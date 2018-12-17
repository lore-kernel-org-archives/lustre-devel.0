From: James Simmons <jsimmons@infradead.org>
Date: Mon, 17 Dec 2018 11:29:48 -0500
Subject: [lustre-devel] [PATCH 14/28] lustre: lov: create lov_comp_* wrappers
In-Reply-To: <1545064202-22483-1-git-send-email-jsimmons@infradead.org>
References: <1545064202-22483-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1545064202-22483-15-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Bobi Jam <bobijam@hotmail.com>

Add new lov_comp_*() wrappers to get the index, stripe, and
entries for PFL components.

Signed-off-by: Jinshan Xiong <jinshan.xiong@gmail.com>
Signed-off-by: Bobi Jam <bobijam@hotmail.com>
Signed-off-by: Niu Yawei <yawei.niu@intel.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-8998
Reviewed-on: https://review.whamcloud.com/24850
Reviewed-by: Lai Siyao <lai.siyao@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/lov/lov_internal.h  | 15 ++++++++++++++
 drivers/staging/lustre/lustre/lov/lov_io.c        | 20 ++++++++++--------
 drivers/staging/lustre/lustre/lov/lov_lock.c      |  3 ++-
 drivers/staging/lustre/lustre/lov/lov_object.c    | 25 +++++++++++++++--------
 drivers/staging/lustre/lustre/lov/lov_page.c      |  4 ++--
 drivers/staging/lustre/lustre/lov/lovsub_object.c |  9 ++++----
 6 files changed, 52 insertions(+), 24 deletions(-)

diff --git a/drivers/staging/lustre/lustre/lov/lov_internal.h b/drivers/staging/lustre/lustre/lov/lov_internal.h
index ebe5890..ef47c67 100644
--- a/drivers/staging/lustre/lustre/lov/lov_internal.h
+++ b/drivers/staging/lustre/lustre/lov/lov_internal.h
@@ -79,6 +79,21 @@ static inline bool lsm_has_objects(struct lov_stripe_md *lsm)
 	return lsm && !lsm->lsm_is_released;
 }
 
+static inline unsigned int lov_comp_index(int entry, int stripe)
+{
+	return stripe;
+}
+
+static inline int lov_comp_stripe(int index)
+{
+	return index & 0xffff;
+}
+
+static inline int lov_comp_entry(int index)
+{
+	return 0;
+}
+
 struct lsm_operations {
 	struct lov_stripe_md *(*lsm_unpackmd)(struct lov_obd *obd, void *buf,
 					      size_t buf_len);
diff --git a/drivers/staging/lustre/lustre/lov/lov_io.c b/drivers/staging/lustre/lustre/lov/lov_io.c
index 7fdbed9..635e5a6 100644
--- a/drivers/staging/lustre/lustre/lov/lov_io.c
+++ b/drivers/staging/lustre/lustre/lov/lov_io.c
@@ -72,8 +72,8 @@ static int lov_io_sub_init(const struct lu_env *env, struct lov_io *lio,
 	struct cl_io      *sub_io;
 	struct cl_object  *sub_obj;
 	struct cl_io      *io  = lio->lis_cl.cis_io;
-	int stripe = sub->sub_subio_index;
-	int index = 0;
+	int index = lov_comp_entry(sub->sub_subio_index);
+	int stripe = lov_comp_stripe(sub->sub_subio_index);
 	int rc;
 
 	LASSERT(!sub->sub_io);
@@ -286,11 +286,13 @@ static void lov_io_fini(const struct lu_env *env, const struct cl_io_slice *ios)
 		wake_up_all(&lov->lo_waitq);
 }
 
-static void lov_io_sub_inherit(struct cl_io *io, struct lov_io *lio,
+static void lov_io_sub_inherit(struct lov_io_sub *sub, struct lov_io *lio,
 			       int stripe, loff_t start, loff_t end)
 {
+	struct cl_io *io = sub->sub_io;
 	struct lov_stripe_md *lsm = lio->lis_object->lo_lsm;
 	struct cl_io *parent = lio->lis_cl.cis_io;
+	int index = lov_comp_entry(sub->sub_subio_index);
 
 	switch (io->ci_type) {
 	case CIT_SETATTR: {
@@ -305,7 +307,8 @@ static void lov_io_sub_inherit(struct cl_io *io, struct lov_io *lio,
 		if (cl_io_is_trunc(io)) {
 			loff_t new_size = parent->u.ci_setattr.sa_attr.lvb_size;
 
-			new_size = lov_size_to_stripe(lsm, 0, new_size, stripe);
+			new_size = lov_size_to_stripe(lsm, index, new_size,
+						      stripe);
 			io->u.ci_setattr.sa_attr.lvb_size = new_size;
 		}
 		break;
@@ -321,7 +324,7 @@ static void lov_io_sub_inherit(struct cl_io *io, struct lov_io *lio,
 		loff_t off = cl_offset(obj, parent->u.ci_fault.ft_index);
 
 		io->u.ci_fault = parent->u.ci_fault;
-		off = lov_size_to_stripe(lsm, 0, off, stripe);
+		off = lov_size_to_stripe(lsm, index, off, stripe);
 		io->u.ci_fault.ft_index = cl_index(obj, off);
 		break;
 	}
@@ -401,13 +404,14 @@ static int lov_io_iter_init(const struct lu_env *env,
 			}
 
 			end = lov_offset_mod(end, 1);
-			sub = lov_sub_get(env, lio, stripe);
+			sub = lov_sub_get(env, lio,
+					  lov_comp_index(index - 1, stripe));
 			if (IS_ERR(sub)) {
 				rc = PTR_ERR(sub);
 				break;
 			}
 
-			lov_io_sub_inherit(sub->sub_io, lio, stripe, start, end);
+			lov_io_sub_inherit(sub, lio, stripe, start, end);
 			rc = cl_io_iter_init(sub->sub_env, sub->sub_io);
 			if (rc) {
 				cl_io_iter_fini(sub->sub_env, sub->sub_io);
@@ -588,7 +592,7 @@ static int lov_io_read_ahead(const struct lu_env *env,
 	if (unlikely(!r0->lo_sub[stripe]))
 		return -EIO;
 
-	sub = lov_sub_get(env, lio, stripe);
+	sub = lov_sub_get(env, lio, lov_comp_index(index, stripe));
 	if (IS_ERR(sub))
 		return PTR_ERR(sub);
 
diff --git a/drivers/staging/lustre/lustre/lov/lov_lock.c b/drivers/staging/lustre/lustre/lov/lov_lock.c
index 36c9eb7..cc08e96 100644
--- a/drivers/staging/lustre/lustre/lov/lov_lock.c
+++ b/drivers/staging/lustre/lustre/lov/lov_lock.c
@@ -168,7 +168,8 @@ static struct lov_lock *lov_lock_sub_init(const struct lu_env *env,
 			descr->cld_mode  = lock->cll_descr.cld_mode;
 			descr->cld_gid   = lock->cll_descr.cld_gid;
 			descr->cld_enq_flags = lock->cll_descr.cld_enq_flags;
-			lls->sub_index = i;
+
+			lls->sub_index = lov_comp_index(index, i);
 
 			/* initialize sub lock */
 			result = lov_sublock_init(env, lock, lls);
diff --git a/drivers/staging/lustre/lustre/lov/lov_object.c b/drivers/staging/lustre/lustre/lov/lov_object.c
index 8fd92a0..38258ce 100644
--- a/drivers/staging/lustre/lustre/lov/lov_object.c
+++ b/drivers/staging/lustre/lustre/lov/lov_object.c
@@ -132,6 +132,8 @@ static int lov_init_sub(const struct lu_env *env, struct lov_object *lov,
 			struct cl_object *subobj, struct lov_layout_raid0 *r0,
 			int idx)
 {
+	int stripe = lov_comp_stripe(idx);
+	int entry = lov_comp_entry(idx);
 	struct cl_object_header *hdr;
 	struct cl_object_header *subhdr;
 	struct cl_object_header *parent;
@@ -154,8 +156,9 @@ static int lov_init_sub(const struct lu_env *env, struct lov_object *lov,
 	subhdr = cl_object_header(subobj);
 
 	oinfo = lov->lo_lsm->lsm_entries[0]->lsme_oinfo[idx];
-	CDEBUG(D_INODE, DFID "@%p[%d] -> " DFID "@%p: ostid: " DOSTID " idx: %d gen: %d\n",
-	       PFID(&subhdr->coh_lu.loh_fid), subhdr, idx,
+	CDEBUG(D_INODE,
+	       DFID "@%p[%d:%d] -> " DFID "@%p: ostid: " DOSTID " ost idx: %d gen: %d\n",
+	       PFID(&subhdr->coh_lu.loh_fid), subhdr, entry, stripe,
 	       PFID(&hdr->coh_lu.loh_fid), hdr, POSTID(&oinfo->loi_oi),
 	       oinfo->loi_ost_idx, oinfo->loi_ost_gen);
 
@@ -167,9 +170,9 @@ static int lov_init_sub(const struct lu_env *env, struct lov_object *lov,
 		spin_unlock(&subhdr->coh_attr_guard);
 		subhdr->coh_nesting = hdr->coh_nesting + 1;
 		lu_object_ref_add(&subobj->co_lu, "lov-parent", lov);
-		r0->lo_sub[idx] = cl2lovsub(subobj);
-		r0->lo_sub[idx]->lso_super = lov;
-		r0->lo_sub[idx]->lso_index = idx;
+		r0->lo_sub[stripe] = cl2lovsub(subobj);
+		r0->lo_sub[stripe]->lso_super = lov;
+		r0->lo_sub[stripe]->lso_index = idx;
 		result = 0;
 	} else {
 		struct lu_object  *old_obj;
@@ -279,7 +282,8 @@ static int lov_init_raid0(const struct lu_env *env, struct lov_device *dev,
 			goto out;
 		}
 
-		result = lov_init_sub(env, lov, stripe, r0, i);
+		result = lov_init_sub(env, lov, stripe, r0,
+				      lov_comp_index(index, i));
 		if (result == -EAGAIN) { /* try again */
 			--i;
 			result = 0;
@@ -354,14 +358,15 @@ static int lov_init_released(const struct lu_env *env, struct lov_device *dev,
 static struct cl_object *lov_find_subobj(const struct lu_env *env,
 					 struct lov_object *lov,
 					 struct lov_stripe_md *lsm,
-					 int stripe_idx)
+					 int index)
 {
 	struct lov_device *dev = lu2lov_dev(lov2lu(lov)->lo_dev);
-	struct lov_oinfo *oinfo = lsm->lsm_entries[0]->lsme_oinfo[stripe_idx];
 	struct lov_thread_info *lti = lov_env_info(env);
 	struct lu_fid *ofid = &lti->lti_fid;
+	int stripe = lov_comp_stripe(index);
 	struct cl_device *subdev;
 	struct cl_object *result;
+	struct lov_oinfo *oinfo;
 	int ost_idx;
 	int rc;
 
@@ -370,6 +375,7 @@ static struct cl_object *lov_find_subobj(const struct lu_env *env,
 		goto out;
 	}
 
+	oinfo = lsm->lsm_entries[0]->lsme_oinfo[stripe];
 	ost_idx = oinfo->loi_ost_idx;
 	rc = ostid_to_fid(ofid, &oinfo->loi_oi, ost_idx);
 	if (rc) {
@@ -1291,7 +1297,8 @@ static int fiemap_for_stripe(const struct lu_env *env, struct cl_object *obj,
 	len_mapped_single_call = 0;
 
 	/* find lobsub object */
-	subobj = lov_find_subobj(env, cl2lov(obj), lsm, stripeno);
+	subobj = lov_find_subobj(env, cl2lov(obj), lsm,
+				 lov_comp_index(index, stripeno));
 	if (IS_ERR(subobj))
 		return PTR_ERR(subobj);
 	/* If the output buffer is very large and the objects have many
diff --git a/drivers/staging/lustre/lustre/lov/lov_page.c b/drivers/staging/lustre/lustre/lov/lov_page.c
index ad34fc3..e227279 100644
--- a/drivers/staging/lustre/lustre/lov/lov_page.c
+++ b/drivers/staging/lustre/lustre/lov/lov_page.c
@@ -87,10 +87,10 @@ int lov_page_init_composite(const struct lu_env *env, struct cl_object *obj,
 	rc = lov_stripe_offset(loo->lo_lsm, entry, offset, stripe, &suboff);
 	LASSERT(rc == 0);
 
-	lpg->lps_index = stripe;
+	lpg->lps_index = lov_comp_index(entry, stripe);
 	cl_page_slice_add(page, &lpg->lps_cl, obj, index, &lov_comp_page_ops);
 
-	sub = lov_sub_get(env, lio, stripe);
+	sub = lov_sub_get(env, lio, lpg->lps_index);
 	if (IS_ERR(sub))
 		return PTR_ERR(sub);
 
diff --git a/drivers/staging/lustre/lustre/lov/lovsub_object.c b/drivers/staging/lustre/lustre/lov/lovsub_object.c
index cd7806b..ca7c8a0 100644
--- a/drivers/staging/lustre/lustre/lov/lovsub_object.c
+++ b/drivers/staging/lustre/lustre/lov/lovsub_object.c
@@ -79,8 +79,8 @@ static void lovsub_object_free(const struct lu_env *env, struct lu_object *obj)
 	 * object handling in lu_object_find.
 	 */
 	if (lov) {
-		int index = 0;
-		int stripe = los->lso_index;
+		int index = lov_comp_entry(los->lso_index);
+		int stripe = lov_comp_stripe(los->lso_index);
 		struct lov_layout_raid0 *r0 = lov_r0(lov, index);
 
 		LASSERT(lov->lo_type == LLT_COMP);
@@ -107,8 +107,9 @@ static int lovsub_attr_update(const struct lu_env *env, struct cl_object *obj,
 			      const struct cl_attr *attr, unsigned int valid)
 {
 	struct lov_object *lov = cl2lovsub(obj)->lso_super;
+	struct lovsub_object *los = cl2lovsub(obj);
 
-	lov_r0(lov, 0)->lo_attr_valid = 0;
+	lov_r0(lov, lov_comp_entry(los->lso_index))->lo_attr_valid = 0;
 	return 0;
 }
 
@@ -137,7 +138,7 @@ static void lovsub_req_attr_set(const struct lu_env *env, struct cl_object *obj,
 	 * There is no OBD_MD_* flag for obdo::o_stripe_idx, so set it
 	 * unconditionally. It never changes anyway.
 	 */
-	attr->cra_oa->o_stripe_idx = subobj->lso_index;
+	attr->cra_oa->o_stripe_idx = lov_comp_stripe(subobj->lso_index);
 }
 
 static const struct cl_object_operations lovsub_ops = {
-- 
1.8.3.1
