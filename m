From: James Simmons <jsimmons@infradead.org>
Date: Sun, 26 Feb 2017 19:41:38 -0500
Subject: [lustre-devel] [PATCH 13/34] staging: lustre: lnet: change
	lnet_ni_t to proper structure
In-Reply-To: <1488156119-19670-1-git-send-email-jsimmons@infradead.org>
References: <1488156119-19670-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1488156119-19670-14-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@yahoo.com>

Change lnet_ni_t from typedef to proper structure.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-on: https://review.whamcloud.com/20831
Reviewed-by: Olaf Weber <olaf@sgi.com>
Reviewed-by: Doug Oucharek <doug.s.oucharek@intel.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/include/linux/lnet/lib-lnet.h   | 42 ++++++++---------
 .../staging/lustre/include/linux/lnet/lib-types.h  | 10 ++--
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c    | 26 ++++++-----
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h    | 17 +++----
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c | 53 ++++++++++++----------
 .../lustre/lnet/klnds/o2iblnd/o2iblnd_modparams.c  |  2 +-
 .../staging/lustre/lnet/klnds/socklnd/socklnd.c    | 43 +++++++++---------
 .../staging/lustre/lnet/klnds/socklnd/socklnd.h    | 41 +++++++++--------
 .../staging/lustre/lnet/klnds/socklnd/socklnd_cb.c | 15 +++---
 drivers/staging/lustre/lnet/lnet/acceptor.c        |  2 +-
 drivers/staging/lustre/lnet/lnet/api-ni.c          | 40 ++++++++--------
 drivers/staging/lustre/lnet/lnet/config.c          |  8 ++--
 drivers/staging/lustre/lnet/lnet/lib-move.c        | 38 ++++++++--------
 drivers/staging/lustre/lnet/lnet/lib-msg.c         |  2 +-
 drivers/staging/lustre/lnet/lnet/lo.c              |  8 ++--
 drivers/staging/lustre/lnet/lnet/peer.c            |  8 ++--
 drivers/staging/lustre/lnet/lnet/router.c          | 14 +++---
 drivers/staging/lustre/lnet/lnet/router_proc.c     |  5 +-
 18 files changed, 195 insertions(+), 179 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
index 9a29769..3d5913d 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
@@ -388,7 +388,7 @@ void lnet_res_lh_initialize(struct lnet_res_container *rec,
 }
 
 static inline void
-lnet_ni_addref_locked(lnet_ni_t *ni, int cpt)
+lnet_ni_addref_locked(struct lnet_ni *ni, int cpt)
 {
 	LASSERT(cpt >= 0 && cpt < LNET_CPT_NUMBER);
 	LASSERT(*ni->ni_refs[cpt] >= 0);
@@ -397,7 +397,7 @@ void lnet_res_lh_initialize(struct lnet_res_container *rec,
 }
 
 static inline void
-lnet_ni_addref(lnet_ni_t *ni)
+lnet_ni_addref(struct lnet_ni *ni)
 {
 	lnet_net_lock(0);
 	lnet_ni_addref_locked(ni, 0);
@@ -405,7 +405,7 @@ void lnet_res_lh_initialize(struct lnet_res_container *rec,
 }
 
 static inline void
-lnet_ni_decref_locked(lnet_ni_t *ni, int cpt)
+lnet_ni_decref_locked(struct lnet_ni *ni, int cpt)
 {
 	LASSERT(cpt >= 0 && cpt < LNET_CPT_NUMBER);
 	LASSERT(*ni->ni_refs[cpt] > 0);
@@ -414,15 +414,15 @@ void lnet_res_lh_initialize(struct lnet_res_container *rec,
 }
 
 static inline void
-lnet_ni_decref(lnet_ni_t *ni)
+lnet_ni_decref(struct lnet_ni *ni)
 {
 	lnet_net_lock(0);
 	lnet_ni_decref_locked(ni, 0);
 	lnet_net_unlock(0);
 }
 
-void lnet_ni_free(lnet_ni_t *ni);
-lnet_ni_t *
+void lnet_ni_free(struct lnet_ni *ni);
+struct lnet_ni *
 lnet_ni_alloc(__u32 net, struct cfs_expr_list *el, struct list_head *nilist);
 
 static inline int
@@ -444,16 +444,16 @@ void lnet_res_lh_initialize(struct lnet_res_container *rec,
 
 int lnet_cpt_of_nid_locked(lnet_nid_t nid);
 int lnet_cpt_of_nid(lnet_nid_t nid);
-lnet_ni_t *lnet_nid2ni_locked(lnet_nid_t nid, int cpt);
-lnet_ni_t *lnet_net2ni_locked(__u32 net, int cpt);
-lnet_ni_t *lnet_net2ni(__u32 net);
+struct lnet_ni *lnet_nid2ni_locked(lnet_nid_t nid, int cpt);
+struct lnet_ni *lnet_net2ni_locked(__u32 net, int cpt);
+struct lnet_ni *lnet_net2ni(__u32 net);
 
 extern int portal_rotor;
 
 int lnet_lib_init(void);
 void lnet_lib_exit(void);
 
-int lnet_notify(lnet_ni_t *ni, lnet_nid_t peer, int alive, unsigned long when);
+int lnet_notify(struct lnet_ni *ni, lnet_nid_t peer, int alive, unsigned long when);
 void lnet_notify_locked(lnet_peer_t *lp, int notifylnd, int alive,
 			unsigned long when);
 int lnet_add_route(__u32 net, __u32 hops, lnet_nid_t gateway_nid,
@@ -552,26 +552,26 @@ void lnet_ptl_attach_md(struct lnet_me *me, struct lnet_libmd *md,
 void lnet_portals_destroy(void);
 
 /* message functions */
-int lnet_parse(lnet_ni_t *ni, struct lnet_hdr *hdr,
+int lnet_parse(struct lnet_ni *ni, struct lnet_hdr *hdr,
 	       lnet_nid_t fromnid, void *private, int rdma_req);
-int lnet_parse_local(lnet_ni_t *ni, struct lnet_msg *msg);
-int lnet_parse_forward_locked(lnet_ni_t *ni, struct lnet_msg *msg);
+int lnet_parse_local(struct lnet_ni *ni, struct lnet_msg *msg);
+int lnet_parse_forward_locked(struct lnet_ni *ni, struct lnet_msg *msg);
 
-void lnet_recv(lnet_ni_t *ni, void *private, struct lnet_msg *msg,
+void lnet_recv(struct lnet_ni *ni, void *private, struct lnet_msg *msg,
 	       int delayed, unsigned int offset, unsigned int mlen,
 	       unsigned int rlen);
-void lnet_ni_recv(lnet_ni_t *ni, void *private, struct lnet_msg *msg,
+void lnet_ni_recv(struct lnet_ni *ni, void *private, struct lnet_msg *msg,
 		  int delayed, unsigned int offset,
 		  unsigned int mlen, unsigned int rlen);
 
-struct lnet_msg *lnet_create_reply_msg(lnet_ni_t *ni,
+struct lnet_msg *lnet_create_reply_msg(struct lnet_ni *ni,
 				       struct lnet_msg *get_msg);
-void lnet_set_reply_msg_len(lnet_ni_t *ni, struct lnet_msg *msg,
+void lnet_set_reply_msg_len(struct lnet_ni *ni, struct lnet_msg *msg,
 			    unsigned int len);
 
-void lnet_finalize(lnet_ni_t *ni, struct lnet_msg *msg, int rc);
+void lnet_finalize(struct lnet_ni *ni, struct lnet_msg *msg, int rc);
 
-void lnet_drop_message(lnet_ni_t *ni, int cpt, void *private,
+void lnet_drop_message(struct lnet_ni *ni, int cpt, void *private,
 		       unsigned int nob);
 void lnet_drop_delayed_msg_list(struct list_head *head, char *reason);
 void lnet_recv_delayed_msg_list(struct list_head *head);
@@ -662,7 +662,7 @@ int lnet_sock_connect(struct socket **sockp, int *fatal,
 void libcfs_sock_release(struct socket *sock);
 
 int lnet_peers_start_down(void);
-int lnet_peer_buffer_credits(lnet_ni_t *ni);
+int lnet_peer_buffer_credits(struct lnet_ni *ni);
 
 int lnet_router_checker_start(void);
 void lnet_router_checker_stop(void);
@@ -677,7 +677,7 @@ int lnet_sock_connect(struct socket **sockp, int *fatal,
 int lnet_nid2peer_locked(lnet_peer_t **lpp, lnet_nid_t nid, int cpt);
 lnet_peer_t *lnet_find_peer_locked(struct lnet_peer_table *ptable,
 				   lnet_nid_t nid);
-void lnet_peer_tables_cleanup(lnet_ni_t *ni);
+void lnet_peer_tables_cleanup(struct lnet_ni *ni);
 void lnet_peer_tables_destroy(void);
 int lnet_peer_tables_create(void);
 void lnet_debug_peer(lnet_nid_t nid);
diff --git a/drivers/staging/lustre/include/linux/lnet/lib-types.h b/drivers/staging/lustre/include/linux/lnet/lib-types.h
index 8a65db2..bcfb0c7 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-types.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-types.h
@@ -252,7 +252,7 @@ struct lnet_tx_queue {
 	struct list_head	tq_delayed;	/* delayed TXs */
 };
 
-typedef struct lnet_ni {
+struct lnet_ni {
 	spinlock_t		  ni_lock;
 	struct list_head	  ni_list;	/* chain on ln_nis */
 	struct list_head	  ni_cptlist;	/* chain on ln_nis_cpt */
@@ -278,7 +278,7 @@ struct lnet_tx_queue {
 	char			 *ni_interfaces[LNET_MAX_INTERFACES];
 	/* original net namespace */
 	struct net		 *ni_net_ns;
-} lnet_ni_t;
+};
 
 #define LNET_PROTO_PING_MATCHBITS	0x8000000000000000LL
 
@@ -336,7 +336,7 @@ struct lnet_tx_queue {
 	unsigned long		 lp_last_alive;	/* when I was last alive */
 	unsigned long		 lp_last_query;	/* when lp_ni was queried
 						   last time */
-	lnet_ni_t		*lp_ni;		/* interface peer is on */
+	struct lnet_ni		*lp_ni;		/* interface peer is on */
 	lnet_nid_t		 lp_nid;	/* peer's NID */
 	int			 lp_refcount;	/* # refs */
 	int			 lp_cpt;	/* CPT this peer attached on */
@@ -364,7 +364,7 @@ struct lnet_peer_table {
 
 /*
  * peer aliveness is enabled only on routers for peers in a network where the
- * lnet_ni_t::ni_peertimeout has been set to a positive value
+ * lnet_ni::ni_peertimeout has been set to a positive value
  */
 #define lnet_peer_aliveness_enabled(lp) (the_lnet.ln_routing && \
 					 (lp)->lp_ni->ni_peertimeout > 0)
@@ -585,7 +585,7 @@ struct lnet_msg_container {
 	struct list_head		  ln_nis_cpt;
 	/* dying LND instances */
 	struct list_head		  ln_nis_zombie;
-	lnet_ni_t			 *ln_loni;	/* the loopback NI */
+	struct lnet_ni			 *ln_loni;	/* the loopback NI */
 
 	/* remote networks with routes to them */
 	struct list_head		 *ln_remote_nets_hash;
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
index 29a5263..79321e4 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
@@ -174,7 +174,7 @@ static int kiblnd_unpack_rd(struct kib_msg *msg, int flip)
 	return 0;
 }
 
-void kiblnd_pack_msg(lnet_ni_t *ni, struct kib_msg *msg, int version,
+void kiblnd_pack_msg(struct lnet_ni *ni, struct kib_msg *msg, int version,
 		     int credits, lnet_nid_t dstnid, __u64 dststamp)
 {
 	struct kib_net *net = ni->ni_data;
@@ -313,7 +313,8 @@ int kiblnd_unpack_msg(struct kib_msg *msg, int nob)
 	return 0;
 }
 
-int kiblnd_create_peer(lnet_ni_t *ni, struct kib_peer **peerp, lnet_nid_t nid)
+int kiblnd_create_peer(struct lnet_ni *ni, struct kib_peer **peerp,
+		       lnet_nid_t nid)
 {
 	struct kib_peer *peer;
 	struct kib_net *net = ni->ni_data;
@@ -412,7 +413,7 @@ void kiblnd_unlink_peer_locked(struct kib_peer *peer)
 	kiblnd_peer_decref(peer);
 }
 
-static int kiblnd_get_peer_info(lnet_ni_t *ni, int index,
+static int kiblnd_get_peer_info(struct lnet_ni *ni, int index,
 				lnet_nid_t *nidp, int *count)
 {
 	struct kib_peer *peer;
@@ -468,7 +469,7 @@ static void kiblnd_del_peer_locked(struct kib_peer *peer)
 	 */
 }
 
-static int kiblnd_del_peer(lnet_ni_t *ni, lnet_nid_t nid)
+static int kiblnd_del_peer(struct lnet_ni *ni, lnet_nid_t nid)
 {
 	LIST_HEAD(zombies);
 	struct list_head *ptmp;
@@ -520,7 +521,7 @@ static int kiblnd_del_peer(lnet_ni_t *ni, lnet_nid_t nid)
 	return rc;
 }
 
-static struct kib_conn *kiblnd_get_conn_by_idx(lnet_ni_t *ni, int index)
+static struct kib_conn *kiblnd_get_conn_by_idx(struct lnet_ni *ni, int index)
 {
 	struct kib_peer *peer;
 	struct list_head *ptmp;
@@ -947,7 +948,7 @@ int kiblnd_close_stale_conns_locked(struct kib_peer *peer,
 	return count;
 }
 
-static int kiblnd_close_matching_conns(lnet_ni_t *ni, lnet_nid_t nid)
+static int kiblnd_close_matching_conns(struct lnet_ni *ni, lnet_nid_t nid)
 {
 	struct kib_peer *peer;
 	struct list_head *ptmp;
@@ -992,7 +993,7 @@ static int kiblnd_close_matching_conns(lnet_ni_t *ni, lnet_nid_t nid)
 	return !count ? -ENOENT : 0;
 }
 
-static int kiblnd_ctl(lnet_ni_t *ni, unsigned int cmd, void *arg)
+static int kiblnd_ctl(struct lnet_ni *ni, unsigned int cmd, void *arg)
 {
 	struct libcfs_ioctl_data *data = arg;
 	int rc = -EINVAL;
@@ -1045,7 +1046,8 @@ static int kiblnd_ctl(lnet_ni_t *ni, unsigned int cmd, void *arg)
 	return rc;
 }
 
-static void kiblnd_query(lnet_ni_t *ni, lnet_nid_t nid, unsigned long *when)
+static void kiblnd_query(struct lnet_ni *ni, lnet_nid_t nid,
+			 unsigned long *when)
 {
 	unsigned long last_alive = 0;
 	unsigned long now = cfs_time_current();
@@ -2143,8 +2145,8 @@ static void kiblnd_net_fini_pools(struct kib_net *net)
 	}
 }
 
-static int kiblnd_net_init_pools(struct kib_net *net, lnet_ni_t *ni, __u32 *cpts,
-				 int ncpts)
+static int kiblnd_net_init_pools(struct kib_net *net, struct lnet_ni *ni,
+				 __u32 *cpts, int ncpts)
 {
 	struct lnet_ioctl_config_o2iblnd_tunables *tunables;
 	int cpt;
@@ -2587,7 +2589,7 @@ static void kiblnd_base_shutdown(void)
 	module_put(THIS_MODULE);
 }
 
-static void kiblnd_shutdown(lnet_ni_t *ni)
+static void kiblnd_shutdown(struct lnet_ni *ni)
 {
 	struct kib_net *net = ni->ni_data;
 	rwlock_t *g_lock = &kiblnd_data.kib_global_lock;
@@ -2844,7 +2846,7 @@ static struct kib_dev *kiblnd_dev_search(char *ifname)
 	return alias;
 }
 
-static int kiblnd_startup(lnet_ni_t *ni)
+static int kiblnd_startup(struct lnet_ni *ni)
 {
 	char *ifname;
 	struct kib_dev *ibdev = NULL;
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
index dbd3b8e..16e437b 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
@@ -566,7 +566,7 @@ struct kib_conn {
 struct kib_peer {
 	struct list_head ibp_list;        /* stash on global peer list */
 	lnet_nid_t       ibp_nid;         /* who's on the other end(s) */
-	lnet_ni_t        *ibp_ni;         /* LNet interface */
+	struct lnet_ni	*ibp_ni;         /* LNet interface */
 	struct list_head ibp_conns;       /* all active connections */
 	struct list_head ibp_tx_queue;    /* msgs waiting for a conn */
 	__u64            ibp_incarnation; /* incarnation of peer */
@@ -763,7 +763,7 @@ struct kib_peer {
 kiblnd_need_noop(struct kib_conn *conn)
 {
 	struct lnet_ioctl_config_o2iblnd_tunables *tunables;
-	lnet_ni_t *ni = conn->ibc_peer->ibp_ni;
+	struct lnet_ni *ni = conn->ibc_peer->ibp_ni;
 
 	LASSERT(conn->ibc_state >= IBLND_CONN_ESTABLISHED);
 	tunables = &ni->ni_lnd_tunables->lt_tun_u.lt_o2ib;
@@ -1002,7 +1002,8 @@ int  kiblnd_cm_callback(struct rdma_cm_id *cmid,
 int  kiblnd_translate_mtu(int value);
 
 int  kiblnd_dev_failover(struct kib_dev *dev);
-int  kiblnd_create_peer(lnet_ni_t *ni, struct kib_peer **peerp, lnet_nid_t nid);
+int kiblnd_create_peer(struct lnet_ni *ni, struct kib_peer **peerp,
+		       lnet_nid_t nid);
 void kiblnd_destroy_peer(struct kib_peer *peer);
 bool kiblnd_reconnect_peer(struct kib_peer *peer);
 void kiblnd_destroy_dev(struct kib_dev *dev);
@@ -1019,19 +1020,19 @@ struct kib_conn *kiblnd_create_conn(struct kib_peer *peer,
 void kiblnd_close_conn(struct kib_conn *conn, int error);
 void kiblnd_close_conn_locked(struct kib_conn *conn, int error);
 
-void kiblnd_launch_tx(lnet_ni_t *ni, struct kib_tx *tx, lnet_nid_t nid);
-void kiblnd_txlist_done(lnet_ni_t *ni, struct list_head *txlist,
+void kiblnd_launch_tx(struct lnet_ni *ni, struct kib_tx *tx, lnet_nid_t nid);
+void kiblnd_txlist_done(struct lnet_ni *ni, struct list_head *txlist,
 			int status);
 
 void kiblnd_qp_event(struct ib_event *event, void *arg);
 void kiblnd_cq_event(struct ib_event *event, void *arg);
 void kiblnd_cq_completion(struct ib_cq *cq, void *arg);
 
-void kiblnd_pack_msg(lnet_ni_t *ni, struct kib_msg *msg, int version,
+void kiblnd_pack_msg(struct lnet_ni *ni, struct kib_msg *msg, int version,
 		     int credits, lnet_nid_t dstnid, __u64 dststamp);
 int  kiblnd_unpack_msg(struct kib_msg *msg, int nob);
 int  kiblnd_post_rx(struct kib_rx *rx, int credit);
 
-int kiblnd_send(lnet_ni_t *ni, void *private, struct lnet_msg *lntmsg);
-int kiblnd_recv(lnet_ni_t *ni, void *private, struct lnet_msg *lntmsg,
+int kiblnd_send(struct lnet_ni *ni, void *private, struct lnet_msg *lntmsg);
+int kiblnd_recv(struct lnet_ni *ni, void *private, struct lnet_msg *lntmsg,
 		int delayed, struct iov_iter *to, unsigned int rlen);
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
index 021e6ac..0c9b40f 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -40,18 +40,18 @@
 
 static void kiblnd_peer_alive(struct kib_peer *peer);
 static void kiblnd_peer_connect_failed(struct kib_peer *peer, int active, int error);
-static void kiblnd_init_tx_msg(lnet_ni_t *ni, struct kib_tx *tx,
+static void kiblnd_init_tx_msg(struct lnet_ni *ni, struct kib_tx *tx,
 			       int type, int body_nob);
 static int kiblnd_init_rdma(struct kib_conn *conn, struct kib_tx *tx, int type,
 			    int resid, struct kib_rdma_desc *dstrd,
 			    __u64 dstcookie);
 static void kiblnd_queue_tx_locked(struct kib_tx *tx, struct kib_conn *conn);
 static void kiblnd_queue_tx(struct kib_tx *tx, struct kib_conn *conn);
-static void kiblnd_unmap_tx(lnet_ni_t *ni, struct kib_tx *tx);
+static void kiblnd_unmap_tx(struct lnet_ni *ni, struct kib_tx *tx);
 static void kiblnd_check_sends_locked(struct kib_conn *conn);
 
 static void
-kiblnd_tx_done(lnet_ni_t *ni, struct kib_tx *tx)
+kiblnd_tx_done(struct lnet_ni *ni, struct kib_tx *tx)
 {
 	struct lnet_msg *lntmsg[2];
 	struct kib_net *net = ni->ni_data;
@@ -94,7 +94,7 @@ static int kiblnd_init_rdma(struct kib_conn *conn, struct kib_tx *tx, int type,
 }
 
 void
-kiblnd_txlist_done(lnet_ni_t *ni, struct list_head *txlist, int status)
+kiblnd_txlist_done(struct lnet_ni *ni, struct list_head *txlist, int status)
 {
 	struct kib_tx *tx;
 
@@ -110,7 +110,7 @@ static int kiblnd_init_rdma(struct kib_conn *conn, struct kib_tx *tx, int type,
 }
 
 static struct kib_tx *
-kiblnd_get_idle_tx(lnet_ni_t *ni, lnet_nid_t target)
+kiblnd_get_idle_tx(struct lnet_ni *ni, lnet_nid_t target)
 {
 	struct kib_net *net = (struct kib_net *)ni->ni_data;
 	struct list_head *node;
@@ -249,7 +249,7 @@ static int kiblnd_init_rdma(struct kib_conn *conn, struct kib_tx *tx, int type,
 kiblnd_handle_completion(struct kib_conn *conn, int txtype, int status, __u64 cookie)
 {
 	struct kib_tx *tx;
-	lnet_ni_t *ni = conn->ibc_peer->ibp_ni;
+	struct lnet_ni *ni = conn->ibc_peer->ibp_ni;
 	int idle;
 
 	spin_lock(&conn->ibc_lock);
@@ -286,7 +286,7 @@ static int kiblnd_init_rdma(struct kib_conn *conn, struct kib_tx *tx, int type,
 static void
 kiblnd_send_completion(struct kib_conn *conn, int type, int status, __u64 cookie)
 {
-	lnet_ni_t *ni = conn->ibc_peer->ibp_ni;
+	struct lnet_ni *ni = conn->ibc_peer->ibp_ni;
 	struct kib_tx *tx = kiblnd_get_idle_tx(ni, conn->ibc_peer->ibp_nid);
 
 	if (!tx) {
@@ -307,7 +307,7 @@ static int kiblnd_init_rdma(struct kib_conn *conn, struct kib_tx *tx, int type,
 {
 	struct kib_msg *msg = rx->rx_msg;
 	struct kib_conn *conn = rx->rx_conn;
-	lnet_ni_t *ni = conn->ibc_peer->ibp_ni;
+	struct lnet_ni *ni = conn->ibc_peer->ibp_ni;
 	int credits = msg->ibm_credits;
 	struct kib_tx *tx;
 	int rc = 0;
@@ -468,7 +468,7 @@ static int kiblnd_init_rdma(struct kib_conn *conn, struct kib_tx *tx, int type,
 {
 	struct kib_msg *msg = rx->rx_msg;
 	struct kib_conn *conn = rx->rx_conn;
-	lnet_ni_t *ni = conn->ibc_peer->ibp_ni;
+	struct lnet_ni *ni = conn->ibc_peer->ibp_ni;
 	struct kib_net *net = ni->ni_data;
 	int rc;
 	int err = -EIO;
@@ -590,7 +590,7 @@ static int kiblnd_init_rdma(struct kib_conn *conn, struct kib_tx *tx, int type,
 	return 0;
 }
 
-static void kiblnd_unmap_tx(lnet_ni_t *ni, struct kib_tx *tx)
+static void kiblnd_unmap_tx(struct lnet_ni *ni, struct kib_tx *tx)
 {
 	struct kib_net *net = ni->ni_data;
 
@@ -606,8 +606,8 @@ static void kiblnd_unmap_tx(lnet_ni_t *ni, struct kib_tx *tx)
 	}
 }
 
-static int kiblnd_map_tx(lnet_ni_t *ni, struct kib_tx *tx, struct kib_rdma_desc *rd,
-			 int nfrags)
+static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
+			 struct kib_rdma_desc *rd, int nfrags)
 {
 	struct kib_net *net = ni->ni_data;
 	struct kib_hca_dev *hdev = net->ibn_dev->ibd_hdev;
@@ -639,8 +639,9 @@ static int kiblnd_map_tx(lnet_ni_t *ni, struct kib_tx *tx, struct kib_rdma_desc
 }
 
 static int
-kiblnd_setup_rd_iov(lnet_ni_t *ni, struct kib_tx *tx, struct kib_rdma_desc *rd,
-		    unsigned int niov, const struct kvec *iov, int offset, int nob)
+kiblnd_setup_rd_iov(struct lnet_ni *ni, struct kib_tx *tx,
+		    struct kib_rdma_desc *rd, unsigned int niov,
+		    const struct kvec *iov, int offset, int nob)
 {
 	struct kib_net *net = ni->ni_data;
 	struct page *page;
@@ -696,8 +697,9 @@ static int kiblnd_map_tx(lnet_ni_t *ni, struct kib_tx *tx, struct kib_rdma_desc
 }
 
 static int
-kiblnd_setup_rd_kiov(lnet_ni_t *ni, struct kib_tx *tx, struct kib_rdma_desc *rd,
-		     int nkiov, const lnet_kiov_t *kiov, int offset, int nob)
+kiblnd_setup_rd_kiov(struct lnet_ni *ni, struct kib_tx *tx,
+		     struct kib_rdma_desc *rd, int nkiov,
+		     const lnet_kiov_t *kiov, int offset, int nob)
 {
 	struct kib_net *net = ni->ni_data;
 	struct scatterlist *sg;
@@ -899,7 +901,7 @@ static int kiblnd_map_tx(lnet_ni_t *ni, struct kib_tx *tx, struct kib_rdma_desc
 kiblnd_check_sends_locked(struct kib_conn *conn)
 {
 	int ver = conn->ibc_version;
-	lnet_ni_t *ni = conn->ibc_peer->ibp_ni;
+	struct lnet_ni *ni = conn->ibc_peer->ibp_ni;
 	struct kib_tx *tx;
 
 	/* Don't send anything until after the connection is established */
@@ -1011,7 +1013,8 @@ static int kiblnd_map_tx(lnet_ni_t *ni, struct kib_tx *tx, struct kib_rdma_desc
 }
 
 static void
-kiblnd_init_tx_msg(lnet_ni_t *ni, struct kib_tx *tx, int type, int body_nob)
+kiblnd_init_tx_msg(struct lnet_ni *ni, struct kib_tx *tx, int type,
+		   int body_nob)
 {
 	struct kib_hca_dev *hdev = tx->tx_pool->tpo_hdev;
 	struct ib_sge *sge = &tx->tx_sge[tx->tx_nwrq];
@@ -1353,7 +1356,7 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
 }
 
 void
-kiblnd_launch_tx(lnet_ni_t *ni, struct kib_tx *tx, lnet_nid_t nid)
+kiblnd_launch_tx(struct lnet_ni *ni, struct kib_tx *tx, lnet_nid_t nid)
 {
 	struct kib_peer *peer;
 	struct kib_peer *peer2;
@@ -1475,7 +1478,7 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
 }
 
 int
-kiblnd_send(lnet_ni_t *ni, void *private, struct lnet_msg *lntmsg)
+kiblnd_send(struct lnet_ni *ni, void *private, struct lnet_msg *lntmsg)
 {
 	struct lnet_hdr *hdr = &lntmsg->msg_hdr;
 	int type = lntmsg->msg_type;
@@ -1648,7 +1651,7 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
 }
 
 static void
-kiblnd_reply(lnet_ni_t *ni, struct kib_rx *rx, struct lnet_msg *lntmsg)
+kiblnd_reply(struct lnet_ni *ni, struct kib_rx *rx, struct lnet_msg *lntmsg)
 {
 	lnet_process_id_t target = lntmsg->msg_target;
 	unsigned int niov = lntmsg->msg_niov;
@@ -1709,7 +1712,7 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
 }
 
 int
-kiblnd_recv(lnet_ni_t *ni, void *private, struct lnet_msg *lntmsg,
+kiblnd_recv(struct lnet_ni *ni, void *private, struct lnet_msg *lntmsg,
 	    int delayed, struct iov_iter *to, unsigned int rlen)
 {
 	struct kib_rx *rx = private;
@@ -2157,7 +2160,7 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
 
 	if (!kiblnd_peer_active(peer) ||	/* peer has been deleted */
 	    conn->ibc_comms_error) {       /* error has happened already */
-		lnet_ni_t *ni = peer->ibp_ni;
+		struct lnet_ni *ni = peer->ibp_ni;
 
 		/* start to shut down connection */
 		kiblnd_close_conn_locked(conn, -ECONNABORTED);
@@ -2214,7 +2217,7 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
 	struct kib_peer *peer;
 	struct kib_peer *peer2;
 	struct kib_conn *conn;
-	lnet_ni_t *ni  = NULL;
+	struct lnet_ni *ni  = NULL;
 	struct kib_net *net = NULL;
 	lnet_nid_t nid;
 	struct rdma_conn_param cp;
@@ -2776,7 +2779,7 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
 kiblnd_check_connreply(struct kib_conn *conn, void *priv, int priv_nob)
 {
 	struct kib_peer *peer = conn->ibc_peer;
-	lnet_ni_t *ni = peer->ibp_ni;
+	struct lnet_ni *ni = peer->ibp_ni;
 	struct kib_net *net = ni->ni_data;
 	struct kib_msg *msg = priv;
 	int ver = conn->ibc_version;
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_modparams.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_modparams.c
index 3c81b527..3fe4d48 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_modparams.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_modparams.c
@@ -161,7 +161,7 @@ struct kib_tunables kiblnd_tunables = {
 static struct lnet_ioctl_config_o2iblnd_tunables default_tunables;
 
 /* # messages/RDMAs in-flight */
-int kiblnd_msg_queue_size(int version, lnet_ni_t *ni)
+int kiblnd_msg_queue_size(int version, struct lnet_ni *ni)
 {
 	if (version == IBLND_MSG_VERSION_1)
 		return IBLND_MSG_QUEUE_SIZE_V1;
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
index 258507f..f92fa4b 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
@@ -43,7 +43,7 @@
 struct ksock_nal_data ksocknal_data;
 
 static struct ksock_interface *
-ksocknal_ip2iface(lnet_ni_t *ni, __u32 ip)
+ksocknal_ip2iface(struct lnet_ni *ni, __u32 ip)
 {
 	struct ksock_net *net = ni->ni_data;
 	int i;
@@ -96,7 +96,7 @@
 }
 
 static int
-ksocknal_create_peer(struct ksock_peer **peerp, lnet_ni_t *ni,
+ksocknal_create_peer(struct ksock_peer **peerp, struct lnet_ni *ni,
 		     lnet_process_id_t id)
 {
 	int cpt = lnet_cpt_of_nid(id.nid);
@@ -173,7 +173,7 @@
 }
 
 struct ksock_peer *
-ksocknal_find_peer_locked(lnet_ni_t *ni, lnet_process_id_t id)
+ksocknal_find_peer_locked(struct lnet_ni *ni, lnet_process_id_t id)
 {
 	struct list_head *peer_list = ksocknal_nid2peerlist(id.nid);
 	struct list_head *tmp;
@@ -200,7 +200,7 @@ struct ksock_peer *
 }
 
 struct ksock_peer *
-ksocknal_find_peer(lnet_ni_t *ni, lnet_process_id_t id)
+ksocknal_find_peer(struct lnet_ni *ni, lnet_process_id_t id)
 {
 	struct ksock_peer *peer;
 
@@ -246,7 +246,7 @@ struct ksock_peer *
 }
 
 static int
-ksocknal_get_peer_info(lnet_ni_t *ni, int index,
+ksocknal_get_peer_info(struct lnet_ni *ni, int index,
 		       lnet_process_id_t *id, __u32 *myip, __u32 *peer_ip,
 		       int *port, int *conn_count, int *share_count)
 {
@@ -450,7 +450,8 @@ struct ksock_peer *
 }
 
 int
-ksocknal_add_peer(lnet_ni_t *ni, lnet_process_id_t id, __u32 ipaddr, int port)
+ksocknal_add_peer(struct lnet_ni *ni, lnet_process_id_t id, __u32 ipaddr,
+		  int port)
 {
 	struct list_head *tmp;
 	struct ksock_peer *peer;
@@ -568,7 +569,7 @@ struct ksock_peer *
 }
 
 static int
-ksocknal_del_peer(lnet_ni_t *ni, lnet_process_id_t id, __u32 ip)
+ksocknal_del_peer(struct lnet_ni *ni, lnet_process_id_t id, __u32 ip)
 {
 	LIST_HEAD(zombies);
 	struct list_head *ptmp;
@@ -627,7 +628,7 @@ struct ksock_peer *
 }
 
 static struct ksock_conn *
-ksocknal_get_conn_by_idx(lnet_ni_t *ni, int index)
+ksocknal_get_conn_by_idx(struct lnet_ni *ni, int index)
 {
 	struct ksock_peer *peer;
 	struct list_head *ptmp;
@@ -687,7 +688,7 @@ struct ksock_peer *
 }
 
 static int
-ksocknal_local_ipvec(lnet_ni_t *ni, __u32 *ipaddrs)
+ksocknal_local_ipvec(struct lnet_ni *ni, __u32 *ipaddrs)
 {
 	struct ksock_net *net = ni->ni_data;
 	int i;
@@ -866,7 +867,7 @@ struct ksock_peer *
 {
 	struct ksock_route *newroute = NULL;
 	rwlock_t *global_lock = &ksocknal_data.ksnd_global_lock;
-	lnet_ni_t *ni = peer->ksnp_ni;
+	struct lnet_ni *ni = peer->ksnp_ni;
 	struct ksock_net *net = ni->ni_data;
 	struct list_head *rtmp;
 	struct ksock_route *route;
@@ -982,7 +983,7 @@ struct ksock_peer *
 }
 
 int
-ksocknal_accept(lnet_ni_t *ni, struct socket *sock)
+ksocknal_accept(struct lnet_ni *ni, struct socket *sock)
 {
 	struct ksock_connreq *cr;
 	int rc;
@@ -1025,7 +1026,7 @@ struct ksock_peer *
 }
 
 int
-ksocknal_create_conn(lnet_ni_t *ni, struct ksock_route *route,
+ksocknal_create_conn(struct lnet_ni *ni, struct ksock_route *route,
 		     struct socket *sock, int type)
 {
 	rwlock_t *global_lock = &ksocknal_data.ksnd_global_lock;
@@ -1810,7 +1811,7 @@ struct ksock_peer *
 }
 
 void
-ksocknal_notify(lnet_ni_t *ni, lnet_nid_t gw_nid, int alive)
+ksocknal_notify(struct lnet_ni *ni, lnet_nid_t gw_nid, int alive)
 {
 	/*
 	 * The router is telling me she's been notified of a change in
@@ -1837,7 +1838,7 @@ struct ksock_peer *
 }
 
 void
-ksocknal_query(lnet_ni_t *ni, lnet_nid_t nid, unsigned long *when)
+ksocknal_query(struct lnet_ni *ni, lnet_nid_t nid, unsigned long *when)
 {
 	int connect = 1;
 	unsigned long last_alive = 0;
@@ -1932,7 +1933,7 @@ struct ksock_peer *
 	}
 }
 
-static int ksocknal_push(lnet_ni_t *ni, lnet_process_id_t id)
+static int ksocknal_push(struct lnet_ni *ni, lnet_process_id_t id)
 {
 	struct list_head *start;
 	struct list_head *end;
@@ -1982,7 +1983,7 @@ static int ksocknal_push(lnet_ni_t *ni, lnet_process_id_t id)
 }
 
 static int
-ksocknal_add_interface(lnet_ni_t *ni, __u32 ipaddress, __u32 netmask)
+ksocknal_add_interface(struct lnet_ni *ni, __u32 ipaddress, __u32 netmask)
 {
 	struct ksock_net *net = ni->ni_data;
 	struct ksock_interface *iface;
@@ -2086,7 +2087,7 @@ static int ksocknal_push(lnet_ni_t *ni, lnet_process_id_t id)
 }
 
 static int
-ksocknal_del_interface(lnet_ni_t *ni, __u32 ipaddress)
+ksocknal_del_interface(struct lnet_ni *ni, __u32 ipaddress)
 {
 	struct ksock_net *net = ni->ni_data;
 	int rc = -ENOENT;
@@ -2132,7 +2133,7 @@ static int ksocknal_push(lnet_ni_t *ni, lnet_process_id_t id)
 }
 
 int
-ksocknal_ctl(lnet_ni_t *ni, unsigned int cmd, void *arg)
+ksocknal_ctl(struct lnet_ni *ni, unsigned int cmd, void *arg)
 {
 	lnet_process_id_t id = {0};
 	struct libcfs_ioctl_data *data = arg;
@@ -2534,7 +2535,7 @@ static int ksocknal_push(lnet_ni_t *ni, lnet_process_id_t id)
 }
 
 static void
-ksocknal_debug_peerhash(lnet_ni_t *ni)
+ksocknal_debug_peerhash(struct lnet_ni *ni)
 {
 	struct ksock_peer *peer = NULL;
 	struct list_head *tmp;
@@ -2587,7 +2588,7 @@ static int ksocknal_push(lnet_ni_t *ni, lnet_process_id_t id)
 }
 
 void
-ksocknal_shutdown(lnet_ni_t *ni)
+ksocknal_shutdown(struct lnet_ni *ni)
 {
 	struct ksock_net *net = ni->ni_data;
 	int i;
@@ -2810,7 +2811,7 @@ static int ksocknal_push(lnet_ni_t *ni, lnet_process_id_t id)
 }
 
 int
-ksocknal_startup(lnet_ni_t *ni)
+ksocknal_startup(struct lnet_ni *ni)
 {
 	struct ksock_net *net;
 	int rc;
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h
index d03a029..99fec18 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h
@@ -447,7 +447,7 @@ struct ksock_peer {
 						 * ACK
 						 */
 	unsigned long      ksnp_send_keepalive; /* time to send keepalive */
-	lnet_ni_t          *ksnp_ni;            /* which network */
+	struct lnet_ni	   *ksnp_ni;		/* which network */
 	int                ksnp_n_passive_ips;  /* # of... */
 
 	/* preferred local interfaces */
@@ -456,7 +456,7 @@ struct ksock_peer {
 
 struct ksock_connreq {
 	struct list_head ksncr_list;  /* stash on ksnd_connd_connreqs */
-	lnet_ni_t        *ksncr_ni;   /* chosen NI */
+	struct lnet_ni	 *ksncr_ni;	/* chosen NI */
 	struct socket    *ksncr_sock; /* accepted socket */
 };
 
@@ -603,7 +603,7 @@ static inline __u32 ksocknal_csum(__u32 crc, unsigned char const *p, size_t len)
 }
 
 void ksocknal_tx_prep(struct ksock_conn *, struct ksock_tx *tx);
-void ksocknal_tx_done(lnet_ni_t *ni, struct ksock_tx *tx);
+void ksocknal_tx_done(struct lnet_ni *ni, struct ksock_tx *tx);
 
 static inline void
 ksocknal_tx_decref(struct ksock_tx *tx)
@@ -647,19 +647,22 @@ static inline __u32 ksocknal_csum(__u32 crc, unsigned char const *p, size_t len)
 		ksocknal_destroy_peer(peer);
 }
 
-int ksocknal_startup(lnet_ni_t *ni);
-void ksocknal_shutdown(lnet_ni_t *ni);
-int ksocknal_ctl(lnet_ni_t *ni, unsigned int cmd, void *arg);
-int ksocknal_send(lnet_ni_t *ni, void *private, struct lnet_msg *lntmsg);
-int ksocknal_recv(lnet_ni_t *ni, void *private, struct lnet_msg *lntmsg,
+int ksocknal_startup(struct lnet_ni *ni);
+void ksocknal_shutdown(struct lnet_ni *ni);
+int ksocknal_ctl(struct lnet_ni *ni, unsigned int cmd, void *arg);
+int ksocknal_send(struct lnet_ni *ni, void *private, struct lnet_msg *lntmsg);
+int ksocknal_recv(struct lnet_ni *ni, void *private, struct lnet_msg *lntmsg,
 		  int delayed, struct iov_iter *to, unsigned int rlen);
-int ksocknal_accept(lnet_ni_t *ni, struct socket *sock);
-
-int ksocknal_add_peer(lnet_ni_t *ni, lnet_process_id_t id, __u32 ip, int port);
-struct ksock_peer *ksocknal_find_peer_locked(lnet_ni_t *ni, lnet_process_id_t id);
-struct ksock_peer *ksocknal_find_peer(lnet_ni_t *ni, lnet_process_id_t id);
+int ksocknal_accept(struct lnet_ni *ni, struct socket *sock);
+
+int ksocknal_add_peer(struct lnet_ni *ni, lnet_process_id_t id, __u32 ip,
+		      int port);
+struct ksock_peer *ksocknal_find_peer_locked(struct lnet_ni *ni,
+					     lnet_process_id_t id);
+struct ksock_peer *ksocknal_find_peer(struct lnet_ni *ni,
+				      lnet_process_id_t id);
 void ksocknal_peer_failed(struct ksock_peer *peer);
-int ksocknal_create_conn(lnet_ni_t *ni, struct ksock_route *route,
+int ksocknal_create_conn(struct lnet_ni *ni, struct ksock_route *route,
 			 struct socket *sock, int type);
 void ksocknal_close_conn_locked(struct ksock_conn *conn, int why);
 void ksocknal_terminate_conn(struct ksock_conn *conn);
@@ -671,15 +674,15 @@ int  ksocknal_close_peer_conns_locked(struct ksock_peer *peer,
 struct ksock_conn *ksocknal_find_conn_locked(struct ksock_peer *peer,
 					     struct ksock_tx *tx, int nonblk);
 
-int  ksocknal_launch_packet(lnet_ni_t *ni, struct ksock_tx *tx,
+int  ksocknal_launch_packet(struct lnet_ni *ni, struct ksock_tx *tx,
 			    lnet_process_id_t id);
 struct ksock_tx *ksocknal_alloc_tx(int type, int size);
 void ksocknal_free_tx(struct ksock_tx *tx);
 struct ksock_tx *ksocknal_alloc_tx_noop(__u64 cookie, int nonblk);
 void ksocknal_next_tx_carrier(struct ksock_conn *conn);
 void ksocknal_queue_tx_locked(struct ksock_tx *tx, struct ksock_conn *conn);
-void ksocknal_txlist_done(lnet_ni_t *ni, struct list_head *txlist, int error);
-void ksocknal_notify(lnet_ni_t *ni, lnet_nid_t gw_nid, int alive);
+void ksocknal_txlist_done(struct lnet_ni *ni, struct list_head *txlist, int error);
+void ksocknal_notify(struct lnet_ni *ni, lnet_nid_t gw_nid, int alive);
 void ksocknal_query(struct lnet_ni *ni, lnet_nid_t nid, unsigned long *when);
 int ksocknal_thread_start(int (*fn)(void *arg), void *arg, char *name);
 void ksocknal_thread_fini(void);
@@ -690,9 +693,9 @@ int  ksocknal_launch_packet(lnet_ni_t *ni, struct ksock_tx *tx,
 int ksocknal_scheduler(void *arg);
 int ksocknal_connd(void *arg);
 int ksocknal_reaper(void *arg);
-int ksocknal_send_hello(lnet_ni_t *ni, struct ksock_conn *conn,
+int ksocknal_send_hello(struct lnet_ni *ni, struct ksock_conn *conn,
 			lnet_nid_t peer_nid, struct ksock_hello_msg *hello);
-int ksocknal_recv_hello(lnet_ni_t *ni, struct ksock_conn *conn,
+int ksocknal_recv_hello(struct lnet_ni *ni, struct ksock_conn *conn,
 			struct ksock_hello_msg *hello, lnet_process_id_t *id,
 			__u64 *incarnation);
 void ksocknal_read_callback(struct ksock_conn *conn);
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
index 66827f2..8cea4f6 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
@@ -393,7 +393,7 @@ struct ksock_tx *
 }
 
 void
-ksocknal_tx_done(lnet_ni_t *ni, struct ksock_tx *tx)
+ksocknal_tx_done(struct lnet_ni *ni, struct ksock_tx *tx)
 {
 	struct lnet_msg *lnetmsg = tx->tx_lnetmsg;
 	int rc = (!tx->tx_resid && !tx->tx_zc_aborted) ? 0 : -EIO;
@@ -412,7 +412,7 @@ struct ksock_tx *
 }
 
 void
-ksocknal_txlist_done(lnet_ni_t *ni, struct list_head *txlist, int error)
+ksocknal_txlist_done(struct lnet_ni *ni, struct list_head *txlist, int error)
 {
 	struct ksock_tx *tx;
 
@@ -845,7 +845,8 @@ struct ksock_route *
 }
 
 int
-ksocknal_launch_packet(lnet_ni_t *ni, struct ksock_tx *tx, lnet_process_id_t id)
+ksocknal_launch_packet(struct lnet_ni *ni, struct ksock_tx *tx,
+		       lnet_process_id_t id)
 {
 	struct ksock_peer *peer;
 	struct ksock_conn *conn;
@@ -938,7 +939,7 @@ struct ksock_route *
 }
 
 int
-ksocknal_send(lnet_ni_t *ni, void *private, struct lnet_msg *lntmsg)
+ksocknal_send(struct lnet_ni *ni, void *private, struct lnet_msg *lntmsg)
 {
 	int mpflag = 1;
 	int type = lntmsg->msg_type;
@@ -1333,7 +1334,7 @@ struct ksock_route *
 }
 
 int
-ksocknal_recv(lnet_ni_t *ni, void *private, struct lnet_msg *msg,
+ksocknal_recv(struct lnet_ni *ni, void *private, struct lnet_msg *msg,
 	      int delayed, struct iov_iter *to, unsigned int rlen)
 {
 	struct ksock_conn *conn = private;
@@ -1675,7 +1676,7 @@ void ksocknal_write_callback(struct ksock_conn *conn)
 }
 
 int
-ksocknal_send_hello(lnet_ni_t *ni, struct ksock_conn *conn,
+ksocknal_send_hello(struct lnet_ni *ni, struct ksock_conn *conn,
 		    lnet_nid_t peer_nid, struct ksock_hello_msg *hello)
 {
 	/* CAVEAT EMPTOR: this byte flips 'ipaddrs' */
@@ -1713,7 +1714,7 @@ void ksocknal_write_callback(struct ksock_conn *conn)
 }
 
 int
-ksocknal_recv_hello(lnet_ni_t *ni, struct ksock_conn *conn,
+ksocknal_recv_hello(struct lnet_ni *ni, struct ksock_conn *conn,
 		    struct ksock_hello_msg *hello, lnet_process_id_t *peerid,
 		    __u64 *incarnation)
 {
diff --git a/drivers/staging/lustre/lnet/lnet/acceptor.c b/drivers/staging/lustre/lnet/lnet/acceptor.c
index 69bbd59..a6f60c3 100644
--- a/drivers/staging/lustre/lnet/lnet/acceptor.c
+++ b/drivers/staging/lustre/lnet/lnet/acceptor.c
@@ -211,7 +211,7 @@
 	int peer_port;
 	int rc;
 	int flip;
-	lnet_ni_t *ni;
+	struct lnet_ni *ni;
 	char *str;
 
 	LASSERT(sizeof(cr) <= 16);	     /* not too big for the stack */
diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
index d31a50b..88279ed 100644
--- a/drivers/staging/lustre/lnet/lnet/api-ni.c
+++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
@@ -653,16 +653,16 @@ struct lnet_libhandle *
 	return 0;
 }
 
-lnet_ni_t  *
+struct lnet_ni  *
 lnet_net2ni_locked(__u32 net, int cpt)
 {
 	struct list_head *tmp;
-	lnet_ni_t *ni;
+	struct lnet_ni *ni;
 
 	LASSERT(cpt != LNET_LOCK_EX);
 
 	list_for_each(tmp, &the_lnet.ln_nis) {
-		ni = list_entry(tmp, lnet_ni_t, ni_list);
+		ni = list_entry(tmp, struct lnet_ni, ni_list);
 
 		if (LNET_NIDNET(ni->ni_nid) == net) {
 			lnet_ni_addref_locked(ni, cpt);
@@ -673,10 +673,10 @@ struct lnet_libhandle *
 	return NULL;
 }
 
-lnet_ni_t *
+struct lnet_ni *
 lnet_net2ni(__u32 net)
 {
-	lnet_ni_t *ni;
+	struct lnet_ni *ni;
 
 	lnet_net_lock(0);
 	ni = lnet_net2ni_locked(net, 0);
@@ -766,7 +766,7 @@ struct lnet_libhandle *
 	return !!ni;
 }
 
-lnet_ni_t  *
+struct lnet_ni  *
 lnet_nid2ni_locked(lnet_nid_t nid, int cpt)
 {
 	struct lnet_ni *ni;
@@ -775,7 +775,7 @@ struct lnet_libhandle *
 	LASSERT(cpt != LNET_LOCK_EX);
 
 	list_for_each(tmp, &the_lnet.ln_nis) {
-		ni = list_entry(tmp, lnet_ni_t, ni_list);
+		ni = list_entry(tmp, struct lnet_ni, ni_list);
 
 		if (ni->ni_nid == nid) {
 			lnet_ni_addref_locked(ni, cpt);
@@ -812,7 +812,7 @@ struct lnet_libhandle *
 
 	cpt = lnet_net_lock_current();
 	list_for_each(tmp, &the_lnet.ln_nis) {
-		ni = list_entry(tmp, lnet_ni_t, ni_list);
+		ni = list_entry(tmp, struct lnet_ni, ni_list);
 
 		if (ni->ni_lnd->lnd_accept)
 			count++;
@@ -985,7 +985,7 @@ struct lnet_libhandle *
 lnet_ping_info_install_locked(struct lnet_ping_info *ping_info)
 {
 	struct lnet_ni_status *ns;
-	lnet_ni_t *ni;
+	struct lnet_ni *ni;
 	int i = 0;
 
 	list_for_each_entry(ni, &the_lnet.ln_nis, ni_list) {
@@ -1050,7 +1050,7 @@ struct lnet_libhandle *
 }
 
 static int
-lnet_ni_tq_credits(lnet_ni_t *ni)
+lnet_ni_tq_credits(struct lnet_ni *ni)
 {
 	int credits;
 
@@ -1067,7 +1067,7 @@ struct lnet_libhandle *
 }
 
 static void
-lnet_ni_unlink_locked(lnet_ni_t *ni)
+lnet_ni_unlink_locked(struct lnet_ni *ni)
 {
 	if (!list_empty(&ni->ni_cptlist)) {
 		list_del_init(&ni->ni_cptlist);
@@ -1085,8 +1085,8 @@ struct lnet_libhandle *
 {
 	int i;
 	int islo;
-	lnet_ni_t *ni;
-	lnet_ni_t *temp;
+	struct lnet_ni *ni;
+	struct lnet_ni *temp;
 
 	/*
 	 * Now wait for the NI's I just nuked to show up on ln_zombie_nis
@@ -1145,8 +1145,8 @@ struct lnet_libhandle *
 static void
 lnet_shutdown_lndnis(void)
 {
-	lnet_ni_t *ni;
-	lnet_ni_t *temp;
+	struct lnet_ni *ni;
+	struct lnet_ni *temp;
 	int i;
 
 	/* NB called holding the global mutex */
@@ -1380,7 +1380,7 @@ struct lnet_libhandle *
 	int ni_count = 0;
 
 	while (!list_empty(nilist)) {
-		ni = list_entry(nilist->next, lnet_ni_t, ni_list);
+		ni = list_entry(nilist->next, struct lnet_ni, ni_list);
 		list_del(&ni->ni_list);
 		rc = lnet_startup_lndni(ni, NULL);
 
@@ -1742,7 +1742,7 @@ void lnet_lib_exit(void)
 		if (i++ != idx)
 			continue;
 
-		ni = list_entry(tmp, lnet_ni_t, ni_list);
+		ni = list_entry(tmp, struct lnet_ni, ni_list);
 		lnet_ni_lock(ni);
 		lnet_fill_ni_info(ni, config);
 		lnet_ni_unlock(ni);
@@ -1837,7 +1837,7 @@ void lnet_lib_exit(void)
 int
 lnet_dyn_del_ni(__u32 net)
 {
-	lnet_ni_t *ni;
+	struct lnet_ni *ni;
 	struct lnet_ping_info *pinfo;
 	struct lnet_handle_md md_handle;
 	int rc;
@@ -1888,7 +1888,7 @@ void lnet_lib_exit(void)
 	struct libcfs_ioctl_data *data = arg;
 	struct lnet_ioctl_config_data *config;
 	lnet_process_id_t id = {0};
-	lnet_ni_t *ni;
+	struct lnet_ni *ni;
 	int rc;
 	unsigned long secs_passed;
 
@@ -2115,7 +2115,7 @@ void LNetDebugPeer(lnet_process_id_t id)
 		if (index--)
 			continue;
 
-		ni = list_entry(tmp, lnet_ni_t, ni_list);
+		ni = list_entry(tmp, struct lnet_ni, ni_list);
 
 		id->nid = ni->ni_nid;
 		id->pid = the_lnet.ln_pid;
diff --git a/drivers/staging/lustre/lnet/lnet/config.c b/drivers/staging/lustre/lnet/lnet/config.c
index 9e2183f..933988d 100644
--- a/drivers/staging/lustre/lnet/lnet/config.c
+++ b/drivers/staging/lustre/lnet/lnet/config.c
@@ -79,10 +79,10 @@ struct lnet_text_buf {	    /* tmp struct for parsing routes */
 lnet_net_unique(__u32 net, struct list_head *nilist)
 {
 	struct list_head *tmp;
-	lnet_ni_t *ni;
+	struct lnet_ni *ni;
 
 	list_for_each(tmp, nilist) {
-		ni = list_entry(tmp, lnet_ni_t, ni_list);
+		ni = list_entry(tmp, struct lnet_ni, ni_list);
 
 		if (LNET_NIDNET(ni->ni_nid) == net)
 			return 0;
@@ -120,7 +120,7 @@ struct lnet_text_buf {	    /* tmp struct for parsing routes */
 	LIBCFS_FREE(ni, sizeof(*ni));
 }
 
-lnet_ni_t *
+struct lnet_ni *
 lnet_ni_alloc(__u32 net, struct cfs_expr_list *el, struct list_head *nilist)
 {
 	struct lnet_tx_queue *tq;
@@ -390,7 +390,7 @@ struct lnet_text_buf {	    /* tmp struct for parsing routes */
 	lnet_syntax("networks", networks, (int)(tmp - tokens), strlen(tmp));
  failed:
 	while (!list_empty(nilist)) {
-		ni = list_entry(nilist->next, lnet_ni_t, ni_list);
+		ni = list_entry(nilist->next, struct lnet_ni, ni_list);
 
 		list_del(&ni->ni_list);
 		lnet_ni_free(ni);
diff --git a/drivers/staging/lustre/lnet/lnet/lib-move.c b/drivers/staging/lustre/lnet/lnet/lib-move.c
index f919732..3aabb32 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-move.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-move.c
@@ -364,7 +364,7 @@
 EXPORT_SYMBOL(lnet_extract_kiov);
 
 void
-lnet_ni_recv(lnet_ni_t *ni, void *private, struct lnet_msg *msg,
+lnet_ni_recv(struct lnet_ni *ni, void *private, struct lnet_msg *msg,
 	     int delayed, unsigned int offset, unsigned int mlen,
 	     unsigned int rlen)
 {
@@ -450,7 +450,7 @@
 }
 
 static void
-lnet_ni_send(lnet_ni_t *ni, struct lnet_msg *msg)
+lnet_ni_send(struct lnet_ni *ni, struct lnet_msg *msg)
 {
 	void *priv = msg->msg_private;
 	int rc;
@@ -465,7 +465,7 @@
 }
 
 static int
-lnet_ni_eager_recv(lnet_ni_t *ni, struct lnet_msg *msg)
+lnet_ni_eager_recv(struct lnet_ni *ni, struct lnet_msg *msg)
 {
 	int rc;
 
@@ -489,7 +489,7 @@
 
 /* NB: caller shall hold a ref on 'lp' as I'd drop lnet_net_lock */
 static void
-lnet_ni_query_locked(lnet_ni_t *ni, lnet_peer_t *lp)
+lnet_ni_query_locked(struct lnet_ni *ni, lnet_peer_t *lp)
 {
 	unsigned long last_alive = 0;
 
@@ -599,7 +599,7 @@
 lnet_post_send_locked(struct lnet_msg *msg, int do_send)
 {
 	lnet_peer_t *lp = msg->msg_txpeer;
-	lnet_ni_t *ni = lp->lp_ni;
+	struct lnet_ni *ni = lp->lp_ni;
 	int cpt = msg->msg_tx_cpt;
 	struct lnet_tx_queue *tq = ni->ni_tx_queues[cpt];
 
@@ -995,7 +995,8 @@
 }
 
 static lnet_peer_t *
-lnet_find_route_locked(lnet_ni_t *ni, lnet_nid_t target, lnet_nid_t rtr_nid)
+lnet_find_route_locked(struct lnet_ni *ni, lnet_nid_t target,
+		       lnet_nid_t rtr_nid)
 {
 	lnet_remotenet_t *rnet;
 	lnet_route_t *route;
@@ -1233,7 +1234,7 @@
 }
 
 void
-lnet_drop_message(lnet_ni_t *ni, int cpt, void *private, unsigned int nob)
+lnet_drop_message(struct lnet_ni *ni, int cpt, void *private, unsigned int nob)
 {
 	lnet_net_lock(cpt);
 	the_lnet.ln_counters[cpt]->drop_count++;
@@ -1244,7 +1245,7 @@
 }
 
 static void
-lnet_recv_put(lnet_ni_t *ni, struct lnet_msg *msg)
+lnet_recv_put(struct lnet_ni *ni, struct lnet_msg *msg)
 {
 	struct lnet_hdr *hdr = &msg->msg_hdr;
 
@@ -1265,7 +1266,7 @@
 }
 
 static int
-lnet_parse_put(lnet_ni_t *ni, struct lnet_msg *msg)
+lnet_parse_put(struct lnet_ni *ni, struct lnet_msg *msg)
 {
 	struct lnet_hdr *hdr = &msg->msg_hdr;
 	struct lnet_match_info info;
@@ -1323,7 +1324,7 @@
 }
 
 static int
-lnet_parse_get(lnet_ni_t *ni, struct lnet_msg *msg, int rdma_get)
+lnet_parse_get(struct lnet_ni *ni, struct lnet_msg *msg, int rdma_get)
 {
 	struct lnet_match_info info;
 	struct lnet_hdr *hdr = &msg->msg_hdr;
@@ -1387,7 +1388,7 @@
 }
 
 static int
-lnet_parse_reply(lnet_ni_t *ni, struct lnet_msg *msg)
+lnet_parse_reply(struct lnet_ni *ni, struct lnet_msg *msg)
 {
 	void *private = msg->msg_private;
 	struct lnet_hdr *hdr = &msg->msg_hdr;
@@ -1452,7 +1453,7 @@
 }
 
 static int
-lnet_parse_ack(lnet_ni_t *ni, struct lnet_msg *msg)
+lnet_parse_ack(struct lnet_ni *ni, struct lnet_msg *msg)
 {
 	struct lnet_hdr *hdr = &msg->msg_hdr;
 	lnet_process_id_t src = {0};
@@ -1507,7 +1508,7 @@
  * \retval -ve			error code
  */
 int
-lnet_parse_forward_locked(lnet_ni_t *ni, struct lnet_msg *msg)
+lnet_parse_forward_locked(struct lnet_ni *ni, struct lnet_msg *msg)
 {
 	int rc = 0;
 
@@ -1531,7 +1532,7 @@
 }
 
 int
-lnet_parse_local(lnet_ni_t *ni, struct lnet_msg *msg)
+lnet_parse_local(struct lnet_ni *ni, struct lnet_msg *msg)
 {
 	int rc;
 
@@ -1635,7 +1636,7 @@
 }
 
 int
-lnet_parse(lnet_ni_t *ni, struct lnet_hdr *hdr, lnet_nid_t from_nid,
+lnet_parse(struct lnet_ni *ni, struct lnet_hdr *hdr, lnet_nid_t from_nid,
 	   void *private, int rdma_req)
 {
 	int rc = 0;
@@ -2074,7 +2075,7 @@
 EXPORT_SYMBOL(LNetPut);
 
 struct lnet_msg *
-lnet_create_reply_msg(lnet_ni_t *ni, struct lnet_msg *getmsg)
+lnet_create_reply_msg(struct lnet_ni *ni, struct lnet_msg *getmsg)
 {
 	/*
 	 * The LND can DMA direct to the GET md (i.e. no REPLY msg).  This
@@ -2152,7 +2153,8 @@ struct lnet_msg *
 EXPORT_SYMBOL(lnet_create_reply_msg);
 
 void
-lnet_set_reply_msg_len(lnet_ni_t *ni, struct lnet_msg *reply, unsigned int len)
+lnet_set_reply_msg_len(struct lnet_ni *ni, struct lnet_msg *reply,
+		       unsigned int len)
 {
 	/*
 	 * Set the REPLY length, now the RDMA that elides the REPLY message has
@@ -2307,7 +2309,7 @@ struct lnet_msg *
 	cpt = lnet_net_lock_current();
 
 	list_for_each(e, &the_lnet.ln_nis) {
-		ni = list_entry(e, lnet_ni_t, ni_list);
+		ni = list_entry(e, struct lnet_ni, ni_list);
 
 		if (ni->ni_nid == dstnid) {
 			if (srcnidp)
diff --git a/drivers/staging/lustre/lnet/lnet/lib-msg.c b/drivers/staging/lustre/lnet/lnet/lib-msg.c
index bcb5e24..128c335 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-msg.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-msg.c
@@ -437,7 +437,7 @@
 }
 
 void
-lnet_finalize(lnet_ni_t *ni, struct lnet_msg *msg, int status)
+lnet_finalize(struct lnet_ni *ni, struct lnet_msg *msg, int status)
 {
 	struct lnet_msg_container *container;
 	int my_slot;
diff --git a/drivers/staging/lustre/lnet/lnet/lo.c b/drivers/staging/lustre/lnet/lnet/lo.c
index d11b4f9..a7504b8 100644
--- a/drivers/staging/lustre/lnet/lnet/lo.c
+++ b/drivers/staging/lustre/lnet/lnet/lo.c
@@ -32,7 +32,7 @@
 #include "../../include/linux/lnet/lib-lnet.h"
 
 static int
-lolnd_send(lnet_ni_t *ni, void *private, struct lnet_msg *lntmsg)
+lolnd_send(struct lnet_ni *ni, void *private, struct lnet_msg *lntmsg)
 {
 	LASSERT(!lntmsg->msg_routing);
 	LASSERT(!lntmsg->msg_target_is_router);
@@ -41,7 +41,7 @@
 }
 
 static int
-lolnd_recv(lnet_ni_t *ni, void *private, struct lnet_msg *lntmsg,
+lolnd_recv(struct lnet_ni *ni, void *private, struct lnet_msg *lntmsg,
 	   int delayed, struct iov_iter *to, unsigned int rlen)
 {
 	struct lnet_msg *sendmsg = private;
@@ -70,7 +70,7 @@
 static int lolnd_instanced;
 
 static void
-lolnd_shutdown(lnet_ni_t *ni)
+lolnd_shutdown(struct lnet_ni *ni)
 {
 	CDEBUG(D_NET, "shutdown\n");
 	LASSERT(lolnd_instanced);
@@ -79,7 +79,7 @@
 }
 
 static int
-lolnd_startup(lnet_ni_t *ni)
+lolnd_startup(struct lnet_ni *ni)
 {
 	LASSERT(ni->ni_lnd == &the_lolnd);
 	LASSERT(!lolnd_instanced);
diff --git a/drivers/staging/lustre/lnet/lnet/peer.c b/drivers/staging/lustre/lnet/lnet/peer.c
index e806191..4b1a632 100644
--- a/drivers/staging/lustre/lnet/lnet/peer.c
+++ b/drivers/staging/lustre/lnet/lnet/peer.c
@@ -101,7 +101,8 @@
 }
 
 static void
-lnet_peer_table_cleanup_locked(lnet_ni_t *ni, struct lnet_peer_table *ptable)
+lnet_peer_table_cleanup_locked(struct lnet_ni *ni,
+			       struct lnet_peer_table *ptable)
 {
 	int i;
 	lnet_peer_t *lp;
@@ -141,7 +142,8 @@
 }
 
 static void
-lnet_peer_table_del_rtrs_locked(lnet_ni_t *ni, struct lnet_peer_table *ptable,
+lnet_peer_table_del_rtrs_locked(struct lnet_ni *ni,
+				struct lnet_peer_table *ptable,
 				int cpt_locked)
 {
 	lnet_peer_t *lp;
@@ -168,7 +170,7 @@
 }
 
 void
-lnet_peer_tables_cleanup(lnet_ni_t *ni)
+lnet_peer_tables_cleanup(struct lnet_ni *ni)
 {
 	struct lnet_peer_table *ptable;
 	struct list_head deathrow;
diff --git a/drivers/staging/lustre/lnet/lnet/router.c b/drivers/staging/lustre/lnet/lnet/router.c
index eb14ce2..85fdd08 100644
--- a/drivers/staging/lustre/lnet/lnet/router.c
+++ b/drivers/staging/lustre/lnet/lnet/router.c
@@ -53,7 +53,7 @@
 MODULE_PARM_DESC(auto_down, "Automatically mark peers down on comms error");
 
 int
-lnet_peer_buffer_credits(lnet_ni_t *ni)
+lnet_peer_buffer_credits(struct lnet_ni *ni)
 {
 	/* NI option overrides LNet default */
 	if (ni->ni_peerrtrcredits > 0)
@@ -128,7 +128,7 @@
 }
 
 static void
-lnet_ni_notify_locked(lnet_ni_t *ni, lnet_peer_t *lp)
+lnet_ni_notify_locked(struct lnet_ni *ni, lnet_peer_t *lp)
 {
 	int alive;
 	int notifylnd;
@@ -241,7 +241,7 @@ static void lnet_shuffle_seed(void)
 	static int seeded;
 	__u32 lnd_type, seed[2];
 	struct timespec64 ts;
-	lnet_ni_t *ni;
+	struct lnet_ni *ni;
 	struct list_head *tmp;
 
 	if (seeded)
@@ -254,7 +254,7 @@ static void lnet_shuffle_seed(void)
 	 * the NID for this node gives the most entropy in the low bits
 	 */
 	list_for_each(tmp, &the_lnet.ln_nis) {
-		ni = list_entry(tmp, lnet_ni_t, ni_list);
+		ni = list_entry(tmp, struct lnet_ni, ni_list);
 		lnd_type = LNET_NETTYP(LNET_NIDNET(ni->ni_nid));
 
 		if (lnd_type != LOLND)
@@ -302,7 +302,7 @@ static void lnet_shuffle_seed(void)
 	lnet_remotenet_t *rnet;
 	lnet_remotenet_t *rnet2;
 	lnet_route_t *route;
-	lnet_ni_t *ni;
+	struct lnet_ni *ni;
 	int add_route;
 	int rc;
 
@@ -838,7 +838,7 @@ int lnet_get_rtr_pool_cfg(int idx, struct lnet_ioctl_pool_cfg *pool_cfg)
 static void
 lnet_update_ni_status_locked(void)
 {
-	lnet_ni_t *ni;
+	struct lnet_ni *ni;
 	time64_t now;
 	int timeout;
 
@@ -1740,7 +1740,7 @@ int lnet_get_rtr_pool_cfg(int idx, struct lnet_ioctl_pool_cfg *pool_cfg)
 }
 
 int
-lnet_notify(lnet_ni_t *ni, lnet_nid_t nid, int alive, unsigned long when)
+lnet_notify(struct lnet_ni *ni, lnet_nid_t nid, int alive, unsigned long when)
 {
 	struct lnet_peer *lp = NULL;
 	unsigned long now = cfs_time_current();
diff --git a/drivers/staging/lustre/lnet/lnet/router_proc.c b/drivers/staging/lustre/lnet/lnet/router_proc.c
index a19e140..672d71d 100644
--- a/drivers/staging/lustre/lnet/lnet/router_proc.c
+++ b/drivers/staging/lustre/lnet/lnet/router_proc.c
@@ -652,7 +652,7 @@ static int proc_lnet_nis(struct ctl_table *table, int write,
 		LASSERT(tmpstr + tmpsiz - s > 0);
 	} else {
 		struct list_head *n;
-		lnet_ni_t *ni   = NULL;
+		struct lnet_ni *ni = NULL;
 		int skip = *ppos - 1;
 
 		lnet_net_lock(0);
@@ -660,8 +660,9 @@ static int proc_lnet_nis(struct ctl_table *table, int write,
 		n = the_lnet.ln_nis.next;
 
 		while (n != &the_lnet.ln_nis) {
-			lnet_ni_t *a_ni = list_entry(n, lnet_ni_t, ni_list);
+			struct lnet_ni *a_ni;
 
+			a_ni = list_entry(n, struct lnet_ni, ni_list);
 			if (!skip) {
 				ni = a_ni;
 				break;
-- 
1.8.3.1
