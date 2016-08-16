From: James Simmons <jsimmons@infradead.org>
Date: Tue, 16 Aug 2016 16:19:00 -0400
Subject: [lustre-devel] [PATCH 47/80] staging: lustre: uapi: reduce scope of
	lustre_idl.h
In-Reply-To: <1471378773-24590-1-git-send-email-jsimmons@infradead.org>
References: <1471378773-24590-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1471378773-24590-48-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, "John L. Hammond" <john.hammond@intel.com>, James Simmons <jsimmons@infradead.org>

From: John L. Hammond <john.hammond@intel.com>

Move the definition of OBD_OCD_VERSION() and similar macros from
lustre_idl.h to lustre_ver.h. These macros are primarily used in
comparisons to LUSTRE_VERSION_CODE which is defined in lustre_ver.h
and so should be defined there as well. Move a few definitions
(related to FIDs, quota and striping) from lustre_idl.h to
lustre_user.h.

Signed-off-by: John L. Hammond <john.hammond@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5065
Reviewed-on: http://review.whamcloud.com/10336
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Bob Glossman <bob.glossman@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/lustre/include/lustre/lustre_idl.h      |   38 +------------------
 .../lustre/lustre/include/lustre/lustre_user.h     |   32 +++++++++++++++--
 drivers/staging/lustre/lustre/include/lustre_ver.h |   13 +++++--
 3 files changed, 41 insertions(+), 42 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
index 8736826..69bed64 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
@@ -93,6 +93,7 @@
 /* Defn's shared with user-space. */
 #include "lustre_user.h"
 #include "lustre_errno.h"
+#include "../lustre_ver.h"
 
 /*
  *  GENERAL STUFF
@@ -846,11 +847,6 @@ static inline bool fid_is_sane(const struct lu_fid *fid)
 		fid_seq_is_rsvd(fid_seq(fid)));
 }
 
-static inline bool fid_is_zero(const struct lu_fid *fid)
-{
-	return fid_seq(fid) == 0 && fid_oid(fid) == 0;
-}
-
 void lustre_swab_lu_fid(struct lu_fid *fid);
 void lustre_swab_lu_seq_range(struct lu_seq_range *range);
 
@@ -1318,14 +1314,6 @@ void lustre_swab_ptlrpc_body(struct ptlrpc_body *pb);
 #define CLIENT_CONNECT_MDT_REQD (OBD_CONNECT_IBITS | OBD_CONNECT_FID | \
 				 OBD_CONNECT_FULL20)
 
-#define OBD_OCD_VERSION(major, minor, patch, fix) (((major)<<24) + \
-						  ((minor)<<16) + \
-						  ((patch)<<8) + (fix))
-#define OBD_OCD_VERSION_MAJOR(version) ((int)((version)>>24)&255)
-#define OBD_OCD_VERSION_MINOR(version) ((int)((version)>>16)&255)
-#define OBD_OCD_VERSION_PATCH(version) ((int)((version)>>8)&255)
-#define OBD_OCD_VERSION_FIX(version)   ((int)(version)&255)
-
 /* This structure is used for both request and reply.
  *
  * If we eventually have separate connect data for different types, which we
@@ -1509,14 +1497,6 @@ enum obdo_flags {
 #define LOV_MAGIC_V1_DEF  0x0CD10BD0
 #define LOV_MAGIC_V3_DEF  0x0CD30BD0
 
-#define LOV_PATTERN_RAID0	0x001   /* stripes are used round-robin */
-#define LOV_PATTERN_RAID1	0x002   /* stripes are mirrors of each other */
-#define LOV_PATTERN_FIRST	0x100   /* first stripe is not in round-robin */
-#define LOV_PATTERN_CMOBD	0x200
-
-#define LOV_PATTERN_F_MASK	0xffff0000
-#define LOV_PATTERN_F_RELEASED	0x80000000 /* HSM released file */
-
 #define lov_pattern(pattern)		(pattern & ~LOV_PATTERN_F_MASK)
 #define lov_pattern_flags(pattern)	(pattern & LOV_PATTERN_F_MASK)
 
@@ -1796,7 +1776,7 @@ void lustre_swab_obd_statfs(struct obd_statfs *os);
 				      * it to sync quickly
 				      */
 
-#define OBD_OBJECT_EOF 0xffffffffffffffffULL
+#define OBD_OBJECT_EOF	LUSTRE_EOF
 
 #define OST_MIN_PRECREATE 32
 #define OST_MAX_PRECREATE 20000
@@ -1892,12 +1872,6 @@ struct obd_quotactl {
 
 void lustre_swab_obd_quotactl(struct obd_quotactl *q);
 
-#define Q_QUOTACHECK	0x800100 /* deprecated as of 2.4 */
-#define Q_INITQUOTA	0x800101 /* deprecated as of 2.4  */
-#define Q_GETOINFO	0x800102 /* get obd quota info */
-#define Q_GETOQUOTA	0x800103 /* get obd quotas */
-#define Q_FINVALIDATE	0x800104 /* deprecated as of 2.4 */
-
 #define Q_COPY(out, in, member) (out)->member = (in)->member
 
 #define QCTL_COPY(out, in)		\
@@ -2533,19 +2507,11 @@ struct lmv_mds_md_v1 {
  * for example the object is being migrated. And the hash function
  * might be interpreted differently with different flags.
  */
-enum lmv_hash_type {
-	LMV_HASH_TYPE_ALL_CHARS = 1,
-	LMV_HASH_TYPE_FNV_1A_64 = 2,
-};
-
 #define LMV_HASH_TYPE_MASK		0x0000ffff
 
 #define LMV_HASH_FLAG_MIGRATION		0x80000000
 #define LMV_HASH_FLAG_DEAD		0x40000000
 
-#define LMV_HASH_NAME_ALL_CHARS		"all_char"
-#define LMV_HASH_NAME_FNV_1A_64		"fnv_1a_64"
-
 /**
  * The FNV-1a hash algorithm is as follows:
  *     hash = FNV_offset_basis
diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_user.h b/drivers/staging/lustre/lustre/include/lustre/lustre_user.h
index 59d45de..8398c4f 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_user.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_user.h
@@ -45,6 +45,8 @@
 #include "ll_fiemap.h"
 #include "../linux/lustre_user.h"
 
+#define LUSTRE_EOF 0xffffffffffffffffULL
+
 /* for statfs() */
 #define LL_SUPER_MAGIC 0x0BD00BD0
 
@@ -117,6 +119,11 @@ struct lu_fid {
 	__u32 f_ver;
 };
 
+static inline bool fid_is_zero(const struct lu_fid *fid)
+{
+	return !fid->f_seq && !fid->f_oid;
+}
+
 struct filter_fid {
 	struct lu_fid	ff_parent;  /* ff_parent.f_ver == file stripe number */
 };
@@ -271,9 +278,14 @@ struct ost_id {
 
 #define LMV_USER_MAGIC    0x0CD30CD0    /*default lmv magic*/
 
-#define LOV_PATTERN_RAID0 0x001
-#define LOV_PATTERN_RAID1 0x002
-#define LOV_PATTERN_FIRST 0x100
+#define LOV_PATTERN_RAID0	0x001
+#define LOV_PATTERN_RAID1	0x002
+#define LOV_PATTERN_FIRST	0x100
+#define LOV_PATTERN_CMOBD	0x200
+
+#define LOV_PATTERN_F_MASK	0xffff0000
+#define LOV_PATTERN_F_RELEASED	0x80000000 /* HSM released file */
+
 
 #define LOV_MAXPOOLNAME 16
 #define LOV_POOLNAMEF "%.16s"
@@ -370,6 +382,14 @@ struct lmv_user_mds_data {
 	__u32		lum_mds;
 };
 
+enum lmv_hash_type {
+	LMV_HASH_TYPE_ALL_CHARS = 1,
+	LMV_HASH_TYPE_FNV_1A_64 = 2,
+};
+
+#define LMV_HASH_NAME_ALL_CHARS		"all_char"
+#define LMV_HASH_NAME_FNV_1A_64		"fnv_1a_64"
+
 /*
  * Got this according to how get LOV_MAX_STRIPE_COUNT, see above,
  * (max buffer size - lmv+rpc header) / sizeof(struct lmv_user_mds_data)
@@ -488,6 +508,12 @@ static inline void obd_uuid2fsname(char *buf, char *uuid, int buflen)
 
 /********* Quotas **********/
 
+#define Q_QUOTACHECK   0x800100 /* deprecated as of 2.4 */
+#define Q_INITQUOTA    0x800101 /* deprecated as of 2.4  */
+#define Q_GETOINFO     0x800102 /* get obd quota info */
+#define Q_GETOQUOTA    0x800103 /* get obd quotas */
+#define Q_FINVALIDATE  0x800104 /* deprecated as of 2.4 */
+
 /* these must be explicitly translated into linux Q_* in ll_dir_ioctl */
 #define LUSTRE_Q_QUOTAON    0x800002     /* turn quotas on */
 #define LUSTRE_Q_QUOTAOFF   0x800003     /* turn quotas off */
diff --git a/drivers/staging/lustre/lustre/include/lustre_ver.h b/drivers/staging/lustre/lustre/include/lustre_ver.h
index 64559a1..2bb59b2 100644
--- a/drivers/staging/lustre/lustre/include/lustre_ver.h
+++ b/drivers/staging/lustre/lustre/include/lustre_ver.h
@@ -7,9 +7,16 @@
 #define LUSTRE_FIX 0
 #define LUSTRE_VERSION_STRING "2.4.60"
 
-#define LUSTRE_VERSION_CODE OBD_OCD_VERSION(LUSTRE_MAJOR, \
-					    LUSTRE_MINOR, LUSTRE_PATCH, \
-					    LUSTRE_FIX)
+#define OBD_OCD_VERSION(major, minor, patch, fix)			\
+	(((major) << 24) + ((minor) << 16) + ((patch) << 8) + (fix))
+
+#define OBD_OCD_VERSION_MAJOR(version)	((int)((version) >> 24) & 255)
+#define OBD_OCD_VERSION_MINOR(version)	((int)((version) >> 16) & 255)
+#define OBD_OCD_VERSION_PATCH(version)	((int)((version) >>  8) & 255)
+#define OBD_OCD_VERSION_FIX(version)	((int)((version) >>  0) & 255)
+
+#define LUSTRE_VERSION_CODE						\
+	OBD_OCD_VERSION(LUSTRE_MAJOR, LUSTRE_MINOR, LUSTRE_PATCH, LUSTRE_FIX)
 
 /*
  * If lustre version of client and servers it connects to differs by more
-- 
1.7.1
