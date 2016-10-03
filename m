From: James Simmons <jsimmons@infradead.org>
Date: Sun,  2 Oct 2016 22:28:14 -0400
Subject: [lustre-devel] [PATCH 18/41] staging: lustre: llite: Report first
	encountered error
In-Reply-To: <1475461717-21631-1-git-send-email-jsimmons@infradead.org>
References: <1475461717-21631-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1475461717-21631-19-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Henri Doreau <henri.doreau@cea.fr>, James Simmons <jsimmons@infradead.org>

From: Henri Doreau <henri.doreau@cea.fr>

Failures in ll_ioc_copy_{start,end} are reported to coordinator.
The return code delivered to the caller should indicate what this
error was, not whether coordinator was successfully notified.

Signed-off-by: Henri Doreau <henri.doreau@cea.fr>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5683
Reviewed-on: http://review.whamcloud.com/14335
Reviewed-by: Jinshan Xiong <jinshan.xiong@intel.com>
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/dir.c |   16 ++++++++--------
 1 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/dir.c b/drivers/staging/lustre/lustre/llite/dir.c
index 3641327..68675eb 100644
--- a/drivers/staging/lustre/lustre/llite/dir.c
+++ b/drivers/staging/lustre/lustre/llite/dir.c
@@ -681,7 +681,7 @@ static int ll_ioc_copy_start(struct super_block *sb, struct hsm_copy *copy)
 {
 	struct ll_sb_info		*sbi = ll_s2sbi(sb);
 	struct hsm_progress_kernel	 hpk;
-	int				 rc;
+	int rc2, rc = 0;
 
 	/* Forge a hsm_progress based on data from copy. */
 	hpk.hpk_fid = copy->hc_hai.hai_fid;
@@ -731,10 +731,10 @@ progress:
 	/* On error, the request should be considered as completed */
 	if (hpk.hpk_errval > 0)
 		hpk.hpk_flags |= HP_FLAG_COMPLETED;
-	rc = obd_iocontrol(LL_IOC_HSM_PROGRESS, sbi->ll_md_exp, sizeof(hpk),
-			   &hpk, NULL);
+	rc2 = obd_iocontrol(LL_IOC_HSM_PROGRESS, sbi->ll_md_exp, sizeof(hpk),
+			    &hpk, NULL);
 
-	return rc;
+	return rc ? rc : rc2;
 }
 
 /**
@@ -756,7 +756,7 @@ static int ll_ioc_copy_end(struct super_block *sb, struct hsm_copy *copy)
 {
 	struct ll_sb_info		*sbi = ll_s2sbi(sb);
 	struct hsm_progress_kernel	 hpk;
-	int				 rc;
+	int rc2, rc = 0;
 
 	/* If you modify the logic here, also check llapi_hsm_copy_end(). */
 	/* Take care: copy->hc_hai.hai_action, len, gid and data are not
@@ -830,10 +830,10 @@ static int ll_ioc_copy_end(struct super_block *sb, struct hsm_copy *copy)
 	}
 
 progress:
-	rc = obd_iocontrol(LL_IOC_HSM_PROGRESS, sbi->ll_md_exp, sizeof(hpk),
-			   &hpk, NULL);
+	rc2 = obd_iocontrol(LL_IOC_HSM_PROGRESS, sbi->ll_md_exp, sizeof(hpk),
+			    &hpk, NULL);
 
-	return rc;
+	return rc ? rc : rc2;
 }
 
 static int copy_and_ioctl(int cmd, struct obd_export *exp,
-- 
1.7.1
