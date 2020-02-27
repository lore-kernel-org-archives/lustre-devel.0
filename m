From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:13:36 -0500
Subject: [lustre-devel] [PATCH 348/622] lnet: misleading discovery seqno.
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-349-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <ashehata@whamcloud.com>

There is a sequence number used when sending discovery messages. This
sequence number is intended to detect stale messages. However it
could be misleading if the peer reboots. In this case the peer's
sequence number will reset. The node will think that all information
being sent to it is stale, while in reality the peer might've
changed configuration.

There is no reliable why to know whether a peer rebooted, so we'll
always assume that the messages we're receiving are valid. So we'll
operate on first come first serve basis.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11478
Lustre-commit: 42d999ed8f61 ("LU-11478 lnet: misleading discovery seqno.")
Signed-off-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/33304
Reviewed-by: Olaf Weber <olaf.weber@hpe.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/peer.c | 45 +++++++--------------------------------------
 1 file changed, 7 insertions(+), 38 deletions(-)

diff --git a/net/lnet/lnet/peer.c b/net/lnet/lnet/peer.c
index 5d13986..2097a97 100644
--- a/net/lnet/lnet/peer.c
+++ b/net/lnet/lnet/peer.c
@@ -1987,38 +1987,9 @@ void lnet_peer_push_event(struct lnet_event *ev)
 		goto out;
 	}
 
-	/*
-	 * Check whether the Put data is stale. Stale data can just be
-	 * dropped.
-	 */
-	if (pbuf->pb_info.pi_nnis > 1 &&
-	    lp->lp_primary_nid == pbuf->pb_info.pi_ni[1].ns_nid &&
-	    LNET_PING_BUFFER_SEQNO(pbuf) < lp->lp_peer_seqno) {
-		CDEBUG(D_NET, "Stale Push from %s: got %u have %u\n",
-		       libcfs_nid2str(lp->lp_primary_nid),
-		       LNET_PING_BUFFER_SEQNO(pbuf),
-		       lp->lp_peer_seqno);
-		goto out;
-	}
-
-	/*
-	 * Check whether the Put data is new, in which case we clear
-	 * the UPTODATE flag and prepare to process it.
-	 *
-	 * If the Put data is current, and the peer is UPTODATE then
-	 * we assome everything is all right and drop the data as
-	 * stale.
-	 */
-	if (LNET_PING_BUFFER_SEQNO(pbuf) > lp->lp_peer_seqno) {
-		lp->lp_peer_seqno = LNET_PING_BUFFER_SEQNO(pbuf);
-		lp->lp_state &= ~LNET_PEER_NIDS_UPTODATE;
-	} else if (lp->lp_state & LNET_PEER_NIDS_UPTODATE) {
-		CDEBUG(D_NET, "Stale Push from %s: got %u have %u\n",
-		       libcfs_nid2str(lp->lp_primary_nid),
-		       LNET_PING_BUFFER_SEQNO(pbuf),
-		       lp->lp_peer_seqno);
-		goto out;
-	}
+	/* always assume new data */
+	lp->lp_peer_seqno = LNET_PING_BUFFER_SEQNO(pbuf);
+	lp->lp_state &= ~LNET_PEER_NIDS_UPTODATE;
 
 	/*
 	 * If there is data present that hasn't been processed yet,
@@ -2302,16 +2273,14 @@ static void lnet_peer_clear_discovery_error(struct lnet_peer *lp)
 	if (pbuf->pb_info.pi_features & LNET_PING_FEAT_MULTI_RAIL &&
 	    pbuf->pb_info.pi_nnis > 1 &&
 	    lp->lp_primary_nid == pbuf->pb_info.pi_ni[1].ns_nid) {
-		if (LNET_PING_BUFFER_SEQNO(pbuf) < lp->lp_peer_seqno) {
-			CDEBUG(D_NET, "Stale Reply from %s: got %u have %u\n",
+		if (LNET_PING_BUFFER_SEQNO(pbuf) < lp->lp_peer_seqno)
+			CDEBUG(D_NET,
+			       "peer %s: seq# got %u have %u. peer rebooted?\n",
 			       libcfs_nid2str(lp->lp_primary_nid),
 			       LNET_PING_BUFFER_SEQNO(pbuf),
 			       lp->lp_peer_seqno);
-			goto out;
-		}
 
-		if (LNET_PING_BUFFER_SEQNO(pbuf) > lp->lp_peer_seqno)
-			lp->lp_peer_seqno = LNET_PING_BUFFER_SEQNO(pbuf);
+		lp->lp_peer_seqno = LNET_PING_BUFFER_SEQNO(pbuf);
 	}
 
 	/* We're happy with the state of the data in the buffer. */
-- 
1.8.3.1
