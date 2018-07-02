From: James Simmons <jsimmons@infradead.org>
Date: Mon,  2 Jul 2018 19:24:49 -0400
Subject: [lustre-devel] [PATCH 05/10] lustre: libcfs: fix wrong debugfs
 symlink name
In-Reply-To: <1530573894-20592-1-git-send-email-jsimmons@infradead.org>
References: <1530573894-20592-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1530573894-20592-6-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

The symlink libcfs_console_backoff is incorrect. Rename to the
correct name console_backoff.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-8066
Reviewed-on: https://review.whamcloud.com/24688
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Olaf Weber <olaf.weber@hpe.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lnet/libcfs/module.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lnet/libcfs/module.c b/drivers/staging/lustre/lnet/libcfs/module.c
index f25270a..55bcb89 100644
--- a/drivers/staging/lustre/lnet/libcfs/module.c
+++ b/drivers/staging/lustre/lnet/libcfs/module.c
@@ -568,7 +568,7 @@ static int proc_cpt_distance(struct ctl_table *table, int write,
 	  "/sys/module/libcfs/parameters/libcfs_debug_file_path"},
 	{ "panic_on_lbug",
 	  "/sys/module/libcfs/parameters/libcfs_panic_on_lbug"},
-	{ "libcfs_console_backoff",
+	{ "console_backoff",
 	  "/sys/module/libcfs/parameters/libcfs_console_backoff"},
 	{ "debug_mb",
 	  "/sys/module/libcfs/parameters/libcfs_debug_mb"},
-- 
1.8.3.1
