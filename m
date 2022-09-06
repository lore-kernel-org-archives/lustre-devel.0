Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id A158BECAAD3
	for <lustre-devel@archiver.kernel.org>; Tue,  6 Sep 2022 01:55:59 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4MM7lL6wkVz1yBf;
	Mon,  5 Sep 2022 18:55:58 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4MM7l96fnPz1y80
 for <lustre-devel@lists.lustre.org>; Mon,  5 Sep 2022 18:55:49 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id C4CAA100B006;
 Mon,  5 Sep 2022 21:55:39 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id C0E2D589A1; Mon,  5 Sep 2022 21:55:39 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon,  5 Sep 2022 21:55:25 -0400
Message-Id: <1662429337-18737-13-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1662429337-18737-1-git-send-email-jsimmons@infradead.org>
References: <1662429337-18737-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 12/24] lustre: llite: Rework upper/lower
 DIO/AIO
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

From: Patrick Farrell <pfarrell@whamcloud.com>

One of the patches for LU-13799,
"Implement lower/upper aio"
(https://review.whamcloud.com/44209/) created a
complicated setup where the cl_dio_aio struct was used
both for the top level DIO or AIO and for the lower level
sub I/Os (corresponding to stripes).

This is quite complicated and hard to follow, so this
rewrites these two uses to be separate structs.  This
incidentally fixes at least one possible memory leak, but
is mostly a cleanup.

Fixes: c51105d64c ("lustre: llite: Implement lower/upper aio")
WC-bug-id: https://jira.whamcloud.com/browse/LU-15811
Lustre-commit: 51c18539338f1a23f ("LU-15811 llite: Rework upper/lower DIO/AIO")
Signed-off-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/47187
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Yingjin Qian <qian@ddn.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/cl_object.h    |  41 ++++++++-----
 fs/lustre/llite/file.c           |  37 ++++++-----
 fs/lustre/llite/rw26.c           |  83 +++++++++++++------------
 fs/lustre/obdclass/cl_internal.h |   1 +
 fs/lustre/obdclass/cl_io.c       | 129 ++++++++++++++++++++++-----------------
 fs/lustre/obdclass/cl_object.c   |   6 ++
 6 files changed, 175 insertions(+), 122 deletions(-)

diff --git a/fs/lustre/include/cl_object.h b/fs/lustre/include/cl_object.h
index c717d03..0f28cfe 100644
--- a/fs/lustre/include/cl_object.h
+++ b/fs/lustre/include/cl_object.h
@@ -1788,8 +1788,8 @@ struct cl_io {
 	enum cl_io_state	ci_state;
 	/** main object this io is against. Immutable after creation. */
 	struct cl_object	*ci_obj;
-	/** one AIO request might be split in cl_io_loop */
-	struct cl_dio_aio	*ci_aio;
+	/** top level dio_aio */
+	struct cl_dio_aio	*ci_dio_aio;
 	/**
 	 * Upper layer io, of which this io is a part of. Immutable after
 	 * creation.
@@ -2532,11 +2532,12 @@ void cl_req_attr_set(const struct lu_env *env, struct cl_object *obj,
 
 struct cl_sync_io;
 struct cl_dio_aio;
+struct cl_sub_dio;
 
 typedef void (cl_sync_io_end_t)(const struct lu_env *, struct cl_sync_io *);
 
-void cl_sync_io_init_notify(struct cl_sync_io *anchor, int nr,
-			    struct cl_dio_aio *aio, cl_sync_io_end_t *end);
+void cl_sync_io_init_notify(struct cl_sync_io *anchor, int nr, void *dio_aio,
+			    cl_sync_io_end_t *end);
 
 int cl_sync_io_wait(const struct lu_env *env, struct cl_sync_io *anchor,
 		    long timeout);
@@ -2544,9 +2545,12 @@ void cl_sync_io_note(const struct lu_env *env, struct cl_sync_io *anchor,
 		     int ioret);
 int cl_sync_io_wait_recycle(const struct lu_env *env, struct cl_sync_io *anchor,
 			    long timeout, int ioret);
-struct cl_dio_aio *cl_aio_alloc(struct kiocb *iocb, struct cl_object *obj,
-				struct cl_dio_aio *ll_aio);
-void cl_aio_free(const struct lu_env *env, struct cl_dio_aio *aio);
+struct cl_dio_aio *cl_dio_aio_alloc(struct kiocb *iocb, struct cl_object *obj,
+				    bool is_aio);
+struct cl_sub_dio *cl_sub_dio_alloc(struct cl_dio_aio *ll_aio, bool nofree);
+void cl_dio_aio_free(const struct lu_env *env, struct cl_dio_aio *aio,
+		     bool always_free);
+void cl_sub_dio_free(struct cl_sub_dio *sdio, bool nofree);
 
 static inline void cl_sync_io_init(struct cl_sync_io *anchor, int nr)
 {
@@ -2568,8 +2572,8 @@ struct cl_sync_io {
 	wait_queue_head_t	csi_waitq;
 	/** callback to invoke when this IO is finished */
 	cl_sync_io_end_t	*csi_end_io;
-	/** aio private data */
-	struct cl_dio_aio	*csi_aio;
+	/* private pointer for an associated DIO/AIO */
+	void			*csi_dio_aio;
 };
 
 
@@ -2587,17 +2591,26 @@ struct ll_dio_pages {
 	loff_t			ldp_file_offset;
 };
 
-/* To support Direct AIO */
+/* Top level struct used for AIO and DIO */
 struct cl_dio_aio {
 	struct cl_sync_io	cda_sync;
-	struct cl_page_list	cda_pages;
 	struct cl_object	*cda_obj;
 	struct kiocb		*cda_iocb;
 	ssize_t			cda_bytes;
-	struct cl_dio_aio	*cda_ll_aio;
-	struct ll_dio_pages	cda_dio_pages;
 	unsigned int		cda_no_aio_complete:1,
-				cda_no_aio_free:1;
+				cda_no_sub_free:1;
+};
+
+/* Sub-dio used for splitting DIO (and AIO, because AIO is DIO) according to
+ * the layout/striping, so we can do parallel submit of DIO RPCs
+ */
+struct cl_sub_dio {
+	struct cl_sync_io	csd_sync;
+	struct cl_page_list	csd_pages;
+	ssize_t			csd_bytes;
+	struct cl_dio_aio	*csd_ll_aio;
+	struct ll_dio_pages	csd_dio_pages;
+	unsigned int		csd_no_free:1;
 };
 
 void ll_release_user_pages(struct page **pages, int npages);
diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index ac20d05..92e450f 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -1664,7 +1664,7 @@ static void ll_heat_add(struct inode *inode, enum cl_io_type iot,
 	unsigned int dio_lock = 0;
 	bool is_aio = false;
 	bool is_parallel_dio = false;
-	struct cl_dio_aio *ci_aio = NULL;
+	struct cl_dio_aio *ci_dio_aio = NULL;
 	size_t per_bytes;
 	bool partial_io = false;
 	size_t max_io_pages, max_cached_pages;
@@ -1694,9 +1694,10 @@ static void ll_heat_add(struct inode *inode, enum cl_io_type iot,
 		if (!ll_sbi_has_parallel_dio(sbi))
 			is_parallel_dio = false;
 
-		ci_aio = cl_aio_alloc(args->u.normal.via_iocb,
-				      ll_i2info(inode)->lli_clob, NULL);
-		if (!ci_aio) {
+		ci_dio_aio = cl_dio_aio_alloc(args->u.normal.via_iocb,
+					      ll_i2info(inode)->lli_clob,
+					      is_aio);
+		if (!ci_dio_aio) {
 			rc = -ENOMEM;
 			goto out;
 		}
@@ -1715,7 +1716,7 @@ static void ll_heat_add(struct inode *inode, enum cl_io_type iot,
 	partial_io = per_bytes < count;
 	io = vvp_env_thread_io(env);
 	ll_io_init(io, file, iot == CIT_WRITE, args);
-	io->ci_aio = ci_aio;
+	io->ci_dio_aio = ci_dio_aio;
 	io->ci_dio_lock = dio_lock;
 	io->ci_ndelay_tried = retried;
 	io->ci_parallel_dio = is_parallel_dio;
@@ -1762,12 +1763,8 @@ static void ll_heat_add(struct inode *inode, enum cl_io_type iot,
 		rc = io->ci_result;
 	}
 
-	/* N/B: parallel DIO may be disabled during i/o submission;
-	 * if that occurs, async RPCs are resolved before we get here, and this
-	 * wait call completes immediately.
-	 */
 	if (is_parallel_dio) {
-		struct cl_sync_io *anchor = &io->ci_aio->cda_sync;
+		struct cl_sync_io *anchor = &io->ci_dio_aio->cda_sync;
 
 		/* for dio, EIOCBQUEUED is an implementation detail,
 		 * and we don't return it to userspace
@@ -1775,6 +1772,11 @@ static void ll_heat_add(struct inode *inode, enum cl_io_type iot,
 		if (rc == -EIOCBQUEUED)
 			rc = 0;
 
+		/* N/B: parallel DIO may be disabled during i/o submission;
+		 * if that occurs, I/O shifts to sync, so it's all resolved
+		 * before we get here, and this wait call completes
+		 * immediately.
+		 */
 		rc2 = cl_sync_io_wait_recycle(env, anchor, 0, 0);
 		if (rc2 < 0)
 			rc = rc2;
@@ -1838,24 +1840,29 @@ static void ll_heat_add(struct inode *inode, enum cl_io_type iot,
 		goto restart;
 	}
 
-	if (io->ci_aio) {
+	if (io->ci_dio_aio) {
 		/*
 		 * VFS will call aio_complete() if no -EIOCBQUEUED
 		 * is returned for AIO, so we can not call aio_complete()
 		 * in our end_io().
+		 *
+		 * NB: This is safe because the atomic_dec_and_lock  in
+		 * cl_sync_io_init has implicit memory barriers, so this will
+		 * be seen by whichever thread completes the DIO/AIO, even if
+		 * it's not this one
 		 */
 		if (rc != -EIOCBQUEUED)
-			io->ci_aio->cda_no_aio_complete = 1;
+			io->ci_dio_aio->cda_no_aio_complete = 1;
 		/**
 		 * Drop one extra reference so that end_io() could be
 		 * called for this IO context, we could call it after
 		 * we make sure all AIO requests have been proceed.
 		 */
-		cl_sync_io_note(env, &io->ci_aio->cda_sync,
+		cl_sync_io_note(env, &io->ci_dio_aio->cda_sync,
 				rc == -EIOCBQUEUED ? 0 : rc);
 		if (!is_aio) {
-			cl_aio_free(env, io->ci_aio);
-			io->ci_aio = NULL;
+			cl_dio_aio_free(env, io->ci_dio_aio, true);
+			io->ci_dio_aio = NULL;
 		}
 	}
 
diff --git a/fs/lustre/llite/rw26.c b/fs/lustre/llite/rw26.c
index 7147f0f..0f9ab68 100644
--- a/fs/lustre/llite/rw26.c
+++ b/fs/lustre/llite/rw26.c
@@ -202,13 +202,13 @@ static unsigned long ll_iov_iter_alignment(struct iov_iter *i)
 
 static int
 ll_direct_rw_pages(const struct lu_env *env, struct cl_io *io, size_t size,
-		   int rw, struct inode *inode, struct cl_dio_aio *aio)
+		   int rw, struct inode *inode, struct cl_sub_dio *sdio)
 {
-	struct ll_dio_pages *pv = &aio->cda_dio_pages;
+	struct ll_dio_pages *pv = &sdio->csd_dio_pages;
 	struct cl_page *page;
 	struct cl_2queue *queue = &io->ci_queue;
 	struct cl_object *obj = io->ci_obj;
-	struct cl_sync_io *anchor = &aio->cda_sync;
+	struct cl_sync_io *anchor = &sdio->csd_sync;
 	loff_t offset = pv->ldp_file_offset;
 	int io_pages = 0;
 	size_t page_size = cl_page_size(obj);
@@ -268,7 +268,7 @@ static unsigned long ll_iov_iter_alignment(struct iov_iter *i)
 		smp_mb();
 		rc = cl_io_submit_rw(env, io, iot, queue);
 		if (rc == 0) {
-			cl_page_list_splice(&queue->c2_qout, &aio->cda_pages);
+			cl_page_list_splice(&queue->c2_qout, &sdio->csd_pages);
 		} else {
 			atomic_add(-queue->c2_qin.pl_nr,
 				   &anchor->csi_sync_nr);
@@ -307,13 +307,15 @@ static ssize_t ll_direct_IO(struct kiocb *iocb, struct iov_iter *iter)
 	struct cl_io *io;
 	struct file *file = iocb->ki_filp;
 	struct inode *inode = file->f_mapping->host;
-	struct cl_dio_aio *ll_aio;
-	struct cl_dio_aio *ldp_aio;
+	struct cl_dio_aio *ll_dio_aio;
+	struct cl_sub_dio *ldp_aio;
 	size_t count = iov_iter_count(iter);
 	ssize_t tot_bytes = 0, result = 0;
 	loff_t file_offset = iocb->ki_pos;
 	int rw = iov_iter_rw(iter);
+	bool sync_submit = false;
 	struct vvp_io *vio;
+	ssize_t rc2;
 
 	/* Check EOF by ourselves */
 	if (rw == READ && file_offset >= i_size_read(inode))
@@ -343,9 +345,22 @@ static ssize_t ll_direct_IO(struct kiocb *iocb, struct iov_iter *iter)
 	io = lcc->lcc_io;
 	LASSERT(io);
 
-	ll_aio = io->ci_aio;
-	LASSERT(ll_aio);
-	LASSERT(ll_aio->cda_iocb == iocb);
+	ll_dio_aio = io->ci_dio_aio;
+	LASSERT(ll_dio_aio);
+	LASSERT(ll_dio_aio->cda_iocb == iocb);
+
+	/* We cannot do parallel submission of sub-I/Os - for AIO or regular
+	 * DIO - unless lockless because it causes us to release the lock
+	 * early.
+	 *
+	 * There are also several circumstances in which we must disable
+	 * parallel DIO, so we check if it is enabled.
+	 *
+	 * The check for "is_sync_kiocb" excludes AIO, which does not need to
+	 * be disabled in these situations.
+	 */
+	if (io->ci_dio_lock || (is_sync_kiocb(iocb) && !io->ci_parallel_dio))
+		sync_submit = true;
 
 	while (iov_iter_count(iter)) {
 		struct ll_dio_pages *pvec;
@@ -360,22 +375,24 @@ static ssize_t ll_direct_IO(struct kiocb *iocb, struct iov_iter *iter)
 				count = i_size_read(inode) - file_offset;
 		}
 
-		/* this aio is freed on completion from cl_sync_io_note, so we
-		 * do not need to directly free the memory here
+		/* if we are doing sync_submit, then we free this below,
+		 * otherwise it is freed on the final call to cl_sync_io_note
+		 * (either in this function or from a ptlrpcd daemon)
 		 */
-		ldp_aio = cl_aio_alloc(iocb, ll_i2info(inode)->lli_clob,
-				       ll_aio);
+		ldp_aio = cl_sub_dio_alloc(ll_dio_aio, sync_submit);
 		if (!ldp_aio) {
 			result = -ENOMEM;
 			goto out;
 		}
 
-		pvec = &ldp_aio->cda_dio_pages;
+		pvec = &ldp_aio->csd_dio_pages;
 
 		result = ll_get_user_pages(rw, iter, &pages,
 					   &pvec->ldp_count, count);
 		if (unlikely(result <= 0)) {
-			cl_sync_io_note(env, &ldp_aio->cda_sync, result);
+			cl_sync_io_note(env, &ldp_aio->csd_sync, result);
+			if (sync_submit)
+				cl_sub_dio_free(ldp_aio, true);
 			goto out;
 		}
 
@@ -388,8 +405,15 @@ static ssize_t ll_direct_IO(struct kiocb *iocb, struct iov_iter *iter)
 		/* We've submitted pages and can now remove the extra
 		 * reference for that
 		 */
-		cl_sync_io_note(env, &ldp_aio->cda_sync, result);
-
+		cl_sync_io_note(env, &ldp_aio->csd_sync, result);
+
+		if (sync_submit) {
+			rc2 = cl_sync_io_wait(env, &ldp_aio->csd_sync,
+					     0);
+			if (result == 0 && rc2)
+				result = rc2;
+			cl_sub_dio_free(ldp_aio, true);
+		}
 		if (unlikely(result < 0))
 			goto out;
 
@@ -399,35 +423,18 @@ static ssize_t ll_direct_IO(struct kiocb *iocb, struct iov_iter *iter)
 	}
 
 out:
-	ll_aio->cda_bytes += tot_bytes;
+	ll_dio_aio->cda_bytes += tot_bytes;
 
 	if (rw == WRITE)
 		vio->u.readwrite.vui_written += tot_bytes;
 	else
 		vio->u.readwrite.vui_read += tot_bytes;
 
-	/* We cannot do async submission - for AIO or regular DIO - unless
-	 * lockless because it causes us to release the lock early.
-	 *
-	 * There are also several circumstances in which we must disable
-	 * parallel DIO, so we check if it is enabled.
-	 *
-	 * The check for "is_sync_kiocb" excludes AIO, which does not need to
-	 * be disabled in these situations.
+	/* AIO is not supported on pipes, so we cannot return EIOCBQEUED like
+	 * we normally would for both DIO and AIO here
 	 */
-	if (io->ci_dio_lock || (is_sync_kiocb(iocb) && !io->ci_parallel_dio)) {
-		ssize_t rc2;
-
-		/* Wait here rather than doing async submission */
-		rc2 = cl_sync_io_wait_recycle(env, &ll_aio->cda_sync, 0, 0);
-		if (result == 0 && rc2)
-			result = rc2;
-
-		if (result == 0)
-			result = tot_bytes;
-	} else if (result == 0) {
+	if (result == 0 && !iov_iter_is_pipe(iter))
 		result = -EIOCBQUEUED;
-	}
 
 	return result;
 }
diff --git a/fs/lustre/obdclass/cl_internal.h b/fs/lustre/obdclass/cl_internal.h
index db9dd98..eb3d81a 100644
--- a/fs/lustre/obdclass/cl_internal.h
+++ b/fs/lustre/obdclass/cl_internal.h
@@ -47,6 +47,7 @@ struct cl_thread_info {
 };
 
 extern struct kmem_cache *cl_dio_aio_kmem;
+extern struct kmem_cache *cl_sub_dio_kmem;
 extern struct kmem_cache *cl_page_kmem_array[16];
 extern unsigned short cl_page_kmem_size_array[16];
 
diff --git a/fs/lustre/obdclass/cl_io.c b/fs/lustre/obdclass/cl_io.c
index c388700..06b9eb8 100644
--- a/fs/lustre/obdclass/cl_io.c
+++ b/fs/lustre/obdclass/cl_io.c
@@ -1072,14 +1072,14 @@ void cl_req_attr_set(const struct lu_env *env, struct cl_object *obj,
  *		anchor->csi_waitq.lock
  */
 void cl_sync_io_init_notify(struct cl_sync_io *anchor, int nr,
-			    struct cl_dio_aio *aio, cl_sync_io_end_t *end)
+			    void *dio_aio, cl_sync_io_end_t *end)
 {
 	memset(anchor, 0, sizeof(*anchor));
 	init_waitqueue_head(&anchor->csi_waitq);
 	atomic_set(&anchor->csi_sync_nr, nr);
 	anchor->csi_sync_rc = 0;
 	anchor->csi_end_io = end;
-	anchor->csi_aio = aio;
+	anchor->csi_dio_aio = dio_aio;
 }
 EXPORT_SYMBOL(cl_sync_io_init_notify);
 
@@ -1117,32 +1117,37 @@ int cl_sync_io_wait(const struct lu_env *env, struct cl_sync_io *anchor,
 }
 EXPORT_SYMBOL(cl_sync_io_wait);
 
-static void cl_aio_end(const struct lu_env *env, struct cl_sync_io *anchor)
+static void cl_dio_aio_end(const struct lu_env *env, struct cl_sync_io *anchor)
 {
 	struct cl_dio_aio *aio = container_of(anchor, typeof(*aio), cda_sync);
 	ssize_t ret = anchor->csi_sync_rc;
 
+	if (!aio->cda_no_aio_complete) {
+		aio->cda_iocb->ki_complete(aio->cda_iocb, ret ?: aio->cda_bytes,
+					   0);
+	}
+}
+
+static void cl_sub_dio_end(const struct lu_env *env, struct cl_sync_io *anchor)
+{
+	struct cl_sub_dio *sdio = container_of(anchor, typeof(*sdio), csd_sync);
+	ssize_t ret = anchor->csi_sync_rc;
+
 	/* release pages */
-	while (aio->cda_pages.pl_nr > 0) {
-		struct cl_page *page = cl_page_list_first(&aio->cda_pages);
+	while (sdio->csd_pages.pl_nr > 0) {
+		struct cl_page *page = cl_page_list_first(&sdio->csd_pages);
 
 		cl_page_delete(env, page);
-		cl_page_list_del(env, &aio->cda_pages, page);
+		cl_page_list_del(env, &sdio->csd_pages, page);
 	}
 
-	if (!aio->cda_no_aio_complete)
-		aio->cda_iocb->ki_complete(aio->cda_iocb,
-					   ret ?: aio->cda_bytes, 0);
-
-	if (aio->cda_ll_aio) {
-		ll_release_user_pages(aio->cda_dio_pages.ldp_pages,
-				      aio->cda_dio_pages.ldp_count);
-		cl_sync_io_note(env, &aio->cda_ll_aio->cda_sync, ret);
-	}
+	ll_release_user_pages(sdio->csd_dio_pages.ldp_pages,
+			      sdio->csd_dio_pages.ldp_count);
+	cl_sync_io_note(env, &sdio->csd_ll_aio->cda_sync, ret);
 }
 
-struct cl_dio_aio *cl_aio_alloc(struct kiocb *iocb, struct cl_object *obj,
-				struct cl_dio_aio *ll_aio)
+struct cl_dio_aio *cl_dio_aio_alloc(struct kiocb *iocb, struct cl_object *obj,
+				    bool is_aio)
 {
 	struct cl_dio_aio *aio;
 
@@ -1152,46 +1157,63 @@ struct cl_dio_aio *cl_aio_alloc(struct kiocb *iocb, struct cl_object *obj,
 		 * Hold one ref so that it won't be released until
 		 * every pages is added.
 		 */
-		cl_sync_io_init_notify(&aio->cda_sync, 1, aio, cl_aio_end);
-		cl_page_list_init(&aio->cda_pages);
+		cl_sync_io_init_notify(&aio->cda_sync, 1, aio, cl_dio_aio_end);
 		aio->cda_iocb = iocb;
-		if (is_sync_kiocb(iocb) || ll_aio)
-			aio->cda_no_aio_complete = 1;
-		else
-			aio->cda_no_aio_complete = 0;
-		/* in the case of a lower level aio struct (ll_aio is set), or
-		 * true AIO (!is_sync_kiocb()), the memory is freed by
-		 * the daemons calling cl_sync_io_note, because they are the
-		 * last users of the aio struct
+		aio->cda_no_aio_complete = !is_aio;
+		/* if this is true AIO, the memory is freed by the last call
+		 * to cl_sync_io_note (when all the I/O is complete), because
+		 * no one is waiting (in the kernel) for this to complete
 		 *
 		 * in other cases, the last user is cl_sync_io_wait, and in
-		 * that case, the caller frees the aio struct after that call
-		 * completes
+		 * that case, the caller frees the struct after that call
 		 */
-		if (ll_aio || !is_sync_kiocb(iocb))
-			aio->cda_no_aio_free = 0;
-		else
-			aio->cda_no_aio_free = 1;
+		aio->cda_no_sub_free = !is_aio;
 
 		cl_object_get(obj);
 		aio->cda_obj = obj;
-		aio->cda_ll_aio = ll_aio;
-
-		if (ll_aio)
-			atomic_add(1,  &ll_aio->cda_sync.csi_sync_nr);
 	}
 	return aio;
 }
-EXPORT_SYMBOL(cl_aio_alloc);
+EXPORT_SYMBOL(cl_dio_aio_alloc);
 
-void cl_aio_free(const struct lu_env *env, struct cl_dio_aio *aio)
+struct cl_sub_dio *cl_sub_dio_alloc(struct cl_dio_aio *ll_aio, bool nofree)
 {
-	if (aio) {
+	struct cl_sub_dio *sdio;
+
+	sdio = kmem_cache_zalloc(cl_sub_dio_kmem, GFP_NOFS);
+	if (sdio) {
+		/*
+		 * Hold one ref so that it won't be released until
+		 * every pages is added.
+		 */
+		cl_sync_io_init_notify(&sdio->csd_sync, 1, sdio,
+				       cl_sub_dio_end);
+		cl_page_list_init(&sdio->csd_pages);
+
+		sdio->csd_ll_aio = ll_aio;
+		atomic_add(1,  &ll_aio->cda_sync.csi_sync_nr);
+		sdio->csd_no_free = nofree;
+	}
+	return sdio;
+}
+EXPORT_SYMBOL(cl_sub_dio_alloc);
+
+void cl_dio_aio_free(const struct lu_env *env, struct cl_dio_aio *aio,
+		     bool always_free)
+{
+	if (aio && (!aio->cda_no_sub_free || always_free)) {
 		cl_object_put(env, aio->cda_obj);
 		kmem_cache_free(cl_dio_aio_kmem, aio);
 	}
 }
-EXPORT_SYMBOL(cl_aio_free);
+EXPORT_SYMBOL(cl_dio_aio_free);
+
+void cl_sub_dio_free(struct cl_sub_dio *sdio, bool always_free)
+{
+	if (sdio && (!sdio->csd_no_free || always_free))
+		kmem_cache_free(cl_sub_dio_kmem, sdio);
+}
+EXPORT_SYMBOL(cl_sub_dio_free);
 
 /*
  * ll_release_user_pages - tear down page struct array
@@ -1225,7 +1247,7 @@ void cl_sync_io_note(const struct lu_env *env, struct cl_sync_io *anchor,
 	LASSERT(atomic_read(&anchor->csi_sync_nr) > 0);
 	if (atomic_dec_and_lock(&anchor->csi_sync_nr,
 				&anchor->csi_waitq.lock)) {
-		struct cl_dio_aio *aio = NULL;
+		void *dio_aio = NULL;
 
 		cl_sync_io_end_t *end_io = anchor->csi_end_io;
 
@@ -1238,29 +1260,28 @@ void cl_sync_io_note(const struct lu_env *env, struct cl_sync_io *anchor,
 		if (end_io)
 			end_io(env, anchor);
 
-		aio = anchor->csi_aio;
+		dio_aio = anchor->csi_dio_aio;
 
 		spin_unlock(&anchor->csi_waitq.lock);
 
-		if (aio && !aio->cda_no_aio_free)
-			cl_aio_free(env, aio);
+		if (dio_aio) {
+			if (end_io == cl_dio_aio_end)
+				cl_dio_aio_free(env,
+						(struct cl_dio_aio *) dio_aio,
+						false);
+			else if (end_io == cl_sub_dio_end)
+				cl_sub_dio_free((struct cl_sub_dio *) dio_aio,
+						false);
+		}
 	}
 }
 EXPORT_SYMBOL(cl_sync_io_note);
 
-
 int cl_sync_io_wait_recycle(const struct lu_env *env, struct cl_sync_io *anchor,
 			    long timeout, int ioret)
 {
-	bool no_aio_free = anchor->csi_aio->cda_no_aio_free;
 	int rc = 0;
 
-	/* for true AIO, the daemons running cl_sync_io_note would normally
-	 * free the aio struct, but if we're waiting on it, we need them to not
-	 * do that.  This ensures the aio is not freed when we drop the
-	 * reference count to zero in cl_sync_io_note below
-	 */
-	anchor->csi_aio->cda_no_aio_free = 1;
 	/*
 	 * @anchor was inited as 1 to prevent end_io to be
 	 * called before we add all pages for IO, so drop
@@ -1280,8 +1301,6 @@ int cl_sync_io_wait_recycle(const struct lu_env *env, struct cl_sync_io *anchor,
 	 */
 	atomic_add(1, &anchor->csi_sync_nr);
 
-	anchor->csi_aio->cda_no_aio_free = no_aio_free;
-
 	return rc;
 }
 EXPORT_SYMBOL(cl_sync_io_wait_recycle);
diff --git a/fs/lustre/obdclass/cl_object.c b/fs/lustre/obdclass/cl_object.c
index 6f87160..28bf1e4 100644
--- a/fs/lustre/obdclass/cl_object.c
+++ b/fs/lustre/obdclass/cl_object.c
@@ -57,6 +57,7 @@
 
 static struct kmem_cache *cl_env_kmem;
 struct kmem_cache *cl_dio_aio_kmem;
+struct kmem_cache *cl_sub_dio_kmem;
 struct kmem_cache *cl_page_kmem_array[16];
 unsigned short cl_page_kmem_size_array[16];
 
@@ -989,6 +990,11 @@ struct cl_thread_info *cl_env_info(const struct lu_env *env)
 		.ckd_size  = sizeof(struct cl_dio_aio)
 	},
 	{
+		.ckd_cache = &cl_sub_dio_kmem,
+		.ckd_name  = "cl_sub_dio_kmem",
+		.ckd_size  = sizeof(struct cl_sub_dio)
+	},
+	{
 		.ckd_cache = NULL
 	}
 };
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
