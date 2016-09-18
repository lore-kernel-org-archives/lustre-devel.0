From: James Simmons <jsimmons@infradead.org>
Date: Sun, 18 Sep 2016 16:37:34 -0400
Subject: [lustre-devel] [PATCH 035/124] staging: lustre: llite: style
	cleanup for ll_mkdir
In-Reply-To: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
References: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1474231143-4061-36-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, "John L. Hammond" <john.hammond@intel.com>, James Simmons <jsimmons@infradead.org>

From: John L. Hammond <john.hammond@intel.com>

Style cleanup to make the code readable.

Signed-off-by: John L. Hammond <john.hammond@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-2675
Reviewed-on: http://review.whamcloud.com/10769
Reviewed-by: Yang Sheng <yang.sheng@intel.com>
Reviewed-by: Lai Siyao <lai.siyao@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/namei.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/namei.c b/drivers/staging/lustre/lustre/llite/namei.c
index fadac44..5e182fc 100644
--- a/drivers/staging/lustre/lustre/llite/namei.c
+++ b/drivers/staging/lustre/lustre/llite/namei.c
@@ -1015,8 +1015,8 @@ static int ll_mkdir(struct inode *dir, struct dentry *dentry, umode_t mode)
 	if (!IS_POSIXACL(dir) || !exp_connect_umask(ll_i2mdexp(dir)))
 		mode &= ~current_umask();
 	mode = (mode & (S_IRWXUGO | S_ISVTX)) | S_IFDIR;
-	err = ll_new_node(dir, dentry, NULL, mode, 0, LUSTRE_OPC_MKDIR);
 
+	err = ll_new_node(dir, dentry, NULL, mode, 0, LUSTRE_OPC_MKDIR);
 	if (!err)
 		ll_stats_ops_tally(ll_i2sbi(dir), LPROC_LL_MKDIR, 1);
 
-- 
1.7.1
