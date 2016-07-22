From: James Simmons <jsimmons@infradead.org>
Date: Thu, 21 Jul 2016 22:44:02 -0400
Subject: [lustre-devel] [PATCH 09/58] staging: lustre: llite: remove debug
	message in ll_dir_read
In-Reply-To: <1469155491-15265-1-git-send-email-jsimmons@infradead.org>
References: <1469155491-15265-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1469155491-15265-10-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, wang di <di.wang@intel.com>, James Simmons <jsimmons@infradead.org>

From: wang di <di.wang@intel.com>

Remove debug message and struct ll_inode_info.

Signed-off-by: wang di <di.wang@intel.com>
Reviewed-on: http://review.whamcloud.com/10761
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-4906
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/dir.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/dir.c b/drivers/staging/lustre/lustre/llite/dir.c
index 75d0176..5b46dd8 100644
--- a/drivers/staging/lustre/lustre/llite/dir.c
+++ b/drivers/staging/lustre/lustre/llite/dir.c
@@ -492,7 +492,6 @@ static __u16 ll_dirent_type_get(struct lu_dirent *ent)
 int ll_dir_read(struct inode *inode, struct md_op_data *op_data,
 		struct dir_context *ctx)
 {
-	struct ll_inode_info *info       = ll_i2info(inode);
 	struct ll_sb_info    *sbi	= ll_i2sbi(inode);
 	__u64		   pos		= ctx->pos;
 	int		   api32      = ll_need_32bit_api(sbi);
@@ -596,8 +595,6 @@ int ll_dir_read(struct inode *inode, struct md_op_data *op_data,
 			}
 		} else {
 			rc = PTR_ERR(page);
-			CERROR("error reading dir "DFID" at %lu: rc %d\n",
-			       PFID(&info->lli_fid), (unsigned long)pos, rc);
 		}
 	}
 
-- 
1.7.1
