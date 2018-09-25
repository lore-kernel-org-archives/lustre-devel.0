From: NeilBrown <neilb@suse.com>
Date: Tue, 25 Sep 2018 11:07:15 +1000
Subject: [lustre-devel] [PATCH 20/34] LU-7734 lnet: protect peer_ni credits
In-Reply-To: <153783752960.32103.8394391715843917125.stgit@noble>
References: <153783752960.32103.8394391715843917125.stgit@noble>
Message-ID: <153783763565.32103.14024172070634950028.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <amir.shehata@intel.com>

Currently multiple NIs can talk to the same peer_ni. The per-CPT
lnet_net_lock therefore no longer protects the lpni against
concurrent updates. To resolve this issue a spinlock is added
to the lnet_peer_ni, which must be locked when the peer NI
credits, delayed message queue, and delayed routed message queue
are modified. The lock is not taken when reporting credits.

Signed-off-by: Amir Shehata <amir.shehata@intel.com>
Signed-off-by: Olaf Weber <olaf@sgi.com>
Change-Id: I52153680a74d43e595314b63487026cc3f6a5a8f
Reviewed-on: http://review.whamcloud.com/20702
Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lnet/lnet/lib-move.c |   40 ++++++++++++++++++++-------
 drivers/staging/lustre/lnet/lnet/peer.c     |    8 ++++-
 drivers/staging/lustre/lnet/lnet/router.c   |    3 +-
 3 files changed, 38 insertions(+), 13 deletions(-)

diff --git a/drivers/staging/lustre/lnet/lnet/lib-move.c b/drivers/staging/lustre/lnet/lnet/lib-move.c
index 51224a4cb218..b4c7c8aa33a7 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-move.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-move.c
@@ -657,6 +657,7 @@ lnet_post_send_locked(struct lnet_msg *msg, int do_send)
 	}
 
 	if (!msg->msg_peertxcredit) {
+		spin_lock(&lp->lpni_lock);
 		LASSERT((lp->lpni_txcredits < 0) ==
 			!list_empty(&lp->lpni_txq));
 
@@ -670,8 +671,10 @@ lnet_post_send_locked(struct lnet_msg *msg, int do_send)
 		if (lp->lpni_txcredits < 0) {
 			msg->msg_tx_delayed = 1;
 			list_add_tail(&msg->msg_list, &lp->lpni_txq);
+			spin_unlock(&lp->lpni_lock);
 			return LNET_CREDIT_WAIT;
 		}
+		spin_unlock(&lp->lpni_lock);
 	}
 
 	if (!msg->msg_txcredit) {
@@ -744,6 +747,7 @@ lnet_post_routed_recv_locked(struct lnet_msg *msg, int do_recv)
 	LASSERT(!do_recv || msg->msg_rx_delayed);
 
 	if (!msg->msg_peerrtrcredit) {
+		spin_lock(&lp->lpni_lock);
 		LASSERT((lp->lpni_rtrcredits < 0) ==
 			!list_empty(&lp->lpni_rtrq));
 
@@ -757,8 +761,10 @@ lnet_post_routed_recv_locked(struct lnet_msg *msg, int do_recv)
 			LASSERT(msg->msg_rx_ready_delay);
 			msg->msg_rx_delayed = 1;
 			list_add_tail(&msg->msg_list, &lp->lpni_rtrq);
+			spin_unlock(&lp->lpni_lock);
 			return LNET_CREDIT_WAIT;
 		}
+		spin_unlock(&lp->lpni_lock);
 	}
 
 	rbp = lnet_msg2bufpool(msg);
@@ -822,6 +828,7 @@ lnet_return_tx_credits_locked(struct lnet_msg *msg)
 
 			LASSERT(msg2->msg_txni == ni);
 			LASSERT(msg2->msg_tx_delayed);
+			LASSERT(msg2->msg_tx_cpt == msg->msg_tx_cpt);
 
 			(void)lnet_post_send_locked(msg2, 1);
 		}
@@ -831,6 +838,7 @@ lnet_return_tx_credits_locked(struct lnet_msg *msg)
 		/* give back peer txcredits */
 		msg->msg_peertxcredit = 0;
 
+		spin_lock(&txpeer->lpni_lock);
 		LASSERT((txpeer->lpni_txcredits < 0) ==
 			!list_empty(&txpeer->lpni_txq));
 
@@ -842,11 +850,22 @@ lnet_return_tx_credits_locked(struct lnet_msg *msg)
 			msg2 = list_entry(txpeer->lpni_txq.next,
 					  struct lnet_msg, msg_list);
 			list_del(&msg2->msg_list);
+			spin_unlock(&txpeer->lpni_lock);
 
 			LASSERT(msg2->msg_txpeer == txpeer);
 			LASSERT(msg2->msg_tx_delayed);
 
+			if (msg2->msg_tx_cpt != msg->msg_tx_cpt) {
+				lnet_net_unlock(msg->msg_tx_cpt);
+				lnet_net_lock(msg2->msg_tx_cpt);
+			}
 			(void)lnet_post_send_locked(msg2, 1);
+			if (msg2->msg_tx_cpt != msg->msg_tx_cpt) {
+				lnet_net_unlock(msg2->msg_tx_cpt);
+				lnet_net_lock(msg->msg_tx_cpt);
+			}
+		} else {
+			spin_unlock(&txpeer->lpni_lock);
 		}
 	}
 
@@ -887,17 +906,12 @@ lnet_schedule_blocked_locked(struct lnet_rtrbufpool *rbp)
 void
 lnet_drop_routed_msgs_locked(struct list_head *list, int cpt)
 {
-	struct list_head drop;
 	struct lnet_msg *msg;
 
-	INIT_LIST_HEAD(&drop);
-
-	list_splice_init(list, &drop);
-
 	lnet_net_unlock(cpt);
 
-	while(!list_empty(&drop)) {
-		msg = list_first_entry(&drop, struct lnet_msg, msg_list);
+	while (!list_empty(list)) {
+		msg = list_first_entry(list, struct lnet_msg, msg_list);
 		lnet_ni_recv(msg->msg_rxni, msg->msg_private, NULL,
 			     0, 0, 0, msg->msg_hdr.payload_length);
 		list_del_init(&msg->msg_list);
@@ -968,6 +982,7 @@ lnet_return_rx_credits_locked(struct lnet_msg *msg)
 		/* give back peer router credits */
 		msg->msg_peerrtrcredit = 0;
 
+		spin_lock(&rxpeer->lpni_lock);
 		LASSERT((rxpeer->lpni_rtrcredits < 0) ==
 			!list_empty(&rxpeer->lpni_rtrq));
 
@@ -977,14 +992,19 @@ lnet_return_rx_credits_locked(struct lnet_msg *msg)
 		 * peer.
 		 */
 		if (!the_lnet.ln_routing) {
-			lnet_drop_routed_msgs_locked(&rxpeer->lpni_rtrq,
-						     msg->msg_rx_cpt);
+			LIST_HEAD(drop);
+
+			list_splice_init(&rxpeer->lpni_rtrq, &drop);
+			spin_unlock(&rxpeer->lpni_lock);
+			lnet_drop_routed_msgs_locked(&drop, msg->msg_rx_cpt);
 		} else if (rxpeer->lpni_rtrcredits <= 0) {
 			msg2 = list_entry(rxpeer->lpni_rtrq.next,
 					  struct lnet_msg, msg_list);
 			list_del(&msg2->msg_list);
-
+			spin_unlock(&rxpeer->lpni_lock);
 			(void)lnet_post_routed_recv_locked(msg2, 1);
+		} else {
+			spin_unlock(&rxpeer->lpni_lock);
 		}
 	}
 	if (rxni) {
diff --git a/drivers/staging/lustre/lnet/lnet/peer.c b/drivers/staging/lustre/lnet/lnet/peer.c
index dc4527f86113..3555e9bd1db1 100644
--- a/drivers/staging/lustre/lnet/lnet/peer.c
+++ b/drivers/staging/lustre/lnet/lnet/peer.c
@@ -56,12 +56,16 @@ lnet_peer_net_added(struct lnet_net *net)
 				 lpni_on_remote_peer_ni_list) {
 		if (LNET_NIDNET(lpni->lpni_nid) == net->net_id) {
 			lpni->lpni_net = net;
+
+			spin_lock(&lpni->lpni_lock);
 			lpni->lpni_txcredits =
-				lpni->lpni_mintxcredits =
 				lpni->lpni_net->net_tunables.lct_peer_tx_credits;
+			lpni->lpni_mintxcredits =
+				lpni->lpni_txcredits;
 			lpni->lpni_rtrcredits =
-				lpni->lpni_minrtrcredits =
 				lnet_peer_buffer_credits(lpni->lpni_net);
+			lpni->lpni_minrtrcredits = lpni->lpni_rtrcredits;
+			spin_unlock(&lpni->lpni_lock);
 
 			lnet_peer_remove_from_remote_list(lpni);
 		}
diff --git a/drivers/staging/lustre/lnet/lnet/router.c b/drivers/staging/lustre/lnet/lnet/router.c
index d3c41f5664a4..6c50e8cc7833 100644
--- a/drivers/staging/lustre/lnet/lnet/router.c
+++ b/drivers/staging/lustre/lnet/lnet/router.c
@@ -1358,7 +1358,8 @@ lnet_rtrpool_free_bufs(struct lnet_rtrbufpool *rbp, int cpt)
 	INIT_LIST_HEAD(&tmp);
 
 	lnet_net_lock(cpt);
-	lnet_drop_routed_msgs_locked(&rbp->rbp_msgs, cpt);
+	list_splice_init(&rbp->rbp_msgs, &tmp);
+	lnet_drop_routed_msgs_locked(&tmp, cpt);
 	list_splice_init(&rbp->rbp_bufs, &tmp);
 	rbp->rbp_req_nbuffers = 0;
 	rbp->rbp_nbuffers = 0;
