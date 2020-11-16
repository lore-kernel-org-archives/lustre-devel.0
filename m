From: James Simmons <jsimmons@infradead.org>
Date: Sun, 15 Nov 2020 19:59:57 -0500
Subject: [lustre-devel] [PATCH 24/28] lustre: sec: O_DIRECT for encrypted
 file
In-Reply-To: <1605488401-981-1-git-send-email-jsimmons@infradead.org>
References: <1605488401-981-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1605488401-981-25-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Sebastien Buisson <sbuisson@ddn.com>

Add O_DIRECT support for encrypted files.
By default, fscrypt does not support O_DIRECT because it needs
pagecache pages to proceed.
With Lustre, we can make use of pages being used for sending RPCs.
They can be twisted so that they have a proper mapping and index,
suitable for encryption/decryption.

One of the benefits of O_DIRECT support for encrypted files is that
we get support for mirroring at the same time.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12275
Lustre-commit: 728036f25635a ("LU-12275 sec: O_DIRECT for encrypted file")
Signed-off-by: Sebastien Buisson <sbuisson@ddn.com>
Reviewed-on: https://review.whamcloud.com/38967
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Wang Shilong <wshilong@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../client_side_encryption/access_semantics.txt    |  3 --
 fs/lustre/llite/dir.c                              |  1 -
 fs/lustre/llite/llite_lib.c                        | 11 ++++++-
 fs/lustre/llite/rw26.c                             | 27 +++++++++++++---
 fs/lustre/llite/super25.c                          | 11 +++++++
 fs/lustre/obdclass/cl_io.c                         | 11 +++++++
 fs/lustre/osc/osc_request.c                        | 37 ++++++++++++++++++----
 fs/lustre/ptlrpc/wiretest.c                        |  2 ++
 8 files changed, 87 insertions(+), 16 deletions(-)

diff --git a/Documentation/lustre/client_side_encryption/access_semantics.txt b/Documentation/lustre/client_side_encryption/access_semantics.txt
index fe2c28d..7ed0bc7 100644
--- a/Documentation/lustre/client_side_encryption/access_semantics.txt
+++ b/Documentation/lustre/client_side_encryption/access_semantics.txt
@@ -42,9 +42,6 @@ astute users may notice some differences in behavior:
   may be used to overwrite the source files but isn't guaranteed to be
   effective on all filesystems and storage devices.
 
-- Direct I/O is not supported on encrypted files.  Attempts to use
-  direct I/O on such files will fall back to buffered I/O.
-
 - The fallocate operations FALLOC_FL_COLLAPSE_RANGE,
   FALLOC_FL_INSERT_RANGE, and FALLOC_FL_ZERO_RANGE are not supported
   on encrypted files and will fail with EOPNOTSUPP.
diff --git a/fs/lustre/llite/dir.c b/fs/lustre/llite/dir.c
index 262aea0..6bc95d9 100644
--- a/fs/lustre/llite/dir.c
+++ b/fs/lustre/llite/dir.c
@@ -481,7 +481,6 @@ static int ll_dir_setdirstripe(struct dentry *dparent, struct lmv_user_md *lump,
 			goto out_op_data;
 	}
 
-
 	op_data->op_cli_flags |= CLI_SET_MEA;
 	err = md_create(sbi->ll_md_exp, op_data, lump, len, mode,
 			from_kuid(&init_user_ns, current_fsuid()),
diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index a4042b8..e4036af 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -1759,6 +1759,7 @@ int ll_io_zero_page(struct inode *inode, pgoff_t index, pgoff_t offset,
 			 * file, we must not zero and write as below. Subsequent
 			 * server-side truncate will handle things correctly.
 			 */
+			rc = 0;
 			goto clpfini;
 		ClearPagePrivate2(vmpage);
 		if (rc)
@@ -1960,7 +1961,15 @@ int ll_setattr_raw(struct dentry *dentry, struct iattr *attr,
 			    attr->ia_valid & ATTR_SIZE) {
 				xvalid |= OP_XVALID_FLAGS;
 				flags = LUSTRE_ENCRYPT_FL;
-				if (attr->ia_size & ~PAGE_MASK) {
+				/* Call to ll_io_zero_page is not necessary if
+				 * truncating on PAGE_SIZE boundary, because
+				 * whole pages will be wiped.
+				 * In case of Direct IO, all we need is to set
+				 * new size.
+				 */
+				if (attr->ia_size & ~PAGE_MASK &&
+				    !(attr->ia_valid & ATTR_FILE &&
+				      attr->ia_file->f_flags & O_DIRECT)) {
 					pgoff_t offset;
 
 					offset = attr->ia_size & (PAGE_SIZE - 1);
diff --git a/fs/lustre/llite/rw26.c b/fs/lustre/llite/rw26.c
index a4ae211..1736e9a 100644
--- a/fs/lustre/llite/rw26.c
+++ b/fs/lustre/llite/rw26.c
@@ -207,6 +207,7 @@ struct ll_dio_pages {
 	int io_pages = 0;
 	size_t page_size = cl_page_size(obj);
 	int i;
+	pgoff_t index = offset >> PAGE_SHIFT;
 	ssize_t rc = 0;
 
 	cl_2queue_init(queue);
@@ -226,6 +227,28 @@ struct ll_dio_pages {
 		}
 
 		page->cp_sync_io = anchor;
+		if (inode && IS_ENCRYPTED(inode)) {
+			struct page *vmpage = cl_page_vmpage(page);
+
+			/* In case of Direct IO on encrypted file, we need to
+			 * set the correct page index, and add a reference to
+			 * the mapping. This is required by llcrypt to proceed
+			 * to encryption/decryption, because each block is
+			 * encrypted independently, and each block's IV is set
+			 * to the logical block number within the file.
+			 * This is safe because we know these pages are private
+			 * to the thread doing the Direct IO, and despite
+			 * setting a mapping on the pages, cached lookups will
+			 * not find them.
+			 * Set PageChecked to detect special case of Direct IO
+			 * in osc_brw_fini_request().
+			 * Reference to the mapping and PageChecked flag are
+			 * removed in cl_aio_end().
+			 */
+			vmpage->index = index++;
+			vmpage->mapping = inode->i_mapping;
+			SetPageChecked(vmpage);
+		}
 		cl_page_list_add(&queue->c2_qin, page);
 		/*
 		 * Set page clip to tell transfer formation engine
@@ -297,10 +320,6 @@ static ssize_t ll_direct_IO(struct kiocb *iocb, struct iov_iter *iter)
 	int rw = iov_iter_rw(iter);
 	struct vvp_io *vio;
 
-	/* if file is encrypted, return 0 so that we fall back to buffered IO */
-	if (IS_ENCRYPTED(inode))
-		return 0;
-
 	/* Check EOF by ourselves */
 	if (rw == READ && file_offset >= i_size_read(inode))
 		return 0;
diff --git a/fs/lustre/llite/super25.c b/fs/lustre/llite/super25.c
index 8eb3fc3..d02c8cf 100644
--- a/fs/lustre/llite/super25.c
+++ b/fs/lustre/llite/super25.c
@@ -72,10 +72,21 @@ static void ll_destroy_inode(struct inode *inode)
 	call_rcu(&inode->i_rcu, ll_inode_destroy_callback);
 }
 
+static int ll_drop_inode(struct inode *inode)
+{
+	int drop = generic_drop_inode(inode);
+
+	if (!drop)
+		drop = llcrypt_drop_inode(inode);
+
+	return drop;
+}
+
 /* exported operations */
 struct super_operations lustre_super_operations = {
 	.alloc_inode		= ll_alloc_inode,
 	.destroy_inode		= ll_destroy_inode,
+	.drop_inode		= ll_drop_inode,
 	.evict_inode		= ll_delete_inode,
 	.put_super		= ll_put_super,
 	.statfs			= ll_statfs,
diff --git a/fs/lustre/obdclass/cl_io.c b/fs/lustre/obdclass/cl_io.c
index c57a3766..37b0828 100644
--- a/fs/lustre/obdclass/cl_io.c
+++ b/fs/lustre/obdclass/cl_io.c
@@ -1081,8 +1081,19 @@ static void cl_aio_end(const struct lu_env *env, struct cl_sync_io *anchor)
 	/* release pages */
 	while (aio->cda_pages.pl_nr > 0) {
 		struct cl_page *page = cl_page_list_first(&aio->cda_pages);
+		struct page *vmpage = cl_page_vmpage(page);
+		struct inode *inode = vmpage ? page2inode(vmpage) : NULL;
 
 		cl_page_get(page);
+		/* We end up here in case of Direct IO only. For encrypted file,
+		 * mapping was set on pages in ll_direct_rw_pages(), so it has
+		 * to be cleared now before page cleanup.
+		 * PageChecked flag was also set there, so we clean up here.
+		 */
+		if (inode && IS_ENCRYPTED(inode)) {
+			vmpage->mapping = NULL;
+			ClearPageChecked(vmpage);
+		}
 		cl_page_list_del(env, &aio->cda_pages, page);
 		cl_page_delete(env, page);
 		cl_page_put(env, page);
diff --git a/fs/lustre/osc/osc_request.c b/fs/lustre/osc/osc_request.c
index 8a8a624..bf9ce44 100644
--- a/fs/lustre/osc/osc_request.c
+++ b/fs/lustre/osc/osc_request.c
@@ -1369,13 +1369,9 @@ static inline void osc_release_bounce_pages(struct brw_page **pga,
 	int i;
 
 	for (i = 0; i < page_count; i++) {
-		if (pga[i]->pg->mapping)
+		if (!pga[i]->pg->mapping)
 			/* bounce pages are unmapped */
-			continue;
-		if (pga[i]->flag & OBD_BRW_SYNC)
-			/* sync transfer cannot have encrypted pages */
-			continue;
-		llcrypt_finalize_bounce_page(&pga[i]->pg);
+			llcrypt_finalize_bounce_page(&pga[i]->pg);
 		pga[i]->count -= pga[i]->bp_count_diff;
 		pga[i]->off += pga[i]->bp_off_diff;
 	}
@@ -1470,6 +1466,19 @@ static int osc_brw_prep_request(int cmd, struct client_obd *cli,
 			pg->bp_off_diff = pg->off & ~PAGE_MASK;
 			pg->off = pg->off & PAGE_MASK;
 		}
+	} else if (opc == OST_READ && inode && IS_ENCRYPTED(inode)) {
+		for (i = 0; i < page_count; i++) {
+			struct brw_page *pg = pga[i];
+
+			/* count/off are forced to cover the whole page so that
+			 * all encrypted data is stored on the OST, so adjust
+			 * bp_{count,off}_diff for the size of the clear text.
+			 */
+			pg->bp_count_diff = PAGE_SIZE - pg->count;
+			pg->count = PAGE_SIZE;
+			pg->bp_off_diff = pg->off & ~PAGE_MASK;
+			pg->off = pg->off & PAGE_MASK;
+		}
 	}
 
 	for (niocount = i = 1; i < page_count; i++) {
@@ -1483,8 +1492,13 @@ static int osc_brw_prep_request(int cmd, struct client_obd *cli,
 	req_capsule_set_size(pill, &RMF_NIOBUF_REMOTE, RCL_CLIENT,
 			     niocount * sizeof(*niobuf));
 
-	for (i = 0; i < page_count; i++)
+	for (i = 0; i < page_count; i++) {
 		short_io_size += pga[i]->count;
+		if (!inode || !IS_ENCRYPTED(inode)) {
+			pga[i]->bp_count_diff = 0;
+			pga[i]->bp_off_diff = 0;
+		}
+	}
 
 	/* Check if read/write is small enough to be a short io. */
 	if (short_io_size > cli->cl_max_short_io_bytes || niocount > 1 ||
@@ -2093,8 +2107,17 @@ static int osc_brw_fini_request(struct ptlrpc_request *req, int rc)
 				continue;
 			}
 
+			/* The page is already locked when we arrive here,
+			 * except when we deal with a twisted page for
+			 * specific Direct IO support, in which case
+			 * PageChecked flag is set on page.
+			 */
+			if (PageChecked(pg->pg))
+				lock_page(pg->pg);
 			rc = llcrypt_decrypt_pagecache_blocks(pg->pg,
 							      PAGE_SIZE, 0);
+			if (PageChecked(pg->pg))
+				unlock_page(pg->pg);
 			if (rc)
 				goto out;
 		}
diff --git a/fs/lustre/ptlrpc/wiretest.c b/fs/lustre/ptlrpc/wiretest.c
index ba19b78..c8b97fa 100644
--- a/fs/lustre/ptlrpc/wiretest.c
+++ b/fs/lustre/ptlrpc/wiretest.c
@@ -2307,6 +2307,8 @@ void lustre_assert_wire_constants(void)
 		 LUSTRE_TOPDIR_FL);
 	LASSERTF(LUSTRE_INLINE_DATA_FL == 0x10000000, "found 0x%.8x\n",
 		 LUSTRE_INLINE_DATA_FL);
+	LASSERTF(LUSTRE_ENCRYPT_FL == 0x00800000UL, "found 0x%.8x\n",
+		 LUSTRE_ENCRYPT_FL);
 	LASSERTF(MDS_INODELOCK_LOOKUP == 0x00000001UL, "found 0x%.8x\n",
 		 MDS_INODELOCK_LOOKUP);
 	LASSERTF(MDS_INODELOCK_UPDATE == 0x00000002UL, "found 0x%.8x\n",
-- 
1.8.3.1
