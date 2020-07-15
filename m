From: James Simmons <jsimmons@infradead.org>
Date: Wed, 15 Jul 2020 16:45:10 -0400
Subject: [lustre-devel] [PATCH 29/37] lnet: Allow router to forward to
 healthier NID
In-Reply-To: <1594845918-29027-1-git-send-email-jsimmons@infradead.org>
References: <1594845918-29027-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1594845918-29027-30-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Chris Horn <chris.horn@hpe.com>

When a final-hop router (aka edge router) is forwarding a message,
if both the originator and destination of the message are mutli-rail
capable, then allow the router to choose a new destination lpni if
the one selected by the message originator is unhealthy or down.

HPE-bug-id: LUS-8905
WC-bug-id: https://jira.whamcloud.com/browse/LU-13606
Lustre-commit: b0e8ab1a5f6f8 ("LU-13606 lnet: Allow router to forward to healthier NID")
Signed-off-by: Chris Horn <chris.horn@hpe.com>
Reviewed-on: https://review.whamcloud.com/38798
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/lib-lnet.h |  4 ++--
 net/lnet/lnet/lib-move.c      | 37 +++++++++++++++++++++++++++++++++++--
 2 files changed, 37 insertions(+), 4 deletions(-)

diff --git a/include/linux/lnet/lib-lnet.h b/include/linux/lnet/lib-lnet.h
index 75c0da7..b069422 100644
--- a/include/linux/lnet/lib-lnet.h
+++ b/include/linux/lnet/lib-lnet.h
@@ -819,8 +819,8 @@ int lnet_get_peer_ni_info(u32 peer_index, u64 *nid,
 }
 
 /*
- * A peer is alive if it satisfies the following two conditions:
- *  1. peer health >= LNET_MAX_HEALTH_VALUE * router_sensitivity_percentage
+ * A peer NI is alive if it satisfies the following two conditions:
+ *  1. peer NI health >= LNET_MAX_HEALTH_VALUE * router_sensitivity_percentage
  *  2. the cached NI status received when we discover the peer is UP
  */
 static inline bool
diff --git a/net/lnet/lnet/lib-move.c b/net/lnet/lnet/lib-move.c
index 2f3ef8c..234fbb5 100644
--- a/net/lnet/lnet/lib-move.c
+++ b/net/lnet/lnet/lib-move.c
@@ -2371,6 +2371,8 @@ struct lnet_ni *
 	int cpt, rc;
 	int md_cpt;
 	u32 send_case = 0;
+	bool final_hop;
+	bool mr_forwarding_allowed;
 
 	memset(&send_data, 0, sizeof(send_data));
 
@@ -2447,16 +2449,47 @@ struct lnet_ni *
 	else
 		send_case |= REMOTE_DST;
 
+	final_hop = false;
+	if (msg->msg_routing && (send_case & LOCAL_DST))
+		final_hop = true;
+
+	/* Determine whether to allow MR forwarding for this message.
+	 * NB: MR forwarding is allowed if the message originator and the
+	 * destination are both MR capable, and the destination lpni that was
+	 * originally chosen by the originator is unhealthy or down.
+	 * We check the MR capability of the destination further below
+	 */
+	mr_forwarding_allowed = false;
+	if (final_hop) {
+		struct lnet_peer *src_lp;
+		struct lnet_peer_ni *src_lpni;
+
+		src_lpni = lnet_nid2peerni_locked(msg->msg_hdr.src_nid,
+						  LNET_NID_ANY, cpt);
+		/* We don't fail the send if we hit any errors here. We'll just
+		 * try to send it via non-multi-rail criteria
+		 */
+		if (!IS_ERR(src_lpni)) {
+			src_lp = lpni->lpni_peer_net->lpn_peer;
+			if (lnet_peer_is_multi_rail(src_lp) &&
+			    !lnet_is_peer_ni_alive(lpni))
+				mr_forwarding_allowed = true;
+		}
+		CDEBUG(D_NET, "msg %p MR forwarding %s\n", msg,
+		       mr_forwarding_allowed ? "allowed" : "not allowed");
+	}
+
 	/* Deal with the peer as NMR in the following cases:
 	 * 1. the peer is NMR
 	 * 2. We're trying to recover a specific peer NI
-	 * 3. I'm a router sending to the final destination
+	 * 3. I'm a router sending to the final destination and MR forwarding is
+	 *    not allowed for this message (as determined above).
 	 *    In this case the source of the message would've
 	 *    already selected the final destination so my job
 	 *    is to honor the selection.
 	 */
 	if (!lnet_peer_is_multi_rail(peer) || msg->msg_recovery ||
-	    (msg->msg_routing && (send_case & LOCAL_DST)))
+	    (final_hop && !mr_forwarding_allowed))
 		send_case |= NMR_DST;
 	else
 		send_case |= MR_DST;
-- 
1.8.3.1
