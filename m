From: James Simmons <jsimmons@infradead.org>
Date: Fri, 12 Feb 2016 12:06:02 -0500
Subject: [lustre-devel] [PATCH 04/11] staging: lustre: remove unnecessary
	parentheses around LNet function pointer
In-Reply-To: <1455296769-5481-1-git-send-email-jsimmons@infradead.org>
References: <1455296769-5481-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1455296769-5481-5-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Dorkin <oleg.dorkin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

No need for the parentheses around any function pointer.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c |    2 +-
 drivers/staging/lustre/lnet/lnet/api-ni.c          |    4 ++--
 drivers/staging/lustre/lnet/lnet/lib-move.c        |   12 ++++++------
 drivers/staging/lustre/lnet/lnet/router.c          |    4 ++--
 4 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
index fbcbb97..cbf5d0a 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -2185,7 +2185,7 @@ kiblnd_passive_connect(struct rdma_cm_id *cmid, void *priv, int priv_nob)
 	rej.ibr_why = IBLND_REJECT_FATAL;
 	rej.ibr_cp.ibcp_max_msg_size = IBLND_MSG_SIZE;
 
-	peer_addr = (struct sockaddr_in *)&(cmid->route.addr.dst_addr);
+	peer_addr = (struct sockaddr_in *)&cmid->route.addr.dst_addr;
 	if (*kiblnd_tunables.kib_require_priv_port &&
 	    ntohs(peer_addr->sin_port) >= PROT_SOCK) {
 		__u32 ip = ntohl(peer_addr->sin_addr.s_addr);
diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
index aeef480..e59fbfb 100644
--- a/drivers/staging/lustre/lnet/lnet/api-ni.c
+++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
@@ -935,7 +935,7 @@ lnet_shutdown_lndnis(void)
 		islo = ni->ni_lnd->lnd_type == LOLND;
 
 		LASSERT(!in_interrupt());
-		(ni->ni_lnd->lnd_shutdown)(ni);
+		ni->ni_lnd->lnd_shutdown(ni);
 
 		/*
 		 * can't deref lnd anymore now; it might have unregistered
@@ -1023,7 +1023,7 @@ lnet_startup_lndnis(void)
 
 		ni->ni_lnd = lnd;
 
-		rc = (lnd->lnd_startup)(ni);
+		rc = lnd->lnd_startup(ni);
 
 		mutex_unlock(&the_lnet.ln_lnd_mutex);
 
diff --git a/drivers/staging/lustre/lnet/lnet/lib-move.c b/drivers/staging/lustre/lnet/lnet/lib-move.c
index 7e1ef18..afc4522 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-move.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-move.c
@@ -599,8 +599,8 @@ lnet_ni_recv(lnet_ni_t *ni, void *private, lnet_msg_t *msg, int delayed,
 		}
 	}
 
-	rc = (ni->ni_lnd->lnd_recv)(ni, private, msg, delayed,
-				    niov, iov, kiov, offset, mlen, rlen);
+	rc = ni->ni_lnd->lnd_recv(ni, private, msg, delayed,
+				  niov, iov, kiov, offset, mlen, rlen);
 	if (rc < 0)
 		lnet_finalize(ni, msg, rc);
 }
@@ -655,7 +655,7 @@ lnet_ni_send(lnet_ni_t *ni, lnet_msg_t *msg)
 	LASSERT(LNET_NETTYP(LNET_NIDNET(ni->ni_nid)) == LOLND ||
 		(msg->msg_txcredit && msg->msg_peertxcredit));
 
-	rc = (ni->ni_lnd->lnd_send)(ni, priv, msg);
+	rc = ni->ni_lnd->lnd_send(ni, priv, msg);
 	if (rc < 0)
 		lnet_finalize(ni, msg, rc);
 }
@@ -671,8 +671,8 @@ lnet_ni_eager_recv(lnet_ni_t *ni, lnet_msg_t *msg)
 	LASSERT(ni->ni_lnd->lnd_eager_recv != NULL);
 
 	msg->msg_rx_ready_delay = 1;
-	rc = (ni->ni_lnd->lnd_eager_recv)(ni, msg->msg_private, msg,
-					  &msg->msg_private);
+	rc = ni->ni_lnd->lnd_eager_recv(ni, msg->msg_private, msg,
+					&msg->msg_private);
 	if (rc != 0) {
 		CERROR("recv from %s / send to %s aborted: eager_recv failed %d\n",
 		       libcfs_nid2str(msg->msg_rxpeer->lp_nid),
@@ -693,7 +693,7 @@ lnet_ni_query_locked(lnet_ni_t *ni, lnet_peer_t *lp)
 	LASSERT(ni->ni_lnd->lnd_query != NULL);
 
 	lnet_net_unlock(lp->lp_cpt);
-	(ni->ni_lnd->lnd_query)(ni, lp->lp_nid, &last_alive);
+	ni->ni_lnd->lnd_query(ni, lp->lp_nid, &last_alive);
 	lnet_net_lock(lp->lp_cpt);
 
 	lp->lp_last_query = cfs_time_current();
diff --git a/drivers/staging/lustre/lnet/lnet/router.c b/drivers/staging/lustre/lnet/lnet/router.c
index 754f7f0..e447b1a 100644
--- a/drivers/staging/lustre/lnet/lnet/router.c
+++ b/drivers/staging/lustre/lnet/lnet/router.c
@@ -157,7 +157,7 @@ lnet_ni_notify_locked(lnet_ni_t *ni, lnet_peer_t *lp)
 			 * A new notification could happen now; I'll handle it
 			 * when control returns to me
 			 */
-			(ni->ni_lnd->lnd_notify)(ni, lp->lp_nid, alive);
+			ni->ni_lnd->lnd_notify(ni, lp->lp_nid, alive);
 
 			lnet_net_lock(lp->lp_cpt);
 		}
@@ -389,7 +389,7 @@ lnet_add_route(__u32 net, unsigned int hops, lnet_nid_t gateway,
 
 		/* XXX Assume alive */
 		if (ni->ni_lnd->lnd_notify != NULL)
-			(ni->ni_lnd->lnd_notify)(ni, gateway, 1);
+			ni->ni_lnd->lnd_notify(ni, gateway, 1);
 
 		lnet_net_lock(LNET_LOCK_EX);
 	}
-- 
1.7.1
