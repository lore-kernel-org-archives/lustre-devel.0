From: James Simmons <jsimmons@infradead.org>
Date: Sun,  6 Jan 2019 16:36:42 -0500
Subject: [lustre-devel] [PATCH 09/14] lustre: llite: return correct amount
 of bytes for short operations
In-Reply-To: <1546810607-6348-1-git-send-email-jsimmons@infradead.org>
References: <1546810607-6348-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1546810607-6348-10-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

The incorrect number of bytes processed by ll_file_io_generic() is
returned. We need to add io->ci_nob to result.

Fixes: 623f55c4510 ("staging: lustre: llite: restart short read/write for normal IO")
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/file.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
index 5c6ebfa..b390971 100644
--- a/drivers/staging/lustre/lustre/llite/file.c
+++ b/drivers/staging/lustre/lustre/llite/file.c
@@ -1195,7 +1195,7 @@ static void ll_io_init(struct cl_io *io, const struct file *file, int write)
 	}
 
 	if (io->ci_nob > 0) {
-		result = io->ci_nob;
+		result += io->ci_nob;
 		count -= io->ci_nob;
 		*ppos = io->u.ci_wr.wr.crw_pos;
 
-- 
1.8.3.1
