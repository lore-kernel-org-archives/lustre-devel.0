From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Mon, 22 Feb 2016 21:54:27 -0500
Subject: [lustre-devel] [PATCH 49/56] staging/lustre/lov: Adjust comments to
	better conform to coding style
In-Reply-To: <1456196074-754064-1-git-send-email-green@linuxhacker.ru>
References: <1456196074-754064-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1456196074-754064-50-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

This patch fixes "Block comments use a trailing */ on a separate line"
warnings from checkpatch.

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/lov/lov_ea.c       |  3 +-
 drivers/staging/lustre/lustre/lov/lov_internal.h |  6 +-
 drivers/staging/lustre/lustre/lov/lov_lock.c     | 32 ++++++----
 drivers/staging/lustre/lustre/lov/lov_obd.c      | 78 ++++++++++++++++--------
 drivers/staging/lustre/lustre/lov/lov_object.c   | 24 +++++---
 drivers/staging/lustre/lustre/lov/lov_offset.c   | 12 ++--
 drivers/staging/lustre/lustre/lov/lov_pack.c     | 12 ++--
 drivers/staging/lustre/lustre/lov/lov_pool.c     | 12 ++--
 drivers/staging/lustre/lustre/lov/lov_request.c  | 18 ++++--
 drivers/staging/lustre/lustre/lov/lovsub_lock.c  |  6 +-
 10 files changed, 134 insertions(+), 69 deletions(-)

diff --git a/drivers/staging/lustre/lustre/lov/lov_ea.c b/drivers/staging/lustre/lustre/lov/lov_ea.c
index 6c8381a..c27b884 100644
--- a/drivers/staging/lustre/lustre/lov/lov_ea.c
+++ b/drivers/staging/lustre/lustre/lov/lov_ea.c
@@ -162,7 +162,8 @@ static int lsm_destroy_plain(struct lov_stripe_md *lsm, struct obdo *oa,
 }
 
 /* Find minimum stripe maxbytes value.  For inactive or
- * reconnecting targets use LUSTRE_STRIPE_MAXBYTES. */
+ * reconnecting targets use LUSTRE_STRIPE_MAXBYTES.
+ */
 static void lov_tgt_maxbytes(struct lov_tgt_desc *tgt, __u64 *stripe_maxbytes)
 {
 	struct obd_import *imp = tgt->ltd_obd->u.cli.cl_import;
diff --git a/drivers/staging/lustre/lustre/lov/lov_internal.h b/drivers/staging/lustre/lustre/lov/lov_internal.h
index d4522ba..725ebf9 100644
--- a/drivers/staging/lustre/lustre/lov/lov_internal.h
+++ b/drivers/staging/lustre/lustre/lov/lov_internal.h
@@ -43,7 +43,8 @@
 /* lov_do_div64(a, b) returns a % b, and a = a / b.
  * The 32-bit code is LOV-specific due to knowing about stripe limits in
  * order to reduce the divisor to a 32-bit number.  If the divisor is
- * already a 32-bit value the compiler handles this directly. */
+ * already a 32-bit value the compiler handles this directly.
+ */
 #if BITS_PER_LONG == 64
 # define lov_do_div64(n, base) ({					\
 	uint64_t __base = (base);					\
@@ -92,7 +93,8 @@ struct lov_request_set {
 	atomic_t			set_refcount;
 	struct obd_export		*set_exp;
 	/* XXX: There is @set_exp already, however obd_statfs gets obd_device
-	   only. */
+	 * only.
+	 */
 	struct obd_device		*set_obd;
 	int				set_count;
 	atomic_t			set_completes;
diff --git a/drivers/staging/lustre/lustre/lov/lov_lock.c b/drivers/staging/lustre/lustre/lov/lov_lock.c
index e6b0437..e0a6438 100644
--- a/drivers/staging/lustre/lustre/lov/lov_lock.c
+++ b/drivers/staging/lustre/lustre/lov/lov_lock.c
@@ -160,7 +160,8 @@ static struct cl_lock *lov_sublock_alloc(const struct lu_env *env,
 			 * to remember the subio. This is because lock is able
 			 * to be cached, but this is not true for IO. This
 			 * further means a sublock might be referenced in
-			 * different io context. -jay */
+			 * different io context. -jay
+			 */
 
 			sublock = cl_lock_hold(subenv->lse_env, subenv->lse_io,
 					       descr, "lov-parent", parent);
@@ -477,7 +478,8 @@ static int lov_lock_enqueue_one(const struct lu_env *env, struct lov_lock *lck,
 	result = cl_enqueue_try(env, sublock, io, enqflags);
 	if ((sublock->cll_state == CLS_ENQUEUED) && !(enqflags & CEF_AGL)) {
 		/* if it is enqueued, try to `wait' on it---maybe it's already
-		 * granted */
+		 * granted
+		 */
 		result = cl_wait_try(env, sublock);
 		if (result == CLO_REENQUEUED)
 			result = CLO_WAIT;
@@ -518,7 +520,8 @@ static int lov_sublock_fill(const struct lu_env *env, struct cl_lock *parent,
 		} else {
 			kmem_cache_free(lov_lock_link_kmem, link);
 			/* other thread allocated sub-lock, or enqueue is no
-			 * longer going on */
+			 * longer going on
+			 */
 			cl_lock_mutex_put(env, parent);
 			cl_lock_unhold(env, sublock, "lov-parent", parent);
 			cl_lock_mutex_get(env, parent);
@@ -575,7 +578,8 @@ static int lov_lock_enqueue(const struct lu_env *env,
 		if (!sub) {
 			result = lov_sublock_fill(env, lock, io, lck, i);
 			/* lov_sublock_fill() released @lock mutex,
-			 * restart. */
+			 * restart.
+			 */
 			break;
 		}
 		sublock = sub->lss_cl.cls_lock;
@@ -603,7 +607,8 @@ static int lov_lock_enqueue(const struct lu_env *env,
 					/* take recursive mutex of sublock */
 					cl_lock_mutex_get(env, sublock);
 					/* need to release all locks in closure
-					 * otherwise it may deadlock. LU-2683.*/
+					 * otherwise it may deadlock. LU-2683.
+					 */
 					lov_sublock_unlock(env, sub, closure,
 							   subenv);
 					/* sublock and parent are held. */
@@ -647,7 +652,8 @@ static int lov_lock_unuse(const struct lu_env *env,
 
 		/* top-lock state cannot change concurrently, because single
 		 * thread (one that released the last hold) carries unlocking
-		 * to the completion. */
+		 * to the completion.
+		 */
 		LASSERT(slice->cls_lock->cll_state == CLS_INTRANSIT);
 		lls = &lck->lls_sub[i];
 		sub = lls->sub_lock;
@@ -693,7 +699,8 @@ static void lov_lock_cancel(const struct lu_env *env,
 
 		/* top-lock state cannot change concurrently, because single
 		 * thread (one that released the last hold) carries unlocking
-		 * to the completion. */
+		 * to the completion.
+		 */
 		lls = &lck->lls_sub[i];
 		sub = lls->sub_lock;
 		if (!sub)
@@ -773,8 +780,9 @@ again:
 		if (result != 0)
 			break;
 	}
-	/* Each sublock only can be reenqueued once, so will not loop for
-	 * ever. */
+	/* Each sublock only can be reenqueued once, so will not loop
+	 * forever.
+	 */
 	if (result == 0 && reenqueued != 0)
 		goto again;
 	cl_lock_closure_fini(closure);
@@ -823,7 +831,8 @@ static int lov_lock_use(const struct lu_env *env,
 								 i, 1, rc);
 			} else if (sublock->cll_state == CLS_NEW) {
 				/* Sub-lock might have been canceled, while
-				 * top-lock was cached. */
+				 * top-lock was cached.
+				 */
 				result = -ESTALE;
 				lov_sublock_release(env, lck, i, 1, result);
 			}
@@ -928,7 +937,8 @@ static int lov_lock_fits_into(const struct lu_env *env,
 	LASSERT(lov->lls_nr > 0);
 
 	/* for top lock, it's necessary to match enq flags otherwise it will
-	 * run into problem if a sublock is missing and reenqueue. */
+	 * run into problem if a sublock is missing and reenqueue.
+	 */
 	if (need->cld_enq_flags != lov->lls_orig.cld_enq_flags)
 		return 0;
 
diff --git a/drivers/staging/lustre/lustre/lov/lov_obd.c b/drivers/staging/lustre/lustre/lov/lov_obd.c
index dcaa5a1..b1ac13a 100644
--- a/drivers/staging/lustre/lustre/lov/lov_obd.c
+++ b/drivers/staging/lustre/lustre/lov/lov_obd.c
@@ -61,7 +61,8 @@
 #include "lov_internal.h"
 
 /* Keep a refcount of lov->tgt usage to prevent racing with addition/deletion.
-   Any function that expects lov_tgts to remain stationary must take a ref. */
+ * Any function that expects lov_tgts to remain stationary must take a ref.
+ */
 static void lov_getref(struct obd_device *obd)
 {
 	struct lov_obd *lov = &obd->u.lov;
@@ -96,7 +97,8 @@ static void lov_putref(struct obd_device *obd)
 			list_add(&tgt->ltd_kill, &kill);
 			/* XXX - right now there is a dependency on ld_tgt_count
 			 * being the maximum tgt index for computing the
-			 * mds_max_easize. So we can't shrink it. */
+			 * mds_max_easize. So we can't shrink it.
+			 */
 			lov_ost_pool_remove(&lov->lov_packed, i);
 			lov->lov_tgts[i] = NULL;
 			lov->lov_death_row--;
@@ -158,7 +160,8 @@ int lov_connect_obd(struct obd_device *obd, __u32 index, int activate,
 	if (activate) {
 		tgt_obd->obd_no_recov = 0;
 		/* FIXME this is probably supposed to be
-		   ptlrpc_set_import_active.  Horrible naming. */
+		 * ptlrpc_set_import_active.  Horrible naming.
+		 */
 		ptlrpc_activate_import(imp);
 	}
 
@@ -315,7 +318,8 @@ static int lov_disconnect(struct obd_export *exp)
 	}
 
 	/* Let's hold another reference so lov_del_obd doesn't spin through
-	   putref every time */
+	 * putref every time
+	 */
 	obd_getref(obd);
 
 	for (i = 0; i < lov->desc.ld_tgt_count; i++) {
@@ -480,7 +484,8 @@ static int lov_notify(struct obd_device *obd, struct obd_device *watched,
 				continue;
 
 			/* don't send sync event if target not
-			 * connected/activated */
+			 * connected/activated
+			 */
 			if (is_sync &&  !lov->lov_tgts[i]->ltd_active)
 				continue;
 
@@ -595,8 +600,9 @@ static int lov_add_target(struct obd_device *obd, struct obd_uuid *uuidp,
 
 	if (lov->lov_connects == 0) {
 		/* lov_connect hasn't been called yet. We'll do the
-		   lov_connect_obd on this target when that fn first runs,
-		   because we don't know the connect flags yet. */
+		 * lov_connect_obd on this target when that fn first runs,
+		 * because we don't know the connect flags yet.
+		 */
 		return 0;
 	}
 
@@ -701,8 +707,9 @@ static void __lov_del_obd(struct obd_device *obd, struct lov_tgt_desc *tgt)
 	kfree(tgt);
 
 	/* Manual cleanup - no cleanup logs to clean up the osc's.  We must
-	   do it ourselves. And we can't do it from lov_cleanup,
-	   because we just lost our only reference to it. */
+	 * do it ourselves. And we can't do it from lov_cleanup,
+	 * because we just lost our only reference to it.
+	 */
 	if (osc_obd)
 		class_manual_cleanup(osc_obd);
 }
@@ -858,7 +865,8 @@ static int lov_cleanup(struct obd_device *obd)
 		/* free pool structs */
 		CDEBUG(D_INFO, "delete pool %p\n", pool);
 		/* In the function below, .hs_keycmp resolves to
-		 * pool_hashkey_keycmp() */
+		 * pool_hashkey_keycmp()
+		 */
 		/* coverity[overrun-buffer-val] */
 		lov_pool_del(obd, pool->pool_name);
 	}
@@ -878,8 +886,9 @@ static int lov_cleanup(struct obd_device *obd)
 			if (lov->lov_tgts[i]->ltd_active ||
 			    atomic_read(&lov->lov_refcount))
 			    /* We should never get here - these
-			       should have been removed in the
-			     disconnect. */
+			     * should have been removed in the
+			     * disconnect.
+			     */
 				CERROR("lov tgt %d not cleaned! deathrow=%d, lovrc=%d\n",
 				       i, lov->lov_death_row,
 				       atomic_read(&lov->lov_refcount));
@@ -1197,7 +1206,8 @@ static int lov_setattr_interpret(struct ptlrpc_request_set *rqset,
 }
 
 /* If @oti is given, the request goes from MDS and responses from OSTs are not
-   needed. Otherwise, a client is waiting for responses. */
+ * needed. Otherwise, a client is waiting for responses.
+ */
 static int lov_setattr_async(struct obd_export *exp, struct obd_info *oinfo,
 			     struct obd_trans_info *oti,
 			     struct ptlrpc_request_set *rqset)
@@ -1270,7 +1280,8 @@ static int lov_setattr_async(struct obd_export *exp, struct obd_info *oinfo,
 /* find any ldlm lock of the inode in lov
  * return 0    not find
  *	1    find one
- *      < 0    error */
+ *      < 0    error
+ */
 static int lov_find_cbdata(struct obd_export *exp,
 			   struct lov_stripe_md *lsm, ldlm_iterator_t it,
 			   void *data)
@@ -1366,7 +1377,8 @@ static int lov_statfs(const struct lu_env *env, struct obd_export *exp,
 	int rc = 0;
 
 	/* for obdclass we forbid using obd_statfs_rqset, but prefer using async
-	 * statfs requests */
+	 * statfs requests
+	 */
 	set = ptlrpc_prep_set();
 	if (!set)
 		return -ENOMEM;
@@ -1542,7 +1554,8 @@ static int lov_iocontrol(unsigned int cmd, struct obd_export *exp, int len,
 				continue;
 
 			/* ll_umount_begin() sets force flag but for lov, not
-			 * osc. Let's pass it through */
+			 * osc. Let's pass it through
+			 */
 			osc_obd = class_exp2obd(lov->lov_tgts[i]->ltd_exp);
 			osc_obd->obd_force = obddev->obd_force;
 			err = obd_iocontrol(cmd, lov->lov_tgts[i]->ltd_exp,
@@ -1620,7 +1633,8 @@ static u64 fiemap_calc_fm_end_offset(struct ll_user_fiemap *fiemap,
 		return -EINVAL;
 
 	/* If we have finished mapping on previous device, shift logical
-	 * offset to start of next device */
+	 * offset to start of next device
+	 */
 	if ((lov_stripe_intersects(lsm, stripe_no, fm_start, fm_end,
 				   &lun_start, &lun_end)) != 0 &&
 				   local_end < lun_end) {
@@ -1628,7 +1642,8 @@ static u64 fiemap_calc_fm_end_offset(struct ll_user_fiemap *fiemap,
 		*start_stripe = stripe_no;
 	} else {
 		/* This is a special value to indicate that caller should
-		 * calculate offset in next stripe. */
+		 * calculate offset in next stripe.
+		 */
 		fm_end_offset = 0;
 		*start_stripe = (stripe_no + 1) % lsm->lsm_stripe_count;
 	}
@@ -1796,7 +1811,8 @@ static int lov_fiemap(struct lov_obd *lov, __u32 keylen, void *key,
 
 		/* If this is a continuation FIEMAP call and we are on
 		 * starting stripe then lun_start needs to be set to
-		 * fm_end_offset */
+		 * fm_end_offset
+		 */
 		if (fm_end_offset != 0 && cur_stripe == start_stripe)
 			lun_start = fm_end_offset;
 
@@ -1818,7 +1834,8 @@ static int lov_fiemap(struct lov_obd *lov, __u32 keylen, void *key,
 		len_mapped_single_call = 0;
 
 		/* If the output buffer is very large and the objects have many
-		 * extents we may need to loop on a single OST repeatedly */
+		 * extents we may need to loop on a single OST repeatedly
+		 */
 		ost_eof = 0;
 		ost_done = 0;
 		do {
@@ -1874,7 +1891,8 @@ inactive_tgt:
 			if (ext_count == 0) {
 				ost_done = 1;
 				/* If last stripe has hole at the end,
-				 * then we need to return */
+				 * then we need to return
+				 */
 				if (cur_stripe_wrap == last_stripe) {
 					fiemap->fm_mapped_extents = 0;
 					goto finish;
@@ -1896,7 +1914,8 @@ inactive_tgt:
 				ost_done = 1;
 
 			/* Clear the EXTENT_LAST flag which can be present on
-			 * last extent */
+			 * last extent
+			 */
 			if (lcl_fm_ext[ext_count-1].fe_flags & FIEMAP_EXTENT_LAST)
 				lcl_fm_ext[ext_count - 1].fe_flags &=
 							    ~FIEMAP_EXTENT_LAST;
@@ -1925,7 +1944,8 @@ inactive_tgt:
 
 finish:
 	/* Indicate that we are returning device offsets unless file just has
-	 * single stripe */
+	 * single stripe
+	 */
 	if (lsm->lsm_stripe_count > 1)
 		fiemap->fm_flags |= FIEMAP_FLAG_DEVICE_ORDER;
 
@@ -1933,7 +1953,8 @@ finish:
 		goto skip_last_device_calc;
 
 	/* Check if we have reached the last stripe and whether mapping for that
-	 * stripe is done. */
+	 * stripe is done.
+	 */
 	if (cur_stripe_wrap == last_stripe) {
 		if (ost_done || ost_eof)
 			fiemap->fm_extents[current_extent - 1].fe_flags |=
@@ -1978,10 +1999,12 @@ static int lov_get_info(const struct lu_env *env, struct obd_export *exp,
 
 		/* XXX This is another one of those bits that will need to
 		 * change if we ever actually support nested LOVs.  It uses
-		 * the lock's export to find out which stripe it is. */
+		 * the lock's export to find out which stripe it is.
+		 */
 		/* XXX - it's assumed all the locks for deleted OSTs have
 		 * been cancelled. Also, the export for deleted OSTs will
-		 * be NULL and won't match the lock's export. */
+		 * be NULL and won't match the lock's export.
+		 */
 		for (i = 0; i < lsm->lsm_stripe_count; i++) {
 			loi = lsm->lsm_oinfo[i];
 			if (lov_oinfo_is_dummy(loi))
@@ -2317,7 +2340,8 @@ static int __init lov_init(void)
 
 	/* print an address of _any_ initialized kernel symbol from this
 	 * module, to allow debugging with gdb that doesn't support data
-	 * symbols from modules.*/
+	 * symbols from modules.
+	 */
 	CDEBUG(D_INFO, "Lustre LOV module (%p).\n", &lov_caches);
 
 	rc = lu_kmem_init(lov_caches);
diff --git a/drivers/staging/lustre/lustre/lov/lov_object.c b/drivers/staging/lustre/lustre/lov/lov_object.c
index 1922e04..4101696 100644
--- a/drivers/staging/lustre/lustre/lov/lov_object.c
+++ b/drivers/staging/lustre/lustre/lov/lov_object.c
@@ -135,7 +135,8 @@ static int lov_init_sub(const struct lu_env *env, struct lov_object *lov,
 		 * Do not leave the object in cache to avoid accessing
 		 * freed memory. This is because osc_object is referring to
 		 * lov_oinfo of lsm_stripe_data which will be freed due to
-		 * this failure. */
+		 * this failure.
+		 */
 		cl_object_kill(env, stripe);
 		cl_object_put(env, stripe);
 		return -EIO;
@@ -174,7 +175,8 @@ static int lov_init_sub(const struct lu_env *env, struct lov_object *lov,
 		old_lov = cl2lov(lu2cl(old_obj));
 		if (old_lov->lo_layout_invalid) {
 			/* the object's layout has already changed but isn't
-			 * refreshed */
+			 * refreshed
+			 */
 			lu_object_unhash(env, &stripe->co_lu);
 			result = -EAGAIN;
 		} else {
@@ -243,7 +245,8 @@ static int lov_init_raid0(const struct lu_env *env,
 			subconf->u.coc_oinfo = oinfo;
 			LASSERTF(subdev, "not init ost %d\n", ost_idx);
 			/* In the function below, .hs_keycmp resolves to
-			 * lu_obj_hop_keycmp() */
+			 * lu_obj_hop_keycmp()
+			 */
 			/* coverity[overrun-buffer-val] */
 			stripe = lov_sub_find(env, subdev, ofid, subconf);
 			if (!IS_ERR(stripe)) {
@@ -310,7 +313,8 @@ static void lov_subobject_kill(const struct lu_env *env, struct lov_object *lov,
 	cl_object_put(env, sub);
 
 	/* ... wait until it is actually destroyed---sub-object clears its
-	 * ->lo_sub[] slot in lovsub_object_fini() */
+	 * ->lo_sub[] slot in lovsub_object_fini()
+	 */
 	if (r0->lo_sub[idx] == los) {
 		waiter = &lov_env_info(env)->lti_waiter;
 		init_waitqueue_entry(waiter, current);
@@ -318,7 +322,8 @@ static void lov_subobject_kill(const struct lu_env *env, struct lov_object *lov,
 		set_current_state(TASK_UNINTERRUPTIBLE);
 		while (1) {
 			/* this wait-queue is signaled at the end of
-			 * lu_object_free(). */
+			 * lu_object_free().
+			 */
 			set_current_state(TASK_UNINTERRUPTIBLE);
 			spin_lock(&r0->lo_sub_lock);
 			if (r0->lo_sub[idx] == los) {
@@ -465,7 +470,8 @@ static int lov_attr_get_raid0(const struct lu_env *env, struct cl_object *obj,
 	 * context, and this function is called in ccc_lock_state(), it will
 	 * hit this assertion.
 	 * Anyway, it's still okay to call attr_get w/o type guard as layout
-	 * can't go if locks exist. */
+	 * can't go if locks exist.
+	 */
 	/* LASSERT(atomic_read(&lsm->lsm_refc) > 1); */
 
 	if (!r0->lo_attr_valid) {
@@ -475,7 +481,8 @@ static int lov_attr_get_raid0(const struct lu_env *env, struct cl_object *obj,
 
 		memset(lvb, 0, sizeof(*lvb));
 		/* XXX: timestamps can be negative by sanity:test_39m,
-		 * how can it be? */
+		 * how can it be?
+		 */
 		lvb->lvb_atime = LLONG_MIN;
 		lvb->lvb_ctime = LLONG_MIN;
 		lvb->lvb_mtime = LLONG_MIN;
@@ -845,7 +852,8 @@ static int lov_attr_get(const struct lu_env *env, struct cl_object *obj,
 			struct cl_attr *attr)
 {
 	/* do not take lock, as this function is called under a
-	 * spin-lock. Layout is protected from changing by ongoing IO. */
+	 * spin-lock. Layout is protected from changing by ongoing IO.
+	 */
 	return LOV_2DISPATCH_NOLOCK(cl2lov(obj), llo_getattr, env, obj, attr);
 }
 
diff --git a/drivers/staging/lustre/lustre/lov/lov_offset.c b/drivers/staging/lustre/lustre/lov/lov_offset.c
index 5feb2e9..1ceea3d 100644
--- a/drivers/staging/lustre/lustre/lov/lov_offset.c
+++ b/drivers/staging/lustre/lustre/lov/lov_offset.c
@@ -114,7 +114,8 @@ u64 lov_stripe_size(struct lov_stripe_md *lsm, u64 ost_size,
  * this function returns < 0 when the offset was "before" the stripe and
  * was moved forward to the start of the stripe in question;  0 when it
  * falls in the stripe and no shifting was done; > 0 when the offset
- * was outside the stripe and was pulled back to its final byte. */
+ * was outside the stripe and was pulled back to its final byte.
+ */
 int lov_stripe_offset(struct lov_stripe_md *lsm, u64 lov_off,
 		      int stripeno, u64 *obdoff)
 {
@@ -209,7 +210,8 @@ u64 lov_size_to_stripe(struct lov_stripe_md *lsm, u64 file_size,
 
 /* given an extent in an lov and a stripe, calculate the extent of the stripe
  * that is contained within the lov extent.  this returns true if the given
- * stripe does intersect with the lov extent. */
+ * stripe does intersect with the lov extent.
+ */
 int lov_stripe_intersects(struct lov_stripe_md *lsm, int stripeno,
 			  u64 start, u64 end, u64 *obd_start, u64 *obd_end)
 {
@@ -223,7 +225,8 @@ int lov_stripe_intersects(struct lov_stripe_md *lsm, int stripeno,
 
 	/* this stripe doesn't intersect the file extent when neither
 	 * start or the end intersected the stripe and obd_start and
-	 * obd_end got rounded up to the save value. */
+	 * obd_end got rounded up to the save value.
+	 */
 	if (start_side != 0 && end_side != 0 && *obd_start == *obd_end)
 		return 0;
 
@@ -234,7 +237,8 @@ int lov_stripe_intersects(struct lov_stripe_md *lsm, int stripeno,
 	 * in the wrong direction and touch it up.
 	 * interestingly, this can't underflow since end must be > start
 	 * if we passed through the previous check.
-	 * (should we assert for that somewhere?) */
+	 * (should we assert for that somewhere?)
+	 */
 	if (end_side != 0)
 		(*obd_end)--;
 
diff --git a/drivers/staging/lustre/lustre/lov/lov_pack.c b/drivers/staging/lustre/lustre/lov/lov_pack.c
index 4d8abb9..8871bce 100644
--- a/drivers/staging/lustre/lustre/lov/lov_pack.c
+++ b/drivers/staging/lustre/lustre/lov/lov_pack.c
@@ -141,7 +141,8 @@ int lov_packmd(struct obd_export *exp, struct lov_mds_md **lmmp,
 
 	if (lsm) {
 		/* If we are just sizing the EA, limit the stripe count
-		 * to the actual number of OSTs in this filesystem. */
+		 * to the actual number of OSTs in this filesystem.
+		 */
 		if (!lmmp) {
 			stripe_count = lov_get_stripecnt(lov, lmm_magic,
 							lsm->lsm_stripe_count);
@@ -155,7 +156,8 @@ int lov_packmd(struct obd_export *exp, struct lov_mds_md **lmmp,
 		/* No need to allocate more than maximum supported stripes.
 		 * Anyway, this is pretty inaccurate since ld_tgt_count now
 		 * represents max index and we should rely on the actual number
-		 * of OSTs instead */
+		 * of OSTs instead
+		 */
 		stripe_count = lov_mds_md_max_stripe_count(
 			lov->lov_ocd.ocd_max_easize, lmm_magic);
 
@@ -241,7 +243,8 @@ __u16 lov_get_stripecnt(struct lov_obd *lov, __u32 magic, __u16 stripe_count)
 		stripe_count = 1;
 
 	/* stripe count is based on whether ldiskfs can handle
-	 * larger EA sizes */
+	 * larger EA sizes
+	 */
 	if (lov->lov_ocd.ocd_connect_flags & OBD_CONNECT_MAX_EASIZE &&
 	    lov->lov_ocd.ocd_max_easize)
 		max_stripes = lov_mds_md_max_stripe_count(
@@ -397,7 +400,8 @@ int lov_getstripe(struct obd_export *exp, struct lov_stripe_md *lsm,
 	set_fs(KERNEL_DS);
 
 	/* we only need the header part from user space to get lmm_magic and
-	 * lmm_stripe_count, (the header part is common to v1 and v3) */
+	 * lmm_stripe_count, (the header part is common to v1 and v3)
+	 */
 	lum_size = sizeof(struct lov_user_md_v1);
 	if (copy_from_user(&lum, lump, lum_size)) {
 		rc = -EFAULT;
diff --git a/drivers/staging/lustre/lustre/lov/lov_pool.c b/drivers/staging/lustre/lustre/lov/lov_pool.c
index b9d3622..14e920b 100644
--- a/drivers/staging/lustre/lustre/lov/lov_pool.c
+++ b/drivers/staging/lustre/lustre/lov/lov_pool.c
@@ -204,7 +204,8 @@ static void *pool_proc_start(struct seq_file *s, loff_t *pos)
 	if ((pool_tgt_count(pool) == 0) ||
 	    (*pos >= pool_tgt_count(pool))) {
 		/* iter is not created, so stop() has no way to
-		 * find pool to dec ref */
+		 * find pool to dec ref
+		 */
 		lov_pool_putref(pool);
 		return NULL;
 	}
@@ -217,7 +218,8 @@ static void *pool_proc_start(struct seq_file *s, loff_t *pos)
 	iter->idx = 0;
 
 	/* we use seq_file private field to memorized iterator so
-	 * we can free it at stop() */
+	 * we can free it at stop()
+	 */
 	/* /!\ do not forget to restore it to pool before freeing it */
 	s->private = iter;
 	if (*pos > 0) {
@@ -239,10 +241,12 @@ static void pool_proc_stop(struct seq_file *s, void *v)
 
 	/* in some cases stop() method is called 2 times, without
 	 * calling start() method (see seq_read() from fs/seq_file.c)
-	 * we have to free only if s->private is an iterator */
+	 * we have to free only if s->private is an iterator
+	 */
 	if ((iter) && (iter->magic == POOL_IT_MAGIC)) {
 		/* we restore s->private so next call to pool_proc_start()
-		 * will work */
+		 * will work
+		 */
 		s->private = iter->pool;
 		lov_pool_putref(iter->pool);
 		kfree(iter);
diff --git a/drivers/staging/lustre/lustre/lov/lov_request.c b/drivers/staging/lustre/lustre/lov/lov_request.c
index 6c5ae05..5408eef 100644
--- a/drivers/staging/lustre/lustre/lov/lov_request.c
+++ b/drivers/staging/lustre/lustre/lov/lov_request.c
@@ -225,7 +225,8 @@ static int common_attr_done(struct lov_request_set *set)
 	if ((set->set_oi->oi_oa->o_valid & OBD_MD_FLEPOCH) &&
 	    (set->set_oi->oi_md->lsm_stripe_count != attrset)) {
 		/* When we take attributes of some epoch, we require all the
-		 * ost to be active. */
+		 * ost to be active.
+		 */
 		CERROR("Not all the stripes had valid attrs\n");
 		rc = -EIO;
 		goto out;
@@ -256,7 +257,8 @@ int lov_fini_getattr_set(struct lov_request_set *set)
 }
 
 /* The callback for osc_getattr_async that finalizes a request info when a
- * response is received. */
+ * response is received.
+ */
 static int cb_getattr_update(void *cookie, int rc)
 {
 	struct obd_info *oinfo = cookie;
@@ -458,7 +460,8 @@ int lov_update_setattr_set(struct lov_request_set *set,
 }
 
 /* The callback for osc_setattr_async that finalizes a request info when a
- * response is received. */
+ * response is received.
+ */
 static int cb_setattr_update(void *cookie, int rc)
 {
 	struct obd_info *oinfo = cookie;
@@ -646,7 +649,8 @@ static void lov_update_statfs(struct obd_statfs *osfs,
 }
 
 /* The callback for osc_statfs_async that finalizes a request info when a
- * response is received. */
+ * response is received.
+ */
 static int cb_statfs_update(void *cookie, int rc)
 {
 	struct obd_info *oinfo = cookie;
@@ -666,7 +670,8 @@ static int cb_statfs_update(void *cookie, int rc)
 	lov_sfs = oinfo->oi_osfs;
 	success = atomic_read(&set->set_success);
 	/* XXX: the same is done in lov_update_common_set, however
-	   lovset->set_exp is not initialized. */
+	 * lovset->set_exp is not initialized.
+	 */
 	lov_update_set(set, lovreq, rc);
 	if (rc)
 		goto out;
@@ -724,7 +729,8 @@ int lov_prep_statfs_set(struct obd_device *obd, struct obd_info *oinfo,
 		}
 
 		/* skip targets that have been explicitly disabled by the
-		 * administrator */
+		 * administrator
+		 */
 		if (!lov->lov_tgts[i]->ltd_exp) {
 			CDEBUG(D_HA, "lov idx %d administratively disabled\n", i);
 			continue;
diff --git a/drivers/staging/lustre/lustre/lov/lovsub_lock.c b/drivers/staging/lustre/lustre/lov/lovsub_lock.c
index bd38736..0046812 100644
--- a/drivers/staging/lustre/lustre/lov/lovsub_lock.c
+++ b/drivers/staging/lustre/lustre/lov/lovsub_lock.c
@@ -148,7 +148,8 @@ static void lovsub_lock_descr_map(const struct cl_lock_descr *in,
 {
 	pgoff_t size; /* stripe size in pages */
 	pgoff_t skip; /* how many pages in every stripe are occupied by
-		       * "other" stripes */
+		       * "other" stripes
+		       */
 	pgoff_t start;
 	pgoff_t end;
 
@@ -284,7 +285,8 @@ static int lovsub_lock_delete_one(const struct lu_env *env,
 	switch (parent->cll_state) {
 	case CLS_ENQUEUED:
 		/* See LU-1355 for the case that a glimpse lock is
-		 * interrupted by signal */
+		 * interrupted by signal
+		 */
 		LASSERT(parent->cll_flags & CLF_CANCELLED);
 		break;
 	case CLS_QUEUING:
-- 
2.1.0
