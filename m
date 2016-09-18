From: James Simmons <jsimmons@infradead.org>
Date: Sun, 18 Sep 2016 16:37:09 -0400
Subject: [lustre-devel] [PATCH 010/124] staging: lustre: llite: add
	LL_LEASE_{RD, WR, UN}LCK
In-Reply-To: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
References: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1474231143-4061-11-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, "John L. Hammond" <john.hammond@intel.com>, James Simmons <jsimmons@infradead.org>

From: John L. Hammond <john.hammond@intel.com>

Define new constants LL_LEASE_{RD,WR,UN}LCK for use as the argument to
and return value from the LL_IOC_{GET,SET}_LEASE ioctls. As arguments,
these contants replace the use of F_{RD,WR,UN}LCK from fcntl.h. As
return values they replace the use of FMODE_{READ,WRITE} which are
internal to the Linux kernel source and not under the control of the
Lustre ioctl interface.

Signed-off-by: John L. Hammond <john.hammond@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5013
Reviewed-on: http://review.whamcloud.com/10233
Reviewed-by: Jinshan Xiong <jinshan.xiong@intel.com>
Reviewed-by: Lai Siyao <lai.siyao@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/lustre/include/lustre/lustre_user.h     |    7 +++
 drivers/staging/lustre/lustre/llite/file.c         |   51 +++++++++++---------
 2 files changed, 35 insertions(+), 23 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_user.h b/drivers/staging/lustre/lustre/include/lustre/lustre_user.h
index c69918b..5e907af 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_user.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_user.h
@@ -246,6 +246,13 @@ struct ost_id {
 #define LL_IOC_MIGRATE			_IOR('f', 247, int)
 #define LL_IOC_FID2MDTIDX		_IOWR('f', 248, struct lu_fid)
 
+/* Lease types for use as arg and return of LL_IOC_{GET,SET}_LEASE ioctl. */
+enum ll_lease_type {
+	LL_LEASE_RDLCK	= 0x1,
+	LL_LEASE_WRLCK	= 0x2,
+	LL_LEASE_UNLCK	= 0x4,
+};
+
 #define LL_STATFS_LMV	   1
 #define LL_STATFS_LOV	   2
 #define LL_STATFS_NODELAY	4
diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
index bfac6dd..e9791e3 100644
--- a/drivers/staging/lustre/lustre/llite/file.c
+++ b/drivers/staging/lustre/lustre/llite/file.c
@@ -2245,6 +2245,12 @@ free_hss:
 	return rc;
 }
 
+static inline long ll_lease_type_from_fmode(fmode_t fmode)
+{
+	return ((fmode & FMODE_READ) ? LL_LEASE_RDLCK : 0) |
+	       ((fmode & FMODE_WRITE) ? LL_LEASE_WRLCK : 0);
+}
+
 static long
 ll_file_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 {
@@ -2449,20 +2455,20 @@ ll_file_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 		struct ll_inode_info *lli = ll_i2info(inode);
 		struct obd_client_handle *och = NULL;
 		bool lease_broken;
-		fmode_t mode = 0;
+		fmode_t fmode;
 
 		switch (arg) {
-		case F_WRLCK:
+		case LL_LEASE_WRLCK:
 			if (!(file->f_mode & FMODE_WRITE))
 				return -EPERM;
-			mode = FMODE_WRITE;
+			fmode = FMODE_WRITE;
 			break;
-		case F_RDLCK:
+		case LL_LEASE_RDLCK:
 			if (!(file->f_mode & FMODE_READ))
 				return -EPERM;
-			mode = FMODE_READ;
+			fmode = FMODE_READ;
 			break;
-		case F_UNLCK:
+		case LL_LEASE_UNLCK:
 			mutex_lock(&lli->lli_och_mutex);
 			if (fd->fd_lease_och) {
 				och = fd->fd_lease_och;
@@ -2470,26 +2476,26 @@ ll_file_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 			}
 			mutex_unlock(&lli->lli_och_mutex);
 
-			if (och) {
-				mode = och->och_flags &
-				       (FMODE_READ | FMODE_WRITE);
-				rc = ll_lease_close(och, inode, &lease_broken);
-				if (rc == 0 && lease_broken)
-					mode = 0;
-			} else {
-				rc = -ENOLCK;
-			}
+			if (!och)
+				return -ENOLCK;
 
-			/* return the type of lease or error */
-			return rc < 0 ? rc : (int)mode;
+			fmode = och->och_flags;
+			rc = ll_lease_close(och, inode, &lease_broken);
+			if (rc < 0)
+				return rc;
+
+			if (lease_broken)
+				fmode = 0;
+
+			return ll_lease_type_from_fmode(fmode);
 		default:
 			return -EINVAL;
 		}
 
-		CDEBUG(D_INODE, "Set lease with mode %d\n", mode);
+		CDEBUG(D_INODE, "Set lease with mode %u\n", fmode);
 
 		/* apply for lease */
-		och = ll_lease_open(inode, file, mode, 0);
+		och = ll_lease_open(inode, file, fmode, 0);
 		if (IS_ERR(och))
 			return PTR_ERR(och);
 
@@ -2510,8 +2516,8 @@ ll_file_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 	case LL_IOC_GET_LEASE: {
 		struct ll_inode_info *lli = ll_i2info(inode);
 		struct ldlm_lock *lock = NULL;
+		fmode_t fmode = 0;
 
-		rc = 0;
 		mutex_lock(&lli->lli_och_mutex);
 		if (fd->fd_lease_och) {
 			struct obd_client_handle *och = fd->fd_lease_och;
@@ -2520,14 +2526,13 @@ ll_file_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 			if (lock) {
 				lock_res_and_lock(lock);
 				if (!ldlm_is_cancel(lock))
-					rc = och->och_flags &
-						(FMODE_READ | FMODE_WRITE);
+					fmode = och->och_flags;
 				unlock_res_and_lock(lock);
 				LDLM_LOCK_PUT(lock);
 			}
 		}
 		mutex_unlock(&lli->lli_och_mutex);
-		return rc;
+		return ll_lease_type_from_fmode(fmode);
 	}
 	case LL_IOC_HSM_IMPORT: {
 		struct hsm_user_import *hui;
-- 
1.7.1
