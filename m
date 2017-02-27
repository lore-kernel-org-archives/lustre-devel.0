From: James Simmons <jsimmons@infradead.org>
Date: Sun, 26 Feb 2017 19:41:31 -0500
Subject: [lustre-devel] [PATCH 06/34] staging: lustre: lnet: change
	lnet_msg_t to proper structure
In-Reply-To: <1488156119-19670-1-git-send-email-jsimmons@infradead.org>
References: <1488156119-19670-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1488156119-19670-7-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@yahoo.com>

Change lnet_msg_t from typedef to proper structure.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-on: https://review.whamcloud.com/20831
Reviewed-by: Olaf Weber <olaf@sgi.com>
Reviewed-by: Doug Oucharek <doug.s.oucharek@intel.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/include/linux/lnet/lib-lnet.h   | 43 +++++++------
 .../staging/lustre/include/linux/lnet/lib-types.h  | 11 ++--
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h    |  8 +--
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c | 10 +--
 .../staging/lustre/lnet/klnds/socklnd/socklnd.h    |  6 +-
 .../staging/lustre/lnet/klnds/socklnd/socklnd_cb.c |  8 +--
 drivers/staging/lustre/lnet/lnet/api-ni.c          |  2 +-
 drivers/staging/lustre/lnet/lnet/lib-move.c        | 75 +++++++++++-----------
 drivers/staging/lustre/lnet/lnet/lib-msg.c         | 25 ++++----
 drivers/staging/lustre/lnet/lnet/lib-ptl.c         |  4 +-
 drivers/staging/lustre/lnet/lnet/lo.c              |  6 +-
 11 files changed, 102 insertions(+), 96 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
index bd8d117..e894990 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
@@ -248,10 +248,10 @@ static inline int lnet_md_unlinkable(lnet_libmd_t *md)
 	LIBCFS_FREE(me, sizeof(*me));
 }
 
-static inline lnet_msg_t *
+static inline struct lnet_msg *
 lnet_msg_alloc(void)
 {
-	lnet_msg_t *msg;
+	struct lnet_msg *msg;
 
 	LIBCFS_ALLOC(msg, sizeof(*msg));
 
@@ -260,7 +260,7 @@ static inline int lnet_md_unlinkable(lnet_libmd_t *md)
 }
 
 static inline void
-lnet_msg_free(lnet_msg_t *msg)
+lnet_msg_free(struct lnet_msg *msg)
 {
 	LASSERT(!msg->msg_onactivelist);
 	LIBCFS_FREE(msg, sizeof(*msg));
@@ -482,20 +482,20 @@ int lnet_dyn_add_ni(lnet_pid_t requested_pid,
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
 
@@ -554,19 +554,22 @@ void lnet_ptl_attach_md(lnet_me_t *me, lnet_libmd_t *md,
 /* message functions */
 int lnet_parse(lnet_ni_t *ni, struct lnet_hdr *hdr,
 	       lnet_nid_t fromnid, void *private, int rdma_req);
-int lnet_parse_local(lnet_ni_t *ni, lnet_msg_t *msg);
-int lnet_parse_forward_locked(lnet_ni_t *ni, lnet_msg_t *msg);
+int lnet_parse_local(lnet_ni_t *ni, struct lnet_msg *msg);
+int lnet_parse_forward_locked(lnet_ni_t *ni, struct lnet_msg *msg);
 
-void lnet_recv(lnet_ni_t *ni, void *private, lnet_msg_t *msg, int delayed,
-	       unsigned int offset, unsigned int mlen, unsigned int rlen);
-void lnet_ni_recv(lnet_ni_t *ni, void *private, lnet_msg_t *msg,
+void lnet_recv(lnet_ni_t *ni, void *private, struct lnet_msg *msg,
+	       int delayed, unsigned int offset, unsigned int mlen,
+	       unsigned int rlen);
+void lnet_ni_recv(lnet_ni_t *ni, void *private, struct lnet_msg *msg,
 		  int delayed, unsigned int offset,
 		  unsigned int mlen, unsigned int rlen);
 
-lnet_msg_t *lnet_create_reply_msg(lnet_ni_t *ni, lnet_msg_t *get_msg);
-void lnet_set_reply_msg_len(lnet_ni_t *ni, lnet_msg_t *msg, unsigned int len);
+struct lnet_msg *lnet_create_reply_msg(lnet_ni_t *ni,
+				       struct lnet_msg *get_msg);
+void lnet_set_reply_msg_len(lnet_ni_t *ni, struct lnet_msg *msg,
+			    unsigned int len);
 
-void lnet_finalize(lnet_ni_t *ni, lnet_msg_t *msg, int rc);
+void lnet_finalize(lnet_ni_t *ni, struct lnet_msg *msg, int rc);
 
 void lnet_drop_message(lnet_ni_t *ni, int cpt, void *private,
 		       unsigned int nob);
diff --git a/drivers/staging/lustre/include/linux/lnet/lib-types.h b/drivers/staging/lustre/include/linux/lnet/lib-types.h
index 7ce0091..e3cb795 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-types.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-types.h
@@ -54,7 +54,7 @@
 /* forward refs */
 struct lnet_libmd;
 
-typedef struct lnet_msg {
+struct lnet_msg {
 	struct list_head	msg_activelist;
 	struct list_head	msg_list;	   /* Q for credits/MD */
 
@@ -106,7 +106,7 @@
 
 	lnet_event_t		 msg_ev;
 	struct lnet_hdr		 msg_hdr;
-} lnet_msg_t;
+};
 
 typedef struct lnet_libhandle {
 	struct list_head	lh_hash_chain;
@@ -210,7 +210,8 @@
 	 * non-zero for immediate failure, otherwise complete later with
 	 * lnet_finalize()
 	 */
-	int (*lnd_send)(struct lnet_ni *ni, void *private, lnet_msg_t *msg);
+	int (*lnd_send)(struct lnet_ni *ni, void *private,
+			struct lnet_msg *msg);
 
 	/*
 	 * Start receiving 'mlen' bytes of payload data, skipping the following
@@ -219,7 +220,7 @@
 	 * complete later with lnet_finalize().  This also gives back a receive
 	 * credit if the LND does flow control.
 	 */
-	int (*lnd_recv)(struct lnet_ni *ni, void *private, lnet_msg_t *msg,
+	int (*lnd_recv)(struct lnet_ni *ni, void *private, struct lnet_msg *msg,
 			int delayed, struct iov_iter *to, unsigned int rlen);
 
 	/*
@@ -231,7 +232,7 @@
 	 * release resources; lnd_recv() will not be called.
 	 */
 	int (*lnd_eager_recv)(struct lnet_ni *ni, void *private,
-			      lnet_msg_t *msg, void **new_privatep);
+			      struct lnet_msg *msg, void **new_privatep);
 
 	/* notification of peer health */
 	void (*lnd_notify)(struct lnet_ni *ni, lnet_nid_t peer, int alive);
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
index 366372d..dbd3b8e 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
@@ -490,7 +490,7 @@ struct kib_tx {					/* transmit message */
 	int                   tx_status;      /* LNET completion status */
 	unsigned long         tx_deadline;    /* completion deadline */
 	__u64                 tx_cookie;      /* completion cookie */
-	lnet_msg_t *tx_lntmsg[2]; /* lnet msgs to finalize on completion */
+	struct lnet_msg		*tx_lntmsg[2];	/* lnet msgs to finalize on completion */
 	struct kib_msg	      *tx_msg;        /* message buffer (host vaddr) */
 	__u64                 tx_msgaddr;     /* message buffer (I/O addr) */
 	DECLARE_PCI_UNMAP_ADDR(tx_msgunmap);  /* for dma_unmap_single() */
@@ -1032,6 +1032,6 @@ void kiblnd_pack_msg(lnet_ni_t *ni, struct kib_msg *msg, int version,
 int  kiblnd_unpack_msg(struct kib_msg *msg, int nob);
 int  kiblnd_post_rx(struct kib_rx *rx, int credit);
 
-int  kiblnd_send(lnet_ni_t *ni, void *private, lnet_msg_t *lntmsg);
-int  kiblnd_recv(lnet_ni_t *ni, void *private, lnet_msg_t *lntmsg, int delayed,
-		 struct iov_iter *to, unsigned int rlen);
+int kiblnd_send(lnet_ni_t *ni, void *private, struct lnet_msg *lntmsg);
+int kiblnd_recv(lnet_ni_t *ni, void *private, struct lnet_msg *lntmsg,
+		int delayed, struct iov_iter *to, unsigned int rlen);
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
index 6eaa548..021e6ac 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -53,7 +53,7 @@ static int kiblnd_init_rdma(struct kib_conn *conn, struct kib_tx *tx, int type,
 static void
 kiblnd_tx_done(lnet_ni_t *ni, struct kib_tx *tx)
 {
-	lnet_msg_t *lntmsg[2];
+	struct lnet_msg *lntmsg[2];
 	struct kib_net *net = ni->ni_data;
 	int rc;
 	int i;
@@ -1475,7 +1475,7 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
 }
 
 int
-kiblnd_send(lnet_ni_t *ni, void *private, lnet_msg_t *lntmsg)
+kiblnd_send(lnet_ni_t *ni, void *private, struct lnet_msg *lntmsg)
 {
 	struct lnet_hdr *hdr = &lntmsg->msg_hdr;
 	int type = lntmsg->msg_type;
@@ -1648,7 +1648,7 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
 }
 
 static void
-kiblnd_reply(lnet_ni_t *ni, struct kib_rx *rx, lnet_msg_t *lntmsg)
+kiblnd_reply(lnet_ni_t *ni, struct kib_rx *rx, struct lnet_msg *lntmsg)
 {
 	lnet_process_id_t target = lntmsg->msg_target;
 	unsigned int niov = lntmsg->msg_niov;
@@ -1709,8 +1709,8 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
 }
 
 int
-kiblnd_recv(lnet_ni_t *ni, void *private, lnet_msg_t *lntmsg, int delayed,
-	    struct iov_iter *to, unsigned int rlen)
+kiblnd_recv(lnet_ni_t *ni, void *private, struct lnet_msg *lntmsg,
+	    int delayed, struct iov_iter *to, unsigned int rlen)
 {
 	struct kib_rx *rx = private;
 	struct kib_msg *rxmsg = rx->rx_msg;
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h
index 3631998..d03a029 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h
@@ -284,7 +284,7 @@ struct ksock_tx {			   /* transmit packet */
 	unsigned short    tx_nonblk:1;     /* it's a non-blocking ACK */
 	lnet_kiov_t       *tx_kiov;        /* packet page frags */
 	struct ksock_conn *tx_conn;        /* owning conn */
-	lnet_msg_t        *tx_lnetmsg;     /* lnet message for lnet_finalize()
+	struct lnet_msg        *tx_lnetmsg;     /* lnet message for lnet_finalize()
 					    */
 	unsigned long     tx_deadline;     /* when (in jiffies) tx times out */
 	struct ksock_msg       tx_msg;          /* socklnd message buffer */
@@ -650,8 +650,8 @@ static inline __u32 ksocknal_csum(__u32 crc, unsigned char const *p, size_t len)
 int ksocknal_startup(lnet_ni_t *ni);
 void ksocknal_shutdown(lnet_ni_t *ni);
 int ksocknal_ctl(lnet_ni_t *ni, unsigned int cmd, void *arg);
-int ksocknal_send(lnet_ni_t *ni, void *private, lnet_msg_t *lntmsg);
-int ksocknal_recv(lnet_ni_t *ni, void *private, lnet_msg_t *lntmsg,
+int ksocknal_send(lnet_ni_t *ni, void *private, struct lnet_msg *lntmsg);
+int ksocknal_recv(lnet_ni_t *ni, void *private, struct lnet_msg *lntmsg,
 		  int delayed, struct iov_iter *to, unsigned int rlen);
 int ksocknal_accept(lnet_ni_t *ni, struct socket *sock);
 
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
index 9fbae62..66827f2 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
@@ -395,7 +395,7 @@ struct ksock_tx *
 void
 ksocknal_tx_done(lnet_ni_t *ni, struct ksock_tx *tx)
 {
-	lnet_msg_t *lnetmsg = tx->tx_lnetmsg;
+	struct lnet_msg *lnetmsg = tx->tx_lnetmsg;
 	int rc = (!tx->tx_resid && !tx->tx_zc_aborted) ? 0 : -EIO;
 
 	LASSERT(ni || tx->tx_conn);
@@ -938,7 +938,7 @@ struct ksock_route *
 }
 
 int
-ksocknal_send(lnet_ni_t *ni, void *private, lnet_msg_t *lntmsg)
+ksocknal_send(lnet_ni_t *ni, void *private, struct lnet_msg *lntmsg)
 {
 	int mpflag = 1;
 	int type = lntmsg->msg_type;
@@ -1333,8 +1333,8 @@ struct ksock_route *
 }
 
 int
-ksocknal_recv(lnet_ni_t *ni, void *private, lnet_msg_t *msg, int delayed,
-	      struct iov_iter *to, unsigned int rlen)
+ksocknal_recv(lnet_ni_t *ni, void *private, struct lnet_msg *msg,
+	      int delayed, struct iov_iter *to, unsigned int rlen)
 {
 	struct ksock_conn *conn = private;
 	struct ksock_sched *sched = conn->ksnc_scheduler;
diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
index efafd42..5161b8a 100644
--- a/drivers/staging/lustre/lnet/lnet/api-ni.c
+++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
@@ -1173,7 +1173,7 @@ static void lnet_assert_wire_constants(void)
 
 	/*
 	 * Clear lazy portals and drop delayed messages which hold refs
-	 * on their lnet_msg_t::msg_rxpeer
+	 * on their lnet_msg::msg_rxpeer
 	 */
 	for (i = 0; i < the_lnet.ln_nportals; i++)
 		LNetClearLazyPortal(i);
diff --git a/drivers/staging/lustre/lnet/lnet/lib-move.c b/drivers/staging/lustre/lnet/lnet/lib-move.c
index 88d87eb..a789d7e 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-move.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-move.c
@@ -364,8 +364,9 @@
 EXPORT_SYMBOL(lnet_extract_kiov);
 
 void
-lnet_ni_recv(lnet_ni_t *ni, void *private, lnet_msg_t *msg, int delayed,
-	     unsigned int offset, unsigned int mlen, unsigned int rlen)
+lnet_ni_recv(lnet_ni_t *ni, void *private, struct lnet_msg *msg,
+	     int delayed, unsigned int offset, unsigned int mlen,
+	     unsigned int rlen)
 {
 	unsigned int niov = 0;
 	struct kvec *iov = NULL;
@@ -409,7 +410,7 @@
 }
 
 static void
-lnet_setpayloadbuffer(lnet_msg_t *msg)
+lnet_setpayloadbuffer(struct lnet_msg *msg)
 {
 	lnet_libmd_t *md = msg->msg_md;
 
@@ -428,7 +429,7 @@
 }
 
 void
-lnet_prep_send(lnet_msg_t *msg, int type, lnet_process_id_t target,
+lnet_prep_send(struct lnet_msg *msg, int type, lnet_process_id_t target,
 	       unsigned int offset, unsigned int len)
 {
 	msg->msg_type = type;
@@ -449,7 +450,7 @@
 }
 
 static void
-lnet_ni_send(lnet_ni_t *ni, lnet_msg_t *msg)
+lnet_ni_send(lnet_ni_t *ni, struct lnet_msg *msg)
 {
 	void *priv = msg->msg_private;
 	int rc;
@@ -464,7 +465,7 @@
 }
 
 static int
-lnet_ni_eager_recv(lnet_ni_t *ni, lnet_msg_t *msg)
+lnet_ni_eager_recv(lnet_ni_t *ni, struct lnet_msg *msg)
 {
 	int rc;
 
@@ -595,7 +596,7 @@
  * \retval -ECANCELED If the MD of the message has been unlinked.
  */
 static int
-lnet_post_send_locked(lnet_msg_t *msg, int do_send)
+lnet_post_send_locked(struct lnet_msg *msg, int do_send)
 {
 	lnet_peer_t *lp = msg->msg_txpeer;
 	lnet_ni_t *ni = lp->lp_ni;
@@ -680,7 +681,7 @@
 }
 
 static lnet_rtrbufpool_t *
-lnet_msg2bufpool(lnet_msg_t *msg)
+lnet_msg2bufpool(struct lnet_msg *msg)
 {
 	lnet_rtrbufpool_t *rbp;
 	int cpt;
@@ -700,7 +701,7 @@
 }
 
 static int
-lnet_post_routed_recv_locked(lnet_msg_t *msg, int do_recv)
+lnet_post_routed_recv_locked(struct lnet_msg *msg, int do_recv)
 {
 	/*
 	 * lnet_parse is going to lnet_net_unlock immediately after this, so it
@@ -776,10 +777,10 @@
 }
 
 void
-lnet_return_tx_credits_locked(lnet_msg_t *msg)
+lnet_return_tx_credits_locked(struct lnet_msg *msg)
 {
 	lnet_peer_t *txpeer = msg->msg_txpeer;
-	lnet_msg_t *msg2;
+	struct lnet_msg *msg2;
 
 	if (msg->msg_txcredit) {
 		struct lnet_ni *ni = txpeer->lp_ni;
@@ -794,7 +795,7 @@
 		tq->tq_credits++;
 		if (tq->tq_credits <= 0) {
 			msg2 = list_entry(tq->tq_delayed.next,
-					  lnet_msg_t, msg_list);
+					  struct lnet_msg, msg_list);
 			list_del(&msg2->msg_list);
 
 			LASSERT(msg2->msg_txpeer->lp_ni == ni);
@@ -817,7 +818,7 @@
 		txpeer->lp_txcredits++;
 		if (txpeer->lp_txcredits <= 0) {
 			msg2 = list_entry(txpeer->lp_txq.next,
-					  lnet_msg_t, msg_list);
+					  struct lnet_msg, msg_list);
 			list_del(&msg2->msg_list);
 
 			LASSERT(msg2->msg_txpeer == txpeer);
@@ -836,12 +837,12 @@
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
@@ -851,8 +852,8 @@
 lnet_drop_routed_msgs_locked(struct list_head *list, int cpt)
 {
 	struct list_head drop;
-	lnet_msg_t *msg;
-	lnet_msg_t *tmp;
+	struct lnet_msg *msg;
+	struct lnet_msg *tmp;
 
 	INIT_LIST_HEAD(&drop);
 
@@ -871,10 +872,10 @@
 }
 
 void
-lnet_return_rx_credits_locked(lnet_msg_t *msg)
+lnet_return_rx_credits_locked(struct lnet_msg *msg)
 {
 	lnet_peer_t *rxpeer = msg->msg_rxpeer;
-	lnet_msg_t *msg2;
+	struct lnet_msg *msg2;
 
 	if (msg->msg_rtrcredit) {
 		/* give back global router credits */
@@ -943,7 +944,7 @@
 						     msg->msg_rx_cpt);
 		} else if (rxpeer->lp_rtrcredits <= 0) {
 			msg2 = list_entry(rxpeer->lp_rtrq.next,
-					  lnet_msg_t, msg_list);
+					  struct lnet_msg, msg_list);
 			list_del(&msg2->msg_list);
 
 			(void)lnet_post_routed_recv_locked(msg2, 1);
@@ -1057,7 +1058,7 @@
 }
 
 int
-lnet_send(lnet_nid_t src_nid, lnet_msg_t *msg, lnet_nid_t rtr_nid)
+lnet_send(lnet_nid_t src_nid, struct lnet_msg *msg, lnet_nid_t rtr_nid)
 {
 	lnet_nid_t dst_nid = msg->msg_target.nid;
 	struct lnet_ni *src_ni;
@@ -1243,7 +1244,7 @@
 }
 
 static void
-lnet_recv_put(lnet_ni_t *ni, lnet_msg_t *msg)
+lnet_recv_put(lnet_ni_t *ni, struct lnet_msg *msg)
 {
 	struct lnet_hdr *hdr = &msg->msg_hdr;
 
@@ -1264,7 +1265,7 @@
 }
 
 static int
-lnet_parse_put(lnet_ni_t *ni, lnet_msg_t *msg)
+lnet_parse_put(lnet_ni_t *ni, struct lnet_msg *msg)
 {
 	struct lnet_hdr *hdr = &msg->msg_hdr;
 	struct lnet_match_info info;
@@ -1322,7 +1323,7 @@
 }
 
 static int
-lnet_parse_get(lnet_ni_t *ni, lnet_msg_t *msg, int rdma_get)
+lnet_parse_get(lnet_ni_t *ni, struct lnet_msg *msg, int rdma_get)
 {
 	struct lnet_match_info info;
 	struct lnet_hdr *hdr = &msg->msg_hdr;
@@ -1386,7 +1387,7 @@
 }
 
 static int
-lnet_parse_reply(lnet_ni_t *ni, lnet_msg_t *msg)
+lnet_parse_reply(lnet_ni_t *ni, struct lnet_msg *msg)
 {
 	void *private = msg->msg_private;
 	struct lnet_hdr *hdr = &msg->msg_hdr;
@@ -1451,7 +1452,7 @@
 }
 
 static int
-lnet_parse_ack(lnet_ni_t *ni, lnet_msg_t *msg)
+lnet_parse_ack(lnet_ni_t *ni, struct lnet_msg *msg)
 {
 	struct lnet_hdr *hdr = &msg->msg_hdr;
 	lnet_process_id_t src = {0};
@@ -1506,7 +1507,7 @@
  * \retval -ve			error code
  */
 int
-lnet_parse_forward_locked(lnet_ni_t *ni, lnet_msg_t *msg)
+lnet_parse_forward_locked(lnet_ni_t *ni, struct lnet_msg *msg)
 {
 	int rc = 0;
 
@@ -1530,7 +1531,7 @@
 }
 
 int
-lnet_parse_local(lnet_ni_t *ni, lnet_msg_t *msg)
+lnet_parse_local(lnet_ni_t *ni, struct lnet_msg *msg)
 {
 	int rc;
 
@@ -1874,9 +1875,9 @@
 {
 	while (!list_empty(head)) {
 		lnet_process_id_t id = {0};
-		lnet_msg_t *msg;
+		struct lnet_msg *msg;
 
-		msg = list_entry(head->next, lnet_msg_t, msg_list);
+		msg = list_entry(head->next, struct lnet_msg, msg_list);
 		list_del(&msg->msg_list);
 
 		id.nid = msg->msg_hdr.src_nid;
@@ -1915,10 +1916,10 @@
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
@@ -2009,7 +2010,7 @@
 
 	msg = lnet_msg_alloc();
 	if (!msg) {
-		CERROR("Dropping PUT to %s: ENOMEM on lnet_msg_t\n",
+		CERROR("Dropping PUT to %s: ENOMEM on struct lnet_msg\n",
 		       libcfs_id2str(target));
 		return -ENOMEM;
 	}
@@ -2072,8 +2073,8 @@
 }
 EXPORT_SYMBOL(LNetPut);
 
-lnet_msg_t *
-lnet_create_reply_msg(lnet_ni_t *ni, lnet_msg_t *getmsg)
+struct lnet_msg *
+lnet_create_reply_msg(lnet_ni_t *ni, struct lnet_msg *getmsg)
 {
 	/*
 	 * The LND can DMA direct to the GET md (i.e. no REPLY msg).  This
@@ -2151,7 +2152,7 @@
 EXPORT_SYMBOL(lnet_create_reply_msg);
 
 void
-lnet_set_reply_msg_len(lnet_ni_t *ni, lnet_msg_t *reply, unsigned int len)
+lnet_set_reply_msg_len(lnet_ni_t *ni, struct lnet_msg *reply, unsigned int len)
 {
 	/*
 	 * Set the REPLY length, now the RDMA that elides the REPLY message has
@@ -2213,7 +2214,7 @@
 
 	msg = lnet_msg_alloc();
 	if (!msg) {
-		CERROR("Dropping GET to %s: ENOMEM on lnet_msg_t\n",
+		CERROR("Dropping GET to %s: ENOMEM on struct lnet_msg\n",
 		       libcfs_id2str(target));
 		return -ENOMEM;
 	}
diff --git a/drivers/staging/lustre/lnet/lnet/lib-msg.c b/drivers/staging/lustre/lnet/lnet/lib-msg.c
index 7ee164e..d35d28b 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-msg.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-msg.c
@@ -54,7 +54,7 @@
  * Don't need any lock, must be called after lnet_commit_md
  */
 void
-lnet_build_msg_event(lnet_msg_t *msg, lnet_event_kind_t ev_type)
+lnet_build_msg_event(struct lnet_msg *msg, lnet_event_kind_t ev_type)
 {
 	struct lnet_hdr *hdr = &msg->msg_hdr;
 	lnet_event_t *ev  = &msg->msg_ev;
@@ -129,7 +129,7 @@
 }
 
 void
-lnet_msg_commit(lnet_msg_t *msg, int cpt)
+lnet_msg_commit(struct lnet_msg *msg, int cpt)
 {
 	struct lnet_msg_container *container = the_lnet.ln_msg_containers[cpt];
 	lnet_counters_t *counters  = the_lnet.ln_counters[cpt];
@@ -162,7 +162,7 @@
 }
 
 static void
-lnet_msg_decommit_tx(lnet_msg_t *msg, int status)
+lnet_msg_decommit_tx(struct lnet_msg *msg, int status)
 {
 	lnet_counters_t	*counters;
 	lnet_event_t *ev = &msg->msg_ev;
@@ -214,7 +214,7 @@
 }
 
 static void
-lnet_msg_decommit_rx(lnet_msg_t *msg, int status)
+lnet_msg_decommit_rx(struct lnet_msg *msg, int status)
 {
 	lnet_counters_t *counters;
 	lnet_event_t *ev = &msg->msg_ev;
@@ -272,7 +272,7 @@
 }
 
 void
-lnet_msg_decommit(lnet_msg_t *msg, int cpt, int status)
+lnet_msg_decommit(struct lnet_msg *msg, int cpt, int status)
 {
 	int cpt2 = cpt;
 
@@ -306,7 +306,7 @@
 }
 
 void
-lnet_msg_attach_md(lnet_msg_t *msg, lnet_libmd_t *md,
+lnet_msg_attach_md(struct lnet_msg *msg, lnet_libmd_t *md,
 		   unsigned int offset, unsigned int mlen)
 {
 	/* NB: @offset and @len are only useful for receiving */
@@ -336,7 +336,7 @@
 }
 
 void
-lnet_msg_detach_md(lnet_msg_t *msg, int status)
+lnet_msg_detach_md(struct lnet_msg *msg, int status)
 {
 	lnet_libmd_t *md = msg->msg_md;
 	int unlink;
@@ -359,7 +359,7 @@
 }
 
 static int
-lnet_complete_msg_locked(lnet_msg_t *msg, int cpt)
+lnet_complete_msg_locked(struct lnet_msg *msg, int cpt)
 {
 	struct lnet_handle_wire ack_wmd;
 	int rc;
@@ -437,7 +437,7 @@
 }
 
 void
-lnet_finalize(lnet_ni_t *ni, lnet_msg_t *msg, int status)
+lnet_finalize(lnet_ni_t *ni, struct lnet_msg *msg, int status)
 {
 	struct lnet_msg_container *container;
 	int my_slot;
@@ -502,7 +502,7 @@
 
 	while (!list_empty(&container->msc_finalizing)) {
 		msg = list_entry(container->msc_finalizing.next,
-				 lnet_msg_t, msg_list);
+				 struct lnet_msg, msg_list);
 
 		list_del(&msg->msg_list);
 
@@ -538,9 +538,10 @@
 		return;
 
 	while (!list_empty(&container->msc_active)) {
-		lnet_msg_t *msg = list_entry(container->msc_active.next,
-					     lnet_msg_t, msg_activelist);
+		struct lnet_msg *msg;
 
+		msg = list_entry(container->msc_active.next,
+				 struct lnet_msg, msg_activelist);
 		LASSERT(msg->msg_onactivelist);
 		msg->msg_onactivelist = 0;
 		list_del(&msg->msg_activelist);
diff --git a/drivers/staging/lustre/lnet/lnet/lib-ptl.c b/drivers/staging/lustre/lnet/lnet/lib-ptl.c
index fa515af..891d028 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-ptl.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-ptl.c
@@ -657,8 +657,8 @@ struct list_head *
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
index cb213b8..12b6b3a 100644
--- a/drivers/staging/lustre/lnet/lnet/lo.c
+++ b/drivers/staging/lustre/lnet/lnet/lo.c
@@ -32,7 +32,7 @@
 #include "../../include/linux/lnet/lib-lnet.h"
 
 static int
-lolnd_send(lnet_ni_t *ni, void *private, lnet_msg_t *lntmsg)
+lolnd_send(lnet_ni_t *ni, void *private, struct lnet_msg *lntmsg)
 {
 	LASSERT(!lntmsg->msg_routing);
 	LASSERT(!lntmsg->msg_target_is_router);
@@ -41,10 +41,10 @@
 }
 
 static int
-lolnd_recv(lnet_ni_t *ni, void *private, lnet_msg_t *lntmsg,
+lolnd_recv(lnet_ni_t *ni, void *private, struct lnet_msg *lntmsg,
 	   int delayed, struct iov_iter *to, unsigned int rlen)
 {
-	lnet_msg_t *sendmsg = private;
+	struct lnet_msg *sendmsg = private;
 
 	if (lntmsg) {		   /* not discarding */
 		if (sendmsg->msg_iov)
-- 
1.8.3.1
