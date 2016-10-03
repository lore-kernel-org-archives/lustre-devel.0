From: James Simmons <jsimmons@infradead.org>
Date: Sun,  2 Oct 2016 22:28:19 -0400
Subject: [lustre-devel] [PATCH 23/41] staging: lustre: mgc: MGC should retry
	for invalid import
In-Reply-To: <1475461717-21631-1-git-send-email-jsimmons@infradead.org>
References: <1475461717-21631-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1475461717-21631-24-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, wang di <di.wang@intel.com>, James Simmons <jsimmons@infradead.org>

From: wang di <di.wang@intel.com>

After http://review.whamcloud.com/#/c/9967/ is landed, mgc does
not wait the import connected(state = FULL), then enqueue and
retrieve config log, which will cause the mount process to fail,
especially if the mgc is shared by multiple targets.
So once mgc enqueue is failed, it will give another chance to
wait the import to recover, if the import comes back in time,
it will try to enqueue again. Otherwise it will use local config log.

Signed-off-by: wang di <di.wang@intel.com>
Signed-off-by: Andreas Dilger <andreas.dilger@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5420
Reviewed-on: http://review.whamcloud.com/11258
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/lustre_ha.h |    1 +
 drivers/staging/lustre/lustre/mgc/mgc_request.c   |   85 +++++++++++++++++++--
 drivers/staging/lustre/lustre/ptlrpc/import.c     |    3 +-
 3 files changed, 81 insertions(+), 8 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_ha.h b/drivers/staging/lustre/lustre/include/lustre_ha.h
index cde7ed7..dec1e99 100644
--- a/drivers/staging/lustre/lustre/include/lustre_ha.h
+++ b/drivers/staging/lustre/lustre/include/lustre_ha.h
@@ -53,6 +53,7 @@ void ptlrpc_activate_import(struct obd_import *imp);
 void ptlrpc_deactivate_import(struct obd_import *imp);
 void ptlrpc_invalidate_import(struct obd_import *imp);
 void ptlrpc_fail_import(struct obd_import *imp, __u32 conn_cnt);
+void ptlrpc_pinger_force(struct obd_import *imp);
 
 /** @} ha */
 
diff --git a/drivers/staging/lustre/lustre/mgc/mgc_request.c b/drivers/staging/lustre/lustre/mgc/mgc_request.c
index 1a0e59a..7b5ac44 100644
--- a/drivers/staging/lustre/lustre/mgc/mgc_request.c
+++ b/drivers/staging/lustre/lustre/mgc/mgc_request.c
@@ -1552,14 +1552,52 @@ out_free:
 	return rc;
 }
 
-/** Get a config log from the MGS and process it.
- * This func is called for both clients and servers.
- * Copy the log locally before parsing it if appropriate (non-MGS server)
+static bool mgc_import_in_recovery(struct obd_import *imp)
+{
+	bool in_recovery = true;
+
+	spin_lock(&imp->imp_lock);
+	if (imp->imp_state == LUSTRE_IMP_FULL ||
+	    imp->imp_state == LUSTRE_IMP_CLOSED)
+		in_recovery = false;
+	spin_unlock(&imp->imp_lock);
+
+	return in_recovery;
+}
+
+/**
+ * Get a configuration log from the MGS and process it.
+ *
+ * This function is called for both clients and servers to process the
+ * configuration log from the MGS.  The MGC enqueues a DLM lock on the
+ * log from the MGS, and if the lock gets revoked the MGC will be notified
+ * by the lock cancellation callback that the config log has changed,
+ * and will enqueue another MGS lock on it, and then continue processing
+ * the new additions to the end of the log.
+ *
+ * Since the MGC import is not replayable, if the import is being evicted
+ * (rcl == -ESHUTDOWN, \see ptlrpc_import_delay_req()), retry to process
+ * the log until recovery is finished or the import is closed.
+ *
+ * Make a local copy of the log before parsing it if appropriate (non-MGS
+ * server) so that the server can start even when the MGS is down.
+ *
+ * There shouldn't be multiple processes running process_log at once --
+ * sounds like badness.  It actually might be fine, as long as they're not
+ * trying to update from the same log simultaneously, in which case we
+ * should use a per-log semaphore instead of cld_lock.
+ *
+ * \param[in] mgc	MGC device by which to fetch the configuration log
+ * \param[in] cld	log processing state (stored in lock callback data)
+ *
+ * \retval		0 on success
+ * \retval		negative errno on failure
  */
 int mgc_process_log(struct obd_device *mgc, struct config_llog_data *cld)
 {
 	struct lustre_handle lockh = { 0 };
 	__u64 flags = LDLM_FL_NO_LRU;
+	bool retry = false;
 	int rc = 0, rcl;
 
 	LASSERT(cld);
@@ -1569,6 +1607,7 @@ int mgc_process_log(struct obd_device *mgc, struct config_llog_data *cld)
 	 * we're not trying to update from the same log
 	 * simultaneously (in which case we should use a per-log sem.)
 	 */
+restart:
 	mutex_lock(&cld->cld_lock);
 	if (cld->cld_stopping) {
 		mutex_unlock(&cld->cld_lock);
@@ -1592,10 +1631,42 @@ int mgc_process_log(struct obd_device *mgc, struct config_llog_data *cld)
 	} else {
 		CDEBUG(D_MGC, "Can't get cfg lock: %d\n", rcl);
 
-		/* mark cld_lostlock so that it will requeue
-		 * after MGC becomes available.
-		 */
-		cld->cld_lostlock = 1;
+		if (rcl == -ESHUTDOWN &&
+		    atomic_read(&mgc->u.cli.cl_mgc_refcount) > 0 && !retry) {
+			int secs = cfs_time_seconds(obd_timeout);
+			struct obd_import *imp;
+			struct l_wait_info lwi;
+
+			mutex_unlock(&cld->cld_lock);
+			imp = class_exp2cliimp(mgc->u.cli.cl_mgc_mgsexp);
+
+			/*
+			 * Let's force the pinger, and wait the import to be
+			 * connected, note: since mgc import is non-replayable,
+			 * and even the import state is disconnected, it does
+			 * not mean the "recovery" is stopped, so we will keep
+			 * waitting until timeout or the import state is
+			 * FULL or closed
+			 */
+			ptlrpc_pinger_force(imp);
+
+			lwi = LWI_TIMEOUT(secs, NULL, NULL);
+			l_wait_event(imp->imp_recovery_waitq,
+				     !mgc_import_in_recovery(imp), &lwi);
+
+			if (imp->imp_state == LUSTRE_IMP_FULL) {
+				retry = true;
+				goto restart;
+			} else {
+				mutex_lock(&cld->cld_lock);
+				cld->cld_lostlock = 1;
+			}
+		} else {
+			/* mark cld_lostlock so that it will requeue
+			 * after MGC becomes available.
+			 */
+			cld->cld_lostlock = 1;
+		}
 		/* Get extra reference, it will be put in requeue thread */
 		config_log_get(cld);
 	}
diff --git a/drivers/staging/lustre/lustre/ptlrpc/import.c b/drivers/staging/lustre/lustre/ptlrpc/import.c
index b245784..2bdaf2b 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/import.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/import.c
@@ -396,7 +396,7 @@ void ptlrpc_activate_import(struct obd_import *imp)
 }
 EXPORT_SYMBOL(ptlrpc_activate_import);
 
-static void ptlrpc_pinger_force(struct obd_import *imp)
+void ptlrpc_pinger_force(struct obd_import *imp)
 {
 	CDEBUG(D_HA, "%s: waking up pinger s:%s\n", obd2cli_tgt(imp->imp_obd),
 	       ptlrpc_import_state_name(imp->imp_state));
@@ -408,6 +408,7 @@ static void ptlrpc_pinger_force(struct obd_import *imp)
 	if (imp->imp_state != LUSTRE_IMP_CONNECTING)
 		ptlrpc_pinger_wake_up();
 }
+EXPORT_SYMBOL(ptlrpc_pinger_force);
 
 void ptlrpc_fail_import(struct obd_import *imp, __u32 conn_cnt)
 {
-- 
1.7.1
