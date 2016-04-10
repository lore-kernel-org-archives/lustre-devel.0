From: James Simmons <jsimmons@infradead.org>
Date: Sun, 10 Apr 2016 09:13:39 -0400
Subject: [lustre-devel] [PATCH 16/17] staging: lustre: hsm: permission
	checks for HSM ioctl operations
In-Reply-To: <1460294020-2111-1-git-send-email-jsimmons@infradead.org>
References: <1460294020-2111-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1460294020-2111-17-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, "John L. Hammond" <john.hammond@intel.com>, James Simmons <jsimmons@infradead.org>

From: John L. Hammond <john.hammond@intel.com>

In the LL_IOC_HSM_CT_START case of ll_dir_ioctl() require
CAP_SYS_ADMIN, since the local handler for this ioctl may modify the
global KUC table.

Signed-off-by: John L. Hammond <john.hammond@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-3866
Reviewed-on: http://review.whamcloud.com/7565
Reviewed-by: Aurelien Degremont <aurelien.degremont@cea.fr>
Reviewed-by: Faccini Bruno <bruno.faccini@intel.com>
Reviewed-by: Jinshan Xiong <jinshan.xiong@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/dir.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/dir.c b/drivers/staging/lustre/lustre/llite/dir.c
index 45bdf8f..94f3800 100644
--- a/drivers/staging/lustre/lustre/llite/dir.c
+++ b/drivers/staging/lustre/lustre/llite/dir.c
@@ -1844,6 +1844,9 @@ out_quotactl:
 		return rc;
 	}
 	case LL_IOC_HSM_CT_START:
+		if (!capable(CFS_CAP_SYS_ADMIN))
+			return -EPERM;
+
 		rc = copy_and_ioctl(cmd, sbi->ll_md_exp, (void __user *)arg,
 				    sizeof(struct lustre_kernelcomm));
 		return rc;
-- 
1.7.1
