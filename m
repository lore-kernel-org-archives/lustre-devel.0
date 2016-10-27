From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Oct 2016 18:11:56 -0400
Subject: [lustre-devel] [PATCH 22/29] staging: lustre: llite: add
	LL_IOC_FUTIMES_3
In-Reply-To: <1477606323-30325-1-git-send-email-jsimmons@infradead.org>
References: <1477606323-30325-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1477606323-30325-23-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, "John L. Hammond" <john.hammond@intel.com>, James Simmons <jsimmons@infradead.org>

From: John L. Hammond <john.hammond@intel.com>

Add a new regular file ioctl LL_IOC_FUTIMES_3 similar to futimes() but
which allows setting of all three inode timestamps. Use this ioctl
during HSM restore to ensure that the volatile file has the same
timestamps as the file to be restored. Strengthen sanity-hsm test_24a
to check that archive, release, and restore do not change a file's
ctime. Add sanity-hsm test_24e to check that tar will succeed when it
encounters a HSM released file.

Signed-off-by: John L. Hammond <john.hammond@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6213
Reviewed-on: http://review.whamcloud.com/13665
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Jinshan Xiong <jinshan.xiong@intel.com>
Reviewed-by: frank zago <fzago@cray.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/lustre/include/lustre/lustre_user.h     |   10 ++++
 drivers/staging/lustre/lustre/llite/file.c         |   45 ++++++++++++++++++++
 drivers/staging/lustre/lustre/llite/llite_lib.c    |    6 ++-
 3 files changed, 59 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_user.h b/drivers/staging/lustre/lustre/include/lustre/lustre_user.h
index 856e2f9..1d72b73 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_user.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_user.h
@@ -213,6 +213,15 @@ struct ost_id {
 #define DOSTID "%#llx:%llu"
 #define POSTID(oi) ostid_seq(oi), ostid_id(oi)
 
+struct ll_futimes_3 {
+	__u64 lfu_atime_sec;
+	__u64 lfu_atime_nsec;
+	__u64 lfu_mtime_sec;
+	__u64 lfu_mtime_nsec;
+	__u64 lfu_ctime_sec;
+	__u64 lfu_ctime_nsec;
+};
+
 /*
  * The ioctl naming rules:
  * LL_*     - works on the currently opened filehandle instead of parent dir
@@ -249,6 +258,7 @@ struct ost_id {
 #define LL_IOC_PATH2FID		 _IOR('f', 173, long)
 #define LL_IOC_GET_CONNECT_FLAGS	_IOWR('f', 174, __u64 *)
 #define LL_IOC_GET_MDTIDX	       _IOR('f', 175, int)
+#define LL_IOC_FUTIMES_3		_IOWR('f', 176, struct ll_futimes_3)
 
 /*	lustre_ioctl.h			177-210 */
 #define LL_IOC_HSM_STATE_GET		_IOR('f', 211, struct hsm_user_state)
diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
index 0ae78c7..694d920 100644
--- a/drivers/staging/lustre/lustre/llite/file.c
+++ b/drivers/staging/lustre/lustre/llite/file.c
@@ -1904,6 +1904,41 @@ static inline long ll_lease_type_from_fmode(fmode_t fmode)
 	       ((fmode & FMODE_WRITE) ? LL_LEASE_WRLCK : 0);
 }
 
+static int ll_file_futimes_3(struct file *file, const struct ll_futimes_3 *lfu)
+{
+	struct inode *inode = file_inode(file);
+	struct iattr ia = {
+		.ia_valid = ATTR_ATIME | ATTR_ATIME_SET |
+			    ATTR_MTIME | ATTR_MTIME_SET |
+			    ATTR_CTIME | ATTR_CTIME_SET,
+		.ia_atime = {
+			.tv_sec = lfu->lfu_atime_sec,
+			.tv_nsec = lfu->lfu_atime_nsec,
+		},
+		.ia_mtime = {
+			.tv_sec = lfu->lfu_mtime_sec,
+			.tv_nsec = lfu->lfu_mtime_nsec,
+		},
+		.ia_ctime = {
+			.tv_sec = lfu->lfu_ctime_sec,
+			.tv_nsec = lfu->lfu_ctime_nsec,
+		},
+	};
+	int rc;
+
+	if (!capable(CAP_SYS_ADMIN))
+		return -EPERM;
+
+	if (!S_ISREG(inode->i_mode))
+		return -EINVAL;
+
+	inode_lock(inode);
+	rc = ll_setattr_raw(file_dentry(file), &ia, false);
+	inode_unlock(inode);
+
+	return rc;
+}
+
 static long
 ll_file_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 {
@@ -2138,6 +2173,16 @@ static inline long ll_lease_type_from_fmode(fmode_t fmode)
 				fmode = 0;
 
 			return ll_lease_type_from_fmode(fmode);
+		case LL_IOC_FUTIMES_3: {
+			const struct ll_futimes_3 __user *lfu_user;
+			struct ll_futimes_3 lfu;
+
+			lfu_user = (const struct ll_futimes_3 __user *)arg;
+			if (copy_from_user(&lfu, lfu_user, sizeof(lfu)))
+				return -EFAULT;
+
+			return ll_file_futimes_3(file, &lfu);
+		}
 		default:
 			return -EINVAL;
 		}
diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index 308da06..2954aa9 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -1410,7 +1410,8 @@ int ll_setattr_raw(struct dentry *dentry, struct iattr *attr, bool hsm_import)
 	}
 
 	/* We mark all of the fields "set" so MDS/OST does not re-set them */
-	if (attr->ia_valid & ATTR_CTIME) {
+	if (!(attr->ia_valid & ATTR_CTIME_SET) &&
+	    (attr->ia_valid & ATTR_CTIME)) {
 		attr->ia_ctime = CURRENT_TIME;
 		attr->ia_valid |= ATTR_CTIME_SET;
 	}
@@ -1516,7 +1517,8 @@ int ll_setattr_raw(struct dentry *dentry, struct iattr *attr, bool hsm_import)
 
 	if (attr->ia_valid & (ATTR_SIZE |
 			      ATTR_ATIME | ATTR_ATIME_SET |
-			      ATTR_MTIME | ATTR_MTIME_SET)) {
+			      ATTR_MTIME | ATTR_MTIME_SET |
+			      ATTR_CTIME | ATTR_CTIME_SET)) {
 		/* For truncate and utimes sending attributes to OSTs, setting
 		 * mtime/atime to the past will be performed under PW [0:EOF]
 		 * extent lock (new_size:EOF for truncate).  It may seem
-- 
1.7.1
