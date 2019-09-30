From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Sep 2019 14:54:58 -0400
Subject: [lustre-devel] [PATCH 039/151] lnet: don't discover loopback
 interface
In-Reply-To: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1569869810-23848-40-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <ashehata@whamcloud.com>

Whenever we send messages destined to the loopback interface
it should always go over the loopback interface. To achieve that
there is no real need to initiate discovery on the loopback.
This will result in a non-mr peer created for the loopback,
Which makes sense because if we are to send messages to
ourselves we do not want to use the different interfaces
rather just keep sending over the lolnd. In effect this
is a special case where we want to behave as a non-mr
node.

When sending a message destined for the loopback interface
there is no need to go through the selection process, it
is sufficient to shortcut all the MR logic and send directly
over the lolnd.

WC-bug-id: https://jira.whamcloud.com/browse/LU-9992
Lustre-commit: de823879c43d ("LU-9992 lnet: don't discover loopback interface")
Signed-off-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/29007
Reviewed-by: Sonia Sharma <sharmaso@whamcloud.com>
Reviewed-by: Olaf Weber <olaf.weber@hpe.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/lib-move.c | 11 +++++++++++
 net/lnet/lnet/peer.c     |  9 +++++++++
 2 files changed, 20 insertions(+)

diff --git a/net/lnet/lnet/lib-move.c b/net/lnet/lnet/lib-move.c
index 875d289..6f3e941 100644
--- a/net/lnet/lnet/lib-move.c
+++ b/net/lnet/lnet/lib-move.c
@@ -1391,6 +1391,17 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 		lnet_net_unlock(cpt);
 		return PTR_ERR(lpni);
 	}
+
+	/* If we're being asked to send to the loopback interface, there
+	 * is no need to go through any selection. We can just shortcut
+	 * the entire process and send over lolnd
+	 */
+	if (LNET_NETTYP(LNET_NIDNET(dst_nid)) == LOLND) {
+		lnet_peer_ni_decref_locked(lpni);
+		best_ni = the_lnet.ln_loni;
+		goto send;
+	}
+
 	/*
 	 * Now that we have a peer_ni, check if we want to discover
 	 * the peer. Traffic to the LNET_RESERVED_PORTAL should not
diff --git a/net/lnet/lnet/peer.c b/net/lnet/lnet/peer.c
index 9fdb6a9..1266e32 100644
--- a/net/lnet/lnet/peer.c
+++ b/net/lnet/lnet/peer.c
@@ -211,6 +211,15 @@
 	init_waitqueue_head(&lp->lp_dc_waitq);
 	spin_lock_init(&lp->lp_lock);
 	lp->lp_primary_nid = nid;
+
+	/* Turn off discovery for loopback peer. If you're creating a peer
+	 * for the loopback interface then that was initiated when we
+	 * attempted to send a message over the loopback. There is no need
+	 * to ever use a different interface when sending messages to
+	 * myself.
+	 */
+	if (LNET_NETTYP(LNET_NIDNET(nid)) == LOLND)
+		lp->lp_state = LNET_PEER_NO_DISCOVERY;
 	lp->lp_cpt = lnet_nid_cpt_hash(nid, LNET_CPT_NUMBER);
 
 	CDEBUG(D_NET, "%p nid %s\n", lp, libcfs_nid2str(lp->lp_primary_nid));
-- 
1.8.3.1
