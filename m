From: James Simmons <jsimmons@infradead.org>
Date: Tue, 11 Aug 2020 08:20:04 -0400
Subject: [lustre-devel] [PATCH 08/23] lustre: sec: encryption support for
 DoM files
In-Reply-To: <1597148419-20629-1-git-send-email-jsimmons@infradead.org>
References: <1597148419-20629-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1597148419-20629-9-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Sebastien Buisson <sbuisson@ddn.com>

On client side, data read from DoM files do not go through the OSC
layer. So implement file decryption in ll_dom_finish_open() right
after file data has been put in cache pages.
On server side, DoM file size needs to be properly set on MDT when
content is encrypted. Pages are full of encrypted data, but inode size
must be apparent, clear text object size.
For reads of DoM encrypted files to work proprely, we also need to
make sure we send whole encryption units to client side.
Also add sanity-sec test_50 to exercise encryption of DoM files.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12275
Lustre-commit: a71586d4ee8d6 ("LU-12275 sec: encryption support for DoM files")
Signed-off-by: Sebastien Buisson <sbuisson@ddn.com>
Reviewed-on: https://review.whamcloud.com/38702
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Mike Pershin <mpershin@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/crypto.c | 10 +++-------
 fs/lustre/llite/file.c   | 20 +++++++++++++++++--
 fs/lustre/llite/namei.c  | 52 ++++++++++++++++++++++++++++--------------------
 3 files changed, 51 insertions(+), 31 deletions(-)

diff --git a/fs/lustre/llite/crypto.c b/fs/lustre/llite/crypto.c
index 83ed316..d37f0a9 100644
--- a/fs/lustre/llite/crypto.c
+++ b/fs/lustre/llite/crypto.c
@@ -31,17 +31,13 @@
 
 static int ll_get_context(struct inode *inode, void *ctx, size_t len)
 {
-	struct dentry *dentry;
+	struct dentry *dentry = d_find_any_alias(inode);
 	int rc;
 
-	if (hlist_empty(&inode->i_dentry))
-		return -ENODATA;
-
-	hlist_for_each_entry(dentry, &inode->i_dentry, d_u.d_alias)
-		break;
-
 	rc = __vfs_getxattr(dentry, inode, LL_XATTR_NAME_ENCRYPTION_CONTEXT,
 			    ctx, len);
+	if (dentry)
+		dput(dentry);
 
 	/* used as encryption unit size */
 	if (S_ISREG(inode->i_mode))
diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index 757950f..7d00728 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -429,8 +429,10 @@ int ll_file_release(struct inode *inode, struct file *file)
 
 static inline int ll_dom_readpage(void *data, struct page *page)
 {
+	struct inode *inode = page2inode(page);
 	struct niobuf_local *lnb = data;
 	void *kaddr;
+	int rc = 0;
 
 	kaddr = kmap_atomic(page);
 	memcpy(kaddr, lnb->lnb_data, lnb->lnb_len);
@@ -440,9 +442,22 @@ static inline int ll_dom_readpage(void *data, struct page *page)
 	flush_dcache_page(page);
 	SetPageUptodate(page);
 	kunmap_atomic(kaddr);
+
+	if (inode && IS_ENCRYPTED(inode) && S_ISREG(inode->i_mode)) {
+		if (!llcrypt_has_encryption_key(inode))
+			CDEBUG(D_SEC, "no enc key for " DFID "\n",
+			       PFID(ll_inode2fid(inode)));
+		/* decrypt only if page is not empty */
+		else if (memcmp(page_address(page),
+				page_address(ZERO_PAGE(0)),
+				PAGE_SIZE) != 0)
+			rc = llcrypt_decrypt_pagecache_blocks(page,
+							      PAGE_SIZE,
+							      0);
+	}
 	unlock_page(page);
 
-	return 0;
+	return rc;
 }
 
 void ll_dom_finish_open(struct inode *inode, struct ptlrpc_request *req,
@@ -481,7 +496,8 @@ void ll_dom_finish_open(struct inode *inode, struct ptlrpc_request *req,
 	 * buffer, in both cases total size should be equal to the file size.
 	 */
 	body = req_capsule_server_get(&req->rq_pill, &RMF_MDT_BODY);
-	if (rnb->rnb_offset + rnb->rnb_len != body->mbo_dom_size) {
+	if (rnb->rnb_offset + rnb->rnb_len != body->mbo_dom_size &&
+	    !(inode && IS_ENCRYPTED(inode))) {
 		CERROR("%s: server returns off/len %llu/%u but size %llu\n",
 		       ll_i2sbi(inode)->ll_fsname, rnb->rnb_offset,
 		       rnb->rnb_len, body->mbo_dom_size);
diff --git a/fs/lustre/llite/namei.c b/fs/lustre/llite/namei.c
index 3fbcbbd..a268c93 100644
--- a/fs/lustre/llite/namei.c
+++ b/fs/lustre/llite/namei.c
@@ -629,6 +629,36 @@ static int ll_lookup_it_finish(struct ptlrpc_request *request,
 		if (rc)
 			return rc;
 
+		/* If encryption context was returned by MDT, put it in
+		 * inode now to save an extra getxattr and avoid deadlock.
+		 */
+		if (body->mbo_valid & OBD_MD_ENCCTX) {
+			encctx = req_capsule_server_get(pill, &RMF_FILE_ENCCTX);
+			encctxlen = req_capsule_get_size(pill,
+							 &RMF_FILE_ENCCTX,
+							 RCL_SERVER);
+
+			if (encctxlen) {
+				CDEBUG(D_SEC,
+				       "server returned encryption ctx for " DFID "\n",
+				       PFID(ll_inode2fid(inode)));
+				rc = ll_xattr_cache_insert(inode,
+							   LL_XATTR_NAME_ENCRYPTION_CONTEXT,
+							   encctx, encctxlen);
+				if (rc) {
+					CWARN("%s: cannot set enc ctx for " DFID ": rc = %d\n",
+					      ll_i2sbi(inode)->ll_fsname,
+					      PFID(ll_inode2fid(inode)), rc);
+				} else if (encrypt) {
+					rc = llcrypt_get_encryption_info(inode);
+					if (rc)
+						CDEBUG(D_SEC,
+						       "cannot get enc info for " DFID ": rc = %d\n",
+						       PFID(ll_inode2fid(inode)), rc);
+				}
+			}
+		}
+
 		if (it->it_op & IT_OPEN)
 			ll_dom_finish_open(inode, request, it);
 
@@ -674,28 +704,6 @@ static int ll_lookup_it_finish(struct ptlrpc_request *request,
 				      rc);
 		}
 
-		/* If encryption context was returned by MDT, put it in
-		 * inode now to save an extra getxattr and avoid deadlock.
-		 */
-		if (body->mbo_valid & OBD_MD_ENCCTX) {
-			encctx = req_capsule_server_get(pill, &RMF_FILE_ENCCTX);
-			encctxlen = req_capsule_get_size(pill,
-							 &RMF_FILE_ENCCTX,
-							 RCL_SERVER);
-
-			if (encctxlen) {
-				CDEBUG(D_SEC,
-				       "server returned encryption ctx for " DFID "\n",
-				       PFID(ll_inode2fid(inode)));
-				rc = ll_xattr_cache_insert(inode,
-							   LL_XATTR_NAME_ENCRYPTION_CONTEXT,
-							   encctx, encctxlen);
-				if (rc)
-					CWARN("%s: cannot set enc ctx for " DFID ": rc = %d\n",
-					      ll_i2sbi(inode)->ll_fsname,
-					      PFID(ll_inode2fid(inode)), rc);
-			}
-		}
 	}
 
 	alias = ll_splice_alias(inode, *de);
-- 
1.8.3.1
