Return-Path: <SRS0=EXfh=KK=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.7 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6DD57C433B4
	for <lustre-devel@archiver.kernel.org>; Sat, 15 May 2021 13:06:33 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 14814611C9
	for <lustre-devel@archiver.kernel.org>; Sat, 15 May 2021 13:06:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 14814611C9
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id ABF8821FABF;
	Sat, 15 May 2021 06:06:23 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id B24E321CAD2
 for <lustre-devel@lists.lustre.org>; Sat, 15 May 2021 06:06:15 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 88D10100677C;
 Sat, 15 May 2021 09:06:12 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 7E96DA93C3; Sat, 15 May 2021 09:06:12 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sat, 15 May 2021 09:06:04 -0400
Message-Id: <1621083970-32463-8-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1621083970-32463-1-git-send-email-jsimmons@infradead.org>
References: <1621083970-32463-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 07/13] lustre: sec: rework includes for
 client encryption
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

Simplify includes for crypto, by not repeating stubs in case
CONFIG_FS_ENCRYPTION is not defined.
Expose encoding routines that are going to be used in the Lustre
code (both client and server sides) with filename encryption.

WC-bug-id: https://jira.whamcloud.com/browse/LU-13717
Lustre-commit: 028281ae195927e9751 ("LU-13717 sec: rework includes for client encryption")
Signed-off-by: Sebastien Buisson <sbuisson@ddn.com>
Reviewed-on: https://review.whamcloud.com/43386
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_crypto.h | 158 +++++++++++++++++++++-----------------
 fs/lustre/llite/crypto.c          |   6 +-
 fs/lustre/llite/dir.c             |  20 ++---
 fs/lustre/llite/file.c            |  22 +++---
 fs/lustre/llite/llite_internal.h  |  18 +----
 fs/lustre/llite/llite_lib.c       |   6 +-
 fs/lustre/llite/namei.c           |  26 +++----
 fs/lustre/llite/super25.c         |   4 +-
 fs/lustre/osc/osc_request.c       |  12 +--
 9 files changed, 135 insertions(+), 137 deletions(-)

diff --git a/fs/lustre/include/lustre_crypto.h b/fs/lustre/include/lustre_crypto.h
index 01b5e85..b19bb420 100644
--- a/fs/lustre/include/lustre_crypto.h
+++ b/fs/lustre/include/lustre_crypto.h
@@ -30,87 +30,101 @@
 #ifndef _LUSTRE_CRYPTO_H_
 #define _LUSTRE_CRYPTO_H_
 
+#include <linux/fscrypt.h>
+
 struct ll_sb_info;
+#ifdef CONFIG_FS_ENCRYPTION
 int ll_set_encflags(struct inode *inode, void *encctx, u32 encctxlen,
 		    bool preload);
 bool ll_sbi_has_test_dummy_encryption(struct ll_sb_info *sbi);
 bool ll_sbi_has_encrypt(struct ll_sb_info *sbi);
 void ll_sbi_set_encrypt(struct ll_sb_info *sbi, bool set);
+#else
+static inline int ll_set_encflags(struct inode *inode, void *encctx,
+				  u32 encctxlen, bool preload)
+{
+	return 0;
+}
 
-#ifdef CONFIG_FS_ENCRYPTION
-#define __FS_HAS_ENCRYPTION 1
-#include <linux/fscrypt.h>
+static inline bool ll_sbi_has_test_dummy_encryption(struct ll_sb_info *sbi)
+{
+	return false;
+}
 
-#define llcrypt_operations	fscrypt_operations
-#define llcrypt_symlink_data	fscrypt_symlink_data
-#define llcrypt_dummy_context_enabled(inode) \
-	fscrypt_dummy_context_enabled(inode)
-#define llcrypt_has_encryption_key(inode) fscrypt_has_encryption_key(inode)
-#define llcrypt_encrypt_pagecache_blocks(page, len, offs, gfp_flags)	\
-	fscrypt_encrypt_pagecache_blocks(page, len, offs, gfp_flags)
-#define llcrypt_encrypt_block_inplace(inode, page, len, offs, lblk, gfp_flags) \
-	fscrypt_encrypt_block_inplace(inode, page, len, offs, lblk, gfp_flags)
-#define llcrypt_decrypt_pagecache_blocks(page, len, offs)	\
-	fscrypt_decrypt_pagecache_blocks(page, len, offs)
-#define llcrypt_decrypt_block_inplace(inode, page, len, offs, lblk_num)        \
-	fscrypt_decrypt_block_inplace(inode, page, len, offs, lblk_num)
-#define llcrypt_inherit_context(parent, child, fs_data, preload)	\
-	fscrypt_inherit_context(parent, child, fs_data, preload)
-#define llcrypt_get_encryption_info(inode) fscrypt_get_encryption_info(inode)
-#define llcrypt_put_encryption_info(inode) fscrypt_put_encryption_info(inode)
-#define llcrypt_free_inode(inode)	   fscrypt_free_inode(inode)
-#define llcrypt_finalize_bounce_page(pagep)  fscrypt_finalize_bounce_page(pagep)
-#define llcrypt_file_open(inode, filp)	fscrypt_file_open(inode, filp)
-#define llcrypt_ioctl_set_policy(filp, arg)  fscrypt_ioctl_set_policy(filp, arg)
-#define llcrypt_ioctl_get_policy_ex(filp, arg)	\
-	fscrypt_ioctl_get_policy_ex(filp, arg)
-#define llcrypt_ioctl_add_key(filp, arg)	fscrypt_ioctl_add_key(filp, arg)
-#define llcrypt_ioctl_remove_key(filp, arg)  fscrypt_ioctl_remove_key(filp, arg)
-#define llcrypt_ioctl_remove_key_all_users(filp, arg)	\
-	fscrypt_ioctl_remove_key_all_users(filp, arg)
-#define llcrypt_ioctl_get_key_status(filp, arg)	\
-	fscrypt_ioctl_get_key_status(filp, arg)
-#define llcrypt_drop_inode(inode)	fscrypt_drop_inode(inode)
-#define llcrypt_prepare_rename(olddir, olddentry, newdir, newdentry, flags) \
-	fscrypt_prepare_rename(olddir, olddentry, newdir, newdentry, flags)
-#define llcrypt_prepare_link(old_dentry, dir, dentry)	\
-	fscrypt_prepare_link(old_dentry, dir, dentry)
-#define llcrypt_prepare_setattr(dentry, attr)		\
-	fscrypt_prepare_setattr(dentry, attr)
-#define llcrypt_set_ops(sb, cop)	fscrypt_set_ops(sb, cop)
-#else /* !CONFIG_FS_ENCRYPTION */
-#undef IS_ENCRYPTED
-#define IS_ENCRYPTED(x)	0
-#define llcrypt_dummy_context_enabled(inode)	NULL
-/* copied from include/linux/fscrypt.h */
-#define llcrypt_has_encryption_key(inode) false
-#define llcrypt_encrypt_pagecache_blocks(page, len, offs, gfp_flags)	\
-	ERR_PTR(-EOPNOTSUPP)
-#define llcrypt_encrypt_block_inplace(inode, page, len, offs, lblk, gfp_flags) \
-	-EOPNOTSUPP
-#define llcrypt_decrypt_pagecache_blocks(page, len, offs)	-EOPNOTSUPP
-#define llcrypt_decrypt_block_inplace(inode, page, len, offs, lblk_num)	       \
-	-EOPNOTSUPP
-#define llcrypt_inherit_context(parent, child, fs_data, preload)     -EOPNOTSUPP
-#define llcrypt_get_encryption_info(inode)			-EOPNOTSUPP
-#define llcrypt_put_encryption_info(inode)			do {} while (0)
-#define llcrypt_free_inode(inode)				do {} while (0)
-#define llcrypt_finalize_bounce_page(pagep)			do {} while (0)
-static inline int llcrypt_file_open(struct inode *inode, struct file *filp)
+static inline bool ll_sbi_has_encrypt(struct ll_sb_info *sbi)
 {
-	return IS_ENCRYPTED(inode) ? -EOPNOTSUPP : 0;
+	return false;
 }
-#define llcrypt_ioctl_set_policy(filp, arg)			-EOPNOTSUPP
-#define llcrypt_ioctl_get_policy_ex(filp, arg)			-EOPNOTSUPP
-#define llcrypt_ioctl_add_key(filp, arg)			-EOPNOTSUPP
-#define llcrypt_ioctl_remove_key(filp, arg)			-EOPNOTSUPP
-#define llcrypt_ioctl_remove_key_all_users(filp, arg)		-EOPNOTSUPP
-#define llcrypt_ioctl_get_key_status(filp, arg)			-EOPNOTSUPP
-#define llcrypt_drop_inode(inode)				 0
-#define llcrypt_prepare_rename(olddir, olddentry, newdir, newdentry, flags)    0
-#define llcrypt_prepare_link(old_dentry, dir, dentry)		 0
-#define llcrypt_prepare_setattr(dentry, attr)			 0
-#define llcrypt_set_ops(sb, cop)				do {} while (0)
-#endif /* CONFIG_FS_ENCRYPTION */
+
+static inline void ll_sbi_set_encrypt(struct ll_sb_info *sbi, bool set) { }
+#endif
+
+/* Encoding/decoding routines inspired from yEnc principles.
+ * We just take care of a few critical characters:
+ * NULL, LF, CR, /, DEL and =.
+ * If such a char is found, it is replaced with '=' followed by
+ * the char value + 64.
+ * All other chars are left untouched.
+ * Efficiency of this encoding depends on the occurences of the
+ * critical chars, but statistically on binary data it can be much higher
+ * than base64 for instance.
+ */
+static inline int critical_encode(const u8 *src, int len, char *dst)
+{
+	u8 *p = (u8 *)src, *q = dst;
+
+	while (p - src < len) {
+		/* escape NULL, LF, CR, /, DEL and = */
+		if (unlikely(*p == 0x0 || *p == 0xA || *p == 0xD ||
+			     *p == '/' || *p == 0x7F || *p == '=')) {
+			*(q++) = '=';
+			*(q++) = *(p++) + 64;
+		} else {
+			*(q++) = *(p++);
+		}
+	}
+
+	return (char *)q - dst;
+}
+
+/* returns the number of chars encoding would produce */
+static inline int critical_chars(const u8 *src, int len)
+{
+	u8 *p = (u8 *)src;
+	int newlen = len;
+
+	while (p - src < len) {
+		/* NULL, LF, CR, /, DEL and = cost an additional '=' */
+		if (unlikely(*p == 0x0 || *p == 0xA || *p == 0xD ||
+			     *p == '/' || *p == 0x7F || *p == '='))
+			newlen++;
+		p++;
+	}
+
+	return newlen;
+}
+
+/* decoding routine - returns the number of chars in output */
+static inline int critical_decode(const u8 *src, int len, char *dst)
+{
+	u8 *p = (u8 *)src, *q = dst;
+
+	while (p - src < len) {
+		if (unlikely(*p == '=')) {
+			*(q++) = *(++p) - 64;
+			p++;
+		} else {
+			*(q++) = *(p++);
+		}
+	}
+
+	return (char *)q - dst;
+}
+
+/* Extracts the second-to-last ciphertext block */
+#define LLCRYPT_FNAME_DIGEST(name, len)					\
+	((name) + round_down((len) - FS_CRYPTO_BLOCK_SIZE - 1,		\
+			     FS_CRYPTO_BLOCK_SIZE))
+#define LLCRYPT_FNAME_DIGEST_SIZE	FS_CRYPTO_BLOCK_SIZE
 
 #endif /* _LUSTRE_CRYPTO_H_ */
diff --git a/fs/lustre/llite/crypto.c b/fs/lustre/llite/crypto.c
index 8bbb766..34d0ad1 100644
--- a/fs/lustre/llite/crypto.c
+++ b/fs/lustre/llite/crypto.c
@@ -64,7 +64,7 @@ int ll_set_encflags(struct inode *inode, void *encctx, u32 encctxlen,
 	if (rc)
 		return rc;
 
-	return preload ? llcrypt_get_encryption_info(inode) : 0;
+	return preload ? fscrypt_get_encryption_info(inode) : 0;
 }
 
 /* ll_set_context has 2 distinct behaviors, depending on the value of inode
@@ -143,7 +143,7 @@ void ll_sbi_set_encrypt(struct ll_sb_info *sbi, bool set)
 
 static bool ll_empty_dir(struct inode *inode)
 {
-	/* used by llcrypt_ioctl_set_policy(), because a policy can only be set
+	/* used by fscrypt_ioctl_set_policy(), because a policy can only be set
 	 * on an empty dir.
 	 */
 	/* Here we choose to return true, meaning we always call .set_context.
@@ -153,7 +153,7 @@ static bool ll_empty_dir(struct inode *inode)
 	return true;
 }
 
-const struct llcrypt_operations lustre_cryptops = {
+const struct fscrypt_operations lustre_cryptops = {
 	.key_prefix		= "lustre:",
 	.get_context		= ll_get_context,
 	.set_context		= ll_set_context,
diff --git a/fs/lustre/llite/dir.c b/fs/lustre/llite/dir.c
index 06ca329..13676c1 100644
--- a/fs/lustre/llite/dir.c
+++ b/fs/lustre/llite/dir.c
@@ -450,11 +450,11 @@ static int ll_dir_setdirstripe(struct dentry *dparent, struct lmv_user_md *lump,
 
 	if (ll_sbi_has_encrypt(sbi) &&
 	    (IS_ENCRYPTED(parent) ||
-	     unlikely(llcrypt_dummy_context_enabled(parent)))) {
-		err = llcrypt_get_encryption_info(parent);
+	     unlikely(fscrypt_dummy_context_enabled(parent)))) {
+		err = fscrypt_get_encryption_info(parent);
 		if (err)
 			goto out_op_data;
-		if (!llcrypt_has_encryption_key(parent)) {
+		if (!fscrypt_has_encryption_key(parent)) {
 			err = -ENOKEY;
 			goto out_op_data;
 		}
@@ -476,7 +476,7 @@ static int ll_dir_setdirstripe(struct dentry *dparent, struct lmv_user_md *lump,
 	}
 
 	if (encrypt) {
-		err = llcrypt_inherit_context(parent, NULL, op_data, false);
+		err = fscrypt_inherit_context(parent, NULL, op_data, false);
 		if (err)
 			goto out_op_data;
 	}
@@ -2149,28 +2149,28 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 	case FS_IOC_SET_ENCRYPTION_POLICY:
 		if (!ll_sbi_has_encrypt(ll_i2sbi(inode)))
 			return -EOPNOTSUPP;
-		return llcrypt_ioctl_set_policy(file, (const void __user *)arg);
+		return fscrypt_ioctl_set_policy(file, (const void __user *)arg);
 	case FS_IOC_GET_ENCRYPTION_POLICY_EX:
 		if (!ll_sbi_has_encrypt(ll_i2sbi(inode)))
 			return -EOPNOTSUPP;
-		return llcrypt_ioctl_get_policy_ex(file, (void __user *)arg);
+		return fscrypt_ioctl_get_policy_ex(file, (void __user *)arg);
 	case FS_IOC_ADD_ENCRYPTION_KEY:
 		if (!ll_sbi_has_encrypt(ll_i2sbi(inode)))
 			return -EOPNOTSUPP;
-		return llcrypt_ioctl_add_key(file, (void __user *)arg);
+		return fscrypt_ioctl_add_key(file, (void __user *)arg);
 	case FS_IOC_REMOVE_ENCRYPTION_KEY:
 		if (!ll_sbi_has_encrypt(ll_i2sbi(inode)))
 			return -EOPNOTSUPP;
-		return llcrypt_ioctl_remove_key(file, (void __user *)arg);
+		return fscrypt_ioctl_remove_key(file, (void __user *)arg);
 	case FS_IOC_REMOVE_ENCRYPTION_KEY_ALL_USERS:
 		if (!ll_sbi_has_encrypt(ll_i2sbi(inode)))
 			return -EOPNOTSUPP;
-		return llcrypt_ioctl_remove_key_all_users(file,
+		return fscrypt_ioctl_remove_key_all_users(file,
 							  (void __user *)arg);
 	case FS_IOC_GET_ENCRYPTION_KEY_STATUS:
 		if (!ll_sbi_has_encrypt(ll_i2sbi(inode)))
 			return -EOPNOTSUPP;
-		return llcrypt_ioctl_get_key_status(file, (void __user *)arg);
+		return fscrypt_ioctl_get_key_status(file, (void __user *)arg);
 #endif
 	default:
 		return obd_iocontrol(cmd, sbi->ll_dt_exp, 0, NULL,
diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index 78f3469..ffddec6 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -443,7 +443,7 @@ static inline int ll_dom_readpage(void *data, struct page *page)
 	kunmap_atomic(kaddr);
 
 	if (inode && IS_ENCRYPTED(inode) && S_ISREG(inode->i_mode)) {
-		if (!llcrypt_has_encryption_key(inode)) {
+		if (!fscrypt_has_encryption_key(inode)) {
 			CDEBUG(D_SEC, "no enc key for " DFID "\n",
 			       PFID(ll_inode2fid(inode)));
 		} else {
@@ -456,7 +456,7 @@ static inline int ll_dom_readpage(void *data, struct page *page)
 					   LUSTRE_ENCRYPTION_UNIT_SIZE) == 0)
 					break;
 
-				rc = llcrypt_decrypt_pagecache_blocks(page,
+				rc = fscrypt_decrypt_pagecache_blocks(page,
 								      LUSTRE_ENCRYPTION_UNIT_SIZE,
 								      0);
 				if (rc)
@@ -776,7 +776,7 @@ int ll_file_open(struct inode *inode, struct file *file)
 	file->private_data = NULL; /* prevent ll_local_open assertion */
 
 	if (S_ISREG(inode->i_mode)) {
-		rc = llcrypt_file_open(inode, file);
+		rc = fscrypt_file_open(inode, file);
 		if (rc)
 			goto out_nofiledata;
 	}
@@ -4063,28 +4063,28 @@ static int ll_heat_set(struct inode *inode, enum lu_heat_flag flags)
 	case FS_IOC_SET_ENCRYPTION_POLICY:
 		if (!ll_sbi_has_encrypt(ll_i2sbi(inode)))
 			return -EOPNOTSUPP;
-		return llcrypt_ioctl_set_policy(file, (const void __user *)arg);
+		return fscrypt_ioctl_set_policy(file, (const void __user *)arg);
 	case FS_IOC_GET_ENCRYPTION_POLICY_EX:
 		if (!ll_sbi_has_encrypt(ll_i2sbi(inode)))
 			return -EOPNOTSUPP;
-		return llcrypt_ioctl_get_policy_ex(file, (void __user *)arg);
+		return fscrypt_ioctl_get_policy_ex(file, (void __user *)arg);
 	case FS_IOC_ADD_ENCRYPTION_KEY:
 		if (!ll_sbi_has_encrypt(ll_i2sbi(inode)))
 			return -EOPNOTSUPP;
-		return llcrypt_ioctl_add_key(file, (void __user *)arg);
+		return fscrypt_ioctl_add_key(file, (void __user *)arg);
 	case FS_IOC_REMOVE_ENCRYPTION_KEY:
 		if (!ll_sbi_has_encrypt(ll_i2sbi(inode)))
 			return -EOPNOTSUPP;
-		return llcrypt_ioctl_remove_key(file, (void __user *)arg);
+		return fscrypt_ioctl_remove_key(file, (void __user *)arg);
 	case FS_IOC_REMOVE_ENCRYPTION_KEY_ALL_USERS:
 		if (!ll_sbi_has_encrypt(ll_i2sbi(inode)))
 			return -EOPNOTSUPP;
-		return llcrypt_ioctl_remove_key_all_users(file,
+		return fscrypt_ioctl_remove_key_all_users(file,
 							  (void __user *)arg);
 	case FS_IOC_GET_ENCRYPTION_KEY_STATUS:
 		if (!ll_sbi_has_encrypt(ll_i2sbi(inode)))
 			return -EOPNOTSUPP;
-		return llcrypt_ioctl_get_key_status(file, (void __user *)arg);
+		return fscrypt_ioctl_get_key_status(file, (void __user *)arg);
 #endif
 
 	case LL_IOC_UNLOCK_FOREIGN: {
@@ -4551,10 +4551,10 @@ int ll_migrate(struct inode *parent, struct file *file, struct lmv_user_md *lum,
 	}
 
 	if (IS_ENCRYPTED(child_inode)) {
-		rc = llcrypt_get_encryption_info(child_inode);
+		rc = fscrypt_get_encryption_info(child_inode);
 		if (rc)
 			goto out_iput;
-		if (!llcrypt_has_encryption_key(child_inode)) {
+		if (!fscrypt_has_encryption_key(child_inode)) {
 			CDEBUG(D_SEC, "no enc key for "DFID"\n",
 			       PFID(ll_inode2fid(child_inode)));
 			rc = -ENOKEY;
diff --git a/fs/lustre/llite/llite_internal.h b/fs/lustre/llite/llite_internal.h
index b3e8a96..03d2796 100644
--- a/fs/lustre/llite/llite_internal.h
+++ b/fs/lustre/llite/llite_internal.h
@@ -1681,25 +1681,9 @@ static inline struct pcc_super *ll_info2pccs(struct ll_inode_info *lli)
 	return ll_i2pccs(ll_info2i(lli));
 }
 
-#ifdef CONFIG_FS_ENCRYPTION
 /* crypto.c */
-extern const struct llcrypt_operations lustre_cryptops;
-
-#else /* !CONFIG_FS_ENCRYPTION */
-inline bool ll_sbi_has_test_dummy_encryption(struct ll_sb_info *sbi)
-{
-	return false;
-}
+extern const struct fscrypt_operations lustre_cryptops;
 
-inline bool ll_sbi_has_encrypt(struct ll_sb_info *sbi)
-{
-	return false;
-}
-
-inline void ll_sbi_set_encrypt(struct ll_sb_info *sbi, bool set)
-{
-}
-#endif /* !CONFIG_FS_ENCRYPTION */
 /* llite/llite_foreign.c */
 int ll_manage_foreign(struct inode *inode, struct lustre_md *lmd);
 bool ll_foreign_is_openable(struct dentry *dentry, unsigned int flags);
diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index 1b3eef0..ada2b625c 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -616,8 +616,8 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt)
 #if THREAD_SIZE >= 8192 /*b=17630*/
 	sb->s_export_op = &lustre_export_operations;
 #endif
-	llcrypt_set_ops(sb, &lustre_cryptops);
 
+	fscrypt_set_ops(sb, &lustre_cryptops);
 	/* make root inode
 	 * XXX: move this to after cbd setup?
 	 */
@@ -1682,7 +1682,7 @@ void ll_clear_inode(struct inode *inode)
 	 */
 	cl_inode_fini(inode);
 
-	llcrypt_put_encryption_info(inode);
+	fscrypt_put_encryption_info(inode);
 }
 
 static int ll_md_setattr(struct dentry *dentry, struct md_op_data *op_data)
@@ -2140,7 +2140,7 @@ int ll_setattr(struct dentry *de, struct iattr *attr)
 	enum op_xvalid xvalid = 0;
 	int rc;
 
-	rc = llcrypt_prepare_setattr(de, attr);
+	rc = fscrypt_prepare_setattr(de, attr);
 	if (rc)
 		return rc;
 
diff --git a/fs/lustre/llite/namei.c b/fs/lustre/llite/namei.c
index 2da33d0..658da49 100644
--- a/fs/lustre/llite/namei.c
+++ b/fs/lustre/llite/namei.c
@@ -674,7 +674,7 @@ static int ll_lookup_it_finish(struct ptlrpc_request *request,
 					      ll_i2sbi(inode)->ll_fsname,
 					      PFID(ll_inode2fid(inode)), rc);
 				} else if (encrypt) {
-					rc = llcrypt_get_encryption_info(inode);
+					rc = fscrypt_get_encryption_info(inode);
 					if (rc)
 						CDEBUG(D_SEC,
 						       "cannot get enc info for " DFID ": rc = %d\n",
@@ -744,10 +744,10 @@ static int ll_lookup_it_finish(struct ptlrpc_request *request,
 			d_lustre_revalidate(*de);
 
 		if (encrypt) {
-			rc = llcrypt_get_encryption_info(inode);
+			rc = fscrypt_get_encryption_info(inode);
 			if (rc)
 				goto out;
-			if (!llcrypt_has_encryption_key(inode)) {
+			if (!fscrypt_has_encryption_key(inode)) {
 				rc = -ENOKEY;
 				goto out;
 			}
@@ -878,7 +878,7 @@ static struct dentry *ll_lookup_it(struct inode *parent, struct dentry *dentry,
 			*secctxlen = 0;
 	}
 	if (it->it_op & IT_CREAT && encrypt) {
-		rc = llcrypt_inherit_context(parent, NULL, op_data, false);
+		rc = fscrypt_inherit_context(parent, NULL, op_data, false);
 		if (rc) {
 			retval = ERR_PTR(rc);
 			goto out;
@@ -1134,11 +1134,11 @@ static int ll_atomic_open(struct inode *dir, struct dentry *dentry,
 		/* in case of create, this is going to be a regular file because
 		 * we set S_IFREG bit on it->it_create_mode above
 		 */
-		rc = llcrypt_get_encryption_info(dir);
+		rc = fscrypt_get_encryption_info(dir);
 		if (rc)
 			goto out_release;
 		if (open_flags & O_CREAT) {
-			if (!llcrypt_has_encryption_key(dir)) {
+			if (!fscrypt_has_encryption_key(dir)) {
 				rc = -ENOKEY;
 				goto out_release;
 			}
@@ -1390,11 +1390,11 @@ static int ll_new_node(struct inode *dir, struct dentry *dentry,
 	if (ll_sbi_has_encrypt(sbi) &&
 	    ((IS_ENCRYPTED(dir) &&
 	    (S_ISREG(mode) || S_ISDIR(mode) || S_ISLNK(mode))) ||
-	    (unlikely(llcrypt_dummy_context_enabled(dir)) && S_ISDIR(mode)))) {
-		err = llcrypt_get_encryption_info(dir);
+	    (unlikely(fscrypt_dummy_context_enabled(dir)) && S_ISDIR(mode)))) {
+		err = fscrypt_get_encryption_info(dir);
 		if (err)
 			goto err_exit;
-		if (!llcrypt_has_encryption_key(dir)) {
+		if (!fscrypt_has_encryption_key(dir)) {
 			err = -ENOKEY;
 			goto err_exit;
 		}
@@ -1402,7 +1402,7 @@ static int ll_new_node(struct inode *dir, struct dentry *dentry,
 	}
 
 	if (encrypt) {
-		err = llcrypt_inherit_context(dir, NULL, op_data, false);
+		err = fscrypt_inherit_context(dir, NULL, op_data, false);
 		if (err)
 			goto err_exit;
 	}
@@ -1504,7 +1504,7 @@ static int ll_new_node(struct inode *dir, struct dentry *dentry,
 	d_instantiate(dentry, inode);
 
 	if (encrypt) {
-		err = llcrypt_inherit_context(dir, inode, NULL, true);
+		err = fscrypt_inherit_context(dir, inode, NULL, true);
 		if (err)
 			goto err_exit;
 	}
@@ -1740,7 +1740,7 @@ static int ll_link(struct dentry *old_dentry, struct inode *dir,
 	       PFID(ll_inode2fid(src)), src, PFID(ll_inode2fid(dir)), dir,
 	       new_dentry);
 
-	err = llcrypt_prepare_link(old_dentry, dir, new_dentry);
+	err = fscrypt_prepare_link(old_dentry, dir, new_dentry);
 	if (err)
 		return err;
 
@@ -1785,7 +1785,7 @@ static int ll_rename(struct inode *src, struct dentry *src_dchild,
 	if (unlikely(d_mountpoint(src_dchild) || d_mountpoint(tgt_dchild)))
 		return -EBUSY;
 
-	err = llcrypt_prepare_rename(src, src_dchild, tgt, tgt_dchild, flags);
+	err = fscrypt_prepare_rename(src, src_dchild, tgt, tgt_dchild, flags);
 	if (err)
 		return err;
 
diff --git a/fs/lustre/llite/super25.c b/fs/lustre/llite/super25.c
index decfa2f..f50c23a 100644
--- a/fs/lustre/llite/super25.c
+++ b/fs/lustre/llite/super25.c
@@ -63,7 +63,7 @@ static void ll_inode_destroy_callback(struct rcu_head *head)
 	struct inode *inode = container_of(head, struct inode, i_rcu);
 	struct ll_inode_info *ptr = ll_i2info(inode);
 
-	llcrypt_free_inode(inode);
+	fscrypt_free_inode(inode);
 	kmem_cache_free(ll_inode_cachep, ptr);
 }
 
@@ -77,7 +77,7 @@ static int ll_drop_inode(struct inode *inode)
 	int drop = generic_drop_inode(inode);
 
 	if (!drop)
-		drop = llcrypt_drop_inode(inode);
+		drop = fscrypt_drop_inode(inode);
 
 	return drop;
 }
diff --git a/fs/lustre/osc/osc_request.c b/fs/lustre/osc/osc_request.c
index e49d73f..0d590ed 100644
--- a/fs/lustre/osc/osc_request.c
+++ b/fs/lustre/osc/osc_request.c
@@ -1371,11 +1371,11 @@ static inline void osc_release_bounce_pages(struct brw_page **pga,
 
 	for (i = 0; i < page_count; i++) {
 		/* Bounce pages allocated by a call to
-		 * llcrypt_encrypt_pagecache_blocks() in osc_brw_prep_request()
+		 * fscrypt_encrypt_pagecache_blocks() in osc_brw_prep_request()
 		 * are identified thanks to the PageChecked flag.
 		 */
 		if (PageChecked(pga[i]->pg))
-			llcrypt_finalize_bounce_page(&pga[i]->pg);
+			fscrypt_finalize_bounce_page(&pga[i]->pg);
 		pga[i]->count -= pga[i]->bp_count_diff;
 		pga[i]->off += pga[i]->bp_off_diff;
 	}
@@ -1463,7 +1463,7 @@ static int osc_brw_prep_request(int cmd, struct client_obd *cli,
 				pg->pg->index = pg->off >> PAGE_SHIFT;
 			}
 			data_page =
-				llcrypt_encrypt_pagecache_blocks(pg->pg,
+				fscrypt_encrypt_pagecache_blocks(pg->pg,
 								 nunits, 0,
 								 GFP_NOFS);
 			if (directio) {
@@ -2145,7 +2145,7 @@ static int osc_brw_fini_request(struct ptlrpc_request *req, int rc)
 	if (inode && IS_ENCRYPTED(inode)) {
 		int idx;
 
-		if (!llcrypt_has_encryption_key(inode)) {
+		if (!fscrypt_has_encryption_key(inode)) {
 			CDEBUG(D_SEC, "no enc key for ino %lu\n", inode->i_ino);
 			goto out;
 		}
@@ -2181,7 +2181,7 @@ static int osc_brw_fini_request(struct ptlrpc_request *req, int rc)
 					for (i = offs;
 					     i < offs + LUSTRE_ENCRYPTION_UNIT_SIZE;
 					     i += blocksize, lblk_num++) {
-						rc = llcrypt_decrypt_block_inplace(inode,
+						rc = fscrypt_decrypt_block_inplace(inode,
 										   pg->pg,
 										   blocksize, i,
 										   lblk_num);
@@ -2189,7 +2189,7 @@ static int osc_brw_fini_request(struct ptlrpc_request *req, int rc)
 							break;
 					}
 				} else {
-					rc = llcrypt_decrypt_pagecache_blocks(pg->pg,
+					rc = fscrypt_decrypt_pagecache_blocks(pg->pg,
 									      LUSTRE_ENCRYPTION_UNIT_SIZE,
 									      offs);
 				}
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
