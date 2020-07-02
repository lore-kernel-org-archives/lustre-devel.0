From: James Simmons <jsimmons@infradead.org>
Date: Wed,  1 Jul 2020 20:04:53 -0400
Subject: [lustre-devel] [PATCH 13/18] lustre: sec: ioctls to handle
 encryption policies
In-Reply-To: <1593648298-10571-1-git-send-email-jsimmons@infradead.org>
References: <1593648298-10571-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1593648298-10571-14-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Sebastien Buisson <sbuisson@ddn.com>

Introduce support for fscrypt IOCTLs that handle encryption
policies v2. It enables setting/getting encryption policies on
individual directories, letting users decide how they want to
encrypt specific directories.

fscrypt encryption policies v2 are supported from Linux 5.4.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12275
Lustre-commit: 3973cf8dc955c ("LU-12275 sec: ioctls to handle encryption policies")
Signed-off-by: Sebastien Buisson <sbuisson@ddn.com>
Reviewed-on: https://review.whamcloud.com/37673
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: John L. Hammond <jhammond@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/dir.c | 28 ++++++++++++++++++++++++++++
 1 file changed, 28 insertions(+)

diff --git a/fs/lustre/llite/dir.c b/fs/lustre/llite/dir.c
index 2c93908..463c5d7 100644
--- a/fs/lustre/llite/dir.c
+++ b/fs/lustre/llite/dir.c
@@ -48,6 +48,7 @@
 
 #include <obd_support.h>
 #include <obd_class.h>
+#include <uapi/linux/fscrypt.h>
 #include <uapi/linux/lustre/lustre_idl.h>
 #include <uapi/linux/lustre/lustre_ioctl.h>
 #include <lustre_lib.h>
@@ -2103,6 +2104,33 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 		kfree(detach);
 		return rc;
 	}
+#ifdef CONFIG_FS_ENCRYPTION
+	case FS_IOC_SET_ENCRYPTION_POLICY:
+		if (!ll_sbi_has_encrypt(ll_i2sbi(inode)))
+			return -EOPNOTSUPP;
+		return llcrypt_ioctl_set_policy(file, (const void __user *)arg);
+	case FS_IOC_GET_ENCRYPTION_POLICY_EX:
+		if (!ll_sbi_has_encrypt(ll_i2sbi(inode)))
+			return -EOPNOTSUPP;
+		return llcrypt_ioctl_get_policy_ex(file, (void __user *)arg);
+	case FS_IOC_ADD_ENCRYPTION_KEY:
+		if (!ll_sbi_has_encrypt(ll_i2sbi(inode)))
+			return -EOPNOTSUPP;
+		return llcrypt_ioctl_add_key(file, (void __user *)arg);
+	case FS_IOC_REMOVE_ENCRYPTION_KEY:
+		if (!ll_sbi_has_encrypt(ll_i2sbi(inode)))
+			return -EOPNOTSUPP;
+		return llcrypt_ioctl_remove_key(file, (void __user *)arg);
+	case FS_IOC_REMOVE_ENCRYPTION_KEY_ALL_USERS:
+		if (!ll_sbi_has_encrypt(ll_i2sbi(inode)))
+			return -EOPNOTSUPP;
+		return llcrypt_ioctl_remove_key_all_users(file,
+							  (void __user *)arg);
+	case FS_IOC_GET_ENCRYPTION_KEY_STATUS:
+		if (!ll_sbi_has_encrypt(ll_i2sbi(inode)))
+			return -EOPNOTSUPP;
+		return llcrypt_ioctl_get_key_status(file, (void __user *)arg);
+#endif
 	default:
 		return obd_iocontrol(cmd, sbi->ll_dt_exp, 0, NULL,
 				     (void __user *)arg);
-- 
1.8.3.1
