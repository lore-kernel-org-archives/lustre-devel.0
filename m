From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:09:58 -0500
Subject: [lustre-devel] [PATCH 130/622] lustre: ptlrpc: don't change buffer
 when signature is ready
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-131-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mikhail Pershin <mpershin@whamcloud.com>

The lm_repsize is part of buffer being used in signature calculation
and must not be changed after calculation is done.

Patch reverts related changes from commit 13372d6c and moves related
lm_repsize update into MDC where DOM read-on-open buffer is prepared

WC-bug-id: https://jira.whamcloud.com/browse/LU-11414
Lustre-commit: cf503e047c7f ("LU-11414 ptlrpc: don't change buffer when signature is ready")
Signed-off-by: Mikhail Pershin <mpershin@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/33223
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Sebastien Buisson <sbuisson@ddn.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/mdc/mdc_locks.c | 30 +++++++++++++++++++++---------
 fs/lustre/ptlrpc/niobuf.c |  5 -----
 2 files changed, 21 insertions(+), 14 deletions(-)

diff --git a/fs/lustre/mdc/mdc_locks.c b/fs/lustre/mdc/mdc_locks.c
index 80f2e10..09f9bc5 100644
--- a/fs/lustre/mdc/mdc_locks.c
+++ b/fs/lustre/mdc/mdc_locks.c
@@ -256,7 +256,7 @@ static int mdc_save_lovea(struct ptlrpc_request *req,
 	int count = 0;
 	enum ldlm_mode mode;
 	int rc;
-	int repsize;
+	int repsize, repsize_estimate;
 
 	it->it_create_mode = (it->it_create_mode & ~S_IFMT) | S_IFREG;
 
@@ -347,22 +347,34 @@ static int mdc_save_lovea(struct ptlrpc_request *req,
 	/* Get real repbuf allocated size as rounded up power of 2 */
 	repsize = size_roundup_power2(req->rq_replen +
 				      lustre_msg_early_size());
-
 	/* Estimate free space for DoM files in repbuf */
-	repsize -= req->rq_replen - obddev->u.cli.cl_max_mds_easize +
-		   sizeof(struct lov_comp_md_v1) +
-		   sizeof(struct lov_comp_md_entry_v1) +
-		   lov_mds_md_size(0, LOV_MAGIC_V3);
-
-	if (repsize < obddev->u.cli.cl_dom_min_inline_repsize) {
-		repsize = obddev->u.cli.cl_dom_min_inline_repsize - repsize;
+	repsize_estimate = repsize - (req->rq_replen -
+			   obddev->u.cli.cl_max_mds_easize +
+			   sizeof(struct lov_comp_md_v1) +
+			   sizeof(struct lov_comp_md_entry_v1) +
+			   lov_mds_md_size(0, LOV_MAGIC_V3));
+
+	if (repsize_estimate < obddev->u.cli.cl_dom_min_inline_repsize) {
+		repsize = obddev->u.cli.cl_dom_min_inline_repsize -
+			  repsize_estimate + sizeof(struct niobuf_remote);
 		req_capsule_set_size(&req->rq_pill, &RMF_NIOBUF_INLINE,
 				     RCL_SERVER,
 				     sizeof(struct niobuf_remote) + repsize);
 		ptlrpc_request_set_replen(req);
 		CDEBUG(D_INFO, "Increase repbuf by %d bytes, total: %d\n",
 		       repsize, req->rq_replen);
+		repsize = size_roundup_power2(req->rq_replen +
+					      lustre_msg_early_size());
 	}
+	/* The only way to report real allocated repbuf size to the server
+	 * is the lm_repsize but it must be set prior buffer allocation itself
+	 * due to security reasons - it is part of buffer used in signature
+	 * calculation (see LU-11414). Therefore the saved size is predicted
+	 * value as rq_replen rounded to the next higher power of 2.
+	 * Such estimation is safe. Though the final allocated buffer might
+	 * be even larger, it is not possible to know that at this point.
+	 */
+	req->rq_reqmsg->lm_repsize = repsize;
 	return req;
 }
 
diff --git a/fs/lustre/ptlrpc/niobuf.c b/fs/lustre/ptlrpc/niobuf.c
index e8ba57b..2e866fe 100644
--- a/fs/lustre/ptlrpc/niobuf.c
+++ b/fs/lustre/ptlrpc/niobuf.c
@@ -617,11 +617,6 @@ int ptl_send_rpc(struct ptlrpc_request *request, int noreply)
 				request->rq_status = rc;
 				goto cleanup_bulk;
 			}
-			/* Use real allocated value in lm_repsize,
-			 * so the server may use whole reply buffer
-			 * without resends where it is needed.
-			 */
-			request->rq_reqmsg->lm_repsize = request->rq_repbuf_len;
 		} else {
 			request->rq_repdata = NULL;
 			request->rq_repmsg = NULL;
-- 
1.8.3.1
