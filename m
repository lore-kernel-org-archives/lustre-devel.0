Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 55A68FA3740
	for <lustre-devel@archiver.kernel.org>; Thu, 27 Oct 2022 14:21:10 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4Mynd35h9wz21Jx;
	Thu, 27 Oct 2022 07:10:15 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4MyncZ1Rh7z21JZ
 for <lustre-devel@lists.lustre.org>; Thu, 27 Oct 2022 07:09:49 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 8451E1009102;
 Thu, 27 Oct 2022 10:05:44 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 80969FD4E9; Thu, 27 Oct 2022 10:05:44 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Thu, 27 Oct 2022 10:05:36 -0400
Message-Id: <1666879542-10737-10-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1666879542-10737-1-git-send-email-jsimmons@infradead.org>
References: <1666879542-10737-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 09/15] lnet: Discovery queue and deletion race
X-BeenThere: lustre-devel@lists.lustre.org
X-Mailman-Version: 2.1.39
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

lnet_peer_deletion() can race with another thread calling
lnet_peer_queue_for_discovery.

Discovery thread:
  - Calls lnet_peer_deletion():
  - LNET_PEER_DISCOVERING bit is cleared from lnet_peer::lp_state
  - releases lnet_peer::lp_lock

Another thread:
  - Acquires lnet_net_lock/EX
  - Calls lnet_peer_queue_for_discovery()
  - Takes lnet_peer::lp_lock
  - Sets LNET_PEER_DISCOVERING bit
  - Releases lnet_peer::lp_lock
  - Sees lnet_peer::lp_dc_list is not empty, so it does not add peer
    to dc request queue
  - lnet_peer_queue_for_discovery() returns, lnet_net_lock/EX releases

Discovery thread:
  - Acquires lnet_net_lock/EX
  - Deletes peer from ln_dc_working list
  - performs the peer deletion

At this point, the peer is not on any discovery list, and it has
LNET_PEER_DISCOVERING bit set. This peer is now stranded, and any
messages on the peer's lnet_peer::lp_dc_pendq are likewise stranded.

To solve this, we modify lnet_peer_deletion() so that it waits to
clear the LNET_PEER_DISCOVERING bit until it has completed deleting
the peer and re-acquired the lnet_peer::lp_lock. This ensures we
cannot race with any other thread that may add the
LNET_PEER_DISCOVERING bit back to the peer. We also avoid deleting
the peer from the ln_dc_working list in lnet_peer_deletion(). This is
already done by lnet_peer_discovery_complete().

There is another window where the LNET_PEER_DISCOVERING bit can be
added when the discovery thread drops the lp_lock just before
acquiring the net_lock/EX and calling lnet_peer_discovery_complete().
Have lnet_peer_discovery_complete() clear LNET_PEER_DISCOVERING to
deal with this (it already does this for the case where discovery hit
an error). Also move the deletion of lp_dc_list to after we clear the
DISCOVERING bit. This is to mirror the behavior of
lnet_peer_queue_for_discovery() which sets the DISCOVERING bit and
then manipulates the lp_dc_list.

Also tweak the logic in lnet_peer_deletion() to call
lnet_peer_del_locked() in order to avoid extra calls to
lnet_net_lock()/lnet_net_unlock().

HPE-bug-id: LUS-11237
WC-bug-id: https://jira.whamcloud.com/browse/LU-16149
Lustre-commit: a966b624ac76e34e8 ("LU-16149 lnet: Discovery queue and deletion race")
Signed-off-by: Chris Horn <chris.horn@hpe.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/48532
Reviewed-by: Frank Sehr <fsehr@whamcloud.com>
Reviewed-by: Cyril Bordage <cbordage@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/peer.c | 39 ++++++++++++++++++++++-----------------
 1 file changed, 22 insertions(+), 17 deletions(-)

diff --git a/net/lnet/lnet/peer.c b/net/lnet/lnet/peer.c
index 9b20660..d8d1857 100644
--- a/net/lnet/lnet/peer.c
+++ b/net/lnet/lnet/peer.c
@@ -2206,15 +2206,19 @@ static void lnet_peer_discovery_complete(struct lnet_peer *lp, int dc_error)
 	CDEBUG(D_NET, "Discovery complete. Dequeue peer %s\n",
 	       libcfs_nidstr(&lp->lp_primary_nid));
 
-	list_del_init(&lp->lp_dc_list);
 	spin_lock(&lp->lp_lock);
+	/* Our caller dropped lp_lock which may have allowed another thread to
+	 * set LNET_PEER_DISCOVERING, or it may be set if dc_error is non-zero.
+	 * Ensure it is cleared.
+	 */
+	lp->lp_state &= ~LNET_PEER_DISCOVERING;
 	if (dc_error) {
 		lp->lp_dc_error = dc_error;
-		lp->lp_state &= ~LNET_PEER_DISCOVERING;
 		lp->lp_state |= LNET_PEER_REDISCOVER;
 	}
 	list_splice_init(&lp->lp_dc_pendq, &pending_msgs);
 	spin_unlock(&lp->lp_lock);
+	list_del_init(&lp->lp_dc_list);
 	wake_up(&lp->lp_dc_waitq);
 
 	if (lp->lp_rtr_refcount > 0)
@@ -3152,18 +3156,16 @@ static int lnet_peer_deletion(struct lnet_peer *lp)
 	struct list_head rlist;
 	struct lnet_route *route, *tmp;
 	int sensitivity = lp->lp_health_sensitivity;
-	int rc;
+	int rc = 0;
 
 	INIT_LIST_HEAD(&rlist);
 
-	lp->lp_state &= ~(LNET_PEER_DISCOVERING | LNET_PEER_FORCE_PING |
-			  LNET_PEER_FORCE_PUSH);
 	CDEBUG(D_NET, "peer %s(%p) state %#x\n",
 	       libcfs_nidstr(&lp->lp_primary_nid), lp, lp->lp_state);
 
 	/* no-op if lnet_peer_del() has already been called on this peer */
 	if (lp->lp_state & LNET_PEER_MARK_DELETED)
-		return 0;
+		goto clear_discovering;
 
 	spin_unlock(&lp->lp_lock);
 
@@ -3172,28 +3174,25 @@ static int lnet_peer_deletion(struct lnet_peer *lp)
 	    the_lnet.ln_dc_state != LNET_DC_STATE_RUNNING) {
 		mutex_unlock(&the_lnet.ln_api_mutex);
 		spin_lock(&lp->lp_lock);
-		return -ESHUTDOWN;
+		rc = -ESHUTDOWN;
+		goto clear_discovering;
 	}
 
+	lnet_peer_cancel_discovery(lp);
 	lnet_net_lock(LNET_LOCK_EX);
-	/* remove the peer from the discovery work
-	 * queue if it's on there in preparation
-	 * of deleting it.
-	 */
-	if (!list_empty(&lp->lp_dc_list))
-		list_del_init(&lp->lp_dc_list);
 	list_for_each_entry_safe(route, tmp,
 				 &lp->lp_routes,
 				 lr_gwlist)
 		lnet_move_route(route, NULL, &rlist);
-	lnet_net_unlock(LNET_LOCK_EX);
 
-	/* lnet_peer_del() deletes all the peer NIs owned by this peer */
-	rc = lnet_peer_del(lp);
+	/* lnet_peer_del_locked() deletes all the peer NIs owned by this peer */
+	rc = lnet_peer_del_locked(lp);
 	if (rc)
 		CNETERR("Internal error: Unable to delete peer %s rc %d\n",
 			libcfs_nidstr(&lp->lp_primary_nid), rc);
 
+	lnet_net_unlock(LNET_LOCK_EX);
+
 	list_for_each_entry_safe(route, tmp,
 				 &rlist, lr_list) {
 		/* re-add these routes */
@@ -3209,7 +3208,13 @@ static int lnet_peer_deletion(struct lnet_peer *lp)
 
 	spin_lock(&lp->lp_lock);
 
-	return 0;
+	rc = 0;
+
+clear_discovering:
+	lp->lp_state &= ~(LNET_PEER_DISCOVERING | LNET_PEER_FORCE_PING |
+			  LNET_PEER_FORCE_PUSH);
+
+	return rc;
 }
 
 /*
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
