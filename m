From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Mon, 22 Feb 2016 21:54:29 -0500
Subject: [lustre-devel] [PATCH 51/56] staging/lustre/mgc: Adjust comments to
	better conform to coding style
In-Reply-To: <1456196074-754064-1-git-send-email-green@linuxhacker.ru>
References: <1456196074-754064-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1456196074-754064-52-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

This patch fixes "Block comments use a trailing */ on a separate line"
warnings from checkpatch

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/mgc/mgc_request.c | 71 ++++++++++++++++---------
 1 file changed, 46 insertions(+), 25 deletions(-)

diff --git a/drivers/staging/lustre/lustre/mgc/mgc_request.c b/drivers/staging/lustre/lustre/mgc/mgc_request.c
index 9764e57..6fc8225 100644
--- a/drivers/staging/lustre/lustre/mgc/mgc_request.c
+++ b/drivers/staging/lustre/lustre/mgc/mgc_request.c
@@ -90,7 +90,8 @@ static int mgc_name2resid(char *name, int len, struct ldlm_res_id *res_id,
 int mgc_fsname2resid(char *fsname, struct ldlm_res_id *res_id, int type)
 {
 	/* fsname is at most 8 chars long, maybe contain "-".
-	 * e.g. "lustre", "SUN-000" */
+	 * e.g. "lustre", "SUN-000"
+	 */
 	return mgc_name2resid(fsname, strlen(fsname), res_id, type);
 }
 EXPORT_SYMBOL(mgc_fsname2resid);
@@ -102,7 +103,8 @@ static int mgc_logname2resid(char *logname, struct ldlm_res_id *res_id, int type
 
 	/* logname consists of "fsname-nodetype".
 	 * e.g. "lustre-MDT0001", "SUN-000-client"
-	 * there is an exception: llog "params" */
+	 * there is an exception: llog "params"
+	 */
 	name_end = strrchr(logname, '-');
 	if (!name_end)
 		len = strlen(logname);
@@ -125,7 +127,8 @@ static int config_log_get(struct config_llog_data *cld)
 }
 
 /* Drop a reference to a config log.  When no longer referenced,
-   we can free the config log data */
+ * we can free the config log data
+ */
 static void config_log_put(struct config_llog_data *cld)
 {
 	CDEBUG(D_INFO, "log %s refs %d\n", cld->cld_logname,
@@ -252,7 +255,8 @@ static struct config_llog_data *config_recover_log_add(struct obd_device *obd,
 	char logname[32];
 
 	/* we have to use different llog for clients and mdts for cmd
-	 * where only clients are notified if one of cmd server restarts */
+	 * where only clients are notified if one of cmd server restarts
+	 */
 	LASSERT(strlen(fsname) < sizeof(logname) / 2);
 	strcpy(logname, fsname);
 	LASSERT(lcfg.cfg_instance);
@@ -483,8 +487,9 @@ static void do_requeue(struct config_llog_data *cld)
 	LASSERT(atomic_read(&cld->cld_refcount) > 0);
 
 	/* Do not run mgc_process_log on a disconnected export or an
-	   export which is being disconnected. Take the client
-	   semaphore to make the check non-racy. */
+	 * export which is being disconnected. Take the client
+	 * semaphore to make the check non-racy.
+	 */
 	down_read(&cld->cld_mgcexp->exp_obd->u.cli.cl_sem);
 	if (cld->cld_mgcexp->exp_obd->u.cli.cl_conn_count != 0) {
 		CDEBUG(D_MGC, "updating log %s\n", cld->cld_logname);
@@ -529,8 +534,9 @@ static int mgc_requeue_thread(void *data)
 		}
 
 		/* Always wait a few seconds to allow the server who
-		   caused the lock revocation to finish its setup, plus some
-		   random so everyone doesn't try to reconnect at once. */
+		 * caused the lock revocation to finish its setup, plus some
+		 * random so everyone doesn't try to reconnect at once.
+		 */
 		to = MGC_TIMEOUT_MIN_SECONDS * HZ;
 		to += rand * HZ / 100; /* rand is centi-seconds */
 		lwi = LWI_TIMEOUT(to, NULL, NULL);
@@ -559,7 +565,8 @@ static int mgc_requeue_thread(void *data)
 			LASSERT(atomic_read(&cld->cld_refcount) > 0);
 
 			/* Whether we enqueued again or not in mgc_process_log,
-			 * we're done with the ref from the old enqueue */
+			 * we're done with the ref from the old enqueue
+			 */
 			if (cld_prev)
 				config_log_put(cld_prev);
 			cld_prev = cld;
@@ -575,7 +582,8 @@ static int mgc_requeue_thread(void *data)
 			config_log_put(cld_prev);
 
 		/* break after scanning the list so that we can drop
-		 * refcount to losing lock clds */
+		 * refcount to losing lock clds
+		 */
 		if (unlikely(stopped)) {
 			spin_lock(&config_list_lock);
 			break;
@@ -598,7 +606,8 @@ static int mgc_requeue_thread(void *data)
 }
 
 /* Add a cld to the list to requeue.  Start the requeue thread if needed.
-   We are responsible for dropping the config log reference from here on out. */
+ * We are responsible for dropping the config log reference from here on out.
+ */
 static void mgc_requeue_add(struct config_llog_data *cld)
 {
 	CDEBUG(D_INFO, "log %s: requeue (r=%d sp=%d st=%x)\n",
@@ -635,7 +644,8 @@ static int mgc_llog_init(const struct lu_env *env, struct obd_device *obd)
 	int			 rc;
 
 	/* setup only remote ctxt, the local disk context is switched per each
-	 * filesystem during mgc_fs_setup() */
+	 * filesystem during mgc_fs_setup()
+	 */
 	rc = llog_setup(env, obd, &obd->obd_olg, LLOG_CONFIG_REPL_CTXT, obd,
 			&llog_client_ops);
 	if (rc)
@@ -697,7 +707,8 @@ static int mgc_precleanup(struct obd_device *obd, enum obd_cleanup_stage stage)
 static int mgc_cleanup(struct obd_device *obd)
 {
 	/* COMPAT_146 - old config logs may have added profiles we don't
-	   know about */
+	 * know about
+	 */
 	if (obd->obd_type->typ_refcnt <= 1)
 		/* Only for the last mgc */
 		class_del_profiles();
@@ -794,7 +805,8 @@ static int mgc_blocking_ast(struct ldlm_lock *lock, struct ldlm_lock_desc *desc,
 			break;
 		}
 		/* Make sure not to re-enqueue when the mgc is stopping
-		   (we get called from client_disconnect_export) */
+		 * (we get called from client_disconnect_export)
+		 */
 		if (!lock->l_conn_export ||
 		    !lock->l_conn_export->exp_obd->u.cli.cl_conn_count) {
 			CDEBUG(D_MGC, "log %.8s: disconnecting, won't requeue\n",
@@ -816,7 +828,8 @@ static int mgc_blocking_ast(struct ldlm_lock *lock, struct ldlm_lock_desc *desc,
 
 /* Not sure where this should go... */
 /* This is the timeout value for MGS_CONNECT request plus a ping interval, such
- * that we can have a chance to try the secondary MGS if any. */
+ * that we can have a chance to try the secondary MGS if any.
+ */
 #define  MGC_ENQUEUE_LIMIT (INITIAL_CONNECT_TIMEOUT + (AT_OFF ? 0 : at_min) \
 				+ PING_INTERVAL)
 #define  MGC_TARGET_REG_LIMIT 10
@@ -880,7 +893,8 @@ static int mgc_enqueue(struct obd_export *exp, struct lov_stripe_md *lsm,
 	       cld->cld_resid.name[0]);
 
 	/* We need a callback for every lockholder, so don't try to
-	   ldlm_lock_match (see rev 1.1.2.11.2.47) */
+	 * ldlm_lock_match (see rev 1.1.2.11.2.47)
+	 */
 	req = ptlrpc_request_alloc_pack(class_exp2cliimp(exp),
 					&RQF_LDLM_ENQUEUE, LUSTRE_DLM_VERSION,
 					LDLM_ENQUEUE);
@@ -895,7 +909,8 @@ static int mgc_enqueue(struct obd_export *exp, struct lov_stripe_md *lsm,
 	rc = ldlm_cli_enqueue(exp, &req, &einfo, &cld->cld_resid, NULL, flags,
 			      NULL, 0, LVB_T_NONE, lockh, 0);
 	/* A failed enqueue should still call the mgc_blocking_ast,
-	   where it will be requeued if needed ("grant failed"). */
+	 * where it will be requeued if needed ("grant failed").
+	 */
 	ptlrpc_req_finished(req);
 	return rc;
 }
@@ -1373,7 +1388,8 @@ again:
 	}
 
 	/* always update the index even though it might have errors with
-	 * handling the recover logs */
+	 * handling the recover logs
+	 */
 	cfg->cfg_last_idx = res->mcr_offset;
 	eof = res->mcr_offset == res->mcr_size;
 
@@ -1400,7 +1416,8 @@ again:
 	mne_swab = !!ptlrpc_rep_need_swab(req);
 #if LUSTRE_VERSION_CODE < OBD_OCD_VERSION(3, 2, 50, 0)
 	/* This import flag means the server did an extra swab of IR MNE
-	 * records (fixed in LU-1252), reverse it here if needed. LU-1644 */
+	 * records (fixed in LU-1252), reverse it here if needed. LU-1644
+	 */
 	if (unlikely(req->rq_import->imp_need_mne_swab))
 		mne_swab = !mne_swab;
 #else
@@ -1489,7 +1506,8 @@ static int mgc_process_cfg_log(struct obd_device *mgc,
 
 	/* logname and instance info should be the same, so use our
 	 * copy of the instance for the update.  The cfg_last_idx will
-	 * be updated here. */
+	 * be updated here.
+	 */
 	rc = class_config_parse_llog(env, ctxt, cld->cld_logname,
 				     &cld->cld_cfg);
 
@@ -1529,9 +1547,10 @@ int mgc_process_log(struct obd_device *mgc, struct config_llog_data *cld)
 	LASSERT(cld);
 
 	/* I don't want multiple processes running process_log at once --
-	   sounds like badness.  It actually might be fine, as long as
-	   we're not trying to update from the same log
-	   simultaneously (in which case we should use a per-log sem.) */
+	 * sounds like badness.  It actually might be fine, as long as
+	 * we're not trying to update from the same log
+	 * simultaneously (in which case we should use a per-log sem.)
+	 */
 	mutex_lock(&cld->cld_lock);
 	if (cld->cld_stopping) {
 		mutex_unlock(&cld->cld_lock);
@@ -1556,7 +1575,8 @@ int mgc_process_log(struct obd_device *mgc, struct config_llog_data *cld)
 		CDEBUG(D_MGC, "Can't get cfg lock: %d\n", rcl);
 
 		/* mark cld_lostlock so that it will requeue
-		 * after MGC becomes available. */
+		 * after MGC becomes available.
+		 */
 		cld->cld_lostlock = 1;
 		/* Get extra reference, it will be put in requeue thread */
 		config_log_get(cld);
@@ -1642,7 +1662,8 @@ static int mgc_process_config(struct obd_device *obd, u32 len, void *buf)
 
 		/* COMPAT_146 */
 		/* FIXME only set this for old logs!  Right now this forces
-		   us to always skip the "inside markers" check */
+		 * us to always skip the "inside markers" check
+		 */
 		cld->cld_cfg.cfg_flags |= CFG_F_COMPAT146;
 
 		rc = mgc_process_log(obd, cld);
-- 
2.1.0
