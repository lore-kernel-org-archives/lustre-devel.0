Return-Path: <SRS0=2ypu=OM=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9A5FCC433EF
	for <lustre-devel@archiver.kernel.org>; Wed, 22 Sep 2021 02:20:29 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 3EBC06112F
	for <lustre-devel@archiver.kernel.org>; Wed, 22 Sep 2021 02:20:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.1 mail.kernel.org 3EBC06112F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 8AD3121F2A3;
	Tue, 21 Sep 2021 19:20:25 -0700 (PDT)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 2370321F1FE
 for <lustre-devel@lists.lustre.org>; Tue, 21 Sep 2021 19:20:09 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 1C51A376;
 Tue, 21 Sep 2021 22:20:04 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 19ED3FF4BE; Tue, 21 Sep 2021 22:20:04 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Tue, 21 Sep 2021 22:19:48 -0400
Message-Id: <1632277201-6920-12-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1632277201-6920-1-git-send-email-jsimmons@infradead.org>
References: <1632277201-6920-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 11/24] lnet: change lr_nid to struct lnet_nid
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

The nid in 'struct lnet_route' is now a struct lnet_nid'.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10391
Lustre-commit: d1e2f6fc688762222 ("LU-10391 lnet: change lr_nid to struct lnet_nid")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/43593
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Chris Horn <chris.horn@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/lib-lnet.h  |   9 ++--
 include/linux/lnet/lib-types.h |   2 +-
 net/lnet/lnet/api-ni.c         |  19 +++++++-
 net/lnet/lnet/config.c         |  15 +++---
 net/lnet/lnet/lib-move.c       |   2 +-
 net/lnet/lnet/peer.c           | 105 ++++++++++++++++++++++++-----------------
 net/lnet/lnet/router.c         |  43 +++++++++--------
 net/lnet/lnet/router_proc.c    |   2 +-
 8 files changed, 117 insertions(+), 80 deletions(-)

diff --git a/include/linux/lnet/lib-lnet.h b/include/linux/lnet/lib-lnet.h
index 9e7d0b8..890f61a 100644
--- a/include/linux/lnet/lib-lnet.h
+++ b/include/linux/lnet/lib-lnet.h
@@ -517,7 +517,7 @@ int lnet_notify(struct lnet_ni *ni, lnet_nid_t peer, bool alive, bool reset,
 		time64_t when);
 void lnet_notify_locked(struct lnet_peer_ni *lp, int notifylnd, int alive,
 			time64_t when);
-int lnet_add_route(u32 net, u32 hops, lnet_nid_t gateway_nid,
+int lnet_add_route(u32 net, u32 hops, struct lnet_nid *gateway,
 		   u32 priority, u32 sensitivity);
 int lnet_del_route(u32 net, lnet_nid_t gw_nid);
 void lnet_move_route(struct lnet_route *route, struct lnet_peer *lp,
@@ -567,7 +567,8 @@ void lnet_rtr_transfer_to_peer(struct lnet_peer *src,
 void lnet_net_clr_pref_rtrs(struct lnet_net *net);
 int lnet_net_add_pref_rtr(struct lnet_net *net, lnet_nid_t gw_nid);
 
-int lnet_islocalnid(lnet_nid_t nid);
+int lnet_islocalnid4(lnet_nid_t nid);
+int lnet_islocalnid(struct lnet_nid *nid);
 int lnet_islocalnet(u32 net);
 int lnet_islocalnet_locked(u32 net);
 
@@ -837,9 +838,11 @@ struct lnet_peer_ni *lnet_get_next_peer_ni_locked(struct lnet_peer *peer,
 						  struct lnet_peer_ni *prev);
 struct lnet_peer_ni *lnet_nid2peerni_locked(lnet_nid_t nid, lnet_nid_t pref,
 					    int cpt);
-struct lnet_peer_ni *lnet_nid2peerni_ex(lnet_nid_t nid, int cpt);
+struct lnet_peer_ni *lnet_nid2peerni_ex(struct lnet_nid *nid, int cpt);
 struct lnet_peer_ni *lnet_peer_get_ni_locked(struct lnet_peer *lp,
 					     lnet_nid_t nid);
+struct lnet_peer_ni *lnet_peer_ni_get_locked(struct lnet_peer *lp,
+					     struct lnet_nid *nid);
 struct lnet_peer_ni *lnet_find_peer_ni_locked(lnet_nid_t nid);
 struct lnet_peer_ni *lnet_peer_ni_find_locked(struct lnet_nid *nid);
 struct lnet_peer *lnet_find_peer(lnet_nid_t nid);
diff --git a/include/linux/lnet/lib-types.h b/include/linux/lnet/lib-types.h
index ba900e8..1e1ddd7 100644
--- a/include/linux/lnet/lib-types.h
+++ b/include/linux/lnet/lib-types.h
@@ -905,7 +905,7 @@ struct lnet_route {
 	/* router node */
 	struct lnet_peer       *lr_gateway;
 	/* NID used to add route */
-	lnet_nid_t		lr_nid;
+	struct lnet_nid		lr_nid;
 	/* remote network number */
 	u32			lr_net;
 	/* local network number */
diff --git a/net/lnet/lnet/api-ni.c b/net/lnet/lnet/api-ni.c
index 31ccb2c..0f4feda 100644
--- a/net/lnet/lnet/api-ni.c
+++ b/net/lnet/lnet/api-ni.c
@@ -1635,7 +1635,7 @@ struct lnet_ni *
 EXPORT_SYMBOL(lnet_nid_to_ni_addref);
 
 int
-lnet_islocalnid(lnet_nid_t nid)
+lnet_islocalnid4(lnet_nid_t nid)
 {
 	struct lnet_ni *ni;
 	int cpt;
@@ -1648,6 +1648,19 @@ struct lnet_ni *
 }
 
 int
+lnet_islocalnid(struct lnet_nid *nid)
+{
+	struct lnet_ni	*ni;
+	int		cpt;
+
+	cpt = lnet_net_lock_current();
+	ni = lnet_nid_to_ni_locked(nid, cpt);
+	lnet_net_unlock(cpt);
+
+	return ni != NULL;
+}
+
+int
 lnet_count_acceptor_nets(void)
 {
 	/* Return the # of NIs that need the acceptor. */
@@ -3852,6 +3865,7 @@ u32 lnet_get_dlc_seq_locked(void)
 	struct lnet_ioctl_config_data *config;
 	struct lnet_process_id id = { 0 };
 	struct lnet_ni *ni;
+	struct lnet_nid nid;
 	int rc;
 
 	BUILD_BUG_ON(LIBCFS_IOC_DATA_MAX <
@@ -3880,10 +3894,11 @@ u32 lnet_get_dlc_seq_locked(void)
 			  config->cfg_config_u.cfg_route.rtr_sensitivity;
 		}
 
+		lnet_nid4_to_nid(config->cfg_nid, &nid);
 		mutex_lock(&the_lnet.ln_api_mutex);
 		rc = lnet_add_route(config->cfg_net,
 				    config->cfg_config_u.cfg_route.rtr_hop,
-				    config->cfg_nid,
+				    &nid,
 				    config->cfg_config_u.cfg_route.rtr_priority,
 				    sensitivity);
 		mutex_unlock(&the_lnet.ln_api_mutex);
diff --git a/net/lnet/lnet/config.c b/net/lnet/lnet/config.c
index 0c833fe..f499c91 100644
--- a/net/lnet/lnet/config.c
+++ b/net/lnet/lnet/config.c
@@ -1065,7 +1065,7 @@ struct lnet_ni *
 	struct list_head *tmp1;
 	struct list_head *tmp2;
 	u32 net;
-	lnet_nid_t nid;
+	struct lnet_nid nid;
 	struct lnet_text_buf *ltb;
 	struct lnet_text_buf *ltb1, *ltb2;
 	int rc;
@@ -1145,8 +1145,8 @@ struct lnet_ni *
 				if (rc < 0)
 					goto token_error;
 
-				nid = libcfs_str2nid(ltb->ltb_text);
-				if (nid == LNET_NID_ANY || nid == LNET_NID_LO_0)
+				if (libcfs_strnid(&nid, ltb->ltb_text) != 0 ||
+				    nid_is_lo0(&nid))
 					goto token_error;
 			}
 		}
@@ -1167,19 +1167,18 @@ struct lnet_ni *
 		LASSERT(net != LNET_NET_ANY);
 
 		list_for_each_entry(ltb2, &gateways, ltb_list) {
-			nid = libcfs_str2nid(ltb2->ltb_text);
-			LASSERT(nid != LNET_NID_ANY);
+			LASSERT(libcfs_strnid(&nid, ltb->ltb_text) == 0);
 
-			if (lnet_islocalnid(nid)) {
+			if (lnet_islocalnid(&nid)) {
 				*im_a_router = 1;
 				continue;
 			}
 
-			rc = lnet_add_route(net, hops, nid, priority, 1);
+			rc = lnet_add_route(net, hops, &nid, priority, 1);
 			if (rc && rc != -EEXIST && rc != -EHOSTUNREACH) {
 				CERROR("Can't create route to %s via %s\n",
 				       libcfs_net2str(net),
-				       libcfs_nid2str(nid));
+				       libcfs_nidstr(&nid));
 				goto out;
 			}
 		}
diff --git a/net/lnet/lnet/lib-move.c b/net/lnet/lnet/lib-move.c
index 8c8db31..2454a0c 100644
--- a/net/lnet/lnet/lib-move.c
+++ b/net/lnet/lnet/lib-move.c
@@ -4298,7 +4298,7 @@ void lnet_monitor_thr_stop(void)
 			return -EPROTO;
 		}
 
-		if (lnet_islocalnid(dest_nid)) {
+		if (lnet_islocalnid4(dest_nid)) {
 			/*
 			 * dest is another local NI; sender should have used
 			 * this node's NID on its own network
diff --git a/net/lnet/lnet/peer.c b/net/lnet/lnet/peer.c
index 17f99ee..4b6f339 100644
--- a/net/lnet/lnet/peer.c
+++ b/net/lnet/lnet/peer.c
@@ -107,15 +107,13 @@
 }
 
 static struct lnet_peer_ni *
-lnet_peer_ni_alloc(lnet_nid_t nid4)
+lnet_peer_ni_alloc(struct lnet_nid *nid)
 {
 	struct lnet_peer_ni *lpni;
 	struct lnet_net *net;
-	struct lnet_nid nid;
 	int cpt;
 
-	lnet_nid4_to_nid(nid4, &nid);
-	cpt = lnet_nid_cpt_hash(&nid, LNET_CPT_NUMBER);
+	cpt = lnet_nid_cpt_hash(nid, LNET_CPT_NUMBER);
 
 	lpni = kzalloc_cpt(sizeof(*lpni), GFP_KERNEL, cpt);
 	if (!lpni)
@@ -138,11 +136,11 @@
 	else
 		lpni->lpni_ns_status = LNET_NI_STATUS_UP;
 	lpni->lpni_ping_feats = LNET_PING_FEAT_INVAL;
-	lpni->lpni_nid = nid;
+	lpni->lpni_nid = *nid;
 	lpni->lpni_cpt = cpt;
 	atomic_set(&lpni->lpni_healthv, LNET_MAX_HEALTH_VALUE);
 
-	net = lnet_get_net_locked(LNET_NID_NET(&nid));
+	net = lnet_get_net_locked(LNET_NID_NET(nid));
 	lpni->lpni_net = net;
 	if (net) {
 		lpni->lpni_txcredits = net->net_tunables.lct_peer_tx_credits;
@@ -204,12 +202,10 @@
 }
 
 static struct lnet_peer *
-lnet_peer_alloc(lnet_nid_t nid4)
+lnet_peer_alloc(struct lnet_nid *nid)
 {
 	struct lnet_peer *lp;
-	struct lnet_nid nid;
 
-	lnet_nid4_to_nid(nid4, &nid);
 	lp = kzalloc_cpt(sizeof(*lp), GFP_KERNEL, CFS_CPT_ANY);
 	if (!lp)
 		return NULL;
@@ -223,7 +219,7 @@
 	INIT_LIST_HEAD(&lp->lp_rtr_list);
 	init_waitqueue_head(&lp->lp_dc_waitq);
 	spin_lock_init(&lp->lp_lock);
-	lp->lp_primary_nid = nid;
+	lp->lp_primary_nid = *nid;
 	lp->lp_disc_src_nid = LNET_ANY_NID;
 	lp->lp_disc_dst_nid = LNET_ANY_NID;
 	if (lnet_peers_start_down())
@@ -243,9 +239,9 @@
 	 * to ever use a different interface when sending messages to
 	 * myself.
 	 */
-	if (nid_is_lo0(&nid))
+	if (nid_is_lo0(nid))
 		lp->lp_state = LNET_PEER_NO_DISCOVERY;
-	lp->lp_cpt = lnet_nid_cpt_hash(&nid, LNET_CPT_NUMBER);
+	lp->lp_cpt = lnet_nid_cpt_hash(nid, LNET_CPT_NUMBER);
 
 	CDEBUG(D_NET, "%p nid %s\n", lp, libcfs_nidstr(&lp->lp_primary_nid));
 
@@ -760,6 +756,24 @@ struct lnet_peer_ni *
 	return NULL;
 }
 
+struct lnet_peer_ni *
+lnet_peer_ni_get_locked(struct lnet_peer *lp, struct lnet_nid *nid)
+{
+	struct lnet_peer_net *lpn;
+	struct lnet_peer_ni *lpni;
+
+	lpn = lnet_peer_get_net_locked(lp, LNET_NID_NET(nid));
+	if (!lpn)
+		return NULL;
+
+	list_for_each_entry(lpni, &lpn->lpn_peer_nis, lpni_peer_nis) {
+		if (nid_same(&lpni->lpni_nid, nid))
+			return lpni;
+	}
+
+	return NULL;
+}
+
 struct lnet_peer *
 lnet_find_peer(lnet_nid_t nid)
 {
@@ -1592,20 +1606,21 @@ struct lnet_peer_net *
  * Call with the lnet_api_mutex held.
  */
 static int
-lnet_peer_add(lnet_nid_t nid, unsigned int flags)
+lnet_peer_add(lnet_nid_t nid4, unsigned int flags)
 {
+	struct lnet_nid nid;
 	struct lnet_peer *lp;
 	struct lnet_peer_net *lpn;
 	struct lnet_peer_ni *lpni;
 	int rc = 0;
 
-	LASSERT(nid != LNET_NID_ANY);
+	LASSERT(nid4 != LNET_NID_ANY);
 
 	/*
 	 * No need for the lnet_net_lock here, because the
 	 * lnet_api_mutex is held.
 	 */
-	lpni = lnet_find_peer_ni_locked(nid);
+	lpni = lnet_find_peer_ni_locked(nid4);
 	if (lpni) {
 		/* A peer with this NID already exists. */
 		lp = lpni->lpni_peer_net->lpn_peer;
@@ -1617,13 +1632,13 @@ struct lnet_peer_net *
 		 * that an existing peer is being modified.
 		 */
 		if (lp->lp_state & LNET_PEER_CONFIGURED) {
-			if (lnet_nid_to_nid4(&lp->lp_primary_nid) != nid)
+			if (lnet_nid_to_nid4(&lp->lp_primary_nid) != nid4)
 				rc = -EEXIST;
 			else if ((lp->lp_state ^ flags) & LNET_PEER_MULTI_RAIL)
 				rc = -EPERM;
 			goto out;
 		} else if (!(flags & LNET_PEER_CONFIGURED)) {
-			if (lnet_nid_to_nid4(&lp->lp_primary_nid) == nid) {
+			if (lnet_nid_to_nid4(&lp->lp_primary_nid) == nid4) {
 				rc = -EEXIST;
 				goto out;
 			}
@@ -1634,13 +1649,14 @@ struct lnet_peer_net *
 
 	/* Create peer, peer_net, and peer_ni. */
 	rc = -ENOMEM;
-	lp = lnet_peer_alloc(nid);
+	lnet_nid4_to_nid(nid4, &nid);
+	lp = lnet_peer_alloc(&nid);
 	if (!lp)
 		goto out;
-	lpn = lnet_peer_net_alloc(LNET_NIDNET(nid));
+	lpn = lnet_peer_net_alloc(LNET_NID_NET(&nid));
 	if (!lpn)
 		goto out_free_lp;
-	lpni = lnet_peer_ni_alloc(nid);
+	lpni = lnet_peer_ni_alloc(&nid);
 	if (!lpni)
 		goto out_free_lpn;
 
@@ -1652,7 +1668,7 @@ struct lnet_peer_net *
 	kfree(lp);
 out:
 	CDEBUG(D_NET, "peer %s NID flags %#x: %d\n",
-	       libcfs_nid2str(nid), flags, rc);
+	       libcfs_nid2str(nid4), flags, rc);
 	return rc;
 }
 
@@ -1667,14 +1683,17 @@ struct lnet_peer_net *
  *             non-multi-rail peer.
  */
 static int
-lnet_peer_add_nid(struct lnet_peer *lp, lnet_nid_t nid, unsigned int flags)
+lnet_peer_add_nid(struct lnet_peer *lp, lnet_nid_t nid4, unsigned int flags)
 {
 	struct lnet_peer_net *lpn;
 	struct lnet_peer_ni *lpni;
+	struct lnet_nid nid;
 	int rc = 0;
 
 	LASSERT(lp);
-	LASSERT(nid != LNET_NID_ANY);
+	LASSERT(nid4 != LNET_NID_ANY);
+
+	lnet_nid4_to_nid(nid4, &nid);
 
 	/* A configured peer can only be updated through configuration. */
 	if (!(flags & LNET_PEER_CONFIGURED)) {
@@ -1700,7 +1719,7 @@ struct lnet_peer_net *
 		goto out;
 	}
 
-	lpni = lnet_find_peer_ni_locked(nid);
+	lpni = lnet_find_peer_ni_locked(nid4);
 	if (lpni) {
 		/*
 		 * A peer_ni already exists. This is only a problem if
@@ -1747,14 +1766,14 @@ struct lnet_peer_net *
 			}
 			lnet_peer_del(lp2);
 			lnet_peer_ni_decref_locked(lpni);
-			lpni = lnet_peer_ni_alloc(nid);
+			lpni = lnet_peer_ni_alloc(&nid);
 			if (!lpni) {
 				rc = -ENOMEM;
 				goto out_free_lpni;
 			}
 		}
 	} else {
-		lpni = lnet_peer_ni_alloc(nid);
+		lpni = lnet_peer_ni_alloc(&nid);
 		if (!lpni) {
 			rc = -ENOMEM;
 			goto out_free_lpni;
@@ -1765,9 +1784,9 @@ struct lnet_peer_net *
 	 * Get the peer_net. Check that we're not adding a second
 	 * peer_ni on a peer_net of a non-multi-rail peer.
 	 */
-	lpn = lnet_peer_get_net_locked(lp, LNET_NIDNET(nid));
+	lpn = lnet_peer_get_net_locked(lp, LNET_NIDNET(nid4));
 	if (!lpn) {
-		lpn = lnet_peer_net_alloc(LNET_NIDNET(nid));
+		lpn = lnet_peer_net_alloc(LNET_NIDNET(nid4));
 		if (!lpn) {
 			rc = -ENOMEM;
 			goto out_free_lpni;
@@ -1783,7 +1802,7 @@ struct lnet_peer_net *
 	lnet_peer_ni_decref_locked(lpni);
 out:
 	CDEBUG(D_NET, "peer %s NID %s flags %#x: %d\n",
-	       libcfs_nidstr(&lp->lp_primary_nid), libcfs_nid2str(nid),
+	       libcfs_nidstr(&lp->lp_primary_nid), libcfs_nid2str(nid4),
 	       flags, rc);
 	return rc;
 }
@@ -1830,7 +1849,7 @@ struct lnet_peer_net *
  * lpni creation initiated due to traffic either sending or receiving.
  */
 static int
-lnet_peer_ni_traffic_add(lnet_nid_t nid, lnet_nid_t pref)
+lnet_peer_ni_traffic_add(struct lnet_nid *nid, lnet_nid_t pref)
 {
 	struct lnet_peer *lp;
 	struct lnet_peer_net *lpn;
@@ -1838,13 +1857,13 @@ struct lnet_peer_net *
 	unsigned int flags = 0;
 	int rc = 0;
 
-	if (nid == LNET_NID_ANY) {
+	if (LNET_NID_IS_ANY(nid)) {
 		rc = -EINVAL;
 		goto out;
 	}
 
 	/* lnet_net_lock is not needed here because ln_api_lock is held */
-	lpni = lnet_find_peer_ni_locked(nid);
+	lpni = lnet_peer_ni_find_locked(nid);
 	if (lpni) {
 		/*
 		 * We must have raced with another thread. Since we
@@ -1861,7 +1880,7 @@ struct lnet_peer_net *
 	lp = lnet_peer_alloc(nid);
 	if (!lp)
 		goto out;
-	lpn = lnet_peer_net_alloc(LNET_NIDNET(nid));
+	lpn = lnet_peer_net_alloc(LNET_NID_NET(nid));
 	if (!lpn)
 		goto out_free_lp;
 	lpni = lnet_peer_ni_alloc(nid);
@@ -1877,7 +1896,7 @@ struct lnet_peer_net *
 out_free_lp:
 	kfree(lp);
 out:
-	CDEBUG(D_NET, "peer %s: %d\n", libcfs_nid2str(nid), rc);
+	CDEBUG(D_NET, "peer %s: %d\n", libcfs_nidstr(nid), rc);
 	return rc;
 }
 
@@ -2047,7 +2066,7 @@ struct lnet_peer_net *
 }
 
 struct lnet_peer_ni *
-lnet_nid2peerni_ex(lnet_nid_t nid, int cpt)
+lnet_nid2peerni_ex(struct lnet_nid *nid, int cpt)
 {
 	struct lnet_peer_ni *lpni = NULL;
 	int rc;
@@ -2059,7 +2078,7 @@ struct lnet_peer_ni *
 	 * find if a peer_ni already exists.
 	 * If so then just return that.
 	 */
-	lpni = lnet_find_peer_ni_locked(nid);
+	lpni = lnet_peer_ni_find_locked(nid);
 	if (lpni)
 		return lpni;
 
@@ -2071,7 +2090,7 @@ struct lnet_peer_ni *
 		goto out_net_relock;
 	}
 
-	lpni = lnet_find_peer_ni_locked(nid);
+	lpni = lnet_peer_ni_find_locked(nid);
 	LASSERT(lpni);
 
 out_net_relock:
@@ -2085,19 +2104,21 @@ struct lnet_peer_ni *
  * hold on the peer_ni.
  */
 struct lnet_peer_ni *
-lnet_nid2peerni_locked(lnet_nid_t nid, lnet_nid_t pref, int cpt)
+lnet_nid2peerni_locked(lnet_nid_t nid4, lnet_nid_t pref, int cpt)
 {
 	struct lnet_peer_ni *lpni = NULL;
+	struct lnet_nid nid;
 	int rc;
 
 	if (the_lnet.ln_state != LNET_STATE_RUNNING)
 		return ERR_PTR(-ESHUTDOWN);
 
+	lnet_nid4_to_nid(nid4, &nid);
 	/*
 	 * find if a peer_ni already exists.
 	 * If so then just return that.
 	 */
-	lpni = lnet_find_peer_ni_locked(nid);
+	lpni = lnet_find_peer_ni_locked(nid4);
 	if (lpni)
 		return lpni;
 
@@ -2124,13 +2145,13 @@ struct lnet_peer_ni *
 		goto out_mutex_unlock;
 	}
 
-	rc = lnet_peer_ni_traffic_add(nid, pref);
+	rc = lnet_peer_ni_traffic_add(&nid, pref);
 	if (rc) {
 		lpni = ERR_PTR(rc);
 		goto out_mutex_unlock;
 	}
 
-	lpni = lnet_find_peer_ni_locked(nid);
+	lpni = lnet_find_peer_ni_locked(nid4);
 	LASSERT(lpni);
 
 out_mutex_unlock:
@@ -3242,7 +3263,7 @@ static int lnet_peer_deletion(struct lnet_peer *lp)
 		/* re-add these routes */
 		lnet_add_route(route->lr_net,
 			       route->lr_hops,
-			       route->lr_nid,
+			       &route->lr_nid,
 			       route->lr_priority,
 			       sensitivity);
 		kfree(route);
diff --git a/net/lnet/lnet/router.c b/net/lnet/lnet/router.c
index 2d5f0b6..6cfcead 100644
--- a/net/lnet/lnet/router.c
+++ b/net/lnet/lnet/router.c
@@ -170,7 +170,7 @@ static void lnet_del_route_from_rnet(lnet_nid_t gw_nid,
 
 	CDEBUG(D_NET, "deleting route %s->%s\n",
 	       libcfs_net2str(route->lr_net),
-	       libcfs_nid2str(route->lr_nid));
+	       libcfs_nidstr(&route->lr_nid));
 
 	/* use the gateway's lp_primary_nid to delete the route as the
 	 * lr_nid can be a constituent NID of the peer
@@ -207,7 +207,7 @@ static void lnet_del_route_from_rnet(lnet_nid_t gw_nid,
 		CDEBUG(D_NET, "%s: %s->%s\n",
 		       libcfs_nidstr(&src->lp_primary_nid),
 		       libcfs_net2str(route->lr_net),
-		       libcfs_nid2str(route->lr_nid));
+		       libcfs_nidstr(&route->lr_nid));
 	}
 	list_splice_init(&src->lp_rtrq, &target->lp_rtrq);
 	list_for_each_entry_safe(route, tmp, &src->lp_routes, lr_gwlist) {
@@ -356,7 +356,7 @@ bool lnet_is_route_alive(struct lnet_route *route)
 	 * intent here is not to confuse the user who added the route.
 	 */
 	list_for_each_entry(route, &orig_lp->lp_routes, lr_gwlist) {
-		lpni = lnet_peer_get_ni_locked(orig_lp, route->lr_nid);
+		lpni = lnet_peer_ni_get_locked(orig_lp, &route->lr_nid);
 		if (!lpni) {
 			lnet_net_lock(LNET_LOCK_EX);
 			list_move(&route->lr_gwlist, &new_lp->lp_routes);
@@ -640,7 +640,7 @@ static void lnet_shuffle_seed(void)
 }
 
 int
-lnet_add_route(u32 net, u32 hops, lnet_nid_t gateway,
+lnet_add_route(u32 net, u32 hops, struct lnet_nid *gateway,
 	       u32 priority, u32 sensitivity)
 {
 	struct list_head *route_entry;
@@ -653,13 +653,13 @@ static void lnet_shuffle_seed(void)
 	int rc;
 
 	CDEBUG(D_NET, "Add route: remote net %s hops %d priority %u gw %s\n",
-	       libcfs_net2str(net), hops, priority, libcfs_nid2str(gateway));
+	       libcfs_net2str(net), hops, priority, libcfs_nidstr(gateway));
 
-	if (gateway == LNET_NID_ANY ||
-	    gateway == LNET_NID_LO_0 ||
+	if (LNET_NID_IS_ANY(gateway) ||
+	    nid_is_lo0(gateway) ||
 	    net == LNET_NET_ANY ||
 	    LNET_NETTYP(net) == LOLND ||
-	    LNET_NIDNET(gateway) == net ||
+	    LNET_NID_NET(gateway) == net ||
 	    (hops != LNET_UNDEFINED_HOPS && (hops < 1 || hops > 255)))
 		return -EINVAL;
 
@@ -667,10 +667,10 @@ static void lnet_shuffle_seed(void)
 	if (lnet_islocalnet(net))
 		return -EEXIST;
 
-	if (!lnet_islocalnet(LNET_NIDNET(gateway))) {
+	if (!lnet_islocalnet(LNET_NID_NET(gateway))) {
 		CERROR("Cannot add route with gateway %s. There is no local interface configured on LNet %s\n",
-		       libcfs_nid2str(gateway),
-		       libcfs_net2str(LNET_NIDNET(gateway)));
+		       libcfs_nidstr(gateway),
+		       libcfs_net2str(LNET_NID_NET(gateway)));
 		return -EHOSTUNREACH;
 	}
 
@@ -679,7 +679,7 @@ static void lnet_shuffle_seed(void)
 	rnet = kzalloc(sizeof(*rnet), GFP_NOFS);
 	if (!route || !rnet) {
 		CERROR("Out of memory creating route %s %d %s\n",
-		       libcfs_net2str(net), hops, libcfs_nid2str(gateway));
+		       libcfs_net2str(net), hops, libcfs_nidstr(gateway));
 		kfree(route);
 		kfree(rnet);
 		return -ENOMEM;
@@ -688,9 +688,9 @@ static void lnet_shuffle_seed(void)
 	INIT_LIST_HEAD(&rnet->lrn_routes);
 	rnet->lrn_net = net;
 	/* store the local and remote net that the route represents */
-	route->lr_lnet = LNET_NIDNET(gateway);
+	route->lr_lnet = LNET_NID_NET(gateway);
 	route->lr_net = net;
-	route->lr_nid = gateway;
+	route->lr_nid = *gateway;
 	route->lr_priority = priority;
 	route->lr_hops = hops;
 	if (lnet_peers_start_down())
@@ -713,7 +713,7 @@ static void lnet_shuffle_seed(void)
 		rc = PTR_ERR(lpni);
 		CERROR("Error %d creating route %s %d %s\n", rc,
 		       libcfs_net2str(net), hops,
-		       libcfs_nid2str(gateway));
+		       libcfs_nidstr(gateway));
 		return rc;
 	}
 
@@ -741,8 +741,8 @@ static void lnet_shuffle_seed(void)
 		}
 
 		/* our lookups must be true */
-		LASSERT(lnet_nid_to_nid4(&route2->lr_gateway->lp_primary_nid) !=
-			gateway);
+		LASSERT(!nid_same(&route2->lr_gateway->lp_primary_nid,
+				  gateway));
 	}
 
 	/* It is possible to add multiple routes through the same peer,
@@ -933,8 +933,8 @@ int lnet_get_rtr_pool_cfg(int cpt, struct lnet_ioctl_pool_cfg *pool_cfg)
 }
 
 int
-lnet_get_route(int idx, u32 *net, u32 *hops,
-	       lnet_nid_t *gateway, u32 *flags, u32 *priority, u32 *sensitivity)
+lnet_get_route(int idx, u32 *net, u32 *hops, lnet_nid_t *gateway,
+	       u32 *flags, u32 *priority, u32 *sensitivity)
 {
 	struct lnet_remotenet *rnet;
 	struct list_head *rn_list;
@@ -950,7 +950,7 @@ int lnet_get_rtr_pool_cfg(int cpt, struct lnet_ioctl_pool_cfg *pool_cfg)
 			list_for_each_entry(route, &rnet->lrn_routes, lr_list) {
 				if (!idx--) {
 					*net = rnet->lrn_net;
-					*gateway = route->lr_nid;
+					*gateway = lnet_nid_to_nid4(&route->lr_nid);
 					*hops = route->lr_hops;
 					*priority =
 					    route->lr_priority;
@@ -1774,8 +1774,7 @@ bool lnet_router_checker_active(void)
 		 */
 		if (lnet_is_discovery_disabled(lp)) {
 			list_for_each_entry(route, &lp->lp_routes, lr_gwlist) {
-				if (route->lr_nid ==
-				    lnet_nid_to_nid4(&lpni->lpni_nid))
+				if (nid_same(&route->lr_nid, &lpni->lpni_nid))
 					lnet_set_route_aliveness(route, alive);
 			}
 		}
diff --git a/net/lnet/lnet/router_proc.c b/net/lnet/lnet/router_proc.c
index 2e3c802..a53d6fa 100644
--- a/net/lnet/lnet/router_proc.c
+++ b/net/lnet/lnet/router_proc.c
@@ -217,7 +217,7 @@ static int proc_lnet_routes(struct ctl_table *table, int write,
 				       libcfs_net2str(net), hops,
 				       priority,
 				       alive ? "up" : "down",
-				       libcfs_nid2str(route->lr_nid));
+				       libcfs_nidstr(&route->lr_nid));
 			LASSERT(tmpstr + tmpsiz - s > 0);
 		}
 
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
