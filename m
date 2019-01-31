From: James Simmons <jsimmons@infradead.org>
Date: Thu, 31 Jan 2019 12:19:08 -0500
Subject: [lustre-devel] [PATCH 04/26] ptlrpc: use kernel types for kernel
 code
In-Reply-To: <1548955170-13456-1-git-send-email-jsimmons@infradead.org>
References: <1548955170-13456-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1548955170-13456-5-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Lustre ptlrpc code was originally both a user land and kernel
implementation. The source contains many types of the form __u32
but since this is mostly kernel code change the types to kernel
internal types.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/ptlrpc/client.c      |  32 +++---
 drivers/staging/lustre/lustre/ptlrpc/events.c      |  10 +-
 drivers/staging/lustre/lustre/ptlrpc/import.c      |  14 +--
 drivers/staging/lustre/lustre/ptlrpc/layout.c      |  18 ++--
 drivers/staging/lustre/lustre/ptlrpc/llog_client.c |   2 +-
 .../staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c    |  30 +++---
 drivers/staging/lustre/lustre/ptlrpc/niobuf.c      |   4 +-
 .../staging/lustre/lustre/ptlrpc/pack_generic.c    | 112 ++++++++++-----------
 .../staging/lustre/lustre/ptlrpc/ptlrpc_internal.h |   4 +-
 drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c     |   2 +-
 drivers/staging/lustre/lustre/ptlrpc/recover.c     |   2 +-
 drivers/staging/lustre/lustre/ptlrpc/sec.c         |  20 ++--
 drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c    |   6 +-
 drivers/staging/lustre/lustre/ptlrpc/sec_null.c    |   6 +-
 drivers/staging/lustre/lustre/ptlrpc/sec_plain.c   |  26 ++---
 drivers/staging/lustre/lustre/ptlrpc/service.c     |  16 +--
 16 files changed, 152 insertions(+), 152 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ptlrpc/client.c b/drivers/staging/lustre/lustre/ptlrpc/client.c
index 110bb5d..f4b3875 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/client.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/client.c
@@ -286,7 +286,7 @@ void ptlrpc_free_bulk(struct ptlrpc_bulk_desc *desc)
  */
 void ptlrpc_at_set_req_timeout(struct ptlrpc_request *req)
 {
-	__u32 serv_est;
+	u32 serv_est;
 	int idx;
 	struct imp_at *at;
 
@@ -690,12 +690,12 @@ static inline void ptlrpc_assign_next_xid(struct ptlrpc_request *req)
 }
 
 int ptlrpc_request_bufs_pack(struct ptlrpc_request *request,
-			     __u32 version, int opcode, char **bufs,
+			     u32 version, int opcode, char **bufs,
 			     struct ptlrpc_cli_ctx *ctx)
 {
 	int count;
 	struct obd_import *imp;
-	__u32 *lengths;
+	u32 *lengths;
 	int rc;
 
 	count = req_capsule_filled_sizes(&request->rq_pill, RCL_CLIENT);
@@ -785,7 +785,7 @@ int ptlrpc_request_bufs_pack(struct ptlrpc_request *request,
  * steps if necessary.
  */
 int ptlrpc_request_pack(struct ptlrpc_request *request,
-			__u32 version, int opcode)
+			u32 version, int opcode)
 {
 	int rc;
 
@@ -917,7 +917,7 @@ void ptlrpc_request_free(struct ptlrpc_request *request)
  */
 struct ptlrpc_request *ptlrpc_request_alloc_pack(struct obd_import *imp,
 						 const struct req_format *format,
-						 __u32 version, int opcode)
+						 u32 version, int opcode)
 {
 	struct ptlrpc_request *req = ptlrpc_request_alloc(imp, format);
 	int rc;
@@ -1186,7 +1186,7 @@ static int ptlrpc_import_delay_req(struct obd_import *imp,
  */
 static bool ptlrpc_console_allow(struct ptlrpc_request *req)
 {
-	__u32 opc;
+	u32 opc;
 
 	LASSERT(req->rq_reqmsg);
 	opc = lustre_msg_get_opc(req->rq_reqmsg);
@@ -1226,7 +1226,7 @@ static int ptlrpc_check_status(struct ptlrpc_request *req)
 	if (lustre_msg_get_type(req->rq_repmsg) == PTL_RPC_MSG_ERR) {
 		struct obd_import *imp = req->rq_import;
 		lnet_nid_t nid = imp->imp_connection->c_peer.nid;
-		__u32 opc = lustre_msg_get_opc(req->rq_reqmsg);
+		u32 opc = lustre_msg_get_opc(req->rq_reqmsg);
 
 		/* -EAGAIN is normal when using POSIX flocks */
 		if (ptlrpc_console_allow(req) &&
@@ -1256,7 +1256,7 @@ static void ptlrpc_save_versions(struct ptlrpc_request *req)
 {
 	struct lustre_msg *repmsg = req->rq_repmsg;
 	struct lustre_msg *reqmsg = req->rq_reqmsg;
-	__u64 *versions = lustre_msg_get_versions(repmsg);
+	u64 *versions = lustre_msg_get_versions(repmsg);
 
 	if (lustre_msg_get_flags(req->rq_reqmsg) & MSG_REPLAY)
 		return;
@@ -1267,7 +1267,7 @@ static void ptlrpc_save_versions(struct ptlrpc_request *req)
 	       versions[0], versions[1]);
 }
 
-__u64 ptlrpc_known_replied_xid(struct obd_import *imp)
+u64 ptlrpc_known_replied_xid(struct obd_import *imp)
 {
 	struct ptlrpc_request *req;
 
@@ -2471,7 +2471,7 @@ void ptlrpc_req_finished(struct ptlrpc_request *request)
 /**
  * Returns xid of a \a request
  */
-__u64 ptlrpc_req_xid(struct ptlrpc_request *request)
+u64 ptlrpc_req_xid(struct ptlrpc_request *request)
 {
 	return request->rq_xid;
 }
@@ -3025,7 +3025,7 @@ void ptlrpc_abort_set(struct ptlrpc_request_set *set)
 	}
 }
 
-static __u64 ptlrpc_last_xid;
+static u64 ptlrpc_last_xid;
 static spinlock_t ptlrpc_last_xid_lock;
 
 /**
@@ -3054,7 +3054,7 @@ void ptlrpc_init_xid(void)
 		ptlrpc_last_xid >>= 2;
 		ptlrpc_last_xid |= (1ULL << 61);
 	} else {
-		ptlrpc_last_xid = (__u64)now << 20;
+		ptlrpc_last_xid = (u64)now << 20;
 	}
 
 	/* Always need to be aligned to a power-of-two for multi-bulk BRW */
@@ -3074,9 +3074,9 @@ void ptlrpc_init_xid(void)
  * This is assumed to be true due to the initial ptlrpc_last_xid
  * value also being initialized to a power-of-two value. LU-1431
  */
-__u64 ptlrpc_next_xid(void)
+u64 ptlrpc_next_xid(void)
 {
-	__u64 next;
+	u64 next;
 
 	spin_lock(&ptlrpc_last_xid_lock);
 	next = ptlrpc_last_xid + PTLRPC_BULK_OPS_COUNT;
@@ -3155,11 +3155,11 @@ void ptlrpc_set_bulk_mbits(struct ptlrpc_request *req)
  * Get a glimpse@what next xid value might have been.
  * Returns possible next xid.
  */
-__u64 ptlrpc_sample_next_xid(void)
+u64 ptlrpc_sample_next_xid(void)
 {
 #if BITS_PER_LONG == 32
 	/* need to avoid possible word tearing on 32-bit systems */
-	__u64 next;
+	u64 next;
 
 	spin_lock(&ptlrpc_last_xid_lock);
 	next = ptlrpc_last_xid + PTLRPC_BULK_OPS_COUNT;
diff --git a/drivers/staging/lustre/lustre/ptlrpc/events.c b/drivers/staging/lustre/lustre/ptlrpc/events.c
index ab6dd74..0c16a2c 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/events.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/events.c
@@ -253,9 +253,9 @@ void client_bulk_callback(struct lnet_event *ev)
 static void ptlrpc_req_add_history(struct ptlrpc_service_part *svcpt,
 				   struct ptlrpc_request *req)
 {
-	__u64 sec = req->rq_arrival_time.tv_sec;
-	__u32 usec = req->rq_arrival_time.tv_nsec / NSEC_PER_USEC / 16; /* usec / 16 */
-	__u64 new_seq;
+	u64 sec = req->rq_arrival_time.tv_sec;
+	u32 usec = req->rq_arrival_time.tv_nsec / NSEC_PER_USEC / 16; /* usec / 16 */
+	u64 new_seq;
 
 	/* set sequence ID for request and add it to history list,
 	 * it must be called with hold svcpt::scp_lock
@@ -453,11 +453,11 @@ int ptlrpc_uuid_to_peer(struct obd_uuid *uuid,
 			struct lnet_process_id *peer, lnet_nid_t *self)
 {
 	int best_dist = 0;
-	__u32 best_order = 0;
+	u32 best_order = 0;
 	int count = 0;
 	int rc = -ENOENT;
 	int dist;
-	__u32 order;
+	u32 order;
 	lnet_nid_t dst_nid;
 	lnet_nid_t src_nid;
 
diff --git a/drivers/staging/lustre/lustre/ptlrpc/import.c b/drivers/staging/lustre/lustre/ptlrpc/import.c
index 480c860d..56a0b76 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/import.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/import.c
@@ -51,7 +51,7 @@
 #include "ptlrpc_internal.h"
 
 struct ptlrpc_connect_async_args {
-	 __u64 pcaa_peer_committed;
+	 u64 pcaa_peer_committed;
 	int pcaa_initial_connect;
 };
 
@@ -154,7 +154,7 @@ static void deuuidify(char *uuid, const char *prefix, char **uuid_start,
  *	     (increasing the import->conn_cnt) the older failure should
  *	     not also cause a reconnection.  If zero it forces a reconnect.
  */
-int ptlrpc_set_import_discon(struct obd_import *imp, __u32 conn_cnt)
+int ptlrpc_set_import_discon(struct obd_import *imp, u32 conn_cnt)
 {
 	int rc = 0;
 
@@ -399,7 +399,7 @@ void ptlrpc_pinger_force(struct obd_import *imp)
 }
 EXPORT_SYMBOL(ptlrpc_pinger_force);
 
-void ptlrpc_fail_import(struct obd_import *imp, __u32 conn_cnt)
+void ptlrpc_fail_import(struct obd_import *imp, u32 conn_cnt)
 {
 	LASSERT(!imp->imp_dlm_fake);
 
@@ -547,7 +547,7 @@ static int import_select_connection(struct obd_import *imp)
 /*
  * must be called under imp_lock
  */
-static int ptlrpc_first_transno(struct obd_import *imp, __u64 *transno)
+static int ptlrpc_first_transno(struct obd_import *imp, u64 *transno)
 {
 	struct ptlrpc_request *req;
 
@@ -589,7 +589,7 @@ int ptlrpc_connect_import(struct obd_import *imp)
 	struct obd_device *obd = imp->imp_obd;
 	int initial_connect = 0;
 	int set_transno = 0;
-	__u64 committed_before_reconnect = 0;
+	u64 committed_before_reconnect = 0;
 	struct ptlrpc_request *request;
 	char *bufs[] = { NULL,
 			 obd2cli_tgt(imp->imp_obd),
@@ -686,7 +686,7 @@ int ptlrpc_connect_import(struct obd_import *imp)
 	/* Allow a slightly larger reply for future growth compatibility */
 	req_capsule_set_size(&request->rq_pill, &RMF_CONNECT_DATA, RCL_SERVER,
 			     sizeof(struct obd_connect_data) +
-			     16 * sizeof(__u64));
+			     16 * sizeof(u64));
 	ptlrpc_request_set_replen(request);
 	request->rq_interpret_reply = ptlrpc_connect_interpret;
 
@@ -936,7 +936,7 @@ static int ptlrpc_connect_interpret(const struct lu_env *env,
 	struct ptlrpc_connect_async_args *aa = data;
 	struct obd_import *imp = request->rq_import;
 	struct lustre_handle old_hdl;
-	__u64 old_connect_flags;
+	u64 old_connect_flags;
 	int msg_flags;
 	struct obd_connect_data *ocd;
 	struct obd_export *exp;
diff --git a/drivers/staging/lustre/lustre/ptlrpc/layout.c b/drivers/staging/lustre/lustre/ptlrpc/layout.c
index a155200..2848f2f 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/layout.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/layout.c
@@ -768,7 +768,7 @@
 };
 
 struct req_msg_field {
-	const __u32 rmf_flags;
+	const u32 rmf_flags;
 	const char  *rmf_name;
 	/**
 	 * Field length. (-1) means "variable length".  If the
@@ -842,7 +842,7 @@ struct req_msg_field RMF_MGS_CONFIG_RES =
 
 struct req_msg_field RMF_U32 =
 	DEFINE_MSGF("generic u32", 0,
-		    sizeof(__u32), lustre_swab_generic_32s, NULL);
+		    sizeof(u32), lustre_swab_generic_32s, NULL);
 EXPORT_SYMBOL(RMF_U32);
 
 struct req_msg_field RMF_SETINFO_VAL =
@@ -855,7 +855,7 @@ struct req_msg_field RMF_GETINFO_KEY =
 
 struct req_msg_field RMF_GETINFO_VALLEN =
 	DEFINE_MSGF("getinfo_vallen", 0,
-		    sizeof(__u32), lustre_swab_generic_32s, NULL);
+		    sizeof(u32), lustre_swab_generic_32s, NULL);
 EXPORT_SYMBOL(RMF_GETINFO_VALLEN);
 
 struct req_msg_field RMF_GETINFO_VAL =
@@ -864,7 +864,7 @@ struct req_msg_field RMF_GETINFO_VAL =
 
 struct req_msg_field RMF_SEQ_OPC =
 	DEFINE_MSGF("seq_query_opc", 0,
-		    sizeof(__u32), lustre_swab_generic_32s, NULL);
+		    sizeof(u32), lustre_swab_generic_32s, NULL);
 EXPORT_SYMBOL(RMF_SEQ_OPC);
 
 struct req_msg_field RMF_SEQ_RANGE =
@@ -875,7 +875,7 @@ struct req_msg_field RMF_SEQ_RANGE =
 
 struct req_msg_field RMF_FLD_OPC =
 	DEFINE_MSGF("fld_query_opc", 0,
-		    sizeof(__u32), lustre_swab_generic_32s, NULL);
+		    sizeof(u32), lustre_swab_generic_32s, NULL);
 EXPORT_SYMBOL(RMF_FLD_OPC);
 
 struct req_msg_field RMF_FLD_MDFLD =
@@ -1069,12 +1069,12 @@ struct req_msg_field RMF_NIOBUF_REMOTE =
 EXPORT_SYMBOL(RMF_NIOBUF_REMOTE);
 
 struct req_msg_field RMF_RCS =
-	DEFINE_MSGF("niobuf_remote", RMF_F_STRUCT_ARRAY, sizeof(__u32),
+	DEFINE_MSGF("niobuf_remote", RMF_F_STRUCT_ARRAY, sizeof(u32),
 		    lustre_swab_generic_32s, dump_rcs);
 EXPORT_SYMBOL(RMF_RCS);
 
 struct req_msg_field RMF_EAVALS_LENS =
-	DEFINE_MSGF("eavals_lens", RMF_F_STRUCT_ARRAY, sizeof(__u32),
+	DEFINE_MSGF("eavals_lens", RMF_F_STRUCT_ARRAY, sizeof(u32),
 		    lustre_swab_generic_32s, NULL);
 EXPORT_SYMBOL(RMF_EAVALS_LENS);
 
@@ -1130,7 +1130,7 @@ struct req_msg_field RMF_MDS_HSM_USER_ITEM =
 
 struct req_msg_field RMF_MDS_HSM_ARCHIVE =
 	DEFINE_MSGF("hsm_archive", 0,
-		    sizeof(__u32), lustre_swab_generic_32s, NULL);
+		    sizeof(u32), lustre_swab_generic_32s, NULL);
 EXPORT_SYMBOL(RMF_MDS_HSM_ARCHIVE);
 
 struct req_msg_field RMF_MDS_HSM_REQUEST =
@@ -2129,7 +2129,7 @@ u32 req_capsule_msg_size(struct req_capsule *pill, enum req_location loc)
  * This function should not be used for formats which contain variable size
  * fields.
  */
-u32 req_capsule_fmt_size(__u32 magic, const struct req_format *fmt,
+u32 req_capsule_fmt_size(u32 magic, const struct req_format *fmt,
 			 enum req_location loc)
 {
 	size_t i = 0;
diff --git a/drivers/staging/lustre/lustre/ptlrpc/llog_client.c b/drivers/staging/lustre/lustre/ptlrpc/llog_client.c
index 6ddd93c..8ca6959 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/llog_client.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/llog_client.c
@@ -142,7 +142,7 @@ static int llog_client_open(const struct lu_env *env,
 static int llog_client_next_block(const struct lu_env *env,
 				  struct llog_handle *loghandle,
 				  int *cur_idx, int next_idx,
-				  __u64 *cur_offset, void *buf, int len)
+				  u64 *cur_offset, void *buf, int len)
 {
 	struct obd_import *imp;
 	struct ptlrpc_request *req = NULL;
diff --git a/drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c b/drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c
index cce86c4..92e3e0f 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c
@@ -42,7 +42,7 @@
 #include "ptlrpc_internal.h"
 
 static struct ll_rpc_opcode {
-	__u32       opcode;
+	u32       opcode;
 	const char *opname;
 } ll_rpc_opcode_table[LUSTRE_MAX_OPCODES] = {
 	{ OST_REPLY,	"ost_reply" },
@@ -134,7 +134,7 @@
 };
 
 static struct ll_eopcode {
-	__u32       opcode;
+	u32       opcode;
 	const char *opname;
 } ll_eopcode_table[EXTRA_LAST_OPC] = {
 	{ LDLM_GLIMPSE_ENQUEUE, "ldlm_glimpse_enqueue" },
@@ -153,7 +153,7 @@
 	{ BRW_WRITE_BYTES,      "write_bytes" },
 };
 
-const char *ll_opcode2str(__u32 opcode)
+const char *ll_opcode2str(u32 opcode)
 {
 	/* When one of the assertions below fail, chances are that:
 	 *     1) A new opcode was added in include/lustre/lustre_idl.h,
@@ -162,7 +162,7 @@ const char *ll_opcode2str(__u32 opcode)
 	 *	and the opcode_offset() function in
 	 *	ptlrpc_internal.h needs to be modified.
 	 */
-	__u32 offset = opcode_offset(opcode);
+	u32 offset = opcode_offset(opcode);
 
 	LASSERTF(offset < LUSTRE_MAX_OPCODES,
 		 "offset %u >= LUSTRE_MAX_OPCODES %u\n",
@@ -173,7 +173,7 @@ const char *ll_opcode2str(__u32 opcode)
 	return ll_rpc_opcode_table[offset].opname;
 }
 
-static const char *ll_eopcode2str(__u32 opcode)
+static const char *ll_eopcode2str(u32 opcode)
 {
 	LASSERT(ll_eopcode_table[opcode].opcode == opcode);
 	return ll_eopcode_table[opcode].opname;
@@ -231,7 +231,7 @@ static const char *ll_eopcode2str(__u32 opcode)
 				     ll_eopcode2str(i), units);
 	}
 	for (i = 0; i < LUSTRE_MAX_OPCODES; i++) {
-		__u32 opcode = ll_rpc_opcode_table[i].opcode;
+		u32 opcode = ll_rpc_opcode_table[i].opcode;
 
 		lprocfs_counter_init(svc_stats,
 				     EXTRA_MAX_OPCODES + i, svc_counter_config,
@@ -709,14 +709,14 @@ static ssize_t ptlrpc_lprocfs_nrs_seq_write(struct file *file,
 
 struct ptlrpc_srh_iterator {
 	int			srhi_idx;
-	__u64			srhi_seq;
+	u64			srhi_seq;
 	struct ptlrpc_request	*srhi_req;
 };
 
 static int
 ptlrpc_lprocfs_svc_req_history_seek(struct ptlrpc_service_part *svcpt,
 				    struct ptlrpc_srh_iterator *srhi,
-				    __u64 seq)
+				    u64 seq)
 {
 	struct list_head *e;
 	struct ptlrpc_request *req;
@@ -772,7 +772,7 @@ struct ptlrpc_srh_iterator {
 /* convert seq_file pos to cpt */
 #define PTLRPC_REQ_POS2CPT(svc, pos)			\
 	((svc)->srv_cpt_bits == 0 ? 0 :			\
-	 (__u64)(pos) >> (64 - (svc)->srv_cpt_bits))
+	 (u64)(pos) >> (64 - (svc)->srv_cpt_bits))
 
 /* make up seq_file pos from cpt */
 #define PTLRPC_REQ_CPT2POS(svc, cpt)			\
@@ -788,8 +788,8 @@ struct ptlrpc_srh_iterator {
 /* convert position to sequence */
 #define PTLRPC_REQ_POS2SEQ(svc, pos)			\
 	((svc)->srv_cpt_bits == 0 ? (pos) :		\
-	 ((__u64)(pos) << (svc)->srv_cpt_bits) |	\
-	 ((__u64)(pos) >> (64 - (svc)->srv_cpt_bits)))
+	 ((u64)(pos) << (svc)->srv_cpt_bits) |	\
+	 ((u64)(pos) >> (64 - (svc)->srv_cpt_bits)))
 
 static void *
 ptlrpc_lprocfs_svc_req_history_start(struct seq_file *s, loff_t *pos)
@@ -801,7 +801,7 @@ struct ptlrpc_srh_iterator {
 	int				rc;
 	int				i;
 
-	if (sizeof(loff_t) != sizeof(__u64)) { /* can't support */
+	if (sizeof(loff_t) != sizeof(u64)) { /* can't support */
 		CWARN("Failed to read request history because size of loff_t %d can't match size of u64\n",
 		      (int)sizeof(loff_t));
 		return NULL;
@@ -852,7 +852,7 @@ struct ptlrpc_srh_iterator {
 	struct ptlrpc_service *svc = s->private;
 	struct ptlrpc_srh_iterator *srhi = iter;
 	struct ptlrpc_service_part *svcpt;
-	__u64 seq;
+	u64 seq;
 	int rc;
 	int i;
 
@@ -1120,7 +1120,7 @@ void ptlrpc_lprocfs_register_obd(struct obd_device *obddev)
 void ptlrpc_lprocfs_rpc_sent(struct ptlrpc_request *req, long amount)
 {
 	struct lprocfs_stats *svc_stats;
-	__u32 op = lustre_msg_get_opc(req->rq_reqmsg);
+	u32 op = lustre_msg_get_opc(req->rq_reqmsg);
 	int opc = opcode_offset(op);
 
 	svc_stats = req->rq_import->imp_obd->obd_svc_stats;
@@ -1243,7 +1243,7 @@ int lprocfs_wr_import(struct file *file, const char __user *buffer,
 	uuid = kbuf + prefix_len;
 	ptr = strstr(uuid, "::");
 	if (ptr) {
-		__u32 inst;
+		u32 inst;
 		char *endptr;
 
 		*ptr = 0;
diff --git a/drivers/staging/lustre/lustre/ptlrpc/niobuf.c b/drivers/staging/lustre/lustre/ptlrpc/niobuf.c
index 7e7db24..d3044a7 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/niobuf.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/niobuf.c
@@ -48,7 +48,7 @@
 static int ptl_send_buf(struct lnet_handle_md *mdh, void *base, int len,
 			enum lnet_ack_req ack, struct ptlrpc_cb_id *cbid,
 			lnet_nid_t self, struct lnet_process_id peer_id,
-			int portal, __u64 xid, unsigned int offset,
+			int portal, u64 xid, unsigned int offset,
 			struct lnet_handle_md *bulk_cookie)
 {
 	int rc;
@@ -530,7 +530,7 @@ int ptl_send_rpc(struct ptlrpc_request *request, int noreply)
 	 * from the resend for reply timeout.
 	 */
 	if (request->rq_nr_resend && list_empty(&request->rq_unreplied_list)) {
-		__u64 min_xid = 0;
+		u64 min_xid = 0;
 		/*
 		 * resend for EINPROGRESS, allocate new xid to avoid reply
 		 * reconstruction
diff --git a/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c b/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
index 5fadd5e..1fadba2 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
@@ -58,7 +58,7 @@ static inline u32 lustre_msg_hdr_size_v2(u32 count)
 				       lm_buflens[count]));
 }
 
-u32 lustre_msg_hdr_size(__u32 magic, u32 count)
+u32 lustre_msg_hdr_size(u32 magic, u32 count)
 {
 	switch (magic) {
 	case LUSTRE_MSG_MAGIC_V2:
@@ -102,7 +102,7 @@ u32 lustre_msg_early_size(void)
 		 * XXX Remove this whenever we drop interoperability with such
 		 *     client.
 		 */
-		__u32 pblen = sizeof(struct ptlrpc_body_v2);
+		u32 pblen = sizeof(struct ptlrpc_body_v2);
 
 		size = lustre_msg_size(LUSTRE_MSG_MAGIC_V2, 1, &pblen);
 	}
@@ -110,7 +110,7 @@ u32 lustre_msg_early_size(void)
 }
 EXPORT_SYMBOL(lustre_msg_early_size);
 
-u32 lustre_msg_size_v2(int count, __u32 *lengths)
+u32 lustre_msg_size_v2(int count, u32 *lengths)
 {
 	u32 size;
 	int i;
@@ -130,9 +130,9 @@ u32 lustre_msg_size_v2(int count, __u32 *lengths)
  *       target then the first buffer will be stripped because the ptlrpc
  *       data is part of the lustre_msg_v1 header. b=14043
  */
-u32 lustre_msg_size(__u32 magic, int count, __u32 *lens)
+u32 lustre_msg_size(u32 magic, int count, u32 *lens)
 {
-	__u32 size[] = { sizeof(struct ptlrpc_body) };
+	u32 size[] = { sizeof(struct ptlrpc_body) };
 
 	if (!lens) {
 		LASSERT(count == 1);
@@ -165,7 +165,7 @@ u32 lustre_packed_msg_size(struct lustre_msg *msg)
 	}
 }
 
-void lustre_init_msg_v2(struct lustre_msg_v2 *msg, int count, __u32 *lens,
+void lustre_init_msg_v2(struct lustre_msg_v2 *msg, int count, u32 *lens,
 			char **bufs)
 {
 	char *ptr;
@@ -193,7 +193,7 @@ void lustre_init_msg_v2(struct lustre_msg_v2 *msg, int count, __u32 *lens,
 EXPORT_SYMBOL(lustre_init_msg_v2);
 
 static int lustre_pack_request_v2(struct ptlrpc_request *req,
-				  int count, __u32 *lens, char **bufs)
+				  int count, u32 *lens, char **bufs)
 {
 	int reqlen, rc;
 
@@ -210,10 +210,10 @@ static int lustre_pack_request_v2(struct ptlrpc_request *req,
 	return 0;
 }
 
-int lustre_pack_request(struct ptlrpc_request *req, __u32 magic, int count,
-			__u32 *lens, char **bufs)
+int lustre_pack_request(struct ptlrpc_request *req, u32 magic, int count,
+			u32 *lens, char **bufs)
 {
-	__u32 size[] = { sizeof(struct ptlrpc_body) };
+	u32 size[] = { sizeof(struct ptlrpc_body) };
 
 	if (!lens) {
 		LASSERT(count == 1);
@@ -297,7 +297,7 @@ void lustre_put_emerg_rs(struct ptlrpc_reply_state *rs)
 }
 
 int lustre_pack_reply_v2(struct ptlrpc_request *req, int count,
-			 __u32 *lens, char **bufs, int flags)
+			 u32 *lens, char **bufs, int flags)
 {
 	struct ptlrpc_reply_state *rs;
 	int msg_len, rc;
@@ -338,11 +338,11 @@ int lustre_pack_reply_v2(struct ptlrpc_request *req, int count,
 }
 EXPORT_SYMBOL(lustre_pack_reply_v2);
 
-int lustre_pack_reply_flags(struct ptlrpc_request *req, int count, __u32 *lens,
+int lustre_pack_reply_flags(struct ptlrpc_request *req, int count, u32 *lens,
 			    char **bufs, int flags)
 {
 	int rc = 0;
-	__u32 size[] = { sizeof(struct ptlrpc_body) };
+	u32 size[] = { sizeof(struct ptlrpc_body) };
 
 	if (!lens) {
 		LASSERT(count == 1);
@@ -367,7 +367,7 @@ int lustre_pack_reply_flags(struct ptlrpc_request *req, int count, __u32 *lens,
 	return rc;
 }
 
-int lustre_pack_reply(struct ptlrpc_request *req, int count, __u32 *lens,
+int lustre_pack_reply(struct ptlrpc_request *req, int count, u32 *lens,
 		      char **bufs)
 {
 	return lustre_pack_reply_flags(req, count, lens, bufs, 0);
@@ -749,7 +749,7 @@ static inline struct ptlrpc_body *lustre_msg_ptlrpc_body(struct lustre_msg *msg)
 				 sizeof(struct ptlrpc_body_v2));
 }
 
-__u32 lustre_msghdr_get_flags(struct lustre_msg *msg)
+u32 lustre_msghdr_get_flags(struct lustre_msg *msg)
 {
 	switch (msg->lm_magic) {
 	case LUSTRE_MSG_MAGIC_V2:
@@ -762,7 +762,7 @@ __u32 lustre_msghdr_get_flags(struct lustre_msg *msg)
 }
 EXPORT_SYMBOL(lustre_msghdr_get_flags);
 
-void lustre_msghdr_set_flags(struct lustre_msg *msg, __u32 flags)
+void lustre_msghdr_set_flags(struct lustre_msg *msg, u32 flags)
 {
 	switch (msg->lm_magic) {
 	case LUSTRE_MSG_MAGIC_V2:
@@ -773,7 +773,7 @@ void lustre_msghdr_set_flags(struct lustre_msg *msg, __u32 flags)
 	}
 }
 
-__u32 lustre_msg_get_flags(struct lustre_msg *msg)
+u32 lustre_msg_get_flags(struct lustre_msg *msg)
 {
 	switch (msg->lm_magic) {
 	case LUSTRE_MSG_MAGIC_V2: {
@@ -841,7 +841,7 @@ void lustre_msg_clear_flags(struct lustre_msg *msg, u32 flags)
 }
 EXPORT_SYMBOL(lustre_msg_clear_flags);
 
-__u32 lustre_msg_get_op_flags(struct lustre_msg *msg)
+u32 lustre_msg_get_op_flags(struct lustre_msg *msg)
 {
 	switch (msg->lm_magic) {
 	case LUSTRE_MSG_MAGIC_V2: {
@@ -892,7 +892,7 @@ struct lustre_handle *lustre_msg_get_handle(struct lustre_msg *msg)
 	}
 }
 
-__u32 lustre_msg_get_type(struct lustre_msg *msg)
+u32 lustre_msg_get_type(struct lustre_msg *msg)
 {
 	switch (msg->lm_magic) {
 	case LUSTRE_MSG_MAGIC_V2: {
@@ -926,7 +926,7 @@ void lustre_msg_add_version(struct lustre_msg *msg, u32 version)
 	}
 }
 
-__u32 lustre_msg_get_opc(struct lustre_msg *msg)
+u32 lustre_msg_get_opc(struct lustre_msg *msg)
 {
 	switch (msg->lm_magic) {
 	case LUSTRE_MSG_MAGIC_V2: {
@@ -946,7 +946,7 @@ __u32 lustre_msg_get_opc(struct lustre_msg *msg)
 }
 EXPORT_SYMBOL(lustre_msg_get_opc);
 
-__u16 lustre_msg_get_tag(struct lustre_msg *msg)
+u16 lustre_msg_get_tag(struct lustre_msg *msg)
 {
 	switch (msg->lm_magic) {
 	case LUSTRE_MSG_MAGIC_V2: {
@@ -965,7 +965,7 @@ __u16 lustre_msg_get_tag(struct lustre_msg *msg)
 }
 EXPORT_SYMBOL(lustre_msg_get_tag);
 
-__u64 lustre_msg_get_last_committed(struct lustre_msg *msg)
+u64 lustre_msg_get_last_committed(struct lustre_msg *msg)
 {
 	switch (msg->lm_magic) {
 	case LUSTRE_MSG_MAGIC_V2: {
@@ -984,7 +984,7 @@ __u64 lustre_msg_get_last_committed(struct lustre_msg *msg)
 }
 EXPORT_SYMBOL(lustre_msg_get_last_committed);
 
-__u64 *lustre_msg_get_versions(struct lustre_msg *msg)
+u64 *lustre_msg_get_versions(struct lustre_msg *msg)
 {
 	switch (msg->lm_magic) {
 	case LUSTRE_MSG_MAGIC_V2: {
@@ -1003,7 +1003,7 @@ __u64 *lustre_msg_get_versions(struct lustre_msg *msg)
 }
 EXPORT_SYMBOL(lustre_msg_get_versions);
 
-__u64 lustre_msg_get_transno(struct lustre_msg *msg)
+u64 lustre_msg_get_transno(struct lustre_msg *msg)
 {
 	switch (msg->lm_magic) {
 	case LUSTRE_MSG_MAGIC_V2: {
@@ -1043,7 +1043,7 @@ int lustre_msg_get_status(struct lustre_msg *msg)
 }
 EXPORT_SYMBOL(lustre_msg_get_status);
 
-__u64 lustre_msg_get_slv(struct lustre_msg *msg)
+u64 lustre_msg_get_slv(struct lustre_msg *msg)
 {
 	switch (msg->lm_magic) {
 	case LUSTRE_MSG_MAGIC_V2: {
@@ -1061,7 +1061,7 @@ __u64 lustre_msg_get_slv(struct lustre_msg *msg)
 	}
 }
 
-void lustre_msg_set_slv(struct lustre_msg *msg, __u64 slv)
+void lustre_msg_set_slv(struct lustre_msg *msg, u64 slv)
 {
 	switch (msg->lm_magic) {
 	case LUSTRE_MSG_MAGIC_V2: {
@@ -1080,7 +1080,7 @@ void lustre_msg_set_slv(struct lustre_msg *msg, __u64 slv)
 	}
 }
 
-__u32 lustre_msg_get_limit(struct lustre_msg *msg)
+u32 lustre_msg_get_limit(struct lustre_msg *msg)
 {
 	switch (msg->lm_magic) {
 	case LUSTRE_MSG_MAGIC_V2: {
@@ -1098,7 +1098,7 @@ __u32 lustre_msg_get_limit(struct lustre_msg *msg)
 	}
 }
 
-void lustre_msg_set_limit(struct lustre_msg *msg, __u64 limit)
+void lustre_msg_set_limit(struct lustre_msg *msg, u64 limit)
 {
 	switch (msg->lm_magic) {
 	case LUSTRE_MSG_MAGIC_V2: {
@@ -1117,7 +1117,7 @@ void lustre_msg_set_limit(struct lustre_msg *msg, __u64 limit)
 	}
 }
 
-__u32 lustre_msg_get_conn_cnt(struct lustre_msg *msg)
+u32 lustre_msg_get_conn_cnt(struct lustre_msg *msg)
 {
 	switch (msg->lm_magic) {
 	case LUSTRE_MSG_MAGIC_V2: {
@@ -1136,7 +1136,7 @@ __u32 lustre_msg_get_conn_cnt(struct lustre_msg *msg)
 }
 EXPORT_SYMBOL(lustre_msg_get_conn_cnt);
 
-__u32 lustre_msg_get_magic(struct lustre_msg *msg)
+u32 lustre_msg_get_magic(struct lustre_msg *msg)
 {
 	switch (msg->lm_magic) {
 	case LUSTRE_MSG_MAGIC_V2:
@@ -1147,7 +1147,7 @@ __u32 lustre_msg_get_magic(struct lustre_msg *msg)
 	}
 }
 
-__u32 lustre_msg_get_timeout(struct lustre_msg *msg)
+u32 lustre_msg_get_timeout(struct lustre_msg *msg)
 {
 	switch (msg->lm_magic) {
 	case LUSTRE_MSG_MAGIC_V2: {
@@ -1165,7 +1165,7 @@ __u32 lustre_msg_get_timeout(struct lustre_msg *msg)
 	}
 }
 
-__u32 lustre_msg_get_service_time(struct lustre_msg *msg)
+u32 lustre_msg_get_service_time(struct lustre_msg *msg)
 {
 	switch (msg->lm_magic) {
 	case LUSTRE_MSG_MAGIC_V2: {
@@ -1183,7 +1183,7 @@ __u32 lustre_msg_get_service_time(struct lustre_msg *msg)
 	}
 }
 
-__u32 lustre_msg_get_cksum(struct lustre_msg *msg)
+u32 lustre_msg_get_cksum(struct lustre_msg *msg)
 {
 	switch (msg->lm_magic) {
 	case LUSTRE_MSG_MAGIC_V2:
@@ -1194,12 +1194,12 @@ __u32 lustre_msg_get_cksum(struct lustre_msg *msg)
 	}
 }
 
-__u32 lustre_msg_calc_cksum(struct lustre_msg *msg)
+u32 lustre_msg_calc_cksum(struct lustre_msg *msg)
 {
 	switch (msg->lm_magic) {
 	case LUSTRE_MSG_MAGIC_V2: {
 		struct ptlrpc_body *pb = lustre_msg_ptlrpc_body(msg);
-		__u32 crc;
+		u32 crc;
 		unsigned int hsize = 4;
 
 		cfs_crypto_hash_digest(CFS_HASH_ALG_CRC32, (unsigned char *)pb,
@@ -1229,7 +1229,7 @@ void lustre_msg_set_handle(struct lustre_msg *msg, struct lustre_handle *handle)
 	}
 }
 
-void lustre_msg_set_type(struct lustre_msg *msg, __u32 type)
+void lustre_msg_set_type(struct lustre_msg *msg, u32 type)
 {
 	switch (msg->lm_magic) {
 	case LUSTRE_MSG_MAGIC_V2: {
@@ -1244,7 +1244,7 @@ void lustre_msg_set_type(struct lustre_msg *msg, __u32 type)
 	}
 }
 
-void lustre_msg_set_opc(struct lustre_msg *msg, __u32 opc)
+void lustre_msg_set_opc(struct lustre_msg *msg, u32 opc)
 {
 	switch (msg->lm_magic) {
 	case LUSTRE_MSG_MAGIC_V2: {
@@ -1274,7 +1274,7 @@ void lustre_msg_set_last_xid(struct lustre_msg *msg, u64 last_xid)
 	}
 }
 
-void lustre_msg_set_tag(struct lustre_msg *msg, __u16 tag)
+void lustre_msg_set_tag(struct lustre_msg *msg, u16 tag)
 {
 	switch (msg->lm_magic) {
 	case LUSTRE_MSG_MAGIC_V2: {
@@ -1290,7 +1290,7 @@ void lustre_msg_set_tag(struct lustre_msg *msg, __u16 tag)
 }
 EXPORT_SYMBOL(lustre_msg_set_tag);
 
-void lustre_msg_set_versions(struct lustre_msg *msg, __u64 *versions)
+void lustre_msg_set_versions(struct lustre_msg *msg, u64 *versions)
 {
 	switch (msg->lm_magic) {
 	case LUSTRE_MSG_MAGIC_V2: {
@@ -1309,7 +1309,7 @@ void lustre_msg_set_versions(struct lustre_msg *msg, __u64 *versions)
 }
 EXPORT_SYMBOL(lustre_msg_set_versions);
 
-void lustre_msg_set_transno(struct lustre_msg *msg, __u64 transno)
+void lustre_msg_set_transno(struct lustre_msg *msg, u64 transno)
 {
 	switch (msg->lm_magic) {
 	case LUSTRE_MSG_MAGIC_V2: {
@@ -1325,7 +1325,7 @@ void lustre_msg_set_transno(struct lustre_msg *msg, __u64 transno)
 }
 EXPORT_SYMBOL(lustre_msg_set_transno);
 
-void lustre_msg_set_status(struct lustre_msg *msg, __u32 status)
+void lustre_msg_set_status(struct lustre_msg *msg, u32 status)
 {
 	switch (msg->lm_magic) {
 	case LUSTRE_MSG_MAGIC_V2: {
@@ -1341,7 +1341,7 @@ void lustre_msg_set_status(struct lustre_msg *msg, __u32 status)
 }
 EXPORT_SYMBOL(lustre_msg_set_status);
 
-void lustre_msg_set_conn_cnt(struct lustre_msg *msg, __u32 conn_cnt)
+void lustre_msg_set_conn_cnt(struct lustre_msg *msg, u32 conn_cnt)
 {
 	switch (msg->lm_magic) {
 	case LUSTRE_MSG_MAGIC_V2: {
@@ -1356,7 +1356,7 @@ void lustre_msg_set_conn_cnt(struct lustre_msg *msg, __u32 conn_cnt)
 	}
 }
 
-void lustre_msg_set_timeout(struct lustre_msg *msg, __u32 timeout)
+void lustre_msg_set_timeout(struct lustre_msg *msg, u32 timeout)
 {
 	switch (msg->lm_magic) {
 	case LUSTRE_MSG_MAGIC_V2: {
@@ -1371,7 +1371,7 @@ void lustre_msg_set_timeout(struct lustre_msg *msg, __u32 timeout)
 	}
 }
 
-void lustre_msg_set_service_time(struct lustre_msg *msg, __u32 service_time)
+void lustre_msg_set_service_time(struct lustre_msg *msg, u32 service_time)
 {
 	switch (msg->lm_magic) {
 	case LUSTRE_MSG_MAGIC_V2: {
@@ -1390,7 +1390,7 @@ void lustre_msg_set_jobid(struct lustre_msg *msg, char *jobid)
 {
 	switch (msg->lm_magic) {
 	case LUSTRE_MSG_MAGIC_V2: {
-		__u32 opc = lustre_msg_get_opc(msg);
+		u32 opc = lustre_msg_get_opc(msg);
 		struct ptlrpc_body *pb;
 
 		/* Don't set jobid for ldlm ast RPCs, they've been shrunk.
@@ -1416,7 +1416,7 @@ void lustre_msg_set_jobid(struct lustre_msg *msg, char *jobid)
 }
 EXPORT_SYMBOL(lustre_msg_set_jobid);
 
-void lustre_msg_set_cksum(struct lustre_msg *msg, __u32 cksum)
+void lustre_msg_set_cksum(struct lustre_msg *msg, u32 cksum)
 {
 	switch (msg->lm_magic) {
 	case LUSTRE_MSG_MAGIC_V2:
@@ -1427,7 +1427,7 @@ void lustre_msg_set_cksum(struct lustre_msg *msg, __u32 cksum)
 	}
 }
 
-void lustre_msg_set_mbits(struct lustre_msg *msg, __u64 mbits)
+void lustre_msg_set_mbits(struct lustre_msg *msg, u64 mbits)
 {
 	switch (msg->lm_magic) {
 	case LUSTRE_MSG_MAGIC_V2: {
@@ -1677,7 +1677,7 @@ void lustre_swab_ost_last_id(u64 *id)
 	__swab64s(id);
 }
 
-void lustre_swab_generic_32s(__u32 *val)
+void lustre_swab_generic_32s(u32 *val)
 {
 	__swab32s(val);
 }
@@ -1784,14 +1784,14 @@ void lustre_swab_mgs_target_info(struct mgs_target_info *mti)
 	__swab32s(&mti->mti_flags);
 	__swab32s(&mti->mti_instance);
 	__swab32s(&mti->mti_nid_count);
-	BUILD_BUG_ON(sizeof(lnet_nid_t) != sizeof(__u64));
+	BUILD_BUG_ON(sizeof(lnet_nid_t) != sizeof(u64));
 	for (i = 0; i < MTI_NIDS_MAX; i++)
 		__swab64s(&mti->mti_nids[i]);
 }
 
 void lustre_swab_mgs_nidtbl_entry(struct mgs_nidtbl_entry *entry)
 {
-	__u8 i;
+	u8 i;
 
 	__swab64s(&entry->mne_version);
 	__swab32s(&entry->mne_instance);
@@ -1800,13 +1800,13 @@ void lustre_swab_mgs_nidtbl_entry(struct mgs_nidtbl_entry *entry)
 
 	/* mne_nid_(count|type) must be one byte size because we're gonna
 	 * access it w/o swapping. */
-	BUILD_BUG_ON(sizeof(entry->mne_nid_count) != sizeof(__u8));
-	BUILD_BUG_ON(sizeof(entry->mne_nid_type) != sizeof(__u8));
+	BUILD_BUG_ON(sizeof(entry->mne_nid_count) != sizeof(u8));
+	BUILD_BUG_ON(sizeof(entry->mne_nid_type) != sizeof(u8));
 
 	/* remove this assertion if ipv6 is supported. */
 	LASSERT(entry->mne_nid_type == 0);
 	for (i = 0; i < entry->mne_nid_count; i++) {
-		BUILD_BUG_ON(sizeof(lnet_nid_t) != sizeof(__u64));
+		BUILD_BUG_ON(sizeof(lnet_nid_t) != sizeof(u64));
 		__swab64s(&entry->u.nids[i]);
 	}
 }
@@ -1877,7 +1877,7 @@ static void lustre_swab_fiemap_extent(struct fiemap_extent *fm_extent)
 
 void lustre_swab_fiemap(struct fiemap *fiemap)
 {
-	__u32 i;
+	u32 i;
 
 	__swab64s(&fiemap->fm_start);
 	__swab64s(&fiemap->fm_length);
@@ -2171,7 +2171,7 @@ void dump_rniobuf(struct niobuf_remote *nb)
 
 static void dump_obdo(struct obdo *oa)
 {
-	__u32 valid = oa->o_valid;
+	u32 valid = oa->o_valid;
 
 	CDEBUG(D_RPCTRACE, "obdo: o_valid = %08x\n", valid);
 	if (valid & OBD_MD_FLID)
@@ -2234,7 +2234,7 @@ void dump_ost_body(struct ost_body *ob)
 	dump_obdo(&ob->oa);
 }
 
-void dump_rcs(__u32 *rc)
+void dump_rcs(u32 *rc)
 {
 	CDEBUG(D_RPCTRACE, "rmf_rcs: %d\n", *rc);
 }
diff --git a/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_internal.h b/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_internal.h
index da42b99..10c2520 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_internal.h
+++ b/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_internal.h
@@ -73,7 +73,7 @@ void ptlrpc_set_add_new_req(struct ptlrpcd_ctl *pc,
 void ptlrpc_resend_req(struct ptlrpc_request *request);
 void ptlrpc_set_bulk_mbits(struct ptlrpc_request *req);
 void ptlrpc_assign_next_xid_nolock(struct ptlrpc_request *req);
-__u64 ptlrpc_known_replied_xid(struct obd_import *imp);
+u64 ptlrpc_known_replied_xid(struct obd_import *imp);
 void ptlrpc_add_unreplied(struct ptlrpc_request *req);
 
 /* events.c */
@@ -83,7 +83,7 @@ void ptlrpc_set_add_new_req(struct ptlrpcd_ctl *pc,
 void ptlrpc_request_handle_notconn(struct ptlrpc_request *req);
 void lustre_assert_wire_constants(void);
 int ptlrpc_import_in_recovery(struct obd_import *imp);
-int ptlrpc_set_import_discon(struct obd_import *imp, __u32 conn_cnt);
+int ptlrpc_set_import_discon(struct obd_import *imp, u32 conn_cnt);
 int ptlrpc_replay_next(struct obd_import *imp, int *inflight);
 void ptlrpc_initiate_recovery(struct obd_import *imp);
 
diff --git a/drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c b/drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c
index 4bd0d9d..e39c38a 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c
@@ -672,7 +672,7 @@ static int ptlrpcd_init(void)
 	int j;
 	int rc = 0;
 	struct cfs_cpt_table *cptable;
-	__u32 *cpts = NULL;
+	u32 *cpts = NULL;
 	int ncpts;
 	int cpt;
 	struct ptlrpcd *pd;
diff --git a/drivers/staging/lustre/lustre/ptlrpc/recover.c b/drivers/staging/lustre/lustre/ptlrpc/recover.c
index 9d369f8..ed769a4 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/recover.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/recover.c
@@ -67,7 +67,7 @@ int ptlrpc_replay_next(struct obd_import *imp, int *inflight)
 {
 	int rc = 0;
 	struct ptlrpc_request *req = NULL, *pos;
-	__u64 last_transno;
+	u64 last_transno;
 
 	*inflight = 0;
 
diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec.c b/drivers/staging/lustre/lustre/ptlrpc/sec.c
index 53f4d4f..165082a 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/sec.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/sec.c
@@ -64,7 +64,7 @@
 
 int sptlrpc_register_policy(struct ptlrpc_sec_policy *policy)
 {
-	__u16 number = policy->sp_policy;
+	u16 number = policy->sp_policy;
 
 	LASSERT(policy->sp_name);
 	LASSERT(policy->sp_cops);
@@ -88,7 +88,7 @@ int sptlrpc_register_policy(struct ptlrpc_sec_policy *policy)
 
 int sptlrpc_unregister_policy(struct ptlrpc_sec_policy *policy)
 {
-	__u16 number = policy->sp_policy;
+	u16 number = policy->sp_policy;
 
 	LASSERT(number < SPTLRPC_POLICY_MAX);
 
@@ -109,13 +109,13 @@ int sptlrpc_unregister_policy(struct ptlrpc_sec_policy *policy)
 EXPORT_SYMBOL(sptlrpc_unregister_policy);
 
 static
-struct ptlrpc_sec_policy *sptlrpc_wireflavor2policy(__u32 flavor)
+struct ptlrpc_sec_policy *sptlrpc_wireflavor2policy(u32 flavor)
 {
 	static DEFINE_MUTEX(load_mutex);
 	static atomic_t loaded = ATOMIC_INIT(0);
 	struct ptlrpc_sec_policy *policy;
-	__u16 number = SPTLRPC_FLVR_POLICY(flavor);
-	__u16 flag = 0;
+	u16 number = SPTLRPC_FLVR_POLICY(flavor);
+	u16 flag = 0;
 
 	if (number >= SPTLRPC_POLICY_MAX)
 		return NULL;
@@ -150,7 +150,7 @@ struct ptlrpc_sec_policy *sptlrpc_wireflavor2policy(__u32 flavor)
 	return policy;
 }
 
-__u32 sptlrpc_name2flavor_base(const char *name)
+u32 sptlrpc_name2flavor_base(const char *name)
 {
 	if (!strcmp(name, "null"))
 		return SPTLRPC_FLVR_NULL;
@@ -169,9 +169,9 @@ __u32 sptlrpc_name2flavor_base(const char *name)
 }
 EXPORT_SYMBOL(sptlrpc_name2flavor_base);
 
-const char *sptlrpc_flavor2name_base(__u32 flvr)
+const char *sptlrpc_flavor2name_base(u32 flvr)
 {
-	__u32   base = SPTLRPC_FLVR_BASE(flvr);
+	u32   base = SPTLRPC_FLVR_BASE(flvr);
 
 	if (base == SPTLRPC_FLVR_BASE(SPTLRPC_FLVR_NULL))
 		return "null";
@@ -226,7 +226,7 @@ char *sptlrpc_flavor2name(struct sptlrpc_flavor *sf, char *buf, int bufsize)
 }
 EXPORT_SYMBOL(sptlrpc_flavor2name);
 
-static char *sptlrpc_secflags2str(__u32 flags, char *buf, int bufsize)
+static char *sptlrpc_secflags2str(u32 flags, char *buf, int bufsize)
 {
 	buf[0] = '\0';
 
@@ -2280,7 +2280,7 @@ int sptlrpc_unpack_user_desc(struct lustre_msg *msg, int offset, int swabbed)
 		return -EINVAL;
 	}
 
-	if (sizeof(*pud) + pud->pud_ngroups * sizeof(__u32) >
+	if (sizeof(*pud) + pud->pud_ngroups * sizeof(u32) >
 	    msg->lm_buflens[offset]) {
 		CERROR("%u groups are claimed but bufsize only %u\n",
 		       pud->pud_ngroups, msg->lm_buflens[offset]);
diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c b/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c
index dbd6c74..93dcb6d 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c
@@ -485,12 +485,12 @@ void sptlrpc_enc_pool_fini(void)
 	[BULK_HASH_ALG_SHA512]	= CFS_HASH_ALG_SHA512,
 };
 
-const char *sptlrpc_get_hash_name(__u8 hash_alg)
+const char *sptlrpc_get_hash_name(u8 hash_alg)
 {
 	return cfs_crypto_hash_name(cfs_hash_alg_id[hash_alg]);
 }
 
-__u8 sptlrpc_get_hash_alg(const char *algname)
+u8 sptlrpc_get_hash_alg(const char *algname)
 {
 	return cfs_crypto_hash_alg(algname);
 }
@@ -532,7 +532,7 @@ int bulk_sec_desc_unpack(struct lustre_msg *msg, int offset, int swabbed)
 }
 EXPORT_SYMBOL(bulk_sec_desc_unpack);
 
-int sptlrpc_get_bulk_checksum(struct ptlrpc_bulk_desc *desc, __u8 alg,
+int sptlrpc_get_bulk_checksum(struct ptlrpc_bulk_desc *desc, u8 alg,
 			      void *buf, int buflen)
 {
 	struct ahash_request *hdesc;
diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec_null.c b/drivers/staging/lustre/lustre/ptlrpc/sec_null.c
index ecc387d..6933a53 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/sec_null.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/sec_null.c
@@ -57,7 +57,7 @@
 static inline
 void null_encode_sec_part(struct lustre_msg *msg, enum lustre_sec_part sp)
 {
-	msg->lm_secflvr |= (((__u32)sp) & 0xFF) << 24;
+	msg->lm_secflvr |= (((u32)sp) & 0xFF) << 24;
 }
 
 static inline
@@ -91,7 +91,7 @@ int null_ctx_sign(struct ptlrpc_cli_ctx *ctx, struct ptlrpc_request *req)
 static
 int null_ctx_verify(struct ptlrpc_cli_ctx *ctx, struct ptlrpc_request *req)
 {
-	__u32 cksums, cksumc;
+	u32 cksums, cksumc;
 
 	LASSERT(req->rq_repdata);
 
@@ -361,7 +361,7 @@ int null_authorize(struct ptlrpc_request *req)
 		else
 			req->rq_reply_off = 0;
 	} else {
-		__u32 cksum;
+		u32 cksum;
 
 		cksum = lustre_msg_calc_cksum(rs->rs_repbuf);
 		lustre_msg_set_cksum(rs->rs_repbuf, cksum);
diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec_plain.c b/drivers/staging/lustre/lustre/ptlrpc/sec_plain.c
index ead1df7..0a31ff4 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/sec_plain.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/sec_plain.c
@@ -76,15 +76,15 @@ static inline struct plain_sec *sec2plsec(struct ptlrpc_sec *sec)
 #define PLAIN_FL_BULK		   (0x02)
 
 struct plain_header {
-	__u8	    ph_ver;	    /* 0 */
-	__u8	    ph_flags;
-	__u8	    ph_sp;	     /* source */
-	__u8	    ph_bulk_hash_alg;  /* complete flavor desc */
-	__u8	    ph_pad[4];
+	u8	    ph_ver;	    /* 0 */
+	u8	    ph_flags;
+	u8	    ph_sp;	     /* source */
+	u8	    ph_bulk_hash_alg;  /* complete flavor desc */
+	u8	    ph_pad[4];
 };
 
 struct plain_bulk_token {
-	__u8	    pbt_hash[8];
+	u8	    pbt_hash[8];
 };
 
 #define PLAIN_BSD_SIZE \
@@ -118,7 +118,7 @@ static int plain_unpack_bsd(struct lustre_msg *msg, int swabbed)
 }
 
 static int plain_generate_bulk_csum(struct ptlrpc_bulk_desc *desc,
-				    __u8 hash_alg,
+				    u8 hash_alg,
 				    struct plain_bulk_token *token)
 {
 	if (hash_alg == BULK_HASH_ALG_NULL)
@@ -130,7 +130,7 @@ static int plain_generate_bulk_csum(struct ptlrpc_bulk_desc *desc,
 }
 
 static int plain_verify_bulk_csum(struct ptlrpc_bulk_desc *desc,
-				  __u8 hash_alg,
+				  u8 hash_alg,
 				  struct plain_bulk_token *tokenr)
 {
 	struct plain_bulk_token tokenv;
@@ -216,7 +216,7 @@ int plain_ctx_verify(struct ptlrpc_cli_ctx *ctx, struct ptlrpc_request *req)
 {
 	struct lustre_msg *msg = req->rq_repdata;
 	struct plain_header *phdr;
-	__u32 cksum;
+	u32 cksum;
 	int swabbed;
 
 	if (msg->lm_bufcount != PLAIN_PACK_SEGMENTS) {
@@ -543,7 +543,7 @@ int plain_alloc_reqbuf(struct ptlrpc_sec *sec,
 		       struct ptlrpc_request *req,
 		       int msgsize)
 {
-	__u32 buflens[PLAIN_PACK_SEGMENTS] = { 0, };
+	u32 buflens[PLAIN_PACK_SEGMENTS] = { 0, };
 	int alloc_len;
 
 	buflens[PLAIN_PACK_HDR_OFF] = sizeof(struct plain_header);
@@ -603,7 +603,7 @@ int plain_alloc_repbuf(struct ptlrpc_sec *sec,
 		       struct ptlrpc_request *req,
 		       int msgsize)
 {
-	__u32 buflens[PLAIN_PACK_SEGMENTS] = { 0, };
+	u32 buflens[PLAIN_PACK_SEGMENTS] = { 0, };
 	int alloc_len;
 
 	buflens[PLAIN_PACK_HDR_OFF] = sizeof(struct plain_header);
@@ -790,7 +790,7 @@ int plain_accept(struct ptlrpc_request *req)
 int plain_alloc_rs(struct ptlrpc_request *req, int msgsize)
 {
 	struct ptlrpc_reply_state *rs;
-	__u32 buflens[PLAIN_PACK_SEGMENTS] = { 0, };
+	u32 buflens[PLAIN_PACK_SEGMENTS] = { 0, };
 	int rs_size = sizeof(*rs);
 
 	LASSERT(msgsize % 8 == 0);
@@ -1001,7 +1001,7 @@ int plain_svc_wrap_bulk(struct ptlrpc_request *req,
 
 int sptlrpc_plain_init(void)
 {
-	__u32 buflens[PLAIN_PACK_SEGMENTS] = { 0, };
+	u32 buflens[PLAIN_PACK_SEGMENTS] = { 0, };
 	int rc;
 
 	buflens[PLAIN_PACK_MSG_OFF] = lustre_msg_early_size();
diff --git a/drivers/staging/lustre/lustre/ptlrpc/service.c b/drivers/staging/lustre/lustre/ptlrpc/service.c
index 6a5a9c5..1030f65 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/service.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/service.c
@@ -507,7 +507,7 @@ static void ptlrpc_at_timer(struct timer_list *t)
 		INIT_LIST_HEAD(&array->paa_reqs_array[index]);
 
 	array->paa_reqs_count =
-		kzalloc_node(sizeof(__u32) * size, GFP_NOFS,
+		kzalloc_node(sizeof(u32) * size, GFP_NOFS,
 			     cfs_cpt_spread_node(svc->srv_cptable, cpt));
 	if (!array->paa_reqs_count)
 		goto free_reqs_array;
@@ -555,7 +555,7 @@ struct ptlrpc_service *
 	struct ptlrpc_service *service;
 	struct ptlrpc_service_part *svcpt;
 	struct cfs_cpt_table *cptable;
-	__u32 *cpts = NULL;
+	u32 *cpts = NULL;
 	int ncpts;
 	int cpt;
 	int rc;
@@ -925,7 +925,7 @@ static int ptlrpc_check_req(struct ptlrpc_request *req)
 static void ptlrpc_at_set_timer(struct ptlrpc_service_part *svcpt)
 {
 	struct ptlrpc_at_array *array = &svcpt->scp_at_array;
-	__s32 next;
+	s32 next;
 
 	if (array->paa_count == 0) {
 		del_timer(&svcpt->scp_at_timer);
@@ -933,7 +933,7 @@ static void ptlrpc_at_set_timer(struct ptlrpc_service_part *svcpt)
 	}
 
 	/* Set timer for closest deadline */
-	next = (__s32)(array->paa_deadline - ktime_get_real_seconds() -
+	next = (s32)(array->paa_deadline - ktime_get_real_seconds() -
 		       at_early_margin);
 	if (next <= 0) {
 		ptlrpc_at_timer(&svcpt->scp_at_timer);
@@ -950,7 +950,7 @@ static int ptlrpc_at_add_timed(struct ptlrpc_request *req)
 	struct ptlrpc_service_part *svcpt = req->rq_rqbd->rqbd_svcpt;
 	struct ptlrpc_at_array *array = &svcpt->scp_at_array;
 	struct ptlrpc_request *rq = NULL;
-	__u32 index;
+	u32 index;
 
 	if (AT_OFF)
 		return 0;
@@ -1158,7 +1158,7 @@ static void ptlrpc_at_check_timed(struct ptlrpc_service_part *svcpt)
 	struct ptlrpc_at_array *array = &svcpt->scp_at_array;
 	struct ptlrpc_request *rq, *n;
 	struct list_head work_list;
-	__u32 index, count;
+	u32 index, count;
 	time64_t deadline;
 	time64_t now = ktime_get_real_seconds();
 	long delay;
@@ -1478,7 +1478,7 @@ static bool ptlrpc_server_normal_pending(struct ptlrpc_service_part *svcpt,
 {
 	struct ptlrpc_service *svc = svcpt->scp_service;
 	struct ptlrpc_request *req;
-	__u32 deadline;
+	u32 deadline;
 	int rc;
 
 	spin_lock(&svcpt->scp_lock);
@@ -1757,7 +1757,7 @@ static bool ptlrpc_server_normal_pending(struct ptlrpc_service_part *svcpt,
 	       (request->rq_repmsg ?
 		lustre_msg_get_status(request->rq_repmsg) : -999));
 	if (likely(svc->srv_stats && request->rq_reqmsg)) {
-		__u32 op = lustre_msg_get_opc(request->rq_reqmsg);
+		u32 op = lustre_msg_get_opc(request->rq_reqmsg);
 		int opc = opcode_offset(op);
 
 		if (opc > 0 && !(op == LDLM_ENQUEUE || op == MDS_REINT)) {
-- 
1.8.3.1
