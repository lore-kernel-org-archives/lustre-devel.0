From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:16:41 -0500
Subject: [lustre-devel] [PATCH 533/622] lustre: llite: support page
 unaligned stride readahead
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-534-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Wang Shilong <wshilong@ddn.com>

Currently, Lustre works well for aligned IO, but performance
is pretty bad for unaligned IO stride read, we might need
take some efforts to improve this situation.

One of the main problem with current stride read is it is
based on Page Index, so if we hit unaligned page case,
stride Read detection will not work well. To support unaligned
page stride read, we might change page index to bytes offset
thus stride read pattern detection work well and we won't hit
many small pages RPC and readahead window reset. At the same
time, we shall keep as much as performances for existed cases
and make sure there won't be obvious regressions for
aligned-stride and sequential read.

Benchmark numbers:
iozone -w -c -i 5 -t1 -j 2 -s 1G -r 43k -F /mnt/lustre/data

Patched                 Unpatched
1386630.75 kB/sec       152002.50 kB/sec

At least performance bumped up more than ~800%.

Benchmarked with IOR from ihara:
	FPP Read(MB/sec)        SSF Read(MB/sec)
Unpatched 44,636                7,731

Patched   44,318                20,745

Got 250% performances up for ior_hard_read workload.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12518
Lustre-commit: 91d264551508 ("LU-12518 llite: support page unaligned stride readahead")
Signed-off-by: Wang Shilong <wshilong@ddn.com>
Reviewed-on: https://review.whamcloud.com/35437
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Li Xi <lixi@ddn.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/file.c           |   2 +-
 fs/lustre/llite/llite_internal.h |  11 +-
 fs/lustre/llite/rw.c             | 388 ++++++++++++++++++++++-----------------
 3 files changed, 228 insertions(+), 173 deletions(-)

diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index 92eead1..d196da8 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -1703,7 +1703,7 @@ static ssize_t ll_file_read_iter(struct kiocb *iocb, struct iov_iter *to)
 	if (cached)
 		goto out;
 
-	ll_ras_enter(file);
+	ll_ras_enter(file, iocb->ki_pos, iov_iter_count(to));
 
 	result = ll_do_fast_read(iocb, to);
 	if (result < 0 || iov_iter_count(to) == 0)
diff --git a/fs/lustre/llite/llite_internal.h b/fs/lustre/llite/llite_internal.h
index 8e7b949..fe9d568 100644
--- a/fs/lustre/llite/llite_internal.h
+++ b/fs/lustre/llite/llite_internal.h
@@ -654,11 +654,6 @@ struct ll_readahead_state {
 	 */
 	unsigned long	ras_requests;
 	/*
-	 * Page index with respect to the current request, these value
-	 * will not be accurate when dealing with reads issued via mmap.
-	 */
-	unsigned long	ras_request_index;
-	/*
 	 * The following 3 items are used for detecting the stride I/O
 	 * mode.
 	 * In stride I/O mode,
@@ -681,6 +676,10 @@ struct ll_readahead_state {
 	unsigned long	ras_consecutive_stride_requests;
 	/* index of the last page that async readahead starts */
 	pgoff_t		ras_async_last_readpage;
+	/* whether we should increase readahead window */
+	bool		ras_need_increase_window;
+	/* whether ra miss check should be skipped */
+	bool		ras_no_miss_check;
 };
 
 struct ll_readahead_work {
@@ -778,7 +777,7 @@ static inline bool ll_sbi_has_file_heat(struct ll_sb_info *sbi)
 	return !!(sbi->ll_flags & LL_SBI_FILE_HEAT);
 }
 
-void ll_ras_enter(struct file *f);
+void ll_ras_enter(struct file *f, unsigned long pos, unsigned long count);
 
 /* llite/lcommon_misc.c */
 int cl_ocd_update(struct obd_device *host, struct obd_device *watched,
diff --git a/fs/lustre/llite/rw.c b/fs/lustre/llite/rw.c
index 38f7aa2c..bf91ae1 100644
--- a/fs/lustre/llite/rw.c
+++ b/fs/lustre/llite/rw.c
@@ -131,12 +131,11 @@ void ll_ra_stats_inc(struct inode *inode, enum ra_stat which)
 
 #define RAS_CDEBUG(ras) \
 	CDEBUG(D_READA,							     \
-	       "lre %lu cr %lu cb %lu ws %lu wl %lu nra %lu rpc %lu r %lu ri %lu csr %lu sf %lu sb %lu sl %lu lr %lu\n", \
+	       "lre %lu cr %lu cb %lu ws %lu wl %lu nra %lu rpc %lu r %lu csr %lu sf %lu sb %lu sl %lu lr %lu\n", \
 	       ras->ras_last_read_end, ras->ras_consecutive_requests,	     \
 	       ras->ras_consecutive_bytes, ras->ras_window_start,	     \
 	       ras->ras_window_len, ras->ras_next_readahead,		     \
-	       ras->ras_rpc_size,					     \
-	       ras->ras_requests, ras->ras_request_index,		     \
+	       ras->ras_rpc_size, ras->ras_requests,			     \
 	       ras->ras_consecutive_stride_requests, ras->ras_stride_offset, \
 	       ras->ras_stride_bytes, ras->ras_stride_length,		     \
 	       ras->ras_async_last_readpage)
@@ -154,18 +153,6 @@ static int pos_in_window(unsigned long pos, unsigned long point,
 	return start <= pos && pos <= end;
 }
 
-void ll_ras_enter(struct file *f)
-{
-	struct ll_file_data *fd = LUSTRE_FPRIVATE(f);
-	struct ll_readahead_state *ras = &fd->fd_ras;
-
-	spin_lock(&ras->ras_lock);
-	ras->ras_requests++;
-	ras->ras_request_index = 0;
-	ras->ras_consecutive_requests++;
-	spin_unlock(&ras->ras_lock);
-}
-
 /**
  * Initiates read-ahead of a page with given index.
  *
@@ -311,15 +298,23 @@ static inline int stride_io_mode(struct ll_readahead_state *ras)
 
 static int ria_page_count(struct ra_io_arg *ria)
 {
-	u64 length = ria->ria_end >= ria->ria_start ?
-		     ria->ria_end - ria->ria_start + 1 : 0;
-	unsigned int bytes_count;
-
+	u64 length_bytes = ria->ria_end >= ria->ria_start ?
+			   (ria->ria_end - ria->ria_start + 1) << PAGE_SHIFT : 0;
+	unsigned int bytes_count, pg_count;
+
+	if (ria->ria_length > ria->ria_bytes && ria->ria_bytes &&
+	    (ria->ria_length % PAGE_SIZE || ria->ria_bytes % PAGE_SIZE ||
+	     ria->ria_stoff % PAGE_SIZE)) {
+		/* Over-estimate un-aligned page stride read */
+		pg_count = ((ria->ria_bytes + PAGE_SIZE - 1) >> PAGE_SHIFT) + 1;
+		pg_count *= length_bytes / ria->ria_length + 1;
+
+		return pg_count;
+	}
 	bytes_count = stride_byte_count(ria->ria_stoff, ria->ria_length,
 					 ria->ria_bytes, ria->ria_start,
-					 length << PAGE_SHIFT);
+					 length_bytes);
 	return (bytes_count + PAGE_SIZE - 1) >> PAGE_SHIFT;
-
 }
 
 static unsigned long ras_align(struct ll_readahead_state *ras,
@@ -333,16 +328,28 @@ static unsigned long ras_align(struct ll_readahead_state *ras,
 }
 
 /*Check whether the index is in the defined ra-window */
-static int ras_inside_ra_window(unsigned long idx, struct ra_io_arg *ria)
+static bool ras_inside_ra_window(unsigned long idx, struct ra_io_arg *ria)
 {
+	unsigned long pos = idx << PAGE_SHIFT;
+	unsigned long offset;
+
 	/* If ria_length == ria_pages, it means non-stride I/O mode,
 	 * idx should always inside read-ahead window in this case
 	 * For stride I/O mode, just check whether the idx is inside
 	 * the ria_pages.
 	 */
-	return ria->ria_length == 0 || ria->ria_length == ria->ria_bytes ||
-	       (idx >= ria->ria_stoff && (idx - ria->ria_stoff) %
-		ria->ria_length < ria->ria_bytes);
+	if (ria->ria_length == 0 || ria->ria_length == ria->ria_bytes)
+		return true;
+
+	if (pos >= ria->ria_stoff) {
+		offset = (pos - ria->ria_stoff) % ria->ria_length;
+		if (offset < ria->ria_bytes ||
+		    (ria->ria_length - offset) < PAGE_SIZE)
+			return true;
+	} else if (pos + PAGE_SIZE > ria->ria_stoff)
+		return true;
+
+	return false;
 }
 
 static unsigned long
@@ -351,7 +358,6 @@ static int ras_inside_ra_window(unsigned long idx, struct ra_io_arg *ria)
 		    struct ra_io_arg *ria, pgoff_t *ra_end)
 {
 	struct cl_read_ahead ra = { 0 };
-	bool stride_ria;
 	pgoff_t page_idx;
 	int count = 0;
 	int rc;
@@ -359,7 +365,6 @@ static int ras_inside_ra_window(unsigned long idx, struct ra_io_arg *ria)
 	LASSERT(ria);
 	RIA_DEBUG(ria);
 
-	stride_ria = ria->ria_length > ria->ria_bytes && ria->ria_bytes > 0;
 	for (page_idx = ria->ria_start;
 	     page_idx <= ria->ria_end && ria->ria_reserved > 0; page_idx++) {
 		if (ras_inside_ra_window(page_idx, ria)) {
@@ -417,7 +422,7 @@ static int ras_inside_ra_window(unsigned long idx, struct ra_io_arg *ria)
 				ria->ria_reserved--;
 				count++;
 			}
-		} else if (stride_ria) {
+		} else if (stride_io_mode(ras)) {
 			/* If it is not in the read-ahead window, and it is
 			 * read-ahead mode, then check whether it should skip
 			 * the stride gap.
@@ -428,7 +433,8 @@ static int ras_inside_ra_window(unsigned long idx, struct ra_io_arg *ria)
 			offset = (pos - ria->ria_stoff) % ria->ria_length;
 			if (offset >= ria->ria_bytes) {
 				pos += (ria->ria_length - offset);
-				page_idx = (pos >> PAGE_SHIFT) - 1;
+				if ((pos >> PAGE_SHIFT) >= page_idx + 1)
+					page_idx = (pos >> PAGE_SHIFT) - 1;
 				CDEBUG(D_READA,
 				       "Stride: jump %lu pages to %lu\n",
 				       ria->ria_length - offset, page_idx);
@@ -775,11 +781,10 @@ void ll_readahead_init(struct inode *inode, struct ll_readahead_state *ras)
  * Check whether the read request is in the stride window.
  * If it is in the stride window, return true, otherwise return false.
  */
-static bool index_in_stride_window(struct ll_readahead_state *ras,
-				   pgoff_t index)
+static bool read_in_stride_window(struct ll_readahead_state *ras,
+				  unsigned long pos, unsigned long count)
 {
 	unsigned long stride_gap;
-	unsigned long pos = index << PAGE_SHIFT;
 
 	if (ras->ras_stride_length == 0 || ras->ras_stride_bytes == 0 ||
 	    ras->ras_stride_bytes == ras->ras_stride_length)
@@ -789,12 +794,13 @@ static bool index_in_stride_window(struct ll_readahead_state *ras,
 
 	/* If it is contiguous read */
 	if (stride_gap == 0)
-		return ras->ras_consecutive_bytes + PAGE_SIZE <=
+		return ras->ras_consecutive_bytes + count <=
 			ras->ras_stride_bytes;
 
 	/* Otherwise check the stride by itself */
 	return (ras->ras_stride_length - ras->ras_stride_bytes) == stride_gap &&
-		ras->ras_consecutive_bytes == ras->ras_stride_bytes;
+		ras->ras_consecutive_bytes == ras->ras_stride_bytes &&
+		count <= ras->ras_stride_bytes;
 }
 
 static void ras_init_stride_detector(struct ll_readahead_state *ras,
@@ -802,13 +808,6 @@ static void ras_init_stride_detector(struct ll_readahead_state *ras,
 {
 	unsigned long stride_gap = pos - ras->ras_last_read_end - 1;
 
-	if ((stride_gap != 0 || ras->ras_consecutive_stride_requests == 0) &&
-	    !stride_io_mode(ras)) {
-		ras->ras_stride_bytes = ras->ras_consecutive_bytes;
-		ras->ras_stride_length =  ras->ras_consecutive_bytes +
-					 stride_gap;
-	}
-	LASSERT(ras->ras_request_index == 0);
 	LASSERT(ras->ras_consecutive_stride_requests == 0);
 
 	if (pos <= ras->ras_last_read_end) {
@@ -819,6 +818,8 @@ static void ras_init_stride_detector(struct ll_readahead_state *ras,
 
 	ras->ras_stride_bytes = ras->ras_consecutive_bytes;
 	ras->ras_stride_length = stride_gap + ras->ras_consecutive_bytes;
+	ras->ras_consecutive_stride_requests++;
+	ras->ras_stride_offset = pos;
 
 	RAS_CDEBUG(ras);
 }
@@ -895,49 +896,97 @@ static void ras_increase_window(struct inode *inode,
 	}
 }
 
-static void ras_update(struct ll_sb_info *sbi, struct inode *inode,
-		       struct ll_readahead_state *ras, unsigned long index,
-		       enum ras_update_flags flags)
+/**
+ * Seek within 8 pages are considered as sequential read for now.
+ */
+static inline bool is_loose_seq_read(struct ll_readahead_state *ras,
+				     unsigned long pos)
 {
-	struct ll_ra_info *ra = &sbi->ll_ra_info;
-	int zero = 0, stride_detect = 0, ra_miss = 0;
-	unsigned long pos = index << PAGE_SHIFT;
-	bool hit = flags & LL_RAS_HIT;
-
-	spin_lock(&ras->ras_lock);
-
-	if (!hit)
-		CDEBUG(D_READA, DFID " pages at %lu miss.\n",
-		       PFID(ll_inode2fid(inode)), index);
+	return pos_in_window(pos, ras->ras_last_read_end,
+			     8 << PAGE_SHIFT, 8 << PAGE_SHIFT);
+}
 
-	ll_ra_stats_inc_sbi(sbi, hit ? RA_STAT_HIT : RA_STAT_MISS);
+static void ras_detect_read_pattern(struct ll_readahead_state *ras,
+				    struct ll_sb_info *sbi,
+				    unsigned long pos, unsigned long count,
+				    bool mmap)
+{
+	bool stride_detect = false;
+	unsigned long index = pos >> PAGE_SHIFT;
 
-	/* reset the read-ahead window in two cases.  First when the app seeks
-	 * or reads to some other part of the file.  Secondly if we get a
-	 * read-ahead miss that we think we've previously issued.  This can
-	 * be a symptom of there being so many read-ahead pages that the VM is
-	 * reclaiming it before we get to it.
+	/*
+	 * Reset the read-ahead window in two cases. First when the app seeks
+	 * or reads to some other part of the file. Secondly if we get a
+	 * read-ahead miss that we think we've previously issued. This can
+	 * be a symptom of there being so many read-ahead pages that the VM
+	 * is reclaiming it before we get to it.
 	 */
-	if (!pos_in_window(pos, ras->ras_last_read_end,
-			   8 << PAGE_SHIFT, 8 << PAGE_SHIFT)) {
-		zero = 1;
+	if (!is_loose_seq_read(ras, pos)) {
+		/* Check whether it is in stride I/O mode */
+		if (!read_in_stride_window(ras, pos, count)) {
+			if (ras->ras_consecutive_stride_requests == 0)
+				ras_init_stride_detector(ras, pos, count);
+			else
+				ras_stride_reset(ras);
+			ras->ras_consecutive_bytes = 0;
+			ras_reset(ras, index);
+		} else {
+			ras->ras_consecutive_bytes = 0;
+			ras->ras_consecutive_requests = 0;
+			if (++ras->ras_consecutive_stride_requests > 1)
+				stride_detect = true;
+			RAS_CDEBUG(ras);
+		}
 		ll_ra_stats_inc_sbi(sbi, RA_STAT_DISTANT_READPAGE);
-	} else if (!hit && ras->ras_window_len &&
-		   index < ras->ras_next_readahead &&
-		   pos_in_window(index, ras->ras_window_start, 0,
-				 ras->ras_window_len)) {
-		ra_miss = 1;
-		ll_ra_stats_inc_sbi(sbi, RA_STAT_MISS_IN_WINDOW);
+	} else if (stride_io_mode(ras)) {
+		/*
+		 * If this is contiguous read but in stride I/O mode
+		 * currently, check whether stride step still is valid,
+		 * if invalid, it will reset the stride ra window to
+		 * be zero.
+		 */
+		if (!read_in_stride_window(ras, pos, count)) {
+			ras_stride_reset(ras);
+			ras->ras_window_len = 0;
+			ras->ras_next_readahead = index;
+		}
 	}
 
-	/* On the second access to a file smaller than the tunable
+	ras->ras_consecutive_bytes += count;
+	if (mmap) {
+		unsigned int idx = (ras->ras_consecutive_bytes >> PAGE_SHIFT);
+
+		if ((idx >= 4 && idx % 4 == 0) || stride_detect)
+			ras->ras_need_increase_window = true;
+	} else if ((ras->ras_consecutive_requests > 1 || stride_detect)) {
+		ras->ras_need_increase_window = true;
+	}
+
+	ras->ras_last_read_end = pos + count - 1;
+}
+
+void ll_ras_enter(struct file *f, unsigned long pos, unsigned long count)
+{
+	struct ll_file_data *fd = LUSTRE_FPRIVATE(f);
+	struct ll_readahead_state *ras = &fd->fd_ras;
+	struct inode *inode = file_inode(f);
+	unsigned long index = pos >> PAGE_SHIFT;
+	struct ll_sb_info *sbi = ll_i2sbi(inode);
+
+	spin_lock(&ras->ras_lock);
+	ras->ras_requests++;
+	ras->ras_consecutive_requests++;
+	ras->ras_need_increase_window = false;
+	ras->ras_no_miss_check = false;
+	/*
+	 * On the second access to a file smaller than the tunable
 	 * ra_max_read_ahead_whole_pages trigger RA on all pages in the
 	 * file up to ra_max_pages_per_file.  This is simply a best effort
-	 * and only occurs once per open file.  Normal RA behavior is reverted
-	 * to for subsequent IO.  The mmap case does not increment
-	 * ras_requests and thus can never trigger this behavior.
+	 * and only occurs once per open file. Normal RA behavior is reverted
+	 * to for subsequent IO.
 	 */
-	if (ras->ras_requests >= 2 && !ras->ras_request_index) {
+	if (ras->ras_requests >= 2) {
+		struct ll_ra_info *ra = &sbi->ll_ra_info;
 		u64 kms_pages;
 
 		kms_pages = (i_size_read(inode) + PAGE_SIZE - 1) >>
@@ -952,73 +1001,111 @@ static void ras_update(struct ll_sb_info *sbi, struct inode *inode,
 			ras->ras_window_start = 0;
 			ras->ras_next_readahead = index + 1;
 			ras->ras_window_len = min(ra->ra_max_pages_per_file,
-				ra->ra_max_read_ahead_whole_pages);
+						  ra->ra_max_read_ahead_whole_pages);
+			ras->ras_no_miss_check = true;
 			goto out_unlock;
 		}
 	}
-	if (zero) {
-		/* check whether it is in stride I/O mode*/
-		if (!index_in_stride_window(ras, index)) {
-			if (ras->ras_consecutive_stride_requests == 0 &&
-			    ras->ras_request_index == 0) {
-				ras_init_stride_detector(ras, pos, PAGE_SIZE);
-				ras->ras_consecutive_stride_requests++;
-			} else {
-				ras_stride_reset(ras);
-			}
+	ras_detect_read_pattern(ras, sbi, pos, count, false);
+out_unlock:
+	spin_unlock(&ras->ras_lock);
+}
+
+static bool index_in_stride_window(struct ll_readahead_state *ras,
+				   unsigned int index)
+{
+	unsigned long pos = index << PAGE_SHIFT;
+	unsigned long offset;
+
+	if (ras->ras_stride_length == 0 || ras->ras_stride_bytes == 0 ||
+	    ras->ras_stride_bytes == ras->ras_stride_length)
+		return false;
+
+	if (pos >= ras->ras_stride_offset) {
+		offset = (pos - ras->ras_stride_offset) %
+			 ras->ras_stride_length;
+		if (offset < ras->ras_stride_bytes ||
+		    ras->ras_stride_length - offset < PAGE_SIZE)
+			return true;
+	} else if (ras->ras_stride_offset - pos < PAGE_SIZE) {
+		return true;
+	}
+
+	return false;
+}
+
+/*
+ * ll_ras_enter() is used to detect read pattern according to
+ * pos and count.
+ *
+ * ras_update() is used to detect cache miss and
+ * reset window or increase window accordingly
+ */
+static void ras_update(struct ll_sb_info *sbi, struct inode *inode,
+		       struct ll_readahead_state *ras, unsigned long index,
+		       enum ras_update_flags flags)
+{
+	struct ll_ra_info *ra = &sbi->ll_ra_info;
+	bool hit = flags & LL_RAS_HIT;
+
+	spin_lock(&ras->ras_lock);
+
+	if (!hit)
+		CDEBUG(D_READA, DFID " pages at %lu miss.\n",
+		       PFID(ll_inode2fid(inode)), index);
+	ll_ra_stats_inc_sbi(sbi, hit ? RA_STAT_HIT : RA_STAT_MISS);
+
+	/*
+	 * The readahead window has been expanded to cover whole
+	 * file size, we don't care whether ra miss happen or not.
+	 * Because we will read whole file to page cache even if
+	 * some pages missed.
+	 */
+	if (ras->ras_no_miss_check)
+		goto out_unlock;
+
+	if (flags & LL_RAS_MMAP)
+		ras_detect_read_pattern(ras, sbi, index << PAGE_SHIFT,
+					PAGE_SIZE, true);
+
+	if (!hit && ras->ras_window_len &&
+	    index < ras->ras_next_readahead &&
+	    pos_in_window(index, ras->ras_window_start, 0,
+			  ras->ras_window_len)) {
+		ll_ra_stats_inc_sbi(sbi, RA_STAT_MISS_IN_WINDOW);
+		ras->ras_need_increase_window = false;
+
+		if (index_in_stride_window(ras, index) &&
+		    stride_io_mode(ras)) {
+			/*
+			 * if (index != ras->ras_last_readpage + 1)
+			 *      ras->ras_consecutive_pages = 0;
+			 */
 			ras_reset(ras, index);
-			ras->ras_consecutive_bytes += PAGE_SIZE;
-			goto out_unlock;
-		} else {
-			ras->ras_consecutive_bytes = 0;
-			ras->ras_consecutive_requests = 0;
-			if (++ras->ras_consecutive_stride_requests > 1)
-				stride_detect = 1;
-			RAS_CDEBUG(ras);
-		}
-	} else {
-		if (ra_miss) {
-			if (index_in_stride_window(ras, index) &&
-			    stride_io_mode(ras)) {
-				if (index != (ras->ras_last_read_end >>
-					      PAGE_SHIFT) + 1)
-					ras->ras_consecutive_bytes = 0;
-				ras_reset(ras, index);
-
-				/* If stride-RA hit cache miss, the stride
-				 * detector will not be reset to avoid the
-				 * overhead of redetecting read-ahead mode,
-				 * but on the condition that the stride window
-				 * is still intersect with normal sequential
-				 * read-ahead window.
-				 */
-				if (ras->ras_window_start <
-				    (ras->ras_stride_offset >> PAGE_SHIFT))
-					ras_stride_reset(ras);
-				RAS_CDEBUG(ras);
-			} else {
-				/* Reset both stride window and normal RA
-				 * window
-				 */
-				ras_reset(ras, index);
-				ras->ras_consecutive_bytes += PAGE_SIZE;
-				ras_stride_reset(ras);
-				goto out_unlock;
-			}
-		} else if (stride_io_mode(ras)) {
-			/* If this is contiguous read but in stride I/O mode
-			 * currently, check whether stride step still is valid,
-			 * if invalid, it will reset the stride ra window
+			/*
+			 * If stride-RA hit cache miss, the stride
+			 * detector will not be reset to avoid the
+			 * overhead of redetecting read-ahead mode,
+			 * but on the condition that the stride window
+			 * is still intersect with normal sequential
+			 * read-ahead window.
 			 */
-			if (!index_in_stride_window(ras, index)) {
-				/* Shrink stride read-ahead window to be zero */
+			if (ras->ras_window_start <
+			    ras->ras_stride_offset)
 				ras_stride_reset(ras);
-				ras->ras_window_len = 0;
-				ras->ras_next_readahead = index;
-			}
+			RAS_CDEBUG(ras);
+		} else {
+			/*
+			 * Reset both stride window and normal RA
+			 * window.
+			 */
+			ras_reset(ras, index);
+			/* ras->ras_consecutive_pages++; */
+			ras->ras_consecutive_bytes = 0;
+			ras_stride_reset(ras);
+			goto out_unlock;
 		}
 	}
-	ras->ras_consecutive_bytes += PAGE_SIZE;
 	ras_set_start(ras, index);
 
 	if (stride_io_mode(ras)) {
@@ -1037,44 +1124,13 @@ static void ras_update(struct ll_sb_info *sbi, struct inode *inode,
 		if (!hit)
 			ras->ras_next_readahead = index + 1;
 	}
-	RAS_CDEBUG(ras);
 
-	/* Trigger RA in the mmap case where ras_consecutive_requests
-	 * is not incremented and thus can't be used to trigger RA
-	 */
-	if (ras->ras_consecutive_bytes >= (4 << PAGE_SHIFT) &&
-	    flags & LL_RAS_MMAP) {
+	if (ras->ras_need_increase_window) {
 		ras_increase_window(inode, ras, ra);
-		/*
-		 * reset consecutive pages so that the readahead window can
-		 * grow gradually.
-		 */
-		ras->ras_consecutive_bytes = 0;
-		goto out_unlock;
-	}
-
-	/* Initially reset the stride window offset to next_readahead*/
-	if (ras->ras_consecutive_stride_requests == 2 && stride_detect) {
-		/**
-		 * Once stride IO mode is detected, next_readahead should be
-		 * reset to make sure next_readahead > stride offset
-		 */
-		ras->ras_next_readahead = max(index, ras->ras_next_readahead);
-		ras->ras_stride_offset = index << PAGE_SHIFT;
-		ras->ras_window_start = max(index, ras->ras_window_start);
+		ras->ras_need_increase_window = false;
 	}
 
-	/* The initial ras_window_len is set to the request size.  To avoid
-	 * uselessly reading and discarding pages for random IO the window is
-	 * only increased once per consecutive request received.
-	 */
-	if ((ras->ras_consecutive_requests > 1 || stride_detect) &&
-	    !ras->ras_request_index)
-		ras_increase_window(inode, ras, ra);
 out_unlock:
-	RAS_CDEBUG(ras);
-	ras->ras_request_index++;
-	ras->ras_last_read_end = pos + PAGE_SIZE - 1;
 	spin_unlock(&ras->ras_lock);
 }
 
-- 
1.8.3.1
