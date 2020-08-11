From: James Simmons <jsimmons@infradead.org>
Date: Tue, 11 Aug 2020 08:19:57 -0400
Subject: [lustre-devel] [PATCH 01/23] lustre: lov: one more fix to
 write_intent end for trunc
In-Reply-To: <1597148419-20629-1-git-send-email-jsimmons@infradead.org>
References: <1597148419-20629-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1597148419-20629-2-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Bobi Jam <bobijam@whamcloud.com>

This patch fixes another case where the truncate write intent
extent is set incorrectly.  This may cause errors when truncating
PFL files to exactly the boundary between two extents.

Fixes: 782b737b76c1 ("lustre: lov: Correct write_intent end for trunc")
WC-bug-id: https://jira.whamcloud.com/browse/LU-12586
Lustre-commit: ecf9e229cf59d ("LU-12586 lov: one more fix to write_intent end for trunc")
Signed-off-by: Bobi Jam <bobijam@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/38412
Reviewed-by: Wang Shilong <wshilong@whamcloud.com>
Reviewed-by: Li Dongyang <dongyangli@ddn.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/lov/lov_io.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/fs/lustre/lov/lov_io.c b/fs/lustre/lov/lov_io.c
index 99b68d8..af79d20 100644
--- a/fs/lustre/lov/lov_io.c
+++ b/fs/lustre/lov/lov_io.c
@@ -363,11 +363,12 @@ static int lov_io_mirror_init(struct lov_io *lio, struct lov_object *obj,
 			/**
 			 * for truncate, we uses [size, EOF) to judge whether
 			 * a write intent needs to be send, but we need to
-			 * restore the write extent to [0, size).
+			 * restore the write extent to [0, size), in truncate,
+			 * the byte in the size position is accessed.
 			 */
 			io->ci_write_intent.e_start = 0;
 			io->ci_write_intent.e_end =
-					io->u.ci_setattr.sa_attr.lvb_size;
+					io->u.ci_setattr.sa_attr.lvb_size + 1;
 		}
 		/* stop cl_io_init() loop */
 		return 1;
-- 
1.8.3.1
