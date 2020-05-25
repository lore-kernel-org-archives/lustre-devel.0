From: James Simmons <jsimmons@infradead.org>
Date: Mon, 25 May 2020 18:08:08 -0400
Subject: [lustre-devel] [PATCH 31/45] lustre: llite: fix possible divide
 zero in ll_use_fast_io()
In-Reply-To: <1590444502-20533-1-git-send-email-jsimmons@infradead.org>
References: <1590444502-20533-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1590444502-20533-32-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Wang Shilong <wshilong@ddn.com>

ll_use_fast_io() is used to check wheather we could use fast IO.
Since it is called in fast path, we don't hold ras_lock to protect
access, there might have the race @ras_stride_bytes is reset after
stride_io_mode() check.

Fixes: 52fa1b524a84 ("lustre: llite: try fast io for stride io correctly")
WC-bug-id: https://jira.whamcloud.com/browse/LU-13541
Lustre-commit: 7cd0afe58321 ("LU-13541 llite: fix possible divide zero in ll_use_fast_io()")
Signed-off-by: Wang Shilong <wshilong@ddn.com>
Reviewed-on: https://review.whamcloud.com/38545
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Tested-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Jian Yu <yujian@whamcloud.com>
Reviewed-by: James Nunez <jnunez@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/rw.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/fs/lustre/llite/rw.c b/fs/lustre/llite/rw.c
index 9e004f4..fd0bed6 100644
--- a/fs/lustre/llite/rw.c
+++ b/fs/lustre/llite/rw.c
@@ -1609,10 +1609,11 @@ static bool ll_use_fast_io(struct file *file,
 	unsigned long fast_read_pages =
 		max(RA_REMAIN_WINDOW_MIN, ras->ras_rpc_pages);
 	loff_t skip_pages;
+	loff_t stride_bytes = ras->ras_stride_bytes;
 
-	if (stride_io_mode(ras)) {
+	if (stride_io_mode(ras) && stride_bytes) {
 		skip_pages = (ras->ras_stride_length +
-			ras->ras_stride_bytes - 1) / ras->ras_stride_bytes;
+			ras->ras_stride_bytes - 1) / stride_bytes;
 		skip_pages *= fast_read_pages;
 	} else {
 		skip_pages = fast_read_pages;
-- 
1.8.3.1
