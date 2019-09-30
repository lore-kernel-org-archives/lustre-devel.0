From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Sep 2019 14:55:45 -0400
Subject: [lustre-devel] [PATCH 086/151] lustre: idl: clean up and document
 ptlrpc structures
In-Reply-To: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1569869810-23848-87-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Andreas Dilger <adilger@whamcloud.com>

Miscellaneous cleanups for wire-related structures found during the
Lustre protocol documentation project.

Remove obsolete and unused since 2.3 OBD_QC_CALLBACK RPC.

Move definition of constants used by lustre_msg_v2 and ptlrpc_body
fields to immediately before their respective structures.

Add comments for struct members for lustre_msg_v2, ptlrpc_body_v3,
ldlm_request, and obd_statfs.

Rename RQF_MDS_INTENT_CLOSE to RQF_MDS_CLOSE_INTENT to make it more
easily found with RQF_MDS_CLOSE.  Rename mdt_intent_close_client()
and mdc_intent_close_pack() to mdt_close_intent_client() and
mdc_close_intent_pack() to match.

Rename RQF_LDLM_GL_DESC_CALLBACK to RQF_LDLM_GL_CALLBACK_DESC to make
it match RQF_LDLM_FL_CALLBACK and RQF_LDLM_BL_CALLBACK.

Remove unused MSG_OP_FLAG_MASK, MSG_OP_FLAG_SHIFT, MSG_GEN_FLAG_MASK.

WC-bug-id: https://jira.whamcloud.com/browse/LU-6349
Lustre-commit: e8bdd1a48dd8 ("LU-6349 idl: clean up and document ptlrpc structures")
Signed-off-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/17830
Reviewed-by: Ben Evans <bevans@cray.com>
Reviewed-by: Steve Guminski <stephenx.guminski@intel.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: John L. Hammond <jhammond@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_req_layout.h   |   4 +-
 fs/lustre/include/obd_class.h           |   2 +-
 fs/lustre/mdc/mdc_lib.c                 |   6 +-
 fs/lustre/mdc/mdc_request.c             |   2 +-
 fs/lustre/mgc/mgc_request.c             |   2 +-
 fs/lustre/ptlrpc/layout.c               |  18 ++--
 fs/lustre/ptlrpc/pack_generic.c         |  60 +++++------
 fs/lustre/ptlrpc/wiretest.c             |   6 --
 include/uapi/linux/lustre/lustre_idl.h  | 176 ++++++++++++++++----------------
 include/uapi/linux/lustre/lustre_user.h |  27 ++---
 10 files changed, 149 insertions(+), 154 deletions(-)

diff --git a/fs/lustre/include/lustre_req_layout.h b/fs/lustre/include/lustre_req_layout.h
index 3d86883..48f454c 100644
--- a/fs/lustre/include/lustre_req_layout.h
+++ b/fs/lustre/include/lustre_req_layout.h
@@ -143,7 +143,7 @@ void req_capsule_shrink(struct req_capsule *pill,
  */
 extern struct req_format RQF_MDS_GETATTR_NAME;
 extern struct req_format RQF_MDS_CLOSE;
-extern struct req_format RQF_MDS_INTENT_CLOSE;
+extern struct req_format RQF_MDS_CLOSE_INTENT;
 extern struct req_format RQF_MDS_CONNECT;
 extern struct req_format RQF_MDS_DISCONNECT;
 extern struct req_format RQF_MDS_GET_INFO;
@@ -210,7 +210,7 @@ void req_capsule_shrink(struct req_capsule *pill,
 extern struct req_format RQF_LDLM_CP_CALLBACK;
 extern struct req_format RQF_LDLM_BL_CALLBACK;
 extern struct req_format RQF_LDLM_GL_CALLBACK;
-extern struct req_format RQF_LDLM_GL_DESC_CALLBACK;
+extern struct req_format RQF_LDLM_GL_CALLBACK_DESC;
 /* LOG req_format */
 extern struct req_format RQF_LOG_CANCEL;
 extern struct req_format RQF_LLOG_ORIGIN_HANDLE_CREATE;
diff --git a/fs/lustre/include/obd_class.h b/fs/lustre/include/obd_class.h
index a939f17..38b69e8 100644
--- a/fs/lustre/include/obd_class.h
+++ b/fs/lustre/include/obd_class.h
@@ -183,7 +183,7 @@ int class_config_parse_llog(const struct lu_env *env, struct llog_ctxt *ctxt,
 struct config_llog_data {
 	struct ldlm_res_id		cld_resid;
 	struct config_llog_instance	cld_cfg;
-	struct list_head		cld_list_chain;
+	struct list_head		cld_list_chain; /* on config_llog_list */
 	atomic_t			cld_refcount;
 	struct config_llog_data	       *cld_sptlrpc;	/* depended sptlrpc log */
 	struct config_llog_data	       *cld_params;	/* common parameters log */
diff --git a/fs/lustre/mdc/mdc_lib.c b/fs/lustre/mdc/mdc_lib.c
index ff14f82..df66ed1 100644
--- a/fs/lustre/mdc/mdc_lib.c
+++ b/fs/lustre/mdc/mdc_lib.c
@@ -428,7 +428,7 @@ void mdc_link_pack(struct ptlrpc_request *req, struct md_op_data *op_data)
 	mdc_pack_name(req, &RMF_NAME, op_data->op_name, op_data->op_namelen);
 }
 
-static void mdc_intent_close_pack(struct ptlrpc_request *req,
+static void mdc_close_intent_pack(struct ptlrpc_request *req,
 				  struct md_op_data *op_data)
 {
 	enum mds_op_bias bias = op_data->op_bias;
@@ -501,7 +501,7 @@ void mdc_rename_pack(struct ptlrpc_request *req, struct md_op_data *op_data,
 	    op_data->op_bias & MDS_RENAME_MIGRATE) {
 		struct mdt_ioepoch *epoch;
 
-		mdc_intent_close_pack(req, op_data);
+		mdc_close_intent_pack(req, op_data);
 		epoch = req_capsule_client_get(&req->rq_pill, &RMF_MDT_EPOCH);
 		mdc_ioepoch_pack(epoch, op_data);
 	}
@@ -553,5 +553,5 @@ void mdc_close_pack(struct ptlrpc_request *req, struct md_op_data *op_data)
 		rec->sa_valid &= ~MDS_ATTR_ATIME;
 
 	mdc_ioepoch_pack(epoch, op_data);
-	mdc_intent_close_pack(req, op_data);
+	mdc_close_intent_pack(req, op_data);
 }
diff --git a/fs/lustre/mdc/mdc_request.c b/fs/lustre/mdc/mdc_request.c
index 1a0f05a..efa6516 100644
--- a/fs/lustre/mdc/mdc_request.c
+++ b/fs/lustre/mdc/mdc_request.c
@@ -771,7 +771,7 @@ static int mdc_close(struct obd_export *exp, struct md_op_data *op_data,
 	       op_data->op_bias);
 
 	if (op_data->op_bias & MDS_CLOSE_INTENT) {
-		req_fmt = &RQF_MDS_INTENT_CLOSE;
+		req_fmt = &RQF_MDS_CLOSE_INTENT;
 		if (op_data->op_bias & MDS_HSM_RELEASE) {
 			/* allocate a FID for volatile file */
 			rc = mdc_fid_alloc(NULL, exp, &op_data->op_fid2,
diff --git a/fs/lustre/mgc/mgc_request.c b/fs/lustre/mgc/mgc_request.c
index 581ffb0..ca7f47a 100644
--- a/fs/lustre/mgc/mgc_request.c
+++ b/fs/lustre/mgc/mgc_request.c
@@ -116,7 +116,7 @@ static int mgc_logname2resid(char *logname, struct ldlm_res_id *res_id,
 
 /********************** config llog list **********************/
 static LIST_HEAD(config_llog_list);
-static DEFINE_SPINLOCK(config_list_lock);
+static DEFINE_SPINLOCK(config_list_lock);	/* protects config_llog_list */
 
 /* Take a reference to a config log */
 static int config_log_get(struct config_llog_data *cld)
diff --git a/fs/lustre/ptlrpc/layout.c b/fs/lustre/ptlrpc/layout.c
index ce1de5e..0978329 100644
--- a/fs/lustre/ptlrpc/layout.c
+++ b/fs/lustre/ptlrpc/layout.c
@@ -116,7 +116,7 @@
 	&RMF_CAPA1
 };
 
-static const struct req_msg_field *mdt_intent_close_client[] = {
+static const struct req_msg_field *mdt_close_intent_client[] = {
 	&RMF_PTLRPC_BODY,
 	&RMF_MDT_EPOCH,
 	&RMF_REC_REINT,
@@ -705,7 +705,7 @@
 	&RQF_MDS_GETXATTR,
 	&RQF_MDS_SYNC,
 	&RQF_MDS_CLOSE,
-	&RQF_MDS_INTENT_CLOSE,
+	&RQF_MDS_CLOSE_INTENT,
 	&RQF_MDS_READPAGE,
 	&RQF_MDS_WRITEPAGE,
 	&RQF_MDS_REINT,
@@ -757,7 +757,7 @@
 	&RQF_LDLM_CP_CALLBACK,
 	&RQF_LDLM_BL_CALLBACK,
 	&RQF_LDLM_GL_CALLBACK,
-	&RQF_LDLM_GL_DESC_CALLBACK,
+	&RQF_LDLM_GL_CALLBACK_DESC,
 	&RQF_LDLM_INTENT,
 	&RQF_LDLM_INTENT_BASIC,
 	&RQF_LDLM_INTENT_LAYOUT,
@@ -1405,10 +1405,10 @@ struct req_format RQF_LDLM_GL_CALLBACK =
 			ldlm_gl_callback_server);
 EXPORT_SYMBOL(RQF_LDLM_GL_CALLBACK);
 
-struct req_format RQF_LDLM_GL_DESC_CALLBACK =
+struct req_format RQF_LDLM_GL_CALLBACK_DESC =
 	DEFINE_REQ_FMT0("LDLM_GL_CALLBACK", ldlm_gl_callback_desc_client,
 			ldlm_gl_callback_server);
-EXPORT_SYMBOL(RQF_LDLM_GL_DESC_CALLBACK);
+EXPORT_SYMBOL(RQF_LDLM_GL_CALLBACK_DESC);
 
 struct req_format RQF_LDLM_INTENT_BASIC =
 	DEFINE_REQ_FMT0("LDLM_INTENT_BASIC",
@@ -1421,7 +1421,7 @@ struct req_format RQF_LDLM_INTENT =
 EXPORT_SYMBOL(RQF_LDLM_INTENT);
 
 struct req_format RQF_LDLM_INTENT_LAYOUT =
-	DEFINE_REQ_FMT0("LDLM_INTENT_LAYOUT ",
+	DEFINE_REQ_FMT0("LDLM_INTENT_LAYOUT",
 			ldlm_intent_layout_client, ldlm_enqueue_lvb_server);
 EXPORT_SYMBOL(RQF_LDLM_INTENT_LAYOUT);
 
@@ -1456,10 +1456,10 @@ struct req_format RQF_MDS_CLOSE =
 			mdt_close_client, mds_last_unlink_server);
 EXPORT_SYMBOL(RQF_MDS_CLOSE);
 
-struct req_format RQF_MDS_INTENT_CLOSE =
+struct req_format RQF_MDS_CLOSE_INTENT =
 	DEFINE_REQ_FMT0("MDS_CLOSE",
-			mdt_intent_close_client, mds_last_unlink_server);
-EXPORT_SYMBOL(RQF_MDS_INTENT_CLOSE);
+			mdt_close_intent_client, mds_last_unlink_server);
+EXPORT_SYMBOL(RQF_MDS_CLOSE_INTENT);
 
 struct req_format RQF_MDS_READPAGE =
 	DEFINE_REQ_FMT0("MDS_READPAGE",
diff --git a/fs/lustre/ptlrpc/pack_generic.c b/fs/lustre/ptlrpc/pack_generic.c
index e7662be..7fa2cf7 100644
--- a/fs/lustre/ptlrpc/pack_generic.c
+++ b/fs/lustre/ptlrpc/pack_generic.c
@@ -832,7 +832,7 @@ void lustre_msg_clear_flags(struct lustre_msg *msg, u32 flags)
 		struct ptlrpc_body *pb = lustre_msg_ptlrpc_body(msg);
 
 		LASSERTF(pb, "invalid msg %p: no ptlrpc body!\n", msg);
-		pb->pb_flags &= ~(flags & MSG_GEN_FLAG_MASK);
+		pb->pb_flags &= ~flags;
 		return;
 	}
 	default:
@@ -1504,40 +1504,41 @@ int do_set_info_async(struct obd_import *imp,
 /* byte flipping routines for all wire types declared in
  * lustre_idl.h implemented here.
  */
-void lustre_swab_ptlrpc_body(struct ptlrpc_body *b)
-{
-	__swab32s(&b->pb_type);
-	__swab32s(&b->pb_version);
-	__swab32s(&b->pb_opc);
-	__swab32s(&b->pb_status);
-	__swab64s(&b->pb_last_xid);
-	__swab16s(&b->pb_tag);
-	__swab64s(&b->pb_last_committed);
-	__swab64s(&b->pb_transno);
-	__swab32s(&b->pb_flags);
-	__swab32s(&b->pb_op_flags);
-	__swab32s(&b->pb_conn_cnt);
-	__swab32s(&b->pb_timeout);
-	__swab32s(&b->pb_service_time);
-	__swab32s(&b->pb_limit);
-	__swab64s(&b->pb_slv);
-	__swab64s(&b->pb_pre_versions[0]);
-	__swab64s(&b->pb_pre_versions[1]);
-	__swab64s(&b->pb_pre_versions[2]);
-	__swab64s(&b->pb_pre_versions[3]);
-	__swab64s(&b->pb_mbits);
-	BUILD_BUG_ON(offsetof(typeof(*b), pb_padding0) == 0);
-	BUILD_BUG_ON(offsetof(typeof(*b), pb_padding1) == 0);
-	BUILD_BUG_ON(offsetof(typeof(*b), pb_padding64_0) == 0);
-	BUILD_BUG_ON(offsetof(typeof(*b), pb_padding64_1) == 0);
-	BUILD_BUG_ON(offsetof(typeof(*b), pb_padding64_2) == 0);
+void lustre_swab_ptlrpc_body(struct ptlrpc_body *body)
+{
+	__swab32s(&body->pb_type);
+	__swab32s(&body->pb_version);
+	__swab32s(&body->pb_opc);
+	__swab32s(&body->pb_status);
+	__swab64s(&body->pb_last_xid);
+	__swab16s(&body->pb_tag);
+	BUILD_BUG_ON(offsetof(typeof(*body), pb_padding0) == 0);
+	BUILD_BUG_ON(offsetof(typeof(*body), pb_padding1) == 0);
+	__swab64s(&body->pb_last_committed);
+	__swab64s(&body->pb_transno);
+	__swab32s(&body->pb_flags);
+	__swab32s(&body->pb_op_flags);
+	__swab32s(&body->pb_conn_cnt);
+	__swab32s(&body->pb_timeout);
+	__swab32s(&body->pb_service_time);
+	__swab32s(&body->pb_limit);
+	__swab64s(&body->pb_slv);
+	__swab64s(&body->pb_pre_versions[0]);
+	__swab64s(&body->pb_pre_versions[1]);
+	__swab64s(&body->pb_pre_versions[2]);
+	__swab64s(&body->pb_pre_versions[3]);
+	__swab64s(&body->pb_mbits);
+	BUILD_BUG_ON(offsetof(typeof(*body), pb_padding64_0) == 0);
+	BUILD_BUG_ON(offsetof(typeof(*body), pb_padding64_1) == 0);
+	BUILD_BUG_ON(offsetof(typeof(*body), pb_padding64_2) == 0);
 	/* While we need to maintain compatibility between
 	 * clients and servers without ptlrpc_body_v2 (< 2.3)
 	 * do not swab any fields beyond pb_jobid, as we are
 	 * using this swab function for both ptlrpc_body
 	 * and ptlrpc_body_v2.
 	 */
-	BUILD_BUG_ON(offsetof(typeof(*b), pb_jobid) == 0);
+	/* pb_jobid is an ASCII string and should not be swabbed */
+	BUILD_BUG_ON(offsetof(typeof(*body), pb_jobid) == 0);
 }
 
 void lustre_swab_connect(struct obd_connect_data *ocd)
@@ -1642,6 +1643,7 @@ void lustre_swab_obd_statfs(struct obd_statfs *os)
 	__swab32s(&os->os_namelen);
 	__swab64s(&os->os_maxbytes);
 	__swab32s(&os->os_state);
+	__swab32s(&os->os_fprecreated);
 	BUILD_BUG_ON(offsetof(typeof(*os), os_fprecreated) == 0);
 	BUILD_BUG_ON(offsetof(typeof(*os), os_spare2) == 0);
 	BUILD_BUG_ON(offsetof(typeof(*os), os_spare3) == 0);
diff --git a/fs/lustre/ptlrpc/wiretest.c b/fs/lustre/ptlrpc/wiretest.c
index ff3c79a..76fb656 100644
--- a/fs/lustre/ptlrpc/wiretest.c
+++ b/fs/lustre/ptlrpc/wiretest.c
@@ -827,12 +827,6 @@ void lustre_assert_wire_constants(void)
 		 (long long)MSGHDR_AT_SUPPORT);
 	LASSERTF(MSGHDR_CKSUM_INCOMPAT18 == 2, "found %lld\n",
 		 (long long)MSGHDR_CKSUM_INCOMPAT18);
-	LASSERTF(MSG_OP_FLAG_MASK == 0xffff0000UL, "found 0x%.8xUL\n",
-		 (unsigned int)MSG_OP_FLAG_MASK);
-	LASSERTF(MSG_OP_FLAG_SHIFT == 16, "found %lld\n",
-		 (long long)MSG_OP_FLAG_SHIFT);
-	LASSERTF(MSG_GEN_FLAG_MASK == 0x0000ffffUL, "found 0x%.8xUL\n",
-		 (unsigned int)MSG_GEN_FLAG_MASK);
 	LASSERTF(MSG_LAST_REPLAY == 0x00000001UL, "found 0x%.8xUL\n",
 		 (unsigned int)MSG_LAST_REPLAY);
 	LASSERTF(MSG_RESENT == 0x00000002UL, "found 0x%.8xUL\n",
diff --git a/include/uapi/linux/lustre/lustre_idl.h b/include/uapi/linux/lustre/lustre_idl.h
index 2c729ad..2a7f419 100644
--- a/include/uapi/linux/lustre/lustre_idl.h
+++ b/include/uapi/linux/lustre/lustre_idl.h
@@ -123,29 +123,8 @@
 #define SEQ_CONTROLLER_PORTAL	32
 #define MGS_BULK_PORTAL		33
 
-/* Portal 63 is reserved for the Cray Inc DVS - nic at cray.com, roe at cray.com,
- *						n8851 at cray.com
- */
-
-/* packet types */
-#define PTL_RPC_MSG_REQUEST	4711
-#define PTL_RPC_MSG_ERR		4712
-#define PTL_RPC_MSG_REPLY	4713
-
-/* DON'T use swabbed values of MAGIC as magic! */
-#define LUSTRE_MSG_MAGIC_V2		0x0BD00BD3
-#define LUSTRE_MSG_MAGIC_V2_SWABBED	0xD30BD00B
-
-#define LUSTRE_MSG_MAGIC LUSTRE_MSG_MAGIC_V2
-
-#define PTLRPC_MSG_VERSION  0x00000003
-#define LUSTRE_VERSION_MASK 0xffff0000
-#define LUSTRE_OBD_VERSION  0x00010000
-#define LUSTRE_MDS_VERSION  0x00020000
-#define LUSTRE_OST_VERSION  0x00030000
-#define LUSTRE_DLM_VERSION  0x00040000
-#define LUSTRE_LOG_VERSION  0x00050000
-#define LUSTRE_MGS_VERSION  0x00060000
+/* #define DVS_PORTAL		63 */
+/* reserved for Cray DVS - spitzcor at cray.com, roe at cray.com, n8851 at cray.com */
 
 /**
  * Describes a range of sequence, lsr_start is included but lsr_end is
@@ -550,55 +529,107 @@ static inline void lustre_handle_copy(struct lustre_handle *tgt,
 	tgt->cookie = src->cookie;
 }
 
+/* lustre_msg struct magic.  DON'T use swabbed values of MAGIC as magic! */
+#define LUSTRE_MSG_MAGIC_V2		0x0BD00BD3
+#define LUSTRE_MSG_MAGIC_V2_SWABBED	0xD30BD00B
+#define LUSTRE_MSG_MAGIC		LUSTRE_MSG_MAGIC_V2
+
 /* flags for lm_flags */
-#define MSGHDR_AT_SUPPORT	0x1
-#define MSGHDR_CKSUM_INCOMPAT18	0x2
+#define MSGHDR_AT_SUPPORT		0x1 /* adaptive timeouts, lm_cksum valid
+					     * in early reply messages
+					     */
+#define MSGHDR_CKSUM_INCOMPAT18		0x2 /* compat for 1.8, needs to be set
+					     * well beyond 2.8.0 for
+					     * compatibility
+					     */
 
 #define lustre_msg lustre_msg_v2
 /* we depend on this structure to be 8-byte aligned */
 /* this type is only endian-adjusted in lustre_unpack_msg() */
 struct lustre_msg_v2 {
-	__u32 lm_bufcount;
-	__u32 lm_secflvr;
-	__u32 lm_magic;
-	__u32 lm_repsize;
-	__u32 lm_cksum;
-	__u32 lm_flags;
-	__u32 lm_padding_2;
-	__u32 lm_padding_3;
-	__u32 lm_buflens[0];
+	__u32 lm_bufcount;	/* number of buffers in lm_buflens[] */
+	__u32 lm_secflvr;	/* 0 = no crypto, or sptlrpc security flavour */
+	__u32 lm_magic;		/* RPC version magic = LUSTRE_MSG_MAGIC_V2 */
+	__u32 lm_repsize;	/* size of preallocated reply buffer */
+	__u32 lm_cksum;		/* CRC32 of ptlrpc_body early reply messages */
+	__u32 lm_flags;		/* MSGHDR_* flags */
+	__u32 lm_padding_2;	/* unused */
+	__u32 lm_padding_3;	/* unused */
+	__u32 lm_buflens[0];	/* length of additional buffers in bytes,
+				 * padded to a multiple of 8 bytes.
+				 */
+	/*
+	 * message buffers are packed after padded lm_buflens[] array,
+	 * padded to a multiple of 8 bytes each to align contents.
+	 */
 };
 
-/* without gss, ptlrpc_body is put at the first buffer. */
-#define PTLRPC_NUM_VERSIONS	4
+/* ptlrpc_body packet pb_types */
+#define PTL_RPC_MSG_REQUEST	4711	/* normal RPC request message */
+#define PTL_RPC_MSG_ERR		4712	/* error reply if request unprocessed */
+#define PTL_RPC_MSG_REPLY	4713	/* normal RPC reply message */
 
+/* ptlrpc_body pb_version ((target_version << 16) | rpc_version) */
+#define PTLRPC_MSG_VERSION	0x00000003
+#define LUSTRE_VERSION_MASK	0xffff0000
+#define LUSTRE_OBD_VERSION	0x00010000
+#define LUSTRE_MDS_VERSION	0x00020000
+#define LUSTRE_OST_VERSION	0x00030000
+#define LUSTRE_DLM_VERSION	0x00040000
+#define LUSTRE_LOG_VERSION	0x00050000
+#define LUSTRE_MGS_VERSION	0x00060000
+
+/* pb_flags that apply to all requests */
+#define MSG_LAST_REPLAY		0x0001
+#define MSG_RESENT		0x0002
+#define MSG_REPLAY		0x0004
+/* #define MSG_AT_SUPPORT	0x0008 obsolete 1.5 */
+#define MSG_DELAY_REPLAY	0x0010
+#define MSG_VERSION_REPLAY	0x0020
+#define MSG_REQ_REPLAY_DONE	0x0040
+#define MSG_LOCK_REPLAY_DONE	0x0080
+
+/* pb_op_flags for all connect opcodes (MDS_CONNECT, OST_CONNECT) */
+#define MSG_CONNECT_RECOVERING	0x00000001
+#define MSG_CONNECT_RECONNECT	0x00000002
+#define MSG_CONNECT_REPLAYABLE	0x00000004
+/* #define MSG_CONNECT_PEER	0x00000008 removed 1.5 */
+#define MSG_CONNECT_LIBCLIENT	0x00000010
+#define MSG_CONNECT_INITIAL	0x00000020
+#define MSG_CONNECT_ASYNC	0x00000040
+#define MSG_CONNECT_NEXT_VER	0x00000080 /* use next version of lustre_msg */
+#define MSG_CONNECT_TRANSNO	0x00000100 /* report transno */
+
+/* number of previous object versions in pb_pre_versions[] */
+#define PTLRPC_NUM_VERSIONS	4
+/* without gss, ptlrpc_body is put@the first buffer. */
 struct ptlrpc_body_v3 {
 	struct lustre_handle pb_handle;
-	__u32 pb_type;
-	__u32 pb_version;
-	__u32 pb_opc;
-	__u32 pb_status;
+	__u32 pb_type;		/* request/reply/err type: PTL_RPC_MSG_* */
+	__u32 pb_version;	/* LUSTRE_*_VERSION | PTLRPC_MSG_VERSION */
+	__u32 pb_opc;		/* RPC opcodes: MDS_*, OST_*, LDLM_, ... */
+	__u32 pb_status;	/* negative Linux x86 error number */
 	__u64 pb_last_xid;	/* highest replied XID without lower unreplied XID */
 	__u16 pb_tag;		/* virtual slot idx for multiple modifying RPCs */
 	__u16 pb_padding0;
 	__u32 pb_padding1;
-	__u64 pb_last_committed;
-	__u64 pb_transno;
-	__u32 pb_flags;
-	__u32 pb_op_flags;
-	__u32 pb_conn_cnt;
-	__u32 pb_timeout;	/* for req, the deadline, for rep, the service est */
-	__u32 pb_service_time;	/* for rep, actual service time */
-	__u32 pb_limit;
-	__u64 pb_slv;
-	/* VBR: pre-versions */
+	__u64 pb_last_committed;/* rep: highest pb_transno committed to disk */
+	__u64 pb_transno;	/* server-assigned transno for modifying RPCs */
+	__u32 pb_flags;		/* req: MSG_* flags */
+	__u32 pb_op_flags;	/* req: MSG_CONNECT_* flags */
+	__u32 pb_conn_cnt;	/* connect instance of this client on server */
+	__u32 pb_timeout;	/* req: max wait time; rep: service estimate */
+	__u32 pb_service_time;	/* rep: server arrival to reply in seconds */
+	__u32 pb_limit;		/* rep: dynamic DLM LRU lock count limit */
+	__u64 pb_slv;		/* rep: dynamic DLM LRU server lock volume */
+	/* VBR: rep: previous pb_version(s) of objects modified by this RPC */
 	__u64 pb_pre_versions[PTLRPC_NUM_VERSIONS];
 	__u64 pb_mbits;		/**< match bits for bulk request */
-	/* padding for future needs */
+	/* padding for future needs - fix lustre_swab_ptlrpc_body() also */
 	__u64 pb_padding64_0;
 	__u64 pb_padding64_1;
 	__u64 pb_padding64_2;
-	char  pb_jobid[LUSTRE_JOBID_SIZE];
+	char  pb_jobid[LUSTRE_JOBID_SIZE]; /* req: ASCII MPI jobid from env */
 };
 
 #define ptlrpc_body	ptlrpc_body_v3
@@ -656,39 +687,6 @@ struct ptlrpc_body_v2 {
 /** only use in req->rq_{req,rep}_swab_mask */
 #define MSG_PTLRPC_HEADER_OFF		31
 
-/* Flags that are operation-specific go in the top 16 bits. */
-#define MSG_OP_FLAG_MASK		0xffff0000
-#define MSG_OP_FLAG_SHIFT		16
-
-/* Flags that apply to all requests are in the bottom 16 bits */
-#define MSG_GEN_FLAG_MASK	0x0000ffff
-#define MSG_LAST_REPLAY		0x0001
-#define MSG_RESENT		0x0002
-#define MSG_REPLAY		0x0004
-/* #define MSG_AT_SUPPORT	0x0008
- * This was used in early prototypes of adaptive timeouts, and while there
- * shouldn't be any users of that code there also isn't a need for using this
- * bits. Defer usage until at least 1.10 to avoid potential conflict.
- */
-#define MSG_DELAY_REPLAY	0x0010
-#define MSG_VERSION_REPLAY	0x0020
-#define MSG_REQ_REPLAY_DONE	0x0040
-#define MSG_LOCK_REPLAY_DONE	0x0080
-
-/*
- * Flags for all connect opcodes (MDS_CONNECT, OST_CONNECT)
- */
-
-#define MSG_CONNECT_RECOVERING	0x00000001
-#define MSG_CONNECT_RECONNECT	0x00000002
-#define MSG_CONNECT_REPLAYABLE	0x00000004
-/*#define MSG_CONNECT_PEER	0x8 */
-#define MSG_CONNECT_LIBCLIENT	0x00000010
-#define MSG_CONNECT_INITIAL	0x00000020
-#define MSG_CONNECT_ASYNC	0x00000040
-#define MSG_CONNECT_NEXT_VER	0x00000080 /* use next version of lustre_msg */
-#define MSG_CONNECT_TRANSNO	0x00000100 /* report transno */
-
 /* Connect flags */
 #define OBD_CONNECT_RDONLY		  0x1ULL /*client has read-only access*/
 #define OBD_CONNECT_INDEX		  0x2ULL /*connect specific LOV idx */
@@ -2225,9 +2223,9 @@ struct ldlm_lock_desc {
 #define LDLM_ENQUEUE_CANCEL_OFF 1
 
 struct ldlm_request {
-	__u32 lock_flags;
-	__u32 lock_count;
-	struct ldlm_lock_desc lock_desc;
+	__u32 lock_flags;		/* LDLM_FL_*, see lustre_dlm_flags.h */
+	__u32 lock_count;		/* number of locks in lock_handle[] */
+	struct ldlm_lock_desc lock_desc;/* lock descriptor */
 	struct lustre_handle lock_handle[LDLM_LOCKREQ_HANDLES];
 };
 
@@ -2273,7 +2271,7 @@ struct mgs_target_info {
 	__u32		mti_lustre_ver;
 	__u32		mti_stripe_index;
 	__u32		mti_config_ver;
-	__u32		mti_flags;
+	__u32		mti_flags;	/* LDD_F_* */
 	__u32		mti_nid_count;
 	__u32		mti_instance; /* Running instance of target */
 	char		mti_fsname[MTI_NAME_MAXLEN];
diff --git a/include/uapi/linux/lustre/lustre_user.h b/include/uapi/linux/lustre/lustre_user.h
index ad50f95..e9bb3d6 100644
--- a/include/uapi/linux/lustre/lustre_user.h
+++ b/include/uapi/linux/lustre/lustre_user.h
@@ -107,21 +107,22 @@ enum obd_statfs_state {
 };
 
 struct obd_statfs {
-	__u64	os_type;
-	__u64	os_blocks;
-	__u64	os_bfree;
-	__u64	os_bavail;
-	__u64	os_files;
-	__u64	os_ffree;
-	__u8	os_fsid[40];
-	__u32	os_bsize;
-	__u32	os_namelen;
-	__u64	os_maxbytes;
+	__u64	os_type;	/* EXT4_SUPER_MAGIC, UBERBLOCK_MAGIC */
+	__u64	os_blocks;	/* total size in #os_bsize blocks */
+	__u64	os_bfree;	/* number of unused blocks */
+	__u64	os_bavail;	/* blocks available for allocation */
+	__u64	os_files;	/* total number of objects */
+	__u64	os_ffree;	/* # objects that could be created */
+	__u8	os_fsid[40];	/* identifier for filesystem */
+	__u32	os_bsize;	/* block size in bytes for os_blocks */
+	__u32	os_namelen;	/* maximum length of filename in bytes*/
+	__u64	os_maxbytes;	/* maximum object size in bytes */
 	__u32	os_state;	/**< obd_statfs_state OS_STATE_* flag */
 	__u32	os_fprecreated;	/* objs available now to the caller
-				 * used in QoS code to find preferred OSTs */
-	__u32	os_spare2;
-	__u32	os_spare3;
+				 * used in QoS code to find preferred OSTs
+				 */
+	__u32	os_spare2;	/* Unused padding fields.  Remember */
+	__u32	os_spare3;	/* to fix lustre_swab_obd_statfs() */
 	__u32	os_spare4;
 	__u32	os_spare5;
 	__u32	os_spare6;
-- 
1.8.3.1
