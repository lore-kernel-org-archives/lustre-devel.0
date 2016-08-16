From: James Simmons <jsimmons@infradead.org>
Date: Tue, 16 Aug 2016 16:18:48 -0400
Subject: [lustre-devel] [PATCH 35/80] staging: lustre: obdclass: unified
	flow control interfaces
In-Reply-To: <1471378773-24590-1-git-send-email-jsimmons@infradead.org>
References: <1471378773-24590-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1471378773-24590-36-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Fan Yong <fan.yong@intel.com>, James Simmons <jsimmons@infradead.org>

From: Fan Yong <fan.yong@intel.com>

Unify the flow control interfaces for MDC RPC and FLD RPC.
We allow to adjust the maximum inflight RPCs count via /sys
interface.

Signed-off-by: Fan Yong <fan.yong@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-4687
Reviewed-on: http://review.whamcloud.com/9562
Reviewed-by: Niu Yawei <yawei.niu@intel.com>
Reviewed-by: Alex Zhuravlev <alexey.zhuravlev@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/fld/fld_request.c    |   55 +--------
 drivers/staging/lustre/lustre/include/lustre_mdc.h |    5 -
 drivers/staging/lustre/lustre/include/obd.h        |   14 +--
 drivers/staging/lustre/lustre/include/obd_class.h  |    5 +
 drivers/staging/lustre/lustre/ldlm/ldlm_lib.c      |    4 +-
 drivers/staging/lustre/lustre/mdc/lproc_mdc.c      |   17 +--
 drivers/staging/lustre/lustre/mdc/mdc_internal.h   |    2 -
 drivers/staging/lustre/lustre/mdc/mdc_lib.c        |   64 ----------
 drivers/staging/lustre/lustre/mdc/mdc_locks.c      |   10 +-
 drivers/staging/lustre/lustre/mdc/mdc_request.c    |    6 +-
 drivers/staging/lustre/lustre/obdclass/genops.c    |  132 ++++++++++++++++++++
 11 files changed, 161 insertions(+), 153 deletions(-)

diff --git a/drivers/staging/lustre/lustre/fld/fld_request.c b/drivers/staging/lustre/lustre/fld/fld_request.c
index e59d626..ed7962e 100644
--- a/drivers/staging/lustre/lustre/fld/fld_request.c
+++ b/drivers/staging/lustre/lustre/fld/fld_request.c
@@ -53,57 +53,6 @@
 #include "../include/lustre_mdc.h"
 #include "fld_internal.h"
 
-/* TODO: these 3 functions are copies of flow-control code from mdc_lib.c
- * It should be common thing. The same about mdc RPC lock
- */
-static int fld_req_avail(struct client_obd *cli, struct mdc_cache_waiter *mcw)
-{
-	int rc;
-
-	spin_lock(&cli->cl_loi_list_lock);
-	rc = list_empty(&mcw->mcw_entry);
-	spin_unlock(&cli->cl_loi_list_lock);
-	return rc;
-};
-
-static void fld_enter_request(struct client_obd *cli)
-{
-	struct mdc_cache_waiter mcw;
-	struct l_wait_info lwi = { 0 };
-
-	spin_lock(&cli->cl_loi_list_lock);
-	if (cli->cl_r_in_flight >= cli->cl_max_rpcs_in_flight) {
-		list_add_tail(&mcw.mcw_entry, &cli->cl_cache_waiters);
-		init_waitqueue_head(&mcw.mcw_waitq);
-		spin_unlock(&cli->cl_loi_list_lock);
-		l_wait_event(mcw.mcw_waitq, fld_req_avail(cli, &mcw), &lwi);
-	} else {
-		cli->cl_r_in_flight++;
-		spin_unlock(&cli->cl_loi_list_lock);
-	}
-}
-
-static void fld_exit_request(struct client_obd *cli)
-{
-	struct list_head *l, *tmp;
-	struct mdc_cache_waiter *mcw;
-
-	spin_lock(&cli->cl_loi_list_lock);
-	cli->cl_r_in_flight--;
-	list_for_each_safe(l, tmp, &cli->cl_cache_waiters) {
-		if (cli->cl_r_in_flight >= cli->cl_max_rpcs_in_flight) {
-			/* No free request slots anymore */
-			break;
-		}
-
-		mcw = list_entry(l, struct mdc_cache_waiter, mcw_entry);
-		list_del_init(&mcw->mcw_entry);
-		cli->cl_r_in_flight++;
-		wake_up(&mcw->mcw_waitq);
-	}
-	spin_unlock(&cli->cl_loi_list_lock);
-}
-
 static int fld_rrb_hash(struct lu_client_fld *fld, u64 seq)
 {
 	LASSERT(fld->lcf_count > 0);
@@ -439,9 +388,9 @@ int fld_client_rpc(struct obd_export *exp,
 	req->rq_reply_portal = MDC_REPLY_PORTAL;
 	ptlrpc_at_set_req_timeout(req);
 
-	fld_enter_request(&exp->exp_obd->u.cli);
+	obd_get_request_slot(&exp->exp_obd->u.cli);
 	rc = ptlrpc_queue_wait(req);
-	fld_exit_request(&exp->exp_obd->u.cli);
+	obd_put_request_slot(&exp->exp_obd->u.cli);
 	if (rc)
 		goto out_req;
 
diff --git a/drivers/staging/lustre/lustre/include/lustre_mdc.h b/drivers/staging/lustre/lustre/include/lustre_mdc.h
index 0a8c639..bf6f87a 100644
--- a/drivers/staging/lustre/lustre/include/lustre_mdc.h
+++ b/drivers/staging/lustre/lustre/include/lustre_mdc.h
@@ -179,11 +179,6 @@ static inline void mdc_update_max_ea_from_body(struct obd_export *exp,
 	}
 }
 
-struct mdc_cache_waiter {
-	struct list_head	      mcw_entry;
-	wait_queue_head_t	     mcw_waitq;
-};
-
 /* mdc/mdc_locks.c */
 int it_open_error(int phase, struct lookup_intent *it);
 
diff --git a/drivers/staging/lustre/lustre/include/obd.h b/drivers/staging/lustre/lustre/include/obd.h
index f5eeb05..cacd472 100644
--- a/drivers/staging/lustre/lustre/include/obd.h
+++ b/drivers/staging/lustre/lustre/include/obd.h
@@ -211,11 +211,12 @@ struct timeout_item {
 	struct list_head	 ti_chain;
 };
 
-#define OSC_MAX_RIF_DEFAULT       8
-#define OSC_MAX_RIF_MAX	 256
-#define OSC_MAX_DIRTY_DEFAULT  (OSC_MAX_RIF_DEFAULT * 4)
-#define OSC_MAX_DIRTY_MB_MAX   2048     /* arbitrary, but < MAX_LONG bytes */
-#define OSC_DEFAULT_RESENDS      10
+#define OBD_MAX_RIF_DEFAULT	8
+#define OBD_MAX_RIF_MAX		512
+#define OSC_MAX_RIF_MAX		256
+#define OSC_MAX_DIRTY_DEFAULT	(OBD_MAX_RIF_DEFAULT * 4)
+#define OSC_MAX_DIRTY_MB_MAX	2048	/* arbitrary, but < MAX_LONG bytes */
+#define OSC_DEFAULT_RESENDS	10
 
 /* possible values for fo_sync_lock_cancel */
 enum {
@@ -225,9 +226,6 @@ enum {
 	NUM_SYNC_ON_CANCEL_STATES
 };
 
-#define MDC_MAX_RIF_DEFAULT       8
-#define MDC_MAX_RIF_MAX	 512
-
 enum obd_cl_sem_lock_class {
 	OBD_CLI_SEM_NORMAL,
 	OBD_CLI_SEM_MGC,
diff --git a/drivers/staging/lustre/lustre/include/obd_class.h b/drivers/staging/lustre/lustre/include/obd_class.h
index 2f111a8..de808ee 100644
--- a/drivers/staging/lustre/lustre/include/obd_class.h
+++ b/drivers/staging/lustre/lustre/include/obd_class.h
@@ -97,6 +97,11 @@ int obd_zombie_impexp_init(void);
 void obd_zombie_impexp_stop(void);
 void obd_zombie_barrier(void);
 
+int obd_get_request_slot(struct client_obd *cli);
+void obd_put_request_slot(struct client_obd *cli);
+__u32 obd_get_max_rpcs_in_flight(struct client_obd *cli);
+int obd_set_max_rpcs_in_flight(struct client_obd *cli, __u32 max);
+
 struct llog_handle;
 struct llog_rec_hdr;
 typedef int (*llog_cb_t)(const struct lu_env *, struct llog_handle *,
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c
index 7c832aa..ee40006 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c
@@ -360,7 +360,7 @@ int client_obd_setup(struct obd_device *obddev, struct lustre_cfg *lcfg)
 	cli->cl_chunkbits = PAGE_SHIFT;
 
 	if (!strcmp(name, LUSTRE_MDC_NAME)) {
-		cli->cl_max_rpcs_in_flight = MDC_MAX_RIF_DEFAULT;
+		cli->cl_max_rpcs_in_flight = OBD_MAX_RIF_DEFAULT;
 	} else if (totalram_pages >> (20 - PAGE_SHIFT) <= 128 /* MB */) {
 		cli->cl_max_rpcs_in_flight = 2;
 	} else if (totalram_pages >> (20 - PAGE_SHIFT) <= 256 /* MB */) {
@@ -368,7 +368,7 @@ int client_obd_setup(struct obd_device *obddev, struct lustre_cfg *lcfg)
 	} else if (totalram_pages >> (20 - PAGE_SHIFT) <= 512 /* MB */) {
 		cli->cl_max_rpcs_in_flight = 4;
 	} else {
-		cli->cl_max_rpcs_in_flight = OSC_MAX_RIF_DEFAULT;
+		cli->cl_max_rpcs_in_flight = OBD_MAX_RIF_DEFAULT;
 	}
 	rc = ldlm_get_ref();
 	if (rc) {
diff --git a/drivers/staging/lustre/lustre/mdc/lproc_mdc.c b/drivers/staging/lustre/lustre/mdc/lproc_mdc.c
index 98d15fb..fca9450 100644
--- a/drivers/staging/lustre/lustre/mdc/lproc_mdc.c
+++ b/drivers/staging/lustre/lustre/mdc/lproc_mdc.c
@@ -43,11 +43,10 @@ static ssize_t max_rpcs_in_flight_show(struct kobject *kobj,
 	int len;
 	struct obd_device *dev = container_of(kobj, struct obd_device,
 					      obd_kobj);
-	struct client_obd *cli = &dev->u.cli;
+	__u32 max;
 
-	spin_lock(&cli->cl_loi_list_lock);
-	len = sprintf(buf, "%u\n", cli->cl_max_rpcs_in_flight);
-	spin_unlock(&cli->cl_loi_list_lock);
+	max = obd_get_max_rpcs_in_flight(&dev->u.cli);
+	len = sprintf(buf, "%u\n", max);
 
 	return len;
 }
@@ -59,7 +58,6 @@ static ssize_t max_rpcs_in_flight_store(struct kobject *kobj,
 {
 	struct obd_device *dev = container_of(kobj, struct obd_device,
 					      obd_kobj);
-	struct client_obd *cli = &dev->u.cli;
 	int rc;
 	unsigned long val;
 
@@ -67,12 +65,9 @@ static ssize_t max_rpcs_in_flight_store(struct kobject *kobj,
 	if (rc)
 		return rc;
 
-	if (val < 1 || val > MDC_MAX_RIF_MAX)
-		return -ERANGE;
-
-	spin_lock(&cli->cl_loi_list_lock);
-	cli->cl_max_rpcs_in_flight = val;
-	spin_unlock(&cli->cl_loi_list_lock);
+	rc = obd_set_max_rpcs_in_flight(&dev->u.cli, val);
+	if (rc)
+		count = rc;
 
 	return count;
 }
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_internal.h b/drivers/staging/lustre/lustre/mdc/mdc_internal.h
index 58f2841..53b4063 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_internal.h
+++ b/drivers/staging/lustre/lustre/mdc/mdc_internal.h
@@ -61,8 +61,6 @@ void mdc_link_pack(struct ptlrpc_request *req, struct md_op_data *op_data);
 void mdc_rename_pack(struct ptlrpc_request *req, struct md_op_data *op_data,
 		     const char *old, int oldlen, const char *new, int newlen);
 void mdc_close_pack(struct ptlrpc_request *req, struct md_op_data *op_data);
-int mdc_enter_request(struct client_obd *cli);
-void mdc_exit_request(struct client_obd *cli);
 
 /* mdc/mdc_locks.c */
 int mdc_set_lock_data(struct obd_export *exp,
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_lib.c b/drivers/staging/lustre/lustre/mdc/mdc_lib.c
index 95c4550..b532623 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_lib.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_lib.c
@@ -484,67 +484,3 @@ void mdc_close_pack(struct ptlrpc_request *req, struct md_op_data *op_data)
 	mdc_ioepoch_pack(epoch, op_data);
 	mdc_hsm_release_pack(req, op_data);
 }
-
-static int mdc_req_avail(struct client_obd *cli, struct mdc_cache_waiter *mcw)
-{
-	int rc;
-
-	spin_lock(&cli->cl_loi_list_lock);
-	rc = list_empty(&mcw->mcw_entry);
-	spin_unlock(&cli->cl_loi_list_lock);
-	return rc;
-};
-
-/* We record requests in flight in cli->cl_r_in_flight here.
- * There is only one write rpc possible in mdc anyway. If this to change
- * in the future - the code may need to be revisited.
- */
-int mdc_enter_request(struct client_obd *cli)
-{
-	int rc = 0;
-	struct mdc_cache_waiter mcw;
-	struct l_wait_info lwi = LWI_INTR(LWI_ON_SIGNAL_NOOP, NULL);
-
-	spin_lock(&cli->cl_loi_list_lock);
-	if (cli->cl_r_in_flight >= cli->cl_max_rpcs_in_flight) {
-		list_add_tail(&mcw.mcw_entry, &cli->cl_cache_waiters);
-		init_waitqueue_head(&mcw.mcw_waitq);
-		spin_unlock(&cli->cl_loi_list_lock);
-		rc = l_wait_event(mcw.mcw_waitq, mdc_req_avail(cli, &mcw),
-				  &lwi);
-		if (rc) {
-			spin_lock(&cli->cl_loi_list_lock);
-			if (list_empty(&mcw.mcw_entry))
-				cli->cl_r_in_flight--;
-			list_del_init(&mcw.mcw_entry);
-			spin_unlock(&cli->cl_loi_list_lock);
-		}
-	} else {
-		cli->cl_r_in_flight++;
-		spin_unlock(&cli->cl_loi_list_lock);
-	}
-	return rc;
-}
-
-void mdc_exit_request(struct client_obd *cli)
-{
-	struct list_head *l, *tmp;
-	struct mdc_cache_waiter *mcw;
-
-	spin_lock(&cli->cl_loi_list_lock);
-	cli->cl_r_in_flight--;
-	list_for_each_safe(l, tmp, &cli->cl_cache_waiters) {
-		if (cli->cl_r_in_flight >= cli->cl_max_rpcs_in_flight) {
-			/* No free request slots anymore */
-			break;
-		}
-
-		mcw = list_entry(l, struct mdc_cache_waiter, mcw_entry);
-		list_del_init(&mcw->mcw_entry);
-		cli->cl_r_in_flight++;
-		wake_up(&mcw->mcw_waitq);
-	}
-	/* Empty waiting list? Decrease reqs in-flight number */
-
-	spin_unlock(&cli->cl_loi_list_lock);
-}
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_locks.c b/drivers/staging/lustre/lustre/mdc/mdc_locks.c
index 626fce5..d8406d5 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_locks.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_locks.c
@@ -809,7 +809,7 @@ resend:
 	 */
 	if (it) {
 		mdc_get_rpc_lock(obddev->u.cli.cl_rpc_lock, it);
-		rc = mdc_enter_request(&obddev->u.cli);
+		rc = obd_get_request_slot(&obddev->u.cli);
 		if (rc != 0) {
 			mdc_put_rpc_lock(obddev->u.cli.cl_rpc_lock, it);
 			mdc_clear_replay_flag(req, 0);
@@ -837,7 +837,7 @@ resend:
 		return rc;
 	}
 
-	mdc_exit_request(&obddev->u.cli);
+	obd_put_request_slot(&obddev->u.cli);
 	mdc_put_rpc_lock(obddev->u.cli.cl_rpc_lock, it);
 
 	if (rc < 0) {
@@ -1179,7 +1179,7 @@ static int mdc_intent_getattr_async_interpret(const struct lu_env *env,
 
 	obddev = class_exp2obd(exp);
 
-	mdc_exit_request(&obddev->u.cli);
+	obd_put_request_slot(&obddev->u.cli);
 	if (OBD_FAIL_CHECK(OBD_FAIL_MDC_GETATTR_ENQUEUE))
 		rc = -ETIMEDOUT;
 
@@ -1239,7 +1239,7 @@ int mdc_intent_getattr_async(struct obd_export *exp,
 	if (IS_ERR(req))
 		return PTR_ERR(req);
 
-	rc = mdc_enter_request(&obddev->u.cli);
+	rc = obd_get_request_slot(&obddev->u.cli);
 	if (rc != 0) {
 		ptlrpc_req_finished(req);
 		return rc;
@@ -1248,7 +1248,7 @@ int mdc_intent_getattr_async(struct obd_export *exp,
 	rc = ldlm_cli_enqueue(exp, &req, einfo, &res_id, &policy, &flags, NULL,
 			      0, LVB_T_NONE, &minfo->mi_lockh, 1);
 	if (rc < 0) {
-		mdc_exit_request(&obddev->u.cli);
+		obd_put_request_slot(&obddev->u.cli);
 		ptlrpc_req_finished(req);
 		return rc;
 	}
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_request.c b/drivers/staging/lustre/lustre/mdc/mdc_request.c
index 030295f..558f33b 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_request.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_request.c
@@ -58,16 +58,16 @@ static inline int mdc_queue_wait(struct ptlrpc_request *req)
 	struct client_obd *cli = &req->rq_import->imp_obd->u.cli;
 	int rc;
 
-	/* mdc_enter_request() ensures that this client has no more
+	/* obd_get_request_slot() ensures that this client has no more
 	 * than cl_max_rpcs_in_flight RPCs simultaneously inf light
 	 * against an MDT.
 	 */
-	rc = mdc_enter_request(cli);
+	rc = obd_get_request_slot(cli);
 	if (rc != 0)
 		return rc;
 
 	rc = ptlrpc_queue_wait(req);
-	mdc_exit_request(cli);
+	obd_put_request_slot(cli);
 
 	return rc;
 }
diff --git a/drivers/staging/lustre/lustre/obdclass/genops.c b/drivers/staging/lustre/lustre/obdclass/genops.c
index 99c2da6..be25434 100644
--- a/drivers/staging/lustre/lustre/obdclass/genops.c
+++ b/drivers/staging/lustre/lustre/obdclass/genops.c
@@ -1312,3 +1312,135 @@ void obd_zombie_impexp_stop(void)
 	obd_zombie_impexp_notify();
 	wait_for_completion(&obd_zombie_stop);
 }
+
+struct obd_request_slot_waiter {
+	struct list_head	orsw_entry;
+	wait_queue_head_t	orsw_waitq;
+	bool			orsw_signaled;
+};
+
+static bool obd_request_slot_avail(struct client_obd *cli,
+				   struct obd_request_slot_waiter *orsw)
+{
+	bool avail;
+
+	spin_lock(&cli->cl_loi_list_lock);
+	avail = !!list_empty(&orsw->orsw_entry);
+	spin_unlock(&cli->cl_loi_list_lock);
+
+	return avail;
+};
+
+/*
+ * For network flow control, the RPC sponsor needs to acquire a credit
+ * before sending the RPC. The credits count for a connection is defined
+ * by the "cl_max_rpcs_in_flight". If all the credits are occpuied, then
+ * the subsequent RPC sponsors need to wait until others released their
+ * credits, or the administrator increased the "cl_max_rpcs_in_flight".
+ */
+int obd_get_request_slot(struct client_obd *cli)
+{
+	struct obd_request_slot_waiter orsw;
+	struct l_wait_info lwi;
+	int rc;
+
+	spin_lock(&cli->cl_loi_list_lock);
+	if (cli->cl_r_in_flight < cli->cl_max_rpcs_in_flight) {
+		cli->cl_r_in_flight++;
+		spin_unlock(&cli->cl_loi_list_lock);
+		return 0;
+	}
+
+	init_waitqueue_head(&orsw.orsw_waitq);
+	list_add_tail(&orsw.orsw_entry, &cli->cl_loi_read_list);
+	orsw.orsw_signaled = false;
+	spin_unlock(&cli->cl_loi_list_lock);
+
+	lwi = LWI_INTR(LWI_ON_SIGNAL_NOOP, NULL);
+	rc = l_wait_event(orsw.orsw_waitq,
+			  obd_request_slot_avail(cli, &orsw) ||
+			  orsw.orsw_signaled,
+			  &lwi);
+
+	/*
+	 * Here, we must take the lock to avoid the on-stack 'orsw' to be
+	 * freed but other (such as obd_put_request_slot) is using it.
+	 */
+	spin_lock(&cli->cl_loi_list_lock);
+	if (rc) {
+		if (!orsw.orsw_signaled) {
+			if (list_empty(&orsw.orsw_entry))
+				cli->cl_r_in_flight--;
+			else
+				list_del(&orsw.orsw_entry);
+		}
+	}
+
+	if (orsw.orsw_signaled) {
+		LASSERT(list_empty(&orsw.orsw_entry));
+
+		rc = -EINTR;
+	}
+	spin_unlock(&cli->cl_loi_list_lock);
+
+	return rc;
+}
+EXPORT_SYMBOL(obd_get_request_slot);
+
+void obd_put_request_slot(struct client_obd *cli)
+{
+	struct obd_request_slot_waiter *orsw;
+
+	spin_lock(&cli->cl_loi_list_lock);
+	cli->cl_r_in_flight--;
+
+	/* If there is free slot, wakeup the first waiter. */
+	if (!list_empty(&cli->cl_loi_read_list) &&
+	    likely(cli->cl_r_in_flight < cli->cl_max_rpcs_in_flight)) {
+		orsw = list_entry(cli->cl_loi_read_list.next,
+				  struct obd_request_slot_waiter, orsw_entry);
+		list_del_init(&orsw->orsw_entry);
+		cli->cl_r_in_flight++;
+		wake_up(&orsw->orsw_waitq);
+	}
+	spin_unlock(&cli->cl_loi_list_lock);
+}
+EXPORT_SYMBOL(obd_put_request_slot);
+
+__u32 obd_get_max_rpcs_in_flight(struct client_obd *cli)
+{
+	return cli->cl_max_rpcs_in_flight;
+}
+EXPORT_SYMBOL(obd_get_max_rpcs_in_flight);
+
+int obd_set_max_rpcs_in_flight(struct client_obd *cli, __u32 max)
+{
+	struct obd_request_slot_waiter *orsw;
+	__u32 old;
+	int diff;
+	int i;
+
+	if (max > OBD_MAX_RIF_MAX || max < 1)
+		return -ERANGE;
+
+	spin_lock(&cli->cl_loi_list_lock);
+	old = cli->cl_max_rpcs_in_flight;
+	cli->cl_max_rpcs_in_flight = max;
+	diff = max - old;
+
+	/* We increase the max_rpcs_in_flight, then wakeup some waiters. */
+	for (i = 0; i < diff; i++) {
+		if (list_empty(&cli->cl_loi_read_list))
+			break;
+
+		orsw = list_entry(cli->cl_loi_read_list.next,
+				  struct obd_request_slot_waiter, orsw_entry);
+		list_del_init(&orsw->orsw_entry);
+		cli->cl_r_in_flight++;
+		wake_up(&orsw->orsw_waitq);
+	}
+	spin_unlock(&cli->cl_loi_list_lock);
+
+	return 0;
+}
+EXPORT_SYMBOL(obd_set_max_rpcs_in_flight);
-- 
1.7.1
