From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Wed, 24 Feb 2016 21:59:59 -0500
Subject: [lustre-devel] [PATCH v2 16/84] staging/lustre: Get rid of object
	update code
In-Reply-To: <1456369267-904461-1-git-send-email-green@linuxhacker.ru>
References: <1456369267-904461-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1456369267-904461-17-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

Object update was originally planned to be used for cross-server
updates, so nothign to do with the client. The idea was
later significantly reworked anyway so even wire structs should
not be retained.

This gets rid of update_cmd_t, UPDATE and UPDATE_REPLY rpc and
corresponding subcommands, swabbig logic and such.

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 .../staging/lustre/lustre/include/lprocfs_status.h | 16 +---
 .../lustre/lustre/include/lustre/lustre_idl.h      | 94 ----------------------
 .../lustre/lustre/include/lustre_req_layout.h      |  4 -
 drivers/staging/lustre/lustre/ptlrpc/layout.c      | 25 ------
 .../staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c    |  1 -
 .../staging/lustre/lustre/ptlrpc/pack_generic.c    | 18 -----
 drivers/staging/lustre/lustre/ptlrpc/wiretest.c    | 84 -------------------
 7 files changed, 1 insertion(+), 241 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lprocfs_status.h b/drivers/staging/lustre/lustre/include/lprocfs_status.h
index 88f754e..54e5aee 100644
--- a/drivers/staging/lustre/lustre/include/lprocfs_status.h
+++ b/drivers/staging/lustre/lustre/include/lprocfs_status.h
@@ -284,19 +284,6 @@ static inline int opcode_offset(__u32 opc)
 			OPC_RANGE(LDLM) +
 			OPC_RANGE(MDS) +
 			OPC_RANGE(OST));
-	} else if (opc < UPDATE_LAST_OPC) {
-		/* update opcode */
-		return (opc - UPDATE_FIRST_OPC +
-			OPC_RANGE(FLD) +
-			OPC_RANGE(SEC) +
-			OPC_RANGE(SEQ) +
-			OPC_RANGE(QUOTA) +
-			OPC_RANGE(LLOG) +
-			OPC_RANGE(OBD) +
-			OPC_RANGE(MGS) +
-			OPC_RANGE(LDLM) +
-			OPC_RANGE(MDS) +
-			OPC_RANGE(OST));
 	} else {
 		/* Unknown Opcode */
 		return -1;
@@ -312,8 +299,7 @@ static inline int opcode_offset(__u32 opc)
 			    OPC_RANGE(SEC)  + \
 			    OPC_RANGE(SEQ)  + \
 			    OPC_RANGE(SEC)  + \
-			    OPC_RANGE(FLD)  + \
-			    OPC_RANGE(UPDATE))
+			    OPC_RANGE(FLD))
 
 #define EXTRA_MAX_OPCODES ((PTLRPC_LAST_CNTR - PTLRPC_FIRST_CNTR)  + \
 			    OPC_RANGE(EXTRA))
diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
index d68748b..af70ebb 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
@@ -2053,14 +2053,6 @@ enum mds_cmd {
 
 #define MDS_FIRST_OPC    MDS_GETATTR
 
-/* opcodes for object update */
-typedef enum {
-	UPDATE_OBJ	= 1000,
-	UPDATE_LAST_OPC
-} update_cmd_t;
-
-#define UPDATE_FIRST_OPC    UPDATE_OBJ
-
 /*
  * Do not exceed 63
  */
@@ -3576,92 +3568,6 @@ void lustre_swab_hsm_user_state(struct hsm_user_state *hus);
 void lustre_swab_hsm_user_item(struct hsm_user_item *hui);
 void lustre_swab_hsm_request(struct hsm_request *hr);
 
-/**
- * These are object update opcode under UPDATE_OBJ, which is currently
- * being used by cross-ref operations between MDT.
- *
- * During the cross-ref operation, the Master MDT, which the client send the
- * request to, will disassembly the operation into object updates, then OSP
- * will send these updates to the remote MDT to be executed.
- *
- *   Update request format
- *   magic:  UPDATE_BUFFER_MAGIC_V1
- *   Count:  How many updates in the req.
- *   bufs[0] : following are packets of object.
- *   update[0]:
- *		type: object_update_op, the op code of update
- *		fid: The object fid of the update.
- *		lens/bufs: other parameters of the update.
- *   update[1]:
- *		type: object_update_op, the op code of update
- *		fid: The object fid of the update.
- *		lens/bufs: other parameters of the update.
- *   ..........
- *   update[7]:	type: object_update_op, the op code of update
- *		fid: The object fid of the update.
- *		lens/bufs: other parameters of the update.
- *   Current 8 maxim updates per object update request.
- *
- *******************************************************************
- *   update reply format:
- *
- *   ur_version: UPDATE_REPLY_V1
- *   ur_count:   The count of the reply, which is usually equal
- *		 to the number of updates in the request.
- *   ur_lens:    The reply lengths of each object update.
- *
- *   replies:    1st update reply  [4bytes_ret: other body]
- *		 2nd update reply  [4bytes_ret: other body]
- *		 .....
- *		 nth update reply  [4bytes_ret: other body]
- *
- *   For each reply of the update, the format would be
- *	 result(4 bytes):Other stuff
- */
-
-#define UPDATE_MAX_OPS		10
-#define UPDATE_BUFFER_MAGIC_V1	0xBDDE0001
-#define UPDATE_BUFFER_MAGIC	UPDATE_BUFFER_MAGIC_V1
-#define UPDATE_BUF_COUNT	8
-enum object_update_op {
-	OBJ_CREATE		= 1,
-	OBJ_DESTROY		= 2,
-	OBJ_REF_ADD		= 3,
-	OBJ_REF_DEL		= 4,
-	OBJ_ATTR_SET		= 5,
-	OBJ_ATTR_GET		= 6,
-	OBJ_XATTR_SET		= 7,
-	OBJ_XATTR_GET		= 8,
-	OBJ_INDEX_LOOKUP	= 9,
-	OBJ_INDEX_INSERT	= 10,
-	OBJ_INDEX_DELETE	= 11,
-	OBJ_LAST
-};
-
-struct update {
-	__u32		u_type;
-	__u32		u_batchid;
-	struct lu_fid	u_fid;
-	__u32		u_lens[UPDATE_BUF_COUNT];
-	__u32		u_bufs[0];
-};
-
-struct update_buf {
-	__u32	ub_magic;
-	__u32	ub_count;
-	__u32	ub_bufs[0];
-};
-
-#define UPDATE_REPLY_V1		0x00BD0001
-struct update_reply {
-	__u32	ur_version;
-	__u32	ur_count;
-	__u32	ur_lens[0];
-};
-
-void lustre_swab_update_buf(struct update_buf *ub);
-void lustre_swab_update_reply_buf(struct update_reply *ur);
-
 /** layout swap request structure
  * fid1 and fid2 are in mdt_body
  */
diff --git a/drivers/staging/lustre/lustre/include/lustre_req_layout.h b/drivers/staging/lustre/lustre/include/lustre_req_layout.h
index 46a662f..b8a83a1 100644
--- a/drivers/staging/lustre/lustre/include/lustre_req_layout.h
+++ b/drivers/staging/lustre/lustre/include/lustre_req_layout.h
@@ -146,7 +146,6 @@ extern struct req_format RQF_MDS_GETSTATUS;
 extern struct req_format RQF_MDS_SYNC;
 extern struct req_format RQF_MDS_GETXATTR;
 extern struct req_format RQF_MDS_GETATTR;
-extern struct req_format RQF_UPDATE_OBJ;
 
 /*
  * This is format of direct (non-intent) MDS_GETATTR_NAME request.
@@ -322,9 +321,6 @@ extern struct req_msg_field RMF_MGS_CONFIG_RES;
 /* generic uint32 */
 extern struct req_msg_field RMF_U32;
 
-/* OBJ update format */
-extern struct req_msg_field RMF_UPDATE;
-extern struct req_msg_field RMF_UPDATE_REPLY;
 /** @} req_layout */
 
 #endif /* _LUSTRE_REQ_LAYOUT_H__ */
diff --git a/drivers/staging/lustre/lustre/ptlrpc/layout.c b/drivers/staging/lustre/lustre/ptlrpc/layout.c
index 9601b2a..aff9bf5 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/layout.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/layout.c
@@ -514,16 +514,6 @@ static const struct req_msg_field *mds_setattr_server[] = {
 	&RMF_CAPA2
 };
 
-static const struct req_msg_field *mds_update_client[] = {
-	&RMF_PTLRPC_BODY,
-	&RMF_UPDATE,
-};
-
-static const struct req_msg_field *mds_update_server[] = {
-	&RMF_PTLRPC_BODY,
-	&RMF_UPDATE_REPLY,
-};
-
 static const struct req_msg_field *llog_origin_handle_create_client[] = {
 	&RMF_PTLRPC_BODY,
 	&RMF_LLOGD_BODY,
@@ -721,7 +711,6 @@ static struct req_format *req_formats[] = {
 	&RQF_MDS_HSM_ACTION,
 	&RQF_MDS_HSM_REQUEST,
 	&RQF_MDS_SWAP_LAYOUTS,
-	&RQF_UPDATE_OBJ,
 	&RQF_QC_CALLBACK,
 	&RQF_OST_CONNECT,
 	&RQF_OST_DISCONNECT,
@@ -1145,15 +1134,6 @@ struct req_msg_field RMF_MDS_HSM_REQUEST =
 		    lustre_swab_hsm_request, NULL);
 EXPORT_SYMBOL(RMF_MDS_HSM_REQUEST);
 
-struct req_msg_field RMF_UPDATE = DEFINE_MSGF("update", 0, -1,
-					      lustre_swab_update_buf, NULL);
-EXPORT_SYMBOL(RMF_UPDATE);
-
-struct req_msg_field RMF_UPDATE_REPLY = DEFINE_MSGF("update_reply", 0, -1,
-						lustre_swab_update_reply_buf,
-						    NULL);
-EXPORT_SYMBOL(RMF_UPDATE_REPLY);
-
 struct req_msg_field RMF_SWAP_LAYOUTS =
 	DEFINE_MSGF("swap_layouts", 0, sizeof(struct  mdc_swap_layouts),
 		    lustre_swab_swap_layouts, NULL);
@@ -1357,11 +1337,6 @@ struct req_format RQF_MDS_GET_INFO =
 			mds_getinfo_server);
 EXPORT_SYMBOL(RQF_MDS_GET_INFO);
 
-struct req_format RQF_UPDATE_OBJ =
-	DEFINE_REQ_FMT0("OBJECT_UPDATE_OBJ", mds_update_client,
-			mds_update_server);
-EXPORT_SYMBOL(RQF_UPDATE_OBJ);
-
 struct req_format RQF_LDLM_ENQUEUE =
 	DEFINE_REQ_FMT0("LDLM_ENQUEUE",
 			ldlm_enqueue_client, ldlm_enqueue_lvb_server);
diff --git a/drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c b/drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c
index a4a857f..1036400 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c
@@ -131,7 +131,6 @@ static struct ll_rpc_opcode {
 	{ SEC_CTX_INIT_CONT, "sec_ctx_init_cont" },
 	{ SEC_CTX_FINI,     "sec_ctx_fini" },
 	{ FLD_QUERY,	"fld_query" },
-	{ UPDATE_OBJ,	    "update_obj" },
 };
 
 static struct ll_eopcode {
diff --git a/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c b/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
index 36a6ece..8b020fb 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
@@ -2286,24 +2286,6 @@ void lustre_swab_hsm_request(struct hsm_request *hr)
 }
 EXPORT_SYMBOL(lustre_swab_hsm_request);
 
-void lustre_swab_update_buf(struct update_buf *ub)
-{
-	__swab32s(&ub->ub_magic);
-	__swab32s(&ub->ub_count);
-}
-EXPORT_SYMBOL(lustre_swab_update_buf);
-
-void lustre_swab_update_reply_buf(struct update_reply *ur)
-{
-	int i;
-
-	__swab32s(&ur->ur_version);
-	__swab32s(&ur->ur_count);
-	for (i = 0; i < ur->ur_count; i++)
-		__swab32s(&ur->ur_lens[i]);
-}
-EXPORT_SYMBOL(lustre_swab_update_reply_buf);
-
 void lustre_swab_swap_layouts(struct mdc_swap_layouts *msl)
 {
 	__swab64s(&msl->msl_flags);
diff --git a/drivers/staging/lustre/lustre/ptlrpc/wiretest.c b/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
index 61d9ca9..3f9acc2 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
@@ -333,10 +333,6 @@ void lustre_assert_wire_constants(void)
 	CLASSERT(LDLM_MAX_TYPE == 14);
 	CLASSERT(LUSTRE_RES_ID_SEQ_OFF == 0);
 	CLASSERT(LUSTRE_RES_ID_VER_OID_OFF == 1);
-	LASSERTF(UPDATE_OBJ == 1000, "found %lld\n",
-		 (long long)UPDATE_OBJ);
-	LASSERTF(UPDATE_LAST_OPC == 1001, "found %lld\n",
-		 (long long)UPDATE_LAST_OPC);
 	CLASSERT(LUSTRE_RES_ID_QUOTA_SEQ_OFF == 2);
 	CLASSERT(LUSTRE_RES_ID_QUOTA_VER_OID_OFF == 3);
 	CLASSERT(LUSTRE_RES_ID_HSH_OFF == 3);
@@ -437,30 +433,6 @@ void lustre_assert_wire_constants(void)
 		(unsigned)LMAC_NOT_IN_OI);
 	LASSERTF(LMAC_FID_ON_OST == 0x00000008UL, "found 0x%.8xUL\n",
 		(unsigned)LMAC_FID_ON_OST);
-	LASSERTF(OBJ_CREATE == 1, "found %lld\n",
-		 (long long)OBJ_CREATE);
-	LASSERTF(OBJ_DESTROY == 2, "found %lld\n",
-		 (long long)OBJ_DESTROY);
-	LASSERTF(OBJ_REF_ADD == 3, "found %lld\n",
-		 (long long)OBJ_REF_ADD);
-	LASSERTF(OBJ_REF_DEL == 4, "found %lld\n",
-		 (long long)OBJ_REF_DEL);
-	LASSERTF(OBJ_ATTR_SET == 5, "found %lld\n",
-		 (long long)OBJ_ATTR_SET);
-	LASSERTF(OBJ_ATTR_GET == 6, "found %lld\n",
-		 (long long)OBJ_ATTR_GET);
-	LASSERTF(OBJ_XATTR_SET == 7, "found %lld\n",
-		 (long long)OBJ_XATTR_SET);
-	LASSERTF(OBJ_XATTR_GET == 8, "found %lld\n",
-		 (long long)OBJ_XATTR_GET);
-	LASSERTF(OBJ_INDEX_LOOKUP == 9, "found %lld\n",
-		 (long long)OBJ_INDEX_LOOKUP);
-	LASSERTF(OBJ_INDEX_LOOKUP == 9, "found %lld\n",
-		 (long long)OBJ_INDEX_LOOKUP);
-	LASSERTF(OBJ_INDEX_INSERT == 10, "found %lld\n",
-		 (long long)OBJ_INDEX_INSERT);
-	LASSERTF(OBJ_INDEX_DELETE == 11, "found %lld\n",
-		 (long long)OBJ_INDEX_DELETE);
 
 	/* Checks for struct ost_id */
 	LASSERTF((int)sizeof(struct ost_id) == 16, "found %lld\n",
@@ -4431,60 +4403,4 @@ void lustre_assert_wire_constants(void)
 	LASSERTF(sizeof(((struct hsm_user_import *)0)->hui_archive_id) == 4,
 		 "found %lld\n",
 	      (long long)sizeof(((struct hsm_user_import *)0)->hui_archive_id));
-
-	/* Checks for struct update_buf */
-	LASSERTF((int)sizeof(struct update_buf) == 8, "found %lld\n",
-		 (long long)(int)sizeof(struct update_buf));
-	LASSERTF((int)offsetof(struct update_buf, ub_magic) == 0, "found %lld\n",
-		 (long long)(int)offsetof(struct update_buf, ub_magic));
-	LASSERTF((int)sizeof(((struct update_buf *)0)->ub_magic) == 4, "found %lld\n",
-		 (long long)(int)sizeof(((struct update_buf *)0)->ub_magic));
-	LASSERTF((int)offsetof(struct update_buf, ub_count) == 4, "found %lld\n",
-		 (long long)(int)offsetof(struct update_buf, ub_count));
-	LASSERTF((int)sizeof(((struct update_buf *)0)->ub_count) == 4, "found %lld\n",
-		 (long long)(int)sizeof(((struct update_buf *)0)->ub_count));
-	LASSERTF((int)offsetof(struct update_buf, ub_bufs) == 8, "found %lld\n",
-		 (long long)(int)offsetof(struct update_buf, ub_bufs));
-	LASSERTF((int)sizeof(((struct update_buf *)0)->ub_bufs) == 0, "found %lld\n",
-		 (long long)(int)sizeof(((struct update_buf *)0)->ub_bufs));
-
-	/* Checks for struct update_reply */
-	LASSERTF((int)sizeof(struct update_reply) == 8, "found %lld\n",
-		 (long long)(int)sizeof(struct update_reply));
-	LASSERTF((int)offsetof(struct update_reply, ur_version) == 0, "found %lld\n",
-		 (long long)(int)offsetof(struct update_reply, ur_version));
-	LASSERTF((int)sizeof(((struct update_reply *)0)->ur_version) == 4, "found %lld\n",
-		 (long long)(int)sizeof(((struct update_reply *)0)->ur_version));
-	LASSERTF((int)offsetof(struct update_reply, ur_count) == 4, "found %lld\n",
-		 (long long)(int)offsetof(struct update_reply, ur_count));
-	LASSERTF((int)sizeof(((struct update_reply *)0)->ur_count) == 4, "found %lld\n",
-		 (long long)(int)sizeof(((struct update_reply *)0)->ur_count));
-	LASSERTF((int)offsetof(struct update_reply, ur_lens) == 8, "found %lld\n",
-		 (long long)(int)offsetof(struct update_reply, ur_lens));
-	LASSERTF((int)sizeof(((struct update_reply *)0)->ur_lens) == 0, "found %lld\n",
-		 (long long)(int)sizeof(((struct update_reply *)0)->ur_lens));
-
-	/* Checks for struct update */
-	LASSERTF((int)sizeof(struct update) == 56, "found %lld\n",
-		 (long long)(int)sizeof(struct update));
-	LASSERTF((int)offsetof(struct update, u_type) == 0, "found %lld\n",
-		 (long long)(int)offsetof(struct update, u_type));
-	LASSERTF((int)sizeof(((struct update *)0)->u_type) == 4, "found %lld\n",
-		 (long long)(int)sizeof(((struct update *)0)->u_type));
-	LASSERTF((int)offsetof(struct update, u_batchid) == 4, "found %lld\n",
-		 (long long)(int)offsetof(struct update, u_batchid));
-	LASSERTF((int)sizeof(((struct update *)0)->u_batchid) == 4, "found %lld\n",
-		 (long long)(int)sizeof(((struct update *)0)->u_batchid));
-	LASSERTF((int)offsetof(struct update, u_fid) == 8, "found %lld\n",
-		 (long long)(int)offsetof(struct update, u_fid));
-	LASSERTF((int)sizeof(((struct update *)0)->u_fid) == 16, "found %lld\n",
-		 (long long)(int)sizeof(((struct update *)0)->u_fid));
-	LASSERTF((int)offsetof(struct update, u_lens) == 24, "found %lld\n",
-		 (long long)(int)offsetof(struct update, u_lens));
-	LASSERTF((int)sizeof(((struct update *)0)->u_lens) == 32, "found %lld\n",
-		 (long long)(int)sizeof(((struct update *)0)->u_lens));
-	LASSERTF((int)offsetof(struct update, u_bufs) == 56, "found %lld\n",
-		 (long long)(int)offsetof(struct update, u_bufs));
-	LASSERTF((int)sizeof(((struct update *)0)->u_bufs) == 0, "found %lld\n",
-		 (long long)(int)sizeof(((struct update *)0)->u_bufs));
 }
-- 
2.1.0
