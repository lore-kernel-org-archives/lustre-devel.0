Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id EC833C433EF
	for <lustre-devel@archiver.kernel.org>; Wed, 29 Dec 2021 14:51:53 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id AB4DF3AD5A8;
	Wed, 29 Dec 2021 06:51:48 -0800 (PST)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 3EDF73AD50F
 for <lustre-devel@lists.lustre.org>; Wed, 29 Dec 2021 06:51:33 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id A200C1006F15;
 Wed, 29 Dec 2021 09:51:28 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 9EC53D9E6B; Wed, 29 Dec 2021 09:51:28 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Wed, 29 Dec 2021 09:51:25 -0500
Message-Id: <1640789487-22279-12-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1640789487-22279-1-git-send-email-jsimmons@infradead.org>
References: <1640789487-22279-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 11/13] lnet: Race on discovery queue
X-BeenThere: lustre-devel@lists.lustre.org
X-Mailman-Version: 2.1.23
Precedence: list
List-Id: "For discussing Lustre software development."
 <lustre-devel-lustre.org>
List-Unsubscribe: <http://lists.lustre.org/options.cgi/lustre-devel-lustre.org>, 
 <mailto:lustre-devel-request@lists.lustre.org?subject=unsubscribe>
List-Archive: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/>
List-Post: <mailto:lustre-devel@lists.lustre.org>
List-Help: <mailto:lustre-devel-request@lists.lustre.org?subject=help>
List-Subscribe: <http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org>, 
 <mailto:lustre-devel-request@lists.lustre.org?subject=subscribe>
Cc: Chris Horn <chris.horn@hpe.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Chris Horn <chris.horn@hpe.com>

If the discovery thread clears the LNET_PEER_DISCOVERING bit then a
race window opens when the discovery thread drops the
lnet_peer.lp_lock spinlock and closes when the discovery thread
acquires the lnet_net_lock. If another thread queues the peer for
discovery during this window then the LNET_PEER_DISCOVERING bit is
added back to the peer state, but since the peer is already on the
lnet.ln_dc_working queue, it does not get added to the
lnet.ln_dc_request queue.

When the discovery thread acquires the lnet_net_lock/EX, it sees that
the LNET_PEER_DISCOVERING bit has not been cleared, so it does not
call lnet_peer_discovery_complete() which is responsible for sending
messages on the peer's discovery pending queue.

At this point, the peer is stuck on the lnet.ln_dc_working queue, and
messages may continue to accumulate on the peer's
lnet_peer.lp_dc_pendq.

Fix the issue by re-working the main discovery thread loop so that we
do not release the lnet_peer.lp_lock until after we've determined
whether we need to call lnet_peer_discovery_complete().
This ensures that the lnet_peer is correctly removed from the
discovery work queue and any messages on the peer's
lnet_peer.lp_dc_pendq are sent or finalized.

It is also possible for the lnet_peer.lp_dc_error to be cleared
during the aforementioned window, as well as during the time when
lnet_peer_discovery_complete() is processing the contents of the
lnet_peer.lp_dc_pendq. This could prevent messages on the
lnet_peer.lp_dc_pendq from being correctly finalized. To fix this
issue, the responsibilities of lnet_peer_discovery_error() were
incorporated into lnet_peer_discovery_complete().

HPE-bug-id: LUS-10615
WC-bug-id: https://jira.whamcloud.com/browse/LU-15234
Lustre-commit: 852a4b264a984979d ("LU-15234 lnet: Race on discovery queue")
Signed-off-by: Chris Horn <chris.horn@hpe.com>
Reviewed-on: https://review.whamcloud.com/45670
Reviewed-by: Alexey Lyashkov <alexey.lyashkov@hpe.com>
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: Olaf Weber <olaf.weber@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/peer.c | 47 ++++++++++++++++++++---------------------------
 1 file changed, 20 insertions(+), 27 deletions(-)

diff --git a/net/lnet/lnet/peer.c b/net/lnet/lnet/peer.c
index cca458f..057a1db 100644
--- a/net/lnet/lnet/peer.c
+++ b/net/lnet/lnet/peer.c
@@ -2262,7 +2262,7 @@ static int lnet_peer_queue_for_discovery(struct lnet_peer *lp)
  * Discovery of a peer is complete. Wake all waiters on the peer.
  * Call with lnet_net_lock/EX held.
  */
-static void lnet_peer_discovery_complete(struct lnet_peer *lp)
+static void lnet_peer_discovery_complete(struct lnet_peer *lp, int dc_error)
 {
 	struct lnet_msg *msg, *tmp;
 	int rc = 0;
@@ -2273,6 +2273,11 @@ static void lnet_peer_discovery_complete(struct lnet_peer *lp)
 
 	list_del_init(&lp->lp_dc_list);
 	spin_lock(&lp->lp_lock);
+	if (dc_error) {
+		lp->lp_dc_error = dc_error;
+		lp->lp_state &= ~LNET_PEER_DISCOVERING;
+		lp->lp_state |= LNET_PEER_REDISCOVER;
+	}
 	list_splice_init(&lp->lp_dc_pendq, &pending_msgs);
 	spin_unlock(&lp->lp_lock);
 	wake_up(&lp->lp_dc_waitq);
@@ -2285,8 +2290,8 @@ static void lnet_peer_discovery_complete(struct lnet_peer *lp)
 	/* iterate through all pending messages and send them again */
 	list_for_each_entry_safe(msg, tmp, &pending_msgs, msg_list) {
 		list_del_init(&msg->msg_list);
-		if (lp->lp_dc_error) {
-			lnet_finalize(msg, lp->lp_dc_error);
+		if (dc_error) {
+			lnet_finalize(msg, dc_error);
 			continue;
 		}
 
@@ -3619,22 +3624,6 @@ static int lnet_peer_send_push(struct lnet_peer *lp)
 }
 
 /*
- * An unrecoverable error was encountered during discovery.
- * Set error status in peer and abort discovery.
- */
-static void lnet_peer_discovery_error(struct lnet_peer *lp, int error)
-{
-	CDEBUG(D_NET, "Discovery error %s: %d\n",
-	       libcfs_nidstr(&lp->lp_primary_nid), error);
-
-	spin_lock(&lp->lp_lock);
-	lp->lp_dc_error = error;
-	lp->lp_state &= ~LNET_PEER_DISCOVERING;
-	lp->lp_state |= LNET_PEER_REDISCOVER;
-	spin_unlock(&lp->lp_lock);
-}
-
-/*
  * Wait for work to be queued or some other change that must be
  * attended to. Returns non-zero if the discovery thread should shut
  * down.
@@ -3810,17 +3799,22 @@ static int lnet_peer_discovery(void *arg)
 			CDEBUG(D_NET, "peer %s(%p) state %#x rc %d\n",
 			       libcfs_nidstr(&lp->lp_primary_nid), lp,
 			       lp->lp_state, rc);
-			spin_unlock(&lp->lp_lock);
 
-			lnet_net_lock(LNET_LOCK_EX);
 			if (rc == LNET_REDISCOVER_PEER) {
+				spin_unlock(&lp->lp_lock);
+				lnet_net_lock(LNET_LOCK_EX);
 				list_move(&lp->lp_dc_list,
 					  &the_lnet.ln_dc_request);
-			} else if (rc) {
-				lnet_peer_discovery_error(lp, rc);
+			} else if (rc ||
+				   !(lp->lp_state & LNET_PEER_DISCOVERING)) {
+				spin_unlock(&lp->lp_lock);
+				lnet_net_lock(LNET_LOCK_EX);
+				lnet_peer_discovery_complete(lp, rc);
+			} else {
+				spin_unlock(&lp->lp_lock);
+				lnet_net_lock(LNET_LOCK_EX);
 			}
-			if (!(lp->lp_state & LNET_PEER_DISCOVERING))
-				lnet_peer_discovery_complete(lp);
+
 			if (the_lnet.ln_dc_state == LNET_DC_STATE_STOPPING)
 				break;
 		}
@@ -3857,8 +3851,7 @@ static int lnet_peer_discovery(void *arg)
 	while (!list_empty(&the_lnet.ln_dc_request)) {
 		lp = list_first_entry(&the_lnet.ln_dc_request,
 				      struct lnet_peer, lp_dc_list);
-		lnet_peer_discovery_error(lp, -ESHUTDOWN);
-		lnet_peer_discovery_complete(lp);
+		lnet_peer_discovery_complete(lp, -ESHUTDOWN);
 	}
 	lnet_net_unlock(LNET_LOCK_EX);
 
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
