Return-Path: <SRS0=2ypu=OM=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C99EAC433F5
	for <lustre-devel@archiver.kernel.org>; Wed, 22 Sep 2021 02:20:39 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 842BC6112F
	for <lustre-devel@archiver.kernel.org>; Wed, 22 Sep 2021 02:20:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.1 mail.kernel.org 842BC6112F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id EAE4E21F294;
	Tue, 21 Sep 2021 19:20:36 -0700 (PDT)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 1B92721CAA2
 for <lustre-devel@lists.lustre.org>; Tue, 21 Sep 2021 19:20:07 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 106DA355;
 Tue, 21 Sep 2021 22:20:04 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 036F9FF4C1; Tue, 21 Sep 2021 22:20:04 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Tue, 21 Sep 2021 22:19:42 -0400
Message-Id: <1632277201-6920-6-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1632277201-6920-1-git-send-email-jsimmons@infradead.org>
References: <1632277201-6920-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 05/24] lnet: change lpni_nid in lnet_peer_ni
 to lnet_nid
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

lpni_nid in 'struct lnet_peer_ni' is converted to 'struct lnet_nid'
and various supporting functions updated.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10391
Lustre-commit: 6c5561a1e1eeab18e ("LU-10391 lnet: change lpni_nid in lnet_peer_ni to lnet_nid")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/42101
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Chris Horn <chris.horn@hpe.com>
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/lib-lnet.h  | 14 ++++++---
 include/linux/lnet/lib-types.h |  2 +-
 net/lnet/lnet/api-ni.c         | 61 +++++++++++++++++++++++++++----------
 net/lnet/lnet/lib-move.c       | 49 ++++++++++++++++--------------
 net/lnet/lnet/lib-msg.c        |  2 +-
 net/lnet/lnet/net_fault.c      |  2 +-
 net/lnet/lnet/peer.c           | 68 +++++++++++++++++++++++-------------------
 net/lnet/lnet/router.c         |  7 +++--
 net/lnet/lnet/router_proc.c    |  4 +--
 net/lnet/lnet/udsp.c           | 20 ++++++-------
 10 files changed, 139 insertions(+), 90 deletions(-)

diff --git a/include/linux/lnet/lib-lnet.h b/include/linux/lnet/lib-lnet.h
index acc069d..05c099d 100644
--- a/include/linux/lnet/lib-lnet.h
+++ b/include/linux/lnet/lib-lnet.h
@@ -459,9 +459,14 @@ struct lnet_ni *
 			  char *iface);
 
 static inline int
-lnet_nid2peerhash(lnet_nid_t nid)
+lnet_nid2peerhash(struct lnet_nid *nid)
 {
-	return hash_long(nid, LNET_PEER_HASH_BITS);
+	u32 h = 0;
+	int i;
+
+	for (i = 0; i < 4; i++)
+		h = hash_32(nid->nid_addr[i]^h, 32);
+	return hash_32(LNET_NID_NET(nid) ^ h, LNET_PEER_HASH_BITS);
 }
 
 static inline struct list_head *
@@ -476,7 +481,7 @@ struct lnet_ni *
 extern int avoid_asym_router_failure;
 
 unsigned int lnet_nid_cpt_hash(lnet_nid_t nid, unsigned int number);
-int lnet_cpt_of_nid_locked(lnet_nid_t nid, struct lnet_ni *ni);
+int lnet_cpt_of_nid_locked(struct lnet_nid *nid, struct lnet_ni *ni);
 int lnet_cpt_of_nid(lnet_nid_t nid, struct lnet_ni *ni);
 struct lnet_ni *lnet_nid2ni_locked(lnet_nid_t nid, int cpt);
 struct lnet_ni *lnet_nid2ni_addref(lnet_nid_t nid);
@@ -900,7 +905,8 @@ int lnet_get_peer_ni_info(u32 peer_index, u64 *nid,
 static inline bool
 lnet_peer_ni_is_primary(struct lnet_peer_ni *lpni)
 {
-	return lpni->lpni_nid == lpni->lpni_peer_net->lpn_peer->lp_primary_nid;
+	return lnet_nid_to_nid4(&lpni->lpni_nid) ==
+			lpni->lpni_peer_net->lpn_peer->lp_primary_nid;
 }
 
 bool lnet_peer_is_uptodate(struct lnet_peer *lp);
diff --git a/include/linux/lnet/lib-types.h b/include/linux/lnet/lib-types.h
index 5b517cc..a6223d2 100644
--- a/include/linux/lnet/lib-types.h
+++ b/include/linux/lnet/lib-types.h
@@ -606,7 +606,7 @@ struct lnet_peer_ni {
 	/* network peer is on */
 	struct lnet_net		*lpni_net;
 	/* peer's NID */
-	lnet_nid_t		 lpni_nid;
+	struct lnet_nid		 lpni_nid;
 	/* # refs */
 	struct kref		 lpni_kref;
 	/* health value for the peer */
diff --git a/net/lnet/lnet/api-ni.c b/net/lnet/lnet/api-ni.c
index 9471edb..3ae88fc 100644
--- a/net/lnet/lnet/api-ni.c
+++ b/net/lnet/lnet/api-ni.c
@@ -1453,9 +1453,11 @@ struct lnet_net *
 }
 
 int
-lnet_cpt_of_nid_locked(lnet_nid_t nid, struct lnet_ni *ni)
+lnet_cpt_of_nid_locked(struct lnet_nid *nid, struct lnet_ni *ni)
 {
 	struct lnet_net *net;
+	/* FIXME handle long-addr nid */
+	lnet_nid_t nid4 = lnet_nid_to_nid4(nid);
 
 	/* must called with hold of lnet_net_lock */
 	if (LNET_CPT_NUMBER == 1)
@@ -1470,33 +1472,35 @@ struct lnet_net *
 	 */
 	if (ni) {
 		if (ni->ni_cpts)
-			return ni->ni_cpts[lnet_nid_cpt_hash(nid,
+			return ni->ni_cpts[lnet_nid_cpt_hash(nid4,
 							     ni->ni_ncpts)];
 		else
-			return lnet_nid_cpt_hash(nid, LNET_CPT_NUMBER);
+			return lnet_nid_cpt_hash(nid4, LNET_CPT_NUMBER);
 	}
 
 	/* no NI provided so look at the net */
-	net = lnet_get_net_locked(LNET_NIDNET(nid));
+	net = lnet_get_net_locked(LNET_NID_NET(nid));
 
 	if (net && net->net_cpts) {
-		return net->net_cpts[lnet_nid_cpt_hash(nid, net->net_ncpts)];
+		return net->net_cpts[lnet_nid_cpt_hash(nid4, net->net_ncpts)];
 	}
 
-	return lnet_nid_cpt_hash(nid, LNET_CPT_NUMBER);
+	return lnet_nid_cpt_hash(nid4, LNET_CPT_NUMBER);
 }
 
 int
-lnet_cpt_of_nid(lnet_nid_t nid, struct lnet_ni *ni)
+lnet_cpt_of_nid(lnet_nid_t nid4, struct lnet_ni *ni)
 {
 	int cpt;
 	int cpt2;
+	struct lnet_nid nid;
 
 	if (LNET_CPT_NUMBER == 1)
 		return 0; /* the only one */
 
+	lnet_nid4_to_nid(nid4, &nid);
 	cpt = lnet_net_lock_current();
-	cpt2 = lnet_cpt_of_nid_locked(nid, ni);
+	cpt2 = lnet_cpt_of_nid_locked(&nid, ni);
 	lnet_net_unlock(cpt);
 
 	return cpt2;
@@ -1529,18 +1533,16 @@ struct lnet_net *
 }
 
 struct lnet_ni *
-lnet_nid2ni_locked(lnet_nid_t nid4, int cpt)
+lnet_nid_to_ni_locked(struct lnet_nid *nid, int cpt)
 {
 	struct lnet_net *net;
 	struct lnet_ni *ni;
-	struct lnet_nid nid;
 
 	LASSERT(cpt != LNET_LOCK_EX);
-	lnet_nid4_to_nid(nid4, &nid);
 
 	list_for_each_entry(net, &the_lnet.ln_nets, net_list) {
 		list_for_each_entry(ni, &net->net_ni_list, ni_netlist) {
-			if (nid_same(&ni->ni_nid, &nid))
+			if (nid_same(&ni->ni_nid, nid))
 				return ni;
 		}
 	}
@@ -1548,13 +1550,25 @@ struct lnet_ni *
 	return NULL;
 }
 
+struct lnet_ni  *
+lnet_nid2ni_locked(lnet_nid_t nid4, int cpt)
+{
+	struct lnet_nid nid;
+
+	lnet_nid4_to_nid(nid4, &nid);
+	return lnet_nid_to_ni_locked(&nid, cpt);
+}
+
 struct lnet_ni *
-lnet_nid2ni_addref(lnet_nid_t nid)
+lnet_nid2ni_addref(lnet_nid_t nid4)
 {
 	struct lnet_ni *ni;
+	struct lnet_nid nid;
+
+	lnet_nid4_to_nid(nid4, &nid);
 
 	lnet_net_lock(0);
-	ni = lnet_nid2ni_locked(nid, 0);
+	ni = lnet_nid_to_ni_locked(&nid, 0);
 	if (ni)
 		lnet_ni_addref_locked(ni, 0);
 	lnet_net_unlock(0);
@@ -1563,6 +1577,21 @@ struct lnet_ni *
 }
 EXPORT_SYMBOL(lnet_nid2ni_addref);
 
+struct lnet_ni *
+lnet_nid_to_ni_addref(struct lnet_nid *nid)
+{
+	struct lnet_ni *ni;
+
+	lnet_net_lock(0);
+	ni = lnet_nid_to_ni_locked(nid, 0);
+	if (ni)
+		lnet_ni_addref_locked(ni, 0);
+	lnet_net_unlock(0);
+
+	return ni;
+}
+EXPORT_SYMBOL(lnet_nid_to_ni_addref);
+
 int
 lnet_islocalnid(lnet_nid_t nid)
 {
@@ -3759,7 +3788,7 @@ u32 lnet_get_dlc_seq_locked(void)
 
 	lnet_net_lock(LNET_LOCK_EX);
 	list_for_each_entry(lpni, &the_lnet.ln_mt_peerNIRecovq, lpni_recovery) {
-		list->rlst_nid_array[i] = lpni->lpni_nid;
+		list->rlst_nid_array[i] = lnet_nid_to_nid4(&lpni->lpni_nid);
 		i++;
 		if (i >= LNET_MAX_SHOW_NUM_NID)
 			break;
@@ -4630,7 +4659,7 @@ static int lnet_ping(struct lnet_process_id id, signed long timeout,
 	p = NULL;
 	while ((p = lnet_get_next_peer_ni_locked(lp, NULL, p)) != NULL) {
 		buf[i].pid = id.pid;
-		buf[i].nid = p->lpni_nid;
+		buf[i].nid = lnet_nid_to_nid4(&p->lpni_nid);
 		if (++i >= n_ids)
 			break;
 	}
diff --git a/net/lnet/lnet/lib-move.c b/net/lnet/lnet/lib-move.c
index c70ec37..9a2fdb6 100644
--- a/net/lnet/lnet/lib-move.c
+++ b/net/lnet/lnet/lib-move.c
@@ -562,7 +562,7 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 					&msg->msg_private);
 	if (rc) {
 		CERROR("recv from %s / send to %s aborted: eager_recv failed %d\n",
-		       libcfs_nid2str(msg->msg_rxpeer->lpni_nid),
+		       libcfs_nidstr(&msg->msg_rxpeer->lpni_nid),
 		       libcfs_id2str(msg->msg_target), rc);
 		LASSERT(rc < 0); /* required by my callers */
 	}
@@ -648,8 +648,7 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 
 	/* can't get here if we're sending to the loopback interface */
 	if (the_lnet.ln_loni)
-		LASSERT(lp->lpni_nid !=
-			lnet_nid_to_nid4(&the_lnet.ln_loni->ni_nid));
+		LASSERT(!nid_same(&lp->lpni_nid, &the_lnet.ln_loni->ni_nid));
 
 	/* NB 'lp' is always the next hop */
 	if (!(msg->msg_target.pid & LNET_PID_USERFLAG) &&
@@ -1150,8 +1149,8 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 		if (best_lpni)
 			CDEBUG(D_NET,
 			       "n:[%s, %s] h:[%d, %d] p:[%d, %d] c:[%d, %d] s:[%d, %d]\n",
-			       libcfs_nid2str(lpni->lpni_nid),
-			       libcfs_nid2str(best_lpni->lpni_nid),
+			       libcfs_nidstr(&lpni->lpni_nid),
+			       libcfs_nidstr(&best_lpni->lpni_nid),
 			       lpni_healthv, best_lpni_healthv,
 			       lpni_sel_prio, best_sel_prio,
 			       lpni->lpni_txcredits, best_lpni_credits,
@@ -1220,7 +1219,7 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 	}
 
 	CDEBUG(D_NET, "sd_best_lpni = %s\n",
-	       libcfs_nid2str(best_lpni->lpni_nid));
+	       libcfs_nidstr(&best_lpni->lpni_nid));
 
 	return best_lpni;
 }
@@ -1662,7 +1661,7 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 	       best_ni->ni_seq, best_ni->ni_net->net_seq,
 	       atomic_read(&best_ni->ni_tx_credits),
 	       best_ni->ni_sel_priority,
-	       libcfs_nid2str(best_lpni->lpni_nid),
+	       libcfs_nidstr(&best_lpni->lpni_nid),
 	       best_lpni->lpni_seq, best_lpni->lpni_peer_net->lpn_seq,
 	       best_lpni->lpni_txcredits,
 	       best_lpni->lpni_sel_priority);
@@ -1680,7 +1679,7 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 	 * the configuration has changed. We don't have a hold on the best_ni
 	 * yet, and it may have vanished.
 	 */
-	cpt2 = lnet_cpt_of_nid_locked(best_lpni->lpni_nid, best_ni);
+	cpt2 = lnet_cpt_of_nid_locked(&best_lpni->lpni_nid, best_ni);
 	if (sd->sd_cpt != cpt2) {
 		u32 seq = lnet_get_dlc_seq_locked();
 
@@ -1709,7 +1708,8 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 	 * what was originally set in the target or it will be the NID of
 	 * a router if this message should be routed
 	 */
-	msg->msg_target.nid = msg->msg_txpeer->lpni_nid;
+	/* FIXME handle large-addr nids */
+	msg->msg_target.nid = lnet_nid_to_nid4(&msg->msg_txpeer->lpni_nid);
 
 	/* lnet_msg_commit assigns the correct cpt to the message, which
 	 * is used to decrement the correct refcount on the ni when it's
@@ -1737,12 +1737,15 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 		 * lnet_select_pathway() function and is never changed.
 		 * It's safe to use it here.
 		 */
-		msg->msg_hdr.dest_nid = cpu_to_le64(final_dst_lpni->lpni_nid);
+		/* FIXME handle large-addr nid */
+		msg->msg_hdr.dest_nid =
+			cpu_to_le64(lnet_nid_to_nid4(&final_dst_lpni->lpni_nid));
 	} else {
 		/* if we're not routing set the dest_nid to the best peer
 		 * ni NID that we picked earlier in the algorithm.
 		 */
-		msg->msg_hdr.dest_nid = cpu_to_le64(msg->msg_txpeer->lpni_nid);
+		msg->msg_hdr.dest_nid =
+			cpu_to_le64(lnet_nid_to_nid4(&msg->msg_txpeer->lpni_nid));
 	}
 
 	/* if we have response tracker block update it with the next hop
@@ -1751,7 +1754,8 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 	if (msg->msg_md) {
 		rspt = msg->msg_md->md_rspt_ptr;
 		if (rspt) {
-			rspt->rspt_next_hop_nid = msg->msg_txpeer->lpni_nid;
+			rspt->rspt_next_hop_nid =
+				lnet_nid_to_nid4(&msg->msg_txpeer->lpni_nid);
 			CDEBUG(D_NET, "rspt_next_hop_nid = %s\n",
 			       libcfs_nid2str(rspt->rspt_next_hop_nid));
 		}
@@ -1765,7 +1769,7 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 		       libcfs_nid2str(sd->sd_src_nid),
 		       libcfs_nid2str(msg->msg_hdr.dest_nid),
 		       libcfs_nid2str(sd->sd_dst_nid),
-		       libcfs_nid2str(msg->msg_txpeer->lpni_nid),
+		       libcfs_nidstr(&msg->msg_txpeer->lpni_nid),
 		       libcfs_nid2str(sd->sd_rtr_nid),
 		       lnet_msgtyp2str(msg->msg_type), msg->msg_retry_count);
 
@@ -1780,7 +1784,7 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 	    !lnet_msg_is_response(msg) && lpni->lpni_pref_nnids == 0) {
 		CDEBUG(D_NET, "Setting preferred local NID %s on NMR peer %s\n",
 		       libcfs_nidstr(&lni->ni_nid),
-		       libcfs_nid2str(lpni->lpni_nid));
+		       libcfs_nidstr(&lpni->lpni_nid));
 		lnet_peer_ni_set_non_mr_pref_nid(lpni,
 						 lnet_nid_to_nid4(&lni->ni_nid));
 	}
@@ -1833,8 +1837,8 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 	}
 
 	if (sd->sd_best_lpni &&
-	    sd->sd_best_lpni->lpni_nid ==
-	    lnet_nid_to_nid4(&the_lnet.ln_loni->ni_nid))
+	    nid_same(&sd->sd_best_lpni->lpni_nid,
+		      &the_lnet.ln_loni->ni_nid))
 		return lnet_handle_lo_send(sd);
 	else if (sd->sd_best_lpni)
 		return lnet_handle_send(sd);
@@ -1901,7 +1905,7 @@ struct lnet_ni *
 		return rc;
 	}
 
-	new_lpni = lnet_find_peer_ni_locked(lpni->lpni_nid);
+	new_lpni = lnet_find_peer_ni_locked(lnet_nid_to_nid4(&lpni->lpni_nid));
 	if (!new_lpni) {
 		lnet_peer_ni_decref_locked(lpni);
 		return -ENOENT;
@@ -2343,7 +2347,7 @@ struct lnet_ni *
 		/* If there is no best_ni we don't have a route */
 		if (!best_ni) {
 			CERROR("no path to %s from net %s\n",
-			       libcfs_nid2str(best_lpni->lpni_nid),
+			       libcfs_nidstr(&best_lpni->lpni_nid),
 			       libcfs_net2str(best_lpni->lpni_net->net_id));
 			return -EHOSTUNREACH;
 		}
@@ -2460,8 +2464,8 @@ struct lnet_ni *
 		 * network
 		 */
 		if (sd->sd_best_lpni &&
-		    sd->sd_best_lpni->lpni_nid ==
-		    lnet_nid_to_nid4(&the_lnet.ln_loni->ni_nid)) {
+		    nid_same(&sd->sd_best_lpni->lpni_nid,
+			     &the_lnet.ln_loni->ni_nid)) {
 			/* in case we initially started with a routed
 			 * destination, let's reset to local
 			 */
@@ -3461,7 +3465,7 @@ struct lnet_mt_event_info {
 			ev_info = kzalloc(sizeof(*ev_info), GFP_NOFS);
 			if (!ev_info) {
 				CERROR("out of memory. Can't recover %s\n",
-				       libcfs_nid2str(lpni->lpni_nid));
+				       libcfs_nidstr(&lpni->lpni_nid));
 				spin_lock(&lpni->lpni_lock);
 				lpni->lpni_state &=
 					~LNET_PEER_NI_RECOVERY_PENDING;
@@ -3472,7 +3476,8 @@ struct lnet_mt_event_info {
 			/* look at the comments in lnet_recover_local_nis() */
 			mdh = lpni->lpni_recovery_ping_mdh;
 			LNetInvalidateMDHandle(&lpni->lpni_recovery_ping_mdh);
-			nid = lpni->lpni_nid;
+			/* FIXME handle large-addr nid */
+			nid = lnet_nid_to_nid4(&lpni->lpni_nid);
 			lnet_net_lock(0);
 			list_del_init(&lpni->lpni_recovery);
 			lnet_peer_ni_decref_locked(lpni);
diff --git a/net/lnet/lnet/lib-msg.c b/net/lnet/lnet/lib-msg.c
index b1f684f..3c8b7c3 100644
--- a/net/lnet/lnet/lib-msg.c
+++ b/net/lnet/lnet/lib-msg.c
@@ -829,7 +829,7 @@
 
 	CDEBUG(D_NET, "health check: %s->%s: %s: %s\n",
 	       libcfs_nidstr(&ni->ni_nid),
-	       (lo) ? "self" : libcfs_nid2str(lpni->lpni_nid),
+	       (lo) ? "self" : libcfs_nidstr(&lpni->lpni_nid),
 	       lnet_msgtyp2str(msg->msg_type),
 	       lnet_health_error2str(hstatus));
 
diff --git a/net/lnet/lnet/net_fault.c b/net/lnet/lnet/net_fault.c
index 4c50eec..06366df 100644
--- a/net/lnet/lnet/net_fault.c
+++ b/net/lnet/lnet/net_fault.c
@@ -685,7 +685,7 @@ struct delay_daemon_data {
 			ni = msg->msg_txni;
 			CDEBUG(D_NET, "TRACE: msg %p %s -> %s : %s\n", msg,
 			       libcfs_nidstr(&ni->ni_nid),
-			       libcfs_nid2str(msg->msg_txpeer->lpni_nid),
+			       libcfs_nidstr(&msg->msg_txpeer->lpni_nid),
 			       lnet_msgtyp2str(msg->msg_type));
 			lnet_ni_send(ni, msg);
 			continue;
diff --git a/net/lnet/lnet/peer.c b/net/lnet/lnet/peer.c
index 720af99..4629a8b 100644
--- a/net/lnet/lnet/peer.c
+++ b/net/lnet/lnet/peer.c
@@ -59,7 +59,7 @@
 
 	list_for_each_entry_safe(lpni, tmp, &the_lnet.ln_remote_peer_ni_list,
 				 lpni_on_remote_peer_ni_list) {
-		if (LNET_NIDNET(lpni->lpni_nid) == net->net_id) {
+		if (LNET_NID_NET(&lpni->lpni_nid) == net->net_id) {
 			lpni->lpni_net = net;
 
 			spin_lock(&lpni->lpni_lock);
@@ -136,7 +136,7 @@
 	else
 		lpni->lpni_ns_status = LNET_NI_STATUS_UP;
 	lpni->lpni_ping_feats = LNET_PING_FEAT_INVAL;
-	lpni->lpni_nid = nid;
+	lnet_nid4_to_nid(nid, &lpni->lpni_nid);
 	lpni->lpni_cpt = cpt;
 	atomic_set(&lpni->lpni_healthv, LNET_MAX_HEALTH_VALUE);
 
@@ -160,7 +160,7 @@
 			      &the_lnet.ln_remote_peer_ni_list);
 	}
 
-	CDEBUG(D_NET, "%p nid %s\n", lpni, libcfs_nid2str(lpni->lpni_nid));
+	CDEBUG(D_NET, "%p nid %s\n", lpni, libcfs_nidstr(&lpni->lpni_nid));
 
 	return lpni;
 }
@@ -334,7 +334,7 @@
 	}
 	CDEBUG(D_NET, "peer %s NID %s\n",
 	       libcfs_nid2str(lp->lp_primary_nid),
-	       libcfs_nid2str(lpni->lpni_nid));
+	       libcfs_nidstr(&lpni->lpni_nid));
 }
 
 /* called with lnet_net_lock LNET_LOCK_EX held */
@@ -346,7 +346,7 @@
 	/* don't remove a peer_ni if it's also a gateway */
 	if (lnet_isrouter(lpni) && !force) {
 		CERROR("Peer NI %s is a gateway. Can not delete it\n",
-		       libcfs_nid2str(lpni->lpni_nid));
+		       libcfs_nidstr(&lpni->lpni_nid));
 		return -EBUSY;
 	}
 
@@ -567,7 +567,7 @@ static void lnet_peer_cancel_discovery(struct lnet_peer *lp)
 		/* assign the next peer_ni to be the primary */
 		lpni2 = lnet_get_next_peer_ni_locked(lp, NULL, lpni);
 		LASSERT(lpni2);
-		lp->lp_primary_nid = lpni2->lpni_nid;
+		lp->lp_primary_nid = lnet_nid_to_nid4(&lpni2->lpni_nid);
 	}
 	rc = lnet_peer_ni_del_locked(lpni, force);
 
@@ -596,7 +596,8 @@ static void lnet_peer_cancel_discovery(struct lnet_peer *lp)
 				continue;
 
 			peer = lpni->lpni_peer_net->lpn_peer;
-			if (peer->lp_primary_nid != lpni->lpni_nid) {
+			if (peer->lp_primary_nid !=
+			    lnet_nid_to_nid4(&lpni->lpni_nid)) {
 				lnet_peer_ni_del_locked(lpni, false);
 				continue;
 			}
@@ -682,7 +683,7 @@ static void lnet_peer_cancel_discovery(struct lnet_peer *lp)
 }
 
 static struct lnet_peer_ni *
-lnet_get_peer_ni_locked(struct lnet_peer_table *ptable, lnet_nid_t nid)
+lnet_get_peer_ni_locked(struct lnet_peer_table *ptable, struct lnet_nid *nid)
 {
 	struct list_head *peers;
 	struct lnet_peer_ni *lp;
@@ -692,7 +693,7 @@ static void lnet_peer_cancel_discovery(struct lnet_peer *lp)
 
 	peers = &ptable->pt_hash[lnet_nid2peerhash(nid)];
 	list_for_each_entry(lp, peers, lpni_hashlist) {
-		if (lp->lpni_nid == nid) {
+		if (nid_same(&lp->lpni_nid, nid)) {
 			lnet_peer_ni_addref_locked(lp);
 			return lp;
 		}
@@ -702,16 +703,19 @@ static void lnet_peer_cancel_discovery(struct lnet_peer *lp)
 }
 
 struct lnet_peer_ni *
-lnet_find_peer_ni_locked(lnet_nid_t nid)
+lnet_find_peer_ni_locked(lnet_nid_t nid4)
 {
 	struct lnet_peer_ni *lpni;
 	struct lnet_peer_table *ptable;
 	int cpt;
+	struct lnet_nid nid;
 
-	cpt = lnet_nid_cpt_hash(nid, LNET_CPT_NUMBER);
+	lnet_nid4_to_nid(nid4, &nid);
+
+	cpt = lnet_nid_cpt_hash(nid4, LNET_CPT_NUMBER);
 
 	ptable = the_lnet.ln_peer_tables[cpt];
-	lpni = lnet_get_peer_ni_locked(ptable, nid);
+	lpni = lnet_get_peer_ni_locked(ptable, &nid);
 
 	return lpni;
 }
@@ -727,7 +731,7 @@ struct lnet_peer_ni *
 		return NULL;
 
 	list_for_each_entry(lpni, &lpn->lpn_peer_nis, lpni_peer_nis) {
-		if (lpni->lpni_nid == nid)
+		if (lnet_nid_to_nid4(&lpni->lpni_nid) == nid)
 			return lpni;
 	}
 
@@ -953,7 +957,7 @@ struct lnet_peer_ni *
 	struct lnet_nid_list *ne;
 
 	CDEBUG(D_NET, "%s: rtr pref emtpy: %d\n",
-	       libcfs_nid2str(lpni->lpni_nid),
+	       libcfs_nidstr(&lpni->lpni_nid),
 	       list_empty(&lpni->lpni_rtr_pref_nids));
 
 	if (list_empty(&lpni->lpni_rtr_pref_nids))
@@ -1071,7 +1075,7 @@ struct lnet_peer_ni *
 	spin_unlock(&lpni->lpni_lock);
 
 	CDEBUG(D_NET, "peer %s nid %s: %d\n",
-	       libcfs_nid2str(lpni->lpni_nid), libcfs_nid2str(nid), rc);
+	       libcfs_nidstr(&lpni->lpni_nid), libcfs_nid2str(nid), rc);
 	return rc;
 }
 
@@ -1096,7 +1100,7 @@ struct lnet_peer_ni *
 	spin_unlock(&lpni->lpni_lock);
 
 	CDEBUG(D_NET, "peer %s: %d\n",
-	       libcfs_nid2str(lpni->lpni_nid), rc);
+	       libcfs_nidstr(&lpni->lpni_nid), rc);
 	return rc;
 }
 
@@ -1472,7 +1476,7 @@ struct lnet_peer_net *
 	lnet_net_lock(LNET_LOCK_EX);
 	/* Add peer_ni to global peer table hash, if necessary. */
 	if (list_empty(&lpni->lpni_hashlist)) {
-		int hash = lnet_nid2peerhash(lpni->lpni_nid);
+		int hash = lnet_nid2peerhash(&lpni->lpni_nid);
 
 		ptable = the_lnet.ln_peer_tables[lpni->lpni_cpt];
 		list_add_tail(&lpni->lpni_hashlist, &ptable->pt_hash[hash]);
@@ -1491,7 +1495,7 @@ struct lnet_peer_net *
 
 	/* Add peer_ni to peer_net */
 	lpni->lpni_peer_net = lpn;
-	if (lp->lp_primary_nid == lpni->lpni_nid)
+	if (lp->lp_primary_nid == lnet_nid_to_nid4(&lpni->lpni_nid))
 		list_add(&lpni->lpni_peer_nis, &lpn->lpn_peer_nis);
 	else
 		list_add_tail(&lpni->lpni_peer_nis, &lpn->lpn_peer_nis);
@@ -1502,7 +1506,7 @@ struct lnet_peer_net *
 	if (!lpn->lpn_peer) {
 		new_lpn = true;
 		lpn->lpn_peer = lp;
-		if (lp->lp_primary_nid == lpni->lpni_nid)
+		if (lp->lp_primary_nid == lnet_nid_to_nid4(&lpni->lpni_nid))
 			list_add(&lpn->lpn_peer_nets, &lp->lp_peer_nets);
 		else
 			list_add_tail(&lpn->lpn_peer_nets, &lp->lp_peer_nets);
@@ -1545,11 +1549,11 @@ struct lnet_peer_net *
 	rc = lnet_udsp_apply_policies_on_lpni(lpni);
 	if (rc)
 		CERROR("Failed to apply UDSPs on lpni %s\n",
-		       libcfs_nid2str(lpni->lpni_nid));
+		       libcfs_nidstr(&lpni->lpni_nid));
 
 	CDEBUG(D_NET, "peer %s NID %s flags %#x\n",
 	       libcfs_nid2str(lp->lp_primary_nid),
-	       libcfs_nid2str(lpni->lpni_nid), flags);
+	       libcfs_nidstr(&lpni->lpni_nid), flags);
 	lnet_peer_ni_decref_locked(lpni);
 	lnet_net_unlock(LNET_LOCK_EX);
 
@@ -1980,7 +1984,7 @@ struct lnet_peer_net *
 	struct lnet_peer_table *ptable;
 	struct lnet_peer_net *lpn;
 
-	CDEBUG(D_NET, "%p nid %s\n", lpni, libcfs_nid2str(lpni->lpni_nid));
+	CDEBUG(D_NET, "%p nid %s\n", lpni, libcfs_nidstr(&lpni->lpni_nid));
 
 	LASSERT(kref_read(&lpni->lpni_kref) == 0);
 	LASSERT(list_empty(&lpni->lpni_txq));
@@ -2581,7 +2585,7 @@ static void lnet_peer_clear_discovery_error(struct lnet_peer *lp)
 
 	CDEBUG(D_NET, "peer %s NID %s: %d. %s\n",
 	       (lp ? libcfs_nid2str(lp->lp_primary_nid) : "(none)"),
-	       libcfs_nid2str(lpni->lpni_nid), rc,
+	       libcfs_nidstr(&lpni->lpni_nid), rc,
 	       (!block) ? "pending discovery" : "discovery complete");
 
 	return rc;
@@ -2944,7 +2948,7 @@ static int lnet_peer_merge_data(struct lnet_peer *lp,
 	/* Construct the list of NIDs present in peer. */
 	lpni = NULL;
 	while ((lpni = lnet_get_next_peer_ni_locked(lp, NULL, lpni)) != NULL)
-		curnis[ncurnis++] = lpni->lpni_nid;
+		curnis[ncurnis++] = lnet_nid_to_nid4(&lpni->lpni_nid);
 
 	/*
 	 * Check for NIDs in pbuf not present in curnis[].
@@ -3897,7 +3901,7 @@ void lnet_peer_discovery_stop(void)
 		aliveness = (lnet_is_peer_ni_alive(lp)) ? "up" : "down";
 
 	CDEBUG(D_WARNING, "%-24s %4d %5s %5d %5d %5d %5d %5d %ld\n",
-	       libcfs_nid2str(lp->lpni_nid), kref_read(&lp->lpni_kref),
+	       libcfs_nidstr(&lp->lpni_nid), kref_read(&lp->lpni_kref),
 	       aliveness, lp->lpni_net->net_tunables.lct_peer_tx_credits,
 	       lp->lpni_rtrcredits, lp->lpni_minrtrcredits,
 	       lp->lpni_txcredits, lp->lpni_mintxcredits, lp->lpni_txqnob);
@@ -3944,6 +3948,8 @@ void lnet_peer_discovery_stop(void)
 		struct list_head *peers = &peer_table->pt_hash[j];
 
 		list_for_each_entry(lp, peers, lpni_hashlist) {
+			if (!nid_is_nid4(&lp->lpni_nid))
+				continue;
 			if (peer_index-- > 0)
 				continue;
 
@@ -3954,7 +3960,7 @@ void lnet_peer_discovery_stop(void)
 					 lnet_is_peer_ni_alive(lp)
 					 ? "up" : "down");
 
-			*nid = lp->lpni_nid;
+			*nid = lnet_nid_to_nid4(&lp->lpni_nid);
 			*refcount = kref_read(&lp->lpni_kref);
 			*ni_peer_tx_credits =
 				lp->lpni_net->net_tunables.lct_peer_tx_credits;
@@ -4028,7 +4034,9 @@ int lnet_get_peer_info(struct lnet_ioctl_peer_cfg *cfg, void __user *bulk)
 	lpni = NULL;
 	rc = -EFAULT;
 	while ((lpni = lnet_get_next_peer_ni_locked(lp, NULL, lpni)) != NULL) {
-		nid = lpni->lpni_nid;
+		if (!nid_is_nid4(&lpni->lpni_nid))
+			continue;
+		nid = lnet_nid_to_nid4(&lpni->lpni_nid);
 		if (copy_to_user(bulk, &nid, sizeof(nid)))
 			goto out_free_hstats;
 		bulk += sizeof(nid);
@@ -4117,7 +4125,7 @@ int lnet_get_peer_info(struct lnet_ioctl_peer_cfg *cfg, void __user *bulk)
 	if (!lpni->lpni_last_alive) {
 		CDEBUG(D_NET,
 		       "lpni %s(%p) not eligible for recovery last alive %lld\n",
-		       libcfs_nid2str(lpni->lpni_nid), lpni,
+		       libcfs_nidstr(&lpni->lpni_nid), lpni,
 		       lpni->lpni_last_alive);
 		return;
 	}
@@ -4125,7 +4133,7 @@ int lnet_get_peer_info(struct lnet_ioctl_peer_cfg *cfg, void __user *bulk)
 	if (lnet_recovery_limit &&
 	    now > lpni->lpni_last_alive + lnet_recovery_limit) {
 		CDEBUG(D_NET, "lpni %s aged out last alive %lld\n",
-		       libcfs_nid2str(lpni->lpni_nid),
+		       libcfs_nidstr(&lpni->lpni_nid),
 		       lpni->lpni_last_alive);
 		/* Reset the ping count so that if this peer NI is added back to
 		 * the recovery queue we will send the first ping right away.
@@ -4141,7 +4149,7 @@ int lnet_get_peer_info(struct lnet_ioctl_peer_cfg *cfg, void __user *bulk)
 
 	CDEBUG(D_NET,
 	       "%s added to recovery queue. ping count: %u next ping: %lld last alive: %lld health: %d\n",
-	       libcfs_nid2str(lpni->lpni_nid),
+	       libcfs_nidstr(&lpni->lpni_nid),
 	       lpni->lpni_ping_count,
 	       lpni->lpni_next_ping,
 	       lpni->lpni_last_alive,
diff --git a/net/lnet/lnet/router.c b/net/lnet/lnet/router.c
index 6335425..f6fcc93 100644
--- a/net/lnet/lnet/router.c
+++ b/net/lnet/lnet/router.c
@@ -1198,7 +1198,7 @@ bool lnet_router_checker_active(void)
 
 		/* discover the router */
 		CDEBUG(D_NET, "discover %s, cpt = %d\n",
-		       libcfs_nid2str(lpni->lpni_nid), cpt);
+		       libcfs_nidstr(&lpni->lpni_nid), cpt);
 		rc = lnet_discover_peer_locked(lpni, cpt, false);
 
 		/* drop ref taken above */
@@ -1772,7 +1772,8 @@ bool lnet_router_checker_active(void)
 		 */
 		if (lnet_is_discovery_disabled(lp)) {
 			list_for_each_entry(route, &lp->lp_routes, lr_gwlist) {
-				if (route->lr_nid == lpni->lpni_nid)
+				if (route->lr_nid ==
+				    lnet_nid_to_nid4(&lpni->lpni_nid))
 					lnet_set_route_aliveness(route, alive);
 			}
 		}
@@ -1781,7 +1782,7 @@ bool lnet_router_checker_active(void)
 	lnet_net_unlock(0);
 
 	if (ni && !alive)
-		lnet_notify_peer_down(ni, lpni->lpni_nid);
+		lnet_notify_peer_down(ni, lnet_nid_to_nid4(&lpni->lpni_nid));
 
 	cpt = lpni->lpni_cpt;
 	lnet_net_lock(cpt);
diff --git a/net/lnet/lnet/router_proc.c b/net/lnet/lnet/router_proc.c
index 6649f06..1a04ac4 100644
--- a/net/lnet/lnet/router_proc.c
+++ b/net/lnet/lnet/router_proc.c
@@ -474,7 +474,7 @@ static int proc_lnet_peers(struct ctl_table *table, int write,
 		}
 
 		if (peer) {
-			lnet_nid_t nid = peer->lpni_nid;
+			struct lnet_nid nid = peer->lpni_nid;
 			int nrefs = kref_read(&peer->lpni_kref);
 			time64_t lastalive = -1;
 			char *aliveness = "NA";
@@ -495,7 +495,7 @@ static int proc_lnet_peers(struct ctl_table *table, int write,
 
 			s += scnprintf(s, tmpstr + tmpsiz - s,
 				       "%-24s %4d %5s %5lld %5d %5d %5d %5d %5d %d\n",
-				       libcfs_nid2str(nid), nrefs, aliveness,
+				       libcfs_nidstr(&nid), nrefs, aliveness,
 				       lastalive, maxcr, rtrcr, minrtrcr, txcr,
 				       mintxcr, txqnob);
 			LASSERT(tmpstr + tmpsiz - s > 0);
diff --git a/net/lnet/lnet/udsp.c b/net/lnet/lnet/udsp.c
index 4495062..03669e6 100644
--- a/net/lnet/lnet/udsp.c
+++ b/net/lnet/lnet/udsp.c
@@ -255,7 +255,7 @@ enum udsp_apply {
 									    lpni)) != NULL) {
 					if (!lnet_get_net_locked(lpni->lpni_peer_net->lpn_net_id))
 						continue;
-					gw_nid = lpni->lpni_nid;
+					gw_nid = lnet_nid_to_nid4(&lpni->lpni_nid);
 					rc = cfs_match_nid_net(gw_nid,
 							       rte_action->ud_net_id.udn_net_type,
 							       &rte_action->ud_net_id.udn_net_num_range,
@@ -437,7 +437,7 @@ enum udsp_apply {
 					CDEBUG(D_NET,
 					       "%spref rtr nids from lpni %s\n",
 					       (revert) ? "revert " : "clear ",
-					       libcfs_nid2str(lpni->lpni_nid));
+					       libcfs_nidstr(&lpni->lpni_nid));
 					lnet_peer_clr_pref_rtrs(lpni);
 					cleared = true;
 					if (revert) {
@@ -448,7 +448,7 @@ enum udsp_apply {
 				CDEBUG(D_NET,
 				       "add gw nid %s as preferred for peer %s\n",
 				       libcfs_nid2str(gw_nid),
-				       libcfs_nid2str(lpni->lpni_nid));
+				       libcfs_nidstr(&lpni->lpni_nid));
 				/* match. Add to pref NIDs */
 				rc = lnet_peer_add_pref_rtr(lpni, gw_nid);
 				lnet_net_lock(LNET_LOCK_EX);
@@ -456,7 +456,7 @@ enum udsp_apply {
 				if (rc && rc != -EEXIST) {
 					CERROR("Failed to add %s to %s pref rtr list\n",
 					       libcfs_nid2str(gw_nid),
-					       libcfs_nid2str(lpni->lpni_nid));
+					       libcfs_nidstr(&lpni->lpni_nid));
 					return rc;
 				}
 			}
@@ -492,7 +492,7 @@ enum udsp_apply {
 				lnet_peer_clr_pref_nids(lpni);
 				CDEBUG(D_NET, "%spref nids from lpni %s\n",
 				       (revert) ? "revert " : "clear ",
-				       libcfs_nid2str(lpni->lpni_nid));
+				       libcfs_nidstr(&lpni->lpni_nid));
 				cleared = true;
 				if (revert) {
 					lnet_net_lock(LNET_LOCK_EX);
@@ -501,7 +501,7 @@ enum udsp_apply {
 			}
 			CDEBUG(D_NET, "add nid %s as preferred for peer %s\n",
 			       libcfs_nidstr(&ni->ni_nid),
-			       libcfs_nid2str(lpni->lpni_nid));
+			       libcfs_nidstr(&lpni->lpni_nid));
 			/* match. Add to pref NIDs */
 			rc = lnet_peer_add_pref_nid(lpni,
 						    lnet_nid_to_nid4(&ni->ni_nid));
@@ -510,7 +510,7 @@ enum udsp_apply {
 			if (rc && rc != -EEXIST) {
 				CERROR("Failed to add %s to %s pref nid list\n",
 				       libcfs_nidstr(&ni->ni_nid),
-				       libcfs_nid2str(lpni->lpni_nid));
+				       libcfs_nidstr(&lpni->lpni_nid));
 				return rc;
 			}
 		}
@@ -530,7 +530,7 @@ enum udsp_apply {
 	bool local = udi->udi_local;
 	enum lnet_udsp_action_type type = udi->udi_type;
 
-	rc = cfs_match_nid_net(lpni->lpni_nid,
+	rc = cfs_match_nid_net(lnet_nid_to_nid4(&lpni->lpni_nid),
 			       lp_match->ud_net_id.udn_net_type,
 			       &lp_match->ud_net_id.udn_net_num_range,
 			       &lp_match->ud_addr_range);
@@ -629,7 +629,7 @@ enum udsp_apply {
 						    lpni_peer_nis) {
 					CDEBUG(D_NET,
 					       "udsp examining lpni %s\n",
-					       libcfs_nid2str(lpni->lpni_nid));
+					       libcfs_nidstr(&lpni->lpni_nid));
 					udi->udi_lpni = lpni;
 					rc = lnet_udsp_apply_rule_on_lpni(udi);
 					if (rc)
@@ -1017,7 +1017,7 @@ struct lnet_udsp *
 
 	info->cud_nid_priority = lpni->lpni_sel_priority;
 	CDEBUG(D_NET, "lpni %s has %d pref nids\n",
-	       libcfs_nid2str(lpni->lpni_nid),
+	       libcfs_nidstr(&lpni->lpni_nid),
 	       lpni->lpni_pref_nnids);
 	if (lpni->lpni_pref_nnids == 1) {
 		info->cud_pref_nid[0] = lpni->lpni_pref.nid;
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
