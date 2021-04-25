Return-Path: <SRS0=Gt0B=JW=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.7 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 24510C433B4
	for <lustre-devel@archiver.kernel.org>; Sun, 25 Apr 2021 20:10:17 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id D13FC611ED
	for <lustre-devel@archiver.kernel.org>; Sun, 25 Apr 2021 20:10:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D13FC611ED
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 41B9021F7DC;
	Sun, 25 Apr 2021 13:09:44 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id C995521F513
 for <lustre-devel@lists.lustre.org>; Sun, 25 Apr 2021 13:08:43 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 1664010084FD;
 Sun, 25 Apr 2021 16:08:40 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 0EA3769A63; Sun, 25 Apr 2021 16:08:40 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 25 Apr 2021 16:08:15 -0400
Message-Id: <1619381316-7719-9-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1619381316-7719-1-git-send-email-jsimmons@infradead.org>
References: <1619381316-7719-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 08/29] lustre: clio: fix hang on urgent
 cached pages
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

Few problems addressed by this patch:

1) We try to reserve cl_pages in batch, but we don't do
   that for append IO, there is no reason to skip that.

2) IO might be not page aligned, calculate reserved pages
   correctly for this case.

3) If we issue one large IO block size which is larger
   than max_cached_mb, IO will never be finished, because
   we don't have enough cl pages to finish it, split IO
   in this case.

4) Readahead should fail if we are short of LRU page
   slots to avoid deadlock.

After above adjustment, LRU slots are guranteed for normal
buffer write before IO starts, if block size is too large
for max LRU slots, IO will be split.

For extra readahead, don't try hard and quit if we
are short of LRU pages, since readahead could tolerate
errors, applications won't be aware of it.

besides newly added tests, following command with 64M
max_cached_mb setting and don't see client hang any more.

/usr/lib64/openmpi/bin/mpirun --allow-run-as-root -np 12
-wd /mnt/lustre ior -g -e -w -r -b 1g -T 10 -F -C -t 64m

Todo:
Performance benchmark for readahead

WC-bug-id: https://jira.whamcloud.com/browse/LU-12142
Lustre-commit: 2a34dc95bd100c181 ("LU-12142 clio: fix hang on urgent cached pages")
Signed-off-by: Wang Shilong <wshilong@ddn.com>
Reviewed-on: https://review.whamcloud.com/40237
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/cl_object.h  | 16 ++++++++---
 fs/lustre/include/lustre_osc.h | 10 ++++---
 fs/lustre/llite/file.c         | 36 ++++++++++++++++++++++---
 fs/lustre/llite/rw.c           | 31 ++++++++++++++++++++-
 fs/lustre/llite/vvp_io.c       | 12 +++++++++
 fs/lustre/lov/lov_io.c         | 53 ++++++++++++++++++++++++++++++++++++
 fs/lustre/mdc/mdc_dev.c        | 10 ++++---
 fs/lustre/obdclass/cl_io.c     | 28 +++++++++++++++++++
 fs/lustre/osc/osc_io.c         | 61 ++++++++++++++++++++++++------------------
 fs/lustre/osc/osc_page.c       | 38 ++++++++++++++++++++------
 10 files changed, 247 insertions(+), 48 deletions(-)

diff --git a/fs/lustre/include/cl_object.h b/fs/lustre/include/cl_object.h
index b36942a..6554e3d 100644
--- a/fs/lustre/include/cl_object.h
+++ b/fs/lustre/include/cl_object.h
@@ -1490,9 +1490,10 @@ struct cl_read_ahead {
 	 * function should be called to release it.
 	 */
 	void				(*cra_release)(const struct lu_env *env,
-						       void *cbdata);
+						       struct cl_read_ahead *ra);
 	/* Callback data for cra_release routine */
-	void				*cra_cbdata;
+	void				*cra_dlmlock;
+	void				*cra_oio;
 	/* whether lock is in contention */
 	bool				cra_contention;
 };
@@ -1501,7 +1502,7 @@ static inline void cl_read_ahead_release(const struct lu_env *env,
 					 struct cl_read_ahead *ra)
 {
 	if (ra->cra_release)
-		ra->cra_release(env, ra->cra_cbdata);
+		ra->cra_release(env, ra);
 	memset(ra, 0, sizeof(*ra));
 }
 
@@ -1624,6 +1625,13 @@ struct cl_io_operations {
 			      const struct cl_io_slice *slice,
 			      pgoff_t start, struct cl_read_ahead *ra);
 	/**
+	 *
+	 * Reserve LRU slots before IO.
+	 */
+	int (*cio_lru_reserve)(const struct lu_env *env,
+			       const struct cl_io_slice *slice,
+			       loff_t pos, size_t bytes);
+	/**
 	 * Optional debugging helper. Print given io slice.
 	 */
 	int (*cio_print)(const struct lu_env *env, void *cookie,
@@ -2445,6 +2453,8 @@ int cl_io_commit_async(const struct lu_env *env, struct cl_io *io,
 		       struct cl_page_list *queue, int from, int to,
 		       cl_commit_cbt cb);
 void cl_io_extent_release(const struct lu_env *env, struct cl_io *io);
+int cl_io_lru_reserve(const struct lu_env *env, struct cl_io *io,
+		      loff_t pos, size_t bytes);
 int cl_io_read_ahead(const struct lu_env *env, struct cl_io *io,
 		     pgoff_t start, struct cl_read_ahead *ra);
 
diff --git a/fs/lustre/include/lustre_osc.h b/fs/lustre/include/lustre_osc.h
index 4575956..17bfbfb 100644
--- a/fs/lustre/include/lustre_osc.h
+++ b/fs/lustre/include/lustre_osc.h
@@ -142,7 +142,9 @@ struct osc_io {
 	/* true if this io is counted as active IO */
 				oi_is_active:1,
 	/** true if this io has CAP_SYS_RESOURCE */
-				oi_cap_sys_resource:1;
+				oi_cap_sys_resource:1,
+	/** true if this io issued by readahead */
+				oi_is_readahead:1;
 	/* how many LRU pages are reserved for this IO */
 	unsigned long		oi_lru_reserved;
 
@@ -694,8 +696,6 @@ void osc_io_extent_release(const struct lu_env *env,
 int osc_io_iter_init(const struct lu_env *env, const struct cl_io_slice *ios);
 void osc_io_iter_fini(const struct lu_env *env,
 		      const struct cl_io_slice *ios);
-int osc_io_rw_iter_init(const struct lu_env *env,
-			const struct cl_io_slice *ios);
 void osc_io_rw_iter_fini(const struct lu_env *env,
 			    const struct cl_io_slice *ios);
 int osc_io_fault_start(const struct lu_env *env, const struct cl_io_slice *ios);
@@ -710,11 +710,13 @@ int osc_fsync_ost(const struct lu_env *env, struct osc_object *obj,
 		  struct cl_fsync_io *fio);
 void osc_io_fsync_end(const struct lu_env *env,
 		      const struct cl_io_slice *slice);
-void osc_read_ahead_release(const struct lu_env *env, void *cbdata);
+void osc_read_ahead_release(const struct lu_env *env, struct cl_read_ahead *ra);
 int osc_io_lseek_start(const struct lu_env *env,
 		       const struct cl_io_slice *slice);
 void osc_io_lseek_end(const struct lu_env *env,
 		      const struct cl_io_slice *slice);
+int osc_io_lru_reserve(const struct lu_env *env, const struct cl_io_slice *ios,
+		       loff_t pos, size_t count);
 
 /* osc_lock.c */
 void osc_lock_to_lockless(const struct lu_env *env, struct osc_lock *ols,
diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index 2558a60..e9f0fc9 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -1564,8 +1564,10 @@ static void ll_heat_add(struct inode *inode, enum cl_io_type iot,
 		   struct file *file, enum cl_io_type iot,
 		   loff_t *ppos, size_t count)
 {
-	struct ll_inode_info *lli = ll_i2info(file_inode(file));
+	struct inode *inode = file_inode(file);
+	struct ll_inode_info *lli = ll_i2info(inode);
 	struct ll_file_data *fd = file->private_data;
+	struct ll_sb_info *sbi = ll_i2sbi(inode);
 	struct vvp_io *vio = vvp_env_io(env);
 	struct range_lock range;
 	struct cl_io *io;
@@ -1575,10 +1577,18 @@ static void ll_heat_add(struct inode *inode, enum cl_io_type iot,
 	unsigned int dio_lock = 0;
 	bool is_aio = false;
 	struct cl_dio_aio *ci_aio = NULL;
+	size_t per_bytes;
+	bool partial_io = false;
+	size_t max_io_pages, max_cached_pages;
 
 	CDEBUG(D_VFSTRACE, "file: %pD, type: %d ppos: %llu, count: %zu\n",
 	       file, iot, *ppos, count);
 
+	max_io_pages = PTLRPC_MAX_BRW_PAGES * OBD_MAX_RIF_DEFAULT;
+	max_cached_pages = sbi->ll_cache->ccc_lru_max;
+	if (max_io_pages > (max_cached_pages >> 2))
+		max_io_pages = max_cached_pages >> 2;
+
 	io = vvp_env_thread_io(env);
 	if (file->f_flags & O_DIRECT) {
 		if (!is_sync_kiocb(args->u.normal.via_iocb))
@@ -1591,19 +1601,29 @@ static void ll_heat_add(struct inode *inode, enum cl_io_type iot,
 	}
 
 restart:
+	/**
+	 * IO block size need be aware of cached page limit, otherwise
+	 * if we have small max_cached_mb but large block IO issued, io
+	 * could not be finished and blocked whole client.
+	 */
+	if (file->f_flags & O_DIRECT)
+		per_bytes = count;
+	else
+		per_bytes = min(max_io_pages << PAGE_SHIFT, count);
+	partial_io = per_bytes < count;
 	io = vvp_env_thread_io(env);
 	ll_io_init(io, file, iot == CIT_WRITE, args);
 	io->ci_aio = ci_aio;
 	io->ci_dio_lock = dio_lock;
 	io->ci_ndelay_tried = retried;
 
-	if (cl_io_rw_init(env, io, iot, *ppos, count) == 0) {
+	if (cl_io_rw_init(env, io, iot, *ppos, per_bytes) == 0) {
 		bool range_locked = false;
 
 		if (file->f_flags & O_APPEND)
 			range_lock_init(&range, 0, LUSTRE_EOF);
 		else
-			range_lock_init(&range, *ppos, *ppos + count - 1);
+			range_lock_init(&range, *ppos, *ppos + per_bytes - 1);
 
 		vio->vui_fd  = file->private_data;
 		vio->vui_iter = args->u.normal.via_iter;
@@ -1656,6 +1676,16 @@ static void ll_heat_add(struct inode *inode, enum cl_io_type iot,
 		/* prepare IO restart */
 		if (count > 0)
 			args->u.normal.via_iter = vio->vui_iter;
+
+		if (partial_io) {
+			/**
+			 * Reexpand iov count because it was zero
+			 * after IO finish.
+			 */
+			iov_iter_reexpand(vio->vui_iter, count);
+			if (per_bytes == io->ci_nob)
+				io->ci_need_restart = 1;
+		}
 	}
 out:
 	cl_io_fini(env, io);
diff --git a/fs/lustre/llite/rw.c b/fs/lustre/llite/rw.c
index 2d08767..c64696d 100644
--- a/fs/lustre/llite/rw.c
+++ b/fs/lustre/llite/rw.c
@@ -86,7 +86,14 @@ static unsigned long ll_ra_count_get(struct ll_sb_info *sbi,
 	struct ll_ra_info *ra = &sbi->ll_ra_info;
 	long ret;
 
-	/* If read-ahead pages left are less than 1M, do not do read-ahead,
+	/**
+	 * Don't try readahead agreesively if we are limited
+	 * LRU pages, otherwise, it could cause deadlock.
+	 */
+	pages = min(sbi->ll_cache->ccc_lru_max >> 2, pages);
+
+	/*
+	 * If read-ahead pages left are less than 1M, do not do read-ahead,
 	 * otherwise it will form small read RPC(< 1M), which hurt server
 	 * performance a lot.
 	 */
@@ -701,11 +708,24 @@ static int ll_readahead(const struct lu_env *env, struct cl_io *io,
 	struct inode *inode;
 	struct ra_io_arg *ria = &lti->lti_ria;
 	struct cl_object *clob;
+	struct ll_sb_info *sbi;
+	struct ll_ra_info *ra;
 	int ret = 0;
 	u64 kms;
 
 	clob = io->ci_obj;
 	inode = vvp_object_inode(clob);
+	sbi = ll_i2sbi(inode);
+	ra = &sbi->ll_ra_info;
+
+	/**
+	 * In case we have a limited max_cached_mb, readahead
+	 * should be stopped if it have run out of all LRU slots.
+	 */
+	if (atomic_read(&ra->ra_cur_pages) >= sbi->ll_cache->ccc_lru_max) {
+		ll_ra_stats_inc(inode, RA_STAT_MAX_IN_FLIGHT);
+		return 0;
+	}
 
 	memset(ria, 0, sizeof(*ria));
 	ret = ll_readahead_file_kms(env, io, &kms);
@@ -1706,6 +1726,15 @@ static int kickoff_async_readahead(struct file *file, unsigned long pages)
 	pgoff_t start_idx = ras_align(ras, ras->ras_next_readahead_idx);
 	pgoff_t end_idx = start_idx + pages - 1;
 
+	/**
+	 * In case we have a limited max_cached_mb, readahead
+	 * should be stopped if it have run out of all LRU slots.
+	 */
+	if (atomic_read(&ra->ra_cur_pages) >= sbi->ll_cache->ccc_lru_max) {
+		ll_ra_stats_inc(inode, RA_STAT_MAX_IN_FLIGHT);
+		return 0;
+	}
+
 	throttle = min(ra->ra_async_pages_per_file_threshold,
 		       ra->ra_max_pages_per_file);
 	/*
diff --git a/fs/lustre/llite/vvp_io.c b/fs/lustre/llite/vvp_io.c
index ac6aef0..cb59e94 100644
--- a/fs/lustre/llite/vvp_io.c
+++ b/fs/lustre/llite/vvp_io.c
@@ -798,6 +798,12 @@ static int vvp_io_read_start(const struct lu_env *env,
 	if (!can_populate_pages(env, io, inode))
 		return 0;
 
+	if (!(file->f_flags & O_DIRECT)) {
+		result = cl_io_lru_reserve(env, io, pos, cnt);
+		if (result)
+			return result;
+	}
+
 	/* Unless this is reading a sparse file, otherwise the lock has already
 	 * been acquired so vvp_prep_size() is an empty op.
 	 */
@@ -1175,6 +1181,12 @@ static int vvp_io_write_start(const struct lu_env *env,
 	if (OBD_FAIL_CHECK(OBD_FAIL_LLITE_IMUTEX_NOSEC) && lock_inode)
 		return -EINVAL;
 
+	if (!(file->f_flags & O_DIRECT)) {
+		result = cl_io_lru_reserve(env, io, pos, cnt);
+		if (result)
+			return result;
+	}
+
 	if (!vio->vui_iter) {
 		/* from a temp io in ll_cl_init(). */
 		result = 0;
diff --git a/fs/lustre/lov/lov_io.c b/fs/lustre/lov/lov_io.c
index 9f67d16..ae9d547 100644
--- a/fs/lustre/lov/lov_io.c
+++ b/fs/lustre/lov/lov_io.c
@@ -1179,6 +1179,58 @@ static int lov_io_read_ahead(const struct lu_env *env,
 	return 0;
 }
 
+int lov_io_lru_reserve(const struct lu_env *env,
+		       const struct cl_io_slice *ios, loff_t pos, size_t bytes)
+{
+	struct lov_io *lio = cl2lov_io(env, ios);
+	struct lov_stripe_md *lsm = lio->lis_object->lo_lsm;
+	struct lov_io_sub *sub;
+	struct lu_extent ext;
+	int index;
+	int rc = 0;
+
+	ext.e_start = pos;
+	ext.e_end = pos + bytes;
+	lov_foreach_io_layout(index, lio, &ext) {
+		struct lov_layout_entry *le = lov_entry(lio->lis_object, index);
+		struct lov_layout_raid0 *r0 = &le->lle_raid0;
+		u64 start;
+		u64 end;
+		int stripe;
+
+		if (!lsm_entry_inited(lsm, index))
+			continue;
+
+		if (!le->lle_valid && !ios->cis_io->ci_designated_mirror) {
+			CERROR(DFID": I/O to invalid component: %d, mirror: %d\n",
+			       PFID(lu_object_fid(lov2lu(lio->lis_object))),
+			       index, lio->lis_mirror_index);
+			return -EIO;
+		}
+
+		for (stripe = 0; stripe < r0->lo_nr; stripe++) {
+			if (!lov_stripe_intersects(lsm, index, stripe,
+						   &ext, &start, &end))
+				continue;
+
+			if (unlikely(!r0->lo_sub[stripe]))
+				return -EIO;
+
+			sub = lov_sub_get(env, lio,
+					  lov_comp_index(index, stripe));
+			if (IS_ERR(sub))
+				return PTR_ERR(sub);
+
+			rc = cl_io_lru_reserve(sub->sub_env, &sub->sub_io,
+					       start, end - start + 1);
+			if (rc != 0)
+				return rc;
+		}
+	}
+
+	return 0;
+}
+
 /**
  * lov implementation of cl_operations::cio_submit() method. It takes a list
  * of pages in @queue, splits it into per-stripe sub-lists, invokes
@@ -1581,6 +1633,7 @@ static void lov_io_lseek_end(const struct lu_env *env,
 		}
 	},
 	.cio_read_ahead			= lov_io_read_ahead,
+	.cio_lru_reserve		= lov_io_lru_reserve,
 	.cio_submit			= lov_io_submit,
 	.cio_commit_async		= lov_io_commit_async,
 };
diff --git a/fs/lustre/mdc/mdc_dev.c b/fs/lustre/mdc/mdc_dev.c
index 39c1213..7807f9e 100644
--- a/fs/lustre/mdc/mdc_dev.c
+++ b/fs/lustre/mdc/mdc_dev.c
@@ -1113,12 +1113,14 @@ static int mdc_io_read_ahead(const struct lu_env *env,
 			     pgoff_t start, struct cl_read_ahead *ra)
 {
 	struct osc_object *osc = cl2osc(ios->cis_obj);
+	struct osc_io *oio = cl2osc_io(env, ios);
 	struct ldlm_lock *dlmlock;
 
 	dlmlock = mdc_dlmlock_at_pgoff(env, osc, start, 0);
 	if (!dlmlock)
 		return -ENODATA;
 
+	oio->oi_is_readahead = 1;
 	if (dlmlock->l_req_mode != LCK_PR) {
 		struct lustre_handle lockh;
 
@@ -1130,7 +1132,8 @@ static int mdc_io_read_ahead(const struct lu_env *env,
 	ra->cra_rpc_pages = osc_cli(osc)->cl_max_pages_per_rpc;
 	ra->cra_end_idx = CL_PAGE_EOF;
 	ra->cra_release = osc_read_ahead_release;
-	ra->cra_cbdata = dlmlock;
+	ra->cra_dlmlock = dlmlock;
+	ra->cra_oio = oio;
 
 	return 0;
 }
@@ -1287,12 +1290,12 @@ static void mdc_io_data_version_end(const struct lu_env *env,
 static const struct cl_io_operations mdc_io_ops = {
 	.op = {
 		[CIT_READ] = {
-			.cio_iter_init	= osc_io_rw_iter_init,
+			.cio_iter_init	= osc_io_iter_init,
 			.cio_iter_fini	= osc_io_rw_iter_fini,
 			.cio_start	= osc_io_read_start,
 		},
 		[CIT_WRITE] = {
-			.cio_iter_init	= osc_io_rw_iter_init,
+			.cio_iter_init	= osc_io_iter_init,
 			.cio_iter_fini	= osc_io_rw_iter_fini,
 			.cio_start	= osc_io_write_start,
 			.cio_end	= osc_io_end,
@@ -1323,6 +1326,7 @@ static void mdc_io_data_version_end(const struct lu_env *env,
 		},
 	},
 	.cio_read_ahead		= mdc_io_read_ahead,
+	.cio_lru_reserve	= osc_io_lru_reserve,
 	.cio_submit		= osc_io_submit,
 	.cio_commit_async	= osc_io_commit_async,
 	.cio_extent_release	= osc_io_extent_release,
diff --git a/fs/lustre/obdclass/cl_io.c b/fs/lustre/obdclass/cl_io.c
index 138ff27..27804d3 100644
--- a/fs/lustre/obdclass/cl_io.c
+++ b/fs/lustre/obdclass/cl_io.c
@@ -573,6 +573,34 @@ int cl_io_read_ahead(const struct lu_env *env, struct cl_io *io,
 EXPORT_SYMBOL(cl_io_read_ahead);
 
 /**
+ * Called before io start, to reserve enough LRU slots to avoid
+ * deadlock.
+ *
+ * \see cl_io_operations::cio_lru_reserve()
+ */
+int cl_io_lru_reserve(const struct lu_env *env, struct cl_io *io,
+		      loff_t pos, size_t bytes)
+{
+	const struct cl_io_slice *scan;
+	int result = 0;
+
+	LINVRNT(io->ci_type == CIT_READ || io->ci_type == CIT_WRITE);
+	LINVRNT(cl_io_invariant(io));
+
+	list_for_each_entry(scan, &io->ci_layers, cis_linkage) {
+		if (scan->cis_iop->cio_lru_reserve) {
+			result = scan->cis_iop->cio_lru_reserve(env, scan,
+								pos, bytes);
+			if (result)
+				break;
+		}
+	}
+
+	return result;
+}
+EXPORT_SYMBOL(cl_io_lru_reserve);
+
+/**
  * Commit a list of contiguous pages into writeback cache.
  *
  * \returns 0 if all pages committed, or errcode if error occurred.
diff --git a/fs/lustre/osc/osc_io.c b/fs/lustre/osc/osc_io.c
index b965608..9d783e0 100644
--- a/fs/lustre/osc/osc_io.c
+++ b/fs/lustre/osc/osc_io.c
@@ -59,11 +59,13 @@ static void osc_io_fini(const struct lu_env *env, const struct cl_io_slice *io)
 {
 }
 
-void osc_read_ahead_release(const struct lu_env *env, void *cbdata)
+void osc_read_ahead_release(const struct lu_env *env, struct cl_read_ahead *ra)
 {
-	struct ldlm_lock *dlmlock = cbdata;
+	struct ldlm_lock *dlmlock = ra->cra_dlmlock;
+	struct osc_io *oio = ra->cra_oio;
 	struct lustre_handle lockh;
 
+	oio->oi_is_readahead = 0;
 	ldlm_lock2handle(dlmlock, &lockh);
 	ldlm_lock_decref(&lockh, LCK_PR);
 	LDLM_LOCK_PUT(dlmlock);
@@ -75,9 +77,11 @@ static int osc_io_read_ahead(const struct lu_env *env,
 			     pgoff_t start, struct cl_read_ahead *ra)
 {
 	struct osc_object *osc = cl2osc(ios->cis_obj);
+	struct osc_io *oio = cl2osc_io(env, ios);
 	struct ldlm_lock *dlmlock;
 	int result = -ENODATA;
 
+	oio->oi_is_readahead = true;
 	dlmlock = osc_dlmlock_at_pgoff(env, osc, start, 0);
 	if (dlmlock) {
 		LASSERT(dlmlock->l_ast_data == osc);
@@ -93,7 +97,8 @@ static int osc_io_read_ahead(const struct lu_env *env,
 		ra->cra_end_idx = cl_index(osc2cl(osc),
 					   dlmlock->l_policy_data.l_extent.end);
 		ra->cra_release = osc_read_ahead_release;
-		ra->cra_cbdata = dlmlock;
+		ra->cra_dlmlock = dlmlock;
+		ra->cra_oio = oio;
 		if (ra->cra_end_idx != CL_PAGE_EOF)
 			ra->cra_contention = true;
 		result = 0;
@@ -421,27 +426,6 @@ int osc_io_iter_init(const struct lu_env *env, const struct cl_io_slice *ios)
 }
 EXPORT_SYMBOL(osc_io_iter_init);
 
-int osc_io_rw_iter_init(const struct lu_env *env,
-			const struct cl_io_slice *ios)
-{
-	struct cl_io *io = ios->cis_io;
-	struct osc_io *oio = osc_env_io(env);
-	struct osc_object *osc = cl2osc(ios->cis_obj);
-	unsigned long npages;
-
-	if (cl_io_is_append(io))
-		return osc_io_iter_init(env, ios);
-
-	npages = io->u.ci_rw.crw_count >> PAGE_SHIFT;
-	if (io->u.ci_rw.crw_pos & ~PAGE_MASK)
-		++npages;
-
-	oio->oi_lru_reserved = osc_lru_reserve(osc_cli(osc), npages);
-
-	return osc_io_iter_init(env, ios);
-}
-EXPORT_SYMBOL(osc_io_rw_iter_init);
-
 void osc_io_iter_fini(const struct lu_env *env,
 		      const struct cl_io_slice *ios)
 {
@@ -1177,16 +1161,40 @@ void osc_io_lseek_end(const struct lu_env *env,
 }
 EXPORT_SYMBOL(osc_io_lseek_end);
 
+int osc_io_lru_reserve(const struct lu_env *env,
+		       const struct cl_io_slice *ios,
+		       loff_t pos, size_t bytes)
+{
+	struct osc_object *osc = cl2osc(ios->cis_obj);
+	struct osc_io *oio = osc_env_io(env);
+	unsigned long npages = 0;
+	size_t page_offset;
+
+	page_offset = pos & ~PAGE_MASK;
+	if (page_offset) {
+		++npages;
+		if (bytes > PAGE_SIZE - page_offset)
+			bytes -= (PAGE_SIZE - page_offset);
+		else
+			bytes = 0;
+	}
+	npages += (bytes + PAGE_SIZE - 1) >> PAGE_SHIFT;
+	oio->oi_lru_reserved = osc_lru_reserve(osc_cli(osc), npages);
+
+	return 0;
+}
+EXPORT_SYMBOL(osc_io_lru_reserve);
+
 static const struct cl_io_operations osc_io_ops = {
 	.op = {
 		[CIT_READ] = {
-			.cio_iter_init	= osc_io_rw_iter_init,
+			.cio_iter_init	= osc_io_iter_init,
 			.cio_iter_fini	= osc_io_rw_iter_fini,
 			.cio_start	= osc_io_read_start,
 			.cio_fini	= osc_io_fini
 		},
 		[CIT_WRITE] = {
-			.cio_iter_init	= osc_io_rw_iter_init,
+			.cio_iter_init	= osc_io_iter_init,
 			.cio_iter_fini	= osc_io_rw_iter_fini,
 			.cio_start	= osc_io_write_start,
 			.cio_end	= osc_io_end,
@@ -1229,6 +1237,7 @@ void osc_io_lseek_end(const struct lu_env *env,
 		}
 	},
 	.cio_read_ahead			= osc_io_read_ahead,
+	.cio_lru_reserve		= osc_io_lru_reserve,
 	.cio_submit			= osc_io_submit,
 	.cio_commit_async		= osc_io_commit_async,
 	.cio_extent_release		= osc_io_extent_release
diff --git a/fs/lustre/osc/osc_page.c b/fs/lustre/osc/osc_page.c
index bb605af..c59a5ac 100644
--- a/fs/lustre/osc/osc_page.c
+++ b/fs/lustre/osc/osc_page.c
@@ -793,6 +793,13 @@ static int osc_lru_alloc(const struct lu_env *env, struct client_obd *cli,
 			break;
 		if (rc > 0)
 			continue;
+		/* IO issued by readahead, don't try hard */
+		if (oio->oi_is_readahead) {
+			if (atomic_long_read(cli->cl_lru_left) > 0)
+				continue;
+			rc = -EBUSY;
+			break;
+		}
 
 		cond_resched();
 
@@ -824,18 +831,23 @@ unsigned long osc_lru_reserve(struct client_obd *cli, unsigned long npages)
 	unsigned long reserved = 0;
 	unsigned long max_pages;
 	unsigned long c;
+	int rc;
 
-	/*
-	 * reserve a full RPC window at most to avoid that a thread accidentally
-	 * consumes too many LRU slots
-	 */
-	max_pages = cli->cl_max_pages_per_rpc * cli->cl_max_rpcs_in_flight;
-	if (npages > max_pages)
-		npages = max_pages;
-
+again:
 	c = atomic_long_read(cli->cl_lru_left);
 	if (c < npages && osc_lru_reclaim(cli, npages) > 0)
 		c = atomic_long_read(cli->cl_lru_left);
+
+	if (c < npages) {
+		/*
+		 * Trigger writeback in the hope some LRU slot could
+		 * be freed.
+		 */
+		rc = ptlrpcd_queue_work(cli->cl_writeback_work);
+		if (rc)
+			return 0;
+	}
+
 	while (c >= npages) {
 		if (c == atomic_long_cmpxchg(cli->cl_lru_left, c, c - npages)) {
 			reserved = npages;
@@ -843,6 +855,16 @@ unsigned long osc_lru_reserve(struct client_obd *cli, unsigned long npages)
 		}
 		c = atomic_long_read(cli->cl_lru_left);
 	}
+
+	if (reserved != npages) {
+		cond_resched();
+		rc = l_wait_event_abortable(
+			osc_lru_waitq,
+			atomic_long_read(cli->cl_lru_left) > 0);
+		goto again;
+	}
+
+	max_pages = cli->cl_max_pages_per_rpc * cli->cl_max_rpcs_in_flight;
 	if (atomic_long_read(cli->cl_lru_left) < max_pages) {
 		/*
 		 * If there aren't enough pages in the per-OSC LRU then
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
