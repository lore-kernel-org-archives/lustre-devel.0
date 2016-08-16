From: James Simmons <jsimmons@infradead.org>
Date: Tue, 16 Aug 2016 16:19:28 -0400
Subject: [lustre-devel] [PATCH 75/80] staging: lustre: llite: set
	op_max_pages
In-Reply-To: <1471378773-24590-1-git-send-email-jsimmons@infradead.org>
References: <1471378773-24590-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1471378773-24590-76-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, wang di <di.wang@intel.com>, James Simmons <jsimmons@infradead.org>

From: wang di <di.wang@intel.com>

Cache the maximum allowed pages supported by the llite
layer. This value will be used in the mdc and lmv layer.

Signed-off-by: wang di <di.wang@intel.com>
Reviewed-on: http://review.whamcloud.com/7043
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-3531
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Jinshan Xiong <jinshan.xiong@intel.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/dir.c       |    1 +
 drivers/staging/lustre/lustre/llite/llite_nfs.c |    1 +
 drivers/staging/lustre/lustre/llite/statahead.c |    6 ++++++
 3 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/dir.c b/drivers/staging/lustre/lustre/llite/dir.c
index 9c7fa8f..ed09015 100644
--- a/drivers/staging/lustre/lustre/llite/dir.c
+++ b/drivers/staging/lustre/lustre/llite/dir.c
@@ -649,6 +649,7 @@ static int ll_readdir(struct file *filp, struct dir_context *ctx)
 			}
 		}
 	}
+	op_data->op_max_pages = sbi->ll_md_brw_pages;
 	ctx->pos = pos;
 	rc = ll_dir_read(inode, &pos, op_data, ctx);
 	pos = ctx->pos;
diff --git a/drivers/staging/lustre/lustre/llite/llite_nfs.c b/drivers/staging/lustre/lustre/llite/llite_nfs.c
index 2b65240..1e156dc 100644
--- a/drivers/staging/lustre/lustre/llite/llite_nfs.c
+++ b/drivers/staging/lustre/lustre/llite/llite_nfs.c
@@ -276,6 +276,7 @@ static int ll_get_name(struct dentry *dentry, char *name,
 		goto out;
 	}
 
+	op_data->op_max_pages = ll_i2sbi(dir)->ll_md_brw_pages;
 	inode_lock(dir);
 	rc = ll_dir_read(dir, &pos, op_data, &lgd.ctx);
 	inode_unlock(dir);
diff --git a/drivers/staging/lustre/lustre/llite/statahead.c b/drivers/staging/lustre/lustre/llite/statahead.c
index 46b8faf..454c33e 100644
--- a/drivers/staging/lustre/lustre/llite/statahead.c
+++ b/drivers/staging/lustre/lustre/llite/statahead.c
@@ -1052,6 +1052,8 @@ static int ll_statahead_thread(void *arg)
 	if (IS_ERR(op_data))
 		return PTR_ERR(op_data);
 
+	op_data->op_max_pages = ll_i2sbi(dir)->ll_md_brw_pages;
+
 	if (sbi->ll_flags & LL_SBI_AGL_ENABLED)
 		ll_start_agl(parent, sai);
 
@@ -1355,6 +1357,10 @@ static int is_first_dirent(struct inode *dir, struct dentry *dentry)
 				     LUSTRE_OPC_ANY, dir);
 	if (IS_ERR(op_data))
 		return PTR_ERR(op_data);
+	/**
+	 * FIXME choose the start offset of the readdir
+	 */
+	op_data->op_max_pages = ll_i2sbi(dir)->ll_md_brw_pages;
 
 	ll_dir_chain_init(&chain);
 	page = ll_get_dir_page(dir, op_data, pos, &chain);
-- 
1.7.1
