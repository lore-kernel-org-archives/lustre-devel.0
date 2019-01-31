From: James Simmons <jsimmons@infradead.org>
Date: Thu, 31 Jan 2019 12:19:30 -0500
Subject: [lustre-devel] [PATCH 26/26] o2iblnd: cleanup white spaces
In-Reply-To: <1548955170-13456-1-git-send-email-jsimmons@infradead.org>
References: <1548955170-13456-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1548955170-13456-27-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

The o2iblnd code is very messy and difficult to read. Remove
excess white space and properly align data structures so they
are easy on the eyes.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c    |  79 +--
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h    | 612 +++++++++++----------
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c |  99 ++--
 .../lustre/lnet/klnds/o2iblnd/o2iblnd_modparams.c  |  22 +-
 4 files changed, 407 insertions(+), 405 deletions(-)

diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
index 1a6bc45..74b21fe2 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
@@ -183,15 +183,15 @@ void kiblnd_pack_msg(struct lnet_ni *ni, struct kib_msg *msg, int version,
 	 * CAVEAT EMPTOR! all message fields not set here should have been
 	 * initialised previously.
 	 */
-	msg->ibm_magic    = IBLND_MSG_MAGIC;
-	msg->ibm_version  = version;
+	msg->ibm_magic = IBLND_MSG_MAGIC;
+	msg->ibm_version = version;
 	/*   ibm_type */
-	msg->ibm_credits  = credits;
+	msg->ibm_credits = credits;
 	/*   ibm_nob */
-	msg->ibm_cksum    = 0;
-	msg->ibm_srcnid   = ni->ni_nid;
+	msg->ibm_cksum = 0;
+	msg->ibm_srcnid = ni->ni_nid;
 	msg->ibm_srcstamp = net->ibn_incarnation;
-	msg->ibm_dstnid   = dstnid;
+	msg->ibm_dstnid = dstnid;
 	msg->ibm_dststamp = dststamp;
 
 	if (*kiblnd_tunables.kib_cksum) {
@@ -260,7 +260,7 @@ int kiblnd_unpack_msg(struct kib_msg *msg, int nob)
 		msg->ibm_version = version;
 		BUILD_BUG_ON(sizeof(msg->ibm_type) != 1);
 		BUILD_BUG_ON(sizeof(msg->ibm_credits) != 1);
-		msg->ibm_nob     = msg_nob;
+		msg->ibm_nob = msg_nob;
 		__swab64s(&msg->ibm_srcnid);
 		__swab64s(&msg->ibm_srcstamp);
 		__swab64s(&msg->ibm_dstnid);
@@ -903,12 +903,12 @@ struct kib_conn *kiblnd_create_conn(struct kib_peer_ni *peer_ni,
 	atomic_inc(&net->ibn_nconns);
 	return conn;
 
- failed_2:
+failed_2:
 	kiblnd_destroy_conn(conn);
 	kfree(conn);
- failed_1:
+failed_1:
 	kfree(init_qp_attr);
- failed_0:
+failed_0:
 	return NULL;
 }
 
@@ -1004,7 +1004,7 @@ int kiblnd_close_stale_conns_locked(struct kib_peer_ni *peer_ni,
 	list_for_each_safe(ctmp, cnxt, &peer_ni->ibp_conns) {
 		conn = list_entry(ctmp, struct kib_conn, ibc_list);
 
-		if (conn->ibc_version     == version &&
+		if (conn->ibc_version == version &&
 		    conn->ibc_incarnation == incarnation)
 			continue;
 
@@ -1077,7 +1077,7 @@ static int kiblnd_ctl(struct lnet_ni *ni, unsigned int cmd, void *arg)
 
 		rc = kiblnd_get_peer_info(ni, data->ioc_count,
 					  &nid, &count);
-		data->ioc_nid   = nid;
+		data->ioc_nid = nid;
 		data->ioc_count = count;
 		break;
 	}
@@ -1414,15 +1414,16 @@ static void kiblnd_destroy_fmr_pool_list(struct list_head *head)
 static int kiblnd_alloc_fmr_pool(struct kib_fmr_poolset *fps, struct kib_fmr_pool *fpo)
 {
 	struct ib_fmr_pool_param param = {
-		.max_pages_per_fmr = LNET_MAX_IOV,
-		.page_shift        = PAGE_SHIFT,
-		.access            = (IB_ACCESS_LOCAL_WRITE |
-				      IB_ACCESS_REMOTE_WRITE),
-		.pool_size         = fps->fps_pool_size,
-		.dirty_watermark   = fps->fps_flush_trigger,
-		.flush_function    = NULL,
-		.flush_arg         = NULL,
-		.cache             = !!fps->fps_cache };
+		.max_pages_per_fmr	= LNET_MAX_IOV,
+		.page_shift		= PAGE_SHIFT,
+		.access			= (IB_ACCESS_LOCAL_WRITE |
+					   IB_ACCESS_REMOTE_WRITE),
+		.pool_size		= fps->fps_pool_size,
+		.dirty_watermark	= fps->fps_flush_trigger,
+		.flush_function		= NULL,
+		.flush_arg		= NULL,
+		.cache			= !!fps->fps_cache
+	};
 	int rc = 0;
 
 	fpo->fmr.fpo_fmr_pool = ib_create_fmr_pool(fpo->fpo_hdev->ibh_pd,
@@ -1696,7 +1697,7 @@ int kiblnd_fmr_pool_map(struct kib_fmr_poolset *fps, struct kib_tx *tx,
 	u64 version;
 	int rc;
 
- again:
+again:
 	spin_lock(&fps->fps_lock);
 	version = fps->fps_version;
 	list_for_each_entry(fpo, &fps->fps_pool_list, fpo_list) {
@@ -1844,8 +1845,8 @@ static void kiblnd_init_pool(struct kib_poolset *ps, struct kib_pool *pool, int
 	memset(pool, 0, sizeof(*pool));
 	INIT_LIST_HEAD(&pool->po_free_list);
 	pool->po_deadline = ktime_get_seconds() + IBLND_POOL_DEADLINE;
-	pool->po_owner    = ps;
-	pool->po_size     = size;
+	pool->po_owner = ps;
+	pool->po_size = size;
 }
 
 static void kiblnd_destroy_pool_list(struct list_head *head)
@@ -1900,13 +1901,13 @@ static int kiblnd_init_poolset(struct kib_poolset *ps, int cpt,
 
 	memset(ps, 0, sizeof(*ps));
 
-	ps->ps_cpt          = cpt;
-	ps->ps_net          = net;
+	ps->ps_cpt = cpt;
+	ps->ps_net = net;
 	ps->ps_pool_create  = po_create;
 	ps->ps_pool_destroy = po_destroy;
-	ps->ps_node_init    = nd_init;
-	ps->ps_node_fini    = nd_fini;
-	ps->ps_pool_size    = size;
+	ps->ps_node_init = nd_init;
+	ps->ps_node_fini = nd_fini;
+	ps->ps_pool_size = size;
 	if (strlcpy(ps->ps_name, name, sizeof(ps->ps_name))
 	    >= sizeof(ps->ps_name))
 		return -E2BIG;
@@ -1971,7 +1972,7 @@ struct list_head *kiblnd_pool_alloc_node(struct kib_poolset *ps)
 	unsigned int trips = 0;
 	int rc;
 
- again:
+again:
 	spin_lock(&ps->ps_lock);
 	list_for_each_entry(pool, &ps->ps_pool_list, po_list) {
 		if (list_empty(&pool->po_free_list))
@@ -2286,7 +2287,7 @@ static int kiblnd_net_init_pools(struct kib_net *net, struct lnet_ni *ni,
 	}
 
 	return 0;
- failed:
+failed:
 	kiblnd_net_fini_pools(net);
 	LASSERT(rc);
 	return rc;
@@ -2302,8 +2303,8 @@ static int kiblnd_hdev_get_attr(struct kib_hca_dev *hdev)
 	 * matching that of the native system
 	 */
 	hdev->ibh_page_shift = PAGE_SHIFT;
-	hdev->ibh_page_size  = 1 << PAGE_SHIFT;
-	hdev->ibh_page_mask  = ~((u64)hdev->ibh_page_size - 1);
+	hdev->ibh_page_size = 1 << PAGE_SHIFT;
+	hdev->ibh_page_mask = ~((u64)hdev->ibh_page_size - 1);
 
 	if (hdev->ibh_ibdev->ops.alloc_fmr &&
 	    hdev->ibh_ibdev->ops.dealloc_fmr &&
@@ -2455,9 +2456,9 @@ int kiblnd_dev_failover(struct kib_dev *dev)
 	}
 
 	memset(&addr, 0, sizeof(addr));
-	addr.sin_family      = AF_INET;
+	addr.sin_family = AF_INET;
 	addr.sin_addr.s_addr = htonl(dev->ibd_ifip);
-	addr.sin_port	= htons(*kiblnd_tunables.kib_service);
+	addr.sin_port = htons(*kiblnd_tunables.kib_service);
 
 	/* Bind to failover device or port */
 	rc = rdma_bind_addr(cmid, (struct sockaddr *)&addr);
@@ -2478,8 +2479,8 @@ int kiblnd_dev_failover(struct kib_dev *dev)
 	}
 
 	atomic_set(&hdev->ibh_ref, 1);
-	hdev->ibh_dev   = dev;
-	hdev->ibh_cmid  = cmid;
+	hdev->ibh_dev = dev;
+	hdev->ibh_cmid = cmid;
 	hdev->ibh_ibdev = cmid->device;
 
 	pd = ib_alloc_pd(cmid->device, 0);
@@ -2519,7 +2520,7 @@ int kiblnd_dev_failover(struct kib_dev *dev)
 	}
 
 	write_unlock_irqrestore(&kiblnd_data.kib_global_lock, flags);
- out:
+out:
 	if (!list_empty(&zombie_tpo))
 		kiblnd_destroy_pool_list(&zombie_tpo);
 	if (!list_empty(&zombie_ppo))
@@ -2832,7 +2833,7 @@ static int kiblnd_base_startup(void)
 
 	return 0;
 
- failed:
+failed:
 	kiblnd_base_shutdown();
 	return -ENETDOWN;
 }
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
index 423bae7..2bf1228 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
@@ -97,10 +97,10 @@ struct kib_tunables {
 
 extern struct kib_tunables  kiblnd_tunables;
 
-#define IBLND_MSG_QUEUE_SIZE_V1   8 /* V1 only : # messages/RDMAs in-flight */
+#define IBLND_MSG_QUEUE_SIZE_V1	  8 /* V1 only : # messages/RDMAs in-flight */
 #define IBLND_CREDIT_HIGHWATER_V1 7 /* V1 only : when eagerly to return credits */
 
-#define IBLND_CREDITS_DEFAULT     8 /* default # of peer_ni credits */
+#define IBLND_CREDITS_DEFAULT	  8 /* default # of peer_ni credits */
 /* Max # of peer_ni credits */
 #define IBLND_CREDITS_MAX	  ((typeof(((struct kib_msg *)0)->ibm_credits)) - 1)
 
@@ -114,8 +114,8 @@ struct kib_tunables {
 							       ps, qpt)
 
 /* 2 OOB shall suffice for 1 keepalive and 1 returning credits */
-#define IBLND_OOB_CAPABLE(v)       ((v) != IBLND_MSG_VERSION_1)
-#define IBLND_OOB_MSGS(v)	   (IBLND_OOB_CAPABLE(v) ? 2 : 0)
+#define IBLND_OOB_CAPABLE(v)	((v) != IBLND_MSG_VERSION_1)
+#define IBLND_OOB_MSGS(v)	(IBLND_OOB_CAPABLE(v) ? 2 : 0)
 
 #define IBLND_MSG_SIZE		(4 << 10)	/* max size of queued messages (inc hdr) */
 #define IBLND_MAX_RDMA_FRAGS	LNET_MAX_IOV	/* max # of fragments supported */
@@ -124,9 +124,9 @@ struct kib_tunables {
 /* derived constants... */
 /* Pools (shared by connections on each CPT) */
 /* These pools can grow@runtime, so don't need give a very large value */
-#define IBLND_TX_POOL			256
-#define IBLND_FMR_POOL			256
-#define IBLND_FMR_POOL_FLUSH		192
+#define IBLND_TX_POOL		256
+#define IBLND_FMR_POOL		256
+#define IBLND_FMR_POOL_FLUSH	192
 
 #define IBLND_RX_MSGS(c)	\
 	((c->ibc_queue_depth) * 2 + IBLND_OOB_MSGS(c->ibc_version))
@@ -143,9 +143,9 @@ struct kib_tunables {
 
 /* o2iblnd can run over aliased interface */
 #ifdef IFALIASZ
-#define KIB_IFNAME_SIZE	      IFALIASZ
+#define KIB_IFNAME_SIZE		IFALIASZ
 #else
-#define KIB_IFNAME_SIZE	      256
+#define KIB_IFNAME_SIZE		256
 #endif
 
 enum kib_dev_caps {
@@ -155,44 +155,46 @@ enum kib_dev_caps {
 };
 
 struct kib_dev {
-	struct list_head   ibd_list;            /* chain on kib_devs */
-	struct list_head   ibd_fail_list;       /* chain on kib_failed_devs */
-	u32              ibd_ifip;            /* IPoIB interface IP */
+	struct list_head	ibd_list;	/* chain on kib_devs */
+	struct list_head	ibd_fail_list;	/* chain on kib_failed_devs */
+	u32			ibd_ifip;	/* IPoIB interface IP */
 
 	/* IPoIB interface name */
-	char               ibd_ifname[KIB_IFNAME_SIZE];
-	int                ibd_nnets;           /* # nets extant */
-
-	time64_t	   ibd_next_failover;
-	int                ibd_failed_failover; /* # failover failures */
-	unsigned int       ibd_failover;        /* failover in progress */
-	unsigned int ibd_can_failover; /* IPoIB interface is a bonding master */
-	struct list_head   ibd_nets;
-	struct kib_hca_dev *ibd_hdev;
+	char			ibd_ifname[KIB_IFNAME_SIZE];
+	int			ibd_nnets;	/* # nets extant */
+
+	time64_t		ibd_next_failover;
+	int			ibd_failed_failover; /* # failover failures */
+	unsigned int		ibd_failover;        /* failover in progress */
+	unsigned int		ibd_can_failover;    /* IPoIB interface is a
+						      * bonding master
+						      */
+	struct list_head	ibd_nets;
+	struct kib_hca_dev	*ibd_hdev;
 	enum kib_dev_caps	ibd_dev_caps;
 };
 
 struct kib_hca_dev {
-	struct rdma_cm_id  *ibh_cmid;           /* listener cmid */
-	struct ib_device   *ibh_ibdev;          /* IB device */
-	int                ibh_page_shift;      /* page shift of current HCA */
-	int                ibh_page_size;       /* page size of current HCA */
-	u64              ibh_page_mask;       /* page mask of current HCA */
-	int                ibh_mr_shift;        /* bits shift of max MR size */
-	u64              ibh_mr_size;         /* size of MR */
-	struct ib_pd       *ibh_pd;             /* PD */
-	struct kib_dev	   *ibh_dev;		/* owner */
-	atomic_t           ibh_ref;             /* refcount */
+	struct rdma_cm_id	*ibh_cmid;	/* listener cmid */
+	struct ib_device	*ibh_ibdev;	/* IB device */
+	int			ibh_page_shift;	/* page shift of current HCA */
+	int			ibh_page_size;	/* page size of current HCA */
+	u64			ibh_page_mask;	/* page mask of current HCA */
+	int			ibh_mr_shift;	/* bits shift of max MR size */
+	u64			ibh_mr_size;	/* size of MR */
+	struct ib_pd		*ibh_pd;	/* PD */
+	struct kib_dev		*ibh_dev;	/* owner */
+	atomic_t		ibh_ref;	/* refcount */
 };
 
 /** # of seconds to keep pool alive */
-#define IBLND_POOL_DEADLINE     300
+#define IBLND_POOL_DEADLINE	300
 /** # of seconds to retry if allocation failed */
 #define IBLND_POOL_RETRY	1
 
 struct kib_pages {
-	int                ibp_npages;          /* # pages */
-	struct page        *ibp_pages[0];       /* page array */
+	int			ibp_npages;	/* # pages */
+	struct page		*ibp_pages[0];	/* page array */
 };
 
 struct kib_pool;
@@ -206,39 +208,39 @@ typedef int  (*kib_ps_pool_create_t)(struct kib_poolset *ps,
 
 struct kib_net;
 
-#define IBLND_POOL_NAME_LEN     32
+#define IBLND_POOL_NAME_LEN	32
 
 struct kib_poolset {
-	spinlock_t            ps_lock;            /* serialize */
-	struct kib_net        *ps_net;            /* network it belongs to */
-	char                  ps_name[IBLND_POOL_NAME_LEN]; /* pool set name */
-	struct list_head      ps_pool_list;       /* list of pools */
-	struct list_head      ps_failed_pool_list;/* failed pool list */
-	time64_t	      ps_next_retry;	  /* time stamp for retry if */
-						  /* failed to allocate */
-	int                   ps_increasing;      /* is allocating new pool */
-	int                   ps_pool_size;       /* new pool size */
-	int                   ps_cpt;             /* CPT id */
-
-	kib_ps_pool_create_t  ps_pool_create;     /* create a new pool */
-	kib_ps_pool_destroy_t ps_pool_destroy;    /* destroy a pool */
-	kib_ps_node_init_t    ps_node_init; /* initialize new allocated node */
-	kib_ps_node_fini_t    ps_node_fini;       /* finalize node */
+	spinlock_t		ps_lock;	/* serialize */
+	struct kib_net		*ps_net;	/* network it belongs to */
+	char			ps_name[IBLND_POOL_NAME_LEN]; /* pool set name */
+	struct list_head	ps_pool_list;	/* list of pools */
+	struct list_head	ps_failed_pool_list;/* failed pool list */
+	time64_t		ps_next_retry;	/* time stamp for retry if */
+						/* failed to allocate */
+	int			ps_increasing;	/* is allocating new pool */
+	int			ps_pool_size;	/* new pool size */
+	int			ps_cpt;		/* CPT id */
+
+	kib_ps_pool_create_t	ps_pool_create;	 /* create a new pool */
+	kib_ps_pool_destroy_t	ps_pool_destroy; /* destroy a pool */
+	kib_ps_node_init_t	ps_node_init;	 /* initialize new allocated node */
+	kib_ps_node_fini_t	ps_node_fini;    /* finalize node */
 };
 
 struct kib_pool {
-	struct list_head      po_list;       /* chain on pool list */
-	struct list_head      po_free_list;  /* pre-allocated node */
-	struct kib_poolset	*po_owner;	/* pool_set of this pool */
+	struct list_head	po_list;	/* chain on pool list */
+	struct list_head	po_free_list;	/* pre-allocated node */
+	struct kib_poolset     *po_owner;	/* pool_set of this pool */
 	time64_t		po_deadline;	/* deadline of this pool */
-	int                   po_allocated;  /* # of elements in use */
-	int                   po_failed;     /* pool is created on failed HCA */
-	int                   po_size;       /* # of pre-allocated elements */
+	int			po_allocated;	/* # of elements in use */
+	int			po_failed;	/* pool is created on failed HCA */
+	int			po_size;	/* # of pre-allocated elements */
 };
 
 struct kib_tx_poolset {
 	struct kib_poolset	tps_poolset;		/* pool-set */
-	u64                 tps_next_tx_cookie; /* cookie of TX */
+	u64			tps_next_tx_cookie;	/* cookie of TX */
 };
 
 struct kib_tx_pool {
@@ -249,27 +251,27 @@ struct kib_tx_pool {
 };
 
 struct kib_fmr_poolset {
-	spinlock_t            fps_lock;            /* serialize */
-	struct kib_net        *fps_net;            /* IB network */
-	struct list_head      fps_pool_list;       /* FMR pool list */
-	struct list_head      fps_failed_pool_list;/* FMR pool list */
-	u64                 fps_version;         /* validity stamp */
-	int                   fps_cpt;             /* CPT id */
-	int                   fps_pool_size;
-	int                   fps_flush_trigger;
-	int		      fps_cache;
-	int                   fps_increasing;      /* is allocating new pool */
+	spinlock_t		fps_lock;		/* serialize */
+	struct kib_net	       *fps_net;		/* IB network */
+	struct list_head	fps_pool_list;		/* FMR pool list */
+	struct list_head	fps_failed_pool_list;	/* FMR pool list */
+	u64			fps_version;		/* validity stamp */
+	int			fps_cpt;		/* CPT id */
+	int			fps_pool_size;
+	int			fps_flush_trigger;
+	int			fps_cache;
+	int			fps_increasing;		/* is allocating new pool */
 	time64_t		fps_next_retry;		/* time stamp for retry
 							 * if failed to allocate
 							 */
 };
 
 struct kib_fast_reg_descriptor { /* For fast registration */
-	struct list_head		 frd_list;
-	struct ib_send_wr		 frd_inv_wr;
-	struct ib_reg_wr		 frd_fastreg_wr;
-	struct ib_mr			*frd_mr;
-	bool				 frd_valid;
+	struct list_head	frd_list;
+	struct ib_send_wr	frd_inv_wr;
+	struct ib_reg_wr	frd_fastreg_wr;
+	struct ib_mr	       *frd_mr;
+	bool			frd_valid;
 };
 
 struct kib_fmr_pool {
@@ -278,16 +280,16 @@ struct kib_fmr_pool {
 	struct kib_fmr_poolset	*fpo_owner;	/* owner of this pool */
 	union {
 		struct {
-			struct ib_fmr_pool *fpo_fmr_pool; /* IB FMR pool */
+			struct ib_fmr_pool	*fpo_fmr_pool; /* IB FMR pool */
 		} fmr;
 		struct { /* For fast registration */
-			struct list_head    fpo_pool_list;
-			int		    fpo_pool_size;
+			struct list_head	fpo_pool_list;
+			int			fpo_pool_size;
 		} fast_reg;
 	};
 	time64_t		fpo_deadline;	/* deadline of this pool */
-	int                   fpo_failed;          /* fmr pool is failed */
-	int                   fpo_map_count;       /* # of mapped FMR */
+	int			fpo_failed;	/* fmr pool is failed */
+	int			fpo_map_count;	/* # of mapped FMR */
 };
 
 struct kib_fmr {
@@ -298,13 +300,13 @@ struct kib_fmr {
 };
 
 struct kib_net {
-	struct list_head      ibn_list;       /* chain on struct kib_dev::ibd_nets */
-	u64                 ibn_incarnation;/* my epoch */
-	int                   ibn_init;       /* initialisation state */
-	int                   ibn_shutdown;   /* shutting down? */
+	struct list_head	ibn_list;	/* chain on struct kib_dev::ibd_nets */
+	u64			ibn_incarnation;/* my epoch */
+	int			ibn_init;	/* initialisation state */
+	int			ibn_shutdown;	/* shutting down? */
 
-	atomic_t              ibn_npeers;     /* # peers extant */
-	atomic_t              ibn_nconns;     /* # connections extant */
+	atomic_t		ibn_npeers;	/* # peers extant */
+	atomic_t		ibn_nconns;	/* # connections extant */
 
 	struct kib_tx_poolset	**ibn_tx_ps;	/* tx pool-set */
 	struct kib_fmr_poolset	**ibn_fmr_ps;	/* fmr pool-set */
@@ -318,27 +320,27 @@ struct kib_net {
 #define KIB_THREAD_TID(id)		((id) & ((1UL << KIB_THREAD_SHIFT) - 1))
 
 struct kib_sched_info {
-	spinlock_t         ibs_lock;     /* serialise */
-	wait_queue_head_t  ibs_waitq;    /* schedulers sleep here */
-	struct list_head   ibs_conns;    /* conns to check for rx completions */
-	int                ibs_nthreads; /* number of scheduler threads */
-	int                ibs_nthreads_max; /* max allowed scheduler threads */
-	int                ibs_cpt;      /* CPT id */
+	spinlock_t		ibs_lock;	/* serialise */
+	wait_queue_head_t	ibs_waitq;	/* schedulers sleep here */
+	struct list_head	ibs_conns;	/* conns to check for rx completions */
+	int			ibs_nthreads;	/* number of scheduler threads */
+	int			ibs_nthreads_max; /* max allowed scheduler threads */
+	int			ibs_cpt;	/* CPT id */
 };
 
 struct kib_data {
-	int               kib_init;           /* initialisation state */
-	int               kib_shutdown;       /* shut down? */
-	struct list_head  kib_devs;           /* IB devices extant */
-	struct list_head  kib_failed_devs;    /* list head of failed devices */
-	wait_queue_head_t kib_failover_waitq; /* schedulers sleep here */
-	atomic_t kib_nthreads;                /* # live threads */
-	rwlock_t kib_global_lock;    /* stabilize net/dev/peer_ni/conn ops */
-	struct list_head *kib_peers; /* hash table of all my known peers */
-	int  kib_peer_hash_size;     /* size of kib_peers */
-	void *kib_connd; /* the connd task (serialisation assertions) */
-	struct list_head kib_connd_conns;   /* connections to setup/teardown */
-	struct list_head kib_connd_zombies; /* connections with zero refcount */
+	int			kib_init;	    /* initialisation state */
+	int			kib_shutdown;       /* shut down? */
+	struct list_head	kib_devs;           /* IB devices extant */
+	struct list_head	kib_failed_devs;    /* list head of failed devices */
+	wait_queue_head_t	kib_failover_waitq; /* schedulers sleep here */
+	atomic_t		kib_nthreads;	    /* # live threads */
+	rwlock_t		kib_global_lock;    /* stabilize net/dev/peer_ni/conn ops */
+	struct list_head       *kib_peers;	    /* hash table of all my known peers */
+	int			kib_peer_hash_size; /* size of kib_peers */
+	void		       *kib_connd;	    /* the connd task (serialisation assertions) */
+	struct list_head	kib_connd_conns;    /* connections to setup/teardown */
+	struct list_head	kib_connd_zombies;  /* connections with zero refcount */
 	/* connections to reconnect */
 	struct list_head	kib_reconn_list;
 	/* peers wait for reconnection */
@@ -349,15 +351,15 @@ struct kib_data {
 	 */
 	time64_t		kib_reconn_sec;
 
-	wait_queue_head_t kib_connd_waitq;  /* connection daemon sleeps here */
-	spinlock_t kib_connd_lock;          /* serialise */
-	struct ib_qp_attr kib_error_qpa;    /* QP->ERROR */
-	struct kib_sched_info **kib_scheds; /* percpt data for schedulers */
+	wait_queue_head_t	kib_connd_waitq;    /* connection daemon sleeps here */
+	spinlock_t		kib_connd_lock;	    /* serialise */
+	struct ib_qp_attr	kib_error_qpa;	    /* QP->ERROR */
+	struct kib_sched_info **kib_scheds;	    /* percpt data for schedulers */
 };
 
-#define IBLND_INIT_NOTHING 0
-#define IBLND_INIT_DATA    1
-#define IBLND_INIT_ALL     2
+#define IBLND_INIT_NOTHING	0
+#define IBLND_INIT_DATA		1
+#define IBLND_INIT_ALL		2
 
 /************************************************************************
  * IB Wire message format.
@@ -365,62 +367,62 @@ struct kib_data {
  */
 
 struct kib_connparams {
-	u16        ibcp_queue_depth;
-	u16        ibcp_max_frags;
-	u32        ibcp_max_msg_size;
+	u16			ibcp_queue_depth;
+	u16			ibcp_max_frags;
+	u32			ibcp_max_msg_size;
 } __packed;
 
 struct kib_immediate_msg {
-	struct lnet_hdr	ibim_hdr;        /* portals header */
-	char         ibim_payload[0]; /* piggy-backed payload */
+	struct lnet_hdr		ibim_hdr;	/* portals header */
+	char			ibim_payload[0];/* piggy-backed payload */
 } __packed;
 
 struct kib_rdma_frag {
-	u32        rf_nob;          /* # bytes this frag */
-	u64        rf_addr;         /* CAVEAT EMPTOR: misaligned!! */
+	u32			rf_nob;		/* # bytes this frag */
+	u64			rf_addr;	/* CAVEAT EMPTOR: misaligned!! */
 } __packed;
 
 struct kib_rdma_desc {
-	u32           rd_key;       /* local/remote key */
-	u32           rd_nfrags;    /* # fragments */
+	u32			rd_key;		/* local/remote key */
+	u32			rd_nfrags;	/* # fragments */
 	struct kib_rdma_frag	rd_frags[0];	/* buffer frags */
 } __packed;
 
 struct kib_putreq_msg {
-	struct lnet_hdr	ibprm_hdr;    /* portals header */
-	u64           ibprm_cookie; /* opaque completion cookie */
+	struct lnet_hdr		ibprm_hdr;	/* portals header */
+	u64			ibprm_cookie;	/* opaque completion cookie */
 } __packed;
 
 struct kib_putack_msg {
-	u64           ibpam_src_cookie; /* reflected completion cookie */
-	u64           ibpam_dst_cookie; /* opaque completion cookie */
-	struct kib_rdma_desc ibpam_rd;         /* sender's sink buffer */
+	u64			ibpam_src_cookie; /* reflected completion cookie */
+	u64			ibpam_dst_cookie; /* opaque completion cookie */
+	struct kib_rdma_desc	ibpam_rd;	  /* sender's sink buffer */
 } __packed;
 
 struct kib_get_msg {
-	struct lnet_hdr ibgm_hdr;     /* portals header */
-	u64           ibgm_cookie;  /* opaque completion cookie */
-	struct kib_rdma_desc ibgm_rd;      /* rdma descriptor */
+	struct lnet_hdr		ibgm_hdr;	/* portals header */
+	u64			ibgm_cookie;	/* opaque completion cookie */
+	struct kib_rdma_desc	ibgm_rd;	/* rdma descriptor */
 } __packed;
 
 struct kib_completion_msg {
-	u64           ibcm_cookie;  /* opaque completion cookie */
-	s32           ibcm_status;  /* < 0 failure: >= 0 length */
+	u64			ibcm_cookie;	/* opaque completion cookie */
+	s32			ibcm_status;	/* < 0 failure: >= 0 length */
 } __packed;
 
 struct kib_msg {
 	/* First 2 fields fixed FOR ALL TIME */
-	u32           ibm_magic;    /* I'm an ibnal message */
-	u16           ibm_version;  /* this is my version number */
-
-	u8            ibm_type;     /* msg type */
-	u8            ibm_credits;  /* returned credits */
-	u32           ibm_nob;      /* # bytes in whole message */
-	u32           ibm_cksum;    /* checksum (0 == no checksum) */
-	u64           ibm_srcnid;   /* sender's NID */
-	u64           ibm_srcstamp; /* sender's incarnation */
-	u64           ibm_dstnid;   /* destination's NID */
-	u64           ibm_dststamp; /* destination's incarnation */
+	u32			ibm_magic;	/* I'm an ibnal message */
+	u16			ibm_version;	/* this is my version number */
+
+	u8			ibm_type;	/* msg type */
+	u8			ibm_credits;	/* returned credits */
+	u32			ibm_nob;	/* # bytes in whole message */
+	u32			ibm_cksum;	/* checksum (0 == no checksum) */
+	u64			ibm_srcnid;	/* sender's NID */
+	u64			ibm_srcstamp;	/* sender's incarnation */
+	u64			ibm_dstnid;	/* destination's NID */
+	u64			ibm_dststamp;	/* destination's incarnation */
 
 	union {
 		struct kib_connparams		connparams;
@@ -432,161 +434,161 @@ struct kib_msg {
 	} __packed ibm_u;
 } __packed;
 
-#define IBLND_MSG_MAGIC     LNET_PROTO_IB_MAGIC /* unique magic */
+#define IBLND_MSG_MAGIC		LNET_PROTO_IB_MAGIC /* unique magic */
 
-#define IBLND_MSG_VERSION_1 0x11
-#define IBLND_MSG_VERSION_2 0x12
-#define IBLND_MSG_VERSION   IBLND_MSG_VERSION_2
+#define IBLND_MSG_VERSION_1	0x11
+#define IBLND_MSG_VERSION_2	0x12
+#define IBLND_MSG_VERSION	IBLND_MSG_VERSION_2
 
-#define IBLND_MSG_CONNREQ   0xc0	/* connection request */
-#define IBLND_MSG_CONNACK   0xc1	/* connection acknowledge */
-#define IBLND_MSG_NOOP      0xd0	/* nothing (just credits) */
-#define IBLND_MSG_IMMEDIATE 0xd1	/* immediate */
-#define IBLND_MSG_PUT_REQ   0xd2	/* putreq (src->sink) */
-#define IBLND_MSG_PUT_NAK   0xd3	/* completion (sink->src) */
-#define IBLND_MSG_PUT_ACK   0xd4	/* putack (sink->src) */
-#define IBLND_MSG_PUT_DONE  0xd5	/* completion (src->sink) */
-#define IBLND_MSG_GET_REQ   0xd6	/* getreq (sink->src) */
-#define IBLND_MSG_GET_DONE  0xd7	/* completion (src->sink: all OK) */
+#define IBLND_MSG_CONNREQ	0xc0	/* connection request */
+#define IBLND_MSG_CONNACK	0xc1	/* connection acknowledge */
+#define IBLND_MSG_NOOP		0xd0	/* nothing (just credits) */
+#define IBLND_MSG_IMMEDIATE	0xd1	/* immediate */
+#define IBLND_MSG_PUT_REQ	0xd2	/* putreq (src->sink) */
+#define IBLND_MSG_PUT_NAK	0xd3	/* completion (sink->src) */
+#define IBLND_MSG_PUT_ACK	0xd4	/* putack (sink->src) */
+#define IBLND_MSG_PUT_DONE	0xd5	/* completion (src->sink) */
+#define IBLND_MSG_GET_REQ	0xd6	/* getreq (sink->src) */
+#define IBLND_MSG_GET_DONE	0xd7	/* completion (src->sink: all OK) */
 
 struct kib_rej {
-	u32            ibr_magic;       /* sender's magic */
-	u16            ibr_version;     /* sender's version */
-	u8             ibr_why;         /* reject reason */
-	u8             ibr_padding;     /* padding */
-	u64            ibr_incarnation; /* incarnation of peer_ni */
-	struct kib_connparams ibr_cp;          /* connection parameters */
+	u32			ibr_magic;	/* sender's magic */
+	u16			ibr_version;	/* sender's version */
+	u8			ibr_why;	/* reject reason */
+	u8			ibr_padding;	/* padding */
+	u64			ibr_incarnation;/* incarnation of peer_ni */
+	struct kib_connparams	ibr_cp;		/* connection parameters */
 } __packed;
 
 /* connection rejection reasons */
-#define IBLND_REJECT_CONN_RACE      1 /* You lost connection race */
-#define IBLND_REJECT_NO_RESOURCES   2 /* Out of memory/conns etc */
-#define IBLND_REJECT_FATAL          3 /* Anything else */
-#define IBLND_REJECT_CONN_UNCOMPAT  4 /* incompatible version peer_ni */
-#define IBLND_REJECT_CONN_STALE     5 /* stale peer_ni */
+#define IBLND_REJECT_CONN_RACE		1 /* You lost connection race */
+#define IBLND_REJECT_NO_RESOURCES	2 /* Out of memory/conns etc */
+#define IBLND_REJECT_FATAL		3 /* Anything else */
+#define IBLND_REJECT_CONN_UNCOMPAT	4 /* incompatible version peer_ni */
+#define IBLND_REJECT_CONN_STALE		5 /* stale peer_ni */
 /* peer_ni's rdma frags doesn't match mine */
-#define IBLND_REJECT_RDMA_FRAGS	    6
+#define IBLND_REJECT_RDMA_FRAGS		6
 /* peer_ni's msg queue size doesn't match mine */
-#define IBLND_REJECT_MSG_QUEUE_SIZE 7
-#define IBLND_REJECT_INVALID_SRV_ID 8
+#define IBLND_REJECT_MSG_QUEUE_SIZE	7
+#define IBLND_REJECT_INVALID_SRV_ID	8
 
 /***********************************************************************/
 
 struct kib_rx {					/* receive message */
-	struct list_head       rx_list;       /* queue for attention */
-	struct kib_conn        *rx_conn;      /* owning conn */
-	int                    rx_nob; /* # bytes received (-1 while posted) */
-	enum ib_wc_status      rx_status;     /* completion status */
-	struct kib_msg		*rx_msg;	/* message buffer (host vaddr) */
-	u64                  rx_msgaddr;    /* message buffer (I/O addr) */
-	DEFINE_DMA_UNMAP_ADDR(rx_msgunmap);  /* for dma_unmap_single() */
-	struct ib_recv_wr      rx_wrq;        /* receive work item... */
-	struct ib_sge          rx_sge;        /* ...and its memory */
+	struct list_head	rx_list;	/* queue for attention */
+	struct kib_conn        *rx_conn;	/* owning conn */
+	int			rx_nob;		/* # bytes received (-1 while posted) */
+	enum ib_wc_status	rx_status;	/* completion status */
+	struct kib_msg	       *rx_msg;		/* message buffer (host vaddr) */
+	u64			rx_msgaddr;	/* message buffer (I/O addr) */
+	DEFINE_DMA_UNMAP_ADDR(rx_msgunmap);	/* for dma_unmap_single() */
+	struct ib_recv_wr	rx_wrq;		/* receive work item... */
+	struct ib_sge		rx_sge;		/* ...and its memory */
 };
 
-#define IBLND_POSTRX_DONT_POST    0 /* don't post */
-#define IBLND_POSTRX_NO_CREDIT    1 /* post: no credits */
-#define IBLND_POSTRX_PEER_CREDIT  2 /* post: give peer_ni back 1 credit */
-#define IBLND_POSTRX_RSRVD_CREDIT 3 /* post: give self back 1 reserved credit */
+#define IBLND_POSTRX_DONT_POST		0	/* don't post */
+#define IBLND_POSTRX_NO_CREDIT		1	/* post: no credits */
+#define IBLND_POSTRX_PEER_CREDIT	2	/* post: give peer_ni back 1 credit */
+#define IBLND_POSTRX_RSRVD_CREDIT	3	/* post: give self back 1 reserved credit */
 
 struct kib_tx {					/* transmit message */
-	struct list_head      tx_list; /* queue on idle_txs ibc_tx_queue etc. */
-	struct kib_tx_pool	*tx_pool;	/* pool I'm from */
-	struct kib_conn       *tx_conn;       /* owning conn */
-	short                 tx_sending;     /* # tx callbacks outstanding */
-	short                 tx_queued;      /* queued for sending */
-	short                 tx_waiting;     /* waiting for peer_ni */
-	int                   tx_status;      /* LNET completion status */
+	struct list_head	tx_list;	/* queue on idle_txs ibc_tx_queue etc. */
+	struct kib_tx_pool     *tx_pool;	/* pool I'm from */
+	struct kib_conn	       *tx_conn;	/* owning conn */
+	short			tx_sending;	/* # tx callbacks outstanding */
+	short			tx_queued;	/* queued for sending */
+	short			tx_waiting;	/* waiting for peer_ni */
+	int			tx_status;	/* LNET completion status */
 	ktime_t			tx_deadline;	/* completion deadline */
-	u64                 tx_cookie;      /* completion cookie */
-	struct lnet_msg		*tx_lntmsg[2];	/* lnet msgs to finalize on completion */
-	struct kib_msg	      *tx_msg;        /* message buffer (host vaddr) */
-	u64                 tx_msgaddr;     /* message buffer (I/O addr) */
-	DEFINE_DMA_UNMAP_ADDR(tx_msgunmap);  /* for dma_unmap_single() */
+	u64			tx_cookie;	/* completion cookie */
+	struct lnet_msg	       *tx_lntmsg[2];	/* lnet msgs to finalize on completion */
+	struct kib_msg	       *tx_msg;		/* message buffer (host vaddr) */
+	u64			tx_msgaddr;	/* message buffer (I/O addr) */
+	DEFINE_DMA_UNMAP_ADDR(tx_msgunmap);	/* for dma_unmap_single() */
 	/** sge for tx_msgaddr */
 	struct ib_sge		tx_msgsge;
-	int                   tx_nwrq;        /* # send work items */
+	int			tx_nwrq;	/* # send work items */
 	/* # used scatter/gather elements */
 	int			tx_nsge;
-	struct ib_rdma_wr     *tx_wrq;        /* send work items... */
-	struct ib_sge         *tx_sge;        /* ...and their memory */
-	struct kib_rdma_desc  *tx_rd;         /* rdma descriptor */
-	int                   tx_nfrags;      /* # entries in... */
-	struct scatterlist    *tx_frags;      /* dma_map_sg descriptor */
-	u64                 *tx_pages;      /* rdma phys page addrs */
+	struct ib_rdma_wr      *tx_wrq;		/* send work items... */
+	struct ib_sge	       *tx_sge;		/* ...and their memory */
+	struct kib_rdma_desc   *tx_rd;		/* rdma descriptor */
+	int			tx_nfrags;	/* # entries in... */
+	struct scatterlist     *tx_frags;	/* dma_map_sg descriptor */
+	u64		       *tx_pages;	/* rdma phys page addrs */
 	/* gaps in fragments */
 	bool			tx_gaps;
 	struct kib_fmr		tx_fmr;		/* FMR */
-	int                   tx_dmadir;      /* dma direction */
+	int			tx_dmadir;	/* dma direction */
 };
 
 struct kib_connvars {
-	struct kib_msg cv_msg; /* connection-in-progress variables */
+	struct kib_msg		cv_msg;		/* connection-in-progress variables */
 };
 
 struct kib_conn {
-	struct kib_sched_info *ibc_sched;      /* scheduler information */
-	struct kib_peer_ni       *ibc_peer;       /* owning peer_ni */
-	struct kib_hca_dev         *ibc_hdev;       /* HCA bound on */
-	struct list_head ibc_list;            /* stash on peer_ni's conn list */
-	struct list_head      ibc_sched_list;  /* schedule for attention */
-	u16                 ibc_version;     /* version of connection */
+	struct kib_sched_info  *ibc_sched;	/* scheduler information */
+	struct kib_peer_ni     *ibc_peer;	/* owning peer_ni */
+	struct kib_hca_dev     *ibc_hdev;	/* HCA bound on */
+	struct list_head	ibc_list;	/* stash on peer_ni's conn list */
+	struct list_head	ibc_sched_list;	/* schedule for attention */
+	u16			ibc_version;	/* version of connection */
 	/* reconnect later */
 	u16			ibc_reconnect:1;
-	u64                 ibc_incarnation; /* which instance of the peer_ni */
-	atomic_t              ibc_refcount;    /* # users */
-	int                   ibc_state;       /* what's happening */
-	int                   ibc_nsends_posted; /* # uncompleted sends */
-	int                   ibc_noops_posted;  /* # uncompleted NOOPs */
-	int                   ibc_credits;     /* # credits I have */
-	int                   ibc_outstanding_credits; /* # credits to return */
-	int                   ibc_reserved_credits; /* # ACK/DONE msg credits */
-	int                   ibc_comms_error; /* set on comms error */
+	u64			ibc_incarnation;/* which instance of the peer_ni */
+	atomic_t		ibc_refcount;	/* # users */
+	int			ibc_state;	/* what's happening */
+	int			ibc_nsends_posted;	/* # uncompleted sends */
+	int			ibc_noops_posted;	/* # uncompleted NOOPs */
+	int			ibc_credits;     /* # credits I have */
+	int			ibc_outstanding_credits; /* # credits to return */
+	int			ibc_reserved_credits; /* # ACK/DONE msg credits */
+	int			ibc_comms_error; /* set on comms error */
 	/* connections queue depth */
-	u16		      ibc_queue_depth;
+	u16			ibc_queue_depth;
 	/* connections max frags */
-	u16		      ibc_max_frags;
-	unsigned int          ibc_nrx:16;      /* receive buffers owned */
-	unsigned int          ibc_scheduled:1; /* scheduled for attention */
-	unsigned int          ibc_ready:1;     /* CQ callback fired */
+	u16			ibc_max_frags;
+	unsigned int		ibc_nrx:16;	/* receive buffers owned */
+	unsigned int		ibc_scheduled:1;/* scheduled for attention */
+	unsigned int		ibc_ready:1;	/* CQ callback fired */
 	ktime_t			ibc_last_send;	/* time of last send */
-	struct list_head      ibc_connd_list;  /* link chain for */
-					       /* kiblnd_check_conns only */
-	struct list_head ibc_early_rxs; /* rxs completed before ESTABLISHED */
-	struct list_head ibc_tx_noops;         /* IBLND_MSG_NOOPs for */
-					       /* IBLND_MSG_VERSION_1 */
-	struct list_head ibc_tx_queue;         /* sends that need a credit */
-	struct list_head ibc_tx_queue_nocred;  /* sends that don't need a */
-					       /* credit */
-	struct list_head ibc_tx_queue_rsrvd;   /* sends that need to */
-					       /* reserve an ACK/DONE msg */
-	struct list_head ibc_active_txs; /* active tx awaiting completion */
-	spinlock_t            ibc_lock;        /* serialise */
-	struct kib_rx              *ibc_rxs;        /* the rx descs */
-	struct kib_pages           *ibc_rx_pages;   /* premapped rx msg pages */
-
-	struct rdma_cm_id     *ibc_cmid;       /* CM id */
-	struct ib_cq          *ibc_cq;         /* completion queue */
+	struct list_head	ibc_connd_list;	/* link chain for */
+						/* kiblnd_check_conns only */
+	struct list_head	ibc_early_rxs;	/* rxs completed before ESTABLISHED */
+	struct list_head	ibc_tx_noops;	/* IBLND_MSG_NOOPs for */
+						/* IBLND_MSG_VERSION_1 */
+	struct list_head	ibc_tx_queue;	/* sends that need a credit */
+	struct list_head	ibc_tx_queue_nocred;  /* sends that don't need a */
+						      /* credit */
+	struct list_head	ibc_tx_queue_rsrvd;   /* sends that need to */
+						      /* reserve an ACK/DONE msg */
+	struct list_head	ibc_active_txs;	/* active tx awaiting completion */
+	spinlock_t		ibc_lock;	/* serialise */
+	struct kib_rx		*ibc_rxs;	/* the rx descs */
+	struct kib_pages	*ibc_rx_pages;	/* premapped rx msg pages */
+
+	struct rdma_cm_id	*ibc_cmid;	/* CM id */
+	struct ib_cq		*ibc_cq;	/* completion queue */
 
 	struct kib_connvars	*ibc_connvars;	/* in-progress connection state */
 };
 
-#define IBLND_CONN_INIT           0	 /* being initialised */
-#define IBLND_CONN_ACTIVE_CONNECT 1	 /* active sending req */
-#define IBLND_CONN_PASSIVE_WAIT   2	 /* passive waiting for rtu */
-#define IBLND_CONN_ESTABLISHED    3	 /* connection established */
-#define IBLND_CONN_CLOSING        4	 /* being closed */
-#define IBLND_CONN_DISCONNECTED   5	 /* disconnected */
+#define IBLND_CONN_INIT			0	 /* being initialised */
+#define IBLND_CONN_ACTIVE_CONNECT	1	 /* active sending req */
+#define IBLND_CONN_PASSIVE_WAIT		2	 /* passive waiting for rtu */
+#define IBLND_CONN_ESTABLISHED		3	 /* connection established */
+#define IBLND_CONN_CLOSING		4	 /* being closed */
+#define IBLND_CONN_DISCONNECTED		5	 /* disconnected */
 
 struct kib_peer_ni {
-	struct list_head ibp_list;        /* stash on global peer_ni list */
-	lnet_nid_t       ibp_nid;         /* who's on the other end(s) */
-	struct lnet_ni	*ibp_ni;         /* LNet interface */
-	struct list_head ibp_conns;       /* all active connections */
-	struct kib_conn	*ibp_next_conn;  /* next connection to send on for
-					  * round robin */
-	struct list_head ibp_tx_queue;    /* msgs waiting for a conn */
-	u64            ibp_incarnation; /* incarnation of peer_ni */
+	struct list_head	ibp_list;        /* stash on global peer_ni list */
+	lnet_nid_t		ibp_nid;         /* who's on the other end(s) */
+	struct lnet_ni		*ibp_ni;         /* LNet interface */
+	struct list_head	ibp_conns;       /* all active connections */
+	struct kib_conn		*ibp_next_conn;  /* next connection to send on for
+						  * round robin */
+	struct list_head	ibp_tx_queue;	 /* msgs waiting for a conn */
+	u64			ibp_incarnation; /* incarnation of peer_ni */
 	/* when (in seconds) I was last alive */
 	time64_t		ibp_last_alive;
 	/* # users */
@@ -604,11 +606,11 @@ struct kib_peer_ni {
 	/* # consecutive reconnection attempts to this peer_ni */
 	unsigned int		ibp_reconnected;
 	/* errno on closing this peer_ni */
-	int              ibp_error;
+	int			ibp_error;
 	/* max map_on_demand */
-	u16		 ibp_max_frags;
+	u16			ibp_max_frags;
 	/* max_peer_credits */
-	u16		 ibp_queue_depth;
+	u16			ibp_queue_depth;
 };
 
 extern struct kib_data kiblnd_data;
@@ -647,11 +649,11 @@ struct kib_peer_ni {
 	return dev->ibd_can_failover;
 }
 
-#define kiblnd_conn_addref(conn)				\
-do {							    \
-	CDEBUG(D_NET, "conn[%p] (%d)++\n",		      \
-	       (conn), atomic_read(&(conn)->ibc_refcount)); \
-	atomic_inc(&(conn)->ibc_refcount);		  \
+#define kiblnd_conn_addref(conn)					\
+do {									\
+	CDEBUG(D_NET, "conn[%p] (%d)++\n",				\
+	       (conn), atomic_read(&(conn)->ibc_refcount));		\
+	atomic_inc(&(conn)->ibc_refcount);				\
 } while (0)
 
 #define kiblnd_conn_decref(conn)					\
@@ -665,27 +667,27 @@ struct kib_peer_ni {
 		spin_lock_irqsave(&kiblnd_data.kib_connd_lock, flags);	\
 		list_add_tail(&(conn)->ibc_list,			\
 				  &kiblnd_data.kib_connd_zombies);	\
-		wake_up(&kiblnd_data.kib_connd_waitq);		\
+		wake_up(&kiblnd_data.kib_connd_waitq);			\
 		spin_unlock_irqrestore(&kiblnd_data.kib_connd_lock, flags);\
 	}								\
 } while (0)
 
-#define kiblnd_peer_addref(peer_ni)				\
-do {							    \
-	CDEBUG(D_NET, "peer_ni[%p] -> %s (%d)++\n",		\
-	       (peer_ni), libcfs_nid2str((peer_ni)->ibp_nid),	 \
-	       atomic_read(&(peer_ni)->ibp_refcount));	\
-	atomic_inc(&(peer_ni)->ibp_refcount);		  \
+#define kiblnd_peer_addref(peer_ni)					\
+do {									\
+	CDEBUG(D_NET, "peer_ni[%p] -> %s (%d)++\n",			\
+	       (peer_ni), libcfs_nid2str((peer_ni)->ibp_nid),		\
+	       atomic_read(&(peer_ni)->ibp_refcount));			\
+	atomic_inc(&(peer_ni)->ibp_refcount);				\
 } while (0)
 
-#define kiblnd_peer_decref(peer_ni)				\
-do {							    \
-	CDEBUG(D_NET, "peer_ni[%p] -> %s (%d)--\n",		\
-	       (peer_ni), libcfs_nid2str((peer_ni)->ibp_nid),	 \
-	       atomic_read(&(peer_ni)->ibp_refcount));	\
-	LASSERT_ATOMIC_POS(&(peer_ni)->ibp_refcount);	      \
-	if (atomic_dec_and_test(&(peer_ni)->ibp_refcount))     \
-		kiblnd_destroy_peer(peer_ni);		      \
+#define kiblnd_peer_decref(peer_ni)					\
+do {									\
+	CDEBUG(D_NET, "peer_ni[%p] -> %s (%d)--\n",			\
+	       (peer_ni), libcfs_nid2str((peer_ni)->ibp_nid),		\
+	       atomic_read(&(peer_ni)->ibp_refcount));			\
+	LASSERT_ATOMIC_POS(&(peer_ni)->ibp_refcount);			\
+	if (atomic_dec_and_test(&(peer_ni)->ibp_refcount))		\
+		kiblnd_destroy_peer(peer_ni);				\
 } while (0)
 
 static inline bool
@@ -812,12 +814,12 @@ struct kib_peer_ni {
 /* CAVEAT EMPTOR: We rely on descriptor alignment to allow us to use the */
 /* lowest bits of the work request id to stash the work item type. */
 
-#define IBLND_WID_INVAL	0
-#define IBLND_WID_TX	1
-#define IBLND_WID_RX	2
-#define IBLND_WID_RDMA	3
-#define IBLND_WID_MR	4
-#define IBLND_WID_MASK	7UL
+#define IBLND_WID_INVAL		0
+#define IBLND_WID_TX		1
+#define IBLND_WID_RX		2
+#define IBLND_WID_RDMA		3
+#define IBLND_WID_MR		4
+#define IBLND_WID_MASK		7UL
 
 static inline u64
 kiblnd_ptr2wreqid(void *ptr, int type)
@@ -852,14 +854,14 @@ struct kib_peer_ni {
 kiblnd_init_msg(struct kib_msg *msg, int type, int body_nob)
 {
 	msg->ibm_type = type;
-	msg->ibm_nob  = offsetof(struct kib_msg, ibm_u) + body_nob;
+	msg->ibm_nob = offsetof(struct kib_msg, ibm_u) + body_nob;
 }
 
 static inline int
 kiblnd_rd_size(struct kib_rdma_desc *rd)
 {
-	int   i;
-	int   size;
+	int i;
+	int size;
 
 	for (i = size = 0; i < rd->rd_nfrags; i++)
 		size += rd->rd_frags[i].rf_nob;
@@ -890,7 +892,7 @@ struct kib_peer_ni {
 {
 	if (nob < rd->rd_frags[index].rf_nob) {
 		rd->rd_frags[index].rf_addr += nob;
-		rd->rd_frags[index].rf_nob  -= nob;
+		rd->rd_frags[index].rf_nob -= nob;
 	} else {
 		index++;
 	}
@@ -929,8 +931,8 @@ static inline void kiblnd_dma_unmap_single(struct ib_device *dev,
 	ib_dma_unmap_single(dev, addr, size, direction);
 }
 
-#define KIBLND_UNMAP_ADDR_SET(p, m, a)  do {} while (0)
-#define KIBLND_UNMAP_ADDR(p, m, a)      (a)
+#define KIBLND_UNMAP_ADDR_SET(p, m, a)	do {} while (0)
+#define KIBLND_UNMAP_ADDR(p, m, a)	(a)
 
 static inline int kiblnd_dma_map_sg(struct ib_device *dev,
 				    struct scatterlist *sg, int nents,
@@ -962,34 +964,34 @@ static inline unsigned int kiblnd_sg_dma_len(struct ib_device *dev,
 /* right because OFED1.2 defines it as const, to use it we have to add */
 /* (void *) cast to overcome "const" */
 
-#define KIBLND_CONN_PARAM(e)     ((e)->param.conn.private_data)
-#define KIBLND_CONN_PARAM_LEN(e) ((e)->param.conn.private_data_len)
+#define KIBLND_CONN_PARAM(e)		((e)->param.conn.private_data)
+#define KIBLND_CONN_PARAM_LEN(e)	((e)->param.conn.private_data_len)
 
 void kiblnd_map_rx_descs(struct kib_conn *conn);
 void kiblnd_unmap_rx_descs(struct kib_conn *conn);
 void kiblnd_pool_free_node(struct kib_pool *pool, struct list_head *node);
 struct list_head *kiblnd_pool_alloc_node(struct kib_poolset *ps);
 
-int  kiblnd_fmr_pool_map(struct kib_fmr_poolset *fps, struct kib_tx *tx,
-			 struct kib_rdma_desc *rd, u32 nob, u64 iov,
-			 struct kib_fmr *fmr);
+int kiblnd_fmr_pool_map(struct kib_fmr_poolset *fps, struct kib_tx *tx,
+			struct kib_rdma_desc *rd, u32 nob, u64 iov,
+			struct kib_fmr *fmr);
 void kiblnd_fmr_pool_unmap(struct kib_fmr *fmr, int status);
 
 int kiblnd_tunables_setup(struct lnet_ni *ni);
 void kiblnd_tunables_init(void);
 
-int  kiblnd_connd(void *arg);
-int  kiblnd_scheduler(void *arg);
-int  kiblnd_thread_start(int (*fn)(void *arg), void *arg, char *name);
-int  kiblnd_failover_thread(void *arg);
+int kiblnd_connd(void *arg);
+int kiblnd_scheduler(void *arg);
+int kiblnd_thread_start(int (*fn)(void *arg), void *arg, char *name);
+int kiblnd_failover_thread(void *arg);
 
-int  kiblnd_alloc_pages(struct kib_pages **pp, int cpt, int npages);
+int kiblnd_alloc_pages(struct kib_pages **pp, int cpt, int npages);
 
-int  kiblnd_cm_callback(struct rdma_cm_id *cmid,
-			struct rdma_cm_event *event);
-int  kiblnd_translate_mtu(int value);
+int kiblnd_cm_callback(struct rdma_cm_id *cmid,
+		       struct rdma_cm_event *event);
+int kiblnd_translate_mtu(int value);
 
-int  kiblnd_dev_failover(struct kib_dev *dev);
+int kiblnd_dev_failover(struct kib_dev *dev);
 int kiblnd_create_peer(struct lnet_ni *ni, struct kib_peer_ni **peerp,
 		       lnet_nid_t nid);
 void kiblnd_destroy_peer(struct kib_peer_ni *peer_ni);
@@ -997,9 +999,9 @@ int kiblnd_create_peer(struct lnet_ni *ni, struct kib_peer_ni **peerp,
 void kiblnd_destroy_dev(struct kib_dev *dev);
 void kiblnd_unlink_peer_locked(struct kib_peer_ni *peer_ni);
 struct kib_peer_ni *kiblnd_find_peer_locked(struct lnet_ni *ni, lnet_nid_t nid);
-int  kiblnd_close_stale_conns_locked(struct kib_peer_ni *peer_ni,
-				     int version, u64 incarnation);
-int  kiblnd_close_peer_conns_locked(struct kib_peer_ni *peer_ni, int why);
+int kiblnd_close_stale_conns_locked(struct kib_peer_ni *peer_ni,
+				    int version, u64 incarnation);
+int kiblnd_close_peer_conns_locked(struct kib_peer_ni *peer_ni, int why);
 
 struct kib_conn *kiblnd_create_conn(struct kib_peer_ni *peer_ni,
 				    struct rdma_cm_id *cmid,
@@ -1017,8 +1019,8 @@ struct kib_conn *kiblnd_create_conn(struct kib_peer_ni *peer_ni,
 
 void kiblnd_pack_msg(struct lnet_ni *ni, struct kib_msg *msg, int version,
 		     int credits, lnet_nid_t dstnid, u64 dststamp);
-int  kiblnd_unpack_msg(struct kib_msg *msg, int nob);
-int  kiblnd_post_rx(struct kib_rx *rx, int credit);
+int kiblnd_unpack_msg(struct kib_msg *msg, int nob);
+int kiblnd_post_rx(struct kib_rx *rx, int credit);
 
 int kiblnd_send(struct lnet_ni *ni, void *private, struct lnet_msg *lntmsg);
 int kiblnd_recv(struct lnet_ni *ni, void *private, struct lnet_msg *lntmsg,
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
index 48f2814..ad17260 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -167,14 +167,14 @@ static int kiblnd_init_rdma(struct kib_conn *conn, struct kib_tx *tx, int type,
 		credit == IBLND_POSTRX_PEER_CREDIT ||
 		credit == IBLND_POSTRX_RSRVD_CREDIT);
 
-	rx->rx_sge.lkey   = conn->ibc_hdev->ibh_pd->local_dma_lkey;
-	rx->rx_sge.addr   = rx->rx_msgaddr;
+	rx->rx_sge.lkey = conn->ibc_hdev->ibh_pd->local_dma_lkey;
+	rx->rx_sge.addr = rx->rx_msgaddr;
 	rx->rx_sge.length = IBLND_MSG_SIZE;
 
-	rx->rx_wrq.next    = NULL;
+	rx->rx_wrq.next = NULL;
 	rx->rx_wrq.sg_list = &rx->rx_sge;
 	rx->rx_wrq.num_sge = 1;
-	rx->rx_wrq.wr_id   = kiblnd_ptr2wreqid(rx, IBLND_WID_RX);
+	rx->rx_wrq.wr_id = kiblnd_ptr2wreqid(rx, IBLND_WID_RX);
 
 	LASSERT(conn->ibc_state >= IBLND_CONN_INIT);
 	LASSERT(rx->rx_nob >= 0);	      /* not posted */
@@ -528,10 +528,10 @@ static int kiblnd_init_rdma(struct kib_conn *conn, struct kib_tx *tx, int type,
 	kiblnd_handle_rx(rx);
 	return;
 
- failed:
+failed:
 	CDEBUG(D_NET, "rx %p conn %p\n", rx, conn);
 	kiblnd_close_conn(conn, err);
- ignore:
+ignore:
 	kiblnd_drop_rx(rx);		     /* Don't re-post rx. */
 }
 
@@ -1068,17 +1068,17 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 
 	kiblnd_init_msg(tx->tx_msg, type, body_nob);
 
-	sge->lkey   = hdev->ibh_pd->local_dma_lkey;
-	sge->addr   = tx->tx_msgaddr;
+	sge->lkey = hdev->ibh_pd->local_dma_lkey;
+	sge->addr = tx->tx_msgaddr;
 	sge->length = nob;
 
 	memset(wrq, 0, sizeof(*wrq));
 
-	wrq->wr.next       = NULL;
-	wrq->wr.wr_id      = kiblnd_ptr2wreqid(tx, IBLND_WID_TX);
-	wrq->wr.sg_list    = sge;
-	wrq->wr.num_sge    = 1;
-	wrq->wr.opcode     = IB_WR_SEND;
+	wrq->wr.next = NULL;
+	wrq->wr.wr_id = kiblnd_ptr2wreqid(tx, IBLND_WID_TX);
+	wrq->wr.sg_list = sge;
+	wrq->wr.num_sge = 1;
+	wrq->wr.opcode = IB_WR_SEND;
 	wrq->wr.send_flags = IB_SEND_SIGNALED;
 
 	tx->tx_nwrq++;
@@ -1133,8 +1133,8 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 			       (u32)resid);
 
 		sge = &tx->tx_sge[tx->tx_nsge];
-		sge->addr   = kiblnd_rd_frag_addr(srcrd, srcidx);
-		sge->lkey   = kiblnd_rd_frag_key(srcrd, srcidx);
+		sge->addr = kiblnd_rd_frag_addr(srcrd, srcidx);
+		sge->lkey = kiblnd_rd_frag_key(srcrd, srcidx);
 		sge->length = sge_nob;
 
 		if (wrq_sge == 0) {
@@ -1329,12 +1329,12 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
 
 	return;
 
- failed2:
+failed2:
 	kiblnd_peer_connect_failed(peer_ni, 1, rc);
 	kiblnd_peer_decref(peer_ni);	       /* cmid's ref */
 	rdma_destroy_id(cmid);
 	return;
- failed:
+failed:
 	kiblnd_peer_connect_failed(peer_ni, 1, rc);
 }
 
@@ -1397,7 +1397,7 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
 	rwlock_t *g_lock = &kiblnd_data.kib_global_lock;
 	unsigned long flags;
 	int rc;
-	int		   i;
+	int i;
 	struct lnet_ioctl_config_o2iblnd_tunables *tunables;
 
 	/*
@@ -1529,7 +1529,7 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
 	unsigned int payload_nob = lntmsg->msg_len;
 	struct iov_iter from;
 	struct kib_msg *ibmsg;
-	struct kib_rdma_desc  *rd;
+	struct kib_rdma_desc *rd;
 	struct kib_tx *tx;
 	int nob;
 	int rc;
@@ -1747,9 +1747,9 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
 	kiblnd_queue_tx(tx, rx->rx_conn);
 	return;
 
- failed_1:
+failed_1:
 	kiblnd_tx_done(tx);
- failed_0:
+failed_0:
 	lnet_finalize(lntmsg, -EIO);
 }
 
@@ -1797,7 +1797,7 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
 
 	case IBLND_MSG_PUT_REQ: {
 		u64 ibprm_cookie = rxmsg->ibm_u.putreq.ibprm_cookie;
-		struct kib_msg	*txmsg;
+		struct kib_msg *txmsg;
 		struct kib_rdma_desc *rd;
 
 		if (!iov_iter_count(to)) {
@@ -2193,15 +2193,15 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
 		peer_ni->ibp_accepting--;
 
 	if (!peer_ni->ibp_version) {
-		peer_ni->ibp_version     = conn->ibc_version;
+		peer_ni->ibp_version = conn->ibc_version;
 		peer_ni->ibp_incarnation = conn->ibc_incarnation;
 	}
 
-	if (peer_ni->ibp_version     != conn->ibc_version ||
+	if (peer_ni->ibp_version != conn->ibc_version ||
 	    peer_ni->ibp_incarnation != conn->ibc_incarnation) {
 		kiblnd_close_stale_conns_locked(peer_ni, conn->ibc_version,
 						conn->ibc_incarnation);
-		peer_ni->ibp_version     = conn->ibc_version;
+		peer_ni->ibp_version = conn->ibc_version;
 		peer_ni->ibp_incarnation = conn->ibc_incarnation;
 	}
 
@@ -2431,13 +2431,13 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
 	peer2 = kiblnd_find_peer_locked(ni, nid);
 	if (peer2) {
 		if (!peer2->ibp_version) {
-			peer2->ibp_version     = version;
+			peer2->ibp_version = version;
 			peer2->ibp_incarnation = reqmsg->ibm_srcstamp;
 		}
 
 		/* not the guy I've talked with */
 		if (peer2->ibp_incarnation != reqmsg->ibm_srcstamp ||
-		    peer2->ibp_version     != version) {
+		    peer2->ibp_version != version) {
 			kiblnd_close_peer_conns_locked(peer2, -ESTALE);
 
 			if (kiblnd_peer_active(peer2)) {
@@ -2506,8 +2506,8 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
 		LASSERT(!peer_ni->ibp_version &&
 			!peer_ni->ibp_incarnation);
 
-		peer_ni->ibp_accepting   = 1;
-		peer_ni->ibp_version     = version;
+		peer_ni->ibp_accepting = 1;
+		peer_ni->ibp_version = version;
 		peer_ni->ibp_incarnation = reqmsg->ibm_srcstamp;
 
 		/* I have a ref on ni that prevents it being shutdown */
@@ -2532,8 +2532,8 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
 	 * conn now "owns" cmid, so I return success from here on to ensure the
 	 * CM callback doesn't destroy cmid.
 	 */
-	conn->ibc_incarnation      = reqmsg->ibm_srcstamp;
-	conn->ibc_credits          = conn->ibc_queue_depth;
+	conn->ibc_incarnation = reqmsg->ibm_srcstamp;
+	conn->ibc_credits = conn->ibc_queue_depth;
 	conn->ibc_reserved_credits = conn->ibc_queue_depth;
 	LASSERT(conn->ibc_credits + conn->ibc_reserved_credits +
 		IBLND_OOB_MSGS(version) <= IBLND_RX_MSGS(conn));
@@ -2564,7 +2564,7 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
 	if (rc) {
 		CERROR("Can't accept %s: %d\n", libcfs_nid2str(nid), rc);
 		rej.ibr_version = version;
-		rej.ibr_why     = IBLND_REJECT_FATAL;
+		rej.ibr_why = IBLND_REJECT_FATAL;
 
 		kiblnd_reject(cmid, &rej);
 		kiblnd_connreq_done(conn, rc);
@@ -2574,14 +2574,14 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
 	lnet_ni_decref(ni);
 	return 0;
 
- failed:
+failed:
 	if (ni) {
 		rej.ibr_cp.ibcp_queue_depth = kiblnd_msg_queue_size(version, ni);
 		rej.ibr_cp.ibcp_max_frags = IBLND_MAX_RDMA_FRAGS;
 		lnet_ni_decref(ni);
 	}
 
-	rej.ibr_version             = version;
+	rej.ibr_version = version;
 	kiblnd_reject(cmid, &rej);
 
 	return -ECONNREFUSED;
@@ -2789,7 +2789,7 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
 				break;
 			}
 
-			if (rej->ibr_why     == IBLND_REJECT_FATAL &&
+			if (rej->ibr_why == IBLND_REJECT_FATAL &&
 			    rej->ibr_version == IBLND_MSG_VERSION_1) {
 				CDEBUG(D_NET,
 				       "rejected by old version peer_ni %s: %x\n",
@@ -2927,7 +2927,7 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
 	kiblnd_connreq_done(conn, 0);
 	return;
 
- failed:
+failed:
 	/*
 	 * NB My QP has already established itself, so I handle anything going
 	 * wrong here by setting ibc_comms_error.
@@ -2985,12 +2985,12 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
 
 	memset(&cp, 0, sizeof(cp));
 	cp.private_data	= msg;
-	cp.private_data_len    = msg->ibm_nob;
+	cp.private_data_len = msg->ibm_nob;
 	cp.responder_resources = 0;	     /* No atomic ops or RDMA reads */
-	cp.initiator_depth     = 0;
-	cp.flow_control        = 1;
-	cp.retry_count         = *kiblnd_tunables.kib_retry_count;
-	cp.rnr_retry_count     = *kiblnd_tunables.kib_rnr_retry_count;
+	cp.initiator_depth = 0;
+	cp.flow_control = 1;
+	cp.retry_count = *kiblnd_tunables.kib_retry_count;
+	cp.rnr_retry_count = *kiblnd_tunables.kib_rnr_retry_count;
 
 	LASSERT(cmid->context == (void *)conn);
 	LASSERT(conn->ibc_cmid == cmid);
@@ -3217,11 +3217,11 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
 static int
 kiblnd_conn_timed_out_locked(struct kib_conn *conn)
 {
-	return  kiblnd_check_txs_locked(conn, &conn->ibc_tx_queue) ||
-		kiblnd_check_txs_locked(conn, &conn->ibc_tx_noops) ||
-		kiblnd_check_txs_locked(conn, &conn->ibc_tx_queue_rsrvd) ||
-		kiblnd_check_txs_locked(conn, &conn->ibc_tx_queue_nocred) ||
-		kiblnd_check_txs_locked(conn, &conn->ibc_active_txs);
+	return kiblnd_check_txs_locked(conn, &conn->ibc_tx_queue) ||
+	       kiblnd_check_txs_locked(conn, &conn->ibc_tx_noops) ||
+	       kiblnd_check_txs_locked(conn, &conn->ibc_tx_queue_rsrvd) ||
+	       kiblnd_check_txs_locked(conn, &conn->ibc_tx_queue_nocred) ||
+	       kiblnd_check_txs_locked(conn, &conn->ibc_active_txs);
 }
 
 static void
@@ -3561,9 +3561,9 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
 {
 	/*
 	 * NB I'm not allowed to schedule this conn once its refcount has
-	 * reached 0.  Since fundamentally I'm racing with scheduler threads
+	 * reached 0. Since fundamentally I'm racing with scheduler threads
 	 * consuming my CQ I could be called after all completions have
-	 * occurred.  But in this case, !ibc_nrx && !ibc_nsends_posted
+	 * occurred. But in this case, !ibc_nrx && !ibc_nsends_posted
 	 * and this CQ is about to be destroyed so I NOOP.
 	 */
 	struct kib_conn *conn = arg;
@@ -3793,8 +3793,7 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
 		add_wait_queue(&kiblnd_data.kib_failover_waitq, &wait);
 		write_unlock_irqrestore(glock, flags);
 
-		rc = schedule_timeout(long_sleep ? 10 * HZ :
-						   HZ);
+		rc = schedule_timeout(long_sleep ? 10 * HZ : HZ);
 		remove_wait_queue(&kiblnd_data.kib_failover_waitq, &wait);
 		write_lock_irqsave(glock, flags);
 
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_modparams.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_modparams.c
index 47e8a60..9fb1357 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_modparams.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_modparams.c
@@ -183,17 +183,17 @@
 MODULE_PARM_DESC(wrq_sge, "# scatter/gather element per work request");
 
 struct kib_tunables kiblnd_tunables = {
-	.kib_dev_failover      = &dev_failover,
-	.kib_service           = &service,
-	.kib_cksum             = &cksum,
-	.kib_timeout           = &timeout,
-	.kib_keepalive         = &keepalive,
-	.kib_default_ipif      = &ipif_name,
-	.kib_retry_count       = &retry_count,
-	.kib_rnr_retry_count   = &rnr_retry_count,
-	.kib_ib_mtu            = &ib_mtu,
-	.kib_require_priv_port = &require_privileged_port,
-	.kib_use_priv_port     = &use_privileged_port,
+	.kib_dev_failover	= &dev_failover,
+	.kib_service		= &service,
+	.kib_cksum		= &cksum,
+	.kib_timeout		= &timeout,
+	.kib_keepalive		= &keepalive,
+	.kib_default_ipif	= &ipif_name,
+	.kib_retry_count	= &retry_count,
+	.kib_rnr_retry_count	= &rnr_retry_count,
+	.kib_ib_mtu		= &ib_mtu,
+	.kib_require_priv_port	= &require_privileged_port,
+	.kib_use_priv_port	= &use_privileged_port,
 	.kib_nscheds		= &nscheds,
 	.kib_wrq_sge		= &wrq_sge,
 	.kib_use_fastreg_gaps	= &use_fastreg_gaps,
-- 
1.8.3.1
