From: James Simmons <jsimmons@infradead.org>
Date: Tue, 11 Aug 2020 08:20:03 -0400
Subject: [lustre-devel] [PATCH 07/23] lustre: sec: atomicity of encryption
 context getting/setting
In-Reply-To: <1597148419-20629-1-git-send-email-jsimmons@infradead.org>
References: <1597148419-20629-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1597148419-20629-8-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Sebastien Buisson <sbuisson@ddn.com>

Encryption layer needs to set an encryption context on files and dirs
that are encrypted. This context is stored as an extended attribute,
that then needs to be fetched upon metadata ops like lookup, getattr,
open, truncate, and layout.

With this patch we send encryption context to the MDT along with
create RPCs. This closes the insecure window between creation and
setting of the encryption context, and saves a setxattr request.

This patch also introduces a way to have the MDT return encryption
context upon granted lock reply, making the encryption context
retrieval atomic, and sparing the client an additional getxattr
request.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12275
Lustre-commit: 40d91eafe257f ("LU-12275 sec: atomicity of encryption context getting/setting")
Signed-off-by: Sebastien Buisson <sbuisson@ddn.com>
Reviewed-on: https://review.whamcloud.com/38430
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Mike Pershin <mpershin@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_crypto.h      |   2 +
 fs/lustre/include/lustre_export.h      |   5 ++
 fs/lustre/include/lustre_req_layout.h  |   3 +-
 fs/lustre/include/obd.h                |   4 ++
 fs/lustre/llite/crypto.c               |  75 ++++++++++++++++--------
 fs/lustre/llite/dir.c                  |  16 +++--
 fs/lustre/llite/llite_internal.h       |   5 ++
 fs/lustre/llite/llite_lib.c            |   1 +
 fs/lustre/llite/namei.c                | 104 ++++++++++++++++++++++++++++-----
 fs/lustre/llite/xattr_cache.c          |  34 +++++++++++
 fs/lustre/mdc/mdc_internal.h           |   2 +
 fs/lustre/mdc/mdc_lib.c                |  23 ++++++++
 fs/lustre/mdc/mdc_locks.c              |  22 +++++++
 fs/lustre/mdc/mdc_reint.c              |   3 +
 fs/lustre/mdc/mdc_request.c            |   4 +-
 fs/lustre/ptlrpc/layout.c              |  25 +++++---
 fs/lustre/ptlrpc/wiretest.c            |   2 +
 include/uapi/linux/lustre/lustre_idl.h |   3 +-
 18 files changed, 279 insertions(+), 54 deletions(-)

diff --git a/fs/lustre/include/lustre_crypto.h b/fs/lustre/include/lustre_crypto.h
index e9091a2..b80147f 100644
--- a/fs/lustre/include/lustre_crypto.h
+++ b/fs/lustre/include/lustre_crypto.h
@@ -31,6 +31,8 @@
 #define _LUSTRE_CRYPTO_H_
 
 struct ll_sb_info;
+int ll_set_encflags(struct inode *inode, void *encctx, u32 encctxlen,
+		    bool preload);
 bool ll_sbi_has_test_dummy_encryption(struct ll_sb_info *sbi);
 bool ll_sbi_has_encrypt(struct ll_sb_info *sbi);
 void ll_sbi_set_encrypt(struct ll_sb_info *sbi, bool set);
diff --git a/fs/lustre/include/lustre_export.h b/fs/lustre/include/lustre_export.h
index b77605b..b5fdf8a 100644
--- a/fs/lustre/include/lustre_export.h
+++ b/fs/lustre/include/lustre_export.h
@@ -280,6 +280,11 @@ static inline int exp_connect_archive_id_array(struct obd_export *exp)
 	return !!(exp_connect_flags2(exp) & OBD_CONNECT2_ARCHIVE_ID_ARRAY);
 }
 
+static inline int exp_connect_encrypt(struct obd_export *exp)
+{
+	return !!(exp_connect_flags2(exp) & OBD_CONNECT2_ENCRYPT);
+}
+
 enum {
 	/* archive_ids in array format */
 	KKUC_CT_DATA_ARRAY_MAGIC	= 0x092013cea,
diff --git a/fs/lustre/include/lustre_req_layout.h b/fs/lustre/include/lustre_req_layout.h
index 72d9df0..54041b0 100644
--- a/fs/lustre/include/lustre_req_layout.h
+++ b/fs/lustre/include/lustre_req_layout.h
@@ -60,7 +60,7 @@ enum req_location {
 };
 
 /* Maximal number of fields (buffers) in a request message. */
-#define REQ_MAX_FIELD_NR 11
+#define REQ_MAX_FIELD_NR 12
 
 struct req_capsule {
 	struct ptlrpc_request		*rc_req;
@@ -243,6 +243,7 @@ void req_capsule_shrink(struct req_capsule *pill,
 extern struct req_msg_field RMF_FILE_SECCTX_NAME;
 extern struct req_msg_field RMF_FILE_SECCTX;
 extern struct req_msg_field RMF_FID_ARRAY;
+extern struct req_msg_field RMF_FILE_ENCCTX;
 
 /*
  * connection handle received in MDS_CONNECT request.
diff --git a/fs/lustre/include/obd.h b/fs/lustre/include/obd.h
index 849483f..cd3abfd 100644
--- a/fs/lustre/include/obd.h
+++ b/fs/lustre/include/obd.h
@@ -784,6 +784,10 @@ struct md_op_data {
 	void		       *op_file_secctx;
 	u32			op_file_secctx_size;
 
+	/* File encryption context, for creates/metadata ops */
+	void		       *op_file_encctx;
+	u32			op_file_encctx_size;
+
 	u32			op_projid;
 
 	u16			op_mirror_id;
diff --git a/fs/lustre/llite/crypto.c b/fs/lustre/llite/crypto.c
index 157017f..83ed316 100644
--- a/fs/lustre/llite/crypto.c
+++ b/fs/lustre/llite/crypto.c
@@ -49,50 +49,75 @@ static int ll_get_context(struct inode *inode, void *ctx, size_t len)
 	return rc;
 }
 
+int ll_set_encflags(struct inode *inode, void *encctx, u32 encctxlen,
+		    bool preload)
+{
+	unsigned int ext_flags;
+	int rc = 0;
+
+	/* used as encryption unit size */
+	if (S_ISREG(inode->i_mode))
+		inode->i_blkbits = LUSTRE_ENCRYPTION_BLOCKBITS;
+	ext_flags = ll_inode_to_ext_flags(inode->i_flags) | LUSTRE_ENCRYPT_FL;
+	ll_update_inode_flags(inode, ext_flags);
+
+	if (encctx && encctxlen)
+		rc = ll_xattr_cache_insert(inode,
+					   LL_XATTR_NAME_ENCRYPTION_CONTEXT,
+					   encctx, encctxlen);
+	if (rc)
+		return rc;
+
+	return preload ? llcrypt_get_encryption_info(inode) : 0;
+}
+
+/* ll_set_context has 2 distinct behaviors, depending on the value of inode
+ * parameter:
+ * - inode is NULL:
+ *   passed fs_data is a struct md_op_data *. We need to store enc ctx in
+ *   op_data, so that it will be sent along to the server with the request that
+ *   the caller is preparing, thus saving a setxattr request.
+ * - inode is not NULL:
+ *   normal case in which passed fs_data is a struct dentry *, letting proceed
+ *   with setxattr operation.
+ *   This use case should only be used when explicitly setting a new encryption
+ *   policy on an existing, empty directory.
+ */
 static int ll_set_context(struct inode *inode, const void *ctx, size_t len,
 			  void *fs_data)
 {
-	unsigned int ext_flags;
 	struct dentry *dentry;
-	struct md_op_data *op_data;
-	struct ptlrpc_request *req = NULL;
 	int rc;
 
-	if (!inode)
-		return 0;
+	if (!inode) {
+		struct md_op_data *op_data = (struct md_op_data *)fs_data;
 
-	ext_flags = ll_inode_to_ext_flags(inode->i_flags) | LUSTRE_ENCRYPT_FL;
-	dentry = (struct dentry *)fs_data;
+		if (!op_data)
+			return -EINVAL;
+
+		op_data->op_file_encctx = kzalloc(len, GFP_KERNEL);
+		if (!op_data->op_file_encctx)
+			return -ENOMEM;
+		op_data->op_file_encctx_size = len;
+		memcpy(op_data->op_file_encctx, ctx, len);
+		return 0;
+	}
 
 	/* Encrypting the root directory is not allowed */
 	if (inode->i_ino == inode->i_sb->s_root->d_inode->i_ino)
 		return -EPERM;
 
-	op_data = ll_prep_md_op_data(NULL, inode, NULL, NULL, 0, 0,
-				     LUSTRE_OPC_ANY, NULL);
-	if (IS_ERR(op_data))
-		return PTR_ERR(op_data);
-
-	op_data->op_attr_flags = LUSTRE_ENCRYPT_FL;
-	op_data->op_xvalid |= OP_XVALID_FLAGS;
-	rc = md_setattr(ll_i2sbi(inode)->ll_md_exp, op_data, NULL, 0, &req);
-	ll_finish_md_op_data(op_data);
-	ptlrpc_req_finished(req);
-	if (rc)
-		return rc;
-
+	dentry = (struct dentry *)fs_data;
 	rc = __vfs_setxattr(dentry, inode, LL_XATTR_NAME_ENCRYPTION_CONTEXT,
 			    ctx, len, XATTR_CREATE);
 	if (rc)
 		return rc;
 
-	/* used as encryption unit size */
-	if (S_ISREG(inode->i_mode))
-		inode->i_blkbits = LUSTRE_ENCRYPTION_BLOCKBITS;
-	ll_update_inode_flags(inode, ext_flags);
-	return 0;
+	return ll_set_encflags(inode, (void *)ctx, len, false);
 }
 
+#define llcrypto_free_ctx	kfree
+
 inline bool ll_sbi_has_test_dummy_encryption(struct ll_sb_info *sbi)
 {
 	return unlikely(sbi->ll_flags & LL_SBI_TEST_DUMMY_ENCRYPTION);
diff --git a/fs/lustre/llite/dir.c b/fs/lustre/llite/dir.c
index e3305f7..c2a75ce 100644
--- a/fs/lustre/llite/dir.c
+++ b/fs/lustre/llite/dir.c
@@ -448,8 +448,9 @@ static int ll_dir_setdirstripe(struct dentry *dparent, struct lmv_user_md *lump,
 	if (IS_ERR(op_data))
 		return PTR_ERR(op_data);
 
-	if (IS_ENCRYPTED(parent) ||
-	    unlikely(llcrypt_dummy_context_enabled(parent))) {
+	if (ll_sbi_has_encrypt(sbi) &&
+	    (IS_ENCRYPTED(parent) ||
+	     unlikely(llcrypt_dummy_context_enabled(parent)))) {
 		err = llcrypt_get_encryption_info(parent);
 		if (err)
 			goto out_op_data;
@@ -474,6 +475,13 @@ static int ll_dir_setdirstripe(struct dentry *dparent, struct lmv_user_md *lump,
 			goto out_op_data;
 	}
 
+	if (encrypt) {
+		err = llcrypt_inherit_context(parent, NULL, op_data, false);
+		if (err)
+			goto out_op_data;
+	}
+
+
 	op_data->op_cli_flags |= CLI_SET_MEA;
 	err = md_create(sbi->ll_md_exp, op_data, lump, len, mode,
 			from_kuid(&init_user_ns, current_fsuid()),
@@ -501,8 +509,8 @@ static int ll_dir_setdirstripe(struct dentry *dparent, struct lmv_user_md *lump,
 	}
 
 	if (encrypt)
-		err = llcrypt_inherit_context(parent, inode, NULL, false);
-
+		err = ll_set_encflags(inode, op_data->op_file_encctx,
+				      op_data->op_file_encctx_size, false);
 out_inode:
 	iput(inode);
 out_request:
diff --git a/fs/lustre/llite/llite_internal.h b/fs/lustre/llite/llite_internal.h
index 31c528f..89783fb 100644
--- a/fs/lustre/llite/llite_internal.h
+++ b/fs/lustre/llite/llite_internal.h
@@ -402,6 +402,11 @@ static inline void ll_layout_version_set(struct ll_inode_info *lli, u32 gen)
 int ll_xattr_cache_get(struct inode *inode, const char *name,
 		       char *buffer, size_t size, u64 valid);
 
+int ll_xattr_cache_insert(struct inode *inode,
+			  const char *name,
+			  char *buffer,
+			  size_t size);
+
 static inline bool obd_connect_has_secctx(struct obd_connect_data *data)
 {
 #ifdef CONFIG_SECURITY
diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index f52d2b5..4773fc1 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -2873,6 +2873,7 @@ void ll_finish_md_op_data(struct md_op_data *op_data)
 	ll_unlock_md_op_lsm(op_data);
 	security_release_secctx(op_data->op_file_secctx,
 				op_data->op_file_secctx_size);
+	kfree(op_data->op_file_encctx);
 	kfree(op_data);
 }
 
diff --git a/fs/lustre/llite/namei.c b/fs/lustre/llite/namei.c
index 251d6be..3fbcbbd 100644
--- a/fs/lustre/llite/namei.c
+++ b/fs/lustre/llite/namei.c
@@ -48,7 +48,8 @@
 
 static int ll_create_it(struct inode *dir, struct dentry *dentry,
 			struct lookup_intent *it,
-			void *secctx, u32 secctxlen, bool encrypt);
+			void *secctx, u32 secctxlen, bool encrypt,
+			void *encctx, __u32 encctxlen);
 
 /* called from iget5_locked->find_inode() under inode_hash_lock spinlock */
 static int ll_test_inode(struct inode *inode, void *opaque)
@@ -606,6 +607,7 @@ static int ll_lookup_it_finish(struct ptlrpc_request *request,
 			       struct lookup_intent *it,
 			       struct inode *parent, struct dentry **de,
 			       void *secctx, u32 secctxlen,
+			       void *encctx, u32 encctxlen,
 			       ktime_t kstart, bool encrypt)
 {
 	struct inode *inode = NULL;
@@ -666,8 +668,33 @@ static int ll_lookup_it_finish(struct ptlrpc_request *request,
 			rc = security_inode_notifysecctx(inode, secctx,
 							 secctxlen);
 			if (rc)
-				CWARN("cannot set security context for " DFID ": rc = %d\n",
-				      PFID(ll_inode2fid(inode)), rc);
+				CWARN("%s: cannot set security context for " DFID ": rc = %d\n",
+				      ll_i2sbi(inode)->ll_fsname,
+				      PFID(ll_inode2fid(inode)),
+				      rc);
+		}
+
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
+				if (rc)
+					CWARN("%s: cannot set enc ctx for " DFID ": rc = %d\n",
+					      ll_i2sbi(inode)->ll_fsname,
+					      PFID(ll_inode2fid(inode)), rc);
+			}
 		}
 	}
 
@@ -739,7 +766,8 @@ static struct dentry *ll_lookup_it(struct inode *parent, struct dentry *dentry,
 				   struct lookup_intent *it, void **secctx,
 				   u32 *secctxlen,
 				   struct pcc_create_attach *pca,
-				   bool encrypt)
+				   bool encrypt,
+				   void **encctx, u32 *encctxlen)
 {
 	ktime_t kstart = ktime_get();
 	struct lookup_intent lookup_it = { .it_op = IT_LOOKUP };
@@ -816,6 +844,22 @@ static struct dentry *ll_lookup_it(struct inode *parent, struct dentry *dentry,
 		if (secctxlen)
 			*secctxlen = 0;
 	}
+	if (it->it_op & IT_CREAT && encrypt) {
+		rc = llcrypt_inherit_context(parent, NULL, op_data, false);
+		if (rc) {
+			retval = ERR_PTR(rc);
+			goto out;
+		}
+		if (encctx)
+			*encctx = op_data->op_file_encctx;
+		if (encctxlen)
+			*encctxlen = op_data->op_file_encctx_size;
+	} else {
+		if (encctx)
+			*encctx = NULL;
+		if (encctxlen)
+			*encctxlen = 0;
+	}
 
 	/* ask for security context upon intent */
 	if (it->it_op & (IT_LOOKUP | IT_GETATTR | IT_OPEN)) {
@@ -908,6 +952,8 @@ static struct dentry *ll_lookup_it(struct inode *parent, struct dentry *dentry,
 	rc = ll_lookup_it_finish(req, it, parent, &dentry,
 				 secctx ? *secctx : NULL,
 				 secctxlen ? *secctxlen : 0,
+				 encctx ? *encctx : NULL,
+				 encctxlen ? *encctxlen : 0,
 				 kstart, encrypt);
 	if (rc != 0) {
 		ll_intent_release(it);
@@ -936,6 +982,14 @@ static struct dentry *ll_lookup_it(struct inode *parent, struct dentry *dentry,
 			op_data->op_file_secctx = NULL;
 			op_data->op_file_secctx_size = 0;
 		}
+		if (encctx && encctxlen &&
+		    it->it_op & IT_CREAT && encrypt) {
+			/* caller needs enc ctx info, so reset it in op_data to
+			 * prevent it from being freed
+			 */
+			op_data->op_file_encctx = NULL;
+			op_data->op_file_encctx_size = 0;
+		}
 		ll_finish_md_op_data(op_data);
 	}
 
@@ -966,7 +1020,8 @@ static struct dentry *ll_lookup_nd(struct inode *parent, struct dentry *dentry,
 		itp = NULL;
 	else
 		itp = &it;
-	de = ll_lookup_it(parent, dentry, itp, NULL, NULL, NULL, false);
+	de = ll_lookup_it(parent, dentry, itp, NULL, NULL, NULL, false,
+			  NULL, NULL);
 
 	if (itp)
 		ll_intent_release(itp);
@@ -985,6 +1040,8 @@ static int ll_atomic_open(struct inode *dir, struct dentry *dentry,
 	struct lookup_intent *it;
 	void *secctx = NULL;
 	u32 secctxlen = 0;
+	void *encctx = NULL;
+	u32 encctxlen = 0;
 	struct dentry *de;
 	struct ll_sb_info *sbi = NULL;
 	struct pcc_create_attach pca = { NULL, NULL };
@@ -1040,7 +1097,7 @@ static int ll_atomic_open(struct inode *dir, struct dentry *dentry,
 	it->it_flags = (open_flags & ~O_ACCMODE) | OPEN_FMODE(open_flags);
 	it->it_flags &= ~MDS_OPEN_FL_INTERNAL;
 
-	if (IS_ENCRYPTED(dir)) {
+	if (ll_sbi_has_encrypt(ll_i2sbi(dir)) && IS_ENCRYPTED(dir)) {
 		/* we know that we are going to create a regular file because
 		 * we set S_IFREG bit on it->it_create_mode above
 		 */
@@ -1056,7 +1113,8 @@ static int ll_atomic_open(struct inode *dir, struct dentry *dentry,
 	}
 
 	/* Dentry added to dcache tree in ll_lookup_it */
-	de = ll_lookup_it(dir, dentry, it, &secctx, &secctxlen, &pca, encrypt);
+	de = ll_lookup_it(dir, dentry, it, &secctx, &secctxlen, &pca, encrypt,
+			  &encctx, &encctxlen);
 	if (IS_ERR(de))
 		rc = PTR_ERR(de);
 	else if (de)
@@ -1066,8 +1124,9 @@ static int ll_atomic_open(struct inode *dir, struct dentry *dentry,
 		if (it_disposition(it, DISP_OPEN_CREATE)) {
 			/* Dentry instantiated in ll_create_it. */
 			rc = ll_create_it(dir, dentry, it, secctx, secctxlen,
-					  encrypt);
+					  encrypt, encctx, encctxlen);
 			security_release_secctx(secctx, secctxlen);
+			kfree(encctx);
 			if (rc) {
 				/* We dget in ll_splice_alias. */
 				if (de)
@@ -1098,6 +1157,15 @@ static int ll_atomic_open(struct inode *dir, struct dentry *dentry,
 			 * already created PCC copy.
 			 */
 			pcc_create_attach_cleanup(dir->i_sb, &pca);
+
+			if (open_flags & O_CREAT && encrypt &&
+			    dentry->d_inode) {
+				rc = ll_set_encflags(dentry->d_inode, encctx,
+						     encctxlen, true);
+				kfree(encctx);
+				if (rc)
+					goto out_release;
+			}
 		}
 
 		if (d_really_is_positive(dentry) &&
@@ -1182,7 +1250,8 @@ static struct inode *ll_create_node(struct inode *dir, struct lookup_intent *it)
  */
 static int ll_create_it(struct inode *dir, struct dentry *dentry,
 			struct lookup_intent *it,
-			void *secctx, u32 secctxlen, bool encrypt)
+			void *secctx, u32 secctxlen, bool encrypt,
+			void *encctx, __u32 encctxlen)
 {
 	struct inode *inode;
 	u64 bits = 0;
@@ -1220,7 +1289,7 @@ static int ll_create_it(struct inode *dir, struct dentry *dentry,
 	d_instantiate(dentry, inode);
 
 	if (encrypt) {
-		rc = llcrypt_inherit_context(dir, inode, dentry, true);
+		rc = ll_set_encflags(inode, encctx, encctxlen, true);
 		if (rc)
 			return rc;
 	}
@@ -1258,7 +1327,7 @@ static int ll_new_node(struct inode *dir, struct dentry *dentry,
 	struct inode *inode = NULL;
 	struct ll_sb_info *sbi = ll_i2sbi(dir);
 	int tgt_len = 0;
-	int encrypt = 0;
+	bool encrypt = false;
 	int err;
 
 	if (unlikely(tgt))
@@ -1282,9 +1351,10 @@ static int ll_new_node(struct inode *dir, struct dentry *dentry,
 			goto err_exit;
 	}
 
-	if ((IS_ENCRYPTED(dir) &&
+	if (ll_sbi_has_encrypt(sbi) &&
+	    ((IS_ENCRYPTED(dir) &&
 	    (S_ISREG(mode) || S_ISDIR(mode) || S_ISLNK(mode))) ||
-	    (unlikely(llcrypt_dummy_context_enabled(dir)) && S_ISDIR(mode))) {
+	    (unlikely(llcrypt_dummy_context_enabled(dir)) && S_ISDIR(mode)))) {
 		err = llcrypt_get_encryption_info(dir);
 		if (err)
 			goto err_exit;
@@ -1292,7 +1362,13 @@ static int ll_new_node(struct inode *dir, struct dentry *dentry,
 			err = -ENOKEY;
 			goto err_exit;
 		}
-		encrypt = 1;
+		encrypt = true;
+	}
+
+	if (encrypt) {
+		err = llcrypt_inherit_context(dir, NULL, op_data, false);
+		if (err)
+			goto err_exit;
 	}
 
 	err = md_create(sbi->ll_md_exp, op_data, tgt, tgt_len, mode,
diff --git a/fs/lustre/llite/xattr_cache.c b/fs/lustre/llite/xattr_cache.c
index c642444..fee1cf5 100644
--- a/fs/lustre/llite/xattr_cache.c
+++ b/fs/lustre/llite/xattr_cache.c
@@ -502,3 +502,37 @@ int ll_xattr_cache_get(struct inode *inode, const char *name, char *buffer,
 
 	return rc;
 }
+
+/**
+ * Insert an xattr value into the cache.
+ *
+ * Add @name xattr with @buffer value and @size length for @inode.
+ * Init cache for @inode if necessary.
+ *
+ * Return:	0 success
+ *		< 0 from ll_xattr_cache_add(), except -EPROTO is ignored for
+ *		LL_XATTR_NAME_ENCRYPTION_CONTEXT xattr
+ */
+int ll_xattr_cache_insert(struct inode *inode,
+			  const char *name,
+			  char *buffer,
+			  size_t size)
+{
+	struct ll_inode_info *lli = ll_i2info(inode);
+	int rc;
+
+	down_read(&lli->lli_xattrs_list_rwsem);
+	if (!ll_xattr_cache_valid(lli))
+		ll_xattr_cache_init(lli);
+	rc = ll_xattr_cache_add(&lli->lli_xattrs, name, buffer,
+				size);
+	up_read(&lli->lli_xattrs_list_rwsem);
+
+	if (rc == -EPROTO &&
+	    strcmp(name, LL_XATTR_NAME_ENCRYPTION_CONTEXT) == 0)
+		/* it means enc ctx was already in cache,
+		 * ignore error as it cannot be modified
+		 */
+		rc = 0;
+	return rc;
+}
diff --git a/fs/lustre/mdc/mdc_internal.h b/fs/lustre/mdc/mdc_internal.h
index a1fb5d9..065cba5 100644
--- a/fs/lustre/mdc/mdc_internal.h
+++ b/fs/lustre/mdc/mdc_internal.h
@@ -57,6 +57,8 @@ void mdc_open_pack(struct ptlrpc_request *req, struct md_op_data *op_data,
 void mdc_file_secctx_pack(struct ptlrpc_request *req,
 			  const char *secctx_name,
 			  const void *secctx, size_t secctx_size);
+void mdc_file_encctx_pack(struct ptlrpc_request *req,
+			  const void *encctx, size_t encctx_size);
 void mdc_file_sepol_pack(struct ptlrpc_request *req);
 
 void mdc_unlink_pack(struct ptlrpc_request *req, struct md_op_data *op_data);
diff --git a/fs/lustre/mdc/mdc_lib.c b/fs/lustre/mdc/mdc_lib.c
index be77944b..6cb14c1 100644
--- a/fs/lustre/mdc/mdc_lib.c
+++ b/fs/lustre/mdc/mdc_lib.c
@@ -138,6 +138,23 @@ void mdc_file_secctx_pack(struct ptlrpc_request *req, const char *secctx_name,
 	memcpy(buf, secctx, buf_size);
 }
 
+void mdc_file_encctx_pack(struct ptlrpc_request *req,
+			  const void *encctx, size_t encctx_size)
+{
+	void *buf;
+	size_t buf_size;
+
+	if (!encctx)
+		return;
+
+	buf = req_capsule_client_get(&req->rq_pill, &RMF_FILE_ENCCTX);
+	buf_size = req_capsule_get_size(&req->rq_pill, &RMF_FILE_ENCCTX,
+					RCL_CLIENT);
+
+	LASSERT(buf_size == encctx_size);
+	memcpy(buf, encctx, buf_size);
+}
+
 void mdc_file_sepol_pack(struct ptlrpc_request *req)
 {
 	void *buf;
@@ -209,6 +226,9 @@ void mdc_create_pack(struct ptlrpc_request *req, struct md_op_data *op_data,
 			     op_data->op_file_secctx,
 			     op_data->op_file_secctx_size);
 
+	mdc_file_encctx_pack(req, op_data->op_file_encctx,
+			     op_data->op_file_encctx_size);
+
 	/* pack SELinux policy info if any */
 	mdc_file_sepol_pack(req);
 }
@@ -286,6 +306,9 @@ void mdc_open_pack(struct ptlrpc_request *req, struct md_op_data *op_data,
 				     op_data->op_file_secctx,
 				     op_data->op_file_secctx_size);
 
+		mdc_file_encctx_pack(req, op_data->op_file_encctx,
+				     op_data->op_file_encctx_size);
+
 		/* pack SELinux policy info if any */
 		mdc_file_sepol_pack(req);
 	}
diff --git a/fs/lustre/mdc/mdc_locks.c b/fs/lustre/mdc/mdc_locks.c
index 402e6e0..ea78415 100644
--- a/fs/lustre/mdc/mdc_locks.c
+++ b/fs/lustre/mdc/mdc_locks.c
@@ -324,6 +324,9 @@ static int mdc_save_lovea(struct ptlrpc_request *req,
 	req_capsule_set_size(&req->rq_pill, &RMF_FILE_SECCTX, RCL_CLIENT,
 			     op_data->op_file_secctx_size);
 
+	req_capsule_set_size(&req->rq_pill, &RMF_FILE_ENCCTX, RCL_CLIENT,
+			     op_data->op_file_encctx_size);
+
 	/* get SELinux policy info if any */
 	rc = sptlrpc_get_sepol(req);
 	if (rc < 0) {
@@ -380,6 +383,15 @@ static int mdc_save_lovea(struct ptlrpc_request *req,
 				     RCL_SERVER, 0);
 	}
 
+	if (exp_connect_encrypt(exp) && !(it->it_op & IT_CREAT) &&
+	    it->it_op & IT_OPEN)
+		req_capsule_set_size(&req->rq_pill, &RMF_FILE_ENCCTX,
+				     RCL_SERVER,
+				     obd->u.cli.cl_max_mds_easize);
+	else
+		req_capsule_set_size(&req->rq_pill, &RMF_FILE_ENCCTX,
+				     RCL_SERVER, 0);
+
 	/**
 	 * Inline buffer for possible data from Data-on-MDT files.
 	 */
@@ -459,6 +471,9 @@ static int mdc_save_lovea(struct ptlrpc_request *req,
 	/* pack the intent */
 	lit = req_capsule_client_get(&req->rq_pill, &RMF_LDLM_INTENT);
 	lit->opc = IT_GETXATTR;
+	/* Message below is checked in sanity-selinux test_20d
+	 * and sanity-sec test_49
+	 */
 	CDEBUG(D_INFO, "%s: get xattrs for " DFID "\n",
 	       exp->exp_obd->obd_name, PFID(&op_data->op_fid1));
 
@@ -571,6 +586,13 @@ static int mdc_save_lovea(struct ptlrpc_request *req,
 				     RCL_SERVER, 0);
 	}
 
+	if (exp_connect_encrypt(exp) && it->it_op & (IT_LOOKUP | IT_GETATTR))
+		req_capsule_set_size(&req->rq_pill, &RMF_FILE_ENCCTX,
+				     RCL_SERVER, easize);
+	else
+		req_capsule_set_size(&req->rq_pill, &RMF_FILE_ENCCTX,
+				     RCL_SERVER, 0);
+
 	ptlrpc_request_set_replen(req);
 	return req;
 }
diff --git a/fs/lustre/mdc/mdc_reint.c b/fs/lustre/mdc/mdc_reint.c
index cc09374..9e566e7 100644
--- a/fs/lustre/mdc/mdc_reint.c
+++ b/fs/lustre/mdc/mdc_reint.c
@@ -205,6 +205,9 @@ int mdc_create(struct obd_export *exp, struct md_op_data *op_data,
 	req_capsule_set_size(&req->rq_pill, &RMF_FILE_SECCTX, RCL_CLIENT,
 			     op_data->op_file_secctx_size);
 
+	req_capsule_set_size(&req->rq_pill, &RMF_FILE_ENCCTX, RCL_CLIENT,
+			     op_data->op_file_encctx_size);
+
 	/* get SELinux policy info if any */
 	rc = sptlrpc_get_sepol(req);
 	if (rc < 0) {
diff --git a/fs/lustre/mdc/mdc_request.c b/fs/lustre/mdc/mdc_request.c
index f2bca8e..40670cb 100644
--- a/fs/lustre/mdc/mdc_request.c
+++ b/fs/lustre/mdc/mdc_request.c
@@ -452,7 +452,9 @@ static int mdc_getxattr(struct obd_export *exp, const struct lu_fid *fid,
 	LASSERT(obd_md_valid == OBD_MD_FLXATTR ||
 		obd_md_valid == OBD_MD_FLXATTRLS);
 
-	/* The below message is checked in sanity-selinux.sh test_20d */
+	/* Message below is checked in sanity-selinux test_20d
+	 * and sanity-sec test_49
+	 */
 	CDEBUG(D_INFO, "%s: get xattr '%s' for " DFID "\n",
 	       exp->exp_obd->obd_name, name, PFID(fid));
 	rc = mdc_xattr_common(exp, &RQF_MDS_GETXATTR, fid, MDS_GETXATTR,
diff --git a/fs/lustre/ptlrpc/layout.c b/fs/lustre/ptlrpc/layout.c
index 1286547..4e37bbb 100644
--- a/fs/lustre/ptlrpc/layout.c
+++ b/fs/lustre/ptlrpc/layout.c
@@ -189,7 +189,8 @@
 	&RMF_DLM_REQ,
 	&RMF_FILE_SECCTX_NAME,
 	&RMF_FILE_SECCTX,
-	&RMF_SELINUX_POL
+	&RMF_SELINUX_POL,
+	&RMF_FILE_ENCCTX,
 };
 
 static const struct req_msg_field *mds_reint_create_sym_client[] = {
@@ -201,7 +202,8 @@
 	&RMF_DLM_REQ,
 	&RMF_FILE_SECCTX_NAME,
 	&RMF_FILE_SECCTX,
-	&RMF_SELINUX_POL
+	&RMF_SELINUX_POL,
+	&RMF_FILE_ENCCTX,
 };
 
 static const struct req_msg_field *mds_reint_open_client[] = {
@@ -213,7 +215,8 @@
 	&RMF_EADATA,
 	&RMF_FILE_SECCTX_NAME,
 	&RMF_FILE_SECCTX,
-	&RMF_SELINUX_POL
+	&RMF_SELINUX_POL,
+	&RMF_FILE_ENCCTX,
 };
 
 static const struct req_msg_field *mds_reint_open_server[] = {
@@ -443,7 +446,8 @@
 	&RMF_CAPA1,
 	&RMF_CAPA2,
 	&RMF_NIOBUF_INLINE,
-	&RMF_FILE_SECCTX
+	&RMF_FILE_SECCTX,
+	&RMF_FILE_ENCCTX,
 };
 
 static const struct req_msg_field *ldlm_intent_getattr_client[] = {
@@ -464,7 +468,8 @@
 	&RMF_ACL,
 	&RMF_CAPA1,
 	&RMF_FILE_SECCTX,
-	&RMF_DEFAULT_MDT_MD
+	&RMF_DEFAULT_MDT_MD,
+	&RMF_FILE_ENCCTX,
 };
 
 static const struct req_msg_field *ldlm_intent_create_client[] = {
@@ -477,7 +482,8 @@
 	&RMF_EADATA,
 	&RMF_FILE_SECCTX_NAME,
 	&RMF_FILE_SECCTX,
-	&RMF_SELINUX_POL
+	&RMF_SELINUX_POL,
+	&RMF_FILE_ENCCTX,
 };
 
 static const struct req_msg_field *ldlm_intent_open_client[] = {
@@ -491,7 +497,8 @@
 	&RMF_EADATA,
 	&RMF_FILE_SECCTX_NAME,
 	&RMF_FILE_SECCTX,
-	&RMF_SELINUX_POL
+	&RMF_SELINUX_POL,
+	&RMF_FILE_ENCCTX,
 };
 
 static const struct req_msg_field *ldlm_intent_getxattr_client[] = {
@@ -987,6 +994,10 @@ struct req_msg_field RMF_FILE_SECCTX =
 	DEFINE_MSGF("file_secctx", RMF_F_NO_SIZE_CHECK, -1, NULL, NULL);
 EXPORT_SYMBOL(RMF_FILE_SECCTX);
 
+struct req_msg_field RMF_FILE_ENCCTX =
+	DEFINE_MSGF("file_encctx", RMF_F_NO_SIZE_CHECK, -1, NULL, NULL);
+EXPORT_SYMBOL(RMF_FILE_ENCCTX);
+
 struct req_msg_field RMF_LLOGD_BODY =
 	DEFINE_MSGF("llogd_body", 0,
 		    sizeof(struct llogd_body), lustre_swab_llogd_body, NULL);
diff --git a/fs/lustre/ptlrpc/wiretest.c b/fs/lustre/ptlrpc/wiretest.c
index 74a4e940..d1dff09 100644
--- a/fs/lustre/ptlrpc/wiretest.c
+++ b/fs/lustre/ptlrpc/wiretest.c
@@ -1497,6 +1497,8 @@ void lustre_assert_wire_constants(void)
 		 OBD_MD_FLLAZYSIZE);
 	LASSERTF(OBD_MD_FLLAZYBLOCKS == (0x0800000000000000ULL), "found 0x%.16llxULL\n",
 		 OBD_MD_FLLAZYBLOCKS);
+	LASSERTF(OBD_MD_ENCCTX == (0x2000000000000000ULL), "found 0x%.16llxULL\n",
+		 OBD_MD_ENCCTX);
 	BUILD_BUG_ON(OBD_FL_INLINEDATA != 0x00000001);
 	BUILD_BUG_ON(OBD_FL_OBDMDEXISTS != 0x00000002);
 	BUILD_BUG_ON(OBD_FL_DELORPHAN != 0x00000004);
diff --git a/include/uapi/linux/lustre/lustre_idl.h b/include/uapi/linux/lustre/lustre_idl.h
index d4df989..fdeb2a3 100644
--- a/include/uapi/linux/lustre/lustre_idl.h
+++ b/include/uapi/linux/lustre/lustre_idl.h
@@ -1229,11 +1229,10 @@ static inline __u32 lov_mds_md_size(__u16 stripes, __u32 lmm_magic)
 #define OBD_MD_FLOSTLAYOUT	(0x0080000000000000ULL)	/* contain ost_layout */
 #define OBD_MD_FLPROJID		(0x0100000000000000ULL) /* project ID */
 #define OBD_MD_SECCTX        (0x0200000000000000ULL) /* embed security xattr */
-
 #define OBD_MD_FLLAZYSIZE    (0x0400000000000000ULL) /* Lazy size */
 #define OBD_MD_FLLAZYBLOCKS  (0x0800000000000000ULL) /* Lazy blocks */
-
 #define OBD_MD_FLBTIME		(0x1000000000000000ULL) /* birth time */
+#define OBD_MD_ENCCTX	     (0x2000000000000000ULL) /* embed encryption ctx */
 
 #define OBD_MD_FLALLQUOTA (OBD_MD_FLUSRQUOTA | \
 			   OBD_MD_FLGRPQUOTA | \
-- 
1.8.3.1
