From: James Simmons <jsimmons@infradead.org>
Date: Thu, 28 Apr 2016 12:07:34 -0400
Subject: [lustre-devel] [PATCH 4/8] staging: lustre: fld: add local fldb to
	each target
In-Reply-To: <1461859658-22200-1-git-send-email-jsimmons@infradead.org>
References: <1461859658-22200-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1461859658-22200-5-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, wang di <di.wang@intel.com>, James Simmons <jsimmons@infradead.org>

From: wang di <di.wang@intel.com>

Add local FLDB to each MDT, so OSD/OUT can check whether
FID is remote by looking up local FLDB, i.e. no need send RPC
to MDT0. This is just the client part of the work.

Signed-off-by: wang di <di.wang@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-4076
Reviewed-on: http://review.whamcloud.com/7884
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/fid/fid_request.c    |  5 +-
 drivers/staging/lustre/lustre/fld/fld_internal.h   |  9 +--
 drivers/staging/lustre/lustre/fld/fld_request.c    | 79 +++++++++++++++-------
 .../lustre/lustre/include/lustre/lustre_idl.h      | 19 +++++-
 .../lustre/lustre/include/lustre_req_layout.h      |  1 +
 .../staging/lustre/lustre/include/obd_support.h    |  1 +
 drivers/staging/lustre/lustre/ptlrpc/layout.c      | 15 ++++
 .../staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c    |  1 +
 drivers/staging/lustre/lustre/ptlrpc/wiretest.c    |  4 +-
 9 files changed, 95 insertions(+), 39 deletions(-)

diff --git a/drivers/staging/lustre/lustre/fid/fid_request.c b/drivers/staging/lustre/lustre/fid/fid_request.c
index 39269c3..32e4d95 100644
--- a/drivers/staging/lustre/lustre/fid/fid_request.c
+++ b/drivers/staging/lustre/lustre/fid/fid_request.c
@@ -66,6 +66,7 @@ static int seq_client_rpc(struct lu_client_seq *seq,
 	unsigned int           debug_mask;
 	int                    rc;
 
+	LASSERT(exp && !IS_ERR(exp));
 	req = ptlrpc_request_alloc_pack(class_exp2cliimp(exp), &RQF_SEQ_QUERY,
 					LUSTRE_MDS_VERSION, SEQ_QUERY);
 	if (!req)
@@ -110,10 +111,10 @@ static int seq_client_rpc(struct lu_client_seq *seq,
 
 	ptlrpc_at_set_req_timeout(req);
 
-	if (seq->lcs_type == LUSTRE_SEQ_METADATA)
+	if (opc != SEQ_ALLOC_SUPER && seq->lcs_type == LUSTRE_SEQ_METADATA)
 		mdc_get_rpc_lock(exp->exp_obd->u.cli.cl_rpc_lock, NULL);
 	rc = ptlrpc_queue_wait(req);
-	if (seq->lcs_type == LUSTRE_SEQ_METADATA)
+	if (opc != SEQ_ALLOC_SUPER && seq->lcs_type == LUSTRE_SEQ_METADATA)
 		mdc_put_rpc_lock(exp->exp_obd->u.cli.cl_rpc_lock, NULL);
 	if (rc)
 		goto out_req;
diff --git a/drivers/staging/lustre/lustre/fld/fld_internal.h b/drivers/staging/lustre/lustre/fld/fld_internal.h
index e8a3caf..75d6a48 100644
--- a/drivers/staging/lustre/lustre/fld/fld_internal.h
+++ b/drivers/staging/lustre/lustre/fld/fld_internal.h
@@ -101,12 +101,6 @@ struct fld_cache {
 	unsigned int		 fci_no_shrink:1;
 };
 
-enum fld_op {
-	FLD_CREATE = 0,
-	FLD_DELETE = 1,
-	FLD_LOOKUP = 2
-};
-
 enum {
 	/* 4M of FLD cache will not hurt client a lot. */
 	FLD_SERVER_CACHE_SIZE      = (4 * 0x100000),
@@ -126,7 +120,8 @@ enum {
 extern struct lu_fld_hash fld_hash[];
 
 int fld_client_rpc(struct obd_export *exp,
-		   struct lu_seq_range *range, __u32 fld_op);
+		   struct lu_seq_range *range, __u32 fld_op,
+		   struct ptlrpc_request **reqp);
 
 extern struct lprocfs_vars fld_client_debugfs_list[];
 
diff --git a/drivers/staging/lustre/lustre/fld/fld_request.c b/drivers/staging/lustre/lustre/fld/fld_request.c
index 2dfdb51..8150a90 100644
--- a/drivers/staging/lustre/lustre/fld/fld_request.c
+++ b/drivers/staging/lustre/lustre/fld/fld_request.c
@@ -392,55 +392,82 @@ void fld_client_fini(struct lu_client_fld *fld)
 EXPORT_SYMBOL(fld_client_fini);
 
 int fld_client_rpc(struct obd_export *exp,
-		   struct lu_seq_range *range, __u32 fld_op)
+		   struct lu_seq_range *range, __u32 fld_op,
+		   struct ptlrpc_request **reqp)
 {
-	struct ptlrpc_request *req;
+	struct ptlrpc_request *req = NULL;
 	struct lu_seq_range   *prange;
 	__u32		 *op;
-	int		    rc;
+	int		    rc = 0;
 	struct obd_import     *imp;
 
 	LASSERT(exp);
 
 	imp = class_exp2cliimp(exp);
-	req = ptlrpc_request_alloc_pack(imp, &RQF_FLD_QUERY, LUSTRE_MDS_VERSION,
-					FLD_QUERY);
-	if (!req)
-		return -ENOMEM;
-
-	op = req_capsule_client_get(&req->rq_pill, &RMF_FLD_OPC);
-	*op = fld_op;
+	switch (fld_op) {
+	case FLD_QUERY:
+		req = ptlrpc_request_alloc_pack(imp, &RQF_FLD_QUERY,
+						LUSTRE_MDS_VERSION, FLD_QUERY);
+		if (!req)
+			return -ENOMEM;
+
+		/*
+		 * XXX: only needed when talking to old server(< 2.6), it should
+		 * be removed when < 2.6 server is not supported
+		 */
+		op = req_capsule_client_get(&req->rq_pill, &RMF_FLD_OPC);
+		*op = FLD_LOOKUP;
+
+		if (imp->imp_connect_flags_orig & OBD_CONNECT_MDS_MDS)
+			req->rq_allow_replay = 1;
+		break;
+	case FLD_READ:
+		req = ptlrpc_request_alloc_pack(imp, &RQF_FLD_READ,
+						LUSTRE_MDS_VERSION, FLD_READ);
+		if (!req)
+			return -ENOMEM;
+
+		req_capsule_set_size(&req->rq_pill, &RMF_GENERIC_DATA,
+				     RCL_SERVER, PAGE_SIZE);
+		break;
+	default:
+		rc = -EINVAL;
+		break;
+	}
+	if (rc)
+		return rc;
 
 	prange = req_capsule_client_get(&req->rq_pill, &RMF_FLD_MDFLD);
 	*prange = *range;
-
 	ptlrpc_request_set_replen(req);
 	req->rq_request_portal = FLD_REQUEST_PORTAL;
 	req->rq_reply_portal = MDC_REPLY_PORTAL;
 	ptlrpc_at_set_req_timeout(req);
 
-	if (fld_op == FLD_LOOKUP &&
-	    imp->imp_connect_flags_orig & OBD_CONNECT_MDS_MDS)
-		req->rq_allow_replay = 1;
-
-	if (fld_op != FLD_LOOKUP)
-		mdc_get_rpc_lock(exp->exp_obd->u.cli.cl_rpc_lock, NULL);
 	fld_enter_request(&exp->exp_obd->u.cli);
 	rc = ptlrpc_queue_wait(req);
 	fld_exit_request(&exp->exp_obd->u.cli);
-	if (fld_op != FLD_LOOKUP)
-		mdc_put_rpc_lock(exp->exp_obd->u.cli.cl_rpc_lock, NULL);
 	if (rc)
 		goto out_req;
 
-	prange = req_capsule_server_get(&req->rq_pill, &RMF_FLD_MDFLD);
-	if (!prange) {
-		rc = -EFAULT;
-		goto out_req;
+	if (fld_op == FLD_QUERY) {
+		prange = req_capsule_server_get(&req->rq_pill, &RMF_FLD_MDFLD);
+		if (!prange) {
+			rc = -EFAULT;
+			goto out_req;
+		}
+		*range = *prange;
 	}
-	*range = *prange;
+
 out_req:
-	ptlrpc_req_finished(req);
+	if (rc || !reqp) {
+		ptlrpc_req_finished(req);
+		req = NULL;
+	}
+
+	if (reqp)
+		*reqp = req;
+
 	return rc;
 }
 
@@ -468,7 +495,7 @@ int fld_client_lookup(struct lu_client_fld *fld, u64 seq, u32 *mds,
 
 	res.lsr_start = seq;
 	fld_range_set_type(&res, flags);
-	rc = fld_client_rpc(target->ft_exp, &res, FLD_LOOKUP);
+	rc = fld_client_rpc(target->ft_exp, &res, FLD_QUERY, NULL);
 
 	if (rc == 0) {
 		*mds = res.lsr_index;
diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
index 9185ed2..a70545a 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
@@ -183,6 +183,12 @@ struct lu_seq_range {
 	__u32 lsr_flags;
 };
 
+struct lu_seq_range_array {
+	__u32 lsra_count;
+	__u32 lsra_padding;
+	struct lu_seq_range lsra_lsr[0];
+};
+
 #define LU_SEQ_RANGE_MDT	0x0
 #define LU_SEQ_RANGE_OST	0x1
 #define LU_SEQ_RANGE_ANY	0x3
@@ -2447,6 +2453,7 @@ struct mdt_rec_reint {
 
 void lustre_swab_mdt_rec_reint(struct mdt_rec_reint *rr);
 
+/* lmv structures */
 struct lmv_desc {
 	__u32 ld_tgt_count;		/* how many MDS's */
 	__u32 ld_active_tgt_count;	 /* how many active */
@@ -2471,7 +2478,6 @@ struct lmv_stripe_md {
 	struct lu_fid mea_ids[0];
 };
 
-/* lmv structures */
 #define MEA_MAGIC_LAST_CHAR      0xb2221ca1
 #define MEA_MAGIC_ALL_CHARS      0xb222a11c
 #define MEA_MAGIC_HASH_SEGMENT   0xb222a11b
@@ -2481,9 +2487,10 @@ struct lmv_stripe_md {
 #define MAX_HASH_HIGHEST_BIT     0x1000000000000000ULL
 
 enum fld_rpc_opc {
-	FLD_QUERY		       = 900,
+	FLD_QUERY	= 900,
+	FLD_READ	= 901,
 	FLD_LAST_OPC,
-	FLD_FIRST_OPC		   = FLD_QUERY
+	FLD_FIRST_OPC	= FLD_QUERY
 };
 
 enum seq_rpc_opc {
@@ -2497,6 +2504,12 @@ enum seq_op {
 	SEQ_ALLOC_META = 1
 };
 
+enum fld_op {
+	FLD_CREATE = 0,
+	FLD_DELETE = 1,
+	FLD_LOOKUP = 2,
+};
+
 /*
  *  LOV data structures
  */
diff --git a/drivers/staging/lustre/lustre/include/lustre_req_layout.h b/drivers/staging/lustre/lustre/include/lustre_req_layout.h
index b0bc751..0aac439 100644
--- a/drivers/staging/lustre/lustre/include/lustre_req_layout.h
+++ b/drivers/staging/lustre/lustre/include/lustre_req_layout.h
@@ -137,6 +137,7 @@ extern struct req_format RQF_MGS_CONFIG_READ;
 /* fid/fld req_format */
 extern struct req_format RQF_SEQ_QUERY;
 extern struct req_format RQF_FLD_QUERY;
+extern struct req_format RQF_FLD_READ;
 /* MDS req_format */
 extern struct req_format RQF_MDS_CONNECT;
 extern struct req_format RQF_MDS_DISCONNECT;
diff --git a/drivers/staging/lustre/lustre/include/obd_support.h b/drivers/staging/lustre/lustre/include/obd_support.h
index 2aaa343..1358af1 100644
--- a/drivers/staging/lustre/lustre/include/obd_support.h
+++ b/drivers/staging/lustre/lustre/include/obd_support.h
@@ -428,6 +428,7 @@ extern char obd_jobid_var[];
 
 #define OBD_FAIL_FLD		     0x1100
 #define OBD_FAIL_FLD_QUERY_NET	   0x1101
+#define OBD_FAIL_FLD_READ_NET		0x1102
 
 #define OBD_FAIL_SEC_CTX		 0x1200
 #define OBD_FAIL_SEC_CTX_INIT_NET	0x1201
diff --git a/drivers/staging/lustre/lustre/ptlrpc/layout.c b/drivers/staging/lustre/lustre/ptlrpc/layout.c
index ccc1f3e..c0ecd16 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/layout.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/layout.c
@@ -160,6 +160,16 @@ static const struct req_msg_field *fld_query_server[] = {
 	&RMF_FLD_MDFLD
 };
 
+static const struct req_msg_field *fld_read_client[] = {
+	&RMF_PTLRPC_BODY,
+	&RMF_FLD_MDFLD
+};
+
+static const struct req_msg_field *fld_read_server[] = {
+	&RMF_PTLRPC_BODY,
+	&RMF_GENERIC_DATA
+};
+
 static const struct req_msg_field *mds_getattr_name_client[] = {
 	&RMF_PTLRPC_BODY,
 	&RMF_MDT_BODY,
@@ -649,6 +659,7 @@ static struct req_format *req_formats[] = {
 	&RQF_MGS_CONFIG_READ,
 	&RQF_SEQ_QUERY,
 	&RQF_FLD_QUERY,
+	&RQF_FLD_READ,
 	&RQF_MDS_CONNECT,
 	&RQF_MDS_DISCONNECT,
 	&RQF_MDS_GET_INFO,
@@ -1168,6 +1179,10 @@ struct req_format RQF_FLD_QUERY =
 	DEFINE_REQ_FMT0("FLD_QUERY", fld_query_client, fld_query_server);
 EXPORT_SYMBOL(RQF_FLD_QUERY);
 
+struct req_format RQF_FLD_READ =
+	DEFINE_REQ_FMT0("FLD_READ", fld_read_client, fld_read_server);
+EXPORT_SYMBOL(RQF_FLD_READ);
+
 struct req_format RQF_LOG_CANCEL =
 	DEFINE_REQ_FMT0("OBD_LOG_CANCEL", log_cancel_client, empty);
 EXPORT_SYMBOL(RQF_LOG_CANCEL);
diff --git a/drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c b/drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c
index a35b56e..1204201 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c
@@ -131,6 +131,7 @@ static struct ll_rpc_opcode {
 	{ SEC_CTX_INIT_CONT, "sec_ctx_init_cont" },
 	{ SEC_CTX_FINI,     "sec_ctx_fini" },
 	{ FLD_QUERY,	"fld_query" },
+	{ FLD_READ,	"fld_read" },
 };
 
 static struct ll_eopcode {
diff --git a/drivers/staging/lustre/lustre/ptlrpc/wiretest.c b/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
index 308b6b96..aacc810 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
@@ -276,7 +276,9 @@ void lustre_assert_wire_constants(void)
 		 (long long)FLD_QUERY);
 	LASSERTF(FLD_FIRST_OPC == 900, "found %lld\n",
 		 (long long)FLD_FIRST_OPC);
-	LASSERTF(FLD_LAST_OPC == 901, "found %lld\n",
+	LASSERTF(FLD_READ == 901, "found %lld\n",
+		 (long long)FLD_READ);
+	LASSERTF(FLD_LAST_OPC == 902, "found %lld\n",
 		 (long long)FLD_LAST_OPC);
 	LASSERTF(SEQ_QUERY == 700, "found %lld\n",
 		 (long long)SEQ_QUERY);
-- 
2.7.4
