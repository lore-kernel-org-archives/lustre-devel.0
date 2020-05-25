From: James Simmons <jsimmons@infradead.org>
Date: Mon, 25 May 2020 18:08:19 -0400
Subject: [lustre-devel] [PATCH 42/45] lnet: use the same src nid for
 discovery
In-Reply-To: <1590444502-20533-1-git-send-email-jsimmons@infradead.org>
References: <1590444502-20533-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1590444502-20533-43-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <ashehata@whamcloud.com>

When discovering a remote peer (not on the same network) a GET is
sent to the peer to retrieve the peer's interfaces.  This is followed
by a PUSH, if discovery is on, to push the node's interfaces However,
if both node and peer have multiple interfaces it is likely that the
GET and the PUSH will originate on different interfaces. When the
peer receives the PUSH it will not be able to connect the two NIDs
and will not be able to consolidate the node's NIDs.  This issue is
specific for remote peers because at the time the push handler is
invoked the remote lpni has not been created yet. lnet_parse()
creates the lpni of the gateway.

Similar to the strategy already in place of using the same source NID
for all the messages of an RPC, discovery should use the same source
NID for both the GET and PUSH.

This patch stores the source NID interfaces the GET was sent on and
uses it for the PUSH.

WC-bug-id: https://jira.whamcloud.com/browse/LU-13471
Lustre-commit: 71ca66bcd9c3a ("LU-13471 lnet: use the same src nid for discovery")
Signed-off-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/38320
Reviewed-by: Chris Horn <chris.horn@hpe.com>
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/lib-types.h |  3 +++
 net/lnet/lnet/peer.c           | 11 ++++++++++-
 2 files changed, 13 insertions(+), 1 deletion(-)

diff --git a/include/linux/lnet/lib-types.h b/include/linux/lnet/lib-types.h
index f78b372..6aa691e 100644
--- a/include/linux/lnet/lib-types.h
+++ b/include/linux/lnet/lib-types.h
@@ -578,6 +578,9 @@ struct lnet_peer {
 	/* primary NID of the peer */
 	lnet_nid_t		lp_primary_nid;
 
+	/* source NID to use during discovery */
+	lnet_nid_t		lp_disc_src_nid;
+
 	/* net to perform discovery on */
 	u32			lp_disc_net_id;
 
diff --git a/net/lnet/lnet/peer.c b/net/lnet/lnet/peer.c
index 1b9190b..ae70033 100644
--- a/net/lnet/lnet/peer.c
+++ b/net/lnet/lnet/peer.c
@@ -216,6 +216,7 @@
 	init_waitqueue_head(&lp->lp_dc_waitq);
 	spin_lock_init(&lp->lp_lock);
 	lp->lp_primary_nid = nid;
+	lp->lp_disc_src_nid = LNET_NID_ANY;
 	if (lnet_peers_start_down())
 		lp->lp_alive = false;
 	else
@@ -2271,6 +2272,8 @@ static void lnet_peer_clear_discovery_error(struct lnet_peer *lp)
 
 	spin_lock(&lp->lp_lock);
 
+	lp->lp_disc_src_nid = ev->target.nid;
+
 	/*
 	 * If some kind of error happened the contents of message
 	 * cannot be used. Set PING_FAILED to trigger a retry.
@@ -3088,9 +3091,15 @@ static int lnet_peer_send_push(struct lnet_peer *lp)
 		goto fail_unlink;
 	}
 
-	rc = LNetPut(LNET_NID_ANY, lp->lp_push_mdh,
+	rc = LNetPut(lp->lp_disc_src_nid, lp->lp_push_mdh,
 		     LNET_ACK_REQ, id, LNET_RESERVED_PORTAL,
 		     LNET_PROTO_PING_MATCHBITS, 0, 0);
+	/* reset the discovery nid. There is no need to restrict sending
+	 * from that source, if we call lnet_push_update_to_peers(). It'll
+	 * get set to a specific NID, if we initiate discovery from the
+	 * scratch
+	 */
+	lp->lp_disc_src_nid = LNET_NID_ANY;
 	if (rc)
 		goto fail_unlink;
 
-- 
1.8.3.1
