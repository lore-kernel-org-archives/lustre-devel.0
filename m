Return-Path: <SRS0=NZgA=GY=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 819CAC433E0
	for <lustre-devel@archiver.kernel.org>; Thu, 21 Jan 2021 17:18:10 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 3964D23A5A
	for <lustre-devel@archiver.kernel.org>; Thu, 21 Jan 2021 17:18:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3964D23A5A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 2844721FDDD;
	Thu, 21 Jan 2021 09:17:45 -0800 (PST)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id C704521FBB4
 for <lustre-devel@lists.lustre.org>; Thu, 21 Jan 2021 09:17:10 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 4FDDB1008061;
 Thu, 21 Jan 2021 12:17:05 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 4E6571B49C; Thu, 21 Jan 2021 12:17:05 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Thu, 21 Jan 2021 12:16:40 -0500
Message-Id: <1611249422-556-18-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1611249422-556-1-git-send-email-jsimmons@infradead.org>
References: <1611249422-556-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 17/39] lustre: llite: try to improve mmap
 performance
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
Cc: Wang Shilong <wshilong@ddn.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Wang Shilong <wshilong@ddn.com>

We have observed slow mmap read performances for some
applications. The problem is if access pattern is neither
sequential nor stride, but could be still adjacent in a
small range and then seek a random position.

So the pattern could be something like this:

[1M data] [hole] [0.5M data] [hole] [0.7M data] [1M data]

Every time an application reads mmap data, it may not only
read a single 4KB page, but aslo a cluster of nearby pages in
a range(e.g. 1MB) of the first page after a cache miss.

The readahead engine is modified to track the range size of
a cluster of mmap reads, so that after a seek and/or cache miss,
the range size is used to efficiently prefetch multiple pages
in a single RPC rather than many small RPCs.

Benchmark:
fio --name=randread --directory=/ai400/fio --rw=randread
--ioengine=mmap --bs=128K --numjobs=32 --filesize=200G
--filename=randread --time_based --status-interval=10s
--runtime=30s --allow_file_create=1 --group_reporting
--disable_lat=1 --disable_clat=1 --disable_slat=1
--disk_util=0 --aux-path=/tmp --randrepeat=0
--unique_filename=0 --fallocate=0

               |   master  |   patched  |  speedup  |
---------------+-----------+------------+-----------+
page_fault_avg |   512usec |    52usec  |  9.75x
page_fault_max |  37698usec|    6543usec|  5.76x

WC-bug-id: https://jira.whamcloud.com/browse/LU-13669
Lustre-commit: 0c5ad4b6df5bf3 ("LU-13669 llite: try to improve mmap performance")
Signed-off-by: Wang Shilong <wshilong@ddn.com>
Reviewed-on: https://review.whamcloud.com/38916
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Yingjin Qian <qian@ddn.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/llite_internal.h |  18 +++++
 fs/lustre/llite/llite_lib.c      |   1 +
 fs/lustre/llite/lproc_llite.c    |  47 +++++++++++++
 fs/lustre/llite/rw.c             | 142 +++++++++++++++++++++++++++++++++++----
 4 files changed, 196 insertions(+), 12 deletions(-)

diff --git a/fs/lustre/llite/llite_internal.h b/fs/lustre/llite/llite_internal.h
index bad974f..797dfea 100644
--- a/fs/lustre/llite/llite_internal.h
+++ b/fs/lustre/llite/llite_internal.h
@@ -482,6 +482,12 @@ static inline struct pcc_inode *ll_i2pcci(struct inode *inode)
 /* default read-ahead full files smaller than limit on the second read */
 #define SBI_DEFAULT_READ_AHEAD_WHOLE_MAX	MiB_TO_PAGES(2UL)
 
+/* default range pages */
+#define SBI_DEFAULT_RA_RANGE_PAGES		MiB_TO_PAGES(1ULL)
+
+/* Min range pages */
+#define RA_MIN_MMAP_RANGE_PAGES			16UL
+
 enum ra_stat {
 	RA_STAT_HIT = 0,
 	RA_STAT_MISS,
@@ -498,6 +504,7 @@ enum ra_stat {
 	RA_STAT_FAILED_REACH_END,
 	RA_STAT_ASYNC,
 	RA_STAT_FAILED_FAST_READ,
+	RA_STAT_MMAP_RANGE_READ,
 	_NR_RA_STAT,
 };
 
@@ -505,6 +512,7 @@ struct ll_ra_info {
 	atomic_t	      ra_cur_pages;
 	unsigned long	     ra_max_pages;
 	unsigned long	     ra_max_pages_per_file;
+	unsigned long		ra_range_pages;
 	unsigned long	     ra_max_read_ahead_whole_pages;
 	struct workqueue_struct  *ll_readahead_wq;
 	/*
@@ -790,6 +798,16 @@ struct ll_readahead_state {
 	 */
 	pgoff_t		ras_window_start_idx;
 	pgoff_t		ras_window_pages;
+
+	/* Page index where min range read starts */
+	pgoff_t		ras_range_min_start_idx;
+	/* Page index where mmap range read ends */
+	pgoff_t		ras_range_max_end_idx;
+	/* number of mmap pages where last time detected */
+	pgoff_t		ras_last_range_pages;
+	/* number of mmap range requests */
+	pgoff_t		ras_range_requests;
+
 	/*
 	 * Optimal RPC size in pages.
 	 * It decides how many pages will be sent for each read-ahead.
diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index 34bd661..c560492 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -130,6 +130,7 @@ static struct ll_sb_info *ll_init_sbi(void)
 		    SBI_DEFAULT_READ_AHEAD_PER_FILE_MAX);
 	sbi->ll_ra_info.ra_async_pages_per_file_threshold =
 				sbi->ll_ra_info.ra_max_pages_per_file;
+	sbi->ll_ra_info.ra_range_pages = SBI_DEFAULT_RA_RANGE_PAGES;
 	sbi->ll_ra_info.ra_max_read_ahead_whole_pages = -1;
 	atomic_set(&sbi->ll_ra_info.ra_async_inflight, 0);
 
diff --git a/fs/lustre/llite/lproc_llite.c b/fs/lustre/llite/lproc_llite.c
index 9b1c392..5d1e2f4 100644
--- a/fs/lustre/llite/lproc_llite.c
+++ b/fs/lustre/llite/lproc_llite.c
@@ -1173,6 +1173,51 @@ static ssize_t read_ahead_async_file_threshold_mb_show(struct kobject *kobj,
 }
 LUSTRE_RW_ATTR(read_ahead_async_file_threshold_mb);
 
+static ssize_t read_ahead_range_kb_show(struct kobject *kobj,
+					struct attribute *attr, char *buf)
+{
+	struct ll_sb_info *sbi = container_of(kobj, struct ll_sb_info,
+					      ll_kset.kobj);
+
+	return scnprintf(buf, PAGE_SIZE, "%lu\n",
+			 sbi->ll_ra_info.ra_range_pages << (PAGE_SHIFT - 10));
+}
+
+static ssize_t
+read_ahead_range_kb_store(struct kobject *kobj,
+			  struct attribute *attr,
+			  const char *buffer, size_t count)
+{
+	struct ll_sb_info *sbi = container_of(kobj, struct ll_sb_info,
+					      ll_kset.kobj);
+	unsigned long pages_number;
+	unsigned long max_ra_per_file;
+	u64 val;
+	int rc;
+
+	rc = sysfs_memparse(buffer, count, &val, "KiB");
+	if (rc < 0)
+		return rc;
+
+	pages_number = val >> PAGE_SHIFT;
+	/* Disable mmap range read */
+	if (pages_number == 0)
+		goto out;
+
+	max_ra_per_file = sbi->ll_ra_info.ra_max_pages_per_file;
+	if (pages_number > max_ra_per_file ||
+	    pages_number < RA_MIN_MMAP_RANGE_PAGES)
+		return -ERANGE;
+
+out:
+	spin_lock(&sbi->ll_lock);
+	sbi->ll_ra_info.ra_range_pages = pages_number;
+	spin_unlock(&sbi->ll_lock);
+
+	return count;
+}
+LUSTRE_RW_ATTR(read_ahead_range_kb);
+
 static ssize_t fast_read_show(struct kobject *kobj,
 			      struct attribute *attr,
 			      char *buf)
@@ -1506,6 +1551,7 @@ struct ldebugfs_vars lprocfs_llite_obd_vars[] = {
 	&lustre_attr_max_read_ahead_mb.attr,
 	&lustre_attr_max_read_ahead_per_file_mb.attr,
 	&lustre_attr_max_read_ahead_whole_mb.attr,
+	&lustre_attr_read_ahead_range_kb.attr,
 	&lustre_attr_checksums.attr,
 	&lustre_attr_checksum_pages.attr,
 	&lustre_attr_stats_track_pid.attr,
@@ -1622,6 +1668,7 @@ void ll_stats_ops_tally(struct ll_sb_info *sbi, int op, long count)
 	[RA_STAT_FAILED_REACH_END]	= "failed to reach end",
 	[RA_STAT_ASYNC]			= "async readahead",
 	[RA_STAT_FAILED_FAST_READ]	= "failed to fast read",
+	[RA_STAT_MMAP_RANGE_READ]	= "mmap range read",
 };
 
 int ll_debugfs_register_super(struct super_block *sb, const char *name)
diff --git a/fs/lustre/llite/rw.c b/fs/lustre/llite/rw.c
index da4a26d..096e015 100644
--- a/fs/lustre/llite/rw.c
+++ b/fs/lustre/llite/rw.c
@@ -388,7 +388,7 @@ static bool ras_inside_ra_window(pgoff_t idx, struct ra_io_arg *ria)
 static unsigned long
 ll_read_ahead_pages(const struct lu_env *env, struct cl_io *io,
 		    struct cl_page_list *queue, struct ll_readahead_state *ras,
-		    struct ra_io_arg *ria, pgoff_t *ra_end)
+		    struct ra_io_arg *ria, pgoff_t *ra_end, pgoff_t skip_index)
 {
 	struct cl_read_ahead ra = { 0 };
 	pgoff_t page_idx;
@@ -402,6 +402,8 @@ static bool ras_inside_ra_window(pgoff_t idx, struct ra_io_arg *ria)
 	for (page_idx = ria->ria_start_idx;
 	     page_idx <= ria->ria_end_idx && ria->ria_reserved > 0;
 	     page_idx++) {
+		if (skip_index && page_idx == skip_index)
+			continue;
 		if (ras_inside_ra_window(page_idx, ria)) {
 			if (!ra.cra_end_idx || ra.cra_end_idx < page_idx) {
 				pgoff_t end_idx;
@@ -447,10 +449,12 @@ static bool ras_inside_ra_window(pgoff_t idx, struct ra_io_arg *ria)
 				if (ras->ras_rpc_pages != ra.cra_rpc_pages &&
 				    ra.cra_rpc_pages > 0)
 					ras->ras_rpc_pages = ra.cra_rpc_pages;
-				/* trim it to align with optimal RPC size */
-				end_idx = ras_align(ras, ria->ria_end_idx + 1);
-				if (end_idx > 0 && !ria->ria_eof)
-					ria->ria_end_idx = end_idx - 1;
+				if (!skip_index) {
+					/* trim it to align with optimal RPC size */
+					end_idx = ras_align(ras, ria->ria_end_idx + 1);
+					if (end_idx > 0 && !ria->ria_eof)
+						ria->ria_end_idx = end_idx - 1;
+				}
 				if (ria->ria_end_idx < ria->ria_end_idx_min)
 					ria->ria_end_idx = ria->ria_end_idx_min;
 			}
@@ -650,7 +654,7 @@ static void ll_readahead_handle_work(struct work_struct *wq)
 	cl_2queue_init(queue);
 
 	rc = ll_read_ahead_pages(env, io, &queue->c2_qin, ras, ria,
-				 &ra_end_idx);
+				 &ra_end_idx, 0);
 	if (ria->ria_reserved != 0)
 		ll_ra_count_put(ll_i2sbi(inode), ria->ria_reserved);
 	if (queue->c2_qin.pl_nr > 0) {
@@ -688,7 +692,7 @@ static void ll_readahead_handle_work(struct work_struct *wq)
 static int ll_readahead(const struct lu_env *env, struct cl_io *io,
 			struct cl_page_list *queue,
 			struct ll_readahead_state *ras, bool hit,
-			struct file *file)
+			struct file *file, pgoff_t skip_index)
 {
 	struct vvp_io *vio = vvp_env_io(env);
 	struct ll_thread_info *lti = ll_env_info(env);
@@ -731,6 +735,9 @@ static int ll_readahead(const struct lu_env *env, struct cl_io *io,
 	if (ras->ras_window_pages > 0)
 		end_idx = ras->ras_window_start_idx + ras->ras_window_pages - 1;
 
+	if (skip_index)
+		end_idx = start_idx + ras->ras_window_pages - 1;
+
 	/* Enlarge the RA window to encompass the full read */
 	if (vio->vui_ra_valid &&
 	    end_idx < vio->vui_ra_start_idx + vio->vui_ra_pages - 1)
@@ -783,6 +790,10 @@ static int ll_readahead(const struct lu_env *env, struct cl_io *io,
 			    ria->ria_start_idx;
 	}
 
+	/* don't over reserved for mmap range read */
+	if (skip_index)
+		pages_min = 0;
+
 	ria->ria_reserved = ll_ra_count_get(ll_i2sbi(inode), ria, pages,
 					    pages_min);
 	if (ria->ria_reserved < pages)
@@ -793,8 +804,8 @@ static int ll_readahead(const struct lu_env *env, struct cl_io *io,
 	       atomic_read(&ll_i2sbi(inode)->ll_ra_info.ra_cur_pages),
 	       ll_i2sbi(inode)->ll_ra_info.ra_max_pages);
 
-	ret = ll_read_ahead_pages(env, io, queue, ras, ria, &ra_end_idx);
-
+	ret = ll_read_ahead_pages(env, io, queue, ras, ria, &ra_end_idx,
+				  skip_index);
 	if (ria->ria_reserved)
 		ll_ra_count_put(ll_i2sbi(inode), ria->ria_reserved);
 
@@ -890,6 +901,10 @@ void ll_readahead_init(struct inode *inode, struct ll_readahead_state *ras)
 	ras_reset(ras, 0);
 	ras->ras_last_read_end_bytes = 0;
 	ras->ras_requests = 0;
+	ras->ras_range_min_start_idx = 0;
+	ras->ras_range_max_end_idx = 0;
+	ras->ras_range_requests = 0;
+	ras->ras_last_range_pages = 0;
 }
 
 /*
@@ -1033,6 +1048,73 @@ static inline bool is_loose_seq_read(struct ll_readahead_state *ras, loff_t pos)
 			     8UL << PAGE_SHIFT, 8UL << PAGE_SHIFT);
 }
 
+static inline bool is_loose_mmap_read(struct ll_sb_info *sbi,
+				      struct ll_readahead_state *ras,
+				      unsigned long pos)
+{
+	unsigned long range_pages = sbi->ll_ra_info.ra_range_pages;
+
+	return pos_in_window(pos, ras->ras_last_read_end_bytes,
+			     range_pages << PAGE_SHIFT,
+			     range_pages << PAGE_SHIFT);
+}
+
+/**
+ * We have observed slow mmap read performances for some
+ * applications. The problem is if access pattern is neither
+ * sequential nor stride, but could be still adjacent in a
+ * small range and then seek a random position.
+ *
+ * So the pattern could be something like this:
+ *
+ * [1M data] [hole] [0.5M data] [hole] [0.7M data] [1M data]
+ *
+ *
+ * Every time an application reads mmap data, it may not only
+ * read a single 4KB page, but aslo a cluster of nearby pages in
+ * a range(e.g. 1MB) of the first page after a cache miss.
+ *
+ * The readahead engine is modified to track the range size of
+ * a cluster of mmap reads, so that after a seek and/or cache miss,
+ * the range size is used to efficiently prefetch multiple pages
+ * in a single RPC rather than many small RPCs.
+ */
+static void ras_detect_cluster_range(struct ll_readahead_state *ras,
+				     struct ll_sb_info *sbi,
+				     unsigned long pos, unsigned long count)
+{
+	pgoff_t last_pages, pages;
+	pgoff_t end_idx = (pos + count - 1) >> PAGE_SHIFT;
+
+	last_pages = ras->ras_range_max_end_idx -
+		     ras->ras_range_min_start_idx + 1;
+	/* First time come here */
+	if (!ras->ras_range_max_end_idx)
+		goto out;
+
+	/* Random or Stride read */
+	if (!is_loose_mmap_read(sbi, ras, pos))
+		goto out;
+
+	ras->ras_range_requests++;
+	if (ras->ras_range_max_end_idx < end_idx)
+		ras->ras_range_max_end_idx = end_idx;
+
+	if (ras->ras_range_min_start_idx > (pos >> PAGE_SHIFT))
+		ras->ras_range_min_start_idx = pos >> PAGE_SHIFT;
+
+	/* Out of range, consider it as random or stride */
+	pages = ras->ras_range_max_end_idx -
+		ras->ras_range_min_start_idx + 1;
+	if (pages <= sbi->ll_ra_info.ra_range_pages)
+		return;
+out:
+	ras->ras_last_range_pages = last_pages;
+	ras->ras_range_requests = 0;
+	ras->ras_range_min_start_idx = pos >> PAGE_SHIFT;
+	ras->ras_range_max_end_idx = end_idx;
+}
+
 static void ras_detect_read_pattern(struct ll_readahead_state *ras,
 				    struct ll_sb_info *sbi,
 				    loff_t pos, size_t count, bool mmap)
@@ -1080,9 +1162,13 @@ static void ras_detect_read_pattern(struct ll_readahead_state *ras,
 
 	ras->ras_consecutive_bytes += count;
 	if (mmap) {
+		unsigned long ra_range_pages =
+				max_t(unsigned long, RA_MIN_MMAP_RANGE_PAGES,
+				      sbi->ll_ra_info.ra_range_pages);
 		pgoff_t idx = ras->ras_consecutive_bytes >> PAGE_SHIFT;
 
-		if ((idx >= 4 && (idx & 3UL) == 0) || stride_detect)
+		if ((idx >= ra_range_pages &&
+		     idx % ra_range_pages == 0) || stride_detect)
 			ras->ras_need_increase_window = true;
 	} else if ((ras->ras_consecutive_requests > 1 || stride_detect)) {
 		ras->ras_need_increase_window = true;
@@ -1190,10 +1276,36 @@ static void ras_update(struct ll_sb_info *sbi, struct inode *inode,
 	if (ras->ras_no_miss_check)
 		goto out_unlock;
 
-	if (flags & LL_RAS_MMAP)
+	if (flags & LL_RAS_MMAP) {
+		unsigned long ra_pages;
+
+		ras_detect_cluster_range(ras, sbi, index << PAGE_SHIFT,
+					 PAGE_SIZE);
 		ras_detect_read_pattern(ras, sbi, (loff_t)index << PAGE_SHIFT,
 					PAGE_SIZE, true);
 
+		/* we did not detect anything but we could prefetch */
+		if (!ras->ras_need_increase_window &&
+		    ras->ras_window_pages <= sbi->ll_ra_info.ra_range_pages &&
+		    ras->ras_range_requests >= 2) {
+			if (!hit) {
+				ra_pages = max_t(unsigned long,
+						 RA_MIN_MMAP_RANGE_PAGES,
+						 ras->ras_last_range_pages);
+				if (index < ra_pages / 2)
+					index = 0;
+				else
+					index -= ra_pages / 2;
+				ras->ras_window_pages = ra_pages;
+				ll_ra_stats_inc_sbi(sbi,
+						    RA_STAT_MMAP_RANGE_READ);
+			} else {
+				ras->ras_window_pages = 0;
+			}
+			goto skip;
+		}
+	}
+
 	if (!hit && ras->ras_window_pages &&
 	    index < ras->ras_next_readahead_idx &&
 	    pos_in_window(index, ras->ras_window_start_idx, 0,
@@ -1231,6 +1343,8 @@ static void ras_update(struct ll_sb_info *sbi, struct inode *inode,
 			goto out_unlock;
 		}
 	}
+
+skip:
 	ras_set_start(ras, index);
 
 	if (stride_io_mode(ras)) {
@@ -1500,8 +1614,12 @@ int ll_io_read_page(const struct lu_env *env, struct cl_io *io,
 	io_end_index = cl_index(io->ci_obj, io->u.ci_rw.crw_pos +
 				io->u.ci_rw.crw_count - 1);
 	if (ll_readahead_enabled(sbi) && ras) {
+		pgoff_t skip_index = 0;
+
+		if (ras->ras_next_readahead_idx < vvp_index(vpg))
+			skip_index = vvp_index(vpg);
 		rc2 = ll_readahead(env, io, &queue->c2_qin, ras,
-				   uptodate, file);
+				   uptodate, file, skip_index);
 		CDEBUG(D_READA, DFID " %d pages read ahead at %lu\n",
 		       PFID(ll_inode2fid(inode)), rc2, vvp_index(vpg));
 	} else if (vvp_index(vpg) == io_start_index &&
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
