Return-Path: <SRS0=FD7t=JM=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 07BC8C433B4
	for <lustre-devel@archiver.kernel.org>; Thu, 15 Apr 2021 04:05:33 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id BA0ED610CB
	for <lustre-devel@archiver.kernel.org>; Thu, 15 Apr 2021 04:05:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BA0ED610CB
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 5A563329C50;
	Wed, 14 Apr 2021 21:04:13 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 9A05132F3FA
 for <lustre-devel@lists.lustre.org>; Wed, 14 Apr 2021 21:02:47 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 52A5A100F333;
 Thu, 15 Apr 2021 00:02:45 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 4762A9188F; Thu, 15 Apr 2021 00:02:45 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Thu, 15 Apr 2021 00:01:55 -0400
Message-Id: <1618459361-17909-4-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1618459361-17909-1-git-send-email-jsimmons@infradead.org>
References: <1618459361-17909-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 03/49] lustre: llite: mark extended attr and
 inode flags
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

From: Andreas Dilger <adilger@whamcloud.com>

Clearly name the extended attribute and inode flags so that it is
possible to distinguish them more easily.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12885
Lustre-commit: b51a1e1140cac80c ("LU-12885 llite: mark extended attr and inode flags")
Signed-off-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/36519
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Arshad Hussain <arshad.hussain@aeoncomputing.com>
Reviewed-by: Neil Brown <neilb@suse.de>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/obd_support.h        | 28 ++++++++++++++--------------
 fs/lustre/llite/file.c                 | 25 ++++++++++---------------
 fs/lustre/llite/llite_internal.h       | 12 ++++++------
 fs/lustre/llite/llite_lib.c            |  2 +-
 include/uapi/linux/lustre/lustre_idl.h |  4 +++-
 5 files changed, 34 insertions(+), 37 deletions(-)

diff --git a/fs/lustre/include/obd_support.h b/fs/lustre/include/obd_support.h
index c678c8b..152f95c 100644
--- a/fs/lustre/include/obd_support.h
+++ b/fs/lustre/include/obd_support.h
@@ -554,28 +554,28 @@
  * versions. These flags are set/cleared via FSFILT_IOC_{GET,SET}_FLAGS.
  * See b=16526 for a full history.
  */
-static inline int ll_ext_to_inode_flags(int flags)
+static inline int ll_ext_to_inode_flags(int ext_flags)
 {
-	return (((flags & LUSTRE_SYNC_FL)      ? S_SYNC      : 0) |
-		((flags & LUSTRE_NOATIME_FL)   ? S_NOATIME   : 0) |
-		((flags & LUSTRE_APPEND_FL)    ? S_APPEND    : 0) |
-		((flags & LUSTRE_DIRSYNC_FL)   ? S_DIRSYNC   : 0) |
+	return (((ext_flags & LUSTRE_SYNC_FL)      ? S_SYNC      : 0) |
+		((ext_flags & LUSTRE_NOATIME_FL)   ? S_NOATIME   : 0) |
+		((ext_flags & LUSTRE_APPEND_FL)    ? S_APPEND    : 0) |
+		((ext_flags & LUSTRE_DIRSYNC_FL)   ? S_DIRSYNC   : 0) |
 #if defined(S_ENCRYPTED)
-		((flags & LUSTRE_ENCRYPT_FL)   ? S_ENCRYPTED : 0) |
+		((ext_flags & LUSTRE_ENCRYPT_FL)   ? S_ENCRYPTED : 0) |
 #endif
-		((flags & LUSTRE_IMMUTABLE_FL) ? S_IMMUTABLE : 0));
+		((ext_flags & LUSTRE_IMMUTABLE_FL) ? S_IMMUTABLE : 0));
 }
 
-static inline int ll_inode_to_ext_flags(int iflags)
+static inline int ll_inode_to_ext_flags(int inode_flags)
 {
-	return (((iflags & S_SYNC)      ? LUSTRE_SYNC_FL      : 0) |
-		((iflags & S_NOATIME)   ? LUSTRE_NOATIME_FL   : 0) |
-		((iflags & S_APPEND)    ? LUSTRE_APPEND_FL    : 0) |
-		((iflags & S_DIRSYNC)   ? LUSTRE_DIRSYNC_FL   : 0) |
+	return (((inode_flags & S_SYNC)      ? LUSTRE_SYNC_FL      : 0) |
+		((inode_flags & S_NOATIME)   ? LUSTRE_NOATIME_FL   : 0) |
+		((inode_flags & S_APPEND)    ? LUSTRE_APPEND_FL    : 0) |
+		((inode_flags & S_DIRSYNC)   ? LUSTRE_DIRSYNC_FL   : 0) |
 #if defined(S_ENCRYPTED)
-		((iflags & S_ENCRYPTED) ? LUSTRE_ENCRYPT_FL   : 0) |
+		((inode_flags & S_ENCRYPTED) ? LUSTRE_ENCRYPT_FL   : 0) |
 #endif
-		((iflags & S_IMMUTABLE) ? LUSTRE_IMMUTABLE_FL : 0));
+		((inode_flags & S_IMMUTABLE) ? LUSTRE_IMMUTABLE_FL : 0));
 }
 
 struct obd_heat_instance {
diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index c6d53b1..0d866ec 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -3182,9 +3182,8 @@ int ll_ioctl_fssetxattr(struct inode *inode, unsigned int cmd,
 	struct md_op_data *op_data;
 	struct fsxattr fsxattr;
 	struct cl_object *obj;
-	struct iattr *attr;
+	unsigned int inode_flags;
 	int rc = 0;
-	int flags;
 
 	if (copy_from_user(&fsxattr,
 			   (const struct fsxattr __user *)arg,
@@ -3200,8 +3199,8 @@ int ll_ioctl_fssetxattr(struct inode *inode, unsigned int cmd,
 	if (IS_ERR(op_data))
 		return PTR_ERR(op_data);
 
-	flags = ll_xflags_to_inode_flags(fsxattr.fsx_xflags);
-	op_data->op_attr_flags = ll_inode_to_ext_flags(flags);
+	inode_flags = ll_xflags_to_inode_flags(fsxattr.fsx_xflags);
+	op_data->op_attr_flags = ll_inode_to_ext_flags(inode_flags);
 	if (fsxattr.fsx_xflags & FS_XFLAG_PROJINHERIT)
 		op_data->op_attr_flags |= LUSTRE_PROJINHERIT_FL;
 	op_data->op_projid = fsxattr.fsx_projid;
@@ -3213,24 +3212,20 @@ int ll_ioctl_fssetxattr(struct inode *inode, unsigned int cmd,
 		goto out_fsxattr;
 
 	ll_update_inode_flags(inode, op_data->op_attr_flags);
-	obj = ll_i2info(inode)->lli_clob;
-	if (!obj)
-		goto out_fsxattr;
 
-	/* Avoiding OST RPC if this is only project ioctl */
+	/* Avoid OST RPC if this is only ioctl setting project inherit flag */
 	if (fsxattr.fsx_xflags == 0 ||
 	    fsxattr.fsx_xflags == FS_XFLAG_PROJINHERIT)
 		goto out_fsxattr;
 
-	attr = kzalloc(sizeof(*attr), GFP_KERNEL);
-	if (!attr) {
-		rc = -ENOMEM;
-		goto out_fsxattr;
+	obj = ll_i2info(inode)->lli_clob;
+	if (obj) {
+		struct iattr attr = { 0 };
+
+		rc = cl_setattr_ost(obj, &attr, OP_XVALID_FLAGS,
+				    fsxattr.fsx_xflags);
 	}
 
-	rc = cl_setattr_ost(obj, attr, OP_XVALID_FLAGS,
-			    fsxattr.fsx_xflags);
-	kfree(attr);
 out_fsxattr:
 	ll_finish_md_op_data(op_data);
 
diff --git a/fs/lustre/llite/llite_internal.h b/fs/lustre/llite/llite_internal.h
index 677106d..041f6d3 100644
--- a/fs/lustre/llite/llite_internal.h
+++ b/fs/lustre/llite/llite_internal.h
@@ -1081,12 +1081,12 @@ static inline int ll_xflags_to_inode_flags(int xflags)
 	       ((xflags & FS_XFLAG_IMMUTABLE) ? S_IMMUTABLE : 0);
 }
 
-static inline int ll_inode_flags_to_xflags(int flags)
+static inline int ll_inode_flags_to_xflags(int inode_flags)
 {
-	return ((flags & S_SYNC)      ? FS_XFLAG_SYNC      : 0) |
-	       ((flags & S_NOATIME)   ? FS_XFLAG_NOATIME   : 0) |
-	       ((flags & S_APPEND)    ? FS_XFLAG_APPEND    : 0) |
-	       ((flags & S_IMMUTABLE) ? FS_XFLAG_IMMUTABLE : 0);
+	return ((inode_flags & S_SYNC)      ? FS_XFLAG_SYNC      : 0) |
+	       ((inode_flags & S_NOATIME)   ? FS_XFLAG_NOATIME   : 0) |
+	       ((inode_flags & S_APPEND)    ? FS_XFLAG_APPEND    : 0) |
+	       ((inode_flags & S_IMMUTABLE) ? FS_XFLAG_IMMUTABLE : 0);
 }
 
 int ll_migrate(struct inode *parent, struct file *file,
@@ -1148,7 +1148,7 @@ int ll_setattr_raw(struct dentry *dentry, struct iattr *attr,
 int ll_statfs_internal(struct ll_sb_info *sbi, struct obd_statfs *osfs,
 		       u32 flags);
 int ll_update_inode(struct inode *inode, struct lustre_md *md);
-void ll_update_inode_flags(struct inode *inode, int ext_flags);
+void ll_update_inode_flags(struct inode *inode, unsigned int ext_flags);
 int ll_read_inode2(struct inode *inode, void *opaque);
 void ll_delete_inode(struct inode *inode);
 int ll_iocontrol(struct inode *inode, struct file *file,
diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index 3139669..ca6e736 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -2250,7 +2250,7 @@ void ll_inode_size_unlock(struct inode *inode)
 	mutex_unlock(&lli->lli_size_mutex);
 }
 
-void ll_update_inode_flags(struct inode *inode, int ext_flags)
+void ll_update_inode_flags(struct inode *inode, unsigned int ext_flags)
 {
 	struct ll_inode_info *lli = ll_i2info(inode);
 
diff --git a/include/uapi/linux/lustre/lustre_idl.h b/include/uapi/linux/lustre/lustre_idl.h
index 449ac47..3a33657 100644
--- a/include/uapi/linux/lustre/lustre_idl.h
+++ b/include/uapi/linux/lustre/lustre_idl.h
@@ -1614,7 +1614,9 @@ struct mdt_body {
 	__u32	mbo_mode;
 	__u32	mbo_uid;
 	__u32	mbo_gid;
-	__u32	mbo_flags;	/* LUSTRE_*_FL file attributes */
+	__u32	mbo_flags;	/* most replies: LUSTRE_*_FL file attributes,
+				 * data_version: OBD_FL_* flags
+				 */
 	__u32	mbo_rdev;
 	__u32	mbo_nlink;	/* #bytes to read in the case of MDS_READPAGE */
 	__u32	mbo_layout_gen;	/* was "generation" until 2.4.0 */
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
