From: James Simmons <jsimmons@infradead.org>
Date: Mon, 25 May 2020 18:08:02 -0400
Subject: [lustre-devel] [PATCH 25/45] lustre: Send file creation time to
 clients
In-Reply-To: <1590444502-20533-1-git-send-email-jsimmons@infradead.org>
References: <1590444502-20533-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1590444502-20533-26-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Qian Yingjin <qian@ddn.com>

Both ext4 and ZFS allow storing the file creation time in the
on-disk inode, and the new statx() API allows returning it to
userspace, but as yet we do not have any mechanism to send it
from the servers to the client.

Add fields into struct mdt_body and an OBD_MD_FLBTIME flag to
allow it to be requested and returned directly from MDTs. It
does not need to get it from the OSTs or in the LVB since those
objects are precreated and their creation time (birth time) is
not accurate.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11971
Lustre-commit: 186b97e68abbc ("LU-11971 utils: Send file creation time to clients")
Signed-off-by: Qian Yingjin <qian@ddn.com>
Reviewed-on: https://review.whamcloud.com/36507
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Li Xi <lixi@ddn.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lu_object.h           | 2 ++
 fs/lustre/llite/dir.c                   | 3 ++-
 fs/lustre/ptlrpc/pack_generic.c         | 2 +-
 fs/lustre/ptlrpc/wiretest.c             | 8 ++++----
 include/uapi/linux/lustre/lustre_idl.h  | 6 ++++--
 include/uapi/linux/lustre/lustre_user.h | 1 +
 6 files changed, 14 insertions(+), 8 deletions(-)

diff --git a/fs/lustre/include/lu_object.h b/fs/lustre/include/lu_object.h
index d0a59ff..718fdb8 100644
--- a/fs/lustre/include/lu_object.h
+++ b/fs/lustre/include/lu_object.h
@@ -399,6 +399,8 @@ struct lu_attr {
 	s64	  la_atime;
 	/** change time in seconds since Epoch */
 	s64	  la_ctime;
+	/** create time in seconds since Epoch */
+	s64	la_btime;
 	/** 512-byte blocks allocated to object */
 	u64	  la_blocks;
 	/** permission bits and file type */
diff --git a/fs/lustre/llite/dir.c b/fs/lustre/llite/dir.c
index 41e399b..7fd52fe 100644
--- a/fs/lustre/llite/dir.c
+++ b/fs/lustre/llite/dir.c
@@ -1758,11 +1758,12 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 			stx.stx_atime.tv_sec = body->mbo_atime;
 			stx.stx_ctime.tv_sec = body->mbo_ctime;
 			stx.stx_mtime.tv_sec = body->mbo_mtime;
+			stx.stx_btime.tv_sec = body->mbo_btime;
 			stx.stx_rdev_major = MAJOR(body->mbo_rdev);
 			stx.stx_rdev_minor = MINOR(body->mbo_rdev);
 			stx.stx_dev_major = MAJOR(inode->i_sb->s_dev);
 			stx.stx_dev_minor = MINOR(inode->i_sb->s_dev);
-			stx.stx_mask |= STATX_BASIC_STATS;
+			stx.stx_mask |= STATX_BASIC_STATS | STATX_BTIME;
 
 			/*
 			 * For a striped directory, the size and blocks returned
diff --git a/fs/lustre/ptlrpc/pack_generic.c b/fs/lustre/ptlrpc/pack_generic.c
index 82e6c46..55d9814 100644
--- a/fs/lustre/ptlrpc/pack_generic.c
+++ b/fs/lustre/ptlrpc/pack_generic.c
@@ -1805,7 +1805,7 @@ void lustre_swab_mdt_body(struct mdt_body *b)
 	__swab32s(&b->mbo_projid);
 	__swab64s(&b->mbo_dom_size);
 	__swab64s(&b->mbo_dom_blocks);
-	BUILD_BUG_ON(offsetof(typeof(*b), mbo_padding_8) == 0);
+	__swab64s(&b->mbo_btime);
 	BUILD_BUG_ON(offsetof(typeof(*b), mbo_padding_9) == 0);
 	BUILD_BUG_ON(offsetof(typeof(*b), mbo_padding_10) == 0);
 }
diff --git a/fs/lustre/ptlrpc/wiretest.c b/fs/lustre/ptlrpc/wiretest.c
index 81d0a99..8f824ee 100644
--- a/fs/lustre/ptlrpc/wiretest.c
+++ b/fs/lustre/ptlrpc/wiretest.c
@@ -2218,10 +2218,10 @@ void lustre_assert_wire_constants(void)
 		 (long long)(int)offsetof(struct mdt_body, mbo_dom_blocks));
 	LASSERTF((int)sizeof(((struct mdt_body *)0)->mbo_dom_blocks) == 8, "found %lld\n",
 		 (long long)(int)sizeof(((struct mdt_body *)0)->mbo_dom_blocks));
-	LASSERTF((int)offsetof(struct mdt_body, mbo_padding_8) == 192, "found %lld\n",
-		 (long long)(int)offsetof(struct mdt_body, mbo_padding_8));
-	LASSERTF((int)sizeof(((struct mdt_body *)0)->mbo_padding_8) == 8, "found %lld\n",
-		 (long long)(int)sizeof(((struct mdt_body *)0)->mbo_padding_8));
+	LASSERTF((int)offsetof(struct mdt_body, mbo_btime) == 192, "found %lld\n",
+		 (long long)(int)offsetof(struct mdt_body, mbo_btime));
+	LASSERTF((int)sizeof(((struct mdt_body *)0)->mbo_btime) == 8, "found %lld\n",
+		 (long long)(int)sizeof(((struct mdt_body *)0)->mbo_btime));
 	LASSERTF((int)offsetof(struct mdt_body, mbo_padding_9) == 200, "found %lld\n",
 		 (long long)(int)offsetof(struct mdt_body, mbo_padding_9));
 	LASSERTF((int)sizeof(((struct mdt_body *)0)->mbo_padding_9) == 8, "found %lld\n",
diff --git a/include/uapi/linux/lustre/lustre_idl.h b/include/uapi/linux/lustre/lustre_idl.h
index 743af77..bb3f5f1 100644
--- a/include/uapi/linux/lustre/lustre_idl.h
+++ b/include/uapi/linux/lustre/lustre_idl.h
@@ -1213,6 +1213,8 @@ static inline __u32 lov_mds_md_size(__u16 stripes, __u32 lmm_magic)
 #define OBD_MD_FLLAZYSIZE    (0x0400000000000000ULL) /* Lazy size */
 #define OBD_MD_FLLAZYBLOCKS  (0x0800000000000000ULL) /* Lazy blocks */
 
+#define OBD_MD_FLBTIME		(0x1000000000000000ULL) /* birth time */
+
 #define OBD_MD_FLALLQUOTA (OBD_MD_FLUSRQUOTA | \
 			   OBD_MD_FLGRPQUOTA | \
 			   OBD_MD_FLPRJQUOTA)
@@ -1222,7 +1224,7 @@ static inline __u32 lov_mds_md_size(__u16 stripes, __u32 lmm_magic)
 			  OBD_MD_FLMODE  | OBD_MD_FLTYPE  | OBD_MD_FLUID   | \
 			  OBD_MD_FLGID   | OBD_MD_FLFLAGS | OBD_MD_FLNLINK | \
 			  OBD_MD_FLPARENT | OBD_MD_FLRDEV  | OBD_MD_FLGROUP | \
-			  OBD_MD_FLPROJID)
+			  OBD_MD_FLPROJID | OBD_MD_FLBTIME)
 
 #define OBD_MD_FLXATTRALL (OBD_MD_FLXATTR | OBD_MD_FLXATTRLS)
 
@@ -1589,7 +1591,7 @@ struct mdt_body {
 	__u32	mbo_projid;	/* also fix lustre_swab_mdt_body */
 	__u64	mbo_dom_size;	/* size of DOM component */
 	__u64	mbo_dom_blocks; /* blocks consumed by DOM component */
-	__u64	mbo_padding_8; /* also fix lustre_swab_mdt_body */
+	__u64	mbo_btime;
 	__u64	mbo_padding_9;
 	__u64	mbo_padding_10;
 }; /* 216 */
diff --git a/include/uapi/linux/lustre/lustre_user.h b/include/uapi/linux/lustre/lustre_user.h
index 6644b99..80e5c24 100644
--- a/include/uapi/linux/lustre/lustre_user.h
+++ b/include/uapi/linux/lustre/lustre_user.h
@@ -1064,6 +1064,7 @@ enum la_valid {
 	LA_LAYOUT_VERSION = 1 << 16,
 	LA_LSIZE	= 1 << 17,
 	LA_LBLOCKS	= 1 << 18,
+	LA_BTIME	= 1 << 19,	/* 0x8000 */
 	/**
 	 * Attributes must be transmitted to OST objects
 	 */
-- 
1.8.3.1
