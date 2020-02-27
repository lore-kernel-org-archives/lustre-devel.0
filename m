From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:09:54 -0500
Subject: [lustre-devel] [PATCH 126/622] lustre: llite: zero lum for
 stripeless files
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-127-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: "John L. Hammond" <jhammond@whamcloud.com>

In the IOC_MDC_GETFILEINFO/LL_IOC_MDC_GETINFO case of ll_dir_ioctl(),
if the file has no striping then zero out the lum buffer so that
userspace won't be confused by garbage.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11380
Lustre-commit: fab95b4345db ("LU-11380 llite: zero lum for stripeless files")
Signed-off-by: John L. Hammond <jhammond@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/33172
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Jian Yu <yujian@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/dir.c | 26 +++++++++++++++++---------
 1 file changed, 17 insertions(+), 9 deletions(-)

diff --git a/fs/lustre/llite/dir.c b/fs/lustre/llite/dir.c
index 06f7bd3..55a1efb 100644
--- a/fs/lustre/llite/dir.c
+++ b/fs/lustre/llite/dir.c
@@ -1442,15 +1442,14 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 			goto out_req;
 		}
 
-		if (rc < 0) {
-			if (rc == -ENODATA && (cmd == IOC_MDC_GETFILEINFO ||
-					       cmd == LL_IOC_MDC_GETINFO)) {
-				rc = 0;
-				goto skip_lmm;
-			}
+		if (rc == -ENODATA && (cmd == IOC_MDC_GETFILEINFO ||
+				       cmd == LL_IOC_MDC_GETINFO)) {
+			lmmsize = 0;
+			rc = 0;
+		}
 
+		if (rc < 0)
 			goto out_req;
-		}
 
 		if (cmd == IOC_MDC_GETFILESTRIPE ||
 		    cmd == LL_IOC_LOV_GETSTRIPE ||
@@ -1462,14 +1461,23 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 			lmdp = (struct lov_user_mds_data __user *)arg;
 			lump = &lmdp->lmd_lmm;
 		}
-		if (copy_to_user(lump, lmm, lmmsize)) {
+
+		if (lmmsize == 0) {
+			/* If the file has no striping then zero out *lump so
+			 * that the caller isn't confused by garbage.
+			 */
+			if (clear_user(lump, sizeof(*lump))) {
+				rc = -EFAULT;
+				goto out_req;
+			}
+		} else if (copy_to_user(lump, lmm, lmmsize)) {
 			if (copy_to_user(lump, lmm, sizeof(*lump))) {
 				rc = -EFAULT;
 				goto out_req;
 			}
 			rc = -EOVERFLOW;
 		}
-skip_lmm:
+
 		if (cmd == IOC_MDC_GETFILEINFO || cmd == LL_IOC_MDC_GETINFO) {
 			struct lov_user_mds_data __user *lmdp;
 			lstat_t st = { 0 };
-- 
1.8.3.1
