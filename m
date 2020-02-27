From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:16:51 -0500
Subject: [lustre-devel] [PATCH 543/622] lustre: obd: perform proper division
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-544-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Lustre stats have two files lc_sum and lc_count which are both
s64 so using do_div() is completely wrong. Use div64_s64()
instead.

WC-bug-id: https://jira.whamcloud.com/browse/LU-6174
Lustre-commit: e8f793f620f4 ("LU-6174 obd: perform proper division")
Signed-off-by: James Simmons <jsimmons@infradead.org>
Reviewed-on: https://review.whamcloud.com/36751
Reviewed-by: Shaun Tancheff <stancheff@cray.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/obdclass/lprocfs_status.c | 23 +++++------------------
 1 file changed, 5 insertions(+), 18 deletions(-)

diff --git a/fs/lustre/obdclass/lprocfs_status.c b/fs/lustre/obdclass/lprocfs_status.c
index 806d6517..893f06d 100644
--- a/fs/lustre/obdclass/lprocfs_status.c
+++ b/fs/lustre/obdclass/lprocfs_status.c
@@ -799,15 +799,10 @@ int lprocfs_rd_import(struct seq_file *m, void *data)
 
 	header = &obd->obd_svc_stats->ls_cnt_header[PTLRPC_REQWAIT_CNTR];
 	lprocfs_stats_collect(obd->obd_svc_stats, PTLRPC_REQWAIT_CNTR, &ret);
-	if (ret.lc_count != 0) {
-		/* first argument to do_div MUST be u64 */
-		u64 sum = ret.lc_sum;
-
-		do_div(sum, ret.lc_count);
-		ret.lc_sum = sum;
-	} else {
+	if (ret.lc_count != 0)
+		ret.lc_sum = div64_s64(ret.lc_sum, ret.lc_count);
+	else
 		ret.lc_sum = 0;
-	}
 	seq_printf(m,
 		   "    rpcs:\n"
 		   "       inflight: %u\n"
@@ -848,11 +843,7 @@ int lprocfs_rd_import(struct seq_file *m, void *data)
 				      PTLRPC_LAST_CNTR + BRW_READ_BYTES + rw,
 				      &ret);
 		if (ret.lc_sum > 0 && ret.lc_count > 0) {
-			/* first argument to do_div MUST be u64 */
-			u64 sum = ret.lc_sum;
-
-			do_div(sum, ret.lc_count);
-			ret.lc_sum = sum;
+			ret.lc_sum = div64_s64(ret.lc_sum, ret.lc_count);
 			seq_printf(m,
 				   "    %s_data_averages:\n"
 				   "       bytes_per_rpc: %llu\n",
@@ -864,11 +855,7 @@ int lprocfs_rd_import(struct seq_file *m, void *data)
 		header = &obd->obd_svc_stats->ls_cnt_header[j];
 		lprocfs_stats_collect(obd->obd_svc_stats, j, &ret);
 		if (ret.lc_sum > 0 && ret.lc_count != 0) {
-			/* first argument to do_div MUST be u64 */
-			u64 sum = ret.lc_sum;
-
-			do_div(sum, ret.lc_count);
-			ret.lc_sum = sum;
+			ret.lc_sum = div64_s64(ret.lc_sum, ret.lc_count);
 			seq_printf(m,
 				   "       %s_per_rpc: %llu\n",
 				   header->lc_units, ret.lc_sum);
-- 
1.8.3.1
