From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:14:22 -0500
Subject: [lustre-devel] [PATCH 394/622] lustre: llite: make sure readahead
 cover current read
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-395-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Wang Shilong <wshilong@ddn.com>

When doing readahead, @ria_end_min is used to indicate
how far we are expected to read to cover current
read.

update @ria_end_min unconditionally with IO end.
also @ria_end_min is closed interval which should be
calculated as start + count - 1;

WC-bug-id: https://jira.whamcloud.com/browse/LU-12043
Lustre-commit: 8fbef5ee7619 ("LU-12043 llite: make sure readahead cover current read")
Signed-off-by: Wang Shilong <wshilong@ddn.com>
Reviewed-on: https://review.whamcloud.com/35215
Reviewed-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-by: Li Xi <lixi@ddn.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/rw.c | 12 ++----------
 1 file changed, 2 insertions(+), 10 deletions(-)

diff --git a/fs/lustre/llite/rw.c b/fs/lustre/llite/rw.c
index bec26c4..fe9a2b0 100644
--- a/fs/lustre/llite/rw.c
+++ b/fs/lustre/llite/rw.c
@@ -689,16 +689,8 @@ static int ll_readahead(const struct lu_env *env, struct cl_io *io,
 
 	/* at least to extend the readahead window to cover current read */
 	if (!hit && vio->vui_ra_valid &&
-	    vio->vui_ra_start + vio->vui_ra_count > ria->ria_start) {
-		unsigned long remainder;
-
-		/* to the end of current read window. */
-		mlen = vio->vui_ra_start + vio->vui_ra_count - ria->ria_start;
-		/* trim to RPC boundary */
-		ras_align(ras, ria->ria_start, &remainder);
-		mlen = min(mlen, ras->ras_rpc_size - remainder);
-		ria->ria_end_min = ria->ria_start + mlen;
-	}
+	    vio->vui_ra_start + vio->vui_ra_count > ria->ria_start)
+		ria->ria_end_min = vio->vui_ra_start + vio->vui_ra_count - 1;
 
 	ria->ria_reserved = ll_ra_count_get(ll_i2sbi(inode), ria, len, mlen);
 	if (ria->ria_reserved < len)
-- 
1.8.3.1
