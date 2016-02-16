From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Tue, 16 Feb 2016 00:46:36 -0500
Subject: [lustre-devel] [PATCH 04/45] staging/lustre/llite: Get rid of /proc
	references in comments
In-Reply-To: <1455601637-3847710-1-git-send-email-green@linuxhacker.ru>
References: <1455601637-3847710-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1455601637-3847710-5-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

Now that the sysfs conversion is complete, also convert all the
remaining comments

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/llite/lproc_llite.c | 2 +-
 drivers/staging/lustre/lustre/llite/vvp_io.c      | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/lproc_llite.c b/drivers/staging/lustre/lustre/llite/lproc_llite.c
index f134ad9..8d3c788 100644
--- a/drivers/staging/lustre/lustre/llite/lproc_llite.c
+++ b/drivers/staging/lustre/lustre/llite/lproc_llite.c
@@ -43,7 +43,7 @@
 #include "llite_internal.h"
 #include "vvp_internal.h"
 
-/* /proc/lustre/llite mount point registration */
+/* debugfs llite mount point registration */
 static struct file_operations ll_rw_extents_stats_fops;
 static struct file_operations ll_rw_extents_stats_pp_fops;
 static struct file_operations ll_rw_offset_stats_fops;
diff --git a/drivers/staging/lustre/lustre/llite/vvp_io.c b/drivers/staging/lustre/lustre/llite/vvp_io.c
index 0920ac6..573ab15 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_io.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_io.c
@@ -1003,7 +1003,7 @@ static int vvp_io_commit_write(const struct lu_env *env,
 	 *
 	 *     (3) IO is batched up to the RPC size and is async until the
 	 *     client max cache is hit
-	 *     (/proc/fs/lustre/osc/OSC.../max_dirty_mb)
+	 *     (/sys/fs/lustre/osc/OSC.../max_dirty_mb)
 	 *
 	 */
 	if (!PageDirty(vmpage)) {
-- 
2.1.0
