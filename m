From: James Simmons <jsimmons@infradead.org>
Date: Sun, 14 Oct 2018 15:00:41 -0400
Subject: [lustre-devel] [PATCH 2/7] lustre: quota: add project quota support
 for Lustre
In-Reply-To: <1539543646-29717-1-git-send-email-jsimmons@infradead.org>
References: <1539543646-29717-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1539543646-29717-3-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Li Xi <lixi@ddn.com>

This patch adds necessary support of project quota,
so that OSTs can be mounted successfully.

Signed-off-by: Li Xi <lixi@ddn.com>
Signed-off-by: Wang Shilong <wshilong@ddn.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-4017
Reviewed-on: https://review.whamcloud.com/23947
Reviewed-by: Niu Yawei <yawei.niu@intel.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/include/uapi/linux/lustre/lustre_idl.h  | 9 +++++++--
 drivers/staging/lustre/include/uapi/linux/lustre/lustre_user.h | 2 ++
 drivers/staging/lustre/lustre/llite/dir.c                      | 4 +++-
 drivers/staging/lustre/lustre/osc/osc_quota.c                  | 4 ++++
 4 files changed, 16 insertions(+), 3 deletions(-)

diff --git a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_idl.h b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_idl.h
index 9430f11..1220acd 100644
--- a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_idl.h
+++ b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_idl.h
@@ -913,6 +913,9 @@ enum obdo_flags {
 	OBD_FL_IDONLY       = 0x00000010, /* set in o_flags only adjust obj id*/
 	OBD_FL_RECREATE_OBJS = 0x00000020, /* recreate missing obj */
 	OBD_FL_DEBUG_CHECK  = 0x00000040, /* echo client/server debug check */
+	OBD_FL_NO_PRJQUOTA  = 0x00000080, /* the object's project is over
+					   * quota
+					   */
 	OBD_FL_NO_USRQUOTA  = 0x00000100, /* the object's owner is over quota */
 	OBD_FL_NO_GRPQUOTA  = 0x00000200, /* the object's group is over quota */
 	OBD_FL_CREATE_CROW  = 0x00000400, /* object should be create on write */
@@ -1086,7 +1089,7 @@ static inline __u32 lov_mds_md_size(__u16 stripes, __u32 lmm_magic)
 #define OBD_MD_FLHANDLE		(0x00080000ULL) /* file/lock handle */
 #define OBD_MD_FLCKSUM		(0x00100000ULL) /* bulk data checksum */
 #define OBD_MD_FLQOS		(0x00200000ULL) /* quality of service stats */
-/*#define OBD_MD_FLOSCOPQ	(0x00400000ULL) osc opaque data, never used */
+#define OBD_MD_FLPRJQUOTA	(0x00400000ULL)	/* over quota flags sent from ost */
 /*	OBD_MD_FLCOOKIE		(0x00800000ULL) obsolete in 2.8 */
 #define OBD_MD_FLGROUP		(0x01000000ULL) /* group */
 #define OBD_MD_FLFID		(0x02000000ULL) /* ->ost write inline fid */
@@ -1131,7 +1134,9 @@ static inline __u32 lov_mds_md_size(__u16 stripes, __u32 lmm_magic)
 
 #define OBD_MD_DEFAULT_MEA	(0x0040000000000000ULL) /* default MEA */
 
-#define OBD_MD_FLALLQUOTA (OBD_MD_FLUSRQUOTA | OBD_MD_FLGRPQUOTA)
+#define OBD_MD_FLALLQUOTA (OBD_MD_FLUSRQUOTA | \
+			   OBD_MD_FLGRPQUOTA | \
+			   OBD_MD_FLPRJQUOTA)
 
 #define OBD_MD_FLGETATTR (OBD_MD_FLID    | OBD_MD_FLATIME | OBD_MD_FLMTIME | \
 			  OBD_MD_FLCTIME | OBD_MD_FLSIZE  | OBD_MD_FLBLKSZ | \
diff --git a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_user.h b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_user.h
index b1961df..9d553ce6 100644
--- a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_user.h
+++ b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_user.h
@@ -576,6 +576,8 @@ static inline char *qtype_name(int qtype)
 		return "usr";
 	case GRPQUOTA:
 		return "grp";
+	case PRJQUOTA:
+		return "prj";
 	}
 	return "unknown";
 }
diff --git a/drivers/staging/lustre/lustre/llite/dir.c b/drivers/staging/lustre/lustre/llite/dir.c
index 7047938..9fa0e2e 100644
--- a/drivers/staging/lustre/lustre/llite/dir.c
+++ b/drivers/staging/lustre/lustre/llite/dir.c
@@ -902,7 +902,7 @@ static int copy_and_ioctl(int cmd, struct obd_export *exp,
 	return rc;
 }
 
-static inline int check_owner(int type, int id)
+static int check_owner(int type, int id)
 {
 	switch (type) {
 	case USRQUOTA:
@@ -913,6 +913,8 @@ static inline int check_owner(int type, int id)
 		if (!in_egroup_p(make_kgid(&init_user_ns, id)))
 			return -EPERM;
 		break;
+	case PRJQUOTA:
+		break;
 	}
 	return 0;
 }
diff --git a/drivers/staging/lustre/lustre/osc/osc_quota.c b/drivers/staging/lustre/lustre/osc/osc_quota.c
index 13ef482..555f1be 100644
--- a/drivers/staging/lustre/lustre/osc/osc_quota.c
+++ b/drivers/staging/lustre/lustre/osc/osc_quota.c
@@ -85,6 +85,8 @@ static inline u32 md_quota_flag(int qtype)
 		return OBD_MD_FLUSRQUOTA;
 	case GRPQUOTA:
 		return OBD_MD_FLGRPQUOTA;
+	case PRJQUOTA:
+		return OBD_MD_FLPRJQUOTA;
 	default:
 		return 0;
 	}
@@ -97,6 +99,8 @@ static inline u32 fl_quota_flag(int qtype)
 		return OBD_FL_NO_USRQUOTA;
 	case GRPQUOTA:
 		return OBD_FL_NO_GRPQUOTA;
+	case PRJQUOTA:
+		return OBD_FL_NO_PRJQUOTA;
 	default:
 		return 0;
 	}
-- 
1.8.3.1
