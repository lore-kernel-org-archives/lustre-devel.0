Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 93B27C433EF
	for <lustre-devel@archiver.kernel.org>; Sun, 20 Mar 2022 13:32:49 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 1FD7C21FBAB;
	Sun, 20 Mar 2022 06:32:04 -0700 (PDT)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id ADC7D21F9D5
 for <lustre-devel@lists.lustre.org>; Sun, 20 Mar 2022 06:31:22 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 9F6391030;
 Sun, 20 Mar 2022 09:31:08 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 9DAE4AB; Sun, 20 Mar 2022 09:31:08 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 20 Mar 2022 09:31:03 -0400
Message-Id: <1647783064-20688-50-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1647783064-20688-1-git-send-email-jsimmons@infradead.org>
References: <1647783064-20688-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 49/50] lustre: sec: fix DIO for encrypted
 files
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

With Direct IO, we do not have proper page cache pages. So we need to
retrieve by ourselves the page mapping and the page index of the page
to be encrypted/decrypted.

For the index, we need to use the offset of the page within the file,
and not the object.
So we rename cl_page's cp_osc_index to cp_page_index for that purpose.
cp_osc_index is redundant with osc_async_page's oap_obj_off and only
used by osc_index(), so we also adapt this function.
cp_page_index is initialized in cl_page_alloc(), and accessed in
the OSC layer where the llcrypt primitives are called.

For the mapping, problem is page->mapping is not set to NULL on page
allocation, so it cannot safely be used to see if a page is a direct
I/O page.
Use cl_page for direct I/O and page->mapping for buffered
I/O.  (clpage->cp_inode is only set for direct I/O and
cannot easily be always set.)
Without this, we sometimes get panics when page2inode is
used in the OSC layer.  (Note the remaining use in dom is
safe because ll_dom_readpage is a page cache helper and
will never see DIO pages.)

Fixes: 2de53869ee ("lustre: sec: get rid of bad rss-counter state messages")
WC-bug-id: https://jira.whamcloud.com/browse/LU-15608
Lustre-commit: 966ca46e4aa2eb39c ("LU-15608 sec: fix DIO for encrypted files")
Signed-off-by: Sebastien Buisson <sbuisson@ddn.com>
Signed-off-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/46664
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/cl_object.h  |  3 +-
 fs/lustre/include/lustre_osc.h |  2 +-
 fs/lustre/include/obd.h        |  3 ++
 fs/lustre/llite/file.c         |  3 ++
 fs/lustre/obdclass/cl_page.c   |  9 +++-
 fs/lustre/osc/osc_page.c       |  1 -
 fs/lustre/osc/osc_request.c    | 97 +++++++++++++++++++-----------------------
 7 files changed, 60 insertions(+), 58 deletions(-)

diff --git a/fs/lustre/include/cl_object.h b/fs/lustre/include/cl_object.h
index af708cc..ab7f0f2 100644
--- a/fs/lustre/include/cl_object.h
+++ b/fs/lustre/include/cl_object.h
@@ -735,7 +735,8 @@ struct cl_page {
 	refcount_t			 cp_ref;
 	/** layout_entry + stripe index, composed using lov_comp_index() */
 	unsigned int			 cp_lov_index;
-	pgoff_t				 cp_osc_index;
+	/** page->index of the page within the whole file */
+	pgoff_t				 cp_page_index;
 	/** An object this page is a part of. Immutable after creation. */
 	struct cl_object		*cp_obj;
 	/** vmpage */
diff --git a/fs/lustre/include/lustre_osc.h b/fs/lustre/include/lustre_osc.h
index 4c5eb1f..7551390 100644
--- a/fs/lustre/include/lustre_osc.h
+++ b/fs/lustre/include/lustre_osc.h
@@ -855,7 +855,7 @@ static inline struct osc_page *oap2osc(struct osc_async_page *oap)
 
 static inline pgoff_t osc_index(struct osc_page *opg)
 {
-	return opg->ops_cl.cpl_page->cp_osc_index;
+	return opg->ops_oap.oap_obj_off >> PAGE_SHIFT;
 }
 
 static inline struct cl_page *oap2cl_page(struct osc_async_page *oap)
diff --git a/fs/lustre/include/obd.h b/fs/lustre/include/obd.h
index ecee321..c5e2a24 100644
--- a/fs/lustre/include/obd.h
+++ b/fs/lustre/include/obd.h
@@ -1213,6 +1213,9 @@ static inline void client_adjust_max_dirty(struct client_obd *cli)
 					   1 << (20 - PAGE_SHIFT));
 }
 
+/* Must be used for page cache pages only,
+ * not safe otherwise (e.g. direct IO pages)
+ */
 static inline struct inode *page2inode(struct page *page)
 {
 	if (page->mapping) {
diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index 373efdd..4855156 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -440,6 +440,9 @@ int ll_file_release(struct inode *inode, struct file *file)
 
 static inline int ll_dom_readpage(void *data, struct page *page)
 {
+	/* since ll_dom_readpage is a page cache helper, it is safe to assume
+	 * mapping and host pointers are set here
+	 */
 	struct inode *inode = page2inode(page);
 	struct niobuf_local *lnb = data;
 	void *kaddr;
diff --git a/fs/lustre/obdclass/cl_page.c b/fs/lustre/obdclass/cl_page.c
index 4bfa1c5..9326743 100644
--- a/fs/lustre/obdclass/cl_page.c
+++ b/fs/lustre/obdclass/cl_page.c
@@ -235,9 +235,16 @@ struct cl_page *cl_page_alloc(const struct lu_env *env, struct cl_object *o,
 		cl_page->cp_vmpage = vmpage;
 		cl_page->cp_state = CPS_CACHED;
 		cl_page->cp_type = type;
-		cl_page->cp_inode = NULL;
+		if (type == CPT_TRANSIENT)
+			/* ref to correct inode will be added
+			 * in ll_direct_rw_pages
+			 */
+			cl_page->cp_inode = NULL;
+		else
+			cl_page->cp_inode = page2inode(vmpage);
 		INIT_LIST_HEAD(&cl_page->cp_batch);
 		lu_ref_init(&cl_page->cp_reference);
+		cl_page->cp_page_index = ind;
 		cl_object_for_each(o2, o) {
 			if (o2->co_ops->coo_page_init) {
 				result = o2->co_ops->coo_page_init(env, o2,
diff --git a/fs/lustre/osc/osc_page.c b/fs/lustre/osc/osc_page.c
index cba5d02..f46b4e7 100644
--- a/fs/lustre/osc/osc_page.c
+++ b/fs/lustre/osc/osc_page.c
@@ -266,7 +266,6 @@ int osc_page_init(const struct lu_env *env, struct cl_object *obj,
 
 	opg->ops_srvlock = osc_io_srvlock(oio);
 	cl_page_slice_add(cl_page, &opg->ops_cl, obj, &osc_page_ops);
-	cl_page->cp_osc_index = index;
 
 	/* reserve an LRU space for this cl_page */
 	if (cl_page->cp_type == CPT_CACHEABLE) {
diff --git a/fs/lustre/osc/osc_request.c b/fs/lustre/osc/osc_request.c
index 43cd6c5..124d3c57 100644
--- a/fs/lustre/osc/osc_request.c
+++ b/fs/lustre/osc/osc_request.c
@@ -1417,21 +1417,13 @@ static int osc_brw_prep_request(int cmd, struct client_obd *cli,
 	struct inode *inode = NULL;
 	bool directio = false;
 	bool enable_checksum = true;
+	struct cl_page *clpage;
 
 	if (pga[0]->pg) {
-		inode = page2inode(pga[0]->pg);
-		if (!inode) {
-			/* Try to get reference to inode from cl_page if we are
-			 * dealing with direct IO, as handled pages are not
-			 * actual page cache pages.
-			 */
-			struct osc_async_page *oap = brw_page2oap(pga[0]);
-			struct cl_page *clpage = oap2cl_page(oap);
-
-			inode = clpage->cp_inode;
-			if (inode)
-				directio = true;
-		}
+		clpage = oap2cl_page(brw_page2oap(pga[0]));
+		inode = clpage->cp_inode;
+		if (clpage->cp_type == CPT_TRANSIENT)
+			directio = true;
 	}
 	if (OBD_FAIL_CHECK(OBD_FAIL_OSC_BRW_PREP_REQ))
 		return -ENOMEM; /* Recoverable */
@@ -1453,11 +1445,11 @@ static int osc_brw_prep_request(int cmd, struct client_obd *cli,
 	if (opc == OST_WRITE && inode && IS_ENCRYPTED(inode) &&
 	    fscrypt_has_encryption_key(inode)) {
 		for (i = 0; i < page_count; i++) {
-			struct brw_page *pg = pga[i];
+			struct brw_page *brwpg = pga[i];
 			struct page *data_page = NULL;
 			bool retried = false;
 			bool lockedbymyself;
-			u32 nunits = (pg->off & ~PAGE_MASK) + pg->count;
+			u32 nunits = (brwpg->off & ~PAGE_MASK) + brwpg->count;
 			struct address_space *map_orig = NULL;
 			pgoff_t index_orig;
 
@@ -1472,23 +1464,24 @@ static int osc_brw_prep_request(int cmd, struct client_obd *cli,
 			 * end in vvp_page_completion_write/cl_page_completion,
 			 * which means only once the page is fully processed.
 			 */
-			lockedbymyself = trylock_page(pg->pg);
+			lockedbymyself = trylock_page(brwpg->pg);
 			if (directio) {
-				map_orig = pg->pg->mapping;
-				pg->pg->mapping = inode->i_mapping;
-				index_orig = pg->pg->index;
-				pg->pg->index = pg->off >> PAGE_SHIFT;
+				map_orig = brwpg->pg->mapping;
+				brwpg->pg->mapping = inode->i_mapping;
+				index_orig = brwpg->pg->index;
+				clpage = oap2cl_page(brw_page2oap(brwpg));
+				brwpg->pg->index = clpage->cp_page_index;
 			}
 			data_page =
-				fscrypt_encrypt_pagecache_blocks(pg->pg,
+				fscrypt_encrypt_pagecache_blocks(brwpg->pg,
 								 nunits, 0,
 								 GFP_NOFS);
 			if (directio) {
-				pg->pg->mapping = map_orig;
-				pg->pg->index = index_orig;
+				brwpg->pg->mapping = map_orig;
+				brwpg->pg->index = index_orig;
 			}
 			if (lockedbymyself)
-				unlock_page(pg->pg);
+				unlock_page(brwpg->pg);
 			if (IS_ERR(data_page)) {
 				rc = PTR_ERR(data_page);
 				if (rc == -ENOMEM && !retried) {
@@ -1503,10 +1496,11 @@ static int osc_brw_prep_request(int cmd, struct client_obd *cli,
 			 * disambiguation in osc_release_bounce_pages().
 			 */
 			SetPageChecked(data_page);
-			pg->pg = data_page;
+			brwpg->pg = data_page;
 			/* there should be no gap in the middle of page array */
 			if (i == page_count - 1) {
-				struct osc_async_page *oap = brw_page2oap(pg);
+				struct osc_async_page *oap =
+					brw_page2oap(brwpg);
 
 				oa->o_size = oap->oap_count +
 					     oap->oap_obj_off +
@@ -1515,10 +1509,10 @@ static int osc_brw_prep_request(int cmd, struct client_obd *cli,
 			/* len is forced to nunits, and relative offset to 0
 			 * so store the old, clear text info
 			 */
-			pg->bp_count_diff = nunits - pg->count;
-			pg->count = nunits;
-			pg->bp_off_diff = pg->off & ~PAGE_MASK;
-			pg->off = pg->off & PAGE_MASK;
+			brwpg->bp_count_diff = nunits - brwpg->count;
+			brwpg->count = nunits;
+			brwpg->bp_off_diff = brwpg->off & ~PAGE_MASK;
+			brwpg->off = brwpg->off & PAGE_MASK;
 		}
 	} else if (opc == OST_WRITE && inode && IS_ENCRYPTED(inode)) {
 		struct osc_async_page *oap = brw_page2oap(pga[0]);
@@ -1991,8 +1985,9 @@ static int osc_brw_fini_request(struct ptlrpc_request *req, int rc)
 	const char *obd_name = cli->cl_import->imp_obd->obd_name;
 	struct ost_body *body;
 	u32 client_cksum = 0;
-	struct inode *inode;
+	struct inode *inode = NULL;
 	unsigned int blockbits = 0, blocksize = 0;
+	struct cl_page *clpage;
 
 	if (rc < 0 && rc != -EDQUOT) {
 		DEBUG_REQ(D_INFO, req, "Failed request: rc = %d", rc);
@@ -2186,19 +2181,12 @@ static int osc_brw_fini_request(struct ptlrpc_request *req, int rc)
 		rc = 0;
 	}
 
-	inode = page2inode(aa->aa_ppga[0]->pg);
-	if (!inode) {
-		/* Try to get reference to inode from cl_page if we are
-		 * dealing with direct IO, as handled pages are not
-		 * actual page cache pages.
-		 */
-		struct osc_async_page *oap = brw_page2oap(aa->aa_ppga[0]);
-
-		inode = oap2cl_page(oap)->cp_inode;
-		if (inode) {
-			blockbits = inode->i_blkbits;
-			blocksize = 1 << blockbits;
-		}
+	/* get the inode from the first cl_page */
+	clpage = oap2cl_page(brw_page2oap(aa->aa_ppga[0]));
+	inode = clpage->cp_inode;
+	if (clpage->cp_type == CPT_TRANSIENT && inode) {
+		blockbits = inode->i_blkbits;
+		blocksize = 1 << blockbits;
 	}
 	if (inode && IS_ENCRYPTED(inode)) {
 		int idx;
@@ -2208,19 +2196,19 @@ static int osc_brw_fini_request(struct ptlrpc_request *req, int rc)
 			goto out;
 		}
 		for (idx = 0; idx < aa->aa_page_count; idx++) {
-			struct brw_page *pg = aa->aa_ppga[idx];
+			struct brw_page *brwpg = aa->aa_ppga[idx];
 			unsigned int offs = 0;
 
 			while (offs < PAGE_SIZE) {
 				/* do not decrypt if page is all 0s */
-				if (memchr_inv(page_address(pg->pg) + offs, 0,
-					       LUSTRE_ENCRYPTION_UNIT_SIZE) == NULL) {
+				if (!memchr_inv(page_address(brwpg->pg) + offs, 0,
+					        LUSTRE_ENCRYPTION_UNIT_SIZE)) {
 					/* if page is empty forward info to
 					 * upper layers (ll_io_zero_page) by
 					 * clearing PagePrivate2
 					 */
 					if (!offs)
-						ClearPagePrivate2(pg->pg);
+						ClearPagePrivate2(brwpg->pg);
 					break;
 				}
 
@@ -2230,24 +2218,25 @@ static int osc_brw_fini_request(struct ptlrpc_request *req, int rc)
 					 * input parameter. Page does not need
 					 * to be locked.
 					 */
-					u64 lblk_num =
-						((u64)(pg->off >> PAGE_SHIFT) <<
-						      (PAGE_SHIFT - blockbits)) +
-						      (offs >> blockbits);
+					u64 lblk_num;
 					unsigned int i;
 
+					clpage = oap2cl_page(brw_page2oap(brwpg));
+					lblk_num = ((u64)(brwpg->off >> PAGE_SHIFT) <<
+							 (PAGE_SHIFT - blockbits)) +
+							 (offs >> blockbits);
 					for (i = offs;
 					     i < offs + LUSTRE_ENCRYPTION_UNIT_SIZE;
 					     i += blocksize, lblk_num++) {
 						rc = fscrypt_decrypt_block_inplace(inode,
-										   pg->pg,
+										   brwpg->pg,
 										   blocksize, i,
 										   lblk_num);
 						if (rc)
 							break;
 					}
 				} else {
-					rc = fscrypt_decrypt_pagecache_blocks(pg->pg,
+					rc = fscrypt_decrypt_pagecache_blocks(brwpg->pg,
 									      LUSTRE_ENCRYPTION_UNIT_SIZE,
 									      offs);
 				}
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
