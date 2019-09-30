From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Sep 2019 14:55:04 -0400
Subject: [lustre-devel] [PATCH 045/151] lustre: osc: common client
 setup/cleanup
In-Reply-To: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1569869810-23848-46-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mikhal Pershin <mpershin@whamcloud.com>

Make OSC code related to client setup/cleanup common for
both OSB and MDC. Add new events in mdc_import_event().

WC-bug-id: https://jira.whamcloud.com/browse/LU-3285
Lustre-commit: a1bd0f62ee08 ("LU-3285 osc: common client setup/cleanup")
Signed-off-by: Mikhal Pershin <mpershin@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/28014
Reviewed-by: Lai Siyao <lai.siyao@whamcloud.com>
Reviewed-by: Jinshan Xiong <jinshan.xiong@gmail.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_osc.h | 30 +++++++++++++--
 fs/lustre/include/obd.h        |  4 ++
 fs/lustre/ldlm/ldlm_lib.c      |  3 ++
 fs/lustre/mdc/mdc_request.c    | 59 +++++++++++++----------------
 fs/lustre/obdclass/genops.c    | 22 +++++------
 fs/lustre/osc/osc_cache.c      | 17 ++-------
 fs/lustre/osc/osc_internal.h   |  1 +
 fs/lustre/osc/osc_object.c     |  2 +-
 fs/lustre/osc/osc_request.c    | 85 +++++++++++++++++++++++++++---------------
 9 files changed, 130 insertions(+), 93 deletions(-)

diff --git a/fs/lustre/include/lustre_osc.h b/fs/lustre/include/lustre_osc.h
index f14ae85..5723261 100644
--- a/fs/lustre/include/lustre_osc.h
+++ b/fs/lustre/include/lustre_osc.h
@@ -51,6 +51,7 @@
 
 #include <obd.h>
 #include <cl_object.h>
+#include <linux/libcfs/libcfs_hash.h>
 
 struct osc_quota_info {
 	/* linkage for quota hash table */
@@ -479,9 +480,23 @@ int osc_cache_writeback_range(const struct lu_env *env, struct osc_object *obj,
 			      pgoff_t start, pgoff_t end, int hp, int discard);
 int osc_cache_wait_range(const struct lu_env *env, struct osc_object *obj,
 			 pgoff_t start, pgoff_t end);
-void osc_io_unplug(const struct lu_env *env, struct client_obd *cli,
-		   struct osc_object *osc);
-int lru_queue_work(const struct lu_env *env, void *data);
+
+int __osc_io_unplug(const struct lu_env *env, struct client_obd *cli,
+		    struct osc_object *osc, int async);
+
+static inline int osc_io_unplug_async(const struct lu_env *env,
+				      struct client_obd *cli,
+				      struct osc_object *osc)
+{
+	return __osc_io_unplug(env, cli, osc, 1);
+}
+
+static inline void osc_io_unplug(const struct lu_env *env,
+				 struct client_obd *cli,
+				 struct osc_object *osc)
+{
+	(void)__osc_io_unplug(env, cli, osc, 0);
+}
 
 void osc_object_set_contended(struct osc_object *obj);
 void osc_object_clear_contended(struct osc_object *obj);
@@ -511,9 +526,18 @@ int osc_attr_update(const struct lu_env *env, struct cl_object *obj,
 		    const struct cl_attr *attr, unsigned int valid);
 int osc_object_glimpse(const struct lu_env *env, const struct cl_object *obj,
 		       struct ost_lvb *lvb);
+int osc_object_invalidate(const struct lu_env *env, struct osc_object *osc);
 
 /* osc_request.c */
 void osc_init_grant(struct client_obd *cli, struct obd_connect_data *ocd);
+int osc_setup_common(struct obd_device *obd, struct lustre_cfg *lcfg);
+int osc_precleanup_common(struct obd_device *obd);
+int osc_cleanup_common(struct obd_device *obd);
+int osc_set_info_async(const struct lu_env *env, struct obd_export *exp,
+		       u32 keylen, void *key, u32 vallen, void *val,
+		       struct ptlrpc_request_set *set);
+int osc_ldlm_resource_invalidate(struct cfs_hash *hs, struct cfs_hash_bd *bd,
+				 struct hlist_node *hnode, void *arg);
 
 /****************************************************************************
  *
diff --git a/fs/lustre/include/obd.h b/fs/lustre/include/obd.h
index baa97a9..62a8ea9 100644
--- a/fs/lustre/include/obd.h
+++ b/fs/lustre/include/obd.h
@@ -316,6 +316,10 @@ struct client_obd {
 	atomic_t		cl_mgc_refcount;
 	struct obd_export      *cl_mgc_mgsexp;
 
+	/* in-flight control list and total RPCs counter */
+	struct list_head	 cl_flight_waiters;
+	u32			 cl_rpcs_in_flight;
+
 	/* checksumming for data sent over the network */
 	unsigned int		cl_checksum:1,	/* 0 = disabled, 1 = enabled */
 				cl_checksum_dump:1; /* same */
diff --git a/fs/lustre/ldlm/ldlm_lib.c b/fs/lustre/ldlm/ldlm_lib.c
index 67f3297..3a7b3fb 100644
--- a/fs/lustre/ldlm/ldlm_lib.c
+++ b/fs/lustre/ldlm/ldlm_lib.c
@@ -351,6 +351,9 @@ int client_obd_setup(struct obd_device *obddev, struct lustre_cfg *lcfg)
 	atomic_long_set(&cli->cl_unstable_count, 0);
 	INIT_LIST_HEAD(&cli->cl_shrink_list);
 
+	INIT_LIST_HEAD(&cli->cl_flight_waiters);
+	cli->cl_rpcs_in_flight = 0;
+
 	init_waitqueue_head(&cli->cl_destroy_waitq);
 	atomic_set(&cli->cl_destroy_in_flight, 0);
 	/* Turn on checksumming by default. */
diff --git a/fs/lustre/mdc/mdc_request.c b/fs/lustre/mdc/mdc_request.c
index 96e0d0a..85eb0ec 100644
--- a/fs/lustre/mdc/mdc_request.c
+++ b/fs/lustre/mdc/mdc_request.c
@@ -2242,14 +2242,6 @@ static int mdc_set_info_async(const struct lu_env *env,
 		return do_set_info_async(imp, MDS_SET_INFO, LUSTRE_MDS_VERSION,
 					 keylen, key, vallen, val, set);
 	}
-	if (KEY_IS(KEY_SPTLRPC_CONF)) {
-		sptlrpc_conf_client_adapt(exp->exp_obd);
-		return 0;
-	}
-	if (KEY_IS(KEY_FLUSH_CTX)) {
-		sptlrpc_import_flush_my_ctx(imp);
-		return 0;
-	}
 	if (KEY_IS(KEY_CHANGELOG_CLEAR)) {
 		rc = do_set_info_async(imp, MDS_SET_INFO, LUSTRE_MDS_VERSION,
 				       keylen, key, vallen, val, set);
@@ -2266,13 +2258,7 @@ static int mdc_set_info_async(const struct lu_env *env,
 		return 0;
 	}
 
-	/* TODO: these OSC-related keys are ignored for now */
-	if (KEY_IS(KEY_CHECKSUM) || KEY_IS(KEY_CACHE_SET) ||
-	    KEY_IS(KEY_CACHE_LRU_SHRINK) || KEY_IS(KEY_GRANT_SHRINK))
-		return 0;
-
-	CERROR("%s: Unknown key %s\n", exp->exp_obd->obd_name, (char *)key);
-	return -EINVAL;
+	return osc_set_info_async(env, exp, keylen, key, vallen, val, set);
 }
 
 static int mdc_get_info(const struct lu_env *env, struct obd_export *exp,
@@ -2350,22 +2336,19 @@ static int mdc_fsync(struct obd_export *exp, const struct lu_fid *fid,
 static int mdc_import_event(struct obd_device *obd, struct obd_import *imp,
 			    enum obd_import_event event)
 {
+	struct client_obd *cli = &obd->u.cli;
 	int rc = 0;
 
 	LASSERT(imp->imp_obd == obd);
 
 	switch (event) {
-	case IMP_EVENT_DISCON: {
-		struct client_obd *cli = &obd->u.cli;
-
+	case IMP_EVENT_DISCON:
 		spin_lock(&cli->cl_loi_list_lock);
 		cli->cl_avail_grant = 0;
 		cli->cl_lost_grant = 0;
 		spin_unlock(&cli->cl_loi_list_lock);
 		break;
-	}
-	case IMP_EVENT_INACTIVE: {
-		struct client_obd *cli = &obd->u.cli;
+	case IMP_EVENT_INACTIVE:
 		/*
 		 * Flush current sequence to make client obtain new one
 		 * from server in case of disconnect/reconnect.
@@ -2377,12 +2360,28 @@ static int mdc_import_event(struct obd_device *obd, struct obd_import *imp,
 
 		rc = obd_notify_observer(obd, obd, OBD_NOTIFY_INACTIVE);
 		break;
-	}
 	case IMP_EVENT_INVALIDATE: {
 		struct ldlm_namespace *ns = obd->obd_namespace;
+		struct lu_env *env;
+		u16 refcheck;
 
 		ldlm_namespace_cleanup(ns, LDLM_FL_LOCAL_ONLY);
 
+		env = cl_env_get(&refcheck);
+		if (!IS_ERR(env)) {
+			/* Reset grants. All pages go to failing rpcs due to
+			 * the invalid import.
+			 */
+			osc_io_unplug(env, cli, NULL);
+
+			cfs_hash_for_each_nolock(ns->ns_rs_hash,
+						 osc_ldlm_resource_invalidate,
+						 env, 0);
+			cl_env_put(env, &refcheck);
+			ldlm_namespace_cleanup(ns, LDLM_FL_LOCAL_ONLY);
+		} else {
+			rc = PTR_ERR(env);
+		}
 		break;
 	}
 	case IMP_EVENT_ACTIVE:
@@ -2398,7 +2397,7 @@ static int mdc_import_event(struct obd_device *obd, struct obd_import *imp,
 		struct obd_connect_data *ocd = &imp->imp_connect_data;
 
 		if (OCD_HAS_FLAG(ocd, GRANT))
-			osc_init_grant(&obd->u.cli, ocd);
+			osc_init_grant(cli, ocd);
 
 		rc = obd_notify_observer(obd, obd, OBD_NOTIFY_OCD);
 		break;
@@ -2497,14 +2496,10 @@ int mdc_setup(struct obd_device *obd, struct lustre_cfg *cfg)
 {
 	int rc;
 
-	rc = ptlrpcd_addref();
+	rc = osc_setup_common(obd, cfg);
 	if (rc < 0)
 		return rc;
 
-	rc = client_obd_setup(obd, cfg);
-	if (rc)
-		goto err_ptlrpcd_decref;
-
 	rc = mdc_tunables_init(obd);
 	if (rc)
 		goto err_osc_cleanup;
@@ -2536,8 +2531,6 @@ int mdc_setup(struct obd_device *obd, struct lustre_cfg *cfg)
 	ptlrpc_lprocfs_unregister_obd(obd);
 err_osc_cleanup:
 	client_obd_cleanup(obd);
-err_ptlrpcd_decref:
-	ptlrpcd_decref();
 	return rc;
 }
 
@@ -2565,6 +2558,8 @@ static int mdc_init_ea_size(struct obd_export *exp, u32 easize, u32 def_easize)
 
 static int mdc_precleanup(struct obd_device *obd)
 {
+	osc_precleanup_common(obd);
+
 	/* Failsafe, ok if racy */
 	if (atomic_read(&obd->obd_type->typ_refcnt) <= 1)
 		libcfs_kkuc_group_rem(0, KUC_GRP_HSM);
@@ -2581,9 +2576,7 @@ static int mdc_precleanup(struct obd_device *obd)
 
 static int mdc_cleanup(struct obd_device *obd)
 {
-	ptlrpcd_decref();
-
-	return client_obd_cleanup(obd);
+	return osc_cleanup_common(obd);
 }
 
 int mdc_process_config(struct obd_device *obd, u32 len, void *buf)
diff --git a/fs/lustre/obdclass/genops.c b/fs/lustre/obdclass/genops.c
index 4b528a7..68d267f 100644
--- a/fs/lustre/obdclass/genops.c
+++ b/fs/lustre/obdclass/genops.c
@@ -1291,14 +1291,14 @@ int obd_get_request_slot(struct client_obd *cli)
 	int rc;
 
 	spin_lock(&cli->cl_loi_list_lock);
-	if (cli->cl_r_in_flight < cli->cl_max_rpcs_in_flight) {
-		cli->cl_r_in_flight++;
+	if (cli->cl_rpcs_in_flight < cli->cl_max_rpcs_in_flight) {
+		cli->cl_rpcs_in_flight++;
 		spin_unlock(&cli->cl_loi_list_lock);
 		return 0;
 	}
 
 	init_waitqueue_head(&orsw.orsw_waitq);
-	list_add_tail(&orsw.orsw_entry, &cli->cl_loi_read_list);
+	list_add_tail(&orsw.orsw_entry, &cli->cl_flight_waiters);
 	orsw.orsw_signaled = false;
 	spin_unlock(&cli->cl_loi_list_lock);
 
@@ -1314,7 +1314,7 @@ int obd_get_request_slot(struct client_obd *cli)
 	if (rc) {
 		if (!orsw.orsw_signaled) {
 			if (list_empty(&orsw.orsw_entry))
-				cli->cl_r_in_flight--;
+				cli->cl_rpcs_in_flight--;
 			else
 				list_del(&orsw.orsw_entry);
 		}
@@ -1336,16 +1336,16 @@ void obd_put_request_slot(struct client_obd *cli)
 	struct obd_request_slot_waiter *orsw;
 
 	spin_lock(&cli->cl_loi_list_lock);
-	cli->cl_r_in_flight--;
+	cli->cl_rpcs_in_flight--;
 
 	/* If there is free slot, wakeup the first waiter. */
-	if (!list_empty(&cli->cl_loi_read_list) &&
-	    likely(cli->cl_r_in_flight < cli->cl_max_rpcs_in_flight)) {
-		orsw = list_first_entry(&cli->cl_loi_read_list,
+	if (!list_empty(&cli->cl_flight_waiters) &&
+	    likely(cli->cl_rpcs_in_flight < cli->cl_max_rpcs_in_flight)) {
+		orsw = list_first_entry(&cli->cl_flight_waiters,
 					struct obd_request_slot_waiter,
 					orsw_entry);
 		list_del_init(&orsw->orsw_entry);
-		cli->cl_r_in_flight++;
+		cli->cl_rpcs_in_flight++;
 		wake_up(&orsw->orsw_waitq);
 	}
 	spin_unlock(&cli->cl_loi_list_lock);
@@ -1395,14 +1395,14 @@ int obd_set_max_rpcs_in_flight(struct client_obd *cli, u32 max)
 
 	/* We increase the max_rpcs_in_flight, then wakeup some waiters. */
 	for (i = 0; i < diff; i++) {
-		orsw = list_first_entry_or_null(&cli->cl_loi_read_list,
+		orsw = list_first_entry_or_null(&cli->cl_flight_waiters,
 						struct obd_request_slot_waiter,
 						orsw_entry);
 		if (!orsw)
 			break;
 
 		list_del_init(&orsw->orsw_entry);
-		cli->cl_r_in_flight++;
+		cli->cl_rpcs_in_flight++;
 		wake_up(&orsw->orsw_waitq);
 	}
 	spin_unlock(&cli->cl_loi_list_lock);
diff --git a/fs/lustre/osc/osc_cache.c b/fs/lustre/osc/osc_cache.c
index 1d06654..65fdbc1 100644
--- a/fs/lustre/osc/osc_cache.c
+++ b/fs/lustre/osc/osc_cache.c
@@ -2260,8 +2260,8 @@ static void osc_check_rpcs(const struct lu_env *env, struct client_obd *cli)
 	spin_unlock(&cli->cl_loi_list_lock);
 }
 
-static int __osc_io_unplug(const struct lu_env *env, struct client_obd *cli,
-			   struct osc_object *osc, int async)
+int __osc_io_unplug(const struct lu_env *env, struct client_obd *cli,
+		    struct osc_object *osc, int async)
 {
 	int rc = 0;
 
@@ -2278,18 +2278,7 @@ static int __osc_io_unplug(const struct lu_env *env, struct client_obd *cli,
 
 	return rc;
 }
-
-static int osc_io_unplug_async(const struct lu_env *env,
-			       struct client_obd *cli, struct osc_object *osc)
-{
-	return __osc_io_unplug(env, cli, osc, 1);
-}
-
-void osc_io_unplug(const struct lu_env *env, struct client_obd *cli,
-		   struct osc_object *osc)
-{
-	(void)__osc_io_unplug(env, cli, osc, 0);
-}
+EXPORT_SYMBOL(__osc_io_unplug);
 
 int osc_prep_async_page(struct osc_object *osc, struct osc_page *ops,
 			struct page *page, loff_t offset)
diff --git a/fs/lustre/osc/osc_internal.h b/fs/lustre/osc/osc_internal.h
index 72cf131..873556a 100644
--- a/fs/lustre/osc/osc_internal.h
+++ b/fs/lustre/osc/osc_internal.h
@@ -44,6 +44,7 @@
 
 int osc_shrink_grant_to_target(struct client_obd *cli, u64 target_bytes);
 void osc_update_next_shrink(struct client_obd *cli);
+int lru_queue_work(const struct lu_env *env, void *data);
 
 typedef int (*osc_enqueue_upcall_f)(void *cookie, struct lustre_handle *lockh,
 				    int rc);
diff --git a/fs/lustre/osc/osc_object.c b/fs/lustre/osc/osc_object.c
index 9ba3785..d34e6f2 100644
--- a/fs/lustre/osc/osc_object.c
+++ b/fs/lustre/osc/osc_object.c
@@ -462,5 +462,5 @@ int osc_object_invalidate(const struct lu_env *env, struct osc_object *osc)
 
 	return 0;
 }
-
+EXPORT_SYMBOL(osc_object_invalidate);
 /** @} osc */
diff --git a/fs/lustre/osc/osc_request.c b/fs/lustre/osc/osc_request.c
index 96d2c01..e804554 100644
--- a/fs/lustre/osc/osc_request.c
+++ b/fs/lustre/osc/osc_request.c
@@ -737,10 +737,6 @@ static void osc_update_grant(struct client_obd *cli, struct ost_body *body)
 	}
 }
 
-static int osc_set_info_async(const struct lu_env *env, struct obd_export *exp,
-			      u32 keylen, void *key, u32 vallen,
-			      void *val, struct ptlrpc_request_set *set);
-
 static int osc_shrink_grant_interpret(const struct lu_env *env,
 				      struct ptlrpc_request *req,
 				      void *aa, int rc)
@@ -2524,9 +2520,10 @@ static int osc_iocontrol(unsigned int cmd, struct obd_export *exp, int len,
 	return err;
 }
 
-static int osc_set_info_async(const struct lu_env *env, struct obd_export *exp,
-			      u32 keylen, void *key, u32 vallen,
-			      void *val, struct ptlrpc_request_set *set)
+int osc_set_info_async(const struct lu_env *env, struct obd_export *exp,
+		       u32 keylen, void *key,
+		       u32 vallen, void *val,
+		       struct ptlrpc_request_set *set)
 {
 	struct ptlrpc_request *req;
 	struct obd_device *obd = exp->exp_obd;
@@ -2642,6 +2639,7 @@ static int osc_set_info_async(const struct lu_env *env, struct obd_export *exp,
 
 	return 0;
 }
+EXPORT_SYMBOL(osc_set_info_async);
 
 static int osc_reconnect(const struct lu_env *env,
 			 struct obd_export *exp, struct obd_device *obd,
@@ -2702,9 +2700,9 @@ static int osc_disconnect(struct obd_export *exp)
 	return rc;
 }
 
-static int osc_ldlm_resource_invalidate(struct cfs_hash *hs,
-					struct cfs_hash_bd *bd,
-					struct hlist_node *hnode, void *arg)
+int osc_ldlm_resource_invalidate(struct cfs_hash *hs,
+				 struct cfs_hash_bd *bd,
+				 struct hlist_node *hnode, void *arg)
 {
 	struct ldlm_resource *res = cfs_hash_object(hs, hnode);
 	struct osc_object *osc = NULL;
@@ -2734,6 +2732,7 @@ static int osc_ldlm_resource_invalidate(struct cfs_hash *hs,
 
 	return 0;
 }
+EXPORT_SYMBOL(osc_ldlm_resource_invalidate);
 
 static int osc_import_event(struct obd_device *obd,
 			    struct obd_import *imp,
@@ -2842,14 +2841,11 @@ static int brw_queue_work(const struct lu_env *env, void *data)
 	return 0;
 }
 
-int osc_setup(struct obd_device *obd, struct lustre_cfg *lcfg)
+int osc_setup_common(struct obd_device *obd, struct lustre_cfg *lcfg)
 {
 	struct client_obd *cli = &obd->u.cli;
 	void *handler;
 	int rc;
-	int adding;
-	int added;
-	int req_count;
 
 	rc = ptlrpcd_addref();
 	if (rc)
@@ -2862,7 +2858,7 @@ int osc_setup(struct obd_device *obd, struct lustre_cfg *lcfg)
 	handler = ptlrpcd_alloc_work(cli->cl_import, brw_queue_work, cli);
 	if (IS_ERR(handler)) {
 		rc = PTR_ERR(handler);
-		goto out_client_setup;
+		goto out_ptlrpcd_work;
 	}
 	cli->cl_writeback_work = handler;
 
@@ -2880,6 +2876,37 @@ int osc_setup(struct obd_device *obd, struct lustre_cfg *lcfg)
 
 	cli->cl_grant_shrink_interval = GRANT_SHRINK_INTERVAL;
 
+	INIT_LIST_HEAD(&cli->cl_grant_shrink_list);
+	return 0;
+
+out_ptlrpcd_work:
+	if (cli->cl_writeback_work) {
+		ptlrpcd_destroy_work(cli->cl_writeback_work);
+		cli->cl_writeback_work = NULL;
+	}
+	if (cli->cl_lru_work) {
+		ptlrpcd_destroy_work(cli->cl_lru_work);
+		cli->cl_lru_work = NULL;
+	}
+	client_obd_cleanup(obd);
+out_ptlrpcd:
+	ptlrpcd_decref();
+	return rc;
+}
+EXPORT_SYMBOL(osc_setup_common);
+
+int osc_setup(struct obd_device *obd, struct lustre_cfg *lcfg)
+{
+	struct client_obd *cli = &obd->u.cli;
+	int adding;
+	int added;
+	int req_count;
+	int rc;
+
+	rc = osc_setup_common(obd, lcfg);
+	if (rc < 0)
+		return rc;
+
 	rc = osc_tunables_init(obd);
 	if (rc)
 		goto out_quota;
@@ -2910,23 +2937,10 @@ int osc_setup(struct obd_device *obd, struct lustre_cfg *lcfg)
 
 out_quota:
 	osc_quota_cleanup(obd);
-out_ptlrpcd_work:
-	if (cli->cl_writeback_work) {
-		ptlrpcd_destroy_work(cli->cl_writeback_work);
-		cli->cl_writeback_work = NULL;
-	}
-	if (cli->cl_lru_work) {
-		ptlrpcd_destroy_work(cli->cl_lru_work);
-		cli->cl_lru_work = NULL;
-	}
-out_client_setup:
-	client_obd_cleanup(obd);
-out_ptlrpcd:
-	ptlrpcd_decref();
 	return rc;
 }
 
-static int osc_precleanup(struct obd_device *obd)
+int osc_precleanup_common(struct obd_device *obd)
 {
 	struct client_obd *cli = &obd->u.cli;
 
@@ -2951,12 +2965,20 @@ static int osc_precleanup(struct obd_device *obd)
 	}
 
 	obd_cleanup_client_import(obd);
+	return 0;
+}
+EXPORT_SYMBOL(osc_precleanup_common);
+
+static int osc_precleanup(struct obd_device *obd)
+{
+	osc_precleanup_common(obd);
+
 	ptlrpc_lprocfs_unregister_obd(obd);
 	lprocfs_obd_cleanup(obd);
 	return 0;
 }
 
-static int osc_cleanup(struct obd_device *obd)
+int osc_cleanup_common(struct obd_device *obd)
 {
 	struct client_obd *cli = &obd->u.cli;
 	int rc;
@@ -2984,6 +3006,7 @@ static int osc_cleanup(struct obd_device *obd)
 	ptlrpcd_decref();
 	return rc;
 }
+EXPORT_SYMBOL(osc_cleanup_common);
 
 int osc_process_config_base(struct obd_device *obd, struct lustre_cfg *lcfg)
 {
@@ -3001,7 +3024,7 @@ static int osc_process_config(struct obd_device *obd, u32 len, void *buf)
 	.owner		= THIS_MODULE,
 	.setup		= osc_setup,
 	.precleanup	= osc_precleanup,
-	.cleanup	= osc_cleanup,
+	.cleanup	= osc_cleanup_common,
 	.add_conn	= client_import_add_conn,
 	.del_conn	= client_import_del_conn,
 	.connect	= client_connect_import,
-- 
1.8.3.1
