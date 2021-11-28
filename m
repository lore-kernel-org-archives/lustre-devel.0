Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 9C823C433FE
	for <lustre-devel@archiver.kernel.org>; Sun, 28 Nov 2021 23:28:17 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 2B20D205753;
	Sun, 28 Nov 2021 15:28:11 -0800 (PST)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 93874200EB1
 for <lustre-devel@lists.lustre.org>; Sun, 28 Nov 2021 15:27:59 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 8BE63241;
 Sun, 28 Nov 2021 18:27:56 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 82AB7C1ADA; Sun, 28 Nov 2021 18:27:56 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 28 Nov 2021 18:27:38 -0500
Message-Id: <1638142074-5945-4-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1638142074-5945-1-git-send-email-jsimmons@infradead.org>
References: <1638142074-5945-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 03/19] lnet: extend preferred nids in struct
 lnet_peer_ni
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

union lpni_pref in struct lnet_peer_ni how has 'struct lnet_nid'
rather than lnet_nid_t.

Also, lnet_peer_ni_set_no_mr_pref_nid() allows the pref nid to be NULL
and is a no-op in that case.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10391
Lustre-commit: 47cc77462343533b4 ("LU-10391 lnet: extend prefered nids in struct lnet_peer_ni")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/43596
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Chris Horn <chris.horn@hpe.com>
Reviewed-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/lib-lnet.h    | 25 +++++++----
 include/linux/lnet/lib-types.h   |  4 +-
 include/uapi/linux/lnet/nidstr.h |  3 +-
 net/lnet/lnet/api-ni.c           | 16 +++----
 net/lnet/lnet/lib-move.c         | 58 ++++++++++++------------
 net/lnet/lnet/nidstrings.c       |  9 ++--
 net/lnet/lnet/peer.c             | 95 +++++++++++++++++++++++-----------------
 net/lnet/lnet/udsp.c             | 38 ++++++++--------
 8 files changed, 138 insertions(+), 110 deletions(-)

diff --git a/include/linux/lnet/lib-lnet.h b/include/linux/lnet/lib-lnet.h
index 104c98d..fb2f42fcb 100644
--- a/include/linux/lnet/lib-lnet.h
+++ b/include/linux/lnet/lib-lnet.h
@@ -486,6 +486,7 @@ unsigned int lnet_nid_cpt_hash(struct lnet_nid *nid,
 int lnet_cpt_of_nid(lnet_nid_t nid, struct lnet_ni *ni);
 int lnet_nid2cpt(struct lnet_nid *nid, struct lnet_ni *ni);
 struct lnet_ni *lnet_nid2ni_locked(lnet_nid_t nid, int cpt);
+struct lnet_ni *lnet_nid_to_ni_locked(struct lnet_nid *nid, int cpt);
 struct lnet_ni *lnet_nid2ni_addref(lnet_nid_t nid);
 struct lnet_ni *lnet_net2ni_locked(u32 net, int cpt);
 struct lnet_ni *lnet_net2ni_addref(u32 net);
@@ -538,9 +539,11 @@ int lnet_get_peer_list(u32 *countp, u32 *sizep,
 extern void lnet_peer_ni_add_to_recoveryq_locked(struct lnet_peer_ni *lpni,
 						 struct list_head *queue,
 						 time64_t now);
-extern int lnet_peer_add_pref_nid(struct lnet_peer_ni *lpni, lnet_nid_t nid);
+extern int lnet_peer_add_pref_nid(struct lnet_peer_ni *lpni,
+				  struct lnet_nid *nid);
 extern void lnet_peer_clr_pref_nids(struct lnet_peer_ni *lpni);
-extern int lnet_peer_del_pref_nid(struct lnet_peer_ni *lpni, lnet_nid_t nid);
+extern int lnet_peer_del_pref_nid(struct lnet_peer_ni *lpni,
+				  struct lnet_nid *nid);
 void lnet_peer_ni_set_selection_priority(struct lnet_peer_ni *lpni,
 					 u32 priority);
 extern void lnet_ni_add_to_recoveryq_locked(struct lnet_ni *ni,
@@ -565,7 +568,7 @@ void lnet_rtr_transfer_to_peer(struct lnet_peer *src,
 int lnet_clear_lazy_portal(struct lnet_ni *ni, int portal, char *reason);
 struct lnet_net *lnet_get_net_locked(u32 net_id);
 void lnet_net_clr_pref_rtrs(struct lnet_net *net);
-int lnet_net_add_pref_rtr(struct lnet_net *net, lnet_nid_t gw_nid);
+int lnet_net_add_pref_rtr(struct lnet_net *net, struct lnet_nid *gw_nid);
 
 int lnet_islocalnid4(lnet_nid_t nid);
 int lnet_islocalnid(struct lnet_nid *nid);
@@ -838,6 +841,9 @@ struct lnet_peer_ni *lnet_get_next_peer_ni_locked(struct lnet_peer *peer,
 						  struct lnet_peer_ni *prev);
 struct lnet_peer_ni *lnet_nid2peerni_locked(lnet_nid_t nid, lnet_nid_t pref,
 					    int cpt);
+struct lnet_peer_ni *lnet_peerni_by_nid_locked(struct lnet_nid *nid,
+					       struct lnet_nid *pref,
+					       int cpt);
 struct lnet_peer_ni *lnet_nid2peerni_ex(struct lnet_nid *nid, int cpt);
 struct lnet_peer_ni *lnet_peer_get_ni_locked(struct lnet_peer *lp,
 					     lnet_nid_t nid);
@@ -859,13 +865,16 @@ struct lnet_peer_ni *lnet_peer_ni_get_locked(struct lnet_peer *lp,
 void lnet_debug_peer(lnet_nid_t nid);
 struct lnet_peer_net *lnet_peer_get_net_locked(struct lnet_peer *peer,
 					       u32 net_id);
-bool lnet_peer_is_pref_nid_locked(struct lnet_peer_ni *lpni, lnet_nid_t nid);
-int lnet_peer_add_pref_nid(struct lnet_peer_ni *lpni, lnet_nid_t nid);
+bool lnet_peer_is_pref_nid_locked(struct lnet_peer_ni *lpni,
+				  struct lnet_nid *nid);
+int lnet_peer_add_pref_nid(struct lnet_peer_ni *lpni, struct lnet_nid *nid);
 void lnet_peer_clr_pref_nids(struct lnet_peer_ni *lpni);
-bool lnet_peer_is_pref_rtr_locked(struct lnet_peer_ni *lpni, lnet_nid_t gw_nid);
+bool lnet_peer_is_pref_rtr_locked(struct lnet_peer_ni *lpni,
+				  struct lnet_nid *gw_nid);
 void lnet_peer_clr_pref_rtrs(struct lnet_peer_ni *lpni);
-int lnet_peer_add_pref_rtr(struct lnet_peer_ni *lpni, lnet_nid_t nid);
-int lnet_peer_ni_set_non_mr_pref_nid(struct lnet_peer_ni *lpni, lnet_nid_t nid);
+int lnet_peer_add_pref_rtr(struct lnet_peer_ni *lpni, struct lnet_nid *nid);
+int lnet_peer_ni_set_non_mr_pref_nid(struct lnet_peer_ni *lpni,
+				     struct lnet_nid *nid);
 int lnet_add_peer_ni(lnet_nid_t key_nid, lnet_nid_t nid, bool mr, bool temp);
 int lnet_del_peer_ni(lnet_nid_t key_nid, lnet_nid_t nid);
 int lnet_get_peer_info(struct lnet_ioctl_peer_cfg *cfg, void __user *bulk);
diff --git a/include/linux/lnet/lib-types.h b/include/linux/lnet/lib-types.h
index 1901ad2..bde7249 100644
--- a/include/linux/lnet/lib-types.h
+++ b/include/linux/lnet/lib-types.h
@@ -568,7 +568,7 @@ struct lnet_ping_buffer {
 
 struct lnet_nid_list {
 	struct list_head nl_list;
-	lnet_nid_t nl_nid;
+	struct lnet_nid nl_nid;
 };
 
 struct lnet_peer_ni {
@@ -635,7 +635,7 @@ struct lnet_peer_ni {
 	time64_t		lpni_last_alive;
 	/* preferred local nids: if only one, use lpni_pref.nid */
 	union lpni_pref {
-		lnet_nid_t	 nid;
+		struct lnet_nid	nid;
 		struct list_head nids;
 	} lpni_pref;
 	/* list of router nids preferred for this peer NI */
diff --git a/include/uapi/linux/lnet/nidstr.h b/include/uapi/linux/lnet/nidstr.h
index bfc9644..482cfb2 100644
--- a/include/uapi/linux/lnet/nidstr.h
+++ b/include/uapi/linux/lnet/nidstr.h
@@ -108,7 +108,8 @@ static inline char *libcfs_nidstr(const struct lnet_nid *nid)
 int cfs_parse_nidlist(char *str, int len, struct list_head *list);
 int cfs_print_nidlist(char *buffer, int count, struct list_head *list);
 int cfs_match_nid(lnet_nid_t nid, struct list_head *list);
-int cfs_match_nid_net(lnet_nid_t nid, __u32 net, struct list_head *net_num_list,
+int cfs_match_nid_net(struct lnet_nid *nid, __u32 net,
+		       struct list_head *net_num_list,
 		      struct list_head *addr);
 int cfs_match_net(__u32 net_id, __u32 net_type,
 		  struct list_head *net_num_list);
diff --git a/net/lnet/lnet/api-ni.c b/net/lnet/lnet/api-ni.c
index 0f4feda..340cc84e 100644
--- a/net/lnet/lnet/api-ni.c
+++ b/net/lnet/lnet/api-ni.c
@@ -1388,7 +1388,7 @@ struct lnet_net *
 
 int
 lnet_net_add_pref_rtr(struct lnet_net *net,
-		      lnet_nid_t gw_nid)
+		      struct lnet_nid *gw_nid)
 __must_hold(&the_lnet.ln_api_mutex)
 {
 	struct lnet_nid_list *ne;
@@ -1399,7 +1399,7 @@ struct lnet_net *
 	 * lock.
 	 */
 	list_for_each_entry(ne, &net->net_rtr_pref_nids, nl_list) {
-		if (ne->nl_nid == gw_nid)
+		if (nid_same(&ne->nl_nid, gw_nid))
 			return -EEXIST;
 	}
 
@@ -1407,7 +1407,7 @@ struct lnet_net *
 	if (!ne)
 		return -ENOMEM;
 
-	ne->nl_nid = gw_nid;
+	ne->nl_nid = *gw_nid;
 
 	/* Lock the cpt to protect against addition and checks in the
 	 * selection algorithm
@@ -1420,11 +1420,11 @@ struct lnet_net *
 }
 
 bool
-lnet_net_is_pref_rtr_locked(struct lnet_net *net, lnet_nid_t rtr_nid)
+lnet_net_is_pref_rtr_locked(struct lnet_net *net, struct lnet_nid *rtr_nid)
 {
 	struct lnet_nid_list *ne;
 
-	CDEBUG(D_NET, "%s: rtr pref emtpy: %d\n",
+	CDEBUG(D_NET, "%s: rtr pref empty: %d\n",
 	       libcfs_net2str(net->net_id),
 	       list_empty(&net->net_rtr_pref_nids));
 
@@ -1433,9 +1433,9 @@ struct lnet_net *
 
 	list_for_each_entry(ne, &net->net_rtr_pref_nids, nl_list) {
 		CDEBUG(D_NET, "Comparing pref %s with gw %s\n",
-		       libcfs_nid2str(ne->nl_nid),
-		       libcfs_nid2str(rtr_nid));
-		if (rtr_nid == ne->nl_nid)
+		       libcfs_nidstr(&ne->nl_nid),
+		       libcfs_nidstr(rtr_nid));
+		if (nid_same(rtr_nid, &ne->nl_nid))
 			return true;
 	}
 
diff --git a/net/lnet/lnet/lib-move.c b/net/lnet/lnet/lib-move.c
index b9f5973..2f7c37d 100644
--- a/net/lnet/lnet/lib-move.c
+++ b/net/lnet/lnet/lib-move.c
@@ -1137,9 +1137,8 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 		 * preferred, then let's use it
 		 */
 		if (best_ni) {
-			/* FIXME need to handle large-addr nid */
 			lpni_is_preferred = lnet_peer_is_pref_nid_locked(lpni,
-									 lnet_nid_to_nid4(&best_ni->ni_nid));
+									 &best_ni->ni_nid);
 			CDEBUG(D_NET, "%s lpni_is_preferred = %d\n",
 			       libcfs_nidstr(&best_ni->ni_nid),
 			       lpni_is_preferred);
@@ -1318,7 +1317,7 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 	struct lnet_route *route;
 	int rc;
 	bool best_rte_is_preferred = false;
-	lnet_nid_t gw_pnid;
+	struct lnet_nid *gw_pnid;
 
 	CDEBUG(D_NET, "Looking up a route to %s, from %s\n",
 	       libcfs_net2str(rnet->lrn_net), libcfs_net2str(src_net));
@@ -1328,7 +1327,7 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 	list_for_each_entry(route, &rnet->lrn_routes, lr_list) {
 		if (!lnet_is_route_alive(route))
 			continue;
-		gw_pnid = lnet_nid_to_nid4(&route->lr_gateway->lp_primary_nid);
+		gw_pnid = &route->lr_gateway->lp_primary_nid;
 
 		/* no protection on below fields, but it's harmless */
 		if (last_route && (last_route->lr_seq - route->lr_seq < 0))
@@ -1352,7 +1351,7 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 			if (!lpni) {
 				CDEBUG(D_NET,
 				       "Gateway %s does not have a peer NI on net %s\n",
-				       libcfs_nid2str(gw_pnid),
+				       libcfs_nidstr(gw_pnid),
 				       libcfs_net2str(src_net));
 				continue;
 			}
@@ -1368,7 +1367,7 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 			best_gw_ni = lpni;
 			best_rte_is_preferred = true;
 			CDEBUG(D_NET, "preferred gw = %s\n",
-			       libcfs_nid2str(gw_pnid));
+			       libcfs_nidstr(gw_pnid));
 			continue;
 		} else if ((!rc) && best_rte_is_preferred)
 			/* The best route we found so far is in the preferred
@@ -1397,7 +1396,7 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 		if (!lpni) {
 			CDEBUG(D_NET,
 			       "Gateway %s does not have a peer NI on net %s\n",
-			       libcfs_nid2str(gw_pnid),
+			       libcfs_nidstr(gw_pnid),
 			       libcfs_net2str(src_net));
 			continue;
 		}
@@ -1789,8 +1788,7 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 		CDEBUG(D_NET, "Setting preferred local NID %s on NMR peer %s\n",
 		       libcfs_nidstr(&lni->ni_nid),
 		       libcfs_nidstr(&lpni->lpni_nid));
-		lnet_peer_ni_set_non_mr_pref_nid(lpni,
-						 lnet_nid_to_nid4(&lni->ni_nid));
+		lnet_peer_ni_set_non_mr_pref_nid(lpni, &lni->ni_nid);
 	}
 }
 
@@ -2314,7 +2312,8 @@ struct lnet_ni *
 		if (lpni_entry->lpni_pref_nnids == 0)
 			continue;
 		LASSERT(lpni_entry->lpni_pref_nnids == 1);
-		best_ni = lnet_nid2ni_locked(lpni_entry->lpni_pref.nid, cpt);
+		best_ni = lnet_nid_to_ni_locked(&lpni_entry->lpni_pref.nid,
+						cpt);
 		break;
 	}
 
@@ -4208,7 +4207,7 @@ void lnet_monitor_thr_stop(void)
 }
 
 int
-lnet_parse(struct lnet_ni *ni, struct lnet_hdr *hdr, lnet_nid_t from_nid,
+lnet_parse(struct lnet_ni *ni, struct lnet_hdr *hdr, lnet_nid_t from_nid4,
 	   void *private, int rdma_req)
 {
 	struct lnet_peer_ni *lpni;
@@ -4217,6 +4216,7 @@ void lnet_monitor_thr_stop(void)
 	lnet_pid_t dest_pid;
 	lnet_nid_t dest_nid;
 	lnet_nid_t src_nid;
+	struct lnet_nid from_nid;
 	bool push = false;
 	int for_me;
 	u32 type;
@@ -4225,6 +4225,8 @@ void lnet_monitor_thr_stop(void)
 
 	LASSERT(!in_interrupt());
 
+	lnet_nid4_to_nid(from_nid4, &from_nid);
+
 	type = le32_to_cpu(hdr->type);
 	src_nid = le64_to_cpu(hdr->src_nid);
 	dest_nid = le64_to_cpu(hdr->dest_nid);
@@ -4233,7 +4235,7 @@ void lnet_monitor_thr_stop(void)
 
 	/* FIXME handle large-addr nids */
 	for_me = (lnet_nid_to_nid4(&ni->ni_nid) == dest_nid);
-	cpt = lnet_cpt_of_nid(from_nid, ni);
+	cpt = lnet_cpt_of_nid(from_nid4, ni);
 
 	CDEBUG(D_NET, "TRACE: %s(%s) <- %s : %s\n",
 	       libcfs_nid2str(dest_nid),
@@ -4246,7 +4248,7 @@ void lnet_monitor_thr_stop(void)
 	case LNET_MSG_GET:
 		if (payload_length > 0) {
 			CERROR("%s, src %s: bad %s payload %d (0 expected)\n",
-			       libcfs_nid2str(from_nid),
+			       libcfs_nid2str(from_nid4),
 			       libcfs_nid2str(src_nid),
 			       lnet_msgtyp2str(type), payload_length);
 			return -EPROTO;
@@ -4258,7 +4260,7 @@ void lnet_monitor_thr_stop(void)
 		if (payload_length >
 		   (u32)(for_me ? LNET_MAX_PAYLOAD : LNET_MTU)) {
 			CERROR("%s, src %s: bad %s payload %d (%d max expected)\n",
-			       libcfs_nid2str(from_nid),
+			       libcfs_nid2str(from_nid4),
 			       libcfs_nid2str(src_nid),
 			       lnet_msgtyp2str(type),
 			       payload_length,
@@ -4269,7 +4271,7 @@ void lnet_monitor_thr_stop(void)
 
 	default:
 		CERROR("%s, src %s: Bad message type 0x%x\n",
-		       libcfs_nid2str(from_nid),
+		       libcfs_nid2str(from_nid4),
 		       libcfs_nid2str(src_nid), type);
 		return -EPROTO;
 	}
@@ -4296,7 +4298,7 @@ void lnet_monitor_thr_stop(void)
 		if (LNET_NIDNET(dest_nid) == LNET_NID_NET(&ni->ni_nid)) {
 			/* should have gone direct */
 			CERROR("%s, src %s: Bad dest nid %s (should have been sent direct)\n",
-			       libcfs_nid2str(from_nid),
+			       libcfs_nid2str(from_nid4),
 			       libcfs_nid2str(src_nid),
 			       libcfs_nid2str(dest_nid));
 			return -EPROTO;
@@ -4308,7 +4310,7 @@ void lnet_monitor_thr_stop(void)
 			 * this node's NID on its own network
 			 */
 			CERROR("%s, src %s: Bad dest nid %s (it's my nid but on a different network)\n",
-			       libcfs_nid2str(from_nid),
+			       libcfs_nid2str(from_nid4),
 			       libcfs_nid2str(src_nid),
 			       libcfs_nid2str(dest_nid));
 			return -EPROTO;
@@ -4316,7 +4318,7 @@ void lnet_monitor_thr_stop(void)
 
 		if (rdma_req && type == LNET_MSG_GET) {
 			CERROR("%s, src %s: Bad optimized GET for %s (final destination must be me)\n",
-			       libcfs_nid2str(from_nid),
+			       libcfs_nid2str(from_nid4),
 			       libcfs_nid2str(src_nid),
 			       libcfs_nid2str(dest_nid));
 			return -EPROTO;
@@ -4324,7 +4326,7 @@ void lnet_monitor_thr_stop(void)
 
 		if (!the_lnet.ln_routing) {
 			CERROR("%s, src %s: Dropping message for %s (routing not enabled)\n",
-			       libcfs_nid2str(from_nid),
+			       libcfs_nid2str(from_nid4),
 			       libcfs_nid2str(src_nid),
 			       libcfs_nid2str(dest_nid));
 			goto drop;
@@ -4338,7 +4340,7 @@ void lnet_monitor_thr_stop(void)
 	if (!list_empty(&the_lnet.ln_test_peers) && /* normally we don't */
 	    fail_peer(src_nid, 0)) {		/* shall we now? */
 		CERROR("%s, src %s: Dropping %s to simulate failure\n",
-		       libcfs_nid2str(from_nid), libcfs_nid2str(src_nid),
+		       libcfs_nid2str(from_nid4), libcfs_nid2str(src_nid),
 		       lnet_msgtyp2str(type));
 		goto drop;
 	}
@@ -4347,7 +4349,7 @@ void lnet_monitor_thr_stop(void)
 	if (!list_empty(&the_lnet.ln_drop_rules) &&
 	    lnet_drop_rule_match(hdr, lnet_nid_to_nid4(&ni->ni_nid), NULL)) {
 		CDEBUG(D_NET, "%s, src %s, dst %s: Dropping %s to simulate silent message loss\n",
-		       libcfs_nid2str(from_nid), libcfs_nid2str(src_nid),
+		       libcfs_nid2str(from_nid4), libcfs_nid2str(src_nid),
 		       libcfs_nid2str(dest_nid), lnet_msgtyp2str(type));
 		goto drop;
 	}
@@ -4355,7 +4357,7 @@ void lnet_monitor_thr_stop(void)
 	msg = kmem_cache_zalloc(lnet_msg_cachep, GFP_NOFS);
 	if (!msg) {
 		CERROR("%s, src %s: Dropping %s (out of memory)\n",
-		       libcfs_nid2str(from_nid), libcfs_nid2str(src_nid),
+		       libcfs_nid2str(from_nid4), libcfs_nid2str(src_nid),
 		       lnet_msgtyp2str(type));
 		goto drop;
 	}
@@ -4372,7 +4374,7 @@ void lnet_monitor_thr_stop(void)
 	msg->msg_offset = 0;
 	msg->msg_hdr = *hdr;
 	/* for building message event */
-	msg->msg_from = from_nid;
+	msg->msg_from = from_nid4;
 	if (!for_me) {
 		msg->msg_target.pid = dest_pid;
 		msg->msg_target.nid = dest_nid;
@@ -4388,14 +4390,12 @@ void lnet_monitor_thr_stop(void)
 	}
 
 	lnet_net_lock(cpt);
-	/* FIXME support large-addr nid */
-	lpni = lnet_nid2peerni_locked(from_nid, lnet_nid_to_nid4(&ni->ni_nid),
-				      cpt);
+	lpni = lnet_peerni_by_nid_locked(&from_nid, &ni->ni_nid, cpt);
 	if (IS_ERR(lpni)) {
 		lnet_net_unlock(cpt);
 		rc = PTR_ERR(lpni);
 		CERROR("%s, src %s: Dropping %s (error %d looking up sender)\n",
-		       libcfs_nid2str(from_nid), libcfs_nid2str(src_nid),
+		       libcfs_nid2str(from_nid4), libcfs_nid2str(src_nid),
 		       lnet_msgtyp2str(type), rc);
 		kfree(msg);
 		if (rc == -ESHUTDOWN)
@@ -4410,7 +4410,7 @@ void lnet_monitor_thr_stop(void)
 	 */
 	if (((lnet_drop_asym_route && for_me) ||
 	     !lpni->lpni_peer_net->lpn_peer->lp_alive) &&
-	    LNET_NIDNET(src_nid) != LNET_NIDNET(from_nid)) {
+	    LNET_NIDNET(src_nid) != LNET_NIDNET(from_nid4)) {
 		u32 src_net_id = LNET_NIDNET(src_nid);
 		struct lnet_peer *gw = lpni->lpni_peer_net->lpn_peer;
 		struct lnet_route *route;
@@ -4445,7 +4445,7 @@ void lnet_monitor_thr_stop(void)
 			 * => asymmetric routing detected but forbidden
 			 */
 			CERROR("%s, src %s: Dropping asymmetrical route %s\n",
-			       libcfs_nid2str(from_nid),
+			       libcfs_nid2str(from_nid4),
 			       libcfs_nid2str(src_nid), lnet_msgtyp2str(type));
 			kfree(msg);
 			goto drop;
diff --git a/net/lnet/lnet/nidstrings.c b/net/lnet/lnet/nidstrings.c
index d91815d..dfd6744 100644
--- a/net/lnet/lnet/nidstrings.c
+++ b/net/lnet/lnet/nidstrings.c
@@ -803,7 +803,7 @@ int cfs_print_nidlist(char *buffer, int count, struct list_head *nidlist)
 }
 
 int
-cfs_match_nid_net(lnet_nid_t nid, u32 net_type,
+cfs_match_nid_net(struct lnet_nid *nid, u32 net_type,
 		  struct list_head *net_num_list,
 		  struct list_head *addr)
 {
@@ -813,15 +813,16 @@ int cfs_print_nidlist(char *buffer, int count, struct list_head *nidlist)
 	if (!addr || !net_num_list)
 		return 0;
 
-	nf = type2net_info(LNET_NETTYP(LNET_NIDNET(nid)));
+	nf = type2net_info(LNET_NETTYP(LNET_NID_NET(nid)));
 	if (!nf || !net_num_list || !addr)
 		return 0;
 
-	address = LNET_NIDADDR(nid);
+	/* FIXME handle long-addr nid */
+	address = LNET_NIDADDR(lnet_nid_to_nid4(nid));
 
 	/* if either the address or net number don't match then no match */
 	if (!nf->nf_match_addr(address, addr) ||
-	    !cfs_match_net(LNET_NIDNET(nid), net_type, net_num_list))
+	    !cfs_match_net(LNET_NID_NET(nid), net_type, net_num_list))
 		return 0;
 
 	return 1;
diff --git a/net/lnet/lnet/peer.c b/net/lnet/lnet/peer.c
index 4b6f339..1853388 100644
--- a/net/lnet/lnet/peer.c
+++ b/net/lnet/lnet/peer.c
@@ -990,7 +990,7 @@ struct lnet_peer_ni *
  */
 bool
 lnet_peer_is_pref_rtr_locked(struct lnet_peer_ni *lpni,
-			     lnet_nid_t gw_nid)
+			     struct lnet_nid *gw_nid)
 {
 	struct lnet_nid_list *ne;
 
@@ -1006,9 +1006,9 @@ struct lnet_peer_ni *
 	 */
 	list_for_each_entry(ne, &lpni->lpni_rtr_pref_nids, nl_list) {
 		CDEBUG(D_NET, "Comparing pref %s with gw %s\n",
-		       libcfs_nid2str(ne->nl_nid),
-		       libcfs_nid2str(gw_nid));
-		if (ne->nl_nid == gw_nid)
+		       libcfs_nidstr(&ne->nl_nid),
+		       libcfs_nidstr(gw_nid));
+		if (nid_same(&ne->nl_nid, gw_nid))
 			return true;
 	}
 
@@ -1037,7 +1037,7 @@ struct lnet_peer_ni *
 
 int
 lnet_peer_add_pref_rtr(struct lnet_peer_ni *lpni,
-		       lnet_nid_t gw_nid)
+		       struct lnet_nid *gw_nid)
 {
 	int cpt = lpni->lpni_cpt;
 	struct lnet_nid_list *ne = NULL;
@@ -1050,7 +1050,7 @@ struct lnet_peer_ni *
 	__must_hold(&the_lnet.ln_api_mutex);
 
 	list_for_each_entry(ne, &lpni->lpni_rtr_pref_nids, nl_list) {
-		if (ne->nl_nid == gw_nid)
+		if (nid_same(&ne->nl_nid, gw_nid))
 			return -EEXIST;
 	}
 
@@ -1058,7 +1058,7 @@ struct lnet_peer_ni *
 	if (!ne)
 		return -ENOMEM;
 
-	ne->nl_nid = gw_nid;
+	ne->nl_nid = *gw_nid;
 
 	/* Lock the cpt to protect against addition and checks in the
 	 * selection algorithm
@@ -1076,16 +1076,16 @@ struct lnet_peer_ni *
  * shared mmode.
  */
 bool
-lnet_peer_is_pref_nid_locked(struct lnet_peer_ni *lpni, lnet_nid_t nid)
+lnet_peer_is_pref_nid_locked(struct lnet_peer_ni *lpni, struct lnet_nid *nid)
 {
 	struct lnet_nid_list *ne;
 
 	if (lpni->lpni_pref_nnids == 0)
 		return false;
 	if (lpni->lpni_pref_nnids == 1)
-		return lpni->lpni_pref.nid == nid;
+		return nid_same(&lpni->lpni_pref.nid, nid);
 	list_for_each_entry(ne, &lpni->lpni_pref.nids, nl_list) {
-		if (ne->nl_nid == nid)
+		if (nid_same(&ne->nl_nid, nid))
 			return true;
 	}
 	return false;
@@ -1096,24 +1096,27 @@ struct lnet_peer_ni *
  * defined. Only to be used for non-multi-rail peer_ni.
  */
 int
-lnet_peer_ni_set_non_mr_pref_nid(struct lnet_peer_ni *lpni, lnet_nid_t nid)
+lnet_peer_ni_set_non_mr_pref_nid(struct lnet_peer_ni *lpni,
+				 struct lnet_nid *nid)
 {
 	int rc = 0;
 
+	if (!nid)
+		return -EINVAL;
 	spin_lock(&lpni->lpni_lock);
-	if (nid == LNET_NID_ANY) {
+	if (LNET_NID_IS_ANY(nid)) {
 		rc = -EINVAL;
 	} else if (lpni->lpni_pref_nnids > 0) {
 		rc = -EPERM;
 	} else if (lpni->lpni_pref_nnids == 0) {
-		lpni->lpni_pref.nid = nid;
+		lpni->lpni_pref.nid = *nid;
 		lpni->lpni_pref_nnids = 1;
 		lpni->lpni_state |= LNET_PEER_NI_NON_MR_PREF;
 	}
 	spin_unlock(&lpni->lpni_lock);
 
 	CDEBUG(D_NET, "peer %s nid %s: %d\n",
-	       libcfs_nidstr(&lpni->lpni_nid), libcfs_nid2str(nid), rc);
+	       libcfs_nidstr(&lpni->lpni_nid), libcfs_nidstr(nid), rc);
 	return rc;
 }
 
@@ -1161,20 +1164,21 @@ struct lnet_peer_ni *
 }
 
 int
-lnet_peer_add_pref_nid(struct lnet_peer_ni *lpni, lnet_nid_t nid)
+lnet_peer_add_pref_nid(struct lnet_peer_ni *lpni, struct lnet_nid *nid)
 {
 	struct lnet_peer *lp = lpni->lpni_peer_net->lpn_peer;
 	struct lnet_nid_list *ne1 = NULL;
 	struct lnet_nid_list *ne2 = NULL;
-	lnet_nid_t tmp_nid = LNET_NID_ANY;
+	struct lnet_nid *tmp_nid = NULL;
 	int rc = 0;
 
-	if (nid == LNET_NID_ANY) {
+	if (LNET_NID_IS_ANY(nid)) {
 		rc = -EINVAL;
 		goto out;
 	}
 
-	if (lpni->lpni_pref_nnids == 1 && lpni->lpni_pref.nid == nid) {
+	if (lpni->lpni_pref_nnids == 1 &&
+	    nid_same(&lpni->lpni_pref.nid, nid)) {
 		rc = -EEXIST;
 		goto out;
 	}
@@ -1191,12 +1195,12 @@ struct lnet_peer_ni *
 		size_t alloc_size = sizeof(*ne1);
 
 		if (lpni->lpni_pref_nnids == 1) {
-			tmp_nid = lpni->lpni_pref.nid;
+			tmp_nid = &lpni->lpni_pref.nid;
 			INIT_LIST_HEAD(&lpni->lpni_pref.nids);
 		}
 
 		list_for_each_entry(ne1, &lpni->lpni_pref.nids, nl_list) {
-			if (ne1->nl_nid == nid) {
+			if (nid_same(&ne1->nl_nid, nid)) {
 				rc = -EEXIST;
 				goto out;
 			}
@@ -1217,15 +1221,15 @@ struct lnet_peer_ni *
 				goto out;
 			}
 			INIT_LIST_HEAD(&ne2->nl_list);
-			ne2->nl_nid = tmp_nid;
+			ne2->nl_nid = *tmp_nid;
 		}
-		ne1->nl_nid = nid;
+		ne1->nl_nid = *nid;
 	}
 
 	lnet_net_lock(LNET_LOCK_EX);
 	spin_lock(&lpni->lpni_lock);
 	if (lpni->lpni_pref_nnids == 0) {
-		lpni->lpni_pref.nid = nid;
+		lpni->lpni_pref.nid = *nid;
 	} else {
 		if (ne2)
 			list_add_tail(&ne2->nl_list, &lpni->lpni_pref.nids);
@@ -1243,12 +1247,12 @@ struct lnet_peer_ni *
 		spin_unlock(&lpni->lpni_lock);
 	}
 	CDEBUG(D_NET, "peer %s nid %s: %d\n",
-	       libcfs_nidstr(&lp->lp_primary_nid), libcfs_nid2str(nid), rc);
+	       libcfs_nidstr(&lp->lp_primary_nid), libcfs_nidstr(nid), rc);
 	return rc;
 }
 
 int
-lnet_peer_del_pref_nid(struct lnet_peer_ni *lpni, lnet_nid_t nid)
+lnet_peer_del_pref_nid(struct lnet_peer_ni *lpni, struct lnet_nid *nid)
 {
 	struct lnet_peer *lp = lpni->lpni_peer_net->lpn_peer;
 	struct lnet_nid_list *ne = NULL;
@@ -1260,13 +1264,13 @@ struct lnet_peer_ni *
 	}
 
 	if (lpni->lpni_pref_nnids == 1) {
-		if (lpni->lpni_pref.nid != nid) {
+		if (!nid_same(&lpni->lpni_pref.nid, nid)) {
 			rc = -ENOENT;
 			goto out;
 		}
 	} else {
 		list_for_each_entry(ne, &lpni->lpni_pref.nids, nl_list) {
-			if (ne->nl_nid == nid)
+			if (nid_same(&ne->nl_nid, nid))
 				goto remove_nid_entry;
 		}
 		rc = -ENOENT;
@@ -1278,7 +1282,7 @@ struct lnet_peer_ni *
 	lnet_net_lock(LNET_LOCK_EX);
 	spin_lock(&lpni->lpni_lock);
 	if (lpni->lpni_pref_nnids == 1) {
-		lpni->lpni_pref.nid = LNET_NID_ANY;
+		lpni->lpni_pref.nid = LNET_ANY_NID;
 	} else {
 		list_del_init(&ne->nl_list);
 		if (lpni->lpni_pref_nnids == 2) {
@@ -1301,7 +1305,7 @@ struct lnet_peer_ni *
 	kfree(ne);
 out:
 	CDEBUG(D_NET, "peer %s nid %s: %d\n",
-	       libcfs_nidstr(&lp->lp_primary_nid), libcfs_nid2str(nid), rc);
+	       libcfs_nidstr(&lp->lp_primary_nid), libcfs_nidstr(nid), rc);
 	return rc;
 }
 
@@ -1316,7 +1320,7 @@ struct lnet_peer_ni *
 
 	lnet_net_lock(LNET_LOCK_EX);
 	if (lpni->lpni_pref_nnids == 1)
-		lpni->lpni_pref.nid = LNET_NID_ANY;
+		lpni->lpni_pref.nid = LNET_ANY_NID;
 	else if (lpni->lpni_pref_nnids > 1)
 		list_splice_init(&lpni->lpni_pref.nids, &zombies);
 	lpni->lpni_pref_nnids = 0;
@@ -1849,7 +1853,7 @@ struct lnet_peer_net *
  * lpni creation initiated due to traffic either sending or receiving.
  */
 static int
-lnet_peer_ni_traffic_add(struct lnet_nid *nid, lnet_nid_t pref)
+lnet_peer_ni_traffic_add(struct lnet_nid *nid, struct lnet_nid *pref)
 {
 	struct lnet_peer *lp;
 	struct lnet_peer_net *lpn;
@@ -1886,8 +1890,7 @@ struct lnet_peer_net *
 	lpni = lnet_peer_ni_alloc(nid);
 	if (!lpni)
 		goto out_free_lpn;
-	if (pref != LNET_NID_ANY)
-		lnet_peer_ni_set_non_mr_pref_nid(lpni, pref);
+	lnet_peer_ni_set_non_mr_pref_nid(lpni, pref);
 
 	return lnet_peer_attach_peer_ni(lp, lpn, lpni, flags);
 
@@ -2084,7 +2087,7 @@ struct lnet_peer_ni *
 
 	lnet_net_unlock(cpt);
 
-	rc = lnet_peer_ni_traffic_add(nid, LNET_NID_ANY);
+	rc = lnet_peer_ni_traffic_add(nid, NULL);
 	if (rc) {
 		lpni = ERR_PTR(rc);
 		goto out_net_relock;
@@ -2104,21 +2107,20 @@ struct lnet_peer_ni *
  * hold on the peer_ni.
  */
 struct lnet_peer_ni *
-lnet_nid2peerni_locked(lnet_nid_t nid4, lnet_nid_t pref, int cpt)
+lnet_peerni_by_nid_locked(struct lnet_nid *nid,
+			  struct lnet_nid *pref, int cpt)
 {
 	struct lnet_peer_ni *lpni = NULL;
-	struct lnet_nid nid;
 	int rc;
 
 	if (the_lnet.ln_state != LNET_STATE_RUNNING)
 		return ERR_PTR(-ESHUTDOWN);
 
-	lnet_nid4_to_nid(nid4, &nid);
 	/*
 	 * find if a peer_ni already exists.
 	 * If so then just return that.
 	 */
-	lpni = lnet_find_peer_ni_locked(nid4);
+	lpni = lnet_peer_ni_find_locked(nid);
 	if (lpni)
 		return lpni;
 
@@ -2145,13 +2147,13 @@ struct lnet_peer_ni *
 		goto out_mutex_unlock;
 	}
 
-	rc = lnet_peer_ni_traffic_add(&nid, pref);
+	rc = lnet_peer_ni_traffic_add(nid, pref);
 	if (rc) {
 		lpni = ERR_PTR(rc);
 		goto out_mutex_unlock;
 	}
 
-	lpni = lnet_find_peer_ni_locked(nid4);
+	lpni = lnet_peer_ni_find_locked(nid);
 	LASSERT(lpni);
 
 out_mutex_unlock:
@@ -2168,6 +2170,19 @@ struct lnet_peer_ni *
 	return lpni;
 }
 
+struct lnet_peer_ni *
+lnet_nid2peerni_locked(lnet_nid_t nid4, lnet_nid_t pref4, int cpt)
+{
+	struct lnet_nid nid, pref;
+
+	lnet_nid4_to_nid(nid4, &nid);
+	lnet_nid4_to_nid(pref4, &pref);
+	if (pref4 == LNET_NID_ANY)
+		return lnet_peerni_by_nid_locked(&nid, NULL, cpt);
+	else
+		return lnet_peerni_by_nid_locked(&nid, &pref, cpt);
+}
+
 bool
 lnet_peer_gw_discovery(struct lnet_peer *lp)
 {
diff --git a/net/lnet/lnet/udsp.c b/net/lnet/lnet/udsp.c
index 977a6a6..7fa4f88 100644
--- a/net/lnet/lnet/udsp.c
+++ b/net/lnet/lnet/udsp.c
@@ -213,7 +213,7 @@ enum udsp_apply {
 	struct lnet_ud_nid_descr *ni_match = udi->udi_match;
 	u32 priority = (udi->udi_revert) ? -1 : udi->udi_priority;
 
-	rc = cfs_match_nid_net(lnet_nid_to_nid4(&ni->ni_nid),
+	rc = cfs_match_nid_net(&ni->ni_nid,
 			       ni_match->ud_net_id.udn_net_type,
 			       &ni_match->ud_net_id.udn_net_num_range,
 			       &ni_match->ud_addr_range);
@@ -239,7 +239,7 @@ enum udsp_apply {
 	struct lnet_route *route;
 	struct lnet_peer_ni *lpni;
 	bool cleared = false;
-	lnet_nid_t gw_nid, gw_prim_nid;
+	struct lnet_nid *gw_nid, *gw_prim_nid;
 	int rc = 0;
 	int i;
 
@@ -248,14 +248,14 @@ enum udsp_apply {
 		list_for_each_entry(rnet, rn_list, lrn_list) {
 			list_for_each_entry(route, &rnet->lrn_routes, lr_list) {
 				/* look if gw nid on the same net matches */
-				gw_prim_nid = lnet_nid_to_nid4(&route->lr_gateway->lp_primary_nid);
+				gw_prim_nid = &route->lr_gateway->lp_primary_nid;
 				lpni = NULL;
 				while ((lpni = lnet_get_next_peer_ni_locked(route->lr_gateway,
 									    NULL,
 									    lpni)) != NULL) {
 					if (!lnet_get_net_locked(lpni->lpni_peer_net->lpn_net_id))
 						continue;
-					gw_nid = lnet_nid_to_nid4(&lpni->lpni_nid);
+					gw_nid = &lpni->lpni_nid;
 					rc = cfs_match_nid_net(gw_nid,
 							       rte_action->ud_net_id.udn_net_type,
 							       &rte_action->ud_net_id.udn_net_num_range,
@@ -285,13 +285,13 @@ enum udsp_apply {
 				/* match. Add to pref NIDs */
 				CDEBUG(D_NET, "udsp net->gw: %s->%s\n",
 				       libcfs_net2str(net->net_id),
-				       libcfs_nid2str(gw_prim_nid));
+				       libcfs_nidstr(gw_prim_nid));
 				rc = lnet_net_add_pref_rtr(net, gw_prim_nid);
 				lnet_net_lock(LNET_LOCK_EX);
 				/* success if EEXIST return */
 				if (rc && rc != -EEXIST) {
 					CERROR("Failed to add %s to %s pref rtr list\n",
-					       libcfs_nid2str(gw_prim_nid),
+					       libcfs_nidstr(gw_prim_nid),
 					       libcfs_net2str(net->net_id));
 					return rc;
 				}
@@ -417,7 +417,7 @@ enum udsp_apply {
 	struct list_head *rn_list;
 	struct lnet_route *route;
 	bool cleared = false;
-	lnet_nid_t gw_nid;
+	struct lnet_nid *gw_nid;
 	int rc = 0;
 	int i;
 
@@ -425,7 +425,7 @@ enum udsp_apply {
 		rn_list = &the_lnet.ln_remote_nets_hash[i];
 		list_for_each_entry(rnet, rn_list, lrn_list) {
 			list_for_each_entry(route, &rnet->lrn_routes, lr_list) {
-				gw_nid = lnet_nid_to_nid4(&route->lr_gateway->lp_primary_nid);
+				gw_nid = &route->lr_gateway->lp_primary_nid;
 				rc = cfs_match_nid_net(gw_nid,
 						       rte_action->ud_net_id.udn_net_type,
 						       &rte_action->ud_net_id.udn_net_num_range,
@@ -447,7 +447,7 @@ enum udsp_apply {
 				}
 				CDEBUG(D_NET,
 				       "add gw nid %s as preferred for peer %s\n",
-				       libcfs_nid2str(gw_nid),
+				       libcfs_nidstr(gw_nid),
 				       libcfs_nidstr(&lpni->lpni_nid));
 				/* match. Add to pref NIDs */
 				rc = lnet_peer_add_pref_rtr(lpni, gw_nid);
@@ -455,7 +455,7 @@ enum udsp_apply {
 				/* success if EEXIST return */
 				if (rc && rc != -EEXIST) {
 					CERROR("Failed to add %s to %s pref rtr list\n",
-					       libcfs_nid2str(gw_nid),
+					       libcfs_nidstr(gw_nid),
 					       libcfs_nidstr(&lpni->lpni_nid));
 					return rc;
 				}
@@ -481,7 +481,7 @@ enum udsp_apply {
 		    ni_action->ud_net_id.udn_net_type)
 			continue;
 		list_for_each_entry(ni, &net->net_ni_list, ni_netlist) {
-			rc = cfs_match_nid_net(lnet_nid_to_nid4(&ni->ni_nid),
+			rc = cfs_match_nid_net(&ni->ni_nid,
 					       ni_action->ud_net_id.udn_net_type,
 					       &ni_action->ud_net_id.udn_net_num_range,
 					       &ni_action->ud_addr_range);
@@ -503,8 +503,7 @@ enum udsp_apply {
 			       libcfs_nidstr(&ni->ni_nid),
 			       libcfs_nidstr(&lpni->lpni_nid));
 			/* match. Add to pref NIDs */
-			rc = lnet_peer_add_pref_nid(lpni,
-						    lnet_nid_to_nid4(&ni->ni_nid));
+			rc = lnet_peer_add_pref_nid(lpni, &ni->ni_nid);
 			lnet_net_lock(LNET_LOCK_EX);
 			/* success if EEXIST return */
 			if (rc && rc != -EEXIST) {
@@ -530,7 +529,7 @@ enum udsp_apply {
 	bool local = udi->udi_local;
 	enum lnet_udsp_action_type type = udi->udi_type;
 
-	rc = cfs_match_nid_net(lnet_nid_to_nid4(&lpni->lpni_nid),
+	rc = cfs_match_nid_net(&lpni->lpni_nid,
 			       lp_match->ud_net_id.udn_net_type,
 			       &lp_match->ud_net_id.udn_net_num_range,
 			       &lp_match->ud_addr_range);
@@ -996,7 +995,8 @@ struct lnet_udsp *
 		info->cud_net_priority = ni->ni_net->net_sel_priority;
 		list_for_each_entry(ne, &net->net_rtr_pref_nids, nl_list) {
 			if (i < LNET_MAX_SHOW_NUM_NID)
-				info->cud_pref_rtr_nid[i] = ne->nl_nid;
+				info->cud_pref_rtr_nid[i] =
+					lnet_nid_to_nid4(&ne->nl_nid);
 			else
 				break;
 			i++;
@@ -1020,13 +1020,14 @@ struct lnet_udsp *
 	       libcfs_nidstr(&lpni->lpni_nid),
 	       lpni->lpni_pref_nnids);
 	if (lpni->lpni_pref_nnids == 1) {
-		info->cud_pref_nid[0] = lpni->lpni_pref.nid;
+		info->cud_pref_nid[0] = lnet_nid_to_nid4(&lpni->lpni_pref.nid);
 	} else if (lpni->lpni_pref_nnids > 1) {
 		struct list_head *list = &lpni->lpni_pref.nids;
 
 		list_for_each_entry(ne, list, nl_list) {
 			if (i < LNET_MAX_SHOW_NUM_NID)
-				info->cud_pref_nid[i] = ne->nl_nid;
+				info->cud_pref_nid[i] =
+					lnet_nid_to_nid4(&ne->nl_nid);
 			else
 				break;
 			i++;
@@ -1036,7 +1037,8 @@ struct lnet_udsp *
 	i = 0;
 	list_for_each_entry(ne, &lpni->lpni_rtr_pref_nids, nl_list) {
 		if (i < LNET_MAX_SHOW_NUM_NID)
-			info->cud_pref_rtr_nid[i] = ne->nl_nid;
+			info->cud_pref_rtr_nid[i] =
+				lnet_nid_to_nid4(&ne->nl_nid);
 		else
 			break;
 		i++;
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
