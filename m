From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:17:46 -0500
Subject: [lustre-devel] [PATCH 598/622] lustre: llite: proper names/types
 for offset/pages
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-599-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Andreas Dilger <adilger@whamcloud.com>

Use loff_t for file offsets and pgoff_t for page index values
instead of unsigned long, so that it is possible to distinguish
what type of value is being used in the byte-granular readahead
code.  Otherwise, it is difficult to determine what units "start"
or "end" in a given function are in.

Rename variables that reference page index values with an "_idx"
suffix to make this clear when reading the code.  Similarly, use
"bytes" or "pages" for variable names instead of "count" or "len".

Fix stride_page_count() to properly use loff_t for the byte_count,
which might otherwise overflow for large strides.

Cast pgoff_t vars to loff_t before PAGE_SIZE shift to avoid overflow.
Use shift and mask with PAGE_SIZE and PAGE_MASK instead of mod/div.

Use proper 64-bit division functions for the loff_t types when
calculating stride, since they are not guaranteed to be within 4GB.

Remove unused "remainder" argument from ras_align() function.

Fixes: 91d264551508 ("LU-12518 llite: support page unaligned stride readahead")
WC-bug-id: https://jira.whamcloud.com/browse/LU-12518
Lustre-commit: 83d8dd1d7c30 ("LU-12518 llite: proper names/types for offset/pages")
Signed-off-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/37248
Reviewed-by: Wang Shilong <wshilong@ddn.com>
Reviewed-by: Gu Zheng <gzheng@ddn.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/cl_object.h    |  10 +-
 fs/lustre/llite/file.c           |   6 +-
 fs/lustre/llite/llite_internal.h |  49 +++--
 fs/lustre/llite/rw.c             | 455 ++++++++++++++++++++-------------------
 fs/lustre/llite/vvp_internal.h   |   4 +-
 fs/lustre/llite/vvp_io.c         |  18 +-
 fs/lustre/lov/lov_io.c           |  21 +-
 fs/lustre/mdc/mdc_dev.c          |   4 +-
 fs/lustre/obdclass/integrity.c   |   2 +-
 fs/lustre/osc/osc_cache.c        |   2 +-
 fs/lustre/osc/osc_io.c           |   8 +-
 11 files changed, 294 insertions(+), 285 deletions(-)

diff --git a/fs/lustre/include/cl_object.h b/fs/lustre/include/cl_object.h
index 67731b0..aa54537 100644
--- a/fs/lustre/include/cl_object.h
+++ b/fs/lustre/include/cl_object.h
@@ -1464,14 +1464,14 @@ struct cl_read_ahead {
 	 * This is determined DLM lock coverage, RPC and stripe boundary.
 	 * cra_end is included.
 	 */
-	pgoff_t				cra_end;
+	pgoff_t				cra_end_idx;
 	/* optimal RPC size for this read, by pages */
-	unsigned long			cra_rpc_size;
-	/*
-	 * Release callback. If readahead holds resources underneath, this
+	unsigned long			cra_rpc_pages;
+	/* Release callback. If readahead holds resources underneath, this
 	 * function should be called to release it.
 	 */
-	void (*cra_release)(const struct lu_env *env, void *cbdata);
+	void				(*cra_release)(const struct lu_env *env,
+						       void *cbdata);
 	/* Callback data for cra_release routine */
 	void				*cra_cbdata;
 	/* whether lock is in contention */
diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index c7233bf..097dbeb 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -472,7 +472,7 @@ void ll_dom_finish_open(struct inode *inode, struct ptlrpc_request *req,
 	 * client PAGE_SIZE to be used on that client, if server's PAGE_SIZE is
 	 * smaller then offset may be not aligned and that data is just ignored.
 	 */
-	if (rnb->rnb_offset % PAGE_SIZE)
+	if (rnb->rnb_offset & ~PAGE_MASK)
 		return;
 
 	/* Server returns whole file or just file tail if it fills in reply
@@ -492,9 +492,9 @@ void ll_dom_finish_open(struct inode *inode, struct ptlrpc_request *req,
 	data = (char *)rnb + sizeof(*rnb);
 
 	lnb.lnb_file_offset = rnb->rnb_offset;
-	start = lnb.lnb_file_offset / PAGE_SIZE;
+	start = lnb.lnb_file_offset >> PAGE_SHIFT;
 	index = 0;
-	LASSERT(lnb.lnb_file_offset % PAGE_SIZE == 0);
+	LASSERT((lnb.lnb_file_offset & ~PAGE_MASK) == 0);
 	lnb.lnb_page_offset = 0;
 	do {
 		lnb.lnb_data = data + (index << PAGE_SHIFT);
diff --git a/fs/lustre/llite/llite_internal.h b/fs/lustre/llite/llite_internal.h
index b7b418f..55d451fe 100644
--- a/fs/lustre/llite/llite_internal.h
+++ b/fs/lustre/llite/llite_internal.h
@@ -464,22 +464,22 @@ struct ll_ra_info {
  * counted by page index.
  */
 struct ra_io_arg {
-	pgoff_t		ria_start;	/* start offset of read-ahead*/
-	pgoff_t		ria_end;	/* end offset of read-ahead*/
+	pgoff_t		ria_start_idx;	/* start offset of read-ahead*/
+	pgoff_t		ria_end_idx;	/* end offset of read-ahead*/
 	unsigned long	ria_reserved;	/* reserved pages for read-ahead */
-	pgoff_t		ria_end_min;	/* minimum end to cover current read */
+	pgoff_t		ria_end_idx_min;/* minimum end to cover current read */
 	bool		ria_eof;	/* reach end of file */
-	/* If stride read pattern is detected, ria_stoff means where
-	 * stride read is started. Note: for normal read-ahead, the
+	/* If stride read pattern is detected, ria_stoff is the byte offset
+	 * where stride read is started. Note: for normal read-ahead, the
 	 * value here is meaningless, and also it will not be accessed
 	 */
-	unsigned long	ria_stoff;
+	loff_t		ria_stoff;
 	/* ria_length and ria_bytes are the length and pages length in the
 	 * stride I/O mode. And they will also be used to check whether
 	 * it is stride I/O read-ahead in the read-ahead pages
 	 */
-	unsigned long	ria_length;
-	unsigned long	ria_bytes;
+	loff_t		ria_length;
+	loff_t		ria_bytes;
 };
 
 /* LL_HIST_MAX=32 causes an overflow */
@@ -697,9 +697,9 @@ struct ll_sb_info {
  * per file-descriptor read-ahead data.
  */
 struct ll_readahead_state {
-	spinlock_t  ras_lock;
+	spinlock_t	ras_lock;
 	/* End byte that read(2) try to read.  */
-	unsigned long	ras_last_read_end;
+	loff_t		ras_last_read_end_bytes;
 	/*
 	 * number of bytes read after last read-ahead window reset. As window
 	 * is reset on each seek, this is effectively a number of consecutive
@@ -710,7 +710,7 @@ struct ll_readahead_state {
 	 * case, it probably doesn't make sense to expand window to
 	 * PTLRPC_MAX_BRW_PAGES on the third access.
 	 */
-	unsigned long	ras_consecutive_bytes;
+	loff_t		ras_consecutive_bytes;
 	/*
 	 * number of read requests after the last read-ahead window reset
 	 * As window is reset on each seek, this is effectively the number
@@ -724,12 +724,13 @@ struct ll_readahead_state {
 	 * expanded to PTLRPC_MAX_BRW_PAGES. Afterwards, window is enlarged by
 	 * PTLRPC_MAX_BRW_PAGES chunks up to ->ra_max_pages.
 	 */
-	pgoff_t		ras_window_start, ras_window_len;
+	pgoff_t		ras_window_start_idx;
+	pgoff_t		ras_window_pages;
 	/*
-	 * Optimal RPC size. It decides how many pages will be sent
-	 * for each read-ahead.
+	 * Optimal RPC size in pages.
+	 * It decides how many pages will be sent for each read-ahead.
 	 */
-	unsigned long	ras_rpc_size;
+	unsigned long	ras_rpc_pages;
 	/*
 	 * Where next read-ahead should start at. This lies within read-ahead
 	 * window. Read-ahead window is read in pieces rather than at once
@@ -737,7 +738,7 @@ struct ll_readahead_state {
 	 * ->ra_max_pages (see ll_ra_count_get()), 2. client cannot read pages
 	 * not covered by DLM lock.
 	 */
-	pgoff_t		ras_next_readahead;
+	pgoff_t		ras_next_readahead_idx;
 	/*
 	 * Total number of ll_file_read requests issued, reads originating
 	 * due to mmap are not counted in this total.  This value is used to
@@ -755,9 +756,9 @@ struct ll_readahead_state {
 	 * ras_stride_bytes = stride_bytes;
 	 * Note: all these three items are counted by bytes.
 	 */
-	unsigned long	ras_stride_length;
-	unsigned long	ras_stride_bytes;
-	unsigned long	ras_stride_offset;
+	loff_t		ras_stride_length;
+	loff_t		ras_stride_bytes;
+	loff_t		ras_stride_offset;
 	/*
 	 * number of consecutive stride request count, and it is similar as
 	 * ras_consecutive_requests, but used for stride I/O mode.
@@ -766,7 +767,7 @@ struct ll_readahead_state {
 	 */
 	unsigned long	ras_consecutive_stride_requests;
 	/* index of the last page that async readahead starts */
-	pgoff_t		ras_async_last_readpage;
+	pgoff_t		ras_async_last_readpage_idx;
 	/* whether we should increase readahead window */
 	bool		ras_need_increase_window;
 	/* whether ra miss check should be skipped */
@@ -776,10 +777,8 @@ struct ll_readahead_state {
 struct ll_readahead_work {
 	/** File to readahead */
 	struct file			*lrw_file;
-	/** Start bytes */
-	unsigned long			 lrw_start;
-	/** End bytes */
-	unsigned long			 lrw_end;
+	pgoff_t				 lrw_start_idx;
+	pgoff_t				 lrw_end_idx;
 
 	/* async worker to handler read */
 	struct work_struct		 lrw_readahead_work;
@@ -868,7 +867,7 @@ static inline bool ll_sbi_has_file_heat(struct ll_sb_info *sbi)
 	return !!(sbi->ll_flags & LL_SBI_FILE_HEAT);
 }
 
-void ll_ras_enter(struct file *f, unsigned long pos, unsigned long count);
+void ll_ras_enter(struct file *f, loff_t pos, size_t count);
 
 /* llite/lcommon_misc.c */
 int cl_ocd_update(struct obd_device *host, struct obd_device *watched,
diff --git a/fs/lustre/llite/rw.c b/fs/lustre/llite/rw.c
index bf91ae1..9509023 100644
--- a/fs/lustre/llite/rw.c
+++ b/fs/lustre/llite/rw.c
@@ -80,7 +80,8 @@
  */
 static unsigned long ll_ra_count_get(struct ll_sb_info *sbi,
 				     struct ra_io_arg *ria,
-				     unsigned long pages, unsigned long min)
+				     unsigned long pages,
+				     unsigned long pages_min)
 {
 	struct ll_ra_info *ra = &sbi->ll_ra_info;
 	long ret;
@@ -101,19 +102,19 @@ static unsigned long ll_ra_count_get(struct ll_sb_info *sbi,
 	}
 
 out:
-	if (ret < min) {
+	if (ret < pages_min) {
 		/* override ra limit for maximum performance */
-		atomic_add(min - ret, &ra->ra_cur_pages);
-		ret = min;
+		atomic_add(pages_min - ret, &ra->ra_cur_pages);
+		ret = pages_min;
 	}
 	return ret;
 }
 
-void ll_ra_count_put(struct ll_sb_info *sbi, unsigned long len)
+void ll_ra_count_put(struct ll_sb_info *sbi, unsigned long pages)
 {
 	struct ll_ra_info *ra = &sbi->ll_ra_info;
 
-	atomic_sub(len, &ra->ra_cur_pages);
+	atomic_sub(pages, &ra->ra_cur_pages);
 }
 
 static void ll_ra_stats_inc_sbi(struct ll_sb_info *sbi, enum ra_stat which)
@@ -131,19 +132,20 @@ void ll_ra_stats_inc(struct inode *inode, enum ra_stat which)
 
 #define RAS_CDEBUG(ras) \
 	CDEBUG(D_READA,							     \
-	       "lre %lu cr %lu cb %lu ws %lu wl %lu nra %lu rpc %lu r %lu csr %lu sf %lu sb %lu sl %lu lr %lu\n", \
-	       ras->ras_last_read_end, ras->ras_consecutive_requests,	     \
-	       ras->ras_consecutive_bytes, ras->ras_window_start,	     \
-	       ras->ras_window_len, ras->ras_next_readahead,		     \
-	       ras->ras_rpc_size, ras->ras_requests,			     \
+	       "lre %llu cr %lu cb %llu wsi %lu wp %lu nra %lu rpc %lu r %lu csr %lu so %llu sb %llu sl %llu lr %lu\n", \
+	       ras->ras_last_read_end_bytes, ras->ras_consecutive_requests,  \
+	       ras->ras_consecutive_bytes, ras->ras_window_start_idx,	     \
+	       ras->ras_window_pages, ras->ras_next_readahead_idx,	     \
+	       ras->ras_rpc_pages, ras->ras_requests,			     \
 	       ras->ras_consecutive_stride_requests, ras->ras_stride_offset, \
 	       ras->ras_stride_bytes, ras->ras_stride_length,		     \
-	       ras->ras_async_last_readpage)
+	       ras->ras_async_last_readpage_idx)
 
-static int pos_in_window(unsigned long pos, unsigned long point,
-			 unsigned long before, unsigned long after)
+static bool pos_in_window(loff_t pos, loff_t point,
+			  unsigned long before, unsigned long after)
 {
-	unsigned long start = point - before, end = point + after;
+	loff_t start = point - before;
+	loff_t end = point + after;
 
 	if (start > point)
 		start = 0;
@@ -228,9 +230,9 @@ static int ll_read_ahead_page(const struct lu_env *env, struct cl_io *io,
 	return rc;
 }
 
-#define RIA_DEBUG(ria)						\
-	CDEBUG(D_READA, "rs %lu re %lu ro %lu rl %lu rb %lu\n",	\
-	       ria->ria_start, ria->ria_end, ria->ria_stoff,	\
+#define RIA_DEBUG(ria)							\
+	CDEBUG(D_READA, "rs %lu re %lu ro %llu rl %llu rb %llu\n",	\
+	       ria->ria_start_idx, ria->ria_end_idx, ria->ria_stoff,	\
 	       ria->ria_length, ria->ria_bytes)
 
 static inline int stride_io_mode(struct ll_readahead_state *ras)
@@ -238,7 +240,7 @@ static inline int stride_io_mode(struct ll_readahead_state *ras)
 	return ras->ras_consecutive_stride_requests > 1;
 }
 
-/* The function calculates how much pages will be read in
+/* The function calculates how many bytes will be read in
  * [off, off + length], in such stride IO area,
  * stride_offset = st_off, stride_length = st_len,
  * stride_bytes = st_bytes
@@ -256,31 +258,29 @@ static inline int stride_io_mode(struct ll_readahead_state *ras)
  *	  =   |<----->|  +  |-------------------------------------| +   |---|
  *	       start_left                 st_bytes * i                 end_left
  */
-static unsigned long
-stride_byte_count(unsigned long st_off, unsigned long st_len,
-		  unsigned long st_bytes, unsigned long off,
-		  unsigned long length)
+static loff_t stride_byte_count(loff_t st_off, loff_t st_len, loff_t st_bytes,
+				loff_t off, loff_t length)
 {
 	u64 start = off > st_off ? off - st_off : 0;
 	u64 end = off + length > st_off ? off + length - st_off : 0;
-	unsigned long start_left = 0;
-	unsigned long end_left = 0;
-	unsigned long bytes_count;
+	u64 start_left;
+	u64 end_left;
+	u64 bytes_count;
 
 	if (st_len == 0 || length == 0 || end == 0)
 		return length;
 
-	start_left = do_div(start, st_len);
+	start = div64_u64_rem(start, st_len, &start_left);
 	if (start_left < st_bytes)
 		start_left = st_bytes - start_left;
 	else
 		start_left = 0;
 
-	end_left = do_div(end, st_len);
+	end = div64_u64_rem(end, st_len, &end_left);
 	if (end_left > st_bytes)
 		end_left = st_bytes;
 
-	CDEBUG(D_READA, "start %llu, end %llu start_left %lu end_left %lu\n",
+	CDEBUG(D_READA, "start %llu, end %llu start_left %llu end_left %llu\n",
 	       start, end, start_left, end_left);
 
 	if (start == end)
@@ -290,48 +290,45 @@ static inline int stride_io_mode(struct ll_readahead_state *ras)
 			st_bytes * (end - start - 1) + end_left;
 
 	CDEBUG(D_READA,
-	       "st_off %lu, st_len %lu st_bytes %lu off %lu length %lu bytescount %lu\n",
+	       "st_off %llu, st_len %llu st_bytes %llu off %llu length %llu bytescount %llu\n",
 	       st_off, st_len, st_bytes, off, length, bytes_count);
 
 	return bytes_count;
 }
 
-static int ria_page_count(struct ra_io_arg *ria)
+static unsigned long ria_page_count(struct ra_io_arg *ria)
 {
-	u64 length_bytes = ria->ria_end >= ria->ria_start ?
-			   (ria->ria_end - ria->ria_start + 1) << PAGE_SHIFT : 0;
-	unsigned int bytes_count, pg_count;
+	loff_t length_bytes = ria->ria_end_idx >= ria->ria_start_idx ?
+			      (loff_t)(ria->ria_end_idx -
+				       ria->ria_start_idx + 1) << PAGE_SHIFT : 0;
+	loff_t bytes_count;
 
 	if (ria->ria_length > ria->ria_bytes && ria->ria_bytes &&
-	    (ria->ria_length % PAGE_SIZE || ria->ria_bytes % PAGE_SIZE ||
-	     ria->ria_stoff % PAGE_SIZE)) {
+	    (ria->ria_length & ~PAGE_SIZE || ria->ria_bytes & ~PAGE_SIZE ||
+	     ria->ria_stoff & ~PAGE_SIZE)) {
 		/* Over-estimate un-aligned page stride read */
-		pg_count = ((ria->ria_bytes + PAGE_SIZE - 1) >> PAGE_SHIFT) + 1;
-		pg_count *= length_bytes / ria->ria_length + 1;
+		unsigned long pg_count = ((ria->ria_bytes +
+					   PAGE_SIZE - 1) >> PAGE_SHIFT) + 1;
 
+		pg_count *= length_bytes / ria->ria_length + 1;
 		return pg_count;
 	}
 	bytes_count = stride_byte_count(ria->ria_stoff, ria->ria_length,
-					 ria->ria_bytes, ria->ria_start,
-					 length_bytes);
+					ria->ria_bytes,
+					(loff_t)ria->ria_start_idx << PAGE_SHIFT,
+					length_bytes);
 	return (bytes_count + PAGE_SIZE - 1) >> PAGE_SHIFT;
 }
 
-static unsigned long ras_align(struct ll_readahead_state *ras,
-			       pgoff_t index, unsigned long *remainder)
+static pgoff_t ras_align(struct ll_readahead_state *ras, pgoff_t index)
 {
-	unsigned long rem = index % ras->ras_rpc_size;
-
-	if (remainder)
-		*remainder = rem;
-	return index - rem;
+	return index - (index % ras->ras_rpc_pages);
 }
 
-/*Check whether the index is in the defined ra-window */
-static bool ras_inside_ra_window(unsigned long idx, struct ra_io_arg *ria)
+/* Check whether the index is in the defined ra-window */
+static bool ras_inside_ra_window(pgoff_t idx, struct ra_io_arg *ria)
 {
-	unsigned long pos = idx << PAGE_SHIFT;
-	unsigned long offset;
+	loff_t pos = (loff_t)idx << PAGE_SHIFT;
 
 	/* If ria_length == ria_pages, it means non-stride I/O mode,
 	 * idx should always inside read-ahead window in this case
@@ -342,12 +339,16 @@ static bool ras_inside_ra_window(unsigned long idx, struct ra_io_arg *ria)
 		return true;
 
 	if (pos >= ria->ria_stoff) {
-		offset = (pos - ria->ria_stoff) % ria->ria_length;
+		u64 offset;
+
+		div64_u64_rem(pos - ria->ria_stoff, ria->ria_length, &offset);
+
 		if (offset < ria->ria_bytes ||
 		    (ria->ria_length - offset) < PAGE_SIZE)
 			return true;
-	} else if (pos + PAGE_SIZE > ria->ria_stoff)
+	} else if (pos + PAGE_SIZE > ria->ria_stoff) {
 		return true;
+	}
 
 	return false;
 }
@@ -365,11 +366,12 @@ static bool ras_inside_ra_window(unsigned long idx, struct ra_io_arg *ria)
 	LASSERT(ria);
 	RIA_DEBUG(ria);
 
-	for (page_idx = ria->ria_start;
-	     page_idx <= ria->ria_end && ria->ria_reserved > 0; page_idx++) {
+	for (page_idx = ria->ria_start_idx;
+	     page_idx <= ria->ria_end_idx && ria->ria_reserved > 0;
+	     page_idx++) {
 		if (ras_inside_ra_window(page_idx, ria)) {
-			if (!ra.cra_end || ra.cra_end < page_idx) {
-				unsigned long end;
+			if (!ra.cra_end_idx || ra.cra_end_idx < page_idx) {
+				pgoff_t end_idx;
 
 				cl_read_ahead_release(env, &ra);
 
@@ -377,37 +379,40 @@ static bool ras_inside_ra_window(unsigned long idx, struct ra_io_arg *ria)
 				if (rc < 0)
 					break;
 
-				/* Do not shrink the ria_end at any case until
+				/* Do not shrink ria_end_idx@any case until
 				 * the minimum end of current read is covered.
-				 * And only shrink the ria_end if the matched
+				 * And only shrink ria_end_idx if the matched
 				 * LDLM lock doesn't cover more.
 				 */
-				if (page_idx > ra.cra_end ||
+				if (page_idx > ra.cra_end_idx ||
 				    (ra.cra_contention &&
-				     page_idx > ria->ria_end_min)) {
-					ria->ria_end = ra.cra_end;
+				     page_idx > ria->ria_end_idx_min)) {
+					ria->ria_end_idx = ra.cra_end_idx;
 					break;
 				}
 
 				CDEBUG(D_READA, "idx: %lu, ra: %lu, rpc: %lu\n",
-				       page_idx, ra.cra_end, ra.cra_rpc_size);
-				LASSERTF(ra.cra_end >= page_idx,
+				       page_idx, ra.cra_end_idx,
+				       ra.cra_rpc_pages);
+				LASSERTF(ra.cra_end_idx >= page_idx,
 					 "object: %p, indcies %lu / %lu\n",
-					 io->ci_obj, ra.cra_end, page_idx);
+					 io->ci_obj, ra.cra_end_idx, page_idx);
 				/*
 				 * update read ahead RPC size.
 				 * NB: it's racy but doesn't matter
 				 */
-				if (ras->ras_rpc_size != ra.cra_rpc_size &&
-				    ra.cra_rpc_size > 0)
-					ras->ras_rpc_size = ra.cra_rpc_size;
+				if (ras->ras_rpc_pages != ra.cra_rpc_pages &&
+				    ra.cra_rpc_pages > 0)
+					ras->ras_rpc_pages = ra.cra_rpc_pages;
 				/* trim it to align with optimal RPC size */
-				end = ras_align(ras, ria->ria_end + 1, NULL);
-				if (end > 0 && !ria->ria_eof)
-					ria->ria_end = end - 1;
-				if (ria->ria_end < ria->ria_end_min)
-					ria->ria_end = ria->ria_end_min;
+				end_idx = ras_align(ras, ria->ria_end_idx + 1);
+				if (end_idx > 0 && !ria->ria_eof)
+					ria->ria_end_idx = end_idx - 1;
+				if (ria->ria_end_idx < ria->ria_end_idx_min)
+					ria->ria_end_idx = ria->ria_end_idx_min;
 			}
+			if (page_idx > ria->ria_end_idx)
+				break;
 
 			/* If the page is inside the read-ahead window */
 			rc = ll_read_ahead_page(env, io, queue, page_idx);
@@ -427,16 +432,17 @@ static bool ras_inside_ra_window(unsigned long idx, struct ra_io_arg *ria)
 			 * read-ahead mode, then check whether it should skip
 			 * the stride gap.
 			 */
-			unsigned long offset;
-			unsigned long pos = page_idx << PAGE_SHIFT;
+			loff_t pos = (loff_t)page_idx << PAGE_SHIFT;
+			u64 offset;
 
-			offset = (pos - ria->ria_stoff) % ria->ria_length;
+			div64_u64_rem(pos - ria->ria_stoff, ria->ria_length,
+				      &offset);
 			if (offset >= ria->ria_bytes) {
 				pos += (ria->ria_length - offset);
 				if ((pos >> PAGE_SHIFT) >= page_idx + 1)
 					page_idx = (pos >> PAGE_SHIFT) - 1;
 				CDEBUG(D_READA,
-				       "Stride: jump %lu pages to %lu\n",
+				       "Stride: jump %llu pages to %lu\n",
 				       ria->ria_length - offset, page_idx);
 				continue;
 			}
@@ -495,12 +501,12 @@ static void ll_readahead_handle_work(struct work_struct *wq)
 	struct ll_readahead_state *ras;
 	struct cl_io *io;
 	struct cl_2queue *queue;
-	pgoff_t ra_end = 0;
-	unsigned long len, mlen = 0;
+	pgoff_t ra_end_idx = 0;
+	unsigned long pages, pages_min = 0;
 	struct file *file;
 	u64 kms;
 	int rc;
-	unsigned long end_index;
+	pgoff_t eof_index;
 
 	work = container_of(wq, struct ll_readahead_work,
 			    lrw_readahead_work);
@@ -531,30 +537,30 @@ static void ll_readahead_handle_work(struct work_struct *wq)
 	ria = &ll_env_info(env)->lti_ria;
 	memset(ria, 0, sizeof(*ria));
 
-	ria->ria_start = work->lrw_start;
+	ria->ria_start_idx = work->lrw_start_idx;
 	/* Truncate RA window to end of file */
-	end_index = (unsigned long)((kms - 1) >> PAGE_SHIFT);
-	if (end_index <= work->lrw_end) {
-		work->lrw_end = end_index;
+	eof_index = (pgoff_t)(kms - 1) >> PAGE_SHIFT;
+	if (eof_index <= work->lrw_end_idx) {
+		work->lrw_end_idx = eof_index;
 		ria->ria_eof = true;
 	}
-	if (work->lrw_end <= work->lrw_start) {
+	if (work->lrw_end_idx <= work->lrw_start_idx) {
 		rc = 0;
 		goto out_put_env;
 	}
 
-	ria->ria_end = work->lrw_end;
-	len = ria->ria_end - ria->ria_start + 1;
+	ria->ria_end_idx = work->lrw_end_idx;
+	pages = ria->ria_end_idx - ria->ria_start_idx + 1;
 	ria->ria_reserved = ll_ra_count_get(ll_i2sbi(inode), ria,
-					    ria_page_count(ria), mlen);
+					    ria_page_count(ria), pages_min);
 
 	CDEBUG(D_READA,
 	       "async reserved pages: %lu/%lu/%lu, ra_cur %d, ra_max %lu\n",
-	       ria->ria_reserved, len, mlen,
+	       ria->ria_reserved, pages, pages_min,
 	       atomic_read(&ll_i2sbi(inode)->ll_ra_info.ra_cur_pages),
 	       ll_i2sbi(inode)->ll_ra_info.ra_max_pages);
 
-	if (ria->ria_reserved < len) {
+	if (ria->ria_reserved < pages) {
 		ll_ra_stats_inc(inode, RA_STAT_MAX_IN_FLIGHT);
 		if (PAGES_TO_MiB(ria->ria_reserved) < 1) {
 			ll_ra_count_put(ll_i2sbi(inode), ria->ria_reserved);
@@ -563,7 +569,7 @@ static void ll_readahead_handle_work(struct work_struct *wq)
 		}
 	}
 
-	rc = cl_io_rw_init(env, io, CIT_READ, ria->ria_start, len);
+	rc = cl_io_rw_init(env, io, CIT_READ, ria->ria_start_idx, pages);
 	if (rc)
 		goto out_put_env;
 
@@ -577,7 +583,8 @@ static void ll_readahead_handle_work(struct work_struct *wq)
 	queue = &io->ci_queue;
 	cl_2queue_init(queue);
 
-	rc = ll_read_ahead_pages(env, io, &queue->c2_qin, ras, ria, &ra_end);
+	rc = ll_read_ahead_pages(env, io, &queue->c2_qin, ras, ria,
+				 &ra_end_idx);
 	if (ria->ria_reserved != 0)
 		ll_ra_count_put(ll_i2sbi(inode), ria->ria_reserved);
 	if (queue->c2_qin.pl_nr > 0) {
@@ -587,10 +594,10 @@ static void ll_readahead_handle_work(struct work_struct *wq)
 		if (rc == 0)
 			task_io_account_read(PAGE_SIZE * count);
 	}
-	if (ria->ria_end == ra_end && ra_end == (kms >> PAGE_SHIFT))
+	if (ria->ria_end_idx == ra_end_idx && ra_end_idx == (kms >> PAGE_SHIFT))
 		ll_ra_stats_inc(inode, RA_STAT_EOF);
 
-	if (ra_end != ria->ria_end)
+	if (ra_end_idx != ria->ria_end_idx)
 		ll_ra_stats_inc(inode, RA_STAT_FAILED_REACH_END);
 
 	/* TODO: discard all pages until page reinit route is implemented */
@@ -606,7 +613,7 @@ static void ll_readahead_handle_work(struct work_struct *wq)
 out_put_env:
 	cl_env_put(env, &refcheck);
 out_free_work:
-	if (ra_end > 0)
+	if (ra_end_idx > 0)
 		ll_ra_stats_inc_sbi(ll_i2sbi(inode), RA_STAT_ASYNC);
 	ll_readahead_work_free(work);
 }
@@ -618,8 +625,8 @@ static int ll_readahead(const struct lu_env *env, struct cl_io *io,
 {
 	struct vvp_io *vio = vvp_env_io(env);
 	struct ll_thread_info *lti = ll_env_info(env);
-	unsigned long len, mlen = 0;
-	pgoff_t ra_end = 0, start = 0, end = 0;
+	unsigned long pages, pages_min = 0;
+	pgoff_t ra_end_idx = 0, start_idx = 0, end_idx = 0;
 	struct inode *inode;
 	struct ra_io_arg *ria = &lti->lti_ria;
 	struct cl_object *clob;
@@ -642,39 +649,38 @@ static int ll_readahead(const struct lu_env *env, struct cl_io *io,
 	spin_lock(&ras->ras_lock);
 
 	/**
-	 * Note: other thread might rollback the ras_next_readahead,
+	 * Note: other thread might rollback the ras_next_readahead_idx,
 	 * if it can not get the full size of prepared pages, see the
 	 * end of this function. For stride read ahead, it needs to
 	 * make sure the offset is no less than ras_stride_offset,
 	 * so that stride read ahead can work correctly.
 	 */
 	if (stride_io_mode(ras))
-		start = max(ras->ras_next_readahead,
-			    ras->ras_stride_offset >> PAGE_SHIFT);
+		start_idx = max_t(pgoff_t, ras->ras_next_readahead_idx,
+				  ras->ras_stride_offset >> PAGE_SHIFT);
 	else
-		start = ras->ras_next_readahead;
+		start_idx = ras->ras_next_readahead_idx;
 
-	if (ras->ras_window_len > 0)
-		end = ras->ras_window_start + ras->ras_window_len - 1;
+	if (ras->ras_window_pages > 0)
+		end_idx = ras->ras_window_start_idx + ras->ras_window_pages - 1;
 
 	/* Enlarge the RA window to encompass the full read */
 	if (vio->vui_ra_valid &&
-	    end < vio->vui_ra_start + vio->vui_ra_count - 1)
-		end = vio->vui_ra_start + vio->vui_ra_count - 1;
+	    end_idx < vio->vui_ra_start_idx + vio->vui_ra_pages - 1)
+		end_idx = vio->vui_ra_start_idx + vio->vui_ra_pages - 1;
 
-	if (end) {
-		unsigned long end_index;
+	if (end_idx) {
+		pgoff_t eof_index;
 
 		/* Truncate RA window to end of file */
-		end_index = (unsigned long)((kms - 1) >> PAGE_SHIFT);
-		if (end_index <= end) {
-			end = end_index;
+		eof_index = (pgoff_t)((kms - 1) >> PAGE_SHIFT);
+		if (eof_index <= end_idx) {
+			end_idx = eof_index;
 			ria->ria_eof = true;
 		}
 	}
-
-	ria->ria_start = start;
-	ria->ria_end = end;
+	ria->ria_start_idx = start_idx;
+	ria->ria_end_idx = end_idx;
 	/* If stride I/O mode is detected, get stride window*/
 	if (stride_io_mode(ras)) {
 		ria->ria_stoff = ras->ras_stride_offset;
@@ -683,12 +689,12 @@ static int ll_readahead(const struct lu_env *env, struct cl_io *io,
 	}
 	spin_unlock(&ras->ras_lock);
 
-	if (end == 0) {
+	if (end_idx == 0) {
 		ll_ra_stats_inc(inode, RA_STAT_ZERO_WINDOW);
 		return 0;
 	}
-	len = ria_page_count(ria);
-	if (len == 0) {
+	pages = ria_page_count(ria);
+	if (pages == 0) {
 		ll_ra_stats_inc(inode, RA_STAT_ZERO_WINDOW);
 		return 0;
 	}
@@ -696,45 +702,48 @@ static int ll_readahead(const struct lu_env *env, struct cl_io *io,
 	RAS_CDEBUG(ras);
 	CDEBUG(D_READA, DFID ": ria: %lu/%lu, bead: %lu/%lu, hit: %d\n",
 	       PFID(lu_object_fid(&clob->co_lu)),
-	       ria->ria_start, ria->ria_end,
-	       vio->vui_ra_valid ? vio->vui_ra_start : 0,
-	       vio->vui_ra_valid ? vio->vui_ra_count : 0,
+	       ria->ria_start_idx, ria->ria_end_idx,
+	       vio->vui_ra_valid ? vio->vui_ra_start_idx : 0,
+	       vio->vui_ra_valid ? vio->vui_ra_pages : 0,
 	       hit);
 
 	/* at least to extend the readahead window to cover current read */
 	if (!hit && vio->vui_ra_valid &&
-	    vio->vui_ra_start + vio->vui_ra_count > ria->ria_start)
-		ria->ria_end_min = vio->vui_ra_start + vio->vui_ra_count - 1;
+	    vio->vui_ra_start_idx + vio->vui_ra_pages > ria->ria_start_idx)
+		ria->ria_end_idx_min =
+			vio->vui_ra_start_idx + vio->vui_ra_pages - 1;
 
-	ria->ria_reserved = ll_ra_count_get(ll_i2sbi(inode), ria, len, mlen);
-	if (ria->ria_reserved < len)
+	ria->ria_reserved = ll_ra_count_get(ll_i2sbi(inode), ria, pages,
+					    pages_min);
+	if (ria->ria_reserved < pages)
 		ll_ra_stats_inc(inode, RA_STAT_MAX_IN_FLIGHT);
 
-	CDEBUG(D_READA, "reserved pages %lu/%lu/%lu, ra_cur %d, ra_max %lu\n",
-	       ria->ria_reserved, len, mlen,
+	CDEBUG(D_READA, "reserved pages: %lu/%lu/%lu, ra_cur %d, ra_max %lu\n",
+	       ria->ria_reserved, pages, pages_min,
 	       atomic_read(&ll_i2sbi(inode)->ll_ra_info.ra_cur_pages),
 	       ll_i2sbi(inode)->ll_ra_info.ra_max_pages);
 
-	ret = ll_read_ahead_pages(env, io, queue, ras, ria, &ra_end);
+	ret = ll_read_ahead_pages(env, io, queue, ras, ria, &ra_end_idx);
 
 	if (ria->ria_reserved)
 		ll_ra_count_put(ll_i2sbi(inode), ria->ria_reserved);
 
-	if (ra_end == end && ra_end == (kms >> PAGE_SHIFT))
+	if (ra_end_idx == end_idx && ra_end_idx == (kms >> PAGE_SHIFT))
 		ll_ra_stats_inc(inode, RA_STAT_EOF);
 
-	CDEBUG(D_READA, "ra_end = %lu end = %lu stride end = %lu pages = %d\n",
-	       ra_end, end, ria->ria_end, ret);
+	CDEBUG(D_READA,
+	       "ra_end_idx = %lu end_idx = %lu stride end = %lu pages = %d\n",
+	       ra_end_idx, end_idx, ria->ria_end_idx, ret);
 
-	if (ra_end != end)
+	if (ra_end_idx != end_idx)
 		ll_ra_stats_inc(inode, RA_STAT_FAILED_REACH_END);
 
-	if (ra_end > 0) {
+	if (ra_end_idx > 0) {
 		/* update the ras so that the next read-ahead tries from
 		 * where we left off.
 		 */
 		spin_lock(&ras->ras_lock);
-		ras->ras_next_readahead = ra_end + 1;
+		ras->ras_next_readahead_idx = ra_end_idx + 1;
 		spin_unlock(&ras->ras_lock);
 		RAS_CDEBUG(ras);
 	}
@@ -744,7 +753,7 @@ static int ll_readahead(const struct lu_env *env, struct cl_io *io,
 
 static void ras_set_start(struct ll_readahead_state *ras, pgoff_t index)
 {
-	ras->ras_window_start = ras_align(ras, index, NULL);
+	ras->ras_window_start_idx = ras_align(ras, index);
 }
 
 /* called with the ras_lock held or from places where it doesn't matter */
@@ -752,9 +761,9 @@ static void ras_reset(struct ll_readahead_state *ras, pgoff_t index)
 {
 	ras->ras_consecutive_requests = 0;
 	ras->ras_consecutive_bytes = 0;
-	ras->ras_window_len = 0;
+	ras->ras_window_pages = 0;
 	ras_set_start(ras, index);
-	ras->ras_next_readahead = max(ras->ras_window_start, index + 1);
+	ras->ras_next_readahead_idx = max(ras->ras_window_start_idx, index + 1);
 
 	RAS_CDEBUG(ras);
 }
@@ -771,9 +780,9 @@ static void ras_stride_reset(struct ll_readahead_state *ras)
 void ll_readahead_init(struct inode *inode, struct ll_readahead_state *ras)
 {
 	spin_lock_init(&ras->ras_lock);
-	ras->ras_rpc_size = PTLRPC_MAX_BRW_PAGES;
+	ras->ras_rpc_pages = PTLRPC_MAX_BRW_PAGES;
 	ras_reset(ras, 0);
-	ras->ras_last_read_end = 0;
+	ras->ras_last_read_end_bytes = 0;
 	ras->ras_requests = 0;
 }
 
@@ -782,15 +791,15 @@ void ll_readahead_init(struct inode *inode, struct ll_readahead_state *ras)
  * If it is in the stride window, return true, otherwise return false.
  */
 static bool read_in_stride_window(struct ll_readahead_state *ras,
-				  unsigned long pos, unsigned long count)
+				  loff_t pos, loff_t count)
 {
-	unsigned long stride_gap;
+	loff_t stride_gap;
 
 	if (ras->ras_stride_length == 0 || ras->ras_stride_bytes == 0 ||
 	    ras->ras_stride_bytes == ras->ras_stride_length)
 		return false;
 
-	stride_gap = pos - ras->ras_last_read_end - 1;
+	stride_gap = pos - ras->ras_last_read_end_bytes - 1;
 
 	/* If it is contiguous read */
 	if (stride_gap == 0)
@@ -804,13 +813,13 @@ static bool read_in_stride_window(struct ll_readahead_state *ras,
 }
 
 static void ras_init_stride_detector(struct ll_readahead_state *ras,
-				     unsigned long pos, unsigned long count)
+				     loff_t pos, loff_t count)
 {
-	unsigned long stride_gap = pos - ras->ras_last_read_end - 1;
+	loff_t stride_gap = pos - ras->ras_last_read_end_bytes - 1;
 
 	LASSERT(ras->ras_consecutive_stride_requests == 0);
 
-	if (pos <= ras->ras_last_read_end) {
+	if (pos <= ras->ras_last_read_end_bytes) {
 		/*Reset stride window for forward read*/
 		ras_stride_reset(ras);
 		return;
@@ -828,47 +837,50 @@ static void ras_init_stride_detector(struct ll_readahead_state *ras,
  * stride I/O pattern
  */
 static void ras_stride_increase_window(struct ll_readahead_state *ras,
-				       struct ll_ra_info *ra,
-				       unsigned long inc_len)
+				       struct ll_ra_info *ra, loff_t inc_bytes)
 {
-	unsigned long left, step, window_len;
-	unsigned long stride_len;
-	unsigned long end = ras->ras_window_start + ras->ras_window_len;
+	loff_t window_bytes, stride_bytes;
+	u64 left_bytes;
+	u64 step;
+	loff_t end;
+
+	/* temporarily store in page units to reduce LASSERT() cost below */
+	end = ras->ras_window_start_idx + ras->ras_window_pages;
 
 	LASSERT(ras->ras_stride_length > 0);
 	LASSERTF(end >= (ras->ras_stride_offset >> PAGE_SHIFT),
-		 "window_start %lu, window_len %lu stride_offset %lu\n",
-		 ras->ras_window_start, ras->ras_window_len,
+		 "window_start_idx %lu, window_pages %lu stride_offset %llu\n",
+		 ras->ras_window_start_idx, ras->ras_window_pages,
 		 ras->ras_stride_offset);
 
 	end <<= PAGE_SHIFT;
-	if (end < ras->ras_stride_offset)
-		stride_len = 0;
+	if (end <= ras->ras_stride_offset)
+		stride_bytes = 0;
 	else
-		stride_len = end - ras->ras_stride_offset;
+		stride_bytes = end - ras->ras_stride_offset;
 
-	left = stride_len % ras->ras_stride_length;
-	window_len = (ras->ras_window_len << PAGE_SHIFT) - left;
+	div64_u64_rem(stride_bytes, ras->ras_stride_length, &left_bytes);
+	window_bytes = ((loff_t)ras->ras_window_pages << PAGE_SHIFT) -
+		       left_bytes;
 
-	if (left < ras->ras_stride_bytes)
-		left += inc_len;
+	if (left_bytes < ras->ras_stride_bytes)
+		left_bytes += inc_bytes;
 	else
-		left = ras->ras_stride_bytes + inc_len;
+		left_bytes = ras->ras_stride_bytes + inc_bytes;
 
 	LASSERT(ras->ras_stride_bytes != 0);
 
-	step = left / ras->ras_stride_bytes;
-	left %= ras->ras_stride_bytes;
+	step = div64_u64_rem(left_bytes, ras->ras_stride_bytes, &left_bytes);
 
-	window_len += step * ras->ras_stride_length + left;
+	window_bytes += step * ras->ras_stride_length + left_bytes;
 
 	if (DIV_ROUND_UP(stride_byte_count(ras->ras_stride_offset,
 					   ras->ras_stride_length,
 					   ras->ras_stride_bytes,
 					   ras->ras_stride_offset,
-					   window_len), PAGE_SIZE)
+					   window_bytes), PAGE_SIZE)
 	    <= ra->ra_max_pages_per_file)
-		ras->ras_window_len = (window_len >> PAGE_SHIFT);
+		ras->ras_window_pages = (window_bytes >> PAGE_SHIFT);
 
 	RAS_CDEBUG(ras);
 }
@@ -883,36 +895,34 @@ static void ras_increase_window(struct inode *inode,
 	 */
 	if (stride_io_mode(ras)) {
 		ras_stride_increase_window(ras, ra,
-				ras->ras_rpc_size << PAGE_SHIFT);
+					   (loff_t)ras->ras_rpc_pages << PAGE_SHIFT);
 	} else {
-		unsigned long wlen;
+		pgoff_t window_pages;
 
-		wlen = min(ras->ras_window_len + ras->ras_rpc_size,
-			   ra->ra_max_pages_per_file);
-		if (wlen < ras->ras_rpc_size)
-			ras->ras_window_len = wlen;
+		window_pages = min(ras->ras_window_pages + ras->ras_rpc_pages,
+				   ra->ra_max_pages_per_file);
+		if (window_pages < ras->ras_rpc_pages)
+			ras->ras_window_pages = window_pages;
 		else
-			ras->ras_window_len = ras_align(ras, wlen, NULL);
+			ras->ras_window_pages = ras_align(ras, window_pages);
 	}
 }
 
 /**
  * Seek within 8 pages are considered as sequential read for now.
  */
-static inline bool is_loose_seq_read(struct ll_readahead_state *ras,
-				     unsigned long pos)
+static inline bool is_loose_seq_read(struct ll_readahead_state *ras, loff_t pos)
 {
-	return pos_in_window(pos, ras->ras_last_read_end,
-			     8 << PAGE_SHIFT, 8 << PAGE_SHIFT);
+	return pos_in_window(pos, ras->ras_last_read_end_bytes,
+			     8UL << PAGE_SHIFT, 8UL << PAGE_SHIFT);
 }
 
 static void ras_detect_read_pattern(struct ll_readahead_state *ras,
 				    struct ll_sb_info *sbi,
-				    unsigned long pos, unsigned long count,
-				    bool mmap)
+				    loff_t pos, size_t count, bool mmap)
 {
 	bool stride_detect = false;
-	unsigned long index = pos >> PAGE_SHIFT;
+	pgoff_t index = pos >> PAGE_SHIFT;
 
 	/*
 	 * Reset the read-ahead window in two cases. First when the app seeks
@@ -947,25 +957,25 @@ static void ras_detect_read_pattern(struct ll_readahead_state *ras,
 		 */
 		if (!read_in_stride_window(ras, pos, count)) {
 			ras_stride_reset(ras);
-			ras->ras_window_len = 0;
-			ras->ras_next_readahead = index;
+			ras->ras_window_pages = 0;
+			ras->ras_next_readahead_idx = index;
 		}
 	}
 
 	ras->ras_consecutive_bytes += count;
 	if (mmap) {
-		unsigned int idx = (ras->ras_consecutive_bytes >> PAGE_SHIFT);
+		pgoff_t idx = ras->ras_consecutive_bytes >> PAGE_SHIFT;
 
-		if ((idx >= 4 && idx % 4 == 0) || stride_detect)
+		if ((idx >= 4 && (idx & 3UL) == 0) || stride_detect)
 			ras->ras_need_increase_window = true;
 	} else if ((ras->ras_consecutive_requests > 1 || stride_detect)) {
 		ras->ras_need_increase_window = true;
 	}
 
-	ras->ras_last_read_end = pos + count - 1;
+	ras->ras_last_read_end_bytes = pos + count - 1;
 }
 
-void ll_ras_enter(struct file *f, unsigned long pos, unsigned long count)
+void ll_ras_enter(struct file *f, loff_t pos, size_t count)
 {
 	struct ll_file_data *fd = LUSTRE_FPRIVATE(f);
 	struct ll_readahead_state *ras = &fd->fd_ras;
@@ -998,10 +1008,10 @@ void ll_ras_enter(struct file *f, unsigned long pos, unsigned long count)
 
 		if (kms_pages &&
 		    kms_pages <= ra->ra_max_read_ahead_whole_pages) {
-			ras->ras_window_start = 0;
-			ras->ras_next_readahead = index + 1;
-			ras->ras_window_len = min(ra->ra_max_pages_per_file,
-						  ra->ra_max_read_ahead_whole_pages);
+			ras->ras_window_start_idx = 0;
+			ras->ras_next_readahead_idx = index + 1;
+			ras->ras_window_pages = min(ra->ra_max_pages_per_file,
+						    ra->ra_max_read_ahead_whole_pages);
 			ras->ras_no_miss_check = true;
 			goto out_unlock;
 		}
@@ -1012,18 +1022,19 @@ void ll_ras_enter(struct file *f, unsigned long pos, unsigned long count)
 }
 
 static bool index_in_stride_window(struct ll_readahead_state *ras,
-				   unsigned int index)
+				   pgoff_t index)
 {
-	unsigned long pos = index << PAGE_SHIFT;
-	unsigned long offset;
+	loff_t pos = (loff_t)index << PAGE_SHIFT;
 
 	if (ras->ras_stride_length == 0 || ras->ras_stride_bytes == 0 ||
 	    ras->ras_stride_bytes == ras->ras_stride_length)
 		return false;
 
 	if (pos >= ras->ras_stride_offset) {
-		offset = (pos - ras->ras_stride_offset) %
-			 ras->ras_stride_length;
+		u64 offset;
+
+		div64_u64_rem(pos - ras->ras_stride_offset,
+			      ras->ras_stride_length, &offset);
 		if (offset < ras->ras_stride_bytes ||
 		    ras->ras_stride_length - offset < PAGE_SIZE)
 			return true;
@@ -1035,14 +1046,13 @@ static bool index_in_stride_window(struct ll_readahead_state *ras,
 }
 
 /*
- * ll_ras_enter() is used to detect read pattern according to
- * pos and count.
+ * ll_ras_enter() is used to detect read pattern according to pos and count.
  *
  * ras_update() is used to detect cache miss and
  * reset window or increase window accordingly
  */
 static void ras_update(struct ll_sb_info *sbi, struct inode *inode,
-		       struct ll_readahead_state *ras, unsigned long index,
+		       struct ll_readahead_state *ras, pgoff_t index,
 		       enum ras_update_flags flags)
 {
 	struct ll_ra_info *ra = &sbi->ll_ra_info;
@@ -1065,13 +1075,13 @@ static void ras_update(struct ll_sb_info *sbi, struct inode *inode,
 		goto out_unlock;
 
 	if (flags & LL_RAS_MMAP)
-		ras_detect_read_pattern(ras, sbi, index << PAGE_SHIFT,
+		ras_detect_read_pattern(ras, sbi, (loff_t)index << PAGE_SHIFT,
 					PAGE_SIZE, true);
 
-	if (!hit && ras->ras_window_len &&
-	    index < ras->ras_next_readahead &&
-	    pos_in_window(index, ras->ras_window_start, 0,
-			  ras->ras_window_len)) {
+	if (!hit && ras->ras_window_pages &&
+	    index < ras->ras_next_readahead_idx &&
+	    pos_in_window(index, ras->ras_window_start_idx, 0,
+			  ras->ras_window_pages)) {
 		ll_ra_stats_inc_sbi(sbi, RA_STAT_MISS_IN_WINDOW);
 		ras->ras_need_increase_window = false;
 
@@ -1090,8 +1100,7 @@ static void ras_update(struct ll_sb_info *sbi, struct inode *inode,
 			 * is still intersect with normal sequential
 			 * read-ahead window.
 			 */
-			if (ras->ras_window_start <
-			    ras->ras_stride_offset)
+			if (ras->ras_window_start_idx < ras->ras_stride_offset)
 				ras_stride_reset(ras);
 			RAS_CDEBUG(ras);
 		} else {
@@ -1111,18 +1120,18 @@ static void ras_update(struct ll_sb_info *sbi, struct inode *inode,
 	if (stride_io_mode(ras)) {
 		/* Since stride readahead is sensitive to the offset
 		 * of read-ahead, so we use original offset here,
-		 * instead of ras_window_start, which is RPC aligned
+		 * instead of ras_window_start_idx, which is RPC aligned.
 		 */
-		ras->ras_next_readahead = max(index + 1,
-					      ras->ras_next_readahead);
-		ras->ras_window_start =
-				max(ras->ras_stride_offset >> PAGE_SHIFT,
-				    ras->ras_window_start);
+		ras->ras_next_readahead_idx = max(index + 1,
+						  ras->ras_next_readahead_idx);
+		ras->ras_window_start_idx =
+				max_t(pgoff_t, ras->ras_window_start_idx,
+				      ras->ras_stride_offset >> PAGE_SHIFT);
 	} else {
-		if (ras->ras_next_readahead < ras->ras_window_start)
-			ras->ras_next_readahead = ras->ras_window_start;
+		if (ras->ras_next_readahead_idx < ras->ras_window_start_idx)
+			ras->ras_next_readahead_idx = ras->ras_window_start_idx;
 		if (!hit)
-			ras->ras_next_readahead = index + 1;
+			ras->ras_next_readahead_idx = index + 1;
 	}
 
 	if (ras->ras_need_increase_window) {
@@ -1241,7 +1250,7 @@ int ll_writepages(struct address_space *mapping, struct writeback_control *wbc)
 	int result;
 
 	if (wbc->range_cyclic) {
-		start = mapping->writeback_index << PAGE_SHIFT;
+		start = (loff_t)mapping->writeback_index << PAGE_SHIFT;
 		end = OBD_OBJECT_EOF;
 	} else {
 		start = wbc->range_start;
@@ -1429,8 +1438,8 @@ static int kickoff_async_readahead(struct file *file, unsigned long pages)
 	struct ll_readahead_state *ras = &fd->fd_ras;
 	struct ll_ra_info *ra = &sbi->ll_ra_info;
 	unsigned long throttle;
-	unsigned long start = ras_align(ras, ras->ras_next_readahead, NULL);
-	unsigned long end = start + pages - 1;
+	pgoff_t start_idx = ras_align(ras, ras->ras_next_readahead_idx);
+	pgoff_t end_idx = start_idx + pages - 1;
 
 	throttle = min(ra->ra_async_pages_per_file_threshold,
 		       ra->ra_max_pages_per_file);
@@ -1440,24 +1449,24 @@ static int kickoff_async_readahead(struct file *file, unsigned long pages)
 	 * we do async readahead, allowing the user thread to do fast i/o.
 	 */
 	if (stride_io_mode(ras) || !throttle ||
-	    ras->ras_window_len < throttle)
+	    ras->ras_window_pages < throttle)
 		return 0;
 
 	if ((atomic_read(&ra->ra_cur_pages) + pages) > ra->ra_max_pages)
 		return 0;
 
-	if (ras->ras_async_last_readpage == start)
+	if (ras->ras_async_last_readpage_idx == start_idx)
 		return 1;
 
 	/* ll_readahead_work_free() free it */
 	lrw = kzalloc(sizeof(*lrw), GFP_NOFS);
 	if (lrw) {
 		lrw->lrw_file = get_file(file);
-		lrw->lrw_start = start;
-		lrw->lrw_end = end;
+		lrw->lrw_start_idx = start_idx;
+		lrw->lrw_end_idx = end_idx;
 		spin_lock(&ras->ras_lock);
-		ras->ras_next_readahead = end + 1;
-		ras->ras_async_last_readpage = start;
+		ras->ras_next_readahead_idx = end_idx + 1;
+		ras->ras_async_last_readpage_idx = start_idx;
 		spin_unlock(&ras->ras_lock);
 		ll_readahead_work_add(inode, lrw);
 	} else {
@@ -1489,7 +1498,7 @@ int ll_readpage(struct file *file, struct page *vmpage)
 		struct lu_env *local_env = NULL;
 		struct inode *inode = file_inode(file);
 		unsigned long fast_read_pages =
-			max(RA_REMAIN_WINDOW_MIN, ras->ras_rpc_size);
+			max(RA_REMAIN_WINDOW_MIN, ras->ras_rpc_pages);
 		struct vvp_page *vpg;
 
 		result = -ENODATA;
@@ -1526,8 +1535,8 @@ int ll_readpage(struct file *file, struct page *vmpage)
 			 * the case, we can't do fast IO because we will need
 			 * a cl_io to issue the RPC.
 			 */
-			if (ras->ras_window_start + ras->ras_window_len <
-			    ras->ras_next_readahead + fast_read_pages ||
+			if (ras->ras_window_start_idx + ras->ras_window_pages <
+			    ras->ras_next_readahead_idx + fast_read_pages ||
 			    kickoff_async_readahead(file, fast_read_pages) > 0)
 				result = 0;
 		}
diff --git a/fs/lustre/llite/vvp_internal.h b/fs/lustre/llite/vvp_internal.h
index 1cc152f..0382b79 100644
--- a/fs/lustre/llite/vvp_internal.h
+++ b/fs/lustre/llite/vvp_internal.h
@@ -103,8 +103,8 @@ struct vvp_io {
 	struct kiocb		*vui_iocb;
 
 	/* Readahead state. */
-	pgoff_t			vui_ra_start;
-	pgoff_t			vui_ra_count;
+	pgoff_t			vui_ra_start_idx;
+	pgoff_t			vui_ra_pages;
 	/* Set when vui_ra_{start,count} have been initialized. */
 	bool			vui_ra_valid;
 };
diff --git a/fs/lustre/llite/vvp_io.c b/fs/lustre/llite/vvp_io.c
index 259b14a..cf116be 100644
--- a/fs/lustre/llite/vvp_io.c
+++ b/fs/lustre/llite/vvp_io.c
@@ -739,8 +739,8 @@ static int vvp_io_read_start(const struct lu_env *env,
 	struct file *file = vio->vui_fd->fd_file;
 	int result;
 	loff_t pos = io->u.ci_rd.rd.crw_pos;
-	long cnt = io->u.ci_rd.rd.crw_count;
-	long tot = vio->vui_tot_count;
+	size_t cnt = io->u.ci_rd.rd.crw_count;
+	size_t tot = vio->vui_tot_count;
 	int exceed = 0;
 
 	CLOBINVRNT(env, obj, vvp_object_invariant(obj));
@@ -776,16 +776,16 @@ static int vvp_io_read_start(const struct lu_env *env,
 	/* initialize read-ahead window once per syscall */
 	if (!vio->vui_ra_valid) {
 		vio->vui_ra_valid = true;
-		vio->vui_ra_start = cl_index(obj, pos);
-		vio->vui_ra_count = cl_index(obj, tot + PAGE_SIZE - 1);
+		vio->vui_ra_start_idx = cl_index(obj, pos);
+		vio->vui_ra_pages = cl_index(obj, tot + PAGE_SIZE - 1);
 		/* If both start and end are unaligned, we read one more page
 		 * than the index math suggests.
 		 */
-		if (pos % PAGE_SIZE != 0 && (pos + tot) % PAGE_SIZE != 0)
-			vio->vui_ra_count++;
+		if ((pos & ~PAGE_MASK) != 0 && ((pos + tot) & ~PAGE_MASK) != 0)
+			vio->vui_ra_pages++;
 
-		CDEBUG(D_READA, "tot %ld, ra_start %lu, ra_count %lu\n", tot,
-		       vio->vui_ra_start, vio->vui_ra_count);
+		CDEBUG(D_READA, "tot %zu, ra_start %lu, ra_count %lu\n",
+		       tot, vio->vui_ra_start_idx, vio->vui_ra_pages);
 	}
 
 	/* BUG: 5972 */
@@ -1424,7 +1424,7 @@ static int vvp_io_read_ahead(const struct lu_env *env,
 		struct vvp_io *vio = cl2vvp_io(env, ios);
 
 		if (unlikely(vio->vui_fd->fd_flags & LL_FILE_GROUP_LOCKED)) {
-			ra->cra_end = CL_PAGE_EOF;
+			ra->cra_end_idx = CL_PAGE_EOF;
 			result = 1; /* no need to call down */
 		}
 	}
diff --git a/fs/lustre/lov/lov_io.c b/fs/lustre/lov/lov_io.c
index 971f9ba..019e986 100644
--- a/fs/lustre/lov/lov_io.c
+++ b/fs/lustre/lov/lov_io.c
@@ -1014,7 +1014,8 @@ static int lov_io_read_ahead(const struct lu_env *env,
 			      ra);
 
 	CDEBUG(D_READA, DFID " cra_end = %lu, stripes = %d, rc = %d\n",
-	       PFID(lu_object_fid(lov2lu(loo))), ra->cra_end, r0->lo_nr, rc);
+	       PFID(lu_object_fid(lov2lu(loo))), ra->cra_end_idx,
+		    r0->lo_nr, rc);
 	if (rc)
 		return rc;
 
@@ -1027,15 +1028,15 @@ static int lov_io_read_ahead(const struct lu_env *env,
 	 */
 
 	/* cra_end is stripe level, convert it into file level */
-	ra_end = ra->cra_end;
+	ra_end = ra->cra_end_idx;
 	if (ra_end != CL_PAGE_EOF)
-		ra->cra_end = lov_stripe_pgoff(loo->lo_lsm, index,
-					       ra_end, stripe);
+		ra->cra_end_idx = lov_stripe_pgoff(loo->lo_lsm, index,
+						   ra_end, stripe);
 
 	/* boundary of current component */
 	ra_end = cl_index(obj, (loff_t)lov_io_extent(lio, index)->e_end);
-	if (ra_end != CL_PAGE_EOF && ra->cra_end >= ra_end)
-		ra->cra_end = ra_end - 1;
+	if (ra_end != CL_PAGE_EOF && ra->cra_end_idx >= ra_end)
+		ra->cra_end_idx = ra_end - 1;
 
 	if (r0->lo_nr == 1) /* single stripe file */
 		return 0;
@@ -1043,13 +1044,13 @@ static int lov_io_read_ahead(const struct lu_env *env,
 	pps = lov_lse(loo, index)->lsme_stripe_size >> PAGE_SHIFT;
 
 	CDEBUG(D_READA,
-	       DFID " max_index = %lu, pps = %u, index = %u, stripe_size = %u, stripe no = %u, start index = %lu\n",
-	       PFID(lu_object_fid(lov2lu(loo))), ra->cra_end, pps, index,
+	       DFID " max_index = %lu, pps = %u, index = %d, stripe_size = %u, stripe no = %u, start index = %lu\n",
+	       PFID(lu_object_fid(lov2lu(loo))), ra->cra_end_idx, pps, index,
 	       lov_lse(loo, index)->lsme_stripe_size, stripe, start);
 
 	/* never exceed the end of the stripe */
-	ra->cra_end = min_t(pgoff_t,
-			    ra->cra_end, start + pps - start % pps - 1);
+	ra->cra_end_idx = min_t(pgoff_t, ra->cra_end_idx,
+				start + pps - start % pps - 1);
 	return 0;
 }
 
diff --git a/fs/lustre/mdc/mdc_dev.c b/fs/lustre/mdc/mdc_dev.c
index 312e527..496491f 100644
--- a/fs/lustre/mdc/mdc_dev.c
+++ b/fs/lustre/mdc/mdc_dev.c
@@ -1099,8 +1099,8 @@ static int mdc_io_read_ahead(const struct lu_env *env,
 		ldlm_lock_decref(&lockh, dlmlock->l_req_mode);
 	}
 
-	ra->cra_rpc_size = osc_cli(osc)->cl_max_pages_per_rpc;
-	ra->cra_end = CL_PAGE_EOF;
+	ra->cra_rpc_pages = osc_cli(osc)->cl_max_pages_per_rpc;
+	ra->cra_end_idx = CL_PAGE_EOF;
 	ra->cra_release = osc_read_ahead_release;
 	ra->cra_cbdata = dlmlock;
 
diff --git a/fs/lustre/obdclass/integrity.c b/fs/lustre/obdclass/integrity.c
index 230e1a5..cbb91ed 100644
--- a/fs/lustre/obdclass/integrity.c
+++ b/fs/lustre/obdclass/integrity.c
@@ -229,7 +229,7 @@ static void obd_t10_performance_test(const char *obd_name,
 	for (start = jiffies, end = start + HZ / 4,
 	     bcount = 0; time_before(jiffies, end) && rc == 0; bcount++) {
 		rc = __obd_t10_performance_test(obd_name, cksum_type, page,
-						buf_len / PAGE_SIZE);
+						buf_len >> PAGE_SHIFT);
 		if (rc)
 			break;
 	}
diff --git a/fs/lustre/osc/osc_cache.c b/fs/lustre/osc/osc_cache.c
index dde03bd..7a8dbfc 100644
--- a/fs/lustre/osc/osc_cache.c
+++ b/fs/lustre/osc/osc_cache.c
@@ -1349,7 +1349,7 @@ static int osc_refresh_count(const struct lu_env *env,
 		return 0;
 	else if (cl_offset(obj, index + 1) > kms)
 		/* catch sub-page write at end of file */
-		return kms % PAGE_SIZE;
+		return kms & ~PAGE_MASK;
 	else
 		return PAGE_SIZE;
 }
diff --git a/fs/lustre/osc/osc_io.c b/fs/lustre/osc/osc_io.c
index 1ff2df2..f26c95d 100644
--- a/fs/lustre/osc/osc_io.c
+++ b/fs/lustre/osc/osc_io.c
@@ -88,12 +88,12 @@ static int osc_io_read_ahead(const struct lu_env *env,
 			ldlm_lock_decref(&lockh, dlmlock->l_req_mode);
 		}
 
-		ra->cra_rpc_size = osc_cli(osc)->cl_max_pages_per_rpc;
-		ra->cra_end = cl_index(osc2cl(osc),
-				       dlmlock->l_policy_data.l_extent.end);
+		ra->cra_rpc_pages = osc_cli(osc)->cl_max_pages_per_rpc;
+		ra->cra_end_idx = cl_index(osc2cl(osc),
+					   dlmlock->l_policy_data.l_extent.end);
 		ra->cra_release = osc_read_ahead_release;
 		ra->cra_cbdata = dlmlock;
-		if (ra->cra_end != CL_PAGE_EOF)
+		if (ra->cra_end_idx != CL_PAGE_EOF)
 			ra->cra_contention = true;
 		result = 0;
 	}
-- 
1.8.3.1
