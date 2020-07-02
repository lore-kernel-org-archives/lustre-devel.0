From: James Simmons <jsimmons@infradead.org>
Date: Wed,  1 Jul 2020 20:04:50 -0400
Subject: [lustre-devel] [PATCH 10/18] lustre: lov: use lov_pattern_support()
 to verify lmm
In-Reply-To: <1593648298-10571-1-git-send-email-jsimmons@infradead.org>
References: <1593648298-10571-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1593648298-10571-11-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

We can use lov_pattern_support(), which is used by the server
and userland code, to ensure lmm is valid instead of open coding.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12511
Lustre-commit: 0f607f22696ff ("LU-12511 lov: use lov_pattern_support() to verify lmm")
Signed-off-by: James Simmons <jsimmons@infradead.org>
Reviewed-on: https://review.whamcloud.com/38791
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Mike Pershin <mpershin@whamcloud.com>
---
 fs/lustre/lov/lov_ea.c                  | 6 ++----
 include/uapi/linux/lustre/lustre_user.h | 8 ++++++++
 2 files changed, 10 insertions(+), 4 deletions(-)

diff --git a/fs/lustre/lov/lov_ea.c b/fs/lustre/lov/lov_ea.c
index 39ff50b..e198536 100644
--- a/fs/lustre/lov/lov_ea.c
+++ b/fs/lustre/lov/lov_ea.c
@@ -84,6 +84,7 @@ static loff_t lov_tgt_maxbytes(struct lov_tgt_desc *tgt)
 static int lsm_lmm_verify_v1v3(struct lov_mds_md *lmm, size_t lmm_size,
 			       u16 stripe_count)
 {
+	u32 pattern = le32_to_cpu(lmm->lmm_pattern);
 	int rc = 0;
 
 	if (stripe_count > LOV_V1_INSANE_STRIPE_COUNT) {
@@ -101,10 +102,7 @@ static int lsm_lmm_verify_v1v3(struct lov_mds_md *lmm, size_t lmm_size,
 		goto out;
 	}
 
-	if (lov_pattern(le32_to_cpu(lmm->lmm_pattern)) != LOV_PATTERN_MDT &&
-	    lov_pattern(le32_to_cpu(lmm->lmm_pattern)) != LOV_PATTERN_RAID0 &&
-	    lov_pattern(le32_to_cpu(lmm->lmm_pattern)) !=
-			(LOV_PATTERN_RAID0 | LOV_PATTERN_OVERSTRIPING)) {
+	if (!lov_pattern_supported(lov_pattern(pattern))) {
 		rc = -EINVAL;
 		CERROR("lov: unrecognized striping pattern: rc = %d\n", rc);
 		lov_dump_lmm_common(D_WARNING, lmm);
diff --git a/include/uapi/linux/lustre/lustre_user.h b/include/uapi/linux/lustre/lustre_user.h
index 121c064..6a2d5f9 100644
--- a/include/uapi/linux/lustre/lustre_user.h
+++ b/include/uapi/linux/lustre/lustre_user.h
@@ -443,6 +443,14 @@ static inline bool lov_pattern_supported_normal_comp(__u32 pattern)
 #define LOV_OFFSET_DEFAULT      ((__u16)-1)
 #define LMV_OFFSET_DEFAULT      ((__u32)-1)
 
+static inline bool lov_pattern_supported(__u32 pattern)
+{
+	return (pattern & ~LOV_PATTERN_F_RELEASED) == LOV_PATTERN_RAID0 ||
+	       (pattern & ~LOV_PATTERN_F_RELEASED) ==
+			(LOV_PATTERN_RAID0 | LOV_PATTERN_OVERSTRIPING) ||
+	       (pattern & ~LOV_PATTERN_F_RELEASED) == LOV_PATTERN_MDT;
+}
+
 #define LOV_MIN_STRIPE_BITS	16	/* maximum PAGE_SIZE (ia64), power of 2 */
 #define LOV_MIN_STRIPE_SIZE	(1 << LOV_MIN_STRIPE_BITS)
 #define LOV_MAX_STRIPE_COUNT_OLD 160
-- 
1.8.3.1
