From: James Simmons <jsimmons@infradead.org>
Date: Tue, 16 Aug 2016 16:18:17 -0400
Subject: [lustre-devel] [PATCH 04/80] staging: lustre: llite: pass inode to
	ll_release_page
In-Reply-To: <1471378773-24590-1-git-send-email-jsimmons@infradead.org>
References: <1471378773-24590-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1471378773-24590-5-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, wang di <di.wang@intel.com>, James Simmons <jsimmons@infradead.org>

From: wang di <di.wang@intel.com>

Add a inode parameter to ll_release_page. This will be
used in the future.

Signed-off-by: wang di <di.wang@intel.com>
Reviewed-on: http://review.whamcloud.com/7043
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-3531
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Jinshan Xiong <jinshan.xiong@intel.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/dir.c          |   17 +++++++++--------
 .../staging/lustre/lustre/llite/llite_internal.h   |    2 +-
 drivers/staging/lustre/lustre/llite/statahead.c    |   20 +++++++++++---------
 3 files changed, 21 insertions(+), 18 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/dir.c b/drivers/staging/lustre/lustre/llite/dir.c
index d854edd..3a800b2 100644
--- a/drivers/staging/lustre/lustre/llite/dir.c
+++ b/drivers/staging/lustre/lustre/llite/dir.c
@@ -236,7 +236,7 @@ static int ll_dir_filler(void *_hash, struct page *page0)
 	return rc;
 }
 
-void ll_release_page(struct page *page, int remove)
+void ll_release_page(struct inode *inode, struct page *page, int remove)
 {
 	kunmap(page);
 	if (remove) {
@@ -297,7 +297,7 @@ static struct page *ll_dir_page_locate(struct inode *dir, __u64 *hash,
 			CDEBUG(D_VFSTRACE, "page %lu [%llu %llu], hash %llu\n",
 			       offset, *start, *end, *hash);
 			if (*hash > *end) {
-				ll_release_page(page, 0);
+				ll_release_page(dir, page, 0);
 				page = NULL;
 			} else if (*end != *start && *hash == *end) {
 				/*
@@ -306,8 +306,9 @@ static struct page *ll_dir_page_locate(struct inode *dir, __u64 *hash,
 				 * ll_get_dir_page() will issue RPC to fetch
 				 * the page we want.
 				 */
-				ll_release_page(page,
-				    le32_to_cpu(dp->ldp_flags) & LDF_COLLIDE);
+				ll_release_page(dir, page,
+						le32_to_cpu(dp->ldp_flags) &
+						LDF_COLLIDE);
 				page = NULL;
 			}
 		} else {
@@ -462,7 +463,7 @@ out_unlock:
 	return page;
 
 fail:
-	ll_release_page(page, 1);
+	ll_release_page(dir, page, 1);
 	page = ERR_PTR(-EIO);
 	goto out_unlock;
 }
@@ -560,7 +561,7 @@ int ll_dir_read(struct inode *inode, __u64 *ppos, struct md_op_data *op_data,
 
 		if (done) {
 			pos = hash;
-			ll_release_page(page, 0);
+			ll_release_page(inode, page, 0);
 			break;
 		}
 
@@ -571,13 +572,13 @@ int ll_dir_read(struct inode *inode, __u64 *ppos, struct md_op_data *op_data,
 			 * End of directory reached.
 			 */
 			done = 1;
-			ll_release_page(page, 0);
+			ll_release_page(inode, page, 0);
 		} else {
 			/*
 			 * Normal case: continue to the next
 			 * page.
 			 */
-			ll_release_page(page,
+			ll_release_page(inode, page,
 					le32_to_cpu(dp->ldp_flags) &
 					LDF_COLLIDE);
 			next = pos;
diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
index 1ced397..4b03a64 100644
--- a/drivers/staging/lustre/lustre/llite/llite_internal.h
+++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
@@ -655,7 +655,7 @@ int ll_dir_read(struct inode *inode, __u64 *ppos, struct md_op_data *op_data,
 int ll_get_mdt_idx(struct inode *inode);
 struct page *ll_get_dir_page(struct inode *dir, struct md_op_data *op_data,
 			     __u64 hash, struct ll_dir_chain *chain);
-void ll_release_page(struct page *page, int remove);
+void ll_release_page(struct inode *inode, struct page *page, int remove);
 
 /* llite/namei.c */
 extern const struct inode_operations ll_special_inode_operations;
diff --git a/drivers/staging/lustre/lustre/llite/statahead.c b/drivers/staging/lustre/lustre/llite/statahead.c
index 1b222c7..2949ff6 100644
--- a/drivers/staging/lustre/lustre/llite/statahead.c
+++ b/drivers/staging/lustre/lustre/llite/statahead.c
@@ -1142,7 +1142,7 @@ interpret_it:
 				ll_post_statahead(sai);
 
 			if (unlikely(!thread_is_running(thread))) {
-				ll_release_page(page, 0);
+				ll_release_page(dir, page, 0);
 				rc = 0;
 				goto out;
 			}
@@ -1166,7 +1166,7 @@ interpret_it:
 
 					if (unlikely(
 						!thread_is_running(thread))) {
-						ll_release_page(page, 0);
+						ll_release_page(dir, page, 0);
 						rc = 0;
 						goto out;
 					}
@@ -1189,7 +1189,7 @@ do_it:
 			/*
 			 * End of directory reached.
 			 */
-			ll_release_page(page, 0);
+			ll_release_page(dir, page, 0);
 			while (1) {
 				l_wait_event(thread->t_ctl_waitq,
 					     !list_empty(&sai->sai_entries_received) ||
@@ -1229,8 +1229,9 @@ do_it:
 			 * chain is exhausted.
 			 * Normal case: continue to the next page.
 			 */
-			ll_release_page(page, le32_to_cpu(dp->ldp_flags) &
-					      LDF_COLLIDE);
+			ll_release_page(dir, page,
+					le32_to_cpu(dp->ldp_flags) &
+					LDF_COLLIDE);
 			sai->sai_in_readpage = 1;
 			page = ll_get_dir_page(dir, op_data, pos, &chain);
 			sai->sai_in_readpage = 0;
@@ -1427,7 +1428,7 @@ static int is_first_dirent(struct inode *dir, struct dentry *dentry)
 			else
 				rc = LS_FIRST_DOT_DE;
 
-			ll_release_page(page, 0);
+			ll_release_page(dir, page, 0);
 			goto out;
 		}
 		pos = le64_to_cpu(dp->ldp_hash_end);
@@ -1435,15 +1436,16 @@ static int is_first_dirent(struct inode *dir, struct dentry *dentry)
 			/*
 			 * End of directory reached.
 			 */
-			ll_release_page(page, 0);
+			ll_release_page(dir, page, 0);
 			goto out;
 		} else {
 			/*
 			 * chain is exhausted
 			 * Normal case: continue to the next page.
 			 */
-			ll_release_page(page, le32_to_cpu(dp->ldp_flags) &
-					      LDF_COLLIDE);
+			ll_release_page(dir, page,
+					le32_to_cpu(dp->ldp_flags) &
+					LDF_COLLIDE);
 			page = ll_get_dir_page(dir, op_data, pos, &chain);
 		}
 	}
-- 
1.7.1
