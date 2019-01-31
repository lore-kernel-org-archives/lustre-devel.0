From: James Simmons <jsimmons@infradead.org>
Date: Thu, 31 Jan 2019 12:19:09 -0500
Subject: [lustre-devel] [PATCH 05/26] lustre: use kernel types for lustre
 internal headers
In-Reply-To: <1548955170-13456-1-git-send-email-jsimmons@infradead.org>
References: <1548955170-13456-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1548955170-13456-6-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Lustre internal header was originally both a user land and kernel
implementation. The source contains many types of the form __u32
but since this is mostly kernel code change the types to kernel
internal types.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/cl_object.h  |  10 +-
 .../staging/lustre/lustre/include/lprocfs_status.h |  28 ++--
 drivers/staging/lustre/lustre/include/lu_object.h  |  46 +++----
 .../staging/lustre/lustre/include/lustre_debug.h   |   4 +-
 .../staging/lustre/lustre/include/lustre_disk.h    |   6 +-
 drivers/staging/lustre/lustre/include/lustre_dlm.h |  66 +++++-----
 .../staging/lustre/lustre/include/lustre_export.h  |  14 +-
 drivers/staging/lustre/lustre/include/lustre_fid.h |  34 ++---
 drivers/staging/lustre/lustre/include/lustre_fld.h |   6 +-
 drivers/staging/lustre/lustre/include/lustre_ha.h  |   2 +-
 .../staging/lustre/lustre/include/lustre_handles.h |   4 +-
 .../staging/lustre/lustre/include/lustre_import.h  |  28 ++--
 .../staging/lustre/lustre/include/lustre_intent.h  |   8 +-
 drivers/staging/lustre/lustre/include/lustre_lmv.h |  26 ++--
 drivers/staging/lustre/lustre/include/lustre_log.h |   8 +-
 drivers/staging/lustre/lustre/include/lustre_mdc.h |   2 +-
 drivers/staging/lustre/lustre/include/lustre_net.h | 144 ++++++++++-----------
 .../lustre/lustre/include/lustre_nrs_fifo.h        |   4 +-
 .../lustre/lustre/include/lustre_req_layout.h      |   4 +-
 drivers/staging/lustre/lustre/include/lustre_sec.h |  92 ++++++-------
 .../staging/lustre/lustre/include/lustre_swab.h    |   6 +-
 drivers/staging/lustre/lustre/include/obd.h        |  84 ++++++------
 drivers/staging/lustre/lustre/include/obd_class.h  |  28 ++--
 23 files changed, 327 insertions(+), 327 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/cl_object.h b/drivers/staging/lustre/lustre/include/cl_object.h
index 41b32b7..3109c04 100644
--- a/drivers/staging/lustre/lustre/include/cl_object.h
+++ b/drivers/staging/lustre/lustre/include/cl_object.h
@@ -153,7 +153,7 @@ struct cl_attr {
 	 *
 	 * \todo XXX An interface for block size is needed.
 	 */
-	__u64  cat_blocks;
+	u64  cat_blocks;
 	/**
 	 * User identifier for quota purposes.
 	 */
@@ -164,7 +164,7 @@ struct cl_attr {
 	gid_t  cat_gid;
 
 	/* nlink of the directory */
-	__u64  cat_nlink;
+	u64  cat_nlink;
 
 	/* Project identifier for quota purpose. */
 	u32	cat_projid;
@@ -1151,14 +1151,14 @@ struct cl_lock_descr {
 	/** Index of the last page (inclusive) protected by this lock. */
 	pgoff_t	   cld_end;
 	/** Group ID, for group lock */
-	__u64	     cld_gid;
+	u64	     cld_gid;
 	/** Lock mode. */
 	enum cl_lock_mode cld_mode;
 	/**
 	 * flags to enqueue lock. A combination of bit-flags from
 	 * enum cl_enq_flags.
 	 */
-	__u32	     cld_enq_flags;
+	u32	     cld_enq_flags;
 };
 
 #define DDESCR "%s(%d):[%lu, %lu]:%x"
@@ -2438,7 +2438,7 @@ void cl_sync_io_note(const struct lu_env *env, struct cl_sync_io *anchor,
  */
 
 struct lu_env *cl_env_get(u16 *refcheck);
-struct lu_env *cl_env_alloc(u16 *refcheck, __u32 tags);
+struct lu_env *cl_env_alloc(u16 *refcheck, u32 tags);
 void cl_env_put(struct lu_env *env, u16 *refcheck);
 unsigned int cl_env_cache_purge(unsigned int nr);
 struct lu_env *cl_env_percpu_get(void);
diff --git a/drivers/staging/lustre/lustre/include/lprocfs_status.h b/drivers/staging/lustre/lustre/include/lprocfs_status.h
index c22ae3d..7649040 100644
--- a/drivers/staging/lustre/lustre/include/lprocfs_status.h
+++ b/drivers/staging/lustre/lustre/include/lprocfs_status.h
@@ -136,7 +136,7 @@ enum {
 	LPROCFS_TYPE_CYCLE	= 0x0800,
 };
 
-#define LC_MIN_INIT ((~(__u64)0) >> 1)
+#define LC_MIN_INIT ((~(u64)0) >> 1)
 
 struct lprocfs_counter_header {
 	unsigned int		lc_config;
@@ -145,17 +145,17 @@ struct lprocfs_counter_header {
 };
 
 struct lprocfs_counter {
-	__s64	lc_count;
-	__s64	lc_min;
-	__s64	lc_max;
-	__s64	lc_sumsquare;
+	s64	lc_count;
+	s64	lc_min;
+	s64	lc_max;
+	s64	lc_sumsquare;
 	/*
 	 * Every counter has lc_array_sum[0], while lc_array_sum[1] is only
 	 * for irq context counter, i.e. stats with
 	 * LPROCFS_STATS_FLAG_IRQ_SAFE flag, its counter need
 	 * lc_array_sum[1]
 	 */
-	__s64	lc_array_sum[1];
+	s64	lc_array_sum[1];
 };
 
 #define lc_sum		lc_array_sum[0]
@@ -163,7 +163,7 @@ struct lprocfs_counter {
 
 struct lprocfs_percpu {
 #ifndef __GNUC__
-	__s64			pad;
+	s64			pad;
 #endif
 	struct lprocfs_counter lp_cntr[0];
 };
@@ -210,7 +210,7 @@ struct lprocfs_stats {
 #define OPC_RANGE(seg) (seg ## _LAST_OPC - seg ## _FIRST_OPC)
 
 /* Pack all opcodes down into a single monotonically increasing index */
-static inline int opcode_offset(__u32 opc)
+static inline int opcode_offset(u32 opc)
 {
 	if (opc < OST_LAST_OPC) {
 		 /* OST opcode */
@@ -394,7 +394,7 @@ void lprocfs_stats_unlock(struct lprocfs_stats *stats,
 
 	/* irq safe stats need lc_array_sum[1] */
 	if ((stats->ls_flags & LPROCFS_STATS_FLAG_IRQ_SAFE) != 0)
-		percpusize += stats->ls_num * sizeof(__s64);
+		percpusize += stats->ls_num * sizeof(s64);
 
 	if ((stats->ls_flags & LPROCFS_STATS_FLAG_NOPERCPU) == 0)
 		percpusize = L1_CACHE_ALIGN(percpusize);
@@ -411,7 +411,7 @@ void lprocfs_stats_unlock(struct lprocfs_stats *stats,
 	cntr = &stats->ls_percpu[cpuid]->lp_cntr[index];
 
 	if ((stats->ls_flags & LPROCFS_STATS_FLAG_IRQ_SAFE) != 0)
-		cntr = (void *)cntr + index * sizeof(__s64);
+		cntr = (void *)cntr + index * sizeof(s64);
 
 	return cntr;
 }
@@ -431,11 +431,11 @@ void lprocfs_stats_unlock(struct lprocfs_stats *stats,
 #define lprocfs_counter_decr(stats, idx) \
 	lprocfs_counter_sub(stats, idx, 1)
 
-__s64 lprocfs_read_helper(struct lprocfs_counter *lc,
+s64 lprocfs_read_helper(struct lprocfs_counter *lc,
 			  struct lprocfs_counter_header *header,
 			  enum lprocfs_stats_flags flags,
 			  enum lprocfs_fields_flags field);
-__u64 lprocfs_stats_collector(struct lprocfs_stats *stats, int idx,
+u64 lprocfs_stats_collector(struct lprocfs_stats *stats, int idx,
 			      enum lprocfs_fields_flags field);
 
 extern struct lprocfs_stats *
@@ -485,10 +485,10 @@ int lprocfs_wr_pinger_recov(struct file *file, const char __user *buffer,
 int lprocfs_write_helper(const char __user *buffer, unsigned long count,
 			 int *val);
 int lprocfs_write_u64_helper(const char __user *buffer,
-			     unsigned long count, __u64 *val);
+			     unsigned long count, u64 *val);
 int lprocfs_write_frac_u64_helper(const char __user *buffer,
 				  unsigned long count,
-				  __u64 *val, int mult);
+				  u64 *val, int mult);
 char *lprocfs_find_named_value(const char *buffer, const char *name,
 			       size_t *count);
 void lprocfs_oh_tally(struct obd_histogram *oh, unsigned int value);
diff --git a/drivers/staging/lustre/lustre/include/lu_object.h b/drivers/staging/lustre/lustre/include/lu_object.h
index 47f8021..3e663a9 100644
--- a/drivers/staging/lustre/lustre/include/lu_object.h
+++ b/drivers/staging/lustre/lustre/include/lu_object.h
@@ -309,7 +309,7 @@ struct lu_device_type {
 	/**
 	 * Tag bits. Taken from enum lu_device_tag. Never modified once set.
 	 */
-	__u32				   ldt_tags;
+	u32				   ldt_tags;
 	/**
 	 * Name of this class. Unique system-wide. Never modified once set.
 	 */
@@ -325,7 +325,7 @@ struct lu_device_type {
 	/**
 	 * \todo XXX: temporary: context tags used by obd_*() calls.
 	 */
-	__u32				   ldt_ctx_tags;
+	u32				   ldt_ctx_tags;
 	/**
 	 * Number of existing device type instances.
 	 */
@@ -392,7 +392,7 @@ static inline int lu_device_is_md(const struct lu_device *d)
  */
 struct lu_attr {
 	/** size in bytes */
-	__u64	  la_size;
+	u64	  la_size;
 	/** modification time in seconds since Epoch */
 	s64	  la_mtime;
 	/** access time in seconds since Epoch */
@@ -400,29 +400,29 @@ struct lu_attr {
 	/** change time in seconds since Epoch */
 	s64	  la_ctime;
 	/** 512-byte blocks allocated to object */
-	__u64	  la_blocks;
+	u64	  la_blocks;
 	/** permission bits and file type */
-	__u32	  la_mode;
+	u32	  la_mode;
 	/** owner id */
-	__u32	  la_uid;
+	u32	  la_uid;
 	/** group id */
-	__u32	  la_gid;
+	u32	  la_gid;
 	/** object flags */
-	__u32	  la_flags;
+	u32	  la_flags;
 	/** number of persistent references to this object */
-	__u32	  la_nlink;
+	u32	  la_nlink;
 	/** blk bits of the object*/
-	__u32	  la_blkbits;
+	u32	  la_blkbits;
 	/** blk size of the object*/
-	__u32	  la_blksize;
+	u32	  la_blksize;
 	/** real device */
-	__u32	  la_rdev;
+	u32	  la_rdev;
 	/**
 	 * valid bits
 	 *
 	 * \see enum la_valid
 	 */
-	__u64	  la_valid;
+	u64	  la_valid;
 };
 
 /** Bit-mask of valid attributes */
@@ -522,7 +522,7 @@ struct lu_object_header {
 	 * Common object attributes, cached for efficiency. From enum
 	 * lu_object_header_attr.
 	 */
-	__u32		  loh_attr;
+	u32		  loh_attr;
 	/**
 	 * Linkage into per-site hash table. Protected by lu_site::ls_guard.
 	 */
@@ -812,7 +812,7 @@ static inline int lu_object_assert_not_exists(const struct lu_object *o)
 /**
  * Attr of this object.
  */
-static inline __u32 lu_object_attr(const struct lu_object *o)
+static inline u32 lu_object_attr(const struct lu_object *o)
 {
 	LASSERT(lu_object_exists(o) != 0);
 	return o->lo_header->loh_attr;
@@ -849,13 +849,13 @@ static inline void lu_object_ref_del_at(struct lu_object *o,
 /** input params, should be filled out by mdt */
 struct lu_rdpg {
 	/** hash */
-	__u64		   rp_hash;
+	u64		   rp_hash;
 	/** count in bytes */
 	unsigned int	    rp_count;
 	/** number of pages */
 	unsigned int	    rp_npages;
 	/** requested attr */
-	__u32		   rp_attrs;
+	u32		   rp_attrs;
 	/** pointers to pages */
 	struct page	   **rp_pages;
 };
@@ -912,7 +912,7 @@ struct lu_context {
 	 * of tags has non-empty intersection with one for key. Tags are taken
 	 * from enum lu_context_tag.
 	 */
-	__u32		  lc_tags;
+	u32		  lc_tags;
 	enum lu_context_state  lc_state;
 	/**
 	 * Pointer to the home service thread. NULL for other execution
@@ -1049,7 +1049,7 @@ struct lu_context_key {
 	/**
 	 * Set of tags for which values of this key are to be instantiated.
 	 */
-	__u32 lct_tags;
+	u32 lct_tags;
 	/**
 	 * Value constructor. This is called when new value is created for a
 	 * context. Returns pointer to new value of error pointer.
@@ -1194,7 +1194,7 @@ void *lu_context_key_get(const struct lu_context *ctx,
 	LU_TYPE_START(mod, __VA_ARGS__);	\
 	LU_TYPE_STOP(mod, __VA_ARGS__)
 
-int lu_context_init(struct lu_context *ctx, __u32 tags);
+int lu_context_init(struct lu_context *ctx, u32 tags);
 void lu_context_fini(struct lu_context *ctx);
 void lu_context_enter(struct lu_context *ctx);
 void lu_context_exit(struct lu_context *ctx);
@@ -1224,7 +1224,7 @@ struct lu_env {
 	struct lu_context *le_ses;
 };
 
-int lu_env_init(struct lu_env *env, __u32 tags);
+int lu_env_init(struct lu_env *env, u32 tags);
 void lu_env_fini(struct lu_env *env);
 int lu_env_refill(struct lu_env *env);
 
@@ -1293,8 +1293,8 @@ struct lu_kmem_descr {
 int  lu_kmem_init(struct lu_kmem_descr *caches);
 void lu_kmem_fini(struct lu_kmem_descr *caches);
 
-extern __u32 lu_context_tags_default;
-extern __u32 lu_session_tags_default;
+extern u32 lu_context_tags_default;
+extern u32 lu_session_tags_default;
 
 /** @} lu */
 #endif /* __LUSTRE_LU_OBJECT_H */
diff --git a/drivers/staging/lustre/lustre/include/lustre_debug.h b/drivers/staging/lustre/lustre/include/lustre_debug.h
index 721a81f..b9414fc 100644
--- a/drivers/staging/lustre/lustre/include/lustre_debug.h
+++ b/drivers/staging/lustre/lustre/include/lustre_debug.h
@@ -44,8 +44,8 @@
 
 /* lib/debug.c */
 int dump_req(struct ptlrpc_request *req);
-int block_debug_setup(void *addr, int len, __u64 off, __u64 id);
-int block_debug_check(char *who, void *addr, int len, __u64 off, __u64 id);
+int block_debug_setup(void *addr, int len, u64 off, u64 id);
+int block_debug_check(char *who, void *addr, int len, u64 off, u64 id);
 
 /** @} debug */
 
diff --git a/drivers/staging/lustre/lustre/include/lustre_disk.h b/drivers/staging/lustre/lustre/include/lustre_disk.h
index 7b6421d..091a09f 100644
--- a/drivers/staging/lustre/lustre/include/lustre_disk.h
+++ b/drivers/staging/lustre/lustre/include/lustre_disk.h
@@ -70,8 +70,8 @@
 
 /* gleaned from the mount command - no persistent info here */
 struct lustre_mount_data {
-	__u32	lmd_magic;
-	__u32	lmd_flags;	/* lustre mount flags */
+	u32	lmd_magic;
+	u32	lmd_flags;	/* lustre mount flags */
 	int	lmd_mgs_failnodes; /* mgs failover node count */
 	int	lmd_exclude_count;
 	int	lmd_recovery_time_soft;
@@ -84,7 +84,7 @@ struct lustre_mount_data {
 				 * _device_ mount options)
 				 */
 	char	*lmd_params;	/* lustre params */
-	__u32	*lmd_exclude;	/* array of OSTs to ignore */
+	u32	*lmd_exclude;	/* array of OSTs to ignore */
 	char	*lmd_mgs;	/* MGS nid */
 	char	*lmd_osd_type;	/* OSD type */
 	char    *lmd_nidnet;	/* network to restrict this client to */
diff --git a/drivers/staging/lustre/lustre/include/lustre_dlm.h b/drivers/staging/lustre/lustre/include/lustre_dlm.h
index e2bbcaa..7c12087 100644
--- a/drivers/staging/lustre/lustre/include/lustre_dlm.h
+++ b/drivers/staging/lustre/lustre/include/lustre_dlm.h
@@ -243,9 +243,9 @@ struct ldlm_pool {
 	/** Cancel rate per T. */
 	atomic_t		pl_cancel_rate;
 	/** Server lock volume (SLV). Protected by pl_lock. */
-	__u64			pl_server_lock_volume;
+	u64			pl_server_lock_volume;
 	/** Current biggest client lock volume. Protected by pl_lock. */
-	__u64			pl_client_lock_volume;
+	u64			pl_client_lock_volume;
 	/** Lock volume factor. SLV on client is calculated as following:
 	 *  server_slv * lock_volume_factor.
 	 */
@@ -377,10 +377,10 @@ struct ldlm_namespace {
 	 * Namespace connect flags supported by server (may be changed via
 	 * sysfs, LRU resize may be disabled/enabled).
 	 */
-	__u64			ns_connect_flags;
+	u64			ns_connect_flags;
 
 	/** Client side original connect flags supported by server. */
-	__u64			ns_orig_connect_flags;
+	u64			ns_orig_connect_flags;
 
 	/* namespace debugfs dir entry */
 	struct dentry		*ns_debugfs_entry;
@@ -494,7 +494,7 @@ typedef int (*ldlm_blocking_callback)(struct ldlm_lock *lock,
 				      struct ldlm_lock_desc *new, void *data,
 				      int flag);
 /** Type for completion callback function of a lock. */
-typedef int (*ldlm_completion_callback)(struct ldlm_lock *lock, __u64 flags,
+typedef int (*ldlm_completion_callback)(struct ldlm_lock *lock, u64 flags,
 					void *data);
 /** Type for glimpse callback function of a lock. */
 typedef int (*ldlm_glimpse_callback)(struct ldlm_lock *lock, void *data);
@@ -503,7 +503,7 @@ typedef int (*ldlm_completion_callback)(struct ldlm_lock *lock, __u64 flags,
 struct ldlm_glimpse_work {
 	struct ldlm_lock	*gl_lock; /* lock to glimpse */
 	struct list_head		 gl_list; /* linkage to other gl work structs */
-	__u32			 gl_flags;/* see LDLM_GL_WORK_* below */
+	u32			 gl_flags;/* see LDLM_GL_WORK_* below */
 	union ldlm_gl_desc	*gl_desc; /* glimpse descriptor to be packed in
 					   * glimpse callback request
 					   */
@@ -538,12 +538,12 @@ enum ldlm_cancel_flags {
 };
 
 struct ldlm_flock {
-	__u64 start;
-	__u64 end;
-	__u64 owner;
-	__u64 blocking_owner;
+	u64 start;
+	u64 end;
+	u64 owner;
+	u64 blocking_owner;
 	struct obd_export *blocking_export;
-	__u32 pid;
+	u32 pid;
 };
 
 union ldlm_policy_data {
@@ -566,7 +566,7 @@ enum lvb_type {
 /**
  * LDLM_GID_ANY is used to match any group id in ldlm_lock_match().
  */
-#define LDLM_GID_ANY	((__u64)-1)
+#define LDLM_GID_ANY	((u64)-1)
 
 /**
  * LDLM lock structure
@@ -621,7 +621,7 @@ struct ldlm_lock {
 	 * Interval-tree node for ldlm_extent.
 	 */
 	struct rb_node		l_rb;
-	__u64			__subtree_last;
+	u64			__subtree_last;
 
 	/**
 	 * Requested mode.
@@ -681,14 +681,14 @@ struct ldlm_lock {
 	 * Lock state flags. Protected by lr_lock.
 	 * \see lustre_dlm_flags.h where the bits are defined.
 	 */
-	__u64			l_flags;
+	u64			l_flags;
 
 	/**
 	 * Lock r/w usage counters.
 	 * Protected by lr_lock.
 	 */
-	__u32			l_readers;
-	__u32			l_writers;
+	u32			l_readers;
+	u32			l_writers;
 	/**
 	 * If the lock is granted, a process sleeps on this waitq to learn when
 	 * it's no longer in use.  If the lock is not granted, a process sleeps
@@ -720,7 +720,7 @@ struct ldlm_lock {
 	/**
 	 * Temporary storage for a LVB received during an enqueue operation.
 	 */
-	__u32			l_lvb_len;
+	u32			l_lvb_len;
 	void			*l_lvb_data;
 
 	/** Private storage for lock user. Opaque to LDLM. */
@@ -735,7 +735,7 @@ struct ldlm_lock {
 	 * Used by Commit on Share (COS) code. Currently only used for
 	 * inodebits locks on MDS.
 	 */
-	__u64			l_client_cookie;
+	u64			l_client_cookie;
 
 	/**
 	 * List item for locks waiting for cancellation from clients.
@@ -756,7 +756,7 @@ struct ldlm_lock {
 	unsigned long		l_callback_timeout;
 
 	/** Local PID of process which created this lock. */
-	__u32			l_pid;
+	u32			l_pid;
 
 	/**
 	 * Number of times blocking AST was sent for this lock.
@@ -1007,7 +1007,7 @@ void _ldlm_lock_debug(struct ldlm_lock *lock,
 	}								    \
 } while (0)
 
-typedef int (*ldlm_processing_policy)(struct ldlm_lock *lock, __u64 *flags,
+typedef int (*ldlm_processing_policy)(struct ldlm_lock *lock, u64 *flags,
 				      int first_enq, enum ldlm_error *err,
 				      struct list_head *work_list);
 
@@ -1034,10 +1034,10 @@ int ldlm_resource_iterate(struct ldlm_namespace *, const struct ldlm_res_id *,
 int ldlm_replay_locks(struct obd_import *imp);
 
 /* ldlm_flock.c */
-int ldlm_flock_completion_ast(struct ldlm_lock *lock, __u64 flags, void *data);
+int ldlm_flock_completion_ast(struct ldlm_lock *lock, u64 flags, void *data);
 
 /* ldlm_extent.c */
-__u64 ldlm_extent_shift_kms(struct ldlm_lock *lock, __u64 old_kms);
+u64 ldlm_extent_shift_kms(struct ldlm_lock *lock, u64 old_kms);
 
 struct ldlm_callback_suite {
 	ldlm_completion_callback lcs_completion;
@@ -1053,7 +1053,7 @@ struct ldlm_callback_suite {
 /* ldlm_lock.c */
 void ldlm_lock2handle(const struct ldlm_lock *lock,
 		      struct lustre_handle *lockh);
-struct ldlm_lock *__ldlm_handle2lock(const struct lustre_handle *, __u64 flags);
+struct ldlm_lock *__ldlm_handle2lock(const struct lustre_handle *, u64 flags);
 void ldlm_cancel_callback(struct ldlm_lock *);
 int ldlm_lock_remove_from_lru(struct ldlm_lock *);
 int ldlm_lock_set_data(const struct lustre_handle *lockh, void *data);
@@ -1070,7 +1070,7 @@ static inline struct ldlm_lock *ldlm_handle2lock(const struct lustre_handle *h)
 	lu_ref_del(&lock->l_reference, "handle", current)
 
 static inline struct ldlm_lock *
-ldlm_handle2lock_long(const struct lustre_handle *h, __u64 flags)
+ldlm_handle2lock_long(const struct lustre_handle *h, u64 flags)
 {
 	struct ldlm_lock *lock;
 
@@ -1154,13 +1154,13 @@ void ldlm_lock_decref_and_cancel(const struct lustre_handle *lockh,
 void ldlm_lock_fail_match_locked(struct ldlm_lock *lock);
 void ldlm_lock_allow_match(struct ldlm_lock *lock);
 void ldlm_lock_allow_match_locked(struct ldlm_lock *lock);
-enum ldlm_mode ldlm_lock_match(struct ldlm_namespace *ns, __u64 flags,
+enum ldlm_mode ldlm_lock_match(struct ldlm_namespace *ns, u64 flags,
 			       const struct ldlm_res_id *,
 			       enum ldlm_type type, union ldlm_policy_data *,
 			       enum ldlm_mode mode, struct lustre_handle *,
 			       int unref);
 enum ldlm_mode ldlm_revalidate_lock_handle(const struct lustre_handle *lockh,
-					   __u64 *bits);
+					   u64 *bits);
 void ldlm_lock_cancel(struct ldlm_lock *lock);
 void ldlm_lock_dump_handle(int level, const struct lustre_handle *);
 void ldlm_unlink_lock_skiplist(struct ldlm_lock *req);
@@ -1170,7 +1170,7 @@ struct ldlm_namespace *
 ldlm_namespace_new(struct obd_device *obd, char *name,
 		   enum ldlm_side client, enum ldlm_appetite apt,
 		   enum ldlm_ns_type ns_type);
-int ldlm_namespace_cleanup(struct ldlm_namespace *ns, __u64 flags);
+int ldlm_namespace_cleanup(struct ldlm_namespace *ns, u64 flags);
 void ldlm_namespace_free_prior(struct ldlm_namespace *ns,
 			       struct obd_import *imp,
 			       int force);
@@ -1213,7 +1213,7 @@ int ldlm_lock_change_resource(struct ldlm_namespace *, struct ldlm_lock *,
  * processing.
  * @{
  */
-int ldlm_completion_ast(struct ldlm_lock *lock, __u64 flags, void *data);
+int ldlm_completion_ast(struct ldlm_lock *lock, u64 flags, void *data);
 /** @} ldlm_local_ast */
 
 /** \defgroup ldlm_cli_api API to operate on locks from actual LDLM users.
@@ -1224,8 +1224,8 @@ int ldlm_lock_change_resource(struct ldlm_namespace *, struct ldlm_lock *,
 int ldlm_cli_enqueue(struct obd_export *exp, struct ptlrpc_request **reqp,
 		     struct ldlm_enqueue_info *einfo,
 		     const struct ldlm_res_id *res_id,
-		     union ldlm_policy_data const *policy, __u64 *flags,
-		     void *lvb, __u32 lvb_len, enum lvb_type lvb_type,
+		     union ldlm_policy_data const *policy, u64 *flags,
+		     void *lvb, u32 lvb_len, enum lvb_type lvb_type,
 		     struct lustre_handle *lockh, int async);
 int ldlm_prep_enqueue_req(struct obd_export *exp,
 			  struct ptlrpc_request *req,
@@ -1237,9 +1237,9 @@ int ldlm_prep_elc_req(struct obd_export *exp,
 		      struct list_head *cancels, int count);
 
 int ldlm_cli_enqueue_fini(struct obd_export *exp, struct ptlrpc_request *req,
-			  enum ldlm_type type, __u8 with_policy,
+			  enum ldlm_type type, u8 with_policy,
 			  enum ldlm_mode mode,
-			  __u64 *flags, void *lvb, __u32 lvb_len,
+			  u64 *flags, void *lvb, u32 lvb_len,
 			  const struct lustre_handle *lockh, int rc);
 int ldlm_cli_update_pool(struct ptlrpc_request *req);
 int ldlm_cli_cancel(const struct lustre_handle *lockh,
@@ -1255,7 +1255,7 @@ int ldlm_cli_cancel_unused_resource(struct ldlm_namespace *ns,
 int ldlm_cancel_resource_local(struct ldlm_resource *res,
 			       struct list_head *cancels,
 			       union ldlm_policy_data *policy,
-			       enum ldlm_mode mode, __u64 lock_flags,
+			       enum ldlm_mode mode, u64 lock_flags,
 			       enum ldlm_cancel_flags cancel_flags,
 			       void *opaque);
 int ldlm_cli_cancel_list_local(struct list_head *cancels, int count,
diff --git a/drivers/staging/lustre/lustre/include/lustre_export.h b/drivers/staging/lustre/lustre/include/lustre_export.h
index 79ad5aa..1c70259 100644
--- a/drivers/staging/lustre/lustre/include/lustre_export.h
+++ b/drivers/staging/lustre/lustre/include/lustre_export.h
@@ -101,12 +101,12 @@ struct obd_export {
 	/** Active connection */
 	struct ptlrpc_connection *exp_connection;
 	/** Connection count value from last successful reconnect rpc */
-	__u32		     exp_conn_cnt;
+	u32		     exp_conn_cnt;
 	struct list_head		exp_outstanding_replies;
 	struct list_head		exp_uncommitted_replies;
 	spinlock_t		  exp_uncommitted_replies_lock;
 	/** Last committed transno for this export */
-	__u64		     exp_last_committed;
+	u64		     exp_last_committed;
 	/** On replay all requests waiting for replay are linked here */
 	struct list_head		exp_req_replay_queue;
 	/**
@@ -139,12 +139,12 @@ struct obd_export {
 	spinlock_t		  exp_bl_list_lock;
 };
 
-static inline __u64 *exp_connect_flags_ptr(struct obd_export *exp)
+static inline u64 *exp_connect_flags_ptr(struct obd_export *exp)
 {
 	return &exp->exp_connect_data.ocd_connect_flags;
 }
 
-static inline __u64 exp_connect_flags(struct obd_export *exp)
+static inline u64 exp_connect_flags(struct obd_export *exp)
 {
 	return *exp_connect_flags_ptr(exp);
 }
@@ -219,7 +219,7 @@ static inline bool imp_connect_lvb_type(struct obd_import *imp)
 		return false;
 }
 
-static inline __u64 exp_connect_ibits(struct obd_export *exp)
+static inline u64 exp_connect_ibits(struct obd_export *exp)
 {
 	struct obd_connect_data *ocd;
 
@@ -239,9 +239,9 @@ static inline bool imp_connect_disp_stripe(struct obd_import *imp)
 
 #define KKUC_CT_DATA_MAGIC	0x092013cea
 struct kkuc_ct_data {
-	__u32		kcd_magic;
+	u32		kcd_magic;
 	struct obd_uuid	kcd_uuid;
-	__u32		kcd_archive;
+	u32		kcd_archive;
 };
 
 /** @} export */
diff --git a/drivers/staging/lustre/lustre/include/lustre_fid.h b/drivers/staging/lustre/lustre/include/lustre_fid.h
index 094ad28..f0afa8d 100644
--- a/drivers/staging/lustre/lustre/include/lustre_fid.h
+++ b/drivers/staging/lustre/lustre/include/lustre_fid.h
@@ -235,14 +235,14 @@ enum local_oid {
 	SLAVE_LLOG_CATALOGS_OID	= 4124UL,
 };
 
-static inline void lu_local_obj_fid(struct lu_fid *fid, __u32 oid)
+static inline void lu_local_obj_fid(struct lu_fid *fid, u32 oid)
 {
 	fid->f_seq = FID_SEQ_LOCAL_FILE;
 	fid->f_oid = oid;
 	fid->f_ver = 0;
 }
 
-static inline void lu_local_name_obj_fid(struct lu_fid *fid, __u32 oid)
+static inline void lu_local_name_obj_fid(struct lu_fid *fid, u32 oid)
 {
 	fid->f_seq = FID_SEQ_LOCAL_NAME;
 	fid->f_oid = oid;
@@ -290,13 +290,13 @@ static inline int fid_is_quota(const struct lu_fid *fid)
 	       fid_seq(fid) == FID_SEQ_QUOTA_GLB;
 }
 
-static inline int fid_seq_in_fldb(__u64 seq)
+static inline int fid_seq_in_fldb(u64 seq)
 {
 	return fid_seq_is_igif(seq) || fid_seq_is_norm(seq) ||
 	       fid_seq_is_root(seq) || fid_seq_is_dot(seq);
 }
 
-static inline void lu_last_id_fid(struct lu_fid *fid, __u64 seq, __u32 ost_idx)
+static inline void lu_last_id_fid(struct lu_fid *fid, u64 seq, u32 ost_idx)
 {
 	if (fid_seq_is_mdt0(seq)) {
 		fid->f_seq = fid_idif_seq(0, ost_idx);
@@ -352,7 +352,7 @@ struct lu_client_seq {
 	 * Sequence width, that is how many objects may be allocated in one
 	 * sequence. Default value for it is LUSTRE_SEQ_MAX_WIDTH.
 	 */
-	__u64		   lcs_width;
+	u64		   lcs_width;
 
 	/* wait queue for fid allocation and update indicator */
 	wait_queue_head_t	     lcs_waitq;
@@ -409,8 +409,8 @@ static inline bool fid_res_name_eq(const struct lu_fid *fid,
 fid_extract_from_res_name(struct lu_fid *fid, const struct ldlm_res_id *res)
 {
 	fid->f_seq = res->name[LUSTRE_RES_ID_SEQ_OFF];
-	fid->f_oid = (__u32)(res->name[LUSTRE_RES_ID_VER_OID_OFF]);
-	fid->f_ver = (__u32)(res->name[LUSTRE_RES_ID_VER_OID_OFF] >> 32);
+	fid->f_oid = (u32)(res->name[LUSTRE_RES_ID_VER_OID_OFF]);
+	fid->f_ver = (u32)(res->name[LUSTRE_RES_ID_VER_OID_OFF] >> 32);
 	LASSERT(fid_res_name_eq(fid, res));
 }
 
@@ -435,9 +435,9 @@ static inline void fid_extract_from_quota_res(struct lu_fid *glb_fid,
 {
 	fid_extract_from_res_name(glb_fid, res);
 	qid->qid_fid.f_seq = res->name[LUSTRE_RES_ID_QUOTA_SEQ_OFF];
-	qid->qid_fid.f_oid = (__u32)res->name[LUSTRE_RES_ID_QUOTA_VER_OID_OFF];
+	qid->qid_fid.f_oid = (u32)res->name[LUSTRE_RES_ID_QUOTA_VER_OID_OFF];
 	qid->qid_fid.f_ver =
-		(__u32)(res->name[LUSTRE_RES_ID_QUOTA_VER_OID_OFF] >> 32);
+		(u32)(res->name[LUSTRE_RES_ID_QUOTA_VER_OID_OFF] >> 32);
 }
 
 static inline void
@@ -500,7 +500,7 @@ static inline int ostid_res_name_eq(const struct ost_id *oi,
  * Note: we need check oi_seq to decide where to set oi_id,
  * so oi_seq should always be set ahead of oi_id.
  */
-static inline int ostid_set_id(struct ost_id *oi, __u64 oid)
+static inline int ostid_set_id(struct ost_id *oi, u64 oid)
 {
 	if (fid_seq_is_mdt0(oi->oi.oi_seq)) {
 		if (oid >= IDIF_MAX_OID)
@@ -569,10 +569,10 @@ static inline void ost_fid_build_resid(const struct lu_fid *fid,
  * the time between re-used inode numbers is very long - 2^40 SEQ numbers,
  * or about 2^40 client mounts, if clients create less than 2^24 files/mount.
  */
-static inline __u64 fid_flatten(const struct lu_fid *fid)
+static inline u64 fid_flatten(const struct lu_fid *fid)
 {
-	__u64 ino;
-	__u64 seq;
+	u64 ino;
+	u64 seq;
 
 	if (fid_is_igif(fid)) {
 		ino = lu_igif_ino(fid);
@@ -586,7 +586,7 @@ static inline __u64 fid_flatten(const struct lu_fid *fid)
 	return ino ? ino : fid_oid(fid);
 }
 
-static inline __u32 fid_hash(const struct lu_fid *f, int bits)
+static inline u32 fid_hash(const struct lu_fid *f, int bits)
 {
 	/* all objects with same id and different versions will belong to same
 	 * collisions list.
@@ -597,10 +597,10 @@ static inline __u32 fid_hash(const struct lu_fid *f, int bits)
 /**
  * map fid to 32 bit value for ino on 32bit systems.
  */
-static inline __u32 fid_flatten32(const struct lu_fid *fid)
+static inline u32 fid_flatten32(const struct lu_fid *fid)
 {
-	__u32 ino;
-	__u64 seq;
+	u32 ino;
+	u64 seq;
 
 	if (fid_is_igif(fid)) {
 		ino = lu_igif_ino(fid);
diff --git a/drivers/staging/lustre/lustre/include/lustre_fld.h b/drivers/staging/lustre/lustre/include/lustre_fld.h
index f42122a..4bcabf7 100644
--- a/drivers/staging/lustre/lustre/include/lustre_fld.h
+++ b/drivers/staging/lustre/lustre/include/lustre_fld.h
@@ -62,7 +62,7 @@ struct lu_fld_target {
 	struct list_head	       ft_chain;
 	struct obd_export       *ft_exp;
 	struct lu_server_fld    *ft_srv;
-	__u64		    ft_idx;
+	u64		    ft_idx;
 };
 
 struct lu_server_fld {
@@ -115,7 +115,7 @@ int fld_client_init(struct lu_client_fld *fld,
 void fld_client_flush(struct lu_client_fld *fld);
 
 int fld_client_lookup(struct lu_client_fld *fld, u64 seq, u32 *mds,
-		      __u32 flags, const struct lu_env *env);
+		      u32 flags, const struct lu_env *env);
 
 int fld_client_create(struct lu_client_fld *fld,
 		      struct lu_seq_range *range,
@@ -128,7 +128,7 @@ int fld_client_add_target(struct lu_client_fld *fld,
 			  struct lu_fld_target *tar);
 
 int fld_client_del_target(struct lu_client_fld *fld,
-			  __u64 idx);
+			  u64 idx);
 
 void fld_client_debugfs_fini(struct lu_client_fld *fld);
 
diff --git a/drivers/staging/lustre/lustre/include/lustre_ha.h b/drivers/staging/lustre/lustre/include/lustre_ha.h
index cbd6898..af92a56 100644
--- a/drivers/staging/lustre/lustre/include/lustre_ha.h
+++ b/drivers/staging/lustre/lustre/include/lustre_ha.h
@@ -53,7 +53,7 @@
 void ptlrpc_activate_import(struct obd_import *imp);
 void ptlrpc_deactivate_import(struct obd_import *imp);
 void ptlrpc_invalidate_import(struct obd_import *imp);
-void ptlrpc_fail_import(struct obd_import *imp, __u32 conn_cnt);
+void ptlrpc_fail_import(struct obd_import *imp, u32 conn_cnt);
 void ptlrpc_pinger_force(struct obd_import *imp);
 
 /** @} ha */
diff --git a/drivers/staging/lustre/lustre/include/lustre_handles.h b/drivers/staging/lustre/lustre/include/lustre_handles.h
index 3556ce8..84f70f3 100644
--- a/drivers/staging/lustre/lustre/include/lustre_handles.h
+++ b/drivers/staging/lustre/lustre/include/lustre_handles.h
@@ -64,7 +64,7 @@ struct portals_handle_ops {
  */
 struct portals_handle {
 	struct list_head			h_link;
-	__u64				h_cookie;
+	u64				h_cookie;
 	const void			*h_owner;
 	struct portals_handle_ops	*h_ops;
 
@@ -81,7 +81,7 @@ struct portals_handle {
 void class_handle_hash(struct portals_handle *,
 		       struct portals_handle_ops *ops);
 void class_handle_unhash(struct portals_handle *);
-void *class_handle2object(__u64 cookie, const void *owner);
+void *class_handle2object(u64 cookie, const void *owner);
 void class_handle_free_cb(struct rcu_head *rcu);
 int class_handle_init(void);
 void class_handle_cleanup(void);
diff --git a/drivers/staging/lustre/lustre/include/lustre_import.h b/drivers/staging/lustre/lustre/include/lustre_import.h
index 8a8a125..db075be 100644
--- a/drivers/staging/lustre/lustre/include/lustre_import.h
+++ b/drivers/staging/lustre/lustre/include/lustre_import.h
@@ -69,10 +69,10 @@ struct adaptive_timeout {
 
 struct ptlrpc_at_array {
 	struct list_head       *paa_reqs_array; /** array to hold requests */
-	__u32	     paa_size;       /** the size of array */
-	__u32	     paa_count;      /** the total count of reqs */
+	u32	     paa_size;       /** the size of array */
+	u32	     paa_count;      /** the total count of reqs */
 	time64_t     paa_deadline;   /** the earliest deadline of reqs */
-	__u32	    *paa_reqs_count; /** the count of reqs in each entry */
+	u32	    *paa_reqs_count; /** the count of reqs in each entry */
 };
 
 #define IMP_AT_MAX_PORTALS 8
@@ -137,7 +137,7 @@ struct obd_import_conn {
 	/**
 	 * Time (64 bit jiffies) of last connection attempt on this connection
 	 */
-	__u64		     oic_last_attempt;
+	u64		     oic_last_attempt;
 };
 
 /* state history */
@@ -190,7 +190,7 @@ struct obd_import {
 	/** List of not replied requests */
 	struct list_head	imp_unreplied_list;
 	/** Known maximal replied XID */
-	__u64			imp_known_replied_xid;
+	u64			imp_known_replied_xid;
 
 	/** obd device for this import */
 	struct obd_device	*imp_obd;
@@ -227,23 +227,23 @@ struct obd_import {
 	/** Current import generation. Incremented on every reconnect */
 	int		       imp_generation;
 	/** Incremented every time we send reconnection request */
-	__u32		     imp_conn_cnt;
+	u32		     imp_conn_cnt;
        /**
 	* \see ptlrpc_free_committed remembers imp_generation value here
 	* after a check to save on unnecessary replay list iterations
 	*/
 	int		       imp_last_generation_checked;
 	/** Last transno we replayed */
-	__u64		     imp_last_replay_transno;
+	u64		     imp_last_replay_transno;
 	/** Last transno committed on remote side */
-	__u64		     imp_peer_committed_transno;
+	u64		     imp_peer_committed_transno;
 	/**
 	 * \see ptlrpc_free_committed remembers last_transno since its last
 	 * check here and if last_transno did not change since last run of
 	 * ptlrpc_free_committed and import generation is the same, we can
 	 * skip looking for requests to remove from replay list as optimisation
 	 */
-	__u64		     imp_last_transno_checked;
+	u64		     imp_last_transno_checked;
 	/**
 	 * Remote export handle. This is how remote side knows what export
 	 * we are talking to. Filled from response to connect request
@@ -252,7 +252,7 @@ struct obd_import {
 	/** When to perform next ping. time in jiffies. */
 	unsigned long		imp_next_ping;
 	/** When we last successfully connected. time in 64bit jiffies */
-	__u64		     imp_last_success_conn;
+	u64		     imp_last_success_conn;
 
 	/** List of all possible connection for import. */
 	struct list_head		imp_conn_list;
@@ -304,14 +304,14 @@ struct obd_import {
 				  imp_connect_tried:1,
 				 /* connected but not FULL yet */
 				 imp_connected:1;
-	__u32		     imp_connect_op;
+	u32		     imp_connect_op;
 	struct obd_connect_data   imp_connect_data;
-	__u64		     imp_connect_flags_orig;
+	u64		     imp_connect_flags_orig;
 	u64			imp_connect_flags2_orig;
 	int		       imp_connect_error;
 
-	__u32		     imp_msg_magic;
-	__u32		     imp_msghdr_flags;       /* adjusted based on server capability */
+	u32		     imp_msg_magic;
+	u32		     imp_msghdr_flags;       /* adjusted based on server capability */
 
 	struct imp_at	     imp_at;		 /* adaptive timeout data */
 	time64_t	     imp_last_reply_time;    /* for health check */
diff --git a/drivers/staging/lustre/lustre/include/lustre_intent.h b/drivers/staging/lustre/lustre/include/lustre_intent.h
index 51e5c0e..3f26d7a 100644
--- a/drivers/staging/lustre/lustre/include/lustre_intent.h
+++ b/drivers/staging/lustre/lustre/include/lustre_intent.h
@@ -41,14 +41,14 @@
 struct lookup_intent {
 	int		it_op;
 	int		it_create_mode;
-	__u64		it_flags;
+	u64		it_flags;
 	int		it_disposition;
 	int		it_status;
-	__u64		it_lock_handle;
-	__u64		it_lock_bits;
+	u64		it_lock_handle;
+	u64		it_lock_bits;
 	int		it_lock_mode;
 	int		it_remote_lock_mode;
-	__u64	   it_remote_lock_handle;
+	u64	   it_remote_lock_handle;
 	struct ptlrpc_request *it_request;
 	unsigned int    it_lock_set:1;
 };
diff --git a/drivers/staging/lustre/lustre/include/lustre_lmv.h b/drivers/staging/lustre/lustre/include/lustre_lmv.h
index 080ec1f..c4f05d2 100644
--- a/drivers/staging/lustre/lustre/include/lustre_lmv.h
+++ b/drivers/staging/lustre/lustre/include/lustre_lmv.h
@@ -42,13 +42,13 @@ struct lmv_oinfo {
 };
 
 struct lmv_stripe_md {
-	__u32	lsm_md_magic;
-	__u32	lsm_md_stripe_count;
-	__u32	lsm_md_master_mdt_index;
-	__u32	lsm_md_hash_type;
-	__u32	lsm_md_layout_version;
-	__u32	lsm_md_default_count;
-	__u32	lsm_md_default_index;
+	u32	lsm_md_magic;
+	u32	lsm_md_stripe_count;
+	u32	lsm_md_master_mdt_index;
+	u32	lsm_md_hash_type;
+	u32	lsm_md_layout_version;
+	u32	lsm_md_default_count;
+	u32	lsm_md_default_index;
 	char	lsm_md_pool_name[LOV_MAXPOOLNAME + 1];
 	struct lmv_oinfo lsm_md_oinfo[0];
 };
@@ -56,7 +56,7 @@ struct lmv_stripe_md {
 static inline bool
 lsm_md_eq(const struct lmv_stripe_md *lsm1, const struct lmv_stripe_md *lsm2)
 {
-	__u32 idx;
+	u32 idx;
 
 	if (lsm1->lsm_md_magic != lsm2->lsm_md_magic ||
 	    lsm1->lsm_md_stripe_count != lsm2->lsm_md_stripe_count ||
@@ -82,7 +82,7 @@ struct lmv_stripe_md {
 static inline void lmv1_le_to_cpu(struct lmv_mds_md_v1 *lmv_dst,
 				  const struct lmv_mds_md_v1 *lmv_src)
 {
-	__u32 i;
+	u32 i;
 
 	lmv_dst->lmv_magic = le32_to_cpu(lmv_src->lmv_magic);
 	lmv_dst->lmv_stripe_count = le32_to_cpu(lmv_src->lmv_stripe_count);
@@ -126,18 +126,18 @@ static inline void lmv_le_to_cpu(union lmv_mds_md *lmv_dst,
 static inline unsigned int
 lmv_hash_fnv1a(unsigned int count, const char *name, int namelen)
 {
-	__u64 hash;
+	u64 hash;
 
 	hash = lustre_hash_fnv_1a_64(name, namelen);
 
 	return do_div(hash, count);
 }
 
-static inline int lmv_name_to_stripe_index(__u32 lmv_hash_type,
+static inline int lmv_name_to_stripe_index(u32 lmv_hash_type,
 					   unsigned int stripe_count,
 					   const char *name, int namelen)
 {
-	__u32 hash_type = lmv_hash_type & LMV_HASH_TYPE_MASK;
+	u32 hash_type = lmv_hash_type & LMV_HASH_TYPE_MASK;
 	int idx;
 
 	LASSERT(namelen > 0);
@@ -165,7 +165,7 @@ static inline int lmv_name_to_stripe_index(__u32 lmv_hash_type,
 	return idx;
 }
 
-static inline bool lmv_is_known_hash_type(__u32 type)
+static inline bool lmv_is_known_hash_type(u32 type)
 {
 	return (type & LMV_HASH_TYPE_MASK) == LMV_HASH_TYPE_FNV_1A_64 ||
 	       (type & LMV_HASH_TYPE_MASK) == LMV_HASH_TYPE_ALL_CHARS;
diff --git a/drivers/staging/lustre/lustre/include/lustre_log.h b/drivers/staging/lustre/lustre/include/lustre_log.h
index 07f4e60..4ba4501 100644
--- a/drivers/staging/lustre/lustre/include/lustre_log.h
+++ b/drivers/staging/lustre/lustre/include/lustre_log.h
@@ -143,7 +143,7 @@ int llog_setup(const struct lu_env *env, struct obd_device *obd,
 
 struct llog_operations {
 	int (*lop_next_block)(const struct lu_env *env, struct llog_handle *h,
-			      int *curr_idx, int next_idx, __u64 *offset,
+			      int *curr_idx, int next_idx, u64 *offset,
 			      void *buf, int len);
 	int (*lop_prev_block)(const struct lu_env *env, struct llog_handle *h,
 			      int prev_idx, void *buf, int len);
@@ -218,7 +218,7 @@ struct llog_handle {
 	size_t			 lgh_hdr_size;
 	int			 lgh_last_idx;
 	int			 lgh_cur_idx; /* used during llog_process */
-	__u64			 lgh_cur_offset; /* used during llog_process */
+	u64			 lgh_cur_offset; /* used during llog_process */
 	struct llog_ctxt	*lgh_ctxt;
 	union {
 		struct plain_handle_data	 phd;
@@ -250,7 +250,7 @@ struct llog_ctxt {
 	 * llog chunk size, and llog record size can not be bigger than
 	 * loc_chunk_size
 	 */
-	__u32			loc_chunk_size;
+	u32			loc_chunk_size;
 };
 
 #define LLOG_PROC_BREAK 0x0001
@@ -348,7 +348,7 @@ static inline int llog_ctxt_null(struct obd_device *obd, int index)
 
 static inline int llog_next_block(const struct lu_env *env,
 				  struct llog_handle *loghandle, int *cur_idx,
-				  int next_idx, __u64 *cur_offset, void *buf,
+				  int next_idx, u64 *cur_offset, void *buf,
 				  int len)
 {
 	struct llog_operations *lop;
diff --git a/drivers/staging/lustre/lustre/include/lustre_mdc.h b/drivers/staging/lustre/lustre/include/lustre_mdc.h
index 6ac7fc4..c1fb324 100644
--- a/drivers/staging/lustre/lustre/include/lustre_mdc.h
+++ b/drivers/staging/lustre/lustre/include/lustre_mdc.h
@@ -204,7 +204,7 @@ static inline void mdc_update_max_ea_from_body(struct obd_export *exp,
 		if (cli->cl_max_mds_easize < body->mbo_max_mdsize)
 			cli->cl_max_mds_easize = body->mbo_max_mdsize;
 
-		def_easize = min_t(__u32, body->mbo_max_mdsize,
+		def_easize = min_t(u32, body->mbo_max_mdsize,
 				   OBD_MAX_DEFAULT_EA_SIZE);
 		cli->cl_default_mds_easize = def_easize;
 	}
diff --git a/drivers/staging/lustre/lustre/include/lustre_net.h b/drivers/staging/lustre/lustre/include/lustre_net.h
index 8e34766..050a7ec 100644
--- a/drivers/staging/lustre/lustre/include/lustre_net.h
+++ b/drivers/staging/lustre/lustre/include/lustre_net.h
@@ -95,7 +95,7 @@
  * use the negotiated per-client ocd_brw_size to determine the bulk
  * RPC count.
  */
-#define PTLRPC_BULK_OPS_MASK	(~((__u64)PTLRPC_BULK_OPS_COUNT - 1))
+#define PTLRPC_BULK_OPS_MASK	(~((u64)PTLRPC_BULK_OPS_COUNT - 1))
 
 /**
  * Define maxima for bulk I/O.
@@ -304,9 +304,9 @@ struct ptlrpc_connection {
 /** Client definition for PortalRPC */
 struct ptlrpc_client {
 	/** What lnet portal does this client send messages to by default */
-	__u32		   cli_request_portal;
+	u32		   cli_request_portal;
 	/** What portal do we expect replies on */
-	__u32		   cli_reply_portal;
+	u32		   cli_reply_portal;
 	/** Name of the client */
 	char		   *cli_name;
 };
@@ -327,7 +327,7 @@ struct ptlrpc_client {
 	 * least big enough for that.
 	 */
 	void      *pointer_arg[11];
-	__u64      space[7];
+	u64      space[7];
 };
 
 struct ptlrpc_request_set;
@@ -455,11 +455,11 @@ struct ptlrpc_reply_state {
 	/** Size of the state */
 	int		    rs_size;
 	/** opcode */
-	__u32		  rs_opc;
+	u32		  rs_opc;
 	/** Transaction number */
-	__u64		  rs_transno;
+	u64		  rs_transno;
 	/** xid */
-	__u64		  rs_xid;
+	u64		  rs_xid;
 	struct obd_export     *rs_export;
 	struct ptlrpc_service_part *rs_svcpt;
 	/** Lnet metadata handle for the reply */
@@ -667,7 +667,7 @@ struct ptlrpc_srv_req {
 	/** server-side history, used for debuging purposes. */
 	struct list_head		sr_hist_list;
 	/** history sequence # */
-	__u64				sr_hist_seq;
+	u64				sr_hist_seq;
 	/** the index of service's srv_at_array into which request is linked */
 	time64_t			sr_at_index;
 	/** authed uid */
@@ -809,9 +809,9 @@ struct ptlrpc_request {
 	/** Reply message - server response */
 	struct lustre_msg *rq_repmsg;
 	/** Transaction number */
-	__u64 rq_transno;
+	u64 rq_transno;
 	/** xid */
-	__u64 rq_xid;
+	u64 rq_xid;
 	/** bulk match bits */
 	u64				rq_mbits;
 	/**
@@ -871,8 +871,8 @@ struct ptlrpc_request {
 	/** @} */
 
 	/** Fields that help to see if request and reply were swabbed or not */
-	__u32 rq_req_swab_mask;
-	__u32 rq_rep_swab_mask;
+	u32 rq_req_swab_mask;
+	u32 rq_rep_swab_mask;
 
 	/** how many early replies (for stats) */
 	int rq_early_count;
@@ -1214,7 +1214,7 @@ struct ptlrpc_bulk_desc {
 	/** {put,get}{source,sink}{kvec,kiov} */
 	enum ptlrpc_bulk_op_type bd_type;
 	/** LNet portal for this bulk */
-	__u32 bd_portal;
+	u32 bd_portal;
 	/** Server side - export this bulk created for */
 	struct obd_export *bd_export;
 	/** Client side - import this bulk was sent on */
@@ -1282,7 +1282,7 @@ struct ptlrpc_thread {
 	 * thread-private data (preallocated memory)
 	 */
 	void *t_data;
-	__u32 t_flags;
+	u32 t_flags;
 	/**
 	 * service thread index, from ptlrpc_start_threads
 	 */
@@ -1329,23 +1329,23 @@ static inline int thread_is_running(struct ptlrpc_thread *thread)
 	return !!(thread->t_flags & SVC_RUNNING);
 }
 
-static inline void thread_clear_flags(struct ptlrpc_thread *thread, __u32 flags)
+static inline void thread_clear_flags(struct ptlrpc_thread *thread, u32 flags)
 {
 	thread->t_flags &= ~flags;
 }
 
-static inline void thread_set_flags(struct ptlrpc_thread *thread, __u32 flags)
+static inline void thread_set_flags(struct ptlrpc_thread *thread, u32 flags)
 {
 	thread->t_flags = flags;
 }
 
-static inline void thread_add_flags(struct ptlrpc_thread *thread, __u32 flags)
+static inline void thread_add_flags(struct ptlrpc_thread *thread, u32 flags)
 {
 	thread->t_flags |= flags;
 }
 
 static inline int thread_test_and_clear_flags(struct ptlrpc_thread *thread,
-					      __u32 flags)
+					      u32 flags)
 {
 	if (thread->t_flags & flags) {
 		thread->t_flags &= ~flags;
@@ -1459,14 +1459,14 @@ struct ptlrpc_service {
 	/** # buffers to allocate in 1 group */
 	int			     srv_nbuf_per_group;
 	/** Local portal on which to receive requests */
-	__u32			   srv_req_portal;
+	u32			   srv_req_portal;
 	/** Portal on the client to send replies to */
-	__u32			   srv_rep_portal;
+	u32			   srv_rep_portal;
 	/**
 	 * Tags for lu_context associated with this thread, see struct
 	 * lu_context.
 	 */
-	__u32			   srv_ctx_tags;
+	u32			   srv_ctx_tags;
 	/** soft watchdog timeout multiplier */
 	int			     srv_watchdog_factor;
 	/** under unregister_service */
@@ -1477,7 +1477,7 @@ struct ptlrpc_service {
 	/** number of CPTs this service bound on */
 	int				srv_ncpts;
 	/** CPTs array this service bound on */
-	__u32				*srv_cpts;
+	u32				*srv_cpts;
 	/** 2^srv_cptab_bits >= cfs_cpt_numbert(srv_cptable) */
 	int				srv_cpt_bits;
 	/** CPT table this service is running over */
@@ -1561,9 +1561,9 @@ struct ptlrpc_service_part {
 	/** # request buffers in history */
 	int				scp_hist_nrqbds;
 	/** sequence number for request */
-	__u64				scp_hist_seq;
+	u64				scp_hist_seq;
 	/** highest seq culled from history */
-	__u64				scp_hist_seq_culled;
+	u64				scp_hist_seq_culled;
 
 	/**
 	 * serialize the following fields, used for processing requests
@@ -1849,12 +1849,12 @@ struct ptlrpc_request *ptlrpc_request_alloc_pool(struct obd_import *imp,
 						 const struct req_format *);
 void ptlrpc_request_free(struct ptlrpc_request *request);
 int ptlrpc_request_pack(struct ptlrpc_request *request,
-			__u32 version, int opcode);
+			u32 version, int opcode);
 struct ptlrpc_request *ptlrpc_request_alloc_pack(struct obd_import *,
 						 const struct req_format *,
-						 __u32, int);
+						 u32, int);
 int ptlrpc_request_bufs_pack(struct ptlrpc_request *request,
-			     __u32 version, int opcode, char **bufs,
+			     u32 version, int opcode, char **bufs,
 			     struct ptlrpc_cli_ctx *ctx);
 void ptlrpc_req_finished(struct ptlrpc_request *request);
 struct ptlrpc_request *ptlrpc_request_addref(struct ptlrpc_request *req);
@@ -1896,9 +1896,9 @@ static inline void ptlrpc_release_bulk_page_pin(struct ptlrpc_bulk_desc *desc)
 
 void ptlrpc_retain_replayable_request(struct ptlrpc_request *req,
 				      struct obd_import *imp);
-__u64 ptlrpc_next_xid(void);
-__u64 ptlrpc_sample_next_xid(void);
-__u64 ptlrpc_req_xid(struct ptlrpc_request *request);
+u64 ptlrpc_next_xid(void);
+u64 ptlrpc_sample_next_xid(void);
+u64 ptlrpc_req_xid(struct ptlrpc_request *request);
 
 /* Set of routines to run a function in ptlrpcd context */
 void *ptlrpcd_alloc_work(struct obd_import *imp,
@@ -1945,7 +1945,7 @@ struct ptlrpc_service_thr_conf {
 	/* set NUMA node affinity for service threads */
 	unsigned int			tc_cpu_affinity;
 	/* Tags for lu_context associated with service thread */
-	__u32				tc_ctx_tags;
+	u32				tc_ctx_tags;
 };
 
 struct ptlrpc_service_cpt_conf {
@@ -2016,24 +2016,24 @@ void ptlrpc_buf_set_swabbed(struct ptlrpc_request *req, const int inout,
 int ptlrpc_unpack_rep_msg(struct ptlrpc_request *req, int len);
 int ptlrpc_unpack_req_msg(struct ptlrpc_request *req, int len);
 
-void lustre_init_msg_v2(struct lustre_msg_v2 *msg, int count, __u32 *lens,
+void lustre_init_msg_v2(struct lustre_msg_v2 *msg, int count, u32 *lens,
 			char **bufs);
-int lustre_pack_request(struct ptlrpc_request *, __u32 magic, int count,
-			__u32 *lens, char **bufs);
-int lustre_pack_reply(struct ptlrpc_request *, int count, __u32 *lens,
+int lustre_pack_request(struct ptlrpc_request *, u32 magic, int count,
+			u32 *lens, char **bufs);
+int lustre_pack_reply(struct ptlrpc_request *, int count, u32 *lens,
 		      char **bufs);
 int lustre_pack_reply_v2(struct ptlrpc_request *req, int count,
-			 __u32 *lens, char **bufs, int flags);
+			 u32 *lens, char **bufs, int flags);
 #define LPRFL_EARLY_REPLY 1
-int lustre_pack_reply_flags(struct ptlrpc_request *, int count, __u32 *lens,
+int lustre_pack_reply_flags(struct ptlrpc_request *, int count, u32 *lens,
 			    char **bufs, int flags);
 int lustre_shrink_msg(struct lustre_msg *msg, int segment,
 		      unsigned int newlen, int move_data);
 void lustre_free_reply_state(struct ptlrpc_reply_state *rs);
 int __lustre_unpack_msg(struct lustre_msg *m, int len);
-u32 lustre_msg_hdr_size(__u32 magic, u32 count);
-u32 lustre_msg_size(__u32 magic, int count, __u32 *lengths);
-u32 lustre_msg_size_v2(int count, __u32 *lengths);
+u32 lustre_msg_hdr_size(u32 magic, u32 count);
+u32 lustre_msg_size(u32 magic, int count, u32 *lengths);
+u32 lustre_msg_size_v2(int count, u32 *lengths);
 u32 lustre_packed_msg_size(struct lustre_msg *msg);
 u32 lustre_msg_early_size(void);
 void *lustre_msg_buf_v2(struct lustre_msg_v2 *m, u32 n, u32 min_size);
@@ -2041,48 +2041,48 @@ int lustre_shrink_msg(struct lustre_msg *msg, int segment,
 u32 lustre_msg_buflen(struct lustre_msg *m, u32 n);
 u32 lustre_msg_bufcount(struct lustre_msg *m);
 char *lustre_msg_string(struct lustre_msg *m, u32 n, u32 max_len);
-__u32 lustre_msghdr_get_flags(struct lustre_msg *msg);
-void lustre_msghdr_set_flags(struct lustre_msg *msg, __u32 flags);
-__u32 lustre_msg_get_flags(struct lustre_msg *msg);
+u32 lustre_msghdr_get_flags(struct lustre_msg *msg);
+void lustre_msghdr_set_flags(struct lustre_msg *msg, u32 flags);
+u32 lustre_msg_get_flags(struct lustre_msg *msg);
 void lustre_msg_add_flags(struct lustre_msg *msg, u32 flags);
 void lustre_msg_set_flags(struct lustre_msg *msg, u32 flags);
 void lustre_msg_clear_flags(struct lustre_msg *msg, u32 flags);
-__u32 lustre_msg_get_op_flags(struct lustre_msg *msg);
+u32 lustre_msg_get_op_flags(struct lustre_msg *msg);
 void lustre_msg_add_op_flags(struct lustre_msg *msg, u32 flags);
 struct lustre_handle *lustre_msg_get_handle(struct lustre_msg *msg);
-__u32 lustre_msg_get_type(struct lustre_msg *msg);
+u32 lustre_msg_get_type(struct lustre_msg *msg);
 void lustre_msg_add_version(struct lustre_msg *msg, u32 version);
-__u32 lustre_msg_get_opc(struct lustre_msg *msg);
-__u16 lustre_msg_get_tag(struct lustre_msg *msg);
-__u64 lustre_msg_get_last_committed(struct lustre_msg *msg);
-__u64 *lustre_msg_get_versions(struct lustre_msg *msg);
-__u64 lustre_msg_get_transno(struct lustre_msg *msg);
-__u64 lustre_msg_get_slv(struct lustre_msg *msg);
-__u32 lustre_msg_get_limit(struct lustre_msg *msg);
-void lustre_msg_set_slv(struct lustre_msg *msg, __u64 slv);
-void lustre_msg_set_limit(struct lustre_msg *msg, __u64 limit);
+u32 lustre_msg_get_opc(struct lustre_msg *msg);
+u16 lustre_msg_get_tag(struct lustre_msg *msg);
+u64 lustre_msg_get_last_committed(struct lustre_msg *msg);
+u64 *lustre_msg_get_versions(struct lustre_msg *msg);
+u64 lustre_msg_get_transno(struct lustre_msg *msg);
+u64 lustre_msg_get_slv(struct lustre_msg *msg);
+u32 lustre_msg_get_limit(struct lustre_msg *msg);
+void lustre_msg_set_slv(struct lustre_msg *msg, u64 slv);
+void lustre_msg_set_limit(struct lustre_msg *msg, u64 limit);
 int lustre_msg_get_status(struct lustre_msg *msg);
-__u32 lustre_msg_get_conn_cnt(struct lustre_msg *msg);
-__u32 lustre_msg_get_magic(struct lustre_msg *msg);
-__u32 lustre_msg_get_timeout(struct lustre_msg *msg);
-__u32 lustre_msg_get_service_time(struct lustre_msg *msg);
-__u32 lustre_msg_get_cksum(struct lustre_msg *msg);
-__u32 lustre_msg_calc_cksum(struct lustre_msg *msg);
+u32 lustre_msg_get_conn_cnt(struct lustre_msg *msg);
+u32 lustre_msg_get_magic(struct lustre_msg *msg);
+u32 lustre_msg_get_timeout(struct lustre_msg *msg);
+u32 lustre_msg_get_service_time(struct lustre_msg *msg);
+u32 lustre_msg_get_cksum(struct lustre_msg *msg);
+u32 lustre_msg_calc_cksum(struct lustre_msg *msg);
 void lustre_msg_set_handle(struct lustre_msg *msg,
 			   struct lustre_handle *handle);
-void lustre_msg_set_type(struct lustre_msg *msg, __u32 type);
-void lustre_msg_set_opc(struct lustre_msg *msg, __u32 opc);
+void lustre_msg_set_type(struct lustre_msg *msg, u32 type);
+void lustre_msg_set_opc(struct lustre_msg *msg, u32 opc);
 void lustre_msg_set_last_xid(struct lustre_msg *msg, u64 last_xid);
-void lustre_msg_set_tag(struct lustre_msg *msg, __u16 tag);
-void lustre_msg_set_versions(struct lustre_msg *msg, __u64 *versions);
-void lustre_msg_set_transno(struct lustre_msg *msg, __u64 transno);
-void lustre_msg_set_status(struct lustre_msg *msg, __u32 status);
-void lustre_msg_set_conn_cnt(struct lustre_msg *msg, __u32 conn_cnt);
+void lustre_msg_set_tag(struct lustre_msg *msg, u16 tag);
+void lustre_msg_set_versions(struct lustre_msg *msg, u64 *versions);
+void lustre_msg_set_transno(struct lustre_msg *msg, u64 transno);
+void lustre_msg_set_status(struct lustre_msg *msg, u32 status);
+void lustre_msg_set_conn_cnt(struct lustre_msg *msg, u32 conn_cnt);
 void ptlrpc_request_set_replen(struct ptlrpc_request *req);
-void lustre_msg_set_timeout(struct lustre_msg *msg, __u32 timeout);
-void lustre_msg_set_service_time(struct lustre_msg *msg, __u32 service_time);
+void lustre_msg_set_timeout(struct lustre_msg *msg, u32 timeout);
+void lustre_msg_set_service_time(struct lustre_msg *msg, u32 service_time);
 void lustre_msg_set_jobid(struct lustre_msg *msg, char *jobid);
-void lustre_msg_set_cksum(struct lustre_msg *msg, __u32 cksum);
+void lustre_msg_set_cksum(struct lustre_msg *msg, u32 cksum);
 void lustre_msg_set_mbits(struct lustre_msg *msg, u64 mbits);
 
 static inline void
@@ -2244,7 +2244,7 @@ static inline void ptlrpc_req_drop_rs(struct ptlrpc_request *req)
 	req->rq_repmsg = NULL;
 }
 
-static inline __u32 lustre_request_magic(struct ptlrpc_request *req)
+static inline u32 lustre_request_magic(struct ptlrpc_request *req)
 {
 	return lustre_msg_get_magic(req->rq_reqmsg);
 }
@@ -2355,7 +2355,7 @@ int ptlrpc_del_timeout_client(struct list_head *obd_list,
  * procfs output related functions
  * @{
  */
-const char *ll_opcode2str(__u32 opcode);
+const char *ll_opcode2str(u32 opcode);
 void ptlrpc_lprocfs_register_obd(struct obd_device *obd);
 void ptlrpc_lprocfs_unregister_obd(struct obd_device *obd);
 void ptlrpc_lprocfs_brw(struct ptlrpc_request *req, int bytes);
diff --git a/drivers/staging/lustre/lustre/include/lustre_nrs_fifo.h b/drivers/staging/lustre/lustre/include/lustre_nrs_fifo.h
index b70d97d..0db4345f 100644
--- a/drivers/staging/lustre/lustre/include/lustre_nrs_fifo.h
+++ b/drivers/staging/lustre/lustre/include/lustre_nrs_fifo.h
@@ -59,12 +59,12 @@ struct nrs_fifo_head {
 	/**
 	 * For debugging purposes.
 	 */
-	__u64				fh_sequence;
+	u64				fh_sequence;
 };
 
 struct nrs_fifo_req {
 	struct list_head	fr_list;
-	__u64			fr_sequence;
+	u64			fr_sequence;
 };
 
 /** @} fifo */
diff --git a/drivers/staging/lustre/lustre/include/lustre_req_layout.h b/drivers/staging/lustre/lustre/include/lustre_req_layout.h
index 3387ab2..2aba99f 100644
--- a/drivers/staging/lustre/lustre/include/lustre_req_layout.h
+++ b/drivers/staging/lustre/lustre/include/lustre_req_layout.h
@@ -66,7 +66,7 @@ struct req_capsule {
 	struct ptlrpc_request   *rc_req;
 	const struct req_format *rc_fmt;
 	enum req_location	rc_loc;
-	__u32		    rc_area[RCL_NR][REQ_MAX_FIELD_NR];
+	u32		    rc_area[RCL_NR][REQ_MAX_FIELD_NR];
 };
 
 void req_capsule_init(struct req_capsule *pill, struct ptlrpc_request *req,
@@ -105,7 +105,7 @@ u32 req_capsule_get_size(const struct req_capsule *pill,
 			 const struct req_msg_field *field,
 			 enum req_location loc);
 u32 req_capsule_msg_size(struct req_capsule *pill, enum req_location loc);
-u32 req_capsule_fmt_size(__u32 magic, const struct req_format *fmt,
+u32 req_capsule_fmt_size(u32 magic, const struct req_format *fmt,
 			 enum req_location loc);
 void req_capsule_extend(struct req_capsule *pill, const struct req_format *fmt);
 
diff --git a/drivers/staging/lustre/lustre/include/lustre_sec.h b/drivers/staging/lustre/lustre/include/lustre_sec.h
index 43ff594..c622c8d 100644
--- a/drivers/staging/lustre/lustre/include/lustre_sec.h
+++ b/drivers/staging/lustre/lustre/include/lustre_sec.h
@@ -139,37 +139,37 @@ enum sptlrpc_bulk_service {
 #define FLVR_BULK_SVC_OFFSET	    (16)
 
 #define MAKE_FLVR(policy, mech, svc, btype, bsvc)		       \
-	(((__u32)(policy) << FLVR_POLICY_OFFSET) |		      \
-	 ((__u32)(mech) << FLVR_MECH_OFFSET) |			  \
-	 ((__u32)(svc) << FLVR_SVC_OFFSET) |			    \
-	 ((__u32)(btype) << FLVR_BULK_TYPE_OFFSET) |		    \
-	 ((__u32)(bsvc) << FLVR_BULK_SVC_OFFSET))
+	(((u32)(policy) << FLVR_POLICY_OFFSET) |		      \
+	 ((u32)(mech) << FLVR_MECH_OFFSET) |			  \
+	 ((u32)(svc) << FLVR_SVC_OFFSET) |			    \
+	 ((u32)(btype) << FLVR_BULK_TYPE_OFFSET) |		    \
+	 ((u32)(bsvc) << FLVR_BULK_SVC_OFFSET))
 
 /*
  * extraction
  */
 #define SPTLRPC_FLVR_POLICY(flavor)				     \
-	((((__u32)(flavor)) >> FLVR_POLICY_OFFSET) & 0xF)
+	((((u32)(flavor)) >> FLVR_POLICY_OFFSET) & 0xF)
 #define SPTLRPC_FLVR_MECH(flavor)				       \
-	((((__u32)(flavor)) >> FLVR_MECH_OFFSET) & 0xF)
+	((((u32)(flavor)) >> FLVR_MECH_OFFSET) & 0xF)
 #define SPTLRPC_FLVR_SVC(flavor)					\
-	((((__u32)(flavor)) >> FLVR_SVC_OFFSET) & 0xF)
+	((((u32)(flavor)) >> FLVR_SVC_OFFSET) & 0xF)
 #define SPTLRPC_FLVR_BULK_TYPE(flavor)				  \
-	((((__u32)(flavor)) >> FLVR_BULK_TYPE_OFFSET) & 0xF)
+	((((u32)(flavor)) >> FLVR_BULK_TYPE_OFFSET) & 0xF)
 #define SPTLRPC_FLVR_BULK_SVC(flavor)				   \
-	((((__u32)(flavor)) >> FLVR_BULK_SVC_OFFSET) & 0xF)
+	((((u32)(flavor)) >> FLVR_BULK_SVC_OFFSET) & 0xF)
 
 #define SPTLRPC_FLVR_BASE(flavor)				       \
-	((((__u32)(flavor)) >> FLVR_POLICY_OFFSET) & 0xFFF)
+	((((u32)(flavor)) >> FLVR_POLICY_OFFSET) & 0xFFF)
 #define SPTLRPC_FLVR_BASE_SUB(flavor)				   \
-	((((__u32)(flavor)) >> FLVR_MECH_OFFSET) & 0xFF)
+	((((u32)(flavor)) >> FLVR_MECH_OFFSET) & 0xFF)
 
 /*
  * gss subflavors
  */
 #define MAKE_BASE_SUBFLVR(mech, svc)				    \
-	((__u32)(mech) |						\
-	 ((__u32)(svc) << (FLVR_SVC_OFFSET - FLVR_MECH_OFFSET)))
+	((u32)(mech) |						\
+	 ((u32)(svc) << (FLVR_SVC_OFFSET - FLVR_MECH_OFFSET)))
 
 #define SPTLRPC_SUBFLVR_KRB5N					   \
 	MAKE_BASE_SUBFLVR(SPTLRPC_MECH_GSS_KRB5, SPTLRPC_SVC_NULL)
@@ -222,17 +222,17 @@ enum sptlrpc_bulk_service {
 
 #define SPTLRPC_FLVR_DEFAULT	    SPTLRPC_FLVR_NULL
 
-#define SPTLRPC_FLVR_INVALID	    ((__u32)0xFFFFFFFF)
-#define SPTLRPC_FLVR_ANY		((__u32)0xFFF00000)
+#define SPTLRPC_FLVR_INVALID	    ((u32)0xFFFFFFFF)
+#define SPTLRPC_FLVR_ANY		((u32)0xFFF00000)
 
 /**
  * extract the useful part from wire flavor
  */
-#define WIRE_FLVR(wflvr)		(((__u32)(wflvr)) & 0x000FFFFF)
+#define WIRE_FLVR(wflvr)		(((u32)(wflvr)) & 0x000FFFFF)
 
 /** @} flavor */
 
-static inline void flvr_set_svc(__u32 *flvr, __u32 svc)
+static inline void flvr_set_svc(u32 *flvr, u32 svc)
 {
 	LASSERT(svc < SPTLRPC_SVC_MAX);
 	*flvr = MAKE_FLVR(SPTLRPC_FLVR_POLICY(*flvr),
@@ -242,7 +242,7 @@ static inline void flvr_set_svc(__u32 *flvr, __u32 svc)
 			  SPTLRPC_FLVR_BULK_SVC(*flvr));
 }
 
-static inline void flvr_set_bulk_svc(__u32 *flvr, __u32 svc)
+static inline void flvr_set_bulk_svc(u32 *flvr, u32 svc)
 {
 	LASSERT(svc < SPTLRPC_BULK_SVC_MAX);
 	*flvr = MAKE_FLVR(SPTLRPC_FLVR_POLICY(*flvr),
@@ -253,7 +253,7 @@ static inline void flvr_set_bulk_svc(__u32 *flvr, __u32 svc)
 }
 
 struct bulk_spec_hash {
-	__u8    hash_alg;
+	u8    hash_alg;
 };
 
 /**
@@ -264,11 +264,11 @@ struct sptlrpc_flavor {
 	/**
 	 * wire flavor, should be renamed to sf_wire.
 	 */
-	__u32   sf_rpc;
+	u32   sf_rpc;
 	/**
 	 * general flags of PTLRPC_SEC_FL_*
 	 */
-	__u32   sf_flags;
+	u32   sf_flags;
 	/**
 	 * rpc flavor specification
 	 */
@@ -303,10 +303,10 @@ enum lustre_sec_part {
  * two Lustre parts.
  */
 struct sptlrpc_rule {
-	__u32		   sr_netid;   /* LNET network ID */
-	__u8		    sr_from;    /* sec_part */
-	__u8		    sr_to;      /* sec_part */
-	__u16		   sr_padding;
+	u32		   sr_netid;   /* LNET network ID */
+	u8		    sr_from;    /* sec_part */
+	u8		    sr_to;      /* sec_part */
+	u16		   sr_padding;
 	struct sptlrpc_flavor   sr_flvr;
 };
 
@@ -757,7 +757,7 @@ struct ptlrpc_sec_sops {
 struct ptlrpc_sec_policy {
 	struct module		   *sp_owner;
 	char			   *sp_name;
-	__u16			   sp_policy; /* policy number */
+	u16			   sp_policy; /* policy number */
 	struct ptlrpc_sec_cops	 *sp_cops;   /* client ops */
 	struct ptlrpc_sec_sops	 *sp_sops;   /* server ops */
 };
@@ -819,13 +819,13 @@ struct ptlrpc_svc_ctx {
 #define LUSTRE_MAX_GROUPS	       (128)
 
 struct ptlrpc_user_desc {
-	__u32	   pud_uid;
-	__u32	   pud_gid;
-	__u32	   pud_fsuid;
-	__u32	   pud_fsgid;
-	__u32	   pud_cap;
-	__u32	   pud_ngroups;
-	__u32	   pud_groups[0];
+	u32	   pud_uid;
+	u32	   pud_gid;
+	u32	   pud_fsuid;
+	u32	   pud_fsgid;
+	u32	   pud_cap;
+	u32	   pud_ngroups;
+	u32	   pud_groups[0];
 };
 
 /*
@@ -843,20 +843,20 @@ enum sptlrpc_bulk_hash_alg {
 	BULK_HASH_ALG_MAX
 };
 
-const char *sptlrpc_get_hash_name(__u8 hash_alg);
-__u8 sptlrpc_get_hash_alg(const char *algname);
+const char *sptlrpc_get_hash_name(u8 hash_alg);
+u8 sptlrpc_get_hash_alg(const char *algname);
 
 enum {
 	BSD_FL_ERR      = 1,
 };
 
 struct ptlrpc_bulk_sec_desc {
-	__u8	    bsd_version;    /* 0 */
-	__u8	    bsd_type;       /* SPTLRPC_BULK_XXX */
-	__u8	    bsd_svc;	/* SPTLRPC_BULK_SVC_XXXX */
-	__u8	    bsd_flags;      /* flags */
-	__u32	   bsd_nob;	/* nob of bulk data */
-	__u8	    bsd_data[0];    /* policy-specific token */
+	u8	    bsd_version;    /* 0 */
+	u8	    bsd_type;       /* SPTLRPC_BULK_XXX */
+	u8	    bsd_svc;	/* SPTLRPC_BULK_SVC_XXXX */
+	u8	    bsd_flags;      /* flags */
+	u32	   bsd_nob;	/* nob of bulk data */
+	u8	    bsd_data[0];    /* policy-specific token */
 };
 
 /*
@@ -887,8 +887,8 @@ void _sptlrpc_enlarge_msg_inplace(struct lustre_msg *msg,
 int sptlrpc_register_policy(struct ptlrpc_sec_policy *policy);
 int sptlrpc_unregister_policy(struct ptlrpc_sec_policy *policy);
 
-__u32 sptlrpc_name2flavor_base(const char *name);
-const char *sptlrpc_flavor2name_base(__u32 flvr);
+u32 sptlrpc_name2flavor_base(const char *name);
+const char *sptlrpc_flavor2name_base(u32 flvr);
 char *sptlrpc_flavor2name_bulk(struct sptlrpc_flavor *sf,
 			       char *buf, int bufsize);
 char *sptlrpc_flavor2name(struct sptlrpc_flavor *sf, char *buf, int bufsize);
@@ -1047,7 +1047,7 @@ int sptlrpc_cli_unwrap_bulk_write(struct ptlrpc_request *req,
 				  struct ptlrpc_bulk_desc *desc);
 
 /* bulk helpers (internal use only by policies) */
-int sptlrpc_get_bulk_checksum(struct ptlrpc_bulk_desc *desc, __u8 alg,
+int sptlrpc_get_bulk_checksum(struct ptlrpc_bulk_desc *desc, u8 alg,
 			      void *buf, int buflen);
 
 int bulk_sec_desc_unpack(struct lustre_msg *msg, int offset, int swabbed);
@@ -1055,7 +1055,7 @@ int sptlrpc_get_bulk_checksum(struct ptlrpc_bulk_desc *desc, __u8 alg,
 /* user descriptor helpers */
 static inline int sptlrpc_user_desc_size(int ngroups)
 {
-	return sizeof(struct ptlrpc_user_desc) + ngroups * sizeof(__u32);
+	return sizeof(struct ptlrpc_user_desc) + ngroups * sizeof(u32);
 }
 
 int sptlrpc_current_user_desc_size(void);
diff --git a/drivers/staging/lustre/lustre/include/lustre_swab.h b/drivers/staging/lustre/lustre/include/lustre_swab.h
index 6939ac1..1758dd9 100644
--- a/drivers/staging/lustre/lustre/include/lustre_swab.h
+++ b/drivers/staging/lustre/lustre/include/lustre_swab.h
@@ -62,7 +62,7 @@
 void lustre_swab_ost_lvb(struct ost_lvb *lvb);
 void lustre_swab_obd_quotactl(struct obd_quotactl *q);
 void lustre_swab_lquota_lvb(struct lquota_lvb *lvb);
-void lustre_swab_generic_32s(__u32 *val);
+void lustre_swab_generic_32s(u32 *val);
 void lustre_swab_mdt_body(struct mdt_body *b);
 void lustre_swab_mdt_ioepoch(struct mdt_ioepoch *b);
 void lustre_swab_mdt_rec_setattr(struct mdt_rec_setattr *sa);
@@ -79,7 +79,7 @@
 void lustre_swab_mgs_config_body(struct mgs_config_body *body);
 void lustre_swab_mgs_config_res(struct mgs_config_res *body);
 void lustre_swab_ost_body(struct ost_body *b);
-void lustre_swab_ost_last_id(__u64 *id);
+void lustre_swab_ost_last_id(u64 *id);
 void lustre_swab_fiemap(struct fiemap *fiemap);
 void lustre_swab_lov_user_md_v1(struct lov_user_md_v1 *lum);
 void lustre_swab_lov_user_md_v3(struct lov_user_md_v3 *lum);
@@ -107,6 +107,6 @@ void lustre_swab_lov_user_md_objects(struct lov_user_ost_data *lod,
 void dump_rniobuf(struct niobuf_remote *rnb);
 void dump_ioo(struct obd_ioobj *nb);
 void dump_ost_body(struct ost_body *ob);
-void dump_rcs(__u32 *rc);
+void dump_rcs(u32 *rc);
 
 #endif
diff --git a/drivers/staging/lustre/lustre/include/obd.h b/drivers/staging/lustre/lustre/include/obd.h
index a5dc573..0bb3cf8 100644
--- a/drivers/staging/lustre/lustre/include/obd.h
+++ b/drivers/staging/lustre/lustre/include/obd.h
@@ -55,7 +55,7 @@
 struct osc_async_rc {
 	int     ar_rc;
 	int     ar_force_sync;
-	__u64   ar_min_xid;
+	u64   ar_min_xid;
 };
 
 struct lov_oinfo {		 /* per-stripe data structure */
@@ -64,12 +64,12 @@ struct lov_oinfo {		 /* per-stripe data structure */
 	int loi_ost_gen;	   /* generation of this loi_ost_idx */
 
 	unsigned long loi_kms_valid:1;
-	__u64 loi_kms;	     /* known minimum size */
+	u64 loi_kms;	     /* known minimum size */
 	struct ost_lvb loi_lvb;
 	struct osc_async_rc     loi_ar;
 };
 
-static inline void loi_kms_set(struct lov_oinfo *oinfo, __u64 kms)
+static inline void loi_kms_set(struct lov_oinfo *oinfo, u64 kms)
 {
 	oinfo->loi_kms = kms;
 	oinfo->loi_kms_valid = 1;
@@ -85,7 +85,7 @@ static inline void loi_kms_set(struct lov_oinfo *oinfo, __u64 kms)
 /* obd info for a particular level (lov, osc). */
 struct obd_info {
 	/* OBD_STATFS_* flags */
-	__u64		   oi_flags;
+	u64		   oi_flags;
 	/* lsm data specific for every OSC. */
 	struct lov_stripe_md   *oi_md;
 	/* statfs data specific for every OSC, if needed at all. */
@@ -243,13 +243,13 @@ struct client_obd {
 	struct list_head	       cl_loi_hp_ready_list;
 	struct list_head	       cl_loi_write_list;
 	struct list_head	       cl_loi_read_list;
-	__u32			 cl_r_in_flight;
-	__u32			 cl_w_in_flight;
+	u32			 cl_r_in_flight;
+	u32			 cl_w_in_flight;
 	/* just a sum of the loi/lop pending numbers to be exported by sysfs */
 	atomic_t	     cl_pending_w_pages;
 	atomic_t	     cl_pending_r_pages;
-	__u32			 cl_max_pages_per_rpc;
-	__u32			 cl_max_rpcs_in_flight;
+	u32			 cl_max_pages_per_rpc;
+	u32			 cl_max_rpcs_in_flight;
 	struct obd_histogram     cl_read_rpc_hist;
 	struct obd_histogram     cl_write_rpc_hist;
 	struct obd_histogram     cl_read_page_hist;
@@ -322,7 +322,7 @@ struct client_obd {
 	unsigned int		 cl_checksum:1,	/* 0 = disabled, 1 = enabled */
 				 cl_checksum_dump:1; /* same */
 	/* supported checksum types that are worked out at connect time */
-	__u32		    cl_supp_cksum_types;
+	u32		    cl_supp_cksum_types;
 	/* checksum algorithm to be used */
 	enum cksum_type	     cl_cksum_type;
 
@@ -347,7 +347,7 @@ struct client_obd {
 #define obd2cli_tgt(obd) ((char *)(obd)->u.cli.cl_target_uuid.uuid)
 
 struct obd_id_info {
-	__u32   idx;
+	u32   idx;
 	u64	*data;
 };
 
@@ -356,12 +356,12 @@ struct echo_client_obd {
 	spinlock_t		ec_lock;
 	struct list_head	   ec_objects;
 	struct list_head	   ec_locks;
-	__u64		ec_unique;
+	u64		ec_unique;
 };
 
 /* Generic subset of OSTs */
 struct ost_pool {
-	__u32	      *op_array;      /* array of index of lov_obd->lov_tgts */
+	u32	      *op_array;      /* array of index of lov_obd->lov_tgts */
 	unsigned int	op_count;      /* number of OSTs in the array */
 	unsigned int	op_size;       /* allocated size of lp_array */
 	struct rw_semaphore op_rw_sem;     /* to protect ost_pool use */
@@ -375,8 +375,8 @@ struct lov_tgt_desc {
 	struct obd_uuid     ltd_uuid;
 	struct obd_device  *ltd_obd;
 	struct obd_export  *ltd_exp;
-	__u32	       ltd_gen;
-	__u32	       ltd_index;   /* index in lov_obd->tgts */
+	u32	       ltd_gen;
+	u32	       ltd_index;   /* index in lov_obd->tgts */
 	unsigned long       ltd_active:1,/* is this target up for requests */
 			    ltd_activate:1,/* should  target be activated */
 			    ltd_reap:1;  /* should this target be deleted */
@@ -389,8 +389,8 @@ struct lov_obd {
 	struct mutex		lov_lock;
 	struct obd_connect_data lov_ocd;
 	atomic_t	    lov_refcount;
-	__u32		   lov_death_row;/* tgts scheduled to be deleted */
-	__u32		   lov_tgt_size;   /* size of tgts array */
+	u32		   lov_death_row;/* tgts scheduled to be deleted */
+	u32		   lov_tgt_size;   /* size of tgts array */
 	int		     lov_connects;
 	int		     lov_pool_count;
 	struct rhashtable	lov_pools_hash_body; /* used for key access */
@@ -433,10 +433,10 @@ struct lmv_obd {
 };
 
 struct niobuf_local {
-	__u64		lnb_file_offset;
-	__u32		lnb_page_offset;
-	__u32		lnb_len;
-	__u32		lnb_flags;
+	u64		lnb_file_offset;
+	u32		lnb_page_offset;
+	u32		lnb_len;
+	u32		lnb_flags;
 	int		lnb_rc;
 	struct page	*lnb_page;
 	void		*lnb_data;
@@ -576,7 +576,7 @@ struct obd_device {
 	spinlock_t		obd_dev_lock; /* protect OBD bitfield above */
 	spinlock_t		obd_osfs_lock;
 	struct obd_statfs	obd_osfs;       /* locked by obd_osfs_lock */
-	__u64			obd_osfs_age;
+	u64			obd_osfs_age;
 	u64			obd_last_committed;
 	struct mutex		obd_dev_mutex;
 	struct lvfs_run_ctxt	obd_lvfs_ctxt;
@@ -728,9 +728,9 @@ struct md_op_data {
 	size_t			op_namelen;
 	struct lmv_stripe_md   *op_mea1;
 	struct lmv_stripe_md   *op_mea2;
-	__u32		   op_suppgids[2];
-	__u32		   op_fsuid;
-	__u32		   op_fsgid;
+	u32		   op_suppgids[2];
+	u32		   op_fsuid;
+	u32		   op_fsgid;
 	kernel_cap_t	       op_cap;
 	void		   *op_data;
 	size_t			op_data_size;
@@ -739,16 +739,16 @@ struct md_op_data {
 	struct iattr	    op_attr;
 	enum op_xvalid		op_xvalid;	/* eXtra validity flags */
 	unsigned int	    op_attr_flags;
-	__u64		   op_valid;
+	u64		   op_valid;
 	loff_t		  op_attr_blocks;
 
-	__u32		   op_flags;
+	u32		   op_flags;
 
 	/* Various operation flags. */
 	enum mds_op_bias        op_bias;
 
 	/* Used by readdir */
-	__u64		   op_offset;
+	u64		   op_offset;
 
 	/* used to transfer info between the stacks of MD client
 	 * see enum op_cli_flags
@@ -756,7 +756,7 @@ struct md_op_data {
 	enum md_cli_flags	op_cli_flags;
 
 	/* File object data version for HSM release, on client */
-	__u64			op_data_version;
+	u64			op_data_version;
 	struct lustre_handle	op_lease_handle;
 
 	/* File security context, for creates. */
@@ -765,7 +765,7 @@ struct md_op_data {
 	u32			op_file_secctx_size;
 
 	/* default stripe offset */
-	__u32			op_default_stripe_offset;
+	u32			op_default_stripe_offset;
 
 	u32			op_projid;
 };
@@ -795,10 +795,10 @@ struct obd_ops {
 	int (*iocontrol)(unsigned int cmd, struct obd_export *exp, int len,
 			 void *karg, void __user *uarg);
 	int (*get_info)(const struct lu_env *env, struct obd_export *,
-			__u32 keylen, void *key, __u32 *vallen, void *val);
+			u32 keylen, void *key, u32 *vallen, void *val);
 	int (*set_info_async)(const struct lu_env *, struct obd_export *,
-			      __u32 keylen, void *key,
-			      __u32 vallen, void *val,
+			      u32 keylen, void *key,
+			      u32 vallen, void *val,
 			      struct ptlrpc_request_set *set);
 	int (*setup)(struct obd_device *dev, struct lustre_cfg *cfg);
 	int (*precleanup)(struct obd_device *dev);
@@ -838,9 +838,9 @@ struct obd_ops {
 	 * about this.
 	 */
 	int (*statfs)(const struct lu_env *, struct obd_export *exp,
-		      struct obd_statfs *osfs, __u64 max_age, __u32 flags);
+		      struct obd_statfs *osfs, u64 max_age, u32 flags);
 	int (*statfs_async)(struct obd_export *exp, struct obd_info *oinfo,
-			    __u64 max_age, struct ptlrpc_request_set *set);
+			    u64 max_age, struct ptlrpc_request_set *set);
 	int (*create)(const struct lu_env *env, struct obd_export *exp,
 		      struct obdo *oa);
 	int (*destroy)(const struct lu_env *env, struct obd_export *exp,
@@ -908,7 +908,7 @@ struct obd_client_handle {
 	struct lu_fid		 och_fid;
 	struct md_open_data	*och_mod;
 	struct lustre_handle	 och_lease_handle; /* open lock for lease */
-	__u32			 och_magic;
+	u32			 och_magic;
 	fmode_t			 och_flags;
 };
 
@@ -925,10 +925,10 @@ struct md_ops {
 		     struct md_open_data *, struct ptlrpc_request **);
 	int (*create)(struct obd_export *, struct md_op_data *,
 		      const void *, size_t, umode_t, uid_t, gid_t,
-		      kernel_cap_t, __u64, struct ptlrpc_request **);
+		      kernel_cap_t, u64, struct ptlrpc_request **);
 	int (*enqueue)(struct obd_export *, struct ldlm_enqueue_info *,
 		       const union ldlm_policy_data *, struct md_op_data *,
-		       struct lustre_handle *, __u64);
+		       struct lustre_handle *, u64);
 	int (*getattr)(struct obd_export *, struct md_op_data *,
 		       struct ptlrpc_request **);
 	int (*getattr_name)(struct obd_export *, struct md_op_data *,
@@ -936,7 +936,7 @@ struct md_ops {
 	int (*intent_lock)(struct obd_export *, struct md_op_data *,
 			   struct lookup_intent *,
 			   struct ptlrpc_request **,
-			   ldlm_blocking_callback, __u64);
+			   ldlm_blocking_callback, u64);
 	int (*link)(struct obd_export *, struct md_op_data *,
 		    struct ptlrpc_request **);
 	int (*rename)(struct obd_export *, struct md_op_data *,
@@ -947,7 +947,7 @@ struct md_ops {
 	int (*fsync)(struct obd_export *, const struct lu_fid *,
 		     struct ptlrpc_request **);
 	int (*read_page)(struct obd_export *, struct md_op_data *,
-			 struct md_callback *cb_op, __u64 hash_offset,
+			 struct md_callback *cb_op, u64 hash_offset,
 			 struct page **ppage);
 	int (*unlink)(struct obd_export *, struct md_op_data *,
 		      struct ptlrpc_request **);
@@ -977,9 +977,9 @@ struct md_ops {
 	int (*clear_open_replay_data)(struct obd_export *,
 				      struct obd_client_handle *);
 	int (*set_lock_data)(struct obd_export *, const struct lustre_handle *,
-			     void *, __u64 *);
+			     void *, u64 *);
 
-	enum ldlm_mode (*lock_match)(struct obd_export *, __u64,
+	enum ldlm_mode (*lock_match)(struct obd_export *, u64,
 				     const struct lu_fid *, enum ldlm_type,
 				     union ldlm_policy_data *, enum ldlm_mode,
 				     struct lustre_handle *);
@@ -997,7 +997,7 @@ struct md_ops {
 				    struct md_enqueue_info *);
 
 	int (*revalidate_lock)(struct obd_export *, struct lookup_intent *,
-			       struct lu_fid *, __u64 *bits);
+			       struct lu_fid *, u64 *bits);
 
 	int (*unpackmd)(struct obd_export *exp, struct lmv_stripe_md **plsm,
 			const union lmv_mds_md *lmv, size_t lmv_size);
diff --git a/drivers/staging/lustre/lustre/include/obd_class.h b/drivers/staging/lustre/lustre/include/obd_class.h
index cc00915..b64ba8b 100644
--- a/drivers/staging/lustre/lustre/include/obd_class.h
+++ b/drivers/staging/lustre/lustre/include/obd_class.h
@@ -92,8 +92,8 @@ int obd_connect_flags2str(char *page, int count, u64 flags, u64 flags2,
 
 int obd_get_request_slot(struct client_obd *cli);
 void obd_put_request_slot(struct client_obd *cli);
-__u32 obd_get_max_rpcs_in_flight(struct client_obd *cli);
-int obd_set_max_rpcs_in_flight(struct client_obd *cli, __u32 max);
+u32 obd_get_max_rpcs_in_flight(struct client_obd *cli);
+int obd_set_max_rpcs_in_flight(struct client_obd *cli, u32 max);
 int obd_set_max_mod_rpcs_in_flight(struct client_obd *cli, u16 max);
 int obd_mod_rpc_stats_seq_show(struct client_obd *cli, struct seq_file *seq);
 
@@ -356,8 +356,8 @@ static inline int class_devno_max(void)
 }
 
 static inline int obd_get_info(const struct lu_env *env,
-			       struct obd_export *exp, __u32 keylen,
-			       void *key, __u32 *vallen, void *val)
+			       struct obd_export *exp, u32 keylen,
+			       void *key, u32 *vallen, void *val)
 {
 	int rc;
 
@@ -873,7 +873,7 @@ static inline int obd_destroy_export(struct obd_export *exp)
  */
 static inline int obd_statfs_async(struct obd_export *exp,
 				   struct obd_info *oinfo,
-				   __u64 max_age,
+				   u64 max_age,
 				   struct ptlrpc_request_set *rqset)
 {
 	int rc = 0;
@@ -909,8 +909,8 @@ static inline int obd_statfs_async(struct obd_export *exp,
 }
 
 static inline int obd_statfs_rqset(struct obd_export *exp,
-				   struct obd_statfs *osfs, __u64 max_age,
-				   __u32 flags)
+				   struct obd_statfs *osfs, u64 max_age,
+				   u32 flags)
 {
 	struct ptlrpc_request_set *set = NULL;
 	struct obd_info oinfo = {
@@ -936,8 +936,8 @@ static inline int obd_statfs_rqset(struct obd_export *exp,
  * target.  Use a value of "jiffies + HZ" to guarantee freshness.
  */
 static inline int obd_statfs(const struct lu_env *env, struct obd_export *exp,
-			     struct obd_statfs *osfs, __u64 max_age,
-			     __u32 flags)
+			     struct obd_statfs *osfs, u64 max_age,
+			     u32 flags)
 {
 	struct obd_device *obd = exp->exp_obd;
 	int rc = 0;
@@ -1509,7 +1509,7 @@ static inline int md_clear_open_replay_data(struct obd_export *exp,
 
 static inline int md_set_lock_data(struct obd_export *exp,
 				   const struct lustre_handle *lockh,
-				   void *data, __u64 *bits)
+				   void *data, u64 *bits)
 {
 	int rc;
 
@@ -1537,7 +1537,7 @@ static inline int md_cancel_unused(struct obd_export *exp,
 						flags, opaque);
 }
 
-static inline enum ldlm_mode md_lock_match(struct obd_export *exp, __u64 flags,
+static inline enum ldlm_mode md_lock_match(struct obd_export *exp, u64 flags,
 					   const struct lu_fid *fid,
 					   enum ldlm_type type,
 					   union ldlm_policy_data *policy,
@@ -1583,7 +1583,7 @@ static inline int md_intent_getattr_async(struct obd_export *exp,
 
 static inline int md_revalidate_lock(struct obd_export *exp,
 				     struct lookup_intent *it,
-				     struct lu_fid *fid, __u64 *bits)
+				     struct lu_fid *fid, u64 *bits)
 {
 	int rc;
 
@@ -1669,9 +1669,9 @@ static inline void class_uuid_unparse(class_uuid_t uu, struct obd_uuid *out)
 
 /* lustre_peer.c    */
 int lustre_uuid_to_peer(const char *uuid, lnet_nid_t *peer_nid, int index);
-int class_add_uuid(const char *uuid, __u64 nid);
+int class_add_uuid(const char *uuid, u64 nid);
 int class_del_uuid(const char *uuid);
-int class_check_uuid(struct obd_uuid *uuid, __u64 nid);
+int class_check_uuid(struct obd_uuid *uuid, u64 nid);
 
 /* class_obd.c */
 extern char obd_jobid_node[];
-- 
1.8.3.1
