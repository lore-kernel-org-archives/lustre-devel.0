From: James Simmons <jsimmons@infradead.org>
Date: Thu, 31 Jan 2019 12:19:26 -0500
Subject: [lustre-devel] [PATCH 22/26] lustre: last batch to cleanup white
 spaces in internal headers
In-Reply-To: <1548955170-13456-1-git-send-email-jsimmons@infradead.org>
References: <1548955170-13456-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1548955170-13456-23-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

The internal headers are very messy and difficult to read. Remove
excess white space and properly align data structures so they are
easy on the eyes. This is the last batch since it covers many
lines of changes.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/obd.h        | 509 +++++++-------
 drivers/staging/lustre/lustre/include/obd_cksum.h  |   4 +-
 drivers/staging/lustre/lustre/include/obd_class.h  |  82 +--
 .../staging/lustre/lustre/include/obd_support.h    | 744 ++++++++++-----------
 drivers/staging/lustre/lustre/include/seq_range.h  |   2 +-
 5 files changed, 671 insertions(+), 670 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/obd.h b/drivers/staging/lustre/lustre/include/obd.h
index 0bb3cf8..171d2c2 100644
--- a/drivers/staging/lustre/lustre/include/obd.h
+++ b/drivers/staging/lustre/lustre/include/obd.h
@@ -53,20 +53,20 @@
 #define MAX_OBD_DEVICES 8192
 
 struct osc_async_rc {
-	int     ar_rc;
-	int     ar_force_sync;
-	u64   ar_min_xid;
+	int			ar_rc;
+	int			ar_force_sync;
+	u64			ar_min_xid;
 };
 
-struct lov_oinfo {		 /* per-stripe data structure */
-	struct ost_id   loi_oi;    /* object ID/Sequence on the target OST */
-	int loi_ost_idx;	   /* OST stripe index in lov_tgt_desc->tgts */
-	int loi_ost_gen;	   /* generation of this loi_ost_idx */
+struct lov_oinfo {				/* per-stripe data structure */
+	struct ost_id		loi_oi;		/* object ID/Sequence on the target OST */
+	int			loi_ost_idx;	/* OST stripe index in lov_tgt_desc->tgts */
+	int			loi_ost_gen;	/* generation of this loi_ost_idx */
 
-	unsigned long loi_kms_valid:1;
-	u64 loi_kms;	     /* known minimum size */
-	struct ost_lvb loi_lvb;
-	struct osc_async_rc     loi_ar;
+	unsigned long		loi_kms_valid:1;
+	u64			loi_kms;	/* known minimum size */
+	struct ost_lvb		loi_lvb;
+	struct osc_async_rc	loi_ar;
 };
 
 static inline void loi_kms_set(struct lov_oinfo *oinfo, u64 kms)
@@ -85,7 +85,7 @@ static inline void loi_kms_set(struct lov_oinfo *oinfo, u64 kms)
 /* obd info for a particular level (lov, osc). */
 struct obd_info {
 	/* OBD_STATFS_* flags */
-	u64		   oi_flags;
+	u64			oi_flags;
 	/* lsm data specific for every OSC. */
 	struct lov_stripe_md   *oi_md;
 	/* statfs data specific for every OSC, if needed at all. */
@@ -99,31 +99,31 @@ struct obd_info {
 };
 
 struct obd_type {
-	struct list_head typ_chain;
-	struct obd_ops *typ_dt_ops;
-	struct md_ops *typ_md_ops;
-	struct dentry *typ_debugfs_entry;
-	char *typ_name;
-	int  typ_refcnt;
-	struct lu_device_type *typ_lu;
-	spinlock_t obd_type_lock;
+	struct list_head	 typ_chain;
+	struct obd_ops		*typ_dt_ops;
+	struct md_ops		*typ_md_ops;
+	struct dentry		*typ_debugfs_entry;
+	char			*typ_name;
+	int			 typ_refcnt;
+	struct lu_device_type	*typ_lu;
+	spinlock_t		 obd_type_lock;
 	struct kobject		*typ_kobj;
 };
 
 struct brw_page {
-	u64 off;
-	struct page *pg;
-	unsigned int count;
-	u32 flag;
+	u64			off;
+	struct page	       *pg;
+	unsigned int		count;
+	u32			flag;
 };
 
 struct timeout_item {
-	enum timeout_event ti_event;
-	unsigned long	 ti_timeout;
-	timeout_cb_t       ti_cb;
-	void	      *ti_cb_data;
-	struct list_head	 ti_obd_list;
-	struct list_head	 ti_chain;
+	enum timeout_event	ti_event;
+	unsigned long		ti_timeout;
+	timeout_cb_t		ti_cb;
+	void		       *ti_cb_data;
+	struct list_head	ti_obd_list;
+	struct list_head	ti_chain;
 };
 
 #define OBD_MAX_RIF_DEFAULT	8
@@ -135,9 +135,9 @@ struct timeout_item {
 
 /* possible values for fo_sync_lock_cancel */
 enum {
-	NEVER_SYNC_ON_CANCEL = 0,
-	BLOCKING_SYNC_ON_CANCEL = 1,
-	ALWAYS_SYNC_ON_CANCEL = 2,
+	NEVER_SYNC_ON_CANCEL	= 0,
+	BLOCKING_SYNC_ON_CANCEL	= 1,
+	ALWAYS_SYNC_ON_CANCEL	= 2,
 	NUM_SYNC_ON_CANCEL_STATES
 };
 
@@ -159,10 +159,10 @@ enum obd_cl_sem_lock_class {
 struct mdc_rpc_lock;
 struct obd_import;
 struct client_obd {
-	struct rw_semaphore  cl_sem;
-	struct obd_uuid	  cl_target_uuid;
-	struct obd_import       *cl_import; /* ptlrpc connection state */
-	size_t			 cl_conn_count;
+	struct rw_semaphore	cl_sem;
+	struct obd_uuid		cl_target_uuid;
+	struct obd_import      *cl_import; /* ptlrpc connection state */
+	size_t			cl_conn_count;
 	/*
 	 * Cache maximum and default values for easize. This is
 	 * strictly a performance optimization to minimize calls to
@@ -203,22 +203,22 @@ struct client_obd {
 	 * grant before trying to dirty a page and unreserve the rest.
 	 * See osc_{reserve|unreserve}_grant for details.
 	 */
-	long		 cl_reserved_grant;
-	wait_queue_head_t cl_cache_waiters; /* waiting for cache/grant */
-	unsigned long	 cl_next_shrink_grant;   /* jiffies */
-	struct list_head cl_grant_shrink_list;  /* Timeout event list */
-	int		 cl_grant_shrink_interval; /* seconds */
+	long			cl_reserved_grant;
+	wait_queue_head_t	cl_cache_waiters;	/* waiting for cache/grant */
+	unsigned long		cl_next_shrink_grant;   /* jiffies */
+	struct list_head	cl_grant_shrink_list;	/* Timeout event list */
+	int			cl_grant_shrink_interval; /* seconds */
 
 	/* A chunk is an optimal size used by osc_extent to determine
 	 * the extent size. A chunk is max(PAGE_SIZE, OST block size)
 	 */
-	int		  cl_chunkbits;
+	int			cl_chunkbits;
 	/* extent insertion metadata overhead to be accounted in grant,
 	 * in bytes
 	 */
-	unsigned int	 cl_grant_extent_tax;
+	unsigned int		cl_grant_extent_tax;
 	/* maximum extent size, in number of pages */
-	unsigned int	 cl_max_extent_pages;
+	unsigned int		cl_max_extent_pages;
 
 	/* keep track of objects that have lois that contain pages which
 	 * have been queued for async brw.  this lock also protects the
@@ -238,29 +238,29 @@ struct client_obd {
 	 * NB by Jinshan: though field names are still _loi_, but actually
 	 * osc_object{}s are in the list.
 	 */
-	spinlock_t		       cl_loi_list_lock;
-	struct list_head	       cl_loi_ready_list;
-	struct list_head	       cl_loi_hp_ready_list;
-	struct list_head	       cl_loi_write_list;
-	struct list_head	       cl_loi_read_list;
-	u32			 cl_r_in_flight;
-	u32			 cl_w_in_flight;
+	spinlock_t		cl_loi_list_lock;
+	struct list_head	cl_loi_ready_list;
+	struct list_head	cl_loi_hp_ready_list;
+	struct list_head	cl_loi_write_list;
+	struct list_head	cl_loi_read_list;
+	u32			cl_r_in_flight;
+	u32			cl_w_in_flight;
 	/* just a sum of the loi/lop pending numbers to be exported by sysfs */
-	atomic_t	     cl_pending_w_pages;
-	atomic_t	     cl_pending_r_pages;
-	u32			 cl_max_pages_per_rpc;
-	u32			 cl_max_rpcs_in_flight;
-	struct obd_histogram     cl_read_rpc_hist;
-	struct obd_histogram     cl_write_rpc_hist;
-	struct obd_histogram     cl_read_page_hist;
-	struct obd_histogram     cl_write_page_hist;
-	struct obd_histogram     cl_read_offset_hist;
-	struct obd_histogram     cl_write_offset_hist;
+	atomic_t		cl_pending_w_pages;
+	atomic_t		cl_pending_r_pages;
+	u32			cl_max_pages_per_rpc;
+	u32			cl_max_rpcs_in_flight;
+	struct obd_histogram    cl_read_rpc_hist;
+	struct obd_histogram    cl_write_rpc_hist;
+	struct obd_histogram    cl_read_page_hist;
+	struct obd_histogram    cl_write_page_hist;
+	struct obd_histogram    cl_read_offset_hist;
+	struct obd_histogram    cl_write_offset_hist;
 
 	/* LRU for osc caching pages */
 	struct cl_client_cache	*cl_cache;
 	/** member of cl_cache->ccc_lru */
-	struct list_head	 cl_lru_osc;
+	struct list_head	cl_lru_osc;
 	/** # of available LRU slots left in the per-OSC cache.
 	 * Available LRU slots are shared by all OSCs of the same file system,
 	 * therefore this is a pointer to cl_client_cache::ccc_lru_left.
@@ -270,73 +270,74 @@ struct client_obd {
 	 * queue, or in transfer. Busy pages can't be discarded so they are not
 	 * in LRU cache.
 	 */
-	atomic_long_t		 cl_lru_busy;
+	atomic_long_t		cl_lru_busy;
 	/** # of LRU pages in the cache for this client_obd */
-	atomic_long_t		 cl_lru_in_list;
+	atomic_long_t		cl_lru_in_list;
 	/** # of threads are shrinking LRU cache. To avoid contention, it's not
 	 * allowed to have multiple threads shrinking LRU cache.
 	 */
-	atomic_t		 cl_lru_shrinkers;
+	atomic_t		cl_lru_shrinkers;
 	/** The time when this LRU cache was last used. */
-	time64_t		 cl_lru_last_used;
+	time64_t		cl_lru_last_used;
 	/** stats: how many reclaims have happened for this client_obd.
 	 * reclaim and shrink - shrink is async, voluntarily rebalancing;
 	 * reclaim is sync, initiated by IO thread when the LRU slots are
 	 * in shortage.
 	 */
-	u64			 cl_lru_reclaim;
+	u64			cl_lru_reclaim;
 	/** List of LRU pages for this client_obd */
-	struct list_head	 cl_lru_list;
+	struct list_head	cl_lru_list;
 	/** Lock for LRU page list */
-	spinlock_t		 cl_lru_list_lock;
+	spinlock_t		cl_lru_list_lock;
 	/** # of unstable pages in this client_obd.
 	 * An unstable page is a page state that WRITE RPC has finished but
 	 * the transaction has NOT yet committed.
 	 */
-	atomic_long_t		 cl_unstable_count;
+	atomic_long_t		cl_unstable_count;
 	/** Link to osc_shrinker_list */
-	struct list_head	 cl_shrink_list;
+	struct list_head	cl_shrink_list;
 
 	/* number of in flight destroy rpcs is limited to max_rpcs_in_flight */
-	atomic_t	     cl_destroy_in_flight;
-	wait_queue_head_t	      cl_destroy_waitq;
+	atomic_t		cl_destroy_in_flight;
+	wait_queue_head_t	cl_destroy_waitq;
 
 	struct mdc_rpc_lock     *cl_rpc_lock;
 
 	/* modify rpcs in flight
 	 * currently used for metadata only
 	 */
-	spinlock_t		 cl_mod_rpcs_lock;
-	u16			 cl_max_mod_rpcs_in_flight;
-	u16			 cl_mod_rpcs_in_flight;
-	u16			 cl_close_rpcs_in_flight;
-	wait_queue_head_t	 cl_mod_rpcs_waitq;
-	unsigned long		*cl_mod_tag_bitmap;
-	struct obd_histogram	 cl_mod_rpcs_hist;
+	spinlock_t		cl_mod_rpcs_lock;
+	u16			cl_max_mod_rpcs_in_flight;
+	u16			cl_mod_rpcs_in_flight;
+	u16			cl_close_rpcs_in_flight;
+	wait_queue_head_t	cl_mod_rpcs_waitq;
+	unsigned long	       *cl_mod_tag_bitmap;
+	struct obd_histogram	cl_mod_rpcs_hist;
 
 	/* mgc datastruct */
-	atomic_t	     cl_mgc_refcount;
-	struct obd_export       *cl_mgc_mgsexp;
+	atomic_t		cl_mgc_refcount;
+	struct obd_export      *cl_mgc_mgsexp;
 
 	/* checksumming for data sent over the network */
-	unsigned int		 cl_checksum:1,	/* 0 = disabled, 1 = enabled */
-				 cl_checksum_dump:1; /* same */
+	unsigned int		cl_checksum:1,	/* 0 = disabled, 1 = enabled */
+				cl_checksum_dump:1; /* same */
 	/* supported checksum types that are worked out at connect time */
-	u32		    cl_supp_cksum_types;
+	u32			cl_supp_cksum_types;
 	/* checksum algorithm to be used */
-	enum cksum_type	     cl_cksum_type;
+	enum cksum_type		cl_cksum_type;
 
 	/* also protected by the poorly named _loi_list_lock lock above */
-	struct osc_async_rc      cl_ar;
+	struct osc_async_rc     cl_ar;
 
 	/* sequence manager */
 	struct lu_client_seq    *cl_seq;
-	struct rw_semaphore	 cl_seq_rwsem;
+	struct rw_semaphore	cl_seq_rwsem;
+
+	atomic_t		cl_resends; /* resend count */
 
-	atomic_t	     cl_resends; /* resend count */
 
 	/* ptlrpc work for writeback in ptlrpcd context */
-	void		    *cl_writeback_work;
+	void			*cl_writeback_work;
 	void			*cl_lru_work;
 	/* hash tables for osc_quota_info */
 	struct rhashtable	cl_quota_hash[MAXQUOTAS];
@@ -347,55 +348,55 @@ struct client_obd {
 #define obd2cli_tgt(obd) ((char *)(obd)->u.cli.cl_target_uuid.uuid)
 
 struct obd_id_info {
-	u32   idx;
+	u32	idx;
 	u64	*data;
 };
 
 struct echo_client_obd {
 	struct obd_export	*ec_exp;   /* the local connection to osc/lov */
 	spinlock_t		ec_lock;
-	struct list_head	   ec_objects;
-	struct list_head	   ec_locks;
-	u64		ec_unique;
+	struct list_head	ec_objects;
+	struct list_head	ec_locks;
+	u64			ec_unique;
 };
 
 /* Generic subset of OSTs */
 struct ost_pool {
-	u32	      *op_array;      /* array of index of lov_obd->lov_tgts */
-	unsigned int	op_count;      /* number of OSTs in the array */
-	unsigned int	op_size;       /* allocated size of lp_array */
-	struct rw_semaphore op_rw_sem;     /* to protect ost_pool use */
+	u32			*op_array;  /* array of index of lov_obd->lov_tgts */
+	unsigned int		 op_count;  /* number of OSTs in the array */
+	unsigned int		 op_size;   /* allocated size of lp_array */
+	struct rw_semaphore	 op_rw_sem; /* to protect ost_pool use */
 };
 
 /* allow statfs data caching for 1 second */
 #define OBD_STATFS_CACHE_SECONDS 1
 
 struct lov_tgt_desc {
-	struct list_head	  ltd_kill;
-	struct obd_uuid     ltd_uuid;
-	struct obd_device  *ltd_obd;
-	struct obd_export  *ltd_exp;
-	u32	       ltd_gen;
-	u32	       ltd_index;   /* index in lov_obd->tgts */
-	unsigned long       ltd_active:1,/* is this target up for requests */
-			    ltd_activate:1,/* should  target be activated */
-			    ltd_reap:1;  /* should this target be deleted */
+	struct list_head	ltd_kill;
+	struct obd_uuid		ltd_uuid;
+	struct obd_device      *ltd_obd;
+	struct obd_export      *ltd_exp;
+	u32			ltd_gen;
+	u32			ltd_index;   /* index in lov_obd->tgts */
+	unsigned long		ltd_active:1,/* is this target up for requests */
+				ltd_activate:1,/* should  target be activated */
+				ltd_reap:1;  /* should this target be deleted */
 };
 
 struct lov_obd {
-	struct lov_desc	 desc;
-	struct lov_tgt_desc   **lov_tgts;	      /* sparse array */
-	struct ost_pool	 lov_packed;	    /* all OSTs in a packed array */
+	struct lov_desc		desc;
+	struct lov_tgt_desc   **lov_tgts;	/* sparse array */
+	struct ost_pool		lov_packed;	/* all OSTs in a packed array */
 	struct mutex		lov_lock;
 	struct obd_connect_data lov_ocd;
-	atomic_t	    lov_refcount;
-	u32		   lov_death_row;/* tgts scheduled to be deleted */
-	u32		   lov_tgt_size;   /* size of tgts array */
-	int		     lov_connects;
-	int		     lov_pool_count;
+	atomic_t		lov_refcount;
+	u32			lov_death_row;/* tgts scheduled to be deleted */
+	u32			lov_tgt_size;   /* size of tgts array */
+	int			lov_connects;
+	int			lov_pool_count;
 	struct rhashtable	lov_pools_hash_body; /* used for key access */
 	struct list_head	lov_pool_list; /* used for sequential access */
-	struct dentry		*lov_pool_debugfs_entry;
+	struct dentry	       *lov_pool_debugfs_entry;
 	enum lustre_sec_part    lov_sp_me;
 
 	/* Cached LRU and unstable data from upper layer */
@@ -403,12 +404,12 @@ struct lov_obd {
 
 	struct rw_semaphore     lov_notify_lock;
 
-	struct kobject		*lov_tgts_kobj;
+	struct kobject	       *lov_tgts_kobj;
 };
 
 struct lmv_tgt_desc {
 	struct obd_uuid		ltd_uuid;
-	struct obd_export	*ltd_exp;
+	struct obd_export      *ltd_exp;
 	u32			ltd_idx;
 	struct mutex		ltd_fid_mutex;
 	unsigned long		ltd_active:1; /* target up for requests */
@@ -433,52 +434,52 @@ struct lmv_obd {
 };
 
 struct niobuf_local {
-	u64		lnb_file_offset;
-	u32		lnb_page_offset;
-	u32		lnb_len;
-	u32		lnb_flags;
-	int		lnb_rc;
-	struct page	*lnb_page;
-	void		*lnb_data;
+	u64			lnb_file_offset;
+	u32			lnb_page_offset;
+	u32			lnb_len;
+	u32			lnb_flags;
+	int			lnb_rc;
+	struct page		*lnb_page;
+	void			*lnb_data;
 };
 
-#define LUSTRE_FLD_NAME	 "fld"
-#define LUSTRE_SEQ_NAME	 "seq"
+#define LUSTRE_FLD_NAME		"fld"
+#define LUSTRE_SEQ_NAME		"seq"
 
-#define LUSTRE_MDD_NAME	 "mdd"
+#define LUSTRE_MDD_NAME		"mdd"
 #define LUSTRE_OSD_LDISKFS_NAME	"osd-ldiskfs"
 #define LUSTRE_OSD_ZFS_NAME     "osd-zfs"
-#define LUSTRE_VVP_NAME	 "vvp"
-#define LUSTRE_LMV_NAME	 "lmv"
-#define LUSTRE_SLP_NAME	 "slp"
+#define LUSTRE_VVP_NAME		"vvp"
+#define LUSTRE_LMV_NAME		"lmv"
+#define LUSTRE_SLP_NAME		"slp"
 #define LUSTRE_LOD_NAME		"lod"
 #define LUSTRE_OSP_NAME		"osp"
 #define LUSTRE_LWP_NAME		"lwp"
 
 /* obd device type names */
  /* FIXME all the references to LUSTRE_MDS_NAME should be swapped with LUSTRE_MDT_NAME */
-#define LUSTRE_MDS_NAME	 "mds"
-#define LUSTRE_MDT_NAME	 "mdt"
-#define LUSTRE_MDC_NAME	 "mdc"
-#define LUSTRE_OSS_NAME	 "ost"       /* FIXME change name to oss */
-#define LUSTRE_OST_NAME	 "obdfilter" /* FIXME change name to ost */
-#define LUSTRE_OSC_NAME	 "osc"
-#define LUSTRE_LOV_NAME	 "lov"
-#define LUSTRE_MGS_NAME	 "mgs"
-#define LUSTRE_MGC_NAME	 "mgc"
+#define LUSTRE_MDS_NAME		"mds"
+#define LUSTRE_MDT_NAME		"mdt"
+#define LUSTRE_MDC_NAME		"mdc"
+#define LUSTRE_OSS_NAME		"ost"       /* FIXME change name to oss */
+#define LUSTRE_OST_NAME		"obdfilter" /* FIXME change name to ost */
+#define LUSTRE_OSC_NAME		"osc"
+#define LUSTRE_LOV_NAME		"lov"
+#define LUSTRE_MGS_NAME		"mgs"
+#define LUSTRE_MGC_NAME		"mgc"
 
 #define LUSTRE_ECHO_NAME	"obdecho"
 #define LUSTRE_ECHO_CLIENT_NAME "echo_client"
-#define LUSTRE_QMT_NAME	 "qmt"
+#define LUSTRE_QMT_NAME		"qmt"
 
 /* Constant obd names (post-rename) */
-#define LUSTRE_MDS_OBDNAME "MDS"
-#define LUSTRE_OSS_OBDNAME "OSS"
-#define LUSTRE_MGS_OBDNAME "MGS"
-#define LUSTRE_MGC_OBDNAME "MGC"
+#define LUSTRE_MDS_OBDNAME	"MDS"
+#define LUSTRE_OSS_OBDNAME	"OSS"
+#define LUSTRE_MGS_OBDNAME	"MGS"
+#define LUSTRE_MGC_OBDNAME	"MGC"
 
 /* Don't conflict with on-wire flags OBD_BRW_WRITE, etc */
-#define N_LOCAL_TEMP_PAGE 0x10000000
+#define N_LOCAL_TEMP_PAGE	0x10000000
 
 /*
  * Events signalled through obd_notify() upcall-chain.
@@ -516,21 +517,21 @@ struct target_recovery_data {
 };
 
 struct obd_llog_group {
-	struct llog_ctxt  *olg_ctxts[LLOG_MAX_CTXTS];
+	struct llog_ctxt       *olg_ctxts[LLOG_MAX_CTXTS];
 	wait_queue_head_t	olg_waitq;
-	spinlock_t	   olg_lock;
-	struct mutex	   olg_cat_processing;
+	spinlock_t		olg_lock;
+	struct mutex		olg_cat_processing;
 };
 
 /* corresponds to one of the obd's */
 #define OBD_DEVICE_MAGIC	0XAB5CD6EF
 
 struct lvfs_run_ctxt {
-	struct dt_device *dt;
+	struct dt_device       *dt;
 };
 
 struct obd_device {
-	struct obd_type	*obd_type;
+	struct obd_type		*obd_type;
 	u32			 obd_magic; /* OBD_DEVICE_MAGIC */
 	int			 obd_minor; /* device number: lctl dl */
 	struct lu_device	*obd_lu_dev;
@@ -562,35 +563,35 @@ struct obd_device {
 	 */
 	unsigned long obd_recovery_expired:1;
 	/* uuid-export hash body */
-	struct rhashtable	obd_uuid_hash;
-	wait_queue_head_t	     obd_refcount_waitq;
-	struct list_head	      obd_exports;
-	struct list_head	      obd_unlinked_exports;
-	struct list_head	      obd_delayed_exports;
-	atomic_t			obd_refcount;
-	int		     obd_num_exports;
-	spinlock_t		obd_nid_lock;
-	struct ldlm_namespace  *obd_namespace;
-	struct ptlrpc_client	obd_ldlm_client; /* XXX OST/MDS only */
+	struct rhashtable	 obd_uuid_hash;
+	wait_queue_head_t	 obd_refcount_waitq;
+	struct list_head	 obd_exports;
+	struct list_head	 obd_unlinked_exports;
+	struct list_head	 obd_delayed_exports;
+	atomic_t		 obd_refcount;
+	int			 obd_num_exports;
+	spinlock_t		 obd_nid_lock;
+	struct ldlm_namespace	*obd_namespace;
+	struct ptlrpc_client	 obd_ldlm_client; /* XXX OST/MDS only */
 	/* a spinlock is OK for what we do now, may need a semaphore later */
-	spinlock_t		obd_dev_lock; /* protect OBD bitfield above */
-	spinlock_t		obd_osfs_lock;
-	struct obd_statfs	obd_osfs;       /* locked by obd_osfs_lock */
-	u64			obd_osfs_age;
-	u64			obd_last_committed;
-	struct mutex		obd_dev_mutex;
-	struct lvfs_run_ctxt	obd_lvfs_ctxt;
-	struct obd_llog_group	obd_olg;	/* default llog group */
+	spinlock_t		 obd_dev_lock; /* protect OBD bitfield above */
+	spinlock_t		 obd_osfs_lock;
+	struct obd_statfs	 obd_osfs;       /* locked by obd_osfs_lock */
+	u64			 obd_osfs_age;
+	u64			 obd_last_committed;
+	struct mutex		 obd_dev_mutex;
+	struct lvfs_run_ctxt	 obd_lvfs_ctxt;
+	struct obd_llog_group	 obd_olg;	/* default llog group */
 	struct obd_device	*obd_observer;
-	struct rw_semaphore	obd_observer_link_sem;
+	struct rw_semaphore	 obd_observer_link_sem;
 	struct obd_notify_upcall obd_upcall;
-	struct obd_export       *obd_self_export;
+	struct obd_export	*obd_self_export;
 
 	union {
-		struct client_obd cli;
-		struct echo_client_obd echo_client;
-		struct lov_obd lov;
-		struct lmv_obd lmv;
+		struct client_obd	cli;
+		struct echo_client_obd	echo_client;
+		struct lov_obd		lov;
+		struct lmv_obd		lmv;
 	} u;
 
 	/* Fields used by LProcFS */
@@ -600,12 +601,12 @@ struct obd_device {
 
 	struct dentry		*obd_debugfs_entry;
 	struct dentry		*obd_svc_debugfs_entry;
-	struct lprocfs_stats  *obd_svc_stats;
-	const struct attribute	       **obd_attrs;
-	struct lprocfs_vars		*obd_vars;
-	atomic_t	   obd_evict_inprogress;
-	wait_queue_head_t	    obd_evict_inprogress_waitq;
-	struct list_head	obd_evict_list; /* protected with pet_lock */
+	struct lprocfs_stats	*obd_svc_stats;
+	const struct attribute **obd_attrs;
+	struct lprocfs_vars	*obd_vars;
+	atomic_t		 obd_evict_inprogress;
+	wait_queue_head_t	 obd_evict_inprogress_waitq;
+	struct list_head	 obd_evict_list; /* protected with pet_lock */
 
 	/**
 	 * Ldlm pool part. Save last calculated SLV and Limit.
@@ -620,39 +621,39 @@ struct obd_device {
 	 * A list of outstanding class_incref()'s against this obd. For
 	 * debugging.
 	 */
-	struct lu_ref	  obd_reference;
+	struct lu_ref		 obd_reference;
 
-	struct kset			obd_kset; /* sysfs object collection */
-	struct kobj_type		obd_ktype;
-	struct completion		obd_kobj_unregister;
+	struct kset		 obd_kset; /* sysfs object collection */
+	struct kobj_type	 obd_ktype;
+	struct completion	 obd_kobj_unregister;
 };
 
 int obd_uuid_add(struct obd_device *obd, struct obd_export *export);
 void obd_uuid_del(struct obd_device *obd, struct obd_export *export);
 
 /* get/set_info keys */
-#define KEY_ASYNC	       "async"
-#define KEY_CHANGELOG_CLEAR     "changelog_clear"
-#define KEY_FID2PATH	    "fid2path"
-#define KEY_CHECKSUM	    "checksum"
-#define KEY_CLEAR_FS	    "clear_fs"
-#define KEY_CONN_DATA	   "conn_data"
+#define KEY_ASYNC		"async"
+#define KEY_CHANGELOG_CLEAR	"changelog_clear"
+#define KEY_FID2PATH		"fid2path"
+#define KEY_CHECKSUM		"checksum"
+#define KEY_CLEAR_FS		"clear_fs"
+#define KEY_CONN_DATA		"conn_data"
 #define KEY_EVICT_BY_NID	"evict_by_nid"
-#define KEY_FIEMAP	      "fiemap"
-#define KEY_FLUSH_CTX	   "flush_ctx"
+#define KEY_FIEMAP		"fiemap"
+#define KEY_FLUSH_CTX		"flush_ctx"
 #define KEY_GRANT_SHRINK	"grant_shrink"
 #define KEY_HSM_COPYTOOL_SEND   "hsm_send"
 #define KEY_INIT_RECOV_BACKUP   "init_recov_bk"
-#define KEY_INTERMDS	    "inter_mds"
-#define KEY_LAST_ID	     "last_id"
+#define KEY_INTERMDS		"inter_mds"
+#define KEY_LAST_ID		"last_id"
 #define KEY_LAST_FID		"last_fid"
 #define KEY_MAX_EASIZE		"max_easize"
 #define KEY_DEFAULT_EASIZE	"default_easize"
-#define KEY_MGSSEC	      "mgssec"
-#define KEY_READ_ONLY	   "read-only"
-#define KEY_REGISTER_TARGET     "register_target"
-#define KEY_SET_FS	      "set_fs"
-#define KEY_TGT_COUNT	   "tgt_count"
+#define KEY_MGSSEC		"mgssec"
+#define KEY_READ_ONLY		"read-only"
+#define KEY_REGISTER_TARGET	"register_target"
+#define KEY_SET_FS		"set_fs"
+#define KEY_TGT_COUNT		"tgt_count"
 /*      KEY_SET_INFO in lustre_idl.h */
 #define KEY_SPTLRPC_CONF	"sptlrpc_conf"
 
@@ -698,11 +699,11 @@ enum md_op_flags {
 };
 
 enum md_cli_flags {
-	CLI_SET_MEA	= BIT(0),
-	CLI_RM_ENTRY	= BIT(1),
-	CLI_HASH64	= BIT(2),
-	CLI_API32	= BIT(3),
-	CLI_MIGRATE	= BIT(4),
+	CLI_SET_MEA		= BIT(0),
+	CLI_RM_ENTRY		= BIT(1),
+	CLI_HASH64		= BIT(2),
+	CLI_API32		= BIT(3),
+	CLI_MIGRATE		= BIT(4),
 };
 
 /**
@@ -716,39 +717,39 @@ static inline bool it_has_reply_body(const struct lookup_intent *it)
 }
 
 struct md_op_data {
-	struct lu_fid	   op_fid1; /* operation fid1 (usually parent) */
-	struct lu_fid	   op_fid2; /* operation fid2 (usually child) */
-	struct lu_fid	   op_fid3; /* 2 extra fids to find conflicting */
-	struct lu_fid	   op_fid4; /* to the operation locks. */
+	struct lu_fid		op_fid1; /* operation fid1 (usually parent) */
+	struct lu_fid		op_fid2; /* operation fid2 (usually child) */
+	struct lu_fid		op_fid3; /* 2 extra fids to find conflicting */
+	struct lu_fid		op_fid4; /* to the operation locks. */
 	u32			op_mds;  /* what mds server open will go to */
 	u32			op_mode;
-	struct lustre_handle    op_handle;
+	struct lustre_handle	op_handle;
 	s64			op_mod_time;
-	const char	     *op_name;
+	const char	       *op_name;
 	size_t			op_namelen;
 	struct lmv_stripe_md   *op_mea1;
 	struct lmv_stripe_md   *op_mea2;
-	u32		   op_suppgids[2];
-	u32		   op_fsuid;
-	u32		   op_fsgid;
-	kernel_cap_t	       op_cap;
-	void		   *op_data;
+	u32			op_suppgids[2];
+	u32			op_fsuid;
+	u32			op_fsgid;
+	kernel_cap_t		op_cap;
+	void		       *op_data;
 	size_t			op_data_size;
 
 	/* iattr fields and blocks. */
-	struct iattr	    op_attr;
+	struct iattr		op_attr;
 	enum op_xvalid		op_xvalid;	/* eXtra validity flags */
-	unsigned int	    op_attr_flags;
-	u64		   op_valid;
-	loff_t		  op_attr_blocks;
+	unsigned int		op_attr_flags;
+	u64			op_valid;
+	loff_t			op_attr_blocks;
 
-	u32		   op_flags;
+	u32			op_flags;
 
 	/* Various operation flags. */
 	enum mds_op_bias        op_bias;
 
 	/* Used by readdir */
-	u64		   op_offset;
+	u64			op_offset;
 
 	/* used to transfer info between the stacks of MD client
 	 * see enum op_cli_flags
@@ -780,14 +781,14 @@ struct md_callback {
 /* metadata stat-ahead */
 
 struct md_enqueue_info {
-	struct md_op_data       mi_data;
-	struct lookup_intent    mi_it;
-	struct lustre_handle    mi_lockh;
-	struct inode	   *mi_dir;
+	struct md_op_data		mi_data;
+	struct lookup_intent		mi_it;
+	struct lustre_handle		mi_lockh;
+	struct inode		       *mi_dir;
 	struct ldlm_enqueue_info	mi_einfo;
 	int (*mi_cb)(struct ptlrpc_request *req,
 		     struct md_enqueue_info *minfo, int rc);
-	void			*mi_cbdata;
+	void			       *mi_cbdata;
 };
 
 struct obd_ops {
@@ -886,33 +887,33 @@ struct obd_ops {
 
 /* lmv structures */
 struct lustre_md {
-	struct mdt_body	 *body;
-	struct lu_buf		 layout;
-	struct lmv_stripe_md    *lmv;
+	struct mdt_body			*body;
+	struct lu_buf			 layout;
+	struct lmv_stripe_md		*lmv;
 #ifdef CONFIG_FS_POSIX_ACL
-	struct posix_acl	*posix_acl;
+	struct posix_acl		*posix_acl;
 #endif
-	struct mdt_remote_perm  *remote_perm;
+	struct mdt_remote_perm		*remote_perm;
 };
 
 struct md_open_data {
-	struct obd_client_handle *mod_och;
-	struct ptlrpc_request    *mod_open_req;
-	struct ptlrpc_request    *mod_close_req;
-	atomic_t		  mod_refcount;
-	bool			  mod_is_create;
+	struct obd_client_handle	*mod_och;
+	struct ptlrpc_request		*mod_open_req;
+	struct ptlrpc_request		*mod_close_req;
+	atomic_t			 mod_refcount;
+	bool				 mod_is_create;
 };
 
 struct obd_client_handle {
-	struct lustre_handle	 och_fh;
-	struct lu_fid		 och_fid;
-	struct md_open_data	*och_mod;
-	struct lustre_handle	 och_lease_handle; /* open lock for lease */
-	u32			 och_magic;
-	fmode_t			 och_flags;
+	struct lustre_handle		och_fh;
+	struct lu_fid			och_fid;
+	struct md_open_data	       *och_mod;
+	struct lustre_handle		och_lease_handle; /* open lock for lease */
+	u32				och_magic;
+	fmode_t				och_flags;
 };
 
-#define OBD_CLIENT_HANDLE_MAGIC 0xd15ea5ed
+#define OBD_CLIENT_HANDLE_MAGIC	0xd15ea5ed
 
 struct lookup_intent;
 struct cl_attr;
@@ -1015,13 +1016,13 @@ static inline struct md_open_data *obd_mod_alloc(void)
 }
 
 #define obd_mod_get(mod) atomic_inc(&(mod)->mod_refcount)
-#define obd_mod_put(mod)					\
-({							      \
-	if (atomic_dec_and_test(&(mod)->mod_refcount)) {	  \
-		if ((mod)->mod_open_req)			  \
-			ptlrpc_req_finished((mod)->mod_open_req);   \
-		kfree(mod);			      \
-	}						       \
+#define obd_mod_put(mod)						\
+({									\
+	if (atomic_dec_and_test(&(mod)->mod_refcount)) {		\
+		if ((mod)->mod_open_req)				\
+			ptlrpc_req_finished((mod)->mod_open_req);	\
+		kfree(mod);						\
+	}								\
 })
 
 void obdo_from_inode(struct obdo *dst, struct inode *src, u32 valid);
@@ -1050,8 +1051,8 @@ static inline const char *lu_dev_name(const struct lu_device *lu_dev)
 static inline bool filename_is_volatile(const char *name, size_t namelen,
 					int *idx)
 {
-	const char	*start;
-	char		*end;
+	const char *start;
+	char *end;
 
 	if (strncmp(name, LUSTRE_VOLATILE_HDR, LUSTRE_VOLATILE_HDR_LEN) != 0)
 		return false;
diff --git a/drivers/staging/lustre/lustre/include/obd_cksum.h b/drivers/staging/lustre/lustre/include/obd_cksum.h
index e5f7bb2..26a9555 100644
--- a/drivers/staging/lustre/lustre/include/obd_cksum.h
+++ b/drivers/staging/lustre/lustre/include/obd_cksum.h
@@ -65,8 +65,8 @@ static inline unsigned char cksum_obd2cfs(enum cksum_type cksum_type)
  */
 static inline u32 cksum_type_pack(enum cksum_type cksum_type)
 {
-	unsigned int    performance = 0, tmp;
-	u32		flag = OBD_FL_CKSUM_ADLER;
+	unsigned int performance = 0, tmp;
+	u32 flag = OBD_FL_CKSUM_ADLER;
 
 	if (cksum_type & OBD_CKSUM_CRC32) {
 		tmp = cfs_crypto_hash_speed(cksum_obd2cfs(OBD_CKSUM_CRC32));
diff --git a/drivers/staging/lustre/lustre/include/obd_class.h b/drivers/staging/lustre/lustre/include/obd_class.h
index b64ba8b..30b3e2c 100644
--- a/drivers/staging/lustre/lustre/include/obd_class.h
+++ b/drivers/staging/lustre/lustre/include/obd_class.h
@@ -144,22 +144,22 @@ int class_config_llog_handler(const struct lu_env *env,
 /* obdecho */
 void lprocfs_echo_init_vars(struct lprocfs_static_vars *lvars);
 
-#define CFG_F_START     0x01   /* Set when we start updating from a log */
-#define CFG_F_MARKER    0x02   /* We are within a maker */
-#define CFG_F_SKIP      0x04   /* We should ignore this cfg command */
-#define CFG_F_COMPAT146 0x08   /* Allow old-style logs */
-#define CFG_F_EXCLUDE   0x10   /* OST exclusion list */
+#define CFG_F_START	0x01   /* Set when we start updating from a log */
+#define CFG_F_MARKER	0x02   /* We are within a maker */
+#define CFG_F_SKIP	0x04   /* We should ignore this cfg command */
+#define CFG_F_COMPAT146	0x08   /* Allow old-style logs */
+#define CFG_F_EXCLUDE	0x10   /* OST exclusion list */
 
 /* Passed as data param to class_config_parse_llog */
 struct config_llog_instance {
-	char		   *cfg_obdname;
-	void		   *cfg_instance;
-	struct super_block *cfg_sb;
-	struct obd_uuid     cfg_uuid;
-	llog_cb_t	    cfg_callback;
-	int		    cfg_last_idx; /* for partial llog processing */
-	int		    cfg_flags;
-	u32		    cfg_sub_clds;
+	char		       *cfg_obdname;
+	void		       *cfg_instance;
+	struct super_block     *cfg_sb;
+	struct obd_uuid		cfg_uuid;
+	llog_cb_t		cfg_callback;
+	int			cfg_last_idx; /* for partial llog processing */
+	int			cfg_flags;
+	u32			cfg_sub_clds;
 };
 
 int class_config_parse_llog(const struct lu_env *env, struct llog_ctxt *ctxt,
@@ -181,31 +181,31 @@ int class_config_parse_llog(const struct lu_env *env, struct llog_ctxt *ctxt,
 
 /* list of active configuration logs  */
 struct config_llog_data {
-	struct ldlm_res_id	    cld_resid;
-	struct config_llog_instance cld_cfg;
-	struct list_head	    cld_list_chain;
-	atomic_t		    cld_refcount;
-	struct config_llog_data    *cld_sptlrpc;/* depended sptlrpc log */
-	struct config_llog_data	   *cld_params;	/* common parameters log */
-	struct config_llog_data    *cld_recover;/* imperative recover log */
-	struct obd_export	   *cld_mgcexp;
-	struct mutex		    cld_lock;
-	int			    cld_type;
-	unsigned int		    cld_stopping:1, /*
-						     * we were told to stop
-						     * watching
-						     */
-				    cld_lostlock:1; /* lock not requeued */
-	char			    cld_logname[0];
+	struct ldlm_res_id		cld_resid;
+	struct config_llog_instance	cld_cfg;
+	struct list_head		cld_list_chain;
+	atomic_t			cld_refcount;
+	struct config_llog_data	       *cld_sptlrpc;	/* depended sptlrpc log */
+	struct config_llog_data	       *cld_params;	/* common parameters log */
+	struct config_llog_data	       *cld_recover;	/* imperative recover log */
+	struct obd_export	       *cld_mgcexp;
+	struct mutex			cld_lock;
+	int				cld_type;
+	unsigned int			cld_stopping:1, /*
+							 * we were told to stop
+							 * watching
+							 */
+					cld_lostlock:1; /* lock not requeued */
+	char				cld_logname[0];
 };
 
 struct lustre_profile {
-	struct list_head lp_list;
-	char		*lp_profile;
-	char		*lp_dt;
-	char		*lp_md;
-	int		 lp_refs;
-	bool		 lp_list_deleted;
+	struct list_head		lp_list;
+	char			       *lp_profile;
+	char			       *lp_dt;
+	char			       *lp_md;
+	int				lp_refs;
+	bool				lp_list_deleted;
 };
 
 struct lustre_profile *class_get_profile(const char *prof);
@@ -423,7 +423,7 @@ static inline int obd_setup(struct obd_device *obd, struct lustre_cfg *cfg)
 
 	ldt = obd->obd_type->typ_lu;
 	if (ldt) {
-		struct lu_context  session_ctx;
+		struct lu_context session_ctx;
 		struct lu_env env;
 
 		lu_context_init(&session_ctx, LCT_SESSION | LCT_SERVER_SESSION);
@@ -1642,11 +1642,11 @@ static inline int md_unpackmd(struct obd_export *exp,
 typedef int (*register_lwp_cb)(void *data);
 
 struct lwp_register_item {
-	struct obd_export **lri_exp;
-	register_lwp_cb	    lri_cb_func;
-	void		   *lri_cb_data;
-	struct list_head    lri_list;
-	char		    lri_name[MTI_NAME_MAXLEN];
+	struct obd_export     **lri_exp;
+	register_lwp_cb		lri_cb_func;
+	void		       *lri_cb_data;
+	struct list_head	lri_list;
+	char			lri_name[MTI_NAME_MAXLEN];
 };
 
 /*
diff --git a/drivers/staging/lustre/lustre/include/obd_support.h b/drivers/staging/lustre/lustre/include/obd_support.h
index 93a3745..3e15cac 100644
--- a/drivers/staging/lustre/lustre/include/obd_support.h
+++ b/drivers/staging/lustre/lustre/include/obd_support.h
@@ -59,151 +59,151 @@
 
 /* Some hash init argument constants */
 /* Timeout definitions */
-#define OBD_TIMEOUT_DEFAULT	     100
+#define OBD_TIMEOUT_DEFAULT	100
 /* Time to wait for all clients to reconnect during recovery (hard limit) */
-#define OBD_RECOVERY_TIME_HARD	  (obd_timeout * 9)
+#define OBD_RECOVERY_TIME_HARD	(obd_timeout * 9)
 /* Time to wait for all clients to reconnect during recovery (soft limit) */
 /* Should be very conservative; must catch the first reconnect after reboot */
-#define OBD_RECOVERY_TIME_SOFT	  (obd_timeout * 3)
+#define OBD_RECOVERY_TIME_SOFT	(obd_timeout * 3)
 /* Change recovery-small 26b time if you change this */
-#define PING_INTERVAL max(obd_timeout / 4, 1U)
+#define PING_INTERVAL		max(obd_timeout / 4, 1U)
 /* a bit more than maximal journal commit time in seconds */
-#define PING_INTERVAL_SHORT min(PING_INTERVAL, 7U)
+#define PING_INTERVAL_SHORT	min(PING_INTERVAL, 7U)
 /* Client may skip 1 ping; we must wait at least 2.5. But for multiple
  * failover targets the client only pings one server at a time, and pings
  * can be lost on a loaded network. Since eviction has serious consequences,
  * and there's no urgent need to evict a client just because it's idle, we
  * should be very conservative here.
  */
-#define PING_EVICT_TIMEOUT (PING_INTERVAL * 6)
-#define DISK_TIMEOUT 50	  /* Beyond this we warn about disk speed */
-#define CONNECTION_SWITCH_MIN 5U /* Connection switching rate limiter */
+#define PING_EVICT_TIMEOUT	(PING_INTERVAL * 6)
+#define DISK_TIMEOUT		50 /* Beyond this we warn about disk speed */
+#define CONNECTION_SWITCH_MIN	5U /* Connection switching rate limiter */
 /* Max connect interval for nonresponsive servers; ~50s to avoid building up
  * connect requests in the LND queues, but within obd_timeout so we don't
  * miss the recovery window
  */
-#define CONNECTION_SWITCH_MAX min(50U, max(CONNECTION_SWITCH_MIN, obd_timeout))
-#define CONNECTION_SWITCH_INC 5  /* Connection timeout backoff */
+#define CONNECTION_SWITCH_MAX	min(50U, max(CONNECTION_SWITCH_MIN, obd_timeout))
+#define CONNECTION_SWITCH_INC	5  /* Connection timeout backoff */
 /* In general this should be low to have quick detection of a system
  * running on a backup server. (If it's too low, import_select_connection
  * will increase the timeout anyhow.)
  */
-#define INITIAL_CONNECT_TIMEOUT max(CONNECTION_SWITCH_MIN, obd_timeout / 20)
+#define INITIAL_CONNECT_TIMEOUT	max(CONNECTION_SWITCH_MIN, obd_timeout / 20)
 /* The max delay between connects is SWITCH_MAX + SWITCH_INC + INITIAL */
-#define RECONNECT_DELAY_MAX (CONNECTION_SWITCH_MAX + CONNECTION_SWITCH_INC + \
-			     INITIAL_CONNECT_TIMEOUT)
+#define RECONNECT_DELAY_MAX	(CONNECTION_SWITCH_MAX + CONNECTION_SWITCH_INC + \
+				 INITIAL_CONNECT_TIMEOUT)
 /* The min time a target should wait for clients to reconnect in recovery */
-#define OBD_RECOVERY_TIME_MIN    (2 * RECONNECT_DELAY_MAX)
-#define OBD_IR_FACTOR_MIN	 1
-#define OBD_IR_FACTOR_MAX	 10
-#define OBD_IR_FACTOR_DEFAULT    (OBD_IR_FACTOR_MAX / 2)
+#define OBD_RECOVERY_TIME_MIN	(2 * RECONNECT_DELAY_MAX)
+#define OBD_IR_FACTOR_MIN	1
+#define OBD_IR_FACTOR_MAX	10
+#define OBD_IR_FACTOR_DEFAULT	(OBD_IR_FACTOR_MAX / 2)
 /* default timeout for the MGS to become IR_FULL */
-#define OBD_IR_MGS_TIMEOUT       (4 * obd_timeout)
-#define LONG_UNLINK 300	  /* Unlink should happen before now */
+#define OBD_IR_MGS_TIMEOUT	(4 * obd_timeout)
+#define LONG_UNLINK		300 /* Unlink should happen before now */
 
 /**
  * Time interval of shrink, if the client is "idle" more than this interval,
  * then the ll_grant thread will return the requested grant space to filter
  */
-#define GRANT_SHRINK_INTERVAL	    1200/*20 minutes*/
-
-#define OBD_FAIL_MDS		     0x100
-#define OBD_FAIL_MDS_HANDLE_UNPACK       0x101
-#define OBD_FAIL_MDS_GETATTR_NET	 0x102
-#define OBD_FAIL_MDS_GETATTR_PACK	0x103
-#define OBD_FAIL_MDS_READPAGE_NET	0x104
-#define OBD_FAIL_MDS_READPAGE_PACK       0x105
-#define OBD_FAIL_MDS_SENDPAGE	    0x106
-#define OBD_FAIL_MDS_REINT_NET	   0x107
-#define OBD_FAIL_MDS_REINT_UNPACK	0x108
-#define OBD_FAIL_MDS_REINT_SETATTR       0x109
-#define OBD_FAIL_MDS_REINT_SETATTR_WRITE 0x10a
-#define OBD_FAIL_MDS_REINT_CREATE	0x10b
-#define OBD_FAIL_MDS_REINT_CREATE_WRITE  0x10c
-#define OBD_FAIL_MDS_REINT_UNLINK	0x10d
-#define OBD_FAIL_MDS_REINT_UNLINK_WRITE  0x10e
-#define OBD_FAIL_MDS_REINT_LINK	  0x10f
-#define OBD_FAIL_MDS_REINT_LINK_WRITE    0x110
-#define OBD_FAIL_MDS_REINT_RENAME	0x111
-#define OBD_FAIL_MDS_REINT_RENAME_WRITE  0x112
-#define OBD_FAIL_MDS_OPEN_NET	    0x113
-#define OBD_FAIL_MDS_OPEN_PACK	   0x114
-#define OBD_FAIL_MDS_CLOSE_NET	   0x115
-#define OBD_FAIL_MDS_CLOSE_PACK	  0x116
-#define OBD_FAIL_MDS_CONNECT_NET	 0x117
-#define OBD_FAIL_MDS_CONNECT_PACK	0x118
-#define OBD_FAIL_MDS_REINT_NET_REP       0x119
-#define OBD_FAIL_MDS_DISCONNECT_NET      0x11a
-#define OBD_FAIL_MDS_GET_ROOT_NET	0x11b
-#define OBD_FAIL_MDS_GET_ROOT_PACK	0x11c
-#define OBD_FAIL_MDS_STATFS_PACK	 0x11d
-#define OBD_FAIL_MDS_STATFS_NET	  0x11e
-#define OBD_FAIL_MDS_GETATTR_NAME_NET    0x11f
-#define OBD_FAIL_MDS_PIN_NET	     0x120
-#define OBD_FAIL_MDS_UNPIN_NET	   0x121
-#define OBD_FAIL_MDS_ALL_REPLY_NET       0x122
-#define OBD_FAIL_MDS_ALL_REQUEST_NET     0x123
-#define OBD_FAIL_MDS_SYNC_NET	    0x124
-#define OBD_FAIL_MDS_SYNC_PACK	   0x125
+#define GRANT_SHRINK_INTERVAL	1200/*20 minutes*/
+
+#define OBD_FAIL_MDS					0x100
+#define OBD_FAIL_MDS_HANDLE_UNPACK			0x101
+#define OBD_FAIL_MDS_GETATTR_NET			0x102
+#define OBD_FAIL_MDS_GETATTR_PACK			0x103
+#define OBD_FAIL_MDS_READPAGE_NET			0x104
+#define OBD_FAIL_MDS_READPAGE_PACK			0x105
+#define OBD_FAIL_MDS_SENDPAGE				0x106
+#define OBD_FAIL_MDS_REINT_NET				0x107
+#define OBD_FAIL_MDS_REINT_UNPACK			0x108
+#define OBD_FAIL_MDS_REINT_SETATTR			0x109
+#define OBD_FAIL_MDS_REINT_SETATTR_WRITE		0x10a
+#define OBD_FAIL_MDS_REINT_CREATE			0x10b
+#define OBD_FAIL_MDS_REINT_CREATE_WRITE			0x10c
+#define OBD_FAIL_MDS_REINT_UNLINK			0x10d
+#define OBD_FAIL_MDS_REINT_UNLINK_WRITE			0x10e
+#define OBD_FAIL_MDS_REINT_LINK				0x10f
+#define OBD_FAIL_MDS_REINT_LINK_WRITE			0x110
+#define OBD_FAIL_MDS_REINT_RENAME			0x111
+#define OBD_FAIL_MDS_REINT_RENAME_WRITE			0x112
+#define OBD_FAIL_MDS_OPEN_NET				0x113
+#define OBD_FAIL_MDS_OPEN_PACK				0x114
+#define OBD_FAIL_MDS_CLOSE_NET				0x115
+#define OBD_FAIL_MDS_CLOSE_PACK				0x116
+#define OBD_FAIL_MDS_CONNECT_NET			0x117
+#define OBD_FAIL_MDS_CONNECT_PACK			0x118
+#define OBD_FAIL_MDS_REINT_NET_REP			0x119
+#define OBD_FAIL_MDS_DISCONNECT_NET			0x11a
+#define OBD_FAIL_MDS_GET_ROOT_NET			0x11b
+#define OBD_FAIL_MDS_GET_ROOT_PACK			0x11c
+#define OBD_FAIL_MDS_STATFS_PACK			0x11d
+#define OBD_FAIL_MDS_STATFS_NET				0x11e
+#define OBD_FAIL_MDS_GETATTR_NAME_NET			0x11f
+#define OBD_FAIL_MDS_PIN_NET				0x120
+#define OBD_FAIL_MDS_UNPIN_NET				0x121
+#define OBD_FAIL_MDS_ALL_REPLY_NET			0x122
+#define OBD_FAIL_MDS_ALL_REQUEST_NET			0x123
+#define OBD_FAIL_MDS_SYNC_NET				0x124
+#define OBD_FAIL_MDS_SYNC_PACK				0x125
 /*	OBD_FAIL_MDS_DONE_WRITING_NET	0x126 obsolete since 2.8.0 */
 /*	OBD_FAIL_MDS_DONE_WRITING_PACK	0x127 obsolete since 2.8.0 */
-#define OBD_FAIL_MDS_ALLOC_OBDO	  0x128
-#define OBD_FAIL_MDS_PAUSE_OPEN	  0x129
-#define OBD_FAIL_MDS_STATFS_LCW_SLEEP    0x12a
-#define OBD_FAIL_MDS_OPEN_CREATE	 0x12b
-#define OBD_FAIL_MDS_OST_SETATTR	 0x12c
+#define OBD_FAIL_MDS_ALLOC_OBDO				0x128
+#define OBD_FAIL_MDS_PAUSE_OPEN				0x129
+#define OBD_FAIL_MDS_STATFS_LCW_SLEEP			0x12a
+#define OBD_FAIL_MDS_OPEN_CREATE			0x12b
+#define OBD_FAIL_MDS_OST_SETATTR			0x12c
 /*	OBD_FAIL_MDS_QUOTACHECK_NET      0x12d obsolete since 2.4 */
-#define OBD_FAIL_MDS_QUOTACTL_NET	0x12e
-#define OBD_FAIL_MDS_CLIENT_ADD	  0x12f
-#define OBD_FAIL_MDS_GETXATTR_NET	0x130
-#define OBD_FAIL_MDS_GETXATTR_PACK       0x131
-#define OBD_FAIL_MDS_SETXATTR_NET	0x132
-#define OBD_FAIL_MDS_SETXATTR	    0x133
-#define OBD_FAIL_MDS_SETXATTR_WRITE      0x134
-#define OBD_FAIL_MDS_FS_SETUP	    0x135
-#define OBD_FAIL_MDS_RESEND	      0x136
-#define OBD_FAIL_MDS_LLOG_CREATE_FAILED  0x137
-#define OBD_FAIL_MDS_LOV_SYNC_RACE       0x138
-#define OBD_FAIL_MDS_OSC_PRECREATE       0x139
-#define OBD_FAIL_MDS_LLOG_SYNC_TIMEOUT   0x13a
-#define OBD_FAIL_MDS_CLOSE_NET_REP       0x13b
-#define OBD_FAIL_MDS_BLOCK_QUOTA_REQ     0x13c
-#define OBD_FAIL_MDS_DROP_QUOTA_REQ      0x13d
-#define OBD_FAIL_MDS_REMOVE_COMMON_EA    0x13e
-#define OBD_FAIL_MDS_ALLOW_COMMON_EA_SETTING   0x13f
-#define OBD_FAIL_MDS_FAIL_LOV_LOG_ADD    0x140
-#define OBD_FAIL_MDS_LOV_PREP_CREATE     0x141
-#define OBD_FAIL_MDS_REINT_DELAY	 0x142
-#define OBD_FAIL_MDS_READLINK_EPROTO     0x143
-#define OBD_FAIL_MDS_OPEN_WAIT_CREATE    0x144
-#define OBD_FAIL_MDS_PDO_LOCK	    0x145
-#define OBD_FAIL_MDS_PDO_LOCK2	   0x146
-#define OBD_FAIL_MDS_OSC_CREATE_FAIL     0x147
-#define OBD_FAIL_MDS_NEGATIVE_POSITIVE	 0x148
-#define OBD_FAIL_MDS_HSM_STATE_GET_NET		0x149
-#define OBD_FAIL_MDS_HSM_STATE_SET_NET		0x14a
-#define OBD_FAIL_MDS_HSM_PROGRESS_NET		0x14b
-#define OBD_FAIL_MDS_HSM_REQUEST_NET		0x14c
-#define OBD_FAIL_MDS_HSM_CT_REGISTER_NET	0x14d
-#define OBD_FAIL_MDS_HSM_CT_UNREGISTER_NET	0x14e
-#define OBD_FAIL_MDS_SWAP_LAYOUTS_NET		0x14f
-#define OBD_FAIL_MDS_HSM_ACTION_NET		0x150
-#define OBD_FAIL_MDS_CHANGELOG_INIT		0x151
+#define OBD_FAIL_MDS_QUOTACTL_NET			0x12e
+#define OBD_FAIL_MDS_CLIENT_ADD				0x12f
+#define OBD_FAIL_MDS_GETXATTR_NET			0x130
+#define OBD_FAIL_MDS_GETXATTR_PACK			0x131
+#define OBD_FAIL_MDS_SETXATTR_NET			0x132
+#define OBD_FAIL_MDS_SETXATTR				0x133
+#define OBD_FAIL_MDS_SETXATTR_WRITE			0x134
+#define OBD_FAIL_MDS_FS_SETUP				0x135
+#define OBD_FAIL_MDS_RESEND				0x136
+#define OBD_FAIL_MDS_LLOG_CREATE_FAILED			0x137
+#define OBD_FAIL_MDS_LOV_SYNC_RACE			0x138
+#define OBD_FAIL_MDS_OSC_PRECREATE			0x139
+#define OBD_FAIL_MDS_LLOG_SYNC_TIMEOUT			0x13a
+#define OBD_FAIL_MDS_CLOSE_NET_REP			0x13b
+#define OBD_FAIL_MDS_BLOCK_QUOTA_REQ			0x13c
+#define OBD_FAIL_MDS_DROP_QUOTA_REQ			0x13d
+#define OBD_FAIL_MDS_REMOVE_COMMON_EA			0x13e
+#define OBD_FAIL_MDS_ALLOW_COMMON_EA_SETTING		0x13f
+#define OBD_FAIL_MDS_FAIL_LOV_LOG_ADD			0x140
+#define OBD_FAIL_MDS_LOV_PREP_CREATE			0x141
+#define OBD_FAIL_MDS_REINT_DELAY			0x142
+#define OBD_FAIL_MDS_READLINK_EPROTO			0x143
+#define OBD_FAIL_MDS_OPEN_WAIT_CREATE			0x144
+#define OBD_FAIL_MDS_PDO_LOCK				0x145
+#define OBD_FAIL_MDS_PDO_LOCK2				0x146
+#define OBD_FAIL_MDS_OSC_CREATE_FAIL			0x147
+#define OBD_FAIL_MDS_NEGATIVE_POSITIVE			0x148
+#define OBD_FAIL_MDS_HSM_STATE_GET_NET			0x149
+#define OBD_FAIL_MDS_HSM_STATE_SET_NET			0x14a
+#define OBD_FAIL_MDS_HSM_PROGRESS_NET			0x14b
+#define OBD_FAIL_MDS_HSM_REQUEST_NET			0x14c
+#define OBD_FAIL_MDS_HSM_CT_REGISTER_NET		0x14d
+#define OBD_FAIL_MDS_HSM_CT_UNREGISTER_NET		0x14e
+#define OBD_FAIL_MDS_SWAP_LAYOUTS_NET			0x14f
+#define OBD_FAIL_MDS_HSM_ACTION_NET			0x150
+#define OBD_FAIL_MDS_CHANGELOG_INIT			0x151
 
 /* layout lock */
-#define OBD_FAIL_MDS_NO_LL_GETATTR	 0x170
-#define OBD_FAIL_MDS_NO_LL_OPEN		 0x171
-#define OBD_FAIL_MDS_LL_BLOCK		 0x172
+#define OBD_FAIL_MDS_NO_LL_GETATTR			0x170
+#define OBD_FAIL_MDS_NO_LL_OPEN				0x171
+#define OBD_FAIL_MDS_LL_BLOCK				0x172
 
 /* CMD */
-#define OBD_FAIL_MDS_IS_SUBDIR_NET       0x180
-#define OBD_FAIL_MDS_IS_SUBDIR_PACK      0x181
-#define OBD_FAIL_MDS_SET_INFO_NET	0x182
-#define OBD_FAIL_MDS_WRITEPAGE_NET       0x183
-#define OBD_FAIL_MDS_WRITEPAGE_PACK      0x184
-#define OBD_FAIL_MDS_RECOVERY_ACCEPTS_GAPS 0x185
-#define OBD_FAIL_MDS_GET_INFO_NET	0x186
-#define OBD_FAIL_MDS_DQACQ_NET	   0x187
+#define OBD_FAIL_MDS_IS_SUBDIR_NET			0x180
+#define OBD_FAIL_MDS_IS_SUBDIR_PACK			0x181
+#define OBD_FAIL_MDS_SET_INFO_NET			0x182
+#define OBD_FAIL_MDS_WRITEPAGE_NET			0x183
+#define OBD_FAIL_MDS_WRITEPAGE_PACK			0x184
+#define OBD_FAIL_MDS_RECOVERY_ACCEPTS_GAPS		0x185
+#define OBD_FAIL_MDS_GET_INFO_NET			0x186
+#define OBD_FAIL_MDS_DQACQ_NET				0x187
 
 /* OI scrub */
 #define OBD_FAIL_OSD_SCRUB_DELAY			0x190
@@ -213,278 +213,278 @@
 #define OBD_FAIL_OSD_LMA_INCOMPAT			0x194
 #define OBD_FAIL_OSD_COMPAT_INVALID_ENTRY		0x195
 
-#define OBD_FAIL_OST		     0x200
-#define OBD_FAIL_OST_CONNECT_NET	 0x201
-#define OBD_FAIL_OST_DISCONNECT_NET      0x202
-#define OBD_FAIL_OST_GET_INFO_NET	0x203
-#define OBD_FAIL_OST_CREATE_NET	  0x204
-#define OBD_FAIL_OST_DESTROY_NET	 0x205
-#define OBD_FAIL_OST_GETATTR_NET	 0x206
-#define OBD_FAIL_OST_SETATTR_NET	 0x207
-#define OBD_FAIL_OST_OPEN_NET	    0x208
-#define OBD_FAIL_OST_CLOSE_NET	   0x209
-#define OBD_FAIL_OST_BRW_NET	     0x20a
-#define OBD_FAIL_OST_PUNCH_NET	   0x20b
-#define OBD_FAIL_OST_STATFS_NET	  0x20c
-#define OBD_FAIL_OST_HANDLE_UNPACK       0x20d
-#define OBD_FAIL_OST_BRW_WRITE_BULK      0x20e
-#define OBD_FAIL_OST_BRW_READ_BULK       0x20f
-#define OBD_FAIL_OST_SYNC_NET	    0x210
-#define OBD_FAIL_OST_ALL_REPLY_NET       0x211
-#define OBD_FAIL_OST_ALL_REQUEST_NET     0x212
-#define OBD_FAIL_OST_LDLM_REPLY_NET      0x213
-#define OBD_FAIL_OST_BRW_PAUSE_BULK      0x214
-#define OBD_FAIL_OST_ENOSPC	      0x215
-#define OBD_FAIL_OST_EROFS	       0x216
-#define OBD_FAIL_OST_ENOENT	      0x217
+#define OBD_FAIL_OST					0x200
+#define OBD_FAIL_OST_CONNECT_NET			0x201
+#define OBD_FAIL_OST_DISCONNECT_NET			0x202
+#define OBD_FAIL_OST_GET_INFO_NET			0x203
+#define OBD_FAIL_OST_CREATE_NET				0x204
+#define OBD_FAIL_OST_DESTROY_NET			0x205
+#define OBD_FAIL_OST_GETATTR_NET			0x206
+#define OBD_FAIL_OST_SETATTR_NET			0x207
+#define OBD_FAIL_OST_OPEN_NET				0x208
+#define OBD_FAIL_OST_CLOSE_NET				0x209
+#define OBD_FAIL_OST_BRW_NET				0x20a
+#define OBD_FAIL_OST_PUNCH_NET				0x20b
+#define OBD_FAIL_OST_STATFS_NET				0x20c
+#define OBD_FAIL_OST_HANDLE_UNPACK			0x20d
+#define OBD_FAIL_OST_BRW_WRITE_BULK			0x20e
+#define OBD_FAIL_OST_BRW_READ_BULK			0x20f
+#define OBD_FAIL_OST_SYNC_NET				0x210
+#define OBD_FAIL_OST_ALL_REPLY_NET			0x211
+#define OBD_FAIL_OST_ALL_REQUEST_NET			0x212
+#define OBD_FAIL_OST_LDLM_REPLY_NET			0x213
+#define OBD_FAIL_OST_BRW_PAUSE_BULK			0x214
+#define OBD_FAIL_OST_ENOSPC				0x215
+#define OBD_FAIL_OST_EROFS				0x216
+#define OBD_FAIL_OST_ENOENT				0x217
 /*	OBD_FAIL_OST_QUOTACHECK_NET      0x218 obsolete since 2.4 */
-#define OBD_FAIL_OST_QUOTACTL_NET	0x219
-#define OBD_FAIL_OST_CHECKSUM_RECEIVE    0x21a
-#define OBD_FAIL_OST_CHECKSUM_SEND       0x21b
-#define OBD_FAIL_OST_BRW_SIZE	    0x21c
-#define OBD_FAIL_OST_DROP_REQ	    0x21d
-#define OBD_FAIL_OST_SETATTR_CREDITS     0x21e
-#define OBD_FAIL_OST_HOLD_WRITE_RPC      0x21f
-#define OBD_FAIL_OST_BRW_WRITE_BULK2     0x220
-#define OBD_FAIL_OST_LLOG_RECOVERY_TIMEOUT 0x221
-#define OBD_FAIL_OST_CANCEL_COOKIE_TIMEOUT 0x222
-#define OBD_FAIL_OST_PAUSE_CREATE	0x223
-#define OBD_FAIL_OST_BRW_PAUSE_PACK      0x224
-#define OBD_FAIL_OST_CONNECT_NET2	0x225
-#define OBD_FAIL_OST_NOMEM	       0x226
-#define OBD_FAIL_OST_BRW_PAUSE_BULK2     0x227
-#define OBD_FAIL_OST_MAPBLK_ENOSPC       0x228
-#define OBD_FAIL_OST_ENOINO	      0x229
-#define OBD_FAIL_OST_DQACQ_NET	   0x230
-#define OBD_FAIL_OST_STATFS_EINPROGRESS  0x231
-#define OBD_FAIL_OST_SET_INFO_NET		0x232
-
-#define OBD_FAIL_LDLM		    0x300
-#define OBD_FAIL_LDLM_NAMESPACE_NEW      0x301
+#define OBD_FAIL_OST_QUOTACTL_NET			0x219
+#define OBD_FAIL_OST_CHECKSUM_RECEIVE			0x21a
+#define OBD_FAIL_OST_CHECKSUM_SEND			0x21b
+#define OBD_FAIL_OST_BRW_SIZE				0x21c
+#define OBD_FAIL_OST_DROP_REQ				0x21d
+#define OBD_FAIL_OST_SETATTR_CREDITS			0x21e
+#define OBD_FAIL_OST_HOLD_WRITE_RPC			0x21f
+#define OBD_FAIL_OST_BRW_WRITE_BULK2			0x220
+#define OBD_FAIL_OST_LLOG_RECOVERY_TIMEOUT		0x221
+#define OBD_FAIL_OST_CANCEL_COOKIE_TIMEOUT		0x222
+#define OBD_FAIL_OST_PAUSE_CREATE			0x223
+#define OBD_FAIL_OST_BRW_PAUSE_PACK			0x224
+#define OBD_FAIL_OST_CONNECT_NET2			0x225
+#define OBD_FAIL_OST_NOMEM				0x226
+#define OBD_FAIL_OST_BRW_PAUSE_BULK2			0x227
+#define OBD_FAIL_OST_MAPBLK_ENOSPC			0x228
+#define OBD_FAIL_OST_ENOINO				0x229
+#define OBD_FAIL_OST_DQACQ_NET				0x230
+#define OBD_FAIL_OST_STATFS_EINPROGRESS			0x231
+#define OBD_FAIL_OST_SET_INFO_NET			0x232
+
+#define OBD_FAIL_LDLM					0x300
+#define OBD_FAIL_LDLM_NAMESPACE_NEW			0x301
 #define OBD_FAIL_LDLM_ENQUEUE_NET			0x302
 #define OBD_FAIL_LDLM_CONVERT_NET			0x303
 #define OBD_FAIL_LDLM_CANCEL_NET			0x304
 #define OBD_FAIL_LDLM_BL_CALLBACK_NET			0x305
 #define OBD_FAIL_LDLM_CP_CALLBACK_NET			0x306
 #define OBD_FAIL_LDLM_GL_CALLBACK_NET			0x307
-#define OBD_FAIL_LDLM_ENQUEUE_EXTENT_ERR 0x308
-#define OBD_FAIL_LDLM_ENQUEUE_INTENT_ERR 0x309
-#define OBD_FAIL_LDLM_CREATE_RESOURCE    0x30a
-#define OBD_FAIL_LDLM_ENQUEUE_BLOCKED    0x30b
-#define OBD_FAIL_LDLM_REPLY	      0x30c
-#define OBD_FAIL_LDLM_RECOV_CLIENTS      0x30d
-#define OBD_FAIL_LDLM_ENQUEUE_OLD_EXPORT 0x30e
-#define OBD_FAIL_LDLM_GLIMPSE	    0x30f
-#define OBD_FAIL_LDLM_CANCEL_RACE	0x310
-#define OBD_FAIL_LDLM_CANCEL_EVICT_RACE  0x311
-#define OBD_FAIL_LDLM_PAUSE_CANCEL       0x312
-#define OBD_FAIL_LDLM_CLOSE_THREAD       0x313
-#define OBD_FAIL_LDLM_CANCEL_BL_CB_RACE  0x314
-#define OBD_FAIL_LDLM_CP_CB_WAIT	 0x315
-#define OBD_FAIL_LDLM_OST_FAIL_RACE      0x316
-#define OBD_FAIL_LDLM_INTR_CP_AST	0x317
-#define OBD_FAIL_LDLM_CP_BL_RACE	 0x318
-#define OBD_FAIL_LDLM_NEW_LOCK	   0x319
-#define OBD_FAIL_LDLM_AGL_DELAY	  0x31a
-#define OBD_FAIL_LDLM_AGL_NOLOCK	 0x31b
-#define OBD_FAIL_LDLM_OST_LVB		 0x31c
-#define OBD_FAIL_LDLM_ENQUEUE_HANG	 0x31d
-#define OBD_FAIL_LDLM_PAUSE_CANCEL2	 0x31f
-#define OBD_FAIL_LDLM_CP_CB_WAIT2	 0x320
-#define OBD_FAIL_LDLM_CP_CB_WAIT3	 0x321
-#define OBD_FAIL_LDLM_CP_CB_WAIT4	 0x322
-#define OBD_FAIL_LDLM_CP_CB_WAIT5	 0x323
-
-#define OBD_FAIL_LDLM_GRANT_CHECK        0x32a
+#define OBD_FAIL_LDLM_ENQUEUE_EXTENT_ERR		0x308
+#define OBD_FAIL_LDLM_ENQUEUE_INTENT_ERR		0x309
+#define OBD_FAIL_LDLM_CREATE_RESOURCE			0x30a
+#define OBD_FAIL_LDLM_ENQUEUE_BLOCKED			0x30b
+#define OBD_FAIL_LDLM_REPLY				0x30c
+#define OBD_FAIL_LDLM_RECOV_CLIENTS			0x30d
+#define OBD_FAIL_LDLM_ENQUEUE_OLD_EXPORT		0x30e
+#define OBD_FAIL_LDLM_GLIMPSE				0x30f
+#define OBD_FAIL_LDLM_CANCEL_RACE			0x310
+#define OBD_FAIL_LDLM_CANCEL_EVICT_RACE			0x311
+#define OBD_FAIL_LDLM_PAUSE_CANCEL			0x312
+#define OBD_FAIL_LDLM_CLOSE_THREAD			0x313
+#define OBD_FAIL_LDLM_CANCEL_BL_CB_RACE			0x314
+#define OBD_FAIL_LDLM_CP_CB_WAIT			0x315
+#define OBD_FAIL_LDLM_OST_FAIL_RACE			0x316
+#define OBD_FAIL_LDLM_INTR_CP_AST			0x317
+#define OBD_FAIL_LDLM_CP_BL_RACE			0x318
+#define OBD_FAIL_LDLM_NEW_LOCK				0x319
+#define OBD_FAIL_LDLM_AGL_DELAY				0x31a
+#define OBD_FAIL_LDLM_AGL_NOLOCK			0x31b
+#define OBD_FAIL_LDLM_OST_LVB				0x31c
+#define OBD_FAIL_LDLM_ENQUEUE_HANG			0x31d
+#define OBD_FAIL_LDLM_PAUSE_CANCEL2			0x31f
+#define OBD_FAIL_LDLM_CP_CB_WAIT2			0x320
+#define OBD_FAIL_LDLM_CP_CB_WAIT3			0x321
+#define OBD_FAIL_LDLM_CP_CB_WAIT4			0x322
+#define OBD_FAIL_LDLM_CP_CB_WAIT5			0x323
+
+#define OBD_FAIL_LDLM_GRANT_CHECK			0x32a
 
 /* LOCKLESS IO */
-#define OBD_FAIL_LDLM_SET_CONTENTION     0x385
-
-#define OBD_FAIL_OSC		     0x400
-#define OBD_FAIL_OSC_BRW_READ_BULK       0x401
-#define OBD_FAIL_OSC_BRW_WRITE_BULK      0x402
-#define OBD_FAIL_OSC_LOCK_BL_AST	 0x403
-#define OBD_FAIL_OSC_LOCK_CP_AST	 0x404
-#define OBD_FAIL_OSC_MATCH	       0x405
-#define OBD_FAIL_OSC_BRW_PREP_REQ	0x406
-#define OBD_FAIL_OSC_SHUTDOWN	    0x407
-#define OBD_FAIL_OSC_CHECKSUM_RECEIVE    0x408
-#define OBD_FAIL_OSC_CHECKSUM_SEND       0x409
-#define OBD_FAIL_OSC_BRW_PREP_REQ2       0x40a
+#define OBD_FAIL_LDLM_SET_CONTENTION			0x385
+
+#define OBD_FAIL_OSC					0x400
+#define OBD_FAIL_OSC_BRW_READ_BULK			0x401
+#define OBD_FAIL_OSC_BRW_WRITE_BULK			0x402
+#define OBD_FAIL_OSC_LOCK_BL_AST			0x403
+#define OBD_FAIL_OSC_LOCK_CP_AST			0x404
+#define OBD_FAIL_OSC_MATCH				0x405
+#define OBD_FAIL_OSC_BRW_PREP_REQ			0x406
+#define OBD_FAIL_OSC_SHUTDOWN				0x407
+#define OBD_FAIL_OSC_CHECKSUM_RECEIVE			0x408
+#define OBD_FAIL_OSC_CHECKSUM_SEND			0x409
+#define OBD_FAIL_OSC_BRW_PREP_REQ2			0x40a
 /* #define OBD_FAIL_OSC_CONNECT_CKSUM	 0x40b Obsolete since 2.9 */
-#define OBD_FAIL_OSC_CKSUM_ADLER_ONLY    0x40c
-#define OBD_FAIL_OSC_DIO_PAUSE	   0x40d
-#define OBD_FAIL_OSC_OBJECT_CONTENTION   0x40e
-#define OBD_FAIL_OSC_CP_CANCEL_RACE      0x40f
-#define OBD_FAIL_OSC_CP_ENQ_RACE	 0x410
-#define OBD_FAIL_OSC_NO_GRANT	    0x411
-#define OBD_FAIL_OSC_DELAY_SETTIME	 0x412
-#define OBD_FAIL_OSC_CONNECT_GRANT_PARAM 0x413
-#define OBD_FAIL_OSC_DELAY_IO		 0x414
-
-#define OBD_FAIL_PTLRPC		  0x500
-#define OBD_FAIL_PTLRPC_ACK	      0x501
-#define OBD_FAIL_PTLRPC_RQBD	     0x502
-#define OBD_FAIL_PTLRPC_BULK_GET_NET     0x503
-#define OBD_FAIL_PTLRPC_BULK_PUT_NET     0x504
-#define OBD_FAIL_PTLRPC_DROP_RPC	 0x505
-#define OBD_FAIL_PTLRPC_DELAY_SEND       0x506
-#define OBD_FAIL_PTLRPC_DELAY_RECOV      0x507
-#define OBD_FAIL_PTLRPC_CLIENT_BULK_CB   0x508
-#define OBD_FAIL_PTLRPC_PAUSE_REQ	0x50a
-#define OBD_FAIL_PTLRPC_PAUSE_REP	0x50c
-#define OBD_FAIL_PTLRPC_IMP_DEACTIVE     0x50d
-#define OBD_FAIL_PTLRPC_DUMP_LOG	 0x50e
-#define OBD_FAIL_PTLRPC_LONG_REPL_UNLINK 0x50f
-#define OBD_FAIL_PTLRPC_LONG_BULK_UNLINK 0x510
-#define OBD_FAIL_PTLRPC_HPREQ_TIMEOUT    0x511
-#define OBD_FAIL_PTLRPC_HPREQ_NOTIMEOUT  0x512
-#define OBD_FAIL_PTLRPC_DROP_REQ_OPC     0x513
-#define OBD_FAIL_PTLRPC_FINISH_REPLAY    0x514
-#define OBD_FAIL_PTLRPC_CLIENT_BULK_CB2  0x515
-#define OBD_FAIL_PTLRPC_DELAY_IMP_FULL   0x516
-#define OBD_FAIL_PTLRPC_CANCEL_RESEND    0x517
-#define OBD_FAIL_PTLRPC_DROP_BULK	 0x51a
-#define OBD_FAIL_PTLRPC_LONG_REQ_UNLINK	 0x51b
-#define OBD_FAIL_PTLRPC_LONG_BOTH_UNLINK 0x51c
-
-#define OBD_FAIL_OBD_PING_NET	    0x600
-#define OBD_FAIL_OBD_LOG_CANCEL_NET      0x601
-#define OBD_FAIL_OBD_LOGD_NET	    0x602
+#define OBD_FAIL_OSC_CKSUM_ADLER_ONLY			0x40c
+#define OBD_FAIL_OSC_DIO_PAUSE				0x40d
+#define OBD_FAIL_OSC_OBJECT_CONTENTION			0x40e
+#define OBD_FAIL_OSC_CP_CANCEL_RACE			0x40f
+#define OBD_FAIL_OSC_CP_ENQ_RACE			0x410
+#define OBD_FAIL_OSC_NO_GRANT				0x411
+#define OBD_FAIL_OSC_DELAY_SETTIME			0x412
+#define OBD_FAIL_OSC_CONNECT_GRANT_PARAM		0x413
+#define OBD_FAIL_OSC_DELAY_IO				0x414
+
+#define OBD_FAIL_PTLRPC					0x500
+#define OBD_FAIL_PTLRPC_ACK				0x501
+#define OBD_FAIL_PTLRPC_RQBD				0x502
+#define OBD_FAIL_PTLRPC_BULK_GET_NET			0x503
+#define OBD_FAIL_PTLRPC_BULK_PUT_NET			0x504
+#define OBD_FAIL_PTLRPC_DROP_RPC			0x505
+#define OBD_FAIL_PTLRPC_DELAY_SEND			0x506
+#define OBD_FAIL_PTLRPC_DELAY_RECOV			0x507
+#define OBD_FAIL_PTLRPC_CLIENT_BULK_CB			0x508
+#define OBD_FAIL_PTLRPC_PAUSE_REQ			0x50a
+#define OBD_FAIL_PTLRPC_PAUSE_REP			0x50c
+#define OBD_FAIL_PTLRPC_IMP_DEACTIVE			0x50d
+#define OBD_FAIL_PTLRPC_DUMP_LOG			0x50e
+#define OBD_FAIL_PTLRPC_LONG_REPL_UNLINK		0x50f
+#define OBD_FAIL_PTLRPC_LONG_BULK_UNLINK		0x510
+#define OBD_FAIL_PTLRPC_HPREQ_TIMEOUT			0x511
+#define OBD_FAIL_PTLRPC_HPREQ_NOTIMEOUT			0x512
+#define OBD_FAIL_PTLRPC_DROP_REQ_OPC			0x513
+#define OBD_FAIL_PTLRPC_FINISH_REPLAY			0x514
+#define OBD_FAIL_PTLRPC_CLIENT_BULK_CB2			0x515
+#define OBD_FAIL_PTLRPC_DELAY_IMP_FULL			0x516
+#define OBD_FAIL_PTLRPC_CANCEL_RESEND			0x517
+#define OBD_FAIL_PTLRPC_DROP_BULK			0x51a
+#define OBD_FAIL_PTLRPC_LONG_REQ_UNLINK			0x51b
+#define OBD_FAIL_PTLRPC_LONG_BOTH_UNLINK		0x51c
+
+#define OBD_FAIL_OBD_PING_NET				0x600
+#define OBD_FAIL_OBD_LOG_CANCEL_NET			0x601
+#define OBD_FAIL_OBD_LOGD_NET				0x602
 /*	OBD_FAIL_OBD_QC_CALLBACK_NET     0x603 obsolete since 2.4 */
-#define OBD_FAIL_OBD_DQACQ	       0x604
-#define OBD_FAIL_OBD_LLOG_SETUP	  0x605
-#define OBD_FAIL_OBD_LOG_CANCEL_REP      0x606
-#define OBD_FAIL_OBD_IDX_READ_NET	0x607
-#define OBD_FAIL_OBD_IDX_READ_BREAK	 0x608
-#define OBD_FAIL_OBD_NO_LRU		 0x609
-#define OBD_FAIL_OBDCLASS_MODULE_LOAD	 0x60a
-
-#define OBD_FAIL_TGT_REPLY_NET	   0x700
-#define OBD_FAIL_TGT_CONN_RACE	   0x701
-#define OBD_FAIL_TGT_FORCE_RECONNECT     0x702
-#define OBD_FAIL_TGT_DELAY_CONNECT       0x703
-#define OBD_FAIL_TGT_DELAY_RECONNECT     0x704
-#define OBD_FAIL_TGT_DELAY_PRECREATE     0x705
-#define OBD_FAIL_TGT_TOOMANY_THREADS     0x706
-#define OBD_FAIL_TGT_REPLAY_DROP	 0x707
-#define OBD_FAIL_TGT_FAKE_EXP	    0x708
-#define OBD_FAIL_TGT_REPLAY_DELAY	0x709
-#define OBD_FAIL_TGT_LAST_REPLAY	 0x710
-#define OBD_FAIL_TGT_CLIENT_ADD	  0x711
-#define OBD_FAIL_TGT_RCVG_FLAG	   0x712
-#define OBD_FAIL_TGT_DELAY_CONDITIONAL	 0x713
-
-#define OBD_FAIL_MDC_REVALIDATE_PAUSE    0x800
-#define OBD_FAIL_MDC_ENQUEUE_PAUSE       0x801
-#define OBD_FAIL_MDC_OLD_EXT_FLAGS       0x802
-#define OBD_FAIL_MDC_GETATTR_ENQUEUE     0x803
-#define OBD_FAIL_MDC_RPCS_SEM		 0x804
-#define OBD_FAIL_MDC_LIGHTWEIGHT	 0x805
-#define OBD_FAIL_MDC_CLOSE		 0x806
-
-#define OBD_FAIL_MGS		     0x900
-#define OBD_FAIL_MGS_ALL_REQUEST_NET     0x901
-#define OBD_FAIL_MGS_ALL_REPLY_NET       0x902
-#define OBD_FAIL_MGC_PAUSE_PROCESS_LOG   0x903
-#define OBD_FAIL_MGS_PAUSE_REQ	   0x904
-#define OBD_FAIL_MGS_PAUSE_TARGET_REG    0x905
-#define OBD_FAIL_MGS_CONNECT_NET	 0x906
-#define OBD_FAIL_MGS_DISCONNECT_NET	 0x907
-#define OBD_FAIL_MGS_SET_INFO_NET	 0x908
-#define OBD_FAIL_MGS_EXCEPTION_NET	 0x909
-#define OBD_FAIL_MGS_TARGET_REG_NET	 0x90a
-#define OBD_FAIL_MGS_TARGET_DEL_NET	 0x90b
-#define OBD_FAIL_MGS_CONFIG_READ_NET	 0x90c
+#define OBD_FAIL_OBD_DQACQ				0x604
+#define OBD_FAIL_OBD_LLOG_SETUP				0x605
+#define OBD_FAIL_OBD_LOG_CANCEL_REP			0x606
+#define OBD_FAIL_OBD_IDX_READ_NET			0x607
+#define OBD_FAIL_OBD_IDX_READ_BREAK			0x608
+#define OBD_FAIL_OBD_NO_LRU				0x609
+#define OBD_FAIL_OBDCLASS_MODULE_LOAD			0x60a
+
+#define OBD_FAIL_TGT_REPLY_NET				0x700
+#define OBD_FAIL_TGT_CONN_RACE				0x701
+#define OBD_FAIL_TGT_FORCE_RECONNECT			0x702
+#define OBD_FAIL_TGT_DELAY_CONNECT			0x703
+#define OBD_FAIL_TGT_DELAY_RECONNECT			0x704
+#define OBD_FAIL_TGT_DELAY_PRECREATE			0x705
+#define OBD_FAIL_TGT_TOOMANY_THREADS			0x706
+#define OBD_FAIL_TGT_REPLAY_DROP			0x707
+#define OBD_FAIL_TGT_FAKE_EXP				0x708
+#define OBD_FAIL_TGT_REPLAY_DELAY			0x709
+#define OBD_FAIL_TGT_LAST_REPLAY			0x710
+#define OBD_FAIL_TGT_CLIENT_ADD				0x711
+#define OBD_FAIL_TGT_RCVG_FLAG				0x712
+#define OBD_FAIL_TGT_DELAY_CONDITIONAL			0x713
+
+#define OBD_FAIL_MDC_REVALIDATE_PAUSE			0x800
+#define OBD_FAIL_MDC_ENQUEUE_PAUSE			0x801
+#define OBD_FAIL_MDC_OLD_EXT_FLAGS			0x802
+#define OBD_FAIL_MDC_GETATTR_ENQUEUE			0x803
+#define OBD_FAIL_MDC_RPCS_SEM				0x804
+#define OBD_FAIL_MDC_LIGHTWEIGHT			0x805
+#define OBD_FAIL_MDC_CLOSE				0x806
+
+#define OBD_FAIL_MGS					0x900
+#define OBD_FAIL_MGS_ALL_REQUEST_NET			0x901
+#define OBD_FAIL_MGS_ALL_REPLY_NET			0x902
+#define OBD_FAIL_MGC_PAUSE_PROCESS_LOG			0x903
+#define OBD_FAIL_MGS_PAUSE_REQ				0x904
+#define OBD_FAIL_MGS_PAUSE_TARGET_REG			0x905
+#define OBD_FAIL_MGS_CONNECT_NET			0x906
+#define OBD_FAIL_MGS_DISCONNECT_NET			0x907
+#define OBD_FAIL_MGS_SET_INFO_NET			0x908
+#define OBD_FAIL_MGS_EXCEPTION_NET			0x909
+#define OBD_FAIL_MGS_TARGET_REG_NET			0x90a
+#define OBD_FAIL_MGS_TARGET_DEL_NET			0x90b
+#define OBD_FAIL_MGS_CONFIG_READ_NET			0x90c
 
 #define OBD_FAIL_QUOTA_DQACQ_NET			0xA01
-#define OBD_FAIL_QUOTA_EDQUOT	    0xA02
-#define OBD_FAIL_QUOTA_DELAY_REINT       0xA03
-#define OBD_FAIL_QUOTA_RECOVERABLE_ERR   0xA04
-
-#define OBD_FAIL_LPROC_REMOVE	    0xB00
-
-#define OBD_FAIL_SEQ		     0x1000
-#define OBD_FAIL_SEQ_QUERY_NET	   0x1001
-#define OBD_FAIL_SEQ_EXHAUST		 0x1002
-
-#define OBD_FAIL_FLD		     0x1100
-#define OBD_FAIL_FLD_QUERY_NET	   0x1101
-#define OBD_FAIL_FLD_READ_NET		0x1102
-
-#define OBD_FAIL_SEC_CTX		 0x1200
-#define OBD_FAIL_SEC_CTX_INIT_NET	0x1201
-#define OBD_FAIL_SEC_CTX_INIT_CONT_NET   0x1202
-#define OBD_FAIL_SEC_CTX_FINI_NET	0x1203
-#define OBD_FAIL_SEC_CTX_HDL_PAUSE       0x1204
-
-#define OBD_FAIL_LLOG			       0x1300
-#define OBD_FAIL_LLOG_ORIGIN_CONNECT_NET	    0x1301
-#define OBD_FAIL_LLOG_ORIGIN_HANDLE_CREATE_NET      0x1302
-#define OBD_FAIL_LLOG_ORIGIN_HANDLE_DESTROY_NET     0x1303
-#define OBD_FAIL_LLOG_ORIGIN_HANDLE_READ_HEADER_NET 0x1304
-#define OBD_FAIL_LLOG_ORIGIN_HANDLE_NEXT_BLOCK_NET  0x1305
-#define OBD_FAIL_LLOG_ORIGIN_HANDLE_PREV_BLOCK_NET  0x1306
-#define OBD_FAIL_LLOG_ORIGIN_HANDLE_WRITE_REC_NET   0x1307
-#define OBD_FAIL_LLOG_ORIGIN_HANDLE_CLOSE_NET       0x1308
-#define OBD_FAIL_LLOG_CATINFO_NET		   0x1309
-#define OBD_FAIL_MDS_SYNC_CAPA_SL		   0x1310
-#define OBD_FAIL_SEQ_ALLOC			  0x1311
-
-#define OBD_FAIL_LLITE			      0x1400
-#define OBD_FAIL_LLITE_FAULT_TRUNC_RACE	     0x1401
-#define OBD_FAIL_LOCK_STATE_WAIT_INTR	       0x1402
-#define OBD_FAIL_LOV_INIT			    0x1403
-#define OBD_FAIL_GLIMPSE_DELAY			    0x1404
-#define OBD_FAIL_LLITE_XATTR_ENOMEM		    0x1405
-#define OBD_FAIL_MAKE_LOVEA_HOLE		    0x1406
-#define OBD_FAIL_LLITE_LOST_LAYOUT		    0x1407
-#define OBD_FAIL_GETATTR_DELAY			    0x1409
-#define OBD_FAIL_LLITE_CREATE_NODE_PAUSE	    0x140c
-#define OBD_FAIL_LLITE_IMUTEX_SEC		    0x140e
-#define OBD_FAIL_LLITE_IMUTEX_NOSEC		    0x140f
-
-#define OBD_FAIL_FID_INDIR	0x1501
-#define OBD_FAIL_FID_INLMA	0x1502
-#define OBD_FAIL_FID_IGIF	0x1504
-#define OBD_FAIL_FID_LOOKUP	0x1505
-#define OBD_FAIL_FID_NOLMA	0x1506
+#define OBD_FAIL_QUOTA_EDQUOT				0xA02
+#define OBD_FAIL_QUOTA_DELAY_REINT			0xA03
+#define OBD_FAIL_QUOTA_RECOVERABLE_ERR			0xA04
+
+#define OBD_FAIL_LPROC_REMOVE				0xB00
+
+#define OBD_FAIL_SEQ					0x1000
+#define OBD_FAIL_SEQ_QUERY_NET				0x1001
+#define OBD_FAIL_SEQ_EXHAUST				0x1002
+
+#define OBD_FAIL_FLD					0x1100
+#define OBD_FAIL_FLD_QUERY_NET				0x1101
+#define OBD_FAIL_FLD_READ_NET				0x1102
+
+#define OBD_FAIL_SEC_CTX				0x1200
+#define OBD_FAIL_SEC_CTX_INIT_NET			0x1201
+#define OBD_FAIL_SEC_CTX_INIT_CONT_NET			0x1202
+#define OBD_FAIL_SEC_CTX_FINI_NET			0x1203
+#define OBD_FAIL_SEC_CTX_HDL_PAUSE			0x1204
+
+#define OBD_FAIL_LLOG					0x1300
+#define OBD_FAIL_LLOG_ORIGIN_CONNECT_NET		0x1301
+#define OBD_FAIL_LLOG_ORIGIN_HANDLE_CREATE_NET		0x1302
+#define OBD_FAIL_LLOG_ORIGIN_HANDLE_DESTROY_NET		0x1303
+#define OBD_FAIL_LLOG_ORIGIN_HANDLE_READ_HEADER_NET	0x1304
+#define OBD_FAIL_LLOG_ORIGIN_HANDLE_NEXT_BLOCK_NET	0x1305
+#define OBD_FAIL_LLOG_ORIGIN_HANDLE_PREV_BLOCK_NET	0x1306
+#define OBD_FAIL_LLOG_ORIGIN_HANDLE_WRITE_REC_NET	0x1307
+#define OBD_FAIL_LLOG_ORIGIN_HANDLE_CLOSE_NET		0x1308
+#define OBD_FAIL_LLOG_CATINFO_NET			0x1309
+#define OBD_FAIL_MDS_SYNC_CAPA_SL			0x1310
+#define OBD_FAIL_SEQ_ALLOC				0x1311
+
+#define OBD_FAIL_LLITE					0x1400
+#define OBD_FAIL_LLITE_FAULT_TRUNC_RACE			0x1401
+#define OBD_FAIL_LOCK_STATE_WAIT_INTR			0x1402
+#define OBD_FAIL_LOV_INIT				0x1403
+#define OBD_FAIL_GLIMPSE_DELAY				0x1404
+#define OBD_FAIL_LLITE_XATTR_ENOMEM			0x1405
+#define OBD_FAIL_MAKE_LOVEA_HOLE			0x1406
+#define OBD_FAIL_LLITE_LOST_LAYOUT			0x1407
+#define OBD_FAIL_GETATTR_DELAY				0x1409
+#define OBD_FAIL_LLITE_CREATE_NODE_PAUSE		0x140c
+#define OBD_FAIL_LLITE_IMUTEX_SEC			0x140e
+#define OBD_FAIL_LLITE_IMUTEX_NOSEC			0x140f
+
+#define OBD_FAIL_FID_INDIR				0x1501
+#define OBD_FAIL_FID_INLMA				0x1502
+#define OBD_FAIL_FID_IGIF				0x1504
+#define OBD_FAIL_FID_LOOKUP				0x1505
+#define OBD_FAIL_FID_NOLMA				0x1506
 
 /* LFSCK */
-#define OBD_FAIL_LFSCK_DELAY1		0x1600
-#define OBD_FAIL_LFSCK_DELAY2		0x1601
-#define OBD_FAIL_LFSCK_DELAY3		0x1602
-#define OBD_FAIL_LFSCK_LINKEA_CRASH	0x1603
-#define OBD_FAIL_LFSCK_LINKEA_MORE	0x1604
-#define OBD_FAIL_LFSCK_LINKEA_MORE2	0x1605
-#define OBD_FAIL_LFSCK_FATAL1		0x1608
-#define OBD_FAIL_LFSCK_FATAL2		0x1609
-#define OBD_FAIL_LFSCK_CRASH		0x160a
-#define OBD_FAIL_LFSCK_NO_AUTO		0x160b
-#define OBD_FAIL_LFSCK_NO_DOUBLESCAN	0x160c
-#define OBD_FAIL_LFSCK_INVALID_PFID	0x1619
-#define OBD_FAIL_LFSCK_BAD_NAME_HASH	0x1628
+#define OBD_FAIL_LFSCK_DELAY1				0x1600
+#define OBD_FAIL_LFSCK_DELAY2				0x1601
+#define OBD_FAIL_LFSCK_DELAY3				0x1602
+#define OBD_FAIL_LFSCK_LINKEA_CRASH			0x1603
+#define OBD_FAIL_LFSCK_LINKEA_MORE			0x1604
+#define OBD_FAIL_LFSCK_LINKEA_MORE2			0x1605
+#define OBD_FAIL_LFSCK_FATAL1				0x1608
+#define OBD_FAIL_LFSCK_FATAL2				0x1609
+#define OBD_FAIL_LFSCK_CRASH				0x160a
+#define OBD_FAIL_LFSCK_NO_AUTO				0x160b
+#define OBD_FAIL_LFSCK_NO_DOUBLESCAN			0x160c
+#define OBD_FAIL_LFSCK_INVALID_PFID			0x1619
+#define OBD_FAIL_LFSCK_BAD_NAME_HASH			0x1628
 
 /* UPDATE */
-#define OBD_FAIL_UPDATE_OBJ_NET			0x1700
-#define OBD_FAIL_UPDATE_OBJ_NET_REP		0x1701
+#define OBD_FAIL_UPDATE_OBJ_NET				0x1700
+#define OBD_FAIL_UPDATE_OBJ_NET_REP			0x1701
 
 /* LMV */
-#define OBD_FAIL_UNKNOWN_LMV_STRIPE		0x1901
+#define OBD_FAIL_UNKNOWN_LMV_STRIPE			0x1901
 
 /* Assign references to moved code to reduce code changes */
-#define OBD_FAIL_PRECHECK(id)		   CFS_FAIL_PRECHECK(id)
-#define OBD_FAIL_CHECK(id)		      CFS_FAIL_CHECK(id)
-#define OBD_FAIL_CHECK_VALUE(id, value)	 CFS_FAIL_CHECK_VALUE(id, value)
-#define OBD_FAIL_CHECK_ORSET(id, value)	 CFS_FAIL_CHECK_ORSET(id, value)
-#define OBD_FAIL_CHECK_RESET(id, value)	 CFS_FAIL_CHECK_RESET(id, value)
+#define OBD_FAIL_PRECHECK(id)			CFS_FAIL_PRECHECK(id)
+#define OBD_FAIL_CHECK(id)			CFS_FAIL_CHECK(id)
+#define OBD_FAIL_CHECK_VALUE(id, value)		CFS_FAIL_CHECK_VALUE(id, value)
+#define OBD_FAIL_CHECK_ORSET(id, value)		CFS_FAIL_CHECK_ORSET(id, value)
+#define OBD_FAIL_CHECK_RESET(id, value)		CFS_FAIL_CHECK_RESET(id, value)
 #define OBD_FAIL_RETURN(id, ret)		CFS_FAIL_RETURN(id, ret)
-#define OBD_FAIL_TIMEOUT(id, secs)	      CFS_FAIL_TIMEOUT(id, secs)
-#define OBD_FAIL_TIMEOUT_MS(id, ms)	     CFS_FAIL_TIMEOUT_MS(id, ms)
-#define OBD_FAIL_TIMEOUT_ORSET(id, value, secs) CFS_FAIL_TIMEOUT_ORSET(id, value, secs)
-#define OBD_RACE(id)			    CFS_RACE(id)
-#define OBD_FAIL_ONCE			   CFS_FAIL_ONCE
-#define OBD_FAILED			      CFS_FAILED
+#define OBD_FAIL_TIMEOUT(id, secs)		CFS_FAIL_TIMEOUT(id, secs)
+#define OBD_FAIL_TIMEOUT_MS(id, ms)		CFS_FAIL_TIMEOUT_MS(id, ms)
+#define OBD_FAIL_TIMEOUT_ORSET(id, value, secs)	CFS_FAIL_TIMEOUT_ORSET(id, value, secs)
+#define OBD_RACE(id)				CFS_RACE(id)
+#define OBD_FAIL_ONCE				CFS_FAIL_ONCE
+#define OBD_FAILED				CFS_FAILED
 
 #ifdef CONFIG_DEBUG_SLAB
 #define POISON(ptr, c, s) do {} while (0)
@@ -495,22 +495,22 @@
 #endif
 
 #ifdef POISON_BULK
-#define POISON_PAGE(page, val) do {		  \
-	memset(kmap(page), val, PAGE_SIZE); \
-	kunmap(page);				  \
+#define POISON_PAGE(page, val) do {			\
+	memset(kmap(page), val, PAGE_SIZE);		\
+	kunmap(page);					\
 } while (0)
 #else
 #define POISON_PAGE(page, val) do { } while (0)
 #endif
 
-#define OBD_FREE_RCU(ptr, size, handle)					      \
-do {									      \
-	struct portals_handle *__h = (handle);				      \
-									      \
-	__h->h_cookie = (unsigned long)(ptr);				      \
-	__h->h_size = (size);						      \
-	call_rcu(&__h->h_rcu, class_handle_free_cb);			      \
-	POISON_PTR(ptr);						      \
+#define OBD_FREE_RCU(ptr, size, handle)			\
+do {							\
+	struct portals_handle *__h = (handle);		\
+							\
+	__h->h_cookie = (unsigned long)(ptr);		\
+	__h->h_size = (size);				\
+	call_rcu(&__h->h_rcu, class_handle_free_cb);	\
+	POISON_PTR(ptr);				\
 } while (0)
 
 #define KEY_IS(str)					\
diff --git a/drivers/staging/lustre/lustre/include/seq_range.h b/drivers/staging/lustre/lustre/include/seq_range.h
index 9450da72..884d4d4 100644
--- a/drivers/staging/lustre/lustre/include/seq_range.h
+++ b/drivers/staging/lustre/lustre/include/seq_range.h
@@ -176,7 +176,7 @@ static inline int lu_seq_range_compare_loc(const struct lu_seq_range *r1,
 					   const struct lu_seq_range *r2)
 {
 	return r1->lsr_index != r2->lsr_index ||
-		r1->lsr_flags != r2->lsr_flags;
+	       r1->lsr_flags != r2->lsr_flags;
 }
 
 #if !defined(__REQ_LAYOUT_USER__)
-- 
1.8.3.1
