From: James Simmons <jsimmons@infradead.org>
Date: Thu, 31 Jan 2019 12:19:23 -0500
Subject: [lustre-devel] [PATCH 19/26] ptlrpc: cleanup white spaces
In-Reply-To: <1548955170-13456-1-git-send-email-jsimmons@infradead.org>
References: <1548955170-13456-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1548955170-13456-20-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

The ptlrpc code is very messy and difficult to read. Remove excess
white space and properly align data structures so they are easy on
the eyes.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/ptlrpc/client.c      |  45 ++--
 drivers/staging/lustre/lustre/ptlrpc/import.c      |   2 +-
 drivers/staging/lustre/lustre/ptlrpc/layout.c      |   3 -
 .../staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c    | 278 ++++++++++-----------
 drivers/staging/lustre/lustre/ptlrpc/niobuf.c      |   7 +-
 drivers/staging/lustre/lustre/ptlrpc/nrs.c         |   1 -
 .../staging/lustre/lustre/ptlrpc/ptlrpc_internal.h |  14 +-
 drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c     |  20 +-
 drivers/staging/lustre/lustre/ptlrpc/recover.c     |   1 +
 drivers/staging/lustre/lustre/ptlrpc/sec.c         |   4 +-
 drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c    |  74 +++---
 drivers/staging/lustre/lustre/ptlrpc/sec_config.c  |  22 +-
 drivers/staging/lustre/lustre/ptlrpc/sec_null.c    |  34 +--
 drivers/staging/lustre/lustre/ptlrpc/sec_plain.c   |  68 ++---
 drivers/staging/lustre/lustre/ptlrpc/service.c     |  20 +-
 15 files changed, 293 insertions(+), 300 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ptlrpc/client.c b/drivers/staging/lustre/lustre/ptlrpc/client.c
index f4b3875..0831810 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/client.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/client.c
@@ -49,14 +49,14 @@
 #include "ptlrpc_internal.h"
 
 const struct ptlrpc_bulk_frag_ops ptlrpc_bulk_kiov_pin_ops = {
-	.add_kiov_frag	= ptlrpc_prep_bulk_page_pin,
-	.release_frags	= ptlrpc_release_bulk_page_pin,
+	.add_kiov_frag		= ptlrpc_prep_bulk_page_pin,
+	.release_frags		= ptlrpc_release_bulk_page_pin,
 };
 EXPORT_SYMBOL(ptlrpc_bulk_kiov_pin_ops);
 
 const struct ptlrpc_bulk_frag_ops ptlrpc_bulk_kiov_nopin_ops = {
-	.add_kiov_frag	= ptlrpc_prep_bulk_page_nopin,
-	.release_frags	= NULL,
+	.add_kiov_frag		= ptlrpc_prep_bulk_page_nopin,
+	.release_frags		= NULL,
 };
 EXPORT_SYMBOL(ptlrpc_bulk_kiov_nopin_ops);
 
@@ -658,15 +658,14 @@ static void __ptlrpc_free_req_to_pool(struct ptlrpc_request *request)
 
 void ptlrpc_add_unreplied(struct ptlrpc_request *req)
 {
-	struct obd_import	*imp = req->rq_import;
-	struct ptlrpc_request	*iter;
+	struct obd_import *imp = req->rq_import;
+	struct ptlrpc_request *iter;
 
 	assert_spin_locked(&imp->imp_lock);
 	LASSERT(list_empty(&req->rq_unreplied_list));
 
 	/* unreplied list is sorted by xid in ascending order */
 	list_for_each_entry_reverse(iter, &imp->imp_unreplied_list, rq_unreplied_list) {
-
 		LASSERT(req->rq_xid != iter->rq_xid);
 		if (req->rq_xid < iter->rq_xid)
 			continue;
@@ -1318,10 +1317,10 @@ static int after_reply(struct ptlrpc_request *req)
 		 * reply).  NB: no need to round up because alloc_repbuf will
 		 * round it up
 		 */
-		req->rq_replen       = req->rq_nob_received;
+		req->rq_replen = req->rq_nob_received;
 		req->rq_nob_received = 0;
 		spin_lock(&req->rq_lock);
-		req->rq_resend       = 1;
+		req->rq_resend = 1;
 		spin_unlock(&req->rq_lock);
 		return 0;
 	}
@@ -1359,7 +1358,7 @@ static int after_reply(struct ptlrpc_request *req)
 		spin_unlock(&req->rq_lock);
 		req->rq_nr_resend++;
 
-		/* Readjust the timeout for current conditions */
+		/* Read just the timeout for current conditions */
 		ptlrpc_at_set_req_timeout(req);
 		/*
 		 * delay resend to give a chance to the server to get ready.
@@ -1620,7 +1619,7 @@ static inline int ptlrpc_set_producer(struct ptlrpc_request_set *set)
 		rc = set->set_producer(set, set->set_producer_arg);
 		if (rc == -ENOENT) {
 			/* no more RPC to produce */
-			set->set_producer     = NULL;
+			set->set_producer = NULL;
 			set->set_producer_arg = NULL;
 			return 0;
 		}
@@ -1654,7 +1653,7 @@ int ptlrpc_check_set(const struct lu_env *env, struct ptlrpc_request_set *set)
 
 		/*
 		 * This schedule point is mainly for the ptlrpcd caller of this
-		 * function.  Most ptlrpc sets are not long-lived and unbounded
+		 * function. Most ptlrpc sets are not long-lived and unbounded
 		 * in length, but at the least the set used by the ptlrpcd is.
 		 * Since the processing time is unbounded, we need to insert an
 		 * explicit schedule point to make the thread well-behaved.
@@ -2130,7 +2129,6 @@ void ptlrpc_expired_set(struct ptlrpc_request_set *set)
 
 	/* A timeout expired. See which reqs it applies to...  */
 	list_for_each_entry(req, &set->set_requests, rq_set_chain) {
-
 		/* don't expire request waiting for context */
 		if (req->rq_wait_ctx)
 			continue;
@@ -2185,7 +2183,6 @@ int ptlrpc_set_next_timeout(struct ptlrpc_request_set *set)
 	time64_t deadline;
 
 	list_for_each_entry(req, &set->set_requests, rq_set_chain) {
-
 		/* Request in-flight? */
 		if (!(((req->rq_phase == RQ_PHASE_RPC) && !req->rq_waiting) ||
 		      (req->rq_phase == RQ_PHASE_BULK) ||
@@ -2568,7 +2565,7 @@ static void ptlrpc_free_request(struct ptlrpc_request *req)
  */
 void ptlrpc_request_committed(struct ptlrpc_request *req, int force)
 {
-	struct obd_import	*imp = req->rq_import;
+	struct obd_import *imp = req->rq_import;
 
 	spin_lock(&imp->imp_lock);
 	if (list_empty(&req->rq_replay_list)) {
@@ -2896,7 +2893,7 @@ static int ptlrpc_replay_interpret(const struct lu_env *env,
 
 	/* continue with recovery */
 	rc = ptlrpc_import_recovery_state_machine(imp);
- out:
+out:
 	req->rq_send_state = aa->praa_old_state;
 
 	if (rc != 0)
@@ -3031,7 +3028,7 @@ void ptlrpc_abort_set(struct ptlrpc_request_set *set)
 /**
  * Initialize the XID for the node.  This is common among all requests on
  * this node, and only requires the property that it is monotonically
- * increasing.  It does not need to be sequential.  Since this is also used
+ * increasing. It does not need to be sequential.  Since this is also used
  * as the RDMA match bits, it is important that a single client NOT have
  * the same match bits for two different in-flight requests, hence we do
  * NOT want to have an XID per target or similar.
@@ -3198,12 +3195,12 @@ struct ptlrpc_work_async_args {
 static void ptlrpcd_add_work_req(struct ptlrpc_request *req)
 {
 	/* re-initialize the req */
-	req->rq_timeout		= obd_timeout;
-	req->rq_sent		= ktime_get_real_seconds();
-	req->rq_deadline	= req->rq_sent + req->rq_timeout;
-	req->rq_phase		= RQ_PHASE_INTERPRET;
-	req->rq_next_phase	= RQ_PHASE_COMPLETE;
-	req->rq_xid		= ptlrpc_next_xid();
+	req->rq_timeout	= obd_timeout;
+	req->rq_sent = ktime_get_real_seconds();
+	req->rq_deadline = req->rq_sent + req->rq_timeout;
+	req->rq_phase = RQ_PHASE_INTERPRET;
+	req->rq_next_phase = RQ_PHASE_COMPLETE;
+	req->rq_xid = ptlrpc_next_xid();
 	req->rq_import_generation = req->rq_import->imp_generation;
 
 	ptlrpcd_add_req(req);
@@ -3241,7 +3238,7 @@ static int ptlrpcd_check_work(struct ptlrpc_request *req)
 void *ptlrpcd_alloc_work(struct obd_import *imp,
 			 int (*cb)(const struct lu_env *, void *), void *cbdata)
 {
-	struct ptlrpc_request	 *req = NULL;
+	struct ptlrpc_request *req = NULL;
 	struct ptlrpc_work_async_args *args;
 
 	might_sleep();
diff --git a/drivers/staging/lustre/lustre/ptlrpc/import.c b/drivers/staging/lustre/lustre/ptlrpc/import.c
index 56a0b76..7bb2e06 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/import.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/import.c
@@ -51,7 +51,7 @@
 #include "ptlrpc_internal.h"
 
 struct ptlrpc_connect_async_args {
-	 u64 pcaa_peer_committed;
+	u64 pcaa_peer_committed;
 	int pcaa_initial_connect;
 };
 
diff --git a/drivers/staging/lustre/lustre/ptlrpc/layout.c b/drivers/staging/lustre/lustre/ptlrpc/layout.c
index 2848f2f..f1f7d70 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/layout.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/layout.c
@@ -1907,9 +1907,7 @@ static void *__req_capsule_get(struct req_capsule *pill,
 	void *value;
 	u32 len;
 	u32 offset;
-
 	void *(*getter)(struct lustre_msg *m, u32 n, u32 minlen);
-
 	static const char *rcl_names[RCL_NR] = {
 		[RCL_CLIENT] = "client",
 		[RCL_SERVER] = "server"
@@ -2176,7 +2174,6 @@ void req_capsule_extend(struct req_capsule *pill, const struct req_format *fmt)
 {
 	int i;
 	size_t j;
-
 	const struct req_format *old;
 
 	LASSERT(pill->rc_fmt);
diff --git a/drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c b/drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c
index 92e3e0f..25858b8 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c
@@ -42,115 +42,115 @@
 #include "ptlrpc_internal.h"
 
 static struct ll_rpc_opcode {
-	u32       opcode;
-	const char *opname;
+	u32				opcode;
+	const char			*opname;
 } ll_rpc_opcode_table[LUSTRE_MAX_OPCODES] = {
-	{ OST_REPLY,	"ost_reply" },
-	{ OST_GETATTR,      "ost_getattr" },
-	{ OST_SETATTR,      "ost_setattr" },
-	{ OST_READ,	 "ost_read" },
-	{ OST_WRITE,	"ost_write" },
-	{ OST_CREATE,       "ost_create" },
-	{ OST_DESTROY,      "ost_destroy" },
-	{ OST_GET_INFO,     "ost_get_info" },
-	{ OST_CONNECT,      "ost_connect" },
-	{ OST_DISCONNECT,   "ost_disconnect" },
-	{ OST_PUNCH,	"ost_punch" },
-	{ OST_OPEN,	 "ost_open" },
-	{ OST_CLOSE,	"ost_close" },
-	{ OST_STATFS,       "ost_statfs" },
-	{ 14,		NULL },    /* formerly OST_SAN_READ */
-	{ 15,		NULL },    /* formerly OST_SAN_WRITE */
-	{ OST_SYNC,	 "ost_sync" },
-	{ OST_SET_INFO,     "ost_set_info" },
-	{ OST_QUOTACHECK,   "ost_quotacheck" },
-	{ OST_QUOTACTL,     "ost_quotactl" },
-	{ OST_QUOTA_ADJUST_QUNIT, "ost_quota_adjust_qunit" },
-	{ OST_LADVISE,			"ost_ladvise" },
-	{ MDS_GETATTR,      "mds_getattr" },
-	{ MDS_GETATTR_NAME, "mds_getattr_lock" },
-	{ MDS_CLOSE,	"mds_close" },
-	{ MDS_REINT,	"mds_reint" },
-	{ MDS_READPAGE,     "mds_readpage" },
-	{ MDS_CONNECT,      "mds_connect" },
-	{ MDS_DISCONNECT,   "mds_disconnect" },
-	{ MDS_GET_ROOT,			"mds_get_root" },
-	{ MDS_STATFS,       "mds_statfs" },
-	{ MDS_PIN,	  "mds_pin" },
-	{ MDS_UNPIN,	"mds_unpin" },
-	{ MDS_SYNC,	 "mds_sync" },
-	{ MDS_DONE_WRITING, "mds_done_writing" },
-	{ MDS_SET_INFO,     "mds_set_info" },
-	{ MDS_QUOTACHECK,   "mds_quotacheck" },
-	{ MDS_QUOTACTL,     "mds_quotactl" },
-	{ MDS_GETXATTR,     "mds_getxattr" },
-	{ MDS_SETXATTR,     "mds_setxattr" },
-	{ MDS_WRITEPAGE,    "mds_writepage" },
-	{ MDS_IS_SUBDIR,    "mds_is_subdir" },
-	{ MDS_GET_INFO,     "mds_get_info" },
-	{ MDS_HSM_STATE_GET, "mds_hsm_state_get" },
-	{ MDS_HSM_STATE_SET, "mds_hsm_state_set" },
-	{ MDS_HSM_ACTION,   "mds_hsm_action" },
-	{ MDS_HSM_PROGRESS, "mds_hsm_progress" },
-	{ MDS_HSM_REQUEST,  "mds_hsm_request" },
-	{ MDS_HSM_CT_REGISTER, "mds_hsm_ct_register" },
-	{ MDS_HSM_CT_UNREGISTER, "mds_hsm_ct_unregister" },
-	{ MDS_SWAP_LAYOUTS,	"mds_swap_layouts" },
-	{ LDLM_ENQUEUE,     "ldlm_enqueue" },
-	{ LDLM_CONVERT,     "ldlm_convert" },
-	{ LDLM_CANCEL,      "ldlm_cancel" },
-	{ LDLM_BL_CALLBACK, "ldlm_bl_callback" },
-	{ LDLM_CP_CALLBACK, "ldlm_cp_callback" },
-	{ LDLM_GL_CALLBACK, "ldlm_gl_callback" },
-	{ LDLM_SET_INFO,    "ldlm_set_info" },
-	{ MGS_CONNECT,      "mgs_connect" },
-	{ MGS_DISCONNECT,   "mgs_disconnect" },
-	{ MGS_EXCEPTION,    "mgs_exception" },
-	{ MGS_TARGET_REG,   "mgs_target_reg" },
-	{ MGS_TARGET_DEL,   "mgs_target_del" },
-	{ MGS_SET_INFO,     "mgs_set_info" },
-	{ MGS_CONFIG_READ,  "mgs_config_read" },
-	{ OBD_PING,	 "obd_ping" },
-	{ OBD_LOG_CANCEL,	"llog_cancel" },
-	{ OBD_QC_CALLBACK,  "obd_quota_callback" },
-	{ OBD_IDX_READ,	    "dt_index_read" },
-	{ LLOG_ORIGIN_HANDLE_CREATE,	 "llog_origin_handle_open" },
-	{ LLOG_ORIGIN_HANDLE_NEXT_BLOCK, "llog_origin_handle_next_block" },
-	{ LLOG_ORIGIN_HANDLE_READ_HEADER, "llog_origin_handle_read_header" },
-	{ LLOG_ORIGIN_HANDLE_WRITE_REC,  "llog_origin_handle_write_rec" },
-	{ LLOG_ORIGIN_HANDLE_CLOSE,      "llog_origin_handle_close" },
-	{ LLOG_ORIGIN_CONNECT,	   "llog_origin_connect" },
-	{ LLOG_CATINFO,		  "llog_catinfo" },
-	{ LLOG_ORIGIN_HANDLE_PREV_BLOCK, "llog_origin_handle_prev_block" },
-	{ LLOG_ORIGIN_HANDLE_DESTROY,    "llog_origin_handle_destroy" },
-	{ QUOTA_DQACQ,      "quota_acquire" },
-	{ QUOTA_DQREL,      "quota_release" },
-	{ SEQ_QUERY,	"seq_query" },
-	{ SEC_CTX_INIT,     "sec_ctx_init" },
-	{ SEC_CTX_INIT_CONT, "sec_ctx_init_cont" },
-	{ SEC_CTX_FINI,     "sec_ctx_fini" },
-	{ FLD_QUERY,	"fld_query" },
-	{ FLD_READ,	"fld_read" },
+	{ OST_REPLY,				"ost_reply" },
+	{ OST_GETATTR,				"ost_getattr" },
+	{ OST_SETATTR,				"ost_setattr" },
+	{ OST_READ,				"ost_read" },
+	{ OST_WRITE,				"ost_write" },
+	{ OST_CREATE,				"ost_create" },
+	{ OST_DESTROY,				"ost_destroy" },
+	{ OST_GET_INFO,				"ost_get_info" },
+	{ OST_CONNECT,				"ost_connect" },
+	{ OST_DISCONNECT,			"ost_disconnect" },
+	{ OST_PUNCH,				"ost_punch" },
+	{ OST_OPEN,				"ost_open" },
+	{ OST_CLOSE,				"ost_close" },
+	{ OST_STATFS,				"ost_statfs" },
+	{ 14,					NULL },	/* formerly OST_SAN_READ */
+	{ 15,					NULL }, /* formerly OST_SAN_WRITE */
+	{ OST_SYNC,				"ost_sync" },
+	{ OST_SET_INFO,				"ost_set_info" },
+	{ OST_QUOTACHECK,			"ost_quotacheck" },
+	{ OST_QUOTACTL,				"ost_quotactl" },
+	{ OST_QUOTA_ADJUST_QUNIT,		"ost_quota_adjust_qunit" },
+	{ OST_LADVISE,				"ost_ladvise" },
+	{ MDS_GETATTR,				"mds_getattr" },
+	{ MDS_GETATTR_NAME,			"mds_getattr_lock" },
+	{ MDS_CLOSE,				"mds_close" },
+	{ MDS_REINT,				"mds_reint" },
+	{ MDS_READPAGE,				"mds_readpage" },
+	{ MDS_CONNECT,				"mds_connect" },
+	{ MDS_DISCONNECT,			"mds_disconnect" },
+	{ MDS_GET_ROOT,				"mds_get_root" },
+	{ MDS_STATFS,				"mds_statfs" },
+	{ MDS_PIN,				"mds_pin" },
+	{ MDS_UNPIN,				"mds_unpin" },
+	{ MDS_SYNC,				"mds_sync" },
+	{ MDS_DONE_WRITING,			"mds_done_writing" },
+	{ MDS_SET_INFO,				"mds_set_info" },
+	{ MDS_QUOTACHECK,			"mds_quotacheck" },
+	{ MDS_QUOTACTL,				"mds_quotactl" },
+	{ MDS_GETXATTR,				"mds_getxattr" },
+	{ MDS_SETXATTR,				"mds_setxattr" },
+	{ MDS_WRITEPAGE,			"mds_writepage" },
+	{ MDS_IS_SUBDIR,			"mds_is_subdir" },
+	{ MDS_GET_INFO,				"mds_get_info" },
+	{ MDS_HSM_STATE_GET,			"mds_hsm_state_get" },
+	{ MDS_HSM_STATE_SET,			"mds_hsm_state_set" },
+	{ MDS_HSM_ACTION,			"mds_hsm_action" },
+	{ MDS_HSM_PROGRESS,			"mds_hsm_progress" },
+	{ MDS_HSM_REQUEST,			"mds_hsm_request" },
+	{ MDS_HSM_CT_REGISTER,			"mds_hsm_ct_register" },
+	{ MDS_HSM_CT_UNREGISTER,		"mds_hsm_ct_unregister" },
+	{ MDS_SWAP_LAYOUTS,			"mds_swap_layouts" },
+	{ LDLM_ENQUEUE,				"ldlm_enqueue" },
+	{ LDLM_CONVERT,				"ldlm_convert" },
+	{ LDLM_CANCEL,				"ldlm_cancel" },
+	{ LDLM_BL_CALLBACK,			"ldlm_bl_callback" },
+	{ LDLM_CP_CALLBACK,			"ldlm_cp_callback" },
+	{ LDLM_GL_CALLBACK,			"ldlm_gl_callback" },
+	{ LDLM_SET_INFO,			"ldlm_set_info" },
+	{ MGS_CONNECT,				"mgs_connect" },
+	{ MGS_DISCONNECT,			"mgs_disconnect" },
+	{ MGS_EXCEPTION,			"mgs_exception" },
+	{ MGS_TARGET_REG,			"mgs_target_reg" },
+	{ MGS_TARGET_DEL,			"mgs_target_del" },
+	{ MGS_SET_INFO,				"mgs_set_info" },
+	{ MGS_CONFIG_READ,			"mgs_config_read" },
+	{ OBD_PING,				"obd_ping" },
+	{ OBD_LOG_CANCEL,			"llog_cancel" },
+	{ OBD_QC_CALLBACK,			"obd_quota_callback" },
+	{ OBD_IDX_READ,				"dt_index_read" },
+	{ LLOG_ORIGIN_HANDLE_CREATE,		 "llog_origin_handle_open" },
+	{ LLOG_ORIGIN_HANDLE_NEXT_BLOCK,	"llog_origin_handle_next_block" },
+	{ LLOG_ORIGIN_HANDLE_READ_HEADER,	"llog_origin_handle_read_header" },
+	{ LLOG_ORIGIN_HANDLE_WRITE_REC,		"llog_origin_handle_write_rec" },
+	{ LLOG_ORIGIN_HANDLE_CLOSE,		"llog_origin_handle_close" },
+	{ LLOG_ORIGIN_CONNECT,			"llog_origin_connect" },
+	{ LLOG_CATINFO,				"llog_catinfo" },
+	{ LLOG_ORIGIN_HANDLE_PREV_BLOCK,	"llog_origin_handle_prev_block" },
+	{ LLOG_ORIGIN_HANDLE_DESTROY,		"llog_origin_handle_destroy" },
+	{ QUOTA_DQACQ,				"quota_acquire" },
+	{ QUOTA_DQREL,				"quota_release" },
+	{ SEQ_QUERY,				"seq_query" },
+	{ SEC_CTX_INIT,				"sec_ctx_init" },
+	{ SEC_CTX_INIT_CONT,			"sec_ctx_init_cont" },
+	{ SEC_CTX_FINI,				"sec_ctx_fini" },
+	{ FLD_QUERY,				"fld_query" },
+	{ FLD_READ,				"fld_read" },
 };
 
 static struct ll_eopcode {
-	u32       opcode;
-	const char *opname;
+	u32			opcode;
+	const char		*opname;
 } ll_eopcode_table[EXTRA_LAST_OPC] = {
-	{ LDLM_GLIMPSE_ENQUEUE, "ldlm_glimpse_enqueue" },
-	{ LDLM_PLAIN_ENQUEUE,   "ldlm_plain_enqueue" },
-	{ LDLM_EXTENT_ENQUEUE,  "ldlm_extent_enqueue" },
-	{ LDLM_FLOCK_ENQUEUE,   "ldlm_flock_enqueue" },
-	{ LDLM_IBITS_ENQUEUE,   "ldlm_ibits_enqueue" },
-	{ MDS_REINT_SETATTR,    "mds_reint_setattr" },
-	{ MDS_REINT_CREATE,     "mds_reint_create" },
-	{ MDS_REINT_LINK,       "mds_reint_link" },
-	{ MDS_REINT_UNLINK,     "mds_reint_unlink" },
-	{ MDS_REINT_RENAME,     "mds_reint_rename" },
-	{ MDS_REINT_OPEN,       "mds_reint_open" },
-	{ MDS_REINT_SETXATTR,   "mds_reint_setxattr" },
-	{ BRW_READ_BYTES,       "read_bytes" },
-	{ BRW_WRITE_BYTES,      "write_bytes" },
+	{ LDLM_GLIMPSE_ENQUEUE,			"ldlm_glimpse_enqueue" },
+	{ LDLM_PLAIN_ENQUEUE,			"ldlm_plain_enqueue" },
+	{ LDLM_EXTENT_ENQUEUE,			"ldlm_extent_enqueue" },
+	{ LDLM_FLOCK_ENQUEUE,			"ldlm_flock_enqueue" },
+	{ LDLM_IBITS_ENQUEUE,			"ldlm_ibits_enqueue" },
+	{ MDS_REINT_SETATTR,			"mds_reint_setattr" },
+	{ MDS_REINT_CREATE,			"mds_reint_create" },
+	{ MDS_REINT_LINK,			"mds_reint_link" },
+	{ MDS_REINT_UNLINK,			"mds_reint_unlink" },
+	{ MDS_REINT_RENAME,			"mds_reint_rename" },
+	{ MDS_REINT_OPEN,			"mds_reint_open" },
+	{ MDS_REINT_SETXATTR,			"mds_reint_setxattr" },
+	{ BRW_READ_BYTES,			"read_bytes" },
+	{ BRW_WRITE_BYTES,			"write_bytes" },
 };
 
 const char *ll_opcode2str(u32 opcode)
@@ -450,13 +450,13 @@ static void nrs_policy_get_info_locked(struct ptlrpc_nrs_policy *policy,
 
 	memcpy(info->pi_name, policy->pol_desc->pd_name, NRS_POL_NAME_MAX);
 
-	info->pi_fallback    = !!(policy->pol_flags & PTLRPC_NRS_FL_FALLBACK);
-	info->pi_state	     = policy->pol_state;
+	info->pi_fallback = !!(policy->pol_flags & PTLRPC_NRS_FL_FALLBACK);
+	info->pi_state = policy->pol_state;
 	/**
 	 * XXX: These are accessed without holding
 	 * ptlrpc_service_part::scp_req_lock.
 	 */
-	info->pi_req_queued  = policy->pol_req_queued;
+	info->pi_req_queued = policy->pol_req_queued;
 	info->pi_req_started = policy->pol_req_started;
 }
 
@@ -788,18 +788,18 @@ struct ptlrpc_srh_iterator {
 /* convert position to sequence */
 #define PTLRPC_REQ_POS2SEQ(svc, pos)			\
 	((svc)->srv_cpt_bits == 0 ? (pos) :		\
-	 ((u64)(pos) << (svc)->srv_cpt_bits) |	\
+	 ((u64)(pos) << (svc)->srv_cpt_bits) |		\
 	 ((u64)(pos) >> (64 - (svc)->srv_cpt_bits)))
 
 static void *
 ptlrpc_lprocfs_svc_req_history_start(struct seq_file *s, loff_t *pos)
 {
-	struct ptlrpc_service		*svc = s->private;
-	struct ptlrpc_service_part	*svcpt;
-	struct ptlrpc_srh_iterator	*srhi;
-	unsigned int			cpt;
-	int				rc;
-	int				i;
+	struct ptlrpc_service *svc = s->private;
+	struct ptlrpc_service_part *svcpt;
+	struct ptlrpc_srh_iterator *srhi;
+	unsigned int cpt;
+	int rc;
+	int i;
 
 	if (sizeof(loff_t) != sizeof(u64)) { /* can't support */
 		CWARN("Failed to read request history because size of loff_t %d can't match size of u64\n",
@@ -940,10 +940,10 @@ static int ptlrpc_lprocfs_svc_req_history_show(struct seq_file *s, void *iter)
 ptlrpc_lprocfs_svc_req_history_open(struct inode *inode, struct file *file)
 {
 	static const struct seq_operations sops = {
-		.start = ptlrpc_lprocfs_svc_req_history_start,
-		.stop  = ptlrpc_lprocfs_svc_req_history_stop,
-		.next  = ptlrpc_lprocfs_svc_req_history_next,
-		.show  = ptlrpc_lprocfs_svc_req_history_show,
+		.start	= ptlrpc_lprocfs_svc_req_history_start,
+		.stop	= ptlrpc_lprocfs_svc_req_history_stop,
+		.next	= ptlrpc_lprocfs_svc_req_history_next,
+		.show	= ptlrpc_lprocfs_svc_req_history_show,
 	};
 	struct seq_file *seqf;
 	int rc;
@@ -975,9 +975,9 @@ static int ptlrpc_lprocfs_timeouts_seq_show(struct seq_file *m, void *n)
 	}
 
 	ptlrpc_service_for_each_part(svcpt, i, svc) {
-		cur	= at_get(&svcpt->scp_at_estimate);
-		worst	= svcpt->scp_at_estimate.at_worst_ever;
-		worstt	= svcpt->scp_at_estimate.at_worst_time;
+		cur = at_get(&svcpt->scp_at_estimate);
+		worst = svcpt->scp_at_estimate.at_worst_ever;
+		worstt = svcpt->scp_at_estimate.at_worst_time;
 		s2dhms(&ts, ktime_get_real_seconds() - worstt);
 
 		seq_printf(m, "%10s : cur %3u  worst %3u (at %lld, "
@@ -1074,26 +1074,26 @@ void ptlrpc_ldebugfs_register_service(struct dentry *entry,
 				      struct ptlrpc_service *svc)
 {
 	struct lprocfs_vars lproc_vars[] = {
-		{.name       = "req_buffer_history_len",
-		 .fops	     = &ptlrpc_lprocfs_req_history_len_fops,
-		 .data       = svc},
-		{.name       = "req_buffer_history_max",
-		 .fops	     = &ptlrpc_lprocfs_req_history_max_fops,
-		 .data       = svc},
-		{.name       = "timeouts",
-		 .fops	     = &ptlrpc_lprocfs_timeouts_fops,
-		 .data       = svc},
-		{.name       = "nrs_policies",
-		 .fops	     = &ptlrpc_lprocfs_nrs_fops,
-		 .data	     = svc},
-		{NULL}
+		{ .name		= "req_buffer_history_len",
+		  .fops		= &ptlrpc_lprocfs_req_history_len_fops,
+		  .data		= svc },
+		{ .name		= "req_buffer_history_max",
+		  .fops		= &ptlrpc_lprocfs_req_history_max_fops,
+		  .data		= svc },
+		{ .name		= "timeouts",
+		  .fops		= &ptlrpc_lprocfs_timeouts_fops,
+		  .data		= svc },
+		{ .name		= "nrs_policies",
+		  .fops		= &ptlrpc_lprocfs_nrs_fops,
+		  .data		= svc },
+		{ NULL }
 	};
 	static const struct file_operations req_history_fops = {
-		.owner       = THIS_MODULE,
-		.open	= ptlrpc_lprocfs_svc_req_history_open,
-		.read	= seq_read,
-		.llseek      = seq_lseek,
-		.release     = lprocfs_seq_release,
+		.owner		= THIS_MODULE,
+		.open		= ptlrpc_lprocfs_svc_req_history_open,
+		.read		= seq_read,
+		.llseek		= seq_lseek,
+		.release	= lprocfs_seq_release,
 	};
 
 	ptlrpc_ldebugfs_register(entry, svc->srv_name,
diff --git a/drivers/staging/lustre/lustre/ptlrpc/niobuf.c b/drivers/staging/lustre/lustre/ptlrpc/niobuf.c
index d3044a7..ea7a7f9 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/niobuf.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/niobuf.c
@@ -280,6 +280,7 @@ int ptlrpc_unregister_bulk(struct ptlrpc_request *req, int async)
 		 * timeout lets us CWARN for visibility of sluggish LNDs
 		 */
 		int cnt = 0;
+
 		while (cnt < LONG_UNLINK &&
 		       (rc = wait_event_idle_timeout(*wq,
 						     !ptlrpc_client_bulk_active(req),
@@ -685,7 +686,7 @@ int ptl_send_rpc(struct ptlrpc_request *request, int noreply)
 	 * add the network latency for our local timeout.
 	 */
 	request->rq_deadline = request->rq_sent + request->rq_timeout +
-		ptlrpc_at_get_net_latency(request);
+			       ptlrpc_at_get_net_latency(request);
 
 	ptlrpc_pinger_sending_on_import(imp);
 
@@ -705,7 +706,7 @@ int ptl_send_rpc(struct ptlrpc_request *request, int noreply)
 	if (noreply)
 		goto out;
 
- cleanup_me:
+cleanup_me:
 	/* MEUnlink is safe; the PUT didn't even get off the ground, and
 	 * nobody apart from the PUT's target has the right nid+XID to
 	 * access the reply buffer.
@@ -715,7 +716,7 @@ int ptl_send_rpc(struct ptlrpc_request *request, int noreply)
 	/* UNLINKED callback called synchronously */
 	LASSERT(!request->rq_receiving_reply);
 
- cleanup_bulk:
+cleanup_bulk:
 	/* We do sync unlink here as there was no real transfer here so
 	 * the chance to have long unlink to sluggish net is smaller here.
 	 */
diff --git a/drivers/staging/lustre/lustre/ptlrpc/nrs.c b/drivers/staging/lustre/lustre/ptlrpc/nrs.c
index 248ba04..ef7dd5d 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/nrs.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/nrs.c
@@ -118,7 +118,6 @@ static int nrs_policy_stop_locked(struct ptlrpc_nrs_policy *policy)
 	/* Immediately make it invisible */
 	if (nrs->nrs_policy_primary == policy) {
 		nrs->nrs_policy_primary = NULL;
-
 	} else {
 		LASSERT(nrs->nrs_policy_fallback == policy);
 		nrs->nrs_policy_fallback = NULL;
diff --git a/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_internal.h b/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_internal.h
index 10c2520..5383b68 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_internal.h
+++ b/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_internal.h
@@ -111,12 +111,12 @@ struct nrs_core {
 	 * Protects nrs_core::nrs_policies, serializes external policy
 	 * registration/unregistration, and NRS core lprocfs operations.
 	 */
-	struct mutex nrs_mutex;
+	struct mutex		nrs_mutex;
 	/**
 	 * List of all policy descriptors registered with NRS core; protected
 	 * by nrs_core::nrs_mutex.
 	 */
-	struct list_head nrs_policies;
+	struct list_head	nrs_policies;
 
 };
 
@@ -251,15 +251,15 @@ struct ptlrpc_reply_state *
 void ptlrpc_pinger_wake_up(void);
 
 /* sec_null.c */
-int  sptlrpc_null_init(void);
+int sptlrpc_null_init(void);
 void sptlrpc_null_fini(void);
 
 /* sec_plain.c */
-int  sptlrpc_plain_init(void);
+int sptlrpc_plain_init(void);
 void sptlrpc_plain_fini(void);
 
 /* sec_bulk.c */
-int  sptlrpc_enc_pool_init(void);
+int sptlrpc_enc_pool_init(void);
 void sptlrpc_enc_pool_fini(void);
 int sptlrpc_proc_enc_pool_seq_show(struct seq_file *m, void *v);
 
@@ -277,11 +277,11 @@ void sptlrpc_conf_choose_flavor(enum lustre_sec_part from,
 				struct obd_uuid *target,
 				lnet_nid_t nid,
 				struct sptlrpc_flavor *sf);
-int  sptlrpc_conf_init(void);
+int sptlrpc_conf_init(void);
 void sptlrpc_conf_fini(void);
 
 /* sec.c */
-int  sptlrpc_init(void);
+int sptlrpc_init(void);
 void sptlrpc_fini(void);
 
 /* layout.c */
diff --git a/drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c b/drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c
index e39c38a..f0ac296 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c
@@ -69,13 +69,13 @@
 
 /* One of these per CPT. */
 struct ptlrpcd {
-	int pd_size;
-	int pd_index;
-	int pd_cpt;
-	int pd_cursor;
-	int pd_nthreads;
-	int pd_groupsize;
-	struct ptlrpcd_ctl pd_threads[0];
+	int			pd_size;
+	int			pd_index;
+	int			pd_cpt;
+	int			pd_cursor;
+	int			pd_nthreads;
+	int			pd_groupsize;
+	struct ptlrpcd_ctl	pd_threads[0];
 };
 
 /*
@@ -171,9 +171,9 @@ void ptlrpcd_wake(struct ptlrpc_request *req)
 static struct ptlrpcd_ctl *
 ptlrpcd_select_pc(struct ptlrpc_request *req)
 {
-	struct ptlrpcd	*pd;
-	int		cpt;
-	int		idx;
+	struct ptlrpcd *pd;
+	int cpt;
+	int idx;
 
 	if (req && req->rq_send_state != LUSTRE_IMP_FULL)
 		return &ptlrpcd_rcv;
diff --git a/drivers/staging/lustre/lustre/ptlrpc/recover.c b/drivers/staging/lustre/lustre/ptlrpc/recover.c
index ed769a4..af672ab 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/recover.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/recover.c
@@ -119,6 +119,7 @@ int ptlrpc_replay_next(struct obd_import *imp, int *inflight)
 	 */
 	if (!req) {
 		struct ptlrpc_request *tmp;
+
 		list_for_each_entry_safe(tmp, pos, &imp->imp_replay_list,
 					 rq_replay_list) {
 			if (tmp->rq_transno > last_transno) {
diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec.c b/drivers/staging/lustre/lustre/ptlrpc/sec.c
index 165082a..6dc7731 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/sec.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/sec.c
@@ -171,7 +171,7 @@ u32 sptlrpc_name2flavor_base(const char *name)
 
 const char *sptlrpc_flavor2name_base(u32 flvr)
 {
-	u32   base = SPTLRPC_FLVR_BASE(flvr);
+	u32 base = SPTLRPC_FLVR_BASE(flvr);
 
 	if (base == SPTLRPC_FLVR_BASE(SPTLRPC_FLVR_NULL))
 		return "null";
@@ -365,7 +365,7 @@ int sptlrpc_req_get_ctx(struct ptlrpc_request *req)
 {
 	struct obd_import *imp = req->rq_import;
 	struct ptlrpc_sec *sec;
-	int		rc;
+	int rc;
 
 	LASSERT(!req->rq_cli_ctx);
 	LASSERT(imp);
diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c b/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c
index 93dcb6d..74cfdd8 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c
@@ -57,8 +57,8 @@
 #define POINTERS_PER_PAGE	(PAGE_SIZE / sizeof(void *))
 #define PAGES_PER_POOL		(POINTERS_PER_PAGE)
 
-#define IDLE_IDX_MAX	 (100)
-#define IDLE_IDX_WEIGHT	 (3)
+#define IDLE_IDX_MAX		(100)
+#define IDLE_IDX_WEIGHT		(3)
 
 #define CACHE_QUIESCENT_PERIOD  (20)
 
@@ -66,16 +66,16 @@
 	/*
 	 * constants
 	 */
-	unsigned long    epp_max_pages;   /* maximum pages can hold, const */
-	unsigned int     epp_max_pools;   /* number of pools, const */
+	unsigned long		epp_max_pages;	/* maximum pages can hold, const */
+	unsigned int		epp_max_pools;	/* number of pools, const */
 
 	/*
 	 * wait queue in case of not enough free pages.
 	 */
-	wait_queue_head_t      epp_waitq;       /* waiting threads */
-	unsigned int     epp_waitqlen;    /* wait queue length */
-	unsigned long    epp_pages_short; /* # of pages wanted of in-q users */
-	unsigned int     epp_growing:1;   /* during adding pages */
+	wait_queue_head_t	epp_waitq;	/* waiting threads */
+	unsigned int		epp_waitqlen;	/* wait queue length */
+	unsigned long		epp_pages_short; /* # of pages wanted of in-q users */
+	unsigned int		epp_growing:1;	/* during adding pages */
 
 	/*
 	 * indicating how idle the pools are, from 0 to MAX_IDLE_IDX
@@ -84,36 +84,36 @@
 	 * is idled for a while but the idle_idx might still be low if no
 	 * activities happened in the pools.
 	 */
-	unsigned long    epp_idle_idx;
+	unsigned long		epp_idle_idx;
 
 	/* last shrink time due to mem tight */
-	time64_t         epp_last_shrink;
-	time64_t         epp_last_access;
+	time64_t		epp_last_shrink;
+	time64_t		epp_last_access;
 
 	/*
 	 * in-pool pages bookkeeping
 	 */
-	spinlock_t	 epp_lock;	   /* protect following fields */
-	unsigned long    epp_total_pages; /* total pages in pools */
-	unsigned long    epp_free_pages;  /* current pages available */
+	spinlock_t		epp_lock;	 /* protect following fields */
+	unsigned long		epp_total_pages; /* total pages in pools */
+	unsigned long		epp_free_pages;	 /* current pages available */
 
 	/*
 	 * statistics
 	 */
-	unsigned long    epp_st_max_pages;      /* # of pages ever reached */
-	unsigned int     epp_st_grows;	  /* # of grows */
-	unsigned int     epp_st_grow_fails;     /* # of add pages failures */
-	unsigned int     epp_st_shrinks;	/* # of shrinks */
-	unsigned long    epp_st_access;	 /* # of access */
-	unsigned long    epp_st_missings;       /* # of cache missing */
-	unsigned long    epp_st_lowfree;	/* lowest free pages reached */
-	unsigned int     epp_st_max_wqlen;      /* highest waitqueue length */
-	unsigned long       epp_st_max_wait;       /* in jiffies */
-	unsigned long	 epp_st_outofmem;	/* # of out of mem requests */
+	unsigned long		epp_st_max_pages;	/* # of pages ever reached */
+	unsigned int		epp_st_grows;		/* # of grows */
+	unsigned int		epp_st_grow_fails;	/* # of add pages failures */
+	unsigned int		epp_st_shrinks;		/* # of shrinks */
+	unsigned long		epp_st_access;		/* # of access */
+	unsigned long		epp_st_missings;	/* # of cache missing */
+	unsigned long		epp_st_lowfree;		/* lowest free pages reached */
+	unsigned int		epp_st_max_wqlen;	/* highest waitqueue length */
+	unsigned long		epp_st_max_wait;	/* in jiffies */
+	unsigned long		epp_st_outofmem;	/* # of out of mem requests */
 	/*
 	 * pointers to pools
 	 */
-	struct page    ***epp_pools;
+	struct page		***epp_pools;
 } page_pools;
 
 /*
@@ -394,9 +394,9 @@ static inline void enc_pools_free(void)
 }
 
 static struct shrinker pools_shrinker = {
-	.count_objects	= enc_pools_shrink_count,
-	.scan_objects	= enc_pools_shrink_scan,
-	.seeks		= DEFAULT_SEEKS,
+	.count_objects		= enc_pools_shrink_count,
+	.scan_objects		= enc_pools_shrink_scan,
+	.seeks			= DEFAULT_SEEKS,
 };
 
 int sptlrpc_enc_pool_init(void)
@@ -475,14 +475,14 @@ void sptlrpc_enc_pool_fini(void)
 }
 
 static int cfs_hash_alg_id[] = {
-	[BULK_HASH_ALG_NULL]	= CFS_HASH_ALG_NULL,
-	[BULK_HASH_ALG_ADLER32]	= CFS_HASH_ALG_ADLER32,
-	[BULK_HASH_ALG_CRC32]	= CFS_HASH_ALG_CRC32,
-	[BULK_HASH_ALG_MD5]	= CFS_HASH_ALG_MD5,
-	[BULK_HASH_ALG_SHA1]	= CFS_HASH_ALG_SHA1,
-	[BULK_HASH_ALG_SHA256]	= CFS_HASH_ALG_SHA256,
-	[BULK_HASH_ALG_SHA384]	= CFS_HASH_ALG_SHA384,
-	[BULK_HASH_ALG_SHA512]	= CFS_HASH_ALG_SHA512,
+	[BULK_HASH_ALG_NULL]		= CFS_HASH_ALG_NULL,
+	[BULK_HASH_ALG_ADLER32]		= CFS_HASH_ALG_ADLER32,
+	[BULK_HASH_ALG_CRC32]		= CFS_HASH_ALG_CRC32,
+	[BULK_HASH_ALG_MD5]		= CFS_HASH_ALG_MD5,
+	[BULK_HASH_ALG_SHA1]		= CFS_HASH_ALG_SHA1,
+	[BULK_HASH_ALG_SHA256]		= CFS_HASH_ALG_SHA256,
+	[BULK_HASH_ALG_SHA384]		= CFS_HASH_ALG_SHA384,
+	[BULK_HASH_ALG_SHA512]		= CFS_HASH_ALG_SHA512,
 };
 
 const char *sptlrpc_get_hash_name(u8 hash_alg)
@@ -498,7 +498,7 @@ u8 sptlrpc_get_hash_alg(const char *algname)
 int bulk_sec_desc_unpack(struct lustre_msg *msg, int offset, int swabbed)
 {
 	struct ptlrpc_bulk_sec_desc *bsd;
-	int			  size = msg->lm_buflens[offset];
+	int size = msg->lm_buflens[offset];
 
 	bsd = lustre_msg_buf(msg, offset, sizeof(*bsd));
 	if (!bsd) {
diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec_config.c b/drivers/staging/lustre/lustre/ptlrpc/sec_config.c
index 1844ada..54130ae 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/sec_config.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/sec_config.c
@@ -408,19 +408,19 @@ static int sptlrpc_rule_set_choose(struct sptlrpc_rule_set *rset,
  **********************************/
 
 struct sptlrpc_conf_tgt {
-	struct list_head	      sct_list;
-	char		    sct_name[MAX_OBD_NAME];
-	struct sptlrpc_rule_set sct_rset;
+	struct list_head		sct_list;
+	char				sct_name[MAX_OBD_NAME];
+	struct sptlrpc_rule_set		sct_rset;
 };
 
 struct sptlrpc_conf {
-	struct list_head	      sc_list;
-	char		    sc_fsname[MTI_NAME_MAXLEN];
-	unsigned int	    sc_modified;  /* modified during updating */
-	unsigned int	    sc_updated:1, /* updated copy from MGS */
-				sc_local:1;   /* local copy from target */
-	struct sptlrpc_rule_set sc_rset;      /* fs general rules */
-	struct list_head	      sc_tgts;      /* target-specific rules */
+	struct list_head		sc_list;
+	char				sc_fsname[MTI_NAME_MAXLEN];
+	unsigned int			sc_modified;	/* modified during updating */
+	unsigned int			sc_updated:1,	/* updated copy from MGS */
+					sc_local:1;	/* local copy from target */
+	struct sptlrpc_rule_set		sc_rset;	/* fs general rules */
+	struct list_head		sc_tgts;	/* target-specific rules */
 };
 
 static struct mutex sptlrpc_conf_lock;
@@ -801,7 +801,7 @@ void sptlrpc_conf_choose_flavor(enum lustre_sec_part from,
 	flavor_set_flags(sf, from, to, 1);
 }
 
-#define SEC_ADAPT_DELAY	 (10)
+#define SEC_ADAPT_DELAY		(10)
 
 /**
  * called by client devices, notify the sptlrpc config has changed and
diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec_null.c b/drivers/staging/lustre/lustre/ptlrpc/sec_null.c
index 6933a53..df6ef4f 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/sec_null.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/sec_null.c
@@ -277,8 +277,8 @@ int null_enlarge_reqbuf(struct ptlrpc_sec *sec,
 }
 
 static struct ptlrpc_svc_ctx null_svc_ctx = {
-	.sc_refcount    = ATOMIC_INIT(1),
-	.sc_policy      = &null_policy,
+	.sc_refcount	= ATOMIC_INIT(1),
+	.sc_policy	= &null_policy,
 };
 
 static
@@ -373,33 +373,33 @@ int null_authorize(struct ptlrpc_request *req)
 
 static struct ptlrpc_ctx_ops null_ctx_ops = {
 	.refresh		= null_ctx_refresh,
-	.sign		   = null_ctx_sign,
-	.verify		 = null_ctx_verify,
+	.sign			= null_ctx_sign,
+	.verify			= null_ctx_verify,
 };
 
 static struct ptlrpc_sec_cops null_sec_cops = {
-	.create_sec	     = null_create_sec,
-	.destroy_sec	    = null_destroy_sec,
-	.lookup_ctx	     = null_lookup_ctx,
+	.create_sec		= null_create_sec,
+	.destroy_sec		= null_destroy_sec,
+	.lookup_ctx		= null_lookup_ctx,
 	.flush_ctx_cache	= null_flush_ctx_cache,
-	.alloc_reqbuf	   = null_alloc_reqbuf,
-	.alloc_repbuf	   = null_alloc_repbuf,
-	.free_reqbuf	    = null_free_reqbuf,
-	.free_repbuf	    = null_free_repbuf,
-	.enlarge_reqbuf	 = null_enlarge_reqbuf,
+	.alloc_reqbuf		= null_alloc_reqbuf,
+	.alloc_repbuf		= null_alloc_repbuf,
+	.free_reqbuf		= null_free_reqbuf,
+	.free_repbuf		= null_free_repbuf,
+	.enlarge_reqbuf		= null_enlarge_reqbuf,
 };
 
 static struct ptlrpc_sec_sops null_sec_sops = {
-	.accept		 = null_accept,
-	.alloc_rs	       = null_alloc_rs,
-	.authorize	      = null_authorize,
+	.accept			= null_accept,
+	.alloc_rs		= null_alloc_rs,
+	.authorize		= null_authorize,
 	.free_rs		= null_free_rs,
 };
 
 static struct ptlrpc_sec_policy null_policy = {
-	.sp_owner	       = THIS_MODULE,
+	.sp_owner		= THIS_MODULE,
 	.sp_name		= "sec.null",
-	.sp_policy	      = SPTLRPC_POLICY_NULL,
+	.sp_policy		= SPTLRPC_POLICY_NULL,
 	.sp_cops		= &null_sec_cops,
 	.sp_sops		= &null_sec_sops,
 };
diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec_plain.c b/drivers/staging/lustre/lustre/ptlrpc/sec_plain.c
index 0a31ff4..021bf7f 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/sec_plain.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/sec_plain.c
@@ -46,9 +46,9 @@
 #include "ptlrpc_internal.h"
 
 struct plain_sec {
-	struct ptlrpc_sec       pls_base;
-	rwlock_t	    pls_lock;
-	struct ptlrpc_cli_ctx  *pls_ctx;
+	struct ptlrpc_sec	 pls_base;
+	rwlock_t		 pls_lock;
+	struct ptlrpc_cli_ctx	*pls_ctx;
 };
 
 static inline struct plain_sec *sec2plsec(struct ptlrpc_sec *sec)
@@ -65,15 +65,15 @@ static inline struct plain_sec *sec2plsec(struct ptlrpc_sec *sec)
 /*
  * for simplicity, plain policy rpc use fixed layout.
  */
-#define PLAIN_PACK_SEGMENTS	     (4)
+#define PLAIN_PACK_SEGMENTS	(4)
 
-#define PLAIN_PACK_HDR_OFF	      (0)
-#define PLAIN_PACK_MSG_OFF	      (1)
-#define PLAIN_PACK_USER_OFF	     (2)
-#define PLAIN_PACK_BULK_OFF	     (3)
+#define PLAIN_PACK_HDR_OFF	(0)
+#define PLAIN_PACK_MSG_OFF	(1)
+#define PLAIN_PACK_USER_OFF	(2)
+#define PLAIN_PACK_BULK_OFF	(3)
 
-#define PLAIN_FL_USER		   (0x01)
-#define PLAIN_FL_BULK		   (0x02)
+#define PLAIN_FL_USER		(0x01)
+#define PLAIN_FL_BULK		(0x02)
 
 struct plain_header {
 	u8	    ph_ver;	    /* 0 */
@@ -711,8 +711,8 @@ int plain_enlarge_reqbuf(struct ptlrpc_sec *sec,
  ****************************************/
 
 static struct ptlrpc_svc_ctx plain_svc_ctx = {
-	.sc_refcount    = ATOMIC_INIT(1),
-	.sc_policy      = &plain_policy,
+	.sc_refcount	= ATOMIC_INIT(1),
+	.sc_policy	= &plain_policy,
 };
 
 static
@@ -961,40 +961,40 @@ int plain_svc_wrap_bulk(struct ptlrpc_request *req,
 
 static struct ptlrpc_ctx_ops plain_ctx_ops = {
 	.refresh		= plain_ctx_refresh,
-	.validate	       = plain_ctx_validate,
-	.sign		   = plain_ctx_sign,
-	.verify		 = plain_ctx_verify,
-	.wrap_bulk	      = plain_cli_wrap_bulk,
-	.unwrap_bulk	    = plain_cli_unwrap_bulk,
+	.validate		= plain_ctx_validate,
+	.sign			= plain_ctx_sign,
+	.verify			= plain_ctx_verify,
+	.wrap_bulk		= plain_cli_wrap_bulk,
+	.unwrap_bulk		= plain_cli_unwrap_bulk,
 };
 
 static struct ptlrpc_sec_cops plain_sec_cops = {
-	.create_sec	     = plain_create_sec,
-	.destroy_sec	    = plain_destroy_sec,
-	.kill_sec	       = plain_kill_sec,
-	.lookup_ctx	     = plain_lookup_ctx,
-	.release_ctx	    = plain_release_ctx,
+	.create_sec		= plain_create_sec,
+	.destroy_sec		= plain_destroy_sec,
+	.kill_sec		= plain_kill_sec,
+	.lookup_ctx		= plain_lookup_ctx,
+	.release_ctx		= plain_release_ctx,
 	.flush_ctx_cache	= plain_flush_ctx_cache,
-	.alloc_reqbuf	   = plain_alloc_reqbuf,
-	.free_reqbuf	    = plain_free_reqbuf,
-	.alloc_repbuf	   = plain_alloc_repbuf,
-	.free_repbuf	    = plain_free_repbuf,
-	.enlarge_reqbuf	 = plain_enlarge_reqbuf,
+	.alloc_reqbuf		= plain_alloc_reqbuf,
+	.free_reqbuf		= plain_free_reqbuf,
+	.alloc_repbuf		= plain_alloc_repbuf,
+	.free_repbuf		= plain_free_repbuf,
+	.enlarge_reqbuf		= plain_enlarge_reqbuf,
 };
 
 static struct ptlrpc_sec_sops plain_sec_sops = {
-	.accept		 = plain_accept,
-	.alloc_rs	       = plain_alloc_rs,
-	.authorize	      = plain_authorize,
+	.accept			= plain_accept,
+	.alloc_rs		= plain_alloc_rs,
+	.authorize		= plain_authorize,
 	.free_rs		= plain_free_rs,
-	.unwrap_bulk	    = plain_svc_unwrap_bulk,
-	.wrap_bulk	      = plain_svc_wrap_bulk,
+	.unwrap_bulk		= plain_svc_unwrap_bulk,
+	.wrap_bulk		= plain_svc_wrap_bulk,
 };
 
 static struct ptlrpc_sec_policy plain_policy = {
-	.sp_owner	       = THIS_MODULE,
+	.sp_owner		= THIS_MODULE,
 	.sp_name		= "plain",
-	.sp_policy	      = SPTLRPC_POLICY_PLAIN,
+	.sp_policy		= SPTLRPC_POLICY_PLAIN,
 	.sp_cops		= &plain_sec_cops,
 	.sp_sops		= &plain_sec_sops,
 };
diff --git a/drivers/staging/lustre/lustre/ptlrpc/service.c b/drivers/staging/lustre/lustre/ptlrpc/service.c
index 1030f65..5b97f2a 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/service.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/service.c
@@ -173,7 +173,7 @@
 	       svc->srv_name, i, svc->srv_buf_size, svcpt->scp_nrqbds_posted,
 	       svcpt->scp_nrqbds_total, rc);
 
- try_post:
+try_post:
 	if (post && rc == 0)
 		rc = ptlrpc_server_post_idle_rqbds(svcpt);
 
@@ -185,8 +185,8 @@
 struct ptlrpc_hr_thread {
 	int				hrt_id;		/* thread ID */
 	spinlock_t			hrt_lock;
-	wait_queue_head_t			hrt_waitq;
-	struct list_head			hrt_queue;	/* RS queue */
+	wait_queue_head_t		hrt_waitq;
+	struct list_head		hrt_queue;	/* RS queue */
 	struct ptlrpc_hr_partition	*hrt_partition;
 };
 
@@ -212,7 +212,7 @@ struct ptlrpc_hr_service {
 	/* CPU partition table, it's just cfs_cpt_tab for now */
 	struct cfs_cpt_table		*hr_cpt_table;
 	/** controller sleep waitq */
-	wait_queue_head_t			hr_waitq;
+	wait_queue_head_t		hr_waitq;
 	unsigned int			hr_stopping;
 	/** roundrobin rotor for non-affinity service */
 	unsigned int			hr_rotor;
@@ -236,7 +236,6 @@ struct ptlrpc_hr_service {
 	    svcpt->scp_service->srv_cptable == ptlrpc_hr.hr_cpt_table) {
 		/* directly match partition */
 		hrp = ptlrpc_hr.hr_partitions[svcpt->scp_cpt];
-
 	} else {
 		rotor = ptlrpc_hr.hr_rotor++;
 		rotor %= cfs_cpt_number(ptlrpc_hr.hr_cpt_table);
@@ -440,7 +439,7 @@ static void ptlrpc_at_timer(struct timer_list *t)
 		nthrs = max(tc->tc_nthrs_base,
 			    tc->tc_nthrs_max / svc->srv_ncpts);
 	}
- out:
+out:
 	nthrs = max(nthrs, tc->tc_nthrs_init);
 	svc->srv_nthrs_cpt_limit = nthrs;
 	svc->srv_nthrs_cpt_init = init;
@@ -459,7 +458,7 @@ static void ptlrpc_at_timer(struct timer_list *t)
 ptlrpc_service_part_init(struct ptlrpc_service *svc,
 			 struct ptlrpc_service_part *svcpt, int cpt)
 {
-	struct ptlrpc_at_array	*array;
+	struct ptlrpc_at_array *array;
 	int size;
 	int index;
 	int rc;
@@ -1125,7 +1124,6 @@ static int ptlrpc_at_send_early_reply(struct ptlrpc_request *req)
 		goto out_put;
 
 	rc = ptlrpc_send_reply(reqcopy, PTLRPC_REPLY_EARLY);
-
 	if (!rc) {
 		/* Adjust our own deadline to what we told the client */
 		req->rq_deadline = newdl;
@@ -1316,7 +1314,7 @@ static void ptlrpc_server_hpreq_fini(struct ptlrpc_request *req)
 static int ptlrpc_server_request_add(struct ptlrpc_service_part *svcpt,
 				     struct ptlrpc_request *req)
 {
-	int	rc;
+	int rc;
 
 	rc = ptlrpc_server_hpreq_init(svcpt, req);
 	if (rc < 0)
@@ -2412,7 +2410,7 @@ int ptlrpc_start_threads(struct ptlrpc_service *svc)
 	}
 
 	return 0;
- failed:
+failed:
 	CERROR("cannot start %s thread #%d_%d: rc %d\n",
 	       svc->srv_thread_name, i, j, rc);
 	ptlrpc_stop_all_threads(svc);
@@ -2432,7 +2430,7 @@ int ptlrpc_start_thread(struct ptlrpc_service_part *svcpt, int wait)
 	       svc->srv_name, svcpt->scp_cpt, svcpt->scp_nthrs_running,
 	       svc->srv_nthrs_cpt_init, svc->srv_nthrs_cpt_limit);
 
- again:
+again:
 	if (unlikely(svc->srv_is_stopping))
 		return -ESRCH;
 
-- 
1.8.3.1
