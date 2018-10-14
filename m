From: James Simmons <jsimmons@infradead.org>
Date: Sun, 14 Oct 2018 14:57:57 -0400
Subject: [lustre-devel] [PATCH 07/28] lustre: llite: pipeline readahead
 better with large I/O
In-Reply-To: <1539543498-29105-1-git-send-email-jsimmons@infradead.org>
References: <1539543498-29105-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1539543498-29105-8-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Jinshan Xiong <jinshan.xiong@gmail.com>

Fixed a bug where next readahead is not set correctly when
appplication issues large I/O;
Extend the readahead window length to at least cover the size of
current I/O.

Signed-off-by: Jinshan Xiong <jinshan.xiong@gmail.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-9574
Reviewed-on: https://review.whamcloud.com/27388
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Reviewed-by: Patrick Farrell <paf@cray.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/rw.c | 29 ++++++++++++-----------------
 1 file changed, 12 insertions(+), 17 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/rw.c b/drivers/staging/lustre/lustre/llite/rw.c
index 82d874a..9cc0d4fe 100644
--- a/drivers/staging/lustre/lustre/llite/rw.c
+++ b/drivers/staging/lustre/lustre/llite/rw.c
@@ -494,10 +494,8 @@ static int ll_readahead(const struct lu_env *env, struct cl_io *io,
 			end = end_index;
 			ria->ria_eof = true;
 		}
-
-		ras->ras_next_readahead = max(end, end + 1);
-		RAS_CDEBUG(ras);
 	}
+
 	ria->ria_start = start;
 	ria->ria_end = end;
 	/* If stride I/O mode is detected, get stride window*/
@@ -518,6 +516,7 @@ static int ll_readahead(const struct lu_env *env, struct cl_io *io,
 		return 0;
 	}
 
+	RAS_CDEBUG(ras);
 	CDEBUG(D_READA, DFID ": ria: %lu/%lu, bead: %lu/%lu, hit: %d\n",
 	       PFID(lu_object_fid(&clob->co_lu)),
 	       ria->ria_start, ria->ria_end,
@@ -555,25 +554,20 @@ static int ll_readahead(const struct lu_env *env, struct cl_io *io,
 	if (ra_end == end && ra_end == (kms >> PAGE_SHIFT))
 		ll_ra_stats_inc(inode, RA_STAT_EOF);
 
-	/* if we didn't get to the end of the region we reserved from
-	 * the ras we need to go back and update the ras so that the
-	 * next read-ahead tries from where we left off.  we only do so
-	 * if the region we failed to issue read-ahead on is still ahead
-	 * of the app and behind the next index to start read-ahead from
-	 */
 	CDEBUG(D_READA, "ra_end = %lu end = %lu stride end = %lu pages = %d\n",
 	       ra_end, end, ria->ria_end, ret);
 
-	if (ra_end > 0 && ra_end != end) {
+	if (ra_end != end)
 		ll_ra_stats_inc(inode, RA_STAT_FAILED_REACH_END);
+
+	if (ra_end > 0) {
+		/* update the ras so that the next read-ahead tries from
+		 * where we left off.
+		 */
 		spin_lock(&ras->ras_lock);
-		if (ra_end <= ras->ras_next_readahead &&
-		    index_in_window(ra_end, ras->ras_window_start, 0,
-				    ras->ras_window_len)) {
-			ras->ras_next_readahead = ra_end + 1;
-			RAS_CDEBUG(ras);
-		}
+		ras->ras_next_readahead = ra_end + 1;
 		spin_unlock(&ras->ras_lock);
+		RAS_CDEBUG(ras);
 	}
 
 	return ret;
@@ -857,7 +851,8 @@ static void ras_update(struct ll_sb_info *sbi, struct inode *inode,
 		 * of read-ahead, so we use original offset here,
 		 * instead of ras_window_start, which is RPC aligned
 		 */
-		ras->ras_next_readahead = max(index, ras->ras_next_readahead);
+		ras->ras_next_readahead = max(index + 1,
+					      ras->ras_next_readahead);
 		ras->ras_window_start = max(ras->ras_stride_offset,
 					    ras->ras_window_start);
 	} else {
-- 
1.8.3.1
