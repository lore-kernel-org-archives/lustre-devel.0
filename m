From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Tue, 16 Feb 2016 00:46:55 -0500
Subject: [lustre-devel] [PATCH 23/45] staging/lustre/obdclass: Adjust NULL
	comparison codestyle
In-Reply-To: <1455601637-3847710-1-git-send-email-green@linuxhacker.ru>
References: <1455601637-3847710-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1455601637-3847710-24-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

All instances of "x == NULL" are changed to "!x" and
"x != NULL" to "x"

Also remove some redundant assertions.

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/obdclass/acl.c       | 10 +--
 drivers/staging/lustre/lustre/obdclass/cl_io.c     | 83 +++++++++---------
 drivers/staging/lustre/lustre/obdclass/cl_lock.c   | 47 +++++------
 drivers/staging/lustre/lustre/obdclass/cl_object.c | 40 +++++----
 drivers/staging/lustre/lustre/obdclass/cl_page.c   | 97 +++++++++++-----------
 drivers/staging/lustre/lustre/obdclass/class_obd.c |  4 +-
 drivers/staging/lustre/lustre/obdclass/genops.c    | 29 +++----
 .../lustre/lustre/obdclass/linux/linux-module.c    |  5 +-
 drivers/staging/lustre/lustre/obdclass/llog.c      | 18 ++--
 drivers/staging/lustre/lustre/obdclass/llog_cat.c  |  2 +-
 drivers/staging/lustre/lustre/obdclass/llog_obd.c  |  7 +-
 .../lustre/lustre/obdclass/lprocfs_counters.c      |  4 +-
 .../lustre/lustre/obdclass/lprocfs_status.c        | 56 ++++++-------
 drivers/staging/lustre/lustre/obdclass/lu_object.c | 94 ++++++++++-----------
 .../lustre/lustre/obdclass/lustre_handles.c        | 12 +--
 .../staging/lustre/lustre/obdclass/lustre_peer.c   |  4 +-
 .../staging/lustre/lustre/obdclass/obd_config.c    | 12 +--
 drivers/staging/lustre/lustre/obdclass/obd_mount.c | 37 ++++-----
 18 files changed, 267 insertions(+), 294 deletions(-)

diff --git a/drivers/staging/lustre/lustre/obdclass/acl.c b/drivers/staging/lustre/lustre/obdclass/acl.c
index 49ba885..0e02ae9 100644
--- a/drivers/staging/lustre/lustre/obdclass/acl.c
+++ b/drivers/staging/lustre/lustre/obdclass/acl.c
@@ -104,7 +104,7 @@ static int lustre_posix_acl_xattr_reduce_space(posix_acl_xattr_header **header,
 		return old_size;
 
 	new = kmemdup(*header, new_size, GFP_NOFS);
-	if (unlikely(new == NULL))
+	if (unlikely(!new))
 		return -ENOMEM;
 
 	kfree(*header);
@@ -124,7 +124,7 @@ static int lustre_ext_acl_xattr_reduce_space(ext_acl_xattr_header **header,
 		return 0;
 
 	new = kmemdup(*header, ext_size, GFP_NOFS);
-	if (unlikely(new == NULL))
+	if (unlikely(!new))
 		return -ENOMEM;
 
 	kfree(*header);
@@ -149,7 +149,7 @@ lustre_posix_acl_xattr_2ext(posix_acl_xattr_header *header, int size)
 		count = CFS_ACL_XATTR_COUNT(size, posix_acl_xattr);
 	esize = CFS_ACL_XATTR_SIZE(count, ext_acl_xattr);
 	new = kzalloc(esize, GFP_NOFS);
-	if (unlikely(new == NULL))
+	if (unlikely(!new))
 		return ERR_PTR(-ENOMEM);
 
 	new->a_count = cpu_to_le32(count);
@@ -180,7 +180,7 @@ int lustre_posix_acl_xattr_filter(posix_acl_xattr_header *header, size_t size,
 		return -EINVAL;
 
 	new = kzalloc(size, GFP_NOFS);
-	if (unlikely(new == NULL))
+	if (unlikely(!new))
 		return -ENOMEM;
 
 	new->a_version = cpu_to_le32(CFS_ACL_XATTR_VERSION);
@@ -300,7 +300,7 @@ lustre_acl_xattr_merge2ext(posix_acl_xattr_header *posix_header, int size,
 	ext_size = CFS_ACL_XATTR_SIZE(ext_count, ext_acl_xattr);
 
 	new = kzalloc(ext_size, GFP_NOFS);
-	if (unlikely(new == NULL))
+	if (unlikely(!new))
 		return ERR_PTR(-ENOMEM);
 
 	for (i = 0, j = 0; i < posix_count; i++) {
diff --git a/drivers/staging/lustre/lustre/obdclass/cl_io.c b/drivers/staging/lustre/lustre/obdclass/cl_io.c
index 63246ba..58b46a7 100644
--- a/drivers/staging/lustre/lustre/obdclass/cl_io.c
+++ b/drivers/staging/lustre/lustre/obdclass/cl_io.c
@@ -93,7 +93,7 @@ static int cl_io_invariant(const struct cl_io *io)
 		 * CIS_IO_GOING.
 		 */
 		ergo(io->ci_owned_nr > 0, io->ci_state == CIS_IO_GOING ||
-		     (io->ci_state == CIS_LOCKED && up != NULL));
+		     (io->ci_state == CIS_LOCKED && up));
 }
 
 /**
@@ -111,7 +111,7 @@ void cl_io_fini(const struct lu_env *env, struct cl_io *io)
 		slice = container_of(io->ci_layers.prev, struct cl_io_slice,
 				     cis_linkage);
 		list_del_init(&slice->cis_linkage);
-		if (slice->cis_iop->op[io->ci_type].cio_fini != NULL)
+		if (slice->cis_iop->op[io->ci_type].cio_fini)
 			slice->cis_iop->op[io->ci_type].cio_fini(env, slice);
 		/*
 		 * Invalidate slice to catch use after free. This assumes that
@@ -164,7 +164,7 @@ static int cl_io_init0(const struct lu_env *env, struct cl_io *io,
 
 	result = 0;
 	cl_object_for_each(scan, obj) {
-		if (scan->co_ops->coo_io_init != NULL) {
+		if (scan->co_ops->coo_io_init) {
 			result = scan->co_ops->coo_io_init(env, scan, io);
 			if (result != 0)
 				break;
@@ -186,7 +186,7 @@ int cl_io_sub_init(const struct lu_env *env, struct cl_io *io,
 	struct cl_thread_info *info = cl_env_info(env);
 
 	LASSERT(obj != cl_object_top(obj));
-	if (info->clt_current_io == NULL)
+	if (!info->clt_current_io)
 		info->clt_current_io = io;
 	return cl_io_init0(env, io, iot, obj);
 }
@@ -208,7 +208,7 @@ int cl_io_init(const struct lu_env *env, struct cl_io *io,
 	struct cl_thread_info *info = cl_env_info(env);
 
 	LASSERT(obj == cl_object_top(obj));
-	LASSERT(info->clt_current_io == NULL);
+	LASSERT(!info->clt_current_io);
 
 	info->clt_current_io = io;
 	return cl_io_init0(env, io, iot, obj);
@@ -224,7 +224,7 @@ int cl_io_rw_init(const struct lu_env *env, struct cl_io *io,
 		  enum cl_io_type iot, loff_t pos, size_t count)
 {
 	LINVRNT(iot == CIT_READ || iot == CIT_WRITE);
-	LINVRNT(io->ci_obj != NULL);
+	LINVRNT(io->ci_obj);
 
 	LU_OBJECT_HEADER(D_VFSTRACE, env, &io->ci_obj->co_lu,
 			 "io range: %u [%llu, %llu) %u %u\n",
@@ -292,7 +292,7 @@ static void cl_io_locks_sort(struct cl_io *io)
 		list_for_each_entry_safe(curr, temp,
 					     &io->ci_lockset.cls_todo,
 					     cill_linkage) {
-			if (prev != NULL) {
+			if (prev) {
 				switch (cl_lock_descr_sort(&prev->cill_descr,
 							  &curr->cill_descr)) {
 				case 0:
@@ -399,11 +399,11 @@ static void cl_lock_link_fini(const struct lu_env *env, struct cl_io *io,
 	struct cl_lock *lock = link->cill_lock;
 
 	list_del_init(&link->cill_linkage);
-	if (lock != NULL) {
+	if (lock) {
 		cl_lock_release(env, lock, "io", io);
 		link->cill_lock = NULL;
 	}
-	if (link->cill_fini != NULL)
+	if (link->cill_fini)
 		link->cill_fini(env, link);
 }
 
@@ -458,7 +458,7 @@ int cl_io_lock(const struct lu_env *env, struct cl_io *io)
 	LINVRNT(cl_io_invariant(io));
 
 	cl_io_for_each(scan, io) {
-		if (scan->cis_iop->op[io->ci_type].cio_lock == NULL)
+		if (!scan->cis_iop->op[io->ci_type].cio_lock)
 			continue;
 		result = scan->cis_iop->op[io->ci_type].cio_lock(env, scan);
 		if (result != 0)
@@ -503,7 +503,7 @@ void cl_io_unlock(const struct lu_env *env, struct cl_io *io)
 		cl_lock_link_fini(env, io, link);
 	}
 	cl_io_for_each_reverse(scan, io) {
-		if (scan->cis_iop->op[io->ci_type].cio_unlock != NULL)
+		if (scan->cis_iop->op[io->ci_type].cio_unlock)
 			scan->cis_iop->op[io->ci_type].cio_unlock(env, scan);
 	}
 	io->ci_state = CIS_UNLOCKED;
@@ -529,7 +529,7 @@ int cl_io_iter_init(const struct lu_env *env, struct cl_io *io)
 
 	result = 0;
 	cl_io_for_each(scan, io) {
-		if (scan->cis_iop->op[io->ci_type].cio_iter_init == NULL)
+		if (!scan->cis_iop->op[io->ci_type].cio_iter_init)
 			continue;
 		result = scan->cis_iop->op[io->ci_type].cio_iter_init(env,
 								      scan);
@@ -556,7 +556,7 @@ void cl_io_iter_fini(const struct lu_env *env, struct cl_io *io)
 	LINVRNT(cl_io_invariant(io));
 
 	cl_io_for_each_reverse(scan, io) {
-		if (scan->cis_iop->op[io->ci_type].cio_iter_fini != NULL)
+		if (scan->cis_iop->op[io->ci_type].cio_iter_fini)
 			scan->cis_iop->op[io->ci_type].cio_iter_fini(env, scan);
 	}
 	io->ci_state = CIS_IT_ENDED;
@@ -581,7 +581,7 @@ static void cl_io_rw_advance(const struct lu_env *env, struct cl_io *io,
 
 	/* layers have to be notified. */
 	cl_io_for_each_reverse(scan, io) {
-		if (scan->cis_iop->op[io->ci_type].cio_advance != NULL)
+		if (scan->cis_iop->op[io->ci_type].cio_advance)
 			scan->cis_iop->op[io->ci_type].cio_advance(env, scan,
 								   nob);
 	}
@@ -621,7 +621,7 @@ int cl_io_lock_alloc_add(const struct lu_env *env, struct cl_io *io,
 	int result;
 
 	link = kzalloc(sizeof(*link), GFP_NOFS);
-	if (link != NULL) {
+	if (link) {
 		link->cill_descr     = *descr;
 		link->cill_fini      = cl_free_io_lock_link;
 		result = cl_io_lock_add(env, io, link);
@@ -648,7 +648,7 @@ int cl_io_start(const struct lu_env *env, struct cl_io *io)
 
 	io->ci_state = CIS_IO_GOING;
 	cl_io_for_each(scan, io) {
-		if (scan->cis_iop->op[io->ci_type].cio_start == NULL)
+		if (!scan->cis_iop->op[io->ci_type].cio_start)
 			continue;
 		result = scan->cis_iop->op[io->ci_type].cio_start(env, scan);
 		if (result != 0)
@@ -673,7 +673,7 @@ void cl_io_end(const struct lu_env *env, struct cl_io *io)
 	LINVRNT(cl_io_invariant(io));
 
 	cl_io_for_each_reverse(scan, io) {
-		if (scan->cis_iop->op[io->ci_type].cio_end != NULL)
+		if (scan->cis_iop->op[io->ci_type].cio_end)
 			scan->cis_iop->op[io->ci_type].cio_end(env, scan);
 		/* TODO: error handling. */
 	}
@@ -687,7 +687,7 @@ cl_io_slice_page(const struct cl_io_slice *ios, struct cl_page *page)
 	const struct cl_page_slice *slice;
 
 	slice = cl_page_at(page, ios->cis_obj->co_lu.lo_dev->ld_type);
-	LINVRNT(slice != NULL);
+	LINVRNT(slice);
 	return slice;
 }
 
@@ -759,11 +759,11 @@ int cl_io_read_page(const struct lu_env *env, struct cl_io *io,
 	 * "parallel io" (see CLO_REPEAT loops in cl_lock.c).
 	 */
 	cl_io_for_each(scan, io) {
-		if (scan->cis_iop->cio_read_page != NULL) {
+		if (scan->cis_iop->cio_read_page) {
 			const struct cl_page_slice *slice;
 
 			slice = cl_io_slice_page(scan, page);
-			LINVRNT(slice != NULL);
+			LINVRNT(slice);
 			result = scan->cis_iop->cio_read_page(env, scan, slice);
 			if (result != 0)
 				break;
@@ -798,7 +798,7 @@ int cl_io_prepare_write(const struct lu_env *env, struct cl_io *io,
 	LASSERT(cl_page_in_io(page, io));
 
 	cl_io_for_each_reverse(scan, io) {
-		if (scan->cis_iop->cio_prepare_write != NULL) {
+		if (scan->cis_iop->cio_prepare_write) {
 			const struct cl_page_slice *slice;
 
 			slice = cl_io_slice_page(scan, page);
@@ -833,11 +833,11 @@ int cl_io_commit_write(const struct lu_env *env, struct cl_io *io,
 	 * state. Better (and more general) way of dealing with such situation
 	 * is needed.
 	 */
-	LASSERT(cl_page_is_owned(page, io) || page->cp_parent != NULL);
+	LASSERT(cl_page_is_owned(page, io) || page->cp_parent);
 	LASSERT(cl_page_in_io(page, io));
 
 	cl_io_for_each(scan, io) {
-		if (scan->cis_iop->cio_commit_write != NULL) {
+		if (scan->cis_iop->cio_commit_write) {
 			const struct cl_page_slice *slice;
 
 			slice = cl_io_slice_page(scan, page);
@@ -872,7 +872,7 @@ int cl_io_submit_rw(const struct lu_env *env, struct cl_io *io,
 	LINVRNT(crt < ARRAY_SIZE(scan->cis_iop->req_op));
 
 	cl_io_for_each(scan, io) {
-		if (scan->cis_iop->req_op[crt].cio_submit == NULL)
+		if (!scan->cis_iop->req_op[crt].cio_submit)
 			continue;
 		result = scan->cis_iop->req_op[crt].cio_submit(env, scan, crt,
 							       queue);
@@ -900,7 +900,7 @@ int cl_io_submit_sync(const struct lu_env *env, struct cl_io *io,
 	int rc;
 
 	cl_page_list_for_each(pg, &queue->c2_qin) {
-		LASSERT(pg->cp_sync_io == NULL);
+		LASSERT(!pg->cp_sync_io);
 		pg->cp_sync_io = anchor;
 	}
 
@@ -1026,7 +1026,7 @@ void cl_io_slice_add(struct cl_io *io, struct cl_io_slice *slice,
 {
 	struct list_head *linkage = &slice->cis_linkage;
 
-	LASSERT((linkage->prev == NULL && linkage->next == NULL) ||
+	LASSERT((!linkage->prev && !linkage->next) ||
 		list_empty(linkage));
 
 	list_add_tail(linkage, &io->ci_layers);
@@ -1054,7 +1054,7 @@ void cl_page_list_add(struct cl_page_list *plist, struct cl_page *page)
 {
 	/* it would be better to check that page is owned by "current" io, but
 	 * it is not passed here. */
-	LASSERT(page->cp_owner != NULL);
+	LASSERT(page->cp_owner);
 	LINVRNT(plist->pl_owner == current);
 
 	lockdep_off();
@@ -1263,7 +1263,7 @@ EXPORT_SYMBOL(cl_2queue_init_page);
  */
 struct cl_io *cl_io_top(struct cl_io *io)
 {
-	while (io->ci_parent != NULL)
+	while (io->ci_parent)
 		io = io->ci_parent;
 	return io;
 }
@@ -1296,13 +1296,13 @@ static void cl_req_free(const struct lu_env *env, struct cl_req *req)
 	LASSERT(list_empty(&req->crq_pages));
 	LASSERT(req->crq_nrpages == 0);
 	LINVRNT(list_empty(&req->crq_layers));
-	LINVRNT(equi(req->crq_nrobjs > 0, req->crq_o != NULL));
+	LINVRNT(equi(req->crq_nrobjs > 0, req->crq_o));
 
-	if (req->crq_o != NULL) {
+	if (req->crq_o) {
 		for (i = 0; i < req->crq_nrobjs; ++i) {
 			struct cl_object *obj = req->crq_o[i].ro_obj;
 
-			if (obj != NULL) {
+			if (obj) {
 				lu_object_ref_del_at(&obj->co_lu,
 						     &req->crq_o[i].ro_obj_ref,
 						     "cl_req", req);
@@ -1326,7 +1326,7 @@ static int cl_req_init(const struct lu_env *env, struct cl_req *req,
 	do {
 		list_for_each_entry(slice, &page->cp_layers, cpl_linkage) {
 			dev = lu2cl_dev(slice->cpl_obj->co_lu.lo_dev);
-			if (dev->cd_ops->cdo_req_init != NULL) {
+			if (dev->cd_ops->cdo_req_init) {
 				result = dev->cd_ops->cdo_req_init(env,
 								   dev, req);
 				if (result != 0)
@@ -1334,7 +1334,7 @@ static int cl_req_init(const struct lu_env *env, struct cl_req *req,
 			}
 		}
 		page = page->cp_child;
-	} while (page != NULL && result == 0);
+	} while (page && result == 0);
 	return result;
 }
 
@@ -1353,7 +1353,7 @@ void cl_req_completion(const struct lu_env *env, struct cl_req *req, int rc)
 		slice = list_entry(req->crq_layers.prev,
 				       struct cl_req_slice, crs_linkage);
 		list_del_init(&slice->crs_linkage);
-		if (slice->crs_ops->cro_completion != NULL)
+		if (slice->crs_ops->cro_completion)
 			slice->crs_ops->cro_completion(env, slice, rc);
 	}
 	cl_req_free(env, req);
@@ -1371,7 +1371,7 @@ struct cl_req *cl_req_alloc(const struct lu_env *env, struct cl_page *page,
 	LINVRNT(nr_objects > 0);
 
 	req = kzalloc(sizeof(*req), GFP_NOFS);
-	if (req != NULL) {
+	if (req) {
 		int result;
 
 		req->crq_type = crt;
@@ -1380,7 +1380,7 @@ struct cl_req *cl_req_alloc(const struct lu_env *env, struct cl_page *page,
 
 		req->crq_o = kcalloc(nr_objects, sizeof(req->crq_o[0]),
 				     GFP_NOFS);
-		if (req->crq_o != NULL) {
+		if (req->crq_o) {
 			req->crq_nrobjs = nr_objects;
 			result = cl_req_init(env, req, page);
 		} else
@@ -1408,7 +1408,7 @@ void cl_req_page_add(const struct lu_env *env,
 	page = cl_page_top(page);
 
 	LASSERT(list_empty(&page->cp_flight));
-	LASSERT(page->cp_req == NULL);
+	LASSERT(!page->cp_req);
 
 	CL_PAGE_DEBUG(D_PAGE, env, page, "req %p, %d, %u\n",
 		      req, req->crq_type, req->crq_nrpages);
@@ -1418,7 +1418,7 @@ void cl_req_page_add(const struct lu_env *env,
 	page->cp_req = req;
 	obj = cl_object_top(page->cp_obj);
 	for (i = 0, rqo = req->crq_o; obj != rqo->ro_obj; ++i, ++rqo) {
-		if (rqo->ro_obj == NULL) {
+		if (!rqo->ro_obj) {
 			rqo->ro_obj = obj;
 			cl_object_get(obj);
 			lu_object_ref_add_at(&obj->co_lu, &rqo->ro_obj_ref,
@@ -1463,11 +1463,11 @@ int cl_req_prep(const struct lu_env *env, struct cl_req *req)
 	 * of objects.
 	 */
 	for (i = 0; i < req->crq_nrobjs; ++i)
-		LASSERT(req->crq_o[i].ro_obj != NULL);
+		LASSERT(req->crq_o[i].ro_obj);
 
 	result = 0;
 	list_for_each_entry(slice, &req->crq_layers, crs_linkage) {
-		if (slice->crs_ops->cro_prep != NULL) {
+		if (slice->crs_ops->cro_prep) {
 			result = slice->crs_ops->cro_prep(env, slice);
 			if (result != 0)
 				break;
@@ -1501,9 +1501,8 @@ void cl_req_attr_set(const struct lu_env *env, struct cl_req *req,
 
 			scan = cl_page_at(page,
 					  slice->crs_dev->cd_lu_dev.ld_type);
-			LASSERT(scan != NULL);
 			obj = scan->cpl_obj;
-			if (slice->crs_ops->cro_attr_set != NULL)
+			if (slice->crs_ops->cro_attr_set)
 				slice->crs_ops->cro_attr_set(env, slice, obj,
 							     attr + i, flags);
 		}
diff --git a/drivers/staging/lustre/lustre/obdclass/cl_lock.c b/drivers/staging/lustre/lustre/obdclass/cl_lock.c
index 1836dc0..57cb100 100644
--- a/drivers/staging/lustre/lustre/obdclass/cl_lock.c
+++ b/drivers/staging/lustre/lustre/obdclass/cl_lock.c
@@ -96,7 +96,7 @@ static int cl_lock_invariant(const struct lu_env *env,
 
 	result = atomic_read(&lock->cll_ref) > 0 &&
 		cl_lock_invariant_trusted(env, lock);
-	if (!result && env != NULL)
+	if (!result && env)
 		CL_LOCK_DEBUG(D_ERROR, env, lock, "invariant broken");
 	return result;
 }
@@ -288,7 +288,7 @@ void cl_lock_put(const struct lu_env *env, struct cl_lock *lock)
 
 	LINVRNT(cl_lock_invariant(env, lock));
 	obj = lock->cll_descr.cld_obj;
-	LINVRNT(obj != NULL);
+	LINVRNT(obj);
 
 	CDEBUG(D_TRACE, "releasing reference: %d %p %lu\n",
 	       atomic_read(&lock->cll_ref), lock, RETIP);
@@ -362,7 +362,7 @@ static struct cl_lock *cl_lock_alloc(const struct lu_env *env,
 	struct lu_object_header *head;
 
 	lock = kmem_cache_alloc(cl_lock_kmem, GFP_NOFS | __GFP_ZERO);
-	if (lock != NULL) {
+	if (lock) {
 		atomic_set(&lock->cll_ref, 1);
 		lock->cll_descr = *descr;
 		lock->cll_state = CLS_NEW;
@@ -461,7 +461,7 @@ static int cl_lock_fits_into(const struct lu_env *env,
 
 	LINVRNT(cl_lock_invariant_trusted(env, lock));
 	list_for_each_entry(slice, &lock->cll_layers, cls_linkage) {
-		if (slice->cls_ops->clo_fits_into != NULL &&
+		if (slice->cls_ops->clo_fits_into &&
 		    !slice->cls_ops->clo_fits_into(env, slice, need, io))
 			return 0;
 	}
@@ -524,14 +524,14 @@ static struct cl_lock *cl_lock_find(const struct lu_env *env,
 	lock = cl_lock_lookup(env, obj, io, need);
 	spin_unlock(&head->coh_lock_guard);
 
-	if (lock == NULL) {
+	if (!lock) {
 		lock = cl_lock_alloc(env, obj, io, need);
 		if (!IS_ERR(lock)) {
 			struct cl_lock *ghost;
 
 			spin_lock(&head->coh_lock_guard);
 			ghost = cl_lock_lookup(env, obj, io, need);
-			if (ghost == NULL) {
+			if (!ghost) {
 				cl_lock_get_trust(lock);
 				list_add_tail(&lock->cll_linkage,
 						  &head->coh_locks);
@@ -572,7 +572,7 @@ struct cl_lock *cl_lock_peek(const struct lu_env *env, const struct cl_io *io,
 		spin_lock(&head->coh_lock_guard);
 		lock = cl_lock_lookup(env, obj, io, need);
 		spin_unlock(&head->coh_lock_guard);
-		if (lock == NULL)
+		if (!lock)
 			return NULL;
 
 		cl_lock_mutex_get(env, lock);
@@ -584,7 +584,7 @@ struct cl_lock *cl_lock_peek(const struct lu_env *env, const struct cl_io *io,
 			cl_lock_put(env, lock);
 			lock = NULL;
 		}
-	} while (lock == NULL);
+	} while (!lock);
 
 	cl_lock_hold_add(env, lock, scope, source);
 	cl_lock_user_add(env, lock);
@@ -775,7 +775,7 @@ static void cl_lock_cancel0(const struct lu_env *env, struct cl_lock *lock)
 		lock->cll_flags |= CLF_CANCELLED;
 		list_for_each_entry_reverse(slice, &lock->cll_layers,
 						cls_linkage) {
-			if (slice->cls_ops->clo_cancel != NULL)
+			if (slice->cls_ops->clo_cancel)
 				slice->cls_ops->clo_cancel(env, slice);
 		}
 	}
@@ -812,7 +812,7 @@ static void cl_lock_delete0(const struct lu_env *env, struct cl_lock *lock)
 		 */
 		list_for_each_entry_reverse(slice, &lock->cll_layers,
 						cls_linkage) {
-			if (slice->cls_ops->clo_delete != NULL)
+			if (slice->cls_ops->clo_delete)
 				slice->cls_ops->clo_delete(env, slice);
 		}
 		/*
@@ -974,7 +974,7 @@ static void cl_lock_state_signal(const struct lu_env *env, struct cl_lock *lock,
 	LINVRNT(cl_lock_invariant(env, lock));
 
 	list_for_each_entry(slice, &lock->cll_layers, cls_linkage)
-		if (slice->cls_ops->clo_state != NULL)
+		if (slice->cls_ops->clo_state)
 			slice->cls_ops->clo_state(env, slice, state);
 	wake_up_all(&lock->cll_wq);
 }
@@ -1039,7 +1039,7 @@ static int cl_unuse_try_internal(const struct lu_env *env, struct cl_lock *lock)
 		result = -ENOSYS;
 		list_for_each_entry_reverse(slice, &lock->cll_layers,
 						cls_linkage) {
-			if (slice->cls_ops->clo_unuse != NULL) {
+			if (slice->cls_ops->clo_unuse) {
 				result = slice->cls_ops->clo_unuse(env, slice);
 				if (result != 0)
 					break;
@@ -1072,7 +1072,7 @@ int cl_use_try(const struct lu_env *env, struct cl_lock *lock, int atomic)
 	result = -ENOSYS;
 	state = cl_lock_intransit(env, lock);
 	list_for_each_entry(slice, &lock->cll_layers, cls_linkage) {
-		if (slice->cls_ops->clo_use != NULL) {
+		if (slice->cls_ops->clo_use) {
 			result = slice->cls_ops->clo_use(env, slice);
 			if (result != 0)
 				break;
@@ -1125,7 +1125,7 @@ static int cl_enqueue_kick(const struct lu_env *env,
 
 	result = -ENOSYS;
 	list_for_each_entry(slice, &lock->cll_layers, cls_linkage) {
-		if (slice->cls_ops->clo_enqueue != NULL) {
+		if (slice->cls_ops->clo_enqueue) {
 			result = slice->cls_ops->clo_enqueue(env,
 							     slice, io, flags);
 			if (result != 0)
@@ -1215,7 +1215,7 @@ int cl_lock_enqueue_wait(const struct lu_env *env,
 
 	LASSERT(cl_lock_is_mutexed(lock));
 	LASSERT(lock->cll_state == CLS_QUEUING);
-	LASSERT(lock->cll_conflict != NULL);
+	LASSERT(lock->cll_conflict);
 
 	conflict = lock->cll_conflict;
 	lock->cll_conflict = NULL;
@@ -1258,7 +1258,7 @@ static int cl_enqueue_locked(const struct lu_env *env, struct cl_lock *lock,
 	do {
 		result = cl_enqueue_try(env, lock, io, enqflags);
 		if (result == CLO_WAIT) {
-			if (lock->cll_conflict != NULL)
+			if (lock->cll_conflict)
 				result = cl_lock_enqueue_wait(env, lock, 1);
 			else
 				result = cl_lock_state_wait(env, lock);
@@ -1416,7 +1416,7 @@ int cl_wait_try(const struct lu_env *env, struct cl_lock *lock)
 
 		result = -ENOSYS;
 		list_for_each_entry(slice, &lock->cll_layers, cls_linkage) {
-			if (slice->cls_ops->clo_wait != NULL) {
+			if (slice->cls_ops->clo_wait) {
 				result = slice->cls_ops->clo_wait(env, slice);
 				if (result != 0)
 					break;
@@ -1487,7 +1487,7 @@ unsigned long cl_lock_weigh(const struct lu_env *env, struct cl_lock *lock)
 
 	pound = 0;
 	list_for_each_entry_reverse(slice, &lock->cll_layers, cls_linkage) {
-		if (slice->cls_ops->clo_weigh != NULL) {
+		if (slice->cls_ops->clo_weigh) {
 			ounce = slice->cls_ops->clo_weigh(env, slice);
 			pound += ounce;
 			if (pound < ounce) /* over-weight^Wflow */
@@ -1523,7 +1523,7 @@ int cl_lock_modify(const struct lu_env *env, struct cl_lock *lock,
 	LINVRNT(cl_lock_invariant(env, lock));
 
 	list_for_each_entry_reverse(slice, &lock->cll_layers, cls_linkage) {
-		if (slice->cls_ops->clo_modify != NULL) {
+		if (slice->cls_ops->clo_modify) {
 			result = slice->cls_ops->clo_modify(env, slice, desc);
 			if (result != 0)
 				return result;
@@ -1584,7 +1584,7 @@ int cl_lock_closure_build(const struct lu_env *env, struct cl_lock *lock,
 	result = cl_lock_enclosure(env, lock, closure);
 	if (result == 0) {
 		list_for_each_entry(slice, &lock->cll_layers, cls_linkage) {
-			if (slice->cls_ops->clo_closure != NULL) {
+			if (slice->cls_ops->clo_closure) {
 				result = slice->cls_ops->clo_closure(env, slice,
 								     closure);
 				if (result != 0)
@@ -1820,7 +1820,6 @@ static pgoff_t pgoff_at_lock(struct cl_page *page, struct cl_lock *lock)
 
 	dtype = lock->cll_descr.cld_obj->co_lu.lo_dev->ld_type;
 	slice = cl_page_at(page, dtype);
-	LASSERT(slice != NULL);
 	return slice->cpl_page->cp_index;
 }
 
@@ -1840,7 +1839,7 @@ static int check_and_discard_cb(const struct lu_env *env, struct cl_io *io,
 		/* refresh non-overlapped index */
 		tmp = cl_lock_at_pgoff(env, lock->cll_descr.cld_obj, index,
 					lock, 1, 0);
-		if (tmp != NULL) {
+		if (tmp) {
 			/* Cache the first-non-overlapped index so as to skip
 			 * all pages within [index, clt_fn_index). This
 			 * is safe because if tmp lock is canceled, it will
@@ -1950,7 +1949,7 @@ void cl_locks_prune(const struct lu_env *env, struct cl_object *obj, int cancel)
 	 * already destroyed (as otherwise they will be left unprotected).
 	 */
 	LASSERT(ergo(!cancel,
-		     head->coh_tree.rnode == NULL && head->coh_pages == 0));
+		     !head->coh_tree.rnode && head->coh_pages == 0));
 
 	spin_lock(&head->coh_lock_guard);
 	while (!list_empty(&head->coh_locks)) {
@@ -2194,7 +2193,7 @@ void cl_lock_print(const struct lu_env *env, void *cookie,
 		(*printer)(env, cookie, "    %s@%p: ",
 			   slice->cls_obj->co_lu.lo_dev->ld_type->ldt_name,
 			   slice);
-		if (slice->cls_ops->clo_print != NULL)
+		if (slice->cls_ops->clo_print)
 			slice->cls_ops->clo_print(env, cookie, printer, slice);
 		(*printer)(env, cookie, "\n");
 	}
diff --git a/drivers/staging/lustre/lustre/obdclass/cl_object.c b/drivers/staging/lustre/lustre/obdclass/cl_object.c
index f118983..39b4fd0 100644
--- a/drivers/staging/lustre/lustre/obdclass/cl_object.c
+++ b/drivers/staging/lustre/lustre/obdclass/cl_object.c
@@ -152,7 +152,7 @@ struct cl_object *cl_object_top(struct cl_object *o)
 	struct cl_object_header *hdr = cl_object_header(o);
 	struct cl_object *top;
 
-	while (hdr->coh_parent != NULL)
+	while (hdr->coh_parent)
 		hdr = hdr->coh_parent;
 
 	top = lu2cl(lu_object_top(&hdr->coh_lu));
@@ -217,7 +217,7 @@ int cl_object_attr_get(const struct lu_env *env, struct cl_object *obj,
 	top = obj->co_lu.lo_header;
 	result = 0;
 	list_for_each_entry(obj, &top->loh_layers, co_lu.lo_linkage) {
-		if (obj->co_ops->coo_attr_get != NULL) {
+		if (obj->co_ops->coo_attr_get) {
 			result = obj->co_ops->coo_attr_get(env, obj, attr);
 			if (result != 0) {
 				if (result > 0)
@@ -249,7 +249,7 @@ int cl_object_attr_set(const struct lu_env *env, struct cl_object *obj,
 	result = 0;
 	list_for_each_entry_reverse(obj, &top->loh_layers,
 					co_lu.lo_linkage) {
-		if (obj->co_ops->coo_attr_set != NULL) {
+		if (obj->co_ops->coo_attr_set) {
 			result = obj->co_ops->coo_attr_set(env, obj, attr, v);
 			if (result != 0) {
 				if (result > 0)
@@ -280,7 +280,7 @@ int cl_object_glimpse(const struct lu_env *env, struct cl_object *obj,
 	result = 0;
 	list_for_each_entry_reverse(obj, &top->loh_layers,
 					co_lu.lo_linkage) {
-		if (obj->co_ops->coo_glimpse != NULL) {
+		if (obj->co_ops->coo_glimpse) {
 			result = obj->co_ops->coo_glimpse(env, obj, lvb);
 			if (result != 0)
 				break;
@@ -306,7 +306,7 @@ int cl_conf_set(const struct lu_env *env, struct cl_object *obj,
 	top = obj->co_lu.lo_header;
 	result = 0;
 	list_for_each_entry(obj, &top->loh_layers, co_lu.lo_linkage) {
-		if (obj->co_ops->coo_conf_set != NULL) {
+		if (obj->co_ops->coo_conf_set) {
 			result = obj->co_ops->coo_conf_set(env, obj, conf);
 			if (result != 0)
 				break;
@@ -328,7 +328,7 @@ void cl_object_kill(const struct lu_env *env, struct cl_object *obj)
 	struct cl_object_header *hdr;
 
 	hdr = cl_object_header(obj);
-	LASSERT(hdr->coh_tree.rnode == NULL);
+	LASSERT(!hdr->coh_tree.rnode);
 	LASSERT(hdr->coh_pages == 0);
 
 	set_bit(LU_OBJECT_HEARD_BANSHEE, &hdr->coh_lu.loh_flags);
@@ -541,7 +541,7 @@ static void cl_env_init0(struct cl_env *cle, void *debug)
 {
 	LASSERT(cle->ce_ref == 0);
 	LASSERT(cle->ce_magic == &cl_env_init0);
-	LASSERT(cle->ce_debug == NULL && cle->ce_owner == NULL);
+	LASSERT(!cle->ce_debug && !cle->ce_owner);
 
 	cle->ce_ref = 1;
 	cle->ce_debug = debug;
@@ -576,7 +576,7 @@ static int cl_env_hops_keycmp(const void *key, struct hlist_node *hn)
 {
 	struct cl_env *cle = cl_env_hops_obj(hn);
 
-	LASSERT(cle->ce_owner != NULL);
+	LASSERT(cle->ce_owner);
 	return (key == cle->ce_owner);
 }
 
@@ -610,7 +610,7 @@ static inline void cl_env_attach(struct cl_env *cle)
 	if (cle) {
 		int rc;
 
-		LASSERT(cle->ce_owner == NULL);
+		LASSERT(!cle->ce_owner);
 		cle->ce_owner = (void *) (long) current->pid;
 		rc = cfs_hash_add_unique(cl_env_hash, cle->ce_owner,
 					 &cle->ce_node);
@@ -638,7 +638,7 @@ static int cl_env_store_init(void)
 				      CFS_HASH_MAX_THETA,
 				      &cl_env_hops,
 				      CFS_HASH_RW_BKTLOCK);
-	return cl_env_hash != NULL ? 0 : -ENOMEM;
+	return cl_env_hash ? 0 : -ENOMEM;
 }
 
 static void cl_env_store_fini(void)
@@ -648,7 +648,7 @@ static void cl_env_store_fini(void)
 
 static inline struct cl_env *cl_env_detach(struct cl_env *cle)
 {
-	if (cle == NULL)
+	if (!cle)
 		cle = cl_env_fetch();
 
 	if (cle && cle->ce_owner)
@@ -663,7 +663,7 @@ static struct lu_env *cl_env_new(__u32 ctx_tags, __u32 ses_tags, void *debug)
 	struct cl_env *cle;
 
 	cle = kmem_cache_alloc(cl_env_kmem, GFP_NOFS | __GFP_ZERO);
-	if (cle != NULL) {
+	if (cle) {
 		int rc;
 
 		INIT_LIST_HEAD(&cle->ce_linkage);
@@ -717,7 +717,7 @@ static struct lu_env *cl_env_peek(int *refcheck)
 
 	env = NULL;
 	cle = cl_env_fetch();
-	if (cle != NULL) {
+	if (cle) {
 		CL_ENV_INC(hit);
 		env = &cle->ce_lu;
 		*refcheck = ++cle->ce_ref;
@@ -742,7 +742,7 @@ struct lu_env *cl_env_get(int *refcheck)
 	struct lu_env *env;
 
 	env = cl_env_peek(refcheck);
-	if (env == NULL) {
+	if (!env) {
 		env = cl_env_new(lu_context_tags_default,
 				 lu_session_tags_default,
 				 __builtin_return_address(0));
@@ -769,7 +769,7 @@ struct lu_env *cl_env_alloc(int *refcheck, __u32 tags)
 {
 	struct lu_env *env;
 
-	LASSERT(cl_env_peek(refcheck) == NULL);
+	LASSERT(!cl_env_peek(refcheck));
 	env = cl_env_new(tags, tags, __builtin_return_address(0));
 	if (!IS_ERR(env)) {
 		struct cl_env *cle;
@@ -784,7 +784,7 @@ EXPORT_SYMBOL(cl_env_alloc);
 
 static void cl_env_exit(struct cl_env *cle)
 {
-	LASSERT(cle->ce_owner == NULL);
+	LASSERT(!cle->ce_owner);
 	lu_context_exit(&cle->ce_lu.le_ctx);
 	lu_context_exit(&cle->ce_ses);
 }
@@ -803,7 +803,7 @@ void cl_env_put(struct lu_env *env, int *refcheck)
 	cle = cl_env_container(env);
 
 	LASSERT(cle->ce_ref > 0);
-	LASSERT(ergo(refcheck != NULL, cle->ce_ref == *refcheck));
+	LASSERT(ergo(refcheck, cle->ce_ref == *refcheck));
 
 	CDEBUG(D_OTHER, "%d@%p\n", cle->ce_ref, cle);
 	if (--cle->ce_ref == 0) {
@@ -878,7 +878,7 @@ struct lu_env *cl_env_nested_get(struct cl_env_nest *nest)
 
 	nest->cen_cookie = NULL;
 	env = cl_env_peek(&nest->cen_refcheck);
-	if (env != NULL) {
+	if (env) {
 		if (!cl_io_is_going(env))
 			return env;
 		cl_env_put(env, &nest->cen_refcheck);
@@ -930,14 +930,12 @@ struct cl_device *cl_type_setup(const struct lu_env *env, struct lu_site *site,
 	const char       *typename;
 	struct lu_device *d;
 
-	LASSERT(ldt != NULL);
-
 	typename = ldt->ldt_name;
 	d = ldt->ldt_ops->ldto_device_alloc(env, ldt, NULL);
 	if (!IS_ERR(d)) {
 		int rc;
 
-		if (site != NULL)
+		if (site)
 			d->ld_site = site;
 		rc = ldt->ldt_ops->ldto_device_init(env, d, typename, next);
 		if (rc == 0) {
diff --git a/drivers/staging/lustre/lustre/obdclass/cl_page.c b/drivers/staging/lustre/lustre/obdclass/cl_page.c
index 61f28eb..72f9924 100644
--- a/drivers/staging/lustre/lustre/obdclass/cl_page.c
+++ b/drivers/staging/lustre/lustre/obdclass/cl_page.c
@@ -69,7 +69,7 @@ static void cl_page_delete0(const struct lu_env *env, struct cl_page *pg,
  */
 static struct cl_page *cl_page_top_trusted(struct cl_page *page)
 {
-	while (page->cp_parent != NULL)
+	while (page->cp_parent)
 		page = page->cp_parent;
 	return page;
 }
@@ -110,7 +110,7 @@ cl_page_at_trusted(const struct cl_page *page,
 				return slice;
 		}
 		page = page->cp_child;
-	} while (page != NULL);
+	} while (page);
 	return NULL;
 }
 
@@ -127,7 +127,7 @@ struct cl_page *cl_page_lookup(struct cl_object_header *hdr, pgoff_t index)
 	assert_spin_locked(&hdr->coh_page_guard);
 
 	page = radix_tree_lookup(&hdr->coh_tree, index);
-	if (page != NULL)
+	if (page)
 		cl_page_get_trust(page);
 	return page;
 }
@@ -188,7 +188,7 @@ int cl_page_gang_lookup(const struct lu_env *env, struct cl_object *obj,
 			 * Pages for lsm-less file has no underneath sub-page
 			 * for osc, in case of ...
 			 */
-			PASSERT(env, page, slice != NULL);
+			PASSERT(env, page, slice);
 
 			page = slice->cpl_page;
 			/*
@@ -245,9 +245,9 @@ static void cl_page_free(const struct lu_env *env, struct cl_page *page)
 	struct cl_object *obj  = page->cp_obj;
 
 	PASSERT(env, page, list_empty(&page->cp_batch));
-	PASSERT(env, page, page->cp_owner == NULL);
-	PASSERT(env, page, page->cp_req == NULL);
-	PASSERT(env, page, page->cp_parent == NULL);
+	PASSERT(env, page, !page->cp_owner);
+	PASSERT(env, page, !page->cp_req);
+	PASSERT(env, page, !page->cp_parent);
 	PASSERT(env, page, page->cp_state == CPS_FREEING);
 
 	might_sleep();
@@ -284,7 +284,7 @@ static struct cl_page *cl_page_alloc(const struct lu_env *env,
 	struct lu_object_header *head;
 
 	page = kzalloc(cl_object_header(o)->coh_page_bufsize, GFP_NOFS);
-	if (page != NULL) {
+	if (page) {
 		int result = 0;
 
 		atomic_set(&page->cp_ref, 1);
@@ -305,7 +305,7 @@ static struct cl_page *cl_page_alloc(const struct lu_env *env,
 		head = o->co_lu.lo_header;
 		list_for_each_entry(o, &head->loh_layers,
 					co_lu.lo_linkage) {
-			if (o->co_ops->coo_page_init != NULL) {
+			if (o->co_ops->coo_page_init) {
 				result = o->co_ops->coo_page_init(env, o,
 								  page, vmpage);
 				if (result != 0) {
@@ -369,13 +369,13 @@ static struct cl_page *cl_page_find0(const struct lu_env *env,
 		 */
 		page = cl_vmpage_page(vmpage, o);
 		PINVRNT(env, page,
-			ergo(page != NULL,
+			ergo(page,
 			     cl_page_vmpage(env, page) == vmpage &&
 			     (void *)radix_tree_lookup(&hdr->coh_tree,
 						       idx) == page));
 	}
 
-	if (page != NULL)
+	if (page)
 		return page;
 
 	/* allocate and initialize cl_page */
@@ -385,7 +385,7 @@ static struct cl_page *cl_page_find0(const struct lu_env *env,
 
 	if (type == CPT_TRANSIENT) {
 		if (parent) {
-			LASSERT(page->cp_parent == NULL);
+			LASSERT(!page->cp_parent);
 			page->cp_parent = parent;
 			parent->cp_child = page;
 		}
@@ -418,7 +418,7 @@ static struct cl_page *cl_page_find0(const struct lu_env *env,
 			      "fail to insert into radix tree: %d\n", err);
 	} else {
 		if (parent) {
-			LASSERT(page->cp_parent == NULL);
+			LASSERT(!page->cp_parent);
 			page->cp_parent = parent;
 			parent->cp_child = page;
 		}
@@ -426,7 +426,7 @@ static struct cl_page *cl_page_find0(const struct lu_env *env,
 	}
 	spin_unlock(&hdr->coh_page_guard);
 
-	if (unlikely(ghost != NULL)) {
+	if (unlikely(ghost)) {
 		cl_page_delete0(env, ghost, 0);
 		cl_page_free(env, ghost);
 	}
@@ -467,14 +467,13 @@ static inline int cl_page_invariant(const struct cl_page *pg)
 	owner  = pg->cp_owner;
 
 	return cl_page_in_use(pg) &&
-		ergo(parent != NULL, parent->cp_child == pg) &&
-		ergo(child != NULL, child->cp_parent == pg) &&
-		ergo(child != NULL, pg->cp_obj != child->cp_obj) &&
-		ergo(parent != NULL, pg->cp_obj != parent->cp_obj) &&
-		ergo(owner != NULL && parent != NULL,
+		ergo(parent, parent->cp_child == pg) &&
+		ergo(child, child->cp_parent == pg) &&
+		ergo(child, pg->cp_obj != child->cp_obj) &&
+		ergo(parent, pg->cp_obj != parent->cp_obj) &&
+		ergo(owner && parent,
 		     parent->cp_owner == pg->cp_owner->ci_parent) &&
-		ergo(owner != NULL && child != NULL,
-		     child->cp_owner->ci_parent == owner) &&
+		ergo(owner && child, child->cp_owner->ci_parent == owner) &&
 		/*
 		 * Either page is early in initialization (has neither child
 		 * nor parent yet), or it is in the object radix tree.
@@ -482,7 +481,7 @@ static inline int cl_page_invariant(const struct cl_page *pg)
 		ergo(pg->cp_state < CPS_FREEING && pg->cp_type == CPT_CACHEABLE,
 		     (void *)radix_tree_lookup(&header->coh_tree,
 					       pg->cp_index) == pg ||
-		     (child == NULL && parent == NULL));
+		     (!child && !parent));
 }
 
 static void cl_page_state_set0(const struct lu_env *env,
@@ -535,10 +534,10 @@ static void cl_page_state_set0(const struct lu_env *env,
 	old = page->cp_state;
 	PASSERT(env, page, allowed_transitions[old][state]);
 	CL_PAGE_HEADER(D_TRACE, env, page, "%d -> %d\n", old, state);
-	for (; page != NULL; page = page->cp_child) {
+	for (; page; page = page->cp_child) {
 		PASSERT(env, page, page->cp_state == old);
 		PASSERT(env, page,
-			equi(state == CPS_OWNED, page->cp_owner != NULL));
+			equi(state == CPS_OWNED, page->cp_owner));
 
 		cl_page_state_set_trust(page, state);
 	}
@@ -584,7 +583,7 @@ void cl_page_put(const struct lu_env *env, struct cl_page *page)
 		LASSERT(page->cp_state == CPS_FREEING);
 
 		LASSERT(atomic_read(&page->cp_ref) == 0);
-		PASSERT(env, page, page->cp_owner == NULL);
+		PASSERT(env, page, !page->cp_owner);
 		PASSERT(env, page, list_empty(&page->cp_batch));
 		/*
 		 * Page is no longer reachable by other threads. Tear
@@ -609,11 +608,11 @@ struct page *cl_page_vmpage(const struct lu_env *env, struct cl_page *page)
 	page = cl_page_top(page);
 	do {
 		list_for_each_entry(slice, &page->cp_layers, cpl_linkage) {
-			if (slice->cpl_ops->cpo_vmpage != NULL)
+			if (slice->cpl_ops->cpo_vmpage)
 				return slice->cpl_ops->cpo_vmpage(env, slice);
 		}
 		page = page->cp_child;
-	} while (page != NULL);
+	} while (page);
 	LBUG(); /* ->cpo_vmpage() has to be defined somewhere in the stack */
 }
 EXPORT_SYMBOL(cl_page_vmpage);
@@ -639,10 +638,10 @@ struct cl_page *cl_vmpage_page(struct page *vmpage, struct cl_object *obj)
 	 * can be rectified easily.
 	 */
 	top = (struct cl_page *)vmpage->private;
-	if (top == NULL)
+	if (!top)
 		return NULL;
 
-	for (page = top; page != NULL; page = page->cp_child) {
+	for (page = top; page; page = page->cp_child) {
 		if (cl_object_same(page->cp_obj, obj)) {
 			cl_page_get_trust(page);
 			break;
@@ -689,7 +688,7 @@ EXPORT_SYMBOL(cl_page_at);
 					cpl_linkage) {		  \
 			__method = *(void **)((char *)__scan->cpl_ops + \
 					      __op);		    \
-			if (__method != NULL) {			 \
+			if (__method) {					\
 				__result = (*__method)(__env, __scan,   \
 						       ## __VA_ARGS__); \
 				if (__result != 0)		      \
@@ -697,7 +696,7 @@ EXPORT_SYMBOL(cl_page_at);
 			}					       \
 		}						       \
 		__page = __page->cp_child;			      \
-	} while (__page != NULL && __result == 0);		      \
+	} while (__page && __result == 0);			      \
 	if (__result > 0)					       \
 		__result = 0;					   \
 	__result;						       \
@@ -717,12 +716,12 @@ do {								    \
 					cpl_linkage) {		  \
 			__method = *(void **)((char *)__scan->cpl_ops + \
 					      __op);		    \
-			if (__method != NULL)			   \
+			if (__method)				   \
 				(*__method)(__env, __scan,	      \
 					    ## __VA_ARGS__);	    \
 		}						       \
 		__page = __page->cp_child;			      \
-	} while (__page != NULL);				       \
+	} while (__page);					       \
 } while (0)
 
 #define CL_PAGE_INVOID_REVERSE(_env, _page, _op, _proto, ...)	       \
@@ -734,19 +733,19 @@ do {									\
 	void		      (*__method)_proto;			\
 									    \
 	/* get to the bottom page. */				       \
-	while (__page->cp_child != NULL)				    \
+	while (__page->cp_child)					    \
 		__page = __page->cp_child;				  \
 	do {								\
 		list_for_each_entry_reverse(__scan, &__page->cp_layers, \
 						cpl_linkage) {	      \
 			__method = *(void **)((char *)__scan->cpl_ops +     \
 					      __op);			\
-			if (__method != NULL)			       \
+			if (__method)				       \
 				(*__method)(__env, __scan,		  \
 					    ## __VA_ARGS__);		\
 		}							   \
 		__page = __page->cp_parent;				 \
-	} while (__page != NULL);					   \
+	} while (__page);						   \
 } while (0)
 
 static int cl_page_invoke(const struct lu_env *env,
@@ -772,8 +771,8 @@ static void cl_page_invoid(const struct lu_env *env,
 
 static void cl_page_owner_clear(struct cl_page *page)
 {
-	for (page = cl_page_top(page); page != NULL; page = page->cp_child) {
-		if (page->cp_owner != NULL) {
+	for (page = cl_page_top(page); page; page = page->cp_child) {
+		if (page->cp_owner) {
 			LASSERT(page->cp_owner->ci_owned_nr > 0);
 			page->cp_owner->ci_owned_nr--;
 			page->cp_owner = NULL;
@@ -784,10 +783,8 @@ static void cl_page_owner_clear(struct cl_page *page)
 
 static void cl_page_owner_set(struct cl_page *page)
 {
-	for (page = cl_page_top(page); page != NULL; page = page->cp_child) {
-		LASSERT(page->cp_owner != NULL);
+	for (page = cl_page_top(page); page; page = page->cp_child)
 		page->cp_owner->ci_owned_nr++;
-	}
 }
 
 void cl_page_disown0(const struct lu_env *env,
@@ -862,8 +859,8 @@ static int cl_page_own0(const struct lu_env *env, struct cl_io *io,
 					 struct cl_io *, int),
 					io, nonblock);
 		if (result == 0) {
-			PASSERT(env, pg, pg->cp_owner == NULL);
-			PASSERT(env, pg, pg->cp_req == NULL);
+			PASSERT(env, pg, !pg->cp_owner);
+			PASSERT(env, pg, !pg->cp_req);
 			pg->cp_owner = io;
 			pg->cp_task  = current;
 			cl_page_owner_set(pg);
@@ -921,7 +918,7 @@ void cl_page_assume(const struct lu_env *env,
 	io = cl_io_top(io);
 
 	cl_page_invoid(env, io, pg, CL_PAGE_OP(cpo_assume));
-	PASSERT(env, pg, pg->cp_owner == NULL);
+	PASSERT(env, pg, !pg->cp_owner);
 	pg->cp_owner = io;
 	pg->cp_task = current;
 	cl_page_owner_set(pg);
@@ -1037,7 +1034,7 @@ static void cl_page_delete0(const struct lu_env *env, struct cl_page *pg,
 			 * skip removing it.
 			 */
 			tmp = pg->cp_child;
-		for (; tmp != NULL; tmp = tmp->cp_child) {
+		for (; tmp; tmp = tmp->cp_child) {
 			void		    *value;
 			struct cl_object_header *hdr;
 
@@ -1135,7 +1132,7 @@ int cl_page_is_vmlocked(const struct lu_env *env, const struct cl_page *pg)
 	pg = cl_page_top_trusted((struct cl_page *)pg);
 	slice = container_of(pg->cp_layers.next,
 			     const struct cl_page_slice, cpl_linkage);
-	PASSERT(env, pg, slice->cpl_ops->cpo_is_vmlocked != NULL);
+	PASSERT(env, pg, slice->cpl_ops->cpo_is_vmlocked);
 	/*
 	 * Call ->cpo_is_vmlocked() directly instead of going through
 	 * CL_PAGE_INVOKE(), because cl_page_is_vmlocked() is used by
@@ -1216,7 +1213,7 @@ void cl_page_completion(const struct lu_env *env,
 
 	PASSERT(env, pg, crt < CRT_NR);
 	/* cl_page::cp_req already cleared by the caller (osc_completion()) */
-	PASSERT(env, pg, pg->cp_req == NULL);
+	PASSERT(env, pg, !pg->cp_req);
 	PASSERT(env, pg, pg->cp_state == cl_req_type_state(crt));
 
 	CL_PAGE_HEADER(D_TRACE, env, pg, "%d %d\n", crt, ioret);
@@ -1304,7 +1301,7 @@ int cl_page_cache_add(const struct lu_env *env, struct cl_io *io,
 		return -EINVAL;
 
 	list_for_each_entry(scan, &pg->cp_layers, cpl_linkage) {
-		if (scan->cpl_ops->io[crt].cpo_cache_add == NULL)
+		if (!scan->cpl_ops->io[crt].cpo_cache_add)
 			continue;
 
 		result = scan->cpl_ops->io[crt].cpo_cache_add(env, scan, io);
@@ -1450,8 +1447,8 @@ void cl_page_print(const struct lu_env *env, void *cookie,
 {
 	struct cl_page *scan;
 
-	for (scan = cl_page_top((struct cl_page *)pg);
-	     scan != NULL; scan = scan->cp_child)
+	for (scan = cl_page_top((struct cl_page *)pg); scan;
+	     scan = scan->cp_child)
 		cl_page_header_print(env, cookie, printer, scan);
 	CL_PAGE_INVOKE(env, (struct cl_page *)pg, CL_PAGE_OP(cpo_print),
 		       (const struct lu_env *env,
diff --git a/drivers/staging/lustre/lustre/obdclass/class_obd.c b/drivers/staging/lustre/lustre/obdclass/class_obd.c
index 84f6880..4b7e21f 100644
--- a/drivers/staging/lustre/lustre/obdclass/class_obd.c
+++ b/drivers/staging/lustre/lustre/obdclass/class_obd.c
@@ -341,7 +341,7 @@ int class_handle_ioctl(unsigned int cmd, unsigned long arg)
 	}
 
 	if (data->ioc_dev == OBD_DEV_BY_DEVNAME) {
-		if (data->ioc_inllen4 <= 0 || data->ioc_inlbuf4 == NULL) {
+		if (data->ioc_inllen4 <= 0 || !data->ioc_inlbuf4) {
 			err = -EINVAL;
 			goto out;
 		}
@@ -358,7 +358,7 @@ int class_handle_ioctl(unsigned int cmd, unsigned long arg)
 		goto out;
 	}
 
-	if (obd == NULL) {
+	if (!obd) {
 		CERROR("OBD ioctl : No Device %d\n", data->ioc_dev);
 		err = -EINVAL;
 		goto out;
diff --git a/drivers/staging/lustre/lustre/obdclass/genops.c b/drivers/staging/lustre/lustre/obdclass/genops.c
index 1cb68df..10b8d33 100644
--- a/drivers/staging/lustre/lustre/obdclass/genops.c
+++ b/drivers/staging/lustre/lustre/obdclass/genops.c
@@ -70,17 +70,16 @@ static struct obd_device *obd_device_alloc(void)
 	struct obd_device *obd;
 
 	obd = kmem_cache_alloc(obd_device_cachep, GFP_NOFS | __GFP_ZERO);
-	if (obd != NULL)
+	if (obd)
 		obd->obd_magic = OBD_DEVICE_MAGIC;
 	return obd;
 }
 
 static void obd_device_free(struct obd_device *obd)
 {
-	LASSERT(obd != NULL);
 	LASSERTF(obd->obd_magic == OBD_DEVICE_MAGIC, "obd %p obd_magic %08x != %08x\n",
 		 obd, obd->obd_magic, OBD_DEVICE_MAGIC);
-	if (obd->obd_namespace != NULL) {
+	if (obd->obd_namespace) {
 		CERROR("obd %p: namespace %p was not properly cleaned up (obd_force=%d)!\n",
 		       obd, obd->obd_namespace, obd->obd_force);
 		LBUG();
@@ -194,7 +193,7 @@ int class_register_type(struct obd_ops *dt_ops, struct md_ops *md_ops,
 		goto failed;
 	}
 
-	if (ldt != NULL) {
+	if (ldt) {
 		type->typ_lu = ldt;
 		rc = lu_device_type_init(ldt);
 		if (rc != 0)
@@ -356,7 +355,7 @@ void class_release_dev(struct obd_device *obd)
 		 obd, obd->obd_magic, OBD_DEVICE_MAGIC);
 	LASSERTF(obd == obd_devs[obd->obd_minor], "obd %p != obd_devs[%d] %p\n",
 		 obd, obd->obd_minor, obd_devs[obd->obd_minor]);
-	LASSERT(obd_type != NULL);
+	LASSERT(obd_type);
 
 	CDEBUG(D_INFO, "Release obd device %s at %d obd_type name =%s\n",
 	       obd->obd_name, obd->obd_minor, obd->obd_type->typ_name);
@@ -650,7 +649,7 @@ static void class_export_destroy(struct obd_export *exp)
 	struct obd_device *obd = exp->exp_obd;
 
 	LASSERT_ATOMIC_ZERO(&exp->exp_refcount);
-	LASSERT(obd != NULL);
+	LASSERT(obd);
 
 	CDEBUG(D_IOCTL, "destroying export %p/%s for %s\n", exp,
 	       exp->exp_client_uuid.uuid, obd->obd_name);
@@ -690,7 +689,6 @@ EXPORT_SYMBOL(class_export_get);
 
 void class_export_put(struct obd_export *exp)
 {
-	LASSERT(exp != NULL);
 	LASSERT_ATOMIC_GT_LT(&exp->exp_refcount, 0, LI_POISON);
 	CDEBUG(D_INFO, "PUTting export %p : new refcount %d\n", exp,
 	       atomic_read(&exp->exp_refcount) - 1);
@@ -942,7 +940,7 @@ EXPORT_SYMBOL(class_new_import);
 
 void class_destroy_import(struct obd_import *import)
 {
-	LASSERT(import != NULL);
+	LASSERT(import);
 	LASSERT(import != LP_POISON);
 
 	class_handle_unhash(&import->imp_handle);
@@ -962,8 +960,7 @@ void __class_export_add_lock_ref(struct obd_export *exp, struct ldlm_lock *lock)
 
 	LASSERT(lock->l_exp_refs_nr >= 0);
 
-	if (lock->l_exp_refs_target != NULL &&
-	    lock->l_exp_refs_target != exp) {
+	if (lock->l_exp_refs_target && lock->l_exp_refs_target != exp) {
 		LCONSOLE_WARN("setting export %p for lock %p which already has export %p\n",
 			      exp, lock, lock->l_exp_refs_target);
 	}
@@ -1005,9 +1002,9 @@ int class_connect(struct lustre_handle *conn, struct obd_device *obd,
 {
 	struct obd_export *export;
 
-	LASSERT(conn != NULL);
-	LASSERT(obd != NULL);
-	LASSERT(cluuid != NULL);
+	LASSERT(conn);
+	LASSERT(obd);
+	LASSERT(cluuid);
 
 	export = class_new_export(obd, cluuid);
 	if (IS_ERR(export))
@@ -1133,14 +1130,14 @@ static void obd_zombie_impexp_cull(void)
 
 		spin_unlock(&obd_zombie_impexp_lock);
 
-		if (import != NULL) {
+		if (import) {
 			class_import_destroy(import);
 			spin_lock(&obd_zombie_impexp_lock);
 			zombies_count--;
 			spin_unlock(&obd_zombie_impexp_lock);
 		}
 
-		if (export != NULL) {
+		if (export) {
 			class_export_destroy(export);
 			spin_lock(&obd_zombie_impexp_lock);
 			zombies_count--;
@@ -1148,7 +1145,7 @@ static void obd_zombie_impexp_cull(void)
 		}
 
 		cond_resched();
-	} while (import != NULL || export != NULL);
+	} while (import || export);
 }
 
 static struct completion	obd_zombie_start;
diff --git a/drivers/staging/lustre/lustre/obdclass/linux/linux-module.c b/drivers/staging/lustre/lustre/obdclass/linux/linux-module.c
index 1913f3e..1de3b9a 100644
--- a/drivers/staging/lustre/lustre/obdclass/linux/linux-module.c
+++ b/drivers/staging/lustre/lustre/obdclass/linux/linux-module.c
@@ -106,7 +106,7 @@ int obd_ioctl_getdata(char **buf, int *len, void __user *arg)
 	 * obdfilter-survey is an example, which relies on ioctl. So we'd
 	 * better avoid vmalloc on ioctl path. LU-66 */
 	*buf = libcfs_kvzalloc(hdr.ioc_len, GFP_NOFS);
-	if (*buf == NULL) {
+	if (!*buf) {
 		CERROR("Cannot allocate control buffer of len %d\n",
 		       hdr.ioc_len);
 		return -EINVAL;
@@ -454,8 +454,7 @@ out:
 
 int class_procfs_clean(void)
 {
-	if (debugfs_lustre_root != NULL)
-		debugfs_remove_recursive(debugfs_lustre_root);
+	debugfs_remove_recursive(debugfs_lustre_root);
 
 	debugfs_lustre_root = NULL;
 
diff --git a/drivers/staging/lustre/lustre/obdclass/llog.c b/drivers/staging/lustre/lustre/obdclass/llog.c
index f956d7e..9a647ba 100644
--- a/drivers/staging/lustre/lustre/obdclass/llog.c
+++ b/drivers/staging/lustre/lustre/obdclass/llog.c
@@ -76,8 +76,6 @@ static struct llog_handle *llog_alloc_handle(void)
  */
 static void llog_free_handle(struct llog_handle *loghandle)
 {
-	LASSERT(loghandle != NULL);
-
 	/* failed llog_init_handle */
 	if (!loghandle->lgh_hdr)
 		goto out;
@@ -115,7 +113,7 @@ static int llog_read_header(const struct lu_env *env,
 	if (rc)
 		return rc;
 
-	if (lop->lop_read_header == NULL)
+	if (!lop->lop_read_header)
 		return -EOPNOTSUPP;
 
 	rc = lop->lop_read_header(env, handle);
@@ -144,7 +142,7 @@ int llog_init_handle(const struct lu_env *env, struct llog_handle *handle,
 	struct llog_log_hdr	*llh;
 	int			 rc;
 
-	LASSERT(handle->lgh_hdr == NULL);
+	LASSERT(!handle->lgh_hdr);
 
 	llh = kzalloc(sizeof(*llh), GFP_NOFS);
 	if (!llh)
@@ -228,11 +226,11 @@ static int llog_process_thread(void *arg)
 		return 0;
 	}
 
-	if (cd != NULL) {
+	if (cd) {
 		last_called_index = cd->lpcd_first_idx;
 		index = cd->lpcd_first_idx + 1;
 	}
-	if (cd != NULL && cd->lpcd_last_idx)
+	if (cd && cd->lpcd_last_idx)
 		last_index = cd->lpcd_last_idx;
 	else
 		last_index = LLOG_BITMAP_BYTES * 8 - 1;
@@ -328,7 +326,7 @@ repeat:
 	}
 
 out:
-	if (cd != NULL)
+	if (cd)
 		cd->lpcd_last_idx = last_called_index;
 
 	kfree(buf);
@@ -416,13 +414,13 @@ int llog_open(const struct lu_env *env, struct llog_ctxt *ctxt,
 	LASSERT(ctxt);
 	LASSERT(ctxt->loc_logops);
 
-	if (ctxt->loc_logops->lop_open == NULL) {
+	if (!ctxt->loc_logops->lop_open) {
 		*lgh = NULL;
 		return -EOPNOTSUPP;
 	}
 
 	*lgh = llog_alloc_handle();
-	if (*lgh == NULL)
+	if (!*lgh)
 		return -ENOMEM;
 	(*lgh)->lgh_ctxt = ctxt;
 	(*lgh)->lgh_logops = ctxt->loc_logops;
@@ -449,7 +447,7 @@ int llog_close(const struct lu_env *env, struct llog_handle *loghandle)
 	rc = llog_handle2ops(loghandle, &lop);
 	if (rc)
 		goto out;
-	if (lop->lop_close == NULL) {
+	if (!lop->lop_close) {
 		rc = -EOPNOTSUPP;
 		goto out;
 	}
diff --git a/drivers/staging/lustre/lustre/obdclass/llog_cat.c b/drivers/staging/lustre/lustre/obdclass/llog_cat.c
index 0f05e9c..b88ccba 100644
--- a/drivers/staging/lustre/lustre/obdclass/llog_cat.c
+++ b/drivers/staging/lustre/lustre/obdclass/llog_cat.c
@@ -69,7 +69,7 @@ static int llog_cat_id2handle(const struct lu_env *env,
 	struct llog_handle	*loghandle;
 	int			 rc = 0;
 
-	if (cathandle == NULL)
+	if (!cathandle)
 		return -EBADF;
 
 	down_write(&cathandle->lgh_lock);
diff --git a/drivers/staging/lustre/lustre/obdclass/llog_obd.c b/drivers/staging/lustre/lustre/obdclass/llog_obd.c
index 9bc5199..a06a5ea 100644
--- a/drivers/staging/lustre/lustre/obdclass/llog_obd.c
+++ b/drivers/staging/lustre/lustre/obdclass/llog_obd.c
@@ -110,11 +110,8 @@ int llog_cleanup(const struct lu_env *env, struct llog_ctxt *ctxt)
 	struct obd_llog_group *olg;
 	int rc, idx;
 
-	LASSERT(ctxt != NULL);
-	LASSERT(ctxt != LP_POISON);
-
 	olg = ctxt->loc_olg;
-	LASSERT(olg != NULL);
+	LASSERT(olg);
 	LASSERT(olg != LP_POISON);
 
 	idx = ctxt->loc_idx;
@@ -151,7 +148,7 @@ int llog_setup(const struct lu_env *env, struct obd_device *obd,
 	if (index < 0 || index >= LLOG_MAX_CTXTS)
 		return -EINVAL;
 
-	LASSERT(olg != NULL);
+	LASSERT(olg);
 
 	ctxt = llog_new_ctxt(obd);
 	if (!ctxt)
diff --git a/drivers/staging/lustre/lustre/obdclass/lprocfs_counters.c b/drivers/staging/lustre/lustre/obdclass/lprocfs_counters.c
index 6acc4a1..4b04124 100644
--- a/drivers/staging/lustre/lustre/obdclass/lprocfs_counters.c
+++ b/drivers/staging/lustre/lustre/obdclass/lprocfs_counters.c
@@ -48,7 +48,7 @@ void lprocfs_counter_add(struct lprocfs_stats *stats, int idx, long amount)
 	int				smp_id;
 	unsigned long			flags = 0;
 
-	if (stats == NULL)
+	if (!stats)
 		return;
 
 	LASSERTF(0 <= idx && idx < stats->ls_num,
@@ -96,7 +96,7 @@ void lprocfs_counter_sub(struct lprocfs_stats *stats, int idx, long amount)
 	int				smp_id;
 	unsigned long			flags = 0;
 
-	if (stats == NULL)
+	if (!stats)
 		return;
 
 	LASSERTF(0 <= idx && idx < stats->ls_num,
diff --git a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
index a7e22e0..16b1c70 100644
--- a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
+++ b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
@@ -109,7 +109,7 @@ int obd_connect_flags2str(char *page, int count, __u64 flags, char *sep)
 	__u64 mask = 1;
 	int i, ret = 0;
 
-	for (i = 0; obd_connect_names[i] != NULL; i++, mask <<= 1) {
+	for (i = 0; obd_connect_names[i]; i++, mask <<= 1) {
 		if (flags & mask)
 			ret += snprintf(page + ret, count - ret, "%s%s",
 					ret ? sep : "", obd_connect_names[i]);
@@ -199,7 +199,7 @@ int lprocfs_write_frac_helper(const char __user *buffer, unsigned long count,
 	if (pbuf == end)
 		return -EINVAL;
 
-	if (end != NULL && *end == '.') {
+	if (end && *end == '.') {
 		int temp_val, pow = 1;
 		int i;
 
@@ -247,7 +247,7 @@ struct dentry *ldebugfs_add_simple(struct dentry *root,
 	struct dentry *entry;
 	umode_t mode = 0;
 
-	if (root == NULL || name == NULL || fops == NULL)
+	if (!root || !name || !fops)
 		return ERR_PTR(-EINVAL);
 
 	if (fops->read)
@@ -272,7 +272,7 @@ int ldebugfs_add_vars(struct dentry *parent,
 	if (IS_ERR_OR_NULL(parent) || IS_ERR_OR_NULL(list))
 		return -EINVAL;
 
-	while (list->name != NULL) {
+	while (list->name) {
 		struct dentry *entry;
 		umode_t mode = 0;
 
@@ -491,7 +491,7 @@ int lprocfs_rd_server_uuid(struct seq_file *m, void *data)
 	char *imp_state_name = NULL;
 	int rc;
 
-	LASSERT(obd != NULL);
+	LASSERT(obd);
 	rc = lprocfs_climp_check(obd);
 	if (rc)
 		return rc;
@@ -514,7 +514,7 @@ int lprocfs_rd_conn_uuid(struct seq_file *m, void *data)
 	struct ptlrpc_connection *conn;
 	int rc;
 
-	LASSERT(obd != NULL);
+	LASSERT(obd);
 
 	rc = lprocfs_climp_check(obd);
 	if (rc)
@@ -543,7 +543,7 @@ void lprocfs_stats_collect(struct lprocfs_stats *stats, int idx,
 
 	memset(cnt, 0, sizeof(*cnt));
 
-	if (stats == NULL) {
+	if (!stats) {
 		/* set count to 1 to avoid divide-by-zero errs in callers */
 		cnt->lc_count = 1;
 		return;
@@ -554,7 +554,7 @@ void lprocfs_stats_collect(struct lprocfs_stats *stats, int idx,
 	num_entry = lprocfs_stats_lock(stats, LPROCFS_GET_NUM_CPU, &flags);
 
 	for (i = 0; i < num_entry; i++) {
-		if (stats->ls_percpu[i] == NULL)
+		if (!stats->ls_percpu[i])
 			continue;
 		percpu_cntr = lprocfs_stats_counter_get(stats, i, idx);
 
@@ -604,7 +604,7 @@ static void obd_connect_seq_flags2str(struct seq_file *m, __u64 flags, char *sep
 	int i;
 	bool first = true;
 
-	for (i = 0; obd_connect_names[i] != NULL; i++, mask <<= 1) {
+	for (i = 0; obd_connect_names[i]; i++, mask <<= 1) {
 		if (flags & mask) {
 			seq_printf(m, "%s%s",
 					first ? sep : "", obd_connect_names[i]);
@@ -629,7 +629,7 @@ int lprocfs_rd_import(struct seq_file *m, void *data)
 	int				rw	= 0;
 	int				rc;
 
-	LASSERT(obd != NULL);
+	LASSERT(obd);
 	rc = lprocfs_climp_check(obd);
 	if (rc)
 		return rc;
@@ -665,7 +665,7 @@ int lprocfs_rd_import(struct seq_file *m, void *data)
 		seq_printf(m, "%s%s", j ? ", " : "", nidstr);
 		j++;
 	}
-	if (imp->imp_connection != NULL)
+	if (imp->imp_connection)
 		libcfs_nid2str_r(imp->imp_connection->c_peer.nid,
 				 nidstr, sizeof(nidstr));
 	else
@@ -682,7 +682,7 @@ int lprocfs_rd_import(struct seq_file *m, void *data)
 		      atomic_read(&imp->imp_inval_count));
 	spin_unlock(&imp->imp_lock);
 
-	if (obd->obd_svc_stats == NULL)
+	if (!obd->obd_svc_stats)
 		goto out_climp;
 
 	header = &obd->obd_svc_stats->ls_cnt_header[PTLRPC_REQWAIT_CNTR];
@@ -779,7 +779,7 @@ int lprocfs_rd_state(struct seq_file *m, void *data)
 	struct obd_import *imp;
 	int j, k, rc;
 
-	LASSERT(obd != NULL);
+	LASSERT(obd);
 	rc = lprocfs_climp_check(obd);
 	if (rc)
 		return rc;
@@ -825,7 +825,7 @@ int lprocfs_rd_timeouts(struct seq_file *m, void *data)
 	struct dhms ts;
 	int i, rc;
 
-	LASSERT(obd != NULL);
+	LASSERT(obd);
 	rc = lprocfs_climp_check(obd);
 	if (rc)
 		return rc;
@@ -967,12 +967,12 @@ int lprocfs_stats_alloc_one(struct lprocfs_stats *stats, unsigned int cpuid)
 	unsigned long           flags = 0;
 	int                     i;
 
-	LASSERT(stats->ls_percpu[cpuid] == NULL);
+	LASSERT(!stats->ls_percpu[cpuid]);
 	LASSERT((stats->ls_flags & LPROCFS_STATS_FLAG_NOPERCPU) == 0);
 
 	percpusize = lprocfs_stats_counter_size(stats);
 	LIBCFS_ALLOC_ATOMIC(stats->ls_percpu[cpuid], percpusize);
-	if (stats->ls_percpu[cpuid] != NULL) {
+	if (stats->ls_percpu[cpuid]) {
 		rc = 0;
 		if (unlikely(stats->ls_biggest_alloc_num <= cpuid)) {
 			if (stats->ls_flags & LPROCFS_STATS_FLAG_IRQ_SAFE)
@@ -1017,7 +1017,7 @@ struct lprocfs_stats *lprocfs_alloc_stats(unsigned int num,
 
 	/* alloc percpu pointers for all possible cpu slots */
 	LIBCFS_ALLOC(stats, offsetof(typeof(*stats), ls_percpu[num_entry]));
-	if (stats == NULL)
+	if (!stats)
 		return NULL;
 
 	stats->ls_num = num;
@@ -1027,14 +1027,14 @@ struct lprocfs_stats *lprocfs_alloc_stats(unsigned int num,
 	/* alloc num of counter headers */
 	LIBCFS_ALLOC(stats->ls_cnt_header,
 		     stats->ls_num * sizeof(struct lprocfs_counter_header));
-	if (stats->ls_cnt_header == NULL)
+	if (!stats->ls_cnt_header)
 		goto fail;
 
 	if ((flags & LPROCFS_STATS_FLAG_NOPERCPU) != 0) {
 		/* contains only one set counters */
 		percpusize = lprocfs_stats_counter_size(stats);
 		LIBCFS_ALLOC_ATOMIC(stats->ls_percpu[0], percpusize);
-		if (stats->ls_percpu[0] == NULL)
+		if (!stats->ls_percpu[0])
 			goto fail;
 		stats->ls_biggest_alloc_num = 1;
 	} else if ((flags & LPROCFS_STATS_FLAG_IRQ_SAFE) != 0) {
@@ -1059,7 +1059,7 @@ void lprocfs_free_stats(struct lprocfs_stats **statsh)
 	unsigned int percpusize;
 	unsigned int i;
 
-	if (stats == NULL || stats->ls_num == 0)
+	if (!stats || stats->ls_num == 0)
 		return;
 	*statsh = NULL;
 
@@ -1070,9 +1070,9 @@ void lprocfs_free_stats(struct lprocfs_stats **statsh)
 
 	percpusize = lprocfs_stats_counter_size(stats);
 	for (i = 0; i < num_entry; i++)
-		if (stats->ls_percpu[i] != NULL)
+		if (stats->ls_percpu[i])
 			LIBCFS_FREE(stats->ls_percpu[i], percpusize);
-	if (stats->ls_cnt_header != NULL)
+	if (stats->ls_cnt_header)
 		LIBCFS_FREE(stats->ls_cnt_header, stats->ls_num *
 					sizeof(struct lprocfs_counter_header));
 	LIBCFS_FREE(stats, offsetof(typeof(*stats), ls_percpu[num_entry]));
@@ -1090,7 +1090,7 @@ void lprocfs_clear_stats(struct lprocfs_stats *stats)
 	num_entry = lprocfs_stats_lock(stats, LPROCFS_GET_NUM_CPU, &flags);
 
 	for (i = 0; i < num_entry; i++) {
-		if (stats->ls_percpu[i] == NULL)
+		if (!stats->ls_percpu[i])
 			continue;
 		for (j = 0; j < stats->ls_num; j++) {
 			percpu_cntr = lprocfs_stats_counter_get(stats, i, j);
@@ -1230,10 +1230,8 @@ void lprocfs_counter_init(struct lprocfs_stats *stats, int index,
 	unsigned int			i;
 	unsigned int			num_cpu;
 
-	LASSERT(stats != NULL);
-
 	header = &stats->ls_cnt_header[index];
-	LASSERTF(header != NULL, "Failed to allocate stats header:[%d]%s/%s\n",
+	LASSERTF(header, "Failed to allocate stats header:[%d]%s/%s\n",
 		 index, name, units);
 
 	header->lc_config = conf;
@@ -1242,7 +1240,7 @@ void lprocfs_counter_init(struct lprocfs_stats *stats, int index,
 
 	num_cpu = lprocfs_stats_lock(stats, LPROCFS_GET_NUM_CPU, &flags);
 	for (i = 0; i < num_cpu; ++i) {
-		if (stats->ls_percpu[i] == NULL)
+		if (!stats->ls_percpu[i])
 			continue;
 		percpu_cntr = lprocfs_stats_counter_get(stats, i, index);
 		percpu_cntr->lc_count		= 0;
@@ -1270,7 +1268,7 @@ __s64 lprocfs_read_helper(struct lprocfs_counter *lc,
 {
 	__s64 ret = 0;
 
-	if (lc == NULL || header == NULL)
+	if (!lc || !header)
 		return 0;
 
 	switch (field) {
@@ -1412,7 +1410,7 @@ char *lprocfs_find_named_value(const char *buffer, const char *name,
 
 	/* there is no strnstr() in rhel5 and ubuntu kernels */
 	val = lprocfs_strnstr(buffer, name, buflen);
-	if (val == NULL)
+	if (!val)
 		return (char *)buffer;
 
 	val += strlen(name);			     /* skip prefix */
diff --git a/drivers/staging/lustre/lustre/obdclass/lu_object.c b/drivers/staging/lustre/lustre/obdclass/lu_object.c
index ce248f4..15ffbbf 100644
--- a/drivers/staging/lustre/lustre/obdclass/lu_object.c
+++ b/drivers/staging/lustre/lustre/obdclass/lu_object.c
@@ -86,13 +86,12 @@ void lu_object_put(const struct lu_env *env, struct lu_object *o)
 	 */
 	fid = lu_object_fid(o);
 	if (fid_is_zero(fid)) {
-		LASSERT(top->loh_hash.next == NULL
-			&& top->loh_hash.pprev == NULL);
+		LASSERT(!top->loh_hash.next && !top->loh_hash.pprev);
 		LASSERT(list_empty(&top->loh_lru));
 		if (!atomic_dec_and_test(&top->loh_ref))
 			return;
 		list_for_each_entry_reverse(o, &top->loh_layers, lo_linkage) {
-			if (o->lo_ops->loo_object_release != NULL)
+			if (o->lo_ops->loo_object_release)
 				o->lo_ops->loo_object_release(env, o);
 		}
 		lu_object_free(env, orig);
@@ -119,7 +118,7 @@ void lu_object_put(const struct lu_env *env, struct lu_object *o)
 	 * layers, and notify them that object is no longer busy.
 	 */
 	list_for_each_entry_reverse(o, &top->loh_layers, lo_linkage) {
-		if (o->lo_ops->loo_object_release != NULL)
+		if (o->lo_ops->loo_object_release)
 			o->lo_ops->loo_object_release(env, o);
 	}
 
@@ -210,7 +209,7 @@ static struct lu_object *lu_object_alloc(const struct lu_env *env,
 	 * lu_object_header.
 	 */
 	top = dev->ld_ops->ldo_object_alloc(env, NULL, dev);
-	if (top == NULL)
+	if (!top)
 		return ERR_PTR(-ENOMEM);
 	if (IS_ERR(top))
 		return top;
@@ -245,7 +244,7 @@ next:
 	} while (!clean);
 
 	list_for_each_entry_reverse(scan, layers, lo_linkage) {
-		if (scan->lo_ops->loo_object_start != NULL) {
+		if (scan->lo_ops->loo_object_start) {
 			result = scan->lo_ops->loo_object_start(env, scan);
 			if (result != 0) {
 				lu_object_free(env, top);
@@ -276,7 +275,7 @@ static void lu_object_free(const struct lu_env *env, struct lu_object *o)
 	 * First call ->loo_object_delete() method to release all resources.
 	 */
 	list_for_each_entry_reverse(scan, layers, lo_linkage) {
-		if (scan->lo_ops->loo_object_delete != NULL)
+		if (scan->lo_ops->loo_object_delete)
 			scan->lo_ops->loo_object_delete(env, scan);
 	}
 
@@ -296,7 +295,6 @@ static void lu_object_free(const struct lu_env *env, struct lu_object *o)
 		 */
 		o = container_of0(splice.prev, struct lu_object, lo_linkage);
 		list_del_init(&o->lo_linkage);
-		LASSERT(o->lo_ops->loo_object_free != NULL);
 		o->lo_ops->loo_object_free(env, o);
 	}
 
@@ -451,7 +449,6 @@ int lu_cdebug_printer(const struct lu_env *env,
 	va_start(args, format);
 
 	key = lu_context_key_get(&env->le_ctx, &lu_global_key);
-	LASSERT(key != NULL);
 
 	used = strlen(key->lck_area);
 	complete = format[strlen(format) - 1] == '\n';
@@ -508,7 +505,7 @@ void lu_object_print(const struct lu_env *env, void *cookie,
 		(*printer)(env, cookie, "%*.*s%s@%p", depth, depth, ruler,
 			   o->lo_dev->ld_type->ldt_name, o);
 
-		if (o->lo_ops->loo_object_print != NULL)
+		if (o->lo_ops->loo_object_print)
 			(*o->lo_ops->loo_object_print)(env, cookie, printer, o);
 
 		(*printer)(env, cookie, "\n");
@@ -537,7 +534,7 @@ static struct lu_object *htable_lookup(struct lu_site *s,
 	/* cfs_hash_bd_peek_locked is a somehow "internal" function
 	 * of cfs_hash, it doesn't add refcount on object. */
 	hnode = cfs_hash_bd_peek_locked(s->ls_obj_hash, bd, (void *)f);
-	if (hnode == NULL) {
+	if (!hnode) {
 		lprocfs_counter_incr(s->ls_stats, LU_SS_CACHE_MISS);
 		return ERR_PTR(-ENOENT);
 	}
@@ -636,7 +633,7 @@ static struct lu_object *lu_object_find_try(const struct lu_env *env,
 	 * If dying object is found during index search, add @waiter to the
 	 * site wait-queue and return ERR_PTR(-EAGAIN).
 	 */
-	if (conf != NULL && conf->loc_flags & LOC_F_NEW)
+	if (conf && conf->loc_flags & LOC_F_NEW)
 		return lu_object_new(env, dev, f, conf);
 
 	s  = dev->ld_site;
@@ -715,7 +712,7 @@ struct lu_object *lu_object_find_slice(const struct lu_env *env,
 	top = lu_object_find(env, dev, f, conf);
 	if (!IS_ERR(top)) {
 		obj = lu_object_locate(top->lo_header, dev->ld_type);
-		if (obj == NULL)
+		if (!obj)
 			lu_object_put(env, top);
 	} else
 		obj = top;
@@ -966,11 +963,11 @@ int lu_site_init(struct lu_site *s, struct lu_device *top)
 						 CFS_HASH_NO_ITEMREF |
 						 CFS_HASH_DEPTH |
 						 CFS_HASH_ASSERT_EMPTY);
-		if (s->ls_obj_hash != NULL)
+		if (s->ls_obj_hash)
 			break;
 	}
 
-	if (s->ls_obj_hash == NULL) {
+	if (!s->ls_obj_hash) {
 		CERROR("failed to create lu_site hash with bits: %d\n", bits);
 		return -ENOMEM;
 	}
@@ -982,7 +979,7 @@ int lu_site_init(struct lu_site *s, struct lu_device *top)
 	}
 
 	s->ls_stats = lprocfs_alloc_stats(LU_SS_LAST_STAT, 0);
-	if (s->ls_stats == NULL) {
+	if (!s->ls_stats) {
 		cfs_hash_putref(s->ls_obj_hash);
 		s->ls_obj_hash = NULL;
 		return -ENOMEM;
@@ -1031,19 +1028,19 @@ void lu_site_fini(struct lu_site *s)
 	list_del_init(&s->ls_linkage);
 	mutex_unlock(&lu_sites_guard);
 
-	if (s->ls_obj_hash != NULL) {
+	if (s->ls_obj_hash) {
 		cfs_hash_putref(s->ls_obj_hash);
 		s->ls_obj_hash = NULL;
 	}
 
-	if (s->ls_top_dev != NULL) {
+	if (s->ls_top_dev) {
 		s->ls_top_dev->ld_site = NULL;
 		lu_ref_del(&s->ls_top_dev->ld_reference, "site-top", s);
 		lu_device_put(s->ls_top_dev);
 		s->ls_top_dev = NULL;
 	}
 
-	if (s->ls_stats != NULL)
+	if (s->ls_stats)
 		lprocfs_free_stats(&s->ls_stats);
 }
 EXPORT_SYMBOL(lu_site_fini);
@@ -1088,7 +1085,7 @@ EXPORT_SYMBOL(lu_device_put);
  */
 int lu_device_init(struct lu_device *d, struct lu_device_type *t)
 {
-	if (t->ldt_device_nr++ == 0 && t->ldt_ops->ldto_start != NULL)
+	if (t->ldt_device_nr++ == 0 && t->ldt_ops->ldto_start)
 		t->ldt_ops->ldto_start(t);
 	memset(d, 0, sizeof(*d));
 	atomic_set(&d->ld_ref, 0);
@@ -1107,7 +1104,7 @@ void lu_device_fini(struct lu_device *d)
 	struct lu_device_type *t;
 
 	t = d->ld_type;
-	if (d->ld_obd != NULL) {
+	if (d->ld_obd) {
 		d->ld_obd->obd_lu_dev = NULL;
 		d->ld_obd = NULL;
 	}
@@ -1116,7 +1113,7 @@ void lu_device_fini(struct lu_device *d)
 	LASSERTF(atomic_read(&d->ld_ref) == 0,
 		 "Refcount is %u\n", atomic_read(&d->ld_ref));
 	LASSERT(t->ldt_device_nr > 0);
-	if (--t->ldt_device_nr == 0 && t->ldt_ops->ldto_stop != NULL)
+	if (--t->ldt_device_nr == 0 && t->ldt_ops->ldto_stop)
 		t->ldt_ops->ldto_stop(t);
 }
 EXPORT_SYMBOL(lu_device_fini);
@@ -1148,7 +1145,7 @@ void lu_object_fini(struct lu_object *o)
 
 	LASSERT(list_empty(&o->lo_linkage));
 
-	if (dev != NULL) {
+	if (dev) {
 		lu_ref_del_at(&dev->ld_reference, &o->lo_dev_ref,
 			      "lu_object", o);
 		lu_device_put(dev);
@@ -1239,7 +1236,7 @@ void lu_stack_fini(const struct lu_env *env, struct lu_device *top)
 	struct lu_device *next;
 
 	lu_site_purge(env, site, ~0);
-	for (scan = top; scan != NULL; scan = next) {
+	for (scan = top; scan; scan = next) {
 		next = scan->ld_type->ldt_ops->ldto_device_fini(env, scan);
 		lu_ref_del(&scan->ld_reference, "lu-stack", &lu_site_init);
 		lu_device_put(scan);
@@ -1248,13 +1245,13 @@ void lu_stack_fini(const struct lu_env *env, struct lu_device *top)
 	/* purge again. */
 	lu_site_purge(env, site, ~0);
 
-	for (scan = top; scan != NULL; scan = next) {
+	for (scan = top; scan; scan = next) {
 		const struct lu_device_type *ldt = scan->ld_type;
 		struct obd_type	     *type;
 
 		next = ldt->ldt_ops->ldto_device_free(env, scan);
 		type = ldt->ldt_obd_type;
-		if (type != NULL) {
+		if (type) {
 			type->typ_refcnt--;
 			class_put_type(type);
 		}
@@ -1289,14 +1286,14 @@ int lu_context_key_register(struct lu_context_key *key)
 	int result;
 	int i;
 
-	LASSERT(key->lct_init != NULL);
-	LASSERT(key->lct_fini != NULL);
+	LASSERT(key->lct_init);
+	LASSERT(key->lct_fini);
 	LASSERT(key->lct_tags != 0);
 
 	result = -ENFILE;
 	spin_lock(&lu_keys_guard);
 	for (i = 0; i < ARRAY_SIZE(lu_keys); ++i) {
-		if (lu_keys[i] == NULL) {
+		if (!lu_keys[i]) {
 			key->lct_index = i;
 			atomic_set(&key->lct_used, 1);
 			lu_keys[i] = key;
@@ -1313,12 +1310,10 @@ EXPORT_SYMBOL(lu_context_key_register);
 
 static void key_fini(struct lu_context *ctx, int index)
 {
-	if (ctx->lc_value != NULL && ctx->lc_value[index] != NULL) {
+	if (ctx->lc_value && ctx->lc_value[index]) {
 		struct lu_context_key *key;
 
 		key = lu_keys[index];
-		LASSERT(key != NULL);
-		LASSERT(key->lct_fini != NULL);
 		LASSERT(atomic_read(&key->lct_used) > 1);
 
 		key->lct_fini(ctx, key, ctx->lc_value[index]);
@@ -1376,7 +1371,7 @@ int lu_context_key_register_many(struct lu_context_key *k, ...)
 		if (result)
 			break;
 		key = va_arg(args, struct lu_context_key *);
-	} while (key != NULL);
+	} while (key);
 	va_end(args);
 
 	if (result != 0) {
@@ -1404,7 +1399,7 @@ void lu_context_key_degister_many(struct lu_context_key *k, ...)
 	do {
 		lu_context_key_degister(k);
 		k = va_arg(args, struct lu_context_key*);
-	} while (k != NULL);
+	} while (k);
 	va_end(args);
 }
 EXPORT_SYMBOL(lu_context_key_degister_many);
@@ -1420,7 +1415,7 @@ void lu_context_key_revive_many(struct lu_context_key *k, ...)
 	do {
 		lu_context_key_revive(k);
 		k = va_arg(args, struct lu_context_key*);
-	} while (k != NULL);
+	} while (k);
 	va_end(args);
 }
 EXPORT_SYMBOL(lu_context_key_revive_many);
@@ -1436,7 +1431,7 @@ void lu_context_key_quiesce_many(struct lu_context_key *k, ...)
 	do {
 		lu_context_key_quiesce(k);
 		k = va_arg(args, struct lu_context_key*);
-	} while (k != NULL);
+	} while (k);
 	va_end(args);
 }
 EXPORT_SYMBOL(lu_context_key_quiesce_many);
@@ -1497,7 +1492,7 @@ static void keys_fini(struct lu_context *ctx)
 {
 	int	i;
 
-	if (ctx->lc_value == NULL)
+	if (!ctx->lc_value)
 		return;
 
 	for (i = 0; i < ARRAY_SIZE(lu_keys); ++i)
@@ -1511,12 +1506,12 @@ static int keys_fill(struct lu_context *ctx)
 {
 	int i;
 
-	LINVRNT(ctx->lc_value != NULL);
+	LINVRNT(ctx->lc_value);
 	for (i = 0; i < ARRAY_SIZE(lu_keys); ++i) {
 		struct lu_context_key *key;
 
 		key = lu_keys[i];
-		if (ctx->lc_value[i] == NULL && key != NULL &&
+		if (!ctx->lc_value[i] && key &&
 		    (key->lct_tags & ctx->lc_tags) &&
 		    /*
 		     * Don't create values for a LCT_QUIESCENT key, as this
@@ -1525,7 +1520,7 @@ static int keys_fill(struct lu_context *ctx)
 		    !(key->lct_tags & LCT_QUIESCENT)) {
 			void *value;
 
-			LINVRNT(key->lct_init != NULL);
+			LINVRNT(key->lct_init);
 			LINVRNT(key->lct_index == i);
 
 			value = key->lct_init(ctx, key);
@@ -1542,7 +1537,7 @@ static int keys_fill(struct lu_context *ctx)
 			 * value.
 			 */
 			ctx->lc_value[i] = value;
-			if (key->lct_exit != NULL)
+			if (key->lct_exit)
 				ctx->lc_tags |= LCT_HAS_EXIT;
 		}
 		ctx->lc_version = key_set_version;
@@ -1554,7 +1549,7 @@ static int keys_init(struct lu_context *ctx)
 {
 	ctx->lc_value = kcalloc(ARRAY_SIZE(lu_keys), sizeof(ctx->lc_value[0]),
 				GFP_NOFS);
-	if (likely(ctx->lc_value != NULL))
+	if (likely(ctx->lc_value))
 		return keys_fill(ctx);
 
 	return -ENOMEM;
@@ -1626,14 +1621,13 @@ void lu_context_exit(struct lu_context *ctx)
 
 	LINVRNT(ctx->lc_state == LCS_ENTERED);
 	ctx->lc_state = LCS_LEFT;
-	if (ctx->lc_tags & LCT_HAS_EXIT && ctx->lc_value != NULL) {
+	if (ctx->lc_tags & LCT_HAS_EXIT && ctx->lc_value) {
 		for (i = 0; i < ARRAY_SIZE(lu_keys); ++i) {
-			if (ctx->lc_value[i] != NULL) {
+			if (ctx->lc_value[i]) {
 				struct lu_context_key *key;
 
 				key = lu_keys[i];
-				LASSERT(key != NULL);
-				if (key->lct_exit != NULL)
+				if (key->lct_exit)
 					key->lct_exit(ctx,
 						      key, ctx->lc_value[i]);
 			}
@@ -1688,7 +1682,7 @@ int lu_env_refill(struct lu_env *env)
 	int result;
 
 	result = lu_context_refill(&env->le_ctx);
-	if (result == 0 && env->le_ses != NULL)
+	if (result == 0 && env->le_ses)
 		result = lu_context_refill(env->le_ses);
 	return result;
 }
@@ -1922,11 +1916,11 @@ int lu_kmem_init(struct lu_kmem_descr *caches)
 	int result;
 	struct lu_kmem_descr *iter = caches;
 
-	for (result = 0; iter->ckd_cache != NULL; ++iter) {
+	for (result = 0; iter->ckd_cache; ++iter) {
 		*iter->ckd_cache = kmem_cache_create(iter->ckd_name,
 							iter->ckd_size,
 							0, 0, NULL);
-		if (*iter->ckd_cache == NULL) {
+		if (!*iter->ckd_cache) {
 			result = -ENOMEM;
 			/* free all previously allocated caches */
 			lu_kmem_fini(caches);
@@ -1943,7 +1937,7 @@ EXPORT_SYMBOL(lu_kmem_init);
  */
 void lu_kmem_fini(struct lu_kmem_descr *caches)
 {
-	for (; caches->ckd_cache != NULL; ++caches) {
+	for (; caches->ckd_cache; ++caches) {
 		kmem_cache_destroy(*caches->ckd_cache);
 		*caches->ckd_cache = NULL;
 	}
diff --git a/drivers/staging/lustre/lustre/obdclass/lustre_handles.c b/drivers/staging/lustre/lustre/obdclass/lustre_handles.c
index fb9147c..2bbbc9f 100644
--- a/drivers/staging/lustre/lustre/obdclass/lustre_handles.c
+++ b/drivers/staging/lustre/lustre/obdclass/lustre_handles.c
@@ -65,7 +65,7 @@ void class_handle_hash(struct portals_handle *h,
 {
 	struct handle_bucket *bucket;
 
-	LASSERT(h != NULL);
+	LASSERT(h);
 	LASSERT(list_empty(&h->h_link));
 
 	/*
@@ -140,7 +140,7 @@ void *class_handle2object(__u64 cookie)
 	struct portals_handle *h;
 	void *retval = NULL;
 
-	LASSERT(handle_hash != NULL);
+	LASSERT(handle_hash);
 
 	/* Be careful when you want to change this code. See the
 	 * rcu_read_lock() definition on top this file. - jxiong */
@@ -170,7 +170,7 @@ void class_handle_free_cb(struct rcu_head *rcu)
 	struct portals_handle *h = RCU2HANDLE(rcu);
 	void *ptr = (void *)(unsigned long)h->h_cookie;
 
-	if (h->h_ops->hop_free != NULL)
+	if (h->h_ops->hop_free)
 		h->h_ops->hop_free(ptr, h->h_size);
 	else
 		kfree(ptr);
@@ -183,11 +183,11 @@ int class_handle_init(void)
 	struct timespec64 ts;
 	int seed[2];
 
-	LASSERT(handle_hash == NULL);
+	LASSERT(!handle_hash);
 
 	handle_hash = libcfs_kvzalloc(sizeof(*bucket) * HANDLE_HASH_SIZE,
 				      GFP_NOFS);
-	if (handle_hash == NULL)
+	if (!handle_hash)
 		return -ENOMEM;
 
 	spin_lock_init(&handle_base_lock);
@@ -234,7 +234,7 @@ void class_handle_cleanup(void)
 {
 	int count;
 
-	LASSERT(handle_hash != NULL);
+	LASSERT(handle_hash);
 
 	count = cleanup_all_handles();
 
diff --git a/drivers/staging/lustre/lustre/obdclass/lustre_peer.c b/drivers/staging/lustre/lustre/obdclass/lustre_peer.c
index d6184f8..e90041b 100644
--- a/drivers/staging/lustre/lustre/obdclass/lustre_peer.c
+++ b/drivers/staging/lustre/lustre/obdclass/lustre_peer.c
@@ -151,7 +151,7 @@ int class_del_uuid(const char *uuid)
 	struct uuid_nid_data *data;
 
 	spin_lock(&g_uuid_lock);
-	if (uuid != NULL) {
+	if (uuid) {
 		struct obd_uuid tmp;
 
 		obd_str2uuid(&tmp, uuid);
@@ -165,7 +165,7 @@ int class_del_uuid(const char *uuid)
 		list_splice_init(&g_uuid_list, &deathrow);
 	spin_unlock(&g_uuid_lock);
 
-	if (uuid != NULL && list_empty(&deathrow)) {
+	if (uuid && list_empty(&deathrow)) {
 		CDEBUG(D_INFO, "Try to delete a non-existent uuid %s\n", uuid);
 		return -EINVAL;
 	}
diff --git a/drivers/staging/lustre/lustre/obdclass/obd_config.c b/drivers/staging/lustre/lustre/obdclass/obd_config.c
index 49cdc64..c4128ac 100644
--- a/drivers/staging/lustre/lustre/obdclass/obd_config.c
+++ b/drivers/staging/lustre/lustre/obdclass/obd_config.c
@@ -210,7 +210,7 @@ static int class_attach(struct lustre_cfg *lcfg)
 		       name, typename, rc);
 		goto out;
 	}
-	LASSERTF(obd != NULL, "Cannot get obd device %s of type %s\n",
+	LASSERTF(obd, "Cannot get obd device %s of type %s\n",
 		 name, typename);
 	LASSERTF(obd->obd_magic == OBD_DEVICE_MAGIC,
 		 "obd %p obd_magic %08X != %08X\n",
@@ -272,9 +272,9 @@ static int class_attach(struct lustre_cfg *lcfg)
 	       obd->obd_minor, typename, atomic_read(&obd->obd_refcount));
 	return 0;
  out:
-	if (obd != NULL) {
+	if (obd)
 		class_release_dev(obd);
-	}
+
 	return rc;
 }
 
@@ -286,7 +286,7 @@ static int class_setup(struct obd_device *obd, struct lustre_cfg *lcfg)
 	int err = 0;
 	struct obd_export *exp;
 
-	LASSERT(obd != NULL);
+	LASSERT(obd);
 	LASSERTF(obd == class_num2obd(obd->obd_minor),
 		 "obd %p != obd_devs[%d] %p\n",
 		 obd, obd->obd_minor, class_num2obd(obd->obd_minor));
@@ -1183,7 +1183,7 @@ int class_config_llog_handler(const struct lu_env *env,
 
 		/* we override the llog's uuid for clients, to insure they
 		are unique */
-		if (clli && clli->cfg_instance != NULL &&
+		if (clli && clli->cfg_instance &&
 		    lcfg->lcfg_command == LCFG_ATTACH) {
 			lustre_cfg_bufs_set_string(&bufs, 2,
 						   clli->cfg_uuid.uuid);
@@ -1270,7 +1270,7 @@ int class_config_parse_llog(const struct lu_env *env, struct llog_ctxt *ctxt,
 	if (cfg) {
 		cd.lpcd_first_idx = cfg->cfg_last_idx;
 		callback = cfg->cfg_callback;
-		LASSERT(callback != NULL);
+		LASSERT(callback);
 	} else {
 		callback = class_config_llog_handler;
 	}
diff --git a/drivers/staging/lustre/lustre/obdclass/obd_mount.c b/drivers/staging/lustre/lustre/obdclass/obd_mount.c
index b5aa816..9618cc2 100644
--- a/drivers/staging/lustre/lustre/obdclass/obd_mount.c
+++ b/drivers/staging/lustre/lustre/obdclass/obd_mount.c
@@ -518,13 +518,12 @@ static int lustre_free_lsi(struct super_block *sb)
 {
 	struct lustre_sb_info *lsi = s2lsi(sb);
 
-	LASSERT(lsi != NULL);
 	CDEBUG(D_MOUNT, "Freeing lsi %p\n", lsi);
 
 	/* someone didn't call server_put_mount. */
 	LASSERT(atomic_read(&lsi->lsi_mounts) == 0);
 
-	if (lsi->lsi_lmd != NULL) {
+	if (lsi->lsi_lmd) {
 		kfree(lsi->lsi_lmd->lmd_dev);
 		kfree(lsi->lsi_lmd->lmd_profile);
 		kfree(lsi->lsi_lmd->lmd_mgssec);
@@ -538,7 +537,7 @@ static int lustre_free_lsi(struct super_block *sb)
 		kfree(lsi->lsi_lmd);
 	}
 
-	LASSERT(lsi->lsi_llsbi == NULL);
+	LASSERT(!lsi->lsi_llsbi);
 	kfree(lsi);
 	s2lsi_nocast(sb) = NULL;
 
@@ -551,8 +550,6 @@ static int lustre_put_lsi(struct super_block *sb)
 {
 	struct lustre_sb_info *lsi = s2lsi(sb);
 
-	LASSERT(lsi != NULL);
-
 	CDEBUG(D_MOUNT, "put %p %d\n", sb, atomic_read(&lsi->lsi_mounts));
 	if (atomic_dec_and_test(&lsi->lsi_mounts)) {
 		lustre_free_lsi(sb);
@@ -588,12 +585,12 @@ static int server_name2fsname(const char *svname, char *fsname,
 	if (dash == svname)
 		return -EINVAL;
 
-	if (fsname != NULL) {
+	if (fsname) {
 		strncpy(fsname, svname, dash - svname);
 		fsname[dash - svname] = '\0';
 	}
 
-	if (endptr != NULL)
+	if (endptr)
 		*endptr = dash;
 
 	return 0;
@@ -627,18 +624,18 @@ static int server_name2index(const char *svname, __u32 *idx,
 	dash += 3;
 
 	if (strncmp(dash, "all", 3) == 0) {
-		if (endptr != NULL)
+		if (endptr)
 			*endptr = dash + 3;
 		return rc | LDD_F_SV_ALL;
 	}
 
 	index = simple_strtoul(dash, (char **)endptr, 16);
-	if (idx != NULL)
+	if (idx)
 		*idx = index;
 
 	/* Account for -mdc after index that is possible when specifying mdt */
-	if (endptr != NULL && strncmp(LUSTRE_MDC_NAME, *endptr + 1,
-				      sizeof(LUSTRE_MDC_NAME)-1) == 0)
+	if (endptr && strncmp(LUSTRE_MDC_NAME, *endptr + 1,
+			      sizeof(LUSTRE_MDC_NAME) - 1) == 0)
 		*endptr += sizeof(LUSTRE_MDC_NAME);
 
 	return rc;
@@ -788,7 +785,7 @@ static int lmd_parse_mgssec(struct lustre_mount_data *lmd, char *ptr)
 	lmd->lmd_mgssec = NULL;
 
 	tail = strchr(ptr, ',');
-	if (tail == NULL)
+	if (!tail)
 		length = strlen(ptr);
 	else
 		length = tail - ptr;
@@ -807,14 +804,14 @@ static int lmd_parse_string(char **handle, char *ptr)
 	char   *tail;
 	int     length;
 
-	if ((handle == NULL) || (ptr == NULL))
+	if (!handle || !ptr)
 		return -EINVAL;
 
 	kfree(*handle);
 	*handle = NULL;
 
 	tail = strchr(ptr, ',');
-	if (tail == NULL)
+	if (!tail)
 		length = strlen(ptr);
 	else
 		length = tail - ptr;
@@ -847,14 +844,14 @@ static int lmd_parse_mgs(struct lustre_mount_data *lmd, char **ptr)
 		return -EINVAL;
 	}
 
-	if (lmd->lmd_mgs != NULL)
+	if (lmd->lmd_mgs)
 		oldlen = strlen(lmd->lmd_mgs) + 1;
 
 	mgsnid = kzalloc(oldlen + length + 1, GFP_NOFS);
 	if (!mgsnid)
 		return -ENOMEM;
 
-	if (lmd->lmd_mgs != NULL) {
+	if (lmd->lmd_mgs) {
 		/* Multiple mgsnid= are taken to mean failover locations */
 		memcpy(mgsnid, lmd->lmd_mgs, oldlen);
 		mgsnid[oldlen - 1] = ':';
@@ -981,7 +978,7 @@ static int lmd_parse(char *options, struct lustre_mount_data *lmd)
 			size_t length, params_length;
 			char *tail = strchr(s1 + 6, ',');
 
-			if (tail == NULL)
+			if (!tail)
 				length = strlen(s1);
 			else
 				length = tail - s1;
@@ -1011,7 +1008,7 @@ static int lmd_parse(char *options, struct lustre_mount_data *lmd)
 
 		/* Find next opt */
 		s2 = strchr(s1, ',');
-		if (s2 == NULL) {
+		if (!s2) {
 			if (clear)
 				*s1 = '\0';
 			break;
@@ -1113,9 +1110,9 @@ static int lustre_fill_super(struct super_block *sb, void *data, int silent)
 
 	if (lmd_is_client(lmd)) {
 		CDEBUG(D_MOUNT, "Mounting client %s\n", lmd->lmd_profile);
-		if (client_fill_super == NULL)
+		if (!client_fill_super)
 			request_module("lustre");
-		if (client_fill_super == NULL) {
+		if (!client_fill_super) {
 			LCONSOLE_ERROR_MSG(0x165, "Nothing registered for client mount! Is the 'lustre' module loaded?\n");
 			lustre_put_lsi(sb);
 			rc = -ENODEV;
-- 
2.1.0
