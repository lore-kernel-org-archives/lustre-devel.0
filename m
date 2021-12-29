Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 252A1C433F5
	for <lustre-devel@archiver.kernel.org>; Wed, 29 Dec 2021 14:51:42 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 584753AD53B;
	Wed, 29 Dec 2021 06:51:39 -0800 (PST)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 44E853AD371
 for <lustre-devel@lists.lustre.org>; Wed, 29 Dec 2021 06:51:30 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 7FD9E1006F02;
 Wed, 29 Dec 2021 09:51:28 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 75E61D9E6D; Wed, 29 Dec 2021 09:51:28 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Wed, 29 Dec 2021 09:51:15 -0500
Message-Id: <1640789487-22279-2-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1640789487-22279-1-git-send-email-jsimmons@infradead.org>
References: <1640789487-22279-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 01/13] lustre: sec: filename encryption -
 digest support
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

A number of operations are allowed on encrypted files without the key:
- read file metadata (stat);
- list directories;
- remove files and directories.
In order to present valid names to users, cipher text names are base64
encoded if they are short. Otherwise we compute a digested form of the
cipher text, made of the FID (16 bytes) followed by the second-to-last
cipher block (16 bytes), and we base64 encode this digested form for
presentation to user.
These transformations are carried out in the specific overlay
functions, that now need to know the fid of the file.

As the digested form does not contain the whole cipher text name,
server side needs to proceed to an operation by FID for requests such
as lookup and getattr. It also relies on the content of the LinkEA to
verify the digested form as received from client side.

WC-bug-id: https://jira.whamcloud.com/browse/LU-13717
Lustre-commit: ed4a625d88567a249 ("LU-13717 sec: filename encryption - digest support")
Signed-off-by: Sebastien Buisson <sbuisson@ddn.com>
Reviewed-on: https://review.whamcloud.com/43392
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Patrick Farrell <pfarrell@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/crypto.c                | 130 +++++++++++++++++++++++++++-----
 fs/lustre/llite/dir.c                   |   2 +-
 fs/lustre/llite/llite_internal.h        |  15 +++-
 fs/lustre/llite/llite_lib.c             |  11 ++-
 fs/lustre/llite/namei.c                 |  19 +++--
 fs/lustre/llite/statahead.c             |   8 +-
 fs/lustre/mdc/mdc_lib.c                 |   2 +
 fs/lustre/mdc/mdc_locks.c               |   4 +-
 fs/lustre/mdc/mdc_request.c             |   9 +++
 include/uapi/linux/lustre/lustre_idl.h  |  14 ++--
 include/uapi/linux/lustre/lustre_user.h |   3 +-
 11 files changed, 180 insertions(+), 37 deletions(-)

diff --git a/fs/lustre/llite/crypto.c b/fs/lustre/llite/crypto.c
index 0388e360..7bc6e01 100644
--- a/fs/lustre/llite/crypto.c
+++ b/fs/lustre/llite/crypto.c
@@ -178,19 +178,70 @@ static bool ll_empty_dir(struct inode *inode)
  *	->lookup() or we're finding the dir_entry for deletion; 0 if we cannot
  *	proceed without the key because we're going to create the dir_entry.
  * @fname: the filename information to be filled in
+ * @fid: fid retrieved from user-provided filename
  *
  * This overlay function is necessary to properly encode @fname after
  * encryption, as it will be sent over the wire.
+ * This overlay function is also necessary to handle the case of operations
+ * carried out without the key. Normally llcrypt makes use of digested names in
+ * that case. Having a digested name works for local file systems that can call
+ * llcrypt_match_name(), but Lustre server side is not aware of encryption.
+ * So for keyless @lookup operations on long names, for Lustre we choose to
+ * present to users the encoded struct ll_digest_filename, instead of a digested
+ * name. FID and name hash can then easily be extracted and put into the
+ * requests sent to servers.
  */
 int ll_setup_filename(struct inode *dir, const struct qstr *iname,
-		      int lookup, struct fscrypt_name *fname)
+		      int lookup, struct fscrypt_name *fname,
+		      struct lu_fid *fid)
 {
+	int digested = 0;
+	struct qstr dname;
 	int rc;
 
-	rc = fscrypt_setup_filename(dir, iname, lookup, fname);
+	if (fid) {
+		fid->f_seq = 0;
+		fid->f_oid = 0;
+		fid->f_ver = 0;
+	}
+
+	if (fid && IS_ENCRYPTED(dir) && !fscrypt_has_encryption_key(dir) &&
+	    iname->name[0] == '_')
+		digested = 1;
+
+	dname.name = iname->name + digested;
+	dname.len = iname->len - digested;
+
+	if (fid) {
+		fid->f_seq = 0;
+		fid->f_oid = 0;
+		fid->f_ver = 0;
+	}
+	rc = fscrypt_setup_filename(dir, &dname, lookup, fname);
 	if (rc)
 		return rc;
 
+	if (digested) {
+		/* Without the key, for long names user should have struct
+		 * ll_digest_filename representation of the dentry instead of
+		 * the name. So make sure it is valid, return fid and put
+		 * excerpt of cipher text name in disk_name.
+		 */
+		struct ll_digest_filename *digest;
+
+		if (fname->crypto_buf.len < sizeof(struct ll_digest_filename)) {
+			rc = -EINVAL;
+			goto out_free;
+		}
+		digest = (struct ll_digest_filename *)fname->crypto_buf.name;
+		*fid = digest->ldf_fid;
+		if (!fid_is_sane(fid)) {
+			rc = -EINVAL;
+			goto out_free;
+		}
+		fname->disk_name.name = digest->ldf_excerpt;
+		fname->disk_name.len = LLCRYPT_FNAME_DIGEST_SIZE;
+	}
 	if (IS_ENCRYPTED(dir) &&
 	    !name_is_dot_or_dotdot(fname->disk_name.name,
 				   fname->disk_name.len)) {
@@ -224,6 +275,11 @@ int ll_setup_filename(struct inode *dir, const struct qstr *iname,
 	return rc;
 }
 
+#define LLCRYPT_FNAME_DIGEST(name, len) \
+	((name) + round_down((len) - FS_CRYPTO_BLOCK_SIZE - 1, \
+			     FS_CRYPTO_BLOCK_SIZE))
+#define LLCRYPT_FNAME_MAX_UNDIGESTED_SIZE	32
+
 /**
  * ll_fname_disk_to_usr() - overlay to fscrypt_fname_disk_to_usr
  * @inode: the inode to convert name
@@ -231,40 +287,76 @@ int ll_setup_filename(struct inode *dir, const struct qstr *iname,
  * @minor_hash: minor hash for inode
  * @iname: the user-provided filename needing conversion
  * @oname: the filename information to be filled in
+ * @fid: the user-provided fid for filename
  *
  * The caller must have allocated sufficient memory for the @oname string.
  *
  * This overlay function is necessary to properly decode @iname before
  * decryption, as it comes from the wire.
+ * This overlay function is also necessary to handle the case of operations
+ * carried out without the key. Normally llcrypt makes use of digested names in
+ * that case. Having a digested name works for local file systems that can call
+ * llcrypt_match_name(), but Lustre server side is not aware of encryption.
+ * So for keyless @lookup operations on long names, for Lustre we choose to
+ * present to users the encoded struct ll_digest_filename, instead of a digested
+ * name. FID and name hash can then easily be extracted and put into the
+ * requests sent to servers.
  */
 int ll_fname_disk_to_usr(struct inode *inode,
 			 u32 hash, u32 minor_hash,
-			 struct fscrypt_str *iname, struct fscrypt_str *oname)
+			 struct fscrypt_str *iname, struct fscrypt_str *oname,
+			 struct lu_fid *fid)
 {
 	struct fscrypt_str lltr = FSTR_INIT(iname->name, iname->len);
+	struct ll_digest_filename digest;
+	int digested = 0;
 	char *buf = NULL;
 	int rc;
 
-	if (IS_ENCRYPTED(inode) &&
-	    !name_is_dot_or_dotdot(lltr.name, lltr.len) &&
-	    strnchr(lltr.name, lltr.len, '=')) {
-		/* Only proceed to critical decode if
-		 * iname contains espace char '='.
-		 */
-		int len = lltr.len;
-
-		buf = kmalloc(len, GFP_NOFS);
-		if (!buf)
-			return -ENOMEM;
-
-		len = critical_decode(lltr.name, len, buf);
-		lltr.name = buf;
-		lltr.len = len;
+	if (IS_ENCRYPTED(inode)) {
+		if (!name_is_dot_or_dotdot(lltr.name, lltr.len) &&
+		    strnchr(lltr.name, lltr.len, '=')) {
+			/* Only proceed to critical decode if
+			 * iname contains espace char '='.
+			 */
+			int len = lltr.len;
+
+			buf = kmalloc(len, GFP_NOFS);
+			if (!buf)
+				return -ENOMEM;
+
+			len = critical_decode(lltr.name, len, buf);
+			lltr.name = buf;
+			lltr.len = len;
+		}
+		if (lltr.len > LLCRYPT_FNAME_MAX_UNDIGESTED_SIZE &&
+		    !fscrypt_has_encryption_key(inode)) {
+			digested = 1;
+			/* Without the key for long names, set the dentry name
+			 * to the representing struct ll_digest_filename. It
+			 * will be encoded by llcrypt for display, and will
+			 * enable further lookup requests.
+			 */
+			if (!fid)
+				return -EINVAL;
+			digest.ldf_fid = *fid;
+			memcpy(digest.ldf_excerpt,
+			       LLCRYPT_FNAME_DIGEST(lltr.name, lltr.len),
+			       LLCRYPT_FNAME_DIGEST_SIZE);
+
+			lltr.name = (char *)&digest;
+			lltr.len = sizeof(digest);
+
+			oname->name[0] = '_';
+			oname->name = oname->name + 1;
+			oname->len--;
+		}
 	}
-
 	rc = fscrypt_fname_disk_to_usr(inode, hash, minor_hash, &lltr, oname);
 
 	kfree(buf);
+	oname->name = oname->name - digested;
+	oname->len = oname->len + digested;
 
 	return rc;
 }
diff --git a/fs/lustre/llite/dir.c b/fs/lustre/llite/dir.c
index ee49c90..23d3fba 100644
--- a/fs/lustre/llite/dir.c
+++ b/fs/lustre/llite/dir.c
@@ -250,7 +250,7 @@ int ll_dir_read(struct inode *inode, u64 *ppos, struct md_op_data *op_data,
 					= FSTR_INIT(ent->lde_name, namelen);
 
 				rc = ll_fname_disk_to_usr(inode, 0, 0, &de_name,
-							  &lltr);
+							  &lltr, &fid);
 				de_name = lltr;
 				lltr.len = save_len;
 				if (rc) {
diff --git a/fs/lustre/llite/llite_internal.h b/fs/lustre/llite/llite_internal.h
index 01672b8..6e212c9 100644
--- a/fs/lustre/llite/llite_internal.h
+++ b/fs/lustre/llite/llite_internal.h
@@ -1705,11 +1705,22 @@ static inline struct pcc_super *ll_info2pccs(struct ll_inode_info *lli)
 
 /* crypto.c */
 #ifdef CONFIG_FS_ENCRYPTION
+/* The digested form is made of a FID (16 bytes) followed by the second-to-last
+ * ciphertext block (16 bytes), so a total length of 32 bytes.
+ * That way, llcrypt does not compute a digested form of this digest.
+ */
+struct ll_digest_filename {
+	struct lu_fid ldf_fid;
+	char ldf_excerpt[LLCRYPT_FNAME_DIGEST_SIZE];
+};
+
 int ll_setup_filename(struct inode *dir, const struct qstr *iname,
-		      int lookup, struct fscrypt_name *fname);
+		      int lookup, struct fscrypt_name *fname,
+		      struct lu_fid *fid);
 int ll_fname_disk_to_usr(struct inode *inode,
 			 u32 hash, u32 minor_hash,
-			 struct fscrypt_str *iname, struct fscrypt_str *oname);
+			 struct fscrypt_str *iname, struct fscrypt_str *oname,
+			 struct lu_fid *fid);
 int ll_revalidate_d_crypto(struct dentry *dentry, unsigned int flags);
 #else
 int ll_setup_filename(struct inode *dir, const struct qstr *iname,
diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index dddbe7a..7f168a2 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -3067,6 +3067,8 @@ struct md_op_data *ll_prep_md_op_data(struct md_op_data *op_data,
 	} else if (name && namelen) {
 		struct qstr dname = QSTR_INIT(name, namelen);
 		struct inode *dir;
+		struct lu_fid *pfid = NULL;
+		struct lu_fid fid;
 		int lookup;
 
 		if (!S_ISDIR(i1->i_mode) && i2 && S_ISDIR(i2->i_mode)) {
@@ -3077,11 +3079,18 @@ struct md_op_data *ll_prep_md_op_data(struct md_op_data *op_data,
 			dir = i1;
 			lookup = (int)(opc == LUSTRE_OPC_ANY);
 		}
-		rc = ll_setup_filename(dir, &dname, lookup, &fname);
+		if (opc == LUSTRE_OPC_ANY && lookup)
+			pfid = &fid;
+		rc = ll_setup_filename(dir, &dname, lookup, &fname, pfid);
 		if (rc) {
 			ll_finish_md_op_data(op_data);
 			return ERR_PTR(rc);
 		}
+		if (pfid && !fid_is_zero(pfid)) {
+			if (i2 == NULL)
+				op_data->op_fid2 = fid;
+			op_data->op_bias = MDS_FID_OP;
+		}
 		if (fname.disk_name.name &&
 		    fname.disk_name.name != (unsigned char *)name)
 			/* op_data->op_name must be freed after use */
diff --git a/fs/lustre/llite/namei.c b/fs/lustre/llite/namei.c
index a0192da..5fff54d 100644
--- a/fs/lustre/llite/namei.c
+++ b/fs/lustre/llite/namei.c
@@ -814,6 +814,7 @@ static struct dentry *ll_lookup_it(struct inode *parent, struct dentry *dentry,
 	char secctx_name[XATTR_NAME_MAX + 1];
 	struct fscrypt_name fname;
 	struct inode *inode;
+	struct lu_fid fid;
 	u32 opc;
 	int rc;
 
@@ -856,7 +857,7 @@ static struct dentry *ll_lookup_it(struct inode *parent, struct dentry *dentry,
 	 * not exported function) and call it from ll_revalidate_dentry(), to
 	 * ensure we do not cache stale dentries after a key has been added.
 	 */
-	rc = ll_setup_filename(parent, &dentry->d_name, 1, &fname);
+	rc = ll_setup_filename(parent, &dentry->d_name, 1, &fname, &fid);
 	if ((!rc || rc == -ENOENT) && fname.is_ciphertext_name) {
 		spin_lock(&dentry->d_lock);
 		dentry->d_flags |= DCACHE_ENCRYPTED_NAME;
@@ -874,6 +875,12 @@ static struct dentry *ll_lookup_it(struct inode *parent, struct dentry *dentry,
 		return ERR_CAST(op_data);
 		goto out;
 	}
+	if (!fid_is_zero(&fid)) {
+		op_data->op_fid2 = fid;
+		op_data->op_bias = MDS_FID_OP;
+		if (it->it_op & IT_OPEN)
+			it->it_flags |= MDS_OPEN_BY_FID;
+	}
 
 	/* enforce umask if acl disabled or MDS doesn't support umask */
 	if (!IS_POSIXACL(parent) || !exp_connect_umask(ll_i2mdexp(parent)))
@@ -1856,7 +1863,8 @@ static int ll_unlink(struct inode *dir, struct dentry *dchild)
 	    ll_i2info(dchild->d_inode)->lli_clob &&
 	    dirty_cnt(dchild->d_inode))
 		op_data->op_cli_flags |= CLI_DIRTY_DATA;
-	op_data->op_fid2 = op_data->op_fid3;
+	if (fid_is_zero(&op_data->op_fid2))
+		op_data->op_fid2 = op_data->op_fid3;
 	rc = md_unlink(ll_i2sbi(dir)->ll_md_exp, op_data, &request);
 	ll_finish_md_op_data(op_data);
 	if (rc)
@@ -1926,7 +1934,8 @@ static int ll_rmdir(struct inode *dir, struct dentry *dchild)
 	if (dchild->d_inode)
 		op_data->op_fid3 = *ll_inode2fid(dchild->d_inode);
 
-	op_data->op_fid2 = op_data->op_fid3;
+	if (fid_is_zero(&op_data->op_fid2))
+		op_data->op_fid2 = op_data->op_fid3;
 	rc = md_unlink(ll_i2sbi(dir)->ll_md_exp, op_data, &request);
 	ll_finish_md_op_data(op_data);
 	if (rc == 0) {
@@ -2068,10 +2077,10 @@ static int ll_rename(struct inode *src, struct dentry *src_dchild,
 	if (tgt_dchild->d_inode)
 		op_data->op_fid4 = *ll_inode2fid(tgt_dchild->d_inode);
 
-	err = ll_setup_filename(src, &src_dchild->d_name, 1, &foldname);
+	err = ll_setup_filename(src, &src_dchild->d_name, 1, &foldname, NULL);
 	if (err)
 		return err;
-	err = ll_setup_filename(tgt, &tgt_dchild->d_name, 1, &fnewname);
+	err = ll_setup_filename(tgt, &tgt_dchild->d_name, 1, &fnewname, NULL);
 	if (err) {
 		fscrypt_free_filename(&foldname);
 		return err;
diff --git a/fs/lustre/llite/statahead.c b/fs/lustre/llite/statahead.c
index 39ffb9d..afb668e 100644
--- a/fs/lustre/llite/statahead.c
+++ b/fs/lustre/llite/statahead.c
@@ -1141,14 +1141,16 @@ static int ll_statahead_thread(void *arg)
 			if (IS_ENCRYPTED(dir)) {
 				struct fscrypt_str de_name =
 					FSTR_INIT(ent->lde_name, namelen);
+				struct lu_fid fid;
 
 				rc = fscrypt_fname_alloc_buffer(dir, NAME_MAX,
 								&lltr);
 				if (rc < 0)
 					continue;
 
+				fid_le_to_cpu(&fid, &ent->lde_fid);
 				if (ll_fname_disk_to_usr(dir, 0, 0, &de_name,
-							 &lltr)) {
+							 &lltr, &fid)) {
 					fscrypt_fname_free_buffer(&lltr);
 					continue;
 				}
@@ -1391,9 +1393,11 @@ static int is_first_dirent(struct inode *dir, struct dentry *dentry)
 			if (IS_ENCRYPTED(dir)) {
 				struct fscrypt_str de_name =
 					FSTR_INIT(ent->lde_name, namelen);
+				struct lu_fid fid;
 
+				fid_le_to_cpu(&fid, &ent->lde_fid);
 				if (ll_fname_disk_to_usr(dir, 0, 0, &de_name,
-							  &lltr))
+							 &lltr, &fid))
 					continue;
 				name = lltr.name;
 				namelen = lltr.len;
diff --git a/fs/lustre/mdc/mdc_lib.c b/fs/lustre/mdc/mdc_lib.c
index d07ef81..51080a1 100644
--- a/fs/lustre/mdc/mdc_lib.c
+++ b/fs/lustre/mdc/mdc_lib.c
@@ -621,6 +621,8 @@ void mdc_getattr_pack(struct req_capsule *pill, u64 valid, u32 flags,
 	b->mbo_valid = valid;
 	if (op_data->op_bias & MDS_CROSS_REF)
 		b->mbo_valid |= OBD_MD_FLCROSSREF;
+	if (op_data->op_bias & MDS_FID_OP)
+		b->mbo_valid |= OBD_MD_NAMEHASH;
 	b->mbo_eadatasize = ea_size;
 	b->mbo_flags = flags;
 	__mdc_pack_body(b, op_data->op_suppgids[0]);
diff --git a/fs/lustre/mdc/mdc_locks.c b/fs/lustre/mdc/mdc_locks.c
index 2c344d7..aba94d1 100644
--- a/fs/lustre/mdc/mdc_locks.c
+++ b/fs/lustre/mdc/mdc_locks.c
@@ -1320,8 +1320,10 @@ int mdc_intent_lock(struct obd_export *exp, struct md_op_data *op_data,
 		it->it_flags);
 
 	lockh.cookie = 0;
+	/* MDS_FID_OP is not a revalidate case */
 	if (fid_is_sane(&op_data->op_fid2) &&
-	    (it->it_op & (IT_LOOKUP | IT_GETATTR | IT_READDIR))) {
+	    (it->it_op & (IT_LOOKUP | IT_GETATTR | IT_READDIR)) &&
+	    !(op_data->op_bias & MDS_FID_OP)) {
 		/* We could just return 1 immediately, but since we should only
 		 * be called in revalidate_it if we already have a lock, let's
 		 * verify that.
diff --git a/fs/lustre/mdc/mdc_request.c b/fs/lustre/mdc/mdc_request.c
index 626f493..818c542 100644
--- a/fs/lustre/mdc/mdc_request.c
+++ b/fs/lustre/mdc/mdc_request.c
@@ -287,6 +287,15 @@ static int mdc_getattr_name(struct obd_export *exp, struct md_op_data *op_data,
 			     op_data->op_mode);
 	req_capsule_set_size(&req->rq_pill, &RMF_ACL, RCL_SERVER, acl_bufsize);
 	ptlrpc_request_set_replen(req);
+	if (op_data->op_bias & MDS_FID_OP) {
+		struct mdt_body *b = req_capsule_client_get(&req->rq_pill,
+							    &RMF_MDT_BODY);
+
+		if (b) {
+			b->mbo_valid |= OBD_MD_NAMEHASH;
+			b->mbo_fid2 = op_data->op_fid2;
+		}
+	}
 
 	rc = mdc_getattr_common(exp, req);
 	if (rc) {
diff --git a/include/uapi/linux/lustre/lustre_idl.h b/include/uapi/linux/lustre/lustre_idl.h
index ec25140..debd0c1 100644
--- a/include/uapi/linux/lustre/lustre_idl.h
+++ b/include/uapi/linux/lustre/lustre_idl.h
@@ -1197,11 +1197,14 @@ static inline __u32 lov_mds_md_size(__u16 stripes, __u32 lmm_magic)
 #define OBD_MD_DEFAULT_MEA	(0x0040000000000000ULL) /* default MEA */
 #define OBD_MD_FLOSTLAYOUT	(0x0080000000000000ULL)	/* contain ost_layout */
 #define OBD_MD_FLPROJID		(0x0100000000000000ULL) /* project ID */
-#define OBD_MD_SECCTX        (0x0200000000000000ULL) /* embed security xattr */
-#define OBD_MD_FLLAZYSIZE    (0x0400000000000000ULL) /* Lazy size */
-#define OBD_MD_FLLAZYBLOCKS  (0x0800000000000000ULL) /* Lazy blocks */
+#define OBD_MD_SECCTX		(0x0200000000000000ULL) /* embed security xattr */
+#define OBD_MD_FLLAZYSIZE	(0x0400000000000000ULL) /* Lazy size */
+#define OBD_MD_FLLAZYBLOCKS	(0x0800000000000000ULL) /* Lazy blocks */
 #define OBD_MD_FLBTIME		(0x1000000000000000ULL) /* birth time */
-#define OBD_MD_ENCCTX	     (0x2000000000000000ULL) /* embed encryption ctx */
+#define OBD_MD_ENCCTX		(0x2000000000000000ULL) /* embed encryption ctx */
+#define OBD_MD_NAMEHASH		(0x4000000000000000ULL)	/* use hash instead of name
+							 * in case of encryption
+							 */
 
 #define OBD_MD_FLALLQUOTA (OBD_MD_FLUSRQUOTA | \
 			   OBD_MD_FLGRPQUOTA | \
@@ -1705,7 +1708,8 @@ enum mds_op_bias {
 	MDS_PCC_ATTACH		= 1 << 19,
 	MDS_CLOSE_UPDATE_TIMES	= 1 << 20,
 	/* setstripe create only, don't restripe if target exists */
-	 MDS_SETSTRIPE_CREATE	= 1 << 21,
+	MDS_SETSTRIPE_CREATE	= 1 << 21,
+	MDS_FID_OP		= 1 << 22,
 };
 
 #define MDS_CLOSE_INTENT (MDS_HSM_RELEASE | MDS_CLOSE_LAYOUT_SWAP |         \
diff --git a/include/uapi/linux/lustre/lustre_user.h b/include/uapi/linux/lustre/lustre_user.h
index 5c4dadf..291e8e0 100644
--- a/include/uapi/linux/lustre/lustre_user.h
+++ b/include/uapi/linux/lustre/lustre_user.h
@@ -1221,12 +1221,13 @@ enum la_valid {
 #define MDS_OPEN_PCC      010000000000000ULL /* PCC: auto RW-PCC cache attach
 					      * for newly created file
 					      */
+#define MDS_OP_WITH_FID	  020000000000000ULL /* operation carried out by FID */
 
 #define MDS_OPEN_FL_INTERNAL (MDS_OPEN_HAS_EA | MDS_OPEN_HAS_OBJS |	\
 			      MDS_OPEN_OWNEROVERRIDE | MDS_OPEN_LOCK |	\
 			      MDS_OPEN_BY_FID | MDS_OPEN_LEASE |	\
 			      MDS_OPEN_RELEASE | MDS_OPEN_RESYNC |	\
-			      MDS_OPEN_PCC)
+			      MDS_OPEN_PCC | MDS_OP_WITH_FID)
 
 /********* Changelogs **********/
 /** Changelog record types */
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
