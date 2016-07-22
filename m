From: James Simmons <jsimmons@infradead.org>
Date: Thu, 21 Jul 2016 22:44:01 -0400
Subject: [lustre-devel] [PATCH 08/58] staging: lustre: llite: pass struct
	md_op_data to ll_dir_read
In-Reply-To: <1469155491-15265-1-git-send-email-jsimmons@infradead.org>
References: <1469155491-15265-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1469155491-15265-9-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, wang di <di.wang@intel.com>, James Simmons <jsimmons@infradead.org>

From: wang di <di.wang@intel.com>

Add struct md_op_data as a parameter to ll_dir_read.

Signed-off-by: wang di <di.wang@intel.com>
Reviewed-on: http://review.whamcloud.com/7043
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-3531
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Jinshan Xiong <jinshan.xiong@intel.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/dir.c          |   14 ++++++++++++--
 .../staging/lustre/lustre/llite/llite_internal.h   |    3 ++-
 drivers/staging/lustre/lustre/llite/llite_nfs.c    |   11 ++++++++++-
 drivers/staging/lustre/lustre/llite/statahead.c    |    7 +++++++
 4 files changed, 31 insertions(+), 4 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/dir.c b/drivers/staging/lustre/lustre/llite/dir.c
index 4d81a64..75d0176 100644
--- a/drivers/staging/lustre/lustre/llite/dir.c
+++ b/drivers/staging/lustre/lustre/llite/dir.c
@@ -489,7 +489,8 @@ static __u16 ll_dirent_type_get(struct lu_dirent *ent)
 	return type;
 }
 
-int ll_dir_read(struct inode *inode, struct dir_context *ctx)
+int ll_dir_read(struct inode *inode, struct md_op_data *op_data,
+		struct dir_context *ctx)
 {
 	struct ll_inode_info *info       = ll_i2info(inode);
 	struct ll_sb_info    *sbi	= ll_i2sbi(inode);
@@ -613,6 +614,7 @@ static int ll_readdir(struct file *filp, struct dir_context *ctx)
 	__u64 pos = lfd ? lfd->lfd_pos : 0;
 	int			hash64	= sbi->ll_flags & LL_SBI_64BIT_HASH;
 	int			api32	= ll_need_32bit_api(sbi);
+	struct md_op_data *op_data;
 	int			rc;
 
 	CDEBUG(D_VFSTRACE, "VFS Op:inode="DFID"(%p) pos/size %lu/%llu 32bit_api %d\n",
@@ -627,8 +629,15 @@ static int ll_readdir(struct file *filp, struct dir_context *ctx)
 		goto out;
 	}
 
+	op_data = ll_prep_md_op_data(NULL, inode, inode, NULL, 0, 0,
+				     LUSTRE_OPC_ANY, inode);
+	if (IS_ERR(op_data)) {
+		rc = PTR_ERR(op_data);
+		goto out;
+	}
+
 	ctx->pos = pos;
-	rc = ll_dir_read(inode, ctx);
+	rc = ll_dir_read(inode, op_data, ctx);
 	if (lfd)
 		lfd->lfd_pos = ctx->pos;
 	if (ctx->pos == MDS_DIR_END_OFF) {
@@ -640,6 +649,7 @@ static int ll_readdir(struct file *filp, struct dir_context *ctx)
 		if (api32 && hash64)
 			ctx->pos >>= 32;
 	}
+	ll_finish_md_op_data(op_data);
 	filp->f_version = inode->i_version;
 
 out:
diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
index baa208f..623455f 100644
--- a/drivers/staging/lustre/lustre/llite/llite_internal.h
+++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
@@ -653,7 +653,8 @@ extern const struct file_operations ll_dir_operations;
 extern const struct inode_operations ll_dir_inode_operations;
 struct page *ll_get_dir_page(struct inode *dir, __u64 hash,
 			     struct ll_dir_chain *chain);
-int ll_dir_read(struct inode *inode, struct dir_context *ctx);
+int ll_dir_read(struct inode *inode, struct md_op_data *op_data,
+		struct dir_context *ctx);
 
 int ll_get_mdt_idx(struct inode *inode);
 /* llite/namei.c */
diff --git a/drivers/staging/lustre/lustre/llite/llite_nfs.c b/drivers/staging/lustre/lustre/llite/llite_nfs.c
index 65972c8..b74582a 100644
--- a/drivers/staging/lustre/lustre/llite/llite_nfs.c
+++ b/drivers/staging/lustre/lustre/llite/llite_nfs.c
@@ -255,6 +255,7 @@ static int ll_get_name(struct dentry *dentry, char *name,
 		.lgd_fid = ll_i2info(d_inode(child))->lli_fid,
 		.ctx.actor = ll_nfs_get_name_filldir,
 	};
+	struct md_op_data *op_data;
 
 	if (!dir || !S_ISDIR(dir->i_mode)) {
 		rc = -ENOTDIR;
@@ -266,9 +267,17 @@ static int ll_get_name(struct dentry *dentry, char *name,
 		goto out;
 	}
 
+	op_data = ll_prep_md_op_data(NULL, dir, dir, NULL, 0, 0,
+				     LUSTRE_OPC_ANY, dir);
+	if (IS_ERR(op_data)) {
+		rc = PTR_ERR(op_data);
+		goto out;
+	}
+
 	inode_lock(dir);
-	rc = ll_dir_read(dir, &lgd.ctx);
+	rc = ll_dir_read(dir, op_data, &lgd.ctx);
 	inode_unlock(dir);
+	ll_finish_md_op_data(op_data);
 	if (!rc && !lgd.lgd_found)
 		rc = -ENOENT;
 out:
diff --git a/drivers/staging/lustre/lustre/llite/statahead.c b/drivers/staging/lustre/lustre/llite/statahead.c
index f775242..7a7b11c 100644
--- a/drivers/staging/lustre/lustre/llite/statahead.c
+++ b/drivers/staging/lustre/lustre/llite/statahead.c
@@ -1037,6 +1037,7 @@ static int ll_statahead_thread(void *arg)
 	__u64		     pos    = 0;
 	int		       first  = 0;
 	int		       rc     = 0;
+	struct md_op_data *op_data;
 	struct ll_dir_chain       chain;
 	struct l_wait_info	lwi    = { 0 };
 
@@ -1044,6 +1045,11 @@ static int ll_statahead_thread(void *arg)
 	CDEBUG(D_READA, "statahead thread starting: sai %p, parent %pd\n",
 	       sai, parent);
 
+	op_data = ll_prep_md_op_data(NULL, dir, dir, NULL, 0, 0,
+				     LUSTRE_OPC_ANY, dir);
+	if (IS_ERR(op_data))
+		return PTR_ERR(op_data);
+
 	if (sbi->ll_flags & LL_SBI_AGL_ENABLED)
 		ll_start_agl(parent, sai);
 
@@ -1234,6 +1240,7 @@ do_it:
 	}
 
 out:
+	ll_finish_md_op_data(op_data);
 	if (sai->sai_agl_valid) {
 		spin_lock(&plli->lli_agl_lock);
 		thread_set_flags(agl_thread, SVC_STOPPING);
-- 
1.7.1
