From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:13:24 -0500
Subject: [lustre-devel] [PATCH 336/622] lnet: Cache the routing feature
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-337-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <ashehata@whamcloud.com>

When processing a REPLY or a PUSH for a discovery cache the
whether the routing feature is enabled or disabled as
reported by the peer.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11300
Lustre-commit: d65a7b8727ee ("LU-11300 lnet: Cache the routing feature")
Signed-off-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/33451
Reviewed-by: Chris Horn <hornc@cray.com>
Reviewed-by: Olaf Weber <olaf.weber@hpe.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/lib-types.h | 28 ++++++++++++++++------------
 net/lnet/lnet/peer.c           | 10 ++++++++++
 2 files changed, 26 insertions(+), 12 deletions(-)

diff --git a/include/linux/lnet/lib-types.h b/include/linux/lnet/lib-types.h
index a551005..ecc6dee 100644
--- a/include/linux/lnet/lib-types.h
+++ b/include/linux/lnet/lib-types.h
@@ -705,9 +705,13 @@ struct lnet_peer {
  *
  * A peer is marked NO_DISCOVERY if the LNET_PING_FEAT_DISCOVERY bit was
  * NOT set when the peer was pinged by discovery.
+ *
+ * A peer is marked ROUTER if it indicates so in the feature bit.
  */
 #define LNET_PEER_MULTI_RAIL	BIT(0)	/* Multi-rail aware */
 #define LNET_PEER_NO_DISCOVERY	BIT(1)	/* Peer disabled discovery */
+#define LNET_PEER_ROUTER_ENABLED BIT(2)	/* router feature enabled */
+
 /*
  * A peer is marked CONFIGURED if it was configured by DLC.
  *
@@ -721,28 +725,28 @@ struct lnet_peer {
  * A peer that was created as the result of inbound traffic will not
  * be marked at all.
  */
-#define LNET_PEER_CONFIGURED	BIT(2)	/* Configured via DLC */
-#define LNET_PEER_DISCOVERED	BIT(3)	/* Peer was discovered */
-#define LNET_PEER_REDISCOVER	BIT(4)	/* Discovery was disabled */
+#define LNET_PEER_CONFIGURED	BIT(3)	/* Configured via DLC */
+#define LNET_PEER_DISCOVERED	BIT(4)	/* Peer was discovered */
+#define LNET_PEER_REDISCOVER	BIT(5)	/* Discovery was disabled */
 /*
  * A peer is marked DISCOVERING when discovery is in progress.
  * The other flags below correspond to stages of discovery.
  */
-#define LNET_PEER_DISCOVERING	BIT(5)	/* Discovering */
-#define LNET_PEER_DATA_PRESENT	BIT(6)	/* Remote peer data present */
-#define LNET_PEER_NIDS_UPTODATE	BIT(7)	/* Remote peer info uptodate */
-#define LNET_PEER_PING_SENT	BIT(8)	/* Waiting for REPLY to Ping */
-#define LNET_PEER_PUSH_SENT	BIT(9)	/* Waiting for ACK of Push */
-#define LNET_PEER_PING_FAILED	BIT(10)	/* Ping send failure */
-#define LNET_PEER_PUSH_FAILED	BIT(11)	/* Push send failure */
+#define LNET_PEER_DISCOVERING	BIT(6)	/* Discovering */
+#define LNET_PEER_DATA_PRESENT	BIT(7)	/* Remote peer data present */
+#define LNET_PEER_NIDS_UPTODATE	BIT(8)	/* Remote peer info uptodate */
+#define LNET_PEER_PING_SENT	BIT(9)	/* Waiting for REPLY to Ping */
+#define LNET_PEER_PUSH_SENT	BIT(10)	/* Waiting for ACK of Push */
+#define LNET_PEER_PING_FAILED	BIT(11)	/* Ping send failure */
+#define LNET_PEER_PUSH_FAILED	BIT(12)	/* Push send failure */
 /*
  * A ping can be forced as a way to fix up state, or as a manual
  * intervention by an admin.
  * A push can be forced in circumstances that would normally not
  * allow for one to happen.
  */
-#define LNET_PEER_FORCE_PING	BIT(12)	/* Forced Ping */
-#define LNET_PEER_FORCE_PUSH	BIT(13)	/* Forced Push */
+#define LNET_PEER_FORCE_PING	BIT(13)	/* Forced Ping */
+#define LNET_PEER_FORCE_PUSH	BIT(14)	/* Forced Push */
 
 struct lnet_peer_net {
 	/* chain on lp_peer_nets */
diff --git a/net/lnet/lnet/peer.c b/net/lnet/lnet/peer.c
index cba3da2..91ad6b4 100644
--- a/net/lnet/lnet/peer.c
+++ b/net/lnet/lnet/peer.c
@@ -2427,6 +2427,16 @@ static int lnet_peer_merge_data(struct lnet_peer *lp,
 	if (pbuf->pb_info.pi_features & LNET_PING_FEAT_MULTI_RAIL)
 		flags |= LNET_PEER_MULTI_RAIL;
 
+	/* Cache the routing feature for the peer; whether it is enabled
+	 * for disabled as reported by the remote peer.
+	 */
+	spin_lock(&lp->lp_lock);
+	if (!(pbuf->pb_info.pi_features & LNET_PING_FEAT_RTE_DISABLED))
+		lp->lp_state |= LNET_PEER_ROUTER_ENABLED;
+	else
+		lp->lp_state &= ~LNET_PEER_ROUTER_ENABLED;
+	spin_unlock(&lp->lp_lock);
+
 	nnis = max_t(int, lp->lp_nnis, pbuf->pb_info.pi_nnis);
 	curnis = kmalloc_array(nnis, sizeof(*curnis), GFP_NOFS);
 	addnis = kmalloc_array(nnis, sizeof(*addnis), GFP_NOFS);
-- 
1.8.3.1
