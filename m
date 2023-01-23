Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 1D477C05027
	for <lustre-devel@archiver.kernel.org>; Mon, 23 Jan 2023 23:12:32 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4P15KJ1vK6z21Bq;
	Mon, 23 Jan 2023 15:04:52 -0800 (PST)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4P15Gs5xMtz1yFc
 for <lustre-devel@lists.lustre.org>; Mon, 23 Jan 2023 15:02:45 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 412C76D1;
 Mon, 23 Jan 2023 18:00:58 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 3AA5F58995; Mon, 23 Jan 2023 18:00:58 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon, 23 Jan 2023 18:00:23 -0500
Message-Id: <1674514855-15399-11-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1674514855-15399-1-git-send-email-jsimmons@infradead.org>
References: <1674514855-15399-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 10/42] lustre: misc: fix stats snapshot_time
 to use wallclock
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
Cc: Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Andreas Dilger <adilger@whamcloud.com>

The timestamps reported during stats collection inadvertently changed
from being POSIX epoch timestamps to elapsed-from-boot timestamps.

While some collection tools ignore these timestamps, or only use the
delta between successive reads, having uniform timestaps in stats
files simplifies stats correlation between different servers.

Revert the snapshot_time back to showing wallclock time.

Some "init" times were not initialized when stats were allocated or
cleared, do this for all stats shown by lprocfs_stats_header().

Rename struct osc_device fields from od_ to osc_ to avoid confusion
with struct osd_device. Having two od_stats was especially confusing.

Fixes: 653198e691 ("lustre: obdclass: add start time to stats files")
WC-bug-id: https://jira.whamcloud.com/browse/LU-16231
Lustre-commit: e42efe35eec7b9725 ("LU-16231 misc: fix stats snapshot_time to use wallclock")
Signed-off-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/48821
Reviewed-by: Li Xi <lixi@ddn.com>
Reviewed-by: Ellis Wilson <elliswilson@microsoft.com>
Reviewed-by: Feng Lei <flei@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_osc.h      | 16 ++++++++--------
 fs/lustre/ldlm/ldlm_lib.c           |  1 +
 fs/lustre/llite/lproc_llite.c       | 20 +++++++++++---------
 fs/lustre/mdc/lproc_mdc.c           | 11 ++++++-----
 fs/lustre/mdc/mdc_dev.c             | 13 +++++++------
 fs/lustre/obdclass/genops.c         |  2 +-
 fs/lustre/obdclass/lprocfs_status.c |  6 ++++--
 fs/lustre/osc/lproc_osc.c           | 16 ++++++++--------
 fs/lustre/osc/osc_cache.c           |  2 +-
 fs/lustre/osc/osc_dev.c             | 17 +++++++++--------
 10 files changed, 56 insertions(+), 48 deletions(-)

diff --git a/fs/lustre/include/lustre_osc.h b/fs/lustre/include/lustre_osc.h
index 526093ebff18..3b936c7dc1a1 100644
--- a/fs/lustre/include/lustre_osc.h
+++ b/fs/lustre/include/lustre_osc.h
@@ -114,18 +114,18 @@ static inline void osc_wake_cache_waiters(struct client_obd *cli)
 }
 
 struct osc_device {
-	struct cl_device	od_cl;
-	struct obd_export	*od_exp;
+	struct cl_device	osc_cl;
+	struct obd_export	*osc_exp;
 
 	/* Write stats is actually protected by client_obd's lock. */
 	struct osc_stats {
 		ktime_t		os_init;
 		u64		os_lockless_writes;	/* by bytes */
 		u64		os_lockless_reads;	/* by bytes */
-	} od_stats;
+	} osc_stats;
 
 	/* configuration item(s) */
-	time64_t		od_contention_time;
+	time64_t		osc_contention_time;
 };
 
 /* \defgroup osc osc
@@ -772,12 +772,12 @@ static inline struct osc_io *osc_env_io(const struct lu_env *env)
 
 static inline struct osc_device *lu2osc_dev(const struct lu_device *d)
 {
-	return container_of(d, struct osc_device, od_cl.cd_lu_dev);
+	return container_of(d, struct osc_device, osc_cl.cd_lu_dev);
 }
 
 static inline struct obd_export *osc_export(const struct osc_object *obj)
 {
-	return lu2osc_dev(obj->oo_cl.co_lu.lo_dev)->od_exp;
+	return lu2osc_dev(obj->oo_cl.co_lu.lo_dev)->osc_exp;
 }
 
 static inline struct client_obd *osc_cli(const struct osc_object *obj)
@@ -798,12 +798,12 @@ static inline struct cl_object *osc2cl(const struct osc_object *obj)
 static inline struct osc_device *obd2osc_dev(const struct obd_device *obd)
 {
 	return container_of_safe(obd->obd_lu_dev, struct osc_device,
-				 od_cl.cd_lu_dev);
+				 osc_cl.cd_lu_dev);
 }
 
 static inline struct lu_device *osc2lu_dev(struct osc_device *osc)
 {
-	return &osc->od_cl.cd_lu_dev;
+	return &osc->osc_cl.cd_lu_dev;
 }
 
 static inline struct lu_object *osc2lu(struct osc_object *osc)
diff --git a/fs/lustre/ldlm/ldlm_lib.c b/fs/lustre/ldlm/ldlm_lib.c
index e4262c360950..ddedaadacf31 100644
--- a/fs/lustre/ldlm/ldlm_lib.c
+++ b/fs/lustre/ldlm/ldlm_lib.c
@@ -449,6 +449,7 @@ int client_obd_setup(struct obd_device *obd, struct lustre_cfg *lcfg)
 	cli->cl_mod_rpcs_in_flight = 0;
 	cli->cl_close_rpcs_in_flight = 0;
 	init_waitqueue_head(&cli->cl_mod_rpcs_waitq);
+	cli->cl_mod_rpcs_init = ktime_get_real();
 	cli->cl_mod_tag_bitmap = NULL;
 
 	INIT_LIST_HEAD(&cli->cl_chg_dev_linkage);
diff --git a/fs/lustre/llite/lproc_llite.c b/fs/lustre/llite/lproc_llite.c
index ef7ca4c67681..7157886c31cc 100644
--- a/fs/lustre/llite/lproc_llite.c
+++ b/fs/lustre/llite/lproc_llite.c
@@ -2020,8 +2020,8 @@ static int ll_rw_extents_stats_pp_seq_show(struct seq_file *seq, void *v)
 	}
 
 	spin_lock(&sbi->ll_pp_extent_lock);
-	lprocfs_stats_header(seq, ktime_get(), rw_extents->pp_init, 25, ":",
-			     true, "");
+	lprocfs_stats_header(seq, ktime_get_real(), rw_extents->pp_init, 25,
+			     ":", true, "");
 	seq_printf(seq, "%15s %19s       | %20s\n", " ", "read", "write");
 	seq_printf(seq, "%13s   %14s %4s %4s  | %14s %4s %4s\n",
 		   "extents", "calls", "%", "cum%", "calls", "%", "cum%");
@@ -2052,6 +2052,7 @@ static int alloc_rw_stats_info(struct ll_sb_info *sbi)
 		spin_lock_init(&rw_extents->pp_extents[i].pp_r_hist.oh_lock);
 		spin_lock_init(&rw_extents->pp_extents[i].pp_w_hist.oh_lock);
 	}
+	rw_extents->pp_init = ktime_get_real();
 
 	spin_lock(&sbi->ll_pp_extent_lock);
 	if (!sbi->ll_rw_extents_info)
@@ -2080,6 +2081,7 @@ static int alloc_rw_stats_info(struct ll_sb_info *sbi)
 	if (!sbi->ll_rw_offset_info)
 		sbi->ll_rw_offset_info = offset;
 	spin_unlock(&sbi->ll_process_lock);
+	sbi->ll_process_stats_init = ktime_get_real();
 
 	/* another writer allocated the structs before we got the lock */
 	if (sbi->ll_rw_offset_info != offset)
@@ -2133,7 +2135,7 @@ static ssize_t ll_rw_extents_stats_pp_seq_write(struct file *file,
 	spin_lock(&sbi->ll_pp_extent_lock);
 	rw_extents = sbi->ll_rw_extents_info;
 	if (rw_extents) {
-		rw_extents->pp_init = ktime_get();
+		rw_extents->pp_init = ktime_get_real();
 		for (i = 0; i < LL_PROCESS_HIST_MAX; i++) {
 			rw_extents->pp_extents[i].pid = 0;
 			lprocfs_oh_clear(&rw_extents->pp_extents[i].pp_r_hist);
@@ -2158,8 +2160,8 @@ static int ll_rw_extents_stats_seq_show(struct seq_file *seq, void *v)
 	}
 
 	spin_lock(&sbi->ll_lock);
-	lprocfs_stats_header(seq, ktime_get(), rw_extents->pp_init, 25, ":",
-			     true, "");
+	lprocfs_stats_header(seq, ktime_get_real(), rw_extents->pp_init, 25,
+			     ":", true, "");
 
 	seq_printf(seq, "%15s %19s       | %20s\n", " ", "read", "write");
 	seq_printf(seq, "%13s   %14s %4s %4s  | %14s %4s %4s\n",
@@ -2202,7 +2204,7 @@ static ssize_t ll_rw_extents_stats_seq_write(struct file *file,
 	spin_lock(&sbi->ll_pp_extent_lock);
 	rw_extents = sbi->ll_rw_extents_info;
 	if (rw_extents) {
-		rw_extents->pp_init = ktime_get();
+		rw_extents->pp_init = ktime_get_real();
 		for (i = 0; i <= LL_PROCESS_HIST_MAX; i++) {
 			rw_extents->pp_extents[i].pid = 0;
 			lprocfs_oh_clear(&rw_extents->pp_extents[i].pp_r_hist);
@@ -2342,8 +2344,8 @@ static int ll_rw_offset_stats_seq_show(struct seq_file *seq, void *v)
 		return 0;
 	}
 	spin_lock(&sbi->ll_process_lock);
-	lprocfs_stats_header(seq, ktime_get(), sbi->ll_process_stats_init, 25,
-			     ":", true, "");
+	lprocfs_stats_header(seq, ktime_get_real(), sbi->ll_process_stats_init,
+			     25, ":", true, "");
 	seq_printf(seq, "%3s %10s %14s %14s %17s %17s %14s\n",
 		   "R/W", "PID", "RANGE START", "RANGE END",
 		   "SMALLEST EXTENT", "LARGEST EXTENT", "OFFSET");
@@ -2410,7 +2412,7 @@ static ssize_t ll_rw_offset_stats_seq_write(struct file *file,
 	spin_lock(&sbi->ll_process_lock);
 	sbi->ll_offset_process_count = 0;
 	sbi->ll_rw_offset_entry_count = 0;
-	sbi->ll_process_stats_init = ktime_get();
+	sbi->ll_process_stats_init = ktime_get_real();
 	if (sbi->ll_rw_process_info)
 		memset(sbi->ll_rw_process_info, 0,
 		       sizeof(struct ll_rw_process_info) * LL_PROCESS_HIST_MAX);
diff --git a/fs/lustre/mdc/lproc_mdc.c b/fs/lustre/mdc/lproc_mdc.c
index 81397a388681..b59bba3595e3 100644
--- a/fs/lustre/mdc/lproc_mdc.c
+++ b/fs/lustre/mdc/lproc_mdc.c
@@ -410,6 +410,7 @@ static ssize_t mdc_rpc_stats_seq_write(struct file *file,
 	lprocfs_oh_clear(&cli->cl_write_page_hist);
 	lprocfs_oh_clear(&cli->cl_read_offset_hist);
 	lprocfs_oh_clear(&cli->cl_write_offset_hist);
+	cli->cl_mod_rpcs_init = ktime_get_real();
 
 	return len;
 }
@@ -511,10 +512,10 @@ LDEBUGFS_SEQ_FOPS(mdc_rpc_stats);
 static int mdc_stats_seq_show(struct seq_file *seq, void *v)
 {
 	struct obd_device *obd = seq->private;
-	struct osc_stats *stats = &obd2osc_dev(obd)->od_stats;
+	struct osc_stats *stats = &obd2osc_dev(obd)->osc_stats;
 
-	lprocfs_stats_header(seq, ktime_get(), stats->os_init, 25, ":", true,
-			     "");
+	lprocfs_stats_header(seq, ktime_get_real(), stats->os_init, 25, ":",
+			     true, "");
 	seq_printf(seq, "lockless_write_bytes\t\t%llu\n",
 		   stats->os_lockless_writes);
 	seq_printf(seq, "lockless_read_bytes\t\t%llu\n",
@@ -528,10 +529,10 @@ static ssize_t mdc_stats_seq_write(struct file *file,
 {
 	struct seq_file *seq = file->private_data;
 	struct obd_device *obd = seq->private;
-	struct osc_stats *stats = &obd2osc_dev(obd)->od_stats;
+	struct osc_stats *stats = &obd2osc_dev(obd)->osc_stats;
 
 	memset(stats, 0, sizeof(*stats));
-	stats->os_init = ktime_get();
+	stats->os_init = ktime_get_real();
 
 	return len;
 }
diff --git a/fs/lustre/mdc/mdc_dev.c b/fs/lustre/mdc/mdc_dev.c
index e0f5b457b0fb..984d1a8cc697 100644
--- a/fs/lustre/mdc/mdc_dev.c
+++ b/fs/lustre/mdc/mdc_dev.c
@@ -1554,16 +1554,16 @@ static struct lu_device *mdc_device_alloc(const struct lu_env *env,
 					  struct lustre_cfg *cfg)
 {
 	struct lu_device *d;
-	struct osc_device *od;
+	struct osc_device *oc;
 	struct obd_device *obd;
 	int rc;
 
-	od = kzalloc(sizeof(*od), GFP_NOFS);
-	if (!od)
+	oc = kzalloc(sizeof(*oc), GFP_NOFS);
+	if (!oc)
 		return ERR_PTR(-ENOMEM);
 
-	cl_device_init(&od->od_cl, t);
-	d = osc2lu_dev(od);
+	cl_device_init(&oc->osc_cl, t);
+	d = osc2lu_dev(oc);
 	d->ld_ops = &mdc_lu_ops;
 
 	/* Setup MDC OBD */
@@ -1576,7 +1576,8 @@ static struct lu_device *mdc_device_alloc(const struct lu_env *env,
 		osc_device_free(env, d);
 		return ERR_PTR(rc);
 	}
-	od->od_exp = obd->obd_self_export;
+	oc->osc_exp = obd->obd_self_export;
+	oc->osc_stats.os_init = ktime_get_real();
 	return d;
 }
 
diff --git a/fs/lustre/obdclass/genops.c b/fs/lustre/obdclass/genops.c
index a20b119f9c37..b6bde00ab389 100644
--- a/fs/lustre/obdclass/genops.c
+++ b/fs/lustre/obdclass/genops.c
@@ -1447,7 +1447,7 @@ int obd_mod_rpc_stats_seq_show(struct client_obd *cli, struct seq_file *seq)
 	int i;
 
 	spin_lock_irq(&cli->cl_mod_rpcs_waitq.lock);
-	lprocfs_stats_header(seq, ktime_get(), cli->cl_mod_rpcs_init, 25,
+	lprocfs_stats_header(seq, ktime_get_real(), cli->cl_mod_rpcs_init, 25,
 			     ":", true, "");
 	seq_printf(seq, "modify_RPCs_in_flight:  %hu\n",
 		   cli->cl_mod_rpcs_in_flight);
diff --git a/fs/lustre/obdclass/lprocfs_status.c b/fs/lustre/obdclass/lprocfs_status.c
index edc576d5f957..5089e7cfd377 100644
--- a/fs/lustre/obdclass/lprocfs_status.c
+++ b/fs/lustre/obdclass/lprocfs_status.c
@@ -1229,6 +1229,7 @@ struct lprocfs_stats *lprocfs_alloc_stats(unsigned int num,
 
 	stats->ls_num = num;
 	stats->ls_flags = flags;
+	stats->ls_init = ktime_get_real();
 	spin_lock_init(&stats->ls_lock);
 
 	/* alloc num of counter headers */
@@ -1339,6 +1340,7 @@ void lprocfs_clear_stats(struct lprocfs_stats *stats)
 				percpu_cntr->lc_sum_irq	= 0;
 		}
 	}
+	stats->ls_init = ktime_get_real();
 
 	lprocfs_stats_unlock(stats, LPROCFS_GET_NUM_CPU, &flags);
 }
@@ -1419,8 +1421,8 @@ static int lprocfs_stats_seq_show(struct seq_file *p, void *v)
 	int idx = *(loff_t *)v;
 
 	if (idx == 0)
-		lprocfs_stats_header(p, ktime_get(), stats->ls_init, 25, "",
-				     true, "");
+		lprocfs_stats_header(p, ktime_get_real(), stats->ls_init, 25,
+				     "", true, "");
 
 	hdr = &stats->ls_cnt_header[idx];
 	lprocfs_stats_collect(stats, idx, &ctr);
diff --git a/fs/lustre/osc/lproc_osc.c b/fs/lustre/osc/lproc_osc.c
index c4b1e3e4e2cc..b458a867c31f 100644
--- a/fs/lustre/osc/lproc_osc.c
+++ b/fs/lustre/osc/lproc_osc.c
@@ -702,8 +702,8 @@ static int osc_rpc_stats_seq_show(struct seq_file *seq, void *v)
 
 	spin_lock(&cli->cl_loi_list_lock);
 
-	lprocfs_stats_header(seq, ktime_get(), cli->cl_stats_init, 25, ":",
-			     true, "");
+	lprocfs_stats_header(seq, ktime_get_real(), cli->cl_stats_init, 25,
+			     ":", true, "");
 	seq_printf(seq, "read RPCs in flight:  %d\n",
 		   cli->cl_r_in_flight);
 	seq_printf(seq, "write RPCs in flight: %d\n",
@@ -803,7 +803,7 @@ static ssize_t osc_rpc_stats_seq_write(struct file *file,
 	lprocfs_oh_clear(&cli->cl_write_page_hist);
 	lprocfs_oh_clear(&cli->cl_read_offset_hist);
 	lprocfs_oh_clear(&cli->cl_write_offset_hist);
-	cli->cl_stats_init = ktime_get();
+	cli->cl_stats_init = ktime_get_real();
 
 	return len;
 }
@@ -813,10 +813,10 @@ LDEBUGFS_SEQ_FOPS(osc_rpc_stats);
 static int osc_stats_seq_show(struct seq_file *seq, void *v)
 {
 	struct obd_device *obd = seq->private;
-	struct osc_stats *stats = &obd2osc_dev(obd)->od_stats;
+	struct osc_stats *stats = &obd2osc_dev(obd)->osc_stats;
 
-	lprocfs_stats_header(seq, ktime_get(), stats->os_init, 25, ":", true,
-			     "");
+	lprocfs_stats_header(seq, ktime_get_real(), stats->os_init, 25, ":",
+			     true, "");
 	seq_printf(seq, "lockless_write_bytes\t\t%llu\n",
 		   stats->os_lockless_writes);
 	seq_printf(seq, "lockless_read_bytes\t\t%llu\n",
@@ -830,10 +830,10 @@ static ssize_t osc_stats_seq_write(struct file *file,
 {
 	struct seq_file *seq = file->private_data;
 	struct obd_device *obd = seq->private;
-	struct osc_stats *stats = &obd2osc_dev(obd)->od_stats;
+	struct osc_stats *stats = &obd2osc_dev(obd)->osc_stats;
 
 	memset(stats, 0, sizeof(*stats));
-	stats->os_init = ktime_get();
+	stats->os_init = ktime_get_real();
 
 	return len;
 }
diff --git a/fs/lustre/osc/osc_cache.c b/fs/lustre/osc/osc_cache.c
index b5776a127643..a9dc985bfa18 100644
--- a/fs/lustre/osc/osc_cache.c
+++ b/fs/lustre/osc/osc_cache.c
@@ -1365,7 +1365,7 @@ static int osc_completion(const struct lu_env *env, struct osc_async_page *oap,
 	/* statistic */
 	if (rc == 0 && srvlock) {
 		struct lu_device *ld = osc_page_object(opg)->oo_cl.co_lu.lo_dev;
-		struct osc_stats *stats = &lu2osc_dev(ld)->od_stats;
+		struct osc_stats *stats = &lu2osc_dev(ld)->osc_stats;
 		size_t bytes = oap->oap_count;
 
 		if (crt == CRT_READ)
diff --git a/fs/lustre/osc/osc_dev.c b/fs/lustre/osc/osc_dev.c
index 621beb6b6351..c3f9caaf9607 100644
--- a/fs/lustre/osc/osc_dev.c
+++ b/fs/lustre/osc/osc_dev.c
@@ -190,10 +190,10 @@ EXPORT_SYMBOL(osc_device_fini);
 struct lu_device *osc_device_free(const struct lu_env *env,
 				  struct lu_device *d)
 {
-	struct osc_device *od = lu2osc_dev(d);
+	struct osc_device *oc = lu2osc_dev(d);
 
 	cl_device_fini(lu2cl_dev(d));
-	kfree(od);
+	kfree(oc);
 	return NULL;
 }
 EXPORT_SYMBOL(osc_device_free);
@@ -203,16 +203,16 @@ static struct lu_device *osc_device_alloc(const struct lu_env *env,
 					  struct lustre_cfg *cfg)
 {
 	struct lu_device *d;
-	struct osc_device *od;
+	struct osc_device *osc;
 	struct obd_device *obd;
 	int rc;
 
-	od = kzalloc(sizeof(*od), GFP_NOFS);
-	if (!od)
+	osc = kzalloc(sizeof(*osc), GFP_NOFS);
+	if (!osc)
 		return ERR_PTR(-ENOMEM);
 
-	cl_device_init(&od->od_cl, t);
-	d = osc2lu_dev(od);
+	cl_device_init(&osc->osc_cl, t);
+	d = osc2lu_dev(osc);
 	d->ld_ops = &osc_lu_ops;
 
 	/* Setup OSC OBD */
@@ -223,7 +223,8 @@ static struct lu_device *osc_device_alloc(const struct lu_env *env,
 		osc_device_free(env, d);
 		return ERR_PTR(rc);
 	}
-	od->od_exp = obd->obd_self_export;
+	osc->osc_exp = obd->obd_self_export;
+	osc->osc_stats.os_init = ktime_get_real();
 	return d;
 }
 
-- 
2.27.0

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
