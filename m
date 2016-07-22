From: James Simmons <jsimmons@infradead.org>
Date: Thu, 21 Jul 2016 22:44:16 -0400
Subject: [lustre-devel] [PATCH 23/58] staging: lustre: llite: change remove
	parameter to bool
In-Reply-To: <1469155491-15265-1-git-send-email-jsimmons@infradead.org>
References: <1469155491-15265-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1469155491-15265-24-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, wang di <di.wang@intel.com>, James Simmons <jsimmons@infradead.org>

From: wang di <di.wang@intel.com>

Change the 3rd parameter remove to a bool for ll_release_page
function.

Signed-off-by: wang di <di.wang@intel.com>
Reviewed-on: http://review.whamcloud.com/7043
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-3531
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Jinshan Xiong <jinshan.xiong@intel.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/dir.c          |   10 +++++-----
 .../staging/lustre/lustre/llite/llite_internal.h   |    2 +-
 drivers/staging/lustre/lustre/llite/statahead.c    |   10 +++++-----
 3 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/dir.c b/drivers/staging/lustre/lustre/llite/dir.c
index 3a800b2..a72b486 100644
--- a/drivers/staging/lustre/lustre/llite/dir.c
+++ b/drivers/staging/lustre/lustre/llite/dir.c
@@ -236,7 +236,7 @@ static int ll_dir_filler(void *_hash, struct page *page0)
 	return rc;
 }
 
-void ll_release_page(struct inode *inode, struct page *page, int remove)
+void ll_release_page(struct inode *inode, struct page *page, bool remove)
 {
 	kunmap(page);
 	if (remove) {
@@ -297,7 +297,7 @@ static struct page *ll_dir_page_locate(struct inode *dir, __u64 *hash,
 			CDEBUG(D_VFSTRACE, "page %lu [%llu %llu], hash %llu\n",
 			       offset, *start, *end, *hash);
 			if (*hash > *end) {
-				ll_release_page(dir, page, 0);
+				ll_release_page(dir, page, false);
 				page = NULL;
 			} else if (*end != *start && *hash == *end) {
 				/*
@@ -463,7 +463,7 @@ out_unlock:
 	return page;
 
 fail:
-	ll_release_page(dir, page, 1);
+	ll_release_page(dir, page, true);
 	page = ERR_PTR(-EIO);
 	goto out_unlock;
 }
@@ -561,7 +561,7 @@ int ll_dir_read(struct inode *inode, __u64 *ppos, struct md_op_data *op_data,
 
 		if (done) {
 			pos = hash;
-			ll_release_page(inode, page, 0);
+			ll_release_page(inode, page, false);
 			break;
 		}
 
@@ -572,7 +572,7 @@ int ll_dir_read(struct inode *inode, __u64 *ppos, struct md_op_data *op_data,
 			 * End of directory reached.
 			 */
 			done = 1;
-			ll_release_page(inode, page, 0);
+			ll_release_page(inode, page, false);
 		} else {
 			/*
 			 * Normal case: continue to the next
diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
index 4b03a64..07b6918 100644
--- a/drivers/staging/lustre/lustre/llite/llite_internal.h
+++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
@@ -655,7 +655,7 @@ int ll_dir_read(struct inode *inode, __u64 *ppos, struct md_op_data *op_data,
 int ll_get_mdt_idx(struct inode *inode);
 struct page *ll_get_dir_page(struct inode *dir, struct md_op_data *op_data,
 			     __u64 hash, struct ll_dir_chain *chain);
-void ll_release_page(struct inode *inode, struct page *page, int remove);
+void ll_release_page(struct inode *inode, struct page *page, bool remove);
 
 /* llite/namei.c */
 extern const struct inode_operations ll_special_inode_operations;
diff --git a/drivers/staging/lustre/lustre/llite/statahead.c b/drivers/staging/lustre/lustre/llite/statahead.c
index 1551e7a..7b23497 100644
--- a/drivers/staging/lustre/lustre/llite/statahead.c
+++ b/drivers/staging/lustre/lustre/llite/statahead.c
@@ -1140,7 +1140,7 @@ interpret_it:
 				ll_post_statahead(sai);
 
 			if (unlikely(!thread_is_running(thread))) {
-				ll_release_page(dir, page, 0);
+				ll_release_page(dir, page, false);
 				rc = 0;
 				goto out;
 			}
@@ -1164,7 +1164,7 @@ interpret_it:
 
 					if (unlikely(
 						!thread_is_running(thread))) {
-						ll_release_page(dir, page, 0);
+						ll_release_page(dir, page, false);
 						rc = 0;
 						goto out;
 					}
@@ -1187,7 +1187,7 @@ do_it:
 			/*
 			 * End of directory reached.
 			 */
-			ll_release_page(dir, page, 0);
+			ll_release_page(dir, page, false);
 			while (1) {
 				l_wait_event(thread->t_ctl_waitq,
 					     !list_empty(&sai->sai_entries_received) ||
@@ -1426,7 +1426,7 @@ static int is_first_dirent(struct inode *dir, struct dentry *dentry)
 			else
 				rc = LS_FIRST_DOT_DE;
 
-			ll_release_page(dir, page, 0);
+			ll_release_page(dir, page, false);
 			goto out;
 		}
 		pos = le64_to_cpu(dp->ldp_hash_end);
@@ -1434,7 +1434,7 @@ static int is_first_dirent(struct inode *dir, struct dentry *dentry)
 			/*
 			 * End of directory reached.
 			 */
-			ll_release_page(dir, page, 0);
+			ll_release_page(dir, page, false);
 			goto out;
 		} else {
 			/*
-- 
1.7.1
