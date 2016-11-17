From: James Simmons <jsimmons@infradead.org>
Date: Thu, 17 Nov 2016 14:35:40 -0500
Subject: [lustre-devel] [PATCH 02/19] staging: lustre: lnet: resolve
	trailing */ errors
In-Reply-To: <1479411357-28979-1-git-send-email-jsimmons@infradead.org>
References: <1479411357-28979-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1479411357-28979-3-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

This patch resolves the checkpatch error:

Block comments use a trailing */ on a separate line

for the LNet/libcfs layer

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/lnet/klnds/socklnd/socklnd.h    |  128 +++++++++++++-------
 drivers/staging/lustre/lnet/libcfs/hash.c          |    2 +-
 .../lustre/lnet/libcfs/linux/linux-crypto.h        |    2 +-
 drivers/staging/lustre/lnet/libcfs/prng.c          |    2 +-
 drivers/staging/lustre/lnet/selftest/console.h     |    9 +-
 drivers/staging/lustre/lnet/selftest/rpc.h         |    6 +-
 drivers/staging/lustre/lnet/selftest/selftest.h    |   21 ++-
 drivers/staging/lustre/lnet/selftest/timer.c       |    3 +-
 8 files changed, 112 insertions(+), 61 deletions(-)

diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h
index c51c16b..2978014 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h
@@ -84,7 +84,8 @@ struct ksock_sched {				/* per scheduler state */
 	struct list_head        kss_zombie_noop_txs; /* zombie noop tx list */
 	wait_queue_head_t       kss_waitq;	/* where scheduler sleeps */
 	int                     kss_nconns;     /* # connections assigned to
-						 * this scheduler */
+						 * this scheduler
+						 */
 	struct ksock_sched_info *kss_info;	/* owner of it */
 };
 
@@ -110,15 +111,19 @@ struct ksock_interface {			/* in-use interface */
 
 struct ksock_tunables {
 	int          *ksnd_timeout;            /* "stuck" socket timeout
-						* (seconds) */
+						* (seconds)
+						*/
 	int          *ksnd_nscheds;            /* # scheduler threads in each
-						* pool while starting */
+						* pool while starting
+						*/
 	int          *ksnd_nconnds;            /* # connection daemons */
 	int          *ksnd_nconnds_max;        /* max # connection daemons */
 	int          *ksnd_min_reconnectms;    /* first connection retry after
-						* (ms)... */
+						* (ms)...
+						*/
 	int          *ksnd_max_reconnectms;    /* ...exponentially increasing to
-						* this */
+						* this
+						*/
 	int          *ksnd_eager_ack;          /* make TCP ack eagerly? */
 	int          *ksnd_typed_conns;        /* drive sockets by type? */
 	int          *ksnd_min_bulk;           /* smallest "large" message */
@@ -126,9 +131,11 @@ struct ksock_tunables {
 	int          *ksnd_rx_buffer_size;     /* socket rx buffer size */
 	int          *ksnd_nagle;              /* enable NAGLE? */
 	int          *ksnd_round_robin;        /* round robin for multiple
-						* interfaces */
+						* interfaces
+						*/
 	int          *ksnd_keepalive;          /* # secs for sending keepalive
-						* NOOP */
+						* NOOP
+						*/
 	int          *ksnd_keepalive_idle;     /* # idle secs before 1st probe
 						*/
 	int          *ksnd_keepalive_count;    /* # probes */
@@ -137,20 +144,26 @@ struct ksock_tunables {
 	int          *ksnd_peertxcredits;      /* # concurrent sends to 1 peer
 						*/
 	int          *ksnd_peerrtrcredits;     /* # per-peer router buffer
-						* credits */
+						* credits
+						*/
 	int          *ksnd_peertimeout;        /* seconds to consider peer dead
 						*/
 	int          *ksnd_enable_csum;        /* enable check sum */
 	int          *ksnd_inject_csum_error;  /* set non-zero to inject
-						* checksum error */
+						* checksum error
+						*/
 	int          *ksnd_nonblk_zcack;       /* always send zc-ack on
-						* non-blocking connection */
+						* non-blocking connection
+						*/
 	unsigned int *ksnd_zc_min_payload;     /* minimum zero copy payload
-						* size */
+						* size
+						*/
 	int          *ksnd_zc_recv;            /* enable ZC receive (for
-						* Chelsio TOE) */
+						* Chelsio TOE)
+						*/
 	int          *ksnd_zc_recv_min_nfrags; /* minimum # of fragments to
-						* enable ZC receive */
+						* enable ZC receive
+						*/
 };
 
 struct ksock_net {
@@ -174,9 +187,11 @@ struct ksock_nal_data {
 	int                     ksnd_nnets;             /* # networks set up */
 	struct list_head        ksnd_nets;              /* list of nets */
 	rwlock_t                ksnd_global_lock;       /* stabilize peer/conn
-							 * ops */
+							 * ops
+							 */
 	struct list_head        *ksnd_peers;            /* hash table of all my
-							 * known peers */
+							 * known peers
+							 */
 	int                     ksnd_peer_hash_size;    /* size of ksnd_peers */
 
 	int                     ksnd_nthreads;          /* # live threads */
@@ -187,11 +202,14 @@ struct ksock_nal_data {
 	atomic_t                ksnd_nactive_txs;       /* #active txs */
 
 	struct list_head        ksnd_deathrow_conns;    /* conns to close:
-							 * reaper_lock*/
+							 * reaper_lock
+							 */
 	struct list_head        ksnd_zombie_conns;      /* conns to free:
-							 * reaper_lock */
+							 * reaper_lock
+							 */
 	struct list_head        ksnd_enomem_conns;      /* conns to retry:
-							 * reaper_lock*/
+							 * reaper_lock
+							 */
 	wait_queue_head_t       ksnd_reaper_waitq;      /* reaper sleeps here */
 	unsigned long	        ksnd_reaper_waketime;   /* when reaper will wake
 							 */
@@ -201,18 +219,21 @@ struct ksock_nal_data {
 	int                     ksnd_stall_tx;          /* test sluggish sender
 							 */
 	int                     ksnd_stall_rx;          /* test sluggish
-							 * receiver */
-
+							 * receiver
+							 */
 	struct list_head        ksnd_connd_connreqs;    /* incoming connection
-							 * requests */
+							 * requests
+							 */
 	struct list_head        ksnd_connd_routes;      /* routes waiting to be
-							 * connected */
+							 * connected
+							 */
 	wait_queue_head_t       ksnd_connd_waitq;       /* connds sleep here */
 	int                     ksnd_connd_connecting;  /* # connds connecting
 							 */
 	time64_t                ksnd_connd_failed_stamp;/* time stamp of the
 							 * last failed
-							 * connecting attempt */
+							 * connecting attempt
+							 */
 	time64_t                ksnd_connd_starting_stamp;/* time stamp of the
 							   * last starting connd
 							   */
@@ -221,10 +242,11 @@ struct ksock_nal_data {
 	spinlock_t              ksnd_connd_lock;        /* serialise */
 
 	struct list_head        ksnd_idle_noop_txs;     /* list head for freed
-							 * noop tx */
+							 * noop tx
+							 */
 	spinlock_t              ksnd_tx_lock;           /* serialise, g_lock
-							 * unsafe */
-
+							 * unsafe
+							 */
 };
 
 #define SOCKNAL_INIT_NOTHING 0
@@ -304,9 +326,11 @@ struct ksock_conn {
 	struct list_head   ksnc_list;         /* stash on peer's conn list */
 	struct socket      *ksnc_sock;        /* actual socket */
 	void               *ksnc_saved_data_ready;  /* socket's original
-						     * data_ready() callback */
+						     * data_ready() callback
+						     */
 	void               *ksnc_saved_write_space; /* socket's original
-						     * write_space() callback */
+						     * write_space() callback
+						     */
 	atomic_t           ksnc_conn_refcount;/* conn refcount */
 	atomic_t           ksnc_sock_refcount;/* sock refcount */
 	struct ksock_sched *ksnc_scheduler;	/* who schedules this connection
@@ -315,7 +339,8 @@ struct ksock_conn {
 	__u32              ksnc_ipaddr;       /* peer's IP */
 	int                ksnc_port;         /* peer's port */
 	signed int         ksnc_type:3;       /* type of connection, should be
-					       * signed value */
+					       * signed value
+					       */
 	unsigned int       ksnc_closing:1;    /* being shut down */
 	unsigned int       ksnc_flip:1;       /* flip or not, only for V2.x */
 	unsigned int       ksnc_zc_capable:1; /* enable to ZC */
@@ -323,9 +348,11 @@ struct ksock_conn {
 
 	/* reader */
 	struct list_head   ksnc_rx_list;      /* where I enq waiting input or a
-					       * forwarding descriptor */
+					       * forwarding descriptor
+					       */
 	unsigned long      ksnc_rx_deadline;  /* when (in jiffies) receive times
-					       * out */
+					       * out
+					       */
 	__u8               ksnc_rx_started;   /* started receiving a message */
 	__u8               ksnc_rx_ready;     /* data ready to read */
 	__u8               ksnc_rx_scheduled; /* being progressed */
@@ -338,7 +365,8 @@ struct ksock_conn {
 	lnet_kiov_t        *ksnc_rx_kiov;     /* the page frags */
 	union ksock_rxiovspace ksnc_rx_iov_space; /* space for frag descriptors */
 	__u32              ksnc_rx_csum;      /* partial checksum for incoming
-					       * data */
+					       * data
+					       */
 	void               *ksnc_cookie;      /* rx lnet_finalize passthru arg
 					       */
 	ksock_msg_t        ksnc_msg;          /* incoming message buffer:
@@ -346,14 +374,16 @@ struct ksock_conn {
 					       * whole struct
 					       * V1.x message is a bare
 					       * lnet_hdr_t, it's stored in
-					       * ksnc_msg.ksm_u.lnetmsg */
-
+					       * ksnc_msg.ksm_u.lnetmsg
+					       */
 	/* WRITER */
 	struct list_head   ksnc_tx_list;      /* where I enq waiting for output
-					       * space */
+					       * space
+					       */
 	struct list_head   ksnc_tx_queue;     /* packets waiting to be sent */
-	struct ksock_tx         *ksnc_tx_carrier;  /* next TX that can carry a LNet
-					       * message or ZC-ACK */
+	struct ksock_tx	  *ksnc_tx_carrier;   /* next TX that can carry a LNet
+					       * message or ZC-ACK
+					       */
 	unsigned long      ksnc_tx_deadline;  /* when (in jiffies) tx times out
 					       */
 	int                ksnc_tx_bufnob;    /* send buffer marker */
@@ -361,7 +391,8 @@ struct ksock_conn {
 	int		   ksnc_tx_ready;     /* write space */
 	int		   ksnc_tx_scheduled; /* being progressed */
 	unsigned long      ksnc_tx_last_post; /* time stamp of the last posted
-					       * TX */
+					       * TX
+					       */
 };
 
 struct ksock_route {
@@ -370,20 +401,24 @@ struct ksock_route {
 	struct ksock_peer *ksnr_peer;          /* owning peer */
 	atomic_t          ksnr_refcount;       /* # users */
 	unsigned long     ksnr_timeout;        /* when (in jiffies) reconnection
-						* can happen next */
+						* can happen next
+						*/
 	long              ksnr_retry_interval; /* how long between retries */
 	__u32             ksnr_myipaddr;       /* my IP */
 	__u32             ksnr_ipaddr;         /* IP address to connect to */
 	int               ksnr_port;           /* port to connect to */
 	unsigned int      ksnr_scheduled:1;    /* scheduled for attention */
 	unsigned int      ksnr_connecting:1;   /* connection establishment in
-						* progress */
+						* progress
+						*/
 	unsigned int      ksnr_connected:4;    /* connections established by
-						* type */
+						* type
+						*/
 	unsigned int      ksnr_deleted:1;      /* been removed from peer? */
 	unsigned int      ksnr_share_count;    /* created explicitly? */
 	int               ksnr_conn_count;     /* # conns established by this
-						* route */
+						* route
+						*/
 };
 
 #define SOCKNAL_KEEPALIVE_PING 1 /* cookie for keepalive ping */
@@ -391,7 +426,8 @@ struct ksock_route {
 struct ksock_peer {
 	struct list_head   ksnp_list;           /* stash on global peer list */
 	unsigned long      ksnp_last_alive;     /* when (in jiffies) I was last
-						 * alive */
+						 * alive
+						 */
 	lnet_process_id_t  ksnp_id;             /* who's on the other end(s) */
 	atomic_t           ksnp_refcount;       /* # users */
 	int                ksnp_sharecount;     /* lconf usage counter */
@@ -408,7 +444,8 @@ struct ksock_peer {
 	struct list_head   ksnp_tx_queue;       /* waiting packets */
 	spinlock_t         ksnp_lock;           /* serialize, g_lock unsafe */
 	struct list_head   ksnp_zc_req_list;    /* zero copy requests wait for
-						 * ACK  */
+						 * ACK
+						 */
 	unsigned long      ksnp_send_keepalive; /* time to send keepalive */
 	lnet_ni_t          *ksnp_ni;            /* which network */
 	int                ksnp_n_passive_ips;  /* # of... */
@@ -429,7 +466,8 @@ struct ksock_connreq {
 #define SOCKNAL_MATCH_NO  0 /* TX can't match type of connection */
 #define SOCKNAL_MATCH_YES 1 /* TX matches type of connection */
 #define SOCKNAL_MATCH_MAY 2 /* TX can be sent on the connection, but not
-			     * preferred */
+			     * preferred
+			     */
 
 struct ksock_proto {
 	/* version number of protocol */
diff --git a/drivers/staging/lustre/lnet/libcfs/hash.c b/drivers/staging/lustre/lnet/libcfs/hash.c
index 3137f12..530def6 100644
--- a/drivers/staging/lustre/lnet/libcfs/hash.c
+++ b/drivers/staging/lustre/lnet/libcfs/hash.c
@@ -1716,7 +1716,7 @@ struct cfs_hash_cond_arg {
  * the passed callback @func and pass to it as an argument each hash
  * item and the private @data. During the callback the bucket lock
  * is held so the callback must never sleep.
-   */
+ */
 void
 cfs_hash_for_each_key(struct cfs_hash *hs, const void *key,
 		      cfs_hash_for_each_cb_t func, void *data)
diff --git a/drivers/staging/lustre/lnet/libcfs/linux/linux-crypto.h b/drivers/staging/lustre/lnet/libcfs/linux/linux-crypto.h
index 18e8cd4..d0b3aa8 100644
--- a/drivers/staging/lustre/lnet/libcfs/linux/linux-crypto.h
+++ b/drivers/staging/lustre/lnet/libcfs/linux/linux-crypto.h
@@ -1,4 +1,4 @@
- /*
+/*
  * GPL HEADER START
  *
  * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
diff --git a/drivers/staging/lustre/lnet/libcfs/prng.c b/drivers/staging/lustre/lnet/libcfs/prng.c
index a9bdb28..21d5a39 100644
--- a/drivers/staging/lustre/lnet/libcfs/prng.c
+++ b/drivers/staging/lustre/lnet/libcfs/prng.c
@@ -33,7 +33,7 @@
  * x(n)=a*x(n-1)+carry mod 2^16 and y(n)=b*y(n-1)+carry mod 2^16,
  * number and carry packed within the same 32 bit integer.
  * algorithm recommended by Marsaglia
-*/
+ */
 
 #include "../../include/linux/libcfs/libcfs.h"
 
diff --git a/drivers/staging/lustre/lnet/selftest/console.h b/drivers/staging/lustre/lnet/selftest/console.h
index 5b11b2c..5dc1de4 100644
--- a/drivers/staging/lustre/lnet/selftest/console.h
+++ b/drivers/staging/lustre/lnet/selftest/console.h
@@ -92,14 +92,16 @@ struct lstcon_batch {
 	int		 bat_ntest;	  /* # of test */
 	int		 bat_state;	  /* state of the batch */
 	int		 bat_arg;	  /* parameter for run|stop, timeout
-					   * for run, force for stop */
+					   * for run, force for stop
+					   */
 	char		 bat_name[LST_NAME_SIZE];/* name of batch */
 
 	struct list_head bat_test_list;   /* list head of tests (struct lstcon_test)
 					   */
 	struct list_head bat_trans_list;  /* list head of transaction */
 	struct list_head bat_cli_list;	  /* list head of client nodes
-					   * (struct lstcon_node) */
+					   * (struct lstcon_node)
+					   */
 	struct list_head *bat_cli_hash;   /* hash table of client nodes */
 	struct list_head bat_srv_list;	  /* list head of server nodes */
 	struct list_head *bat_srv_hash;   /* hash table of server nodes */
@@ -147,7 +149,8 @@ struct lstcon_session {
 	unsigned int	    ses_features;     /* tests features of the session
 					       */
 	unsigned int	    ses_feats_updated:1; /* features are synced with
-						  * remote test nodes */
+						  * remote test nodes
+						  */
 	unsigned int	    ses_force:1;      /* force creating */
 	unsigned int	    ses_shutdown:1;   /* session is shutting down */
 	unsigned int	    ses_expired:1;    /* console is timedout */
diff --git a/drivers/staging/lustre/lnet/selftest/rpc.h b/drivers/staging/lustre/lnet/selftest/rpc.h
index 8a0c18e..f353a63 100644
--- a/drivers/staging/lustre/lnet/selftest/rpc.h
+++ b/drivers/staging/lustre/lnet/selftest/rpc.h
@@ -113,7 +113,8 @@ struct srpc_join_reply {
 	__u32			join_status;	/* returned status */
 	lst_sid_t		join_sid;	/* session id */
 	__u32			join_timeout;	/* # seconds' inactivity to
-						 * expire */
+						 * expire
+						 */
 	char			join_session[LST_NAME_SIZE]; /* session name */
 } WIRE_ATTR;
 
@@ -190,7 +191,8 @@ struct srpc_test_reqst {
 	lst_bid_t		tsr_bid;	/* batch id */
 	__u32			tsr_service;	/* test type: bulk|ping|... */
 	__u32			tsr_loop;	/* test client loop count or
-						 * # server buffers needed */
+						 * # server buffers needed
+						 */
 	__u32			tsr_concur;	/* concurrency of test */
 	__u8			tsr_is_client;	/* is test client or not */
 	__u8			tsr_stop_onerr; /* stop on error */
diff --git a/drivers/staging/lustre/lnet/selftest/selftest.h b/drivers/staging/lustre/lnet/selftest/selftest.h
index 4a1eb29..c8833a0 100644
--- a/drivers/staging/lustre/lnet/selftest/selftest.h
+++ b/drivers/staging/lustre/lnet/selftest/selftest.h
@@ -131,7 +131,8 @@
 
 enum srpc_event_type {
 	SRPC_BULK_REQ_RCVD   = 1, /* passive bulk request(PUT sink/GET source)
-				   * received */
+				   * received
+				   */
 	SRPC_BULK_PUT_SENT   = 2, /* active bulk PUT sent (source) */
 	SRPC_BULK_GET_RPLD   = 3, /* active bulk GET replied (sink) */
 	SRPC_REPLY_RCVD      = 4, /* incoming reply received */
@@ -295,7 +296,8 @@ struct srpc_service_cd {
 #define SFW_TEST_WI_MIN		256
 #define SFW_TEST_WI_MAX		2048
 /* extra buffers for tolerating buggy peers, or unbalanced number
- * of peers between partitions	*/
+ * of peers between partitions
+ */
 #define SFW_TEST_WI_EXTRA	64
 
 /* number of server workitems (mini-thread) for framework service */
@@ -347,9 +349,11 @@ struct sfw_batch {
 
 struct sfw_test_client_ops {
 	int  (*tso_init)(struct sfw_test_instance *tsi); /* initialize test
-							  * client */
+							  * client
+							  */
 	void (*tso_fini)(struct sfw_test_instance *tsi); /* finalize test
-							  * client */
+							  * client
+							  */
 	int  (*tso_prep_rpc)(struct sfw_test_unit *tsu,
 			     lnet_process_id_t dest,
 			     struct srpc_client_rpc **rpc);	/* prep a tests rpc */
@@ -374,7 +378,8 @@ struct sfw_test_instance {
 	spinlock_t		   tsi_lock;		/* serialize */
 	unsigned int		   tsi_stopping:1;	/* test is stopping */
 	atomic_t		   tsi_nactive;		/* # of active test
-							 * unit */
+							 * unit
+							 */
 	struct list_head	   tsi_units;		/* test units */
 	struct list_head	   tsi_free_rpcs;	/* free rpcs */
 	struct list_head	   tsi_active_rpcs;	/* active rpcs */
@@ -386,8 +391,10 @@ struct sfw_test_instance {
 	} tsi_u;
 };
 
-/* XXX: trailing (PAGE_SIZE % sizeof(lnet_process_id_t)) bytes at the end of
- * pages are not used */
+/*
+ * XXX: trailing (PAGE_SIZE % sizeof(lnet_process_id_t)) bytes at the end of
+ * pages are not used
+ */
 #define SFW_MAX_CONCUR	   LST_MAX_CONCUR
 #define SFW_ID_PER_PAGE    (PAGE_SIZE / sizeof(lnet_process_id_packed_t))
 #define SFW_MAX_NDESTS	   (LNET_MAX_IOV * SFW_ID_PER_PAGE)
diff --git a/drivers/staging/lustre/lnet/selftest/timer.c b/drivers/staging/lustre/lnet/selftest/timer.c
index dcd2258..a4b723b 100644
--- a/drivers/staging/lustre/lnet/selftest/timer.c
+++ b/drivers/staging/lustre/lnet/selftest/timer.c
@@ -55,7 +55,8 @@
 static struct st_timer_data {
 	spinlock_t	  stt_lock;
 	unsigned long	  stt_prev_slot; /* start time of the slot processed
-					  * previously */
+					  * previously
+					  */
 	struct list_head  stt_hash[STTIMER_NSLOTS];
 	int		  stt_shuttingdown;
 	wait_queue_head_t stt_waitq;
-- 
1.7.1
