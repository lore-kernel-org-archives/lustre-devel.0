From: James Simmons <jsimmons@infradead.org>
Date: Mon, 17 Dec 2018 11:29:47 -0500
Subject: [lustre-devel] [PATCH 13/28] lustre: lov: add looping
 lsm_entry_count times
In-Reply-To: <1545064202-22483-1-git-send-email-jsimmons@infradead.org>
References: <1545064202-22483-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1545064202-22483-14-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Bobi Jam <bobijam@hotmail.com>

Create lov_for_each_layout_entry() and lov_lse() to handle when
lsm_entry_count will be greater than one. Modifiy various code
blocks to loop lsm_entry_count times.

Signed-off-by: Jinshan Xiong <jinshan.xiong@gmail.com>
Signed-off-by: Bobi Jam <bobijam@hotmail.com>
Signed-off-by: Niu Yawei <yawei.niu@intel.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-8998
Reviewed-on: https://review.whamcloud.com/24850
Reviewed-by: Lai Siyao <lai.siyao@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/lustre/lov/lov_cl_internal.h    |  13 +++
 drivers/staging/lustre/lustre/lov/lov_ea.c         |  20 +++-
 drivers/staging/lustre/lustre/lov/lov_io.c         |  88 +++++++++-------
 drivers/staging/lustre/lustre/lov/lov_merge.c      |   6 +-
 drivers/staging/lustre/lustre/lov/lov_object.c     | 116 +++++++++++++--------
 5 files changed, 156 insertions(+), 87 deletions(-)

diff --git a/drivers/staging/lustre/lustre/lov/lov_cl_internal.h b/drivers/staging/lustre/lustre/lov/lov_cl_internal.h
index ce32823..952da3a 100644
--- a/drivers/staging/lustre/lustre/lov/lov_cl_internal.h
+++ b/drivers/staging/lustre/lustre/lov/lov_cl_internal.h
@@ -235,6 +235,11 @@ struct lov_object {
 	struct task_struct	*lo_owner;
 };
 
+#define lov_foreach_layout_entry(lov, entry)				\
+	for (entry = &lov->u.composite.lo_entries[0];			\
+	     entry < &lov->u.composite.lo_entries[lov->u.composite.lo_entry_count];\
+	     entry++)
+
 /**
  * State lov_lock keeps for each sub-lock.
  */
@@ -642,6 +647,14 @@ static inline struct lov_layout_raid0 *lov_r0(struct lov_object *lov, int i)
 	return &lov->u.composite.lo_entries[i].lle_raid0;
 }
 
+static inline struct lov_stripe_md_entry *lov_lse(struct lov_object *lov, int i)
+{
+	LASSERT(lov->lo_lsm);
+	LASSERT(i < lov->lo_lsm->lsm_entry_count);
+
+	return lov->lo_lsm->lsm_entries[i];
+}
+
 /* lov_pack.c */
 int lov_getstripe(struct lov_object *obj, struct lov_stripe_md *lsm,
 		  struct lov_user_md __user *lump);
diff --git a/drivers/staging/lustre/lustre/lov/lov_ea.c b/drivers/staging/lustre/lustre/lov/lov_ea.c
index f0ea895..f89284a 100644
--- a/drivers/staging/lustre/lustre/lov/lov_ea.c
+++ b/drivers/staging/lustre/lustre/lov/lov_ea.c
@@ -507,11 +507,21 @@ const struct lsm_operations *lsm_op_find(int magic)
 
 void dump_lsm(unsigned int level, const struct lov_stripe_md *lsm)
 {
+	int i;
+
 	CDEBUG(level,
-	       "lsm %p, objid " DOSTID ", maxbytes %#llx, magic 0x%08X, stripe_size %u, stripe_count %u, refc: %d, layout_gen %u, pool [" LOV_POOLNAMEF "]\n",
+	       "lsm %p, objid " DOSTID ", maxbytes %#llx, magic 0x%08X, refc: %d, entry: %u, layout_gen %u\n",
 	       lsm, POSTID(&lsm->lsm_oi), lsm->lsm_maxbytes, lsm->lsm_magic,
-	       lsm->lsm_entries[0]->lsme_stripe_size,
-	       lsm->lsm_entries[0]->lsme_stripe_count,
-	       atomic_read(&lsm->lsm_refc), lsm->lsm_layout_gen,
-	       lsm->lsm_entries[0]->lsme_pool_name);
+	       atomic_read(&lsm->lsm_refc), lsm->lsm_entry_count,
+	       lsm->lsm_layout_gen);
+
+	for (i = 0; i < lsm->lsm_entry_count; i++) {
+		struct lov_stripe_md_entry *lse = lsm->lsm_entries[i];
+
+		CDEBUG(level,
+		       ": id: %u, magic 0x%08X, stripe count %u, size %u, layout_gen %u, pool: [" LOV_POOLNAMEF "]\n",
+		       lse->lsme_id, lse->lsme_magic,
+		       lse->lsme_stripe_count, lse->lsme_stripe_size,
+		       lse->lsme_layout_gen, lse->lsme_pool_name);
+	}
 }
diff --git a/drivers/staging/lustre/lustre/lov/lov_io.c b/drivers/staging/lustre/lustre/lov/lov_io.c
index ab97326..7fdbed9 100644
--- a/drivers/staging/lustre/lustre/lov/lov_io.c
+++ b/drivers/staging/lustre/lustre/lov/lov_io.c
@@ -368,46 +368,59 @@ static int lov_io_iter_init(const struct lu_env *env,
 {
 	struct lov_io	*lio = cl2lov_io(env, ios);
 	struct lov_stripe_md *lsm = lio->lis_object->lo_lsm;
+	struct lov_layout_entry *le;
 	struct lov_io_sub    *sub;
 	u64 endpos;
-	u64 start;
-	u64 end;
-	int stripe;
 	int rc = 0;
-	int index = 0;
+	int index;
 
 	endpos = lov_offset_mod(lio->lis_endpos, -1);
-	for (stripe = 0; stripe < lio->lis_stripe_count; stripe++) {
-		if (!lov_stripe_intersects(lsm, index, stripe, lio->lis_pos,
-					   endpos, &start, &end))
-			continue;
-
-		if (unlikely(!lov_r0(lio->lis_object, index)->lo_sub[stripe])) {
-			if (ios->cis_io->ci_type == CIT_READ ||
-			    ios->cis_io->ci_type == CIT_WRITE ||
-			    ios->cis_io->ci_type == CIT_FAULT)
-				return -EIO;
 
-			continue;
-		}
+	index = 0;
+	lov_foreach_layout_entry(lio->lis_object, le) {
+		struct lov_layout_raid0 *r0 = &le->lle_raid0;
+		int stripe;
+		u64 start;
+		u64 end;
+
+		index++;
+
+		for (stripe = 0; stripe < r0->lo_nr; stripe++) {
+			if (!lov_stripe_intersects(lsm, index - 1, stripe,
+						   lio->lis_pos,
+						   endpos, &start, &end))
+				continue;
+
+			if (unlikely(!r0->lo_sub[stripe])) {
+				if (ios->cis_io->ci_type == CIT_READ ||
+				    ios->cis_io->ci_type == CIT_WRITE ||
+				    ios->cis_io->ci_type == CIT_FAULT)
+					return -EIO;
+
+				continue;
+			}
+
+			end = lov_offset_mod(end, 1);
+			sub = lov_sub_get(env, lio, stripe);
+			if (IS_ERR(sub)) {
+				rc = PTR_ERR(sub);
+				break;
+			}
 
-		end = lov_offset_mod(end, 1);
-		sub = lov_sub_get(env, lio, stripe);
-		if (IS_ERR(sub)) {
-			rc = PTR_ERR(sub);
-			break;
-		}
+			lov_io_sub_inherit(sub->sub_io, lio, stripe, start, end);
+			rc = cl_io_iter_init(sub->sub_env, sub->sub_io);
+			if (rc) {
+				cl_io_iter_fini(sub->sub_env, sub->sub_io);
+				break;
+			}
 
-		lov_io_sub_inherit(sub->sub_io, lio, stripe, start, end);
-		rc = cl_io_iter_init(sub->sub_env, sub->sub_io);
-		if (rc) {
-			cl_io_iter_fini(sub->sub_env, sub->sub_io);
-			break;
-		}
-		CDEBUG(D_VFSTRACE, "shrink: %d [%llu, %llu)\n",
-		       stripe, start, end);
+			CDEBUG(D_VFSTRACE, "shrink: %d [%llu, %llu)\n",
+			       stripe, start, end);
 
-		list_add_tail(&sub->sub_linkage, &lio->lis_active);
+			list_add_tail(&sub->sub_linkage, &lio->lis_active);
+		}
+		if (rc)
+			break;
 	}
 	return rc;
 }
@@ -417,13 +430,18 @@ static int lov_io_rw_iter_init(const struct lu_env *env,
 {
 	struct lov_io	*lio = cl2lov_io(env, ios);
 	struct cl_io	 *io  = ios->cis_io;
-	struct lov_stripe_md *lsm = lio->lis_object->lo_lsm;
-	unsigned long ssize = lsm->lsm_entries[0]->lsme_stripe_size;
 	u64 start = io->u.ci_rw.crw_pos;
+	struct lov_stripe_md_entry *lse;
+	unsigned long ssize;
 	loff_t next;
+	int index = 0;
 
 	LASSERT(io->ci_type == CIT_READ || io->ci_type == CIT_WRITE);
 
+	lse = lov_lse(lio->lis_object, index);
+
+	ssize = lse->lsme_stripe_size;
+
 	/* fast path for common case. */
 	if (lio->lis_nr_subios != 1 && !cl_io_is_append(io)) {
 		lov_do_div64(start, ssize);
@@ -598,12 +616,12 @@ static int lov_io_read_ahead(const struct lu_env *env,
 	if (ra_end != CL_PAGE_EOF)
 		ra_end = lov_stripe_pgoff(loo->lo_lsm, index, ra_end, stripe);
 
-	pps = loo->lo_lsm->lsm_entries[0]->lsme_stripe_size >> PAGE_SHIFT;
+	pps = lov_lse(loo, index)->lsme_stripe_size >> PAGE_SHIFT;
 
 	CDEBUG(D_READA,
 	       DFID " max_index = %lu, pps = %u, stripe_size = %u, stripe no = %u, start index = %lu\n",
 	       PFID(lu_object_fid(lov2lu(loo))), ra_end, pps,
-	       loo->lo_lsm->lsm_entries[0]->lsme_stripe_size, stripe, start);
+	       lov_lse(loo, index)->lsme_stripe_size, stripe, start);
 
 	/* never exceed the end of the stripe */
 	ra->cra_end = min_t(pgoff_t, ra_end, start + pps - start % pps - 1);
diff --git a/drivers/staging/lustre/lustre/lov/lov_merge.c b/drivers/staging/lustre/lustre/lov/lov_merge.c
index 020795f..79edc26 100644
--- a/drivers/staging/lustre/lustre/lov/lov_merge.c
+++ b/drivers/staging/lustre/lustre/lov/lov_merge.c
@@ -44,6 +44,7 @@
 int lov_merge_lvb_kms(struct lov_stripe_md *lsm, int index,
 		      struct ost_lvb *lvb, __u64 *kms_place)
 {
+	struct lov_stripe_md_entry *lse = lsm->lsm_entries[index];
 	__u64 size = 0;
 	__u64 kms = 0;
 	__u64 blocks = 0;
@@ -59,8 +60,9 @@ int lov_merge_lvb_kms(struct lov_stripe_md *lsm, int index,
 	CDEBUG(D_INODE, "MDT ID " DOSTID " initial value: s=%llu m=%llu a=%llu c=%llu b=%llu\n",
 	       POSTID(&lsm->lsm_oi), lvb->lvb_size, lvb->lvb_mtime,
 	       lvb->lvb_atime, lvb->lvb_ctime, lvb->lvb_blocks);
-	for (i = 0; i < lsm->lsm_entries[0]->lsme_stripe_count; i++) {
-		struct lov_oinfo *loi = lsm->lsm_entries[0]->lsme_oinfo[i];
+
+	for (i = 0; i < lse->lsme_stripe_count; i++) {
+		struct lov_oinfo *loi = lse->lsme_oinfo[i];
 		u64 lov_size, tmpsize;
 
 		if (OST_LVB_IS_ERR(loi->loi_lvb.lvb_blocks)) {
diff --git a/drivers/staging/lustre/lustre/lov/lov_object.c b/drivers/staging/lustre/lustre/lov/lov_object.c
index 3677fac..8fd92a0 100644
--- a/drivers/staging/lustre/lustre/lov/lov_object.c
+++ b/drivers/staging/lustre/lustre/lov/lov_object.c
@@ -217,10 +217,11 @@ static int lov_page_slice_fixup(struct lov_object *lov,
 }
 
 static int lov_init_raid0(const struct lu_env *env, struct lov_device *dev,
-			  struct lov_object *lov, struct lov_stripe_md *lsm,
+			  struct lov_object *lov, int index,
 			  const struct cl_object_conf *conf,
 			  struct lov_layout_raid0 *r0)
 {
+	struct lov_stripe_md_entry *lse = lov_lse(lov, index);
 	struct cl_object *stripe;
 	struct lov_thread_info *lti = lov_env_info(env);
 	struct cl_object_conf *subconf = &lti->lti_stripe_conf;
@@ -230,7 +231,7 @@ static int lov_init_raid0(const struct lu_env *env, struct lov_device *dev,
 	int i;
 
 	spin_lock_init(&r0->lo_sub_lock);
-	r0->lo_nr  = lsm->lsm_entries[0]->lsme_stripe_count;
+	r0->lo_nr = lse->lsme_stripe_count;
 	LASSERT(r0->lo_nr <= lov_targets_nr(dev));
 
 	r0->lo_sub = kvzalloc(r0->lo_nr * sizeof(r0->lo_sub[0]),
@@ -245,11 +246,10 @@ static int lov_init_raid0(const struct lu_env *env, struct lov_device *dev,
 	 * Create stripe cl_objects.
 	 */
 	for (i = 0; i < r0->lo_nr; ++i) {
+		struct lov_oinfo *oinfo = lse->lsme_oinfo[i];
 		struct cl_device *subdev;
-		struct lov_oinfo *oinfo;
 		int ost_idx;
 
-		oinfo = lsm->lsm_entries[0]->lsme_oinfo[i];
 		if (lov_oinfo_is_dummy(oinfo))
 			continue;
 
@@ -324,7 +324,7 @@ static int lov_init_composite(const struct lu_env *env, struct lov_device *dev,
 	for (i = 0; i < entry_count; i++) {
 		struct lov_layout_entry *le = &comp->lo_entries[i];
 
-		result = lov_init_raid0(env, dev, lov, lsm, conf,
+		result = lov_init_raid0(env, dev, lov, i, conf,
 					&le->lle_raid0);
 		if (result < 0)
 			break;
@@ -467,13 +467,13 @@ static int lov_delete_composite(const struct lu_env *env,
 				struct lov_object *lov,
 				union lov_layout_state *state)
 {
-	struct lov_layout_composite *comp = &state->composite;
-	struct lov_layout_entry *entry = &comp->lo_entries[0];
+	struct lov_layout_entry *entry;
 
 	dump_lsm(D_INODE, lov->lo_lsm);
 
 	lov_layout_wait(env, lov);
-	lov_delete_raid0(env, lov, &entry->lle_raid0);
+	lov_foreach_layout_entry(lov, entry)
+		lov_delete_raid0(env, lov, &entry->lle_raid0);
 
 	return 0;
 }
@@ -500,9 +500,10 @@ static void lov_fini_composite(const struct lu_env *env,
 	struct lov_layout_composite *comp = &state->composite;
 
 	if (comp->lo_entries) {
-		struct lov_layout_entry *entry = &comp->lo_entries[0];
+		struct lov_layout_entry *entry;
 
-		lov_fini_raid0(env, &entry->lle_raid0);
+		lov_foreach_layout_entry(lov, entry)
+			lov_fini_raid0(env, &entry->lle_raid0);
 
 		kvfree(comp->lo_entries);
 		comp->lo_entries = NULL;
@@ -548,15 +549,24 @@ static int lov_print_composite(const struct lu_env *env, void *cookie,
 			       lu_printer_t p, const struct lu_object *o)
 {
 	struct lov_object *lov = lu2lov(o);
-	struct lov_layout_raid0	*r0 = lov_r0(lov, 0);
 	struct lov_stripe_md *lsm = lov->lo_lsm;
+	int i;
 
-	(*p)(env, cookie, "stripes: %d, %s, lsm{%p 0x%08X %d %u %u}:\n",
-	     r0->lo_nr, lov->lo_layout_invalid ? "invalid" : "valid", lsm,
+	(*p)(env, cookie, "entries: %d, %s, lsm{%p 0x%08X %d %u}:\n",
+	     lsm->lsm_entry_count,
+	     lov->lo_layout_invalid ? "invalid" : "valid", lsm,
 	     lsm->lsm_magic, atomic_read(&lsm->lsm_refc),
-	     lsm->lsm_entries[0]->lsme_stripe_count, lsm->lsm_layout_gen);
+	     lsm->lsm_layout_gen);
+
+	for (i = 0; i < lsm->lsm_entry_count; i++) {
+		struct lov_stripe_md_entry *lse = lsm->lsm_entries[i];
 
-	lov_print_raid0(env, cookie, p, r0);
+		(*p)(env, cookie, ": { 0x%08X, %u, %u, %u, %u }\n",
+		     lse->lsme_magic,
+		     lse->lsme_id, lse->lsme_layout_gen,
+		     lse->lsme_stripe_count, lse->lsme_stripe_size);
+		lov_print_raid0(env, cookie, p, lov_r0(lov, i));
+	}
 
 	return 0;
 }
@@ -589,10 +599,11 @@ static int lov_attr_get_empty(const struct lu_env *env, struct cl_object *obj,
 }
 
 static int lov_attr_get_raid0(const struct lu_env *env, struct lov_object *lov,
-			      struct cl_attr *attr, struct lov_layout_raid0 *r0)
+			      unsigned int index, struct lov_layout_raid0 *r0)
 {
 	struct lov_stripe_md *lsm = lov->lo_lsm;
 	struct ost_lvb *lvb = &lov_env_info(env)->lti_lvb;
+	struct cl_attr *attr = &r0->lo_attr;
 	int result = 0;
 	u64 kms = 0;
 
@@ -621,7 +632,7 @@ static int lov_attr_get_raid0(const struct lu_env *env, struct lov_object *lov,
 	 * sub-object attributes.
 	 */
 	lov_stripe_lock(lsm);
-	result = lov_merge_lvb_kms(lsm, 0, lvb, &kms);
+	result = lov_merge_lvb_kms(lsm, index, lvb, &kms);
 	lov_stripe_unlock(lsm);
 	if (result)
 		return result;
@@ -638,24 +649,33 @@ static int lov_attr_get_composite(const struct lu_env *env,
 				  struct cl_attr *attr)
 {
 	struct lov_object *lov = cl2lov(obj);
-	struct lov_layout_raid0 *r0 = lov_r0(lov, 0);
-	struct cl_attr *lov_attr = &r0->lo_attr;
-	int result;
+	struct lov_layout_entry *entry;
+	int result = 0;
+	int index = 0;
 
-	result = lov_attr_get_raid0(env, lov, attr, r0);
-	if (result)
-		return result;
+	attr->cat_blocks = 0;
+	attr->cat_size = 0;
+	lov_foreach_layout_entry(lov, entry) {
+		struct lov_layout_raid0 *r0 = &entry->lle_raid0;
+		struct cl_attr *lov_attr = &r0->lo_attr;
 
-	attr->cat_blocks = lov_attr->cat_blocks;
-	attr->cat_size = lov_attr->cat_size;
-	attr->cat_kms = lov_attr->cat_kms;
-	if (attr->cat_atime < lov_attr->cat_atime)
-		attr->cat_atime = lov_attr->cat_atime;
-	if (attr->cat_ctime < lov_attr->cat_ctime)
-		attr->cat_ctime = lov_attr->cat_ctime;
-	if (attr->cat_mtime < lov_attr->cat_mtime)
-		attr->cat_mtime = lov_attr->cat_mtime;
+		result = lov_attr_get_raid0(env, lov, index, r0);
+		if (result)
+			break;
 
+		/* merge results */
+		attr->cat_blocks += lov_attr->cat_blocks;
+		if (attr->cat_size < lov_attr->cat_size)
+			attr->cat_size = lov_attr->cat_size;
+		if (attr->cat_kms < lov_attr->cat_kms)
+			attr->cat_kms = lov_attr->cat_kms;
+		if (attr->cat_atime < lov_attr->cat_atime)
+			attr->cat_atime = lov_attr->cat_atime;
+		if (attr->cat_ctime < lov_attr->cat_ctime)
+			attr->cat_ctime = lov_attr->cat_ctime;
+		if (attr->cat_mtime < lov_attr->cat_mtime)
+			attr->cat_mtime = lov_attr->cat_mtime;
+	}
 	return result;
 }
 
@@ -1089,8 +1109,7 @@ static int fiemap_calc_last_stripe(struct lov_stripe_md *lsm, int index,
 		*stripe_count = lsme->lsme_stripe_count;
 	} else {
 		for (j = 0, i = start_stripe; j < lsme->lsme_stripe_count;
-		     i = (i + 1) % lsme->lsme_stripe_count,
-		     j++) {
+		     i = (i + 1) % lsme->lsme_stripe_count, j++) {
 			if (lov_stripe_intersects(lsm, index, i, fm_start, fm_end,
 						  &obd_start, &obd_end) == 0)
 				break;
@@ -1681,18 +1700,25 @@ int lov_read_and_clear_async_rc(struct cl_object *clob)
 			int i;
 
 			lsm = lov->lo_lsm;
-			for (i = 0; i < lsm->lsm_entries[0]->lsme_stripe_count;
-			     i++) {
-				struct lov_oinfo *loi;
-
-				loi = lsm->lsm_entries[0]->lsme_oinfo[i];
-				if (lov_oinfo_is_dummy(loi))
-					continue;
-
-				if (loi->loi_ar.ar_rc && !rc)
-					rc = loi->loi_ar.ar_rc;
-				loi->loi_ar.ar_rc = 0;
+			LASSERT(lsm);
+			for (i = 0; i < lsm->lsm_entry_count; i++) {
+				struct lov_stripe_md_entry *lse;
+				int j;
+
+				lse = lsm->lsm_entries[i];
+				for (j = 0; j < lse->lsme_stripe_count; j++) {
+					struct lov_oinfo *loi;
+
+					loi = lse->lsme_oinfo[i];
+					if (lov_oinfo_is_dummy(loi))
+						continue;
+
+					if (loi->loi_ar.ar_rc && !rc)
+						rc = loi->loi_ar.ar_rc;
+					loi->loi_ar.ar_rc = 0;
+				}
 			}
+			break;
 		}
 		case LLT_RELEASED:
 		case LLT_EMPTY:
-- 
1.8.3.1
