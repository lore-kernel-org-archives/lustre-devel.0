From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:08:40 -0500
Subject: [lustre-devel] [PATCH 052/622] lustre: ptlrpc: idle connections can
 disconnect
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-53-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Alex Zhuravlev <bzzz@whamcloud.com>

 - when new request is being allocated ptlrpc initiates
   connection if it's not connected yet
 - if the import is idle (no locks, no active RPCs, no
   non-PING reply for last osc_idle_timeout seconds),
   then pinger tries to disconnect asynchronously
 - currently only client-to-OST connections can be idle
 - lctl set_param osc.*.idle_timeout=N controls new feature:
   N=0 - disable
   N>0 - seconds to idle before disconnect
 - lctl set_param osc.*.idle_connect=N to reconnect if idle
   (N is positive number)
 - OSC module parameter osc_idle_timeout controls default
   idle timeout and set to 20 seconds by default

WC-bug-id: https://jira.whamcloud.com/browse/LU-7236
Lustre-commit: 5a6ceb664f07 ("LU-7236 ptlrpc: idle connections can disconnect")
Signed-off-by: Alex Zhuravlev <bzzz@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/16682
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_import.h |  17 +++--
 fs/lustre/include/lustre_net.h    |   1 +
 fs/lustre/lov/lov_ea.c            |   3 +-
 fs/lustre/lov/lov_obd.c           |   8 ++-
 fs/lustre/lov/lov_request.c       |  25 ++++++--
 fs/lustre/osc/lproc_osc.c         |  66 +++++++++++++++++++
 fs/lustre/osc/osc_request.c       |   3 +
 fs/lustre/ptlrpc/client.c         |  32 +++++++++-
 fs/lustre/ptlrpc/events.c         |   3 +-
 fs/lustre/ptlrpc/import.c         | 130 ++++++++++++++++++++++++++++++--------
 fs/lustre/ptlrpc/pinger.c         |  30 +++++++++
 11 files changed, 275 insertions(+), 43 deletions(-)

diff --git a/fs/lustre/include/lustre_import.h b/fs/lustre/include/lustre_import.h
index 0d7bb0f..c4452e1 100644
--- a/fs/lustre/include/lustre_import.h
+++ b/fs/lustre/include/lustre_import.h
@@ -96,6 +96,8 @@ enum lustre_imp_state {
 	LUSTRE_IMP_RECOVER	= 8,
 	LUSTRE_IMP_FULL		= 9,
 	LUSTRE_IMP_EVICTED	= 10,
+	LUSTRE_IMP_IDLE		= 11,
+	LUSTRE_IMP_LAST
 };
 
 /** Returns test string representation of numeric import state @state */
@@ -104,10 +106,10 @@ static inline char *ptlrpc_import_state_name(enum lustre_imp_state state)
 	static char *import_state_names[] = {
 		"<UNKNOWN>", "CLOSED",  "NEW", "DISCONN",
 		"CONNECTING", "REPLAY", "REPLAY_LOCKS", "REPLAY_WAIT",
-		"RECOVER", "FULL", "EVICTED",
+		"RECOVER", "FULL", "EVICTED", "IDLE",
 	};
 
-	LASSERT(state <= LUSTRE_IMP_EVICTED);
+	LASSERT(state < LUSTRE_IMP_LAST);
 	return import_state_names[state];
 }
 
@@ -226,12 +228,14 @@ struct obd_import {
 	int				imp_state_hist_idx;
 	/** Current import generation. Incremented on every reconnect */
 	int				imp_generation;
+	/* Idle connection initiated@this generation */
+	int				imp_initiated_at;
 	/** Incremented every time we send reconnection request */
 	u32				imp_conn_cnt;
-       /**
-	* \see ptlrpc_free_committed remembers imp_generation value here
-	* after a check to save on unnecessary replay list iterations
-	*/
+	/*
+	 * \see ptlrpc_free_committed remembers imp_generation value here
+	 * after a check to save on unnecessary replay list iterations
+	 */
 	int				imp_last_generation_checked;
 	/** Last transno we replayed */
 	u64				imp_last_replay_transno;
@@ -299,6 +303,7 @@ struct obd_import {
 					imp_connected:1;
 
 	u32				imp_connect_op;
+	u32				imp_idle_timeout;
 	struct obd_connect_data		imp_connect_data;
 	u64				imp_connect_flags_orig;
 	u64				imp_connect_flags2_orig;
diff --git a/fs/lustre/include/lustre_net.h b/fs/lustre/include/lustre_net.h
index 0231011..674803c 100644
--- a/fs/lustre/include/lustre_net.h
+++ b/fs/lustre/include/lustre_net.h
@@ -1988,6 +1988,7 @@ struct ptlrpc_service *ptlrpc_register_service(struct ptlrpc_service_conf *conf,
 int ptlrpc_connect_import(struct obd_import *imp);
 int ptlrpc_init_import(struct obd_import *imp);
 int ptlrpc_disconnect_import(struct obd_import *imp, int noclose);
+int ptlrpc_disconnect_and_idle_import(struct obd_import *imp);
 int ptlrpc_import_recovery_state_machine(struct obd_import *imp);
 
 /* ptlrpc/pack_generic.c */
diff --git a/fs/lustre/lov/lov_ea.c b/fs/lustre/lov/lov_ea.c
index 41308d3..edca3b0 100644
--- a/fs/lustre/lov/lov_ea.c
+++ b/fs/lustre/lov/lov_ea.c
@@ -70,7 +70,8 @@ static loff_t lov_tgt_maxbytes(struct lov_tgt_desc *tgt)
 		return maxbytes;
 
 	spin_lock(&imp->imp_lock);
-	if (imp->imp_state == LUSTRE_IMP_FULL &&
+	if ((imp->imp_state == LUSTRE_IMP_FULL ||
+	    imp->imp_state == LUSTRE_IMP_IDLE) &&
 	    (imp->imp_connect_data.ocd_connect_flags & OBD_CONNECT_MAXBYTES) &&
 	     imp->imp_connect_data.ocd_maxbytes > 0)
 		maxbytes = imp->imp_connect_data.ocd_maxbytes;
diff --git a/fs/lustre/lov/lov_obd.c b/fs/lustre/lov/lov_obd.c
index 9449aa9..35eaa1f 100644
--- a/fs/lustre/lov/lov_obd.c
+++ b/fs/lustre/lov/lov_obd.c
@@ -977,17 +977,21 @@ static int lov_iocontrol(unsigned int cmd, struct obd_export *exp, int len,
 		struct obd_ioctl_data *data = karg;
 		struct obd_device *osc_obd;
 		struct obd_statfs stat_buf = { 0 };
+		struct obd_import *imp;
 		u32 index;
 		u32 flags;
 
-		memcpy(&index, data->ioc_inlbuf2, sizeof(u32));
+		memcpy(&index, data->ioc_inlbuf2, sizeof(index));
 		if (index >= count)
 			return -ENODEV;
 
 		if (!lov->lov_tgts[index])
 			/* Try again with the next index */
 			return -EAGAIN;
-		if (!lov->lov_tgts[index]->ltd_active)
+
+		imp = lov->lov_tgts[index]->ltd_exp->exp_obd->u.cli.cl_import;
+		if (!lov->lov_tgts[index]->ltd_active &&
+		    imp->imp_state != LUSTRE_IMP_IDLE)
 			return -ENODATA;
 
 		osc_obd = class_exp2obd(lov->lov_tgts[index]->ltd_exp);
diff --git a/fs/lustre/lov/lov_request.c b/fs/lustre/lov/lov_request.c
index 864e410..added19 100644
--- a/fs/lustre/lov/lov_request.c
+++ b/fs/lustre/lov/lov_request.c
@@ -99,6 +99,7 @@ static int lov_check_and_wait_active(struct lov_obd *lov, int ost_idx)
 {
 	int cnt = 0;
 	struct lov_tgt_desc *tgt;
+	struct obd_import *imp = NULL;
 	int rc = 0;
 
 	mutex_lock(&lov->lov_lock);
@@ -115,7 +116,13 @@ static int lov_check_and_wait_active(struct lov_obd *lov, int ost_idx)
 		goto out;
 	}
 
-	if (tgt->ltd_exp && class_exp2cliimp(tgt->ltd_exp)->imp_connect_tried) {
+	if (tgt->ltd_exp)
+		imp = class_exp2cliimp(tgt->ltd_exp);
+	if (imp && imp->imp_connect_tried) {
+		rc = 0;
+		goto out;
+	}
+	if (imp && imp->imp_state == LUSTRE_IMP_IDLE) {
 		rc = 0;
 		goto out;
 	}
@@ -302,11 +309,10 @@ int lov_prep_statfs_set(struct obd_device *obd, struct obd_info *oinfo,
 
 	/* We only get block data from the OBD */
 	for (i = 0; i < lov->desc.ld_tgt_count; i++) {
+		struct lov_tgt_desc *ltd = lov->lov_tgts[i];
 		struct lov_request *req;
 
-		if (!lov->lov_tgts[i] ||
-		    (oinfo->oi_flags & OBD_STATFS_NODELAY &&
-		     !lov->lov_tgts[i]->ltd_active)) {
+		if (!ltd) {
 			CDEBUG(D_HA, "lov idx %d inactive\n", i);
 			continue;
 		}
@@ -314,13 +320,20 @@ int lov_prep_statfs_set(struct obd_device *obd, struct obd_info *oinfo,
 		/* skip targets that have been explicitly disabled by the
 		 * administrator
 		 */
-		if (!lov->lov_tgts[i]->ltd_exp) {
+		if (!ltd->ltd_exp) {
 			CDEBUG(D_HA,
 			       "lov idx %d administratively disabled\n", i);
 			continue;
 		}
 
-		if (!lov->lov_tgts[i]->ltd_active)
+		if (oinfo->oi_flags & OBD_STATFS_NODELAY &&
+		    class_exp2cliimp(ltd->ltd_exp)->imp_state !=
+		    LUSTRE_IMP_IDLE && !ltd->ltd_active) {
+			CDEBUG(D_HA, "lov idx %d inactive\n", i);
+			continue;
+		}
+
+		if (!ltd->ltd_active)
 			lov_check_and_wait_active(lov, i);
 
 		req = kzalloc(sizeof(*req), GFP_NOFS);
diff --git a/fs/lustre/osc/lproc_osc.c b/fs/lustre/osc/lproc_osc.c
index 605a236..fd84393 100644
--- a/fs/lustre/osc/lproc_osc.c
+++ b/fs/lustre/osc/lproc_osc.c
@@ -598,6 +598,68 @@ static int osc_unstable_stats_seq_show(struct seq_file *m, void *v)
 
 LPROC_SEQ_FOPS_RO(osc_unstable_stats);
 
+static int osc_idle_timeout_seq_show(struct seq_file *m, void *v)
+{
+	struct obd_device *obd = m->private;
+	struct client_obd *cli = &obd->u.cli;
+
+	seq_printf(m, "%u\n", cli->cl_import->imp_idle_timeout);
+	return 0;
+}
+
+static ssize_t osc_idle_timeout_seq_write(struct file *f,
+					  const char __user *buffer,
+					  size_t count, loff_t *off)
+{
+	struct obd_device *obd = ((struct seq_file *)f->private_data)->private;
+	struct client_obd *cli = &obd->u.cli;
+	struct ptlrpc_request *req;
+	unsigned int val;
+	int rc;
+
+	rc = kstrtouint_from_user(buffer, count, 0, &val);
+	if (rc)
+		return rc;
+
+	if (val > CONNECTION_SWITCH_MAX)
+		return -ERANGE;
+
+	cli->cl_import->imp_idle_timeout = val;
+
+	/* to initiate the connection if it's in IDLE state */
+	if (!val) {
+		req = ptlrpc_request_alloc(cli->cl_import, &RQF_OST_STATFS);
+		if (req)
+			ptlrpc_req_finished(req);
+	}
+
+	return count;
+}
+LPROC_SEQ_FOPS(osc_idle_timeout);
+
+static int osc_idle_connect_seq_show(struct seq_file *m, void *v)
+{
+	return 0;
+}
+
+static ssize_t osc_idle_connect_seq_write(struct file *f,
+					  const char __user *buffer,
+					  size_t count, loff_t *off)
+{
+	struct obd_device *dev = ((struct seq_file *)f->private_data)->private;
+	struct client_obd *cli = &dev->u.cli;
+	struct ptlrpc_request *req;
+
+	/* to initiate the connection if it's in IDLE state */
+	req = ptlrpc_request_alloc(cli->cl_import, &RQF_OST_STATFS);
+	if (req)
+		ptlrpc_req_finished(req);
+	ptlrpc_pinger_force(cli->cl_import);
+
+	return count;
+}
+LPROC_SEQ_FOPS(osc_idle_connect);
+
 LPROC_SEQ_FOPS_RO_TYPE(osc, connect_flags);
 LPROC_SEQ_FOPS_RO_TYPE(osc, server_uuid);
 LPROC_SEQ_FOPS_RO_TYPE(osc, timeouts);
@@ -625,6 +687,10 @@ static int osc_unstable_stats_seq_show(struct seq_file *m, void *v)
 	  .fops	=	&osc_pinger_recov_fops		},
 	{ .name	=	"unstable_stats",
 	  .fops	=	&osc_unstable_stats_fops	},
+	{ .name	=	"idle_timeout",
+	  .fops	=	&osc_idle_timeout_fops		},
+	{ .name	=	"idle_connect",
+	  .fops	=	&osc_idle_connect_fops		},
 	{ NULL }
 };
 
diff --git a/fs/lustre/osc/osc_request.c b/fs/lustre/osc/osc_request.c
index 9ac9c84..e341fcc 100644
--- a/fs/lustre/osc/osc_request.c
+++ b/fs/lustre/osc/osc_request.c
@@ -61,6 +61,8 @@
 /* max memory used for request pool, unit is MB */
 static unsigned int osc_reqpool_mem_max = 5;
 module_param(osc_reqpool_mem_max, uint, 0444);
+static int osc_idle_timeout = 20;
+module_param(osc_idle_timeout, uint, 0644);
 
 struct osc_async_args {
 	struct obd_info		*aa_oi;
@@ -3214,6 +3216,7 @@ int osc_setup(struct obd_device *obd, struct lustre_cfg *lcfg)
 	spin_lock(&osc_shrink_lock);
 	list_add_tail(&cli->cl_shrink_list, &osc_shrink_list);
 	spin_unlock(&osc_shrink_lock);
+	cli->cl_import->imp_idle_timeout = osc_idle_timeout;
 
 	return rc;
 
diff --git a/fs/lustre/ptlrpc/client.c b/fs/lustre/ptlrpc/client.c
index 424db55..9b41c12 100644
--- a/fs/lustre/ptlrpc/client.c
+++ b/fs/lustre/ptlrpc/client.c
@@ -885,6 +885,28 @@ struct ptlrpc_request *__ptlrpc_request_alloc(struct obd_import *imp,
 			      const struct req_format *format)
 {
 	struct ptlrpc_request *request;
+	int connect = 0;
+
+	if (unlikely(imp->imp_state == LUSTRE_IMP_IDLE)) {
+		int rc;
+
+		CDEBUG(D_INFO, "%s: connect at new req\n",
+		       imp->imp_obd->obd_name);
+		spin_lock(&imp->imp_lock);
+		if (imp->imp_state == LUSTRE_IMP_IDLE) {
+			imp->imp_generation++;
+			imp->imp_initiated_at = imp->imp_generation;
+			imp->imp_state =  LUSTRE_IMP_NEW;
+			connect = 1;
+		}
+		spin_unlock(&imp->imp_lock);
+		if (connect) {
+			rc = ptlrpc_connect_import(imp);
+			if (rc < 0)
+				return NULL;
+			ptlrpc_pinger_add_import(imp);
+		}
+	}
 
 	request = __ptlrpc_request_alloc(imp, pool);
 	if (!request)
@@ -1075,6 +1097,7 @@ void ptlrpc_set_add_req(struct ptlrpc_request_set *set,
 		return;
 	}
 
+	LASSERT(req->rq_import->imp_state != LUSTRE_IMP_IDLE);
 	LASSERT(list_empty(&req->rq_set_chain));
 
 	/* The set takes over the caller's request reference */
@@ -1183,7 +1206,9 @@ static int ptlrpc_import_delay_req(struct obd_import *imp,
 		if (atomic_read(&imp->imp_inval_count) != 0) {
 			DEBUG_REQ(D_ERROR, req, "invalidate in flight");
 			*status = -EIO;
-		} else if (req->rq_no_delay) {
+		} else if (req->rq_no_delay &&
+			   imp->imp_generation != imp->imp_initiated_at) {
+			/* ignore nodelay for requests initiating connections */
 			*status = -EWOULDBLOCK;
 		} else if (req->rq_allow_replay &&
 			  (imp->imp_state == LUSTRE_IMP_REPLAY ||
@@ -1842,8 +1867,11 @@ int ptlrpc_check_set(const struct lu_env *env, struct ptlrpc_request_set *set)
 					spin_unlock(&imp->imp_lock);
 					goto interpret;
 				}
+				/* ignore on just initiated connections */
 				if (ptlrpc_no_resend(req) &&
-				    !req->rq_wait_ctx) {
+				    !req->rq_wait_ctx &&
+				    imp->imp_generation !=
+				    imp->imp_initiated_at) {
 					req->rq_status = -ENOTCONN;
 					ptlrpc_rqphase_move(req,
 							    RQ_PHASE_INTERPRET);
diff --git a/fs/lustre/ptlrpc/events.c b/fs/lustre/ptlrpc/events.c
index 93a59b8..87c0ab7 100644
--- a/fs/lustre/ptlrpc/events.c
+++ b/fs/lustre/ptlrpc/events.c
@@ -164,7 +164,8 @@ void reply_in_callback(struct lnet_event *ev)
 			  ev->mlength, ev->offset, req->rq_replen);
 	}
 
-	req->rq_import->imp_last_reply_time = ktime_get_real_seconds();
+	if (lustre_msg_get_opc(req->rq_reqmsg) != OBD_PING)
+		req->rq_import->imp_last_reply_time = ktime_get_real_seconds();
 
 out_wake:
 	/* NB don't unlock till after wakeup; req can disappear under us
diff --git a/fs/lustre/ptlrpc/import.c b/fs/lustre/ptlrpc/import.c
index 019648b..b90f78c 100644
--- a/fs/lustre/ptlrpc/import.c
+++ b/fs/lustre/ptlrpc/import.c
@@ -925,6 +925,21 @@ static int ptlrpc_connect_interpret(const struct lu_env *env,
 	}
 
 	if (rc) {
+		struct ptlrpc_request *free_req;
+		struct ptlrpc_request *tmp;
+
+		/* abort all delayed requests initiated connection */
+		list_for_each_entry_safe(free_req, tmp, &imp->imp_delayed_list,
+					 rq_list) {
+			spin_lock(&free_req->rq_lock);
+			if (free_req->rq_no_resend) {
+				free_req->rq_err = 1;
+				free_req->rq_status = -EIO;
+				ptlrpc_client_wake_req(free_req);
+			}
+			spin_unlock(&free_req->rq_lock);
+		}
+
 		/* if this reconnect to busy export - not need select new target
 		 * for connecting
 		 */
@@ -1454,14 +1469,11 @@ int ptlrpc_import_recovery_state_machine(struct obd_import *imp)
 	return rc;
 }
 
-int ptlrpc_disconnect_import(struct obd_import *imp, int noclose)
+static struct ptlrpc_request *ptlrpc_disconnect_prep_req(struct obd_import *imp)
 {
 	struct ptlrpc_request *req;
 	int rq_opc, rc = 0;
 
-	if (imp->imp_obd->obd_force)
-		goto set_state;
-
 	switch (imp->imp_connect_op) {
 	case OST_CONNECT:
 		rq_opc = OST_DISCONNECT;
@@ -1477,9 +1489,47 @@ int ptlrpc_disconnect_import(struct obd_import *imp, int noclose)
 		CERROR("%s: don't know how to disconnect from %s (connect_op %d): rc = %d\n",
 		       imp->imp_obd->obd_name, obd2cli_tgt(imp->imp_obd),
 		       imp->imp_connect_op, rc);
-		return rc;
+		return ERR_PTR(rc);
 	}
 
+	req = ptlrpc_request_alloc_pack(imp, &RQF_MDS_DISCONNECT,
+					LUSTRE_OBD_VERSION, rq_opc);
+	if (!req)
+		return NULL;
+
+	/* We are disconnecting, do not retry a failed DISCONNECT rpc if
+	 * it fails.  We can get through the above with a down server
+	 * if the client doesn't know the server is gone yet.
+	 */
+	req->rq_no_resend = 1;
+
+	/* We want client umounts to happen quickly, no matter the
+	 * server state...
+	 */
+	req->rq_timeout = min_t(int, req->rq_timeout,
+				INITIAL_CONNECT_TIMEOUT);
+
+	IMPORT_SET_STATE(imp, LUSTRE_IMP_CONNECTING);
+	req->rq_send_state =  LUSTRE_IMP_CONNECTING;
+	ptlrpc_request_set_replen(req);
+
+	return req;
+}
+
+int ptlrpc_disconnect_import(struct obd_import *imp, int noclose)
+{
+	struct ptlrpc_request *req;
+	int rc = 0;
+
+	if (imp->imp_obd->obd_force)
+		goto set_state;
+
+	/* probably the import has been disconnected already being idle */
+	spin_lock(&imp->imp_lock);
+	if (imp->imp_state == LUSTRE_IMP_IDLE)
+		goto out;
+	spin_unlock(&imp->imp_lock);
+
 	if (ptlrpc_import_in_recovery(imp)) {
 		long timeout_jiffies;
 		time64_t timeout;
@@ -1512,27 +1562,13 @@ int ptlrpc_disconnect_import(struct obd_import *imp, int noclose)
 		goto out;
 	spin_unlock(&imp->imp_lock);
 
-	req = ptlrpc_request_alloc_pack(imp, &RQF_MDS_DISCONNECT,
-					LUSTRE_OBD_VERSION, rq_opc);
-	if (req) {
-		/* We are disconnecting, do not retry a failed DISCONNECT rpc if
-		 * it fails.  We can get through the above with a down server
-		 * if the client doesn't know the server is gone yet.
-		 */
-		req->rq_no_resend = 1;
-
-		/* We want client umounts to happen quickly, no matter the
-		 * server state...
-		 */
-		req->rq_timeout = min_t(int, req->rq_timeout,
-					INITIAL_CONNECT_TIMEOUT);
-
-		IMPORT_SET_STATE(imp, LUSTRE_IMP_CONNECTING);
-		req->rq_send_state = LUSTRE_IMP_CONNECTING;
-		ptlrpc_request_set_replen(req);
-		rc = ptlrpc_queue_wait(req);
-		ptlrpc_req_finished(req);
+	req = ptlrpc_disconnect_prep_req(imp);
+	if (IS_ERR(req)) {
+		rc = PTR_ERR(req);
+		goto set_state;
 	}
+	rc = ptlrpc_queue_wait(req);
+	ptlrpc_req_finished(req);
 
 set_state:
 	spin_lock(&imp->imp_lock);
@@ -1551,6 +1587,50 @@ int ptlrpc_disconnect_import(struct obd_import *imp, int noclose)
 }
 EXPORT_SYMBOL(ptlrpc_disconnect_import);
 
+static int ptlrpc_disconnect_idle_interpret(const struct lu_env *env,
+					    struct ptlrpc_request *req,
+					    void *data, int rc)
+{
+	struct obd_import *imp = req->rq_import;
+
+	LASSERT(imp->imp_state == LUSTRE_IMP_CONNECTING);
+	spin_lock(&imp->imp_lock);
+	IMPORT_SET_STATE_NOLOCK(imp, LUSTRE_IMP_IDLE);
+	memset(&imp->imp_remote_handle, 0, sizeof(imp->imp_remote_handle));
+	spin_unlock(&imp->imp_lock);
+
+	return 0;
+}
+
+int ptlrpc_disconnect_and_idle_import(struct obd_import *imp)
+{
+	struct ptlrpc_request *req;
+
+	if (imp->imp_obd->obd_force)
+		return 0;
+
+	if (ptlrpc_import_in_recovery(imp))
+		return 0;
+
+	spin_lock(&imp->imp_lock);
+	if (imp->imp_state != LUSTRE_IMP_FULL) {
+		spin_unlock(&imp->imp_lock);
+		return 0;
+	}
+	spin_unlock(&imp->imp_lock);
+
+	req = ptlrpc_disconnect_prep_req(imp);
+	if (IS_ERR(req))
+		return PTR_ERR(req);
+
+	CDEBUG(D_INFO, "%s: disconnect\n", imp->imp_obd->obd_name);
+	req->rq_interpret_reply = ptlrpc_disconnect_idle_interpret;
+	ptlrpcd_add_req(req);
+
+	return 0;
+}
+EXPORT_SYMBOL(ptlrpc_disconnect_and_idle_import);
+
 /* Adaptive Timeout utils */
 
 /*
diff --git a/fs/lustre/ptlrpc/pinger.c b/fs/lustre/ptlrpc/pinger.c
index 762fd0e..c565e2d 100644
--- a/fs/lustre/ptlrpc/pinger.c
+++ b/fs/lustre/ptlrpc/pinger.c
@@ -79,10 +79,40 @@ int ptlrpc_obd_ping(struct obd_device *obd)
 }
 EXPORT_SYMBOL(ptlrpc_obd_ping);
 
+static bool ptlrpc_check_import_is_idle(struct obd_import *imp)
+{
+	struct ldlm_namespace *ns = imp->imp_obd->obd_namespace;
+	time64_t now;
+
+	if (!imp->imp_idle_timeout)
+		return false;
+	/* 4 comes from:
+	 *  - client_obd_setup() - hashed import
+	 *  - ptlrpcd_alloc_work()
+	 *  - ptlrpcd_alloc_work()
+	 *  - ptlrpc_pinger_add_import
+	 */
+	if (atomic_read(&imp->imp_refcount) > 4)
+		return false;
+
+	/* any lock increases ns_bref being a resource holder */
+	if (ns && atomic_read(&ns->ns_bref) > 0)
+		return false;
+
+	now = ktime_get_real_seconds();
+	if (now - imp->imp_last_reply_time < imp->imp_idle_timeout)
+		return false;
+
+	return true;
+}
+
 static int ptlrpc_ping(struct obd_import *imp)
 {
 	struct ptlrpc_request *req;
 
+	if (ptlrpc_check_import_is_idle(imp))
+		return ptlrpc_disconnect_and_idle_import(imp);
+
 	req = ptlrpc_prep_ping(imp);
 	if (!req) {
 		CERROR("OOM trying to ping %s->%s\n",
-- 
1.8.3.1
