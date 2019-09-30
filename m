From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Sep 2019 14:55:59 -0400
Subject: [lustre-devel] [PATCH 100/151] lustre: clio: Use readahead for
 partial page write
In-Reply-To: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1569869810-23848-101-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Patrick Farrell <pfarrell@whamcloud.com>

When writing to a region of a file less than file size
(either an existing file or a shared file with multiple
writers), writes of less than one page in size must first
read in that page.

This results in extremely poor performance. For random I/O,
there's no easy improvements available, but the sequential
case can benefit enormously by using readahead to bring in
those pages.

This patch connects ll_prepare_partial_page to the readahead
infrastructure.

This does not affect random I/O or large unaligned writes,
where readahead does not detect I/O.

Benchmarks are from a small VM system, files are NOT in
cache when rewriting.

Write numbers are in MB/s.

File per process:
    access             = file-per-process
    ordering in a file = sequential offsets
    ordering inter file= no tasks offsets
    clients            = 1 (1 per node)
    repetitions        = 1
    blocksize          = 1000 MiB
    aggregate filesize = 1000 MiB

New file (best case):
xfsize  ppr     write
1KiB    n/a     59.44
5KiB    n/a     164.5

Rewrite of existing file:
xfsize  ppr     re-write
1KiB    off     4.65
1KiB    on      48.40
5KiB    off     12.95
5KiB    on      143.3

Shared file writing:
        access             = single-shared-file
        ordering in a file = sequential offsets
        ordering inter file= no tasks offsets
        clients            = 4 (4 per node)
        repetitions        = 1
        blocksize          = 1000 MiB
        aggregate filesize = 4000 MiB

xfsize  ppr     write
1KiB    off     11.26
1KiB    on      58.72
5KiB    off     18.7
5KiB    on      127.3

WC-bug-id: https://jira.whamcloud.com/browse/LU-9618
Cray-bug-id: LUS-188
Lustre-commit: b7d38ece0013 ("LU-9618 clio: Use readahead for partial page write")
Signed-off-by: Patrick Farrell <pfarrell@whamcloud.com>
Signed-off-by: Jinshan Xiong <jinshan.xiong@gmail.com>
Reviewed-on: https://review.whamcloud.com/27544
Reviewed-by: Jinshan Xiong <jinshan.xiong@gmail.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/llite_internal.h |  2 ++
 fs/lustre/llite/rw.c             | 34 +++---------------
 fs/lustre/llite/rw26.c           | 75 +++++++++++++++++++++++++++++-----------
 3 files changed, 61 insertions(+), 50 deletions(-)

diff --git a/fs/lustre/llite/llite_internal.h b/fs/lustre/llite/llite_internal.h
index ded310b..229d417 100644
--- a/fs/lustre/llite/llite_internal.h
+++ b/fs/lustre/llite/llite_internal.h
@@ -788,6 +788,8 @@ int ll_md_blocking_ast(struct ldlm_lock *lock, struct ldlm_lock_desc *desc,
 int ll_writepage(struct page *page, struct writeback_control *wbc);
 int ll_writepages(struct address_space *mapping, struct writeback_control *wbc);
 int ll_readpage(struct file *file, struct page *page);
+int ll_io_read_page(const struct lu_env *env, struct cl_io *io,
+			   struct cl_page *page, struct file *file);
 void ll_readahead_init(struct inode *inode, struct ll_readahead_state *ras);
 int vvp_io_write_commit(const struct lu_env *env, struct cl_io *io);
 
diff --git a/fs/lustre/llite/rw.c b/fs/lustre/llite/rw.c
index 02b9a0c..c42bbab 100644
--- a/fs/lustre/llite/rw.c
+++ b/fs/lustre/llite/rw.c
@@ -1094,7 +1094,7 @@ void ll_cl_remove(struct file *file, const struct lu_env *env)
 	write_unlock(&fd->fd_lock);
 }
 
-static int ll_io_read_page(const struct lu_env *env, struct cl_io *io,
+int ll_io_read_page(const struct lu_env *env, struct cl_io *io,
 			   struct cl_page *page, struct file *file)
 {
 	struct inode *inode = vvp_object_inode(page->cp_obj);
@@ -1153,6 +1153,7 @@ static int ll_io_read_page(const struct lu_env *env, struct cl_io *io,
 		if (!rc)
 			task_io_account_read(PAGE_SIZE * count);
 	}
+
 	if (anchor && !cl_page_is_owned(page, io)) { /* have sent */
 		rc = cl_sync_io_wait(env, anchor, 0);
 
@@ -1174,10 +1175,9 @@ static int ll_io_read_page(const struct lu_env *env, struct cl_io *io,
 	/* TODO: discard all pages until page reinit route is implemented */
 	cl_page_list_discard(env, io, &queue->c2_qin);
 
-	/*
-	 * Unlock unsent pages in case of error.
-	 */
+	/* Unlock unsent read pages in case of error. */
 	cl_page_list_disown(env, io, &queue->c2_qin);
+
 	cl_2queue_fini(env, queue);
 
 	return rc;
@@ -1270,6 +1270,7 @@ int ll_readpage(struct file *file, struct page *vmpage)
 		LASSERT(page->cp_type == CPT_CACHEABLE);
 		if (likely(!PageUptodate(vmpage))) {
 			cl_page_assume(env, io, page);
+
 			result = ll_io_read_page(env, io, page, file);
 		} else {
 			/* Page from a non-object file. */
@@ -1283,28 +1284,3 @@ int ll_readpage(struct file *file, struct page *vmpage)
 	}
 	return result;
 }
-
-int ll_page_sync_io(const struct lu_env *env, struct cl_io *io,
-		    struct cl_page *page, enum cl_req_type crt)
-{
-	struct cl_2queue  *queue;
-	int result;
-
-	LASSERT(io->ci_type == CIT_READ || io->ci_type == CIT_WRITE);
-
-	queue = &io->ci_queue;
-	cl_2queue_init_page(queue, page);
-
-	result = cl_io_submit_sync(env, io, crt, queue, 0);
-	LASSERT(cl_page_is_owned(page, io));
-
-	if (crt == CRT_READ)
-		/*
-		 * in CRT_WRITE case page is left locked even in case of
-		 * error.
-		 */
-		cl_page_list_disown(env, io, &queue->c2_qin);
-	cl_2queue_fini(env, queue);
-
-	return result;
-}
diff --git a/fs/lustre/llite/rw26.c b/fs/lustre/llite/rw26.c
index 4d86c4b..37b6755 100644
--- a/fs/lustre/llite/rw26.c
+++ b/fs/lustre/llite/rw26.c
@@ -383,9 +383,11 @@ static ssize_t ll_direct_IO(struct kiocb *iocb, struct iov_iter *iter)
 
 /**
  * Prepare partially written-to page for a write.
+ * @pg is owned when passed in and disowned when it returns non-zero result to
+ * the caller.
  */
 static int ll_prepare_partial_page(const struct lu_env *env, struct cl_io *io,
-				   struct cl_page *pg)
+				   struct cl_page *pg, struct file *file)
 {
 	struct cl_attr *attr = vvp_env_thread_attr(env);
 	struct cl_object *obj = io->ci_obj;
@@ -396,23 +398,48 @@ static int ll_prepare_partial_page(const struct lu_env *env, struct cl_io *io,
 	cl_object_attr_lock(obj);
 	result = cl_object_attr_get(env, obj, attr);
 	cl_object_attr_unlock(obj);
-	if (result == 0) {
-		/*
-		 * If are writing to a new page, no need to read old data.
-		 * The extent locking will have updated the KMS, and for our
-		 * purposes here we can treat it like i_size.
-		 */
-		if (attr->cat_kms <= offset) {
-			char *kaddr = kmap_atomic(vpg->vpg_page);
+	if (result) {
+		cl_page_disown(env, io, pg);
+		goto out;
+	}
 
-			memset(kaddr, 0, cl_page_size(obj));
-			kunmap_atomic(kaddr);
-		} else if (vpg->vpg_defer_uptodate) {
-			vpg->vpg_ra_used = 1;
-		} else {
-			result = ll_page_sync_io(env, io, pg, CRT_READ);
+	/*
+	 * If are writing to a new page, no need to read old data.
+	 * The extent locking will have updated the KMS, and for our
+	 * purposes here we can treat it like i_size.
+	 */
+	if (attr->cat_kms <= offset) {
+		char *kaddr = kmap_atomic(vpg->vpg_page);
+
+		memset(kaddr, 0, cl_page_size(obj));
+		kunmap_atomic(kaddr);
+		result = 0;
+		goto out;
+	}
+
+	if (vpg->vpg_defer_uptodate) {
+		vpg->vpg_ra_used = 1;
+		result = 0;
+		goto out;
+	}
+
+	result = ll_io_read_page(env, io, pg, file);
+	if (result)
+		goto out;
+
+	/* ll_io_read_page() disowns the page */
+	result = cl_page_own(env, io, pg);
+	if (!result) {
+		if (!PageUptodate(cl_page_vmpage(pg))) {
+			cl_page_disown(env, io, pg);
+			result = -EIO;
 		}
+	} else if (result == -ENOENT) {
+		/* page was truncated */
+		result = -EAGAIN;
 	}
+
+out:
 	return result;
 }
 
@@ -452,7 +479,7 @@ static int ll_write_begin(struct file *file, struct address_space *mapping,
 		result = -EBUSY;
 		goto out;
 	}
-
+again:
 	/* To avoid deadlock, try to lock page first. */
 	vmpage = grab_cache_page_nowait(mapping, index);
 	if (unlikely(!vmpage || PageDirty(vmpage) || PageWriteback(vmpage))) {
@@ -509,13 +536,19 @@ static int ll_write_begin(struct file *file, struct address_space *mapping,
 			 * is a lockless IO. In that case, it's not necessary
 			 * to read the data.
 			 */
-			result = ll_prepare_partial_page(env, io, page);
-			if (result == 0)
-				SetPageUptodate(vmpage);
+			result = ll_prepare_partial_page(env, io, page, file);
+			if (result) {
+				/* vmpage should have been unlocked */
+				put_page(vmpage);
+				vmpage = NULL;
+
+				if (result == -EAGAIN)
+					goto again;
+
+				goto out;
+			}
 		}
 	}
-	if (result < 0)
-		cl_page_unassume(env, io, page);
 out:
 	if (result < 0) {
 		if (vmpage) {
-- 
1.8.3.1
