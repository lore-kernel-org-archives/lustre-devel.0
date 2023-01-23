Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 86206C54EAA
	for <lustre-devel@archiver.kernel.org>; Mon, 23 Jan 2023 23:11:07 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4P15K16n74z1yC5;
	Mon, 23 Jan 2023 15:04:37 -0800 (PST)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4P15G75Pp0z1yD0
 for <lustre-devel@lists.lustre.org>; Mon, 23 Jan 2023 15:02:07 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 3B9AF6D0;
 Mon, 23 Jan 2023 18:00:58 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 36B2858987; Mon, 23 Jan 2023 18:00:58 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon, 23 Jan 2023 18:00:22 -0500
Message-Id: <1674514855-15399-10-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1674514855-15399-1-git-send-email-jsimmons@infradead.org>
References: <1674514855-15399-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 09/42] lustre: ldebugfs: make job_stats and
 rename_stats valid YAML
X-BeenThere: lustre-devel@lists.lustre.org
X-Mailman-Version: 2.1.39
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
Cc: Lei Feng <flei@whamcloud.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Lei Feng <flei@whamcloud.com>

Adjust the format of job_stats and rename_stats to make
them valid YAML.  This fixes the output to correctly indent
the items to follow YAML formatting rules.

Add a test case to verify the format of these params is valid
YAML to avoid other errors being introduced in the future.

WC-bug-id: https://jira.whamcloud.com/browse/LU-16110
Lustre-commit: e96cb6ff1fea7a2bc ("LU-16110 lprocfs: make job_stats and rename_stats valid YAML")
Signed-off-by: Lei Feng <flei@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/48417
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Li Xi <lixi@ddn.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lprocfs_status.h  |  2 +-
 fs/lustre/llite/lproc_llite.c       |  8 ++++---
 fs/lustre/mdc/lproc_mdc.c           |  3 ++-
 fs/lustre/obdclass/genops.c         |  2 +-
 fs/lustre/obdclass/lprocfs_status.c | 36 ++++++++++++++++++++++-------
 fs/lustre/osc/lproc_osc.c           |  6 +++--
 6 files changed, 41 insertions(+), 16 deletions(-)

diff --git a/fs/lustre/include/lprocfs_status.h b/fs/lustre/include/lprocfs_status.h
index f53125c96683..ef923ae4ca37 100644
--- a/fs/lustre/include/lprocfs_status.h
+++ b/fs/lustre/include/lprocfs_status.h
@@ -461,7 +461,7 @@ int lprocfs_obd_setup(struct obd_device *obd, bool uuid_only);
 int lprocfs_obd_cleanup(struct obd_device *obd);
 void lprocfs_stats_header(struct seq_file *seq, ktime_t now,
 			  ktime_t ts_init, int width, const char *colon,
-			  bool show_units);
+			  bool show_units, const char *prefix);
 
 /* Generic callbacks */
 int ldebugfs_uint(struct seq_file *m, void *data);
diff --git a/fs/lustre/llite/lproc_llite.c b/fs/lustre/llite/lproc_llite.c
index a57d7bb0a848..ef7ca4c67681 100644
--- a/fs/lustre/llite/lproc_llite.c
+++ b/fs/lustre/llite/lproc_llite.c
@@ -2020,7 +2020,8 @@ static int ll_rw_extents_stats_pp_seq_show(struct seq_file *seq, void *v)
 	}
 
 	spin_lock(&sbi->ll_pp_extent_lock);
-	lprocfs_stats_header(seq, ktime_get(), rw_extents->pp_init, 25, ":", 1);
+	lprocfs_stats_header(seq, ktime_get(), rw_extents->pp_init, 25, ":",
+			     true, "");
 	seq_printf(seq, "%15s %19s       | %20s\n", " ", "read", "write");
 	seq_printf(seq, "%13s   %14s %4s %4s  | %14s %4s %4s\n",
 		   "extents", "calls", "%", "cum%", "calls", "%", "cum%");
@@ -2157,7 +2158,8 @@ static int ll_rw_extents_stats_seq_show(struct seq_file *seq, void *v)
 	}
 
 	spin_lock(&sbi->ll_lock);
-	lprocfs_stats_header(seq, ktime_get(), rw_extents->pp_init, 25, ":", 1);
+	lprocfs_stats_header(seq, ktime_get(), rw_extents->pp_init, 25, ":",
+			     true, "");
 
 	seq_printf(seq, "%15s %19s       | %20s\n", " ", "read", "write");
 	seq_printf(seq, "%13s   %14s %4s %4s  | %14s %4s %4s\n",
@@ -2341,7 +2343,7 @@ static int ll_rw_offset_stats_seq_show(struct seq_file *seq, void *v)
 	}
 	spin_lock(&sbi->ll_process_lock);
 	lprocfs_stats_header(seq, ktime_get(), sbi->ll_process_stats_init, 25,
-			     ":", true);
+			     ":", true, "");
 	seq_printf(seq, "%3s %10s %14s %14s %17s %17s %14s\n",
 		   "R/W", "PID", "RANGE START", "RANGE END",
 		   "SMALLEST EXTENT", "LARGEST EXTENT", "OFFSET");
diff --git a/fs/lustre/mdc/lproc_mdc.c b/fs/lustre/mdc/lproc_mdc.c
index cb3744ad9f93..81397a388681 100644
--- a/fs/lustre/mdc/lproc_mdc.c
+++ b/fs/lustre/mdc/lproc_mdc.c
@@ -513,7 +513,8 @@ static int mdc_stats_seq_show(struct seq_file *seq, void *v)
 	struct obd_device *obd = seq->private;
 	struct osc_stats *stats = &obd2osc_dev(obd)->od_stats;
 
-	lprocfs_stats_header(seq, ktime_get(), stats->os_init, 25, ":", true);
+	lprocfs_stats_header(seq, ktime_get(), stats->os_init, 25, ":", true,
+			     "");
 	seq_printf(seq, "lockless_write_bytes\t\t%llu\n",
 		   stats->os_lockless_writes);
 	seq_printf(seq, "lockless_read_bytes\t\t%llu\n",
diff --git a/fs/lustre/obdclass/genops.c b/fs/lustre/obdclass/genops.c
index 6e4d2402efee..a20b119f9c37 100644
--- a/fs/lustre/obdclass/genops.c
+++ b/fs/lustre/obdclass/genops.c
@@ -1448,7 +1448,7 @@ int obd_mod_rpc_stats_seq_show(struct client_obd *cli, struct seq_file *seq)
 
 	spin_lock_irq(&cli->cl_mod_rpcs_waitq.lock);
 	lprocfs_stats_header(seq, ktime_get(), cli->cl_mod_rpcs_init, 25,
-			     ":", true);
+			     ":", true, "");
 	seq_printf(seq, "modify_RPCs_in_flight:  %hu\n",
 		   cli->cl_mod_rpcs_in_flight);
 
diff --git a/fs/lustre/obdclass/lprocfs_status.c b/fs/lustre/obdclass/lprocfs_status.c
index 01b8132087d6..edc576d5f957 100644
--- a/fs/lustre/obdclass/lprocfs_status.c
+++ b/fs/lustre/obdclass/lprocfs_status.c
@@ -1373,21 +1373,40 @@ static void *lprocfs_stats_seq_next(struct seq_file *p, void *v, loff_t *pos)
 	return lprocfs_stats_seq_start(p, pos);
 }
 
+/**
+ * print header of stats including snapshot_time, start_time and elapsed_time.
+ *
+ * @seq		the file to print content to
+ * @now		end time to calculate elapsed_time
+ * @ts_init		start time to calculate elapsed_time
+ * @width		the width of key to align them well
+ * @colon		"" or ":"
+ * @show_units		show units or not
+ * @prefix		prefix (indent) before printing each line of header
+ *			to align them with other content
+ */
 void lprocfs_stats_header(struct seq_file *seq, ktime_t now, ktime_t ts_init,
-			  int width, const char *colon, bool show_units)
+			  int width, const char *colon, bool show_units,
+			  const char *prefix)
 {
 	const char *units = show_units ? " secs.nsecs" : "";
 	struct timespec64 ts;
+	const char *field;
 
+	field = (colon && colon[0]) ? "snapshot_time:" : "snapshot_time";
 	ts = ktime_to_timespec64(now);
-	seq_printf(seq, "%-*s%s %llu.%09lu%s\n", width,
-		   "snapshot_time", colon, (s64)ts.tv_sec, ts.tv_nsec, units);
+	seq_printf(seq, "%s%-*s %llu.%09lu%s\n", prefix, width, field,
+		   (s64)ts.tv_sec, ts.tv_nsec, units);
+
+	field = (colon && colon[0]) ? "start_time:" : "start_time";
 	ts = ktime_to_timespec64(ts_init);
-	seq_printf(seq, "%-*s%s %llu.%09lu%s\n", width,
-		   "start_time", colon, (s64)ts.tv_sec, ts.tv_nsec, units);
+	seq_printf(seq, "%s%-*s %llu.%09lu%s\n", prefix, width, field,
+		   (s64)ts.tv_sec, ts.tv_nsec, units);
+
+	field = (colon && colon[0]) ? "elapsed_time:" : "elapsed_time";
 	ts = ktime_to_timespec64(ktime_sub(now, ts_init));
-	seq_printf(seq, "%-*s%s %llu.%09lu%s\n", width,
-		   "elapsed_time", colon, (s64)ts.tv_sec, ts.tv_nsec, units);
+	seq_printf(seq, "%s%-*s %llu.%09lu%s\n", prefix, width, field,
+		   (s64)ts.tv_sec, ts.tv_nsec, units);
 }
 EXPORT_SYMBOL(lprocfs_stats_header);
 
@@ -1400,7 +1419,8 @@ static int lprocfs_stats_seq_show(struct seq_file *p, void *v)
 	int idx = *(loff_t *)v;
 
 	if (idx == 0)
-		lprocfs_stats_header(p, ktime_get(), stats->ls_init, 25, "", 1);
+		lprocfs_stats_header(p, ktime_get(), stats->ls_init, 25, "",
+				     true, "");
 
 	hdr = &stats->ls_cnt_header[idx];
 	lprocfs_stats_collect(stats, idx, &ctr);
diff --git a/fs/lustre/osc/lproc_osc.c b/fs/lustre/osc/lproc_osc.c
index 54b86d17eb78..c4b1e3e4e2cc 100644
--- a/fs/lustre/osc/lproc_osc.c
+++ b/fs/lustre/osc/lproc_osc.c
@@ -702,7 +702,8 @@ static int osc_rpc_stats_seq_show(struct seq_file *seq, void *v)
 
 	spin_lock(&cli->cl_loi_list_lock);
 
-	lprocfs_stats_header(seq, ktime_get(), cli->cl_stats_init, 25, ":", 1);
+	lprocfs_stats_header(seq, ktime_get(), cli->cl_stats_init, 25, ":",
+			     true, "");
 	seq_printf(seq, "read RPCs in flight:  %d\n",
 		   cli->cl_r_in_flight);
 	seq_printf(seq, "write RPCs in flight: %d\n",
@@ -814,7 +815,8 @@ static int osc_stats_seq_show(struct seq_file *seq, void *v)
 	struct obd_device *obd = seq->private;
 	struct osc_stats *stats = &obd2osc_dev(obd)->od_stats;
 
-	lprocfs_stats_header(seq, ktime_get(), stats->os_init, 25, ":", true);
+	lprocfs_stats_header(seq, ktime_get(), stats->os_init, 25, ":", true,
+			     "");
 	seq_printf(seq, "lockless_write_bytes\t\t%llu\n",
 		   stats->os_lockless_writes);
 	seq_printf(seq, "lockless_read_bytes\t\t%llu\n",
-- 
2.27.0

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
