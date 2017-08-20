From: James Simmons <jsimmons@infradead.org>
Date: Sat, 19 Aug 2017 22:26:38 -0400
Subject: [lustre-devel] [PATCH 44/64 v2] staging: lustre: uapi: remove BIT
	macro from UAPI headers
In-Reply-To: <1503196018-24500-1-git-send-email-jsimmons@infradead.org>
References: <1503196018-24500-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1503196018-24500-45-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

The BIT macro is not available for UAPI headers so remove
it from the lustre UAPI headers.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/include/uapi/linux/lustre/lustre_idl.h  | 38 +++++++++++-----------
 .../lustre/include/uapi/linux/lustre/lustre_user.h | 12 +++----
 2 files changed, 25 insertions(+), 25 deletions(-)

diff --git a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_idl.h b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_idl.h
index 9613f7c..cc59c1a 100644
--- a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_idl.h
+++ b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_idl.h
@@ -1554,8 +1554,8 @@ enum mds_op_bias {
 	MDS_CREATE_VOLATILE	= 1 << 10,
 	MDS_OWNEROVERRIDE	= 1 << 11,
 	MDS_HSM_RELEASE		= 1 << 12,
-	MDS_RENAME_MIGRATE	= BIT(13),
-	MDS_CLOSE_LAYOUT_SWAP   = BIT(14),
+	MDS_RENAME_MIGRATE	= 1 << 13,
+	MDS_CLOSE_LAYOUT_SWAP	= 1 << 14,
 };
 
 /* instance of mdt_reint_rec */
@@ -1993,21 +1993,21 @@ struct ldlm_flock_wire {
 };
 
 enum ldlm_intent_flags {
-	IT_OPEN		= BIT(0),
-	IT_CREAT	= BIT(1),
-	IT_OPEN_CREAT	= BIT(1) | BIT(0),
-	IT_READDIR	= BIT(2),
-	IT_GETATTR	= BIT(3),
-	IT_LOOKUP	= BIT(4),
-	IT_UNLINK	= BIT(5),
-	IT_TRUNC	= BIT(6),
-	IT_GETXATTR	= BIT(7),
-	IT_EXEC		= BIT(8),
-	IT_PIN		= BIT(9),
-	IT_LAYOUT	= BIT(10),
-	IT_QUOTA_DQACQ	= BIT(11),
-	IT_QUOTA_CONN	= BIT(12),
-	IT_SETXATTR	= BIT(13),
+	IT_OPEN		= 0x00000001,
+	IT_CREAT	= 0x00000002,
+	IT_OPEN_CREAT	= 0x00000003,
+	IT_READDIR	= 0x00000004,
+	IT_GETATTR	= 0x00000008,
+	IT_LOOKUP	= 0x00000010,
+	IT_UNLINK	= 0x00000020,
+	IT_TRUNC	= 0x00000040,
+	IT_GETXATTR	= 0x00000080,
+	IT_EXEC		= 0x00000100,
+	IT_PIN		= 0x00000200,
+	IT_LAYOUT	= 0x00000400,
+	IT_QUOTA_DQACQ	= 0x00000800,
+	IT_QUOTA_CONN	= 0x00001000,
+	IT_SETXATTR	= 0x00002000,
 };
 
 struct ldlm_intent {
@@ -2375,8 +2375,8 @@ enum llog_flag {
 	LLOG_F_ZAP_WHEN_EMPTY	= 0x1,
 	LLOG_F_IS_CAT		= 0x2,
 	LLOG_F_IS_PLAIN		= 0x4,
-	LLOG_F_EXT_JOBID        = BIT(3),
-	LLOG_F_IS_FIXSIZE	= BIT(4),
+	LLOG_F_EXT_JOBID        = 0x8,
+	LLOG_F_IS_FIXSIZE	= 0x10,
 
 	/*
 	 * Note: Flags covered by LLOG_F_EXT_MASK will be inherited from
diff --git a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_user.h b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_user.h
index ca720f1..2fcfe2b 100644
--- a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_user.h
+++ b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_user.h
@@ -645,7 +645,7 @@ struct if_quotactl {
 #define SWAP_LAYOUTS_CHECK_DV2		(1 << 1)
 #define SWAP_LAYOUTS_KEEP_MTIME		(1 << 2)
 #define SWAP_LAYOUTS_KEEP_ATIME		(1 << 3)
-#define SWAP_LAYOUTS_CLOSE		BIT(4)
+#define SWAP_LAYOUTS_CLOSE		(1 << 4)
 
 /* Swap XATTR_NAME_HSM as well, only on the MDT so far */
 #define SWAP_LAYOUTS_MDS_HSM		(1 << 31)
@@ -792,15 +792,15 @@ static inline void hsm_set_cl_error(int *flags, int error)
 
 enum changelog_send_flag {
 	/* Not yet implemented */
-	CHANGELOG_FLAG_FOLLOW	= BIT(0),
+	CHANGELOG_FLAG_FOLLOW	= 0x01,
 	/*
 	 * Blocking IO makes sense in case of slow user parsing of the records,
 	 * but it also prevents us from cleaning up if the records are not
 	 * consumed.
 	 */
-	CHANGELOG_FLAG_BLOCK	= BIT(1),
+	CHANGELOG_FLAG_BLOCK	= 0x02,
 	/* Pack jobid into the changelog records if available. */
-	CHANGELOG_FLAG_JOBID	= BIT(2),
+	CHANGELOG_FLAG_JOBID	= 0x04,
 };
 
 #define CR_MAXSIZE cfs_size_round(2 * NAME_MAX + 2 + \
@@ -981,8 +981,8 @@ struct ioc_data_version {
 	__u64 idv_flags;     /* See LL_DV_xxx */
 };
 
-#define LL_DV_RD_FLUSH	BIT(0)	/* Flush dirty pages from clients */
-#define LL_DV_WR_FLUSH	BIT(1)	/* Flush all caching pages from clients */
+#define LL_DV_RD_FLUSH	(1 << 0) /* Flush dirty pages from clients */
+#define LL_DV_WR_FLUSH	(1 << 1) /* Flush all caching pages from clients */
 
 #ifndef offsetof
 # define offsetof(typ, memb)     ((unsigned long)((char *)&(((typ *)0)->memb)))
-- 
1.8.3.1
