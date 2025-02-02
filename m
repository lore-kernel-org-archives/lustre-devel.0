Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 2D6D5C02193
	for <lustre-devel@archiver.kernel.org>; Sun,  2 Feb 2025 20:54:08 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4YmMDh6Y94z20y3;
	Sun, 02 Feb 2025 12:49:08 -0800 (PST)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4YmMBN2Sghz1yWd
 for <lustre-devel@lists.lustre.org>; Sun, 02 Feb 2025 12:47:08 -0800 (PST)
Received: from star2.ccs.ornl.gov (ltm-e204-208.ccs.ornl.gov [160.91.203.12])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id BB827899AD6;
 Sun,  2 Feb 2025 15:46:41 -0500 (EST)
Received: by star2.ccs.ornl.gov (Postfix, from userid 2004)
 id BA0DB106BE15; Sun,  2 Feb 2025 15:46:41 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun,  2 Feb 2025 15:46:09 -0500
Message-ID: <20250202204633.1148872-10-jsimmons@infradead.org>
X-Mailer: git-send-email 2.43.5
In-Reply-To: <20250202204633.1148872-1-jsimmons@infradead.org>
References: <20250202204633.1148872-1-jsimmons@infradead.org>
MIME-Version: 1.0
Subject: [lustre-devel] [PATCH 09/33] lustre: remove cl_{offset, index,
 page_size} helpers
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
Cc: Wang Shilong <wshilong@ddn.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Wang Shilong <wshilong@ddn.com>

These helpers could be replaced with PAGE_SIZE and PAGE_SHIFT calculation
directly which avoid CPU overhead.

WC-bug-id: https://jira.whamcloud.com/browse/LU-13199
Lustre-commit: b34bf55f9493778c3 ("LU-13199 lustre: remove cl_{offset,index,page_size} helpers")
Signed-off-by: Wang Shilong <wshilong@ddn.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/37426
Reviewed-by: Neil Brown <neilb@suse.de>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/cl_object.h |  2 --
 fs/lustre/llite/file.c        |  4 ++--
 fs/lustre/llite/llite_lib.c   |  4 ++--
 fs/lustre/llite/llite_mmap.c  |  4 ++--
 fs/lustre/llite/rw.c          |  8 ++++----
 fs/lustre/llite/rw26.c        |  4 ++--
 fs/lustre/llite/vvp_io.c      | 20 ++++++++------------
 fs/lustre/lov/lov_io.c        | 19 ++++++++-----------
 fs/lustre/lov/lov_lock.c      |  8 ++++----
 fs/lustre/lov/lov_page.c      | 16 ++++++++--------
 fs/lustre/mdc/mdc_dev.c       |  4 ++--
 fs/lustre/obdclass/cl_page.c  | 24 ------------------------
 fs/lustre/osc/osc_cache.c     | 25 ++++++++++++-------------
 fs/lustre/osc/osc_io.c        | 28 ++++++++++++++--------------
 fs/lustre/osc/osc_lock.c      | 20 ++++++++++----------
 fs/lustre/osc/osc_page.c      |  6 +++---
 16 files changed, 81 insertions(+), 115 deletions(-)

diff --git a/fs/lustre/include/cl_object.h b/fs/lustre/include/cl_object.h
index 94e7f8060d4a..9d940cbdb249 100644
--- a/fs/lustre/include/cl_object.h
+++ b/fs/lustre/include/cl_object.h
@@ -2260,8 +2260,6 @@ void cl_page_discard(const struct lu_env *env, struct cl_io *io,
 void cl_page_delete(const struct lu_env *env, struct cl_page *pg);
 void cl_page_touch(const struct lu_env *env, const struct cl_page *pg,
 		   size_t to);
-loff_t cl_offset(const struct cl_object *obj, pgoff_t idx);
-pgoff_t cl_index(const struct cl_object *obj, loff_t offset);
 int cl_pages_prune(const struct lu_env *env, struct cl_object *obj);
 
 void cl_lock_print(const struct lu_env *env, void *cookie,
diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index b2751b571ea9..e5bbe35de473 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -3471,8 +3471,8 @@ int ll_file_lock_ahead(struct file *file, struct llapi_lu_ladvise *ladvise)
 
 		descr->cld_obj = io->ci_obj;
 		/* Convert byte offsets to pages */
-		descr->cld_start = cl_index(io->ci_obj, start);
-		descr->cld_end = cl_index(io->ci_obj, end);
+		descr->cld_start = start >> PAGE_SHIFT;
+		descr->cld_end = end >> PAGE_SHIFT;
 		descr->cld_mode = cl_mode;
 		/* CEF_MUST is used because we do not want to convert a
 		 * lockahead request to a lockless lock
diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index a9acce572e32..908ca3d43ee3 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -1922,8 +1922,8 @@ int ll_io_zero_page(struct inode *inode, pgoff_t index, pgoff_t offset,
 	lock = vvp_env_lock(env);
 	descr = &lock->cll_descr;
 	descr->cld_obj = io->ci_obj;
-	descr->cld_start = cl_index(io->ci_obj, from);
-	descr->cld_end = cl_index(io->ci_obj, from + PAGE_SIZE - 1);
+	descr->cld_start = from >> PAGE_SHIFT;
+	descr->cld_end = (from + PAGE_SIZE - 1) >> PAGE_SHIFT;
 	descr->cld_mode = CLM_WRITE;
 	descr->cld_enq_flags = CEF_MUST | CEF_NONBLOCK;
 
diff --git a/fs/lustre/llite/llite_mmap.c b/fs/lustre/llite/llite_mmap.c
index d6c1a6fd0794..509855837582 100644
--- a/fs/lustre/llite/llite_mmap.c
+++ b/fs/lustre/llite/llite_mmap.c
@@ -449,7 +449,7 @@ static vm_fault_t ll_fault(struct vm_fault *vmf)
 	if (vmf->page && result == VM_FAULT_LOCKED) {
 		ll_rw_stats_tally(ll_i2sbi(file_inode(vma->vm_file)),
 				  current->pid, vma->vm_file->private_data,
-				  cl_offset(NULL, vmf->page->index), PAGE_SIZE,
+				  vmf->page->index << PAGE_SHIFT, PAGE_SIZE,
 				  READ);
 		ll_stats_ops_tally(ll_i2sbi(file_inode(vma->vm_file)),
 				   LPROC_LL_FAULT,
@@ -522,7 +522,7 @@ static vm_fault_t ll_page_mkwrite(struct vm_fault *vmf)
 	if (ret == VM_FAULT_LOCKED) {
 		ll_rw_stats_tally(ll_i2sbi(file_inode(vma->vm_file)),
 				  current->pid, vma->vm_file->private_data,
-				  cl_offset(NULL, vmf->page->index), PAGE_SIZE,
+				  vmf->page->index << PAGE_SHIFT, PAGE_SIZE,
 				  WRITE);
 		ll_stats_ops_tally(ll_i2sbi(file_inode(vma->vm_file)),
 				   LPROC_LL_MKWRITE,
diff --git a/fs/lustre/llite/rw.c b/fs/lustre/llite/rw.c
index 9b1cf71116df..c7adfc6d4faf 100644
--- a/fs/lustre/llite/rw.c
+++ b/fs/lustre/llite/rw.c
@@ -1513,7 +1513,7 @@ int ll_writepage(struct page *vmpage, struct writeback_control *wbc)
 	cl_io_fini(env, io);
 
 	if (redirtied && wbc->sync_mode == WB_SYNC_ALL) {
-		loff_t offset = cl_offset(clob, vmpage->index);
+		loff_t offset = vmpage->index << PAGE_SHIFT;
 
 		/* Flush page failed because the extent is being written out.
 		 * Wait for the write of extent to be finished to avoid
@@ -1695,9 +1695,9 @@ int ll_io_read_page(const struct lu_env *env, struct cl_io *io,
 
 	/* mmap does not set the ci_rw fields */
 	if (!mmap) {
-		io_start_index = cl_index(io->ci_obj, io->u.ci_rw.crw_pos);
-		io_end_index = cl_index(io->ci_obj, io->u.ci_rw.crw_pos +
-					io->u.ci_rw.crw_count - 1);
+		io_start_index = io->u.ci_rw.crw_pos >> PAGE_SHIFT;
+		io_end_index = (io->u.ci_rw.crw_pos +
+				io->u.ci_rw.crw_count - 1) >> PAGE_SHIFT;
 	} else {
 		io_start_index = cl_page_index(page);
 		io_end_index = cl_page_index(page);
diff --git a/fs/lustre/llite/rw26.c b/fs/lustre/llite/rw26.c
index 2065e14e8469..5f0186cb9ecb 100644
--- a/fs/lustre/llite/rw26.c
+++ b/fs/lustre/llite/rw26.c
@@ -217,7 +217,7 @@ ll_direct_rw_pages(const struct lu_env *env, struct cl_io *io, size_t size,
 	cl_2queue_init(queue);
 	for (i = 0; i < pv->ldp_count; i++) {
 		LASSERT(!(offset & (PAGE_SIZE - 1)));
-		page = cl_page_find(env, obj, cl_index(obj, offset),
+		page = cl_page_find(env, obj, offset >> PAGE_SHIFT,
 				    pv->ldp_pages[i], CPT_TRANSIENT);
 		if (IS_ERR(page)) {
 			rc = PTR_ERR(page);
@@ -451,7 +451,7 @@ static int ll_prepare_partial_page(const struct lu_env *env, struct cl_io *io,
 {
 	struct cl_attr *attr = vvp_env_thread_attr(env);
 	struct cl_object *obj = io->ci_obj;
-	loff_t offset = cl_offset(obj, cl_page_index(pg));
+	loff_t offset = cl_page_index(pg) << PAGE_SHIFT;
 	int result;
 
 	cl_object_attr_lock(obj);
diff --git a/fs/lustre/llite/vvp_io.c b/fs/lustre/llite/vvp_io.c
index 86dab3b1a39f..1b5628d1502d 100644
--- a/fs/lustre/llite/vvp_io.c
+++ b/fs/lustre/llite/vvp_io.c
@@ -239,10 +239,8 @@ static int vvp_io_one_lock(const struct lu_env *env, struct cl_io *io,
 			   u32 enqflags, enum cl_lock_mode mode,
 			   loff_t start, loff_t end)
 {
-	struct cl_object *obj = io->ci_obj;
-
 	return vvp_io_one_lock_index(env, io, enqflags, mode,
-				     cl_index(obj, start), cl_index(obj, end));
+				     start >> PAGE_SHIFT, end >> PAGE_SHIFT);
 }
 
 static int vvp_io_write_iter_init(const struct lu_env *env,
@@ -483,10 +481,8 @@ static int vvp_mmap_locks(const struct lu_env *env,
 			policy_from_vma(&policy, vma, addr, count);
 			descr->cld_mode = vvp_mode_from_vma(vma);
 			descr->cld_obj = ll_i2info(inode)->lli_clob;
-			descr->cld_start = cl_index(descr->cld_obj,
-						    policy.l_extent.start);
-			descr->cld_end = cl_index(descr->cld_obj,
-						  policy.l_extent.end);
+			descr->cld_start = policy.l_extent.start >> PAGE_SHIFT;
+			descr->cld_end = policy.l_extent.end >> PAGE_SHIFT;
 			descr->cld_enq_flags = flags;
 			result = cl_io_lock_alloc_add(env, io, descr);
 
@@ -854,7 +850,7 @@ static int vvp_io_read_start(const struct lu_env *env,
 	/* initialize read-ahead window once per syscall */
 	if (!vio->vui_ra_valid) {
 		vio->vui_ra_valid = true;
-		vio->vui_ra_start_idx = cl_index(obj, pos);
+		vio->vui_ra_start_idx = pos >> PAGE_SHIFT;
 		vio->vui_ra_pages = 0;
 		page_offset = pos & ~PAGE_MASK;
 		if (page_offset) {
@@ -1408,8 +1404,8 @@ static int vvp_io_fault_start(const struct lu_env *env,
 	trunc_sem_down_read_nowait(&lli->lli_trunc_sem);
 
 	/* offset of the last byte on the page */
-	offset = cl_offset(obj, fio->ft_index + 1) - 1;
-	LASSERT(cl_index(obj, offset) == fio->ft_index);
+	offset = ((fio->ft_index + 1) << PAGE_SHIFT) - 1;
+	LASSERT((offset >> PAGE_SHIFT) == fio->ft_index);
 	result = vvp_prep_size(env, obj, io, 0, offset + 1, NULL);
 	if (result != 0)
 		return result;
@@ -1445,7 +1441,7 @@ static int vvp_io_fault_start(const struct lu_env *env,
 		goto out;
 	}
 
-	last_index = cl_index(obj, size - 1);
+	last_index = (size - 1) >> PAGE_SHIFT;
 
 	if (fio->ft_mkwrite) {
 		/*
@@ -1558,7 +1554,7 @@ static int vvp_io_fault_start(const struct lu_env *env,
 		/*
 		 * Last page is mapped partially.
 		 */
-		fio->ft_nob = size - cl_offset(obj, fio->ft_index);
+		fio->ft_nob = size - (fio->ft_index << PAGE_SHIFT);
 	else
 		fio->ft_nob = PAGE_SIZE;
 
diff --git a/fs/lustre/lov/lov_io.c b/fs/lustre/lov/lov_io.c
index 4c842cd2b67d..eda8e3752a15 100644
--- a/fs/lustre/lov/lov_io.c
+++ b/fs/lustre/lov/lov_io.c
@@ -514,8 +514,8 @@ static int lov_io_slice_init(struct lov_io *lio, struct lov_object *obj,
 	case CIT_FAULT: {
 		pgoff_t index = io->u.ci_fault.ft_index;
 
-		lio->lis_pos = cl_offset(io->ci_obj, index);
-		lio->lis_endpos = cl_offset(io->ci_obj, index + 1);
+		lio->lis_pos = index << PAGE_SHIFT;
+		lio->lis_endpos = (index + 1) << PAGE_SHIFT;
 		break;
 	}
 
@@ -699,12 +699,11 @@ static void lov_io_sub_inherit(struct lov_io_sub *sub, struct lov_io *lio,
 		break;
 	}
 	case CIT_FAULT: {
-		struct cl_object *obj = parent->ci_obj;
-		u64 off = cl_offset(obj, parent->u.ci_fault.ft_index);
+		loff_t off = parent->u.ci_fault.ft_index << PAGE_SHIFT;
 
 		io->u.ci_fault = parent->u.ci_fault;
 		off = lov_size_to_stripe(lsm, index, off, stripe);
-		io->u.ci_fault.ft_index = cl_index(obj, off);
+		io->u.ci_fault.ft_index = off >> PAGE_SHIFT;
 		break;
 	}
 	case CIT_FSYNC: {
@@ -1131,7 +1130,6 @@ static int lov_io_read_ahead(const struct lu_env *env,
 {
 	struct lov_io *lio = cl2lov_io(env, ios);
 	struct lov_object *loo = lio->lis_object;
-	struct cl_object *obj = lov2cl(loo);
 	struct lov_layout_raid0 *r0;
 	unsigned int pps; /* pages per stripe */
 	struct lov_io_sub *sub;
@@ -1142,7 +1140,7 @@ static int lov_io_read_ahead(const struct lu_env *env,
 	int index;
 	int rc;
 
-	offset = cl_offset(obj, start);
+	offset = start << PAGE_SHIFT;
 	index = lov_io_layout_at(lio, offset);
 	if (index < 0 || !lsm_entry_inited(loo->lo_lsm, index) ||
 	    lsm_entry_is_foreign(loo->lo_lsm, index))
@@ -1164,8 +1162,7 @@ static int lov_io_read_ahead(const struct lu_env *env,
 
 	lov_stripe_offset(loo->lo_lsm, index, offset, stripe, &suboff);
 	rc = cl_io_read_ahead(sub->sub_env, &sub->sub_io,
-			      cl_index(lovsub2cl(r0->lo_sub[stripe]), suboff),
-			      ra);
+			      suboff >> PAGE_SHIFT, ra);
 
 	CDEBUG(D_READA, DFID " cra_end = %lu, stripes = %d, rc = %d\n",
 	       PFID(lu_object_fid(lov2lu(loo))), ra->cra_end_idx,
@@ -1188,7 +1185,7 @@ static int lov_io_read_ahead(const struct lu_env *env,
 						   ra_end, stripe);
 
 	/* boundary of current component */
-	ra_end = cl_index(obj, (loff_t)lov_io_extent(lio, index)->e_end);
+	ra_end = lov_io_extent(lio, index)->e_end >> PAGE_SHIFT;
 	if (ra_end != CL_PAGE_EOF && ra->cra_end_idx >= ra_end)
 		ra->cra_end_idx = ra_end - 1;
 
@@ -1444,7 +1441,7 @@ static int lov_io_fault_start(const struct lu_env *env,
 	 * refer to another mirror of an old IO.
 	 */
 	if (lov_is_flr(lio->lis_object)) {
-		offset = cl_offset(ios->cis_obj, fio->ft_index);
+		offset = fio->ft_index << PAGE_SHIFT;
 		entry = lov_io_layout_at(lio, offset);
 		if (entry < 0) {
 			CERROR(DFID": page fault index %lu invalid component: %d, mirror: %d\n",
diff --git a/fs/lustre/lov/lov_lock.c b/fs/lustre/lov/lov_lock.c
index 313c09ae0e24..f2b24cabea01 100644
--- a/fs/lustre/lov/lov_lock.c
+++ b/fs/lustre/lov/lov_lock.c
@@ -128,11 +128,11 @@ static struct lov_lock *lov_lock_sub_init(const struct lu_env *env,
 
 	LASSERT(ergo(is_trunc, lio->lis_trunc_stripe_index != NULL));
 
-	ext.e_start = cl_offset(obj, lock->cll_descr.cld_start);
+	ext.e_start = lock->cll_descr.cld_start << PAGE_SHIFT;
 	if (lock->cll_descr.cld_end == CL_PAGE_EOF)
 		ext.e_end = OBD_OBJECT_EOF;
 	else
-		ext.e_end = cl_offset(obj, lock->cll_descr.cld_end + 1);
+		ext.e_end = (lock->cll_descr.cld_end + 1) << PAGE_SHIFT;
 
 	nr = 0;
 	lov_foreach_io_layout(index, lio, &ext) {
@@ -185,8 +185,8 @@ static struct lov_lock *lov_lock_sub_init(const struct lu_env *env,
 			descr = &lls->sub_lock.cll_descr;
 			LASSERT(!descr->cld_obj);
 			descr->cld_obj = lovsub2cl(r0->lo_sub[i]);
-			descr->cld_start = cl_index(descr->cld_obj, start);
-			descr->cld_end = cl_index(descr->cld_obj, end);
+			descr->cld_start = start >> PAGE_SHIFT;
+			descr->cld_end = end >> PAGE_SHIFT;
 			descr->cld_mode = lock->cll_descr.cld_mode;
 			descr->cld_gid = lock->cll_descr.cld_gid;
 			descr->cld_enq_flags = lock->cll_descr.cld_enq_flags;
diff --git a/fs/lustre/lov/lov_page.c b/fs/lustre/lov/lov_page.c
index e9283aa73765..de5264318577 100644
--- a/fs/lustre/lov/lov_page.c
+++ b/fs/lustre/lov/lov_page.c
@@ -75,7 +75,7 @@ int lov_page_init_composite(const struct lu_env *env, struct cl_object *obj,
 	stripe_cached = lio->lis_cached_entry != LIS_CACHE_ENTRY_NONE &&
 			page->cp_type == CPT_TRANSIENT;
 
-	offset = cl_offset(obj, index);
+	offset = index << PAGE_SHIFT;
 
 	if (stripe_cached) {
 		entry = lio->lis_cached_entry;
@@ -126,7 +126,7 @@ int lov_page_init_composite(const struct lu_env *env, struct cl_object *obj,
 	cl_object_for_each(o, subobj) {
 		if (o->co_ops->coo_page_init) {
 			rc = o->co_ops->coo_page_init(sub->sub_env, o, page,
-						      cl_index(subobj, suboff));
+						      suboff >> PAGE_SHIFT);
 			if (rc != 0)
 				break;
 		}
@@ -136,17 +136,17 @@ int lov_page_init_composite(const struct lu_env *env, struct cl_object *obj,
 }
 
 int lov_page_init_empty(const struct lu_env *env, struct cl_object *obj,
-			struct cl_page *page, pgoff_t index)
+			struct cl_page *cl_page, pgoff_t index)
 {
 	void *addr;
 
-	BUILD_BUG_ON(!__same_type(page->cp_lov_index, CP_LOV_INDEX_EMPTY));
-	page->cp_lov_index = CP_LOV_INDEX_EMPTY;
+	BUILD_BUG_ON(!__same_type(cl_page->cp_lov_index, CP_LOV_INDEX_EMPTY));
+	cl_page->cp_lov_index = CP_LOV_INDEX_EMPTY;
 
-	addr = kmap(page->cp_vmpage);
+	addr = kmap(cl_page->cp_vmpage);
 	memset(addr, 0, PAGE_SIZE);
-	kunmap(page->cp_vmpage);
-	SetPageUptodate(page->cp_vmpage);
+	kunmap(cl_page->cp_vmpage);
+	SetPageUptodate(cl_page->cp_vmpage);
 	return 0;
 }
 
diff --git a/fs/lustre/mdc/mdc_dev.c b/fs/lustre/mdc/mdc_dev.c
index 74911da6822b..a205a8de3249 100644
--- a/fs/lustre/mdc/mdc_dev.c
+++ b/fs/lustre/mdc/mdc_dev.c
@@ -332,7 +332,7 @@ static int mdc_dlm_canceling(const struct lu_env *env,
 		struct cl_attr *attr = &osc_env_info(env)->oti_attr;
 
 		/* Destroy pages covered by the extent of the DLM lock */
-		result = mdc_lock_flush(env, cl2osc(obj), cl_index(obj, 0),
+		result = mdc_lock_flush(env, cl2osc(obj), 0,
 					CL_PAGE_EOF, mode, discard);
 		/* Losing a lock, set KMS to 0.
 		 * NB: assumed that DOM lock covers whole data on MDT.
@@ -489,7 +489,7 @@ static void mdc_lock_granted(const struct lu_env *env, struct osc_lock *oscl,
 		 * we decide whether to grant a lockless lock.
 		 */
 		descr->cld_mode = osc_ldlm2cl_lock(dlmlock->l_granted_mode);
-		descr->cld_start = cl_index(descr->cld_obj, 0);
+		descr->cld_start = 0;
 		descr->cld_end = CL_PAGE_EOF;
 
 		/* no lvb update for matched lock */
diff --git a/fs/lustre/obdclass/cl_page.c b/fs/lustre/obdclass/cl_page.c
index 80423b745650..ecfccdb2c945 100644
--- a/fs/lustre/obdclass/cl_page.c
+++ b/fs/lustre/obdclass/cl_page.c
@@ -1015,30 +1015,6 @@ void cl_page_print(const struct lu_env *env, void *cookie,
 }
 EXPORT_SYMBOL(cl_page_print);
 
-/**
- * Converts a byte offset within object @obj into a page index.
- */
-loff_t cl_offset(const struct cl_object *obj, pgoff_t idx)
-{
-	/*
-	 * XXX for now.
-	 */
-	return (loff_t)idx << PAGE_SHIFT;
-}
-EXPORT_SYMBOL(cl_offset);
-
-/**
- * Converts a page index into a byte offset within object @obj.
- */
-pgoff_t cl_index(const struct cl_object *obj, loff_t offset)
-{
-	/*
-	 * XXX for now.
-	 */
-	return offset >> PAGE_SHIFT;
-}
-EXPORT_SYMBOL(cl_index);
-
 /**
  * Adds page slice to the compound page.
  *
diff --git a/fs/lustre/osc/osc_cache.c b/fs/lustre/osc/osc_cache.c
index dddf98f38782..691ebc0ad46a 100644
--- a/fs/lustre/osc/osc_cache.c
+++ b/fs/lustre/osc/osc_cache.c
@@ -249,13 +249,13 @@ static int __osc_extent_sanity_check(struct osc_extent *ext,
 	}
 
 	if (ext->oe_dlmlock &&
-	    ext->oe_dlmlock->l_resource->lr_type == LDLM_EXTENT &&
-	    !ldlm_is_failed(ext->oe_dlmlock)) {
+			ext->oe_dlmlock->l_resource->lr_type == LDLM_EXTENT &&
+			!ldlm_is_failed(ext->oe_dlmlock)) {
 		struct ldlm_extent *extent;
 
 		extent = &ext->oe_dlmlock->l_policy_data.l_extent;
-		if (!(extent->start <= cl_offset(osc2cl(obj), ext->oe_start) &&
-		      extent->end >= cl_offset(osc2cl(obj), ext->oe_max_end))) {
+		if (!(extent->start <= ext->oe_start << PAGE_SHIFT &&
+		      extent->end >= ext->oe_max_end << PAGE_SHIFT)) {
 			rc = 100;
 			goto out;
 		}
@@ -1331,10 +1331,10 @@ static int osc_refresh_count(const struct lu_env *env,
 		return result;
 
 	kms = attr->cat_kms;
-	if (cl_offset(obj, index) >= kms)
+	if (index << PAGE_SHIFT >= kms)
 		/* catch race with truncate */
 		return 0;
-	else if (cl_offset(obj, index + 1) > kms)
+	else if ((index + 1) << PAGE_SHIFT > kms)
 		/* catch sub-page write at end of file */
 		return kms & ~PAGE_MASK;
 	else
@@ -2777,8 +2777,8 @@ int osc_cache_truncate_start(const struct lu_env *env, struct osc_object *obj,
 	bool partial;
 
 	/* pages with index greater or equal to index will be truncated. */
-	index = cl_index(osc2cl(obj), size);
-	partial = size > cl_offset(osc2cl(obj), index);
+	index = size >> PAGE_SHIFT;
+	partial = size > (index << PAGE_SHIFT);
 
 again:
 	osc_object_lock(obj);
@@ -3248,12 +3248,11 @@ static bool check_and_discard_cb(const struct lu_env *env, struct cl_io *io,
 				u64 start = tmp->l_policy_data.l_extent.start;
 
 				/* no lock covering this page */
-				if (index < cl_index(osc2cl(osc), start)) {
+				if (index < start >> PAGE_SHIFT) {
 					/* no lock at @index,
 					 * first lock at @start
 					 */
-					info->oti_ng_index = cl_index(osc2cl(osc),
-								      start);
+					info->oti_ng_index = start >> PAGE_SHIFT;
 					discard = true;
 				} else {
 					/* Cache the first-non-overlapped
@@ -3263,8 +3262,8 @@ static bool check_and_discard_cb(const struct lu_env *env, struct cl_io *io,
 					 * is canceled, it will discard these
 					 * pages.
 					 */
-					info->oti_fn_index = cl_index(osc2cl(osc),
-								      end + 1);
+					info->oti_fn_index =
+						(end + 1) >> PAGE_SHIFT;
 					if (end == OBD_OBJECT_EOF)
 						info->oti_fn_index = CL_PAGE_EOF;
 				}
diff --git a/fs/lustre/osc/osc_io.c b/fs/lustre/osc/osc_io.c
index d0ee74823ade..71bfe60ad40a 100644
--- a/fs/lustre/osc/osc_io.c
+++ b/fs/lustre/osc/osc_io.c
@@ -95,16 +95,16 @@ static int osc_io_read_ahead(const struct lu_env *env,
 		}
 
 		ra->cra_rpc_pages = osc_cli(osc)->cl_max_pages_per_rpc;
-		ra->cra_end_idx = cl_index(osc2cl(osc),
-					   dlmlock->l_policy_data.l_extent.end);
+		ra->cra_end_idx =
+			dlmlock->l_policy_data.l_extent.end >> PAGE_SHIFT;
 		ra->cra_release = osc_read_ahead_release;
 		ra->cra_dlmlock = dlmlock;
 		ra->cra_oio = oio;
 		if (ra->cra_end_idx != CL_PAGE_EOF)
 			ra->cra_contention = true;
-		ra->cra_end_idx = min_t(pgoff_t, ra->cra_end_idx,
-					cl_index(osc2cl(osc),
-						 oinfo->loi_kms - 1));
+		ra->cra_end_idx = min_t(pgoff_t,
+					ra->cra_end_idx,
+					(oinfo->loi_kms - 1) >> PAGE_SHIFT);
 		result = 0;
 	}
 
@@ -270,7 +270,7 @@ void osc_page_touch_at(const struct lu_env *env, struct cl_object *obj,
 	u64 kms;
 
 	/* offset within stripe */
-	kms = cl_offset(obj, idx) + to;
+	kms = (idx << PAGE_SHIFT) + to;
 
 	cl_object_attr_lock(obj);
 	CDEBUG(D_INODE, "stripe KMS %sincreasing %llu->%llu %llu\n",
@@ -533,8 +533,8 @@ static void osc_trunc_check(const struct lu_env *env, struct cl_io *io,
 	pgoff_t start;
 
 	clob = oio->oi_cl.cis_obj;
-	start = cl_index(clob, size);
-	partial = cl_offset(clob, start) < size;
+	start = size >> PAGE_SHIFT;
+	partial = (start << PAGE_SHIFT) < size;
 
 	/*
 	 * Complain if there are pages in the truncated region.
@@ -554,8 +554,8 @@ int osc_punch_start(const struct lu_env *env, struct cl_io *io,
 		    struct cl_object *obj)
 {
 	struct osc_object *osc = cl2osc(obj);
-	pgoff_t pg_start = cl_index(obj, io->u.ci_setattr.sa_falloc_offset);
-	pgoff_t pg_end = cl_index(obj, io->u.ci_setattr.sa_falloc_end - 1);
+	pgoff_t pg_start = io->u.ci_setattr.sa_falloc_offset >> PAGE_SHIFT;
+	pgoff_t pg_end = (io->u.ci_setattr.sa_falloc_end - 1) >> PAGE_SHIFT;
 	int rc;
 
 	rc = osc_cache_writeback_range(env, osc, pg_start, pg_end, 1, 0);
@@ -944,8 +944,8 @@ int osc_io_fsync_start(const struct lu_env *env,
 	struct cl_fsync_io *fio = &io->u.ci_fsync;
 	struct cl_object *obj = slice->cis_obj;
 	struct osc_object *osc = cl2osc(obj);
-	pgoff_t start = cl_index(obj, fio->fi_start);
-	pgoff_t end = cl_index(obj, fio->fi_end);
+	pgoff_t start = fio->fi_start >> PAGE_SHIFT;
+	pgoff_t end = fio->fi_end >> PAGE_SHIFT;
 	int result = 0;
 
 	if (fio->fi_end == OBD_OBJECT_EOF)
@@ -982,8 +982,8 @@ void osc_io_fsync_end(const struct lu_env *env,
 {
 	struct cl_fsync_io *fio = &slice->cis_io->u.ci_fsync;
 	struct cl_object *obj = slice->cis_obj;
-	pgoff_t start = cl_index(obj, fio->fi_start);
-	pgoff_t end = cl_index(obj, fio->fi_end);
+	pgoff_t start = fio->fi_start >> PAGE_SHIFT;
+	pgoff_t end = fio->fi_end >> PAGE_SHIFT;
 	int result = 0;
 
 	if (fio->fi_mode == CL_FSYNC_LOCAL) {
diff --git a/fs/lustre/osc/osc_lock.c b/fs/lustre/osc/osc_lock.c
index 3b22688e0b4f..181edf286739 100644
--- a/fs/lustre/osc/osc_lock.c
+++ b/fs/lustre/osc/osc_lock.c
@@ -237,8 +237,8 @@ static void osc_lock_granted(const struct lu_env *env, struct osc_lock *oscl,
 		 * we decide whether to grant a lockless lock.
 		 */
 		descr->cld_mode = osc_ldlm2cl_lock(dlmlock->l_granted_mode);
-		descr->cld_start = cl_index(descr->cld_obj, ext->start);
-		descr->cld_end = cl_index(descr->cld_obj, ext->end);
+		descr->cld_start = ext->start >> PAGE_SHIFT;
+		descr->cld_end = ext->end >> PAGE_SHIFT;
 		descr->cld_gid = ext->gid;
 
 		/* no lvb update for matched lock */
@@ -424,8 +424,8 @@ static int __osc_dlm_blocking_ast(const struct lu_env *env,
 
 		/* Destroy pages covered by the extent of the DLM lock */
 		result = osc_lock_flush(cl2osc(obj),
-					cl_index(obj, extent->start),
-					cl_index(obj, extent->end),
+					extent->start >> PAGE_SHIFT,
+					extent->end >> PAGE_SHIFT,
 					mode, discard);
 
 		/* losing a lock, update kms */
@@ -669,11 +669,11 @@ static unsigned long osc_lock_weight(const struct lu_env *env,
 	if (result != 0)
 		return 1;
 
-	page_index = cl_index(obj, start);
+	page_index = start >> PAGE_SHIFT;
 
 	if (!osc_page_gang_lookup(env, io, oscobj,
-				 page_index, cl_index(obj, end),
-				 weigh_cb, (void *)&page_index))
+				  page_index, end >> PAGE_SHIFT,
+				  weigh_cb, (void *)&page_index))
 		result = 1;
 	cl_io_fini(env, io);
 
@@ -1157,9 +1157,9 @@ void osc_lock_set_writer(const struct lu_env *env, const struct cl_io *io,
 		return;
 
 	if (likely(io->ci_type == CIT_WRITE)) {
-		io_start = cl_index(obj, io->u.ci_rw.crw_pos);
-		io_end = cl_index(obj, io->u.ci_rw.crw_pos +
-				  io->u.ci_rw.crw_count - 1);
+		io_start = io->u.ci_rw.crw_pos >> PAGE_SHIFT;
+		io_end = (io->u.ci_rw.crw_pos +
+			  io->u.ci_rw.crw_count - 1) >> PAGE_SHIFT;
 	} else {
 		LASSERT(cl_io_is_mkwrite(io));
 		io_start = io->u.ci_fault.ft_index;
diff --git a/fs/lustre/osc/osc_page.c b/fs/lustre/osc/osc_page.c
index f700b5af7de0..d4b3baf227b6 100644
--- a/fs/lustre/osc/osc_page.c
+++ b/fs/lustre/osc/osc_page.c
@@ -111,8 +111,8 @@ void osc_index2policy(union ldlm_policy_data *policy,
 		      pgoff_t start, pgoff_t end)
 {
 	memset(policy, 0, sizeof(*policy));
-	policy->l_extent.start = cl_offset(obj, start);
-	policy->l_extent.end = cl_offset(obj, end + 1) - 1;
+	policy->l_extent.start = start << PAGE_SHIFT;
+	policy->l_extent.end = ((end + 1) << PAGE_SHIFT) - 1;
 }
 
 static int osc_page_print(const struct lu_env *env,
@@ -247,7 +247,7 @@ int osc_page_init(const struct lu_env *env, struct cl_object *obj,
 	opg->ops_to = PAGE_SIZE - 1;
 	INIT_LIST_HEAD(&opg->ops_lru);
 
-	result = osc_prep_async_page(osc, opg, cl_page, cl_offset(obj, index));
+	result = osc_prep_async_page(osc, opg, cl_page, index << PAGE_SHIFT);
 	if (result != 0)
 		return result;
 
-- 
2.39.3

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
