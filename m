From: James Simmons <jsimmons@infradead.org>
Date: Sun, 14 Oct 2018 14:57:52 -0400
Subject: [lustre-devel] [PATCH 02/28] lustre: llite: Read ahead should
 return pages read
In-Reply-To: <1539543498-29105-1-git-send-email-jsimmons@infradead.org>
References: <1539543498-29105-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1539543498-29105-3-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Patrick Farrell <paf@cray.com>

ll_read_ahead_pages was modified by commit 198a49a964a0
("staging: lustre: clio: revise readahead to support 16MB IO")

and returning the count of pages read was removed.

This only affects debug, but it's very nice to have it
printed out, and several messages still try to print out
pages read ahead, but print 0.

Restore this functionality.

Signed-off-by: Patrick Farrell <paf@cray.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-9778
Reviewed-on: https://review.whamcloud.com/28052
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Ben Evans <bevans@cray.com>
Reviewed-by: Gu Zheng <gzheng@ddn.com>
Reviewed-by: Jinshan Xiong <jinshan.xiong@gmail.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/rw.c | 19 ++++++++++++-------
 1 file changed, 12 insertions(+), 7 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/rw.c b/drivers/staging/lustre/lustre/llite/rw.c
index 49ac723..82d874a 100644
--- a/drivers/staging/lustre/lustre/llite/rw.c
+++ b/drivers/staging/lustre/lustre/llite/rw.c
@@ -342,12 +342,12 @@ static int ras_inside_ra_window(unsigned long idx, struct ra_io_arg *ria)
 static unsigned long
 ll_read_ahead_pages(const struct lu_env *env, struct cl_io *io,
 		    struct cl_page_list *queue, struct ll_readahead_state *ras,
-		    struct ra_io_arg *ria)
+		    struct ra_io_arg *ria, pgoff_t *ra_end)
 {
 	struct cl_read_ahead ra = { 0 };
-	unsigned long ra_end = 0;
 	bool stride_ria;
 	pgoff_t page_idx;
+	int count = 0;
 	int rc;
 
 	LASSERT(ria);
@@ -393,9 +393,14 @@ static int ras_inside_ra_window(unsigned long idx, struct ra_io_arg *ria)
 			if (rc < 0)
 				break;
 
-			ra_end = page_idx;
-			if (!rc)
+			*ra_end = page_idx;
+			/* Only subtract from reserve & count the page if we
+			 * really did readahead on that page.
+			 */
+			if (!rc) {
 				ria->ria_reserved--;
+				count++;
+			}
 		} else if (stride_ria) {
 			/* If it is not in the read-ahead window, and it is
 			 * read-ahead mode, then check whether it should skip
@@ -423,7 +428,7 @@ static int ras_inside_ra_window(unsigned long idx, struct ra_io_arg *ria)
 	}
 	cl_read_ahead_release(env, &ra);
 
-	return ra_end;
+	return count;
 }
 
 static int ll_readahead(const struct lu_env *env, struct cl_io *io,
@@ -434,7 +439,7 @@ static int ll_readahead(const struct lu_env *env, struct cl_io *io,
 	struct ll_thread_info *lti = ll_env_info(env);
 	struct cl_attr *attr = vvp_env_thread_attr(env);
 	unsigned long len, mlen = 0;
-	pgoff_t ra_end, start = 0, end = 0;
+	pgoff_t ra_end = 0, start = 0, end = 0;
 	struct inode *inode;
 	struct ra_io_arg *ria = &lti->lti_ria;
 	struct cl_object *clob;
@@ -542,7 +547,7 @@ static int ll_readahead(const struct lu_env *env, struct cl_io *io,
 	       atomic_read(&ll_i2sbi(inode)->ll_ra_info.ra_cur_pages),
 	       ll_i2sbi(inode)->ll_ra_info.ra_max_pages);
 
-	ra_end = ll_read_ahead_pages(env, io, queue, ras, ria);
+	ret = ll_read_ahead_pages(env, io, queue, ras, ria, &ra_end);
 
 	if (ria->ria_reserved)
 		ll_ra_count_put(ll_i2sbi(inode), ria->ria_reserved);
-- 
1.8.3.1
