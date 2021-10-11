Return-Path: <SRS0=0agL=O7=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C941DC433EF
	for <lustre-devel@archiver.kernel.org>; Mon, 11 Oct 2021 17:42:00 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 8BDB260EB6
	for <lustre-devel@archiver.kernel.org>; Mon, 11 Oct 2021 17:42:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.1 mail.kernel.org 8BDB260EB6
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 1D00C381544;
	Mon, 11 Oct 2021 10:41:38 -0700 (PDT)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 58F7121FDCE
 for <lustre-devel@lists.lustre.org>; Mon, 11 Oct 2021 10:40:57 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id C693F46F;
 Mon, 11 Oct 2021 13:40:51 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id C4E92A9502; Mon, 11 Oct 2021 13:40:51 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon, 11 Oct 2021 13:40:43 -0400
Message-Id: <1633974049-26490-15-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1633974049-26490-1-git-send-email-jsimmons@infradead.org>
References: <1633974049-26490-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 14/20] lustre: llite: harden ll_sbi ll_flags
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

For most file systems mount flags are straight forward but this
is not the case for Lustre. We have to consider if the server
backend supports a mount option. Additionally its possible to
disable or enable a feature using sysfs during run time. Some
features can't be managed with a mount option but still can
be managed with sysfs or based on what is enabled on the server
node. All these states are reported together in the debugfs
file sbi_flags. The mount specific options are reported in
the super block show_option ll_show_option().

With all this complexity it is easy for it to get out of sync
and report incorrect things. We consolidate this handling by
moving to using match_table_t that is used by various Linux
file system to parse options. LL_SBI_FLAGS is replaced by our
match_table_t, ll_sbi_flags_name, that can be used for mount
options as well as reporting the sbi_flags in debugfs. We take
advantage of the fact that mount option parse will stop at the
first NULL in ll_sbi_flags_name and after that NULL list the
other features flags that are managed with other methods besides
mount options.

The next change is the move of ll_flags to a bitmap which gives
us two advantages. The first is that we can support more than
32 flags in the future. Second is no need to use bit shifting
math since we can use th enum LL_SBI_* values directly with
clear_bit() / set_bit() / test_bit(). Allow these changes should
miminize future problems with keeping all these states in sync.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12262
Lustre-commit: 47e6f6abdacd6a3c ("LU-12262 llite: harden ll_sbi ll_flags")
Signed-off-by: James Simmons <jsimmons@infradead.org>
Reviewed-on: https://review.whamcloud.com/44541
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Neil Brown <neilb@suse.de>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
---
 fs/lustre/llite/crypto.c                |  15 +-
 fs/lustre/llite/dir.c                   |  25 +-
 fs/lustre/llite/file.c                  |  12 +-
 fs/lustre/llite/llite_foreign_symlink.c |  12 +-
 fs/lustre/llite/llite_internal.h        | 125 +++-----
 fs/lustre/llite/llite_lib.c             | 490 ++++++++++++++++----------------
 fs/lustre/llite/lproc_llite.c           |  78 ++---
 fs/lustre/llite/namei.c                 |  13 +-
 fs/lustre/llite/statahead.c             |   3 +-
 fs/lustre/llite/xattr.c                 |  17 +-
 10 files changed, 359 insertions(+), 431 deletions(-)

diff --git a/fs/lustre/llite/crypto.c b/fs/lustre/llite/crypto.c
index 0fae9a5..0388e360 100644
--- a/fs/lustre/llite/crypto.c
+++ b/fs/lustre/llite/crypto.c
@@ -133,7 +133,7 @@ static int ll_set_context(struct inode *inode, const void *ctx, size_t len,
 
 bool ll_sbi_has_test_dummy_encryption(struct ll_sb_info *sbi)
 {
-	return unlikely(sbi->ll_flags & LL_SBI_TEST_DUMMY_ENCRYPTION);
+	return unlikely(test_bit(LL_SBI_TEST_DUMMY_ENCRYPTION, sbi->ll_flags));
 }
 
 static bool ll_dummy_context(struct inode *inode)
@@ -145,16 +145,17 @@ static bool ll_dummy_context(struct inode *inode)
 
 bool ll_sbi_has_encrypt(struct ll_sb_info *sbi)
 {
-	return sbi->ll_flags & LL_SBI_ENCRYPT;
+	return test_bit(LL_SBI_ENCRYPT, sbi->ll_flags);
 }
 
 void ll_sbi_set_encrypt(struct ll_sb_info *sbi, bool set)
 {
-	if (set)
-		sbi->ll_flags |= LL_SBI_ENCRYPT;
-	else
-		sbi->ll_flags &=
-			~(LL_SBI_ENCRYPT | LL_SBI_TEST_DUMMY_ENCRYPTION);
+	if (set) {
+		set_bit(LL_SBI_ENCRYPT, sbi->ll_flags);
+	} else {
+		clear_bit(LL_SBI_ENCRYPT, sbi->ll_flags);
+		clear_bit(LL_SBI_TEST_DUMMY_ENCRYPTION, sbi->ll_flags);
+	}
 }
 
 static bool ll_empty_dir(struct inode *inode)
diff --git a/fs/lustre/llite/dir.c b/fs/lustre/llite/dir.c
index b7dd2aa..ee49c90 100644
--- a/fs/lustre/llite/dir.c
+++ b/fs/lustre/llite/dir.c
@@ -182,7 +182,7 @@ int ll_dir_read(struct inode *inode, u64 *ppos, struct md_op_data *op_data,
 	struct ll_sb_info *sbi = ll_i2sbi(inode);
 	u64 pos = *ppos;
 	bool is_api32 = ll_need_32bit_api(sbi);
-	bool is_hash64 = sbi->ll_flags & LL_SBI_64BIT_HASH;
+	bool is_hash64 = test_bit(LL_SBI_64BIT_HASH, sbi->ll_flags);
 	struct fscrypt_str lltr = FSTR_INIT(NULL, 0);
 	struct page *page;
 	bool done = false;
@@ -300,7 +300,7 @@ static int ll_readdir(struct file *filp, struct dir_context *ctx)
 	struct ll_file_data *lfd = filp->private_data;
 	struct ll_sb_info *sbi	= ll_i2sbi(inode);
 	u64 pos = lfd ? lfd->lfd_pos : 0;
-	int hash64 = sbi->ll_flags & LL_SBI_64BIT_HASH;
+	bool hash64 = test_bit(LL_SBI_64BIT_HASH, sbi->ll_flags);
 	bool api32 = ll_need_32bit_api(sbi);
 	struct md_op_data *op_data;
 	struct lu_fid pfid = { 0 };
@@ -495,7 +495,7 @@ static int ll_dir_setdirstripe(struct dentry *dparent, struct lmv_user_md *lump,
 		encrypt = true;
 	}
 
-	if (sbi->ll_flags & LL_SBI_FILE_SECCTX) {
+	if (test_bit(LL_SBI_FILE_SECCTX, sbi->ll_flags)) {
 		/*
 		 * selinux_dentry_init_security() uses dentry->d_parent and name
 		 * to determine the security context for the file. So our fake
@@ -534,7 +534,7 @@ static int ll_dir_setdirstripe(struct dentry *dparent, struct lmv_user_md *lump,
 
 	dentry.d_inode = inode;
 
-	if (sbi->ll_flags & LL_SBI_FILE_SECCTX) {
+	if (test_bit(LL_SBI_FILE_SECCTX, sbi->ll_flags)) {
 		/* no need to protect selinux_inode_setsecurity() by
 		 * inode_lock. Taking it would lead to a client deadlock
 		 * LU-13617
@@ -1270,13 +1270,14 @@ int quotactl_ioctl(struct super_block *sb, struct if_quotactl *qctl)
 int ll_rmfid(struct file *file, void __user *arg)
 {
 	const struct fid_array __user *ufa = arg;
+	struct inode *inode = file_inode(file);
 	struct fid_array *lfa = NULL;
 	size_t size;
 	unsigned int nr;
 	int i, rc, *rcs = NULL;
 
 	if (!capable(CAP_DAC_READ_SEARCH) &&
-	    !(ll_i2sbi(file_inode(file))->ll_flags & LL_SBI_USER_FID2PATH))
+	    !test_bit(LL_SBI_USER_FID2PATH, ll_i2sbi(inode)->ll_flags))
 		return -EPERM;
 	/* Only need to get the buflen */
 	if (get_user(nr, &ufa->fa_nr))
@@ -1719,6 +1720,7 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 		u32 __user *lmmsizep = NULL;
 		struct lu_fid __user *fidp = NULL;
 		int lmmsize;
+		bool api32;
 
 		if (cmd == IOC_MDC_GETFILEINFO_V1 ||
 		    cmd == IOC_MDC_GETFILEINFO_V2 ||
@@ -1791,6 +1793,7 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 			}
 			rc = -EOVERFLOW;
 		}
+		api32 = test_bit(LL_SBI_32BIT_API, sbi->ll_flags);
 
 		if (cmd == IOC_MDC_GETFILEINFO_V1 ||
 		    cmd == LL_IOC_MDC_GETINFO_V1) {
@@ -1808,9 +1811,7 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 			st.st_atime = body->mbo_atime;
 			st.st_mtime = body->mbo_mtime;
 			st.st_ctime = body->mbo_ctime;
-			st.st_ino = cl_fid_build_ino(&body->mbo_fid1,
-						     sbi->ll_flags &
-						     LL_SBI_32BIT_API);
+			st.st_ino = cl_fid_build_ino(&body->mbo_fid1, api32);
 
 			if (copy_to_user(statp, &st, sizeof(st))) {
 				rc = -EFAULT;
@@ -1827,8 +1828,7 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 			stx.stx_gid = body->mbo_gid;
 			stx.stx_mode = body->mbo_mode;
 			stx.stx_ino = cl_fid_build_ino(&body->mbo_fid1,
-						       sbi->ll_flags &
-						       LL_SBI_32BIT_API);
+						       api32);
 			stx.stx_size = body->mbo_size;
 			stx.stx_blocks = body->mbo_blocks;
 			stx.stx_atime.tv_sec = body->mbo_atime;
@@ -2252,10 +2252,13 @@ static loff_t ll_dir_seek(struct file *file, loff_t offset, int origin)
 	    ((api32 && offset <= LL_DIR_END_OFF_32BIT) ||
 	     (!api32 && offset <= LL_DIR_END_OFF))) {
 		if (offset != file->f_pos) {
+			bool hash64;
+
+			hash64 = test_bit(LL_SBI_64BIT_HASH, sbi->ll_flags);
 			if ((api32 && offset == LL_DIR_END_OFF_32BIT) ||
 			    (!api32 && offset == LL_DIR_END_OFF))
 				fd->lfd_pos = MDS_DIR_END_OFF;
-			else if (api32 && sbi->ll_flags & LL_SBI_64BIT_HASH)
+			else if (api32 && hash64)
 				fd->lfd_pos = offset << 32;
 			else
 				fd->lfd_pos = offset;
diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index ad1c07e..1e4ff49 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -2625,7 +2625,7 @@ int ll_fid2path(struct inode *inode, void __user *arg)
 	int rc;
 
 	if (!capable(CAP_DAC_READ_SEARCH) &&
-	    !(ll_i2sbi(inode)->ll_flags & LL_SBI_USER_FID2PATH))
+	    !test_bit(LL_SBI_USER_FID2PATH, ll_i2sbi(inode)->ll_flags))
 		return -EPERM;
 
 	/* Only need to get the buflen */
@@ -5393,9 +5393,8 @@ int ll_inode_permission(struct inode *inode, int mask)
 	squash = &sbi->ll_squash;
 	if (unlikely(squash->rsi_uid &&
 		     uid_eq(current_fsuid(), GLOBAL_ROOT_UID) &&
-		     !(sbi->ll_flags & LL_SBI_NOROOTSQUASH))) {
+		     !test_bit(LL_SBI_NOROOTSQUASH, sbi->ll_flags)))
 		squash_id = true;
-	}
 
 	if (squash_id) {
 		CDEBUG(D_OTHER, "squash creds (%d:%d)=>(%d:%d)\n",
@@ -5494,9 +5493,9 @@ const struct file_operations *ll_select_file_operations(struct ll_sb_info *sbi)
 {
 	const struct file_operations *fops = &ll_file_operations_noflock;
 
-	if (sbi->ll_flags & LL_SBI_FLOCK)
+	if (test_bit(LL_SBI_FLOCK, sbi->ll_flags))
 		fops = &ll_file_operations_flock;
-	else if (sbi->ll_flags & LL_SBI_LOCALFLOCK)
+	else if (test_bit(LL_SBI_LOCALFLOCK, sbi->ll_flags))
 		fops = &ll_file_operations;
 
 	return fops;
@@ -5787,7 +5786,8 @@ int ll_layout_refresh(struct inode *inode, u32 *gen)
 	int rc;
 
 	*gen = ll_layout_version_get(lli);
-	if (!(sbi->ll_flags & LL_SBI_LAYOUT_LOCK) || *gen != CL_LAYOUT_GEN_NONE)
+	if (!test_bit(LL_SBI_LAYOUT_LOCK, sbi->ll_flags) ||
+	    *gen != CL_LAYOUT_GEN_NONE)
 		return 0;
 
 	/* sanity checks */
diff --git a/fs/lustre/llite/llite_foreign_symlink.c b/fs/lustre/llite/llite_foreign_symlink.c
index 7ba33f4..bfade93 100644
--- a/fs/lustre/llite/llite_foreign_symlink.c
+++ b/fs/lustre/llite/llite_foreign_symlink.c
@@ -205,7 +205,7 @@ static int ll_foreign_symlink_parse(struct ll_sb_info *sbi,
 	 * of foreign LOV is relative path of faked symlink destination,
 	 * to be completed by prefix
 	 */
-	if (!(sbi->ll_flags & LL_SBI_FOREIGN_SYMLINK_UPCALL))
+	if (!test_bit(LL_SBI_FOREIGN_SYMLINK_UPCALL, sbi->ll_flags))
 		rc = ll_foreign_symlink_default_parse(sbi, inode, lfm,
 						      destname);
 	else /* upcall is available */
@@ -385,7 +385,7 @@ ssize_t foreign_symlink_enable_show(struct kobject *kobj,
 					      ll_kset.kobj);
 
 	return snprintf(buf, PAGE_SIZE, "%d\n",
-			!!(sbi->ll_flags & LL_SBI_FOREIGN_SYMLINK));
+			test_bit(LL_SBI_FOREIGN_SYMLINK, sbi->ll_flags));
 }
 
 /*
@@ -412,9 +412,9 @@ ssize_t foreign_symlink_enable_store(struct kobject *kobj,
 		return rc;
 
 	if (val)
-		sbi->ll_flags |= LL_SBI_FOREIGN_SYMLINK;
+		set_bit(LL_SBI_FOREIGN_SYMLINK, sbi->ll_flags);
 	else
-		sbi->ll_flags &= ~LL_SBI_FOREIGN_SYMLINK;
+		clear_bit(LL_SBI_FOREIGN_SYMLINK, sbi->ll_flags);
 
 	return count;
 }
@@ -545,7 +545,7 @@ ssize_t foreign_symlink_upcall_store(struct kobject *kobj,
 	 * order, we may end up using the format provided by a different
 	 * upcall than the one set in ll_foreign_symlink_upcall
 	 */
-	sbi->ll_flags &= ~LL_SBI_FOREIGN_SYMLINK_UPCALL;
+	clear_bit(LL_SBI_FOREIGN_SYMLINK_UPCALL, sbi->ll_flags);
 	up_write(&sbi->ll_foreign_symlink_sem);
 
 	if (strcmp(new, "none")) {
@@ -692,7 +692,7 @@ ssize_t foreign_symlink_upcall_info_store(struct kobject *kobj,
 	old_nb_items = sbi->ll_foreign_symlink_upcall_nb_items;
 	sbi->ll_foreign_symlink_upcall_items = new_items;
 	sbi->ll_foreign_symlink_upcall_nb_items = nb_items;
-	sbi->ll_flags |= LL_SBI_FOREIGN_SYMLINK_UPCALL;
+	set_bit(LL_SBI_FOREIGN_SYMLINK_UPCALL, sbi->ll_flags);
 	up_write(&sbi->ll_foreign_symlink_sem);
 
 	/* free old_items */
diff --git a/fs/lustre/llite/llite_internal.h b/fs/lustre/llite/llite_internal.h
index afd5c7a..bd49228 100644
--- a/fs/lustre/llite/llite_internal.h
+++ b/fs/lustre/llite/llite_internal.h
@@ -45,6 +45,8 @@
 #include <lustre_mdc.h>
 #include <lustre_intent.h>
 #include <linux/compat.h>
+#include <linux/aio.h>
+#include <linux/parser.h>
 #include <lustre_crypto.h>
 #include <range_lock.h>
 #include <linux/namei.h>
@@ -602,82 +604,41 @@ enum stats_track_type {
 	STATS_TRACK_LAST,
 };
 
-/* flags for sbi->ll_flags */
-#define LL_SBI_NOLCK	     0x01 /* DLM locking disabled (directio-only) */
-#define LL_SBI_CHECKSUM	  0x02 /* checksum each page as it's written */
-#define LL_SBI_FLOCK	     0x04
-#define LL_SBI_USER_XATTR	0x08 /* support user xattr */
-#define LL_SBI_ACL	       0x10 /* support ACL */
-/* LL_SBI_RMT_CLIENT		 0x40	 remote client */
-#define LL_SBI_MDS_CAPA		 0x80 /* support mds capa, obsolete */
-#define LL_SBI_OSS_CAPA		0x100 /* support oss capa, obsolete */
-#define LL_SBI_LOCALFLOCK       0x200 /* Local flocks support by kernel */
-#define LL_SBI_LRU_RESIZE       0x400 /* lru resize support */
-#define LL_SBI_LAZYSTATFS       0x800 /* lazystatfs mount option */
-/*	LL_SBI_SOM_PREVIEW     0x1000    SOM preview mount option, obsolete */
-#define LL_SBI_32BIT_API       0x2000 /* generate 32 bit inodes. */
-#define LL_SBI_64BIT_HASH      0x4000 /* support 64-bits dir hash/offset */
-#define LL_SBI_AGL_ENABLED     0x8000 /* enable agl */
-#define LL_SBI_VERBOSE	0x10000 /* verbose mount/umount */
-#define LL_SBI_LAYOUT_LOCK    0x20000 /* layout lock support */
-#define LL_SBI_USER_FID2PATH  0x40000 /* allow fid2path by unprivileged users */
-#define LL_SBI_XATTR_CACHE    0x80000 /* support for xattr cache */
-#define LL_SBI_NOROOTSQUASH	0x100000 /* do not apply root squash */
-#define LL_SBI_ALWAYS_PING	0x200000 /* always ping even if server
-					  * suppress_pings
-					  */
-#define LL_SBI_FAST_READ	0x400000 /* fast read support */
-#define LL_SBI_FILE_SECCTX	0x800000 /* set file security context at
-					  * create
-					  */
-#define LL_SBI_TINY_WRITE	0x2000000 /* tiny write support */
-#define LL_SBI_FILE_HEAT    0x4000000 /* file heat support */
-#define LL_SBI_TEST_DUMMY_ENCRYPTION	0x8000000 /* test dummy encryption */
-#define LL_SBI_ENCRYPT	   0x10000000 /* client side encryption */
-#define LL_SBI_FOREIGN_SYMLINK	0x20000000 /* foreign fake-symlink support */
-/* foreign fake-symlink upcall registered */
-#define LL_SBI_FOREIGN_SYMLINK_UPCALL	0x40000000
-#define LL_SBI_PARALLEL_DIO     0x80000000 /* parallel (async) submission of
-					    * RPCs for DIO
-					    */
+enum ll_sbi_flags {
+	LL_SBI_NOLCK,			/* DLM locking disabled directio-only */
+	LL_SBI_CHECKSUM,		/* checksum each page as it's written */
+	LL_SBI_LOCALFLOCK,		/* local flocks instead of fs-wide */
+	LL_SBI_FLOCK,			/* flock enabled */
+	LL_SBI_USER_XATTR,		/* support user xattr */
+	LL_SBI_LRU_RESIZE,		/* lru resize support */
+	LL_SBI_LAZYSTATFS,		/* lazystatfs mount option */
+	LL_SBI_32BIT_API,		/* generate 32 bit inodes. */
+	LL_SBI_USER_FID2PATH,		/* fid2path by unprivileged users */
+	LL_SBI_VERBOSE,			/* verbose mount/umount */
+	LL_SBI_ALWAYS_PING,		/* ping even if server suppress_pings */
+	LL_SBI_TEST_DUMMY_ENCRYPTION,	/* test dummy encryption */
+	LL_SBI_ENCRYPT,			/* client side encryption */
+	LL_SBI_FOREIGN_SYMLINK,		/* foreign fake-symlink support */
+	LL_SBI_FOREIGN_SYMLINK_UPCALL,	/* foreign fake-symlink upcall set */
+	LL_SBI_NUM_MOUNT_OPT,
+
+	LL_SBI_ACL,			/* support ACL */
+	LL_SBI_AGL_ENABLED,		/* enable agl */
+	LL_SBI_64BIT_HASH,		/* support 64-bits dir hash/offset */
+	LL_SBI_LAYOUT_LOCK,		/* layout lock support */
+	LL_SBI_XATTR_CACHE,		/* support for xattr cache */
+	LL_SBI_NOROOTSQUASH,		/* do not apply root squash */
+	LL_SBI_FAST_READ,		/* fast read support */
+	LL_SBI_FILE_SECCTX,		/* file security context at create */
+	LL_SBI_TINY_WRITE,		/* tiny write support */
+	LL_SBI_FILE_HEAT,		/* file heat support */
+	LL_SBI_PARALLEL_DIO,		/* parallel (async) O_DIRECT RPCs */
+	LL_SBI_NUM_FLAGS
+};
 
-#define LL_SBI_FLAGS {	\
-	"nolck",	\
-	"checksum",	\
-	"flock",	\
-	"user_xattr",	\
-	"acl",		\
-	"???",		\
-	"???",		\
-	"mds_capa",	\
-	"oss_capa",	\
-	"flock",	\
-	"lru_resize",	\
-	"lazy_statfs",	\
-	"som",		\
-	"32bit_api",	\
-	"64bit_hash",	\
-	"agl",		\
-	"verbose",	\
-	"layout",	\
-	"user_fid2path",\
-	"xattr_cache",	\
-	"norootsquash",	\
-	"always_ping",	\
-	"fast_read",    \
-	"file_secctx",	\
-	"pio",		\
-	"tiny_write",	\
-	"file_heat",	\
-	"test_dummy_encryption", \
-	"noencrypt",	\
-	"foreign_symlink",	\
-	"foreign_symlink_upcall",	\
-	"parallel_dio",	\
-}
+int ll_sbi_flags_seq_show(struct seq_file *m, void *v);
 
-/*
- * This is embedded into llite super-blocks to keep track of connect
+/* This is embedded into llite super-blocks to keep track of connect
  * flags (capabilities) supported by all imports given mount is
  * connected to.
  */
@@ -708,7 +669,7 @@ struct ll_sb_info {
 	struct dentry		*ll_debugfs_entry;
 	struct lu_fid		ll_root_fid; /* root object fid */
 
-	int			ll_flags;
+	DECLARE_BITMAP(ll_flags, LL_SBI_NUM_FLAGS); /* enum ll_sbi_flags */
 	unsigned int		ll_xattr_cache_enabled:1,
 				ll_xattr_cache_set:1, /* already set to 0/1 */
 				ll_client_common_fill_super_succeeded:1,
@@ -970,7 +931,7 @@ static inline bool ll_need_32bit_api(struct ll_sb_info *sbi)
 #if BITS_PER_LONG == 32
 	return true;
 #else
-	if (unlikely(sbi->ll_flags & LL_SBI_32BIT_API))
+	if (unlikely(test_bit(LL_SBI_32BIT_API, sbi->ll_flags)))
 		return true;
 
 #if defined(CONFIG_COMPAT)
@@ -991,27 +952,27 @@ static inline bool ll_need_32bit_api(struct ll_sb_info *sbi)
 
 static inline bool ll_sbi_has_fast_read(struct ll_sb_info *sbi)
 {
-	return !!(sbi->ll_flags & LL_SBI_FAST_READ);
+	return test_bit(LL_SBI_FAST_READ, sbi->ll_flags);
 }
 
 static inline bool ll_sbi_has_tiny_write(struct ll_sb_info *sbi)
 {
-	return !!(sbi->ll_flags & LL_SBI_TINY_WRITE);
+	return test_bit(LL_SBI_TINY_WRITE, sbi->ll_flags);
 }
 
 static inline bool ll_sbi_has_file_heat(struct ll_sb_info *sbi)
 {
-	return !!(sbi->ll_flags & LL_SBI_FILE_HEAT);
+	return test_bit(LL_SBI_FILE_HEAT, sbi->ll_flags);
 }
 
 static inline bool ll_sbi_has_foreign_symlink(struct ll_sb_info *sbi)
 {
-	return !!(sbi->ll_flags & LL_SBI_FOREIGN_SYMLINK);
+	return test_bit(LL_SBI_FOREIGN_SYMLINK, sbi->ll_flags);
 }
 
 static inline bool ll_sbi_has_parallel_dio(struct ll_sb_info *sbi)
 {
-	return !!(sbi->ll_flags & LL_SBI_PARALLEL_DIO);
+	return test_bit(LL_SBI_PARALLEL_DIO, sbi->ll_flags);
 }
 
 void ll_ras_enter(struct file *f, loff_t pos, size_t count);
@@ -1615,7 +1576,7 @@ static inline int ll_file_nolock(const struct file *file)
 	struct inode *inode = file_inode(file);
 
 	return ((fd->fd_flags & LL_FILE_IGNORE_LOCK) ||
-		(ll_i2sbi(inode)->ll_flags & LL_SBI_NOLCK));
+		test_bit(LL_SBI_NOLCK, ll_i2sbi(inode)->ll_flags));
 }
 
 static inline void ll_set_lock_data(struct obd_export *exp, struct inode *inode,
diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index 9ff881c..abd470a 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -155,11 +155,11 @@ static struct ll_sb_info *ll_init_sbi(void)
 	sbi->ll_ra_info.ra_max_read_ahead_whole_pages = -1;
 	atomic_set(&sbi->ll_ra_info.ra_async_inflight, 0);
 
-	sbi->ll_flags |= LL_SBI_VERBOSE;
-	sbi->ll_flags |= LL_SBI_CHECKSUM;
-	sbi->ll_flags |= LL_SBI_FLOCK;
-	sbi->ll_flags |= LL_SBI_LRU_RESIZE;
-	sbi->ll_flags |= LL_SBI_LAZYSTATFS;
+	set_bit(LL_SBI_VERBOSE, sbi->ll_flags);
+	set_bit(LL_SBI_CHECKSUM, sbi->ll_flags);
+	set_bit(LL_SBI_FLOCK, sbi->ll_flags);
+	set_bit(LL_SBI_LRU_RESIZE, sbi->ll_flags);
+	set_bit(LL_SBI_LAZYSTATFS, sbi->ll_flags);
 
 	for (i = 0; i <= LL_PROCESS_HIST_MAX; i++) {
 		struct per_process_info *pp_ext;
@@ -176,10 +176,10 @@ static struct ll_sb_info *ll_init_sbi(void)
 	atomic_set(&sbi->ll_sa_wrong, 0);
 	atomic_set(&sbi->ll_sa_running, 0);
 	atomic_set(&sbi->ll_agl_total, 0);
-	sbi->ll_flags |= LL_SBI_AGL_ENABLED;
-	sbi->ll_flags |= LL_SBI_FAST_READ;
-	sbi->ll_flags |= LL_SBI_TINY_WRITE;
-	sbi->ll_flags |= LL_SBI_PARALLEL_DIO;
+	set_bit(LL_SBI_AGL_ENABLED, sbi->ll_flags);
+	set_bit(LL_SBI_FAST_READ, sbi->ll_flags);
+	set_bit(LL_SBI_TINY_WRITE, sbi->ll_flags);
+	set_bit(LL_SBI_PARALLEL_DIO, sbi->ll_flags);
 	ll_sbi_set_encrypt(sbi, true);
 
 	/* root squash */
@@ -257,6 +257,7 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt)
 	struct lustre_md lmd;
 	u64 valid;
 	int size, err, checksum;
+	bool api32;
 
 	sbi->ll_md_obd  = class_name2obd(md);
 	if (!sbi->ll_md_obd) {
@@ -320,7 +321,7 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt)
 				   OBD_CONNECT2_REP_MBITS |
 				   OBD_CONNECT2_ATOMIC_OPEN_LOCK;
 
-	if (sbi->ll_flags & LL_SBI_LRU_RESIZE)
+	if (test_bit(LL_SBI_LRU_RESIZE, sbi->ll_flags))
 		data->ocd_connect_flags |= OBD_CONNECT_LRU_RESIZE;
 	data->ocd_connect_flags |= OBD_CONNECT_ACL_FLAGS;
 
@@ -337,7 +338,7 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt)
 
 	if (sb_rdonly(sb))
 		data->ocd_connect_flags |= OBD_CONNECT_RDONLY;
-	if (sbi->ll_flags & LL_SBI_USER_XATTR)
+	if (test_bit(LL_SBI_USER_XATTR, sbi->ll_flags))
 		data->ocd_connect_flags |= OBD_CONNECT_XATTR;
 
 	/* Setting this indicates we correctly support S_NOSEC (See kernel
@@ -348,7 +349,7 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt)
 	sbi->ll_fop = ll_select_file_operations(sbi);
 
 	/* always ping even if server suppress_pings */
-	if (sbi->ll_flags & LL_SBI_ALWAYS_PING)
+	if (test_bit(LL_SBI_ALWAYS_PING, sbi->ll_flags))
 		data->ocd_connect_flags &= ~OBD_CONNECT_PINGLESS;
 
 	obd_connect_set_secctx(data);
@@ -451,29 +452,29 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt)
 	sbi->ll_namelen = osfs->os_namelen;
 	sbi->ll_mnt.mnt = current->fs->root.mnt;
 
-	if ((sbi->ll_flags & LL_SBI_USER_XATTR) &&
+	if (test_bit(LL_SBI_USER_XATTR, sbi->ll_flags) &&
 	    !(data->ocd_connect_flags & OBD_CONNECT_XATTR)) {
 		LCONSOLE_INFO("Disabling user_xattr feature because it is not supported on the server\n");
-		sbi->ll_flags &= ~LL_SBI_USER_XATTR;
+		clear_bit(LL_SBI_USER_XATTR, sbi->ll_flags);
 	}
 
 	if (data->ocd_connect_flags & OBD_CONNECT_ACL) {
 		sb->s_flags |= SB_POSIXACL;
-		sbi->ll_flags |= LL_SBI_ACL;
+		set_bit(LL_SBI_ACL, sbi->ll_flags);
 	} else {
 		LCONSOLE_INFO("client wants to enable acl, but mdt not!\n");
 		sb->s_flags &= ~SB_POSIXACL;
-		sbi->ll_flags &= ~LL_SBI_ACL;
+		clear_bit(LL_SBI_ACL, sbi->ll_flags);
 	}
 
 	if (data->ocd_connect_flags & OBD_CONNECT_64BITHASH)
-		sbi->ll_flags |= LL_SBI_64BIT_HASH;
+		set_bit(LL_SBI_64BIT_HASH, sbi->ll_flags);
 
 	if (data->ocd_connect_flags & OBD_CONNECT_LAYOUTLOCK)
-		sbi->ll_flags |= LL_SBI_LAYOUT_LOCK;
+		set_bit(LL_SBI_LAYOUT_LOCK, sbi->ll_flags);
 
 	if (obd_connect_has_secctx(data))
-		sbi->ll_flags |= LL_SBI_FILE_SECCTX;
+		set_bit(LL_SBI_FILE_SECCTX, sbi->ll_flags);
 
 	if (ll_sbi_has_encrypt(sbi) && !obd_connect_has_enc(data)) {
 		if (ll_sbi_has_test_dummy_encryption(sbi))
@@ -492,7 +493,7 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt)
 			 * during processing llog, it won't be enabled here.
 			 */
 			spin_lock(&sbi->ll_lock);
-			sbi->ll_flags |= LL_SBI_XATTR_CACHE;
+			set_bit(LL_SBI_XATTR_CACHE, sbi->ll_flags);
 			spin_unlock(&sbi->ll_lock);
 			sbi->ll_xattr_cache_enabled = 1;
 		}
@@ -542,7 +543,7 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt)
 	data->ocd_connect_flags |= OBD_CONNECT_LRU_RESIZE;
 
 	/* always ping even if server suppress_pings */
-	if (sbi->ll_flags & LL_SBI_ALWAYS_PING)
+	if (test_bit(LL_SBI_ALWAYS_PING, sbi->ll_flags))
 		data->ocd_connect_flags &= ~OBD_CONNECT_PINGLESS;
 
 	if (ll_sbi_has_encrypt(sbi))
@@ -630,7 +631,7 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt)
 	 * XXX: move this to after cbd setup?
 	 */
 	valid = OBD_MD_FLGETATTR | OBD_MD_FLBLOCKS | OBD_MD_FLMODEASIZE;
-	if (sbi->ll_flags & LL_SBI_ACL)
+	if (test_bit(LL_SBI_ACL, sbi->ll_flags))
 		valid |= OBD_MD_FLACL;
 
 	op_data = kzalloc(sizeof(*op_data), GFP_NOFS);
@@ -660,9 +661,8 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt)
 	}
 
 	LASSERT(fid_is_sane(&sbi->ll_root_fid));
-	root = ll_iget(sb, cl_fid_build_ino(&sbi->ll_root_fid,
-					    sbi->ll_flags & LL_SBI_32BIT_API),
-		       &lmd);
+	api32 = test_bit(LL_SBI_32BIT_API, sbi->ll_flags);
+	root = ll_iget(sb, cl_fid_build_ino(&sbi->ll_root_fid, api32), &lmd);
 	md_free_lustre_md(sbi->ll_md_exp, &lmd);
 	ptlrpc_req_finished(request);
 
@@ -673,7 +673,7 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt)
 		goto out_root;
 	}
 
-	checksum = sbi->ll_flags & LL_SBI_CHECKSUM;
+	checksum = test_bit(LL_SBI_CHECKSUM, sbi->ll_flags);
 	if (sbi->ll_checksum_set) {
 		err = obd_set_info_async(NULL, sbi->ll_dt_exp,
 					 sizeof(KEY_CHECKSUM), KEY_CHECKSUM,
@@ -864,183 +864,193 @@ void ll_kill_super(struct super_block *sb)
 	}
 }
 
-static inline int ll_set_opt(const char *opt, char *data, int fl)
+/* Since we use this table for ll_sbi_flags_seq_show make
+ * sure what you want displayed for a specific token that
+ * is listed more than once below be listed first. For
+ * example we want "checksum" displayed, not "nochecksum"
+ * for the sbi_flags.
+ */
+static const match_table_t ll_sbi_flags_name = {
+	{LL_SBI_NOLCK,			"nolock"},
+	{LL_SBI_CHECKSUM,		"checksum"},
+	{LL_SBI_CHECKSUM,		"nochecksum"},
+	{LL_SBI_LOCALFLOCK,		"localflock"},
+	{LL_SBI_FLOCK,			"flock"},
+	{LL_SBI_FLOCK,			"noflock"},
+	{LL_SBI_USER_XATTR,		"user_xattr"},
+	{LL_SBI_USER_XATTR,		"nouser_xattr"},
+	{LL_SBI_LRU_RESIZE,		"lruresize"},
+	{LL_SBI_LRU_RESIZE,		"nolruresize"},
+	{LL_SBI_LAZYSTATFS,		"lazystatfs"},
+	{LL_SBI_LAZYSTATFS,		"nolazystatfs"},
+	{LL_SBI_32BIT_API,		"32bitapi"},
+	{LL_SBI_USER_FID2PATH,		"user_fid2path"},
+	{LL_SBI_USER_FID2PATH,		"nouser_fid2path"},
+	{LL_SBI_VERBOSE,		"verbose"},
+	{LL_SBI_VERBOSE,		"noverbose"},
+	{LL_SBI_ALWAYS_PING,		"always_ping"},
+	{LL_SBI_TEST_DUMMY_ENCRYPTION,	"test_dummy_encryption"},
+	{LL_SBI_ENCRYPT,		"encrypt"},
+	{LL_SBI_ENCRYPT,		"noencrypt"},
+	{LL_SBI_FOREIGN_SYMLINK,	"foreign_symlink=%s"},
+	{LL_SBI_NUM_MOUNT_OPT,		NULL},
+
+	{LL_SBI_ACL,			"acl"},
+	{LL_SBI_AGL_ENABLED,		"agl"},
+	{LL_SBI_64BIT_HASH,		"64bit_hash"},
+	{LL_SBI_LAYOUT_LOCK,		"layout"},
+	{LL_SBI_XATTR_CACHE,		"xattr_cache"},
+	{LL_SBI_NOROOTSQUASH,		"norootsquash"},
+	{LL_SBI_FAST_READ,		"fast_read"},
+	{LL_SBI_FILE_SECCTX,		"file_secctx"},
+	{LL_SBI_TINY_WRITE,		"tiny_write"},
+	{LL_SBI_FILE_HEAT,		"file_heat"},
+	{LL_SBI_PARALLEL_DIO,		"parallel_dio"},
+};
+
+int ll_sbi_flags_seq_show(struct seq_file *m, void *v)
 {
-	if (strncmp(opt, data, strlen(opt)) != 0)
-		return 0;
-	else
-		return fl;
+	struct super_block *sb = m->private;
+	int i;
+
+	for (i = 0; i < LL_SBI_NUM_FLAGS; i++) {
+		int j;
+
+		if (!test_bit(i, ll_s2sbi(sb)->ll_flags))
+			continue;
+
+		for (j = 0; j < ARRAY_SIZE(ll_sbi_flags_name); j++) {
+			if (ll_sbi_flags_name[j].token == i &&
+			    ll_sbi_flags_name[j].pattern) {
+				seq_printf(m, "%s ",
+					   ll_sbi_flags_name[j].pattern);
+				break;
+			}
+		}
+	}
+	seq_puts(m, "\b\n");
+	return 0;
 }
 
 /* non-client-specific mount options are parsed in lmd_parse */
-static int ll_options(char *options, struct ll_sb_info *sbi)
+static int ll_options(char *options, struct super_block *sb)
 {
-	int tmp;
-	char *s1 = options, *s2;
-	int *flags = &sbi->ll_flags;
+	struct ll_sb_info *sbi = ll_s2sbi(sb);
+	char *s2, *s1, *opts;
 
 	if (!options)
 		return 0;
 
+	/* Don't stomp on lmd_opts */
+	opts = kstrdup(options, GFP_KERNEL);
+	if (!opts)
+		return -ENOMEM;
+	s1 = opts;
+	s2 = opts;
+
 	CDEBUG(D_CONFIG, "Parsing opts %s\n", options);
 
-	while (*s1) {
+	while ((s1 = strsep(&opts, ",")) != NULL) {
+		substring_t args[MAX_OPT_ARGS];
+		bool turn_off = false;
+		int token;
+
+		if (!*s1)
+			continue;
+
 		CDEBUG(D_SUPER, "next opt=%s\n", s1);
-		tmp = ll_set_opt("nolock", s1, LL_SBI_NOLCK);
-		if (tmp) {
-			*flags |= tmp;
-			goto next;
-		}
-		tmp = ll_set_opt("flock", s1, LL_SBI_FLOCK);
-		if (tmp) {
-			*flags = (*flags & ~LL_SBI_LOCALFLOCK) | tmp;
-			goto next;
-		}
-		tmp = ll_set_opt("localflock", s1, LL_SBI_LOCALFLOCK);
-		if (tmp) {
-			*flags = (*flags & ~LL_SBI_FLOCK) | tmp;
-			goto next;
-		}
-		tmp = ll_set_opt("noflock", s1,
-				 LL_SBI_FLOCK | LL_SBI_LOCALFLOCK);
-		if (tmp) {
-			*flags &= ~tmp;
-			goto next;
-		}
-		tmp = ll_set_opt("user_xattr", s1, LL_SBI_USER_XATTR);
-		if (tmp) {
-			*flags |= tmp;
-			goto next;
-		}
-		tmp = ll_set_opt("nouser_xattr", s1, LL_SBI_USER_XATTR);
-		if (tmp) {
-			*flags &= ~tmp;
-			goto next;
-		}
-		tmp = ll_set_opt("context", s1, 1);
-		if (tmp)
-			goto next;
-		tmp = ll_set_opt("fscontext", s1, 1);
-		if (tmp)
-			goto next;
-		tmp = ll_set_opt("defcontext", s1, 1);
-		if (tmp)
-			goto next;
-		tmp = ll_set_opt("rootcontext", s1, 1);
-		if (tmp)
-			goto next;
-		tmp = ll_set_opt("user_fid2path", s1, LL_SBI_USER_FID2PATH);
-		if (tmp) {
-			*flags |= tmp;
-			goto next;
-		}
-		tmp = ll_set_opt("nouser_fid2path", s1, LL_SBI_USER_FID2PATH);
-		if (tmp) {
-			*flags &= ~tmp;
-			goto next;
-		}
+		if (strncmp(s1, "no", 2) == 0)
+			turn_off = true;
 
-		tmp = ll_set_opt("checksum", s1, LL_SBI_CHECKSUM);
-		if (tmp) {
-			*flags |= tmp;
-			sbi->ll_checksum_set = 1;
-			goto next;
+		/*
+		 * Initialize args struct so we know whether arg was
+		 * found; some options take optional arguments.
+		 */
+		args[0].to = NULL;
+		args[0].from = NULL;
+		token = match_token(s1, ll_sbi_flags_name, args);
+		if (token == LL_SBI_NUM_MOUNT_OPT) {
+			if (match_wildcard("context", s1) ||
+			    match_wildcard("fscontext", s1) ||
+			    match_wildcard("defcontext", s1) ||
+			    match_wildcard("rootcontext", s1))
+				continue;
+
+			LCONSOLE_ERROR_MSG(0x152,
+					   "Unknown option '%s', won't mount.\n",
+					   s1);
+			return -EINVAL;
 		}
-		tmp = ll_set_opt("nochecksum", s1, LL_SBI_CHECKSUM);
-		if (tmp) {
-			*flags &= ~tmp;
+
+		switch (token) {
+		case LL_SBI_NOLCK:
+		case LL_SBI_32BIT_API:
+		case LL_SBI_64BIT_HASH:
+		case LL_SBI_ALWAYS_PING:
+			set_bit(token, sbi->ll_flags);
+			break;
+
+		case LL_SBI_FLOCK:
+			clear_bit(LL_SBI_LOCALFLOCK, sbi->ll_flags);
+			if (turn_off)
+				clear_bit(LL_SBI_FLOCK, sbi->ll_flags);
+			else
+				set_bit(token, sbi->ll_flags);
+			break;
+
+		case LL_SBI_LOCALFLOCK:
+			clear_bit(LL_SBI_FLOCK, sbi->ll_flags);
+			set_bit(token, sbi->ll_flags);
+			break;
+
+		case LL_SBI_CHECKSUM:
 			sbi->ll_checksum_set = 1;
-			goto next;
-		}
-		tmp = ll_set_opt("lruresize", s1, LL_SBI_LRU_RESIZE);
-		if (tmp) {
-			*flags |= tmp;
-			goto next;
-		}
-		tmp = ll_set_opt("nolruresize", s1, LL_SBI_LRU_RESIZE);
-		if (tmp) {
-			*flags &= ~tmp;
-			goto next;
-		}
-		tmp = ll_set_opt("lazystatfs", s1, LL_SBI_LAZYSTATFS);
-		if (tmp) {
-			*flags |= tmp;
-			goto next;
-		}
-		tmp = ll_set_opt("nolazystatfs", s1, LL_SBI_LAZYSTATFS);
-		if (tmp) {
-			*flags &= ~tmp;
-			goto next;
-		}
-		tmp = ll_set_opt("32bitapi", s1, LL_SBI_32BIT_API);
-		if (tmp) {
-			*flags |= tmp;
-			goto next;
-		}
-		tmp = ll_set_opt("verbose", s1, LL_SBI_VERBOSE);
-		if (tmp) {
-			*flags |= tmp;
-			goto next;
-		}
-		tmp = ll_set_opt("noverbose", s1, LL_SBI_VERBOSE);
-		if (tmp) {
-			*flags &= ~tmp;
-			goto next;
-		}
-		tmp = ll_set_opt("always_ping", s1, LL_SBI_ALWAYS_PING);
-		if (tmp) {
-			*flags |= tmp;
-			goto next;
-		}
-		tmp = ll_set_opt("test_dummy_encryption", s1,
-				 LL_SBI_TEST_DUMMY_ENCRYPTION);
-		if (tmp) {
+			/* fall through */
+		case LL_SBI_USER_XATTR:
+		case LL_SBI_USER_FID2PATH:
+		case LL_SBI_LRU_RESIZE:
+		case LL_SBI_LAZYSTATFS:
+		case LL_SBI_VERBOSE:
+			if (turn_off)
+				clear_bit(token, sbi->ll_flags);
+			else
+				set_bit(token, sbi->ll_flags);
+			break;
+		case LL_SBI_TEST_DUMMY_ENCRYPTION: {
 #ifdef CONFIG_FS_ENCRYPTION
-			*flags |= tmp;
+			set_bit(token, sbi->ll_flags);
 #else
 			LCONSOLE_WARN("Test dummy encryption mount option ignored: encryption not supported\n");
 #endif
-			goto next;
+			break;
 		}
-		tmp = ll_set_opt("noencrypt", s1, LL_SBI_ENCRYPT);
-		if (tmp) {
+		case LL_SBI_ENCRYPT:
 #ifdef CONFIG_FS_ENCRYPTION
-			*flags &= ~tmp;
+			if (turn_off)
+				clear_bit(token, sbi->ll_flags);
+			else
+				set_bit(token, sbi->ll_flags);
 #else
-			LCONSOLE_WARN("noencrypt mount option ignored: encryption not supported\n");
+			LCONSOLE_WARN("noencrypt or encrypt mount option ignored: encryption not supported\n");
 #endif
-			goto next;
-		}
-		tmp = ll_set_opt("foreign_symlink", s1, LL_SBI_FOREIGN_SYMLINK);
-		if (tmp) {
-			int prefix_pos = sizeof("foreign_symlink=") - 1;
-			int equal_pos = sizeof("foreign_symlink=") - 2;
-
+			break;
+		case LL_SBI_FOREIGN_SYMLINK:
 			/* non-default prefix provided ? */
-			if (strlen(s1) >= sizeof("foreign_symlink=") &&
-			    *(s1 + equal_pos) == '=') {
-				char *old = sbi->ll_foreign_symlink_prefix;
-				size_t old_len =
-					sbi->ll_foreign_symlink_prefix_size;
+			if (args->from) {
+				size_t old_len;
+				char *old;
 
 				/* path must be absolute */
-				if (*(s1 + sizeof("foreign_symlink=") -
-				    1) != '/') {
+				if (args->from[0] != '/') {
 					LCONSOLE_ERROR_MSG(0x152,
 							   "foreign prefix '%s' must be an absolute path\n",
-							   s1 + prefix_pos);
+							   args->from);
 					return -EINVAL;
 				}
-				/* last option ? */
-				s2 = strchrnul(s1 + prefix_pos, ',');
-
-				if (sbi->ll_foreign_symlink_prefix) {
-					sbi->ll_foreign_symlink_prefix = NULL;
-					sbi->ll_foreign_symlink_prefix_size = 0;
-				}
+				old_len = sbi->ll_foreign_symlink_prefix_size;
+				old = sbi->ll_foreign_symlink_prefix;
 				/* alloc for path length and '\0' */
-				sbi->ll_foreign_symlink_prefix = kmalloc(s2 - (s1 + prefix_pos) + 1,
-									 GFP_KERNEL);
+				sbi->ll_foreign_symlink_prefix = match_strdup(args);
 				if (!sbi->ll_foreign_symlink_prefix) {
 					/* restore previous */
 					sbi->ll_foreign_symlink_prefix = old;
@@ -1048,31 +1058,22 @@ static int ll_options(char *options, struct ll_sb_info *sbi)
 						old_len;
 					return -ENOMEM;
 				}
-				kfree(old);
-				strncpy(sbi->ll_foreign_symlink_prefix,
-					s1 + prefix_pos,
-					s2 - (s1 + prefix_pos));
 				sbi->ll_foreign_symlink_prefix_size =
-					s2 - (s1 + prefix_pos) + 1;
+					args->to - args->from + 1;
+				kfree(old);
+
+				/* enable foreign symlink support */
+				set_bit(token, sbi->ll_flags);
 			} else {
 				LCONSOLE_ERROR_MSG(0x152,
 						   "invalid %s option\n", s1);
 			}
-			/* enable foreign symlink support */
-			*flags |= tmp;
-			goto next;
-		}
-		LCONSOLE_ERROR_MSG(0x152, "Unknown option '%s', won't mount.\n",
-				   s1);
-		return -EINVAL;
-
-next:
-		/* Find next opt */
-		s2 = strchr(s1, ',');
-		if (!s2)
+		/* fall through */
+		default:
 			break;
-		s1 = s2 + 1;
+		}
 	}
+	kfree(opts);
 	return 0;
 }
 
@@ -1168,7 +1169,7 @@ int ll_fill_super(struct super_block *sb)
 		goto out_free;
 	}
 
-	err = ll_options(lsi->lsi_lmd->lmd_opts, sbi);
+	err = ll_options(lsi->lsi_lmd->lmd_opts, sb);
 	if (err)
 		goto out_free;
 
@@ -1271,7 +1272,7 @@ int ll_fill_super(struct super_block *sb)
 	kfree(cfg);
 	if (err)
 		ll_put_super(sb);
-	else if (sbi->ll_flags & LL_SBI_VERBOSE)
+	else if (test_bit(LL_SBI_VERBOSE, sbi->ll_flags))
 		LCONSOLE_WARN("Mounted %s\n", profilenm);
 
 	return err;
@@ -1339,7 +1340,7 @@ void ll_put_super(struct super_block *sb)
 	while ((obd = class_devices_in_group(&sbi->ll_sb_uuid, &next)))
 		class_manual_cleanup(obd);
 
-	if (sbi->ll_flags & LL_SBI_VERBOSE)
+	if (test_bit(LL_SBI_VERBOSE, sbi->ll_flags))
 		LCONSOLE_WARN("Unmounted %s\n", profilenm ? profilenm : "");
 
 	if (profilenm)
@@ -1408,7 +1409,7 @@ static struct inode *ll_iget_anon_dir(struct super_block *sb,
 	ino_t ino;
 
 	LASSERT(md->lmv);
-	ino = cl_fid_build_ino(fid, sbi->ll_flags & LL_SBI_32BIT_API);
+	ino = cl_fid_build_ino(fid, test_bit(LL_SBI_32BIT_API, sbi->ll_flags));
 	inode = iget_locked(sb, ino);
 	if (!inode) {
 		CERROR("%s: failed get simple inode " DFID ": rc = -ENOENT\n",
@@ -2207,7 +2208,7 @@ int ll_statfs_internal(struct ll_sb_info *sbi, struct obd_statfs *osfs,
 
 	max_age = ktime_get_seconds() - sbi->ll_statfs_max_age;
 
-	if (sbi->ll_flags & LL_SBI_LAZYSTATFS)
+	if (test_bit(LL_SBI_LAZYSTATFS, sbi->ll_flags))
 		flags |= OBD_STATFS_NODELAY;
 
 	rc = obd_statfs(NULL, sbi->ll_md_exp, osfs, max_age, flags);
@@ -2383,6 +2384,7 @@ int ll_update_inode(struct inode *inode, struct lustre_md *md)
 	struct ll_inode_info *lli = ll_i2info(inode);
 	struct mdt_body *body = md->body;
 	struct ll_sb_info *sbi = ll_i2sbi(inode);
+	bool api32;
 	int rc = 0;
 
 	if (body->mbo_valid & OBD_MD_FLEASIZE) {
@@ -2400,8 +2402,8 @@ int ll_update_inode(struct inode *inode, struct lustre_md *md)
 	if (body->mbo_valid & OBD_MD_FLACL)
 		lli_replace_acl(lli, md);
 
-	inode->i_ino = cl_fid_build_ino(&body->mbo_fid1,
-					sbi->ll_flags & LL_SBI_32BIT_API);
+	api32 = test_bit(LL_SBI_32BIT_API, sbi->ll_flags);
+	inode->i_ino = cl_fid_build_ino(&body->mbo_fid1, api32);
 	inode->i_generation = cl_fid_build_gen(&body->mbo_fid1);
 
 	if (body->mbo_valid & OBD_MD_FLATIME) {
@@ -2782,7 +2784,7 @@ int ll_remount_fs(struct super_block *sb, int *flags, char *data)
 		else
 			sb->s_flags &= ~SB_RDONLY;
 
-		if (sbi->ll_flags & LL_SBI_VERBOSE)
+		if (test_bit(LL_SBI_VERBOSE, sbi->ll_flags))
 			LCONSOLE_WARN("Remounted %s %s\n", profilenm,
 				      read_only ?  "read-only" : "read-write");
 	}
@@ -2853,24 +2855,23 @@ int ll_prep_inode(struct inode **inode, struct req_capsule *pill,
 		if (rc)
 			goto out;
 	} else {
+		bool api32 = test_bit(LL_SBI_32BIT_API, sbi->ll_flags);
+		struct lu_fid *fid1 = &md.body->mbo_fid1;
+
 		LASSERT(sb);
 
 		/*
 		 * At this point server returns to client's same fid as client
 		 * generated for creating. So using ->fid1 is okay here.
 		 */
-		if (!fid_is_sane(&md.body->mbo_fid1)) {
+		if (!fid_is_sane(fid1)) {
 			CERROR("%s: Fid is insane " DFID "\n",
-			       sbi->ll_fsname,
-			       PFID(&md.body->mbo_fid1));
+			       sbi->ll_fsname, PFID(fid1));
 			rc = -EINVAL;
 			goto out;
 		}
 
-		*inode = ll_iget(sb,
-				 cl_fid_build_ino(&md.body->mbo_fid1,
-						  sbi->ll_flags & LL_SBI_32BIT_API),
-				 &md);
+		*inode = ll_iget(sb, cl_fid_build_ino(fid1, api32), &md);
 		if (IS_ERR(*inode)) {
 			lmd_clear_acl(&md);
 			rc = IS_ERR(*inode) ? PTR_ERR(*inode) : -ENOMEM;
@@ -3055,7 +3056,7 @@ struct md_op_data *ll_prep_md_op_data(struct md_op_data *op_data,
 		fid_zero(&op_data->op_fid2);
 	}
 
-	if (ll_i2sbi(i1)->ll_flags & LL_SBI_64BIT_HASH)
+	if (test_bit(LL_SBI_64BIT_HASH, ll_i2sbi(i1)->ll_flags))
 		op_data->op_cli_flags |= CLI_HASH64;
 
 	if (ll_need_32bit_api(ll_i2sbi(i1)))
@@ -3132,47 +3133,40 @@ void ll_finish_md_op_data(struct md_op_data *op_data)
 int ll_show_options(struct seq_file *seq, struct dentry *dentry)
 {
 	struct ll_sb_info *sbi;
+	int i;
 
 	LASSERT(seq && dentry);
 	sbi = ll_s2sbi(dentry->d_sb);
 
-	if (sbi->ll_flags & LL_SBI_NOLCK)
-		seq_puts(seq, ",nolock");
-
-	/* "flock" is the default since 2.13, but it wasn't for many years,
-	 * so it is still useful to print this to show it is enabled.
-	 * Start to print "noflock" so it is now clear when flock is disabled.
-	 */
-	if (sbi->ll_flags & LL_SBI_FLOCK)
-		seq_puts(seq, ",flock");
-	else if (sbi->ll_flags & LL_SBI_LOCALFLOCK)
-		seq_puts(seq, ",localflock");
-	else
-		seq_puts(seq, ",noflock");
-
-	if (sbi->ll_flags & LL_SBI_USER_XATTR)
-		seq_puts(seq, ",user_xattr");
-
-	if (sbi->ll_flags & LL_SBI_LAZYSTATFS)
-		seq_puts(seq, ",lazystatfs");
-
-	if (sbi->ll_flags & LL_SBI_USER_FID2PATH)
-		seq_puts(seq, ",user_fid2path");
-
-	if (sbi->ll_flags & LL_SBI_ALWAYS_PING)
-		seq_puts(seq, ",always_ping");
+	if (test_bit(LL_SBI_NOLCK, sbi->ll_flags))
+		seq_puts(seq, "nolock");
 
-	if (ll_sbi_has_test_dummy_encryption(sbi))
-		seq_puts(seq, ",test_dummy_encryption");
-
-	if (ll_sbi_has_encrypt(sbi))
-		seq_puts(seq, ",encrypt");
-	else
-		seq_puts(seq, ",noencrypt");
+	for (i = 1; ll_sbi_flags_name[i].token != LL_SBI_NUM_MOUNT_OPT; i++) {
+		/* match_table in some cases has patterns for both enabled and
+		 * disabled cases. Ignore 'no'xxx versions if bit is set.
+		 */
+		if (test_bit(ll_sbi_flags_name[i].token, sbi->ll_flags) &&
+		    strncmp(ll_sbi_flags_name[i].pattern, "no", 2)) {
+			if (ll_sbi_flags_name[i].token ==
+			    LL_SBI_FOREIGN_SYMLINK) {
+				seq_show_option(seq, "foreign_symlink",
+						sbi->ll_foreign_symlink_prefix);
+			} else {
+				seq_printf(seq, ",%s",
+					   ll_sbi_flags_name[i].pattern);
+			}
 
-	if (sbi->ll_flags & LL_SBI_FOREIGN_SYMLINK) {
-		seq_puts(seq, ",foreign_symlink=");
-		seq_puts(seq, sbi->ll_foreign_symlink_prefix);
+			/* You can have either localflock or flock but not
+			 * both. If localflock is set don't print flock or
+			 * noflock.
+			 */
+			if (ll_sbi_flags_name[i].token == LL_SBI_LOCALFLOCK)
+				i += 2;
+		} else if (!test_bit(ll_sbi_flags_name[i].token, sbi->ll_flags) &&
+			   !strncmp(ll_sbi_flags_name[i].pattern, "no", 2)) {
+			seq_printf(seq, ",%s",
+				   ll_sbi_flags_name[i].pattern);
+		}
 	}
 
 	return 0;
@@ -3276,12 +3270,9 @@ void ll_compute_rootsquash_state(struct ll_sb_info *sbi)
 	/* Update norootsquash flag */
 	spin_lock(&squash->rsi_lock);
 	if (list_empty(&squash->rsi_nosquash_nids)) {
-		spin_lock(&sbi->ll_lock);
-		sbi->ll_flags &= ~LL_SBI_NOROOTSQUASH;
-		spin_unlock(&sbi->ll_lock);
+		clear_bit(LL_SBI_NOROOTSQUASH, sbi->ll_flags);
 	} else {
-		/*
-		 * Do not apply root squash as soon as one of our NIDs is
+		/* Do not apply root squash as soon as one of our NIDs is
 		 * in the nosquash_nids list
 		 */
 		matched = false;
@@ -3297,10 +3288,9 @@ void ll_compute_rootsquash_state(struct ll_sb_info *sbi)
 		}
 		spin_lock(&sbi->ll_lock);
 		if (matched)
-			sbi->ll_flags |= LL_SBI_NOROOTSQUASH;
+			set_bit(LL_SBI_NOROOTSQUASH, sbi->ll_flags);
 		else
-			sbi->ll_flags &= ~LL_SBI_NOROOTSQUASH;
-		spin_unlock(&sbi->ll_lock);
+			clear_bit(LL_SBI_NOROOTSQUASH, sbi->ll_flags);
 	}
 	spin_unlock(&squash->rsi_lock);
 }
@@ -3375,7 +3365,7 @@ int ll_getparent(struct file *file, struct getparent __user *arg)
 	int rc;
 
 	if (!capable(CAP_DAC_READ_SEARCH) &&
-	    !(ll_i2sbi(inode)->ll_flags & LL_SBI_USER_FID2PATH))
+	    !test_bit(LL_SBI_USER_FID2PATH, ll_i2sbi(inode)->ll_flags))
 		return -EPERM;
 
 	if (get_user(name_size, &arg->gp_name_size))
diff --git a/fs/lustre/llite/lproc_llite.c b/fs/lustre/llite/lproc_llite.c
index 3b4f60c..eac905d 100644
--- a/fs/lustre/llite/lproc_llite.c
+++ b/fs/lustre/llite/lproc_llite.c
@@ -610,7 +610,8 @@ static ssize_t checksums_show(struct kobject *kobj, struct attribute *attr,
 	struct ll_sb_info *sbi = container_of(kobj, struct ll_sb_info,
 					      ll_kset.kobj);
 
-	return sprintf(buf, "%u\n", (sbi->ll_flags & LL_SBI_CHECKSUM) ? 1 : 0);
+	return scnprintf(buf, PAGE_SIZE, "%u\n",
+			 test_bit(LL_SBI_CHECKSUM, sbi->ll_flags));
 }
 
 static ssize_t checksums_store(struct kobject *kobj, struct attribute *attr,
@@ -630,12 +631,10 @@ static ssize_t checksums_store(struct kobject *kobj, struct attribute *attr,
 	if (rc)
 		return rc;
 
-	spin_lock(&sbi->ll_lock);
 	if (val)
-		sbi->ll_flags |= LL_SBI_CHECKSUM;
+		set_bit(LL_SBI_CHECKSUM, sbi->ll_flags);
 	else
-		sbi->ll_flags &= ~LL_SBI_CHECKSUM;
-	spin_unlock(&sbi->ll_lock);
+		clear_bit(LL_SBI_CHECKSUM, sbi->ll_flags);
 	tmp = val;
 
 	rc = obd_set_info_async(NULL, sbi->ll_dt_exp, sizeof(KEY_CHECKSUM),
@@ -809,7 +808,8 @@ static ssize_t statahead_agl_show(struct kobject *kobj,
 	struct ll_sb_info *sbi = container_of(kobj, struct ll_sb_info,
 					      ll_kset.kobj);
 
-	return sprintf(buf, "%u\n", sbi->ll_flags & LL_SBI_AGL_ENABLED ? 1 : 0);
+	return scnprintf(buf, PAGE_SIZE, "%u\n",
+			 test_bit(LL_SBI_AGL_ENABLED, sbi->ll_flags));
 }
 
 static ssize_t statahead_agl_store(struct kobject *kobj,
@@ -826,12 +826,10 @@ static ssize_t statahead_agl_store(struct kobject *kobj,
 	if (rc)
 		return rc;
 
-	spin_lock(&sbi->ll_lock);
 	if (val)
-		sbi->ll_flags |= LL_SBI_AGL_ENABLED;
+		set_bit(LL_SBI_AGL_ENABLED, sbi->ll_flags);
 	else
-		sbi->ll_flags &= ~LL_SBI_AGL_ENABLED;
-	spin_unlock(&sbi->ll_lock);
+		clear_bit(LL_SBI_AGL_ENABLED, sbi->ll_flags);
 
 	return count;
 }
@@ -861,7 +859,8 @@ static ssize_t lazystatfs_show(struct kobject *kobj,
 	struct ll_sb_info *sbi = container_of(kobj, struct ll_sb_info,
 					      ll_kset.kobj);
 
-	return sprintf(buf, "%u\n", sbi->ll_flags & LL_SBI_LAZYSTATFS ? 1 : 0);
+	return scnprintf(buf, PAGE_SIZE, "%u\n",
+			 test_bit(LL_SBI_LAZYSTATFS, sbi->ll_flags));
 }
 
 static ssize_t lazystatfs_store(struct kobject *kobj,
@@ -878,12 +877,10 @@ static ssize_t lazystatfs_store(struct kobject *kobj,
 	if (rc)
 		return rc;
 
-	spin_lock(&sbi->ll_lock);
 	if (val)
-		sbi->ll_flags |= LL_SBI_LAZYSTATFS;
+		set_bit(LL_SBI_LAZYSTATFS, sbi->ll_flags);
 	else
-		sbi->ll_flags &= ~LL_SBI_LAZYSTATFS;
-	spin_unlock(&sbi->ll_lock);
+		clear_bit(LL_SBI_LAZYSTATFS, sbi->ll_flags);
 
 	return count;
 }
@@ -1006,29 +1003,6 @@ static ssize_t default_easize_store(struct kobject *kobj,
 }
 LUSTRE_RW_ATTR(default_easize);
 
-static int ll_sbi_flags_seq_show(struct seq_file *m, void *v)
-{
-	const char *const str[] = LL_SBI_FLAGS;
-	struct super_block *sb = m->private;
-	int flags = ll_s2sbi(sb)->ll_flags;
-	int i = 0;
-
-	while (flags != 0) {
-		if (ARRAY_SIZE(str) <= i) {
-			CERROR("%s: Revise array LL_SBI_FLAGS to match sbi flags please.\n",
-			       ll_s2sbi(sb)->ll_fsname);
-			return -EINVAL;
-		}
-
-		if (flags & 0x1)
-			seq_printf(m, "%s ", str[i]);
-		flags >>= 1;
-		++i;
-	}
-	seq_puts(m, "\b\n");
-	return 0;
-}
-
 LDEBUGFS_SEQ_FOPS_RO(ll_sbi_flags);
 
 static ssize_t xattr_cache_show(struct kobject *kobj,
@@ -1055,7 +1029,7 @@ static ssize_t xattr_cache_store(struct kobject *kobj,
 	if (rc)
 		return rc;
 
-	if (val && !(sbi->ll_flags & LL_SBI_XATTR_CACHE))
+	if (val && !test_bit(LL_SBI_XATTR_CACHE, sbi->ll_flags))
 		return -ENOTSUPP;
 
 	sbi->ll_xattr_cache_enabled = val;
@@ -1072,7 +1046,8 @@ static ssize_t tiny_write_show(struct kobject *kobj,
 	struct ll_sb_info *sbi = container_of(kobj, struct ll_sb_info,
 					      ll_kset.kobj);
 
-	return sprintf(buf, "%u\n", !!(sbi->ll_flags & LL_SBI_TINY_WRITE));
+	return scnprintf(buf, PAGE_SIZE, "%u\n",
+			 test_bit(LL_SBI_TINY_WRITE, sbi->ll_flags));
 }
 
 static ssize_t tiny_write_store(struct kobject *kobj,
@@ -1091,9 +1066,9 @@ static ssize_t tiny_write_store(struct kobject *kobj,
 
 	spin_lock(&sbi->ll_lock);
 	if (val)
-		sbi->ll_flags |= LL_SBI_TINY_WRITE;
+		set_bit(LL_SBI_TINY_WRITE, sbi->ll_flags);
 	else
-		sbi->ll_flags &= ~LL_SBI_TINY_WRITE;
+		clear_bit(LL_SBI_TINY_WRITE, sbi->ll_flags);
 	spin_unlock(&sbi->ll_lock);
 
 	return count;
@@ -1108,7 +1083,7 @@ static ssize_t parallel_dio_show(struct kobject *kobj,
 					      ll_kset.kobj);
 
 	return snprintf(buf, PAGE_SIZE, "%u\n",
-		       !!(sbi->ll_flags & LL_SBI_PARALLEL_DIO));
+			test_bit(LL_SBI_PARALLEL_DIO, sbi->ll_flags));
 }
 
 static ssize_t parallel_dio_store(struct kobject *kobj,
@@ -1127,9 +1102,9 @@ static ssize_t parallel_dio_store(struct kobject *kobj,
 
 	spin_lock(&sbi->ll_lock);
 	if (val)
-		sbi->ll_flags |= LL_SBI_PARALLEL_DIO;
+		set_bit(LL_SBI_PARALLEL_DIO, sbi->ll_flags);
 	else
-		sbi->ll_flags &= ~LL_SBI_PARALLEL_DIO;
+		clear_bit(LL_SBI_PARALLEL_DIO, sbi->ll_flags);
 	spin_unlock(&sbi->ll_lock);
 
 	return count;
@@ -1274,7 +1249,8 @@ static ssize_t fast_read_show(struct kobject *kobj,
 	struct ll_sb_info *sbi = container_of(kobj, struct ll_sb_info,
 					      ll_kset.kobj);
 
-	return sprintf(buf, "%u\n", !!(sbi->ll_flags & LL_SBI_FAST_READ));
+	return scnprintf(buf, PAGE_SIZE, "%u\n",
+			 test_bit(LL_SBI_FAST_READ, sbi->ll_flags));
 }
 
 static ssize_t fast_read_store(struct kobject *kobj,
@@ -1293,9 +1269,9 @@ static ssize_t fast_read_store(struct kobject *kobj,
 
 	spin_lock(&sbi->ll_lock);
 	if (val)
-		sbi->ll_flags |= LL_SBI_FAST_READ;
+		set_bit(LL_SBI_FAST_READ, sbi->ll_flags);
 	else
-		sbi->ll_flags &= ~LL_SBI_FAST_READ;
+		clear_bit(LL_SBI_FAST_READ, sbi->ll_flags);
 	spin_unlock(&sbi->ll_lock);
 
 	return count;
@@ -1310,7 +1286,7 @@ static ssize_t file_heat_show(struct kobject *kobj,
 					      ll_kset.kobj);
 
 	return scnprintf(buf, PAGE_SIZE, "%u\n",
-			 !!(sbi->ll_flags & LL_SBI_FILE_HEAT));
+			 test_bit(LL_SBI_FILE_HEAT, sbi->ll_flags));
 }
 
 static ssize_t file_heat_store(struct kobject *kobj,
@@ -1329,9 +1305,9 @@ static ssize_t file_heat_store(struct kobject *kobj,
 
 	spin_lock(&sbi->ll_lock);
 	if (val)
-		sbi->ll_flags |= LL_SBI_FILE_HEAT;
+		set_bit(LL_SBI_FILE_HEAT, sbi->ll_flags);
 	else
-		sbi->ll_flags &= ~LL_SBI_FILE_HEAT;
+		clear_bit(LL_SBI_FILE_HEAT, sbi->ll_flags);
 	spin_unlock(&sbi->ll_lock);
 
 	return count;
diff --git a/fs/lustre/llite/namei.c b/fs/lustre/llite/namei.c
index 781bb16..f942179 100644
--- a/fs/lustre/llite/namei.c
+++ b/fs/lustre/llite/namei.c
@@ -880,7 +880,7 @@ static struct dentry *ll_lookup_it(struct inode *parent, struct dentry *dentry,
 		it->it_create_mode &= ~current_umask();
 
 	if (it->it_op & IT_CREAT &&
-	    ll_i2sbi(parent)->ll_flags & LL_SBI_FILE_SECCTX) {
+	    test_bit(LL_SBI_FILE_SECCTX, ll_i2sbi(parent)->ll_flags)) {
 		rc = ll_dentry_init_security(dentry, it->it_create_mode,
 					     &dentry->d_name,
 					     &op_data->op_file_secctx_name,
@@ -1424,7 +1424,8 @@ static int ll_create_it(struct inode *dir, struct dentry *dentry,
 	if (IS_ERR(inode))
 		return PTR_ERR(inode);
 
-	if ((ll_i2sbi(inode)->ll_flags & LL_SBI_FILE_SECCTX) && secctx) {
+	if (test_bit(LL_SBI_FILE_SECCTX, ll_i2sbi(inode)->ll_flags) &&
+	    secctx) {
 		/* must be done before d_instantiate, because it calls
 		 * security_d_instantiate, which means a getxattr if security
 		 * context is not set yet
@@ -1446,7 +1447,7 @@ static int ll_create_it(struct inode *dir, struct dentry *dentry,
 			return rc;
 	}
 
-	if (!(ll_i2sbi(inode)->ll_flags & LL_SBI_FILE_SECCTX)) {
+	if (!test_bit(LL_SBI_FILE_SECCTX, ll_i2sbi(inode)->ll_flags)) {
 		rc = ll_inode_init_security(dentry, inode, dir);
 		if (rc)
 			return rc;
@@ -1562,7 +1563,7 @@ static int ll_new_node(struct inode *dir, struct dentry *dchild,
 	if (S_ISDIR(mode))
 		ll_qos_mkdir_prep(op_data, dir);
 
-	if (sbi->ll_flags & LL_SBI_FILE_SECCTX) {
+	if (test_bit(LL_SBI_FILE_SECCTX, sbi->ll_flags)) {
 		err = ll_dentry_init_security(dchild, mode, &dchild->d_name,
 					      &op_data->op_file_secctx_name,
 					      &op_data->op_file_secctx,
@@ -1707,7 +1708,7 @@ static int ll_new_node(struct inode *dir, struct dentry *dchild,
 	if (err)
 		goto err_exit;
 
-	if (sbi->ll_flags & LL_SBI_FILE_SECCTX) {
+	if (test_bit(LL_SBI_FILE_SECCTX, sbi->ll_flags)) {
 		/* must be done before d_instantiate, because it calls
 		 * security_d_instantiate, which means a getxattr if security
 		 * context is not set yet
@@ -1747,7 +1748,7 @@ static int ll_new_node(struct inode *dir, struct dentry *dchild,
 		}
 	}
 
-	if (!(sbi->ll_flags & LL_SBI_FILE_SECCTX))
+	if (!test_bit(LL_SBI_FILE_SECCTX, sbi->ll_flags))
 		err = ll_inode_init_security(dchild, inode, dir);
 err_exit:
 	if (request)
diff --git a/fs/lustre/llite/statahead.c b/fs/lustre/llite/statahead.c
index 15b95b7..4806e99 100644
--- a/fs/lustre/llite/statahead.c
+++ b/fs/lustre/llite/statahead.c
@@ -1667,7 +1667,8 @@ static int start_statahead_thread(struct inode *dir, struct dentry *dentry,
 		goto out;
 	}
 
-	if (ll_i2sbi(parent->d_inode)->ll_flags & LL_SBI_AGL_ENABLED && agl)
+	if (test_bit(LL_SBI_AGL_ENABLED, ll_i2sbi(parent->d_inode)->ll_flags) &&
+	    agl)
 		ll_start_agl(parent, sai);
 
 	atomic_inc(&ll_i2sbi(parent->d_inode)->ll_sa_total);
diff --git a/fs/lustre/llite/xattr.c b/fs/lustre/llite/xattr.c
index 59a1400..b67b822 100644
--- a/fs/lustre/llite/xattr.c
+++ b/fs/lustre/llite/xattr.c
@@ -67,11 +67,11 @@ static int xattr_type_filter(struct ll_sb_info *sbi,
 
 	if ((handler->flags == XATTR_ACL_ACCESS_T ||
 	     handler->flags == XATTR_ACL_DEFAULT_T) &&
-	   !(sbi->ll_flags & LL_SBI_ACL))
+	   !test_bit(LL_SBI_ACL, sbi->ll_flags))
 		return -EOPNOTSUPP;
 
 	if (handler->flags == XATTR_USER_T &&
-	    !(sbi->ll_flags & LL_SBI_USER_XATTR))
+	    !test_bit(LL_SBI_USER_XATTR, sbi->ll_flags))
 		return -EOPNOTSUPP;
 
 	if (handler->flags == XATTR_TRUSTED_T &&
@@ -153,9 +153,7 @@ static int ll_xattr_set_common(const struct xattr_handler *handler,
 	if (rc) {
 		if (rc == -EOPNOTSUPP && handler->flags == XATTR_USER_T) {
 			LCONSOLE_INFO("Disabling user_xattr feature because it is not supported on the server\n");
-			spin_lock(&sbi->ll_lock);
-			sbi->ll_flags &= ~LL_SBI_USER_XATTR;
-			spin_unlock(&sbi->ll_lock);
+			clear_bit(LL_SBI_USER_XATTR, sbi->ll_flags);
 		}
 		return rc;
 	}
@@ -431,12 +429,9 @@ int ll_xattr_list(struct inode *inode, const char *name, int type, void *buffer,
 
 out_xattr:
 	if (rc == -EOPNOTSUPP && type == XATTR_USER_T) {
-		LCONSOLE_INFO(
-			"%s: disabling user_xattr feature because it is not supported on the server: rc = %d\n",
-			sbi->ll_fsname, rc);
-		spin_lock(&sbi->ll_lock);
-		sbi->ll_flags &= ~LL_SBI_USER_XATTR;
-		spin_unlock(&sbi->ll_lock);
+		LCONSOLE_INFO("%s: disabling user_xattr feature because it is not supported on the server: rc = %d\n",
+			      sbi->ll_fsname, rc);
+		clear_bit(LL_SBI_USER_XATTR, sbi->ll_flags);
 	}
 out:
 	ptlrpc_req_finished(req);
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
