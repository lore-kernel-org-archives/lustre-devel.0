From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Wed, 30 Mar 2016 19:48:47 -0400
Subject: [lustre-devel] [PATCH v2 26/46] staging/lustre/llite: rename
	ccc_object to vvp_object
In-Reply-To: <1459381747-2886687-1-git-send-email-green@linuxhacker.ru>
References: <1459381747-2886687-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1459381747-2886687-27-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, "John L. Hammond" <john.hammond@intel.com>, Oleg Drokin <green@linuxhacker.ru>

From: "John L. Hammond" <john.hammond@intel.com>

Rename struct ccc_object to struct vvp_object and merge the CCC object
methods into the VVP object methods.

Signed-off-by: John L. Hammond <john.hammond@intel.com>
Reviewed-on: http://review.whamcloud.com/13077
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5971
Reviewed-by: James Simmons <uja.ornl@gmail.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/include/cl_object.h  |   4 +-
 drivers/staging/lustre/lustre/llite/glimpse.c      |   4 +-
 drivers/staging/lustre/lustre/llite/lcommon_cl.c   | 166 ++-------------------
 drivers/staging/lustre/lustre/llite/llite_close.c  |  22 +--
 .../staging/lustre/lustre/llite/llite_internal.h   |   6 +-
 drivers/staging/lustre/lustre/llite/llite_lib.c    |   4 +-
 drivers/staging/lustre/lustre/llite/llite_mmap.c   |  16 +-
 drivers/staging/lustre/lustre/llite/rw.c           |   4 +-
 drivers/staging/lustre/lustre/llite/rw26.c         |   6 +-
 drivers/staging/lustre/lustre/llite/vvp_dev.c      |  10 +-
 drivers/staging/lustre/lustre/llite/vvp_internal.h |  61 ++++----
 drivers/staging/lustre/lustre/llite/vvp_io.c       |  36 ++---
 drivers/staging/lustre/lustre/llite/vvp_object.c   | 121 +++++++++++++--
 drivers/staging/lustre/lustre/llite/vvp_page.c     |  40 ++---
 .../staging/lustre/lustre/osc/osc_cl_internal.h    |   2 +-
 15 files changed, 231 insertions(+), 271 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/cl_object.h b/drivers/staging/lustre/lustre/include/cl_object.h
index f2a242b..d3271ff 100644
--- a/drivers/staging/lustre/lustre/include/cl_object.h
+++ b/drivers/staging/lustre/lustre/include/cl_object.h
@@ -245,7 +245,7 @@ enum cl_attr_valid {
  *    be discarded from the memory, all its sub-objects are torn-down and
  *    destroyed too.
  *
- * \see ccc_object, lov_object, lovsub_object, osc_object
+ * \see vvp_object, lov_object, lovsub_object, osc_object
  */
 struct cl_object {
 	/** super class */
@@ -385,7 +385,7 @@ struct cl_object_operations {
 	 * object. Layers are supposed to fill parts of \a lvb that will be
 	 * shipped to the glimpse originator as a glimpse result.
 	 *
-	 * \see ccc_object_glimpse(), lovsub_object_glimpse(),
+	 * \see vvp_object_glimpse(), lovsub_object_glimpse(),
 	 * \see osc_object_glimpse()
 	 */
 	int (*coo_glimpse)(const struct lu_env *env,
diff --git a/drivers/staging/lustre/lustre/llite/glimpse.c b/drivers/staging/lustre/lustre/llite/glimpse.c
index a634633..d76fa16 100644
--- a/drivers/staging/lustre/lustre/llite/glimpse.c
+++ b/drivers/staging/lustre/lustre/llite/glimpse.c
@@ -69,14 +69,14 @@ static const struct cl_lock_descr whole_file = {
 blkcnt_t dirty_cnt(struct inode *inode)
 {
 	blkcnt_t cnt = 0;
-	struct ccc_object *vob = cl_inode2ccc(inode);
+	struct vvp_object *vob = cl_inode2vvp(inode);
 	void	      *results[1];
 
 	if (inode->i_mapping)
 		cnt += radix_tree_gang_lookup_tag(&inode->i_mapping->page_tree,
 						  results, 0, 1,
 						  PAGECACHE_TAG_DIRTY);
-	if (cnt == 0 && atomic_read(&vob->cob_mmap_cnt) > 0)
+	if (cnt == 0 && atomic_read(&vob->vob_mmap_cnt) > 0)
 		cnt = 1;
 
 	return (cnt > 0) ? 1 : 0;
diff --git a/drivers/staging/lustre/lustre/llite/lcommon_cl.c b/drivers/staging/lustre/lustre/llite/lcommon_cl.c
index b0d4a3d..9db0510 100644
--- a/drivers/staging/lustre/lustre/llite/lcommon_cl.c
+++ b/drivers/staging/lustre/lustre/llite/lcommon_cl.c
@@ -68,7 +68,6 @@ static const struct cl_req_operations ccc_req_ops;
  */
 
 static struct kmem_cache *ccc_lock_kmem;
-static struct kmem_cache *ccc_object_kmem;
 static struct kmem_cache *ccc_thread_kmem;
 static struct kmem_cache *ccc_session_kmem;
 static struct kmem_cache *ccc_req_kmem;
@@ -80,11 +79,6 @@ static struct lu_kmem_descr ccc_caches[] = {
 		.ckd_size  = sizeof(struct ccc_lock)
 	},
 	{
-		.ckd_cache = &ccc_object_kmem,
-		.ckd_name  = "ccc_object_kmem",
-		.ckd_size  = sizeof(struct ccc_object)
-	},
-	{
 		.ckd_cache = &ccc_thread_kmem,
 		.ckd_name  = "ccc_thread_kmem",
 		.ckd_size  = sizeof(struct ccc_thread_info),
@@ -227,84 +221,6 @@ void ccc_global_fini(struct lu_device_type *device_type)
 	lu_kmem_fini(ccc_caches);
 }
 
-/*****************************************************************************
- *
- * Object operations.
- *
- */
-
-struct lu_object *ccc_object_alloc(const struct lu_env *env,
-				   const struct lu_object_header *unused,
-				   struct lu_device *dev,
-				   const struct cl_object_operations *clops,
-				   const struct lu_object_operations *luops)
-{
-	struct ccc_object *vob;
-	struct lu_object  *obj;
-
-	vob = kmem_cache_zalloc(ccc_object_kmem, GFP_NOFS);
-	if (vob) {
-		struct cl_object_header *hdr;
-
-		obj = ccc2lu(vob);
-		hdr = &vob->cob_header;
-		cl_object_header_init(hdr);
-		hdr->coh_page_bufsize = cfs_size_round(sizeof(struct cl_page));
-
-		lu_object_init(obj, &hdr->coh_lu, dev);
-		lu_object_add_top(&hdr->coh_lu, obj);
-
-		vob->cob_cl.co_ops = clops;
-		obj->lo_ops = luops;
-	} else {
-		obj = NULL;
-	}
-	return obj;
-}
-
-int ccc_object_init0(const struct lu_env *env,
-		     struct ccc_object *vob,
-		     const struct cl_object_conf *conf)
-{
-	vob->cob_inode = conf->coc_inode;
-	vob->cob_transient_pages = 0;
-	cl_object_page_init(&vob->cob_cl, sizeof(struct ccc_page));
-	return 0;
-}
-
-int ccc_object_init(const struct lu_env *env, struct lu_object *obj,
-		    const struct lu_object_conf *conf)
-{
-	struct vvp_device *dev = lu2vvp_dev(obj->lo_dev);
-	struct ccc_object *vob = lu2ccc(obj);
-	struct lu_object  *below;
-	struct lu_device  *under;
-	int result;
-
-	under = &dev->vdv_next->cd_lu_dev;
-	below = under->ld_ops->ldo_object_alloc(env, obj->lo_header, under);
-	if (below) {
-		const struct cl_object_conf *cconf;
-
-		cconf = lu2cl_conf(conf);
-		INIT_LIST_HEAD(&vob->cob_pending_list);
-		lu_object_add(obj, below);
-		result = ccc_object_init0(env, vob, cconf);
-	} else {
-		result = -ENOMEM;
-	}
-	return result;
-}
-
-void ccc_object_free(const struct lu_env *env, struct lu_object *obj)
-{
-	struct ccc_object *vob = lu2ccc(obj);
-
-	lu_object_fini(obj);
-	lu_object_header_fini(obj->lo_header);
-	kmem_cache_free(ccc_object_kmem, vob);
-}
-
 int ccc_lock_init(const struct lu_env *env,
 		  struct cl_object *obj, struct cl_lock *lock,
 		  const struct cl_io *unused,
@@ -313,7 +229,7 @@ int ccc_lock_init(const struct lu_env *env,
 	struct ccc_lock *clk;
 	int result;
 
-	CLOBINVRNT(env, obj, ccc_object_invariant(obj));
+	CLOBINVRNT(env, obj, vvp_object_invariant(obj));
 
 	clk = kmem_cache_zalloc(ccc_lock_kmem, GFP_NOFS);
 	if (clk) {
@@ -325,35 +241,17 @@ int ccc_lock_init(const struct lu_env *env,
 	return result;
 }
 
-int ccc_object_glimpse(const struct lu_env *env,
-		       const struct cl_object *obj, struct ost_lvb *lvb)
-{
-	struct inode *inode = ccc_object_inode(obj);
-
-	lvb->lvb_mtime = LTIME_S(inode->i_mtime);
-	lvb->lvb_atime = LTIME_S(inode->i_atime);
-	lvb->lvb_ctime = LTIME_S(inode->i_ctime);
-	/*
-	 * LU-417: Add dirty pages block count lest i_blocks reports 0, some
-	 * "cp" or "tar" on remote node may think it's a completely sparse file
-	 * and skip it.
-	 */
-	if (lvb->lvb_size > 0 && lvb->lvb_blocks == 0)
-		lvb->lvb_blocks = dirty_cnt(inode);
-	return 0;
-}
-
-static void ccc_object_size_lock(struct cl_object *obj)
+static void vvp_object_size_lock(struct cl_object *obj)
 {
-	struct inode *inode = ccc_object_inode(obj);
+	struct inode *inode = vvp_object_inode(obj);
 
 	ll_inode_size_lock(inode);
 	cl_object_attr_lock(obj);
 }
 
-static void ccc_object_size_unlock(struct cl_object *obj)
+static void vvp_object_size_unlock(struct cl_object *obj)
 {
-	struct inode *inode = ccc_object_inode(obj);
+	struct inode *inode = vvp_object_inode(obj);
 
 	cl_object_attr_unlock(obj);
 	ll_inode_size_unlock(inode);
@@ -399,7 +297,7 @@ int ccc_lock_enqueue(const struct lu_env *env,
 		     const struct cl_lock_slice *slice,
 		     struct cl_io *unused, struct cl_sync_io *anchor)
 {
-	CLOBINVRNT(env, slice->cls_obj, ccc_object_invariant(slice->cls_obj));
+	CLOBINVRNT(env, slice->cls_obj, vvp_object_invariant(slice->cls_obj));
 	return 0;
 }
 
@@ -417,7 +315,7 @@ int ccc_io_one_lock_index(const struct lu_env *env, struct cl_io *io,
 	struct cl_lock_descr   *descr = &cio->cui_link.cill_descr;
 	struct cl_object       *obj   = io->ci_obj;
 
-	CLOBINVRNT(env, obj, ccc_object_invariant(obj));
+	CLOBINVRNT(env, obj, vvp_object_invariant(obj));
 
 	CDEBUG(D_VFSTRACE, "lock: %d [%lu, %lu]\n", mode, start, end);
 
@@ -462,7 +360,7 @@ int ccc_io_one_lock(const struct lu_env *env, struct cl_io *io,
 void ccc_io_end(const struct lu_env *env, const struct cl_io_slice *ios)
 {
 	CLOBINVRNT(env, ios->cis_io->ci_obj,
-		   ccc_object_invariant(ios->cis_io->ci_obj));
+		   vvp_object_invariant(ios->cis_io->ci_obj));
 }
 
 void ccc_io_advance(const struct lu_env *env,
@@ -473,7 +371,7 @@ void ccc_io_advance(const struct lu_env *env,
 	struct cl_io     *io  = ios->cis_io;
 	struct cl_object *obj = ios->cis_io->ci_obj;
 
-	CLOBINVRNT(env, obj, ccc_object_invariant(obj));
+	CLOBINVRNT(env, obj, vvp_object_invariant(obj));
 
 	if (!cl_is_normalio(env, io))
 		return;
@@ -496,7 +394,7 @@ int ccc_prep_size(const struct lu_env *env, struct cl_object *obj,
 		  struct cl_io *io, loff_t start, size_t count, int *exceed)
 {
 	struct cl_attr *attr  = ccc_env_thread_attr(env);
-	struct inode   *inode = ccc_object_inode(obj);
+	struct inode   *inode = vvp_object_inode(obj);
 	loff_t	  pos   = start + count - 1;
 	loff_t kms;
 	int result;
@@ -520,7 +418,7 @@ int ccc_prep_size(const struct lu_env *env, struct cl_object *obj,
 	 * ll_inode_size_lock(). This guarantees that short reads are handled
 	 * correctly in the face of concurrent writes and truncates.
 	 */
-	ccc_object_size_lock(obj);
+	vvp_object_size_lock(obj);
 	result = cl_object_attr_get(env, obj, attr);
 	if (result == 0) {
 		kms = attr->cat_kms;
@@ -530,7 +428,7 @@ int ccc_prep_size(const struct lu_env *env, struct cl_object *obj,
 			 * return a short read (B) or some zeroes at the end
 			 * of the buffer (C)
 			 */
-			ccc_object_size_unlock(obj);
+			vvp_object_size_unlock(obj);
 			result = cl_glimpse_lock(env, io, inode, obj, 0);
 			if (result == 0 && exceed) {
 				/* If objective page index exceed end-of-file
@@ -567,7 +465,9 @@ int ccc_prep_size(const struct lu_env *env, struct cl_object *obj,
 			       (__u64)i_size_read(inode));
 		}
 	}
-	ccc_object_size_unlock(obj);
+
+	vvp_object_size_unlock(obj);
+
 	return result;
 }
 
@@ -618,7 +518,7 @@ void ccc_req_attr_set(const struct lu_env *env,
 	u32	      valid_flags;
 
 	oa = attr->cra_oa;
-	inode = ccc_object_inode(obj);
+	inode = vvp_object_inode(obj);
 	valid_flags = OBD_MD_FLTYPE;
 
 	if (slice->crs_req->crq_type == CRT_WRITE) {
@@ -694,21 +594,6 @@ again:
  *
  */
 
-struct lu_object *ccc2lu(struct ccc_object *vob)
-{
-	return &vob->cob_cl.co_lu;
-}
-
-struct ccc_object *lu2ccc(const struct lu_object *obj)
-{
-	return container_of0(obj, struct ccc_object, cob_cl.co_lu);
-}
-
-struct ccc_object *cl2ccc(const struct cl_object *obj)
-{
-	return container_of0(obj, struct ccc_object, cob_cl);
-}
-
 struct ccc_lock *cl2ccc_lock(const struct cl_lock_slice *slice)
 {
 	return container_of(slice, struct ccc_lock, clk_cl);
@@ -734,25 +619,6 @@ struct page *cl2vm_page(const struct cl_page_slice *slice)
 	return cl2ccc_page(slice)->cpg_page;
 }
 
-/*****************************************************************************
- *
- * Accessors.
- *
- */
-int ccc_object_invariant(const struct cl_object *obj)
-{
-	struct inode	 *inode = ccc_object_inode(obj);
-	struct ll_inode_info	*lli	= ll_i2info(inode);
-
-	return (S_ISREG(inode->i_mode) || inode->i_mode == 0) &&
-	       lli->lli_clob == obj;
-}
-
-struct inode *ccc_object_inode(const struct cl_object *obj)
-{
-	return cl2ccc(obj)->cob_inode;
-}
-
 /**
  * Initialize or update CLIO structures for regular files when new
  * meta-data arrives from the server.
diff --git a/drivers/staging/lustre/lustre/llite/llite_close.c b/drivers/staging/lustre/lustre/llite/llite_close.c
index a55ac4d..6e99d34 100644
--- a/drivers/staging/lustre/lustre/llite/llite_close.c
+++ b/drivers/staging/lustre/lustre/llite/llite_close.c
@@ -46,21 +46,21 @@
 #include "llite_internal.h"
 
 /** records that a write is in flight */
-void vvp_write_pending(struct ccc_object *club, struct ccc_page *page)
+void vvp_write_pending(struct vvp_object *club, struct ccc_page *page)
 {
-	struct ll_inode_info *lli = ll_i2info(club->cob_inode);
+	struct ll_inode_info *lli = ll_i2info(club->vob_inode);
 
 	spin_lock(&lli->lli_lock);
 	lli->lli_flags |= LLIF_SOM_DIRTY;
 	if (page && list_empty(&page->cpg_pending_linkage))
-		list_add(&page->cpg_pending_linkage, &club->cob_pending_list);
+		list_add(&page->cpg_pending_linkage, &club->vob_pending_list);
 	spin_unlock(&lli->lli_lock);
 }
 
 /** records that a write has completed */
-void vvp_write_complete(struct ccc_object *club, struct ccc_page *page)
+void vvp_write_complete(struct vvp_object *club, struct ccc_page *page)
 {
-	struct ll_inode_info *lli = ll_i2info(club->cob_inode);
+	struct ll_inode_info *lli = ll_i2info(club->vob_inode);
 	int rc = 0;
 
 	spin_lock(&lli->lli_lock);
@@ -70,7 +70,7 @@ void vvp_write_complete(struct ccc_object *club, struct ccc_page *page)
 	}
 	spin_unlock(&lli->lli_lock);
 	if (rc)
-		ll_queue_done_writing(club->cob_inode, 0);
+		ll_queue_done_writing(club->vob_inode, 0);
 }
 
 /** Queues DONE_WRITING if
@@ -80,13 +80,13 @@ void vvp_write_complete(struct ccc_object *club, struct ccc_page *page)
 void ll_queue_done_writing(struct inode *inode, unsigned long flags)
 {
 	struct ll_inode_info *lli = ll_i2info(inode);
-	struct ccc_object *club = cl2ccc(ll_i2info(inode)->lli_clob);
+	struct vvp_object *club = cl2vvp(ll_i2info(inode)->lli_clob);
 
 	spin_lock(&lli->lli_lock);
 	lli->lli_flags |= flags;
 
 	if ((lli->lli_flags & LLIF_DONE_WRITING) &&
-	    list_empty(&club->cob_pending_list)) {
+	    list_empty(&club->vob_pending_list)) {
 		struct ll_close_queue *lcq = ll_i2sbi(inode)->ll_lcq;
 
 		if (lli->lli_flags & LLIF_MDS_SIZE_LOCK)
@@ -140,10 +140,10 @@ void ll_ioepoch_close(struct inode *inode, struct md_op_data *op_data,
 		      struct obd_client_handle **och, unsigned long flags)
 {
 	struct ll_inode_info *lli = ll_i2info(inode);
-	struct ccc_object *club = cl2ccc(ll_i2info(inode)->lli_clob);
+	struct vvp_object *club = cl2vvp(ll_i2info(inode)->lli_clob);
 
 	spin_lock(&lli->lli_lock);
-	if (!(list_empty(&club->cob_pending_list))) {
+	if (!(list_empty(&club->vob_pending_list))) {
 		if (!(lli->lli_flags & LLIF_EPOCH_PENDING)) {
 			LASSERT(*och);
 			LASSERT(!lli->lli_pending_och);
@@ -198,7 +198,7 @@ void ll_ioepoch_close(struct inode *inode, struct md_op_data *op_data,
 		}
 	}
 
-	LASSERT(list_empty(&club->cob_pending_list));
+	LASSERT(list_empty(&club->vob_pending_list));
 	lli->lli_flags &= ~LLIF_SOM_DIRTY;
 	spin_unlock(&lli->lli_lock);
 	ll_done_writing_attr(inode, op_data);
diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
index 1e9e41b..1c39d15 100644
--- a/drivers/staging/lustre/lustre/llite/llite_internal.h
+++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
@@ -828,10 +828,8 @@ struct ll_close_queue {
 	atomic_t		lcq_stop;
 };
 
-struct ccc_object *cl_inode2ccc(struct inode *inode);
-
-void vvp_write_pending (struct ccc_object *club, struct ccc_page *page);
-void vvp_write_complete(struct ccc_object *club, struct ccc_page *page);
+void vvp_write_pending(struct vvp_object *club, struct ccc_page *page);
+void vvp_write_complete(struct vvp_object *club, struct ccc_page *page);
 
 /* specific architecture can implement only part of this list */
 enum vvp_io_subtype {
diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index 0f01cfc..95c55c3 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -2270,7 +2270,7 @@ void ll_dirty_page_discard_warn(struct page *page, int ioret)
 {
 	char *buf, *path = NULL;
 	struct dentry *dentry = NULL;
-	struct ccc_object *obj = cl_inode2ccc(page->mapping->host);
+	struct vvp_object *obj = cl_inode2vvp(page->mapping->host);
 
 	/* this can be called inside spin lock so use GFP_ATOMIC. */
 	buf = (char *)__get_free_page(GFP_ATOMIC);
@@ -2284,7 +2284,7 @@ void ll_dirty_page_discard_warn(struct page *page, int ioret)
 	       "%s: dirty page discard: %s/fid: " DFID "/%s may get corrupted (rc %d)\n",
 	       ll_get_fsname(page->mapping->host->i_sb, NULL, 0),
 	       s2lsi(page->mapping->host->i_sb)->lsi_lmd->lmd_dev,
-	       PFID(&obj->cob_header.coh_lu.loh_fid),
+	       PFID(&obj->vob_header.coh_lu.loh_fid),
 	       (path && !IS_ERR(path)) ? path : "", ioret);
 
 	if (dentry)
diff --git a/drivers/staging/lustre/lustre/llite/llite_mmap.c b/drivers/staging/lustre/lustre/llite/llite_mmap.c
index baccf93..1263da8 100644
--- a/drivers/staging/lustre/lustre/llite/llite_mmap.c
+++ b/drivers/staging/lustre/lustre/llite/llite_mmap.c
@@ -200,7 +200,7 @@ static int ll_page_mkwrite0(struct vm_area_struct *vma, struct page *vmpage,
 	 * Otherwise, we could add dirty pages into osc cache
 	 * while truncate is on-going.
 	 */
-	inode = ccc_object_inode(io->ci_obj);
+	inode = vvp_object_inode(io->ci_obj);
 	lli = ll_i2info(inode);
 	down_read(&lli->lli_trunc_sem);
 
@@ -422,16 +422,16 @@ static int ll_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
 
 /**
  *  To avoid cancel the locks covering mmapped region for lock cache pressure,
- *  we track the mapped vma count in ccc_object::cob_mmap_cnt.
+ *  we track the mapped vma count in vvp_object::vob_mmap_cnt.
  */
 static void ll_vm_open(struct vm_area_struct *vma)
 {
 	struct inode *inode    = file_inode(vma->vm_file);
-	struct ccc_object *vob = cl_inode2ccc(inode);
+	struct vvp_object *vob = cl_inode2vvp(inode);
 
 	LASSERT(vma->vm_file);
-	LASSERT(atomic_read(&vob->cob_mmap_cnt) >= 0);
-	atomic_inc(&vob->cob_mmap_cnt);
+	LASSERT(atomic_read(&vob->vob_mmap_cnt) >= 0);
+	atomic_inc(&vob->vob_mmap_cnt);
 }
 
 /**
@@ -440,11 +440,11 @@ static void ll_vm_open(struct vm_area_struct *vma)
 static void ll_vm_close(struct vm_area_struct *vma)
 {
 	struct inode      *inode = file_inode(vma->vm_file);
-	struct ccc_object *vob   = cl_inode2ccc(inode);
+	struct vvp_object *vob   = cl_inode2vvp(inode);
 
 	LASSERT(vma->vm_file);
-	atomic_dec(&vob->cob_mmap_cnt);
-	LASSERT(atomic_read(&vob->cob_mmap_cnt) >= 0);
+	atomic_dec(&vob->vob_mmap_cnt);
+	LASSERT(atomic_read(&vob->vob_mmap_cnt) >= 0);
 }
 
 /* XXX put nice comment here.  talk about __free_pte -> dirty pages and
diff --git a/drivers/staging/lustre/lustre/llite/rw.c b/drivers/staging/lustre/lustre/llite/rw.c
index ad15058..5ae0993 100644
--- a/drivers/staging/lustre/lustre/llite/rw.c
+++ b/drivers/staging/lustre/lustre/llite/rw.c
@@ -343,7 +343,7 @@ static int ll_read_ahead_page(const struct lu_env *env, struct cl_io *io,
 			      pgoff_t index, pgoff_t *max_index)
 {
 	struct cl_object *clob  = io->ci_obj;
-	struct inode     *inode = ccc_object_inode(clob);
+	struct inode     *inode = vvp_object_inode(clob);
 	struct page      *vmpage;
 	struct cl_page   *page;
 	enum ra_stat      which = _NR_RA_STAT; /* keep gcc happy */
@@ -558,7 +558,7 @@ int ll_readahead(const struct lu_env *env, struct cl_io *io,
 	__u64 kms;
 
 	clob = io->ci_obj;
-	inode = ccc_object_inode(clob);
+	inode = vvp_object_inode(clob);
 
 	memset(ria, 0, sizeof(*ria));
 
diff --git a/drivers/staging/lustre/lustre/llite/rw26.c b/drivers/staging/lustre/lustre/llite/rw26.c
index f87238b..ec114bc 100644
--- a/drivers/staging/lustre/lustre/llite/rw26.c
+++ b/drivers/staging/lustre/lustre/llite/rw26.c
@@ -350,7 +350,7 @@ static ssize_t ll_direct_IO_26(struct kiocb *iocb, struct iov_iter *iter,
 	struct cl_io *io;
 	struct file *file = iocb->ki_filp;
 	struct inode *inode = file->f_mapping->host;
-	struct ccc_object *obj = cl_inode2ccc(inode);
+	struct vvp_object *obj = cl_inode2vvp(inode);
 	ssize_t count = iov_iter_count(iter);
 	ssize_t tot_bytes = 0, result = 0;
 	struct ll_inode_info *lli = ll_i2info(inode);
@@ -386,7 +386,7 @@ static ssize_t ll_direct_IO_26(struct kiocb *iocb, struct iov_iter *iter,
 	if (iov_iter_rw(iter) == READ)
 		inode_lock(inode);
 
-	LASSERT(obj->cob_transient_pages == 0);
+	LASSERT(obj->vob_transient_pages == 0);
 	while (iov_iter_count(iter)) {
 		struct page **pages;
 		size_t offs;
@@ -434,7 +434,7 @@ static ssize_t ll_direct_IO_26(struct kiocb *iocb, struct iov_iter *iter,
 		file_offset += result;
 	}
 out:
-	LASSERT(obj->cob_transient_pages == 0);
+	LASSERT(obj->vob_transient_pages == 0);
 	if (iov_iter_rw(iter) == READ)
 		inode_unlock(inode);
 
diff --git a/drivers/staging/lustre/lustre/llite/vvp_dev.c b/drivers/staging/lustre/lustre/llite/vvp_dev.c
index e934ec8..45c549c 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_dev.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_dev.c
@@ -57,10 +57,16 @@
  * "llite_" (var. "ll_") prefix.
  */
 
+struct kmem_cache *vvp_object_kmem;
 static struct kmem_cache *vvp_thread_kmem;
 static struct kmem_cache *vvp_session_kmem;
 static struct lu_kmem_descr vvp_caches[] = {
 	{
+		.ckd_cache = &vvp_object_kmem,
+		.ckd_name  = "vvp_object_kmem",
+		.ckd_size  = sizeof(struct vvp_object),
+	},
+	{
 		.ckd_cache = &vvp_thread_kmem,
 		.ckd_name  = "vvp_thread_kmem",
 		.ckd_size  = sizeof(struct vvp_thread_info),
@@ -431,7 +437,7 @@ static loff_t vvp_pgcache_find(const struct lu_env *env,
 			return ~0ULL;
 		clob = vvp_pgcache_obj(env, dev, &id);
 		if (clob) {
-			struct inode *inode = ccc_object_inode(clob);
+			struct inode *inode = vvp_object_inode(clob);
 			struct page *vmpage;
 			int nr;
 
@@ -512,7 +518,7 @@ static int vvp_pgcache_show(struct seq_file *f, void *v)
 		sbi = f->private;
 		clob = vvp_pgcache_obj(env, &sbi->ll_cl->cd_lu_dev, &id);
 		if (clob) {
-			struct inode *inode = ccc_object_inode(clob);
+			struct inode *inode = vvp_object_inode(clob);
 			struct cl_page *page = NULL;
 			struct page *vmpage;
 
diff --git a/drivers/staging/lustre/lustre/llite/vvp_internal.h b/drivers/staging/lustre/lustre/llite/vvp_internal.h
index 34509f9..76e7b4c 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_internal.h
+++ b/drivers/staging/lustre/lustre/llite/vvp_internal.h
@@ -128,6 +128,8 @@ int cl_is_normalio(const struct lu_env *env, const struct cl_io *io);
 extern struct lu_context_key ccc_key;
 extern struct lu_context_key ccc_session_key;
 
+extern struct kmem_cache *vvp_object_kmem;
+
 struct ccc_thread_info {
 	struct cl_lock		cti_lock;
 	struct cl_lock_descr	cti_descr;
@@ -193,10 +195,10 @@ static inline struct ccc_io *ccc_env_io(const struct lu_env *env)
 /**
  * ccc-private object state.
  */
-struct ccc_object {
-	struct cl_object_header cob_header;
-	struct cl_object        cob_cl;
-	struct inode           *cob_inode;
+struct vvp_object {
+	struct cl_object_header vob_header;
+	struct cl_object        vob_cl;
+	struct inode           *vob_inode;
 
 	/**
 	 * A list of dirty pages pending IO in the cache. Used by
@@ -204,24 +206,24 @@ struct ccc_object {
 	 *
 	 * \see ccc_page::cpg_pending_linkage
 	 */
-	struct list_head	cob_pending_list;
+	struct list_head	vob_pending_list;
 
 	/**
 	 * Access this counter is protected by inode->i_sem. Now that
 	 * the lifetime of transient pages must be covered by inode sem,
 	 * we don't need to hold any lock..
 	 */
-	int			cob_transient_pages;
+	int			vob_transient_pages;
 	/**
 	 * Number of outstanding mmaps on this file.
 	 *
 	 * \see ll_vm_open(), ll_vm_close().
 	 */
-	atomic_t                cob_mmap_cnt;
+	atomic_t                vob_mmap_cnt;
 
 	/**
 	 * various flags
-	 * cob_discard_page_warned
+	 * vob_discard_page_warned
 	 *     if pages belonging to this object are discarded when a client
 	 * is evicted, some debug info will be printed, this flag will be set
 	 * during processing the first discarded page, then avoid flooding
@@ -229,7 +231,7 @@ struct ccc_object {
 	 *
 	 * \see ll_dirty_page_discard_warn.
 	 */
-	unsigned int		cob_discard_page_warned:1;
+	unsigned int		vob_discard_page_warned:1;
 };
 
 /**
@@ -242,8 +244,7 @@ struct ccc_page {
 	int		  cpg_write_queued;
 	/**
 	 * Non-empty iff this page is already counted in
-	 * ccc_object::cob_pending_list. Protected by
-	 * ccc_object::cob_pending_guard. This list is only used as a flag,
+	 * vvp_object::vob_pending_list. This list is only used as a flag,
 	 * that is, never iterated through, only checked for list_empty(), but
 	 * having a list is useful for debugging.
 	 */
@@ -287,27 +288,14 @@ void *ccc_session_key_init(const struct lu_context *ctx,
 void  ccc_session_key_fini(const struct lu_context *ctx,
 			   struct lu_context_key *key, void *data);
 
-struct lu_object *ccc_object_alloc(const struct lu_env *env,
-				   const struct lu_object_header *hdr,
-				   struct lu_device *dev,
-				   const struct cl_object_operations *clops,
-				   const struct lu_object_operations *luops);
-
 int ccc_req_init(const struct lu_env *env, struct cl_device *dev,
 		 struct cl_req *req);
 void ccc_umount(const struct lu_env *env, struct cl_device *dev);
 int ccc_global_init(struct lu_device_type *device_type);
 void ccc_global_fini(struct lu_device_type *device_type);
-int ccc_object_init0(const struct lu_env *env, struct ccc_object *vob,
-		     const struct cl_object_conf *conf);
-int ccc_object_init(const struct lu_env *env, struct lu_object *obj,
-		    const struct lu_object_conf *conf);
-void ccc_object_free(const struct lu_env *env, struct lu_object *obj);
 int ccc_lock_init(const struct lu_env *env, struct cl_object *obj,
 		  struct cl_lock *lock, const struct cl_io *io,
 		  const struct cl_lock_operations *lkops);
-int ccc_object_glimpse(const struct lu_env *env,
-		       const struct cl_object *obj, struct ost_lvb *lvb);
 int ccc_fail(const struct lu_env *env, const struct cl_page_slice *slice);
 int ccc_transient_page_prep(const struct lu_env *env,
 			    const struct cl_page_slice *slice,
@@ -354,20 +342,32 @@ static inline struct vvp_device *cl2vvp_dev(const struct cl_device *d)
 	return container_of0(d, struct vvp_device, vdv_cl);
 }
 
-struct lu_object *ccc2lu(struct ccc_object *vob);
-struct ccc_object *lu2ccc(const struct lu_object *obj);
-struct ccc_object *cl2ccc(const struct cl_object *obj);
+static inline struct vvp_object *cl2vvp(const struct cl_object *obj)
+{
+	return container_of0(obj, struct vvp_object, vob_cl);
+}
+
+static inline struct vvp_object *lu2vvp(const struct lu_object *obj)
+{
+	return container_of0(obj, struct vvp_object, vob_cl.co_lu);
+}
+
+static inline struct inode *vvp_object_inode(const struct cl_object *obj)
+{
+	return cl2vvp(obj)->vob_inode;
+}
+
+int vvp_object_invariant(const struct cl_object *obj);
+struct vvp_object *cl_inode2vvp(struct inode *inode);
+
 struct ccc_lock *cl2ccc_lock(const struct cl_lock_slice *slice);
 struct ccc_io *cl2ccc_io(const struct lu_env *env,
 			 const struct cl_io_slice *slice);
 struct ccc_req *cl2ccc_req(const struct cl_req_slice *slice);
 struct page *cl2vm_page(const struct cl_page_slice *slice);
-struct inode *ccc_object_inode(const struct cl_object *obj);
-struct ccc_object *cl_inode2ccc(struct inode *inode);
 
 int cl_setattr_ost(struct inode *inode, const struct iattr *attr);
 
-int ccc_object_invariant(const struct cl_object *obj);
 int cl_file_inode_init(struct inode *inode, struct lustre_md *md);
 void cl_inode_fini(struct inode *inode);
 int cl_local_size(struct inode *inode);
@@ -419,7 +419,6 @@ int vvp_page_init(const struct lu_env *env, struct cl_object *obj,
 struct lu_object *vvp_object_alloc(const struct lu_env *env,
 				   const struct lu_object_header *hdr,
 				   struct lu_device *dev);
-struct ccc_object *cl_inode2ccc(struct inode *inode);
 
 extern const struct file_operations vvp_dump_pgcache_file_ops;
 
diff --git a/drivers/staging/lustre/lustre/llite/vvp_io.c b/drivers/staging/lustre/lustre/llite/vvp_io.c
index fcf0cfe..1773cb2 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_io.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_io.c
@@ -127,7 +127,7 @@ static int vvp_io_fault_iter_init(const struct lu_env *env,
 				  const struct cl_io_slice *ios)
 {
 	struct vvp_io *vio   = cl2vvp_io(env, ios);
-	struct inode  *inode = ccc_object_inode(ios->cis_obj);
+	struct inode  *inode = vvp_object_inode(ios->cis_obj);
 
 	LASSERT(inode ==
 		file_inode(cl2ccc_io(env, ios)->cui_fd->fd_file));
@@ -141,7 +141,7 @@ static void vvp_io_fini(const struct lu_env *env, const struct cl_io_slice *ios)
 	struct cl_object *obj = io->ci_obj;
 	struct ccc_io    *cio = cl2ccc_io(env, ios);
 
-	CLOBINVRNT(env, obj, ccc_object_invariant(obj));
+	CLOBINVRNT(env, obj, vvp_object_invariant(obj));
 
 	CDEBUG(D_VFSTRACE, DFID
 	       " ignore/verify layout %d/%d, layout version %d restore needed %d\n",
@@ -155,7 +155,7 @@ static void vvp_io_fini(const struct lu_env *env, const struct cl_io_slice *ios)
 		/* file was detected release, we need to restore it
 		 * before finishing the io
 		 */
-		rc = ll_layout_restore(ccc_object_inode(obj));
+		rc = ll_layout_restore(vvp_object_inode(obj));
 		/* if restore registration failed, no restart,
 		 * we will return -ENODATA
 		 */
@@ -181,7 +181,7 @@ static void vvp_io_fini(const struct lu_env *env, const struct cl_io_slice *ios)
 		__u32 gen = 0;
 
 		/* check layout version */
-		ll_layout_refresh(ccc_object_inode(obj), &gen);
+		ll_layout_refresh(vvp_object_inode(obj), &gen);
 		io->ci_need_restart = cio->cui_layout_gen != gen;
 		if (io->ci_need_restart) {
 			CDEBUG(D_VFSTRACE,
@@ -190,7 +190,7 @@ static void vvp_io_fini(const struct lu_env *env, const struct cl_io_slice *ios)
 			       cio->cui_layout_gen, gen);
 			/* today successful restore is the only possible case */
 			/* restore was done, clear restoring state */
-			ll_i2info(ccc_object_inode(obj))->lli_flags &=
+			ll_i2info(vvp_object_inode(obj))->lli_flags &=
 				~LLIF_FILE_RESTORING;
 		}
 	}
@@ -202,7 +202,7 @@ static void vvp_io_fault_fini(const struct lu_env *env,
 	struct cl_io   *io   = ios->cis_io;
 	struct cl_page *page = io->u.ci_fault.ft_page;
 
-	CLOBINVRNT(env, io->ci_obj, ccc_object_invariant(io->ci_obj));
+	CLOBINVRNT(env, io->ci_obj, vvp_object_invariant(io->ci_obj));
 
 	if (page) {
 		lu_ref_del(&page->cp_reference, "fault", io);
@@ -459,7 +459,7 @@ static int vvp_io_setattr_start(const struct lu_env *env,
 				const struct cl_io_slice *ios)
 {
 	struct cl_io	*io    = ios->cis_io;
-	struct inode	*inode = ccc_object_inode(io->ci_obj);
+	struct inode	*inode = vvp_object_inode(io->ci_obj);
 	int result = 0;
 
 	inode_lock(inode);
@@ -475,7 +475,7 @@ static void vvp_io_setattr_end(const struct lu_env *env,
 			       const struct cl_io_slice *ios)
 {
 	struct cl_io *io    = ios->cis_io;
-	struct inode *inode = ccc_object_inode(io->ci_obj);
+	struct inode *inode = vvp_object_inode(io->ci_obj);
 
 	if (cl_io_is_trunc(io))
 		/* Truncate in memory pages - they must be clean pages
@@ -499,7 +499,7 @@ static int vvp_io_read_start(const struct lu_env *env,
 	struct ccc_io     *cio   = cl2ccc_io(env, ios);
 	struct cl_io      *io    = ios->cis_io;
 	struct cl_object  *obj   = io->ci_obj;
-	struct inode      *inode = ccc_object_inode(obj);
+	struct inode      *inode = vvp_object_inode(obj);
 	struct ll_ra_read *bead  = &vio->cui_bead;
 	struct file       *file  = cio->cui_fd->fd_file;
 
@@ -509,7 +509,7 @@ static int vvp_io_read_start(const struct lu_env *env,
 	long    tot = cio->cui_tot_count;
 	int     exceed = 0;
 
-	CLOBINVRNT(env, obj, ccc_object_invariant(obj));
+	CLOBINVRNT(env, obj, vvp_object_invariant(obj));
 
 	CDEBUG(D_VFSTRACE, "read: -> [%lli, %lli)\n", pos, pos + cnt);
 
@@ -653,7 +653,7 @@ static void write_commit_callback(const struct lu_env *env, struct cl_io *io,
 	set_page_dirty(vmpage);
 
 	cp = cl2ccc_page(cl_object_page_slice(clob, page));
-	vvp_write_pending(cl2ccc(clob), cp);
+	vvp_write_pending(cl2vvp(clob), cp);
 
 	cl_page_disown(env, io, page);
 
@@ -690,7 +690,7 @@ static bool page_list_sanity_check(struct cl_object *obj,
 int vvp_io_write_commit(const struct lu_env *env, struct cl_io *io)
 {
 	struct cl_object *obj = io->ci_obj;
-	struct inode *inode = ccc_object_inode(obj);
+	struct inode *inode = vvp_object_inode(obj);
 	struct ccc_io *cio = ccc_env_io(env);
 	struct cl_page_list *queue = &cio->u.write.cui_queue;
 	struct cl_page *page;
@@ -773,7 +773,7 @@ static int vvp_io_write_start(const struct lu_env *env,
 	struct ccc_io      *cio   = cl2ccc_io(env, ios);
 	struct cl_io       *io    = ios->cis_io;
 	struct cl_object   *obj   = io->ci_obj;
-	struct inode       *inode = ccc_object_inode(obj);
+	struct inode       *inode = vvp_object_inode(obj);
 	ssize_t result = 0;
 	loff_t pos = io->u.ci_wr.wr.crw_pos;
 	size_t cnt = io->u.ci_wr.wr.crw_count;
@@ -874,7 +874,7 @@ static void mkwrite_commit_callback(const struct lu_env *env, struct cl_io *io,
 	set_page_dirty(page->cp_vmpage);
 
 	cp = cl2ccc_page(cl_object_page_slice(clob, page));
-	vvp_write_pending(cl2ccc(clob), cp);
+	vvp_write_pending(cl2vvp(clob), cp);
 }
 
 static int vvp_io_fault_start(const struct lu_env *env,
@@ -883,7 +883,7 @@ static int vvp_io_fault_start(const struct lu_env *env,
 	struct vvp_io       *vio     = cl2vvp_io(env, ios);
 	struct cl_io	*io      = ios->cis_io;
 	struct cl_object    *obj     = io->ci_obj;
-	struct inode	*inode   = ccc_object_inode(obj);
+	struct inode        *inode   = vvp_object_inode(obj);
 	struct cl_fault_io  *fio     = &io->u.ci_fault;
 	struct vvp_fault_io *cfio    = &vio->u.fault;
 	loff_t	       offset;
@@ -1060,7 +1060,7 @@ static int vvp_io_read_page(const struct lu_env *env,
 	struct cl_io	      *io     = ios->cis_io;
 	struct ccc_page	   *cp     = cl2ccc_page(slice);
 	struct cl_page	    *page   = slice->cpl_page;
-	struct inode	      *inode  = ccc_object_inode(slice->cpl_obj);
+	struct inode              *inode  = vvp_object_inode(slice->cpl_obj);
 	struct ll_sb_info	 *sbi    = ll_i2sbi(inode);
 	struct ll_file_data       *fd     = cl2ccc_io(env, ios)->cui_fd;
 	struct ll_readahead_state *ras    = &fd->fd_ras;
@@ -1135,10 +1135,10 @@ int vvp_io_init(const struct lu_env *env, struct cl_object *obj,
 {
 	struct vvp_io      *vio   = vvp_env_io(env);
 	struct ccc_io      *cio   = ccc_env_io(env);
-	struct inode       *inode = ccc_object_inode(obj);
+	struct inode       *inode = vvp_object_inode(obj);
 	int		 result;
 
-	CLOBINVRNT(env, obj, ccc_object_invariant(obj));
+	CLOBINVRNT(env, obj, vvp_object_invariant(obj));
 
 	CDEBUG(D_VFSTRACE, DFID
 	       " ignore/verify layout %d/%d, layout version %d restore needed %d\n",
diff --git a/drivers/staging/lustre/lustre/llite/vvp_object.c b/drivers/staging/lustre/lustre/llite/vvp_object.c
index 45fac69..9f5e6a6 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_object.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_object.c
@@ -54,16 +54,25 @@
  *
  */
 
+int vvp_object_invariant(const struct cl_object *obj)
+{
+	struct inode *inode  = vvp_object_inode(obj);
+	struct ll_inode_info *lli = ll_i2info(inode);
+
+	return (S_ISREG(inode->i_mode) || inode->i_mode == 0) &&
+		lli->lli_clob == obj;
+}
+
 static int vvp_object_print(const struct lu_env *env, void *cookie,
 			    lu_printer_t p, const struct lu_object *o)
 {
-	struct ccc_object    *obj   = lu2ccc(o);
-	struct inode	 *inode = obj->cob_inode;
+	struct vvp_object    *obj   = lu2vvp(o);
+	struct inode	 *inode = obj->vob_inode;
 	struct ll_inode_info *lli;
 
 	(*p)(env, cookie, "(%s %d %d) inode: %p ",
-	     list_empty(&obj->cob_pending_list) ? "-" : "+",
-	     obj->cob_transient_pages, atomic_read(&obj->cob_mmap_cnt),
+	     list_empty(&obj->vob_pending_list) ? "-" : "+",
+	     obj->vob_transient_pages, atomic_read(&obj->vob_mmap_cnt),
 	     inode);
 	if (inode) {
 		lli = ll_i2info(inode);
@@ -78,7 +87,7 @@ static int vvp_object_print(const struct lu_env *env, void *cookie,
 static int vvp_attr_get(const struct lu_env *env, struct cl_object *obj,
 			struct cl_attr *attr)
 {
-	struct inode *inode = ccc_object_inode(obj);
+	struct inode *inode = vvp_object_inode(obj);
 
 	/*
 	 * lov overwrites most of these fields in
@@ -100,7 +109,7 @@ static int vvp_attr_get(const struct lu_env *env, struct cl_object *obj,
 static int vvp_attr_set(const struct lu_env *env, struct cl_object *obj,
 			const struct cl_attr *attr, unsigned valid)
 {
-	struct inode *inode = ccc_object_inode(obj);
+	struct inode *inode = vvp_object_inode(obj);
 
 	if (valid & CAT_UID)
 		inode->i_uid = make_kuid(&init_user_ns, attr->cat_uid);
@@ -168,7 +177,7 @@ static int vvp_conf_set(const struct lu_env *env, struct cl_object *obj,
 
 static int vvp_prune(const struct lu_env *env, struct cl_object *obj)
 {
-	struct inode *inode = ccc_object_inode(obj);
+	struct inode *inode = vvp_object_inode(obj);
 	int rc;
 
 	rc = cl_sync_file_range(inode, 0, OBD_OBJECT_EOF, CL_FSYNC_LOCAL, 1);
@@ -182,6 +191,24 @@ static int vvp_prune(const struct lu_env *env, struct cl_object *obj)
 	return 0;
 }
 
+static int vvp_object_glimpse(const struct lu_env *env,
+			      const struct cl_object *obj, struct ost_lvb *lvb)
+{
+	struct inode *inode = vvp_object_inode(obj);
+
+	lvb->lvb_mtime = LTIME_S(inode->i_mtime);
+	lvb->lvb_atime = LTIME_S(inode->i_atime);
+	lvb->lvb_ctime = LTIME_S(inode->i_ctime);
+	/*
+	 * LU-417: Add dirty pages block count lest i_blocks reports 0, some
+	 * "cp" or "tar" on remote node may think it's a completely sparse file
+	 * and skip it.
+	 */
+	if (lvb->lvb_size > 0 && lvb->lvb_blocks == 0)
+		lvb->lvb_blocks = dirty_cnt(inode);
+	return 0;
+}
+
 static const struct cl_object_operations vvp_ops = {
 	.coo_page_init = vvp_page_init,
 	.coo_lock_init = vvp_lock_init,
@@ -190,16 +217,60 @@ static const struct cl_object_operations vvp_ops = {
 	.coo_attr_set  = vvp_attr_set,
 	.coo_conf_set  = vvp_conf_set,
 	.coo_prune     = vvp_prune,
-	.coo_glimpse   = ccc_object_glimpse
+	.coo_glimpse   = vvp_object_glimpse
 };
 
+static int vvp_object_init0(const struct lu_env *env,
+			    struct vvp_object *vob,
+			    const struct cl_object_conf *conf)
+{
+	vob->vob_inode = conf->coc_inode;
+	vob->vob_transient_pages = 0;
+	cl_object_page_init(&vob->vob_cl, sizeof(struct ccc_page));
+	return 0;
+}
+
+static int vvp_object_init(const struct lu_env *env, struct lu_object *obj,
+			   const struct lu_object_conf *conf)
+{
+	struct vvp_device *dev = lu2vvp_dev(obj->lo_dev);
+	struct vvp_object *vob = lu2vvp(obj);
+	struct lu_object  *below;
+	struct lu_device  *under;
+	int result;
+
+	under = &dev->vdv_next->cd_lu_dev;
+	below = under->ld_ops->ldo_object_alloc(env, obj->lo_header, under);
+	if (below) {
+		const struct cl_object_conf *cconf;
+
+		cconf = lu2cl_conf(conf);
+		INIT_LIST_HEAD(&vob->vob_pending_list);
+		lu_object_add(obj, below);
+		result = vvp_object_init0(env, vob, cconf);
+	} else {
+		result = -ENOMEM;
+	}
+
+	return result;
+}
+
+static void vvp_object_free(const struct lu_env *env, struct lu_object *obj)
+{
+	struct vvp_object *vob = lu2vvp(obj);
+
+	lu_object_fini(obj);
+	lu_object_header_fini(obj->lo_header);
+	kmem_cache_free(vvp_object_kmem, vob);
+}
+
 static const struct lu_object_operations vvp_lu_obj_ops = {
-	.loo_object_init  = ccc_object_init,
-	.loo_object_free  = ccc_object_free,
-	.loo_object_print = vvp_object_print
+	.loo_object_init	= vvp_object_init,
+	.loo_object_free	= vvp_object_free,
+	.loo_object_print	= vvp_object_print,
 };
 
-struct ccc_object *cl_inode2ccc(struct inode *inode)
+struct vvp_object *cl_inode2vvp(struct inode *inode)
 {
 	struct ll_inode_info *lli = ll_i2info(inode);
 	struct cl_object     *obj = lli->lli_clob;
@@ -207,12 +278,32 @@ struct ccc_object *cl_inode2ccc(struct inode *inode)
 
 	lu = lu_object_locate(obj->co_lu.lo_header, &vvp_device_type);
 	LASSERT(lu);
-	return lu2ccc(lu);
+	return lu2vvp(lu);
 }
 
 struct lu_object *vvp_object_alloc(const struct lu_env *env,
-				   const struct lu_object_header *hdr,
+				   const struct lu_object_header *unused,
 				   struct lu_device *dev)
 {
-	return ccc_object_alloc(env, hdr, dev, &vvp_ops, &vvp_lu_obj_ops);
+	struct vvp_object *vob;
+	struct lu_object  *obj;
+
+	vob = kmem_cache_zalloc(vvp_object_kmem, GFP_NOFS);
+	if (vob) {
+		struct cl_object_header *hdr;
+
+		obj = &vob->vob_cl.co_lu;
+		hdr = &vob->vob_header;
+		cl_object_header_init(hdr);
+		hdr->coh_page_bufsize = cfs_size_round(sizeof(struct cl_page));
+
+		lu_object_init(obj, &hdr->coh_lu, dev);
+		lu_object_add_top(&hdr->coh_lu, obj);
+
+		vob->vob_cl.co_ops = &vvp_ops;
+		obj->lo_ops = &vvp_lu_obj_ops;
+	} else {
+		obj = NULL;
+	}
+	return obj;
 }
diff --git a/drivers/staging/lustre/lustre/llite/vvp_page.c b/drivers/staging/lustre/lustre/llite/vvp_page.c
index 66a4f9b..419a535 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_page.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_page.c
@@ -159,9 +159,9 @@ static void vvp_page_delete(const struct lu_env *env,
 
 	LASSERT(PageLocked(vmpage));
 	LASSERT((struct cl_page *)vmpage->private == page);
-	LASSERT(inode == ccc_object_inode(obj));
+	LASSERT(inode == vvp_object_inode(obj));
 
-	vvp_write_complete(cl2ccc(obj), cl2ccc_page(slice));
+	vvp_write_complete(cl2vvp(obj), cl2ccc_page(slice));
 
 	/* Drop the reference count held in vvp_page_init */
 	refc = atomic_dec_return(&page->cp_ref);
@@ -220,7 +220,7 @@ static int vvp_page_prep_write(const struct lu_env *env,
 	if (!pg->cp_sync_io)
 		set_page_writeback(vmpage);
 
-	vvp_write_pending(cl2ccc(slice->cpl_obj), cl2ccc_page(slice));
+	vvp_write_pending(cl2vvp(slice->cpl_obj), cl2ccc_page(slice));
 
 	return 0;
 }
@@ -233,11 +233,11 @@ static int vvp_page_prep_write(const struct lu_env *env,
  */
 static void vvp_vmpage_error(struct inode *inode, struct page *vmpage, int ioret)
 {
-	struct ccc_object *obj = cl_inode2ccc(inode);
+	struct vvp_object *obj = cl_inode2vvp(inode);
 
 	if (ioret == 0) {
 		ClearPageError(vmpage);
-		obj->cob_discard_page_warned = 0;
+		obj->vob_discard_page_warned = 0;
 	} else {
 		SetPageError(vmpage);
 		if (ioret == -ENOSPC)
@@ -246,8 +246,8 @@ static void vvp_vmpage_error(struct inode *inode, struct page *vmpage, int ioret
 			set_bit(AS_EIO, &inode->i_mapping->flags);
 
 		if ((ioret == -ESHUTDOWN || ioret == -EINTR) &&
-		    obj->cob_discard_page_warned == 0) {
-			obj->cob_discard_page_warned = 1;
+		     obj->vob_discard_page_warned == 0) {
+			obj->vob_discard_page_warned = 1;
 			ll_dirty_page_discard_warn(vmpage, ioret);
 		}
 	}
@@ -260,7 +260,7 @@ static void vvp_page_completion_read(const struct lu_env *env,
 	struct ccc_page *cp     = cl2ccc_page(slice);
 	struct page      *vmpage = cp->cpg_page;
 	struct cl_page  *page   = slice->cpl_page;
-	struct inode    *inode  = ccc_object_inode(page->cp_obj);
+	struct inode    *inode  = vvp_object_inode(page->cp_obj);
 
 	LASSERT(PageLocked(vmpage));
 	CL_PAGE_HEADER(D_PAGE, env, page, "completing READ with %d\n", ioret);
@@ -299,7 +299,7 @@ static void vvp_page_completion_write(const struct lu_env *env,
 	 */
 
 	cp->cpg_write_queued = 0;
-	vvp_write_complete(cl2ccc(slice->cpl_obj), cp);
+	vvp_write_complete(cl2vvp(slice->cpl_obj), cp);
 
 	if (pg->cp_sync_io) {
 		LASSERT(PageLocked(vmpage));
@@ -310,7 +310,7 @@ static void vvp_page_completion_write(const struct lu_env *env,
 		 * Only mark the page error only when it's an async write
 		 * because applications won't wait for IO to finish.
 		 */
-		vvp_vmpage_error(ccc_object_inode(pg->cp_obj), vmpage, ioret);
+		vvp_vmpage_error(vvp_object_inode(pg->cp_obj), vmpage, ioret);
 
 		end_page_writeback(vmpage);
 	}
@@ -342,7 +342,7 @@ static int vvp_page_make_ready(const struct lu_env *env,
 		LASSERT(pg->cp_state == CPS_CACHED);
 		/* This actually clears the dirty bit in the radix tree. */
 		set_page_writeback(vmpage);
-		vvp_write_pending(cl2ccc(slice->cpl_obj), cl2ccc_page(slice));
+		vvp_write_pending(cl2vvp(slice->cpl_obj), cl2ccc_page(slice));
 		CL_PAGE_HEADER(D_PAGE, env, pg, "readied\n");
 	} else if (pg->cp_state == CPS_PAGEOUT) {
 		/* is it possible for osc_flush_async_page() to already
@@ -421,7 +421,7 @@ static const struct cl_page_operations vvp_page_ops = {
 
 static void vvp_transient_page_verify(const struct cl_page *page)
 {
-	struct inode *inode = ccc_object_inode(page->cp_obj);
+	struct inode *inode = vvp_object_inode(page->cp_obj);
 
 	LASSERT(!inode_trylock(inode));
 }
@@ -472,7 +472,7 @@ static void vvp_transient_page_discard(const struct lu_env *env,
 static int vvp_transient_page_is_vmlocked(const struct lu_env *env,
 					  const struct cl_page_slice *slice)
 {
-	struct inode    *inode = ccc_object_inode(slice->cpl_obj);
+	struct inode    *inode = vvp_object_inode(slice->cpl_obj);
 	int	locked;
 
 	locked = !inode_trylock(inode);
@@ -494,11 +494,11 @@ static void vvp_transient_page_fini(const struct lu_env *env,
 {
 	struct ccc_page *cp = cl2ccc_page(slice);
 	struct cl_page *clp = slice->cpl_page;
-	struct ccc_object *clobj = cl2ccc(clp->cp_obj);
+	struct vvp_object *clobj = cl2vvp(clp->cp_obj);
 
 	vvp_page_fini_common(cp);
-	LASSERT(!inode_trylock(clobj->cob_inode));
-	clobj->cob_transient_pages--;
+	LASSERT(!inode_trylock(clobj->vob_inode));
+	clobj->vob_transient_pages--;
 }
 
 static const struct cl_page_operations vvp_transient_page_ops = {
@@ -529,7 +529,7 @@ int vvp_page_init(const struct lu_env *env, struct cl_object *obj,
 	struct ccc_page *cpg = cl_object_page_slice(obj, page);
 	struct page     *vmpage = page->cp_vmpage;
 
-	CLOBINVRNT(env, obj, ccc_object_invariant(obj));
+	CLOBINVRNT(env, obj, vvp_object_invariant(obj));
 
 	cpg->cpg_page = vmpage;
 	page_cache_get(vmpage);
@@ -543,12 +543,12 @@ int vvp_page_init(const struct lu_env *env, struct cl_object *obj,
 		cl_page_slice_add(page, &cpg->cpg_cl, obj, index,
 				  &vvp_page_ops);
 	} else {
-		struct ccc_object *clobj = cl2ccc(obj);
+		struct vvp_object *clobj = cl2vvp(obj);
 
-		LASSERT(!inode_trylock(clobj->cob_inode));
+		LASSERT(!inode_trylock(clobj->vob_inode));
 		cl_page_slice_add(page, &cpg->cpg_cl, obj, index,
 				  &vvp_transient_page_ops);
-		clobj->cob_transient_pages++;
+		clobj->vob_transient_pages++;
 	}
 	return 0;
 }
diff --git a/drivers/staging/lustre/lustre/osc/osc_cl_internal.h b/drivers/staging/lustre/lustre/osc/osc_cl_internal.h
index d6d7661..aba6469 100644
--- a/drivers/staging/lustre/lustre/osc/osc_cl_internal.h
+++ b/drivers/staging/lustre/lustre/osc/osc_cl_internal.h
@@ -135,7 +135,7 @@ struct osc_object {
 	 */
 	struct list_head	 oo_inflight[CRT_NR];
 	/**
-	 * Lock, protecting ccc_object::cob_inflight, because a seat-belt is
+	 * Lock, protecting osc_page::ops_inflight, because a seat-belt is
 	 * locked during take-off and landing.
 	 */
 	spinlock_t	   oo_seatbelt;
-- 
2.1.0
