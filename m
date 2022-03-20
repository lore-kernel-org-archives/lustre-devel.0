Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id E8140C433F5
	for <lustre-devel@archiver.kernel.org>; Sun, 20 Mar 2022 13:31:23 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id DE37921F97E;
	Sun, 20 Mar 2022 06:31:18 -0700 (PDT)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 6606C21CA7D
 for <lustre-devel@lists.lustre.org>; Sun, 20 Mar 2022 06:31:10 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id ED954ED6;
 Sun, 20 Mar 2022 09:31:07 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id E3C0DE4F03; Sun, 20 Mar 2022 09:31:07 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 20 Mar 2022 09:30:18 -0400
Message-Id: <1647783064-20688-5-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1647783064-20688-1-git-send-email-jsimmons@infradead.org>
References: <1647783064-20688-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 04/50] lnet: Change lnet_send() to take
 large-addr nids
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

The src and rtr nids passed to lnet_send() are now pointers to a
'struct lnet_nid'.  NULL can be passed for the rtr nid, which is
treated the same as ANY.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10391
Lustre-commit: 005bd7075c8710fb8 ("LU-10391 lnet: Change lnet_send() to take large-addr nids")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/43599
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/lib-lnet.h |   3 +-
 net/lnet/lnet/lib-move.c      | 181 +++++++++++++++++++++++-------------------
 net/lnet/lnet/lib-msg.c       |   7 +-
 net/lnet/lnet/peer.c          |   8 +-
 4 files changed, 108 insertions(+), 91 deletions(-)

diff --git a/include/linux/lnet/lib-lnet.h b/include/linux/lnet/lib-lnet.h
index 29a6252..8b4a29b 100644
--- a/include/linux/lnet/lib-lnet.h
+++ b/include/linux/lnet/lib-lnet.h
@@ -585,7 +585,8 @@ void lnet_msg_attach_md(struct lnet_msg *msg, struct lnet_libmd *md,
 void lnet_prep_send(struct lnet_msg *msg, int type,
 		    struct lnet_process_id target, unsigned int offset,
 		    unsigned int len);
-int lnet_send(lnet_nid_t nid, struct lnet_msg *msg, lnet_nid_t rtr_nid);
+int lnet_send(struct lnet_nid *nid, struct lnet_msg *msg,
+	      struct lnet_nid *rtr_nid);
 int lnet_send_ping(lnet_nid_t dest_nid, struct lnet_handle_md *mdh, int nnis,
 		   void *user_ptr, lnet_handler_t handler, bool recovery);
 void lnet_return_tx_credits_locked(struct lnet_msg *msg);
diff --git a/net/lnet/lnet/lib-move.c b/net/lnet/lnet/lib-move.c
index 83c93ca..de3e0ac 100644
--- a/net/lnet/lnet/lib-move.c
+++ b/net/lnet/lnet/lib-move.c
@@ -53,9 +53,9 @@ struct lnet_send_data {
 	struct lnet_peer_ni	*sd_gw_lpni;
 	struct lnet_peer_net	*sd_peer_net;
 	struct lnet_msg		*sd_msg;
-	lnet_nid_t		sd_dst_nid;
-	lnet_nid_t		sd_src_nid;
-	lnet_nid_t		sd_rtr_nid;
+	struct lnet_nid		sd_dst_nid;
+	struct lnet_nid		sd_src_nid;
+	struct lnet_nid		sd_rtr_nid;
 	int			sd_cpt;
 	int			sd_md_cpt;
 	u32			sd_send_case;
@@ -1769,11 +1769,11 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 		CDEBUG(D_NET, "TRACE: %s(%s:%s) -> %s(%s:%s) %s : %s try# %d\n",
 		       libcfs_nid2str(msg->msg_hdr.src_nid),
 		       libcfs_nidstr(&msg->msg_txni->ni_nid),
-		       libcfs_nid2str(sd->sd_src_nid),
+		       libcfs_nidstr(&sd->sd_src_nid),
 		       libcfs_nid2str(msg->msg_hdr.dest_nid),
-		       libcfs_nid2str(sd->sd_dst_nid),
+		       libcfs_nidstr(&sd->sd_dst_nid),
 		       libcfs_nidstr(&msg->msg_txpeer->lpni_nid),
-		       libcfs_nid2str(sd->sd_rtr_nid),
+		       libcfs_nidstr(&sd->sd_rtr_nid),
 		       lnet_msgtyp2str(msg->msg_type), msg->msg_retry_count);
 
 	return rc;
@@ -1804,11 +1804,11 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 	/* the destination lpni is set before we get here. */
 
 	/* find local NI */
-	sd->sd_best_ni = lnet_nid2ni_locked(sd->sd_src_nid, sd->sd_cpt);
+	sd->sd_best_ni = lnet_nid_to_ni_locked(&sd->sd_src_nid, sd->sd_cpt);
 	if (!sd->sd_best_ni) {
 		CERROR("Can't send to %s: src %s is not a local nid\n",
-		       libcfs_nid2str(sd->sd_dst_nid),
-		       libcfs_nid2str(sd->sd_src_nid));
+		       libcfs_nidstr(&sd->sd_dst_nid),
+		       libcfs_nidstr(&sd->sd_src_nid));
 		return -EINVAL;
 	}
 
@@ -1830,11 +1830,11 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 static int
 lnet_handle_spec_local_mr_dst(struct lnet_send_data *sd)
 {
-	sd->sd_best_ni = lnet_nid2ni_locked(sd->sd_src_nid, sd->sd_cpt);
+	sd->sd_best_ni = lnet_nid_to_ni_locked(&sd->sd_src_nid, sd->sd_cpt);
 	if (!sd->sd_best_ni) {
 		CERROR("Can't send to %s: src %s is not a local nid\n",
-		       libcfs_nid2str(sd->sd_dst_nid),
-		       libcfs_nid2str(sd->sd_src_nid));
+		       libcfs_nidstr(&sd->sd_dst_nid),
+		       libcfs_nidstr(&sd->sd_src_nid));
 		return -EINVAL;
 	}
 
@@ -1846,7 +1846,7 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 		return lnet_handle_send(sd);
 
 	CERROR("can't send to %s. no NI on %s\n",
-	       libcfs_nid2str(sd->sd_dst_nid),
+	       libcfs_nidstr(&sd->sd_dst_nid),
 	       libcfs_net2str(sd->sd_best_ni->ni_net->net_id));
 
 	return -EHOSTUNREACH;
@@ -1947,7 +1947,7 @@ struct lnet_ni *
 
 static int
 lnet_handle_find_routed_path(struct lnet_send_data *sd,
-			     lnet_nid_t dst_nid,
+			     struct lnet_nid *dst_nid,
 			     struct lnet_peer_ni **gw_lpni,
 			     struct lnet_peer **gw_peer)
 {
@@ -1962,21 +1962,21 @@ struct lnet_ni *
 	struct lnet_peer_ni *lpni = NULL;
 	struct lnet_peer_ni *gwni = NULL;
 	bool route_found = false;
-	lnet_nid_t src_nid = (sd->sd_src_nid != LNET_NID_ANY) ? sd->sd_src_nid :
-			      sd->sd_best_ni ? lnet_nid_to_nid4(&sd->sd_best_ni->ni_nid) :
-			      LNET_NID_ANY;
+	struct lnet_nid *src_nid =
+		!LNET_NID_IS_ANY(&sd->sd_src_nid) ||
+		!sd->sd_best_ni ? &sd->sd_src_nid : &sd->sd_best_ni->ni_nid;
 	int best_lpn_healthv = 0;
 	u32 best_lpn_sel_prio = LNET_MAX_SELECTION_PRIORITY;
 
 	CDEBUG(D_NET, "using src nid %s for route restriction\n",
-	       libcfs_nid2str(src_nid));
+	       src_nid ? libcfs_nidstr(src_nid) : "ANY");
 
 	/* If a router nid was specified then we are replying to a GET or
 	 * sending an ACK. In this case we use the gateway associated with the
 	 * specified router nid.
 	 */
-	if (sd->sd_rtr_nid != LNET_NID_ANY) {
-		gwni = lnet_find_peer_ni_locked(sd->sd_rtr_nid);
+	if (!LNET_NID_IS_ANY(&sd->sd_rtr_nid)) {
+		gwni = lnet_peer_ni_find_locked(&sd->sd_rtr_nid);
 		if (gwni) {
 			gw = gwni->lpni_peer_net->lpn_peer;
 			lnet_peer_ni_decref_locked(gwni);
@@ -1984,25 +1984,26 @@ struct lnet_ni *
 				route_found = true;
 		} else {
 			CWARN("No peer NI for gateway %s. Attempting to find an alternative route.\n",
-			       libcfs_nid2str(sd->sd_rtr_nid));
+			       libcfs_nidstr(&sd->sd_rtr_nid));
 		}
 	}
 
 	if (!route_found) {
-		if (sd->sd_msg->msg_routing || src_nid != LNET_NID_ANY) {
+		if (sd->sd_msg->msg_routing ||
+		    (src_nid && !LNET_NID_IS_ANY(src_nid))) {
 			/* If I'm routing this message then I need to find the
 			 * next hop based on the destination NID
 			 *
 			 * We also find next hop based on the destination NID
 			 * if the source NI was specified
 			 */
-			best_rnet = lnet_find_rnet_locked(LNET_NIDNET(sd->sd_dst_nid));
+			best_rnet = lnet_find_rnet_locked(LNET_NID_NET(&sd->sd_dst_nid));
 			if (!best_rnet) {
 				CERROR("Unable to send message from %s to %s - Route table may be misconfigured\n",
-				       src_nid != LNET_NID_ANY ?
-						libcfs_nid2str(src_nid) :
-						"any local NI",
-				       libcfs_nid2str(sd->sd_dst_nid));
+				       (src_nid && LNET_NID_IS_ANY(src_nid)) ?
+						"any local NI" :
+						libcfs_nidstr(src_nid),
+				       libcfs_nidstr(&sd->sd_dst_nid));
 				return -EHOSTUNREACH;
 			}
 		} else {
@@ -2049,17 +2050,17 @@ struct lnet_ni *
 
 			if (!best_lpn) {
 				CERROR("peer %s has no available nets\n",
-				       libcfs_nid2str(sd->sd_dst_nid));
+				       libcfs_nidstr(&sd->sd_dst_nid));
 				return -EHOSTUNREACH;
 			}
 
 			sd->sd_best_lpni = lnet_find_best_lpni(sd->sd_best_ni,
-							       sd->sd_dst_nid,
+							       lnet_nid_to_nid4(&sd->sd_dst_nid),
 							       lp,
 							       best_lpn->lpn_net_id);
 			if (!sd->sd_best_lpni) {
 				CERROR("peer %s is unreachable\n",
-				       libcfs_nid2str(sd->sd_dst_nid));
+				       libcfs_nidstr(&sd->sd_dst_nid));
 				return -EHOSTUNREACH;
 			}
 
@@ -2083,20 +2084,20 @@ struct lnet_ni *
 		 * have when adding a route.
 		 */
 		best_route = lnet_find_route_locked(best_rnet,
-						    LNET_NIDNET(src_nid),
+						    LNET_NID_NET(src_nid),
 						    sd->sd_best_lpni,
 						    &last_route, &gwni);
 		if (!best_route) {
 			CERROR("no route to %s from %s\n",
-			       libcfs_nid2str(dst_nid),
-			       libcfs_nid2str(src_nid));
+			       libcfs_nidstr(dst_nid),
+			       libcfs_nidstr(src_nid));
 			return -EHOSTUNREACH;
 		}
 
 		if (!gwni) {
 			CERROR("Internal Error. Route expected to %s from %s\n",
-			       libcfs_nid2str(dst_nid),
-			       libcfs_nid2str(src_nid));
+			       libcfs_nidstr(dst_nid),
+			       libcfs_nidstr(src_nid));
 			return -EFAULT;
 		}
 
@@ -2130,7 +2131,7 @@ struct lnet_ni *
 		if (!sd->sd_best_ni) {
 			CERROR("Internal Error. Expected local ni on %s but non found :%s\n",
 			       libcfs_net2str(lpn->lpn_net_id),
-			       libcfs_nid2str(sd->sd_src_nid));
+			       libcfs_nidstr(&sd->sd_src_nid));
 			return -EFAULT;
 		}
 	}
@@ -2141,7 +2142,7 @@ struct lnet_ni *
 	/* increment the sequence numbers since now we're sure we're
 	 * going to use this path
 	 */
-	if (sd->sd_rtr_nid == LNET_NID_ANY) {
+	if (LNET_NID_IS_ANY(&sd->sd_rtr_nid)) {
 		LASSERT(best_route && last_route);
 		best_route->lr_seq = last_route->lr_seq + 1;
 		if (best_lpn)
@@ -2174,15 +2175,15 @@ struct lnet_ni *
 	struct lnet_peer *gw_peer = NULL;
 
 	/* find local NI */
-	sd->sd_best_ni = lnet_nid2ni_locked(sd->sd_src_nid, sd->sd_cpt);
+	sd->sd_best_ni = lnet_nid_to_ni_locked(&sd->sd_src_nid, sd->sd_cpt);
 	if (!sd->sd_best_ni) {
 		CERROR("Can't send to %s: src %s is not a local nid\n",
-		       libcfs_nid2str(sd->sd_dst_nid),
-		       libcfs_nid2str(sd->sd_src_nid));
+		       libcfs_nidstr(&sd->sd_dst_nid),
+		       libcfs_nidstr(&sd->sd_src_nid));
 		return -EINVAL;
 	}
 
-	rc = lnet_handle_find_routed_path(sd, sd->sd_dst_nid, &gw_lpni,
+	rc = lnet_handle_find_routed_path(sd, &sd->sd_dst_nid, &gw_lpni,
 					  &gw_peer);
 	if (rc)
 		return rc;
@@ -2403,7 +2404,7 @@ struct lnet_ni *
 	if (!sd->sd_best_lpni) {
 		CERROR("Internal fault. Unable to send msg %s to %s. NID not known\n",
 		       lnet_msgtyp2str(sd->sd_msg->msg_type),
-		       libcfs_nid2str(sd->sd_dst_nid));
+		       libcfs_nidstr(&sd->sd_dst_nid));
 		return -EFAULT;
 	}
 
@@ -2418,7 +2419,7 @@ struct lnet_ni *
 							       sd->sd_md_cpt);
 		if (!sd->sd_best_ni) {
 			CERROR("Unable to forward message to %s. No local NI available\n",
-			       libcfs_nid2str(sd->sd_dst_nid));
+			       libcfs_nidstr(&sd->sd_dst_nid));
 			rc = -EHOSTUNREACH;
 		}
 	} else {
@@ -2455,7 +2456,7 @@ struct lnet_ni *
 			 * a response to the provided final destination
 			 */
 			CERROR("Can't send response to %s. No local NI available\n",
-			       libcfs_nid2str(sd->sd_dst_nid));
+			       libcfs_nidstr(&sd->sd_dst_nid));
 			return -EHOSTUNREACH;
 		}
 
@@ -2473,7 +2474,8 @@ struct lnet_ni *
 					lnet_msg_discovery(sd->sd_msg));
 	if (sd->sd_best_ni) {
 		sd->sd_best_lpni =
-		  lnet_find_best_lpni(sd->sd_best_ni, sd->sd_dst_nid,
+		  lnet_find_best_lpni(sd->sd_best_ni,
+				      lnet_nid_to_nid4(&sd->sd_dst_nid),
 				      sd->sd_peer,
 				      sd->sd_best_ni->ni_net->net_id);
 
@@ -2501,8 +2503,8 @@ struct lnet_ni *
 		}
 
 		CERROR("Internal Error. Expected to have a best_lpni: %s -> %s\n",
-		       libcfs_nid2str(sd->sd_src_nid),
-		       libcfs_nid2str(sd->sd_dst_nid));
+		       libcfs_nidstr(&sd->sd_src_nid),
+		       libcfs_nidstr(&sd->sd_dst_nid));
 
 		return -EFAULT;
 	}
@@ -2544,11 +2546,11 @@ struct lnet_ni *
 		struct lnet_peer_ni *gw;
 		struct lnet_peer *gw_peer;
 
-		rc = lnet_handle_find_routed_path(sd, sd->sd_dst_nid, &gw,
+		rc = lnet_handle_find_routed_path(sd, &sd->sd_dst_nid, &gw,
 						  &gw_peer);
 		if (rc < 0) {
 			CERROR("Can't send response to %s. No route available\n",
-			       libcfs_nid2str(sd->sd_dst_nid));
+			       libcfs_nidstr(&sd->sd_dst_nid));
 			return -EHOSTUNREACH;
 		} else if (rc > 0) {
 			return rc;
@@ -2577,8 +2579,8 @@ struct lnet_ni *
 	 * need to select the destination which we can route to and if
 	 * there are multiple, we need to round robin.
 	 */
-	rc = lnet_handle_find_routed_path(sd, sd->sd_dst_nid, &gw_lpni,
-					  &gw_peer);
+	rc = lnet_handle_find_routed_path(sd, &sd->sd_dst_nid,
+					  &gw_lpni, &gw_peer);
 	if (rc)
 		return rc;
 
@@ -2613,7 +2615,7 @@ struct lnet_ni *
 	/* find the router and that'll find the best NI if we didn't find
 	 * it already.
 	 */
-	rc = lnet_handle_find_routed_path(sd, sd->sd_dst_nid, &gw_lpni,
+	rc = lnet_handle_find_routed_path(sd, &sd->sd_dst_nid, &gw_lpni,
 					  &gw_peer);
 	if (rc)
 		return rc;
@@ -2640,9 +2642,9 @@ struct lnet_ni *
 
 	CDEBUG(D_NET, "Source %s%s to %s %s %s destination\n",
 	       (send_case & SRC_SPEC) ? "Specified: " : "ANY",
-	       (send_case & SRC_SPEC) ? libcfs_nid2str(sd->sd_src_nid) : "",
+	       (send_case & SRC_SPEC) ? libcfs_nidstr(&sd->sd_src_nid) : "",
 	       (send_case & MR_DST) ? "MR: " : "NMR: ",
-	       libcfs_nid2str(sd->sd_dst_nid),
+	       libcfs_nidstr(&sd->sd_dst_nid),
 	       (send_case & LOCAL_DST) ? "local" : "routed");
 
 	switch (send_case) {
@@ -2672,8 +2674,10 @@ struct lnet_ni *
 }
 
 static int
-lnet_select_pathway(lnet_nid_t src_nid, lnet_nid_t dst_nid,
-		    struct lnet_msg *msg, lnet_nid_t rtr_nid)
+lnet_select_pathway(struct lnet_nid *src_nid,
+		    struct lnet_nid *dst_nid,
+		    struct lnet_msg *msg,
+		    struct lnet_nid *rtr_nid)
 {
 	struct lnet_peer_ni *lpni;
 	struct lnet_peer *peer;
@@ -2707,7 +2711,7 @@ struct lnet_ni *
 	 */
 	send_data.sd_msg = msg;
 	send_data.sd_cpt = cpt;
-	if (dst_nid == LNET_NID_LO_0) {
+	if (nid_is_lo0(dst_nid)) {
 		rc = lnet_handle_lo_send(&send_data);
 		lnet_net_unlock(cpt);
 		return rc;
@@ -2717,7 +2721,7 @@ struct lnet_ni *
 	 * created due to network traffic. This call will create the
 	 * peer->peer_net->peer_ni tree.
 	 */
-	lpni = lnet_nid2peerni_locked(dst_nid, LNET_NID_ANY, cpt);
+	lpni = lnet_peerni_by_nid_locked(dst_nid, NULL, cpt);
 	if (IS_ERR(lpni)) {
 		lnet_net_unlock(cpt);
 		return PTR_ERR(lpni);
@@ -2730,8 +2734,14 @@ struct lnet_ni *
 	 * continuing the same sequence of messages. Similarly, rtr_nid will
 	 * affect our choice of next hop.
 	 */
-	lnet_nid4_to_nid(src_nid, &msg->msg_src_nid_param);
-	lnet_nid4_to_nid(rtr_nid, &msg->msg_rtr_nid_param);
+	if (src_nid)
+		msg->msg_src_nid_param = *src_nid;
+	else
+		msg->msg_src_nid_param = LNET_ANY_NID;
+	if (rtr_nid)
+		msg->msg_rtr_nid_param = *rtr_nid;
+	else
+		msg->msg_rtr_nid_param = LNET_ANY_NID;
 
 	/* If necessary, perform discovery on the peer that owns this peer_ni.
 	 * Note, this can result in the ownership of this peer_ni changing
@@ -2749,15 +2759,15 @@ struct lnet_ni *
 
 	/* Identify the different send cases
 	 */
-	if (src_nid == LNET_NID_ANY) {
+	if (!src_nid || LNET_NID_IS_ANY(src_nid)) {
 		send_case |= SRC_ANY;
-		if (lnet_get_net_locked(LNET_NIDNET(dst_nid)))
+		if (lnet_get_net_locked(LNET_NID_NET(dst_nid)))
 			send_case |= LOCAL_DST;
 		else
 			send_case |= REMOTE_DST;
 	} else {
 		send_case |= SRC_SPEC;
-		if (LNET_NIDNET(src_nid) == LNET_NIDNET(dst_nid))
+		if (LNET_NID_NET(src_nid) == LNET_NID_NET(dst_nid))
 			send_case |= LOCAL_DST;
 		else
 			send_case |= REMOTE_DST;
@@ -2814,9 +2824,15 @@ struct lnet_ni *
 		send_case |= SND_RESP;
 
 	/* assign parameters to the send_data */
-	send_data.sd_rtr_nid = rtr_nid;
-	send_data.sd_src_nid = src_nid;
-	send_data.sd_dst_nid = dst_nid;
+	if (rtr_nid)
+		send_data.sd_rtr_nid = *rtr_nid;
+	else
+		send_data.sd_rtr_nid = LNET_ANY_NID;
+	if (src_nid)
+		send_data.sd_src_nid = *src_nid;
+	else
+		send_data.sd_src_nid = LNET_ANY_NID;
+	send_data.sd_dst_nid = *dst_nid;
 	send_data.sd_best_lpni = lpni;
 	/* keep a pointer to the final destination in case we're going to
 	 * route, so we'll need to access it later
@@ -2842,16 +2858,12 @@ struct lnet_ni *
 }
 
 int
-lnet_send(lnet_nid_t src_nid, struct lnet_msg *msg, lnet_nid_t rtr_nid)
+lnet_send(struct lnet_nid *src_nid, struct lnet_msg *msg,
+	  struct lnet_nid *rtr_nid)
 {
-	lnet_nid_t dst_nid = lnet_nid_to_nid4(&msg->msg_target.nid);
+	struct lnet_nid *dst_nid = &msg->msg_target.nid;
 	int rc;
 
-	/*
-	 * NB: rtr_nid is set to LNET_NID_ANY for all current use-cases,
-	 * but we might want to use pre-determined router for ACK/REPLY
-	 * in the future
-	 */
 	/* NB: !ni == interface pre-determined (ACK/REPLY) */
 	LASSERT(!msg->msg_txpeer);
 	LASSERT(!msg->msg_txni);
@@ -3112,9 +3124,8 @@ struct lnet_mt_event_info {
 			       lnet_msgtyp2str(msg->msg_type),
 			       msg->msg_recovery,
 			       msg->msg_retry_count);
-			rc = lnet_send(lnet_nid_to_nid4(&msg->msg_src_nid_param),
-				       msg,
-				       lnet_nid_to_nid4(&msg->msg_rtr_nid_param));
+			rc = lnet_send(&msg->msg_src_nid_param, msg,
+				       &msg->msg_rtr_nid_param);
 			if (rc) {
 				CERROR("Error sending %s to %s: %d\n",
 				       lnet_msgtyp2str(msg->msg_type),
@@ -4023,9 +4034,7 @@ void lnet_monitor_thr_stop(void)
 	lnet_ni_recv(ni, msg->msg_private, NULL, 0, 0, 0, 0);
 	msg->msg_receiving = 0;
 
-	/* FIXME need to handle large-addr nid */
-	rc = lnet_send(lnet_nid_to_nid4(&ni->ni_nid), msg,
-		       lnet_nid_to_nid4(&msg->msg_from));
+	rc = lnet_send(&ni->ni_nid, msg, &msg->msg_from);
 	if (rc < 0) {
 		/* didn't get as far as lnet_ni_send() */
 		CERROR("%s: Unable to send REPLY for GET from %s: %d\n",
@@ -4706,7 +4715,7 @@ void lnet_monitor_thr_stop(void)
  * \see lnet_event::hdr_data and lnet_event_kind.
  */
 int
-LNetPut(lnet_nid_t self, struct lnet_handle_md mdh, enum lnet_ack_req ack,
+LNetPut(lnet_nid_t self4, struct lnet_handle_md mdh, enum lnet_ack_req ack,
 	struct lnet_process_id target, unsigned int portal,
 	u64 match_bits, unsigned int offset,
 	u64 hdr_data)
@@ -4714,11 +4723,14 @@ void lnet_monitor_thr_stop(void)
 	struct lnet_rsp_tracker *rspt = NULL;
 	struct lnet_msg *msg;
 	struct lnet_libmd *md;
+	struct lnet_nid self;
 	int cpt;
 	int rc;
 
 	LASSERT(the_lnet.ln_refcount > 0);
 
+	lnet_nid4_to_nid(self4, &self);
+
 	if (!list_empty(&the_lnet.ln_test_peers) && /* normally we don't */
 	    fail_peer(target.nid, 1)) { /* shall we now? */
 		CERROR("Dropping PUT to %s: simulated failure\n",
@@ -4803,7 +4815,7 @@ void lnet_monitor_thr_stop(void)
 				 CFS_FAIL_ONCE))
 		rc = -EIO;
 	else
-		rc = lnet_send(self, msg, LNET_NID_ANY);
+		rc = lnet_send(&self, msg, NULL);
 	if (rc) {
 		CNETERR("Error sending PUT to %s: %d\n",
 			libcfs_id2str(target), rc);
@@ -4947,18 +4959,21 @@ struct lnet_msg *
  *		-ENOENT Invalid MD object.
  */
 int
-LNetGet(lnet_nid_t self, struct lnet_handle_md mdh,
+LNetGet(lnet_nid_t self4, struct lnet_handle_md mdh,
 	struct lnet_process_id target, unsigned int portal,
 	u64 match_bits, unsigned int offset, bool recovery)
 {
 	struct lnet_rsp_tracker *rspt;
 	struct lnet_msg *msg;
 	struct lnet_libmd *md;
+	struct lnet_nid self;
 	int cpt;
 	int rc;
 
 	LASSERT(the_lnet.ln_refcount > 0);
 
+	lnet_nid4_to_nid(self4, &self);
+
 	if (!list_empty(&the_lnet.ln_test_peers) && /* normally we don't */
 	    fail_peer(target.nid, 1)) {		/* shall we now? */
 		CERROR("Dropping GET to %s: simulated failure\n",
@@ -5029,7 +5044,7 @@ struct lnet_msg *
 	else
 		lnet_rspt_free(rspt, cpt);
 
-	rc = lnet_send(self, msg, LNET_NID_ANY);
+	rc = lnet_send(&self, msg, NULL);
 	if (rc < 0) {
 		CNETERR("Error sending GET to %s: %d\n",
 			libcfs_id2str(target), rc);
diff --git a/net/lnet/lnet/lib-msg.c b/net/lnet/lnet/lib-msg.c
index 980f93d..f432488 100644
--- a/net/lnet/lnet/lib-msg.c
+++ b/net/lnet/lnet/lib-msg.c
@@ -379,6 +379,7 @@
 
 	if (!status && msg->msg_ack) {
 		/* Only send an ACK if the PUT completed successfully */
+		struct lnet_nid src;
 
 		lnet_msg_decommit(msg, cpt, 0);
 
@@ -396,8 +397,8 @@
 		msg->msg_hdr.msg.ack.match_bits = msg->msg_ev.match_bits;
 		msg->msg_hdr.msg.ack.mlength = cpu_to_le32(msg->msg_ev.mlength);
 
-		rc = lnet_send(msg->msg_ev.target.nid, msg,
-			       lnet_nid_to_nid4(&msg->msg_from));
+		lnet_nid4_to_nid(msg->msg_ev.target.nid, &src);
+		rc = lnet_send(&src, msg, &msg->msg_from);
 
 		lnet_net_lock(cpt);
 		/*
@@ -419,7 +420,7 @@
 		LASSERT(!msg->msg_receiving);	/* called back recv already */
 		lnet_net_unlock(cpt);
 
-		rc = lnet_send(LNET_NID_ANY, msg, LNET_NID_ANY);
+		rc = lnet_send(NULL, msg, NULL);
 
 		lnet_net_lock(cpt);
 		/*
diff --git a/net/lnet/lnet/peer.c b/net/lnet/lnet/peer.c
index 9cb06d2..505065f 100644
--- a/net/lnet/lnet/peer.c
+++ b/net/lnet/lnet/peer.c
@@ -2296,8 +2296,8 @@ static void lnet_peer_discovery_complete(struct lnet_peer *lp, int dc_error)
 		CDEBUG(D_NET, "sending pending message %s to target %s\n",
 		       lnet_msgtyp2str(msg->msg_type),
 		       libcfs_idstr(&msg->msg_target));
-		rc = lnet_send(lnet_nid_to_nid4(&msg->msg_src_nid_param), msg,
-			       lnet_nid_to_nid4(&msg->msg_rtr_nid_param));
+		rc = lnet_send(&msg->msg_src_nid_param, msg,
+			       &msg->msg_rtr_nid_param);
 		if (rc < 0) {
 			CNETERR("Error sending %s to %s: %d\n",
 				lnet_msgtyp2str(msg->msg_type),
@@ -3697,8 +3697,8 @@ static void lnet_resend_msgs(void)
 
 	list_for_each_entry_safe(msg, tmp, &resend, msg_list) {
 		list_del_init(&msg->msg_list);
-		rc = lnet_send(lnet_nid_to_nid4(&msg->msg_src_nid_param), msg,
-			       lnet_nid_to_nid4(&msg->msg_rtr_nid_param));
+		rc = lnet_send(&msg->msg_src_nid_param, msg,
+			       &msg->msg_rtr_nid_param);
 		if (rc < 0) {
 			CNETERR("Error sending %s to %s: %d\n",
 				lnet_msgtyp2str(msg->msg_type),
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
