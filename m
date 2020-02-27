From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:15:46 -0500
Subject: [lustre-devel] [PATCH 478/622] lustre: readahead: convert stride
 page index to byte
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-479-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Wang Shilong <wshilong@ddn.com>

This is a prepared patch to support unaligned stride readahead.
Some detection variables are converted to byte unit to be aware
of possible unaligned stride read.

Since we still need read pages by page index, so those variables
are still kept as page unit. to make things more clear, fix them
to use pgoff_t rather than unsigned long.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12518
Lustre-commit: 0923e4055116 ("LU-12518 readahead: convert stride page index to byte")
Signed-off-by: Wang Shilong <wshilong@ddn.com>
Reviewed-on: https://review.whamcloud.com/35829
Reviewed-by: Li Xi <lixi@ddn.com>
Reviewed-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/llite_internal.h |  60 +++++-----
 fs/lustre/llite/rw.c             | 243 ++++++++++++++++++++-------------------
 2 files changed, 153 insertions(+), 150 deletions(-)

diff --git a/fs/lustre/llite/llite_internal.h b/fs/lustre/llite/llite_internal.h
index 025d33e..d84f50c 100644
--- a/fs/lustre/llite/llite_internal.h
+++ b/fs/lustre/llite/llite_internal.h
@@ -358,22 +358,22 @@ struct ll_ra_info {
  * counted by page index.
  */
 struct ra_io_arg {
-	unsigned long ria_start;	/* start offset of read-ahead*/
-	unsigned long ria_end;		/* end offset of read-ahead*/
-	unsigned long ria_reserved;	/* reserved pages for read-ahead */
-	unsigned long ria_end_min;	/* minimum end to cover current read */
-	bool ria_eof;			/* reach end of file */
+	pgoff_t		ria_start;	/* start offset of read-ahead*/
+	pgoff_t		ria_end;	/* end offset of read-ahead*/
+	unsigned long	ria_reserved;	/* reserved pages for read-ahead */
+	pgoff_t		ria_end_min;	/* minimum end to cover current read */
+	bool		ria_eof;	/* reach end of file */
 	/* If stride read pattern is detected, ria_stoff means where
 	 * stride read is started. Note: for normal read-ahead, the
 	 * value here is meaningless, and also it will not be accessed
 	 */
-	pgoff_t ria_stoff;
-	/* ria_length and ria_pages are the length and pages length in the
+	unsigned long	ria_stoff;
+	/* ria_length and ria_bytes are the length and pages length in the
 	 * stride I/O mode. And they will also be used to check whether
 	 * it is stride I/O read-ahead in the read-ahead pages
 	 */
-	unsigned long ria_length;
-	unsigned long ria_pages;
+	unsigned long	ria_length;
+	unsigned long	ria_bytes;
 };
 
 /* LL_HIST_MAX=32 causes an overflow */
@@ -592,16 +592,10 @@ struct ll_sb_info {
  */
 struct ll_readahead_state {
 	spinlock_t  ras_lock;
+	/* End byte that read(2) try to read.  */
+	unsigned long	ras_last_read_end;
 	/*
-	 * index of the last page that read(2) needed and that wasn't in the
-	 * cache. Used by ras_update() to detect seeks.
-	 *
-	 * XXX nikita: if access seeks into cached region, Lustre doesn't see
-	 * this.
-	 */
-	unsigned long   ras_last_readpage;
-	/*
-	 * number of pages read after last read-ahead window reset. As window
+	 * number of bytes read after last read-ahead window reset. As window
 	 * is reset on each seek, this is effectively a number of consecutive
 	 * accesses. Maybe ->ras_accessed_in_window is better name.
 	 *
@@ -610,13 +604,13 @@ struct ll_readahead_state {
 	 * case, it probably doesn't make sense to expand window to
 	 * PTLRPC_MAX_BRW_PAGES on the third access.
 	 */
-	unsigned long   ras_consecutive_pages;
+	unsigned long	ras_consecutive_bytes;
 	/*
 	 * number of read requests after the last read-ahead window reset
 	 * As window is reset on each seek, this is effectively the number
 	 * on consecutive read request and is used to trigger read-ahead.
 	 */
-	unsigned long   ras_consecutive_requests;
+	unsigned long	ras_consecutive_requests;
 	/*
 	 * Parameters of current read-ahead window. Handled by
 	 * ras_update(). On the initial access to the file or after a seek,
@@ -624,7 +618,7 @@ struct ll_readahead_state {
 	 * expanded to PTLRPC_MAX_BRW_PAGES. Afterwards, window is enlarged by
 	 * PTLRPC_MAX_BRW_PAGES chunks up to ->ra_max_pages.
 	 */
-	unsigned long   ras_window_start, ras_window_len;
+	pgoff_t		ras_window_start, ras_window_len;
 	/*
 	 * Optimal RPC size. It decides how many pages will be sent
 	 * for each read-ahead.
@@ -637,41 +631,41 @@ struct ll_readahead_state {
 	 * ->ra_max_pages (see ll_ra_count_get()), 2. client cannot read pages
 	 * not covered by DLM lock.
 	 */
-	unsigned long   ras_next_readahead;
+	pgoff_t		ras_next_readahead;
 	/*
 	 * Total number of ll_file_read requests issued, reads originating
 	 * due to mmap are not counted in this total.  This value is used to
 	 * trigger full file read-ahead after multiple reads to a small file.
 	 */
-	unsigned long   ras_requests;
+	unsigned long	ras_requests;
 	/*
 	 * Page index with respect to the current request, these value
 	 * will not be accurate when dealing with reads issued via mmap.
 	 */
-	unsigned long   ras_request_index;
+	unsigned long	ras_request_index;
 	/*
 	 * The following 3 items are used for detecting the stride I/O
 	 * mode.
 	 * In stride I/O mode,
 	 * ...............|-----data-----|****gap*****|--------|******|....
-	 *    offset      |-stride_pages-|-stride_gap-|
+	 *    offset      |-stride_bytes-|-stride_gap-|
 	 * ras_stride_offset = offset;
-	 * ras_stride_length = stride_pages + stride_gap;
-	 * ras_stride_pages = stride_pages;
-	 * Note: all these three items are counted by pages.
+	 * ras_stride_length = stride_bytes + stride_gap;
+	 * ras_stride_bytes = stride_bytes;
+	 * Note: all these three items are counted by bytes.
 	 */
-	unsigned long   ras_stride_length;
-	unsigned long   ras_stride_pages;
-	pgoff_t	 ras_stride_offset;
+	unsigned long	ras_stride_length;
+	unsigned long	ras_stride_bytes;
+	unsigned long	ras_stride_offset;
 	/*
 	 * number of consecutive stride request count, and it is similar as
 	 * ras_consecutive_requests, but used for stride I/O mode.
 	 * Note: only more than 2 consecutive stride request are detected,
 	 * stride read-ahead will be enable
 	 */
-	unsigned long   ras_consecutive_stride_requests;
+	unsigned long	ras_consecutive_stride_requests;
 	/* index of the last page that async readahead starts */
-	unsigned long	ras_async_last_readpage;
+	pgoff_t		ras_async_last_readpage;
 };
 
 struct ll_readahead_work {
diff --git a/fs/lustre/llite/rw.c b/fs/lustre/llite/rw.c
index 7c2dbdc..38f7aa2c 100644
--- a/fs/lustre/llite/rw.c
+++ b/fs/lustre/llite/rw.c
@@ -131,19 +131,18 @@ void ll_ra_stats_inc(struct inode *inode, enum ra_stat which)
 
 #define RAS_CDEBUG(ras) \
 	CDEBUG(D_READA,							     \
-	       "lrp %lu cr %lu cp %lu ws %lu wl %lu nra %lu rpc %lu "	     \
-	       "r %lu ri %lu csr %lu sf %lu sp %lu sl %lu lr %lu\n",	     \
-	       ras->ras_last_readpage, ras->ras_consecutive_requests,	     \
-	       ras->ras_consecutive_pages, ras->ras_window_start,	     \
+	       "lre %lu cr %lu cb %lu ws %lu wl %lu nra %lu rpc %lu r %lu ri %lu csr %lu sf %lu sb %lu sl %lu lr %lu\n", \
+	       ras->ras_last_read_end, ras->ras_consecutive_requests,	     \
+	       ras->ras_consecutive_bytes, ras->ras_window_start,	     \
 	       ras->ras_window_len, ras->ras_next_readahead,		     \
 	       ras->ras_rpc_size,					     \
 	       ras->ras_requests, ras->ras_request_index,		     \
 	       ras->ras_consecutive_stride_requests, ras->ras_stride_offset, \
-	       ras->ras_stride_pages, ras->ras_stride_length,		     \
+	       ras->ras_stride_bytes, ras->ras_stride_length,		     \
 	       ras->ras_async_last_readpage)
 
-static int index_in_window(unsigned long index, unsigned long point,
-			   unsigned long before, unsigned long after)
+static int pos_in_window(unsigned long pos, unsigned long point,
+			 unsigned long before, unsigned long after)
 {
 	unsigned long start = point - before, end = point + after;
 
@@ -152,7 +151,7 @@ static int index_in_window(unsigned long index, unsigned long point,
 	if (end < point)
 		end = ~0;
 
-	return start <= index && index <= end;
+	return start <= pos && pos <= end;
 }
 
 void ll_ras_enter(struct file *f)
@@ -242,10 +241,10 @@ static int ll_read_ahead_page(const struct lu_env *env, struct cl_io *io,
 	return rc;
 }
 
-#define RIA_DEBUG(ria)						       \
-	CDEBUG(D_READA, "rs %lu re %lu ro %lu rl %lu rp %lu\n",       \
-	ria->ria_start, ria->ria_end, ria->ria_stoff, ria->ria_length,\
-	ria->ria_pages)
+#define RIA_DEBUG(ria)						\
+	CDEBUG(D_READA, "rs %lu re %lu ro %lu rl %lu rb %lu\n",	\
+	       ria->ria_start, ria->ria_end, ria->ria_stoff,	\
+	       ria->ria_length, ria->ria_bytes)
 
 static inline int stride_io_mode(struct ll_readahead_state *ras)
 {
@@ -255,72 +254,76 @@ static inline int stride_io_mode(struct ll_readahead_state *ras)
 /* The function calculates how much pages will be read in
  * [off, off + length], in such stride IO area,
  * stride_offset = st_off, stride_length = st_len,
- * stride_pages = st_pgs
+ * stride_bytes = st_bytes
  *
  *   |------------------|*****|------------------|*****|------------|*****|....
  * st_off
- *   |--- st_pgs     ---|
+ *   |--- st_bytes     ---|
  *   |-----     st_len   -----|
  *
- *	      How many pages it should read in such pattern
+ *	      How many bytes it should read in such pattern
  *	      |-------------------------------------------------------------|
  *	      off
  *	      |<------		  length		      ------->|
  *
  *	  =   |<----->|  +  |-------------------------------------| +   |---|
- *	     start_left		 st_pgs * i		    end_left
+ *	       start_left                 st_bytes * i                 end_left
  */
 static unsigned long
-stride_pg_count(pgoff_t st_off, unsigned long st_len, unsigned long st_pgs,
-		unsigned long off, unsigned long length)
+stride_byte_count(unsigned long st_off, unsigned long st_len,
+		  unsigned long st_bytes, unsigned long off,
+		  unsigned long length)
 {
 	u64 start = off > st_off ? off - st_off : 0;
 	u64 end = off + length > st_off ? off + length - st_off : 0;
 	unsigned long start_left = 0;
 	unsigned long end_left = 0;
-	unsigned long pg_count;
+	unsigned long bytes_count;
 
 	if (st_len == 0 || length == 0 || end == 0)
 		return length;
 
 	start_left = do_div(start, st_len);
-	if (start_left < st_pgs)
-		start_left = st_pgs - start_left;
+	if (start_left < st_bytes)
+		start_left = st_bytes - start_left;
 	else
 		start_left = 0;
 
 	end_left = do_div(end, st_len);
-	if (end_left > st_pgs)
-		end_left = st_pgs;
+	if (end_left > st_bytes)
+		end_left = st_bytes;
 
 	CDEBUG(D_READA, "start %llu, end %llu start_left %lu end_left %lu\n",
 	       start, end, start_left, end_left);
 
 	if (start == end)
-		pg_count = end_left - (st_pgs - start_left);
+		bytes_count = end_left - (st_bytes - start_left);
 	else
-		pg_count = start_left + st_pgs * (end - start - 1) + end_left;
+		bytes_count = start_left +
+			st_bytes * (end - start - 1) + end_left;
 
 	CDEBUG(D_READA,
-	       "st_off %lu, st_len %lu st_pgs %lu off %lu length %lu pgcount %lu\n",
-	       st_off, st_len, st_pgs, off, length, pg_count);
+	       "st_off %lu, st_len %lu st_bytes %lu off %lu length %lu bytescount %lu\n",
+	       st_off, st_len, st_bytes, off, length, bytes_count);
 
-	return pg_count;
+	return bytes_count;
 }
 
 static int ria_page_count(struct ra_io_arg *ria)
 {
 	u64 length = ria->ria_end >= ria->ria_start ?
 		     ria->ria_end - ria->ria_start + 1 : 0;
+	unsigned int bytes_count;
+
+	bytes_count = stride_byte_count(ria->ria_stoff, ria->ria_length,
+					 ria->ria_bytes, ria->ria_start,
+					 length << PAGE_SHIFT);
+	return (bytes_count + PAGE_SIZE - 1) >> PAGE_SHIFT;
 
-	return stride_pg_count(ria->ria_stoff, ria->ria_length,
-			       ria->ria_pages, ria->ria_start,
-			       length);
 }
 
 static unsigned long ras_align(struct ll_readahead_state *ras,
-			       unsigned long index,
-			       unsigned long *remainder)
+			       pgoff_t index, unsigned long *remainder)
 {
 	unsigned long rem = index % ras->ras_rpc_size;
 
@@ -337,9 +340,9 @@ static int ras_inside_ra_window(unsigned long idx, struct ra_io_arg *ria)
 	 * For stride I/O mode, just check whether the idx is inside
 	 * the ria_pages.
 	 */
-	return ria->ria_length == 0 || ria->ria_length == ria->ria_pages ||
+	return ria->ria_length == 0 || ria->ria_length == ria->ria_bytes ||
 	       (idx >= ria->ria_stoff && (idx - ria->ria_stoff) %
-		ria->ria_length < ria->ria_pages);
+		ria->ria_length < ria->ria_bytes);
 }
 
 static unsigned long
@@ -356,7 +359,7 @@ static int ras_inside_ra_window(unsigned long idx, struct ra_io_arg *ria)
 	LASSERT(ria);
 	RIA_DEBUG(ria);
 
-	stride_ria = ria->ria_length > ria->ria_pages && ria->ria_pages > 0;
+	stride_ria = ria->ria_length > ria->ria_bytes && ria->ria_bytes > 0;
 	for (page_idx = ria->ria_start;
 	     page_idx <= ria->ria_end && ria->ria_reserved > 0; page_idx++) {
 		if (ras_inside_ra_window(page_idx, ria)) {
@@ -419,20 +422,13 @@ static int ras_inside_ra_window(unsigned long idx, struct ra_io_arg *ria)
 			 * read-ahead mode, then check whether it should skip
 			 * the stride gap.
 			 */
-			pgoff_t offset;
-			/* NOTE: This assertion only is valid when it is for
-			 * forward read-ahead, must adjust if backward
-			 * readahead is implemented.
-			 */
-			LASSERTF(page_idx >= ria->ria_stoff,
-				 "Invalid page_idx %lu rs %lu re %lu ro %lu rl %lu rp %lu\n",
-				 page_idx,
-				 ria->ria_start, ria->ria_end, ria->ria_stoff,
-				 ria->ria_length, ria->ria_pages);
-			offset = page_idx - ria->ria_stoff;
-			offset = offset % (ria->ria_length);
-			if (offset >= ria->ria_pages) {
-				page_idx += ria->ria_length - offset - 1;
+			unsigned long offset;
+			unsigned long pos = page_idx << PAGE_SHIFT;
+
+			offset = (pos - ria->ria_stoff) % ria->ria_length;
+			if (offset >= ria->ria_bytes) {
+				pos += (ria->ria_length - offset);
+				page_idx = (pos >> PAGE_SHIFT) - 1;
 				CDEBUG(D_READA,
 				       "Stride: jump %lu pages to %lu\n",
 				       ria->ria_length - offset, page_idx);
@@ -647,7 +643,8 @@ static int ll_readahead(const struct lu_env *env, struct cl_io *io,
 	 * so that stride read ahead can work correctly.
 	 */
 	if (stride_io_mode(ras))
-		start = max(ras->ras_next_readahead, ras->ras_stride_offset);
+		start = max(ras->ras_next_readahead,
+			    ras->ras_stride_offset >> PAGE_SHIFT);
 	else
 		start = ras->ras_next_readahead;
 
@@ -676,7 +673,7 @@ static int ll_readahead(const struct lu_env *env, struct cl_io *io,
 	if (stride_io_mode(ras)) {
 		ria->ria_stoff = ras->ras_stride_offset;
 		ria->ria_length = ras->ras_stride_length;
-		ria->ria_pages = ras->ras_stride_pages;
+		ria->ria_bytes = ras->ras_stride_bytes;
 	}
 	spin_unlock(&ras->ras_lock);
 
@@ -739,21 +736,18 @@ static int ll_readahead(const struct lu_env *env, struct cl_io *io,
 	return ret;
 }
 
-static void ras_set_start(struct inode *inode, struct ll_readahead_state *ras,
-			  unsigned long index)
+static void ras_set_start(struct ll_readahead_state *ras, pgoff_t index)
 {
 	ras->ras_window_start = ras_align(ras, index, NULL);
 }
 
 /* called with the ras_lock held or from places where it doesn't matter */
-static void ras_reset(struct inode *inode, struct ll_readahead_state *ras,
-		      unsigned long index)
+static void ras_reset(struct ll_readahead_state *ras, pgoff_t index)
 {
-	ras->ras_last_readpage = index;
 	ras->ras_consecutive_requests = 0;
-	ras->ras_consecutive_pages = 0;
+	ras->ras_consecutive_bytes = 0;
 	ras->ras_window_len = 0;
-	ras_set_start(inode, ras, index);
+	ras_set_start(ras, index);
 	ras->ras_next_readahead = max(ras->ras_window_start, index + 1);
 
 	RAS_CDEBUG(ras);
@@ -764,7 +758,7 @@ static void ras_stride_reset(struct ll_readahead_state *ras)
 {
 	ras->ras_consecutive_stride_requests = 0;
 	ras->ras_stride_length = 0;
-	ras->ras_stride_pages = 0;
+	ras->ras_stride_bytes = 0;
 	RAS_CDEBUG(ras);
 }
 
@@ -772,56 +766,59 @@ void ll_readahead_init(struct inode *inode, struct ll_readahead_state *ras)
 {
 	spin_lock_init(&ras->ras_lock);
 	ras->ras_rpc_size = PTLRPC_MAX_BRW_PAGES;
-	ras_reset(inode, ras, 0);
+	ras_reset(ras, 0);
+	ras->ras_last_read_end = 0;
 	ras->ras_requests = 0;
 }
 
 /*
  * Check whether the read request is in the stride window.
- * If it is in the stride window, return 1, otherwise return 0.
+ * If it is in the stride window, return true, otherwise return false.
  */
-static int index_in_stride_window(struct ll_readahead_state *ras,
-				  unsigned long index)
+static bool index_in_stride_window(struct ll_readahead_state *ras,
+				   pgoff_t index)
 {
 	unsigned long stride_gap;
+	unsigned long pos = index << PAGE_SHIFT;
 
-	if (ras->ras_stride_length == 0 || ras->ras_stride_pages == 0 ||
-	    ras->ras_stride_pages == ras->ras_stride_length)
-		return 0;
+	if (ras->ras_stride_length == 0 || ras->ras_stride_bytes == 0 ||
+	    ras->ras_stride_bytes == ras->ras_stride_length)
+		return false;
 
-	stride_gap = index - ras->ras_last_readpage - 1;
+	stride_gap = pos - ras->ras_last_read_end - 1;
 
 	/* If it is contiguous read */
 	if (stride_gap == 0)
-		return ras->ras_consecutive_pages + 1 <= ras->ras_stride_pages;
+		return ras->ras_consecutive_bytes + PAGE_SIZE <=
+			ras->ras_stride_bytes;
 
 	/* Otherwise check the stride by itself */
-	return (ras->ras_stride_length - ras->ras_stride_pages) == stride_gap &&
-		ras->ras_consecutive_pages == ras->ras_stride_pages;
+	return (ras->ras_stride_length - ras->ras_stride_bytes) == stride_gap &&
+		ras->ras_consecutive_bytes == ras->ras_stride_bytes;
 }
 
-static void ras_update_stride_detector(struct ll_readahead_state *ras,
-				       unsigned long index)
+static void ras_init_stride_detector(struct ll_readahead_state *ras,
+				     unsigned long pos, unsigned long count)
 {
-	unsigned long stride_gap = index - ras->ras_last_readpage - 1;
+	unsigned long stride_gap = pos - ras->ras_last_read_end - 1;
 
 	if ((stride_gap != 0 || ras->ras_consecutive_stride_requests == 0) &&
 	    !stride_io_mode(ras)) {
-		ras->ras_stride_pages = ras->ras_consecutive_pages;
-		ras->ras_stride_length = ras->ras_consecutive_pages +
+		ras->ras_stride_bytes = ras->ras_consecutive_bytes;
+		ras->ras_stride_length =  ras->ras_consecutive_bytes +
 					 stride_gap;
 	}
 	LASSERT(ras->ras_request_index == 0);
 	LASSERT(ras->ras_consecutive_stride_requests == 0);
 
-	if (index <= ras->ras_last_readpage) {
+	if (pos <= ras->ras_last_read_end) {
 		/*Reset stride window for forward read*/
 		ras_stride_reset(ras);
 		return;
 	}
 
-	ras->ras_stride_pages = ras->ras_consecutive_pages;
-	ras->ras_stride_length = stride_gap + ras->ras_consecutive_pages;
+	ras->ras_stride_bytes = ras->ras_consecutive_bytes;
+	ras->ras_stride_length = stride_gap + ras->ras_consecutive_bytes;
 
 	RAS_CDEBUG(ras);
 }
@@ -835,36 +832,42 @@ static void ras_stride_increase_window(struct ll_readahead_state *ras,
 {
 	unsigned long left, step, window_len;
 	unsigned long stride_len;
+	unsigned long end = ras->ras_window_start + ras->ras_window_len;
 
 	LASSERT(ras->ras_stride_length > 0);
-	LASSERTF(ras->ras_window_start + ras->ras_window_len >=
-		 ras->ras_stride_offset,
+	LASSERTF(end >= (ras->ras_stride_offset >> PAGE_SHIFT),
 		 "window_start %lu, window_len %lu stride_offset %lu\n",
-		 ras->ras_window_start,
-		 ras->ras_window_len, ras->ras_stride_offset);
+		 ras->ras_window_start, ras->ras_window_len,
+		 ras->ras_stride_offset);
 
-	stride_len = ras->ras_window_start + ras->ras_window_len -
-		     ras->ras_stride_offset;
+	end <<= PAGE_SHIFT;
+	if (end < ras->ras_stride_offset)
+		stride_len = 0;
+	else
+		stride_len = end - ras->ras_stride_offset;
 
 	left = stride_len % ras->ras_stride_length;
-	window_len = ras->ras_window_len - left;
+	window_len = (ras->ras_window_len << PAGE_SHIFT) - left;
 
-	if (left < ras->ras_stride_pages)
+	if (left < ras->ras_stride_bytes)
 		left += inc_len;
 	else
-		left = ras->ras_stride_pages + inc_len;
+		left = ras->ras_stride_bytes + inc_len;
 
-	LASSERT(ras->ras_stride_pages != 0);
+	LASSERT(ras->ras_stride_bytes != 0);
 
-	step = left / ras->ras_stride_pages;
-	left %= ras->ras_stride_pages;
+	step = left / ras->ras_stride_bytes;
+	left %= ras->ras_stride_bytes;
 
 	window_len += step * ras->ras_stride_length + left;
 
-	if (stride_pg_count(ras->ras_stride_offset, ras->ras_stride_length,
-			    ras->ras_stride_pages, ras->ras_stride_offset,
-			    window_len) <= ra->ra_max_pages_per_file)
-		ras->ras_window_len = window_len;
+	if (DIV_ROUND_UP(stride_byte_count(ras->ras_stride_offset,
+					   ras->ras_stride_length,
+					   ras->ras_stride_bytes,
+					   ras->ras_stride_offset,
+					   window_len), PAGE_SIZE)
+	    <= ra->ra_max_pages_per_file)
+		ras->ras_window_len = (window_len >> PAGE_SHIFT);
 
 	RAS_CDEBUG(ras);
 }
@@ -878,7 +881,8 @@ static void ras_increase_window(struct inode *inode,
 	 * information from lower layer. FIXME later
 	 */
 	if (stride_io_mode(ras)) {
-		ras_stride_increase_window(ras, ra, ras->ras_rpc_size);
+		ras_stride_increase_window(ras, ra,
+				ras->ras_rpc_size << PAGE_SHIFT);
 	} else {
 		unsigned long wlen;
 
@@ -897,6 +901,7 @@ static void ras_update(struct ll_sb_info *sbi, struct inode *inode,
 {
 	struct ll_ra_info *ra = &sbi->ll_ra_info;
 	int zero = 0, stride_detect = 0, ra_miss = 0;
+	unsigned long pos = index << PAGE_SHIFT;
 	bool hit = flags & LL_RAS_HIT;
 
 	spin_lock(&ras->ras_lock);
@@ -913,13 +918,14 @@ static void ras_update(struct ll_sb_info *sbi, struct inode *inode,
 	 * be a symptom of there being so many read-ahead pages that the VM is
 	 * reclaiming it before we get to it.
 	 */
-	if (!index_in_window(index, ras->ras_last_readpage, 8, 8)) {
+	if (!pos_in_window(pos, ras->ras_last_read_end,
+			   8 << PAGE_SHIFT, 8 << PAGE_SHIFT)) {
 		zero = 1;
 		ll_ra_stats_inc_sbi(sbi, RA_STAT_DISTANT_READPAGE);
 	} else if (!hit && ras->ras_window_len &&
 		   index < ras->ras_next_readahead &&
-		   index_in_window(index, ras->ras_window_start, 0,
-				   ras->ras_window_len)) {
+		   pos_in_window(index, ras->ras_window_start, 0,
+				 ras->ras_window_len)) {
 		ra_miss = 1;
 		ll_ra_stats_inc_sbi(sbi, RA_STAT_MISS_IN_WINDOW);
 	}
@@ -955,16 +961,16 @@ static void ras_update(struct ll_sb_info *sbi, struct inode *inode,
 		if (!index_in_stride_window(ras, index)) {
 			if (ras->ras_consecutive_stride_requests == 0 &&
 			    ras->ras_request_index == 0) {
-				ras_update_stride_detector(ras, index);
+				ras_init_stride_detector(ras, pos, PAGE_SIZE);
 				ras->ras_consecutive_stride_requests++;
 			} else {
 				ras_stride_reset(ras);
 			}
-			ras_reset(inode, ras, index);
-			ras->ras_consecutive_pages++;
+			ras_reset(ras, index);
+			ras->ras_consecutive_bytes += PAGE_SIZE;
 			goto out_unlock;
 		} else {
-			ras->ras_consecutive_pages = 0;
+			ras->ras_consecutive_bytes = 0;
 			ras->ras_consecutive_requests = 0;
 			if (++ras->ras_consecutive_stride_requests > 1)
 				stride_detect = 1;
@@ -974,9 +980,10 @@ static void ras_update(struct ll_sb_info *sbi, struct inode *inode,
 		if (ra_miss) {
 			if (index_in_stride_window(ras, index) &&
 			    stride_io_mode(ras)) {
-				if (index != ras->ras_last_readpage + 1)
-					ras->ras_consecutive_pages = 0;
-				ras_reset(inode, ras, index);
+				if (index != (ras->ras_last_read_end >>
+					      PAGE_SHIFT) + 1)
+					ras->ras_consecutive_bytes = 0;
+				ras_reset(ras, index);
 
 				/* If stride-RA hit cache miss, the stride
 				 * detector will not be reset to avoid the
@@ -986,15 +993,15 @@ static void ras_update(struct ll_sb_info *sbi, struct inode *inode,
 				 * read-ahead window.
 				 */
 				if (ras->ras_window_start <
-				    ras->ras_stride_offset)
+				    (ras->ras_stride_offset >> PAGE_SHIFT))
 					ras_stride_reset(ras);
 				RAS_CDEBUG(ras);
 			} else {
 				/* Reset both stride window and normal RA
 				 * window
 				 */
-				ras_reset(inode, ras, index);
-				ras->ras_consecutive_pages++;
+				ras_reset(ras, index);
+				ras->ras_consecutive_bytes += PAGE_SIZE;
 				ras_stride_reset(ras);
 				goto out_unlock;
 			}
@@ -1011,9 +1018,8 @@ static void ras_update(struct ll_sb_info *sbi, struct inode *inode,
 			}
 		}
 	}
-	ras->ras_consecutive_pages++;
-	ras->ras_last_readpage = index;
-	ras_set_start(inode, ras, index);
+	ras->ras_consecutive_bytes += PAGE_SIZE;
+	ras_set_start(ras, index);
 
 	if (stride_io_mode(ras)) {
 		/* Since stride readahead is sensitive to the offset
@@ -1022,8 +1028,9 @@ static void ras_update(struct ll_sb_info *sbi, struct inode *inode,
 		 */
 		ras->ras_next_readahead = max(index + 1,
 					      ras->ras_next_readahead);
-		ras->ras_window_start = max(ras->ras_stride_offset,
-					    ras->ras_window_start);
+		ras->ras_window_start =
+				max(ras->ras_stride_offset >> PAGE_SHIFT,
+				    ras->ras_window_start);
 	} else {
 		if (ras->ras_next_readahead < ras->ras_window_start)
 			ras->ras_next_readahead = ras->ras_window_start;
@@ -1035,13 +1042,14 @@ static void ras_update(struct ll_sb_info *sbi, struct inode *inode,
 	/* Trigger RA in the mmap case where ras_consecutive_requests
 	 * is not incremented and thus can't be used to trigger RA
 	 */
-	if (ras->ras_consecutive_pages >= 4 && flags & LL_RAS_MMAP) {
+	if (ras->ras_consecutive_bytes >= (4 << PAGE_SHIFT) &&
+	    flags & LL_RAS_MMAP) {
 		ras_increase_window(inode, ras, ra);
 		/*
 		 * reset consecutive pages so that the readahead window can
 		 * grow gradually.
 		 */
-		ras->ras_consecutive_pages = 0;
+		ras->ras_consecutive_bytes = 0;
 		goto out_unlock;
 	}
 
@@ -1052,7 +1060,7 @@ static void ras_update(struct ll_sb_info *sbi, struct inode *inode,
 		 * reset to make sure next_readahead > stride offset
 		 */
 		ras->ras_next_readahead = max(index, ras->ras_next_readahead);
-		ras->ras_stride_offset = index;
+		ras->ras_stride_offset = index << PAGE_SHIFT;
 		ras->ras_window_start = max(index, ras->ras_window_start);
 	}
 
@@ -1066,6 +1074,7 @@ static void ras_update(struct ll_sb_info *sbi, struct inode *inode,
 out_unlock:
 	RAS_CDEBUG(ras);
 	ras->ras_request_index++;
+	ras->ras_last_read_end = pos + PAGE_SIZE - 1;
 	spin_unlock(&ras->ras_lock);
 }
 
-- 
1.8.3.1
