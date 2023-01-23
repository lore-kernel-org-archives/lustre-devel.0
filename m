Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id B81E3C25B50
	for <lustre-devel@archiver.kernel.org>; Mon, 23 Jan 2023 23:27:31 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4P15Ph20blz22T8;
	Mon, 23 Jan 2023 15:08:40 -0800 (PST)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4P15NR0f3Bz22Pn
 for <lustre-devel@lists.lustre.org>; Mon, 23 Jan 2023 15:07:35 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 94830B9D;
 Mon, 23 Jan 2023 18:00:58 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 91F1458987; Mon, 23 Jan 2023 18:00:58 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon, 23 Jan 2023 18:00:44 -0500
Message-Id: <1674514855-15399-32-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1674514855-15399-1-git-send-email-jsimmons@infradead.org>
References: <1674514855-15399-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 31/42] lustre: llite: replace
 selinux_is_enabled()
X-BeenThere: lustre-devel@lists.lustre.org
X-Mailman-Version: 2.1.39
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
Cc: Etienne AUJAMES <etienne.aujames@cea.fr>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Etienne AUJAMES <etienne.aujames@cea.fr>

selinux_is_enabled() was removed from kernel 5.1.
The commit 7037720 add the kernel support by assuming SELinux to be
enabled if the function selinux_is_enabled() does not exist.

This has performances impacts: getxattr RPCs was not send for
"security.selinux" if selinux was disabled. Utilities like "ls -l"
always try to get "security.selinux".
See the LU-549 for more information.

This patch uses security_inode_listsecurity() when mounting the
client to know if a LSM module (selinux) required a xattr to store
file contexts. If a xattr is returned we store it and use it for in
request security context.

For getxattr/setxattr we use the stored LSM's xattr to filter xattr
security contexts like security.selinux. If xattr does not match the
stored xattr name we returned -EOPNOTSUPP to userspace.

It adds also the s_security check for security_inode_notifysecctx() to
avoid calling this function if selinux is disabled (as in
nfs_setsecurity()).

For "Enforcing SELinux Policy Check" functionality, the selinux check
have been moved in l_getsepol: -ENODEV is returned if selinux is
disabled.

*Note:*
This patch detects that selinux is disabled without explicitly
disabled it in kernel cmdline.

*Performances:*
Tests with "strace -c ls -l" with 100000 files on root in a multi VMs
env (on Rocky 9). FS is remount for each tests (cache is cleaned) and
selinux is disabled.

 __________________ ___________ _________
| Total time %     | lgetxattr | statx   |
|__________________|___________|_________|
|Without the patch:|    29%    |   51%   |
|__________________|___________|_________|
|With the patch:   |    0%     |   87%   |
|__________________|___________|_________|
"ls -l" uses lgetxattr to get "security.selinux".

Linux-commit: 3d252529480c68bfd6a6774652df7c8968b28e41

Fixes: 7037720 ("lustre: remove use of selinux_is_enabled().")
WC-bug-id: https://jira.whamcloud.com/browse/LU-16210
Lustre-commit: 1d8faaf6caf4acaf0 ("LU-16210 llite: replace selinux_is_enabled()")
Signed-off-by: Etienne AUJAMES <etienne.aujames@cea.fr>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/48875
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Sebastien Buisson <sbuisson@ddn.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/dir.c            |  22 ++--
 fs/lustre/llite/llite_internal.h |  46 +++++++-
 fs/lustre/llite/llite_lib.c      |  11 ++
 fs/lustre/llite/namei.c          |  87 +++++---------
 fs/lustre/llite/xattr.c          |  10 +-
 fs/lustre/llite/xattr_cache.c    |   6 +-
 fs/lustre/llite/xattr_security.c | 193 ++++++++++++++++++++++++-------
 fs/lustre/ptlrpc/sec.c           |  17 +--
 8 files changed, 260 insertions(+), 132 deletions(-)

diff --git a/fs/lustre/llite/dir.c b/fs/lustre/llite/dir.c
index abbba964103f..7dca0fc461c0 100644
--- a/fs/lustre/llite/dir.c
+++ b/fs/lustre/llite/dir.c
@@ -432,6 +432,7 @@ static int ll_dir_setdirstripe(struct dentry *dparent, struct lmv_user_md *lump,
 			.hash = full_name_hash(dparent, dirname,
 					       strlen(dirname)),
 		},
+		.d_sb = dparent->d_sb,
 	};
 	bool encrypt = false;
 	int hash_flags;
@@ -511,14 +512,13 @@ static int ll_dir_setdirstripe(struct dentry *dparent, struct lmv_user_md *lump,
 	}
 
 	if (test_bit(LL_SBI_FILE_SECCTX, sbi->ll_flags)) {
-		/*
-		 * selinux_dentry_init_security() uses dentry->d_parent and name
+		/* selinux_dentry_init_security() uses dentry->d_parent and name
 		 * to determine the security context for the file. So our fake
 		 * dentry should be real enough for this purpose.
 		 */
-		err = ll_dentry_init_security(parent,
-					      &dentry, mode, &dentry.d_name,
+		err = ll_dentry_init_security(&dentry, mode, &dentry.d_name,
 					      &op_data->op_file_secctx_name,
+					      &op_data->op_file_secctx_name_size,
 					      &op_data->op_file_secctx,
 					      &op_data->op_file_secctx_size);
 		if (err < 0)
@@ -550,17 +550,11 @@ static int ll_dir_setdirstripe(struct dentry *dparent, struct lmv_user_md *lump,
 
 	dentry.d_inode = inode;
 
-	if (test_bit(LL_SBI_FILE_SECCTX, sbi->ll_flags)) {
-		/* no need to protect selinux_inode_setsecurity() by
-		 * inode_lock. Taking it would lead to a client deadlock
-		 * LU-13617
-		 */
-		err = security_inode_notifysecctx(inode,
-						  op_data->op_file_secctx,
-						  op_data->op_file_secctx_size);
-	} else {
+	if (test_bit(LL_SBI_FILE_SECCTX, sbi->ll_flags))
+		err = ll_inode_notifysecctx(inode, op_data->op_file_secctx,
+					    op_data->op_file_secctx_size);
+	else
 		err = ll_inode_init_security(&dentry, inode, parent);
-	}
 
 	if (encrypt)
 		err = ll_set_encflags(inode, op_data->op_file_encctx,
diff --git a/fs/lustre/llite/llite_internal.h b/fs/lustre/llite/llite_internal.h
index 998eed83738e..c42330e54874 100644
--- a/fs/lustre/llite/llite_internal.h
+++ b/fs/lustre/llite/llite_internal.h
@@ -447,15 +447,45 @@ static inline void obd_connect_set_secctx(struct obd_connect_data *data)
 #endif
 }
 
-int ll_dentry_init_security(struct inode *parent, struct dentry *dentry,
-			    int mode, struct qstr *name,
-			    const char **secctx_name, void **secctx,
-			    u32 *secctx_size);
+/* Only smack and selinux is known to use security contexts */
+static inline bool ll_xattr_is_seclabel(const char *name)
+{
+	return !strcmp(name, XATTR_NAME_SELINUX) ||
+		!strcmp(name, XATTR_NAME_SMACK);
+}
+
+static inline bool ll_xattr_suffix_is_seclabel(const char *suffix)
+{
+	return !strcmp(suffix, XATTR_SELINUX_SUFFIX) ||
+		!strcmp(suffix, XATTR_SMACK_SUFFIX);
+}
+
+int ll_dentry_init_security(struct dentry *dentry, int mode, struct qstr *name,
+			    const char **secctx_name, u32 *secctx_name_size,
+			    void **secctx, u32 *secctx_size);
 int ll_inode_init_security(struct dentry *dentry, struct inode *inode,
 			   struct inode *dir);
 
-int ll_listsecurity(struct inode *inode, char *secctx_name,
-		    size_t secctx_name_size);
+int ll_inode_notifysecctx(struct inode *inode,
+			  void *secctx, u32 secctxlen);
+
+void ll_secctx_name_free(struct ll_sb_info *sbi);
+
+int ll_secctx_name_store(struct inode *in);
+
+u32 ll_secctx_name_get(struct ll_sb_info *sbi, const char **secctx_name);
+
+int ll_security_secctx_name_filter(struct ll_sb_info *sbi, int xattr_type,
+				   const char *suffix);
+
+static inline bool ll_security_xattr_wanted(struct inode *in)
+{
+#ifdef CONFIG_SECURITY
+	return in->i_security && in->i_sb->s_security;
+#else
+	return false;
+#endif
+}
 
 static inline bool obd_connect_has_enc(struct obd_connect_data *data)
 {
@@ -804,6 +834,10 @@ struct ll_sb_info {
 	struct ll_foreign_symlink_upcall_item *ll_foreign_symlink_upcall_items;
 	/* foreign symlink path upcall nb infos */
 	unsigned int		ll_foreign_symlink_upcall_nb_items;
+
+	/* cached file security context xattr name. e.g: security.selinux */
+	char			*ll_secctx_name;
+	u32			ll_secctx_name_size;
 };
 
 #define SBI_DEFAULT_HEAT_DECAY_WEIGHT	((80 * 256 + 50) / 100)
diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index 176e61b5874e..4bc91dddb6a7 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -144,6 +144,9 @@ static struct ll_sb_info *ll_init_sbi(void)
 	 * not enabled by default
 	 */
 
+	sbi->ll_secctx_name = NULL;
+	sbi->ll_secctx_name_size = 0;
+
 	sbi->ll_ra_info.ra_max_pages =
 		min(pages / 32, SBI_DEFAULT_READ_AHEAD_MAX);
 	sbi->ll_ra_info.ra_max_pages_per_file =
@@ -236,6 +239,8 @@ static void ll_free_sbi(struct super_block *sb)
 		kvfree(items);
 		sbi->ll_foreign_symlink_upcall_items = NULL;
 	}
+	ll_secctx_name_free(sbi);
+
 	ll_free_rw_stats_info(sbi);
 	pcc_super_fini(&sbi->ll_pcc_super);
 	kfree(sbi);
@@ -710,6 +715,12 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt)
 		goto out_root;
 	}
 
+	err = ll_secctx_name_store(root);
+	if (err < 0 && ll_security_xattr_wanted(root))
+		CWARN("%s: file security contextes not supported: rc = %d\n",
+		      sbi->ll_fsname, err);
+
+	err = 0;
 	if (encctxlen) {
 		CDEBUG(D_SEC,
 		       "server returned encryption ctx for root inode "DFID"\n",
diff --git a/fs/lustre/llite/namei.c b/fs/lustre/llite/namei.c
index f23d3ae49fae..9314a1704146 100644
--- a/fs/lustre/llite/namei.c
+++ b/fs/lustre/llite/namei.c
@@ -712,20 +712,8 @@ static int ll_lookup_it_finish(struct ptlrpc_request *request,
 				       PFID(ll_inode2fid(inode)));
 		}
 
-		if (secctx && secctxlen != 0) {
-			/* no need to protect selinux_inode_setsecurity() by
-			 * inode_lock. Taking it would lead to a client deadlock
-			 * LU-13617
-			 */
-			rc = security_inode_notifysecctx(inode, secctx,
-							 secctxlen);
-			if (rc)
-				CWARN("%s: cannot set security context for " DFID ": rc = %d\n",
-				      ll_i2sbi(inode)->ll_fsname,
-				      PFID(ll_inode2fid(inode)),
-				      rc);
-		}
-
+		/* resume normally on error */
+		ll_inode_notifysecctx(inode, secctx, secctxlen);
 	}
 
 	alias = ll_splice_alias(inode, *de);
@@ -798,26 +786,26 @@ static int ll_lookup_it_finish(struct ptlrpc_request *request,
 }
 
 static struct dentry *ll_lookup_it(struct inode *parent, struct dentry *dentry,
-				   struct lookup_intent *it, void **secctx,
-				   u32 *secctxlen,
+				   struct lookup_intent *it,
+				   void **secctx, u32 *secctxlen,
 				   struct pcc_create_attach *pca,
 				   bool encrypt,
 				   void **encctx, u32 *encctxlen)
 {
 	ktime_t kstart = ktime_get();
 	struct lookup_intent lookup_it = { .it_op = IT_LOOKUP };
+	struct ll_sb_info *sbi = ll_i2sbi(parent);
 	struct dentry *save = dentry, *retval;
 	struct ptlrpc_request *req = NULL;
 	struct md_op_data *op_data = NULL;
 	struct lov_user_md *lum = NULL;
-	char secctx_name[XATTR_NAME_MAX + 1];
 	struct fscrypt_name fname;
 	struct inode *inode;
 	struct lu_fid fid;
 	u32 opc;
 	int rc;
 
-	if (dentry->d_name.len > ll_i2sbi(parent)->ll_namelen)
+	if (dentry->d_name.len > sbi->ll_namelen)
 		return ERR_PTR(-ENAMETOOLONG);
 
 	CDEBUG(D_VFSTRACE, "VFS Op:name=%pd, dir=" DFID "(%p),intent=%s\n",
@@ -831,13 +819,8 @@ static struct dentry *ll_lookup_it(struct inode *parent, struct dentry *dentry,
 
 	if (it->it_op == IT_GETATTR && dentry_may_statahead(parent, dentry)) {
 		rc = ll_revalidate_statahead(parent, &dentry, 0);
-		if (rc == 1) {
-			if (dentry == save)
-				retval = NULL;
-			else
-				retval = dentry;
-			goto out;
-		}
+		if (rc == 1)
+			return dentry == save ? NULL : dentry;
 	}
 
 	if (it->it_op & IT_OPEN && it->it_flags & FMODE_WRITE &&
@@ -872,7 +855,6 @@ static struct dentry *ll_lookup_it(struct inode *parent, struct dentry *dentry,
 	if (IS_ERR(op_data)) {
 		fscrypt_free_filename(&fname);
 		return ERR_CAST(op_data);
-		goto out;
 	}
 	if (!fid_is_zero(&fid)) {
 		op_data->op_fid2 = fid;
@@ -886,11 +868,11 @@ static struct dentry *ll_lookup_it(struct inode *parent, struct dentry *dentry,
 		it->it_create_mode &= ~current_umask();
 
 	if (it->it_op & IT_CREAT &&
-	    test_bit(LL_SBI_FILE_SECCTX, ll_i2sbi(parent)->ll_flags)) {
-		rc = ll_dentry_init_security(parent,
-					     dentry, it->it_create_mode,
+	    test_bit(LL_SBI_FILE_SECCTX, sbi->ll_flags)) {
+		rc = ll_dentry_init_security(dentry, it->it_create_mode,
 					     &dentry->d_name,
 					     &op_data->op_file_secctx_name,
+					     &op_data->op_file_secctx_name_size,
 					     &op_data->op_file_secctx,
 					     &op_data->op_file_secctx_size);
 		if (rc < 0) {
@@ -993,22 +975,12 @@ static struct dentry *ll_lookup_it(struct inode *parent, struct dentry *dentry,
 			*encctxlen = 0;
 	}
 
-	/* ask for security context upon intent */
-	if (it->it_op & (IT_LOOKUP | IT_GETATTR | IT_OPEN)) {
-		/* get name of security xattr to request to server */
-		rc = ll_listsecurity(parent, secctx_name,
-				     sizeof(secctx_name));
-		if (rc < 0) {
-			CDEBUG(D_SEC,
-			       "cannot get security xattr name for " DFID ": rc = %d\n",
-			       PFID(ll_inode2fid(parent)), rc);
-		} else if (rc > 0) {
-			op_data->op_file_secctx_name = secctx_name;
-			op_data->op_file_secctx_name_size = rc;
-			CDEBUG(D_SEC, "'%.*s' is security xattr for " DFID "\n",
-			       rc, secctx_name, PFID(ll_inode2fid(parent)));
-		}
-	}
+	/* ask for security context upon intent:
+	 * get name of security xattr to request to server
+	 */
+	if (it->it_op & (IT_LOOKUP | IT_GETATTR | IT_OPEN))
+		op_data->op_file_secctx_name_size =
+			ll_secctx_name_get(sbi, &op_data->op_file_secctx_name);
 
 	if (pca && pca->pca_dataset) {
 		lum = kzalloc(sizeof(*lum), GFP_NOFS);
@@ -1416,20 +1388,13 @@ static int ll_create_it(struct inode *dir, struct dentry *dentry,
 	if (IS_ERR(inode))
 		return PTR_ERR(inode);
 
-	if (test_bit(LL_SBI_FILE_SECCTX, ll_i2sbi(inode)->ll_flags) &&
-	    secctx) {
-		/* must be done before d_instantiate, because it calls
-		 * security_d_instantiate, which means a getxattr if security
-		 * context is not set yet
-		 */
-		/* no need to protect selinux_inode_setsecurity() by
-		 * inode_lock. Taking it would lead to a client deadlock
-		 * LU-13617
-		 */
-		rc = security_inode_notifysecctx(inode, secctx, secctxlen);
-		if (rc)
-			return rc;
-	}
+	/* must be done before d_instantiate, because it calls
+	 * security_d_instantiate, which means a getxattr if security
+	 * context is not set yet
+	 */
+	rc = ll_inode_notifysecctx(inode, secctx, secctxlen);
+	if (rc)
+		return rc;
 
 	d_instantiate(dentry, inode);
 
@@ -1567,9 +1532,9 @@ static int ll_new_node(struct inode *dir, struct dentry *dchild,
 		ll_qos_mkdir_prep(op_data, dir);
 
 	if (test_bit(LL_SBI_FILE_SECCTX, sbi->ll_flags)) {
-		err = ll_dentry_init_security(dir,
-					      dchild, mode, &dchild->d_name,
+		err = ll_dentry_init_security(dchild, mode, &dchild->d_name,
 					      &op_data->op_file_secctx_name,
+					      &op_data->op_file_secctx_name_size,
 					      &op_data->op_file_secctx,
 					      &op_data->op_file_secctx_size);
 		if (err < 0)
diff --git a/fs/lustre/llite/xattr.c b/fs/lustre/llite/xattr.c
index 11310f9a0a6b..c90f5017c931 100644
--- a/fs/lustre/llite/xattr.c
+++ b/fs/lustre/llite/xattr.c
@@ -123,6 +123,10 @@ static int ll_xattr_set_common(const struct xattr_handler *handler,
 	    (!strcmp(name, "ima") || !strcmp(name, "evm")))
 		return -EOPNOTSUPP;
 
+	rc = ll_security_secctx_name_filter(sbi, handler->flags, name);
+	if (rc)
+		return rc;
+
 	/*
 	 * In user.* namespace, only regular files and directories can have
 	 * extended attributes.
@@ -373,7 +377,7 @@ int ll_xattr_list(struct inode *inode, const char *name, int type, void *buffer,
 	}
 
 	if (sbi->ll_xattr_cache_enabled && type != XATTR_ACL_ACCESS_T &&
-	    (type != XATTR_SECURITY_T || strcmp(name, "security.selinux")) &&
+	    (type != XATTR_SECURITY_T || !ll_xattr_is_seclabel(name)) &&
 	    (type != XATTR_TRUSTED_T || strcmp(name, XATTR_NAME_SOM))) {
 		rc = ll_xattr_cache_get(inode, name, buffer, size, valid);
 		if (rc == -EAGAIN)
@@ -448,6 +452,10 @@ static int ll_xattr_get_common(const struct xattr_handler *handler,
 	if (rc)
 		return rc;
 
+	rc = ll_security_secctx_name_filter(sbi, handler->flags, name);
+	if (rc)
+		return rc;
+
 #ifdef CONFIG_LUSTRE_FS_POSIX_ACL
 	/* posix acl is under protection of LOOKUP lock. when calling to this,
 	 * we just have path resolution to the target inode, so we have great
diff --git a/fs/lustre/llite/xattr_cache.c b/fs/lustre/llite/xattr_cache.c
index ae5980603bce..d8ddb90f2042 100644
--- a/fs/lustre/llite/xattr_cache.c
+++ b/fs/lustre/llite/xattr_cache.c
@@ -461,9 +461,9 @@ static int ll_xattr_cache_refill(struct inode *inode)
 			CDEBUG(D_CACHE, "not caching %s\n",
 			       XATTR_NAME_ACL_ACCESS);
 			rc = 0;
-		} else if (!strcmp(xdata, "security.selinux")) {
-			/* Filter out security.selinux, it is cached in slab */
-			CDEBUG(D_CACHE, "not caching security.selinux\n");
+		} else if (ll_xattr_is_seclabel(xdata)) {
+			/* Filter out security label, it is cached in slab */
+			CDEBUG(D_CACHE, "not caching %s\n", xdata);
 			rc = 0;
 		} else if (!strcmp(xdata, XATTR_NAME_SOM)) {
 			/* Filter out trusted.som, it is not cached on client */
diff --git a/fs/lustre/llite/xattr_security.c b/fs/lustre/llite/xattr_security.c
index 39229d3d0f9e..9910ac6c77fc 100644
--- a/fs/lustre/llite/xattr_security.c
+++ b/fs/lustre/llite/xattr_security.c
@@ -38,19 +38,17 @@
 /*
  * Check for LL_SBI_FILE_SECCTX before calling.
  */
-int ll_dentry_init_security(struct inode *parent, struct dentry *dentry,
-			    int mode, struct qstr *name,
-			    const char **secctx_name, void **secctx,
-			    u32 *secctx_size)
+int ll_dentry_init_security(struct dentry *dentry, int mode, struct qstr *name,
+			    const char **secctx_name, u32 *secctx_name_size,
+			    void **secctx, u32 *secctx_size)
 {
+	struct ll_sb_info *sbi = ll_s2sbi(dentry->d_sb);
 	int rc;
 
 	/*
-	 * security_dentry_init_security() is strange. Like
-	 * security_inode_init_security() it may return a context (provided a
-	 * Linux security module is enabled) but unlike
-	 * security_inode_init_security() it does not return to us the name of
-	 * the extended attribute to store the context under (for example
+	 * Before kernel 5.15-rc1-20-g15bf32398ad4,
+	 * security_inode_init_security() does not return to us the name of the
+	 * extended attribute to store the context under (for example
 	 * "security.selinux"). So we only call it when we think we know what
 	 * the name of the extended attribute will be. This is OK-ish since
 	 * SELinux is the only module that implements
@@ -59,30 +57,19 @@ int ll_dentry_init_security(struct inode *parent, struct dentry *dentry,
 	 * from SELinux.
 	 */
 
-	/* fetch length of security xattr name */
-	rc = security_inode_listsecurity(parent, NULL, 0);
-	/* xattr name length == 0 means SELinux is disabled */
-	if (rc == 0)
+	*secctx_name_size = ll_secctx_name_get(sbi, secctx_name);
+	/* xattr name length == 0 means no LSM module manage file contexts */
+	if (*secctx_name_size == 0)
 		return 0;
-	/* we support SELinux only */
-	if (rc != strlen(XATTR_NAME_SELINUX) + 1)
-		return -EOPNOTSUPP;
 
 	rc = security_dentry_init_security(dentry, mode, name, secctx,
 					   secctx_size);
-	/* Usually, security_dentry_init_security() returns -EOPNOTSUPP when
-	 * SELinux is disabled.
-	 * But on some kernels (e.g. rhel 8.5) it returns 0 when SELinux is
-	 * disabled, and in this case the security context is empty.
-	 */
-	if (rc == -EOPNOTSUPP || (rc == 0 && *secctx_size == 0))
-		/* do nothing */
+	/* ignore error if the hook is not supported by the LSM module */
+	if (rc == -EOPNOTSUPP)
 		return 0;
 	if (rc < 0)
 		return rc;
 
-	*secctx_name = XATTR_NAME_SELINUX;
-
 	return 0;
 }
 
@@ -139,31 +126,159 @@ int
 ll_inode_init_security(struct dentry *dentry, struct inode *inode,
 		       struct inode *dir)
 {
-	int err;
+	int rc;
 
-	err = security_inode_init_security(inode, dir, NULL,
-					   &ll_initxattrs, dentry);
+	if (!ll_security_xattr_wanted(dir))
+		return 0;
 
-	if (err == -EOPNOTSUPP)
+	rc = security_inode_init_security(inode, dir, NULL,
+					  &ll_initxattrs, dentry);
+	if (rc == -EOPNOTSUPP)
 		return 0;
-	return err;
+
+	return rc;
 }
 
 /**
- * Get security context xattr name used by policy.
+ * Notify security context to the security layer
+ *
+ * Notify security context @secctx of inode @inode to the security layer.
  *
- * \retval >= 0     length of xattr name
- * \retval < 0      failure to get security context xattr name
+ * Return	0 success, or SELinux is disabled or not supported by the fs
+ *		< 0 failure to set the security context
  */
-int
-ll_listsecurity(struct inode *inode, char *secctx_name, size_t secctx_name_size)
+int ll_inode_notifysecctx(struct inode *inode,
+			  void *secctx, u32 secctxlen)
 {
+	struct ll_sb_info *sbi = ll_i2sbi(inode);
 	int rc;
 
-	rc = security_inode_listsecurity(inode, secctx_name, secctx_name_size);
-	if (rc >= secctx_name_size)
+	if (!test_bit(LL_SBI_FILE_SECCTX, sbi->ll_flags) ||
+	    !ll_security_xattr_wanted(inode) ||
+	    !secctx || !secctxlen)
+		return 0;
+
+	/* no need to protect selinux_inode_setsecurity() by
+	 * inode_lock. Taking it would lead to a client deadlock
+	 * LU-13617
+	 */
+	rc = security_inode_notifysecctx(inode, secctx, secctxlen);
+	if (rc)
+		CWARN("%s: cannot set security context for "DFID": rc = %d\n",
+		      sbi->ll_fsname, PFID(ll_inode2fid(inode)), rc);
+
+	return rc;
+}
+
+/**
+ * Free the security context xattr name used by policy
+ */
+void ll_secctx_name_free(struct ll_sb_info *sbi)
+{
+	kfree(sbi->ll_secctx_name);
+	sbi->ll_secctx_name = NULL;
+	sbi->ll_secctx_name_size = 0;
+}
+
+/**
+ * Get security context xattr name used by policy and save it.
+ *
+ * Return > 0	length of xattr name
+ *	  == 0	no LSM module registered supporting security contexts
+ *	  <= 0	failure to get xattr name or xattr is not supported
+ */
+int ll_secctx_name_store(struct inode *in)
+{
+	struct ll_sb_info *sbi = ll_i2sbi(in);
+	int rc = 0;
+
+	if (!ll_security_xattr_wanted(in))
+		return 0;
+
+	/* get size of xattr name */
+	rc = security_inode_listsecurity(in, NULL, 0);
+	if (rc <= 0)
+		return rc;
+
+	ll_secctx_name_free(sbi);
+
+	sbi->ll_secctx_name = kzalloc(rc + 1, GFP_NOFS);
+	if (!sbi->ll_secctx_name)
+		return -ENOMEM;
+
+	/* save the xattr name */
+	sbi->ll_secctx_name_size = rc;
+	rc = security_inode_listsecurity(in, sbi->ll_secctx_name,
+					 sbi->ll_secctx_name_size);
+	if (rc <= 0)
+		goto err_free;
+
+	if (rc > sbi->ll_secctx_name_size) {
 		rc = -ERANGE;
-	else if (rc >= 0)
-		secctx_name[rc] = '\0';
+		goto err_free;
+	}
+
+	/* sanity check */
+	sbi->ll_secctx_name[rc] = '\0';
+	if (rc < sizeof(XATTR_SECURITY_PREFIX)) {
+		rc = -EINVAL;
+		goto err_free;
+	}
+	if (strncmp(sbi->ll_secctx_name, XATTR_SECURITY_PREFIX,
+		    sizeof(XATTR_SECURITY_PREFIX) - 1) != 0) {
+		rc = -EOPNOTSUPP;
+		goto err_free;
+	}
+
+	return rc;
+
+err_free:
+	ll_secctx_name_free(sbi);
 	return rc;
 }
+
+/**
+ * Retrieved file security context xattr name stored.
+ *
+ * Return	security context xattr name size stored.
+ *	  0	no xattr name stored.
+ */
+u32 ll_secctx_name_get(struct ll_sb_info *sbi, const char **secctx_name)
+{
+	if (!sbi->ll_secctx_name || !sbi->ll_secctx_name_size)
+		return 0;
+
+	*secctx_name = sbi->ll_secctx_name;
+
+	return sbi->ll_secctx_name_size;
+}
+
+/**
+ * Filter out xattr file security context if not managed by LSM
+ *
+ * This is done to improve performance for application that blindly try to get
+ * file context (like "ls -l" for security.linux).
+ * See LU-549 for more information.
+ *
+ * Return 0		xattr not filtered
+ *	  -EOPNOTSUPP	no enabled LSM security module supports the xattr
+ */
+int ll_security_secctx_name_filter(struct ll_sb_info *sbi, int xattr_type,
+				   const char *suffix)
+{
+	const char *cached_suffix = NULL;
+
+	if (xattr_type != XATTR_SECURITY_T ||
+	    !ll_xattr_suffix_is_seclabel(suffix))
+		return 0;
+
+	/* is the xattr label used by lsm ? */
+	if (!ll_secctx_name_get(sbi, &cached_suffix))
+		return -EOPNOTSUPP;
+
+	cached_suffix += sizeof(XATTR_SECURITY_PREFIX) - 1;
+	if (strcmp(suffix, cached_suffix) != 0)
+		return -EOPNOTSUPP;
+
+	return 0;
+}
diff --git a/fs/lustre/ptlrpc/sec.c b/fs/lustre/ptlrpc/sec.c
index 976df0bca8a8..7cd09ebe78db 100644
--- a/fs/lustre/ptlrpc/sec.c
+++ b/fs/lustre/ptlrpc/sec.c
@@ -1767,19 +1767,17 @@ static inline int sptlrpc_sepol_needs_check(struct ptlrpc_sec *imp_sec)
 
 int sptlrpc_get_sepol(struct ptlrpc_request *req)
 {
-#ifndef CONFIG_SECURITY_SELINUX
+	struct ptlrpc_sec *imp_sec = req->rq_import->imp_sec;
+	int rc = 0;
+
 	(req->rq_sepol)[0] = '\0';
 
+#ifndef CONFIG_SECURITY_SELINUX
 	if (unlikely(send_sepol != 0))
 		CDEBUG(D_SEC,
 		       "Client cannot report SELinux status, it was not built against libselinux.\n");
 	return 0;
-#else
-	struct ptlrpc_sec *imp_sec = req->rq_import->imp_sec;
-	int rc = 0;
-
-	(req->rq_sepol)[0] = '\0';
-
+#endif
 	if (send_sepol == 0)
 		return 0;
 
@@ -1794,10 +1792,13 @@ int sptlrpc_get_sepol(struct ptlrpc_request *req)
 		memcpy(req->rq_sepol, imp_sec->ps_sepol,
 		       sizeof(req->rq_sepol));
 		spin_unlock(&imp_sec->ps_lock);
+	} else if (rc == -ENODEV) {
+		CDEBUG(D_SEC,
+		       "Client cannot report SELinux status, SELinux is disabled.\n");
+		rc = 0;
 	}
 
 	return rc;
-#endif
 }
 EXPORT_SYMBOL(sptlrpc_get_sepol);
 
-- 
2.27.0

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
