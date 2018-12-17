From: James Simmons <jsimmons@infradead.org>
Date: Mon, 17 Dec 2018 11:29:58 -0500
Subject: [lustre-devel] [PATCH 24/28] lustre: lov: readahead shouldn't
 exceed component boundary
In-Reply-To: <1545064202-22483-1-git-send-email-jsimmons@infradead.org>
References: <1545064202-22483-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1545064202-22483-25-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Jinshan Xiong <jinshan.xiong@gmail.com>

Otherwise, it will extend the readahead RPC to the next component
while the actual lock of that component is not checked.

Signed-off-by: Jinshan Xiong <jinshan.xiong@gmail.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-9340
Reviewed-on: https://review.whamcloud.com/26677
Reviewed-on: https://review.whamcloud.com/26861
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Niu Yawei <yawei.niu@intel.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/lov/lov_io.c   | 23 ++++++++++++++++-------
 drivers/staging/lustre/lustre/lov/lov_page.c |  4 +++-
 2 files changed, 19 insertions(+), 8 deletions(-)

diff --git a/drivers/staging/lustre/lustre/lov/lov_io.c b/drivers/staging/lustre/lustre/lov/lov_io.c
index ec0d14f..9a3352f 100644
--- a/drivers/staging/lustre/lustre/lov/lov_io.c
+++ b/drivers/staging/lustre/lustre/lov/lov_io.c
@@ -684,28 +684,37 @@ static int lov_io_read_ahead(const struct lu_env *env,
 		return rc;
 
 	/**
-	 * Adjust the stripe index by layout of raid0. ra->cra_end is
+	 * Adjust the stripe index by layout of comp. ra->cra_end is
 	 * the maximum page index covered by an underlying DLM lock.
 	 * This function converts cra_end from stripe level to file
-	 * level, and make sure it's not beyond stripe boundary.
+	 * level, and make sure it's not beyond stripe and component
+	 * boundary.
 	 */
-	if (r0->lo_nr == 1)	/* single stripe file */
-		return 0;
 
 	/* cra_end is stripe level, convert it into file level */
 	ra_end = ra->cra_end;
 	if (ra_end != CL_PAGE_EOF)
-		ra_end = lov_stripe_pgoff(loo->lo_lsm, index, ra_end, stripe);
+		ra->cra_end = lov_stripe_pgoff(loo->lo_lsm, index,
+					       ra_end, stripe);
+
+	/* boundary of current component */
+	ra_end = cl_index(obj, (loff_t)lov_lse(loo, index)->lsme_extent.e_end);
+	if (ra_end != CL_PAGE_EOF && ra->cra_end >= ra_end)
+		ra->cra_end = ra_end - 1;
+
+	if (r0->lo_nr == 1) /* single stripe file */
+		return 0;
 
 	pps = lov_lse(loo, index)->lsme_stripe_size >> PAGE_SHIFT;
 
 	CDEBUG(D_READA,
 	       DFID " max_index = %lu, pps = %u, index = %u, stripe_size = %u, stripe no = %u, start index = %lu\n",
-	       PFID(lu_object_fid(lov2lu(loo))), ra_end, pps, index,
+	       PFID(lu_object_fid(lov2lu(loo))), ra->cra_end, pps, index,
 	       lov_lse(loo, index)->lsme_stripe_size, stripe, start);
 
 	/* never exceed the end of the stripe */
-	ra->cra_end = min_t(pgoff_t, ra_end, start + pps - start % pps - 1);
+	ra->cra_end = min_t(pgoff_t,
+			    ra->cra_end, start + pps - start % pps - 1);
 	return 0;
 }
 
diff --git a/drivers/staging/lustre/lustre/lov/lov_page.c b/drivers/staging/lustre/lustre/lov/lov_page.c
index 8b68d3c..90e2981 100644
--- a/drivers/staging/lustre/lustre/lov/lov_page.c
+++ b/drivers/staging/lustre/lustre/lov/lov_page.c
@@ -56,7 +56,9 @@ static int lov_comp_page_print(const struct lu_env *env,
 {
 	struct lov_page *lp = cl2lov_page(slice);
 
-	return (*printer)(env, cookie, LUSTRE_LOV_NAME "-page@%p, raid0\n", lp);
+	return (*printer)(env, cookie,
+			  LUSTRE_LOV_NAME "-page@%p, comp index: %x\n",
+			  lp, lp->lps_index);
 }
 
 static const struct cl_page_operations lov_comp_page_ops = {
-- 
1.8.3.1
