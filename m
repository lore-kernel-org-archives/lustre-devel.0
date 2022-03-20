Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 8E6B6C433FE
	for <lustre-devel@archiver.kernel.org>; Sun, 20 Mar 2022 13:31:19 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 1414421EB66;
	Sun, 20 Mar 2022 06:31:16 -0700 (PDT)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id B18D621CA7D
 for <lustre-devel@lists.lustre.org>; Sun, 20 Mar 2022 06:31:10 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 05183ED7;
 Sun, 20 Mar 2022 09:31:08 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id F3AD2E41FE; Sun, 20 Mar 2022 09:31:07 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 20 Mar 2022 09:30:22 -0400
Message-Id: <1647783064-20688-9-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1647783064-20688-1-git-send-email-jsimmons@infradead.org>
References: <1647783064-20688-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 08/50] lustre: sec: make client encryption
 compatible with ext4
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

In order to benefit from encrypted file handling implemented in
e2fsprogs, we need to adjust the way Lustre deals with encryption
context of files.

First, the encryption context needs to be stored in an xattr named
"encryption.c" instead of "security.c". But neither llite nor ldiskfs
has an xattr handler for this "encryption." xattr type. So we need
to export ldiskfs_xattr_get and ldiskfs_xattr_set_handle symbols for
this to work.

Second, we set the LDISKFS_ENCRYPT_FL flag on files for which we set
the 'encryption.c' xattr. But we just keep this flag for on-disk
inodes, and make sure the flag is cleared for in-memory inodes.
The purpose is to help e2fsprogs with encrypted files handling, while
not disturbing Lustre server side with the encryption flag (servers
are not supposed to know about it for Lustre client-side encryption).

To maintain compatibility with 2.14 in which encryption context is
stored in "security.c" xattr, we try to fetch enc context from this
xattr if getting it from "encryption.c" fails. On client side, in all
cases everything looks like encryption context is stored in
"encryption.c".

WC-bug-id: https://jira.whamcloud.com/browse/LU-13717
Lustre-commit: 4231fab66eab3e984 ("LU-13717 sec: make client encryption compatible with ext4")
Signed-off-by: Sebastien Buisson <sbuisson@ddn.com>
Reviewed-on: https://review.whamcloud.com/45211
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Li Dongyang <dongyangli@ddn.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/crypto.c               | 42 ++++++++--------------
 fs/lustre/llite/llite_internal.h       | 14 +++-----
 fs/lustre/llite/xattr.c                | 65 +++++++++++++++-------------------
 include/uapi/linux/lustre/lustre_idl.h |  5 +--
 4 files changed, 50 insertions(+), 76 deletions(-)

diff --git a/fs/lustre/llite/crypto.c b/fs/lustre/llite/crypto.c
index 6a12b6c..f310d4c 100644
--- a/fs/lustre/llite/crypto.c
+++ b/fs/lustre/llite/crypto.c
@@ -31,29 +31,13 @@
 
 static int ll_get_context(struct inode *inode, void *ctx, size_t len)
 {
-	struct dentry *dentry = d_find_any_alias(inode);
-	struct lu_env *env;
-	u16 refcheck;
 	int rc;
 
-	env = cl_env_get(&refcheck);
-	if (IS_ERR(env))
-		return PTR_ERR(env);
-
-	/* Set lcc_getencctx=1 to allow this thread to read
-	 * LL_XATTR_NAME_ENCRYPTION_CONTEXT xattr, as requested by fscrypt.
+	/* Get enc context xattr directly instead of going through the VFS,
+	 * as there is no xattr handler for "encryption.".
 	 */
-	ll_cl_add(inode, env, NULL, LCC_RW);
-	ll_env_info(env)->lti_io_ctx.lcc_getencctx = 1;
-
-	rc = __vfs_getxattr(dentry, inode, LL_XATTR_NAME_ENCRYPTION_CONTEXT,
-			    ctx, len);
-
-	ll_cl_remove(inode, env);
-	cl_env_put(env, &refcheck);
-
-	if (dentry)
-		dput(dentry);
+	rc = ll_xattr_list(inode, LL_XATTR_NAME_ENCRYPTION_CONTEXT,
+			   XATTR_ENCRYPTION_T, ctx, len, OBD_MD_FLXATTR);
 
 	/* used as encryption unit size */
 	if (S_ISREG(inode->i_mode))
@@ -90,15 +74,15 @@ int ll_set_encflags(struct inode *inode, void *encctx, u32 encctxlen,
  *   op_data, so that it will be sent along to the server with the request that
  *   the caller is preparing, thus saving a setxattr request.
  * - inode is not NULL:
- *   normal case in which passed fs_data is a struct dentry *, letting proceed
- *   with setxattr operation.
+ *   normal case, letting proceed with setxattr operation.
  *   This use case should only be used when explicitly setting a new encryption
  *   policy on an existing, empty directory.
  */
 static int ll_set_context(struct inode *inode, const void *ctx, size_t len,
 			  void *fs_data)
 {
-	struct dentry *dentry;
+	struct ptlrpc_request *req = NULL;
+	struct ll_sb_info *sbi;
 	int rc;
 
 	if (!inode) {
@@ -119,12 +103,16 @@ static int ll_set_context(struct inode *inode, const void *ctx, size_t len,
 	if (is_root_inode(inode))
 		return -EPERM;
 
-	dentry = (struct dentry *)fs_data;
-	set_bit(LLIF_SET_ENC_CTX, &ll_i2info(inode)->lli_flags);
-	rc = __vfs_setxattr(dentry, inode, LL_XATTR_NAME_ENCRYPTION_CONTEXT,
-			    ctx, len, XATTR_CREATE);
+	sbi = ll_i2sbi(inode);
+	/* Send setxattr request to lower layers directly instead of going
+	 * through the VFS, as there is no xattr handler for "encryption.".
+	 */
+	rc = md_setxattr(sbi->ll_md_exp, ll_inode2fid(inode),
+			 OBD_MD_FLXATTR, LL_XATTR_NAME_ENCRYPTION_CONTEXT,
+			 ctx, len, XATTR_CREATE, ll_i2suppgid(inode), &req);
 	if (rc)
 		return rc;
+	ptlrpc_req_finished(req);
 
 	return ll_set_encflags(inode, (void *)ctx, len, false);
 }
diff --git a/fs/lustre/llite/llite_internal.h b/fs/lustre/llite/llite_internal.h
index dd338f2..a8d43bd 100644
--- a/fs/lustre/llite/llite_internal.h
+++ b/fs/lustre/llite/llite_internal.h
@@ -109,8 +109,6 @@ enum ll_file_flags {
 	LLIF_UPDATE_ATIME	= 4,
 	/* foreign file/dir can be unlinked unconditionnaly */
 	LLIF_FOREIGN_REMOVABLE	= 5,
-	/* setting encryption context in progress */
-	LLIF_SET_ENC_CTX	= 6,
 	/* Xattr cache is filled */
 	LLIF_XATTR_CACHE_FILLED	= 7,
 };
@@ -1285,16 +1283,11 @@ enum lcc_type {
 
 struct ll_cl_context {
 	struct list_head	 lcc_list;
-	void	   *lcc_cookie;
+	void			*lcc_cookie;
 	const struct lu_env	*lcc_env;
-	struct cl_io   *lcc_io;
-	struct cl_page *lcc_page;
+	struct cl_io		*lcc_io;
+	struct cl_page		*lcc_page;
 	enum lcc_type		 lcc_type;
-	/**
-	 * Get encryption context operation in progress,
-	 * allow getxattr of LL_XATTR_NAME_ENCRYPTION_CONTEXT xattr
-	 */
-	unsigned int		 lcc_getencctx:1;
 };
 
 struct ll_thread_info {
@@ -1405,6 +1398,7 @@ static inline loff_t ll_file_maxbytes(struct inode *inode)
 #define XATTR_ACL_DEFAULT_T	5
 #define XATTR_LUSTRE_T		6
 #define XATTR_OTHER_T		7
+#define XATTR_ENCRYPTION_T	9
 
 ssize_t ll_listxattr(struct dentry *dentry, char *buffer, size_t size);
 int ll_xattr_list(struct inode *inode, const char *name, int type,
diff --git a/fs/lustre/llite/xattr.c b/fs/lustre/llite/xattr.c
index ce9585a..3a342ad 100644
--- a/fs/lustre/llite/xattr.c
+++ b/fs/lustre/llite/xattr.c
@@ -132,15 +132,14 @@ static int ll_xattr_set_common(const struct xattr_handler *handler,
 			return -EPERM;
 	}
 
-	/* Setting LL_XATTR_NAME_ENCRYPTION_CONTEXT xattr is only allowed
-	 * when defining an encryption policy on a directory, ie when it
-	 * comes from ll_set_context().
-	 * When new files/dirs are created in an encrypted dir, the xattr
-	 * is set directly in the create request.
+	/* This check is required for compatibility with 2.14, in which
+	 * encryption context is stored in security.c xattr.
+	 * Setting the encryption context should only be possible by llcrypt
+	 * when defining an encryption policy on a directory.
+	 * When new files/dirs are created in an encrypted dir, the enc
+	 * context is set directly in the create request.
 	 */
-	if (handler->flags == XATTR_SECURITY_T &&
-	    !strcmp(name, "c") &&
-	    !test_and_clear_bit(LLIF_SET_ENC_CTX, &ll_i2info(inode)->lli_flags))
+	if (handler->flags == XATTR_SECURITY_T && strcmp(name, "c") == 0)
 		return -EPERM;
 
 	fullname = kasprintf(GFP_KERNEL, "%s%s", xattr_prefix(handler), name);
@@ -364,19 +363,13 @@ int ll_xattr_list(struct inode *inode, const char *name, int type, void *buffer,
 	void *xdata;
 	int rc;
 
-	/* Getting LL_XATTR_NAME_ENCRYPTION_CONTEXT xattr is only allowed
-	 * when it comes from ll_get_context(), ie when fscrypt needs to
-	 * know the encryption context.
-	 * Otherwise, any direct reading of this xattr returns -EPERM.
+	/* This check is required for compatibility with 2.14, in which
+	 * encryption context is stored in security.c xattr. Accessing the
+	 * encryption context should only be possible by llcrypt.
 	 */
-	if (type == XATTR_SECURITY_T &&
-	    !strcmp(name, LL_XATTR_NAME_ENCRYPTION_CONTEXT)) {
-		struct ll_cl_context *lcc = ll_cl_find(inode);
-
-		if (!lcc || !lcc->lcc_getencctx) {
-			rc = -EPERM;
-			goto out_xattr;
-		}
+	if (type == XATTR_SECURITY_T && strcmp(name, "security.c") == 0) {
+		rc = -EPERM;
+		goto out_xattr;
 	}
 
 	if (sbi->ll_xattr_cache_enabled && type != XATTR_ACL_ACCESS_T &&
@@ -613,7 +606,6 @@ static int ll_xattr_get(const struct xattr_handler *handler,
 
 ssize_t ll_listxattr(struct dentry *dentry, char *buffer, size_t size)
 {
-	struct inode *dir = d_inode(dentry->d_parent);
 	struct inode *inode = d_inode(dentry);
 	struct ll_sb_info *sbi = ll_i2sbi(inode);
 	ktime_t kstart = ktime_get();
@@ -643,38 +635,37 @@ ssize_t ll_listxattr(struct dentry *dentry, char *buffer, size_t size)
 	rem = rc;
 
 	while (rem > 0) {
+		const struct xattr_handler *xh = get_xattr_type(xattr_name);
 		bool hide_xattr = false;
 
-		/* Listing xattrs should not expose
-		 * LL_XATTR_NAME_ENCRYPTION_CONTEXT xattr, unless it comes
-		 * from fscrypt.
-		 */
-		if (get_xattr_type(xattr_name)->flags == XATTR_SECURITY_T &&
-		    !strcmp(xattr_name, LL_XATTR_NAME_ENCRYPTION_CONTEXT)) {
-			struct ll_cl_context *lcc = ll_cl_find(inode);
-
-			if (!lcc || !lcc->lcc_getencctx)
-				hide_xattr = true;
-		}
-
 		/* Hide virtual project id xattr from the list when
 		 * parent has the inherit flag and the same project id,
 		 * so project id won't be messed up by copying the xattrs
 		 * when mv to a tree with different project id.
 		 */
-		if (get_xattr_type(xattr_name)->flags == XATTR_TRUSTED_T &&
+		if (xh && xh->flags == XATTR_TRUSTED_T &&
 		    strcmp(xattr_name, XATTR_NAME_PROJID) == 0) {
+			struct inode *dir = d_inode(dentry->d_parent);
+
 			if (ll_i2info(inode)->lli_projid ==
-					ll_i2info(dir)->lli_projid &&
+			    ll_i2info(dir)->lli_projid &&
 			    test_bit(LLIF_PROJECT_INHERIT,
 				     &ll_i2info(dir)->lli_flags))
 				hide_xattr = true;
+		} else if (xh && xh->flags == XATTR_SECURITY_T &&
+			   strcmp(xattr_name, "security.c") == 0) {
+			/* Listing xattrs should not expose encryption
+			 * context. There is no handler defined for
+			 * XATTR_ENCRYPTION_PREFIX, so this test is just
+			 * needed for compatibility with 2.14, in which
+			 * encryption context is stored in security.c xattr.
+			 */
+			hide_xattr = true;
 		}
 
 		len = strnlen(xattr_name, rem - 1) + 1;
 		rem -= len;
-		if (!xattr_type_filter(sbi, hide_xattr ? NULL :
-				       get_xattr_type(xattr_name))) {
+		if (!xattr_type_filter(sbi, hide_xattr ? NULL : xh)) {
 			/* Skip OK xattr type, leave it in buffer. */
 			xattr_name += len;
 			continue;
diff --git a/include/uapi/linux/lustre/lustre_idl.h b/include/uapi/linux/lustre/lustre_idl.h
index 78e20a7..753df16 100644
--- a/include/uapi/linux/lustre/lustre_idl.h
+++ b/include/uapi/linux/lustre/lustre_idl.h
@@ -1065,7 +1065,7 @@ struct lov_mds_md_v1 {		/* LOV EA mds/wire data (little-endian) */
 #define XATTR_USER_PREFIX	"user."
 #define XATTR_TRUSTED_PREFIX	"trusted."
 #define XATTR_SECURITY_PREFIX	"security."
-#define XATTR_LUSTRE_PREFIX	"lustre."
+#define XATTR_ENCRYPTION_PREFIX	"encryption."
 
 #define XATTR_NAME_SOM		"trusted.som"
 #define XATTR_NAME_LOV		"trusted.lov"
@@ -1080,7 +1080,8 @@ struct lov_mds_md_v1 {		/* LOV EA mds/wire data (little-endian) */
 #define XATTR_NAME_LFSCK_NAMESPACE "trusted.lfsck_namespace"
 #define XATTR_NAME_PROJID	"trusted.projid"
 
-#define LL_XATTR_NAME_ENCRYPTION_CONTEXT XATTR_SECURITY_PREFIX"c"
+#define LL_XATTR_NAME_ENCRYPTION_CONTEXT_OLD XATTR_SECURITY_PREFIX"c"
+#define LL_XATTR_NAME_ENCRYPTION_CONTEXT XATTR_ENCRYPTION_PREFIX"c"
 
 struct lov_mds_md_v3 {		/* LOV EA mds/wire data (little-endian) */
 	__u32 lmm_magic;	/* magic number = LOV_MAGIC_V3 */
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
