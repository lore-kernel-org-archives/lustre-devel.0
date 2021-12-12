Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 3D98CC433F5
	for <lustre-devel@archiver.kernel.org>; Sun, 12 Dec 2021 15:09:15 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 84CCF21F524;
	Sun, 12 Dec 2021 07:08:26 -0800 (PST)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 9F3CD21F487
 for <lustre-devel@lists.lustre.org>; Sun, 12 Dec 2021 07:08:09 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id CB0E410084F7;
 Sun, 12 Dec 2021 10:08:04 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id C6299E07E6; Sun, 12 Dec 2021 10:08:04 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 12 Dec 2021 10:08:03 -0500
Message-Id: <1639321683-22909-13-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1639321683-22909-1-git-send-email-jsimmons@infradead.org>
References: <1639321683-22909-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 12/12] lustre: llite: avoid needless large
 stats alloc
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
Cc: Alexander Zarochentsev <alexander.zarochentsev@hpe.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Andreas Dilger <adilger@whamcloud.com>

Allocate the ll_rw_extents_info (5896 bytes), ll_rw_offset_info
(6400 bytes), and ll_rw_process_info (640 bytes) structs only
when these stats are enabled, which is very rarely.

WC-bug-id: https://jira.whamcloud.com/browse/LU-15217
Lustre-commit: 9490fd9bb84dc277b ("LU-13601 llite: avoid needless large stats alloc")
Signed-off-by: Andreas Dilger <adilger@whamcloud.com>
Signed-off-by: Alexander Zarochentsev <alexander.zarochentsev@hpe.com>
Reviewed-on: https://review.whamcloud.com/40901
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/llite_internal.h |   7 +-
 fs/lustre/llite/llite_lib.c      |  10 +-
 fs/lustre/llite/lproc_llite.c    | 238 ++++++++++++++++++++++++++++-----------
 3 files changed, 177 insertions(+), 78 deletions(-)

diff --git a/fs/lustre/llite/llite_internal.h b/fs/lustre/llite/llite_internal.h
index ce7431f..01672b8 100644
--- a/fs/lustre/llite/llite_internal.h
+++ b/fs/lustre/llite/llite_internal.h
@@ -701,12 +701,12 @@ struct ll_sb_info {
 	struct cl_device	*ll_cl;
 
 	/* Statistics */
-	struct ll_rw_extents_info ll_rw_extents_info;
+	struct ll_rw_extents_info *ll_rw_extents_info;
 	int			ll_extent_process_count;
 	unsigned int		ll_offset_process_count;
+	struct ll_rw_process_info *ll_rw_process_info;
+	struct ll_rw_process_info *ll_rw_offset_info;
 	ktime_t			ll_process_stats_init;
-	struct ll_rw_process_info ll_rw_process_info[LL_PROCESS_HIST_MAX];
-	struct ll_rw_process_info ll_rw_offset_info[LL_OFFSET_HIST_MAX];
 	unsigned int		ll_rw_offset_entry_count;
 	int			ll_stats_track_id;
 	enum stats_track_type	ll_stats_track_type;
@@ -997,6 +997,7 @@ int cl_get_grouplock(struct cl_object *obj, unsigned long gid, int nonblock,
 void ll_rw_stats_tally(struct ll_sb_info *sbi, pid_t pid,
 		       struct ll_file_data *file, loff_t pos,
 		       size_t count, int rw);
+void ll_free_rw_stats_info(struct ll_sb_info *sbi);
 
 enum {
 	LPROC_LL_READ_BYTES,
diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index 147e680..dddbe7a 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -85,7 +85,6 @@ static struct ll_sb_info *ll_init_sbi(void)
 	unsigned long lru_page_max;
 	struct sysinfo si;
 	int rc;
-	int i;
 
 	sbi = kzalloc(sizeof(*sbi), GFP_NOFS);
 	if (!sbi)
@@ -161,14 +160,6 @@ static struct ll_sb_info *ll_init_sbi(void)
 	set_bit(LL_SBI_LRU_RESIZE, sbi->ll_flags);
 	set_bit(LL_SBI_LAZYSTATFS, sbi->ll_flags);
 
-	for (i = 0; i <= LL_PROCESS_HIST_MAX; i++) {
-		struct per_process_info *pp_ext;
-
-		pp_ext = &sbi->ll_rw_extents_info.pp_extents[i];
-		spin_lock_init(&pp_ext->pp_r_hist.oh_lock);
-		spin_lock_init(&pp_ext->pp_w_hist.oh_lock);
-	}
-
 	/* metadata statahead is enabled by default */
 	sbi->ll_sa_running_max = LL_SA_RUNNING_DEF;
 	sbi->ll_sa_max = LL_SA_RPC_DEF;
@@ -241,6 +232,7 @@ static void ll_free_sbi(struct super_block *sb)
 		kvfree(items);
 		sbi->ll_foreign_symlink_upcall_items = NULL;
 	}
+	ll_free_rw_stats_info(sbi);
 	pcc_super_fini(&sbi->ll_pcc_super);
 	kfree(sbi);
 }
diff --git a/fs/lustre/llite/lproc_llite.c b/fs/lustre/llite/lproc_llite.c
index a7eb8e1..ce715b4 100644
--- a/fs/lustre/llite/lproc_llite.c
+++ b/fs/lustre/llite/lproc_llite.c
@@ -1924,15 +1924,16 @@ void ll_debugfs_unregister_super(struct super_block *sb)
 	lprocfs_free_stats(&sbi->ll_stats);
 }
 
-static void ll_display_extents_info(struct ll_rw_extents_info *io_extents,
+static void ll_display_extents_info(struct ll_rw_extents_info *rw_extents,
 				    struct seq_file *seq, int which)
 {
 	unsigned long read_tot = 0, write_tot = 0, read_cum, write_cum;
 	unsigned long start, end, r, w;
 	char *unitp = "KMGTPEZY";
 	int i, units = 10;
-	struct per_process_info *pp_info = &io_extents->pp_extents[which];
+	struct per_process_info *pp_info;
 
+	pp_info = &rw_extents->pp_extents[which];
 	read_cum = 0;
 	write_cum = 0;
 	start = 0;
@@ -1968,39 +1969,103 @@ static void ll_display_extents_info(struct ll_rw_extents_info *io_extents,
 static int ll_rw_extents_stats_pp_seq_show(struct seq_file *seq, void *v)
 {
 	struct ll_sb_info *sbi = seq->private;
-	struct ll_rw_extents_info *io_extents = &sbi->ll_rw_extents_info;
+	struct ll_rw_extents_info *rw_extents = sbi->ll_rw_extents_info;
 	int k;
 
-	if (!sbi->ll_rw_stats_on) {
-		seq_puts(seq, "disabled\n"
-			 "write anything in this file to activate, then '0' or 'disabled' to deactivate\n");
+	if (!sbi->ll_rw_stats_on || !rw_extents) {
+		seq_puts(seq, "disabled\n write anything in this file to activate, then '0' or 'disabled' to deactivate\n");
 		return 0;
 	}
-	lprocfs_stats_header(seq, ktime_get(), io_extents->pp_init, 25, ":", 1);
+
+	spin_lock(&sbi->ll_pp_extent_lock);
+	lprocfs_stats_header(seq, ktime_get(), rw_extents->pp_init, 25, ":", 1);
 	seq_printf(seq, "%15s %19s       | %20s\n", " ", "read", "write");
 	seq_printf(seq, "%13s   %14s %4s %4s  | %14s %4s %4s\n",
-		   "extents", "calls", "%", "cum%",
-		   "calls", "%", "cum%");
-	spin_lock(&sbi->ll_pp_extent_lock);
+		   "extents", "calls", "%", "cum%", "calls", "%", "cum%");
+
 	for (k = 0; k < LL_PROCESS_HIST_MAX; k++) {
-		if (io_extents->pp_extents[k].pid != 0) {
+		if (rw_extents->pp_extents[k].pid != 0) {
 			seq_printf(seq, "\nPID: %d\n",
-				   io_extents->pp_extents[k].pid);
-			ll_display_extents_info(io_extents, seq, k);
+				   rw_extents->pp_extents[k].pid);
+			ll_display_extents_info(rw_extents, seq, k);
 		}
 	}
 	spin_unlock(&sbi->ll_pp_extent_lock);
 	return 0;
 }
 
+static int alloc_rw_stats_info(struct ll_sb_info *sbi)
+{
+	struct ll_rw_extents_info *rw_extents;
+	struct ll_rw_process_info *offset;
+	struct ll_rw_process_info *process;
+	int i, rc = 0;
+
+	rw_extents = kzalloc(sizeof(*rw_extents), GFP_KERNEL);
+	if (!rw_extents)
+		return -ENOMEM;
+
+	for (i = 0; i <= LL_PROCESS_HIST_MAX; i++) {
+		spin_lock_init(&rw_extents->pp_extents[i].pp_r_hist.oh_lock);
+		spin_lock_init(&rw_extents->pp_extents[i].pp_w_hist.oh_lock);
+	}
+
+	spin_lock(&sbi->ll_pp_extent_lock);
+	if (!sbi->ll_rw_extents_info)
+		sbi->ll_rw_extents_info = rw_extents;
+	spin_unlock(&sbi->ll_pp_extent_lock);
+	/* another writer allocated the struct before we got the lock */
+	if (sbi->ll_rw_extents_info != rw_extents)
+		kfree(rw_extents);
+
+	process = kzalloc(sizeof(*process) * LL_PROCESS_HIST_MAX,
+			  GFP_KERNEL);
+	if (!process) {
+		rc = -ENOMEM;
+		goto out;
+	}
+	offset = kzalloc(sizeof(*offset) * LL_OFFSET_HIST_MAX,
+			 GFP_KERNEL);
+	if (!offset) {
+		rc = -ENOMEM;
+		goto out_free;
+	}
+
+	spin_lock(&sbi->ll_process_lock);
+	if (!sbi->ll_rw_process_info)
+		sbi->ll_rw_process_info = process;
+	if (!sbi->ll_rw_offset_info)
+		sbi->ll_rw_offset_info = offset;
+	spin_unlock(&sbi->ll_process_lock);
+
+	/* another writer allocated the structs before we got the lock */
+	if (sbi->ll_rw_offset_info != offset)
+		kfree(offset);
+	if (sbi->ll_rw_process_info != process) {
+out_free:
+		kfree(process);
+	}
+out:
+	return rc;
+}
+
+void ll_free_rw_stats_info(struct ll_sb_info *sbi)
+{
+	kfree(sbi->ll_rw_extents_info);
+	sbi->ll_rw_extents_info = NULL;
+	kfree(sbi->ll_rw_offset_info);
+	sbi->ll_rw_offset_info = NULL;
+	kfree(sbi->ll_rw_process_info);
+	sbi->ll_rw_process_info = NULL;
+}
+
 static ssize_t ll_rw_extents_stats_pp_seq_write(struct file *file,
 						const char __user *buf,
-						size_t len,
-						loff_t *off)
+						size_t len, loff_t *off)
 {
 	struct seq_file *seq = file->private_data;
 	struct ll_sb_info *sbi = seq->private;
-	struct ll_rw_extents_info *io_extents = &sbi->ll_rw_extents_info;
+	struct ll_rw_extents_info *rw_extents;
 	int i;
 	s64 value;
 
@@ -2009,19 +2074,31 @@ static ssize_t ll_rw_extents_stats_pp_seq_write(struct file *file,
 
 	value = ll_stats_pid_write(buf, len);
 
-	if (value == 0)
+	if (value == 0) {
 		sbi->ll_rw_stats_on = 0;
-	else
+	} else {
+		if (!sbi->ll_rw_extents_info) {
+			int rc = alloc_rw_stats_info(sbi);
+
+			if (rc)
+				return rc;
+		}
 		sbi->ll_rw_stats_on = 1;
+	}
+
 
 	spin_lock(&sbi->ll_pp_extent_lock);
-	io_extents->pp_init = ktime_get();
-	for (i = 0; i < LL_PROCESS_HIST_MAX; i++) {
-		io_extents->pp_extents[i].pid = 0;
-		lprocfs_oh_clear(&io_extents->pp_extents[i].pp_r_hist);
-		lprocfs_oh_clear(&io_extents->pp_extents[i].pp_w_hist);
+	rw_extents = sbi->ll_rw_extents_info;
+	if (rw_extents) {
+		rw_extents->pp_init = ktime_get();
+		for (i = 0; i < LL_PROCESS_HIST_MAX; i++) {
+			rw_extents->pp_extents[i].pid = 0;
+			lprocfs_oh_clear(&rw_extents->pp_extents[i].pp_r_hist);
+			lprocfs_oh_clear(&rw_extents->pp_extents[i].pp_w_hist);
+		}
 	}
 	spin_unlock(&sbi->ll_pp_extent_lock);
+
 	return len;
 }
 
@@ -2030,22 +2107,22 @@ static ssize_t ll_rw_extents_stats_pp_seq_write(struct file *file,
 static int ll_rw_extents_stats_seq_show(struct seq_file *seq, void *v)
 {
 	struct ll_sb_info *sbi = seq->private;
-	struct ll_rw_extents_info *io_extents = &sbi->ll_rw_extents_info;
+	struct ll_rw_extents_info *rw_extents = sbi->ll_rw_extents_info;
 
-	if (!sbi->ll_rw_stats_on) {
-		seq_puts(seq, "disabled\n"
-			 "write anything in this file to activate, then '0' or 'disabled' to deactivate\n");
+	if (!sbi->ll_rw_stats_on || !rw_extents) {
+		seq_puts(seq, "disabled\n write anything in this file to activate, then '0' or 'disabled' to deactivate\n");
 		return 0;
 	}
 
-	lprocfs_stats_header(seq, ktime_get(), io_extents->pp_init, 25, ":", 1);
+	spin_lock(&sbi->ll_lock);
+	lprocfs_stats_header(seq, ktime_get(), rw_extents->pp_init, 25, ":", 1);
 
 	seq_printf(seq, "%15s %19s       | %20s\n", " ", "read", "write");
 	seq_printf(seq, "%13s   %14s %4s %4s  | %14s %4s %4s\n",
 		   "extents", "calls", "%", "cum%",
 		   "calls", "%", "cum%");
-	spin_lock(&sbi->ll_lock);
-	ll_display_extents_info(io_extents, seq, LL_PROCESS_HIST_MAX);
+
+	ll_display_extents_info(rw_extents, seq, LL_PROCESS_HIST_MAX);
 	spin_unlock(&sbi->ll_lock);
 
 	return 0;
@@ -2057,7 +2134,7 @@ static ssize_t ll_rw_extents_stats_seq_write(struct file *file,
 {
 	struct seq_file *seq = file->private_data;
 	struct ll_sb_info *sbi = seq->private;
-	struct ll_rw_extents_info *io_extents = &sbi->ll_rw_extents_info;
+	struct ll_rw_extents_info *rw_extents;
 	int i;
 	s64 value;
 
@@ -2066,17 +2143,27 @@ static ssize_t ll_rw_extents_stats_seq_write(struct file *file,
 
 	value = ll_stats_pid_write(buf, len);
 
-	if (value == 0)
+	if (value == 0) {
 		sbi->ll_rw_stats_on = 0;
-	else
+	} else {
+		if (!sbi->ll_rw_extents_info) {
+			int rc = alloc_rw_stats_info(sbi);
+
+			if (rc)
+				return rc;
+		}
 		sbi->ll_rw_stats_on = 1;
+	}
 
 	spin_lock(&sbi->ll_pp_extent_lock);
-	io_extents->pp_init = ktime_get();
-	for (i = 0; i <= LL_PROCESS_HIST_MAX; i++) {
-		io_extents->pp_extents[i].pid = 0;
-		lprocfs_oh_clear(&io_extents->pp_extents[i].pp_r_hist);
-		lprocfs_oh_clear(&io_extents->pp_extents[i].pp_w_hist);
+	rw_extents = sbi->ll_rw_extents_info;
+	if (rw_extents) {
+		rw_extents->pp_init = ktime_get();
+		for (i = 0; i <= LL_PROCESS_HIST_MAX; i++) {
+			rw_extents->pp_extents[i].pid = 0;
+			lprocfs_oh_clear(&rw_extents->pp_extents[i].pp_r_hist);
+			lprocfs_oh_clear(&rw_extents->pp_extents[i].pp_w_hist);
+		}
 	}
 	spin_unlock(&sbi->ll_pp_extent_lock);
 
@@ -2094,17 +2181,21 @@ void ll_rw_stats_tally(struct ll_sb_info *sbi, pid_t pid,
 	struct ll_rw_process_info *offset;
 	int *off_count = &sbi->ll_rw_offset_entry_count;
 	int *process_count = &sbi->ll_offset_process_count;
-	struct ll_rw_extents_info *io_extents = &sbi->ll_rw_extents_info;
+	struct ll_rw_extents_info *rw_extents;
 
 	if (!sbi->ll_rw_stats_on)
 		return;
-	process = sbi->ll_rw_process_info;
-	offset = sbi->ll_rw_offset_info;
 
 	spin_lock(&sbi->ll_pp_extent_lock);
+	rw_extents = sbi->ll_rw_extents_info;
+	if (!rw_extents) {
+		spin_unlock(&sbi->ll_pp_extent_lock);
+		return;
+	}
+
 	/* Extent statistics */
 	for (i = 0; i < LL_PROCESS_HIST_MAX; i++) {
-		if (io_extents->pp_extents[i].pid == pid) {
+		if (rw_extents->pp_extents[i].pid == pid) {
 			cur = i;
 			break;
 		}
@@ -2115,24 +2206,29 @@ void ll_rw_stats_tally(struct ll_sb_info *sbi, pid_t pid,
 		sbi->ll_extent_process_count =
 			(sbi->ll_extent_process_count + 1) % LL_PROCESS_HIST_MAX;
 		cur = sbi->ll_extent_process_count;
-		io_extents->pp_extents[cur].pid = pid;
-		lprocfs_oh_clear(&io_extents->pp_extents[cur].pp_r_hist);
-		lprocfs_oh_clear(&io_extents->pp_extents[cur].pp_w_hist);
+		rw_extents->pp_extents[cur].pid = pid;
+		lprocfs_oh_clear(&rw_extents->pp_extents[cur].pp_r_hist);
+		lprocfs_oh_clear(&rw_extents->pp_extents[cur].pp_w_hist);
 	}
 
 	for (i = 0; (count >= 1 << (LL_HIST_START + i)) &&
 	     (i < (LL_HIST_MAX - 1)); i++)
 		;
 	if (rw == 0) {
-		io_extents->pp_extents[cur].pp_r_hist.oh_buckets[i]++;
-		io_extents->pp_extents[LL_PROCESS_HIST_MAX].pp_r_hist.oh_buckets[i]++;
+		rw_extents->pp_extents[cur].pp_r_hist.oh_buckets[i]++;
+		rw_extents->pp_extents[LL_PROCESS_HIST_MAX].pp_r_hist.oh_buckets[i]++;
 	} else {
-		io_extents->pp_extents[cur].pp_w_hist.oh_buckets[i]++;
-		io_extents->pp_extents[LL_PROCESS_HIST_MAX].pp_w_hist.oh_buckets[i]++;
+		rw_extents->pp_extents[cur].pp_w_hist.oh_buckets[i]++;
+		rw_extents->pp_extents[LL_PROCESS_HIST_MAX].pp_w_hist.oh_buckets[i]++;
 	}
 	spin_unlock(&sbi->ll_pp_extent_lock);
 
 	spin_lock(&sbi->ll_process_lock);
+	process = sbi->ll_rw_process_info;
+	offset = sbi->ll_rw_offset_info;
+	if (!process || !offset)
+		goto out_unlock;
+
 	/* Offset statistics */
 	for (i = 0; i < LL_PROCESS_HIST_MAX; i++) {
 		if (process[i].rw_pid == pid) {
@@ -2143,8 +2239,7 @@ void ll_rw_stats_tally(struct ll_sb_info *sbi, pid_t pid,
 				process[i].rw_largest_extent = count;
 				process[i].rw_offset = 0;
 				process[i].rw_last_file = file;
-				spin_unlock(&sbi->ll_process_lock);
-				return;
+				goto out_unlock;
 			}
 			if (process[i].rw_last_file_pos != pos) {
 				*off_count =
@@ -2173,8 +2268,7 @@ void ll_rw_stats_tally(struct ll_sb_info *sbi, pid_t pid,
 			if (process[i].rw_largest_extent < count)
 				process[i].rw_largest_extent = count;
 			process[i].rw_last_file_pos = pos + count;
-			spin_unlock(&sbi->ll_process_lock);
-			return;
+			goto out_unlock;
 		}
 	}
 	*process_count = (*process_count + 1) % LL_PROCESS_HIST_MAX;
@@ -2186,14 +2280,16 @@ void ll_rw_stats_tally(struct ll_sb_info *sbi, pid_t pid,
 	process[*process_count].rw_largest_extent = count;
 	process[*process_count].rw_offset = 0;
 	process[*process_count].rw_last_file = file;
+
+out_unlock:
 	spin_unlock(&sbi->ll_process_lock);
 }
 
 static int ll_rw_offset_stats_seq_show(struct seq_file *seq, void *v)
 {
 	struct ll_sb_info *sbi = seq->private;
-	struct ll_rw_process_info *offset = sbi->ll_rw_offset_info;
-	struct ll_rw_process_info *process = sbi->ll_rw_process_info;
+	struct ll_rw_process_info *offset;
+	struct ll_rw_process_info *process;
 	int i;
 
 	if (!sbi->ll_rw_stats_on) {
@@ -2204,12 +2300,13 @@ static int ll_rw_offset_stats_seq_show(struct seq_file *seq, void *v)
 	spin_lock(&sbi->ll_process_lock);
 	lprocfs_stats_header(seq, ktime_get(), sbi->ll_process_stats_init, 25,
 			     ":", true);
-
 	seq_printf(seq, "%3s %10s %14s %14s %17s %17s %14s\n",
 		   "R/W", "PID", "RANGE START", "RANGE END",
 		   "SMALLEST EXTENT", "LARGEST EXTENT", "OFFSET");
+
 	/* We stored the discontiguous offsets here; print them first */
-	for (i = 0; i < LL_OFFSET_HIST_MAX; i++) {
+	offset = sbi->ll_rw_offset_info;
+	for (i = 0; offset && i < LL_OFFSET_HIST_MAX; i++) {
 		if (offset[i].rw_pid != 0)
 			seq_printf(seq,
 				   "%3c %10d %14llu %14llu %17lu %17lu %14lld\n",
@@ -2221,8 +2318,10 @@ static int ll_rw_offset_stats_seq_show(struct seq_file *seq, void *v)
 				   (unsigned long)offset[i].rw_largest_extent,
 				   offset[i].rw_offset);
 	}
+
 	/* Then print the current offsets for each process */
-	for (i = 0; i < LL_PROCESS_HIST_MAX; i++) {
+	process = sbi->ll_rw_process_info;
+	for (i = 0; process && i < LL_PROCESS_HIST_MAX; i++) {
 		if (process[i].rw_pid != 0)
 			seq_printf(seq,
 				   "%3c %10d %14llu %14llu %17lu %17lu %14lld\n",
@@ -2245,8 +2344,6 @@ static ssize_t ll_rw_offset_stats_seq_write(struct file *file,
 {
 	struct seq_file *seq = file->private_data;
 	struct ll_sb_info *sbi = seq->private;
-	struct ll_rw_process_info *process_info = sbi->ll_rw_process_info;
-	struct ll_rw_process_info *offset_info = sbi->ll_rw_offset_info;
 	s64 value;
 
 	if (len == 0)
@@ -2254,19 +2351,28 @@ static ssize_t ll_rw_offset_stats_seq_write(struct file *file,
 
 	value = ll_stats_pid_write(buf, len);
 
-	if (value == 0)
+	if (value == 0) {
 		sbi->ll_rw_stats_on = 0;
-	else
+	} else {
+		if (!sbi->ll_rw_process_info || !sbi->ll_rw_offset_info) {
+			int rc = alloc_rw_stats_info(sbi);
+
+			if (rc)
+				return rc;
+		}
 		sbi->ll_rw_stats_on = 1;
+	}
 
 	spin_lock(&sbi->ll_process_lock);
 	sbi->ll_offset_process_count = 0;
 	sbi->ll_rw_offset_entry_count = 0;
 	sbi->ll_process_stats_init = ktime_get();
-	memset(process_info, 0, sizeof(struct ll_rw_process_info) *
-	       LL_PROCESS_HIST_MAX);
-	memset(offset_info, 0, sizeof(struct ll_rw_process_info) *
-	       LL_OFFSET_HIST_MAX);
+	if (sbi->ll_rw_process_info)
+		memset(sbi->ll_rw_process_info, 0,
+		       sizeof(struct ll_rw_process_info) * LL_PROCESS_HIST_MAX);
+	if (sbi->ll_rw_offset_info)
+		memset(sbi->ll_rw_offset_info, 0,
+		       sizeof(struct ll_rw_process_info) * LL_OFFSET_HIST_MAX);
 	spin_unlock(&sbi->ll_process_lock);
 
 	return len;
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
