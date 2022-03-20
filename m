Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 64704C433F5
	for <lustre-devel@archiver.kernel.org>; Sun, 20 Mar 2022 13:33:42 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 6AFEB21FA65;
	Sun, 20 Mar 2022 06:32:33 -0700 (PDT)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 775E221F157
 for <lustre-devel@lists.lustre.org>; Sun, 20 Mar 2022 06:31:17 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 51002EF4;
 Sun, 20 Mar 2022 09:31:08 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 4D552AB; Sun, 20 Mar 2022 09:31:08 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 20 Mar 2022 09:30:43 -0400
Message-Id: <1647783064-20688-30-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1647783064-20688-1-git-send-email-jsimmons@infradead.org>
References: <1647783064-20688-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 29/50] lustre: llite: Move free user pages
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
Cc: Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Patrick Farrell <pfarrell@whamcloud.com>

It is incorrect to release our reference on the user pages
before we're done with them - We need to keep it until the
i/o is complete, otherwise we access them after releasing
our reference.  This has not caused any known bugs so far,
but it's still wrong.

So only drop these references when we free the aio struct,
which is only freed once i/o is complete.

Also rename free_user_pages to release_user_pages, because
it does not free them - it just releases our reference.

This also helps performance by moving free_user_pages to
the daemon threads.  This is a 5-10% boost.

This patch reduces i/o time in ms/GiB by:
Write: 18 ms/GiB
ead: 19 ms/GiB

Totals:
Write: 180 ms/GiB
Read: 178 ms/GiB

mpirun -np 1  $IOR -w -r -t 64M -b 64G -o ./iorfile --posix.odirect

With previous patches in series:
write           5183 MiB/s
read            5201 MiB/s

Plus this patch:
write           5702 MiB/s
read            5756 MiB/s

WC-bug-id: https://jira.whamcloud.com/browse/LU-13799
Lustre-commit: 7f9b8465bc1125e51 ("LU-13799 llite: Move free user pages")
Signed-off-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/39443
Reviewed-by: Yingjin Qian <qian@ddn.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/cl_object.h | 18 +++++++++++++++
 fs/lustre/llite/rw26.c        | 52 +++++++++----------------------------------
 fs/lustre/obdclass/cl_io.c    | 21 ++++++++++++++++-
 3 files changed, 49 insertions(+), 42 deletions(-)

diff --git a/fs/lustre/include/cl_object.h b/fs/lustre/include/cl_object.h
index 9815b19..af708cc 100644
--- a/fs/lustre/include/cl_object.h
+++ b/fs/lustre/include/cl_object.h
@@ -2620,6 +2620,21 @@ struct cl_sync_io {
 	struct cl_dio_aio	*csi_aio;
 };
 
+
+/* direct IO pages */
+struct ll_dio_pages {
+	struct cl_dio_aio	*ldp_aio;
+	/*
+	 * page array to be written. we don't support
+	 * partial pages except the last one.
+	 */
+	struct page		**ldp_pages;
+	/* # of pages in the array. */
+	size_t			ldp_count;
+	/* the file offset of the first page. */
+	loff_t			ldp_file_offset;
+};
+
 /* To support Direct AIO */
 struct cl_dio_aio {
 	struct cl_sync_io	cda_sync;
@@ -2628,10 +2643,13 @@ struct cl_dio_aio {
 	struct kiocb		*cda_iocb;
 	ssize_t			cda_bytes;
 	struct cl_dio_aio	*cda_ll_aio;
+	struct ll_dio_pages	cda_dio_pages;
 	unsigned int		cda_no_aio_complete:1,
 				cda_no_aio_free:1;
 };
 
+void ll_release_user_pages(struct page **pages, int npages);
+
 /** @} cl_sync_io */
 
 /** \defgroup cl_env cl_env
diff --git a/fs/lustre/llite/rw26.c b/fs/lustre/llite/rw26.c
index 16cccfa..a5cdb01 100644
--- a/fs/lustre/llite/rw26.c
+++ b/fs/lustre/llite/rw26.c
@@ -150,22 +150,6 @@ static int ll_releasepage(struct page *vmpage, gfp_t gfp_mask)
 	return result;
 }
 
-/*
- * ll_free_user_pages - tear down page struct array
- * @pages: array of page struct pointers underlying target buffer
- */
-static void ll_free_user_pages(struct page **pages, int npages)
-{
-	int i;
-
-	for (i = 0; i < npages; i++) {
-		if (!pages[i])
-			break;
-		put_page(pages[i]);
-	}
-	kvfree(pages);
-}
-
 static ssize_t ll_get_user_pages(int rw, struct iov_iter *iter,
 				struct page ***pages, ssize_t *npages,
 				size_t maxsize)
@@ -209,28 +193,15 @@ static unsigned long ll_iov_iter_alignment(struct iov_iter *i)
 	return res;
 }
 
-/* direct IO pages */
-struct ll_dio_pages {
-	struct cl_dio_aio	*ldp_aio;
-	/*
-	 * page array to be written. we don't support
-	 * partial pages except the last one.
-	 */
-	struct page		**ldp_pages;
-	/* # of pages in the array. */
-	size_t			ldp_count;
-	/* the file offset of the first page. */
-	loff_t			ldp_file_offset;
-};
-
 static int
 ll_direct_rw_pages(const struct lu_env *env, struct cl_io *io, size_t size,
-		   int rw, struct inode *inode, struct ll_dio_pages *pv)
+		   int rw, struct inode *inode, struct cl_dio_aio *aio)
 {
+	struct ll_dio_pages *pv = &aio->cda_dio_pages;
 	struct cl_page *page;
 	struct cl_2queue *queue = &io->ci_queue;
 	struct cl_object *obj = io->ci_obj;
-	struct cl_sync_io *anchor = &pv->ldp_aio->cda_sync;
+	struct cl_sync_io *anchor = &aio->cda_sync;
 	loff_t offset = pv->ldp_file_offset;
 	int io_pages = 0;
 	size_t page_size = cl_page_size(obj);
@@ -290,8 +261,7 @@ struct ll_dio_pages {
 		smp_mb();
 		rc = cl_io_submit_rw(env, io, iot, queue);
 		if (rc == 0) {
-			cl_page_list_splice(&queue->c2_qout,
-					&pv->ldp_aio->cda_pages);
+			cl_page_list_splice(&queue->c2_qout, &aio->cda_pages);
 		} else {
 			atomic_add(-queue->c2_qin.pl_nr,
 				   &anchor->csi_sync_nr);
@@ -371,7 +341,7 @@ static ssize_t ll_direct_IO(struct kiocb *iocb, struct iov_iter *iter)
 	LASSERT(ll_aio->cda_iocb == iocb);
 
 	while (iov_iter_count(iter)) {
-		struct ll_dio_pages pvec = {};
+		struct ll_dio_pages *pvec;
 		struct page **pages;
 
 		count = min_t(size_t, iov_iter_count(iter), MAX_DIO_SIZE);
@@ -392,26 +362,26 @@ static ssize_t ll_direct_IO(struct kiocb *iocb, struct iov_iter *iter)
 			result = -ENOMEM;
 			goto out;
 		}
-		pvec.ldp_aio = ldp_aio;
+
+		pvec = &ldp_aio->cda_dio_pages;
 
 		result = ll_get_user_pages(rw, iter, &pages,
-					   &pvec.ldp_count, count);
+					   &pvec->ldp_count, count);
 		if (unlikely(result <= 0)) {
 			cl_sync_io_note(env, &ldp_aio->cda_sync, result);
 			goto out;
 		}
 
 		count = result;
-		pvec.ldp_file_offset = file_offset;
-		pvec.ldp_pages = pages;
+		pvec->ldp_file_offset = file_offset;
+		pvec->ldp_pages = pages;
 
 		result = ll_direct_rw_pages(env, io, count,
-					    rw, inode, &pvec);
+					    rw, inode, ldp_aio);
 		/* We've submitted pages and can now remove the extra
 		 * reference for that
 		 */
 		cl_sync_io_note(env, &ldp_aio->cda_sync, result);
-		ll_free_user_pages(pages, pvec.ldp_count);
 
 		if (unlikely(result < 0))
 			goto out;
diff --git a/fs/lustre/obdclass/cl_io.c b/fs/lustre/obdclass/cl_io.c
index 038ab4c..e4fc795 100644
--- a/fs/lustre/obdclass/cl_io.c
+++ b/fs/lustre/obdclass/cl_io.c
@@ -1139,8 +1139,11 @@ static void cl_aio_end(const struct lu_env *env, struct cl_sync_io *anchor)
 		aio->cda_iocb->ki_complete(aio->cda_iocb,
 					   ret ?: aio->cda_bytes, 0);
 
-	if (aio->cda_ll_aio)
+	if (aio->cda_ll_aio) {
+		ll_release_user_pages(aio->cda_dio_pages.ldp_pages,
+				      aio->cda_dio_pages.ldp_count);
 		cl_sync_io_note(env, &aio->cda_ll_aio->cda_sync, ret);
+	}
 }
 
 struct cl_dio_aio *cl_aio_alloc(struct kiocb *iocb, struct cl_object *obj,
@@ -1195,6 +1198,22 @@ void cl_aio_free(const struct lu_env *env, struct cl_dio_aio *aio)
 }
 EXPORT_SYMBOL(cl_aio_free);
 
+/*
+ * ll_release_user_pages - tear down page struct array
+ * @pages: array of page struct pointers underlying target buffer
+ */
+void ll_release_user_pages(struct page **pages, int npages)
+{
+	int i;
+
+	for (i = 0; i < npages; i++) {
+		if (!pages[i])
+			break;
+		put_page(pages[i]);
+	}
+	kvfree(pages);
+}
+
 /**
  * Indicate that transfer of a single page completed.
  */
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
