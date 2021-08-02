Return-Path: <SRS0=Kfxm=MZ=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.7 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 45123C4338F
	for <lustre-devel@archiver.kernel.org>; Mon,  2 Aug 2021 19:51:11 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id E4EC560F36
	for <lustre-devel@archiver.kernel.org>; Mon,  2 Aug 2021 19:51:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.1 mail.kernel.org E4EC560F36
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 12050352DB2;
	Mon,  2 Aug 2021 12:51:08 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 665F435286A
 for <lustre-devel@lists.lustre.org>; Mon,  2 Aug 2021 12:50:57 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 65628100804A;
 Mon,  2 Aug 2021 15:50:53 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 62FB6C2F53; Mon,  2 Aug 2021 15:50:53 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon,  2 Aug 2021 15:50:30 -0400
Message-Id: <1627933851-7603-11-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1627933851-7603-1-git-send-email-jsimmons@infradead.org>
References: <1627933851-7603-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 10/25] lustre: llite: Modify AIO/DIO
 reference counting
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
Cc: Patrick Farrell <farr0186@gmail.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Patrick Farrell <farr0186@gmail.com>

For DIO pages, it's enough to have a reference on the
cl_object associated with the AIO.  This saves taking a
reference on the cl_object for each page, which saves about
5% of the time when doing DIO/AIO.

This is possible because the lifecycle of the aio struct is
always greater than that of the associated pages.

This patch reduces i/o time in ms/GiB by:
Write: 6 ms/GiB
Read: 1 ms/GiB

Totals:
Write: 198 ms/GiB
Read: 197 ms/GiB

mpirun -np 1  $IOR -w -r -t 64M -b 64G -o ./iorfile --posix.odirect

With previous patches in series:
write     5030 MiB/s
read      5174 MiB/s

Plus this patch:
write     5183 MiB/s
read      5200 MiB/s

WC-bug-id: https://jira.whamcloud.com/browse/LU-13799
Lustre-commit: b3de247b76b4101 ("LU-13799 llite: Modify AIO/DIO reference counting")
Signed-off-by: Patrick Farrell <farr0186@gmail.com>
Reviewed-on: https://review.whamcloud.com/39442
Reviewed-by: Wang Shilong <wshilong@whamcloud.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Shaun Tancheff <shaun.tancheff@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/cl_object.h |  5 +++--
 fs/lustre/llite/file.c        |  5 +++--
 fs/lustre/obdclass/cl_io.c    | 12 ++++++++----
 fs/lustre/obdclass/cl_page.c  |  6 ++++--
 4 files changed, 18 insertions(+), 10 deletions(-)

diff --git a/fs/lustre/include/cl_object.h b/fs/lustre/include/cl_object.h
index 61a14f4..0f785e5 100644
--- a/fs/lustre/include/cl_object.h
+++ b/fs/lustre/include/cl_object.h
@@ -2593,8 +2593,8 @@ void cl_sync_io_note(const struct lu_env *env, struct cl_sync_io *anchor,
 		     int ioret);
 int cl_sync_io_wait_recycle(const struct lu_env *env, struct cl_sync_io *anchor,
 			    long timeout, int ioret);
-struct cl_dio_aio *cl_aio_alloc(struct kiocb *iocb);
-void cl_aio_free(struct cl_dio_aio *aio);
+struct cl_dio_aio *cl_aio_alloc(struct kiocb *iocb, struct cl_object *obj);
+void cl_aio_free(const struct lu_env *env, struct cl_dio_aio *aio);
 
 static inline void cl_sync_io_init(struct cl_sync_io *anchor, int nr)
 {
@@ -2624,6 +2624,7 @@ struct cl_sync_io {
 struct cl_dio_aio {
 	struct cl_sync_io	cda_sync;
 	struct cl_page_list	cda_pages;
+	struct cl_object	*cda_obj;
 	struct kiocb		*cda_iocb;
 	ssize_t			cda_bytes;
 	unsigned int		cda_no_aio_complete:1;
diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index b822ca5..1bf237b 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -1656,7 +1656,8 @@ static void ll_heat_add(struct inode *inode, enum cl_io_type iot,
 		if (!ll_sbi_has_parallel_dio(sbi))
 			is_parallel_dio = false;
 
-		ci_aio = cl_aio_alloc(args->u.normal.via_iocb);
+		ci_aio = cl_aio_alloc(args->u.normal.via_iocb,
+				      ll_i2info(inode)->lli_clob);
 		if (!ci_aio) {
 			rc = -ENOMEM;
 			goto out;
@@ -1814,7 +1815,7 @@ static void ll_heat_add(struct inode *inode, enum cl_io_type iot,
 		cl_sync_io_note(env, &io->ci_aio->cda_sync,
 				rc == -EIOCBQUEUED ? 0 : rc);
 		if (!is_aio) {
-			cl_aio_free(io->ci_aio);
+			cl_aio_free(env, io->ci_aio);
 			io->ci_aio = NULL;
 		}
 	}
diff --git a/fs/lustre/obdclass/cl_io.c b/fs/lustre/obdclass/cl_io.c
index 63ce39c..b5e7744b 100644
--- a/fs/lustre/obdclass/cl_io.c
+++ b/fs/lustre/obdclass/cl_io.c
@@ -1131,7 +1131,7 @@ static void cl_aio_end(const struct lu_env *env, struct cl_sync_io *anchor)
 					   ret ?: aio->cda_bytes, 0);
 }
 
-struct cl_dio_aio *cl_aio_alloc(struct kiocb *iocb)
+struct cl_dio_aio *cl_aio_alloc(struct kiocb *iocb, struct cl_object *obj)
 {
 	struct cl_dio_aio *aio;
 
@@ -1147,15 +1147,19 @@ struct cl_dio_aio *cl_aio_alloc(struct kiocb *iocb)
 		cl_page_list_init(&aio->cda_pages);
 		aio->cda_iocb = iocb;
 		aio->cda_no_aio_complete = 0;
+		cl_object_get(obj);
+		aio->cda_obj = obj;
 	}
 	return aio;
 }
 EXPORT_SYMBOL(cl_aio_alloc);
 
-void cl_aio_free(struct cl_dio_aio *aio)
+void cl_aio_free(const struct lu_env *env, struct cl_dio_aio *aio)
 {
-	if (aio)
+	if (aio) {
+		cl_object_put(env, aio->cda_obj);
 		kmem_cache_free(cl_dio_aio_kmem, aio);
+	}
 }
 EXPORT_SYMBOL(cl_aio_free);
 
@@ -1196,7 +1200,7 @@ void cl_sync_io_note(const struct lu_env *env, struct cl_sync_io *anchor,
 		 * If anchor->csi_aio is set, we are responsible for freeing
 		 * memory here rather than when cl_sync_io_wait() completes.
 		 */
-		cl_aio_free(aio);
+		cl_aio_free(env, aio);
 	}
 }
 EXPORT_SYMBOL(cl_sync_io_note);
diff --git a/fs/lustre/obdclass/cl_page.c b/fs/lustre/obdclass/cl_page.c
index 1c9e91d..41bd767 100644
--- a/fs/lustre/obdclass/cl_page.c
+++ b/fs/lustre/obdclass/cl_page.c
@@ -147,7 +147,8 @@ static void cl_page_free(const struct lu_env *env, struct cl_page *cl_page,
 	cl_page->cp_layer_count = 0;
 	lu_object_ref_del_at(&obj->co_lu, &cl_page->cp_obj_ref,
 			     "cl_page", cl_page);
-	cl_object_put(env, obj);
+	if (cl_page->cp_type != CPT_TRANSIENT)
+		cl_object_put(env, obj);
 	lu_ref_fini(&cl_page->cp_reference);
 	__cl_page_free(cl_page, bufsize);
 }
@@ -227,7 +228,8 @@ struct cl_page *cl_page_alloc(const struct lu_env *env, struct cl_object *o,
 		BUILD_BUG_ON((1 << CP_TYPE_BITS) < CPT_NR); /* cp_type */
 		refcount_set(&cl_page->cp_ref, 1);
 		cl_page->cp_obj = o;
-		cl_object_get(o);
+		if (type != CPT_TRANSIENT)
+			cl_object_get(o);
 		lu_object_ref_add_at(&o->co_lu, &cl_page->cp_obj_ref,
 				     "cl_page", cl_page);
 		cl_page->cp_vmpage = vmpage;
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
