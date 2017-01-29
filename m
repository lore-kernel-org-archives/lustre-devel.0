From: James Simmons <jsimmons@infradead.org>
Date: Sat, 28 Jan 2017 19:04:34 -0500
Subject: [lustre-devel] [PATCH 06/60] staging: lustre: clio: revise
	readahead to support 16MB IO
In-Reply-To: <1485648328-2141-1-git-send-email-jsimmons@infradead.org>
References: <1485648328-2141-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1485648328-2141-7-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Jinshan Xiong <jinshan.xiong@intel.com>, Gu Zheng <gzheng@ddn.com>, James Simmons <jsimmons@infradead.org>

From: Jinshan Xiong <jinshan.xiong@intel.com>

Read ahead currently doesn't handle 16MB RPC packets correctly
by assuming the packets are a default size instead of querying
the size. This work adjust the read ahead policy to issue
read ahead RPC by the underlying RPC size.

Signed-off-by: Jinshan Xiong <jinshan.xiong@intel.com>
Signed-off-by: Gu Zheng <gzheng@ddn.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-7990
Reviewed-on: http://review.whamcloud.com/19368
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Li Xi <lixi@ddn.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/cl_object.h  |   4 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_lib.c      |  10 +-
 .../staging/lustre/lustre/llite/llite_internal.h   |  14 +-
 drivers/staging/lustre/lustre/llite/rw.c           | 195 ++++++++++-----------
 drivers/staging/lustre/lustre/osc/osc_io.c         |   3 +-
 5 files changed, 114 insertions(+), 112 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/cl_object.h b/drivers/staging/lustre/lustre/include/cl_object.h
index a1b8301..813e71d 100644
--- a/drivers/staging/lustre/lustre/include/cl_object.h
+++ b/drivers/staging/lustre/lustre/include/cl_object.h
@@ -1452,8 +1452,10 @@ struct cl_read_ahead {
 	 * cra_end is included.
 	 */
 	pgoff_t cra_end;
+	/* optimal RPC size for this read, by pages */
+	unsigned long cra_rpc_size;
 	/*
-	 * Release routine. If readahead holds resources underneath, this
+	 * Release callback. If readahead holds resources underneath, this
 	 * function should be called to release it.
 	 */
 	void (*cra_release)(const struct lu_env *env, void *cbdata);
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c
index 675e25b..95b8c76 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c
@@ -351,13 +351,11 @@ int client_obd_setup(struct obd_device *obddev, struct lustre_cfg *lcfg)
 	cli->cl_supp_cksum_types = OBD_CKSUM_CRC32;
 	atomic_set(&cli->cl_resends, OSC_DEFAULT_RESENDS);
 
-	/* This value may be reduced at connect time in
-	 * ptlrpc_connect_interpret() . We initialize it to only
-	 * 1MB until we know what the performance looks like.
-	 * In the future this should likely be increased. LU-1431
+	/*
+	 * Set it to possible maximum size. It may be reduced by ocd_brw_size
+	 * from OFD after connecting.
 	 */
-	cli->cl_max_pages_per_rpc = min_t(int, PTLRPC_MAX_BRW_PAGES,
-					  LNET_MTU >> PAGE_SHIFT);
+	cli->cl_max_pages_per_rpc = PTLRPC_MAX_BRW_PAGES;
 
 	/*
 	 * set cl_chunkbits default value to PAGE_CACHE_SHIFT,
diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
index 2c72177..501957c 100644
--- a/drivers/staging/lustre/lustre/llite/llite_internal.h
+++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
@@ -281,10 +281,8 @@ static inline struct ll_inode_info *ll_i2info(struct inode *inode)
 	return container_of(inode, struct ll_inode_info, lli_vfs_inode);
 }
 
-/* default to about 40meg of readahead on a given system.  That much tied
- * up in 512k readahead requests serviced at 40ms each is about 1GB/s.
- */
-#define SBI_DEFAULT_READAHEAD_MAX (40UL << (20 - PAGE_SHIFT))
+/* default to about 64M of readahead on a given system. */
+#define SBI_DEFAULT_READAHEAD_MAX	(64UL << (20 - PAGE_SHIFT))
 
 /* default to read-ahead full files smaller than 2MB on the second read */
 #define SBI_DEFAULT_READAHEAD_WHOLE_MAX (2UL << (20 - PAGE_SHIFT))
@@ -321,6 +319,9 @@ struct ll_ra_info {
 struct ra_io_arg {
 	unsigned long ria_start;  /* start offset of read-ahead*/
 	unsigned long ria_end;    /* end offset of read-ahead*/
+	unsigned long ria_reserved; /* reserved pages for read-ahead */
+	unsigned long ria_end_min;  /* minimum end to cover current read */
+	bool ria_eof;		    /* reach end of file */
 	/* If stride read pattern is detected, ria_stoff means where
 	 * stride read is started. Note: for normal read-ahead, the
 	 * value here is meaningless, and also it will not be accessed
@@ -551,6 +552,11 @@ struct ll_readahead_state {
 	 */
 	unsigned long   ras_window_start, ras_window_len;
 	/*
+	 * Optimal RPC size. It decides how many pages will be sent
+	 * for each read-ahead.
+	 */
+	unsigned long	ras_rpc_size;
+	/*
 	 * Where next read-ahead should start at. This lies within read-ahead
 	 * window. Read-ahead window is read in pieces rather than@once
 	 * because: 1. lustre limits total number of pages under read-ahead by
diff --git a/drivers/staging/lustre/lustre/llite/rw.c b/drivers/staging/lustre/lustre/llite/rw.c
index f10e092..18d3ccb 100644
--- a/drivers/staging/lustre/lustre/llite/rw.c
+++ b/drivers/staging/lustre/lustre/llite/rw.c
@@ -92,25 +92,6 @@ static unsigned long ll_ra_count_get(struct ll_sb_info *sbi,
 		goto out;
 	}
 
-	/* If the non-strided (ria_pages == 0) readahead window
-	 * (ria_start + ret) has grown across an RPC boundary, then trim
-	 * readahead size by the amount beyond the RPC so it ends on an
-	 * RPC boundary. If the readahead window is already ending on
-	 * an RPC boundary (beyond_rpc == 0), or smaller than a full
-	 * RPC (beyond_rpc < ret) the readahead size is unchanged.
-	 * The (beyond_rpc != 0) check is skipped since the conditional
-	 * branch is more expensive than subtracting zero from the result.
-	 *
-	 * Strided read is left unaligned to avoid small fragments beyond
-	 * the RPC boundary from needing an extra read RPC.
-	 */
-	if (ria->ria_pages == 0) {
-		long beyond_rpc = (ria->ria_start + ret) % PTLRPC_MAX_BRW_PAGES;
-
-		if (/* beyond_rpc != 0 && */ beyond_rpc < ret)
-			ret -= beyond_rpc;
-	}
-
 	if (atomic_add_return(ret, &ra->ra_cur_pages) > ra->ra_max_pages) {
 		atomic_sub(ret, &ra->ra_cur_pages);
 		ret = 0;
@@ -147,11 +128,12 @@ void ll_ra_stats_inc(struct inode *inode, enum ra_stat which)
 
 #define RAS_CDEBUG(ras) \
 	CDEBUG(D_READA,						      \
-	       "lrp %lu cr %lu cp %lu ws %lu wl %lu nra %lu r %lu ri %lu"    \
-	       "csr %lu sf %lu sp %lu sl %lu\n",			    \
+	       "lrp %lu cr %lu cp %lu ws %lu wl %lu nra %lu rpc %lu "	     \
+	       "r %lu ri %lu csr %lu sf %lu sp %lu sl %lu\n",		     \
 	       ras->ras_last_readpage, ras->ras_consecutive_requests,	\
 	       ras->ras_consecutive_pages, ras->ras_window_start,	    \
 	       ras->ras_window_len, ras->ras_next_readahead,		 \
+	       ras->ras_rpc_size,					     \
 	       ras->ras_requests, ras->ras_request_index,		    \
 	       ras->ras_consecutive_stride_requests, ras->ras_stride_offset, \
 	       ras->ras_stride_pages, ras->ras_stride_length)
@@ -261,20 +243,6 @@ static int ll_read_ahead_page(const struct lu_env *env, struct cl_io *io,
 	ria->ria_start, ria->ria_end, ria->ria_stoff, ria->ria_length,\
 	ria->ria_pages)
 
-/* Limit this to the blocksize instead of PTLRPC_BRW_MAX_SIZE, since we don't
- * know what the actual RPC size is.  If this needs to change, it makes more
- * sense to tune the i_blkbits value for the file based on the OSTs it is
- * striped over, rather than having a constant value for all files here.
- */
-
-/* RAS_INCREASE_STEP should be (1UL << (inode->i_blkbits - PAGE_SHIFT)).
- * Temporarily set RAS_INCREASE_STEP to 1MB. After 4MB RPC is enabled
- * by default, this should be adjusted corresponding with max_read_ahead_mb
- * and max_read_ahead_per_file_mb otherwise the readahead budget can be used
- * up quickly which will affect read performance significantly. See LU-2816
- */
-#define RAS_INCREASE_STEP(inode) (ONE_MB_BRW_SIZE >> PAGE_SHIFT)
-
 static inline int stride_io_mode(struct ll_readahead_state *ras)
 {
 	return ras->ras_consecutive_stride_requests > 1;
@@ -345,6 +313,17 @@ static int ria_page_count(struct ra_io_arg *ria)
 			       length);
 }
 
+static unsigned long ras_align(struct ll_readahead_state *ras,
+			       unsigned long index,
+			       unsigned long *remainder)
+{
+	unsigned long rem = index % ras->ras_rpc_size;
+
+	if (remainder)
+		*remainder = rem;
+	return index - rem;
+}
+
 /*Check whether the index is in the defined ra-window */
 static int ras_inside_ra_window(unsigned long idx, struct ra_io_arg *ria)
 {
@@ -358,42 +337,63 @@ static int ras_inside_ra_window(unsigned long idx, struct ra_io_arg *ria)
 		ria->ria_length < ria->ria_pages);
 }
 
-static int ll_read_ahead_pages(const struct lu_env *env,
-			       struct cl_io *io, struct cl_page_list *queue,
-			       struct ra_io_arg *ria,
-			       unsigned long *reserved_pages,
-			       pgoff_t *ra_end)
+static unsigned long
+ll_read_ahead_pages(const struct lu_env *env, struct cl_io *io,
+		    struct cl_page_list *queue, struct ll_readahead_state *ras,
+		    struct ra_io_arg *ria)
 {
 	struct cl_read_ahead ra = { 0 };
-	int rc, count = 0;
+	unsigned long ra_end = 0;
 	bool stride_ria;
 	pgoff_t page_idx;
+	int rc;
 
 	LASSERT(ria);
 	RIA_DEBUG(ria);
 
 	stride_ria = ria->ria_length > ria->ria_pages && ria->ria_pages > 0;
 	for (page_idx = ria->ria_start;
-	     page_idx <= ria->ria_end && *reserved_pages > 0; page_idx++) {
+	     page_idx <= ria->ria_end && ria->ria_reserved > 0; page_idx++) {
 		if (ras_inside_ra_window(page_idx, ria)) {
 			if (!ra.cra_end || ra.cra_end < page_idx) {
+				unsigned long end;
+
 				cl_read_ahead_release(env, &ra);
 
 				rc = cl_io_read_ahead(env, io, page_idx, &ra);
 				if (rc < 0)
 					break;
 
+				CDEBUG(D_READA, "idx: %lu, ra: %lu, rpc: %lu\n",
+				       page_idx, ra.cra_end, ra.cra_rpc_size);
 				LASSERTF(ra.cra_end >= page_idx,
 					 "object: %p, indcies %lu / %lu\n",
 					 io->ci_obj, ra.cra_end, page_idx);
+				/*
+				 * update read ahead RPC size.
+				 * NB: it's racy but doesn't matter
+				 */
+				if (ras->ras_rpc_size > ra.cra_rpc_size &&
+				    ra.cra_rpc_size > 0)
+					ras->ras_rpc_size = ra.cra_rpc_size;
+				/* trim it to align with optimal RPC size */
+				end = ras_align(ras, ria->ria_end + 1, NULL);
+				if (end > 0 && !ria->ria_eof)
+					ria->ria_end = end - 1;
+				if (ria->ria_end < ria->ria_end_min)
+					ria->ria_end = ria->ria_end_min;
+				if (ria->ria_end > ra.cra_end)
+					ria->ria_end = ra.cra_end;
 			}
 
-			/* If the page is inside the read-ahead window*/
+			/* If the page is inside the read-ahead window */
 			rc = ll_read_ahead_page(env, io, queue, page_idx);
-			if (!rc) {
-				(*reserved_pages)--;
-				count++;
-			}
+			if (rc < 0)
+				break;
+
+			ra_end = page_idx;
+			if (!rc)
+				ria->ria_reserved--;
 		} else if (stride_ria) {
 			/* If it is not in the read-ahead window, and it is
 			 * read-ahead mode, then check whether it should skip
@@ -420,8 +420,7 @@ static int ll_read_ahead_pages(const struct lu_env *env,
 	}
 	cl_read_ahead_release(env, &ra);
 
-	*ra_end = page_idx;
-	return count;
+	return ra_end;
 }
 
 static int ll_readahead(const struct lu_env *env, struct cl_io *io,
@@ -431,7 +430,7 @@ static int ll_readahead(const struct lu_env *env, struct cl_io *io,
 	struct vvp_io *vio = vvp_env_io(env);
 	struct ll_thread_info *lti = ll_env_info(env);
 	struct cl_attr *attr = vvp_env_thread_attr(env);
-	unsigned long len, mlen = 0, reserved;
+	unsigned long len, mlen = 0;
 	pgoff_t ra_end, start = 0, end = 0;
 	struct inode *inode;
 	struct ra_io_arg *ria = &lti->lti_ria;
@@ -478,29 +477,15 @@ static int ll_readahead(const struct lu_env *env, struct cl_io *io,
 	    end < vio->vui_ra_start + vio->vui_ra_count - 1)
 		end = vio->vui_ra_start + vio->vui_ra_count - 1;
 
-	if (end != 0) {
-		unsigned long rpc_boundary;
-		/*
-		 * Align RA window to an optimal boundary.
-		 *
-		 * XXX This would be better to align to cl_max_pages_per_rpc
-		 * instead of PTLRPC_MAX_BRW_PAGES, because the RPC size may
-		 * be aligned to the RAID stripe size in the future and that
-		 * is more important than the RPC size.
-		 */
-		/* Note: we only trim the RPC, instead of extending the RPC
-		 * to the boundary, so to avoid reading too much pages during
-		 * random reading.
-		 */
-		rpc_boundary = (end + 1) & (~(PTLRPC_MAX_BRW_PAGES - 1));
-		if (rpc_boundary > 0)
-			rpc_boundary--;
-
-		if (rpc_boundary  > start)
-			end = rpc_boundary;
+	if (end) {
+		unsigned long end_index;
 
 		/* Truncate RA window to end of file */
-		end = min(end, (unsigned long)((kms - 1) >> PAGE_SHIFT));
+		end_index = (unsigned long)((kms - 1) >> PAGE_SHIFT);
+		if (end_index <= end) {
+			end = end_index;
+			ria->ria_eof = true;
+		}
 
 		ras->ras_next_readahead = max(end, end + 1);
 		RAS_CDEBUG(ras);
@@ -535,28 +520,31 @@ static int ll_readahead(const struct lu_env *env, struct cl_io *io,
 	/* at least to extend the readahead window to cover current read */
 	if (!hit && vio->vui_ra_valid &&
 	    vio->vui_ra_start + vio->vui_ra_count > ria->ria_start) {
+		unsigned long remainder;
+
 		/* to the end of current read window. */
 		mlen = vio->vui_ra_start + vio->vui_ra_count - ria->ria_start;
 		/* trim to RPC boundary */
-		start = ria->ria_start & (PTLRPC_MAX_BRW_PAGES - 1);
-		mlen = min(mlen, PTLRPC_MAX_BRW_PAGES - start);
+		ras_align(ras, ria->ria_start, &remainder);
+		mlen = min(mlen, ras->ras_rpc_size - remainder);
+		ria->ria_end_min = ria->ria_start + mlen;
 	}
 
-	reserved = ll_ra_count_get(ll_i2sbi(inode), ria, len, mlen);
-	if (reserved < len)
+	ria->ria_reserved = ll_ra_count_get(ll_i2sbi(inode), ria, len, mlen);
+	if (ria->ria_reserved < len)
 		ll_ra_stats_inc(inode, RA_STAT_MAX_IN_FLIGHT);
 
 	CDEBUG(D_READA, "reserved pages %lu/%lu/%lu, ra_cur %d, ra_max %lu\n",
-	       reserved, len, mlen,
+	       ria->ria_reserved, len, mlen,
 	       atomic_read(&ll_i2sbi(inode)->ll_ra_info.ra_cur_pages),
 	       ll_i2sbi(inode)->ll_ra_info.ra_max_pages);
 
-	ret = ll_read_ahead_pages(env, io, queue, ria, &reserved, &ra_end);
+	ra_end = ll_read_ahead_pages(env, io, queue, ras, ria);
 
-	if (reserved != 0)
-		ll_ra_count_put(ll_i2sbi(inode), reserved);
+	if (ria->ria_reserved)
+		ll_ra_count_put(ll_i2sbi(inode), ria->ria_reserved);
 
-	if (ra_end == end + 1 && ra_end == (kms >> PAGE_SHIFT))
+	if (ra_end == end && ra_end == (kms >> PAGE_SHIFT))
 		ll_ra_stats_inc(inode, RA_STAT_EOF);
 
 	/* if we didn't get to the end of the region we reserved from
@@ -568,13 +556,13 @@ static int ll_readahead(const struct lu_env *env, struct cl_io *io,
 	CDEBUG(D_READA, "ra_end = %lu end = %lu stride end = %lu pages = %d\n",
 	       ra_end, end, ria->ria_end, ret);
 
-	if (ra_end != end + 1) {
+	if (ra_end > 0 && ra_end != end) {
 		ll_ra_stats_inc(inode, RA_STAT_FAILED_REACH_END);
 		spin_lock(&ras->ras_lock);
-		if (ra_end < ras->ras_next_readahead &&
+		if (ra_end <= ras->ras_next_readahead &&
 		    index_in_window(ra_end, ras->ras_window_start, 0,
 				    ras->ras_window_len)) {
-			ras->ras_next_readahead = ra_end;
+			ras->ras_next_readahead = ra_end + 1;
 			RAS_CDEBUG(ras);
 		}
 		spin_unlock(&ras->ras_lock);
@@ -586,7 +574,7 @@ static int ll_readahead(const struct lu_env *env, struct cl_io *io,
 static void ras_set_start(struct inode *inode, struct ll_readahead_state *ras,
 			  unsigned long index)
 {
-	ras->ras_window_start = index & (~(RAS_INCREASE_STEP(inode) - 1));
+	ras->ras_window_start = ras_align(ras, index, NULL);
 }
 
 /* called with the ras_lock held or from places where it doesn't matter */
@@ -615,6 +603,7 @@ static void ras_stride_reset(struct ll_readahead_state *ras)
 void ll_readahead_init(struct inode *inode, struct ll_readahead_state *ras)
 {
 	spin_lock_init(&ras->ras_lock);
+	ras->ras_rpc_size = PTLRPC_MAX_BRW_PAGES;
 	ras_reset(inode, ras, 0);
 	ras->ras_requests = 0;
 }
@@ -719,12 +708,15 @@ static void ras_increase_window(struct inode *inode,
 	 * but current clio architecture does not support retrieve such
 	 * information from lower layer. FIXME later
 	 */
-	if (stride_io_mode(ras))
-		ras_stride_increase_window(ras, ra, RAS_INCREASE_STEP(inode));
-	else
-		ras->ras_window_len = min(ras->ras_window_len +
-					  RAS_INCREASE_STEP(inode),
-					  ra->ra_max_pages_per_file);
+	if (stride_io_mode(ras)) {
+		ras_stride_increase_window(ras, ra, ras->ras_rpc_size);
+	} else {
+		unsigned long wlen;
+
+		wlen = min(ras->ras_window_len + ras->ras_rpc_size,
+			   ra->ra_max_pages_per_file);
+		ras->ras_window_len = ras_align(ras, wlen, NULL);
+	}
 }
 
 static void ras_update(struct ll_sb_info *sbi, struct inode *inode,
@@ -852,6 +844,8 @@ static void ras_update(struct ll_sb_info *sbi, struct inode *inode,
 		 * instead of ras_window_start, which is RPC aligned
 		 */
 		ras->ras_next_readahead = max(index, ras->ras_next_readahead);
+		ras->ras_window_start = max(ras->ras_stride_offset,
+					    ras->ras_window_start);
 	} else {
 		if (ras->ras_next_readahead < ras->ras_window_start)
 			ras->ras_next_readahead = ras->ras_window_start;
@@ -881,7 +875,7 @@ static void ras_update(struct ll_sb_info *sbi, struct inode *inode,
 		 */
 		ras->ras_next_readahead = max(index, ras->ras_next_readahead);
 		ras->ras_stride_offset = index;
-		ras->ras_window_len = RAS_INCREASE_STEP(inode);
+		ras->ras_window_start = max(index, ras->ras_window_start);
 	}
 
 	/* The initial ras_window_len is set to the request size.  To avoid
@@ -1098,38 +1092,39 @@ static int ll_io_read_page(const struct lu_env *env, struct cl_io *io,
 	struct cl_2queue *queue  = &io->ci_queue;
 	struct ll_sb_info *sbi = ll_i2sbi(inode);
 	struct vvp_page *vpg;
+	bool uptodate;
 	int rc = 0;
 
 	vpg = cl2vvp_page(cl_object_page_slice(page->cp_obj, page));
+	uptodate = vpg->vpg_defer_uptodate;
+
 	if (sbi->ll_ra_info.ra_max_pages_per_file > 0 &&
 	    sbi->ll_ra_info.ra_max_pages > 0) {
 		struct vvp_io *vio = vvp_env_io(env);
 		enum ras_update_flags flags = 0;
 
-		if (vpg->vpg_defer_uptodate)
+		if (uptodate)
 			flags |= LL_RAS_HIT;
 		if (!vio->vui_ra_valid)
 			flags |= LL_RAS_MMAP;
 		ras_update(sbi, inode, ras, vvp_index(vpg), flags);
 	}
 
-	if (vpg->vpg_defer_uptodate) {
+	cl_2queue_init(queue);
+	if (uptodate) {
 		vpg->vpg_ra_used = 1;
 		cl_page_export(env, page, 1);
+		cl_page_disown(env, io, page);
+	} else {
+		cl_page_list_add(&queue->c2_qin, page);
 	}
 
-	cl_2queue_init(queue);
-	/*
-	 * Add page into the queue even when it is marked uptodate above.
-	 * this will unlock it automatically as part of cl_page_list_disown().
-	 */
-	cl_page_list_add(&queue->c2_qin, page);
 	if (sbi->ll_ra_info.ra_max_pages_per_file > 0 &&
 	    sbi->ll_ra_info.ra_max_pages > 0) {
 		int rc2;
 
 		rc2 = ll_readahead(env, io, &queue->c2_qin, ras,
-				   vpg->vpg_defer_uptodate);
+				   uptodate);
 		CDEBUG(D_READA, DFID "%d pages read ahead at %lu\n",
 		       PFID(ll_inode2fid(inode)), rc2, vvp_index(vpg));
 	}
diff --git a/drivers/staging/lustre/lustre/osc/osc_io.c b/drivers/staging/lustre/lustre/osc/osc_io.c
index 9402dfc..7e5cd3a 100644
--- a/drivers/staging/lustre/lustre/osc/osc_io.c
+++ b/drivers/staging/lustre/lustre/osc/osc_io.c
@@ -99,6 +99,7 @@ static int osc_io_read_ahead(const struct lu_env *env,
 			ldlm_lock_decref(&lockh, dlmlock->l_req_mode);
 		}
 
+		ra->cra_rpc_size = osc_cli(osc)->cl_max_pages_per_rpc;
 		ra->cra_end = cl_index(osc2cl(osc),
 				       dlmlock->l_policy_data.l_extent.end);
 		ra->cra_release = osc_read_ahead_release;
@@ -138,7 +139,7 @@ static int osc_io_submit(const struct lu_env *env,
 
 	LASSERT(qin->pl_nr > 0);
 
-	CDEBUG(D_CACHE, "%d %d\n", qin->pl_nr, crt);
+	CDEBUG(D_CACHE | D_READA, "%d %d\n", qin->pl_nr, crt);
 
 	osc = cl2osc(ios->cis_obj);
 	cli = osc_cli(osc);
-- 
1.8.3.1
