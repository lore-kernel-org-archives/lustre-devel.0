From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:11:17 -0500
Subject: [lustre-devel] [PATCH 209/622] lustre: lmv: avoid gratuitous 64-bit
 modulus
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-210-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Andreas Dilger <adilger@whamcloud.com>

Fix the pct() calculation to use unsigned long arguments, since this
is what callers use.  Remove duplicate pct() definition in lproc_mdc.

Don't do a 64-bit modulus of the LNet NID to find the starting MDT
index when this isn't really needed.

Similarly, don't compute the FLD cache usage percentage for a debug
message that is never used.

Fixes: fed15ee3b3f2 ("lustre: headers: define pct(a,b) once")
WC-bug-id: https://jira.whamcloud.com/browse/LU-10171
Lustre-commit: e1b63fd21177 ("LU-10171 lmv: avoid gratuitous 64-bit modulus")
Signed-off-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/33922
Reviewed-by: Ben Evans <bevans@cray.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/fld/fld_cache.c          | 4 +---
 fs/lustre/include/lprocfs_status.h | 2 +-
 fs/lustre/include/obd.h            | 3 +--
 fs/lustre/lmv/lmv_obd.c            | 5 ++++-
 fs/lustre/mdc/lproc_mdc.c          | 8 +++-----
 5 files changed, 10 insertions(+), 12 deletions(-)

diff --git a/fs/lustre/fld/fld_cache.c b/fs/lustre/fld/fld_cache.c
index 96be544..5267ba2 100644
--- a/fs/lustre/fld/fld_cache.c
+++ b/fs/lustre/fld/fld_cache.c
@@ -98,10 +98,8 @@ void fld_cache_fini(struct fld_cache *cache)
 	fld_cache_flush(cache);
 
 	CDEBUG(D_INFO, "FLD cache statistics (%s):\n", cache->fci_name);
-	CDEBUG(D_INFO, "  Total reqs: %llu\n", cache->fci_stat.fst_count);
 	CDEBUG(D_INFO, "  Cache reqs: %llu\n", cache->fci_stat.fst_cache);
-	CDEBUG(D_INFO, "  Cache hits: %u%%\n",
-	       pct(cache->fci_stat.fst_cache, cache->fci_stat.fst_count));
+	CDEBUG(D_INFO, "  Total reqs: %llu\n", cache->fci_stat.fst_count);
 
 	kfree(cache);
 }
diff --git a/fs/lustre/include/lprocfs_status.h b/fs/lustre/include/lprocfs_status.h
index c1079f1..8d74822 100644
--- a/fs/lustre/include/lprocfs_status.h
+++ b/fs/lustre/include/lprocfs_status.h
@@ -58,7 +58,7 @@ struct lprocfs_vars {
 	umode_t				proc_mode;
 };
 
-static inline u32 pct(s64 a, s64 b)
+static inline unsigned int pct(unsigned long a, unsigned long b)
 {
 	return b ? a * 100 / b : 0;
 }
diff --git a/fs/lustre/include/obd.h b/fs/lustre/include/obd.h
index 4829e11..bf0bf97 100644
--- a/fs/lustre/include/obd.h
+++ b/fs/lustre/include/obd.h
@@ -437,11 +437,10 @@ struct lmv_obd {
 	int			connected;
 	int			max_easize;
 	int			max_def_easize;
+	u32			lmv_statfs_start;
 
 	u32			tgts_size; /* size of tgts array */
 	struct lmv_tgt_desc	**tgts;
-	int			lmv_statfs_start;
-
 	struct obd_connect_data	conn_data;
 	struct kobject		*lmv_tgts_kobj;
 };
diff --git a/fs/lustre/lmv/lmv_obd.c b/fs/lustre/lmv/lmv_obd.c
index 9f9abd3..0685925 100644
--- a/fs/lustre/lmv/lmv_obd.c
+++ b/fs/lustre/lmv/lmv_obd.c
@@ -1366,8 +1366,11 @@ static int lmv_select_statfs_mdt(struct lmv_obd *lmv, u32 flags)
 			break;
 
 		if (LNET_NETTYP(LNET_NIDNET(lnet_id.nid)) != LOLND) {
+			/* We dont need a full 64-bit modulus, just enough
+			 * to distribute the requests across MDTs evenly.
+			 */
 			lmv->lmv_statfs_start =
-				lnet_id.nid % lmv->desc.ld_tgt_count;
+				(u32)lnet_id.nid % lmv->desc.ld_tgt_count;
 			break;
 		}
 	}
diff --git a/fs/lustre/mdc/lproc_mdc.c b/fs/lustre/mdc/lproc_mdc.c
index 70c9eaf..81167bbd 100644
--- a/fs/lustre/mdc/lproc_mdc.c
+++ b/fs/lustre/mdc/lproc_mdc.c
@@ -328,7 +328,6 @@ static ssize_t mdc_rpc_stats_seq_write(struct file *file,
 	return len;
 }
 
-#define pct(a, b) (b ? a * 100 / b : 0)
 static int mdc_rpc_stats_seq_show(struct seq_file *seq, void *v)
 {
 	struct obd_device *dev = seq->private;
@@ -364,7 +363,7 @@ static int mdc_rpc_stats_seq_show(struct seq_file *seq, void *v)
 
 		read_cum += r;
 		write_cum += w;
-		seq_printf(seq, "%d:\t\t%10lu %3lu %3lu   | %10lu %3lu %3lu\n",
+		seq_printf(seq, "%d:\t\t%10lu %3u %3u   | %10lu %3u %3u\n",
 			   1 << i, r, pct(r, read_tot),
 			   pct(read_cum, read_tot), w,
 			   pct(w, write_tot),
@@ -388,7 +387,7 @@ static int mdc_rpc_stats_seq_show(struct seq_file *seq, void *v)
 
 		read_cum += r;
 		write_cum += w;
-		seq_printf(seq, "%d:\t\t%10lu %3lu %3lu   | %10lu %3lu %3lu\n",
+		seq_printf(seq, "%d:\t\t%10lu %3u %3u   | %10lu %3u %3u\n",
 			   i, r, pct(r, read_tot), pct(read_cum, read_tot), w,
 			   pct(w, write_tot), pct(write_cum, write_tot));
 		if (read_cum == read_tot && write_cum == write_tot)
@@ -410,7 +409,7 @@ static int mdc_rpc_stats_seq_show(struct seq_file *seq, void *v)
 
 		read_cum += r;
 		write_cum += w;
-		seq_printf(seq, "%d:\t\t%10lu %3lu %3lu   | %10lu %3lu %3lu\n",
+		seq_printf(seq, "%d:\t\t%10lu %3u %3u   | %10lu %3u %3u\n",
 			   (i == 0) ? 0 : 1 << (i - 1),
 			   r, pct(r, read_tot), pct(read_cum, read_tot),
 			   w, pct(w, write_tot), pct(write_cum, write_tot));
@@ -421,7 +420,6 @@ static int mdc_rpc_stats_seq_show(struct seq_file *seq, void *v)
 
 	return 0;
 }
-#undef pct
 LPROC_SEQ_FOPS(mdc_rpc_stats);
 
 static int mdc_stats_seq_show(struct seq_file *seq, void *v)
-- 
1.8.3.1
