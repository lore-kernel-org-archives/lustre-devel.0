From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Wed, 30 Mar 2016 12:47:59 -0400
Subject: [lustre-devel] [PATCH 27/43] staging/lustre/llite: rename ccc_page
	to vvp_page
In-Reply-To: <1459356495-2794775-1-git-send-email-green@linuxhacker.ru>
References: <1459356495-2794775-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1459356495-2794775-28-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, "John L. Hammond" <john.hammond@intel.com>, Oleg Drokin <green@linuxhacker.ru>

From: "John L. Hammond" <john.hammond@intel.com>

Rename struct ccc_page to struct vvp_page and remove obsolete CCC page
methods.

Signed-off-by: John L. Hammond <john.hammond@intel.com>
Reviewed-on: http://review.whamcloud.com/13086
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5971
Reviewed-by: James Simmons <uja.ornl@gmail.com>
Reviewed-by: Jinshan Xiong <jinshan.xiong@intel.com>
Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/include/cl_object.h  |   2 +-
 drivers/staging/lustre/lustre/llite/lcommon_cl.c   |  28 ------
 drivers/staging/lustre/lustre/llite/llite_close.c  |  12 +--
 .../staging/lustre/lustre/llite/llite_internal.h   |   4 +-
 drivers/staging/lustre/lustre/llite/rw.c           |  14 +--
 drivers/staging/lustre/lustre/llite/rw26.c         |  10 +-
 drivers/staging/lustre/lustre/llite/vvp_dev.c      |  12 +--
 drivers/staging/lustre/lustre/llite/vvp_internal.h |  38 ++++----
 drivers/staging/lustre/lustre/llite/vvp_io.c       |  34 +++----
 drivers/staging/lustre/lustre/llite/vvp_object.c   |   2 +-
 drivers/staging/lustre/lustre/llite/vvp_page.c     | 107 +++++++++++++--------
 11 files changed, 131 insertions(+), 132 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/cl_object.h b/drivers/staging/lustre/lustre/include/cl_object.h
index d3271ff..3488349 100644
--- a/drivers/staging/lustre/lustre/include/cl_object.h
+++ b/drivers/staging/lustre/lustre/include/cl_object.h
@@ -769,7 +769,7 @@ struct cl_page {
 /**
  * Per-layer part of cl_page.
  *
- * \see ccc_page, lov_page, osc_page
+ * \see vvp_page, lov_page, osc_page
  */
 struct cl_page_slice {
 	struct cl_page		  *cpl_page;
diff --git a/drivers/staging/lustre/lustre/llite/lcommon_cl.c b/drivers/staging/lustre/lustre/llite/lcommon_cl.c
index 9db0510..0762032 100644
--- a/drivers/staging/lustre/lustre/llite/lcommon_cl.c
+++ b/drivers/staging/lustre/lustre/llite/lcommon_cl.c
@@ -259,29 +259,6 @@ static void vvp_object_size_unlock(struct cl_object *obj)
 
 /*****************************************************************************
  *
- * Page operations.
- *
- */
-
-int ccc_fail(const struct lu_env *env, const struct cl_page_slice *slice)
-{
-	/*
-	 * Cached read?
-	 */
-	LBUG();
-	return 0;
-}
-
-int ccc_transient_page_prep(const struct lu_env *env,
-			    const struct cl_page_slice *slice,
-			    struct cl_io *unused)
-{
-	/* transient page should always be sent. */
-	return 0;
-}
-
-/*****************************************************************************
- *
  * Lock operations.
  *
  */
@@ -614,11 +591,6 @@ struct ccc_req *cl2ccc_req(const struct cl_req_slice *slice)
 	return container_of0(slice, struct ccc_req, crq_cl);
 }
 
-struct page *cl2vm_page(const struct cl_page_slice *slice)
-{
-	return cl2ccc_page(slice)->cpg_page;
-}
-
 /**
  * Initialize or update CLIO structures for regular files when new
  * meta-data arrives from the server.
diff --git a/drivers/staging/lustre/lustre/llite/llite_close.c b/drivers/staging/lustre/lustre/llite/llite_close.c
index 6e99d34..8d23980 100644
--- a/drivers/staging/lustre/lustre/llite/llite_close.c
+++ b/drivers/staging/lustre/lustre/llite/llite_close.c
@@ -46,26 +46,26 @@
 #include "llite_internal.h"
 
 /** records that a write is in flight */
-void vvp_write_pending(struct vvp_object *club, struct ccc_page *page)
+void vvp_write_pending(struct vvp_object *club, struct vvp_page *page)
 {
 	struct ll_inode_info *lli = ll_i2info(club->vob_inode);
 
 	spin_lock(&lli->lli_lock);
 	lli->lli_flags |= LLIF_SOM_DIRTY;
-	if (page && list_empty(&page->cpg_pending_linkage))
-		list_add(&page->cpg_pending_linkage, &club->vob_pending_list);
+	if (page && list_empty(&page->vpg_pending_linkage))
+		list_add(&page->vpg_pending_linkage, &club->vob_pending_list);
 	spin_unlock(&lli->lli_lock);
 }
 
 /** records that a write has completed */
-void vvp_write_complete(struct vvp_object *club, struct ccc_page *page)
+void vvp_write_complete(struct vvp_object *club, struct vvp_page *page)
 {
 	struct ll_inode_info *lli = ll_i2info(club->vob_inode);
 	int rc = 0;
 
 	spin_lock(&lli->lli_lock);
-	if (page && !list_empty(&page->cpg_pending_linkage)) {
-		list_del_init(&page->cpg_pending_linkage);
+	if (page && !list_empty(&page->vpg_pending_linkage)) {
+		list_del_init(&page->vpg_pending_linkage);
 		rc = 1;
 	}
 	spin_unlock(&lli->lli_lock);
diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
index 1c39d15..78b3edd 100644
--- a/drivers/staging/lustre/lustre/llite/llite_internal.h
+++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
@@ -828,8 +828,8 @@ struct ll_close_queue {
 	atomic_t		lcq_stop;
 };
 
-void vvp_write_pending(struct vvp_object *club, struct ccc_page *page);
-void vvp_write_complete(struct vvp_object *club, struct ccc_page *page);
+void vvp_write_pending(struct vvp_object *club, struct vvp_page *page);
+void vvp_write_complete(struct vvp_object *club, struct vvp_page *page);
 
 /* specific architecture can implement only part of this list */
 enum vvp_io_subtype {
diff --git a/drivers/staging/lustre/lustre/llite/rw.c b/drivers/staging/lustre/lustre/llite/rw.c
index 5ae0993..2c4d4c4 100644
--- a/drivers/staging/lustre/lustre/llite/rw.c
+++ b/drivers/staging/lustre/lustre/llite/rw.c
@@ -298,21 +298,21 @@ static int cl_read_ahead_page(const struct lu_env *env, struct cl_io *io,
 			      struct cl_object *clob, pgoff_t *max_index)
 {
 	struct page *vmpage = page->cp_vmpage;
-	struct ccc_page *cp;
+	struct vvp_page *vpg;
 	int	      rc;
 
 	rc = 0;
 	cl_page_assume(env, io, page);
 	lu_ref_add(&page->cp_reference, "ra", current);
-	cp = cl2ccc_page(cl_object_page_slice(clob, page));
-	if (!cp->cpg_defer_uptodate && !PageUptodate(vmpage)) {
+	vpg = cl2vvp_page(cl_object_page_slice(clob, page));
+	if (!vpg->vpg_defer_uptodate && !PageUptodate(vmpage)) {
 		CDEBUG(D_READA, "page index %lu, max_index: %lu\n",
-		       ccc_index(cp), *max_index);
-		if (*max_index == 0 || ccc_index(cp) > *max_index)
+		       vvp_index(vpg), *max_index);
+		if (*max_index == 0 || vvp_index(vpg) > *max_index)
 			rc = cl_page_is_under_lock(env, io, page, max_index);
 		if (rc == 0) {
-			cp->cpg_defer_uptodate = 1;
-			cp->cpg_ra_used = 0;
+			vpg->vpg_defer_uptodate = 1;
+			vpg->vpg_ra_used = 0;
 			cl_page_list_add(queue, page);
 			rc = 1;
 		} else {
diff --git a/drivers/staging/lustre/lustre/llite/rw26.c b/drivers/staging/lustre/lustre/llite/rw26.c
index ec114bc..bb85629 100644
--- a/drivers/staging/lustre/lustre/llite/rw26.c
+++ b/drivers/staging/lustre/lustre/llite/rw26.c
@@ -457,8 +457,8 @@ static int ll_prepare_partial_page(const struct lu_env *env, struct cl_io *io,
 {
 	struct cl_attr *attr   = ccc_env_thread_attr(env);
 	struct cl_object *obj  = io->ci_obj;
-	struct ccc_page *cp    = cl_object_page_slice(obj, pg);
-	loff_t          offset = cl_offset(obj, ccc_index(cp));
+	struct vvp_page *vpg   = cl_object_page_slice(obj, pg);
+	loff_t          offset = cl_offset(obj, vvp_index(vpg));
 	int             result;
 
 	cl_object_attr_lock(obj);
@@ -471,12 +471,12 @@ static int ll_prepare_partial_page(const struct lu_env *env, struct cl_io *io,
 		 * purposes here we can treat it like i_size.
 		 */
 		if (attr->cat_kms <= offset) {
-			char *kaddr = kmap_atomic(cp->cpg_page);
+			char *kaddr = kmap_atomic(vpg->vpg_page);
 
 			memset(kaddr, 0, cl_page_size(obj));
 			kunmap_atomic(kaddr);
-		} else if (cp->cpg_defer_uptodate) {
-			cp->cpg_ra_used = 1;
+		} else if (vpg->vpg_defer_uptodate) {
+			vpg->vpg_ra_used = 1;
 		} else {
 			result = ll_page_sync_io(env, io, pg, CRT_READ);
 		}
diff --git a/drivers/staging/lustre/lustre/llite/vvp_dev.c b/drivers/staging/lustre/lustre/llite/vvp_dev.c
index 45c549c..3891b0d 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_dev.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_dev.c
@@ -474,18 +474,18 @@ static loff_t vvp_pgcache_find(const struct lu_env *env,
 static void vvp_pgcache_page_show(const struct lu_env *env,
 				  struct seq_file *seq, struct cl_page *page)
 {
-	struct ccc_page *cpg;
+	struct vvp_page *vpg;
 	struct page      *vmpage;
 	int	      has_flags;
 
-	cpg = cl2ccc_page(cl_page_at(page, &vvp_device_type));
-	vmpage = cpg->cpg_page;
+	vpg = cl2vvp_page(cl_page_at(page, &vvp_device_type));
+	vmpage = vpg->vpg_page;
 	seq_printf(seq, " %5i | %p %p %s %s %s %s | %p %lu/%u(%p) %lu %u [",
 		   0 /* gen */,
-		   cpg, page,
+		   vpg, page,
 		   "none",
-		   cpg->cpg_write_queued ? "wq" : "- ",
-		   cpg->cpg_defer_uptodate ? "du" : "- ",
+		   vpg->vpg_write_queued ? "wq" : "- ",
+		   vpg->vpg_defer_uptodate ? "du" : "- ",
 		   PageWriteback(vmpage) ? "wb" : "-",
 		   vmpage, vmpage->mapping->host->i_ino,
 		   vmpage->mapping->host->i_generation,
diff --git a/drivers/staging/lustre/lustre/llite/vvp_internal.h b/drivers/staging/lustre/lustre/llite/vvp_internal.h
index 76e7b4c..4991ce7 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_internal.h
+++ b/drivers/staging/lustre/lustre/llite/vvp_internal.h
@@ -204,7 +204,7 @@ struct vvp_object {
 	 * A list of dirty pages pending IO in the cache. Used by
 	 * SOM. Protected by ll_inode_info::lli_lock.
 	 *
-	 * \see ccc_page::cpg_pending_linkage
+	 * \see vvp_page::vpg_pending_linkage
 	 */
 	struct list_head	vob_pending_list;
 
@@ -235,36 +235,34 @@ struct vvp_object {
 };
 
 /**
- * ccc-private page state.
+ * VVP-private page state.
  */
-struct ccc_page {
-	struct cl_page_slice cpg_cl;
-	int		  cpg_defer_uptodate;
-	int		  cpg_ra_used;
-	int		  cpg_write_queued;
+struct vvp_page {
+	struct cl_page_slice vpg_cl;
+	int		  vpg_defer_uptodate;
+	int		  vpg_ra_used;
+	int		  vpg_write_queued;
 	/**
 	 * Non-empty iff this page is already counted in
 	 * vvp_object::vob_pending_list. This list is only used as a flag,
 	 * that is, never iterated through, only checked for list_empty(), but
 	 * having a list is useful for debugging.
 	 */
-	struct list_head	   cpg_pending_linkage;
+	struct list_head	   vpg_pending_linkage;
 	/** VM page */
-	struct page	  *cpg_page;
+	struct page	  *vpg_page;
 };
 
-static inline struct ccc_page *cl2ccc_page(const struct cl_page_slice *slice)
+static inline struct vvp_page *cl2vvp_page(const struct cl_page_slice *slice)
 {
-	return container_of(slice, struct ccc_page, cpg_cl);
+	return container_of(slice, struct vvp_page, vpg_cl);
 }
 
-static inline pgoff_t ccc_index(struct ccc_page *ccc)
+static inline pgoff_t vvp_index(struct vvp_page *vvp)
 {
-	return ccc->cpg_cl.cpl_index;
+	return vvp->vpg_cl.cpl_index;
 }
 
-struct cl_page *ccc_vmpage_page_transient(struct page *vmpage);
-
 struct vvp_device {
 	struct cl_device    vdv_cl;
 	struct super_block *vdv_sb;
@@ -296,10 +294,6 @@ void ccc_global_fini(struct lu_device_type *device_type);
 int ccc_lock_init(const struct lu_env *env, struct cl_object *obj,
 		  struct cl_lock *lock, const struct cl_io *io,
 		  const struct cl_lock_operations *lkops);
-int ccc_fail(const struct lu_env *env, const struct cl_page_slice *slice);
-int ccc_transient_page_prep(const struct lu_env *env,
-			    const struct cl_page_slice *slice,
-			    struct cl_io *io);
 void ccc_lock_delete(const struct lu_env *env,
 		     const struct cl_lock_slice *slice);
 void ccc_lock_fini(const struct lu_env *env, struct cl_lock_slice *slice);
@@ -360,11 +354,15 @@ static inline struct inode *vvp_object_inode(const struct cl_object *obj)
 int vvp_object_invariant(const struct cl_object *obj);
 struct vvp_object *cl_inode2vvp(struct inode *inode);
 
+static inline struct page *cl2vm_page(const struct cl_page_slice *slice)
+{
+	return cl2vvp_page(slice)->vpg_page;
+}
+
 struct ccc_lock *cl2ccc_lock(const struct cl_lock_slice *slice);
 struct ccc_io *cl2ccc_io(const struct lu_env *env,
 			 const struct cl_io_slice *slice);
 struct ccc_req *cl2ccc_req(const struct cl_req_slice *slice);
-struct page *cl2vm_page(const struct cl_page_slice *slice);
 
 int cl_setattr_ost(struct inode *inode, const struct iattr *attr);
 
diff --git a/drivers/staging/lustre/lustre/llite/vvp_io.c b/drivers/staging/lustre/lustre/llite/vvp_io.c
index 1773cb2..eb6ce1c 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_io.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_io.c
@@ -645,15 +645,15 @@ static int vvp_io_commit_sync(const struct lu_env *env, struct cl_io *io,
 static void write_commit_callback(const struct lu_env *env, struct cl_io *io,
 				  struct cl_page *page)
 {
-	struct ccc_page *cp;
+	struct vvp_page *vpg;
 	struct page *vmpage = page->cp_vmpage;
 	struct cl_object *clob = cl_io_top(io)->ci_obj;
 
 	SetPageUptodate(vmpage);
 	set_page_dirty(vmpage);
 
-	cp = cl2ccc_page(cl_object_page_slice(clob, page));
-	vvp_write_pending(cl2vvp(clob), cp);
+	vpg = cl2vvp_page(cl_object_page_slice(clob, page));
+	vvp_write_pending(cl2vvp(clob), vpg);
 
 	cl_page_disown(env, io, page);
 
@@ -670,15 +670,15 @@ static bool page_list_sanity_check(struct cl_object *obj,
 	pgoff_t index = CL_PAGE_EOF;
 
 	cl_page_list_for_each(page, plist) {
-		struct ccc_page *cp = cl_object_page_slice(obj, page);
+		struct vvp_page *vpg = cl_object_page_slice(obj, page);
 
 		if (index == CL_PAGE_EOF) {
-			index = ccc_index(cp);
+			index = vvp_index(vpg);
 			continue;
 		}
 
 		++index;
-		if (index == ccc_index(cp))
+		if (index == vvp_index(vpg))
 			continue;
 
 		return false;
@@ -868,13 +868,13 @@ static int vvp_io_kernel_fault(struct vvp_fault_io *cfio)
 static void mkwrite_commit_callback(const struct lu_env *env, struct cl_io *io,
 				    struct cl_page *page)
 {
-	struct ccc_page *cp;
+	struct vvp_page *vpg;
 	struct cl_object *clob = cl_io_top(io)->ci_obj;
 
 	set_page_dirty(page->cp_vmpage);
 
-	cp = cl2ccc_page(cl_object_page_slice(clob, page));
-	vvp_write_pending(cl2vvp(clob), cp);
+	vpg = cl2vvp_page(cl_object_page_slice(clob, page));
+	vvp_write_pending(cl2vvp(clob), vpg);
 }
 
 static int vvp_io_fault_start(const struct lu_env *env,
@@ -979,7 +979,7 @@ static int vvp_io_fault_start(const struct lu_env *env,
 		wait_on_page_writeback(vmpage);
 		if (!PageDirty(vmpage)) {
 			struct cl_page_list *plist = &io->ci_queue.c2_qin;
-			struct ccc_page *cp = cl_object_page_slice(obj, page);
+			struct vvp_page *vpg = cl_object_page_slice(obj, page);
 			int to = PAGE_SIZE;
 
 			/* vvp_page_assume() calls wait_on_page_writeback(). */
@@ -989,7 +989,7 @@ static int vvp_io_fault_start(const struct lu_env *env,
 			cl_page_list_add(plist, page);
 
 			/* size fixup */
-			if (last_index == ccc_index(cp))
+			if (last_index == vvp_index(vpg))
 				to = size & ~PAGE_MASK;
 
 			/* Do not set Dirty bit here so that in case IO is
@@ -1058,7 +1058,7 @@ static int vvp_io_read_page(const struct lu_env *env,
 			    const struct cl_page_slice *slice)
 {
 	struct cl_io	      *io     = ios->cis_io;
-	struct ccc_page	   *cp     = cl2ccc_page(slice);
+	struct vvp_page           *vpg    = cl2vvp_page(slice);
 	struct cl_page	    *page   = slice->cpl_page;
 	struct inode              *inode  = vvp_object_inode(slice->cpl_obj);
 	struct ll_sb_info	 *sbi    = ll_i2sbi(inode);
@@ -1068,11 +1068,11 @@ static int vvp_io_read_page(const struct lu_env *env,
 
 	if (sbi->ll_ra_info.ra_max_pages_per_file &&
 	    sbi->ll_ra_info.ra_max_pages)
-		ras_update(sbi, inode, ras, ccc_index(cp),
-			   cp->cpg_defer_uptodate);
+		ras_update(sbi, inode, ras, vvp_index(vpg),
+			   vpg->vpg_defer_uptodate);
 
-	if (cp->cpg_defer_uptodate) {
-		cp->cpg_ra_used = 1;
+	if (vpg->vpg_defer_uptodate) {
+		vpg->vpg_ra_used = 1;
 		cl_page_export(env, page, 1);
 	}
 	/*
@@ -1084,7 +1084,7 @@ static int vvp_io_read_page(const struct lu_env *env,
 	if (sbi->ll_ra_info.ra_max_pages_per_file &&
 	    sbi->ll_ra_info.ra_max_pages)
 		ll_readahead(env, io, &queue->c2_qin, ras,
-			     cp->cpg_defer_uptodate);
+			     vpg->vpg_defer_uptodate);
 
 	return 0;
 }
diff --git a/drivers/staging/lustre/lustre/llite/vvp_object.c b/drivers/staging/lustre/lustre/llite/vvp_object.c
index 9f5e6a6..18c9df7 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_object.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_object.c
@@ -226,7 +226,7 @@ static int vvp_object_init0(const struct lu_env *env,
 {
 	vob->vob_inode = conf->coc_inode;
 	vob->vob_transient_pages = 0;
-	cl_object_page_init(&vob->vob_cl, sizeof(struct ccc_page));
+	cl_object_page_init(&vob->vob_cl, sizeof(struct vvp_page));
 	return 0;
 }
 
diff --git a/drivers/staging/lustre/lustre/llite/vvp_page.c b/drivers/staging/lustre/lustre/llite/vvp_page.c
index 419a535..5ebbe27 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_page.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_page.c
@@ -41,7 +41,13 @@
 
 #define DEBUG_SUBSYSTEM S_LLITE
 
-#include "../include/obd.h"
+#include <linux/atomic.h>
+#include <linux/bitops.h>
+#include <linux/mm.h>
+#include <linux/mutex.h>
+#include <linux/page-flags.h>
+#include <linux/pagemap.h>
+
 #include "../include/lustre_lite.h"
 
 #include "llite_internal.h"
@@ -53,9 +59,9 @@
  *
  */
 
-static void vvp_page_fini_common(struct ccc_page *cp)
+static void vvp_page_fini_common(struct vvp_page *vpg)
 {
-	struct page *vmpage = cp->cpg_page;
+	struct page *vmpage = vpg->vpg_page;
 
 	LASSERT(vmpage);
 	page_cache_release(vmpage);
@@ -64,23 +70,23 @@ static void vvp_page_fini_common(struct ccc_page *cp)
 static void vvp_page_fini(const struct lu_env *env,
 			  struct cl_page_slice *slice)
 {
-	struct ccc_page *cp = cl2ccc_page(slice);
-	struct page *vmpage  = cp->cpg_page;
+	struct vvp_page *vpg     = cl2vvp_page(slice);
+	struct page     *vmpage  = vpg->vpg_page;
 
 	/*
 	 * vmpage->private was already cleared when page was moved into
 	 * VPG_FREEING state.
 	 */
 	LASSERT((struct cl_page *)vmpage->private != slice->cpl_page);
-	vvp_page_fini_common(cp);
+	vvp_page_fini_common(vpg);
 }
 
 static int vvp_page_own(const struct lu_env *env,
 			const struct cl_page_slice *slice, struct cl_io *io,
 			int nonblock)
 {
-	struct ccc_page *vpg    = cl2ccc_page(slice);
-	struct page      *vmpage = vpg->cpg_page;
+	struct vvp_page *vpg    = cl2vvp_page(slice);
+	struct page     *vmpage = vpg->vpg_page;
 
 	LASSERT(vmpage);
 	if (nonblock) {
@@ -97,6 +103,7 @@ static int vvp_page_own(const struct lu_env *env,
 
 	lock_page(vmpage);
 	wait_on_page_writeback(vmpage);
+
 	return 0;
 }
 
@@ -137,12 +144,12 @@ static void vvp_page_discard(const struct lu_env *env,
 			     struct cl_io *unused)
 {
 	struct page	   *vmpage  = cl2vm_page(slice);
-	struct ccc_page      *cpg     = cl2ccc_page(slice);
+	struct vvp_page      *vpg     = cl2vvp_page(slice);
 
 	LASSERT(vmpage);
 	LASSERT(PageLocked(vmpage));
 
-	if (cpg->cpg_defer_uptodate && !cpg->cpg_ra_used)
+	if (vpg->vpg_defer_uptodate && !vpg->vpg_ra_used)
 		ll_ra_stats_inc(vmpage->mapping->host, RA_STAT_DISCARDED);
 
 	ll_invalidate_page(vmpage);
@@ -161,7 +168,7 @@ static void vvp_page_delete(const struct lu_env *env,
 	LASSERT((struct cl_page *)vmpage->private == page);
 	LASSERT(inode == vvp_object_inode(obj));
 
-	vvp_write_complete(cl2vvp(obj), cl2ccc_page(slice));
+	vvp_write_complete(cl2vvp(obj), cl2vvp_page(slice));
 
 	/* Drop the reference count held in vvp_page_init */
 	refc = atomic_dec_return(&page->cp_ref);
@@ -220,7 +227,7 @@ static int vvp_page_prep_write(const struct lu_env *env,
 	if (!pg->cp_sync_io)
 		set_page_writeback(vmpage);
 
-	vvp_write_pending(cl2vvp(slice->cpl_obj), cl2ccc_page(slice));
+	vvp_write_pending(cl2vvp(slice->cpl_obj), cl2vvp_page(slice));
 
 	return 0;
 }
@@ -257,22 +264,23 @@ static void vvp_page_completion_read(const struct lu_env *env,
 				     const struct cl_page_slice *slice,
 				     int ioret)
 {
-	struct ccc_page *cp     = cl2ccc_page(slice);
-	struct page      *vmpage = cp->cpg_page;
+	struct vvp_page *vpg    = cl2vvp_page(slice);
+	struct page     *vmpage = vpg->vpg_page;
 	struct cl_page  *page   = slice->cpl_page;
 	struct inode    *inode  = vvp_object_inode(page->cp_obj);
 
 	LASSERT(PageLocked(vmpage));
 	CL_PAGE_HEADER(D_PAGE, env, page, "completing READ with %d\n", ioret);
 
-	if (cp->cpg_defer_uptodate)
+	if (vpg->vpg_defer_uptodate)
 		ll_ra_count_put(ll_i2sbi(inode), 1);
 
 	if (ioret == 0)  {
-		if (!cp->cpg_defer_uptodate)
+		if (!vpg->vpg_defer_uptodate)
 			cl_page_export(env, page, 1);
-	} else
-		cp->cpg_defer_uptodate = 0;
+	} else {
+		vpg->vpg_defer_uptodate = 0;
+	}
 
 	if (!page->cp_sync_io)
 		unlock_page(vmpage);
@@ -282,9 +290,9 @@ static void vvp_page_completion_write(const struct lu_env *env,
 				      const struct cl_page_slice *slice,
 				      int ioret)
 {
-	struct ccc_page *cp     = cl2ccc_page(slice);
+	struct vvp_page *vpg     = cl2vvp_page(slice);
 	struct cl_page  *pg     = slice->cpl_page;
-	struct page      *vmpage = cp->cpg_page;
+	struct page     *vmpage = vpg->vpg_page;
 
 	CL_PAGE_HEADER(D_PAGE, env, pg, "completing WRITE with %d\n", ioret);
 
@@ -298,8 +306,8 @@ static void vvp_page_completion_write(const struct lu_env *env,
 	 * and then re-add the page into pending transfer queue.  -jay
 	 */
 
-	cp->cpg_write_queued = 0;
-	vvp_write_complete(cl2vvp(slice->cpl_obj), cp);
+	vpg->vpg_write_queued = 0;
+	vvp_write_complete(cl2vvp(slice->cpl_obj), vpg);
 
 	if (pg->cp_sync_io) {
 		LASSERT(PageLocked(vmpage));
@@ -342,7 +350,7 @@ static int vvp_page_make_ready(const struct lu_env *env,
 		LASSERT(pg->cp_state == CPS_CACHED);
 		/* This actually clears the dirty bit in the radix tree. */
 		set_page_writeback(vmpage);
-		vvp_write_pending(cl2vvp(slice->cpl_obj), cl2ccc_page(slice));
+		vvp_write_pending(cl2vvp(slice->cpl_obj), cl2vvp_page(slice));
 		CL_PAGE_HEADER(D_PAGE, env, pg, "readied\n");
 	} else if (pg->cp_state == CPS_PAGEOUT) {
 		/* is it possible for osc_flush_async_page() to already
@@ -376,12 +384,12 @@ static int vvp_page_print(const struct lu_env *env,
 			  const struct cl_page_slice *slice,
 			  void *cookie, lu_printer_t printer)
 {
-	struct ccc_page *vp = cl2ccc_page(slice);
-	struct page      *vmpage = vp->cpg_page;
+	struct vvp_page *vpg = cl2vvp_page(slice);
+	struct page     *vmpage = vpg->vpg_page;
 
 	(*printer)(env, cookie, LUSTRE_VVP_NAME "-page@%p(%d:%d:%d) vm@%p ",
-		   vp, vp->cpg_defer_uptodate, vp->cpg_ra_used,
-		   vp->cpg_write_queued, vmpage);
+		   vpg, vpg->vpg_defer_uptodate, vpg->vpg_ra_used,
+		   vpg->vpg_write_queued, vmpage);
 	if (vmpage) {
 		(*printer)(env, cookie, "%lx %d:%d %lx %lu %slru",
 			   (long)vmpage->flags, page_count(vmpage),
@@ -389,7 +397,20 @@ static int vvp_page_print(const struct lu_env *env,
 			   page_index(vmpage),
 			   list_empty(&vmpage->lru) ? "not-" : "");
 	}
+
 	(*printer)(env, cookie, "\n");
+
+	return 0;
+}
+
+static int vvp_page_fail(const struct lu_env *env,
+			 const struct cl_page_slice *slice)
+{
+	/*
+	 * Cached read?
+	 */
+	LBUG();
+
 	return 0;
 }
 
@@ -409,16 +430,24 @@ static const struct cl_page_operations vvp_page_ops = {
 		[CRT_READ] = {
 			.cpo_prep	= vvp_page_prep_read,
 			.cpo_completion  = vvp_page_completion_read,
-			.cpo_make_ready  = ccc_fail,
+			.cpo_make_ready = vvp_page_fail,
 		},
 		[CRT_WRITE] = {
 			.cpo_prep	= vvp_page_prep_write,
 			.cpo_completion  = vvp_page_completion_write,
 			.cpo_make_ready  = vvp_page_make_ready,
-		}
-	}
+		},
+	},
 };
 
+static int vvp_transient_page_prep(const struct lu_env *env,
+				   const struct cl_page_slice *slice,
+				   struct cl_io *unused)
+{
+	/* transient page should always be sent. */
+	return 0;
+}
+
 static void vvp_transient_page_verify(const struct cl_page *page)
 {
 	struct inode *inode = vvp_object_inode(page->cp_obj);
@@ -492,11 +521,11 @@ vvp_transient_page_completion(const struct lu_env *env,
 static void vvp_transient_page_fini(const struct lu_env *env,
 				    struct cl_page_slice *slice)
 {
-	struct ccc_page *cp = cl2ccc_page(slice);
+	struct vvp_page *vpg = cl2vvp_page(slice);
 	struct cl_page *clp = slice->cpl_page;
 	struct vvp_object *clobj = cl2vvp(clp->cp_obj);
 
-	vvp_page_fini_common(cp);
+	vvp_page_fini_common(vpg);
 	LASSERT(!inode_trylock(clobj->vob_inode));
 	clobj->vob_transient_pages--;
 }
@@ -513,11 +542,11 @@ static const struct cl_page_operations vvp_transient_page_ops = {
 	.cpo_is_under_lock	= vvp_page_is_under_lock,
 	.io = {
 		[CRT_READ] = {
-			.cpo_prep	= ccc_transient_page_prep,
+			.cpo_prep	= vvp_transient_page_prep,
 			.cpo_completion  = vvp_transient_page_completion,
 		},
 		[CRT_WRITE] = {
-			.cpo_prep	= ccc_transient_page_prep,
+			.cpo_prep	= vvp_transient_page_prep,
 			.cpo_completion  = vvp_transient_page_completion,
 		}
 	}
@@ -526,27 +555,27 @@ static const struct cl_page_operations vvp_transient_page_ops = {
 int vvp_page_init(const struct lu_env *env, struct cl_object *obj,
 		struct cl_page *page, pgoff_t index)
 {
-	struct ccc_page *cpg = cl_object_page_slice(obj, page);
+	struct vvp_page *vpg = cl_object_page_slice(obj, page);
 	struct page     *vmpage = page->cp_vmpage;
 
 	CLOBINVRNT(env, obj, vvp_object_invariant(obj));
 
-	cpg->cpg_page = vmpage;
+	vpg->vpg_page = vmpage;
 	page_cache_get(vmpage);
 
-	INIT_LIST_HEAD(&cpg->cpg_pending_linkage);
+	INIT_LIST_HEAD(&vpg->vpg_pending_linkage);
 	if (page->cp_type == CPT_CACHEABLE) {
 		/* in cache, decref in vvp_page_delete */
 		atomic_inc(&page->cp_ref);
 		SetPagePrivate(vmpage);
 		vmpage->private = (unsigned long)page;
-		cl_page_slice_add(page, &cpg->cpg_cl, obj, index,
+		cl_page_slice_add(page, &vpg->vpg_cl, obj, index,
 				  &vvp_page_ops);
 	} else {
 		struct vvp_object *clobj = cl2vvp(obj);
 
 		LASSERT(!inode_trylock(clobj->vob_inode));
-		cl_page_slice_add(page, &cpg->cpg_cl, obj, index,
+		cl_page_slice_add(page, &vpg->vpg_cl, obj, index,
 				  &vvp_transient_page_ops);
 		clobj->vob_transient_pages++;
 	}
-- 
2.1.0
