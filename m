Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 12679C6FA8B
	for <lustre-devel@archiver.kernel.org>; Sun, 18 Sep 2022 05:22:54 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4MVbmY5JxHz1yC4;
	Sat, 17 Sep 2022 22:22:53 -0700 (PDT)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4MVbm46NVwz1yBh
 for <lustre-devel@lists.lustre.org>; Sat, 17 Sep 2022 22:22:28 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id F21428F0E;
 Sun, 18 Sep 2022 01:22:16 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id F0392E8B93; Sun, 18 Sep 2022 01:22:16 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 18 Sep 2022 01:22:04 -0400
Message-Id: <1663478534-19917-15-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1663478534-19917-1-git-send-email-jsimmons@infradead.org>
References: <1663478534-19917-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 14/24] lustre: clio: remove struct vvp_page
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
Cc: Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: "John L. Hammond" <jhammond@whamcloud.com>

Remove struct vvp_page and use struct cl_page_slice in its place. Use
cp_vmpage in place of vpg_page and cl_page_index() in place of
vvp_index().

WC-bug-id: https://jira.whamcloud.com/browse/LU-10994
Lustre-commit: 127570b3e5a2ff018 ("LU-10994 clio: remove struct vvp_page")
Signed-off-by: John L. Hammond <jhammond@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/47400
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/cl_object.h  |  7 ++++++-
 fs/lustre/llite/rw.c           | 24 ++++++++++--------------
 fs/lustre/llite/rw26.c         |  5 ++---
 fs/lustre/llite/vvp_dev.c      |  7 +++----
 fs/lustre/llite/vvp_internal.h | 19 ++-----------------
 fs/lustre/llite/vvp_io.c       |  9 +++------
 fs/lustre/llite/vvp_object.c   |  2 +-
 fs/lustre/llite/vvp_page.c     | 20 ++++++++------------
 8 files changed, 35 insertions(+), 58 deletions(-)

diff --git a/fs/lustre/include/cl_object.h b/fs/lustre/include/cl_object.h
index b19d521..c816b1d 100644
--- a/fs/lustre/include/cl_object.h
+++ b/fs/lustre/include/cl_object.h
@@ -963,12 +963,17 @@ struct cl_page_operations {
 	}								\
 } while (0)
 
-static inline struct page *cl_page_vmpage(struct cl_page *page)
+static inline struct page *cl_page_vmpage(const struct cl_page *page)
 {
 	LASSERT(page->cp_vmpage);
 	return page->cp_vmpage;
 }
 
+static inline pgoff_t cl_page_index(const struct cl_page *cp)
+{
+	return cl_page_vmpage(cp)->index;
+}
+
 /**
  * Check if a cl_page is in use.
  *
diff --git a/fs/lustre/llite/rw.c b/fs/lustre/llite/rw.c
index 7c4b8ec..2290b31 100644
--- a/fs/lustre/llite/rw.c
+++ b/fs/lustre/llite/rw.c
@@ -1635,7 +1635,6 @@ int ll_io_read_page(const struct lu_env *env, struct cl_io *io,
 	pgoff_t io_start_index;
 	pgoff_t io_end_index;
 	int rc = 0, rc2 = 0;
-	struct vvp_page *vpg;
 
 	if (file) {
 		fd = file->private_data;
@@ -1648,7 +1647,6 @@ int ll_io_read_page(const struct lu_env *env, struct cl_io *io,
 	if (page->cp_vmpage && PagePrivate2(page->cp_vmpage))
 		unlockpage = false;
 
-	vpg = cl2vvp_page(cl_object_page_slice(page->cp_obj, page));
 	uptodate = page->cp_defer_uptodate;
 
 	if (ll_readahead_enabled(sbi) && !page->cp_ra_updated && ras) {
@@ -1658,7 +1656,7 @@ int ll_io_read_page(const struct lu_env *env, struct cl_io *io,
 			flags |= LL_RAS_HIT;
 		if (mmap)
 			flags |= LL_RAS_MMAP;
-		ras_update(sbi, inode, ras, vvp_index(vpg), flags, io);
+		ras_update(sbi, inode, ras, cl_page_index(page), flags, io);
 	}
 
 	cl_2queue_init(queue);
@@ -1680,15 +1678,15 @@ int ll_io_read_page(const struct lu_env *env, struct cl_io *io,
 		io_end_index = cl_index(io->ci_obj, io->u.ci_rw.crw_pos +
 					io->u.ci_rw.crw_count - 1);
 	} else {
-		io_start_index = vvp_index(vpg);
-		io_end_index = vvp_index(vpg);
+		io_start_index = cl_page_index(page);
+		io_end_index = cl_page_index(page);
 	}
 
 	if (ll_readahead_enabled(sbi) && ras && !io->ci_rand_read) {
 		pgoff_t skip_index = 0;
 
-		if (ras->ras_next_readahead_idx < vvp_index(vpg))
-			skip_index = vvp_index(vpg);
+		if (ras->ras_next_readahead_idx < cl_page_index(page))
+			skip_index = cl_page_index(page);
 		rc2 = ll_readahead(env, io, &queue->c2_qin, ras,
 				   uptodate, file, skip_index,
 				   &ra_start_index);
@@ -1698,15 +1696,15 @@ int ll_io_read_page(const struct lu_env *env, struct cl_io *io,
 		CDEBUG(D_READA | (rc2 ? D_IOTRACE : 0),
 		       DFID " %d pages read ahead at %lu, triggered by user read at %lu, stride offset %lld, stride length %lld, stride bytes %lld\n",
 		       PFID(ll_inode2fid(inode)), rc2, ra_start_index,
-		       vvp_index(vpg), ras->ras_stride_offset,
+		       cl_page_index(page), ras->ras_stride_offset,
 		       ras->ras_stride_length, ras->ras_stride_bytes);
 
-	} else if (vvp_index(vpg) == io_start_index &&
+	} else if (cl_page_index(page) == io_start_index &&
 		   io_end_index - io_start_index > 0) {
 		rc2 = ll_readpages(env, io, &queue->c2_qin, io_start_index + 1,
 				   io_end_index);
 		CDEBUG(D_READA, DFID " %d pages read at %lu\n",
-		       PFID(ll_inode2fid(inode)), rc2, vvp_index(vpg));
+		       PFID(ll_inode2fid(inode)), rc2, cl_page_index(page));
 	}
 
 	if (queue->c2_qin.pl_nr > 0) {
@@ -1865,7 +1863,6 @@ int ll_readpage(struct file *file, struct page *vmpage)
 		struct ll_file_data *fd = file->private_data;
 		struct ll_readahead_state *ras = &fd->fd_ras;
 		struct lu_env *local_env = NULL;
-		struct vvp_page *vpg;
 
 		result = -ENODATA;
 
@@ -1880,7 +1877,6 @@ int ll_readpage(struct file *file, struct page *vmpage)
 			return result;
 		}
 
-		vpg = cl2vvp_page(cl_object_page_slice(page->cp_obj, page));
 		if (page->cp_defer_uptodate) {
 			enum ras_update_flags flags = LL_RAS_HIT;
 
@@ -1892,11 +1888,11 @@ int ll_readpage(struct file *file, struct page *vmpage)
 			 * if the page is hit in cache because non cache page
 			 * case will be handled by slow read later.
 			 */
-			ras_update(sbi, inode, ras, vvp_index(vpg), flags, io);
+			ras_update(sbi, inode, ras, cl_page_index(page), flags, io);
 			/* avoid duplicate ras_update() call */
 			page->cp_ra_updated = 1;
 
-			if (ll_use_fast_io(file, ras, vvp_index(vpg)))
+			if (ll_use_fast_io(file, ras, cl_page_index(page)))
 				result = 0;
 		}
 
diff --git a/fs/lustre/llite/rw26.c b/fs/lustre/llite/rw26.c
index 4f2e68e..cadded4 100644
--- a/fs/lustre/llite/rw26.c
+++ b/fs/lustre/llite/rw26.c
@@ -452,8 +452,7 @@ static int ll_prepare_partial_page(const struct lu_env *env, struct cl_io *io,
 {
 	struct cl_attr *attr = vvp_env_thread_attr(env);
 	struct cl_object *obj = io->ci_obj;
-	struct vvp_page *vpg = cl_object_page_slice(obj, pg);
-	loff_t offset = cl_offset(obj, vvp_index(vpg));
+	loff_t offset = cl_offset(obj, cl_page_index(pg));
 	int result;
 
 	cl_object_attr_lock(obj);
@@ -470,7 +469,7 @@ static int ll_prepare_partial_page(const struct lu_env *env, struct cl_io *io,
 	 * purposes here we can treat it like i_size.
 	 */
 	if (attr->cat_kms <= offset) {
-		char *kaddr = kmap_atomic(vpg->vpg_page);
+		char *kaddr = kmap_atomic(pg->cp_vmpage);
 
 		memset(kaddr, 0, cl_page_size(obj));
 		kunmap_atomic(kaddr);
diff --git a/fs/lustre/llite/vvp_dev.c b/fs/lustre/llite/vvp_dev.c
index 99335bd..298720c 100644
--- a/fs/lustre/llite/vvp_dev.c
+++ b/fs/lustre/llite/vvp_dev.c
@@ -429,15 +429,14 @@ static struct page *vvp_pgcache_current(struct vvp_seq_private *priv)
 static void vvp_pgcache_page_show(const struct lu_env *env,
 				  struct seq_file *seq, struct cl_page *page)
 {
-	struct vvp_page *vpg;
 	struct page *vmpage;
 	int has_flags;
 
-	vpg = cl2vvp_page(cl_page_at(page, &vvp_device_type));
-	vmpage = vpg->vpg_page;
+	vmpage = page->cp_vmpage;
 	seq_printf(seq, " %5i | %p %p %s %s | %p " DFID "(%p) %lu %u [",
 		   0 /* gen */,
-		   vpg, page,
+		   NULL, /* was vvp_page */
+		   page,
 		   "none",
 		   PageWriteback(vmpage) ? "wb" : "-",
 		   vmpage, PFID(ll_inode2fid(vmpage->mapping->host)),
diff --git a/fs/lustre/llite/vvp_internal.h b/fs/lustre/llite/vvp_internal.h
index 0e0da76..17feae6 100644
--- a/fs/lustre/llite/vvp_internal.h
+++ b/fs/lustre/llite/vvp_internal.h
@@ -209,23 +209,8 @@ struct vvp_object {
 };
 
 /**
- * VVP-private page state.
+ * Their is no VVP-private page state.
  */
-struct vvp_page {
-	struct cl_page_slice	vpg_cl;
-	/** VM page */
-	struct page		*vpg_page;
-};
-
-static inline struct vvp_page *cl2vvp_page(const struct cl_page_slice *slice)
-{
-	return container_of(slice, struct vvp_page, vpg_cl);
-}
-
-static inline pgoff_t vvp_index(struct vvp_page *vvp)
-{
-	return vvp->vpg_page->index;
-}
 
 struct vvp_device {
 	struct cl_device	vdv_cl;
@@ -267,7 +252,7 @@ static inline struct inode *vvp_object_inode(const struct cl_object *obj)
 
 static inline struct page *cl2vm_page(const struct cl_page_slice *slice)
 {
-	return cl2vvp_page(slice)->vpg_page;
+	return slice->cpl_page->cp_vmpage;
 }
 
 # define CLOBINVRNT(env, clob, expr)					\
diff --git a/fs/lustre/llite/vvp_io.c b/fs/lustre/llite/vvp_io.c
index 6fd2e2dd..ef7a3d92 100644
--- a/fs/lustre/llite/vvp_io.c
+++ b/fs/lustre/llite/vvp_io.c
@@ -1044,15 +1044,13 @@ static bool page_list_sanity_check(struct cl_object *obj,
 	pgoff_t index = CL_PAGE_EOF;
 
 	cl_page_list_for_each(page, plist) {
-		struct vvp_page *vpg = cl_object_page_slice(obj, page);
-
 		if (index == CL_PAGE_EOF) {
-			index = vvp_index(vpg);
+			index = cl_page_index(page);
 			continue;
 		}
 
 		++index;
-		if (index == vvp_index(vpg))
+		if (index == cl_page_index(page))
 			continue;
 
 		return false;
@@ -1438,7 +1436,6 @@ static int vvp_io_fault_start(const struct lu_env *env,
 		wait_on_page_writeback(vmpage);
 		if (!PageDirty(vmpage)) {
 			struct cl_page_list *plist = &vio->u.fault.ft_queue;
-			struct vvp_page *vpg = cl_object_page_slice(obj, page);
 			int to = PAGE_SIZE;
 
 			/* vvp_page_assume() calls wait_on_page_writeback(). */
@@ -1448,7 +1445,7 @@ static int vvp_io_fault_start(const struct lu_env *env,
 			cl_page_list_add(plist, page, true);
 
 			/* size fixup */
-			if (last_index == vvp_index(vpg))
+			if (last_index == cl_page_index(page))
 				to = ((size - 1) & ~PAGE_MASK) + 1;
 
 			/* Do not set Dirty bit here so that in case IO is
diff --git a/fs/lustre/llite/vvp_object.c b/fs/lustre/llite/vvp_object.c
index 64ecdb9..0ef055f 100644
--- a/fs/lustre/llite/vvp_object.c
+++ b/fs/lustre/llite/vvp_object.c
@@ -228,7 +228,7 @@ static int __vvp_object_init(const struct lu_env *env,
 			     const struct cl_object_conf *conf)
 {
 	vob->vob_inode = conf->coc_inode;
-	cl_object_page_init(&vob->vob_cl, sizeof(struct vvp_page));
+	cl_object_page_init(&vob->vob_cl, sizeof(struct cl_page_slice));
 	return 0;
 }
 
diff --git a/fs/lustre/llite/vvp_page.c b/fs/lustre/llite/vvp_page.c
index 7c80908..f359596 100644
--- a/fs/lustre/llite/vvp_page.c
+++ b/fs/lustre/llite/vvp_page.c
@@ -125,13 +125,12 @@ static void vvp_page_completion_write(const struct lu_env *env,
 				      const struct cl_page_slice *slice,
 				      int ioret)
 {
-	struct vvp_page *vpg = cl2vvp_page(slice);
-	struct cl_page *pg = slice->cpl_page;
-	struct page *vmpage = vpg->vpg_page;
+	struct cl_page *cp = slice->cpl_page;
+	struct page *vmpage = cp->cp_vmpage;
 
-	CL_PAGE_HEADER(D_PAGE, env, pg, "completing WRITE with %d\n", ioret);
+	CL_PAGE_HEADER(D_PAGE, env, cp, "completing WRITE with %d\n", ioret);
 
-	if (pg->cp_sync_io) {
+	if (cp->cp_sync_io) {
 		LASSERT(PageLocked(vmpage));
 		LASSERT(!PageWriteback(vmpage));
 	} else {
@@ -140,7 +139,7 @@ static void vvp_page_completion_write(const struct lu_env *env,
 		 * Only mark the page error only when it's an async write
 		 * because applications won't wait for IO to finish.
 		 */
-		vvp_vmpage_error(vvp_object_inode(pg->cp_obj), vmpage, ioret);
+		vvp_vmpage_error(vvp_object_inode(cp->cp_obj), vmpage, ioret);
 
 		end_page_writeback(vmpage);
 	}
@@ -164,18 +163,16 @@ static void vvp_page_completion_write(const struct lu_env *env,
 int vvp_page_init(const struct lu_env *env, struct cl_object *obj,
 		  struct cl_page *page, pgoff_t index)
 {
-	struct vvp_page *vpg = cl_object_page_slice(obj, page);
+	struct cl_page_slice *cpl = cl_object_page_slice(obj, page);
 	struct page *vmpage = page->cp_vmpage;
 
 	CLOBINVRNT(env, obj, vvp_object_invariant(obj));
 
-	vpg->vpg_page = vmpage;
-
 	if (page->cp_type == CPT_TRANSIENT) {
 		/* DIO pages are referenced by userspace, we don't need to take
 		 * a reference on them. (contrast with get_page() call above)
 		 */
-		cl_page_slice_add(page, &vpg->vpg_cl, obj,
+		cl_page_slice_add(page, cpl, obj,
 				  &vvp_transient_page_ops);
 	} else {
 		get_page(vmpage);
@@ -183,8 +180,7 @@ int vvp_page_init(const struct lu_env *env, struct cl_object *obj,
 		refcount_inc(&page->cp_ref);
 		SetPagePrivate(vmpage);
 		vmpage->private = (unsigned long)page;
-		cl_page_slice_add(page, &vpg->vpg_cl, obj,
-				  &vvp_page_ops);
+		cl_page_slice_add(page, cpl, obj, &vvp_page_ops);
 	}
 	return 0;
 }
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
