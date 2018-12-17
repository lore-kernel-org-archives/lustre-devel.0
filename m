From: James Simmons <jsimmons@infradead.org>
Date: Mon, 17 Dec 2018 11:29:43 -0500
Subject: [lustre-devel] [PATCH 09/28] lustre: lov: reduce code indentation
In-Reply-To: <1545064202-22483-1-git-send-email-jsimmons@infradead.org>
References: <1545064202-22483-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1545064202-22483-10-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Bobi Jam <bobijam@hotmail.com>

For lov_init_raid0() we check for the failure of lo_sub and return
an error rigth away. This allows us to reduce the code indentation.
The same can be done for lov_attr_get_raid0() with the test of
r0->lo_attr_valid.

Signed-off-by: Jinshan Xiong <jinshan.xiong@gmail.com>
Signed-off-by: Bobi Jam <bobijam@hotmail.com>
Signed-off-by: Niu Yawei <yawei.niu@intel.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-8998
Reviewed-on: https://review.whamcloud.com/24850
Reviewed-by: Lai Siyao <lai.siyao@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/lov/lov_io.c     |  11 +-
 drivers/staging/lustre/lustre/lov/lov_object.c | 186 ++++++++++++-------------
 2 files changed, 96 insertions(+), 101 deletions(-)

diff --git a/drivers/staging/lustre/lustre/lov/lov_io.c b/drivers/staging/lustre/lustre/lov/lov_io.c
index 023b588..6dd5639 100644
--- a/drivers/staging/lustre/lustre/lov/lov_io.c
+++ b/drivers/staging/lustre/lustre/lov/lov_io.c
@@ -948,12 +948,13 @@ int lov_io_init_composite(const struct lu_env *env, struct cl_object *obj,
 
 	INIT_LIST_HEAD(&lio->lis_active);
 	io->ci_result = lov_io_slice_init(lio, lov, io);
+	if (io->ci_result)
+		return io->ci_result;
+
+	io->ci_result = lov_io_subio_init(env, lio, io);
 	if (io->ci_result == 0) {
-		io->ci_result = lov_io_subio_init(env, lio, io);
-		if (io->ci_result == 0) {
-			cl_io_slice_add(io, &lio->lis_cl, obj, &lov_io_ops);
-			atomic_inc(&lov->lo_active_ios);
-		}
+		cl_io_slice_add(io, &lio->lis_cl, obj, &lov_io_ops);
+		atomic_inc(&lov->lo_active_ios);
 	}
 	return io->ci_result;
 }
diff --git a/drivers/staging/lustre/lustre/lov/lov_object.c b/drivers/staging/lustre/lustre/lov/lov_object.c
index f5c6da1..1ebaa23 100644
--- a/drivers/staging/lustre/lustre/lov/lov_object.c
+++ b/drivers/staging/lustre/lustre/lov/lov_object.c
@@ -228,6 +228,7 @@ static int lov_init_raid0(const struct lu_env *env, struct lov_device *dev,
 	struct lov_thread_info  *lti     = lov_env_info(env);
 	struct cl_object_conf   *subconf = &lti->lti_stripe_conf;
 	struct lu_fid	   *ofid    = &lti->lti_fid;
+	int psz;
 
 	if (lsm->lsm_magic != LOV_MAGIC_V1 && lsm->lsm_magic != LOV_MAGIC_V3) {
 		dump_lsm(D_ERROR, lsm);
@@ -238,73 +239,76 @@ static int lov_init_raid0(const struct lu_env *env, struct lov_device *dev,
 	LASSERT(!lov->lo_lsm);
 	lov->lo_lsm = lsm_addref(lsm);
 	lov->lo_layout_invalid = true;
+
+	spin_lock_init(&r0->lo_sub_lock);
 	r0->lo_nr  = lsm->lsm_entries[0]->lsme_stripe_count;
 	LASSERT(r0->lo_nr <= lov_targets_nr(dev));
 
 	r0->lo_sub = kvzalloc(r0->lo_nr * sizeof(r0->lo_sub[0]),
 				     GFP_NOFS);
-	if (r0->lo_sub) {
-		int psz = 0;
+	if (!r0->lo_sub)
+		return -ENOMEM;
 
-		result = 0;
-		subconf->coc_inode = conf->coc_inode;
-		spin_lock_init(&r0->lo_sub_lock);
-		/*
-		 * Create stripe cl_objects.
+	psz = 0;
+	result = 0;
+	subconf->coc_inode = conf->coc_inode;
+	/*
+	 * Create stripe cl_objects.
+	 */
+	for (i = 0; i < r0->lo_nr; ++i) {
+		struct cl_device *subdev;
+		struct lov_oinfo *oinfo;
+		int ost_idx;
+
+		oinfo = lsm->lsm_entries[0]->lsme_oinfo[i];
+		if (lov_oinfo_is_dummy(oinfo))
+			continue;
+
+		result = ostid_to_fid(ofid, &oinfo->loi_oi,
+				      oinfo->loi_ost_idx);
+		if (result != 0)
+			goto out;
+
+		ost_idx = oinfo->loi_ost_idx;
+		if (!dev->ld_target[ost_idx]) {
+			CERROR("%s: OST %04x is not initialized\n",
+			       lov2obd(dev->ld_lov)->obd_name, ost_idx);
+			result = -EIO;
+			goto out;
+		}
+
+		subdev = lovsub2cl_dev(dev->ld_target[ost_idx]);
+		subconf->u.coc_oinfo = oinfo;
+		LASSERTF(subdev, "not init ost %d\n", ost_idx);
+		/* In the function below, .hs_keycmp resolves to
+		 * lu_obj_hop_keycmp()
 		 */
-		for (i = 0; i < r0->lo_nr && result == 0; ++i) {
-			struct cl_device *subdev;
-			struct lov_oinfo *oinfo;
-			int ost_idx;
-
-			oinfo = lsm->lsm_entries[0]->lsme_oinfo[i];
-			if (lov_oinfo_is_dummy(oinfo))
-				continue;
-
-			result = ostid_to_fid(ofid, &oinfo->loi_oi,
-					      oinfo->loi_ost_idx);
-			if (result != 0)
-				goto out;
-
-			ost_idx = oinfo->loi_ost_idx;
-			if (!dev->ld_target[ost_idx]) {
-				CERROR("%s: OST %04x is not initialized\n",
-				lov2obd(dev->ld_lov)->obd_name, ost_idx);
-				result = -EIO;
-				goto out;
-			}
+		/* coverity[overrun-buffer-val] */
+		stripe = lov_sub_find(env, subdev, ofid, subconf);
+		if (IS_ERR(stripe)) {
+			result = PTR_ERR(stripe);
+			goto out;
+		}
 
-			subdev = lovsub2cl_dev(dev->ld_target[ost_idx]);
-			subconf->u.coc_oinfo = oinfo;
-			LASSERTF(subdev, "not init ost %d\n", ost_idx);
-			/* In the function below, .hs_keycmp resolves to
-			 * lu_obj_hop_keycmp()
-			 */
-			/* coverity[overrun-buffer-val] */
-			stripe = lov_sub_find(env, subdev, ofid, subconf);
-			if (!IS_ERR(stripe)) {
-				result = lov_init_sub(env, lov, stripe, r0, i);
-				if (result == -EAGAIN) { /* try again */
-					--i;
-					result = 0;
-					continue;
-				}
-			} else {
-				result = PTR_ERR(stripe);
-			}
+		result = lov_init_sub(env, lov, stripe, r0, i);
+		if (result == -EAGAIN) { /* try again */
+			--i;
+			result = 0;
+			continue;
+		}
 
-			if (result == 0) {
-				int sz = lov_page_slice_fixup(lov, stripe);
+		if (result == 0) {
+			int sz = lov_page_slice_fixup(lov, stripe);
 
-				LASSERT(ergo(psz > 0, psz == sz));
-				psz = sz;
-			}
+			LASSERT(ergo(psz > 0, psz == sz));
+			psz = sz;
 		}
-		if (result == 0)
-			cl_object_header(&lov->lo_cl)->coh_page_bufsize += psz;
-	} else {
-		result = -ENOMEM;
 	}
+	if (result == 0)
+		cl_object_header(&lov->lo_cl)->coh_page_bufsize += psz;
+	else
+		result = -ENOMEM;
+
 out:
 	return result;
 }
@@ -567,53 +571,43 @@ static int lov_attr_get_empty(const struct lu_env *env, struct cl_object *obj,
 static int lov_attr_get_raid0(const struct lu_env *env, struct lov_object *lov,
 			      struct cl_attr *attr, struct lov_layout_raid0 *r0)
 {
+	struct lov_stripe_md *lsm = lov->lo_lsm;
+	struct ost_lvb *lvb = &lov_env_info(env)->lti_lvb;
 	int result = 0;
+	u64 kms = 0;
 
-	/* this is called w/o holding type guard mutex, so it must be inside
-	 * an on going IO otherwise lsm may be replaced.
-	 * LU-2117: it turns out there exists one exception. For mmaped files,
-	 * the lock of those files may be requested in the other file's IO
-	 * context, and this function is called in ccc_lock_state(), it will
-	 * hit this assertion.
-	 * Anyway, it's still okay to call attr_get w/o type guard as layout
-	 * can't go if locks exist.
-	 */
-	/* LASSERT(atomic_read(&lsm->lsm_refc) > 1); */
+	if (r0->lo_attr_valid)
+		return 0;
 
-	if (!r0->lo_attr_valid) {
-		struct lov_stripe_md    *lsm = lov->lo_lsm;
-		struct ost_lvb	  *lvb = &lov_env_info(env)->lti_lvb;
-		__u64		    kms = 0;
+	memset(lvb, 0, sizeof(*lvb));
+	/* XXX: timestamps can be negative by sanity:test_39m,
+	 * how can it be?
+	 */
+	lvb->lvb_atime = LLONG_MIN;
+	lvb->lvb_ctime = LLONG_MIN;
+	lvb->lvb_mtime = LLONG_MIN;
 
-		memset(lvb, 0, sizeof(*lvb));
-		/* XXX: timestamps can be negative by sanity:test_39m,
-		 * how can it be?
-		 */
-		lvb->lvb_atime = LLONG_MIN;
-		lvb->lvb_ctime = LLONG_MIN;
-		lvb->lvb_mtime = LLONG_MIN;
+	/*
+	 * XXX that should be replaced with a loop over sub-objects,
+	 * doing cl_object_attr_get() on them. But for now, let's
+	 * reuse old lov code.
+	 */
 
-		/*
-		 * XXX that should be replaced with a loop over sub-objects,
-		 * doing cl_object_attr_get() on them. But for now, let's
-		 * reuse old lov code.
-		 */
+	/*
+	 * XXX take lsm spin-lock to keep lov_merge_lvb_kms()
+	 * happy. It's not needed, because new code uses
+	 * ->coh_attr_guard spin-lock to protect consistency of
+	 * sub-object attributes.
+	 */
+	lov_stripe_lock(lsm);
+	result = lov_merge_lvb_kms(lsm, lvb, &kms);
+	lov_stripe_unlock(lsm);
+	if (result)
+		return result;
 
-		/*
-		 * XXX take lsm spin-lock to keep lov_merge_lvb_kms()
-		 * happy. It's not needed, because new code uses
-		 * ->coh_attr_guard spin-lock to protect consistency of
-		 * sub-object attributes.
-		 */
-		lov_stripe_lock(lsm);
-		result = lov_merge_lvb_kms(lsm, lvb, &kms);
-		lov_stripe_unlock(lsm);
-		if (result == 0) {
-			cl_lvb2attr(attr, lvb);
-			attr->cat_kms = kms;
-			r0->lo_attr_valid = 1;
-		}
-	}
+	cl_lvb2attr(attr, lvb);
+	attr->cat_kms = kms;
+	r0->lo_attr_valid = 1;
 
 	return result;
 }
-- 
1.8.3.1
