From: James Simmons <jsimmons@infradead.org>
Date: Fri,  2 Dec 2016 19:53:26 -0500
Subject: [lustre-devel] [PATCH 19/22] staging: lustre: llite: ll_dir_ioctl
	cleanup of redundant comparisons
In-Reply-To: <1480726409-20350-1-git-send-email-jsimmons@infradead.org>
References: <1480726409-20350-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1480726409-20350-20-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Parinay Kondekar <parinay.kondekar@seagate.com>, James Simmons <jsimmons@infradead.org>

From: Parinay Kondekar <parinay.kondekar@seagate.com>

In ll_dir_ioctl() two identical comparisions are present for
return code (rc) of ll_dir_getstripe(). This patch removes
the other inside if( ) condition which is not necessary.

Signed-off-by: Parinay Kondekar <parinay.kondekar@seagate.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6512
Reviewed-on: http://review.whamcloud.com/18027
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/dir.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/dir.c b/drivers/staging/lustre/lustre/llite/dir.c
index 351e900..3dc7344 100644
--- a/drivers/staging/lustre/lustre/llite/dir.c
+++ b/drivers/staging/lustre/lustre/llite/dir.c
@@ -1227,9 +1227,6 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 
 		/* Get default LMV EA */
 		if (lum.lum_magic == LMV_USER_MAGIC) {
-			if (rc)
-				goto finish_req;
-
 			if (lmmsize > sizeof(*ulmv)) {
 				rc = -EINVAL;
 				goto finish_req;
-- 
1.7.1
