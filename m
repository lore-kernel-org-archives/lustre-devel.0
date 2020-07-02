From: James Simmons <jsimmons@infradead.org>
Date: Wed,  1 Jul 2020 20:04:44 -0400
Subject: [lustre-devel] [PATCH 04/18] lustre: sec: decryption for read path
In-Reply-To: <1593648298-10571-1-git-send-email-jsimmons@infradead.org>
References: <1593648298-10571-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1593648298-10571-5-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Sebastien Buisson <sbuisson@ddn.com>

With the support for encryption, all files need to be opened with
fscrypt_file_open(). fscrypt will retrieve encryption context if
file is encrypted, or immediately return if not.
Decryption itself is carried out in osc_brw_fini_request(), right
after the reply has been received from the server.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12275
Lustre-commit: eecf86131d099 ("LU-12275 sec: decryption for read path")
Signed-off-by: Sebastien Buisson <sbuisson@ddn.com>
Reviewed-on: https://review.whamcloud.com/36145
Reviewed-by: Patrick Farrell <farr0186@gmail.com>
Reviewed-by: John L. Hammond <jhammond@whamcloud.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/crypto.c    | 10 ++++++++--
 fs/lustre/llite/file.c      |  6 ++++++
 fs/lustre/osc/osc_request.c | 31 +++++++++++++++++++++++++++++++
 3 files changed, 45 insertions(+), 2 deletions(-)

diff --git a/fs/lustre/llite/crypto.c b/fs/lustre/llite/crypto.c
index f411343..157017f 100644
--- a/fs/lustre/llite/crypto.c
+++ b/fs/lustre/llite/crypto.c
@@ -32,6 +32,7 @@
 static int ll_get_context(struct inode *inode, void *ctx, size_t len)
 {
 	struct dentry *dentry;
+	int rc;
 
 	if (hlist_empty(&inode->i_dentry))
 		return -ENODATA;
@@ -39,8 +40,13 @@ static int ll_get_context(struct inode *inode, void *ctx, size_t len)
 	hlist_for_each_entry(dentry, &inode->i_dentry, d_u.d_alias)
 		break;
 
-	return __vfs_getxattr(dentry, inode, LL_XATTR_NAME_ENCRYPTION_CONTEXT,
-			      ctx, len);
+	rc = __vfs_getxattr(dentry, inode, LL_XATTR_NAME_ENCRYPTION_CONTEXT,
+			    ctx, len);
+
+	/* used as encryption unit size */
+	if (S_ISREG(inode->i_mode))
+		inode->i_blkbits = LUSTRE_ENCRYPTION_BLOCKBITS;
+	return rc;
 }
 
 static int ll_set_context(struct inode *inode, const void *ctx, size_t len,
diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index 8264b86..3b04952 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -714,6 +714,12 @@ int ll_file_open(struct inode *inode, struct file *file)
 	it = file->private_data; /* XXX: compat macro */
 	file->private_data = NULL; /* prevent ll_local_open assertion */
 
+	if (S_ISREG(inode->i_mode)) {
+		rc = llcrypt_file_open(inode, file);
+		if (rc)
+			goto out_nofiledata;
+	}
+
 	fd = ll_file_data_get();
 	if (!fd) {
 		rc = -ENOMEM;
diff --git a/fs/lustre/osc/osc_request.c b/fs/lustre/osc/osc_request.c
index db97d37..65d17a8 100644
--- a/fs/lustre/osc/osc_request.c
+++ b/fs/lustre/osc/osc_request.c
@@ -1865,6 +1865,7 @@ static int osc_brw_fini_request(struct ptlrpc_request *req, int rc)
 	const char *obd_name = cli->cl_import->imp_obd->obd_name;
 	struct ost_body *body;
 	u32 client_cksum = 0;
+	struct inode *inode;
 
 	if (rc < 0 && rc != -EDQUOT) {
 		DEBUG_REQ(D_INFO, req, "Failed request: rc = %d", rc);
@@ -2055,6 +2056,36 @@ static int osc_brw_fini_request(struct ptlrpc_request *req, int rc)
 	} else {
 		rc = 0;
 	}
+
+	inode = page2inode(aa->aa_ppga[0]->pg);
+	if (inode && IS_ENCRYPTED(inode)) {
+		int idx;
+
+		if (!llcrypt_has_encryption_key(inode)) {
+			CDEBUG(D_SEC, "no enc key for ino %lu\n", inode->i_ino);
+			goto out;
+		}
+		for (idx = 0; idx < aa->aa_page_count; idx++) {
+			struct brw_page *pg = aa->aa_ppga[idx];
+			u64 *p, *q;
+
+			/* do not decrypt if page is all 0s */
+			p = q = page_address(pg->pg);
+			while (p - q < PAGE_SIZE / sizeof(*p)) {
+				if (*p != 0)
+					break;
+				p++;
+			}
+			if (p - q == PAGE_SIZE / sizeof(*p))
+				continue;
+
+			rc = llcrypt_decrypt_pagecache_blocks(pg->pg,
+							      PAGE_SIZE, 0);
+			if (rc)
+				goto out;
+		}
+	}
+
 out:
 	if (rc >= 0)
 		lustre_get_wire_obdo(&req->rq_import->imp_connect_data,
-- 
1.8.3.1
