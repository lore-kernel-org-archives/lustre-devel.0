From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:08:56 -0500
Subject: [lustre-devel] [PATCH 068/622] lustre: osc: depart grant shrinking
 from pinger
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-69-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Bobi Jam <bobijam@hotmail.com>

* Removing grant shrinking code outside of pinger, use a workqueue
  to handle grant shrinking timer.
* Enable OSC grant shrinking by default.

bugzilla: 19507

WC-bug-id: https://jira.whamcloud.com/browse/LU-8708
Lustre-commit: fc915a43786e ("LU-8708 osc: depart grant shrinking from pinger")
Signed-off-by: Bobi Jam <bobijam@hotmail.com>
Reviewed-on: https://review.whamcloud.com/23202
Reviewed-by: Hongchao Zhang <hongchao@whamcloud.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ldlm/ldlm_lib.c   |   1 +
 fs/lustre/llite/llite_lib.c |   2 +-
 fs/lustre/osc/osc_request.c | 155 ++++++++++++++++++++++++++++++--------------
 3 files changed, 110 insertions(+), 48 deletions(-)

diff --git a/fs/lustre/ldlm/ldlm_lib.c b/fs/lustre/ldlm/ldlm_lib.c
index 2c0fad3..838ddb3 100644
--- a/fs/lustre/ldlm/ldlm_lib.c
+++ b/fs/lustre/ldlm/ldlm_lib.c
@@ -349,6 +349,7 @@ int client_obd_setup(struct obd_device *obddev, struct lustre_cfg *lcfg)
 	spin_lock_init(&cli->cl_lru_list_lock);
 	atomic_long_set(&cli->cl_unstable_count, 0);
 	INIT_LIST_HEAD(&cli->cl_shrink_list);
+	INIT_LIST_HEAD(&cli->cl_grant_chain);
 
 	INIT_LIST_HEAD(&cli->cl_flight_waiters);
 	cli->cl_rpcs_in_flight = 0;
diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index 0844318..56624e8 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -399,7 +399,7 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt)
 				  OBD_CONNECT_LAYOUTLOCK  |
 				  OBD_CONNECT_PINGLESS	| OBD_CONNECT_LFSCK |
 				  OBD_CONNECT_BULK_MBITS  | OBD_CONNECT_SHORTIO |
-				  OBD_CONNECT_FLAGS2;
+				  OBD_CONNECT_FLAGS2 | OBD_CONNECT_GRANT_SHRINK;
 
 	/* The client currently advertises support for OBD_CONNECT_LOCKAHEAD_OLD
 	 * so it can interoperate with an older version of lockahead which was
diff --git a/fs/lustre/osc/osc_request.c b/fs/lustre/osc/osc_request.c
index e341fcc..1a9ed8d 100644
--- a/fs/lustre/osc/osc_request.c
+++ b/fs/lustre/osc/osc_request.c
@@ -33,6 +33,7 @@
 
 #define DEBUG_SUBSYSTEM S_OSC
 
+#include <linux/workqueue.h>
 #include <linux/highmem.h>
 #include <linux/libcfs/libcfs_hash.h>
 #include <linux/sched/mm.h>
@@ -721,6 +722,16 @@ static void osc_update_grant(struct client_obd *cli, struct ost_body *body)
 	}
 }
 
+/**
+ * grant thread data for shrinking space.
+ */
+struct grant_thread_data {
+	struct list_head	gtd_clients;
+	struct mutex		gtd_mutex;
+	unsigned long		gtd_stopped:1;
+};
+static struct grant_thread_data client_gtd;
+
 static int osc_shrink_grant_interpret(const struct lu_env *env,
 				      struct ptlrpc_request *req,
 				      void *aa, int rc)
@@ -823,6 +834,9 @@ static int osc_should_shrink_grant(struct client_obd *client)
 {
 	time64_t next_shrink = client->cl_next_shrink_grant;
 
+	if (!client->cl_import)
+		return 0;
+
 	if ((client->cl_import->imp_connect_data.ocd_connect_flags &
 	     OBD_CONNECT_GRANT_SHRINK) == 0)
 		return 0;
@@ -843,38 +857,83 @@ static int osc_should_shrink_grant(struct client_obd *client)
 	return 0;
 }
 
-static int osc_grant_shrink_grant_cb(struct timeout_item *item, void *data)
-{
-	struct client_obd *client;
+#define GRANT_SHRINK_RPC_BATCH	100
+
+static void osc_grant_work_handler(struct work_struct *data);
+static DECLARE_DELAYED_WORK(work, osc_grant_work_handler);
 
-	list_for_each_entry(client, &item->ti_obd_list, cl_grant_shrink_list) {
-		if (osc_should_shrink_grant(client))
-			osc_shrink_grant(client);
+static void osc_grant_work_handler(struct work_struct *data)
+{
+	struct client_obd *cli;
+	int rpc_sent;
+	bool init_next_shrink = true;
+	time64_t next_shrink = ktime_get_seconds() + GRANT_SHRINK_INTERVAL;
+
+	rpc_sent = 0;
+	mutex_lock(&client_gtd.gtd_mutex);
+	list_for_each_entry(cli, &client_gtd.gtd_clients,
+			    cl_grant_chain) {
+		if (++rpc_sent < GRANT_SHRINK_RPC_BATCH &&
+		    osc_should_shrink_grant(cli))
+			osc_shrink_grant(cli);
+
+		if (!init_next_shrink) {
+			if (cli->cl_next_shrink_grant < next_shrink &&
+			    cli->cl_next_shrink_grant > ktime_get_seconds())
+				next_shrink = cli->cl_next_shrink_grant;
+		} else {
+			init_next_shrink = false;
+			next_shrink = cli->cl_next_shrink_grant;
+		}
 	}
-	return 0;
+	mutex_unlock(&client_gtd.gtd_mutex);
+
+	if (client_gtd.gtd_stopped == 1)
+		return;
+
+	if (next_shrink > ktime_get_seconds())
+		schedule_delayed_work(&work, msecs_to_jiffies(
+					(next_shrink - ktime_get_seconds()) *
+					MSEC_PER_SEC));
+	else
+		schedule_work(&work.work);
 }
 
-static int osc_add_shrink_grant(struct client_obd *client)
+/**
+ * Start grant thread for returing grant to server for idle clients.
+ */
+static int osc_start_grant_work(void)
 {
-	int rc;
+	client_gtd.gtd_stopped = 0;
+	mutex_init(&client_gtd.gtd_mutex);
+	INIT_LIST_HEAD(&client_gtd.gtd_clients);
+
+	schedule_work(&work.work);
 
-	rc = ptlrpc_add_timeout_client(client->cl_grant_shrink_interval,
-				       TIMEOUT_GRANT,
-				       osc_grant_shrink_grant_cb, NULL,
-				       &client->cl_grant_shrink_list);
-	if (rc) {
-		CERROR("add grant client %s error %d\n", cli_name(client), rc);
-		return rc;
-	}
-	CDEBUG(D_CACHE, "add grant client %s\n", cli_name(client));
-	osc_update_next_shrink(client);
 	return 0;
 }
 
-static int osc_del_shrink_grant(struct client_obd *client)
+static void osc_stop_grant_work(void)
+{
+	client_gtd.gtd_stopped = 1;
+	cancel_delayed_work_sync(&work);
+}
+
+static void osc_add_grant_list(struct client_obd *client)
 {
-	return ptlrpc_del_timeout_client(&client->cl_grant_shrink_list,
-					 TIMEOUT_GRANT);
+	mutex_lock(&client_gtd.gtd_mutex);
+	list_add(&client->cl_grant_chain, &client_gtd.gtd_clients);
+	mutex_unlock(&client_gtd.gtd_mutex);
+}
+
+static void osc_del_grant_list(struct client_obd *client)
+{
+	if (list_empty(&client->cl_grant_chain))
+		return;
+
+	mutex_lock(&client_gtd.gtd_mutex);
+	list_del_init(&client->cl_grant_chain);
+	mutex_unlock(&client_gtd.gtd_mutex);
 }
 
 void osc_init_grant(struct client_obd *cli, struct obd_connect_data *ocd)
@@ -929,9 +988,8 @@ void osc_init_grant(struct client_obd *cli, struct obd_connect_data *ocd)
 	       cli_name(cli), cli->cl_avail_grant, cli->cl_lost_grant,
 	       cli->cl_chunkbits, cli->cl_max_extent_pages);
 
-	if (ocd->ocd_connect_flags & OBD_CONNECT_GRANT_SHRINK &&
-	    list_empty(&cli->cl_grant_shrink_list))
-		osc_add_shrink_grant(cli);
+	if (OCD_HAS_FLAG(ocd, GRANT_SHRINK) && list_empty(&cli->cl_grant_chain))
+		osc_add_grant_list(cli);
 }
 EXPORT_SYMBOL(osc_init_grant);
 
@@ -2971,15 +3029,12 @@ int osc_disconnect(struct obd_export *exp)
 	 *				     osc_disconnect
 	 *				     del_shrink_grant
 	 *   ptlrpc_connect_interrupt
-	 *     init_grant_shrink
+	 *     osc_init_grant
 	 *   add this client to shrink list
-	 *				      cleanup_osc
-	 * Bang! pinger trigger the shrink.
-	 * So the osc should be disconnected from the shrink list, after we
-	 * are sure the import has been destroyed. BUG18662
+	 *				     cleanup_osc
+	 * Bang! grant shrink thread trigger the shrink. BUG18662
 	 */
-	if (!obd->u.cli.cl_import)
-		osc_del_shrink_grant(&obd->u.cli);
+	osc_del_grant_list(&obd->u.cli);
 	return rc;
 }
 EXPORT_SYMBOL(osc_disconnect);
@@ -3159,8 +3214,8 @@ int osc_setup_common(struct obd_device *obd, struct lustre_cfg *lcfg)
 		goto out_ptlrpcd_work;
 
 	cli->cl_grant_shrink_interval = GRANT_SHRINK_INTERVAL;
+	osc_update_next_shrink(cli);
 
-	INIT_LIST_HEAD(&cli->cl_grant_shrink_list);
 	return 0;
 
 out_ptlrpcd_work:
@@ -3210,7 +3265,6 @@ int osc_setup(struct obd_device *obd, struct lustre_cfg *lcfg)
 		atomic_add(added, &osc_pool_req_count);
 	}
 
-	INIT_LIST_HEAD(&cli->cl_grant_shrink_list);
 	ns_register_cancel(obd->obd_namespace, osc_cancel_weight);
 
 	spin_lock(&osc_shrink_lock);
@@ -3356,14 +3410,19 @@ static int __init osc_init(void)
 	if (rc)
 		return rc;
 
+	rc = class_register_type(&osc_obd_ops, NULL,
+				 LUSTRE_OSC_NAME, &osc_device_type);
+	if (rc)
+		goto out_kmem;
+
 	rc = register_shrinker(&osc_cache_shrinker);
 	if (rc)
-		goto err;
+		goto out_type;
 
 	/* This is obviously too much memory, only prevent overflow here */
 	if (osc_reqpool_mem_max >= 1 << 12 || osc_reqpool_mem_max == 0) {
 		rc = -EINVAL;
-		goto err;
+		goto out_shrinker;
 	}
 
 	reqpool_size = osc_reqpool_mem_max << 20;
@@ -3383,29 +3442,31 @@ static int __init osc_init(void)
 	atomic_set(&osc_pool_req_count, 0);
 	osc_rq_pool = ptlrpc_init_rq_pool(0, OST_MAXREQSIZE,
 					  ptlrpc_add_rqs_to_pool);
+	if (!osc_rq_pool) {
+		rc = -ENOMEM;
+		goto out_shrinker;
+	}
 
-	rc = -ENOMEM;
-
-	if (!osc_rq_pool)
-		goto err;
-
-	rc = class_register_type(&osc_obd_ops, NULL,
-				 LUSTRE_OSC_NAME, &osc_device_type);
+	rc = osc_start_grant_work();
 	if (rc)
-		goto err;
+		goto out_req_pool;
 
 	return rc;
 
-err:
-	if (osc_rq_pool)
-		ptlrpc_free_rq_pool(osc_rq_pool);
+out_req_pool:
+	ptlrpc_free_rq_pool(osc_rq_pool);
+out_type:
+	class_unregister_type(LUSTRE_OSC_NAME);
+out_shrinker:
 	unregister_shrinker(&osc_cache_shrinker);
+out_kmem:
 	lu_kmem_fini(osc_caches);
 	return rc;
 }
 
 static void /*__exit*/ osc_exit(void)
 {
+	osc_stop_grant_work();
 	unregister_shrinker(&osc_cache_shrinker);
 	class_unregister_type(LUSTRE_OSC_NAME);
 	lu_kmem_fini(osc_caches);
-- 
1.8.3.1
