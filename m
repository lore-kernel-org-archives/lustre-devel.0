From: James Simmons <jsimmons@infradead.org>
Date: Thu, 21 Jul 2016 22:44:10 -0400
Subject: [lustre-devel] [PATCH 17/58] staging: lustre: llite: pass in __u64
	pos for ll_dir_read
In-Reply-To: <1469155491-15265-1-git-send-email-jsimmons@infradead.org>
References: <1469155491-15265-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1469155491-15265-18-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, wang di <di.wang@intel.com>, James Simmons <jsimmons@infradead.org>

From: wang di <di.wang@intel.com>

Some cases we want to preserve the ctx->pos value or use
a different value altogther. So allow the passing in of
a position offset to ll_dir_read.

Signed-off-by: wang di <di.wang@intel.com>
Reviewed-on: http://review.whamcloud.com/10761
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-4906
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/dir.c          |   19 +++++++++++--------
 .../staging/lustre/lustre/llite/llite_internal.h   |    2 +-
 drivers/staging/lustre/lustre/llite/llite_nfs.c    |    3 ++-
 3 files changed, 14 insertions(+), 10 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/dir.c b/drivers/staging/lustre/lustre/llite/dir.c
index 2307e70..031c9e4 100644
--- a/drivers/staging/lustre/lustre/llite/dir.c
+++ b/drivers/staging/lustre/lustre/llite/dir.c
@@ -489,11 +489,11 @@ static __u16 ll_dirent_type_get(struct lu_dirent *ent)
 	return type;
 }
 
-int ll_dir_read(struct inode *inode, struct md_op_data *op_data,
+int ll_dir_read(struct inode *inode, __u64 *ppos, struct md_op_data *op_data,
 		struct dir_context *ctx)
 {
 	struct ll_sb_info    *sbi	= ll_i2sbi(inode);
-	__u64		   pos		= ctx->pos;
+	__u64		   pos		= *ppos;
 	int		   is_api32 = ll_need_32bit_api(sbi);
 	int		   is_hash64 = sbi->ll_flags & LL_SBI_64BIT_HASH;
 	struct page	  *page;
@@ -626,18 +626,21 @@ static int ll_readdir(struct file *filp, struct dir_context *ctx)
 	}
 
 	ctx->pos = pos;
-	rc = ll_dir_read(inode, op_data, ctx);
+	rc = ll_dir_read(inode, &pos, op_data, ctx);
+	pos = ctx->pos;
 	if (lfd)
-		lfd->lfd_pos = ctx->pos;
-	if (ctx->pos == MDS_DIR_END_OFF) {
+		lfd->lfd_pos = pos;
+
+	if (pos == MDS_DIR_END_OFF) {
 		if (api32)
-			ctx->pos = LL_DIR_END_OFF_32BIT;
+			pos = LL_DIR_END_OFF_32BIT;
 		else
-			ctx->pos = LL_DIR_END_OFF;
+			pos = LL_DIR_END_OFF;
 	} else {
 		if (api32 && hash64)
-			ctx->pos >>= 32;
+			pos >>= 32;
 	}
+	ctx->pos = pos;
 	ll_finish_md_op_data(op_data);
 	filp->f_version = inode->i_version;
 
diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
index 623455f..e650aeb 100644
--- a/drivers/staging/lustre/lustre/llite/llite_internal.h
+++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
@@ -653,7 +653,7 @@ extern const struct file_operations ll_dir_operations;
 extern const struct inode_operations ll_dir_inode_operations;
 struct page *ll_get_dir_page(struct inode *dir, __u64 hash,
 			     struct ll_dir_chain *chain);
-int ll_dir_read(struct inode *inode, struct md_op_data *op_data,
+int ll_dir_read(struct inode *inode, __u64 *ppos, struct md_op_data *op_data,
 		struct dir_context *ctx);
 
 int ll_get_mdt_idx(struct inode *inode);
diff --git a/drivers/staging/lustre/lustre/llite/llite_nfs.c b/drivers/staging/lustre/lustre/llite/llite_nfs.c
index b74582a..74eb1fc 100644
--- a/drivers/staging/lustre/lustre/llite/llite_nfs.c
+++ b/drivers/staging/lustre/lustre/llite/llite_nfs.c
@@ -256,6 +256,7 @@ static int ll_get_name(struct dentry *dentry, char *name,
 		.ctx.actor = ll_nfs_get_name_filldir,
 	};
 	struct md_op_data *op_data;
+	__u64 pos = 0;
 
 	if (!dir || !S_ISDIR(dir->i_mode)) {
 		rc = -ENOTDIR;
@@ -275,7 +276,7 @@ static int ll_get_name(struct dentry *dentry, char *name,
 	}
 
 	inode_lock(dir);
-	rc = ll_dir_read(dir, op_data, &lgd.ctx);
+	rc = ll_dir_read(dir, &pos, op_data, &lgd.ctx);
 	inode_unlock(dir);
 	ll_finish_md_op_data(op_data);
 	if (!rc && !lgd.lgd_found)
-- 
1.7.1
