From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Mon, 22 Feb 2016 21:54:09 -0500
Subject: [lustre-devel] [PATCH 31/56] staging/lustre: Remove unused struct
	quota_body
In-Reply-To: <1456196074-754064-1-git-send-email-green@linuxhacker.ru>
References: <1456196074-754064-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1456196074-754064-32-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

It's only used for communications between servers.

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 .../lustre/lustre/include/lustre/lustre_idl.h      | 31 ---------------
 .../lustre/lustre/include/lustre_req_layout.h      |  3 --
 drivers/staging/lustre/lustre/ptlrpc/layout.c      | 36 ------------------
 .../staging/lustre/lustre/ptlrpc/pack_generic.c    | 10 -----
 drivers/staging/lustre/lustre/ptlrpc/wiretest.c    | 44 ----------------------
 5 files changed, 124 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
index ccb1b85..607bfde 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
@@ -1819,37 +1819,6 @@ do {					\
 	Q_COPY(out, in, qc_dqblk);	\
 } while (0)
 
-/* Body of quota request used for quota acquire/release RPCs between quota
- * master (aka QMT) and slaves (ak QSD). */
-struct quota_body {
-	struct lu_fid	qb_fid;     /* FID of global index packing the pool ID
-				      * and type (data or metadata) as well as
-				      * the quota type (user or group). */
-	union lquota_id	qb_id;      /* uid or gid or directory FID */
-	__u32		qb_flags;   /* see below */
-	__u32		qb_padding;
-	__u64		qb_count;   /* acquire/release count (kbytes/inodes) */
-	__u64		qb_usage;   /* current slave usage (kbytes/inodes) */
-	__u64		qb_slv_ver; /* slave index file version */
-	struct lustre_handle	qb_lockh;     /* per-ID lock handle */
-	struct lustre_handle	qb_glb_lockh; /* global lock handle */
-	__u64		qb_padding1[4];
-};
-
-/* When the quota_body is used in the reply of quota global intent
- * lock (IT_QUOTA_CONN) reply, qb_fid contains slave index file FID. */
-#define qb_slv_fid	qb_fid
-/* qb_usage is the current qunit (in kbytes/inodes) when quota_body is used in
- * quota reply */
-#define qb_qunit	qb_usage
-
-#define QUOTA_DQACQ_FL_ACQ	0x1  /* acquire quota */
-#define QUOTA_DQACQ_FL_PREACQ	0x2  /* pre-acquire */
-#define QUOTA_DQACQ_FL_REL	0x4  /* release quota */
-#define QUOTA_DQACQ_FL_REPORT	0x8  /* report usage */
-
-void lustre_swab_quota_body(struct quota_body *b);
-
 /* Quota types currently supported */
 enum {
 	LQUOTA_TYPE_USR	= 0x00, /* maps to USRQUOTA */
diff --git a/drivers/staging/lustre/lustre/include/lustre_req_layout.h b/drivers/staging/lustre/lustre/include/lustre_req_layout.h
index b8a83a1..fdcdd7a 100644
--- a/drivers/staging/lustre/lustre/include/lustre_req_layout.h
+++ b/drivers/staging/lustre/lustre/include/lustre_req_layout.h
@@ -176,7 +176,6 @@ extern struct req_format RQF_MDS_REINT_SETXATTR;
 extern struct req_format RQF_MDS_QUOTACHECK;
 extern struct req_format RQF_MDS_QUOTACTL;
 extern struct req_format RQF_QC_CALLBACK;
-extern struct req_format RQF_QUOTA_DQACQ;
 extern struct req_format RQF_MDS_SWAP_LAYOUTS;
 /* MDS hsm formats */
 extern struct req_format RQF_MDS_HSM_STATE_GET;
@@ -219,7 +218,6 @@ extern struct req_format RQF_LDLM_INTENT_OPEN;
 extern struct req_format RQF_LDLM_INTENT_CREATE;
 extern struct req_format RQF_LDLM_INTENT_UNLINK;
 extern struct req_format RQF_LDLM_INTENT_GETXATTR;
-extern struct req_format RQF_LDLM_INTENT_QUOTA;
 extern struct req_format RQF_LDLM_CANCEL;
 extern struct req_format RQF_LDLM_CALLBACK;
 extern struct req_format RQF_LDLM_CP_CALLBACK;
@@ -276,7 +274,6 @@ extern struct req_msg_field RMF_CAPA1;
 extern struct req_msg_field RMF_CAPA2;
 extern struct req_msg_field RMF_OBD_QUOTACHECK;
 extern struct req_msg_field RMF_OBD_QUOTACTL;
-extern struct req_msg_field RMF_QUOTA_BODY;
 extern struct req_msg_field RMF_STRING;
 extern struct req_msg_field RMF_SWAP_LAYOUTS;
 extern struct req_msg_field RMF_MDS_HSM_PROGRESS;
diff --git a/drivers/staging/lustre/lustre/ptlrpc/layout.c b/drivers/staging/lustre/lustre/ptlrpc/layout.c
index aff9bf5..715088f 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/layout.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/layout.c
@@ -118,25 +118,6 @@ static const struct req_msg_field *quotactl_only[] = {
 	&RMF_OBD_QUOTACTL
 };
 
-static const struct req_msg_field *quota_body_only[] = {
-	&RMF_PTLRPC_BODY,
-	&RMF_QUOTA_BODY
-};
-
-static const struct req_msg_field *ldlm_intent_quota_client[] = {
-	&RMF_PTLRPC_BODY,
-	&RMF_DLM_REQ,
-	&RMF_LDLM_INTENT,
-	&RMF_QUOTA_BODY
-};
-
-static const struct req_msg_field *ldlm_intent_quota_server[] = {
-	&RMF_PTLRPC_BODY,
-	&RMF_DLM_REP,
-	&RMF_DLM_LVB,
-	&RMF_QUOTA_BODY
-};
-
 static const struct req_msg_field *mdt_close_client[] = {
 	&RMF_PTLRPC_BODY,
 	&RMF_MDT_EPOCH,
@@ -748,8 +729,6 @@ static struct req_format *req_formats[] = {
 	&RQF_LDLM_INTENT_CREATE,
 	&RQF_LDLM_INTENT_UNLINK,
 	&RQF_LDLM_INTENT_GETXATTR,
-	&RQF_LDLM_INTENT_QUOTA,
-	&RQF_QUOTA_DQACQ,
 	&RQF_LOG_CANCEL,
 	&RQF_LLOG_ORIGIN_HANDLE_CREATE,
 	&RQF_LLOG_ORIGIN_HANDLE_DESTROY,
@@ -888,11 +867,6 @@ struct req_msg_field RMF_OBD_QUOTACTL =
 		    lustre_swab_obd_quotactl, NULL);
 EXPORT_SYMBOL(RMF_OBD_QUOTACTL);
 
-struct req_msg_field RMF_QUOTA_BODY =
-	DEFINE_MSGF("quota_body", 0,
-		    sizeof(struct quota_body), lustre_swab_quota_body, NULL);
-EXPORT_SYMBOL(RMF_QUOTA_BODY);
-
 struct req_msg_field RMF_MDT_EPOCH =
 	DEFINE_MSGF("mdt_ioepoch", 0,
 		    sizeof(struct mdt_ioepoch), lustre_swab_mdt_ioepoch, NULL);
@@ -1233,16 +1207,6 @@ struct req_format RQF_QC_CALLBACK =
 	DEFINE_REQ_FMT0("QC_CALLBACK", quotactl_only, empty);
 EXPORT_SYMBOL(RQF_QC_CALLBACK);
 
-struct req_format RQF_QUOTA_DQACQ =
-	DEFINE_REQ_FMT0("QUOTA_DQACQ", quota_body_only, quota_body_only);
-EXPORT_SYMBOL(RQF_QUOTA_DQACQ);
-
-struct req_format RQF_LDLM_INTENT_QUOTA =
-	DEFINE_REQ_FMT0("LDLM_INTENT_QUOTA",
-			ldlm_intent_quota_client,
-			ldlm_intent_quota_server);
-EXPORT_SYMBOL(RQF_LDLM_INTENT_QUOTA);
-
 struct req_format RQF_MDS_GETSTATUS =
 	DEFINE_REQ_FMT0("MDS_GETSTATUS", mdt_body_only, mdt_body_capa);
 EXPORT_SYMBOL(RQF_MDS_GETSTATUS);
diff --git a/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c b/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
index 8b020fb..d6f0e6d 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
@@ -2033,16 +2033,6 @@ void lustre_swab_ldlm_reply(struct ldlm_reply *r)
 }
 EXPORT_SYMBOL(lustre_swab_ldlm_reply);
 
-void lustre_swab_quota_body(struct quota_body *b)
-{
-	lustre_swab_lu_fid(&b->qb_fid);
-	lustre_swab_lu_fid((struct lu_fid *)&b->qb_id);
-	__swab32s(&b->qb_flags);
-	__swab64s(&b->qb_count);
-	__swab64s(&b->qb_usage);
-	__swab64s(&b->qb_slv_ver);
-}
-
 /* Dump functions */
 void dump_ioo(struct obd_ioobj *ioo)
 {
diff --git a/drivers/staging/lustre/lustre/ptlrpc/wiretest.c b/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
index 799a85ac..c61d46f 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
@@ -3720,50 +3720,6 @@ void lustre_assert_wire_constants(void)
 	LASSERTF((int)sizeof(((struct ll_fiemap_info_key *)0)->fiemap) == 32, "found %lld\n",
 		 (long long)(int)sizeof(((struct ll_fiemap_info_key *)0)->fiemap));
 
-	/* Checks for struct quota_body */
-	LASSERTF((int)sizeof(struct quota_body) == 112, "found %lld\n",
-		 (long long)(int)sizeof(struct quota_body));
-	LASSERTF((int)offsetof(struct quota_body, qb_fid) == 0, "found %lld\n",
-		 (long long)(int)offsetof(struct quota_body, qb_fid));
-	LASSERTF((int)sizeof(((struct quota_body *)0)->qb_fid) == 16, "found %lld\n",
-		 (long long)(int)sizeof(((struct quota_body *)0)->qb_fid));
-	LASSERTF((int)offsetof(struct quota_body, qb_id) == 16, "found %lld\n",
-		 (long long)(int)offsetof(struct quota_body, qb_id));
-	LASSERTF((int)sizeof(((struct quota_body *)0)->qb_id) == 16, "found %lld\n",
-		 (long long)(int)sizeof(((struct quota_body *)0)->qb_id));
-	LASSERTF((int)offsetof(struct quota_body, qb_flags) == 32, "found %lld\n",
-		 (long long)(int)offsetof(struct quota_body, qb_flags));
-	LASSERTF((int)sizeof(((struct quota_body *)0)->qb_flags) == 4, "found %lld\n",
-		 (long long)(int)sizeof(((struct quota_body *)0)->qb_flags));
-	LASSERTF((int)offsetof(struct quota_body, qb_padding) == 36, "found %lld\n",
-		 (long long)(int)offsetof(struct quota_body, qb_padding));
-	LASSERTF((int)sizeof(((struct quota_body *)0)->qb_padding) == 4, "found %lld\n",
-		 (long long)(int)sizeof(((struct quota_body *)0)->qb_padding));
-	LASSERTF((int)offsetof(struct quota_body, qb_count) == 40, "found %lld\n",
-		 (long long)(int)offsetof(struct quota_body, qb_count));
-	LASSERTF((int)sizeof(((struct quota_body *)0)->qb_count) == 8, "found %lld\n",
-		 (long long)(int)sizeof(((struct quota_body *)0)->qb_count));
-	LASSERTF((int)offsetof(struct quota_body, qb_usage) == 48, "found %lld\n",
-		 (long long)(int)offsetof(struct quota_body, qb_usage));
-	LASSERTF((int)sizeof(((struct quota_body *)0)->qb_usage) == 8, "found %lld\n",
-		 (long long)(int)sizeof(((struct quota_body *)0)->qb_usage));
-	LASSERTF((int)offsetof(struct quota_body, qb_slv_ver) == 56, "found %lld\n",
-		 (long long)(int)offsetof(struct quota_body, qb_slv_ver));
-	LASSERTF((int)sizeof(((struct quota_body *)0)->qb_slv_ver) == 8, "found %lld\n",
-		 (long long)(int)sizeof(((struct quota_body *)0)->qb_slv_ver));
-	LASSERTF((int)offsetof(struct quota_body, qb_lockh) == 64, "found %lld\n",
-		 (long long)(int)offsetof(struct quota_body, qb_lockh));
-	LASSERTF((int)sizeof(((struct quota_body *)0)->qb_lockh) == 8, "found %lld\n",
-		 (long long)(int)sizeof(((struct quota_body *)0)->qb_lockh));
-	LASSERTF((int)offsetof(struct quota_body, qb_glb_lockh) == 72, "found %lld\n",
-		 (long long)(int)offsetof(struct quota_body, qb_glb_lockh));
-	LASSERTF((int)sizeof(((struct quota_body *)0)->qb_glb_lockh) == 8, "found %lld\n",
-		 (long long)(int)sizeof(((struct quota_body *)0)->qb_glb_lockh));
-	LASSERTF((int)offsetof(struct quota_body, qb_padding1[4]) == 112, "found %lld\n",
-		 (long long)(int)offsetof(struct quota_body, qb_padding1[4]));
-	LASSERTF((int)sizeof(((struct quota_body *)0)->qb_padding1[4]) == 8, "found %lld\n",
-		 (long long)(int)sizeof(((struct quota_body *)0)->qb_padding1[4]));
-
 	/* Checks for struct mgs_target_info */
 	LASSERTF((int)sizeof(struct mgs_target_info) == 4544, "found %lld\n",
 		 (long long)(int)sizeof(struct mgs_target_info));
-- 
2.1.0
