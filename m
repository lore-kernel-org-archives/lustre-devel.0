From: James Simmons <jsimmons@infradead.org>
Date: Thu, 31 Jan 2019 12:19:24 -0500
Subject: [lustre-devel] [PATCH 20/26] lustre: first batch to cleanup white
 spaces in internal headers
In-Reply-To: <1548955170-13456-1-git-send-email-jsimmons@infradead.org>
References: <1548955170-13456-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1548955170-13456-21-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

The internal headers are very messy and difficult to read. Remove
excess white space and properly align data structures so they are
easy on the eyes. This is the first batch since it covers many
lines of changes.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/cl_object.h  | 338 ++++++++++-----------
 .../staging/lustre/lustre/include/lprocfs_status.h |  77 ++---
 drivers/staging/lustre/lustre/include/lu_object.h  | 322 ++++++++++----------
 .../staging/lustre/lustre/include/lustre_disk.h    |  42 +--
 drivers/staging/lustre/lustre/include/lustre_dlm.h | 256 ++++++++--------
 .../lustre/lustre/include/lustre_dlm_flags.h       | 326 ++++++++++----------
 6 files changed, 682 insertions(+), 679 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/cl_object.h b/drivers/staging/lustre/lustre/include/cl_object.h
index 3109c04..b8ae41d 100644
--- a/drivers/staging/lustre/lustre/include/cl_object.h
+++ b/drivers/staging/lustre/lustre/include/cl_object.h
@@ -49,16 +49,16 @@
  *
  *   - cl_page
  *
- *   - cl_lock     represents an extent lock on an object.
+ *   - cl_lock	represents an extent lock on an object.
  *
- *   - cl_io       represents high-level i/o activity such as whole read/write
- *		 system call, or write-out of pages from under the lock being
- *		 canceled. cl_io has sub-ios that can be stopped and resumed
- *		 independently, thus achieving high degree of transfer
- *		 parallelism. Single cl_io can be advanced forward by
- *		 the multiple threads (although in the most usual case of
- *		 read/write system call it is associated with the single user
- *		 thread, that issued the system call).
+ *   - cl_io	represents high-level i/o activity such as whole read/write
+ *		system call, or write-out of pages from under the lock being
+ *		canceled. cl_io has sub-ios that can be stopped and resumed
+ *		independently, thus achieving high degree of transfer
+ *		parallelism. Single cl_io can be advanced forward by
+ *		the multiple threads (although in the most usual case of
+ *		read/write system call it is associated with the single user
+ *		thread, that issued the system call).
  *
  * Terminology
  *
@@ -135,39 +135,39 @@ struct cl_device {
  */
 struct cl_attr {
 	/** Object size, in bytes */
-	loff_t cat_size;
+	loff_t		cat_size;
 	/**
 	 * Known minimal size, in bytes.
 	 *
 	 * This is only valid when at least one DLM lock is held.
 	 */
-	loff_t cat_kms;
+	loff_t		cat_kms;
 	/** Modification time. Measured in seconds since epoch. */
-	time64_t cat_mtime;
+	time64_t	cat_mtime;
 	/** Access time. Measured in seconds since epoch. */
-	time64_t cat_atime;
+	time64_t	cat_atime;
 	/** Change time. Measured in seconds since epoch. */
-	time64_t cat_ctime;
+	time64_t	cat_ctime;
 	/**
 	 * Blocks allocated to this cl_object on the server file system.
 	 *
 	 * \todo XXX An interface for block size is needed.
 	 */
-	u64  cat_blocks;
+	u64		cat_blocks;
 	/**
 	 * User identifier for quota purposes.
 	 */
-	uid_t  cat_uid;
+	uid_t		cat_uid;
 	/**
 	 * Group identifier for quota purposes.
 	 */
-	gid_t  cat_gid;
+	gid_t		cat_gid;
 
 	/* nlink of the directory */
-	u64  cat_nlink;
+	u64		cat_nlink;
 
 	/* Project identifier for quota purpose. */
-	u32	cat_projid;
+	u32		cat_projid;
 };
 
 /**
@@ -223,11 +223,11 @@ enum cl_attr_valid {
  */
 struct cl_object {
 	/** super class */
-	struct lu_object		   co_lu;
+	struct lu_object			co_lu;
 	/** per-object-layer operations */
-	const struct cl_object_operations *co_ops;
+	const struct cl_object_operations	*co_ops;
 	/** offset of page slice in cl_page buffer */
-	int				   co_slice_off;
+	int					co_slice_off;
 };
 
 /**
@@ -237,30 +237,30 @@ struct cl_object {
  */
 struct cl_object_conf {
 	/** Super-class. */
-	struct lu_object_conf     coc_lu;
+	struct lu_object_conf	coc_lu;
 	union {
 		/**
 		 * Object layout. This is consumed by lov.
 		 */
-		struct lu_buf	  coc_layout;
+		struct lu_buf		coc_layout;
 		/**
 		 * Description of particular stripe location in the
 		 * cluster. This is consumed by osc.
 		 */
-		struct lov_oinfo *coc_oinfo;
+		struct lov_oinfo	*coc_oinfo;
 	} u;
 	/**
 	 * VFS inode. This is consumed by vvp.
 	 */
-	struct inode	     *coc_inode;
+	struct inode		*coc_inode;
 	/**
 	 * Layout lock handle.
 	 */
-	struct ldlm_lock	 *coc_lock;
+	struct ldlm_lock	*coc_lock;
 	/**
 	 * Operation to handle layout, OBJECT_CONF_XYZ.
 	 */
-	int			  coc_opc;
+	int			coc_opc;
 };
 
 enum {
@@ -283,13 +283,13 @@ enum {
 
 struct cl_layout {
 	/** the buffer to return the layout in lov_mds_md format. */
-	struct lu_buf	cl_buf;
+	struct lu_buf		cl_buf;
 	/** size of layout in lov_mds_md format. */
-	size_t		cl_size;
+	size_t			cl_size;
 	/** Layout generation. */
-	u32		cl_layout_gen;
+	u32			cl_layout_gen;
 	/** whether layout is a composite one */
-	bool		cl_is_composite;
+	bool			cl_is_composite;
 };
 
 /**
@@ -421,7 +421,7 @@ struct cl_object_header {
 	/** Standard lu_object_header. cl_object::co_lu::lo_header points
 	 * here.
 	 */
-	struct lu_object_header  coh_lu;
+	struct lu_object_header	 coh_lu;
 
 	/**
 	 * Parent object. It is assumed that an object has a well-defined
@@ -454,16 +454,16 @@ struct cl_object_header {
  * Helper macro: iterate over all layers of the object \a obj, assigning every
  * layer top-to-bottom to \a slice.
  */
-#define cl_object_for_each(slice, obj)				      \
-	list_for_each_entry((slice),				    \
-				&(obj)->co_lu.lo_header->loh_layers,	\
-				co_lu.lo_linkage)
+#define cl_object_for_each(slice, obj)					\
+	list_for_each_entry((slice),					\
+			    &(obj)->co_lu.lo_header->loh_layers,	\
+			    co_lu.lo_linkage)
 /**
  * Helper macro: iterate over all layers of the object \a obj, assigning every
  * layer bottom-to-top to \a slice.
  */
-#define cl_object_for_each_reverse(slice, obj)			       \
-	list_for_each_entry_reverse((slice),			     \
+#define cl_object_for_each_reverse(slice, obj)				\
+	list_for_each_entry_reverse((slice),				\
 					&(obj)->co_lu.lo_header->loh_layers, \
 					co_lu.lo_linkage)
 /** @} cl_object */
@@ -717,39 +717,39 @@ enum cl_page_type {
  */
 struct cl_page {
 	/** Reference counter. */
-	atomic_t	     cp_ref;
+	atomic_t			 cp_ref;
 	/** An object this page is a part of. Immutable after creation. */
-	struct cl_object	*cp_obj;
+	struct cl_object		*cp_obj;
 	/** vmpage */
-	struct page		*cp_vmpage;
+	struct page			*cp_vmpage;
 	/** Linkage of pages within group. Pages must be owned */
-	struct list_head	 cp_batch;
+	struct list_head		 cp_batch;
 	/** List of slices. Immutable after creation. */
-	struct list_head	 cp_layers;
+	struct list_head		 cp_layers;
 	/**
 	 * Page state. This field is const to avoid accidental update, it is
 	 * modified only internally within cl_page.c. Protected by a VM lock.
 	 */
-	const enum cl_page_state cp_state;
+	const enum cl_page_state	 cp_state;
 	/**
 	 * Page type. Only CPT_TRANSIENT is used so far. Immutable after
 	 * creation.
 	 */
-	enum cl_page_type	cp_type;
+	enum cl_page_type		 cp_type;
 
 	/**
 	 * Owning IO in cl_page_state::CPS_OWNED state. Sub-page can be owned
 	 * by sub-io. Protected by a VM lock.
 	 */
-	struct cl_io	    *cp_owner;
+	struct cl_io			*cp_owner;
 	/** List of references to this page, for debugging. */
-	struct lu_ref	    cp_reference;
+	struct lu_ref			 cp_reference;
 	/** Link to an object, for debugging. */
-	struct lu_ref_link       cp_obj_ref;
+	struct lu_ref_link		 cp_obj_ref;
 	/** Link to a queue, for debugging. */
-	struct lu_ref_link       cp_queue_ref;
+	struct lu_ref_link		 cp_queue_ref;
 	/** Assigned if doing a sync_io */
-	struct cl_sync_io       *cp_sync_io;
+	struct cl_sync_io		*cp_sync_io;
 };
 
 /**
@@ -758,7 +758,7 @@ struct cl_page {
  * \see vvp_page, lov_page, osc_page
  */
 struct cl_page_slice {
-	struct cl_page		  *cpl_page;
+	struct cl_page			*cpl_page;
 	pgoff_t				 cpl_index;
 	/**
 	 * Object slice corresponding to this page slice. Immutable after
@@ -767,7 +767,7 @@ struct cl_page_slice {
 	struct cl_object		*cpl_obj;
 	const struct cl_page_operations *cpl_ops;
 	/** Linkage into cl_page::cp_layers. Immutable after creation. */
-	struct list_head		       cpl_linkage;
+	struct list_head		 cpl_linkage;
 };
 
 /**
@@ -986,25 +986,25 @@ struct cl_page_operations {
 /**
  * Helper macro, dumping detailed information about \a page into a log.
  */
-#define CL_PAGE_DEBUG(mask, env, page, format, ...)		     \
-do {								    \
-	if (cfs_cdebug_show(mask, DEBUG_SUBSYSTEM)) {		   \
+#define CL_PAGE_DEBUG(mask, env, page, format, ...)			\
+do {									\
+	if (cfs_cdebug_show(mask, DEBUG_SUBSYSTEM)) {			\
 		LIBCFS_DEBUG_MSG_DATA_DECL(msgdata, mask, NULL);	\
 		cl_page_print(env, &msgdata, lu_cdebug_printer, page);  \
-		CDEBUG(mask, format, ## __VA_ARGS__);		  \
-	}							       \
+		CDEBUG(mask, format, ## __VA_ARGS__);			\
+	}								\
 } while (0)
 
 /**
  * Helper macro, dumping shorter information about \a page into a log.
  */
-#define CL_PAGE_HEADER(mask, env, page, format, ...)			  \
-do {									  \
-	if (cfs_cdebug_show(mask, DEBUG_SUBSYSTEM)) {			 \
-		LIBCFS_DEBUG_MSG_DATA_DECL(msgdata, mask, NULL);		\
+#define CL_PAGE_HEADER(mask, env, page, format, ...)			\
+do {									\
+	if (cfs_cdebug_show(mask, DEBUG_SUBSYSTEM)) {			\
+		LIBCFS_DEBUG_MSG_DATA_DECL(msgdata, mask, NULL);	\
 		cl_page_header_print(env, &msgdata, lu_cdebug_printer, page); \
 		CDEBUG(mask, format, ## __VA_ARGS__);			\
-	}								     \
+	}								\
 } while (0)
 
 static inline struct page *cl_page_vmpage(struct cl_page *page)
@@ -1145,24 +1145,24 @@ static inline bool __page_in_use(const struct cl_page *page, int refc)
  */
 struct cl_lock_descr {
 	/** Object this lock is granted for. */
-	struct cl_object *cld_obj;
+	struct cl_object		*cld_obj;
 	/** Index of the first page protected by this lock. */
-	pgoff_t	   cld_start;
+	pgoff_t				cld_start;
 	/** Index of the last page (inclusive) protected by this lock. */
-	pgoff_t	   cld_end;
+	pgoff_t				cld_end;
 	/** Group ID, for group lock */
-	u64	     cld_gid;
+	u64				cld_gid;
 	/** Lock mode. */
-	enum cl_lock_mode cld_mode;
+	enum cl_lock_mode		cld_mode;
 	/**
 	 * flags to enqueue lock. A combination of bit-flags from
 	 * enum cl_enq_flags.
 	 */
-	u32	     cld_enq_flags;
+	u32				cld_enq_flags;
 };
 
 #define DDESCR "%s(%d):[%lu, %lu]:%x"
-#define PDESCR(descr)						   \
+#define PDESCR(descr)							\
 	cl_lock_mode_name((descr)->cld_mode), (descr)->cld_mode,	\
 	(descr)->cld_start, (descr)->cld_end, (descr)->cld_enq_flags
 
@@ -1173,9 +1173,9 @@ struct cl_lock_descr {
  */
 struct cl_lock {
 	/** List of slices. Immutable after creation. */
-	struct list_head	    cll_layers;
+	struct list_head		cll_layers;
 	/** lock attribute, extent, cl_object, etc. */
-	struct cl_lock_descr  cll_descr;
+	struct cl_lock_descr		cll_descr;
 };
 
 /**
@@ -1184,14 +1184,14 @@ struct cl_lock {
  * \see vvp_lock, lov_lock, lovsub_lock, osc_lock
  */
 struct cl_lock_slice {
-	struct cl_lock		  *cls_lock;
+	struct cl_lock			*cls_lock;
 	/** Object slice corresponding to this lock slice. Immutable after
 	 * creation.
 	 */
 	struct cl_object		*cls_obj;
 	const struct cl_lock_operations *cls_ops;
 	/** Linkage into cl_lock::cll_layers. Immutable after creation. */
-	struct list_head		       cls_linkage;
+	struct list_head		 cls_linkage;
 };
 
 /**
@@ -1236,22 +1236,22 @@ struct cl_lock_operations {
 			 const struct cl_lock_slice *slice);
 };
 
-#define CL_LOCK_DEBUG(mask, env, lock, format, ...)		     \
-do {								    \
+#define CL_LOCK_DEBUG(mask, env, lock, format, ...)			\
+do {									\
 	LIBCFS_DEBUG_MSG_DATA_DECL(msgdata, mask, NULL);		\
 									\
-	if (cfs_cdebug_show(mask, DEBUG_SUBSYSTEM)) {		   \
+	if (cfs_cdebug_show(mask, DEBUG_SUBSYSTEM)) {			\
 		cl_lock_print(env, &msgdata, lu_cdebug_printer, lock);  \
-		CDEBUG(mask, format, ## __VA_ARGS__);		  \
-	}							       \
+		CDEBUG(mask, format, ## __VA_ARGS__);			\
+	}								\
 } while (0)
 
-#define CL_LOCK_ASSERT(expr, env, lock) do {			    \
-	if (likely(expr))					       \
-		break;						  \
+#define CL_LOCK_ASSERT(expr, env, lock) do {				\
+	if (likely(expr))						\
+		break;							\
 									\
 	CL_LOCK_DEBUG(D_ERROR, env, lock, "failed at %s.\n", #expr);    \
-	LBUG();							 \
+	LBUG();								\
 } while (0)
 
 /** @} cl_lock */
@@ -1276,9 +1276,9 @@ struct cl_lock_operations {
  * @{
  */
 struct cl_page_list {
-	unsigned int		 pl_nr;
-	struct list_head	   pl_pages;
-	struct task_struct	*pl_owner;
+	unsigned int			pl_nr;
+	struct list_head		pl_pages;
+	struct task_struct		*pl_owner;
 };
 
 /**
@@ -1286,8 +1286,8 @@ struct cl_page_list {
  * contains an incoming page list and an outgoing page list.
  */
 struct cl_2queue {
-	struct cl_page_list c2_qin;
-	struct cl_page_list c2_qout;
+	struct cl_page_list		c2_qin;
+	struct cl_page_list		c2_qout;
 };
 
 /** @} cl_page_list */
@@ -1424,16 +1424,16 @@ enum cl_io_state {
  * \see vvp_io, lov_io, osc_io
  */
 struct cl_io_slice {
-	struct cl_io		  *cis_io;
+	struct cl_io			*cis_io;
 	/** corresponding object slice. Immutable after creation. */
-	struct cl_object	      *cis_obj;
+	struct cl_object		*cis_obj;
 	/** io operations. Immutable after creation. */
-	const struct cl_io_operations *cis_iop;
+	const struct cl_io_operations	*cis_iop;
 	/**
 	 * linkage into a list of all slices for a given cl_io, hanging off
 	 * cl_io::ci_layers. Immutable after creation.
 	 */
-	struct list_head		     cis_linkage;
+	struct list_head		cis_linkage;
 };
 
 typedef void (*cl_commit_cbt)(const struct lu_env *, struct cl_io *,
@@ -1445,16 +1445,16 @@ struct cl_read_ahead {
 	 * This is determined DLM lock coverage, RPC and stripe boundary.
 	 * cra_end is included.
 	 */
-	pgoff_t cra_end;
+	pgoff_t				cra_end;
 	/* optimal RPC size for this read, by pages */
-	unsigned long cra_rpc_size;
+	unsigned long			cra_rpc_size;
 	/*
 	 * Release callback. If readahead holds resources underneath, this
 	 * function should be called to release it.
 	 */
 	void (*cra_release)(const struct lu_env *env, void *cbdata);
 	/* Callback data for cra_release routine */
-	void *cra_cbdata;
+	void				*cra_cbdata;
 };
 
 static inline void cl_read_ahead_release(const struct lu_env *env,
@@ -1594,18 +1594,18 @@ enum cl_enq_flags {
 	 * instruct server to not block, if conflicting lock is found. Instead
 	 * -EWOULDBLOCK is returned immediately.
 	 */
-	CEF_NONBLOCK     = 0x00000001,
+	CEF_NONBLOCK		= 0x00000001,
 	/**
 	 * take lock asynchronously (out of order), as it cannot
 	 * deadlock. This is for LDLM_FL_HAS_INTENT locks used for glimpsing.
 	 */
-	CEF_ASYNC	= 0x00000002,
+	CEF_ASYNC		= 0x00000002,
 	/**
 	 * tell the server to instruct (though a flag in the blocking ast) an
 	 * owner of the conflicting lock, that it can drop dirty pages
 	 * protected by this lock, without sending them to the server.
 	 */
-	CEF_DISCARD_DATA = 0x00000004,
+	CEF_DISCARD_DATA	= 0x00000004,
 	/**
 	 * tell the sub layers that it must be a `real' lock. This is used for
 	 * mmapped-buffer locks and glimpse locks that must be never converted
@@ -1613,7 +1613,7 @@ enum cl_enq_flags {
 	 *
 	 * \see vvp_mmap_locks(), cl_glimpse_lock().
 	 */
-	CEF_MUST	 = 0x00000008,
+	CEF_MUST		= 0x00000008,
 	/**
 	 * tell the sub layers that never request a `real' lock. This flag is
 	 * not used currently.
@@ -1624,24 +1624,24 @@ enum cl_enq_flags {
 	 * object doing IO; however, lock itself may have precise requirements
 	 * that are described by the enqueue flags.
 	 */
-	CEF_NEVER	= 0x00000010,
+	CEF_NEVER		= 0x00000010,
 	/**
 	 * for async glimpse lock.
 	 */
-	CEF_AGL	  = 0x00000020,
+	CEF_AGL			= 0x00000020,
 	/**
 	 * enqueue a lock to test DLM lock existence.
 	 */
-	CEF_PEEK	= 0x00000040,
+	CEF_PEEK		= 0x00000040,
 	/**
 	 * Lock match only. Used by group lock in I/O as group lock
 	 * is known to exist.
 	 */
-	CEF_LOCK_MATCH	= BIT(7),
+	CEF_LOCK_MATCH		= BIT(7),
 	/**
 	 * mask of enq_flags.
 	 */
-	CEF_MASK	= 0x000000ff,
+	CEF_MASK		= 0x000000ff,
 };
 
 /**
@@ -1650,8 +1650,8 @@ enum cl_enq_flags {
  */
 struct cl_io_lock_link {
 	/** linkage into one of cl_lockset lists. */
-	struct list_head	   cill_linkage;
-	struct cl_lock          cill_lock;
+	struct list_head	cill_linkage;
+	struct cl_lock		cill_lock;
 	/** optional destructor */
 	void	       (*cill_fini)(const struct lu_env *env,
 				    struct cl_io_lock_link *link);
@@ -1689,9 +1689,9 @@ struct cl_io_lock_link {
  */
 struct cl_lockset {
 	/** locks to be acquired. */
-	struct list_head  cls_todo;
+	struct list_head	cls_todo;
 	/** locks acquired. */
-	struct list_head  cls_done;
+	struct list_head	cls_done;
 };
 
 /**
@@ -1709,21 +1709,21 @@ enum cl_io_lock_dmd {
 
 enum cl_fsync_mode {
 	/** start writeback, do not wait for them to finish */
-	CL_FSYNC_NONE  = 0,
+	CL_FSYNC_NONE		= 0,
 	/** start writeback and wait for them to finish */
-	CL_FSYNC_LOCAL = 1,
+	CL_FSYNC_LOCAL		= 1,
 	/** discard all of dirty pages in a specific file range */
-	CL_FSYNC_DISCARD = 2,
+	CL_FSYNC_DISCARD	= 2,
 	/** start writeback and make sure they have reached storage before
 	 * return. OST_SYNC RPC must be issued and finished
 	 */
-	CL_FSYNC_ALL   = 3
+	CL_FSYNC_ALL		= 3
 };
 
 struct cl_io_rw_common {
-	loff_t      crw_pos;
-	size_t      crw_count;
-	int	 crw_nonblock;
+	loff_t			crw_pos;
+	size_t			crw_count;
+	int			crw_nonblock;
 };
 
 /**
@@ -1739,65 +1739,65 @@ struct cl_io {
 	/** type of this IO. Immutable after creation. */
 	enum cl_io_type		ci_type;
 	/** current state of cl_io state machine. */
-	enum cl_io_state	       ci_state;
+	enum cl_io_state	ci_state;
 	/** main object this io is against. Immutable after creation. */
-	struct cl_object	      *ci_obj;
+	struct cl_object	*ci_obj;
 	/**
 	 * Upper layer io, of which this io is a part of. Immutable after
 	 * creation.
 	 */
-	struct cl_io		  *ci_parent;
+	struct cl_io		*ci_parent;
 	/** List of slices. Immutable after creation. */
-	struct list_head		     ci_layers;
+	struct list_head	ci_layers;
 	/** list of locks (to be) acquired by this io. */
-	struct cl_lockset	      ci_lockset;
+	struct cl_lockset	ci_lockset;
 	/** lock requirements, this is just a help info for sublayers. */
-	enum cl_io_lock_dmd	    ci_lockreq;
+	enum cl_io_lock_dmd	ci_lockreq;
 	union {
 		struct cl_rd_io {
-			struct cl_io_rw_common rd;
+			struct cl_io_rw_common	rd;
 		} ci_rd;
 		struct cl_wr_io {
-			struct cl_io_rw_common wr;
-			int		    wr_append;
-			int		    wr_sync;
+			struct cl_io_rw_common	wr;
+			int			wr_append;
+			int			wr_sync;
 		} ci_wr;
-		struct cl_io_rw_common ci_rw;
+		struct cl_io_rw_common	ci_rw;
 		struct cl_setattr_io {
-			struct ost_lvb   sa_attr;
-			unsigned int		 sa_attr_flags;
-			unsigned int     sa_avalid;
+			struct ost_lvb		sa_attr;
+			unsigned int		sa_attr_flags;
+			unsigned int		sa_avalid;
 			unsigned int		sa_xvalid; /* OP_XVALID */
-			int		sa_stripe_index;
-			struct ost_layout	 sa_layout;
+			int			sa_stripe_index;
+			struct ost_layout	sa_layout;
 			const struct lu_fid	*sa_parent_fid;
 		} ci_setattr;
 		struct cl_data_version_io {
-			u64 dv_data_version;
-			int dv_flags;
+			u64			dv_data_version;
+			int			dv_flags;
 		} ci_data_version;
 		struct cl_fault_io {
 			/** page index within file. */
-			pgoff_t	 ft_index;
+			pgoff_t			ft_index;
 			/** bytes valid byte on a faulted page. */
-			size_t	     ft_nob;
+			size_t			ft_nob;
 			/** writable page? for nopage() only */
-			int	     ft_writable;
+			int			ft_writable;
 			/** page of an executable? */
-			int	     ft_executable;
+			int			ft_executable;
 			/** page_mkwrite() */
-			int	     ft_mkwrite;
+			int			ft_mkwrite;
 			/** resulting page */
-			struct cl_page *ft_page;
+			struct cl_page		*ft_page;
 		} ci_fault;
 		struct cl_fsync_io {
-			loff_t	     fi_start;
-			loff_t	     fi_end;
+			loff_t			fi_start;
+			loff_t			fi_end;
 			/** file system level fid */
-			struct lu_fid     *fi_fid;
-			enum cl_fsync_mode fi_mode;
+			struct lu_fid		*fi_fid;
+			enum cl_fsync_mode	fi_mode;
 			/* how many pages were written/discarded */
-			unsigned int       fi_nr_written;
+			unsigned int		fi_nr_written;
 		} ci_fsync;
 		struct cl_ladvise_io {
 			u64			li_start;
@@ -1808,30 +1808,30 @@ struct cl_io {
 			u64			li_flags;
 		} ci_ladvise;
 	} u;
-	struct cl_2queue     ci_queue;
-	size_t	       ci_nob;
-	int		  ci_result;
-	unsigned int	 ci_continue:1,
+	struct cl_2queue	ci_queue;
+	size_t			ci_nob;
+	int			ci_result;
+	unsigned int		ci_continue:1,
 	/**
 	 * This io has held grouplock, to inform sublayers that
 	 * don't do lockless i/o.
 	 */
-			     ci_no_srvlock:1,
+				ci_no_srvlock:1,
 	/**
 	 * The whole IO need to be restarted because layout has been changed
 	 */
-			     ci_need_restart:1,
+				ci_need_restart:1,
 	/**
 	 * to not refresh layout - the IO issuer knows that the layout won't
 	 * change(page operations, layout change causes all page to be
 	 * discarded), or it doesn't matter if it changes(sync).
 	 */
-			     ci_ignore_layout:1,
+				ci_ignore_layout:1,
 	/**
 	 * Need MDS intervention to complete a write. This usually means the
 	 * corresponding component is not initialized for the writing extent.
 	 */
-			ci_need_write_intent:1,
+				ci_need_write_intent:1,
 	/**
 	 * Check if layout changed after the IO finishes. Mainly for HSM
 	 * requirement. If IO occurs to openning files, it doesn't need to
@@ -1839,19 +1839,19 @@ struct cl_io {
 	 * Right now, only two operations need to verify layout: glimpse
 	 * and setattr.
 	 */
-			     ci_verify_layout:1,
+				ci_verify_layout:1,
 	/**
 	 * file is released, restore has to be triggered by vvp layer
 	 */
-			     ci_restore_needed:1,
+				ci_restore_needed:1,
 	/**
 	 * O_NOATIME
 	 */
-			     ci_noatime:1;
+				ci_noatime:1;
 	/**
 	 * Number of pages owned by this IO. For invariant checking.
 	 */
-	unsigned int	     ci_owned_nr;
+	unsigned int		ci_owned_nr;
 };
 
 /** @} cl_io */
@@ -1860,14 +1860,14 @@ struct cl_io {
  * Per-transfer attributes.
  */
 struct cl_req_attr {
-	enum cl_req_type cra_type;
-	u64		 cra_flags;
-	struct cl_page	*cra_page;
+	enum cl_req_type	cra_type;
+	u64			cra_flags;
+	struct cl_page	       *cra_page;
 
 	/** Generic attributes for the server consumption. */
-	struct obdo	*cra_oa;
+	struct obdo	       *cra_oa;
 	/** Jobid */
-	char		 cra_jobid[LUSTRE_JOBID_SIZE];
+	char			cra_jobid[LUSTRE_JOBID_SIZE];
 };
 
 enum cache_stats_item {
@@ -1892,8 +1892,8 @@ enum cache_stats_item {
  * Stats for a generic cache (similar to inode, lu_object, etc. caches).
  */
 struct cache_stats {
-	const char    *cs_name;
-	atomic_t   cs_stats[CS_NR];
+	const char	       *cs_name;
+	atomic_t		cs_stats[CS_NR];
 };
 
 /** These are not exported so far */
@@ -1905,7 +1905,7 @@ struct cache_stats {
  * clients to co-exist in the single address space.
  */
 struct cl_site {
-	struct lu_site	cs_lu;
+	struct lu_site		cs_lu;
 	/**
 	 * Statistical counters. Atomics do not scale, something better like
 	 * per-cpu counters is needed.
@@ -1915,8 +1915,8 @@ struct cl_site {
 	 * When interpreting keep in mind that both sub-locks (and sub-pages)
 	 * and top-locks (and top-pages) are accounted here.
 	 */
-	struct cache_stats    cs_pages;
-	atomic_t	  cs_pages_state[CPS_NR];
+	struct cache_stats	cs_pages;
+	atomic_t		cs_pages_state[CPS_NR];
 };
 
 int  cl_site_init(struct cl_site *s, struct cl_device *top);
@@ -2341,13 +2341,13 @@ static inline struct cl_page *cl_page_list_first(struct cl_page_list *plist)
 /**
  * Iterate over pages in a page list.
  */
-#define cl_page_list_for_each(page, list)			       \
+#define cl_page_list_for_each(page, list)				\
 	list_for_each_entry((page), &(list)->pl_pages, cp_batch)
 
 /**
  * Iterate over pages in a page list, taking possible removals into account.
  */
-#define cl_page_list_for_each_safe(page, temp, list)		    \
+#define cl_page_list_for_each_safe(page, temp, list)			\
 	list_for_each_entry_safe((page), (temp), &(list)->pl_pages, cp_batch)
 
 void cl_page_list_init(struct cl_page_list *plist);
@@ -2394,7 +2394,7 @@ struct cl_sync_io {
 	/** barrier of destroy this structure */
 	atomic_t		csi_barrier;
 	/** completion to be signaled when transfer is complete. */
-	wait_queue_head_t		csi_waitq;
+	wait_queue_head_t	csi_waitq;
 	/** callback to invoke when this IO is finished */
 	void			(*csi_end_io)(const struct lu_env *,
 					      struct cl_sync_io *);
diff --git a/drivers/staging/lustre/lustre/include/lprocfs_status.h b/drivers/staging/lustre/lustre/include/lprocfs_status.h
index 7649040..d69f395 100644
--- a/drivers/staging/lustre/lustre/include/lprocfs_status.h
+++ b/drivers/staging/lustre/lustre/include/lprocfs_status.h
@@ -49,25 +49,25 @@
 #include <uapi/linux/lustre/lustre_idl.h>
 
 struct lprocfs_vars {
-	const char		*name;
+	const char			*name;
 	const struct file_operations	*fops;
-	void			*data;
+	void				*data;
 	/**
 	 * sysfs file mode.
 	 */
-	umode_t			proc_mode;
+	umode_t				proc_mode;
 };
 
 struct lprocfs_static_vars {
-	struct lprocfs_vars *obd_vars;
-	const struct attribute_group *sysfs_vars;
+	struct lprocfs_vars		*obd_vars;
+	const struct attribute_group	*sysfs_vars;
 };
 
 /* if we find more consumers this could be generalized */
 #define OBD_HIST_MAX 32
 struct obd_histogram {
-	spinlock_t	oh_lock;
-	unsigned long	oh_buckets[OBD_HIST_MAX];
+	spinlock_t			oh_lock;
+	unsigned long			oh_buckets[OBD_HIST_MAX];
 };
 
 enum {
@@ -125,37 +125,37 @@ struct rename_stats {
  */
 
 enum {
-	LPROCFS_CNTR_EXTERNALLOCK = 0x0001,
-	LPROCFS_CNTR_AVGMINMAX    = 0x0002,
-	LPROCFS_CNTR_STDDEV       = 0x0004,
+	LPROCFS_CNTR_EXTERNALLOCK	= 0x0001,
+	LPROCFS_CNTR_AVGMINMAX		= 0x0002,
+	LPROCFS_CNTR_STDDEV		= 0x0004,
 
 	/* counter data type */
-	LPROCFS_TYPE_REGS	 = 0x0100,
-	LPROCFS_TYPE_BYTES	= 0x0200,
-	LPROCFS_TYPE_PAGES	= 0x0400,
-	LPROCFS_TYPE_CYCLE	= 0x0800,
+	LPROCFS_TYPE_REGS		= 0x0100,
+	LPROCFS_TYPE_BYTES		= 0x0200,
+	LPROCFS_TYPE_PAGES		= 0x0400,
+	LPROCFS_TYPE_CYCLE		= 0x0800,
 };
 
 #define LC_MIN_INIT ((~(u64)0) >> 1)
 
 struct lprocfs_counter_header {
-	unsigned int		lc_config;
-	const char		*lc_name;   /* must be static */
-	const char		*lc_units;  /* must be static */
+	unsigned int	 lc_config;
+	const char	*lc_name;   /* must be static */
+	const char	*lc_units;  /* must be static */
 };
 
 struct lprocfs_counter {
-	s64	lc_count;
-	s64	lc_min;
-	s64	lc_max;
-	s64	lc_sumsquare;
+	s64		lc_count;
+	s64		lc_min;
+	s64		lc_max;
+	s64		lc_sumsquare;
 	/*
 	 * Every counter has lc_array_sum[0], while lc_array_sum[1] is only
 	 * for irq context counter, i.e. stats with
 	 * LPROCFS_STATS_FLAG_IRQ_SAFE flag, its counter need
 	 * lc_array_sum[1]
 	 */
-	s64	lc_array_sum[1];
+	s64		lc_array_sum[1];
 };
 
 #define lc_sum		lc_array_sum[0]
@@ -165,20 +165,23 @@ struct lprocfs_percpu {
 #ifndef __GNUC__
 	s64			pad;
 #endif
-	struct lprocfs_counter lp_cntr[0];
+	struct lprocfs_counter	lp_cntr[0];
 };
 
 enum lprocfs_stats_lock_ops {
-	LPROCFS_GET_NUM_CPU	= 0x0001, /* number allocated per-CPU stats */
-	LPROCFS_GET_SMP_ID	= 0x0002, /* current stat to be updated */
+	LPROCFS_GET_NUM_CPU		= 0x0001, /* number allocated per-CPU
+						   * stats
+						   */
+	LPROCFS_GET_SMP_ID		= 0x0002, /* current stat to be updated
+						   */
 };
 
 enum lprocfs_stats_flags {
-	LPROCFS_STATS_FLAG_NONE     = 0x0000, /* per cpu counter */
-	LPROCFS_STATS_FLAG_NOPERCPU = 0x0001, /* stats have no percpu
-					       * area and need locking
-					       */
-	LPROCFS_STATS_FLAG_IRQ_SAFE = 0x0002, /* alloc need irq safe */
+	LPROCFS_STATS_FLAG_NONE		= 0x0000, /* per cpu counter */
+	LPROCFS_STATS_FLAG_NOPERCPU	= 0x0001, /* stats have no percpu
+						   * area and need locking
+						   */
+	LPROCFS_STATS_FLAG_IRQ_SAFE	= 0x0002, /* alloc need irq safe */
 };
 
 enum lprocfs_fields_flags {
@@ -187,7 +190,7 @@ enum lprocfs_fields_flags {
 	LPROCFS_FIELDS_FLAGS_MIN	= 0x0003,
 	LPROCFS_FIELDS_FLAGS_MAX	= 0x0004,
 	LPROCFS_FIELDS_FLAGS_AVG	= 0x0005,
-	LPROCFS_FIELDS_FLAGS_SUMSQUARE  = 0x0006,
+	LPROCFS_FIELDS_FLAGS_SUMSQUARE	= 0x0006,
 	LPROCFS_FIELDS_FLAGS_COUNT      = 0x0007,
 };
 
@@ -513,12 +516,12 @@ void lprocfs_stats_collect(struct lprocfs_stats *stats, int idx,
 	return single_open(file, name##_seq_show, inode->i_private);	\
 }									\
 static const struct file_operations name##_fops = {			\
-	.owner   = THIS_MODULE,					    \
-	.open    = name##_single_open,				     \
-	.read    = seq_read,					       \
-	.write   = custom_seq_write,				       \
-	.llseek  = seq_lseek,					      \
-	.release = lprocfs_single_release,				 \
+	.owner   = THIS_MODULE,						\
+	.open    = name##_single_open,					\
+	.read    = seq_read,						\
+	.write   = custom_seq_write,					\
+	.llseek  = seq_lseek,						\
+	.release = lprocfs_single_release,				\
 }
 
 #define LPROC_SEQ_FOPS_RO(name)	 __LPROC_SEQ_FOPS(name, NULL)
diff --git a/drivers/staging/lustre/lustre/include/lu_object.h b/drivers/staging/lustre/lustre/include/lu_object.h
index 3e663a9..68aa0d0 100644
--- a/drivers/staging/lustre/lustre/include/lu_object.h
+++ b/drivers/staging/lustre/lustre/include/lu_object.h
@@ -178,7 +178,7 @@ struct lu_object_conf {
 	/**
 	 * Some hints for obj find and alloc.
 	 */
-	enum loc_flags     loc_flags;
+	enum loc_flags	loc_flags;
 };
 
 /**
@@ -261,30 +261,30 @@ struct lu_device {
 	 *
 	 * \todo XXX which means that atomic_t is probably too small.
 	 */
-	atomic_t		       ld_ref;
+	atomic_t				ld_ref;
 	/**
 	 * Pointer to device type. Never modified once set.
 	 */
-	struct lu_device_type       *ld_type;
+	struct lu_device_type			*ld_type;
 	/**
 	 * Operation vector for this device.
 	 */
-	const struct lu_device_operations *ld_ops;
+	const struct lu_device_operations	*ld_ops;
 	/**
 	 * Stack this device belongs to.
 	 */
-	struct lu_site		    *ld_site;
+	struct lu_site				*ld_site;
 
 	/** \todo XXX: temporary back pointer into obd. */
-	struct obd_device		 *ld_obd;
+	struct obd_device			*ld_obd;
 	/**
 	 * A list of references to this object, for debugging.
 	 */
-	struct lu_ref		      ld_reference;
+	struct lu_ref				ld_reference;
 	/**
 	 * Link the device to the site.
 	 **/
-	struct list_head			 ld_linkage;
+	struct list_head			ld_linkage;
 };
 
 struct lu_device_type_operations;
@@ -309,23 +309,23 @@ struct lu_device_type {
 	/**
 	 * Tag bits. Taken from enum lu_device_tag. Never modified once set.
 	 */
-	u32				   ldt_tags;
+	u32					ldt_tags;
 	/**
 	 * Name of this class. Unique system-wide. Never modified once set.
 	 */
-	char				   *ldt_name;
+	char					*ldt_name;
 	/**
 	 * Operations for this type.
 	 */
-	const struct lu_device_type_operations *ldt_ops;
+	const struct lu_device_type_operations	*ldt_ops;
 	/**
 	 * \todo XXX: temporary pointer to associated obd_type.
 	 */
-	struct obd_type			*ldt_obd_type;
+	struct obd_type				*ldt_obd_type;
 	/**
 	 * \todo XXX: temporary: context tags used by obd_*() calls.
 	 */
-	u32				   ldt_ctx_tags;
+	u32					ldt_ctx_tags;
 	/**
 	 * Number of existing device type instances.
 	 */
@@ -427,21 +427,21 @@ struct lu_attr {
 
 /** Bit-mask of valid attributes */
 enum la_valid {
-	LA_ATIME = 1 << 0,
-	LA_MTIME = 1 << 1,
-	LA_CTIME = 1 << 2,
-	LA_SIZE  = 1 << 3,
-	LA_MODE  = 1 << 4,
-	LA_UID   = 1 << 5,
-	LA_GID   = 1 << 6,
-	LA_BLOCKS = 1 << 7,
-	LA_TYPE   = 1 << 8,
-	LA_FLAGS  = 1 << 9,
-	LA_NLINK  = 1 << 10,
-	LA_RDEV   = 1 << 11,
-	LA_BLKSIZE = 1 << 12,
-	LA_KILL_SUID = 1 << 13,
-	LA_KILL_SGID = 1 << 14,
+	LA_ATIME	= 1 << 0,
+	LA_MTIME	= 1 << 1,
+	LA_CTIME	= 1 << 2,
+	LA_SIZE		= 1 << 3,
+	LA_MODE		= 1 << 4,
+	LA_UID		= 1 << 5,
+	LA_GID		= 1 << 6,
+	LA_BLOCKS	= 1 << 7,
+	LA_TYPE		= 1 << 8,
+	LA_FLAGS	= 1 << 9,
+	LA_NLINK	= 1 << 10,
+	LA_RDEV		= 1 << 11,
+	LA_BLKSIZE	= 1 << 12,
+	LA_KILL_SUID	= 1 << 13,
+	LA_KILL_SGID	= 1 << 14,
 };
 
 /**
@@ -451,15 +451,15 @@ struct lu_object {
 	/**
 	 * Header for this object.
 	 */
-	struct lu_object_header	   *lo_header;
+	struct lu_object_header			*lo_header;
 	/**
 	 * Device for this layer.
 	 */
-	struct lu_device		  *lo_dev;
+	struct lu_device			*lo_dev;
 	/**
 	 * Operations for this object.
 	 */
-	const struct lu_object_operations *lo_ops;
+	const struct lu_object_operations	*lo_ops;
 	/**
 	 * Linkage into list of all layers.
 	 */
@@ -467,7 +467,7 @@ struct lu_object {
 	/**
 	 * Link to the device, for debugging.
 	 */
-	struct lu_ref_link                 lo_dev_ref;
+	struct lu_ref_link			 lo_dev_ref;
 };
 
 enum lu_object_header_flags {
@@ -484,13 +484,13 @@ enum lu_object_header_flags {
 };
 
 enum lu_object_header_attr {
-	LOHA_EXISTS   = 1 << 0,
-	LOHA_REMOTE   = 1 << 1,
+	LOHA_EXISTS	= 1 << 0,
+	LOHA_REMOTE	= 1 << 1,
 	/**
 	 * UNIX file type is stored in S_IFMT bits.
 	 */
-	LOHA_FT_START = 001 << 12, /**< S_IFIFO */
-	LOHA_FT_END   = 017 << 12, /**< S_IFMT */
+	LOHA_FT_START	= 001 << 12, /**< S_IFIFO */
+	LOHA_FT_END	= 017 << 12, /**< S_IFMT */
 };
 
 /**
@@ -513,33 +513,33 @@ struct lu_object_header {
 	 * Object flags from enum lu_object_header_flags. Set and checked
 	 * atomically.
 	 */
-	unsigned long	  loh_flags;
+	unsigned long		loh_flags;
 	/**
 	 * Object reference count. Protected by lu_site::ls_guard.
 	 */
-	atomic_t	   loh_ref;
+	atomic_t		loh_ref;
 	/**
 	 * Common object attributes, cached for efficiency. From enum
 	 * lu_object_header_attr.
 	 */
-	u32		  loh_attr;
+	u32			loh_attr;
 	/**
 	 * Linkage into per-site hash table. Protected by lu_site::ls_guard.
 	 */
-	struct hlist_node       loh_hash;
+	struct hlist_node	loh_hash;
 	/**
 	 * Linkage into per-site LRU list. Protected by lu_site::ls_guard.
 	 */
-	struct list_head	     loh_lru;
+	struct list_head	loh_lru;
 	/**
 	 * Linkage into list of layers. Never modified once set (except lately
 	 * during object destruction). No locking is necessary.
 	 */
-	struct list_head	     loh_layers;
+	struct list_head	loh_layers;
 	/**
 	 * A list of references to this object, for debugging.
 	 */
-	struct lu_ref	  loh_reference;
+	struct lu_ref		loh_reference;
 };
 
 struct fld;
@@ -577,7 +577,7 @@ struct lu_site {
 	/**
 	 * Top-level device for this stack.
 	 */
-	struct lu_device	 *ls_top_dev;
+	struct lu_device	*ls_top_dev;
 	/**
 	 * Bottom-level device for this stack
 	 */
@@ -585,12 +585,12 @@ struct lu_site {
 	/**
 	 * Linkage into global list of sites.
 	 */
-	struct list_head		ls_linkage;
+	struct list_head	ls_linkage;
 	/**
 	 * List for lu device for this site, protected
 	 * by ls_ld_lock.
 	 **/
-	struct list_head		ls_ld_linkage;
+	struct list_head	ls_ld_linkage;
 	spinlock_t		ls_ld_lock;
 
 	/**
@@ -609,7 +609,7 @@ struct lu_site {
 	/**
 	 * Number of objects in lsb_lru_lists - used for shrinking
 	 */
-	struct percpu_counter	 ls_lru_len_counter;
+	struct percpu_counter	ls_lru_len_counter;
 };
 
 wait_queue_head_t *
@@ -753,31 +753,31 @@ int lu_cdebug_printer(const struct lu_env *env,
 /**
  * Print object description followed by a user-supplied message.
  */
-#define LU_OBJECT_DEBUG(mask, env, object, format, ...)		   \
-do {								      \
-	if (cfs_cdebug_show(mask, DEBUG_SUBSYSTEM)) {		     \
+#define LU_OBJECT_DEBUG(mask, env, object, format, ...)			\
+do {									\
+	if (cfs_cdebug_show(mask, DEBUG_SUBSYSTEM)) {			\
 		LIBCFS_DEBUG_MSG_DATA_DECL(msgdata, mask, NULL);	\
 		lu_object_print(env, &msgdata, lu_cdebug_printer, object);\
-		CDEBUG(mask, format "\n", ## __VA_ARGS__);		    \
-	}								 \
+		CDEBUG(mask, format "\n", ## __VA_ARGS__);		\
+	}								\
 } while (0)
 
 /**
  * Print short object description followed by a user-supplied message.
  */
 #define LU_OBJECT_HEADER(mask, env, object, format, ...)		\
-do {								    \
-	if (cfs_cdebug_show(mask, DEBUG_SUBSYSTEM)) {		   \
+do {									\
+	if (cfs_cdebug_show(mask, DEBUG_SUBSYSTEM)) {			\
 		LIBCFS_DEBUG_MSG_DATA_DECL(msgdata, mask, NULL);	\
 		lu_object_header_print(env, &msgdata, lu_cdebug_printer,\
-				       (object)->lo_header);	    \
-		lu_cdebug_printer(env, &msgdata, "\n");		 \
-		CDEBUG(mask, format, ## __VA_ARGS__);		  \
-	}							       \
+				       (object)->lo_header);		\
+		lu_cdebug_printer(env, &msgdata, "\n");			\
+		CDEBUG(mask, format, ## __VA_ARGS__);			\
+	}								\
 } while (0)
 
-void lu_object_print       (const struct lu_env *env, void *cookie,
-			    lu_printer_t printer, const struct lu_object *o);
+void lu_object_print(const struct lu_env *env, void *cookie,
+		     lu_printer_t printer, const struct lu_object *o);
 void lu_object_header_print(const struct lu_env *env, void *cookie,
 			    lu_printer_t printer,
 			    const struct lu_object_header *hdr);
@@ -849,15 +849,15 @@ static inline void lu_object_ref_del_at(struct lu_object *o,
 /** input params, should be filled out by mdt */
 struct lu_rdpg {
 	/** hash */
-	u64		   rp_hash;
+	u64			rp_hash;
 	/** count in bytes */
-	unsigned int	    rp_count;
+	unsigned int		rp_count;
 	/** number of pages */
-	unsigned int	    rp_npages;
+	unsigned int		rp_npages;
 	/** requested attr */
-	u32		   rp_attrs;
+	u32			rp_attrs;
 	/** pointers to pages */
-	struct page	   **rp_pages;
+	struct page		**rp_pages;
 };
 
 enum lu_xattr_flags {
@@ -912,24 +912,24 @@ struct lu_context {
 	 * of tags has non-empty intersection with one for key. Tags are taken
 	 * from enum lu_context_tag.
 	 */
-	u32		  lc_tags;
-	enum lu_context_state  lc_state;
+	u32			lc_tags;
+	enum lu_context_state	lc_state;
 	/**
 	 * Pointer to the home service thread. NULL for other execution
 	 * contexts.
 	 */
-	struct ptlrpc_thread  *lc_thread;
+	struct ptlrpc_thread	*lc_thread;
 	/**
 	 * Pointer to an array with key values. Internal implementation
 	 * detail.
 	 */
-	void		 **lc_value;
+	void			**lc_value;
 	/**
 	 * Linkage into a list of all remembered contexts. Only
 	 * `non-transient' contexts, i.e., ones created for service threads
 	 * are placed here.
 	 */
-	struct list_head	     lc_remember;
+	struct list_head	lc_remember;
 	/**
 	 * Version counter used to skip calls to lu_context_refill() when no
 	 * keys were registered.
@@ -949,59 +949,59 @@ enum lu_context_tag {
 	/**
 	 * Thread on md server
 	 */
-	LCT_MD_THREAD = 1 << 0,
+	LCT_MD_THREAD		= 1 << 0,
 	/**
 	 * Thread on dt server
 	 */
-	LCT_DT_THREAD = 1 << 1,
+	LCT_DT_THREAD		= 1 << 1,
 	/**
 	 * Context for transaction handle
 	 */
-	LCT_TX_HANDLE = 1 << 2,
+	LCT_TX_HANDLE		= 1 << 2,
 	/**
 	 * Thread on client
 	 */
-	LCT_CL_THREAD = 1 << 3,
+	LCT_CL_THREAD		= 1 << 3,
 	/**
 	 * A per-request session on a server, and a per-system-call session on
 	 * a client.
 	 */
-	LCT_SESSION   = 1 << 4,
+	LCT_SESSION		= 1 << 4,
 	/**
 	 * A per-request data on OSP device
 	 */
-	LCT_OSP_THREAD = 1 << 5,
+	LCT_OSP_THREAD		= 1 << 5,
 	/**
 	 * MGS device thread
 	 */
-	LCT_MG_THREAD = 1 << 6,
+	LCT_MG_THREAD		= 1 << 6,
 	/**
 	 * Context for local operations
 	 */
-	LCT_LOCAL = 1 << 7,
+	LCT_LOCAL		= 1 << 7,
 	/**
 	 * session for server thread
 	 **/
-	LCT_SERVER_SESSION = BIT(8),
+	LCT_SERVER_SESSION	= BIT(8),
 	/**
 	 * Set when@least one of keys, having values in this context has
 	 * non-NULL lu_context_key::lct_exit() method. This is used to
 	 * optimize lu_context_exit() call.
 	 */
-	LCT_HAS_EXIT  = 1 << 28,
+	LCT_HAS_EXIT		= 1 << 28,
 	/**
 	 * Don't add references for modules creating key values in that context.
 	 * This is only for contexts used internally by lu_object framework.
 	 */
-	LCT_NOREF     = 1 << 29,
+	LCT_NOREF		= 1 << 29,
 	/**
 	 * Key is being prepared for retiring, don't create new values for it.
 	 */
-	LCT_QUIESCENT = 1 << 30,
+	LCT_QUIESCENT		= 1 << 30,
 	/**
 	 * Context should be remembered.
 	 */
-	LCT_REMEMBER  = 1 << 31,
+	LCT_REMEMBER		= 1 << 31,
 	/**
 	 * Contexts usable in cache shrinker thread.
 	 */
@@ -1049,7 +1049,7 @@ struct lu_context_key {
 	/**
 	 * Set of tags for which values of this key are to be instantiated.
 	 */
-	u32 lct_tags;
+	u32		lct_tags;
 	/**
 	 * Value constructor. This is called when new value is created for a
 	 * context. Returns pointer to new value of error pointer.
@@ -1074,62 +1074,62 @@ struct lu_context_key {
 	 * Internal implementation detail: index within lu_context::lc_value[]
 	 * reserved for this key.
 	 */
-	int      lct_index;
+	int		lct_index;
 	/**
 	 * Internal implementation detail: number of values created for this
 	 * key.
 	 */
-	atomic_t lct_used;
+	atomic_t	lct_used;
 	/**
 	 * Internal implementation detail: module for this key.
 	 */
-	struct module *lct_owner;
+	struct module	*lct_owner;
 	/**
 	 * References to this key. For debugging.
 	 */
-	struct lu_ref  lct_reference;
+	struct lu_ref	lct_reference;
 };
 
-#define LU_KEY_INIT(mod, type)				    \
-	static void *mod##_key_init(const struct lu_context *ctx, \
-				    struct lu_context_key *key)   \
-	{							 \
-		type *value;				      \
-								  \
-		BUILD_BUG_ON(sizeof(*value) > PAGE_SIZE);        \
-								  \
-		value = kzalloc(sizeof(*value), GFP_NOFS);	\
-		if (!value)				\
-			value = ERR_PTR(-ENOMEM);		 \
-								  \
-		return value;				     \
-	}							 \
+#define LU_KEY_INIT(mod, type)						\
+	static void *mod##_key_init(const struct lu_context *ctx,	\
+				    struct lu_context_key *key)		\
+	{								\
+		type *value;						\
+									\
+		BUILD_BUG_ON(sizeof(*value) > PAGE_SIZE);		\
+									\
+		value = kzalloc(sizeof(*value), GFP_NOFS);		\
+		if (!value)						\
+			value = ERR_PTR(-ENOMEM);			\
+									\
+		return value;						\
+	}								\
 	struct __##mod##__dummy_init {; } /* semicolon catcher */
 
-#define LU_KEY_FINI(mod, type)					      \
-	static void mod##_key_fini(const struct lu_context *ctx,	    \
+#define LU_KEY_FINI(mod, type)						\
+	static void mod##_key_fini(const struct lu_context *ctx,	\
 				    struct lu_context_key *key, void *data) \
-	{								   \
-		type *info = data;					  \
-									    \
-		kfree(info);					 \
-	}								   \
+	{								\
+		type *info = data;					\
+									\
+		kfree(info);						\
+	}								\
 	struct __##mod##__dummy_fini {; } /* semicolon catcher */
 
-#define LU_KEY_INIT_FINI(mod, type)   \
-	LU_KEY_INIT(mod, type);	\
+#define LU_KEY_INIT_FINI(mod, type)			\
+	LU_KEY_INIT(mod, type);				\
 	LU_KEY_FINI(mod, type)
 
 #define LU_CONTEXT_KEY_DEFINE(mod, tags)		\
-	struct lu_context_key mod##_thread_key = {      \
-		.lct_tags = tags,		       \
-		.lct_init = mod##_key_init,	     \
-		.lct_fini = mod##_key_fini	      \
+	struct lu_context_key mod##_thread_key = {	\
+		.lct_tags = tags,			\
+		.lct_init = mod##_key_init,		\
+		.lct_fini = mod##_key_fini		\
 	}
 
 #define LU_CONTEXT_KEY_INIT(key)			\
-do {						    \
-	(key)->lct_owner = THIS_MODULE;		 \
+do {							\
+	(key)->lct_owner = THIS_MODULE;			\
 } while (0)
 
 int lu_context_key_register(struct lu_context_key *key);
@@ -1144,53 +1144,53 @@ void *lu_context_key_get(const struct lu_context *ctx,
  * owning module.
  */
 
-#define LU_KEY_INIT_GENERIC(mod)					\
+#define LU_KEY_INIT_GENERIC(mod)					  \
 	static void mod##_key_init_generic(struct lu_context_key *k, ...) \
-	{							       \
-		struct lu_context_key *key = k;			 \
-		va_list args;					   \
-									\
-		va_start(args, k);				      \
-		do {						    \
-			LU_CONTEXT_KEY_INIT(key);		       \
-			key = va_arg(args, struct lu_context_key *);    \
-		} while (key);				  \
-		va_end(args);					   \
+	{								  \
+		struct lu_context_key *key = k;				  \
+		va_list args;						  \
+									  \
+		va_start(args, k);					  \
+		do {							  \
+			LU_CONTEXT_KEY_INIT(key);			  \
+			key = va_arg(args, struct lu_context_key *);	  \
+		} while (key);						  \
+		va_end(args);						  \
 	}
 
-#define LU_TYPE_INIT(mod, ...)					  \
-	LU_KEY_INIT_GENERIC(mod)					\
-	static int mod##_type_init(struct lu_device_type *t)	    \
-	{							       \
-		mod##_key_init_generic(__VA_ARGS__, NULL);	      \
-		return lu_context_key_register_many(__VA_ARGS__, NULL); \
-	}							       \
+#define LU_TYPE_INIT(mod, ...)						  \
+	LU_KEY_INIT_GENERIC(mod)					  \
+	static int mod##_type_init(struct lu_device_type *t)		  \
+	{								  \
+		mod##_key_init_generic(__VA_ARGS__, NULL);		  \
+		return lu_context_key_register_many(__VA_ARGS__, NULL);	  \
+	}								  \
 	struct __##mod##_dummy_type_init {; }
 
-#define LU_TYPE_FINI(mod, ...)					  \
-	static void mod##_type_fini(struct lu_device_type *t)	   \
-	{							       \
+#define LU_TYPE_FINI(mod, ...)						\
+	static void mod##_type_fini(struct lu_device_type *t)		\
+	{								\
 		lu_context_key_degister_many(__VA_ARGS__, NULL);	\
-	}							       \
+	}								\
 	struct __##mod##_dummy_type_fini {; }
 
-#define LU_TYPE_START(mod, ...)				 \
-	static void mod##_type_start(struct lu_device_type *t)  \
-	{						       \
-		lu_context_key_revive_many(__VA_ARGS__, NULL);  \
-	}						       \
+#define LU_TYPE_START(mod, ...)						\
+	static void mod##_type_start(struct lu_device_type *t)		\
+	{								\
+		lu_context_key_revive_many(__VA_ARGS__, NULL);		\
+	}								\
 	struct __##mod##_dummy_type_start {; }
 
-#define LU_TYPE_STOP(mod, ...)				  \
-	static void mod##_type_stop(struct lu_device_type *t)   \
-	{						       \
-		lu_context_key_quiesce_many(__VA_ARGS__, NULL); \
-	}						       \
+#define LU_TYPE_STOP(mod, ...)						\
+	static void mod##_type_stop(struct lu_device_type *t)		\
+	{								\
+		lu_context_key_quiesce_many(__VA_ARGS__, NULL);		\
+	}								\
 	struct __##mod##_dummy_type_stop {; }
 
-#define LU_TYPE_INIT_FINI(mod, ...)	     \
-	LU_TYPE_INIT(mod, __VA_ARGS__);	 \
-	LU_TYPE_FINI(mod, __VA_ARGS__);	 \
+#define LU_TYPE_INIT_FINI(mod, ...)		\
+	LU_TYPE_INIT(mod, __VA_ARGS__);		\
+	LU_TYPE_FINI(mod, __VA_ARGS__);		\
 	LU_TYPE_START(mod, __VA_ARGS__);	\
 	LU_TYPE_STOP(mod, __VA_ARGS__)
 
@@ -1217,11 +1217,11 @@ struct lu_env {
 	/**
 	 * "Local" context, used to store data instead of stack.
 	 */
-	struct lu_context  le_ctx;
+	struct lu_context	le_ctx;
 	/**
 	 * "Session" context for per-request data.
 	 */
-	struct lu_context *le_ses;
+	struct lu_context	*le_ses;
 };
 
 int lu_env_init(struct lu_env *env, u32 tags);
@@ -1240,8 +1240,8 @@ struct lu_env {
  * Common name structure to be passed around for various name related methods.
  */
 struct lu_name {
-	const char    *ln_name;
-	int	    ln_namelen;
+	const char	*ln_name;
+	int		ln_namelen;
 };
 
 /**
@@ -1265,8 +1265,8 @@ static inline bool lu_name_is_valid_2(const char *name, size_t name_len)
  * methods.
  */
 struct lu_buf {
-	void   *lb_buf;
-	size_t	lb_len;
+	void		*lb_buf;
+	size_t		lb_len;
 };
 
 /**
@@ -1285,9 +1285,9 @@ struct lu_buf {
 void lu_global_fini(void);
 
 struct lu_kmem_descr {
-	struct kmem_cache **ckd_cache;
-	const char       *ckd_name;
-	const size_t      ckd_size;
+	struct kmem_cache     **ckd_cache;
+	const char	       *ckd_name;
+	const size_t		ckd_size;
 };
 
 int  lu_kmem_init(struct lu_kmem_descr *caches);
diff --git a/drivers/staging/lustre/lustre/include/lustre_disk.h b/drivers/staging/lustre/lustre/include/lustre_disk.h
index 091a09f..07c074e 100644
--- a/drivers/staging/lustre/lustre/include/lustre_disk.h
+++ b/drivers/staging/lustre/lustre/include/lustre_disk.h
@@ -51,13 +51,13 @@
 
 /****************** persistent mount data *********************/
 
-#define LDD_F_SV_TYPE_MDT   0x0001
-#define LDD_F_SV_TYPE_OST   0x0002
-#define LDD_F_SV_TYPE_MGS   0x0004
-#define LDD_F_SV_TYPE_MASK (LDD_F_SV_TYPE_MDT  | \
-			    LDD_F_SV_TYPE_OST  | \
-			    LDD_F_SV_TYPE_MGS)
-#define LDD_F_SV_ALL	0x0008
+#define LDD_F_SV_TYPE_MDT	0x0001
+#define LDD_F_SV_TYPE_OST	0x0002
+#define LDD_F_SV_TYPE_MGS	0x0004
+#define LDD_F_SV_TYPE_MASK	(LDD_F_SV_TYPE_MDT  | \
+				 LDD_F_SV_TYPE_OST  | \
+				 LDD_F_SV_TYPE_MGS)
+#define LDD_F_SV_ALL		0x0008
 
 /****************** mount command *********************/
 
@@ -65,7 +65,7 @@
  * everything as string options
  */
 
-#define LMD_MAGIC    0xbdacbd03
+#define LMD_MAGIC		0xbdacbd03
 #define LMD_PARAMS_MAXLEN	4096
 
 /* gleaned from the mount command - no persistent info here */
@@ -117,19 +117,19 @@ struct lustre_mount_data {
 struct kobject;
 
 struct lustre_sb_info {
-	int			lsi_flags;
-	struct obd_device	*lsi_mgc;     /* mgc obd */
-	struct lustre_mount_data *lsi_lmd;     /* mount command info */
-	struct ll_sb_info	*lsi_llsbi;   /* add'l client sbi info */
-	struct dt_device	*lsi_dt_dev;  /* dt device to access disk fs*/
-	atomic_t		lsi_mounts;  /* references to the srv_mnt */
-	struct kobject		*lsi_kobj;
-	char			lsi_svname[MTI_NAME_MAXLEN];
-	char			lsi_osd_obdname[64];
-	char			lsi_osd_uuid[64];
-	struct obd_export	*lsi_osd_exp;
-	char			lsi_osd_type[16];
-	char			lsi_fstype[16];
+	int			  lsi_flags;
+	struct obd_device	 *lsi_mgc;    /* mgc obd */
+	struct lustre_mount_data *lsi_lmd;    /* mount command info */
+	struct ll_sb_info	 *lsi_llsbi;  /* add'l client sbi info */
+	struct dt_device	 *lsi_dt_dev; /* dt device to access disk fs */
+	atomic_t		  lsi_mounts; /* references to the srv_mnt */
+	struct kobject		 *lsi_kobj;
+	char			  lsi_svname[MTI_NAME_MAXLEN];
+	char			  lsi_osd_obdname[64];
+	char			  lsi_osd_uuid[64];
+	struct obd_export	 *lsi_osd_exp;
+	char			  lsi_osd_type[16];
+	char			  lsi_fstype[16];
 };
 
 #define LSI_UMOUNT_FAILOVER	0x00200000
diff --git a/drivers/staging/lustre/lustre/include/lustre_dlm.h b/drivers/staging/lustre/lustre/include/lustre_dlm.h
index 7c12087..c561d61 100644
--- a/drivers/staging/lustre/lustre/include/lustre_dlm.h
+++ b/drivers/staging/lustre/lustre/include/lustre_dlm.h
@@ -66,17 +66,17 @@
  * LDLM non-error return states
  */
 enum ldlm_error {
-	ELDLM_OK = 0,
-	ELDLM_LOCK_MATCHED = 1,
+	ELDLM_OK		= 0,
+	ELDLM_LOCK_MATCHED	= 1,
 
-	ELDLM_LOCK_CHANGED = 300,
-	ELDLM_LOCK_ABORTED = 301,
-	ELDLM_LOCK_REPLACED = 302,
-	ELDLM_NO_LOCK_DATA = 303,
-	ELDLM_LOCK_WOULDBLOCK = 304,
+	ELDLM_LOCK_CHANGED	= 300,
+	ELDLM_LOCK_ABORTED	= 301,
+	ELDLM_LOCK_REPLACED	= 302,
+	ELDLM_NO_LOCK_DATA	= 303,
+	ELDLM_LOCK_WOULDBLOCK	= 304,
 
-	ELDLM_NAMESPACE_EXISTS = 400,
-	ELDLM_BAD_NAMESPACE    = 401
+	ELDLM_NAMESPACE_EXISTS	= 400,
+	ELDLM_BAD_NAMESPACE	= 401
 };
 
 /**
@@ -389,7 +389,7 @@ struct ldlm_namespace {
 	 * Position in global namespace list linking all namespaces on
 	 * the node.
 	 */
-	struct list_head		ns_list_chain;
+	struct list_head	ns_list_chain;
 
 	/**
 	 * List of unused locks for this namespace. This list is also called
@@ -401,7 +401,7 @@ struct ldlm_namespace {
 	 * to release from the head of this list.
 	 * Locks are linked via l_lru field in \see struct ldlm_lock.
 	 */
-	struct list_head		ns_unused_list;
+	struct list_head	ns_unused_list;
 	/** Number of locks in the LRU list above */
 	int			ns_nr_unused;
 
@@ -437,7 +437,7 @@ struct ldlm_namespace {
 	 * Wait queue used by __ldlm_namespace_free. Gets woken up every time
 	 * a resource is removed.
 	 */
-	wait_queue_head_t		ns_waitq;
+	wait_queue_head_t	ns_waitq;
 	/** LDLM pool structure for this namespace */
 	struct ldlm_pool	ns_pool;
 	/** Definition of how eagerly unused locks will be released from LRU */
@@ -502,7 +502,7 @@ typedef int (*ldlm_completion_callback)(struct ldlm_lock *lock, u64 flags,
 /** Work list for sending GL ASTs to multiple locks. */
 struct ldlm_glimpse_work {
 	struct ldlm_lock	*gl_lock; /* lock to glimpse */
-	struct list_head		 gl_list; /* linkage to other gl work structs */
+	struct list_head	 gl_list; /* linkage to other gl work structs */
 	u32			 gl_flags;/* see LDLM_GL_WORK_* below */
 	union ldlm_gl_desc	*gl_desc; /* glimpse descriptor to be packed in
 					   * glimpse callback request
@@ -538,18 +538,18 @@ enum ldlm_cancel_flags {
 };
 
 struct ldlm_flock {
-	u64 start;
-	u64 end;
-	u64 owner;
-	u64 blocking_owner;
-	struct obd_export *blocking_export;
-	u32 pid;
+	u64			start;
+	u64			end;
+	u64			owner;
+	u64			blocking_owner;
+	struct obd_export	*blocking_export;
+	u32			pid;
 };
 
 union ldlm_policy_data {
-	struct ldlm_extent l_extent;
-	struct ldlm_flock l_flock;
-	struct ldlm_inodebits l_inodebits;
+	struct ldlm_extent	l_extent;
+	struct ldlm_flock	l_flock;
+	struct ldlm_inodebits	l_inodebits;
 };
 
 void ldlm_convert_policy_to_local(struct obd_export *exp, enum ldlm_type type,
@@ -589,23 +589,23 @@ struct ldlm_lock {
 	 *
 	 * Must be first in the structure.
 	 */
-	struct portals_handle	l_handle;
+	struct portals_handle		l_handle;
 	/**
 	 * Lock reference count.
 	 * This is how many users have pointers to actual structure, so that
 	 * we do not accidentally free lock structure that is in use.
 	 */
-	atomic_t		l_refc;
+	atomic_t			l_refc;
 	/**
 	 * Internal spinlock protects l_resource.  We should hold this lock
 	 * first before taking res_lock.
 	 */
-	spinlock_t		l_lock;
+	spinlock_t			l_lock;
 	/**
 	 * Pointer to actual resource this lock is in.
 	 * ldlm_lock_change_resource() can change this.
 	 */
-	struct ldlm_resource	*l_resource;
+	struct ldlm_resource		*l_resource;
 	/**
 	 * List item for client side LRU list.
 	 * Protected by ns_lock in struct ldlm_namespace.
@@ -620,20 +620,20 @@ struct ldlm_lock {
 	/**
 	 * Interval-tree node for ldlm_extent.
 	 */
-	struct rb_node		l_rb;
-	u64			__subtree_last;
+	struct rb_node			l_rb;
+	u64				__subtree_last;
 
 	/**
 	 * Requested mode.
 	 * Protected by lr_lock.
 	 */
-	enum ldlm_mode		l_req_mode;
+	enum ldlm_mode			l_req_mode;
 	/**
 	 * Granted mode, also protected by lr_lock.
 	 */
-	enum ldlm_mode		l_granted_mode;
+	enum ldlm_mode			l_granted_mode;
 	/** Lock completion handler pointer. Called when lock is granted. */
-	ldlm_completion_callback l_completion_ast;
+	ldlm_completion_callback	l_completion_ast;
 	/**
 	 * Lock blocking AST handler pointer.
 	 * It plays two roles:
@@ -644,51 +644,51 @@ struct ldlm_lock {
 	 * and then once more when the last user went away and the lock is
 	 * cancelled (could happen recursively).
 	 */
-	ldlm_blocking_callback	l_blocking_ast;
+	ldlm_blocking_callback		l_blocking_ast;
 	/**
 	 * Lock glimpse handler.
 	 * Glimpse handler is used to obtain LVB updates from a client by
 	 * server
 	 */
-	ldlm_glimpse_callback	l_glimpse_ast;
+	ldlm_glimpse_callback		l_glimpse_ast;
 
 	/**
 	 * Lock export.
 	 * This is a pointer to actual client export for locks that were granted
 	 * to clients. Used server-side.
 	 */
-	struct obd_export	*l_export;
+	struct obd_export		*l_export;
 	/**
 	 * Lock connection export.
 	 * Pointer to server export on a client.
 	 */
-	struct obd_export	*l_conn_export;
+	struct obd_export		*l_conn_export;
 
 	/**
 	 * Remote lock handle.
 	 * If the lock is remote, this is the handle of the other side lock
 	 * (l_handle)
 	 */
-	struct lustre_handle	l_remote_handle;
+	struct lustre_handle		l_remote_handle;
 
 	/**
 	 * Representation of private data specific for a lock type.
 	 * Examples are: extent range for extent lock or bitmask for ibits locks
 	 */
-	union ldlm_policy_data	l_policy_data;
+	union ldlm_policy_data		l_policy_data;
 
 	/**
 	 * Lock state flags. Protected by lr_lock.
 	 * \see lustre_dlm_flags.h where the bits are defined.
 	 */
-	u64			l_flags;
+	u64				l_flags;
 
 	/**
 	 * Lock r/w usage counters.
 	 * Protected by lr_lock.
 	 */
-	u32			l_readers;
-	u32			l_writers;
+	u32				l_readers;
+	u32				l_writers;
 	/**
 	 * If the lock is granted, a process sleeps on this waitq to learn when
 	 * it's no longer in use.  If the lock is not granted, a process sleeps
@@ -700,31 +700,31 @@ struct ldlm_lock {
 	 * Seconds. It will be updated if there is any activity related to
 	 * the lock, e.g. enqueue the lock or send blocking AST.
 	 */
-	time64_t		l_last_activity;
+	time64_t			l_last_activity;
 
 	/**
 	 * Time last used by e.g. being matched by lock match.
 	 * Jiffies. Should be converted to time if needed.
 	 */
-	unsigned long		l_last_used;
+	unsigned long			l_last_used;
 
 	/** Originally requested extent for the extent lock. */
-	struct ldlm_extent	l_req_extent;
+	struct ldlm_extent		l_req_extent;
 
 	/*
 	 * Client-side-only members.
 	 */
 
-	enum lvb_type	      l_lvb_type;
+	enum lvb_type			l_lvb_type;
 
 	/**
 	 * Temporary storage for a LVB received during an enqueue operation.
 	 */
-	u32			l_lvb_len;
-	void			*l_lvb_data;
+	u32				l_lvb_len;
+	void				*l_lvb_data;
 
 	/** Private storage for lock user. Opaque to LDLM. */
-	void			*l_ast_data;
+	void				*l_ast_data;
 
 	/*
 	 * Server-side-only members.
@@ -735,7 +735,7 @@ struct ldlm_lock {
 	 * Used by Commit on Share (COS) code. Currently only used for
 	 * inodebits locks on MDS.
 	 */
-	u64			l_client_cookie;
+	u64				l_client_cookie;
 
 	/**
 	 * List item for locks waiting for cancellation from clients.
@@ -753,10 +753,10 @@ struct ldlm_lock {
 	 * under this lock.
 	 * \see ost_rw_prolong_locks
 	 */
-	unsigned long		l_callback_timeout;
+	unsigned long			l_callback_timeout;
 
 	/** Local PID of process which created this lock. */
-	u32			l_pid;
+	u32				l_pid;
 
 	/**
 	 * Number of times blocking AST was sent for this lock.
@@ -764,7 +764,7 @@ struct ldlm_lock {
 	 * attempt to send blocking AST more than once, an assertion would be
 	 * hit. \see ldlm_work_bl_ast_lock
 	 */
-	int			l_bl_ast_run;
+	int				l_bl_ast_run;
 	/** List item ldlm_add_ast_work_item() for case of blocking ASTs. */
 	struct list_head		l_bl_ast;
 	/** List item ldlm_add_ast_work_item() for case of completion ASTs. */
@@ -776,7 +776,7 @@ struct ldlm_lock {
 	 * Pointer to a conflicting lock that caused blocking AST to be sent
 	 * for this lock
 	 */
-	struct ldlm_lock	*l_blocking_lock;
+	struct ldlm_lock		*l_blocking_lock;
 
 	/**
 	 * Protected by lr_lock, linkages to "skip lists".
@@ -786,15 +786,15 @@ struct ldlm_lock {
 	struct list_head		l_sl_policy;
 
 	/** Reference tracking structure to debug leaked locks. */
-	struct lu_ref		l_reference;
+	struct lu_ref			l_reference;
 #if LUSTRE_TRACKS_LOCK_EXP_REFS
 	/* Debugging stuff for bug 20498, for tracking export references. */
 	/** number of export references taken */
-	int			l_exp_refs_nr;
+	int				l_exp_refs_nr;
 	/** link all locks referencing one export */
 	struct list_head		l_exp_refs_link;
 	/** referenced export object */
-	struct obd_export	*l_exp_refs_target;
+	struct obd_export		*l_exp_refs_target;
 #endif
 };
 
@@ -810,19 +810,19 @@ struct ldlm_lock {
  * whether the locks are conflicting or not.
  */
 struct ldlm_resource {
-	struct ldlm_ns_bucket	*lr_ns_bucket;
+	struct ldlm_ns_bucket		*lr_ns_bucket;
 
 	/**
 	 * List item for list in namespace hash.
 	 * protected by ns_lock
 	 */
-	struct hlist_node	lr_hash;
+	struct hlist_node		lr_hash;
 
 	/** Reference count for this resource */
-	atomic_t		lr_refcount;
+	atomic_t			lr_refcount;
 
 	/** Spinlock to protect locks under this resource. */
-	spinlock_t		lr_lock;
+	spinlock_t			lr_lock;
 
 	/**
 	 * protected by lr_lock
@@ -838,30 +838,30 @@ struct ldlm_resource {
 	/** @} */
 
 	/** Resource name */
-	struct ldlm_res_id	lr_name;
+	struct ldlm_res_id		lr_name;
 
 	/**
 	 * Interval trees (only for extent locks) for all modes of this resource
 	 */
-	struct ldlm_interval_tree *lr_itree;
+	struct ldlm_interval_tree	*lr_itree;
 
 	/** Type of locks this resource can hold. Only one type per resource. */
-	enum ldlm_type		lr_type; /* LDLM_{PLAIN,EXTENT,FLOCK,IBITS} */
+	enum ldlm_type			lr_type; /* LDLM_{PLAIN,EXTENT,FLOCK,IBITS} */
 
 	/**
 	 * Server-side-only lock value block elements.
 	 * To serialize lvbo_init.
 	 */
-	int			lr_lvb_len;
-	struct mutex		lr_lvb_mutex;
+	int				lr_lvb_len;
+	struct mutex			lr_lvb_mutex;
 
 	/**
 	 * Associated inode, used only on client side.
 	 */
-	struct inode		*lr_lvb_inode;
+	struct inode			*lr_lvb_inode;
 
 	/** List of references to this resource. For debugging. */
-	struct lu_ref		lr_reference;
+	struct lu_ref			lr_reference;
 };
 
 static inline bool ldlm_has_layout(struct ldlm_lock *lock)
@@ -931,26 +931,26 @@ static inline int ldlm_lvbo_fill(struct ldlm_lock *lock, void *buf, int len)
 }
 
 struct ldlm_ast_work {
-	struct ldlm_lock      *w_lock;
-	int		    w_blocking;
-	struct ldlm_lock_desc  w_desc;
-	struct list_head	     w_list;
-	int		    w_flags;
-	void		  *w_data;
-	int		    w_datalen;
+	struct ldlm_lock       *w_lock;
+	int			w_blocking;
+	struct ldlm_lock_desc	w_desc;
+	struct list_head	w_list;
+	int			w_flags;
+	void		       *w_data;
+	int			w_datalen;
 };
 
 /**
  * Common ldlm_enqueue parameters
  */
 struct ldlm_enqueue_info {
-	enum ldlm_type	ei_type;  /** Type of the lock being enqueued. */
-	enum ldlm_mode	ei_mode;  /** Mode of the lock being enqueued. */
-	void *ei_cb_bl;  /** blocking lock callback */
-	void *ei_cb_cp;  /** lock completion callback */
-	void *ei_cb_gl;  /** lock glimpse callback */
-	void *ei_cbdata; /** Data to be passed into callbacks. */
-	unsigned int ei_enq_slave:1; /* whether enqueue slave stripes */
+	enum ldlm_type		ei_type;  /** Type of the lock being enqueued. */
+	enum ldlm_mode		ei_mode;  /** Mode of the lock being enqueued. */
+	void			*ei_cb_bl;  /** blocking lock callback */
+	void			*ei_cb_cp;  /** lock completion callback */
+	void			*ei_cb_gl;  /** lock glimpse callback */
+	void			*ei_cbdata; /** Data to be passed into callbacks. */
+	unsigned int		ei_enq_slave:1; /* whether enqueue slave stripes */
 };
 
 extern struct obd_ops ldlm_obd_ops;
@@ -971,12 +971,12 @@ struct ldlm_enqueue_info {
  * \see LDLM_DEBUG
  */
 #define ldlm_lock_debug(msgdata, mask, cdls, lock, fmt, a...) do {      \
-	CFS_CHECK_STACK(msgdata, mask, cdls);			   \
+	CFS_CHECK_STACK(msgdata, mask, cdls);				\
 									\
-	if (((mask) & D_CANTMASK) != 0 ||			       \
-	    ((libcfs_debug & (mask)) != 0 &&			    \
-	     (libcfs_subsystem_debug & DEBUG_SUBSYSTEM) != 0))	  \
-		_ldlm_lock_debug(lock, msgdata, fmt, ##a);	      \
+	if (((mask) & D_CANTMASK) != 0 ||				\
+	    ((libcfs_debug & (mask)) != 0 &&				\
+	     (libcfs_subsystem_debug & DEBUG_SUBSYSTEM) != 0))		\
+		_ldlm_lock_debug(lock, msgdata, fmt, ##a);		\
 } while (0)
 
 void _ldlm_lock_debug(struct ldlm_lock *lock,
@@ -987,9 +987,9 @@ void _ldlm_lock_debug(struct ldlm_lock *lock,
 /**
  * Rate-limited version of lock printing function.
  */
-#define LDLM_DEBUG_LIMIT(mask, lock, fmt, a...) do {			 \
-	static struct cfs_debug_limit_state _ldlm_cdls;			   \
-	LIBCFS_DEBUG_MSG_DATA_DECL(msgdata, mask, &_ldlm_cdls);	      \
+#define LDLM_DEBUG_LIMIT(mask, lock, fmt, a...) do {			\
+	static struct cfs_debug_limit_state _ldlm_cdls;			\
+	LIBCFS_DEBUG_MSG_DATA_DECL(msgdata, mask, &_ldlm_cdls);		\
 	ldlm_lock_debug(&msgdata, mask, &_ldlm_cdls, lock, "### " fmt, ##a);\
 } while (0)
 
@@ -997,14 +997,14 @@ void _ldlm_lock_debug(struct ldlm_lock *lock,
 #define LDLM_WARN(lock, fmt, a...)  LDLM_DEBUG_LIMIT(D_WARNING, lock, fmt, ## a)
 
 /** Non-rate-limited lock printing function for debugging purposes. */
-#define LDLM_DEBUG(lock, fmt, a...)   do {				  \
-	if (likely(lock)) {						    \
-		LIBCFS_DEBUG_MSG_DATA_DECL(msgdata, D_DLMTRACE, NULL);      \
-		ldlm_lock_debug(&msgdata, D_DLMTRACE, NULL, lock,	    \
-				"### " fmt, ##a);			    \
-	} else {							    \
-		LDLM_DEBUG_NOLOCK("no dlm lock: " fmt, ##a);		    \
-	}								    \
+#define LDLM_DEBUG(lock, fmt, a...)   do {				\
+	if (likely(lock)) {						\
+		LIBCFS_DEBUG_MSG_DATA_DECL(msgdata, D_DLMTRACE, NULL);	\
+		ldlm_lock_debug(&msgdata, D_DLMTRACE, NULL, lock,	\
+				"### " fmt, ##a);			\
+	} else {							\
+		LDLM_DEBUG_NOLOCK("no dlm lock: " fmt, ##a);		\
+	}								\
 } while (0)
 
 typedef int (*ldlm_processing_policy)(struct ldlm_lock *lock, u64 *flags,
@@ -1040,9 +1040,9 @@ int ldlm_resource_iterate(struct ldlm_namespace *, const struct ldlm_res_id *,
 u64 ldlm_extent_shift_kms(struct ldlm_lock *lock, u64 old_kms);
 
 struct ldlm_callback_suite {
-	ldlm_completion_callback lcs_completion;
-	ldlm_blocking_callback   lcs_blocking;
-	ldlm_glimpse_callback    lcs_glimpse;
+	ldlm_completion_callback	lcs_completion;
+	ldlm_blocking_callback		lcs_blocking;
+	ldlm_glimpse_callback		lcs_glimpse;
 };
 
 /* ldlm_lockd.c */
@@ -1105,41 +1105,41 @@ static inline int ldlm_res_lvbo_update(struct ldlm_resource *res,
  * Release a temporary lock reference obtained by ldlm_handle2lock() or
  * __ldlm_handle2lock().
  */
-#define LDLM_LOCK_PUT(lock)		     \
-do {					    \
-	LDLM_LOCK_REF_DEL(lock);		\
-	/*LDLM_DEBUG((lock), "put");*/	  \
-	ldlm_lock_put(lock);		    \
+#define LDLM_LOCK_PUT(lock)		\
+do {					\
+	LDLM_LOCK_REF_DEL(lock);	\
+	/*LDLM_DEBUG((lock), "put");*/	\
+	ldlm_lock_put(lock);		\
 } while (0)
 
 /**
  * Release a lock reference obtained by some other means (see
  * LDLM_LOCK_PUT()).
  */
-#define LDLM_LOCK_RELEASE(lock)		 \
-do {					    \
-	/*LDLM_DEBUG((lock), "put");*/	  \
-	ldlm_lock_put(lock);		    \
+#define LDLM_LOCK_RELEASE(lock)		\
+do {					\
+	/*LDLM_DEBUG((lock), "put");*/	\
+	ldlm_lock_put(lock);		\
 } while (0)
 
-#define LDLM_LOCK_GET(lock)		     \
-({					      \
-	ldlm_lock_get(lock);		    \
-	/*LDLM_DEBUG((lock), "get");*/	  \
-	lock;				   \
+#define LDLM_LOCK_GET(lock)		\
+({					\
+	ldlm_lock_get(lock);		\
+	/*LDLM_DEBUG((lock), "get");*/	\
+	lock;				\
 })
 
-#define ldlm_lock_list_put(head, member, count)		     \
-({								  \
-	struct ldlm_lock *_lock, *_next;			    \
-	int c = count;					      \
-	list_for_each_entry_safe(_lock, _next, head, member) {  \
-		if (c-- == 0)				       \
-			break;				      \
-		list_del_init(&_lock->member);		  \
-		LDLM_LOCK_RELEASE(_lock);			   \
-	}							   \
-	LASSERT(c <= 0);					    \
+#define ldlm_lock_list_put(head, member, count)			\
+({								\
+	struct ldlm_lock *_lock, *_next;			\
+	int c = count;						\
+	list_for_each_entry_safe(_lock, _next, head, member) {	\
+		if (c-- == 0)					\
+			break;					\
+		list_del_init(&_lock->member);			\
+		LDLM_LOCK_RELEASE(_lock);			\
+	}							\
+	LASSERT(c <= 0);					\
 })
 
 struct ldlm_lock *ldlm_lock_get(struct ldlm_lock *lock);
@@ -1198,12 +1198,12 @@ void ldlm_resource_add_lock(struct ldlm_resource *res,
 int ldlm_lock_change_resource(struct ldlm_namespace *, struct ldlm_lock *,
 			      const struct ldlm_res_id *);
 
-#define LDLM_RESOURCE_ADDREF(res) do {				  \
-	lu_ref_add_atomic(&(res)->lr_reference, __func__, current);  \
+#define LDLM_RESOURCE_ADDREF(res) do {					\
+	lu_ref_add_atomic(&(res)->lr_reference, __func__, current);	\
 } while (0)
 
-#define LDLM_RESOURCE_DELREF(res) do {				  \
-	lu_ref_del(&(res)->lr_reference, __func__, current);	  \
+#define LDLM_RESOURCE_DELREF(res) do {				\
+	lu_ref_del(&(res)->lr_reference, __func__, current);	\
 } while (0)
 
 /* ldlm_request.c */
diff --git a/drivers/staging/lustre/lustre/include/lustre_dlm_flags.h b/drivers/staging/lustre/lustre/include/lustre_dlm_flags.h
index 487ea17..abeb651 100644
--- a/drivers/staging/lustre/lustre/include/lustre_dlm_flags.h
+++ b/drivers/staging/lustre/lustre/include/lustre_dlm_flags.h
@@ -27,100 +27,100 @@
 #ifndef LDLM_ALL_FLAGS_MASK
 
 /** l_flags bits marked as "all_flags" bits */
-#define LDLM_FL_ALL_FLAGS_MASK          0x00FFFFFFC08F932FULL
+#define LDLM_FL_ALL_FLAGS_MASK		0x00FFFFFFC08F932FULL
 
 /** extent, mode, or resource changed */
-#define LDLM_FL_LOCK_CHANGED            0x0000000000000001ULL /* bit 0 */
-#define ldlm_is_lock_changed(_l)        LDLM_TEST_FLAG((_l), 1ULL <<  0)
-#define ldlm_set_lock_changed(_l)       LDLM_SET_FLAG((_l), 1ULL <<  0)
-#define ldlm_clear_lock_changed(_l)     LDLM_CLEAR_FLAG((_l), 1ULL <<  0)
+#define LDLM_FL_LOCK_CHANGED		0x0000000000000001ULL /* bit 0 */
+#define ldlm_is_lock_changed(_l)	LDLM_TEST_FLAG((_l), 1ULL <<  0)
+#define ldlm_set_lock_changed(_l)	LDLM_SET_FLAG((_l), 1ULL <<  0)
+#define ldlm_clear_lock_changed(_l)	LDLM_CLEAR_FLAG((_l), 1ULL <<  0)
 
 /**
  * Server placed lock on granted list, or a recovering client wants the
  * lock added to the granted list, no questions asked.
  */
-#define LDLM_FL_BLOCK_GRANTED           0x0000000000000002ULL /* bit 1 */
-#define ldlm_is_block_granted(_l)       LDLM_TEST_FLAG((_l), 1ULL <<  1)
-#define ldlm_set_block_granted(_l)      LDLM_SET_FLAG((_l), 1ULL <<  1)
-#define ldlm_clear_block_granted(_l)    LDLM_CLEAR_FLAG((_l), 1ULL <<  1)
+#define LDLM_FL_BLOCK_GRANTED		0x0000000000000002ULL /* bit 1 */
+#define ldlm_is_block_granted(_l)	LDLM_TEST_FLAG((_l), 1ULL <<  1)
+#define ldlm_set_block_granted(_l)	LDLM_SET_FLAG((_l), 1ULL <<  1)
+#define ldlm_clear_block_granted(_l)	LDLM_CLEAR_FLAG((_l), 1ULL <<  1)
 
 /**
  * Server placed lock on conv list, or a recovering client wants the lock
  * added to the conv list, no questions asked.
  */
-#define LDLM_FL_BLOCK_CONV              0x0000000000000004ULL /* bit 2 */
-#define ldlm_is_block_conv(_l)          LDLM_TEST_FLAG((_l), 1ULL <<  2)
-#define ldlm_set_block_conv(_l)         LDLM_SET_FLAG((_l), 1ULL <<  2)
-#define ldlm_clear_block_conv(_l)       LDLM_CLEAR_FLAG((_l), 1ULL <<  2)
+#define LDLM_FL_BLOCK_CONV		0x0000000000000004ULL /* bit 2 */
+#define ldlm_is_block_conv(_l)		LDLM_TEST_FLAG((_l), 1ULL <<  2)
+#define ldlm_set_block_conv(_l)		LDLM_SET_FLAG((_l), 1ULL <<  2)
+#define ldlm_clear_block_conv(_l)	LDLM_CLEAR_FLAG((_l), 1ULL <<  2)
 
 /**
  * Server placed lock on wait list, or a recovering client wants the lock
  * added to the wait list, no questions asked.
  */
-#define LDLM_FL_BLOCK_WAIT              0x0000000000000008ULL /* bit 3 */
-#define ldlm_is_block_wait(_l)          LDLM_TEST_FLAG((_l), 1ULL <<  3)
-#define ldlm_set_block_wait(_l)         LDLM_SET_FLAG((_l), 1ULL <<  3)
-#define ldlm_clear_block_wait(_l)       LDLM_CLEAR_FLAG((_l), 1ULL <<  3)
+#define LDLM_FL_BLOCK_WAIT		0x0000000000000008ULL /* bit 3 */
+#define ldlm_is_block_wait(_l)		LDLM_TEST_FLAG((_l), 1ULL <<  3)
+#define ldlm_set_block_wait(_l)		LDLM_SET_FLAG((_l), 1ULL <<  3)
+#define ldlm_clear_block_wait(_l)	LDLM_CLEAR_FLAG((_l), 1ULL <<  3)
 
 /** blocking or cancel packet was queued for sending. */
-#define LDLM_FL_AST_SENT                0x0000000000000020ULL /* bit 5 */
-#define ldlm_is_ast_sent(_l)            LDLM_TEST_FLAG((_l), 1ULL <<  5)
-#define ldlm_set_ast_sent(_l)           LDLM_SET_FLAG((_l), 1ULL <<  5)
-#define ldlm_clear_ast_sent(_l)         LDLM_CLEAR_FLAG((_l), 1ULL <<  5)
+#define LDLM_FL_AST_SENT		0x0000000000000020ULL /* bit 5 */
+#define ldlm_is_ast_sent(_l)		LDLM_TEST_FLAG((_l), 1ULL <<  5)
+#define ldlm_set_ast_sent(_l)		LDLM_SET_FLAG((_l), 1ULL <<  5)
+#define ldlm_clear_ast_sent(_l)		LDLM_CLEAR_FLAG((_l), 1ULL <<  5)
 
 /**
  * Lock is being replayed.  This could probably be implied by the fact that
  * one of BLOCK_{GRANTED,CONV,WAIT} is set, but that is pretty dangerous.
  */
-#define LDLM_FL_REPLAY                  0x0000000000000100ULL /* bit 8 */
-#define ldlm_is_replay(_l)              LDLM_TEST_FLAG((_l), 1ULL <<  8)
-#define ldlm_set_replay(_l)             LDLM_SET_FLAG((_l), 1ULL <<  8)
-#define ldlm_clear_replay(_l)           LDLM_CLEAR_FLAG((_l), 1ULL <<  8)
+#define LDLM_FL_REPLAY			0x0000000000000100ULL /* bit 8 */
+#define ldlm_is_replay(_l)		LDLM_TEST_FLAG((_l), 1ULL <<  8)
+#define ldlm_set_replay(_l)		LDLM_SET_FLAG((_l), 1ULL <<  8)
+#define ldlm_clear_replay(_l)		LDLM_CLEAR_FLAG((_l), 1ULL <<  8)
 
 /** Don't grant lock, just do intent. */
-#define LDLM_FL_INTENT_ONLY             0x0000000000000200ULL /* bit 9 */
-#define ldlm_is_intent_only(_l)         LDLM_TEST_FLAG((_l), 1ULL <<  9)
-#define ldlm_set_intent_only(_l)        LDLM_SET_FLAG((_l), 1ULL <<  9)
-#define ldlm_clear_intent_only(_l)      LDLM_CLEAR_FLAG((_l), 1ULL <<  9)
+#define LDLM_FL_INTENT_ONLY		0x0000000000000200ULL /* bit 9 */
+#define ldlm_is_intent_only(_l)		LDLM_TEST_FLAG((_l), 1ULL <<  9)
+#define ldlm_set_intent_only(_l)	LDLM_SET_FLAG((_l), 1ULL <<  9)
+#define ldlm_clear_intent_only(_l)	LDLM_CLEAR_FLAG((_l), 1ULL <<  9)
 
 /** lock request has intent */
-#define LDLM_FL_HAS_INTENT              0x0000000000001000ULL /* bit 12 */
-#define ldlm_is_has_intent(_l)          LDLM_TEST_FLAG((_l), 1ULL << 12)
-#define ldlm_set_has_intent(_l)         LDLM_SET_FLAG((_l), 1ULL << 12)
-#define ldlm_clear_has_intent(_l)       LDLM_CLEAR_FLAG((_l), 1ULL << 12)
+#define LDLM_FL_HAS_INTENT		0x0000000000001000ULL /* bit 12 */
+#define ldlm_is_has_intent(_l)		LDLM_TEST_FLAG((_l), 1ULL << 12)
+#define ldlm_set_has_intent(_l)		LDLM_SET_FLAG((_l), 1ULL << 12)
+#define ldlm_clear_has_intent(_l)	LDLM_CLEAR_FLAG((_l), 1ULL << 12)
 
 /** flock deadlock detected */
-#define LDLM_FL_FLOCK_DEADLOCK          0x0000000000008000ULL /* bit  15 */
-#define ldlm_is_flock_deadlock(_l)      LDLM_TEST_FLAG((_l), 1ULL << 15)
-#define ldlm_set_flock_deadlock(_l)     LDLM_SET_FLAG((_l), 1ULL << 15)
-#define ldlm_clear_flock_deadlock(_l)   LDLM_CLEAR_FLAG((_l), 1ULL << 15)
+#define LDLM_FL_FLOCK_DEADLOCK		0x0000000000008000ULL /* bit  15 */
+#define ldlm_is_flock_deadlock(_l)	LDLM_TEST_FLAG((_l), 1ULL << 15)
+#define ldlm_set_flock_deadlock(_l)	LDLM_SET_FLAG((_l), 1ULL << 15)
+#define ldlm_clear_flock_deadlock(_l)	LDLM_CLEAR_FLAG((_l), 1ULL << 15)
 
 /** discard (no writeback) (PW locks) or page retention (PR locks)) on cancel */
-#define LDLM_FL_DISCARD_DATA            0x0000000000010000ULL /* bit 16 */
-#define ldlm_is_discard_data(_l)        LDLM_TEST_FLAG((_l), 1ULL << 16)
-#define ldlm_set_discard_data(_l)       LDLM_SET_FLAG((_l), 1ULL << 16)
-#define ldlm_clear_discard_data(_l)     LDLM_CLEAR_FLAG((_l), 1ULL << 16)
+#define LDLM_FL_DISCARD_DATA		0x0000000000010000ULL /* bit 16 */
+#define ldlm_is_discard_data(_l)	LDLM_TEST_FLAG((_l), 1ULL << 16)
+#define ldlm_set_discard_data(_l)	LDLM_SET_FLAG((_l), 1ULL << 16)
+#define ldlm_clear_discard_data(_l)	LDLM_CLEAR_FLAG((_l), 1ULL << 16)
 
 /** Blocked by group lock - wait indefinitely */
-#define LDLM_FL_NO_TIMEOUT              0x0000000000020000ULL /* bit 17 */
-#define ldlm_is_no_timeout(_l)          LDLM_TEST_FLAG((_l), 1ULL << 17)
-#define ldlm_set_no_timeout(_l)         LDLM_SET_FLAG((_l), 1ULL << 17)
-#define ldlm_clear_no_timeout(_l)       LDLM_CLEAR_FLAG((_l), 1ULL << 17)
+#define LDLM_FL_NO_TIMEOUT		0x0000000000020000ULL /* bit 17 */
+#define ldlm_is_no_timeout(_l)		LDLM_TEST_FLAG((_l), 1ULL << 17)
+#define ldlm_set_no_timeout(_l)		LDLM_SET_FLAG((_l), 1ULL << 17)
+#define ldlm_clear_no_timeout(_l)	LDLM_CLEAR_FLAG((_l), 1ULL << 17)
 
 /**
  * Server told not to wait if blocked. For AGL, OST will not send glimpse
  * callback.
  */
-#define LDLM_FL_BLOCK_NOWAIT            0x0000000000040000ULL /* bit 18 */
-#define ldlm_is_block_nowait(_l)        LDLM_TEST_FLAG((_l), 1ULL << 18)
-#define ldlm_set_block_nowait(_l)       LDLM_SET_FLAG((_l), 1ULL << 18)
-#define ldlm_clear_block_nowait(_l)     LDLM_CLEAR_FLAG((_l), 1ULL << 18)
+#define LDLM_FL_BLOCK_NOWAIT		0x0000000000040000ULL /* bit 18 */
+#define ldlm_is_block_nowait(_l)	LDLM_TEST_FLAG((_l), 1ULL << 18)
+#define ldlm_set_block_nowait(_l)	LDLM_SET_FLAG((_l), 1ULL << 18)
+#define ldlm_clear_block_nowait(_l)	LDLM_CLEAR_FLAG((_l), 1ULL << 18)
 
 /** return blocking lock */
-#define LDLM_FL_TEST_LOCK               0x0000000000080000ULL /* bit 19 */
-#define ldlm_is_test_lock(_l)           LDLM_TEST_FLAG((_l), 1ULL << 19)
-#define ldlm_set_test_lock(_l)          LDLM_SET_FLAG((_l), 1ULL << 19)
-#define ldlm_clear_test_lock(_l)        LDLM_CLEAR_FLAG((_l), 1ULL << 19)
+#define LDLM_FL_TEST_LOCK		0x0000000000080000ULL /* bit 19 */
+#define ldlm_is_test_lock(_l)		LDLM_TEST_FLAG((_l), 1ULL << 19)
+#define ldlm_set_test_lock(_l)		LDLM_SET_FLAG((_l), 1ULL << 19)
+#define ldlm_clear_test_lock(_l)	LDLM_CLEAR_FLAG((_l), 1ULL << 19)
 
 /** match lock only */
 #define LDLM_FL_MATCH_LOCK		0x0000000000100000ULL /* bit  20 */
@@ -131,87 +131,87 @@
  * is for clients (like liblustre) that cannot be expected to reliably
  * response to blocking AST.
  */
-#define LDLM_FL_CANCEL_ON_BLOCK         0x0000000000800000ULL /* bit 23 */
-#define ldlm_is_cancel_on_block(_l)     LDLM_TEST_FLAG((_l), 1ULL << 23)
-#define ldlm_set_cancel_on_block(_l)    LDLM_SET_FLAG((_l), 1ULL << 23)
-#define ldlm_clear_cancel_on_block(_l)  LDLM_CLEAR_FLAG((_l), 1ULL << 23)
+#define LDLM_FL_CANCEL_ON_BLOCK		0x0000000000800000ULL /* bit 23 */
+#define ldlm_is_cancel_on_block(_l)	LDLM_TEST_FLAG((_l), 1ULL << 23)
+#define ldlm_set_cancel_on_block(_l)	LDLM_SET_FLAG((_l), 1ULL << 23)
+#define ldlm_clear_cancel_on_block(_l)	LDLM_CLEAR_FLAG((_l), 1ULL << 23)
 
 /**
  * measure lock contention and return -EUSERS if locking contention is high
  */
-#define LDLM_FL_DENY_ON_CONTENTION        0x0000000040000000ULL /* bit 30 */
-#define ldlm_is_deny_on_contention(_l)    LDLM_TEST_FLAG((_l), 1ULL << 30)
-#define ldlm_set_deny_on_contention(_l)   LDLM_SET_FLAG((_l), 1ULL << 30)
+#define LDLM_FL_DENY_ON_CONTENTION	  0x0000000040000000ULL /* bit 30 */
+#define ldlm_is_deny_on_contention(_l)	  LDLM_TEST_FLAG((_l), 1ULL << 30)
+#define ldlm_set_deny_on_contention(_l)	  LDLM_SET_FLAG((_l), 1ULL << 30)
 #define ldlm_clear_deny_on_contention(_l) LDLM_CLEAR_FLAG((_l), 1ULL << 30)
 
 /**
  * These are flags that are mapped into the flags and ASTs of blocking
  * locks Add FL_DISCARD to blocking ASTs
  */
-#define LDLM_FL_AST_DISCARD_DATA        0x0000000080000000ULL /* bit 31 */
-#define ldlm_is_ast_discard_data(_l)    LDLM_TEST_FLAG((_l), 1ULL << 31)
-#define ldlm_set_ast_discard_data(_l)   LDLM_SET_FLAG((_l), 1ULL << 31)
-#define ldlm_clear_ast_discard_data(_l) LDLM_CLEAR_FLAG((_l), 1ULL << 31)
+#define LDLM_FL_AST_DISCARD_DATA	0x0000000080000000ULL /* bit 31 */
+#define ldlm_is_ast_discard_data(_l)	LDLM_TEST_FLAG((_l), 1ULL << 31)
+#define ldlm_set_ast_discard_data(_l)	LDLM_SET_FLAG((_l), 1ULL << 31)
+#define ldlm_clear_ast_discard_data(_l)	LDLM_CLEAR_FLAG((_l), 1ULL << 31)
 
 /**
  * Used for marking lock as a target for -EINTR while cp_ast sleep emulation
  * + race with upcoming bl_ast.
  */
-#define LDLM_FL_FAIL_LOC                0x0000000100000000ULL /* bit 32 */
-#define ldlm_is_fail_loc(_l)            LDLM_TEST_FLAG((_l), 1ULL << 32)
-#define ldlm_set_fail_loc(_l)           LDLM_SET_FLAG((_l), 1ULL << 32)
-#define ldlm_clear_fail_loc(_l)         LDLM_CLEAR_FLAG((_l), 1ULL << 32)
+#define LDLM_FL_FAIL_LOC		0x0000000100000000ULL /* bit 32 */
+#define ldlm_is_fail_loc(_l)		LDLM_TEST_FLAG((_l), 1ULL << 32)
+#define ldlm_set_fail_loc(_l)		LDLM_SET_FLAG((_l), 1ULL << 32)
+#define ldlm_clear_fail_loc(_l)		LDLM_CLEAR_FLAG((_l), 1ULL << 32)
 
 /**
  * Used while processing the unused list to know that we have already
  * handled this lock and decided to skip it.
  */
-#define LDLM_FL_SKIPPED                 0x0000000200000000ULL /* bit 33 */
-#define ldlm_is_skipped(_l)             LDLM_TEST_FLAG((_l), 1ULL << 33)
-#define ldlm_set_skipped(_l)            LDLM_SET_FLAG((_l), 1ULL << 33)
-#define ldlm_clear_skipped(_l)          LDLM_CLEAR_FLAG((_l), 1ULL << 33)
+#define LDLM_FL_SKIPPED			0x0000000200000000ULL /* bit 33 */
+#define ldlm_is_skipped(_l)		LDLM_TEST_FLAG((_l), 1ULL << 33)
+#define ldlm_set_skipped(_l)		LDLM_SET_FLAG((_l), 1ULL << 33)
+#define ldlm_clear_skipped(_l)		LDLM_CLEAR_FLAG((_l), 1ULL << 33)
 
 /** this lock is being destroyed */
-#define LDLM_FL_CBPENDING               0x0000000400000000ULL /* bit 34 */
-#define ldlm_is_cbpending(_l)           LDLM_TEST_FLAG((_l), 1ULL << 34)
-#define ldlm_set_cbpending(_l)          LDLM_SET_FLAG((_l), 1ULL << 34)
-#define ldlm_clear_cbpending(_l)        LDLM_CLEAR_FLAG((_l), 1ULL << 34)
+#define LDLM_FL_CBPENDING		0x0000000400000000ULL /* bit 34 */
+#define ldlm_is_cbpending(_l)		LDLM_TEST_FLAG((_l), 1ULL << 34)
+#define ldlm_set_cbpending(_l)		LDLM_SET_FLAG((_l), 1ULL << 34)
+#define ldlm_clear_cbpending(_l)	LDLM_CLEAR_FLAG((_l), 1ULL << 34)
 
 /** not a real flag, not saved in lock */
-#define LDLM_FL_WAIT_NOREPROC           0x0000000800000000ULL /* bit 35 */
-#define ldlm_is_wait_noreproc(_l)       LDLM_TEST_FLAG((_l), 1ULL << 35)
-#define ldlm_set_wait_noreproc(_l)      LDLM_SET_FLAG((_l), 1ULL << 35)
-#define ldlm_clear_wait_noreproc(_l)    LDLM_CLEAR_FLAG((_l), 1ULL << 35)
+#define LDLM_FL_WAIT_NOREPROC		0x0000000800000000ULL /* bit 35 */
+#define ldlm_is_wait_noreproc(_l)	LDLM_TEST_FLAG((_l), 1ULL << 35)
+#define ldlm_set_wait_noreproc(_l)	LDLM_SET_FLAG((_l), 1ULL << 35)
+#define ldlm_clear_wait_noreproc(_l)	LDLM_CLEAR_FLAG((_l), 1ULL << 35)
 
 /** cancellation callback already run */
-#define LDLM_FL_CANCEL                  0x0000001000000000ULL /* bit 36 */
-#define ldlm_is_cancel(_l)              LDLM_TEST_FLAG((_l), 1ULL << 36)
-#define ldlm_set_cancel(_l)             LDLM_SET_FLAG((_l), 1ULL << 36)
-#define ldlm_clear_cancel(_l)           LDLM_CLEAR_FLAG((_l), 1ULL << 36)
+#define LDLM_FL_CANCEL			0x0000001000000000ULL /* bit 36 */
+#define ldlm_is_cancel(_l)		LDLM_TEST_FLAG((_l), 1ULL << 36)
+#define ldlm_set_cancel(_l)		LDLM_SET_FLAG((_l), 1ULL << 36)
+#define ldlm_clear_cancel(_l)		LDLM_CLEAR_FLAG((_l), 1ULL << 36)
 
 /** whatever it might mean -- never transmitted? */
-#define LDLM_FL_LOCAL_ONLY              0x0000002000000000ULL /* bit 37 */
-#define ldlm_is_local_only(_l)          LDLM_TEST_FLAG((_l), 1ULL << 37)
-#define ldlm_set_local_only(_l)         LDLM_SET_FLAG((_l), 1ULL << 37)
-#define ldlm_clear_local_only(_l)       LDLM_CLEAR_FLAG((_l), 1ULL << 37)
+#define LDLM_FL_LOCAL_ONLY		0x0000002000000000ULL /* bit 37 */
+#define ldlm_is_local_only(_l)		LDLM_TEST_FLAG((_l), 1ULL << 37)
+#define ldlm_set_local_only(_l)		LDLM_SET_FLAG((_l), 1ULL << 37)
+#define ldlm_clear_local_only(_l)	LDLM_CLEAR_FLAG((_l), 1ULL << 37)
 
 /** don't run the cancel callback under ldlm_cli_cancel_unused */
-#define LDLM_FL_FAILED                  0x0000004000000000ULL /* bit 38 */
-#define ldlm_is_failed(_l)              LDLM_TEST_FLAG((_l), 1ULL << 38)
-#define ldlm_set_failed(_l)             LDLM_SET_FLAG((_l), 1ULL << 38)
-#define ldlm_clear_failed(_l)           LDLM_CLEAR_FLAG((_l), 1ULL << 38)
+#define LDLM_FL_FAILED			0x0000004000000000ULL /* bit 38 */
+#define ldlm_is_failed(_l)		LDLM_TEST_FLAG((_l), 1ULL << 38)
+#define ldlm_set_failed(_l)		LDLM_SET_FLAG((_l), 1ULL << 38)
+#define ldlm_clear_failed(_l)		LDLM_CLEAR_FLAG((_l), 1ULL << 38)
 
 /** lock cancel has already been sent */
-#define LDLM_FL_CANCELING               0x0000008000000000ULL /* bit 39 */
-#define ldlm_is_canceling(_l)           LDLM_TEST_FLAG((_l), 1ULL << 39)
-#define ldlm_set_canceling(_l)          LDLM_SET_FLAG((_l), 1ULL << 39)
-#define ldlm_clear_canceling(_l)        LDLM_CLEAR_FLAG((_l), 1ULL << 39)
+#define LDLM_FL_CANCELING		0x0000008000000000ULL /* bit 39 */
+#define ldlm_is_canceling(_l)		LDLM_TEST_FLAG((_l), 1ULL << 39)
+#define ldlm_set_canceling(_l)		LDLM_SET_FLAG((_l), 1ULL << 39)
+#define ldlm_clear_canceling(_l)	LDLM_CLEAR_FLAG((_l), 1ULL << 39)
 
 /** local lock (ie, no srv/cli split) */
-#define LDLM_FL_LOCAL                   0x0000010000000000ULL /* bit 40 */
-#define ldlm_is_local(_l)               LDLM_TEST_FLAG((_l), 1ULL << 40)
-#define ldlm_set_local(_l)              LDLM_SET_FLAG((_l), 1ULL << 40)
-#define ldlm_clear_local(_l)            LDLM_CLEAR_FLAG((_l), 1ULL << 40)
+#define LDLM_FL_LOCAL			0x0000010000000000ULL /* bit 40 */
+#define ldlm_is_local(_l)		LDLM_TEST_FLAG((_l), 1ULL << 40)
+#define ldlm_set_local(_l)		LDLM_SET_FLAG((_l), 1ULL << 40)
+#define ldlm_clear_local(_l)		LDLM_CLEAR_FLAG((_l), 1ULL << 40)
 
 /**
  * XXX FIXME: This is being added to b_size as a low-risk fix to the
@@ -226,10 +226,10 @@
  * That change is pretty high-risk, though, and would need a lot more
  * testing.
  */
-#define LDLM_FL_LVB_READY               0x0000020000000000ULL /* bit 41 */
-#define ldlm_is_lvb_ready(_l)           LDLM_TEST_FLAG((_l), 1ULL << 41)
-#define ldlm_set_lvb_ready(_l)          LDLM_SET_FLAG((_l), 1ULL << 41)
-#define ldlm_clear_lvb_ready(_l)        LDLM_CLEAR_FLAG((_l), 1ULL << 41)
+#define LDLM_FL_LVB_READY		0x0000020000000000ULL /* bit 41 */
+#define ldlm_is_lvb_ready(_l)		LDLM_TEST_FLAG((_l), 1ULL << 41)
+#define ldlm_set_lvb_ready(_l)		LDLM_SET_FLAG((_l), 1ULL << 41)
+#define ldlm_clear_lvb_ready(_l)	LDLM_CLEAR_FLAG((_l), 1ULL << 41)
 
 /**
  * A lock contributes to the known minimum size (KMS) calculation until it
@@ -239,31 +239,31 @@
  * to know to exclude each other's locks from the calculation as they walk
  * the granted list.
  */
-#define LDLM_FL_KMS_IGNORE              0x0000040000000000ULL /* bit 42 */
-#define ldlm_is_kms_ignore(_l)          LDLM_TEST_FLAG((_l), 1ULL << 42)
-#define ldlm_set_kms_ignore(_l)         LDLM_SET_FLAG((_l), 1ULL << 42)
-#define ldlm_clear_kms_ignore(_l)       LDLM_CLEAR_FLAG((_l), 1ULL << 42)
+#define LDLM_FL_KMS_IGNORE		0x0000040000000000ULL /* bit 42 */
+#define ldlm_is_kms_ignore(_l)		LDLM_TEST_FLAG((_l), 1ULL << 42)
+#define ldlm_set_kms_ignore(_l)		LDLM_SET_FLAG((_l), 1ULL << 42)
+#define ldlm_clear_kms_ignore(_l)	LDLM_CLEAR_FLAG((_l), 1ULL << 42)
 
 /** completion AST to be executed */
-#define LDLM_FL_CP_REQD                 0x0000080000000000ULL /* bit 43 */
-#define ldlm_is_cp_reqd(_l)             LDLM_TEST_FLAG((_l), 1ULL << 43)
-#define ldlm_set_cp_reqd(_l)            LDLM_SET_FLAG((_l), 1ULL << 43)
-#define ldlm_clear_cp_reqd(_l)          LDLM_CLEAR_FLAG((_l), 1ULL << 43)
+#define LDLM_FL_CP_REQD			0x0000080000000000ULL /* bit 43 */
+#define ldlm_is_cp_reqd(_l)		LDLM_TEST_FLAG((_l), 1ULL << 43)
+#define ldlm_set_cp_reqd(_l)		LDLM_SET_FLAG((_l), 1ULL << 43)
+#define ldlm_clear_cp_reqd(_l)		LDLM_CLEAR_FLAG((_l), 1ULL << 43)
 
 /** cleanup_resource has already handled the lock */
-#define LDLM_FL_CLEANED                 0x0000100000000000ULL /* bit 44 */
-#define ldlm_is_cleaned(_l)             LDLM_TEST_FLAG((_l), 1ULL << 44)
-#define ldlm_set_cleaned(_l)            LDLM_SET_FLAG((_l), 1ULL << 44)
-#define ldlm_clear_cleaned(_l)          LDLM_CLEAR_FLAG((_l), 1ULL << 44)
+#define LDLM_FL_CLEANED			0x0000100000000000ULL /* bit 44 */
+#define ldlm_is_cleaned(_l)		LDLM_TEST_FLAG((_l), 1ULL << 44)
+#define ldlm_set_cleaned(_l)		LDLM_SET_FLAG((_l), 1ULL << 44)
+#define ldlm_clear_cleaned(_l)		LDLM_CLEAR_FLAG((_l), 1ULL << 44)
 
 /**
  * optimization hint: LDLM can run blocking callback from current context
  * w/o involving separate thread. in order to decrease cs rate
  */
-#define LDLM_FL_ATOMIC_CB               0x0000200000000000ULL /* bit 45 */
-#define ldlm_is_atomic_cb(_l)           LDLM_TEST_FLAG((_l), 1ULL << 45)
-#define ldlm_set_atomic_cb(_l)          LDLM_SET_FLAG((_l), 1ULL << 45)
-#define ldlm_clear_atomic_cb(_l)        LDLM_CLEAR_FLAG((_l), 1ULL << 45)
+#define LDLM_FL_ATOMIC_CB		0x0000200000000000ULL /* bit 45 */
+#define ldlm_is_atomic_cb(_l)		LDLM_TEST_FLAG((_l), 1ULL << 45)
+#define ldlm_set_atomic_cb(_l)		LDLM_SET_FLAG((_l), 1ULL << 45)
+#define ldlm_clear_atomic_cb(_l)	LDLM_CLEAR_FLAG((_l), 1ULL << 45)
 
 /**
  * It may happen that a client initiates two operations, e.g. unlink and
@@ -273,10 +273,10 @@
  * the first operation. LDLM_FL_BL_AST is set by ldlm_callback_handler() in
  * the lock to prevent the Early Lock Cancel (ELC) code from cancelling it.
  */
-#define LDLM_FL_BL_AST                  0x0000400000000000ULL /* bit 46 */
-#define ldlm_is_bl_ast(_l)              LDLM_TEST_FLAG((_l), 1ULL << 46)
-#define ldlm_set_bl_ast(_l)             LDLM_SET_FLAG((_l), 1ULL << 46)
-#define ldlm_clear_bl_ast(_l)           LDLM_CLEAR_FLAG((_l), 1ULL << 46)
+#define LDLM_FL_BL_AST			0x0000400000000000ULL /* bit 46 */
+#define ldlm_is_bl_ast(_l)		LDLM_TEST_FLAG((_l), 1ULL << 46)
+#define ldlm_set_bl_ast(_l)		LDLM_SET_FLAG((_l), 1ULL << 46)
+#define ldlm_clear_bl_ast(_l)		LDLM_CLEAR_FLAG((_l), 1ULL << 46)
 
 /**
  * Set by ldlm_cancel_callback() when lock cache is dropped to let
@@ -284,30 +284,30 @@
  * ELC RPC is already prepared and is waiting for rpc_lock, too late to
  * send a separate CANCEL RPC.
  */
-#define LDLM_FL_BL_DONE                 0x0000800000000000ULL /* bit 47 */
-#define ldlm_is_bl_done(_l)             LDLM_TEST_FLAG((_l), 1ULL << 47)
-#define ldlm_set_bl_done(_l)            LDLM_SET_FLAG((_l), 1ULL << 47)
-#define ldlm_clear_bl_done(_l)          LDLM_CLEAR_FLAG((_l), 1ULL << 47)
+#define LDLM_FL_BL_DONE			0x0000800000000000ULL /* bit 47 */
+#define ldlm_is_bl_done(_l)		LDLM_TEST_FLAG((_l), 1ULL << 47)
+#define ldlm_set_bl_done(_l)		LDLM_SET_FLAG((_l), 1ULL << 47)
+#define ldlm_clear_bl_done(_l)		LDLM_CLEAR_FLAG((_l), 1ULL << 47)
 
 /**
  * Don't put lock into the LRU list, so that it is not canceled due
  * to aging.  Used by MGC locks, they are cancelled only@unmount or
  * by callback.
  */
-#define LDLM_FL_NO_LRU                  0x0001000000000000ULL /* bit 48 */
-#define ldlm_is_no_lru(_l)              LDLM_TEST_FLAG((_l), 1ULL << 48)
-#define ldlm_set_no_lru(_l)             LDLM_SET_FLAG((_l), 1ULL << 48)
-#define ldlm_clear_no_lru(_l)           LDLM_CLEAR_FLAG((_l), 1ULL << 48)
+#define LDLM_FL_NO_LRU			0x0001000000000000ULL /* bit 48 */
+#define ldlm_is_no_lru(_l)		LDLM_TEST_FLAG((_l), 1ULL << 48)
+#define ldlm_set_no_lru(_l)		LDLM_SET_FLAG((_l), 1ULL << 48)
+#define ldlm_clear_no_lru(_l)		LDLM_CLEAR_FLAG((_l), 1ULL << 48)
 
 /**
  * Set for locks that failed and where the server has been notified.
  *
  * Protected by lock and resource locks.
  */
-#define LDLM_FL_FAIL_NOTIFIED           0x0002000000000000ULL /* bit 49 */
-#define ldlm_is_fail_notified(_l)       LDLM_TEST_FLAG((_l), 1ULL << 49)
-#define ldlm_set_fail_notified(_l)      LDLM_SET_FLAG((_l), 1ULL << 49)
-#define ldlm_clear_fail_notified(_l)    LDLM_CLEAR_FLAG((_l), 1ULL << 49)
+#define LDLM_FL_FAIL_NOTIFIED		0x0002000000000000ULL /* bit 49 */
+#define ldlm_is_fail_notified(_l)	LDLM_TEST_FLAG((_l), 1ULL << 49)
+#define ldlm_set_fail_notified(_l)	LDLM_SET_FLAG((_l), 1ULL << 49)
+#define ldlm_clear_fail_notified(_l)	LDLM_CLEAR_FLAG((_l), 1ULL << 49)
 
 /**
  * Set for locks that were removed from class hash table and will
@@ -316,16 +316,16 @@
  *
  * Protected by lock and resource locks.
  */
-#define LDLM_FL_DESTROYED               0x0004000000000000ULL /* bit 50 */
-#define ldlm_is_destroyed(_l)           LDLM_TEST_FLAG((_l), 1ULL << 50)
-#define ldlm_set_destroyed(_l)          LDLM_SET_FLAG((_l), 1ULL << 50)
-#define ldlm_clear_destroyed(_l)        LDLM_CLEAR_FLAG((_l), 1ULL << 50)
+#define LDLM_FL_DESTROYED		0x0004000000000000ULL /* bit 50 */
+#define ldlm_is_destroyed(_l)		LDLM_TEST_FLAG((_l), 1ULL << 50)
+#define ldlm_set_destroyed(_l)		LDLM_SET_FLAG((_l), 1ULL << 50)
+#define ldlm_clear_destroyed(_l)	LDLM_CLEAR_FLAG((_l), 1ULL << 50)
 
 /** flag whether this is a server namespace lock */
-#define LDLM_FL_SERVER_LOCK             0x0008000000000000ULL /* bit 51 */
-#define ldlm_is_server_lock(_l)         LDLM_TEST_FLAG((_l), 1ULL << 51)
-#define ldlm_set_server_lock(_l)        LDLM_SET_FLAG((_l), 1ULL << 51)
-#define ldlm_clear_server_lock(_l)      LDLM_CLEAR_FLAG((_l), 1ULL << 51)
+#define LDLM_FL_SERVER_LOCK		0x0008000000000000ULL /* bit 51 */
+#define ldlm_is_server_lock(_l)		LDLM_TEST_FLAG((_l), 1ULL << 51)
+#define ldlm_set_server_lock(_l)	LDLM_SET_FLAG((_l), 1ULL << 51)
+#define ldlm_clear_server_lock(_l)	LDLM_CLEAR_FLAG((_l), 1ULL << 51)
 
 /**
  * It's set in lock_res_and_lock() and unset in unlock_res_and_lock().
@@ -335,10 +335,10 @@
  * because it works only for SMP so user needs to add extra macros like
  * LASSERT_SPIN_LOCKED for uniprocessor kernels.
  */
-#define LDLM_FL_RES_LOCKED              0x0010000000000000ULL /* bit 52 */
-#define ldlm_is_res_locked(_l)          LDLM_TEST_FLAG((_l), 1ULL << 52)
-#define ldlm_set_res_locked(_l)         LDLM_SET_FLAG((_l), 1ULL << 52)
-#define ldlm_clear_res_locked(_l)       LDLM_CLEAR_FLAG((_l), 1ULL << 52)
+#define LDLM_FL_RES_LOCKED		0x0010000000000000ULL /* bit 52 */
+#define ldlm_is_res_locked(_l)		LDLM_TEST_FLAG((_l), 1ULL << 52)
+#define ldlm_set_res_locked(_l)		LDLM_SET_FLAG((_l), 1ULL << 52)
+#define ldlm_clear_res_locked(_l)	LDLM_CLEAR_FLAG((_l), 1ULL << 52)
 
 /**
  * It's set once we call ldlm_add_waiting_lock_res_locked() to start the
@@ -346,22 +346,22 @@
  *
  * Protected by lock and resource locks.
  */
-#define LDLM_FL_WAITED                  0x0020000000000000ULL /* bit 53 */
-#define ldlm_is_waited(_l)              LDLM_TEST_FLAG((_l), 1ULL << 53)
-#define ldlm_set_waited(_l)             LDLM_SET_FLAG((_l), 1ULL << 53)
-#define ldlm_clear_waited(_l)           LDLM_CLEAR_FLAG((_l), 1ULL << 53)
+#define LDLM_FL_WAITED			0x0020000000000000ULL /* bit 53 */
+#define ldlm_is_waited(_l)		LDLM_TEST_FLAG((_l), 1ULL << 53)
+#define ldlm_set_waited(_l)		LDLM_SET_FLAG((_l), 1ULL << 53)
+#define ldlm_clear_waited(_l)		LDLM_CLEAR_FLAG((_l), 1ULL << 53)
 
 /** Flag whether this is a server namespace lock. */
-#define LDLM_FL_NS_SRV                  0x0040000000000000ULL /* bit 54 */
-#define ldlm_is_ns_srv(_l)              LDLM_TEST_FLAG((_l), 1ULL << 54)
-#define ldlm_set_ns_srv(_l)             LDLM_SET_FLAG((_l), 1ULL << 54)
-#define ldlm_clear_ns_srv(_l)           LDLM_CLEAR_FLAG((_l), 1ULL << 54)
+#define LDLM_FL_NS_SRV			0x0040000000000000ULL /* bit 54 */
+#define ldlm_is_ns_srv(_l)		LDLM_TEST_FLAG((_l), 1ULL << 54)
+#define ldlm_set_ns_srv(_l)		LDLM_SET_FLAG((_l), 1ULL << 54)
+#define ldlm_clear_ns_srv(_l)		LDLM_CLEAR_FLAG((_l), 1ULL << 54)
 
 /** Flag whether this lock can be reused. Used by exclusive open. */
-#define LDLM_FL_EXCL                    0x0080000000000000ULL /* bit  55 */
-#define ldlm_is_excl(_l)                LDLM_TEST_FLAG((_l), 1ULL << 55)
-#define ldlm_set_excl(_l)               LDLM_SET_FLAG((_l), 1ULL << 55)
-#define ldlm_clear_excl(_l)             LDLM_CLEAR_FLAG((_l), 1ULL << 55)
+#define LDLM_FL_EXCL			0x0080000000000000ULL /* bit  55 */
+#define ldlm_is_excl(_l)		LDLM_TEST_FLAG((_l), 1ULL << 55)
+#define ldlm_set_excl(_l)		LDLM_SET_FLAG((_l), 1ULL << 55)
+#define ldlm_clear_excl(_l)		LDLM_CLEAR_FLAG((_l), 1ULL << 55)
 
 /** l_flags bits marked as "ast" bits */
 #define LDLM_FL_AST_MASK		(LDLM_FL_FLOCK_DEADLOCK		|\
@@ -385,16 +385,16 @@
 					 LDLM_FL_TEST_LOCK)
 
 /** test for ldlm_lock flag bit set */
-#define LDLM_TEST_FLAG(_l, _b)        (((_l)->l_flags & (_b)) != 0)
+#define LDLM_TEST_FLAG(_l, _b)		(((_l)->l_flags & (_b)) != 0)
 
 /** multi-bit test: are any of mask bits set? */
 #define LDLM_HAVE_MASK(_l, _m)		((_l)->l_flags & LDLM_FL_##_m##_MASK)
 
 /** set a ldlm_lock flag bit */
-#define LDLM_SET_FLAG(_l, _b)         ((_l)->l_flags |= (_b))
+#define LDLM_SET_FLAG(_l, _b)		((_l)->l_flags |= (_b))
 
 /** clear a ldlm_lock flag bit */
-#define LDLM_CLEAR_FLAG(_l, _b)       ((_l)->l_flags &= ~(_b))
+#define LDLM_CLEAR_FLAG(_l, _b)		((_l)->l_flags &= ~(_b))
 
 /** @} subgroup */
 /** @} group */
-- 
1.8.3.1
