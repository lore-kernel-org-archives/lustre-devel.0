Return-Path: <SRS0=2ypu=OM=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 32C07C433EF
	for <lustre-devel@archiver.kernel.org>; Wed, 22 Sep 2021 02:21:16 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id EAF0960F4C
	for <lustre-devel@archiver.kernel.org>; Wed, 22 Sep 2021 02:21:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.1 mail.kernel.org EAF0960F4C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 44C7221E009;
	Tue, 21 Sep 2021 19:21:15 -0700 (PDT)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id D26C521CBCA
 for <lustre-devel@lists.lustre.org>; Tue, 21 Sep 2021 19:20:11 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 3E13D486;
 Tue, 21 Sep 2021 22:20:04 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 3B2C9FF4BC; Tue, 21 Sep 2021 22:20:04 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Tue, 21 Sep 2021 22:19:58 -0400
Message-Id: <1632277201-6920-22-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1632277201-6920-1-git-send-email-jsimmons@infradead.org>
References: <1632277201-6920-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 21/24] lustre: sec: filename encryption
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

On client side, call the appropriate fscrypt primitives for llite,
to proceed with filename encryption before sending requests to servers
and filename decryption upon request receipt.
Note we need specific overlay functions to handle encoding and
decoding of encrypted filenames, as we do not want server side to deal
with binary names before they reach the backend file system layer.

On server side, mainly the OSD layer, we need to know the encryption
status of files being processed.
If an object belongs to an encrypted file, the filename has been
encoded by the client because it is binary, so it needs to be decoded
before being handed over to the backend file system layer.
And conversely, the filename of an encrypted file has to be encoded
before being sent over the wire.
Note server side is osd-ldiskfs only for now.

WC-bug-id: https://jira.whamcloud.com/browse/LU-13717
Lustre-commit: 4d38566a004f6a636 ("LU-13717 sec: filename encryption")
Signed-off-by: Sebastien Buisson <sbuisson@ddn.com>
Reviewed-on: https://review.whamcloud.com/43390
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/obd.h          |   4 ++
 fs/lustre/llite/crypto.c         | 144 +++++++++++++++++++++++++++++++++++++++
 fs/lustre/llite/dcache.c         |   8 +++
 fs/lustre/llite/dir.c            |  39 ++++++++++-
 fs/lustre/llite/file.c           |  11 +--
 fs/lustre/llite/llite_internal.h |  27 ++++++++
 fs/lustre/llite/llite_lib.c      |  51 +++++++++++++-
 fs/lustre/llite/namei.c          |  47 ++++++++++---
 fs/lustre/llite/statahead.c      |  48 +++++++++++++
 fs/lustre/mdc/mdc_lib.c          |   6 +-
 fs/lustre/ptlrpc/layout.c        |   2 +-
 11 files changed, 366 insertions(+), 21 deletions(-)

diff --git a/fs/lustre/include/obd.h b/fs/lustre/include/obd.h
index 7c5e699..7642973 100644
--- a/fs/lustre/include/obd.h
+++ b/fs/lustre/include/obd.h
@@ -708,6 +708,7 @@ enum md_op_flags {
 	MF_GETATTR_BY_FID	= BIT(5),
 	MF_QOS_MKDIR		= BIT(6),
 	MF_RR_MKDIR		= BIT(7),
+	MF_OPNAME_KMALLOCED	= BIT(8),
 };
 
 enum md_cli_flags {
@@ -725,6 +726,9 @@ enum md_op_code {
 	LUSTRE_OPC_MKNOD,
 	LUSTRE_OPC_CREATE,
 	LUSTRE_OPC_ANY,
+	LUSTRE_OPC_LOOKUP,
+	LUSTRE_OPC_OPEN,
+	LUSTRE_OPC_MIGR,
 };
 
 /**
diff --git a/fs/lustre/llite/crypto.c b/fs/lustre/llite/crypto.c
index 34d0ad1..5d99037 100644
--- a/fs/lustre/llite/crypto.c
+++ b/fs/lustre/llite/crypto.c
@@ -153,6 +153,150 @@ static bool ll_empty_dir(struct inode *inode)
 	return true;
 }
 
+/**
+ * ll_setup_filename() - overlay to fscrypt_setup_filename
+ * @dir: the directory that will be searched
+ * @iname: the user-provided filename being searched for
+ * @lookup: 1 if we're allowed to proceed without the key because it's
+ *	->lookup() or we're finding the dir_entry for deletion; 0 if we cannot
+ *	proceed without the key because we're going to create the dir_entry.
+ * @fname: the filename information to be filled in
+ *
+ * This overlay function is necessary to properly encode @fname after
+ * encryption, as it will be sent over the wire.
+ */
+int ll_setup_filename(struct inode *dir, const struct qstr *iname,
+		      int lookup, struct fscrypt_name *fname)
+{
+	int rc;
+
+	rc = fscrypt_setup_filename(dir, iname, lookup, fname);
+	if (rc)
+		return rc;
+
+	if (IS_ENCRYPTED(dir) &&
+	    !name_is_dot_or_dotdot(fname->disk_name.name,
+				   fname->disk_name.len)) {
+		int presented_len = critical_chars(fname->disk_name.name,
+						   fname->disk_name.len);
+		char *buf;
+
+		buf = kmalloc(presented_len + 1, GFP_NOFS);
+		if (!buf) {
+			rc = -ENOMEM;
+			goto out_free;
+		}
+
+		if (presented_len == fname->disk_name.len)
+			memcpy(buf, fname->disk_name.name, presented_len);
+		else
+			critical_encode(fname->disk_name.name,
+					fname->disk_name.len, buf);
+		buf[presented_len] = '\0';
+		kfree(fname->crypto_buf.name);
+		fname->crypto_buf.name = buf;
+		fname->crypto_buf.len = presented_len;
+		fname->disk_name.name = fname->crypto_buf.name;
+		fname->disk_name.len = fname->crypto_buf.len;
+	}
+
+	return rc;
+
+out_free:
+	fscrypt_free_filename(fname);
+	return rc;
+}
+
+/**
+ * ll_fname_disk_to_usr() - overlay to fscrypt_fname_disk_to_usr
+ * @inode: the inode to convert name
+ * @hash: major hash for inode
+ * @minor_hash: minor hash for inode
+ * @iname: the user-provided filename needing conversion
+ * @oname: the filename information to be filled in
+ *
+ * The caller must have allocated sufficient memory for the @oname string.
+ *
+ * This overlay function is necessary to properly decode @iname before
+ * decryption, as it comes from the wire.
+ */
+int ll_fname_disk_to_usr(struct inode *inode,
+			 u32 hash, u32 minor_hash,
+			 struct fscrypt_str *iname, struct fscrypt_str *oname)
+{
+	struct fscrypt_str lltr = FSTR_INIT(iname->name, iname->len);
+	char *buf = NULL;
+	int rc;
+
+	if (IS_ENCRYPTED(inode) &&
+	    !name_is_dot_or_dotdot(lltr.name, lltr.len) &&
+	    strnchr(lltr.name, lltr.len, '=')) {
+		/* Only proceed to critical decode if
+		 * iname contains espace char '='.
+		 */
+		int len = lltr.len;
+
+		buf = kmalloc(len, GFP_NOFS);
+		if (!buf)
+			return -ENOMEM;
+
+		len = critical_decode(lltr.name, len, buf);
+		lltr.name = buf;
+		lltr.len = len;
+	}
+
+	rc = fscrypt_fname_disk_to_usr(inode, hash, minor_hash, &lltr, oname);
+
+	kfree(buf);
+
+	return rc;
+}
+
+/* Copied from fscrypt_d_revalidate, as it is not exported */
+/*
+ * Validate dentries in encrypted directories to make sure we aren't potentially
+ * caching stale dentries after a key has been added.
+ */
+int ll_revalidate_d_crypto(struct dentry *dentry, unsigned int flags)
+{
+	struct dentry *dir;
+	int err;
+	int valid;
+
+	/*
+	 * Plaintext names are always valid, since llcrypt doesn't support
+	 * reverting to ciphertext names without evicting the directory's inode
+	 * -- which implies eviction of the dentries in the directory.
+	 */
+	if (!(dentry->d_flags & DCACHE_ENCRYPTED_NAME))
+		return 1;
+
+	/*
+	 * Ciphertext name; valid if the directory's key is still unavailable.
+	 *
+	 * Although llcrypt forbids rename() on ciphertext names, we still must
+	 * use dget_parent() here rather than use ->d_parent directly.  That's
+	 * because a corrupted fs image may contain directory hard links, which
+	 * the VFS handles by moving the directory's dentry tree in the dcache
+	 * each time ->lookup() finds the directory and it already has a dentry
+	 * elsewhere.  Thus ->d_parent can be changing, and we must safely grab
+	 * a reference to some ->d_parent to prevent it from being freed.
+	 */
+
+	if (flags & LOOKUP_RCU)
+		return -ECHILD;
+
+	dir = dget_parent(dentry);
+	err = fscrypt_get_encryption_info(d_inode(dir));
+	valid = !fscrypt_has_encryption_key(d_inode(dir));
+	dput(dir);
+
+	if (err < 0)
+		return err;
+
+	return valid;
+}
+
 const struct fscrypt_operations lustre_cryptops = {
 	.key_prefix		= "lustre:",
 	.get_context		= ll_get_context,
diff --git a/fs/lustre/llite/dcache.c b/fs/lustre/llite/dcache.c
index 4162f46..a074a2c 100644
--- a/fs/lustre/llite/dcache.c
+++ b/fs/lustre/llite/dcache.c
@@ -235,6 +235,14 @@ static int ll_revalidate_dentry(struct dentry *dentry,
 				unsigned int lookup_flags)
 {
 	struct inode *dir = d_inode(dentry->d_parent);
+	int rc;
+
+	CDEBUG(D_VFSTRACE, "VFS Op:name=%s, flags=%u\n",
+	       dentry->d_name.name, lookup_flags);
+
+	rc = ll_revalidate_d_crypto(dentry, lookup_flags);
+	if (rc != 1)
+		return rc;
 
 	/* If this is intermediate component path lookup and we were able to get
 	 * to this dentry, then its lock has not been revoked and the
diff --git a/fs/lustre/llite/dir.c b/fs/lustre/llite/dir.c
index 9a4ccfc..f7216db 100644
--- a/fs/lustre/llite/dir.c
+++ b/fs/lustre/llite/dir.c
@@ -42,6 +42,7 @@
 #include <linux/pagevec.h>
 #include <linux/prefetch.h>
 #include <linux/security.h>
+#include <linux/fscrypt.h>
 
 #define DEBUG_SUBSYSTEM S_LLITE
 
@@ -181,11 +182,18 @@ int ll_dir_read(struct inode *inode, u64 *ppos, struct md_op_data *op_data,
 	struct ll_sb_info *sbi = ll_i2sbi(inode);
 	u64 pos = *ppos;
 	bool is_api32 = ll_need_32bit_api(sbi);
-	int is_hash64 = sbi->ll_flags & LL_SBI_64BIT_HASH;
+	bool is_hash64 = sbi->ll_flags & LL_SBI_64BIT_HASH;
+	struct fscrypt_str lltr = FSTR_INIT(NULL, 0);
 	struct page *page;
 	bool done = false;
 	int rc = 0;
 
+	if (IS_ENCRYPTED(inode)) {
+		rc = fscrypt_fname_alloc_buffer(inode, NAME_MAX, &lltr);
+		if (rc < 0)
+			return rc;
+	}
+
 	page = ll_get_dir_page(inode, op_data, pos);
 
 	while (rc == 0 && !done) {
@@ -232,8 +240,26 @@ int ll_dir_read(struct inode *inode, u64 *ppos, struct md_op_data *op_data,
 			 * so the parameter 'name' for 'ctx->actor()'
 			 * must be part of the 'ent'.
 			 */
-			done = !dir_emit(ctx, ent->lde_name,
-					 namelen, ino, type);
+			if (!IS_ENCRYPTED(inode)) {
+				done = !dir_emit(ctx, ent->lde_name, namelen,
+						 ino, type);
+			} else {
+				/* Directory is encrypted */
+				int save_len = lltr.len;
+				struct fscrypt_str de_name
+					= FSTR_INIT(ent->lde_name, namelen);
+
+				rc = ll_fname_disk_to_usr(inode, 0, 0, &de_name,
+							  &lltr);
+				de_name = lltr;
+				lltr.len = save_len;
+				if (rc) {
+					done = 1;
+					break;
+				}
+				done = !dir_emit(ctx, de_name.name, de_name.len,
+						 ino, type);
+			}
 		}
 
 		if (done) {
@@ -264,6 +290,7 @@ int ll_dir_read(struct inode *inode, u64 *ppos, struct md_op_data *op_data,
 	}
 
 	ctx->pos = pos;
+	fscrypt_fname_free_buffer(&lltr);
 	return rc;
 }
 
@@ -285,6 +312,12 @@ static int ll_readdir(struct file *filp, struct dir_context *ctx)
 	       PFID(ll_inode2fid(inode)), inode, (unsigned long)pos,
 	       i_size_read(inode), api32);
 
+	if (IS_ENCRYPTED(inode)) {
+		rc = fscrypt_get_encryption_info(inode);
+		if (rc && rc != -ENOKEY)
+			goto out;
+	}
+
 	if (pos == MDS_DIR_END_OFF) {
 		/*
 		 * end-of-file.
diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index e60789b..ab7c72a 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -631,7 +631,7 @@ static int ll_intent_file_open(struct dentry *de, void *lmm, int lmmsize,
 	}
 
 	op_data  = ll_prep_md_op_data(NULL, d_inode(parent), inode, name, len,
-				      O_RDWR, LUSTRE_OPC_ANY, NULL);
+				      O_RDWR, LUSTRE_OPC_OPEN, NULL);
 	if (IS_ERR(op_data)) {
 		kfree(name);
 		return PTR_ERR(op_data);
@@ -2164,7 +2164,7 @@ int ll_lov_getstripe_ea_info(struct inode *inode, const char *filename,
 			     struct ptlrpc_request **request)
 {
 	struct ll_sb_info *sbi = ll_i2sbi(inode);
-	struct mdt_body *body;
+	struct mdt_body  *body;
 	struct lov_mds_md *lmm = NULL;
 	struct ptlrpc_request *req = NULL;
 	struct md_op_data *op_data;
@@ -4744,7 +4744,7 @@ int ll_migrate(struct inode *parent, struct file *file, struct lmv_user_md *lum,
 	}
 
 	op_data = ll_prep_md_op_data(NULL, parent, NULL, name, namelen,
-				     child_inode->i_mode, LUSTRE_OPC_ANY, NULL);
+				     child_inode->i_mode, LUSTRE_OPC_MIGR, NULL);
 	if (IS_ERR(op_data)) {
 		rc = PTR_ERR(op_data);
 		goto out_iput;
@@ -4788,8 +4788,9 @@ int ll_migrate(struct inode *parent, struct file *file, struct lmv_user_md *lum,
 		spin_unlock(&och->och_mod->mod_open_req->rq_lock);
 	}
 
-	rc = md_rename(ll_i2sbi(parent)->ll_md_exp, op_data, name, namelen,
-		       name, namelen, &request);
+	rc = md_rename(ll_i2sbi(parent)->ll_md_exp, op_data,
+		       op_data->op_name, op_data->op_namelen,
+		       op_data->op_name, op_data->op_namelen, &request);
 	if (!rc) {
 		LASSERT(request);
 		ll_update_times(request, parent);
diff --git a/fs/lustre/llite/llite_internal.h b/fs/lustre/llite/llite_internal.h
index ed6ff07..25bd460 100644
--- a/fs/lustre/llite/llite_internal.h
+++ b/fs/lustre/llite/llite_internal.h
@@ -1731,6 +1731,33 @@ static inline struct pcc_super *ll_info2pccs(struct ll_inode_info *lli)
 }
 
 /* crypto.c */
+#ifdef CONFIG_FS_ENCRYPTION
+int ll_setup_filename(struct inode *dir, const struct qstr *iname,
+		      int lookup, struct fscrypt_name *fname);
+int ll_fname_disk_to_usr(struct inode *inode,
+			 u32 hash, u32 minor_hash,
+			 struct fscrypt_str *iname, struct fscrypt_str *oname);
+int ll_revalidate_d_crypto(struct dentry *dentry, unsigned int flags);
+#else
+int ll_setup_filename(struct inode *dir, const struct qstr *iname,
+		      int lookup, struct fscrypt_name *fname)
+{
+	return fscrypt_setup_filename(dir, iname, lookup, fname);
+}
+
+int ll_fname_disk_to_usr(struct inode *inode,
+			 u32 hash, u32 minor_hash,
+			 struct fscrypt_str *iname, struct fscrypt_str *oname)
+{
+	return fscrypt_fname_disk_to_usr(inode, hash, minor_hash, iname, oname);
+}
+
+int ll_revalidate_d_crypto(struct dentry *dentry, unsigned int flags)
+{
+	return 1;
+}
+#endif
+
 extern const struct fscrypt_operations lustre_cryptops;
 
 /* llite/llite_foreign.c */
diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index 58e60c8..7a822b8 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -3003,6 +3003,9 @@ struct md_op_data *ll_prep_md_op_data(struct md_op_data *op_data,
 				      u32 mode, enum md_op_code opc,
 				      void *data)
 {
+	struct fscrypt_name fname = { 0 };
+	int rc;
+
 	if (!name) {
 		/* Do not reuse namelen for something else. */
 		if (namelen)
@@ -3025,7 +3028,6 @@ struct md_op_data *ll_prep_md_op_data(struct md_op_data *op_data,
 
 	ll_i2gids(op_data->op_suppgids, i1, i2);
 	op_data->op_fid1 = *ll_inode2fid(i1);
-	op_data->op_code = opc;
 
 	if (S_ISDIR(i1->i_mode)) {
 		down_read_non_owner(&ll_i2info(i1)->lli_lsm_sem);
@@ -3057,8 +3059,46 @@ struct md_op_data *ll_prep_md_op_data(struct md_op_data *op_data,
 	if (ll_need_32bit_api(ll_i2sbi(i1)))
 		op_data->op_cli_flags |= CLI_API32;
 
-	op_data->op_name = name;
-	op_data->op_namelen = namelen;
+	if (opc == LUSTRE_OPC_LOOKUP || opc == LUSTRE_OPC_CREATE) {
+		/* In case of lookup, ll_setup_filename() has already been
+		 * called in ll_lookup_it(), so just take provided name.
+		 */
+		fname.disk_name.name = (unsigned char *)name;
+		fname.disk_name.len = namelen;
+	} else if (name && namelen) {
+		struct qstr dname = QSTR_INIT(name, namelen);
+		struct inode *dir;
+		int lookup;
+
+		if (!S_ISDIR(i1->i_mode) && i2 && S_ISDIR(i2->i_mode)) {
+			/* special case when called from ll_link() */
+			dir = i2;
+			lookup = 0;
+		} else {
+			dir = i1;
+			lookup = (int)(opc == LUSTRE_OPC_ANY);
+		}
+		rc = ll_setup_filename(dir, &dname, lookup, &fname);
+		if (rc) {
+			ll_finish_md_op_data(op_data);
+			return ERR_PTR(rc);
+		}
+		if (fname.disk_name.name &&
+		    fname.disk_name.name != (unsigned char *)name)
+			/* op_data->op_name must be freed after use */
+			op_data->op_flags |= MF_OPNAME_KMALLOCED;
+	}
+
+	/* In fact LUSTRE_OPC_LOOKUP, LUSTRE_OPC_OPEN, LUSTRE_OPC_MIGR
+	 * are LUSTRE_OPC_ANY
+	 */
+	if (opc == LUSTRE_OPC_LOOKUP || opc == LUSTRE_OPC_OPEN ||
+	    opc == LUSTRE_OPC_MIGR)
+		op_data->op_code = LUSTRE_OPC_ANY;
+	else
+		op_data->op_code = opc;
+	op_data->op_name = fname.disk_name.name;
+	op_data->op_namelen = fname.disk_name.len;
 	op_data->op_mode = mode;
 	op_data->op_mod_time = ktime_get_real_seconds();
 	op_data->op_fsuid = from_kuid(&init_user_ns, current_fsuid());
@@ -3078,6 +3118,11 @@ void ll_finish_md_op_data(struct md_op_data *op_data)
 	ll_unlock_md_op_lsm(op_data);
 	security_release_secctx(op_data->op_file_secctx,
 				op_data->op_file_secctx_size);
+	if (op_data->op_flags & MF_OPNAME_KMALLOCED)
+		/* allocated via ll_setup_filename called
+		 * from ll_prep_md_op_data
+		 */
+		kfree(op_data->op_name);
 	kfree(op_data->op_file_encctx);
 	kfree(op_data);
 }
diff --git a/fs/lustre/llite/namei.c b/fs/lustre/llite/namei.c
index 54b4e0a..f0f10da 100644
--- a/fs/lustre/llite/namei.c
+++ b/fs/lustre/llite/namei.c
@@ -812,6 +812,7 @@ static struct dentry *ll_lookup_it(struct inode *parent, struct dentry *dentry,
 	struct md_op_data *op_data = NULL;
 	struct lov_user_md *lum = NULL;
 	char secctx_name[XATTR_NAME_MAX + 1];
+	struct fscrypt_name fname;
 	struct inode *inode;
 	u32 opc;
 	int rc;
@@ -846,12 +847,31 @@ static struct dentry *ll_lookup_it(struct inode *parent, struct dentry *dentry,
 	if (it->it_op & IT_CREAT)
 		opc = LUSTRE_OPC_CREATE;
 	else
-		opc = LUSTRE_OPC_ANY;
+		opc = LUSTRE_OPC_LOOKUP;
+
+	/* Here we should be calling fscrypt_prepare_lookup(). But it installs a
+	 * custom ->d_revalidate() method, so we lose ll_d_ops.
+	 * To workaround this, call ll_setup_filename() and do the rest
+	 * manually. Also make a copy of fscrypt_d_revalidate() (unfortunately
+	 * not exported function) and call it from ll_revalidate_dentry(), to
+	 * ensure we do not cache stale dentries after a key has been added.
+	 */
+	rc = ll_setup_filename(parent, &dentry->d_name, 1, &fname);
+	if ((!rc || rc == -ENOENT) && fname.is_ciphertext_name) {
+		spin_lock(&dentry->d_lock);
+		dentry->d_flags |= DCACHE_ENCRYPTED_NAME;
+		spin_unlock(&dentry->d_lock);
+	}
+	if (rc == -ENOENT)
+		return NULL;
+	if (rc)
+		return ERR_PTR(rc);
 
-	op_data = ll_prep_md_op_data(NULL, parent, NULL, dentry->d_name.name,
-				     dentry->d_name.len, 0, opc, NULL);
+	op_data = ll_prep_md_op_data(NULL, parent, NULL, fname.disk_name.name,
+				     fname.disk_name.len, 0, opc, NULL);
 	if (IS_ERR(op_data)) {
-		retval = ERR_CAST(op_data);
+		fscrypt_free_filename(&fname);
+		return ERR_CAST(op_data);
 		goto out;
 	}
 
@@ -1111,6 +1131,7 @@ static struct dentry *ll_lookup_it(struct inode *parent, struct dentry *dentry,
 			op_data->op_file_encctx = NULL;
 			op_data->op_file_encctx_size = 0;
 		}
+		fscrypt_free_filename(&fname);
 		ll_finish_md_op_data(op_data);
 	}
 
@@ -1934,6 +1955,7 @@ static int ll_rename(struct inode *src, struct dentry *src_dchild,
 		     struct inode *tgt, struct dentry *tgt_dchild,
 		     unsigned int flags)
 {
+	struct fscrypt_name foldname, fnewname;
 	struct ptlrpc_request *request = NULL;
 	struct ll_sb_info *sbi = ll_i2sbi(src);
 	struct md_op_data *op_data;
@@ -1977,11 +1999,20 @@ static int ll_rename(struct inode *src, struct dentry *src_dchild,
 	if (tgt_dchild->d_inode)
 		op_data->op_fid4 = *ll_inode2fid(tgt_dchild->d_inode);
 
+	err = ll_setup_filename(src, &src_dchild->d_name, 1, &foldname);
+	if (err)
+		return err;
+	err = ll_setup_filename(tgt, &tgt_dchild->d_name, 1, &fnewname);
+	if (err) {
+		fscrypt_free_filename(&foldname);
+		return err;
+	}
 	err = md_rename(sbi->ll_md_exp, op_data,
-			src_dchild->d_name.name,
-			src_dchild->d_name.len,
-			tgt_dchild->d_name.name,
-			tgt_dchild->d_name.len, &request);
+			foldname.disk_name.name, foldname.disk_name.len,
+			fnewname.disk_name.name, fnewname.disk_name.len,
+			&request);
+	fscrypt_free_filename(&foldname);
+	fscrypt_free_filename(&fnewname);
 	ll_finish_md_op_data(op_data);
 	if (!err) {
 		ll_update_times(request, src);
diff --git a/fs/lustre/llite/statahead.c b/fs/lustre/llite/statahead.c
index e00fe58..cb435d5 100644
--- a/fs/lustre/llite/statahead.c
+++ b/fs/lustre/llite/statahead.c
@@ -330,6 +330,11 @@ static void sa_free(struct ll_statahead_info *sai, struct sa_entry *entry)
 /* finish async stat RPC arguments */
 static void sa_fini_data(struct md_enqueue_info *minfo)
 {
+	struct md_op_data *op_data = &minfo->mi_data;
+
+	if (op_data->op_flags & MF_OPNAME_KMALLOCED)
+		/* allocated via ll_setup_filename called from sa_prep_data */
+		kfree(op_data->op_name);
 	ll_unlock_md_op_lsm(&minfo->mi_data);
 	iput(minfo->mi_dir);
 	kfree(minfo);
@@ -1031,6 +1036,7 @@ static int ll_statahead_thread(void *arg)
 			u64 hash;
 			int namelen;
 			char *name;
+			struct fscrypt_str lltr = FSTR_INIT(NULL, 0);
 
 			hash = le64_to_cpu(ent->lde_hash);
 			if (unlikely(hash < pos))
@@ -1107,7 +1113,27 @@ static int ll_statahead_thread(void *arg)
 			}
 			__set_current_state(TASK_RUNNING);
 
+			if (IS_ENCRYPTED(dir)) {
+				struct fscrypt_str de_name =
+					FSTR_INIT(ent->lde_name, namelen);
+
+				rc = fscrypt_fname_alloc_buffer(dir, NAME_MAX,
+								&lltr);
+				if (rc < 0)
+					continue;
+
+				if (ll_fname_disk_to_usr(dir, 0, 0, &de_name,
+							 &lltr)) {
+					fscrypt_fname_free_buffer(&lltr);
+					continue;
+				}
+
+				name = lltr.name;
+				namelen = lltr.len;
+			}
+
 			sa_statahead(parent, name, namelen, &fid);
+			fscrypt_fname_free_buffer(&lltr);
 		}
 
 		pos = le64_to_cpu(dp->ldp_hash_end);
@@ -1249,6 +1275,7 @@ enum {
 /* file is first dirent under @dir */
 static int is_first_dirent(struct inode *dir, struct dentry *dentry)
 {
+	struct fscrypt_str lltr = FSTR_INIT(NULL, 0);
 	const struct qstr *target = &dentry->d_name;
 	struct md_op_data *op_data;
 	struct page *page;
@@ -1260,6 +1287,14 @@ static int is_first_dirent(struct inode *dir, struct dentry *dentry)
 				     LUSTRE_OPC_ANY, dir);
 	if (IS_ERR(op_data))
 		return PTR_ERR(op_data);
+
+	if (IS_ENCRYPTED(dir)) {
+		int rc2 = fscrypt_fname_alloc_buffer(dir, NAME_MAX, &lltr);
+
+		if (rc2 < 0)
+			return rc2;
+	}
+
 	/**
 	 * FIXME choose the start offset of the readdir
 	 */
@@ -1286,6 +1321,7 @@ static int is_first_dirent(struct inode *dir, struct dentry *dentry)
 			u64 hash;
 			int namelen;
 			char *name;
+			struct fscrypt_str lltr = FSTR_INIT(NULL, 0);
 
 			hash = le64_to_cpu(ent->lde_hash);
 			/*
@@ -1327,6 +1363,17 @@ static int is_first_dirent(struct inode *dir, struct dentry *dentry)
 				continue;
 			}
 
+			if (IS_ENCRYPTED(dir)) {
+				struct fscrypt_str de_name =
+					FSTR_INIT(ent->lde_name, namelen);
+
+				if (ll_fname_disk_to_usr(dir, 0, 0, &de_name,
+							  &lltr))
+					continue;
+				name = lltr.name;
+				namelen = lltr.len;
+			}
+
 			if (target->len != namelen ||
 			    memcmp(target->name, name, namelen) != 0)
 				rc = LS_NOT_FIRST_DE;
@@ -1357,6 +1404,7 @@ static int is_first_dirent(struct inode *dir, struct dentry *dentry)
 		}
 	}
 out:
+	fscrypt_fname_free_buffer(&lltr);
 	ll_finish_md_op_data(op_data);
 
 	return rc;
diff --git a/fs/lustre/mdc/mdc_lib.c b/fs/lustre/mdc/mdc_lib.c
index ccaa0f2..d07ef81 100644
--- a/fs/lustre/mdc/mdc_lib.c
+++ b/fs/lustre/mdc/mdc_lib.c
@@ -101,8 +101,12 @@ static void mdc_pack_name(struct req_capsule *pill,
 	buf = req_capsule_client_get(pill, field);
 	buf_size = req_capsule_get_size(pill, field, RCL_CLIENT);
 
-	LASSERT(name && name_len && buf && buf_size == name_len + 1);
+	LASSERT(buf && buf_size == name_len + 1);
 
+	if (!name) {
+		buf[name_len] = '\0';
+		return;
+	}
 	cpy_len = strlcpy(buf, name, buf_size);
 
 	LASSERT(lu_name_is_valid_2(buf, cpy_len));
diff --git a/fs/lustre/ptlrpc/layout.c b/fs/lustre/ptlrpc/layout.c
index 836b2a2..2874a41 100644
--- a/fs/lustre/ptlrpc/layout.c
+++ b/fs/lustre/ptlrpc/layout.c
@@ -969,7 +969,7 @@ struct req_msg_field RMF_FID_ARRAY =
 EXPORT_SYMBOL(RMF_FID_ARRAY);
 
 struct req_msg_field RMF_SYMTGT =
-	DEFINE_MSGF("symtgt", RMF_F_STRING, -1, NULL, NULL);
+	DEFINE_MSGF("symtgt", 0, -1, NULL, NULL);
 EXPORT_SYMBOL(RMF_SYMTGT);
 
 struct req_msg_field RMF_TGTUUID =
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
