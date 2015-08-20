From: Jeff Becker <Jeffrey.C.Becker@nasa.gov>
Date: Thu, 20 Aug 2015 13:01:38 -0700
Subject: [lustre-devel] [PATCH] staging/lustre: fix block comment formatting
Message-ID: <1440100898-37695-1-git-send-email-Jeffrey.C.Becker@nasa.gov>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Running checkpatch.pl on lnet/klnds/o2iblnd/o2iblnd.h produces several
"Block comments use a trailing */ on a separate line" warnings. This patch
fixes these.

---
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h    | 90 ++++++++++++++--------
 1 file changed, 60 insertions(+), 30 deletions(-)

diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
index f4b6c33..659d9cc 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
@@ -82,9 +82,11 @@ typedef struct {
 	int          *kib_dev_failover;      /* HCA failover */
 	unsigned int *kib_service;           /* IB service number */
 	int          *kib_min_reconnect_interval; /* first failed connection
-						   * retry... */
+						   * retry...
+						   */
 	int          *kib_max_reconnect_interval; /* ...exponentially increasing
-						   * to this */
+						   * to this
+						   */
 	int          *kib_cksum;             /* checksum kib_msg_t? */
 	int          *kib_timeout;           /* comms timeout (seconds) */
 	int          *kib_keepalive;         /* keepalive timeout (seconds) */
@@ -92,9 +94,11 @@ typedef struct {
 	int          *kib_credits;           /* # concurrent sends */
 	int          *kib_peertxcredits;     /* # concurrent sends to 1 peer */
 	int          *kib_peerrtrcredits;    /* # per-peer router buffer
-					      * credits */
+					      * credits
+					      */
 	int          *kib_peercredits_hiw;   /* # when eagerly to return
-					      * credits */
+					      * credits
+					      */
 	int          *kib_peertimeout;       /* seconds to consider peer dead */
 	char         **kib_default_ipif;     /* default IPoIB interface */
 	int          *kib_retry_count;
@@ -103,13 +107,15 @@ typedef struct {
 	int          *kib_ib_mtu;            /* IB MTU */
 	int          *kib_map_on_demand;     /* map-on-demand if RD has more
 					      * fragments than this value, 0
-					      * disable map-on-demand */
+					      * disable map-on-demand
+					      */
 	int          *kib_fmr_pool_size;     /* # FMRs in pool */
 	int          *kib_fmr_flush_trigger; /* When to trigger FMR flush */
 	int          *kib_fmr_cache;         /* enable FMR pool cache? */
 	int          *kib_require_priv_port; /* accept only privileged ports */
 	int          *kib_use_priv_port;     /* use privileged port for active
-					      * connect */
+					      * connect
+					      */
 	int          *kib_nscheds;           /* # threads on each CPT */
 } kib_tunables_t;
 
@@ -200,7 +206,8 @@ typedef struct {
 	int                ibd_failed_failover; /* # failover failures */
 	unsigned int       ibd_failover;        /* failover in progress */
 	unsigned int       ibd_can_failover;    /* IPoIB interface is a bonding
-						 * master */
+						 * master
+						 */
 	struct list_head   ibd_nets;
 	struct kib_hca_dev *ibd_hdev;
 } kib_dev_t;
@@ -250,7 +257,8 @@ typedef struct kib_poolset {
 	struct list_head      ps_pool_list;       /* list of pools */
 	struct list_head      ps_failed_pool_list;/* failed pool list */
 	unsigned long         ps_next_retry;      /* time stamp for retry if
-						   * failed to allocate */
+						   * failed to allocate
+						   */
 	int                   ps_increasing;      /* is allocating new pool */
 	int                   ps_pool_size;       /* new pool size */
 	int                   ps_cpt;             /* CPT id */
@@ -258,7 +266,8 @@ typedef struct kib_poolset {
 	kib_ps_pool_create_t  ps_pool_create;     /* create a new pool */
 	kib_ps_pool_destroy_t ps_pool_destroy;    /* destroy a pool */
 	kib_ps_node_init_t    ps_node_init;       /* initialize new allocated
-						   * node */
+						   * node
+						   */
 	kib_ps_node_fini_t    ps_node_fini;       /* finalize node */
 } kib_poolset_t;
 
@@ -269,7 +278,8 @@ typedef struct kib_pool {
 	unsigned long         po_deadline;     /* deadline of this pool */
 	int                   po_allocated;    /* # of elements in use */
 	int                   po_failed;       /* pool is created on failed
-						* HCA */
+						* HCA
+						*/
 	int                   po_size;         /* # of pre-allocated elements */
 } kib_pool_t;
 
@@ -296,7 +306,8 @@ typedef struct {
 	int                   fps_flush_trigger;
 	int                   fps_increasing;      /* is allocating new pool */
 	unsigned long         fps_next_retry;      /* time stamp for retry if
-						    * failed to allocate */
+						    * failed to allocate
+						    */
 } kib_fmr_poolset_t;
 
 typedef struct {
@@ -348,23 +359,29 @@ typedef struct {
 	int                   kib_shutdown;       /* shut down? */
 	struct list_head      kib_devs;           /* IB devices extant */
 	struct list_head      kib_failed_devs;    /* list head of failed
-						   * devices */
+						   * devices
+						   */
 	wait_queue_head_t     kib_failover_waitq; /* schedulers sleep here */
 	atomic_t              kib_nthreads;       /* # live threads */
 	rwlock_t              kib_global_lock;    /* stabilize net/dev/peer/conn
-						   * ops */
+						   * ops
+						   */
 	struct list_head      *kib_peers;         /* hash table of all my known
-						   * peers */
+						   * peers
+						   */
 	int                   kib_peer_hash_size; /* size of kib_peers */
 	void                  *kib_connd;         /* the connd task
 						   * (serialisation assertions)
 						   */
 	struct list_head      kib_connd_conns;    /* connections to
-						   * setup/teardown */
+						   * setup/teardown
+						   */
 	struct list_head      kib_connd_zombies;  /* connections with zero
-						   * refcount */
+						   * refcount
+						   */
 	wait_queue_head_t     kib_connd_waitq;    /* connection daemon sleeps
-						   * here */
+						   * here
+						   */
 	spinlock_t            kib_connd_lock;     /* serialise */
 	struct ib_qp_attr     kib_error_qpa;      /* QP->ERROR */
 	struct kib_sched_info **kib_scheds;       /* percpt data for schedulers
@@ -481,9 +498,11 @@ typedef struct {
 #define IBLND_REJECT_CONN_UNCOMPAT  4 /* incompatible version peer */
 #define IBLND_REJECT_CONN_STALE     5 /* stale peer */
 #define IBLND_REJECT_RDMA_FRAGS     6 /* Fatal: peer's rdma frags can't match
-				       * mine */
+				       * mine
+				       */
 #define IBLND_REJECT_MSG_QUEUE_SIZE 7 /* Fatal: peer's msg queue size can't
-				       * match mine */
+				       * match mine
+				       */
 
 /***********************************************************************/
 
@@ -492,7 +511,8 @@ typedef struct kib_rx                         /* receive message */
 	struct list_head       rx_list;       /* queue for attention */
 	struct kib_conn        *rx_conn;      /* owning conn */
 	int                    rx_nob;        /* # bytes received (-1 while
-					       * posted) */
+					       * posted)
+					       */
 	enum ib_wc_status      rx_status;     /* completion status */
 	kib_msg_t              *rx_msg;       /* message buffer (host vaddr) */
 	__u64                  rx_msgaddr;    /* message buffer (I/O addr) */
@@ -505,12 +525,14 @@ typedef struct kib_rx                         /* receive message */
 #define IBLND_POSTRX_NO_CREDIT    1   /* post: no credits */
 #define IBLND_POSTRX_PEER_CREDIT  2   /* post: give peer back 1 credit */
 #define IBLND_POSTRX_RSRVD_CREDIT 3   /* post: give myself back 1 reserved
-				       * credit */
+				       * credit
+				       */
 
 typedef struct kib_tx                         /* transmit message */
 {
 	struct list_head       tx_list;       /* queue on idle_txs ibc_tx_queue
-					       * etc. */
+					       * etc.
+					       */
 	kib_tx_pool_t          *tx_pool;      /* pool I'm from */
 	struct kib_conn        *tx_conn;      /* owning conn */
 	short                  tx_sending;    /* # tx callbacks outstanding */
@@ -520,7 +542,8 @@ typedef struct kib_tx                         /* transmit message */
 	unsigned long          tx_deadline;   /* completion deadline */
 	__u64                  tx_cookie;     /* completion cookie */
 	lnet_msg_t             *tx_lntmsg[2]; /* lnet msgs to finalize on
-					       * completion */
+					       * completion
+					       */
 	kib_msg_t              *tx_msg;       /* message buffer (host vaddr) */
 	__u64                  tx_msgaddr;    /* message buffer (I/O addr) */
 	DECLARE_PCI_UNMAP_ADDR(tx_msgunmap);  /* for dma_unmap_single() */
@@ -566,18 +589,22 @@ typedef struct kib_conn {
 						     * kiblnd_check_conns only
 						     */
 	struct list_head      ibc_early_rxs;        /* rxs completed before
-						     * ESTABLISHED */
+						     * ESTABLISHED
+						     */
 	struct list_head      ibc_tx_noops;         /* IBLND_MSG_NOOPs for
-						     * IBLND_MSG_VERSION_1 */
+						     * IBLND_MSG_VERSION_1
+						     */
 	struct list_head      ibc_tx_queue;         /* sends that need a credit
 						     */
 	struct list_head      ibc_tx_queue_nocred;  /* sends that don't need a
-						     * credit */
+						     * credit
+						     */
 	struct list_head      ibc_tx_queue_rsrvd;   /* sends that need to
 						     * reserve an ACK/DONE msg
 						     */
 	struct list_head      ibc_active_txs;       /* active tx awaiting
-						     * completion */
+						     * completion
+						     */
 	spinlock_t            ibc_lock;             /* serialise */
 	kib_rx_t              *ibc_rxs;             /* the rx descs */
 	kib_pages_t           *ibc_rx_pages;        /* premapped rx msg pages */
@@ -586,7 +613,8 @@ typedef struct kib_conn {
 	struct ib_cq          *ibc_cq;              /* completion queue */
 
 	kib_connvars_t        *ibc_connvars;        /* in-progress connection
-						     * state */
+						     * state
+						     */
 } kib_conn_t;
 
 #define IBLND_CONN_INIT           0	 /* being initialised */
@@ -781,7 +809,8 @@ kiblnd_queue2str(kib_conn_t *conn, struct list_head *q)
 }
 
 /* CAVEAT EMPTOR: We rely on descriptor alignment to allow us to use the
- * lowest bits of the work request id to stash the work item type. */
+ * lowest bits of the work request id to stash the work item type.
+ */
 
 #define IBLND_WID_TX    0
 #define IBLND_WID_RDMA  1
@@ -930,7 +959,8 @@ static inline unsigned int kiblnd_sg_dma_len(struct ib_device *dev,
 
 /* XXX We use KIBLND_CONN_PARAM(e) as writable buffer, it's not strictly
  * right because OFED1.2 defines it as const, to use it we have to add
- * (void *) cast to overcome "const" */
+ * (void *) cast to overcome "const"
+ */
 
 #define KIBLND_CONN_PARAM(e)     ((e)->param.conn.private_data)
 #define KIBLND_CONN_PARAM_LEN(e) ((e)->param.conn.private_data_len)
-- 
2.4.5
