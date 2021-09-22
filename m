Return-Path: <SRS0=2ypu=OM=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 91BE7C433F5
	for <lustre-devel@archiver.kernel.org>; Wed, 22 Sep 2021 02:21:39 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 5374A610A1
	for <lustre-devel@archiver.kernel.org>; Wed, 22 Sep 2021 02:21:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.1 mail.kernel.org 5374A610A1
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 74EE921F253;
	Tue, 21 Sep 2021 19:21:38 -0700 (PDT)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 70C9121CBCE
 for <lustre-devel@lists.lustre.org>; Tue, 21 Sep 2021 19:20:07 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 14444357;
 Tue, 21 Sep 2021 22:20:04 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 08136FF4C2; Tue, 21 Sep 2021 22:20:04 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Tue, 21 Sep 2021 22:19:43 -0400
Message-Id: <1632277201-6920-7-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1632277201-6920-1-git-send-email-jsimmons@infradead.org>
References: <1632277201-6920-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 06/24] lnet: change lp_primary_nid to struct
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

Change lp_primary_nid in struct lnet_peer to struct lnet_nid.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10391
Lustre-commit: 36dd83ee8e143a472 ("LU-10391 lnet: change lp_primary_nid to struct lnet_nid")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/42102
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Chris Horn <chris.horn@hpe.com>
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/lib-lnet.h  |  10 +-
 include/linux/lnet/lib-types.h |   2 +-
 net/lnet/lnet/api-ni.c         |  46 +++++--
 net/lnet/lnet/lib-move.c       |   7 +-
 net/lnet/lnet/peer.c           | 297 +++++++++++++++++++++++------------------
 net/lnet/lnet/router.c         |  38 +++---
 net/lnet/lnet/router_proc.c    |   4 +-
 net/lnet/lnet/udsp.c           |   6 +-
 8 files changed, 238 insertions(+), 172 deletions(-)

diff --git a/include/linux/lnet/lib-lnet.h b/include/linux/lnet/lib-lnet.h
index 05c099d..a4ec067 100644
--- a/include/linux/lnet/lib-lnet.h
+++ b/include/linux/lnet/lib-lnet.h
@@ -480,7 +480,8 @@ struct lnet_ni *
 extern struct lnet_lnd the_lolnd;
 extern int avoid_asym_router_failure;
 
-unsigned int lnet_nid_cpt_hash(lnet_nid_t nid, unsigned int number);
+unsigned int lnet_nid_cpt_hash(struct lnet_nid *nid,
+			       unsigned int number);
 int lnet_cpt_of_nid_locked(struct lnet_nid *nid, struct lnet_ni *ni);
 int lnet_cpt_of_nid(lnet_nid_t nid, struct lnet_ni *ni);
 struct lnet_ni *lnet_nid2ni_locked(lnet_nid_t nid, int cpt);
@@ -838,6 +839,7 @@ struct lnet_peer_ni *lnet_nid2peerni_locked(lnet_nid_t nid, lnet_nid_t pref,
 struct lnet_peer_ni *lnet_peer_get_ni_locked(struct lnet_peer *lp,
 					     lnet_nid_t nid);
 struct lnet_peer_ni *lnet_find_peer_ni_locked(lnet_nid_t nid);
+struct lnet_peer_ni *lnet_peer_ni_find_locked(struct lnet_nid *nid);
 struct lnet_peer *lnet_find_peer(lnet_nid_t nid);
 void lnet_peer_net_added(struct lnet_net *net);
 lnet_nid_t lnet_peer_primary_nid_locked(lnet_nid_t nid);
@@ -905,8 +907,8 @@ int lnet_get_peer_ni_info(u32 peer_index, u64 *nid,
 static inline bool
 lnet_peer_ni_is_primary(struct lnet_peer_ni *lpni)
 {
-	return lnet_nid_to_nid4(&lpni->lpni_nid) ==
-			lpni->lpni_peer_net->lpn_peer->lp_primary_nid;
+	return nid_same(&lpni->lpni_nid,
+			 &lpni->lpni_peer_net->lpn_peer->lp_primary_nid);
 }
 
 bool lnet_peer_is_uptodate(struct lnet_peer *lp);
@@ -1081,7 +1083,7 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 	if (old != alive)
 		CERROR("route to %s through %s has gone from %s to %s\n",
 		       libcfs_net2str(route->lr_net),
-		       libcfs_nid2str(route->lr_gateway->lp_primary_nid),
+		       libcfs_nidstr(&route->lr_gateway->lp_primary_nid),
 		       old ? "up" : "down",
 		       alive ? "up" : "down");
 }
diff --git a/include/linux/lnet/lib-types.h b/include/linux/lnet/lib-types.h
index a6223d2..f980f2f 100644
--- a/include/linux/lnet/lib-types.h
+++ b/include/linux/lnet/lib-types.h
@@ -669,7 +669,7 @@ struct lnet_peer {
 	struct list_head	lp_rtr_list;
 
 	/* primary NID of the peer */
-	lnet_nid_t		lp_primary_nid;
+	struct lnet_nid		lp_primary_nid;
 
 	/* source NID to use during discovery */
 	lnet_nid_t		lp_disc_src_nid;
diff --git a/net/lnet/lnet/api-ni.c b/net/lnet/lnet/api-ni.c
index 3ae88fc..f5b022f 100644
--- a/net/lnet/lnet/api-ni.c
+++ b/net/lnet/lnet/api-ni.c
@@ -1433,8 +1433,8 @@ struct lnet_net *
 	return false;
 }
 
-unsigned int
-lnet_nid_cpt_hash(lnet_nid_t nid, unsigned int number)
+static unsigned int
+lnet_nid4_cpt_hash(lnet_nid_t nid, unsigned int number)
 {
 	u64 key = nid;
 	unsigned int val;
@@ -1452,12 +1452,33 @@ struct lnet_net *
 	return (unsigned int)(key + val + (val >> 1)) % number;
 }
 
+unsigned int
+lnet_nid_cpt_hash(struct lnet_nid *nid, unsigned int number)
+{
+	unsigned int val;
+	u32 h = 0;
+	int i;
+
+	LASSERT(number >= 1 && number <= LNET_CPT_NUMBER);
+
+	if (number == 1)
+		return 0;
+
+	if (nid_is_nid4(nid))
+		return lnet_nid4_cpt_hash(lnet_nid_to_nid4(nid), number);
+
+	for (i = 0; i < 4; i++)
+		h = hash_32(nid->nid_addr[i] ^ h, 32);
+	val = hash_32(LNET_NID_NET(nid) ^ h, LNET_CPT_BITS);
+	if (val < number)
+		return val;
+	return (unsigned int)(h + val + (val >> 1)) % number;
+}
+
 int
 lnet_cpt_of_nid_locked(struct lnet_nid *nid, struct lnet_ni *ni)
 {
 	struct lnet_net *net;
-	/* FIXME handle long-addr nid */
-	lnet_nid_t nid4 = lnet_nid_to_nid4(nid);
 
 	/* must called with hold of lnet_net_lock */
 	if (LNET_CPT_NUMBER == 1)
@@ -1472,20 +1493,19 @@ struct lnet_net *
 	 */
 	if (ni) {
 		if (ni->ni_cpts)
-			return ni->ni_cpts[lnet_nid_cpt_hash(nid4,
+			return ni->ni_cpts[lnet_nid_cpt_hash(nid,
 							     ni->ni_ncpts)];
 		else
-			return lnet_nid_cpt_hash(nid4, LNET_CPT_NUMBER);
+			return lnet_nid_cpt_hash(nid, LNET_CPT_NUMBER);
 	}
 
 	/* no NI provided so look at the net */
 	net = lnet_get_net_locked(LNET_NID_NET(nid));
 
-	if (net && net->net_cpts) {
-		return net->net_cpts[lnet_nid_cpt_hash(nid4, net->net_ncpts)];
-	}
+	if (net && net->net_cpts)
+		return net->net_cpts[lnet_nid_cpt_hash(nid, net->net_ncpts)];
 
-	return lnet_nid_cpt_hash(nid4, LNET_CPT_NUMBER);
+	return lnet_nid_cpt_hash(nid, LNET_CPT_NUMBER);
 }
 
 int
@@ -4240,7 +4260,8 @@ u32 lnet_get_dlc_seq_locked(void)
 		mutex_lock(&the_lnet.ln_api_mutex);
 		lp = lnet_find_peer(ping->ping_id.nid);
 		if (lp) {
-			ping->ping_id.nid = lp->lp_primary_nid;
+			ping->ping_id.nid =
+				lnet_nid_to_nid4(&lp->lp_primary_nid);
 			ping->mr_info = lnet_peer_is_multi_rail(lp);
 			lnet_peer_decref_locked(lp);
 		}
@@ -4263,7 +4284,8 @@ u32 lnet_get_dlc_seq_locked(void)
 		mutex_lock(&the_lnet.ln_api_mutex);
 		lp = lnet_find_peer(discover->ping_id.nid);
 		if (lp) {
-			discover->ping_id.nid = lp->lp_primary_nid;
+			discover->ping_id.nid =
+				lnet_nid_to_nid4(&lp->lp_primary_nid);
 			discover->mr_info = lnet_peer_is_multi_rail(lp);
 			lnet_peer_decref_locked(lp);
 		}
diff --git a/net/lnet/lnet/lib-move.c b/net/lnet/lnet/lib-move.c
index 9a2fdb6..8c8db31 100644
--- a/net/lnet/lnet/lib-move.c
+++ b/net/lnet/lnet/lib-move.c
@@ -1324,7 +1324,7 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 	list_for_each_entry(route, &rnet->lrn_routes, lr_list) {
 		if (!lnet_is_route_alive(route))
 			continue;
-		gw_pnid = route->lr_gateway->lp_primary_nid;
+		gw_pnid = lnet_nid_to_nid4(&route->lr_gateway->lp_primary_nid);
 
 		/* no protection on below fields, but it's harmless */
 		if (last_route && (last_route->lr_seq - route->lr_seq < 0))
@@ -1938,7 +1938,7 @@ struct lnet_ni *
 	lnet_peer_ni_decref_locked(new_lpni);
 
 	CDEBUG(D_NET, "msg %p delayed. %s pending discovery\n",
-	       msg, libcfs_nid2str(peer->lp_primary_nid));
+	       msg, libcfs_nidstr(&peer->lp_primary_nid));
 
 	return LNET_DC_WAIT;
 }
@@ -4831,7 +4831,8 @@ struct lnet_msg *
 	       libcfs_nidstr(&ni->ni_nid), libcfs_id2str(peer_id), getmd);
 
 	/* setup information for lnet_build_msg_event */
-	msg->msg_initiator = getmsg->msg_txpeer->lpni_peer_net->lpn_peer->lp_primary_nid;
+	msg->msg_initiator =
+		lnet_nid_to_nid4(&getmsg->msg_txpeer->lpni_peer_net->lpn_peer->lp_primary_nid);
 	msg->msg_from = peer_id.nid;
 	msg->msg_type = LNET_MSG_GET; /* flag this msg as an "optimized" GET */
 	msg->msg_hdr.src_nid = peer_id.nid;
diff --git a/net/lnet/lnet/peer.c b/net/lnet/lnet/peer.c
index 4629a8b..7f2c6f3 100644
--- a/net/lnet/lnet/peer.c
+++ b/net/lnet/lnet/peer.c
@@ -107,13 +107,15 @@
 }
 
 static struct lnet_peer_ni *
-lnet_peer_ni_alloc(lnet_nid_t nid)
+lnet_peer_ni_alloc(lnet_nid_t nid4)
 {
 	struct lnet_peer_ni *lpni;
 	struct lnet_net *net;
+	struct lnet_nid nid;
 	int cpt;
 
-	cpt = lnet_nid_cpt_hash(nid, LNET_CPT_NUMBER);
+	lnet_nid4_to_nid(nid4, &nid);
+	cpt = lnet_nid_cpt_hash(&nid, LNET_CPT_NUMBER);
 
 	lpni = kzalloc_cpt(sizeof(*lpni), GFP_KERNEL, cpt);
 	if (!lpni)
@@ -136,11 +138,11 @@
 	else
 		lpni->lpni_ns_status = LNET_NI_STATUS_UP;
 	lpni->lpni_ping_feats = LNET_PING_FEAT_INVAL;
-	lnet_nid4_to_nid(nid, &lpni->lpni_nid);
+	lpni->lpni_nid = nid;
 	lpni->lpni_cpt = cpt;
 	atomic_set(&lpni->lpni_healthv, LNET_MAX_HEALTH_VALUE);
 
-	net = lnet_get_net_locked(LNET_NIDNET(nid));
+	net = lnet_get_net_locked(LNET_NID_NET(&nid));
 	lpni->lpni_net = net;
 	if (net) {
 		lpni->lpni_txcredits = net->net_tunables.lct_peer_tx_credits;
@@ -202,10 +204,12 @@
 }
 
 static struct lnet_peer *
-lnet_peer_alloc(lnet_nid_t nid)
+lnet_peer_alloc(lnet_nid_t nid4)
 {
 	struct lnet_peer *lp;
+	struct lnet_nid nid;
 
+	lnet_nid4_to_nid(nid4, &nid);
 	lp = kzalloc_cpt(sizeof(*lp), GFP_KERNEL, CFS_CPT_ANY);
 	if (!lp)
 		return NULL;
@@ -239,11 +243,11 @@
 	 * to ever use a different interface when sending messages to
 	 * myself.
 	 */
-	if (nid == LNET_NID_LO_0)
+	if (nid_is_lo0(&nid))
 		lp->lp_state = LNET_PEER_NO_DISCOVERY;
-	lp->lp_cpt = lnet_nid_cpt_hash(nid, LNET_CPT_NUMBER);
+	lp->lp_cpt = lnet_nid_cpt_hash(&nid, LNET_CPT_NUMBER);
 
-	CDEBUG(D_NET, "%p nid %s\n", lp, libcfs_nid2str(lp->lp_primary_nid));
+	CDEBUG(D_NET, "%p nid %s\n", lp, libcfs_nidstr(&lp->lp_primary_nid));
 
 	return lp;
 }
@@ -251,7 +255,7 @@
 void
 lnet_destroy_peer_locked(struct lnet_peer *lp)
 {
-	CDEBUG(D_NET, "%p nid %s\n", lp, libcfs_nid2str(lp->lp_primary_nid));
+	CDEBUG(D_NET, "%p nid %s\n", lp, libcfs_nidstr(&lp->lp_primary_nid));
 
 	LASSERT(atomic_read(&lp->lp_refcount) == 0);
 	LASSERT(lp->lp_rtr_refcount == 0);
@@ -333,7 +337,7 @@
 		wake_up(&the_lnet.ln_dc_waitq);
 	}
 	CDEBUG(D_NET, "peer %s NID %s\n",
-	       libcfs_nid2str(lp->lp_primary_nid),
+	       libcfs_nidstr(&lp->lp_primary_nid),
 	       libcfs_nidstr(&lpni->lpni_nid));
 }
 
@@ -448,7 +452,7 @@ void lnet_peer_uninit(void)
 	struct lnet_peer_ni *lpni = NULL, *lpni2;
 	int rc = 0, rc2 = 0;
 
-	CDEBUG(D_NET, "peer %s\n", libcfs_nid2str(peer->lp_primary_nid));
+	CDEBUG(D_NET, "peer %s\n", libcfs_nidstr(&peer->lp_primary_nid));
 
 	spin_lock(&peer->lp_lock);
 	peer->lp_state |= LNET_PEER_MARK_DELETED;
@@ -517,13 +521,15 @@ static void lnet_peer_cancel_discovery(struct lnet_peer *lp)
  *  -EBUSY:  The lnet_peer_ni is the primary, and not the only peer_ni.
  */
 static int
-lnet_peer_del_nid(struct lnet_peer *lp, lnet_nid_t nid, unsigned int flags)
+lnet_peer_del_nid(struct lnet_peer *lp, lnet_nid_t nid4, unsigned int flags)
 {
 	struct lnet_peer_ni *lpni;
-	lnet_nid_t primary_nid = lp->lp_primary_nid;
+	struct lnet_nid primary_nid = lp->lp_primary_nid;
+	struct lnet_nid nid;
 	int rc = 0;
 	bool force = (flags & LNET_PEER_RTR_NI_FORCE_DEL) ? true : false;
 
+	lnet_nid4_to_nid(nid4, &nid);
 	if (!(flags & LNET_PEER_CONFIGURED)) {
 		if (lp->lp_state & LNET_PEER_CONFIGURED) {
 			rc = -EPERM;
@@ -535,12 +541,12 @@ static void lnet_peer_cancel_discovery(struct lnet_peer *lp)
 	 * deleting it
 	 */
 	if (lp->lp_state & LNET_PEER_LOCK_PRIMARY &&
-	    primary_nid == nid) {
+	    nid_same(&primary_nid, &nid)) {
 		rc = -EPERM;
 		goto out;
 	}
 
-	lpni = lnet_find_peer_ni_locked(nid);
+	lpni = lnet_peer_ni_find_locked(&nid);
 	if (!lpni) {
 		rc = -ENOENT;
 		goto out;
@@ -555,19 +561,19 @@ static void lnet_peer_cancel_discovery(struct lnet_peer *lp)
 	 * This function only allows deletion of the primary NID if it
 	 * is the only NID.
 	 */
-	if (nid == lp->lp_primary_nid && lp->lp_nnis != 1 && !force) {
+	if (nid_same(&nid, &lp->lp_primary_nid) && lp->lp_nnis != 1 && !force) {
 		rc = -EBUSY;
 		goto out;
 	}
 
 	lnet_net_lock(LNET_LOCK_EX);
 
-	if (nid == lp->lp_primary_nid && lp->lp_nnis != 1 && force) {
+	if (nid_same(&nid, &lp->lp_primary_nid) && lp->lp_nnis != 1 && force) {
 		struct lnet_peer_ni *lpni2;
 		/* assign the next peer_ni to be the primary */
 		lpni2 = lnet_get_next_peer_ni_locked(lp, NULL, lpni);
 		LASSERT(lpni2);
-		lp->lp_primary_nid = lnet_nid_to_nid4(&lpni2->lpni_nid);
+		lp->lp_primary_nid = lpni2->lpni_nid;
 	}
 	rc = lnet_peer_ni_del_locked(lpni, force);
 
@@ -575,7 +581,8 @@ static void lnet_peer_cancel_discovery(struct lnet_peer *lp)
 
 out:
 	CDEBUG(D_NET, "peer %s NID %s flags %#x: %d\n",
-	       libcfs_nid2str(primary_nid), libcfs_nid2str(nid), flags, rc);
+	       libcfs_nidstr(&primary_nid), libcfs_nidstr(&nid),
+	       flags, rc);
 
 	return rc;
 }
@@ -596,8 +603,8 @@ static void lnet_peer_cancel_discovery(struct lnet_peer *lp)
 				continue;
 
 			peer = lpni->lpni_peer_net->lpn_peer;
-			if (peer->lp_primary_nid !=
-			    lnet_nid_to_nid4(&lpni->lpni_nid)) {
+			if (!nid_same(&peer->lp_primary_nid,
+				      &lpni->lpni_nid)) {
 				lnet_peer_ni_del_locked(lpni, false);
 				continue;
 			}
@@ -643,8 +650,8 @@ static void lnet_peer_cancel_discovery(struct lnet_peer *lp)
 			if (!lnet_isrouter(lp))
 				continue;
 
-			gw_nid = lp->lpni_peer_net->lpn_peer->lp_primary_nid;
-
+			/* FIXME handle large-addr nid */
+			gw_nid = lnet_nid_to_nid4(&lp->lpni_peer_net->lpn_peer->lp_primary_nid);
 			lnet_net_unlock(LNET_LOCK_EX);
 			lnet_del_route(LNET_NET_ANY, gw_nid);
 			lnet_net_lock(LNET_LOCK_EX);
@@ -712,7 +719,7 @@ struct lnet_peer_ni *
 
 	lnet_nid4_to_nid(nid4, &nid);
 
-	cpt = lnet_nid_cpt_hash(nid4, LNET_CPT_NUMBER);
+	cpt = lnet_nid_cpt_hash(&nid, LNET_CPT_NUMBER);
 
 	ptable = the_lnet.ln_peer_tables[cpt];
 	lpni = lnet_get_peer_ni_locked(ptable, &nid);
@@ -721,6 +728,21 @@ struct lnet_peer_ni *
 }
 
 struct lnet_peer_ni *
+lnet_peer_ni_find_locked(struct lnet_nid *nid)
+{
+	struct lnet_peer_ni *lpni;
+	struct lnet_peer_table *ptable;
+	int cpt;
+
+	cpt = lnet_nid_cpt_hash(nid, LNET_CPT_NUMBER);
+
+	ptable = the_lnet.ln_peer_tables[cpt];
+	lpni = lnet_get_peer_ni_locked(ptable, nid);
+
+	return lpni;
+}
+
+struct lnet_peer_ni *
 lnet_peer_get_ni_locked(struct lnet_peer *lp, lnet_nid_t nid)
 {
 	struct lnet_peer_net *lpn;
@@ -896,9 +918,11 @@ struct lnet_peer_ni *
 	for (cpt = 0; cpt < lncpt; cpt++) {
 		ptable = the_lnet.ln_peer_tables[cpt];
 		list_for_each_entry(lp, &ptable->pt_peer_list, lp_peer_list) {
+			if (!nid_is_nid4(&lp->lp_primary_nid))
+				continue;
 			if (i >= count)
 				goto done;
-			id.nid = lp->lp_primary_nid;
+			id.nid = lnet_nid_to_nid4(&lp->lp_primary_nid);
 			if (copy_to_user(&ids[i], &id, sizeof(id)))
 				goto done;
 			i++;
@@ -1205,7 +1229,7 @@ struct lnet_peer_ni *
 		spin_unlock(&lpni->lpni_lock);
 	}
 	CDEBUG(D_NET, "peer %s nid %s: %d\n",
-	       libcfs_nid2str(lp->lp_primary_nid), libcfs_nid2str(nid), rc);
+	       libcfs_nidstr(&lp->lp_primary_nid), libcfs_nid2str(nid), rc);
 	return rc;
 }
 
@@ -1263,7 +1287,7 @@ struct lnet_peer_ni *
 	kfree(ne);
 out:
 	CDEBUG(D_NET, "peer %s nid %s: %d\n",
-	       libcfs_nid2str(lp->lp_primary_nid), libcfs_nid2str(nid), rc);
+	       libcfs_nidstr(&lp->lp_primary_nid), libcfs_nid2str(nid), rc);
 	return rc;
 }
 
@@ -1293,12 +1317,13 @@ struct lnet_peer_ni *
 lnet_nid_t
 lnet_peer_primary_nid_locked(lnet_nid_t nid)
 {
+	/* FIXME handle large-addr nid */
 	struct lnet_peer_ni *lpni;
 	lnet_nid_t primary_nid = nid;
 
 	lpni = lnet_find_peer_ni_locked(nid);
 	if (lpni) {
-		primary_nid = lpni->lpni_peer_net->lpn_peer->lp_primary_nid;
+		primary_nid = lnet_nid_to_nid4(&lpni->lpni_peer_net->lpn_peer->lp_primary_nid);
 		lnet_peer_ni_decref_locked(lpni);
 	}
 
@@ -1379,6 +1404,7 @@ struct lnet_peer_ni *
 }
 EXPORT_SYMBOL(LNetAddPeer);
 
+/* FIXME support large-addr nid */
 lnet_nid_t
 LNetPrimaryNID(lnet_nid_t nid)
 {
@@ -1428,7 +1454,7 @@ struct lnet_peer_ni *
 		}
 		lp = lpni->lpni_peer_net->lpn_peer;
 	}
-	primary_nid = lp->lp_primary_nid;
+	primary_nid = lnet_nid_to_nid4(&lp->lp_primary_nid);
 out_decref:
 	lnet_peer_ni_decref_locked(lpni);
 out_unlock:
@@ -1495,7 +1521,7 @@ struct lnet_peer_net *
 
 	/* Add peer_ni to peer_net */
 	lpni->lpni_peer_net = lpn;
-	if (lp->lp_primary_nid == lnet_nid_to_nid4(&lpni->lpni_nid))
+	if (nid_same(&lp->lp_primary_nid, &lpni->lpni_nid))
 		list_add(&lpni->lpni_peer_nis, &lpn->lpn_peer_nis);
 	else
 		list_add_tail(&lpni->lpni_peer_nis, &lpn->lpn_peer_nis);
@@ -1506,7 +1532,7 @@ struct lnet_peer_net *
 	if (!lpn->lpn_peer) {
 		new_lpn = true;
 		lpn->lpn_peer = lp;
-		if (lp->lp_primary_nid == lnet_nid_to_nid4(&lpni->lpni_nid))
+		if (nid_same(&lp->lp_primary_nid, &lpni->lpni_nid))
 			list_add(&lpn->lpn_peer_nets, &lp->lp_peer_nets);
 		else
 			list_add_tail(&lpn->lpn_peer_nets, &lp->lp_peer_nets);
@@ -1552,7 +1578,7 @@ struct lnet_peer_net *
 		       libcfs_nidstr(&lpni->lpni_nid));
 
 	CDEBUG(D_NET, "peer %s NID %s flags %#x\n",
-	       libcfs_nid2str(lp->lp_primary_nid),
+	       libcfs_nidstr(&lp->lp_primary_nid),
 	       libcfs_nidstr(&lpni->lpni_nid), flags);
 	lnet_peer_ni_decref_locked(lpni);
 	lnet_net_unlock(LNET_LOCK_EX);
@@ -1591,13 +1617,13 @@ struct lnet_peer_net *
 		 * that an existing peer is being modified.
 		 */
 		if (lp->lp_state & LNET_PEER_CONFIGURED) {
-			if (lp->lp_primary_nid != nid)
+			if (lnet_nid_to_nid4(&lp->lp_primary_nid) != nid)
 				rc = -EEXIST;
 			else if ((lp->lp_state ^ flags) & LNET_PEER_MULTI_RAIL)
 				rc = -EPERM;
 			goto out;
 		} else if (!(flags & LNET_PEER_CONFIGURED)) {
-			if (lp->lp_primary_nid == nid) {
+			if (lnet_nid_to_nid4(&lp->lp_primary_nid) == nid) {
 				rc = -EEXIST;
 				goto out;
 			}
@@ -1757,7 +1783,7 @@ struct lnet_peer_net *
 	lnet_peer_ni_decref_locked(lpni);
 out:
 	CDEBUG(D_NET, "peer %s NID %s flags %#x: %d\n",
-	       libcfs_nid2str(lp->lp_primary_nid), libcfs_nid2str(nid),
+	       libcfs_nidstr(&lp->lp_primary_nid), libcfs_nid2str(nid),
 	       flags, rc);
 	return rc;
 }
@@ -1771,14 +1797,14 @@ struct lnet_peer_net *
 lnet_peer_set_primary_nid(struct lnet_peer *lp, lnet_nid_t nid,
 			  unsigned int flags)
 {
-	lnet_nid_t old = lp->lp_primary_nid;
+	struct lnet_nid old = lp->lp_primary_nid;
 	int rc = 0;
 
-	if (lp->lp_primary_nid == nid)
+	if (lnet_nid_to_nid4(&lp->lp_primary_nid) == nid)
 		goto out;
 
 	if (!(lp->lp_state & LNET_PEER_LOCK_PRIMARY))
-		lp->lp_primary_nid = nid;
+		lnet_nid4_to_nid(nid, &lp->lp_primary_nid);
 
 	rc = lnet_peer_add_nid(lp, nid, flags);
 	if (rc) {
@@ -1795,7 +1821,7 @@ struct lnet_peer_net *
 		return 0;
 
 	CDEBUG(D_NET, "peer %s NID %s: %d\n",
-	       libcfs_nid2str(old), libcfs_nid2str(nid), rc);
+	       libcfs_nidstr(&old), libcfs_nid2str(nid), rc);
 
 	return rc;
 }
@@ -1906,10 +1932,10 @@ struct lnet_peer_net *
 	}
 
 	/* Primary NID must match */
-	if (lp->lp_primary_nid != prim_nid) {
+	if (lnet_nid_to_nid4(&lp->lp_primary_nid) != prim_nid) {
 		CDEBUG(D_NET, "prim_nid %s is not primary for peer %s\n",
 		       libcfs_nid2str(prim_nid),
-		       libcfs_nid2str(lp->lp_primary_nid));
+		       libcfs_nidstr(&lp->lp_primary_nid));
 		return -ENODEV;
 	}
 
@@ -1950,10 +1976,10 @@ struct lnet_peer_net *
 	lnet_peer_ni_decref_locked(lpni);
 	lp = lpni->lpni_peer_net->lpn_peer;
 
-	if (prim_nid != lp->lp_primary_nid) {
+	if (prim_nid != lnet_nid_to_nid4(&lp->lp_primary_nid)) {
 		CDEBUG(D_NET, "prim_nid %s is not primary for peer %s\n",
 		       libcfs_nid2str(prim_nid),
-		       libcfs_nid2str(lp->lp_primary_nid));
+		       libcfs_nidstr(&lp->lp_primary_nid));
 		return -ENODEV;
 	}
 
@@ -1966,7 +1992,7 @@ struct lnet_peer_net *
 	}
 	lnet_net_unlock(LNET_LOCK_EX);
 
-	if (nid == LNET_NID_ANY || nid == lp->lp_primary_nid)
+	if (nid == LNET_NID_ANY || nid == lnet_nid_to_nid4(&lp->lp_primary_nid))
 		return lnet_peer_del(lp);
 
 	flags = LNET_PEER_CONFIGURED;
@@ -2222,7 +2248,7 @@ static int lnet_peer_queue_for_discovery(struct lnet_peer *lp)
 	}
 
 	CDEBUG(D_NET, "Queue peer %s: %d\n",
-	       libcfs_nid2str(lp->lp_primary_nid), rc);
+	       libcfs_nidstr(&lp->lp_primary_nid), rc);
 
 	return rc;
 }
@@ -2238,7 +2264,7 @@ static void lnet_peer_discovery_complete(struct lnet_peer *lp)
 	LIST_HEAD(pending_msgs);
 
 	CDEBUG(D_NET, "Discovery complete. Dequeue peer %s\n",
-	       libcfs_nid2str(lp->lp_primary_nid));
+	       libcfs_nidstr(&lp->lp_primary_nid));
 
 	list_del_init(&lp->lp_dc_list);
 	spin_lock(&lp->lp_lock);
@@ -2310,7 +2336,7 @@ void lnet_peer_push_event(struct lnet_event *ev)
 		lp->lp_state |= LNET_PEER_FORCE_PING;
 		CDEBUG(D_NET, "Push Put error %d from %s (source %s)\n",
 		       ev->status,
-		       libcfs_nid2str(lp->lp_primary_nid),
+		       libcfs_nidstr(&lp->lp_primary_nid),
 		       libcfs_nid2str(ev->source.nid));
 		goto out;
 	}
@@ -2323,7 +2349,7 @@ void lnet_peer_push_event(struct lnet_event *ev)
 		lp->lp_state &= ~LNET_PEER_NIDS_UPTODATE;
 		lp->lp_state |= LNET_PEER_FORCE_PING;
 		CDEBUG(D_NET, "Corrupted Push from %s\n",
-		       libcfs_nid2str(lp->lp_primary_nid));
+		       libcfs_nidstr(&lp->lp_primary_nid));
 		goto out;
 	}
 
@@ -2340,43 +2366,32 @@ void lnet_peer_push_event(struct lnet_event *ev)
 	 */
 	if (!(pbuf->pb_info.pi_features & LNET_PING_FEAT_MULTI_RAIL)) {
 		CERROR("Push from non-Multi-Rail peer %s dropped\n",
-		       libcfs_nid2str(lp->lp_primary_nid));
+		       libcfs_nidstr(&lp->lp_primary_nid));
 		goto out;
 	}
 
 	/* The peer may have discovery disabled at its end. Set
 	 * NO_DISCOVERY as appropriate.
 	 */
-	if (!(pbuf->pb_info.pi_features & LNET_PING_FEAT_DISCOVERY) ||
-	    lnet_peer_discovery_disabled) {
+	if (!(pbuf->pb_info.pi_features & LNET_PING_FEAT_DISCOVERY)) {
 		CDEBUG(D_NET, "Peer %s has discovery disabled\n",
-		       libcfs_nid2str(lp->lp_primary_nid));
+		       libcfs_nidstr(&lp->lp_primary_nid));
 
-		/* Detect whether this peer has toggled discovery from on to
-		 * off and whether we can delete and re-create the peer. Peers
-		 * that were manually configured cannot be deleted by discovery.
-		 * We need to delete this peer and re-create it if the peer was
-		 * not configured manually, is currently considered DD capable,
-		 * and either:
-		 * 1. We've already discovered the peer (the peer has toggled
-		 *    the discovery feature from on to off), or
-		 * 2. The peer is considered MR, but it was not user configured
-		 *    (this was a "temporary" peer created via the kernel APIs
-		 *     that we're discovering for the first time)
+		/* Mark the peer for deletion if we already know about it
+		 * and it's going from discovery set to no discovery set
 		 */
-		if (!(lp->lp_state & (LNET_PEER_CONFIGURED |
-				      LNET_PEER_NO_DISCOVERY)) &&
-		    (lp->lp_state & (LNET_PEER_DISCOVERED |
-				     LNET_PEER_MULTI_RAIL))) {
+		if (!(lp->lp_state & (LNET_PEER_NO_DISCOVERY |
+				      LNET_PEER_DISCOVERING)) &&
+		     lp->lp_state & LNET_PEER_DISCOVERED) {
 			CDEBUG(D_NET, "Marking %s:0x%x for deletion\n",
-			       libcfs_nid2str(lp->lp_primary_nid),
+			       libcfs_nidstr(&lp->lp_primary_nid),
 			       lp->lp_state);
 			lp->lp_state |= LNET_PEER_MARK_DELETION;
 		}
 		lp->lp_state |= LNET_PEER_NO_DISCOVERY;
-	} else {
+	} else if (lp->lp_state & LNET_PEER_NO_DISCOVERY) {
 		CDEBUG(D_NET, "Peer %s has discovery enabled\n",
-		       libcfs_nid2str(lp->lp_primary_nid));
+		       libcfs_nidstr(&lp->lp_primary_nid));
 		lp->lp_state &= ~LNET_PEER_NO_DISCOVERY;
 	}
 
@@ -2387,19 +2402,19 @@ void lnet_peer_push_event(struct lnet_event *ev)
 	 */
 	if (lp->lp_state & LNET_PEER_MULTI_RAIL) {
 		CDEBUG(D_NET, "peer %s(%p) is MR\n",
-		       libcfs_nid2str(lp->lp_primary_nid), lp);
+		       libcfs_nidstr(&lp->lp_primary_nid), lp);
 	} else if (lp->lp_state & LNET_PEER_CONFIGURED) {
 		CWARN("Push says %s is Multi-Rail, DLC says not\n",
-		      libcfs_nid2str(lp->lp_primary_nid));
+		      libcfs_nidstr(&lp->lp_primary_nid));
 	} else if (lnet_peer_discovery_disabled) {
 		CDEBUG(D_NET, "peer %s(%p) not MR: DD disabled locally\n",
-		       libcfs_nid2str(lp->lp_primary_nid), lp);
+		       libcfs_nidstr(&lp->lp_primary_nid), lp);
 	} else if (lp->lp_state & LNET_PEER_NO_DISCOVERY) {
 		CDEBUG(D_NET, "peer %s(%p) not MR: DD disabled remotely\n",
-		       libcfs_nid2str(lp->lp_primary_nid), lp);
+		       libcfs_nidstr(&lp->lp_primary_nid), lp);
 	} else {
 		CDEBUG(D_NET, "peer %s(%p) is MR capable\n",
-		       libcfs_nid2str(lp->lp_primary_nid), lp);
+		       libcfs_nidstr(&lp->lp_primary_nid), lp);
 		lp->lp_state |= LNET_PEER_MULTI_RAIL;
 		lnet_peer_clr_non_mr_pref_nids(lp);
 	}
@@ -2414,7 +2429,7 @@ void lnet_peer_push_event(struct lnet_event *ev)
 		lp->lp_state &= ~LNET_PEER_NIDS_UPTODATE;
 		lp->lp_state |= LNET_PEER_FORCE_PING;
 		CDEBUG(D_NET, "Truncated Push from %s (%d nids)\n",
-		       libcfs_nid2str(lp->lp_primary_nid),
+		       libcfs_nidstr(&lp->lp_primary_nid),
 		       pbuf->pb_info.pi_nnis);
 		goto out;
 	}
@@ -2436,7 +2451,7 @@ void lnet_peer_push_event(struct lnet_event *ev)
 			memcpy(&lp->lp_data->pb_info, &pbuf->pb_info,
 			       LNET_PING_INFO_SIZE(pbuf->pb_info.pi_nnis));
 			CDEBUG(D_NET, "Ping/Push race from %s: %u vs %u\n",
-			       libcfs_nid2str(lp->lp_primary_nid),
+			       libcfs_nidstr(&lp->lp_primary_nid),
 			       LNET_PING_BUFFER_SEQNO(pbuf),
 			       LNET_PING_BUFFER_SEQNO(lp->lp_data));
 		}
@@ -2452,7 +2467,7 @@ void lnet_peer_push_event(struct lnet_event *ev)
 	if (!lp->lp_data) {
 		lp->lp_state |= LNET_PEER_FORCE_PING;
 		CDEBUG(D_NET, "Cannot allocate Push buffer for %s %u\n",
-		       libcfs_nid2str(lp->lp_primary_nid),
+		       libcfs_nidstr(&lp->lp_primary_nid),
 		       LNET_PING_BUFFER_SEQNO(pbuf));
 		goto out;
 	}
@@ -2462,7 +2477,7 @@ void lnet_peer_push_event(struct lnet_event *ev)
 	       LNET_PING_INFO_SIZE(pbuf->pb_info.pi_nnis));
 	lp->lp_state |= LNET_PEER_DATA_PRESENT;
 	CDEBUG(D_NET, "Received Push %s %u\n",
-	       libcfs_nid2str(lp->lp_primary_nid),
+	       libcfs_nidstr(&lp->lp_primary_nid),
 	       LNET_PING_BUFFER_SEQNO(pbuf));
 
 out:
@@ -2584,7 +2599,7 @@ static void lnet_peer_clear_discovery_error(struct lnet_peer *lp)
 		goto again;
 
 	CDEBUG(D_NET, "peer %s NID %s: %d. %s\n",
-	       (lp ? libcfs_nid2str(lp->lp_primary_nid) : "(none)"),
+	       (lp ? libcfs_nidstr(&lp->lp_primary_nid) : "(none)"),
 	       libcfs_nidstr(&lpni->lpni_nid), rc,
 	       (!block) ? "pending discovery" : "discovery complete");
 
@@ -2608,7 +2623,7 @@ static void lnet_peer_clear_discovery_error(struct lnet_peer *lp)
 	spin_unlock(&lp->lp_lock);
 
 	CDEBUG(D_NET, "peer %s ev->status %d\n",
-	       libcfs_nid2str(lp->lp_primary_nid), ev->status);
+	       libcfs_nidstr(&lp->lp_primary_nid), ev->status);
 }
 
 /* Handle a Reply message. This is the reply to a Ping message. */
@@ -2632,7 +2647,7 @@ static void lnet_peer_clear_discovery_error(struct lnet_peer *lp)
 		lp->lp_ping_error = ev->status;
 		CDEBUG(D_NET, "Ping Reply error %d from %s (source %s)\n",
 		       ev->status,
-		       libcfs_nid2str(lp->lp_primary_nid),
+		       libcfs_nidstr(&lp->lp_primary_nid),
 		       libcfs_nid2str(ev->source.nid));
 		goto out;
 	}
@@ -2650,7 +2665,7 @@ static void lnet_peer_clear_discovery_error(struct lnet_peer *lp)
 		lp->lp_state |= LNET_PEER_PING_FAILED;
 		lp->lp_ping_error = 0;
 		CDEBUG(D_NET, "Corrupted Ping Reply from %s: %d\n",
-		       libcfs_nid2str(lp->lp_primary_nid), rc);
+		       libcfs_nidstr(&lp->lp_primary_nid), rc);
 		goto out;
 	}
 
@@ -2658,15 +2673,37 @@ static void lnet_peer_clear_discovery_error(struct lnet_peer *lp)
 	 * The peer may have discovery disabled at its end. Set
 	 * NO_DISCOVERY as appropriate.
 	 */
-	if ((pbuf->pb_info.pi_features & LNET_PING_FEAT_DISCOVERY) &&
-	    !lnet_peer_discovery_disabled) {
+	if (!(pbuf->pb_info.pi_features & LNET_PING_FEAT_DISCOVERY) &&
+	    lnet_peer_discovery_disabled) {
 		CDEBUG(D_NET, "Peer %s has discovery enabled\n",
-		       libcfs_nid2str(lp->lp_primary_nid));
-		lp->lp_state &= ~LNET_PEER_NO_DISCOVERY;
-	} else {
-		CDEBUG(D_NET, "Peer %s has discovery disabled\n",
-		       libcfs_nid2str(lp->lp_primary_nid));
+		       libcfs_nidstr(&lp->lp_primary_nid));
+
+		/* Detect whether this peer has toggled discovery from on to
+		 * off and whether we can delete and re-create the peer. Peers
+		 * that were manually configured cannot be deleted by discovery.
+		 * We need to delete this peer and re-create it if the peer was
+		 * not configured manually, is currently considered DD capable,
+		 * and either:
+		 * 1. We've already discovered the peer (the peer has toggled
+		 *    the discovery feature from on to off), or
+		 * 2. The peer is considered MR, but it was not user configured
+		 *    (this was a "temporary" peer created via the kernel APIs
+		 *     that we're discovering for the first time)
+		 */
+		if (!(lp->lp_state & (LNET_PEER_CONFIGURED |
+				      LNET_PEER_NO_DISCOVERY)) &&
+		    (lp->lp_state & (LNET_PEER_DISCOVERED |
+				     LNET_PEER_MULTI_RAIL))) {
+			CDEBUG(D_NET, "Marking %s:0x%x for deletion\n",
+			       libcfs_nidstr(&lp->lp_primary_nid),
+			       lp->lp_state);
+			lp->lp_state |= LNET_PEER_MARK_DELETION;
+		}
 		lp->lp_state |= LNET_PEER_NO_DISCOVERY;
+	} else {
+		CDEBUG(D_NET, "Peer %s has discovery enabled\n",
+		       libcfs_nidstr(&lp->lp_primary_nid));
+		lp->lp_state &= ~LNET_PEER_NO_DISCOVERY;
 	}
 
 	/*
@@ -2677,31 +2714,31 @@ static void lnet_peer_clear_discovery_error(struct lnet_peer *lp)
 	if (pbuf->pb_info.pi_features & LNET_PING_FEAT_MULTI_RAIL) {
 		if (lp->lp_state & LNET_PEER_MULTI_RAIL) {
 			CDEBUG(D_NET, "peer %s(%p) is MR\n",
-			       libcfs_nid2str(lp->lp_primary_nid), lp);
+			       libcfs_nidstr(&lp->lp_primary_nid), lp);
 		} else if (lp->lp_state & LNET_PEER_CONFIGURED) {
 			CWARN("Reply says %s is Multi-Rail, DLC says not\n",
-			      libcfs_nid2str(lp->lp_primary_nid));
+			      libcfs_nidstr(&lp->lp_primary_nid));
 		} else if (lnet_peer_discovery_disabled) {
 			CDEBUG(D_NET,
 			       "peer %s(%p) not MR: DD disabled locally\n",
-			       libcfs_nid2str(lp->lp_primary_nid), lp);
+			       libcfs_nidstr(&lp->lp_primary_nid), lp);
 		} else if (lp->lp_state & LNET_PEER_NO_DISCOVERY) {
 			CDEBUG(D_NET,
 			       "peer %s(%p) not MR: DD disabled remotely\n",
-			       libcfs_nid2str(lp->lp_primary_nid), lp);
+			       libcfs_nidstr(&lp->lp_primary_nid), lp);
 		} else {
 			CDEBUG(D_NET, "peer %s(%p) is MR capable\n",
-			       libcfs_nid2str(lp->lp_primary_nid), lp);
+			       libcfs_nidstr(&lp->lp_primary_nid), lp);
 			lp->lp_state |= LNET_PEER_MULTI_RAIL;
 			lnet_peer_clr_non_mr_pref_nids(lp);
 		}
 	} else if (lp->lp_state & LNET_PEER_MULTI_RAIL) {
 		if (lp->lp_state & LNET_PEER_CONFIGURED) {
 			CWARN("DLC says %s is Multi-Rail, Reply says not\n",
-			      libcfs_nid2str(lp->lp_primary_nid));
+			      libcfs_nidstr(&lp->lp_primary_nid));
 		} else {
 			CERROR("Multi-Rail state vanished from %s\n",
-			       libcfs_nid2str(lp->lp_primary_nid));
+			       libcfs_nidstr(&lp->lp_primary_nid));
 			lp->lp_state &= ~LNET_PEER_MULTI_RAIL;
 		}
 	}
@@ -2723,7 +2760,7 @@ static void lnet_peer_clear_discovery_error(struct lnet_peer *lp)
 		lp->lp_state |= LNET_PEER_PING_FAILED;
 		lp->lp_ping_error = 0;
 		CDEBUG(D_NET, "Truncated Reply from %s (%d nids)\n",
-		       libcfs_nid2str(lp->lp_primary_nid),
+		       libcfs_nidstr(&lp->lp_primary_nid),
 		       pbuf->pb_info.pi_nnis);
 		goto out;
 	}
@@ -2734,11 +2771,12 @@ static void lnet_peer_clear_discovery_error(struct lnet_peer *lp)
 	 */
 	if (pbuf->pb_info.pi_features & LNET_PING_FEAT_MULTI_RAIL &&
 	    pbuf->pb_info.pi_nnis > 1 &&
-	    lp->lp_primary_nid == pbuf->pb_info.pi_ni[1].ns_nid) {
+	    lnet_nid_to_nid4(&lp->lp_primary_nid) ==
+	    pbuf->pb_info.pi_ni[1].ns_nid) {
 		if (LNET_PING_BUFFER_SEQNO(pbuf) < lp->lp_peer_seqno)
 			CDEBUG(D_NET,
 			       "peer %s: seq# got %u have %u. peer rebooted?\n",
-			       libcfs_nid2str(lp->lp_primary_nid),
+			       libcfs_nidstr(&lp->lp_primary_nid),
 			       LNET_PING_BUFFER_SEQNO(pbuf),
 			       lp->lp_peer_seqno);
 
@@ -2747,7 +2785,7 @@ static void lnet_peer_clear_discovery_error(struct lnet_peer *lp)
 
 	/* We're happy with the state of the data in the buffer. */
 	CDEBUG(D_NET, "peer %s data present %u. state = 0x%x\n",
-	       libcfs_nid2str(lp->lp_primary_nid), lp->lp_peer_seqno,
+	       libcfs_nidstr(&lp->lp_primary_nid), lp->lp_peer_seqno,
 	       lp->lp_state);
 	if (lp->lp_state & LNET_PEER_DATA_PRESENT)
 		lnet_ping_buffer_decref(lp->lp_data);
@@ -2817,7 +2855,7 @@ static void lnet_peer_clear_discovery_error(struct lnet_peer *lp)
 		lp->lp_state |= LNET_PEER_PING_FAILED;
 		lp->lp_ping_error = -ETIMEDOUT;
 		CDEBUG(D_NET, "Ping Unlink for message to peer %s\n",
-		       libcfs_nid2str(lp->lp_primary_nid));
+		       libcfs_nidstr(&lp->lp_primary_nid));
 	}
 	/* We've passed through LNetPut() */
 	if (lp->lp_state & LNET_PEER_PUSH_SENT) {
@@ -2825,7 +2863,7 @@ static void lnet_peer_clear_discovery_error(struct lnet_peer *lp)
 		lp->lp_state |= LNET_PEER_PUSH_FAILED;
 		lp->lp_push_error = -ETIMEDOUT;
 		CDEBUG(D_NET, "Push Unlink for message to peer %s\n",
-		       libcfs_nid2str(lp->lp_primary_nid));
+		       libcfs_nidstr(&lp->lp_primary_nid));
 	}
 	spin_unlock(&lp->lp_lock);
 }
@@ -3003,7 +3041,7 @@ static int lnet_peer_merge_data(struct lnet_peer *lp,
 		if (rc) {
 			CERROR("Error adding NID %s to peer %s: %d\n",
 			       libcfs_nid2str(addnis[i].ns_nid),
-			       libcfs_nid2str(lp->lp_primary_nid), rc);
+			       libcfs_nidstr(&lp->lp_primary_nid), rc);
 			if (rc == -ENOMEM)
 				goto out;
 		}
@@ -3026,7 +3064,7 @@ static int lnet_peer_merge_data(struct lnet_peer *lp,
 		if (rc) {
 			CERROR("Error deleting NID %s from peer %s: %d\n",
 			       libcfs_nid2str(delnis[i]),
-			       libcfs_nid2str(lp->lp_primary_nid), rc);
+			       libcfs_nidstr(&lp->lp_primary_nid), rc);
 			if (rc == -ENOMEM)
 				goto out;
 		}
@@ -3064,8 +3102,8 @@ static int lnet_peer_merge_data(struct lnet_peer *lp,
 	kfree(addnis);
 	kfree(delnis);
 	lnet_ping_buffer_decref(pbuf);
-	CDEBUG(D_NET, "peer %s (%p): %d\n", libcfs_nid2str(lp->lp_primary_nid),
-	       lp, rc);
+	CDEBUG(D_NET, "peer %s (%p): %d\n",
+	       libcfs_nidstr(&lp->lp_primary_nid), lp, rc);
 
 	if (rc) {
 		spin_lock(&lp->lp_lock);
@@ -3134,7 +3172,7 @@ static int lnet_peer_merge_data(struct lnet_peer *lp,
 	if (pbuf)
 		return lnet_peer_merge_data(lp, pbuf);
 
-	CDEBUG(D_NET, "peer %s\n", libcfs_nid2str(lp->lp_primary_nid));
+	CDEBUG(D_NET, "peer %s\n", libcfs_nidstr(&lp->lp_primary_nid));
 	return 0;
 }
 
@@ -3170,7 +3208,7 @@ static int lnet_peer_deletion(struct lnet_peer *lp)
 	lp->lp_state &= ~(LNET_PEER_DISCOVERING | LNET_PEER_FORCE_PING |
 			  LNET_PEER_FORCE_PUSH);
 	CDEBUG(D_NET, "peer %s(%p) state %#x\n",
-	       libcfs_nid2str(lp->lp_primary_nid), lp, lp->lp_state);
+	       libcfs_nidstr(&lp->lp_primary_nid), lp, lp->lp_state);
 
 	/* no-op if lnet_peer_del() has already been called on this peer */
 	if (lp->lp_state & LNET_PEER_MARK_DELETED)
@@ -3280,7 +3318,7 @@ static int lnet_peer_data_present(struct lnet_peer *lp)
 	if (pbuf->pb_info.pi_nnis <= 1)
 		goto out;
 	nid = pbuf->pb_info.pi_ni[1].ns_nid;
-	if (lp->lp_primary_nid == LNET_NID_LO_0) {
+	if (nid_is_lo0(&lp->lp_primary_nid)) {
 		rc = lnet_peer_set_primary_nid(lp, nid, flags);
 		if (!rc)
 			rc = lnet_peer_merge_data(lp, pbuf);
@@ -3291,8 +3329,8 @@ static int lnet_peer_data_present(struct lnet_peer *lp)
 	 * to update the status of the nids that we currently have
 	 * recorded in that peer.
 	 */
-	} else if (lp->lp_primary_nid == nid ||
-		   (lnet_is_nid_in_ping_info(lp->lp_primary_nid,
+	} else if (lnet_nid_to_nid4(&lp->lp_primary_nid) == nid ||
+		   (lnet_is_nid_in_ping_info(lnet_nid_to_nid4(&lp->lp_primary_nid),
 					     &pbuf->pb_info) &&
 		    lnet_is_discovery_disabled(lp))) {
 		rc = lnet_peer_merge_data(lp, pbuf);
@@ -3302,7 +3340,7 @@ static int lnet_peer_data_present(struct lnet_peer *lp)
 			rc = lnet_peer_set_primary_nid(lp, nid, flags);
 			if (rc) {
 				CERROR("Primary NID error %s versus %s: %d\n",
-				       libcfs_nid2str(lp->lp_primary_nid),
+				       libcfs_nidstr(&lp->lp_primary_nid),
 				       libcfs_nid2str(nid), rc);
 			} else {
 				rc = lnet_peer_merge_data(lp, pbuf);
@@ -3343,7 +3381,7 @@ static int lnet_peer_data_present(struct lnet_peer *lp)
 	}
 out:
 	CDEBUG(D_NET, "peer %s(%p): %d. state = 0x%x\n",
-	       libcfs_nid2str(lp->lp_primary_nid), lp, rc,
+	       libcfs_nidstr(&lp->lp_primary_nid), lp, rc,
 	       lp->lp_state);
 	mutex_unlock(&the_lnet.ln_api_mutex);
 
@@ -3377,7 +3415,7 @@ static int lnet_peer_ping_failed(struct lnet_peer *lp)
 		LNetMDUnlink(mdh);
 
 	CDEBUG(D_NET, "peer %s:%d\n",
-	       libcfs_nid2str(lp->lp_primary_nid), rc);
+	       libcfs_nidstr(&lp->lp_primary_nid), rc);
 
 	spin_lock(&lp->lp_lock);
 	return rc ? rc : LNET_REDISCOVER_PEER;
@@ -3402,7 +3440,8 @@ static int lnet_peer_send_ping(struct lnet_peer *lp)
 
 	nnis = max_t(int, lp->lp_data_nnis, LNET_INTERFACES_MIN);
 
-	rc = lnet_send_ping(lp->lp_primary_nid, &lp->lp_ping_mdh, nnis, lp,
+	rc = lnet_send_ping(lnet_nid_to_nid4(&lp->lp_primary_nid),
+			    &lp->lp_ping_mdh, nnis, lp,
 			    the_lnet.ln_dc_handler, false);
 	/* if LNetMDBind in lnet_send_ping fails we need to decrement the
 	 * refcount on the peer, otherwise LNetMDUnlink will be called
@@ -3418,13 +3457,13 @@ static int lnet_peer_send_ping(struct lnet_peer *lp)
 		goto fail_error;
 	}
 
-	CDEBUG(D_NET, "peer %s\n", libcfs_nid2str(lp->lp_primary_nid));
+	CDEBUG(D_NET, "peer %s\n", libcfs_nidstr(&lp->lp_primary_nid));
 
 	spin_lock(&lp->lp_lock);
 	return 0;
 
 fail_error:
-	CDEBUG(D_NET, "peer %s: %d\n", libcfs_nid2str(lp->lp_primary_nid), rc);
+	CDEBUG(D_NET, "peer %s: %d\n", libcfs_nidstr(&lp->lp_primary_nid), rc);
 	/*
 	 * The errors that get us here are considered hard errors and
 	 * cause Discovery to terminate. So we clear PING_SENT, but do
@@ -3457,7 +3496,7 @@ static int lnet_peer_push_failed(struct lnet_peer *lp)
 	if (!LNetMDHandleIsInvalid(mdh))
 		LNetMDUnlink(mdh);
 
-	CDEBUG(D_NET, "peer %s\n", libcfs_nid2str(lp->lp_primary_nid));
+	CDEBUG(D_NET, "peer %s\n", libcfs_nidstr(&lp->lp_primary_nid));
 	spin_lock(&lp->lp_lock);
 	return rc ? rc : LNET_REDISCOVER_PEER;
 }
@@ -3472,7 +3511,7 @@ static int lnet_peer_discovered(struct lnet_peer *lp)
 
 	lp->lp_dc_error = 0;
 
-	CDEBUG(D_NET, "peer %s\n", libcfs_nid2str(lp->lp_primary_nid));
+	CDEBUG(D_NET, "peer %s\n", libcfs_nidstr(&lp->lp_primary_nid));
 
 	return 0;
 }
@@ -3531,7 +3570,7 @@ static int lnet_peer_send_push(struct lnet_peer *lp)
 	if (lp->lp_disc_dst_nid != LNET_NID_ANY)
 		id.nid = lp->lp_disc_dst_nid;
 	else
-		id.nid = lp->lp_primary_nid;
+		id.nid = lnet_nid_to_nid4(&lp->lp_primary_nid);
 	lnet_net_unlock(cpt);
 
 	rc = LNetPut(lp->lp_disc_src_nid, lp->lp_push_mdh,
@@ -3547,7 +3586,7 @@ static int lnet_peer_send_push(struct lnet_peer *lp)
 	if (rc)
 		goto fail_unlink;
 
-	CDEBUG(D_NET, "peer %s\n", libcfs_nid2str(lp->lp_primary_nid));
+	CDEBUG(D_NET, "peer %s\n", libcfs_nidstr(&lp->lp_primary_nid));
 
 	spin_lock(&lp->lp_lock);
 	return 0;
@@ -3556,8 +3595,8 @@ static int lnet_peer_send_push(struct lnet_peer *lp)
 	LNetMDUnlink(lp->lp_push_mdh);
 	LNetInvalidateMDHandle(&lp->lp_push_mdh);
 fail_error:
-	CDEBUG(D_NET, "peer %s(%p): %d\n",
-	       libcfs_nid2str(lp->lp_primary_nid), lp, rc);
+	CDEBUG(D_NET, "peer %s(%p): %d\n", libcfs_nidstr(&lp->lp_primary_nid),
+	       lp, rc);
 	/*
 	 * The errors that get us here are considered hard errors and
 	 * cause Discovery to terminate. So we clear PUSH_SENT, but do
@@ -3577,7 +3616,7 @@ static int lnet_peer_send_push(struct lnet_peer *lp)
 static void lnet_peer_discovery_error(struct lnet_peer *lp, int error)
 {
 	CDEBUG(D_NET, "Discovery error %s: %d\n",
-	       libcfs_nid2str(lp->lp_primary_nid), error);
+	       libcfs_nidstr(&lp->lp_primary_nid), error);
 
 	spin_lock(&lp->lp_lock);
 	lp->lp_dc_error = error;
@@ -3738,7 +3777,7 @@ static int lnet_peer_discovery(void *arg)
 			 */
 			spin_lock(&lp->lp_lock);
 			CDEBUG(D_NET, "peer %s(%p) state %#x\n",
-			       libcfs_nid2str(lp->lp_primary_nid), lp,
+			       libcfs_nidstr(&lp->lp_primary_nid), lp,
 			       lp->lp_state);
 			if (lp->lp_state & (LNET_PEER_MARK_DELETION |
 					    LNET_PEER_MARK_DELETED))
@@ -3760,7 +3799,7 @@ static int lnet_peer_discovery(void *arg)
 			else
 				rc = lnet_peer_discovered(lp);
 			CDEBUG(D_NET, "peer %s(%p) state %#x rc %d\n",
-			       libcfs_nid2str(lp->lp_primary_nid), lp,
+			       libcfs_nidstr(&lp->lp_primary_nid), lp,
 			       lp->lp_state, rc);
 			spin_unlock(&lp->lp_lock);
 
@@ -4008,9 +4047,9 @@ int lnet_get_peer_info(struct lnet_ioctl_peer_cfg *cfg, void __user *bulk)
 		goto out_lp_decref;
 	}
 
-	cfg->prcfg_prim_nid = lp->lp_primary_nid;
+	cfg->prcfg_prim_nid = lnet_nid_to_nid4(&lp->lp_primary_nid);
 	cfg->prcfg_mr = lnet_peer_is_multi_rail(lp);
-	cfg->prcfg_cfg_nid = lp->lp_primary_nid;
+	cfg->prcfg_cfg_nid = lnet_nid_to_nid4(&lp->lp_primary_nid);
 	cfg->prcfg_count = lp->lp_nnis;
 	cfg->prcfg_size = size;
 	cfg->prcfg_state = lp->lp_state;
diff --git a/net/lnet/lnet/router.c b/net/lnet/lnet/router.c
index f6fcc93..2d5f0b6 100644
--- a/net/lnet/lnet/router.c
+++ b/net/lnet/lnet/router.c
@@ -175,7 +175,7 @@ static void lnet_del_route_from_rnet(lnet_nid_t gw_nid,
 	/* use the gateway's lp_primary_nid to delete the route as the
 	 * lr_nid can be a constituent NID of the peer
 	 */
-	lnet_del_route_from_rnet(route->lr_gateway->lp_primary_nid,
+	lnet_del_route_from_rnet(lnet_nid_to_nid4(&route->lr_gateway->lp_primary_nid),
 				 &rnet->lrn_routes, l);
 
 	if (lp) {
@@ -201,11 +201,11 @@ static void lnet_del_route_from_rnet(lnet_nid_t gw_nid,
 
 	lnet_net_lock(LNET_LOCK_EX);
 	CDEBUG(D_NET, "transferring routes from %s -> %s\n",
-	       libcfs_nid2str(src->lp_primary_nid),
-	       libcfs_nid2str(target->lp_primary_nid));
+	       libcfs_nidstr(&src->lp_primary_nid),
+	       libcfs_nidstr(&target->lp_primary_nid));
 	list_for_each_entry(route, &src->lp_routes, lr_gwlist) {
 		CDEBUG(D_NET, "%s: %s->%s\n",
-		       libcfs_nid2str(src->lp_primary_nid),
+		       libcfs_nidstr(&src->lp_primary_nid),
 		       libcfs_net2str(route->lr_net),
 		       libcfs_nid2str(route->lr_nid));
 	}
@@ -331,7 +331,7 @@ bool lnet_is_route_alive(struct lnet_route *route)
 		spin_unlock(&gw->lp_lock);
 		if (gw->lp_rtr_refcount > 0)
 			CERROR("peer %s is being used as a gateway but routing feature is not turned on\n",
-			       libcfs_nid2str(gw->lp_primary_nid));
+			       libcfs_nidstr(&gw->lp_primary_nid));
 		return false;
 	}
 	spin_unlock(&gw->lp_lock);
@@ -372,7 +372,7 @@ bool lnet_is_route_alive(struct lnet_route *route)
 	    (route->lr_hops == 1 || route->lr_hops == LNET_UNDEFINED_HOPS)) {
 		CWARN("route %s->%s is detected to be multi-hop but hop count is set to %d\n",
 		      libcfs_net2str(route->lr_net),
-		      libcfs_nid2str(route->lr_gateway->lp_primary_nid),
+		      libcfs_nidstr(&route->lr_gateway->lp_primary_nid),
 		      (int)route->lr_hops);
 	}
 }
@@ -420,7 +420,7 @@ bool lnet_is_route_alive(struct lnet_route *route)
 	if (lp_state & LNET_PEER_PING_FAILED ||
 	    pbuf->pb_info.pi_features & LNET_PING_FEAT_RTE_DISABLED) {
 		CDEBUG(D_NET, "Set routes down for gw %s because %s %d\n",
-		       libcfs_nid2str(lp->lp_primary_nid),
+		       libcfs_nidstr(&lp->lp_primary_nid),
 		       lp_state & LNET_PEER_PING_FAILED ? "ping failed" :
 		       "route feature is disabled", lp->lp_ping_error);
 		/* If the ping failed or the peer has routing disabled then
@@ -432,7 +432,7 @@ bool lnet_is_route_alive(struct lnet_route *route)
 	}
 
 	CDEBUG(D_NET, "Discovery is disabled. Processing reply for gw: %s:%d\n",
-	       libcfs_nid2str(lp->lp_primary_nid), pbuf->pb_info.pi_nnis);
+	       libcfs_nidstr(&lp->lp_primary_nid), pbuf->pb_info.pi_nnis);
 
 	/* examine the ping response to determine if the routes on that
 	 * gateway should be declared alive.
@@ -521,7 +521,7 @@ bool lnet_is_route_alive(struct lnet_route *route)
 	 * determine otherwise.
 	 */
 	CDEBUG(D_NET, "%s: Router discovery failed %d\n",
-	       libcfs_nid2str(lp->lp_primary_nid), lp->lp_dc_error);
+	       libcfs_nidstr(&lp->lp_primary_nid), lp->lp_dc_error);
 	while ((lpni = lnet_get_next_peer_ni_locked(lp, NULL, lpni)) != NULL)
 		lpni->lpni_ns_status = LNET_NI_STATUS_DOWN;
 
@@ -741,7 +741,8 @@ static void lnet_shuffle_seed(void)
 		}
 
 		/* our lookups must be true */
-		LASSERT(route2->lr_gateway->lp_primary_nid != gateway);
+		LASSERT(lnet_nid_to_nid4(&route2->lr_gateway->lp_primary_nid) !=
+			gateway);
 	}
 
 	/* It is possible to add multiple routes through the same peer,
@@ -790,7 +791,7 @@ static void lnet_shuffle_seed(void)
 	list_for_each_entry_safe(route, tmp, route_list, lr_list) {
 		gateway = route->lr_gateway;
 		if (gw_nid != LNET_NID_ANY &&
-		    gw_nid != gateway->lp_primary_nid)
+		    gw_nid != lnet_nid_to_nid4(&gateway->lp_primary_nid))
 			continue;
 
 		/* move to zombie to delete outside the lock
@@ -834,7 +835,7 @@ static void lnet_shuffle_seed(void)
 	if (lpni) {
 		lp = lpni->lpni_peer_net->lpn_peer;
 		LASSERT(lp);
-		gw_nid = lp->lp_primary_nid;
+		gw_nid = lnet_nid_to_nid4(&lp->lp_primary_nid);
 		lnet_peer_ni_decref_locked(lpni);
 	}
 
@@ -1142,7 +1143,7 @@ bool lnet_router_checker_active(void)
 			lpn = lnet_get_next_peer_net_locked(rtr, net_id);
 			if (!lpn) {
 				CERROR("gateway %s has no networks\n",
-				       libcfs_nid2str(rtr->lp_primary_nid));
+				       libcfs_nidstr(&rtr->lp_primary_nid));
 				break;
 			}
 
@@ -1159,7 +1160,7 @@ bool lnet_router_checker_active(void)
 			found_lpn = true;
 
 			CDEBUG(D_NET, "rtr %s(%p) %s(%p) next ping %lld\n",
-			       libcfs_nid2str(rtr->lp_primary_nid), rtr,
+			       libcfs_nidstr(&rtr->lp_primary_nid), rtr,
 			       libcfs_net2str(net_id), lpn,
 			       lpn->lpn_next_ping);
 
@@ -1169,7 +1170,7 @@ bool lnet_router_checker_active(void)
 
 		if (!found_lpn || !lpn) {
 			CERROR("no local network found for gateway %s\n",
-			       libcfs_nid2str(rtr->lp_primary_nid));
+			       libcfs_nidstr(&rtr->lp_primary_nid));
 			continue;
 		}
 
@@ -1184,11 +1185,12 @@ bool lnet_router_checker_active(void)
 		spin_unlock(&rtr->lp_lock);
 
 		/* find the peer_ni associated with the primary NID */
-		lpni = lnet_peer_get_ni_locked(rtr, rtr->lp_primary_nid);
+		lpni = lnet_peer_get_ni_locked(rtr,
+					       lnet_nid_to_nid4(&rtr->lp_primary_nid));
 		if (!lpni) {
 			CDEBUG(D_NET,
 			       "Expected to find an lpni for %s, but non found\n",
-			       libcfs_nid2str(rtr->lp_primary_nid));
+			       libcfs_nidstr(&rtr->lp_primary_nid));
 			continue;
 		}
 		lnet_peer_ni_addref_locked(lpni);
@@ -1208,7 +1210,7 @@ bool lnet_router_checker_active(void)
 			lpn->lpn_next_ping = now + alive_router_check_interval;
 		else
 			CERROR("Failed to discover router %s\n",
-			       libcfs_nid2str(rtr->lp_primary_nid));
+			       libcfs_nidstr(&rtr->lp_primary_nid));
 
 		/* NB cpt lock was dropped in lnet_discover_peer_locked() */
 		if (version != the_lnet.ln_routers_version) {
diff --git a/net/lnet/lnet/router_proc.c b/net/lnet/lnet/router_proc.c
index 1a04ac4..2e3c802 100644
--- a/net/lnet/lnet/router_proc.c
+++ b/net/lnet/lnet/router_proc.c
@@ -310,7 +310,7 @@ static int proc_lnet_routers(struct ctl_table *table, int write,
 		}
 
 		if (peer) {
-			lnet_nid_t nid = peer->lp_primary_nid;
+			struct lnet_nid *nid = &peer->lp_primary_nid;
 			int nrefs = atomic_read(&peer->lp_refcount);
 			int nrtrrefs = peer->lp_rtr_refcount;
 			int alive = lnet_is_gateway_alive(peer);
@@ -319,7 +319,7 @@ static int proc_lnet_routers(struct ctl_table *table, int write,
 				       "%-4d %7d %5s %s\n",
 				       nrefs, nrtrrefs,
 				       alive ? "up" : "down",
-				       libcfs_nid2str(nid));
+				       libcfs_nidstr(nid));
 		}
 
 		lnet_net_unlock(0);
diff --git a/net/lnet/lnet/udsp.c b/net/lnet/lnet/udsp.c
index 03669e6..977a6a6 100644
--- a/net/lnet/lnet/udsp.c
+++ b/net/lnet/lnet/udsp.c
@@ -248,7 +248,7 @@ enum udsp_apply {
 		list_for_each_entry(rnet, rn_list, lrn_list) {
 			list_for_each_entry(route, &rnet->lrn_routes, lr_list) {
 				/* look if gw nid on the same net matches */
-				gw_prim_nid = route->lr_gateway->lp_primary_nid;
+				gw_prim_nid = lnet_nid_to_nid4(&route->lr_gateway->lp_primary_nid);
 				lpni = NULL;
 				while ((lpni = lnet_get_next_peer_ni_locked(route->lr_gateway,
 									    NULL,
@@ -425,7 +425,7 @@ enum udsp_apply {
 		rn_list = &the_lnet.ln_remote_nets_hash[i];
 		list_for_each_entry(rnet, rn_list, lrn_list) {
 			list_for_each_entry(route, &rnet->lrn_routes, lr_list) {
-				gw_nid = route->lr_gateway->lp_primary_nid;
+				gw_nid = lnet_nid_to_nid4(&route->lr_gateway->lp_primary_nid);
 				rc = cfs_match_nid_net(gw_nid,
 						       rte_action->ud_net_id.udn_net_type,
 						       &rte_action->ud_net_id.udn_net_num_range,
@@ -608,7 +608,7 @@ enum udsp_apply {
 		ptable = the_lnet.ln_peer_tables[cpt];
 		list_for_each_entry(lp, &ptable->pt_peer_list, lp_peer_list) {
 			CDEBUG(D_NET, "udsp examining lp %s\n",
-			       libcfs_nid2str(lp->lp_primary_nid));
+			       libcfs_nidstr(&lp->lp_primary_nid));
 			list_for_each_entry(lpn,
 					    &lp->lp_peer_nets,
 					    lpn_peer_nets) {
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
