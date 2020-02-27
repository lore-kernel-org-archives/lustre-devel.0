From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:15:59 -0500
Subject: [lustre-devel] [PATCH 491/622] lustre: som: integrate LSOM with lfs
 find
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-492-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Qian Yingjin <qian@ddn.com>

The patch integrates LSOM functionality with lfs find so that it
is possible to use LSOM functionality directly on the client. The
MDS fills in the mbo_size and mbo_blocks fields from the LSOM
xattr, if the actual size/blocks are not available, and then set
new OBD_MD_FLLSIZE and OBD_MD_FLLBLOCKS flags in the reply so that
the client knows these fields are valid.

The lfs find command adds "-l|--lazy" option to allow the use of
LSOM data from the MDS.

Add a new version of ioctl(LL_IOC_MDC_GETINFO) call that also returns
valid flags from the MDS RPC to userspace in struct lov_user_mds_data
so that it is possible to determine whether the size and blocks are
returned by the call.  The old LL_IOC_MDC_GETINFO ioctl number is
renamed to LL_IOC_MDC_GETINFO_OLD and is binary compatible, but
newly-compiled applications will use the new struct lov_user_mds_data.

New llapi interfaces llapi_get_lum_file(), llapi_get_lum_dir(),
llapi_get_lum_file_fd(), llapi_get_lum_dir_fd() are added to fetch
valid stat() attributes and LOV info to the user.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11367
Lustre-commit: 11aa7f8704c4 ("LU-11367 som: integrate LSOM with lfs find")
Signed-off-by: Qian Yingjin <qian@ddn.com>
Signed-off-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/35167
Reviewed-by: Li Xi <lixi@ddn.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/dir.c                   | 97 +++++++++++++++++++++++++++++++--
 include/uapi/linux/lustre/lustre_idl.h  |  3 +
 include/uapi/linux/lustre/lustre_user.h | 17 +++++-
 3 files changed, 108 insertions(+), 9 deletions(-)

diff --git a/fs/lustre/llite/dir.c b/fs/lustre/llite/dir.c
index 812f535..4dccd24 100644
--- a/fs/lustre/llite/dir.c
+++ b/fs/lustre/llite/dir.c
@@ -1604,16 +1604,24 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 	case LL_IOC_LOV_GETSTRIPE:
 	case LL_IOC_LOV_GETSTRIPE_NEW:
 	case LL_IOC_MDC_GETINFO:
+	case LL_IOC_MDC_GETINFO_OLD:
 	case IOC_MDC_GETFILEINFO:
+	case IOC_MDC_GETFILEINFO_OLD:
 	case IOC_MDC_GETFILESTRIPE: {
 		struct ptlrpc_request *request = NULL;
 		struct lov_user_md __user *lump;
 		struct lov_mds_md *lmm = NULL;
 		struct mdt_body *body;
 		char *filename = NULL;
+		lstat_t __user *statp = NULL;
+		struct statx __user *stxp = NULL;
+		u64 __user *flagsp = NULL;
+		u32 __user *lmmsizep = NULL;
+		struct lu_fid __user *fidp = NULL;
 		int lmmsize;
 
-		if (cmd == IOC_MDC_GETFILEINFO ||
+		if (cmd == IOC_MDC_GETFILEINFO_OLD ||
+		    cmd == IOC_MDC_GETFILEINFO ||
 		    cmd == IOC_MDC_GETFILESTRIPE) {
 			filename = ll_getname((const char __user *)arg);
 			if (IS_ERR(filename))
@@ -1635,7 +1643,9 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 		}
 
 		if (rc == -ENODATA && (cmd == IOC_MDC_GETFILEINFO ||
-				       cmd == LL_IOC_MDC_GETINFO)) {
+				       cmd == LL_IOC_MDC_GETINFO ||
+				       cmd == IOC_MDC_GETFILEINFO_OLD ||
+				       cmd == LL_IOC_MDC_GETINFO_OLD)) {
 			lmmsize = 0;
 			rc = 0;
 		}
@@ -1647,10 +1657,21 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 		    cmd == LL_IOC_LOV_GETSTRIPE ||
 		    cmd == LL_IOC_LOV_GETSTRIPE_NEW) {
 			lump = (struct lov_user_md __user *)arg;
+		} else if (cmd == IOC_MDC_GETFILEINFO_OLD ||
+			   cmd == LL_IOC_MDC_GETINFO_OLD){
+			struct lov_user_mds_data_v1 __user *lmdp;
+
+			lmdp = (struct lov_user_mds_data_v1 __user *)arg;
+			statp = &lmdp->lmd_st;
+			lump = &lmdp->lmd_lmm;
 		} else {
 			struct lov_user_mds_data __user *lmdp;
 
 			lmdp = (struct lov_user_mds_data __user *)arg;
+			fidp = &lmdp->lmd_fid;
+			stxp = &lmdp->lmd_stx;
+			flagsp = &lmdp->lmd_flags;
+			lmmsizep = &lmdp->lmd_lmmsize;
 			lump = &lmdp->lmd_lmm;
 		}
 
@@ -1670,8 +1691,8 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 			rc = -EOVERFLOW;
 		}
 
-		if (cmd == IOC_MDC_GETFILEINFO || cmd == LL_IOC_MDC_GETINFO) {
-			struct lov_user_mds_data __user *lmdp;
+		if (cmd == IOC_MDC_GETFILEINFO_OLD ||
+		    cmd == LL_IOC_MDC_GETINFO_OLD) {
 			lstat_t st = { 0 };
 
 			st.st_dev = inode->i_sb->s_dev;
@@ -1690,8 +1711,72 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 						     sbi->ll_flags &
 						     LL_SBI_32BIT_API);
 
-			lmdp = (struct lov_user_mds_data __user *)arg;
-			if (copy_to_user(&lmdp->lmd_st, &st, sizeof(st))) {
+			if (copy_to_user(statp, &st, sizeof(st))) {
+				rc = -EFAULT;
+				goto out_req;
+			}
+		} else if (cmd == IOC_MDC_GETFILEINFO ||
+			   cmd == LL_IOC_MDC_GETINFO) {
+			struct statx stx = { 0 };
+			u64 valid = body->mbo_valid;
+
+			stx.stx_blksize = PAGE_SIZE;
+			stx.stx_nlink = body->mbo_nlink;
+			stx.stx_uid = body->mbo_uid;
+			stx.stx_gid = body->mbo_gid;
+			stx.stx_mode = body->mbo_mode;
+			stx.stx_ino = cl_fid_build_ino(&body->mbo_fid1,
+						       sbi->ll_flags &
+						       LL_SBI_32BIT_API);
+			stx.stx_size = body->mbo_size;
+			stx.stx_blocks = body->mbo_blocks;
+			stx.stx_atime.tv_sec = body->mbo_atime;
+			stx.stx_ctime.tv_sec = body->mbo_ctime;
+			stx.stx_mtime.tv_sec = body->mbo_mtime;
+			stx.stx_rdev_major = MAJOR(body->mbo_rdev);
+			stx.stx_rdev_minor = MINOR(body->mbo_rdev);
+			stx.stx_dev_major = MAJOR(inode->i_sb->s_dev);
+			stx.stx_dev_minor = MINOR(inode->i_sb->s_dev);
+			stx.stx_mask |= STATX_BASIC_STATS;
+
+			/*
+			 * For a striped directory, the size and blocks returned
+			 * from MDT is not correct.
+			 * The size and blocks are aggregated by client across
+			 * all stripes.
+			 * Thus for a striped directory, do not return the valid
+			 * FLSIZE and FLBLOCKS flags to the caller.
+			 * However, this whould be better decided by the MDS
+			 * instead of the client.
+			 */
+			if (cmd == LL_IOC_MDC_GETINFO &&
+			    ll_i2info(inode)->lli_lsm_md)
+				valid &= ~(OBD_MD_FLSIZE | OBD_MD_FLBLOCKS);
+
+			if (flagsp && copy_to_user(flagsp, &valid,
+						   sizeof(*flagsp))) {
+				rc = -EFAULT;
+				goto out_req;
+			}
+
+			if (fidp && copy_to_user(fidp, &body->mbo_fid1,
+						 sizeof(*fidp))) {
+				rc = -EFAULT;
+				goto out_req;
+			}
+
+			if (!(valid & OBD_MD_FLSIZE))
+				stx.stx_mask &= ~STATX_SIZE;
+			if (!(valid & OBD_MD_FLBLOCKS))
+				stx.stx_mask &= ~STATX_BLOCKS;
+
+			if (stxp && copy_to_user(stxp, &stx, sizeof(stx))) {
+				rc = -EFAULT;
+				goto out_req;
+			}
+
+			if (lmmsizep && copy_to_user(lmmsizep, &lmmsize,
+						     sizeof(*lmmsizep))) {
 				rc = -EFAULT;
 				goto out_req;
 			}
diff --git a/include/uapi/linux/lustre/lustre_idl.h b/include/uapi/linux/lustre/lustre_idl.h
index 47321ae..d4b29d8 100644
--- a/include/uapi/linux/lustre/lustre_idl.h
+++ b/include/uapi/linux/lustre/lustre_idl.h
@@ -1211,6 +1211,9 @@ static inline __u32 lov_mds_md_size(__u16 stripes, __u32 lmm_magic)
 #define OBD_MD_FLPROJID		(0x0100000000000000ULL) /* project ID */
 #define OBD_MD_SECCTX        (0x0200000000000000ULL) /* embed security xattr */
 
+#define OBD_MD_FLLAZYSIZE    (0x0400000000000000ULL) /* Lazy size */
+#define OBD_MD_FLLAZYBLOCKS  (0x0800000000000000ULL) /* Lazy blocks */
+
 #define OBD_MD_FLALLQUOTA (OBD_MD_FLUSRQUOTA | \
 			   OBD_MD_FLGRPQUOTA | \
 			   OBD_MD_FLPRJQUOTA)
diff --git a/include/uapi/linux/lustre/lustre_user.h b/include/uapi/linux/lustre/lustre_user.h
index 695ceb2..06a691b 100644
--- a/include/uapi/linux/lustre/lustre_user.h
+++ b/include/uapi/linux/lustre/lustre_user.h
@@ -371,8 +371,10 @@ struct ll_ioc_lease_id {
 #define IOC_MDC_TYPE		'i'
 #define IOC_MDC_LOOKUP		_IOWR(IOC_MDC_TYPE, 20, struct obd_device *)
 #define IOC_MDC_GETFILESTRIPE	_IOWR(IOC_MDC_TYPE, 21, struct lov_user_md *)
-#define IOC_MDC_GETFILEINFO	_IOWR(IOC_MDC_TYPE, 22, struct lov_user_mds_data *)
-#define LL_IOC_MDC_GETINFO	_IOWR(IOC_MDC_TYPE, 23, struct lov_user_mds_data *)
+#define IOC_MDC_GETFILEINFO_OLD	_IOWR(IOC_MDC_TYPE, 22, struct lov_user_mds_data_v1 *)
+#define IOC_MDC_GETFILEINFO	_IOWR(IOC_MDC_TYPE, 22, struct lov_user_mds_data)
+#define LL_IOC_MDC_GETINFO_OLD	_IOWR(IOC_MDC_TYPE, 23, struct lov_user_mds_data_v1 *)
+#define LL_IOC_MDC_GETINFO	_IOWR(IOC_MDC_TYPE, 23, struct lov_user_mds_data)
 
 #define MAX_OBD_NAME 128 /* If this changes, a NEW ioctl must be added */
 
@@ -636,12 +638,21 @@ static inline __u32 lov_user_md_size(__u16 stripes, __u32 lmm_magic)
  * is possible the application has already #included <sys/stat.h>.
  */
 #ifdef HAVE_LOV_USER_MDS_DATA
-#define lov_user_mds_data lov_user_mds_data_v1
+#define lov_user_mds_data lov_user_mds_data_v2
 struct lov_user_mds_data_v1 {
 	lstat_t lmd_st;			/* MDS stat struct */
 	struct lov_user_md_v1 lmd_lmm;	/* LOV EA V1 user data */
 } __packed;
 
+struct lov_user_mds_data_v2 {
+	struct lu_fid lmd_fid;		/* Lustre FID */
+	struct statx lmd_stx;		/* MDS statx struct */
+	__u64 lmd_flags;		/* MDS stat flags */
+	__u32 lmd_lmmsize;		/* LOV EA size */
+	__u32 lmd_padding;		/* unused */
+	struct lov_user_md_v1 lmd_lmm;	/* LOV EA user data */
+} __attribute__((packed));
+
 struct lov_user_mds_data_v3 {
 	lstat_t lmd_st;			/* MDS stat struct */
 	struct lov_user_md_v3 lmd_lmm;	/* LOV EA V3 user data */
-- 
1.8.3.1
