From: James Simmons <jsimmons@infradead.org>
Date: Sun, 21 Jul 2019 21:52:18 -0400
Subject: [lustre-devel] [PATCH 11/11] lustre: internal headers checkpatch
 cleanup
In-Reply-To: <1563760338-806-1-git-send-email-jsimmons@infradead.org>
References: <1563760338-806-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1563760338-806-12-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Many checkpatch errors exist in the headers. This address
a good chuck of them. Other are left since future patches will
cleanup those areas. Others will need more code rework so this
patch handles the simple cases. This is a good step forward
toward proper kernel code style compliance.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/cl_object.h      | 13 +++++-----
 fs/lustre/include/lprocfs_status.h | 11 ++++----
 fs/lustre/include/lu_object.h      | 26 ++++++++++---------
 fs/lustre/include/lustre_acl.h     |  4 +--
 fs/lustre/include/lustre_dlm.h     | 53 +++++++++++++++++++++++---------------
 fs/lustre/include/seq_range.h      |  8 +++---
 6 files changed, 65 insertions(+), 50 deletions(-)

diff --git a/fs/lustre/include/cl_object.h b/fs/lustre/include/cl_object.h
index 691c2f5..be30ce8 100644
--- a/fs/lustre/include/cl_object.h
+++ b/fs/lustre/include/cl_object.h
@@ -987,8 +987,9 @@ struct cl_page_operations {
 /**
  * Helper macro, dumping detailed information about @page into a log.
  */
-#define CL_PAGE_DEBUG(mask, env, page, format, ...)			\
+#define CL_PAGE_DEBUG(_mask, env, page, format, ...)			\
 do {									\
+	typeof(_mask) (mask) = (_mask);					\
 	if (cfs_cdebug_show(mask, DEBUG_SUBSYSTEM)) {			\
 		LIBCFS_DEBUG_MSG_DATA_DECL(msgdata, mask, NULL);	\
 		cl_page_print(env, &msgdata, lu_cdebug_printer, page);  \
@@ -999,8 +1000,9 @@ struct cl_page_operations {
 /**
  * Helper macro, dumping shorter information about @page into a log.
  */
-#define CL_PAGE_HEADER(mask, env, page, format, ...)			\
+#define CL_PAGE_HEADER(_mask, env, page, format, ...)			\
 do {									\
+	typeof(_mask) (mask) = (_mask);					\
 	if (cfs_cdebug_show(mask, DEBUG_SUBSYSTEM)) {			\
 		LIBCFS_DEBUG_MSG_DATA_DECL(msgdata, mask, NULL);	\
 		cl_page_header_print(env, &msgdata, lu_cdebug_printer, page); \
@@ -1163,9 +1165,6 @@ struct cl_lock_descr {
 };
 
 #define DDESCR "%s(%d):[%lu, %lu]:%x"
-#define PDESCR(descr)							\
-	cl_lock_mode_name((descr)->cld_mode), (descr)->cld_mode,	\
-	(descr)->cld_start, (descr)->cld_end, (descr)->cld_enq_flags
 
 const char *cl_lock_mode_name(const enum cl_lock_mode mode);
 
@@ -1237,8 +1236,9 @@ struct cl_lock_operations {
 			 const struct cl_lock_slice *slice);
 };
 
-#define CL_LOCK_DEBUG(mask, env, lock, format, ...)			\
+#define CL_LOCK_DEBUG(_mask, env, lock, format, ...)			\
 do {									\
+	typeof(_mask) (mask) = (_mask);					\
 	LIBCFS_DEBUG_MSG_DATA_DECL(msgdata, mask, NULL);		\
 									\
 	if (cfs_cdebug_show(mask, DEBUG_SUBSYSTEM)) {			\
@@ -1657,6 +1657,7 @@ struct cl_io_lock_link {
 	void	       (*cill_fini)(const struct lu_env *env,
 				    struct cl_io_lock_link *link);
 };
+
 #define cill_descr	cill_lock.cll_descr
 
 /**
diff --git a/fs/lustre/include/lprocfs_status.h b/fs/lustre/include/lprocfs_status.h
index 8565c28..815ca37 100644
--- a/fs/lustre/include/lprocfs_status.h
+++ b/fs/lustre/include/lprocfs_status.h
@@ -435,11 +435,11 @@ void lprocfs_stats_unlock(struct lprocfs_stats *stats,
 	lprocfs_counter_sub(stats, idx, 1)
 
 s64 lprocfs_read_helper(struct lprocfs_counter *lc,
-			  struct lprocfs_counter_header *header,
-			  enum lprocfs_stats_flags flags,
-			  enum lprocfs_fields_flags field);
+			struct lprocfs_counter_header *header,
+			enum lprocfs_stats_flags flags,
+			enum lprocfs_fields_flags field);
 u64 lprocfs_stats_collector(struct lprocfs_stats *stats, int idx,
-			      enum lprocfs_fields_flags field);
+			    enum lprocfs_fields_flags field);
 
 extern struct lprocfs_stats *
 lprocfs_alloc_stats(unsigned int num, enum lprocfs_stats_flags flags);
@@ -553,7 +553,8 @@ void lprocfs_stats_collect(struct lprocfs_stats *stats, int idx,
 	{								\
 		return lprocfs_wr_##type(file, buffer, count, off);	\
 	}								\
-	static int name##_##type##_open(struct inode *inode, struct file *file) \
+	static int name##_##type##_open(struct inode *inode,		\
+					struct file *file)		\
 	{								\
 		return single_open(file, NULL, inode->i_private);	\
 	}								\
diff --git a/fs/lustre/include/lu_object.h b/fs/lustre/include/lu_object.h
index 8137628..05f8d81 100644
--- a/fs/lustre/include/lu_object.h
+++ b/fs/lustre/include/lu_object.h
@@ -142,10 +142,10 @@ struct lu_device_operations {
 	/**
 	 * process config specific for device.
 	 */
-	int (*ldo_process_config)(const struct lu_env *env,
-				  struct lu_device *, struct lustre_cfg *);
-	int (*ldo_recovery_complete)(const struct lu_env *,
-				     struct lu_device *);
+	int (*ldo_process_config)(const struct lu_env *env, struct lu_device *d,
+				  struct lustre_cfg *cfg);
+	int (*ldo_recovery_complete)(const struct lu_env *env,
+				     struct lu_device *dev);
 
 	/**
 	 * initialize local objects for device. this method called after layer
@@ -153,7 +153,7 @@ struct lu_device_operations {
 	 * serving user requests.
 	 */
 
-	int (*ldo_prepare)(const struct lu_env *,
+	int (*ldo_prepare)(const struct lu_env *env,
 			   struct lu_device *parent,
 			   struct lu_device *dev);
 
@@ -347,22 +347,22 @@ struct lu_device_type_operations {
 	 * lu_device_type_operations::ldto_device_alloc(). Returns pointer to
 	 * the next device in the stack.
 	 */
-	struct lu_device *(*ldto_device_free)(const struct lu_env *,
-					      struct lu_device *);
+	struct lu_device *(*ldto_device_free)(const struct lu_env *env,
+					      struct lu_device *dev);
 
 	/**
 	 * Initialize the devices after allocation
 	 */
 	int  (*ldto_device_init)(const struct lu_env *env,
-				 struct lu_device *, const char *,
-				 struct lu_device *);
+				 struct lu_device *dev, const char *name,
+				 struct lu_device *next);
 	/**
 	 * Finalize device. Dual to
 	 * lu_device_type_operations::ldto_device_init(). Returns pointer to
 	 * the next device in the stack.
 	 */
 	struct lu_device *(*ldto_device_fini)(const struct lu_env *env,
-					      struct lu_device *);
+					      struct lu_device *dev);
 	/**
 	 * Initialize device type. This is called on module load.
 	 */
@@ -753,8 +753,9 @@ int lu_cdebug_printer(const struct lu_env *env,
 /**
  * Print object description followed by a user-supplied message.
  */
-#define LU_OBJECT_DEBUG(mask, env, object, format, ...)			\
+#define LU_OBJECT_DEBUG(_mask, env, object, format, ...)		\
 do {									\
+	typeof(_mask) (mask) = (_mask);					\
 	if (cfs_cdebug_show(mask, DEBUG_SUBSYSTEM)) {			\
 		LIBCFS_DEBUG_MSG_DATA_DECL(msgdata, mask, NULL);	\
 		lu_object_print(env, &msgdata, lu_cdebug_printer, object);\
@@ -765,8 +766,9 @@ int lu_cdebug_printer(const struct lu_env *env,
 /**
  * Print short object description followed by a user-supplied message.
  */
-#define LU_OBJECT_HEADER(mask, env, object, format, ...)		\
+#define LU_OBJECT_HEADER(_mask, env, object, format, ...)		\
 do {									\
+	typeof(_mask) (mask) = (_mask);					\
 	if (cfs_cdebug_show(mask, DEBUG_SUBSYSTEM)) {			\
 		LIBCFS_DEBUG_MSG_DATA_DECL(msgdata, mask, NULL);	\
 		lu_object_header_print(env, &msgdata, lu_cdebug_printer,\
diff --git a/fs/lustre/include/lustre_acl.h b/fs/lustre/include/lustre_acl.h
index e7575a1..aff77b0 100644
--- a/fs/lustre/include/lustre_acl.h
+++ b/fs/lustre/include/lustre_acl.h
@@ -40,8 +40,8 @@
 #include <linux/posix_acl_xattr.h>
 
 #define LUSTRE_POSIX_ACL_MAX_ENTRIES	32
-#define LUSTRE_POSIX_ACL_MAX_SIZE_OLD						\
-	(sizeof(struct posix_acl_xattr_header) +				\
+#define LUSTRE_POSIX_ACL_MAX_SIZE_OLD					\
+	(sizeof(struct posix_acl_xattr_header) +			\
 	 LUSTRE_POSIX_ACL_MAX_ENTRIES * sizeof(struct posix_acl_xattr_entry))
 
 #else /* ! CONFIG_FS_POSIX_ACL */
diff --git a/fs/lustre/include/lustre_dlm.h b/fs/lustre/include/lustre_dlm.h
index 1bd5119..a1ff852 100644
--- a/fs/lustre/include/lustre_dlm.h
+++ b/fs/lustre/include/lustre_dlm.h
@@ -165,10 +165,9 @@ static inline int lockmode_compat(enum ldlm_mode exist_mode,
 #define DLM_MDS_NAMESPACE 2
 
 /* XXX
-   - do we just separate this by security domains and use a prefix for
-     multiple namespaces in the same domain?
-   -
-*/
+ * - do we just separate this by security domains and use a prefix for
+ *    multiple namespaces in the same domain?
+ */
 
 /**
  * Locking rules for LDLM:
@@ -444,7 +443,7 @@ struct ldlm_namespace {
 	enum ldlm_appetite	ns_appetite;
 
 	/** Limit of parallel AST RPC count. */
-	unsigned		ns_max_parallel_ast;
+	unsigned int		ns_max_parallel_ast;
 
 	/**
 	 * Callback to check if a lock is good to be canceled by ELC or
@@ -845,8 +844,10 @@ struct ldlm_resource {
 	 */
 	struct ldlm_interval_tree	*lr_itree;
 
-	/** Type of locks this resource can hold. Only one type per resource. */
-	enum ldlm_type			lr_type; /* LDLM_{PLAIN,EXTENT,FLOCK,IBITS} */
+	/** Type of locks this resource can hold. Only one type per resource.
+	 *  LDLM_{PLAIN,EXTENT,FLOCK,IBITS}
+	 */
+	enum ldlm_type			lr_type;
 
 	/**
 	 * Server-side-only lock value block elements.
@@ -944,13 +945,20 @@ struct ldlm_ast_work {
  * Common ldlm_enqueue parameters
  */
 struct ldlm_enqueue_info {
-	enum ldlm_type		ei_type;  /** Type of the lock being enqueued. */
-	enum ldlm_mode		ei_mode;  /** Mode of the lock being enqueued. */
-	void			*ei_cb_bl;  /** blocking lock callback */
-	void			*ei_cb_cp;  /** lock completion callback */
-	void			*ei_cb_gl;  /** lock glimpse callback */
-	void			*ei_cbdata; /** Data to be passed into callbacks. */
-	unsigned int		ei_enq_slave:1; /* whether enqueue slave stripes */
+	/* Type of the lock being enqueued. */
+	enum ldlm_type		ei_type;
+	/* Mode of the lock being enqueued. */
+	enum ldlm_mode		ei_mode;
+	/* blocking lock callback */
+	void			*ei_cb_bl;
+	/* lock completion callback */
+	void			*ei_cb_cp;
+	/* lock glimpse callback */
+	void			*ei_cb_gl;
+	/* Data to be passed into callbacks. */
+	void			*ei_cbdata;
+	/* whether enqueue slave stripes */
+	unsigned int		ei_enq_slave:1;
 };
 
 extern struct obd_ops ldlm_obd_ops;
@@ -1027,7 +1035,8 @@ typedef int (*ldlm_processing_policy)(struct ldlm_lock *lock, u64 *flags,
  * namespace or every resource in a namespace.
  * @{
  */
-int ldlm_resource_iterate(struct ldlm_namespace *, const struct ldlm_res_id *,
+int ldlm_resource_iterate(struct ldlm_namespace *ns,
+			  const struct ldlm_res_id *res_id,
 			  ldlm_iterator_t iter, void *data);
 /** @} ldlm_iterator */
 
@@ -1053,9 +1062,10 @@ struct ldlm_callback_suite {
 /* ldlm_lock.c */
 void ldlm_lock2handle(const struct ldlm_lock *lock,
 		      struct lustre_handle *lockh);
-struct ldlm_lock *__ldlm_handle2lock(const struct lustre_handle *, u64 flags);
-void ldlm_cancel_callback(struct ldlm_lock *);
-int ldlm_lock_remove_from_lru(struct ldlm_lock *);
+struct ldlm_lock *__ldlm_handle2lock(const struct lustre_handle *lh,
+				     u64 flags);
+void ldlm_cancel_callback(struct ldlm_lock *lock);
+int ldlm_lock_remove_from_lru(struct ldlm_lock *lock);
 int ldlm_lock_set_data(const struct lustre_handle *lockh, void *data);
 
 /**
@@ -1155,9 +1165,10 @@ void ldlm_lock_decref_and_cancel(const struct lustre_handle *lockh,
 void ldlm_lock_allow_match(struct ldlm_lock *lock);
 void ldlm_lock_allow_match_locked(struct ldlm_lock *lock);
 enum ldlm_mode ldlm_lock_match(struct ldlm_namespace *ns, u64 flags,
-			       const struct ldlm_res_id *,
-			       enum ldlm_type type, union ldlm_policy_data *,
-			       enum ldlm_mode mode, struct lustre_handle *,
+			       const struct ldlm_res_id *res_id,
+			       enum ldlm_type type,
+			       union ldlm_policy_data *policy,
+			       enum ldlm_mode mode, struct lustre_handle *lh,
 			       int unref);
 enum ldlm_mode ldlm_revalidate_lock_handle(const struct lustre_handle *lockh,
 					   u64 *bits);
diff --git a/fs/lustre/include/seq_range.h b/fs/lustre/include/seq_range.h
index dbf73ea..ede0c4b 100644
--- a/fs/lustre/include/seq_range.h
+++ b/fs/lustre/include/seq_range.h
@@ -191,10 +191,10 @@ static inline int lu_seq_range_compare_loc(const struct lu_seq_range *r1,
  */
 #define DRANGE "[%#16.16llx-%#16.16llx]:%x:%s"
 
-#define PRANGE(range)		\
-	(range)->lsr_start,	\
-	(range)->lsr_end,	\
-	(range)->lsr_index,	\
+#define PRANGE(range)				\
+	(range)->lsr_start,			\
+	(range)->lsr_end,			\
+	(range)->lsr_index,			\
 	fld_range_is_mdt(range) ? "mdt" : "ost"
 
 #endif
-- 
1.8.3.1
