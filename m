From: James Simmons <jsimmons@infradead.org>
Date: Sun,  6 Jan 2019 17:14:27 -0500
Subject: [lustre-devel] [PATCH v2 32/33] lustre: lov: use stripe_count
 instead of stripe_nr
In-Reply-To: <1546812868-11794-1-git-send-email-jsimmons@infradead.org>
References: <1546812868-11794-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1546812868-11794-33-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Andreas Dilger <adilger@whamcloud.com>

Replace the use of stripecnt in the code with
stripe_count to be consistent the rest of the code.

Signed-off-by: Andreas Dilger <adilger@whamcloud.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-8653
Reviewed-on: https://review.whamcloud.com/26681
Reviewed-by: Lai Siyao <lai.siyao@whamcloud.com>
Reviewed-by: Steve Guminski <stephenx.guminski@intel.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/lov/lov_internal.h |  2 +-
 drivers/staging/lustre/lustre/lov/lov_pack.c     | 12 ++++++------
 drivers/staging/lustre/lustre/lov/lov_request.c  |  4 ++--
 3 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/drivers/staging/lustre/lustre/lov/lov_internal.h b/drivers/staging/lustre/lustre/lov/lov_internal.h
index 3878cad..2b31c99 100644
--- a/drivers/staging/lustre/lustre/lov/lov_internal.h
+++ b/drivers/staging/lustre/lustre/lov/lov_internal.h
@@ -271,7 +271,7 @@ int lov_prep_statfs_set(struct obd_device *obd, struct obd_info *oinfo,
 void lov_fix_desc_stripe_count(__u32 *val);
 void lov_fix_desc_pattern(__u32 *val);
 void lov_fix_desc_qos_maxage(__u32 *val);
-__u16 lov_get_stripecnt(struct lov_obd *lov, __u32 magic, __u16 stripe_count);
+u16 lov_get_stripe_count(struct lov_obd *lov, u32 magic, u16 stripe_count);
 int lov_connect_obd(struct obd_device *obd, __u32 index, int activate,
 		    struct obd_connect_data *data);
 int lov_setup(struct obd_device *obd, struct lustre_cfg *lcfg);
diff --git a/drivers/staging/lustre/lustre/lov/lov_pack.c b/drivers/staging/lustre/lustre/lov/lov_pack.c
index 089e556..0a6bb1e 100644
--- a/drivers/staging/lustre/lustre/lov/lov_pack.c
+++ b/drivers/staging/lustre/lustre/lov/lov_pack.c
@@ -192,7 +192,7 @@ ssize_t lov_lsm_pack(const struct lov_stripe_md *lsm, void *buf,
 	for (entry = 0; entry < lsm->lsm_entry_count; entry++) {
 		struct lov_stripe_md_entry *lsme;
 		struct lov_mds_md *lmm;
-		u16 stripecnt;
+		u16 stripe_count;
 
 		lsme = lsm->lsm_entries[entry];
 		lcme = &lcmv1->lcm_entries[entry];
@@ -227,11 +227,11 @@ ssize_t lov_lsm_pack(const struct lov_stripe_md *lsm, void *buf,
 
 		if (lsme_inited(lsme) &&
 		    !(lsme->lsme_pattern & LOV_PATTERN_F_RELEASED))
-			stripecnt = lsme->lsme_stripe_count;
+			stripe_count = lsme->lsme_stripe_count;
 		else
-			stripecnt = 0;
+			stripe_count = 0;
 
-		for (i = 0; i < stripecnt; i++) {
+		for (i = 0; i < stripe_count; i++) {
 			struct lov_oinfo *loi = lsme->lsme_oinfo[i];
 
 			ostid_cpu_to_le(&loi->loi_oi, &lmm_objects[i].l_ost_oi);
@@ -241,7 +241,7 @@ ssize_t lov_lsm_pack(const struct lov_stripe_md *lsm, void *buf,
 				cpu_to_le32(loi->loi_ost_idx);
 		}
 
-		size = lov_mds_md_size(stripecnt, lsme->lsme_magic);
+		size = lov_mds_md_size(stripe_count, lsme->lsme_magic);
 		lcme->lcme_size = cpu_to_le32(size);
 		offset += size;
 	} /* for each layout component */
@@ -250,7 +250,7 @@ ssize_t lov_lsm_pack(const struct lov_stripe_md *lsm, void *buf,
 }
 
 /* Find the max stripecount we should use */
-__u16 lov_get_stripecnt(struct lov_obd *lov, __u32 magic, __u16 stripe_count)
+u16 lov_get_stripe_count(struct lov_obd *lov, u32 magic, u16 stripe_count)
 {
 	__u32 max_stripes = LOV_MAX_STRIPE_COUNT_OLD;
 
diff --git a/drivers/staging/lustre/lustre/lov/lov_request.c b/drivers/staging/lustre/lustre/lov/lov_request.c
index 8ca13ed..d13e8d1 100644
--- a/drivers/staging/lustre/lustre/lov/lov_request.c
+++ b/drivers/staging/lustre/lustre/lov/lov_request.c
@@ -149,8 +149,8 @@ static int lov_fini_statfs(struct obd_device *obd, struct obd_statfs *osfs,
 			   int success)
 {
 	if (success) {
-		__u32 expected_stripes = lov_get_stripecnt(&obd->u.lov,
-							   LOV_MAGIC, 0);
+		u32 expected_stripes = lov_get_stripe_count(&obd->u.lov,
+							    LOV_MAGIC, 0);
 		if (osfs->os_files != LOV_U64_MAX)
 			lov_do_div64(osfs->os_files, expected_stripes);
 		if (osfs->os_ffree != LOV_U64_MAX)
-- 
1.8.3.1
