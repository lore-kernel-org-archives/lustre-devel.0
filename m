From: James Simmons <jsimmons@infradead.org>
Date: Mon,  2 Jul 2018 19:24:54 -0400
Subject: [lustre-devel] [PATCH 10/10] lustre: libcfs: small cleanups for
 debugfs code
In-Reply-To: <1530573894-20592-1-git-send-email-jsimmons@infradead.org>
References: <1530573894-20592-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1530573894-20592-11-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Small cleanups to make the code easier to read.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-8066
Reviewed-on: https://review.whamcloud.com/24688
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Olaf Weber <olaf.weber@hpe.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lnet/libcfs/debug.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/staging/lustre/lnet/libcfs/debug.c b/drivers/staging/lustre/lnet/libcfs/debug.c
index 5d93341..d925bf5 100644
--- a/drivers/staging/lustre/lnet/libcfs/debug.c
+++ b/drivers/staging/lustre/lnet/libcfs/debug.c
@@ -180,9 +180,11 @@ static int param_set_uint_minmax(const char *val,
 
 	if (!val)
 		return -EINVAL;
+
 	ret = kstrtouint(val, 0, &num);
 	if (ret < 0 || num < min || num > max)
 		return -EINVAL;
+
 	*((unsigned int *)kp->arg) = num;
 	return 0;
 }
@@ -229,8 +231,7 @@ static int param_set_uintpos(const char *val, const struct kernel_param *kp)
 int libcfs_panic_in_progress;
 
 /* libcfs_debug_token2mask() expects the returned string in lower-case */
-static const char *
-libcfs_debug_subsys2str(int subsys)
+static const char *libcfs_debug_subsys2str(int subsys)
 {
 	static const char * const libcfs_debug_subsystems[] =
 		LIBCFS_DEBUG_SUBSYS_NAMES;
@@ -242,8 +243,7 @@ static int param_set_uintpos(const char *val, const struct kernel_param *kp)
 }
 
 /* libcfs_debug_token2mask() expects the returned string in lower-case */
-static const char *
-libcfs_debug_dbg2str(int debug)
+static const char *libcfs_debug_dbg2str(int debug)
 {
 	static const char * const libcfs_debug_masks[] =
 		LIBCFS_DEBUG_MASKS_NAMES;
-- 
1.8.3.1
