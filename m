Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 5AF8FC6FA86
	for <lustre-devel@archiver.kernel.org>; Sun, 18 Sep 2022 05:22:57 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4MVbmd0VnQz1y78;
	Sat, 17 Sep 2022 22:22:57 -0700 (PDT)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4MVbm54cV1z1yD2
 for <lustre-devel@lists.lustre.org>; Sat, 17 Sep 2022 22:22:29 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 015918F0F;
 Sun, 18 Sep 2022 01:22:17 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id F34AAE8BA5; Sun, 18 Sep 2022 01:22:16 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 18 Sep 2022 01:22:05 -0400
Message-Id: <1663478534-19917-16-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1663478534-19917-1-git-send-email-jsimmons@infradead.org>
References: <1663478534-19917-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 15/24] lustre: clio: remove unused
 convenience functions
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

Remove the unused convenience functions cl_page_top(), cl_page_at(),
cl_page_at_trusted(), and cl2vm_page().

WC-bug-id: https://jira.whamcloud.com/browse/LU-10994
Lustre-commit: 27e19a5420ae3ec22 ("LU-10994 clio: remove unused convenience functions")
Signed-off-by: John L. Hammond <jhammond@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/47401
Reviewed-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/cl_object.h  |  3 ---
 fs/lustre/llite/vvp_internal.h |  5 -----
 fs/lustre/obdclass/cl_page.c   | 28 ----------------------------
 3 files changed, 36 deletions(-)

diff --git a/fs/lustre/include/cl_object.h b/fs/lustre/include/cl_object.h
index c816b1d..c5adbda 100644
--- a/fs/lustre/include/cl_object.h
+++ b/fs/lustre/include/cl_object.h
@@ -2217,9 +2217,6 @@ void cl_page_header_print(const struct lu_env *env, void *cookie,
 			  lu_printer_t printer, const struct cl_page *pg);
 struct cl_page *cl_vmpage_page(struct page *vmpage, struct cl_object *obj);
 
-const struct cl_page_slice *cl_page_at(const struct cl_page *page,
-				       const struct lu_device_type *dtype);
-
 /**
  * \name ownership
  *
diff --git a/fs/lustre/llite/vvp_internal.h b/fs/lustre/llite/vvp_internal.h
index 17feae6..c73923b 100644
--- a/fs/lustre/llite/vvp_internal.h
+++ b/fs/lustre/llite/vvp_internal.h
@@ -250,11 +250,6 @@ static inline struct inode *vvp_object_inode(const struct cl_object *obj)
 int vvp_object_invariant(const struct cl_object *obj);
 struct vvp_object *cl_inode2vvp(struct inode *inode);
 
-static inline struct page *cl2vm_page(const struct cl_page_slice *slice)
-{
-	return slice->cpl_page->cp_vmpage;
-}
-
 # define CLOBINVRNT(env, clob, expr)					\
 	((void)sizeof(env), (void)sizeof(clob), (void)sizeof(!!(expr)))
 
diff --git a/fs/lustre/obdclass/cl_page.c b/fs/lustre/obdclass/cl_page.c
index 2e3374c..7829b90d 100644
--- a/fs/lustre/obdclass/cl_page.c
+++ b/fs/lustre/obdclass/cl_page.c
@@ -95,27 +95,6 @@ static void cl_page_get_trust(struct cl_page *page)
 	     slice = cl_page_slice_get(cl_page, i); i >= 0;	\
 	     slice = cl_page_slice_get(cl_page, --i))
 
-/**
- * Returns a slice within a cl_page, corresponding to the given layer in the
- * device stack.
- *
- * \see cl_lock_at()
- */
-static const struct cl_page_slice *
-cl_page_at_trusted(const struct cl_page *cl_page,
-		   const struct lu_device_type *dtype)
-{
-	const struct cl_page_slice *slice;
-	int i;
-
-	cl_page_slice_for_each(cl_page, slice, i) {
-		if (slice->cpl_obj->co_lu.lo_dev->ld_type == dtype)
-			return slice;
-	}
-
-	return NULL;
-}
-
 static void __cl_page_free(struct cl_page *cl_page, unsigned short bufsize)
 {
 	int index = cl_page->cp_kmem_index;
@@ -477,13 +456,6 @@ struct cl_page *cl_vmpage_page(struct page *vmpage, struct cl_object *obj)
 }
 EXPORT_SYMBOL(cl_vmpage_page);
 
-const struct cl_page_slice *cl_page_at(const struct cl_page *page,
-				       const struct lu_device_type *dtype)
-{
-	return cl_page_at_trusted(page, dtype);
-}
-EXPORT_SYMBOL(cl_page_at);
-
 static void cl_page_owner_clear(struct cl_page *page)
 {
 	if (page->cp_owner) {
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
