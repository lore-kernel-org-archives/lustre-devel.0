From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:13:59 -0500
Subject: [lustre-devel] [PATCH 371/622] lustre: llite: improve single-thread
 read performance
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-372-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Wang Shilong <wshilong@ddn.com>

Here is whole history:

Currently, for sequential read IO, We grow up window
size very quickly, and once we cached @max_readahead_per_file
pages. For following command:

  dd if=/mnt/lustre/file of=/dev/null bs=1M

We will do something like following:
...
64M bytes cached.
fast io for 16M bytes
readahead extra 16M to fill up window.
fast io for 16M bytes
readahead extra 16M to fill up window.
....

In this way, we could only use fast IO for 16M bytes and
then fall through non-fast IO mode. this is also reason
that why increasing @max_readahead_per_file don't give us
performances up, since this value only changes how much
memory we cached in memory, during my testing whatever
I changed the value, i could only get 2GB/s for single thread
read.

Actually, we could do this better, if we have used
more than 16M bytes readahead pages, submit another readahead
requests in the background. and ideally, we could always
use fast IO.

Test                                                    Patched         Unpatched
dd if=file of=/dev/null bs=1M.                          4.0G/s          1.9G/s
ior -np 192 r -t 1m -b 4g -F -e -vv -o /cache1/ior -k   11195.97        10817.02 MB/sec

Tested with drop OSS and client memory before every run.
max_readahead_per_mb=128M, RPC size is 16M.
dd file's size is 400G which is double of memory or so.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12043
Lustre-commit: c2791674260b ("LU-12043 llite: improve single-thread read performance")
Signed-off-by: Wang Shilong <wshilong@ddn.com>
Reviewed-on: https://review.whamcloud.com/34095
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Li Xi <lixi@ddn.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/cl_object.h    |   6 +-
 fs/lustre/llite/file.c           |   3 +-
 fs/lustre/llite/llite_internal.h |  27 ++++
 fs/lustre/llite/llite_lib.c      |  17 ++-
 fs/lustre/llite/lproc_llite.c    |  87 +++++++++++-
 fs/lustre/llite/rw.c             | 277 +++++++++++++++++++++++++++++++++++----
 fs/lustre/llite/vvp_io.c         |   5 +
 fs/lustre/lov/lov_io.c           |   1 +
 8 files changed, 391 insertions(+), 32 deletions(-)

diff --git a/fs/lustre/include/cl_object.h b/fs/lustre/include/cl_object.h
index d1c1413..5096025 100644
--- a/fs/lustre/include/cl_object.h
+++ b/fs/lustre/include/cl_object.h
@@ -1891,7 +1891,11 @@ struct cl_io {
 	 * mirror is inaccessible, non-delay RPC would error out quickly so
 	 * that the upper layer can try to access the next mirror.
 	 */
-				ci_ndelay:1;
+				ci_ndelay:1,
+	/**
+	 * Set if IO is triggered by async workqueue readahead.
+	 */
+				ci_async_readahead:1;
 	/**
 	 * How many times the read has retried before this one.
 	 * Set by the top level and consumed by the LOV.
diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index 9321b84..5d1cfa4 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -1407,7 +1407,7 @@ static bool file_is_noatime(const struct file *file)
 	return false;
 }
 
-static void ll_io_init(struct cl_io *io, const struct file *file, int write)
+void ll_io_init(struct cl_io *io, const struct file *file, int write)
 {
 	struct ll_file_data *fd = LUSTRE_FPRIVATE(file);
 	struct inode *inode = file_inode(file);
@@ -1431,6 +1431,7 @@ static void ll_io_init(struct cl_io *io, const struct file *file, int write)
 	}
 
 	io->ci_noatime = file_is_noatime(file);
+	io->ci_async_readahead = false;
 
 	/* FLR: only use non-delay I/O for read as there is only one
 	 * available mirror for write.
diff --git a/fs/lustre/llite/llite_internal.h b/fs/lustre/llite/llite_internal.h
index 36b620e..8d95694 100644
--- a/fs/lustre/llite/llite_internal.h
+++ b/fs/lustre/llite/llite_internal.h
@@ -330,6 +330,8 @@ enum ra_stat {
 	RA_STAT_MAX_IN_FLIGHT,
 	RA_STAT_WRONG_GRAB_PAGE,
 	RA_STAT_FAILED_REACH_END,
+	RA_STAT_ASYNC,
+	RA_STAT_FAILED_FAST_READ,
 	_NR_RA_STAT,
 };
 
@@ -338,6 +340,16 @@ struct ll_ra_info {
 	unsigned long	     ra_max_pages;
 	unsigned long	     ra_max_pages_per_file;
 	unsigned long	     ra_max_read_ahead_whole_pages;
+	struct workqueue_struct  *ll_readahead_wq;
+	/*
+	 * Max number of active works for readahead workqueue,
+	 * default is 0 which make workqueue init number itself,
+	 * unless there is a specific need for throttling the
+	 * number of active work items, specifying '0' is recommended.
+	 */
+	unsigned int ra_async_max_active;
+	/* Threshold to control when to trigger async readahead */
+	unsigned long ra_async_pages_per_file_threshold;
 };
 
 /* ra_io_arg will be filled in the beginning of ll_readahead with
@@ -656,6 +668,20 @@ struct ll_readahead_state {
 	 * stride read-ahead will be enable
 	 */
 	unsigned long   ras_consecutive_stride_requests;
+	/* index of the last page that async readahead starts */
+	unsigned long	ras_async_last_readpage;
+};
+
+struct ll_readahead_work {
+	/** File to readahead */
+	struct file			*lrw_file;
+	/** Start bytes */
+	unsigned long			 lrw_start;
+	/** End bytes */
+	unsigned long			 lrw_end;
+
+	/* async worker to handler read */
+	struct work_struct		 lrw_readahead_work;
 };
 
 extern struct kmem_cache *ll_file_data_slab;
@@ -757,6 +783,7 @@ int cl_get_grouplock(struct cl_object *obj, unsigned long gid, int nonblock,
 void ll_rw_stats_tally(struct ll_sb_info *sbi, pid_t pid,
 		       struct ll_file_data *file, loff_t pos,
 		       size_t count, int rw);
+void ll_io_init(struct cl_io *io, const struct file *file, int write);
 
 enum {
 	LPROC_LL_DIRTY_HITS,
diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index 5ac083c..33f7fdb 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -92,14 +92,25 @@ static struct ll_sb_info *ll_init_sbi(void)
 	pages = si.totalram - si.totalhigh;
 	lru_page_max = pages / 2;
 
+	sbi->ll_ra_info.ra_async_max_active = 0;
+	sbi->ll_ra_info.ll_readahead_wq =
+		alloc_workqueue("ll-readahead-wq", WQ_UNBOUND,
+				sbi->ll_ra_info.ra_async_max_active);
+	if (!sbi->ll_ra_info.ll_readahead_wq) {
+		rc = -ENOMEM;
+		goto out_pcc;
+	}
+
 	sbi->ll_cache = cl_cache_init(lru_page_max);
 	if (!sbi->ll_cache) {
 		rc = -ENOMEM;
-		goto out_pcc;
+		goto out_destroy_ra;
 	}
 
 	sbi->ll_ra_info.ra_max_pages_per_file = min(pages / 32,
 						    SBI_DEFAULT_READAHEAD_MAX);
+	sbi->ll_ra_info.ra_async_pages_per_file_threshold =
+				sbi->ll_ra_info.ra_max_pages_per_file;
 	sbi->ll_ra_info.ra_max_pages = sbi->ll_ra_info.ra_max_pages_per_file;
 	sbi->ll_ra_info.ra_max_read_ahead_whole_pages = -1;
 
@@ -138,6 +149,8 @@ static struct ll_sb_info *ll_init_sbi(void)
 	sbi->ll_heat_decay_weight = SBI_DEFAULT_HEAT_DECAY_WEIGHT;
 	sbi->ll_heat_period_second = SBI_DEFAULT_HEAT_PERIOD_SECOND;
 	return sbi;
+out_destroy_ra:
+	destroy_workqueue(sbi->ll_ra_info.ll_readahead_wq);
 out_pcc:
 	pcc_super_fini(&sbi->ll_pcc_super);
 out_sbi:
@@ -151,6 +164,8 @@ static void ll_free_sbi(struct super_block *sb)
 
 	if (!list_empty(&sbi->ll_squash.rsi_nosquash_nids))
 		cfs_free_nidlist(&sbi->ll_squash.rsi_nosquash_nids);
+	if (sbi->ll_ra_info.ll_readahead_wq)
+		destroy_workqueue(sbi->ll_ra_info.ll_readahead_wq);
 	if (sbi->ll_cache) {
 		cl_cache_decref(sbi->ll_cache);
 		sbi->ll_cache = NULL;
diff --git a/fs/lustre/llite/lproc_llite.c b/fs/lustre/llite/lproc_llite.c
index 8cb4983..02403e4 100644
--- a/fs/lustre/llite/lproc_llite.c
+++ b/fs/lustre/llite/lproc_llite.c
@@ -1059,6 +1059,87 @@ static ssize_t tiny_write_store(struct kobject *kobj,
 }
 LUSTRE_RW_ATTR(tiny_write);
 
+static ssize_t max_read_ahead_async_active_show(struct kobject *kobj,
+					       struct attribute *attr,
+					       char *buf)
+{
+	struct ll_sb_info *sbi = container_of(kobj, struct ll_sb_info,
+					      ll_kset.kobj);
+
+	return snprintf(buf, PAGE_SIZE, "%u\n",
+			sbi->ll_ra_info.ra_async_max_active);
+}
+
+static ssize_t max_read_ahead_async_active_store(struct kobject *kobj,
+						struct attribute *attr,
+						const char *buffer,
+						size_t count)
+{
+	unsigned int val;
+	int rc;
+	struct ll_sb_info *sbi = container_of(kobj, struct ll_sb_info,
+					      ll_kset.kobj);
+
+	rc = kstrtouint(buffer, 10, &val);
+	if (rc)
+		return rc;
+
+	if (val < 1 || val > WQ_UNBOUND_MAX_ACTIVE) {
+		CERROR("%s: cannot set max_read_ahead_async_active=%u %s than %u\n",
+		       sbi->ll_fsname, val,
+		       val < 1 ? "smaller" : "larger",
+		       val < 1 ? 1 : WQ_UNBOUND_MAX_ACTIVE);
+		return -ERANGE;
+	}
+
+	sbi->ll_ra_info.ra_async_max_active = val;
+	workqueue_set_max_active(sbi->ll_ra_info.ll_readahead_wq, val);
+
+	return count;
+}
+LUSTRE_RW_ATTR(max_read_ahead_async_active);
+
+static ssize_t read_ahead_async_file_threshold_mb_show(struct kobject *kobj,
+						       struct attribute *attr,
+						       char *buf)
+{
+	struct ll_sb_info *sbi = container_of(kobj, struct ll_sb_info,
+					      ll_kset.kobj);
+
+	return snprintf(buf, PAGE_SIZE, "%lu\n",
+	     PAGES_TO_MiB(sbi->ll_ra_info.ra_async_pages_per_file_threshold));
+}
+
+static ssize_t
+read_ahead_async_file_threshold_mb_store(struct kobject *kobj,
+					 struct attribute *attr,
+					 const char *buffer, size_t count)
+{
+	unsigned long pages_number;
+	unsigned long max_ra_per_file;
+	struct ll_sb_info *sbi = container_of(kobj, struct ll_sb_info,
+					      ll_kset.kobj);
+	int rc;
+
+	rc = kstrtoul(buffer, 10, &pages_number);
+	if (rc)
+		return rc;
+
+	pages_number = MiB_TO_PAGES(pages_number);
+	max_ra_per_file = sbi->ll_ra_info.ra_max_pages_per_file;
+	if (pages_number < 0 || pages_number > max_ra_per_file) {
+		CERROR("%s: can't set read_ahead_async_file_threshold_mb=%lu > max_read_readahead_per_file_mb=%lu\n",
+		       sbi->ll_fsname,
+		       PAGES_TO_MiB(pages_number),
+		       PAGES_TO_MiB(max_ra_per_file));
+		return -ERANGE;
+	}
+	sbi->ll_ra_info.ra_async_pages_per_file_threshold = pages_number;
+
+	return count;
+}
+LUSTRE_RW_ATTR(read_ahead_async_file_threshold_mb);
+
 static ssize_t fast_read_show(struct kobject *kobj,
 			      struct attribute *attr,
 			      char *buf)
@@ -1407,6 +1488,8 @@ struct lprocfs_vars lprocfs_llite_obd_vars[] = {
 	&lustre_attr_file_heat.attr,
 	&lustre_attr_heat_decay_percentage.attr,
 	&lustre_attr_heat_period_second.attr,
+	&lustre_attr_max_read_ahead_async_active.attr,
+	&lustre_attr_read_ahead_async_file_threshold_mb.attr,
 	NULL,
 };
 
@@ -1505,7 +1588,9 @@ void ll_stats_ops_tally(struct ll_sb_info *sbi, int op, int count)
 	[RA_STAT_EOF]			= "read-ahead to EOF",
 	[RA_STAT_MAX_IN_FLIGHT]		= "hit max r-a issue",
 	[RA_STAT_WRONG_GRAB_PAGE]	= "wrong page from grab_cache_page",
-	[RA_STAT_FAILED_REACH_END]	= "failed to reach end"
+	[RA_STAT_FAILED_REACH_END]	= "failed to reach end",
+	[RA_STAT_ASYNC]			= "async readahead",
+	[RA_STAT_FAILED_FAST_READ]	= "failed to fast read",
 };
 
 int ll_debugfs_register_super(struct super_block *sb, const char *name)
diff --git a/fs/lustre/llite/rw.c b/fs/lustre/llite/rw.c
index ad55695..bec26c4 100644
--- a/fs/lustre/llite/rw.c
+++ b/fs/lustre/llite/rw.c
@@ -45,6 +45,7 @@
 #include <linux/uaccess.h>
 
 #include <linux/fs.h>
+#include <linux/file.h>
 #include <linux/pagemap.h>
 /* current_is_kswapd() */
 #include <linux/swap.h>
@@ -129,16 +130,17 @@ void ll_ra_stats_inc(struct inode *inode, enum ra_stat which)
 }
 
 #define RAS_CDEBUG(ras) \
-	CDEBUG(D_READA,						      \
+	CDEBUG(D_READA,							     \
 	       "lrp %lu cr %lu cp %lu ws %lu wl %lu nra %lu rpc %lu "	     \
-	       "r %lu ri %lu csr %lu sf %lu sp %lu sl %lu\n",		     \
-	       ras->ras_last_readpage, ras->ras_consecutive_requests,	\
-	       ras->ras_consecutive_pages, ras->ras_window_start,	    \
-	       ras->ras_window_len, ras->ras_next_readahead,		 \
+	       "r %lu ri %lu csr %lu sf %lu sp %lu sl %lu lr %lu\n",	     \
+	       ras->ras_last_readpage, ras->ras_consecutive_requests,	     \
+	       ras->ras_consecutive_pages, ras->ras_window_start,	     \
+	       ras->ras_window_len, ras->ras_next_readahead,		     \
 	       ras->ras_rpc_size,					     \
-	       ras->ras_requests, ras->ras_request_index,		    \
+	       ras->ras_requests, ras->ras_request_index,		     \
 	       ras->ras_consecutive_stride_requests, ras->ras_stride_offset, \
-	       ras->ras_stride_pages, ras->ras_stride_length)
+	       ras->ras_stride_pages, ras->ras_stride_length,		     \
+	       ras->ras_async_last_readpage)
 
 static int index_in_window(unsigned long index, unsigned long point,
 			   unsigned long before, unsigned long after)
@@ -432,13 +434,177 @@ static int ras_inside_ra_window(unsigned long idx, struct ra_io_arg *ria)
 	return count;
 }
 
+static void ll_readahead_work_free(struct ll_readahead_work *work)
+{
+	fput(work->lrw_file);
+	kfree(work);
+}
+
+static void ll_readahead_handle_work(struct work_struct *wq);
+static void ll_readahead_work_add(struct inode *inode,
+				  struct ll_readahead_work *work)
+{
+	INIT_WORK(&work->lrw_readahead_work, ll_readahead_handle_work);
+	queue_work(ll_i2sbi(inode)->ll_ra_info.ll_readahead_wq,
+		   &work->lrw_readahead_work);
+}
+
+static int ll_readahead_file_kms(const struct lu_env *env,
+				struct cl_io *io, u64 *kms)
+{
+	struct cl_object *clob;
+	struct inode *inode;
+	struct cl_attr *attr = vvp_env_thread_attr(env);
+	int ret;
+
+	clob = io->ci_obj;
+	inode = vvp_object_inode(clob);
+
+	cl_object_attr_lock(clob);
+	ret = cl_object_attr_get(env, clob, attr);
+	cl_object_attr_unlock(clob);
+
+	if (ret != 0)
+		return ret;
+
+	*kms = attr->cat_kms;
+	return 0;
+}
+
+static void ll_readahead_handle_work(struct work_struct *wq)
+{
+	struct ll_readahead_work *work;
+	struct lu_env *env;
+	u16 refcheck;
+	struct ra_io_arg *ria;
+	struct inode *inode;
+	struct ll_file_data *fd;
+	struct ll_readahead_state *ras;
+	struct cl_io *io;
+	struct cl_2queue *queue;
+	pgoff_t ra_end = 0;
+	unsigned long len, mlen = 0;
+	struct file *file;
+	u64 kms;
+	int rc;
+	unsigned long end_index;
+
+	work = container_of(wq, struct ll_readahead_work,
+			    lrw_readahead_work);
+	fd = LUSTRE_FPRIVATE(work->lrw_file);
+	ras = &fd->fd_ras;
+	file = work->lrw_file;
+	inode = file_inode(file);
+
+	env = cl_env_alloc(&refcheck, LCT_NOREF);
+	if (IS_ERR(env)) {
+		rc = PTR_ERR(env);
+		goto out_free_work;
+	}
+
+	io = vvp_env_thread_io(env);
+	ll_io_init(io, file, 0);
+
+	rc = ll_readahead_file_kms(env, io, &kms);
+	if (rc != 0)
+		goto out_put_env;
+
+	if (kms == 0) {
+		ll_ra_stats_inc(inode, RA_STAT_ZERO_LEN);
+		rc = 0;
+		goto out_put_env;
+	}
+
+	ria = &ll_env_info(env)->lti_ria;
+	memset(ria, 0, sizeof(*ria));
+
+	ria->ria_start = work->lrw_start;
+	/* Truncate RA window to end of file */
+	end_index = (unsigned long)((kms - 1) >> PAGE_SHIFT);
+	if (end_index <= work->lrw_end) {
+		work->lrw_end = end_index;
+		ria->ria_eof = true;
+	}
+	if (work->lrw_end <= work->lrw_start) {
+		rc = 0;
+		goto out_put_env;
+	}
+
+	ria->ria_end = work->lrw_end;
+	len = ria->ria_end - ria->ria_start + 1;
+	ria->ria_reserved = ll_ra_count_get(ll_i2sbi(inode), ria,
+					    ria_page_count(ria), mlen);
+
+	CDEBUG(D_READA,
+	       "async reserved pages: %lu/%lu/%lu, ra_cur %d, ra_max %lu\n",
+	       ria->ria_reserved, len, mlen,
+	       atomic_read(&ll_i2sbi(inode)->ll_ra_info.ra_cur_pages),
+	       ll_i2sbi(inode)->ll_ra_info.ra_max_pages);
+
+	if (ria->ria_reserved < len) {
+		ll_ra_stats_inc(inode, RA_STAT_MAX_IN_FLIGHT);
+		if (PAGES_TO_MiB(ria->ria_reserved) < 1) {
+			ll_ra_count_put(ll_i2sbi(inode), ria->ria_reserved);
+			rc = 0;
+			goto out_put_env;
+		}
+	}
+
+	rc = cl_io_rw_init(env, io, CIT_READ, ria->ria_start, len);
+	if (rc)
+		goto out_put_env;
+
+	vvp_env_io(env)->vui_fd = fd;
+	io->ci_state = CIS_LOCKED;
+	io->ci_async_readahead = true;
+	rc = cl_io_start(env, io);
+	if (rc)
+		goto out_io_fini;
+
+	queue = &io->ci_queue;
+	cl_2queue_init(queue);
+
+	rc = ll_read_ahead_pages(env, io, &queue->c2_qin, ras, ria, &ra_end);
+	if (ria->ria_reserved != 0)
+		ll_ra_count_put(ll_i2sbi(inode), ria->ria_reserved);
+	if (queue->c2_qin.pl_nr > 0) {
+		int count = queue->c2_qin.pl_nr;
+
+		rc = cl_io_submit_rw(env, io, CRT_READ, queue);
+		if (rc == 0)
+			task_io_account_read(PAGE_SIZE * count);
+	}
+	if (ria->ria_end == ra_end && ra_end == (kms >> PAGE_SHIFT))
+		ll_ra_stats_inc(inode, RA_STAT_EOF);
+
+	if (ra_end != ria->ria_end)
+		ll_ra_stats_inc(inode, RA_STAT_FAILED_REACH_END);
+
+	/* TODO: discard all pages until page reinit route is implemented */
+	cl_page_list_discard(env, io, &queue->c2_qin);
+
+	/* Unlock unsent read pages in case of error. */
+	cl_page_list_disown(env, io, &queue->c2_qin);
+
+	cl_2queue_fini(env, queue);
+out_io_fini:
+	cl_io_end(env, io);
+	cl_io_fini(env, io);
+out_put_env:
+	cl_env_put(env, &refcheck);
+out_free_work:
+	if (ra_end > 0)
+		ll_ra_stats_inc_sbi(ll_i2sbi(inode), RA_STAT_ASYNC);
+	ll_readahead_work_free(work);
+}
+
 static int ll_readahead(const struct lu_env *env, struct cl_io *io,
 			struct cl_page_list *queue,
-			struct ll_readahead_state *ras, bool hit)
+			struct ll_readahead_state *ras, bool hit,
+			struct file *file)
 {
 	struct vvp_io *vio = vvp_env_io(env);
 	struct ll_thread_info *lti = ll_env_info(env);
-	struct cl_attr *attr = vvp_env_thread_attr(env);
 	unsigned long len, mlen = 0;
 	pgoff_t ra_end = 0, start = 0, end = 0;
 	struct inode *inode;
@@ -451,14 +617,10 @@ static int ll_readahead(const struct lu_env *env, struct cl_io *io,
 	inode = vvp_object_inode(clob);
 
 	memset(ria, 0, sizeof(*ria));
-
-	cl_object_attr_lock(clob);
-	ret = cl_object_attr_get(env, clob, attr);
-	cl_object_attr_unlock(clob);
-
+	ret = ll_readahead_file_kms(env, io, &kms);
 	if (ret != 0)
 		return ret;
-	kms = attr->cat_kms;
+
 	if (kms == 0) {
 		ll_ra_stats_inc(inode, RA_STAT_ZERO_LEN);
 		return 0;
@@ -1141,7 +1303,7 @@ int ll_io_read_page(const struct lu_env *env, struct cl_io *io,
 		int rc2;
 
 		rc2 = ll_readahead(env, io, &queue->c2_qin, ras,
-				   uptodate);
+				   uptodate, file);
 		CDEBUG(D_READA, DFID "%d pages read ahead at %lu\n",
 		       PFID(ll_inode2fid(inode)), rc2, vvp_index(vpg));
 	}
@@ -1183,6 +1345,60 @@ int ll_io_read_page(const struct lu_env *env, struct cl_io *io,
 	return rc;
 }
 
+/*
+ * Possible return value:
+ * 0 no async readahead triggered and fast read could not be used.
+ * 1 no async readahead, but fast read could be used.
+ * 2 async readahead triggered and fast read could be used too.
+ * < 0 on error.
+ */
+static int kickoff_async_readahead(struct file *file, unsigned long pages)
+{
+	struct ll_readahead_work *lrw;
+	struct inode *inode = file_inode(file);
+	struct ll_sb_info *sbi = ll_i2sbi(inode);
+	struct ll_file_data *fd = LUSTRE_FPRIVATE(file);
+	struct ll_readahead_state *ras = &fd->fd_ras;
+	struct ll_ra_info *ra = &sbi->ll_ra_info;
+	unsigned long throttle;
+	unsigned long start = ras_align(ras, ras->ras_next_readahead, NULL);
+	unsigned long end = start + pages - 1;
+
+	throttle = min(ra->ra_async_pages_per_file_threshold,
+		       ra->ra_max_pages_per_file);
+	/*
+	 * If this is strided i/o or the window is smaller than the
+	 * throttle limit, we do not do async readahead. Otherwise,
+	 * we do async readahead, allowing the user thread to do fast i/o.
+	 */
+	if (stride_io_mode(ras) || !throttle ||
+	    ras->ras_window_len < throttle)
+		return 0;
+
+	if ((atomic_read(&ra->ra_cur_pages) + pages) > ra->ra_max_pages)
+		return 0;
+
+	if (ras->ras_async_last_readpage == start)
+		return 1;
+
+	/* ll_readahead_work_free() free it */
+	lrw = kzalloc(sizeof(*lrw), GFP_NOFS);
+	if (lrw) {
+		lrw->lrw_file = get_file(file);
+		lrw->lrw_start = start;
+		lrw->lrw_end = end;
+		spin_lock(&ras->ras_lock);
+		ras->ras_next_readahead = end + 1;
+		ras->ras_async_last_readpage = start;
+		spin_unlock(&ras->ras_lock);
+		ll_readahead_work_add(inode, lrw);
+	} else {
+		return -ENOMEM;
+	}
+
+	return 2;
+}
+
 int ll_readpage(struct file *file, struct page *vmpage)
 {
 	struct cl_object *clob = ll_i2info(file_inode(file))->lli_clob;
@@ -1190,6 +1406,7 @@ int ll_readpage(struct file *file, struct page *vmpage)
 	const struct lu_env *env = NULL;
 	struct cl_io *io = NULL;
 	struct cl_page *page;
+	struct ll_sb_info *sbi = ll_i2sbi(file_inode(file));
 	int result;
 
 	lcc = ll_cl_find(file);
@@ -1216,14 +1433,10 @@ int ll_readpage(struct file *file, struct page *vmpage)
 		page = cl_vmpage_page(vmpage, clob);
 		if (!page) {
 			unlock_page(vmpage);
+			ll_ra_stats_inc_sbi(sbi, RA_STAT_FAILED_FAST_READ);
 			return result;
 		}
 
-		if (!env) {
-			local_env = cl_env_percpu_get();
-			env = local_env;
-		}
-
 		vpg = cl2vvp_page(cl_object_page_slice(page->cp_obj, page));
 		if (vpg->vpg_defer_uptodate) {
 			enum ras_update_flags flags = LL_RAS_HIT;
@@ -1236,8 +1449,7 @@ int ll_readpage(struct file *file, struct page *vmpage)
 			 * if the page is hit in cache because non cache page
 			 * case will be handled by slow read later.
 			 */
-			ras_update(ll_i2sbi(inode), inode, ras, vvp_index(vpg),
-				   flags);
+			ras_update(sbi, inode, ras, vvp_index(vpg), flags);
 			/* avoid duplicate ras_update() call */
 			vpg->vpg_ra_updated = 1;
 
@@ -1247,14 +1459,23 @@ int ll_readpage(struct file *file, struct page *vmpage)
 			 * a cl_io to issue the RPC.
 			 */
 			if (ras->ras_window_start + ras->ras_window_len <
-			    ras->ras_next_readahead + fast_read_pages) {
-				/* export the page and skip io stack */
-				vpg->vpg_ra_used = 1;
-				cl_page_export(env, page, 1);
+			    ras->ras_next_readahead + fast_read_pages ||
+			    kickoff_async_readahead(file, fast_read_pages) > 0)
 				result = 0;
-			}
 		}
 
+		if (!env) {
+			local_env = cl_env_percpu_get();
+			env = local_env;
+		}
+
+		/* export the page and skip io stack */
+		if (result == 0) {
+			vpg->vpg_ra_used = 1;
+			cl_page_export(env, page, 1);
+		} else {
+			ll_ra_stats_inc_sbi(sbi, RA_STAT_FAILED_FAST_READ);
+		}
 		/* release page refcount before unlocking the page to ensure
 		 * the object won't be destroyed in the calling path of
 		 * cl_page_put(). Please see comment in ll_releasepage().
diff --git a/fs/lustre/llite/vvp_io.c b/fs/lustre/llite/vvp_io.c
index ee44a18..68455d5 100644
--- a/fs/lustre/llite/vvp_io.c
+++ b/fs/lustre/llite/vvp_io.c
@@ -749,6 +749,11 @@ static int vvp_io_read_start(const struct lu_env *env,
 
 	down_read(&lli->lli_trunc_sem);
 
+	if (io->ci_async_readahead) {
+		file_accessed(file);
+		return 0;
+	}
+
 	if (!can_populate_pages(env, io, inode))
 		return 0;
 
diff --git a/fs/lustre/lov/lov_io.c b/fs/lustre/lov/lov_io.c
index 9cdfca1..9328240 100644
--- a/fs/lustre/lov/lov_io.c
+++ b/fs/lustre/lov/lov_io.c
@@ -136,6 +136,7 @@ static int lov_io_sub_init(const struct lu_env *env, struct lov_io *lio,
 	sub_io->ci_type = io->ci_type;
 	sub_io->ci_no_srvlock = io->ci_no_srvlock;
 	sub_io->ci_noatime = io->ci_noatime;
+	sub_io->ci_async_readahead = io->ci_async_readahead;
 	sub_io->ci_lock_no_expand = io->ci_lock_no_expand;
 	sub_io->ci_ndelay = io->ci_ndelay;
 	sub_io->ci_layout_version = io->ci_layout_version;
-- 
1.8.3.1
