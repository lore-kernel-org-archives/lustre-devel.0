From: James Simmons <jsimmons@infradead.org>
Date: Thu, 31 Jan 2019 12:19:29 -0500
Subject: [lustre-devel] [PATCH 25/26] socklnd: cleanup white spaces
In-Reply-To: <1548955170-13456-1-git-send-email-jsimmons@infradead.org>
References: <1548955170-13456-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1548955170-13456-26-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

The ksocklnd code is very messy and difficult to read. Remove
excess white space and properly align data structures so they
are easy on the eyes.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/include/linux/lnet/socklnd.h    |   6 +-
 .../staging/lustre/lnet/klnds/socklnd/socklnd.c    |  71 +--
 .../staging/lustre/lnet/klnds/socklnd/socklnd.h    | 548 ++++++++++-----------
 .../staging/lustre/lnet/klnds/socklnd/socklnd_cb.c |  48 +-
 .../lustre/lnet/klnds/socklnd/socklnd_lib.c        |  16 +-
 .../lustre/lnet/klnds/socklnd/socklnd_modparams.c  |  54 +-
 .../lustre/lnet/klnds/socklnd/socklnd_proto.c      |  79 ++-
 7 files changed, 408 insertions(+), 414 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/socklnd.h b/drivers/staging/lustre/include/linux/lnet/socklnd.h
index 20fa221d..ca814af 100644
--- a/drivers/staging/lustre/include/linux/lnet/socklnd.h
+++ b/drivers/staging/lustre/include/linux/lnet/socklnd.h
@@ -64,9 +64,9 @@ struct ksock_lnet_msg {
 } __packed;
 
 struct ksock_msg {
-	u32	ksm_type;		/* type of socklnd message */
-	u32	ksm_csum;		/* checksum if != 0 */
-	u64	ksm_zc_cookies[2];	/* Zero-Copy request/ACK cookie */
+	u32		ksm_type;		/* type of socklnd message */
+	u32		ksm_csum;		/* checksum if != 0 */
+	u64		ksm_zc_cookies[2];	/* Zero-Copy request/ACK cookie */
 	union {
 		struct ksock_lnet_msg lnetmsg; /* lnet message, it's empty if
 						* it's NOOP
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
index f048f0a..785f76c 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
@@ -309,7 +309,7 @@ struct ksock_peer *
 			}
 		}
 	}
- out:
+out:
 	read_unlock(&ksocknal_data.ksnd_global_lock);
 	return rc;
 }
@@ -713,8 +713,8 @@ struct ksock_peer *
 ksocknal_match_peerip(struct ksock_interface *iface, u32 *ips, int nips)
 {
 	int best_netmatch = 0;
-	int best_xor      = 0;
-	int best	  = -1;
+	int best_xor = 0;
+	int best = -1;
 	int this_xor;
 	int this_netmatch;
 	int i;
@@ -944,7 +944,8 @@ struct ksock_peer *
 			best_iface = iface;
 			best_netmatch = this_netmatch;
 			best_nroutes = iface->ksni_nroutes;
-		next_iface:;
+next_iface:
+			;
 		}
 
 		if (!best_iface)
@@ -955,7 +956,8 @@ struct ksock_peer *
 
 		ksocknal_add_route_locked(peer_ni, newroute);
 		newroute = NULL;
-	next_ipaddr:;
+next_ipaddr:
+		;
 	}
 
 	write_unlock_bh(global_lock);
@@ -982,7 +984,7 @@ struct ksock_peer *
 	}
 
 	lnet_ni_addref(ni);
-	cr->ksncr_ni   = ni;
+	cr->ksncr_ni = ni;
 	cr->ksncr_sock = sock;
 
 	spin_lock_bh(&ksocknal_data.ksnd_connd_lock);
@@ -1215,7 +1217,6 @@ struct ksock_peer *
 	 */
 	if (conn->ksnc_ipaddr != conn->ksnc_myipaddr) {
 		list_for_each_entry(conn2, &peer_ni->ksnp_conns, ksnc_list) {
-
 			if (conn2->ksnc_ipaddr != conn->ksnc_ipaddr ||
 			    conn2->ksnc_myipaddr != conn->ksnc_myipaddr ||
 			    conn2->ksnc_type != conn->ksnc_type)
@@ -1249,7 +1250,7 @@ struct ksock_peer *
 
 	/*
 	 * Search for a route corresponding to the new connection and
-	 * create an association.  This allows incoming connections created
+	 * create an association. This allows incoming connections created
 	 * by routes in my peer_ni to match my own route entries so I don't
 	 * continually create duplicate routes.
 	 */
@@ -1371,7 +1372,7 @@ struct ksock_peer *
 	ksocknal_conn_decref(conn);
 	return rc;
 
- failed_2:
+failed_2:
 	if (!peer_ni->ksnp_closing &&
 	    list_empty(&peer_ni->ksnp_conns) &&
 	    list_empty(&peer_ni->ksnp_routes)) {
@@ -1457,7 +1458,7 @@ struct ksock_peer *
 				goto conn2_found;
 		}
 		route->ksnr_connected &= ~(1 << conn->ksnc_type);
-	conn2_found:
+conn2_found:
 		conn->ksnc_route = NULL;
 
 		ksocknal_route_decref(route);     /* drop conn's ref on route */
@@ -2121,7 +2122,7 @@ static int ksocknal_push(struct lnet_ni *ni, struct lnet_process_id id)
 
 	switch (cmd) {
 	case IOC_LIBCFS_GET_INTERFACE: {
-		struct ksock_net       *net = ni->ni_data;
+		struct ksock_net *net = ni->ni_data;
 		struct ksock_interface *iface;
 
 		read_lock(&ksocknal_data.ksnd_global_lock);
@@ -2164,8 +2165,8 @@ static int ksocknal_push(struct lnet_ni *ni, struct lnet_process_id id)
 		if (rc)
 			return rc;
 
-		data->ioc_nid    = id.nid;
-		data->ioc_count  = share_count;
+		data->ioc_nid  = id.nid;
+		data->ioc_count = share_count;
 		data->ioc_u32[0] = ip;
 		data->ioc_u32[1] = port;
 		data->ioc_u32[2] = myip;
@@ -2178,14 +2179,14 @@ static int ksocknal_push(struct lnet_ni *ni, struct lnet_process_id id)
 		id.nid = data->ioc_nid;
 		id.pid = LNET_PID_LUSTRE;
 		return ksocknal_add_peer(ni, id,
-					  data->ioc_u32[0], /* IP */
-					  data->ioc_u32[1]); /* port */
+					 data->ioc_u32[0], /* IP */
+					 data->ioc_u32[1]); /* port */
 
 	case IOC_LIBCFS_DEL_PEER:
 		id.nid = data->ioc_nid;
 		id.pid = LNET_PID_ANY;
 		return ksocknal_del_peer(ni, id,
-					  data->ioc_u32[0]); /* IP */
+					 data->ioc_u32[0]); /* IP */
 
 	case IOC_LIBCFS_GET_CONN: {
 		int txmem;
@@ -2199,9 +2200,9 @@ static int ksocknal_push(struct lnet_ni *ni, struct lnet_process_id id)
 
 		ksocknal_lib_get_conn_tunables(conn, &txmem, &rxmem, &nagle);
 
-		data->ioc_count  = txmem;
-		data->ioc_nid    = conn->ksnc_peer->ksnp_id.nid;
-		data->ioc_flags  = nagle;
+		data->ioc_count = txmem;
+		data->ioc_nid = conn->ksnc_peer->ksnp_id.nid;
+		data->ioc_flags = nagle;
 		data->ioc_u32[0] = conn->ksnc_ipaddr;
 		data->ioc_u32[1] = conn->ksnc_port;
 		data->ioc_u32[2] = conn->ksnc_myipaddr;
@@ -2217,7 +2218,7 @@ static int ksocknal_push(struct lnet_ni *ni, struct lnet_process_id id)
 		id.nid = data->ioc_nid;
 		id.pid = LNET_PID_ANY;
 		return ksocknal_close_matching_conns(id,
-						      data->ioc_u32[0]);
+						     data->ioc_u32[0]);
 
 	case IOC_LIBCFS_REGISTER_MYNID:
 		/* Ignore if this is a noop */
@@ -2449,8 +2450,8 @@ static int ksocknal_push(struct lnet_ni *ni, struct lnet_process_id id)
 		}
 	}
 
-	ksocknal_data.ksnd_connd_starting       = 0;
-	ksocknal_data.ksnd_connd_failed_stamp   = 0;
+	ksocknal_data.ksnd_connd_starting = 0;
+	ksocknal_data.ksnd_connd_failed_stamp = 0;
 	ksocknal_data.ksnd_connd_starting_stamp = ktime_get_real_seconds();
 	/*
 	 * must have at least 2 connds to remain responsive to accepts while
@@ -2495,7 +2496,7 @@ static int ksocknal_push(struct lnet_ni *ni, struct lnet_process_id id)
 
 	return 0;
 
- failed:
+failed:
 	ksocknal_base_shutdown();
 	return -ENETDOWN;
 }
@@ -2512,7 +2513,7 @@ static int ksocknal_push(struct lnet_ni *ni, struct lnet_process_id id)
 		list_for_each_entry(peer_ni, &ksocknal_data.ksnd_peers[i],
 				    ksnp_list) {
 			struct ksock_route *route;
-			struct ksock_conn  *conn;
+			struct ksock_conn *conn;
 
 			if (peer_ni->ksnp_ni != ni)
 				continue;
@@ -2555,7 +2556,7 @@ static int ksocknal_push(struct lnet_ni *ni, struct lnet_process_id id)
 {
 	struct ksock_net *net = ni->ni_data;
 	int i;
-	struct lnet_process_id anyid = {0};
+	struct lnet_process_id anyid = { 0 };
 
 	anyid.nid = LNET_NID_ANY;
 	anyid.pid = LNET_PID_ANY;
@@ -2846,9 +2847,9 @@ static int ksocknal_push(struct lnet_ni *ni, struct lnet_process_id id)
 
 	return 0;
 
- fail_1:
+fail_1:
 	kfree(net);
- fail_0:
+fail_0:
 	if (!ksocknal_data.ksnd_nnets)
 		ksocknal_base_shutdown();
 
@@ -2869,15 +2870,15 @@ static int __init ksocklnd_init(void)
 	BUILD_BUG_ON(SOCKLND_CONN_ACK != SOCKLND_CONN_BULK_IN);
 
 	/* initialize the_ksocklnd */
-	the_ksocklnd.lnd_type     = SOCKLND;
-	the_ksocklnd.lnd_startup  = ksocknal_startup;
+	the_ksocklnd.lnd_type = SOCKLND;
+	the_ksocklnd.lnd_startup = ksocknal_startup;
 	the_ksocklnd.lnd_shutdown = ksocknal_shutdown;
-	the_ksocklnd.lnd_ctl      = ksocknal_ctl;
-	the_ksocklnd.lnd_send     = ksocknal_send;
-	the_ksocklnd.lnd_recv     = ksocknal_recv;
-	the_ksocklnd.lnd_notify   = ksocknal_notify;
-	the_ksocklnd.lnd_query    = ksocknal_query;
-	the_ksocklnd.lnd_accept   = ksocknal_accept;
+	the_ksocklnd.lnd_ctl = ksocknal_ctl;
+	the_ksocklnd.lnd_send = ksocknal_send;
+	the_ksocklnd.lnd_recv = ksocknal_recv;
+	the_ksocklnd.lnd_notify = ksocknal_notify;
+	the_ksocklnd.lnd_query = ksocknal_query;
+	the_ksocklnd.lnd_accept = ksocknal_accept;
 
 	rc = ksocknal_tunables_init();
 	if (rc)
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h
index a390381..ce1f9e7 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h
@@ -69,36 +69,36 @@
  * no risk if we're not running on a CONFIG_HIGHMEM platform.
  */
 #ifdef CONFIG_HIGHMEM
-# define SOCKNAL_RISK_KMAP_DEADLOCK  0
+# define SOCKNAL_RISK_KMAP_DEADLOCK	0
 #else
-# define SOCKNAL_RISK_KMAP_DEADLOCK  1
+# define SOCKNAL_RISK_KMAP_DEADLOCK	1
 #endif
 
 struct ksock_sched_info;
 
 struct ksock_sched {				/* per scheduler state */
-	spinlock_t              kss_lock;       /* serialise */
-	struct list_head        kss_rx_conns;   /* conn waiting to be read */
-	struct list_head        kss_tx_conns;   /* conn waiting to be written */
-	struct list_head        kss_zombie_noop_txs; /* zombie noop tx list */
-	wait_queue_head_t       kss_waitq;	/* where scheduler sleeps */
-	int                     kss_nconns;     /* # connections assigned to
+	spinlock_t		kss_lock;	/* serialise */
+	struct list_head	kss_rx_conns;	/* conn waiting to be read */
+	struct list_head	kss_tx_conns;	/* conn waiting to be written */
+	struct list_head	kss_zombie_noop_txs; /* zombie noop tx list */
+	wait_queue_head_t	kss_waitq;	/* where scheduler sleeps */
+	int			kss_nconns;	/* # connections assigned to
 						 * this scheduler
 						 */
-	struct ksock_sched_info *kss_info;	/* owner of it */
+	struct ksock_sched_info	*kss_info;	/* owner of it */
 };
 
 struct ksock_sched_info {
-	int                     ksi_nthreads_max; /* max allowed threads */
-	int                     ksi_nthreads;     /* number of threads */
-	int                     ksi_cpt;          /* CPT id */
+	int			ksi_nthreads_max; /* max allowed threads */
+	int			ksi_nthreads;	  /* number of threads */
+	int			ksi_cpt;	  /* CPT id */
 	struct ksock_sched	*ksi_scheds;	  /* array of schedulers */
 };
 
-#define KSOCK_CPT_SHIFT           16
-#define KSOCK_THREAD_ID(cpt, sid) (((cpt) << KSOCK_CPT_SHIFT) | (sid))
-#define KSOCK_THREAD_CPT(id)      ((id) >> KSOCK_CPT_SHIFT)
-#define KSOCK_THREAD_SID(id)      ((id) & ((1UL << KSOCK_CPT_SHIFT) - 1))
+#define KSOCK_CPT_SHIFT			16
+#define KSOCK_THREAD_ID(cpt, sid)	(((cpt) << KSOCK_CPT_SHIFT) | (sid))
+#define KSOCK_THREAD_CPT(id)		((id) >> KSOCK_CPT_SHIFT)
+#define KSOCK_THREAD_SID(id)		((id) & ((1UL << KSOCK_CPT_SHIFT) - 1))
 
 struct ksock_interface {			/* in-use interface */
 	u32		ksni_ipaddr;		/* interface's IP address */
@@ -109,149 +109,149 @@ struct ksock_interface {			/* in-use interface */
 };
 
 struct ksock_tunables {
-	int          *ksnd_timeout;            /* "stuck" socket timeout
-						* (seconds)
-						*/
-	int          *ksnd_nscheds;            /* # scheduler threads in each
-						* pool while starting
-						*/
-	int          *ksnd_nconnds;            /* # connection daemons */
-	int          *ksnd_nconnds_max;        /* max # connection daemons */
-	int          *ksnd_min_reconnectms;    /* first connection retry after
-						* (ms)...
-						*/
-	int          *ksnd_max_reconnectms;    /* ...exponentially increasing to
-						* this
-						*/
-	int          *ksnd_eager_ack;          /* make TCP ack eagerly? */
-	int          *ksnd_typed_conns;        /* drive sockets by type? */
-	int          *ksnd_min_bulk;           /* smallest "large" message */
-	int          *ksnd_tx_buffer_size;     /* socket tx buffer size */
-	int          *ksnd_rx_buffer_size;     /* socket rx buffer size */
-	int          *ksnd_nagle;              /* enable NAGLE? */
-	int          *ksnd_round_robin;        /* round robin for multiple
-						* interfaces
-						*/
-	int          *ksnd_keepalive;          /* # secs for sending keepalive
-						* NOOP
-						*/
-	int          *ksnd_keepalive_idle;     /* # idle secs before 1st probe
-						*/
-	int          *ksnd_keepalive_count;    /* # probes */
-	int          *ksnd_keepalive_intvl;    /* time between probes */
-	int          *ksnd_credits;            /* # concurrent sends */
-	int          *ksnd_peertxcredits;      /* # concurrent sends to 1 peer
-						*/
-	int          *ksnd_peerrtrcredits;     /* # per-peer_ni router buffer
-						* credits
-						*/
-	int          *ksnd_peertimeout;        /* seconds to consider
-						* peer_ni dead
-						*/
-	int          *ksnd_enable_csum;        /* enable check sum */
-	int          *ksnd_inject_csum_error;  /* set non-zero to inject
-						* checksum error
-						*/
-	int          *ksnd_nonblk_zcack;       /* always send zc-ack on
-						* non-blocking connection
-						*/
-	unsigned int *ksnd_zc_min_payload;     /* minimum zero copy payload
-						* size
-						*/
-	int          *ksnd_zc_recv;            /* enable ZC receive (for
-						* Chelsio TOE)
-						*/
-	int          *ksnd_zc_recv_min_nfrags; /* minimum # of fragments to
-						* enable ZC receive
-						*/
+	int		*ksnd_timeout;		/* "stuck" socket timeout
+						 * (seconds)
+						 */
+	int		*ksnd_nscheds;		/* # scheduler threads in each
+						 * pool while starting
+						 */
+	int		*ksnd_nconnds;		/* # connection daemons */
+	int		*ksnd_nconnds_max;	/* max # connection daemons */
+	int		*ksnd_min_reconnectms;	/* first connection retry after
+						 * (ms)...
+						 */
+	int		*ksnd_max_reconnectms;	/* ...exponentially increasing to
+						 * this
+						 */
+	int		*ksnd_eager_ack;	/* make TCP ack eagerly? */
+	int		*ksnd_typed_conns;	/* drive sockets by type? */
+	int		*ksnd_min_bulk;		/* smallest "large" message */
+	int		*ksnd_tx_buffer_size;	/* socket tx buffer size */
+	int		*ksnd_rx_buffer_size;	/* socket rx buffer size */
+	int		*ksnd_nagle;		/* enable NAGLE? */
+	int		*ksnd_round_robin;	/* round robin for multiple
+						 * interfaces
+						 */
+	int		*ksnd_keepalive;	/* # secs for sending keepalive
+						 * NOOP
+						 */
+	int		*ksnd_keepalive_idle;	/* # idle secs before 1st probe
+						 */
+	int		*ksnd_keepalive_count;	/* # probes */
+	int		*ksnd_keepalive_intvl;	/* time between probes */
+	int		*ksnd_credits;		/* # concurrent sends */
+	int		*ksnd_peertxcredits;	/* # concurrent sends to 1 peer
+						 */
+	int		*ksnd_peerrtrcredits;	/* # per-peer_ni router buffer
+						 * credits
+						 */
+	int		*ksnd_peertimeout;	/* seconds to consider
+						 * peer_ni dead
+						 */
+	int		*ksnd_enable_csum;	/* enable check sum */
+	int		*ksnd_inject_csum_error;/* set non-zero to inject
+						 * checksum error
+						 */
+	int		*ksnd_nonblk_zcack;	/* always send zc-ack on
+						 * non-blocking connection
+						 */
+	unsigned int	*ksnd_zc_min_payload;	/* minimum zero copy payload
+						 * size
+						 */
+	int		*ksnd_zc_recv;		/* enable ZC receive (for
+						 * Chelsio TOE)
+						 */
+	int		*ksnd_zc_recv_min_nfrags; /* minimum # of fragments to
+						   * enable ZC receive
+						   */
 };
 
 struct ksock_net {
-	u64		  ksnn_incarnation;	/* my epoch */
-	spinlock_t	  ksnn_lock;		/* serialise */
-	struct list_head	  ksnn_list;		/* chain on global list */
-	int		  ksnn_npeers;		/* # peers */
-	int		  ksnn_shutdown;	/* shutting down? */
-	int		  ksnn_ninterfaces;	/* IP interfaces */
-	struct ksock_interface ksnn_interfaces[LNET_INTERFACES_NUM];
+	u64			ksnn_incarnation;	/* my epoch */
+	spinlock_t		ksnn_lock;		/* serialise */
+	struct list_head	ksnn_list;		/* chain on global list */
+	int			ksnn_npeers;		/* # peers */
+	int			ksnn_shutdown;		/* shutting down? */
+	int			ksnn_ninterfaces;	/* IP interfaces */
+	struct ksock_interface	ksnn_interfaces[LNET_INTERFACES_NUM];
 };
 
 /** connd timeout */
-#define SOCKNAL_CONND_TIMEOUT  120
+#define SOCKNAL_CONND_TIMEOUT	120
 /** reserved thread for accepting & creating new connd */
-#define SOCKNAL_CONND_RESV     1
+#define SOCKNAL_CONND_RESV	1
 
 struct ksock_nal_data {
-	int                     ksnd_init;              /* initialisation state
+	int			ksnd_init;		/* initialisation state
 							 */
-	int                     ksnd_nnets;             /* # networks set up */
-	struct list_head        ksnd_nets;              /* list of nets */
-	rwlock_t                ksnd_global_lock;       /* stabilize
+	int			ksnd_nnets;		/* # networks set up */
+	struct list_head	ksnd_nets;		/* list of nets */
+	rwlock_t		ksnd_global_lock;	/* stabilize
 							 * peer_ni/conn ops
 							 */
-	struct list_head        *ksnd_peers;            /* hash table of all my
+	struct list_head	*ksnd_peers;		/* hash table of all my
 							 * known peers
 							 */
-	int                     ksnd_peer_hash_size;    /* size of ksnd_peers */
+	int			ksnd_peer_hash_size;	/* size of ksnd_peers */
 
-	int                     ksnd_nthreads;          /* # live threads */
-	int                     ksnd_shuttingdown;      /* tell threads to exit
+	int			ksnd_nthreads;		/* # live threads */
+	int			ksnd_shuttingdown;	/* tell threads to exit
 							 */
-	struct ksock_sched_info **ksnd_sched_info;      /* schedulers info */
+	struct ksock_sched_info	**ksnd_sched_info;	/* schedulers info */
 
-	atomic_t                ksnd_nactive_txs;       /* #active txs */
+	atomic_t		ksnd_nactive_txs;	/* #active txs */
 
-	struct list_head        ksnd_deathrow_conns;    /* conns to close:
+	struct list_head	ksnd_deathrow_conns;	/* conns to close:
 							 * reaper_lock
 							 */
-	struct list_head        ksnd_zombie_conns;      /* conns to free:
+	struct list_head	ksnd_zombie_conns;	/* conns to free:
 							 * reaper_lock
 							 */
-	struct list_head        ksnd_enomem_conns;      /* conns to retry:
+	struct list_head	ksnd_enomem_conns;	/* conns to retry:
 							 * reaper_lock
 							 */
-	wait_queue_head_t       ksnd_reaper_waitq;      /* reaper sleeps here */
-	time64_t		ksnd_reaper_waketime;   /* when reaper will wake
+	wait_queue_head_t	ksnd_reaper_waitq;	/* reaper sleeps here */
+	time64_t		ksnd_reaper_waketime;	/* when reaper will wake
 							 */
-	spinlock_t              ksnd_reaper_lock;       /* serialise */
+	spinlock_t		ksnd_reaper_lock;	/* serialise */
 
-	int                     ksnd_enomem_tx;         /* test ENOMEM sender */
-	int                     ksnd_stall_tx;          /* test sluggish sender
+	int			ksnd_enomem_tx;		/* test ENOMEM sender */
+	int			ksnd_stall_tx;		/* test sluggish sender
 							 */
-	int                     ksnd_stall_rx;          /* test sluggish
+	int			ksnd_stall_rx;		/* test sluggish
 							 * receiver
 							 */
-	struct list_head        ksnd_connd_connreqs;    /* incoming connection
+	struct list_head	ksnd_connd_connreqs;	/* incoming connection
 							 * requests
 							 */
-	struct list_head        ksnd_connd_routes;      /* routes waiting to be
+	struct list_head	ksnd_connd_routes;	/* routes waiting to be
 							 * connected
 							 */
-	wait_queue_head_t       ksnd_connd_waitq;       /* connds sleep here */
-	int                     ksnd_connd_connecting;  /* # connds connecting
+	wait_queue_head_t	ksnd_connd_waitq;	/* connds sleep here */
+	int			ksnd_connd_connecting;	/* # connds connecting
 							 */
-	time64_t                ksnd_connd_failed_stamp;/* time stamp of the
+	time64_t		ksnd_connd_failed_stamp;/* time stamp of the
 							 * last failed
 							 * connecting attempt
 							 */
-	time64_t                ksnd_connd_starting_stamp;/* time stamp of the
+	time64_t		ksnd_connd_starting_stamp;/* time stamp of the
 							   * last starting connd
 							   */
 	unsigned int		ksnd_connd_starting;	/* # starting connd */
 	unsigned int		ksnd_connd_running;	/* # running connd */
-	spinlock_t              ksnd_connd_lock;        /* serialise */
+	spinlock_t		ksnd_connd_lock;	/* serialise */
 
-	struct list_head        ksnd_idle_noop_txs;     /* list head for freed
+	struct list_head	ksnd_idle_noop_txs;	/* list head for freed
 							 * noop tx
 							 */
-	spinlock_t              ksnd_tx_lock;           /* serialise, g_lock
+	spinlock_t		ksnd_tx_lock;		/* serialise, g_lock
 							 * unsafe
 							 */
 };
 
-#define SOCKNAL_INIT_NOTHING 0
-#define SOCKNAL_INIT_DATA    1
-#define SOCKNAL_INIT_ALL     2
+#define SOCKNAL_INIT_NOTHING	0
+#define SOCKNAL_INIT_DATA	1
+#define SOCKNAL_INIT_ALL	2
 
 /*
  * A packet just assembled for transmission is represented by 1 or more
@@ -268,34 +268,34 @@ struct ksock_nal_data {
 struct ksock_route; /* forward ref */
 struct ksock_proto; /* forward ref */
 
-struct ksock_tx {			   /* transmit packet */
-	struct list_head  tx_list;         /* queue on conn for transmission etc
-					    */
-	struct list_head  tx_zc_list;      /* queue on peer_ni for ZC request */
-	atomic_t          tx_refcount;     /* tx reference count */
-	int               tx_nob;          /* # packet bytes */
-	int               tx_resid;        /* residual bytes */
-	int               tx_niov;         /* # packet iovec frags */
-	struct kvec       *tx_iov;         /* packet iovec frags */
-	int               tx_nkiov;        /* # packet page frags */
-	unsigned short    tx_zc_aborted;   /* aborted ZC request */
-	unsigned short    tx_zc_capable:1; /* payload is large enough for ZC */
-	unsigned short    tx_zc_checked:1; /* Have I checked if I should ZC? */
-	unsigned short    tx_nonblk:1;     /* it's a non-blocking ACK */
-	struct bio_vec	  *tx_kiov;	   /* packet page frags */
-	struct ksock_conn *tx_conn;        /* owning conn */
-	struct lnet_msg        *tx_lnetmsg;     /* lnet message for lnet_finalize()
-					    */
+struct ksock_tx {				/* transmit packet */
+	struct list_head	tx_list;	/* queue on conn for transmission etc
+						 */
+	struct list_head	tx_zc_list;	/* queue on peer_ni for ZC request */
+	atomic_t		tx_refcount;	/* tx reference count */
+	int			tx_nob;		/* # packet bytes */
+	int			tx_resid;	/* residual bytes */
+	int			tx_niov;	/* # packet iovec frags */
+	struct kvec		*tx_iov;	/* packet iovec frags */
+	int			tx_nkiov;	/* # packet page frags */
+	unsigned short		tx_zc_aborted;	/* aborted ZC request */
+	unsigned short		tx_zc_capable:1;/* payload is large enough for ZC */
+	unsigned short		tx_zc_checked:1;/* Have I checked if I should ZC? */
+	unsigned short		tx_nonblk:1;	/* it's a non-blocking ACK */
+	struct bio_vec		*tx_kiov;	/* packet page frags */
+	struct ksock_conn	*tx_conn;	/* owning conn */
+	struct lnet_msg		*tx_lnetmsg;	/* lnet message for lnet_finalize()
+						 */
 	time64_t		tx_deadline;	/* when (in secs) tx times out */
-	struct ksock_msg       tx_msg;          /* socklnd message buffer */
-	int               tx_desc_size;    /* size of this descriptor */
+	struct ksock_msg	tx_msg;		/* socklnd message buffer */
+	int			tx_desc_size;	/* size of this descriptor */
 	union {
 		struct {
-			struct kvec iov;     /* virt hdr */
-			struct bio_vec kiov[0]; /* paged payload */
+			struct kvec	iov;	/* virt hdr */
+			struct bio_vec	kiov[0];/* paged payload */
 		} paged;
 		struct {
-			struct kvec iov[1];  /* virt hdr + payload */
+			struct kvec	iov[1];	/* virt hdr + payload */
 		} virt;
 	} tx_frags;
 };
@@ -304,160 +304,160 @@ struct ksock_tx {			   /* transmit packet */
 
 /* network zero copy callback descriptor embedded in struct ksock_tx */
 
-#define SOCKNAL_RX_KSM_HEADER   1 /* reading ksock message header */
-#define SOCKNAL_RX_LNET_HEADER  2 /* reading lnet message header */
-#define SOCKNAL_RX_PARSE        3 /* Calling lnet_parse() */
-#define SOCKNAL_RX_PARSE_WAIT   4 /* waiting to be told to read the body */
-#define SOCKNAL_RX_LNET_PAYLOAD 5 /* reading lnet payload (to deliver here) */
-#define SOCKNAL_RX_SLOP         6 /* skipping body */
+#define SOCKNAL_RX_KSM_HEADER	1 /* reading ksock message header */
+#define SOCKNAL_RX_LNET_HEADER	2 /* reading lnet message header */
+#define SOCKNAL_RX_PARSE	3 /* Calling lnet_parse() */
+#define SOCKNAL_RX_PARSE_WAIT	4 /* waiting to be told to read the body */
+#define SOCKNAL_RX_LNET_PAYLOAD	5 /* reading lnet payload (to deliver here) */
+#define SOCKNAL_RX_SLOP		6 /* skipping body */
 
 struct ksock_conn {
-	struct ksock_peer  *ksnc_peer;        /* owning peer_ni */
-	struct ksock_route *ksnc_route;       /* owning route */
-	struct list_head   ksnc_list;         /* stash on peer_ni's conn list */
-	struct socket      *ksnc_sock;        /* actual socket */
-	void               *ksnc_saved_data_ready;  /* socket's original
-						     * data_ready() callback
-						     */
-	void               *ksnc_saved_write_space; /* socket's original
-						     * write_space() callback
-						     */
-	atomic_t           ksnc_conn_refcount;/* conn refcount */
-	atomic_t           ksnc_sock_refcount;/* sock refcount */
-	struct ksock_sched *ksnc_scheduler;	/* who schedules this connection
-						 */
-	u32              ksnc_myipaddr;     /* my IP */
-	u32              ksnc_ipaddr;       /* peer_ni's IP */
-	int                ksnc_port;         /* peer_ni's port */
-	signed int         ksnc_type:3;       /* type of connection, should be
-					       * signed value
-					       */
-	unsigned int       ksnc_closing:1;    /* being shut down */
-	unsigned int       ksnc_flip:1;       /* flip or not, only for V2.x */
-	unsigned int       ksnc_zc_capable:1; /* enable to ZC */
-	struct ksock_proto *ksnc_proto;       /* protocol for the connection */
+	struct ksock_peer      *ksnc_peer;		/* owning peer_ni */
+	struct ksock_route     *ksnc_route;		/* owning route */
+	struct list_head	ksnc_list;		/* stash on peer_ni's conn list */
+	struct socket	       *ksnc_sock;		/* actual socket */
+	void		       *ksnc_saved_data_ready;	/* socket's original
+							 * data_ready() callback
+							 */
+	void		       *ksnc_saved_write_space;	/* socket's original
+							 * write_space() callback
+							 */
+	atomic_t		ksnc_conn_refcount;	/* conn refcount */
+	atomic_t		ksnc_sock_refcount;	/* sock refcount */
+	struct ksock_sched     *ksnc_scheduler;		/* who schedules this connection
+							 */
+	u32			ksnc_myipaddr;		/* my IP */
+	u32			ksnc_ipaddr;		/* peer_ni's IP */
+	int			ksnc_port;		/* peer_ni's port */
+	signed int		ksnc_type:3;		/* type of connection, should be
+							 * signed value
+							 */
+	unsigned int		ksnc_closing:1;		/* being shut down */
+	unsigned int		ksnc_flip:1;		/* flip or not, only for V2.x */
+	unsigned int		ksnc_zc_capable:1;	/* enable to ZC */
+	struct ksock_proto     *ksnc_proto;		/* protocol for the connection */
 
 	/* reader */
-	struct list_head   ksnc_rx_list;      /* where I enq waiting input or a
-					       * forwarding descriptor
-					       */
-	time64_t	   ksnc_rx_deadline;  /* when (in secs) receive times
-					       * out
-					       */
-	u8               ksnc_rx_started;   /* started receiving a message */
-	u8               ksnc_rx_ready;     /* data ready to read */
-	u8               ksnc_rx_scheduled; /* being progressed */
-	u8               ksnc_rx_state;     /* what is being read */
-	int                ksnc_rx_nob_left;  /* # bytes to next hdr/body */
-	struct iov_iter    ksnc_rx_to;		/* copy destination */
-	struct kvec        ksnc_rx_iov_space[LNET_MAX_IOV]; /* space for frag descriptors */
-	u32              ksnc_rx_csum;      /* partial checksum for incoming
-					       * data
-					       */
-	void               *ksnc_cookie;      /* rx lnet_finalize passthru arg
-					       */
-	struct ksock_msg        ksnc_msg;          /* incoming message buffer:
-					       * V2.x message takes the
-					       * whole struct
-					       * V1.x message is a bare
-					       * struct lnet_hdr, it's stored in
-					       * ksnc_msg.ksm_u.lnetmsg
-					       */
+	struct list_head	ksnc_rx_list;		/* where I enq waiting input or a
+							 * forwarding descriptor
+							 */
+	time64_t		ksnc_rx_deadline;	/* when (in secs) receive times
+							 * out
+							 */
+	u8			ksnc_rx_started;	/* started receiving a message */
+	u8			ksnc_rx_ready;		/* data ready to read */
+	u8			ksnc_rx_scheduled;	/* being progressed */
+	u8			ksnc_rx_state;		/* what is being read */
+	int			ksnc_rx_nob_left;	/* # bytes to next hdr/body */
+	struct iov_iter		ksnc_rx_to;		/* copy destination */
+	struct kvec		ksnc_rx_iov_space[LNET_MAX_IOV]; /* space for frag descriptors */
+	u32			ksnc_rx_csum;		/* partial checksum for incoming
+							 * data
+							 */
+	void		       *ksnc_cookie;		/* rx lnet_finalize passthru arg
+							 */
+	struct ksock_msg	ksnc_msg;		/* incoming message buffer:
+							 * V2.x message takes the
+							 * whole struct
+							 * V1.x message is a bare
+							 * struct lnet_hdr, it's stored in
+							 * ksnc_msg.ksm_u.lnetmsg
+							 */
 	/* WRITER */
-	struct list_head   ksnc_tx_list;      /* where I enq waiting for output
-					       * space
-					       */
-	struct list_head   ksnc_tx_queue;     /* packets waiting to be sent */
-	struct ksock_tx	  *ksnc_tx_carrier;   /* next TX that can carry a LNet
-					       * message or ZC-ACK
-					       */
-	time64_t	   ksnc_tx_deadline;  /* when (in secs) tx times out
-					       */
-	int                ksnc_tx_bufnob;    /* send buffer marker */
-	atomic_t           ksnc_tx_nob;       /* # bytes queued */
-	int		   ksnc_tx_ready;     /* write space */
-	int		   ksnc_tx_scheduled; /* being progressed */
-	time64_t	   ksnc_tx_last_post; /* time stamp of the last posted
-					       * TX
-					       */
+	struct list_head	ksnc_tx_list;		/* where I enq waiting for output
+							 * space
+							 */
+	struct list_head	ksnc_tx_queue;		/* packets waiting to be sent */
+	struct ksock_tx	       *ksnc_tx_carrier;	/* next TX that can carry a LNet
+							 * message or ZC-ACK
+							 */
+	time64_t		ksnc_tx_deadline;	/* when (in secs) tx times out
+							 */
+	int			ksnc_tx_bufnob;		/* send buffer marker */
+	atomic_t		ksnc_tx_nob;		/* # bytes queued */
+	int			ksnc_tx_ready;		/* write space */
+	int			ksnc_tx_scheduled;	/* being progressed */
+	time64_t		ksnc_tx_last_post;	/* time stamp of the last posted
+							 * TX
+							 */
 };
 
 struct ksock_route {
-	struct list_head  ksnr_list;           /* chain on peer_ni route list */
-	struct list_head  ksnr_connd_list;     /* chain on ksnr_connd_routes */
-	struct ksock_peer *ksnr_peer;          /* owning peer_ni */
-	atomic_t          ksnr_refcount;       /* # users */
-	time64_t	  ksnr_timeout;        /* when (in secs) reconnection
-						* can happen next
-						*/
-	time64_t	  ksnr_retry_interval; /* how long between retries */
-	u32             ksnr_myipaddr;       /* my IP */
-	u32             ksnr_ipaddr;         /* IP address to connect to */
-	int               ksnr_port;           /* port to connect to */
-	unsigned int      ksnr_scheduled:1;    /* scheduled for attention */
-	unsigned int      ksnr_connecting:1;   /* connection establishment in
-						* progress
-						*/
-	unsigned int      ksnr_connected:4;    /* connections established by
-						* type
-						*/
-	unsigned int      ksnr_deleted:1;      /* been removed from peer_ni? */
-	unsigned int      ksnr_share_count;    /* created explicitly? */
-	int               ksnr_conn_count;     /* # conns established by this
-						* route
-						*/
+	struct list_head	ksnr_list;		/* chain on peer_ni route list */
+	struct list_head	ksnr_connd_list;	/* chain on ksnr_connd_routes */
+	struct ksock_peer      *ksnr_peer;		/* owning peer_ni */
+	atomic_t		ksnr_refcount;		/* # users */
+	time64_t		ksnr_timeout;		/* when (in secs) reconnection
+							 * can happen next
+							 */
+	time64_t		ksnr_retry_interval;	/* how long between retries */
+	u32			ksnr_myipaddr;		/* my IP */
+	u32			ksnr_ipaddr;		/* IP address to connect to */
+	int			ksnr_port;		/* port to connect to */
+	unsigned int		ksnr_scheduled:1;	/* scheduled for attention */
+	unsigned int		ksnr_connecting:1;	/* connection establishment in
+							 * progress
+							 */
+	unsigned int		ksnr_connected:4;	/* connections established by
+							 * type
+							 */
+	unsigned int		ksnr_deleted:1;		/* been removed from peer_ni? */
+	unsigned int		ksnr_share_count;	/* created explicitly? */
+	int			ksnr_conn_count;	/* # conns established by this
+							 * route
+							 */
 };
 
-#define SOCKNAL_KEEPALIVE_PING 1 /* cookie for keepalive ping */
+#define SOCKNAL_KEEPALIVE_PING	1	/* cookie for keepalive ping */
 
 struct ksock_peer {
-	struct list_head   ksnp_list;         /* stash on global peer_ni list */
-	time64_t	   ksnp_last_alive;     /* when (in seconds) I was last
-						 * alive
-						 */
-	struct lnet_process_id  ksnp_id;	/* who's on the other end(s) */
-	atomic_t           ksnp_refcount;       /* # users */
-	int                ksnp_sharecount;     /* lconf usage counter */
-	int                ksnp_closing;        /* being closed */
-	int                ksnp_accepting;      /* # passive connections pending
-						 */
-	int                ksnp_error;          /* errno on closing last conn */
-	u64              ksnp_zc_next_cookie; /* ZC completion cookie */
-	u64              ksnp_incarnation;    /* latest known peer_ni
-						 * incarnation
-						 */
-	struct ksock_proto *ksnp_proto;         /* latest known peer_ni
-						 * protocol
-						 */
-	struct list_head   ksnp_conns;          /* all active connections */
-	struct list_head   ksnp_routes;         /* routes */
-	struct list_head   ksnp_tx_queue;       /* waiting packets */
-	spinlock_t         ksnp_lock;           /* serialize, g_lock unsafe */
-	struct list_head   ksnp_zc_req_list;    /* zero copy requests wait for
-						 * ACK
-						 */
-	time64_t	   ksnp_send_keepalive; /* time to send keepalive */
-	struct lnet_ni	   *ksnp_ni;		/* which network */
-	int                ksnp_n_passive_ips;  /* # of... */
+	struct list_head	ksnp_list;		/* stash on global peer_ni list */
+	time64_t		ksnp_last_alive;	/* when (in seconds) I was last
+							 * alive
+							 */
+	struct lnet_process_id	ksnp_id;		/* who's on the other end(s) */
+	atomic_t		ksnp_refcount;		/* # users */
+	int			ksnp_sharecount;	/* lconf usage counter */
+	int			ksnp_closing;		/* being closed */
+	int			ksnp_accepting;		/* # passive connections pending
+							 */
+	int			ksnp_error;		/* errno on closing last conn */
+	u64			ksnp_zc_next_cookie;	/* ZC completion cookie */
+	u64			ksnp_incarnation;	/* latest known peer_ni
+							 * incarnation
+							 */
+	struct ksock_proto     *ksnp_proto;		/* latest known peer_ni
+							 * protocol
+							 */
+	struct list_head	ksnp_conns;		/* all active connections */
+	struct list_head	ksnp_routes;		/* routes */
+	struct list_head	ksnp_tx_queue;		/* waiting packets */
+	spinlock_t		ksnp_lock;		/* serialize, g_lock unsafe */
+	struct list_head	ksnp_zc_req_list;	/* zero copy requests wait for
+							 * ACK
+							 */
+	time64_t		ksnp_send_keepalive;	/* time to send keepalive */
+	struct lnet_ni	       *ksnp_ni;		/* which network */
+	int			ksnp_n_passive_ips;	/* # of... */
 
 	/* preferred local interfaces */
-	u32              ksnp_passive_ips[LNET_INTERFACES_NUM];
+	u32			ksnp_passive_ips[LNET_INTERFACES_NUM];
 };
 
 struct ksock_connreq {
-	struct list_head ksncr_list;  /* stash on ksnd_connd_connreqs */
-	struct lnet_ni	 *ksncr_ni;	/* chosen NI */
-	struct socket    *ksncr_sock; /* accepted socket */
+	struct list_head	ksncr_list;	/* stash on ksnd_connd_connreqs */
+	struct lnet_ni	       *ksncr_ni;	/* chosen NI */
+	struct socket	       *ksncr_sock;	/* accepted socket */
 };
 
 extern struct ksock_nal_data ksocknal_data;
 extern struct ksock_tunables ksocknal_tunables;
 
-#define SOCKNAL_MATCH_NO  0 /* TX can't match type of connection */
-#define SOCKNAL_MATCH_YES 1 /* TX matches type of connection */
-#define SOCKNAL_MATCH_MAY 2 /* TX can be sent on the connection, but not
-			     * preferred
-			     */
+#define SOCKNAL_MATCH_NO	0 /* TX can't match type of connection */
+#define SOCKNAL_MATCH_YES	1 /* TX matches type of connection */
+#define SOCKNAL_MATCH_MAY	2 /* TX can be sent on the connection, but not
+				   * preferred
+				   */
 
 struct ksock_proto {
 	/* version number of protocol */
@@ -501,12 +501,12 @@ struct ksock_proto {
 extern struct ksock_proto ksocknal_protocol_v2x;
 extern struct ksock_proto ksocknal_protocol_v3x;
 
-#define KSOCK_PROTO_V1_MAJOR LNET_PROTO_TCP_VERSION_MAJOR
-#define KSOCK_PROTO_V1_MINOR LNET_PROTO_TCP_VERSION_MINOR
-#define KSOCK_PROTO_V1       KSOCK_PROTO_V1_MAJOR
+#define KSOCK_PROTO_V1_MAJOR	LNET_PROTO_TCP_VERSION_MAJOR
+#define KSOCK_PROTO_V1_MINOR	LNET_PROTO_TCP_VERSION_MINOR
+#define KSOCK_PROTO_V1		KSOCK_PROTO_V1_MAJOR
 
 #ifndef CPU_MASK_NONE
-#define CPU_MASK_NONE   0UL
+#define CPU_MASK_NONE		0UL
 #endif
 
 static inline int
@@ -646,15 +646,15 @@ int ksocknal_create_conn(struct lnet_ni *ni, struct ksock_route *route,
 void ksocknal_close_conn_locked(struct ksock_conn *conn, int why);
 void ksocknal_terminate_conn(struct ksock_conn *conn);
 void ksocknal_destroy_conn(struct ksock_conn *conn);
-int  ksocknal_close_peer_conns_locked(struct ksock_peer *peer_ni,
-				      u32 ipaddr, int why);
+int ksocknal_close_peer_conns_locked(struct ksock_peer *peer_ni,
+				     u32 ipaddr, int why);
 int ksocknal_close_conn_and_siblings(struct ksock_conn *conn, int why);
 int ksocknal_close_matching_conns(struct lnet_process_id id, u32 ipaddr);
 struct ksock_conn *ksocknal_find_conn_locked(struct ksock_peer *peer_ni,
 					     struct ksock_tx *tx, int nonblk);
 
-int  ksocknal_launch_packet(struct lnet_ni *ni, struct ksock_tx *tx,
-			    struct lnet_process_id id);
+int ksocknal_launch_packet(struct lnet_ni *ni, struct ksock_tx *tx,
+			   struct lnet_process_id id);
 struct ksock_tx *ksocknal_alloc_tx(int type, int size);
 void ksocknal_free_tx(struct ksock_tx *tx);
 struct ksock_tx *ksocknal_alloc_tx_noop(u64 cookie, int nonblk);
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
index dd4fb69..8e20f43 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
@@ -56,7 +56,7 @@ struct ksock_tx *
 	tx->tx_zc_aborted = 0;
 	tx->tx_zc_capable = 0;
 	tx->tx_zc_checked = 0;
-	tx->tx_desc_size  = size;
+	tx->tx_desc_size = size;
 
 	atomic_inc(&ksocknal_data.ksnd_nactive_txs);
 
@@ -74,13 +74,13 @@ struct ksock_tx *
 		return NULL;
 	}
 
-	tx->tx_conn    = NULL;
+	tx->tx_conn = NULL;
 	tx->tx_lnetmsg = NULL;
-	tx->tx_kiov    = NULL;
-	tx->tx_nkiov   = 0;
-	tx->tx_iov     = tx->tx_frags.virt.iov;
-	tx->tx_niov    = 1;
-	tx->tx_nonblk  = nonblk;
+	tx->tx_kiov = NULL;
+	tx->tx_nkiov = 0;
+	tx->tx_iov = tx->tx_frags.virt.iov;
+	tx->tx_niov = 1;
+	tx->tx_nonblk = nonblk;
 
 	tx->tx_msg.ksm_csum = 0;
 	tx->tx_msg.ksm_type = KSOCK_MSG_NOOP;
@@ -228,7 +228,6 @@ struct ksock_tx *
 		}
 
 		if (rc <= 0) { /* Didn't write anything? */
-
 			if (!rc) /* some stacks return 0 instead of -EAGAIN */
 				rc = -EAGAIN;
 
@@ -260,7 +259,6 @@ struct ksock_tx *
 	 * status inside ksocknal_lib_recv
 	 */
 	rc = ksocknal_lib_recv(conn);
-
 	if (rc <= 0)
 		return rc;
 
@@ -316,7 +314,6 @@ struct ksock_tx *
 		}
 
 		/* Completed a fragment */
-
 		if (!iov_iter_count(&conn->ksnc_rx_to)) {
 			rc = 1;
 			break;
@@ -521,7 +518,6 @@ struct ksock_tx *
 ksocknal_launch_connection_locked(struct ksock_route *route)
 {
 	/* called holding write lock on ksnd_global_lock */
-
 	LASSERT(!route->ksnr_scheduled);
 	LASSERT(!route->ksnr_connecting);
 	LASSERT(ksocknal_route_mask() & ~route->ksnr_connected);
@@ -588,7 +584,7 @@ struct ksock_conn *
 			    (tnob == nob && *ksocknal_tunables.ksnd_round_robin &&
 			     typed->ksnc_tx_last_post > c->ksnc_tx_last_post)) {
 				typed = c;
-				tnob  = nob;
+				tnob = nob;
 			}
 			break;
 
@@ -760,7 +756,6 @@ struct ksock_route *
 	struct ksock_route *route;
 
 	list_for_each_entry(route, &peer_ni->ksnp_routes, ksnr_list) {
-
 		LASSERT(!route->ksnr_connecting || route->ksnr_scheduled);
 
 		if (route->ksnr_scheduled)
@@ -978,7 +973,6 @@ struct ksock_route *
 {
 	static char ksocknal_slop_buffer[4096];
 	struct kvec *kvec = conn->ksnc_rx_iov_space;
-
 	int nob;
 	unsigned int niov;
 	int skipped;
@@ -1001,8 +995,8 @@ struct ksock_route *
 			kvec->iov_base = &conn->ksnc_msg;
 			kvec->iov_len = offsetof(struct ksock_msg, ksm_u);
 			conn->ksnc_rx_nob_left = offsetof(struct ksock_msg, ksm_u);
-			iov_iter_kvec(&conn->ksnc_rx_to, READ, kvec,
-					1, offsetof(struct ksock_msg, ksm_u));
+			iov_iter_kvec(&conn->ksnc_rx_to, READ, kvec, 1,
+				      offsetof(struct ksock_msg, ksm_u));
 			break;
 
 		case KSOCK_PROTO_V1:
@@ -1011,8 +1005,8 @@ struct ksock_route *
 			kvec->iov_base = &conn->ksnc_msg.ksm_u.lnetmsg;
 			kvec->iov_len = sizeof(struct lnet_hdr);
 			conn->ksnc_rx_nob_left = sizeof(struct lnet_hdr);
-			iov_iter_kvec(&conn->ksnc_rx_to, READ, kvec,
-					1, sizeof(struct lnet_hdr));
+			iov_iter_kvec(&conn->ksnc_rx_to, READ, kvec, 1,
+				      sizeof(struct lnet_hdr));
 			break;
 
 		default:
@@ -1035,7 +1029,7 @@ struct ksock_route *
 		nob = min_t(int, nob_to_skip, sizeof(ksocknal_slop_buffer));
 
 		kvec[niov].iov_base = ksocknal_slop_buffer;
-		kvec[niov].iov_len  = nob;
+		kvec[niov].iov_len = nob;
 		niov++;
 		skipped += nob;
 		nob_to_skip -= nob;
@@ -1063,7 +1057,7 @@ struct ksock_route *
 		conn->ksnc_rx_state == SOCKNAL_RX_LNET_PAYLOAD ||
 		conn->ksnc_rx_state == SOCKNAL_RX_LNET_HEADER ||
 		conn->ksnc_rx_state == SOCKNAL_RX_SLOP);
- again:
+again:
 	if (iov_iter_count(&conn->ksnc_rx_to)) {
 		rc = ksocknal_receive(conn);
 
@@ -1157,8 +1151,8 @@ struct ksock_route *
 		kvec->iov_base = &conn->ksnc_msg.ksm_u.lnetmsg;
 		kvec->iov_len = sizeof(struct ksock_lnet_msg);
 
-		iov_iter_kvec(&conn->ksnc_rx_to, READ, kvec,
-				1, sizeof(struct ksock_lnet_msg));
+		iov_iter_kvec(&conn->ksnc_rx_to, READ, kvec, 1,
+			      sizeof(struct ksock_lnet_msg));
 
 		goto again;     /* read lnet header now */
 
@@ -1295,8 +1289,8 @@ struct ksock_route *
 	spin_lock_bh(&sched->kss_lock);
 
 	rc = !ksocknal_data.ksnd_shuttingdown &&
-	      list_empty(&sched->kss_rx_conns) &&
-	      list_empty(&sched->kss_tx_conns);
+	     list_empty(&sched->kss_rx_conns) &&
+	     list_empty(&sched->kss_tx_conns);
 
 	spin_unlock_bh(&sched->kss_lock);
 	return rc;
@@ -1419,7 +1413,6 @@ int ksocknal_scheduler(void *arg)
 			}
 
 			rc = ksocknal_process_transmit(conn, tx);
-
 			if (rc == -ENOMEM || rc == -EAGAIN) {
 				/*
 				 * Incomplete send: replace tx on HEAD of
@@ -1879,7 +1872,7 @@ void ksocknal_write_callback(struct ksock_conn *conn)
 	write_unlock_bh(&ksocknal_data.ksnd_global_lock);
 	return retry_later;
 
- failed:
+failed:
 	write_lock_bh(&ksocknal_data.ksnd_global_lock);
 
 	route->ksnr_scheduled = 0;
@@ -2026,7 +2019,6 @@ void ksocknal_write_callback(struct ksock_conn *conn)
 		return 0;
 
 	/* no creating in past 120 seconds */
-
 	return ksocknal_data.ksnd_connd_running >
 	       ksocknal_data.ksnd_connd_connecting + SOCKNAL_CONND_RESV;
 }
@@ -2341,7 +2333,7 @@ void ksocknal_write_callback(struct ksock_conn *conn)
 	struct ksock_conn *conn;
 	struct ksock_tx *tx;
 
- again:
+again:
 	/*
 	 * NB. We expect to have a look at all the peers and not find any
 	 * connections to time out, so we just use a shared lock while we
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib.c
index 565c50c..a190869 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib.c
@@ -75,14 +75,14 @@
 int
 ksocknal_lib_send_iov(struct ksock_conn *conn, struct ksock_tx *tx)
 {
-	struct msghdr msg = {.msg_flags = MSG_DONTWAIT};
+	struct msghdr msg = { .msg_flags = MSG_DONTWAIT };
 	struct socket *sock = conn->ksnc_sock;
 	int nob, i;
 
-	if (*ksocknal_tunables.ksnd_enable_csum	&& /* checksum enabled */
-	    conn->ksnc_proto == &ksocknal_protocol_v2x && /* V2.x connection  */
-	    tx->tx_nob == tx->tx_resid		 && /* frist sending    */
-	    !tx->tx_msg.ksm_csum)		     /* not checksummed  */
+	if (*ksocknal_tunables.ksnd_enable_csum	&&		/* checksum enabled */
+	    conn->ksnc_proto == &ksocknal_protocol_v2x &&	/* V2.x connection */
+	    tx->tx_nob == tx->tx_resid &&			/* first sending */
+	    !tx->tx_msg.ksm_csum)				/* not checksummed */
 		ksocknal_lib_csum_tx(tx);
 
 	for (nob = i = 0; i < tx->tx_niov; i++)
@@ -130,7 +130,7 @@
 			rc = tcp_sendpage(sk, page, offset, fragsize, msgflg);
 		}
 	} else {
-		struct msghdr msg = {.msg_flags = MSG_DONTWAIT};
+		struct msghdr msg = { .msg_flags = MSG_DONTWAIT };
 		int i;
 
 		for (nob = i = 0; i < tx->tx_nkiov; i++)
@@ -144,6 +144,7 @@
 			      kiov, tx->tx_nkiov, nob);
 		rc = sock_sendmsg(sock, &msg);
 	}
+
 	return rc;
 }
 
@@ -166,6 +167,7 @@
 static int lustre_csum(struct kvec *v, void *context)
 {
 	struct ksock_conn *conn = context;
+
 	conn->ksnc_rx_csum = crc32_le(conn->ksnc_rx_csum,
 				      v->iov_base, v->iov_len);
 	return 0;
@@ -325,7 +327,7 @@ static int lustre_csum(struct kvec *v, void *context)
 		return rc;
 	}
 
-/* TCP_BACKOFF_* sockopt tunables unsupported in stock kernels */
+	/* TCP_BACKOFF_* sockopt tunables unsupported in stock kernels */
 
 	/* snapshot tunables */
 	keep_idle  = *ksocknal_tunables.ksnd_keepalive_idle;
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_modparams.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_modparams.c
index da59100..0c923f9 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_modparams.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_modparams.c
@@ -145,36 +145,36 @@
 int ksocknal_tunables_init(void)
 {
 	/* initialize ksocknal_tunables structure */
-	ksocknal_tunables.ksnd_timeout            = &sock_timeout;
-	ksocknal_tunables.ksnd_nscheds            = &nscheds;
-	ksocknal_tunables.ksnd_nconnds            = &nconnds;
-	ksocknal_tunables.ksnd_nconnds_max        = &nconnds_max;
-	ksocknal_tunables.ksnd_min_reconnectms    = &min_reconnectms;
-	ksocknal_tunables.ksnd_max_reconnectms    = &max_reconnectms;
-	ksocknal_tunables.ksnd_eager_ack          = &eager_ack;
-	ksocknal_tunables.ksnd_typed_conns        = &typed_conns;
-	ksocknal_tunables.ksnd_min_bulk           = &min_bulk;
-	ksocknal_tunables.ksnd_tx_buffer_size     = &tx_buffer_size;
-	ksocknal_tunables.ksnd_rx_buffer_size     = &rx_buffer_size;
-	ksocknal_tunables.ksnd_nagle              = &nagle;
-	ksocknal_tunables.ksnd_round_robin        = &round_robin;
-	ksocknal_tunables.ksnd_keepalive          = &keepalive;
-	ksocknal_tunables.ksnd_keepalive_idle     = &keepalive_idle;
-	ksocknal_tunables.ksnd_keepalive_count    = &keepalive_count;
-	ksocknal_tunables.ksnd_keepalive_intvl    = &keepalive_intvl;
-	ksocknal_tunables.ksnd_credits            = &credits;
-	ksocknal_tunables.ksnd_peertxcredits      = &peer_credits;
-	ksocknal_tunables.ksnd_peerrtrcredits     = &peer_buffer_credits;
-	ksocknal_tunables.ksnd_peertimeout        = &peer_timeout;
-	ksocknal_tunables.ksnd_enable_csum        = &enable_csum;
-	ksocknal_tunables.ksnd_inject_csum_error  = &inject_csum_error;
-	ksocknal_tunables.ksnd_nonblk_zcack       = &nonblk_zcack;
-	ksocknal_tunables.ksnd_zc_min_payload     = &zc_min_payload;
-	ksocknal_tunables.ksnd_zc_recv            = &zc_recv;
+	ksocknal_tunables.ksnd_timeout = &sock_timeout;
+	ksocknal_tunables.ksnd_nscheds = &nscheds;
+	ksocknal_tunables.ksnd_nconnds = &nconnds;
+	ksocknal_tunables.ksnd_nconnds_max = &nconnds_max;
+	ksocknal_tunables.ksnd_min_reconnectms = &min_reconnectms;
+	ksocknal_tunables.ksnd_max_reconnectms = &max_reconnectms;
+	ksocknal_tunables.ksnd_eager_ack = &eager_ack;
+	ksocknal_tunables.ksnd_typed_conns = &typed_conns;
+	ksocknal_tunables.ksnd_min_bulk = &min_bulk;
+	ksocknal_tunables.ksnd_tx_buffer_size = &tx_buffer_size;
+	ksocknal_tunables.ksnd_rx_buffer_size = &rx_buffer_size;
+	ksocknal_tunables.ksnd_nagle = &nagle;
+	ksocknal_tunables.ksnd_round_robin = &round_robin;
+	ksocknal_tunables.ksnd_keepalive = &keepalive;
+	ksocknal_tunables.ksnd_keepalive_idle = &keepalive_idle;
+	ksocknal_tunables.ksnd_keepalive_count = &keepalive_count;
+	ksocknal_tunables.ksnd_keepalive_intvl = &keepalive_intvl;
+	ksocknal_tunables.ksnd_credits = &credits;
+	ksocknal_tunables.ksnd_peertxcredits = &peer_credits;
+	ksocknal_tunables.ksnd_peerrtrcredits = &peer_buffer_credits;
+	ksocknal_tunables.ksnd_peertimeout = &peer_timeout;
+	ksocknal_tunables.ksnd_enable_csum = &enable_csum;
+	ksocknal_tunables.ksnd_inject_csum_error = &inject_csum_error;
+	ksocknal_tunables.ksnd_nonblk_zcack = &nonblk_zcack;
+	ksocknal_tunables.ksnd_zc_min_payload = &zc_min_payload;
+	ksocknal_tunables.ksnd_zc_recv = &zc_recv;
 	ksocknal_tunables.ksnd_zc_recv_min_nfrags = &zc_recv_min_nfrags;
 
 #if SOCKNAL_VERSION_DEBUG
-	ksocknal_tunables.ksnd_protocol           = &protocol;
+	ksocknal_tunables.ksnd_protocol = &protocol;
 #endif
 
 	if (*ksocknal_tunables.ksnd_zc_min_payload < (2 << 10))
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_proto.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_proto.c
index 91bed59..c694fec 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_proto.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_proto.c
@@ -116,7 +116,7 @@
 static struct ksock_tx *
 ksocknal_queue_tx_msg_v2(struct ksock_conn *conn, struct ksock_tx *tx_msg)
 {
-	struct ksock_tx *tx  = conn->ksnc_tx_carrier;
+	struct ksock_tx *tx = conn->ksnc_tx_carrier;
 
 	/*
 	 * Enqueue tx_msg:
@@ -220,7 +220,7 @@
 	/* takes two or more cookies already */
 
 	if (tx->tx_msg.ksm_zc_cookies[0] > tx->tx_msg.ksm_zc_cookies[1]) {
-		u64   tmp = 0;
+		u64 tmp = 0;
 
 		/* two separated cookies: (a+2, a) or (a+1, a) */
 		LASSERT(tx->tx_msg.ksm_zc_cookies[0] -
@@ -479,7 +479,7 @@
 	 * Re-organize V2.x message header to V1.x (struct lnet_hdr)
 	 * header and send out
 	 */
-	hmv->magic         = cpu_to_le32(LNET_PROTO_TCP_MAGIC);
+	hmv->magic = cpu_to_le32(LNET_PROTO_TCP_MAGIC);
 	hmv->version_major = cpu_to_le16(KSOCK_PROTO_V1_MAJOR);
 	hmv->version_minor = cpu_to_le16(KSOCK_PROTO_V1_MINOR);
 
@@ -537,7 +537,7 @@
 	struct socket *sock = conn->ksnc_sock;
 	int rc;
 
-	hello->kshm_magic   = LNET_PROTO_MAGIC;
+	hello->kshm_magic = LNET_PROTO_MAGIC;
 	hello->kshm_version = conn->ksnc_proto->pro_version;
 
 	if (the_lnet.ln_testprotocompat) {
@@ -607,12 +607,11 @@
 		goto out;
 	}
 
-	hello->kshm_src_nid         = le64_to_cpu(hdr->src_nid);
-	hello->kshm_src_pid         = le32_to_cpu(hdr->src_pid);
+	hello->kshm_src_nid = le64_to_cpu(hdr->src_nid);
+	hello->kshm_src_pid = le32_to_cpu(hdr->src_pid);
 	hello->kshm_src_incarnation = le64_to_cpu(hdr->msg.hello.incarnation);
-	hello->kshm_ctype           = le32_to_cpu(hdr->msg.hello.type);
-	hello->kshm_nips            = le32_to_cpu(hdr->payload_length) /
-						  sizeof(u32);
+	hello->kshm_ctype = le32_to_cpu(hdr->msg.hello.type);
+	hello->kshm_nips = le32_to_cpu(hdr->payload_length) / sizeof(u32);
 
 	if (hello->kshm_nips > LNET_INTERFACES_NUM) {
 		CERROR("Bad nips %d from ip %pI4h\n",
@@ -724,7 +723,7 @@
 	LASSERT(tx->tx_lnetmsg);
 
 	tx->tx_iov[0].iov_base = &tx->tx_lnetmsg->msg_hdr;
-	tx->tx_iov[0].iov_len  = sizeof(struct lnet_hdr);
+	tx->tx_iov[0].iov_len = sizeof(struct lnet_hdr);
 
 	tx->tx_nob = tx->tx_lnetmsg->msg_len + sizeof(struct lnet_hdr);
 	tx->tx_resid = tx->tx_lnetmsg->msg_len + sizeof(struct lnet_hdr);
@@ -771,40 +770,40 @@
 }
 
 struct ksock_proto ksocknal_protocol_v1x = {
-	.pro_version        = KSOCK_PROTO_V1,
-	.pro_send_hello     = ksocknal_send_hello_v1,
-	.pro_recv_hello     = ksocknal_recv_hello_v1,
-	.pro_pack           = ksocknal_pack_msg_v1,
-	.pro_unpack         = ksocknal_unpack_msg_v1,
-	.pro_queue_tx_msg   = ksocknal_queue_tx_msg_v1,
-	.pro_handle_zcreq   = NULL,
-	.pro_handle_zcack   = NULL,
-	.pro_queue_tx_zcack = NULL,
-	.pro_match_tx       = ksocknal_match_tx
+	.pro_version		= KSOCK_PROTO_V1,
+	.pro_send_hello		= ksocknal_send_hello_v1,
+	.pro_recv_hello		= ksocknal_recv_hello_v1,
+	.pro_pack		= ksocknal_pack_msg_v1,
+	.pro_unpack		= ksocknal_unpack_msg_v1,
+	.pro_queue_tx_msg	= ksocknal_queue_tx_msg_v1,
+	.pro_handle_zcreq	= NULL,
+	.pro_handle_zcack	= NULL,
+	.pro_queue_tx_zcack	= NULL,
+	.pro_match_tx		= ksocknal_match_tx
 };
 
 struct ksock_proto ksocknal_protocol_v2x = {
-	.pro_version        = KSOCK_PROTO_V2,
-	.pro_send_hello     = ksocknal_send_hello_v2,
-	.pro_recv_hello     = ksocknal_recv_hello_v2,
-	.pro_pack           = ksocknal_pack_msg_v2,
-	.pro_unpack         = ksocknal_unpack_msg_v2,
-	.pro_queue_tx_msg   = ksocknal_queue_tx_msg_v2,
-	.pro_queue_tx_zcack = ksocknal_queue_tx_zcack_v2,
-	.pro_handle_zcreq   = ksocknal_handle_zcreq,
-	.pro_handle_zcack   = ksocknal_handle_zcack,
-	.pro_match_tx       = ksocknal_match_tx
+	.pro_version		= KSOCK_PROTO_V2,
+	.pro_send_hello		= ksocknal_send_hello_v2,
+	.pro_recv_hello		= ksocknal_recv_hello_v2,
+	.pro_pack		= ksocknal_pack_msg_v2,
+	.pro_unpack		= ksocknal_unpack_msg_v2,
+	.pro_queue_tx_msg	= ksocknal_queue_tx_msg_v2,
+	.pro_queue_tx_zcack	= ksocknal_queue_tx_zcack_v2,
+	.pro_handle_zcreq	= ksocknal_handle_zcreq,
+	.pro_handle_zcack	= ksocknal_handle_zcack,
+	.pro_match_tx		= ksocknal_match_tx
 };
 
 struct ksock_proto ksocknal_protocol_v3x = {
-	.pro_version        = KSOCK_PROTO_V3,
-	.pro_send_hello     = ksocknal_send_hello_v2,
-	.pro_recv_hello     = ksocknal_recv_hello_v2,
-	.pro_pack           = ksocknal_pack_msg_v2,
-	.pro_unpack         = ksocknal_unpack_msg_v2,
-	.pro_queue_tx_msg   = ksocknal_queue_tx_msg_v2,
-	.pro_queue_tx_zcack = ksocknal_queue_tx_zcack_v3,
-	.pro_handle_zcreq   = ksocknal_handle_zcreq,
-	.pro_handle_zcack   = ksocknal_handle_zcack,
-	.pro_match_tx       = ksocknal_match_tx_v3
+	.pro_version		= KSOCK_PROTO_V3,
+	.pro_send_hello		= ksocknal_send_hello_v2,
+	.pro_recv_hello		= ksocknal_recv_hello_v2,
+	.pro_pack		= ksocknal_pack_msg_v2,
+	.pro_unpack		= ksocknal_unpack_msg_v2,
+	.pro_queue_tx_msg	= ksocknal_queue_tx_msg_v2,
+	.pro_queue_tx_zcack	= ksocknal_queue_tx_zcack_v3,
+	.pro_handle_zcreq	= ksocknal_handle_zcreq,
+	.pro_handle_zcack	= ksocknal_handle_zcack,
+	.pro_match_tx		= ksocknal_match_tx_v3
 };
-- 
1.8.3.1
