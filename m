From: James Simmons <jsimmons@infradead.org>
Date: Mon,  2 Jul 2018 19:24:46 -0400
Subject: [lustre-devel] [PATCH 02/10] lustre: libcfs: rename *_debugmb to
 *_debug_mb
In-Reply-To: <1530573894-20592-1-git-send-email-jsimmons@infradead.org>
References: <1530573894-20592-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1530573894-20592-3-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

The module parameter is called libcfs_debug_mb but the code
refers to it as *_debugmb. Change the naming to match the module
parameter.

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
index 71effcf..f2509f4 100644
--- a/drivers/staging/lustre/lnet/libcfs/debug.c
+++ b/drivers/staging/lustre/lnet/libcfs/debug.c
@@ -82,18 +82,18 @@ static int libcfs_param_debug_mb_set(const char *val,
 
 /* While debug_mb setting look like unsigned int, in fact
  * it needs quite a bunch of extra processing, so we define special
- * debugmb parameter type with corresponding methods to handle this case
+ * debug_mb parameter type with corresponding methods to handle this case
  */
-static const struct kernel_param_ops param_ops_debugmb = {
+static const struct kernel_param_ops param_ops_debug_mb = {
 	.set = libcfs_param_debug_mb_set,
 	.get = param_get_uint,
 };
 
-#define param_check_debugmb(name, p) \
+#define param_check_debug_mb(name, p) \
 		__param_check(name, p, unsigned int)
 
 static unsigned int libcfs_debug_mb;
-module_param(libcfs_debug_mb, debugmb, 0644);
+module_param(libcfs_debug_mb, debug_mb, 0644);
 MODULE_PARM_DESC(libcfs_debug_mb, "Total debug buffer size.");
 
 unsigned int libcfs_printk = D_CANTMASK;
-- 
1.8.3.1
