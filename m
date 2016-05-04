From: James Simmons <jsimmons@infradead.org>
Date: Wed,  4 May 2016 10:28:54 -0400
Subject: [lustre-devel] [PATCH 3/9] staging: lustre: lov: remove lov and lod
	stuff from obd.h
In-Reply-To: <1462372140-27880-1-git-send-email-jsimmons@infradead.org>
References: <1462372140-27880-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1462372140-27880-4-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, "John L. Hammond" <john.hammond@intel.com>, James Simmons <jsimmons@infradead.org>

From: "John L. Hammond" <john.hammond@intel.com>

Remove QOS related data structures from obd.h to the
lov_internal.h. Remove the declarations of several
functions that no longer exist.

Signed-off-by: John L. Hammond <john.hammond@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-2675
Reviewed-on: http://review.whamcloud.com/8687
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Jinshan Xiong <jinshan.xiong@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/obd.h      | 60 ------------------------
 drivers/staging/lustre/lustre/lov/lov_internal.h | 21 +++++++--
 drivers/staging/lustre/lustre/lov/lov_obd.c      |  2 -
 drivers/staging/lustre/lustre/lov/lov_pool.c     | 15 +-----
 4 files changed, 18 insertions(+), 80 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/obd.h b/drivers/staging/lustre/lustre/include/obd.h
index d0c0c26..2d926e0 100644
--- a/drivers/staging/lustre/lustre/include/obd.h
+++ b/drivers/staging/lustre/lustre/include/obd.h
@@ -166,9 +166,6 @@ struct obd_info {
 	obd_enqueue_update_f    oi_cb_up;
 };
 
-void lov_stripe_lock(struct lov_stripe_md *md);
-void lov_stripe_unlock(struct lov_stripe_md *md);
-
 struct obd_type {
 	struct list_head typ_chain;
 	struct obd_ops *typ_dt_ops;
@@ -390,45 +387,9 @@ struct ost_pool {
 	struct rw_semaphore op_rw_sem;     /* to protect ost_pool use */
 };
 
-/* Round-robin allocator data */
-struct lov_qos_rr {
-	__u32	       lqr_start_idx;   /* start index of new inode */
-	__u32	       lqr_offset_idx;  /* aliasing for start_idx  */
-	int		 lqr_start_count; /* reseed counter */
-	struct ost_pool     lqr_pool;	/* round-robin optimized list */
-	unsigned long       lqr_dirty:1;     /* recalc round-robin list */
-};
-
 /* allow statfs data caching for 1 second */
 #define OBD_STATFS_CACHE_SECONDS 1
 
-struct lov_statfs_data {
-	struct obd_info   lsd_oi;
-	struct obd_statfs lsd_statfs;
-};
-
-/* Stripe placement optimization */
-struct lov_qos {
-	struct list_head    lq_oss_list; /* list of OSSs that targets use */
-	struct rw_semaphore lq_rw_sem;
-	__u32		lq_active_oss_count;
-	unsigned int	lq_prio_free;   /* priority for free space */
-	unsigned int	lq_threshold_rr;/* priority for rr */
-	struct lov_qos_rr   lq_rr;	  /* round robin qos data */
-	unsigned long       lq_dirty:1,     /* recalc qos data */
-			    lq_same_space:1,/* the ost's all have approx.
-					     * the same space avail
-					     */
-			    lq_reset:1,     /* zero current penalties */
-			    lq_statfs_in_progress:1; /* statfs op in
-							progress */
-	/* qos statfs data */
-	struct lov_statfs_data *lq_statfs_data;
-	wait_queue_head_t lq_statfs_waitq; /* waitqueue to notify statfs
-					    * requests completion
-					    */
-};
-
 struct lov_tgt_desc {
 	struct list_head	  ltd_kill;
 	struct obd_uuid     ltd_uuid;
@@ -441,25 +402,6 @@ struct lov_tgt_desc {
 			    ltd_reap:1;  /* should this target be deleted */
 };
 
-/* Pool metadata */
-#define pool_tgt_size(_p)   _p->pool_obds.op_size
-#define pool_tgt_count(_p)  _p->pool_obds.op_count
-#define pool_tgt_array(_p)  _p->pool_obds.op_array
-#define pool_tgt_rw_sem(_p) _p->pool_obds.op_rw_sem
-
-struct pool_desc {
-	char		  pool_name[LOV_MAXPOOLNAME + 1]; /* name of pool */
-	struct ost_pool       pool_obds;	      /* pool members */
-	atomic_t	  pool_refcount;	  /* pool ref. counter */
-	struct lov_qos_rr     pool_rr;		/* round robin qos */
-	struct hlist_node      pool_hash;	      /* access by poolname */
-	struct list_head	    pool_list;	      /* serial access */
-	struct dentry		*pool_debugfs_entry;	/* file in debugfs */
-	struct obd_device    *pool_lobd;	/* obd of the lov/lod to which
-						 * this pool belongs
-						 */
-};
-
 struct lov_obd {
 	struct lov_desc	 desc;
 	struct lov_tgt_desc   **lov_tgts;	      /* sparse array */
@@ -467,8 +409,6 @@ struct lov_obd {
 	struct mutex		lov_lock;
 	struct obd_connect_data lov_ocd;
 	atomic_t	    lov_refcount;
-	__u32		   lov_tgt_count;	 /* how many OBD's */
-	__u32		   lov_active_tgt_count;  /* how many active */
 	__u32		   lov_death_row;/* tgts scheduled to be deleted */
 	__u32		   lov_tgt_size;   /* size of tgts array */
 	int		     lov_connects;
diff --git a/drivers/staging/lustre/lustre/lov/lov_internal.h b/drivers/staging/lustre/lustre/lov/lov_internal.h
index 9985855..ff01fe9 100644
--- a/drivers/staging/lustre/lustre/lov/lov_internal.h
+++ b/drivers/staging/lustre/lustre/lov/lov_internal.h
@@ -72,6 +72,21 @@
 })
 #endif
 
+#define pool_tgt_size(p)	((p)->pool_obds.op_size)
+#define pool_tgt_count(p)	((p)->pool_obds.op_count)
+#define pool_tgt_array(p)	((p)->pool_obds.op_array)
+#define pool_tgt_rw_sem(p)	((p)->pool_obds.op_rw_sem)
+
+struct pool_desc {
+	char			 pool_name[LOV_MAXPOOLNAME + 1];
+	struct ost_pool		 pool_obds;
+	atomic_t		 pool_refcount;
+	struct hlist_node	 pool_hash;		/* access by poolname */
+	struct list_head	 pool_list;		/* serial access */
+	struct dentry		*pool_debugfs_entry;	/* file in debugfs */
+	struct obd_device	*pool_lobd;		/* owner */
+};
+
 struct lov_request {
 	struct obd_info	  rq_oi;
 	struct lov_request_set  *rq_rqset;
@@ -149,10 +164,6 @@ int lov_stripe_number(struct lov_stripe_md *lsm, u64 lov_off);
 pgoff_t lov_stripe_pgoff(struct lov_stripe_md *lsm, pgoff_t stripe_index,
 			 int stripe);
 
-/* lov_qos.c */
-#define LOV_USES_ASSIGNED_STRIPE	0
-#define LOV_USES_DEFAULT_STRIPE	 1
-
 /* lov_request.c */
 int lov_update_common_set(struct lov_request_set *set,
 			  struct lov_request *req, int rc);
@@ -178,6 +189,8 @@ int lov_fini_statfs_set(struct lov_request_set *set);
 int lov_statfs_interpret(struct ptlrpc_request_set *rqset, void *data, int rc);
 
 /* lov_obd.c */
+void lov_stripe_lock(struct lov_stripe_md *md);
+void lov_stripe_unlock(struct lov_stripe_md *md);
 void lov_fix_desc(struct lov_desc *desc);
 void lov_fix_desc_stripe_size(__u64 *val);
 void lov_fix_desc_stripe_count(__u32 *val);
diff --git a/drivers/staging/lustre/lustre/lov/lov_obd.c b/drivers/staging/lustre/lustre/lov/lov_obd.c
index 2de9255..bc9135a 100644
--- a/drivers/staging/lustre/lustre/lov/lov_obd.c
+++ b/drivers/staging/lustre/lustre/lov/lov_obd.c
@@ -2192,7 +2192,6 @@ void lov_stripe_lock(struct lov_stripe_md *md)
 	LASSERT(md->lsm_lock_owner == 0);
 	md->lsm_lock_owner = current_pid();
 }
-EXPORT_SYMBOL(lov_stripe_lock);
 
 void lov_stripe_unlock(struct lov_stripe_md *md)
 		__releases(&md->lsm_lock)
@@ -2201,7 +2200,6 @@ void lov_stripe_unlock(struct lov_stripe_md *md)
 	md->lsm_lock_owner = 0;
 	spin_unlock(&md->lsm_lock);
 }
-EXPORT_SYMBOL(lov_stripe_unlock);
 
 static int lov_quotactl(struct obd_device *obd, struct obd_export *exp,
 			struct obd_quotactl *oqctl)
diff --git a/drivers/staging/lustre/lustre/lov/lov_pool.c b/drivers/staging/lustre/lustre/lov/lov_pool.c
index 9ae1d6f..4254243 100644
--- a/drivers/staging/lustre/lustre/lov/lov_pool.c
+++ b/drivers/staging/lustre/lustre/lov/lov_pool.c
@@ -65,7 +65,6 @@ void lov_pool_putref(struct pool_desc *pool)
 		LASSERT(hlist_unhashed(&pool->pool_hash));
 		LASSERT(list_empty(&pool->pool_list));
 		LASSERT(!pool->pool_debugfs_entry);
-		lov_ost_pool_free(&(pool->pool_rr.lqr_pool));
 		lov_ost_pool_free(&(pool->pool_obds));
 		kfree(pool);
 	}
@@ -424,11 +423,6 @@ int lov_pool_new(struct obd_device *obd, char *poolname)
 	if (rc)
 		goto out_err;
 
-	memset(&(new_pool->pool_rr), 0, sizeof(struct lov_qos_rr));
-	rc = lov_ost_pool_init(&new_pool->pool_rr.lqr_pool, 0);
-	if (rc)
-		goto out_free_pool_obds;
-
 	INIT_HLIST_NODE(&new_pool->pool_hash);
 
 	/* get ref for debugfs file */
@@ -469,13 +463,10 @@ out_err:
 	list_del_init(&new_pool->pool_list);
 	lov->lov_pool_count--;
 	spin_unlock(&obd->obd_dev_lock);
-
 	ldebugfs_remove(&new_pool->pool_debugfs_entry);
-
-	lov_ost_pool_free(&new_pool->pool_rr.lqr_pool);
-out_free_pool_obds:
 	lov_ost_pool_free(&new_pool->pool_obds);
 	kfree(new_pool);
+
 	return rc;
 }
 
@@ -543,8 +534,6 @@ int lov_pool_add(struct obd_device *obd, char *poolname, char *ostname)
 	if (rc)
 		goto out;
 
-	pool->pool_rr.lqr_dirty = 1;
-
 	CDEBUG(D_CONFIG, "Added %s to "LOV_POOLNAMEF" as member %d\n",
 	       ostname, poolname,  pool_tgt_count(pool));
 
@@ -589,8 +578,6 @@ int lov_pool_remove(struct obd_device *obd, char *poolname, char *ostname)
 
 	lov_ost_pool_remove(&pool->pool_obds, lov_idx);
 
-	pool->pool_rr.lqr_dirty = 1;
-
 	CDEBUG(D_CONFIG, "%s removed from "LOV_POOLNAMEF"\n", ostname,
 	       poolname);
 
-- 
2.7.4
