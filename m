Return-Path: <SRS0=FD7t=JM=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7DEC6C433B4
	for <lustre-devel@archiver.kernel.org>; Thu, 15 Apr 2021 04:03:06 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 34384610CB
	for <lustre-devel@archiver.kernel.org>; Thu, 15 Apr 2021 04:03:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 34384610CB
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 7A78832F4DD;
	Wed, 14 Apr 2021 21:03:00 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 6764132F3FA
 for <lustre-devel@lists.lustre.org>; Wed, 14 Apr 2021 21:02:49 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 60102100F34A;
 Thu, 15 Apr 2021 00:02:45 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 573F091883; Thu, 15 Apr 2021 00:02:45 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Thu, 15 Apr 2021 00:02:00 -0400
Message-Id: <1618459361-17909-9-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1618459361-17909-1-git-send-email-jsimmons@infradead.org>
References: <1618459361-17909-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 08/49] lnet: Lookup lpni after discovery
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

The lpni for a nid can change as part of the discovery process (see
lnet_peer_add_nid()). As such, callers of lnet_discover_peer_locked()
need to lookup the lpni again after discovery completes to make sure
they get the correct peer.

An exception is lnet_check_routers() which doesn't do anything with
the peer or peer NI after the call to lnet_discover_peer_locked().
If the router list is changed then lnet_check_routers() will already
repeat discovery.

HPE-bug-id: LUS-9167
WC-bug-id: https://jira.whamcloud.com/browse/LU-13883
Lustre-commit: 584d9e46053234d0 ("LU-13883 lnet: Lookup lpni after discovery")
Signed-off-by: Chris Horn <chris.horn@hpe.com>
Reviewed-on: https://review.whamcloud.com/39747
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/lib-lnet.h |  1 +
 net/lnet/lnet/api-ni.c        | 12 ++++++++++++
 net/lnet/lnet/lib-move.c      | 30 ++++++++++++++++++++++++------
 net/lnet/lnet/peer.c          | 30 ++++++++++++++++++++++++++++++
 4 files changed, 67 insertions(+), 6 deletions(-)

diff --git a/include/linux/lnet/lib-lnet.h b/include/linux/lnet/lib-lnet.h
index 2741c6f..1954614 100644
--- a/include/linux/lnet/lib-lnet.h
+++ b/include/linux/lnet/lib-lnet.h
@@ -817,6 +817,7 @@ struct lnet_peer_ni *lnet_peer_get_ni_locked(struct lnet_peer *lp,
 void lnet_peer_net_added(struct lnet_net *net);
 lnet_nid_t lnet_peer_primary_nid_locked(lnet_nid_t nid);
 int lnet_discover_peer_locked(struct lnet_peer_ni *lpni, int cpt, bool block);
+void lnet_peer_queue_message(struct lnet_peer *lp, struct lnet_msg *msg);
 int lnet_peer_discovery_start(void);
 void lnet_peer_discovery_stop(void);
 void lnet_push_update_to_peers(int force);
diff --git a/net/lnet/lnet/api-ni.c b/net/lnet/lnet/api-ni.c
index 542cc2e..0c0b304 100644
--- a/net/lnet/lnet/api-ni.c
+++ b/net/lnet/lnet/api-ni.c
@@ -4540,6 +4540,18 @@ static int lnet_ping(struct lnet_process_id id, signed long timeout,
 	if (rc)
 		goto out_decref;
 
+	/* The lpni (or lp) for this NID may have changed and our ref is
+	 * the only thing keeping the old one around. Release the ref
+	 * and lookup the lpni again
+	 */
+	lnet_peer_ni_decref_locked(lpni);
+	lpni = lnet_find_peer_ni_locked(id.nid);
+	if (!lpni) {
+		rc = -ENOENT;
+		goto out;
+	}
+	lp = lpni->lpni_peer_net->lpn_peer;
+
 	i = 0;
 	p = NULL;
 	while ((p = lnet_get_next_peer_ni_locked(lp, NULL, p)) != NULL) {
diff --git a/net/lnet/lnet/lib-move.c b/net/lnet/lnet/lib-move.c
index de17de4b..25e0fd2 100644
--- a/net/lnet/lnet/lib-move.c
+++ b/net/lnet/lnet/lib-move.c
@@ -1834,6 +1834,7 @@ struct lnet_ni *
 			     int cpt)
 {
 	struct lnet_peer *peer;
+	struct lnet_peer_ni *new_lpni;
 	int rc;
 
 	lnet_peer_ni_addref_locked(lpni);
@@ -1855,21 +1856,38 @@ struct lnet_ni *
 		lnet_peer_ni_decref_locked(lpni);
 		return rc;
 	}
-	/* The peer may have changed. */
-	peer = lpni->lpni_peer_net->lpn_peer;
+
+	new_lpni = lnet_find_peer_ni_locked(lpni->lpni_nid);
+	if (!new_lpni) {
+		lnet_peer_ni_decref_locked(lpni);
+		return -ENOENT;
+	}
+
+	peer = new_lpni->lpni_peer_net->lpn_peer;
 	spin_lock(&peer->lp_lock);
-	if (lnet_peer_is_uptodate_locked(peer)) {
+	if (lpni == new_lpni && lnet_peer_is_uptodate_locked(peer)) {
+		/* The peer NI did not change and the peer is up to date.
+		 * Nothing more to do.
+		 */
 		spin_unlock(&peer->lp_lock);
 		lnet_peer_ni_decref_locked(lpni);
+		lnet_peer_ni_decref_locked(new_lpni);
 		return 0;
 	}
-	/* queue message and return */
+	spin_unlock(&peer->lp_lock);
+
+	/* Either the peer NI changed during discovery, or the peer isn't up
+	 * to date. In both cases we want to queue the message on the
+	 * (possibly new) peer's pending queue and queue the peer for discovery
+	 */
 	msg->msg_sending = 0;
 	msg->msg_txpeer = NULL;
-	list_add_tail(&msg->msg_list, &peer->lp_dc_pendq);
-	spin_unlock(&peer->lp_lock);
+	lnet_net_unlock(cpt);
+	lnet_peer_queue_message(peer, msg);
+	lnet_net_lock(cpt);
 
 	lnet_peer_ni_decref_locked(lpni);
+	lnet_peer_ni_decref_locked(new_lpni);
 
 	CDEBUG(D_NET, "msg %p delayed. %s pending discovery\n",
 	       msg, libcfs_nid2str(peer->lp_primary_nid));
diff --git a/net/lnet/lnet/peer.c b/net/lnet/lnet/peer.c
index 1b240f1..ba41d86 100644
--- a/net/lnet/lnet/peer.c
+++ b/net/lnet/lnet/peer.c
@@ -1346,6 +1346,16 @@ struct lnet_peer_ni *
 		rc = lnet_discover_peer_locked(lpni, cpt, true);
 		if (rc)
 			goto out_decref;
+		/* The lpni (or lp) for this NID may have changed and our ref is
+		 * the only thing keeping the old one around. Release the ref
+		 * and lookup the lpni again
+		 */
+		lnet_peer_ni_decref_locked(lpni);
+		lpni = lnet_find_peer_ni_locked(nid);
+		if (!lpni) {
+			rc = -ENOENT;
+			goto out_unlock;
+		}
 		lp = lpni->lpni_peer_net->lpn_peer;
 
 		/* Only try once if discovery is disabled */
@@ -2054,6 +2064,26 @@ struct lnet_peer_ni *
 	return rc;
 }
 
+/* Add the message to the peer's lp_dc_pendq and queue the peer for discovery */
+void
+lnet_peer_queue_message(struct lnet_peer *lp, struct lnet_msg *msg)
+{
+	/* The discovery thread holds net_lock/EX and lp_lock when it splices
+	 * the lp_dc_pendq onto a local list for resending. Thus, we do the same
+	 * when adding to the list and queuing the peer to ensure that we do not
+	 * strand any messages on the lp_dc_pendq. This scheme ensures the
+	 * message will be resent even if the peer is already being discovered.
+	 * Therefore we needn't check the return value of
+	 * lnet_peer_queue_for_discovery(lp).
+	 */
+	lnet_net_lock(LNET_LOCK_EX);
+	spin_lock(&lp->lp_lock);
+	list_add_tail(&msg->msg_list, &lp->lp_dc_pendq);
+	spin_unlock(&lp->lp_lock);
+	lnet_peer_queue_for_discovery(lp);
+	lnet_net_unlock(LNET_LOCK_EX);
+}
+
 /*
  * Queue a peer for the attention of the discovery thread.  Call with
  * lnet_net_lock/EX held. Returns 0 if the peer was queued, and
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
