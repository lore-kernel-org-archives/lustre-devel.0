From: James Simmons <jsimmons@infradead.org>
Date: Sun, 21 Jul 2019 21:52:15 -0400
Subject: [lustre-devel] [PATCH 08/11] lustre: lov: checkpatch cleanup
In-Reply-To: <1563760338-806-1-git-send-email-jsimmons@infradead.org>
References: <1563760338-806-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1563760338-806-9-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Many checkpatch errors exist in the lov layer. This address
a good chuck of them. Other are left since future patches will
cleanup those areas. Others will need more code rework so this
patch handles the simple cases. This is a good step forward
toward proper kernel code style compliance.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/lov/lov_io.c      |  2 +-
 fs/lustre/lov/lov_lock.c    |  4 ++--
 fs/lustre/lov/lov_merge.c   |  6 ++++--
 fs/lustre/lov/lov_obd.c     |  6 ++++--
 fs/lustre/lov/lov_object.c  |  6 +++---
 fs/lustre/lov/lov_pool.c    | 24 +++++++++++++++++-------
 fs/lustre/lov/lov_request.c |  3 ++-
 7 files changed, 33 insertions(+), 18 deletions(-)

diff --git a/fs/lustre/lov/lov_io.c b/fs/lustre/lov/lov_io.c
index 64982be..8214493 100644
--- a/fs/lustre/lov/lov_io.c
+++ b/fs/lustre/lov/lov_io.c
@@ -406,7 +406,7 @@ static int lov_io_iter_init(const struct lu_env *env,
 			 * it's handled in lov_io_setattr_iter_init()
 			 */
 			if (io->ci_type == CIT_WRITE || cl_io_is_mkwrite(io)) {
-			    io->ci_need_write_intent = 1;
+				io->ci_need_write_intent = 1;
 				rc = -ENODATA;
 				break;
 			}
diff --git a/fs/lustre/lov/lov_lock.c b/fs/lustre/lov/lov_lock.c
index 039c902..5520199 100644
--- a/fs/lustre/lov/lov_lock.c
+++ b/fs/lustre/lov/lov_lock.c
@@ -283,8 +283,8 @@ static void lov_lock_cancel(const struct lu_env *env,
 			cl_lock_cancel(subenv->lse_env, sublock);
 		} else {
 			CL_LOCK_DEBUG(D_ERROR, env, slice->cls_lock,
-				      "lov_lock_cancel fails with %ld.\n",
-				      PTR_ERR(subenv));
+				      "%s fails with %ld.\n",
+				      __func__, PTR_ERR(subenv));
 		}
 	}
 }
diff --git a/fs/lustre/lov/lov_merge.c b/fs/lustre/lov/lov_merge.c
index ab0ba12..a8c23fe 100644
--- a/fs/lustre/lov/lov_merge.c
+++ b/fs/lustre/lov/lov_merge.c
@@ -57,7 +57,8 @@ int lov_merge_lvb_kms(struct lov_stripe_md *lsm, int index,
 	assert_spin_locked(&lsm->lsm_lock);
 	LASSERT(lsm->lsm_lock_owner == current->pid);
 
-	CDEBUG(D_INODE, "MDT ID " DOSTID " initial value: s=%llu m=%llu a=%llu c=%llu b=%llu\n",
+	CDEBUG(D_INODE,
+	       "MDT ID " DOSTID " initial value: s=%llu m=%llu a=%llu c=%llu b=%llu\n",
 	       POSTID(&lsm->lsm_oi), lvb->lvb_size, lvb->lvb_mtime,
 	       lvb->lvb_atime, lvb->lvb_ctime, lvb->lvb_blocks);
 
@@ -90,7 +91,8 @@ int lov_merge_lvb_kms(struct lov_stripe_md *lsm, int index,
 		if (loi->loi_lvb.lvb_ctime > current_ctime)
 			current_ctime = loi->loi_lvb.lvb_ctime;
 
-		CDEBUG(D_INODE, "MDT ID " DOSTID " on OST[%u]: s=%llu m=%llu a=%llu c=%llu b=%llu\n",
+		CDEBUG(D_INODE,
+		       "MDT ID " DOSTID " on OST[%u]: s=%llu m=%llu a=%llu c=%llu b=%llu\n",
 		       POSTID(&lsm->lsm_oi), loi->loi_ost_idx,
 		       loi->loi_lvb.lvb_size, loi->loi_lvb.lvb_mtime,
 		       loi->loi_lvb.lvb_atime, loi->loi_lvb.lvb_ctime,
diff --git a/fs/lustre/lov/lov_obd.c b/fs/lustre/lov/lov_obd.c
index 652ed6a..1d96f28 100644
--- a/fs/lustre/lov/lov_obd.c
+++ b/fs/lustre/lov/lov_obd.c
@@ -104,7 +104,8 @@ void lov_tgts_putref(struct obd_device *obd)
 		mutex_unlock(&lov->lov_lock);
 
 		while (!list_empty(&kill)) {
-			tgt = list_first_entry(&kill, struct lov_tgt_desc, ltd_kill);
+			tgt = list_first_entry(&kill, struct lov_tgt_desc,
+					       ltd_kill);
 			list_del(&tgt->ltd_kill);
 			/* Disconnect */
 			__lov_del_obd(obd, tgt);
@@ -171,7 +172,8 @@ int lov_connect_obd(struct obd_device *obd, u32 index, int activate,
 	}
 
 	if (imp->imp_invalid) {
-		CDEBUG(D_CONFIG, "not connecting OSC %s; administratively disabled\n",
+		CDEBUG(D_CONFIG,
+		       "not connecting OSC %s; administratively disabled\n",
 		       obd_uuid2str(tgt_uuid));
 		return 0;
 	}
diff --git a/fs/lustre/lov/lov_object.c b/fs/lustre/lov/lov_object.c
index 261f7b7..caeff89 100644
--- a/fs/lustre/lov/lov_object.c
+++ b/fs/lustre/lov/lov_object.c
@@ -216,8 +216,8 @@ static int lov_init_raid0(const struct lu_env *env, struct lov_device *dev,
 	r0->lo_nr = lse->lsme_stripe_count;
 	LASSERT(r0->lo_nr <= lov_targets_nr(dev));
 
-	r0->lo_sub = kzalloc(r0->lo_nr * sizeof(r0->lo_sub[0]),
-			      GFP_NOFS);
+	r0->lo_sub = kcalloc(r0->lo_nr, sizeof(r0->lo_sub[0]),
+			     GFP_KERNEL);
 	if (!r0->lo_sub)
 		return -ENOMEM;
 
@@ -1568,7 +1568,7 @@ static int lov_object_fiemap(const struct lu_env *env, struct cl_object *obj,
 				goto finish;
 			if (fs.fs_finish_stripe)
 				break;
-		 } /* for each stripe */
+		} /* for each stripe */
 	} /* for covering layout component */
 
 	/*
diff --git a/fs/lustre/lov/lov_pool.c b/fs/lustre/lov/lov_pool.c
index 833fac9..78a7dd2 100644
--- a/fs/lustre/lov/lov_pool.c
+++ b/fs/lustre/lov/lov_pool.c
@@ -50,13 +50,16 @@
 static u32 pool_hashfh(const void *data, u32 len, u32 seed)
 {
 	const char *pool_name = data;
-	return hashlen_hash(hashlen_string((void*)(unsigned long)seed, pool_name));
+
+	return hashlen_hash(hashlen_string((void *)(unsigned long)seed,
+			    pool_name));
 }
 
 static int pool_cmpfn(struct rhashtable_compare_arg *arg, const void *obj)
 {
 	const struct pool_desc *pool = obj;
 	const char *pool_name = arg->key;
+
 	return strcmp(pool_name, pool->pool_name);
 }
 
@@ -338,6 +341,7 @@ int lov_ost_pool_free(struct ost_pool *op)
 pools_hash_exit(void *vpool, void *data)
 {
 	struct pool_desc *pool = vpool;
+
 	lov_pool_putref(pool);
 }
 
@@ -391,7 +395,8 @@ int lov_pool_new(struct obd_device *obd, char *poolname)
 
 	/* Add to hash table only when it is fully ready.  */
 	rc = rhashtable_lookup_insert_fast(&lov->lov_pools_hash_body,
-					   &new_pool->pool_hash, pools_hash_params);
+					   &new_pool->pool_hash,
+					   pools_hash_params);
 	if (rc) {
 		if (rc != -EEXIST)
 			/*
@@ -428,11 +433,14 @@ int lov_pool_del(struct obd_device *obd, char *poolname)
 
 	/* lookup and kill hash reference */
 	rcu_read_lock();
-	pool = rhashtable_lookup(&lov->lov_pools_hash_body, poolname, pools_hash_params);
-	if (pool)
+	pool = rhashtable_lookup(&lov->lov_pools_hash_body, poolname,
+				 pools_hash_params);
+	if (pool) {
 		if (rhashtable_remove_fast(&lov->lov_pools_hash_body,
-					   &pool->pool_hash, pools_hash_params) != 0)
+					   &pool->pool_hash,
+					   pools_hash_params) != 0)
 			pool = NULL;
+	}
 	rcu_read_unlock();
 	if (!pool)
 		return -ENOENT;
@@ -462,7 +470,8 @@ int lov_pool_add(struct obd_device *obd, char *poolname, char *ostname)
 	lov = &obd->u.lov;
 
 	rcu_read_lock();
-	pool = rhashtable_lookup(&lov->lov_pools_hash_body, poolname, pools_hash_params);
+	pool = rhashtable_lookup(&lov->lov_pools_hash_body, poolname,
+				 pools_hash_params);
 	if (pool && !atomic_inc_not_zero(&pool->pool_refcount))
 		pool = NULL;
 	rcu_read_unlock();
@@ -511,7 +520,8 @@ int lov_pool_remove(struct obd_device *obd, char *poolname, char *ostname)
 	lov = &obd->u.lov;
 
 	rcu_read_lock();
-	pool = rhashtable_lookup(&lov->lov_pools_hash_body, poolname, pools_hash_params);
+	pool = rhashtable_lookup(&lov->lov_pools_hash_body, poolname,
+				 pools_hash_params);
 	if (pool && !atomic_inc_not_zero(&pool->pool_refcount))
 		pool = NULL;
 	rcu_read_unlock();
diff --git a/fs/lustre/lov/lov_request.c b/fs/lustre/lov/lov_request.c
index 7f591ba..057d6ca 100644
--- a/fs/lustre/lov/lov_request.c
+++ b/fs/lustre/lov/lov_request.c
@@ -315,7 +315,8 @@ int lov_prep_statfs_set(struct obd_device *obd, struct obd_info *oinfo,
 		 * administrator
 		 */
 		if (!lov->lov_tgts[i]->ltd_exp) {
-			CDEBUG(D_HA, "lov idx %d administratively disabled\n", i);
+			CDEBUG(D_HA,
+			       "lov idx %d administratively disabled\n", i);
 			continue;
 		}
 
-- 
1.8.3.1
