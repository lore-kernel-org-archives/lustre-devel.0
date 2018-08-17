From: James Simmons <jsimmons@infradead.org>
Date: Thu, 16 Aug 2018 23:10:15 -0400
Subject: [lustre-devel] [PATCH 12/38] lustre: llite: improve sysfs file text
 in lproc_llite.c
In-Reply-To: <1534475441-15543-1-git-send-email-jsimmons@infradead.org>
References: <1534475441-15543-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1534475441-15543-13-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Steve Guminski <stephenx.guminski@intel.com>

Improves the instructions displayed when reading from the stats
files.

Signed-off-by: Steve Guminski <stephenx.guminski@intel.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-8767
Reviewed-on: https://review.whamcloud.com/23942
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/lproc_llite.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/lproc_llite.c b/drivers/staging/lustre/lustre/llite/lproc_llite.c
index f57ad15..2a76c01 100644
--- a/drivers/staging/lustre/lustre/llite/lproc_llite.c
+++ b/drivers/staging/lustre/lustre/llite/lproc_llite.c
@@ -1429,8 +1429,8 @@ static int ll_rw_extents_stats_pp_seq_show(struct seq_file *seq, void *v)
 	ktime_get_real_ts64(&now);
 
 	if (!sbi->ll_rw_stats_on) {
-		seq_printf(seq, "disabled\n"
-			   "write anything in this file to activate, then 0 or \"[D/d]isabled\" to deactivate\n");
+		seq_puts(seq, "disabled\n"
+			 "write anything in this file to activate, then '0' or 'disabled' to deactivate\n");
 		return 0;
 	}
 	seq_printf(seq, "snapshot_time:	 %llu.%09lu (secs.usecs)\n",
@@ -1493,8 +1493,8 @@ static int ll_rw_extents_stats_seq_show(struct seq_file *seq, void *v)
 	ktime_get_real_ts64(&now);
 
 	if (!sbi->ll_rw_stats_on) {
-		seq_printf(seq, "disabled\n"
-			   "write anything in this file to activate, then 0 or \"[D/d]isabled\" to deactivate\n");
+		seq_puts(seq, "disabled\n"
+			 "write anything in this file to activate, then '0' or 'disabled' to deactivate\n");
 		return 0;
 	}
 	seq_printf(seq, "snapshot_time:	 %llu.%09lu (secs.usecs)\n",
@@ -1659,8 +1659,8 @@ static int ll_rw_offset_stats_seq_show(struct seq_file *seq, void *v)
 	ktime_get_real_ts64(&now);
 
 	if (!sbi->ll_rw_stats_on) {
-		seq_printf(seq, "disabled\n"
-			   "write anything in this file to activate, then 0 or \"[D/d]isabled\" to deactivate\n");
+		seq_puts(seq, "disabled\n"
+			 "write anything in this file to activate, then 0 or \"[D/d]isabled\" to deactivate\n");
 		return 0;
 	}
 	spin_lock(&sbi->ll_process_lock);
-- 
1.8.3.1
