From: James Simmons <jsimmons@infradead.org>
Date: Thu, 16 Aug 2018 23:10:20 -0400
Subject: [lustre-devel] [PATCH 17/38] lustre: llite: add newline to
 llite.*.offset_stats
In-Reply-To: <1534475441-15543-1-git-send-email-jsimmons@infradead.org>
References: <1534475441-15543-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1534475441-15543-18-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Andreas Dilger <adilger@whamcloud.com>

The llite.*.offset_stats file is missing a newline in the output.

Signed-off-by: Andreas Dilger <adilger@whamcloud.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-11147
Reviewed-on: https://review.whamcloud.com/32817
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/lproc_llite.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/lproc_llite.c b/drivers/staging/lustre/lustre/llite/lproc_llite.c
index e35b3ea..c2d27d7 100644
--- a/drivers/staging/lustre/lustre/llite/lproc_llite.c
+++ b/drivers/staging/lustre/lustre/llite/lproc_llite.c
@@ -1678,7 +1678,7 @@ static int ll_rw_offset_stats_seq_show(struct seq_file *seq, void *v)
 	for (i = 0; i < LL_OFFSET_HIST_MAX; i++) {
 		if (offset[i].rw_pid != 0)
 			seq_printf(seq,
-				   "%3c %10d %14Lu %14Lu %17lu %17lu %14Lu",
+				   "%3c %10d %14llu %14llu %17lu %17lu %14llu\n",
 				   offset[i].rw_op == READ ? 'R' : 'W',
 				   offset[i].rw_pid,
 				   offset[i].rw_range_start,
@@ -1691,7 +1691,7 @@ static int ll_rw_offset_stats_seq_show(struct seq_file *seq, void *v)
 	for (i = 0; i < LL_PROCESS_HIST_MAX; i++) {
 		if (process[i].rw_pid != 0)
 			seq_printf(seq,
-				   "%3c %10d %14Lu %14Lu %17lu %17lu %14Lu",
+				   "%3c %10d %14llu %14llu %17lu %17lu %14llu\n",
 				   process[i].rw_op == READ ? 'R' : 'W',
 				   process[i].rw_pid,
 				   process[i].rw_range_start,
-- 
1.8.3.1
