Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 5DEBAECAAD3
	for <lustre-devel@archiver.kernel.org>; Tue,  6 Sep 2022 01:56:26 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4MM7lt0SYjz1yBf;
	Mon,  5 Sep 2022 18:56:26 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4MM7lC3cW3z1y5s
 for <lustre-devel@lists.lustre.org>; Mon,  5 Sep 2022 18:55:51 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id CE9FE100B008;
 Mon,  5 Sep 2022 21:55:39 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id CC5E958994; Mon,  5 Sep 2022 21:55:39 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon,  5 Sep 2022 21:55:28 -0400
Message-Id: <1662429337-18737-16-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1662429337-18737-1-git-send-email-jsimmons@infradead.org>
References: <1662429337-18737-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 15/24] lustre: llite: Refactor DIO/AIO free
 code
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

Refactor the DIO/AIO free code and add some asserts.

This removes a potential use-after-free in the freeing
code.

WC-bug-id: https://jira.whamcloud.com/browse/LU-15811
Lustre-commit: f1c8ac1156ebea2b8 ("LU-15811 llite: Refactor DIO/AIO free code")
Signed-off-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/48115
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Yingjin Qian <qian@ddn.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/cl_object.h | 11 +++++-----
 fs/lustre/llite/file.c        |  3 ++-
 fs/lustre/llite/rw26.c        |  9 ++++++---
 fs/lustre/obdclass/cl_io.c    | 47 ++++++++++++++++++++++++++-----------------
 4 files changed, 41 insertions(+), 29 deletions(-)

diff --git a/fs/lustre/include/cl_object.h b/fs/lustre/include/cl_object.h
index 0f28cfe..3253f1c 100644
--- a/fs/lustre/include/cl_object.h
+++ b/fs/lustre/include/cl_object.h
@@ -2547,10 +2547,9 @@ int cl_sync_io_wait_recycle(const struct lu_env *env, struct cl_sync_io *anchor,
 			    long timeout, int ioret);
 struct cl_dio_aio *cl_dio_aio_alloc(struct kiocb *iocb, struct cl_object *obj,
 				    bool is_aio);
-struct cl_sub_dio *cl_sub_dio_alloc(struct cl_dio_aio *ll_aio, bool nofree);
-void cl_dio_aio_free(const struct lu_env *env, struct cl_dio_aio *aio,
-		     bool always_free);
-void cl_sub_dio_free(struct cl_sub_dio *sdio, bool nofree);
+struct cl_sub_dio *cl_sub_dio_alloc(struct cl_dio_aio *ll_aio, bool sync);
+void cl_dio_aio_free(const struct lu_env *env, struct cl_dio_aio *aio);
+void cl_sub_dio_free(struct cl_sub_dio *sdio);
 
 static inline void cl_sync_io_init(struct cl_sync_io *anchor, int nr)
 {
@@ -2598,7 +2597,7 @@ struct cl_dio_aio {
 	struct kiocb		*cda_iocb;
 	ssize_t			cda_bytes;
 	unsigned int		cda_no_aio_complete:1,
-				cda_no_sub_free:1;
+				cda_creator_free:1;
 };
 
 /* Sub-dio used for splitting DIO (and AIO, because AIO is DIO) according to
@@ -2610,7 +2609,7 @@ struct cl_sub_dio {
 	ssize_t			csd_bytes;
 	struct cl_dio_aio	*csd_ll_aio;
 	struct ll_dio_pages	csd_dio_pages;
-	unsigned int		csd_no_free:1;
+	unsigned int		csd_creator_free:1;
 };
 
 void ll_release_user_pages(struct page **pages, int npages);
diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index 8152821..115ee69 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -1856,7 +1856,8 @@ static void ll_heat_add(struct inode *inode, enum cl_io_type iot,
 		cl_sync_io_note(env, &io->ci_dio_aio->cda_sync,
 				rc == -EIOCBQUEUED ? 0 : rc);
 		if (!is_aio) {
-			cl_dio_aio_free(env, io->ci_dio_aio, true);
+			LASSERT(io->ci_dio_aio->cda_creator_free);
+			cl_dio_aio_free(env, io->ci_dio_aio);
 			io->ci_dio_aio = NULL;
 		}
 	}
diff --git a/fs/lustre/llite/rw26.c b/fs/lustre/llite/rw26.c
index 0f9ab68..4f2e68e 100644
--- a/fs/lustre/llite/rw26.c
+++ b/fs/lustre/llite/rw26.c
@@ -391,8 +391,10 @@ static ssize_t ll_direct_IO(struct kiocb *iocb, struct iov_iter *iter)
 					   &pvec->ldp_count, count);
 		if (unlikely(result <= 0)) {
 			cl_sync_io_note(env, &ldp_aio->csd_sync, result);
-			if (sync_submit)
-				cl_sub_dio_free(ldp_aio, true);
+			if (sync_submit) {
+				LASSERT(ldp_aio->csd_creator_free);
+				cl_sub_dio_free(ldp_aio);
+			}
 			goto out;
 		}
 
@@ -412,7 +414,8 @@ static ssize_t ll_direct_IO(struct kiocb *iocb, struct iov_iter *iter)
 					     0);
 			if (result == 0 && rc2)
 				result = rc2;
-			cl_sub_dio_free(ldp_aio, true);
+			LASSERT(ldp_aio->csd_creator_free);
+			cl_sub_dio_free(ldp_aio);
 		}
 		if (unlikely(result < 0))
 			goto out;
diff --git a/fs/lustre/obdclass/cl_io.c b/fs/lustre/obdclass/cl_io.c
index 06b9eb8..ee82260 100644
--- a/fs/lustre/obdclass/cl_io.c
+++ b/fs/lustre/obdclass/cl_io.c
@@ -1165,9 +1165,9 @@ struct cl_dio_aio *cl_dio_aio_alloc(struct kiocb *iocb, struct cl_object *obj,
 		 * no one is waiting (in the kernel) for this to complete
 		 *
 		 * in other cases, the last user is cl_sync_io_wait, and in
-		 * that case, the caller frees the struct after that call
+		 * that case, the creator frees the struct after that call
 		 */
-		aio->cda_no_sub_free = !is_aio;
+		aio->cda_creator_free = !is_aio;
 
 		cl_object_get(obj);
 		aio->cda_obj = obj;
@@ -1176,7 +1176,7 @@ struct cl_dio_aio *cl_dio_aio_alloc(struct kiocb *iocb, struct cl_object *obj,
 }
 EXPORT_SYMBOL(cl_dio_aio_alloc);
 
-struct cl_sub_dio *cl_sub_dio_alloc(struct cl_dio_aio *ll_aio, bool nofree)
+struct cl_sub_dio *cl_sub_dio_alloc(struct cl_dio_aio *ll_aio, bool sync)
 {
 	struct cl_sub_dio *sdio;
 
@@ -1192,25 +1192,24 @@ struct cl_sub_dio *cl_sub_dio_alloc(struct cl_dio_aio *ll_aio, bool nofree)
 
 		sdio->csd_ll_aio = ll_aio;
 		atomic_add(1,  &ll_aio->cda_sync.csi_sync_nr);
-		sdio->csd_no_free = nofree;
+		sdio->csd_creator_free = sync;
 	}
 	return sdio;
 }
 EXPORT_SYMBOL(cl_sub_dio_alloc);
 
-void cl_dio_aio_free(const struct lu_env *env, struct cl_dio_aio *aio,
-		     bool always_free)
+void cl_dio_aio_free(const struct lu_env *env, struct cl_dio_aio *aio)
 {
-	if (aio && (!aio->cda_no_sub_free || always_free)) {
+	if (aio) {
 		cl_object_put(env, aio->cda_obj);
 		kmem_cache_free(cl_dio_aio_kmem, aio);
 	}
 }
 EXPORT_SYMBOL(cl_dio_aio_free);
 
-void cl_sub_dio_free(struct cl_sub_dio *sdio, bool always_free)
+void cl_sub_dio_free(struct cl_sub_dio *sdio)
 {
-	if (sdio && (!sdio->csd_no_free || always_free))
+	if (sdio)
 		kmem_cache_free(cl_sub_dio_kmem, sdio);
 }
 EXPORT_SYMBOL(cl_sub_dio_free);
@@ -1247,7 +1246,10 @@ void cl_sync_io_note(const struct lu_env *env, struct cl_sync_io *anchor,
 	LASSERT(atomic_read(&anchor->csi_sync_nr) > 0);
 	if (atomic_dec_and_lock(&anchor->csi_sync_nr,
 				&anchor->csi_waitq.lock)) {
-		void *dio_aio = NULL;
+		struct cl_sub_dio *sub_dio_aio = NULL;
+		struct cl_dio_aio *dio_aio = NULL;
+		void *csi_dio_aio = NULL;
+		bool creator_free = true;
 
 		cl_sync_io_end_t *end_io = anchor->csi_end_io;
 
@@ -1260,18 +1262,25 @@ void cl_sync_io_note(const struct lu_env *env, struct cl_sync_io *anchor,
 		if (end_io)
 			end_io(env, anchor);
 
-		dio_aio = anchor->csi_dio_aio;
+		csi_dio_aio = anchor->csi_dio_aio;
+		sub_dio_aio = csi_dio_aio;
+		dio_aio = csi_dio_aio;
+
+		if (csi_dio_aio && end_io == cl_dio_aio_end)
+			creator_free = dio_aio->cda_creator_free;
+		else if (csi_dio_aio && end_io == cl_sub_dio_end)
+			creator_free = sub_dio_aio->csd_creator_free;
 
 		spin_unlock(&anchor->csi_waitq.lock);
 
-		if (dio_aio) {
-			if (end_io == cl_dio_aio_end)
-				cl_dio_aio_free(env,
-						(struct cl_dio_aio *) dio_aio,
-						false);
-			else if (end_io == cl_sub_dio_end)
-				cl_sub_dio_free((struct cl_sub_dio *) dio_aio,
-						false);
+		if (csi_dio_aio) {
+			if (end_io == cl_dio_aio_end) {
+				if (!creator_free)
+					cl_dio_aio_free(env, dio_aio);
+			} else if (end_io == cl_sub_dio_end) {
+				if (!creator_free)
+					cl_sub_dio_free(sub_dio_aio);
+			}
 		}
 	}
 }
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
