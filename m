From: James Simmons <jsimmons@infradead.org>
Date: Sat, 13 Jun 2020 12:27:12 -0400
Subject: [lustre-devel] [PATCH 16/20] lustre: sec: control client side
 encryption
In-Reply-To: <1592065636-28333-1-git-send-email-jsimmons@infradead.org>
References: <1592065636-28333-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1592065636-28333-17-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Sebastien Buisson <sbuisson@ddn.com>

Client enables encryption by default. However, this should be
possible only if server side is encryption aware.
Moreover, we want to give the ability to decide which clients can
make use of encryption, by extending the nodemap mechanism with a
new 'forbid_encryption' property, set to 0 by default.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12275
Lustre-commit: 3042bcd709ebf ("LU-12275 sec: control client side encryption")
Signed-off-by: Sebastien Buisson <sbuisson@ddn.com>
Reviewed-on: https://review.whamcloud.com/36433
Reviewed-by: John L. Hammond <jhammond@whamcloud.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/llite_internal.h | 17 +++++++++++++++++
 fs/lustre/llite/llite_lib.c      | 23 +++++++++++++++++++++++
 2 files changed, 40 insertions(+)

diff --git a/fs/lustre/llite/llite_internal.h b/fs/lustre/llite/llite_internal.h
index 96585a7..a688bd8 100644
--- a/fs/lustre/llite/llite_internal.h
+++ b/fs/lustre/llite/llite_internal.h
@@ -398,6 +398,23 @@ int ll_inode_init_security(struct dentry *dentry, struct inode *inode,
 int ll_listsecurity(struct inode *inode, char *secctx_name,
 		    size_t secctx_name_size);
 
+static inline bool obd_connect_has_enc(struct obd_connect_data *data)
+{
+#ifdef CONFIG_FS_ENCRYPTION
+	return data->ocd_connect_flags & OBD_CONNECT_FLAGS2 &&
+	       data->ocd_connect_flags2 & OBD_CONNECT2_ENCRYPT;
+#else
+	return false;
+#endif
+}
+
+static inline void obd_connect_set_enc(struct obd_connect_data *data)
+{
+#ifdef HAVE_LUSTRE_CRYPTO
+	data->ocd_connect_flags2 |= OBD_CONNECT2_ENCRYPT;
+#endif
+}
+
 /*
  * Locking to guarantee consistency of non-atomic updates to long long i_size,
  * consistency between file size and KMS.
diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index 5639b16..6cd9f7e 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -303,6 +303,8 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt)
 		data->ocd_connect_flags &= ~OBD_CONNECT_PINGLESS;
 
 	obd_connect_set_secctx(data);
+	if (ll_sbi_has_encrypt(sbi))
+		obd_connect_set_enc(data);
 
 #if defined(CONFIG_SECURITY)
 	data->ocd_connect_flags2 |= OBD_CONNECT2_SELINUX_POLICY;
@@ -424,6 +426,14 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt)
 	if (obd_connect_has_secctx(data))
 		sbi->ll_flags |= LL_SBI_FILE_SECCTX;
 
+	if (ll_sbi_has_encrypt(sbi) && !obd_connect_has_enc(data)) {
+		if (ll_sbi_has_test_dummy_encryption(sbi))
+			LCONSOLE_WARN("%s: server %s does not support encryption feature, encryption deactivated.\n",
+				      sbi->ll_fsname,
+				      sbi->ll_md_exp->exp_obd->obd_name);
+		ll_sbi_set_encrypt(sbi, false);
+	}
+
 	if (data->ocd_ibits_known & MDS_INODELOCK_XATTR) {
 		if (!(data->ocd_connect_flags & OBD_CONNECT_MAX_EASIZE)) {
 			LCONSOLE_INFO("%s: disabling xattr cache due to unknown maximum xattr size.\n",
@@ -486,6 +496,9 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt)
 	if (sbi->ll_flags & LL_SBI_ALWAYS_PING)
 		data->ocd_connect_flags &= ~OBD_CONNECT_PINGLESS;
 
+	if (ll_sbi_has_encrypt(sbi))
+		obd_connect_set_enc(data);
+
 	CDEBUG(D_RPCTRACE,
 	       "ocd_connect_flags: %#llx ocd_version: %d ocd_grant: %d\n",
 	       data->ocd_connect_flags,
@@ -509,6 +522,16 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt)
 		goto out_md_fid;
 	}
 
+	if (ll_sbi_has_encrypt(sbi) &&
+	    !obd_connect_has_enc(&sbi->ll_dt_obd->u.lov.lov_ocd)) {
+		if (ll_sbi_has_test_dummy_encryption(sbi))
+			LCONSOLE_WARN("%s: server %s does not support encryption feature, encryption deactivated.\n",
+				      sbi->ll_fsname, dt);
+		ll_sbi_set_encrypt(sbi, false);
+	} else if (ll_sbi_has_test_dummy_encryption(sbi)) {
+		LCONSOLE_WARN("Test dummy encryption mode enabled\n");
+	}
+
 	sbi->ll_dt_exp->exp_connect_data = *data;
 
 	/* Don't change value if it was specified in the config log */
-- 
1.8.3.1
