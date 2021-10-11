Return-Path: <SRS0=0agL=O7=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1B0D8C433EF
	for <lustre-devel@archiver.kernel.org>; Mon, 11 Oct 2021 17:41:36 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id C6E1160E78
	for <lustre-devel@archiver.kernel.org>; Mon, 11 Oct 2021 17:41:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.1 mail.kernel.org C6E1160E78
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id C53BA38108C;
	Mon, 11 Oct 2021 10:41:20 -0700 (PDT)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 959F021FB84
 for <lustre-devel@lists.lustre.org>; Mon, 11 Oct 2021 10:40:54 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id AB901260;
 Mon, 11 Oct 2021 13:40:51 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 9E513D5A42; Mon, 11 Oct 2021 13:40:51 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon, 11 Oct 2021 13:40:31 -0400
Message-Id: <1633974049-26490-3-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1633974049-26490-1-git-send-email-jsimmons@infradead.org>
References: <1633974049-26490-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 02/20] lustre: sec: filename encryption -
 symlink support
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

On client side, call the appropriate fscrypt primitives from llite,
to proceed with symlink encryption before sending requests to servers
and symlink decryption upon request receipt.
The tricky part is that fscrypt needs an inode to encrypt the target
name. But by the time we prepare the symlink creation request to be
sent to the server with the target name (in ll_new_node), we do not
have an inode yet (it will be obtained only after we get the server
reply). So we create a fake inode and associate the right encryption
context to it, so that the symlink gets encrypted properly.

In order to report the correct size for an encrypted symlink (which is
ought to be the length of the symlink target), we need to read the
symlink target and decrypt or decode it in ->getattr(). This has a
performance hit, but given that the symlink target is cached in
->i_link (when the key is available), the symlink will not have to be
read and decrypted again later when it is actually followed,
readlink() is called, or lstat() is called again.
This part of the patch is adapted from kernel commit
d18760560593e5af921f51a8c9b64b6109d634c2
"fscrypt: add fscrypt_symlink_getattr() for computing st_size"

With encrypted file names, a symlink target is binary. So make sure
server side can handle that, by switching sp_symname to a
struct lu_name in struct md_op_spec.

WC-bug-id: https://jira.whamcloud.com/browse/LU-13717
Lustre-commit: e735298935b64541f ("LU-13717 sec: filename encryption - symlink support")
Signed-off-by: Sebastien Buisson <sbuisson@ddn.com>
Reviewed-on: https://review.whamcloud.com/43394
Reviewed-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/namei.c   | 97 ++++++++++++++++++++++++++++++++++++++---------
 fs/lustre/llite/symlink.c | 85 ++++++++++++++++++++++++++++++++++++++---
 2 files changed, 158 insertions(+), 24 deletions(-)

diff --git a/fs/lustre/llite/namei.c b/fs/lustre/llite/namei.c
index f0f10da..1812c09 100644
--- a/fs/lustre/llite/namei.c
+++ b/fs/lustre/llite/namei.c
@@ -1531,25 +1531,29 @@ static void ll_qos_mkdir_prep(struct md_op_data *op_data, struct inode *dir)
 	up_read(&rlli->lli_lsm_sem);
 }
 
-static int ll_new_node(struct inode *dir, struct dentry *dentry,
-		       const char *tgt, umode_t mode, int rdev,
+static int ll_new_node(struct inode *dir, struct dentry *dchild,
+		       const char *tgt, umode_t mode, u64 rdev,
 		       u32 opc)
 {
+	struct qstr *name = &dchild->d_name;
 	struct ptlrpc_request *request = NULL;
 	struct md_op_data *op_data = NULL;
 	struct inode *inode = NULL;
 	struct ll_sb_info *sbi = ll_i2sbi(dir);
-	int tgt_len = 0;
+	struct fscrypt_str *disk_link = NULL;
 	bool encrypt = false;
 	int err;
 
-	if (unlikely(tgt))
-		tgt_len = strlen(tgt) + 1;
+	if (unlikely(tgt)) {
+		disk_link = (struct fscrypt_str *)rdev;
+		rdev = 0;
+		if (!disk_link)
+			return -EINVAL;
+	}
+
 again:
-	op_data = ll_prep_md_op_data(NULL, dir, NULL,
-				     dentry->d_name.name,
-				     dentry->d_name.len,
-				     0, opc, NULL);
+	op_data = ll_prep_md_op_data(NULL, dir, NULL, name->name,
+				     name->len, 0, opc, NULL);
 	if (IS_ERR(op_data)) {
 		err = PTR_ERR(op_data);
 		goto err_exit;
@@ -1559,7 +1563,7 @@ static int ll_new_node(struct inode *dir, struct dentry *dentry,
 		ll_qos_mkdir_prep(op_data, dir);
 
 	if (sbi->ll_flags & LL_SBI_FILE_SECCTX) {
-		err = ll_dentry_init_security(dentry, mode, &dentry->d_name,
+		err = ll_dentry_init_security(dchild, mode, &dchild->d_name,
 					      &op_data->op_file_secctx_name,
 					      &op_data->op_file_secctx,
 					      &op_data->op_file_secctx_size);
@@ -1585,9 +1589,40 @@ static int ll_new_node(struct inode *dir, struct dentry *dentry,
 		err = fscrypt_inherit_context(dir, NULL, op_data, false);
 		if (err)
 			goto err_exit;
+
+		if (S_ISLNK(mode)) {
+			/* fscrypt needs inode to encrypt target name, so create
+			 * a fake inode and associate encryption context got
+			 * from fscrypt_inherit_context.
+			 */
+			struct inode *fakeinode =
+				dchild->d_sb->s_op->alloc_inode(dchild->d_sb);
+
+			if (!fakeinode) {
+				err = -ENOMEM;
+				goto err_exit;
+			}
+			fakeinode->i_sb = dchild->d_sb;
+			fakeinode->i_mode |= S_IFLNK;
+			err = ll_set_encflags(fakeinode,
+					      op_data->op_file_encctx,
+					      op_data->op_file_encctx_size,
+					      true);
+			if (!err)
+				err = __fscrypt_encrypt_symlink(fakeinode, tgt,
+								strlen(tgt),
+								disk_link);
+
+			ll_xattr_cache_destroy(fakeinode);
+			fscrypt_put_encryption_info(fakeinode);
+			dchild->d_sb->s_op->destroy_inode(fakeinode);
+			if (err)
+				goto err_exit;
+		}
 	}
 
-	err = md_create(sbi->ll_md_exp, op_data, tgt, tgt_len, mode,
+	err = md_create(sbi->ll_md_exp, op_data, tgt ? disk_link->name : NULL,
+			tgt ? disk_link->len : 0, mode,
 			from_kuid(&init_user_ns, current_fsuid()),
 			from_kgid(&init_user_ns, current_fsgid()),
 			current_cap(), rdev, &request);
@@ -1687,16 +1722,32 @@ static int ll_new_node(struct inode *dir, struct dentry *dentry,
 			goto err_exit;
 	}
 
-	d_instantiate(dentry, inode);
+	d_instantiate(dchild, inode);
 
 	if (encrypt) {
 		err = fscrypt_inherit_context(dir, inode, NULL, true);
 		if (err)
 			goto err_exit;
+
+		if (S_ISLNK(mode)) {
+			struct ll_inode_info *lli = ll_i2info(inode);
+
+			/* Cache the plaintext symlink target
+			 * for later use by get_link()
+			 */
+			lli->lli_symlink_name = kzalloc(strlen(tgt) + 1,
+							GFP_NOFS);
+			/* do not return an error if we cannot
+			 * cache the symlink locally
+			 */
+			if (lli->lli_symlink_name)
+				memcpy(lli->lli_symlink_name,
+				       tgt, strlen(tgt) + 1);
+		}
 	}
 
 	if (!(sbi->ll_flags & LL_SBI_FILE_SECCTX))
-		err = ll_inode_init_security(dentry, inode, dir);
+		err = ll_inode_init_security(dchild, inode, dir);
 err_exit:
 	if (request)
 		ptlrpc_req_finished(request);
@@ -1894,17 +1945,27 @@ static int ll_rmdir(struct inode *dir, struct dentry *dchild)
 	return rc;
 }
 
-static int ll_symlink(struct inode *dir, struct dentry *dentry,
-		      const char *oldname)
+static int ll_symlink(struct inode *dir, struct dentry *dchild,
+		      const char *oldpath)
 {
 	ktime_t kstart = ktime_get();
+	int len = strlen(oldpath);
+	struct fscrypt_str disk_link;
 	int err;
 
 	CDEBUG(D_VFSTRACE, "VFS Op:name=%pd, dir=" DFID "(%p),target=%.*s\n",
-	       dentry, PFID(ll_inode2fid(dir)), dir, 3000, oldname);
+	       dchild, PFID(ll_inode2fid(dir)), dir, 3000, oldpath);
+
+	err = fscrypt_prepare_symlink(dir, oldpath, len, dir->i_sb->s_blocksize,
+				      &disk_link);
+	if (err)
+		return err;
+
+	err = ll_new_node(dir, dchild, oldpath, S_IFLNK | 0777,
+			  (u64)&disk_link, LUSTRE_OPC_SYMLINK);
 
-	err = ll_new_node(dir, dentry, oldname, S_IFLNK | 0777,
-			  0, LUSTRE_OPC_SYMLINK);
+	if (disk_link.name != (unsigned char *)oldpath)
+		kfree(disk_link.name);
 
 	if (!err)
 		ll_stats_ops_tally(ll_i2sbi(dir), LPROC_LL_SYMLINK,
diff --git a/fs/lustre/llite/symlink.c b/fs/lustre/llite/symlink.c
index cf5ad9e..8ea16bb 100644
--- a/fs/lustre/llite/symlink.c
+++ b/fs/lustre/llite/symlink.c
@@ -38,8 +38,13 @@
 #include "llite_internal.h"
 
 /* Must be called with lli_size_mutex locked */
+/* HAVE_IOP_GET_LINK is defined from kernel 4.5, whereas
+ * IS_ENCRYPTED is brought by kernel 4.14.
+ * So there is no need to handle encryption case otherwise.
+ */
 static int ll_readlink_internal(struct inode *inode,
-				struct ptlrpc_request **request, char **symname)
+				struct ptlrpc_request **request,
+				char **symname, struct delayed_call *done)
 {
 	struct ll_inode_info *lli = ll_i2info(inode);
 	struct ll_sb_info *sbi = ll_i2sbi(inode);
@@ -97,7 +102,9 @@ static int ll_readlink_internal(struct inode *inode,
 	}
 
 	*symname = req_capsule_server_get(&(*request)->rq_pill, &RMF_MDT_MD);
-	if (!*symname || strnlen(*symname, symlen) != symlen - 1) {
+	if (!*symname ||
+	    (!IS_ENCRYPTED(inode) &&
+	     strnlen(*symname, symlen) != symlen - 1)) {
 		/* not full/NULL terminated */
 		CERROR("%s: inode " DFID ": symlink not NULL terminated string of length %d\n",
 		       ll_i2sbi(inode)->ll_fsname,
@@ -106,6 +113,21 @@ static int ll_readlink_internal(struct inode *inode,
 		goto failed;
 	}
 
+	if (IS_ENCRYPTED(inode)) {
+		const char *target = fscrypt_get_symlink(inode, *symname,
+							 symlen, done);
+		if (IS_ERR(target))
+			return PTR_ERR(target);
+		symlen = strlen(target) + 1;
+		*symname = (char *)target;
+
+		/* Do not cache symlink targets encoded without the key,
+		 * since those become outdated once the key is added.
+		 */
+		if (!fscrypt_has_encryption_key(inode))
+			return 0;
+	}
+
 	lli->lli_symlink_name = kzalloc(symlen, GFP_NOFS);
 	/* do not return an error if we cannot cache the symlink locally */
 	if (lli->lli_symlink_name) {
@@ -131,12 +153,12 @@ static const char *ll_get_link(struct dentry *dentry,
 	int rc;
 	char *symname = NULL;
 
+	CDEBUG(D_VFSTRACE, "VFS Op:name=%pd, inode="DFID"(%p)\n",
+	       dentry, PFID(ll_inode2fid(inode)), inode);
 	if (!dentry)
 		return ERR_PTR(-ECHILD);
-
-	CDEBUG(D_VFSTRACE, "VFS Op\n");
 	ll_inode_size_lock(inode);
-	rc = ll_readlink_internal(inode, &request, &symname);
+	rc = ll_readlink_internal(inode, &request, &symname, done);
 	ll_inode_size_unlock(inode);
 	if (rc) {
 		ptlrpc_req_finished(request);
@@ -151,10 +173,61 @@ static const char *ll_get_link(struct dentry *dentry,
 	return symname;
 }
 
+/**
+ * ll_getattr_link() - link-specific getattr to set the correct st_size
+ *		       for encrypted symlinks
+ *
+ * Override st_size of encrypted symlinks to be the length of the decrypted
+ * symlink target (or the no-key encoded symlink target, if the key is
+ * unavailable) rather than the length of the encrypted symlink target. This is
+ * necessary for st_size to match the symlink target that userspace actually
+ * sees.  POSIX requires this, and some userspace programs depend on it.
+ *
+ * For non encrypted symlinks, this is a just calling ll_getattr().
+ * For encrypted symlinks, this additionally requires reading the symlink target
+ * from disk if needed, setting up the inode's encryption key if possible, and
+ * then decrypting or encoding the symlink target.  This makes lstat() more
+ * heavyweight than is normally the case.  However, decrypted symlink targets
+ * will be cached in ->i_link, so usually the symlink won't have to be read and
+ * decrypted again later if/when it is actually followed, readlink() is called,
+ * or lstat() is called again.
+ *
+ * Return: 0 on success, -errno on failure
+ */
+static int ll_getattr_link(const struct path *path, struct kstat *stat,
+			   u32 request_mask, unsigned int flags)
+{
+	struct dentry *dentry = path->dentry;
+	struct inode *inode = d_inode(dentry);
+	DEFINE_DELAYED_CALL(done);
+	const char *link;
+	int rc;
+
+	rc = ll_getattr(path, stat, request_mask, flags);
+	if (rc || !IS_ENCRYPTED(inode))
+		return rc;
+
+	/*
+	 * To get the symlink target that userspace will see (whether it's the
+	 * decrypted target or the no-key encoded target), we can just get it
+	 * in the same way the VFS does during path resolution and readlink().
+	 */
+	link = READ_ONCE(inode->i_link);
+	if (!link) {
+		link = inode->i_op->get_link(dentry, inode, &done);
+		if (IS_ERR(link))
+			return PTR_ERR(link);
+	}
+	stat->size = strlen(link);
+	do_delayed_call(&done);
+	return 0;
+}
+
+
 const struct inode_operations ll_fast_symlink_inode_operations = {
 	.setattr	= ll_setattr,
 	.get_link	= ll_get_link,
-	.getattr	= ll_getattr,
+	.getattr	= ll_getattr_link,
 	.permission	= ll_inode_permission,
 	.listxattr	= ll_listxattr,
 };
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
