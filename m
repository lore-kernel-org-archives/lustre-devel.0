From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Sep 2019 14:56:21 -0400
Subject: [lustre-devel] [PATCH 122/151] lustre: llite: Add tiny write support
In-Reply-To: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1569869810-23848-123-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Patrick Farrell <pfarrell@whamcloud.com>

If a page is already dirty in the page cache, we can write
to it without a full i/o.  This improves performance for
writes of < 1 page dramatically.

Append writes are a bit tricky, requiring us to take the
range lock (which we can normally avoid), but they are
still much faster than the normal i/o path.

Performance numbers with dd, on a VM with an older Xeon.

All numbers in MiB/s.

                8 bytes 1KiB
Without patch:  .75     75
With patch:     6.5     153

WC-bug-id: https://jira.whamcloud.com/browse/LU-9409
Cray-bug-id: LUS-1705
Lustre-commit: 94470f7eeab5 ("LU-9409 llite: Add tiny write support")
Signed-off-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/27903
Reviewed-by: Jinshan Xiong <jinshan.xiong@gmail.com>
Reviewed-by: Alexey Lyashkov <c17817@cray.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/cl_object.h |   9 ++++
 fs/lustre/llite/file.c        | 122 ++++++++++++++++++++++++++++++++++++++++--
 fs/lustre/llite/rw26.c        |  71 ++++++++++++++++++++++--
 fs/lustre/obdclass/cl_page.c  |  13 +++++
 fs/lustre/osc/osc_internal.h  |   2 +
 fs/lustre/osc/osc_io.c        |  16 ++----
 fs/lustre/osc/osc_page.c      |  12 ++++-
 7 files changed, 224 insertions(+), 21 deletions(-)

diff --git a/fs/lustre/include/cl_object.h b/fs/lustre/include/cl_object.h
index 1088fde..c96a5b7 100644
--- a/fs/lustre/include/cl_object.h
+++ b/fs/lustre/include/cl_object.h
@@ -865,6 +865,13 @@ struct cl_page_operations {
 	 */
 	int (*cpo_is_vmlocked)(const struct lu_env *env,
 			       const struct cl_page_slice *slice);
+
+	/**
+	 * Update file attributes when all we have is this page.  Used for tiny
+	 * writes to update attributes when we don't have a full cl_io.
+	 */
+	void (*cpo_page_touch)(const struct lu_env *env,
+			       const struct cl_page_slice *slice, size_t to);
 	/**
 	 * Page destruction.
 	 */
@@ -2203,6 +2210,8 @@ void cl_page_discard(const struct lu_env *env, struct cl_io *io,
 		     struct cl_page *pg);
 void cl_page_delete(const struct lu_env *env, struct cl_page *pg);
 int cl_page_is_vmlocked(const struct lu_env *env, const struct cl_page *pg);
+void cl_page_touch(const struct lu_env *env, const struct cl_page *pg,
+		   size_t to);
 void cl_page_export(const struct lu_env *env, struct cl_page *pg, int uptodate);
 loff_t cl_offset(const struct cl_object *obj, pgoff_t idx);
 pgoff_t cl_index(const struct cl_object *obj, loff_t offset);
diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index 92f4a43..da5bf86 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -1475,6 +1475,101 @@ static ssize_t ll_file_read_iter(struct kiocb *iocb, struct iov_iter *to)
 	return result;
 }
 
+/**
+ * Similar trick to ll_do_fast_read, this improves write speed for tiny writes.
+ * If a page is already in the page cache and dirty (and some other things -
+ * See ll_tiny_write_begin for the instantiation of these rules), then we can
+ * write to it without doing a full I/O, because Lustre already knows about it
+ * and will write it out.  This saves a lot of processing time.
+ *
+ * All writes here are within one page, so exclusion is handled by the page
+ * lock on the vm page.  Exception is appending, which requires locking the
+ * full file to handle size issues.  We do not do tiny writes for writes which
+ * touch multiple pages because it's very unlikely multiple sequential pages
+ * are already dirty.
+ *
+ * We limit these to < PAGE_SIZE because PAGE_SIZE writes are relatively common
+ * and are unlikely to be to already dirty pages.
+ *
+ * Attribute updates are important here, we do it in ll_tiny_write_end.
+ */
+static ssize_t ll_do_tiny_write(struct kiocb *iocb, struct iov_iter *iter)
+{
+	ssize_t count = iov_iter_count(iter);
+	struct file *file = iocb->ki_filp;
+	struct inode *inode = file_inode(file);
+	struct ll_inode_info *lli = ll_i2info(inode);
+	struct range_lock range;
+	ssize_t result = 0;
+	bool append = false;
+
+	/* NB: we can't do direct IO for tiny writes because they use the page
+	 * cache, and we can't do sync writes because tiny writes can't flush
+	 * pages.
+	 */
+	if (file->f_flags & (O_DIRECT | O_SYNC))
+		return 0;
+
+	/* It is relatively unlikely we will overwrite a full dirty page, so
+	 * limit tiny writes to < PAGE_SIZE
+	 */
+	if (count >= PAGE_SIZE)
+		return 0;
+
+	/* For append writes, we must take the range lock to protect size
+	 * and also move pos to current size before writing.
+	 */
+	if (file->f_flags & O_APPEND) {
+		struct lu_env *env;
+		u16 refcheck;
+
+		append = true;
+		range_lock_init(&range, 0, LUSTRE_EOF);
+		result = range_lock(&lli->lli_write_tree, &range);
+		if (result)
+			return result;
+		env = cl_env_get(&refcheck);
+		if (IS_ERR(env)) {
+			result = PTR_ERR(env);
+			goto out;
+		}
+		ll_merge_attr(env, inode);
+		cl_env_put(env, &refcheck);
+		iocb->ki_pos = i_size_read(inode);
+	}
+
+	/* Does this write touch multiple pages?
+	 *
+	 * This partly duplicates the PAGE_SIZE check above, but must come
+	 * after range locking for append writes because it depends on the
+	 * write position (ki_pos).
+	 */
+	if ((iocb->ki_pos & (PAGE_SIZE-1)) + count > PAGE_SIZE)
+		goto out;
+
+	result = __generic_file_write_iter(iocb, iter);
+
+	/* If the page is not already dirty, ll_tiny_write_begin returns
+	 * -ENODATA.  We continue on to normal write.
+	 */
+	if (result == -ENODATA)
+		result = 0;
+
+	if (result > 0) {
+		ll_stats_ops_tally(ll_i2sbi(inode), LPROC_LL_WRITE_BYTES,
+				   result);
+		set_bit(LLIF_DATA_MODIFIED, &ll_i2info(inode)->lli_flags);
+	}
+
+out:
+	if (append)
+		range_unlock(&lli->lli_write_tree, &range);
+
+	CDEBUG(D_VFSTRACE, "result: %zu, original count %zu\n", result, count);
+
+	return result;
+}
+
 /*
  * Write to a file (through the page cache).
  */
@@ -1482,9 +1577,19 @@ static ssize_t ll_file_write_iter(struct kiocb *iocb, struct iov_iter *from)
 {
 	struct lu_env *env;
 	struct vvp_io_args *args;
-	ssize_t result;
+	ssize_t rc_tiny, rc_normal;
 	u16 refcheck;
 
+	rc_tiny = ll_do_tiny_write(iocb, from);
+
+	/* In case of error, go on and try normal write - Only stop if tiny
+	 * write completed I/O.
+	 */
+	if (iov_iter_count(from) == 0) {
+		rc_normal = rc_tiny;
+		goto out;
+	}
+
 	env = cl_env_get(&refcheck);
 	if (IS_ERR(env))
 		return PTR_ERR(env);
@@ -1493,10 +1598,21 @@ static ssize_t ll_file_write_iter(struct kiocb *iocb, struct iov_iter *from)
 	args->u.normal.via_iter = from;
 	args->u.normal.via_iocb = iocb;
 
-	result = ll_file_io_generic(env, args, iocb->ki_filp, CIT_WRITE,
+	rc_normal = ll_file_io_generic(env, args, iocb->ki_filp, CIT_WRITE,
 				    &iocb->ki_pos, iov_iter_count(from));
+
+	/* On success, combine bytes written. */
+	if (rc_tiny >= 0 && rc_normal > 0)
+		rc_normal += rc_tiny;
+	/* On error, only return error from normal write if tiny write did not
+	 * write any bytes.  Otherwise return bytes written by tiny write.
+	 */
+	else if (rc_tiny > 0)
+		rc_normal = rc_tiny;
+
 	cl_env_put(env, &refcheck);
-	return result;
+out:
+	return rc_normal;
 }
 
 int ll_lov_setstripe_ea_info(struct inode *inode, struct dentry *dentry,
diff --git a/fs/lustre/llite/rw26.c b/fs/lustre/llite/rw26.c
index 37b6755..2baab10 100644
--- a/fs/lustre/llite/rw26.c
+++ b/fs/lustre/llite/rw26.c
@@ -443,13 +443,23 @@ static int ll_prepare_partial_page(const struct lu_env *env, struct cl_io *io,
 	return result;
 }
 
+static int ll_tiny_write_begin(struct page *vmpage)
+{
+	/* Page must be present, up to date, dirty, and not in writeback. */
+	if (!vmpage || !PageUptodate(vmpage) || !PageDirty(vmpage) ||
+	    PageWriteback(vmpage))
+		return -ENODATA;
+
+	return 0;
+}
+
 static int ll_write_begin(struct file *file, struct address_space *mapping,
 			  loff_t pos, unsigned int len, unsigned int flags,
 			  struct page **pagep, void **fsdata)
 {
-	struct ll_cl_context *lcc;
+	struct ll_cl_context *lcc = NULL;
 	const struct lu_env *env = NULL;
-	struct cl_io *io;
+	struct cl_io *io = NULL;
 	struct cl_page *page = NULL;
 	struct cl_object *clob = ll_i2info(mapping->host)->lli_clob;
 	pgoff_t index = pos >> PAGE_SHIFT;
@@ -462,8 +472,8 @@ static int ll_write_begin(struct file *file, struct address_space *mapping,
 
 	lcc = ll_cl_find(file);
 	if (!lcc) {
-		io = NULL;
-		result = -EIO;
+		vmpage = grab_cache_page_nowait(mapping, index);
+		result = ll_tiny_write_begin(vmpage);
 		goto out;
 	}
 
@@ -479,6 +489,7 @@ static int ll_write_begin(struct file *file, struct address_space *mapping,
 		result = -EBUSY;
 		goto out;
 	}
+
 again:
 	/* To avoid deadlock, try to lock page first. */
 	vmpage = grab_cache_page_nowait(mapping, index);
@@ -544,7 +555,6 @@ static int ll_write_begin(struct file *file, struct address_space *mapping,
 
 				if (result == -EAGAIN)
 					goto again;
-
 				goto out;
 			}
 		}
@@ -555,6 +565,7 @@ static int ll_write_begin(struct file *file, struct address_space *mapping,
 			unlock_page(vmpage);
 			put_page(vmpage);
 		}
+		/* On tiny_write failure, page and io are always null. */
 		if (!IS_ERR_OR_NULL(page)) {
 			lu_ref_del(&page->cp_reference, "cl_io", io);
 			cl_page_put(env, page);
@@ -568,6 +579,45 @@ static int ll_write_begin(struct file *file, struct address_space *mapping,
 	return result;
 }
 
+static int ll_tiny_write_end(struct file *file, struct address_space *mapping,
+			     loff_t pos, unsigned int len, unsigned int copied,
+			     struct page *vmpage)
+{
+	struct cl_page *clpage = (struct cl_page *) vmpage->private;
+	loff_t kms = pos+copied;
+	loff_t to = kms & (PAGE_SIZE-1) ? kms & (PAGE_SIZE-1) : PAGE_SIZE;
+	u16 refcheck;
+	struct lu_env *env = cl_env_get(&refcheck);
+	int rc = 0;
+
+	if (IS_ERR(env)) {
+		rc = PTR_ERR(env);
+		goto out;
+	}
+
+	/* This page is dirty in cache, so it should have a cl_page pointer
+	 * set in vmpage->private.
+	 */
+	LASSERT(clpage);
+
+	if (copied == 0)
+		goto out_env;
+
+	/* Update the underlying size information in the OSC/LOV objects this
+	 * page is part of.
+	 */
+	cl_page_touch(env, clpage, to);
+
+out_env:
+	cl_env_put(env, &refcheck);
+
+out:
+	/* Must return page unlocked. */
+	unlock_page(vmpage);
+
+	return rc;
+}
+
 static int ll_write_end(struct file *file, struct address_space *mapping,
 			loff_t pos, unsigned int len, unsigned int copied,
 			struct page *vmpage, void *fsdata)
@@ -583,6 +633,14 @@ static int ll_write_end(struct file *file, struct address_space *mapping,
 
 	put_page(vmpage);
 
+	CDEBUG(D_VFSTRACE, "pos %llu, len %u, copied %u\n", pos, len, copied);
+
+	if (!lcc) {
+		result = ll_tiny_write_end(file, mapping, pos, len, copied,
+					   vmpage);
+		goto out;
+	}
+
 	env  = lcc->lcc_env;
 	page = lcc->lcc_page;
 	io   = lcc->lcc_io;
@@ -632,6 +690,9 @@ static int ll_write_end(struct file *file, struct address_space *mapping,
 
 	if (result < 0)
 		io->ci_result = result;
+
+
+out:
 	return result >= 0 ? copied : result;
 }
 
diff --git a/fs/lustre/obdclass/cl_page.c b/fs/lustre/obdclass/cl_page.c
index 8ea63f7..8dbd312 100644
--- a/fs/lustre/obdclass/cl_page.c
+++ b/fs/lustre/obdclass/cl_page.c
@@ -681,6 +681,19 @@ int cl_page_is_vmlocked(const struct lu_env *env, const struct cl_page *pg)
 }
 EXPORT_SYMBOL(cl_page_is_vmlocked);
 
+void cl_page_touch(const struct lu_env *env, const struct cl_page *pg,
+		  size_t to)
+{
+	const struct cl_page_slice *slice;
+
+	list_for_each_entry(slice, &pg->cp_layers, cpl_linkage) {
+		if (slice->cpl_ops->cpo_page_touch)
+			(*slice->cpl_ops->cpo_page_touch)(env, slice, to);
+	}
+
+}
+EXPORT_SYMBOL(cl_page_touch);
+
 static enum cl_page_state cl_req_type_state(enum cl_req_type crt)
 {
 	return crt == CRT_WRITE ? CPS_PAGEOUT : CPS_PAGEIN;
diff --git a/fs/lustre/osc/osc_internal.h b/fs/lustre/osc/osc_internal.h
index 1194033..3ba209f 100644
--- a/fs/lustre/osc/osc_internal.h
+++ b/fs/lustre/osc/osc_internal.h
@@ -143,6 +143,8 @@ int osc_quotactl(struct obd_device *unused, struct obd_export *exp,
 void osc_inc_unstable_pages(struct ptlrpc_request *req);
 void osc_dec_unstable_pages(struct ptlrpc_request *req);
 bool osc_over_unstable_soft_limit(struct client_obd *cli);
+void osc_page_touch_at(const struct lu_env *env, struct cl_object *obj,
+		       pgoff_t idx, size_t to);
 
 struct ldlm_lock *osc_obj_dlmlock_at_pgoff(const struct lu_env *env,
 					   struct osc_object *obj,
diff --git a/fs/lustre/osc/osc_io.c b/fs/lustre/osc/osc_io.c
index d8fa8cc..98726cd 100644
--- a/fs/lustre/osc/osc_io.c
+++ b/fs/lustre/osc/osc_io.c
@@ -216,14 +216,13 @@ int osc_io_submit(const struct lu_env *env, const struct cl_io_slice *ios,
 EXPORT_SYMBOL(osc_io_submit);
 
 /**
- * This is called when a page is accessed within file in a way that creates
- * new page, if one were missing (i.e., if there were a hole at that place in
- * the file, or accessed page is beyond the current file size).
+ * This is called to update the attributes when modifying a specific page,
+ * both when making new pages and when doing updates to existing cached pages.
  *
  * Expand stripe KMS if necessary.
  */
-static void osc_page_touch_at(const struct lu_env *env,
-			      struct cl_object *obj, pgoff_t idx, size_t to)
+void osc_page_touch_at(const struct lu_env *env, struct cl_object *obj,
+		       pgoff_t idx, size_t to)
 {
 	struct lov_oinfo *loi = cl2osc(obj)->oo_oinfo;
 	struct cl_attr *attr = &osc_env_info(env)->oti_attr;
@@ -234,13 +233,6 @@ static void osc_page_touch_at(const struct lu_env *env,
 	kms = cl_offset(obj, idx) + to;
 
 	cl_object_attr_lock(obj);
-	/*
-	 * XXX old code used
-	 *
-	 *	 ll_inode_size_lock(inode, 0); lov_stripe_lock(lsm);
-	 *
-	 * here
-	 */
 	CDEBUG(D_INODE, "stripe KMS %sincreasing %llu->%llu %llu\n",
 	       kms > loi->loi_kms ? "" : "not ", loi->loi_kms, kms,
 	       loi->loi_lvb.lvb_size);
diff --git a/fs/lustre/osc/osc_page.c b/fs/lustre/osc/osc_page.c
index 96d1385..731fd27 100644
--- a/fs/lustre/osc/osc_page.c
+++ b/fs/lustre/osc/osc_page.c
@@ -228,11 +228,21 @@ static int osc_page_flush(const struct lu_env *env,
 	return rc;
 }
 
+static void osc_page_touch(const struct lu_env *env,
+			  const struct cl_page_slice *slice, size_t to)
+{
+	struct osc_page *opg = cl2osc_page(slice);
+	struct cl_object *obj = opg->ops_cl.cpl_obj;
+
+	osc_page_touch_at(env, obj, osc_index(opg), to);
+}
+
 static const struct cl_page_operations osc_page_ops = {
 	.cpo_print	= osc_page_print,
 	.cpo_delete	= osc_page_delete,
 	.cpo_clip	= osc_page_clip,
-	.cpo_flush	= osc_page_flush
+	.cpo_flush	= osc_page_flush,
+	.cpo_page_touch	= osc_page_touch,
 };
 
 int osc_page_init(const struct lu_env *env, struct cl_object *obj,
-- 
1.8.3.1
