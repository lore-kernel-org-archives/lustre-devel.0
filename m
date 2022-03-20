Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id ACC91C433EF
	for <lustre-devel@archiver.kernel.org>; Sun, 20 Mar 2022 13:32:55 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id C04B121FBD9;
	Sun, 20 Mar 2022 06:32:06 -0700 (PDT)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 5455221EBCD
 for <lustre-devel@lists.lustre.org>; Sun, 20 Mar 2022 06:31:16 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 407EEEF0;
 Sun, 20 Mar 2022 09:31:08 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 3D54CAB; Sun, 20 Mar 2022 09:31:08 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 20 Mar 2022 09:30:39 -0400
Message-Id: <1647783064-20688-26-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1647783064-20688-1-git-send-email-jsimmons@infradead.org>
References: <1647783064-20688-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 25/50] lnet: convert nids in lnet_parse to
 lnet_nid
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
Cc: Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Mr NeilBrown <neilb@suse.de>

src_nid and dest_nid in lnet_parse() are changed to
struct lnet_nid, and this change propagates out to
affect a few support function.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10391
Lustre-commit: ac439ce87b0acbff3 ("LU-10391 lnet: convert nids in lnet_parse to lnet_nid")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/43613
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/lib-lnet.h |  4 +--
 net/lnet/lnet/api-ni.c        | 13 -------
 net/lnet/lnet/lib-move.c      | 80 ++++++++++++++++++++-----------------------
 net/lnet/lnet/peer.c          |  7 ++--
 4 files changed, 43 insertions(+), 61 deletions(-)

diff --git a/include/linux/lnet/lib-lnet.h b/include/linux/lnet/lib-lnet.h
index 297e5ef..fe2fd83 100644
--- a/include/linux/lnet/lib-lnet.h
+++ b/include/linux/lnet/lib-lnet.h
@@ -626,7 +626,6 @@ void lnet_rtr_transfer_to_peer(struct lnet_peer *src,
 void lnet_net_clr_pref_rtrs(struct lnet_net *net);
 int lnet_net_add_pref_rtr(struct lnet_net *net, struct lnet_nid *gw_nid);
 
-int lnet_islocalnid4(lnet_nid_t nid);
 int lnet_islocalnid(struct lnet_nid *nid);
 int lnet_islocalnet(u32 net);
 int lnet_islocalnet_locked(u32 net);
@@ -912,7 +911,8 @@ struct lnet_peer_ni *lnet_peer_ni_get_locked(struct lnet_peer *lp,
 struct lnet_peer *lnet_find_peer4(lnet_nid_t nid);
 struct lnet_peer *lnet_find_peer(struct lnet_nid *nid);
 void lnet_peer_net_added(struct lnet_net *net);
-void lnet_peer_primary_nid_locked(lnet_nid_t nid, struct lnet_nid *result);
+void lnet_peer_primary_nid_locked(struct lnet_nid *nid,
+				  struct lnet_nid *result);
 int lnet_discover_peer_locked(struct lnet_peer_ni *lpni, int cpt, bool block);
 void lnet_peer_queue_message(struct lnet_peer *lp, struct lnet_msg *msg);
 int lnet_peer_discovery_start(void);
diff --git a/net/lnet/lnet/api-ni.c b/net/lnet/lnet/api-ni.c
index d7ada85..0389a89 100644
--- a/net/lnet/lnet/api-ni.c
+++ b/net/lnet/lnet/api-ni.c
@@ -1636,19 +1636,6 @@ struct lnet_ni *
 EXPORT_SYMBOL(lnet_nid_to_ni_addref);
 
 int
-lnet_islocalnid4(lnet_nid_t nid)
-{
-	struct lnet_ni *ni;
-	int cpt;
-
-	cpt = lnet_net_lock_current();
-	ni = lnet_nid2ni_locked(nid, cpt);
-	lnet_net_unlock(cpt);
-
-	return !!ni;
-}
-
-int
 lnet_islocalnid(struct lnet_nid *nid)
 {
 	struct lnet_ni	*ni;
diff --git a/net/lnet/lnet/lib-move.c b/net/lnet/lnet/lib-move.c
index 496c895..051bea1 100644
--- a/net/lnet/lnet/lib-move.c
+++ b/net/lnet/lnet/lib-move.c
@@ -239,16 +239,14 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 }
 
 static int
-fail_peer(lnet_nid_t nid4, int outgoing)
+fail_peer(struct lnet_nid *nid, int outgoing)
 {
 	struct lnet_test_peer *tp;
 	struct list_head *el;
 	struct list_head *next;
-	struct lnet_nid nid;
 	LIST_HEAD(cull);
 	int fail = 0;
 
-	lnet_nid4_to_nid(nid4, &nid);
 	/* NB: use lnet_net_lock(0) to serialize operations on test peers */
 	lnet_net_lock(0);
 
@@ -269,7 +267,7 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 		}
 
 		if (LNET_NID_IS_ANY(&tp->tp_nid) ||	/* fail every peer */
-		    nid_same(&nid, &tp->tp_nid)) {	/* fail this peer */
+		    nid_same(nid, &tp->tp_nid)) {	/* fail this peer */
 			fail = 1;
 
 			if (tp->tp_threshold != LNET_MD_THRESH_INF) {
@@ -4238,8 +4236,8 @@ void lnet_monitor_thr_stop(void)
 	struct lnet_msg *msg;
 	u32 payload_length;
 	lnet_pid_t dest_pid;
-	lnet_nid_t dest_nid;
-	lnet_nid_t src_nid;
+	struct lnet_nid dest_nid;
+	struct lnet_nid src_nid;
 	struct lnet_nid from_nid;
 	bool push = false;
 	int for_me;
@@ -4252,19 +4250,18 @@ void lnet_monitor_thr_stop(void)
 	lnet_nid4_to_nid(from_nid4, &from_nid);
 
 	type = hdr->type;
-	src_nid = lnet_nid_to_nid4(&hdr->src_nid);
-	dest_nid = lnet_nid_to_nid4(&hdr->dest_nid);
+	src_nid = hdr->src_nid;
+	dest_nid = hdr->dest_nid;
 	dest_pid = hdr->dest_pid;
 	payload_length = hdr->payload_length;
 
-	/* FIXME handle large-addr nids */
-	for_me = (lnet_nid_to_nid4(&ni->ni_nid) == dest_nid);
-	cpt = lnet_cpt_of_nid(from_nid4, ni);
+	for_me = nid_same(&ni->ni_nid, &dest_nid);
+	cpt = lnet_nid2cpt(&from_nid, ni);
 
 	CDEBUG(D_NET, "TRACE: %s(%s) <- %s : %s\n",
-	       libcfs_nid2str(dest_nid),
+	       libcfs_nidstr(&dest_nid),
 	       libcfs_nidstr(&ni->ni_nid),
-	       libcfs_nid2str(src_nid),
+	       libcfs_nidstr(&src_nid),
 	       lnet_msgtyp2str(type));
 
 	switch (type) {
@@ -4273,7 +4270,7 @@ void lnet_monitor_thr_stop(void)
 		if (payload_length > 0) {
 			CERROR("%s, src %s: bad %s payload %d (0 expected)\n",
 			       libcfs_nid2str(from_nid4),
-			       libcfs_nid2str(src_nid),
+			       libcfs_nidstr(&src_nid),
 			       lnet_msgtyp2str(type), payload_length);
 			return -EPROTO;
 		}
@@ -4285,7 +4282,7 @@ void lnet_monitor_thr_stop(void)
 		   (u32)(for_me ? LNET_MAX_PAYLOAD : LNET_MTU)) {
 			CERROR("%s, src %s: bad %s payload %d (%d max expected)\n",
 			       libcfs_nid2str(from_nid4),
-			       libcfs_nid2str(src_nid),
+			       libcfs_nidstr(&src_nid),
 			       lnet_msgtyp2str(type),
 			       payload_length,
 			       for_me ? LNET_MAX_PAYLOAD : LNET_MTU);
@@ -4296,7 +4293,7 @@ void lnet_monitor_thr_stop(void)
 	default:
 		CERROR("%s, src %s: Bad message type 0x%x\n",
 		       libcfs_nid2str(from_nid4),
-		       libcfs_nid2str(src_nid), type);
+		       libcfs_nidstr(&src_nid), type);
 		return -EPROTO;
 	}
 
@@ -4319,40 +4316,39 @@ void lnet_monitor_thr_stop(void)
 	 * or malicious so we chop them off at the knees :)
 	 */
 	if (!for_me) {
-		if (LNET_NIDNET(dest_nid) == LNET_NID_NET(&ni->ni_nid)) {
+		if (LNET_NID_NET(&dest_nid) == LNET_NID_NET(&ni->ni_nid)) {
 			/* should have gone direct */
 			CERROR("%s, src %s: Bad dest nid %s (should have been sent direct)\n",
 			       libcfs_nid2str(from_nid4),
-			       libcfs_nid2str(src_nid),
-			       libcfs_nid2str(dest_nid));
+			       libcfs_nidstr(&src_nid),
+			       libcfs_nidstr(&dest_nid));
 			return -EPROTO;
 		}
 
-		if (lnet_islocalnid4(dest_nid)) {
-			/*
-			 * dest is another local NI; sender should have used
+		if (lnet_islocalnid(&dest_nid)) {
+			/* dest is another local NI; sender should have used
 			 * this node's NID on its own network
 			 */
 			CERROR("%s, src %s: Bad dest nid %s (it's my nid but on a different network)\n",
 			       libcfs_nid2str(from_nid4),
-			       libcfs_nid2str(src_nid),
-			       libcfs_nid2str(dest_nid));
+			       libcfs_nidstr(&src_nid),
+			       libcfs_nidstr(&dest_nid));
 			return -EPROTO;
 		}
 
 		if (rdma_req && type == LNET_MSG_GET) {
 			CERROR("%s, src %s: Bad optimized GET for %s (final destination must be me)\n",
 			       libcfs_nid2str(from_nid4),
-			       libcfs_nid2str(src_nid),
-			       libcfs_nid2str(dest_nid));
+			       libcfs_nidstr(&src_nid),
+			       libcfs_nidstr(&dest_nid));
 			return -EPROTO;
 		}
 
 		if (!the_lnet.ln_routing) {
 			CERROR("%s, src %s: Dropping message for %s (routing not enabled)\n",
 			       libcfs_nid2str(from_nid4),
-			       libcfs_nid2str(src_nid),
-			       libcfs_nid2str(dest_nid));
+			       libcfs_nidstr(&src_nid),
+			       libcfs_nidstr(&dest_nid));
 			goto drop;
 		}
 	}
@@ -4361,10 +4357,10 @@ void lnet_monitor_thr_stop(void)
 	 * Message looks OK; we're not going to return an error, so we MUST
 	 * call back lnd_recv() come what may...
 	 */
-	if (!list_empty(&the_lnet.ln_test_peers) && /* normally we don't */
-	    fail_peer(src_nid, 0)) {		/* shall we now? */
+	if (!list_empty(&the_lnet.ln_test_peers) &&	/* normally we don't */
+	    fail_peer(&src_nid, 0)) {			/* shall we now? */
 		CERROR("%s, src %s: Dropping %s to simulate failure\n",
-		       libcfs_nid2str(from_nid4), libcfs_nid2str(src_nid),
+		       libcfs_nid2str(from_nid4), libcfs_nidstr(&src_nid),
 		       lnet_msgtyp2str(type));
 		goto drop;
 	}
@@ -4373,15 +4369,15 @@ void lnet_monitor_thr_stop(void)
 	if (!list_empty(&the_lnet.ln_drop_rules) &&
 	    lnet_drop_rule_match(hdr, lnet_nid_to_nid4(&ni->ni_nid), NULL)) {
 		CDEBUG(D_NET, "%s, src %s, dst %s: Dropping %s to simulate silent message loss\n",
-		       libcfs_nid2str(from_nid4), libcfs_nid2str(src_nid),
-		       libcfs_nid2str(dest_nid), lnet_msgtyp2str(type));
+		       libcfs_nid2str(from_nid4), libcfs_nidstr(&src_nid),
+		       libcfs_nidstr(&dest_nid), lnet_msgtyp2str(type));
 		goto drop;
 	}
 
 	msg = kmem_cache_zalloc(lnet_msg_cachep, GFP_NOFS);
 	if (!msg) {
 		CERROR("%s, src %s: Dropping %s (out of memory)\n",
-		       libcfs_nid2str(from_nid4), libcfs_nid2str(src_nid),
+		       libcfs_nid2str(from_nid4), libcfs_nidstr(&src_nid),
 		       lnet_msgtyp2str(type));
 		goto drop;
 	}
@@ -4401,7 +4397,7 @@ void lnet_monitor_thr_stop(void)
 	msg->msg_from = from_nid;
 	if (!for_me) {
 		msg->msg_target.pid = dest_pid;
-		lnet_nid4_to_nid(dest_nid, &msg->msg_target.nid);
+		msg->msg_target.nid = dest_nid;
 		msg->msg_routing = 1;
 	}
 
@@ -4411,7 +4407,7 @@ void lnet_monitor_thr_stop(void)
 		lnet_net_unlock(cpt);
 		rc = PTR_ERR(lpni);
 		CERROR("%s, src %s: Dropping %s (error %d looking up sender)\n",
-		       libcfs_nid2str(from_nid4), libcfs_nid2str(src_nid),
+		       libcfs_nid2str(from_nid4), libcfs_nidstr(&src_nid),
 		       lnet_msgtyp2str(type), rc);
 		kfree(msg);
 		if (rc == -ESHUTDOWN)
@@ -4426,8 +4422,8 @@ void lnet_monitor_thr_stop(void)
 	 */
 	if (((lnet_drop_asym_route && for_me) ||
 	     !lpni->lpni_peer_net->lpn_peer->lp_alive) &&
-	    LNET_NIDNET(src_nid) != LNET_NIDNET(from_nid4)) {
-		u32 src_net_id = LNET_NIDNET(src_nid);
+	    LNET_NID_NET(&src_nid) != LNET_NIDNET(from_nid4)) {
+		u32 src_net_id = LNET_NID_NET(&src_nid);
 		struct lnet_peer *gw = lpni->lpni_peer_net->lpn_peer;
 		struct lnet_route *route;
 		bool found = false;
@@ -4462,7 +4458,7 @@ void lnet_monitor_thr_stop(void)
 			 */
 			CERROR("%s, src %s: Dropping asymmetrical route %s\n",
 			       libcfs_nid2str(from_nid4),
-			       libcfs_nid2str(src_nid), lnet_msgtyp2str(type));
+			       libcfs_nidstr(&src_nid), lnet_msgtyp2str(type));
 			kfree(msg);
 			goto drop;
 		}
@@ -4486,7 +4482,7 @@ void lnet_monitor_thr_stop(void)
 	msg->msg_rxni = ni;
 	lnet_ni_addref_locked(ni, cpt);
 	/* Multi-Rail: Primary NID of source. */
-	lnet_peer_primary_nid_locked(src_nid, &msg->msg_initiator);
+	lnet_peer_primary_nid_locked(&src_nid, &msg->msg_initiator);
 
 	/* mark the status of this lpni as UP since we received a message
 	 * from it. The ping response reports back the ns_status which is
@@ -4718,7 +4714,7 @@ void lnet_monitor_thr_stop(void)
 	target.pid = target4.pid;
 
 	if (!list_empty(&the_lnet.ln_test_peers) &&	/* normally we don't */
-	    fail_peer(target4.nid, 1)) {		/* shall we now? */
+	    fail_peer(&target.nid, 1)) {		/* shall we now? */
 		CERROR("Dropping PUT to %s: simulated failure\n",
 		       libcfs_id2str(target4));
 		return -EIO;
@@ -4964,7 +4960,7 @@ struct lnet_msg *
 	target.pid = target4.pid;
 
 	if (!list_empty(&the_lnet.ln_test_peers) &&	/* normally we don't */
-	    fail_peer(target4.nid, 1)) {		/* shall we now? */
+	    fail_peer(&target.nid, 1)) {		/* shall we now? */
 		CERROR("Dropping GET to %s: simulated failure\n",
 		       libcfs_id2str(target4));
 		return -EIO;
diff --git a/net/lnet/lnet/peer.c b/net/lnet/lnet/peer.c
index 494b7ef..8e7f44c 100644
--- a/net/lnet/lnet/peer.c
+++ b/net/lnet/lnet/peer.c
@@ -1345,13 +1345,12 @@ struct lnet_peer_ni *
 }
 
 void
-lnet_peer_primary_nid_locked(lnet_nid_t nid, struct lnet_nid *result)
+lnet_peer_primary_nid_locked(struct lnet_nid *nid, struct lnet_nid *result)
 {
-	/* FIXME handle large-addr nid */
 	struct lnet_peer_ni *lpni;
 
-	lnet_nid4_to_nid(nid, result);
-	lpni = lnet_find_peer_ni_locked(nid);
+	*result = *nid;
+	lpni = lnet_peer_ni_find_locked(nid);
 	if (lpni) {
 		*result = lpni->lpni_peer_net->lpn_peer->lp_primary_nid;
 		lnet_peer_ni_decref_locked(lpni);
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
