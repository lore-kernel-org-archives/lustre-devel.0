From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Dec 2018 02:15:12 +0000 (GMT)
Subject: [lustre-devel] [PATCH 4/4] lustre: clear up white space in osc
 header files.
In-Reply-To: <154440277682.29887.12055691371699460100.stgit@noble>
References: <154440246926.29887.1667505755325904791.stgit@noble>
 <154440277682.29887.12055691371699460100.stgit@noble>
Message-ID: <alpine.LFD.2.21.1812270215040.5850@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> Also change /** to /*.  In the kernel, /** should only be
> used for kernel-doc comments.

Reviewed-by: James Simmons <jsimmons@infradead.org>
 
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
>  .../staging/lustre/lustre/osc/osc_cl_internal.h    |  319 ++++++++++----------
>  drivers/staging/lustre/lustre/osc/osc_internal.h   |   96 +++---
>  2 files changed, 209 insertions(+), 206 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lustre/osc/osc_cl_internal.h b/drivers/staging/lustre/lustre/osc/osc_cl_internal.h
> index 4b0180946134..077a2b183634 100644
> --- a/drivers/staging/lustre/lustre/osc/osc_cl_internal.h
> +++ b/drivers/staging/lustre/lustre/osc/osc_cl_internal.h
> @@ -48,62 +48,63 @@
>  #include <cl_object.h>
>  #include "osc_internal.h"
>  
> -/** \defgroup osc osc
> +/* \defgroup osc osc
>   *  @{
>   */
>  
>  struct osc_extent;
>  
> -/**
> +/*
>   * State maintained by osc layer for each IO context.
>   */
>  struct osc_io {
> -	/** super class */
> -	struct cl_io_slice oi_cl;
> -	/** true if this io is lockless. */
> +	/* super class */
> +	struct cl_io_slice	oi_cl;
> +	/* true if this io is lockless. */
>  	unsigned int		oi_lockless:1,
> -	/** true if this io is counted as active IO */
> +	/* true if this io is counted as active IO */
>  				oi_is_active:1;
> -	/** how many LRU pages are reserved for this IO */
> +	/* how many LRU pages are reserved for this IO */
>  	unsigned long		oi_lru_reserved;
>  
> -	/** active extents, we know how many bytes is going to be written,
> -	 * so having an active extent will prevent it from being fragmented
> +	/* active extents, we know how many bytes is going to be
> +	 * written, so having an active extent will prevent it from
> +	 * being fragmented
>  	 */
> -	struct osc_extent *oi_active;
> -	/** partially truncated extent, we need to hold this extent to prevent
> -	 * page writeback from happening.
> +	struct osc_extent	*oi_active;
> +	/* partially truncated extent, we need to hold this extent to
> +	 * prevent page writeback from happening.
>  	 */
> -	struct osc_extent *oi_trunc;
> +	struct osc_extent	*oi_trunc;
>  
> -	/** write osc_lock for this IO, used by osc_extent_find(). */
> -	struct osc_lock   *oi_write_osclock;
> -	struct obdo	oi_oa;
> +	/* write osc_lock for this IO, used by osc_extent_find(). */
> +	struct osc_lock		*oi_write_osclock;
> +	struct obdo		oi_oa;
>  	struct osc_async_cbargs {
> -		bool		  opc_rpc_sent;
> -		int	       opc_rc;
> +		bool			opc_rpc_sent;
> +		int			opc_rc;
>  		struct completion	opc_sync;
> -	} oi_cbarg;
> +	}			oi_cbarg;
>  };
>  
> -/**
> +/*
>   * State maintained by osc layer for the duration of a system call.
>   */
>  struct osc_session {
> -	struct osc_io       os_io;
> +	struct osc_io		os_io;
>  };
>  
>  #define OTI_PVEC_SIZE 256
>  struct osc_thread_info {
> -	struct ldlm_res_id      oti_resname;
> +	struct ldlm_res_id	oti_resname;
>  	union ldlm_policy_data	oti_policy;
> -	struct cl_lock_descr    oti_descr;
> -	struct cl_attr	  oti_attr;
> -	struct lustre_handle    oti_handle;
> -	struct cl_page_list     oti_plist;
> +	struct cl_lock_descr	oti_descr;
> +	struct cl_attr		oti_attr;
> +	struct lustre_handle	oti_handle;
> +	struct cl_page_list	oti_plist;
>  	struct cl_io		oti_io;
>  	void			*oti_pvec[OTI_PVEC_SIZE];
> -	/**
> +	/*
>  	 * Fields used by cl_lock_discard_pages().
>  	 */
>  	pgoff_t			oti_next_index;
> @@ -114,44 +115,44 @@ struct osc_thread_info {
>  };
>  
>  struct osc_object {
> -	struct cl_object   oo_cl;
> -	struct lov_oinfo  *oo_oinfo;
> -	/**
> +	struct cl_object	oo_cl;
> +	struct lov_oinfo	*oo_oinfo;
> +	/*
>  	 * True if locking against this stripe got -EUSERS.
>  	 */
> -	int		oo_contended;
> -	unsigned long	 oo_contention_time;
> -	/**
> +	int			oo_contended;
> +	unsigned long		oo_contention_time;
> +	/*
>  	 * used by the osc to keep track of what objects to build into rpcs.
>  	 * Protected by client_obd->cli_loi_list_lock.
>  	 */
> -	struct list_head	   oo_ready_item;
> -	struct list_head	   oo_hp_ready_item;
> -	struct list_head	   oo_write_item;
> -	struct list_head	   oo_read_item;
> +	struct list_head	oo_ready_item;
> +	struct list_head	oo_hp_ready_item;
> +	struct list_head	oo_write_item;
> +	struct list_head	oo_read_item;
>  
> -	/**
> +	/*
>  	 * extent is a red black tree to manage (async) dirty pages.
>  	 */
> -	struct rb_root       oo_root;
> -	/**
> +	struct rb_root		oo_root;
> +	/*
>  	 * Manage write(dirty) extents.
>  	 */
> -	struct list_head	   oo_hp_exts; /* list of hp extents */
> -	struct list_head	   oo_urgent_exts; /* list of writeback extents */
> -	struct list_head	   oo_full_exts;
> +	struct list_head	oo_hp_exts; /* list of hp extents */
> +	struct list_head	oo_urgent_exts; /* list of writeback extents */
> +	struct list_head	oo_full_exts;
>  
> -	struct list_head	   oo_reading_exts;
> +	struct list_head	oo_reading_exts;
>  
> -	atomic_t	 oo_nr_reads;
> -	atomic_t	 oo_nr_writes;
> +	atomic_t		oo_nr_reads;
> +	atomic_t		oo_nr_writes;
>  
> -	/** Protect extent tree. Will be used to protect
> +	/* Protect extent tree. Will be used to protect
>  	 * oo_{read|write}_pages soon.
>  	 */
> -	spinlock_t	    oo_lock;
> +	spinlock_t		oo_lock;
>  
> -	/**
> +	/*
>  	 * Radix tree for caching pages
>  	 */
>  	struct radix_tree_root	oo_tree;
> @@ -162,7 +163,7 @@ struct osc_object {
>  	spinlock_t		oo_ol_spin;
>  	struct list_head	oo_ol_list;
>  
> -	/** number of active IOs of this object */
> +	/* number of active IOs of this object */
>  	atomic_t		oo_nr_ios;
>  	wait_queue_head_t	oo_io_waitq;
>  };
> @@ -207,7 +208,7 @@ enum osc_lock_state {
>  	OLS_CANCELLED
>  };
>  
> -/**
> +/*
>   * osc-private state of cl_lock.
>   *
>   * Interaction with DLM.
> @@ -250,37 +251,37 @@ enum osc_lock_state {
>   * future.
>   */
>  struct osc_lock {
> -	struct cl_lock_slice     ols_cl;
> -	/** Internal lock to protect states, etc. */
> -	spinlock_t		ols_lock;
> -	/** Owner sleeps on this channel for state change */
> -	struct cl_sync_io	*ols_owner;
> -	/** waiting list for this lock to be cancelled */
> -	struct list_head	ols_waiting_list;
> -	/** wait entry of ols_waiting_list */
> -	struct list_head	ols_wait_entry;
> -	/** list entry for osc_object::oo_ol_list */
> -	struct list_head	ols_nextlock_oscobj;
> -
> -	/** underlying DLM lock */
> -	struct ldlm_lock	*ols_dlmlock;
> -	/** DLM flags with which osc_lock::ols_lock was enqueued */
> -	__u64		    ols_flags;
> -	/** osc_lock::ols_lock handle */
> -	struct lustre_handle     ols_handle;
> -	struct ldlm_enqueue_info ols_einfo;
> -	enum osc_lock_state      ols_state;
> -	/** lock value block */
> -	struct ost_lvb		ols_lvb;
> -
> -	/**
> +	struct cl_lock_slice		ols_cl;
> +	/* Internal lock to protect states, etc. */
> +	spinlock_t			ols_lock;
> +	/* Owner sleeps on this channel for state change */
> +	struct cl_sync_io		*ols_owner;
> +	/* waiting list for this lock to be cancelled */
> +	struct list_head		ols_waiting_list;
> +	/* wait entry of ols_waiting_list */
> +	struct list_head		ols_wait_entry;
> +	/* list entry for osc_object::oo_ol_list */
> +	struct list_head		ols_nextlock_oscobj;
> +
> +	/* underlying DLM lock */
> +	struct ldlm_lock		*ols_dlmlock;
> +	/* DLM flags with which osc_lock::ols_lock was enqueued */
> +	__u64				ols_flags;
> +	/* osc_lock::ols_lock handle */
> +	struct lustre_handle		ols_handle;
> +	struct ldlm_enqueue_info	ols_einfo;
> +	enum osc_lock_state		ols_state;
> +	/* lock value block */
> +	struct ost_lvb			ols_lvb;
> +
> +	/*
>  	 * true, if ldlm_lock_addref() was called against
>  	 * osc_lock::ols_lock. This is used for sanity checking.
>  	 *
>  	 * \see osc_lock::ols_has_ref
>  	 */
> -	unsigned		  ols_hold :1,
> -	/**
> +	unsigned			ols_hold :1,
> +	/*
>  	 * this is much like osc_lock::ols_hold, except that this bit is
>  	 * cleared _after_ reference in released in osc_lock_unuse(). This
>  	 * fine distinction is needed because:
> @@ -295,13 +296,13 @@ struct osc_lock {
>  	 *       release lock reference (so that a flag is needed that is
>  	 *       cleared before ldlm_lock_decref() is called).
>  	 */
> -				 ols_has_ref:1,
> -	/**
> +					ols_has_ref:1,
> +	/*
>  	 * inherit the lockless attribute from top level cl_io.
>  	 * If true, osc_lock_enqueue is able to tolerate the -EUSERS error.
>  	 */
> -				 ols_locklessable:1,
> -	/**
> +					ols_locklessable:1,
> +	/*
>  	 * if set, the osc_lock is a glimpse lock. For glimpse locks, we treat
>  	 * the EVAVAIL error as tolerable, this will make upper logic happy
>  	 * to wait all glimpse locks to each OSTs to be completed.
> @@ -309,53 +310,53 @@ struct osc_lock {
>  	 * granted.
>  	 * Glimpse lock should be destroyed immediately after use.
>  	 */
> -				 ols_glimpse:1,
> -	/**
> +					ols_glimpse:1,
> +	/*
>  	 * For async glimpse lock.
>  	 */
> -				 ols_agl:1;
> +					ols_agl:1;
>  };
>  
> -/**
> +/*
>   * Page state private for osc layer.
>   */
>  struct osc_page {
> -	struct cl_page_slice  ops_cl;
> -	/**
> +	struct cl_page_slice	ops_cl;
> +	/*
>  	 * Page queues used by osc to detect when RPC can be formed.
>  	 */
> -	struct osc_async_page ops_oap;
> -	/**
> +	struct osc_async_page	ops_oap;
> +	/*
>  	 * An offset within page from which next transfer starts. This is used
>  	 * by cl_page_clip() to submit partial page transfers.
>  	 */
> -	int		   ops_from;
> -	/**
> +	int			ops_from;
> +	/*
>  	 * An offset within page at which next transfer ends.
>  	 *
>  	 * \see osc_page::ops_from.
>  	 */
> -	int		   ops_to;
> -	/**
> +	int			ops_to;
> +	/*
>  	 * Boolean, true iff page is under transfer. Used for sanity checking.
>  	 */
> -	unsigned	      ops_transfer_pinned:1,
> -	/**
> +	unsigned		ops_transfer_pinned:1,
> +	/*
>  	 * in LRU?
>  	 */
> -			      ops_in_lru:1,
> -	/**
> +				ops_in_lru:1,
> +	/*
>  	 * Set if the page must be transferred with OBD_BRW_SRVLOCK.
>  	 */
> -			      ops_srvlock:1;
> -	/**
> +				ops_srvlock:1;
> +	/*
>  	 * lru page list. See osc_lru_{del|use}() in osc_page.c for usage.
>  	 */
> -	struct list_head	      ops_lru;
> -	/**
> +	struct list_head	ops_lru;
> +	/*
>  	 * Submit time - the time when the page is starting RPC. For debugging.
>  	 */
> -	unsigned long	    ops_submit_time;
> +	unsigned long		ops_submit_time;
>  };
>  
>  extern struct kmem_cache *osc_lock_kmem;
> @@ -422,7 +423,7 @@ int  osc_object_is_contended(struct osc_object *obj);
>  
>  int  osc_lock_is_lockless(const struct osc_lock *olck);
>  
> -/*****************************************************************************
> +/****************************************************************************
>   *
>   * Accessors.
>   *
> @@ -558,17 +559,17 @@ static inline int osc_io_srvlock(struct osc_io *oio)
>  }
>  
>  enum osc_extent_state {
> -	OES_INV       = 0, /** extent is just initialized or destroyed */
> -	OES_ACTIVE    = 1, /** process is using this extent */
> -	OES_CACHE     = 2, /** extent is ready for IO */
> -	OES_LOCKING   = 3, /** locking page to prepare IO */
> -	OES_LOCK_DONE = 4, /** locking finished, ready to send */
> -	OES_RPC       = 5, /** in RPC */
> -	OES_TRUNC     = 6, /** being truncated */
> +	OES_INV       = 0, /* extent is just initialized or destroyed */
> +	OES_ACTIVE    = 1, /* process is using this extent */
> +	OES_CACHE     = 2, /* extent is ready for IO */
> +	OES_LOCKING   = 3, /* locking page to prepare IO */
> +	OES_LOCK_DONE = 4, /* locking finished, ready to send */
> +	OES_RPC       = 5, /* in RPC */
> +	OES_TRUNC     = 6, /* being truncated */
>  	OES_STATE_MAX
>  };
>  
> -/**
> +/*
>   * osc_extent data to manage dirty pages.
>   * osc_extent has the following attributes:
>   * 1. all pages in the same must be in one RPC in write back;
> @@ -584,85 +585,85 @@ enum osc_extent_state {
>   * page lock -> cl_loi_list_lock -> object lock(osc_object::oo_lock)
>   */
>  struct osc_extent {
> -	/** red-black tree node */
> -	struct rb_node     oe_node;
> -	/** osc_object of this extent */
> -	struct osc_object *oe_obj;
> -	/** refcount, removed from red-black tree if reaches zero. */
> -	atomic_t       oe_refc;
> -	/** busy if non-zero */
> -	atomic_t       oe_users;
> -	/** link list of osc_object's oo_{hp|urgent|locking}_exts. */
> -	struct list_head	 oe_link;
> -	/** state of this extent */
> +	/* red-black tree node */
> +	struct rb_node		oe_node;
> +	/* osc_object of this extent */
> +	struct osc_object	*oe_obj;
> +	/* refcount, removed from red-black tree if reaches zero. */
> +	atomic_t		oe_refc;
> +	/* busy if non-zero */
> +	atomic_t		oe_users;
> +	/* link list of osc_object's oo_{hp|urgent|locking}_exts. */
> +	struct list_head	oe_link;
> +	/* state of this extent */
>  	enum osc_extent_state	oe_state;
> -	/** flags for this extent. */
> -	unsigned int       oe_intree:1,
> -	/** 0 is write, 1 is read */
> -			   oe_rw:1,
> -	/** sync extent, queued by osc_queue_sync_pages() */
> +	/* flags for this extent. */
> +	unsigned int		oe_intree:1,
> +	/* 0 is write, 1 is read */
> +				oe_rw:1,
> +	/* sync extent, queued by osc_queue_sync_pages() */
>  				oe_sync:1,
> -	/** set if this extent has partial, sync pages.
> +	/* set if this extent has partial, sync pages.
>  	 * Extents with partial page(s) can't merge with others in RPC
>  	 */
>  				oe_no_merge:1,
> -			   oe_srvlock:1,
> -			   oe_memalloc:1,
> -	/** an ACTIVE extent is going to be truncated, so when this extent
> +				oe_srvlock:1,
> +				oe_memalloc:1,
> +	/* an ACTIVE extent is going to be truncated, so when this extent
>  	 * is released, it will turn into TRUNC state instead of CACHE.
>  	 */
> -			   oe_trunc_pending:1,
> -	/** this extent should be written asap and someone may wait for the
> +				oe_trunc_pending:1,
> +	/* this extent should be written asap and someone may wait for the
>  	 * write to finish. This bit is usually set along with urgent if
>  	 * the extent was CACHE state.
>  	 * fsync_wait extent can't be merged because new extent region may
>  	 * exceed fsync range.
>  	 */
> -			   oe_fsync_wait:1,
> -	/** covering lock is being canceled */
> -			   oe_hp:1,
> -	/** this extent should be written back asap. set if one of pages is
> +				oe_fsync_wait:1,
> +	/* covering lock is being canceled */
> +				oe_hp:1,
> +	/* this extent should be written back asap. set if one of pages is
>  	 * called by page WB daemon, or sync write or reading requests.
>  	 */
> -			   oe_urgent:1;
> -	/** how many grants allocated for this extent.
> +				oe_urgent:1;
> +	/* how many grants allocated for this extent.
>  	 *  Grant allocated for this extent. There is no grant allocated
>  	 *  for reading extents and sync write extents.
>  	 */
> -	unsigned int       oe_grants;
> -	/** # of dirty pages in this extent */
> -	unsigned int       oe_nr_pages;
> -	/** list of pending oap pages. Pages in this list are NOT sorted. */
> -	struct list_head	 oe_pages;
> -	/** Since an extent has to be written out in atomic, this is used to
> +	unsigned int		oe_grants;
> +	/* # of dirty pages in this extent */
> +	unsigned int		oe_nr_pages;
> +	/* list of pending oap pages. Pages in this list are NOT sorted. */
> +	struct list_head	oe_pages;
> +	/* Since an extent has to be written out in atomic, this is used to
>  	 * remember the next page need to be locked to write this extent out.
>  	 * Not used right now.
>  	 */
> -	struct osc_page   *oe_next_page;
> -	/** start and end index of this extent, include start and end
> +	struct osc_page		*oe_next_page;
> +	/* start and end index of this extent, include start and end
>  	 * themselves. Page offset here is the page index of osc_pages.
>  	 * oe_start is used as keyword for red-black tree.
>  	 */
> -	pgoff_t	    oe_start;
> -	pgoff_t	    oe_end;
> -	/** maximum ending index of this extent, this is limited by
> +	pgoff_t			oe_start;
> +	pgoff_t			oe_end;
> +	/* maximum ending index of this extent, this is limited by
>  	 * max_pages_per_rpc, lock extent and chunk size.
>  	 */
> -	pgoff_t	    oe_max_end;
> -	/** waitqueue - for those who want to be notified if this extent's
> +	pgoff_t			oe_max_end;
> +	/* waitqueue - for those who want to be notified if this extent's
>  	 * state has changed.
>  	 */
>  	wait_queue_head_t	oe_waitq;
> -	/** lock covering this extent */
> +	/* lock covering this extent */
>  	struct ldlm_lock	*oe_dlmlock;
> -	/** terminator of this extent. Must be true if this extent is in IO. */
> +	/* terminator of this extent. Must be true if this extent is in IO. */
>  	struct task_struct	*oe_owner;
> -	/** return value of writeback. If somebody is waiting for this extent,
> +	/* return value of writeback. If somebody is waiting for this extent,
>  	 * this value can be known by outside world.
>  	 */
> -	int		oe_rc;
> -	/** max pages per rpc when this extent was created */
> -	unsigned int       oe_mppr;
> +	int			oe_rc;
> +	/* max pages per rpc when this extent was created */
> +	unsigned int		oe_mppr;
>  };
>  
>  int osc_extent_finish(const struct lu_env *env, struct osc_extent *ext,
> @@ -677,6 +678,6 @@ typedef int (*osc_page_gang_cbt)(const struct lu_env *, struct cl_io *,
>  int osc_page_gang_lookup(const struct lu_env *env, struct cl_io *io,
>  			 struct osc_object *osc, pgoff_t start, pgoff_t end,
>  			 osc_page_gang_cbt cb, void *cbdata);
> -/** @} osc */
> +/* @} osc */
>  
>  #endif /* OSC_CL_INTERNAL_H */
> diff --git a/drivers/staging/lustre/lustre/osc/osc_internal.h b/drivers/staging/lustre/lustre/osc/osc_internal.h
> index 55054d705a01..0de8a3ee826d 100644
> --- a/drivers/staging/lustre/lustre/osc/osc_internal.h
> +++ b/drivers/staging/lustre/lustre/osc/osc_internal.h
> @@ -43,54 +43,56 @@ extern struct ptlrpc_request_pool *osc_rq_pool;
>  struct lu_env;
>  
>  enum async_flags {
> -	ASYNC_READY = 0x1, /* ap_make_ready will not be called before this
> -			    * page is added to an rpc
> -			    */
> -	ASYNC_URGENT = 0x2, /* page must be put into an RPC before return */
> -	ASYNC_COUNT_STABLE = 0x4, /* ap_refresh_count will not be called
> -				   * to give the caller a chance to update
> -				   * or cancel the size of the io
> -				   */
> +	ASYNC_READY		= 0x1, /* ap_make_ready will not be
> +					* called before this page is
> +					* added to an rpc
> +					*/
> +	ASYNC_URGENT		= 0x2, /* page must be put into an RPC
> +					* before return */
> +	ASYNC_COUNT_STABLE	= 0x4, /* ap_refresh_count will not be
> +					* called to give the caller a
> +					* chance to update or cancel
> +					* the size of the io
> +					*/
>  	ASYNC_HP = 0x10,
>  };
>  
>  struct osc_async_page {
> -	int		     oap_magic;
> -	unsigned short	  oap_cmd;
> -	unsigned short	  oap_interrupted:1;
> +	int				oap_magic;
> +	unsigned short			oap_cmd;
> +	unsigned short			oap_interrupted:1;
>  
> -	struct list_head	      oap_pending_item;
> -	struct list_head	      oap_rpc_item;
> +	struct list_head		oap_pending_item;
> +	struct list_head		oap_rpc_item;
>  
> -	u64		 oap_obj_off;
> -	unsigned int		oap_page_off;
> -	enum async_flags	oap_async_flags;
> +	u64				oap_obj_off;
> +	unsigned int			oap_page_off;
> +	enum async_flags		oap_async_flags;
>  
> -	struct brw_page	 oap_brw_page;
> +	struct brw_page			oap_brw_page;
>  
> -	struct ptlrpc_request   *oap_request;
> -	struct client_obd       *oap_cli;
> -	struct osc_object       *oap_obj;
> +	struct ptlrpc_request		*oap_request;
> +	struct client_obd		*oap_cli;
> +	struct osc_object		*oap_obj;
>  
> -	spinlock_t		 oap_lock;
> +	spinlock_t			oap_lock;
>  };
>  
>  #define oap_page	oap_brw_page.pg
> -#define oap_count       oap_brw_page.count
> -#define oap_brw_flags   oap_brw_page.flag
> +#define oap_count	oap_brw_page.count
> +#define oap_brw_flags	oap_brw_page.flag
>  
>  static inline struct osc_async_page *brw_page2oap(struct brw_page *pga)
>  {
> -	return (struct osc_async_page *)container_of(pga, struct osc_async_page,
> -						     oap_brw_page);
> +	return container_of(pga, struct osc_async_page, oap_brw_page);
>  }
>  
>  struct osc_cache_waiter {
> -	struct list_head	      ocw_entry;
> -	wait_queue_head_t	     ocw_waitq;
> -	struct osc_async_page  *ocw_oap;
> -	int		     ocw_grant;
> -	int		     ocw_rc;
> +	struct list_head		ocw_entry;
> +	wait_queue_head_t		ocw_waitq;
> +	struct osc_async_page		*ocw_oap;
> +	int				ocw_grant;
> +	int				ocw_rc;
>  };
>  
>  void osc_wake_cache_waiters(struct client_obd *cli);
> @@ -166,19 +168,19 @@ static inline char *cli_name(struct client_obd *cli)
>  }
>  
>  struct osc_device {
> -	struct cl_device    od_cl;
> -	struct obd_export  *od_exp;
> +	struct cl_device	od_cl;
> +	struct obd_export	*od_exp;
>  
>  	/* Write stats is actually protected by client_obd's lock. */
>  	struct osc_stats {
> -		u64	os_lockless_writes;	  /* by bytes */
> -		u64	os_lockless_reads;	  /* by bytes */
> -		u64	os_lockless_truncates;    /* by times */
> -	} od_stats;
> +		u64	os_lockless_writes;	/* by bytes */
> +		u64	os_lockless_reads;	/* by bytes */
> +		u64	os_lockless_truncates;	/* by times */
> +	}			od_stats;
>  
>  	/* configuration item(s) */
> -	int		 od_contention_time;
> -	int		 od_lockless_truncate;
> +	int			od_contention_time;
> +	int			od_lockless_truncate;
>  };
>  
>  static inline struct osc_device *obd2osc_dev(const struct obd_device *d)
> @@ -190,10 +192,10 @@ extern struct lu_kmem_descr osc_caches[];
>  
>  extern struct kmem_cache *osc_quota_kmem;
>  struct osc_quota_info {
> -	/** linkage for quota hash table */
> -	struct rhash_head oqi_hash;
> -	u32		  oqi_id;
> -	struct rcu_head	  rcu;
> +	/* linkage for quota hash table */
> +	struct rhash_head	oqi_hash;
> +	u32			oqi_id;
> +	struct rcu_head		rcu;
>  };
>  
>  int osc_quota_setup(struct obd_device *obd);
> @@ -207,16 +209,16 @@ void osc_inc_unstable_pages(struct ptlrpc_request *req);
>  void osc_dec_unstable_pages(struct ptlrpc_request *req);
>  bool osc_over_unstable_soft_limit(struct client_obd *cli);
>  
> -/**
> +/*
>   * Bit flags for osc_dlm_lock_at_pageoff().
>   */
>  enum osc_dap_flags {
> -	/**
> +	/*
>  	 * Just check if the desired lock exists, it won't hold reference
>  	 * count on lock.
>  	 */
>  	OSC_DAP_FL_TEST_LOCK	= BIT(0),
> -	/**
> +	/*
>  	 * Return the lock even if it is being canceled.
>  	 */
>  	OSC_DAP_FL_CANCELING	= BIT(1),
> @@ -228,9 +230,9 @@ struct ldlm_lock *osc_dlmlock_at_pgoff(const struct lu_env *env,
>  
>  int osc_object_invalidate(const struct lu_env *env, struct osc_object *osc);
>  
> -/** osc shrink list to link all osc client obd */
> +/* osc shrink list to link all osc client obd */
>  extern struct list_head osc_shrink_list;
> -/** spin lock to protect osc_shrink_list */
> +/* spin lock to protect osc_shrink_list */
>  extern spinlock_t osc_shrink_lock;
>  unsigned long osc_cache_shrink_count(struct shrinker *sk,
>  				     struct shrink_control *sc);
> 
> 
> 
