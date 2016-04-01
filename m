From: Joe Perches <joe@perches.com>
Date: Fri,  1 Apr 2016 06:02:11 -0700
Subject: [lustre-devel] [RFC PATCH 3/3] staging: lustre: Remove typedef
	lnet_msg_t
In-Reply-To: <cover.1459515208.git.joe@perches.com>
References: <cover.1459515208.git.joe@perches.com>
Message-ID: <4e5c312f7bd010cbca483583cdff090c387df465.1459515208.git.joe@perches.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org

Just use struct lnet_msg instead.

Signed-off-by: Joe Perches <joe@perches.com>
---
 .../staging/lustre/include/linux/lnet/lib-lnet.h   | 38 ++++++------
 .../staging/lustre/include/linux/lnet/lib-types.h  | 10 +--
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h    |  6 +-
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c |  8 +--
 .../staging/lustre/lnet/klnds/socklnd/socklnd.h    |  6 +-
 .../staging/lustre/lnet/klnds/socklnd/socklnd_cb.c |  6 +-
 drivers/staging/lustre/lnet/lnet/api-ni.c          |  2 +-
 drivers/staging/lustre/lnet/lnet/lib-move.c        | 72 +++++++++++-----------
 drivers/staging/lustre/lnet/lnet/lib-msg.c         | 24 ++++----
 drivers/staging/lustre/lnet/lnet/lib-ptl.c         |  4 +-
 drivers/staging/lustre/lnet/lnet/lo.c              |  6 +-
 11 files changed, 91 insertions(+), 91 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
index 2390d94..827afe6 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
@@ -248,10 +248,10 @@ lnet_me_free(lnet_me_t *me)
 	LIBCFS_FREE(me, sizeof(*me));
 }
 
-static inline lnet_msg_t *
+static inline struct lnet_msg *
 lnet_msg_alloc(void)
 {
-	lnet_msg_t *msg;
+	struct lnet_msg *msg;
 
 	LIBCFS_ALLOC(msg, sizeof(*msg));
 
@@ -260,7 +260,7 @@ lnet_msg_alloc(void)
 }
 
 static inline void
-lnet_msg_free(lnet_msg_t *msg)
+lnet_msg_free(struct lnet_msg *msg)
 {
 	LASSERT(!msg->msg_onactivelist);
 	LIBCFS_FREE(msg, sizeof(*msg));
@@ -487,20 +487,20 @@ int lnet_clear_lazy_portal(struct lnet_ni *ni, int portal, char *reason);
 int lnet_islocalnid(lnet_nid_t nid);
 int lnet_islocalnet(__u32 net);
 
-void lnet_msg_attach_md(lnet_msg_t *msg, lnet_libmd_t *md,
+void lnet_msg_attach_md(struct lnet_msg *msg, lnet_libmd_t *md,
 			unsigned int offset, unsigned int mlen);
-void lnet_msg_detach_md(lnet_msg_t *msg, int status);
+void lnet_msg_detach_md(struct lnet_msg *msg, int status);
 void lnet_build_unlink_event(lnet_libmd_t *md, lnet_event_t *ev);
-void lnet_build_msg_event(lnet_msg_t *msg, lnet_event_kind_t ev_type);
-void lnet_msg_commit(lnet_msg_t *msg, int cpt);
-void lnet_msg_decommit(lnet_msg_t *msg, int cpt, int status);
+void lnet_build_msg_event(struct lnet_msg *msg, lnet_event_kind_t ev_type);
+void lnet_msg_commit(struct lnet_msg *msg, int cpt);
+void lnet_msg_decommit(struct lnet_msg *msg, int cpt, int status);
 
 void lnet_eq_enqueue_event(lnet_eq_t *eq, lnet_event_t *ev);
-void lnet_prep_send(lnet_msg_t *msg, int type, lnet_process_id_t target,
+void lnet_prep_send(struct lnet_msg *msg, int type, lnet_process_id_t target,
 		    unsigned int offset, unsigned int len);
-int lnet_send(lnet_nid_t nid, lnet_msg_t *msg, lnet_nid_t rtr_nid);
-void lnet_return_tx_credits_locked(lnet_msg_t *msg);
-void lnet_return_rx_credits_locked(lnet_msg_t *msg);
+int lnet_send(lnet_nid_t nid, struct lnet_msg *msg, lnet_nid_t rtr_nid);
+void lnet_return_tx_credits_locked(struct lnet_msg *msg);
+void lnet_return_rx_credits_locked(struct lnet_msg *msg);
 void lnet_schedule_blocked_locked(lnet_rtrbufpool_t *rbp);
 void lnet_drop_routed_msgs_locked(struct list_head *list, int cpt);
 
@@ -559,19 +559,19 @@ void lnet_portals_destroy(void);
 /* message functions */
 int lnet_parse(lnet_ni_t *ni, lnet_hdr_t *hdr,
 	       lnet_nid_t fromnid, void *private, int rdma_req);
-int lnet_parse_local(lnet_ni_t *ni, lnet_msg_t *msg);
-int lnet_parse_forward_locked(lnet_ni_t *ni, lnet_msg_t *msg);
+int lnet_parse_local(lnet_ni_t *ni, struct lnet_msg *msg);
+int lnet_parse_forward_locked(lnet_ni_t *ni, struct lnet_msg *msg);
 
-void lnet_recv(lnet_ni_t *ni, void *private, lnet_msg_t *msg, int delayed,
+void lnet_recv(lnet_ni_t *ni, void *private, struct lnet_msg *msg, int delayed,
 	       unsigned int offset, unsigned int mlen, unsigned int rlen);
-void lnet_ni_recv(lnet_ni_t *ni, void *private, lnet_msg_t *msg,
+void lnet_ni_recv(lnet_ni_t *ni, void *private, struct lnet_msg *msg,
 		  int delayed, unsigned int offset,
 		  unsigned int mlen, unsigned int rlen);
 
-lnet_msg_t *lnet_create_reply_msg(lnet_ni_t *ni, lnet_msg_t *get_msg);
-void lnet_set_reply_msg_len(lnet_ni_t *ni, lnet_msg_t *msg, unsigned int len);
+struct lnet_msg *lnet_create_reply_msg(lnet_ni_t *ni, struct lnet_msg *get_msg);
+void lnet_set_reply_msg_len(lnet_ni_t *ni, struct lnet_msg *msg, unsigned int len);
 
-void lnet_finalize(lnet_ni_t *ni, lnet_msg_t *msg, int rc);
+void lnet_finalize(lnet_ni_t *ni, struct lnet_msg *msg, int rc);
 
 void lnet_drop_message(lnet_ni_t *ni, int cpt, void *private,
 		       unsigned int nob);
diff --git a/drivers/staging/lustre/include/linux/lnet/lib-types.h b/drivers/staging/lustre/include/linux/lnet/lib-types.h
index 62baaca..33729f2 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-types.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-types.h
@@ -53,7 +53,7 @@
 /* forward refs */
 struct lnet_libmd;
 
-typedef struct lnet_msg {
+struct lnet_msg {
 	struct list_head	msg_activelist;
 	struct list_head	msg_list;	   /* Q for credits/MD */
 
@@ -105,7 +105,7 @@ typedef struct lnet_msg {
 
 	lnet_event_t		 msg_ev;
 	lnet_hdr_t		 msg_hdr;
-} lnet_msg_t;
+};
 
 typedef struct lnet_libhandle {
 	struct list_head	lh_hash_chain;
@@ -209,7 +209,7 @@ struct lnet_lnd {
 	 * non-zero for immediate failure, otherwise complete later with
 	 * lnet_finalize()
 	 */
-	int (*lnd_send)(struct lnet_ni *ni, void *private, lnet_msg_t *msg);
+	int (*lnd_send)(struct lnet_ni *ni, void *private, struct lnet_msg *msg);
 
 	/*
 	 * Start receiving 'mlen' bytes of payload data, skipping the following
@@ -218,7 +218,7 @@ struct lnet_lnd {
 	 * complete later with lnet_finalize().  This also gives back a receive
 	 * credit if the LND does flow control.
 	 */
-	int (*lnd_recv)(struct lnet_ni *ni, void *private, lnet_msg_t *msg,
+	int (*lnd_recv)(struct lnet_ni *ni, void *private, struct lnet_msg *msg,
 			int delayed, unsigned int niov,
 			struct kvec *iov, lnet_kiov_t *kiov,
 			unsigned int offset, unsigned int mlen,
@@ -233,7 +233,7 @@ struct lnet_lnd {
 	 * release resources; lnd_recv() will not be called.
 	 */
 	int (*lnd_eager_recv)(struct lnet_ni *ni, void *private,
-			      lnet_msg_t *msg, void **new_privatep);
+			      struct lnet_msg *msg, void **new_privatep);
 
 	/* notification of peer health */
 	void (*lnd_notify)(struct lnet_ni *ni, lnet_nid_t peer, int alive);
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
index bfcbdd1..988b727 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
@@ -509,7 +509,7 @@ typedef struct kib_tx                         /* transmit message */
 	int                   tx_status;      /* LNET completion status */
 	unsigned long         tx_deadline;    /* completion deadline */
 	__u64                 tx_cookie;      /* completion cookie */
-	lnet_msg_t *tx_lntmsg[2]; /* lnet msgs to finalize on completion */
+	struct lnet_msg *tx_lntmsg[2]; /* lnet msgs to finalize on completion */
 	kib_msg_t             *tx_msg;        /* message buffer (host vaddr) */
 	__u64                 tx_msgaddr;     /* message buffer (I/O addr) */
 	DECLARE_PCI_UNMAP_ADDR(tx_msgunmap);  /* for dma_unmap_single() */
@@ -1003,7 +1003,7 @@ void kiblnd_pack_msg(lnet_ni_t *ni, kib_msg_t *msg, int version,
 int  kiblnd_unpack_msg(kib_msg_t *msg, int nob);
 int  kiblnd_post_rx(kib_rx_t *rx, int credit);
 
-int  kiblnd_send(lnet_ni_t *ni, void *private, lnet_msg_t *lntmsg);
-int  kiblnd_recv(lnet_ni_t *ni, void *private, lnet_msg_t *lntmsg, int delayed,
+int  kiblnd_send(lnet_ni_t *ni, void *private, struct lnet_msg *lntmsg);
+int  kiblnd_recv(lnet_ni_t *ni, void *private, struct lnet_msg *lntmsg, int delayed,
 		 unsigned int niov, struct kvec *iov, lnet_kiov_t *kiov,
 		 unsigned int offset, unsigned int mlen, unsigned int rlen);
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
index cd3fde7..6f00bba 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -54,7 +54,7 @@ static void kiblnd_unmap_tx(lnet_ni_t *ni, kib_tx_t *tx);
 static void
 kiblnd_tx_done(lnet_ni_t *ni, kib_tx_t *tx)
 {
-	lnet_msg_t *lntmsg[2];
+	struct lnet_msg *lntmsg[2];
 	kib_net_t *net = ni->ni_data;
 	int rc;
 	int i;
@@ -1486,7 +1486,7 @@ kiblnd_launch_tx(lnet_ni_t *ni, kib_tx_t *tx, lnet_nid_t nid)
 }
 
 int
-kiblnd_send(lnet_ni_t *ni, void *private, lnet_msg_t *lntmsg)
+kiblnd_send(lnet_ni_t *ni, void *private, struct lnet_msg *lntmsg)
 {
 	lnet_hdr_t *hdr = &lntmsg->msg_hdr;
 	int type = lntmsg->msg_type;
@@ -1656,7 +1656,7 @@ kiblnd_send(lnet_ni_t *ni, void *private, lnet_msg_t *lntmsg)
 }
 
 static void
-kiblnd_reply(lnet_ni_t *ni, kib_rx_t *rx, lnet_msg_t *lntmsg)
+kiblnd_reply(lnet_ni_t *ni, kib_rx_t *rx, struct lnet_msg *lntmsg)
 {
 	lnet_process_id_t target = lntmsg->msg_target;
 	unsigned int niov = lntmsg->msg_niov;
@@ -1717,7 +1717,7 @@ kiblnd_reply(lnet_ni_t *ni, kib_rx_t *rx, lnet_msg_t *lntmsg)
 }
 
 int
-kiblnd_recv(lnet_ni_t *ni, void *private, lnet_msg_t *lntmsg, int delayed,
+kiblnd_recv(lnet_ni_t *ni, void *private, struct lnet_msg *lntmsg, int delayed,
 	    unsigned int niov, struct kvec *iov, lnet_kiov_t *kiov,
 	    unsigned int offset, unsigned int mlen, unsigned int rlen)
 {
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h
index a60d72f..13dc69e 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h
@@ -267,7 +267,7 @@ typedef struct                             /* transmit packet */
 	unsigned short    tx_nonblk:1;     /* it's a non-blocking ACK */
 	lnet_kiov_t       *tx_kiov;        /* packet page frags */
 	struct ksock_conn *tx_conn;        /* owning conn */
-	lnet_msg_t        *tx_lnetmsg;     /* lnet message for lnet_finalize()
+	struct lnet_msg   *tx_lnetmsg;     /* lnet message for lnet_finalize()
 					    */
 	unsigned long     tx_deadline;     /* when (in jiffies) tx times out */
 	ksock_msg_t       tx_msg;          /* socklnd message buffer */
@@ -617,8 +617,8 @@ ksocknal_peer_decref(ksock_peer_t *peer)
 int ksocknal_startup(lnet_ni_t *ni);
 void ksocknal_shutdown(lnet_ni_t *ni);
 int ksocknal_ctl(lnet_ni_t *ni, unsigned int cmd, void *arg);
-int ksocknal_send(lnet_ni_t *ni, void *private, lnet_msg_t *lntmsg);
-int ksocknal_recv(lnet_ni_t *ni, void *private, lnet_msg_t *lntmsg,
+int ksocknal_send(lnet_ni_t *ni, void *private, struct lnet_msg *lntmsg);
+int ksocknal_recv(lnet_ni_t *ni, void *private, struct lnet_msg *lntmsg,
 		  int delayed, unsigned int niov,
 		  struct kvec *iov, lnet_kiov_t *kiov,
 		  unsigned int offset, unsigned int mlen, unsigned int rlen);
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
index 976fd78..228146c 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
@@ -393,7 +393,7 @@ ksocknal_receive(ksock_conn_t *conn)
 void
 ksocknal_tx_done(lnet_ni_t *ni, ksock_tx_t *tx)
 {
-	lnet_msg_t *lnetmsg = tx->tx_lnetmsg;
+	struct lnet_msg *lnetmsg = tx->tx_lnetmsg;
 	int rc = (!tx->tx_resid && !tx->tx_zc_aborted) ? 0 : -EIO;
 
 	LASSERT(ni || tx->tx_conn);
@@ -932,7 +932,7 @@ ksocknal_launch_packet(lnet_ni_t *ni, ksock_tx_t *tx, lnet_process_id_t id)
 }
 
 int
-ksocknal_send(lnet_ni_t *ni, void *private, lnet_msg_t *lntmsg)
+ksocknal_send(lnet_ni_t *ni, void *private, struct lnet_msg *lntmsg)
 {
 	int mpflag = 1;
 	int type = lntmsg->msg_type;
@@ -1324,7 +1324,7 @@ ksocknal_process_receive(ksock_conn_t *conn)
 }
 
 int
-ksocknal_recv(lnet_ni_t *ni, void *private, lnet_msg_t *msg, int delayed,
+ksocknal_recv(lnet_ni_t *ni, void *private, struct lnet_msg *msg, int delayed,
 	      unsigned int niov, struct kvec *iov, lnet_kiov_t *kiov,
 	      unsigned int offset, unsigned int mlen, unsigned int rlen)
 {
diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
index 19ad5a3..a5104b1 100644
--- a/drivers/staging/lustre/lnet/lnet/api-ni.c
+++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
@@ -1174,7 +1174,7 @@ lnet_shutdown_lndnis(void)
 
 	/*
 	 * Clear lazy portals and drop delayed messages which hold refs
-	 * on their lnet_msg_t::msg_rxpeer
+	 * on their struct lnet_msg::msg_rxpeer
 	 */
 	for (i = 0; i < the_lnet.ln_nportals; i++)
 		LNetClearLazyPortal(i);
diff --git a/drivers/staging/lustre/lnet/lnet/lib-move.c b/drivers/staging/lustre/lnet/lnet/lib-move.c
index 4ebf1b4..d9389a9 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-move.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-move.c
@@ -567,7 +567,7 @@ lnet_extract_kiov(int dst_niov, lnet_kiov_t *dst,
 EXPORT_SYMBOL(lnet_extract_kiov);
 
 void
-lnet_ni_recv(lnet_ni_t *ni, void *private, lnet_msg_t *msg, int delayed,
+lnet_ni_recv(lnet_ni_t *ni, void *private, struct lnet_msg *msg, int delayed,
 	     unsigned int offset, unsigned int mlen, unsigned int rlen)
 {
 	unsigned int niov = 0;
@@ -605,7 +605,7 @@ lnet_ni_recv(lnet_ni_t *ni, void *private, lnet_msg_t *msg, int delayed,
 }
 
 static void
-lnet_setpayloadbuffer(lnet_msg_t *msg)
+lnet_setpayloadbuffer(struct lnet_msg *msg)
 {
 	lnet_libmd_t *md = msg->msg_md;
 
@@ -624,7 +624,7 @@ lnet_setpayloadbuffer(lnet_msg_t *msg)
 }
 
 void
-lnet_prep_send(lnet_msg_t *msg, int type, lnet_process_id_t target,
+lnet_prep_send(struct lnet_msg *msg, int type, lnet_process_id_t target,
 	       unsigned int offset, unsigned int len)
 {
 	msg->msg_type = type;
@@ -645,7 +645,7 @@ lnet_prep_send(lnet_msg_t *msg, int type, lnet_process_id_t target,
 }
 
 static void
-lnet_ni_send(lnet_ni_t *ni, lnet_msg_t *msg)
+lnet_ni_send(lnet_ni_t *ni, struct lnet_msg *msg)
 {
 	void *priv = msg->msg_private;
 	int rc;
@@ -660,7 +660,7 @@ lnet_ni_send(lnet_ni_t *ni, lnet_msg_t *msg)
 }
 
 static int
-lnet_ni_eager_recv(lnet_ni_t *ni, lnet_msg_t *msg)
+lnet_ni_eager_recv(lnet_ni_t *ni, struct lnet_msg *msg)
 {
 	int rc;
 
@@ -791,7 +791,7 @@ lnet_peer_alive_locked(struct lnet_peer *lp)
  * \retval -ECANCELED If the MD of the message has been unlinked.
  */
 static int
-lnet_post_send_locked(lnet_msg_t *msg, int do_send)
+lnet_post_send_locked(struct lnet_msg *msg, int do_send)
 {
 	struct lnet_peer *lp = msg->msg_txpeer;
 	lnet_ni_t *ni = lp->lp_ni;
@@ -876,7 +876,7 @@ lnet_post_send_locked(lnet_msg_t *msg, int do_send)
 }
 
 static lnet_rtrbufpool_t *
-lnet_msg2bufpool(lnet_msg_t *msg)
+lnet_msg2bufpool(struct lnet_msg *msg)
 {
 	lnet_rtrbufpool_t *rbp;
 	int cpt;
@@ -896,7 +896,7 @@ lnet_msg2bufpool(lnet_msg_t *msg)
 }
 
 static int
-lnet_post_routed_recv_locked(lnet_msg_t *msg, int do_recv)
+lnet_post_routed_recv_locked(struct lnet_msg *msg, int do_recv)
 {
 	/*
 	 * lnet_parse is going to lnet_net_unlock immediately after this, so it
@@ -972,10 +972,10 @@ lnet_post_routed_recv_locked(lnet_msg_t *msg, int do_recv)
 }
 
 void
-lnet_return_tx_credits_locked(lnet_msg_t *msg)
+lnet_return_tx_credits_locked(struct lnet_msg *msg)
 {
 	struct lnet_peer *txpeer = msg->msg_txpeer;
-	lnet_msg_t *msg2;
+	struct lnet_msg *msg2;
 
 	if (msg->msg_txcredit) {
 		struct lnet_ni *ni = txpeer->lp_ni;
@@ -990,7 +990,7 @@ lnet_return_tx_credits_locked(lnet_msg_t *msg)
 		tq->tq_credits++;
 		if (tq->tq_credits <= 0) {
 			msg2 = list_entry(tq->tq_delayed.next,
-					  lnet_msg_t, msg_list);
+					  struct lnet_msg, msg_list);
 			list_del(&msg2->msg_list);
 
 			LASSERT(msg2->msg_txpeer->lp_ni == ni);
@@ -1013,7 +1013,7 @@ lnet_return_tx_credits_locked(lnet_msg_t *msg)
 		txpeer->lp_txcredits++;
 		if (txpeer->lp_txcredits <= 0) {
 			msg2 = list_entry(txpeer->lp_txq.next,
-					  lnet_msg_t, msg_list);
+					  struct lnet_msg, msg_list);
 			list_del(&msg2->msg_list);
 
 			LASSERT(msg2->msg_txpeer == txpeer);
@@ -1032,12 +1032,12 @@ lnet_return_tx_credits_locked(lnet_msg_t *msg)
 void
 lnet_schedule_blocked_locked(lnet_rtrbufpool_t *rbp)
 {
-	lnet_msg_t *msg;
+	struct lnet_msg *msg;
 
 	if (list_empty(&rbp->rbp_msgs))
 		return;
 	msg = list_entry(rbp->rbp_msgs.next,
-			 lnet_msg_t, msg_list);
+			 struct lnet_msg, msg_list);
 	list_del(&msg->msg_list);
 
 	(void)lnet_post_routed_recv_locked(msg, 1);
@@ -1047,8 +1047,8 @@ void
 lnet_drop_routed_msgs_locked(struct list_head *list, int cpt)
 {
 	struct list_head drop;
-	lnet_msg_t *msg;
-	lnet_msg_t *tmp;
+	struct lnet_msg *msg;
+	struct lnet_msg *tmp;
 
 	INIT_LIST_HEAD(&drop);
 
@@ -1067,10 +1067,10 @@ lnet_drop_routed_msgs_locked(struct list_head *list, int cpt)
 }
 
 void
-lnet_return_rx_credits_locked(lnet_msg_t *msg)
+lnet_return_rx_credits_locked(struct lnet_msg *msg)
 {
 	struct lnet_peer *rxpeer = msg->msg_rxpeer;
-	lnet_msg_t *msg2;
+	struct lnet_msg *msg2;
 
 	if (msg->msg_rtrcredit) {
 		/* give back global router credits */
@@ -1139,7 +1139,7 @@ routing_off:
 						     msg->msg_rx_cpt);
 		} else if (rxpeer->lp_rtrcredits <= 0) {
 			msg2 = list_entry(rxpeer->lp_rtrq.next,
-					  lnet_msg_t, msg_list);
+					  struct lnet_msg, msg_list);
 			list_del(&msg2->msg_list);
 
 			(void)lnet_post_routed_recv_locked(msg2, 1);
@@ -1253,7 +1253,7 @@ lnet_find_route_locked(lnet_ni_t *ni, lnet_nid_t target, lnet_nid_t rtr_nid)
 }
 
 int
-lnet_send(lnet_nid_t src_nid, lnet_msg_t *msg, lnet_nid_t rtr_nid)
+lnet_send(lnet_nid_t src_nid, struct lnet_msg *msg, lnet_nid_t rtr_nid)
 {
 	lnet_nid_t dst_nid = msg->msg_target.nid;
 	struct lnet_ni *src_ni;
@@ -1439,7 +1439,7 @@ lnet_drop_message(lnet_ni_t *ni, int cpt, void *private, unsigned int nob)
 }
 
 static void
-lnet_recv_put(lnet_ni_t *ni, lnet_msg_t *msg)
+lnet_recv_put(lnet_ni_t *ni, struct lnet_msg *msg)
 {
 	lnet_hdr_t *hdr = &msg->msg_hdr;
 
@@ -1460,7 +1460,7 @@ lnet_recv_put(lnet_ni_t *ni, lnet_msg_t *msg)
 }
 
 static int
-lnet_parse_put(lnet_ni_t *ni, lnet_msg_t *msg)
+lnet_parse_put(lnet_ni_t *ni, struct lnet_msg *msg)
 {
 	lnet_hdr_t *hdr = &msg->msg_hdr;
 	struct lnet_match_info info;
@@ -1518,7 +1518,7 @@ lnet_parse_put(lnet_ni_t *ni, lnet_msg_t *msg)
 }
 
 static int
-lnet_parse_get(lnet_ni_t *ni, lnet_msg_t *msg, int rdma_get)
+lnet_parse_get(lnet_ni_t *ni, struct lnet_msg *msg, int rdma_get)
 {
 	struct lnet_match_info info;
 	lnet_hdr_t *hdr = &msg->msg_hdr;
@@ -1582,7 +1582,7 @@ lnet_parse_get(lnet_ni_t *ni, lnet_msg_t *msg, int rdma_get)
 }
 
 static int
-lnet_parse_reply(lnet_ni_t *ni, lnet_msg_t *msg)
+lnet_parse_reply(lnet_ni_t *ni, struct lnet_msg *msg)
 {
 	void *private = msg->msg_private;
 	lnet_hdr_t *hdr = &msg->msg_hdr;
@@ -1647,7 +1647,7 @@ lnet_parse_reply(lnet_ni_t *ni, lnet_msg_t *msg)
 }
 
 static int
-lnet_parse_ack(lnet_ni_t *ni, lnet_msg_t *msg)
+lnet_parse_ack(lnet_ni_t *ni, struct lnet_msg *msg)
 {
 	lnet_hdr_t *hdr = &msg->msg_hdr;
 	lnet_process_id_t src = {0};
@@ -1702,7 +1702,7 @@ lnet_parse_ack(lnet_ni_t *ni, lnet_msg_t *msg)
  * \retval -ve			error code
  */
 int
-lnet_parse_forward_locked(lnet_ni_t *ni, lnet_msg_t *msg)
+lnet_parse_forward_locked(lnet_ni_t *ni, struct lnet_msg *msg)
 {
 	int rc = 0;
 
@@ -1726,7 +1726,7 @@ lnet_parse_forward_locked(lnet_ni_t *ni, lnet_msg_t *msg)
 }
 
 int
-lnet_parse_local(lnet_ni_t *ni, lnet_msg_t *msg)
+lnet_parse_local(lnet_ni_t *ni, struct lnet_msg *msg)
 {
 	int rc;
 
@@ -2067,9 +2067,9 @@ lnet_drop_delayed_msg_list(struct list_head *head, char *reason)
 {
 	while (!list_empty(head)) {
 		lnet_process_id_t id = {0};
-		lnet_msg_t *msg;
+		struct lnet_msg *msg;
 
-		msg = list_entry(head->next, lnet_msg_t, msg_list);
+		msg = list_entry(head->next, struct lnet_msg, msg_list);
 		list_del(&msg->msg_list);
 
 		id.nid = msg->msg_hdr.src_nid;
@@ -2108,10 +2108,10 @@ void
 lnet_recv_delayed_msg_list(struct list_head *head)
 {
 	while (!list_empty(head)) {
-		lnet_msg_t *msg;
+		struct lnet_msg *msg;
 		lnet_process_id_t id;
 
-		msg = list_entry(head->next, lnet_msg_t, msg_list);
+		msg = list_entry(head->next, struct lnet_msg, msg_list);
 		list_del(&msg->msg_list);
 
 		/*
@@ -2202,7 +2202,7 @@ LNetPut(lnet_nid_t self, lnet_handle_md_t mdh, lnet_ack_req_t ack,
 
 	msg = lnet_msg_alloc();
 	if (!msg) {
-		CERROR("Dropping PUT to %s: ENOMEM on lnet_msg_t\n",
+		CERROR("Dropping PUT to %s: ENOMEM on struct lnet_msg\n",
 		       libcfs_id2str(target));
 		return -ENOMEM;
 	}
@@ -2265,8 +2265,8 @@ LNetPut(lnet_nid_t self, lnet_handle_md_t mdh, lnet_ack_req_t ack,
 }
 EXPORT_SYMBOL(LNetPut);
 
-lnet_msg_t *
-lnet_create_reply_msg(lnet_ni_t *ni, lnet_msg_t *getmsg)
+struct lnet_msg *
+lnet_create_reply_msg(lnet_ni_t *ni, struct lnet_msg *getmsg)
 {
 	/*
 	 * The LND can DMA direct to the GET md (i.e. no REPLY msg).  This
@@ -2344,7 +2344,7 @@ lnet_create_reply_msg(lnet_ni_t *ni, lnet_msg_t *getmsg)
 EXPORT_SYMBOL(lnet_create_reply_msg);
 
 void
-lnet_set_reply_msg_len(lnet_ni_t *ni, lnet_msg_t *reply, unsigned int len)
+lnet_set_reply_msg_len(lnet_ni_t *ni, struct lnet_msg *reply, unsigned int len)
 {
 	/*
 	 * Set the REPLY length, now the RDMA that elides the REPLY message has
@@ -2406,7 +2406,7 @@ LNetGet(lnet_nid_t self, lnet_handle_md_t mdh,
 
 	msg = lnet_msg_alloc();
 	if (!msg) {
-		CERROR("Dropping GET to %s: ENOMEM on lnet_msg_t\n",
+		CERROR("Dropping GET to %s: ENOMEM on struct lnet_msg\n",
 		       libcfs_id2str(target));
 		return -ENOMEM;
 	}
diff --git a/drivers/staging/lustre/lnet/lnet/lib-msg.c b/drivers/staging/lustre/lnet/lnet/lib-msg.c
index f879d7f..fd31267 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-msg.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-msg.c
@@ -58,7 +58,7 @@ lnet_build_unlink_event(lnet_libmd_t *md, lnet_event_t *ev)
  * Don't need any lock, must be called after lnet_commit_md
  */
 void
-lnet_build_msg_event(lnet_msg_t *msg, lnet_event_kind_t ev_type)
+lnet_build_msg_event(struct lnet_msg *msg, lnet_event_kind_t ev_type)
 {
 	lnet_hdr_t *hdr = &msg->msg_hdr;
 	lnet_event_t *ev  = &msg->msg_ev;
@@ -133,7 +133,7 @@ lnet_build_msg_event(lnet_msg_t *msg, lnet_event_kind_t ev_type)
 }
 
 void
-lnet_msg_commit(lnet_msg_t *msg, int cpt)
+lnet_msg_commit(struct lnet_msg *msg, int cpt)
 {
 	struct lnet_msg_container *container = the_lnet.ln_msg_containers[cpt];
 	lnet_counters_t *counters  = the_lnet.ln_counters[cpt];
@@ -166,7 +166,7 @@ lnet_msg_commit(lnet_msg_t *msg, int cpt)
 }
 
 static void
-lnet_msg_decommit_tx(lnet_msg_t *msg, int status)
+lnet_msg_decommit_tx(struct lnet_msg *msg, int status)
 {
 	lnet_counters_t	*counters;
 	lnet_event_t *ev = &msg->msg_ev;
@@ -218,7 +218,7 @@ lnet_msg_decommit_tx(lnet_msg_t *msg, int status)
 }
 
 static void
-lnet_msg_decommit_rx(lnet_msg_t *msg, int status)
+lnet_msg_decommit_rx(struct lnet_msg *msg, int status)
 {
 	lnet_counters_t *counters;
 	lnet_event_t *ev = &msg->msg_ev;
@@ -276,7 +276,7 @@ lnet_msg_decommit_rx(lnet_msg_t *msg, int status)
 }
 
 void
-lnet_msg_decommit(lnet_msg_t *msg, int cpt, int status)
+lnet_msg_decommit(struct lnet_msg *msg, int cpt, int status)
 {
 	int cpt2 = cpt;
 
@@ -310,7 +310,7 @@ lnet_msg_decommit(lnet_msg_t *msg, int cpt, int status)
 }
 
 void
-lnet_msg_attach_md(lnet_msg_t *msg, lnet_libmd_t *md,
+lnet_msg_attach_md(struct lnet_msg *msg, lnet_libmd_t *md,
 		   unsigned int offset, unsigned int mlen)
 {
 	/* NB: @offset and @len are only useful for receiving */
@@ -340,7 +340,7 @@ lnet_msg_attach_md(lnet_msg_t *msg, lnet_libmd_t *md,
 }
 
 void
-lnet_msg_detach_md(lnet_msg_t *msg, int status)
+lnet_msg_detach_md(struct lnet_msg *msg, int status)
 {
 	lnet_libmd_t *md = msg->msg_md;
 	int unlink;
@@ -363,7 +363,7 @@ lnet_msg_detach_md(lnet_msg_t *msg, int status)
 }
 
 static int
-lnet_complete_msg_locked(lnet_msg_t *msg, int cpt)
+lnet_complete_msg_locked(struct lnet_msg *msg, int cpt)
 {
 	lnet_handle_wire_t ack_wmd;
 	int rc;
@@ -441,7 +441,7 @@ lnet_complete_msg_locked(lnet_msg_t *msg, int cpt)
 }
 
 void
-lnet_finalize(lnet_ni_t *ni, lnet_msg_t *msg, int status)
+lnet_finalize(lnet_ni_t *ni, struct lnet_msg *msg, int status)
 {
 	struct lnet_msg_container *container;
 	int my_slot;
@@ -522,7 +522,7 @@ lnet_finalize(lnet_ni_t *ni, lnet_msg_t *msg, int status)
 
 	while (!list_empty(&container->msc_finalizing)) {
 		msg = list_entry(container->msc_finalizing.next,
-				 lnet_msg_t, msg_list);
+				 struct lnet_msg, msg_list);
 
 		list_del(&msg->msg_list);
 
@@ -558,8 +558,8 @@ lnet_msg_container_cleanup(struct lnet_msg_container *container)
 		return;
 
 	while (!list_empty(&container->msc_active)) {
-		lnet_msg_t *msg = list_entry(container->msc_active.next,
-					     lnet_msg_t, msg_activelist);
+		struct lnet_msg *msg = list_entry(container->msc_active.next,
+					     struct lnet_msg, msg_activelist);
 
 		LASSERT(msg->msg_onactivelist);
 		msg->msg_onactivelist = 0;
diff --git a/drivers/staging/lustre/lnet/lnet/lib-ptl.c b/drivers/staging/lustre/lnet/lnet/lib-ptl.c
index 3947e8b..bfec6c4 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-ptl.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-ptl.c
@@ -657,8 +657,8 @@ lnet_ptl_attach_md(lnet_me_t *me, lnet_libmd_t *md,
 	struct lnet_portal *ptl = the_lnet.ln_portals[me->me_portal];
 	struct lnet_match_table	*mtable;
 	struct list_head *head;
-	lnet_msg_t *tmp;
-	lnet_msg_t *msg;
+	struct lnet_msg *tmp;
+	struct lnet_msg *msg;
 	int exhausted = 0;
 	int cpt;
 
diff --git a/drivers/staging/lustre/lnet/lnet/lo.c b/drivers/staging/lustre/lnet/lnet/lo.c
index 2216301..80c2101 100644
--- a/drivers/staging/lustre/lnet/lnet/lo.c
+++ b/drivers/staging/lustre/lnet/lnet/lo.c
@@ -36,7 +36,7 @@
 #include "../../include/linux/lnet/lib-lnet.h"
 
 static int
-lolnd_send(lnet_ni_t *ni, void *private, lnet_msg_t *lntmsg)
+lolnd_send(lnet_ni_t *ni, void *private, struct lnet_msg *lntmsg)
 {
 	LASSERT(!lntmsg->msg_routing);
 	LASSERT(!lntmsg->msg_target_is_router);
@@ -45,12 +45,12 @@ lolnd_send(lnet_ni_t *ni, void *private, lnet_msg_t *lntmsg)
 }
 
 static int
-lolnd_recv(lnet_ni_t *ni, void *private, lnet_msg_t *lntmsg,
+lolnd_recv(lnet_ni_t *ni, void *private, struct lnet_msg *lntmsg,
 	   int delayed, unsigned int niov,
 	   struct kvec *iov, lnet_kiov_t *kiov,
 	   unsigned int offset, unsigned int mlen, unsigned int rlen)
 {
-	lnet_msg_t *sendmsg = private;
+	struct lnet_msg *sendmsg = private;
 
 	if (lntmsg) {		   /* not discarding */
 		if (sendmsg->msg_iov) {
-- 
2.8.0.rc4.16.g56331f8
