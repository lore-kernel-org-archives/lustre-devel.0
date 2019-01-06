From: James Simmons <jsimmons@infradead.org>
Date: Sun,  6 Jan 2019 17:14:11 -0500
Subject: [lustre-devel] [PATCH v2 16/33] lustre: clio: client side
 implementation for PFL
In-Reply-To: <1546812868-11794-1-git-send-email-jsimmons@infradead.org>
References: <1546812868-11794-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1546812868-11794-17-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Bobi Jam <bobijam@hotmail.com>

Make client layer support composite layout.

Plain layout will be stored in LOV layer as a composite layout
containing a single component.

Signed-off-by: Jinshan Xiong <jinshan.xiong@gmail.com>
Signed-off-by: Bobi Jam <bobijam@hotmail.com>
Signed-off-by: Niu Yawei <yawei.niu@intel.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-8998
Reviewed-on: https://review.whamcloud.com/24850
Reviewed-by: Lai Siyao <lai.siyao@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/include/uapi/linux/lustre/lustre_user.h |   9 +
 .../staging/lustre/lustre/lov/lov_cl_internal.h    |  25 +-
 drivers/staging/lustre/lustre/lov/lov_ea.c         |  21 +-
 drivers/staging/lustre/lustre/lov/lov_internal.h   |  10 +-
 drivers/staging/lustre/lustre/lov/lov_io.c         | 301 +++++++++++----------
 drivers/staging/lustre/lustre/lov/lov_lock.c       |  83 +++---
 drivers/staging/lustre/lustre/lov/lov_object.c     | 283 ++++++++++---------
 drivers/staging/lustre/lustre/lov/lov_offset.c     |  12 +-
 drivers/staging/lustre/lustre/lov/lov_pack.c       |   2 +-
 drivers/staging/lustre/lustre/lov/lov_page.c       |   8 +-
 drivers/staging/lustre/lustre/osc/osc_lock.c       |   7 +-
 11 files changed, 438 insertions(+), 323 deletions(-)

diff --git a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_user.h b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_user.h
index bb87a6f..8ef05f5 100644
--- a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_user.h
+++ b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_user.h
@@ -411,6 +411,15 @@ struct lu_extent {
 	__u64	e_end;
 };
 
+#define DEXT "[ %#llx , %#llx )"
+#define PEXT(ext) (ext)->e_start, (ext)->e_end
+
+static inline bool lu_extent_is_overlapped(struct lu_extent *e1,
+					    struct lu_extent *e2)
+{
+	return e1->e_start < e2->e_end && e2->e_start < e1->e_end;
+}
+
 enum lov_comp_md_entry_flags {
 	LCME_FL_PRIMARY		= 0x00000001,   /* Not used */
 	LCME_FL_STALE		= 0x00000002,   /* Not used */
diff --git a/drivers/staging/lustre/lustre/lov/lov_cl_internal.h b/drivers/staging/lustre/lustre/lov/lov_cl_internal.h
index 952da3a..96e6636 100644
--- a/drivers/staging/lustre/lustre/lov/lov_cl_internal.h
+++ b/drivers/staging/lustre/lustre/lov/lov_cl_internal.h
@@ -224,6 +224,7 @@ struct lov_object {
 			 */
 			unsigned int lo_entry_count;
 			struct lov_layout_entry {
+				struct lu_extent lle_extent;
 				struct lov_layout_raid0 lle_raid0;
 			} *lo_entries;
 		} composite;
@@ -320,15 +321,9 @@ struct lov_thread_info {
  */
 struct lov_io_sub {
 	/**
-	 * true, iff cl_io_init() was successfully executed against
-	 * lov_io_sub::sub_io.
+	 * Linkage into a list (hanging off lov_io::lis_subios)
 	 */
-	u16			 sub_io_initialized:1,
-	/**
-	 * True, iff lov_io_sub::sub_io and lov_io_sub::sub_env weren't
-	 * allocated, but borrowed from a per-device emergency pool.
-	 */
-				 sub_borrowed:1;
+	struct list_head	sub_list;
 	/**
 	 * Linkage into a list (hanging off lov_io::lis_active) of all
 	 * sub-io's active for the current IO iteration.
@@ -340,7 +335,7 @@ struct lov_io_sub {
 	 * independently, with lov acting as a scheduler to maximize overall
 	 * throughput.
 	 */
-	struct cl_io		*sub_io;
+	struct cl_io		sub_io;
 	/**
 	 * environment, in which sub-io executes.
 	 */
@@ -351,6 +346,7 @@ struct lov_io_sub {
 	 * \see cl_env_get()
 	 */
 	u16			sub_refcheck;
+	u16			sub_reenter;
 };
 
 /**
@@ -384,14 +380,13 @@ struct lov_io {
 	 * exclusive (i.e., next offset after last byte affected by io).
 	 */
 	u64			lis_endpos;
-	int			lis_stripe_count;
-	int			lis_active_subios;
+	int			lis_nr_subios;
 
 	/**
 	 * the index of ls_single_subio in ls_subios array
 	 */
 	int			lis_single_subio_index;
-	struct cl_io		lis_single_subio;
+	struct lov_io_sub	lis_single_subio;
 
 	/**
 	 * List of active sub-io's. Active sub-io's are under the range
@@ -400,10 +395,9 @@ struct lov_io {
 	struct list_head	lis_active;
 
 	/**
-	 * size of ls_subios array, actually the highest stripe #
+	 * All sub-io's created in this lov_io.
 	 */
-	int		lis_nr_subios;
-	struct lov_io_sub *lis_subs;
+	struct list_head	lis_subios;
 };
 
 struct lov_session {
@@ -466,6 +460,7 @@ struct lu_object *lovsub_object_alloc(const struct lu_env *env,
 				      struct lu_device *dev);
 
 struct lov_stripe_md *lov_lsm_addref(struct lov_object *lov);
+int lov_lsm_entry(const struct lov_stripe_md *lsm, u64 offset);
 
 #define lov_foreach_target(lov, var)		    \
 	for (var = 0; var < lov_targets_nr(lov); ++var)
diff --git a/drivers/staging/lustre/lustre/lov/lov_ea.c b/drivers/staging/lustre/lustre/lov/lov_ea.c
index ff6b251..6e5b59e 100644
--- a/drivers/staging/lustre/lustre/lov/lov_ea.c
+++ b/drivers/staging/lustre/lustre/lov/lov_ea.c
@@ -519,9 +519,26 @@ void dump_lsm(unsigned int level, const struct lov_stripe_md *lsm)
 		struct lov_stripe_md_entry *lse = lsm->lsm_entries[i];
 
 		CDEBUG(level,
-		       ": id: %u, magic 0x%08X, stripe count %u, size %u, layout_gen %u, pool: [" LOV_POOLNAMEF "]\n",
-		       lse->lsme_id, lse->lsme_magic,
+		       DEXT ": id: %u, magic 0x%08X, stripe count %u, size %u, layout_gen %u, pool: [" LOV_POOLNAMEF "]\n",
+		       PEXT(&lse->lsme_extent), lse->lsme_id, lse->lsme_magic,
 		       lse->lsme_stripe_count, lse->lsme_stripe_size,
 		       lse->lsme_layout_gen, lse->lsme_pool_name);
 	}
 }
+
+int lov_lsm_entry(const struct lov_stripe_md *lsm, u64 offset)
+{
+	int i;
+
+	for (i = 0; i < lsm->lsm_entry_count; i++) {
+		struct lov_stripe_md_entry *lse = lsm->lsm_entries[i];
+
+		if ((offset >= lse->lsme_extent.e_start &&
+		     offset < lse->lsme_extent.e_end) ||
+		    (offset == OBD_OBJECT_EOF &&
+		     lse->lsme_extent.e_end == OBD_OBJECT_EOF))
+			return i;
+	}
+
+	return -1;
+}
diff --git a/drivers/staging/lustre/lustre/lov/lov_internal.h b/drivers/staging/lustre/lustre/lov/lov_internal.h
index ef47c67..29325ff 100644
--- a/drivers/staging/lustre/lustre/lov/lov_internal.h
+++ b/drivers/staging/lustre/lustre/lov/lov_internal.h
@@ -81,7 +81,10 @@ static inline bool lsm_has_objects(struct lov_stripe_md *lsm)
 
 static inline unsigned int lov_comp_index(int entry, int stripe)
 {
-	return stripe;
+	LASSERT(entry >= 0 && entry <= SHRT_MAX);
+	LASSERT(stripe >= 0 && stripe < USHRT_MAX);
+
+	return entry << 16 | stripe;
 }
 
 static inline int lov_comp_stripe(int index)
@@ -91,7 +94,7 @@ static inline int lov_comp_stripe(int index)
 
 static inline int lov_comp_entry(int index)
 {
-	return 0;
+	return index >> 16;
 }
 
 struct lsm_operations {
@@ -191,8 +194,7 @@ int lov_stripe_offset(struct lov_stripe_md *lsm, int index, u64 lov_off,
 u64 lov_size_to_stripe(struct lov_stripe_md *lsm, int index, u64 file_size,
 		       int stripeno);
 int lov_stripe_intersects(struct lov_stripe_md *lsm, int index, int stripeno,
-			  u64 start, u64 end,
-			  u64 *obd_start, u64 *obd_end);
+			  struct lu_extent *ext, u64 *obd_start, u64 *obd_end);
 int lov_stripe_number(struct lov_stripe_md *lsm, int index, u64 lov_off);
 pgoff_t lov_stripe_pgoff(struct lov_stripe_md *lsm, int index,
 			 pgoff_t stripe_index, int stripe);
diff --git a/drivers/staging/lustre/lustre/lov/lov_io.c b/drivers/staging/lustre/lustre/lov/lov_io.c
index 635e5a6..d9b2a81 100644
--- a/drivers/staging/lustre/lustre/lov/lov_io.c
+++ b/drivers/staging/lustre/lustre/lov/lov_io.c
@@ -43,24 +43,46 @@
 /** \addtogroup lov
  *  @{
  */
+
+static inline struct lov_io_sub *lov_sub_alloc(struct lov_io *lio, int index)
+{
+	struct lov_io_sub *sub;
+
+	if (lio->lis_nr_subios == 0) {
+		LASSERT(lio->lis_single_subio_index == -1);
+		sub = &lio->lis_single_subio;
+		lio->lis_single_subio_index = index;
+		memset(sub, 0, sizeof(*sub));
+	} else {
+		sub = kzalloc(sizeof(*sub), GFP_KERNEL);
+	}
+
+	if (sub) {
+		INIT_LIST_HEAD(&sub->sub_list);
+		INIT_LIST_HEAD(&sub->sub_linkage);
+		sub->sub_subio_index = index;
+	}
+
+	return sub;
+}
+
+static inline void lov_sub_free(struct lov_io *lio, struct lov_io_sub *sub)
+{
+	if (sub->sub_subio_index == lio->lis_single_subio_index) {
+		LASSERT(sub == &lio->lis_single_subio);
+		lio->lis_single_subio_index = -1;
+	} else {
+		kfree(sub);
+	}
+}
+
 static void lov_io_sub_fini(const struct lu_env *env, struct lov_io *lio,
 			    struct lov_io_sub *sub)
 {
-	if (sub->sub_io) {
-		if (sub->sub_io_initialized) {
-			cl_io_fini(sub->sub_env, sub->sub_io);
-			sub->sub_io_initialized = 0;
-			lio->lis_active_subios--;
-		}
-		if (sub->sub_subio_index == lio->lis_single_subio_index)
-			lio->lis_single_subio_index = -1;
-		else if (!sub->sub_borrowed)
-			kfree(sub->sub_io);
-		sub->sub_io = NULL;
-	}
-	if (!IS_ERR_OR_NULL(sub->sub_env)) {
-		if (!sub->sub_borrowed)
-			cl_env_put(sub->sub_env, &sub->sub_refcheck);
+	cl_io_fini(sub->sub_env, &sub->sub_io);
+
+	if (sub->sub_env && !IS_ERR(sub->sub_env)) {
+		cl_env_put(sub->sub_env, &sub->sub_refcheck);
 		sub->sub_env = NULL;
 	}
 }
@@ -74,46 +96,24 @@ static int lov_io_sub_init(const struct lu_env *env, struct lov_io *lio,
 	struct cl_io      *io  = lio->lis_cl.cis_io;
 	int index = lov_comp_entry(sub->sub_subio_index);
 	int stripe = lov_comp_stripe(sub->sub_subio_index);
-	int rc;
+	int rc = 0;
 
-	LASSERT(!sub->sub_io);
 	LASSERT(!sub->sub_env);
-	LASSERT(sub->sub_subio_index < lio->lis_stripe_count);
 
 	if (unlikely(!lov_r0(lov, index)->lo_sub[stripe]))
 		return -EIO;
 
-	sub->sub_io_initialized = 0;
-	sub->sub_borrowed = 0;
-
 	/* obtain new environment */
 	sub->sub_env = cl_env_get(&sub->sub_refcheck);
-	if (IS_ERR(sub->sub_env)) {
+	if (IS_ERR(sub->sub_env))
 		rc = PTR_ERR(sub->sub_env);
-		goto fini_lov_io;
-	}
-
-	/*
-	 * First sub-io. Use ->lis_single_subio to
-	 * avoid dynamic allocation.
-	 */
-	if (lio->lis_active_subios == 0) {
-		sub->sub_io = &lio->lis_single_subio;
-		lio->lis_single_subio_index = stripe;
-	} else {
-		sub->sub_io = kzalloc(sizeof(*sub->sub_io),
-				      GFP_NOFS);
-		if (!sub->sub_io) {
-			rc = -ENOMEM;
-			goto fini_lov_io;
-		}
-	}
 
 	sub_obj = lovsub2cl(lov_r0(lov, index)->lo_sub[stripe]);
-	sub_io = sub->sub_io;
+	sub_io = &sub->sub_io;
 
 	sub_io->ci_obj = sub_obj;
 	sub_io->ci_result = 0;
+
 	sub_io->ci_parent = io;
 	sub_io->ci_lockreq = io->ci_lockreq;
 	sub_io->ci_type = io->ci_type;
@@ -121,31 +121,42 @@ static int lov_io_sub_init(const struct lu_env *env, struct lov_io *lio,
 	sub_io->ci_noatime = io->ci_noatime;
 
 	rc = cl_io_sub_init(sub->sub_env, sub_io, io->ci_type, sub_obj);
-	if (rc >= 0) {
-		lio->lis_active_subios++;
-		sub->sub_io_initialized = 1;
-		rc = 0;
-	}
-fini_lov_io:
-	if (rc)
+	if (rc < 0)
 		lov_io_sub_fini(env, lio, sub);
+
 	return rc;
 }
 
 struct lov_io_sub *lov_sub_get(const struct lu_env *env,
 			       struct lov_io *lio, int index)
 {
-	int rc;
-	struct lov_io_sub *sub = &lio->lis_subs[index];
+	struct lov_io_sub *sub;
+	int rc = 0;
 
-	LASSERT(index < lio->lis_stripe_count);
+	list_for_each_entry(sub, &lio->lis_subios, sub_list) {
+		if (sub->sub_subio_index == index) {
+			rc = 1;
+			break;
+		}
+	}
+
+	if (rc == 0) {
+		sub = lov_sub_alloc(lio, index);
+		if (!sub) {
+			rc = -ENOMEM;
+			goto out;
+		}
 
-	if (!sub->sub_io_initialized) {
-		sub->sub_subio_index = index;
 		rc = lov_io_sub_init(env, lio, sub);
-	} else {
-		rc = 0;
+		if (rc < 0) {
+			lov_sub_free(lio, sub);
+			goto out;
+		}
+
+		list_add_tail(&sub->sub_list, &lio->lis_subios);
+		lio->lis_nr_subios++;
 	}
+out:
 	if (rc < 0)
 		sub = ERR_PTR(rc);
 
@@ -162,6 +173,7 @@ static int lov_page_index(const struct cl_page *page)
 	const struct cl_page_slice *slice;
 
 	slice = cl_page_at(page, &lov_device_type);
+	LASSERT(slice);
 	LASSERT(slice->cpl_obj);
 
 	return cl2lov_page(slice)->lps_index;
@@ -170,28 +182,13 @@ static int lov_page_index(const struct cl_page *page)
 static int lov_io_subio_init(const struct lu_env *env, struct lov_io *lio,
 			     struct cl_io *io)
 {
-	struct lov_stripe_md *lsm;
-	int result;
-
 	LASSERT(lio->lis_object);
-	lsm = lio->lis_object->lo_lsm;
 
-	/*
-	 * Need to be optimized, we can't afford to allocate a piece of memory
-	 * when writing a page. -jay
-	 */
-	lio->lis_subs = kcalloc(lsm->lsm_entries[0]->lsme_stripe_count,
-				sizeof(lio->lis_subs[0]),
-				GFP_KERNEL);
-	if (lio->lis_subs) {
-		lio->lis_nr_subios = lio->lis_stripe_count;
-		lio->lis_single_subio_index = -1;
-		lio->lis_active_subios = 0;
-		result = 0;
-	} else {
-		result = -ENOMEM;
-	}
-	return result;
+	INIT_LIST_HEAD(&lio->lis_subios);
+	lio->lis_single_subio_index = -1;
+	lio->lis_nr_subios = 0;
+
+	return 0;
 }
 
 static int lov_io_slice_init(struct lov_io *lio, struct lov_object *obj,
@@ -200,7 +197,7 @@ static int lov_io_slice_init(struct lov_io *lio, struct lov_object *obj,
 	io->ci_result = 0;
 	lio->lis_object = obj;
 
-	lio->lis_stripe_count = obj->lo_lsm->lsm_entries[0]->lsme_stripe_count;
+	LASSERT(obj->lo_lsm);
 
 	switch (io->ci_type) {
 	case CIT_READ:
@@ -272,14 +269,21 @@ static void lov_io_fini(const struct lu_env *env, const struct cl_io_slice *ios)
 {
 	struct lov_io *lio = cl2lov_io(env, ios);
 	struct lov_object *lov = cl2lov(ios->cis_obj);
-	int i;
 
-	if (lio->lis_subs) {
-		for (i = 0; i < lio->lis_nr_subios; i++)
-			lov_io_sub_fini(env, lio, &lio->lis_subs[i]);
-		kvfree(lio->lis_subs);
-		lio->lis_nr_subios = 0;
+	LASSERT(list_empty(&lio->lis_active));
+
+	while (!list_empty(&lio->lis_subios)) {
+		struct lov_io_sub *sub = list_entry(lio->lis_subios.next,
+						    struct lov_io_sub,
+						    sub_list);
+
+		list_del_init(&sub->sub_list);
+		lio->lis_nr_subios--;
+
+		lov_io_sub_fini(env, lio, sub);
+		lov_sub_free(lio, sub);
 	}
+	LASSERT(lio->lis_nr_subios == 0);
 
 	LASSERT(atomic_read(&lov->lo_active_ios) > 0);
 	if (atomic_dec_and_test(&lov->lo_active_ios))
@@ -287,12 +291,13 @@ static void lov_io_fini(const struct lu_env *env, const struct cl_io_slice *ios)
 }
 
 static void lov_io_sub_inherit(struct lov_io_sub *sub, struct lov_io *lio,
-			       int stripe, loff_t start, loff_t end)
+			       loff_t start, loff_t end)
 {
-	struct cl_io *io = sub->sub_io;
+	struct cl_io *io = &sub->sub_io;
 	struct lov_stripe_md *lsm = lio->lis_object->lo_lsm;
 	struct cl_io *parent = lio->lis_cl.cis_io;
 	int index = lov_comp_entry(sub->sub_subio_index);
+	int stripe = lov_comp_stripe(sub->sub_subio_index);
 
 	switch (io->ci_type) {
 	case CIT_SETATTR: {
@@ -321,7 +326,7 @@ static void lov_io_sub_inherit(struct lov_io_sub *sub, struct lov_io *lio,
 	}
 	case CIT_FAULT: {
 		struct cl_object *obj = parent->ci_obj;
-		loff_t off = cl_offset(obj, parent->u.ci_fault.ft_index);
+		u64 off = cl_offset(obj, parent->u.ci_fault.ft_index);
 
 		io->u.ci_fault = parent->u.ci_fault;
 		off = lov_size_to_stripe(lsm, index, off, stripe);
@@ -373,11 +378,12 @@ static int lov_io_iter_init(const struct lu_env *env,
 	struct lov_stripe_md *lsm = lio->lis_object->lo_lsm;
 	struct lov_layout_entry *le;
 	struct lov_io_sub    *sub;
-	u64 endpos;
+	struct lu_extent ext;
 	int rc = 0;
 	int index;
 
-	endpos = lov_offset_mod(lio->lis_endpos, -1);
+	ext.e_start = lio->lis_pos;
+	ext.e_end = lio->lis_endpos;
 
 	index = 0;
 	lov_foreach_layout_entry(lio->lis_object, le) {
@@ -387,11 +393,12 @@ static int lov_io_iter_init(const struct lu_env *env,
 		u64 end;
 
 		index++;
+		if (!lu_extent_is_overlapped(&ext, &le->lle_extent))
+			continue;
 
 		for (stripe = 0; stripe < r0->lo_nr; stripe++) {
 			if (!lov_stripe_intersects(lsm, index - 1, stripe,
-						   lio->lis_pos,
-						   endpos, &start, &end))
+						   &ext, &start, &end))
 				continue;
 
 			if (unlikely(!r0->lo_sub[stripe])) {
@@ -411,10 +418,10 @@ static int lov_io_iter_init(const struct lu_env *env,
 				break;
 			}
 
-			lov_io_sub_inherit(sub, lio, stripe, start, end);
-			rc = cl_io_iter_init(sub->sub_env, sub->sub_io);
+			lov_io_sub_inherit(sub, lio, start, end);
+			rc = cl_io_iter_init(sub->sub_env, &sub->sub_io);
 			if (rc) {
-				cl_io_iter_fini(sub->sub_env, sub->sub_io);
+				cl_io_iter_fini(sub->sub_env, &sub->sub_io);
 				break;
 			}
 
@@ -437,31 +444,50 @@ static int lov_io_rw_iter_init(const struct lu_env *env,
 	u64 start = io->u.ci_rw.crw_pos;
 	struct lov_stripe_md_entry *lse;
 	unsigned long ssize;
-	loff_t next;
-	int index = 0;
+	int index;
+	u64 next;
 
 	LASSERT(io->ci_type == CIT_READ || io->ci_type == CIT_WRITE);
 
+	if (cl_io_is_append(io))
+		return lov_io_iter_init(env, ios);
+
+	index = lov_lsm_entry(lio->lis_object->lo_lsm, io->u.ci_rw.crw_pos);
+	if (index < 0) { /* non-existing layout component */
+		if (io->ci_type == CIT_READ) {
+			/* TODO: it needs to detect the next component and
+			 * then set the next pos
+			 */
+			io->ci_continue = 0;
+
+			return lov_io_iter_init(env, ios);
+		}
+
+		return -ENODATA;
+	}
+
 	lse = lov_lse(lio->lis_object, index);
 
 	ssize = lse->lsme_stripe_size;
+	lov_do_div64(start, ssize);
+	next = (start + 1) * ssize;
+	if (next <= start * ssize)
+		next = ~0ull;
+
+	LASSERT(io->u.ci_rw.crw_pos >= lse->lsme_extent.e_start);
+	next = min_t(u64, next, lse->lsme_extent.e_end);
+	next = min_t(u64, next, lio->lis_io_endpos);
+
+	io->ci_continue = next < lio->lis_io_endpos;
+	io->u.ci_rw.crw_count = next - io->u.ci_rw.crw_pos;
+	lio->lis_pos = io->u.ci_rw.crw_pos;
+	lio->lis_endpos = io->u.ci_rw.crw_pos + io->u.ci_rw.crw_count;
+
+	CDEBUG(D_VFSTRACE,
+	       "stripe: %llu chunk: [%llu, %llu) %llu\n",
+	       (u64)start, lio->lis_pos, lio->lis_endpos,
+	       (u64)lio->lis_io_endpos);
 
-	/* fast path for common case. */
-	if (lio->lis_nr_subios != 1 && !cl_io_is_append(io)) {
-		lov_do_div64(start, ssize);
-		next = (start + 1) * ssize;
-		if (next <= start * ssize)
-			next = ~0ull;
-
-		io->ci_continue = next < lio->lis_io_endpos;
-		io->u.ci_rw.crw_count = min_t(loff_t, lio->lis_io_endpos,
-					      next) - io->u.ci_rw.crw_pos;
-		lio->lis_pos    = io->u.ci_rw.crw_pos;
-		lio->lis_endpos = io->u.ci_rw.crw_pos + io->u.ci_rw.crw_count;
-		CDEBUG(D_VFSTRACE, "stripe: %llu chunk: [%llu, %llu) %llu\n",
-		       (__u64)start, lio->lis_pos, lio->lis_endpos,
-		       (__u64)lio->lis_io_endpos);
-	}
 	/*
 	 * XXX The following call should be optimized: we know, that
 	 * [lio->lis_pos, lio->lis_endpos) intersects with exactly one stripe.
@@ -477,12 +503,12 @@ static int lov_io_call(const struct lu_env *env, struct lov_io *lio,
 	int rc = 0;
 
 	list_for_each_entry(sub, &lio->lis_active, sub_linkage) {
-		rc = iofunc(sub->sub_env, sub->sub_io);
+		rc = iofunc(sub->sub_env, &sub->sub_io);
 		if (rc)
 			break;
 
 		if (parent->ci_result == 0)
-			parent->ci_result = sub->sub_io->ci_result;
+			parent->ci_result = sub->sub_io.ci_result;
 	}
 	return rc;
 }
@@ -539,13 +565,13 @@ static void lov_io_end(const struct lu_env *env, const struct cl_io_slice *ios)
 	struct lov_io_sub *sub;
 
 	list_for_each_entry(sub, &lio->lis_active, sub_linkage) {
-		lov_io_end_wrapper(sub->sub_env, sub->sub_io);
+		lov_io_end_wrapper(sub->sub_env, &sub->sub_io);
 
 		parent->u.ci_data_version.dv_data_version +=
-			sub->sub_io->u.ci_data_version.dv_data_version;
+			sub->sub_io.u.ci_data_version.dv_data_version;
 
 		if (!parent->ci_result)
-			parent->ci_result = sub->sub_io->ci_result;
+			parent->ci_result = sub->sub_io.ci_result;
 	}
 }
 
@@ -581,12 +607,18 @@ static int lov_io_read_ahead(const struct lu_env *env,
 	unsigned int pps; /* pages per stripe */
 	struct lov_io_sub *sub;
 	pgoff_t ra_end;
+	u64 offset;
 	u64 suboff;
 	int stripe;
-	int index = 0;
+	int index;
 	int rc;
 
-	stripe = lov_stripe_number(loo->lo_lsm, index, cl_offset(obj, start));
+	offset = cl_offset(obj, start);
+	index = lov_lsm_entry(loo->lo_lsm, offset);
+	if (index < 0)
+		return -ENODATA;
+
+	stripe = lov_stripe_number(loo->lo_lsm, index, offset);
 
 	r0 = lov_r0(loo, index);
 	if (unlikely(!r0->lo_sub[stripe]))
@@ -596,8 +628,8 @@ static int lov_io_read_ahead(const struct lu_env *env,
 	if (IS_ERR(sub))
 		return PTR_ERR(sub);
 
-	lov_stripe_offset(loo->lo_lsm, index, cl_offset(obj, start), stripe, &suboff);
-	rc = cl_io_read_ahead(sub->sub_env, sub->sub_io,
+	lov_stripe_offset(loo->lo_lsm, index, offset, stripe, &suboff);
+	rc = cl_io_read_ahead(sub->sub_env, &sub->sub_io,
 			      cl_index(lovsub2cl(r0->lo_sub[stripe]), suboff),
 			      ra);
 
@@ -623,8 +655,8 @@ static int lov_io_read_ahead(const struct lu_env *env,
 	pps = lov_lse(loo, index)->lsme_stripe_size >> PAGE_SHIFT;
 
 	CDEBUG(D_READA,
-	       DFID " max_index = %lu, pps = %u, stripe_size = %u, stripe no = %u, start index = %lu\n",
-	       PFID(lu_object_fid(lov2lu(loo))), ra_end, pps,
+	       DFID " max_index = %lu, pps = %u, index = %u, stripe_size = %u, stripe no = %u, start index = %lu\n",
+	       PFID(lu_object_fid(lov2lu(loo))), ra_end, pps, index,
 	       lov_lse(loo, index)->lsme_stripe_size, stripe, start);
 
 	/* never exceed the end of the stripe */
@@ -659,20 +691,17 @@ static int lov_io_submit(const struct lu_env *env,
 	int index;
 	int rc = 0;
 
-	if (lio->lis_active_subios == 1) {
+	if (lio->lis_nr_subios == 1) {
 		int idx = lio->lis_single_subio_index;
 
-		LASSERT(idx < lio->lis_nr_subios);
 		sub = lov_sub_get(env, lio, idx);
 		LASSERT(!IS_ERR(sub));
-		LASSERT(sub->sub_io == &lio->lis_single_subio);
-		rc = cl_io_submit_rw(sub->sub_env, sub->sub_io,
+		LASSERT(sub == &lio->lis_single_subio);
+		rc = cl_io_submit_rw(sub->sub_env, &sub->sub_io,
 				     crt, queue);
 		return rc;
 	}
 
-	LASSERT(lio->lis_subs);
-
 	cl_page_list_init(plist);
 	while (qin->pl_nr > 0) {
 		struct cl_2queue *cl2q = &lov_env_info(env)->lti_cl2q;
@@ -693,7 +722,7 @@ static int lov_io_submit(const struct lu_env *env,
 
 		sub = lov_sub_get(env, lio, index);
 		if (!IS_ERR(sub)) {
-			rc = cl_io_submit_rw(sub->sub_env, sub->sub_io,
+			rc = cl_io_submit_rw(sub->sub_env, &sub->sub_io,
 					     crt, cl2q);
 		} else {
 			rc = PTR_ERR(sub);
@@ -724,20 +753,17 @@ static int lov_io_commit_async(const struct lu_env *env,
 	struct cl_page *page;
 	int rc = 0;
 
-	if (lio->lis_active_subios == 1) {
+	if (lio->lis_nr_subios == 1) {
 		int idx = lio->lis_single_subio_index;
 
-		LASSERT(idx < lio->lis_nr_subios);
 		sub = lov_sub_get(env, lio, idx);
 		LASSERT(!IS_ERR(sub));
-		LASSERT(sub->sub_io == &lio->lis_single_subio);
-		rc = cl_io_commit_async(sub->sub_env, sub->sub_io, queue,
+		LASSERT(sub == &lio->lis_single_subio);
+		rc = cl_io_commit_async(sub->sub_env, &sub->sub_io, queue,
 					from, to, cb);
 		return rc;
 	}
 
-	LASSERT(lio->lis_subs);
-
 	cl_page_list_init(plist);
 	while (queue->pl_nr > 0) {
 		int stripe_to = to;
@@ -761,7 +787,7 @@ static int lov_io_commit_async(const struct lu_env *env,
 
 		sub = lov_sub_get(env, lio, index);
 		if (!IS_ERR(sub)) {
-			rc = cl_io_commit_async(sub->sub_env, sub->sub_io,
+			rc = cl_io_commit_async(sub->sub_env, &sub->sub_io,
 						plist, from, stripe_to, cb);
 		} else {
 			rc = PTR_ERR(sub);
@@ -797,7 +823,8 @@ static int lov_io_fault_start(const struct lu_env *env,
 	sub = lov_sub_get(env, lio, lov_page_index(fio->ft_page));
 	if (IS_ERR(sub))
 		return PTR_ERR(sub);
-	sub->sub_io->u.ci_fault.ft_nob = fio->ft_nob;
+	sub->sub_io.u.ci_fault.ft_nob = fio->ft_nob;
+
 	return lov_io_start(env, ios);
 }
 
@@ -810,7 +837,7 @@ static void lov_io_fsync_end(const struct lu_env *env,
 
 	*written = 0;
 	list_for_each_entry(sub, &lio->lis_active, sub_linkage) {
-		struct cl_io *subio = sub->sub_io;
+		struct cl_io *subio = &sub->sub_io;
 
 		lov_io_end_wrapper(sub->sub_env, subio);
 
diff --git a/drivers/staging/lustre/lustre/lov/lov_lock.c b/drivers/staging/lustre/lustre/lov/lov_lock.c
index cc08e96..ba31be4 100644
--- a/drivers/staging/lustre/lustre/lov/lov_lock.c
+++ b/drivers/staging/lustre/lustre/lov/lov_lock.c
@@ -76,7 +76,7 @@ static struct lov_sublock_env *lov_sublock_env_get(const struct lu_env *env,
 		sub = lov_sub_get(env, lio, lls->sub_index);
 		if (!IS_ERR(sub)) {
 			subenv->lse_env = sub->sub_env;
-			subenv->lse_io  = sub->sub_io;
+			subenv->lse_io = &sub->sub_io;
 		} else {
 			subenv = (void *)sub;
 		}
@@ -114,52 +114,65 @@ static struct lov_lock *lov_lock_sub_init(const struct lu_env *env,
 					  const struct cl_object *obj,
 					  struct cl_lock *lock)
 {
-	struct lov_object *loo = cl2lov(obj);
-	struct lov_layout_raid0 *r0;
-	struct lov_lock	*lovlck;
+	struct lov_object *lov = cl2lov(obj);
+	struct lov_lock *lovlck;
+	struct lu_extent ext;
 	int result = 0;
-	int index = 0;
+	int index;
 	int i;
 	int nr;
 	u64 start;
 	u64 end;
-	u64 file_start;
-	u64 file_end;
-
-	CDEBUG(D_INODE, "%p: lock/io FID " DFID "/" DFID ", lock/io clobj %p/%p\n",
-	       loo, PFID(lu_object_fid(lov2lu(loo))),
-	       PFID(lu_object_fid(&obj->co_lu)),
-	       lov2cl(loo), obj);
-
-	file_start = cl_offset(lov2cl(loo), lock->cll_descr.cld_start);
-	file_end   = cl_offset(lov2cl(loo), lock->cll_descr.cld_end + 1) - 1;
-
-	r0 = lov_r0(loo, index);
-	for (i = 0, nr = 0; i < r0->lo_nr; i++) {
-		/*
-		 * XXX for wide striping smarter algorithm is desirable,
-		 * breaking out of the loop, early.
-		 */
-		if (likely(r0->lo_sub[i]) && /* spare layout */
-		    lov_stripe_intersects(loo->lo_lsm, index, i,
-					  file_start, file_end, &start, &end))
-			nr++;
+
+	ext.e_start = cl_offset(obj, lock->cll_descr.cld_start);
+	if (lock->cll_descr.cld_end == CL_PAGE_EOF)
+		ext.e_end = OBD_OBJECT_EOF;
+	else
+		ext.e_end = cl_offset(obj, lock->cll_descr.cld_end + 1);
+
+	nr = 0;
+	for (index = lov_lsm_entry(lov->lo_lsm, ext.e_start);
+	     index != -1 && index < lov->lo_lsm->lsm_entry_count; index++) {
+		struct lov_layout_raid0 *r0 = lov_r0(lov, index);
+
+		/* assume lsm entries are sorted. */
+		if (!lu_extent_is_overlapped(&ext,
+					     &lov_lse(lov, index)->lsme_extent))
+			break;
+
+		for (i = 0; i < r0->lo_nr; i++) {
+			if (likely(r0->lo_sub[i]) && /* spare layout */
+			    lov_stripe_intersects(lov->lo_lsm, index, i,
+						  &ext, &start, &end))
+				nr++;
+		}
 	}
-	LASSERT(nr > 0);
+	if (nr == 0)
+		return ERR_PTR(-EINVAL);
+
 	lovlck = kvzalloc(offsetof(struct lov_lock, lls_sub[nr]),
 				 GFP_NOFS);
 	if (!lovlck)
 		return ERR_PTR(-ENOMEM);
 
 	lovlck->lls_nr = nr;
-	for (i = 0, nr = 0; i < r0->lo_nr; ++i) {
-		if (likely(r0->lo_sub[i]) &&
-		    lov_stripe_intersects(loo->lo_lsm, index, i,
-					  file_start, file_end, &start, &end)) {
+	nr = 0;
+	for (index = lov_lsm_entry(lov->lo_lsm, ext.e_start);
+	     index < lov->lo_lsm->lsm_entry_count; index++) {
+		struct lov_layout_raid0 *r0 = lov_r0(lov, index);
+
+		/* assume lsm entries are sorted. */
+		if (!lu_extent_is_overlapped(&ext,
+					     &lov_lse(lov, index)->lsme_extent))
+			break;
+		for (i = 0; i < r0->lo_nr; ++i) {
 			struct lov_lock_sub *lls = &lovlck->lls_sub[nr];
-			struct cl_lock_descr *descr;
+			struct cl_lock_descr *descr = &lls->sub_lock.cll_descr;
 
-			descr = &lls->sub_lock.cll_descr;
+			if (unlikely(!r0->lo_sub[i]) ||
+			    !lov_stripe_intersects(lov->lo_lsm, index, i,
+						   &ext, &start, &end))
+				continue;
 
 			LASSERT(!descr->cld_obj);
 			descr->cld_obj   = lovsub2cl(r0->lo_sub[i]);
@@ -267,8 +280,8 @@ static void lov_lock_cancel(const struct lu_env *env,
 			cl_lock_cancel(subenv->lse_env, sublock);
 		} else {
 			CL_LOCK_DEBUG(D_ERROR, env, slice->cls_lock,
-				      "%s fails with %ld.\n",
-				      __func__, PTR_ERR(subenv));
+				      "lov_lock_cancel fails with %ld.\n",
+				      PTR_ERR(subenv));
 		}
 	}
 }
diff --git a/drivers/staging/lustre/lustre/lov/lov_object.c b/drivers/staging/lustre/lustre/lov/lov_object.c
index 3b34713..a7d3068 100644
--- a/drivers/staging/lustre/lustre/lov/lov_object.c
+++ b/drivers/staging/lustre/lustre/lov/lov_object.c
@@ -130,14 +130,13 @@ static struct cl_object *lov_sub_find(const struct lu_env *env,
 
 static int lov_init_sub(const struct lu_env *env, struct lov_object *lov,
 			struct cl_object *subobj, struct lov_layout_raid0 *r0,
-			int idx)
+			struct lov_oinfo *oinfo, int idx)
 {
 	int stripe = lov_comp_stripe(idx);
 	int entry = lov_comp_entry(idx);
 	struct cl_object_header *hdr;
 	struct cl_object_header *subhdr;
 	struct cl_object_header *parent;
-	struct lov_oinfo	*oinfo;
 	int result;
 
 	if (OBD_FAIL_CHECK(OBD_FAIL_LOV_INIT)) {
@@ -155,11 +154,10 @@ static int lov_init_sub(const struct lu_env *env, struct lov_object *lov,
 	hdr    = cl_object_header(lov2cl(lov));
 	subhdr = cl_object_header(subobj);
 
-	oinfo = lov->lo_lsm->lsm_entries[0]->lsme_oinfo[idx];
 	CDEBUG(D_INODE,
 	       DFID "@%p[%d:%d] -> " DFID "@%p: ostid: " DOSTID " ost idx: %d gen: %d\n",
-	       PFID(&subhdr->coh_lu.loh_fid), subhdr, entry, stripe,
-	       PFID(&hdr->coh_lu.loh_fid), hdr, POSTID(&oinfo->loi_oi),
+	       PFID(lu_object_fid(&subobj->co_lu)), subhdr, entry, stripe,
+	       PFID(lu_object_fid(lov2lu(lov))), hdr, POSTID(&oinfo->loi_oi),
 	       oinfo->loi_ost_idx, oinfo->loi_ost_gen);
 
 	/* reuse ->coh_attr_guard to protect coh_parent change */
@@ -221,14 +219,13 @@ static int lov_page_slice_fixup(struct lov_object *lov,
 
 static int lov_init_raid0(const struct lu_env *env, struct lov_device *dev,
 			  struct lov_object *lov, int index,
-			  const struct cl_object_conf *conf,
 			  struct lov_layout_raid0 *r0)
 {
 	struct lov_stripe_md_entry *lse = lov_lse(lov, index);
-	struct cl_object *stripe;
 	struct lov_thread_info *lti = lov_env_info(env);
 	struct cl_object_conf *subconf = &lti->lti_stripe_conf;
 	struct lu_fid *ofid = &lti->lti_fid;
+	struct cl_object *stripe;
 	int result;
 	int psz;
 	int i;
@@ -238,20 +235,21 @@ static int lov_init_raid0(const struct lu_env *env, struct lov_device *dev,
 	LASSERT(r0->lo_nr <= lov_targets_nr(dev));
 
 	r0->lo_sub = kvzalloc(r0->lo_nr * sizeof(r0->lo_sub[0]),
-				     GFP_NOFS);
+			      GFP_KERNEL);
 	if (!r0->lo_sub)
 		return -ENOMEM;
 
 	psz = 0;
 	result = 0;
-	subconf->coc_inode = conf->coc_inode;
+	memset(subconf, 0, sizeof(*subconf));
+
 	/*
 	 * Create stripe cl_objects.
 	 */
 	for (i = 0; i < r0->lo_nr; ++i) {
 		struct lov_oinfo *oinfo = lse->lsme_oinfo[i];
+		int ost_idx = oinfo->loi_ost_idx;
 		struct cl_device *subdev;
-		int ost_idx;
 
 		if (lov_oinfo_is_dummy(oinfo))
 			continue;
@@ -261,7 +259,6 @@ static int lov_init_raid0(const struct lu_env *env, struct lov_device *dev,
 		if (result != 0)
 			goto out;
 
-		ost_idx = oinfo->loi_ost_idx;
 		if (!dev->ld_target[ost_idx]) {
 			CERROR("%s: OST %04x is not initialized\n",
 			       lov2obd(dev->ld_lov)->obd_name, ost_idx);
@@ -282,7 +279,7 @@ static int lov_init_raid0(const struct lu_env *env, struct lov_device *dev,
 			goto out;
 		}
 
-		result = lov_init_sub(env, lov, stripe, r0,
+		result = lov_init_sub(env, lov, stripe, r0, oinfo,
 				      lov_comp_index(index, i));
 		if (result == -EAGAIN) { /* try again */
 			--i;
@@ -309,15 +306,17 @@ static int lov_init_composite(const struct lu_env *env, struct lov_device *dev,
 			      union lov_layout_state *state)
 {
 	struct lov_layout_composite *comp = &state->composite;
-	unsigned int entry_count = 1;
+	unsigned int entry_count;
 	unsigned int psz = 0;
 	int result = 0;
 	int i;
 
+	LASSERT(lsm->lsm_entry_count > 0);
 	LASSERT(!lov->lo_lsm);
 	lov->lo_lsm = lsm_addref(lsm);
 	lov->lo_layout_invalid = true;
 
+	entry_count = lsm->lsm_entry_count;
 	comp->lo_entry_count = entry_count;
 
 	comp->lo_entries = kcalloc(entry_count, sizeof(*comp->lo_entries),
@@ -328,8 +327,8 @@ static int lov_init_composite(const struct lu_env *env, struct lov_device *dev,
 	for (i = 0; i < entry_count; i++) {
 		struct lov_layout_entry *le = &comp->lo_entries[i];
 
-		result = lov_init_raid0(env, dev, lov, i, conf,
-					&le->lle_raid0);
+		le->lle_extent = lsm->lsm_entries[i]->lsme_extent;
+		result = lov_init_raid0(env, dev, lov, i, &le->lle_raid0);
 		if (result < 0)
 			break;
 
@@ -364,31 +363,30 @@ static struct cl_object *lov_find_subobj(const struct lu_env *env,
 	struct lov_thread_info *lti = lov_env_info(env);
 	struct lu_fid *ofid = &lti->lti_fid;
 	int stripe = lov_comp_stripe(index);
+	int entry = lov_comp_entry(index);
+	struct cl_object *result = NULL;
 	struct cl_device *subdev;
-	struct cl_object *result;
 	struct lov_oinfo *oinfo;
 	int ost_idx;
 	int rc;
 
-	if (lov->lo_type != LLT_COMP) {
-		result = NULL;
+	if (lov->lo_type != LLT_COMP)
+		goto out;
+
+	if (entry >= lsm->lsm_entry_count ||
+	    stripe >= lsm->lsm_entries[entry]->lsme_stripe_count)
 		goto out;
-	}
 
-	oinfo = lsm->lsm_entries[0]->lsme_oinfo[stripe];
+	oinfo = lsm->lsm_entries[entry]->lsme_oinfo[stripe];
 	ost_idx = oinfo->loi_ost_idx;
 	rc = ostid_to_fid(ofid, &oinfo->loi_oi, ost_idx);
-	if (rc) {
-		result = NULL;
+	if (rc)
 		goto out;
-	}
 
 	subdev = lovsub2cl_dev(dev->ld_target[ost_idx]);
 	result = lov_sub_find(env, subdev, ofid, NULL);
 out:
-	if (!result)
-		result = ERR_PTR(-EINVAL);
-	return result;
+	return result ? result : ERR_PTR(-EINVAL);
 }
 
 static int lov_delete_empty(const struct lu_env *env, struct lov_object *lov,
@@ -567,8 +565,8 @@ static int lov_print_composite(const struct lu_env *env, void *cookie,
 	for (i = 0; i < lsm->lsm_entry_count; i++) {
 		struct lov_stripe_md_entry *lse = lsm->lsm_entries[i];
 
-		(*p)(env, cookie, ": { 0x%08X, %u, %u, %u, %u }\n",
-		     lse->lsme_magic,
+		(*p)(env, cookie, DEXT ": { 0x%08X, %u, %u, %u, %u }\n",
+		     PEXT(&lse->lsme_extent), lse->lsme_magic,
 		     lse->lsme_id, lse->lsme_layout_gen,
 		     lse->lsme_stripe_count, lse->lsme_stripe_size);
 		lov_print_raid0(env, cookie, p, lov_r0(lov, i));
@@ -584,10 +582,10 @@ static int lov_print_released(const struct lu_env *env, void *cookie,
 	struct lov_stripe_md	*lsm = lov->lo_lsm;
 
 	(*p)(env, cookie,
-	     "released: %s, lsm{%p 0x%08X %d %u %u}:\n",
+	     "released: %s, lsm{%p 0x%08X %d %u}:\n",
 	     lov->lo_layout_invalid ? "invalid" : "valid", lsm,
 	     lsm->lsm_magic, atomic_read(&lsm->lsm_refc),
-	     lsm->lsm_entries[0]->lsme_stripe_count, lsm->lsm_layout_gen);
+	     lsm->lsm_layout_gen);
 	return 0;
 }
 
@@ -601,6 +599,7 @@ static int lov_print_released(const struct lu_env *env, void *cookie,
 static int lov_attr_get_empty(const struct lu_env *env, struct cl_object *obj,
 			      struct cl_attr *attr)
 {
+	attr->cat_blocks = 0;
 	return 0;
 }
 
@@ -659,16 +658,18 @@ static int lov_attr_get_composite(const struct lu_env *env,
 	int result = 0;
 	int index = 0;
 
-	attr->cat_blocks = 0;
 	attr->cat_size = 0;
+	attr->cat_blocks = 0;
 	lov_foreach_layout_entry(lov, entry) {
 		struct lov_layout_raid0 *r0 = &entry->lle_raid0;
 		struct cl_attr *lov_attr = &r0->lo_attr;
 
 		result = lov_attr_get_raid0(env, lov, index, r0);
-		if (result)
+		if (result != 0)
 			break;
 
+		index++;
+
 		/* merge results */
 		attr->cat_blocks += lov_attr->cat_blocks;
 		if (attr->cat_size < lov_attr->cat_size)
@@ -742,13 +743,15 @@ static enum lov_layout_type lov_type(struct lov_stripe_md *lsm)
 	if (!lsm)
 		return LLT_EMPTY;
 
-	if (lsm->lsm_magic == LOV_MAGIC_COMP_V1)
-		return LLT_EMPTY;
-
 	if (lsm->lsm_is_released)
 		return LLT_RELEASED;
 
-	return LLT_COMP;
+	if (lsm->lsm_magic == LOV_MAGIC_V1 ||
+	    lsm->lsm_magic == LOV_MAGIC_V3 ||
+	    lsm->lsm_magic == LOV_MAGIC_COMP_V1)
+		return LLT_COMP;
+
+	return LLT_EMPTY;
 }
 
 static inline void lov_conf_freeze(struct lov_object *lov)
@@ -926,6 +929,8 @@ int lov_object_init(const struct lu_env *env, struct lu_object *obj,
 				   cconf->u.coc_layout.lb_len);
 		if (IS_ERR(lsm))
 			return PTR_ERR(lsm);
+
+		dump_lsm(D_INODE, lsm);
 	}
 
 	/* no locking is necessary, as object is being created */
@@ -1090,8 +1095,8 @@ int lov_lock_init(const struct lu_env *env, struct cl_object *obj,
  * over which the mapping is spread
  *
  * \param lsm [in]		striping information for the file
- * \param fm_start [in]		logical start of mapping
- * \param fm_end [in]		logical end of mapping
+ * @index			stripe component index
+ * @ext				logical extent of mapping
  * \param start_stripe [in]	starting stripe of the mapping
  * \param stripe_count [out]	the number of stripes across which to map is
  *				returned
@@ -1099,7 +1104,7 @@ int lov_lock_init(const struct lu_env *env, struct cl_object *obj,
  * \retval last_stripe		return the last stripe of the mapping
  */
 static int fiemap_calc_last_stripe(struct lov_stripe_md *lsm, int index,
-				   u64 fm_start, u64 fm_end,
+				   struct lu_extent *ext,
 				   int start_stripe, int *stripe_count)
 {
 	struct lov_stripe_md_entry *lsme = lsm->lsm_entries[index];
@@ -1108,7 +1113,7 @@ static int fiemap_calc_last_stripe(struct lov_stripe_md *lsm, int index,
 	u64 obd_end;
 	int i, j;
 
-	if (fm_end - fm_start >
+	if (ext->e_end - ext->e_start >
 	    lsme->lsme_stripe_size * lsme->lsme_stripe_count) {
 		last_stripe = (start_stripe < 1 ? lsme->lsme_stripe_count - 1 :
 						  start_stripe - 1);
@@ -1116,7 +1121,7 @@ static int fiemap_calc_last_stripe(struct lov_stripe_md *lsm, int index,
 	} else {
 		for (j = 0, i = start_stripe; j < lsme->lsme_stripe_count;
 		     i = (i + 1) % lsme->lsme_stripe_count, j++) {
-			if (lov_stripe_intersects(lsm, index, i, fm_start, fm_end,
+			if (lov_stripe_intersects(lsm, index, i, ext,
 						  &obd_start, &obd_end) == 0)
 				break;
 		}
@@ -1170,13 +1175,13 @@ static void fiemap_prepare_and_copy_exts(struct fiemap *fiemap,
  *
  * \param fiemap [in]		fiemap request header
  * \param lsm [in]		striping information for the file
- * \param fm_start [in]		logical start of mapping
- * \param fm_end [in]		logical end of mapping
+ * @index			stripe component index
+ * @ext				logical extent of mapping
  * \param start_stripe [out]	starting stripe will be returned in this
  */
 static u64 fiemap_calc_fm_end_offset(struct fiemap *fiemap,
 				     struct lov_stripe_md *lsm,
-				     int index, u64 fm_start, u64 fm_end,
+				     int index, struct lu_extent *ext,
 				     int *start_stripe)
 {
 	struct lov_stripe_md_entry *lsme = lsm->lsm_entries[index];
@@ -1209,7 +1214,7 @@ static u64 fiemap_calc_fm_end_offset(struct fiemap *fiemap,
 	 * If we have finished mapping on previous device, shift logical
 	 * offset to start of next device
 	 */
-	if (lov_stripe_intersects(lsm, index, stripe_no, fm_start, fm_end,
+	if (lov_stripe_intersects(lsm, index, stripe_no, ext,
 				  &lun_start, &lun_end) != 0 &&
 	    local_end < lun_end) {
 		fm_end_offset = local_end;
@@ -1227,16 +1232,15 @@ static u64 fiemap_calc_fm_end_offset(struct fiemap *fiemap,
 
 struct fiemap_state {
 	struct fiemap		*fs_fm;
-	u64			fs_start;
+	struct lu_extent	fs_ext;
 	u64			fs_length;
-	u64			fs_end;
 	u64			fs_end_offset;
 	int			fs_cur_extent;
 	int			fs_cnt_need;
 	int			fs_start_stripe;
 	int			fs_last_stripe;
 	bool			fs_device_done;
-	bool			fs_finish;
+	bool			fs_finish_stripe;
 	bool			fs_enough;
 };
 
@@ -1264,8 +1268,7 @@ static int fiemap_for_stripe(const struct lu_env *env, struct cl_object *obj,
 
 	fs->fs_device_done = false;
 	/* Find out range of mapping on this stripe */
-	if ((lov_stripe_intersects(lsm, index, stripeno,
-				   fs->fs_start, fs->fs_end,
+	if ((lov_stripe_intersects(lsm, index, stripeno, &fs->fs_ext,
 				   &lun_start, &obd_object_end)) == 0)
 		return 0;
 
@@ -1279,16 +1282,7 @@ static int fiemap_for_stripe(const struct lu_env *env, struct cl_object *obj,
 	if (fs->fs_end_offset != 0 && stripeno == fs->fs_start_stripe)
 		lun_start = fs->fs_end_offset;
 
-	lun_end = fs->fs_length;
-	if (lun_end != ~0ULL) {
-		/* Handle fs->fs_start + fs->fs_length overflow */
-		if (fs->fs_start + fs->fs_length < fs->fs_start)
-			fs->fs_length = ~0ULL - fs->fs_start;
-		lun_end = lov_size_to_stripe(lsm, index,
-					     fs->fs_start + fs->fs_length,
-					     stripeno);
-	}
-
+	lun_end = lov_size_to_stripe(lsm, index, fs->fs_ext.e_end, stripeno);
 	if (lun_start == lun_end)
 		return 0;
 
@@ -1316,6 +1310,11 @@ static int fiemap_for_stripe(const struct lu_env *env, struct cl_object *obj,
 		lun_start += len_mapped_single_call;
 		fs->fs_fm->fm_length = req_fm_len - len_mapped_single_call;
 		req_fm_len = fs->fs_fm->fm_length;
+		/**
+		 * If we've collected enough extent map, we'd request 1 more,
+		 * to see whether we coincidentally finished all available
+		 * extent map, so that FIEMAP_EXTENT_LAST would be set.
+		 */
 		fs->fs_fm->fm_extent_count = fs->fs_enough ?
 					     1 : fs->fs_cnt_need;
 		fs->fs_fm->fm_mapped_extents = 0;
@@ -1357,7 +1356,7 @@ static int fiemap_for_stripe(const struct lu_env *env, struct cl_object *obj,
 			 */
 			if (stripeno == fs->fs_last_stripe) {
 				fiemap->fm_mapped_extents = 0;
-				fs->fs_finish = true;
+				fs->fs_finish_stripe = true;
 				goto obj_put;
 			}
 			break;
@@ -1366,7 +1365,6 @@ static int fiemap_for_stripe(const struct lu_env *env, struct cl_object *obj,
 			 * We've collected enough extents and there are
 			 * more extents after it.
 			 */
-			fs->fs_finish = true;
 			goto obj_put;
 		}
 
@@ -1410,7 +1408,7 @@ static int fiemap_for_stripe(const struct lu_env *env, struct cl_object *obj,
 	} while (!ost_done && !ost_eof);
 
 	if (stripeno == fs->fs_last_stripe)
-		fs->fs_finish = true;
+		fs->fs_finish_stripe = true;
 obj_put:
 	cl_object_put(env, subobj);
 
@@ -1436,26 +1434,35 @@ static int lov_object_fiemap(const struct lu_env *env, struct cl_object *obj,
 			     struct fiemap *fiemap, size_t *buflen)
 {
 	unsigned int buffer_size = FIEMAP_BUFFER_SIZE;
+	struct lov_stripe_md_entry *lsme;
 	struct fiemap *fm_local = NULL;
 	struct lov_stripe_md *lsm;
-	int rc = 0;
-	int entry = 0;
-	int cur_stripe;
+	loff_t whole_start;
+	loff_t whole_end;
+	int entry;
+	int start_entry;
+	int end_entry;
+	int cur_stripe = 0;
 	int stripe_count;
+	int rc = 0;
 	struct fiemap_state fs = { NULL };
 
 	lsm = lov_lsm_addref(cl2lov(obj));
 	if (!lsm)
 		return -ENODATA;
 
-	/**
-	 * If the stripe_count > 1 and the application does not understand
-	 * DEVICE_ORDER flag, it cannot interpret the extents correctly.
-	 */
-	if (lsm->lsm_entries[0]->lsme_stripe_count > 1 &&
-	    !(fiemap->fm_flags & FIEMAP_FLAG_DEVICE_ORDER)) {
-		rc = -ENOTSUPP;
-		goto out;
+	if (!(fiemap->fm_flags & FIEMAP_FLAG_DEVICE_ORDER)) {
+		/**
+		 * If the entry count > 1 or stripe_count > 1 and the
+		 * application does not understand DEVICE_ORDER flag,
+		 * it cannot interpret the extents correctly.
+		 */
+		if (lsm->lsm_entry_count > 1 ||
+		    (lsm->lsm_entry_count == 1 &&
+		     lsm->lsm_entries[0]->lsme_stripe_count > 1)) {
+			rc = -ENOTSUPP;
+			goto out_lsm;
+		}
 	}
 
 	if (lsm->lsm_is_released) {
@@ -1478,49 +1485,19 @@ static int lov_object_fiemap(const struct lu_env *env, struct cl_object *obj,
 				FIEMAP_EXTENT_UNKNOWN | FIEMAP_EXTENT_LAST;
 		}
 		rc = 0;
-		goto out;
+		goto out_lsm;
 	}
 
+	/* buffer_size is small to hold fm_extent_count of extents. */
 	if (fiemap_count_to_size(fiemap->fm_extent_count) < buffer_size)
 		buffer_size = fiemap_count_to_size(fiemap->fm_extent_count);
 
 	fm_local = kvzalloc(buffer_size, GFP_NOFS);
 	if (!fm_local) {
 		rc = -ENOMEM;
-		goto out;
-	}
-	fs.fs_fm = fm_local;
-	fs.fs_cnt_need = fiemap_size_to_count(buffer_size);
-
-	fs.fs_start = fiemap->fm_start;
-	/* fs_start is beyond the end of the file */
-	if (fs.fs_start > fmkey->lfik_oa.o_size) {
-		rc = -EINVAL;
-		goto out;
-	}
-	/* Calculate start stripe, last stripe and length of mapping */
-	fs.fs_start_stripe = lov_stripe_number(lsm, 0, fs.fs_start);
-	fs.fs_end = (fs.fs_length == ~0ULL) ? fmkey->lfik_oa.o_size :
-					      fs.fs_start + fs.fs_length - 1;
-	/* If fs_length != ~0ULL but fs_start+fs_length-1 exceeds file size */
-	if (fs.fs_end > fmkey->lfik_oa.o_size) {
-		fs.fs_end = fmkey->lfik_oa.o_size;
-		fs.fs_length = fs.fs_end - fs.fs_start;
+		goto out_lsm;
 	}
 
-	fs.fs_last_stripe = fiemap_calc_last_stripe(lsm, entry,
-						    fs.fs_start, fs.fs_end,
-						    fs.fs_start_stripe,
-						    &stripe_count);
-	fs.fs_end_offset = fiemap_calc_fm_end_offset(fiemap, lsm, entry,
-						     fs.fs_start, fs.fs_end,
-						     &fs.fs_start_stripe);
-	if (fs.fs_end_offset == -EINVAL) {
-		rc = -EINVAL;
-		goto out;
-	}
-
-
 	/**
 	 * Requested extent count exceeds the fiemap buffer size, shrink our
 	 * ambition.
@@ -1530,27 +1507,88 @@ static int lov_object_fiemap(const struct lu_env *env, struct cl_object *obj,
 	if (!fiemap->fm_extent_count)
 		fs.fs_cnt_need = 0;
 
-	fs.fs_finish = false;
 	fs.fs_enough = false;
 	fs.fs_cur_extent = 0;
+	fs.fs_fm = fm_local;
+	fs.fs_cnt_need = fiemap_size_to_count(buffer_size);
+
+	whole_start = fiemap->fm_start;
+	/* whole_start is beyond the end of the file */
+	if (whole_start > fmkey->lfik_oa.o_size) {
+		rc = -EINVAL;
+		goto out_fm_local;
+	}
+	whole_end = (fiemap->fm_length == OBD_OBJECT_EOF) ?
+		     fmkey->lfik_oa.o_size :
+		     whole_start + fiemap->fm_length - 1;
+	/**
+	 * If fiemap->fm_length != OBD_OBJECT_EOF but whole_end exceeds file
+	 * size
+	 */
+	if (whole_end > fmkey->lfik_oa.o_size)
+		whole_end = fmkey->lfik_oa.o_size;
+
+	start_entry = lov_lsm_entry(lsm, whole_start);
+	end_entry = lov_lsm_entry(lsm, whole_end);
+	if (end_entry == -1)
+		end_entry = lsm->lsm_entry_count - 1;
+
+	if (start_entry == -1 || end_entry == -1) {
+		rc = -EINVAL;
+		goto out_fm_local;
+	}
+
+	for (entry = start_entry; entry <= end_entry; entry++) {
+		lsme = lsm->lsm_entries[entry];
+
+		if (entry == start_entry)
+			fs.fs_ext.e_start = whole_start;
+		else
+			fs.fs_ext.e_start = lsme->lsme_extent.e_start;
+		if (entry == end_entry)
+			fs.fs_ext.e_end = whole_end;
+		else
+			fs.fs_ext.e_end = lsme->lsme_extent.e_end - 1;
+		fs.fs_length = fs.fs_ext.e_end - fs.fs_ext.e_start + 1;
+
+		/* Calculate start stripe, last stripe and length of mapping */
+		fs.fs_start_stripe = lov_stripe_number(lsm, entry,
+						       fs.fs_ext.e_start);
+		fs.fs_last_stripe = fiemap_calc_last_stripe(lsm, entry,
+							    &fs.fs_ext,
+							    fs.fs_start_stripe,
+							    &stripe_count);
+		fs.fs_end_offset = fiemap_calc_fm_end_offset(fiemap, lsm, entry,
+							     &fs.fs_ext,
+							     &fs.fs_start_stripe);
+		/* Check each stripe */
+		for (cur_stripe = fs.fs_start_stripe; stripe_count > 0;
+		     --stripe_count,
+		     cur_stripe = (cur_stripe + 1) % lsme->lsme_stripe_count) {
+			rc = fiemap_for_stripe(env, obj, lsm, fiemap, buflen,
+					       fmkey, entry, cur_stripe, &fs);
+			if (rc < 0)
+				goto out_fm_local;
+			if (fs.fs_enough)
+				goto finish;
+			if (fs.fs_finish_stripe)
+				break;
+		 } /* for each stripe */
+	} /* for covering layout component */
 
-	/* Check each stripe */
-	for (cur_stripe = fs.fs_start_stripe; stripe_count > 0;
-	     --stripe_count,
-	     cur_stripe = (cur_stripe + 1) %
-			  lsm->lsm_entries[0]->lsme_stripe_count) {
-		rc = fiemap_for_stripe(env, obj, lsm, fiemap, buflen,
-				       fmkey, 0, cur_stripe, &fs);
-		if (rc < 0)
-			goto out;
-		if (fs.fs_finish)
-			break;
-	} /* for each stripe */
+	/*
+	 * We've traversed all components, set @entry to the last component
+	 * entry, it's for the last stripe check.
+	 */
+	entry--;
+finish:
 	/*
 	 * Indicate that we are returning device offsets unless file just has
 	 * single stripe
 	 */
-	if (lsm->lsm_entries[0]->lsme_stripe_count > 1)
+	if (lsm->lsm_entry_count > 1 ||
+	    (lsm->lsm_entry_count == 1 &&
+	     lsm->lsm_entries[0]->lsme_stripe_count > 1))
 		fiemap->fm_flags |= FIEMAP_FLAG_DEVICE_ORDER;
 
 	if (!fiemap->fm_extent_count)
@@ -1565,8 +1603,9 @@ static int lov_object_fiemap(const struct lu_env *env, struct cl_object *obj,
 							FIEMAP_EXTENT_LAST;
 skip_last_device_calc:
 	fiemap->fm_mapped_extents = fs.fs_cur_extent;
-out:
+out_fm_local:
 	kvfree(fm_local);
+out_lsm:
 	lov_lsm_put(lsm);
 	return rc;
 }
diff --git a/drivers/staging/lustre/lustre/lov/lov_offset.c b/drivers/staging/lustre/lustre/lov/lov_offset.c
index 513f1fd..ab02c34 100644
--- a/drivers/staging/lustre/lustre/lov/lov_offset.c
+++ b/drivers/staging/lustre/lustre/lov/lov_offset.c
@@ -225,9 +225,19 @@ u64 lov_size_to_stripe(struct lov_stripe_md *lsm, int index, u64 file_size,
  * stripe does intersect with the lov extent.
  */
 int lov_stripe_intersects(struct lov_stripe_md *lsm, int index, int stripeno,
-			  u64 start, u64 end, u64 *obd_start, u64 *obd_end)
+			  struct lu_extent *ext, u64 *obd_start, u64 *obd_end)
 {
+	struct lov_stripe_md_entry *entry = lsm->lsm_entries[index];
 	int start_side, end_side;
+	u64 start, end;
+
+	if (!lu_extent_is_overlapped(ext, &entry->lsme_extent))
+		return 0;
+
+	start = max_t(u64, ext->e_start, entry->lsme_extent.e_start);
+	end = min_t(u64, ext->e_end, entry->lsme_extent.e_end);
+	if (end != OBD_OBJECT_EOF)
+		end--;
 
 	start_side = lov_stripe_offset(lsm, index, start, stripeno, obd_start);
 	end_side = lov_stripe_offset(lsm, index, end, stripeno, obd_end);
diff --git a/drivers/staging/lustre/lustre/lov/lov_pack.c b/drivers/staging/lustre/lustre/lov/lov_pack.c
index 8b7a572..ba7c488 100644
--- a/drivers/staging/lustre/lustre/lov/lov_pack.c
+++ b/drivers/staging/lustre/lustre/lov/lov_pack.c
@@ -189,8 +189,8 @@ int lov_free_memmd(struct lov_stripe_md **lsmp)
 	int refc;
 
 	*lsmp = NULL;
-	LASSERT(atomic_read(&lsm->lsm_refc) > 0);
 	refc = atomic_dec_return(&lsm->lsm_refc);
+	LASSERT(refc >= 0);
 	if (refc == 0)
 		lsm_free(lsm);
 
diff --git a/drivers/staging/lustre/lustre/lov/lov_page.c b/drivers/staging/lustre/lustre/lov/lov_page.c
index e227279..f53379a 100644
--- a/drivers/staging/lustre/lustre/lov/lov_page.c
+++ b/drivers/staging/lustre/lustre/lov/lov_page.c
@@ -76,10 +76,16 @@ int lov_page_init_composite(const struct lu_env *env, struct cl_object *obj,
 	u64 offset;
 	u64	    suboff;
 	int		stripe;
-	int entry = 0;
+	int entry;
 	int		rc;
 
 	offset = cl_offset(obj, index);
+	entry = lov_lsm_entry(loo->lo_lsm, offset);
+	if (entry < 0) {
+		/* non-existing layout component */
+		lov_page_init_empty(env, obj, page, index);
+		return 0;
+	}
 
 	r0 = lov_r0(loo, entry);
 	stripe = lov_stripe_number(loo->lo_lsm, entry, offset);
diff --git a/drivers/staging/lustre/lustre/osc/osc_lock.c b/drivers/staging/lustre/lustre/osc/osc_lock.c
index 4cc813d..824c655 100644
--- a/drivers/staging/lustre/lustre/osc/osc_lock.c
+++ b/drivers/staging/lustre/lustre/osc/osc_lock.c
@@ -1128,10 +1128,6 @@ static void osc_lock_set_writer(const struct lu_env *env,
 		io_start = cl_index(obj, io->u.ci_rw.crw_pos);
 		io_end = cl_index(obj, io->u.ci_rw.crw_pos +
 				  io->u.ci_rw.crw_count - 1);
-		if (cl_io_is_append(io)) {
-			io_start = 0;
-			io_end = CL_PAGE_EOF;
-		}
 	} else {
 		LASSERT(cl_io_is_mkwrite(io));
 		io_start = io->u.ci_fault.ft_index;
@@ -1139,7 +1135,8 @@ static void osc_lock_set_writer(const struct lu_env *env,
 	}
 
 	if (descr->cld_mode >= CLM_WRITE &&
-	    descr->cld_start <= io_start && descr->cld_end >= io_end) {
+	    (cl_io_is_append(io) ||
+	     (descr->cld_start <= io_start && descr->cld_end >= io_end))) {
 		struct osc_io *oio = osc_env_io(env);
 
 		/* There must be only one lock to match the write region */
-- 
1.8.3.1
