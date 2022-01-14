Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 4B83AC433F5
	for <lustre-devel@archiver.kernel.org>; Fri, 14 Jan 2022 01:39:27 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 4D84E3AD9D2;
	Thu, 13 Jan 2022 17:38:53 -0800 (PST)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 476A921FFAD
 for <lustre-devel@lists.lustre.org>; Thu, 13 Jan 2022 17:38:13 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 0C261100F34E;
 Thu, 13 Jan 2022 20:38:05 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 0A15BA8103; Thu, 13 Jan 2022 20:38:05 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Thu, 13 Jan 2022 20:38:03 -0500
Message-Id: <1642124283-10148-25-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1642124283-10148-1-git-send-email-jsimmons@infradead.org>
References: <1642124283-10148-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 24/24] lustre: llite: Implement lower/upper
 aio
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

This patch creates a lower level aio struct for each set of
pages submitted, and attaches that to the llite level aio.

That means the completion of i/o (in the sense of
successful RPC/page completion) is associated with the
lower level aio struct, and the higher level aio waits for
the completion of these lower level structs.  Previously,
all pages were associated with the upper level (and only)
aio struct.

This patch is a reorganization/cleanup, which is necessary
for the next patch, which moves release pages to aio_end.
The justification for this (correctness and performance)
will be provided in that patch.

WC-bug-id: https://jira.whamcloud.com/browse/LU-13799
Lustre-commit: 46ff76137160b66f1 ("LU-13799 llite: Implement lower/upper aio")
Signed-off-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/44209
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Yingjin Qian <qian@ddn.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/cl_object.h |  7 +++++--
 fs/lustre/llite/file.c        |  2 +-
 fs/lustre/llite/rw26.c        | 34 +++++++++++++++++++++++++--------
 fs/lustre/obdclass/cl_io.c    | 44 +++++++++++++++++++++++++++++++++----------
 4 files changed, 66 insertions(+), 21 deletions(-)

diff --git a/fs/lustre/include/cl_object.h b/fs/lustre/include/cl_object.h
index 1746c4e..9815b19 100644
--- a/fs/lustre/include/cl_object.h
+++ b/fs/lustre/include/cl_object.h
@@ -2592,7 +2592,8 @@ void cl_sync_io_note(const struct lu_env *env, struct cl_sync_io *anchor,
 		     int ioret);
 int cl_sync_io_wait_recycle(const struct lu_env *env, struct cl_sync_io *anchor,
 			    long timeout, int ioret);
-struct cl_dio_aio *cl_aio_alloc(struct kiocb *iocb, struct cl_object *obj);
+struct cl_dio_aio *cl_aio_alloc(struct kiocb *iocb, struct cl_object *obj,
+				struct cl_dio_aio *ll_aio);
 void cl_aio_free(const struct lu_env *env, struct cl_dio_aio *aio);
 
 static inline void cl_sync_io_init(struct cl_sync_io *anchor, int nr)
@@ -2626,7 +2627,9 @@ struct cl_dio_aio {
 	struct cl_object	*cda_obj;
 	struct kiocb		*cda_iocb;
 	ssize_t			cda_bytes;
-	unsigned int		cda_no_aio_complete:1;
+	struct cl_dio_aio	*cda_ll_aio;
+	unsigned int		cda_no_aio_complete:1,
+				cda_no_aio_free:1;
 };
 
 /** @} cl_sync_io */
diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index d9b1457..6b95133 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -1684,7 +1684,7 @@ static void ll_heat_add(struct inode *inode, enum cl_io_type iot,
 			is_parallel_dio = false;
 
 		ci_aio = cl_aio_alloc(args->u.normal.via_iocb,
-				      ll_i2info(inode)->lli_clob);
+				      ll_i2info(inode)->lli_clob, NULL);
 		if (!ci_aio) {
 			rc = -ENOMEM;
 			goto out;
diff --git a/fs/lustre/llite/rw26.c b/fs/lustre/llite/rw26.c
index 4c2ab38..16cccfa 100644
--- a/fs/lustre/llite/rw26.c
+++ b/fs/lustre/llite/rw26.c
@@ -330,7 +330,8 @@ static ssize_t ll_direct_IO(struct kiocb *iocb, struct iov_iter *iter)
 	struct cl_io *io;
 	struct file *file = iocb->ki_filp;
 	struct inode *inode = file->f_mapping->host;
-	struct cl_dio_aio *aio;
+	struct cl_dio_aio *ll_aio;
+	struct cl_dio_aio *ldp_aio;
 	size_t count = iov_iter_count(iter);
 	ssize_t tot_bytes = 0, result = 0;
 	loff_t file_offset = iocb->ki_pos;
@@ -365,12 +366,12 @@ static ssize_t ll_direct_IO(struct kiocb *iocb, struct iov_iter *iter)
 	io = lcc->lcc_io;
 	LASSERT(io);
 
-	aio = io->ci_aio;
-	LASSERT(aio);
-	LASSERT(aio->cda_iocb == iocb);
+	ll_aio = io->ci_aio;
+	LASSERT(ll_aio);
+	LASSERT(ll_aio->cda_iocb == iocb);
 
 	while (iov_iter_count(iter)) {
-		struct ll_dio_pages pvec = { .ldp_aio = aio };
+		struct ll_dio_pages pvec = {};
 		struct page **pages;
 
 		count = min_t(size_t, iov_iter_count(iter), MAX_DIO_SIZE);
@@ -382,10 +383,23 @@ static ssize_t ll_direct_IO(struct kiocb *iocb, struct iov_iter *iter)
 				count = i_size_read(inode) - file_offset;
 		}
 
+		/* this aio is freed on completion from cl_sync_io_note, so we
+		 * do not need to directly free the memory here
+		 */
+		ldp_aio = cl_aio_alloc(iocb, ll_i2info(inode)->lli_clob,
+				       ll_aio);
+		if (!ldp_aio) {
+			result = -ENOMEM;
+			goto out;
+		}
+		pvec.ldp_aio = ldp_aio;
+
 		result = ll_get_user_pages(rw, iter, &pages,
 					   &pvec.ldp_count, count);
-		if (unlikely(result <= 0))
+		if (unlikely(result <= 0)) {
+			cl_sync_io_note(env, &ldp_aio->cda_sync, result);
 			goto out;
+		}
 
 		count = result;
 		pvec.ldp_file_offset = file_offset;
@@ -393,6 +407,10 @@ static ssize_t ll_direct_IO(struct kiocb *iocb, struct iov_iter *iter)
 
 		result = ll_direct_rw_pages(env, io, count,
 					    rw, inode, &pvec);
+		/* We've submitted pages and can now remove the extra
+		 * reference for that
+		 */
+		cl_sync_io_note(env, &ldp_aio->cda_sync, result);
 		ll_free_user_pages(pages, pvec.ldp_count);
 
 		if (unlikely(result < 0))
@@ -404,7 +422,7 @@ static ssize_t ll_direct_IO(struct kiocb *iocb, struct iov_iter *iter)
 	}
 
 out:
-	aio->cda_bytes += tot_bytes;
+	ll_aio->cda_bytes += tot_bytes;
 
 	if (rw == WRITE)
 		vio->u.readwrite.vui_written += tot_bytes;
@@ -424,7 +442,7 @@ static ssize_t ll_direct_IO(struct kiocb *iocb, struct iov_iter *iter)
 		ssize_t rc2;
 
 		/* Wait here rather than doing async submission */
-		rc2 = cl_sync_io_wait_recycle(env, &aio->cda_sync, 0, 0);
+		rc2 = cl_sync_io_wait_recycle(env, &ll_aio->cda_sync, 0, 0);
 		if (result == 0 && rc2)
 			result = rc2;
 
diff --git a/fs/lustre/obdclass/cl_io.c b/fs/lustre/obdclass/cl_io.c
index b72f5db..038ab4c 100644
--- a/fs/lustre/obdclass/cl_io.c
+++ b/fs/lustre/obdclass/cl_io.c
@@ -1138,9 +1138,13 @@ static void cl_aio_end(const struct lu_env *env, struct cl_sync_io *anchor)
 	if (!aio->cda_no_aio_complete)
 		aio->cda_iocb->ki_complete(aio->cda_iocb,
 					   ret ?: aio->cda_bytes, 0);
+
+	if (aio->cda_ll_aio)
+		cl_sync_io_note(env, &aio->cda_ll_aio->cda_sync, ret);
 }
 
-struct cl_dio_aio *cl_aio_alloc(struct kiocb *iocb, struct cl_object *obj)
+struct cl_dio_aio *cl_aio_alloc(struct kiocb *iocb, struct cl_object *obj,
+				struct cl_dio_aio *ll_aio)
 {
 	struct cl_dio_aio *aio;
 
@@ -1153,12 +1157,30 @@ struct cl_dio_aio *cl_aio_alloc(struct kiocb *iocb, struct cl_object *obj)
 		cl_sync_io_init_notify(&aio->cda_sync, 1, aio, cl_aio_end);
 		cl_page_list_init(&aio->cda_pages);
 		aio->cda_iocb = iocb;
-		if (is_sync_kiocb(iocb))
+		if (is_sync_kiocb(iocb) || ll_aio)
 			aio->cda_no_aio_complete = 1;
 		else
 			aio->cda_no_aio_complete = 0;
+		/* in the case of a lower level aio struct (ll_aio is set), or
+		 * true AIO (!is_sync_kiocb()), the memory is freed by
+		 * the daemons calling cl_sync_io_note, because they are the
+		 * last users of the aio struct
+		 *
+		 * in other cases, the last user is cl_sync_io_wait, and in
+		 * that case, the caller frees the aio struct after that call
+		 * completes
+		 */
+		if (ll_aio || !is_sync_kiocb(iocb))
+			aio->cda_no_aio_free = 0;
+		else
+			aio->cda_no_aio_free = 1;
+
 		cl_object_get(obj);
 		aio->cda_obj = obj;
+		aio->cda_ll_aio = ll_aio;
+
+		if (ll_aio)
+			atomic_add(1,  &ll_aio->cda_sync.csi_sync_nr);
 	}
 	return aio;
 }
@@ -1206,14 +1228,7 @@ void cl_sync_io_note(const struct lu_env *env, struct cl_sync_io *anchor,
 
 		spin_unlock(&anchor->csi_waitq.lock);
 
-		/**
-		 * For AIO (!is_sync_kiocb), we are responsible for freeing
-		 * memory here.  This is because we are the last user of this
-		 * aio struct, whereas in other cases, we will call
-		 * cl_sync_io_wait to wait after this, and so the memory is
-		 * freed after that call.
-		 */
-		if (aio && !is_sync_kiocb(aio->cda_iocb))
+		if (aio && !aio->cda_no_aio_free)
 			cl_aio_free(env, aio);
 	}
 }
@@ -1223,8 +1238,15 @@ void cl_sync_io_note(const struct lu_env *env, struct cl_sync_io *anchor,
 int cl_sync_io_wait_recycle(const struct lu_env *env, struct cl_sync_io *anchor,
 			    long timeout, int ioret)
 {
+	bool no_aio_free = anchor->csi_aio->cda_no_aio_free;
 	int rc = 0;
 
+	/* for true AIO, the daemons running cl_sync_io_note would normally
+	 * free the aio struct, but if we're waiting on it, we need them to not
+	 * do that.  This ensures the aio is not freed when we drop the
+	 * reference count to zero in cl_sync_io_note below
+	 */
+	anchor->csi_aio->cda_no_aio_free = 1;
 	/*
 	 * @anchor was inited as 1 to prevent end_io to be
 	 * called before we add all pages for IO, so drop
@@ -1244,6 +1266,8 @@ int cl_sync_io_wait_recycle(const struct lu_env *env, struct cl_sync_io *anchor,
 	 */
 	atomic_add(1, &anchor->csi_sync_nr);
 
+	anchor->csi_aio->cda_no_aio_free = no_aio_free;
+
 	return rc;
 }
 EXPORT_SYMBOL(cl_sync_io_wait_recycle);
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
