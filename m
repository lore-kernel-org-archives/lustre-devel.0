From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Tue, 16 Feb 2016 00:46:45 -0500
Subject: [lustre-devel] [PATCH 13/45] staging/lustre/lov: Adjust NULL
	comparison codestyle
In-Reply-To: <1455601637-3847710-1-git-send-email-green@linuxhacker.ru>
References: <1455601637-3847710-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1455601637-3847710-14-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

All instances of "x == NULL" are changed to "!x" and
"x != NULL" to "x"
Also removed some redundant assertions.

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 .../staging/lustre/lustre/lov/lov_cl_internal.h    |  6 +--
 drivers/staging/lustre/lustre/lov/lov_dev.c        | 40 ++++++++---------
 drivers/staging/lustre/lustre/lov/lov_ea.c         |  4 +-
 drivers/staging/lustre/lustre/lov/lov_internal.h   |  1 -
 drivers/staging/lustre/lustre/lov/lov_io.c         | 30 ++++++-------
 drivers/staging/lustre/lustre/lov/lov_lock.c       | 49 ++++++++++-----------
 drivers/staging/lustre/lustre/lov/lov_obd.c        | 44 +++++++++----------
 drivers/staging/lustre/lustre/lov/lov_object.c     | 51 +++++++++++-----------
 drivers/staging/lustre/lustre/lov/lov_offset.c     |  5 ---
 drivers/staging/lustre/lustre/lov/lov_pack.c       |  8 ++--
 drivers/staging/lustre/lustre/lov/lov_page.c       |  6 +--
 drivers/staging/lustre/lustre/lov/lov_pool.c       | 20 ++++-----
 drivers/staging/lustre/lustre/lov/lov_request.c    | 30 ++++++-------
 drivers/staging/lustre/lustre/lov/lovsub_dev.c     |  5 +--
 drivers/staging/lustre/lustre/lov/lovsub_lock.c    |  4 +-
 drivers/staging/lustre/lustre/lov/lovsub_object.c  |  4 +-
 drivers/staging/lustre/lustre/lov/lproc_lov.c      | 18 ++++----
 17 files changed, 152 insertions(+), 173 deletions(-)

diff --git a/drivers/staging/lustre/lustre/lov/lov_cl_internal.h b/drivers/staging/lustre/lustre/lov/lov_cl_internal.h
index 66a2492..b5fc159 100644
--- a/drivers/staging/lustre/lustre/lov/lov_cl_internal.h
+++ b/drivers/staging/lustre/lustre/lov/lov_cl_internal.h
@@ -651,7 +651,7 @@ static inline struct lov_session *lov_env_session(const struct lu_env *env)
 	struct lov_session *ses;
 
 	ses = lu_context_key_get(env->le_ses, &lov_session_key);
-	LASSERT(ses != NULL);
+	LASSERT(ses);
 	return ses;
 }
 
@@ -759,7 +759,7 @@ static inline struct lovsub_lock *cl2sub_lock(const struct cl_lock *lock)
 	const struct cl_lock_slice *slice;
 
 	slice = cl_lock_at(lock, &lovsub_device_type);
-	LASSERT(slice != NULL);
+	LASSERT(slice);
 	return cl2lovsub_lock(slice);
 }
 
@@ -817,7 +817,7 @@ static inline struct lov_thread_info *lov_env_info(const struct lu_env *env)
 	struct lov_thread_info *info;
 
 	info = lu_context_key_get(&env->le_ctx, &lov_key);
-	LASSERT(info != NULL);
+	LASSERT(info);
 	return info;
 }
 
diff --git a/drivers/staging/lustre/lustre/lov/lov_dev.c b/drivers/staging/lustre/lustre/lov/lov_dev.c
index 2c33cbc..ee093e0 100644
--- a/drivers/staging/lustre/lustre/lov/lov_dev.c
+++ b/drivers/staging/lustre/lustre/lov/lov_dev.c
@@ -143,7 +143,7 @@ static void *lov_key_init(const struct lu_context *ctx,
 	struct lov_thread_info *info;
 
 	info = kmem_cache_alloc(lov_thread_kmem, GFP_NOFS | __GFP_ZERO);
-	if (info != NULL)
+	if (info)
 		INIT_LIST_HEAD(&info->lti_closure.clc_list);
 	else
 		info = ERR_PTR(-ENOMEM);
@@ -171,7 +171,7 @@ static void *lov_session_key_init(const struct lu_context *ctx,
 	struct lov_session *info;
 
 	info = kmem_cache_alloc(lov_session_kmem, GFP_NOFS | __GFP_ZERO);
-	if (info == NULL)
+	if (!info)
 		info = ERR_PTR(-ENOMEM);
 	return info;
 }
@@ -199,15 +199,15 @@ static struct lu_device *lov_device_fini(const struct lu_env *env,
 	int i;
 	struct lov_device *ld = lu2lov_dev(d);
 
-	LASSERT(ld->ld_lov != NULL);
-	if (ld->ld_target == NULL)
+	LASSERT(ld->ld_lov);
+	if (!ld->ld_target)
 		return NULL;
 
 	lov_foreach_target(ld, i) {
 		struct lovsub_device *lsd;
 
 		lsd = ld->ld_target[i];
-		if (lsd != NULL) {
+		if (lsd) {
 			cl_stack_fini(env, lovsub2cl_dev(lsd));
 			ld->ld_target[i] = NULL;
 		}
@@ -222,8 +222,8 @@ static int lov_device_init(const struct lu_env *env, struct lu_device *d,
 	int i;
 	int rc = 0;
 
-	LASSERT(d->ld_site != NULL);
-	if (ld->ld_target == NULL)
+	LASSERT(d->ld_site);
+	if (!ld->ld_target)
 		return rc;
 
 	lov_foreach_target(ld, i) {
@@ -232,7 +232,7 @@ static int lov_device_init(const struct lu_env *env, struct lu_device *d,
 		struct lov_tgt_desc  *desc;
 
 		desc = ld->ld_lov->lov_tgts[i];
-		if (desc == NULL)
+		if (!desc)
 			continue;
 
 		cl = cl_type_setup(env, d->ld_site, &lovsub_device_type,
@@ -262,7 +262,7 @@ static int lov_req_init(const struct lu_env *env, struct cl_device *dev,
 	int result;
 
 	lr = kmem_cache_alloc(lov_req_kmem, GFP_NOFS | __GFP_ZERO);
-	if (lr != NULL) {
+	if (lr) {
 		cl_req_slice_add(req, &lr->lr_cl, dev, &lov_req_ops);
 		result = 0;
 	} else
@@ -282,9 +282,9 @@ static void lov_emerg_free(struct lov_device_emerg **emrg, int nr)
 		struct lov_device_emerg *em;
 
 		em = emrg[i];
-		if (em != NULL) {
+		if (em) {
 			LASSERT(em->emrg_page_list.pl_nr == 0);
-			if (em->emrg_env != NULL)
+			if (em->emrg_env)
 				cl_env_put(em->emrg_env, &em->emrg_refcheck);
 			kfree(em);
 		}
@@ -300,7 +300,7 @@ static struct lu_device *lov_device_free(const struct lu_env *env,
 
 	cl_device_fini(lu2cl_dev(d));
 	kfree(ld->ld_target);
-	if (ld->ld_emrg != NULL)
+	if (ld->ld_emrg)
 		lov_emerg_free(ld->ld_emrg, nr);
 	kfree(ld);
 	return NULL;
@@ -311,7 +311,7 @@ static void lov_cl_del_target(const struct lu_env *env, struct lu_device *dev,
 {
 	struct lov_device *ld = lu2lov_dev(dev);
 
-	if (ld->ld_target[index] != NULL) {
+	if (ld->ld_target[index]) {
 		cl_stack_fini(env, lovsub2cl_dev(ld->ld_target[index]));
 		ld->ld_target[index] = NULL;
 	}
@@ -324,13 +324,13 @@ static struct lov_device_emerg **lov_emerg_alloc(int nr)
 	int result;
 
 	emerg = kcalloc(nr, sizeof(emerg[0]), GFP_NOFS);
-	if (emerg == NULL)
+	if (!emerg)
 		return ERR_PTR(-ENOMEM);
 	for (result = i = 0; i < nr && result == 0; i++) {
 		struct lov_device_emerg *em;
 
 		em = kzalloc(sizeof(*em), GFP_NOFS);
-		if (em != NULL) {
+		if (em) {
 			emerg[i] = em;
 			cl_page_list_init(&em->emrg_page_list);
 			em->emrg_env = cl_env_alloc(&em->emrg_refcheck,
@@ -370,7 +370,7 @@ static int lov_expand_targets(const struct lu_env *env, struct lov_device *dev)
 			return PTR_ERR(emerg);
 
 		newd = kcalloc(tgt_size, sz, GFP_NOFS);
-		if (newd != NULL) {
+		if (newd) {
 			mutex_lock(&dev->ld_mutex);
 			if (sub_size > 0) {
 				memcpy(newd, dev->ld_target, sub_size * sz);
@@ -379,7 +379,7 @@ static int lov_expand_targets(const struct lu_env *env, struct lov_device *dev)
 			dev->ld_target    = newd;
 			dev->ld_target_nr = tgt_size;
 
-			if (dev->ld_emrg != NULL)
+			if (dev->ld_emrg)
 				lov_emerg_free(dev->ld_emrg, sub_size);
 			dev->ld_emrg = emerg;
 			mutex_unlock(&dev->ld_mutex);
@@ -404,8 +404,6 @@ static int lov_cl_add_target(const struct lu_env *env, struct lu_device *dev,
 	obd_getref(obd);
 
 	tgt = obd->u.lov.lov_tgts[index];
-	LASSERT(tgt != NULL);
-	LASSERT(tgt->ltd_obd != NULL);
 
 	if (!tgt->ltd_obd->obd_set_up) {
 		CERROR("Target %s not set up\n", obd_uuid2str(&tgt->ltd_uuid));
@@ -414,7 +412,7 @@ static int lov_cl_add_target(const struct lu_env *env, struct lu_device *dev,
 
 	rc = lov_expand_targets(env, ld);
 	if (rc == 0 && ld->ld_flags & LOV_DEV_INITIALIZED) {
-		LASSERT(dev->ld_site != NULL);
+		LASSERT(dev->ld_site);
 
 		cl = cl_type_setup(env, dev->ld_site, &lovsub_device_type,
 				   tgt->ltd_obd->obd_lu_dev);
@@ -492,7 +490,7 @@ static struct lu_device *lov_device_alloc(const struct lu_env *env,
 
 	/* setup the LOV OBD */
 	obd = class_name2obd(lustre_cfg_string(cfg, 0));
-	LASSERT(obd != NULL);
+	LASSERT(obd);
 	rc = lov_setup(obd, cfg);
 	if (rc) {
 		lov_device_free(env, d);
diff --git a/drivers/staging/lustre/lustre/lov/lov_ea.c b/drivers/staging/lustre/lustre/lov/lov_ea.c
index b3c9c85..6c8381a 100644
--- a/drivers/staging/lustre/lustre/lov/lov_ea.c
+++ b/drivers/staging/lustre/lustre/lov/lov_ea.c
@@ -101,7 +101,7 @@ struct lov_stripe_md *lsm_alloc_plain(__u16 stripe_count, int *size)
 
 	for (i = 0; i < stripe_count; i++) {
 		loi = kmem_cache_alloc(lov_oinfo_slab, GFP_NOFS | __GFP_ZERO);
-		if (loi == NULL)
+		if (!loi)
 			goto err;
 		lsm->lsm_oinfo[i] = loi;
 	}
@@ -167,7 +167,7 @@ static void lov_tgt_maxbytes(struct lov_tgt_desc *tgt, __u64 *stripe_maxbytes)
 {
 	struct obd_import *imp = tgt->ltd_obd->u.cli.cl_import;
 
-	if (imp == NULL || !tgt->ltd_active) {
+	if (!imp || !tgt->ltd_active) {
 		*stripe_maxbytes = LUSTRE_STRIPE_MAXBYTES;
 		return;
 	}
diff --git a/drivers/staging/lustre/lustre/lov/lov_internal.h b/drivers/staging/lustre/lustre/lov/lov_internal.h
index f8e92fe..d4522ba 100644
--- a/drivers/staging/lustre/lustre/lov/lov_internal.h
+++ b/drivers/staging/lustre/lustre/lov/lov_internal.h
@@ -114,7 +114,6 @@ void lov_finish_set(struct lov_request_set *set);
 
 static inline void lov_get_reqset(struct lov_request_set *set)
 {
-	LASSERT(set != NULL);
 	LASSERT(atomic_read(&set->set_refcount) > 0);
 	atomic_inc(&set->set_refcount);
 }
diff --git a/drivers/staging/lustre/lustre/lov/lov_io.c b/drivers/staging/lustre/lustre/lov/lov_io.c
index 93fe69e..50954ce 100644
--- a/drivers/staging/lustre/lustre/lov/lov_io.c
+++ b/drivers/staging/lustre/lustre/lov/lov_io.c
@@ -60,7 +60,7 @@ static inline void lov_sub_exit(struct lov_io_sub *sub)
 static void lov_io_sub_fini(const struct lu_env *env, struct lov_io *lio,
 			    struct lov_io_sub *sub)
 {
-	if (sub->sub_io != NULL) {
+	if (sub->sub_io) {
 		if (sub->sub_io_initialized) {
 			lov_sub_enter(sub);
 			cl_io_fini(sub->sub_env, sub->sub_io);
@@ -74,7 +74,7 @@ static void lov_io_sub_fini(const struct lu_env *env, struct lov_io *lio,
 			kfree(sub->sub_io);
 		sub->sub_io = NULL;
 	}
-	if (sub->sub_env != NULL && !IS_ERR(sub->sub_env)) {
+	if (!IS_ERR_OR_NULL(sub->sub_env)) {
 		if (!sub->sub_borrowed)
 			cl_env_put(sub->sub_env, &sub->sub_refcheck);
 		sub->sub_env = NULL;
@@ -143,11 +143,11 @@ static int lov_io_sub_init(const struct lu_env *env, struct lov_io *lio,
 	int stripe = sub->sub_stripe;
 	int result;
 
-	LASSERT(sub->sub_io == NULL);
-	LASSERT(sub->sub_env == NULL);
+	LASSERT(!sub->sub_io);
+	LASSERT(!sub->sub_env);
 	LASSERT(sub->sub_stripe < lio->lis_stripe_count);
 
-	if (unlikely(lov_r0(lov)->lo_sub[stripe] == NULL))
+	if (unlikely(!lov_r0(lov)->lo_sub[stripe]))
 		return -EIO;
 
 	result = 0;
@@ -252,7 +252,6 @@ static int lov_page_stripe(const struct cl_page *page)
 	subobj = lu2lovsub(
 		lu_object_locate(page->cp_child->cp_obj->co_lu.lo_header,
 				 &lovsub_device_type));
-	LASSERT(subobj != NULL);
 	return subobj->lso_index;
 }
 
@@ -263,9 +262,9 @@ struct lov_io_sub *lov_page_subio(const struct lu_env *env, struct lov_io *lio,
 	struct cl_page       *page = slice->cpl_page;
 	int stripe;
 
-	LASSERT(lio->lis_cl.cis_io != NULL);
+	LASSERT(lio->lis_cl.cis_io);
 	LASSERT(cl2lov(slice->cpl_obj) == lio->lis_object);
-	LASSERT(lsm != NULL);
+	LASSERT(lsm);
 	LASSERT(lio->lis_nr_subios > 0);
 
 	stripe = lov_page_stripe(page);
@@ -278,7 +277,7 @@ static int lov_io_subio_init(const struct lu_env *env, struct lov_io *lio,
 	struct lov_stripe_md *lsm = lio->lis_object->lo_lsm;
 	int result;
 
-	LASSERT(lio->lis_object != NULL);
+	LASSERT(lio->lis_object);
 
 	/*
 	 * Need to be optimized, we can't afford to allocate a piece of memory
@@ -288,7 +287,7 @@ static int lov_io_subio_init(const struct lu_env *env, struct lov_io *lio,
 		libcfs_kvzalloc(lsm->lsm_stripe_count *
 				sizeof(lio->lis_subs[0]),
 				GFP_NOFS);
-	if (lio->lis_subs != NULL) {
+	if (lio->lis_subs) {
 		lio->lis_nr_subios = lio->lis_stripe_count;
 		lio->lis_single_subio_index = -1;
 		lio->lis_active_subios = 0;
@@ -304,7 +303,6 @@ static void lov_io_slice_init(struct lov_io *lio,
 	io->ci_result = 0;
 	lio->lis_object = obj;
 
-	LASSERT(obj->lo_lsm != NULL);
 	lio->lis_stripe_count = obj->lo_lsm->lsm_stripe_count;
 
 	switch (io->ci_type) {
@@ -358,7 +356,7 @@ static void lov_io_fini(const struct lu_env *env, const struct cl_io_slice *ios)
 	struct lov_object *lov = cl2lov(ios->cis_obj);
 	int i;
 
-	if (lio->lis_subs != NULL) {
+	if (lio->lis_subs) {
 		for (i = 0; i < lio->lis_nr_subios; i++)
 			lov_io_sub_fini(env, lio, &lio->lis_subs[i]);
 		kvfree(lio->lis_subs);
@@ -395,7 +393,7 @@ static int lov_io_iter_init(const struct lu_env *env,
 					   endpos, &start, &end))
 			continue;
 
-		if (unlikely(lov_r0(lio->lis_object)->lo_sub[stripe] == NULL)) {
+		if (unlikely(!lov_r0(lio->lis_object)->lo_sub[stripe])) {
 			if (ios->cis_io->ci_type == CIT_READ ||
 			    ios->cis_io->ci_type == CIT_WRITE ||
 			    ios->cis_io->ci_type == CIT_FAULT)
@@ -601,13 +599,13 @@ static int lov_io_submit(const struct lu_env *env,
 		return rc;
 	}
 
-	LASSERT(lio->lis_subs != NULL);
+	LASSERT(lio->lis_subs);
 	if (alloc) {
 		stripes_qin =
 			libcfs_kvzalloc(sizeof(*stripes_qin) *
 					lio->lis_nr_subios,
 					GFP_NOFS);
-		if (stripes_qin == NULL)
+		if (!stripes_qin)
 			return -ENOMEM;
 
 		for (stripe = 0; stripe < lio->lis_nr_subios; stripe++)
@@ -955,7 +953,7 @@ int lov_io_init_released(const struct lu_env *env, struct cl_object *obj,
 	struct lov_io *lio = lov_env_io(env);
 	int result;
 
-	LASSERT(lov->lo_lsm != NULL);
+	LASSERT(lov->lo_lsm);
 	lio->lis_object = lov;
 
 	switch (io->ci_type) {
diff --git a/drivers/staging/lustre/lustre/lov/lov_lock.c b/drivers/staging/lustre/lustre/lov/lov_lock.c
index 36615da..e6b0437 100644
--- a/drivers/staging/lustre/lustre/lov/lov_lock.c
+++ b/drivers/staging/lustre/lustre/lov/lov_lock.c
@@ -115,7 +115,7 @@ static void lov_sublock_adopt(const struct lu_env *env, struct lov_lock *lck,
 	/*
 	 * check that sub-lock doesn't have lock link to this top-lock.
 	 */
-	LASSERT(lov_lock_link_find(env, lck, lsl) == NULL);
+	LASSERT(!lov_lock_link_find(env, lck, lsl));
 	LASSERT(idx < lck->lls_nr);
 
 	lck->lls_sub[idx].sub_lock = lsl;
@@ -145,7 +145,7 @@ static struct cl_lock *lov_sublock_alloc(const struct lu_env *env,
 	LASSERT(idx < lck->lls_nr);
 
 	link = kmem_cache_alloc(lov_lock_link_kmem, GFP_NOFS | __GFP_ZERO);
-	if (link != NULL) {
+	if (link) {
 		struct lov_sublock_env *subenv;
 		struct lov_lock_sub  *lls;
 		struct cl_lock_descr *descr;
@@ -220,7 +220,7 @@ static int lov_sublock_lock(const struct lu_env *env,
 			LASSERT(!(lls->sub_flags & LSF_HELD));
 
 			link = lov_lock_link_find(env, lck, sublock);
-			LASSERT(link != NULL);
+			LASSERT(link);
 			lov_lock_unlink(env, link, sublock);
 			lov_sublock_unlock(env, sublock, closure, NULL);
 			lck->lls_cancel_race = 1;
@@ -309,14 +309,14 @@ static int lov_lock_sub_init(const struct lu_env *env,
 		 * XXX for wide striping smarter algorithm is desirable,
 		 * breaking out of the loop, early.
 		 */
-		if (likely(r0->lo_sub[i] != NULL) &&
+		if (likely(r0->lo_sub[i]) &&
 		    lov_stripe_intersects(loo->lo_lsm, i,
 					  file_start, file_end, &start, &end))
 			nr++;
 	}
 	LASSERT(nr > 0);
 	lck->lls_sub = libcfs_kvzalloc(nr * sizeof(lck->lls_sub[0]), GFP_NOFS);
-	if (lck->lls_sub == NULL)
+	if (!lck->lls_sub)
 		return -ENOMEM;
 
 	lck->lls_nr = nr;
@@ -328,14 +328,14 @@ static int lov_lock_sub_init(const struct lu_env *env,
 	 * top-lock.
 	 */
 	for (i = 0, nr = 0; i < r0->lo_nr; ++i) {
-		if (likely(r0->lo_sub[i] != NULL) &&
+		if (likely(r0->lo_sub[i]) &&
 		    lov_stripe_intersects(loo->lo_lsm, i,
 					  file_start, file_end, &start, &end)) {
 			struct cl_lock_descr *descr;
 
 			descr = &lck->lls_sub[nr].sub_descr;
 
-			LASSERT(descr->cld_obj == NULL);
+			LASSERT(!descr->cld_obj);
 			descr->cld_obj   = lovsub2cl(r0->lo_sub[i]);
 			descr->cld_start = cl_index(descr->cld_obj, start);
 			descr->cld_end   = cl_index(descr->cld_obj, end);
@@ -369,7 +369,6 @@ static int lov_sublock_release(const struct lu_env *env, struct lov_lock *lck,
 		struct cl_lock    *sublock;
 		int dying;
 
-		LASSERT(lck->lls_sub[i].sub_lock != NULL);
 		sublock = lck->lls_sub[i].sub_lock->lss_cl.cls_lock;
 		LASSERT(cl_lock_is_mutexed(sublock));
 
@@ -413,7 +412,6 @@ static void lov_sublock_hold(const struct lu_env *env, struct lov_lock *lck,
 	if (!(lck->lls_sub[i].sub_flags & LSF_HELD)) {
 		struct cl_lock *sublock;
 
-		LASSERT(lck->lls_sub[i].sub_lock != NULL);
 		sublock = lck->lls_sub[i].sub_lock->lss_cl.cls_lock;
 		LASSERT(cl_lock_is_mutexed(sublock));
 		LASSERT(sublock->cll_state != CLS_FREEING);
@@ -435,13 +433,13 @@ static void lov_lock_fini(const struct lu_env *env,
 
 	lck = cl2lov_lock(slice);
 	LASSERT(lck->lls_nr_filled == 0);
-	if (lck->lls_sub != NULL) {
+	if (lck->lls_sub) {
 		for (i = 0; i < lck->lls_nr; ++i)
 			/*
 			 * No sub-locks exists at this point, as sub-lock has
 			 * a reference on its parent.
 			 */
-			LASSERT(lck->lls_sub[i].sub_lock == NULL);
+			LASSERT(!lck->lls_sub[i].sub_lock);
 		kvfree(lck->lls_sub);
 	}
 	kmem_cache_free(lov_lock_kmem, lck);
@@ -515,7 +513,7 @@ static int lov_sublock_fill(const struct lu_env *env, struct cl_lock *parent,
 	if (!IS_ERR(sublock)) {
 		cl_lock_get_trust(sublock);
 		if (parent->cll_state == CLS_QUEUING &&
-		    lck->lls_sub[idx].sub_lock == NULL) {
+		    !lck->lls_sub[idx].sub_lock) {
 			lov_sublock_adopt(env, lck, sublock, idx, link);
 		} else {
 			kmem_cache_free(lov_lock_link_kmem, link);
@@ -574,7 +572,7 @@ static int lov_lock_enqueue(const struct lu_env *env,
 		 * Sub-lock might have been canceled, while top-lock was
 		 * cached.
 		 */
-		if (sub == NULL) {
+		if (!sub) {
 			result = lov_sublock_fill(env, lock, io, lck, i);
 			/* lov_sublock_fill() released @lock mutex,
 			 * restart. */
@@ -620,7 +618,7 @@ static int lov_lock_enqueue(const struct lu_env *env,
 					break;
 				}
 			} else {
-				LASSERT(sublock->cll_conflict == NULL);
+				LASSERT(!sublock->cll_conflict);
 				lov_sublock_unlock(env, sub, closure, subenv);
 			}
 		}
@@ -653,7 +651,7 @@ static int lov_lock_unuse(const struct lu_env *env,
 		LASSERT(slice->cls_lock->cll_state == CLS_INTRANSIT);
 		lls = &lck->lls_sub[i];
 		sub = lls->sub_lock;
-		if (sub == NULL)
+		if (!sub)
 			continue;
 
 		sublock = sub->lss_cl.cls_lock;
@@ -698,7 +696,7 @@ static void lov_lock_cancel(const struct lu_env *env,
 		 * to the completion. */
 		lls = &lck->lls_sub[i];
 		sub = lls->sub_lock;
-		if (sub == NULL)
+		if (!sub)
 			continue;
 
 		sublock = sub->lss_cl.cls_lock;
@@ -757,7 +755,6 @@ again:
 
 		lls = &lck->lls_sub[i];
 		sub = lls->sub_lock;
-		LASSERT(sub != NULL);
 		sublock = sub->lss_cl.cls_lock;
 		rc = lov_sublock_lock(env, lck, lls, closure, &subenv);
 		if (rc == 0) {
@@ -805,7 +802,7 @@ static int lov_lock_use(const struct lu_env *env,
 
 		lls = &lck->lls_sub[i];
 		sub = lls->sub_lock;
-		if (sub == NULL) {
+		if (!sub) {
 			/*
 			 * Sub-lock might have been canceled, while top-lock was
 			 * cached.
@@ -883,10 +880,10 @@ static int lov_lock_stripe_is_matching(const struct lu_env *env,
 
 		idx = lov_stripe_number(lsm, start);
 		if (idx == stripe ||
-		    unlikely(lov_r0(lov)->lo_sub[idx] == NULL)) {
+		    unlikely(!lov_r0(lov)->lo_sub[idx])) {
 			idx = lov_stripe_number(lsm, end);
 			if (idx == stripe ||
-			    unlikely(lov_r0(lov)->lo_sub[idx] == NULL))
+			    unlikely(!lov_r0(lov)->lo_sub[idx]))
 				result = 1;
 		}
 	}
@@ -1035,7 +1032,7 @@ static void lov_lock_delete(const struct lu_env *env,
 		struct lov_lock_sub *lls = &lck->lls_sub[i];
 		struct lovsub_lock  *lsl = lls->sub_lock;
 
-		if (lsl == NULL) /* already removed */
+		if (!lsl) /* already removed */
 			continue;
 
 		rc = lov_sublock_lock(env, lck, lls, closure, NULL);
@@ -1051,9 +1048,9 @@ static void lov_lock_delete(const struct lu_env *env,
 			lov_sublock_release(env, lck, i, 1, 0);
 
 		link = lov_lock_link_find(env, lck, lsl);
-		LASSERT(link != NULL);
+		LASSERT(link);
 		lov_lock_unlink(env, link, lsl);
-		LASSERT(lck->lls_sub[i].sub_lock == NULL);
+		LASSERT(!lck->lls_sub[i].sub_lock);
 
 		lov_sublock_unlock(env, lsl, closure, NULL);
 	}
@@ -1073,7 +1070,7 @@ static int lov_lock_print(const struct lu_env *env, void *cookie,
 
 		sub = &lck->lls_sub[i];
 		(*p)(env, cookie, "    %d %x: ", i, sub->sub_flags);
-		if (sub->sub_lock != NULL)
+		if (sub->sub_lock)
 			cl_lock_print(env, cookie, p,
 				      sub->sub_lock->lss_cl.cls_lock);
 		else
@@ -1101,7 +1098,7 @@ int lov_lock_init_raid0(const struct lu_env *env, struct cl_object *obj,
 	int result;
 
 	lck = kmem_cache_alloc(lov_lock_kmem, GFP_NOFS | __GFP_ZERO);
-	if (lck != NULL) {
+	if (lck) {
 		cl_lock_slice_add(lock, &lck->lls_cl, obj, &lov_lock_ops);
 		result = lov_lock_sub_init(env, lck, io);
 	} else
@@ -1137,7 +1134,7 @@ int lov_lock_init_empty(const struct lu_env *env, struct cl_object *obj,
 	int result = -ENOMEM;
 
 	lck = kmem_cache_alloc(lov_lock_kmem, GFP_NOFS | __GFP_ZERO);
-	if (lck != NULL) {
+	if (lck) {
 		cl_lock_slice_add(lock, &lck->lls_cl, obj, &lov_empty_lock_ops);
 		lck->lls_orig = lock->cll_descr;
 		result = 0;
diff --git a/drivers/staging/lustre/lustre/lov/lov_obd.c b/drivers/staging/lustre/lustre/lov/lov_obd.c
index 65077b7..2b7b8ce 100644
--- a/drivers/staging/lustre/lustre/lov/lov_obd.c
+++ b/drivers/staging/lustre/lustre/lov/lov_obd.c
@@ -358,7 +358,7 @@ static int lov_set_osc_active(struct obd_device *obd, struct obd_uuid *uuid,
 		 * LU-642, initially inactive OSC could miss the obd_connect,
 		 * we make up for it here.
 		 */
-		if (ev == OBD_NOTIFY_ACTIVATE && tgt->ltd_exp == NULL &&
+		if (ev == OBD_NOTIFY_ACTIVATE && !tgt->ltd_exp &&
 		    obd_uuid_equals(uuid, &tgt->ltd_uuid)) {
 			struct obd_uuid lov_osc_uuid = {"LOV_OSC_UUID"};
 
@@ -521,12 +521,12 @@ static int lov_add_target(struct obd_device *obd, struct obd_uuid *uuidp,
 
 	tgt_obd = class_find_client_obd(uuidp, LUSTRE_OSC_NAME,
 					&obd->obd_uuid);
-	if (tgt_obd == NULL)
+	if (!tgt_obd)
 		return -EINVAL;
 
 	mutex_lock(&lov->lov_lock);
 
-	if ((index < lov->lov_tgt_size) && (lov->lov_tgts[index] != NULL)) {
+	if ((index < lov->lov_tgt_size) && lov->lov_tgts[index]) {
 		tgt = lov->lov_tgts[index];
 		CERROR("UUID %s already assigned at LOV target index %d\n",
 		       obd_uuid2str(&tgt->ltd_uuid), index);
@@ -543,7 +543,7 @@ static int lov_add_target(struct obd_device *obd, struct obd_uuid *uuidp,
 		while (newsize < index + 1)
 			newsize <<= 1;
 		newtgts = kcalloc(newsize, sizeof(*newtgts), GFP_NOFS);
-		if (newtgts == NULL) {
+		if (!newtgts) {
 			mutex_unlock(&lov->lov_lock);
 			return -ENOMEM;
 		}
@@ -613,7 +613,7 @@ static int lov_add_target(struct obd_device *obd, struct obd_uuid *uuidp,
 		goto out;
 	}
 
-	if (lov->lov_cache != NULL) {
+	if (lov->lov_cache) {
 		rc = obd_set_info_async(NULL, tgt->ltd_exp,
 				sizeof(KEY_CACHE_SET), KEY_CACHE_SET,
 				sizeof(struct cl_client_cache), lov->lov_cache,
@@ -981,7 +981,7 @@ static int lov_recreate(struct obd_export *exp, struct obdo *src_oa,
 
 	ost_idx = src_oa->o_nlink;
 	lsm = *ea;
-	if (lsm == NULL) {
+	if (!lsm) {
 		rc = -EINVAL;
 		goto out;
 	}
@@ -1025,8 +1025,8 @@ static int lov_create(const struct lu_env *env, struct obd_export *exp,
 	struct lov_obd *lov;
 	int rc = 0;
 
-	LASSERT(ea != NULL);
-	if (exp == NULL)
+	LASSERT(ea);
+	if (!exp)
 		return -EINVAL;
 
 	if ((src_oa->o_valid & OBD_MD_FLFLAGS) &&
@@ -1052,7 +1052,7 @@ static int lov_create(const struct lu_env *env, struct obd_export *exp,
 
 #define ASSERT_LSM_MAGIC(lsmp)						  \
 do {									    \
-	LASSERT((lsmp) != NULL);						\
+	LASSERT((lsmp));						\
 	LASSERTF(((lsmp)->lsm_magic == LOV_MAGIC_V1 ||			  \
 		 (lsmp)->lsm_magic == LOV_MAGIC_V3),			    \
 		 "%p->lsm_magic=%x\n", (lsmp), (lsmp)->lsm_magic);	      \
@@ -1105,10 +1105,9 @@ static int lov_destroy(const struct lu_env *env, struct obd_export *exp,
 		}
 	}
 
-	if (rc == 0) {
-		LASSERT(lsm_op_find(lsm->lsm_magic) != NULL);
+	if (rc == 0)
 		rc = lsm_op_find(lsm->lsm_magic)->lsm_destroy(lsm, oa, md_exp);
-	}
+
 	err = lov_fini_destroy_set(set);
 out:
 	obd_putref(exp->exp_obd);
@@ -1174,7 +1173,7 @@ static int lov_getattr_async(struct obd_export *exp, struct obd_info *oinfo,
 
 	if (!list_empty(&rqset->set_requests)) {
 		LASSERT(rc == 0);
-		LASSERT(rqset->set_interpret == NULL);
+		LASSERT(!rqset->set_interpret);
 		rqset->set_interpret = lov_getattr_interpret;
 		rqset->set_arg = (void *)lovset;
 		return rc;
@@ -1262,7 +1261,7 @@ static int lov_setattr_async(struct obd_export *exp, struct obd_info *oinfo,
 		return rc ? rc : err;
 	}
 
-	LASSERT(rqset->set_interpret == NULL);
+	LASSERT(!rqset->set_interpret);
 	rqset->set_interpret = lov_setattr_interpret;
 	rqset->set_arg = (void *)set;
 
@@ -1330,8 +1329,7 @@ static int lov_statfs_async(struct obd_export *exp, struct obd_info *oinfo,
 	struct lov_obd *lov;
 	int rc = 0;
 
-	LASSERT(oinfo != NULL);
-	LASSERT(oinfo->oi_osfs != NULL);
+	LASSERT(oinfo->oi_osfs);
 
 	lov = &obd->u.lov;
 	rc = lov_prep_statfs_set(obd, oinfo, &set);
@@ -1355,7 +1353,7 @@ static int lov_statfs_async(struct obd_export *exp, struct obd_info *oinfo,
 		return rc ? rc : err;
 	}
 
-	LASSERT(rqset->set_interpret == NULL);
+	LASSERT(!rqset->set_interpret);
 	rqset->set_interpret = lov_statfs_interpret;
 	rqset->set_arg = (void *)set;
 	return 0;
@@ -1371,7 +1369,7 @@ static int lov_statfs(const struct lu_env *env, struct obd_export *exp,
 	/* for obdclass we forbid using obd_statfs_rqset, but prefer using async
 	 * statfs requests */
 	set = ptlrpc_prep_set();
-	if (set == NULL)
+	if (!set)
 		return -ENOMEM;
 
 	oinfo.oi_osfs = osfs;
@@ -1503,7 +1501,7 @@ static int lov_iocontrol(unsigned int cmd, struct obd_export *exp, int len,
 						     &qctl->obd_uuid))
 					continue;
 
-				if (tgt->ltd_exp == NULL)
+				if (!tgt->ltd_exp)
 					return -EINVAL;
 
 				break;
@@ -1741,7 +1739,7 @@ static int lov_fiemap(struct lov_obd *lov, __u32 keylen, void *key,
 		buffer_size = fiemap_count_to_size(fm_key->fiemap.fm_extent_count);
 
 	fm_local = libcfs_kvzalloc(buffer_size, GFP_NOFS);
-	if (fm_local == NULL) {
+	if (!fm_local) {
 		rc = -ENOMEM;
 		goto out;
 	}
@@ -2072,7 +2070,7 @@ static int lov_set_info_async(const struct lu_env *env, struct obd_export *exp,
 	unsigned next_id = 0,  mds_con = 0;
 
 	incr = check_uuid = do_inactive = no_set = 0;
-	if (set == NULL) {
+	if (!set) {
 		no_set = 1;
 		set = ptlrpc_prep_set();
 		if (!set)
@@ -2095,7 +2093,7 @@ static int lov_set_info_async(const struct lu_env *env, struct obd_export *exp,
 	} else if (KEY_IS(KEY_MDS_CONN)) {
 		mds_con = 1;
 	} else if (KEY_IS(KEY_CACHE_SET)) {
-		LASSERT(lov->lov_cache == NULL);
+		LASSERT(!lov->lov_cache);
 		lov->lov_cache = val;
 		do_inactive = 1;
 	}
@@ -2329,7 +2327,7 @@ static int __init lov_init(void)
 	lov_oinfo_slab = kmem_cache_create("lov_oinfo",
 					      sizeof(struct lov_oinfo),
 					      0, SLAB_HWCACHE_ALIGN, NULL);
-	if (lov_oinfo_slab == NULL) {
+	if (!lov_oinfo_slab) {
 		lu_kmem_fini(lov_caches);
 		return -ENOMEM;
 	}
diff --git a/drivers/staging/lustre/lustre/lov/lov_object.c b/drivers/staging/lustre/lustre/lov/lov_object.c
index 3b79ebc..1922e04 100644
--- a/drivers/staging/lustre/lustre/lov/lov_object.c
+++ b/drivers/staging/lustre/lustre/lov/lov_object.c
@@ -154,7 +154,7 @@ static int lov_init_sub(const struct lu_env *env, struct lov_object *lov,
 	/* reuse ->coh_attr_guard to protect coh_parent change */
 	spin_lock(&subhdr->coh_attr_guard);
 	parent = subhdr->coh_parent;
-	if (parent == NULL) {
+	if (!parent) {
 		subhdr->coh_parent = hdr;
 		spin_unlock(&subhdr->coh_attr_guard);
 		subhdr->coh_nesting = hdr->coh_nesting + 1;
@@ -170,7 +170,7 @@ static int lov_init_sub(const struct lu_env *env, struct lov_object *lov,
 
 		spin_unlock(&subhdr->coh_attr_guard);
 		old_obj = lu_object_locate(&parent->coh_lu, &lov_device_type);
-		LASSERT(old_obj != NULL);
+		LASSERT(old_obj);
 		old_lov = cl2lov(lu2cl(old_obj));
 		if (old_lov->lo_layout_invalid) {
 			/* the object's layout has already changed but isn't
@@ -212,14 +212,14 @@ static int lov_init_raid0(const struct lu_env *env,
 			 LOV_MAGIC_V1, LOV_MAGIC_V3, lsm->lsm_magic);
 	}
 
-	LASSERT(lov->lo_lsm == NULL);
+	LASSERT(!lov->lo_lsm);
 	lov->lo_lsm = lsm_addref(lsm);
 	r0->lo_nr  = lsm->lsm_stripe_count;
 	LASSERT(r0->lo_nr <= lov_targets_nr(dev));
 
 	r0->lo_sub = libcfs_kvzalloc(r0->lo_nr * sizeof(r0->lo_sub[0]),
 				     GFP_NOFS);
-	if (r0->lo_sub != NULL) {
+	if (r0->lo_sub) {
 		result = 0;
 		subconf->coc_inode = conf->coc_inode;
 		spin_lock_init(&r0->lo_sub_lock);
@@ -241,7 +241,7 @@ static int lov_init_raid0(const struct lu_env *env,
 
 			subdev = lovsub2cl_dev(dev->ld_target[ost_idx]);
 			subconf->u.coc_oinfo = oinfo;
-			LASSERTF(subdev != NULL, "not init ost %d\n", ost_idx);
+			LASSERTF(subdev, "not init ost %d\n", ost_idx);
 			/* In the function below, .hs_keycmp resolves to
 			 * lu_obj_hop_keycmp() */
 			/* coverity[overrun-buffer-val] */
@@ -269,9 +269,9 @@ static int lov_init_released(const struct lu_env *env,
 {
 	struct lov_stripe_md *lsm = conf->u.coc_md->lsm;
 
-	LASSERT(lsm != NULL);
+	LASSERT(lsm);
 	LASSERT(lsm_is_released(lsm));
-	LASSERT(lov->lo_lsm == NULL);
+	LASSERT(!lov->lo_lsm);
 
 	lov->lo_lsm = lsm_addref(lsm);
 	return 0;
@@ -332,7 +332,7 @@ static void lov_subobject_kill(const struct lu_env *env, struct lov_object *lov,
 		}
 		remove_wait_queue(&bkt->lsb_marche_funebre, waiter);
 	}
-	LASSERT(r0->lo_sub[idx] == NULL);
+	LASSERT(!r0->lo_sub[idx]);
 }
 
 static int lov_delete_raid0(const struct lu_env *env, struct lov_object *lov,
@@ -345,11 +345,11 @@ static int lov_delete_raid0(const struct lu_env *env, struct lov_object *lov,
 	dump_lsm(D_INODE, lsm);
 
 	lov_layout_wait(env, lov);
-	if (r0->lo_sub != NULL) {
+	if (r0->lo_sub) {
 		for (i = 0; i < r0->lo_nr; ++i) {
 			struct lovsub_object *los = r0->lo_sub[i];
 
-			if (los != NULL) {
+			if (los) {
 				cl_locks_prune(env, &los->lso_cl, 1);
 				/*
 				 * If top-level object is to be evicted from
@@ -374,7 +374,7 @@ static void lov_fini_raid0(const struct lu_env *env, struct lov_object *lov,
 {
 	struct lov_layout_raid0 *r0 = &state->raid0;
 
-	if (r0->lo_sub != NULL) {
+	if (r0->lo_sub) {
 		kvfree(r0->lo_sub);
 		r0->lo_sub = NULL;
 	}
@@ -412,7 +412,7 @@ static int lov_print_raid0(const struct lu_env *env, void *cookie,
 	for (i = 0; i < r0->lo_nr; ++i) {
 		struct lu_object *sub;
 
-		if (r0->lo_sub[i] != NULL) {
+		if (r0->lo_sub[i]) {
 			sub = lovsub2lu(r0->lo_sub[i]);
 			lu_object_print(env, cookie, p, sub);
 		} else {
@@ -569,7 +569,7 @@ static const struct lov_layout_operations lov_dispatch[] = {
  */
 static enum lov_layout_type lov_type(struct lov_stripe_md *lsm)
 {
-	if (lsm == NULL)
+	if (!lsm)
 		return LLT_EMPTY;
 	if (lsm_is_released(lsm))
 		return LLT_RELEASED;
@@ -624,7 +624,7 @@ static void lov_conf_lock(struct lov_object *lov)
 {
 	LASSERT(lov->lo_owner != current);
 	down_write(&lov->lo_type_guard);
-	LASSERT(lov->lo_owner == NULL);
+	LASSERT(!lov->lo_owner);
 	lov->lo_owner = current;
 }
 
@@ -666,7 +666,7 @@ static int lov_layout_change(const struct lu_env *unused,
 
 	LASSERT(0 <= lov->lo_type && lov->lo_type < ARRAY_SIZE(lov_dispatch));
 
-	if (conf->u.coc_md != NULL)
+	if (conf->u.coc_md)
 		llt = lov_type(conf->u.coc_md->lsm);
 	LASSERT(0 <= llt && llt < ARRAY_SIZE(lov_dispatch));
 
@@ -689,7 +689,7 @@ static int lov_layout_change(const struct lu_env *unused,
 		old_ops->llo_fini(env, lov, &lov->u);
 
 		LASSERT(atomic_read(&lov->lo_active_ios) == 0);
-		LASSERT(hdr->coh_tree.rnode == NULL);
+		LASSERT(!hdr->coh_tree.rnode);
 		LASSERT(hdr->coh_pages == 0);
 
 		lov->lo_type = LLT_EMPTY;
@@ -767,10 +767,10 @@ static int lov_conf_set(const struct lu_env *env, struct cl_object *obj,
 
 	LASSERT(conf->coc_opc == OBJECT_CONF_SET);
 
-	if (conf->u.coc_md != NULL)
+	if (conf->u.coc_md)
 		lsm = conf->u.coc_md->lsm;
-	if ((lsm == NULL && lov->lo_lsm == NULL) ||
-	    ((lsm != NULL && lov->lo_lsm != NULL) &&
+	if ((!lsm && !lov->lo_lsm) ||
+	    ((lsm && lov->lo_lsm) &&
 	     (lov->lo_lsm->lsm_layout_gen == lsm->lsm_layout_gen) &&
 	     (lov->lo_lsm->lsm_pattern == lsm->lsm_pattern))) {
 		/* same version of layout */
@@ -892,7 +892,7 @@ struct lu_object *lov_object_alloc(const struct lu_env *env,
 	struct lu_object  *obj;
 
 	lov = kmem_cache_alloc(lov_object_kmem, GFP_NOFS | __GFP_ZERO);
-	if (lov != NULL) {
+	if (lov) {
 		obj = lov2lu(lov);
 		lu_object_init(obj, NULL, dev);
 		lov->lo_cl.co_ops = &lov_ops;
@@ -913,7 +913,7 @@ static struct lov_stripe_md *lov_lsm_addref(struct lov_object *lov)
 	struct lov_stripe_md *lsm = NULL;
 
 	lov_conf_freeze(lov);
-	if (lov->lo_lsm != NULL) {
+	if (lov->lo_lsm) {
 		lsm = lsm_addref(lov->lo_lsm);
 		CDEBUG(D_INODE, "lsm %p addref %d/%d by %p.\n",
 			lsm, atomic_read(&lsm->lsm_refc),
@@ -928,12 +928,12 @@ struct lov_stripe_md *lov_lsm_get(struct cl_object *clobj)
 	struct lu_object *luobj;
 	struct lov_stripe_md *lsm = NULL;
 
-	if (clobj == NULL)
+	if (!clobj)
 		return NULL;
 
 	luobj = lu_object_locate(&cl_object_header(clobj)->coh_lu,
 				 &lov_device_type);
-	if (luobj != NULL)
+	if (luobj)
 		lsm = lov_lsm_addref(lu2lov(luobj));
 	return lsm;
 }
@@ -941,7 +941,7 @@ EXPORT_SYMBOL(lov_lsm_get);
 
 void lov_lsm_put(struct cl_object *unused, struct lov_stripe_md *lsm)
 {
-	if (lsm != NULL)
+	if (lsm)
 		lov_free_memmd(&lsm);
 }
 EXPORT_SYMBOL(lov_lsm_put);
@@ -953,7 +953,7 @@ int lov_read_and_clear_async_rc(struct cl_object *clob)
 
 	luobj = lu_object_locate(&cl_object_header(clob)->coh_lu,
 				 &lov_device_type);
-	if (luobj != NULL) {
+	if (luobj) {
 		struct lov_object *lov = lu2lov(luobj);
 
 		lov_conf_freeze(lov);
@@ -963,7 +963,6 @@ int lov_read_and_clear_async_rc(struct cl_object *clob)
 			int i;
 
 			lsm = lov->lo_lsm;
-			LASSERT(lsm != NULL);
 			for (i = 0; i < lsm->lsm_stripe_count; i++) {
 				struct lov_oinfo *loi = lsm->lsm_oinfo[i];
 
diff --git a/drivers/staging/lustre/lustre/lov/lov_offset.c b/drivers/staging/lustre/lustre/lov/lov_offset.c
index aa520aa..5feb2e9 100644
--- a/drivers/staging/lustre/lustre/lov/lov_offset.c
+++ b/drivers/staging/lustre/lustre/lov/lov_offset.c
@@ -55,7 +55,6 @@ u64 lov_stripe_size(struct lov_stripe_md *lsm, u64 ost_size,
 	if (ost_size == 0)
 		return 0;
 
-	LASSERT(lsm_op_find(magic) != NULL);
 	lsm_op_find(magic)->lsm_stripe_by_index(lsm, &stripeno, NULL, &swidth);
 
 	/* lov_do_div64(a, b) returns a % b, and a = a / b */
@@ -129,8 +128,6 @@ int lov_stripe_offset(struct lov_stripe_md *lsm, u64 lov_off,
 		return 0;
 	}
 
-	LASSERT(lsm_op_find(magic) != NULL);
-
 	lsm_op_find(magic)->lsm_stripe_by_index(lsm, &stripeno, &lov_off,
 						&swidth);
 
@@ -183,7 +180,6 @@ u64 lov_size_to_stripe(struct lov_stripe_md *lsm, u64 file_size,
 	if (file_size == OBD_OBJECT_EOF)
 		return OBD_OBJECT_EOF;
 
-	LASSERT(lsm_op_find(magic) != NULL);
 	lsm_op_find(magic)->lsm_stripe_by_index(lsm, &stripeno, &file_size,
 						&swidth);
 
@@ -252,7 +248,6 @@ int lov_stripe_number(struct lov_stripe_md *lsm, u64 lov_off)
 	u64 stripe_off, swidth;
 	int magic = lsm->lsm_magic;
 
-	LASSERT(lsm_op_find(magic) != NULL);
 	lsm_op_find(magic)->lsm_stripe_by_offset(lsm, NULL, &lov_off, &swidth);
 
 	stripe_off = lov_do_div64(lov_off, swidth);
diff --git a/drivers/staging/lustre/lustre/lov/lov_pack.c b/drivers/staging/lustre/lustre/lov/lov_pack.c
index a78211f..4680160 100644
--- a/drivers/staging/lustre/lustre/lov/lov_pack.c
+++ b/drivers/staging/lustre/lustre/lov/lov_pack.c
@@ -257,7 +257,7 @@ static int lov_verify_lmm(void *lmm, int lmm_bytes, __u16 *stripe_count)
 {
 	int rc;
 
-	if (lsm_op_find(le32_to_cpu(*(__u32 *)lmm)) == NULL) {
+	if (!lsm_op_find(le32_to_cpu(*(__u32 *)lmm))) {
 		CERROR("bad disk LOV MAGIC: 0x%08X; dumping LMM (size=%d):\n",
 		       le32_to_cpu(*(__u32 *)lmm), lmm_bytes);
 		CERROR("%*phN\n", lmm_bytes, lmm);
@@ -306,10 +306,9 @@ int lov_free_memmd(struct lov_stripe_md **lsmp)
 	*lsmp = NULL;
 	LASSERT(atomic_read(&lsm->lsm_refc) > 0);
 	refc = atomic_dec_return(&lsm->lsm_refc);
-	if (refc == 0) {
-		LASSERT(lsm_op_find(lsm->lsm_magic) != NULL);
+	if (refc == 0)
 		lsm_op_find(lsm->lsm_magic)->lsm_free(lsm);
-	}
+
 	return refc;
 }
 
@@ -359,7 +358,6 @@ int lov_unpackmd(struct obd_export *exp,  struct lov_stripe_md **lsmp,
 	if (!lmm)
 		return lsm_size;
 
-	LASSERT(lsm_op_find(magic) != NULL);
 	rc = lsm_op_find(magic)->lsm_unpackmd(lov, *lsmp, lmm);
 	if (rc) {
 		lov_free_memmd(lsmp);
diff --git a/drivers/staging/lustre/lustre/lov/lov_page.c b/drivers/staging/lustre/lustre/lov/lov_page.c
index 037ae91..17ae450 100644
--- a/drivers/staging/lustre/lustre/lov/lov_page.c
+++ b/drivers/staging/lustre/lustre/lov/lov_page.c
@@ -57,7 +57,7 @@ static int lov_page_invariant(const struct cl_page_slice *slice)
 	const struct cl_page  *page = slice->cpl_page;
 	const struct cl_page  *sub  = lov_sub_page(slice);
 
-	return ergo(sub != NULL,
+	return ergo(sub,
 		    page->cp_child == sub &&
 		    sub->cp_parent == page &&
 		    page->cp_state == sub->cp_state);
@@ -70,7 +70,7 @@ static void lov_page_fini(const struct lu_env *env,
 
 	LINVRNT(lov_page_invariant(slice));
 
-	if (sub != NULL) {
+	if (sub) {
 		LASSERT(sub->cp_state == CPS_FREEING);
 		lu_ref_del(&sub->cp_reference, "lov", sub->cp_parent);
 		sub->cp_parent = NULL;
@@ -151,7 +151,7 @@ static const struct cl_page_operations lov_page_ops = {
 static void lov_empty_page_fini(const struct lu_env *env,
 				struct cl_page_slice *slice)
 {
-	LASSERT(slice->cpl_page->cp_child == NULL);
+	LASSERT(!slice->cpl_page->cp_child);
 }
 
 int lov_page_init_raid0(const struct lu_env *env, struct cl_object *obj,
diff --git a/drivers/staging/lustre/lustre/lov/lov_pool.c b/drivers/staging/lustre/lustre/lov/lov_pool.c
index 470708c..b9d3622 100644
--- a/drivers/staging/lustre/lustre/lov/lov_pool.c
+++ b/drivers/staging/lustre/lustre/lov/lov_pool.c
@@ -64,7 +64,7 @@ void lov_pool_putref(struct pool_desc *pool)
 	if (atomic_dec_and_test(&pool->pool_refcount)) {
 		LASSERT(hlist_unhashed(&pool->pool_hash));
 		LASSERT(list_empty(&pool->pool_list));
-		LASSERT(pool->pool_debugfs_entry == NULL);
+		LASSERT(!pool->pool_debugfs_entry);
 		lov_ost_pool_free(&(pool->pool_rr.lqr_pool));
 		lov_ost_pool_free(&(pool->pool_obds));
 		kfree(pool);
@@ -227,7 +227,7 @@ static void *pool_proc_start(struct seq_file *s, loff_t *pos)
 		i = 0;
 		do {
 		     ptr = pool_proc_next(s, &iter, &i);
-		} while ((i < *pos) && (ptr != NULL));
+		} while ((i < *pos) && ptr);
 		return ptr;
 	}
 	return iter;
@@ -255,7 +255,7 @@ static int pool_proc_show(struct seq_file *s, void *v)
 	struct lov_tgt_desc *tgt;
 
 	LASSERTF(iter->magic == POOL_IT_MAGIC, "%08X", iter->magic);
-	LASSERT(iter->pool != NULL);
+	LASSERT(iter->pool);
 	LASSERT(iter->idx <= pool_tgt_count(iter->pool));
 
 	down_read(&pool_tgt_rw_sem(iter->pool));
@@ -304,7 +304,7 @@ int lov_ost_pool_init(struct ost_pool *op, unsigned int count)
 	init_rwsem(&op->op_rw_sem);
 	op->op_size = count;
 	op->op_array = kcalloc(op->op_size, sizeof(op->op_array[0]), GFP_NOFS);
-	if (op->op_array == NULL) {
+	if (!op->op_array) {
 		op->op_size = 0;
 		return -ENOMEM;
 	}
@@ -324,7 +324,7 @@ int lov_ost_pool_extend(struct ost_pool *op, unsigned int min_count)
 
 	new_size = max(min_count, 2 * op->op_size);
 	new = kcalloc(new_size, sizeof(op->op_array[0]), GFP_NOFS);
-	if (new == NULL)
+	if (!new)
 		return -ENOMEM;
 
 	/* copy old array to new one */
@@ -486,7 +486,7 @@ int lov_pool_del(struct obd_device *obd, char *poolname)
 
 	/* lookup and kill hash reference */
 	pool = cfs_hash_del_key(lov->lov_pools_hash_body, poolname);
-	if (pool == NULL)
+	if (!pool)
 		return -ENOENT;
 
 	if (!IS_ERR_OR_NULL(pool->pool_debugfs_entry)) {
@@ -517,7 +517,7 @@ int lov_pool_add(struct obd_device *obd, char *poolname, char *ostname)
 	lov = &(obd->u.lov);
 
 	pool = cfs_hash_lookup(lov->lov_pools_hash_body, poolname);
-	if (pool == NULL)
+	if (!pool)
 		return -ENOENT;
 
 	obd_str2uuid(&ost_uuid, ostname);
@@ -563,7 +563,7 @@ int lov_pool_remove(struct obd_device *obd, char *poolname, char *ostname)
 	lov = &(obd->u.lov);
 
 	pool = cfs_hash_lookup(lov->lov_pools_hash_body, poolname);
-	if (pool == NULL)
+	if (!pool)
 		return -ENOENT;
 
 	obd_str2uuid(&ost_uuid, ostname);
@@ -631,10 +631,10 @@ struct pool_desc *lov_find_pool(struct lov_obd *lov, char *poolname)
 	pool = NULL;
 	if (poolname[0] != '\0') {
 		pool = cfs_hash_lookup(lov->lov_pools_hash_body, poolname);
-		if (pool == NULL)
+		if (!pool)
 			CWARN("Request for an unknown pool ("LOV_POOLNAMEF")\n",
 			      poolname);
-		if ((pool != NULL) && (pool_tgt_count(pool) == 0)) {
+		if (pool && (pool_tgt_count(pool) == 0)) {
 			CWARN("Request for an empty pool ("LOV_POOLNAMEF")\n",
 			       poolname);
 			/* pool is ignored, so we remove ref on it */
diff --git a/drivers/staging/lustre/lustre/lov/lov_request.c b/drivers/staging/lustre/lustre/lov/lov_request.c
index 42deda7..6c5ae05 100644
--- a/drivers/staging/lustre/lustre/lov/lov_request.c
+++ b/drivers/staging/lustre/lustre/lov/lov_request.c
@@ -156,7 +156,7 @@ static int lov_check_and_wait_active(struct lov_obd *lov, int ost_idx)
 
 	tgt = lov->lov_tgts[ost_idx];
 
-	if (unlikely(tgt == NULL)) {
+	if (unlikely(!tgt)) {
 		rc = 0;
 		goto out;
 	}
@@ -178,7 +178,7 @@ static int lov_check_and_wait_active(struct lov_obd *lov, int ost_idx)
 				   cfs_time_seconds(1), NULL, NULL);
 
 	rc = l_wait_event(waitq, lov_check_set(lov, ost_idx), &lwi);
-	if (tgt != NULL && tgt->ltd_active)
+	if (tgt && tgt->ltd_active)
 		return 1;
 
 	return 0;
@@ -195,16 +195,14 @@ static int common_attr_done(struct lov_request_set *set)
 	struct obdo *tmp_oa;
 	int rc = 0, attrset = 0;
 
-	LASSERT(set->set_oi != NULL);
-
-	if (set->set_oi->oi_oa == NULL)
+	if (!set->set_oi->oi_oa)
 		return 0;
 
 	if (!atomic_read(&set->set_success))
 		return -EIO;
 
 	tmp_oa = kmem_cache_alloc(obdo_cachep, GFP_NOFS | __GFP_ZERO);
-	if (tmp_oa == NULL) {
+	if (!tmp_oa) {
 		rc = -ENOMEM;
 		goto out;
 	}
@@ -246,7 +244,7 @@ int lov_fini_getattr_set(struct lov_request_set *set)
 {
 	int rc = 0;
 
-	if (set == NULL)
+	if (!set)
 		return 0;
 	LASSERT(set->set_exp);
 	if (atomic_read(&set->set_completes))
@@ -312,7 +310,7 @@ int lov_prep_getattr_set(struct obd_export *exp, struct obd_info *oinfo,
 
 		req->rq_oi.oi_oa = kmem_cache_alloc(obdo_cachep,
 						    GFP_NOFS | __GFP_ZERO);
-		if (req->rq_oi.oi_oa == NULL) {
+		if (!req->rq_oi.oi_oa) {
 			kfree(req);
 			rc = -ENOMEM;
 			goto out_set;
@@ -337,7 +335,7 @@ out_set:
 
 int lov_fini_destroy_set(struct lov_request_set *set)
 {
-	if (set == NULL)
+	if (!set)
 		return 0;
 	LASSERT(set->set_exp);
 	if (atomic_read(&set->set_completes)) {
@@ -368,7 +366,7 @@ int lov_prep_destroy_set(struct obd_export *exp, struct obd_info *oinfo,
 	set->set_oi->oi_md = lsm;
 	set->set_oi->oi_oa = src_oa;
 	set->set_oti = oti;
-	if (oti != NULL && src_oa->o_valid & OBD_MD_FLCOOKIE)
+	if (oti && src_oa->o_valid & OBD_MD_FLCOOKIE)
 		set->set_cookies = oti->oti_logcookies;
 
 	for (i = 0; i < lsm->lsm_stripe_count; i++) {
@@ -395,7 +393,7 @@ int lov_prep_destroy_set(struct obd_export *exp, struct obd_info *oinfo,
 
 		req->rq_oi.oi_oa = kmem_cache_alloc(obdo_cachep,
 						    GFP_NOFS | __GFP_ZERO);
-		if (req->rq_oi.oi_oa == NULL) {
+		if (!req->rq_oi.oi_oa) {
 			kfree(req);
 			rc = -ENOMEM;
 			goto out_set;
@@ -419,7 +417,7 @@ int lov_fini_setattr_set(struct lov_request_set *set)
 {
 	int rc = 0;
 
-	if (set == NULL)
+	if (!set)
 		return 0;
 	LASSERT(set->set_exp);
 	if (atomic_read(&set->set_completes)) {
@@ -486,7 +484,7 @@ int lov_prep_setattr_set(struct obd_export *exp, struct obd_info *oinfo,
 	set->set_exp = exp;
 	set->set_oti = oti;
 	set->set_oi = oinfo;
-	if (oti != NULL && oinfo->oi_oa->o_valid & OBD_MD_FLCOOKIE)
+	if (oti && oinfo->oi_oa->o_valid & OBD_MD_FLCOOKIE)
 		set->set_cookies = oti->oti_logcookies;
 
 	for (i = 0; i < oinfo->oi_md->lsm_stripe_count; i++) {
@@ -511,7 +509,7 @@ int lov_prep_setattr_set(struct obd_export *exp, struct obd_info *oinfo,
 
 		req->rq_oi.oi_oa = kmem_cache_alloc(obdo_cachep,
 						    GFP_NOFS | __GFP_ZERO);
-		if (req->rq_oi.oi_oa == NULL) {
+		if (!req->rq_oi.oi_oa) {
 			kfree(req);
 			rc = -ENOMEM;
 			goto out_set;
@@ -581,7 +579,7 @@ int lov_fini_statfs_set(struct lov_request_set *set)
 {
 	int rc = 0;
 
-	if (set == NULL)
+	if (!set)
 		return 0;
 
 	if (atomic_read(&set->set_completes)) {
@@ -718,7 +716,7 @@ int lov_prep_statfs_set(struct obd_device *obd, struct obd_info *oinfo,
 	for (i = 0; i < lov->desc.ld_tgt_count; i++) {
 		struct lov_request *req;
 
-		if (lov->lov_tgts[i] == NULL ||
+		if (!lov->lov_tgts[i] ||
 		    (!lov_check_and_wait_active(lov, i) &&
 		     (oinfo->oi_flags & OBD_STATFS_NODELAY))) {
 			CDEBUG(D_HA, "lov idx %d inactive\n", i);
diff --git a/drivers/staging/lustre/lustre/lov/lovsub_dev.c b/drivers/staging/lustre/lustre/lov/lovsub_dev.c
index f1795c3..233740c 100644
--- a/drivers/staging/lustre/lustre/lov/lovsub_dev.c
+++ b/drivers/staging/lustre/lustre/lov/lovsub_dev.c
@@ -101,7 +101,6 @@ static int lovsub_device_init(const struct lu_env *env, struct lu_device *d,
 
 	next->ld_site = d->ld_site;
 	ldt = next->ld_type;
-	LASSERT(ldt != NULL);
 	rc = ldt->ldt_ops->ldto_device_init(env, next, ldt->ldt_name, NULL);
 	if (rc) {
 		next->ld_site = NULL;
@@ -149,7 +148,7 @@ static int lovsub_req_init(const struct lu_env *env, struct cl_device *dev,
 	int result;
 
 	lsr = kmem_cache_alloc(lovsub_req_kmem, GFP_NOFS | __GFP_ZERO);
-	if (lsr != NULL) {
+	if (lsr) {
 		cl_req_slice_add(req, &lsr->lsrq_cl, dev, &lovsub_req_ops);
 		result = 0;
 	} else
@@ -175,7 +174,7 @@ static struct lu_device *lovsub_device_alloc(const struct lu_env *env,
 	struct lovsub_device *lsd;
 
 	lsd = kzalloc(sizeof(*lsd), GFP_NOFS);
-	if (lsd != NULL) {
+	if (lsd) {
 		int result;
 
 		result = cl_device_init(&lsd->acid_cl, t);
diff --git a/drivers/staging/lustre/lustre/lov/lovsub_lock.c b/drivers/staging/lustre/lustre/lov/lovsub_lock.c
index 1a3e30a..bd38736 100644
--- a/drivers/staging/lustre/lustre/lov/lovsub_lock.c
+++ b/drivers/staging/lustre/lustre/lov/lovsub_lock.c
@@ -429,7 +429,7 @@ static int lovsub_lock_print(const struct lu_env *env, void *cookie,
 	list_for_each_entry(scan, &sub->lss_parents, lll_list) {
 		lov = scan->lll_super;
 		(*p)(env, cookie, "[%d %p ", scan->lll_idx, lov);
-		if (lov != NULL)
+		if (lov)
 			cl_lock_descr_print(env, cookie, p,
 					    &lov->lls_cl.cls_lock->cll_descr);
 		(*p)(env, cookie, "] ");
@@ -454,7 +454,7 @@ int lovsub_lock_init(const struct lu_env *env, struct cl_object *obj,
 	int result;
 
 	lsk = kmem_cache_alloc(lovsub_lock_kmem, GFP_NOFS | __GFP_ZERO);
-	if (lsk != NULL) {
+	if (lsk) {
 		INIT_LIST_HEAD(&lsk->lss_parents);
 		cl_lock_slice_add(lock, &lsk->lss_cl, obj, &lovsub_lock_ops);
 		result = 0;
diff --git a/drivers/staging/lustre/lustre/lov/lovsub_object.c b/drivers/staging/lustre/lustre/lov/lovsub_object.c
index 5ba5ee1..0a9bf51 100644
--- a/drivers/staging/lustre/lustre/lov/lovsub_object.c
+++ b/drivers/staging/lustre/lustre/lov/lovsub_object.c
@@ -63,7 +63,7 @@ int lovsub_object_init(const struct lu_env *env, struct lu_object *obj,
 
 	under = &dev->acid_next->cd_lu_dev;
 	below = under->ld_ops->ldo_object_alloc(env, obj->lo_header, under);
-	if (below != NULL) {
+	if (below) {
 		lu_object_add(obj, below);
 		cl_object_page_init(lu2cl(obj), sizeof(struct lovsub_page));
 		result = 0;
@@ -144,7 +144,7 @@ struct lu_object *lovsub_object_alloc(const struct lu_env *env,
 	struct lu_object     *obj;
 
 	los = kmem_cache_alloc(lovsub_object_kmem, GFP_NOFS | __GFP_ZERO);
-	if (los != NULL) {
+	if (los) {
 		struct cl_object_header *hdr;
 
 		obj = lovsub2lu(los);
diff --git a/drivers/staging/lustre/lustre/lov/lproc_lov.c b/drivers/staging/lustre/lustre/lov/lproc_lov.c
index 337241d..bb81d04 100644
--- a/drivers/staging/lustre/lustre/lov/lproc_lov.c
+++ b/drivers/staging/lustre/lustre/lov/lproc_lov.c
@@ -46,7 +46,7 @@ static int lov_stripesize_seq_show(struct seq_file *m, void *v)
 	struct obd_device *dev = (struct obd_device *)m->private;
 	struct lov_desc *desc;
 
-	LASSERT(dev != NULL);
+	LASSERT(dev);
 	desc = &dev->u.lov.desc;
 	seq_printf(m, "%llu\n", desc->ld_default_stripe_size);
 	return 0;
@@ -61,7 +61,7 @@ static ssize_t lov_stripesize_seq_write(struct file *file,
 	__u64 val;
 	int rc;
 
-	LASSERT(dev != NULL);
+	LASSERT(dev);
 	desc = &dev->u.lov.desc;
 	rc = lprocfs_write_u64_helper(buffer, count, &val);
 	if (rc)
@@ -79,7 +79,7 @@ static int lov_stripeoffset_seq_show(struct seq_file *m, void *v)
 	struct obd_device *dev = (struct obd_device *)m->private;
 	struct lov_desc *desc;
 
-	LASSERT(dev != NULL);
+	LASSERT(dev);
 	desc = &dev->u.lov.desc;
 	seq_printf(m, "%llu\n", desc->ld_default_stripe_offset);
 	return 0;
@@ -94,7 +94,7 @@ static ssize_t lov_stripeoffset_seq_write(struct file *file,
 	__u64 val;
 	int rc;
 
-	LASSERT(dev != NULL);
+	LASSERT(dev);
 	desc = &dev->u.lov.desc;
 	rc = lprocfs_write_u64_helper(buffer, count, &val);
 	if (rc)
@@ -111,7 +111,7 @@ static int lov_stripetype_seq_show(struct seq_file *m, void *v)
 	struct obd_device *dev = (struct obd_device *)m->private;
 	struct lov_desc *desc;
 
-	LASSERT(dev != NULL);
+	LASSERT(dev);
 	desc = &dev->u.lov.desc;
 	seq_printf(m, "%u\n", desc->ld_pattern);
 	return 0;
@@ -125,7 +125,7 @@ static ssize_t lov_stripetype_seq_write(struct file *file,
 	struct lov_desc *desc;
 	int val, rc;
 
-	LASSERT(dev != NULL);
+	LASSERT(dev);
 	desc = &dev->u.lov.desc;
 	rc = lprocfs_write_helper(buffer, count, &val);
 	if (rc)
@@ -143,7 +143,7 @@ static int lov_stripecount_seq_show(struct seq_file *m, void *v)
 	struct obd_device *dev = (struct obd_device *)m->private;
 	struct lov_desc *desc;
 
-	LASSERT(dev != NULL);
+	LASSERT(dev);
 	desc = &dev->u.lov.desc;
 	seq_printf(m, "%d\n", (__s16)(desc->ld_default_stripe_count + 1) - 1);
 	return 0;
@@ -157,7 +157,7 @@ static ssize_t lov_stripecount_seq_write(struct file *file,
 	struct lov_desc *desc;
 	int val, rc;
 
-	LASSERT(dev != NULL);
+	LASSERT(dev);
 	desc = &dev->u.lov.desc;
 	rc = lprocfs_write_helper(buffer, count, &val);
 	if (rc)
@@ -199,7 +199,7 @@ static int lov_desc_uuid_seq_show(struct seq_file *m, void *v)
 	struct obd_device *dev = (struct obd_device *)m->private;
 	struct lov_obd *lov;
 
-	LASSERT(dev != NULL);
+	LASSERT(dev);
 	lov = &dev->u.lov;
 	seq_printf(m, "%s\n", lov->desc.ld_uuid.uuid);
 	return 0;
-- 
2.1.0
