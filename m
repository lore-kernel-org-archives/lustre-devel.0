From: James Simmons <jsimmons@infradead.org>
Date: Mon,  4 Apr 2016 21:36:59 -0400
Subject: [lustre-devel] [PATCH 14/18] staging: lustre: fix 'NULL pointer
	dereference' errors
In-Reply-To: <1459820223-24754-1-git-send-email-jsimmons@infradead.org>
References: <1459820223-24754-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1459820223-24754-15-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Sebastien Buisson <sbuisson@ddn.com>, James Nunez <james.a.nunez@intel.com>, James Simmons <jsimmons@infradead.org>

From: Sebastien Buisson <sbuisson@ddn.com>

Fix 'NULL pointer dereference' defects found by Coverity version
6.5.0:
Dereference after null check (FORWARD_NULL)
For instance, Passing null pointer to a function which dereferences
it.
Dereference before null check (REVERSE_INULL)
Null-checking variable suggests that it may be null, but it has
already been dereferenced on all paths leading to the check.
Dereference null return value (NULL_RETURNS)

Signed-off-by: Sebastien Buisson <sbuisson@ddn.com>
Signed-off-by: James Nunez <james.a.nunez@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-3042
Reviewed-on: http://review.whamcloud.com/5868
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/dir.c  |   10 ++++++----
 drivers/staging/lustre/lustre/lov/lov_io.c |    3 ++-
 2 files changed, 8 insertions(+), 5 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/dir.c b/drivers/staging/lustre/lustre/llite/dir.c
index 41481cc..7251bef 100644
--- a/drivers/staging/lustre/lustre/llite/dir.c
+++ b/drivers/staging/lustre/lustre/llite/dir.c
@@ -612,15 +612,16 @@ static int ll_readdir(struct file *filp, struct dir_context *ctx)
 	struct inode		*inode	= file_inode(filp);
 	struct ll_file_data	*lfd	= LUSTRE_FPRIVATE(filp);
 	struct ll_sb_info	*sbi	= ll_i2sbi(inode);
+	__u64 pos = lfd ? lfd->lfd_pos : 0;
 	int			hash64	= sbi->ll_flags & LL_SBI_64BIT_HASH;
 	int			api32	= ll_need_32bit_api(sbi);
 	int			rc;
 
 	CDEBUG(D_VFSTRACE, "VFS Op:inode=%lu/%u(%p) pos %lu/%llu 32bit_api %d\n",
 	       inode->i_ino, inode->i_generation,
-	       inode, (unsigned long)lfd->lfd_pos, i_size_read(inode), api32);
+	       inode, (unsigned long)pos, i_size_read(inode), api32);
 
-	if (lfd->lfd_pos == MDS_DIR_END_OFF) {
+	if (pos == MDS_DIR_END_OFF) {
 		/*
 		 * end-of-file.
 		 */
@@ -628,9 +629,10 @@ static int ll_readdir(struct file *filp, struct dir_context *ctx)
 		goto out;
 	}
 
-	ctx->pos = lfd->lfd_pos;
+	ctx->pos = pos;
 	rc = ll_dir_read(inode, ctx);
-	lfd->lfd_pos = ctx->pos;
+	if (lfd)
+		lfd->lfd_pos = ctx->pos;
 	if (ctx->pos == MDS_DIR_END_OFF) {
 		if (api32)
 			ctx->pos = LL_DIR_END_OFF_32BIT;
diff --git a/drivers/staging/lustre/lustre/lov/lov_io.c b/drivers/staging/lustre/lustre/lov/lov_io.c
index 4151237..0b59393 100644
--- a/drivers/staging/lustre/lustre/lov/lov_io.c
+++ b/drivers/staging/lustre/lustre/lov/lov_io.c
@@ -276,10 +276,11 @@ struct lov_io_sub *lov_page_subio(const struct lu_env *env, struct lov_io *lio,
 static int lov_io_subio_init(const struct lu_env *env, struct lov_io *lio,
 			     struct cl_io *io)
 {
-	struct lov_stripe_md *lsm = lio->lis_object->lo_lsm;
+	struct lov_stripe_md *lsm;
 	int result;
 
 	LASSERT(lio->lis_object);
+	lsm = lio->lis_object->lo_lsm;
 
 	/*
 	 * Need to be optimized, we can't afford to allocate a piece of memory
-- 
1.7.1
