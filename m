From: James Simmons <jsimmons@infradead.org>
Date: Fri, 19 Aug 2016 14:07:27 -0400
Subject: [lustre-devel] [PATCH 3/7] staging: lustre: obd: remove unused
	lmv_readpages()/mdc_readpage()
In-Reply-To: <1471630051-26700-1-git-send-email-jsimmons@infradead.org>
References: <1471630051-26700-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1471630051-26700-4-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Jian Yu <jian.yu@intel.com>, James Simmons <jsimmons@infradead.org>

From: Jian Yu <jian.yu@intel.com>

This patch fixes the following compile error by removing the
dead codes: "error: 'xxx_readpages' defined but not used".
Now that we have md_read_page functionality we can remove
all the *_readpage implementations.

Signed-off-by: Jian Yu <jian.yu@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-4669
Reviewed-on: http://review.whamcloud.com/9810
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/lmv/lmv_obd.c     |  146 -----------------------
 drivers/staging/lustre/lustre/mdc/mdc_request.c |   82 -------------
 2 files changed, 0 insertions(+), 228 deletions(-)

diff --git a/drivers/staging/lustre/lustre/lmv/lmv_obd.c b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
index 1f01be4..44a334a 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_obd.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
@@ -2223,151 +2223,6 @@ static int lmv_sync(struct obd_export *exp, const struct lu_fid *fid,
 	return rc;
 }
 
-/*
- * Adjust a set of pages, each page containing an array of lu_dirpages,
- * so that each page can be used as a single logical lu_dirpage.
- *
- * A lu_dirpage is laid out as follows, where s = ldp_hash_start,
- * e = ldp_hash_end, f = ldp_flags, p = padding, and each "ent" is a
- * struct lu_dirent.  It has size up to LU_PAGE_SIZE. The ldp_hash_end
- * value is used as a cookie to request the next lu_dirpage in a
- * directory listing that spans multiple pages (two in this example):
- *   ________
- *  |	|
- * .|--------v-------   -----.
- * |s|e|f|p|ent|ent| ... |ent|
- * '--|--------------   -----'   Each CFS_PAGE contains a single
- *    '------.		   lu_dirpage.
- * .---------v-------   -----.
- * |s|e|f|p|ent| 0 | ... | 0 |
- * '-----------------   -----'
- *
- * However, on hosts where the native VM page size (PAGE_SIZE) is
- * larger than LU_PAGE_SIZE, a single host page may contain multiple
- * lu_dirpages. After reading the lu_dirpages from the MDS, the
- * ldp_hash_end of the first lu_dirpage refers to the one immediately
- * after it in the same CFS_PAGE (arrows simplified for brevity, but
- * in general e0==s1, e1==s2, etc.):
- *
- * .--------------------   -----.
- * |s0|e0|f0|p|ent|ent| ... |ent|
- * |---v----------------   -----|
- * |s1|e1|f1|p|ent|ent| ... |ent|
- * |---v----------------   -----|  Here, each CFS_PAGE contains
- *	     ...		 multiple lu_dirpages.
- * |---v----------------   -----|
- * |s'|e'|f'|p|ent|ent| ... |ent|
- * '---|----------------   -----'
- *     v
- * .----------------------------.
- * |	next CFS_PAGE       |
- *
- * This structure is transformed into a single logical lu_dirpage as follows:
- *
- * - Replace e0 with e' so the request for the next lu_dirpage gets the page
- *   labeled 'next CFS_PAGE'.
- *
- * - Copy the LDF_COLLIDE flag from f' to f0 to correctly reflect whether
- *   a hash collision with the next page exists.
- *
- * - Adjust the lde_reclen of the ending entry of each lu_dirpage to span
- *   to the first entry of the next lu_dirpage.
- */
-#if PAGE_SIZE > LU_PAGE_SIZE
-static void lmv_adjust_dirpages(struct page **pages, int ncfspgs, int nlupgs)
-{
-	int i;
-
-	for (i = 0; i < ncfspgs; i++) {
-		struct lu_dirpage	*dp = kmap(pages[i]);
-		struct lu_dirpage	*first = dp;
-		struct lu_dirent	*end_dirent = NULL;
-		struct lu_dirent	*ent;
-		__u64			hash_end = dp->ldp_hash_end;
-		__u32			flags = dp->ldp_flags;
-
-		while (--nlupgs > 0) {
-			ent = lu_dirent_start(dp);
-			for (end_dirent = ent; ent;
-			     end_dirent = ent, ent = lu_dirent_next(ent))
-				;
-
-			/* Advance dp to next lu_dirpage. */
-			dp = (struct lu_dirpage *)((char *)dp + LU_PAGE_SIZE);
-
-			/* Check if we've reached the end of the CFS_PAGE. */
-			if (!((unsigned long)dp & ~PAGE_MASK))
-				break;
-
-			/* Save the hash and flags of this lu_dirpage. */
-			hash_end = dp->ldp_hash_end;
-			flags = dp->ldp_flags;
-
-			/* Check if lu_dirpage contains no entries. */
-			if (!end_dirent)
-				break;
-
-			/* Enlarge the end entry lde_reclen from 0 to
-			 * first entry of next lu_dirpage.
-			 */
-			LASSERT(le16_to_cpu(end_dirent->lde_reclen) == 0);
-			end_dirent->lde_reclen =
-				cpu_to_le16((char *)(dp->ldp_entries) -
-					    (char *)end_dirent);
-		}
-
-		first->ldp_hash_end = hash_end;
-		first->ldp_flags &= ~cpu_to_le32(LDF_COLLIDE);
-		first->ldp_flags |= flags & cpu_to_le32(LDF_COLLIDE);
-
-		kunmap(pages[i]);
-	}
-	LASSERTF(nlupgs == 0, "left = %d", nlupgs);
-}
-#else
-#define lmv_adjust_dirpages(pages, ncfspgs, nlupgs) do {} while (0)
-#endif	/* PAGE_SIZE > LU_PAGE_SIZE */
-
-static int lmv_readpage(struct obd_export *exp, struct md_op_data *op_data,
-			struct page **pages, struct ptlrpc_request **request)
-{
-	struct obd_device	*obd = exp->exp_obd;
-	struct lmv_obd		*lmv = &obd->u.lmv;
-	__u64			offset = op_data->op_offset;
-	int			rc;
-	int			ncfspgs; /* pages read in PAGE_SIZE */
-	int			nlupgs; /* pages read in LU_PAGE_SIZE */
-	struct lmv_tgt_desc	*tgt;
-
-	rc = lmv_check_connect(obd);
-	if (rc)
-		return rc;
-
-	CDEBUG(D_INODE, "READPAGE at %#llx from "DFID"\n",
-	       offset, PFID(&op_data->op_fid1));
-
-	tgt = lmv_find_target(lmv, &op_data->op_fid1);
-	if (IS_ERR(tgt))
-		return PTR_ERR(tgt);
-
-	rc = md_readpage(tgt->ltd_exp, op_data, pages, request);
-	if (rc != 0)
-		return rc;
-
-	ncfspgs = ((*request)->rq_bulk->bd_nob_transferred + PAGE_SIZE - 1)
-		 >> PAGE_SHIFT;
-	nlupgs = (*request)->rq_bulk->bd_nob_transferred >> LU_PAGE_SHIFT;
-	LASSERT(!((*request)->rq_bulk->bd_nob_transferred & ~LU_PAGE_MASK));
-	LASSERT(ncfspgs > 0 && ncfspgs <= op_data->op_npages);
-
-	CDEBUG(D_INODE, "read %d(%d)/%d pages\n", ncfspgs, nlupgs,
-	       op_data->op_npages);
-
-	lmv_adjust_dirpages(pages, ncfspgs, nlupgs);
-
-	return rc;
-}
-
 /**
  * Get current minimum entry from striped directory
  *
@@ -3595,7 +3450,6 @@ static struct md_ops lmv_md_ops = {
 	.setattr		= lmv_setattr,
 	.setxattr		= lmv_setxattr,
 	.sync			= lmv_sync,
-	.readpage		= lmv_readpage,
 	.read_page		= lmv_read_page,
 	.unlink			= lmv_unlink,
 	.init_ea_size		= lmv_init_ea_size,
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_request.c b/drivers/staging/lustre/lustre/mdc/mdc_request.c
index 9ad855f..5520819 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_request.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_request.c
@@ -938,87 +938,6 @@ static int mdc_done_writing(struct obd_export *exp, struct md_op_data *op_data,
 	return rc;
 }
 
-static int mdc_readpage(struct obd_export *exp, struct md_op_data *op_data,
-			struct page **pages, struct ptlrpc_request **request)
-{
-	struct ptlrpc_request   *req;
-	struct ptlrpc_bulk_desc *desc;
-	int		      i;
-	wait_queue_head_t	      waitq;
-	int		      resends = 0;
-	struct l_wait_info       lwi;
-	int		      rc;
-
-	*request = NULL;
-	init_waitqueue_head(&waitq);
-
-restart_bulk:
-	req = ptlrpc_request_alloc(class_exp2cliimp(exp), &RQF_MDS_READPAGE);
-	if (!req)
-		return -ENOMEM;
-
-	rc = ptlrpc_request_pack(req, LUSTRE_MDS_VERSION, MDS_READPAGE);
-	if (rc) {
-		ptlrpc_request_free(req);
-		return rc;
-	}
-
-	req->rq_request_portal = MDS_READPAGE_PORTAL;
-	ptlrpc_at_set_req_timeout(req);
-
-	desc = ptlrpc_prep_bulk_imp(req, op_data->op_npages, 1, BULK_PUT_SINK,
-				    MDS_BULK_PORTAL);
-	if (!desc) {
-		ptlrpc_request_free(req);
-		return -ENOMEM;
-	}
-
-	/* NB req now owns desc and will free it when it gets freed */
-	for (i = 0; i < op_data->op_npages; i++)
-		ptlrpc_prep_bulk_page_pin(desc, pages[i], 0, PAGE_SIZE);
-
-	mdc_readdir_pack(req, op_data->op_offset,
-			 PAGE_SIZE * op_data->op_npages,
-			 &op_data->op_fid1);
-
-	ptlrpc_request_set_replen(req);
-	rc = ptlrpc_queue_wait(req);
-	if (rc) {
-		ptlrpc_req_finished(req);
-		if (rc != -ETIMEDOUT)
-			return rc;
-
-		resends++;
-		if (!client_should_resend(resends, &exp->exp_obd->u.cli)) {
-			CERROR("too many resend retries, returning error\n");
-			return -EIO;
-		}
-		lwi = LWI_TIMEOUT_INTR(cfs_time_seconds(resends),
-				       NULL, NULL, NULL);
-		l_wait_event(waitq, 0, &lwi);
-
-		goto restart_bulk;
-	}
-
-	rc = sptlrpc_cli_unwrap_bulk_read(req, req->rq_bulk,
-					  req->rq_bulk->bd_nob_transferred);
-	if (rc < 0) {
-		ptlrpc_req_finished(req);
-		return rc;
-	}
-
-	if (req->rq_bulk->bd_nob_transferred & ~LU_PAGE_MASK) {
-		CERROR("Unexpected # bytes transferred: %d (%ld expected)\n",
-		       req->rq_bulk->bd_nob_transferred,
-		       PAGE_SIZE * op_data->op_npages);
-		ptlrpc_req_finished(req);
-		return -EPROTO;
-	}
-
-	*request = req;
-	return 0;
-}
-
 static int mdc_getpage(struct obd_export *exp, const struct lu_fid *fid,
 		       u64 offset, struct page **pages, int npages,
 		       struct ptlrpc_request **request)
@@ -2979,7 +2898,6 @@ static struct md_ops mdc_md_ops = {
 	.setxattr		= mdc_setxattr,
 	.getxattr		= mdc_getxattr,
 	.sync			= mdc_sync,
-	.readpage		= mdc_readpage,
 	.read_page		= mdc_read_page,
 	.unlink			= mdc_unlink,
 	.cancel_unused		= mdc_cancel_unused,
-- 
1.7.1
