From: James Simmons <jsimmons@infradead.org>
Date: Thu, 21 Jul 2016 22:44:14 -0400
Subject: [lustre-devel] [PATCH 21/58] staging: lustre: llite: style cleanup
	for llite_internal.h
In-Reply-To: <1469155491-15265-1-git-send-email-jsimmons@infradead.org>
References: <1469155491-15265-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1469155491-15265-22-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, wang di <di.wang@intel.com>, James Simmons <jsimmons@infradead.org>

From: wang di <di.wang@intel.com>

Group function prototypes together related to dir.c. Move
ll_release_page to be with function declarations.

Signed-off-by: wang di <di.wang@intel.com>
Reviewed-on: http://review.whamcloud.com/7043
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-3531
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Jinshan Xiong <jinshan.xiong@intel.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/lustre/llite/llite_internal.h   |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
index fc0c72c..1ced397 100644
--- a/drivers/staging/lustre/lustre/llite/llite_internal.h
+++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
@@ -648,15 +648,15 @@ void ll_rw_stats_tally(struct ll_sb_info *sbi, pid_t pid,
 		       size_t count, int rw);
 
 /* llite/dir.c */
-void ll_release_page(struct page *page, int remove);
 extern const struct file_operations ll_dir_operations;
 extern const struct inode_operations ll_dir_inode_operations;
-struct page *ll_get_dir_page(struct inode *dir, struct md_op_data *op_data,
-			     __u64 hash, struct ll_dir_chain *chain);
 int ll_dir_read(struct inode *inode, __u64 *ppos, struct md_op_data *op_data,
 		struct dir_context *ctx);
-
 int ll_get_mdt_idx(struct inode *inode);
+struct page *ll_get_dir_page(struct inode *dir, struct md_op_data *op_data,
+			     __u64 hash, struct ll_dir_chain *chain);
+void ll_release_page(struct page *page, int remove);
+
 /* llite/namei.c */
 extern const struct inode_operations ll_special_inode_operations;
 
-- 
1.7.1
