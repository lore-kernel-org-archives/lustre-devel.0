From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Sep 2019 14:55:07 -0400
Subject: [lustre-devel] [PATCH 048/151] lustre: mds: add IO locking to the
 MDC and MDT
In-Reply-To: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1569869810-23848-49-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mikhal Pershin <mpershin@whamcloud.com>

- introduce new DOM inodebit for Data-on-MDT files.
- add IO lock and glimpse handling at MDT along with
needed LVB updates for it.
- a MDC is updated to exclude DOM bit from ELC and to
handle LVB changes due to glimpse on MDT.
- add CLIO locking at MDC, it uses IBITS lock to protect
data at MDT and a MDC handles such locks to convert them
into proper CLIO locks.

WC-bug-id: https://jira.whamcloud.com/browse/LU-3285
Lustre-commit: 4f35c341f22b ("LU-3285 mds: add IO locking to the MDC and MDT")
Signed-off-by: Mikhal Pershin <mpershin@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/28018
Lustre-commit: 138b3eee3b61 ("LU-3285 osc: remove wrongly applied assertion.")
Signed-off-by: Mikhal Pershin <mpershin@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/29811
Reviewed-by: Jinshan Xiong <jinshan.xiong@gmail.com>
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
eviewed-by: Andreas Dilger <adilger@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_dlm.h         |  11 +-
 fs/lustre/include/lustre_dlm_flags.h   |   2 +-
 fs/lustre/include/lustre_osc.h         | 147 ++++-
 fs/lustre/ldlm/ldlm_internal.h         |   1 +
 fs/lustre/ldlm/ldlm_request.c          |   4 +-
 fs/lustre/llite/file.c                 |   5 +-
 fs/lustre/llite/llite_lib.c            |   1 +
 fs/lustre/lmv/lmv_obd.c                |   6 +-
 fs/lustre/mdc/mdc_dev.c                | 960 ++++++++++++++++++++++++++++++++-
 fs/lustre/mdc/mdc_internal.h           |   2 +
 fs/lustre/mdc/mdc_reint.c              |   5 +-
 fs/lustre/osc/osc_cache.c              |  12 +-
 fs/lustre/osc/osc_internal.h           |  30 +-
 fs/lustre/osc/osc_io.c                 |   3 +-
 fs/lustre/osc/osc_lock.c               | 122 ++---
 fs/lustre/osc/osc_object.c             |  31 +-
 fs/lustre/osc/osc_request.c            |  25 +-
 include/uapi/linux/lustre/lustre_idl.h |   4 +
 18 files changed, 1201 insertions(+), 170 deletions(-)

diff --git a/fs/lustre/include/lustre_dlm.h b/fs/lustre/include/lustre_dlm.h
index ce287b7..8f92225 100644
--- a/fs/lustre/include/lustre_dlm.h
+++ b/fs/lustre/include/lustre_dlm.h
@@ -723,7 +723,10 @@ struct ldlm_lock {
 
 	/** Private storage for lock user. Opaque to LDLM. */
 	void				*l_ast_data;
-
+	/* Separate ost_lvb used mostly by Data-on-MDT for now.
+	 * It is introduced to don't mix with layout lock data.
+	 */
+	struct ost_lvb		 l_ost_lvb;
 	/*
 	 * Server-side-only members.
 	 */
@@ -870,6 +873,12 @@ static inline bool ldlm_has_layout(struct ldlm_lock *lock)
 		lock->l_policy_data.l_inodebits.bits & MDS_INODELOCK_LAYOUT;
 }
 
+static inline bool ldlm_has_dom(struct ldlm_lock *lock)
+{
+	return lock->l_resource->lr_type == LDLM_IBITS &&
+	       lock->l_policy_data.l_inodebits.bits & MDS_INODELOCK_DOM;
+}
+
 static inline char *
 ldlm_ns_name(struct ldlm_namespace *ns)
 {
diff --git a/fs/lustre/include/lustre_dlm_flags.h b/fs/lustre/include/lustre_dlm_flags.h
index 87cda36..2413309 100644
--- a/fs/lustre/include/lustre_dlm_flags.h
+++ b/fs/lustre/include/lustre_dlm_flags.h
@@ -393,7 +393,7 @@
 
 /** l_flags bits marked as "ast" bits */
 #define LDLM_FL_AST_MASK		(LDLM_FL_FLOCK_DEADLOCK		|\
-					 LDLM_FL_AST_DISCARD_DATA)
+					 LDLM_FL_DISCARD_DATA)
 
 /** l_flags bits marked as "blocked" bits */
 #define LDLM_FL_BLOCKED_MASK		(LDLM_FL_BLOCK_GRANTED		|\
diff --git a/fs/lustre/include/lustre_osc.h b/fs/lustre/include/lustre_osc.h
index 290f3c9..ecca719 100644
--- a/fs/lustre/include/lustre_osc.h
+++ b/fs/lustre/include/lustre_osc.h
@@ -190,6 +190,73 @@ struct osc_thread_info {
 	struct lu_buf		oti_ladvise_buf;
 };
 
+static inline u64 osc_enq2ldlm_flags(u32 enqflags)
+{
+	u64 result = 0;
+
+	CDEBUG(D_DLMTRACE, "flags: %x\n", enqflags);
+
+	LASSERT((enqflags & ~CEF_MASK) == 0);
+
+	if (enqflags & CEF_NONBLOCK)
+		result |= LDLM_FL_BLOCK_NOWAIT;
+	if (enqflags & CEF_GLIMPSE)
+		result |= LDLM_FL_HAS_INTENT;
+	if (enqflags & CEF_DISCARD_DATA)
+		result |= LDLM_FL_AST_DISCARD_DATA;
+	if (enqflags & CEF_PEEK)
+		result |= LDLM_FL_TEST_LOCK;
+	if (enqflags & CEF_LOCK_MATCH)
+		result |= LDLM_FL_MATCH_LOCK;
+	if (enqflags & CEF_LOCK_NO_EXPAND)
+		result |= LDLM_FL_NO_EXPANSION;
+	if (enqflags & CEF_SPECULATIVE)
+		result |= LDLM_FL_SPECULATIVE;
+	return result;
+}
+
+typedef int (*osc_enqueue_upcall_f)(void *cookie, struct lustre_handle *lockh,
+				    int rc);
+
+struct osc_enqueue_args {
+	struct obd_export	*oa_exp;
+	enum ldlm_type		oa_type;
+	enum ldlm_mode		oa_mode;
+	u64			*oa_flags;
+	osc_enqueue_upcall_f	oa_upcall;
+	void			*oa_cookie;
+	struct ost_lvb		*oa_lvb;
+	struct lustre_handle	oa_lockh;
+	bool			oa_speculative;
+};
+
+/**
+ * Bit flags for osc_dlm_lock_at_pageoff().
+ */
+enum osc_dap_flags {
+	/**
+	 * Just check if the desired lock exists, it won't hold reference
+	 * count on lock.
+	 */
+	OSC_DAP_FL_TEST_LOCK = BIT(0),
+	/**
+	 * Return the lock even if it is being canceled.
+	 */
+	OSC_DAP_FL_CANCELING = BIT(1),
+};
+
+/*
+ * The set of operations which are different for MDC and OSC objects
+ */
+struct osc_object_operations {
+	void (*oto_build_res_name)(struct osc_object *osc,
+				   struct ldlm_res_id *resname);
+	struct ldlm_lock* (*oto_dlmlock_at_pgoff)(const struct lu_env *env,
+						struct osc_object *obj,
+						pgoff_t index,
+						enum osc_dap_flags dap_flags);
+};
+
 struct osc_object {
 	struct cl_object	oo_cl;
 	struct lov_oinfo	*oo_oinfo;
@@ -243,9 +310,24 @@ struct osc_object {
 	atomic_t		oo_nr_ios;
 	wait_queue_head_t	oo_io_waitq;
 
+	const struct osc_object_operations *oo_obj_ops;
 	bool			oo_initialized;
 };
 
+static inline void osc_build_res_name(struct osc_object *osc,
+				      struct ldlm_res_id *resname)
+{
+	return osc->oo_obj_ops->oto_build_res_name(osc, resname);
+}
+
+static inline struct ldlm_lock *osc_dlmlock_at_pgoff(const struct lu_env *env,
+						    struct osc_object *obj,
+						    pgoff_t index,
+						    enum osc_dap_flags flags)
+{
+	return obj->oo_obj_ops->oto_dlmlock_at_pgoff(env, obj, index, flags);
+}
+
 static inline void osc_object_lock(struct osc_object *obj)
 {
 	spin_lock(&obj->oo_lock);
@@ -264,6 +346,18 @@ static inline void osc_object_unlock(struct osc_object *obj)
 #define assert_osc_object_is_locked(obj)	\
 	assert_spin_locked(&obj->oo_lock)
 
+static inline void osc_object_set_contended(struct osc_object *obj)
+{
+	obj->oo_contention_time = ktime_get();
+	/* mb(); */
+	obj->oo_contended = 1;
+}
+
+static inline void osc_object_clear_contended(struct osc_object *obj)
+{
+	obj->oo_contended = 0;
+}
+
 /*
  * Lock "micro-states" for osc layer.
  */
@@ -340,7 +434,8 @@ struct osc_lock {
 	enum osc_lock_state		ols_state;
 	/* lock value block */
 	struct ost_lvb			ols_lvb;
-
+	/** Lockless operations to be used by lockless lock */
+	const struct cl_lock_operations *ols_lockless_ops;
 	/*
 	 * true, if ldlm_lock_addref() was called against
 	 * osc_lock::ols_lock. This is used for sanity checking.
@@ -393,6 +488,11 @@ struct osc_lock {
 					ols_speculative:1;
 };
 
+static inline int osc_lock_is_lockless(const struct osc_lock *ols)
+{
+	return (ols->ols_cl.cls_ops == ols->ols_lockless_ops);
+}
+
 /*
  * Page state private for osc layer.
  */
@@ -498,11 +598,14 @@ static inline void osc_io_unplug(const struct lu_env *env,
 	(void)__osc_io_unplug(env, cli, osc, 0);
 }
 
-void osc_object_set_contended(struct osc_object *obj);
-void osc_object_clear_contended(struct osc_object *obj);
-int osc_object_is_contended(struct osc_object *obj);
+typedef bool (*osc_page_gang_cbt)(const struct lu_env *, struct cl_io *,
+				  struct osc_page *, void *);
+bool osc_page_gang_lookup(const struct lu_env *env, struct cl_io *io,
+			  struct osc_object *osc, pgoff_t start, pgoff_t end,
+			  osc_page_gang_cbt cb, void *cbdata);
 
-int osc_lock_is_lockless(const struct osc_lock *olck);
+bool osc_discard_cb(const struct lu_env *env, struct cl_io *io,
+		    struct osc_page *ops, void *cbdata);
 
 /* osc_dev.c */
 int osc_device_init(const struct lu_env *env, struct lu_device *d,
@@ -527,6 +630,10 @@ int osc_attr_update(const struct lu_env *env, struct cl_object *obj,
 int osc_object_glimpse(const struct lu_env *env, const struct cl_object *obj,
 		       struct ost_lvb *lvb);
 int osc_object_invalidate(const struct lu_env *env, struct osc_object *osc);
+int osc_object_is_contended(struct osc_object *obj);
+int osc_object_find_cbdata(const struct lu_env *env, struct cl_object *obj,
+			   ldlm_iterator_t iter, void *data);
+int osc_object_prune(const struct lu_env *env, struct cl_object *obj);
 
 /* osc_request.c */
 void osc_init_grant(struct client_obd *cli, struct obd_connect_data *ocd);
@@ -564,11 +671,27 @@ int osc_io_read_start(const struct lu_env *env,
 int osc_io_write_start(const struct lu_env *env,
 		       const struct cl_io_slice *slice);
 void osc_io_end(const struct lu_env *env, const struct cl_io_slice *slice);
-
 int osc_io_fsync_start(const struct lu_env *env,
 		       const struct cl_io_slice *slice);
 void osc_io_fsync_end(const struct lu_env *env,
 		      const struct cl_io_slice *slice);
+void osc_read_ahead_release(const struct lu_env *env, void *cbdata);
+
+/* osc_lock.c */
+void osc_lock_to_lockless(const struct lu_env *env, struct osc_lock *ols,
+			  int force);
+void osc_lock_wake_waiters(const struct lu_env *env, struct osc_object *osc,
+			   struct osc_lock *oscl);
+int osc_lock_enqueue_wait(const struct lu_env *env, struct osc_object *obj,
+			  struct osc_lock *oscl);
+void osc_lock_set_writer(const struct lu_env *env, const struct cl_io *io,
+			 struct cl_object *obj, struct osc_lock *oscl);
+int osc_lock_print(const struct lu_env *env, void *cookie,
+		   lu_printer_t p, const struct cl_lock_slice *slice);
+void osc_lock_cancel(const struct lu_env *env,
+		     const struct cl_lock_slice *slice);
+void osc_lock_fini(const struct lu_env *env, struct cl_lock_slice *slice);
+int osc_ldlm_glimpse_ast(struct ldlm_lock *dlmlock, void *data);
 
 /****************************************************************************
  *
@@ -828,18 +951,6 @@ struct osc_extent {
 	unsigned int		oe_mppr;
 };
 
-int osc_extent_finish(const struct lu_env *env, struct osc_extent *ext,
-		      int sent, int rc);
-void osc_extent_release(const struct lu_env *env, struct osc_extent *ext);
-
-int osc_lock_discard_pages(const struct lu_env *env, struct osc_object *osc,
-			   pgoff_t start, pgoff_t end, bool discard_pages);
-
-typedef bool (*osc_page_gang_cbt)(const struct lu_env *, struct cl_io *,
-				  struct osc_page *, void *);
-bool osc_page_gang_lookup(const struct lu_env *env, struct cl_io *io,
-			  struct osc_object *osc, pgoff_t start, pgoff_t end,
-			  osc_page_gang_cbt cb, void *cbdata);
 /* @} osc */
 
 #endif /* LUSTRE_OSC_H */
diff --git a/fs/lustre/ldlm/ldlm_internal.h b/fs/lustre/ldlm/ldlm_internal.h
index c3788c2..275d823 100644
--- a/fs/lustre/ldlm/ldlm_internal.h
+++ b/fs/lustre/ldlm/ldlm_internal.h
@@ -37,6 +37,7 @@
 extern struct list_head ldlm_srv_namespace_list;
 extern struct mutex ldlm_cli_namespace_lock;
 extern struct list_head ldlm_cli_active_namespace_list;
+extern struct kmem_cache *ldlm_glimpse_work_kmem;
 
 static inline int ldlm_namespace_nr_read(enum ldlm_side client)
 {
diff --git a/fs/lustre/ldlm/ldlm_request.c b/fs/lustre/ldlm/ldlm_request.c
index 4185d42..09be016 100644
--- a/fs/lustre/ldlm/ldlm_request.c
+++ b/fs/lustre/ldlm/ldlm_request.c
@@ -1488,8 +1488,8 @@ static int ldlm_prepare_lru_list(struct ldlm_namespace *ns,
 		lock->l_flags |= LDLM_FL_CBPENDING | LDLM_FL_CANCELING;
 
 		if ((flags & LDLM_LRU_FLAG_CLEANUP) &&
-		    lock->l_resource->lr_type == LDLM_EXTENT &&
-		    lock->l_granted_mode == LCK_PR)
+		    (lock->l_resource->lr_type == LDLM_EXTENT ||
+		     ldlm_has_dom(lock)) && lock->l_granted_mode == LCK_PR)
 			ldlm_set_discard_data(lock);
 
 		/* We can't re-add to l_lru as it confuses the
diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index c393856..0852e37 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -1054,8 +1054,11 @@ int ll_merge_attr(const struct lu_env *env, struct inode *inode)
 	rc = cl_object_attr_get(env, obj, attr);
 	cl_object_attr_unlock(obj);
 
-	if (rc != 0)
+	if (rc != 0) {
+		if (rc == -ENODATA)
+			rc = 0;
 		goto out_size_unlock;
+	}
 
 	if (atime < attr->cat_atime)
 		atime = attr->cat_atime;
diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index 418f464..a02ac03 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -189,6 +189,7 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt)
 	data->ocd_connect_flags = OBD_CONNECT_IBITS	| OBD_CONNECT_NODEVOH  |
 				  OBD_CONNECT_ATTRFID	| OBD_CONNECT_GRANT    |
 				  OBD_CONNECT_VERSION	| OBD_CONNECT_BRW_SIZE |
+				  OBD_CONNECT_SRVLOCK	| OBD_CONNECT_TRUNCLOCK|
 				  OBD_CONNECT_CANCELSET | OBD_CONNECT_FID      |
 				  OBD_CONNECT_AT	| OBD_CONNECT_LOV_V3   |
 				  OBD_CONNECT_VBR	| OBD_CONNECT_FULL20   |
diff --git a/fs/lustre/lmv/lmv_obd.c b/fs/lustre/lmv/lmv_obd.c
index aabd043..73ab7b6 100644
--- a/fs/lustre/lmv/lmv_obd.c
+++ b/fs/lustre/lmv/lmv_obd.c
@@ -1914,7 +1914,7 @@ static int lmv_rename(struct obd_export *exp, struct md_op_data *op_data,
 			return rc;
 
 		rc = lmv_early_cancel(exp, NULL, op_data, src_tgt->ltd_idx,
-				      LCK_EX, MDS_INODELOCK_FULL,
+				      LCK_EX, MDS_INODELOCK_ELC,
 				      MF_MDC_CANCEL_FID3);
 		if (rc)
 			return rc;
@@ -1928,7 +1928,7 @@ static int lmv_rename(struct obd_export *exp, struct md_op_data *op_data,
 		struct lmv_tgt_desc *tgt;
 
 		rc = lmv_early_cancel(exp, NULL, op_data, src_tgt->ltd_idx,
-				      LCK_EX, MDS_INODELOCK_FULL,
+				      LCK_EX, MDS_INODELOCK_ELC,
 				      MF_MDC_CANCEL_FID4);
 		if (rc)
 			return rc;
@@ -2472,7 +2472,7 @@ static int lmv_unlink(struct obd_export *exp, struct md_op_data *op_data,
 	}
 
 	rc = lmv_early_cancel(exp, NULL, op_data, tgt->ltd_idx, LCK_EX,
-			      MDS_INODELOCK_FULL, MF_MDC_CANCEL_FID3);
+			      MDS_INODELOCK_ELC, MF_MDC_CANCEL_FID3);
 	if (rc != 0)
 		return rc;
 
diff --git a/fs/lustre/mdc/mdc_dev.c b/fs/lustre/mdc/mdc_dev.c
index 77e152e..3a7afab 100644
--- a/fs/lustre/mdc/mdc_dev.c
+++ b/fs/lustre/mdc/mdc_dev.c
@@ -38,10 +38,877 @@
 
 #include "mdc_internal.h"
 
-int mdc_lock_init(const struct lu_env *env,
-		  struct cl_object *obj, struct cl_lock *lock,
-		  const struct cl_io *unused)
+static void mdc_lock_build_policy(const struct lu_env *env,
+				  union ldlm_policy_data *policy)
 {
+	memset(policy, 0, sizeof(*policy));
+	policy->l_inodebits.bits = MDS_INODELOCK_DOM;
+}
+
+int mdc_ldlm_glimpse_ast(struct ldlm_lock *dlmlock, void *data)
+{
+	return osc_ldlm_glimpse_ast(dlmlock, data);
+}
+
+static void mdc_lock_build_einfo(const struct lu_env *env,
+				 const struct cl_lock *lock,
+				 struct osc_object *osc,
+				 struct ldlm_enqueue_info *einfo)
+{
+	einfo->ei_type = LDLM_IBITS;
+	einfo->ei_mode = osc_cl_lock2ldlm(lock->cll_descr.cld_mode);
+	einfo->ei_cb_bl = mdc_ldlm_blocking_ast;
+	einfo->ei_cb_cp = ldlm_completion_ast;
+	einfo->ei_cb_gl = mdc_ldlm_glimpse_ast;
+	einfo->ei_cbdata = osc; /* value to be put into ->l_ast_data */
+}
+
+static int mdc_set_dom_lock_data(struct ldlm_lock *lock, void *data)
+{
+	int set = 0;
+
+	LASSERT(lock);
+
+	lock_res_and_lock(lock);
+
+	if (!lock->l_ast_data)
+		lock->l_ast_data = data;
+	if (lock->l_ast_data == data)
+		set = 1;
+
+	unlock_res_and_lock(lock);
+
+	return set;
+}
+
+int mdc_dom_lock_match(struct obd_export *exp, struct ldlm_res_id *res_id,
+		       enum ldlm_type type, union ldlm_policy_data *policy,
+		       enum ldlm_mode mode, u64 *flags, void *data,
+		       struct lustre_handle *lockh, int unref)
+{
+	struct obd_device *obd = exp->exp_obd;
+	u64 lflags = *flags;
+	enum ldlm_mode rc;
+
+	rc = ldlm_lock_match(obd->obd_namespace, lflags,
+			     res_id, type, policy, mode, lockh, unref);
+	if (rc == 0 || lflags & LDLM_FL_TEST_LOCK)
+		return rc;
+
+	if (data) {
+		struct ldlm_lock *lock = ldlm_handle2lock(lockh);
+
+		LASSERT(lock);
+		if (!mdc_set_dom_lock_data(lock, data)) {
+			ldlm_lock_decref(lockh, rc);
+			rc = 0;
+		}
+		LDLM_LOCK_PUT(lock);
+	}
+	return rc;
+}
+
+/**
+ * Finds an existing lock covering a page with given index.
+ * Copy of osc_obj_dlmlock_at_pgoff() but for DoM IBITS lock.
+ */
+struct ldlm_lock *mdc_dlmlock_at_pgoff(const struct lu_env *env,
+				       struct osc_object *obj, pgoff_t index,
+				       enum osc_dap_flags dap_flags)
+{
+	struct osc_thread_info *info = osc_env_info(env);
+	struct ldlm_res_id *resname = &info->oti_resname;
+	union ldlm_policy_data *policy = &info->oti_policy;
+	struct lustre_handle lockh;
+	struct ldlm_lock *lock = NULL;
+	enum ldlm_mode mode;
+	u64 flags;
+
+	fid_build_reg_res_name(lu_object_fid(osc2lu(obj)), resname);
+	mdc_lock_build_policy(env, policy);
+
+	flags = LDLM_FL_BLOCK_GRANTED | LDLM_FL_CBPENDING;
+	if (dap_flags & OSC_DAP_FL_TEST_LOCK)
+		flags |= LDLM_FL_TEST_LOCK;
+
+again:
+	/* Next, search for already existing extent locks that will cover us */
+	/* If we're trying to read, we also search for an existing PW lock.  The
+	 * VFS and page cache already protect us locally, so lots of readers/
+	 * writers can share a single PW lock.
+	 */
+	mode = mdc_dom_lock_match(osc_export(obj), resname, LDLM_IBITS, policy,
+				  LCK_PR | LCK_PW, &flags, obj, &lockh,
+				  dap_flags & OSC_DAP_FL_CANCELING);
+	if (mode) {
+		lock = ldlm_handle2lock(&lockh);
+		/* RACE: the lock is cancelled so let's try again */
+		if (!lock)
+			goto again;
+	}
+
+	return lock;
+}
+
+/**
+ * Check if page @page is covered by an extra lock or discard it.
+ */
+static bool mdc_check_and_discard_cb(const struct lu_env *env, struct cl_io *io,
+				    struct osc_page *ops, void *cbdata)
+{
+	struct osc_thread_info *info = osc_env_info(env);
+	struct osc_object *osc = cbdata;
+	pgoff_t index;
+
+	index = osc_index(ops);
+	if (index >= info->oti_fn_index) {
+		struct ldlm_lock *tmp;
+		struct cl_page *page = ops->ops_cl.cpl_page;
+
+		/* refresh non-overlapped index */
+		tmp = mdc_dlmlock_at_pgoff(env, osc, index,
+					   OSC_DAP_FL_TEST_LOCK);
+		if (tmp) {
+			info->oti_fn_index = CL_PAGE_EOF;
+			LDLM_LOCK_PUT(tmp);
+		} else if (cl_page_own(env, io, page) == 0) {
+			/* discard the page */
+			cl_page_discard(env, io, page);
+			cl_page_disown(env, io, page);
+		} else {
+			LASSERT(page->cp_state == CPS_FREEING);
+		}
+	}
+
+	info->oti_next_index = index + 1;
+	return true;
+}
+
+/**
+ * Discard pages protected by the given lock. This function traverses radix
+ * tree to find all covering pages and discard them. If a page is being covered
+ * by other locks, it should remain in cache.
+ *
+ * If error happens on any step, the process continues anyway (the reasoning
+ * behind this being that lock cancellation cannot be delayed indefinitely).
+ */
+static int mdc_lock_discard_pages(const struct lu_env *env,
+				  struct osc_object *osc,
+				  pgoff_t start, pgoff_t end,
+				  bool discard)
+{
+	struct osc_thread_info *info = osc_env_info(env);
+	struct cl_io *io = &info->oti_io;
+	osc_page_gang_cbt cb;
+	bool res;
+	int result;
+
+	io->ci_obj = cl_object_top(osc2cl(osc));
+	io->ci_ignore_layout = 1;
+	result = cl_io_init(env, io, CIT_MISC, io->ci_obj);
+	if (result)
+		goto out;
+
+	cb = discard ? osc_discard_cb : mdc_check_and_discard_cb;
+	info->oti_fn_index = info->oti_next_index = start;
+	do {
+		res = osc_page_gang_lookup(env, io, osc, info->oti_next_index,
+					   end, cb, (void *)osc);
+		if (info->oti_next_index > end)
+			break;
+
+	} while (!res);
+out:
+	cl_io_fini(env, io);
+	return result;
+}
+
+static int mdc_lock_flush(const struct lu_env *env, struct osc_object *obj,
+			  pgoff_t start, pgoff_t end, enum cl_lock_mode mode,
+			  bool discard)
+{
+	int result = 0;
+	int rc;
+
+	if (mode == CLM_WRITE) {
+		result = osc_cache_writeback_range(env, obj, start, end, 1,
+						   discard);
+		CDEBUG(D_CACHE, "object %p: [%lu -> %lu] %d pages were %s.\n",
+		       obj, start, end, result,
+		       discard ? "discarded" : "written back");
+		if (result > 0)
+			result = 0;
+	}
+
+	rc = mdc_lock_discard_pages(env, obj, start, end, discard);
+	if (result == 0 && rc < 0)
+		result = rc;
+
+	return result;
+}
+
+void mdc_lock_lockless_cancel(const struct lu_env *env,
+			      const struct cl_lock_slice *slice)
+{
+	struct osc_lock *ols = cl2osc_lock(slice);
+	struct osc_object *osc = cl2osc(slice->cls_obj);
+	struct cl_lock_descr *descr = &slice->cls_lock->cll_descr;
+	int rc;
+
+	LASSERT(!ols->ols_dlmlock);
+	rc = mdc_lock_flush(env, osc, descr->cld_start, descr->cld_end,
+			    descr->cld_mode, 0);
+	if (rc != 0)
+		CERROR("Pages for lockless lock %p were not purged(%d)\n",
+		       ols, rc);
+
+	osc_lock_wake_waiters(env, osc, ols);
+}
+
+/**
+ * Helper for osc_dlm_blocking_ast() handling discrepancies between cl_lock
+ * and ldlm_lock caches.
+ */
+static int mdc_dlm_blocking_ast0(const struct lu_env *env,
+				 struct ldlm_lock *dlmlock,
+				 void *data, int flag)
+{
+	struct cl_object *obj = NULL;
+	int result = 0;
+	bool discard;
+	enum cl_lock_mode mode = CLM_READ;
+
+	LASSERT(flag == LDLM_CB_CANCELING);
+	LASSERT(dlmlock);
+
+	lock_res_and_lock(dlmlock);
+	if (dlmlock->l_granted_mode != dlmlock->l_req_mode) {
+		dlmlock->l_ast_data = NULL;
+		unlock_res_and_lock(dlmlock);
+		return 0;
+	}
+
+	discard = ldlm_is_discard_data(dlmlock);
+	if (dlmlock->l_granted_mode & (LCK_PW | LCK_GROUP))
+		mode = CLM_WRITE;
+
+	if (dlmlock->l_ast_data) {
+		obj = osc2cl(dlmlock->l_ast_data);
+		dlmlock->l_ast_data = NULL;
+		cl_object_get(obj);
+	}
+	unlock_res_and_lock(dlmlock);
+
+	/* if l_ast_data is NULL, the dlmlock was enqueued by AGL or
+	 * the object has been destroyed.
+	 */
+	if (obj) {
+		struct cl_attr *attr = &osc_env_info(env)->oti_attr;
+
+		/* Destroy pages covered by the extent of the DLM lock */
+		result = mdc_lock_flush(env, cl2osc(obj), cl_index(obj, 0),
+					CL_PAGE_EOF, mode, discard);
+		/* Losing a lock, set KMS to 0.
+		 * NB: assumed that DOM lock covers whole data on MDT.
+		 */
+		/* losing a lock, update kms */
+		lock_res_and_lock(dlmlock);
+		cl_object_attr_lock(obj);
+		attr->cat_kms = 0;
+		cl_object_attr_update(env, obj, attr, CAT_KMS);
+		cl_object_attr_unlock(obj);
+		unlock_res_and_lock(dlmlock);
+		cl_object_put(env, obj);
+	}
+	return result;
+}
+
+int mdc_ldlm_blocking_ast(struct ldlm_lock *dlmlock,
+			  struct ldlm_lock_desc *new, void *data, int flag)
+{
+	int rc = 0;
+
+	switch (flag) {
+	case LDLM_CB_BLOCKING: {
+		struct lustre_handle lockh;
+
+		ldlm_lock2handle(dlmlock, &lockh);
+		rc = ldlm_cli_cancel(&lockh, LCF_ASYNC);
+		if (rc == -ENODATA)
+			rc = 0;
+		break;
+	}
+	case LDLM_CB_CANCELING: {
+		struct lu_env *env;
+		u16 refcheck;
+
+		/*
+		 * This can be called in the context of outer IO, e.g.,
+		 *
+		 *    osc_enqueue_base()->...
+		 *      ->ldlm_prep_elc_req()->...
+		 *        ->ldlm_cancel_callback()->...
+		 *          ->osc_ldlm_blocking_ast()
+		 *
+		 * new environment has to be created to not corrupt outer
+		 * context.
+		 */
+		env = cl_env_get(&refcheck);
+		if (IS_ERR(env)) {
+			rc = PTR_ERR(env);
+			break;
+		}
+
+		rc = mdc_dlm_blocking_ast0(env, dlmlock, data, flag);
+		cl_env_put(env, &refcheck);
+		break;
+	}
+	default:
+		LBUG();
+	}
+	return rc;
+}
+
+/**
+ * Updates object attributes from a lock value block (lvb) received together
+ * with the DLM lock reply from the server.
+ * This can be optimized to not update attributes when lock is a result of a
+ * local match.
+ *
+ * Called under lock and resource spin-locks.
+ */
+static void mdc_lock_lvb_update(const struct lu_env *env,
+				struct osc_object *osc,
+				struct ldlm_lock *dlmlock,
+				struct ost_lvb *lvb)
+{
+	struct cl_object *obj = osc2cl(osc);
+	struct lov_oinfo *oinfo = osc->oo_oinfo;
+	struct cl_attr *attr = &osc_env_info(env)->oti_attr;
+	unsigned int valid = CAT_BLOCKS | CAT_ATIME | CAT_CTIME | CAT_MTIME |
+			     CAT_SIZE;
+
+	if (!lvb) {
+		LASSERT(dlmlock);
+		lvb = &dlmlock->l_ost_lvb;
+	}
+	cl_lvb2attr(attr, lvb);
+
+	cl_object_attr_lock(obj);
+	if (dlmlock) {
+		u64 size;
+
+		check_res_locked(dlmlock->l_resource);
+		size = lvb->lvb_size;
+
+		if (size >= oinfo->loi_kms) {
+			LDLM_DEBUG(dlmlock,
+				   "lock acquired, setting rss=%llu, kms=%llu",
+				   lvb->lvb_size, size);
+			valid |= CAT_KMS;
+			attr->cat_kms = size;
+		} else {
+			LDLM_DEBUG(dlmlock,
+				   "lock acquired, setting rss=%llu, leaving kms=%llu, end=%llu",
+				   lvb->lvb_size, oinfo->loi_kms,
+				   dlmlock->l_policy_data.l_extent.end);
+		}
+	}
+	cl_object_attr_update(env, obj, attr, valid);
+	cl_object_attr_unlock(obj);
+}
+
+static void mdc_lock_granted(const struct lu_env *env, struct osc_lock *oscl,
+			     struct lustre_handle *lockh, bool lvb_update)
+{
+	struct ldlm_lock *dlmlock;
+
+	dlmlock = ldlm_handle2lock_long(lockh, 0);
+	LASSERT(dlmlock);
+
+	/* lock reference taken by ldlm_handle2lock_long() is
+	 * owned by osc_lock and released in osc_lock_detach()
+	 */
+	lu_ref_add(&dlmlock->l_reference, "osc_lock", oscl);
+	oscl->ols_has_ref = 1;
+
+	LASSERT(!oscl->ols_dlmlock);
+	oscl->ols_dlmlock = dlmlock;
+
+	/* This may be a matched lock for glimpse request, do not hold
+	 * lock reference in that case.
+	 */
+	if (!oscl->ols_glimpse) {
+		/* hold a refc for non glimpse lock which will
+		 * be released in osc_lock_cancel()
+		 */
+		lustre_handle_copy(&oscl->ols_handle, lockh);
+		ldlm_lock_addref(lockh, oscl->ols_einfo.ei_mode);
+		oscl->ols_hold = 1;
+	}
+
+	/* Lock must have been granted. */
+	lock_res_and_lock(dlmlock);
+	if (dlmlock->l_granted_mode == dlmlock->l_req_mode) {
+		struct cl_lock_descr *descr = &oscl->ols_cl.cls_lock->cll_descr;
+
+		/* extend the lock extent, otherwise it will have problem when
+		 * we decide whether to grant a lockless lock.
+		 */
+		descr->cld_mode = osc_ldlm2cl_lock(dlmlock->l_granted_mode);
+		descr->cld_start = cl_index(descr->cld_obj, 0);
+		descr->cld_end = CL_PAGE_EOF;
+
+		/* no lvb update for matched lock */
+		if (lvb_update) {
+			LASSERT(oscl->ols_flags & LDLM_FL_LVB_READY);
+			mdc_lock_lvb_update(env, cl2osc(oscl->ols_cl.cls_obj),
+					    dlmlock, NULL);
+		}
+	}
+	unlock_res_and_lock(dlmlock);
+
+	LASSERT(oscl->ols_state != OLS_GRANTED);
+	oscl->ols_state = OLS_GRANTED;
+}
+
+/**
+ * Lock upcall function that is executed either when a reply to ENQUEUE rpc is
+ * received from a server, or after osc_enqueue_base() matched a local DLM
+ * lock.
+ */
+static int mdc_lock_upcall(void *cookie, struct lustre_handle *lockh,
+			   int errcode)
+{
+	struct osc_lock *oscl = cookie;
+	struct cl_lock_slice *slice = &oscl->ols_cl;
+	struct lu_env *env;
+	int rc;
+
+	env = cl_env_percpu_get();
+	/* should never happen, similar to osc_ldlm_blocking_ast(). */
+	LASSERT(!IS_ERR(env));
+
+	rc = ldlm_error2errno(errcode);
+	if (oscl->ols_state == OLS_ENQUEUED) {
+		oscl->ols_state = OLS_UPCALL_RECEIVED;
+	} else if (oscl->ols_state == OLS_CANCELLED) {
+		rc = -EIO;
+	} else {
+		CERROR("Impossible state: %d\n", oscl->ols_state);
+		LBUG();
+	}
+
+	CDEBUG(D_INODE, "rc %d, err %d\n", rc, errcode);
+	if (rc == 0)
+		mdc_lock_granted(env, oscl, lockh, errcode == ELDLM_OK);
+
+	/* Error handling, some errors are tolerable. */
+	if (oscl->ols_locklessable && rc == -EUSERS) {
+		/* This is a tolerable error, turn this lock into
+		 * lockless lock.
+		 */
+		osc_object_set_contended(cl2osc(slice->cls_obj));
+		LASSERT(slice->cls_ops != oscl->ols_lockless_ops);
+
+		/* Change this lock to ldlmlock-less lock. */
+		osc_lock_to_lockless(env, oscl, 1);
+		oscl->ols_state = OLS_GRANTED;
+		rc = 0;
+	} else if (oscl->ols_glimpse && rc == -ENAVAIL) {
+		LASSERT(oscl->ols_flags & LDLM_FL_LVB_READY);
+		mdc_lock_lvb_update(env, cl2osc(slice->cls_obj),
+				    NULL, &oscl->ols_lvb);
+		/* Hide the error. */
+		rc = 0;
+	}
+
+	if (oscl->ols_owner)
+		cl_sync_io_note(env, oscl->ols_owner, rc);
+	cl_env_percpu_put(env);
+
+	return rc;
+}
+
+int mdc_fill_lvb(struct ptlrpc_request *req, struct ost_lvb *lvb)
+{
+	struct mdt_body *body;
+
+	body = req_capsule_server_get(&req->rq_pill, &RMF_MDT_BODY);
+	if (!body)
+		return -EPROTO;
+
+	lvb->lvb_mtime = body->mbo_mtime;
+	lvb->lvb_atime = body->mbo_atime;
+	lvb->lvb_ctime = body->mbo_ctime;
+	lvb->lvb_blocks = body->mbo_blocks;
+	lvb->lvb_size = body->mbo_size;
+	return 0;
+}
+
+int mdc_enqueue_fini(struct ptlrpc_request *req, osc_enqueue_upcall_f upcall,
+		     void *cookie, struct lustre_handle *lockh,
+		     enum ldlm_mode mode, u64 *flags, int errcode)
+{
+	struct osc_lock *ols = cookie;
+	struct ldlm_lock *lock;
+	int rc = 0;
+
+	/* The request was created before ldlm_cli_enqueue call. */
+	if (errcode == ELDLM_LOCK_ABORTED) {
+		struct ldlm_reply *rep;
+
+		rep = req_capsule_server_get(&req->rq_pill, &RMF_DLM_REP);
+		LASSERT(rep);
+
+		rep->lock_policy_res2 =
+			ptlrpc_status_ntoh(rep->lock_policy_res2);
+		if (rep->lock_policy_res2)
+			errcode = rep->lock_policy_res2;
+
+		rc = mdc_fill_lvb(req, &ols->ols_lvb);
+		*flags |= LDLM_FL_LVB_READY;
+	} else if (errcode == ELDLM_OK) {
+		/* Callers have references, should be valid always */
+		lock = ldlm_handle2lock(lockh);
+		LASSERT(lock);
+
+		rc = mdc_fill_lvb(req, &lock->l_ost_lvb);
+		LDLM_LOCK_PUT(lock);
+		*flags |= LDLM_FL_LVB_READY;
+	}
+
+	/* Call the update callback. */
+	rc = (*upcall)(cookie, lockh, rc < 0 ? rc : errcode);
+
+	/* release the reference taken in ldlm_cli_enqueue() */
+	if (errcode == ELDLM_LOCK_MATCHED)
+		errcode = ELDLM_OK;
+	if (errcode == ELDLM_OK && lustre_handle_is_used(lockh))
+		ldlm_lock_decref(lockh, mode);
+
+	return rc;
+}
+
+int mdc_enqueue_interpret(const struct lu_env *env, struct ptlrpc_request *req,
+			  struct osc_enqueue_args *aa, int rc)
+{
+	struct ldlm_lock *lock;
+	struct lustre_handle *lockh = &aa->oa_lockh;
+	enum ldlm_mode mode = aa->oa_mode;
+
+	LASSERT(!aa->oa_speculative);
+
+	/* ldlm_cli_enqueue is holding a reference on the lock, so it must
+	 * be valid.
+	 */
+	lock = ldlm_handle2lock(lockh);
+	LASSERTF(lock,
+		 "lockh %#llx, req %p, aa %p - client evicted?\n",
+		 lockh->cookie, req, aa);
+
+	/* Take an additional reference so that a blocking AST that
+	 * ldlm_cli_enqueue_fini() might post for a failed lock, is guaranteed
+	 * to arrive after an upcall has been executed by
+	 * osc_enqueue_fini().
+	 */
+	ldlm_lock_addref(lockh, mode);
+
+	/* Let cl_lock_state_wait fail with -ERESTARTSYS to unuse sublocks. */
+	OBD_FAIL_TIMEOUT(OBD_FAIL_LDLM_ENQUEUE_HANG, 2);
+
+	/* Let CP AST to grant the lock first. */
+	OBD_FAIL_TIMEOUT(OBD_FAIL_OSC_CP_ENQ_RACE, 1);
+
+	/* Complete obtaining the lock procedure. */
+	rc = ldlm_cli_enqueue_fini(aa->oa_exp, req, aa->oa_type, 1,
+				   aa->oa_mode, aa->oa_flags, NULL, 0,
+				   lockh, rc);
+	/* Complete mdc stuff. */
+	rc = mdc_enqueue_fini(req, aa->oa_upcall, aa->oa_cookie, lockh, mode,
+			      aa->oa_flags, rc);
+
+	OBD_FAIL_TIMEOUT(OBD_FAIL_OSC_CP_CANCEL_RACE, 10);
+
+	ldlm_lock_decref(lockh, mode);
+	LDLM_LOCK_PUT(lock);
+	return rc;
+}
+
+/* When enqueuing asynchronously, locks are not ordered, we can obtain a lock
+ * from the 2nd OSC before a lock from the 1st one. This does not deadlock with
+ * other synchronous requests, however keeping some locks and trying to obtain
+ * others may take a considerable amount of time in a case of ost failure; and
+ * when other sync requests do not get released lock from a client, the client
+ * is excluded from the cluster -- such scenarious make the life difficult, so
+ * release locks just after they are obtained.
+ */
+int mdc_enqueue_send(struct obd_export *exp, struct ldlm_res_id *res_id,
+		     u64 *flags, union ldlm_policy_data *policy,
+		     struct ost_lvb *lvb, int kms_valid,
+		     osc_enqueue_upcall_f upcall, void *cookie,
+		     struct ldlm_enqueue_info *einfo, int async)
+{
+	struct obd_device *obd = exp->exp_obd;
+	struct lustre_handle lockh = { 0 };
+	struct ptlrpc_request *req = NULL;
+	struct ldlm_intent *lit;
+	enum ldlm_mode mode;
+	bool glimpse = *flags & LDLM_FL_HAS_INTENT;
+	u64 match_flags = *flags;
+	int rc;
+
+	if (!kms_valid)
+		goto no_match;
+
+	mode = einfo->ei_mode;
+	if (einfo->ei_mode == LCK_PR)
+		mode |= LCK_PW;
+
+	if (!glimpse)
+		match_flags |= LDLM_FL_BLOCK_GRANTED;
+	mode = ldlm_lock_match(obd->obd_namespace, match_flags, res_id,
+			       einfo->ei_type, policy, mode, &lockh, 0);
+	if (mode) {
+		struct ldlm_lock *matched;
+
+		if (*flags & LDLM_FL_TEST_LOCK)
+			return ELDLM_OK;
+
+		matched = ldlm_handle2lock(&lockh);
+		if (!mdc_set_dom_lock_data(matched, einfo->ei_cbdata)) {
+			ldlm_lock_decref(&lockh, mode);
+			LDLM_LOCK_PUT(matched);
+		} else {
+			*flags |= LDLM_FL_LVB_READY;
+
+			/* We already have a lock, and it's referenced. */
+			(*upcall)(cookie, &lockh, ELDLM_LOCK_MATCHED);
+
+			ldlm_lock_decref(&lockh, mode);
+			LDLM_LOCK_PUT(matched);
+			return ELDLM_OK;
+		}
+	}
+
+no_match:
+	if (*flags & (LDLM_FL_TEST_LOCK | LDLM_FL_MATCH_LOCK))
+		return -ENOLCK;
+
+	req = ptlrpc_request_alloc(class_exp2cliimp(exp), &RQF_LDLM_INTENT);
+	if (!req)
+		return -ENOMEM;
+
+	rc = ldlm_prep_enqueue_req(exp, req, NULL, 0);
+	if (rc < 0) {
+		ptlrpc_request_free(req);
+		return rc;
+	}
+
+	/* pack the intent */
+	lit = req_capsule_client_get(&req->rq_pill, &RMF_LDLM_INTENT);
+	lit->opc = glimpse ? IT_GLIMPSE : IT_BRW;
+
+	req_capsule_set_size(&req->rq_pill, &RMF_MDT_MD, RCL_SERVER, 0);
+	req_capsule_set_size(&req->rq_pill, &RMF_ACL, RCL_SERVER, 0);
+	ptlrpc_request_set_replen(req);
+
+	/* users of mdc_enqueue() can pass this flag for ldlm_lock_match() */
+	*flags &= ~LDLM_FL_BLOCK_GRANTED;
+	/* All MDC IO locks are intents */
+	*flags |= LDLM_FL_HAS_INTENT;
+	rc = ldlm_cli_enqueue(exp, &req, einfo, res_id, policy, flags, NULL,
+			      0, LVB_T_NONE, &lockh, async);
+	if (async) {
+		if (!rc) {
+			struct osc_enqueue_args *aa;
+
+			aa = ptlrpc_req_async_args(req);
+			aa->oa_exp = exp;
+			aa->oa_mode = einfo->ei_mode;
+			aa->oa_type = einfo->ei_type;
+			lustre_handle_copy(&aa->oa_lockh, &lockh);
+			aa->oa_upcall = upcall;
+			aa->oa_cookie = cookie;
+			aa->oa_speculative = false;
+			aa->oa_flags = flags;
+			aa->oa_lvb = lvb;
+
+			req->rq_interpret_reply =
+				(ptlrpc_interpterer_t)mdc_enqueue_interpret;
+			ptlrpcd_add_req(req);
+		} else {
+			ptlrpc_req_finished(req);
+		}
+		return rc;
+	}
+
+	rc = mdc_enqueue_fini(req, upcall, cookie, &lockh, einfo->ei_mode,
+			      flags, rc);
+	ptlrpc_req_finished(req);
+	return rc;
+}
+
+/**
+ * Implementation of cl_lock_operations::clo_enqueue() method for osc
+ * layer. This initiates ldlm enqueue:
+ *
+ *     - cancels conflicting locks early (osc_lock_enqueue_wait());
+ *
+ *     - calls osc_enqueue_base() to do actual enqueue.
+ *
+ * osc_enqueue_base() is supplied with an upcall function that is executed
+ * when lock is received either after a local cached ldlm lock is matched, or
+ * when a reply from the server is received.
+ *
+ * This function does not wait for the network communication to complete.
+ */
+static int mdc_lock_enqueue(const struct lu_env *env,
+			    const struct cl_lock_slice *slice,
+			    struct cl_io *unused, struct cl_sync_io *anchor)
+{
+	struct osc_thread_info *info = osc_env_info(env);
+	struct osc_io *oio = osc_env_io(env);
+	struct osc_object *osc = cl2osc(slice->cls_obj);
+	struct osc_lock *oscl = cl2osc_lock(slice);
+	struct cl_lock *lock = slice->cls_lock;
+	struct ldlm_res_id *resname = &info->oti_resname;
+	union ldlm_policy_data *policy = &info->oti_policy;
+	osc_enqueue_upcall_f upcall = mdc_lock_upcall;
+	void *cookie = (void *)oscl;
+	bool async = false;
+	int result;
+
+	LASSERTF(ergo(oscl->ols_glimpse, lock->cll_descr.cld_mode <= CLM_READ),
+		"lock = %p, ols = %p\n", lock, oscl);
+
+	if (oscl->ols_state == OLS_GRANTED)
+		return 0;
+
+	/* Lockahead is not supported on MDT yet */
+	if (oscl->ols_flags & LDLM_FL_NO_EXPANSION) {
+		result = -EOPNOTSUPP;
+		return result;
+	}
+
+	if (oscl->ols_flags & LDLM_FL_TEST_LOCK)
+		goto enqueue_base;
+
+	if (oscl->ols_glimpse) {
+		LASSERT(equi(oscl->ols_speculative, !anchor));
+		async = true;
+		goto enqueue_base;
+	}
+
+	result = osc_lock_enqueue_wait(env, osc, oscl);
+	if (result < 0)
+		goto out;
+
+	/* we can grant lockless lock right after all conflicting locks
+	 * are canceled.
+	 */
+	if (osc_lock_is_lockless(oscl)) {
+		oscl->ols_state = OLS_GRANTED;
+		oio->oi_lockless = 1;
+		return 0;
+	}
+
+enqueue_base:
+	oscl->ols_state = OLS_ENQUEUED;
+	if (anchor) {
+		atomic_inc(&anchor->csi_sync_nr);
+		oscl->ols_owner = anchor;
+	}
+
+	/**
+	 * DLM lock's ast data must be osc_object;
+	 * DLM's enqueue callback set to osc_lock_upcall() with cookie as
+	 * osc_lock.
+	 */
+	fid_build_reg_res_name(lu_object_fid(osc2lu(osc)), resname);
+	mdc_lock_build_policy(env, policy);
+	LASSERT(!oscl->ols_speculative);
+	result = mdc_enqueue_send(osc_export(osc), resname, &oscl->ols_flags,
+				  policy, &oscl->ols_lvb,
+				  osc->oo_oinfo->loi_kms_valid,
+				  upcall, cookie, &oscl->ols_einfo, async);
+	if (result == 0) {
+		if (osc_lock_is_lockless(oscl)) {
+			oio->oi_lockless = 1;
+		} else if (!async) {
+			LASSERT(oscl->ols_state == OLS_GRANTED);
+			LASSERT(oscl->ols_hold);
+			LASSERT(oscl->ols_dlmlock);
+		}
+	}
+out:
+	if (result < 0) {
+		oscl->ols_state = OLS_CANCELLED;
+		osc_lock_wake_waiters(env, osc, oscl);
+
+		if (anchor)
+			cl_sync_io_note(env, anchor, result);
+	}
+	return result;
+}
+
+static const struct cl_lock_operations mdc_lock_lockless_ops = {
+	.clo_fini	= osc_lock_fini,
+	.clo_enqueue	= mdc_lock_enqueue,
+	.clo_cancel	= mdc_lock_lockless_cancel,
+	.clo_print	= osc_lock_print
+};
+
+static const struct cl_lock_operations mdc_lock_ops = {
+	.clo_fini	= osc_lock_fini,
+	.clo_enqueue	= mdc_lock_enqueue,
+	.clo_cancel	= osc_lock_cancel,
+	.clo_print	= osc_lock_print,
+};
+
+int mdc_lock_init(const struct lu_env *env, struct cl_object *obj,
+		  struct cl_lock *lock, const struct cl_io *io)
+{
+	struct osc_lock *ols;
+	u32 enqflags = lock->cll_descr.cld_enq_flags;
+	u64 flags = osc_enq2ldlm_flags(enqflags);
+
+	/* Ignore AGL for Data-on-MDT, stat returns size data */
+	if ((enqflags & CEF_SPECULATIVE) != 0)
+		return 0;
+
+	ols = kmem_cache_zalloc(osc_lock_kmem, GFP_NOFS);
+	if (!ols)
+		return -ENOMEM;
+
+	ols->ols_state = OLS_NEW;
+	spin_lock_init(&ols->ols_lock);
+	INIT_LIST_HEAD(&ols->ols_waiting_list);
+	INIT_LIST_HEAD(&ols->ols_wait_entry);
+	INIT_LIST_HEAD(&ols->ols_nextlock_oscobj);
+	ols->ols_lockless_ops = &mdc_lock_lockless_ops;
+
+	ols->ols_flags = flags;
+	ols->ols_speculative = !!(enqflags & CEF_SPECULATIVE);
+
+	if (ols->ols_flags & LDLM_FL_HAS_INTENT) {
+		ols->ols_flags |= LDLM_FL_BLOCK_GRANTED;
+		ols->ols_glimpse = 1;
+	}
+	mdc_lock_build_einfo(env, lock, cl2osc(obj), &ols->ols_einfo);
+
+	cl_lock_slice_add(lock, &ols->ols_cl, obj, &mdc_lock_ops);
+
+	if (!(enqflags & CEF_MUST))
+		osc_lock_to_lockless(env, ols, (enqflags & CEF_NEVER));
+	if (ols->ols_locklessable && !(enqflags & CEF_DISCARD_DATA))
+		ols->ols_flags |= LDLM_FL_DENY_ON_CONTENTION;
+
+	if (io->ci_type == CIT_WRITE || cl_io_is_mkwrite(io))
+		osc_lock_set_writer(env, io, obj, ols);
+
+	LDLM_DEBUG_NOLOCK("lock %p, mdc lock %p, flags %llx\n",
+			  lock, ols, ols->ols_flags);
 	return 0;
 }
 
@@ -141,6 +1008,33 @@ static int mdc_io_setattr_start(const struct lu_env *env,
 	return rc;
 }
 
+static int mdc_io_read_ahead(const struct lu_env *env,
+			     const struct cl_io_slice *ios,
+			     pgoff_t start, struct cl_read_ahead *ra)
+{
+	struct osc_object *osc = cl2osc(ios->cis_obj);
+	struct ldlm_lock *dlmlock;
+
+	dlmlock = mdc_dlmlock_at_pgoff(env, osc, start, 0);
+	if (!dlmlock)
+		return -ENODATA;
+
+	if (dlmlock->l_req_mode != LCK_PR) {
+		struct lustre_handle lockh;
+
+		ldlm_lock2handle(dlmlock, &lockh);
+		ldlm_lock_addref(&lockh, LCK_PR);
+		ldlm_lock_decref(&lockh, dlmlock->l_req_mode);
+	}
+
+	ra->cra_rpc_size = osc_cli(osc)->cl_max_pages_per_rpc;
+	ra->cra_end = CL_PAGE_EOF;
+	ra->cra_release = osc_read_ahead_release;
+	ra->cra_cbdata = dlmlock;
+
+	return 0;
+}
+
 static struct cl_io_operations mdc_io_ops = {
 	.op = {
 		[CIT_READ] = {
@@ -176,6 +1070,7 @@ static int mdc_io_setattr_start(const struct lu_env *env,
 			.cio_end	= osc_io_fsync_end,
 		},
 	},
+	.cio_read_ahead		= mdc_io_read_ahead,
 	.cio_submit		= osc_io_submit,
 	.cio_commit_async	= osc_io_commit_async,
 };
@@ -190,6 +1085,12 @@ int mdc_io_init(const struct lu_env *env, struct cl_object *obj,
 	return 0;
 }
 
+static void mdc_build_res_name(struct osc_object *osc,
+				   struct ldlm_res_id *resname)
+{
+	fid_build_reg_res_name(lu_object_fid(osc2lu(osc)), resname);
+}
+
 /**
  * Implementation of struct cl_req_operations::cro_attr_set() for MDC
  * layer. MDC is responsible for struct obdo::o_id and struct obdo::o_seq
@@ -208,16 +1109,66 @@ static void mdc_req_attr_set(const struct lu_env *env, struct cl_object *obj,
 
 	if (flags & OBD_MD_FLID)
 		attr->cra_oa->o_valid |= OBD_MD_FLID;
+
+	if (flags & OBD_MD_FLHANDLE) {
+		struct ldlm_lock *lock;  /* _some_ lock protecting @apage */
+		struct osc_page *opg;
+
+		opg = osc_cl_page_osc(attr->cra_page, cl2osc(obj));
+		lock = mdc_dlmlock_at_pgoff(env, cl2osc(obj), osc_index(opg),
+				OSC_DAP_FL_TEST_LOCK | OSC_DAP_FL_CANCELING);
+		if (!lock && !opg->ops_srvlock) {
+			struct ldlm_resource *res;
+			struct ldlm_res_id *resname;
+
+			CL_PAGE_DEBUG(D_ERROR, env, attr->cra_page,
+				      "uncovered page!\n");
+
+			resname = &osc_env_info(env)->oti_resname;
+			mdc_build_res_name(cl2osc(obj), resname);
+			res = ldlm_resource_get(
+				osc_export(cl2osc(obj))->exp_obd->obd_namespace,
+				NULL, resname, LDLM_IBITS, 0);
+			ldlm_resource_dump(D_ERROR, res);
+
+			libcfs_debug_dumpstack(NULL);
+			LBUG();
+		}
+
+		/* check for lockless io. */
+		if (lock) {
+			attr->cra_oa->o_handle = lock->l_remote_handle;
+			attr->cra_oa->o_valid |= OBD_MD_FLHANDLE;
+			LDLM_LOCK_PUT(lock);
+		}
+	}
+}
+
+static int mdc_attr_get(const struct lu_env *env, struct cl_object *obj,
+			struct cl_attr *attr)
+{
+	struct lov_oinfo *oinfo = cl2osc(obj)->oo_oinfo;
+
+	if (OST_LVB_IS_ERR(oinfo->loi_lvb.lvb_blocks))
+		return OST_LVB_GET_ERR(oinfo->loi_lvb.lvb_blocks);
+
+	return osc_attr_get(env, obj, attr);
 }
 
 static const struct cl_object_operations mdc_ops = {
 	.coo_page_init		= osc_page_init,
 	.coo_lock_init		= mdc_lock_init,
 	.coo_io_init		= mdc_io_init,
-	.coo_attr_get		= osc_attr_get,
+	.coo_attr_get		= mdc_attr_get,
 	.coo_attr_update	= osc_attr_update,
 	.coo_glimpse		= osc_object_glimpse,
 	.coo_req_attr_set	= mdc_req_attr_set,
+	.coo_prune		= osc_object_prune,
+};
+
+static const struct osc_object_operations mdc_object_ops = {
+	.oto_build_res_name	= mdc_build_res_name,
+	.oto_dlmlock_at_pgoff	= mdc_dlmlock_at_pgoff,
 };
 
 static int mdc_object_init(const struct lu_env *env, struct lu_object *obj,
@@ -260,6 +1211,7 @@ struct lu_object *mdc_object_alloc(const struct lu_env *env,
 		lu_object_init(obj, NULL, dev);
 		osc->oo_cl.co_ops = &mdc_ops;
 		obj->lo_ops = &mdc_lu_obj_ops;
+		osc->oo_obj_ops = &mdc_object_ops;
 		osc->oo_initialized = false;
 	} else {
 		obj = NULL;
diff --git a/fs/lustre/mdc/mdc_internal.h b/fs/lustre/mdc/mdc_internal.h
index 943b383..6e69dfe 100644
--- a/fs/lustre/mdc/mdc_internal.h
+++ b/fs/lustre/mdc/mdc_internal.h
@@ -154,5 +154,7 @@ static inline unsigned long hash_x_index(u64 hash, int hash64)
 
 /* mdc_dev.c */
 extern struct lu_device_type mdc_device_type;
+int mdc_ldlm_blocking_ast(struct ldlm_lock *dlmlock,
+			  struct ldlm_lock_desc *new, void *data, int flag);
 
 #endif
diff --git a/fs/lustre/mdc/mdc_reint.c b/fs/lustre/mdc/mdc_reint.c
index e0e7b00..87dabaf 100644
--- a/fs/lustre/mdc/mdc_reint.c
+++ b/fs/lustre/mdc/mdc_reint.c
@@ -270,9 +270,10 @@ int mdc_unlink(struct obd_export *exp, struct md_op_data *op_data,
 						MDS_INODELOCK_UPDATE);
 	if ((op_data->op_flags & MF_MDC_CANCEL_FID3) &&
 	    (fid_is_sane(&op_data->op_fid3)))
+		/* don't cancel DoM lock which may cause data flush */
 		count += mdc_resource_get_unused(exp, &op_data->op_fid3,
 						 &cancels, LCK_EX,
-						 MDS_INODELOCK_FULL);
+						 MDS_INODELOCK_ELC);
 	req = ptlrpc_request_alloc(class_exp2cliimp(exp),
 				   &RQF_MDS_REINT_UNLINK);
 	if (!req) {
@@ -373,7 +374,7 @@ int mdc_rename(struct obd_export *exp, struct md_op_data *op_data,
 	    (fid_is_sane(&op_data->op_fid4)))
 		count += mdc_resource_get_unused(exp, &op_data->op_fid4,
 						 &cancels, LCK_EX,
-						 MDS_INODELOCK_FULL);
+						 MDS_INODELOCK_ELC);
 
 	req = ptlrpc_request_alloc(class_exp2cliimp(exp),
 				   op_data->op_cli_flags & CLI_MIGRATE ?
diff --git a/fs/lustre/osc/osc_cache.c b/fs/lustre/osc/osc_cache.c
index cda8791..32785e4 100644
--- a/fs/lustre/osc/osc_cache.c
+++ b/fs/lustre/osc/osc_cache.c
@@ -248,7 +248,9 @@ static int __osc_extent_sanity_check(struct osc_extent *ext,
 		goto out;
 	}
 
-	if (ext->oe_dlmlock && !ldlm_is_failed(ext->oe_dlmlock)) {
+	if (ext->oe_dlmlock &&
+	    ext->oe_dlmlock->l_resource->lr_type == LDLM_EXTENT &&
+	    !ldlm_is_failed(ext->oe_dlmlock)) {
 		struct ldlm_extent *extent;
 
 		extent = &ext->oe_dlmlock->l_policy_data.l_extent;
@@ -3096,6 +3098,7 @@ bool osc_page_gang_lookup(const struct lu_env *env, struct cl_io *io,
 
 	return res;
 }
+EXPORT_SYMBOL(osc_page_gang_lookup);
 
 /**
  * Check if page @page is covered by an extra lock or discard it.
@@ -3140,8 +3143,8 @@ static bool check_and_discard_cb(const struct lu_env *env, struct cl_io *io,
 	return true;
 }
 
-static bool discard_cb(const struct lu_env *env, struct cl_io *io,
-		       struct osc_page *ops, void *cbdata)
+bool osc_discard_cb(const struct lu_env *env, struct cl_io *io,
+		    struct osc_page *ops, void *cbdata)
 {
 	struct osc_thread_info *info = osc_env_info(env);
 	struct cl_page *page = ops->ops_cl.cpl_page;
@@ -3163,6 +3166,7 @@ static bool discard_cb(const struct lu_env *env, struct cl_io *io,
 
 	return true;
 }
+EXPORT_SYMBOL(osc_discard_cb);
 
 /**
  * Discard pages protected by the given lock. This function traverses radix
@@ -3186,7 +3190,7 @@ int osc_lock_discard_pages(const struct lu_env *env, struct osc_object *osc,
 	if (result != 0)
 		goto out;
 
-	cb = discard ? discard_cb : check_and_discard_cb;
+	cb = discard ? osc_discard_cb : check_and_discard_cb;
 	info->oti_fn_index = start;
 	info->oti_next_index = start;
 
diff --git a/fs/lustre/osc/osc_internal.h b/fs/lustre/osc/osc_internal.h
index f9ab069..8f89443 100644
--- a/fs/lustre/osc/osc_internal.h
+++ b/fs/lustre/osc/osc_internal.h
@@ -45,9 +45,11 @@
 int osc_shrink_grant_to_target(struct client_obd *cli, u64 target_bytes);
 void osc_update_next_shrink(struct client_obd *cli);
 int lru_queue_work(const struct lu_env *env, void *data);
-
-typedef int (*osc_enqueue_upcall_f)(void *cookie, struct lustre_handle *lockh,
-				    int rc);
+int osc_extent_finish(const struct lu_env *env, struct osc_extent *ext,
+		      int sent, int rc);
+void  osc_extent_release(const struct lu_env *env, struct osc_extent *ext);
+int osc_lock_discard_pages(const struct lu_env *env, struct osc_object *osc,
+			   pgoff_t start, pgoff_t end, bool discard);
 
 int osc_enqueue_base(struct obd_export *exp, struct ldlm_res_id *res_id,
 		     u64 *flags, union ldlm_policy_data *policy,
@@ -136,24 +138,10 @@ int osc_quotactl(struct obd_device *unused, struct obd_export *exp,
 void osc_dec_unstable_pages(struct ptlrpc_request *req);
 bool osc_over_unstable_soft_limit(struct client_obd *cli);
 
-/*
- * Bit flags for osc_dlm_lock_at_pageoff().
- */
-enum osc_dap_flags {
-	/*
-	 * Just check if the desired lock exists, it won't hold reference
-	 * count on lock.
-	 */
-	OSC_DAP_FL_TEST_LOCK	= BIT(0),
-	/*
-	 * Return the lock even if it is being canceled.
-	 */
-	OSC_DAP_FL_CANCELING	= BIT(1),
-};
-
-struct ldlm_lock *osc_dlmlock_at_pgoff(const struct lu_env *env,
-				       struct osc_object *obj, pgoff_t index,
-				       enum osc_dap_flags flags);
+struct ldlm_lock *osc_obj_dlmlock_at_pgoff(const struct lu_env *env,
+					   struct osc_object *obj,
+					   pgoff_t index,
+					   enum osc_dap_flags flags);
 
 int osc_object_invalidate(const struct lu_env *env, struct osc_object *osc);
 
diff --git a/fs/lustre/osc/osc_io.c b/fs/lustre/osc/osc_io.c
index 176ebe8..0a67089 100644
--- a/fs/lustre/osc/osc_io.c
+++ b/fs/lustre/osc/osc_io.c
@@ -57,7 +57,7 @@ static void osc_io_fini(const struct lu_env *env, const struct cl_io_slice *io)
 {
 }
 
-static void osc_read_ahead_release(const struct lu_env *env, void *cbdata)
+void osc_read_ahead_release(const struct lu_env *env, void *cbdata)
 {
 	struct ldlm_lock *dlmlock = cbdata;
 	struct lustre_handle lockh;
@@ -66,6 +66,7 @@ static void osc_read_ahead_release(const struct lu_env *env, void *cbdata)
 	ldlm_lock_decref(&lockh, LCK_PR);
 	LDLM_LOCK_PUT(dlmlock);
 }
+EXPORT_SYMBOL(osc_read_ahead_release);
 
 static int osc_io_read_ahead(const struct lu_env *env,
 			     const struct cl_io_slice *ios,
diff --git a/fs/lustre/osc/osc_lock.c b/fs/lustre/osc/osc_lock.c
index f976230..42dd654 100644
--- a/fs/lustre/osc/osc_lock.c
+++ b/fs/lustre/osc/osc_lock.c
@@ -48,22 +48,6 @@
  *  @{
  */
 
-/*****************************************************************************
- *
- * Type conversions.
- *
- */
-
-static const struct cl_lock_operations osc_lock_ops;
-static const struct cl_lock_operations osc_lock_lockless_ops;
-static void osc_lock_to_lockless(const struct lu_env *env,
-				 struct osc_lock *ols, int force);
-
-int osc_lock_is_lockless(const struct osc_lock *olck)
-{
-	return (olck->ols_cl.cls_ops == &osc_lock_lockless_ops);
-}
-
 /**
  * Returns a weak pointer to the ldlm lock identified by a handle. Returned
  * pointer cannot be dereferenced, as lock is not protected from concurrent
@@ -133,8 +117,7 @@ static int osc_lock_invariant(struct osc_lock *ols)
  *
  */
 
-static void osc_lock_fini(const struct lu_env *env,
-			  struct cl_lock_slice *slice)
+void osc_lock_fini(const struct lu_env *env, struct cl_lock_slice *slice)
 {
 	struct osc_lock *ols = cl2osc_lock(slice);
 
@@ -143,6 +126,7 @@ static void osc_lock_fini(const struct lu_env *env,
 
 	kmem_cache_free(osc_lock_kmem, ols);
 }
+EXPORT_SYMBOL(osc_lock_fini);
 
 static void osc_lock_build_policy(const struct lu_env *env,
 				  const struct cl_lock *lock,
@@ -154,31 +138,6 @@ static void osc_lock_build_policy(const struct lu_env *env,
 	policy->l_extent.gid = d->cld_gid;
 }
 
-static u64 osc_enq2ldlm_flags(u32 enqflags)
-{
-	u64 result = 0;
-
-	CDEBUG(D_DLMTRACE, "flags: %x\n", enqflags);
-
-	LASSERT((enqflags & ~CEF_MASK) == 0);
-
-	if (enqflags & CEF_NONBLOCK)
-		result |= LDLM_FL_BLOCK_NOWAIT;
-	if (enqflags & CEF_GLIMPSE)
-		result |= LDLM_FL_HAS_INTENT;
-	if (enqflags & CEF_DISCARD_DATA)
-		result |= LDLM_FL_AST_DISCARD_DATA;
-	if (enqflags & CEF_PEEK)
-		result |= LDLM_FL_TEST_LOCK;
-	if (enqflags & CEF_LOCK_MATCH)
-		result |= LDLM_FL_MATCH_LOCK;
-	if (enqflags & CEF_LOCK_NO_EXPAND)
-		result |= LDLM_FL_NO_EXPANSION;
-	if (enqflags & CEF_SPECULATIVE)
-		result |= LDLM_FL_SPECULATIVE;
-	return result;
-}
-
 /**
  * Updates object attributes from a lock value block (lvb) received together
  * with the DLM lock reply from the server. Copy of osc_update_enqueue()
@@ -330,7 +289,7 @@ static int osc_lock_upcall(void *cookie, struct lustre_handle *lockh,
 		 * lockless lock.
 		 */
 		osc_object_set_contended(cl2osc(slice->cls_obj));
-		LASSERT(slice->cls_ops == &osc_lock_ops);
+		LASSERT(slice->cls_ops != oscl->ols_lockless_ops);
 
 		/* Change this lock to ldlmlock-less lock. */
 		osc_lock_to_lockless(env, oscl, 1);
@@ -576,7 +535,7 @@ static int osc_ldlm_blocking_ast(struct ldlm_lock *dlmlock,
 	return result;
 }
 
-static int osc_ldlm_glimpse_ast(struct ldlm_lock *dlmlock, void *data)
+int osc_ldlm_glimpse_ast(struct ldlm_lock *dlmlock, void *data)
 {
 	struct ptlrpc_request *req = data;
 	struct lu_env *env;
@@ -639,6 +598,7 @@ static int osc_ldlm_glimpse_ast(struct ldlm_lock *dlmlock, void *data)
 	req->rq_status = result;
 	return result;
 }
+EXPORT_SYMBOL(osc_ldlm_glimpse_ast);
 
 static bool weigh_cb(const struct lu_env *env, struct cl_io *io,
 		     struct osc_page *ops, void *cbdata)
@@ -768,46 +728,46 @@ static void osc_lock_build_einfo(const struct lu_env *env,
  *  Additional policy can be implemented here, e.g., never do lockless-io
  *  for large extents.
  */
-static void osc_lock_to_lockless(const struct lu_env *env,
-				 struct osc_lock *ols, int force)
+void osc_lock_to_lockless(const struct lu_env *env,
+			  struct osc_lock *ols, int force)
 {
 	struct cl_lock_slice *slice = &ols->ols_cl;
+	struct osc_io *oio = osc_env_io(env);
+	struct cl_io *io = oio->oi_cl.cis_io;
+	struct cl_object *obj = slice->cls_obj;
+	struct osc_object *oob = cl2osc(obj);
+	const struct osc_device *osd = lu2osc_dev(obj->co_lu.lo_dev);
+	struct obd_connect_data *ocd;
 
 	LASSERT(ols->ols_state == OLS_NEW ||
 		ols->ols_state == OLS_UPCALL_RECEIVED);
 
 	if (force) {
 		ols->ols_locklessable = 1;
-		slice->cls_ops = &osc_lock_lockless_ops;
+		slice->cls_ops = ols->ols_lockless_ops;
 	} else {
-		struct osc_io *oio = osc_env_io(env);
-		struct cl_io *io = oio->oi_cl.cis_io;
-		struct cl_object *obj = slice->cls_obj;
-		struct osc_object *oob = cl2osc(obj);
-		const struct osc_device *osd = lu2osc_dev(obj->co_lu.lo_dev);
-		struct obd_connect_data *ocd;
-
 		LASSERT(io->ci_lockreq == CILR_MANDATORY ||
 			io->ci_lockreq == CILR_MAYBE ||
 			io->ci_lockreq == CILR_NEVER);
 
 		ocd = &class_exp2cliimp(osc_export(oob))->imp_connect_data;
 		ols->ols_locklessable = (io->ci_type != CIT_SETATTR) &&
-				(io->ci_lockreq == CILR_MAYBE) &&
-				(ocd->ocd_connect_flags & OBD_CONNECT_SRVLOCK);
+					(io->ci_lockreq == CILR_MAYBE) &&
+					(ocd->ocd_connect_flags &
+					 OBD_CONNECT_SRVLOCK);
 		if (io->ci_lockreq == CILR_NEVER ||
-			/* lockless IO */
+		    /* lockless IO */
 		    (ols->ols_locklessable && osc_object_is_contended(oob)) ||
-			/* lockless truncate */
-		    (cl_io_is_trunc(io) &&
-		     (ocd->ocd_connect_flags & OBD_CONNECT_TRUNCLOCK) &&
-		      osd->od_lockless_truncate)) {
+		    /* lockless truncate */
+		    (cl_io_is_trunc(io) && osd->od_lockless_truncate &&
+		     (ocd->ocd_connect_flags & OBD_CONNECT_TRUNCLOCK))) {
 			ols->ols_locklessable = 1;
-			slice->cls_ops = &osc_lock_lockless_ops;
+			slice->cls_ops = ols->ols_lockless_ops;
 		}
 	}
 	LASSERT(ergo(ols->ols_glimpse, !osc_lock_is_lockless(ols)));
 }
+EXPORT_SYMBOL(osc_lock_to_lockless);
 
 static bool osc_lock_compatible(const struct osc_lock *qing,
 				const struct osc_lock *qed)
@@ -832,9 +792,8 @@ static bool osc_lock_compatible(const struct osc_lock *qing,
 	return false;
 }
 
-static void osc_lock_wake_waiters(const struct lu_env *env,
-				  struct osc_object *osc,
-				  struct osc_lock *oscl)
+void osc_lock_wake_waiters(const struct lu_env *env, struct osc_object *osc,
+			   struct osc_lock *oscl)
 {
 	struct osc_lock *scan;
 
@@ -852,10 +811,10 @@ static void osc_lock_wake_waiters(const struct lu_env *env,
 	}
 	spin_unlock(&oscl->ols_lock);
 }
+EXPORT_SYMBOL(osc_lock_wake_waiters);
 
-static int osc_lock_enqueue_wait(const struct lu_env *env,
-				 struct osc_object *obj,
-				 struct osc_lock *oscl)
+int osc_lock_enqueue_wait(const struct lu_env *env, struct osc_object *obj,
+			  struct osc_lock *oscl)
 {
 	struct osc_lock *tmp_oscl;
 	struct cl_lock_descr *need = &oscl->ols_cl.cls_lock->cll_descr;
@@ -909,6 +868,7 @@ static int osc_lock_enqueue_wait(const struct lu_env *env,
 
 	return rc;
 }
+EXPORT_SYMBOL(osc_lock_enqueue_wait);
 
 /**
  * Implementation of cl_lock_operations::clo_enqueue() method for osc
@@ -1082,8 +1042,8 @@ static void osc_lock_detach(const struct lu_env *env, struct osc_lock *olck)
  *
  *     - cancels ldlm lock (ldlm_cli_cancel()).
  */
-static void osc_lock_cancel(const struct lu_env *env,
-			    const struct cl_lock_slice *slice)
+void osc_lock_cancel(const struct lu_env *env,
+		     const struct cl_lock_slice *slice)
 {
 	struct osc_object *obj = cl2osc(slice->cls_obj);
 	struct osc_lock *oscl = cl2osc_lock(slice);
@@ -1096,9 +1056,10 @@ static void osc_lock_cancel(const struct lu_env *env,
 
 	osc_lock_wake_waiters(env, obj, oscl);
 }
+EXPORT_SYMBOL(osc_lock_cancel);
 
-static int osc_lock_print(const struct lu_env *env, void *cookie,
-			  lu_printer_t p, const struct cl_lock_slice *slice)
+int osc_lock_print(const struct lu_env *env, void *cookie,
+		   lu_printer_t p, const struct cl_lock_slice *slice)
 {
 	struct osc_lock *lock = cl2osc_lock(slice);
 
@@ -1108,6 +1069,7 @@ static int osc_lock_print(const struct lu_env *env, void *cookie,
 	osc_lvb_print(env, cookie, p, &lock->ols_lvb);
 	return 0;
 }
+EXPORT_SYMBOL(osc_lock_print);
 
 static const struct cl_lock_operations osc_lock_ops = {
 	.clo_fini	= osc_lock_fini,
@@ -1141,9 +1103,8 @@ static void osc_lock_lockless_cancel(const struct lu_env *env,
 	.clo_print	= osc_lock_print
 };
 
-static void osc_lock_set_writer(const struct lu_env *env,
-				const struct cl_io *io,
-				struct cl_object *obj, struct osc_lock *oscl)
+void osc_lock_set_writer(const struct lu_env *env, const struct cl_io *io,
+			 struct cl_object *obj, struct osc_lock *oscl)
 {
 	struct cl_lock_descr *descr = &oscl->ols_cl.cls_lock->cll_descr;
 	pgoff_t io_start;
@@ -1172,6 +1133,7 @@ static void osc_lock_set_writer(const struct lu_env *env,
 		oio->oi_write_osclock = oscl;
 	}
 }
+EXPORT_SYMBOL(osc_lock_set_writer);
 
 int osc_lock_init(const struct lu_env *env,
 		  struct cl_object *obj, struct cl_lock *lock,
@@ -1189,6 +1151,7 @@ int osc_lock_init(const struct lu_env *env,
 	INIT_LIST_HEAD(&oscl->ols_waiting_list);
 	INIT_LIST_HEAD(&oscl->ols_wait_entry);
 	INIT_LIST_HEAD(&oscl->ols_nextlock_oscobj);
+	oscl->ols_lockless_ops = &osc_lock_lockless_ops;
 
 	/* Speculative lock requests must be either no_expand or glimpse
 	 * request (CEF_GLIMPSE).  non-glimpse no_expand speculative extent
@@ -1228,9 +1191,10 @@ int osc_lock_init(const struct lu_env *env,
  * Finds an existing lock covering given index and optionally different from a
  * given \a except lock.
  */
-struct ldlm_lock *osc_dlmlock_at_pgoff(const struct lu_env *env,
-				       struct osc_object *obj, pgoff_t index,
-				       enum osc_dap_flags dap_flags)
+struct ldlm_lock *osc_obj_dlmlock_at_pgoff(const struct lu_env *env,
+					   struct osc_object *obj,
+					   pgoff_t index,
+					   enum osc_dap_flags dap_flags)
 {
 	struct osc_thread_info *info = osc_env_info(env);
 	struct ldlm_res_id *resname = &info->oti_resname;
diff --git a/fs/lustre/osc/osc_object.c b/fs/lustre/osc/osc_object.c
index d34e6f2..76e7e33 100644
--- a/fs/lustre/osc/osc_object.c
+++ b/fs/lustre/osc/osc_object.c
@@ -50,6 +50,16 @@
  * Object operations.
  *
  */
+static void osc_obj_build_res_name(struct osc_object *osc,
+				   struct ldlm_res_id *resname)
+{
+	ostid_build_res_name(&osc->oo_oinfo->loi_oi, resname);
+}
+
+static const struct osc_object_operations osc_object_ops = {
+	.oto_build_res_name = osc_obj_build_res_name,
+	.oto_dlmlock_at_pgoff = osc_obj_dlmlock_at_pgoff,
+};
 
 int osc_object_init(const struct lu_env *env, struct lu_object *obj,
 		    const struct lu_object_conf *conf)
@@ -78,6 +88,8 @@ int osc_object_init(const struct lu_env *env, struct lu_object *obj,
 	spin_lock_init(&osc->oo_ol_spin);
 	INIT_LIST_HEAD(&osc->oo_ol_list);
 
+	LASSERT(osc->oo_obj_ops);
+
 	cl_object_page_init(lu2cl(obj), sizeof(struct osc_page));
 
 	return 0;
@@ -189,7 +201,7 @@ static int osc_object_ast_clear(struct ldlm_lock *lock, void *data)
 	return LDLM_ITER_CONTINUE;
 }
 
-static int osc_object_prune(const struct lu_env *env, struct cl_object *obj)
+int osc_object_prune(const struct lu_env *env, struct cl_object *obj)
 {
 	struct osc_object *osc = cl2osc(obj);
 	struct ldlm_res_id *resname = &osc_env_info(env)->oti_resname;
@@ -197,11 +209,12 @@ static int osc_object_prune(const struct lu_env *env, struct cl_object *obj)
 	/* DLM locks don't hold a reference of osc_object so we have to
 	 * clear it before the object is being destroyed.
 	 */
-	ostid_build_res_name(&osc->oo_oinfo->loi_oi, resname);
+	osc_build_res_name(osc, resname);
 	ldlm_resource_iterate(osc_export(osc)->exp_obd->obd_namespace, resname,
 			      osc_object_ast_clear, osc);
 	return 0;
 }
+EXPORT_SYMBOL(osc_object_prune);
 
 static int osc_object_fiemap(const struct lu_env *env, struct cl_object *obj,
 			     struct ll_fiemap_info_key *fmkey,
@@ -291,18 +304,6 @@ static int osc_object_fiemap(const struct lu_env *env, struct cl_object *obj,
 	return rc;
 }
 
-void osc_object_set_contended(struct osc_object *obj)
-{
-	obj->oo_contention_time = jiffies;
-	/* mb(); */
-	obj->oo_contended = 1;
-}
-
-void osc_object_clear_contended(struct osc_object *obj)
-{
-	obj->oo_contended = 0;
-}
-
 int osc_object_is_contended(struct osc_object *obj)
 {
 	struct osc_device *dev = lu2osc_dev(obj->oo_cl.co_lu.lo_dev);
@@ -327,6 +328,7 @@ int osc_object_is_contended(struct osc_object *obj)
 	}
 	return 1;
 }
+EXPORT_SYMBOL(osc_object_is_contended);
 
 /**
  * Implementation of struct cl_object_operations::coo_req_attr_set() for osc
@@ -438,6 +440,7 @@ struct lu_object *osc_object_alloc(const struct lu_env *env,
 		lu_object_init(obj, NULL, dev);
 		osc->oo_cl.co_ops = &osc_ops;
 		obj->lo_ops = &osc_lu_obj_ops;
+		osc->oo_obj_ops = &osc_object_ops;
 	} else {
 		obj = NULL;
 	}
diff --git a/fs/lustre/osc/osc_request.c b/fs/lustre/osc/osc_request.c
index 275bd12..7e3f954 100644
--- a/fs/lustre/osc/osc_request.c
+++ b/fs/lustre/osc/osc_request.c
@@ -97,18 +97,6 @@ struct osc_ladvise_args {
 	void			*la_cookie;
 };
 
-struct osc_enqueue_args {
-	struct obd_export	*oa_exp;
-	enum ldlm_type		oa_type;
-	enum ldlm_mode		oa_mode;
-	u64			*oa_flags;
-	osc_enqueue_upcall_f	oa_upcall;
-	void			*oa_cookie;
-	struct ost_lvb		*oa_lvb;
-	struct lustre_handle	oa_lockh;
-	unsigned int		oa_speculative;
-};
-
 static void osc_release_ppga(struct brw_page **ppga, u32 count);
 static int brw_interpret(const struct lu_env *env,
 			 struct ptlrpc_request *req, void *data, int rc);
@@ -2042,10 +2030,10 @@ static int osc_set_lock_data(struct ldlm_lock *lock, void *data)
 	return set;
 }
 
-static int osc_enqueue_fini(struct ptlrpc_request *req,
-			    osc_enqueue_upcall_f upcall, void *cookie,
-			    struct lustre_handle *lockh, enum ldlm_mode mode,
-			    u64 *flags, int speculative, int errcode)
+int osc_enqueue_fini(struct ptlrpc_request *req, osc_enqueue_upcall_f upcall,
+		     void *cookie, struct lustre_handle *lockh,
+		     enum ldlm_mode mode, u64 *flags, int speculative,
+		     int errcode)
 {
 	bool intent = *flags & LDLM_FL_HAS_INTENT;
 	int rc;
@@ -2077,9 +2065,8 @@ static int osc_enqueue_fini(struct ptlrpc_request *req,
 	return rc;
 }
 
-static int osc_enqueue_interpret(const struct lu_env *env,
-				 struct ptlrpc_request *req,
-				 struct osc_enqueue_args *aa, int rc)
+int osc_enqueue_interpret(const struct lu_env *env, struct ptlrpc_request *req,
+			  struct osc_enqueue_args *aa, int rc)
 {
 	struct ldlm_lock *lock;
 	struct lustre_handle *lockh = &aa->oa_lockh;
diff --git a/include/uapi/linux/lustre/lustre_idl.h b/include/uapi/linux/lustre/lustre_idl.h
index bcbe557..57a869f 100644
--- a/include/uapi/linux/lustre/lustre_idl.h
+++ b/include/uapi/linux/lustre/lustre_idl.h
@@ -1434,6 +1434,8 @@ enum mdt_reint_cmd {
 #define MDS_INODELOCK_MAXSHIFT 6
 /* This FULL lock is useful to take on unlink sort of operations */
 #define MDS_INODELOCK_FULL ((1 << (MDS_INODELOCK_MAXSHIFT + 1)) - 1)
+/* DOM lock shouldn't be canceled early, use this macro for ELC */
+#define MDS_INODELOCK_ELC (MDS_INODELOCK_FULL & ~MDS_INODELOCK_DOM)
 
 /* NOTE: until Lustre 1.8.7/2.1.1 the fid_ver() was packed into name[2],
  * but was moved into name[1] along with the OID to avoid consuming the
@@ -2153,6 +2155,8 @@ enum ldlm_intent_flags {
 	IT_QUOTA_DQACQ	= 0x00000800,
 	IT_QUOTA_CONN	= 0x00001000,
 	IT_SETXATTR	= 0x00002000,
+	IT_GLIMPSE     = 0x00004000,
+	IT_BRW	       = 0x00008000,
 };
 
 struct ldlm_intent {
-- 
1.8.3.1
