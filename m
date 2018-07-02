From: James Simmons <jsimmons@infradead.org>
Date: Mon,  2 Jul 2018 19:24:51 -0400
Subject: [lustre-devel] [PATCH 07/10] lustre: libcfs: properly initialize
 lnet_debugfs_symlink_def
In-Reply-To: <1530573894-20592-1-git-send-email-jsimmons@infradead.org>
References: <1530573894-20592-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1530573894-20592-8-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Mirgate struct lnet_debugfs_symlink_def to C99 struct initializers.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-8066
Reviewed-on: https://review.whamcloud.com/24688
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Olaf Weber <olaf.weber@hpe.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lnet/libcfs/module.c | 28 ++++++++++++++--------------
 1 file changed, 14 insertions(+), 14 deletions(-)

diff --git a/drivers/staging/lustre/lnet/libcfs/module.c b/drivers/staging/lustre/lnet/libcfs/module.c
index 389e74c..2c4268b 100644
--- a/drivers/staging/lustre/lnet/libcfs/module.c
+++ b/drivers/staging/lustre/lnet/libcfs/module.c
@@ -562,20 +562,20 @@ static int proc_cpt_distance(struct ctl_table *table, int write,
 };
 
 static const struct lnet_debugfs_symlink_def lnet_debugfs_symlinks[] = {
-	{ "console_ratelimit",
-	  "../../../module/libcfs/parameters/libcfs_console_ratelimit"},
-	{ "debug_path",
-	  "../../../module/libcfs/parameters/libcfs_debug_file_path"},
-	{ "panic_on_lbug",
-	  "../../../module/libcfs/parameters/libcfs_panic_on_lbug"},
-	{ "console_backoff",
-	  "../../../module/libcfs/parameters/libcfs_console_backoff"},
-	{ "debug_mb",
-	  "../../../module/libcfs/parameters/libcfs_debug_mb"},
-	{ "console_min_delay_centisecs",
-	  "../../../module/libcfs/parameters/libcfs_console_min_delay"},
-	{ "console_max_delay_centisecs",
-	  "../../../module/libcfs/parameters/libcfs_console_max_delay"},
+	{ .name		= "console_ratelimit",
+	  .target	= "../../../module/libcfs/parameters/libcfs_console_ratelimit"},
+	{ .name		= "debug_path",
+	  .target	= "../../../module/libcfs/parameters/libcfs_debug_file_path"},
+	{ .name		= "panic_on_lbug",
+	  .target	= "../../../module/libcfs/parameters/libcfs_panic_on_lbug"},
+	{ .name		= "console_backoff",
+	  .target	= "../../../module/libcfs/parameters/libcfs_console_backoff"},
+	{ .name		= "debug_mb",
+	  .target	= "../../../module/libcfs/parameters/libcfs_debug_mb"},
+	{ .name		= "console_min_delay_centisecs",
+	  .target	= "../../../module/libcfs/parameters/libcfs_console_min_delay"},
+	{ .name		= "console_max_delay_centisecs",
+	  .target	= "../../../module/libcfs/parameters/libcfs_console_max_delay"},
 	{},
 };
 
-- 
1.8.3.1
