From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:16:54 -0500
Subject: [lustre-devel] [PATCH 546/622] lustre: mgc: config lock leak
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-547-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Alexey Lyashkov <c17817@cray.com>

Regression introduced by "LU-580: update mgc llog process code".
It takes additional cld reference to the lock, but lock cancel forget
during normal shutdown. So this lock holds cld on the list for a long
time. any config modification needs to cancel each lock separately.

Cray-bugid: LUS-6253
Fixes: d7e09d0397e8 ("LU-580: update mgc llog process code")

WC-bug-id: https://jira.whamcloud.com/browse/LU-11185
Lustre-commit: 0ad54d597773 ("LU-11185 mgc: config lock leak")
Signed-off-by: Alexey Lyashkov <c17817@cray.com>
Reviewed-on: https://review.whamcloud.com/32890
Reviewed-by: Alexandr Boyko <c17825@cray.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/obd_class.h |  1 +
 fs/lustre/ldlm/ldlm_lock.c    |  3 +++
 fs/lustre/mgc/mgc_request.c   | 57 ++++++++++++++++++++++++++-----------------
 3 files changed, 39 insertions(+), 22 deletions(-)

diff --git a/fs/lustre/include/obd_class.h b/fs/lustre/include/obd_class.h
index a099768..85fe129 100644
--- a/fs/lustre/include/obd_class.h
+++ b/fs/lustre/include/obd_class.h
@@ -197,6 +197,7 @@ int class_config_parse_llog(const struct lu_env *env, struct llog_ctxt *ctxt,
 /* list of active configuration logs  */
 struct config_llog_data {
 	struct ldlm_res_id		cld_resid;
+	struct lustre_handle		cld_lockh;
 	struct config_llog_instance	cld_cfg;
 	struct list_head		cld_list_chain; /* on config_llog_list */
 	atomic_t			cld_refcount;
diff --git a/fs/lustre/ldlm/ldlm_lock.c b/fs/lustre/ldlm/ldlm_lock.c
index 62d2c1d..2471e30 100644
--- a/fs/lustre/ldlm/ldlm_lock.c
+++ b/fs/lustre/ldlm/ldlm_lock.c
@@ -512,6 +512,9 @@ struct ldlm_lock *__ldlm_handle2lock(const struct lustre_handle *handle,
 
 	LASSERT(handle);
 
+	if (!lustre_handle_is_used(handle))
+		return NULL;
+
 	lock = class_handle2object(handle->cookie, &lock_handle_ops);
 	if (!lock)
 		return NULL;
diff --git a/fs/lustre/mgc/mgc_request.c b/fs/lustre/mgc/mgc_request.c
index 28064fd..b2c296e 100644
--- a/fs/lustre/mgc/mgc_request.c
+++ b/fs/lustre/mgc/mgc_request.c
@@ -122,7 +122,7 @@ static int mgc_logname2resid(char *logname, struct ldlm_res_id *res_id,
 static int config_log_get(struct config_llog_data *cld)
 {
 	atomic_inc(&cld->cld_refcount);
-	CDEBUG(D_INFO, "log %s refs %d\n", cld->cld_logname,
+	CDEBUG(D_INFO, "log %s (%p) refs %d\n", cld->cld_logname, cld,
 	       atomic_read(&cld->cld_refcount));
 	return 0;
 }
@@ -135,7 +135,7 @@ static void config_log_put(struct config_llog_data *cld)
 	if (!cld)
 		return;
 
-	CDEBUG(D_INFO, "log %s refs %d\n", cld->cld_logname,
+	CDEBUG(D_INFO, "log %s(%p) refs %d\n", cld->cld_logname, cld,
 	       atomic_read(&cld->cld_refcount));
 	LASSERT(atomic_read(&cld->cld_refcount) > 0);
 
@@ -379,16 +379,26 @@ struct config_llog_data *do_config_log_add(struct obd_device *obd,
 	return ERR_PTR(rc);
 }
 
-static inline void config_mark_cld_stop(struct config_llog_data *cld)
-{
-	if (!cld)
-		return;
+DEFINE_MUTEX(llog_process_lock);
 
-	mutex_lock(&cld->cld_lock);
+static inline void config_mark_cld_stop_nolock(struct config_llog_data *cld)
+{
 	spin_lock(&config_list_lock);
 	cld->cld_stopping = 1;
 	spin_unlock(&config_list_lock);
-	mutex_unlock(&cld->cld_lock);
+
+	CDEBUG(D_INFO, "lockh %#llx\n", cld->cld_lockh.cookie);
+	if (!ldlm_lock_addref_try(&cld->cld_lockh, LCK_CR))
+		ldlm_lock_decref_and_cancel(&cld->cld_lockh, LCK_CR);
+}
+
+static inline void config_mark_cld_stop(struct config_llog_data *cld)
+{
+	if (cld) {
+		mutex_lock(&cld->cld_lock);
+		config_mark_cld_stop_nolock(cld);
+		mutex_unlock(&cld->cld_lock);
+	}
 }
 
 /** Stop watching for updates on this log.
@@ -420,10 +430,6 @@ static int config_log_end(char *logname, struct config_llog_instance *cfg)
 		return rc;
 	}
 
-	spin_lock(&config_list_lock);
-	cld->cld_stopping = 1;
-	spin_unlock(&config_list_lock);
-
 	cld_recover = cld->cld_recover;
 	cld->cld_recover = NULL;
 
@@ -431,21 +437,22 @@ static int config_log_end(char *logname, struct config_llog_instance *cfg)
 	cld->cld_params = NULL;
 	cld_sptlrpc = cld->cld_sptlrpc;
 	cld->cld_sptlrpc = NULL;
+
+	config_mark_cld_stop_nolock(cld);
 	mutex_unlock(&cld->cld_lock);
 
 	config_mark_cld_stop(cld_recover);
-	config_log_put(cld_recover);
-
 	config_mark_cld_stop(cld_params);
-	config_log_put(cld_params);
+	config_mark_cld_stop(cld_sptlrpc);
 
+	config_log_put(cld_params);
+	config_log_put(cld_recover);
 	config_log_put(cld_sptlrpc);
 
 	/* drop the ref from the find */
 	config_log_put(cld);
 	/* drop the start ref */
 	config_log_put(cld);
-
 	CDEBUG(D_MGC, "end config log %s (%d)\n", logname ? logname : "client",
 	       rc);
 	return rc;
@@ -627,9 +634,14 @@ static void mgc_requeue_add(struct config_llog_data *cld)
 	       cld->cld_stopping, rq_state);
 	LASSERT(atomic_read(&cld->cld_refcount) > 0);
 
+	/* lets cancel an existent lock to mark cld as "lostlock" */
+	CDEBUG(D_INFO, "lockh %#llx\n", cld->cld_lockh.cookie);
+	if (!ldlm_lock_addref_try(&cld->cld_lockh, LCK_CR))
+		ldlm_lock_decref_and_cancel(&cld->cld_lockh, LCK_CR);
+
 	mutex_lock(&cld->cld_lock);
 	spin_lock(&config_list_lock);
-	if (!(rq_state & RQ_STOP) && !cld->cld_stopping && !cld->cld_lostlock) {
+	if (!(rq_state & RQ_STOP) && !cld->cld_stopping) {
 		cld->cld_lostlock = 1;
 		rq_state |= RQ_NOW;
 		wakeup = true;
@@ -803,6 +815,7 @@ static int mgc_blocking_ast(struct ldlm_lock *lock, struct ldlm_lock_desc *desc,
 		LASSERT(atomic_read(&cld->cld_refcount) > 0);
 
 		lock->l_ast_data = NULL;
+		cld->cld_lockh.cookie = 0;
 		/* Are we done with this log? */
 		if (cld->cld_stopping) {
 			CDEBUG(D_MGC, "log %s: stopping, won't requeue\n",
@@ -1616,9 +1629,12 @@ int mgc_process_log(struct obd_device *mgc, struct config_llog_data *cld)
 		/* Get the cld, it will be released in mgc_blocking_ast. */
 		config_log_get(cld);
 		rc = ldlm_lock_set_data(&lockh, (void *)cld);
+		LASSERT(!lustre_handle_is_used(&cld->cld_lockh));
 		LASSERT(rc == 0);
+		cld->cld_lockh = lockh;
 	} else {
 		CDEBUG(D_MGC, "Can't get cfg lock: %d\n", rcl);
+		cld->cld_lockh.cookie = 0;
 
 		if (rcl == -ESHUTDOWN &&
 		    atomic_read(&mgc->u.cli.cl_mgc_refcount) > 0 && !retry) {
@@ -1673,9 +1689,6 @@ int mgc_process_log(struct obd_device *mgc, struct config_llog_data *cld)
 				CERROR("%s: recover log %s failed: rc = %d not fatal.\n",
 				       mgc->obd_name, cld->cld_logname, rc);
 				rc = 0;
-				spin_lock(&config_list_lock);
-				cld->cld_lostlock = 1;
-				spin_unlock(&config_list_lock);
 			}
 		}
 	} else {
@@ -1685,12 +1698,12 @@ int mgc_process_log(struct obd_device *mgc, struct config_llog_data *cld)
 	CDEBUG(D_MGC, "%s: configuration from log '%s' %sed (%d).\n",
 	       mgc->obd_name, cld->cld_logname, rc ? "fail" : "succeed", rc);
 
-	mutex_unlock(&cld->cld_lock);
-
 	/* Now drop the lock so MGS can revoke it */
 	if (!rcl)
 		ldlm_lock_decref(&lockh, LCK_CR);
 
+	mutex_unlock(&cld->cld_lock);
+
 	return rc;
 }
 
-- 
1.8.3.1
