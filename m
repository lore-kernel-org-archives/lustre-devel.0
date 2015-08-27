From: Simmons, James A. <simmonsja@ornl.gov>
Date: Thu, 27 Aug 2015 18:16:31 +0000
Subject: [lustre-devel] [PATCH v2] staging/lustre: fix block
	comment	formatting
In-Reply-To: <1440440898-49055-1-git-send-email-Jeffrey.C.Becker@nasa.gov>
References: <1440440898-49055-1-git-send-email-Jeffrey.C.Becker@nasa.gov>
Message-ID: <188827c902704a95bc479702f4454e40@EXCHCS32.ornl.gov>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

>Running checkpatch.pl on lnet/klnds/o2iblnd/o2iblnd.h produces several
>"Block comments use a trailing */ on a separate line" warnings. This patch
>fixes these.
>
>Signed-off-by: Jeff Becker <Jeffrey.C.Becker@nasa.gov>
>---
> .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h    | 284 +++++++++------------
> 1 file changed, 127 insertions(+), 157 deletions(-)

This original was done to avoid the 80 character limit with comments. I remember
the discuss to make checkpatch.pl not complain in that case. Was that ever implemented?
If so this patch could neatly tab the comments to make them line up. That would make it
easier on the eyes.  If that is not the case this patch is fine as it is.

diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
index f4b6c33..07e81cb 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
@@ -79,38 +79,33 @@
 #define IBLND_N_SCHED_HIGH		4
 
 typedef struct {
-	int          *kib_dev_failover;      /* HCA failover */
-	unsigned int *kib_service;           /* IB service number */
-	int          *kib_min_reconnect_interval; /* first failed connection
-						   * retry... */
-	int          *kib_max_reconnect_interval; /* ...exponentially increasing
-						   * to this */
-	int          *kib_cksum;             /* checksum kib_msg_t? */
-	int          *kib_timeout;           /* comms timeout (seconds) */
-	int          *kib_keepalive;         /* keepalive timeout (seconds) */
-	int          *kib_ntx;               /* # tx descs */
-	int          *kib_credits;           /* # concurrent sends */
-	int          *kib_peertxcredits;     /* # concurrent sends to 1 peer */
-	int          *kib_peerrtrcredits;    /* # per-peer router buffer
-					      * credits */
-	int          *kib_peercredits_hiw;   /* # when eagerly to return
-					      * credits */
-	int          *kib_peertimeout;       /* seconds to consider peer dead */
-	char         **kib_default_ipif;     /* default IPoIB interface */
-	int          *kib_retry_count;
-	int          *kib_rnr_retry_count;
-	int          *kib_concurrent_sends;  /* send work queue sizing */
-	int          *kib_ib_mtu;            /* IB MTU */
-	int          *kib_map_on_demand;     /* map-on-demand if RD has more
-					      * fragments than this value, 0
-					      * disable map-on-demand */
-	int          *kib_fmr_pool_size;     /* # FMRs in pool */
-	int          *kib_fmr_flush_trigger; /* When to trigger FMR flush */
-	int          *kib_fmr_cache;         /* enable FMR pool cache? */
-	int          *kib_require_priv_port; /* accept only privileged ports */
-	int          *kib_use_priv_port;     /* use privileged port for active
-					      * connect */
-	int          *kib_nscheds;           /* # threads on each CPT */
+	int *kib_dev_failover;           /* HCA failover */
+	unsigned int *kib_service;       /* IB service number */
+	int *kib_min_reconnect_interval; /* first failed connection retry... */
+	int *kib_max_reconnect_interval; /* exponentially increasing to this */
+	int *kib_cksum;                  /* checksum kib_msg_t? */
+	int *kib_timeout;                /* comms timeout (seconds) */
+	int *kib_keepalive;              /* keepalive timeout (seconds) */
+	int *kib_ntx;                    /* # tx descs */
+	int *kib_credits;                /* # concurrent sends */
+	int *kib_peertxcredits;          /* # concurrent sends to 1 peer */
+	int *kib_peerrtrcredits;         /* # per-peer router buffer credits */
+	int *kib_peercredits_hiw;        /* # when eagerly to return credits */
+	int *kib_peertimeout;            /* seconds to consider peer dead */
+	char **kib_default_ipif;         /* default IPoIB interface */
+	int *kib_retry_count;
+	int *kib_rnr_retry_count;
+	int *kib_concurrent_sends;       /* send work queue sizing */
+	int *kib_ib_mtu;                 /* IB MTU */
+	int *kib_map_on_demand;          /* map-on-demand if RD has more */
+					 /* fragments than this value, 0 */
+					 /* disable map-on-demand */
+	int *kib_fmr_pool_size;          /* # FMRs in pool */
+	int *kib_fmr_flush_trigger;      /* When to trigger FMR flush */
+	int *kib_fmr_cache;              /* enable FMR pool cache? */
+	int *kib_require_priv_port;      /* accept only privileged ports */
+	int *kib_use_priv_port; /* use privileged port for active connect */
+	int *kib_nscheds;                /* # threads on each CPT */
 } kib_tunables_t;
 
 extern kib_tunables_t  kiblnd_tunables;
@@ -199,8 +194,7 @@ typedef struct {
 	unsigned long      ibd_next_failover;
 	int                ibd_failed_failover; /* # failover failures */
 	unsigned int       ibd_failover;        /* failover in progress */
-	unsigned int       ibd_can_failover;    /* IPoIB interface is a bonding
-						 * master */
+	unsigned int ibd_can_failover; /* IPoIB interface is a bonding master */
 	struct list_head   ibd_nets;
 	struct kib_hca_dev *ibd_hdev;
 } kib_dev_t;
@@ -249,28 +243,26 @@ typedef struct kib_poolset {
 	char                  ps_name[IBLND_POOL_NAME_LEN]; /* pool set name */
 	struct list_head      ps_pool_list;       /* list of pools */
 	struct list_head      ps_failed_pool_list;/* failed pool list */
-	unsigned long         ps_next_retry;      /* time stamp for retry if
-						   * failed to allocate */
+	unsigned long         ps_next_retry;      /* time stamp for retry if */
+						  /* failed to allocate */
 	int                   ps_increasing;      /* is allocating new pool */
 	int                   ps_pool_size;       /* new pool size */
 	int                   ps_cpt;             /* CPT id */
 
 	kib_ps_pool_create_t  ps_pool_create;     /* create a new pool */
 	kib_ps_pool_destroy_t ps_pool_destroy;    /* destroy a pool */
-	kib_ps_node_init_t    ps_node_init;       /* initialize new allocated
-						   * node */
+	kib_ps_node_init_t    ps_node_init; /* initialize new allocated node */
 	kib_ps_node_fini_t    ps_node_fini;       /* finalize node */
 } kib_poolset_t;
 
 typedef struct kib_pool {
-	struct list_head      po_list;         /* chain on pool list */
-	struct list_head      po_free_list;    /* pre-allocated node */
-	kib_poolset_t         *po_owner;       /* pool_set of this pool */
-	unsigned long         po_deadline;     /* deadline of this pool */
-	int                   po_allocated;    /* # of elements in use */
-	int                   po_failed;       /* pool is created on failed
-						* HCA */
-	int                   po_size;         /* # of pre-allocated elements */
+	struct list_head      po_list;       /* chain on pool list */
+	struct list_head      po_free_list;  /* pre-allocated node */
+	kib_poolset_t         *po_owner;     /* pool_set of this pool */
+	unsigned long         po_deadline;   /* deadline of this pool */
+	int                   po_allocated;  /* # of elements in use */
+	int                   po_failed;     /* pool is created on failed HCA */
+	int                   po_size;       /* # of pre-allocated elements */
 } kib_pool_t;
 
 typedef struct {
@@ -295,8 +287,8 @@ typedef struct {
 	int                   fps_pool_size;
 	int                   fps_flush_trigger;
 	int                   fps_increasing;      /* is allocating new pool */
-	unsigned long         fps_next_retry;      /* time stamp for retry if
-						    * failed to allocate */
+	unsigned long         fps_next_retry;      /* time stamp for retry if*/
+						   /* failed to allocate */
 } kib_fmr_poolset_t;
 
 typedef struct {
@@ -344,31 +336,22 @@ struct kib_sched_info {
 };
 
 typedef struct {
-	int                   kib_init;           /* initialisation state */
-	int                   kib_shutdown;       /* shut down? */
-	struct list_head      kib_devs;           /* IB devices extant */
-	struct list_head      kib_failed_devs;    /* list head of failed
-						   * devices */
-	wait_queue_head_t     kib_failover_waitq; /* schedulers sleep here */
-	atomic_t              kib_nthreads;       /* # live threads */
-	rwlock_t              kib_global_lock;    /* stabilize net/dev/peer/conn
-						   * ops */
-	struct list_head      *kib_peers;         /* hash table of all my known
-						   * peers */
-	int                   kib_peer_hash_size; /* size of kib_peers */
-	void                  *kib_connd;         /* the connd task
-						   * (serialisation assertions)
-						   */
-	struct list_head      kib_connd_conns;    /* connections to
-						   * setup/teardown */
-	struct list_head      kib_connd_zombies;  /* connections with zero
-						   * refcount */
-	wait_queue_head_t     kib_connd_waitq;    /* connection daemon sleeps
-						   * here */
-	spinlock_t            kib_connd_lock;     /* serialise */
-	struct ib_qp_attr     kib_error_qpa;      /* QP->ERROR */
-	struct kib_sched_info **kib_scheds;       /* percpt data for schedulers
-						   */
+	int               kib_init;           /* initialisation state */
+	int               kib_shutdown;       /* shut down? */
+	struct list_head  kib_devs;           /* IB devices extant */
+	struct list_head  kib_failed_devs;    /* list head of failed devices */
+	wait_queue_head_t kib_failover_waitq; /* schedulers sleep here */
+	atomic_t kib_nthreads;                /* # live threads */
+	rwlock_t kib_global_lock;    /* stabilize net/dev/peer/conn ops */
+	struct list_head *kib_peers; /* hash table of all my known peers */
+	int  kib_peer_hash_size;     /* size of kib_peers */
+	void *kib_connd; /* the connd task (serialisation assertions) */
+	struct list_head kib_connd_conns;   /* connections to setup/teardown */
+	struct list_head kib_connd_zombies; /* connections with zero refcount */
+	wait_queue_head_t kib_connd_waitq;  /* connection daemon sleeps here */
+	spinlock_t kib_connd_lock;          /* serialise */
+	struct ib_qp_attr kib_error_qpa;    /* QP->ERROR */
+	struct kib_sched_info **kib_scheds; /* percpt data for schedulers */
 } kib_data_t;
 
 #define IBLND_INIT_NOTHING 0
@@ -480,10 +463,10 @@ typedef struct {
 #define IBLND_REJECT_FATAL          3 /* Anything else */
 #define IBLND_REJECT_CONN_UNCOMPAT  4 /* incompatible version peer */
 #define IBLND_REJECT_CONN_STALE     5 /* stale peer */
-#define IBLND_REJECT_RDMA_FRAGS     6 /* Fatal: peer's rdma frags can't match
-				       * mine */
-#define IBLND_REJECT_MSG_QUEUE_SIZE 7 /* Fatal: peer's msg queue size can't
-				       * match mine */
+#define IBLND_REJECT_RDMA_FRAGS     6 /* Fatal: peer's rdma frags can't match */
+				      /* mine */
+#define IBLND_REJECT_MSG_QUEUE_SIZE 7 /* Fatal: peer's msg queue size can't */
+				      /* match mine */
 
 /***********************************************************************/
 
@@ -491,8 +474,7 @@ typedef struct kib_rx                         /* receive message */
 {
 	struct list_head       rx_list;       /* queue for attention */
 	struct kib_conn        *rx_conn;      /* owning conn */
-	int                    rx_nob;        /* # bytes received (-1 while
-					       * posted) */
+	int                    rx_nob; /* # bytes received (-1 while posted) */
 	enum ib_wc_status      rx_status;     /* completion status */
 	kib_msg_t              *rx_msg;       /* message buffer (host vaddr) */
 	__u64                  rx_msgaddr;    /* message buffer (I/O addr) */
@@ -501,38 +483,35 @@ typedef struct kib_rx                         /* receive message */
 	struct ib_sge          rx_sge;        /* ...and its memory */
 } kib_rx_t;
 
-#define IBLND_POSTRX_DONT_POST    0   /* don't post */
-#define IBLND_POSTRX_NO_CREDIT    1   /* post: no credits */
-#define IBLND_POSTRX_PEER_CREDIT  2   /* post: give peer back 1 credit */
-#define IBLND_POSTRX_RSRVD_CREDIT 3   /* post: give myself back 1 reserved
-				       * credit */
+#define IBLND_POSTRX_DONT_POST    0 /* don't post */
+#define IBLND_POSTRX_NO_CREDIT    1 /* post: no credits */
+#define IBLND_POSTRX_PEER_CREDIT  2 /* post: give peer back 1 credit */
+#define IBLND_POSTRX_RSRVD_CREDIT 3 /* post: give self back 1 reserved credit */
 
 typedef struct kib_tx                         /* transmit message */
 {
-	struct list_head       tx_list;       /* queue on idle_txs ibc_tx_queue
-					       * etc. */
-	kib_tx_pool_t          *tx_pool;      /* pool I'm from */
-	struct kib_conn        *tx_conn;      /* owning conn */
-	short                  tx_sending;    /* # tx callbacks outstanding */
-	short                  tx_queued;     /* queued for sending */
-	short                  tx_waiting;    /* waiting for peer */
-	int                    tx_status;     /* LNET completion status */
-	unsigned long          tx_deadline;   /* completion deadline */
-	__u64                  tx_cookie;     /* completion cookie */
-	lnet_msg_t             *tx_lntmsg[2]; /* lnet msgs to finalize on
-					       * completion */
-	kib_msg_t              *tx_msg;       /* message buffer (host vaddr) */
-	__u64                  tx_msgaddr;    /* message buffer (I/O addr) */
+	struct list_head      tx_list; /* queue on idle_txs ibc_tx_queue etc. */
+	kib_tx_pool_t         *tx_pool;       /* pool I'm from */
+	struct kib_conn       *tx_conn;       /* owning conn */
+	short                 tx_sending;     /* # tx callbacks outstanding */
+	short                 tx_queued;      /* queued for sending */
+	short                 tx_waiting;     /* waiting for peer */
+	int                   tx_status;      /* LNET completion status */
+	unsigned long         tx_deadline;    /* completion deadline */
+	__u64                 tx_cookie;      /* completion cookie */
+	lnet_msg_t *tx_lntmsg[2]; /* lnet msgs to finalize on completion */
+	kib_msg_t             *tx_msg;        /* message buffer (host vaddr) */
+	__u64                 tx_msgaddr;     /* message buffer (I/O addr) */
 	DECLARE_PCI_UNMAP_ADDR(tx_msgunmap);  /* for dma_unmap_single() */
-	int                    tx_nwrq;       /* # send work items */
-	struct ib_send_wr      *tx_wrq;       /* send work items... */
-	struct ib_sge          *tx_sge;       /* ...and their memory */
-	kib_rdma_desc_t        *tx_rd;        /* rdma descriptor */
-	int                    tx_nfrags;     /* # entries in... */
-	struct scatterlist     *tx_frags;     /* dma_map_sg descriptor */
-	__u64                  *tx_pages;     /* rdma phys page addrs */
-	kib_fmr_t		fmr;	      /* FMR */
-	int                    tx_dmadir;     /* dma direction */
+	int                   tx_nwrq;        /* # send work items */
+	struct ib_send_wr     *tx_wrq;        /* send work items... */
+	struct ib_sge         *tx_sge;        /* ...and their memory */
+	kib_rdma_desc_t       *tx_rd;         /* rdma descriptor */
+	int                   tx_nfrags;      /* # entries in... */
+	struct scatterlist    *tx_frags;      /* dma_map_sg descriptor */
+	__u64                 *tx_pages;      /* rdma phys page addrs */
+	kib_fmr_t             fmr;	      /* FMR */
+	int                   tx_dmadir;      /* dma direction */
 } kib_tx_t;
 
 typedef struct kib_connvars {
@@ -540,53 +519,44 @@ typedef struct kib_connvars {
 } kib_connvars_t;
 
 typedef struct kib_conn {
-	struct kib_sched_info *ibc_sched;           /* scheduler information */
-	struct kib_peer       *ibc_peer;            /* owning peer */
-	kib_hca_dev_t         *ibc_hdev;            /* HCA bound on */
-	struct list_head      ibc_list;             /* stash on peer's conn
-						     * list */
-	struct list_head      ibc_sched_list;       /* schedule for attention */
-	__u16                 ibc_version;          /* version of connection */
-	__u64                 ibc_incarnation;      /* which instance of the
-						     * peer */
-	atomic_t              ibc_refcount;         /* # users */
-	int                   ibc_state;            /* what's happening */
-	int                   ibc_nsends_posted;    /* # uncompleted sends */
-	int                   ibc_noops_posted;     /* # uncompleted NOOPs */
-	int                   ibc_credits;          /* # credits I have */
+	struct kib_sched_info *ibc_sched;      /* scheduler information */
+	struct kib_peer       *ibc_peer;       /* owning peer */
+	kib_hca_dev_t         *ibc_hdev;       /* HCA bound on */
+	struct list_head ibc_list;             /* stash on peer's conn list */
+	struct list_head      ibc_sched_list;  /* schedule for attention */
+	__u16                 ibc_version;     /* version of connection */
+	__u64                 ibc_incarnation; /* which instance of the peer */
+	atomic_t              ibc_refcount;    /* # users */
+	int                   ibc_state;       /* what's happening */
+	int                   ibc_nsends_posted; /* # uncompleted sends */
+	int                   ibc_noops_posted;  /* # uncompleted NOOPs */
+	int                   ibc_credits;     /* # credits I have */
 	int                   ibc_outstanding_credits; /* # credits to return */
 	int                   ibc_reserved_credits; /* # ACK/DONE msg credits */
-	int                   ibc_comms_error;      /* set on comms error */
-	unsigned int          ibc_nrx:16;           /* receive buffers owned */
-	unsigned int          ibc_scheduled:1;      /* scheduled for attention
-						     */
-	unsigned int          ibc_ready:1;          /* CQ callback fired */
-	unsigned long         ibc_last_send;        /* time of last send */
-	struct list_head      ibc_connd_list;       /* link chain for
-						     * kiblnd_check_conns only
-						     */
-	struct list_head      ibc_early_rxs;        /* rxs completed before
-						     * ESTABLISHED */
-	struct list_head      ibc_tx_noops;         /* IBLND_MSG_NOOPs for
-						     * IBLND_MSG_VERSION_1 */
-	struct list_head      ibc_tx_queue;         /* sends that need a credit
-						     */
-	struct list_head      ibc_tx_queue_nocred;  /* sends that don't need a
-						     * credit */
-	struct list_head      ibc_tx_queue_rsrvd;   /* sends that need to
-						     * reserve an ACK/DONE msg
-						     */
-	struct list_head      ibc_active_txs;       /* active tx awaiting
-						     * completion */
-	spinlock_t            ibc_lock;             /* serialise */
-	kib_rx_t              *ibc_rxs;             /* the rx descs */
-	kib_pages_t           *ibc_rx_pages;        /* premapped rx msg pages */
-
-	struct rdma_cm_id     *ibc_cmid;            /* CM id */
-	struct ib_cq          *ibc_cq;              /* completion queue */
-
-	kib_connvars_t        *ibc_connvars;        /* in-progress connection
-						     * state */
+	int                   ibc_comms_error; /* set on comms error */
+	unsigned int          ibc_nrx:16;      /* receive buffers owned */
+	unsigned int          ibc_scheduled:1; /* scheduled for attention */
+	unsigned int          ibc_ready:1;     /* CQ callback fired */
+	unsigned long         ibc_last_send;   /* time of last send */
+	struct list_head      ibc_connd_list;  /* link chain for */
+					       /* kiblnd_check_conns only */
+	struct list_head ibc_early_rxs; /* rxs completed before ESTABLISHED */
+	struct list_head ibc_tx_noops;         /* IBLND_MSG_NOOPs for */
+					       /* IBLND_MSG_VERSION_1 */
+	struct list_head ibc_tx_queue;         /* sends that need a credit */
+	struct list_head ibc_tx_queue_nocred;  /* sends that don't need a */
+					       /* credit */
+	struct list_head ibc_tx_queue_rsrvd;   /* sends that need to */
+					       /* reserve an ACK/DONE msg */
+	struct list_head ibc_active_txs; /* active tx awaiting completion */
+	spinlock_t            ibc_lock;        /* serialise */
+	kib_rx_t              *ibc_rxs;        /* the rx descs */
+	kib_pages_t           *ibc_rx_pages;   /* premapped rx msg pages */
+
+	struct rdma_cm_id     *ibc_cmid;       /* CM id */
+	struct ib_cq          *ibc_cq;         /* completion queue */
+
+	kib_connvars_t        *ibc_connvars; /* in-progress connection state */
 } kib_conn_t;
 
 #define IBLND_CONN_INIT           0	 /* being initialised */
@@ -780,8 +750,8 @@ kiblnd_queue2str(kib_conn_t *conn, struct list_head *q)
 	return NULL;
 }
 
-/* CAVEAT EMPTOR: We rely on descriptor alignment to allow us to use the
- * lowest bits of the work request id to stash the work item type. */
+/* CAVEAT EMPTOR: We rely on descriptor alignment to allow us to use the */
+/* lowest bits of the work request id to stash the work item type. */
 
 #define IBLND_WID_TX    0
 #define IBLND_WID_RDMA  1
@@ -928,9 +898,9 @@ static inline unsigned int kiblnd_sg_dma_len(struct ib_device *dev,
 	return ib_sg_dma_len(dev, sg);
 }
 
-/* XXX We use KIBLND_CONN_PARAM(e) as writable buffer, it's not strictly
- * right because OFED1.2 defines it as const, to use it we have to add
- * (void *) cast to overcome "const" */
+/* XXX We use KIBLND_CONN_PARAM(e) as writable buffer, it's not strictly */
+/* right because OFED1.2 defines it as const, to use it we have to add */
+/* (void *) cast to overcome "const" */
 
 #define KIBLND_CONN_PARAM(e)     ((e)->param.conn.private_data)
 #define KIBLND_CONN_PARAM_LEN(e) ((e)->param.conn.private_data_len)
-- 
2.4.5

_______________________________________________
lustre-devel mailing list
lustre-devel at lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
