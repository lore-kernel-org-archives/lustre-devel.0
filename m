From: James Simmons <jsimmons@infradead.org>
Date: Mon, 17 Dec 2018 11:29:44 -0500
Subject: [lustre-devel] [PATCH 10/28] lustre: lov: change lo_entries to
 array.
In-Reply-To: <1545064202-22483-1-git-send-email-jsimmons@infradead.org>
References: <1545064202-22483-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1545064202-22483-11-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Bobi Jam <bobijam@hotmail.com>

Old style striping is equal to a single component. To support PFL
we need to change lo_entries to an array.

Signed-off-by: Jinshan Xiong <jinshan.xiong@gmail.com>
Signed-off-by: Bobi Jam <bobijam@hotmail.com>
Signed-off-by: Niu Yawei <yawei.niu@intel.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-8998
Reviewed-on: https://review.whamcloud.com/24850
Reviewed-by: Lai Siyao <lai.siyao@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/lustre/lov/lov_cl_internal.h    |  14 +-
 drivers/staging/lustre/lustre/lov/lov_internal.h   |  20 +--
 drivers/staging/lustre/lustre/lov/lov_io.c         |  27 ++--
 drivers/staging/lustre/lustre/lov/lov_lock.c       |  13 +-
 drivers/staging/lustre/lustre/lov/lov_merge.c      |   6 +-
 drivers/staging/lustre/lustre/lov/lov_object.c     | 149 ++++++++++++---------
 drivers/staging/lustre/lustre/lov/lov_offset.c     |  30 +++--
 drivers/staging/lustre/lustre/lov/lov_page.c       |  11 +-
 drivers/staging/lustre/lustre/lov/lovsub_object.c  |   5 +-
 9 files changed, 158 insertions(+), 117 deletions(-)

diff --git a/drivers/staging/lustre/lustre/lov/lov_cl_internal.h b/drivers/staging/lustre/lustre/lov/lov_cl_internal.h
index c44c937..99bd1c1 100644
--- a/drivers/staging/lustre/lustre/lov/lov_cl_internal.h
+++ b/drivers/staging/lustre/lustre/lov/lov_cl_internal.h
@@ -219,9 +219,13 @@ struct lov_object {
 		struct lov_layout_state_released {
 		} released;
 		struct lov_layout_composite {
+			/**
+			 * Current valid entry count of lo_entries.
+			 */
+			unsigned int lo_entry_count;
 			struct lov_layout_entry {
 				struct lov_layout_raid0 lle_raid0;
-			} lo_entries;
+			} *lo_entries;
 		} composite;
 	} u;
 	/**
@@ -628,13 +632,13 @@ static inline struct lov_thread_info *lov_env_info(const struct lu_env *env)
 	return info;
 }
 
-static inline struct lov_layout_raid0 *lov_r0(struct lov_object *lov)
+static inline struct lov_layout_raid0 *lov_r0(struct lov_object *lov, int i)
 {
 	LASSERT(lov->lo_type == LLT_COMP);
-	LASSERT(lov->lo_lsm->lsm_magic == LOV_MAGIC ||
-		lov->lo_lsm->lsm_magic == LOV_MAGIC_V3);
+	LASSERTF(i < lov->u.composite.lo_entry_count,
+		 "entry %d entry_count %d", i, lov->u.composite.lo_entry_count);
 
-	return &lov->u.composite.lo_entries.lle_raid0;
+	return &lov->u.composite.lo_entries[i].lle_raid0;
 }
 
 /* lov_pack.c */
diff --git a/drivers/staging/lustre/lustre/lov/lov_internal.h b/drivers/staging/lustre/lustre/lov/lov_internal.h
index f2747c9..4c9e324 100644
--- a/drivers/staging/lustre/lustre/lov/lov_internal.h
+++ b/drivers/staging/lustre/lustre/lov/lov_internal.h
@@ -169,20 +169,22 @@ struct lov_request_set {
 	(char *)((lv)->lov_tgts[index]->ltd_uuid.uuid)
 
 /* lov_merge.c */
-int lov_merge_lvb_kms(struct lov_stripe_md *lsm,
+int lov_merge_lvb_kms(struct lov_stripe_md *lsm, int index,
 		      struct ost_lvb *lvb, __u64 *kms_place);
 
 /* lov_offset.c */
-u64 lov_stripe_size(struct lov_stripe_md *lsm, u64 ost_size, int stripeno);
-int lov_stripe_offset(struct lov_stripe_md *lsm, u64 lov_off,
-		      int stripeno, u64 *u64);
-u64 lov_size_to_stripe(struct lov_stripe_md *lsm, u64 file_size, int stripeno);
-int lov_stripe_intersects(struct lov_stripe_md *lsm, int stripeno,
+u64 lov_stripe_size(struct lov_stripe_md *lsm, int index, u64 ost_size,
+		    int stripeno);
+int lov_stripe_offset(struct lov_stripe_md *lsm, int index, u64 lov_off,
+		      int stripeno, u64 *obd_off);
+u64 lov_size_to_stripe(struct lov_stripe_md *lsm, int index, u64 file_size,
+		       int stripeno);
+int lov_stripe_intersects(struct lov_stripe_md *lsm, int index, int stripeno,
 			  u64 start, u64 end,
 			  u64 *obd_start, u64 *obd_end);
-int lov_stripe_number(struct lov_stripe_md *lsm, u64 lov_off);
-pgoff_t lov_stripe_pgoff(struct lov_stripe_md *lsm, pgoff_t stripe_index,
-			 int stripe);
+int lov_stripe_number(struct lov_stripe_md *lsm, int index, u64 lov_off);
+pgoff_t lov_stripe_pgoff(struct lov_stripe_md *lsm, int index,
+			 pgoff_t stripe_index, int stripe);
 
 /* lov_request.c */
 int lov_prep_statfs_set(struct obd_device *obd, struct obd_info *oinfo,
diff --git a/drivers/staging/lustre/lustre/lov/lov_io.c b/drivers/staging/lustre/lustre/lov/lov_io.c
index 6dd5639..26d0043 100644
--- a/drivers/staging/lustre/lustre/lov/lov_io.c
+++ b/drivers/staging/lustre/lustre/lov/lov_io.c
@@ -85,7 +85,7 @@ static void lov_io_sub_inherit(struct cl_io *io, struct lov_io *lio,
 		if (cl_io_is_trunc(io)) {
 			loff_t new_size = parent->u.ci_setattr.sa_attr.lvb_size;
 
-			new_size = lov_size_to_stripe(lsm, new_size, stripe);
+			new_size = lov_size_to_stripe(lsm, 0, new_size, stripe);
 			io->u.ci_setattr.sa_attr.lvb_size = new_size;
 		}
 		break;
@@ -101,7 +101,7 @@ static void lov_io_sub_inherit(struct cl_io *io, struct lov_io *lio,
 		loff_t off = cl_offset(obj, parent->u.ci_fault.ft_index);
 
 		io->u.ci_fault = parent->u.ci_fault;
-		off = lov_size_to_stripe(lsm, off, stripe);
+		off = lov_size_to_stripe(lsm, 0, off, stripe);
 		io->u.ci_fault.ft_index = cl_index(obj, off);
 		break;
 	}
@@ -144,13 +144,14 @@ static int lov_io_sub_init(const struct lu_env *env, struct lov_io *lio,
 	struct cl_object  *sub_obj;
 	struct cl_io      *io  = lio->lis_cl.cis_io;
 	int stripe = sub->sub_subio_index;
+	int index = 0;
 	int rc;
 
 	LASSERT(!sub->sub_io);
 	LASSERT(!sub->sub_env);
 	LASSERT(sub->sub_subio_index < lio->lis_stripe_count);
 
-	if (unlikely(!lov_r0(lov)->lo_sub[stripe]))
+	if (unlikely(!lov_r0(lov, index)->lo_sub[stripe]))
 		return -EIO;
 
 	sub->sub_io_initialized = 0;
@@ -179,7 +180,7 @@ static int lov_io_sub_init(const struct lu_env *env, struct lov_io *lio,
 		}
 	}
 
-	sub_obj = lovsub2cl(lov_r0(lov)->lo_sub[stripe]);
+	sub_obj = lovsub2cl(lov_r0(lov, index)->lo_sub[stripe]);
 	sub_io = sub->sub_io;
 
 	sub_io->ci_obj = sub_obj;
@@ -375,14 +376,15 @@ static int lov_io_iter_init(const struct lu_env *env,
 	u64 end;
 	int stripe;
 	int rc = 0;
+	int index = 0;
 
 	endpos = lov_offset_mod(lio->lis_endpos, -1);
 	for (stripe = 0; stripe < lio->lis_stripe_count; stripe++) {
-		if (!lov_stripe_intersects(lsm, stripe, lio->lis_pos,
+		if (!lov_stripe_intersects(lsm, index, stripe, lio->lis_pos,
 					   endpos, &start, &end))
 			continue;
 
-		if (unlikely(!lov_r0(lio->lis_object)->lo_sub[stripe])) {
+		if (unlikely(!lov_r0(lio->lis_object, index)->lo_sub[stripe])) {
 			if (ios->cis_io->ci_type == CIT_READ ||
 			    ios->cis_io->ci_type == CIT_WRITE ||
 			    ios->cis_io->ci_type == CIT_FAULT)
@@ -555,15 +557,18 @@ static int lov_io_read_ahead(const struct lu_env *env,
 	struct lov_io *lio = cl2lov_io(env, ios);
 	struct lov_object *loo = lio->lis_object;
 	struct cl_object *obj = lov2cl(loo);
-	struct lov_layout_raid0 *r0 = lov_r0(loo);
+	struct lov_layout_raid0 *r0;
 	unsigned int pps; /* pages per stripe */
 	struct lov_io_sub *sub;
 	pgoff_t ra_end;
-	loff_t suboff;
+	u64 suboff;
 	int stripe;
+	int index = 0;
 	int rc;
 
-	stripe = lov_stripe_number(loo->lo_lsm, cl_offset(obj, start));
+	stripe = lov_stripe_number(loo->lo_lsm, index, cl_offset(obj, start));
+
+	r0 = lov_r0(loo, index);
 	if (unlikely(!r0->lo_sub[stripe]))
 		return -EIO;
 
@@ -571,7 +576,7 @@ static int lov_io_read_ahead(const struct lu_env *env,
 	if (IS_ERR(sub))
 		return PTR_ERR(sub);
 
-	lov_stripe_offset(loo->lo_lsm, cl_offset(obj, start), stripe, &suboff);
+	lov_stripe_offset(loo->lo_lsm, index, cl_offset(obj, start), stripe, &suboff);
 	rc = cl_io_read_ahead(sub->sub_env, sub->sub_io,
 			      cl_index(lovsub2cl(r0->lo_sub[stripe]), suboff),
 			      ra);
@@ -593,7 +598,7 @@ static int lov_io_read_ahead(const struct lu_env *env,
 	/* cra_end is stripe level, convert it into file level */
 	ra_end = ra->cra_end;
 	if (ra_end != CL_PAGE_EOF)
-		ra_end = lov_stripe_pgoff(loo->lo_lsm, ra_end, stripe);
+		ra_end = lov_stripe_pgoff(loo->lo_lsm, index, ra_end, stripe);
 
 	pps = loo->lo_lsm->lsm_entries[0]->lsme_stripe_size >> PAGE_SHIFT;
 
diff --git a/drivers/staging/lustre/lustre/lov/lov_lock.c b/drivers/staging/lustre/lustre/lov/lov_lock.c
index 4340063..36c9eb7 100644
--- a/drivers/staging/lustre/lustre/lov/lov_lock.c
+++ b/drivers/staging/lustre/lustre/lov/lov_lock.c
@@ -114,7 +114,11 @@ static struct lov_lock *lov_lock_sub_init(const struct lu_env *env,
 					  const struct cl_object *obj,
 					  struct cl_lock *lock)
 {
+	struct lov_object *loo = cl2lov(obj);
+	struct lov_layout_raid0 *r0;
+	struct lov_lock	*lovlck;
 	int result = 0;
+	int index = 0;
 	int i;
 	int nr;
 	u64 start;
@@ -122,10 +126,6 @@ static struct lov_lock *lov_lock_sub_init(const struct lu_env *env,
 	u64 file_start;
 	u64 file_end;
 
-	struct lov_object       *loo    = cl2lov(obj);
-	struct lov_layout_raid0 *r0     = lov_r0(loo);
-	struct lov_lock		*lovlck;
-
 	CDEBUG(D_INODE, "%p: lock/io FID " DFID "/" DFID ", lock/io clobj %p/%p\n",
 	       loo, PFID(lu_object_fid(lov2lu(loo))),
 	       PFID(lu_object_fid(&obj->co_lu)),
@@ -134,13 +134,14 @@ static struct lov_lock *lov_lock_sub_init(const struct lu_env *env,
 	file_start = cl_offset(lov2cl(loo), lock->cll_descr.cld_start);
 	file_end   = cl_offset(lov2cl(loo), lock->cll_descr.cld_end + 1) - 1;
 
+	r0 = lov_r0(loo, index);
 	for (i = 0, nr = 0; i < r0->lo_nr; i++) {
 		/*
 		 * XXX for wide striping smarter algorithm is desirable,
 		 * breaking out of the loop, early.
 		 */
 		if (likely(r0->lo_sub[i]) && /* spare layout */
-		    lov_stripe_intersects(loo->lo_lsm, i,
+		    lov_stripe_intersects(loo->lo_lsm, index, i,
 					  file_start, file_end, &start, &end))
 			nr++;
 	}
@@ -153,7 +154,7 @@ static struct lov_lock *lov_lock_sub_init(const struct lu_env *env,
 	lovlck->lls_nr = nr;
 	for (i = 0, nr = 0; i < r0->lo_nr; ++i) {
 		if (likely(r0->lo_sub[i]) &&
-		    lov_stripe_intersects(loo->lo_lsm, i,
+		    lov_stripe_intersects(loo->lo_lsm, index, i,
 					  file_start, file_end, &start, &end)) {
 			struct lov_lock_sub *lls = &lovlck->lls_sub[nr];
 			struct cl_lock_descr *descr;
diff --git a/drivers/staging/lustre/lustre/lov/lov_merge.c b/drivers/staging/lustre/lustre/lov/lov_merge.c
index 10b8448..020795f 100644
--- a/drivers/staging/lustre/lustre/lov/lov_merge.c
+++ b/drivers/staging/lustre/lustre/lov/lov_merge.c
@@ -41,7 +41,7 @@
  * initializes the current atime, mtime, ctime to avoid regressing a more
  * uptodate time on the local client.
  */
-int lov_merge_lvb_kms(struct lov_stripe_md *lsm,
+int lov_merge_lvb_kms(struct lov_stripe_md *lsm, int index,
 		      struct ost_lvb *lvb, __u64 *kms_place)
 {
 	__u64 size = 0;
@@ -69,14 +69,14 @@ int lov_merge_lvb_kms(struct lov_stripe_md *lsm,
 		}
 
 		tmpsize = loi->loi_kms;
-		lov_size = lov_stripe_size(lsm, tmpsize, i);
+		lov_size = lov_stripe_size(lsm, index, tmpsize, i);
 		if (lov_size > kms)
 			kms = lov_size;
 
 		if (loi->loi_lvb.lvb_size > tmpsize)
 			tmpsize = loi->loi_lvb.lvb_size;
 
-		lov_size = lov_stripe_size(lsm, tmpsize, i);
+		lov_size = lov_stripe_size(lsm, index, tmpsize, i);
 		if (lov_size > size)
 			size = lov_size;
 		/* merge blocks, mtime, atime */
diff --git a/drivers/staging/lustre/lustre/lov/lov_object.c b/drivers/staging/lustre/lustre/lov/lov_object.c
index 1ebaa23..de5e2a2 100644
--- a/drivers/staging/lustre/lustre/lov/lov_object.c
+++ b/drivers/staging/lustre/lustre/lov/lov_object.c
@@ -221,24 +221,13 @@ static int lov_init_raid0(const struct lu_env *env, struct lov_device *dev,
 			  const struct cl_object_conf *conf,
 			  struct lov_layout_raid0 *r0)
 {
+	struct cl_object *stripe;
+	struct lov_thread_info *lti = lov_env_info(env);
+	struct cl_object_conf *subconf = &lti->lti_stripe_conf;
+	struct lu_fid *ofid = &lti->lti_fid;
 	int result;
-	int i;
-
-	struct cl_object	*stripe;
-	struct lov_thread_info  *lti     = lov_env_info(env);
-	struct cl_object_conf   *subconf = &lti->lti_stripe_conf;
-	struct lu_fid	   *ofid    = &lti->lti_fid;
 	int psz;
-
-	if (lsm->lsm_magic != LOV_MAGIC_V1 && lsm->lsm_magic != LOV_MAGIC_V3) {
-		dump_lsm(D_ERROR, lsm);
-		LASSERTF(0, "magic mismatch, expected %d/%d, actual %d.\n",
-			 LOV_MAGIC_V1, LOV_MAGIC_V3, lsm->lsm_magic);
-	}
-
-	LASSERT(!lov->lo_lsm);
-	lov->lo_lsm = lsm_addref(lsm);
-	lov->lo_layout_invalid = true;
+	int i;
 
 	spin_lock_init(&r0->lo_sub_lock);
 	r0->lo_nr  = lsm->lsm_entries[0]->lsme_stripe_count;
@@ -305,10 +294,7 @@ static int lov_init_raid0(const struct lu_env *env, struct lov_device *dev,
 		}
 	}
 	if (result == 0)
-		cl_object_header(&lov->lo_cl)->coh_page_bufsize += psz;
-	else
-		result = -ENOMEM;
-
+		result = psz;
 out:
 	return result;
 }
@@ -319,9 +305,37 @@ static int lov_init_composite(const struct lu_env *env, struct lov_device *dev,
 			      union lov_layout_state *state)
 {
 	struct lov_layout_composite *comp = &state->composite;
-	struct lov_layout_entry *le = &comp->lo_entries;
+	unsigned int entry_count = 1;
+	unsigned int psz = 0;
+	int result = 0;
+	int i;
 
-	return lov_init_raid0(env, dev, lov, lsm, conf, &le->lle_raid0);
+	LASSERT(!lov->lo_lsm);
+	lov->lo_lsm = lsm_addref(lsm);
+	lov->lo_layout_invalid = true;
+
+	comp->lo_entry_count = entry_count;
+
+	comp->lo_entries = kcalloc(entry_count, sizeof(*comp->lo_entries),
+				   GFP_KERNEL);
+	if (!comp->lo_entries)
+		return -ENOMEM;
+
+	for (i = 0; i < entry_count; i++) {
+		struct lov_layout_entry *le = &comp->lo_entries[i];
+
+		result = lov_init_raid0(env, dev, lov, lsm, conf,
+					&le->lle_raid0);
+		if (result < 0)
+			break;
+
+		LASSERT(ergo(psz > 0, psz == result));
+		psz = result;
+	}
+	if (psz > 0)
+		cl_object_header(&lov->lo_cl)->coh_page_bufsize += psz;
+
+	return result > 0 ? 0 : result;
 }
 
 static int lov_init_released(const struct lu_env *env, struct lov_device *dev,
@@ -454,7 +468,7 @@ static int lov_delete_composite(const struct lu_env *env,
 				union lov_layout_state *state)
 {
 	struct lov_layout_composite *comp = &state->composite;
-	struct lov_layout_entry *entry = &comp->lo_entries;
+	struct lov_layout_entry *entry = &comp->lo_entries[0];
 
 	dump_lsm(D_INODE, lov->lo_lsm);
 
@@ -484,9 +498,15 @@ static void lov_fini_composite(const struct lu_env *env,
 			       union lov_layout_state *state)
 {
 	struct lov_layout_composite *comp = &state->composite;
-	struct lov_layout_entry *entry = &comp->lo_entries;
 
-	lov_fini_raid0(env, &entry->lle_raid0);
+	if (comp->lo_entries) {
+		struct lov_layout_entry *entry = &comp->lo_entries[0];
+
+		lov_fini_raid0(env, &entry->lle_raid0);
+
+		kvfree(comp->lo_entries);
+		comp->lo_entries = NULL;
+	}
 
 	dump_lsm(D_INODE, lov->lo_lsm);
 	lov_free_memmd(&lov->lo_lsm);
@@ -528,7 +548,7 @@ static int lov_print_composite(const struct lu_env *env, void *cookie,
 			       lu_printer_t p, const struct lu_object *o)
 {
 	struct lov_object *lov = lu2lov(o);
-	struct lov_layout_raid0	*r0 = lov_r0(lov);
+	struct lov_layout_raid0	*r0 = lov_r0(lov, 0);
 	struct lov_stripe_md *lsm = lov->lo_lsm;
 
 	(*p)(env, cookie, "stripes: %d, %s, lsm{%p 0x%08X %d %u %u}:\n",
@@ -600,7 +620,7 @@ static int lov_attr_get_raid0(const struct lu_env *env, struct lov_object *lov,
 	 * sub-object attributes.
 	 */
 	lov_stripe_lock(lsm);
-	result = lov_merge_lvb_kms(lsm, lvb, &kms);
+	result = lov_merge_lvb_kms(lsm, 0, lvb, &kms);
 	lov_stripe_unlock(lsm);
 	if (result)
 		return result;
@@ -617,7 +637,7 @@ static int lov_attr_get_composite(const struct lu_env *env,
 				  struct cl_attr *attr)
 {
 	struct lov_object *lov = cl2lov(obj);
-	struct lov_layout_raid0 *r0 = lov_r0(lov);
+	struct lov_layout_raid0 *r0 = lov_r0(lov, 0);
 	struct cl_attr *lov_attr = &r0->lo_attr;
 	int result;
 
@@ -1051,33 +1071,31 @@ int lov_lock_init(const struct lu_env *env, struct cl_object *obj,
  *
  * \retval last_stripe		return the last stripe of the mapping
  */
-static int fiemap_calc_last_stripe(struct lov_stripe_md *lsm,
+static int fiemap_calc_last_stripe(struct lov_stripe_md *lsm, int index,
 				   u64 fm_start, u64 fm_end,
 				   int start_stripe, int *stripe_count)
 {
+	struct lov_stripe_md_entry *lsme = lsm->lsm_entries[index];
 	int last_stripe;
 	u64 obd_start;
 	u64 obd_end;
 	int i, j;
 
-	if (fm_end - fm_start > lsm->lsm_entries[0]->lsme_stripe_size *
-				lsm->lsm_entries[0]->lsme_stripe_count) {
-		last_stripe = (start_stripe < 1 ?
-			       lsm->lsm_entries[0]->lsme_stripe_count - 1 :
-			       start_stripe - 1);
-		*stripe_count = lsm->lsm_entries[0]->lsme_stripe_count;
+	if (fm_end - fm_start >
+	    lsme->lsme_stripe_size * lsme->lsme_stripe_count) {
+		last_stripe = (start_stripe < 1 ? lsme->lsme_stripe_count - 1 :
+						  start_stripe - 1);
+		*stripe_count = lsme->lsme_stripe_count;
 	} else {
-		for (j = 0, i = start_stripe;
-		     j < lsm->lsm_entries[0]->lsme_stripe_count;
-		     i = (i + 1) % lsm->lsm_entries[0]->lsme_stripe_count,
+		for (j = 0, i = start_stripe; j < lsme->lsme_stripe_count;
+		     i = (i + 1) % lsme->lsme_stripe_count,
 		     j++) {
-			if (lov_stripe_intersects(lsm, i, fm_start, fm_end,
+			if (lov_stripe_intersects(lsm, index, i, fm_start, fm_end,
 						  &obd_start, &obd_end) == 0)
 				break;
 		}
 		*stripe_count = j;
-		last_stripe = (start_stripe + j - 1) %
-			      lsm->lsm_entries[0]->lsme_stripe_count;
+		last_stripe = (start_stripe + j - 1) % lsme->lsme_stripe_count;
 	}
 
 	return last_stripe;
@@ -1132,9 +1150,10 @@ static void fiemap_prepare_and_copy_exts(struct fiemap *fiemap,
  */
 static u64 fiemap_calc_fm_end_offset(struct fiemap *fiemap,
 				     struct lov_stripe_md *lsm,
-				     u64 fm_start, u64 fm_end,
+				     int index, u64 fm_start, u64 fm_end,
 				     int *start_stripe)
 {
+	struct lov_stripe_md_entry *lsme = lsm->lsm_entries[index];
 	u64 local_end = fiemap->fm_extents[0].fe_logical;
 	u64 lun_start, lun_end;
 	u64 fm_end_offset;
@@ -1145,8 +1164,8 @@ static u64 fiemap_calc_fm_end_offset(struct fiemap *fiemap,
 		return 0;
 
 	/* Find out stripe_no from ost_index saved in the fe_device */
-	for (i = 0; i < lsm->lsm_entries[0]->lsme_stripe_count; i++) {
-		struct lov_oinfo *oinfo = lsm->lsm_entries[0]->lsme_oinfo[i];
+	for (i = 0; i < lsme->lsme_stripe_count; i++) {
+		struct lov_oinfo *oinfo = lsme->lsme_oinfo[i];
 
 		if (lov_oinfo_is_dummy(oinfo))
 			continue;
@@ -1164,7 +1183,7 @@ static u64 fiemap_calc_fm_end_offset(struct fiemap *fiemap,
 	 * If we have finished mapping on previous device, shift logical
 	 * offset to start of next device
 	 */
-	if (lov_stripe_intersects(lsm, stripe_no, fm_start, fm_end,
+	if (lov_stripe_intersects(lsm, index, stripe_no, fm_start, fm_end,
 				  &lun_start, &lun_end) != 0 &&
 	    local_end < lun_end) {
 		fm_end_offset = local_end;
@@ -1174,8 +1193,7 @@ static u64 fiemap_calc_fm_end_offset(struct fiemap *fiemap,
 		 * calculate offset in next stripe.
 		 */
 		fm_end_offset = 0;
-		*start_stripe = (stripe_no + 1) %
-				lsm->lsm_entries[0]->lsme_stripe_count;
+		*start_stripe = (stripe_no + 1) % lsme->lsme_stripe_count;
 	}
 
 	return fm_end_offset;
@@ -1197,11 +1215,11 @@ struct fiemap_state {
 };
 
 static int fiemap_for_stripe(const struct lu_env *env, struct cl_object *obj,
-			     struct lov_stripe_md *lsm,
-			     struct fiemap *fiemap, size_t *buflen,
-			     struct ll_fiemap_info_key *fmkey, int stripeno,
-			     struct fiemap_state *fs)
+			     struct lov_stripe_md *lsm, struct fiemap *fiemap,
+			     size_t *buflen, struct ll_fiemap_info_key *fmkey,
+			     int index, int stripeno, struct fiemap_state *fs)
 {
+	struct lov_stripe_md_entry *lsme = lsm->lsm_entries[index];
 	struct cl_object *subobj;
 	struct lov_obd *lov = lu2lov_dev(obj->co_lu.lo_dev)->ld_lov;
 	struct fiemap_extent *fm_ext = &fs->fs_fm->fm_extents[0];
@@ -1220,11 +1238,12 @@ static int fiemap_for_stripe(const struct lu_env *env, struct cl_object *obj,
 
 	fs->fs_device_done = false;
 	/* Find out range of mapping on this stripe */
-	if ((lov_stripe_intersects(lsm, stripeno, fs->fs_start, fs->fs_end,
+	if ((lov_stripe_intersects(lsm, index, stripeno,
+				   fs->fs_start, fs->fs_end,
 				   &lun_start, &obd_object_end)) == 0)
 		return 0;
 
-	if (lov_oinfo_is_dummy(lsm->lsm_entries[0]->lsme_oinfo[stripeno]))
+	if (lov_oinfo_is_dummy(lsme->lsme_oinfo[stripeno]))
 		return -EIO;
 
 	/* If this is a continuation FIEMAP call and we are on
@@ -1239,7 +1258,8 @@ static int fiemap_for_stripe(const struct lu_env *env, struct cl_object *obj,
 		/* Handle fs->fs_start + fs->fs_length overflow */
 		if (fs->fs_start + fs->fs_length < fs->fs_start)
 			fs->fs_length = ~0ULL - fs->fs_start;
-		lun_end = lov_size_to_stripe(lsm, fs->fs_start + fs->fs_length,
+		lun_end = lov_size_to_stripe(lsm, index,
+					     fs->fs_start + fs->fs_length,
 					     stripeno);
 	}
 
@@ -1274,7 +1294,7 @@ static int fiemap_for_stripe(const struct lu_env *env, struct cl_object *obj,
 		fs->fs_fm->fm_mapped_extents = 0;
 		fs->fs_fm->fm_flags = fiemap->fm_flags;
 
-		ost_index = lsm->lsm_entries[0]->lsme_oinfo[stripeno]->loi_ost_idx;
+		ost_index = lsme->lsme_oinfo[stripeno]->loi_ost_idx;
 
 		if (ost_index < 0 || ost_index >= lov->desc.ld_tgt_count) {
 			rc = -EINVAL;
@@ -1345,8 +1365,9 @@ static int fiemap_for_stripe(const struct lu_env *env, struct cl_object *obj,
 		 */
 		if (fm_ext[ext_count - 1].fe_flags & FIEMAP_EXTENT_LAST)
 			fm_ext[ext_count - 1].fe_flags &= ~FIEMAP_EXTENT_LAST;
-		if (lov_stripe_size(lsm, fm_ext[ext_count - 1].fe_logical +
-					 fm_ext[ext_count - 1].fe_length,
+		if (lov_stripe_size(lsm, index,
+				    fm_ext[ext_count - 1].fe_logical +
+				    fm_ext[ext_count - 1].fe_length,
 				    stripeno) >= fmkey->lfik_oa.o_size) {
 			ost_eof = true;
 			fs->fs_device_done = true;
@@ -1391,6 +1412,7 @@ static int lov_object_fiemap(const struct lu_env *env, struct cl_object *obj,
 	struct fiemap *fm_local = NULL;
 	struct lov_stripe_md *lsm;
 	int rc = 0;
+	int entry = 0;
 	int cur_stripe;
 	int stripe_count;
 	struct fiemap_state fs = { NULL };
@@ -1450,7 +1472,7 @@ static int lov_object_fiemap(const struct lu_env *env, struct cl_object *obj,
 		goto out;
 	}
 	/* Calculate start stripe, last stripe and length of mapping */
-	fs.fs_start_stripe = lov_stripe_number(lsm, fs.fs_start);
+	fs.fs_start_stripe = lov_stripe_number(lsm, 0, fs.fs_start);
 	fs.fs_end = (fs.fs_length == ~0ULL) ? fmkey->lfik_oa.o_size :
 					      fs.fs_start + fs.fs_length - 1;
 	/* If fs_length != ~0ULL but fs_start+fs_length-1 exceeds file size */
@@ -1459,11 +1481,12 @@ static int lov_object_fiemap(const struct lu_env *env, struct cl_object *obj,
 		fs.fs_length = fs.fs_end - fs.fs_start;
 	}
 
-	fs.fs_last_stripe = fiemap_calc_last_stripe(lsm, fs.fs_start, fs.fs_end,
+	fs.fs_last_stripe = fiemap_calc_last_stripe(lsm, entry,
+						    fs.fs_start, fs.fs_end,
 						    fs.fs_start_stripe,
 						    &stripe_count);
-	fs.fs_end_offset = fiemap_calc_fm_end_offset(fiemap, lsm, fs.fs_start,
-						     fs.fs_end,
+	fs.fs_end_offset = fiemap_calc_fm_end_offset(fiemap, lsm, entry,
+						     fs.fs_start, fs.fs_end,
 						     &fs.fs_start_stripe);
 	if (fs.fs_end_offset == -EINVAL) {
 		rc = -EINVAL;
@@ -1489,8 +1512,8 @@ static int lov_object_fiemap(const struct lu_env *env, struct cl_object *obj,
 	     --stripe_count,
 	     cur_stripe = (cur_stripe + 1) %
 			  lsm->lsm_entries[0]->lsme_stripe_count) {
-		rc = fiemap_for_stripe(env, obj, lsm, fiemap, buflen, fmkey,
-				       cur_stripe, &fs);
+		rc = fiemap_for_stripe(env, obj, lsm, fiemap, buflen,
+				       fmkey, 0, cur_stripe, &fs);
 		if (rc < 0)
 			goto out;
 		if (fs.fs_finish)
diff --git a/drivers/staging/lustre/lustre/lov/lov_offset.c b/drivers/staging/lustre/lustre/lov/lov_offset.c
index 19a44d3..d817aa5 100644
--- a/drivers/staging/lustre/lustre/lov/lov_offset.c
+++ b/drivers/staging/lustre/lustre/lov/lov_offset.c
@@ -38,9 +38,10 @@
 #include "lov_internal.h"
 
 /* compute object size given "stripeno" and the ost size */
-u64 lov_stripe_size(struct lov_stripe_md *lsm, u64 ost_size, int stripeno)
+u64 lov_stripe_size(struct lov_stripe_md *lsm, int index, u64 ost_size,
+		    int stripeno)
 {
-	unsigned long ssize = lsm->lsm_entries[0]->lsme_stripe_size;
+	unsigned long ssize = lsm->lsm_entries[index]->lsme_stripe_size;
 	unsigned long stripe_size;
 	u64 swidth;
 	u64 lov_size;
@@ -64,12 +65,13 @@ u64 lov_stripe_size(struct lov_stripe_md *lsm, u64 ost_size, int stripeno)
 /**
  * Compute file level page index by stripe level page offset
  */
-pgoff_t lov_stripe_pgoff(struct lov_stripe_md *lsm, pgoff_t stripe_index,
-			 int stripe)
+pgoff_t lov_stripe_pgoff(struct lov_stripe_md *lsm, int index,
+			 pgoff_t stripe_index, int stripe)
 {
 	loff_t offset;
 
-	offset = lov_stripe_size(lsm, (stripe_index << PAGE_SHIFT) + 1, stripe);
+	offset = lov_stripe_size(lsm, index, (stripe_index << PAGE_SHIFT) + 1,
+				 stripe);
 	return offset >> PAGE_SHIFT;
 }
 
@@ -122,10 +124,10 @@ pgoff_t lov_stripe_pgoff(struct lov_stripe_md *lsm, pgoff_t stripe_index,
  * falls in the stripe and no shifting was done; > 0 when the offset
  * was outside the stripe and was pulled back to its final byte.
  */
-int lov_stripe_offset(struct lov_stripe_md *lsm, u64 lov_off,
+int lov_stripe_offset(struct lov_stripe_md *lsm, int index, u64 lov_off,
 		      int stripeno, u64 *obdoff)
 {
-	unsigned long ssize  = lsm->lsm_entries[0]->lsme_stripe_size;
+	unsigned long ssize  = lsm->lsm_entries[index]->lsme_stripe_size;
 	u64 stripe_off, this_stripe, swidth;
 	int magic = lsm->lsm_magic;
 	int ret = 0;
@@ -177,10 +179,10 @@ int lov_stripe_offset(struct lov_stripe_md *lsm, u64 lov_off,
  * |    0    |     1     |     2     |    0    |     1     |     2     |
  * ---------------------------------------------------------------------
  */
-u64 lov_size_to_stripe(struct lov_stripe_md *lsm, u64 file_size,
+u64 lov_size_to_stripe(struct lov_stripe_md *lsm, int index, u64 file_size,
 		       int stripeno)
 {
-	unsigned long ssize  = lsm->lsm_entries[0]->lsme_stripe_size;
+	unsigned long ssize  = lsm->lsm_entries[index]->lsme_stripe_size;
 	u64 stripe_off, this_stripe, swidth;
 	int magic = lsm->lsm_magic;
 
@@ -218,13 +220,13 @@ u64 lov_size_to_stripe(struct lov_stripe_md *lsm, u64 file_size,
  * that is contained within the lov extent.  this returns true if the given
  * stripe does intersect with the lov extent.
  */
-int lov_stripe_intersects(struct lov_stripe_md *lsm, int stripeno,
+int lov_stripe_intersects(struct lov_stripe_md *lsm, int index, int stripeno,
 			  u64 start, u64 end, u64 *obd_start, u64 *obd_end)
 {
 	int start_side, end_side;
 
-	start_side = lov_stripe_offset(lsm, start, stripeno, obd_start);
-	end_side = lov_stripe_offset(lsm, end, stripeno, obd_end);
+	start_side = lov_stripe_offset(lsm, index, start, stripeno, obd_start);
+	end_side = lov_stripe_offset(lsm, index, end, stripeno, obd_end);
 
 	CDEBUG(D_INODE, "[%llu->%llu] -> [(%d) %llu->%llu (%d)]\n",
 	       start, end, start_side, *obd_start, *obd_end, end_side);
@@ -252,9 +254,9 @@ int lov_stripe_intersects(struct lov_stripe_md *lsm, int stripeno,
 }
 
 /* compute which stripe number "lov_off" will be written into */
-int lov_stripe_number(struct lov_stripe_md *lsm, u64 lov_off)
+int lov_stripe_number(struct lov_stripe_md *lsm, int index, u64 lov_off)
 {
-	unsigned long ssize  = lsm->lsm_entries[0]->lsme_stripe_size;
+	unsigned long ssize  = lsm->lsm_entries[index]->lsme_stripe_size;
 	u64 stripe_off, swidth;
 	int magic = lsm->lsm_magic;
 
diff --git a/drivers/staging/lustre/lustre/lov/lov_page.c b/drivers/staging/lustre/lustre/lov/lov_page.c
index d94d003..ad34fc3 100644
--- a/drivers/staging/lustre/lustre/lov/lov_page.c
+++ b/drivers/staging/lustre/lustre/lov/lov_page.c
@@ -67,21 +67,24 @@ int lov_page_init_composite(const struct lu_env *env, struct cl_object *obj,
 			    struct cl_page *page, pgoff_t index)
 {
 	struct lov_object *loo = cl2lov(obj);
-	struct lov_layout_raid0 *r0 = lov_r0(loo);
 	struct lov_io     *lio = lov_env_io(env);
+	struct lov_layout_raid0 *r0;
 	struct cl_object  *subobj;
 	struct cl_object  *o;
 	struct lov_io_sub *sub;
 	struct lov_page   *lpg = cl_object_page_slice(obj, page);
-	loff_t	     offset;
+	u64 offset;
 	u64	    suboff;
 	int		stripe;
+	int entry = 0;
 	int		rc;
 
 	offset = cl_offset(obj, index);
-	stripe = lov_stripe_number(loo->lo_lsm, offset);
+
+	r0 = lov_r0(loo, entry);
+	stripe = lov_stripe_number(loo->lo_lsm, entry, offset);
 	LASSERT(stripe < r0->lo_nr);
-	rc = lov_stripe_offset(loo->lo_lsm, offset, stripe, &suboff);
+	rc = lov_stripe_offset(loo->lo_lsm, entry, offset, stripe, &suboff);
 	LASSERT(rc == 0);
 
 	lpg->lps_index = stripe;
diff --git a/drivers/staging/lustre/lustre/lov/lovsub_object.c b/drivers/staging/lustre/lustre/lov/lovsub_object.c
index d3e9537..cd7806b 100644
--- a/drivers/staging/lustre/lustre/lov/lovsub_object.c
+++ b/drivers/staging/lustre/lustre/lov/lovsub_object.c
@@ -79,8 +79,9 @@ static void lovsub_object_free(const struct lu_env *env, struct lu_object *obj)
 	 * object handling in lu_object_find.
 	 */
 	if (lov) {
+		int index = 0;
 		int stripe = los->lso_index;
-		struct lov_layout_raid0 *r0 = lov_r0(lov);
+		struct lov_layout_raid0 *r0 = lov_r0(lov, index);
 
 		LASSERT(lov->lo_type == LLT_COMP);
 		LASSERT(r0->lo_sub[stripe] == los);
@@ -107,7 +108,7 @@ static int lovsub_attr_update(const struct lu_env *env, struct cl_object *obj,
 {
 	struct lov_object *lov = cl2lovsub(obj)->lso_super;
 
-	lov_r0(lov)->lo_attr_valid = 0;
+	lov_r0(lov, 0)->lo_attr_valid = 0;
 	return 0;
 }
 
-- 
1.8.3.1
