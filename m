From: James Simmons <jsimmons@infradead.org>
Date: Tue, 16 Aug 2016 16:18:14 -0400
Subject: [lustre-devel] [PATCH 01/80] staging: lustre: llite: add md_op_data
	parameter to ll_get_dir_page
In-Reply-To: <1471378773-24590-1-git-send-email-jsimmons@infradead.org>
References: <1471378773-24590-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1471378773-24590-2-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, wang di <di.wang@intel.com>, James Simmons <jsimmons@infradead.org>

From: wang di <di.wang@intel.com>

Pass in struct md_op_data for ll_get_dir_page function.

Signed-off-by: wang di <di.wang@intel.com>
Reviewed-on: http://review.whamcloud.com/7043
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-3531
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Jinshan Xiong <jinshan.xiong@intel.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/dir.c          |    8 ++++----
 .../staging/lustre/lustre/llite/llite_internal.h   |    4 ++--
 drivers/staging/lustre/lustre/llite/statahead.c    |   15 +++++++++++----
 3 files changed, 17 insertions(+), 10 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/dir.c b/drivers/staging/lustre/lustre/llite/dir.c
index 031c9e4..82c7f88 100644
--- a/drivers/staging/lustre/lustre/llite/dir.c
+++ b/drivers/staging/lustre/lustre/llite/dir.c
@@ -322,8 +322,8 @@ static struct page *ll_dir_page_locate(struct inode *dir, __u64 *hash,
 	return page;
 }
 
-struct page *ll_get_dir_page(struct inode *dir, __u64 hash,
-			     struct ll_dir_chain *chain)
+struct page *ll_get_dir_page(struct inode *dir, struct md_op_data *op_data,
+			     __u64 hash, struct ll_dir_chain *chain)
 {
 	ldlm_policy_data_t policy = {.l_inodebits = {MDS_INODELOCK_UPDATE} };
 	struct address_space *mapping = dir->i_mapping;
@@ -503,7 +503,7 @@ int ll_dir_read(struct inode *inode, __u64 *ppos, struct md_op_data *op_data,
 
 	ll_dir_chain_init(&chain);
 
-	page = ll_get_dir_page(inode, pos, &chain);
+	page = ll_get_dir_page(inode, op_data, pos, &chain);
 
 	while (rc == 0 && !done) {
 		struct lu_dirpage *dp;
@@ -585,7 +585,7 @@ int ll_dir_read(struct inode *inode, __u64 *ppos, struct md_op_data *op_data,
 					le32_to_cpu(dp->ldp_flags) &
 					LDF_COLLIDE);
 			next = pos;
-			page = ll_get_dir_page(inode, pos,
+			page = ll_get_dir_page(inode, op_data, pos,
 					       &chain);
 		}
 	}
diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
index dc15957..fc0c72c 100644
--- a/drivers/staging/lustre/lustre/llite/llite_internal.h
+++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
@@ -651,8 +651,8 @@ void ll_rw_stats_tally(struct ll_sb_info *sbi, pid_t pid,
 void ll_release_page(struct page *page, int remove);
 extern const struct file_operations ll_dir_operations;
 extern const struct inode_operations ll_dir_inode_operations;
-struct page *ll_get_dir_page(struct inode *dir, __u64 hash,
-			     struct ll_dir_chain *chain);
+struct page *ll_get_dir_page(struct inode *dir, struct md_op_data *op_data,
+			     __u64 hash, struct ll_dir_chain *chain);
 int ll_dir_read(struct inode *inode, __u64 *ppos, struct md_op_data *op_data,
 		struct dir_context *ctx);
 
diff --git a/drivers/staging/lustre/lustre/llite/statahead.c b/drivers/staging/lustre/lustre/llite/statahead.c
index 54ed52e..1b222c7 100644
--- a/drivers/staging/lustre/lustre/llite/statahead.c
+++ b/drivers/staging/lustre/lustre/llite/statahead.c
@@ -1067,7 +1067,7 @@ static int ll_statahead_thread(void *arg)
 	wake_up(&thread->t_ctl_waitq);
 
 	ll_dir_chain_init(&chain);
-	page = ll_get_dir_page(dir, pos, &chain);
+	page = ll_get_dir_page(dir, op_data, pos, &chain);
 
 	while (1) {
 		struct lu_dirpage *dp;
@@ -1232,7 +1232,7 @@ do_it:
 			ll_release_page(page, le32_to_cpu(dp->ldp_flags) &
 					      LDF_COLLIDE);
 			sai->sai_in_readpage = 1;
-			page = ll_get_dir_page(dir, pos, &chain);
+			page = ll_get_dir_page(dir, op_data, pos, &chain);
 			sai->sai_in_readpage = 0;
 		}
 	}
@@ -1344,13 +1344,19 @@ static int is_first_dirent(struct inode *dir, struct dentry *dentry)
 {
 	struct ll_dir_chain   chain;
 	const struct qstr  *target = &dentry->d_name;
+	struct md_op_data *op_data;
 	struct page	  *page;
 	__u64		 pos    = 0;
 	int		   dot_de;
 	int		   rc     = LS_NONE_FIRST_DE;
 
+	op_data = ll_prep_md_op_data(NULL, dir, dir, NULL, 0, 0,
+				     LUSTRE_OPC_ANY, dir);
+	if (IS_ERR(op_data))
+		return PTR_ERR(op_data);
+
 	ll_dir_chain_init(&chain);
-	page = ll_get_dir_page(dir, pos, &chain);
+	page = ll_get_dir_page(dir, op_data, pos, &chain);
 
 	while (1) {
 		struct lu_dirpage *dp;
@@ -1438,12 +1444,13 @@ static int is_first_dirent(struct inode *dir, struct dentry *dentry)
 			 */
 			ll_release_page(page, le32_to_cpu(dp->ldp_flags) &
 					      LDF_COLLIDE);
-			page = ll_get_dir_page(dir, pos, &chain);
+			page = ll_get_dir_page(dir, op_data, pos, &chain);
 		}
 	}
 
 out:
 	ll_dir_chain_fini(&chain);
+	ll_finish_md_op_data(op_data);
 	return rc;
 }
 
-- 
1.7.1
