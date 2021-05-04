Return-Path: <SRS0=WSMT=J7=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.7 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E84FBC433ED
	for <lustre-devel@archiver.kernel.org>; Tue,  4 May 2021 00:10:58 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 30BC161185
	for <lustre-devel@archiver.kernel.org>; Tue,  4 May 2021 00:10:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 30BC161185
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id A26B821F832;
	Mon,  3 May 2021 17:10:41 -0700 (PDT)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 810AA21F6A8
 for <lustre-devel@lists.lustre.org>; Mon,  3 May 2021 17:10:25 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 44BC7EE6;
 Mon,  3 May 2021 20:10:20 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 420D58AD3D; Mon,  3 May 2021 20:10:20 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon,  3 May 2021 20:10:15 -0400
Message-Id: <1620087016-17857-14-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1620087016-17857-1-git-send-email-jsimmons@infradead.org>
References: <1620087016-17857-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 13/14] lustre: llite: fake symlink type of
 foreign file/dir
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

From: Bruno Faccini <bruno.faccini@intel.com>

This patch implements a "fake symlink" specific usage of
"foreign" LOV/LMV format. It basically allows these
particular type of foreign files/dirs to behave as a
symlink from VFS point of view, by allowing to construct
a relative path from the LOV/LMV foreign content, to
complement it with a prefix, and then to expose it to
the VFS as a symlink destination. The default/internal
mechanism simply takes the full foreign free string as
the relative path, and for more complex internal formats
an upcall has been implemented to provide format's
details (presently just in terms of constant strings
and substrings positions in EA, but this can be enhanced)
to llite layer.
Using this feature, instead of real symlinks or user EA,
will permit to benefit from the special features (lock,
prefetch, caches) already implemented to handle both
LOV/LMV EAs.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12682
Lustre-commit: 15d44e787e17ff5 ("LU-12682 llite: fake symlink type of foreign file/dir")
Signed-off-by: Bruno Faccini <bruno.faccini@intel.com>
Reviewed-on: https://review.whamcloud.com/35856
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Ben Evans <beevans@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/Makefile                |   1 +
 fs/lustre/llite/dcache.c                |  14 +-
 fs/lustre/llite/dir.c                   |  11 +
 fs/lustre/llite/file.c                  |  50 ++-
 fs/lustre/llite/foreign_symlink.h       |  49 +++
 fs/lustre/llite/llite_foreign.c         | 284 ++++++++++++
 fs/lustre/llite/llite_foreign_symlink.c | 758 ++++++++++++++++++++++++++++++++
 fs/lustre/llite/llite_internal.h        |  35 +-
 fs/lustre/llite/llite_lib.c             | 105 +++++
 fs/lustre/llite/lproc_llite.c           |  12 +
 fs/lustre/llite/namei.c                 |  33 +-
 fs/lustre/llite/pcc.c                   |   4 +-
 fs/lustre/llite/symlink.c               |   1 +
 fs/lustre/lov/lov_object.c              |   3 +-
 fs/lustre/lov/lov_pack.c                |  13 +-
 include/uapi/linux/lustre/lustre_user.h |  49 ++-
 16 files changed, 1399 insertions(+), 23 deletions(-)
 create mode 100644 fs/lustre/llite/foreign_symlink.h
 create mode 100644 fs/lustre/llite/llite_foreign.c
 create mode 100644 fs/lustre/llite/llite_foreign_symlink.c

diff --git a/fs/lustre/llite/Makefile b/fs/lustre/llite/Makefile
index 3bad19c..c83d98c 100644
--- a/fs/lustre/llite/Makefile
+++ b/fs/lustre/llite/Makefile
@@ -7,6 +7,7 @@ lustre-y := dcache.o dir.o file.o llite_lib.o llite_nfs.o \
 	    xattr.o xattr_cache.o xattr_security.o \
 	    super25.o statahead.o glimpse.o lcommon_cl.o lcommon_misc.o \
 	    vvp_dev.o vvp_page.o vvp_io.o vvp_object.o \
+	    llite_foreign.o llite_foreign_symlink.o \
 	    lproc_llite.o pcc.o
 
 lustre-$(CONFIG_LUSTRE_FS_POSIX_ACL) += acl.o
diff --git a/fs/lustre/llite/dcache.c b/fs/lustre/llite/dcache.c
index cf6619f..f8b82d6 100644
--- a/fs/lustre/llite/dcache.c
+++ b/fs/lustre/llite/dcache.c
@@ -248,8 +248,18 @@ static int ll_revalidate_dentry(struct dentry *dentry,
 		return 1;
 
 	/* Symlink - always valid as long as the dentry was found */
-	if (dentry->d_inode && S_ISLNK(dentry->d_inode->i_mode))
-		return 1;
+	/* only special case is to prevent ELOOP error from VFS during open
+	 * of a foreign symlink file/dir with O_NOFOLLOW, like it happens for
+	 * real symlinks. This will allow to open foreign symlink file/dir
+	 * for get[dir]stripe/unlock ioctl()s.
+	 */
+	if (dentry->d_inode && dentry->d_inode->i_op->get_link) {
+		if (!S_ISLNK(dentry->d_inode->i_mode) &&
+		    !(lookup_flags & LOOKUP_FOLLOW))
+			return 0;
+		else
+			return 1;
+	}
 
 	/*
 	 * VFS warns us that this is the second go around and previous
diff --git a/fs/lustre/llite/dir.c b/fs/lustre/llite/dir.c
index bf2d9fe..06ca329 100644
--- a/fs/lustre/llite/dir.c
+++ b/fs/lustre/llite/dir.c
@@ -1641,6 +1641,17 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 		ptlrpc_req_finished(root_request);
 		return rc;
 	}
+
+	case LL_IOC_UNLOCK_FOREIGN:
+		/* if not a foreign symlink do nothing */
+		if (ll_foreign_is_removable(dentry, true)) {
+			CDEBUG(D_INFO,
+			       "prevent rmdir of non-foreign dir ("DFID")\n",
+			       PFID(ll_inode2fid(inode)));
+			return -EOPNOTSUPP;
+		}
+		return 0;
+
 	case LL_IOC_RMFID:
 		return ll_rmfid(file, (void __user *)arg);
 	case LL_IOC_LOV_SWAP_LAYOUTS:
diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index 346e31c..78f3469 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -2342,12 +2342,12 @@ static int ll_lov_setstripe(struct inode *inode, struct file *file,
 		}
 
 		rc = cl_object_layout_get(env, obj, &cl);
-		if (!rc && cl.cl_is_composite)
+		if (rc >= 0 && cl.cl_is_composite)
 			rc = ll_layout_write_intent(inode, LAYOUT_INTENT_WRITE,
 						    &ext);
 
 		cl_env_put(env, &refcheck);
-		if (rc)
+		if (rc < 0)
 			goto out;
 	}
 
@@ -3001,7 +3001,7 @@ int ll_file_lock_ahead(struct file *file, struct llapi_lu_ladvise *ladvise)
 	CDEBUG(D_VFSTRACE,
 	       "Lock request: file=%pd, inode=%p, mode=%s start=%llu, end=%llu\n",
 	       dentry, dentry->d_inode,
-	       user_lockname[ladvise->lla_lockahead_mode], (__u64) start, end);
+	       user_lockname[ladvise->lla_lockahead_mode], (u64) start, end);
 
 	cl_mode = cl_mode_user_to_kernel(ladvise->lla_lockahead_mode);
 	if (cl_mode < 0) {
@@ -4086,6 +4086,20 @@ static int ll_heat_set(struct inode *inode, enum lu_heat_flag flags)
 			return -EOPNOTSUPP;
 		return llcrypt_ioctl_get_key_status(file, (void __user *)arg);
 #endif
+
+	case LL_IOC_UNLOCK_FOREIGN: {
+		struct dentry *dentry = file_dentry(file);
+
+		/* if not a foreign symlink do nothing */
+		if (ll_foreign_is_removable(dentry, true)) {
+			CDEBUG(D_INFO,
+			       "prevent unlink of non-foreign file ("DFID")\n",
+			       PFID(ll_inode2fid(inode)));
+			return -EOPNOTSUPP;
+		}
+		return 0;
+	}
+
 	default:
 		return obd_iocontrol(cmd, ll_i2dtexp(inode), 0, NULL,
 				     (void __user *)arg);
@@ -4842,10 +4856,9 @@ static int ll_merge_md_attr(struct inode *inode)
 	return 0;
 }
 
-int ll_getattr(const struct path *path, struct kstat *stat,
-	       u32 request_mask, unsigned int flags)
+int ll_getattr_dentry(struct dentry *de, struct kstat *stat, u32 request_mask,
+		      unsigned int flags, bool foreign)
 {
-	struct dentry *de = path->dentry;
 	struct inode *inode = d_inode(de);
 	struct ll_sb_info *sbi = ll_i2sbi(inode);
 	struct ll_inode_info *lli = ll_i2info(inode);
@@ -4872,7 +4885,10 @@ int ll_getattr(const struct path *path, struct kstat *stat,
 	if (rc < 0)
 		return rc;
 
-	if (S_ISREG(inode->i_mode)) {
+	/* foreign file/dir are always of zero length, so don't
+	 * need to validate size.
+	 */
+	if (S_ISREG(inode->i_mode) && !foreign) {
 		bool cached;
 
 		if (!need_glimpse)
@@ -4919,7 +4935,8 @@ int ll_getattr(const struct path *path, struct kstat *stat,
 		}
 	} else {
 		/* If object isn't regular a file then don't validate size. */
-		if (ll_dir_striped(inode)) {
+		/* foreign dir is not striped dir */
+		if (ll_dir_striped(inode) && !foreign) {
 			rc = ll_merge_md_attr(inode);
 			if (rc < 0)
 				return rc;
@@ -4948,7 +4965,13 @@ int ll_getattr(const struct path *path, struct kstat *stat,
 		stat->rdev = inode->i_rdev;
 		stat->ino = inode->i_ino;
 	}
-	stat->mode = inode->i_mode;
+
+	/* foreign symlink to be exposed as a real symlink */
+	if (!foreign)
+		stat->mode = inode->i_mode;
+	else
+		stat->mode = (inode->i_mode & ~S_IFMT) | S_IFLNK;
+
 	stat->uid = inode->i_uid;
 	stat->gid = inode->i_gid;
 	stat->atime = inode->i_atime;
@@ -4991,6 +5014,13 @@ int ll_getattr(const struct path *path, struct kstat *stat,
 	return 0;
 }
 
+int ll_getattr(const struct path *path, struct kstat *stat,
+	       u32 request_mask, unsigned int flags)
+{
+	return ll_getattr_dentry(path->dentry, stat, request_mask, flags,
+				 false);
+}
+
 int cl_falloc(struct inode *inode, int mode, loff_t offset, loff_t len)
 {
 	struct lu_env *env;
@@ -5319,7 +5349,7 @@ int ll_layout_conf(struct inode *inode, const struct cl_object_conf *conf)
 	}
 out:
 	cl_env_put(env, &refcheck);
-	return rc;
+	return rc < 0 ? rc : 0;
 }
 
 /* Fetch layout from MDT with getxattr request, if it's not ready yet */
diff --git a/fs/lustre/llite/foreign_symlink.h b/fs/lustre/llite/foreign_symlink.h
new file mode 100644
index 0000000..05e30b4
--- /dev/null
+++ b/fs/lustre/llite/foreign_symlink.h
@@ -0,0 +1,49 @@
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
+
+#ifndef LLITE_FOREIGN_SYMLINK_H
+#define LLITE_FOREIGN_SYMLINK_H
+
+/* llite/llite_foreign_symlink.c */
+ssize_t foreign_symlink_enable_show(struct kobject *kobj,
+				    struct attribute *attr, char *buf);
+ssize_t foreign_symlink_enable_store(struct kobject *kobj,
+				     struct attribute *attr,
+				     const char *buffer, size_t count);
+ssize_t foreign_symlink_prefix_show(struct kobject *kobj,
+				    struct attribute *attr, char *buf);
+ssize_t foreign_symlink_prefix_store(struct kobject *kobj,
+				     struct attribute *attr,
+				     const char *buffer, size_t count);
+ssize_t foreign_symlink_upcall_show(struct kobject *kobj,
+				    struct attribute *attr, char *buf);
+ssize_t foreign_symlink_upcall_store(struct kobject *kobj,
+				     struct attribute *attr,
+				     const char *buffer, size_t count);
+ssize_t foreign_symlink_upcall_info_store(struct kobject *kobj,
+				     struct attribute *attr,
+				     const char *buffer, size_t count);
+extern const struct inode_operations ll_foreign_file_symlink_inode_operations;
+extern const struct inode_operations ll_foreign_dir_symlink_inode_operations;
+
+#endif /* LLITE_FOREIGN_SYMLINK_H */
diff --git a/fs/lustre/llite/llite_foreign.c b/fs/lustre/llite/llite_foreign.c
new file mode 100644
index 0000000..ed958f5
--- /dev/null
+++ b/fs/lustre/llite/llite_foreign.c
@@ -0,0 +1,284 @@
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
+ * Copyright (c) 2020 Intel Corporation.
+ */
+#define DEBUG_SUBSYSTEM S_LLITE
+
+#include "llite_internal.h"
+
+static void ll_manage_foreign_file(struct inode *inode,
+				   struct lov_foreign_md *lfm)
+{
+	struct ll_sb_info *sbi = ll_i2sbi(inode);
+
+	if (le32_to_cpu(lfm->lfm_type) == LU_FOREIGN_TYPE_SYMLINK) {
+		CDEBUG(D_INFO,
+		       "%s: inode %p of fid "DFID": Foreign file of type symlink, faking a symlink\n",
+		       sbi->ll_fsname, inode, PFID(ll_inode2fid(inode)));
+		/* change inode_operations to add symlink methods, and clear
+		 * IOP_NOFOLLOW to ensure file will be treated as a symlink
+		 * by Kernel (see in * d_flags_for_inode()).
+		 */
+		inode->i_op = &ll_foreign_file_symlink_inode_operations;
+		inode->i_opflags &= ~IOP_NOFOLLOW;
+	} else {
+		CDEBUG(D_INFO,
+		       "%s: inode %p of fid "DFID": Foreign file of type %ux, nothing special to do\n",
+		       sbi->ll_fsname, inode, PFID(ll_inode2fid(inode)),
+		       le32_to_cpu(lfm->lfm_type));
+	}
+}
+
+static void ll_manage_foreign_dir(struct inode *inode,
+				  struct lmv_foreign_md *lfm)
+{
+	struct ll_sb_info *sbi = ll_i2sbi(inode);
+
+	if (lfm->lfm_type == LU_FOREIGN_TYPE_SYMLINK) {
+		CDEBUG(D_INFO,
+		       "%s: inode %p of fid "DFID": Foreign dir of type symlink, faking a symlink\n",
+		       sbi->ll_fsname, inode, PFID(ll_inode2fid(inode)));
+		/* change inode_operations to add symlink methods
+		 * IOP_NOFOLLOW should not be set for dirs
+		 */
+		inode->i_op = &ll_foreign_dir_symlink_inode_operations;
+	} else {
+		CDEBUG(D_INFO,
+		       "%s: inode %p of fid "DFID": Foreign dir of type %ux, nothing special to do\n",
+		       sbi->ll_fsname, inode, PFID(ll_inode2fid(inode)),
+		       le32_to_cpu(lfm->lfm_type));
+	}
+}
+
+int ll_manage_foreign(struct inode *inode, struct lustre_md *lmd)
+{
+	int rc = 0;
+
+	/* apply any foreign file/dir policy */
+	if (S_ISREG((inode)->i_mode)) {
+		struct ll_inode_info *lli = ll_i2info(inode);
+		struct cl_object *obj = lli->lli_clob;
+
+		if (lmd->layout.lb_buf && lmd->layout.lb_len != 0) {
+			struct lov_foreign_md *lfm = lmd->layout.lb_buf;
+
+			if (lfm->lfm_magic == LOV_MAGIC_FOREIGN)
+				ll_manage_foreign_file(inode, lfm);
+			goto out;
+		}
+
+		if (obj) {
+			struct lov_foreign_md lfm = {
+				.lfm_magic = LOV_MAGIC,
+			};
+			struct cl_layout cl = {
+				.cl_buf.lb_buf = &lfm,
+				.cl_buf.lb_len = sizeof(lfm),
+			};
+			struct lu_env *env;
+			u16 refcheck;
+
+			env = cl_env_get(&refcheck);
+			if (IS_ERR(env)) {
+				rc = PTR_ERR(env);
+				goto out;
+			}
+			rc = cl_object_layout_get(env, obj, &cl);
+			/* error is likely to be -ERANGE because of the small
+			 * buffer we use, only the content is significant here
+			 */
+			if (rc < 0 && rc != -ERANGE) {
+				cl_env_put(env, &refcheck);
+				goto out;
+			}
+			if (lfm.lfm_magic == LOV_MAGIC_FOREIGN)
+				ll_manage_foreign_file(inode, &lfm);
+			cl_env_put(env, &refcheck);
+		}
+	} else if (S_ISDIR((inode)->i_mode)) {
+		if (lmd->lfm &&
+		    lmd->lfm->lfm_magic == LMV_MAGIC_FOREIGN) {
+			ll_manage_foreign_dir(inode, lmd->lfm);
+		} else {
+			struct ll_inode_info *lli = ll_i2info(inode);
+			struct lmv_foreign_md *lfm;
+
+			down_read(&lli->lli_lsm_sem);
+			lfm = (struct lmv_foreign_md *)(lli->lli_lsm_md);
+			if (lfm &&  lfm->lfm_magic == LMV_MAGIC_FOREIGN)
+				ll_manage_foreign_dir(inode, lfm);
+			up_read(&lli->lli_lsm_sem);
+		}
+	}
+out:
+	return rc;
+}
+
+/* dentry must be spliced to inode (dentry->d_inode != NULL) !!! */
+bool ll_foreign_is_openable(struct dentry *dentry, unsigned int flags)
+{
+	/* check for faked symlink here as they should not be opened (unless
+	 * O_NOFOLLOW!) and thus wants ll_atomic_open() to return 1 from
+	 * finish_no_open() in order to get follow_link() to be called in both
+	 * path_lookupat() and path_openupat().
+	 * This will not break regular symlink handling as they have
+	 * been treated/filtered upstream.
+	 */
+	if (d_is_symlink(dentry) && !S_ISLNK(dentry->d_inode->i_mode) &&
+	    !(flags & O_NOFOLLOW))
+		return false;
+
+	return true;
+}
+
+static bool should_preserve_foreign_file(struct lov_foreign_md *lfm,
+					 struct ll_inode_info *lli, bool unset)
+{
+	/* for now, only avoid foreign fake symlink file removal */
+
+	if (unset)
+		if (lfm->lfm_type == LU_FOREIGN_TYPE_SYMLINK) {
+			set_bit(LLIF_FOREIGN_REMOVABLE, &lli->lli_flags);
+			return true;
+		} else {
+			return false;
+		}
+	else
+		return lfm->lfm_type == LU_FOREIGN_TYPE_SYMLINK &&
+		       !test_bit(LLIF_FOREIGN_REMOVABLE, &lli->lli_flags);
+}
+
+static bool should_preserve_foreign_dir(struct lmv_foreign_md *lfm,
+					struct ll_inode_info *lli, bool unset)
+{
+	/* for now, only avoid foreign fake symlink dir removal */
+
+	if (unset)
+		if (lfm->lfm_type == LU_FOREIGN_TYPE_SYMLINK) {
+			set_bit(LLIF_FOREIGN_REMOVABLE, &lli->lli_flags);
+			return true;
+		} else {
+			return false;
+		}
+	else
+		return lfm->lfm_type == LU_FOREIGN_TYPE_SYMLINK &&
+		       !test_bit(LLIF_FOREIGN_REMOVABLE, &lli->lli_flags);
+}
+
+/* XXX
+ * instead of fetching type from foreign LOV/LMV, we may simply
+ * check (d_is_symlink(dentry) && !S_ISLNK(dentry->d_inode->i_mode))
+ * to identify a fake symlink
+ */
+bool ll_foreign_is_removable(struct dentry *dentry, bool unset)
+{
+	struct inode *inode = dentry->d_inode;
+	struct qstr *name = &dentry->d_name;
+	bool preserve_foreign = false;
+	int rc = 0;
+
+	if (!inode)
+		return 0;
+
+	/* some foreign types may not be allowed to be unlinked in order to
+	 * keep references with external objects
+	 */
+	if (S_ISREG(inode->i_mode)) {
+		struct ll_inode_info *lli = ll_i2info(inode);
+		struct cl_object *obj = lli->lli_clob;
+
+		if (obj) {
+			struct lov_foreign_md lfm = {
+				.lfm_magic = LOV_MAGIC,
+			};
+			struct cl_layout cl = {
+				.cl_buf.lb_buf = &lfm,
+				.cl_buf.lb_len = sizeof(lfm),
+			};
+			struct lu_env *env;
+			u16 refcheck;
+
+			env = cl_env_get(&refcheck);
+			if (IS_ERR(env)) {
+				rc = PTR_ERR(env);
+				goto out;
+			}
+			rc = cl_object_layout_get(env, obj, &cl);
+			/* error is likely to be -ERANGE because of the small
+			 * buffer we use, only the content is significant here
+			 */
+			if (rc < 0 && rc != -ERANGE) {
+				cl_env_put(env, &refcheck);
+				goto out;
+			} else {
+				rc = 0;
+			}
+			if (lfm.lfm_magic == LOV_MAGIC_FOREIGN)
+				preserve_foreign =
+					should_preserve_foreign_file(&lfm, lli,
+								     unset);
+			cl_env_put(env, &refcheck);
+			if (preserve_foreign) {
+				CDEBUG(D_INFO,
+				       "%s unlink of foreign file (%.*s, "DFID")\n",
+				       unset ? "allow" : "prevent",
+				       name->len, name->name,
+				       PFID(ll_inode2fid(inode)));
+				return false;
+			}
+		} else {
+			CDEBUG(D_INFO,
+			       "unable to check if file (%.*s, "DFID") is foreign...\n",
+			       name->len, name->name,
+			       PFID(ll_inode2fid(inode)));
+			/* XXX should we prevent removal ?? */
+		}
+	} else if (S_ISDIR(inode->i_mode)) {
+		struct ll_inode_info *lli = ll_i2info(inode);
+		struct lmv_foreign_md *lfm;
+
+		down_read(&lli->lli_lsm_sem);
+		lfm = (struct lmv_foreign_md *)(lli->lli_lsm_md);
+		if (!lfm)
+			CDEBUG(D_INFO,
+			       "unable to check if dir (%.*s, "DFID") is foreign...\n",
+			       name->len, name->name,
+			       PFID(ll_inode2fid(inode)));
+		else if (lfm->lfm_magic == LMV_MAGIC_FOREIGN)
+			preserve_foreign = should_preserve_foreign_dir(lfm, lli,
+								       unset);
+		up_read(&lli->lli_lsm_sem);
+		if (preserve_foreign) {
+			CDEBUG(D_INFO,
+			       "%s unlink of foreign dir (%.*s, "DFID")\n",
+			       unset ? "allow" : "prevent",
+			       name->len, name->name,
+			       PFID(ll_inode2fid(inode)));
+			return false;
+		}
+	}
+
+out:
+	return true;
+}
diff --git a/fs/lustre/llite/llite_foreign_symlink.c b/fs/lustre/llite/llite_foreign_symlink.c
new file mode 100644
index 0000000..7ba33f4
--- /dev/null
+++ b/fs/lustre/llite/llite_foreign_symlink.c
@@ -0,0 +1,758 @@
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
+ * Copyright (c) 2020 Intel Corporation.
+ */
+/*
+ * Foreign symlink implementation.
+ *
+ * Methods in this source file allow to construct a relative path from the
+ * LOV/LMV foreign content, to complement it with a prefix, and then to
+ * expose it to the VFS as a symlink destination.
+ * The default/internal mechanism simply takes the full foreign free string
+ * as the relative path, and for more complex internal formats an upcall has
+ * been implemented to provide format's details (presently just in terms of
+ * constant strings and substrings positions in EA, but this can be enhanced)
+ * to llite layer.
+ */
+
+#include <linux/fs.h>
+#include <linux/fs_struct.h>
+#include <linux/mm.h>
+#include <linux/stat.h>
+#include <linux/version.h>
+#define DEBUG_SUBSYSTEM S_LLITE
+
+#include "llite_internal.h"
+
+/* allocate space for "/<prefix>/<suffix>'\0'" and copy prefix in,
+ * returns start position for suffix in *destname
+ * must be called with ll_foreign_symlink_sem locked for read, to
+ * protect against sbi->ll_foreign_symlink_prefix change
+ * on output, provides position where to start prefix complement
+ */
+static int foreign_symlink_alloc_and_copy_prefix(struct ll_sb_info *sbi,
+						 struct inode *inode,
+						 char **destname,
+						 size_t suffix_size)
+{
+	size_t prefix_size, full_size;
+
+	/* allocate enough for "/<prefix>/<suffix>'\0'" */
+	prefix_size = sbi->ll_foreign_symlink_prefix_size - 1;
+	full_size = suffix_size + prefix_size + 3;
+	if (full_size > PATH_MAX) {
+		CERROR("%s: inode "DFID": resolved destination path too long\n",
+		       sbi->ll_fsname, PFID(ll_inode2fid(inode)));
+		return -EINVAL;
+	}
+	*destname = kzalloc(full_size, GFP_KERNEL);
+	if (!*destname)
+		return -ENOMEM;
+
+	memcpy(*destname + 1, sbi->ll_foreign_symlink_prefix,
+	       prefix_size);
+	(*destname)[0] = '/';
+	(*destname)[prefix_size + 1] = '/';
+
+	return prefix_size + 2;
+}
+
+/* if no upcall registered, default foreign symlink parsing method
+ * is to use the full lfm_value as a relative path to complement
+ * foreign_prefix
+ */
+static int ll_foreign_symlink_default_parse(struct ll_sb_info *sbi,
+					    struct inode *inode,
+					    struct lov_foreign_md *lfm,
+					    char **destname)
+{
+	int suffix_pos;
+
+	down_read(&sbi->ll_foreign_symlink_sem);
+	suffix_pos = foreign_symlink_alloc_and_copy_prefix(sbi, inode,
+							   destname,
+							   lfm->lfm_length);
+	up_read(&sbi->ll_foreign_symlink_sem);
+
+	if (suffix_pos < 0)
+		return suffix_pos;
+
+	memcpy(*destname + suffix_pos, lfm->lfm_value,
+	       lfm->lfm_length);
+	(*destname)[suffix_pos + lfm->lfm_length] = '\0';
+
+	return 0;
+}
+
+/* if an upcall has been registered, foreign symlink will be
+ * constructed as per upcall provided format
+ * presently we only support a serie of constant strings and sub-strings
+ * to be taken from lfm_value content
+ */
+static int ll_foreign_symlink_upcall_parse(struct ll_sb_info *sbi,
+					   struct inode *inode,
+					   struct lov_foreign_md *lfm,
+					   char **destname)
+{
+	int pos = 0, suffix_pos = -1, items_size = 0;
+	struct ll_foreign_symlink_upcall_item *foreign_symlink_items =
+			sbi->ll_foreign_symlink_upcall_items;
+	int i = 0, rc = 0;
+
+	down_read(&sbi->ll_foreign_symlink_sem);
+
+	/* compute size of relative path of destination path
+	 * could be done once during upcall items/infos reading
+	 * and stored as new ll_sb_info field
+	 */
+	for (i = 0; i < sbi->ll_foreign_symlink_upcall_nb_items; i++) {
+		switch (foreign_symlink_items[i].type) {
+		case STRING_TYPE:
+			items_size += foreign_symlink_items[i].size;
+			break;
+		case POSLEN_TYPE:
+			items_size += foreign_symlink_items[i].len;
+			break;
+		case EOB_TYPE:
+			/* should be the last item */
+			break;
+		default:
+			CERROR("%s: unexpected type '%u' found in items\n",
+			       sbi->ll_fsname, foreign_symlink_items[i].type);
+			rc = -EINVAL;
+			goto failed;
+		}
+	}
+
+	suffix_pos = foreign_symlink_alloc_and_copy_prefix(sbi, inode, destname,
+							   items_size);
+	if (suffix_pos < 0) {
+		rc = suffix_pos;
+		goto failed;
+	}
+
+	/* rescan foreign_symlink_items[] to create faked symlink dest path */
+	i = 0;
+	while (foreign_symlink_items[i].type != EOB_TYPE) {
+		if (foreign_symlink_items[i].type == STRING_TYPE) {
+			memcpy(*destname + suffix_pos + pos,
+			       foreign_symlink_items[i].string,
+			       foreign_symlink_items[i].size);
+			pos += foreign_symlink_items[i].size;
+		} else if (foreign_symlink_items[i].type == POSLEN_TYPE) {
+			if (lfm->lfm_length < foreign_symlink_items[i].pos +
+					      foreign_symlink_items[i].len) {
+				CERROR("%s:  "DFID" foreign EA too short to find (%u,%u) item\n",
+				       sbi->ll_fsname,
+				       PFID(ll_inode2fid(inode)),
+				       foreign_symlink_items[i].pos,
+				       foreign_symlink_items[i].len);
+				rc = -EINVAL;
+				goto failed;
+			}
+			memcpy(*destname + suffix_pos + pos,
+			       lfm->lfm_value + foreign_symlink_items[i].pos,
+			       foreign_symlink_items[i].len);
+			pos += foreign_symlink_items[i].len;
+		} else {
+			CERROR("%s: unexpected type '%u' found in items\n",
+			       sbi->ll_fsname, foreign_symlink_items[i].type);
+			rc = -EINVAL;
+			goto failed;
+		}
+		i++;
+	}
+failed:
+	up_read(&sbi->ll_foreign_symlink_sem);
+
+	if (rc != 0 && suffix_pos >= 0) {
+		kvfree(*destname);
+		*destname = NULL;
+	}
+
+	return rc;
+}
+
+static int ll_foreign_symlink_parse(struct ll_sb_info *sbi,
+				    struct inode *inode,
+				    struct lov_foreign_md *lfm,
+				    char **destname)
+{
+	int rc;
+
+	/* if no user-land upcall registered, assuming whole free field
+	 * of foreign LOV is relative path of faked symlink destination,
+	 * to be completed by prefix
+	 */
+	if (!(sbi->ll_flags & LL_SBI_FOREIGN_SYMLINK_UPCALL))
+		rc = ll_foreign_symlink_default_parse(sbi, inode, lfm,
+						      destname);
+	else /* upcall is available */
+		rc = ll_foreign_symlink_upcall_parse(sbi, inode, lfm,
+						     destname);
+	return rc;
+}
+
+/* Don't need lli_size_mutex locked as LOV/LMV are EAs
+ * and should not be stored in data blocks
+ */
+static int ll_foreign_readlink_internal(struct inode *inode, char **symname)
+{
+	struct ll_inode_info *lli = ll_i2info(inode);
+	struct ll_sb_info *sbi = ll_i2sbi(inode);
+	struct lov_foreign_md *lfm = NULL;
+	char *destname = NULL;
+	size_t lfm_size = 0;
+	int rc;
+
+	if (S_ISREG(inode->i_mode)) {
+		struct cl_object *obj = lli->lli_clob;
+		struct cl_layout cl = {
+			.cl_buf.lb_len = 0, /* to get real size */
+		};
+		struct lu_env *env;
+		u16 refcheck;
+
+		if (!obj) {
+			CERROR("%s: inode "DFID": can not get layout, no cl_object\n",
+			       sbi->ll_fsname, PFID(ll_inode2fid(inode)));
+			rc = -EINVAL;
+			goto failed;
+		}
+
+		env = cl_env_get(&refcheck);
+		if (IS_ERR(env))
+			return PTR_ERR(env);
+		/* get layout size */
+		rc = cl_object_layout_get(env, obj, &cl);
+		if (rc <= 0) {
+			CERROR("%s: inode "DFID": error trying to get layout size : %d\n",
+			       sbi->ll_fsname, PFID(ll_inode2fid(inode)), rc);
+			cl_env_put(env, &refcheck);
+			return rc;
+		}
+		lfm = kzalloc(rc, GFP_KERNEL);
+		if (!lfm) {
+			CERROR("%s: inode "DFID": can not allocate enough mem to get layout\n",
+			       sbi->ll_fsname, PFID(ll_inode2fid(inode)));
+			cl_env_put(env, &refcheck);
+			return -ENOMEM;
+		}
+		cl.cl_buf.lb_len = rc;
+		cl.cl_buf.lb_buf = lfm;
+		/* get layout */
+		rc = cl_object_layout_get(env, obj, &cl);
+		if (rc <= 0) {
+			CERROR("%s: inode "DFID": error trying to get layout : %d\n",
+			       sbi->ll_fsname, PFID(ll_inode2fid(inode)), rc);
+			kfree(lfm);
+			cl_env_put(env, &refcheck);
+			return rc;
+		}
+		lfm_size = cl.cl_buf.lb_len;
+		cl_env_put(env, &refcheck);
+	} else if (S_ISDIR(inode->i_mode)) {
+		down_read(&lli->lli_lsm_sem);
+
+		/* should be casted lmv_foreign_md, but it is ok as both foreign LOV
+		 * and LMV formats are identical, and then we also only need
+		 * one set of parsing routines for both foreign files and dirs!
+		 */
+		lfm = (struct lov_foreign_md *)(lli->lli_lsm_md);
+		if (lfm) {
+			CDEBUG(D_INFO, "%s: inode "DFID": LMV cached found\n",
+			       sbi->ll_fsname, PFID(ll_inode2fid(inode)));
+		} else {
+			CERROR("%s: inode "DFID": cannot get layout, no LMV cached\n",
+			       sbi->ll_fsname, PFID(ll_inode2fid(inode)));
+			rc = -EINVAL;
+			goto failed;
+		}
+	} else {
+		CERROR("%s: inode "DFID": not a regular file nor directory\n",
+		       sbi->ll_fsname, PFID(ll_inode2fid(inode)));
+		rc = -EINVAL;
+		goto failed;
+	}
+
+	/* XXX no assert nor double check of magic, length and type ? */
+
+	rc = ll_foreign_symlink_parse(sbi, inode, lfm, &destname);
+failed:
+	if (S_ISDIR(inode->i_mode))
+		up_read(&lli->lli_lsm_sem);
+
+	if (S_ISREG(inode->i_mode) && lfm)
+		kfree(lfm);
+
+	if (!rc) {
+		*symname = destname;
+		CDEBUG(D_INFO,
+		       "%s: inode "DFID": faking symlink to dest '%s'\n",
+		       sbi->ll_fsname, PFID(ll_inode2fid(inode)), destname);
+	}
+
+	return rc;
+}
+
+static void ll_foreign_put_link(void *cookie)
+{
+	/* to avoid allocating an unnecessary big buffer, and since ways to
+	 * build the symlink path from foreign LOV/LMV can be multiple and
+	 * not constant. So it size is not known and we need to use
+	 * strlen(cookie)+1 to determine its size and to avoid false positive
+	 * to be reported by memory leak check code
+	 */
+	kvfree(cookie);
+}
+
+static const char *ll_foreign_get_link(struct dentry *dentry,
+				       struct inode *inode,
+				       struct delayed_call *done)
+{
+	char *symname = NULL;
+	int rc;
+
+	CDEBUG(D_VFSTRACE, "VFS Op\n");
+	if (!dentry)
+		return ERR_PTR(-ECHILD);
+	rc = ll_foreign_readlink_internal(inode, &symname);
+
+	/*
+	 * symname must be freed when we are done
+	 *
+	 * XXX we may avoid the need to do so if we use
+	 * lli_symlink_name cache to retain symname and
+	 * let ll_clear_inode free it...
+	 */
+	set_delayed_call(done, ll_foreign_put_link, symname);
+	return rc ? ERR_PTR(rc) : symname;
+}
+
+/*
+ * Should only be called for already in-use/cache foreign dir inode
+ * when foreign fake-symlink behaviour has been enabled afterward
+ */
+static struct dentry *ll_foreign_dir_lookup(struct inode *parent,
+					 struct dentry *dentry,
+					 unsigned int flags)
+{
+	CDEBUG(D_VFSTRACE, "VFS Op:name=%.*s, dir="DFID"(%p)\n",
+	       dentry->d_name.len, dentry->d_name.name,
+	       PFID(ll_inode2fid(parent)), parent);
+
+	return ERR_PTR(-ENODATA);
+}
+
+static bool has_same_mount_namespace(struct ll_sb_info *sbi)
+{
+	int rc;
+
+	rc = (sbi->ll_mnt.mnt == current->fs->root.mnt);
+	if (!rc)
+		LCONSOLE_WARN("%s: client mount %s and '%s.%d' not in same mnt-namespace\n",
+			      sbi->ll_fsname, sbi->ll_kset.kobj.name,
+			      current->comm, current->pid);
+
+	return rc;
+}
+
+ssize_t foreign_symlink_enable_show(struct kobject *kobj,
+				    struct attribute *attr, char *buf)
+{
+	struct ll_sb_info *sbi = container_of(kobj, struct ll_sb_info,
+					      ll_kset.kobj);
+
+	return snprintf(buf, PAGE_SIZE, "%d\n",
+			!!(sbi->ll_flags & LL_SBI_FOREIGN_SYMLINK));
+}
+
+/*
+ * XXX
+ * There should be already in-use/cached inodes of foreign files/dirs who
+ * will not-be/continue-to-be handled as fake-symlink, depending if
+ * feature is being enabled/disabled, until being revalidated.
+ * Also, does it require sbi->ll_lock protection ?
+ */
+ssize_t foreign_symlink_enable_store(struct kobject *kobj,
+				     struct attribute *attr,
+				     const char *buffer, size_t count)
+{
+	struct ll_sb_info *sbi = container_of(kobj, struct ll_sb_info,
+					      ll_kset.kobj);
+	unsigned int val;
+	int rc;
+
+	if (!has_same_mount_namespace(sbi))
+		return -EINVAL;
+
+	rc = kstrtouint(buffer, 10, &val);
+	if (rc)
+		return rc;
+
+	if (val)
+		sbi->ll_flags |= LL_SBI_FOREIGN_SYMLINK;
+	else
+		sbi->ll_flags &= ~LL_SBI_FOREIGN_SYMLINK;
+
+	return count;
+}
+
+ssize_t foreign_symlink_prefix_show(struct kobject *kobj,
+				    struct attribute *attr, char *buf)
+{
+	struct ll_sb_info *sbi = container_of(kobj, struct ll_sb_info,
+					      ll_kset.kobj);
+	ssize_t size;
+
+	down_read(&sbi->ll_foreign_symlink_sem);
+	size = snprintf(buf, PAGE_SIZE, "%s\n", sbi->ll_foreign_symlink_prefix);
+	up_read(&sbi->ll_foreign_symlink_sem);
+
+	return size;
+}
+
+ssize_t foreign_symlink_prefix_store(struct kobject *kobj,
+				     struct attribute *attr,
+				     const char *buffer, size_t count)
+{
+	struct ll_sb_info *sbi = container_of(kobj, struct ll_sb_info,
+					      ll_kset.kobj);
+	char *new, *old;
+	size_t new_len, old_len;
+
+	if (!has_same_mount_namespace(sbi))
+		return -EINVAL;
+
+	/* XXX strip buffer of any CR/LF,space,... ?? */
+
+	/* check buffer looks like a valid absolute path */
+	if (*buffer != '/') {
+		CERROR("foreign symlink prefix must be an absolute path\n");
+		return -EINVAL;
+	}
+	new_len = strnlen(buffer, count);
+	if (new_len < count)
+		CDEBUG(D_INFO, "NUL byte found in %zu bytes\n", count);
+	if (new_len > PATH_MAX) {
+		CERROR("%s: foreign symlink prefix length %zu > PATH_MAX\n",
+		       sbi->ll_fsname, new_len);
+		return -EINVAL;
+	}
+	new = kzalloc(new_len + 1, GFP_KERNEL);
+	if (!new) {
+		CERROR("%s: can not allocate space for foreign path prefix\n",
+		       sbi->ll_fsname);
+		return -ENOSPC;
+	}
+
+	down_write(&sbi->ll_foreign_symlink_sem);
+	old_len = sbi->ll_foreign_symlink_prefix_size;
+	old = sbi->ll_foreign_symlink_prefix;
+	memcpy(new, buffer, new_len);
+	*(new + new_len) = '\0';
+
+	sbi->ll_foreign_symlink_prefix = new;
+	sbi->ll_foreign_symlink_prefix_size = new_len + 1;
+	up_write(&sbi->ll_foreign_symlink_sem);
+
+	kfree(old);
+
+	return new_len;
+}
+
+ssize_t foreign_symlink_upcall_show(struct kobject *kobj,
+				    struct attribute *attr, char *buf)
+{
+	ssize_t size;
+	struct ll_sb_info *sbi = container_of(kobj, struct ll_sb_info,
+					      ll_kset.kobj);
+
+	down_read(&sbi->ll_foreign_symlink_sem);
+	size = snprintf(buf, PAGE_SIZE, "%s\n", sbi->ll_foreign_symlink_upcall);
+	up_read(&sbi->ll_foreign_symlink_sem);
+
+	return size;
+}
+
+ssize_t foreign_symlink_upcall_store(struct kobject *kobj,
+				     struct attribute *attr,
+				     const char *buffer, size_t count)
+{
+	struct ll_sb_info *sbi = container_of(kobj, struct ll_sb_info,
+					      ll_kset.kobj);
+	char *old = NULL, *new = NULL;
+	size_t new_len;
+
+	if (!has_same_mount_namespace(sbi))
+		return -EINVAL;
+
+	/* XXX strip buffer of any CR/LF,space,... ?? */
+
+	/* check buffer looks like a valid absolute path */
+	if (*buffer != '/' && strcmp(buffer, "none")) {
+		CERROR("foreign symlink upcall must be an absolute path\n");
+		return -EINVAL;
+	}
+	new_len = strnlen(buffer, count);
+	if (new_len < count)
+		CDEBUG(D_INFO, "NULL byte found in %zu bytes\n", count);
+	if (new_len > PATH_MAX) {
+		CERROR("%s: foreign symlink upcall path length %zu > PATH_MAX\n",
+		       sbi->ll_fsname, new_len);
+		return -EINVAL;
+	}
+
+	new = kzalloc(new_len + 1, GFP_KERNEL);
+	if (!new) {
+		CERROR("%s: can not allocate space for foreign symlink upcall path\n",
+		       sbi->ll_fsname);
+		return -ENOSPC;
+	}
+	memcpy(new, buffer, new_len);
+	*(new + new_len) = '\0';
+
+	down_write(&sbi->ll_foreign_symlink_sem);
+	old = sbi->ll_foreign_symlink_upcall;
+
+	sbi->ll_foreign_symlink_upcall = new;
+	/* LL_SBI_FOREIGN_SYMLINK_UPCALL will be set by
+	 * foreign_symlink_upcall_info_store() upon valid being provided
+	 * by upcall
+	 * XXX there is a potential race if there are multiple concurent
+	 * attempts to set upcall path and execution occur in different
+	 * order, we may end up using the format provided by a different
+	 * upcall than the one set in ll_foreign_symlink_upcall
+	 */
+	sbi->ll_flags &= ~LL_SBI_FOREIGN_SYMLINK_UPCALL;
+	up_write(&sbi->ll_foreign_symlink_sem);
+
+	if (strcmp(new, "none")) {
+		char *argv[] = {
+			  [0] = new,
+			  /* sbi sysfs object name */
+			  [1] = (char *)sbi->ll_kset.kobj.name,
+			  [2] = NULL
+		};
+		char *envp[] = {
+			  [0] = "HOME=/",
+			  [1] = "PATH=/sbin:/usr/sbin",
+			  [2] = NULL
+		};
+		int rc;
+
+		rc = call_usermodehelper(new, argv, envp, UMH_WAIT_EXEC);
+		if (rc < 0)
+			CERROR("%s: error invoking foreign symlink upcall %s: rc %d\n",
+			       sbi->ll_fsname, new, rc);
+		else
+			CDEBUG(D_INFO, "%s: invoked upcall %s\n",
+			       sbi->ll_fsname, new);
+	}
+
+	kvfree(old);
+
+	return new_len;
+}
+
+/* foreign_symlink_upcall_info_store() stores format items in
+ * foreign_symlink_items[], and foreign_symlink_upcall_parse()
+ * uses it to parse each foreign symlink LOV/LMV EAs
+ */
+ssize_t foreign_symlink_upcall_info_store(struct kobject *kobj,
+				     struct attribute *attr,
+				     const char *buffer, size_t count)
+{
+	struct ll_sb_info *sbi = container_of(kobj, struct ll_sb_info,
+					      ll_kset.kobj);
+	struct ll_foreign_symlink_upcall_item items[MAX_NB_UPCALL_ITEMS], *item;
+	struct ll_foreign_symlink_upcall_item *new_items, *old_items;
+	size_t remaining = count;
+	int nb_items = 0, old_nb_items, i, rc = 0;
+
+	if (!has_same_mount_namespace(sbi))
+		return -EINVAL;
+
+	/* parse buffer to check validity of infos and fill symlink format
+	 * descriptors
+	 */
+
+	if (count % sizeof(u32) != 0) {
+		CERROR("%s: invalid size '%zu' of infos buffer returned by foreign symlink upcall\n",
+		       sbi->ll_fsname, count);
+		return -EINVAL;
+	}
+
+	/* evaluate number of items provided */
+	while (remaining > 0) {
+		item = (struct ll_foreign_symlink_upcall_item *)
+				&buffer[count - remaining];
+		switch (item->type) {
+		case STRING_TYPE: {
+			/* a constant string following */
+			if (item->size >= remaining -
+			    offsetof(struct ll_foreign_symlink_upcall_item,
+				     bytestring) - sizeof(item->type)) {
+				/* size of string must not overflow remaining
+				 * bytes minus EOB_TYPE item
+				 */
+				CERROR("%s: constant string too long in infos buffer returned by foreign symlink upcall\n",
+				       sbi->ll_fsname);
+				rc = -EINVAL;
+				goto failed;
+			}
+			items[nb_items].string = kzalloc(item->size,
+							 GFP_KERNEL);
+			if (!items[nb_items].string) {
+				CERROR("%s: constant string allocation has failed for constant string of size %zu\n",
+				       sbi->ll_fsname, item->size);
+				rc = -ENOMEM;
+				goto failed;
+			}
+			memcpy(items[nb_items].string,
+			       item->bytestring, item->size);
+			items[nb_items].size = item->size;
+			/* string items to fit on u32 boundary */
+			remaining = remaining - STRING_ITEM_SZ(item->size);
+			break;
+		}
+		case POSLEN_TYPE: {
+			/* a tuple (pos,len) following to delimit a sub-string
+			 * in lfm_value
+			 */
+			items[nb_items].pos = item->pos;
+			items[nb_items].len = item->len;
+			remaining -= POSLEN_ITEM_SZ;
+			break;
+		}
+		case EOB_TYPE:
+			if (remaining != sizeof(item->type)) {
+				CERROR("%s: early end of infos buffer returned by foreign symlink upcall\n",
+				       sbi->ll_fsname);
+				rc = -EINVAL;
+				goto failed;
+			}
+			remaining -= sizeof(item->type);
+			break;
+		default:
+			CERROR("%s: wrong type '%u' encountered at pos %zu , with %zu remaining bytes, in infos buffer returned by foreign symlink upcall\n",
+			       sbi->ll_fsname, (u32)buffer[count - remaining],
+			       count - remaining, remaining);
+			rc = -EINVAL;
+			goto failed;
+		}
+
+		items[nb_items].type = item->type;
+		nb_items++;
+		if (nb_items >= MAX_NB_UPCALL_ITEMS) {
+			CERROR("%s: too many items in infos buffer returned by foreign symlink upcall\n",
+			       sbi->ll_fsname);
+			rc = -EINVAL;
+			goto failed;
+		}
+	}
+	/* valid format has been provided by foreign symlink user upcall */
+	new_items = kvmalloc_array(nb_items,
+				   sizeof(struct ll_foreign_symlink_upcall_item),
+				   GFP_KERNEL);
+	if (!new_items) {
+		CERROR("%s: constant string allocation has failed for constant string of size %zu\n",
+		       sbi->ll_fsname, nb_items *
+			sizeof(struct ll_foreign_symlink_upcall_item));
+		rc = -ENOMEM;
+		goto failed;
+	}
+	for (i = 0; i < nb_items; i++)
+		*((struct ll_foreign_symlink_upcall_item *)new_items + i) =
+			items[i];
+
+	down_write(&sbi->ll_foreign_symlink_sem);
+	old_items = sbi->ll_foreign_symlink_upcall_items;
+	old_nb_items = sbi->ll_foreign_symlink_upcall_nb_items;
+	sbi->ll_foreign_symlink_upcall_items = new_items;
+	sbi->ll_foreign_symlink_upcall_nb_items = nb_items;
+	sbi->ll_flags |= LL_SBI_FOREIGN_SYMLINK_UPCALL;
+	up_write(&sbi->ll_foreign_symlink_sem);
+
+	/* free old_items */
+	if (old_items) {
+		for (i = 0 ; i < old_nb_items; i++)
+			if (old_items[i].type == STRING_TYPE)
+				kfree(old_items[i].string);
+
+		kvfree(old_items);
+	}
+
+failed:
+	/* clean items[] and free any strings */
+	if (rc != 0) {
+		for (i = 0; i < nb_items; i++) {
+			switch (items[i].type) {
+			case STRING_TYPE:
+				kfree(items[i].string);
+				items[i].string = NULL;
+				items[i].size = 0;
+				break;
+			case POSLEN_TYPE:
+				items[i].pos = 0;
+				items[i].len = 0;
+				break;
+			case EOB_TYPE:
+				break;
+			default:
+				CERROR("%s: wrong '%u'type encountered in foreign symlink upcall items\n",
+				       sbi->ll_fsname, items[i].type);
+				rc = -EINVAL;
+				goto failed;
+			}
+			items[i].type = 0;
+		}
+	}
+
+	return rc == 0 ? count : rc;
+}
+
+static int ll_foreign_symlink_getattr(const struct path *path, struct kstat *stat,
+				      u32 request_mask, unsigned int flags)
+{
+	return ll_getattr_dentry(path->dentry, stat, request_mask, flags,
+				 true);
+}
+
+const struct inode_operations ll_foreign_file_symlink_inode_operations = {
+	.setattr	= ll_setattr,
+	.get_link	= ll_foreign_get_link,
+	.getattr	= ll_foreign_symlink_getattr,
+	.permission	= ll_inode_permission,
+	.listxattr	= ll_listxattr,
+};
+
+const struct inode_operations ll_foreign_dir_symlink_inode_operations = {
+	.lookup		= ll_foreign_dir_lookup,
+	.setattr	= ll_setattr,
+	.get_link	= ll_foreign_get_link,
+	.getattr	= ll_foreign_symlink_getattr,
+	.permission	= ll_inode_permission,
+	.listxattr	= ll_listxattr,
+};
diff --git a/fs/lustre/llite/llite_internal.h b/fs/lustre/llite/llite_internal.h
index 669500b..b3e8a96 100644
--- a/fs/lustre/llite/llite_internal.h
+++ b/fs/lustre/llite/llite_internal.h
@@ -51,6 +51,7 @@
 
 #include "vvp_internal.h"
 #include "pcc.h"
+#include "foreign_symlink.h"
 
 /** Only used on client-side for indicating the tail of dir hash/offset. */
 #define LL_DIR_END_OFF	  0x7fffffffffffffffULL
@@ -102,6 +103,8 @@ enum ll_file_flags {
 	 * local inode atime.
 	 */
 	LLIF_UPDATE_ATIME	= 4,
+	/* foreign file/dir can be unlinked unconditionnaly */
+	LLIF_FOREIGN_REMOVABLE	= 5,
 	/* setting encryption context in progress */
 	LLIF_SET_ENC_CTX	= 6,
 };
@@ -619,6 +622,10 @@ enum stats_track_type {
 #define LL_SBI_FILE_HEAT    0x4000000 /* file heat support */
 #define LL_SBI_TEST_DUMMY_ENCRYPTION	0x8000000 /* test dummy encryption */
 #define LL_SBI_ENCRYPT	   0x10000000 /* client side encryption */
+#define LL_SBI_FOREIGN_SYMLINK	0x20000000 /* foreign fake-symlink support */
+/* foreign fake-symlink upcall registered */
+#define LL_SBI_FOREIGN_SYMLINK_UPCALL	0x40000000
+
 #define LL_SBI_FLAGS {	\
 	"nolck",	\
 	"checksum",	\
@@ -649,6 +656,8 @@ enum stats_track_type {
 	"file_heat",	\
 	"test_dummy_encryption", \
 	"noencrypt",	\
+	"foreign_symlink",	\
+	"foreign_symlink_upcall",	\
 }
 
 /*
@@ -761,6 +770,19 @@ struct ll_sb_info {
 
 	/* Persistent Client Cache */
 	struct pcc_super	ll_pcc_super;
+
+	/* to protect vs updates in all following foreign symlink fields */
+	struct rw_semaphore	ll_foreign_symlink_sem;
+	/* foreign symlink path prefix */
+	char			*ll_foreign_symlink_prefix;
+	/* full prefix size including leading '\0' */
+	size_t			ll_foreign_symlink_prefix_size;
+	/* foreign symlink path upcall */
+	char			*ll_foreign_symlink_upcall;
+	/* foreign symlink path upcall infos */
+	struct ll_foreign_symlink_upcall_item *ll_foreign_symlink_upcall_items;
+	/* foreign symlink path upcall nb infos */
+	unsigned int		ll_foreign_symlink_upcall_nb_items;
 };
 
 #define SBI_DEFAULT_HEAT_DECAY_WEIGHT	((80 * 256 + 50) / 100)
@@ -951,6 +973,11 @@ static inline bool ll_sbi_has_file_heat(struct ll_sb_info *sbi)
 	return !!(sbi->ll_flags & LL_SBI_FILE_HEAT);
 }
 
+static inline bool ll_sbi_has_foreign_symlink(struct ll_sb_info *sbi)
+{
+	return !!(sbi->ll_flags & LL_SBI_FOREIGN_SYMLINK);
+}
+
 void ll_ras_enter(struct file *f, loff_t pos, size_t count);
 
 /* llite/lcommon_misc.c */
@@ -1063,6 +1090,8 @@ enum ldlm_mode ll_take_md_lock(struct inode *inode, u64 bits,
 int ll_md_real_close(struct inode *inode, fmode_t fmode);
 int ll_getattr(const struct path *path, struct kstat *stat,
 	       u32 request_mask, unsigned int flags);
+int ll_getattr_dentry(struct dentry *de, struct kstat *stat, u32 request_mask,
+		      unsigned int flags, bool foreign);
 #ifdef CONFIG_LUSTRE_FS_POSIX_ACL
 struct posix_acl *ll_get_acl(struct inode *inode, int type);
 int ll_set_acl(struct inode *inode, struct posix_acl *acl, int type);
@@ -1459,7 +1488,7 @@ static inline int cl_agl(struct inode *inode)
 int ll_file_lock_ahead(struct file *file, struct llapi_lu_ladvise *ladvise);
 
 int cl_io_get(struct inode *inode, struct lu_env **envout,
-	      struct cl_io **ioout, __u16 *refcheck);
+	      struct cl_io **ioout, u16 *refcheck);
 
 static inline int ll_glimpse_size(struct inode *inode)
 {
@@ -1671,5 +1700,9 @@ inline void ll_sbi_set_encrypt(struct ll_sb_info *sbi, bool set)
 {
 }
 #endif /* !CONFIG_FS_ENCRYPTION */
+/* llite/llite_foreign.c */
+int ll_manage_foreign(struct inode *inode, struct lustre_md *lmd);
+bool ll_foreign_is_openable(struct dentry *dentry, unsigned int flags);
+bool ll_foreign_is_removable(struct dentry *dentry, bool unset);
 
 #endif /* LLITE_INTERNAL_H */
diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index f520b34..1b3eef0 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -122,6 +122,28 @@ static struct ll_sb_info *ll_init_sbi(void)
 		goto out_destroy_ra;
 	}
 
+	/* initialize foreign symlink prefix path */
+	sbi->ll_foreign_symlink_prefix = kasprintf(GFP_KERNEL, "/mnt/");
+	if (!sbi->ll_foreign_symlink_prefix) {
+		rc = -ENOMEM;
+		goto out_destroy_ra;
+	}
+	sbi->ll_foreign_symlink_prefix_size = sizeof("/mnt/");
+
+	/* initialize foreign symlink upcall path, none by default */
+	sbi->ll_foreign_symlink_upcall = kasprintf(GFP_KERNEL, "none");
+	if (!sbi->ll_foreign_symlink_upcall) {
+		rc = -ENOMEM;
+		goto out_destroy_ra;
+	}
+
+	sbi->ll_foreign_symlink_upcall_items = NULL;
+	sbi->ll_foreign_symlink_upcall_nb_items = 0;
+	init_rwsem(&sbi->ll_foreign_symlink_sem);
+	/* foreign symlink support (LL_SBI_FOREIGN_SYMLINK in ll_flags)
+	 * not enabled by default
+	 */
+
 	sbi->ll_ra_info.ra_max_pages =
 		min(pages / 32, SBI_DEFAULT_READ_AHEAD_MAX);
 	sbi->ll_ra_info.ra_max_pages_per_file =
@@ -170,6 +192,12 @@ static struct ll_sb_info *ll_init_sbi(void)
 	sbi->ll_heat_period_second = SBI_DEFAULT_HEAT_PERIOD_SECOND;
 	return sbi;
 out_destroy_ra:
+	kfree(sbi->ll_foreign_symlink_upcall);
+	kfree(sbi->ll_foreign_symlink_prefix);
+	if (sbi->ll_cache) {
+		cl_cache_decref(sbi->ll_cache);
+		sbi->ll_cache = NULL;
+	}
 	destroy_workqueue(sbi->ll_ra_info.ll_readahead_wq);
 out_pcc:
 	pcc_super_fini(&sbi->ll_pcc_super);
@@ -190,6 +218,23 @@ static void ll_free_sbi(struct super_block *sb)
 		cl_cache_decref(sbi->ll_cache);
 		sbi->ll_cache = NULL;
 	}
+	kfree(sbi->ll_foreign_symlink_prefix);
+	sbi->ll_foreign_symlink_prefix = NULL;
+	kfree(sbi->ll_foreign_symlink_upcall);
+	sbi->ll_foreign_symlink_upcall = NULL;
+	if (sbi->ll_foreign_symlink_upcall_items) {
+		int i;
+		int nb_items = sbi->ll_foreign_symlink_upcall_nb_items;
+		struct ll_foreign_symlink_upcall_item *items;
+
+		items = sbi->ll_foreign_symlink_upcall_items;
+		for (i = 0 ; i < nb_items; i++)
+			if (items[i].type == STRING_TYPE)
+				kfree(items[i].string);
+
+		kvfree(items);
+		sbi->ll_foreign_symlink_upcall_items = NULL;
+	}
 	pcc_super_fini(&sbi->ll_pcc_super);
 	kfree(sbi);
 }
@@ -958,6 +1003,57 @@ static int ll_options(char *options, struct ll_sb_info *sbi)
 #endif
 			goto next;
 		}
+		tmp = ll_set_opt("foreign_symlink", s1, LL_SBI_FOREIGN_SYMLINK);
+		if (tmp) {
+			int prefix_pos = sizeof("foreign_symlink=") - 1;
+			int equal_pos = sizeof("foreign_symlink=") - 2;
+
+			/* non-default prefix provided ? */
+			if (strlen(s1) >= sizeof("foreign_symlink=") &&
+			    *(s1 + equal_pos) == '=') {
+				char *old = sbi->ll_foreign_symlink_prefix;
+				size_t old_len =
+					sbi->ll_foreign_symlink_prefix_size;
+
+				/* path must be absolute */
+				if (*(s1 + sizeof("foreign_symlink=") -
+				    1) != '/') {
+					LCONSOLE_ERROR_MSG(0x152,
+							   "foreign prefix '%s' must be an absolute path\n",
+							   s1 + prefix_pos);
+					return -EINVAL;
+				}
+				/* last option ? */
+				s2 = strchrnul(s1 + prefix_pos, ',');
+
+				if (sbi->ll_foreign_symlink_prefix) {
+					sbi->ll_foreign_symlink_prefix = NULL;
+					sbi->ll_foreign_symlink_prefix_size = 0;
+				}
+				/* alloc for path length and '\0' */
+				sbi->ll_foreign_symlink_prefix = kmalloc(s2 - (s1 + prefix_pos) + 1,
+									 GFP_KERNEL);
+				if (!sbi->ll_foreign_symlink_prefix) {
+					/* restore previous */
+					sbi->ll_foreign_symlink_prefix = old;
+					sbi->ll_foreign_symlink_prefix_size =
+						old_len;
+					return -ENOMEM;
+				}
+				kfree(old);
+				strncpy(sbi->ll_foreign_symlink_prefix,
+					s1 + prefix_pos,
+					s2 - (s1 + prefix_pos));
+				sbi->ll_foreign_symlink_prefix_size =
+					s2 - (s1 + prefix_pos) + 1;
+			} else {
+				LCONSOLE_ERROR_MSG(0x152,
+						   "invalid %s option\n", s1);
+			}
+			/* enable foreign symlink support */
+			*flags |= tmp;
+			goto next;
+		}
 		LCONSOLE_ERROR_MSG(0x152, "Unknown option '%s', won't mount.\n",
 				   s1);
 		return -EINVAL;
@@ -2763,6 +2859,10 @@ int ll_prep_inode(struct inode **inode, struct ptlrpc_request *req,
 
 	if (default_lmv_deleted)
 		ll_update_default_lsm_md(*inode, &md);
+
+	/* we may want to apply some policy for foreign file/dir */
+	if (ll_sbi_has_foreign_symlink(sbi))
+		rc = ll_manage_foreign(*inode, &md);
 out:
 	/* cleanup will be done if necessary */
 	md_free_lustre_md(sbi->ll_md_exp, &md);
@@ -2974,6 +3074,11 @@ int ll_show_options(struct seq_file *seq, struct dentry *dentry)
 	else
 		seq_puts(seq, ",noencrypt");
 
+	if (sbi->ll_flags & LL_SBI_FOREIGN_SYMLINK) {
+		seq_puts(seq, ",foreign_symlink=");
+		seq_puts(seq, sbi->ll_foreign_symlink_prefix);
+	}
+
 	return 0;
 }
 
diff --git a/fs/lustre/llite/lproc_llite.c b/fs/lustre/llite/lproc_llite.c
index 3ca553d..16d1497 100644
--- a/fs/lustre/llite/lproc_llite.c
+++ b/fs/lustre/llite/lproc_llite.c
@@ -290,6 +290,14 @@ static ssize_t client_type_show(struct kobject *kobj, struct attribute *attr,
 }
 LUSTRE_RO_ATTR(client_type);
 
+LUSTRE_RW_ATTR(foreign_symlink_enable);
+
+LUSTRE_RW_ATTR(foreign_symlink_prefix);
+
+LUSTRE_RW_ATTR(foreign_symlink_upcall);
+
+LUSTRE_WO_ATTR(foreign_symlink_upcall_info);
+
 static ssize_t fstype_show(struct kobject *kobj, struct attribute *attr,
 			   char *buf)
 {
@@ -1551,6 +1559,10 @@ struct ldebugfs_vars lprocfs_llite_obd_vars[] = {
 	&lustre_attr_filestotal.attr,
 	&lustre_attr_filesfree.attr,
 	&lustre_attr_client_type.attr,
+	&lustre_attr_foreign_symlink_enable.attr,
+	&lustre_attr_foreign_symlink_prefix.attr,
+	&lustre_attr_foreign_symlink_upcall.attr,
+	&lustre_attr_foreign_symlink_upcall_info.attr,
 	&lustre_attr_fstype.attr,
 	&lustre_attr_uuid.attr,
 	&lustre_attr_max_read_ahead_mb.attr,
diff --git a/fs/lustre/llite/namei.c b/fs/lustre/llite/namei.c
index 7f1fd5c..2da33d0 100644
--- a/fs/lustre/llite/namei.c
+++ b/fs/lustre/llite/namei.c
@@ -48,7 +48,7 @@
 static int ll_create_it(struct inode *dir, struct dentry *dentry,
 			struct lookup_intent *it,
 			void *secctx, u32 secctxlen, bool encrypt,
-			void *encctx, __u32 encctxlen);
+			void *encctx, u32 encctxlen);
 
 /* called from iget5_locked->find_inode() under inode_hash_lock spinlock */
 static int ll_test_inode(struct inode *inode, void *opaque)
@@ -597,6 +597,23 @@ struct dentry *ll_splice_alias(struct inode *inode, struct dentry *de)
 	} else {
 		struct dentry *new = d_splice_alias(inode, de);
 
+		/* this needs only to be done for foreign symlink dirs as
+		 * DCACHE_SYMLINK_TYPE is already set by d_flags_for_inode()
+		 * kernel routine for files with symlink ops (ie, real symlink)
+		 */
+		if (inode && ll_sbi_has_foreign_symlink(ll_i2sbi(inode)) &&
+		    inode->i_op->get_link) {
+			CDEBUG(D_INFO,
+			       "%s: inode "DFID": faking foreign dir as a symlink\n",
+			       ll_i2sbi(inode)->ll_fsname,
+			       PFID(ll_inode2fid(inode)));
+			spin_lock(&de->d_lock);
+			/* like d_flags_for_inode() already does for files */
+			de->d_flags = (de->d_flags & ~DCACHE_ENTRY_TYPE) |
+				      DCACHE_SYMLINK_TYPE;
+			spin_unlock(&de->d_lock);
+		}
+
 		if (IS_ERR(new))
 			CDEBUG(D_DENTRY,
 			       "splice inode %p as %pd gives error %lu\n",
@@ -1187,8 +1204,8 @@ static int ll_atomic_open(struct inode *dir, struct dentry *dentry,
 			}
 		}
 
-		if (d_really_is_positive(dentry) &&
-		    it_disposition(it, DISP_OPEN_OPEN)) {
+		if (dentry->d_inode && it_disposition(it, DISP_OPEN_OPEN) &&
+		    ll_foreign_is_openable(dentry, open_flags)) {
 			/* Open dentry. */
 			if (S_ISFIFO(d_inode(dentry)->i_mode)) {
 				/* We cannot call open here as it might
@@ -1270,7 +1287,7 @@ static struct inode *ll_create_node(struct inode *dir, struct lookup_intent *it)
 static int ll_create_it(struct inode *dir, struct dentry *dentry,
 			struct lookup_intent *it,
 			void *secctx, u32 secctxlen, bool encrypt,
-			void *encctx, __u32 encctxlen)
+			void *encctx, u32 encctxlen)
 {
 	struct inode *inode;
 	u64 bits = 0;
@@ -1581,6 +1598,10 @@ static int ll_unlink(struct inode *dir, struct dentry *dchild)
 	CDEBUG(D_VFSTRACE, "VFS Op:name=%pd,dir=%lu/%u(%p)\n",
 	       dchild, dir->i_ino, dir->i_generation, dir);
 
+	/* some foreign file/dir may not be allowed to be unlinked */
+	if (!ll_foreign_is_removable(dchild, false))
+		return -EPERM;
+
 	op_data = ll_prep_md_op_data(NULL, dir, NULL,
 				     dchild->d_name.name,
 				     dchild->d_name.len,
@@ -1647,6 +1668,10 @@ static int ll_rmdir(struct inode *dir, struct dentry *dchild)
 	CDEBUG(D_VFSTRACE, "VFS Op:name=%pd, dir=" DFID "(%p)\n",
 	       dchild, PFID(ll_inode2fid(dir)), dir);
 
+	/* some foreign dir may not be allowed to be removed */
+	if (!ll_foreign_is_removable(dchild, false))
+		return -EPERM;
+
 	op_data = ll_prep_md_op_data(NULL, dir, NULL,
 				     dchild->d_name.name,
 				     dchild->d_name.len,
diff --git a/fs/lustre/llite/pcc.c b/fs/lustre/llite/pcc.c
index b259fa5..8430fff 100644
--- a/fs/lustre/llite/pcc.c
+++ b/fs/lustre/llite/pcc.c
@@ -1152,12 +1152,12 @@ static int pcc_get_layout_info(struct inode *inode, struct cl_layout *clt)
 		return PTR_ERR(env);
 
 	rc = cl_object_layout_get(env, lli->lli_clob, clt);
-	if (rc)
+	if (rc < 0)
 		CDEBUG(D_INODE, "Cannot get layout for "DFID"\n",
 		       PFID(ll_inode2fid(inode)));
 
 	cl_env_put(env, &refcheck);
-	return rc;
+	return rc < 0 ? rc : 0;
 }
 
 static int pcc_fid2dataset_fullpath(char *buf, int sz, struct lu_fid *fid,
diff --git a/fs/lustre/llite/symlink.c b/fs/lustre/llite/symlink.c
index f78db86..cf5ad9e 100644
--- a/fs/lustre/llite/symlink.c
+++ b/fs/lustre/llite/symlink.c
@@ -37,6 +37,7 @@
 
 #include "llite_internal.h"
 
+/* Must be called with lli_size_mutex locked */
 static int ll_readlink_internal(struct inode *inode,
 				struct ptlrpc_request **request, char **symname)
 {
diff --git a/fs/lustre/lov/lov_object.c b/fs/lustre/lov/lov_object.c
index ee61983..16fed09 100644
--- a/fs/lustre/lov/lov_object.c
+++ b/fs/lustre/lov/lov_object.c
@@ -2177,7 +2177,8 @@ static int lov_object_layout_get(const struct lu_env *env,
 	rc = lov_lsm_pack(lsm, buf->lb_buf, buf->lb_len);
 	lov_lsm_put(lsm);
 
-	return rc < 0 ? rc : 0;
+	/* return error or number of bytes */
+	return rc;
 }
 
 static loff_t lov_object_maxbytes(struct cl_object *obj)
diff --git a/fs/lustre/lov/lov_pack.c b/fs/lustre/lov/lov_pack.c
index 9b5fb9c..438bf36 100644
--- a/fs/lustre/lov/lov_pack.c
+++ b/fs/lustre/lov/lov_pack.c
@@ -163,8 +163,14 @@ static ssize_t lov_lsm_pack_foreign(const struct lov_stripe_md *lsm, void *buf,
 	if (buf_size == 0)
 		return lfm_size;
 
-	if (buf_size < lfm_size)
+	/* if buffer too small return ERANGE but copy the size the
+	 * caller has requested anyway. This may be useful to get
+	 * only the header without the need to alloc the full size
+	 */
+	if (buf_size < lfm_size) {
+		memcpy(lfm, lsm_foreign(lsm), buf_size);
 		return -ERANGE;
+	}
 
 	/* full foreign LOV is already avail in its cache
 	 * no need to translate format fields to little-endian
@@ -189,8 +195,10 @@ ssize_t lov_lsm_pack(const struct lov_stripe_md *lsm, void *buf,
 	if (lsm->lsm_magic == LOV_MAGIC_V1 || lsm->lsm_magic == LOV_MAGIC_V3)
 		return lov_lsm_pack_v1v3(lsm, buf, buf_size);
 
-	if (lsm->lsm_magic == LOV_MAGIC_FOREIGN)
+	if (lsm->lsm_magic == LOV_MAGIC_FOREIGN) {
+		pr_info("calling lov_lsm_pack_foreign\n");
 		return lov_lsm_pack_foreign(lsm, buf, buf_size);
+	}
 
 	lmm_size = lov_comp_md_size(lsm);
 	if (buf_size == 0)
@@ -370,6 +378,7 @@ int lov_getstripe(const struct lu_env *env, struct lov_object *obj,
 
 	lmm_size = lov_lsm_pack(lsm, lmmk, lmmk_size);
 	if (lmm_size < 0) {
+		pr_info("lov_lsm_pack return rc = %zd\n", lmm_size);
 		rc = lmm_size;
 		goto out_free;
 	}
diff --git a/include/uapi/linux/lustre/lustre_user.h b/include/uapi/linux/lustre/lustre_user.h
index 5d46ec9..542d2d3 100644
--- a/include/uapi/linux/lustre/lustre_user.h
+++ b/include/uapi/linux/lustre/lustre_user.h
@@ -360,6 +360,7 @@ struct ll_ioc_lease_id {
 #define LL_IOC_LMV_SETSTRIPE		_IOWR('f', 240, struct lmv_user_md)
 #define LL_IOC_LMV_GETSTRIPE		_IOWR('f', 241, struct lmv_user_md)
 #define LL_IOC_RMFID			_IOR('f', 242, struct fid_array)
+#define LL_IOC_UNLOCK_FOREIGN		_IO('f', 242)
 #define LL_IOC_SET_LEASE		_IOWR('f', 243, struct ll_ioc_lease)
 #define LL_IOC_SET_LEASE_OLD		_IOWR('f', 243, long)
 #define LL_IOC_GET_LEASE		_IO('f', 244)
@@ -769,7 +770,7 @@ struct lustre_foreign_type {
  **/
 enum lustre_foreign_types {
 	LU_FOREIGN_TYPE_NONE = 0,
-	LU_FOREIGN_TYPE_DAOS = 0xda05,
+	LU_FOREIGN_TYPE_SYMLINK = 0xda05,
 	/* must be the max/last one */
 	LU_FOREIGN_TYPE_UNKNOWN = 0xffffffff,
 };
@@ -2280,6 +2281,52 @@ struct fid_array {
 };
 #define OBD_MAX_FIDS_IN_ARRAY	4096
 
+/* more types could be defined upon need for more complex
+ * format to be used in foreign symlink LOV/LMV EAs, like
+ * one to describe a delimiter string and occurence number
+ * of delimited sub-string, ...
+ */
+enum ll_foreign_symlink_upcall_item_type {
+	EOB_TYPE = 1,
+	STRING_TYPE = 2,
+	POSLEN_TYPE = 3,
+};
+
+/* may need to be modified to allow for more format items to be defined, and
+ * like for ll_foreign_symlink_upcall_item_type enum
+ */
+struct ll_foreign_symlink_upcall_item {
+	__u32 type;
+	union {
+		struct {
+			__u32 pos;
+			__u32 len;
+		};
+		struct {
+			size_t size;
+			union {
+				/* internal storage of constant string */
+				char *string;
+				/* upcall stores constant string in a raw */
+				char bytestring[0];
+			};
+		};
+	};
+};
+
+#define POSLEN_ITEM_SZ (offsetof(struct ll_foreign_symlink_upcall_item, len) + \
+		sizeof(((struct ll_foreign_symlink_upcall_item *)0)->len))
+#define STRING_ITEM_SZ(sz) ( \
+	offsetof(struct ll_foreign_symlink_upcall_item, bytestring) + \
+	(sz + sizeof(__u32) - 1) / sizeof(__u32) * sizeof(__u32))
+
+/* presently limited to not cause max stack frame size to be reached
+ * because of temporary automatic array of
+ * "struct ll_foreign_symlink_upcall_item" presently used in
+ * foreign_symlink_upcall_info_store()
+ */
+#define MAX_NB_UPCALL_ITEMS 32
+
 #if defined(__cplusplus)
 }
 #endif
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
