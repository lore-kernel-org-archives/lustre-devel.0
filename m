From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Sep 2019 14:54:57 -0400
Subject: [lustre-devel] [PATCH 038/151] lustre: llite: enable readahead for
 small read_ahead_per_file
In-Reply-To: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1569869810-23848-39-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Erich Focht <efocht@hpce.nec.com>

Fixes for a regression introduced by http://review.whamcloud.com/19368
for the case that max_read_ahead_per_file_mb is smaller than
max_pages_per_rpc. With 16MB RPCs this happens pretty easily. In that
case the readahead window stayed zero and the backend saw only
requests of the size of the user IOs.

This patch restores the previous behavior for this corner case while
keeping the fix for large RPCs introduced by the alignment. When
max_read_ahead_per_file_mb is smaller than max_pages_per_rpc the
RPC size will not be optimal, but will be at least 1MB and the
readahead window will be as large as expected instead of zero.

WC-bug-id: https://jira.whamcloud.com/browse/LU-9214
Lustre-commit: 32e64eeefa7d ("LU-9214 llite: enable readahead for small read_ahead_per_file")
Signed-off-by: Erich Focht <efocht@hpce.nec.com>
Reviewed-on: https://review.whamcloud.com/25996
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Jinshan Xiong <jinshan.xiong@gmail.com>
Reviewed-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/rw.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/fs/lustre/llite/rw.c b/fs/lustre/llite/rw.c
index 32f028db..ca0b357 100644
--- a/fs/lustre/llite/rw.c
+++ b/fs/lustre/llite/rw.c
@@ -719,7 +719,10 @@ static void ras_increase_window(struct inode *inode,
 
 		wlen = min(ras->ras_window_len + ras->ras_rpc_size,
 			   ra->ra_max_pages_per_file);
-		ras->ras_window_len = ras_align(ras, wlen, NULL);
+		if (wlen < ras->ras_rpc_size)
+			ras->ras_window_len = wlen;
+		else
+			ras->ras_window_len = ras_align(ras, wlen, NULL);
 	}
 }
 
-- 
1.8.3.1
