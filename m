From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Sep 2019 14:55:29 -0400
Subject: [lustre-devel] [PATCH 070/151] lustre: flr: Send write intent RPC
 to mdt
In-Reply-To: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1569869810-23848-71-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Jinshan Xiong <jinshan.xiong@gmail.com>

When a mirrored file is going to be written, the client needs
to send a write intent RPC to the MDT. The MDT will pick a mirror
as primary and mark the others as stale. The new md operation
moo_layout_change() is introduced for this purpose. The MDT also
transfers the latest layout version to the OST objects via
do_attr_set().

Once OSTs receive the setattr RPC for layout version change, it
will set the update layout version into extended attribute
XATTR_NAME_FID.

WC-bug-id: https://jira.whamcloud.com/browse/LU-9771
Lustre-commit: 10da8afb2786 ("LU-9771 flr: Send write intent RPC to mdt")
Signed-off-by: Jinshan Xiong <jinshan.xiong@gmail.com>
Reviewed-on: https://review.whamcloud.com/29091
Reviewed-by: Lai Siyao <lai.siyao@whamcloud.com>
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/cl_object.h           |   8 ++-
 fs/lustre/include/lustre_osc.h          |   7 +-
 fs/lustre/include/obd.h                 |   5 +-
 fs/lustre/include/obd_support.h         |   2 +
 fs/lustre/llite/file.c                  |   4 +-
 fs/lustre/llite/vvp_object.c            |   7 ++
 fs/lustre/lov/lov_cl_internal.h         |   3 +
 fs/lustre/lov/lov_io.c                  | 121 +++++++++++++++++++++++++++++---
 fs/lustre/lov/lov_object.c              |   4 +-
 fs/lustre/lov/lov_page.c                |   5 +-
 fs/lustre/osc/osc_cache.c               |   9 ++-
 fs/lustre/osc/osc_io.c                  |  10 ++-
 fs/lustre/osc/osc_request.c             |  12 +++-
 fs/lustre/ptlrpc/pack_generic.c         |  11 ++-
 fs/lustre/ptlrpc/wiretest.c             |  20 +++---
 include/uapi/linux/lustre/lustre_idl.h  |   6 +-
 include/uapi/linux/lustre/lustre_user.h |  10 ++-
 17 files changed, 202 insertions(+), 42 deletions(-)

diff --git a/fs/lustre/include/cl_object.h b/fs/lustre/include/cl_object.h
index 45068ca..ef7ba76 100644
--- a/fs/lustre/include/cl_object.h
+++ b/fs/lustre/include/cl_object.h
@@ -1775,6 +1775,8 @@ struct cl_io {
 	struct cl_lockset	ci_lockset;
 	/** lock requirements, this is just a help info for sublayers. */
 	enum cl_io_lock_dmd	ci_lockreq;
+	/** layout version when this IO occurs */
+	u32			ci_layout_version;
 	union {
 		struct cl_rd_io {
 			struct cl_io_rw_common	rd;
@@ -1850,8 +1852,10 @@ struct cl_io {
 	 */
 				ci_ignore_layout:1,
 	/**
-	 * Need MDS intervention to complete a write. This usually means the
-	 * corresponding component is not initialized for the writing extent.
+	 * Need MDS intervention to complete a write.
+	 * Write intent is required for the following cases:
+	 * 1. component being written is not initialized, or
+	 * 2. the mirrored files are NOT in WRITE_PENDING state.
 	 */
 				ci_need_write_intent:1,
 	/**
diff --git a/fs/lustre/include/lustre_osc.h b/fs/lustre/include/lustre_osc.h
index 5efceef..a81e802 100644
--- a/fs/lustre/include/lustre_osc.h
+++ b/fs/lustre/include/lustre_osc.h
@@ -586,8 +586,9 @@ int osc_teardown_async_page(const struct lu_env *env, struct osc_object *obj,
 			    struct osc_page *ops);
 int osc_flush_async_page(const struct lu_env *env, struct cl_io *io,
 			 struct osc_page *ops);
-int osc_queue_sync_pages(const struct lu_env *env, struct osc_object *obj,
-			 struct list_head *list, int brw_flags);
+int osc_queue_sync_pages(const struct lu_env *env, const struct cl_io *io,
+			 struct osc_object *obj, struct list_head *list,
+			 int brw_flags);
 int osc_cache_truncate_start(const struct lu_env *env, struct osc_object *obj,
 			     u64 size, struct osc_extent **extp);
 void osc_cache_truncate_end(const struct lu_env *env, struct osc_extent *ext);
@@ -968,6 +969,8 @@ struct osc_extent {
 	int			oe_rc;
 	/* max pages per rpc when this extent was created */
 	unsigned int		oe_mppr;
+	/* FLR: layout version when this osc_extent is publised */
+	u32			oe_layout_version;
 };
 
 /* @} osc */
diff --git a/fs/lustre/include/obd.h b/fs/lustre/include/obd.h
index 2f586cb..c377a91 100644
--- a/fs/lustre/include/obd.h
+++ b/fs/lustre/include/obd.h
@@ -687,9 +687,10 @@ static inline int it_to_lock_mode(struct lookup_intent *it)
 	/* CREAT needs to be tested before open (both could be set) */
 	if (it->it_op & IT_CREAT)
 		return LCK_CW;
-	else if (it->it_op & (IT_GETATTR | IT_OPEN | IT_LOOKUP |
-			      IT_LAYOUT))
+	else if (it->it_op & (IT_GETATTR | IT_OPEN | IT_LOOKUP))
 		return LCK_CR;
+	else if (it->it_op & IT_LAYOUT)
+		return (it->it_flags & FMODE_WRITE) ? LCK_EX : LCK_CR;
 	else if (it->it_op & IT_READDIR)
 		return LCK_PR;
 	else if (it->it_op &  IT_GETXATTR)
diff --git a/fs/lustre/include/obd_support.h b/fs/lustre/include/obd_support.h
index e6dff44b..9d383f5 100644
--- a/fs/lustre/include/obd_support.h
+++ b/fs/lustre/include/obd_support.h
@@ -476,6 +476,8 @@
 
 /* FLR */
 #define OBD_FAIL_FLR_GLIMPSE_IMMUTABLE			0x1A00
+#define OBD_FAIL_FLR_LV_DELAY			0x1A01
+#define OBD_FAIL_FLR_LV_INC			0x1A02
 
 /* Assign references to moved code to reduce code changes */
 #define OBD_FAIL_PRECHECK(id)			CFS_FAIL_PRECHECK(id)
diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index 1856aa6..9b441ba 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -4206,8 +4206,8 @@ int ll_layout_write_intent(struct inode *inode, u64 start, u64 end)
 {
 	struct layout_intent intent = {
 		.li_opc = LAYOUT_INTENT_WRITE,
-		.li_start = start,
-		.li_end = end,
+		.li_extent.e_start = start,
+		.li_extent.e_end = end,
 	};
 	int rc;
 
diff --git a/fs/lustre/llite/vvp_object.c b/fs/lustre/llite/vvp_object.c
index 1637972..549837f 100644
--- a/fs/lustre/llite/vvp_object.c
+++ b/fs/lustre/llite/vvp_object.c
@@ -165,6 +165,13 @@ static int vvp_prune(const struct lu_env *env, struct cl_object *obj)
 	}
 
 	truncate_inode_pages(inode->i_mapping, 0);
+	if (inode->i_mapping->nrpages) {
+		CDEBUG(D_VFSTRACE, DFID ": still has %lu pages remaining\n",
+		       PFID(lu_object_fid(&obj->co_lu)),
+		       inode->i_mapping->nrpages);
+		return -EIO;
+	}
+
 	return 0;
 }
 
diff --git a/fs/lustre/lov/lov_cl_internal.h b/fs/lustre/lov/lov_cl_internal.h
index 94a5638..ad4a3d3 100644
--- a/fs/lustre/lov/lov_cl_internal.h
+++ b/fs/lustre/lov/lov_cl_internal.h
@@ -230,6 +230,7 @@ struct lov_layout_entry {
 struct lov_mirror_entry {
 	unsigned short	lre_mirror_id;
 	unsigned short	lre_preferred:1,
+			lre_stale:1,	/* set if any components is stale */
 			lre_valid:1;	/* set if at least one of components
 					 * in this mirror is valid
 					 */
@@ -438,6 +439,8 @@ struct lov_page {
 	struct cl_page_slice	lps_cl;
 	/** layout_entry + stripe index, composed using lov_comp_index() */
 	unsigned int		lps_index;
+	/* the layout gen when this page was created */
+	u32			lps_layout_gen;
 };
 
 /*
diff --git a/fs/lustre/lov/lov_io.c b/fs/lustre/lov/lov_io.c
index 22ca77e..3d3f07f 100644
--- a/fs/lustre/lov/lov_io.c
+++ b/fs/lustre/lov/lov_io.c
@@ -136,6 +136,7 @@ static int lov_io_sub_init(const struct lu_env *env, struct lov_io *lio,
 	sub_io->ci_noatime = io->ci_noatime;
 	sub_io->ci_lock_no_expand = io->ci_lock_no_expand;
 	sub_io->ci_ndelay = io->ci_ndelay;
+	sub_io->ci_layout_version = io->ci_layout_version;
 
 	rc = cl_io_sub_init(sub->sub_env, sub_io, io->ci_type, sub_obj);
 	if (rc < 0)
@@ -208,12 +209,88 @@ static int lov_io_subio_init(const struct lu_env *env, struct lov_io *lio,
 	return 0;
 }
 
+/**
+ * Decide if it will need write intent RPC
+ */
+static int lov_io_mirror_write_intent(struct lov_io *lio,
+	struct lov_object *obj, struct cl_io *io)
+{
+	struct lov_layout_composite *comp = &obj->u.composite;
+	struct lu_extent *ext = &io->ci_write_intent;
+	struct lov_mirror_entry *lre;
+	struct lov_mirror_entry *primary;
+	struct lov_layout_entry *lle;
+	size_t count = 0;
+
+	*ext = (typeof(*ext)) { lio->lis_pos, lio->lis_endpos };
+	io->ci_need_write_intent = 0;
+
+	if (!(io->ci_type == CIT_WRITE || cl_io_is_trunc(io) ||
+	      cl_io_is_mkwrite(io)))
+		return 0;
+
+	if (lov_flr_state(obj) == LCM_FL_RDONLY ||
+	    lov_flr_state(obj) == LCM_FL_SYNC_PENDING) {
+		io->ci_need_write_intent = 1;
+		return 0;
+	}
+
+	LASSERT((lov_flr_state(obj) == LCM_FL_WRITE_PENDING));
+	LASSERT(comp->lo_preferred_mirror >= 0);
+
+	/* need to iterate all components to see if there are
+	 * multiple components covering the writing component
+	 */
+	primary = &comp->lo_mirrors[comp->lo_preferred_mirror];
+	LASSERT(!primary->lre_stale);
+	lov_foreach_mirror_layout_entry(obj, lle, primary) {
+		LASSERT(lle->lle_valid);
+		if (!lu_extent_is_overlapped(ext, lle->lle_extent))
+			continue;
+
+		ext->e_start = min(ext->e_start, lle->lle_extent->e_start);
+		ext->e_end = max(ext->e_end, lle->lle_extent->e_end);
+		++count;
+	}
+	if (count == 0) {
+		CERROR(DFID ": cannot find any valid components covering file extent " DEXT ", mirror: %d\n",
+		       PFID(lu_object_fid(lov2lu(obj))), PEXT(ext),
+		       primary->lre_mirror_id);
+		return -EIO;
+	}
+
+	count = 0;
+	lov_foreach_mirror_entry(obj, lre) {
+		if (lre == primary)
+			continue;
+
+		lov_foreach_mirror_layout_entry(obj, lle, lre) {
+			if (!lle->lle_valid)
+				continue;
+
+			if (lu_extent_is_overlapped(ext, lle->lle_extent)) {
+				++count;
+				break;
+			}
+		}
+	}
+
+	CDEBUG(D_VFSTRACE,
+	       DFID "there are %zd components to be staled to modify file extent " DEXT ", iot: %d\n",
+	       PFID(lu_object_fid(lov2lu(obj))), count, PEXT(ext), io->ci_type);
+
+	io->ci_need_write_intent = count > 0;
+
+	return 0;
+}
+
 static int lov_io_mirror_init(struct lov_io *lio, struct lov_object *obj,
 			       struct cl_io *io)
 {
 	struct lov_layout_composite *comp = &obj->u.composite;
 	int index;
 	int i;
+	int result;
 
 	if (!lov_is_flr(obj)) {
 		LASSERT(comp->lo_preferred_mirror == 0);
@@ -222,6 +299,22 @@ static int lov_io_mirror_init(struct lov_io *lio, struct lov_object *obj,
 		return 0;
 	}
 
+	result = lov_io_mirror_write_intent(lio, obj, io);
+	if (result)
+		return result;
+
+	if (io->ci_need_write_intent) {
+		CDEBUG(D_VFSTRACE, DFID " need write intent for [%llu, %llu)\n",
+		       PFID(lu_object_fid(lov2lu(obj))),
+		       lio->lis_pos, lio->lis_endpos);
+
+		/* stop cl_io_init() loop */
+		return 1;
+	}
+
+	/* transfer the layout version for verification */
+	io->ci_layout_version = obj->lo_lsm->lsm_layout_gen;
+
 	if (io->ci_ndelay_tried == 0 || /* first time to try */
 	    /* reset the mirror index if layout has changed */
 	    lio->lis_mirror_layout_gen != obj->lo_lsm->lsm_layout_gen) {
@@ -325,8 +418,10 @@ static int lov_io_slice_init(struct lov_io *lio, struct lov_object *obj,
 			 * the current file-tail exactly.
 			 */
 			if (unlikely(obj->lo_lsm->lsm_entries[0]->lsme_pattern &
-				     LOV_PATTERN_F_HOLE))
-				return -EIO;
+				     LOV_PATTERN_F_HOLE)) {
+				result = -EIO;
+				goto out;
+			}
 
 			lio->lis_pos = 0;
 			lio->lis_endpos = OBD_OBJECT_EOF;
@@ -371,8 +466,11 @@ static int lov_io_slice_init(struct lov_io *lio, struct lov_object *obj,
 		lio->lis_endpos = OBD_OBJECT_EOF;
 
 		if (lov_flr_state(obj) == LCM_FL_RDONLY &&
-		    !OBD_FAIL_CHECK(OBD_FAIL_FLR_GLIMPSE_IMMUTABLE))
-			return 1; /* SoM is accurate, no need glimpse */
+		    !OBD_FAIL_CHECK(OBD_FAIL_FLR_GLIMPSE_IMMUTABLE)) {
+			/* SoM is accurate, no need glimpse */
+			result = 1;
+			goto out;
+		}
 		break;
 
 	case CIT_MISC:
@@ -385,12 +483,14 @@ static int lov_io_slice_init(struct lov_io *lio, struct lov_object *obj,
 	}
 	result = lov_io_mirror_init(lio, obj, io);
 	if (result)
-		return result;
+		goto out;
 
 	/* check if it needs to instantiate layout */
 	if (!(io->ci_type == CIT_WRITE || cl_io_is_mkwrite(io) ||
-	      (cl_io_is_trunc(io) && io->u.ci_setattr.sa_attr.lvb_size > 0)))
-		return 0;
+	      (cl_io_is_trunc(io) && io->u.ci_setattr.sa_attr.lvb_size > 0))) {
+		result = 0;
+		goto out;
+	}
 
 	ext.e_start = lio->lis_pos;
 	ext.e_end = lio->lis_endpos;
@@ -409,10 +509,11 @@ static int lov_io_slice_init(struct lov_io *lio, struct lov_object *obj,
 			io->ci_need_write_intent = 1;
 			io->ci_write_intent = ext;
 			result = 1;
-			break;
+			goto out;
 		}
 	}
 
+out:
 	return result;
 }
 
@@ -799,6 +900,10 @@ static int lov_io_read_ahead(const struct lu_env *env,
 	if (index < 0 || !lsm_entry_inited(loo->lo_lsm, index))
 		return -ENODATA;
 
+	/* avoid readahead to expand to stale components */
+	if (!lov_entry(loo, index)->lle_valid)
+		return -EIO;
+
 	stripe = lov_stripe_number(loo->lo_lsm, index, offset);
 
 	r0 = lov_r0(loo, index);
diff --git a/fs/lustre/lov/lov_object.c b/fs/lustre/lov/lov_object.c
index 42acc78..f606e04 100644
--- a/fs/lustre/lov/lov_object.c
+++ b/fs/lustre/lov/lov_object.c
@@ -675,6 +675,7 @@ static int lov_init_composite(const struct lu_env *env, struct lov_device *dev,
 		if (i > 0) {
 			if (mirror_id == lre->lre_mirror_id) {
 				lre->lre_valid |= lle->lle_valid;
+				lre->lre_stale |= !lle->lle_valid;
 				lre->lre_end = i;
 				continue;
 			}
@@ -696,6 +697,7 @@ static int lov_init_composite(const struct lu_env *env, struct lov_device *dev,
 		lre->lre_preferred = (lle->lle_lsme->lsme_flags &
 					LCME_FL_PREFERRED);
 		lre->lre_valid = lle->lle_valid;
+		lre->lre_stale = !lle->lle_valid;
 	}
 
 	/* sanity check for FLR */
@@ -737,7 +739,7 @@ static int lov_init_composite(const struct lu_env *env, struct lov_device *dev,
 	i = 0;
 	lov_foreach_mirror_entry(lov, lre) {
 		i++;
-		if (!lre->lre_valid)
+		if (lre->lre_stale)
 			continue;
 
 		mirror_count++; /* valid mirror */
diff --git a/fs/lustre/lov/lov_page.c b/fs/lustre/lov/lov_page.c
index ad2a4e7..327bcd3 100644
--- a/fs/lustre/lov/lov_page.c
+++ b/fs/lustre/lov/lov_page.c
@@ -57,8 +57,8 @@ static int lov_comp_page_print(const struct lu_env *env,
 	struct lov_page *lp = cl2lov_page(slice);
 
 	return (*printer)(env, cookie,
-			  LUSTRE_LOV_NAME "-page@%p, comp index: %x\n",
-			  lp, lp->lps_index);
+			  LUSTRE_LOV_NAME "-page@%p, comp index: %x, gen: %u\n",
+			  lp, lp->lps_index, lp->lps_layout_gen);
 }
 
 static const struct cl_page_operations lov_comp_page_ops = {
@@ -96,6 +96,7 @@ int lov_page_init_composite(const struct lu_env *env, struct cl_object *obj,
 	LASSERT(rc == 0);
 
 	lpg->lps_index = lov_comp_index(entry, stripe);
+	lpg->lps_layout_gen = loo->lo_lsm->lsm_layout_gen;
 	cl_page_slice_add(page, &lpg->lps_cl, obj, index, &lov_comp_page_ops);
 
 	sub = lov_sub_get(env, lio, lpg->lps_index);
diff --git a/fs/lustre/osc/osc_cache.c b/fs/lustre/osc/osc_cache.c
index 4ddca32..e387b7a 100644
--- a/fs/lustre/osc/osc_cache.c
+++ b/fs/lustre/osc/osc_cache.c
@@ -2479,6 +2479,9 @@ int osc_queue_async_io(const struct lu_env *env, struct cl_io *io,
 		++ext->oe_nr_pages;
 		list_add_tail(&oap->oap_pending_item, &ext->oe_pages);
 		osc_object_unlock(osc);
+
+		if (!ext->oe_layout_version)
+			ext->oe_layout_version = io->ci_layout_version;
 	}
 
 	return rc;
@@ -2604,8 +2607,9 @@ int osc_flush_async_page(const struct lu_env *env, struct cl_io *io,
 	return rc;
 }
 
-int osc_queue_sync_pages(const struct lu_env *env, struct osc_object *obj,
-			 struct list_head *list, int brw_flags)
+int osc_queue_sync_pages(const struct lu_env *env, const struct cl_io *io,
+			 struct osc_object *obj, struct list_head *list,
+			 int brw_flags)
 {
 	struct client_obd *cli = osc_cli(obj);
 	struct osc_extent *ext;
@@ -2656,6 +2660,7 @@ int osc_queue_sync_pages(const struct lu_env *env, struct osc_object *obj,
 	ext->oe_nr_pages = page_count;
 	ext->oe_mppr = mppr;
 	list_splice_init(list, &ext->oe_pages);
+	ext->oe_layout_version = io->ci_layout_version;
 
 	osc_object_lock(obj);
 	/* Reuse the initial refcount for RPC, don't drop it */
diff --git a/fs/lustre/osc/osc_io.c b/fs/lustre/osc/osc_io.c
index b26d513..8bdfadb 100644
--- a/fs/lustre/osc/osc_io.c
+++ b/fs/lustre/osc/osc_io.c
@@ -188,7 +188,7 @@ int osc_io_submit(const struct lu_env *env, const struct cl_io_slice *ios,
 
 		if (++queued == max_pages) {
 			queued = 0;
-			result = osc_queue_sync_pages(env, osc, &list,
+			result = osc_queue_sync_pages(env, io, osc, &list,
 						      brw_flags);
 			if (result < 0)
 				break;
@@ -196,7 +196,7 @@ int osc_io_submit(const struct lu_env *env, const struct cl_io_slice *ios,
 	}
 
 	if (queued > 0)
-		result = osc_queue_sync_pages(env, osc, &list, brw_flags);
+		result = osc_queue_sync_pages(env, io, osc, &list, brw_flags);
 
 	/* Update c/mtime for sync write. LU-7310 */
 	if (crt == CRT_WRITE && qout->pl_nr > 0 && !result) {
@@ -558,6 +558,12 @@ static int osc_io_setattr_start(const struct lu_env *env,
 				oa->o_flags = OBD_FL_SRVLOCK;
 				oa->o_valid |= OBD_MD_FLFLAGS;
 			}
+
+			if (io->ci_layout_version > 0) {
+				/* verify layout version */
+				oa->o_valid |= OBD_MD_LAYOUT_VERSION;
+				oa->o_layout_version = io->ci_layout_version;
+			}
 		} else {
 			LASSERT(oio->oi_lockless == 0);
 		}
diff --git a/fs/lustre/osc/osc_request.c b/fs/lustre/osc/osc_request.c
index 06ecd20..5581f42 100644
--- a/fs/lustre/osc/osc_request.c
+++ b/fs/lustre/osc/osc_request.c
@@ -1944,6 +1944,7 @@ int osc_build_rpc(const struct lu_env *env, struct client_obd *cli,
 	bool soft_sync = false;
 	int grant = 0;
 	bool ndelay = false;
+	u32 layout_version = 0;
 	int i;
 	int rc;
 	struct ost_body *body;
@@ -1957,6 +1958,7 @@ int osc_build_rpc(const struct lu_env *env, struct client_obd *cli,
 		mem_tight |= ext->oe_memalloc;
 		grant += ext->oe_grants;
 		page_count += ext->oe_nr_pages;
+		layout_version = max(layout_version, ext->oe_layout_version);
 		if (!obj)
 			obj = ext->oe_obj;
 	}
@@ -2016,8 +2018,16 @@ int osc_build_rpc(const struct lu_env *env, struct client_obd *cli,
 	crattr->cra_oa = oa;
 	cl_req_attr_set(env, osc2cl(obj), crattr);
 
-	if (cmd == OBD_BRW_WRITE)
+	if (cmd == OBD_BRW_WRITE) {
 		oa->o_grant_used = grant;
+		if (layout_version > 0) {
+			CDEBUG(D_LAYOUT, DFID": write with layout version %u\n",
+			       PFID(&oa->o_oi.oi_fid), layout_version);
+
+			oa->o_layout_version = layout_version;
+			oa->o_valid |= OBD_MD_LAYOUT_VERSION;
+		}
+	}
 
 	sort_brw_pages(pga, page_count);
 	rc = osc_brw_prep_request(cmd, cli, oa, page_count, pga, &req, 1, 0);
diff --git a/fs/lustre/ptlrpc/pack_generic.c b/fs/lustre/ptlrpc/pack_generic.c
index eb82eaa..0c73da6 100644
--- a/fs/lustre/ptlrpc/pack_generic.c
+++ b/fs/lustre/ptlrpc/pack_generic.c
@@ -1619,7 +1619,7 @@ static void lustre_swab_obdo(struct obdo *o)
 	__swab32s(&o->o_stripe_idx);
 	__swab32s(&o->o_parent_ver);
 	lustre_swab_ost_layout(&o->o_layout);
-	BUILD_BUG_ON(offsetof(typeof(*o), o_padding_3) == 0);
+	__swab32s(&o->o_layout_version);
 	__swab32s(&o->o_uid_h);
 	__swab32s(&o->o_gid_h);
 	__swab64s(&o->o_data_version);
@@ -2374,12 +2374,17 @@ void lustre_swab_hsm_user_item(struct hsm_user_item *hui)
 	lustre_swab_hsm_extent(&hui->hui_extent);
 }
 
+void lustre_swab_lu_extent(struct lu_extent *le)
+{
+	__swab64s(&le->e_start);
+	__swab64s(&le->e_end);
+}
+
 void lustre_swab_layout_intent(struct layout_intent *li)
 {
 	__swab32s(&li->li_opc);
 	__swab32s(&li->li_flags);
-	__swab64s(&li->li_start);
-	__swab64s(&li->li_end);
+	lustre_swab_lu_extent(&li->li_extent);
 }
 
 void lustre_swab_hsm_progress_kernel(struct hsm_progress_kernel *hpk)
diff --git a/fs/lustre/ptlrpc/wiretest.c b/fs/lustre/ptlrpc/wiretest.c
index 749effb..0b3c6af 100644
--- a/fs/lustre/ptlrpc/wiretest.c
+++ b/fs/lustre/ptlrpc/wiretest.c
@@ -1247,10 +1247,10 @@ void lustre_assert_wire_constants(void)
 		 (long long)(int)offsetof(struct obdo, o_layout));
 	LASSERTF((int)sizeof(((struct obdo *)0)->o_layout) == 28, "found %lld\n",
 		 (long long)(int)sizeof(((struct obdo *)0)->o_layout));
-	LASSERTF((int)offsetof(struct obdo, o_padding_3) == 164, "found %lld\n",
-		 (long long)(int)offsetof(struct obdo, o_padding_3));
-	LASSERTF((int)sizeof(((struct obdo *)0)->o_padding_3) == 4, "found %lld\n",
-		 (long long)(int)sizeof(((struct obdo *)0)->o_padding_3));
+	LASSERTF((int)offsetof(struct obdo, o_layout_version) == 164, "found %lld\n",
+		 (long long)(int)offsetof(struct obdo, o_layout_version));
+	LASSERTF((int)sizeof(((struct obdo *)0)->o_layout_version) == 4, "found %lld\n",
+		 (long long)(int)sizeof(((struct obdo *)0)->o_layout_version));
 	LASSERTF((int)offsetof(struct obdo, o_uid_h) == 168, "found %lld\n",
 		 (long long)(int)offsetof(struct obdo, o_uid_h));
 	LASSERTF((int)sizeof(((struct obdo *)0)->o_uid_h) == 4, "found %lld\n",
@@ -4049,14 +4049,10 @@ void lustre_assert_wire_constants(void)
 		 (long long)(int)offsetof(struct layout_intent, li_flags));
 	LASSERTF((int)sizeof(((struct layout_intent *)0)->li_flags) == 4, "found %lld\n",
 		 (long long)(int)sizeof(((struct layout_intent *)0)->li_flags));
-	LASSERTF((int)offsetof(struct layout_intent, li_start) == 8, "found %lld\n",
-		 (long long)(int)offsetof(struct layout_intent, li_start));
-	LASSERTF((int)sizeof(((struct layout_intent *)0)->li_start) == 8, "found %lld\n",
-		 (long long)(int)sizeof(((struct layout_intent *)0)->li_start));
-	LASSERTF((int)offsetof(struct layout_intent, li_end) == 16, "found %lld\n",
-		 (long long)(int)offsetof(struct layout_intent, li_end));
-	LASSERTF((int)sizeof(((struct layout_intent *)0)->li_end) == 8, "found %lld\n",
-		 (long long)(int)sizeof(((struct layout_intent *)0)->li_end));
+	LASSERTF((int)offsetof(struct layout_intent, li_extent) == 8, "found %lld\n",
+		 (long long)(int)offsetof(struct layout_intent, li_extent));
+	LASSERTF((int)sizeof(((struct layout_intent *)0)->li_extent) == 16, "found %lld\n",
+		 (long long)(int)sizeof(((struct layout_intent *)0)->li_extent));
 	LASSERTF(LAYOUT_INTENT_ACCESS == 0, "found %lld\n",
 		 (long long)LAYOUT_INTENT_ACCESS);
 	LASSERTF(LAYOUT_INTENT_READ == 1, "found %lld\n",
diff --git a/include/uapi/linux/lustre/lustre_idl.h b/include/uapi/linux/lustre/lustre_idl.h
index b4f7aec..27146a6 100644
--- a/include/uapi/linux/lustre/lustre_idl.h
+++ b/include/uapi/linux/lustre/lustre_idl.h
@@ -1092,7 +1092,9 @@ static inline __u32 lov_mds_md_size(__u16 stripes, __u32 lmm_magic)
 #define OBD_MD_DOM_SIZE		(0x00001000ULL) /* Data-on-MDT component size */
 #define OBD_MD_FLNLINK		(0x00002000ULL) /* link count */
 #define OBD_MD_FLGENER		(0x00004000ULL) /* generation number */
-/*#define OBD_MD_FLINLINE	(0x00008000ULL)  inline data. used until 1.6.5 */
+#define OBD_MD_LAYOUT_VERSION	(0x00008000ULL) /* layout version for
+						 * OST objects
+						 */
 #define OBD_MD_FLRDEV		(0x00010000ULL) /* device number */
 #define OBD_MD_FLEASIZE		(0x00020000ULL) /* extended attribute data */
 #define OBD_MD_LINKNAME		(0x00040000ULL) /* symbolic link target */
@@ -2675,7 +2677,7 @@ struct obdo {
 	 * sizeof(ost_layout) + sizeof(__u32) == sizeof(llog_cookie).
 	 */
 	struct ost_layout	o_layout;
-	__u32			o_padding_3;
+	__u32			o_layout_version;
 	__u32		o_uid_h;
 	__u32		o_gid_h;
 
diff --git a/include/uapi/linux/lustre/lustre_user.h b/include/uapi/linux/lustre/lustre_user.h
index d4372d9..3b64f734 100644
--- a/include/uapi/linux/lustre/lustre_user.h
+++ b/include/uapi/linux/lustre/lustre_user.h
@@ -453,6 +453,11 @@ enum lov_comp_md_entry_flags {
 
 #define LCME_KNOWN_FLAGS	(LCME_FL_NEG | LCME_FL_INIT)
 
+/* the highest bit in obdo::o_layout_version is used to mark if the file is
+ * being resynced.
+ */
+#define LU_LAYOUT_RESYNC	LCME_FL_NEG
+
 /* lcme_id can be specified as certain flags, and the first
  * bit of lcme_id is used to indicate that the ID is representing
  * certain LCME_FL_* but not a real ID. Which implies we can have
@@ -834,6 +839,8 @@ enum changelog_rec_type {
 	CL_MTIME	= 17, /* Precedence: setattr > mtime > ctime > atime */
 	CL_CTIME	= 18,
 	CL_ATIME	= 19,
+	CL_FLRW		= 21, /* FLR: file was firstly written */
+	CL_RESYNC	= 22, /* FLR: file was resync-ed */
 	CL_LAST
 };
 
@@ -842,7 +849,8 @@ static inline const char *changelog_type2str(int type)
 	static const char *changelog_str[] = {
 		"MARK",  "CREAT", "MKDIR", "HLINK", "SLINK", "MKNOD", "UNLNK",
 		"RMDIR", "RENME", "RNMTO", "OPEN",  "CLOSE", "LYOUT", "TRUNC",
-		"SATTR", "XATTR", "HSM",   "MTIME", "CTIME", "ATIME",
+		"SATTR", "XATTR", "HSM",   "MTIME", "CTIME", "ATIME", "",
+		"FLRW",  "RESYNC",
 	};
 
 	if (type >= 0 && type < CL_LAST)
-- 
1.8.3.1
