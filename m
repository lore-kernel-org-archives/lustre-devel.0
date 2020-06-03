From: James Simmons <jsimmons@infradead.org>
Date: Tue,  2 Jun 2020 20:59:50 -0400
Subject: [lustre-devel] [PATCH 11/22] lustre: llite: fix read if readahead
 window smaller than rpc size
In-Reply-To: <1591146001-27171-1-git-send-email-jsimmons@infradead.org>
References: <1591146001-27171-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1591146001-27171-12-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Wang Shilong <wshilong@ddn.com>

Readahead always try to align readahead with RPC size, but this
could introduce a problem if readahead window is smaller than RPC size.

With current codes, it will fallback a lot of 4k read because
RPC aligned window start plus window pages will be behind of
current read. Fix this to align with readahead window rather
than RPC size in this case.

WC-bug-id: https://jira.whamcloud.com/browse/LU-13412
Lustre-commit: 33d08805f27bb ("LU-13412 llite: fix read if readahead window smaller than rpc size")
Signed-off-by: Wang Shilong <wshilong@ddn.com>
Reviewed-on: https://review.whamcloud.com/38132
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Gu Zheng <gzheng@ddn.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/rw.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/fs/lustre/llite/rw.c b/fs/lustre/llite/rw.c
index fd0bed6..ff8f3c6 100644
--- a/fs/lustre/llite/rw.c
+++ b/fs/lustre/llite/rw.c
@@ -350,7 +350,11 @@ static unsigned long ria_page_count(struct ra_io_arg *ria)
 
 static pgoff_t ras_align(struct ll_readahead_state *ras, pgoff_t index)
 {
-	return index - (index % ras->ras_rpc_pages);
+	unsigned opt_size = min(ras->ras_window_pages, ras->ras_rpc_pages);
+
+	if (opt_size == 0)
+		opt_size = 1;
+	return index - (index % opt_size);
 }
 
 /* Check whether the index is in the defined ra-window */
-- 
1.8.3.1
