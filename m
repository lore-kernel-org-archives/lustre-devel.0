Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 5EE7AC6FA86
	for <lustre-devel@archiver.kernel.org>; Tue,  6 Sep 2022 01:55:48 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4MM7l55rgQz1y6G;
	Mon,  5 Sep 2022 18:55:45 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4MM7l15ccfz1wn4
 for <lustre-devel@lists.lustre.org>; Mon,  5 Sep 2022 18:55:41 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 9744C100AFF4;
 Mon,  5 Sep 2022 21:55:39 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 9177758992; Mon,  5 Sep 2022 21:55:39 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon,  5 Sep 2022 21:55:14 -0400
Message-Id: <1662429337-18737-2-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1662429337-18737-1-git-send-email-jsimmons@infradead.org>
References: <1662429337-18737-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 01/24] lustre: sec: new connect flag for name
 encryption
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
Cc: Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Sebastien Buisson <sbuisson@ddn.com>

Introduce OBD_CONNECT2_ENCRYPT_NAME connection flag for compatibility
with older versions that do not support name encryption.
When server side does not have this flag, client side is forced to
null encryption for file names. And client needs to use old xattr to
store encryption context.

Fixes: 860818695d ("lustre: sec: filename encryption - digest support")
WC-bug-id: https://jira.whamcloud.com/browse/LU-15922
Lustre-commit: 71d63602c57e6d0cb ("LU-15922 sec: new connect flag for name encryption")
Signed-off-by: Sebastien Buisson <sbuisson@ddn.com>
Reviewed-on: https://review.whamcloud.com/47574
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Lai Siyao <lai.siyao@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_crypto.h      |  2 ++
 fs/lustre/llite/crypto.c               | 19 ++++++++++++++++---
 fs/lustre/llite/llite_internal.h       | 30 +++++++++++++++++++++++++++---
 fs/lustre/llite/llite_lib.c            | 14 +++++++++++++-
 fs/lustre/llite/namei.c                |  2 +-
 fs/lustre/llite/statahead.c            |  2 +-
 fs/lustre/llite/symlink.c              |  2 +-
 fs/lustre/llite/xattr_cache.c          |  8 ++++----
 fs/lustre/obdclass/lprocfs_status.c    |  1 +
 fs/lustre/ptlrpc/wiretest.c            |  2 ++
 include/uapi/linux/lustre/lustre_idl.h |  1 +
 11 files changed, 69 insertions(+), 14 deletions(-)

diff --git a/fs/lustre/include/lustre_crypto.h b/fs/lustre/include/lustre_crypto.h
index c31cc1e..2252798 100644
--- a/fs/lustre/include/lustre_crypto.h
+++ b/fs/lustre/include/lustre_crypto.h
@@ -44,6 +44,8 @@ int ll_set_encflags(struct inode *inode, void *encctx, u32 encctxlen,
 bool ll_sb_has_test_dummy_encryption(struct super_block *sb);
 bool ll_sbi_has_encrypt(struct ll_sb_info *sbi);
 void ll_sbi_set_encrypt(struct ll_sb_info *sbi, bool set);
+bool ll_sbi_has_name_encrypt(struct ll_sb_info *sbi);
+void ll_sbi_set_name_encrypt(struct ll_sb_info *sbi, bool set);
 #else
 static inline int ll_set_encflags(struct inode *inode, void *encctx,
 				  u32 encctxlen, bool preload)
diff --git a/fs/lustre/llite/crypto.c b/fs/lustre/llite/crypto.c
index ad045c3..d6750fb 100644
--- a/fs/lustre/llite/crypto.c
+++ b/fs/lustre/llite/crypto.c
@@ -36,7 +36,7 @@ static int ll_get_context(struct inode *inode, void *ctx, size_t len)
 	/* Get enc context xattr directly instead of going through the VFS,
 	 * as there is no xattr handler for "encryption.".
 	 */
-	rc = ll_xattr_list(inode, LL_XATTR_NAME_ENCRYPTION_CONTEXT,
+	rc = ll_xattr_list(inode, xattr_for_enc(inode),
 			   XATTR_ENCRYPTION_T, ctx, len, OBD_MD_FLXATTR);
 
 	/* used as encryption unit size */
@@ -59,7 +59,7 @@ int ll_set_encflags(struct inode *inode, void *encctx, u32 encctxlen,
 
 	if (encctx && encctxlen)
 		rc = ll_xattr_cache_insert(inode,
-					   LL_XATTR_NAME_ENCRYPTION_CONTEXT,
+					   xattr_for_enc(inode),
 					   encctx, encctxlen);
 	if (rc)
 		return rc;
@@ -108,7 +108,7 @@ static int ll_set_context(struct inode *inode, const void *ctx, size_t len,
 	 * through the VFS, as there is no xattr handler for "encryption.".
 	 */
 	rc = md_setxattr(sbi->ll_md_exp, ll_inode2fid(inode),
-			 OBD_MD_FLXATTR, LL_XATTR_NAME_ENCRYPTION_CONTEXT,
+			 OBD_MD_FLXATTR, xattr_for_enc(inode),
 			 ctx, len, XATTR_CREATE, ll_i2suppgid(inode), &req);
 	if (rc)
 		return rc;
@@ -173,6 +173,19 @@ void ll_sbi_set_encrypt(struct ll_sb_info *sbi, bool set)
 	}
 }
 
+bool ll_sbi_has_name_encrypt(struct ll_sb_info *sbi)
+{
+	return test_bit(LL_SBI_ENCRYPT_NAME, sbi->ll_flags);
+}
+
+void ll_sbi_set_name_encrypt(struct ll_sb_info *sbi, bool set)
+{
+	if (set)
+		set_bit(LL_SBI_ENCRYPT_NAME, sbi->ll_flags);
+	else
+		clear_bit(LL_SBI_ENCRYPT_NAME, sbi->ll_flags);
+}
+
 static bool ll_empty_dir(struct inode *inode)
 {
 	/* used by fscrypt_ioctl_set_policy(), because a policy can only be set
diff --git a/fs/lustre/llite/llite_internal.h b/fs/lustre/llite/llite_internal.h
index 2139f88..b018515 100644
--- a/fs/lustre/llite/llite_internal.h
+++ b/fs/lustre/llite/llite_internal.h
@@ -468,11 +468,28 @@ static inline bool obd_connect_has_enc(struct obd_connect_data *data)
 
 static inline void obd_connect_set_enc(struct obd_connect_data *data)
 {
-#ifdef HAVE_LUSTRE_CRYPTO
+#ifdef CONFIG_FS_ENCRYPTION
 	data->ocd_connect_flags2 |= OBD_CONNECT2_ENCRYPT;
 #endif
 }
 
+static inline bool obd_connect_has_name_enc(struct obd_connect_data *data)
+{
+#ifdef CONFIG_FS_ENCRYPTION
+	return data->ocd_connect_flags & OBD_CONNECT_FLAGS2 &&
+		data->ocd_connect_flags2 & OBD_CONNECT2_ENCRYPT_NAME;
+#else
+	return false;
+#endif
+}
+
+static inline void obd_connect_set_name_enc(struct obd_connect_data *data)
+{
+#ifdef CONFIG_FS_ENCRYPTION
+	data->ocd_connect_flags2 |= OBD_CONNECT2_ENCRYPT_NAME;
+#endif
+}
+
 /*
  * Locking to guarantee consistency of non-atomic updates to long long i_size,
  * consistency between file size and KMS.
@@ -639,6 +656,7 @@ enum ll_sbi_flags {
 	LL_SBI_TINY_WRITE,		/* tiny write support */
 	LL_SBI_FILE_HEAT,		/* file heat support */
 	LL_SBI_PARALLEL_DIO,		/* parallel (async) O_DIRECT RPCs */
+	LL_SBI_ENCRYPT_NAME,		/* name encryption */
 	LL_SBI_NUM_FLAGS
 };
 
@@ -1727,7 +1745,6 @@ static inline struct pcc_super *ll_info2pccs(struct ll_inode_info *lli)
 }
 
 /* crypto.c */
-#ifdef CONFIG_FS_ENCRYPTION
 /* The digested form is made of a FID (16 bytes) followed by the second-to-last
  * ciphertext block (16 bytes), so a total length of 32 bytes.
  * That way, fscrypt does not compute a digested form of this digest.
@@ -1737,6 +1754,14 @@ struct ll_digest_filename {
 	char ldf_excerpt[FS_CRYPTO_BLOCK_SIZE];
 };
 
+static inline char *xattr_for_enc(struct inode *inode)
+{
+	if (ll_sbi_has_name_encrypt(ll_i2sbi(inode)))
+		return LL_XATTR_NAME_ENCRYPTION_CONTEXT;
+
+	return LL_XATTR_NAME_ENCRYPTION_CONTEXT_OLD;
+}
+#ifdef CONFIG_FS_ENCRYPTION
 int ll_setup_filename(struct inode *dir, const struct qstr *iname,
 		      int lookup, struct fscrypt_name *fname,
 		      struct lu_fid *fid);
@@ -1752,7 +1777,6 @@ int ll_setup_filename(struct inode *dir, const struct qstr *iname,
 {
 	return fscrypt_setup_filename(dir, iname, lookup, fname);
 }
-
 int ll_fname_disk_to_usr(struct inode *inode,
 			 u32 hash, u32 minor_hash,
 			 struct fscrypt_str *iname, struct fscrypt_str *oname)
diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index dee2e51..5daced0 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -173,6 +173,7 @@ static struct ll_sb_info *ll_init_sbi(void)
 	set_bit(LL_SBI_TINY_WRITE, sbi->ll_flags);
 	set_bit(LL_SBI_PARALLEL_DIO, sbi->ll_flags);
 	ll_sbi_set_encrypt(sbi, true);
+	ll_sbi_set_name_encrypt(sbi, true);
 
 	/* root squash */
 	sbi->ll_squash.rsi_uid = 0;
@@ -349,8 +350,10 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt)
 		data->ocd_connect_flags &= ~OBD_CONNECT_PINGLESS;
 
 	obd_connect_set_secctx(data);
-	if (ll_sbi_has_encrypt(sbi))
+	if (ll_sbi_has_encrypt(sbi)) {
+		obd_connect_set_name_enc(data);
 		obd_connect_set_enc(data);
+	}
 
 #if defined(CONFIG_SECURITY)
 	data->ocd_connect_flags2 |= OBD_CONNECT2_SELINUX_POLICY;
@@ -482,6 +485,14 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt)
 		ll_sbi_set_encrypt(sbi, false);
 	}
 
+	if (ll_sbi_has_name_encrypt(sbi) && !obd_connect_has_name_enc(data)) {
+		if (ll_sb_has_test_dummy_encryption(sb))
+			LCONSOLE_WARN("%s: server %s does not support name encryption, not using it.\n",
+				      sbi->ll_fsname,
+				      sbi->ll_md_exp->exp_obd->obd_name);
+		ll_sbi_set_name_encrypt(sbi, false);
+	}
+
 	if (data->ocd_ibits_known & MDS_INODELOCK_XATTR) {
 		if (!(data->ocd_connect_flags & OBD_CONNECT_MAX_EASIZE)) {
 			LCONSOLE_INFO("%s: disabling xattr cache due to unknown maximum xattr size.\n",
@@ -928,6 +939,7 @@ void ll_kill_super(struct super_block *sb)
 	{LL_SBI_TINY_WRITE,		"tiny_write"},
 	{LL_SBI_FILE_HEAT,		"file_heat"},
 	{LL_SBI_PARALLEL_DIO,		"parallel_dio"},
+	{LL_SBI_ENCRYPT_NAME,		"name_encrypt"},
 };
 
 int ll_sbi_flags_seq_show(struct seq_file *m, void *v)
diff --git a/fs/lustre/llite/namei.c b/fs/lustre/llite/namei.c
index 2215dd8..a08b1c1 100644
--- a/fs/lustre/llite/namei.c
+++ b/fs/lustre/llite/namei.c
@@ -668,7 +668,7 @@ static int ll_lookup_it_finish(struct ptlrpc_request *request,
 				       "server returned encryption ctx for " DFID "\n",
 				       PFID(ll_inode2fid(inode)));
 				rc = ll_xattr_cache_insert(inode,
-							   LL_XATTR_NAME_ENCRYPTION_CONTEXT,
+							   xattr_for_enc(inode),
 							   encctx, encctxlen);
 				if (rc) {
 					CWARN("%s: cannot set enc ctx for " DFID ": rc = %d\n",
diff --git a/fs/lustre/llite/statahead.c b/fs/lustre/llite/statahead.c
index 3043a51..c6779eb 100644
--- a/fs/lustre/llite/statahead.c
+++ b/fs/lustre/llite/statahead.c
@@ -682,7 +682,7 @@ static void sa_instantiate(struct ll_statahead_info *sai,
 			       "server returned encryption ctx for "DFID"\n",
 			       PFID(ll_inode2fid(child)));
 			rc = ll_xattr_cache_insert(child,
-						   LL_XATTR_NAME_ENCRYPTION_CONTEXT,
+						   xattr_for_enc(child),
 						   encctx, encctxlen);
 			if (rc)
 				CWARN("%s: cannot set enc ctx for "DFID": rc = %d\n",
diff --git a/fs/lustre/llite/symlink.c b/fs/lustre/llite/symlink.c
index 8ea16bb..35a8574 100644
--- a/fs/lustre/llite/symlink.c
+++ b/fs/lustre/llite/symlink.c
@@ -38,7 +38,7 @@
 #include "llite_internal.h"
 
 /* Must be called with lli_size_mutex locked */
-/* HAVE_IOP_GET_LINK is defined from kernel 4.5, whereas
+/* iop->get_link is defined from kernel 4.5, whereas
  * IS_ENCRYPTED is brought by kernel 4.14.
  * So there is no need to handle encryption case otherwise.
  */
diff --git a/fs/lustre/llite/xattr_cache.c b/fs/lustre/llite/xattr_cache.c
index 7e5b807..ae59806 100644
--- a/fs/lustre/llite/xattr_cache.c
+++ b/fs/lustre/llite/xattr_cache.c
@@ -109,7 +109,8 @@ static int ll_xattr_cache_add(struct list_head *cache,
 	struct ll_xattr_entry *xattr;
 
 	if (ll_xattr_cache_find(cache, xattr_name, &xattr) == 0) {
-		if (!strcmp(xattr_name, LL_XATTR_NAME_ENCRYPTION_CONTEXT))
+		if (!strcmp(xattr_name, LL_XATTR_NAME_ENCRYPTION_CONTEXT) ||
+		    !strcmp(xattr_name, LL_XATTR_NAME_ENCRYPTION_CONTEXT_OLD))
 			/* it means enc ctx was already in cache,
 			 * ignore error as it cannot be modified
 			 */
@@ -288,8 +289,7 @@ int ll_xattr_cache_empty(struct inode *inode)
 		goto out_empty;
 
 	list_for_each_entry_safe(entry, n, &lli->lli_xattrs, xe_list) {
-		if (strcmp(entry->xe_name,
-			   LL_XATTR_NAME_ENCRYPTION_CONTEXT) == 0)
+		if (strcmp(entry->xe_name, xattr_for_enc(inode)) == 0)
 			continue;
 
 		CDEBUG(D_CACHE, "delete: %s\n", entry->xe_name);
@@ -534,7 +534,7 @@ int ll_xattr_cache_get(struct inode *inode, const char *name, char *buffer,
 	 * cache if we are just interested in encryption context.
 	 */
 	if ((valid & OBD_MD_FLXATTRLS ||
-	     strcmp(name, LL_XATTR_NAME_ENCRYPTION_CONTEXT) != 0) &&
+	     strcmp(name, xattr_for_enc(inode)) != 0) &&
 	    !ll_xattr_cache_filled(lli)) {
 		up_read(&lli->lli_xattrs_list_rwsem);
 		rc = ll_xattr_cache_refill(inode);
diff --git a/fs/lustre/obdclass/lprocfs_status.c b/fs/lustre/obdclass/lprocfs_status.c
index 335e748..d80e7bd 100644
--- a/fs/lustre/obdclass/lprocfs_status.c
+++ b/fs/lustre/obdclass/lprocfs_status.c
@@ -137,6 +137,7 @@
 	"mne_nid_type",		/* 0x1000000 */
 	"lock_contend",		/* 0x2000000 */
 	"atomic_open_lock",	/* 0x4000000 */
+	"name_encryption",	/* 0x8000000 */
 	NULL
 };
 
diff --git a/fs/lustre/ptlrpc/wiretest.c b/fs/lustre/ptlrpc/wiretest.c
index 60a7fd0..66c7c17 100644
--- a/fs/lustre/ptlrpc/wiretest.c
+++ b/fs/lustre/ptlrpc/wiretest.c
@@ -1241,6 +1241,8 @@ void lustre_assert_wire_constants(void)
 		 OBD_CONNECT2_PCCRO);
 	LASSERTF(OBD_CONNECT2_ATOMIC_OPEN_LOCK == 0x4000000ULL, "found 0x%.16llxULL\n",
 		 OBD_CONNECT2_ATOMIC_OPEN_LOCK);
+	LASSERTF(OBD_CONNECT2_ENCRYPT_NAME == 0x8000000ULL, "found 0x%.16llxULL\n",
+		 OBD_CONNECT2_ENCRYPT_NAME);
 	LASSERTF(OBD_CKSUM_CRC32 == 0x00000001UL, "found 0x%.8xUL\n",
 		 (unsigned int)OBD_CKSUM_CRC32);
 	LASSERTF(OBD_CKSUM_ADLER == 0x00000002UL, "found 0x%.8xUL\n",
diff --git a/include/uapi/linux/lustre/lustre_idl.h b/include/uapi/linux/lustre/lustre_idl.h
index 37db3ee..319dc81d 100644
--- a/include/uapi/linux/lustre/lustre_idl.h
+++ b/include/uapi/linux/lustre/lustre_idl.h
@@ -809,6 +809,7 @@ struct ptlrpc_body_v2 {
 #define OBD_CONNECT2_BATCH_RPC	     0x400000ULL /* Multi-RPC batch request */
 #define OBD_CONNECT2_PCCRO	     0x800000ULL /* Read-only PCC */
 #define OBD_CONNECT2_ATOMIC_OPEN_LOCK 0x4000000ULL/* request lock on 1st open */
+#define OBD_CONNECT2_ENCRYPT_NAME     0x8000000ULL /* name encrypt */
 /* XXX README XXX:
  * Please DO NOT add flag values here before first ensuring that this same
  * flag value is not in use on some other branch.  Please clear any such
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
