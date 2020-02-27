From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:08:46 -0500
Subject: [lustre-devel] [PATCH 058/622] lustre: quota: add default quota
 setting support
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-59-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Hongchao Zhang <hongchao@whamcloud.com>

Similar function which is motivated by GPFS which is friendly
feature for cluster administrators to manage quota.

Lazy Quota default setting support, here is basic idea:

Default quota setting is global quota setting for user, group,
project quotas, if default quota is set for one quota type,
newer created users/groups/projects will inherit this setting
automatically, since Lustre itself don't have ideas when new
users created, they could only know when this users trying to
acquire space from Lustre.

So we try to implement lazy quota setting inherit, Slave firstly
check if there exists default quota setting, if exists, it will
force slave to acquire quota from master, and master will detect
whether default quota is set, then it will set this quota and also
return proper grant space to slave.

To implement this and reuse existed quota APIs, we try to manage
the default quota in the quota record of 0 id, and enforce the
quota check when reading the quota recored from disk.

In the current Lustre implementation, the grace time is either
the time or the timestamp to be used after some quota ID exceeds
the soft limt, then 48bits should be enough for it, its high 16bits
can be used as kinds of quota flags, this patch will use one of
them as the default quota flag.

The global quota record used by default quota will set its soft
and hard limit as zero, its grace time will contain the default flag.

Use lfs setquota -U/-G/-P <mnt> to set default quota.
Use lfs setquota -u/-g/-p foo -d <mnt> to set foo to use default quota
Use lfs quota -U/-G/-P <mnt> to show default quota.

WC-bug-id: https://jira.whamcloud.com/browse/LU-7816
Lustre-commit: 530881fe4ee2 ("LU-7816 quota: add default quota setting support")
Signed-off-by: Wang Shilong <wshilong@ddn.com>
Signed-off-by: Hongchao Zhang <hongchao@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/32306
Reviewed-by: Fan Yong <fan.yong@intel.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/dir.c                   |  4 +++-
 include/uapi/linux/lustre/lustre_user.h | 22 ++++++++++++++++++++++
 2 files changed, 25 insertions(+), 1 deletion(-)

diff --git a/fs/lustre/llite/dir.c b/fs/lustre/llite/dir.c
index b006e32..c0c3bf0 100644
--- a/fs/lustre/llite/dir.c
+++ b/fs/lustre/llite/dir.c
@@ -949,10 +949,12 @@ static int quotactl_ioctl(struct ll_sb_info *sbi, struct if_quotactl *qctl)
 	switch (cmd) {
 	case Q_SETQUOTA:
 	case Q_SETINFO:
+	case LUSTRE_Q_SETDEFAULT:
 		if (!capable(CAP_SYS_ADMIN))
 			return -EPERM;
 		break;
 	case Q_GETQUOTA:
+	case LUSTRE_Q_GETDEFAULT:
 		if (check_owner(type, id) && !capable(CAP_SYS_ADMIN))
 			return -EPERM;
 		break;
@@ -960,7 +962,7 @@ static int quotactl_ioctl(struct ll_sb_info *sbi, struct if_quotactl *qctl)
 		break;
 	default:
 		CERROR("unsupported quotactl op: %#x\n", cmd);
-		return -ENOTTY;
+		return -ENOTSUPP;
 	}
 
 	if (valid != QC_GENERAL) {
diff --git a/include/uapi/linux/lustre/lustre_user.h b/include/uapi/linux/lustre/lustre_user.h
index 5405e1b..5956f33 100644
--- a/include/uapi/linux/lustre/lustre_user.h
+++ b/include/uapi/linux/lustre/lustre_user.h
@@ -728,6 +728,28 @@ static inline void obd_uuid2fsname(char *buf, char *uuid, int buflen)
 /* lustre-specific control commands */
 #define LUSTRE_Q_INVALIDATE	0x80000b	/* deprecated as of 2.4 */
 #define LUSTRE_Q_FINVALIDATE	0x80000c	/* deprecated as of 2.4 */
+#define LUSTRE_Q_GETDEFAULT	0x80000d	/* get default quota */
+#define LUSTRE_Q_SETDEFAULT	0x80000e	/* set default quota */
+
+/* In the current Lustre implementation, the grace time is either the time
+ * or the timestamp to be used after some quota ID exceeds the soft limt,
+ * 48 bits should be enough, its high 16 bits can be used as quota flags.
+ */
+#define LQUOTA_GRACE_BITS	48
+#define LQUOTA_GRACE_MASK	((1ULL << LQUOTA_GRACE_BITS) - 1)
+#define LQUOTA_GRACE_MAX	LQUOTA_GRACE_MASK
+#define LQUOTA_GRACE(t)		(t & LQUOTA_GRACE_MASK)
+#define LQUOTA_FLAG(t)		(t >> LQUOTA_GRACE_BITS)
+#define LQUOTA_GRACE_FLAG(t, f)	((__u64)t | (__u64)f << LQUOTA_GRACE_BITS)
+
+/* different quota flags */
+
+/* the default quota flag, the corresponding quota ID will use the default
+ * quota setting, the hardlimit and softlimit of its quota record in the global
+ * quota file will be set to 0, the low 48 bits of the grace will be set to 0
+ * and high 16 bits will contain this flag (see above comment).
+ */
+#define LQUOTA_FLAG_DEFAULT	0x0001
 
 #define ALLQUOTA 255	/* set all quota */
 
-- 
1.8.3.1
