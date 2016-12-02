From: James Simmons <jsimmons@infradead.org>
Date: Fri,  2 Dec 2016 14:40:50 -0500
Subject: [lustre-devel] [PATCH 6/6] staging: lustre: headers: use proper
	byteorder functions in lustre_idl.h
In-Reply-To: <1480707650-24089-1-git-send-email-jsimmons@infradead.org>
References: <1480707650-24089-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1480707650-24089-7-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@yahoo.com>

In order for lustre_idl.h to be usable for both user
land and kernel space it has to use the proper
byteorder functions.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6245
Reviewed-on: http://review.whamcloud.com/16916
Reviewed-by: Frank Zago <fzago@cray.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/lustre/include/lustre/lustre_idl.h      |   55 ++++++++++---------
 1 files changed, 29 insertions(+), 26 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
index b0fef6d..c207ad6 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
@@ -69,6 +69,9 @@
 #ifndef _LUSTRE_IDL_H_
 #define _LUSTRE_IDL_H_
 
+#include <asm/byteorder.h>
+#include <linux/types.h>
+
 #include "../../../include/linux/libcfs/libcfs.h"
 #include "../../../include/linux/lnet/types.h"
 
@@ -687,30 +690,30 @@ static inline void lu_igif_build(struct lu_fid *fid, __u32 ino, __u32 gen)
  */
 static inline void fid_cpu_to_le(struct lu_fid *dst, const struct lu_fid *src)
 {
-	dst->f_seq = cpu_to_le64(fid_seq(src));
-	dst->f_oid = cpu_to_le32(fid_oid(src));
-	dst->f_ver = cpu_to_le32(fid_ver(src));
+	dst->f_seq = __cpu_to_le64(fid_seq(src));
+	dst->f_oid = __cpu_to_le32(fid_oid(src));
+	dst->f_ver = __cpu_to_le32(fid_ver(src));
 }
 
 static inline void fid_le_to_cpu(struct lu_fid *dst, const struct lu_fid *src)
 {
-	dst->f_seq = le64_to_cpu(fid_seq(src));
-	dst->f_oid = le32_to_cpu(fid_oid(src));
-	dst->f_ver = le32_to_cpu(fid_ver(src));
+	dst->f_seq = __le64_to_cpu(fid_seq(src));
+	dst->f_oid = __le32_to_cpu(fid_oid(src));
+	dst->f_ver = __le32_to_cpu(fid_ver(src));
 }
 
 static inline void fid_cpu_to_be(struct lu_fid *dst, const struct lu_fid *src)
 {
-	dst->f_seq = cpu_to_be64(fid_seq(src));
-	dst->f_oid = cpu_to_be32(fid_oid(src));
-	dst->f_ver = cpu_to_be32(fid_ver(src));
+	dst->f_seq = __cpu_to_be64(fid_seq(src));
+	dst->f_oid = __cpu_to_be32(fid_oid(src));
+	dst->f_ver = __cpu_to_be32(fid_ver(src));
 }
 
 static inline void fid_be_to_cpu(struct lu_fid *dst, const struct lu_fid *src)
 {
-	dst->f_seq = be64_to_cpu(fid_seq(src));
-	dst->f_oid = be32_to_cpu(fid_oid(src));
-	dst->f_ver = be32_to_cpu(fid_ver(src));
+	dst->f_seq = __be64_to_cpu(fid_seq(src));
+	dst->f_oid = __be32_to_cpu(fid_oid(src));
+	dst->f_ver = __be32_to_cpu(fid_ver(src));
 }
 
 static inline bool fid_is_sane(const struct lu_fid *fid)
@@ -747,8 +750,8 @@ static inline void ostid_cpu_to_le(const struct ost_id *src_oi,
 				   struct ost_id *dst_oi)
 {
 	if (fid_seq_is_mdt0(ostid_seq(src_oi))) {
-		dst_oi->oi.oi_id = cpu_to_le64(src_oi->oi.oi_id);
-		dst_oi->oi.oi_seq = cpu_to_le64(src_oi->oi.oi_seq);
+		dst_oi->oi.oi_id = __cpu_to_le64(src_oi->oi.oi_id);
+		dst_oi->oi.oi_seq = __cpu_to_le64(src_oi->oi.oi_seq);
 	} else {
 		fid_cpu_to_le(&dst_oi->oi_fid, &src_oi->oi_fid);
 	}
@@ -758,8 +761,8 @@ static inline void ostid_le_to_cpu(const struct ost_id *src_oi,
 				   struct ost_id *dst_oi)
 {
 	if (fid_seq_is_mdt0(ostid_seq(src_oi))) {
-		dst_oi->oi.oi_id = le64_to_cpu(src_oi->oi.oi_id);
-		dst_oi->oi.oi_seq = le64_to_cpu(src_oi->oi.oi_seq);
+		dst_oi->oi.oi_id = __le64_to_cpu(src_oi->oi.oi_id);
+		dst_oi->oi.oi_seq = __le64_to_cpu(src_oi->oi.oi_seq);
 	} else {
 		fid_le_to_cpu(&dst_oi->oi_fid, &src_oi->oi_fid);
 	}
@@ -866,7 +869,7 @@ enum lu_dirpage_flags {
 
 static inline struct lu_dirent *lu_dirent_start(struct lu_dirpage *dp)
 {
-	if (le32_to_cpu(dp->ldp_flags) & LDF_EMPTY)
+	if (__le32_to_cpu(dp->ldp_flags) & LDF_EMPTY)
 		return NULL;
 	else
 		return dp->ldp_entries;
@@ -876,8 +879,8 @@ enum lu_dirpage_flags {
 {
 	struct lu_dirent *next;
 
-	if (le16_to_cpu(ent->lde_reclen) != 0)
-		next = ((void *)ent) + le16_to_cpu(ent->lde_reclen);
+	if (__le16_to_cpu(ent->lde_reclen) != 0)
+		next = ((void *)ent) + __le16_to_cpu(ent->lde_reclen);
 	else
 		next = NULL;
 
@@ -1438,15 +1441,15 @@ static inline __u64 lmm_oi_seq(const struct ost_id *oi)
 static inline void lmm_oi_le_to_cpu(struct ost_id *dst_oi,
 				    const struct ost_id *src_oi)
 {
-	dst_oi->oi.oi_id = le64_to_cpu(src_oi->oi.oi_id);
-	dst_oi->oi.oi_seq = le64_to_cpu(src_oi->oi.oi_seq);
+	dst_oi->oi.oi_id = __le64_to_cpu(src_oi->oi.oi_id);
+	dst_oi->oi.oi_seq = __le64_to_cpu(src_oi->oi.oi_seq);
 }
 
 static inline void lmm_oi_cpu_to_le(struct ost_id *dst_oi,
 				    const struct ost_id *src_oi)
 {
-	dst_oi->oi.oi_id = cpu_to_le64(src_oi->oi.oi_id);
-	dst_oi->oi.oi_seq = cpu_to_le64(src_oi->oi.oi_seq);
+	dst_oi->oi.oi_id = __cpu_to_le64(src_oi->oi.oi_id);
+	dst_oi->oi.oi_seq = __cpu_to_le64(src_oi->oi.oi_seq);
 }
 
 #define MAX_MD_SIZE							\
@@ -2378,11 +2381,11 @@ static inline ssize_t lmv_mds_md_size(int stripe_count, unsigned int lmm_magic)
 
 static inline int lmv_mds_md_stripe_count_get(const union lmv_mds_md *lmm)
 {
-	switch (le32_to_cpu(lmm->lmv_magic)) {
+	switch (__le32_to_cpu(lmm->lmv_magic)) {
 	case LMV_MAGIC_V1:
-		return le32_to_cpu(lmm->lmv_md_v1.lmv_stripe_count);
+		return __le32_to_cpu(lmm->lmv_md_v1.lmv_stripe_count);
 	case LMV_USER_MAGIC:
-		return le32_to_cpu(lmm->lmv_user_md.lum_stripe_count);
+		return __le32_to_cpu(lmm->lmv_user_md.lum_stripe_count);
 	default:
 		return -EINVAL;
 	}
-- 
1.7.1
