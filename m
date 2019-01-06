From: James Simmons <jsimmons@infradead.org>
Date: Sun,  6 Jan 2019 17:14:02 -0500
Subject: [lustre-devel] [PATCH v2 07/33] lustre: lov: add composite layout
 unpacking
In-Reply-To: <1546812868-11794-1-git-send-email-jsimmons@infradead.org>
References: <1546812868-11794-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1546812868-11794-8-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Bobi Jam <bobijam@hotmail.com>

Update struct lov_stripe_md to accommodate composite layouts. Add
methods to unpack composite layouts.

Signed-off-by: John L. Hammond <jhammond@whamcloud.com>
Signed-off-by: Bobi Jam <bobijam@hotmail.com>
Signed-off-by: Niu Yawei <yawei.niu@intel.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-8998
Reviewed-on: https://review.whamcloud.com/24849
WC-bug-id: https://jira.whamcloud.com/browse/LU-9315
Reviewed-on: https://review.whamcloud.com/26503
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Jinshan Xiong <jinshan.xiong@gmail.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/lov/lov_ea.c   | 175 ++++++++++++++++++++++++++-
 drivers/staging/lustre/lustre/lov/lov_pack.c |   3 +
 2 files changed, 175 insertions(+), 3 deletions(-)

diff --git a/drivers/staging/lustre/lustre/lov/lov_ea.c b/drivers/staging/lustre/lustre/lov/lov_ea.c
index f794df9..7d86318 100644
--- a/drivers/staging/lustre/lustre/lov/lov_ea.c
+++ b/drivers/staging/lustre/lustre/lov/lov_ea.c
@@ -38,12 +38,21 @@
 #define DEBUG_SUBSYSTEM S_LOV
 
 #include <asm/div64.h>
+#include <linux/sort.h>
 
 #include <obd_class.h>
 #include <uapi/linux/lustre/lustre_idl.h>
+#include <uapi/linux/lustre/lustre_user.h>
 
 #include "lov_internal.h"
 
+static inline void lu_extent_le_to_cpu(struct lu_extent *dst,
+				       const struct lu_extent *src)
+{
+	dst->e_start = le64_to_cpu(src->e_start);
+	dst->e_end = le64_to_cpu(src->e_end);
+}
+
 /*
  * Find minimum stripe maxbytes value. For inactive or
  * reconnecting targets use LUSTRE_EXT3_STRIPE_MAXBYTES.
@@ -347,17 +356,177 @@ void lsm_free(struct lov_stripe_md *lsm)
 	.lsm_unpackmd		= lsm_unpackmd_v3,
 };
 
+static int lsm_verify_comp_md_v1(struct lov_comp_md_v1 *lcm,
+				 size_t lcm_buf_size)
+{
+	unsigned int entry_count;
+	size_t lcm_size;
+	unsigned int i;
+
+	lcm_size = le32_to_cpu(lcm->lcm_size);
+	if (lcm_buf_size < lcm_size) {
+		CERROR("bad LCM buffer size %zu, expected %zu\n",
+		       lcm_buf_size, lcm_size);
+		return -EINVAL;
+	}
+
+	entry_count = le16_to_cpu(lcm->lcm_entry_count);
+	for (i = 0; i < entry_count; i++) {
+		struct lov_comp_md_entry_v1 *lcme = &lcm->lcm_entries[i];
+		size_t blob_offset;
+		size_t blob_size;
+
+		blob_offset = le32_to_cpu(lcme->lcme_offset);
+		blob_size = le32_to_cpu(lcme->lcme_size);
+
+		if (lcm_size < blob_offset || lcm_size < blob_size ||
+		    lcm_size < blob_offset + blob_size) {
+			CERROR("LCM entry %u has invalid blob: LCM size = %zu, offset = %zu, size = %zu\n",
+			       le32_to_cpu(lcme->lcme_id), lcm_size,
+			       blob_offset, blob_size);
+			return -EINVAL;
+		}
+	}
+
+	return 0;
+}
+
+static struct lov_stripe_md_entry *
+lsme_unpack_comp(struct lov_obd *lov, struct lov_mds_md *lmm,
+		 size_t lmm_buf_size, loff_t *maxbytes)
+{
+	unsigned int stripe_count;
+	unsigned int magic;
+
+	stripe_count = le16_to_cpu(lmm->lmm_stripe_count);
+	if (stripe_count == 0)
+		return ERR_PTR(-EINVAL);
+
+	magic = le32_to_cpu(lmm->lmm_magic);
+	if (magic != LOV_MAGIC_V1 && magic != LOV_MAGIC_V3)
+		return ERR_PTR(-EINVAL);
+
+	if (lmm_buf_size < lov_mds_md_size(stripe_count, magic))
+		return ERR_PTR(-EINVAL);
+
+	if (magic == LOV_MAGIC_V1) {
+		return lsme_unpack(lov, lmm, lmm_buf_size, NULL,
+				   lmm->lmm_objects, maxbytes);
+	} else {
+		struct lov_mds_md_v3 *lmm3 = (struct lov_mds_md_v3 *)lmm;
+
+		return lsme_unpack(lov, lmm, lmm_buf_size, lmm3->lmm_pool_name,
+				   lmm3->lmm_objects, maxbytes);
+	}
+}
+
+static struct lov_stripe_md *
+lsm_unpackmd_comp_md_v1(struct lov_obd *lov, void *buf, size_t buf_size)
+{
+	struct lov_comp_md_v1 *lcm = buf;
+	struct lov_stripe_md *lsm;
+	unsigned int entry_count = 0;
+	loff_t maxbytes;
+	size_t lsm_size;
+	unsigned int i;
+	int rc;
+
+	rc = lsm_verify_comp_md_v1(buf, buf_size);
+	if (rc < 0)
+		return ERR_PTR(rc);
+
+	entry_count = le16_to_cpu(lcm->lcm_entry_count);
+
+	lsm_size = offsetof(typeof(*lsm), lsm_entries[entry_count]);
+	lsm = kzalloc(lsm_size, GFP_KERNEL);
+	if (!lsm)
+		return ERR_PTR(-ENOMEM);
+
+	atomic_set(&lsm->lsm_refc, 1);
+	spin_lock_init(&lsm->lsm_lock);
+	lsm->lsm_magic = le32_to_cpu(lcm->lcm_magic);
+	lsm->lsm_layout_gen = le32_to_cpu(lcm->lcm_layout_gen);
+	lsm->lsm_entry_count = entry_count;
+	lsm->lsm_is_released = true;
+	lsm->lsm_maxbytes = LLONG_MIN;
+
+	for (i = 0; i < entry_count; i++) {
+		struct lov_comp_md_entry_v1 *lcme = &lcm->lcm_entries[i];
+		struct lov_stripe_md_entry *lsme;
+		size_t blob_offset;
+		size_t blob_size;
+		void *blob;
+
+		blob_offset = le32_to_cpu(lcme->lcme_offset);
+		blob_size = le32_to_cpu(lcme->lcme_size);
+		blob = (char *)lcm + blob_offset;
+
+		lsme = lsme_unpack_comp(lov, blob, blob_size,
+					(i == entry_count - 1) ? &maxbytes :
+					NULL);
+		if (IS_ERR(lsme)) {
+			rc = PTR_ERR(lsme);
+			goto out_lsm;
+		}
+
+		if (!(lsme->lsme_pattern & LOV_PATTERN_F_RELEASED))
+			lsm->lsm_is_released = false;
+
+		lsm->lsm_entries[i] = lsme;
+		lsme->lsme_id = le32_to_cpu(lcme->lcme_id);
+		lu_extent_le_to_cpu(&lsme->lsme_extent, &lcme->lcme_extent);
+
+		if (i == entry_count - 1) {
+			lsm->lsm_maxbytes = (loff_t)lsme->lsme_extent.e_start +
+					    maxbytes;
+			/* the last component hasn't been defined, or
+			 * lsm_maxbytes overflowed.
+			 */
+			if (lsme->lsme_extent.e_end != LUSTRE_EOF ||
+			    lsm->lsm_maxbytes <
+			    (loff_t)lsme->lsme_extent.e_start)
+				lsm->lsm_maxbytes = MAX_LFS_FILESIZE;
+		}
+	}
+
+	return lsm;
+
+out_lsm:
+	for (i = 0; i < entry_count; i++)
+		if (lsm->lsm_entries[i])
+			lsme_free(lsm->lsm_entries[i]);
+
+	kfree(lsm);
+
+	return ERR_PTR(rc);
+}
+
+const static struct lsm_operations lsm_comp_md_v1_ops = {
+	.lsm_stripe_by_index	= lsm_stripe_by_index_plain,
+	.lsm_stripe_by_offset	= lsm_stripe_by_offset_plain,
+	.lsm_unpackmd		= lsm_unpackmd_comp_md_v1,
+};
+
 const struct lsm_operations *lsm_op_find(int magic)
 {
+	const struct lsm_operations *lsm = NULL;
+
 	switch (magic) {
 	case LOV_MAGIC_V1:
-		return &lsm_v1_ops;
+		lsm = &lsm_v1_ops;
+		break;
 	case LOV_MAGIC_V3:
-		return &lsm_v3_ops;
+		lsm = &lsm_v3_ops;
+		break;
+	case LOV_MAGIC_COMP_V1:
+		lsm = &lsm_comp_md_v1_ops;
+		break;
 	default:
 		CERROR("unrecognized lsm_magic %08x\n", magic);
-		return NULL;
+		break;
 	}
+
+	return lsm;
 }
 
 void dump_lsm(unsigned int level, const struct lov_stripe_md *lsm)
diff --git a/drivers/staging/lustre/lustre/lov/lov_pack.c b/drivers/staging/lustre/lustre/lov/lov_pack.c
index 3700937..8b7a572 100644
--- a/drivers/staging/lustre/lustre/lov/lov_pack.c
+++ b/drivers/staging/lustre/lustre/lov/lov_pack.c
@@ -206,6 +206,9 @@ struct lov_stripe_md *lov_unpackmd(struct lov_obd *lov, void *buf,
 	const struct lsm_operations *op;
 	u32 magic;
 
+	if (buf_size < sizeof(magic))
+		return ERR_PTR(-EINVAL);
+
 	magic = le32_to_cpu(*(u32 *)buf);
 	op = lsm_op_find(magic);
 	if (!op)
-- 
1.8.3.1
