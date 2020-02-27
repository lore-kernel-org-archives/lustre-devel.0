From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:15:06 -0500
Subject: [lustre-devel] [PATCH 438/622] lustre: llite: don't miss every
 first stride page
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-439-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Wang Shilong <wshilong@ddn.com>

Whenever we need skip some pages for stride io read, we
will calculate next start page index, however, this page
index is skipped every time, because loop start from index + 1

Testing command: iozone -w -c -i 5 -t1 -j 2 -s 100m -r 1m -F data
Without patch: 587384.69 kB/sec

                        read                    write
pages per rpc         rpcs   % cum % |       rpcs   % cum %
1:                      16  19  19   |          0   0   0
2:                       0   0  19   |          0   0   0
4:                       0   0  19   |          0   0   0
8:                       0   0  19   |          0   0   0
16:                      0   0  19   |          0   0   0
32:                      0   0  19   |          0   0   0
64:                      0   0  19   |          0   0   0
128:                     0   0  19   |          0   0   0
256:                     0   0  19   |          0   0   0
512:                    22  26  46   |          0   0   0
1024:                   44  53 100   |          0   0   0

With patch: 744635.56 kB/sec
                        read                    write
pages per rpc         rpcs   % cum % |       rpcs   % cum %
1:                       0   0   0   |          0   0   0
2:                       0   0   0   |          0   0   0
4:                       0   0   0   |          0   0   0
8:                       0   0   0   |          0   0   0
16:                      0   0   0   |          0   0   0
32:                      0   0   0   |          0   0   0
64:                      0   0   0   |          0   0   0
128:                     0   0   0   |          0   0   0
256:                     0   0   0   |          0   0   0
512:                     8  13  13   |          0   0   0
1024:                   50  86 100   |          0   0   0

We get better performances ~27% up here, and all 1 page RPC
disappear.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12043
Lustre-commit: 29d8eb5ee7df ("LU-12043 llite: don't miss every first stride page")
Signed-off-by: Wang Shilong <wshilong@ddn.com>
Reviewed-on: https://review.whamcloud.com/35216
Reviewed-by: Li Xi <lixi@ddn.com>
Reviewed-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/rw.c | 17 +++++++++--------
 1 file changed, 9 insertions(+), 8 deletions(-)

diff --git a/fs/lustre/llite/rw.c b/fs/lustre/llite/rw.c
index 9c4b89f..4fec9a6 100644
--- a/fs/lustre/llite/rw.c
+++ b/fs/lustre/llite/rw.c
@@ -407,12 +407,12 @@ static int ras_inside_ra_window(unsigned long idx, struct ra_io_arg *ria)
 		} else if (stride_ria) {
 			/* If it is not in the read-ahead window, and it is
 			 * read-ahead mode, then check whether it should skip
-			 * the stride gap
+			 * the stride gap.
 			 */
 			pgoff_t offset;
-			/* FIXME: This assertion only is valid when it is for
-			 * forward read-ahead, it will be fixed when backward
-			 * read-ahead is implemented
+			/* NOTE: This assertion only is valid when it is for
+			 * forward read-ahead, must adjust if backward
+			 * readahead is implemented.
 			 */
 			LASSERTF(page_idx >= ria->ria_stoff,
 				 "Invalid page_idx %lu rs %lu re %lu ro %lu rl %lu rp %lu\n",
@@ -421,10 +421,11 @@ static int ras_inside_ra_window(unsigned long idx, struct ra_io_arg *ria)
 				 ria->ria_length, ria->ria_pages);
 			offset = page_idx - ria->ria_stoff;
 			offset = offset % (ria->ria_length);
-			if (offset > ria->ria_pages) {
-				page_idx += ria->ria_length - offset;
-				CDEBUG(D_READA, "i %lu skip %lu\n", page_idx,
-				       ria->ria_length - offset);
+			if (offset >= ria->ria_pages) {
+				page_idx += ria->ria_length - offset - 1;
+				CDEBUG(D_READA,
+				       "Stride: jump %lu pages to %lu\n",
+				       ria->ria_length - offset, page_idx);
 				continue;
 			}
 		}
-- 
1.8.3.1
