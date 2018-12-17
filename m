From: James Simmons <jsimmons@infradead.org>
Date: Mon, 17 Dec 2018 11:29:57 -0500
Subject: [lustre-devel] [PATCH 23/28] lustre: pfl: fix ost pool op->size
 handling
In-Reply-To: <1545064202-22483-1-git-send-email-jsimmons@infradead.org>
References: <1545064202-22483-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1545064202-22483-24-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Bobi Jam <bobijam@hotmail.com>

This patch fixes the misunderstanding of ost_pool::op->size, it
indicates the buffer size allocated instead of the array count.

Signed-off-by: Bobi Jam <bobijam@hotmail.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-9359
Reviewed-on: https://review.whamcloud.com/26706
Reviewed-by: Niu Yawei <yawei.niu@intel.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/lov/lov_internal.h |  1 -
 drivers/staging/lustre/lustre/lov/lov_io.c       |  3 ++-
 drivers/staging/lustre/lustre/lov/lov_pool.c     | 20 +++++++++++---------
 3 files changed, 13 insertions(+), 11 deletions(-)

diff --git a/drivers/staging/lustre/lustre/lov/lov_internal.h b/drivers/staging/lustre/lustre/lov/lov_internal.h
index dd4dd24..3878cad 100644
--- a/drivers/staging/lustre/lustre/lov/lov_internal.h
+++ b/drivers/staging/lustre/lustre/lov/lov_internal.h
@@ -195,7 +195,6 @@ struct lsm_operations {
 })
 #endif
 
-#define pool_tgt_size(p)	((p)->pool_obds.op_size)
 #define pool_tgt_count(p)	((p)->pool_obds.op_count)
 #define pool_tgt_array(p)	((p)->pool_obds.op_array)
 #define pool_tgt_rw_sem(p)	((p)->pool_obds.op_rw_sem)
diff --git a/drivers/staging/lustre/lustre/lov/lov_io.c b/drivers/staging/lustre/lustre/lov/lov_io.c
index 0d809b1..ec0d14f 100644
--- a/drivers/staging/lustre/lustre/lov/lov_io.c
+++ b/drivers/staging/lustre/lustre/lov/lov_io.c
@@ -100,7 +100,8 @@ static int lov_io_sub_init(const struct lu_env *env, struct lov_io *lio,
 
 	LASSERT(!sub->sub_env);
 
-	if (unlikely(!lov_r0(lov, index)->lo_sub[stripe]))
+	if (unlikely(!lov_r0(lov, index)->lo_sub ||
+		     !lov_r0(lov, index)->lo_sub[stripe]))
 		return -EIO;
 
 	/* obtain new environment */
diff --git a/drivers/staging/lustre/lustre/lov/lov_pool.c b/drivers/staging/lustre/lustre/lov/lov_pool.c
index c79c2ae..b90fb1c 100644
--- a/drivers/staging/lustre/lustre/lov/lov_pool.c
+++ b/drivers/staging/lustre/lustre/lov/lov_pool.c
@@ -238,8 +238,9 @@ int lov_ost_pool_init(struct ost_pool *op, unsigned int count)
 	op->op_array = NULL;
 	op->op_count = 0;
 	init_rwsem(&op->op_rw_sem);
-	op->op_size = count;
-	op->op_array = kcalloc(op->op_size, sizeof(op->op_array[0]), GFP_NOFS);
+	op->op_size = count * sizeof(op->op_array[0]);
+	op->op_array = kcalloc(count, sizeof(op->op_array[0]),
+			       GFP_KERNEL);
 	if (!op->op_array) {
 		op->op_size = 0;
 		return -ENOMEM;
@@ -250,24 +251,25 @@ int lov_ost_pool_init(struct ost_pool *op, unsigned int count)
 /* Caller must hold write op_rwlock */
 int lov_ost_pool_extend(struct ost_pool *op, unsigned int min_count)
 {
-	__u32 *new;
-	int new_size;
+	int new_count;
+	u32 *new;
 
 	LASSERT(min_count != 0);
 
-	if (op->op_count < op->op_size)
+	if (op->op_count * sizeof(op->op_array[0]) < op->op_size)
 		return 0;
 
-	new_size = max(min_count, 2 * op->op_size);
-	new = kcalloc(new_size, sizeof(op->op_array[0]), GFP_NOFS);
+	new_count = max_t(u32, min_count,
+			  2 * op->op_size / sizeof(op->op_array[0]));
+	new = kcalloc(new_count, sizeof(op->op_array[0]), GFP_KERNEL);
 	if (!new)
 		return -ENOMEM;
 
 	/* copy old array to new one */
-	memcpy(new, op->op_array, op->op_size * sizeof(op->op_array[0]));
+	memcpy(new, op->op_array, op->op_size);
 	kfree(op->op_array);
 	op->op_array = new;
-	op->op_size = new_size;
+	op->op_size = new_count * sizeof(op->op_array[0]);
 	return 0;
 }
 
-- 
1.8.3.1
