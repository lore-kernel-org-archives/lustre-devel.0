Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id DE418C77B70
	for <lustre-devel@archiver.kernel.org>; Sun,  9 Apr 2023 12:36:05 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4PvWPl50yKz22Rm;
	Sun,  9 Apr 2023 05:19:39 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4PvWJq1vrBz219P
 for <lustre-devel@lists.lustre.org>; Sun,  9 Apr 2023 05:15:23 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 1EB941008482;
 Sun,  9 Apr 2023 08:13:28 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 1D7252AB; Sun,  9 Apr 2023 08:13:28 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun,  9 Apr 2023 08:13:00 -0400
Message-Id: <1681042400-15491-21-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1681042400-15491-1-git-send-email-jsimmons@infradead.org>
References: <1681042400-15491-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 20/40] lustre: clio: Remove cl_page_size()
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

cl_page_size() is just a function which does:
1 << PAGE_SHIFT

and the kernel provides a macro for that - PAGE_SIZE.
Maybe it didn't when this function was added, but it sure
does now.

So, remove cl_page_size().

WC-bug-id: https://jira.whamcloud.com/browse/LU-16515
Lustre-commit: 19c38f6c94ae161b1 ("LU-16515 clio: Remove cl_page_size()")
Signed-off-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/49918
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Sebastien Buisson <sbuisson@ddn.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/cl_object.h | 1 -
 fs/lustre/llite/rw26.c        | 9 ++++-----
 fs/lustre/llite/vvp_io.c      | 2 +-
 fs/lustre/lov/lov_page.c      | 2 +-
 fs/lustre/obdclass/cl_page.c  | 6 ------
 5 files changed, 6 insertions(+), 14 deletions(-)

diff --git a/fs/lustre/include/cl_object.h b/fs/lustre/include/cl_object.h
index 41ce0b0..8a98413 100644
--- a/fs/lustre/include/cl_object.h
+++ b/fs/lustre/include/cl_object.h
@@ -2268,7 +2268,6 @@ void cl_page_touch(const struct lu_env *env, const struct cl_page *pg,
 		   size_t to);
 loff_t cl_offset(const struct cl_object *obj, pgoff_t idx);
 pgoff_t cl_index(const struct cl_object *obj, loff_t offset);
-size_t cl_page_size(const struct cl_object *obj);
 int cl_pages_prune(const struct lu_env *env, struct cl_object *obj);
 
 void cl_lock_print(const struct lu_env *env, void *cookie,
diff --git a/fs/lustre/llite/rw26.c b/fs/lustre/llite/rw26.c
index 6700717..6b338b2 100644
--- a/fs/lustre/llite/rw26.c
+++ b/fs/lustre/llite/rw26.c
@@ -218,7 +218,6 @@ static unsigned long ll_iov_iter_alignment(struct iov_iter *i)
 	struct cl_sync_io *anchor = &sdio->csd_sync;
 	loff_t offset = pv->ldp_file_offset;
 	int io_pages = 0;
-	size_t page_size = cl_page_size(obj);
 	int i;
 	ssize_t rc = 0;
 
@@ -257,12 +256,12 @@ static unsigned long ll_iov_iter_alignment(struct iov_iter *i)
 		 * Set page clip to tell transfer formation engine
 		 * that page has to be sent even if it is beyond KMS.
 		 */
-		if (size < page_size)
+		if (size < PAGE_SIZE)
 			cl_page_clip(env, page, 0, size);
 		++io_pages;
 
-		offset += page_size;
-		size -= page_size;
+		offset += PAGE_SIZE;
+		size -= PAGE_SIZE;
 	}
 	if (rc == 0 && io_pages > 0) {
 		int iot = rw == READ ? CRT_READ : CRT_WRITE;
@@ -478,7 +477,7 @@ static int ll_prepare_partial_page(const struct lu_env *env, struct cl_io *io,
 	if (attr->cat_kms <= offset) {
 		char *kaddr = kmap_atomic(pg->cp_vmpage);
 
-		memset(kaddr, 0, cl_page_size(obj));
+		memset(kaddr, 0, PAGE_SIZE);
 		kunmap_atomic(kaddr);
 		result = 0;
 		goto out;
diff --git a/fs/lustre/llite/vvp_io.c b/fs/lustre/llite/vvp_io.c
index 2da74a2..561ce66 100644
--- a/fs/lustre/llite/vvp_io.c
+++ b/fs/lustre/llite/vvp_io.c
@@ -1525,7 +1525,7 @@ static int vvp_io_fault_start(const struct lu_env *env,
 		 */
 		fio->ft_nob = size - cl_offset(obj, fio->ft_index);
 	else
-		fio->ft_nob = cl_page_size(obj);
+		fio->ft_nob = PAGE_SIZE;
 
 	lu_ref_add(&page->cp_reference, "fault", io);
 	fio->ft_page = page;
diff --git a/fs/lustre/lov/lov_page.c b/fs/lustre/lov/lov_page.c
index 6e28e62..e9283aa 100644
--- a/fs/lustre/lov/lov_page.c
+++ b/fs/lustre/lov/lov_page.c
@@ -144,7 +144,7 @@ int lov_page_init_empty(const struct lu_env *env, struct cl_object *obj,
 	page->cp_lov_index = CP_LOV_INDEX_EMPTY;
 
 	addr = kmap(page->cp_vmpage);
-	memset(addr, 0, cl_page_size(obj));
+	memset(addr, 0, PAGE_SIZE);
 	kunmap(page->cp_vmpage);
 	SetPageUptodate(page->cp_vmpage);
 	return 0;
diff --git a/fs/lustre/obdclass/cl_page.c b/fs/lustre/obdclass/cl_page.c
index 62d8ee5..8320293 100644
--- a/fs/lustre/obdclass/cl_page.c
+++ b/fs/lustre/obdclass/cl_page.c
@@ -1035,12 +1035,6 @@ pgoff_t cl_index(const struct cl_object *obj, loff_t offset)
 }
 EXPORT_SYMBOL(cl_index);
 
-size_t cl_page_size(const struct cl_object *obj)
-{
-	return 1UL << PAGE_SHIFT;
-}
-EXPORT_SYMBOL(cl_page_size);
-
 /**
  * Adds page slice to the compound page.
  *
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
