From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:17:47 -0500
Subject: [lustre-devel] [PATCH 599/622] lustre: llite: Accept EBUSY for page
 unaligned read
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-600-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Patrick Farrell <pfarrell@whamcloud.com>

When doing unaligned strided reads, it's possible for the
first and last page of a stride to be read by another
thread on the same node, resulting in EBUSY.

Also this could potentially happen for sequential read,
for example, several MPI split one large file with unaligned
page size, sequential read happen with each MPI program.

We shouldn't stop readahead in these cases.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12518
Lustre-commit: b9c155065d2c ("LU-12518 llite: Accept EBUSY for page unaligned read")
Signed-off-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/35457
Reviewed-by: Wang Shilong <wshilong@ddn.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/rw.c | 19 +++++++++++++++++--
 1 file changed, 17 insertions(+), 2 deletions(-)

diff --git a/fs/lustre/llite/rw.c b/fs/lustre/llite/rw.c
index 9509023..1b5260d 100644
--- a/fs/lustre/llite/rw.c
+++ b/fs/lustre/llite/rw.c
@@ -360,7 +360,8 @@ static bool ras_inside_ra_window(pgoff_t idx, struct ra_io_arg *ria)
 {
 	struct cl_read_ahead ra = { 0 };
 	pgoff_t page_idx;
-	int count = 0;
+	/* busy page count is per stride */
+	int count = 0, busy_page_count = 0;
 	int rc;
 
 	LASSERT(ria);
@@ -416,8 +417,21 @@ static bool ras_inside_ra_window(pgoff_t idx, struct ra_io_arg *ria)
 
 			/* If the page is inside the read-ahead window */
 			rc = ll_read_ahead_page(env, io, queue, page_idx);
-			if (rc < 0)
+			if (rc < 0 && rc != -EBUSY)
 				break;
+			if (rc == -EBUSY) {
+				busy_page_count++;
+				CDEBUG(D_READA,
+				       "skip busy page: %lu\n", page_idx);
+				/* For page unaligned readahead the first
+				 * last pages of each region can be read by
+				 * another reader on the same node, and so
+				 * may be busy. So only stop for > 2 busy
+				 * pages.
+				 */
+				if (busy_page_count > 2)
+					break;
+			}
 
 			*ra_end = page_idx;
 			/* Only subtract from reserve & count the page if we
@@ -441,6 +455,7 @@ static bool ras_inside_ra_window(pgoff_t idx, struct ra_io_arg *ria)
 				pos += (ria->ria_length - offset);
 				if ((pos >> PAGE_SHIFT) >= page_idx + 1)
 					page_idx = (pos >> PAGE_SHIFT) - 1;
+				busy_page_count = 0;
 				CDEBUG(D_READA,
 				       "Stride: jump %llu pages to %lu\n",
 				       ria->ria_length - offset, page_idx);
-- 
1.8.3.1
