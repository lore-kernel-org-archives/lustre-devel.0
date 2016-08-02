From: Baole Ni <baolex.ni@intel.com>
Date: Tue,  2 Aug 2016 19:58:36 +0800
Subject: [lustre-devel] [PATCH 0925/1285] Replace numeric parameter like
	0444 with macro
Message-ID: <20160802115836.11666-1-baolex.ni@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: oleg.drokin@intel.com, andreas.dilger@intel.com, gregkh@linuxfoundation.org, jejb@linux.vnet.ibm.com, martin.petersen@oracle.com, m.chehab@samsung.com, pawel@osciak.com, m.szyprowski@samsung.com, kyungmin.park@samsung.com, k.kozlowski@samsung.com
Cc: lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, jsimmons@infradead.org, john.hammond@intel.com, shraddha.6596@gmail.com, fan.yong@intel.com, dmitry.eremin@intel.com, jinshan.xiong@intel.com, chuansheng.liu@intel.com, baolex.ni@intel.com

I find that the developers often just specified the numeric value
when calling a macro which is defined with a parameter for access permission.
As we know, these numeric value for access permission have had the corresponding macro,
and that using macro can improve the robustness and readability of the code,
thus, I suggest replacing the numeric parameter with the macro.

Signed-off-by: Chuansheng Liu <chuansheng.liu@intel.com>
Signed-off-by: Baole Ni <baolex.ni@intel.com>
---
 drivers/staging/lustre/lnet/libcfs/debug.c | 20 ++++++++++----------
 1 file changed, 10 insertions(+), 10 deletions(-)

diff --git a/drivers/staging/lustre/lnet/libcfs/debug.c b/drivers/staging/lustre/lnet/libcfs/debug.c
index 8c260c3..4eca40f 100644
--- a/drivers/staging/lustre/lnet/libcfs/debug.c
+++ b/drivers/staging/lustre/lnet/libcfs/debug.c
@@ -48,13 +48,13 @@ static char debug_file_name[1024];
 
 unsigned int libcfs_subsystem_debug = ~0;
 EXPORT_SYMBOL(libcfs_subsystem_debug);
-module_param(libcfs_subsystem_debug, int, 0644);
+module_param(libcfs_subsystem_debug, int, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(libcfs_subsystem_debug, "Lustre kernel debug subsystem mask");
 
 unsigned int libcfs_debug = (D_CANTMASK |
 			     D_NETERROR | D_HA | D_CONFIG | D_IOCTL);
 EXPORT_SYMBOL(libcfs_debug);
-module_param(libcfs_debug, int, 0644);
+module_param(libcfs_debug, int, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(libcfs_debug, "Lustre kernel debug mask");
 
 static int libcfs_param_debug_mb_set(const char *val,
@@ -93,15 +93,15 @@ static struct kernel_param_ops param_ops_debugmb = {
 		__param_check(name, p, unsigned int)
 
 static unsigned int libcfs_debug_mb;
-module_param(libcfs_debug_mb, debugmb, 0644);
+module_param(libcfs_debug_mb, debugmb, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(libcfs_debug_mb, "Total debug buffer size.");
 
 unsigned int libcfs_printk = D_CANTMASK;
-module_param(libcfs_printk, uint, 0644);
+module_param(libcfs_printk, uint, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(libcfs_printk, "Lustre kernel debug console mask");
 
 unsigned int libcfs_console_ratelimit = 1;
-module_param(libcfs_console_ratelimit, uint, 0644);
+module_param(libcfs_console_ratelimit, uint, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(libcfs_console_ratelimit, "Lustre kernel debug console ratelimit (0 to disable)");
 
 static int param_set_delay_minmax(const char *val,
@@ -150,7 +150,7 @@ static struct kernel_param_ops param_ops_console_max_delay = {
 #define param_check_console_max_delay(name, p) \
 		__param_check(name, p, unsigned int)
 
-module_param(libcfs_console_max_delay, console_max_delay, 0644);
+module_param(libcfs_console_max_delay, console_max_delay, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(libcfs_console_max_delay, "Lustre kernel debug console max delay (jiffies)");
 
 static int param_set_console_min_delay(const char *val,
@@ -168,7 +168,7 @@ static struct kernel_param_ops param_ops_console_min_delay = {
 #define param_check_console_min_delay(name, p) \
 		__param_check(name, p, unsigned int)
 
-module_param(libcfs_console_min_delay, console_min_delay, 0644);
+module_param(libcfs_console_min_delay, console_min_delay, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(libcfs_console_min_delay, "Lustre kernel debug console min delay (jiffies)");
 
 static int param_set_uint_minmax(const char *val,
@@ -201,7 +201,7 @@ static struct kernel_param_ops param_ops_uintpos = {
 		__param_check(name, p, unsigned int)
 
 unsigned int libcfs_console_backoff = CDEBUG_DEFAULT_BACKOFF;
-module_param(libcfs_console_backoff, uintpos, 0644);
+module_param(libcfs_console_backoff, uintpos, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(libcfs_console_backoff, "Lustre kernel debug console backoff factor");
 
 unsigned int libcfs_debug_binary = 1;
@@ -213,7 +213,7 @@ unsigned int libcfs_catastrophe;
 EXPORT_SYMBOL(libcfs_catastrophe);
 
 unsigned int libcfs_panic_on_lbug = 1;
-module_param(libcfs_panic_on_lbug, uint, 0644);
+module_param(libcfs_panic_on_lbug, uint, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(libcfs_panic_on_lbug, "Lustre kernel panic on LBUG");
 
 static wait_queue_head_t debug_ctlwq;
@@ -222,7 +222,7 @@ char libcfs_debug_file_path_arr[PATH_MAX] = LIBCFS_DEBUG_FILE_PATH_DEFAULT;
 
 /* We need to pass a pointer here, but elsewhere this must be a const */
 static char *libcfs_debug_file_path;
-module_param(libcfs_debug_file_path, charp, 0644);
+module_param(libcfs_debug_file_path, charp, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(libcfs_debug_file_path,
 		 "Path for dumping debug logs, set 'NONE' to prevent log dumping");
 
-- 
2.9.2
