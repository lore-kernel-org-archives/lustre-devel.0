From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Fri, 26 Feb 2016 01:50:06 -0500
Subject: [lustre-devel] [PATCH 18/25] staging/lustre/mdc: Fix style vs open
	parenthesis alignment
In-Reply-To: <1456469413-931943-1-git-send-email-green@linuxhacker.ru>
References: <1456469413-931943-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1456469413-931943-19-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

This mostly fixes checkpatch complaints about
"Alignment should match open parenthesis"

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/mdc/mdc_internal.h |  2 +-
 drivers/staging/lustre/lustre/mdc/mdc_locks.c    | 26 +++++++++++-------------
 drivers/staging/lustre/lustre/mdc/mdc_reint.c    |  2 +-
 drivers/staging/lustre/lustre/mdc/mdc_request.c  | 12 +++++------
 4 files changed, 20 insertions(+), 22 deletions(-)

diff --git a/drivers/staging/lustre/lustre/mdc/mdc_internal.h b/drivers/staging/lustre/lustre/mdc/mdc_internal.h
index 54f4ca6..c5519ae 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_internal.h
+++ b/drivers/staging/lustre/lustre/mdc/mdc_internal.h
@@ -53,7 +53,7 @@ void mdc_readdir_pack(struct ptlrpc_request *req, __u64 pgoff, __u32 size,
 void mdc_getattr_pack(struct ptlrpc_request *req, __u64 valid, int flags,
 		      struct md_op_data *data, int ea_size);
 void mdc_setattr_pack(struct ptlrpc_request *req, struct md_op_data *op_data,
-		     void *ea, int ealen, void *ea2, int ea2len);
+		      void *ea, int ealen, void *ea2, int ea2len);
 void mdc_create_pack(struct ptlrpc_request *req, struct md_op_data *op_data,
 		     const void *data, int datalen, __u32 mode, __u32 uid,
 		     __u32 gid, cfs_cap_t capability, __u64 rdev);
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_locks.c b/drivers/staging/lustre/lustre/mdc/mdc_locks.c
index 6dae574..958a164 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_locks.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_locks.c
@@ -366,7 +366,7 @@ mdc_intent_getxattr_pack(struct obd_export *exp,
 	LIST_HEAD(cancels);
 
 	req = ptlrpc_request_alloc(class_exp2cliimp(exp),
-					&RQF_LDLM_INTENT_GETXATTR);
+				   &RQF_LDLM_INTENT_GETXATTR);
 	if (!req)
 		return ERR_PTR(-ENOMEM);
 
@@ -386,14 +386,12 @@ mdc_intent_getxattr_pack(struct obd_export *exp,
 	mdc_pack_body(req, &op_data->op_fid1, op_data->op_valid, maxdata, -1,
 		      0);
 
-	req_capsule_set_size(&req->rq_pill, &RMF_EADATA,
-				RCL_SERVER, maxdata);
+	req_capsule_set_size(&req->rq_pill, &RMF_EADATA, RCL_SERVER, maxdata);
 
-	req_capsule_set_size(&req->rq_pill, &RMF_EAVALS,
-				RCL_SERVER, maxdata);
+	req_capsule_set_size(&req->rq_pill, &RMF_EAVALS, RCL_SERVER, maxdata);
 
 	req_capsule_set_size(&req->rq_pill, &RMF_EAVALS_LENS,
-				RCL_SERVER, maxdata);
+			     RCL_SERVER, maxdata);
 
 	ptlrpc_request_set_replen(req);
 
@@ -439,8 +437,8 @@ static struct ptlrpc_request *mdc_intent_unlink_pack(struct obd_export *exp,
 }
 
 static struct ptlrpc_request *mdc_intent_getattr_pack(struct obd_export *exp,
-						    struct lookup_intent *it,
-						    struct md_op_data *op_data)
+						      struct lookup_intent *it,
+						     struct md_op_data *op_data)
 {
 	struct ptlrpc_request *req;
 	struct obd_device     *obddev = class_exp2obd(exp);
@@ -498,7 +496,7 @@ static struct ptlrpc_request *mdc_intent_layout_pack(struct obd_export *exp,
 	int rc;
 
 	req = ptlrpc_request_alloc(class_exp2cliimp(exp),
-				&RQF_LDLM_INTENT_LAYOUT);
+				   &RQF_LDLM_INTENT_LAYOUT);
 	if (!req)
 		return ERR_PTR(-ENOMEM);
 
@@ -718,7 +716,7 @@ static int mdc_finish_enqueue(struct obd_export *exp,
 		void *lmm;
 
 		LDLM_DEBUG(lock, "layout lock returned by: %s, lvb_len: %d\n",
-			ldlm_it2str(it->it_op), lvb_len);
+			   ldlm_it2str(it->it_op), lvb_len);
 
 		lmm = libcfs_kvzalloc(lvb_len, GFP_NOFS);
 		if (!lmm) {
@@ -1094,7 +1092,7 @@ int mdc_revalidate_lock(struct obd_export *exp, struct lookup_intent *it,
 		}
 
 		mode = mdc_lock_match(exp, LDLM_FL_BLOCK_GRANTED, fid,
-				       LDLM_IBITS, &policy,
+				      LDLM_IBITS, &policy,
 				      LCK_CR | LCK_CW | LCK_PR | LCK_PW,
 				      &lockh);
 	}
@@ -1264,9 +1262,9 @@ int mdc_intent_getattr_async(struct obd_export *exp,
 	__u64		    flags = LDLM_FL_HAS_INTENT;
 
 	CDEBUG(D_DLMTRACE,
-		"name: %.*s in inode "DFID", intent: %s flags %#Lo\n",
-		op_data->op_namelen, op_data->op_name, PFID(&op_data->op_fid1),
-		ldlm_it2str(it->it_op), it->it_flags);
+	       "name: %.*s in inode " DFID ", intent: %s flags %#Lo\n",
+	       op_data->op_namelen, op_data->op_name, PFID(&op_data->op_fid1),
+	       ldlm_it2str(it->it_op), it->it_flags);
 
 	fid_build_reg_res_name(&op_data->op_fid1, &res_id);
 	req = mdc_intent_getattr_pack(exp, it, op_data);
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_reint.c b/drivers/staging/lustre/lustre/mdc/mdc_reint.c
index 019b237..4ef3db1 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_reint.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_reint.c
@@ -422,7 +422,7 @@ int mdc_rename(struct obd_export *exp, struct md_op_data *op_data,
 						 &cancels, LCK_EX,
 						 MDS_INODELOCK_LOOKUP);
 	if ((op_data->op_flags & MF_MDC_CANCEL_FID4) &&
-	     (fid_is_sane(&op_data->op_fid4)))
+	    (fid_is_sane(&op_data->op_fid4)))
 		count += mdc_resource_get_unused(exp, &op_data->op_fid4,
 						 &cancels, LCK_EX,
 						 MDS_INODELOCK_FULL);
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_request.c b/drivers/staging/lustre/lustre/mdc/mdc_request.c
index c7a0fa1..7bdb205 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_request.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_request.c
@@ -165,7 +165,7 @@ static int mdc_getattr_common(struct obd_export *exp,
 }
 
 static int mdc_getattr(struct obd_export *exp, struct md_op_data *op_data,
-		struct ptlrpc_request **request)
+		       struct ptlrpc_request **request)
 {
 	struct ptlrpc_request *req;
 	int		    rc;
@@ -207,7 +207,7 @@ static int mdc_getattr(struct obd_export *exp, struct md_op_data *op_data,
 }
 
 static int mdc_getattr_name(struct obd_export *exp, struct md_op_data *op_data,
-		     struct ptlrpc_request **request)
+			    struct ptlrpc_request **request)
 {
 	struct ptlrpc_request *req;
 	int		    rc;
@@ -1036,8 +1036,8 @@ restart_bulk:
 
 	if (req->rq_bulk->bd_nob_transferred & ~LU_PAGE_MASK) {
 		CERROR("Unexpected # bytes transferred: %d (%ld expected)\n",
-			req->rq_bulk->bd_nob_transferred,
-			PAGE_CACHE_SIZE * op_data->op_npages);
+		       req->rq_bulk->bd_nob_transferred,
+		       PAGE_CACHE_SIZE * op_data->op_npages);
 		ptlrpc_req_finished(req);
 		return -EPROTO;
 	}
@@ -1815,7 +1815,7 @@ static int mdc_iocontrol(unsigned int cmd, struct obd_export *exp, int len,
 		/* copy UUID */
 		if (copy_to_user(data->ioc_pbuf2, obd2cli_tgt(obd),
 				 min_t(size_t, data->ioc_plen2,
-					       sizeof(struct obd_uuid)))) {
+				       sizeof(struct obd_uuid)))) {
 			rc = -EFAULT;
 			goto out;
 		}
@@ -1828,7 +1828,7 @@ static int mdc_iocontrol(unsigned int cmd, struct obd_export *exp, int len,
 
 		if (copy_to_user(data->ioc_pbuf1, &stat_buf,
 				 min_t(size_t, data->ioc_plen1,
-					       sizeof(stat_buf)))) {
+				       sizeof(stat_buf)))) {
 			rc = -EFAULT;
 			goto out;
 		}
-- 
2.1.0
