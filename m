From: James Simmons <jsimmons@infradead.org>
Date: Mon, 17 Dec 2018 11:30:02 -0500
Subject: [lustre-devel] [PATCH 28/28] lustre: lov: do not split IO for
 single striped file
In-Reply-To: <1545064202-22483-1-git-send-email-jsimmons@infradead.org>
References: <1545064202-22483-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1545064202-22483-29-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Jinshan Xiong <jinshan.xiong@gmail.com>

stripe size for single striped file is not reliable, it shouldn't
be used to split I/O.

Signed-off-by: Jinshan Xiong <jinshan.xiong@gmail.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-9841
Reviewed-on: https://review.whamcloud.com/28451
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/lov/lov_io.c | 15 +++++++++------
 1 file changed, 9 insertions(+), 6 deletions(-)

diff --git a/drivers/staging/lustre/lustre/lov/lov_io.c b/drivers/staging/lustre/lustre/lov/lov_io.c
index 9a3352f..47bb618 100644
--- a/drivers/staging/lustre/lustre/lov/lov_io.c
+++ b/drivers/staging/lustre/lustre/lov/lov_io.c
@@ -466,7 +466,6 @@ static int lov_io_rw_iter_init(const struct lu_env *env,
 	struct cl_io	 *io  = ios->cis_io;
 	u64 start = io->u.ci_rw.crw_pos;
 	struct lov_stripe_md_entry *lse;
-	unsigned long ssize;
 	int index;
 	u64 next;
 
@@ -491,11 +490,15 @@ static int lov_io_rw_iter_init(const struct lu_env *env,
 
 	lse = lov_lse(lio->lis_object, index);
 
-	ssize = lse->lsme_stripe_size;
-	lov_do_div64(start, ssize);
-	next = (start + 1) * ssize;
-	if (next <= start * ssize)
-		next = ~0ull;
+	next = MAX_LFS_FILESIZE;
+	if (lse->lsme_stripe_count > 1) {
+		unsigned long ssize = lse->lsme_stripe_size;
+
+		lov_do_div64(start, ssize);
+		next = (start + 1) * ssize;
+		if (next <= start * ssize)
+			next = MAX_LFS_FILESIZE;
+	}
 
 	LASSERTF(io->u.ci_rw.crw_pos >= lse->lsme_extent.e_start,
 		 "pos %lld, [%lld, %lld]\n", io->u.ci_rw.crw_pos,
-- 
1.8.3.1
