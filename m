From: James Simmons <jsimmons@infradead.org>
Date: Thu, 21 Jul 2016 22:44:07 -0400
Subject: [lustre-devel] [PATCH 14/58] staging: lustre: llite: rename some
	variables for ll_dir_read
In-Reply-To: <1469155491-15265-1-git-send-email-jsimmons@infradead.org>
References: <1469155491-15265-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1469155491-15265-15-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, wang di <di.wang@intel.com>, James Simmons <jsimmons@infradead.org>

From: wang di <di.wang@intel.com>

The variables api32 and hash64 was renamed to is_api32 and
is_hash64.

Signed-off-by: wang di <di.wang@intel.com>
Reviewed-on: http://review.whamcloud.com/7043
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-3531
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Jinshan Xiong <jinshan.xiong@intel.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/dir.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/dir.c b/drivers/staging/lustre/lustre/llite/dir.c
index 70a3ca0..907fae4 100644
--- a/drivers/staging/lustre/lustre/llite/dir.c
+++ b/drivers/staging/lustre/lustre/llite/dir.c
@@ -494,8 +494,8 @@ int ll_dir_read(struct inode *inode, struct md_op_data *op_data,
 {
 	struct ll_sb_info    *sbi	= ll_i2sbi(inode);
 	__u64		   pos		= ctx->pos;
-	int		   api32      = ll_need_32bit_api(sbi);
-	int		   hash64     = sbi->ll_flags & LL_SBI_64BIT_HASH;
+	int		   is_api32 = ll_need_32bit_api(sbi);
+	int		   is_hash64 = sbi->ll_flags & LL_SBI_64BIT_HASH;
 	struct page	  *page;
 	struct ll_dir_chain   chain;
 	bool		   done = false;
@@ -545,12 +545,12 @@ int ll_dir_read(struct inode *inode, struct md_op_data *op_data,
 				 */
 				continue;
 
-			if (api32 && hash64)
+			if (is_api32 && is_hash64)
 				lhash = hash >> 32;
 			else
 				lhash = hash;
 			fid_le_to_cpu(&fid, &ent->lde_fid);
-			ino = cl_fid_build_ino(&fid, api32);
+			ino = cl_fid_build_ino(&fid, is_api32);
 			type = ll_dirent_type_get(ent);
 			ctx->pos = lhash;
 			/* For 'll_nfs_get_name_filldir()', it will try
-- 
1.7.1
