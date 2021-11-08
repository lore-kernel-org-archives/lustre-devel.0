Return-Path: <SRS0=Xi2l=P3=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 145BBC43219
	for <lustre-devel@archiver.kernel.org>; Mon,  8 Nov 2021 15:07:57 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id A618E6113A
	for <lustre-devel@archiver.kernel.org>; Mon,  8 Nov 2021 15:07:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.1 mail.kernel.org A618E6113A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 0F67B21F1E5;
	Mon,  8 Nov 2021 07:07:54 -0800 (PST)
Received: from smtp3.ccs.ornl.gov (SMTP3.CCS.ORNL.GOV [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 29F8521C967
 for <lustre-devel@lists.lustre.org>; Mon,  8 Nov 2021 07:07:50 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 23A3C2227;
 Mon,  8 Nov 2021 10:07:46 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 1F948E07E4; Mon,  8 Nov 2021 10:07:46 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon,  8 Nov 2021 10:07:36 -0500
Message-Id: <1636384063-13838-9-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1636384063-13838-1-git-send-email-jsimmons@infradead.org>
References: <1636384063-13838-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 08/15] lustre: obdclass: add start time to
 stats files
X-BeenThere: lustre-devel@lists.lustre.org
X-Mailman-Version: 2.1.23
Precedence: list
List-Id: "For discussing Lustre software development."
 <lustre-devel-lustre.org>
List-Unsubscribe: <http://lists.lustre.org/options.cgi/lustre-devel-lustre.org>, 
 <mailto:lustre-devel-request@lists.lustre.org?subject=unsubscribe>
List-Archive: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/>
List-Post: <mailto:lustre-devel@lists.lustre.org>
List-Help: <mailto:lustre-devel-request@lists.lustre.org?subject=help>
List-Subscribe: <http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org>, 
 <mailto:lustre-devel-request@lists.lustre.org?subject=subscribe>
Cc: Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Andreas Dilger <adilger@whamcloud.com>

When the stats files are initialized or reset, store the current
timestamp with the stats.  That allows computing average IO and
RPC rates over the accumulated stats lifetime, in addition to the
normal incremental operation rates found by comparing successive
values read from the stats file with the read interval.

Any stats that currently print the "snapshot_time:" header will
now also print "start_time:" and "elapsed_time:" fields as well.
Consolodate this printing into a helper function instead of
duplicating very similar code in many different functions.  Output
can't be exactly the same for all callers, because these fields are
embedded into different types of output files, but it is very close.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11407
Lustre-commit: ea2cd3af7bfabfa68 ("LU-11407 obdclass: add start time to stats files")
Signed-off-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/33201
Reviewed-by: Ben Evans <beevans@whamcloud.com>
Reviewed-by: Arshad Hussain <arshad.hussain@aeoncomputing.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lprocfs_status.h  |  5 ++++-
 fs/lustre/include/lustre_osc.h      |  1 +
 fs/lustre/include/obd.h             |  2 ++
 fs/lustre/llite/llite_internal.h    |  5 ++++-
 fs/lustre/llite/lproc_llite.c       | 23 ++++++++---------------
 fs/lustre/mdc/lproc_mdc.c           |  8 +++-----
 fs/lustre/obdclass/genops.c         |  8 ++------
 fs/lustre/obdclass/lprocfs_status.c | 28 ++++++++++++++++++++--------
 fs/lustre/osc/lproc_osc.c           | 15 +++++----------
 9 files changed, 49 insertions(+), 46 deletions(-)

diff --git a/fs/lustre/include/lprocfs_status.h b/fs/lustre/include/lprocfs_status.h
index c8923c8..3e86e8e 100644
--- a/fs/lustre/include/lprocfs_status.h
+++ b/fs/lustre/include/lprocfs_status.h
@@ -209,6 +209,7 @@ struct lprocfs_stats {
 	/* 1 + the biggest cpu # whose ls_percpu slot has been allocated */
 	unsigned short			ls_biggest_alloc_num;
 	enum lprocfs_stats_flags	ls_flags;
+	ktime_t				ls_init;
 	/* Lock used when there are no percpu stats areas; For percpu stats,
 	 * it is used to protect ls_biggest_alloc_num change
 	 */
@@ -444,9 +445,11 @@ void ldebugfs_add_vars(struct dentry *parent, struct ldebugfs_vars *var,
 
 int lprocfs_obd_setup(struct obd_device *obd, bool uuid_only);
 int lprocfs_obd_cleanup(struct obd_device *obd);
+void lprocfs_stats_header(struct seq_file *seq, ktime_t now,
+			  ktime_t ts_init, int width, const char *colon,
+			  bool show_units);
 
 /* Generic callbacks */
-
 int ldebugfs_uint(struct seq_file *m, void *data);
 int lprocfs_wr_uint(struct file *file, const char __user *buffer,
 		    unsigned long count, void *data);
diff --git a/fs/lustre/include/lustre_osc.h b/fs/lustre/include/lustre_osc.h
index 49a5e3b..4c5eb1f 100644
--- a/fs/lustre/include/lustre_osc.h
+++ b/fs/lustre/include/lustre_osc.h
@@ -114,6 +114,7 @@ struct osc_device {
 
 	/* Write stats is actually protected by client_obd's lock. */
 	struct osc_stats {
+		ktime_t		os_init;
 		u64		os_lockless_writes;	/* by bytes */
 		u64		os_lockless_reads;	/* by bytes */
 	} od_stats;
diff --git a/fs/lustre/include/obd.h b/fs/lustre/include/obd.h
index b3ad511..27acd33 100644
--- a/fs/lustre/include/obd.h
+++ b/fs/lustre/include/obd.h
@@ -270,6 +270,7 @@ struct client_obd {
 	u32			cl_max_pages_per_rpc;
 	u32			cl_max_rpcs_in_flight;
 	u32			cl_max_short_io_bytes;
+	ktime_t			cl_stats_init;
 	struct obd_histogram    cl_read_rpc_hist;
 	struct obd_histogram    cl_write_rpc_hist;
 	struct obd_histogram    cl_read_page_hist;
@@ -330,6 +331,7 @@ struct client_obd {
 	u16			cl_close_rpcs_in_flight;
 	wait_queue_head_t	cl_mod_rpcs_waitq;
 	unsigned long	       *cl_mod_tag_bitmap;
+	ktime_t			cl_mod_rpcs_init;
 	struct obd_histogram	cl_mod_rpcs_hist;
 
 	/* mgc datastruct */
diff --git a/fs/lustre/llite/llite_internal.h b/fs/lustre/llite/llite_internal.h
index bed0443..7768c99 100644
--- a/fs/lustre/llite/llite_internal.h
+++ b/fs/lustre/llite/llite_internal.h
@@ -581,6 +581,7 @@ struct per_process_info {
 
 /* pp_extents[LL_PROCESS_HIST_MAX] will hold the combined process info */
 struct ll_rw_extents_info {
+	ktime_t pp_init;
 	struct per_process_info pp_extents[LL_PROCESS_HIST_MAX + 1];
 };
 
@@ -696,11 +697,13 @@ struct ll_sb_info {
 
 	struct lu_site		*ll_site;
 	struct cl_device	*ll_cl;
+
 	/* Statistics */
 	struct ll_rw_extents_info ll_rw_extents_info;
 	int			ll_extent_process_count;
-	struct ll_rw_process_info ll_rw_process_info[LL_PROCESS_HIST_MAX];
 	unsigned int		ll_offset_process_count;
+	ktime_t			ll_process_stats_init;
+	struct ll_rw_process_info ll_rw_process_info[LL_PROCESS_HIST_MAX];
 	struct ll_rw_process_info ll_rw_offset_info[LL_OFFSET_HIST_MAX];
 	unsigned int		ll_rw_offset_entry_count;
 	int			ll_stats_track_id;
diff --git a/fs/lustre/llite/lproc_llite.c b/fs/lustre/llite/lproc_llite.c
index eac905d..a7eb8e1 100644
--- a/fs/lustre/llite/lproc_llite.c
+++ b/fs/lustre/llite/lproc_llite.c
@@ -1967,20 +1967,16 @@ static void ll_display_extents_info(struct ll_rw_extents_info *io_extents,
 
 static int ll_rw_extents_stats_pp_seq_show(struct seq_file *seq, void *v)
 {
-	struct timespec64 now;
 	struct ll_sb_info *sbi = seq->private;
 	struct ll_rw_extents_info *io_extents = &sbi->ll_rw_extents_info;
 	int k;
 
-	ktime_get_real_ts64(&now);
-
 	if (!sbi->ll_rw_stats_on) {
 		seq_puts(seq, "disabled\n"
 			 "write anything in this file to activate, then '0' or 'disabled' to deactivate\n");
 		return 0;
 	}
-	seq_printf(seq, "snapshot_time:	 %llu.%09lu (secs.usecs)\n",
-		   (s64)now.tv_sec, (unsigned long)now.tv_nsec);
+	lprocfs_stats_header(seq, ktime_get(), io_extents->pp_init, 25, ":", 1);
 	seq_printf(seq, "%15s %19s       | %20s\n", " ", "read", "write");
 	seq_printf(seq, "%13s   %14s %4s %4s  | %14s %4s %4s\n",
 		   "extents", "calls", "%", "cum%",
@@ -2019,6 +2015,7 @@ static ssize_t ll_rw_extents_stats_pp_seq_write(struct file *file,
 		sbi->ll_rw_stats_on = 1;
 
 	spin_lock(&sbi->ll_pp_extent_lock);
+	io_extents->pp_init = ktime_get();
 	for (i = 0; i < LL_PROCESS_HIST_MAX; i++) {
 		io_extents->pp_extents[i].pid = 0;
 		lprocfs_oh_clear(&io_extents->pp_extents[i].pp_r_hist);
@@ -2032,19 +2029,16 @@ static ssize_t ll_rw_extents_stats_pp_seq_write(struct file *file,
 
 static int ll_rw_extents_stats_seq_show(struct seq_file *seq, void *v)
 {
-	struct timespec64 now;
 	struct ll_sb_info *sbi = seq->private;
 	struct ll_rw_extents_info *io_extents = &sbi->ll_rw_extents_info;
 
-	ktime_get_real_ts64(&now);
-
 	if (!sbi->ll_rw_stats_on) {
 		seq_puts(seq, "disabled\n"
 			 "write anything in this file to activate, then '0' or 'disabled' to deactivate\n");
 		return 0;
 	}
-	seq_printf(seq, "snapshot_time:	 %llu.%09lu (secs.usecs)\n",
-		   (u64)now.tv_sec, (unsigned long)now.tv_nsec);
+
+	lprocfs_stats_header(seq, ktime_get(), io_extents->pp_init, 25, ":", 1);
 
 	seq_printf(seq, "%15s %19s       | %20s\n", " ", "read", "write");
 	seq_printf(seq, "%13s   %14s %4s %4s  | %14s %4s %4s\n",
@@ -2078,6 +2072,7 @@ static ssize_t ll_rw_extents_stats_seq_write(struct file *file,
 		sbi->ll_rw_stats_on = 1;
 
 	spin_lock(&sbi->ll_pp_extent_lock);
+	io_extents->pp_init = ktime_get();
 	for (i = 0; i <= LL_PROCESS_HIST_MAX; i++) {
 		io_extents->pp_extents[i].pid = 0;
 		lprocfs_oh_clear(&io_extents->pp_extents[i].pp_r_hist);
@@ -2196,23 +2191,20 @@ void ll_rw_stats_tally(struct ll_sb_info *sbi, pid_t pid,
 
 static int ll_rw_offset_stats_seq_show(struct seq_file *seq, void *v)
 {
-	struct timespec64 now;
 	struct ll_sb_info *sbi = seq->private;
 	struct ll_rw_process_info *offset = sbi->ll_rw_offset_info;
 	struct ll_rw_process_info *process = sbi->ll_rw_process_info;
 	int i;
 
-	ktime_get_real_ts64(&now);
-
 	if (!sbi->ll_rw_stats_on) {
 		seq_puts(seq, "disabled\n"
 			 "write anything in this file to activate, then 0 or \"[D/d]isabled\" to deactivate\n");
 		return 0;
 	}
 	spin_lock(&sbi->ll_process_lock);
+	lprocfs_stats_header(seq, ktime_get(), sbi->ll_process_stats_init, 25,
+			     ":", true);
 
-	seq_printf(seq, "snapshot_time:	 %llu.%09lu (secs.usecs)\n",
-		   (s64)now.tv_sec, (unsigned long)now.tv_nsec);
 	seq_printf(seq, "%3s %10s %14s %14s %17s %17s %14s\n",
 		   "R/W", "PID", "RANGE START", "RANGE END",
 		   "SMALLEST EXTENT", "LARGEST EXTENT", "OFFSET");
@@ -2270,6 +2262,7 @@ static ssize_t ll_rw_offset_stats_seq_write(struct file *file,
 	spin_lock(&sbi->ll_process_lock);
 	sbi->ll_offset_process_count = 0;
 	sbi->ll_rw_offset_entry_count = 0;
+	sbi->ll_process_stats_init = ktime_get();
 	memset(process_info, 0, sizeof(struct ll_rw_process_info) *
 	       LL_PROCESS_HIST_MAX);
 	memset(offset_info, 0, sizeof(struct ll_rw_process_info) *
diff --git a/fs/lustre/mdc/lproc_mdc.c b/fs/lustre/mdc/lproc_mdc.c
index 87beb1b..fe93ccd 100644
--- a/fs/lustre/mdc/lproc_mdc.c
+++ b/fs/lustre/mdc/lproc_mdc.c
@@ -510,14 +510,10 @@ static int mdc_rpc_stats_seq_show(struct seq_file *seq, void *v)
 
 static int mdc_stats_seq_show(struct seq_file *seq, void *v)
 {
-	struct timespec64 now;
 	struct obd_device *obd = seq->private;
 	struct osc_stats *stats = &obd2osc_dev(obd)->od_stats;
 
-	ktime_get_real_ts64(&now);
-
-	seq_printf(seq, "snapshot_time:         %lld.%09lu (secs.nsecs)\n",
-		   (s64)now.tv_sec, now.tv_nsec);
+	lprocfs_stats_header(seq, ktime_get(), stats->os_init, 25, ":", true);
 	seq_printf(seq, "lockless_write_bytes\t\t%llu\n",
 		   stats->os_lockless_writes);
 	seq_printf(seq, "lockless_read_bytes\t\t%llu\n",
@@ -534,6 +530,8 @@ static ssize_t mdc_stats_seq_write(struct file *file,
 	struct osc_stats *stats = &obd2osc_dev(obd)->od_stats;
 
 	memset(stats, 0, sizeof(*stats));
+	stats->os_init = ktime_get();
+
 	return len;
 }
 LDEBUGFS_SEQ_FOPS(mdc_stats);
diff --git a/fs/lustre/obdclass/genops.c b/fs/lustre/obdclass/genops.c
index 4e89e0a..81e3498 100644
--- a/fs/lustre/obdclass/genops.c
+++ b/fs/lustre/obdclass/genops.c
@@ -1443,15 +1443,11 @@ int obd_set_max_mod_rpcs_in_flight(struct client_obd *cli, u16 max)
 int obd_mod_rpc_stats_seq_show(struct client_obd *cli, struct seq_file *seq)
 {
 	unsigned long mod_tot = 0, mod_cum;
-	struct timespec64 now;
 	int i;
 
-	ktime_get_real_ts64(&now);
-
 	spin_lock(&cli->cl_mod_rpcs_lock);
-
-	seq_printf(seq, "snapshot_time:		%llu.%9lu (secs.nsecs)\n",
-		   (s64)now.tv_sec, (unsigned long)now.tv_nsec);
+	lprocfs_stats_header(seq, ktime_get(), cli->cl_mod_rpcs_init, 25,
+			     ":", true);
 	seq_printf(seq, "modify_RPCs_in_flight:  %hu\n",
 		   cli->cl_mod_rpcs_in_flight);
 
diff --git a/fs/lustre/obdclass/lprocfs_status.c b/fs/lustre/obdclass/lprocfs_status.c
index db809f3..335fc34 100644
--- a/fs/lustre/obdclass/lprocfs_status.c
+++ b/fs/lustre/obdclass/lprocfs_status.c
@@ -1366,6 +1366,24 @@ static void *lprocfs_stats_seq_next(struct seq_file *p, void *v, loff_t *pos)
 	return lprocfs_stats_seq_start(p, pos);
 }
 
+void lprocfs_stats_header(struct seq_file *seq, ktime_t now, ktime_t ts_init,
+			  int width, const char *colon, bool show_units)
+{
+	const char *units = show_units ? " secs.nsecs" : "";
+	struct timespec64 ts;
+
+	ts = ktime_to_timespec64(now);
+	seq_printf(seq, "%-*s%s %llu.%09lu%s\n", width,
+		   "snapshot_time", colon, (s64)ts.tv_sec, ts.tv_nsec, units);
+	ts = ktime_to_timespec64(ts_init);
+	seq_printf(seq, "%-*s%s %llu.%09lu%s\n", width,
+		   "start_time", colon, (s64)ts.tv_sec, ts.tv_nsec, units);
+	ts = ktime_to_timespec64(ktime_sub(now, ts_init));
+	seq_printf(seq, "%-*s%s %llu.%09lu%s\n", width,
+		   "elapsed_time", colon, (s64)ts.tv_sec, ts.tv_nsec, units);
+}
+EXPORT_SYMBOL(lprocfs_stats_header);
+
 /* seq file export of one lprocfs counter */
 static int lprocfs_stats_seq_show(struct seq_file *p, void *v)
 {
@@ -1374,14 +1392,8 @@ static int lprocfs_stats_seq_show(struct seq_file *p, void *v)
 	struct lprocfs_counter ctr;
 	int idx = *(loff_t *)v;
 
-	if (idx == 0) {
-		struct timespec64 now;
-
-		ktime_get_real_ts64(&now);
-		seq_printf(p, "%-25s %llu.%9lu secs.usecs\n",
-			   "snapshot_time",
-			   (s64)now.tv_sec, (unsigned long)now.tv_nsec);
-	}
+	if (idx == 0)
+		lprocfs_stats_header(p, ktime_get(), stats->ls_init, 25, "", 1);
 
 	hdr = &stats->ls_cnt_header[idx];
 	lprocfs_stats_collect(stats, idx, &ctr);
diff --git a/fs/lustre/osc/lproc_osc.c b/fs/lustre/osc/lproc_osc.c
index f9878e0..54b86d1 100644
--- a/fs/lustre/osc/lproc_osc.c
+++ b/fs/lustre/osc/lproc_osc.c
@@ -695,18 +695,14 @@ static ssize_t grant_shrink_store(struct kobject *kobj, struct attribute *attr,
 
 static int osc_rpc_stats_seq_show(struct seq_file *seq, void *v)
 {
-	struct timespec64 now;
 	struct obd_device *obd = seq->private;
 	struct client_obd *cli = &obd->u.cli;
 	unsigned long read_tot = 0, write_tot = 0, read_cum, write_cum;
 	int i;
 
-	ktime_get_real_ts64(&now);
-
 	spin_lock(&cli->cl_loi_list_lock);
 
-	seq_printf(seq, "snapshot_time:	 %llu.%9lu (secs.usecs)\n",
-		   (s64)now.tv_sec, (unsigned long)now.tv_nsec);
+	lprocfs_stats_header(seq, ktime_get(), cli->cl_stats_init, 25, ":", 1);
 	seq_printf(seq, "read RPCs in flight:  %d\n",
 		   cli->cl_r_in_flight);
 	seq_printf(seq, "write RPCs in flight: %d\n",
@@ -806,6 +802,7 @@ static ssize_t osc_rpc_stats_seq_write(struct file *file,
 	lprocfs_oh_clear(&cli->cl_write_page_hist);
 	lprocfs_oh_clear(&cli->cl_read_offset_hist);
 	lprocfs_oh_clear(&cli->cl_write_offset_hist);
+	cli->cl_stats_init = ktime_get();
 
 	return len;
 }
@@ -814,14 +811,10 @@ static ssize_t osc_rpc_stats_seq_write(struct file *file,
 
 static int osc_stats_seq_show(struct seq_file *seq, void *v)
 {
-	struct timespec64 now;
 	struct obd_device *obd = seq->private;
 	struct osc_stats *stats = &obd2osc_dev(obd)->od_stats;
 
-	ktime_get_real_ts64(&now);
-
-	seq_printf(seq, "snapshot_time:	 %llu.%9lu (secs.usecs)\n",
-		   (s64)now.tv_sec, (unsigned long)now.tv_nsec);
+	lprocfs_stats_header(seq, ktime_get(), stats->os_init, 25, ":", true);
 	seq_printf(seq, "lockless_write_bytes\t\t%llu\n",
 		   stats->os_lockless_writes);
 	seq_printf(seq, "lockless_read_bytes\t\t%llu\n",
@@ -838,6 +831,8 @@ static ssize_t osc_stats_seq_write(struct file *file,
 	struct osc_stats *stats = &obd2osc_dev(obd)->od_stats;
 
 	memset(stats, 0, sizeof(*stats));
+	stats->os_init = ktime_get();
+
 	return len;
 }
 
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
