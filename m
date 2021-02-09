Return-Path: <SRS0=GtYW=HL=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F361BC433E6
	for <lustre-devel@archiver.kernel.org>; Tue,  9 Feb 2021 00:54:42 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id B0B6261606
	for <lustre-devel@archiver.kernel.org>; Tue,  9 Feb 2021 00:54:42 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B0B6261606
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 72A4B30F9EB;
	Mon,  8 Feb 2021 16:54:39 -0800 (PST)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id D780130F986
 for <lustre-devel@lists.lustre.org>; Mon,  8 Feb 2021 16:54:31 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 039051006EBC;
 Mon,  8 Feb 2021 19:54:29 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id F0EEA4CC3A; Mon,  8 Feb 2021 19:54:28 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon,  8 Feb 2021 19:54:24 -0500
Message-Id: <1612832067-1449-7-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1612832067-1449-1-git-send-email-jsimmons@infradead.org>
References: <1612832067-1449-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 6/9] lustre: sec: get rid of bad rss-counter
 state messages
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

From: Sebastien Buisson <sbuisson@ddn.com>

When doing O_DIRECT IOs on encrypted files, messages about bad
rss-counter state can be seen in the console. The mm get confused
because we twist the Lustre pages used for RPCs so that they are
suitable for llcrypt API.
In order to do this properly, the original mapping on these pages
must be preserved outside of the encryption/decryption needs.

Fixes: feca6b62a6 ("lustre: sec: O_DIRECT for encrypted file")
WC-bug-id: https://jira.whamcloud.com/browse/LU-14306
Lustre-commit: a71e0dd7f7aa445 ("LU-14306 sec: get rid of bad rss-counter state messages")
Signed-off-by: Sebastien Buisson <sbuisson@ddn.com>
Reviewed-on: https://review.whamcloud.com/41199
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: John L. Hammond <jhammond@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/cl_object.h     |  6 +++
 fs/lustre/include/lustre_crypto.h |  8 ++++
 fs/lustre/llite/rw26.c            | 23 +++---------
 fs/lustre/obdclass/cl_io.c        | 11 ------
 fs/lustre/obdclass/cl_page.c      |  1 +
 fs/lustre/osc/osc_request.c       | 78 +++++++++++++++++++++++++++++++++------
 6 files changed, 86 insertions(+), 41 deletions(-)

diff --git a/fs/lustre/include/cl_object.h b/fs/lustre/include/cl_object.h
index d2cee34..4f34e5d 100644
--- a/fs/lustre/include/cl_object.h
+++ b/fs/lustre/include/cl_object.h
@@ -741,6 +741,12 @@ struct cl_page {
 	struct cl_object		*cp_obj;
 	/** vmpage */
 	struct page			*cp_vmpage;
+	/**
+	 * Assigned if doing direct IO, because in this case cp_vmpage is not
+	 * a valid page cache page, hence the inode cannot be inferred from
+	 * cp_vmpage->mapping->host.
+	 */
+	struct inode			*cp_inode;
 	/** Linkage of pages within group. Pages must be owned */
 	struct list_head		 cp_batch;
 	/** array of slices offset. Immutable after creation. */
diff --git a/fs/lustre/include/lustre_crypto.h b/fs/lustre/include/lustre_crypto.h
index b80147f..01b5e85 100644
--- a/fs/lustre/include/lustre_crypto.h
+++ b/fs/lustre/include/lustre_crypto.h
@@ -48,8 +48,12 @@ int ll_set_encflags(struct inode *inode, void *encctx, u32 encctxlen,
 #define llcrypt_has_encryption_key(inode) fscrypt_has_encryption_key(inode)
 #define llcrypt_encrypt_pagecache_blocks(page, len, offs, gfp_flags)	\
 	fscrypt_encrypt_pagecache_blocks(page, len, offs, gfp_flags)
+#define llcrypt_encrypt_block_inplace(inode, page, len, offs, lblk, gfp_flags) \
+	fscrypt_encrypt_block_inplace(inode, page, len, offs, lblk, gfp_flags)
 #define llcrypt_decrypt_pagecache_blocks(page, len, offs)	\
 	fscrypt_decrypt_pagecache_blocks(page, len, offs)
+#define llcrypt_decrypt_block_inplace(inode, page, len, offs, lblk_num)        \
+	fscrypt_decrypt_block_inplace(inode, page, len, offs, lblk_num)
 #define llcrypt_inherit_context(parent, child, fs_data, preload)	\
 	fscrypt_inherit_context(parent, child, fs_data, preload)
 #define llcrypt_get_encryption_info(inode) fscrypt_get_encryption_info(inode)
@@ -82,7 +86,11 @@ int ll_set_encflags(struct inode *inode, void *encctx, u32 encctxlen,
 #define llcrypt_has_encryption_key(inode) false
 #define llcrypt_encrypt_pagecache_blocks(page, len, offs, gfp_flags)	\
 	ERR_PTR(-EOPNOTSUPP)
+#define llcrypt_encrypt_block_inplace(inode, page, len, offs, lblk, gfp_flags) \
+	-EOPNOTSUPP
 #define llcrypt_decrypt_pagecache_blocks(page, len, offs)	-EOPNOTSUPP
+#define llcrypt_decrypt_block_inplace(inode, page, len, offs, lblk_num)	       \
+	-EOPNOTSUPP
 #define llcrypt_inherit_context(parent, child, fs_data, preload)     -EOPNOTSUPP
 #define llcrypt_get_encryption_info(inode)			-EOPNOTSUPP
 #define llcrypt_put_encryption_info(inode)			do {} while (0)
diff --git a/fs/lustre/llite/rw26.c b/fs/lustre/llite/rw26.c
index 28c0a75..91a05ac 100644
--- a/fs/lustre/llite/rw26.c
+++ b/fs/lustre/llite/rw26.c
@@ -236,7 +236,6 @@ struct ll_dio_pages {
 	int io_pages = 0;
 	size_t page_size = cl_page_size(obj);
 	int i;
-	pgoff_t index = offset >> PAGE_SHIFT;
 	ssize_t rc = 0;
 
 	cl_2queue_init(queue);
@@ -257,26 +256,14 @@ struct ll_dio_pages {
 
 		page->cp_sync_io = anchor;
 		if (inode && IS_ENCRYPTED(inode)) {
-			struct page *vmpage = cl_page_vmpage(page);
-
 			/* In case of Direct IO on encrypted file, we need to
-			 * set the correct page index, and add a reference to
-			 * the mapping. This is required by llcrypt to proceed
-			 * to encryption/decryption, because each block is
-			 * encrypted independently, and each block's IV is set
-			 * to the logical block number within the file.
+			 * add a reference to the inode on the cl_page.
+			 * This info is required by llcrypt to proceed
+			 * to encryption/decryption.
 			 * This is safe because we know these pages are private
-			 * to the thread doing the Direct IO, and despite
-			 * setting a mapping on the pages, cached lookups will
-			 * not find them.
-			 * Set PageChecked to detect special case of Direct IO
-			 * in osc_brw_fini_request().
-			 * Reference to the mapping and PageChecked flag are
-			 * removed in cl_aio_end().
+			 * to the thread doing the Direct IO.
 			 */
-			vmpage->index = index++;
-			vmpage->mapping = inode->i_mapping;
-			SetPageChecked(vmpage);
+			page->cp_inode = inode;
 		}
 		cl_page_list_add(&queue->c2_qin, page);
 		/*
diff --git a/fs/lustre/obdclass/cl_io.c b/fs/lustre/obdclass/cl_io.c
index 37b0828..c57a3766 100644
--- a/fs/lustre/obdclass/cl_io.c
+++ b/fs/lustre/obdclass/cl_io.c
@@ -1081,19 +1081,8 @@ static void cl_aio_end(const struct lu_env *env, struct cl_sync_io *anchor)
 	/* release pages */
 	while (aio->cda_pages.pl_nr > 0) {
 		struct cl_page *page = cl_page_list_first(&aio->cda_pages);
-		struct page *vmpage = cl_page_vmpage(page);
-		struct inode *inode = vmpage ? page2inode(vmpage) : NULL;
 
 		cl_page_get(page);
-		/* We end up here in case of Direct IO only. For encrypted file,
-		 * mapping was set on pages in ll_direct_rw_pages(), so it has
-		 * to be cleared now before page cleanup.
-		 * PageChecked flag was also set there, so we clean up here.
-		 */
-		if (inode && IS_ENCRYPTED(inode)) {
-			vmpage->mapping = NULL;
-			ClearPageChecked(vmpage);
-		}
 		cl_page_list_del(env, &aio->cda_pages, page);
 		cl_page_delete(env, page);
 		cl_page_put(env, page);
diff --git a/fs/lustre/obdclass/cl_page.c b/fs/lustre/obdclass/cl_page.c
index 53f88a7..2cf8d30 100644
--- a/fs/lustre/obdclass/cl_page.c
+++ b/fs/lustre/obdclass/cl_page.c
@@ -231,6 +231,7 @@ struct cl_page *cl_page_alloc(const struct lu_env *env, struct cl_object *o,
 		cl_page->cp_vmpage = vmpage;
 		cl_page->cp_state = CPS_CACHED;
 		cl_page->cp_type = type;
+		cl_page->cp_inode = NULL;
 		INIT_LIST_HEAD(&cl_page->cp_batch);
 		lu_ref_init(&cl_page->cp_reference);
 		cl_object_for_each(o2, o) {
diff --git a/fs/lustre/osc/osc_request.c b/fs/lustre/osc/osc_request.c
index a6a8cac..8d3688f 100644
--- a/fs/lustre/osc/osc_request.c
+++ b/fs/lustre/osc/osc_request.c
@@ -1409,8 +1409,21 @@ static int osc_brw_prep_request(int cmd, struct client_obd *cli,
 	void *short_io_buf;
 	const char *obd_name = cli->cl_import->imp_obd->obd_name;
 	struct inode *inode;
+	bool directio = false;
 
 	inode = page2inode(pga[0]->pg);
+	if (!inode) {
+		/* Try to get reference to inode from cl_page if we are
+		 * dealing with direct IO, as handled pages are not
+		 * actual page cache pages.
+		 */
+		struct osc_async_page *oap = brw_page2oap(pga[0]);
+		struct cl_page *clpage = oap2cl_page(oap);
+
+		inode = clpage->cp_inode;
+		if (inode)
+			directio = true;
+	}
 	if (OBD_FAIL_CHECK(OBD_FAIL_OSC_BRW_PREP_REQ))
 		return -ENOMEM; /* Recoverable */
 	if (OBD_FAIL_CHECK(OBD_FAIL_OSC_BRW_PREP_REQ2))
@@ -1435,6 +1448,8 @@ static int osc_brw_prep_request(int cmd, struct client_obd *cli,
 			bool retried = false;
 			bool lockedbymyself;
 			u32 nunits = (pg->off & ~PAGE_MASK) + pg->count;
+			struct address_space *map_orig = NULL;
+			pgoff_t index_orig;
 
 retry_encrypt:
 			if (nunits & ~LUSTRE_ENCRYPTION_MASK)
@@ -1450,10 +1465,20 @@ static int osc_brw_prep_request(int cmd, struct client_obd *cli,
 			 * which means only once the page is fully processed.
 			 */
 			lockedbymyself = trylock_page(pg->pg);
+			if (directio) {
+				map_orig = pg->pg->mapping;
+				pg->pg->mapping = inode->i_mapping;
+				index_orig = pg->pg->index;
+				pg->pg->index = pg->off >> PAGE_SHIFT;
+			}
 			data_page =
 				llcrypt_encrypt_pagecache_blocks(pg->pg,
 								 nunits, 0,
 								 GFP_NOFS);
+			if (directio) {
+				pg->pg->mapping = map_orig;
+				pg->pg->index = index_orig;
+			}
 			if (lockedbymyself)
 				unlock_page(pg->pg);
 			if (IS_ERR(data_page)) {
@@ -1921,6 +1946,7 @@ static int osc_brw_fini_request(struct ptlrpc_request *req, int rc)
 	struct ost_body *body;
 	u32 client_cksum = 0;
 	struct inode *inode;
+	unsigned int blockbits = 0, blocksize = 0;
 
 	if (rc < 0 && rc != -EDQUOT) {
 		DEBUG_REQ(D_INFO, req, "Failed request: rc = %d", rc);
@@ -2113,6 +2139,19 @@ static int osc_brw_fini_request(struct ptlrpc_request *req, int rc)
 	}
 
 	inode = page2inode(aa->aa_ppga[0]->pg);
+	if (!inode) {
+		/* Try to get reference to inode from cl_page if we are
+		 * dealing with direct IO, as handled pages are not
+		 * actual page cache pages.
+		 */
+		struct osc_async_page *oap = brw_page2oap(aa->aa_ppga[0]);
+
+		inode = oap2cl_page(oap)->cp_inode;
+		if (inode) {
+			blockbits = inode->i_blkbits;
+			blocksize = 1 << blockbits;
+		}
+	}
 	if (inode && IS_ENCRYPTED(inode)) {
 		int idx;
 
@@ -2137,18 +2176,33 @@ static int osc_brw_fini_request(struct ptlrpc_request *req, int rc)
 					break;
 				}
 
-				/* The page is already locked when we arrive
-				 * here, except when we deal with a twisted
-				 * page for specific Direct IO support, in
-				 * which case PageChecked flag is set on page.
-				 */
-				if (PageChecked(pg->pg))
-					lock_page(pg->pg);
-				rc = llcrypt_decrypt_pagecache_blocks(pg->pg,
-								      LUSTRE_ENCRYPTION_UNIT_SIZE,
-								      offs);
-				if (PageChecked(pg->pg))
-					unlock_page(pg->pg);
+				if (blockbits) {
+					/* This is direct IO case. Directly call
+					 * decrypt function that takes inode as
+					 * input parameter. Page does not need
+					 * to be locked.
+					 */
+					u64 lblk_num =
+						((u64)(pg->off >> PAGE_SHIFT) <<
+						      (PAGE_SHIFT - blockbits)) +
+						      (offs >> blockbits);
+					unsigned int i;
+
+					for (i = offs;
+					     i < offs + LUSTRE_ENCRYPTION_UNIT_SIZE;
+					     i += blocksize, lblk_num++) {
+						rc = llcrypt_decrypt_block_inplace(inode,
+										   pg->pg,
+										   blocksize, i,
+										   lblk_num);
+						if (rc)
+							break;
+					}
+				} else {
+					rc = llcrypt_decrypt_pagecache_blocks(pg->pg,
+									      LUSTRE_ENCRYPTION_UNIT_SIZE,
+									      offs);
+				}
 				if (rc)
 					goto out;
 
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
