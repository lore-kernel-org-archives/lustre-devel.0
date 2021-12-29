Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 08296C433EF
	for <lustre-devel@archiver.kernel.org>; Wed, 29 Dec 2021 14:51:47 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id B165A3AD5AD;
	Wed, 29 Dec 2021 06:51:42 -0800 (PST)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 253093AD37B
 for <lustre-devel@lists.lustre.org>; Wed, 29 Dec 2021 06:51:32 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 945BF1006F11;
 Wed, 29 Dec 2021 09:51:28 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 8E8C6D9E6D; Wed, 29 Dec 2021 09:51:28 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Wed, 29 Dec 2021 09:51:21 -0500
Message-Id: <1640789487-22279-8-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1640789487-22279-1-git-send-email-jsimmons@infradead.org>
References: <1640789487-22279-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 07/13] lustre: sec: no encryption key
 migrate/extend/resync/split
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

Allow some layout operations on encrypted files, even when the
encryption key is not available:
- lfs migrate
- lfs mirror extend
- lfs mirror resync
- lfs mirror verify
- lfs mirror split
We allow these access patterns to applications that know what they are
doing, by using the specific flag O_FILE_ENC and O_DIRECT.

WC-bug-id: https://jira.whamcloud.com/browse/LU-14677
Lustre-commit: fdbf2ffd41fa56607 ("LU-14677 sec: no encryption key migrate/extend/resync/split")
Signed-off-by: Sebastien Buisson <sbuisson@ddn.com>
Reviewed-on: https://review.whamcloud.com/44024
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/obd.h                 |   1 -
 fs/lustre/llite/crypto.c                |  55 +++++++++++++---
 fs/lustre/llite/dir.c                   |  13 +++-
 fs/lustre/llite/file.c                  |  49 +++++++++-----
 fs/lustre/llite/llite_internal.h        |  10 ++-
 fs/lustre/llite/llite_lib.c             | 109 ++++++++++++++++++++++++++++++--
 fs/lustre/llite/namei.c                 |  64 +++++++++----------
 fs/lustre/llite/rw26.c                  |   2 +-
 fs/lustre/llite/xattr.c                 |   4 +-
 fs/lustre/osc/osc_request.c             |  42 +++++++++---
 include/uapi/linux/lustre/lustre_user.h |   4 ++
 11 files changed, 273 insertions(+), 80 deletions(-)

diff --git a/fs/lustre/include/obd.h b/fs/lustre/include/obd.h
index 3aa5b37..f6b9d16 100644
--- a/fs/lustre/include/obd.h
+++ b/fs/lustre/include/obd.h
@@ -734,7 +734,6 @@ enum md_op_code {
 	LUSTRE_OPC_ANY,
 	LUSTRE_OPC_LOOKUP,
 	LUSTRE_OPC_OPEN,
-	LUSTRE_OPC_MIGR,
 };
 
 /**
diff --git a/fs/lustre/llite/crypto.c b/fs/lustre/llite/crypto.c
index 7bc6e01..6a12b6c 100644
--- a/fs/lustre/llite/crypto.c
+++ b/fs/lustre/llite/crypto.c
@@ -41,7 +41,7 @@ static int ll_get_context(struct inode *inode, void *ctx, size_t len)
 		return PTR_ERR(env);
 
 	/* Set lcc_getencctx=1 to allow this thread to read
-	 * LL_XATTR_NAME_ENCRYPTION_CONTEXT xattr, as requested by llcrypt.
+	 * LL_XATTR_NAME_ENCRYPTION_CONTEXT xattr, as requested by fscrypt.
 	 */
 	ll_cl_add(inode, env, NULL, LCC_RW);
 	ll_env_info(env)->lti_io_ctx.lcc_getencctx = 1;
@@ -129,7 +129,33 @@ static int ll_set_context(struct inode *inode, const void *ctx, size_t len,
 	return ll_set_encflags(inode, (void *)ctx, len, false);
 }
 
-#define llcrypto_free_ctx	kfree
+/**
+ * ll_file_open_encrypt() - overlay to fscrypt_file_open
+ * @inode: the inode being opened
+ * @filp: the struct file being set up
+ *
+ * This overlay function is necessary to handle encrypted file open without
+ * the key. We allow this access pattern to applications that know what they
+ * are doing, by using the specific flag O_FILE_ENC.
+ * This flag is only compatible with O_DIRECT IOs, to make sure ciphertext
+ * data is wiped from page cache once IOs are finished.
+ */
+int ll_file_open_encrypt(struct inode *inode, struct file *filp)
+{
+	int rc;
+
+	rc = fscrypt_file_open(inode, filp);
+	if (likely(rc != -ENOKEY))
+		return rc;
+
+	if (rc == -ENOKEY &&
+	    (filp->f_flags & O_FILE_ENC) == O_FILE_ENC &&
+	    filp->f_flags & O_DIRECT)
+		/* allow file open with O_FILE_ENC flag when we have O_DIRECT */
+		rc = 0;
+
+	return rc;
+}
 
 bool ll_sbi_has_test_dummy_encryption(struct ll_sb_info *sbi)
 {
@@ -183,9 +209,9 @@ static bool ll_empty_dir(struct inode *inode)
  * This overlay function is necessary to properly encode @fname after
  * encryption, as it will be sent over the wire.
  * This overlay function is also necessary to handle the case of operations
- * carried out without the key. Normally llcrypt makes use of digested names in
+ * carried out without the key. Normally fscrypt makes use of digested names in
  * that case. Having a digested name works for local file systems that can call
- * llcrypt_match_name(), but Lustre server side is not aware of encryption.
+ * fscrypt_match_name(), but Lustre server side is not aware of encryption.
  * So for keyless @lookup operations on long names, for Lustre we choose to
  * present to users the encoded struct ll_digest_filename, instead of a digested
  * name. FID and name hash can then easily be extracted and put into the
@@ -218,6 +244,17 @@ int ll_setup_filename(struct inode *dir, const struct qstr *iname,
 		fid->f_ver = 0;
 	}
 	rc = fscrypt_setup_filename(dir, &dname, lookup, fname);
+	if (rc == -ENOENT && lookup &&
+	    !fscrypt_has_encryption_key(dir) &&
+	    unlikely(filename_is_volatile(iname->name, iname->len, NULL))) {
+		/* For purpose of migration or mirroring without enc key, we
+		 * allow lookup of volatile file without enc context.
+		 */
+		memset(fname, 0, sizeof(struct fscrypt_name));
+		fname->disk_name.name = (unsigned char *)iname->name;
+		fname->disk_name.len = iname->len;
+		rc = 0;
+	}
 	if (rc)
 		return rc;
 
@@ -294,9 +331,9 @@ int ll_setup_filename(struct inode *dir, const struct qstr *iname,
  * This overlay function is necessary to properly decode @iname before
  * decryption, as it comes from the wire.
  * This overlay function is also necessary to handle the case of operations
- * carried out without the key. Normally llcrypt makes use of digested names in
+ * carried out without the key. Normally fscrypt makes use of digested names in
  * that case. Having a digested name works for local file systems that can call
- * llcrypt_match_name(), but Lustre server side is not aware of encryption.
+ * fscrypt_match_name(), but Lustre server side is not aware of encryption.
  * So for keyless @lookup operations on long names, for Lustre we choose to
  * present to users the encoded struct ll_digest_filename, instead of a digested
  * name. FID and name hash can then easily be extracted and put into the
@@ -334,7 +371,7 @@ int ll_fname_disk_to_usr(struct inode *inode,
 			digested = 1;
 			/* Without the key for long names, set the dentry name
 			 * to the representing struct ll_digest_filename. It
-			 * will be encoded by llcrypt for display, and will
+			 * will be encoded by fscrypt for display, and will
 			 * enable further lookup requests.
 			 */
 			if (!fid)
@@ -373,7 +410,7 @@ int ll_revalidate_d_crypto(struct dentry *dentry, unsigned int flags)
 	int valid;
 
 	/*
-	 * Plaintext names are always valid, since llcrypt doesn't support
+	 * Plaintext names are always valid, since fscrypt doesn't support
 	 * reverting to ciphertext names without evicting the directory's inode
 	 * -- which implies eviction of the dentries in the directory.
 	 */
@@ -383,7 +420,7 @@ int ll_revalidate_d_crypto(struct dentry *dentry, unsigned int flags)
 	/*
 	 * Ciphertext name; valid if the directory's key is still unavailable.
 	 *
-	 * Although llcrypt forbids rename() on ciphertext names, we still must
+	 * Although fscrypt forbids rename() on ciphertext names, we still must
 	 * use dget_parent() here rather than use ->d_parent directly.  That's
 	 * because a corrupted fs image may contain directory hard links, which
 	 * the VFS handles by moving the directory's dentry tree in the dcache
diff --git a/fs/lustre/llite/dir.c b/fs/lustre/llite/dir.c
index 40e83e7..f3f1ce7 100644
--- a/fs/lustre/llite/dir.c
+++ b/fs/lustre/llite/dir.c
@@ -1805,7 +1805,12 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 			st.st_uid = body->mbo_uid;
 			st.st_gid = body->mbo_gid;
 			st.st_rdev = body->mbo_rdev;
-			st.st_size = body->mbo_size;
+			if (fscrypt_require_key(inode) == -ENOKEY)
+				st.st_size = round_up(st.st_size,
+						      LUSTRE_ENCRYPTION_UNIT_SIZE);
+			else
+				st.st_size = body->mbo_size;
+
 			st.st_blksize = PAGE_SIZE;
 			st.st_blocks = body->mbo_blocks;
 			st.st_atime = body->mbo_atime;
@@ -1829,7 +1834,11 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 			stx.stx_mode = body->mbo_mode;
 			stx.stx_ino = cl_fid_build_ino(&body->mbo_fid1,
 						       api32);
-			stx.stx_size = body->mbo_size;
+			if (fscrypt_require_key(inode) == -ENOKEY)
+				stx.stx_size = round_up(stx.stx_size,
+						   LUSTRE_ENCRYPTION_UNIT_SIZE);
+			else
+				stx.stx_size = body->mbo_size;
 			stx.stx_blocks = body->mbo_blocks;
 			stx.stx_atime.tv_sec = body->mbo_atime;
 			stx.stx_ctime.tv_sec = body->mbo_ctime;
diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index 0dd1bae..eafb936 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -104,7 +104,16 @@ static void ll_prepare_close(struct inode *inode, struct md_op_data *op_data,
 	op_data->op_attr.ia_atime = inode->i_atime;
 	op_data->op_attr.ia_mtime = inode->i_mtime;
 	op_data->op_attr.ia_ctime = inode->i_ctime;
-	op_data->op_attr.ia_size = i_size_read(inode);
+	/* In case of encrypted file without the key, visible size was rounded
+	 * up to next LUSTRE_ENCRYPTION_UNIT_SIZE, and clear text size was
+	 * stored into lli_lazysize in ll_merge_attr(), so set proper file size
+	 * now that we are closing.
+	 */
+	if (fscrypt_require_key(inode) == -ENOKEY &&
+	    ll_i2info(inode)->lli_attr_valid & OBD_MD_FLLAZYSIZE)
+		op_data->op_attr.ia_size = ll_i2info(inode)->lli_lazysize;
+	else
+		op_data->op_attr.ia_size = i_size_read(inode);
 	op_data->op_attr.ia_valid |= (ATTR_MODE | ATTR_ATIME | ATTR_ATIME_SET |
 				      ATTR_MTIME | ATTR_MTIME_SET |
 				      ATTR_CTIME);
@@ -796,6 +805,7 @@ int ll_file_open(struct inode *inode, struct file *file)
 	struct lookup_intent *it, oit = { .it_op = IT_OPEN,
 					  .it_flags = file->f_flags };
 	struct obd_client_handle **och_p = NULL;
+	struct dentry *de = file_dentry(file);
 	u64 *och_usecount = NULL;
 	struct ll_file_data *fd;
 	ktime_t kstart = ktime_get();
@@ -808,9 +818,12 @@ int ll_file_open(struct inode *inode, struct file *file)
 	file->private_data = NULL; /* prevent ll_local_open assertion */
 
 	if (S_ISREG(inode->i_mode)) {
-		rc = fscrypt_file_open(inode, file);
-		if (rc)
+		rc = ll_file_open_encrypt(inode, file);
+		if (rc) {
+			if (it && it->it_disposition)
+				ll_release_openhandle(d_inode(de), it);
 			goto out_nofiledata;
+		}
 	}
 
 	fd = ll_file_data_get();
@@ -1475,6 +1488,16 @@ int ll_merge_attr(const struct lu_env *env, struct inode *inode)
 	CDEBUG(D_VFSTRACE, DFID " updating i_size %llu\n",
 	       PFID(&lli->lli_fid), attr->cat_size);
 
+	if (fscrypt_require_key(inode) == -ENOKEY) {
+		/* Without the key, round up encrypted file size to next
+		 * LUSTRE_ENCRYPTION_UNIT_SIZE. Clear text size is put in
+		 * lli_lazysize for proper file size setting at close time.
+		 */
+		lli->lli_attr_valid |= OBD_MD_FLLAZYSIZE;
+		lli->lli_lazysize = attr->cat_size;
+		attr->cat_size = round_up(attr->cat_size,
+					  LUSTRE_ENCRYPTION_UNIT_SIZE);
+	}
 	i_size_write(inode, attr->cat_size);
 
 	inode->i_blocks = attr->cat_blocks;
@@ -4344,6 +4367,12 @@ loff_t ll_lseek(struct file *file, loff_t offset, int whence)
 
 	cl_env_put(env, &refcheck);
 
+	/* Without the key, SEEK_HOLE return value has to be
+	 * rounded up to next LUSTRE_ENCRYPTION_UNIT_SIZE.
+	 */
+	if (fscrypt_require_key(inode) == -ENOKEY && whence == SEEK_HOLE)
+		retval = round_up(retval, LUSTRE_ENCRYPTION_UNIT_SIZE);
+
 	return retval;
 }
 
@@ -4746,20 +4775,8 @@ int ll_migrate(struct inode *parent, struct file *file, struct lmv_user_md *lum,
 		goto out_iput;
 	}
 
-	if (IS_ENCRYPTED(child_inode)) {
-		rc = fscrypt_get_encryption_info(child_inode);
-		if (rc)
-			goto out_iput;
-		if (!fscrypt_has_encryption_key(child_inode)) {
-			CDEBUG(D_SEC, "no enc key for "DFID"\n",
-			       PFID(ll_inode2fid(child_inode)));
-			rc = -ENOKEY;
-			goto out_iput;
-		}
-	}
-
 	op_data = ll_prep_md_op_data(NULL, parent, NULL, name, namelen,
-				     child_inode->i_mode, LUSTRE_OPC_MIGR, NULL);
+				     child_inode->i_mode, LUSTRE_OPC_ANY, NULL);
 	if (IS_ERR(op_data)) {
 		rc = PTR_ERR(op_data);
 		goto out_iput;
diff --git a/fs/lustre/llite/llite_internal.h b/fs/lustre/llite/llite_internal.h
index 12d47e8..54fd8d4 100644
--- a/fs/lustre/llite/llite_internal.h
+++ b/fs/lustre/llite/llite_internal.h
@@ -1184,6 +1184,8 @@ int ll_revalidate_it_finish(struct ptlrpc_request *request,
 struct inode *ll_inode_from_resource_lock(struct ldlm_lock *lock);
 void ll_dir_clear_lsm_md(struct inode *inode);
 void ll_clear_inode(struct inode *inode);
+int volatile_ref_file(const char *volatile_name, int volatile_len,
+		      struct file **ref_file);
 int ll_setattr_raw(struct dentry *dentry, struct iattr *attr,
 		   enum op_xvalid xvalid, bool hsm_import);
 int ll_setattr(struct dentry *de, struct iattr *attr);
@@ -1707,7 +1709,7 @@ static inline struct pcc_super *ll_info2pccs(struct ll_inode_info *lli)
 #ifdef CONFIG_FS_ENCRYPTION
 /* The digested form is made of a FID (16 bytes) followed by the second-to-last
  * ciphertext block (16 bytes), so a total length of 32 bytes.
- * That way, llcrypt does not compute a digested form of this digest.
+ * That way, fscrypt does not compute a digested form of this digest.
  */
 struct ll_digest_filename {
 	struct lu_fid ldf_fid;
@@ -1722,6 +1724,7 @@ int ll_fname_disk_to_usr(struct inode *inode,
 			 struct fscrypt_str *iname, struct fscrypt_str *oname,
 			 struct lu_fid *fid);
 int ll_revalidate_d_crypto(struct dentry *dentry, unsigned int flags);
+int ll_file_open_encrypt(struct inode *inode, struct file *filp);
 #else
 int ll_setup_filename(struct inode *dir, const struct qstr *iname,
 		      int lookup, struct fscrypt_name *fname)
@@ -1740,6 +1743,11 @@ int ll_revalidate_d_crypto(struct dentry *dentry, unsigned int flags)
 {
 	return 1;
 }
+
+int ll_file_open_encrypt(struct inode *inode, struct file *filp)
+{
+	return 0;
+}
 #endif
 
 extern const struct fscrypt_operations lustre_cryptops;
diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index 7f168a2..c9be5af 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -40,6 +40,7 @@
 #include <linux/module.h>
 #include <linux/random.h>
 #include <linux/statfs.h>
+#include <linux/file.h>
 #include <linux/types.h>
 #include <linux/mm.h>
 #include <linux/delay.h>
@@ -1863,7 +1864,7 @@ int ll_io_zero_page(struct inode *inode, pgoff_t index, pgoff_t offset,
 		 */
 		SetPagePrivate2(vmpage);
 		rc = ll_io_read_page(env, io, clpage, NULL);
-		if (!PagePrivate2(vmpage))
+		if (!PagePrivate2(vmpage)) {
 			/* PagePrivate2 was cleared in osc_brw_fini_request()
 			 * meaning we read an empty page. In this case, in order
 			 * to avoid allocating unnecessary block in truncated
@@ -1872,6 +1873,7 @@ int ll_io_zero_page(struct inode *inode, pgoff_t index, pgoff_t offset,
 			 */
 			rc = 0;
 			goto clpfini;
+		}
 		ClearPagePrivate2(vmpage);
 		if (rc)
 			goto clpfini;
@@ -1925,6 +1927,44 @@ int ll_io_zero_page(struct inode *inode, pgoff_t index, pgoff_t offset,
 	return rc;
 }
 
+/**
+ * Get reference file from volatile file name.
+ * Volatile file name may look like:
+ * <parent>/LUSTRE_VOLATILE_HDR:<mdt_index>:<random>:fd=<fd>
+ * where fd is opened descriptor of reference file.
+ *
+ * \param[in] volatile_name	volatile file name
+ * \param[in] volatile_len	volatile file name length
+ * \param[out] ref_file		pointer to struct file of reference file
+ *
+ * \retval 0		on success
+ * \retval negative	errno on failure
+ */
+int volatile_ref_file(const char *volatile_name, int volatile_len,
+		      struct file **ref_file)
+{
+	char *p, *q, *fd_str;
+	int fd, rc;
+
+	p = strnstr(volatile_name, ":fd=", volatile_len);
+	if (!p || strlen(p + 4) == 0)
+		return -EINVAL;
+
+	q = strchrnul(p + 4, ':');
+	fd_str = kstrndup(p + 4, q - p - 4, GFP_NOFS);
+	if (!fd_str)
+		return -ENOMEM;
+	rc = kstrtouint(fd_str, 10, &fd);
+	kfree(fd_str);
+	if (rc)
+		return -EINVAL;
+
+	*ref_file = fget(fd);
+	if (!(*ref_file))
+		return -EINVAL;
+	return 0;
+}
+
 /* If this inode has objects allocated to it (lsm != NULL), then the OST
  * object(s) determine the file size and mtime.  Otherwise, the MDS will
  * keep these values until such a time that objects are allocated for it.
@@ -2090,6 +2130,58 @@ int ll_setattr_raw(struct dentry *dentry, struct iattr *attr,
 					if (rc)
 						goto out;
 				}
+				/* If encrypted volatile file without the key,
+				 * we need to fetch size from reference file,
+				 * and set it on OST objects. This happens when
+				 * migrating or extending an encrypted file
+				 * without the key.
+				 */
+				if (filename_is_volatile(dentry->d_name.name,
+							 dentry->d_name.len,
+							 NULL) &&
+				    fscrypt_require_key(inode) == -ENOKEY) {
+					struct file *ref_file;
+					struct inode *ref_inode;
+					struct ll_inode_info *ref_lli;
+					struct cl_object *ref_obj;
+					struct cl_attr ref_attr = { 0 };
+					struct lu_env *env;
+					u16 refcheck;
+
+					rc = volatile_ref_file(
+						dentry->d_name.name,
+						dentry->d_name.len,
+						&ref_file);
+					if (rc)
+						goto out;
+
+					ref_inode = file_inode(ref_file);
+					if (!ref_inode) {
+						fput(ref_file);
+						rc = -EINVAL;
+						goto out;
+					}
+
+					env = cl_env_get(&refcheck);
+					if (IS_ERR(env)) {
+						rc = PTR_ERR(env);
+						goto out;
+					}
+
+					ref_lli = ll_i2info(ref_inode);
+					ref_obj = ref_lli->lli_clob;
+					cl_object_attr_lock(ref_obj);
+					rc = cl_object_attr_get(env, ref_obj,
+								&ref_attr);
+					cl_object_attr_unlock(ref_obj);
+					cl_env_put(env, &refcheck);
+					fput(ref_file);
+					if (rc)
+						goto out;
+
+					attr->ia_valid |= ATTR_SIZE;
+					attr->ia_size = ref_attr.cat_size;
+				}
 			}
 			rc = cl_setattr_ost(ll_i2info(inode)->lli_clob,
 					    attr, xvalid, flags);
@@ -2462,7 +2554,15 @@ int ll_update_inode(struct inode *inode, struct lustre_md *md)
 
 	LASSERT(fid_seq(&lli->lli_fid) != 0);
 
-	lli->lli_attr_valid = body->mbo_valid;
+	/* In case of encrypted file without the key, please do not lose
+	 * clear text size stored into lli_lazysize in ll_merge_attr(),
+	 * we will need it in ll_prepare_close().
+	 */
+	if (lli->lli_attr_valid & OBD_MD_FLLAZYSIZE && lli->lli_lazysize &&
+	    fscrypt_require_key(inode) == -ENOKEY)
+		lli->lli_attr_valid = body->mbo_valid | OBD_MD_FLLAZYSIZE;
+	else
+		lli->lli_attr_valid = body->mbo_valid;
 	if (body->mbo_valid & OBD_MD_FLSIZE) {
 		i_size_write(inode, body->mbo_size);
 
@@ -3097,11 +3197,10 @@ struct md_op_data *ll_prep_md_op_data(struct md_op_data *op_data,
 			op_data->op_flags |= MF_OPNAME_KMALLOCED;
 	}
 
-	/* In fact LUSTRE_OPC_LOOKUP, LUSTRE_OPC_OPEN, LUSTRE_OPC_MIGR
+	/* In fact LUSTRE_OPC_LOOKUP, LUSTRE_OPC_OPEN
 	 * are LUSTRE_OPC_ANY
 	 */
-	if (opc == LUSTRE_OPC_LOOKUP || opc == LUSTRE_OPC_OPEN ||
-	    opc == LUSTRE_OPC_MIGR)
+	if (opc == LUSTRE_OPC_LOOKUP || opc == LUSTRE_OPC_OPEN)
 		op_data->op_code = LUSTRE_OPC_ANY;
 	else
 		op_data->op_code = opc;
diff --git a/fs/lustre/llite/namei.c b/fs/lustre/llite/namei.c
index 5fff54d..d46a30f 100644
--- a/fs/lustre/llite/namei.c
+++ b/fs/lustre/llite/namei.c
@@ -49,7 +49,7 @@
 static int ll_create_it(struct inode *dir, struct dentry *dentry,
 			struct lookup_intent *it,
 			void *secctx, u32 secctxlen, bool encrypt,
-			void *encctx, u32 encctxlen);
+			void *encctx, u32 encctxlen, unsigned int open_flags);
 
 /* called from iget5_locked->find_inode() under inode_hash_lock spinlock */
 static int ll_test_inode(struct inode *inode, void *opaque)
@@ -908,44 +908,21 @@ static struct dentry *ll_lookup_it(struct inode *parent, struct dentry *dentry,
 			*secctxlen = 0;
 	}
 	if (it->it_op & IT_CREAT && encrypt) {
-		/* Volatile file name may look like:
-		 * <parent>/LUSTRE_VOLATILE_HDR:<mdt_index>:<random>:fd=<fd>
-		 * where fd is opened descriptor of reference file.
-		 */
 		if (unlikely(filename_is_volatile(dentry->d_name.name,
 						  dentry->d_name.len, NULL))) {
+			/* get encryption context from reference file */
 			int ctx_size = LLCRYPT_ENC_CTX_SIZE;
 			struct lustre_sb_info *lsi;
 			struct file *ref_file;
 			struct inode *ref_inode;
-			char *p, *q, *fd_str;
 			void *ctx;
-			int fd;
 
-			p = strnstr(dentry->d_name.name, ":fd=",
-				    dentry->d_name.len);
-			if (!p || strlen(p + 4) == 0) {
-				retval = ERR_PTR(-EINVAL);
-				goto out;
-			}
-
-			q = strchrnul(p + 4, ':');
-			fd_str = kstrndup(p + 4, q - p - 4, GFP_NOFS);
-			if (!fd_str) {
-				retval = ERR_PTR(-ENOMEM);
-				goto out;
-			}
-			rc = kstrtouint(fd_str, 10, &fd);
-			kfree(fd_str);
+			rc = volatile_ref_file(dentry->d_name.name,
+					       dentry->d_name.len,
+					       &ref_file);
 			if (rc) {
-				rc = -EINVAL;
-				goto inherit;
-			}
-
-			ref_file = fget(fd);
-			if (!ref_file) {
-				rc = -EINVAL;
-				goto inherit;
+				retval = ERR_PTR(rc);
+				goto out;
 			}
 
 			ref_inode = file_inode(ref_file);
@@ -1254,7 +1231,14 @@ static int ll_atomic_open(struct inode *dir, struct dentry *dentry,
 		if (rc)
 			goto out_release;
 		if (open_flags & O_CREAT) {
-			if (!fscrypt_has_encryption_key(dir)) {
+			/* For migration or mirroring without enc key, we still
+			 * need to be able to create a volatile file.
+			 */
+			if (!fscrypt_has_encryption_key(dir) &&
+			    (!filename_is_volatile(dentry->d_name.name,
+						   dentry->d_name.len, NULL) ||
+			    (open_flags & O_FILE_ENC) != O_FILE_ENC ||
+			    !(open_flags & O_DIRECT))) {
 				rc = -ENOKEY;
 				goto out_release;
 			}
@@ -1287,7 +1271,8 @@ static int ll_atomic_open(struct inode *dir, struct dentry *dentry,
 		if (it_disposition(it, DISP_OPEN_CREATE)) {
 			/* Dentry instantiated in ll_create_it. */
 			rc = ll_create_it(dir, dentry, it, secctx, secctxlen,
-					  encrypt, encctx, encctxlen);
+					  encrypt, encctx, encctxlen,
+					  open_flags);
 			security_release_secctx(secctx, secctxlen);
 			kfree(encctx);
 			if (rc) {
@@ -1414,7 +1399,7 @@ static struct inode *ll_create_node(struct inode *dir, struct lookup_intent *it)
 static int ll_create_it(struct inode *dir, struct dentry *dentry,
 			struct lookup_intent *it,
 			void *secctx, u32 secctxlen, bool encrypt,
-			void *encctx, u32 encctxlen)
+			void *encctx, u32 encctxlen, unsigned int open_flags)
 {
 	struct inode *inode;
 	u64 bits = 0;
@@ -1449,7 +1434,18 @@ static int ll_create_it(struct inode *dir, struct dentry *dentry,
 	d_instantiate(dentry, inode);
 
 	if (encrypt) {
-		rc = ll_set_encflags(inode, encctx, encctxlen, true);
+		bool preload = true;
+
+		/* For migration or mirroring without enc key, we
+		 * create a volatile file without enc context.
+		 */
+		if (!fscrypt_has_encryption_key(dir) &&
+		    filename_is_volatile(dentry->d_name.name,
+					 dentry->d_name.len, NULL) &&
+		    (open_flags & O_FILE_ENC) == O_FILE_ENC &&
+		    open_flags & O_DIRECT)
+			preload = false;
+		rc = ll_set_encflags(inode, encctx, encctxlen, preload);
 		if (rc)
 			return rc;
 	}
diff --git a/fs/lustre/llite/rw26.c b/fs/lustre/llite/rw26.c
index 0a271b9..4c2ab38 100644
--- a/fs/lustre/llite/rw26.c
+++ b/fs/lustre/llite/rw26.c
@@ -257,7 +257,7 @@ struct ll_dio_pages {
 		if (inode && IS_ENCRYPTED(inode)) {
 			/* In case of Direct IO on encrypted file, we need to
 			 * add a reference to the inode on the cl_page.
-			 * This info is required by llcrypt to proceed
+			 * This info is required by fscrypt to proceed
 			 * to encryption/decryption.
 			 * This is safe because we know these pages are private
 			 * to the thread doing the Direct IO.
diff --git a/fs/lustre/llite/xattr.c b/fs/lustre/llite/xattr.c
index b67b822..6aea651 100644
--- a/fs/lustre/llite/xattr.c
+++ b/fs/lustre/llite/xattr.c
@@ -365,7 +365,7 @@ int ll_xattr_list(struct inode *inode, const char *name, int type, void *buffer,
 	int rc;
 
 	/* Getting LL_XATTR_NAME_ENCRYPTION_CONTEXT xattr is only allowed
-	 * when it comes from ll_get_context(), ie when llcrypt needs to
+	 * when it comes from ll_get_context(), ie when fscrypt needs to
 	 * know the encryption context.
 	 * Otherwise, any direct reading of this xattr returns -EPERM.
 	 */
@@ -646,7 +646,7 @@ ssize_t ll_listxattr(struct dentry *dentry, char *buffer, size_t size)
 
 		/* Listing xattrs should not expose
 		 * LL_XATTR_NAME_ENCRYPTION_CONTEXT xattr, unless it comes
-		 * from llcrypt.
+		 * from fscrypt.
 		 */
 		if (get_xattr_type(xattr_name)->flags == XATTR_SECURITY_T &&
 		    !strcmp(xattr_name, LL_XATTR_NAME_ENCRYPTION_CONTEXT)) {
diff --git a/fs/lustre/osc/osc_request.c b/fs/lustre/osc/osc_request.c
index e065eab..59dc625 100644
--- a/fs/lustre/osc/osc_request.c
+++ b/fs/lustre/osc/osc_request.c
@@ -1450,7 +1450,8 @@ static int osc_brw_prep_request(int cmd, struct client_obd *cli,
 	if (!req)
 		return -ENOMEM;
 
-	if (opc == OST_WRITE && inode && IS_ENCRYPTED(inode)) {
+	if (opc == OST_WRITE && inode && IS_ENCRYPTED(inode) &&
+	    fscrypt_has_encryption_key(inode)) {
 		for (i = 0; i < page_count; i++) {
 			struct brw_page *pg = pga[i];
 			struct page *data_page = NULL;
@@ -1461,9 +1462,7 @@ static int osc_brw_prep_request(int cmd, struct client_obd *cli,
 			pgoff_t index_orig;
 
 retry_encrypt:
-			if (nunits & ~LUSTRE_ENCRYPTION_MASK)
-				nunits = (nunits & LUSTRE_ENCRYPTION_MASK) +
-					  LUSTRE_ENCRYPTION_UNIT_SIZE;
+			nunits = round_up(nunits, LUSTRE_ENCRYPTION_UNIT_SIZE);
 			/* The page can already be locked when we arrive here.
 			 * This is possible when cl_page_assume/vvp_page_assume
 			 * is stuck on wait_on_page_writeback with page lock
@@ -1521,14 +1520,38 @@ static int osc_brw_prep_request(int cmd, struct client_obd *cli,
 			pg->bp_off_diff = pg->off & ~PAGE_MASK;
 			pg->off = pg->off & PAGE_MASK;
 		}
-	} else if (opc == OST_READ && inode && IS_ENCRYPTED(inode)) {
+	} else if (opc == OST_WRITE && inode && IS_ENCRYPTED(inode)) {
+		struct osc_async_page *oap = brw_page2oap(pga[0]);
+		struct cl_page *clpage = oap2cl_page(oap);
+		struct cl_object *clobj = clpage->cp_obj;
+		struct cl_attr attr = { 0 };
+		struct lu_env *env;
+		u16 refcheck;
+
+		env = cl_env_get(&refcheck);
+		if (IS_ERR(env)) {
+			rc = PTR_ERR(env);
+			ptlrpc_request_free(req);
+			return rc;
+		}
+
+		cl_object_attr_lock(clobj);
+		rc = cl_object_attr_get(env, clobj, &attr);
+		cl_object_attr_unlock(clobj);
+		cl_env_put(env, &refcheck);
+		if (rc != 0) {
+			ptlrpc_request_free(req);
+			return rc;
+		}
+		if (attr.cat_size)
+			oa->o_size = attr.cat_size;
+	} else if (opc == OST_READ && inode && IS_ENCRYPTED(inode) &&
+		   fscrypt_has_encryption_key(inode)) {
 		for (i = 0; i < page_count; i++) {
 			struct brw_page *pg = pga[i];
 			u32 nunits = (pg->off & ~PAGE_MASK) + pg->count;
 
-			if (nunits & ~LUSTRE_ENCRYPTION_MASK)
-				nunits = (nunits & LUSTRE_ENCRYPTION_MASK) +
-					  LUSTRE_ENCRYPTION_UNIT_SIZE;
+			nunits = round_up(nunits, LUSTRE_ENCRYPTION_UNIT_SIZE);
 			/* count/off are forced to cover the whole encryption
 			 * unit size so that all encrypted data is stored on the
 			 * OST, so adjust bp_{count,off}_diff for the size of
@@ -1554,7 +1577,8 @@ static int osc_brw_prep_request(int cmd, struct client_obd *cli,
 
 	for (i = 0; i < page_count; i++) {
 		short_io_size += pga[i]->count;
-		if (!inode || !IS_ENCRYPTED(inode)) {
+		if (!inode || !IS_ENCRYPTED(inode) ||
+		    !fscrypt_has_encryption_key(inode)) {
 			pga[i]->bp_count_diff = 0;
 			pga[i]->bp_off_diff = 0;
 		}
diff --git a/include/uapi/linux/lustre/lustre_user.h b/include/uapi/linux/lustre/lustre_user.h
index 291e8e0..1e66930 100644
--- a/include/uapi/linux/lustre/lustre_user.h
+++ b/include/uapi/linux/lustre/lustre_user.h
@@ -399,6 +399,10 @@ struct ll_ioc_lease_id {
  * devices and are safe for use on new files (See LU-812, LU-4209).
  */
 #define O_LOV_DELAY_CREATE	(O_NOCTTY | FASYNC)
+/* O_FILE_ENC principle is similar to O_LOV_DELAY_CREATE above,
+ * for access to encrypted files without the encryption key.
+ */
+#define O_FILE_ENC		(O_NOCTTY | O_NDELAY)
 
 #define LL_FILE_IGNORE_LOCK	0x00000001
 #define LL_FILE_GROUP_LOCKED	0x00000002
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
