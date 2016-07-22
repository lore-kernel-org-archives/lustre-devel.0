From: James Simmons <jsimmons@infradead.org>
Date: Thu, 21 Jul 2016 22:44:09 -0400
Subject: [lustre-devel] [PATCH 16/58] staging: lustre: llite: remove code
	never called
In-Reply-To: <1469155491-15265-1-git-send-email-jsimmons@infradead.org>
References: <1469155491-15265-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1469155491-15265-17-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, wang di <di.wang@intel.com>, James Simmons <jsimmons@infradead.org>

From: wang di <di.wang@intel.com>

We have if (1) conditionals which is pointless so remove
it and the next code block is never called so remove that
as well.

Signed-off-by: wang di <di.wang@intel.com>
Reviewed-on: http://review.whamcloud.com/7043
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-3531
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Jinshan Xiong <jinshan.xiong@intel.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/dir.c       |    9 +--------
 drivers/staging/lustre/lustre/llite/statahead.c |   18 +++---------------
 2 files changed, 4 insertions(+), 23 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/dir.c b/drivers/staging/lustre/lustre/llite/dir.c
index 907fae4..2307e70 100644
--- a/drivers/staging/lustre/lustre/llite/dir.c
+++ b/drivers/staging/lustre/lustre/llite/dir.c
@@ -576,7 +576,7 @@ int ll_dir_read(struct inode *inode, struct md_op_data *op_data,
 			 */
 			done = 1;
 			ll_release_page(page, 0);
-		} else if (1 /* chain is exhausted*/) {
+		} else {
 			/*
 			 * Normal case: continue to the next
 			 * page.
@@ -587,13 +587,6 @@ int ll_dir_read(struct inode *inode, struct md_op_data *op_data,
 			next = pos;
 			page = ll_get_dir_page(inode, pos,
 					       &chain);
-		} else {
-			/*
-			 * go into overflow page.
-			 */
-			LASSERT(le32_to_cpu(dp->ldp_flags) &
-				LDF_COLLIDE);
-			ll_release_page(page, 1);
 		}
 	}
 
diff --git a/drivers/staging/lustre/lustre/llite/statahead.c b/drivers/staging/lustre/lustre/llite/statahead.c
index fc24a65..e4ca525 100644
--- a/drivers/staging/lustre/lustre/llite/statahead.c
+++ b/drivers/staging/lustre/lustre/llite/statahead.c
@@ -1222,7 +1222,7 @@ do_it:
 
 			rc = 0;
 			goto out;
-		} else if (1) {
+		} else {
 			/*
 			 * chain is exhausted.
 			 * Normal case: continue to the next page.
@@ -1230,12 +1230,6 @@ do_it:
 			ll_release_page(page, le32_to_cpu(dp->ldp_flags) &
 					      LDF_COLLIDE);
 			page = ll_get_dir_page(dir, pos, &chain);
-		} else {
-			LASSERT(le32_to_cpu(dp->ldp_flags) & LDF_COLLIDE);
-			ll_release_page(page, 1);
-			/*
-			 * go into overflow page.
-			 */
 		}
 	}
 
@@ -1432,8 +1426,8 @@ static int is_first_dirent(struct inode *dir, struct dentry *dentry)
 			 * End of directory reached.
 			 */
 			ll_release_page(page, 0);
-			break;
-		} else if (1) {
+			goto out;
+		} else {
 			/*
 			 * chain is exhausted
 			 * Normal case: continue to the next page.
@@ -1441,12 +1435,6 @@ static int is_first_dirent(struct inode *dir, struct dentry *dentry)
 			ll_release_page(page, le32_to_cpu(dp->ldp_flags) &
 					      LDF_COLLIDE);
 			page = ll_get_dir_page(dir, pos, &chain);
-		} else {
-			/*
-			 * go into overflow page.
-			 */
-			LASSERT(le32_to_cpu(dp->ldp_flags) & LDF_COLLIDE);
-			ll_release_page(page, 1);
 		}
 	}
 
-- 
1.7.1
