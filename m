From: James Simmons <jsimmons@infradead.org>
Date: Sun, 18 Sep 2016 16:37:35 -0400
Subject: [lustre-devel] [PATCH 036/124] staging: lustre: llite: no need to
	check dentry is NULL
In-Reply-To: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
References: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1474231143-4061-37-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, "John L. Hammond" <john.hammond@intel.com>, James Simmons <jsimmons@infradead.org>

From: John L. Hammond <john.hammond@intel.com>

We are already touching dentry in CDEBUG macros so it
will crash long before these checks. Since this is the
case no need to do an additional check.

Signed-off-by: John L. Hammond <john.hammond@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-2675
Reviewed-on: http://review.whamcloud.com/10769
Reviewed-by: Yang Sheng <yang.sheng@intel.com>
Reviewed-by: Lai Siyao <lai.siyao@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/namei.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/namei.c b/drivers/staging/lustre/lustre/llite/namei.c
index 5e182fc..7a82ae4 100644
--- a/drivers/staging/lustre/lustre/llite/namei.c
+++ b/drivers/staging/lustre/lustre/llite/namei.c
@@ -987,7 +987,7 @@ static int ll_unlink(struct inode *dir, struct dentry *dchild)
 	if (IS_ERR(op_data))
 		return PTR_ERR(op_data);
 
-	if (dchild && dchild->d_inode)
+	if (dchild->d_inode)
 		op_data->op_fid3 = *ll_inode2fid(dchild->d_inode);
 
 	op_data->op_fid2 = op_data->op_fid3;
@@ -1039,7 +1039,7 @@ static int ll_rmdir(struct inode *dir, struct dentry *dchild)
 	if (IS_ERR(op_data))
 		return PTR_ERR(op_data);
 
-	if (dchild && dchild->d_inode)
+	if (dchild->d_inode)
 		op_data->op_fid3 = *ll_inode2fid(dchild->d_inode);
 
 	op_data->op_fid2 = op_data->op_fid3;
@@ -1120,9 +1120,9 @@ static int ll_rename(struct inode *src, struct dentry *src_dchild,
 	if (IS_ERR(op_data))
 		return PTR_ERR(op_data);
 
-	if (src_dchild && src_dchild->d_inode)
+	if (src_dchild->d_inode)
 		op_data->op_fid3 = *ll_inode2fid(src_dchild->d_inode);
-	if (tgt_dchild && tgt_dchild->d_inode)
+	if (tgt_dchild->d_inode)
 		op_data->op_fid4 = *ll_inode2fid(tgt_dchild->d_inode);
 
 	err = md_rename(sbi->ll_md_exp, op_data,
-- 
1.7.1
