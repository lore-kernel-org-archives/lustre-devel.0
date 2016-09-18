From: James Simmons <jsimmons@infradead.org>
Date: Sun, 18 Sep 2016 16:37:10 -0400
Subject: [lustre-devel] [PATCH 011/124] staging: lustre: llite: update ras
	stride offset
In-Reply-To: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
References: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1474231143-4061-12-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Bobi Jam <bobijam.xu@intel.com>, James Simmons <jsimmons@infradead.org>

From: Bobi Jam <bobijam.xu@intel.com>

When a read ahead does not reach the end of the region reserved from
ras, we'd set ras::ras_next_readahead back to where we left off; For
stride read ahead, it needs to make sure that the offset is no less
than ras_stride_offset, so that the stride read ahead can work
correctly.

Signed-off-by: Bobi Jam <bobijam.xu@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5263
Reviewed-on: http://review.whamcloud.com/11181
Reviewed-by: Fan Yong <fan.yong@intel.com>
Reviewed-by: wang di <di.wang@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/rw.c |   18 +++++++++++++++---
 1 files changed, 15 insertions(+), 3 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/rw.c b/drivers/staging/lustre/lustre/llite/rw.c
index 25de3bf..de20b7d 100644
--- a/drivers/staging/lustre/lustre/llite/rw.c
+++ b/drivers/staging/lustre/lustre/llite/rw.c
@@ -413,7 +413,7 @@ static int ll_read_ahead_pages(const struct lu_env *env,
 			 * forward read-ahead, it will be fixed when backward
 			 * read-ahead is implemented
 			 */
-			LASSERTF(page_idx > ria->ria_stoff, "Invalid page_idx %lu rs %lu re %lu ro %lu rl %lu rp %lu\n",
+			LASSERTF(page_idx >= ria->ria_stoff, "Invalid page_idx %lu rs %lu re %lu ro %lu rl %lu rp %lu\n",
 				 page_idx,
 				 ria->ria_start, ria->ria_end, ria->ria_stoff,
 				 ria->ria_length, ria->ria_pages);
@@ -474,10 +474,22 @@ int ll_readahead(const struct lu_env *env, struct cl_io *io,
 	}
 
 	/* Reserve a part of the read-ahead window that we'll be issuing */
-	if (ras->ras_window_len) {
-		start = ras->ras_next_readahead;
+	if (ras->ras_window_len > 0) {
+		/*
+		 * Note: other thread might rollback the ras_next_readahead,
+		 * if it can not get the full size of prepared pages, see the
+		 * end of this function. For stride read ahead, it needs to
+		 * make sure the offset is no less than ras_stride_offset,
+		 * so that stride read ahead can work correctly.
+		 */
+		if (stride_io_mode(ras))
+			start = max(ras->ras_next_readahead,
+				    ras->ras_stride_offset);
+		else
+			start = ras->ras_next_readahead;
 		end = ras->ras_window_start + ras->ras_window_len - 1;
 	}
+
 	if (end != 0) {
 		unsigned long rpc_boundary;
 		/*
-- 
1.7.1
