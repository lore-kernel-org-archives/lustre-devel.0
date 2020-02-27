From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:10:53 -0500
Subject: [lustre-devel] [PATCH 185/622] lustre: headers: define pct(a,
 b) once
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-186-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Ben Evans <bevans@cray.com>

pct is defined 6 times in different places.  Define it in one.
Also change it to a static inline to do a better job of
enforcing types.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10171
Lustre-commit: 9b924e86b27d ("LU-10171 headers: define pct(a,b) once")
Signed-off-by: Ben Evans <bevans@cray.com>
Reviewed-on: https://review.whamcloud.com/29852
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/fld/fld_cache.c          | 12 ++----------
 fs/lustre/include/lprocfs_status.h |  5 +++++
 fs/lustre/llite/lproc_llite.c      |  7 +++----
 fs/lustre/obdclass/genops.c        |  6 +-----
 fs/lustre/osc/lproc_osc.c          | 10 +++-------
 5 files changed, 14 insertions(+), 26 deletions(-)

diff --git a/fs/lustre/fld/fld_cache.c b/fs/lustre/fld/fld_cache.c
index d289c29..96be544 100644
--- a/fs/lustre/fld/fld_cache.c
+++ b/fs/lustre/fld/fld_cache.c
@@ -94,22 +94,14 @@ struct fld_cache *fld_cache_init(const char *name,
  */
 void fld_cache_fini(struct fld_cache *cache)
 {
-	u64 pct;
-
 	LASSERT(cache);
 	fld_cache_flush(cache);
 
-	if (cache->fci_stat.fst_count > 0) {
-		pct = cache->fci_stat.fst_cache * 100;
-		do_div(pct, cache->fci_stat.fst_count);
-	} else {
-		pct = 0;
-	}
-
 	CDEBUG(D_INFO, "FLD cache statistics (%s):\n", cache->fci_name);
 	CDEBUG(D_INFO, "  Total reqs: %llu\n", cache->fci_stat.fst_count);
 	CDEBUG(D_INFO, "  Cache reqs: %llu\n", cache->fci_stat.fst_cache);
-	CDEBUG(D_INFO, "  Cache hits: %llu%%\n", pct);
+	CDEBUG(D_INFO, "  Cache hits: %u%%\n",
+	       pct(cache->fci_stat.fst_cache, cache->fci_stat.fst_count));
 
 	kfree(cache);
 }
diff --git a/fs/lustre/include/lprocfs_status.h b/fs/lustre/include/lprocfs_status.h
index 32d43fb..1ef548ae 100644
--- a/fs/lustre/include/lprocfs_status.h
+++ b/fs/lustre/include/lprocfs_status.h
@@ -58,6 +58,11 @@ struct lprocfs_vars {
 	umode_t				proc_mode;
 };
 
+static inline u32 pct(s64 a, s64 b)
+{
+	return b ? a * 100 / b : 0;
+}
+
 struct lprocfs_static_vars {
 	struct lprocfs_vars		*obd_vars;
 	const struct attribute_group	*sysfs_vars;
diff --git a/fs/lustre/llite/lproc_llite.c b/fs/lustre/llite/lproc_llite.c
index 5fc7705..4060271 100644
--- a/fs/lustre/llite/lproc_llite.c
+++ b/fs/lustre/llite/lproc_llite.c
@@ -1483,8 +1483,6 @@ void ll_debugfs_unregister_super(struct super_block *sb)
 	lprocfs_free_stats(&sbi->ll_stats);
 }
 
-#define pct(a, b) (b ? a * 100 / b : 0)
-
 static void ll_display_extents_info(struct ll_rw_extents_info *io_extents,
 				    struct seq_file *seq, int which)
 {
@@ -1508,8 +1506,9 @@ static void ll_display_extents_info(struct ll_rw_extents_info *io_extents,
 		w = pp_info->pp_w_hist.oh_buckets[i];
 		read_cum += r;
 		write_cum += w;
-		end = 1 << (i + LL_HIST_START - units);
-		seq_printf(seq, "%4lu%c - %4lu%c%c: %14lu %4lu %4lu  | %14lu %4lu %4lu\n",
+		end = BIT(i + LL_HIST_START - units);
+		seq_printf(seq,
+			   "%4lu%c - %4lu%c%c: %14lu %4u %4u  | %14lu %4u %4u\n",
 			   start, *unitp, end, *unitp,
 			   (i == LL_HIST_MAX - 1) ? '+' : ' ',
 			   r, pct(r, read_tot), pct(read_cum, read_tot),
diff --git a/fs/lustre/obdclass/genops.c b/fs/lustre/obdclass/genops.c
index 2254943..fd9dd96 100644
--- a/fs/lustre/obdclass/genops.c
+++ b/fs/lustre/obdclass/genops.c
@@ -1425,8 +1425,6 @@ int obd_set_max_mod_rpcs_in_flight(struct client_obd *cli, u16 max)
 }
 EXPORT_SYMBOL(obd_set_max_mod_rpcs_in_flight);
 
-#define pct(a, b) (b ? (a * 100) / b : 0)
-
 int obd_mod_rpc_stats_seq_show(struct client_obd *cli, struct seq_file *seq)
 {
 	unsigned long mod_tot = 0, mod_cum;
@@ -1452,7 +1450,7 @@ int obd_mod_rpc_stats_seq_show(struct client_obd *cli, struct seq_file *seq)
 		unsigned long mod = cli->cl_mod_rpcs_hist.oh_buckets[i];
 
 		mod_cum += mod;
-		seq_printf(seq, "%d:\t\t%10lu %3lu %3lu\n",
+		seq_printf(seq, "%d:\t\t%10lu %3u %3u\n",
 			   i, mod, pct(mod, mod_tot),
 			   pct(mod_cum, mod_tot));
 		if (mod_cum == mod_tot)
@@ -1464,8 +1462,6 @@ int obd_mod_rpc_stats_seq_show(struct client_obd *cli, struct seq_file *seq)
 	return 0;
 }
 EXPORT_SYMBOL(obd_mod_rpc_stats_seq_show);
-#undef pct
-
 /*
  * The number of modify RPCs sent in parallel is limited
  * because the server has a finite number of slots per client to
diff --git a/fs/lustre/osc/lproc_osc.c b/fs/lustre/osc/lproc_osc.c
index d9030b7..ac64724 100644
--- a/fs/lustre/osc/lproc_osc.c
+++ b/fs/lustre/osc/lproc_osc.c
@@ -780,8 +780,6 @@ static ssize_t grant_shrink_store(struct kobject *kobj, struct attribute *attr,
 	{ NULL }
 };
 
-#define pct(a, b) (b ? a * 100 / b : 0)
-
 static int osc_rpc_stats_seq_show(struct seq_file *seq, void *v)
 {
 	struct timespec64 now;
@@ -820,7 +818,7 @@ static int osc_rpc_stats_seq_show(struct seq_file *seq, void *v)
 
 		read_cum += r;
 		write_cum += w;
-		seq_printf(seq, "%d:\t\t%10lu %3lu %3lu   | %10lu %3lu %3lu\n",
+		seq_printf(seq, "%d:\t\t%10lu %3u %3u   | %10lu %3u %3u\n",
 			   1 << i, r, pct(r, read_tot),
 			   pct(read_cum, read_tot), w,
 			   pct(w, write_tot),
@@ -844,7 +842,7 @@ static int osc_rpc_stats_seq_show(struct seq_file *seq, void *v)
 
 		read_cum += r;
 		write_cum += w;
-		seq_printf(seq, "%d:\t\t%10lu %3lu %3lu   | %10lu %3lu %3lu\n",
+		seq_printf(seq, "%d:\t\t%10lu %3u %3u   | %10lu %3u %3u\n",
 			   i, r, pct(r, read_tot),
 			   pct(read_cum, read_tot), w,
 			   pct(w, write_tot),
@@ -868,7 +866,7 @@ static int osc_rpc_stats_seq_show(struct seq_file *seq, void *v)
 
 		read_cum += r;
 		write_cum += w;
-		seq_printf(seq, "%d:\t\t%10lu %3lu %3lu   | %10lu %3lu %3lu\n",
+		seq_printf(seq, "%d:\t\t%10lu %3u %3u   | %10lu %3u %3u\n",
 			   (i == 0) ? 0 : 1 << (i - 1),
 			   r, pct(r, read_tot), pct(read_cum, read_tot),
 			   w, pct(w, write_tot), pct(write_cum, write_tot));
@@ -881,8 +879,6 @@ static int osc_rpc_stats_seq_show(struct seq_file *seq, void *v)
 	return 0;
 }
 
-#undef pct
-
 static ssize_t osc_rpc_stats_seq_write(struct file *file,
 				       const char __user *buf,
 				       size_t len, loff_t *off)
-- 
1.8.3.1
