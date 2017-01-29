From: James Simmons <jsimmons@infradead.org>
Date: Sat, 28 Jan 2017 19:04:31 -0500
Subject: [lustre-devel] [PATCH 03/60] staging: lustre: clio: add cl_page LRU
	shrinker
In-Reply-To: <1485648328-2141-1-git-send-email-jsimmons@infradead.org>
References: <1485648328-2141-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1485648328-2141-4-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Bobi Jam <bobijam.xu@intel.com>, James Simmons <jsimmons@infradead.org>

From: Bobi Jam <bobijam.xu@intel.com>

Register cache shrinker to reclaim memory from cl_page LRU list.

Signed-off-by: Bobi Jam <bobijam.xu@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6842
Reviewed-on: http://review.whamcloud.com/15630
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Jinshan Xiong <jinshan.xiong@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/obd.h      |  2 +
 drivers/staging/lustre/lustre/ldlm/ldlm_lib.c    |  1 +
 drivers/staging/lustre/lustre/osc/osc_internal.h |  9 +++
 drivers/staging/lustre/lustre/osc/osc_page.c     | 87 ++++++++++++++++++++++++
 drivers/staging/lustre/lustre/osc/osc_request.c  | 21 ++++++
 5 files changed, 120 insertions(+)

diff --git a/drivers/staging/lustre/lustre/include/obd.h b/drivers/staging/lustre/lustre/include/obd.h
index 7f0fc44..6d3bd05 100644
--- a/drivers/staging/lustre/lustre/include/obd.h
+++ b/drivers/staging/lustre/lustre/include/obd.h
@@ -287,6 +287,8 @@ struct client_obd {
 	 * the transaction has NOT yet committed.
 	 */
 	atomic_long_t		 cl_unstable_count;
+	/** Link to osc_shrinker_list */
+	struct list_head	 cl_shrink_list;
 
 	/* number of in flight destroy rpcs is limited to max_rpcs_in_flight */
 	atomic_t	     cl_destroy_in_flight;
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c
index 9be0142..675e25b 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c
@@ -336,6 +336,7 @@ int client_obd_setup(struct obd_device *obddev, struct lustre_cfg *lcfg)
 	INIT_LIST_HEAD(&cli->cl_lru_list);
 	spin_lock_init(&cli->cl_lru_list_lock);
 	atomic_long_set(&cli->cl_unstable_count, 0);
+	INIT_LIST_HEAD(&cli->cl_shrink_list);
 
 	init_waitqueue_head(&cli->cl_destroy_waitq);
 	atomic_set(&cli->cl_destroy_in_flight, 0);
diff --git a/drivers/staging/lustre/lustre/osc/osc_internal.h b/drivers/staging/lustre/lustre/osc/osc_internal.h
index ff7c9ec..43a43e4 100644
--- a/drivers/staging/lustre/lustre/osc/osc_internal.h
+++ b/drivers/staging/lustre/lustre/osc/osc_internal.h
@@ -222,4 +222,13 @@ struct ldlm_lock *osc_dlmlock_at_pgoff(const struct lu_env *env,
 
 int osc_object_invalidate(const struct lu_env *env, struct osc_object *osc);
 
+/** osc shrink list to link all osc client obd */
+extern struct list_head osc_shrink_list;
+/** spin lock to protect osc_shrink_list */
+extern spinlock_t osc_shrink_lock;
+unsigned long osc_cache_shrink_count(struct shrinker *sk,
+				     struct shrink_control *sc);
+unsigned long osc_cache_shrink_scan(struct shrinker *sk,
+				    struct shrink_control *sc);
+
 #endif /* OSC_INTERNAL_H */
diff --git a/drivers/staging/lustre/lustre/osc/osc_page.c b/drivers/staging/lustre/lustre/osc/osc_page.c
index e356e4a..0461408 100644
--- a/drivers/staging/lustre/lustre/osc/osc_page.c
+++ b/drivers/staging/lustre/lustre/osc/osc_page.c
@@ -943,4 +943,91 @@ bool osc_over_unstable_soft_limit(struct client_obd *cli)
 				    cli->cl_max_rpcs_in_flight;
 }
 
+/**
+ * Return how many LRU pages in the cache of all OSC devices
+ *
+ * Return:	return # of cached LRU pages times reclaimation tendency
+ *		SHRINK_STOP if it cannot do any scanning in this time
+ */
+unsigned long osc_cache_shrink_count(struct shrinker *sk,
+				     struct shrink_control *sc)
+{
+	struct client_obd *cli;
+	unsigned long cached = 0;
+
+	spin_lock(&osc_shrink_lock);
+	list_for_each_entry(cli, &osc_shrink_list, cl_shrink_list)
+		cached += atomic_long_read(&cli->cl_lru_in_list);
+	spin_unlock(&osc_shrink_lock);
+
+	return (cached  * sysctl_vfs_cache_pressure) / 100;
+}
+
+/**
+ * Scan and try to reclaim sc->nr_to_scan cached LRU pages
+ *
+ * Return:	number of cached LRU pages reclaimed
+ *		SHRINK_STOP if it cannot do any scanning in this time
+ *
+ * Linux kernel will loop calling this shrinker scan routine with
+ * sc->nr_to_scan = SHRINK_BATCH(128 for now) until kernel got enough memory.
+ *
+ * If sc->nr_to_scan is 0, the VM is querying the cache size, we don't need
+ * to scan and try to reclaim LRU pages, just return 0 and
+ * osc_cache_shrink_count() will report the LRU page number.
+ */
+unsigned long osc_cache_shrink_scan(struct shrinker *sk,
+				    struct shrink_control *sc)
+{
+	struct client_obd *stop_anchor = NULL;
+	struct client_obd *cli;
+	struct lu_env *env;
+	long shrank = 0;
+	int refcheck;
+	int rc;
+
+	if (!sc->nr_to_scan)
+		return 0;
+
+	if (!(sc->gfp_mask & __GFP_FS))
+		return SHRINK_STOP;
+
+	env = cl_env_get(&refcheck);
+	if (IS_ERR(env))
+		return SHRINK_STOP;
+
+	spin_lock(&osc_shrink_lock);
+	while (!list_empty(&osc_shrink_list)) {
+		cli = list_entry(osc_shrink_list.next, struct client_obd,
+				 cl_shrink_list);
+
+		if (!stop_anchor)
+			stop_anchor = cli;
+		else if (cli == stop_anchor)
+			break;
+
+		list_move_tail(&cli->cl_shrink_list, &osc_shrink_list);
+		spin_unlock(&osc_shrink_lock);
+
+		/* shrink no more than max_pages_per_rpc for an OSC */
+		rc = osc_lru_shrink(env, cli, (sc->nr_to_scan - shrank) >
+				    cli->cl_max_pages_per_rpc ?
+				    cli->cl_max_pages_per_rpc :
+				    sc->nr_to_scan - shrank, true);
+		if (rc > 0)
+			shrank += rc;
+
+		if (shrank >= sc->nr_to_scan)
+			goto out;
+
+		spin_lock(&osc_shrink_lock);
+	}
+	spin_unlock(&osc_shrink_lock);
+
+out:
+	cl_env_put(env, &refcheck);
+
+	return shrank;
+}
+
 /** @} osc */
diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
index 3efae75..c2c0385 100644
--- a/drivers/staging/lustre/lustre/osc/osc_request.c
+++ b/drivers/staging/lustre/lustre/osc/osc_request.c
@@ -2675,6 +2675,11 @@ int osc_setup(struct obd_device *obd, struct lustre_cfg *lcfg)
 
 	INIT_LIST_HEAD(&cli->cl_grant_shrink_list);
 	ns_register_cancel(obd->obd_namespace, osc_cancel_weight);
+
+	spin_lock(&osc_shrink_lock);
+	list_add_tail(&cli->cl_shrink_list, &osc_shrink_list);
+	spin_unlock(&osc_shrink_lock);
+
 	return rc;
 
 out_ptlrpcd_work:
@@ -2728,6 +2733,10 @@ static int osc_cleanup(struct obd_device *obd)
 	struct client_obd *cli = &obd->u.cli;
 	int rc;
 
+	spin_lock(&osc_shrink_lock);
+	list_del(&cli->cl_shrink_list);
+	spin_unlock(&osc_shrink_lock);
+
 	/* lru cleanup */
 	if (cli->cl_cache) {
 		LASSERT(atomic_read(&cli->cl_cache->ccc_users) > 0);
@@ -2795,6 +2804,15 @@ static int osc_process_config(struct obd_device *obd, u32 len, void *buf)
 	.quotactl       = osc_quotactl,
 };
 
+struct list_head osc_shrink_list = LIST_HEAD_INIT(osc_shrink_list);
+DEFINE_SPINLOCK(osc_shrink_lock);
+
+static struct shrinker osc_cache_shrinker = {
+	.count_objects	= osc_cache_shrink_count,
+	.scan_objects	= osc_cache_shrink_scan,
+	.seeks		= DEFAULT_SEEKS,
+};
+
 static int __init osc_init(void)
 {
 	struct lprocfs_static_vars lvars = { NULL };
@@ -2819,6 +2837,8 @@ static int __init osc_init(void)
 	if (rc)
 		goto out_kmem;
 
+	register_shrinker(&osc_cache_shrinker);
+
 	/* This is obviously too much memory, only prevent overflow here */
 	if (osc_reqpool_mem_max >= 1 << 12 || osc_reqpool_mem_max == 0) {
 		rc = -EINVAL;
@@ -2857,6 +2877,7 @@ static int __init osc_init(void)
 
 static void /*__exit*/ osc_exit(void)
 {
+	unregister_shrinker(&osc_cache_shrinker);
 	class_unregister_type(LUSTRE_OSC_NAME);
 	lu_kmem_fini(osc_caches);
 	ptlrpc_free_rq_pool(osc_rq_pool);
-- 
1.8.3.1
