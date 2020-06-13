From: James Simmons <jsimmons@infradead.org>
Date: Sat, 13 Jun 2020 12:27:08 -0400
Subject: [lustre-devel] [PATCH 12/20] lustre: sec: enable client side
 encryption
In-Reply-To: <1592065636-28333-1-git-send-email-jsimmons@infradead.org>
References: <1592065636-28333-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1592065636-28333-13-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Sebastien Buisson <sbuisson@ddn.com>

Enable client side encryption. By default it is activated,
letting user specifies actual encryption policy to use on
a per-directory basis. It is possible to deactivate client
side encryption by using the 'noencrypt' mount option.

Also add the test dummy encryption mode option to ease
testing.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12275
Lustre-commit: 28be31137cd22 ("LU-12275 sec: enable client side encryption")
Signed-off-by: Sebastien Buisson <sbuisson@ddn.com>
Reviewed-on: https://review.whamcloud.com/36143
Reviewed-by: John L. Hammond <jhammond@whamcloud.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_crypto.h      | 106 ++++++++++++++++++++++++++
 fs/lustre/include/obd_support.h        |   6 ++
 fs/lustre/llite/Makefile               |   1 +
 fs/lustre/llite/crypto.c               | 132 +++++++++++++++++++++++++++++++++
 fs/lustre/llite/llite_internal.h       |  26 +++++++
 fs/lustre/llite/llite_lib.c            |  33 +++++++++
 fs/lustre/llite/super25.c              |   1 +
 include/uapi/linux/lustre/lustre_idl.h |  12 +++
 8 files changed, 317 insertions(+)
 create mode 100644 fs/lustre/include/lustre_crypto.h
 create mode 100644 fs/lustre/llite/crypto.c

diff --git a/fs/lustre/include/lustre_crypto.h b/fs/lustre/include/lustre_crypto.h
new file mode 100644
index 0000000..e9091a2
--- /dev/null
+++ b/fs/lustre/include/lustre_crypto.h
@@ -0,0 +1,106 @@
+// SPDX-License-Identifier: GPL-2.0
+/*
+ * GPL HEADER START
+ *
+ * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 only,
+ * as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License version 2 for more details (a copy is included
+ * in the LICENSE file that accompanied this code).
+ *
+ * You should have received a copy of the GNU General Public License
+ * version 2 along with this program; If not, see
+ * http://www.gnu.org/licenses/gpl-2.0.html
+ *
+ * GPL HEADER END
+ */
+/*
+ * Copyright (c) 2019, 2020, Whamcloud.
+ */
+/*
+ * This file is part of Lustre, http://www.lustre.org/
+ */
+
+#ifndef _LUSTRE_CRYPTO_H_
+#define _LUSTRE_CRYPTO_H_
+
+struct ll_sb_info;
+bool ll_sbi_has_test_dummy_encryption(struct ll_sb_info *sbi);
+bool ll_sbi_has_encrypt(struct ll_sb_info *sbi);
+void ll_sbi_set_encrypt(struct ll_sb_info *sbi, bool set);
+
+#ifdef CONFIG_FS_ENCRYPTION
+#define __FS_HAS_ENCRYPTION 1
+#include <linux/fscrypt.h>
+
+#define llcrypt_operations	fscrypt_operations
+#define llcrypt_symlink_data	fscrypt_symlink_data
+#define llcrypt_dummy_context_enabled(inode) \
+	fscrypt_dummy_context_enabled(inode)
+#define llcrypt_has_encryption_key(inode) fscrypt_has_encryption_key(inode)
+#define llcrypt_encrypt_pagecache_blocks(page, len, offs, gfp_flags)	\
+	fscrypt_encrypt_pagecache_blocks(page, len, offs, gfp_flags)
+#define llcrypt_decrypt_pagecache_blocks(page, len, offs)	\
+	fscrypt_decrypt_pagecache_blocks(page, len, offs)
+#define llcrypt_inherit_context(parent, child, fs_data, preload)	\
+	fscrypt_inherit_context(parent, child, fs_data, preload)
+#define llcrypt_get_encryption_info(inode) fscrypt_get_encryption_info(inode)
+#define llcrypt_put_encryption_info(inode) fscrypt_put_encryption_info(inode)
+#define llcrypt_free_inode(inode)	   fscrypt_free_inode(inode)
+#define llcrypt_finalize_bounce_page(pagep)  fscrypt_finalize_bounce_page(pagep)
+#define llcrypt_file_open(inode, filp)	fscrypt_file_open(inode, filp)
+#define llcrypt_ioctl_set_policy(filp, arg)  fscrypt_ioctl_set_policy(filp, arg)
+#define llcrypt_ioctl_get_policy_ex(filp, arg)	\
+	fscrypt_ioctl_get_policy_ex(filp, arg)
+#define llcrypt_ioctl_add_key(filp, arg)	fscrypt_ioctl_add_key(filp, arg)
+#define llcrypt_ioctl_remove_key(filp, arg)  fscrypt_ioctl_remove_key(filp, arg)
+#define llcrypt_ioctl_remove_key_all_users(filp, arg)	\
+	fscrypt_ioctl_remove_key_all_users(filp, arg)
+#define llcrypt_ioctl_get_key_status(filp, arg)	\
+	fscrypt_ioctl_get_key_status(filp, arg)
+#define llcrypt_drop_inode(inode)	fscrypt_drop_inode(inode)
+#define llcrypt_prepare_rename(olddir, olddentry, newdir, newdentry, flags) \
+	fscrypt_prepare_rename(olddir, olddentry, newdir, newdentry, flags)
+#define llcrypt_prepare_link(old_dentry, dir, dentry)	\
+	fscrypt_prepare_link(old_dentry, dir, dentry)
+#define llcrypt_prepare_setattr(dentry, attr)		\
+	fscrypt_prepare_setattr(dentry, attr)
+#define llcrypt_set_ops(sb, cop)	fscrypt_set_ops(sb, cop)
+#else /* !CONFIG_FS_ENCRYPTION */
+#undef IS_ENCRYPTED
+#define IS_ENCRYPTED(x)	0
+#define llcrypt_dummy_context_enabled(inode)	NULL
+/* copied from include/linux/fscrypt.h */
+#define llcrypt_has_encryption_key(inode) false
+#define llcrypt_encrypt_pagecache_blocks(page, len, offs, gfp_flags)	\
+	ERR_PTR(-EOPNOTSUPP)
+#define llcrypt_decrypt_pagecache_blocks(page, len, offs)	-EOPNOTSUPP
+#define llcrypt_inherit_context(parent, child, fs_data, preload)     -EOPNOTSUPP
+#define llcrypt_get_encryption_info(inode)			-EOPNOTSUPP
+#define llcrypt_put_encryption_info(inode)			do {} while (0)
+#define llcrypt_free_inode(inode)				do {} while (0)
+#define llcrypt_finalize_bounce_page(pagep)			do {} while (0)
+static inline int llcrypt_file_open(struct inode *inode, struct file *filp)
+{
+	return IS_ENCRYPTED(inode) ? -EOPNOTSUPP : 0;
+}
+#define llcrypt_ioctl_set_policy(filp, arg)			-EOPNOTSUPP
+#define llcrypt_ioctl_get_policy_ex(filp, arg)			-EOPNOTSUPP
+#define llcrypt_ioctl_add_key(filp, arg)			-EOPNOTSUPP
+#define llcrypt_ioctl_remove_key(filp, arg)			-EOPNOTSUPP
+#define llcrypt_ioctl_remove_key_all_users(filp, arg)		-EOPNOTSUPP
+#define llcrypt_ioctl_get_key_status(filp, arg)			-EOPNOTSUPP
+#define llcrypt_drop_inode(inode)				 0
+#define llcrypt_prepare_rename(olddir, olddentry, newdir, newdentry, flags)    0
+#define llcrypt_prepare_link(old_dentry, dir, dentry)		 0
+#define llcrypt_prepare_setattr(dentry, attr)			 0
+#define llcrypt_set_ops(sb, cop)				do {} while (0)
+#endif /* CONFIG_FS_ENCRYPTION */
+
+#endif /* _LUSTRE_CRYPTO_H_ */
diff --git a/fs/lustre/include/obd_support.h b/fs/lustre/include/obd_support.h
index d1d21e0..b5736f8 100644
--- a/fs/lustre/include/obd_support.h
+++ b/fs/lustre/include/obd_support.h
@@ -559,6 +559,9 @@ static inline int ll_ext_to_inode_flags(int flags)
 		((flags & LUSTRE_NOATIME_FL)   ? S_NOATIME   : 0) |
 		((flags & LUSTRE_APPEND_FL)    ? S_APPEND    : 0) |
 		((flags & LUSTRE_DIRSYNC_FL)   ? S_DIRSYNC   : 0) |
+#if defined(S_ENCRYPTED)
+		((flags & LUSTRE_ENCRYPT_FL)   ? S_ENCRYPTED : 0) |
+#endif
 		((flags & LUSTRE_IMMUTABLE_FL) ? S_IMMUTABLE : 0));
 }
 
@@ -568,6 +571,9 @@ static inline int ll_inode_to_ext_flags(int iflags)
 		((iflags & S_NOATIME)   ? LUSTRE_NOATIME_FL   : 0) |
 		((iflags & S_APPEND)    ? LUSTRE_APPEND_FL    : 0) |
 		((iflags & S_DIRSYNC)   ? LUSTRE_DIRSYNC_FL   : 0) |
+#if defined(S_ENCRYPTED)
+		((iflags & S_ENCRYPTED) ? LUSTRE_ENCRYPT_FL   : 0) |
+#endif
 		((iflags & S_IMMUTABLE) ? LUSTRE_IMMUTABLE_FL : 0));
 }
 
diff --git a/fs/lustre/llite/Makefile b/fs/lustre/llite/Makefile
index c88a1b0..aa388bb6 100644
--- a/fs/lustre/llite/Makefile
+++ b/fs/lustre/llite/Makefile
@@ -10,3 +10,4 @@ lustre-y := dcache.o dir.o file.o llite_lib.o llite_nfs.o \
 	    lproc_llite.o pcc.o
 
 lustre-$(CONFIG_LUSTRE_FS_POSIX_ACL) += acl.o
+lustre-$(CONFIG_FS_ENCRYPTION)	     += crypto.o
diff --git a/fs/lustre/llite/crypto.c b/fs/lustre/llite/crypto.c
new file mode 100644
index 0000000..94189c9
--- /dev/null
+++ b/fs/lustre/llite/crypto.c
@@ -0,0 +1,132 @@
+// SPDX-License-Identifier: GPL-2.0
+/*
+ * GPL HEADER START
+ *
+ * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 only,
+ * as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License version 2 for more details (a copy is included
+ * in the LICENSE file that accompanied this code).
+ *
+ * You should have received a copy of the GNU General Public License
+ * version 2 along with this program; If not, see
+ * http://www.gnu.org/licenses/gpl-2.0.html
+ *
+ * GPL HEADER END
+ */
+/*
+ * Copyright (c) 2019, 2020, Whamcloud.
+ */
+/*
+ * This file is part of Lustre, http://www.lustre.org/
+ */
+
+#include "llite_internal.h"
+
+static int ll_get_context(struct inode *inode, void *ctx, size_t len)
+{
+	struct dentry *dentry;
+
+	if (hlist_empty(&inode->i_dentry))
+		return -ENODATA;
+
+	hlist_for_each_entry(dentry, &inode->i_dentry, d_u.d_alias)
+		break;
+
+	return __vfs_getxattr(dentry, inode, LL_XATTR_NAME_ENCRYPTION_CONTEXT,
+			      ctx, len);
+}
+
+static int ll_set_context(struct inode *inode, const void *ctx, size_t len,
+			  void *fs_data)
+{
+	unsigned int ext_flags;
+	struct dentry *dentry;
+	struct md_op_data *op_data;
+	struct ptlrpc_request *req = NULL;
+	int rc;
+
+	if (inode == NULL)
+		return 0;
+
+	ext_flags = ll_inode_to_ext_flags(inode->i_flags) | LUSTRE_ENCRYPT_FL;
+	dentry = (struct dentry *)fs_data;
+
+	/* Encrypting the root directory is not allowed */
+	if (inode->i_ino == inode->i_sb->s_root->d_inode->i_ino)
+		return -EPERM;
+
+	op_data = ll_prep_md_op_data(NULL, inode, NULL, NULL, 0, 0,
+				     LUSTRE_OPC_ANY, NULL);
+	if (IS_ERR(op_data))
+		return PTR_ERR(op_data);
+
+	op_data->op_attr_flags = LUSTRE_ENCRYPT_FL;
+	op_data->op_xvalid |= OP_XVALID_FLAGS;
+	rc = md_setattr(ll_i2sbi(inode)->ll_md_exp, op_data, NULL, 0, &req);
+	ll_finish_md_op_data(op_data);
+	ptlrpc_req_finished(req);
+	if (rc)
+		return rc;
+
+	rc = __vfs_setxattr(dentry, inode, LL_XATTR_NAME_ENCRYPTION_CONTEXT,
+			    ctx, len, XATTR_CREATE);
+	if (rc)
+		return rc;
+
+	ll_update_inode_flags(inode, ext_flags);
+	return 0;
+}
+
+inline bool ll_sbi_has_test_dummy_encryption(struct ll_sb_info *sbi)
+{
+	return unlikely(sbi->ll_flags & LL_SBI_TEST_DUMMY_ENCRYPTION);
+}
+
+static bool ll_dummy_context(struct inode *inode)
+{
+	struct ll_sb_info *sbi = ll_i2sbi(inode);
+
+	return sbi ? ll_sbi_has_test_dummy_encryption(sbi) : false;
+}
+
+inline bool ll_sbi_has_encrypt(struct ll_sb_info *sbi)
+{
+	return sbi->ll_flags & LL_SBI_ENCRYPT;
+}
+
+inline void ll_sbi_set_encrypt(struct ll_sb_info *sbi, bool set)
+{
+	if (set)
+		sbi->ll_flags |= LL_SBI_ENCRYPT;
+	else
+		sbi->ll_flags &=
+			~(LL_SBI_ENCRYPT | LL_SBI_TEST_DUMMY_ENCRYPTION);
+}
+
+static bool ll_empty_dir(struct inode *inode)
+{
+	/* used by llcrypt_ioctl_set_policy(), because a policy can only be set
+	 * on an empty dir.
+	 */
+	/* Here we choose to return true, meaning we always call .set_context.
+	 * Then we rely on server side, with mdd_fix_attr() that calls
+	 * mdd_dir_is_empty() when setting encryption flag on directory.
+	 */
+	return true;
+}
+
+const struct llcrypt_operations lustre_cryptops = {
+	.key_prefix		= "lustre:",
+	.get_context		= ll_get_context,
+	.set_context		= ll_set_context,
+	.dummy_context		= ll_dummy_context,
+	.empty_dir		= ll_empty_dir,
+	.max_namelen		= NAME_MAX,
+};
diff --git a/fs/lustre/llite/llite_internal.h b/fs/lustre/llite/llite_internal.h
index be3a0b0..96585a7 100644
--- a/fs/lustre/llite/llite_internal.h
+++ b/fs/lustre/llite/llite_internal.h
@@ -44,9 +44,11 @@
 #include <lustre_mdc.h>
 #include <lustre_intent.h>
 #include <linux/compat.h>
+#include <lustre_crypto.h>
 #include <linux/namei.h>
 #include <linux/xattr.h>
 #include <linux/posix_acl_xattr.h>
+
 #include "vvp_internal.h"
 #include "range_lock.h"
 #include "pcc.h"
@@ -551,6 +553,8 @@ enum stats_track_type {
 					  */
 #define LL_SBI_TINY_WRITE	0x2000000 /* tiny write support */
 #define LL_SBI_FILE_HEAT    0x4000000 /* file heat support */
+#define LL_SBI_TEST_DUMMY_ENCRYPTION	0x8000000 /* test dummy encryption */
+#define LL_SBI_ENCRYPT	   0x10000000 /* client side encryption */
 #define LL_SBI_FLAGS {	\
 	"nolck",	\
 	"checksum",	\
@@ -579,6 +583,8 @@ enum stats_track_type {
 	"pio",		\
 	"tiny_write",	\
 	"file_heat",	\
+	"test_dummy_encryption", \
+	"noencrypt",	\
 }
 
 /*
@@ -1578,4 +1584,24 @@ static inline struct pcc_super *ll_info2pccs(struct ll_inode_info *lli)
 	return ll_i2pccs(ll_info2i(lli));
 }
 
+#ifdef CONFIG_FS_ENCRYPTION
+/* crypto.c */
+extern const struct llcrypt_operations lustre_cryptops;
+
+#else /* !CONFIG_FS_ENCRYPTION */
+inline bool ll_sbi_has_test_dummy_encryption(struct ll_sb_info *sbi)
+{
+	return false;
+}
+
+inline bool ll_sbi_has_encrypt(struct ll_sb_info *sbi)
+{
+	return false;
+}
+
+inline void ll_sbi_set_encrypt(struct ll_sb_info *sbi, bool set)
+{
+}
+#endif /* !CONFIG_FS_ENCRYPTION */
+
 #endif /* LLITE_INTERNAL_H */
diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index 05d949b..5639b16 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -155,6 +155,7 @@ static struct ll_sb_info *ll_init_sbi(void)
 	sbi->ll_flags |= LL_SBI_AGL_ENABLED;
 	sbi->ll_flags |= LL_SBI_FAST_READ;
 	sbi->ll_flags |= LL_SBI_TINY_WRITE;
+	ll_sbi_set_encrypt(sbi, true);
 
 	/* root squash */
 	sbi->ll_squash.rsi_uid = 0;
@@ -551,6 +552,7 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt)
 #if THREAD_SIZE >= 8192 /*b=17630*/
 	sb->s_export_op = &lustre_export_operations;
 #endif
+	llcrypt_set_ops(sb, &lustre_cryptops);
 
 	/* make root inode
 	 * XXX: move this to after cbd setup?
@@ -923,6 +925,25 @@ static int ll_options(char *options, struct ll_sb_info *sbi)
 			*flags |= tmp;
 			goto next;
 		}
+		tmp = ll_set_opt("test_dummy_encryption", s1,
+				 LL_SBI_TEST_DUMMY_ENCRYPTION);
+		if (tmp) {
+#ifdef CONFIG_FS_ENCRYPTION
+			*flags |= tmp;
+#else
+			LCONSOLE_WARN("Test dummy encryption mount option ignored: encryption not supported\n");
+#endif
+			goto next;
+		}
+		tmp = ll_set_opt("noencrypt", s1, LL_SBI_ENCRYPT);
+		if (tmp) {
+#ifdef CONFIG_FS_ENCRYPTION
+			*flags &= ~tmp;
+#else
+			LCONSOLE_WARN("noencrypt mount option ignored: encryption not supported\n");
+#endif
+			goto next;
+		}
 		LCONSOLE_ERROR_MSG(0x152, "Unknown option '%s', won't mount.\n",
 				   s1);
 		return -EINVAL;
@@ -1558,6 +1579,8 @@ void ll_clear_inode(struct inode *inode)
 	 * cl_object still uses inode lsm.
 	 */
 	cl_inode_fini(inode);
+
+	llcrypt_put_encryption_info(inode);
 }
 
 static int ll_md_setattr(struct dentry *dentry, struct md_op_data *op_data)
@@ -1978,6 +2001,8 @@ void ll_update_inode_flags(struct inode *inode, int ext_flags)
 {
 	struct ll_inode_info *lli = ll_i2info(inode);
 
+	/* do not clear encryption flag */
+	ext_flags |= ll_inode_to_ext_flags(inode->i_flags) & LUSTRE_ENCRYPT_FL;
 	inode->i_flags = ll_ext_to_inode_flags(ext_flags);
 	if (ext_flags & LUSTRE_PROJINHERIT_FL)
 		set_bit(LLIF_PROJECT_INHERIT, &lli->lli_flags);
@@ -2702,6 +2727,14 @@ int ll_show_options(struct seq_file *seq, struct dentry *dentry)
 	if (sbi->ll_flags & LL_SBI_ALWAYS_PING)
 		seq_puts(seq, ",always_ping");
 
+	if (ll_sbi_has_test_dummy_encryption(sbi))
+		seq_puts(seq, ",test_dummy_encryption");
+
+	if (ll_sbi_has_encrypt(sbi))
+		seq_puts(seq, ",encrypt");
+	else
+		seq_puts(seq, ",noencrypt");
+
 	return 0;
 }
 
diff --git a/fs/lustre/llite/super25.c b/fs/lustre/llite/super25.c
index 006be6b..8eb3fc3 100644
--- a/fs/lustre/llite/super25.c
+++ b/fs/lustre/llite/super25.c
@@ -63,6 +63,7 @@ static void ll_inode_destroy_callback(struct rcu_head *head)
 	struct inode *inode = container_of(head, struct inode, i_rcu);
 	struct ll_inode_info *ptr = ll_i2info(inode);
 
+	llcrypt_free_inode(inode);
 	kmem_cache_free(ll_inode_cachep, ptr);
 }
 
diff --git a/include/uapi/linux/lustre/lustre_idl.h b/include/uapi/linux/lustre/lustre_idl.h
index d0b43c8..d4df989 100644
--- a/include/uapi/linux/lustre/lustre_idl.h
+++ b/include/uapi/linux/lustre/lustre_idl.h
@@ -1108,6 +1108,8 @@ struct lov_mds_md_v1 {		/* LOV EA mds/wire data (little-endian) */
 #define XATTR_NAME_HSM		"trusted.hsm"
 #define XATTR_NAME_LFSCK_NAMESPACE "trusted.lfsck_namespace"
 
+#define LL_XATTR_NAME_ENCRYPTION_CONTEXT XATTR_SECURITY_PREFIX"c"
+
 struct lov_mds_md_v3 {		/* LOV EA mds/wire data (little-endian) */
 	__u32 lmm_magic;	/* magic number = LOV_MAGIC_V3 */
 	__u32 lmm_pattern;	/* LOV_PATTERN_RAID0, LOV_PATTERN_RAID1 */
@@ -1571,6 +1573,16 @@ enum {
 	LUSTRE_TOPDIR_FL	= 0x00020000, /* Top of directory hierarchies*/
 	LUSTRE_INLINE_DATA_FL	= 0x10000000, /* Inode has inline data. */
 	LUSTRE_PROJINHERIT_FL	= 0x20000000, /* Create with parents projid */
+
+	/* These flags will not be identical to any EXT4_*_FL counterparts,
+	 * and only reserved for lustre purpose. Note: these flags might
+	 * be conflict with some of EXT4 flags, so
+	 * 1. these conflict flags needs to be removed when the flag is
+	 * wired by la_flags see osd_attr_get().
+	 * 2. If these flags needs to be stored into inode, they will be
+	 * stored in LMA. see LMAI_XXXX
+	 */
+	LUSTRE_ENCRYPT_FL       = 0x00800000, /* encrypted file */
 };
 
 /* 64 possible states */
-- 
1.8.3.1
