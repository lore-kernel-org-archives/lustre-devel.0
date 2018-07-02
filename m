From: James Simmons <jsimmons@infradead.org>
Date: Mon,  2 Jul 2018 19:24:50 -0400
Subject: [lustre-devel] [PATCH 06/10] lustre: libcfs: don't assume sysfs
 mount point
In-Reply-To: <1530573894-20592-1-git-send-email-jsimmons@infradead.org>
References: <1530573894-20592-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1530573894-20592-7-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

The symlinks created for the libcfs module parameters assume the
mount point of syfs is always /sys. We shouldn't assume that is
the case so use relative paths that guaranteed to work.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-8066
Reviewed-on: https://review.whamcloud.com/24688
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Olaf Weber <olaf.weber@hpe.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lnet/libcfs/module.c | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/staging/lustre/lnet/libcfs/module.c b/drivers/staging/lustre/lnet/libcfs/module.c
index 55bcb89..389e74c 100644
--- a/drivers/staging/lustre/lnet/libcfs/module.c
+++ b/drivers/staging/lustre/lnet/libcfs/module.c
@@ -563,19 +563,19 @@ static int proc_cpt_distance(struct ctl_table *table, int write,
 
 static const struct lnet_debugfs_symlink_def lnet_debugfs_symlinks[] = {
 	{ "console_ratelimit",
-	  "/sys/module/libcfs/parameters/libcfs_console_ratelimit"},
+	  "../../../module/libcfs/parameters/libcfs_console_ratelimit"},
 	{ "debug_path",
-	  "/sys/module/libcfs/parameters/libcfs_debug_file_path"},
+	  "../../../module/libcfs/parameters/libcfs_debug_file_path"},
 	{ "panic_on_lbug",
-	  "/sys/module/libcfs/parameters/libcfs_panic_on_lbug"},
+	  "../../../module/libcfs/parameters/libcfs_panic_on_lbug"},
 	{ "console_backoff",
-	  "/sys/module/libcfs/parameters/libcfs_console_backoff"},
+	  "../../../module/libcfs/parameters/libcfs_console_backoff"},
 	{ "debug_mb",
-	  "/sys/module/libcfs/parameters/libcfs_debug_mb"},
+	  "../../../module/libcfs/parameters/libcfs_debug_mb"},
 	{ "console_min_delay_centisecs",
-	  "/sys/module/libcfs/parameters/libcfs_console_min_delay"},
+	  "../../../module/libcfs/parameters/libcfs_console_min_delay"},
 	{ "console_max_delay_centisecs",
-	  "/sys/module/libcfs/parameters/libcfs_console_max_delay"},
+	  "../../../module/libcfs/parameters/libcfs_console_max_delay"},
 	{},
 };
 
-- 
1.8.3.1
