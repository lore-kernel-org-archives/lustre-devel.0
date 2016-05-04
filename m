From: James Simmons <jsimmons@infradead.org>
Date: Wed,  4 May 2016 10:29:00 -0400
Subject: [lustre-devel] [PATCH 9/9] staging: lustre: lov: remove unused lov
	obd functions
In-Reply-To: <1462372140-27880-1-git-send-email-jsimmons@infradead.org>
References: <1462372140-27880-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1462372140-27880-10-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, "John L. Hammond" <john.hammond@intel.com>, James Simmons <jsimmons@infradead.org>

From: "John L. Hammond" <john.hammond@intel.com>

Remove the unused lov functions lov_get_reqset,
lov_check_index_in_pool, and lov_find_pool functions.
Remove unused data structures.

Signed-off-by: John L. Hammond <john.hammond@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-2675
Reviewed-on: http://review.whamcloud.com/5581
Reviewed-by: Alex Zhuravlev <alexey.zhuravlev@intel.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: James Simmons <uja.ornl@gmail.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/lov/lov_ea.c       |  5 ---
 drivers/staging/lustre/lustre/lov/lov_internal.h | 11 ------
 drivers/staging/lustre/lustre/lov/lov_obd.c      |  1 -
 drivers/staging/lustre/lustre/lov/lov_pool.c     | 47 ------------------------
 drivers/staging/lustre/lustre/lov/lov_request.c  |  3 --
 5 files changed, 67 deletions(-)

diff --git a/drivers/staging/lustre/lustre/lov/lov_ea.c b/drivers/staging/lustre/lustre/lov/lov_ea.c
index b652940..460f0fa 100644
--- a/drivers/staging/lustre/lustre/lov/lov_ea.c
+++ b/drivers/staging/lustre/lustre/lov/lov_ea.c
@@ -48,11 +48,6 @@
 
 #include "lov_internal.h"
 
-struct lovea_unpack_args {
-	struct lov_stripe_md *lsm;
-	int		   cursor;
-};
-
 static int lsm_lmm_verify_common(struct lov_mds_md *lmm, int lmm_bytes,
 				 __u16 stripe_count)
 {
diff --git a/drivers/staging/lustre/lustre/lov/lov_internal.h b/drivers/staging/lustre/lustre/lov/lov_internal.h
index ff01fe9..eef9afa 100644
--- a/drivers/staging/lustre/lustre/lov/lov_internal.h
+++ b/drivers/staging/lustre/lustre/lov/lov_internal.h
@@ -103,7 +103,6 @@ struct lov_request {
 };
 
 struct lov_request_set {
-	struct ldlm_enqueue_info	*set_ei;
 	struct obd_info			*set_oi;
 	atomic_t			set_refcount;
 	struct obd_export		*set_exp;
@@ -117,10 +116,8 @@ struct lov_request_set {
 	atomic_t			set_finish_checked;
 	struct llog_cookie		*set_cookies;
 	int				set_cookie_sent;
-	struct obd_trans_info		*set_oti;
 	struct list_head			set_list;
 	wait_queue_head_t			set_waitq;
-	spinlock_t			set_lock;
 };
 
 extern struct kmem_cache *lov_oinfo_slab;
@@ -129,12 +126,6 @@ extern struct lu_kmem_descr lov_caches[];
 
 void lov_finish_set(struct lov_request_set *set);
 
-static inline void lov_get_reqset(struct lov_request_set *set)
-{
-	LASSERT(atomic_read(&set->set_refcount) > 0);
-	atomic_inc(&set->set_refcount);
-}
-
 static inline void lov_put_reqset(struct lov_request_set *set)
 {
 	if (atomic_dec_and_test(&set->set_refcount))
@@ -246,8 +237,6 @@ int lov_pool_new(struct obd_device *obd, char *poolname);
 int lov_pool_del(struct obd_device *obd, char *poolname);
 int lov_pool_add(struct obd_device *obd, char *poolname, char *ostname);
 int lov_pool_remove(struct obd_device *obd, char *poolname, char *ostname);
-struct pool_desc *lov_find_pool(struct lov_obd *lov, char *poolname);
-int lov_check_index_in_pool(__u32 idx, struct pool_desc *pool);
 void lov_pool_putref(struct pool_desc *pool);
 
 static inline struct lov_stripe_md *lsm_addref(struct lov_stripe_md *lsm)
diff --git a/drivers/staging/lustre/lustre/lov/lov_obd.c b/drivers/staging/lustre/lustre/lov/lov_obd.c
index bc9135a..e15ef2e 100644
--- a/drivers/staging/lustre/lustre/lov/lov_obd.c
+++ b/drivers/staging/lustre/lustre/lov/lov_obd.c
@@ -123,7 +123,6 @@ static int lov_set_osc_active(struct obd_device *obd, struct obd_uuid *uuid,
 static int lov_notify(struct obd_device *obd, struct obd_device *watched,
 		      enum obd_notify_event ev, void *data);
 
-#define MAX_STRING_SIZE 128
 int lov_connect_obd(struct obd_device *obd, __u32 index, int activate,
 		    struct obd_connect_data *data)
 {
diff --git a/drivers/staging/lustre/lustre/lov/lov_pool.c b/drivers/staging/lustre/lustre/lov/lov_pool.c
index 4254243..690292e 100644
--- a/drivers/staging/lustre/lustre/lov/lov_pool.c
+++ b/drivers/staging/lustre/lustre/lov/lov_pool.c
@@ -586,50 +586,3 @@ out:
 	lov_pool_putref(pool);
 	return rc;
 }
-
-int lov_check_index_in_pool(__u32 idx, struct pool_desc *pool)
-{
-	int i, rc;
-
-	/* caller may no have a ref on pool if it got the pool
-	 * without calling lov_find_pool() (e.g. go through the lov pool
-	 * list)
-	 */
-	lov_pool_getref(pool);
-
-	down_read(&pool_tgt_rw_sem(pool));
-
-	for (i = 0; i < pool_tgt_count(pool); i++) {
-		if (pool_tgt_array(pool)[i] == idx) {
-			rc = 0;
-			goto out;
-		}
-	}
-	rc = -ENOENT;
-out:
-	up_read(&pool_tgt_rw_sem(pool));
-
-	lov_pool_putref(pool);
-	return rc;
-}
-
-struct pool_desc *lov_find_pool(struct lov_obd *lov, char *poolname)
-{
-	struct pool_desc *pool;
-
-	pool = NULL;
-	if (poolname[0] != '\0') {
-		pool = cfs_hash_lookup(lov->lov_pools_hash_body, poolname);
-		if (!pool)
-			CWARN("Request for an unknown pool ("LOV_POOLNAMEF")\n",
-			      poolname);
-		if (pool && (pool_tgt_count(pool) == 0)) {
-			CWARN("Request for an empty pool ("LOV_POOLNAMEF")\n",
-			      poolname);
-			/* pool is ignored, so we remove ref on it */
-			lov_pool_putref(pool);
-			pool = NULL;
-		}
-	}
-	return pool;
-}
diff --git a/drivers/staging/lustre/lustre/lov/lov_request.c b/drivers/staging/lustre/lustre/lov/lov_request.c
index 4d7073e..1be4b92 100644
--- a/drivers/staging/lustre/lustre/lov/lov_request.c
+++ b/drivers/staging/lustre/lustre/lov/lov_request.c
@@ -52,7 +52,6 @@ static void lov_init_set(struct lov_request_set *set)
 	INIT_LIST_HEAD(&set->set_list);
 	atomic_set(&set->set_refcount, 1);
 	init_waitqueue_head(&set->set_waitq);
-	spin_lock_init(&set->set_lock);
 }
 
 void lov_finish_set(struct lov_request_set *set)
@@ -362,7 +361,6 @@ int lov_prep_destroy_set(struct obd_export *exp, struct obd_info *oinfo,
 	set->set_oi = oinfo;
 	set->set_oi->oi_md = lsm;
 	set->set_oi->oi_oa = src_oa;
-	set->set_oti = oti;
 	if (oti && src_oa->o_valid & OBD_MD_FLCOOKIE)
 		set->set_cookies = oti->oti_logcookies;
 
@@ -479,7 +477,6 @@ int lov_prep_setattr_set(struct obd_export *exp, struct obd_info *oinfo,
 	lov_init_set(set);
 
 	set->set_exp = exp;
-	set->set_oti = oti;
 	set->set_oi = oinfo;
 	if (oti && oinfo->oi_oa->o_valid & OBD_MD_FLCOOKIE)
 		set->set_cookies = oti->oti_logcookies;
-- 
2.7.4
