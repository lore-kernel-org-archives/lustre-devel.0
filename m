From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Sep 2019 14:55:26 -0400
Subject: [lustre-devel] [PATCH 067/151] lustre: flr: read support for flr
In-Reply-To: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1569869810-23848-68-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Jinshan Xiong <jinshan.xiong@gmail.com>

Avoid stale mirrors to read;
If preferred mirror is inaccessible, try next one, ndelay RPC
is implemented to make the error-out quick. ndelay RPC has
rq_no_delay bit set that can be applied to brw and lock RPC.

WC-bug-id: https://jira.whamcloud.com/browse/LU-9771
Lustre-commit: 526dbd3d8723 ("LU-9971 flr: read support for flr")
Signed-off-by: Jinshan Xiong <jinshan.xiong@gmail.com>
Reviewed-on: https://review.whamcloud.com/29085
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Reviewed-by: Fan Yong <fan.yong@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/cl_object.h          |  22 +++-
 fs/lustre/include/lustre_dlm_flags.h   |   7 ++
 fs/lustre/include/lustre_osc.h         |   6 +-
 fs/lustre/include/obd_support.h        |   3 +
 fs/lustre/ldlm/ldlm_request.c          |   9 ++
 fs/lustre/llite/file.c                 |  14 +++
 fs/lustre/llite/glimpse.c              |  12 ++-
 fs/lustre/llite/rw.c                   |  28 ++++-
 fs/lustre/llite/vvp_internal.h         |   1 +
 fs/lustre/llite/vvp_io.c               |  55 +++++++---
 fs/lustre/llite/vvp_page.c             |   9 +-
 fs/lustre/lov/lov_cl_internal.h        | 186 +++++++++++++++++++++++++++------
 fs/lustre/lov/lov_io.c                 | 183 ++++++++++++++++++++++++++++----
 fs/lustre/lov/lov_lock.c               |  15 +--
 fs/lustre/lov/lov_object.c             | 147 +++++++++++++++++++++-----
 fs/lustre/lov/lov_page.c               |   2 +-
 fs/lustre/obdclass/cl_io.c             |  14 ++-
 fs/lustre/osc/osc_cache.c              |   8 +-
 fs/lustre/osc/osc_io.c                 |   9 +-
 fs/lustre/osc/osc_lock.c               |   4 +
 fs/lustre/osc/osc_request.c            |  15 ++-
 include/uapi/linux/lustre/lustre_idl.h |   4 +
 22 files changed, 623 insertions(+), 130 deletions(-)

diff --git a/fs/lustre/include/cl_object.h b/fs/lustre/include/cl_object.h
index 81190ba..f573c6f 100644
--- a/fs/lustre/include/cl_object.h
+++ b/fs/lustre/include/cl_object.h
@@ -1871,7 +1871,20 @@ struct cl_io {
 	 */
 				ci_noatime:1,
 	/* Tell sublayers not to expand LDLM locks requested for this IO */
-				ci_lock_no_expand:1;
+				ci_lock_no_expand:1,
+	/**
+	 * Set if non-delay RPC should be used for this IO.
+	 *
+	 * If this file has multiple mirrors, and if the OSTs of the current
+	 * mirror is inaccessible, non-delay RPC would error out quickly so
+	 * that the upper layer can try to access the next mirror.
+	 */
+				ci_ndelay:1;
+	/**
+	 * How many times the read has retried before this one.
+	 * Set by the top level and consumed by the LOV.
+	 */
+	unsigned int		ci_ndelay_tried;
 	/**
 	 * Number of pages owned by this IO. For invariant checking.
 	 */
@@ -2336,9 +2349,8 @@ static inline int cl_io_is_trunc(const struct cl_io *io)
 do {									\
 	typeof(foo_io) __foo_io = (foo_io);				\
 									\
-	BUILD_BUG_ON(offsetof(typeof(*__foo_io), base) != 0);		\
-	memset(&__foo_io->base + 1, 0,					\
-	       sizeof(*__foo_io) - sizeof(__foo_io->base));		\
+	memset(&__foo_io->base, 0,					\
+	       sizeof(*__foo_io) - offsetof(typeof(*__foo_io), base));	\
 } while (0)
 
 /** @} cl_io */
@@ -2385,6 +2397,8 @@ void cl_page_list_del(const struct lu_env *env, struct cl_page_list *plist,
 		      struct cl_page *page);
 void cl_page_list_disown(const struct lu_env *env,
 			 struct cl_io *io, struct cl_page_list *plist);
+void cl_page_list_discard(const struct lu_env *env,
+			  struct cl_io *io, struct cl_page_list *plist);
 void cl_page_list_fini(const struct lu_env *env, struct cl_page_list *plist);
 
 void cl_2queue_init(struct cl_2queue *queue);
diff --git a/fs/lustre/include/lustre_dlm_flags.h b/fs/lustre/include/lustre_dlm_flags.h
index f1f454f..22fb595 100644
--- a/fs/lustre/include/lustre_dlm_flags.h
+++ b/fs/lustre/include/lustre_dlm_flags.h
@@ -391,6 +391,13 @@
 #define ldlm_set_excl(_l)		LDLM_SET_FLAG((_l), 1ULL << 55)
 #define ldlm_clear_excl(_l)		LDLM_CLEAR_FLAG((_l), 1ULL << 55)
 
+/**
+ * This flags means to use non-delay RPC to send dlm request RPC.
+ */
+#define LDLM_FL_NDELAY			0x0400000000000000ULL /* bit  58 */
+#define ldlm_is_ndelay(_l)		LDLM_TEST_FLAG((_l), 1ULL << 58)
+#define ldlm_set_ndelay(_l)		LDLM_SET_FLAG((_l), 1ULL << 58)
+
 /** l_flags bits marked as "ast" bits */
 #define LDLM_FL_AST_MASK		(LDLM_FL_FLOCK_DEADLOCK		|\
 					 LDLM_FL_DISCARD_DATA)
diff --git a/fs/lustre/include/lustre_osc.h b/fs/lustre/include/lustre_osc.h
index 895c1cb..5efceef 100644
--- a/fs/lustre/include/lustre_osc.h
+++ b/fs/lustre/include/lustre_osc.h
@@ -587,7 +587,7 @@ int osc_teardown_async_page(const struct lu_env *env, struct osc_object *obj,
 int osc_flush_async_page(const struct lu_env *env, struct cl_io *io,
 			 struct osc_page *ops);
 int osc_queue_sync_pages(const struct lu_env *env, struct osc_object *obj,
-			 struct list_head *list, int cmd, int brw_flags);
+			 struct list_head *list, int brw_flags);
 int osc_cache_truncate_start(const struct lu_env *env, struct osc_object *obj,
 			     u64 size, struct osc_extent **extp);
 void osc_cache_truncate_end(const struct lu_env *env, struct osc_extent *ext);
@@ -927,7 +927,9 @@ struct osc_extent {
 	/* this extent should be written back asap. set if one of pages is
 	 * called by page WB daemon, or sync write or reading requests.
 	 */
-				oe_urgent:1;
+				oe_urgent:1,
+	/* Non-delay RPC should be used for this extent. */
+				oe_ndelay:1;
 	/* how many grants allocated for this extent.
 	 *  Grant allocated for this extent. There is no grant allocated
 	 *  for reading extents and sync write extents.
diff --git a/fs/lustre/include/obd_support.h b/fs/lustre/include/obd_support.h
index 7999ac6..e6dff44b 100644
--- a/fs/lustre/include/obd_support.h
+++ b/fs/lustre/include/obd_support.h
@@ -474,6 +474,9 @@
 /* LMV */
 #define OBD_FAIL_UNKNOWN_LMV_STRIPE			0x1901
 
+/* FLR */
+#define OBD_FAIL_FLR_GLIMPSE_IMMUTABLE			0x1A00
+
 /* Assign references to moved code to reduce code changes */
 #define OBD_FAIL_PRECHECK(id)			CFS_FAIL_PRECHECK(id)
 #define OBD_FAIL_CHECK(id)			CFS_FAIL_CHECK(id)
diff --git a/fs/lustre/ldlm/ldlm_request.c b/fs/lustre/ldlm/ldlm_request.c
index 13b323a..65c3558 100644
--- a/fs/lustre/ldlm/ldlm_request.c
+++ b/fs/lustre/ldlm/ldlm_request.c
@@ -748,6 +748,15 @@ int ldlm_cli_enqueue(struct obd_export *exp, struct ptlrpc_request **reqp,
 			 DLM_LOCKREQ_OFF, len, (int)sizeof(*body));
 	}
 
+	if (*flags & LDLM_FL_NDELAY) {
+		DEBUG_REQ(D_DLMTRACE, req, "enque lock with no delay\n");
+		req->rq_no_resend = req->rq_no_delay = 1;
+		/* probably set a shorter timeout value and handle ETIMEDOUT
+		 * in osc_lock_upcall() correctly
+		 */
+		/* lustre_msg_set_timeout(req, req->rq_timeout / 2); */
+	}
+
 	/* Dump lock data into the request buffer */
 	body = req_capsule_client_get(&req->rq_pill, &RMF_DLM_REQ);
 	ldlm_lock2desc(lock, &body->lock_desc);
diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index 6f991ed..1856aa6 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -1155,6 +1155,11 @@ static void ll_io_init(struct cl_io *io, const struct file *file, int write)
 	}
 
 	io->ci_noatime = file_is_noatime(file);
+
+	/* FLR: only use non-delay I/O for read as there is only one
+	 * available mirror for write.
+	 */
+	io->ci_ndelay = !write;
 }
 
 static ssize_t
@@ -1169,6 +1174,7 @@ static void ll_io_init(struct cl_io *io, const struct file *file, int write)
 	struct cl_io *io;
 	ssize_t result = 0;
 	int rc = 0;
+	unsigned int retried = 0;
 
 	CDEBUG(D_VFSTRACE, "file: %pD, type: %d ppos: %llu, count: %zu\n",
 	       file, iot, *ppos, count);
@@ -1176,6 +1182,7 @@ static void ll_io_init(struct cl_io *io, const struct file *file, int write)
 restart:
 	io = vvp_env_thread_io(env);
 	ll_io_init(io, file, iot == CIT_WRITE);
+	io->ci_ndelay_tried = retried;
 
 	if (cl_io_rw_init(env, io, iot, *ppos, count) == 0) {
 		struct vvp_io *vio = vvp_env_io(env);
@@ -1232,12 +1239,19 @@ static void ll_io_init(struct cl_io *io, const struct file *file, int write)
 out:
 	cl_io_fini(env, io);
 
+	CDEBUG(D_VFSTRACE,
+	       "%s: %d io complete with rc: %d, result: %zd, restart: %d\n",
+	       file->f_path.dentry->d_name.name,
+	       iot, rc, result, io->ci_need_restart);
+
 	if ((!rc || rc == -ENODATA) && count > 0 && io->ci_need_restart) {
 		CDEBUG(D_VFSTRACE,
 		       "%s: restart %s from %lld, count:%zu, result: %zd\n",
 		       file_dentry(file)->d_name.name,
 		       iot == CIT_READ ? "read" : "write",
 		       *ppos, count, result);
+		/* preserve the tried count for FLR */
+		retried = io->ci_ndelay_tried;
 		goto restart;
 	}
 
diff --git a/fs/lustre/llite/glimpse.c b/fs/lustre/llite/glimpse.c
index f2f4e4e..13a2621 100644
--- a/fs/lustre/llite/glimpse.c
+++ b/fs/lustre/llite/glimpse.c
@@ -187,24 +187,28 @@ int __cl_glimpse_size(struct inode *inode, int agl)
 	struct cl_io *io  = NULL;
 	int result;
 	u16 refcheck;
+	int retried = 0;
 
 	result = cl_io_get(inode, &env, &io, &refcheck);
 	if (result <= 0)
 		return result;
 
 	do {
-		io->ci_need_restart = 0;
-		io->ci_verify_layout = 1;
+		io->ci_ndelay_tried = retried++;
+		io->ci_ndelay = io->ci_verify_layout = 1;
 		result = cl_io_init(env, io, CIT_GLIMPSE, io->ci_obj);
-		if (result > 0)
+		if (result > 0) {
 			/*
 			 * nothing to do for this io. This currently happens
 			 * when stripe sub-object's are not yet created.
 			 */
 			result = io->ci_result;
-		else if (result == 0)
+		} else if (result == 0) {
 			result = cl_glimpse_lock(env, io, inode, io->ci_obj,
 						 agl);
+			if (!agl && result == -EWOULDBLOCK)
+				io->ci_need_restart = 1;
+		}
 
 		OBD_FAIL_TIMEOUT(OBD_FAIL_GLIMPSE_DELAY, 2);
 		cl_io_fini(env, io);
diff --git a/fs/lustre/llite/rw.c b/fs/lustre/llite/rw.c
index ca0b357..e2e47174 100644
--- a/fs/lustre/llite/rw.c
+++ b/fs/lustre/llite/rw.c
@@ -1100,8 +1100,9 @@ static int ll_io_read_page(const struct lu_env *env, struct cl_io *io,
 	struct inode *inode = vvp_object_inode(page->cp_obj);
 	struct ll_file_data *fd = LUSTRE_FPRIVATE(file);
 	struct ll_readahead_state *ras = &fd->fd_ras;
-	struct cl_2queue *queue  = &io->ci_queue;
+	struct cl_2queue *queue = &io->ci_queue;
 	struct ll_sb_info *sbi = ll_i2sbi(inode);
+	struct cl_sync_io *anchor = NULL;
 	struct vvp_page *vpg;
 	bool uptodate;
 	int rc = 0;
@@ -1128,6 +1129,10 @@ static int ll_io_read_page(const struct lu_env *env, struct cl_io *io,
 		cl_page_export(env, page, 1);
 		cl_page_disown(env, io, page);
 	} else {
+		anchor = &vvp_env_info(env)->vti_anchor;
+		cl_sync_io_init(anchor, 1);
+		page->cp_sync_io = anchor;
+
 		cl_page_list_add(&queue->c2_qin, page);
 	}
 
@@ -1148,6 +1153,27 @@ static int ll_io_read_page(const struct lu_env *env, struct cl_io *io,
 		if (!rc)
 			task_io_account_read(PAGE_SIZE * count);
 	}
+	if (anchor && !cl_page_is_owned(page, io)) { /* have sent */
+		rc = cl_sync_io_wait(env, anchor, 0);
+
+		cl_page_assume(env, io, page);
+		cl_page_list_del(env, &queue->c2_qout, page);
+
+		if (!PageUptodate(cl_page_vmpage(page))) {
+			/* Failed to read a mirror, discard this page so that
+			 * new page can be created with new mirror.
+			 *
+			 * TODO: this is not needed after page reinit
+			 * route is implemented
+			 */
+			cl_page_discard(env, io, page);
+		}
+		cl_page_disown(env, io, page);
+	}
+
+	/* TODO: discard all pages until page reinit route is implemented */
+	cl_page_list_discard(env, io, &queue->c2_qin);
+
 	/*
 	 * Unlock unsent pages in case of error.
 	 */
diff --git a/fs/lustre/llite/vvp_internal.h b/fs/lustre/llite/vvp_internal.h
index 0f7c027..f9a4552 100644
--- a/fs/lustre/llite/vvp_internal.h
+++ b/fs/lustre/llite/vvp_internal.h
@@ -127,6 +127,7 @@ struct vvp_thread_info {
 	struct cl_lock_descr	vti_descr;
 	struct cl_io		vti_io;
 	struct cl_attr		vti_attr;
+	struct cl_sync_io	vti_anchor;
 };
 
 static inline struct vvp_thread_info *vvp_env_info(const struct lu_env *env)
diff --git a/fs/lustre/llite/vvp_io.c b/fs/lustre/llite/vvp_io.c
index 3479f7a..8518423 100644
--- a/fs/lustre/llite/vvp_io.c
+++ b/fs/lustre/llite/vvp_io.c
@@ -281,6 +281,7 @@ static void vvp_io_fini(const struct lu_env *env, const struct cl_io_slice *ios)
 	struct cl_object *obj = io->ci_obj;
 	struct vvp_io *vio = cl2vvp_io(env, ios);
 	struct inode *inode = vvp_object_inode(obj);
+	u32 gen = 0;
 	int rc;
 
 	CLOBINVRNT(env, obj, vvp_object_invariant(obj));
@@ -304,18 +305,41 @@ static void vvp_io_fini(const struct lu_env *env, const struct cl_io_slice *ios)
 		 * block on layout lock hold by the MDT
 		 * as MDT will not send new layout in lvb (see LU-3124)
 		 * we have to explicitly fetch it, all this will be done
-		 * by ll_layout_refresh()
+		 * by ll_layout_refresh().
+		 * Even if ll_layout_restore() returns zero, it doesn't mean
+		 * that restore has been successful. Therefore it sets
+		 * ci_verify_layout so that it will check layout at the end
+		 * of this function.
 		 */
-		if (rc == 0) {
-			io->ci_restore_needed = 0;
-			io->ci_need_restart = 1;
-			io->ci_verify_layout = 1;
-		} else {
+		if (rc) {
 			io->ci_restore_needed = 1;
 			io->ci_need_restart = 0;
 			io->ci_verify_layout = 0;
 			io->ci_result = rc;
+			goto out;
+		}
+
+		io->ci_restore_needed = 0;
+
+		/* Even if ll_layout_restore() returns zero, it doesn't mean
+		 * that restore has been successful. Therefore it should verify
+		 * if there was layout change and restart I/O correspondingly.
+		 */
+		ll_layout_refresh(inode, &gen);
+		io->ci_need_restart = vio->vui_layout_gen != gen;
+		if (io->ci_need_restart) {
+			CDEBUG(D_VFSTRACE,
+			       DFID" layout changed from %d to %d.\n",
+			       PFID(lu_object_fid(&obj->co_lu)),
+			       vio->vui_layout_gen, gen);
+			/* today successful restore is the only possible
+			 * case
+			 */
+			/* restore was done, clear restoring state */
+			clear_bit(LLIF_FILE_RESTORING,
+				  &ll_i2info(vvp_object_inode(obj))->lli_flags);
 		}
+		goto out;
 	}
 
 	/**
@@ -352,11 +376,11 @@ static void vvp_io_fini(const struct lu_env *env, const struct cl_io_slice *ios)
 		io->ci_result = rc;
 		if (!rc)
 			io->ci_need_restart = 1;
+		goto out;
 	}
 
-	if (!io->ci_ignore_layout && io->ci_verify_layout) {
-		u32 gen = 0;
-
+	if (!io->ci_need_restart &&
+	    !io->ci_ignore_layout && io->ci_verify_layout) {
 		/* check layout version */
 		ll_layout_refresh(inode, &gen);
 		io->ci_need_restart = vio->vui_layout_gen != gen;
@@ -365,12 +389,11 @@ static void vvp_io_fini(const struct lu_env *env, const struct cl_io_slice *ios)
 			       DFID " layout changed from %d to %d.\n",
 			       PFID(lu_object_fid(&obj->co_lu)),
 			       vio->vui_layout_gen, gen);
-			/* today successful restore is the only possible case */
-			/* restore was done, clear restoring state */
-			clear_bit(LLIF_FILE_RESTORING,
-				  &ll_i2info(inode)->lli_flags);
 		}
+		goto out;
 	}
+out:
+	;
 }
 
 static void vvp_io_fault_fini(const struct lu_env *env,
@@ -740,7 +763,10 @@ static int vvp_io_read_start(const struct lu_env *env,
 	if (!can_populate_pages(env, io, inode))
 		return 0;
 
-	result = vvp_prep_size(env, obj, io, pos, tot, &exceed);
+	/* Unless this is reading a sparse file, otherwise the lock has already
+	 * been acquired so vvp_prep_size() is an empty op.
+	 */
+	result = vvp_prep_size(env, obj, io, pos, cnt, &exceed);
 	if (result != 0)
 		return result;
 	if (exceed != 0)
@@ -765,6 +791,7 @@ static int vvp_io_read_start(const struct lu_env *env,
 	file_accessed(file);
 	LASSERT(vio->vui_iocb->ki_pos == pos);
 	result = generic_file_read_iter(vio->vui_iocb, vio->vui_iter);
+	goto out;
 
 out:
 	if (result >= 0) {
diff --git a/fs/lustre/llite/vvp_page.c b/fs/lustre/llite/vvp_page.c
index 590e5f5..7b07eae 100644
--- a/fs/lustre/llite/vvp_page.c
+++ b/fs/lustre/llite/vvp_page.c
@@ -267,8 +267,15 @@ static void vvp_page_completion_read(const struct lu_env *env,
 	if (ioret == 0)  {
 		if (!vpg->vpg_defer_uptodate)
 			cl_page_export(env, page, 1);
-	} else {
+	} else if (vpg->vpg_defer_uptodate) {
 		vpg->vpg_defer_uptodate = 0;
+		if (ioret == -EWOULDBLOCK) {
+			/* mirror read failed, it needs to destroy the page
+			 * because subpage would be from wrong osc when trying
+			 * to read from a new mirror
+			 */
+			generic_error_remove_page(vmpage->mapping, vmpage);
+		}
 	}
 
 	if (!page->cp_sync_io)
diff --git a/fs/lustre/lov/lov_cl_internal.h b/fs/lustre/lov/lov_cl_internal.h
index 069b30e..94a5638 100644
--- a/fs/lustre/lov/lov_cl_internal.h
+++ b/fs/lustre/lov/lov_cl_internal.h
@@ -178,7 +178,7 @@ struct lov_layout_raid0 {
 	 * object. This field is reset to 0 when attributes of
 	 * any sub-object change.
 	 */
-	int			lo_attr_valid;
+	bool			lo_attr_valid;
 	/**
 	 * Array of sub-objects. Allocated when top-object is
 	 * created (lov_init_raid0()).
@@ -217,7 +217,9 @@ struct lov_layout_dom {
 
 struct lov_layout_entry {
 	u32					lle_type;
-	struct lu_extent			lle_extent;
+	unsigned int				lle_valid:1;
+	struct lu_extent			*lle_extent;
+	struct lov_stripe_md_entry		*lle_lsme;
 	struct lov_comp_layout_entry_ops	*lle_comp_ops;
 	union {
 		struct lov_layout_raid0		lle_raid0;
@@ -225,6 +227,18 @@ struct lov_layout_entry {
 	};
 };
 
+struct lov_mirror_entry {
+	unsigned short	lre_mirror_id;
+	unsigned short	lre_preferred:1,
+			lre_valid:1;	/* set if at least one of components
+					 * in this mirror is valid
+					 */
+	unsigned short	lre_start;	/* index to lo_entries, start index of
+					 * this mirror
+					 */
+	unsigned short	lre_end;	/* end index of this mirror */
+};
+
 /**
  * lov-specific file state.
  *
@@ -280,9 +294,36 @@ struct lov_object {
 		} released;
 		struct lov_layout_composite {
 			/**
-			 * Current valid entry count of entries.
+			 * flags of lov_comp_md_v1::lcm_flags. Mainly used
+			 * by FLR.
+			 */
+			u32		lo_flags;
+			/**
+			 * For FLR: index of preferred mirror to read.
+			 * Preferred mirror is initialized by the preferred
+			 * bit of lsme. It can be changed when the preferred
+			 * is inaccessible.
+			 * In order to make lov_lsm_entry() return the same
+			 * mirror in the same IO context, it's only possible
+			 * to change the preferred mirror when the
+			 * lo_active_ios reaches zero.
+			 */
+			int		lo_preferred_mirror;
+			/**
+			 * For FLR: the lock to protect access to
+			 * lo_preferred_mirror.
 			 */
-			unsigned int lo_entry_count;
+			spinlock_t	lo_write_lock;
+			/**
+			 * For FLR: Number of (valid) mirrors.
+			 */
+			unsigned int	lo_mirror_count;
+			struct lov_mirror_entry *lo_mirrors;
+			/**
+			 * Current entry count of lo_entries, include
+			 * invalid entries.
+			 */
+			unsigned int	lo_entry_count;
 			struct lov_layout_entry *lo_entries;
 		} composite;
 	} u;
@@ -293,10 +334,80 @@ struct lov_object {
 	struct task_struct	*lo_owner;
 };
 
+static inline struct lov_layout_raid0 *lov_r0(struct lov_object *lov, int i)
+{
+	LASSERT(lov->lo_type == LLT_COMP);
+	LASSERTF(i < lov->u.composite.lo_entry_count,
+		 "entry %d entry_count %d", i, lov->u.composite.lo_entry_count);
+
+	return &lov->u.composite.lo_entries[i].lle_raid0;
+}
+
+static inline struct lov_stripe_md_entry *lov_lse(struct lov_object *lov, int i)
+{
+	LASSERT(lov->lo_lsm);
+	LASSERT(i < lov->lo_lsm->lsm_entry_count);
+
+	return lov->lo_lsm->lsm_entries[i];
+}
+
+static inline unsigned int lov_flr_state(const struct lov_object *lov)
+{
+	if (lov->lo_type != LLT_COMP)
+		return LCM_FL_NOT_FLR;
+
+	return lov->u.composite.lo_flags & LCM_FL_FLR_MASK;
+}
+
+static inline bool lov_is_flr(const struct lov_object *lov)
+{
+	return lov_flr_state(lov) != LCM_FL_NOT_FLR;
+}
+
+static inline struct lov_layout_entry *lov_entry(struct lov_object *lov, int i)
+{
+	LASSERT(lov->lo_type == LLT_COMP);
+	LASSERTF(i < lov->u.composite.lo_entry_count,
+		 "entry %d entry_count %d", i, lov->u.composite.lo_entry_count);
+
+	return &lov->u.composite.lo_entries[i];
+}
+
+#define lov_for_layout_entry(lov, entry, start, end)			\
+	for (entry = lov_entry(lov, start);				\
+	     entry <= lov_entry(lov, end); entry++)
+
 #define lov_foreach_layout_entry(lov, entry)				\
-	for (entry = &lov->u.composite.lo_entries[0];			\
-	     entry < &lov->u.composite.lo_entries[lov->u.composite.lo_entry_count];\
-	     entry++)
+	lov_for_layout_entry(lov, entry, 0,				\
+			     (lov)->u.composite.lo_entry_count - 1)
+
+#define lov_foreach_mirror_layout_entry(lov, entry, lre)		\
+	lov_for_layout_entry(lov, entry, (lre)->lre_start, (lre)->lre_end)
+
+static inline struct lov_mirror_entry *
+lov_mirror_entry(struct lov_object *lov, int i)
+{
+	LASSERT(i < lov->u.composite.lo_mirror_count);
+	return &lov->u.composite.lo_mirrors[i];
+}
+
+#define lov_foreach_mirror_entry(lov, lre)				\
+	for (lre = lov_mirror_entry(lov, 0);				\
+	     lre <= lov_mirror_entry(lov,				\
+				     lov->u.composite.lo_mirror_count - 1);\
+	     lre++)
+
+static inline unsigned
+lov_layout_entry_index(struct lov_object *lov, struct lov_layout_entry *entry)
+{
+	struct lov_layout_entry *first = &lov->u.composite.lo_entries[0];
+	unsigned int index = (unsigned int)(entry - first);
+
+	LASSERT(entry >= first);
+	LASSERT(index < lov->u.composite.lo_entry_count);
+
+	return index;
+}
 
 /**
  * State lov_lock keeps for each sub-lock.
@@ -412,6 +523,26 @@ struct lov_io_sub {
 struct lov_io {
 	/** super-class */
 	struct cl_io_slice	lis_cl;
+
+	/**
+	 * FLR: index to lo_mirrors. Valid only if lov_is_flr() returns true.
+	 *
+	 * The mirror index of this io. Preserved over cl_io_init()
+	 * if io->ci_ndelay_tried is greater than zero.
+	 */
+	int			lis_mirror_index;
+	/**
+	 * FLR: the layout gen when lis_mirror_index was cached. The
+	 * mirror index makes sense only when the layout gen doesn't
+	 * change.
+	 */
+	int			lis_mirror_layout_gen;
+
+	/**
+	 * fields below this will be initialized in lov_io_init().
+	 */
+	unsigned int		lis_preserved;
+
 	/**
 	 * Pointer to the object slice. This is a duplicate of
 	 * lov_io::lis_cl::cis_object.
@@ -518,10 +649,25 @@ struct lu_object *lovsub_object_alloc(const struct lu_env *env,
 
 struct lov_stripe_md *lov_lsm_addref(struct lov_object *lov);
 int lov_lsm_entry(const struct lov_stripe_md *lsm, u64 offset);
+int lov_io_layout_at(struct lov_io *lio, u64 offset);
 
 #define lov_foreach_target(lov, var)		    \
 	for (var = 0; var < lov_targets_nr(lov); ++var)
 
+static inline struct lu_extent *lov_io_extent(struct lov_io *io, int i)
+{
+	return &lov_lse(io->lis_object, i)->lsme_extent;
+}
+
+/**
+ * For layout entries within @ext.
+ */
+#define lov_foreach_io_layout(ind, lio, ext)				\
+	for (ind = lov_io_layout_at(lio, (ext)->e_start);		\
+	     ind >= 0 &&						\
+	     lu_extent_is_overlapped(lov_io_extent(lio, ind), ext);	\
+	     ind = lov_io_layout_at(lio, lov_io_extent(lio, ind)->e_end))
+
 /*****************************************************************************
  *
  * Type conversions.
@@ -690,32 +836,6 @@ static inline struct lov_thread_info *lov_env_info(const struct lu_env *env)
 	return info;
 }
 
-static inline struct lov_layout_entry *lov_entry(struct lov_object *lov, int i)
-{
-	LASSERT(lov->lo_type == LLT_COMP);
-	LASSERTF(i < lov->u.composite.lo_entry_count,
-		 "entry %d entry_count %d", i, lov->u.composite.lo_entry_count);
-
-	return &lov->u.composite.lo_entries[i];
-}
-
-static inline struct lov_layout_raid0 *lov_r0(struct lov_object *lov, int i)
-{
-	LASSERT(lov->lo_type == LLT_COMP);
-	LASSERTF(i < lov->u.composite.lo_entry_count,
-		 "entry %d entry_count %d", i, lov->u.composite.lo_entry_count);
-
-	return &lov->u.composite.lo_entries[i].lle_raid0;
-}
-
-static inline struct lov_stripe_md_entry *lov_lse(struct lov_object *lov, int i)
-{
-	LASSERT(lov->lo_lsm);
-	LASSERT(i < lov->lo_lsm->lsm_entry_count);
-
-	return lov->lo_lsm->lsm_entries[i];
-}
-
 /* lov_pack.c */
 int lov_getstripe(const struct lu_env *env, struct lov_object *obj,
 		  struct lov_stripe_md *lsm, struct lov_user_md __user *lump,
diff --git a/fs/lustre/lov/lov_io.c b/fs/lustre/lov/lov_io.c
index c3fd86a..12ea614 100644
--- a/fs/lustre/lov/lov_io.c
+++ b/fs/lustre/lov/lov_io.c
@@ -87,6 +87,15 @@ static void lov_io_sub_fini(const struct lu_env *env, struct lov_io *lio,
 	}
 }
 
+static inline bool
+is_index_within_mirror(struct lov_object *lov, int index, int mirror_index)
+{
+	struct lov_layout_composite *comp = &lov->u.composite;
+	struct lov_mirror_entry *lre = &comp->lo_mirrors[mirror_index];
+
+	return (index >= lre->lre_start && index <= lre->lre_end);
+}
+
 static int lov_io_sub_init(const struct lu_env *env, struct lov_io *lio,
 			   struct lov_io_sub *sub)
 {
@@ -104,6 +113,11 @@ static int lov_io_sub_init(const struct lu_env *env, struct lov_io *lio,
 		     !lov_r0(lov, index)->lo_sub[stripe]))
 		return -EIO;
 
+	LASSERTF(is_index_within_mirror(lov, index, lio->lis_mirror_index),
+		 DFID "iot = %d, index = %d, mirror = %d\n",
+		 PFID(lu_object_fid(lov2lu(lov))), io->ci_type, index,
+		 lio->lis_mirror_index);
+
 	/* obtain new environment */
 	sub->sub_env = cl_env_get(&sub->sub_refcheck);
 	if (IS_ERR(sub->sub_env))
@@ -121,6 +135,7 @@ static int lov_io_sub_init(const struct lu_env *env, struct lov_io *lio,
 	sub_io->ci_no_srvlock = io->ci_no_srvlock;
 	sub_io->ci_noatime = io->ci_noatime;
 	sub_io->ci_lock_no_expand = io->ci_lock_no_expand;
+	sub_io->ci_ndelay = io->ci_ndelay;
 
 	rc = cl_io_sub_init(sub->sub_env, sub_io, io->ci_type, sub_obj);
 	if (rc < 0)
@@ -193,9 +208,102 @@ static int lov_io_subio_init(const struct lu_env *env, struct lov_io *lio,
 	return 0;
 }
 
+static int lov_io_mirror_init(struct lov_io *lio, struct lov_object *obj,
+			       struct cl_io *io)
+{
+	struct lov_layout_composite *comp = &obj->u.composite;
+	int index;
+	int i;
+
+	if (!lov_is_flr(obj)) {
+		LASSERT(comp->lo_preferred_mirror == 0);
+		lio->lis_mirror_index = comp->lo_preferred_mirror;
+		io->ci_ndelay = 0;
+		return 0;
+	}
+
+	if (io->ci_ndelay_tried == 0 || /* first time to try */
+	    /* reset the mirror index if layout has changed */
+	    lio->lis_mirror_layout_gen != obj->lo_lsm->lsm_layout_gen) {
+		lio->lis_mirror_layout_gen = obj->lo_lsm->lsm_layout_gen;
+		index = lio->lis_mirror_index = comp->lo_preferred_mirror;
+	} else {
+		index = lio->lis_mirror_index;
+		LASSERT(index >= 0);
+
+		/* move mirror index to the next one */
+		index = (index + 1) % comp->lo_mirror_count;
+	}
+
+	for (i = 0; i < comp->lo_mirror_count; i++) {
+		struct lu_extent ext = { .e_start = lio->lis_pos,
+					 .e_end   = lio->lis_pos + 1 };
+		struct lov_mirror_entry *lre;
+		struct lov_layout_entry *lle;
+		bool found = false;
+
+		lre = &comp->lo_mirrors[(index + i) % comp->lo_mirror_count];
+		if (!lre->lre_valid)
+			continue;
+
+		lov_foreach_mirror_layout_entry(obj, lle, lre) {
+			if (!lle->lle_valid)
+				continue;
+
+			if (lu_extent_is_overlapped(&ext, lle->lle_extent)) {
+				found = true;
+				break;
+			}
+		}
+
+		if (found) {
+			index = (index + i) % comp->lo_mirror_count;
+			break;
+		}
+	}
+	if (i == comp->lo_mirror_count) {
+		CERROR(DFID ": failed to find a component covering I/O region at %llu\n",
+		       PFID(lu_object_fid(lov2lu(obj))), lio->lis_pos);
+
+		dump_lsm(D_ERROR, obj->lo_lsm);
+
+		return -EIO;
+	}
+
+	CDEBUG(D_VFSTRACE,
+	       DFID ": flr state: %d, move mirror from %d to %d, have retried: %d, mirror count: %d\n",
+	       PFID(lu_object_fid(lov2lu(obj))), lov_flr_state(obj),
+	       lio->lis_mirror_index, index, io->ci_ndelay_tried,
+	       comp->lo_mirror_count);
+
+	lio->lis_mirror_index = index;
+
+	/* FLR: if all mirrors have been tried once, most likely the network
+	 * of this client has been partitioned. We should relinquish CPU for
+	 * a while before trying again.
+	 */
+	++io->ci_ndelay_tried;
+	if (io->ci_ndelay && io->ci_ndelay_tried >= comp->lo_mirror_count) {
+		set_current_state(TASK_INTERRUPTIBLE);
+		schedule_timeout(msecs_to_jiffies(MSEC_PER_SEC)); /* 10ms */
+		if (signal_pending(current))
+			return -EINTR;
+
+		/* reset retry counter */
+		io->ci_ndelay_tried = 1;
+	}
+
+	CDEBUG(D_VFSTRACE, "use %sdelayed RPC state for this IO\n",
+	       io->ci_ndelay ? "non-" : "");
+
+	return 0;
+}
+
 static int lov_io_slice_init(struct lov_io *lio, struct lov_object *obj,
 			     struct cl_io *io)
 {
+	int result = 0;
+
 	io->ci_result = 0;
 	lio->lis_object = obj;
 
@@ -260,7 +368,8 @@ static int lov_io_slice_init(struct lov_io *lio, struct lov_object *obj,
 		lio->lis_pos = 0;
 		lio->lis_endpos = OBD_OBJECT_EOF;
 
-		if ((obj->lo_lsm->lsm_flags & LCM_FL_FLR_MASK) == LCM_FL_RDONLY)
+		if (lov_flr_state(obj) == LCM_FL_RDONLY &&
+		    !OBD_FAIL_CHECK(OBD_FAIL_FLR_GLIMPSE_IMMUTABLE))
 			return 1; /* SoM is accurate, no need glimpse */
 		break;
 
@@ -272,7 +381,8 @@ static int lov_io_slice_init(struct lov_io *lio, struct lov_object *obj,
 	default:
 		LBUG();
 	}
-	return 0;
+	result = lov_io_mirror_init(lio, obj, io);
+	return result;
 }
 
 static void lov_io_fini(const struct lu_env *env, const struct cl_io_slice *ios)
@@ -390,7 +500,6 @@ static int lov_io_iter_init(const struct lu_env *env,
 	struct lov_io *lio = cl2lov_io(env, ios);
 	struct lov_stripe_md *lsm = lio->lis_object->lo_lsm;
 	struct cl_io *io = ios->cis_io;
-	struct lov_layout_entry *le;
 	struct lov_io_sub *sub;
 	struct lu_extent ext;
 	int rc = 0;
@@ -399,20 +508,15 @@ static int lov_io_iter_init(const struct lu_env *env,
 	ext.e_start = lio->lis_pos;
 	ext.e_end = lio->lis_endpos;
 
-	index = 0;
-	lov_foreach_layout_entry(lio->lis_object, le) {
-		struct lov_layout_raid0 *r0 = &le->lle_raid0;
+	lov_foreach_io_layout(index, lio, &ext) {
+		struct lov_layout_raid0 *r0 = lov_r0(lio->lis_object, index);
 		int stripe;
 		u64 start;
 		u64 end;
 
-		index++;
-		if (!lu_extent_is_overlapped(&ext, &le->lle_extent))
-			continue;
-
 		CDEBUG(D_VFSTRACE, "component[%d] flags %#x\n",
-		       index - 1, lsm->lsm_entries[index - 1]->lsme_flags);
-		if (!lsm_entry_inited(lsm, index - 1)) {
+		       index, lsm->lsm_entries[index]->lsme_flags);
+		if (!lsm_entry_inited(lsm, index)) {
 			/* truncate IO will trigger write intent as well, and
 			 * it's handled in lov_io_setattr_iter_init()
 			 */
@@ -429,7 +533,7 @@ static int lov_io_iter_init(const struct lu_env *env,
 		}
 
 		for (stripe = 0; stripe < r0->lo_nr; stripe++) {
-			if (!lov_stripe_intersects(lsm, index - 1, stripe,
+			if (!lov_stripe_intersects(lsm, index, stripe,
 						   &ext, &start, &end))
 				continue;
 
@@ -444,7 +548,7 @@ static int lov_io_iter_init(const struct lu_env *env,
 
 			end = lov_offset_mod(end, 1);
 			sub = lov_sub_get(env, lio,
-					  lov_comp_index(index - 1, stripe));
+					  lov_comp_index(index, stripe));
 			if (IS_ERR(sub)) {
 				rc = PTR_ERR(sub);
 				break;
@@ -472,7 +576,6 @@ static int lov_io_rw_iter_init(const struct lu_env *env,
 			       const struct cl_io_slice *ios)
 {
 	struct lov_io *lio = cl2lov_io(env, ios);
-	struct lov_stripe_md *lsm = lio->lis_object->lo_lsm;
 	struct cl_io *io = ios->cis_io;
 	u64 start = io->u.ci_rw.crw_pos;
 	struct lov_stripe_md_entry *lse;
@@ -484,7 +587,7 @@ static int lov_io_rw_iter_init(const struct lu_env *env,
 	if (cl_io_is_append(io))
 		return lov_io_iter_init(env, ios);
 
-	index = lov_lsm_entry(lsm, io->u.ci_rw.crw_pos);
+	index = lov_io_layout_at(lio, io->u.ci_rw.crw_pos);
 	if (index < 0) { /* non-existing layout component */
 		if (io->ci_type == CIT_READ) {
 			/* TODO: it needs to detect the next component and
@@ -542,7 +645,7 @@ static int lov_io_setattr_iter_init(const struct lu_env *env,
 	int index;
 
 	if (cl_io_is_trunc(io) && lio->lis_pos > 0) {
-		index = lov_lsm_entry(lsm, lio->lis_pos - 1);
+		index = lov_io_layout_at(lio, lio->lis_pos - 1);
 		/* no entry found for such offset */
 		if (index < 0) {
 			io->ci_result = -ENODATA;
@@ -676,7 +779,7 @@ static int lov_io_read_ahead(const struct lu_env *env,
 	int rc;
 
 	offset = cl_offset(obj, start);
-	index = lov_lsm_entry(loo->lo_lsm, offset);
+	index = lov_io_layout_at(lio, offset);
 	if (index < 0 || !lsm_entry_inited(loo->lo_lsm, index))
 		return -ENODATA;
 
@@ -715,7 +818,7 @@ static int lov_io_read_ahead(const struct lu_env *env,
 					       ra_end, stripe);
 
 	/* boundary of current component */
-	ra_end = cl_index(obj, (loff_t)lov_lse(loo, index)->lsme_extent.e_end);
+	ra_end = cl_index(obj, (loff_t)lov_io_extent(lio, index)->e_end);
 	if (ra_end != CL_PAGE_EOF && ra->cra_end >= ra_end)
 		ra->cra_end = ra_end - 1;
 
@@ -1148,8 +1251,8 @@ int lov_io_init_released(const struct lu_env *env, struct cl_object *obj,
 		LASSERTF(0, "invalid type %d\n", io->ci_type);
 		result = -EOPNOTSUPP;
 		break;
-	case CIT_MISC:
 	case CIT_GLIMPSE:
+	case CIT_MISC:
 	case CIT_FSYNC:
 	case CIT_LADVISE:
 	case CIT_DATA_VERSION:
@@ -1184,4 +1287,42 @@ int lov_io_init_released(const struct lu_env *env, struct cl_object *obj,
 	return result;
 }
 
-/** @} lov */
+/**
+ * Return the index in composite:lo_entries by the file offset
+ */
+int lov_io_layout_at(struct lov_io *lio, u64 offset)
+{
+	struct lov_object *lov = lio->lis_object;
+	struct lov_layout_composite *comp = &lov->u.composite;
+	int start_index = 0;
+	int end_index = comp->lo_entry_count - 1;
+	int i;
+
+	LASSERT(lov->lo_type == LLT_COMP);
+
+	/* This is actual file offset so nothing can cover eof. */
+	if (offset == LUSTRE_EOF)
+		return -1;
+
+	if (lov_is_flr(lov)) {
+		struct lov_mirror_entry *lre;
+
+		LASSERT(lio->lis_mirror_index >= 0);
+
+		lre = &comp->lo_mirrors[lio->lis_mirror_index];
+		start_index = lre->lre_start;
+		end_index = lre->lre_end;
+	}
+
+	for (i = start_index; i <= end_index; i++) {
+		struct lov_layout_entry *lle = lov_entry(lov, i);
+
+		if ((offset >= lle->lle_extent->e_start &&
+		     offset < lle->lle_extent->e_end) ||
+		    (offset == OBD_OBJECT_EOF &&
+		     lle->lle_extent->e_end == OBD_OBJECT_EOF))
+			return i;
+	}
+
+	return -1;
+}
diff --git a/fs/lustre/lov/lov_lock.c b/fs/lustre/lov/lov_lock.c
index 5520199..0c10c3a 100644
--- a/fs/lustre/lov/lov_lock.c
+++ b/fs/lustre/lov/lov_lock.c
@@ -131,15 +131,9 @@ static struct lov_lock *lov_lock_sub_init(const struct lu_env *env,
 		ext.e_end = cl_offset(obj, lock->cll_descr.cld_end + 1);
 
 	nr = 0;
-	for (index = lov_lsm_entry(lov->lo_lsm, ext.e_start);
-	     index >= 0 && index < lov->lo_lsm->lsm_entry_count; index++) {
+	lov_foreach_io_layout(index, lov_env_io(env), &ext) {
 		struct lov_layout_raid0 *r0 = lov_r0(lov, index);
 
-		/* assume lsm entries are sorted. */
-		if (!lu_extent_is_overlapped(&ext,
-					     &lov_lse(lov, index)->lsme_extent))
-			break;
-
 		for (i = 0; i < r0->lo_nr; i++) {
 			if (likely(r0->lo_sub[i]) && /* spare layout */
 			    lov_stripe_intersects(lov->lo_lsm, index, i,
@@ -160,14 +154,9 @@ static struct lov_lock *lov_lock_sub_init(const struct lu_env *env,
 
 	lovlck->lls_nr = nr;
 	nr = 0;
-	for (index = lov_lsm_entry(lov->lo_lsm, ext.e_start);
-	     index >= 0 && index < lov->lo_lsm->lsm_entry_count; index++) {
+	lov_foreach_io_layout(index, lov_env_io(env), &ext) {
 		struct lov_layout_raid0 *r0 = lov_r0(lov, index);
 
-		/* assume lsm entries are sorted. */
-		if (!lu_extent_is_overlapped(&ext,
-					     &lov_lse(lov, index)->lsme_extent))
-			break;
 		for (i = 0; i < r0->lo_nr; ++i) {
 			struct lov_lock_sub *lls = &lovlck->lls_sub[nr];
 			struct cl_lock_descr *descr = &lls->sub_lock.cll_descr;
diff --git a/fs/lustre/lov/lov_object.c b/fs/lustre/lov/lov_object.c
index cb9b108..42acc78 100644
--- a/fs/lustre/lov/lov_object.c
+++ b/fs/lustre/lov/lov_object.c
@@ -437,8 +437,8 @@ static int lov_attr_get_dom(const struct lu_env *env, struct lov_object *lov,
 	 * component end. Alternatively, check that limit on server
 	 * and do not allow size overflow there.
 	 */
-	if (attr->cat_size > lle->lle_extent.e_end)
-		attr->cat_size = lle->lle_extent.e_end;
+	if (attr->cat_size > lle->lle_extent->e_end)
+		attr->cat_size = lle->lle_extent->e_end;
 
 	attr->cat_kms = attr->cat_size;
 
@@ -604,19 +604,38 @@ static int lov_init_composite(const struct lu_env *env, struct lov_device *dev,
 			      union lov_layout_state *state)
 {
 	struct lov_layout_composite *comp = &state->composite;
+	int flr_state = lsm->lsm_flags & LCM_FL_FLR_MASK;
 	struct lov_layout_entry *lle;
+	struct lov_mirror_entry *lre;
 	unsigned int entry_count;
 	unsigned int psz = 0;
+	unsigned int mirror_count;
 	int result = 0;
-	int i;
+	int i, j;
 
 	LASSERT(lsm->lsm_entry_count > 0);
 	LASSERT(!lov->lo_lsm);
 	lov->lo_lsm = lsm_addref(lsm);
 	lov->lo_layout_invalid = true;
 
+	dump_lsm(D_INODE, lsm);
+
 	entry_count = lsm->lsm_entry_count;
-	comp->lo_entry_count = entry_count;
+
+	spin_lock_init(&comp->lo_write_lock);
+	comp->lo_flags = lsm->lsm_flags;
+	comp->lo_mirror_count = lsm->lsm_mirror_count + 1;
+	comp->lo_entry_count = lsm->lsm_entry_count;
+	comp->lo_preferred_mirror = -1;
+
+	if (equi(flr_state == LCM_FL_NOT_FLR, comp->lo_mirror_count > 1))
+		return -EINVAL;
+
+	comp->lo_mirrors = kcalloc(comp->lo_mirror_count,
+				   sizeof(*comp->lo_mirrors),
+				   GFP_NOFS);
+	if (!comp->lo_mirrors)
+		return -ENOMEM;
 
 	comp->lo_entries = kcalloc(entry_count, sizeof(*comp->lo_entries),
 				   GFP_NOFS);
@@ -624,10 +643,13 @@ static int lov_init_composite(const struct lu_env *env, struct lov_device *dev,
 		return -ENOMEM;
 
 	/* Initiate all entry types and extents data at first */
-	for (i = 0; i < entry_count; i++) {
+	for (i = 0, j = 0, mirror_count = 1; i < entry_count; i++) {
+		int mirror_id = 0;
+
 		lle = &comp->lo_entries[i];
 
-		lle->lle_type = lov_entry_type(lsm->lsm_entries[i]);
+		lle->lle_lsme = lsm->lsm_entries[i];
+		lle->lle_type = lov_entry_type(lle->lle_lsme);
 		switch (lle->lle_type) {
 		case LOV_PATTERN_RAID0:
 			lle->lle_comp_ops = &raid0_ops;
@@ -642,30 +664,99 @@ static int lov_init_composite(const struct lu_env *env, struct lov_device *dev,
 			dump_lsm(D_ERROR, lsm);
 			return -EIO;
 		}
-		lle->lle_extent = lsm->lsm_entries[i]->lsme_extent;
+
+		lle->lle_extent = &lle->lle_lsme->lsme_extent;
+		lle->lle_valid = !(lle->lle_lsme->lsme_flags & LCME_FL_STALE);
+
+		if (flr_state != LCM_FL_NOT_FLR)
+			mirror_id = mirror_id_of(lle->lle_lsme->lsme_id);
+
+		lre = &comp->lo_mirrors[j];
+		if (i > 0) {
+			if (mirror_id == lre->lre_mirror_id) {
+				lre->lre_valid |= lle->lle_valid;
+				lre->lre_end = i;
+				continue;
+			}
+
+			/* new mirror detected, assume that the mirrors
+			 * are shorted in layout
+			 */
+			++mirror_count;
+			++j;
+			if (j >= comp->lo_mirror_count)
+				break;
+
+			lre = &comp->lo_mirrors[j];
+		}
+
+		/* entries must be sorted by mirrors */
+		lre->lre_mirror_id = mirror_id;
+		lre->lre_start = lre->lre_end = i;
+		lre->lre_preferred = (lle->lle_lsme->lsme_flags &
+					LCME_FL_PREFERRED);
+		lre->lre_valid = lle->lle_valid;
+	}
+
+	/* sanity check for FLR */
+	if (mirror_count != comp->lo_mirror_count) {
+		CDEBUG(D_INODE, DFID
+		       " doesn't have the # of mirrors it claims, %u/%u\n",
+		       PFID(lu_object_fid(lov2lu(lov))), mirror_count,
+		       comp->lo_mirror_count + 1);
+
+		result = -EINVAL;
+		goto out;
 	}
 
-	i = 0;
 	lov_foreach_layout_entry(lov, lle) {
+		int index = lov_layout_entry_index(lov, lle);
+
 		/**
 		 * If the component has not been init-ed on MDS side, for
 		 * PFL layout, we'd know that the components beyond this one
 		 * will be dynamically init-ed later on file write/trunc ops.
 		 */
-		if (lsm_entry_inited(lsm, i)) {
-			result = lle->lle_comp_ops->lco_init(env, dev, lov, i,
-							     conf, lle);
-			if (result < 0)
-				break;
+		if (!lsme_inited(lle->lle_lsme))
+			continue;
 
-			LASSERT(ergo(psz > 0, psz == result));
-			psz = result;
-		}
-		i++;
+		result = lle->lle_comp_ops->lco_init(env, dev, lov, index,
+						     conf, lle);
+		if (result < 0)
+			break;
+
+		LASSERT(ergo(psz > 0, psz == result));
+		psz = result;
 	}
+
 	if (psz > 0)
 		cl_object_header(&lov->lo_cl)->coh_page_bufsize += psz;
 
+	/* decide the preferred mirror */
+	mirror_count = 0;
+	i = 0;
+	lov_foreach_mirror_entry(lov, lre) {
+		i++;
+		if (!lre->lre_valid)
+			continue;
+
+		mirror_count++; /* valid mirror */
+
+		if (lre->lre_preferred || comp->lo_preferred_mirror < 0)
+			comp->lo_preferred_mirror = i - 1;
+	}
+	if (mirror_count == 0) {
+		CDEBUG(D_INODE, DFID
+		       " doesn't have any valid mirrors\n",
+		       PFID(lu_object_fid(lov2lu(lov))));
+
+		result = -EINVAL;
+		goto out;
+	}
+
+	LASSERT(comp->lo_preferred_mirror >= 0);
+
+out:
 	return result > 0 ? 0 : result;
 }
 
@@ -739,6 +830,10 @@ static void lov_fini_composite(const struct lu_env *env,
 		comp->lo_entries = NULL;
 	}
 
+	kfree(comp->lo_mirrors);
+
+	memset(comp, 0, sizeof(*comp));
+
 	dump_lsm(D_INODE, lov->lo_lsm);
 	lov_free_memmd(&lov->lo_lsm);
 }
@@ -821,24 +916,25 @@ static int lov_attr_get_composite(const struct lu_env *env,
 	struct lov_object *lov = cl2lov(obj);
 	struct lov_layout_entry *entry;
 	int result = 0;
-	int index = 0;
 
 	attr->cat_size = 0;
 	attr->cat_blocks = 0;
 	lov_foreach_layout_entry(lov, entry) {
+		int index = lov_layout_entry_index(lov, entry);
 		struct cl_attr *lov_attr = NULL;
 
+		if (!entry->lle_valid)
+			continue;
+
 		/* PFL: This component has not been init-ed. */
 		if (!lsm_entry_inited(lov->lo_lsm, index))
-			break;
+			continue;
 
 		result = entry->lle_comp_ops->lco_getattr(env, lov, index,
 							  entry, &lov_attr);
 		if (result < 0)
 			return result;
 
-		index++;
-
 		if (!lov_attr)
 			continue;
 
@@ -861,6 +957,7 @@ static int lov_attr_get_composite(const struct lu_env *env,
 		if (attr->cat_mtime < lov_attr->cat_mtime)
 			attr->cat_mtime = lov_attr->cat_mtime;
 	}
+
 	return 0;
 }
 
@@ -1051,12 +1148,11 @@ static int lov_layout_change(const struct lu_env *unused,
 	CDEBUG(D_INODE, DFID "Apply new layout lov %p, type %d\n",
 	       PFID(lu_object_fid(lov2lu(lov))), lov, llt);
 
-	lov->lo_type = LLT_EMPTY;
-
 	/* page bufsize fixup */
 	cl_object_header(&lov->lo_cl)->coh_page_bufsize -=
 			lov_page_slice_fixup(lov, NULL);
 
+	lov->lo_type = llt;
 	rc = new_ops->llo_init(env, lov_dev, lov, lsm, conf, state);
 	if (rc) {
 		struct obd_device *obd = lov2obd(lov_dev->ld_lov);
@@ -1066,10 +1162,10 @@ static int lov_layout_change(const struct lu_env *unused,
 		new_ops->llo_delete(env, lov, state);
 		new_ops->llo_fini(env, lov, state);
 		/* this file becomes an EMPTY file. */
+		lov->lo_type = LLT_EMPTY;
 		goto out;
 	}
 
-	lov->lo_type = llt;
 out:
 	cl_env_put(env, &refcheck);
 	return rc;
@@ -1218,7 +1314,7 @@ int lov_page_init(const struct lu_env *env, struct cl_object *obj,
 int lov_io_init(const struct lu_env *env, struct cl_object *obj,
 		struct cl_io *io)
 {
-	CL_IO_SLICE_CLEAN(lov_env_io(env), lis_cl);
+	CL_IO_SLICE_CLEAN(lov_env_io(env), lis_preserved);
 
 	CDEBUG(D_INODE, DFID "io %p type %d ignore/verify layout %d/%d\n",
 	       PFID(lu_object_fid(&obj->co_lu)), io, io->ci_type,
@@ -1767,6 +1863,7 @@ static int lov_object_fiemap(const struct lu_env *env, struct cl_object *obj,
 		goto out_fm_local;
 	}
 
+	/* TODO: rewrite it with lov_foreach_io_layout() */
 	for (entry = start_entry; entry <= end_entry; entry++) {
 		lsme = lsm->lsm_entries[entry];
 
diff --git a/fs/lustre/lov/lov_page.c b/fs/lustre/lov/lov_page.c
index e64b350..ad2a4e7 100644
--- a/fs/lustre/lov/lov_page.c
+++ b/fs/lustre/lov/lov_page.c
@@ -82,7 +82,7 @@ int lov_page_init_composite(const struct lu_env *env, struct cl_object *obj,
 	int rc;
 
 	offset = cl_offset(obj, index);
-	entry = lov_lsm_entry(loo->lo_lsm, offset);
+	entry = lov_io_layout_at(lio, offset);
 	if (entry < 0 || !lsm_entry_inited(loo->lo_lsm, entry)) {
 		/* non-existing layout component */
 		lov_page_init_empty(env, obj, page, index);
diff --git a/fs/lustre/obdclass/cl_io.c b/fs/lustre/obdclass/cl_io.c
index 3dc5c87..ca94eb3 100644
--- a/fs/lustre/obdclass/cl_io.c
+++ b/fs/lustre/obdclass/cl_io.c
@@ -191,6 +191,9 @@ int cl_io_init(const struct lu_env *env, struct cl_io *io,
 {
 	LASSERT(obj == cl_object_top(obj));
 
+	/* clear I/O restart from previous instance */
+	io->ci_need_restart = 0;
+
 	return __cl_io_init(env, io, iot, obj);
 }
 EXPORT_SYMBOL(cl_io_init);
@@ -722,6 +725,12 @@ int cl_io_loop(const struct lu_env *env, struct cl_io *io)
 		}
 		cl_io_iter_fini(env, io);
 	} while (result == 0 && io->ci_continue);
+
+	if (result == -EWOULDBLOCK && io->ci_ndelay) {
+		io->ci_need_restart = 1;
+		result = 0;
+	}
+
 	if (result == 0)
 		result = io->ci_result;
 	return result < 0 ? result : 0;
@@ -917,8 +926,8 @@ static void cl_page_list_assume(const struct lu_env *env,
 /**
  * Discards all pages in a queue.
  */
-static void cl_page_list_discard(const struct lu_env *env, struct cl_io *io,
-				 struct cl_page_list *plist)
+void cl_page_list_discard(const struct lu_env *env, struct cl_io *io,
+			  struct cl_page_list *plist)
 {
 	struct cl_page *page;
 
@@ -926,6 +935,7 @@ static void cl_page_list_discard(const struct lu_env *env, struct cl_io *io,
 	cl_page_list_for_each(page, plist)
 		cl_page_discard(env, io, page);
 }
+EXPORT_SYMBOL(cl_page_list_discard);
 
 /**
  * Initialize dual page queue.
diff --git a/fs/lustre/osc/osc_cache.c b/fs/lustre/osc/osc_cache.c
index 7a707a1..4ddca32 100644
--- a/fs/lustre/osc/osc_cache.c
+++ b/fs/lustre/osc/osc_cache.c
@@ -1916,6 +1916,7 @@ static int try_to_add_extent_for_io(struct client_obd *cli,
 
 		if (tmp->oe_srvlock != ext->oe_srvlock ||
 		    !tmp->oe_grants != !ext->oe_grants ||
+		    tmp->oe_ndelay != ext->oe_ndelay ||
 		    tmp->oe_no_merge || ext->oe_no_merge)
 			return 0;
 
@@ -2604,7 +2605,7 @@ int osc_flush_async_page(const struct lu_env *env, struct cl_io *io,
 }
 
 int osc_queue_sync_pages(const struct lu_env *env, struct osc_object *obj,
-			 struct list_head *list, int cmd, int brw_flags)
+			 struct list_head *list, int brw_flags)
 {
 	struct client_obd *cli = osc_cli(obj);
 	struct osc_extent *ext;
@@ -2642,7 +2643,7 @@ int osc_queue_sync_pages(const struct lu_env *env, struct osc_object *obj,
 		return -ENOMEM;
 	}
 
-	ext->oe_rw = !!(cmd & OBD_BRW_READ);
+	ext->oe_rw = !!(brw_flags & OBD_BRW_READ);
 	ext->oe_sync = 1;
 	ext->oe_no_merge = !can_merge;
 	ext->oe_urgent = 1;
@@ -2651,6 +2652,7 @@ int osc_queue_sync_pages(const struct lu_env *env, struct osc_object *obj,
 	ext->oe_max_end = end;
 	ext->oe_obj = obj;
 	ext->oe_srvlock = !!(brw_flags & OBD_BRW_SRVLOCK);
+	ext->oe_ndelay = !!(brw_flags & OBD_BRW_NDELAY);
 	ext->oe_nr_pages = page_count;
 	ext->oe_mppr = mppr;
 	list_splice_init(list, &ext->oe_pages);
@@ -2658,7 +2660,7 @@ int osc_queue_sync_pages(const struct lu_env *env, struct osc_object *obj,
 	osc_object_lock(obj);
 	/* Reuse the initial refcount for RPC, don't drop it */
 	osc_extent_state_set(ext, OES_LOCK_DONE);
-	if (cmd & OBD_BRW_WRITE) {
+	if (!ext->oe_rw) { /* write */
 		list_add_tail(&ext->oe_link, &obj->oo_urgent_exts);
 		osc_update_pending(obj, OBD_BRW_WRITE, page_count);
 	} else {
diff --git a/fs/lustre/osc/osc_io.c b/fs/lustre/osc/osc_io.c
index d2e2f7f..b26d513 100644
--- a/fs/lustre/osc/osc_io.c
+++ b/fs/lustre/osc/osc_io.c
@@ -120,7 +120,6 @@ int osc_io_submit(const struct lu_env *env, const struct cl_io_slice *ios,
 	struct cl_page_list *qout = &queue->c2_qout;
 	unsigned int queued = 0;
 	int result = 0;
-	int cmd;
 	int brw_flags;
 	unsigned int max_pages;
 
@@ -132,8 +131,10 @@ int osc_io_submit(const struct lu_env *env, const struct cl_io_slice *ios,
 	cli = osc_cli(osc);
 	max_pages = cli->cl_max_pages_per_rpc;
 
-	cmd = crt == CRT_WRITE ? OBD_BRW_WRITE : OBD_BRW_READ;
 	brw_flags = osc_io_srvlock(cl2osc_io(env, ios)) ? OBD_BRW_SRVLOCK : 0;
+	brw_flags |= crt == CRT_WRITE ? OBD_BRW_WRITE : OBD_BRW_READ;
+	if (crt == CRT_READ && ios->cis_io->ci_ndelay)
+		brw_flags |= OBD_BRW_NDELAY;
 
 	/*
 	 * NOTE: here @page is a top-level page. This is done to avoid
@@ -187,7 +188,7 @@ int osc_io_submit(const struct lu_env *env, const struct cl_io_slice *ios,
 
 		if (++queued == max_pages) {
 			queued = 0;
-			result = osc_queue_sync_pages(env, osc, &list, cmd,
+			result = osc_queue_sync_pages(env, osc, &list,
 						      brw_flags);
 			if (result < 0)
 				break;
@@ -195,7 +196,7 @@ int osc_io_submit(const struct lu_env *env, const struct cl_io_slice *ios,
 	}
 
 	if (queued > 0)
-		result = osc_queue_sync_pages(env, osc, &list, cmd, brw_flags);
+		result = osc_queue_sync_pages(env, osc, &list, brw_flags);
 
 	/* Update c/mtime for sync write. LU-7310 */
 	if (crt == CRT_WRITE && qout->pl_nr > 0 && !result) {
diff --git a/fs/lustre/osc/osc_lock.c b/fs/lustre/osc/osc_lock.c
index 84dda93..1ede75c 100644
--- a/fs/lustre/osc/osc_lock.c
+++ b/fs/lustre/osc/osc_lock.c
@@ -301,6 +301,8 @@ static int osc_lock_upcall(void *cookie, struct lustre_handle *lockh,
 				    NULL, &oscl->ols_lvb);
 		/* Hide the error. */
 		rc = 0;
+	} else if (rc < 0 && oscl->ols_flags & LDLM_FL_NDELAY) {
+		rc = -EWOULDBLOCK;
 	}
 
 	if (oscl->ols_owner)
@@ -1167,6 +1169,8 @@ int osc_lock_init(const struct lu_env *env,
 		oscl->ols_flags |= LDLM_FL_BLOCK_GRANTED;
 		oscl->ols_glimpse = 1;
 	}
+	if (io->ci_ndelay && cl_object_same(io->ci_obj, obj))
+		oscl->ols_flags |= LDLM_FL_NDELAY;
 	osc_lock_build_einfo(env, lock, cl2osc(obj), &oscl->ols_einfo);
 
 	cl_lock_slice_add(lock, &oscl->ols_cl, obj, &osc_lock_ops);
diff --git a/fs/lustre/osc/osc_request.c b/fs/lustre/osc/osc_request.c
index e164d6a..06ecd20 100644
--- a/fs/lustre/osc/osc_request.c
+++ b/fs/lustre/osc/osc_request.c
@@ -1790,7 +1790,7 @@ static int brw_interpret(const struct lu_env *env,
 	/* When server return -EINPROGRESS, client should always retry
 	 * regardless of the number of times the bulk was resent already.
 	 */
-	if (osc_recoverable_error(rc)) {
+	if (osc_recoverable_error(rc) && !req->rq_no_delay) {
 		if (req->rq_import_generation !=
 		    req->rq_import->imp_generation) {
 			CDEBUG(D_HA,
@@ -1872,7 +1872,8 @@ static int brw_interpret(const struct lu_env *env,
 
 	list_for_each_entry_safe(ext, tmp, &aa->aa_exts, oe_link) {
 		list_del_init(&ext->oe_link);
-		osc_extent_finish(env, ext, 1, rc);
+		osc_extent_finish(env, ext, 1,
+				  rc && req->rq_no_delay ? -EWOULDBLOCK : rc);
 	}
 	LASSERT(list_empty(&aa->aa_exts));
 	LASSERT(list_empty(&aa->aa_oaps));
@@ -1942,6 +1943,7 @@ int osc_build_rpc(const struct lu_env *env, struct client_obd *cli,
 	int page_count = 0;
 	bool soft_sync = false;
 	int grant = 0;
+	bool ndelay = false;
 	int i;
 	int rc;
 	struct ost_body *body;
@@ -1999,6 +2001,8 @@ int osc_build_rpc(const struct lu_env *env, struct client_obd *cli,
 				LASSERT(oap->oap_page_off + oap->oap_count ==
 					PAGE_SIZE);
 		}
+		if (ext->oe_ndelay)
+			ndelay = true;
 	}
 
 	/* first page in the list */
@@ -2027,6 +2031,13 @@ int osc_build_rpc(const struct lu_env *env, struct client_obd *cli,
 
 	req->rq_memalloc = mem_tight != 0;
 	oap->oap_request = ptlrpc_request_addref(req);
+	if (ndelay) {
+		req->rq_no_resend = req->rq_no_delay = 1;
+		/* probably set a shorter timeout value.
+		 * to handle ETIMEDOUT in brw_interpret() correctly.
+		 */
+		/* lustre_msg_set_timeout(req, req->rq_timeout / 2); */
+	}
 
 	/* Need to update the timestamps after the request is built in case
 	 * we race with setattr (locally or in queue at OST).  If OST gets
diff --git a/include/uapi/linux/lustre/lustre_idl.h b/include/uapi/linux/lustre/lustre_idl.h
index 951d501..a088f4a 100644
--- a/include/uapi/linux/lustre/lustre_idl.h
+++ b/include/uapi/linux/lustre/lustre_idl.h
@@ -1181,6 +1181,10 @@ struct hsm_state_set {
 #define OBD_BRW_READ		0x01
 #define OBD_BRW_WRITE		0x02
 #define OBD_BRW_RWMASK		(OBD_BRW_READ | OBD_BRW_WRITE)
+#define OBD_BRW_NDELAY		0x04 /* Non-delay RPC should be issued for
+				      * this page. Non-delay RPCs have bit
+				      * rq_no_delay set.
+				      */
 #define OBD_BRW_SYNC		0x08 /* this page is a part of synchronous
 				      * transfer and is not accounted in
 				      * the grant.
-- 
1.8.3.1
