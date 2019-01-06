From: James Simmons <jsimmons@infradead.org>
Date: Sun,  6 Jan 2019 17:14:07 -0500
Subject: [lustre-devel] [PATCH v2 12/33] lustre: lov: move around PFL code
 and cleanups
In-Reply-To: <1546812868-11794-1-git-send-email-jsimmons@infradead.org>
References: <1546812868-11794-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1546812868-11794-13-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Bobi Jam <bobijam@hotmail.com>

No code changes expect for sub_subio_index that changed type.
Move some code around and some style cleanups. This makes it
clear the real code changes from style updates.

Signed-off-by: Jinshan Xiong <jinshan.xiong@gmail.com>
Signed-off-by: Bobi Jam <bobijam@hotmail.com>
Signed-off-by: Niu Yawei <yawei.niu@intel.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-8998
Reviewed-on: https://review.whamcloud.com/24850
Reviewed-by: Lai Siyao <lai.siyao@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/file.c         |   2 +-
 .../staging/lustre/lustre/lov/lov_cl_internal.h    |  45 ++---
 drivers/staging/lustre/lustre/lov/lov_ea.c         |   5 +-
 drivers/staging/lustre/lustre/lov/lov_io.c         | 181 ++++++++++-----------
 drivers/staging/lustre/lustre/lov/lov_object.c     |  25 +--
 5 files changed, 130 insertions(+), 128 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
index c018c5f..fae0111 100644
--- a/drivers/staging/lustre/lustre/llite/file.c
+++ b/drivers/staging/lustre/lustre/llite/file.c
@@ -3726,6 +3726,7 @@ static int ll_layout_lock_set(struct lustre_handle *lockh, enum ldlm_mode mode,
 	lock_res_and_lock(lock);
 	lvb_ready = ldlm_is_lvb_ready(lock);
 	unlock_res_and_lock(lock);
+
 	/* checking lvb_ready is racy but this is okay. The worst case is
 	 * that multi processes may configure the file on the same time.
 	 */
@@ -3755,7 +3756,6 @@ static int ll_layout_lock_set(struct lustre_handle *lockh, enum ldlm_mode mode,
 
 	/* refresh layout failed, need to wait */
 	wait_layout = rc == -EBUSY;
-
 out:
 	LDLM_LOCK_PUT(lock);
 	ldlm_lock_decref(lockh, mode);
diff --git a/drivers/staging/lustre/lustre/lov/lov_cl_internal.h b/drivers/staging/lustre/lustre/lov/lov_cl_internal.h
index 99bd1c1..ce32823 100644
--- a/drivers/staging/lustre/lustre/lov/lov_cl_internal.h
+++ b/drivers/staging/lustre/lustre/lov/lov_cl_internal.h
@@ -315,12 +315,6 @@ struct lov_thread_info {
  */
 struct lov_io_sub {
 	/**
-	 * environment's refcheck.
-	 *
-	 * \see cl_env_get()
-	 */
-	u16			 sub_refcheck;
-	/**
 	 * true, iff cl_io_init() was successfully executed against
 	 * lov_io_sub::sub_io.
 	 */
@@ -334,18 +328,24 @@ struct lov_io_sub {
 	 * Linkage into a list (hanging off lov_io::lis_active) of all
 	 * sub-io's active for the current IO iteration.
 	 */
-	struct list_head	 sub_linkage;
-	u16			sub_subio_index;
+	struct list_head	sub_linkage;
+	unsigned int		sub_subio_index;
 	/**
 	 * sub-io for a stripe. Ideally sub-io's can be stopped and resumed
 	 * independently, with lov acting as a scheduler to maximize overall
 	 * throughput.
 	 */
-	struct cl_io	*sub_io;
+	struct cl_io		*sub_io;
 	/**
 	 * environment, in which sub-io executes.
 	 */
-	struct lu_env *sub_env;
+	struct lu_env		*sub_env;
+	/**
+	 * environment's refcheck.
+	 *
+	 * \see cl_env_get()
+	 */
+	u16			sub_refcheck;
 };
 
 /**
@@ -367,37 +367,38 @@ struct lov_io {
 	 *
 	 * This is used only for CIT_READ and CIT_WRITE io's.
 	 */
-	loff_t	     lis_io_endpos;
+	loff_t			lis_io_endpos;
 
 	/**
 	 * starting position within a file, for the current io loop iteration
 	 * (stripe), used by ci_io_loop().
 	 */
-	u64	    lis_pos;
+	u64			lis_pos;
 	/**
 	 * end position with in a file, for the current stripe io. This is
 	 * exclusive (i.e., next offset after last byte affected by io).
 	 */
-	u64	    lis_endpos;
-
-	int		lis_stripe_count;
-	int		lis_active_subios;
+	u64			lis_endpos;
+	int			lis_stripe_count;
+	int			lis_active_subios;
 
 	/**
 	 * the index of ls_single_subio in ls_subios array
 	 */
-	int		lis_single_subio_index;
-	struct cl_io       lis_single_subio;
+	int			lis_single_subio_index;
+	struct cl_io		lis_single_subio;
+
+	/**
+	 * List of active sub-io's. Active sub-io's are under the range
+	 * of [lis_pos, lis_endpos).
+	 */
+	struct list_head	lis_active;
 
 	/**
 	 * size of ls_subios array, actually the highest stripe #
 	 */
 	int		lis_nr_subios;
 	struct lov_io_sub *lis_subs;
-	/**
-	 * List of active sub-io's.
-	 */
-	struct list_head	 lis_active;
 };
 
 struct lov_session {
diff --git a/drivers/staging/lustre/lustre/lov/lov_ea.c b/drivers/staging/lustre/lustre/lov/lov_ea.c
index 7d86318..f2a5a60 100644
--- a/drivers/staging/lustre/lustre/lov/lov_ea.c
+++ b/drivers/staging/lustre/lustre/lov/lov_ea.c
@@ -338,7 +338,7 @@ void lsm_free(struct lov_stripe_md *lsm)
 const static struct lsm_operations lsm_v1_ops = {
 	.lsm_stripe_by_index    = lsm_stripe_by_index_plain,
 	.lsm_stripe_by_offset   = lsm_stripe_by_offset_plain,
-	.lsm_unpackmd	   = lsm_unpackmd_v1,
+	.lsm_unpackmd		= lsm_unpackmd_v1,
 };
 
 static struct lov_stripe_md *
@@ -531,7 +531,8 @@ const struct lsm_operations *lsm_op_find(int magic)
 
 void dump_lsm(unsigned int level, const struct lov_stripe_md *lsm)
 {
-	CDEBUG(level, "lsm %p, objid " DOSTID ", maxbytes %#llx, magic 0x%08X, stripe_size %u, stripe_count %u, refc: %d, layout_gen %u, pool [" LOV_POOLNAMEF "]\n",
+	CDEBUG(level,
+	       "lsm %p, objid " DOSTID ", maxbytes %#llx, magic 0x%08X, stripe_size %u, stripe_count %u, refc: %d, layout_gen %u, pool [" LOV_POOLNAMEF "]\n",
 	       lsm, POSTID(&lsm->lsm_oi), lsm->lsm_maxbytes, lsm->lsm_magic,
 	       lsm->lsm_entries[0]->lsme_stripe_size,
 	       lsm->lsm_entries[0]->lsme_stripe_count,
diff --git a/drivers/staging/lustre/lustre/lov/lov_io.c b/drivers/staging/lustre/lustre/lov/lov_io.c
index 26d0043..ab97326 100644
--- a/drivers/staging/lustre/lustre/lov/lov_io.c
+++ b/drivers/staging/lustre/lustre/lov/lov_io.c
@@ -43,7 +43,6 @@
 /** \addtogroup lov
  *  @{
  */
-
 static void lov_io_sub_fini(const struct lu_env *env, struct lov_io *lio,
 			    struct lov_io_sub *sub)
 {
@@ -66,76 +65,6 @@ static void lov_io_sub_fini(const struct lu_env *env, struct lov_io *lio,
 	}
 }
 
-static void lov_io_sub_inherit(struct cl_io *io, struct lov_io *lio,
-			       int stripe, loff_t start, loff_t end)
-{
-	struct lov_stripe_md *lsm    = lio->lis_object->lo_lsm;
-	struct cl_io	 *parent = lio->lis_cl.cis_io;
-
-	switch (io->ci_type) {
-	case CIT_SETATTR: {
-		io->u.ci_setattr.sa_attr = parent->u.ci_setattr.sa_attr;
-		io->u.ci_setattr.sa_attr_flags =
-					parent->u.ci_setattr.sa_attr_flags;
-		io->u.ci_setattr.sa_avalid = parent->u.ci_setattr.sa_avalid;
-		io->u.ci_setattr.sa_xvalid = parent->u.ci_setattr.sa_xvalid;
-		io->u.ci_setattr.sa_stripe_index = stripe;
-		io->u.ci_setattr.sa_parent_fid =
-					parent->u.ci_setattr.sa_parent_fid;
-		if (cl_io_is_trunc(io)) {
-			loff_t new_size = parent->u.ci_setattr.sa_attr.lvb_size;
-
-			new_size = lov_size_to_stripe(lsm, 0, new_size, stripe);
-			io->u.ci_setattr.sa_attr.lvb_size = new_size;
-		}
-		break;
-	}
-	case CIT_DATA_VERSION: {
-		io->u.ci_data_version.dv_data_version = 0;
-		io->u.ci_data_version.dv_flags =
-			parent->u.ci_data_version.dv_flags;
-		break;
-	}
-	case CIT_FAULT: {
-		struct cl_object *obj = parent->ci_obj;
-		loff_t off = cl_offset(obj, parent->u.ci_fault.ft_index);
-
-		io->u.ci_fault = parent->u.ci_fault;
-		off = lov_size_to_stripe(lsm, 0, off, stripe);
-		io->u.ci_fault.ft_index = cl_index(obj, off);
-		break;
-	}
-	case CIT_FSYNC: {
-		io->u.ci_fsync.fi_start = start;
-		io->u.ci_fsync.fi_end = end;
-		io->u.ci_fsync.fi_fid = parent->u.ci_fsync.fi_fid;
-		io->u.ci_fsync.fi_mode = parent->u.ci_fsync.fi_mode;
-		break;
-	}
-	case CIT_READ:
-	case CIT_WRITE: {
-		io->u.ci_wr.wr_sync = cl_io_is_sync_write(parent);
-		if (cl_io_is_append(parent)) {
-			io->u.ci_wr.wr_append = 1;
-		} else {
-			io->u.ci_rw.crw_pos = start;
-			io->u.ci_rw.crw_count = end - start;
-		}
-		break;
-	}
-	case CIT_LADVISE: {
-		io->u.ci_ladvise.li_start = start;
-		io->u.ci_ladvise.li_end = end;
-		io->u.ci_ladvise.li_fid = parent->u.ci_ladvise.li_fid;
-		io->u.ci_ladvise.li_advice = parent->u.ci_ladvise.li_advice;
-		io->u.ci_ladvise.li_flags = parent->u.ci_ladvise.li_flags;
-		break;
-	}
-	default:
-		break;
-	}
-}
-
 static int lov_io_sub_init(const struct lu_env *env, struct lov_io *lio,
 			   struct lov_io_sub *sub)
 {
@@ -228,7 +157,6 @@ struct lov_io_sub *lov_sub_get(const struct lu_env *env,
  * Lov io operations.
  *
  */
-
 static int lov_page_index(const struct cl_page *page)
 {
 	const struct cl_page_slice *slice;
@@ -358,6 +286,76 @@ static void lov_io_fini(const struct lu_env *env, const struct cl_io_slice *ios)
 		wake_up_all(&lov->lo_waitq);
 }
 
+static void lov_io_sub_inherit(struct cl_io *io, struct lov_io *lio,
+			       int stripe, loff_t start, loff_t end)
+{
+	struct lov_stripe_md *lsm = lio->lis_object->lo_lsm;
+	struct cl_io *parent = lio->lis_cl.cis_io;
+
+	switch (io->ci_type) {
+	case CIT_SETATTR: {
+		io->u.ci_setattr.sa_attr = parent->u.ci_setattr.sa_attr;
+		io->u.ci_setattr.sa_attr_flags =
+			parent->u.ci_setattr.sa_attr_flags;
+		io->u.ci_setattr.sa_avalid = parent->u.ci_setattr.sa_avalid;
+		io->u.ci_setattr.sa_xvalid = parent->u.ci_setattr.sa_xvalid;
+		io->u.ci_setattr.sa_stripe_index = stripe;
+		io->u.ci_setattr.sa_parent_fid =
+			parent->u.ci_setattr.sa_parent_fid;
+		if (cl_io_is_trunc(io)) {
+			loff_t new_size = parent->u.ci_setattr.sa_attr.lvb_size;
+
+			new_size = lov_size_to_stripe(lsm, 0, new_size, stripe);
+			io->u.ci_setattr.sa_attr.lvb_size = new_size;
+		}
+		break;
+	}
+	case CIT_DATA_VERSION: {
+		io->u.ci_data_version.dv_data_version = 0;
+		io->u.ci_data_version.dv_flags =
+			parent->u.ci_data_version.dv_flags;
+		break;
+	}
+	case CIT_FAULT: {
+		struct cl_object *obj = parent->ci_obj;
+		loff_t off = cl_offset(obj, parent->u.ci_fault.ft_index);
+
+		io->u.ci_fault = parent->u.ci_fault;
+		off = lov_size_to_stripe(lsm, 0, off, stripe);
+		io->u.ci_fault.ft_index = cl_index(obj, off);
+		break;
+	}
+	case CIT_FSYNC: {
+		io->u.ci_fsync.fi_start = start;
+		io->u.ci_fsync.fi_end = end;
+		io->u.ci_fsync.fi_fid = parent->u.ci_fsync.fi_fid;
+		io->u.ci_fsync.fi_mode = parent->u.ci_fsync.fi_mode;
+		break;
+	}
+	case CIT_READ:
+	case CIT_WRITE: {
+		io->u.ci_wr.wr_sync = cl_io_is_sync_write(parent);
+		if (cl_io_is_append(parent)) {
+			io->u.ci_wr.wr_append = 1;
+		} else {
+			io->u.ci_rw.crw_pos = start;
+			io->u.ci_rw.crw_count = end - start;
+		}
+		break;
+	}
+	case CIT_LADVISE: {
+		io->u.ci_ladvise.li_start = start;
+		io->u.ci_ladvise.li_end = end;
+		io->u.ci_ladvise.li_fid = parent->u.ci_ladvise.li_fid;
+		io->u.ci_ladvise.li_advice = parent->u.ci_ladvise.li_advice;
+		io->u.ci_ladvise.li_flags = parent->u.ci_ladvise.li_flags;
+		break;
+	}
+	default:
+		break;
+	}
+}
+
 static u64 lov_offset_mod(u64 val, int delta)
 {
 	if (val != OBD_OBJECT_EOF)
@@ -491,24 +489,6 @@ static int lov_io_end_wrapper(const struct lu_env *env, struct cl_io *io)
 	return 0;
 }
 
-static void
-lov_io_data_version_end(const struct lu_env *env, const struct cl_io_slice *ios)
-{
-	struct lov_io *lio = cl2lov_io(env, ios);
-	struct cl_io *parent = lio->lis_cl.cis_io;
-	struct lov_io_sub *sub;
-
-	list_for_each_entry(sub, &lio->lis_active, sub_linkage) {
-		lov_io_end_wrapper(sub->sub_env, sub->sub_io);
-
-		parent->u.ci_data_version.dv_data_version +=
-			sub->sub_io->u.ci_data_version.dv_data_version;
-
-		if (!parent->ci_result)
-			parent->ci_result = sub->sub_io->ci_result;
-	}
-}
-
 static int lov_io_iter_fini_wrapper(const struct lu_env *env, struct cl_io *io)
 {
 	cl_io_iter_fini(env, io);
@@ -529,6 +509,24 @@ static void lov_io_end(const struct lu_env *env, const struct cl_io_slice *ios)
 	LASSERT(rc == 0);
 }
 
+static void
+lov_io_data_version_end(const struct lu_env *env, const struct cl_io_slice *ios)
+{
+	struct lov_io *lio = cl2lov_io(env, ios);
+	struct cl_io *parent = lio->lis_cl.cis_io;
+	struct lov_io_sub *sub;
+
+	list_for_each_entry(sub, &lio->lis_active, sub_linkage) {
+		lov_io_end_wrapper(sub->sub_env, sub->sub_io);
+
+		parent->u.ci_data_version.dv_data_version +=
+			sub->sub_io->u.ci_data_version.dv_data_version;
+
+		if (!parent->ci_result)
+			parent->ci_result = sub->sub_io->ci_result;
+	}
+}
+
 static void lov_io_iter_fini(const struct lu_env *env,
 			     const struct cl_io_slice *ios)
 {
@@ -602,7 +600,8 @@ static int lov_io_read_ahead(const struct lu_env *env,
 
 	pps = loo->lo_lsm->lsm_entries[0]->lsme_stripe_size >> PAGE_SHIFT;
 
-	CDEBUG(D_READA, DFID " max_index = %lu, pps = %u, stripe_size = %u, stripe no = %u, start index = %lu\n",
+	CDEBUG(D_READA,
+	       DFID " max_index = %lu, pps = %u, stripe_size = %u, stripe no = %u, start index = %lu\n",
 	       PFID(lu_object_fid(lov2lu(loo))), ra_end, pps,
 	       loo->lo_lsm->lsm_entries[0]->lsme_stripe_size, stripe, start);
 
diff --git a/drivers/staging/lustre/lustre/lov/lov_object.c b/drivers/staging/lustre/lustre/lov/lov_object.c
index de5e2a2..3677fac 100644
--- a/drivers/staging/lustre/lustre/lov/lov_object.c
+++ b/drivers/staging/lustre/lustre/lov/lov_object.c
@@ -600,6 +600,7 @@ static int lov_attr_get_raid0(const struct lu_env *env, struct lov_object *lov,
 		return 0;
 
 	memset(lvb, 0, sizeof(*lvb));
+
 	/* XXX: timestamps can be negative by sanity:test_39m,
 	 * how can it be?
 	 */
@@ -1200,18 +1201,18 @@ static u64 fiemap_calc_fm_end_offset(struct fiemap *fiemap,
 }
 
 struct fiemap_state {
-	struct fiemap	*fs_fm;
-	u64		fs_start;
-	u64		fs_length;
-	u64		fs_end;
-	u64		fs_end_offset;
-	int		fs_cur_extent;
-	int		fs_cnt_need;
-	int		fs_start_stripe;
-	int		fs_last_stripe;
-	bool		fs_device_done;
-	bool		fs_finish;
-	bool		fs_enough;
+	struct fiemap		*fs_fm;
+	u64			fs_start;
+	u64			fs_length;
+	u64			fs_end;
+	u64			fs_end_offset;
+	int			fs_cur_extent;
+	int			fs_cnt_need;
+	int			fs_start_stripe;
+	int			fs_last_stripe;
+	bool			fs_device_done;
+	bool			fs_finish;
+	bool			fs_enough;
 };
 
 static int fiemap_for_stripe(const struct lu_env *env, struct cl_object *obj,
-- 
1.8.3.1
