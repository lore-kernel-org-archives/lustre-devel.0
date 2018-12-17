From: James Simmons <jsimmons@infradead.org>
Date: Mon, 17 Dec 2018 11:29:46 -0500
Subject: [lustre-devel] [PATCH 12/28] lustre: lov: remove
 lsm_stripe_by_[index|offset]_plain
In-Reply-To: <1545064202-22483-1-git-send-email-jsimmons@infradead.org>
References: <1545064202-22483-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1545064202-22483-13-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Bobi Jam <bobijam@hotmail.com>

Since both lsm_stripe_by_index() and lsm_stripe_by_offset() are
the same for lsm_operations replace them with a new universal
function stripe_width().

Signed-off-by: Jinshan Xiong <jinshan.xiong@gmail.com>
Signed-off-by: Bobi Jam <bobijam@hotmail.com>
Signed-off-by: Niu Yawei <yawei.niu@intel.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-8998
Reviewed-on: https://review.whamcloud.com/24850
Reviewed-by: Lai Siyao <lai.siyao@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/lov/lov_ea.c       | 24 ------------------------
 drivers/staging/lustre/lustre/lov/lov_internal.h |  4 ----
 drivers/staging/lustre/lustre/lov/lov_offset.c   | 23 +++++++++++++----------
 3 files changed, 13 insertions(+), 38 deletions(-)

diff --git a/drivers/staging/lustre/lustre/lov/lov_ea.c b/drivers/staging/lustre/lustre/lov/lov_ea.c
index 3a8d79e..f0ea895 100644
--- a/drivers/staging/lustre/lustre/lov/lov_ea.c
+++ b/drivers/staging/lustre/lustre/lov/lov_ea.c
@@ -309,24 +309,6 @@ void lsm_free(struct lov_stripe_md *lsm)
 	return lsm;
 }
 
-static void
-lsm_stripe_by_index_plain(struct lov_stripe_md *lsm, int *stripeno,
-			  loff_t *lov_off, loff_t *swidth)
-{
-	if (swidth)
-		*swidth = (loff_t)lsm->lsm_entries[0]->lsme_stripe_size *
-			  lsm->lsm_entries[0]->lsme_stripe_count;
-}
-
-static void
-lsm_stripe_by_offset_plain(struct lov_stripe_md *lsm, int *stripeno,
-			   loff_t *lov_off, loff_t *swidth)
-{
-	if (swidth)
-		*swidth = (loff_t)lsm->lsm_entries[0]->lsme_stripe_size *
-			  lsm->lsm_entries[0]->lsme_stripe_count;
-}
-
 static struct lov_stripe_md *
 lsm_unpackmd_v1(struct lov_obd *lov, void *buf, size_t buf_size)
 {
@@ -336,8 +318,6 @@ void lsm_free(struct lov_stripe_md *lsm)
 }
 
 const static struct lsm_operations lsm_v1_ops = {
-	.lsm_stripe_by_index	= lsm_stripe_by_index_plain,
-	.lsm_stripe_by_offset	= lsm_stripe_by_offset_plain,
 	.lsm_unpackmd		= lsm_unpackmd_v1,
 };
 
@@ -351,8 +331,6 @@ void lsm_free(struct lov_stripe_md *lsm)
 }
 
 const static struct lsm_operations lsm_v3_ops = {
-	.lsm_stripe_by_index	= lsm_stripe_by_index_plain,
-	.lsm_stripe_by_offset	= lsm_stripe_by_offset_plain,
 	.lsm_unpackmd		= lsm_unpackmd_v3,
 };
 
@@ -502,8 +480,6 @@ static int lsm_verify_comp_md_v1(struct lov_comp_md_v1 *lcm,
 }
 
 const static struct lsm_operations lsm_comp_md_v1_ops = {
-	.lsm_stripe_by_index	= lsm_stripe_by_index_plain,
-	.lsm_stripe_by_offset	= lsm_stripe_by_offset_plain,
 	.lsm_unpackmd		= lsm_unpackmd_comp_md_v1,
 };
 
diff --git a/drivers/staging/lustre/lustre/lov/lov_internal.h b/drivers/staging/lustre/lustre/lov/lov_internal.h
index 4c9e324..ebe5890 100644
--- a/drivers/staging/lustre/lustre/lov/lov_internal.h
+++ b/drivers/staging/lustre/lustre/lov/lov_internal.h
@@ -80,10 +80,6 @@ static inline bool lsm_has_objects(struct lov_stripe_md *lsm)
 }
 
 struct lsm_operations {
-	void (*lsm_stripe_by_index)(struct lov_stripe_md *, int *, loff_t *,
-				    loff_t *);
-	void (*lsm_stripe_by_offset)(struct lov_stripe_md *, int *, loff_t *,
-				     loff_t *);
 	struct lov_stripe_md *(*lsm_unpackmd)(struct lov_obd *obd, void *buf,
 					      size_t buf_len);
 };
diff --git a/drivers/staging/lustre/lustre/lov/lov_offset.c b/drivers/staging/lustre/lustre/lov/lov_offset.c
index d817aa5..513f1fd 100644
--- a/drivers/staging/lustre/lustre/lov/lov_offset.c
+++ b/drivers/staging/lustre/lustre/lov/lov_offset.c
@@ -37,6 +37,15 @@
 
 #include "lov_internal.h"
 
+static u64 stripe_width(struct lov_stripe_md *lsm, unsigned int index)
+{
+	struct lov_stripe_md_entry *entry = lsm->lsm_entries[index];
+
+	LASSERT(index < lsm->lsm_entry_count);
+
+	return entry->lsme_stripe_size * entry->lsme_stripe_count;
+}
+
 /* compute object size given "stripeno" and the ost size */
 u64 lov_stripe_size(struct lov_stripe_md *lsm, int index, u64 ost_size,
 		    int stripeno)
@@ -45,12 +54,11 @@ u64 lov_stripe_size(struct lov_stripe_md *lsm, int index, u64 ost_size,
 	unsigned long stripe_size;
 	u64 swidth;
 	u64 lov_size;
-	int magic = lsm->lsm_magic;
 
 	if (ost_size == 0)
 		return 0;
 
-	lsm_op_find(magic)->lsm_stripe_by_index(lsm, &stripeno, NULL, &swidth);
+	swidth = stripe_width(lsm, index);
 
 	/* lov_do_div64(a, b) returns a % b, and a = a / b */
 	stripe_size = lov_do_div64(ost_size, ssize);
@@ -129,7 +137,6 @@ int lov_stripe_offset(struct lov_stripe_md *lsm, int index, u64 lov_off,
 {
 	unsigned long ssize  = lsm->lsm_entries[index]->lsme_stripe_size;
 	u64 stripe_off, this_stripe, swidth;
-	int magic = lsm->lsm_magic;
 	int ret = 0;
 
 	if (lov_off == OBD_OBJECT_EOF) {
@@ -137,8 +144,7 @@ int lov_stripe_offset(struct lov_stripe_md *lsm, int index, u64 lov_off,
 		return 0;
 	}
 
-	lsm_op_find(magic)->lsm_stripe_by_index(lsm, &stripeno, &lov_off,
-						&swidth);
+	swidth = stripe_width(lsm, index);
 
 	/* lov_do_div64(a, b) returns a % b, and a = a / b */
 	stripe_off = lov_do_div64(lov_off, swidth);
@@ -184,13 +190,11 @@ u64 lov_size_to_stripe(struct lov_stripe_md *lsm, int index, u64 file_size,
 {
 	unsigned long ssize  = lsm->lsm_entries[index]->lsme_stripe_size;
 	u64 stripe_off, this_stripe, swidth;
-	int magic = lsm->lsm_magic;
 
 	if (file_size == OBD_OBJECT_EOF)
 		return OBD_OBJECT_EOF;
 
-	lsm_op_find(magic)->lsm_stripe_by_index(lsm, &stripeno, &file_size,
-						&swidth);
+	swidth = stripe_width(lsm, index);
 
 	/* lov_do_div64(a, b) returns a % b, and a = a / b */
 	stripe_off = lov_do_div64(file_size, swidth);
@@ -258,9 +262,8 @@ int lov_stripe_number(struct lov_stripe_md *lsm, int index, u64 lov_off)
 {
 	unsigned long ssize  = lsm->lsm_entries[index]->lsme_stripe_size;
 	u64 stripe_off, swidth;
-	int magic = lsm->lsm_magic;
 
-	lsm_op_find(magic)->lsm_stripe_by_offset(lsm, NULL, &lov_off, &swidth);
+	swidth = stripe_width(lsm, index);
 
 	stripe_off = lov_do_div64(lov_off, swidth);
 
-- 
1.8.3.1
