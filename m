From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Wed, 24 Feb 2016 22:00:25 -0500
Subject: [lustre-devel] [PATCH v2 42/84] staging/lustre/include: Adjust
	comment style
In-Reply-To: <1456369267-904461-1-git-send-email-green@linuxhacker.ru>
References: <1456369267-904461-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1456369267-904461-43-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

This fixes most of the
"Block comments use a trailing */ on a separate line" checkpatch
warnings, also some slight reformats of structures or comments
at places.

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/include/cl_object.h  | 69 ++++++++++++++--------
 drivers/staging/lustre/lustre/include/lclient.h    |  3 +-
 .../staging/lustre/lustre/include/lprocfs_status.h | 13 ++--
 drivers/staging/lustre/lustre/include/lu_object.h  |  6 +-
 .../lustre/lustre/include/lustre/ll_fiemap.h       | 63 ++++++++++++--------
 .../lustre/lustre/include/lustre/lustre_user.h     | 52 ++++++++++------
 drivers/staging/lustre/lustre/include/lustre_cfg.h |  9 ++-
 .../staging/lustre/lustre/include/lustre_disk.h    | 27 +++++----
 drivers/staging/lustre/lustre/include/lustre_dlm.h | 29 +++++----
 .../lustre/lustre/include/lustre_dlm_flags.h       | 51 ++++++++++------
 .../staging/lustre/lustre/include/lustre_export.h  |  3 +-
 drivers/staging/lustre/lustre/include/lustre_fid.h | 18 ++++--
 drivers/staging/lustre/lustre/include/lustre_fld.h | 33 ++++-------
 .../staging/lustre/lustre/include/lustre_handles.h |  3 +-
 .../staging/lustre/lustre/include/lustre_import.h  |  3 +-
 drivers/staging/lustre/lustre/include/lustre_lib.h |  3 +-
 drivers/staging/lustre/lustre/include/lustre_log.h |  3 +-
 drivers/staging/lustre/lustre/include/lustre_mdc.h |  6 +-
 drivers/staging/lustre/lustre/include/lustre_net.h | 39 +++++++-----
 drivers/staging/lustre/lustre/include/obd.h        | 58 ++++++++++--------
 drivers/staging/lustre/lustre/include/obd_cksum.h  |  9 ++-
 drivers/staging/lustre/lustre/include/obd_class.h  | 50 ++++++++++------
 .../staging/lustre/lustre/include/obd_support.h    | 18 +++---
 23 files changed, 352 insertions(+), 216 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/cl_object.h b/drivers/staging/lustre/lustre/include/cl_object.h
index 373e772..2a77ea2f8 100644
--- a/drivers/staging/lustre/lustre/include/cl_object.h
+++ b/drivers/staging/lustre/lustre/include/cl_object.h
@@ -157,7 +157,8 @@ struct cl_device {
 };
 
 /** \addtogroup cl_object cl_object
- * @{ */
+ * @{
+ */
 /**
  * "Data attributes" of cl_object. Data attributes can be updated
  * independently for a sub-object, and top-object's attributes are calculated
@@ -288,13 +289,14 @@ struct cl_object_conf {
 
 enum {
 	/** configure layout, set up a new stripe, must be called while
-	 * holding layout lock. */
+	 * holding layout lock.
+	 */
 	OBJECT_CONF_SET = 0,
 	/** invalidate the current stripe configuration due to losing
-	 * layout lock. */
+	 * layout lock.
+	 */
 	OBJECT_CONF_INVALIDATE = 1,
-	/** wait for old layout to go away so that new layout can be
-	 * set up. */
+	/** wait for old layout to go away so that new layout can be set up. */
 	OBJECT_CONF_WAIT = 2
 };
 
@@ -393,7 +395,8 @@ struct cl_object_operations {
  */
 struct cl_object_header {
 	/** Standard lu_object_header. cl_object::co_lu::lo_header points
-	 * here. */
+	 * here.
+	 */
 	struct lu_object_header  coh_lu;
 	/** \name locks
 	 * \todo XXX move locks below to the separate cache-lines, they are
@@ -464,7 +467,8 @@ struct cl_object_header {
 #define CL_PAGE_EOF ((pgoff_t)~0ull)
 
 /** \addtogroup cl_page cl_page
- * @{ */
+ * @{
+ */
 
 /** \struct cl_page
  * Layered client page.
@@ -687,12 +691,14 @@ enum cl_page_state {
 
 enum cl_page_type {
 	/** Host page, the page is from the host inode which the cl_page
-	 * belongs to. */
+	 * belongs to.
+	 */
 	CPT_CACHEABLE = 1,
 
 	/** Transient page, the transient cl_page is used to bind a cl_page
 	 *  to vmpage which is not belonging to the same object of cl_page.
-	 *  it is used in DirectIO, lockless IO and liblustre. */
+	 *  it is used in DirectIO, lockless IO and liblustre.
+	 */
 	CPT_TRANSIENT,
 };
 
@@ -728,7 +734,8 @@ struct cl_page {
 	/** Parent page, NULL for top-level page. Immutable after creation. */
 	struct cl_page	  *cp_parent;
 	/** Lower-layer page. NULL for bottommost page. Immutable after
-	 * creation. */
+	 * creation.
+	 */
 	struct cl_page	  *cp_child;
 	/**
 	 * Page state. This field is const to avoid accidental update, it is
@@ -1126,7 +1133,8 @@ static inline int __page_in_use(const struct cl_page *page, int refc)
 /** @} cl_page */
 
 /** \addtogroup cl_lock cl_lock
- * @{ */
+ * @{
+ */
 /** \struct cl_lock
  *
  * Extent locking on the client.
@@ -1641,7 +1649,8 @@ struct cl_lock {
 struct cl_lock_slice {
 	struct cl_lock		  *cls_lock;
 	/** Object slice corresponding to this lock slice. Immutable after
-	 * creation. */
+	 * creation.
+	 */
 	struct cl_object		*cls_obj;
 	const struct cl_lock_operations *cls_ops;
 	/** Linkage into cl_lock::cll_layers. Immutable after creation. */
@@ -1885,7 +1894,8 @@ struct cl_2queue {
 /** @} cl_page_list */
 
 /** \addtogroup cl_io cl_io
- * @{ */
+ * @{
+ */
 /** \struct cl_io
  * I/O
  *
@@ -2284,7 +2294,8 @@ enum cl_fsync_mode {
 	/** discard all of dirty pages in a specific file range */
 	CL_FSYNC_DISCARD = 2,
 	/** start writeback and make sure they have reached storage before
-	 * return. OST_SYNC RPC must be issued and finished */
+	 * return. OST_SYNC RPC must be issued and finished
+	 */
 	CL_FSYNC_ALL   = 3
 };
 
@@ -2403,7 +2414,8 @@ struct cl_io {
 /** @} cl_io */
 
 /** \addtogroup cl_req cl_req
- * @{ */
+ * @{
+ */
 /** \struct cl_req
  * Transfer.
  *
@@ -2582,7 +2594,8 @@ enum cache_stats_item {
 	/** how many entities are in the cache right now */
 	CS_total,
 	/** how many entities in the cache are actively used (and cannot be
-	 * evicted) right now */
+	 * evicted) right now
+	 */
 	CS_busy,
 	/** how many entities were created at all */
 	CS_create,
@@ -2725,7 +2738,8 @@ void cl_req_slice_add(struct cl_req *req, struct cl_req_slice *slice,
 /** @} helpers */
 
 /** \defgroup cl_object cl_object
- * @{ */
+ * @{
+ */
 struct cl_object *cl_object_top (struct cl_object *o);
 struct cl_object *cl_object_find(const struct lu_env *env, struct cl_device *cd,
 				 const struct lu_fid *fid,
@@ -2770,7 +2784,8 @@ static inline void *cl_object_page_slice(struct cl_object *clob,
 /** @} cl_object */
 
 /** \defgroup cl_page cl_page
- * @{ */
+ * @{
+ */
 enum {
 	CLP_GANG_OKAY = 0,
 	CLP_GANG_RESCHED,
@@ -2888,7 +2903,8 @@ void cl_lock_descr_print(const struct lu_env *env, void *cookie,
 /** @} cl_page */
 
 /** \defgroup cl_lock cl_lock
- * @{ */
+ * @{
+ */
 
 struct cl_lock *cl_lock_hold(const struct lu_env *env, const struct cl_io *io,
 			     const struct cl_lock_descr *need,
@@ -2966,7 +2982,8 @@ int cl_lock_enqueue_wait(const struct lu_env *env, struct cl_lock *lock,
  *
  * cl_use_try()     NONE	 cl_lock_operations::clo_use()     CLS_HELD
  *
- * @{ */
+ * @{
+ */
 
 int   cl_wait       (const struct lu_env *env, struct cl_lock *lock);
 void  cl_unuse      (const struct lu_env *env, struct cl_lock *lock);
@@ -3019,7 +3036,8 @@ unsigned long cl_lock_weigh(const struct lu_env *env, struct cl_lock *lock);
 /** @} cl_lock */
 
 /** \defgroup cl_io cl_io
- * @{ */
+ * @{
+ */
 
 int   cl_io_init	 (const struct lu_env *env, struct cl_io *io,
 			  enum cl_io_type iot, struct cl_object *obj);
@@ -3094,7 +3112,8 @@ do {									\
 /** @} cl_io */
 
 /** \defgroup cl_page_list cl_page_list
- * @{ */
+ * @{
+ */
 
 /**
  * Last page in the page list.
@@ -3137,7 +3156,8 @@ void cl_2queue_init_page(struct cl_2queue *queue, struct cl_page *page);
 /** @} cl_page_list */
 
 /** \defgroup cl_req cl_req
- * @{ */
+ * @{
+ */
 struct cl_req *cl_req_alloc(const struct lu_env *env, struct cl_page *page,
 			    enum cl_req_type crt, int nr_objects);
 
@@ -3214,7 +3234,8 @@ void cl_sync_io_note(struct cl_sync_io *anchor, int ioret);
  *       - cl_env_reexit(cl_env_reenter had to be called priorly)
  *
  * \see lu_env, lu_context, lu_context_key
- * @{ */
+ * @{
+ */
 
 struct cl_env_nest {
 	int   cen_refcheck;
diff --git a/drivers/staging/lustre/lustre/include/lclient.h b/drivers/staging/lustre/lustre/include/lclient.h
index 7f0a045..5d839a9 100644
--- a/drivers/staging/lustre/lustre/include/lclient.h
+++ b/drivers/staging/lustre/lustre/include/lclient.h
@@ -383,7 +383,8 @@ void cl_put_grouplock(struct ccc_grouplock *cg);
  *
  * NB: If you find you have to use these interfaces for your new code, please
  * think about it again. These interfaces may be removed in the future for
- * better layering. */
+ * better layering.
+ */
 struct lov_stripe_md *lov_lsm_get(struct cl_object *clobj);
 void lov_lsm_put(struct cl_object *clobj, struct lov_stripe_md *lsm);
 int lov_read_and_clear_async_rc(struct cl_object *clob);
diff --git a/drivers/staging/lustre/lustre/include/lprocfs_status.h b/drivers/staging/lustre/lustre/include/lprocfs_status.h
index 54e5aee..eb693a1 100644
--- a/drivers/staging/lustre/lustre/include/lprocfs_status.h
+++ b/drivers/staging/lustre/lustre/include/lprocfs_status.h
@@ -175,7 +175,8 @@ struct lprocfs_percpu {
 enum lprocfs_stats_flags {
 	LPROCFS_STATS_FLAG_NONE     = 0x0000, /* per cpu counter */
 	LPROCFS_STATS_FLAG_NOPERCPU = 0x0001, /* stats have no percpu
-					       * area and need locking */
+					       * area and need locking
+					       */
 	LPROCFS_STATS_FLAG_IRQ_SAFE = 0x0002, /* alloc need irq safe */
 };
 
@@ -196,7 +197,8 @@ struct lprocfs_stats {
 	unsigned short			ls_biggest_alloc_num;
 	enum lprocfs_stats_flags	ls_flags;
 	/* Lock used when there are no percpu stats areas; For percpu stats,
-	 * it is used to protect ls_biggest_alloc_num change */
+	 * it is used to protect ls_biggest_alloc_num change
+	 */
 	spinlock_t			ls_lock;
 
 	/* has ls_num of counter headers */
@@ -611,9 +613,10 @@ int lprocfs_single_release(struct inode *, struct file *);
 int lprocfs_seq_release(struct inode *, struct file *);
 
 /* write the name##_seq_show function, call LPROC_SEQ_FOPS_RO for read-only
-  proc entries; otherwise, you will define name##_seq_write function also for
-  a read-write proc entry, and then call LPROC_SEQ_SEQ instead. Finally,
-  call ldebugfs_obd_seq_create(obd, filename, 0444, &name#_fops, data); */
+ * proc entries; otherwise, you will define name##_seq_write function also for
+ * a read-write proc entry, and then call LPROC_SEQ_SEQ instead. Finally,
+ * call ldebugfs_obd_seq_create(obd, filename, 0444, &name#_fops, data);
+ */
 #define __LPROC_SEQ_FOPS(name, custom_seq_write)			\
 static int name##_single_open(struct inode *inode, struct file *file)	\
 {									\
diff --git a/drivers/staging/lustre/lustre/include/lu_object.h b/drivers/staging/lustre/lustre/include/lu_object.h
index 23e5567..b5088b1 100644
--- a/drivers/staging/lustre/lustre/include/lu_object.h
+++ b/drivers/staging/lustre/lustre/include/lu_object.h
@@ -166,7 +166,8 @@ struct lu_device_operations {
  */
 enum loc_flags {
 	/* This is a new object to be allocated, or the file
-	 * corresponding to the object does not exists. */
+	 * corresponding to the object does not exists.
+	 */
 	LOC_F_NEW	= 0x00000001,
 };
 
@@ -895,7 +896,8 @@ enum lu_xattr_flags {
 /** @} helpers */
 
 /** \name lu_context
- * @{ */
+ * @{
+ */
 
 /** For lu_context health-checks */
 enum lu_context_state {
diff --git a/drivers/staging/lustre/lustre/include/lustre/ll_fiemap.h b/drivers/staging/lustre/lustre/include/lustre/ll_fiemap.h
index 09088f4..07d45de 100644
--- a/drivers/staging/lustre/lustre/include/lustre/ll_fiemap.h
+++ b/drivers/staging/lustre/lustre/include/lustre/ll_fiemap.h
@@ -47,9 +47,11 @@
 
 struct ll_fiemap_extent {
 	__u64 fe_logical;  /* logical offset in bytes for the start of
-			    * the extent from the beginning of the file */
+			    * the extent from the beginning of the file
+			    */
 	__u64 fe_physical; /* physical offset in bytes for the start
-			    * of the extent from the beginning of the disk */
+			    * of the extent from the beginning of the disk
+			    */
 	__u64 fe_length;   /* length in bytes for this extent */
 	__u64 fe_reserved64[2];
 	__u32 fe_flags;    /* FIEMAP_EXTENT_* flags for this extent */
@@ -59,9 +61,11 @@ struct ll_fiemap_extent {
 
 struct ll_user_fiemap {
 	__u64 fm_start;  /* logical offset (inclusive) at
-			  * which to start mapping (in) */
+			  * which to start mapping (in)
+			  */
 	__u64 fm_length; /* logical length of mapping which
-			  * userspace wants (in) */
+			  * userspace wants (in)
+			  */
 	__u32 fm_flags;  /* FIEMAP_FLAG_* flags for request (in/out) */
 	__u32 fm_mapped_extents;/* number of extents that were mapped (out) */
 	__u32 fm_extent_count;  /* size of fm_extents array (in) */
@@ -71,28 +75,38 @@ struct ll_user_fiemap {
 
 #define FIEMAP_MAX_OFFSET      (~0ULL)
 
-#define FIEMAP_FLAG_SYNC	 0x00000001 /* sync file data before map */
-#define FIEMAP_FLAG_XATTR	0x00000002 /* map extended attribute tree */
-
-#define FIEMAP_EXTENT_LAST	      0x00000001 /* Last extent in file. */
-#define FIEMAP_EXTENT_UNKNOWN	   0x00000002 /* Data location unknown. */
-#define FIEMAP_EXTENT_DELALLOC	  0x00000004 /* Location still pending.
-						    * Sets EXTENT_UNKNOWN. */
-#define FIEMAP_EXTENT_ENCODED	   0x00000008 /* Data can not be read
-						    * while fs is unmounted */
-#define FIEMAP_EXTENT_DATA_ENCRYPTED    0x00000080 /* Data is encrypted by fs.
-						    * Sets EXTENT_NO_DIRECT. */
+#define FIEMAP_FLAG_SYNC		0x00000001 /* sync file data before
+						    * map
+						    */
+#define FIEMAP_FLAG_XATTR		0x00000002 /* map extended attribute
+						    * tree
+						    */
+#define FIEMAP_EXTENT_LAST		0x00000001 /* Last extent in file. */
+#define FIEMAP_EXTENT_UNKNOWN		0x00000002 /* Data location unknown. */
+#define FIEMAP_EXTENT_DELALLOC		0x00000004 /* Location still pending.
+						    * Sets EXTENT_UNKNOWN.
+						    */
+#define FIEMAP_EXTENT_ENCODED		0x00000008 /* Data can not be read
+						    * while fs is unmounted
+						    */
+#define FIEMAP_EXTENT_DATA_ENCRYPTED	0x00000080 /* Data is encrypted by fs.
+						    * Sets EXTENT_NO_DIRECT.
+						    */
 #define FIEMAP_EXTENT_NOT_ALIGNED       0x00000100 /* Extent offsets may not be
-						    * block aligned. */
+						    * block aligned.
+						    */
 #define FIEMAP_EXTENT_DATA_INLINE       0x00000200 /* Data mixed with metadata.
 						    * Sets EXTENT_NOT_ALIGNED.*/
-#define FIEMAP_EXTENT_DATA_TAIL	 0x00000400 /* Multiple files in block.
-						    * Sets EXTENT_NOT_ALIGNED.*/
-#define FIEMAP_EXTENT_UNWRITTEN	 0x00000800 /* Space allocated, but
-						    * no data (i.e. zero). */
-#define FIEMAP_EXTENT_MERGED	    0x00001000 /* File does not natively
+#define FIEMAP_EXTENT_DATA_TAIL		0x00000400 /* Multiple files in block.
+						    * Sets EXTENT_NOT_ALIGNED.
+						    */
+#define FIEMAP_EXTENT_UNWRITTEN		0x00000800 /* Space allocated, but
+						    * no data (i.e. zero).
+						    */
+#define FIEMAP_EXTENT_MERGED		0x00001000 /* File does not natively
 						    * support extents. Result
-						    * merged for efficiency. */
+						    * merged for efficiency.
+						    */
 
 static inline size_t fiemap_count_to_size(size_t extent_count)
 {
@@ -114,7 +128,8 @@ static inline unsigned fiemap_size_to_count(size_t array_size)
 
 /* Lustre specific flags - use a high bit, don't conflict with upstream flag */
 #define FIEMAP_EXTENT_NO_DIRECT	 0x40000000 /* Data mapping undefined */
-#define FIEMAP_EXTENT_NET	       0x80000000 /* Data stored remotely.
-						    * Sets NO_DIRECT flag */
+#define FIEMAP_EXTENT_NET	 0x80000000 /* Data stored remotely.
+					     * Sets NO_DIRECT flag
+					     */
 
 #endif /* _LUSTRE_FIEMAP_H */
diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_user.h b/drivers/staging/lustre/lustre/include/lustre/lustre_user.h
index 57d42a3..60c40ca 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_user.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_user.h
@@ -85,9 +85,8 @@ struct obd_statfs {
 	__u32	   os_namelen;
 	__u64	   os_maxbytes;
 	__u32	   os_state;       /**< obd_statfs_state OS_STATE_* flag */
-	__u32	   os_fprecreated;	/* objs available now to the caller */
-					/* used in QoS code to find preferred
-					 * OSTs */
+	__u32	   os_fprecreated; /* objs available now to the caller */
+				   /* used in QoS code to find preferred OSTs */
 	__u32	   os_spare2;
 	__u32	   os_spare3;
 	__u32	   os_spare4;
@@ -135,7 +134,8 @@ struct filter_fid_old {
 
 /* Userspace should treat lu_fid as opaque, and only use the following methods
  * to print or parse them.  Other functions (e.g. compare, swab) could be moved
- * here from lustre_idl.h if needed. */
+ * here from lustre_idl.h if needed.
+ */
 struct lu_fid;
 
 /**
@@ -266,7 +266,8 @@ struct ost_id {
 /* Define O_LOV_DELAY_CREATE to be a mask that is not useful for regular
  * files, but are unlikely to be used in practice and are not harmful if
  * used incorrectly.  O_NOCTTY and FASYNC are only meaningful for character
- * devices and are safe for use on new files (See LU-812, LU-4209). */
+ * devices and are safe for use on new files (See LU-812, LU-4209).
+ */
 #define O_LOV_DELAY_CREATE	(O_NOCTTY | FASYNC)
 
 #define LL_FILE_IGNORE_LOCK     0x00000001
@@ -302,7 +303,8 @@ struct ost_id {
  * The limit of 12 pages is somewhat arbitrary, but is a reasonably large
  * allocation that is sufficient for the current generation of systems.
  *
- * (max buffer size - lov+rpc header) / sizeof(struct lov_ost_data_v1) */
+ * (max buffer size - lov+rpc header) / sizeof(struct lov_ost_data_v1)
+ */
 #define LOV_MAX_STRIPE_COUNT 2000  /* ((12 * 4096 - 256) / 24) */
 #define LOV_ALL_STRIPES       0xffff /* only valid for directories */
 #define LOV_V1_INSANE_STRIPE_COUNT 65532 /* maximum stripe count bz13933 */
@@ -323,9 +325,11 @@ struct lov_user_md_v1 {	   /* LOV EA user data (host-endian) */
 	__u16 lmm_stripe_count;   /* num stripes in use for this object */
 	union {
 		__u16 lmm_stripe_offset;  /* starting stripe offset in
-					   * lmm_objects, use when writing */
+					   * lmm_objects, use when writing
+					   */
 		__u16 lmm_layout_gen;     /* layout generation number
-					   * used when reading */
+					   * used when reading
+					   */
 	};
 	struct lov_user_ost_data_v1 lmm_objects[0]; /* per-stripe data */
 } __attribute__((packed,  __may_alias__));
@@ -338,9 +342,11 @@ struct lov_user_md_v3 {	   /* LOV EA user data (host-endian) */
 	__u16 lmm_stripe_count;   /* num stripes in use for this object */
 	union {
 		__u16 lmm_stripe_offset;  /* starting stripe offset in
-					   * lmm_objects, use when writing */
+					   * lmm_objects, use when writing
+					   */
 		__u16 lmm_layout_gen;     /* layout generation number
-					   * used when reading */
+					   * used when reading
+					   */
 	};
 	char  lmm_pool_name[LOV_MAXPOOLNAME]; /* pool name */
 	struct lov_user_ost_data_v1 lmm_objects[0]; /* per-stripe data */
@@ -444,7 +450,8 @@ static inline char *obd_uuid2str(const struct obd_uuid *uuid)
 {
 	if (uuid->uuid[sizeof(*uuid) - 1] != '\0') {
 		/* Obviously not safe, but for printfs, no real harm done...
-		   we're always null-terminated, even in a race. */
+		 * we're always null-terminated, even in a race.
+		 */
 		static char temp[sizeof(*uuid)];
 
 		memcpy(temp, uuid->uuid, sizeof(*uuid) - 1);
@@ -455,8 +462,9 @@ static inline char *obd_uuid2str(const struct obd_uuid *uuid)
 }
 
 /* Extract fsname from uuid (or target name) of a target
-   e.g. (myfs-OST0007_UUID -> myfs)
-   see also deuuidify. */
+ * e.g. (myfs-OST0007_UUID -> myfs)
+ * see also deuuidify.
+ */
 static inline void obd_uuid2fsname(char *buf, char *uuid, int buflen)
 {
 	char *p;
@@ -469,7 +477,8 @@ static inline void obd_uuid2fsname(char *buf, char *uuid, int buflen)
 }
 
 /* printf display format
-   e.g. printf("file FID is "DFID"\n", PFID(fid)); */
+ * e.g. printf("file FID is "DFID"\n", PFID(fid));
+ */
 #define FID_NOBRACE_LEN 40
 #define FID_LEN (FID_NOBRACE_LEN + 2)
 #define DFID_NOBRACE "%#llx:0x%x:0x%x"
@@ -480,7 +489,8 @@ static inline void obd_uuid2fsname(char *buf, char *uuid, int buflen)
 	(fid)->f_ver
 
 /* scanf input parse format -- strip '[' first.
-   e.g. sscanf(fidstr, SFID, RFID(&fid)); */
+ * e.g. sscanf(fidstr, SFID, RFID(&fid));
+ */
 #define SFID "0x%llx:0x%x:0x%x"
 #define RFID(fid)     \
 	&((fid)->f_seq), \
@@ -698,7 +708,8 @@ static inline const char *changelog_type2str(int type)
 #define CLF_HSM_LAST	15
 
 /* Remove bits higher than _h, then extract the value
- * between _h and _l by shifting lower weigth to bit 0. */
+ * between _h and _l by shifting lower weigth to bit 0.
+ */
 #define CLF_GET_BITS(_b, _h, _l) (((_b << (CLF_HSM_LAST - _h)) & 0xFFFF) \
 				   >> (CLF_HSM_LAST - _h + _l))
 
@@ -775,7 +786,8 @@ struct changelog_rec {
 struct changelog_ext_rec {
 	__u16			cr_namelen;
 	__u16			cr_flags; /**< (flags & CLF_FLAGMASK) |
-						CLF_EXT_VERSION */
+					   *	CLF_EXT_VERSION
+					   */
 	__u32			cr_type;  /**< \a changelog_rec_type */
 	__u64			cr_index; /**< changelog record number */
 	__u64			cr_prev;  /**< last index for this target fid */
@@ -835,7 +847,8 @@ struct ioc_data_version {
 };
 
 #define LL_DV_NOFLUSH 0x01   /* Do not take READ EXTENT LOCK before sampling
-				version. Dirty caches are left unchanged. */
+			      * version. Dirty caches are left unchanged.
+			      */
 
 #ifndef offsetof
 # define offsetof(typ, memb)     ((unsigned long)((char *)&(((typ *)0)->memb)))
@@ -1095,7 +1108,8 @@ struct hsm_action_list {
 	__u32 padding1;
 	char  hal_fsname[0];   /* null-terminated */
 	/* struct hsm_action_item[hal_count] follows, aligned on 8-byte
-	   boundaries. See hai_zero */
+	 * boundaries. See hai_zero
+	 */
 } __packed;
 
 #ifndef HAVE_CFS_SIZE_ROUND
diff --git a/drivers/staging/lustre/lustre/include/lustre_cfg.h b/drivers/staging/lustre/lustre/include/lustre_cfg.h
index 1bc35c4..23ae832 100644
--- a/drivers/staging/lustre/lustre/include/lustre_cfg.h
+++ b/drivers/staging/lustre/lustre/include/lustre_cfg.h
@@ -55,7 +55,8 @@
 /** If the LCFG_REQUIRED bit is set in a configuration command,
  * then the client is required to understand this parameter
  * in order to mount the filesystem. If it does not understand
- * a REQUIRED command the client mount will fail. */
+ * a REQUIRED command the client mount will fail.
+ */
 #define LCFG_REQUIRED	 0x0001000
 
 enum lcfg_command_type {
@@ -87,9 +88,11 @@ enum lcfg_command_type {
 	LCFG_POOL_DEL	   = 0x00ce023, /**< destroy an ost pool name */
 	LCFG_SET_LDLM_TIMEOUT   = 0x00ce030, /**< set ldlm_timeout */
 	LCFG_PRE_CLEANUP	= 0x00cf031, /**< call type-specific pre
-					      * cleanup cleanup */
+					      * cleanup cleanup
+					      */
 	LCFG_SET_PARAM		= 0x00ce032, /**< use set_param syntax to set
-					      *a proc parameters */
+					      * a proc parameters
+					      */
 };
 
 struct lustre_cfg_bufs {
diff --git a/drivers/staging/lustre/lustre/include/lustre_disk.h b/drivers/staging/lustre/lustre/include/lustre_disk.h
index b69bd9d..95fd360 100644
--- a/drivers/staging/lustre/lustre/include/lustre_disk.h
+++ b/drivers/staging/lustre/lustre/include/lustre_disk.h
@@ -65,7 +65,8 @@
 /****************** mount command *********************/
 
 /* The lmd is only used internally by Lustre; mount simply passes
-   everything as string options */
+ * everything as string options
+ */
 
 #define LMD_MAGIC    0xbdacbd03
 #define LMD_PARAMS_MAXLEN	4096
@@ -79,23 +80,26 @@ struct lustre_mount_data {
 	int	lmd_recovery_time_soft;
 	int	lmd_recovery_time_hard;
 	char      *lmd_dev;	   /* device name */
-	char      *lmd_profile;       /* client only */
+	char      *lmd_profile;    /* client only */
 	char      *lmd_mgssec;	/* sptlrpc flavor to mgs */
-	char      *lmd_opts;	  /* lustre mount options (as opposed to
-					 _device_ mount options) */
+	char      *lmd_opts;	/* lustre mount options (as opposed to
+				 * _device_ mount options)
+				 */
 	char      *lmd_params;	/* lustre params */
-	__u32     *lmd_exclude;       /* array of OSTs to ignore */
-	char	*lmd_mgs;	   /* MGS nid */
-	char	*lmd_osd_type;      /* OSD type */
+	__u32     *lmd_exclude; /* array of OSTs to ignore */
+	char	*lmd_mgs;	/* MGS nid */
+	char	*lmd_osd_type;  /* OSD type */
 };
 
 #define LMD_FLG_SERVER		0x0001	/* Mounting a server */
 #define LMD_FLG_CLIENT		0x0002	/* Mounting a client */
 #define LMD_FLG_ABORT_RECOV	0x0008	/* Abort recovery */
 #define LMD_FLG_NOSVC		0x0010	/* Only start MGS/MGC for servers,
-					   no other services */
-#define LMD_FLG_NOMGS		0x0020	/* Only start target for servers, reusing
-					   existing MGS services */
+					 * no other services
+					 */
+#define LMD_FLG_NOMGS		0x0020	/* Only start target for servers,
+					 * reusing existing MGS services
+					 */
 #define LMD_FLG_WRITECONF	0x0040	/* Rewrite config log */
 #define LMD_FLG_NOIR		0x0080	/* NO imperative recovery */
 #define LMD_FLG_NOSCRUB		0x0100	/* Do not trigger scrub automatically */
@@ -135,7 +139,8 @@ struct lustre_sb_info {
 	char			  lsi_osd_type[16];
 	char			  lsi_fstype[16];
 	struct backing_dev_info   lsi_bdi;     /* each client mountpoint needs
-						  own backing_dev_info */
+						* own backing_dev_info
+						*/
 };
 
 #define LSI_UMOUNT_FAILOVER	      0x00200000
diff --git a/drivers/staging/lustre/lustre/include/lustre_dlm.h b/drivers/staging/lustre/lustre/include/lustre_dlm.h
index 4ab34dd..144b5af 100644
--- a/drivers/staging/lustre/lustre/include/lustre_dlm.h
+++ b/drivers/staging/lustre/lustre/include/lustre_dlm.h
@@ -250,7 +250,8 @@ struct ldlm_pool {
 	/** Current biggest client lock volume. Protected by pl_lock. */
 	__u64			pl_client_lock_volume;
 	/** Lock volume factor. SLV on client is calculated as following:
-	 *  server_slv * lock_volume_factor. */
+	 *  server_slv * lock_volume_factor.
+	 */
 	atomic_t		pl_lock_volume_factor;
 	/** Time when last SLV from server was obtained. */
 	time64_t		pl_recalc_time;
@@ -501,7 +502,8 @@ struct ldlm_glimpse_work {
 	struct list_head		 gl_list; /* linkage to other gl work structs */
 	__u32			 gl_flags;/* see LDLM_GL_WORK_* below */
 	union ldlm_gl_desc	*gl_desc; /* glimpse descriptor to be packed in
-					   * glimpse callback request */
+					   * glimpse callback request
+					   */
 };
 
 /** The ldlm_glimpse_work is allocated on the stack and should not be freed. */
@@ -510,8 +512,9 @@ struct ldlm_glimpse_work {
 /** Interval node data for each LDLM_EXTENT lock. */
 struct ldlm_interval {
 	struct interval_node	li_node;  /* node for tree management */
-	struct list_head		li_group; /* the locks which have the same
-					   * policy - group of the policy */
+	struct list_head	li_group; /* the locks which have the same
+					   * policy - group of the policy
+					   */
 };
 
 #define to_ldlm_interval(n) container_of(n, struct ldlm_interval, li_node)
@@ -537,7 +540,8 @@ enum ldlm_cancel_flags {
 	LCF_ASYNC      = 0x1, /* Cancel locks asynchronously. */
 	LCF_LOCAL      = 0x2, /* Cancel locks locally, not notifing server */
 	LCF_BL_AST     = 0x4, /* Cancel locks marked as LDLM_FL_BL_AST
-			       * in the same RPC */
+			       * in the same RPC
+			       */
 };
 
 struct ldlm_flock {
@@ -839,12 +843,14 @@ struct ldlm_resource {
 
 	/**
 	 * protected by lr_lock
-	 * @{ */
+	 * @{
+	 */
 	/** List of locks in granted state */
 	struct list_head		lr_granted;
 	/**
 	 * List of locks that could not be granted due to conflicts and
-	 * that are waiting for conflicts to go away */
+	 * that are waiting for conflicts to go away
+	 */
 	struct list_head		lr_waiting;
 	/** @} */
 
@@ -1036,7 +1042,8 @@ typedef int (*ldlm_res_iterator_t)(struct ldlm_resource *, void *);
  *
  * LDLM provides for a way to iterate through every lock on a resource or
  * namespace or every resource in a namespace.
- * @{ */
+ * @{
+ */
 int ldlm_resource_iterate(struct ldlm_namespace *, const struct ldlm_res_id *,
 			  ldlm_iterator_t iter, void *data);
 /** @} ldlm_iterator */
@@ -1214,7 +1221,8 @@ int ldlm_lock_change_resource(struct ldlm_namespace *, struct ldlm_lock *,
  * These AST handlers are typically used for server-side local locks and are
  * also used by client-side lock handlers to perform minimum level base
  * processing.
- * @{ */
+ * @{
+ */
 int ldlm_completion_ast_async(struct ldlm_lock *lock, __u64 flags, void *data);
 int ldlm_completion_ast(struct ldlm_lock *lock, __u64 flags, void *data);
 /** @} ldlm_local_ast */
@@ -1222,7 +1230,8 @@ int ldlm_completion_ast(struct ldlm_lock *lock, __u64 flags, void *data);
 /** \defgroup ldlm_cli_api API to operate on locks from actual LDLM users.
  * These are typically used by client and server (*_local versions)
  * to obtain and release locks.
- * @{ */
+ * @{
+ */
 int ldlm_cli_enqueue(struct obd_export *exp, struct ptlrpc_request **reqp,
 		     struct ldlm_enqueue_info *einfo,
 		     const struct ldlm_res_id *res_id,
diff --git a/drivers/staging/lustre/lustre/include/lustre_dlm_flags.h b/drivers/staging/lustre/lustre/include/lustre_dlm_flags.h
index 4f9e9ad..7f2ba2f 100644
--- a/drivers/staging/lustre/lustre/include/lustre_dlm_flags.h
+++ b/drivers/staging/lustre/lustre/include/lustre_dlm_flags.h
@@ -57,7 +57,8 @@
 
 /**
  * Server placed lock on granted list, or a recovering client wants the
- * lock added to the granted list, no questions asked. */
+ * lock added to the granted list, no questions asked.
+ */
 #define LDLM_FL_BLOCK_GRANTED           0x0000000000000002ULL /* bit 1 */
 #define ldlm_is_block_granted(_l)       LDLM_TEST_FLAG((_l), 1ULL <<  1)
 #define ldlm_set_block_granted(_l)      LDLM_SET_FLAG((_l), 1ULL <<  1)
@@ -65,7 +66,8 @@
 
 /**
  * Server placed lock on conv list, or a recovering client wants the lock
- * added to the conv list, no questions asked. */
+ * added to the conv list, no questions asked.
+ */
 #define LDLM_FL_BLOCK_CONV              0x0000000000000004ULL /* bit 2 */
 #define ldlm_is_block_conv(_l)          LDLM_TEST_FLAG((_l), 1ULL <<  2)
 #define ldlm_set_block_conv(_l)         LDLM_SET_FLAG((_l), 1ULL <<  2)
@@ -73,7 +75,8 @@
 
 /**
  * Server placed lock on wait list, or a recovering client wants the lock
- * added to the wait list, no questions asked. */
+ * added to the wait list, no questions asked.
+ */
 #define LDLM_FL_BLOCK_WAIT              0x0000000000000008ULL /* bit 3 */
 #define ldlm_is_block_wait(_l)          LDLM_TEST_FLAG((_l), 1ULL <<  3)
 #define ldlm_set_block_wait(_l)         LDLM_SET_FLAG((_l), 1ULL <<  3)
@@ -87,7 +90,8 @@
 
 /**
  * Lock is being replayed.  This could probably be implied by the fact that
- * one of BLOCK_{GRANTED,CONV,WAIT} is set, but that is pretty dangerous. */
+ * one of BLOCK_{GRANTED,CONV,WAIT} is set, but that is pretty dangerous.
+ */
 #define LDLM_FL_REPLAY                  0x0000000000000100ULL /* bit 8 */
 #define ldlm_is_replay(_l)              LDLM_TEST_FLAG((_l), 1ULL <<  8)
 #define ldlm_set_replay(_l)             LDLM_SET_FLAG((_l), 1ULL <<  8)
@@ -125,7 +129,8 @@
 
 /**
  * Server told not to wait if blocked. For AGL, OST will not send glimpse
- * callback. */
+ * callback.
+ */
 #define LDLM_FL_BLOCK_NOWAIT            0x0000000000040000ULL /* bit 18 */
 #define ldlm_is_block_nowait(_l)        LDLM_TEST_FLAG((_l), 1ULL << 18)
 #define ldlm_set_block_nowait(_l)       LDLM_SET_FLAG((_l), 1ULL << 18)
@@ -141,7 +146,8 @@
  * Immediately cancel such locks when they block some other locks. Send
  * cancel notification to original lock holder, but expect no reply. This
  * is for clients (like liblustre) that cannot be expected to reliably
- * response to blocking AST. */
+ * response to blocking AST.
+ */
 #define LDLM_FL_CANCEL_ON_BLOCK         0x0000000000800000ULL /* bit 23 */
 #define ldlm_is_cancel_on_block(_l)     LDLM_TEST_FLAG((_l), 1ULL << 23)
 #define ldlm_set_cancel_on_block(_l)    LDLM_SET_FLAG((_l), 1ULL << 23)
@@ -164,7 +170,8 @@
 
 /**
  * Used for marking lock as a target for -EINTR while cp_ast sleep emulation
- * + race with upcoming bl_ast. */
+ * + race with upcoming bl_ast.
+ */
 #define LDLM_FL_FAIL_LOC                0x0000000100000000ULL /* bit 32 */
 #define ldlm_is_fail_loc(_l)            LDLM_TEST_FLAG((_l), 1ULL << 32)
 #define ldlm_set_fail_loc(_l)           LDLM_SET_FLAG((_l), 1ULL << 32)
@@ -172,7 +179,8 @@
 
 /**
  * Used while processing the unused list to know that we have already
- * handled this lock and decided to skip it. */
+ * handled this lock and decided to skip it.
+ */
 #define LDLM_FL_SKIPPED                 0x0000000200000000ULL /* bit 33 */
 #define ldlm_is_skipped(_l)             LDLM_TEST_FLAG((_l), 1ULL << 33)
 #define ldlm_set_skipped(_l)            LDLM_SET_FLAG((_l), 1ULL << 33)
@@ -231,7 +239,8 @@
  * The proper fix is to do the granting inside of the completion AST,
  * which can be replaced with a LVB-aware wrapping function for OSC locks.
  * That change is pretty high-risk, though, and would need a lot more
- * testing. */
+ * testing.
+ */
 #define LDLM_FL_LVB_READY               0x0000020000000000ULL /* bit 41 */
 #define ldlm_is_lvb_ready(_l)           LDLM_TEST_FLAG((_l), 1ULL << 41)
 #define ldlm_set_lvb_ready(_l)          LDLM_SET_FLAG((_l), 1ULL << 41)
@@ -243,7 +252,8 @@
  * dirty pages.  It can remain on the granted list during this whole time.
  * Threads racing to update the KMS after performing their writeback need
  * to know to exclude each other's locks from the calculation as they walk
- * the granted list. */
+ * the granted list.
+ */
 #define LDLM_FL_KMS_IGNORE              0x0000040000000000ULL /* bit 42 */
 #define ldlm_is_kms_ignore(_l)          LDLM_TEST_FLAG((_l), 1ULL << 42)
 #define ldlm_set_kms_ignore(_l)         LDLM_SET_FLAG((_l), 1ULL << 42)
@@ -263,7 +273,8 @@
 
 /**
  * optimization hint: LDLM can run blocking callback from current context
- * w/o involving separate thread. in order to decrease cs rate */
+ * w/o involving separate thread. in order to decrease cs rate
+ */
 #define LDLM_FL_ATOMIC_CB               0x0000200000000000ULL /* bit 45 */
 #define ldlm_is_atomic_cb(_l)           LDLM_TEST_FLAG((_l), 1ULL << 45)
 #define ldlm_set_atomic_cb(_l)          LDLM_SET_FLAG((_l), 1ULL << 45)
@@ -280,7 +291,8 @@
  * LDLM_FL_BL_DONE is to be set by ldlm_cancel_callback() when lock cache is
  * dropped to let ldlm_callback_handler() return EINVAL to the server. It
  * is used when ELC RPC is already prepared and is waiting for rpc_lock,
- * too late to send a separate CANCEL RPC. */
+ * too late to send a separate CANCEL RPC.
+ */
 #define LDLM_FL_BL_AST                  0x0000400000000000ULL /* bit 46 */
 #define ldlm_is_bl_ast(_l)              LDLM_TEST_FLAG((_l), 1ULL << 46)
 #define ldlm_set_bl_ast(_l)             LDLM_SET_FLAG((_l), 1ULL << 46)
@@ -295,7 +307,8 @@
 /**
  * Don't put lock into the LRU list, so that it is not canceled due
  * to aging.  Used by MGC locks, they are cancelled only@unmount or
- * by callback. */
+ * by callback.
+ */
 #define LDLM_FL_NO_LRU                  0x0001000000000000ULL /* bit 48 */
 #define ldlm_is_no_lru(_l)              LDLM_TEST_FLAG((_l), 1ULL << 48)
 #define ldlm_set_no_lru(_l)             LDLM_SET_FLAG((_l), 1ULL << 48)
@@ -304,7 +317,8 @@
 /**
  * Set for locks that failed and where the server has been notified.
  *
- * Protected by lock and resource locks. */
+ * Protected by lock and resource locks.
+ */
 #define LDLM_FL_FAIL_NOTIFIED           0x0002000000000000ULL /* bit 49 */
 #define ldlm_is_fail_notified(_l)       LDLM_TEST_FLAG((_l), 1ULL << 49)
 #define ldlm_set_fail_notified(_l)      LDLM_SET_FLAG((_l), 1ULL << 49)
@@ -315,7 +329,8 @@
  * be destroyed when last reference to them is released. Set by
  * ldlm_lock_destroy_internal().
  *
- * Protected by lock and resource locks. */
+ * Protected by lock and resource locks.
+ */
 #define LDLM_FL_DESTROYED               0x0004000000000000ULL /* bit 50 */
 #define ldlm_is_destroyed(_l)           LDLM_TEST_FLAG((_l), 1ULL << 50)
 #define ldlm_set_destroyed(_l)          LDLM_SET_FLAG((_l), 1ULL << 50)
@@ -333,7 +348,8 @@
  * NB: compared with check_res_locked(), checking this bit is cheaper.
  * Also, spin_is_locked() is deprecated for kernel code; one reason is
  * because it works only for SMP so user needs to add extra macros like
- * LASSERT_SPIN_LOCKED for uniprocessor kernels. */
+ * LASSERT_SPIN_LOCKED for uniprocessor kernels.
+ */
 #define LDLM_FL_RES_LOCKED              0x0010000000000000ULL /* bit 52 */
 #define ldlm_is_res_locked(_l)          LDLM_TEST_FLAG((_l), 1ULL << 52)
 #define ldlm_set_res_locked(_l)         LDLM_SET_FLAG((_l), 1ULL << 52)
@@ -343,7 +359,8 @@
  * It's set once we call ldlm_add_waiting_lock_res_locked() to start the
  * lock-timeout timer and it will never be reset.
  *
- * Protected by lock and resource locks. */
+ * Protected by lock and resource locks.
+ */
 #define LDLM_FL_WAITED                  0x0020000000000000ULL /* bit 53 */
 #define ldlm_is_waited(_l)              LDLM_TEST_FLAG((_l), 1ULL << 53)
 #define ldlm_set_waited(_l)             LDLM_SET_FLAG((_l), 1ULL << 53)
diff --git a/drivers/staging/lustre/lustre/include/lustre_export.h b/drivers/staging/lustre/lustre/include/lustre_export.h
index 30ae096..3014d27 100644
--- a/drivers/staging/lustre/lustre/include/lustre_export.h
+++ b/drivers/staging/lustre/lustre/include/lustre_export.h
@@ -123,7 +123,8 @@ struct obd_export {
 	 */
 	spinlock_t		  exp_lock;
 	/** Compatibility flags for this export are embedded into
-	 *  exp_connect_data */
+	 *  exp_connect_data
+	 */
 	struct obd_connect_data   exp_connect_data;
 	enum obd_option	   exp_flags;
 	unsigned long	     exp_failed:1,
diff --git a/drivers/staging/lustre/lustre/include/lustre_fid.h b/drivers/staging/lustre/lustre/include/lustre_fid.h
index 9b1a9c6..ab91879 100644
--- a/drivers/staging/lustre/lustre/include/lustre_fid.h
+++ b/drivers/staging/lustre/lustre/include/lustre_fid.h
@@ -251,7 +251,8 @@ static inline void lu_local_name_obj_fid(struct lu_fid *fid, __u32 oid)
 
 /* For new FS (>= 2.4), the root FID will be changed to
  * [FID_SEQ_ROOT:1:0], for existing FS, (upgraded to 2.4),
- * the root FID will still be IGIF */
+ * the root FID will still be IGIF
+ */
 static inline int fid_is_root(const struct lu_fid *fid)
 {
 	return unlikely((fid_seq(fid) == FID_SEQ_ROOT &&
@@ -294,7 +295,8 @@ static inline int fid_is_namespace_visible(const struct lu_fid *fid)
 	const __u64 seq = fid_seq(fid);
 
 	/* Here, we cannot distinguish whether the normal FID is for OST
-	 * object or not. It is caller's duty to check more if needed. */
+	 * object or not. It is caller's duty to check more if needed.
+	 */
 	return (!fid_is_last_id(fid) &&
 		(fid_seq_is_norm(seq) || fid_seq_is_igif(seq))) ||
 	       fid_is_root(fid) || fid_is_dot_lustre(fid);
@@ -516,7 +518,8 @@ static inline int ostid_res_name_eq(struct ost_id *oi,
 				    struct ldlm_res_id *name)
 {
 	/* Note: it is just a trick here to save some effort, probably the
-	 * correct way would be turn them into the FID and compare */
+	 * correct way would be turn them into the FID and compare
+	 */
 	if (fid_seq_is_mdt0(ostid_seq(oi))) {
 		return name->name[LUSTRE_RES_ID_SEQ_OFF] == ostid_id(oi) &&
 		       name->name[LUSTRE_RES_ID_VER_OID_OFF] == ostid_seq(oi);
@@ -589,12 +592,14 @@ static inline __u64 fid_flatten(const struct lu_fid *fid)
 static inline __u32 fid_hash(const struct lu_fid *f, int bits)
 {
 	/* all objects with same id and different versions will belong to same
-	 * collisions list. */
+	 * collisions list.
+	 */
 	return hash_long(fid_flatten(f), bits);
 }
 
 /**
- * map fid to 32 bit value for ino on 32bit systems. */
+ * map fid to 32 bit value for ino on 32bit systems.
+ */
 static inline __u32 fid_flatten32(const struct lu_fid *fid)
 {
 	__u32 ino;
@@ -611,7 +616,8 @@ static inline __u32 fid_flatten32(const struct lu_fid *fid)
 	 * that inodes generated at about the same time have a reduced chance
 	 * of collisions. This will give a period of 2^12 = 1024 unique clients
 	 * (from SEQ) and up to min(LUSTRE_SEQ_MAX_WIDTH, 2^20) = 128k objects
-	 * (from OID), or up to 128M inodes without collisions for new files. */
+	 * (from OID), or up to 128M inodes without collisions for new files.
+	 */
 	ino = ((seq & 0x000fffffULL) << 12) + ((seq >> 8) & 0xfffff000) +
 	       (seq >> (64 - (40-8)) & 0xffffff00) +
 	       (fid_oid(fid) & 0xff000fff) + ((fid_oid(fid) & 0x00fff000) << 8);
diff --git a/drivers/staging/lustre/lustre/include/lustre_fld.h b/drivers/staging/lustre/lustre/include/lustre_fld.h
index 5511626..4cf2b0e 100644
--- a/drivers/staging/lustre/lustre/include/lustre_fld.h
+++ b/drivers/staging/lustre/lustre/include/lustre_fld.h
@@ -71,50 +71,41 @@ struct lu_fld_target {
 struct lu_server_fld {
 	/**
 	 * super sequence controller export, needed to forward fld
-	 * lookup  request. */
+	 * lookup  request.
+	 */
 	struct obd_export       *lsf_control_exp;
 
-	/**
-	 * Client FLD cache. */
+	/** Client FLD cache. */
 	struct fld_cache	*lsf_cache;
 
-	/**
-	 * Protect index modifications */
+	/** Protect index modifications */
 	struct mutex		lsf_lock;
 
-	/**
-	 * Fld service name in form "fld-srv-lustre-MDTXXX" */
+	/** Fld service name in form "fld-srv-lustre-MDTXXX" */
 	char		     lsf_name[LUSTRE_MDT_MAXNAMELEN];
 
 };
 
 struct lu_client_fld {
-	/**
-	 * Client side debugfs entry. */
+	/** Client side debugfs entry. */
 	struct dentry		*lcf_debugfs_entry;
 
-	/**
-	 * List of exports client FLD knows about. */
+	/** List of exports client FLD knows about. */
 	struct list_head	       lcf_targets;
 
-	/**
-	 * Current hash to be used to chose an export. */
+	/** Current hash to be used to chose an export. */
 	struct lu_fld_hash      *lcf_hash;
 
-	/**
-	 * Exports count. */
+	/** Exports count. */
 	int		      lcf_count;
 
-	/**
-	 * Lock protecting exports list and fld_hash. */
+	/** Lock protecting exports list and fld_hash. */
 	spinlock_t		 lcf_lock;
 
-	/**
-	 * Client FLD cache. */
+	/** Client FLD cache. */
 	struct fld_cache	*lcf_cache;
 
-	/**
-	 * Client fld debugfs entry name. */
+	/** Client fld debugfs entry name. */
 	char			 lcf_name[LUSTRE_MDT_MAXNAMELEN];
 
 	int			 lcf_flags;
diff --git a/drivers/staging/lustre/lustre/include/lustre_handles.h b/drivers/staging/lustre/lustre/include/lustre_handles.h
index f39780a..27f169d 100644
--- a/drivers/staging/lustre/lustre/include/lustre_handles.h
+++ b/drivers/staging/lustre/lustre/include/lustre_handles.h
@@ -65,7 +65,8 @@ struct portals_handle_ops {
  *
  * Now you're able to assign the results of cookie2handle directly to an
  * ldlm_lock.  If it's not@the top, you'll want to use container_of()
- * to compute the start of the structure based on the handle field. */
+ * to compute the start of the structure based on the handle field.
+ */
 struct portals_handle {
 	struct list_head			h_link;
 	__u64				h_cookie;
diff --git a/drivers/staging/lustre/lustre/include/lustre_import.h b/drivers/staging/lustre/lustre/include/lustre_import.h
index 4e4230e..dac2d84 100644
--- a/drivers/staging/lustre/lustre/include/lustre_import.h
+++ b/drivers/staging/lustre/lustre/include/lustre_import.h
@@ -292,7 +292,8 @@ struct obd_import {
 				  /* need IR MNE swab */
 				  imp_need_mne_swab:1,
 				  /* import must be reconnected instead of
-				   * chose new connection */
+				   * chosing new connection
+				   */
 				  imp_force_reconnect:1,
 				  /* import has tried to connect with server */
 				  imp_connect_tried:1;
diff --git a/drivers/staging/lustre/lustre/include/lustre_lib.h b/drivers/staging/lustre/lustre/include/lustre_lib.h
index 8f821df..f2223d5 100644
--- a/drivers/staging/lustre/lustre/include/lustre_lib.h
+++ b/drivers/staging/lustre/lustre/include/lustre_lib.h
@@ -387,7 +387,8 @@ static inline void obd_ioctl_freedata(char *buf, int len)
  */
 
 /* Until such time as we get_info the per-stripe maximum from the OST,
- * we define this to be 2T - 4k, which is the ext3 maxbytes. */
+ * we define this to be 2T - 4k, which is the ext3 maxbytes.
+ */
 #define LUSTRE_STRIPE_MAXBYTES 0x1fffffff000ULL
 
 /* Special values for remove LOV EA from disk */
diff --git a/drivers/staging/lustre/lustre/include/lustre_log.h b/drivers/staging/lustre/lustre/include/lustre_log.h
index 155a0e6..49618e1 100644
--- a/drivers/staging/lustre/lustre/include/lustre_log.h
+++ b/drivers/staging/lustre/lustre/include/lustre_log.h
@@ -241,7 +241,8 @@ struct llog_ctxt {
 	struct obd_llog_group   *loc_olg; /* group containing that ctxt */
 	struct obd_export       *loc_exp; /* parent "disk" export (e.g. MDS) */
 	struct obd_import       *loc_imp; /* to use in RPC's: can be backward
-					     pointing import */
+					   * pointing import
+					   */
 	struct llog_operations  *loc_logops;
 	struct llog_handle      *loc_handle;
 	struct mutex		 loc_mutex; /* protect loc_imp */
diff --git a/drivers/staging/lustre/lustre/include/lustre_mdc.h b/drivers/staging/lustre/lustre/include/lustre_mdc.h
index db46004..df94f9f 100644
--- a/drivers/staging/lustre/lustre/include/lustre_mdc.h
+++ b/drivers/staging/lustre/lustre/include/lustre_mdc.h
@@ -90,7 +90,8 @@ static inline void mdc_get_rpc_lock(struct mdc_rpc_lock *lck,
 	 * done, then set rpcl_it to MDC_FAKE_RPCL_IT.  Once that is set
 	 * it will only be cleared when all fake requests are finished.
 	 * Only when all fake requests are finished can normal requests
-	 * be sent, to ensure they are recoverable again. */
+	 * be sent, to ensure they are recoverable again.
+	 */
  again:
 	mutex_lock(&lck->rpcl_mutex);
 
@@ -105,7 +106,8 @@ static inline void mdc_get_rpc_lock(struct mdc_rpc_lock *lck,
 	 * just turned off but there are still requests in progress.
 	 * Wait until they finish.  It doesn't need to be efficient
 	 * in this extremely rare case, just have low overhead in
-	 * the common case when it isn't true. */
+	 * the common case when it isn't true.
+	 */
 	while (unlikely(lck->rpcl_it == MDC_FAKE_RPCL_IT)) {
 		mutex_unlock(&lck->rpcl_mutex);
 		schedule_timeout(cfs_time_seconds(1) / 4);
diff --git a/drivers/staging/lustre/lustre/include/lustre_net.h b/drivers/staging/lustre/lustre/include/lustre_net.h
index 2105a95..ac08b25 100644
--- a/drivers/staging/lustre/lustre/include/lustre_net.h
+++ b/drivers/staging/lustre/lustre/include/lustre_net.h
@@ -76,7 +76,8 @@
  * In order for the client and server to properly negotiate the maximum
  * possible transfer size, PTLRPC_BULK_OPS_COUNT must be a power-of-two
  * value.  The client is free to limit the actual RPC size for any bulk
- * transfer via cl_max_pages_per_rpc to some non-power-of-two value. */
+ * transfer via cl_max_pages_per_rpc to some non-power-of-two value.
+ */
 #define PTLRPC_BULK_OPS_BITS	2
 #define PTLRPC_BULK_OPS_COUNT	(1U << PTLRPC_BULK_OPS_BITS)
 /**
@@ -85,7 +86,8 @@
  * protocol limitation on the maximum RPC size that can be used by any
  * RPC sent to that server in the future.  Instead, the server should
  * use the negotiated per-client ocd_brw_size to determine the bulk
- * RPC count. */
+ * RPC count.
+ */
 #define PTLRPC_BULK_OPS_MASK	(~((__u64)PTLRPC_BULK_OPS_COUNT - 1))
 
 /**
@@ -419,16 +421,18 @@ struct ptlrpc_reply_state {
 	/** A spinlock to protect the reply state flags */
 	spinlock_t		rs_lock;
 	/** Reply state flags */
-	unsigned long	  rs_difficult:1;     /* ACK/commit stuff */
+	unsigned long	  rs_difficult:1; /* ACK/commit stuff */
 	unsigned long	  rs_no_ack:1;    /* no ACK, even for
-						  difficult requests */
+					   * difficult requests
+					   */
 	unsigned long	  rs_scheduled:1;     /* being handled? */
 	unsigned long	  rs_scheduled_ever:1;/* any schedule attempts? */
 	unsigned long	  rs_handled:1;  /* been handled yet? */
 	unsigned long	  rs_on_net:1;   /* reply_out_callback pending? */
 	unsigned long	  rs_prealloc:1; /* rs from prealloc list */
 	unsigned long	  rs_committed:1;/* the transaction was committed
-					  * and the rs was dispatched */
+					  * and the rs was dispatched
+					  */
 	/** Size of the state */
 	int		    rs_size;
 	/** opcode */
@@ -1181,7 +1185,7 @@ struct nrs_fifo_req {
  * purpose of this object is to hold references to the request's resources
  * for the lifetime of the request, and to hold properties that policies use
  * use for determining the request's scheduling priority.
- * */
+ */
 struct ptlrpc_nrs_request {
 	/**
 	 * The request's resource hierarchy.
@@ -1321,15 +1325,17 @@ struct ptlrpc_request {
 		/* do not resend request on -EINPROGRESS */
 		rq_no_retry_einprogress:1,
 		/* allow the req to be sent if the import is in recovery
-		 * status */
+		 * status
+		 */
 		rq_allow_replay:1;
 
 	unsigned int rq_nr_resend;
 
 	enum rq_phase rq_phase; /* one of RQ_PHASE_* */
 	enum rq_phase rq_next_phase; /* one of RQ_PHASE_* to be used next */
-	atomic_t rq_refcount;/* client-side refcount for SENT race,
-				    server-side refcount for multiple replies */
+	atomic_t rq_refcount; /* client-side refcount for SENT race,
+			       * server-side refcount for multiple replies
+			       */
 
 	/** Portal to which this request would be sent */
 	short rq_request_portal;  /* XXX FIXME bug 249 */
@@ -1363,7 +1369,8 @@ struct ptlrpc_request {
 
 	/**
 	 * security and encryption data
-	 * @{ */
+	 * @{
+	 */
 	struct ptlrpc_cli_ctx   *rq_cli_ctx;     /**< client's half ctx */
 	struct ptlrpc_svc_ctx   *rq_svc_ctx;     /**< server's half ctx */
 	struct list_head	       rq_ctx_chain;   /**< link to waited ctx */
@@ -1477,7 +1484,8 @@ struct ptlrpc_request {
 
 	/** when request must finish. volatile
 	 * so that servers' early reply updates to the deadline aren't
-	 * kept in per-cpu cache */
+	 * kept in per-cpu cache
+	 */
 	volatile time64_t rq_deadline;
 	/** when req reply unlink must finish. */
 	time64_t rq_reply_deadline;
@@ -1678,7 +1686,8 @@ do {									  \
 /**
  * This is the debug print function you need to use to print request structure
  * content into lustre debug log.
- * for most callers (level is a constant) this is resolved at compile time */
+ * for most callers (level is a constant) this is resolved@compile time
+ */
 #define DEBUG_REQ(level, req, fmt, args...)				   \
 do {									  \
 	if ((level) & (D_ERROR | D_WARNING)) {				\
@@ -2101,7 +2110,8 @@ struct ptlrpc_service_part {
 	/** NRS head for regular requests */
 	struct ptlrpc_nrs		scp_nrs_reg;
 	/** NRS head for HP requests; this is only valid for services that can
-	 *  handle HP requests */
+	 *  handle HP requests
+	 */
 	struct ptlrpc_nrs	       *scp_nrs_hp;
 
 	/** AT stuff */
@@ -2460,7 +2470,8 @@ struct ptlrpc_service_thr_conf {
 	/* "soft" limit for total threads number */
 	unsigned int			tc_nthrs_max;
 	/* user specified threads number, it will be validated due to
-	 * other members of this structure. */
+	 * other members of this structure.
+	 */
 	unsigned int			tc_nthrs_user;
 	/* set NUMA node affinity for service threads */
 	unsigned int			tc_cpu_affinity;
diff --git a/drivers/staging/lustre/lustre/include/obd.h b/drivers/staging/lustre/lustre/include/obd.h
index 1d9207b..e63366b 100644
--- a/drivers/staging/lustre/lustre/include/obd.h
+++ b/drivers/staging/lustre/lustre/include/obd.h
@@ -90,7 +90,8 @@ struct lov_stripe_md {
 	pid_t	    lsm_lock_owner; /* debugging */
 
 	/* maximum possible file size, might change as OSTs status changes,
-	 * e.g. disconnected, deactivated */
+	 * e.g. disconnected, deactivated
+	 */
 	__u64	    lsm_maxbytes;
 	struct {
 		/* Public members. */
@@ -159,7 +160,8 @@ struct obd_info {
 	/* An update callback which is called to update some data on upper
 	 * level. E.g. it is used for update lsm->lsm_oinfo at every received
 	 * request in osc level for enqueue requests. It is also possible to
-	 * update some caller data from LOV layer if needed. */
+	 * update some caller data from LOV layer if needed.
+	 */
 	obd_enqueue_update_f    oi_cb_up;
 };
 
@@ -240,7 +242,8 @@ struct client_obd {
 	struct obd_import       *cl_import; /* ptlrpc connection state */
 	int		      cl_conn_count;
 	/* max_mds_easize is purely a performance thing so we don't have to
-	 * call obd_size_diskmd() all the time. */
+	 * call obd_size_diskmd() all the time.
+	 */
 	int			 cl_default_mds_easize;
 	int			 cl_max_mds_easize;
 	int			 cl_default_mds_cookiesize;
@@ -260,7 +263,8 @@ struct client_obd {
 	/* since we allocate grant by blocks, we don't know how many grant will
 	 * be used to add a page into cache. As a solution, we reserve maximum
 	 * grant before trying to dirty a page and unreserve the rest.
-	 * See osc_{reserve|unreserve}_grant for details. */
+	 * See osc_{reserve|unreserve}_grant for details.
+	 */
 	long		 cl_reserved_grant;
 	struct list_head cl_cache_waiters; /* waiting for cache/grant */
 	unsigned long	 cl_next_shrink_grant;   /* jiffies */
@@ -268,14 +272,16 @@ struct client_obd {
 	int		 cl_grant_shrink_interval; /* seconds */
 
 	/* A chunk is an optimal size used by osc_extent to determine
-	 * the extent size. A chunk is max(PAGE_CACHE_SIZE, OST block size) */
+	 * the extent size. A chunk is max(PAGE_CACHE_SIZE, OST block size)
+	 */
 	int		  cl_chunkbits;
 	int		  cl_chunk;
 	int		  cl_extent_tax; /* extent overhead, by bytes */
 
 	/* keep track of objects that have lois that contain pages which
 	 * have been queued for async brw.  this lock also protects the
-	 * lists of osc_client_pages that hang off of the loi */
+	 * lists of osc_client_pages that hang off of the loi
+	 */
 	/*
 	 * ->cl_loi_list_lock protects consistency of
 	 * ->cl_loi_{ready,read,write}_list. ->ap_make_ready() and
@@ -379,8 +385,7 @@ struct echo_client_obd {
 
 /* Generic subset of OSTs */
 struct ost_pool {
-	__u32	      *op_array;      /* array of index of
-						   lov_obd->lov_tgts */
+	__u32	      *op_array;      /* array of index of lov_obd->lov_tgts */
 	unsigned int	op_count;      /* number of OSTs in the array */
 	unsigned int	op_size;       /* allocated size of lp_array */
 	struct rw_semaphore op_rw_sem;     /* to protect ost_pool use */
@@ -413,14 +418,16 @@ struct lov_qos {
 	struct lov_qos_rr   lq_rr;	  /* round robin qos data */
 	unsigned long       lq_dirty:1,     /* recalc qos data */
 			    lq_same_space:1,/* the ost's all have approx.
-					       the same space avail */
+					     * the same space avail
+					     */
 			    lq_reset:1,     /* zero current penalties */
 			    lq_statfs_in_progress:1; /* statfs op in
 							progress */
 	/* qos statfs data */
 	struct lov_statfs_data *lq_statfs_data;
-	wait_queue_head_t	 lq_statfs_waitq; /* waitqueue to notify statfs
-					      * requests completion */
+	wait_queue_head_t lq_statfs_waitq; /* waitqueue to notify statfs
+					    * requests completion
+					    */
 };
 
 struct lov_tgt_desc {
@@ -450,14 +457,14 @@ struct pool_desc {
 	struct list_head	    pool_list;	      /* serial access */
 	struct dentry		*pool_debugfs_entry;	/* file in debugfs */
 	struct obd_device    *pool_lobd;	/* obd of the lov/lod to which
-						*  this pool belongs */
+						 * this pool belongs
+						 */
 };
 
 struct lov_obd {
 	struct lov_desc	 desc;
 	struct lov_tgt_desc   **lov_tgts;	      /* sparse array */
-	struct ost_pool	 lov_packed;	    /* all OSTs in a packed
-							  array */
+	struct ost_pool	 lov_packed;	    /* all OSTs in a packed array */
 	struct mutex		lov_lock;
 	struct obd_connect_data lov_ocd;
 	atomic_t	    lov_refcount;
@@ -698,14 +705,14 @@ struct obd_device {
 	unsigned long obd_attached:1,      /* finished attach */
 		      obd_set_up:1,	/* finished setup */
 		      obd_version_recov:1, /* obd uses version checking */
-		      obd_replayable:1,    /* recovery is enabled; inform clients */
-		      obd_no_transno:1,    /* no committed-transno notification */
+		      obd_replayable:1,/* recovery is enabled; inform clients */
+		      obd_no_transno:1,  /* no committed-transno notification */
 		      obd_no_recov:1,      /* fail instead of retry messages */
 		      obd_stopping:1,      /* started cleanup */
 		      obd_starting:1,      /* started setup */
 		      obd_force:1,	 /* cleanup with > 0 obd refcount */
-		      obd_fail:1,	  /* cleanup with failover */
-		      obd_async_recov:1,   /* allow asynchronous orphan cleanup */
+		      obd_fail:1,	 /* cleanup with failover */
+		      obd_async_recov:1, /* allow asynchronous orphan cleanup */
 		      obd_no_conn:1,       /* deny new connections */
 		      obd_inactive:1,      /* device active/inactive
 					    * (for sysfs status only!!)
@@ -713,7 +720,8 @@ struct obd_device {
 		      obd_no_ir:1,	 /* no imperative recovery. */
 		      obd_process_conf:1;  /* device is processing mgs config */
 	/* use separate field as it is set in interrupt to don't mess with
-	 * protection of other bits using _bh lock */
+	 * protection of other bits using _bh lock
+	 */
 	unsigned long obd_recovery_expired:1;
 	/* uuid-export hash body */
 	struct cfs_hash	     *obd_uuid_hash;
@@ -906,7 +914,8 @@ struct md_op_data {
 	__u32		   op_npages;
 
 	/* used to transfer info between the stacks of MD client
-	 * see enum op_cli_flags */
+	 * see enum op_cli_flags
+	 */
 	__u32			op_cli_flags;
 
 	/* File object data version for HSM release, on client */
@@ -958,7 +967,8 @@ struct obd_ops {
 	/* connect to the target device with given connection
 	 * data. @ocd->ocd_connect_flags is modified to reflect flags actually
 	 * granted by the target, which are guaranteed to be a subset of flags
-	 * asked for. If @ocd == NULL, use default parameters. */
+	 * asked for. If @ocd == NULL, use default parameters.
+	 */
 	int (*connect)(const struct lu_env *env,
 		       struct obd_export **exp, struct obd_device *src,
 		       struct obd_uuid *cluuid, struct obd_connect_data *ocd,
@@ -1054,7 +1064,8 @@ struct obd_ops {
 	/*
 	 * NOTE: If adding ops, add another LPROCFS_OBD_OP_INIT() line
 	 * to lprocfs_alloc_obd_stats() in obdclass/lprocfs_status.c.
-	 * Also, add a wrapper function in include/linux/obd_class.h. */
+	 * Also, add a wrapper function in include/linux/obd_class.h.
+	 */
 };
 
 enum {
@@ -1298,7 +1309,8 @@ static inline bool filename_is_volatile(const char *name, int namelen, int *idx)
 	return true;
 bad_format:
 	/* bad format of mdt idx, we cannot return an error
-	 * to caller so we use hash algo */
+	 * to caller so we use hash algo
+	 */
 	CERROR("Bad volatile file name format: %s\n",
 	       name + LUSTRE_VOLATILE_HDR_LEN);
 	return false;
diff --git a/drivers/staging/lustre/lustre/include/obd_cksum.h b/drivers/staging/lustre/lustre/include/obd_cksum.h
index d61b4db..637fa22 100644
--- a/drivers/staging/lustre/lustre/include/obd_cksum.h
+++ b/drivers/staging/lustre/lustre/include/obd_cksum.h
@@ -63,7 +63,8 @@ static inline unsigned char cksum_obd2cfs(enum cksum_type cksum_type)
  * In case of an unsupported types/flags we fall back to ADLER
  * because that is supported by all clients since 1.8
  *
- * In case multiple algorithms are supported the best one is used. */
+ * In case multiple algorithms are supported the best one is used.
+ */
 static inline u32 cksum_type_pack(enum cksum_type cksum_type)
 {
 	unsigned int    performance = 0, tmp;
@@ -139,14 +140,16 @@ static inline enum cksum_type cksum_types_supported_client(void)
  * Currently, calling cksum_type_pack() with a mask will return the fastest
  * checksum type due to its benchmarking at libcfs module load.
  * Caution is advised, however, since what is fastest on a single client may
- * not be the fastest or most efficient algorithm on the server.  */
+ * not be the fastest or most efficient algorithm on the server.
+ */
 static inline enum cksum_type cksum_type_select(enum cksum_type cksum_types)
 {
 	return cksum_type_unpack(cksum_type_pack(cksum_types));
 }
 
 /* Checksum algorithm names. Must be defined in the same order as the
- * OBD_CKSUM_* flags. */
+ * OBD_CKSUM_* flags.
+ */
 #define DECLARE_CKSUM_NAME char *cksum_name[] = {"crc32", "adler", "crc32c"}
 
 #endif /* __OBD_H */
diff --git a/drivers/staging/lustre/lustre/include/obd_class.h b/drivers/staging/lustre/lustre/include/obd_class.h
index 163dd55..7ea5801 100644
--- a/drivers/staging/lustre/lustre/include/obd_class.h
+++ b/drivers/staging/lustre/lustre/include/obd_class.h
@@ -45,18 +45,22 @@
 #include "lprocfs_status.h"
 
 #define OBD_STATFS_NODELAY      0x0001  /* requests should be send without delay
-					 * and resends for avoid deadlocks */
+					 * and resends for avoid deadlocks
+					 */
 #define OBD_STATFS_FROM_CACHE   0x0002  /* the statfs callback should not update
-					 * obd_osfs_age */
+					 * obd_osfs_age
+					 */
 #define OBD_STATFS_PTLRPCD      0x0004  /* requests will be sent via ptlrpcd
 					 * instead of a specific set. This
 					 * means that we cannot rely on the set
 					 * interpret routine to be called.
 					 * lov_statfs_fini() must thus be called
-					 * by the request interpret routine */
+					 * by the request interpret routine
+					 */
 #define OBD_STATFS_FOR_MDT0	0x0008	/* The statfs is only for retrieving
-					 * information from MDT0. */
-#define OBD_FL_PUNCH    0x00000001      /* To indicate it is punch operation */
+					 * information from MDT0.
+					 */
+#define OBD_FL_PUNCH	    0x00000001  /* To indicate it is punch operation */
 
 /* OBD Device Declarations */
 extern struct obd_device *obd_devs[MAX_OBD_DEVICES];
@@ -160,8 +164,9 @@ struct config_llog_data {
 	struct mutex		    cld_lock;
 	int			 cld_type;
 	unsigned int		cld_stopping:1, /* we were told to stop
-						     * watching */
-				    cld_lostlock:1; /* lock not requeued */
+						 * watching
+						 */
+				cld_lostlock:1; /* lock not requeued */
 	char			cld_logname[0];
 };
 
@@ -275,7 +280,8 @@ void md_from_obdo(struct md_op_data *op_data, struct obdo *oa, u32 valid);
 #define CTXTP(ctxt, op) (ctxt)->loc_logops->lop_##op
 
 /* Ensure obd_setup: used for cleanup which must be called
-   while obd is stopping */
+ * while obd is stopping
+ */
 static inline int obd_check_dev(struct obd_device *obd)
 {
 	if (!obd) {
@@ -558,7 +564,8 @@ static inline int obd_cleanup(struct obd_device *obd)
 static inline void obd_cleanup_client_import(struct obd_device *obd)
 {
 	/* If we set up but never connected, the
-	   client import will not have been cleaned. */
+	 * client import will not have been cleaned.
+	 */
 	down_write(&obd->u.cli.cl_sem);
 	if (obd->u.cli.cl_import) {
 		struct obd_import *imp;
@@ -778,7 +785,8 @@ static inline int obd_setattr_rqset(struct obd_export *exp,
 }
 
 /* This adds all the requests into @set if @set != NULL, otherwise
-   all requests are sent asynchronously without waiting for response. */
+ * all requests are sent asynchronously without waiting for response.
+ */
 static inline int obd_setattr_async(struct obd_export *exp,
 				    struct obd_info *oinfo,
 				    struct obd_trans_info *oti,
@@ -848,7 +856,8 @@ static inline int obd_connect(const struct lu_env *env,
 {
 	int rc;
 	__u64 ocf = data ? data->ocd_connect_flags : 0; /* for post-condition
-						   * check */
+							 * check
+							 */
 
 	rc = obd_check_dev_active(obd);
 	if (rc)
@@ -871,8 +880,7 @@ static inline int obd_reconnect(const struct lu_env *env,
 				void *localdata)
 {
 	int rc;
-	__u64 ocf = d ? d->ocd_connect_flags : 0; /* for post-condition
-						   * check */
+	__u64 ocf = d ? d->ocd_connect_flags : 0; /* for post-condition check */
 
 	rc = obd_check_dev_active(obd);
 	if (rc)
@@ -1013,7 +1021,8 @@ static inline int obd_destroy_export(struct obd_export *exp)
 
 /* @max_age is the oldest time in jiffies that we accept using a cached data.
  * If the cache is older than @max_age we will get a new value from the
- * target.  Use a value of "cfs_time_current() + HZ" to guarantee freshness. */
+ * target.  Use a value of "cfs_time_current() + HZ" to guarantee freshness.
+ */
 static inline int obd_statfs_async(struct obd_export *exp,
 				   struct obd_info *oinfo,
 				   __u64 max_age,
@@ -1072,7 +1081,8 @@ static inline int obd_statfs_rqset(struct obd_export *exp,
 
 /* @max_age is the oldest time in jiffies that we accept using a cached data.
  * If the cache is older than @max_age we will get a new value from the
- * target.  Use a value of "cfs_time_current() + HZ" to guarantee freshness. */
+ * target.  Use a value of "cfs_time_current() + HZ" to guarantee freshness.
+ */
 static inline int obd_statfs(const struct lu_env *env, struct obd_export *exp,
 			     struct obd_statfs *osfs, __u64 max_age,
 			     __u32 flags)
@@ -1204,9 +1214,10 @@ static inline int obd_notify(struct obd_device *obd,
 		return rc;
 
 	/* the check for async_recov is a complete hack - I'm hereby
-	   overloading the meaning to also mean "this was called from
-	   mds_postsetup".  I know that my mds is able to handle notifies
-	   by this point, and it needs to get them to execute mds_postrecov. */
+	 * overloading the meaning to also mean "this was called from
+	 * mds_postsetup".  I know that my mds is able to handle notifies
+	 * by this point, and it needs to get them to execute mds_postrecov.
+	 */
 	if (!obd->obd_set_up && !obd->obd_async_recov) {
 		CDEBUG(D_HA, "obd %s not set up\n", obd->obd_name);
 		return -EINVAL;
@@ -1758,7 +1769,8 @@ struct lwp_register_item {
 /* I'm as embarrassed about this as you are.
  *
  * <shaver> // XXX do not look into _superhack with remaining eye
- * <shaver> // XXX if this were any uglier, I'd get my own show on MTV */
+ * <shaver> // XXX if this were any uglier, I'd get my own show on MTV
+ */
 extern int (*ptlrpc_put_connection_superhack)(struct ptlrpc_connection *c);
 
 /* obd_mount.c */
diff --git a/drivers/staging/lustre/lustre/include/obd_support.h b/drivers/staging/lustre/lustre/include/obd_support.h
index 506753c..225262fa 100644
--- a/drivers/staging/lustre/lustre/include/obd_support.h
+++ b/drivers/staging/lustre/lustre/include/obd_support.h
@@ -47,7 +47,8 @@ extern unsigned int obd_debug_peer_on_timeout;
 extern unsigned int obd_dump_on_timeout;
 extern unsigned int obd_dump_on_eviction;
 /* obd_timeout should only be used for recovery, not for
-   networking / disk / timings affected by load (use Adaptive Timeouts) */
+ * networking / disk / timings affected by load (use Adaptive Timeouts)
+ */
 extern unsigned int obd_timeout;	  /* seconds */
 extern unsigned int obd_timeout_set;
 extern unsigned int at_min;
@@ -104,18 +105,21 @@ extern char obd_jobid_var[];
  * failover targets the client only pings one server at a time, and pings
  * can be lost on a loaded network. Since eviction has serious consequences,
  * and there's no urgent need to evict a client just because it's idle, we
- * should be very conservative here. */
+ * should be very conservative here.
+ */
 #define PING_EVICT_TIMEOUT (PING_INTERVAL * 6)
 #define DISK_TIMEOUT 50	  /* Beyond this we warn about disk speed */
 #define CONNECTION_SWITCH_MIN 5U /* Connection switching rate limiter */
- /* Max connect interval for nonresponsive servers; ~50s to avoid building up
-    connect requests in the LND queues, but within obd_timeout so we don't
-    miss the recovery window */
+/* Max connect interval for nonresponsive servers; ~50s to avoid building up
+ * connect requests in the LND queues, but within obd_timeout so we don't
+ * miss the recovery window
+ */
 #define CONNECTION_SWITCH_MAX min(50U, max(CONNECTION_SWITCH_MIN, obd_timeout))
 #define CONNECTION_SWITCH_INC 5  /* Connection timeout backoff */
 /* In general this should be low to have quick detection of a system
-   running on a backup server. (If it's too low, import_select_connection
-   will increase the timeout anyhow.)  */
+ * running on a backup server. (If it's too low, import_select_connection
+ * will increase the timeout anyhow.)
+ */
 #define INITIAL_CONNECT_TIMEOUT max(CONNECTION_SWITCH_MIN, obd_timeout/20)
 /* The max delay between connects is SWITCH_MAX + SWITCH_INC + INITIAL */
 #define RECONNECT_DELAY_MAX (CONNECTION_SWITCH_MAX + CONNECTION_SWITCH_INC + \
-- 
2.1.0
