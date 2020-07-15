From: James Simmons <jsimmons@infradead.org>
Date: Wed, 15 Jul 2020 16:45:16 -0400
Subject: [lustre-devel] [PATCH 35/37] lustre: llite: fix short io for AIO
In-Reply-To: <1594845918-29027-1-git-send-email-jsimmons@infradead.org>
References: <1594845918-29027-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1594845918-29027-36-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Wang Shilong <wshilong@ddn.com>

The problem is currently AIO could not handle i/o size > stripe size:

We need cl io loop to handle io across stripes, since -EIOCBQUEUED is
returned for AIO, io loop will be stopped thus short io happen.

The patch try to fix the problem by making IO engine aware of
special error, and it will be proceed to finish all IO requests.

Fixes: fde7ac1942f5 ("lustre: clio: AIO support for direct IO")
WC-bug-id: https://jira.whamcloud.com/browse/LU-13697
Lustre-commit: 84c3e85ced2dd ("LU-13697 llite: fix short io for AIO")
Signed-off-by: Wang Shilong <wshilong@ddn.com>
Reviewed-on: https://review.whamcloud.com/39104
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/cl_object.h  |  2 ++
 fs/lustre/llite/file.c         | 32 +++++++++++++++++-
 fs/lustre/llite/rw26.c         | 43 +++++++++++++++++--------
 fs/lustre/llite/vvp_internal.h |  3 +-
 fs/lustre/llite/vvp_io.c       | 73 ++++++++++++++++++++++++++++--------------
 fs/lustre/obdclass/cl_io.c     |  9 +++++-
 6 files changed, 122 insertions(+), 40 deletions(-)

diff --git a/fs/lustre/include/cl_object.h b/fs/lustre/include/cl_object.h
index e656c68..e849f23 100644
--- a/fs/lustre/include/cl_object.h
+++ b/fs/lustre/include/cl_object.h
@@ -1814,6 +1814,8 @@ struct cl_io {
 	enum cl_io_state	ci_state;
 	/** main object this io is against. Immutable after creation. */
 	struct cl_object	*ci_obj;
+	/** one AIO request might be split in cl_io_loop */
+	struct cl_dio_aio	*ci_aio;
 	/**
 	 * Upper layer io, of which this io is a part of. Immutable after
 	 * creation.
diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index 1849229..757950f 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -1514,6 +1514,7 @@ static void ll_heat_add(struct inode *inode, enum cl_io_type iot,
 	int rc = 0;
 	unsigned int retried = 0;
 	unsigned int ignore_lockless = 0;
+	bool is_aio = false;
 
 	CDEBUG(D_VFSTRACE, "file: %pD, type: %d ppos: %llu, count: %zu\n",
 	       file, iot, *ppos, count);
@@ -1536,6 +1537,15 @@ static void ll_heat_add(struct inode *inode, enum cl_io_type iot,
 		vio->vui_fd  = file->private_data;
 		vio->vui_iter = args->u.normal.via_iter;
 		vio->vui_iocb = args->u.normal.via_iocb;
+		if (file->f_flags & O_DIRECT) {
+			if (!is_sync_kiocb(vio->vui_iocb))
+				is_aio = true;
+			io->ci_aio = cl_aio_alloc(vio->vui_iocb);
+			if (!io->ci_aio) {
+				rc = -ENOMEM;
+				goto out;
+			}
+		}
 		/*
 		 * Direct IO reads must also take range lock,
 		 * or multiple reads will try to work on the same pages
@@ -1567,7 +1577,14 @@ static void ll_heat_add(struct inode *inode, enum cl_io_type iot,
 		rc = io->ci_result;
 	}
 
-	if (io->ci_nob > 0) {
+	/*
+	 * In order to move forward AIO, ci_nob was increased,
+	 * but that doesn't mean io have been finished, it just
+	 * means io have been submited, we will always return
+	 * EIOCBQUEUED to the caller, So we could only return
+	 * number of bytes in non-AIO case.
+	 */
+	if (io->ci_nob > 0 && !is_aio) {
 		result += io->ci_nob;
 		count -= io->ci_nob;
 		*ppos = io->u.ci_wr.wr.crw_pos;
@@ -1577,6 +1594,19 @@ static void ll_heat_add(struct inode *inode, enum cl_io_type iot,
 			args->u.normal.via_iter = vio->vui_iter;
 	}
 out:
+	if (io->ci_aio) {
+		/**
+		 * Drop one extra reference so that end_io() could be
+		 * called for this IO context, we could call it after
+		 * we make sure all AIO requests have been proceed.
+		 */
+		cl_sync_io_note(env, &io->ci_aio->cda_sync,
+				rc == -EIOCBQUEUED ? 0 : rc);
+		if (!is_aio) {
+			cl_aio_free(io->ci_aio);
+			io->ci_aio = NULL;
+		}
+	}
 	cl_io_fini(env, io);
 
 	CDEBUG(D_VFSTRACE,
diff --git a/fs/lustre/llite/rw26.c b/fs/lustre/llite/rw26.c
index d0e3ff6..b3802cf 100644
--- a/fs/lustre/llite/rw26.c
+++ b/fs/lustre/llite/rw26.c
@@ -290,6 +290,7 @@ static ssize_t ll_direct_IO(struct kiocb *iocb, struct iov_iter *iter)
 	ssize_t tot_bytes = 0, result = 0;
 	loff_t file_offset = iocb->ki_pos;
 	int rw = iov_iter_rw(iter);
+	struct vvp_io *vio;
 
 	/* if file is encrypted, return 0 so that we fall back to buffered IO */
 	if (IS_ENCRYPTED(inode))
@@ -319,12 +320,13 @@ static ssize_t ll_direct_IO(struct kiocb *iocb, struct iov_iter *iter)
 
 	env = lcc->lcc_env;
 	LASSERT(!IS_ERR(env));
+	vio = vvp_env_io(env);
 	io = lcc->lcc_io;
 	LASSERT(io);
 
-	aio = cl_aio_alloc(iocb);
-	if (!aio)
-		return -ENOMEM;
+	aio = io->ci_aio;
+	LASSERT(aio);
+	LASSERT(aio->cda_iocb == iocb);
 
 	/* 0. Need locking between buffered and direct access. and race with
 	 *    size changing by concurrent truncates and writes.
@@ -368,24 +370,39 @@ static ssize_t ll_direct_IO(struct kiocb *iocb, struct iov_iter *iter)
 	}
 
 out:
-	aio->cda_bytes = tot_bytes;
-	cl_sync_io_note(env, &aio->cda_sync, result);
+	aio->cda_bytes += tot_bytes;
 
 	if (is_sync_kiocb(iocb)) {
+		struct cl_sync_io *anchor = &aio->cda_sync;
 		ssize_t rc2;
 
-		rc2 = cl_sync_io_wait(env, &aio->cda_sync, 0);
+		/**
+		 * @anchor was inited as 1 to prevent end_io to be
+		 * called before we add all pages for IO, so drop
+		 * one extra reference to make sure we could wait
+		 * count to be zero.
+		 */
+		cl_sync_io_note(env, anchor, result);
+
+		rc2 = cl_sync_io_wait(env, anchor, 0);
 		if (result == 0 && rc2)
 			result = rc2;
 
+		/**
+		 * One extra reference again, as if @anchor is
+		 * reused we assume it as 1 before using.
+		 */
+		atomic_add(1, &anchor->csi_sync_nr);
 		if (result == 0) {
-			struct vvp_io *vio = vvp_env_io(env);
 			/* no commit async for direct IO */
-			vio->u.write.vui_written += tot_bytes;
+			vio->u.readwrite.vui_written += tot_bytes;
 			result = tot_bytes;
 		}
-		cl_aio_free(aio);
 	} else {
+		if (rw == WRITE)
+			vio->u.readwrite.vui_written += tot_bytes;
+		else
+			vio->u.readwrite.vui_read += tot_bytes;
 		result = -EIOCBQUEUED;
 	}
 
@@ -523,7 +540,7 @@ static int ll_write_begin(struct file *file, struct address_space *mapping,
 	vmpage = grab_cache_page_nowait(mapping, index);
 	if (unlikely(!vmpage || PageDirty(vmpage) || PageWriteback(vmpage))) {
 		struct vvp_io *vio = vvp_env_io(env);
-		struct cl_page_list *plist = &vio->u.write.vui_queue;
+		struct cl_page_list *plist = &vio->u.readwrite.vui_queue;
 
 		/* if the page is already in dirty cache, we have to commit
 		 * the pages right now; otherwise, it may cause deadlock
@@ -685,17 +702,17 @@ static int ll_write_end(struct file *file, struct address_space *mapping,
 
 	LASSERT(cl_page_is_owned(page, io));
 	if (copied > 0) {
-		struct cl_page_list *plist = &vio->u.write.vui_queue;
+		struct cl_page_list *plist = &vio->u.readwrite.vui_queue;
 
 		lcc->lcc_page = NULL; /* page will be queued */
 
 		/* Add it into write queue */
 		cl_page_list_add(plist, page);
 		if (plist->pl_nr == 1) /* first page */
-			vio->u.write.vui_from = from;
+			vio->u.readwrite.vui_from = from;
 		else
 			LASSERT(from == 0);
-		vio->u.write.vui_to = from + copied;
+		vio->u.readwrite.vui_to = from + copied;
 
 		/*
 		 * To address the deadlock in balance_dirty_pages() where
diff --git a/fs/lustre/llite/vvp_internal.h b/fs/lustre/llite/vvp_internal.h
index cff85ea..6956d6b 100644
--- a/fs/lustre/llite/vvp_internal.h
+++ b/fs/lustre/llite/vvp_internal.h
@@ -88,9 +88,10 @@ struct vvp_io {
 		struct {
 			struct cl_page_list	vui_queue;
 			unsigned long		vui_written;
+			unsigned long		vui_read;
 			int			vui_from;
 			int			vui_to;
-		} write;
+		} readwrite; /* normal io */
 	} u;
 
 	/**
diff --git a/fs/lustre/llite/vvp_io.c b/fs/lustre/llite/vvp_io.c
index c3fb03a..59da56d 100644
--- a/fs/lustre/llite/vvp_io.c
+++ b/fs/lustre/llite/vvp_io.c
@@ -249,10 +249,20 @@ static int vvp_io_write_iter_init(const struct lu_env *env,
 {
 	struct vvp_io *vio = cl2vvp_io(env, ios);
 
-	cl_page_list_init(&vio->u.write.vui_queue);
-	vio->u.write.vui_written = 0;
-	vio->u.write.vui_from = 0;
-	vio->u.write.vui_to = PAGE_SIZE;
+	cl_page_list_init(&vio->u.readwrite.vui_queue);
+	vio->u.readwrite.vui_written = 0;
+	vio->u.readwrite.vui_from = 0;
+	vio->u.readwrite.vui_to = PAGE_SIZE;
+
+	return 0;
+}
+
+static int vvp_io_read_iter_init(const struct lu_env *env,
+				 const struct cl_io_slice *ios)
+{
+	struct vvp_io *vio = cl2vvp_io(env, ios);
+
+	vio->u.readwrite.vui_read = 0;
 
 	return 0;
 }
@@ -262,7 +272,7 @@ static void vvp_io_write_iter_fini(const struct lu_env *env,
 {
 	struct vvp_io *vio = cl2vvp_io(env, ios);
 
-	LASSERT(vio->u.write.vui_queue.pl_nr == 0);
+	LASSERT(vio->u.readwrite.vui_queue.pl_nr == 0);
 }
 
 static int vvp_io_fault_iter_init(const struct lu_env *env,
@@ -824,7 +834,13 @@ static int vvp_io_read_start(const struct lu_env *env,
 			io->ci_continue = 0;
 		io->ci_nob += result;
 		result = 0;
+	} else if (result == -EIOCBQUEUED) {
+		io->ci_nob += vio->u.readwrite.vui_read;
+		if (vio->vui_iocb)
+			vio->vui_iocb->ki_pos = pos +
+						vio->u.readwrite.vui_read;
 	}
+
 	return result;
 }
 
@@ -1017,23 +1033,24 @@ int vvp_io_write_commit(const struct lu_env *env, struct cl_io *io)
 	struct cl_object *obj = io->ci_obj;
 	struct inode *inode = vvp_object_inode(obj);
 	struct vvp_io *vio = vvp_env_io(env);
-	struct cl_page_list *queue = &vio->u.write.vui_queue;
+	struct cl_page_list *queue = &vio->u.readwrite.vui_queue;
 	struct cl_page *page;
 	int rc = 0;
 	int bytes = 0;
-	unsigned int npages = vio->u.write.vui_queue.pl_nr;
+	unsigned int npages = vio->u.readwrite.vui_queue.pl_nr;
 
 	if (npages == 0)
 		return 0;
 
 	CDEBUG(D_VFSTRACE, "commit async pages: %d, from %d, to %d\n",
-	       npages, vio->u.write.vui_from, vio->u.write.vui_to);
+	       npages, vio->u.readwrite.vui_from, vio->u.readwrite.vui_to);
 
 	LASSERT(page_list_sanity_check(obj, queue));
 
 	/* submit IO with async write */
 	rc = cl_io_commit_async(env, io, queue,
-				vio->u.write.vui_from, vio->u.write.vui_to,
+				vio->u.readwrite.vui_from,
+				vio->u.readwrite.vui_to,
 				write_commit_callback);
 	npages -= queue->pl_nr; /* already committed pages */
 	if (npages > 0) {
@@ -1041,18 +1058,18 @@ int vvp_io_write_commit(const struct lu_env *env, struct cl_io *io)
 		bytes = npages << PAGE_SHIFT;
 
 		/* first page */
-		bytes -= vio->u.write.vui_from;
+		bytes -= vio->u.readwrite.vui_from;
 		if (queue->pl_nr == 0) /* last page */
-			bytes -= PAGE_SIZE - vio->u.write.vui_to;
+			bytes -= PAGE_SIZE - vio->u.readwrite.vui_to;
 		LASSERTF(bytes > 0, "bytes = %d, pages = %d\n", bytes, npages);
 
-		vio->u.write.vui_written += bytes;
+		vio->u.readwrite.vui_written += bytes;
 
 		CDEBUG(D_VFSTRACE, "Committed %d pages %d bytes, tot: %ld\n",
-		       npages, bytes, vio->u.write.vui_written);
+		       npages, bytes, vio->u.readwrite.vui_written);
 
 		/* the first page must have been written. */
-		vio->u.write.vui_from = 0;
+		vio->u.readwrite.vui_from = 0;
 	}
 	LASSERT(page_list_sanity_check(obj, queue));
 	LASSERT(ergo(rc == 0, queue->pl_nr == 0));
@@ -1060,10 +1077,10 @@ int vvp_io_write_commit(const struct lu_env *env, struct cl_io *io)
 	/* out of quota, try sync write */
 	if (rc == -EDQUOT && !cl_io_is_mkwrite(io)) {
 		rc = vvp_io_commit_sync(env, io, queue,
-					vio->u.write.vui_from,
-					vio->u.write.vui_to);
+					vio->u.readwrite.vui_from,
+					vio->u.readwrite.vui_to);
 		if (rc > 0) {
-			vio->u.write.vui_written += rc;
+			vio->u.readwrite.vui_written += rc;
 			rc = 0;
 		}
 	}
@@ -1181,15 +1198,15 @@ static int vvp_io_write_start(const struct lu_env *env,
 		result = vvp_io_write_commit(env, io);
 		/* Simulate short commit */
 		if (CFS_FAULT_CHECK(OBD_FAIL_LLITE_SHORT_COMMIT)) {
-			vio->u.write.vui_written >>= 1;
-			if (vio->u.write.vui_written > 0)
+			vio->u.readwrite.vui_written >>= 1;
+			if (vio->u.readwrite.vui_written > 0)
 				io->ci_need_restart = 1;
 		}
-		if (vio->u.write.vui_written > 0) {
-			result = vio->u.write.vui_written;
+		if (vio->u.readwrite.vui_written > 0) {
+			result = vio->u.readwrite.vui_written;
 			io->ci_nob += result;
-
-			CDEBUG(D_VFSTRACE, "write: nob %zd, result: %zd\n",
+			CDEBUG(D_VFSTRACE, "%s: write: nob %zd, result: %zd\n",
+			       file_dentry(file)->d_name.name,
 			       io->ci_nob, result);
 		} else {
 			io->ci_continue = 0;
@@ -1215,11 +1232,18 @@ static int vvp_io_write_start(const struct lu_env *env,
 	if (result > 0 || result == -EIOCBQUEUED) {
 		set_bit(LLIF_DATA_MODIFIED, &(ll_i2info(inode))->lli_flags);
 
-		if (result < cnt)
+		if (result != -EIOCBQUEUED && result < cnt)
 			io->ci_continue = 0;
 		if (result > 0)
 			result = 0;
+		/* move forward */
+		if (result == -EIOCBQUEUED) {
+			io->ci_nob += vio->u.readwrite.vui_written;
+			vio->vui_iocb->ki_pos = pos +
+						vio->u.readwrite.vui_written;
+		}
 	}
+
 	return result;
 }
 
@@ -1509,6 +1533,7 @@ static int vvp_io_read_ahead(const struct lu_env *env,
 	.op = {
 		[CIT_READ] = {
 			.cio_fini	= vvp_io_fini,
+			.cio_iter_init	= vvp_io_read_iter_init,
 			.cio_lock	= vvp_io_read_lock,
 			.cio_start	= vvp_io_read_start,
 			.cio_end	= vvp_io_rw_end,
diff --git a/fs/lustre/obdclass/cl_io.c b/fs/lustre/obdclass/cl_io.c
index dcf940f..1564d9f 100644
--- a/fs/lustre/obdclass/cl_io.c
+++ b/fs/lustre/obdclass/cl_io.c
@@ -695,6 +695,7 @@ int cl_io_submit_sync(const struct lu_env *env, struct cl_io *io,
 int cl_io_loop(const struct lu_env *env, struct cl_io *io)
 {
 	int result = 0;
+	int rc = 0;
 
 	LINVRNT(cl_io_is_loopable(io));
 
@@ -727,7 +728,13 @@ int cl_io_loop(const struct lu_env *env, struct cl_io *io)
 			}
 		}
 		cl_io_iter_fini(env, io);
-	} while (result == 0 && io->ci_continue);
+		if (result)
+			rc = result;
+	} while ((result == 0 || result == -EIOCBQUEUED) &&
+		 io->ci_continue);
+
+	if (rc && !result)
+		result = rc;
 
 	if (result == -EWOULDBLOCK && io->ci_ndelay) {
 		io->ci_need_restart = 1;
-- 
1.8.3.1
