From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:12:45 -0500
Subject: [lustre-devel] [PATCH 297/622] lustre: lov: Add overstriping support
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-298-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Patrick Farrell <pfarrell@whamcloud.com>

Each stripe in a shared file in Lustre corresponds to a
single LDLM extent locking domain and also to a single
object on disk (and in the OSS page cache).  LDLM locks are
extent locks, but there are still significant issues with
false sharing with multiple writers.  On-disk file systems
also have per-object performance limitations for both read
and write.

The LDLM limitation means it is best to have a single
writer per stripe, but modern OSTs can be faster than a
single client, so this restricts maximum performance unless
special methods are used (eg, Lustre lock ahead).

The on disk file system limitations mean that even if LDLM
locking is not an issue (read and not write, or lockahead),
OST performance in a shared file is still limited by having
only one object per OST.

These limitations make it impossible to get the full
performance of a modern Lustre FS with a single shared
file.

This patch makes it possible to have >1 stripe on a given
OST in each layout component.  This is known as
overstriping.  It works exactly like a normally striped
file, and is largely transparent to users.

By raising the object count per OST, this avoids the single
object limits, and by creating more stripes, also avoids
the "single effective writer per stripe" LDLM limitation.

However, it is only desirable in some situations, so users
must request it with a special setstripe command:

lfs setstripe -C [count] [file]

Users can also access overstriping using the standard '-o'
option to manually select OSTs:

lfs setstripe -o [ost_indices] [file]

Overstriping also makes it easy to test layout size limits,so we add a
test for that.

WC-bug-id: https://jira.whamcloud.com/browse/LU-9846
Lustre-commit: 591a9b4cebc5 ("LU-9846 lod: Add overstriping support")
Signed-off-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/28425
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/llite_lib.c             |  1 +
 fs/lustre/lov/lov_cl_internal.h         |  5 +++--
 fs/lustre/lov/lov_ea.c                  | 33 ++++++++++++++++++++++-----------
 fs/lustre/lov/lov_obd.c                 |  4 ++--
 fs/lustre/ptlrpc/wiretest.c             |  4 ++--
 include/uapi/linux/lustre/lustre_user.h | 22 +++++++++++++++++-----
 6 files changed, 47 insertions(+), 22 deletions(-)

diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index a89189c..d6293d1 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -210,6 +210,7 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt)
 
 	data->ocd_connect_flags2 = OBD_CONNECT2_DIR_MIGRATE |
 				   OBD_CONNECT2_SUM_STATFS |
+				   OBD_CONNECT2_OVERSTRIPING |
 				   OBD_CONNECT2_FLR |
 				   OBD_CONNECT2_LOCK_CONVERT |
 				   OBD_CONNECT2_ARCHIVE_ID_ARRAY |
diff --git a/fs/lustre/lov/lov_cl_internal.h b/fs/lustre/lov/lov_cl_internal.h
index 7b95a00..6fea0f5 100644
--- a/fs/lustre/lov/lov_cl_internal.h
+++ b/fs/lustre/lov/lov_cl_internal.h
@@ -150,9 +150,10 @@ static inline char *llt2str(enum lov_layout_type llt)
  */
 static inline u32 lov_entry_type(struct lov_stripe_md_entry *lsme)
 {
-	if ((lov_pattern(lsme->lsme_pattern) == LOV_PATTERN_RAID0) ||
+	if ((lov_pattern(lsme->lsme_pattern) & LOV_PATTERN_RAID0) ||
 	    (lov_pattern(lsme->lsme_pattern) == LOV_PATTERN_MDT))
-		return lov_pattern(lsme->lsme_pattern);
+		return lov_pattern(lsme->lsme_pattern &
+				   ~LOV_PATTERN_OVERSTRIPING);
 	return 0;
 }
 
diff --git a/fs/lustre/lov/lov_ea.c b/fs/lustre/lov/lov_ea.c
index b7a6d91..07bfe0f 100644
--- a/fs/lustre/lov/lov_ea.c
+++ b/fs/lustre/lov/lov_ea.c
@@ -84,34 +84,45 @@ static loff_t lov_tgt_maxbytes(struct lov_tgt_desc *tgt)
 static int lsm_lmm_verify_v1v3(struct lov_mds_md *lmm, size_t lmm_size,
 			       u16 stripe_count)
 {
+	int rc = 0;
+
 	if (stripe_count > LOV_V1_INSANE_STRIPE_COUNT) {
-		CERROR("bad stripe count %d\n", stripe_count);
+		rc = -EINVAL;
+		CERROR("lov: bad stripe count %d: rc = %d\n",
+		       stripe_count, rc);
 		lov_dump_lmm_common(D_WARNING, lmm);
-		return -EINVAL;
+		goto out;
 	}
 
 	if (lmm_oi_id(&lmm->lmm_oi) == 0) {
-		CERROR("zero object id\n");
+		rc = -EINVAL;
+		CERROR("lov: zero object id: rc = %d\n", rc);
 		lov_dump_lmm_common(D_WARNING, lmm);
-		return -EINVAL;
+		goto out;
 	}
 
 	if (lov_pattern(le32_to_cpu(lmm->lmm_pattern)) != LOV_PATTERN_MDT &&
-	    lov_pattern(le32_to_cpu(lmm->lmm_pattern)) != LOV_PATTERN_RAID0) {
-		CERROR("bad striping pattern\n");
+	    lov_pattern(le32_to_cpu(lmm->lmm_pattern)) != LOV_PATTERN_RAID0 &&
+	    lov_pattern(le32_to_cpu(lmm->lmm_pattern)) !=
+			(LOV_PATTERN_RAID0 | LOV_PATTERN_OVERSTRIPING)) {
+		rc = -EINVAL;
+		CERROR("lov: unrecognized striping pattern: rc = %d\n", rc);
 		lov_dump_lmm_common(D_WARNING, lmm);
-		return -EINVAL;
+		goto out;
 	}
 
 	if (lmm->lmm_stripe_size == 0 ||
 	    (le32_to_cpu(lmm->lmm_stripe_size) &
 	     (LOV_MIN_STRIPE_SIZE - 1)) != 0) {
-		CERROR("bad stripe size %u\n",
-		       le32_to_cpu(lmm->lmm_stripe_size));
+		rc = -EINVAL;
+		CERROR("lov: bad stripe size %u: rc = %d\n",
+		       le32_to_cpu(lmm->lmm_stripe_size), rc);
 		lov_dump_lmm_common(D_WARNING, lmm);
-		return -EINVAL;
+		goto out;
 	}
-	return 0;
+
+out:
+	return rc;
 }
 
 static void lsme_free(struct lov_stripe_md_entry *lsme)
diff --git a/fs/lustre/lov/lov_obd.c b/fs/lustre/lov/lov_obd.c
index 3a90e7e..234b556 100644
--- a/fs/lustre/lov/lov_obd.c
+++ b/fs/lustre/lov/lov_obd.c
@@ -699,8 +699,8 @@ void lov_fix_desc_stripe_count(u32 *val)
 void lov_fix_desc_pattern(u32 *val)
 {
 	/* from lov_setstripe */
-	if ((*val != 0) && (*val != LOV_PATTERN_RAID0)) {
-		LCONSOLE_WARN("Unknown stripe pattern: %#x\n", *val);
+	if ((*val != 0) && !lov_pattern_supported_normal_comp(*val)) {
+		LCONSOLE_WARN("lov: Unknown stripe pattern: %#x\n", *val);
 		*val = 0;
 	}
 }
diff --git a/fs/lustre/ptlrpc/wiretest.c b/fs/lustre/ptlrpc/wiretest.c
index 34c1d13..b8b561c 100644
--- a/fs/lustre/ptlrpc/wiretest.c
+++ b/fs/lustre/ptlrpc/wiretest.c
@@ -1517,8 +1517,8 @@ void lustre_assert_wire_constants(void)
 		 (unsigned int)LOV_PATTERN_RAID1);
 	LASSERTF(LOV_PATTERN_MDT == 0x00000100UL, "found 0x%.8xUL\n",
 		 (unsigned int)LOV_PATTERN_MDT);
-	LASSERTF(LOV_PATTERN_CMOBD == 0x00000200UL, "found 0x%.8xUL\n",
-		 (unsigned int)LOV_PATTERN_CMOBD);
+	LASSERTF(LOV_PATTERN_OVERSTRIPING == 0x00000200UL, "found 0x%.8xUL\n",
+		 (unsigned int)LOV_PATTERN_OVERSTRIPING);
 
 	/* Checks for struct lov_comp_md_entry_v1 */
 	LASSERTF((int)sizeof(struct lov_comp_md_entry_v1) == 48, "found %lld\n",
diff --git a/include/uapi/linux/lustre/lustre_user.h b/include/uapi/linux/lustre/lustre_user.h
index d52879e..dc39265 100644
--- a/include/uapi/linux/lustre/lustre_user.h
+++ b/include/uapi/linux/lustre/lustre_user.h
@@ -394,16 +394,28 @@ struct ll_ioc_lease_id {
 #define LMV_USER_MAGIC		0x0CD30CD0	/*default lmv magic*/
 #define LMV_USER_MAGIC_SPECIFIC	0x0CD40CD0
 
-#define LOV_PATTERN_RAID0	0x001
+#define LOV_PATTERN_NONE		0x000
+#define LOV_PATTERN_RAID0		0x001
 
-#define LOV_PATTERN_RAID1	0x002
-#define LOV_PATTERN_MDT		0x100
-#define LOV_PATTERN_CMOBD	0x200
+#define LOV_PATTERN_RAID1		0x002
+#define LOV_PATTERN_MDT			0x100
+#define LOV_PATTERN_OVERSTRIPING	0x200
 
 #define LOV_PATTERN_F_MASK	0xffff0000
 #define LOV_PATTERN_F_HOLE	0x40000000 /* there is hole in LOV EA */
 #define LOV_PATTERN_F_RELEASED	0x80000000 /* HSM released file */
 
+/* RELEASED and MDT patterns are not valid in many places, so rather than
+ * having many extra checks on lov_pattern_supported, we have this separate
+ * check for non-released, non-DOM components
+ */
+static inline bool lov_pattern_supported_normal_comp(__u32 pattern)
+{
+	return pattern == LOV_PATTERN_RAID0 ||
+	       pattern == (LOV_PATTERN_RAID0 | LOV_PATTERN_OVERSTRIPING);
+
+}
+
 #define LOV_MAXPOOLNAME 15
 #define LOV_POOLNAMEF "%.15s"
 #define LOV_OFFSET_DEFAULT      ((__u16)-1)
@@ -421,7 +433,7 @@ struct ll_ioc_lease_id {
  *
  * (max buffer size - lov+rpc header) / sizeof(struct lov_ost_data_v1)
  */
-#define LOV_MAX_STRIPE_COUNT	2000  /* ((12 * 4096 - 256) / 24) */
+#define LOV_MAX_STRIPE_COUNT	2000  /* ~((12 * 4096 - 256) / 24) */
 #define LOV_ALL_STRIPES		0xffff /* only valid for directories */
 #define LOV_V1_INSANE_STRIPE_COUNT 65532 /* maximum stripe count bz13933 */
 
-- 
1.8.3.1
