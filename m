From: James Simmons <jsimmons@infradead.org>
Date: Thu, 31 Jan 2019 12:19:25 -0500
Subject: [lustre-devel] [PATCH 21/26] lustre: second batch to cleanup white
 spaces in internal headers
In-Reply-To: <1548955170-13456-1-git-send-email-jsimmons@infradead.org>
References: <1548955170-13456-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1548955170-13456-22-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

The internal headers are very messy and difficult to read. Remove
excess white space and properly align data structures so they are
easy on the eyes. This is the second batch since it covers many
lines of changes.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/lustre/include/lustre_export.h  |  76 ++--
 drivers/staging/lustre/lustre/include/lustre_fid.h |  12 +-
 drivers/staging/lustre/lustre/include/lustre_fld.h |  14 +-
 .../staging/lustre/lustre/include/lustre_handles.h |   2 +-
 .../staging/lustre/lustre/include/lustre_import.h  | 225 ++++++------
 .../staging/lustre/lustre/include/lustre_intent.h  |  24 +-
 drivers/staging/lustre/lustre/include/lustre_lib.h |   2 -
 drivers/staging/lustre/lustre/include/lustre_log.h |  38 +-
 drivers/staging/lustre/lustre/include/lustre_mdc.h |   2 +-
 drivers/staging/lustre/lustre/include/lustre_mds.h |   4 +-
 drivers/staging/lustre/lustre/include/lustre_net.h | 388 +++++++++++----------
 .../lustre/lustre/include/lustre_nrs_fifo.h        |   4 +-
 .../lustre/lustre/include/lustre_req_layout.h      |   8 +-
 drivers/staging/lustre/lustre/include/lustre_sec.h | 300 ++++++++--------
 14 files changed, 550 insertions(+), 549 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_export.h b/drivers/staging/lustre/lustre/include/lustre_export.h
index 1c70259..63fa656 100644
--- a/drivers/staging/lustre/lustre/include/lustre_export.h
+++ b/drivers/staging/lustre/lustre/include/lustre_export.h
@@ -48,9 +48,9 @@
 #include <lustre_dlm.h>
 
 enum obd_option {
-	OBD_OPT_FORCE =	 0x0001,
-	OBD_OPT_FAILOVER =      0x0002,
-	OBD_OPT_ABORT_RECOV =   0x0004,
+	OBD_OPT_FORCE		= 0x0001,
+	OBD_OPT_FAILOVER	= 0x0002,
+	OBD_OPT_ABORT_RECOV	= 0x0004,
 };
 
 /**
@@ -66,77 +66,77 @@ struct obd_export {
 	 * Subsequent client RPCs contain this handle id to identify
 	 * what export they are talking to.
 	 */
-	struct portals_handle     exp_handle;
-	atomic_t	      exp_refcount;
+	struct portals_handle		exp_handle;
+	atomic_t			exp_refcount;
 	/**
 	 * Set of counters below is to track where export references are
 	 * kept. The exp_rpc_count is used for reconnect handling also,
 	 * the cb_count and locks_count are for debug purposes only for now.
 	 * The sum of them should be less than exp_refcount by 3
 	 */
-	atomic_t	      exp_rpc_count; /* RPC references */
-	atomic_t	      exp_cb_count; /* Commit callback references */
+	atomic_t			exp_rpc_count; /* RPC references */
+	atomic_t			exp_cb_count; /* Commit callback references */
 	/** Number of queued replay requests to be processes */
-	atomic_t		  exp_replay_count;
-	atomic_t	      exp_locks_count; /** Lock references */
+	atomic_t			exp_replay_count;
+	atomic_t			exp_locks_count; /** Lock references */
 #if LUSTRE_TRACKS_LOCK_EXP_REFS
 	struct list_head		exp_locks_list;
-	spinlock_t		  exp_locks_list_guard;
+	spinlock_t			exp_locks_list_guard;
 #endif
 	/** UUID of client connected to this export */
-	struct obd_uuid	   exp_client_uuid;
+	struct obd_uuid			exp_client_uuid;
 	/** To link all exports on an obd device */
 	struct list_head		exp_obd_chain;
 	/** work_struct for destruction of export */
-	struct work_struct	exp_zombie_work;
-	struct rhash_head	exp_uuid_hash; /** uuid-export hash*/
+	struct work_struct		exp_zombie_work;
+	struct rhash_head		exp_uuid_hash; /** uuid-export hash*/
 	/** Obd device of this export */
-	struct obd_device	*exp_obd;
+	struct obd_device		*exp_obd;
 	/**
 	 * "reverse" import to send requests (e.g. from ldlm) back to client
 	 * exp_lock protect its change
 	 */
-	struct obd_import	*exp_imp_reverse;
-	struct lprocfs_stats     *exp_md_stats;
+	struct obd_import		*exp_imp_reverse;
+	struct lprocfs_stats		*exp_md_stats;
 	/** Active connection */
-	struct ptlrpc_connection *exp_connection;
+	struct ptlrpc_connection	*exp_connection;
 	/** Connection count value from last successful reconnect rpc */
-	u32		     exp_conn_cnt;
+	u32				exp_conn_cnt;
 	struct list_head		exp_outstanding_replies;
 	struct list_head		exp_uncommitted_replies;
-	spinlock_t		  exp_uncommitted_replies_lock;
+	spinlock_t			exp_uncommitted_replies_lock;
 	/** Last committed transno for this export */
-	u64		     exp_last_committed;
+	u64				exp_last_committed;
 	/** On replay all requests waiting for replay are linked here */
 	struct list_head		exp_req_replay_queue;
 	/**
 	 * protects exp_flags, exp_outstanding_replies and the change
 	 * of exp_imp_reverse
 	 */
-	spinlock_t		  exp_lock;
+	spinlock_t			exp_lock;
 	/** Compatibility flags for this export are embedded into
 	 *  exp_connect_data
 	 */
-	struct obd_connect_data   exp_connect_data;
-	enum obd_option	   exp_flags;
-	unsigned long	     exp_failed:1,
-				  exp_disconnected:1,
-				  exp_connecting:1,
-				  exp_flvr_changed:1,
-				  exp_flvr_adapt:1;
+	struct obd_connect_data		exp_connect_data;
+	enum obd_option			exp_flags;
+	unsigned long			exp_failed:1,
+					exp_disconnected:1,
+					exp_connecting:1,
+					exp_flvr_changed:1,
+					exp_flvr_adapt:1;
 	/* also protected by exp_lock */
-	enum lustre_sec_part      exp_sp_peer;
-	struct sptlrpc_flavor     exp_flvr;	     /* current */
-	struct sptlrpc_flavor     exp_flvr_old[2];      /* about-to-expire */
-	time64_t		  exp_flvr_expire[2];   /* seconds */
+	enum lustre_sec_part		exp_sp_peer;
+	struct sptlrpc_flavor		exp_flvr;	    /* current */
+	struct sptlrpc_flavor		exp_flvr_old[2];    /* about-to-expire */
+	time64_t			exp_flvr_expire[2]; /* seconds */
 
 	/** protects exp_hp_rpcs */
-	spinlock_t		  exp_rpc_lock;
-	struct list_head		  exp_hp_rpcs;	/* (potential) HP RPCs */
+	spinlock_t			exp_rpc_lock;
+	struct list_head		exp_hp_rpcs;	/* (potential) HP RPCs */
 
 	/** blocking dlm lock list, protected by exp_bl_list_lock */
 	struct list_head		exp_bl_list;
-	spinlock_t		  exp_bl_list_lock;
+	spinlock_t			exp_bl_list_lock;
 };
 
 static inline u64 *exp_connect_flags_ptr(struct obd_export *exp)
@@ -239,9 +239,9 @@ static inline bool imp_connect_disp_stripe(struct obd_import *imp)
 
 #define KKUC_CT_DATA_MAGIC	0x092013cea
 struct kkuc_ct_data {
-	u32		kcd_magic;
-	struct obd_uuid	kcd_uuid;
-	u32		kcd_archive;
+	u32			kcd_magic;
+	struct obd_uuid		kcd_uuid;
+	u32			kcd_archive;
 };
 
 /** @} export */
diff --git a/drivers/staging/lustre/lustre/include/lustre_fid.h b/drivers/staging/lustre/lustre/include/lustre_fid.h
index f0afa8d..5108864 100644
--- a/drivers/staging/lustre/lustre/include/lustre_fid.h
+++ b/drivers/staging/lustre/lustre/include/lustre_fid.h
@@ -331,13 +331,13 @@ struct lu_client_seq {
 	 * clients, this contains meta-sequence range. And for servers this
 	 * contains super-sequence range.
 	 */
-	struct lu_seq_range	 lcs_space;
+	struct lu_seq_range	lcs_space;
 
 	/* Seq related proc */
 	struct dentry		*lcs_debugfs_entry;
 
 	/* This holds last allocated fid in last obtained seq */
-	struct lu_fid	   lcs_fid;
+	struct lu_fid		lcs_fid;
 
 	/* LUSTRE_SEQ_METADATA or LUSTRE_SEQ_DATA */
 	enum lu_cli_type	lcs_type;
@@ -346,17 +346,17 @@ struct lu_client_seq {
 	 * Service uuid, passed from MDT + seq name to form unique seq name to
 	 * use it with procfs.
 	 */
-	char		    lcs_name[LUSTRE_MDT_MAXNAMELEN];
+	char			lcs_name[LUSTRE_MDT_MAXNAMELEN];
 
 	/*
 	 * Sequence width, that is how many objects may be allocated in one
 	 * sequence. Default value for it is LUSTRE_SEQ_MAX_WIDTH.
 	 */
-	u64		   lcs_width;
+	u64			lcs_width;
 
 	/* wait queue for fid allocation and update indicator */
-	wait_queue_head_t	     lcs_waitq;
-	int		     lcs_update;
+	wait_queue_head_t	lcs_waitq;
+	int			lcs_update;
 };
 
 /* Client methods */
diff --git a/drivers/staging/lustre/lustre/include/lustre_fld.h b/drivers/staging/lustre/lustre/include/lustre_fld.h
index 4bcabf7..92074ab 100644
--- a/drivers/staging/lustre/lustre/include/lustre_fld.h
+++ b/drivers/staging/lustre/lustre/include/lustre_fld.h
@@ -59,10 +59,10 @@ enum {
 };
 
 struct lu_fld_target {
-	struct list_head	       ft_chain;
-	struct obd_export       *ft_exp;
-	struct lu_server_fld    *ft_srv;
-	u64		    ft_idx;
+	struct list_head	 ft_chain;
+	struct obd_export	*ft_exp;
+	struct lu_server_fld	*ft_srv;
+	u64			 ft_idx;
 };
 
 struct lu_server_fld {
@@ -79,7 +79,7 @@ struct lu_server_fld {
 	struct mutex		lsf_lock;
 
 	/** Fld service name in form "fld-srv-lustre-MDTXXX" */
-	char		     lsf_name[LUSTRE_MDT_MAXNAMELEN];
+	char			lsf_name[LUSTRE_MDT_MAXNAMELEN];
 
 };
 
@@ -88,13 +88,13 @@ struct lu_client_fld {
 	struct dentry		*lcf_debugfs_entry;
 
 	/** List of exports client FLD knows about. */
-	struct list_head	       lcf_targets;
+	struct list_head	 lcf_targets;
 
 	/** Current hash to be used to chose an export. */
 	struct lu_fld_hash      *lcf_hash;
 
 	/** Exports count. */
-	int		      lcf_count;
+	int			 lcf_count;
 
 	/** Lock protecting exports list and fld_hash. */
 	spinlock_t		 lcf_lock;
diff --git a/drivers/staging/lustre/lustre/include/lustre_handles.h b/drivers/staging/lustre/lustre/include/lustre_handles.h
index 84f70f3..6836808 100644
--- a/drivers/staging/lustre/lustre/include/lustre_handles.h
+++ b/drivers/staging/lustre/lustre/include/lustre_handles.h
@@ -63,7 +63,7 @@ struct portals_handle_ops {
  * to compute the start of the structure based on the handle field.
  */
 struct portals_handle {
-	struct list_head			h_link;
+	struct list_head		h_link;
 	u64				h_cookie;
 	const void			*h_owner;
 	struct portals_handle_ops	*h_ops;
diff --git a/drivers/staging/lustre/lustre/include/lustre_import.h b/drivers/staging/lustre/lustre/include/lustre_import.h
index db075be..7d52665 100644
--- a/drivers/staging/lustre/lustre/include/lustre_import.h
+++ b/drivers/staging/lustre/lustre/include/lustre_import.h
@@ -58,26 +58,26 @@
 #define AT_FLG_NOHIST 0x1	  /* use last reported value only */
 
 struct adaptive_timeout {
-	time64_t	at_binstart;	 /* bin start time */
-	unsigned int	at_hist[AT_BINS];    /* timeout history bins */
+	time64_t	at_binstart;		/* bin start time */
+	unsigned int	at_hist[AT_BINS];	/* timeout history bins */
 	unsigned int	at_flags;
-	unsigned int	at_current;	  /* current timeout value */
-	unsigned int	at_worst_ever;       /* worst-ever timeout value */
-	time64_t	at_worst_time;       /* worst-ever timeout timestamp */
+	unsigned int	at_current;		/* current timeout value */
+	unsigned int	at_worst_ever;		/* worst-ever timeout value */
+	time64_t	at_worst_time;		/* worst-ever timeout timestamp */
 	spinlock_t	at_lock;
 };
 
 struct ptlrpc_at_array {
-	struct list_head       *paa_reqs_array; /** array to hold requests */
-	u32	     paa_size;       /** the size of array */
-	u32	     paa_count;      /** the total count of reqs */
-	time64_t     paa_deadline;   /** the earliest deadline of reqs */
-	u32	    *paa_reqs_count; /** the count of reqs in each entry */
+	struct list_head	*paa_reqs_array; /** array to hold requests */
+	u32			paa_size;        /** the size of array */
+	u32			paa_count;       /** the total count of reqs */
+	time64_t		paa_deadline;    /** the earliest deadline of reqs */
+	u32			*paa_reqs_count; /** the count of reqs in each entry */
 };
 
 #define IMP_AT_MAX_PORTALS 8
 struct imp_at {
-	int		     iat_portal[IMP_AT_MAX_PORTALS];
+	int			iat_portal[IMP_AT_MAX_PORTALS];
 	struct adaptive_timeout iat_net_latency;
 	struct adaptive_timeout iat_service_estimate[IMP_AT_MAX_PORTALS];
 };
@@ -86,16 +86,16 @@ struct imp_at {
 
 /** Possible import states */
 enum lustre_imp_state {
-	LUSTRE_IMP_CLOSED     = 1,
-	LUSTRE_IMP_NEW	= 2,
-	LUSTRE_IMP_DISCON     = 3,
-	LUSTRE_IMP_CONNECTING = 4,
-	LUSTRE_IMP_REPLAY     = 5,
+	LUSTRE_IMP_CLOSED	= 1,
+	LUSTRE_IMP_NEW		= 2,
+	LUSTRE_IMP_DISCON	= 3,
+	LUSTRE_IMP_CONNECTING	= 4,
+	LUSTRE_IMP_REPLAY	= 5,
 	LUSTRE_IMP_REPLAY_LOCKS = 6,
-	LUSTRE_IMP_REPLAY_WAIT  = 7,
-	LUSTRE_IMP_RECOVER    = 8,
-	LUSTRE_IMP_FULL       = 9,
-	LUSTRE_IMP_EVICTED    = 10,
+	LUSTRE_IMP_REPLAY_WAIT	= 7,
+	LUSTRE_IMP_RECOVER	= 8,
+	LUSTRE_IMP_FULL		= 9,
+	LUSTRE_IMP_EVICTED	= 10,
 };
 
 /** Returns test string representation of numeric import state \a state */
@@ -115,13 +115,13 @@ static inline char *ptlrpc_import_state_name(enum lustre_imp_state state)
  * List of import event types
  */
 enum obd_import_event {
-	IMP_EVENT_DISCON     = 0x808001,
-	IMP_EVENT_INACTIVE   = 0x808002,
-	IMP_EVENT_INVALIDATE = 0x808003,
-	IMP_EVENT_ACTIVE     = 0x808004,
-	IMP_EVENT_OCD	= 0x808005,
-	IMP_EVENT_DEACTIVATE = 0x808006,
-	IMP_EVENT_ACTIVATE   = 0x808007,
+	IMP_EVENT_DISCON	= 0x808001,
+	IMP_EVENT_INACTIVE	= 0x808002,
+	IMP_EVENT_INVALIDATE	= 0x808003,
+	IMP_EVENT_ACTIVE	= 0x808004,
+	IMP_EVENT_OCD		= 0x808005,
+	IMP_EVENT_DEACTIVATE	= 0x808006,
+	IMP_EVENT_ACTIVATE	= 0x808007,
 };
 
 /**
@@ -131,20 +131,20 @@ struct obd_import_conn {
 	/** Item for linking connections together */
 	struct list_head		oic_item;
 	/** Pointer to actual PortalRPC connection */
-	struct ptlrpc_connection *oic_conn;
+	struct ptlrpc_connection	*oic_conn;
 	/** uuid of remote side */
-	struct obd_uuid	   oic_uuid;
+	struct obd_uuid			oic_uuid;
 	/**
 	 * Time (64 bit jiffies) of last connection attempt on this connection
 	 */
-	u64		     oic_last_attempt;
+	u64				oic_last_attempt;
 };
 
 /* state history */
 #define IMP_STATE_HIST_LEN 16
 struct import_state_hist {
-	enum lustre_imp_state ish_state;
-	time64_t	ish_time;
+	enum lustre_imp_state		ish_state;
+	time64_t			ish_time;
 };
 
 /**
@@ -153,14 +153,14 @@ struct import_state_hist {
  */
 struct obd_import {
 	/** Local handle (== id) for this import. */
-	struct portals_handle     imp_handle;
+	struct portals_handle		imp_handle;
 	/** Reference counter */
-	atomic_t	      imp_refcount;
-	struct lustre_handle      imp_dlm_handle; /* client's ldlm export */
+	atomic_t			imp_refcount;
+	struct lustre_handle		imp_dlm_handle; /* client's ldlm export */
 	/** Currently active connection */
-	struct ptlrpc_connection *imp_connection;
+	struct ptlrpc_connection       *imp_connection;
 	/** PortalRPC client structure for this import */
-	struct ptlrpc_client     *imp_client;
+	struct ptlrpc_client	       *imp_client;
 	/** List element for linking into pinger chain */
 	struct list_head		imp_pinger_chain;
 	/** work struct for destruction of import */
@@ -188,133 +188,134 @@ struct obd_import {
 	/** @} */
 
 	/** List of not replied requests */
-	struct list_head	imp_unreplied_list;
+	struct list_head		imp_unreplied_list;
 	/** Known maximal replied XID */
-	u64			imp_known_replied_xid;
+	u64				imp_known_replied_xid;
 
 	/** obd device for this import */
-	struct obd_device	*imp_obd;
+	struct obd_device	       *imp_obd;
 
 	/**
 	 * some seciruty-related fields
 	 * @{
 	 */
-	struct ptlrpc_sec	*imp_sec;
-	struct mutex		  imp_sec_mutex;
-	time64_t		imp_sec_expire;
+	struct ptlrpc_sec	       *imp_sec;
+	struct mutex			imp_sec_mutex;
+	time64_t			imp_sec_expire;
 	/** @} */
 
 	/** Wait queue for those who need to wait for recovery completion */
-	wait_queue_head_t	       imp_recovery_waitq;
+	wait_queue_head_t		imp_recovery_waitq;
 
 	/** Number of requests currently in-flight */
-	atomic_t	      imp_inflight;
+	atomic_t			imp_inflight;
 	/** Number of requests currently unregistering */
-	atomic_t	      imp_unregistering;
+	atomic_t			imp_unregistering;
 	/** Number of replay requests inflight */
-	atomic_t	      imp_replay_inflight;
+	atomic_t			imp_replay_inflight;
 	/** Number of currently happening import invalidations */
-	atomic_t	      imp_inval_count;
+	atomic_t			imp_inval_count;
 	/** Numbner of request timeouts */
-	atomic_t	      imp_timeouts;
+	atomic_t			imp_timeouts;
 	/** Current import state */
-	enum lustre_imp_state     imp_state;
+	enum lustre_imp_state		imp_state;
 	/** Last replay state */
-	enum lustre_imp_state	  imp_replay_state;
+	enum lustre_imp_state		imp_replay_state;
 	/** History of import states */
-	struct import_state_hist  imp_state_hist[IMP_STATE_HIST_LEN];
-	int		       imp_state_hist_idx;
+	struct import_state_hist	imp_state_hist[IMP_STATE_HIST_LEN];
+	int				imp_state_hist_idx;
 	/** Current import generation. Incremented on every reconnect */
-	int		       imp_generation;
+	int				imp_generation;
 	/** Incremented every time we send reconnection request */
-	u32		     imp_conn_cnt;
+	u32				imp_conn_cnt;
        /**
 	* \see ptlrpc_free_committed remembers imp_generation value here
 	* after a check to save on unnecessary replay list iterations
 	*/
-	int		       imp_last_generation_checked;
+	int				imp_last_generation_checked;
 	/** Last transno we replayed */
-	u64		     imp_last_replay_transno;
+	u64				imp_last_replay_transno;
 	/** Last transno committed on remote side */
-	u64		     imp_peer_committed_transno;
+	u64				imp_peer_committed_transno;
 	/**
 	 * \see ptlrpc_free_committed remembers last_transno since its last
 	 * check here and if last_transno did not change since last run of
 	 * ptlrpc_free_committed and import generation is the same, we can
 	 * skip looking for requests to remove from replay list as optimisation
 	 */
-	u64		     imp_last_transno_checked;
+	u64				imp_last_transno_checked;
 	/**
 	 * Remote export handle. This is how remote side knows what export
 	 * we are talking to. Filled from response to connect request
 	 */
-	struct lustre_handle      imp_remote_handle;
+	struct lustre_handle		imp_remote_handle;
 	/** When to perform next ping. time in jiffies. */
-	unsigned long		imp_next_ping;
+	unsigned long			imp_next_ping;
 	/** When we last successfully connected. time in 64bit jiffies */
-	u64		     imp_last_success_conn;
+	u64				imp_last_success_conn;
 
 	/** List of all possible connection for import. */
 	struct list_head		imp_conn_list;
 	/**
 	 * Current connection. \a imp_connection is imp_conn_current->oic_conn
 	 */
-	struct obd_import_conn   *imp_conn_current;
+	struct obd_import_conn	       *imp_conn_current;
 
 	/** Protects flags, level, generation, conn_cnt, *_list */
-	spinlock_t		  imp_lock;
+	spinlock_t			imp_lock;
 
 	/* flags */
-	unsigned long	     imp_no_timeout:1, /* timeouts are disabled */
-				  imp_invalid:1,    /* evicted */
-				  /* administratively disabled */
-				  imp_deactive:1,
-				  /* try to recover the import */
-				  imp_replayable:1,
-				  /* don't run recovery (timeout instead) */
-				  imp_dlm_fake:1,
-				  /* use 1/2 timeout on MDS' OSCs */
-				  imp_server_timeout:1,
-				  /* VBR: imp in delayed recovery */
-				  imp_delayed_recovery:1,
-				  /* VBR: if gap was found then no lock replays
-				   */
-				  imp_no_lock_replay:1,
-				  /* recovery by versions was failed */
-				  imp_vbr_failed:1,
-				  /* force an immediate ping */
-				  imp_force_verify:1,
-				  /* force a scheduled ping */
-				  imp_force_next_verify:1,
-				  /* pingable */
-				  imp_pingable:1,
-				  /* resend for replay */
-				  imp_resend_replay:1,
-				  /* disable normal recovery, for test only. */
-				  imp_no_pinger_recover:1,
+	unsigned long			imp_no_timeout:1, /* timeouts are disabled */
+					imp_invalid:1,    /* evicted */
+					/* administratively disabled */
+					imp_deactive:1,
+					/* try to recover the import */
+					imp_replayable:1,
+					/* don't run recovery (timeout instead) */
+					imp_dlm_fake:1,
+					/* use 1/2 timeout on MDS' OSCs */
+					imp_server_timeout:1,
+					/* VBR: imp in delayed recovery */
+					imp_delayed_recovery:1,
+					/* VBR: if gap was found then no lock replays
+					 */
+					imp_no_lock_replay:1,
+					/* recovery by versions was failed */
+					imp_vbr_failed:1,
+					/* force an immediate ping */
+					imp_force_verify:1,
+					/* force a scheduled ping */
+					imp_force_next_verify:1,
+					/* pingable */
+					imp_pingable:1,
+					/* resend for replay */
+					imp_resend_replay:1,
+					/* disable normal recovery, for test only. */
+					imp_no_pinger_recover:1,
 #if OBD_OCD_VERSION(3, 0, 53, 0) > LUSTRE_VERSION_CODE
-				  /* need IR MNE swab */
-				  imp_need_mne_swab:1,
+					/* need IR MNE swab */
+					imp_need_mne_swab:1,
 #endif
-				  /* import must be reconnected instead of
-				   * chosing new connection
-				   */
-				  imp_force_reconnect:1,
-				  /* import has tried to connect with server */
-				  imp_connect_tried:1,
-				 /* connected but not FULL yet */
-				 imp_connected:1;
-	u32		     imp_connect_op;
-	struct obd_connect_data   imp_connect_data;
-	u64		     imp_connect_flags_orig;
-	u64			imp_connect_flags2_orig;
-	int		       imp_connect_error;
-
-	u32		     imp_msg_magic;
-	u32		     imp_msghdr_flags;       /* adjusted based on server capability */
-
-	struct imp_at	     imp_at;		 /* adaptive timeout data */
-	time64_t	     imp_last_reply_time;    /* for health check */
+					/* import must be reconnected instead of
+					 * chosing new connection
+					 */
+					imp_force_reconnect:1,
+					/* import has tried to connect with server */
+					imp_connect_tried:1,
+					/* connected but not FULL yet */
+					imp_connected:1;
+
+	u32				imp_connect_op;
+	struct obd_connect_data		imp_connect_data;
+	u64				imp_connect_flags_orig;
+	u64				imp_connect_flags2_orig;
+	int				imp_connect_error;
+
+	u32				imp_msg_magic;
+	u32				imp_msghdr_flags; /* adjusted based on server capability */
+
+	struct imp_at			imp_at;	/* adaptive timeout data */
+	time64_t			imp_last_reply_time; /* for health check */
 };
 
 /* import.c */
diff --git a/drivers/staging/lustre/lustre/include/lustre_intent.h b/drivers/staging/lustre/lustre/include/lustre_intent.h
index 3f26d7a..f97c318 100644
--- a/drivers/staging/lustre/lustre/include/lustre_intent.h
+++ b/drivers/staging/lustre/lustre/include/lustre_intent.h
@@ -39,18 +39,18 @@
 /* intent IT_XXX are defined in lustre/include/obd.h */
 
 struct lookup_intent {
-	int		it_op;
-	int		it_create_mode;
-	u64		it_flags;
-	int		it_disposition;
-	int		it_status;
-	u64		it_lock_handle;
-	u64		it_lock_bits;
-	int		it_lock_mode;
-	int		it_remote_lock_mode;
-	u64	   it_remote_lock_handle;
-	struct ptlrpc_request *it_request;
-	unsigned int    it_lock_set:1;
+	int			it_op;
+	int			it_create_mode;
+	u64			it_flags;
+	int			it_disposition;
+	int			it_status;
+	u64			it_lock_handle;
+	u64			it_lock_bits;
+	int			it_lock_mode;
+	int			it_remote_lock_mode;
+	u64			it_remote_lock_handle;
+	struct ptlrpc_request	*it_request;
+	unsigned int		it_lock_set:1;
 };
 
 static inline int it_disposition(struct lookup_intent *it, int flag)
diff --git a/drivers/staging/lustre/lustre/include/lustre_lib.h b/drivers/staging/lustre/lustre/include/lustre_lib.h
index 87748e9..da86e46 100644
--- a/drivers/staging/lustre/lustre/include/lustre_lib.h
+++ b/drivers/staging/lustre/lustre/include/lustre_lib.h
@@ -85,8 +85,6 @@ static inline int l_fatal_signal_pending(struct task_struct *p)
 
 /** @} lib */
 
-
-
 /* l_wait_event_abortable() is a bit like wait_event_killable()
  * except there is a fixed set of signals which will abort:
  * LUSTRE_FATAL_SIGS
diff --git a/drivers/staging/lustre/lustre/include/lustre_log.h b/drivers/staging/lustre/lustre/include/lustre_log.h
index 4ba4501..a576d40 100644
--- a/drivers/staging/lustre/lustre/include/lustre_log.h
+++ b/drivers/staging/lustre/lustre/include/lustre_log.h
@@ -66,15 +66,15 @@ enum llog_open_param {
 };
 
 struct plain_handle_data {
-	struct list_head	  phd_entry;
-	struct llog_handle *phd_cat_handle;
-	struct llog_cookie  phd_cookie; /* cookie of this log in its cat */
+	struct list_head	 phd_entry;
+	struct llog_handle	*phd_cat_handle;
+	struct llog_cookie	 phd_cookie; /* cookie of this log in its cat */
 };
 
 struct cat_handle_data {
-	struct list_head	      chd_head;
+	struct list_head	chd_head;
 	struct llog_handle     *chd_current_log; /* currently open log */
-	struct llog_handle	*chd_next_log; /* llog to be used next */
+	struct llog_handle     *chd_next_log; /* llog to be used next */
 };
 
 struct llog_handle;
@@ -101,28 +101,28 @@ struct llog_process_data {
 	 * Any useful data needed while processing catalog. This is
 	 * passed later to process callback.
 	 */
-	void		*lpd_data;
+	void			*lpd_data;
 	/**
 	 * Catalog process callback function, called for each record
 	 * in catalog.
 	 */
-	llog_cb_t	    lpd_cb;
+	llog_cb_t		lpd_cb;
 	/**
 	 * Start processing the catalog from startcat/startidx
 	 */
-	int		  lpd_startcat;
-	int		  lpd_startidx;
+	int			lpd_startcat;
+	int			lpd_startidx;
 };
 
 struct llog_process_cat_data {
 	/**
 	 * Temporary stored first_idx while scanning log.
 	 */
-	int		  lpcd_first_idx;
+	int			lpcd_first_idx;
 	/**
 	 * Temporary stored last_idx while scanning log.
 	 */
-	int		  lpcd_last_idx;
+	int			lpcd_last_idx;
 };
 
 struct thandle;
@@ -234,23 +234,23 @@ struct llog_handle {
 #define LLOG_CTXT_FLAG_STOP		 0x00000002
 
 struct llog_ctxt {
-	int		      loc_idx; /* my index the obd array of ctxt's */
-	struct obd_device       *loc_obd; /* points back to the containing obd*/
-	struct obd_llog_group   *loc_olg; /* group containing that ctxt */
-	struct obd_export       *loc_exp; /* parent "disk" export (e.g. MDS) */
-	struct obd_import       *loc_imp; /* to use in RPC's: can be backward
+	int			 loc_idx; /* my index the obd array of ctxt's */
+	struct obd_device	*loc_obd; /* points back to the containing obd*/
+	struct obd_llog_group	*loc_olg; /* group containing that ctxt */
+	struct obd_export	*loc_exp; /* parent "disk" export (e.g. MDS) */
+	struct obd_import	*loc_imp; /* to use in RPC's: can be backward
 					   * pointing import
 					   */
 	struct llog_operations  *loc_logops;
 	struct llog_handle      *loc_handle;
 	struct mutex		 loc_mutex; /* protect loc_imp */
-	atomic_t	     loc_refcount;
-	long		     loc_flags; /* flags, see above defines */
+	atomic_t		 loc_refcount;
+	long			 loc_flags; /* flags, see above defines */
 	/*
 	 * llog chunk size, and llog record size can not be bigger than
 	 * loc_chunk_size
 	 */
-	u32			loc_chunk_size;
+	u32			 loc_chunk_size;
 };
 
 #define LLOG_PROC_BREAK 0x0001
diff --git a/drivers/staging/lustre/lustre/include/lustre_mdc.h b/drivers/staging/lustre/lustre/include/lustre_mdc.h
index c1fb324..90fcbae 100644
--- a/drivers/staging/lustre/lustre/include/lustre_mdc.h
+++ b/drivers/staging/lustre/lustre/include/lustre_mdc.h
@@ -106,7 +106,7 @@ static inline void mdc_get_rpc_lock(struct mdc_rpc_lock *lck,
 	 * Only when all fake requests are finished can normal requests
 	 * be sent, to ensure they are recoverable again.
 	 */
- again:
+again:
 	mutex_lock(&lck->rpcl_mutex);
 
 	if (CFS_FAIL_CHECK_QUIET(OBD_FAIL_MDC_RPCS_SEM)) {
diff --git a/drivers/staging/lustre/lustre/include/lustre_mds.h b/drivers/staging/lustre/lustre/include/lustre_mds.h
index f665556..df178cc 100644
--- a/drivers/staging/lustre/lustre/include/lustre_mds.h
+++ b/drivers/staging/lustre/lustre/include/lustre_mds.h
@@ -50,8 +50,8 @@
 #include <lustre_export.h>
 
 struct mds_group_info {
-	struct obd_uuid *uuid;
-	int group;
+	struct obd_uuid		*uuid;
+	int			group;
 };
 
 #define MDD_OBD_NAME     "mdd_obd"
diff --git a/drivers/staging/lustre/lustre/include/lustre_net.h b/drivers/staging/lustre/lustre/include/lustre_net.h
index 050a7ec..47b9632 100644
--- a/drivers/staging/lustre/lustre/include/lustre_net.h
+++ b/drivers/staging/lustre/lustre/include/lustre_net.h
@@ -136,9 +136,9 @@
  *
  * Constants determine how memory is used to buffer incoming service requests.
  *
- * ?_NBUFS	      # buffers to allocate when growing the pool
- * ?_BUFSIZE	    # bytes in a single request buffer
- * ?_MAXREQSIZE	 # maximum request service will receive
+ * ?_NBUFS		# buffers to allocate when growing the pool
+ * ?_BUFSIZE		# bytes in a single request buffer
+ * ?_MAXREQSIZE		# maximum request service will receive
  *
  * When fewer than ?_NBUFS/2 buffers are posted for receive, another chunk
  * of ?_NBUFS is added to the pool.
@@ -231,7 +231,7 @@
  *	top of this subset
  *     b) bind service threads on a few partitions, see modparameters of
  *	MDS and OSS for details
-*
+ *
  * NB: these calculations (and examples below) are simplified to help
  *     understanding, the real implementation is a little more complex,
  *     please see ptlrpc_server_nthreads_check() for details.
@@ -263,12 +263,12 @@
 #define LDLM_NTHRS_BASE		24
 #define LDLM_NTHRS_MAX		(num_online_cpus() == 1 ? 64 : 128)
 
-#define LDLM_BL_THREADS   LDLM_NTHRS_AUTO_INIT
-#define LDLM_CLIENT_NBUFS 1
-#define LDLM_SERVER_NBUFS 64
-#define LDLM_BUFSIZE      (8 * 1024)
-#define LDLM_MAXREQSIZE   (5 * 1024)
-#define LDLM_MAXREPSIZE   (1024)
+#define LDLM_BL_THREADS		LDLM_NTHRS_AUTO_INIT
+#define LDLM_CLIENT_NBUFS	1
+#define LDLM_SERVER_NBUFS	64
+#define LDLM_BUFSIZE		(8 * 1024)
+#define LDLM_MAXREQSIZE		(5 * 1024)
+#define LDLM_MAXREPSIZE		(1024)
 
 #define MDS_MAXREQSIZE		(5 * 1024)	/* >= 4736 */
 
@@ -292,23 +292,23 @@ struct ptlrpc_connection {
 	/** linkage for connections hash table */
 	struct rhash_head	c_hash;
 	/** Our own lnet nid for this connection */
-	lnet_nid_t	      c_self;
+	lnet_nid_t		c_self;
 	/** Remote side nid for this connection */
 	struct lnet_process_id	c_peer;
 	/** UUID of the other side */
-	struct obd_uuid	 c_remote_uuid;
+	struct obd_uuid		c_remote_uuid;
 	/** reference counter for this connection */
-	atomic_t	    c_refcount;
+	atomic_t		c_refcount;
 };
 
 /** Client definition for PortalRPC */
 struct ptlrpc_client {
 	/** What lnet portal does this client send messages to by default */
-	u32		   cli_request_portal;
+	u32			cli_request_portal;
 	/** What portal do we expect replies on */
-	u32		   cli_reply_portal;
+	u32			cli_reply_portal;
 	/** Name of the client */
-	char		   *cli_name;
+	char			*cli_name;
 };
 
 /** state flags of requests */
@@ -326,8 +326,8 @@ struct ptlrpc_client {
 	 * a pointer to it here.  The pointer_arg ensures this struct is at
 	 * least big enough for that.
 	 */
-	void      *pointer_arg[11];
-	u64      space[7];
+	void			*pointer_arg[11];
+	u64			space[7];
 };
 
 struct ptlrpc_request_set;
@@ -346,26 +346,26 @@ struct ptlrpc_client {
  * returned.
  */
 struct ptlrpc_request_set {
-	atomic_t	  set_refcount;
+	atomic_t		set_refcount;
 	/** number of in queue requests */
-	atomic_t	  set_new_count;
+	atomic_t		set_new_count;
 	/** number of uncompleted requests */
-	atomic_t	  set_remaining;
+	atomic_t		set_remaining;
 	/** wait queue to wait on for request events */
-	wait_queue_head_t	   set_waitq;
-	wait_queue_head_t	  *set_wakeup_ptr;
+	wait_queue_head_t	set_waitq;
+	wait_queue_head_t	*set_wakeup_ptr;
 	/** List of requests in the set */
-	struct list_head	    set_requests;
+	struct list_head	set_requests;
 	/**
 	 * List of completion callbacks to be called when the set is completed
 	 * This is only used if \a set_interpret is NULL.
 	 * Links struct ptlrpc_set_cbdata.
 	 */
-	struct list_head	    set_cblist;
+	struct list_head	set_cblist;
 	/** Completion callback, if only one. */
-	set_interpreter_func  set_interpret;
+	set_interpreter_func	set_interpret;
 	/** opaq argument passed to completion \a set_interpret callback. */
-	void		 *set_arg;
+	void			*set_arg;
 	/**
 	 * Lock for \a set_new_requests manipulations
 	 * locked so that any old caller can communicate requests to
@@ -373,17 +373,17 @@ struct ptlrpc_request_set {
 	 */
 	spinlock_t		set_new_req_lock;
 	/** List of new yet unsent requests. Only used with ptlrpcd now. */
-	struct list_head	    set_new_requests;
+	struct list_head	set_new_requests;
 
 	/** rq_status of requests that have been freed already */
-	int		   set_rc;
+	int			set_rc;
 	/** Additional fields used by the flow control extension */
 	/** Maximum number of RPCs in flight */
-	int		   set_max_inflight;
+	int			set_max_inflight;
 	/** Callback function used to generate RPCs */
-	set_producer_func     set_producer;
+	set_producer_func	set_producer;
 	/** opaq argument passed to the producer callback */
-	void		 *set_producer_arg;
+	void			*set_producer_arg;
 };
 
 /**
@@ -391,11 +391,11 @@ struct ptlrpc_request_set {
  */
 struct ptlrpc_set_cbdata {
 	/** List linkage item */
-	struct list_head	      psc_item;
+	struct list_head	psc_item;
 	/** Pointer to interpreting function */
 	set_interpreter_func    psc_interpret;
 	/** Opaq argument to pass to the callback */
-	void		   *psc_data;
+	void			*psc_data;
 };
 
 struct ptlrpc_bulk_desc;
@@ -423,76 +423,76 @@ struct ptlrpc_cb_id {
  */
 struct ptlrpc_reply_state {
 	/** Callback description */
-	struct ptlrpc_cb_id    rs_cb_id;
+	struct ptlrpc_cb_id	rs_cb_id;
 	/** Linkage for list of all reply states in a system */
-	struct list_head	     rs_list;
+	struct list_head	rs_list;
 	/** Linkage for list of all reply states on same export */
-	struct list_head	     rs_exp_list;
+	struct list_head	rs_exp_list;
 	/** Linkage for list of all reply states for same obd */
-	struct list_head	     rs_obd_list;
+	struct list_head	rs_obd_list;
 #if RS_DEBUG
-	struct list_head	     rs_debug_list;
+	struct list_head	rs_debug_list;
 #endif
 	/** A spinlock to protect the reply state flags */
 	spinlock_t		rs_lock;
 	/** Reply state flags */
-	unsigned long	  rs_difficult:1; /* ACK/commit stuff */
-	unsigned long	  rs_no_ack:1;    /* no ACK, even for
-					   * difficult requests
-					   */
-	unsigned long	  rs_scheduled:1;     /* being handled? */
-	unsigned long	  rs_scheduled_ever:1;/* any schedule attempts? */
-	unsigned long	  rs_handled:1;  /* been handled yet? */
-	unsigned long	  rs_on_net:1;   /* reply_out_callback pending? */
-	unsigned long	  rs_prealloc:1; /* rs from prealloc list */
-	unsigned long	  rs_committed:1;/* the transaction was committed
-					  * and the rs was dispatched
-					  */
+	unsigned long		rs_difficult:1; /* ACK/commit stuff */
+	unsigned long		rs_no_ack:1;    /* no ACK, even for
+						 * difficult requests
+						 */
+	unsigned long		rs_scheduled:1; /* being handled? */
+	unsigned long		rs_scheduled_ever:1; /* any schedule attempts? */
+	unsigned long		rs_handled:1;	/* been handled yet? */
+	unsigned long		rs_on_net:1;	/* reply_out_callback pending? */
+	unsigned long		rs_prealloc:1;	/* rs from prealloc list */
+	unsigned long		rs_committed:1;	/* the transaction was committed
+						 * and the rs was dispatched
+						 */
 	atomic_t		rs_refcount;	/* number of users */
 	/** Number of locks awaiting client ACK */
 	int			rs_nlocks;
 
 	/** Size of the state */
-	int		    rs_size;
+	int			rs_size;
 	/** opcode */
-	u32		  rs_opc;
+	u32			rs_opc;
 	/** Transaction number */
-	u64		  rs_transno;
+	u64			rs_transno;
 	/** xid */
-	u64		  rs_xid;
-	struct obd_export     *rs_export;
+	u64			rs_xid;
+	struct obd_export	*rs_export;
 	struct ptlrpc_service_part *rs_svcpt;
 	/** Lnet metadata handle for the reply */
-	struct lnet_handle_md		rs_md_h;
+	struct lnet_handle_md	rs_md_h;
 
 	/** Context for the service thread */
-	struct ptlrpc_svc_ctx *rs_svc_ctx;
+	struct ptlrpc_svc_ctx	*rs_svc_ctx;
 	/** Reply buffer (actually sent to the client), encoded if needed */
-	struct lustre_msg     *rs_repbuf;       /* wrapper */
+	struct lustre_msg	*rs_repbuf;	/* wrapper */
 	/** Size of the reply buffer */
-	int		    rs_repbuf_len;   /* wrapper buf length */
+	int			rs_repbuf_len;	/* wrapper buf length */
 	/** Size of the reply message */
-	int		    rs_repdata_len;  /* wrapper msg length */
+	int			rs_repdata_len;	/* wrapper msg length */
 	/**
 	 * Actual reply message. Its content is encrypted (if needed) to
 	 * produce reply buffer for actual sending. In simple case
 	 * of no network encryption we just set \a rs_repbuf to \a rs_msg
 	 */
-	struct lustre_msg     *rs_msg;	  /* reply message */
+	struct lustre_msg	*rs_msg;	/* reply message */
 
 	/** Handles of locks awaiting client reply ACK */
-	struct lustre_handle   rs_locks[RS_MAX_LOCKS];
+	struct lustre_handle	rs_locks[RS_MAX_LOCKS];
 	/** Lock modes of locks in \a rs_locks */
-	enum ldlm_mode	    rs_modes[RS_MAX_LOCKS];
+	enum ldlm_mode		rs_modes[RS_MAX_LOCKS];
 };
 
 struct ptlrpc_thread;
 
 /** RPC stages */
 enum rq_phase {
-	RQ_PHASE_NEW	    = 0xebc0de00,
-	RQ_PHASE_RPC	    = 0xebc0de01,
-	RQ_PHASE_BULK	   = 0xebc0de02,
+	RQ_PHASE_NEW		= 0xebc0de00,
+	RQ_PHASE_RPC		= 0xebc0de01,
+	RQ_PHASE_BULK		= 0xebc0de02,
 	RQ_PHASE_INTERPRET      = 0xebc0de03,
 	RQ_PHASE_COMPLETE       = 0xebc0de04,
 	RQ_PHASE_UNREG_RPC	= 0xebc0de05,
@@ -513,11 +513,11 @@ typedef int (*ptlrpc_interpterer_t)(const struct lu_env *env,
  */
 struct ptlrpc_request_pool {
 	/** Locks the list */
-	spinlock_t prp_lock;
+	spinlock_t		prp_lock;
 	/** list of ptlrpc_request structs */
-	struct list_head prp_req_list;
+	struct list_head	prp_req_list;
 	/** Maximum message size that would fit into a request from this pool */
-	int prp_rq_size;
+	int			prp_rq_size;
 	/** Function to allocate more requests for this pool */
 	int (*prp_populate)(struct ptlrpc_request_pool *, int);
 };
@@ -741,9 +741,10 @@ struct ptlrpc_request {
 	 */
 	spinlock_t			 rq_lock;
 	spinlock_t			 rq_early_free_lock;
+
 	/** client-side flags are serialized by rq_lock @{ */
 	unsigned int rq_intr:1, rq_replied:1, rq_err:1,
-		rq_timedout:1, rq_resend:1, rq_restart:1,
+		     rq_timedout:1, rq_resend:1, rq_restart:1,
 		/**
 		 * when ->rq_replay is set, request is kept by the client even
 		 * after server commits corresponding transaction. This is
@@ -797,21 +798,21 @@ struct ptlrpc_request {
 	 * !rq_truncate : # reply bytes actually received,
 	 *  rq_truncate : required repbuf_len for resend
 	 */
-	int rq_nob_received;
+	int				rq_nob_received;
 	/** Request length */
-	int rq_reqlen;
+	int				rq_reqlen;
 	/** Reply length */
-	int rq_replen;
+	int				rq_replen;
 	/** Pool if request is from preallocated list */
 	struct ptlrpc_request_pool     *rq_pool;
 	/** Request message - what client sent */
-	struct lustre_msg *rq_reqmsg;
+	struct lustre_msg	       *rq_reqmsg;
 	/** Reply message - server response */
-	struct lustre_msg *rq_repmsg;
+	struct lustre_msg	       *rq_repmsg;
 	/** Transaction number */
-	u64 rq_transno;
+	u64				rq_transno;
 	/** xid */
-	u64 rq_xid;
+	u64				rq_xid;
 	/** bulk match bits */
 	u64				rq_mbits;
 	/**
@@ -820,7 +821,7 @@ struct ptlrpc_request {
 	 * Also see \a rq_replay comment above.
 	 * It's also link chain on obd_export::exp_req_replay_queue
 	 */
-	struct list_head rq_replay_list;
+	struct list_head		rq_replay_list;
 	/** non-shared members for client & server request*/
 	union {
 		struct ptlrpc_cli_req    rq_cli;
@@ -857,32 +858,32 @@ struct ptlrpc_request {
 	char			*rq_repbuf;	/**< rep buffer */
 	struct lustre_msg       *rq_repdata;	/**< rep wrapper msg */
 	/** only in priv mode */
-	struct lustre_msg       *rq_clrbuf;
-	int		      rq_reqbuf_len;  /* req wrapper buf len */
-	int		      rq_reqdata_len; /* req wrapper msg len */
-	int		      rq_repbuf_len;  /* rep buffer len */
-	int		      rq_repdata_len; /* rep wrapper msg len */
-	int		      rq_clrbuf_len;  /* only in priv mode */
-	int		      rq_clrdata_len; /* only in priv mode */
+	struct lustre_msg      *rq_clrbuf;
+	int			rq_reqbuf_len;  /* req wrapper buf len */
+	int			rq_reqdata_len; /* req wrapper msg len */
+	int			rq_repbuf_len;  /* rep buffer len */
+	int			rq_repdata_len; /* rep wrapper msg len */
+	int			rq_clrbuf_len;  /* only in priv mode */
+	int			rq_clrdata_len; /* only in priv mode */
 
 	/** early replies go to offset 0, regular replies go after that */
-	unsigned int	     rq_reply_off;
+	unsigned int		rq_reply_off;
 
 	/** @} */
 
 	/** Fields that help to see if request and reply were swabbed or not */
-	u32 rq_req_swab_mask;
-	u32 rq_rep_swab_mask;
+	u32			rq_req_swab_mask;
+	u32			rq_rep_swab_mask;
 
 	/** how many early replies (for stats) */
-	int rq_early_count;
+	int			rq_early_count;
 
 	/** Server-side, export on which request was received */
-	struct obd_export		*rq_export;
+	struct obd_export	*rq_export;
 	/** import where request is being sent */
-	struct obd_import		*rq_import;
+	struct obd_import	*rq_import;
 	/** our LNet NID */
-	lnet_nid_t	   rq_self;
+	lnet_nid_t		rq_self;
 	/** Peer description (the other side) */
 	struct lnet_process_id	rq_peer;
 	/** Descriptor for the NID from which the peer sent the request. */
@@ -895,11 +896,11 @@ struct ptlrpc_request {
 	/**
 	 * when request/reply sent (secs), or time when request should be sent
 	 */
-	time64_t rq_sent;
+	time64_t		rq_sent;
 	/** when request must finish. */
-	time64_t		  rq_deadline;
+	time64_t		rq_deadline;
 	/** request format description */
-	struct req_capsule	  rq_pill;
+	struct req_capsule	rq_pill;
 };
 
 /**
@@ -1039,15 +1040,15 @@ static inline void lustre_set_rep_swabbed(struct ptlrpc_request *req,
 #define FLAG(field, str) (field ? str : "")
 
 /** Convert bit flags into a string */
-#define DEBUG_REQ_FLAGS(req)						    \
-	ptlrpc_rqphase2str(req),						\
-	FLAG(req->rq_intr, "I"), FLAG(req->rq_replied, "R"),		    \
-	FLAG(req->rq_err, "E"),	FLAG(req->rq_net_err, "e"),		    \
-	FLAG(req->rq_timedout, "X") /* eXpired */, FLAG(req->rq_resend, "S"),   \
-	FLAG(req->rq_restart, "T"), FLAG(req->rq_replay, "P"),		  \
-	FLAG(req->rq_no_resend, "N"),					   \
-	FLAG(req->rq_waiting, "W"),					     \
-	FLAG(req->rq_wait_ctx, "C"), FLAG(req->rq_hp, "H"),		     \
+#define DEBUG_REQ_FLAGS(req)						      \
+	ptlrpc_rqphase2str(req),					      \
+	FLAG(req->rq_intr, "I"), FLAG(req->rq_replied, "R"),		      \
+	FLAG(req->rq_err, "E"),	FLAG(req->rq_net_err, "e"),		      \
+	FLAG(req->rq_timedout, "X") /* eXpired */, FLAG(req->rq_resend, "S"), \
+	FLAG(req->rq_restart, "T"), FLAG(req->rq_replay, "P"),		      \
+	FLAG(req->rq_no_resend, "N"),					      \
+	FLAG(req->rq_waiting, "W"),					      \
+	FLAG(req->rq_wait_ctx, "C"), FLAG(req->rq_hp, "H"),		      \
 	FLAG(req->rq_committed, "M")
 
 #define REQ_FLAGS_FMT "%s:%s%s%s%s%s%s%s%s%s%s%s%s%s"
@@ -1060,14 +1061,14 @@ void _debug_req(struct ptlrpc_request *req,
  * Helper that decides if we need to print request according to current debug
  * level settings
  */
-#define debug_req(msgdata, mask, cdls, req, fmt, a...)			\
-do {									  \
-	CFS_CHECK_STACK(msgdata, mask, cdls);				 \
+#define debug_req(msgdata, mask, cdls, req, fmt, a...)			      \
+do {									      \
+	CFS_CHECK_STACK(msgdata, mask, cdls);				      \
 									      \
-	if (((mask) & D_CANTMASK) != 0 ||				     \
-	    ((libcfs_debug & (mask)) != 0 &&				  \
-	     (libcfs_subsystem_debug & DEBUG_SUBSYSTEM) != 0))		\
-		_debug_req((req), msgdata, fmt, ##a);			 \
+	if (((mask) & D_CANTMASK) != 0 ||				      \
+	    ((libcfs_debug & (mask)) != 0 &&				      \
+	     (libcfs_subsystem_debug & DEBUG_SUBSYSTEM) != 0))		      \
+		_debug_req((req), msgdata, fmt, ##a);			      \
 } while (0)
 
 /**
@@ -1075,16 +1076,16 @@ void _debug_req(struct ptlrpc_request *req,
  * content into lustre debug log.
  * for most callers (level is a constant) this is resolved at compile time
  */
-#define DEBUG_REQ(level, req, fmt, args...)				   \
-do {									  \
-	if ((level) & (D_ERROR | D_WARNING)) {				\
-		static struct cfs_debug_limit_state cdls;			  \
-		LIBCFS_DEBUG_MSG_DATA_DECL(msgdata, level, &cdls);	    \
+#define DEBUG_REQ(level, req, fmt, args...)				      \
+do {									      \
+	if ((level) & (D_ERROR | D_WARNING)) {				      \
+		static struct cfs_debug_limit_state cdls;		      \
+		LIBCFS_DEBUG_MSG_DATA_DECL(msgdata, level, &cdls);	      \
 		debug_req(&msgdata, level, &cdls, req, "@@@ "fmt" ", ## args);\
 	} else {							      \
-		LIBCFS_DEBUG_MSG_DATA_DECL(msgdata, level, NULL);	     \
+		LIBCFS_DEBUG_MSG_DATA_DECL(msgdata, level, NULL);	      \
 		debug_req(&msgdata, level, NULL, req, "@@@ "fmt" ", ## args); \
-	}								     \
+	}								      \
 } while (0)
 /** @} */
 
@@ -1093,15 +1094,15 @@ void _debug_req(struct ptlrpc_request *req,
  */
 struct ptlrpc_bulk_page {
 	/** Linkage to list of pages in a bulk */
-	struct list_head       bp_link;
+	struct list_head	bp_link;
 	/**
 	 * Number of bytes in a page to transfer starting from \a bp_pageoffset
 	 */
-	int	      bp_buflen;
+	int			bp_buflen;
 	/** offset within a page */
-	int	      bp_pageoffset;
+	int			bp_pageoffset;
 	/** The page itself */
-	struct page     *bp_page;
+	struct page		*bp_page;
 };
 
 enum ptlrpc_bulk_op_type {
@@ -1204,38 +1205,38 @@ struct ptlrpc_bulk_frag_ops {
  */
 struct ptlrpc_bulk_desc {
 	/** completed with failure */
-	unsigned long bd_failure:1;
+	unsigned long			bd_failure:1;
 	/** client side */
-	unsigned long bd_registered:1;
+	unsigned long			bd_registered:1;
 	/** For serialization with callback */
-	spinlock_t bd_lock;
+	spinlock_t			bd_lock;
 	/** Import generation when request for this bulk was sent */
-	int bd_import_generation;
+	int				bd_import_generation;
 	/** {put,get}{source,sink}{kvec,kiov} */
-	enum ptlrpc_bulk_op_type bd_type;
+	enum ptlrpc_bulk_op_type	bd_type;
 	/** LNet portal for this bulk */
-	u32 bd_portal;
+	u32				bd_portal;
 	/** Server side - export this bulk created for */
-	struct obd_export *bd_export;
+	struct obd_export		*bd_export;
 	/** Client side - import this bulk was sent on */
-	struct obd_import *bd_import;
+	struct obd_import		*bd_import;
 	/** Back pointer to the request */
-	struct ptlrpc_request *bd_req;
-	struct ptlrpc_bulk_frag_ops *bd_frag_ops;
-	wait_queue_head_t	    bd_waitq;	/* server side only WQ */
-	int		    bd_iov_count;    /* # entries in bd_iov */
-	int		    bd_max_iov;      /* allocated size of bd_iov */
-	int		    bd_nob;	  /* # bytes covered */
-	int		    bd_nob_transferred; /* # bytes GOT/PUT */
-
-	u64			bd_last_mbits;
-
-	struct ptlrpc_cb_id    bd_cbid;	 /* network callback info */
-	lnet_nid_t	     bd_sender;       /* stash event::sender */
-	int			bd_md_count;	/* # valid entries in bd_mds */
-	int			bd_md_max_brw;	/* max entries in bd_mds */
+	struct ptlrpc_request		*bd_req;
+	struct ptlrpc_bulk_frag_ops	*bd_frag_ops;
+	wait_queue_head_t		bd_waitq;     /* server side only WQ */
+	int				bd_iov_count; /* # entries in bd_iov */
+	int				bd_max_iov;   /* allocated size of bd_iov */
+	int				bd_nob;	      /* # bytes covered */
+	int				bd_nob_transferred; /* # bytes GOT/PUT */
+
+	u64				bd_last_mbits;
+
+	struct ptlrpc_cb_id		bd_cbid;	/* network callback info */
+	lnet_nid_t			bd_sender;	/* stash event::sender */
+	int				bd_md_count;	/* # valid entries in bd_mds */
+	int				bd_md_max_brw;	/* max entries in bd_mds */
 	/** array of associated MDs */
-	struct lnet_handle_md	bd_mds[PTLRPC_BULK_OPS_COUNT];
+	struct lnet_handle_md		bd_mds[PTLRPC_BULK_OPS_COUNT];
 
 	union {
 		struct {
@@ -1277,20 +1278,20 @@ struct ptlrpc_thread {
 	/**
 	 * List of active threads in svc->srv_threads
 	 */
-	struct list_head t_link;
+	struct list_head		t_link;
 	/**
 	 * thread-private data (preallocated memory)
 	 */
-	void *t_data;
-	u32 t_flags;
+	void				*t_data;
+	u32				t_flags;
 	/**
 	 * service thread index, from ptlrpc_start_threads
 	 */
-	unsigned int t_id;
+	unsigned int			t_id;
 	/**
 	 * service thread pid
 	 */
-	pid_t t_pid;
+	pid_t				t_pid;
 	/**
 	 * put watchdog in the structure per thread b=14840
 	 *
@@ -1304,7 +1305,7 @@ struct ptlrpc_thread {
 	 * the svc this thread belonged to b=18582
 	 */
 	struct ptlrpc_service_part	*t_svcpt;
-	wait_queue_head_t			t_ctl_waitq;
+	wait_queue_head_t		t_ctl_waitq;
 	struct lu_env			*t_env;
 	char				t_name[PTLRPC_THR_NAME_LEN];
 };
@@ -1363,22 +1364,22 @@ static inline int thread_test_and_clear_flags(struct ptlrpc_thread *thread,
  */
 struct ptlrpc_request_buffer_desc {
 	/** Link item for rqbds on a service */
-	struct list_head	     rqbd_list;
+	struct list_head		rqbd_list;
 	/** History of requests for this buffer */
-	struct list_head	     rqbd_reqs;
+	struct list_head		rqbd_reqs;
 	/** Back pointer to service for which this buffer is registered */
-	struct ptlrpc_service_part *rqbd_svcpt;
+	struct ptlrpc_service_part	*rqbd_svcpt;
 	/** LNet descriptor */
 	struct lnet_handle_md		rqbd_md_h;
-	int		    rqbd_refcount;
+	int				rqbd_refcount;
 	/** The buffer itself */
-	char		  *rqbd_buffer;
-	struct ptlrpc_cb_id    rqbd_cbid;
+	char				*rqbd_buffer;
+	struct ptlrpc_cb_id		rqbd_cbid;
 	/**
 	 * This "embedded" request structure is only used for the
 	 * last request to fit into the buffer
 	 */
-	struct ptlrpc_request  rqbd_req;
+	struct ptlrpc_request		rqbd_req;
 };
 
 typedef int  (*svc_handler_t)(struct ptlrpc_request *req);
@@ -1431,44 +1432,44 @@ struct ptlrpc_service {
 	spinlock_t			srv_lock;
 	/** most often accessed fields */
 	/** chain thru all services */
-	struct list_head		      srv_list;
+	struct list_head		srv_list;
 	/** service operations table */
 	struct ptlrpc_service_ops	srv_ops;
 	/** only statically allocated strings here; we don't clean them */
-	char			   *srv_name;
+	char				*srv_name;
 	/** only statically allocated strings here; we don't clean them */
-	char			   *srv_thread_name;
+	char				*srv_thread_name;
 	/** service thread list */
-	struct list_head		      srv_threads;
+	struct list_head		srv_threads;
 	/** threads # should be created for each partition on initializing */
 	int				srv_nthrs_cpt_init;
 	/** limit of threads number for each partition */
 	int				srv_nthrs_cpt_limit;
 	/** Root of debugfs dir tree for this service */
-	struct dentry		   *srv_debugfs_entry;
+	struct dentry			*srv_debugfs_entry;
 	/** Pointer to statistic data for this service */
-	struct lprocfs_stats	   *srv_stats;
+	struct lprocfs_stats		*srv_stats;
 	/** # hp per lp reqs to handle */
-	int			     srv_hpreq_ratio;
+	int				srv_hpreq_ratio;
 	/** biggest request to receive */
-	int			     srv_max_req_size;
+	int				srv_max_req_size;
 	/** biggest reply to send */
-	int			     srv_max_reply_size;
+	int				srv_max_reply_size;
 	/** size of individual buffers */
-	int			     srv_buf_size;
+	int				srv_buf_size;
 	/** # buffers to allocate in 1 group */
-	int			     srv_nbuf_per_group;
+	int				srv_nbuf_per_group;
 	/** Local portal on which to receive requests */
-	u32			   srv_req_portal;
+	u32				srv_req_portal;
 	/** Portal on the client to send replies to */
-	u32			   srv_rep_portal;
+	u32				srv_rep_portal;
 	/**
 	 * Tags for lu_context associated with this thread, see struct
 	 * lu_context.
 	 */
-	u32			   srv_ctx_tags;
+	u32				srv_ctx_tags;
 	/** soft watchdog timeout multiplier */
-	int			     srv_watchdog_factor;
+	int				srv_watchdog_factor;
 	/** under unregister_service */
 	unsigned			srv_is_stopping:1;
 
@@ -1524,14 +1525,14 @@ struct ptlrpc_service_part {
 	/** # running threads */
 	int				scp_nthrs_running;
 	/** service threads list */
-	struct list_head			scp_threads;
+	struct list_head		scp_threads;
 
 	/**
 	 * serialize the following fields, used for protecting
 	 * rqbd list and incoming requests waiting for preprocess,
 	 * threads starting & stopping are also protected by this lock.
 	 */
-	spinlock_t scp_lock __cfs_cacheline_aligned;
+	spinlock_t			scp_lock __cfs_cacheline_aligned;
 	/** total # req buffer descs allocated */
 	int				scp_nrqbds_total;
 	/** # posted request buffers for receiving */
@@ -1541,23 +1542,23 @@ struct ptlrpc_service_part {
 	/** # incoming reqs */
 	int				scp_nreqs_incoming;
 	/** request buffers to be reposted */
-	struct list_head			scp_rqbd_idle;
+	struct list_head		scp_rqbd_idle;
 	/** req buffers receiving */
-	struct list_head			scp_rqbd_posted;
+	struct list_head		scp_rqbd_posted;
 	/** incoming reqs */
-	struct list_head			scp_req_incoming;
+	struct list_head		scp_req_incoming;
 	/** timeout before re-posting reqs, in tick */
-	long			scp_rqbd_timeout;
+	long				scp_rqbd_timeout;
 	/**
 	 * all threads sleep on this. This wait-queue is signalled when new
 	 * incoming request arrives and when difficult reply has to be handled.
 	 */
-	wait_queue_head_t			scp_waitq;
+	wait_queue_head_t		scp_waitq;
 
 	/** request history */
-	struct list_head			scp_hist_reqs;
+	struct list_head		scp_hist_reqs;
 	/** request buffer history */
-	struct list_head			scp_hist_rqbds;
+	struct list_head		scp_hist_rqbds;
 	/** # request buffers in history */
 	int				scp_hist_nrqbds;
 	/** sequence number for request */
@@ -1610,11 +1611,11 @@ struct ptlrpc_service_part {
 	 */
 	spinlock_t			scp_rep_lock __cfs_cacheline_aligned;
 	/** all the active replies */
-	struct list_head			scp_rep_active;
+	struct list_head		scp_rep_active;
 	/** List of free reply_states */
-	struct list_head			scp_rep_idle;
+	struct list_head		scp_rep_idle;
 	/** waitq to run, when adding stuff to srv_free_rs_list */
-	wait_queue_head_t			scp_rep_waitq;
+	wait_queue_head_t		scp_rep_waitq;
 	/** # 'difficult' replies */
 	atomic_t			scp_nreps_difficult;
 };
@@ -1648,11 +1649,11 @@ struct ptlrpcd_ctl {
 	/**
 	 * Thread requests set.
 	 */
-	struct ptlrpc_request_set  *pc_set;
+	struct ptlrpc_request_set	*pc_set;
 	/**
 	 * Thread name used in kthread_run()
 	 */
-	char			pc_name[16];
+	char				pc_name[16];
 	/**
 	 * CPT the thread is bound on.
 	 */
@@ -1664,7 +1665,7 @@ struct ptlrpcd_ctl {
 	/**
 	 * Pointer to the array of partners' ptlrpcd_ctl structure.
 	 */
-	struct ptlrpcd_ctl	**pc_partners;
+	struct ptlrpcd_ctl		**pc_partners;
 	/**
 	 * Number of the ptlrpcd's partners.
 	 */
@@ -1672,7 +1673,7 @@ struct ptlrpcd_ctl {
 	/**
 	 * Record the partner index to be processed next.
 	 */
-	int			 pc_cursor;
+	int				pc_cursor;
 	/**
 	 * Error code if the thread failed to fully start.
 	 */
@@ -1777,7 +1778,7 @@ struct ptlrpc_connection *ptlrpc_connection_get(struct lnet_process_id peer,
 static inline int ptlrpc_client_bulk_active(struct ptlrpc_request *req)
 {
 	struct ptlrpc_bulk_desc *desc;
-	int		      rc;
+	int rc;
 
 	desc = req->rq_bulk;
 
@@ -1793,8 +1794,9 @@ static inline int ptlrpc_client_bulk_active(struct ptlrpc_request *req)
 	return rc;
 }
 
-#define PTLRPC_REPLY_MAYBE_DIFFICULT 0x01
-#define PTLRPC_REPLY_EARLY	   0x02
+#define PTLRPC_REPLY_MAYBE_DIFFICULT	0x01
+#define PTLRPC_REPLY_EARLY		0x02
+
 int ptlrpc_send_reply(struct ptlrpc_request *req, int flags);
 int ptlrpc_reply(struct ptlrpc_request *req);
 int ptlrpc_send_error(struct ptlrpc_request *req, int difficult);
diff --git a/drivers/staging/lustre/lustre/include/lustre_nrs_fifo.h b/drivers/staging/lustre/lustre/include/lustre_nrs_fifo.h
index 0db4345f..1c47c80 100644
--- a/drivers/staging/lustre/lustre/include/lustre_nrs_fifo.h
+++ b/drivers/staging/lustre/lustre/include/lustre_nrs_fifo.h
@@ -63,8 +63,8 @@ struct nrs_fifo_head {
 };
 
 struct nrs_fifo_req {
-	struct list_head	fr_list;
-	u64			fr_sequence;
+	struct list_head		fr_list;
+	u64				fr_sequence;
 };
 
 /** @} fifo */
diff --git a/drivers/staging/lustre/lustre/include/lustre_req_layout.h b/drivers/staging/lustre/lustre/include/lustre_req_layout.h
index 2aba99f..57ac618 100644
--- a/drivers/staging/lustre/lustre/include/lustre_req_layout.h
+++ b/drivers/staging/lustre/lustre/include/lustre_req_layout.h
@@ -63,10 +63,10 @@ enum req_location {
 #define REQ_MAX_FIELD_NR 10
 
 struct req_capsule {
-	struct ptlrpc_request   *rc_req;
-	const struct req_format *rc_fmt;
-	enum req_location	rc_loc;
-	u32		    rc_area[RCL_NR][REQ_MAX_FIELD_NR];
+	struct ptlrpc_request		*rc_req;
+	const struct req_format		*rc_fmt;
+	enum req_location		 rc_loc;
+	u32				 rc_area[RCL_NR][REQ_MAX_FIELD_NR];
 };
 
 void req_capsule_init(struct req_capsule *pill, struct ptlrpc_request *req,
diff --git a/drivers/staging/lustre/lustre/include/lustre_sec.h b/drivers/staging/lustre/lustre/include/lustre_sec.h
index c622c8d..5a5625e 100644
--- a/drivers/staging/lustre/lustre/include/lustre_sec.h
+++ b/drivers/staging/lustre/lustre/include/lustre_sec.h
@@ -85,25 +85,25 @@
  * flavor constants
  */
 enum sptlrpc_policy {
-	SPTLRPC_POLICY_NULL	     = 0,
-	SPTLRPC_POLICY_PLAIN	    = 1,
-	SPTLRPC_POLICY_GSS	      = 2,
+	SPTLRPC_POLICY_NULL		= 0,
+	SPTLRPC_POLICY_PLAIN		= 1,
+	SPTLRPC_POLICY_GSS		= 2,
 	SPTLRPC_POLICY_MAX,
 };
 
 enum sptlrpc_mech_null {
-	SPTLRPC_MECH_NULL	       = 0,
+	SPTLRPC_MECH_NULL		= 0,
 	SPTLRPC_MECH_NULL_MAX,
 };
 
 enum sptlrpc_mech_plain {
-	SPTLRPC_MECH_PLAIN	      = 0,
+	SPTLRPC_MECH_PLAIN		= 0,
 	SPTLRPC_MECH_PLAIN_MAX,
 };
 
 enum sptlrpc_mech_gss {
-	SPTLRPC_MECH_GSS_NULL	   = 0,
-	SPTLRPC_MECH_GSS_KRB5	   = 1,
+	SPTLRPC_MECH_GSS_NULL		= 0,
+	SPTLRPC_MECH_GSS_KRB5		= 1,
 	SPTLRPC_MECH_GSS_MAX,
 };
 
@@ -116,113 +116,113 @@ enum sptlrpc_service_type {
 };
 
 enum sptlrpc_bulk_type {
-	SPTLRPC_BULK_DEFAULT	    = 0,    /**< follow rpc flavor */
-	SPTLRPC_BULK_HASH	       = 1,    /**< hash integrity */
+	SPTLRPC_BULK_DEFAULT		= 0,	/**< follow rpc flavor */
+	SPTLRPC_BULK_HASH		= 1,	/**< hash integrity */
 	SPTLRPC_BULK_MAX,
 };
 
 enum sptlrpc_bulk_service {
-	SPTLRPC_BULK_SVC_NULL	   = 0,    /**< no security */
-	SPTLRPC_BULK_SVC_AUTH	   = 1,    /**< authentication only */
-	SPTLRPC_BULK_SVC_INTG	   = 2,    /**< integrity */
-	SPTLRPC_BULK_SVC_PRIV	   = 3,    /**< privacy */
+	SPTLRPC_BULK_SVC_NULL		= 0,	/**< no security */
+	SPTLRPC_BULK_SVC_AUTH		= 1,	/**< authentication only */
+	SPTLRPC_BULK_SVC_INTG		= 2,	/**< integrity */
+	SPTLRPC_BULK_SVC_PRIV		= 3,	/**< privacy */
 	SPTLRPC_BULK_SVC_MAX,
 };
 
 /*
  * compose/extract macros
  */
-#define FLVR_POLICY_OFFSET	      (0)
+#define FLVR_POLICY_OFFSET		(0)
 #define FLVR_MECH_OFFSET		(4)
-#define FLVR_SVC_OFFSET		 (8)
-#define FLVR_BULK_TYPE_OFFSET	   (12)
-#define FLVR_BULK_SVC_OFFSET	    (16)
-
-#define MAKE_FLVR(policy, mech, svc, btype, bsvc)		       \
-	(((u32)(policy) << FLVR_POLICY_OFFSET) |		      \
-	 ((u32)(mech) << FLVR_MECH_OFFSET) |			  \
-	 ((u32)(svc) << FLVR_SVC_OFFSET) |			    \
-	 ((u32)(btype) << FLVR_BULK_TYPE_OFFSET) |		    \
+#define FLVR_SVC_OFFSET			(8)
+#define FLVR_BULK_TYPE_OFFSET		(12)
+#define FLVR_BULK_SVC_OFFSET		(16)
+
+#define MAKE_FLVR(policy, mech, svc, btype, bsvc)	\
+	(((u32)(policy) << FLVR_POLICY_OFFSET) |	\
+	 ((u32)(mech) << FLVR_MECH_OFFSET) |		\
+	 ((u32)(svc) << FLVR_SVC_OFFSET) |		\
+	 ((u32)(btype) << FLVR_BULK_TYPE_OFFSET) |	\
 	 ((u32)(bsvc) << FLVR_BULK_SVC_OFFSET))
 
 /*
  * extraction
  */
-#define SPTLRPC_FLVR_POLICY(flavor)				     \
+#define SPTLRPC_FLVR_POLICY(flavor)			\
 	((((u32)(flavor)) >> FLVR_POLICY_OFFSET) & 0xF)
-#define SPTLRPC_FLVR_MECH(flavor)				       \
+#define SPTLRPC_FLVR_MECH(flavor)			\
 	((((u32)(flavor)) >> FLVR_MECH_OFFSET) & 0xF)
-#define SPTLRPC_FLVR_SVC(flavor)					\
+#define SPTLRPC_FLVR_SVC(flavor)			\
 	((((u32)(flavor)) >> FLVR_SVC_OFFSET) & 0xF)
-#define SPTLRPC_FLVR_BULK_TYPE(flavor)				  \
+#define SPTLRPC_FLVR_BULK_TYPE(flavor)			\
 	((((u32)(flavor)) >> FLVR_BULK_TYPE_OFFSET) & 0xF)
-#define SPTLRPC_FLVR_BULK_SVC(flavor)				   \
+#define SPTLRPC_FLVR_BULK_SVC(flavor)			\
 	((((u32)(flavor)) >> FLVR_BULK_SVC_OFFSET) & 0xF)
 
-#define SPTLRPC_FLVR_BASE(flavor)				       \
+#define SPTLRPC_FLVR_BASE(flavor)			\
 	((((u32)(flavor)) >> FLVR_POLICY_OFFSET) & 0xFFF)
-#define SPTLRPC_FLVR_BASE_SUB(flavor)				   \
+#define SPTLRPC_FLVR_BASE_SUB(flavor)			\
 	((((u32)(flavor)) >> FLVR_MECH_OFFSET) & 0xFF)
 
 /*
  * gss subflavors
  */
-#define MAKE_BASE_SUBFLVR(mech, svc)				    \
-	((u32)(mech) |						\
+#define MAKE_BASE_SUBFLVR(mech, svc)			\
+	((u32)(mech) |					\
 	 ((u32)(svc) << (FLVR_SVC_OFFSET - FLVR_MECH_OFFSET)))
 
-#define SPTLRPC_SUBFLVR_KRB5N					   \
+#define SPTLRPC_SUBFLVR_KRB5N				\
 	MAKE_BASE_SUBFLVR(SPTLRPC_MECH_GSS_KRB5, SPTLRPC_SVC_NULL)
-#define SPTLRPC_SUBFLVR_KRB5A					   \
+#define SPTLRPC_SUBFLVR_KRB5A				\
 	MAKE_BASE_SUBFLVR(SPTLRPC_MECH_GSS_KRB5, SPTLRPC_SVC_AUTH)
-#define SPTLRPC_SUBFLVR_KRB5I					   \
+#define SPTLRPC_SUBFLVR_KRB5I				\
 	MAKE_BASE_SUBFLVR(SPTLRPC_MECH_GSS_KRB5, SPTLRPC_SVC_INTG)
-#define SPTLRPC_SUBFLVR_KRB5P					   \
+#define SPTLRPC_SUBFLVR_KRB5P				\
 	MAKE_BASE_SUBFLVR(SPTLRPC_MECH_GSS_KRB5, SPTLRPC_SVC_PRIV)
 
 /*
  * "end user" flavors
  */
-#define SPTLRPC_FLVR_NULL			       \
-	MAKE_FLVR(SPTLRPC_POLICY_NULL,		  \
-		  SPTLRPC_MECH_NULL,		    \
-		  SPTLRPC_SVC_NULL,		     \
-		  SPTLRPC_BULK_DEFAULT,		 \
+#define SPTLRPC_FLVR_NULL				\
+	MAKE_FLVR(SPTLRPC_POLICY_NULL,			\
+		  SPTLRPC_MECH_NULL,			\
+		  SPTLRPC_SVC_NULL,			\
+		  SPTLRPC_BULK_DEFAULT,			\
 		  SPTLRPC_BULK_SVC_NULL)
-#define SPTLRPC_FLVR_PLAIN			      \
-	MAKE_FLVR(SPTLRPC_POLICY_PLAIN,		 \
-		  SPTLRPC_MECH_PLAIN,		   \
-		  SPTLRPC_SVC_NULL,		     \
-		  SPTLRPC_BULK_HASH,		    \
+#define SPTLRPC_FLVR_PLAIN				\
+	MAKE_FLVR(SPTLRPC_POLICY_PLAIN,			\
+		  SPTLRPC_MECH_PLAIN,			\
+		  SPTLRPC_SVC_NULL,			\
+		  SPTLRPC_BULK_HASH,			\
 		  SPTLRPC_BULK_SVC_INTG)
-#define SPTLRPC_FLVR_KRB5N			      \
-	MAKE_FLVR(SPTLRPC_POLICY_GSS,		   \
+#define SPTLRPC_FLVR_KRB5N				\
+	MAKE_FLVR(SPTLRPC_POLICY_GSS,			\
 		  SPTLRPC_MECH_GSS_KRB5,		\
-		  SPTLRPC_SVC_NULL,		     \
-		  SPTLRPC_BULK_DEFAULT,		 \
+		  SPTLRPC_SVC_NULL,			\
+		  SPTLRPC_BULK_DEFAULT,			\
 		  SPTLRPC_BULK_SVC_NULL)
-#define SPTLRPC_FLVR_KRB5A			      \
-	MAKE_FLVR(SPTLRPC_POLICY_GSS,		   \
+#define SPTLRPC_FLVR_KRB5A				\
+	MAKE_FLVR(SPTLRPC_POLICY_GSS,			\
 		  SPTLRPC_MECH_GSS_KRB5,		\
-		  SPTLRPC_SVC_AUTH,		     \
-		  SPTLRPC_BULK_DEFAULT,		 \
+		  SPTLRPC_SVC_AUTH,			\
+		  SPTLRPC_BULK_DEFAULT,			\
 		  SPTLRPC_BULK_SVC_NULL)
-#define SPTLRPC_FLVR_KRB5I			      \
-	MAKE_FLVR(SPTLRPC_POLICY_GSS,		   \
+#define SPTLRPC_FLVR_KRB5I				\
+	MAKE_FLVR(SPTLRPC_POLICY_GSS,			\
 		  SPTLRPC_MECH_GSS_KRB5,		\
-		  SPTLRPC_SVC_INTG,		     \
-		  SPTLRPC_BULK_DEFAULT,		 \
+		  SPTLRPC_SVC_INTG,			\
+		  SPTLRPC_BULK_DEFAULT,			\
 		  SPTLRPC_BULK_SVC_INTG)
-#define SPTLRPC_FLVR_KRB5P			      \
-	MAKE_FLVR(SPTLRPC_POLICY_GSS,		   \
+#define SPTLRPC_FLVR_KRB5P				\
+	MAKE_FLVR(SPTLRPC_POLICY_GSS,			\
 		  SPTLRPC_MECH_GSS_KRB5,		\
-		  SPTLRPC_SVC_PRIV,		     \
-		  SPTLRPC_BULK_DEFAULT,		 \
+		  SPTLRPC_SVC_PRIV,			\
+		  SPTLRPC_BULK_DEFAULT,			\
 		  SPTLRPC_BULK_SVC_PRIV)
 
-#define SPTLRPC_FLVR_DEFAULT	    SPTLRPC_FLVR_NULL
+#define SPTLRPC_FLVR_DEFAULT		SPTLRPC_FLVR_NULL
 
-#define SPTLRPC_FLVR_INVALID	    ((u32)0xFFFFFFFF)
+#define SPTLRPC_FLVR_INVALID		((u32)0xFFFFFFFF)
 #define SPTLRPC_FLVR_ANY		((u32)0xFFF00000)
 
 /**
@@ -253,7 +253,7 @@ static inline void flvr_set_bulk_svc(u32 *flvr, u32 svc)
 }
 
 struct bulk_spec_hash {
-	u8    hash_alg;
+	u8	hash_alg;
 };
 
 /**
@@ -264,11 +264,11 @@ struct sptlrpc_flavor {
 	/**
 	 * wire flavor, should be renamed to sf_wire.
 	 */
-	u32   sf_rpc;
+	u32	sf_rpc;
 	/**
 	 * general flags of PTLRPC_SEC_FL_*
 	 */
-	u32   sf_flags;
+	u32	sf_flags;
 	/**
 	 * rpc flavor specification
 	 */
@@ -288,12 +288,12 @@ struct sptlrpc_flavor {
  * RPC requests and to be checked by ptlrpc service.
  */
 enum lustre_sec_part {
-	LUSTRE_SP_CLI	   = 0,
+	LUSTRE_SP_CLI	= 0,
 	LUSTRE_SP_MDT,
 	LUSTRE_SP_OST,
 	LUSTRE_SP_MGC,
 	LUSTRE_SP_MGS,
-	LUSTRE_SP_ANY	   = 0xFF
+	LUSTRE_SP_ANY	= 0xFF
 };
 
 enum lustre_sec_part sptlrpc_target_sec_part(struct obd_device *obd);
@@ -303,11 +303,11 @@ enum lustre_sec_part {
  * two Lustre parts.
  */
 struct sptlrpc_rule {
-	u32		   sr_netid;   /* LNET network ID */
-	u8		    sr_from;    /* sec_part */
-	u8		    sr_to;      /* sec_part */
-	u16		   sr_padding;
-	struct sptlrpc_flavor   sr_flvr;
+	u32			sr_netid;	/* LNET network ID */
+	u8			sr_from;	/* sec_part */
+	u8			sr_to;		/* sec_part */
+	u16			sr_padding;
+	struct sptlrpc_flavor	sr_flvr;
 };
 
 /**
@@ -317,8 +317,8 @@ struct sptlrpc_rule {
  * and client when needed.
  */
 struct sptlrpc_rule_set {
-	int		     srs_nslot;
-	int		     srs_nrule;
+	int			srs_nslot;
+	int			srs_nrule;
 	struct sptlrpc_rule    *srs_rules;
 };
 
@@ -460,37 +460,37 @@ struct ptlrpc_ctx_ops {
 			   struct ptlrpc_bulk_desc *desc);
 };
 
-#define PTLRPC_CTX_NEW_BIT	     (0)  /* newly created */
-#define PTLRPC_CTX_UPTODATE_BIT	(1)  /* uptodate */
-#define PTLRPC_CTX_DEAD_BIT	    (2)  /* mark expired gracefully */
-#define PTLRPC_CTX_ERROR_BIT	   (3)  /* fatal error (refresh, etc.) */
-#define PTLRPC_CTX_CACHED_BIT	  (8)  /* in ctx cache (hash etc.) */
-#define PTLRPC_CTX_ETERNAL_BIT	 (9)  /* always valid */
-
-#define PTLRPC_CTX_NEW		 (1 << PTLRPC_CTX_NEW_BIT)
-#define PTLRPC_CTX_UPTODATE	    (1 << PTLRPC_CTX_UPTODATE_BIT)
-#define PTLRPC_CTX_DEAD		(1 << PTLRPC_CTX_DEAD_BIT)
-#define PTLRPC_CTX_ERROR	       (1 << PTLRPC_CTX_ERROR_BIT)
-#define PTLRPC_CTX_CACHED	      (1 << PTLRPC_CTX_CACHED_BIT)
-#define PTLRPC_CTX_ETERNAL	     (1 << PTLRPC_CTX_ETERNAL_BIT)
-
-#define PTLRPC_CTX_STATUS_MASK	 (PTLRPC_CTX_NEW_BIT    |       \
-					PTLRPC_CTX_UPTODATE   |       \
-					PTLRPC_CTX_DEAD       |       \
+#define PTLRPC_CTX_NEW_BIT		(0)  /* newly created */
+#define PTLRPC_CTX_UPTODATE_BIT		(1)  /* uptodate */
+#define PTLRPC_CTX_DEAD_BIT		(2)  /* mark expired gracefully */
+#define PTLRPC_CTX_ERROR_BIT		(3)  /* fatal error (refresh, etc.) */
+#define PTLRPC_CTX_CACHED_BIT		(8)  /* in ctx cache (hash etc.) */
+#define PTLRPC_CTX_ETERNAL_BIT		(9)  /* always valid */
+
+#define PTLRPC_CTX_NEW			(1 << PTLRPC_CTX_NEW_BIT)
+#define PTLRPC_CTX_UPTODATE		(1 << PTLRPC_CTX_UPTODATE_BIT)
+#define PTLRPC_CTX_DEAD			(1 << PTLRPC_CTX_DEAD_BIT)
+#define PTLRPC_CTX_ERROR		(1 << PTLRPC_CTX_ERROR_BIT)
+#define PTLRPC_CTX_CACHED		(1 << PTLRPC_CTX_CACHED_BIT)
+#define PTLRPC_CTX_ETERNAL		(1 << PTLRPC_CTX_ETERNAL_BIT)
+
+#define PTLRPC_CTX_STATUS_MASK	       (PTLRPC_CTX_NEW_BIT	| \
+					PTLRPC_CTX_UPTODATE	| \
+					PTLRPC_CTX_DEAD		| \
 					PTLRPC_CTX_ERROR)
 
 struct ptlrpc_cli_ctx {
-	struct hlist_node	cc_cache;      /* linked into ctx cache */
-	atomic_t	    cc_refcount;
+	struct hlist_node	cc_cache;	/* linked into ctx cache */
+	atomic_t		cc_refcount;
 	struct ptlrpc_sec      *cc_sec;
 	struct ptlrpc_ctx_ops  *cc_ops;
-	unsigned long	      cc_expire;     /* in seconds */
-	unsigned int	    cc_early_expire:1;
-	unsigned long	   cc_flags;
-	struct vfs_cred	 cc_vcred;
+	unsigned long		cc_expire;	/* in seconds */
+	unsigned int		cc_early_expire:1;
+	unsigned long		cc_flags;
+	struct vfs_cred		cc_vcred;
 	spinlock_t		cc_lock;
-	struct list_head	      cc_req_list;   /* waiting reqs linked here */
-	struct list_head	      cc_gc_chain;   /* linked to gc chain */
+	struct list_head	cc_req_list;	/* waiting reqs linked here */
+	struct list_head	cc_gc_chain;	/* linked to gc chain */
 };
 
 /**
@@ -755,18 +755,18 @@ struct ptlrpc_sec_sops {
 };
 
 struct ptlrpc_sec_policy {
-	struct module		   *sp_owner;
-	char			   *sp_name;
-	u16			   sp_policy; /* policy number */
-	struct ptlrpc_sec_cops	 *sp_cops;   /* client ops */
-	struct ptlrpc_sec_sops	 *sp_sops;   /* server ops */
+	struct module			*sp_owner;
+	char				*sp_name;
+	u16				 sp_policy; /* policy number */
+	struct ptlrpc_sec_cops		*sp_cops;   /* client ops */
+	struct ptlrpc_sec_sops		*sp_sops;   /* server ops */
 };
 
-#define PTLRPC_SEC_FL_REVERSE	   0x0001 /* reverse sec */
-#define PTLRPC_SEC_FL_ROOTONLY	  0x0002 /* treat everyone as root */
-#define PTLRPC_SEC_FL_UDESC	     0x0004 /* ship udesc */
-#define PTLRPC_SEC_FL_BULK	      0x0008 /* intensive bulk i/o expected */
-#define PTLRPC_SEC_FL_PAG	       0x0010 /* PAG mode */
+#define PTLRPC_SEC_FL_REVERSE		0x0001 /* reverse sec */
+#define PTLRPC_SEC_FL_ROOTONLY		0x0002 /* treat everyone as root */
+#define PTLRPC_SEC_FL_UDESC		0x0004 /* ship udesc */
+#define PTLRPC_SEC_FL_BULK		0x0008 /* intensive bulk i/o expected */
+#define PTLRPC_SEC_FL_PAG		0x0010 /* PAG mode */
 
 /**
  * The ptlrpc_sec represents the client side ptlrpc security facilities,
@@ -777,25 +777,25 @@ struct ptlrpc_sec_policy {
  */
 struct ptlrpc_sec {
 	struct ptlrpc_sec_policy       *ps_policy;
-	atomic_t		    ps_refcount;
+	atomic_t			ps_refcount;
 	/** statistic only */
-	atomic_t		    ps_nctx;
+	atomic_t			ps_nctx;
 	/** unique identifier */
-	int			     ps_id;
-	struct sptlrpc_flavor	   ps_flvr;
-	enum lustre_sec_part	    ps_part;
+	int				ps_id;
+	struct sptlrpc_flavor		ps_flvr;
+	enum lustre_sec_part		ps_part;
 	/** after set, no more new context will be created */
-	unsigned int		    ps_dying:1;
+	unsigned int			ps_dying:1;
 	/** owning import */
-	struct obd_import	      *ps_import;
+	struct obd_import	       *ps_import;
 	spinlock_t			ps_lock;
 
 	/*
 	 * garbage collection
 	 */
-	struct list_head		      ps_gc_list;
-	unsigned long		      ps_gc_interval; /* in seconds */
-	time64_t		      ps_gc_next;     /* in seconds */
+	struct list_head		ps_gc_list;
+	unsigned long			ps_gc_interval; /* in seconds */
+	time64_t			ps_gc_next;     /* in seconds */
 };
 
 static inline int sec_is_reverse(struct ptlrpc_sec *sec)
@@ -809,30 +809,30 @@ static inline int sec_is_rootonly(struct ptlrpc_sec *sec)
 }
 
 struct ptlrpc_svc_ctx {
-	atomic_t		    sc_refcount;
+	atomic_t			sc_refcount;
 	struct ptlrpc_sec_policy       *sc_policy;
 };
 
 /*
  * user identity descriptor
  */
-#define LUSTRE_MAX_GROUPS	       (128)
+#define LUSTRE_MAX_GROUPS		(128)
 
 struct ptlrpc_user_desc {
-	u32	   pud_uid;
-	u32	   pud_gid;
-	u32	   pud_fsuid;
-	u32	   pud_fsgid;
-	u32	   pud_cap;
-	u32	   pud_ngroups;
-	u32	   pud_groups[0];
+	u32	pud_uid;
+	u32	pud_gid;
+	u32	pud_fsuid;
+	u32	pud_fsgid;
+	u32	pud_cap;
+	u32	pud_ngroups;
+	u32	pud_groups[0];
 };
 
 /*
  * bulk flavors
  */
 enum sptlrpc_bulk_hash_alg {
-	BULK_HASH_ALG_NULL      = 0,
+	BULK_HASH_ALG_NULL	= 0,
 	BULK_HASH_ALG_ADLER32,
 	BULK_HASH_ALG_CRC32,
 	BULK_HASH_ALG_MD5,
@@ -847,16 +847,16 @@ enum sptlrpc_bulk_hash_alg {
 u8 sptlrpc_get_hash_alg(const char *algname);
 
 enum {
-	BSD_FL_ERR      = 1,
+	BSD_FL_ERR	= 1,
 };
 
 struct ptlrpc_bulk_sec_desc {
-	u8	    bsd_version;    /* 0 */
-	u8	    bsd_type;       /* SPTLRPC_BULK_XXX */
-	u8	    bsd_svc;	/* SPTLRPC_BULK_SVC_XXXX */
-	u8	    bsd_flags;      /* flags */
-	u32	   bsd_nob;	/* nob of bulk data */
-	u8	    bsd_data[0];    /* policy-specific token */
+	u8	bsd_version;	/* 0 */
+	u8	bsd_type;	/* SPTLRPC_BULK_XXX */
+	u8	bsd_svc;	/* SPTLRPC_BULK_SVC_XXXX */
+	u8	bsd_flags;	/* flags */
+	u32	bsd_nob;	/* nob of bulk data */
+	u8	bsd_data[0];	/* policy-specific token */
 };
 
 /*
@@ -979,8 +979,8 @@ int cli_ctx_is_eternal(struct ptlrpc_cli_ctx *ctx)
 int sptlrpc_cli_enlarge_reqbuf(struct ptlrpc_request *req,
 			       const struct req_msg_field *field,
 			       int newsize);
-int  sptlrpc_cli_unwrap_early_reply(struct ptlrpc_request *req,
-				    struct ptlrpc_request **req_ret);
+int sptlrpc_cli_unwrap_early_reply(struct ptlrpc_request *req,
+				   struct ptlrpc_request **req_ret);
 void sptlrpc_cli_finish_early_reply(struct ptlrpc_request *early_req);
 
 void sptlrpc_request_out_callback(struct ptlrpc_request *req);
@@ -994,13 +994,13 @@ int sptlrpc_import_sec_adapt(struct obd_import *imp,
 struct ptlrpc_sec *sptlrpc_import_sec_ref(struct obd_import *imp);
 void sptlrpc_import_sec_put(struct obd_import *imp);
 
-int  sptlrpc_import_check_ctx(struct obd_import *imp);
+int sptlrpc_import_check_ctx(struct obd_import *imp);
 void sptlrpc_import_flush_root_ctx(struct obd_import *imp);
 void sptlrpc_import_flush_my_ctx(struct obd_import *imp);
 void sptlrpc_import_flush_all_ctx(struct obd_import *imp);
-int  sptlrpc_req_get_ctx(struct ptlrpc_request *req);
+int sptlrpc_req_get_ctx(struct ptlrpc_request *req);
 void sptlrpc_req_put_ctx(struct ptlrpc_request *req, int sync);
-int  sptlrpc_req_refresh_ctx(struct ptlrpc_request *req, long timeout);
+int sptlrpc_req_refresh_ctx(struct ptlrpc_request *req, long timeout);
 void sptlrpc_req_set_flavor(struct ptlrpc_request *req, int opcode);
 
 /* gc */
@@ -1023,15 +1023,15 @@ enum secsvc_accept_res {
 	SECSVC_DROP,
 };
 
-int  sptlrpc_svc_unwrap_request(struct ptlrpc_request *req);
-int  sptlrpc_svc_alloc_rs(struct ptlrpc_request *req, int msglen);
-int  sptlrpc_svc_wrap_reply(struct ptlrpc_request *req);
+int sptlrpc_svc_unwrap_request(struct ptlrpc_request *req);
+int sptlrpc_svc_alloc_rs(struct ptlrpc_request *req, int msglen);
+int sptlrpc_svc_wrap_reply(struct ptlrpc_request *req);
 void sptlrpc_svc_free_rs(struct ptlrpc_reply_state *rs);
 void sptlrpc_svc_ctx_addref(struct ptlrpc_request *req);
 void sptlrpc_svc_ctx_decref(struct ptlrpc_request *req);
 
-int  sptlrpc_target_export_check(struct obd_export *exp,
-				 struct ptlrpc_request *req);
+int sptlrpc_target_export_check(struct obd_export *exp,
+				struct ptlrpc_request *req);
 
 /* bulk security api */
 void sptlrpc_enc_pool_put_pages(struct ptlrpc_bulk_desc *desc);
@@ -1063,10 +1063,10 @@ static inline int sptlrpc_user_desc_size(int ngroups)
 int sptlrpc_unpack_user_desc(struct lustre_msg *req, int offset, int swabbed);
 
 enum {
-	LUSTRE_SEC_NONE	 = 0,
+	LUSTRE_SEC_NONE		= 0,
 	LUSTRE_SEC_REMOTE       = 1,
 	LUSTRE_SEC_SPECIFY      = 2,
-	LUSTRE_SEC_ALL	  = 3
+	LUSTRE_SEC_ALL		= 3
 };
 
 /** @} sptlrpc */
-- 
1.8.3.1
