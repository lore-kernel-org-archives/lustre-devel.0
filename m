Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id B5BD5C19F29
	for <lustre-devel@archiver.kernel.org>; Thu,  4 Aug 2022 01:39:00 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4Lyrx01l7tz1y7h;
	Wed,  3 Aug 2022 18:39:00 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4LyrwV2gwxz23JB
 for <lustre-devel@lists.lustre.org>; Wed,  3 Aug 2022 18:38:34 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id C3908100B001;
 Wed,  3 Aug 2022 21:38:23 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id C15588D626; Wed,  3 Aug 2022 21:38:23 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Wed,  3 Aug 2022 21:37:57 -0400
Message-Id: <1659577097-19253-13-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1659577097-19253-1-git-send-email-jsimmons@infradead.org>
References: <1659577097-19253-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 12/32] lnet: discard some peer_ni lookup
 functions
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
Cc: Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Mr NeilBrown <neilb@suse.de>

lnet_nid2peerni_locked(), lnet_peer_get_ni_locked(),
lnet_find_peer4(), and lnet_find_peer_ni_locked() each have few users
left and that can call be change to use alternate versions which take
'struct lnet_nid' rather than 'lnet_nid_t'.

So convert all those callers over, and discard the older functions.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10391
Lustre-commit: 9768d8929a305588f ("LU-10391 lnet: discard some peer_ni lookup functions")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/44624
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Frank Sehr <fsehr@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/lib-lnet.h |   6 --
 net/lnet/lnet/api-ni.c        |  26 +++---
 net/lnet/lnet/lib-move.c      |   8 +-
 net/lnet/lnet/peer.c          | 211 +++++++++++++++---------------------------
 net/lnet/lnet/router.c        |  18 ++--
 net/lnet/lnet/udsp.c          |   8 +-
 6 files changed, 110 insertions(+), 167 deletions(-)

diff --git a/include/linux/lnet/lib-lnet.h b/include/linux/lnet/lib-lnet.h
index e21866b..3bdb49e 100644
--- a/include/linux/lnet/lib-lnet.h
+++ b/include/linux/lnet/lib-lnet.h
@@ -898,19 +898,13 @@ struct lnet_peer_net *lnet_get_next_peer_net_locked(struct lnet_peer *lp,
 struct lnet_peer_ni *lnet_get_next_peer_ni_locked(struct lnet_peer *peer,
 						  struct lnet_peer_net *peer_net,
 						  struct lnet_peer_ni *prev);
-struct lnet_peer_ni *lnet_nid2peerni_locked(lnet_nid_t nid, lnet_nid_t pref,
-					    int cpt);
 struct lnet_peer_ni *lnet_peerni_by_nid_locked(struct lnet_nid *nid,
 					       struct lnet_nid *pref,
 					       int cpt);
 struct lnet_peer_ni *lnet_nid2peerni_ex(struct lnet_nid *nid);
-struct lnet_peer_ni *lnet_peer_get_ni_locked(struct lnet_peer *lp,
-					     lnet_nid_t nid);
 struct lnet_peer_ni *lnet_peer_ni_get_locked(struct lnet_peer *lp,
 					     struct lnet_nid *nid);
-struct lnet_peer_ni *lnet_find_peer_ni_locked(lnet_nid_t nid);
 struct lnet_peer_ni *lnet_peer_ni_find_locked(struct lnet_nid *nid);
-struct lnet_peer *lnet_find_peer4(lnet_nid_t nid);
 struct lnet_peer *lnet_find_peer(struct lnet_nid *nid);
 void lnet_peer_net_added(struct lnet_net *net);
 void lnet_peer_primary_nid_locked(struct lnet_nid *nid,
diff --git a/net/lnet/lnet/api-ni.c b/net/lnet/lnet/api-ni.c
index 165728d..124ec86 100644
--- a/net/lnet/lnet/api-ni.c
+++ b/net/lnet/lnet/api-ni.c
@@ -4381,7 +4381,8 @@ u32 lnet_get_dlc_seq_locked(void)
 			return rc;
 
 		mutex_lock(&the_lnet.ln_api_mutex);
-		lp = lnet_find_peer4(ping->ping_id.nid);
+		lnet_nid4_to_nid(ping->ping_id.nid, &nid);
+		lp = lnet_find_peer(&nid);
 		if (lp) {
 			ping->ping_id.nid =
 				lnet_nid_to_nid4(&lp->lp_primary_nid);
@@ -4405,7 +4406,8 @@ u32 lnet_get_dlc_seq_locked(void)
 			return rc;
 
 		mutex_lock(&the_lnet.ln_api_mutex);
-		lp = lnet_find_peer4(discover->ping_id.nid);
+		lnet_nid4_to_nid(discover->ping_id.nid, &nid);
+		lp = lnet_find_peer(&nid);
 		if (lp) {
 			discover->ping_id.nid =
 				lnet_nid_to_nid4(&lp->lp_primary_nid);
@@ -4687,7 +4689,7 @@ static int lnet_ping(struct lnet_process_id id4, struct lnet_nid *src_nid,
 
 	if (nob < 8) {
 		CERROR("%s: ping info too short %d\n",
-		       libcfs_id2str(id4), nob);
+		       libcfs_idstr(&id), nob);
 		goto fail_ping_buffer_decref;
 	}
 
@@ -4695,19 +4697,19 @@ static int lnet_ping(struct lnet_process_id id4, struct lnet_nid *src_nid,
 		lnet_swap_pinginfo(pbuf);
 	} else if (pbuf->pb_info.pi_magic != LNET_PROTO_PING_MAGIC) {
 		CERROR("%s: Unexpected magic %08x\n",
-		       libcfs_id2str(id4), pbuf->pb_info.pi_magic);
+		       libcfs_idstr(&id), pbuf->pb_info.pi_magic);
 		goto fail_ping_buffer_decref;
 	}
 
 	if (!(pbuf->pb_info.pi_features & LNET_PING_FEAT_NI_STATUS)) {
 		CERROR("%s: ping w/o NI status: 0x%x\n",
-		       libcfs_id2str(id4), pbuf->pb_info.pi_features);
+		       libcfs_idstr(&id), pbuf->pb_info.pi_features);
 		goto fail_ping_buffer_decref;
 	}
 
 	if (nob < LNET_PING_INFO_SIZE(0)) {
 		CERROR("%s: Short reply %d(%d min)\n",
-		       libcfs_id2str(id4),
+		       libcfs_idstr(&id),
 		       nob, (int)LNET_PING_INFO_SIZE(0));
 		goto fail_ping_buffer_decref;
 	}
@@ -4717,7 +4719,7 @@ static int lnet_ping(struct lnet_process_id id4, struct lnet_nid *src_nid,
 
 	if (nob < LNET_PING_INFO_SIZE(n_ids)) {
 		CERROR("%s: Short reply %d(%d expected)\n",
-		       libcfs_id2str(id4),
+		       libcfs_idstr(&id),
 		       nob, (int)LNET_PING_INFO_SIZE(n_ids));
 		goto fail_ping_buffer_decref;
 	}
@@ -4739,7 +4741,7 @@ static int lnet_ping(struct lnet_process_id id4, struct lnet_nid *src_nid,
 }
 
 static int
-lnet_discover(struct lnet_process_id id, u32 force,
+lnet_discover(struct lnet_process_id id4, u32 force,
 	      struct lnet_process_id __user *ids,
 	      int n_ids)
 {
@@ -4747,14 +4749,16 @@ static int lnet_ping(struct lnet_process_id id4, struct lnet_nid *src_nid,
 	struct lnet_peer_ni *p;
 	struct lnet_peer *lp;
 	struct lnet_process_id *buf;
+	struct lnet_processid id;
 	int cpt;
 	int i;
 	int rc;
 
 	if (n_ids <= 0 ||
-	    id.nid == LNET_NID_ANY)
+	    id4.nid == LNET_NID_ANY)
 		return -EINVAL;
 
+	lnet_pid4_to_pid(id4, &id);
 	if (id.pid == LNET_PID_ANY)
 		id.pid = LNET_PID_LUSTRE;
 
@@ -4769,7 +4773,7 @@ static int lnet_ping(struct lnet_process_id id4, struct lnet_nid *src_nid,
 		return -ENOMEM;
 
 	cpt = lnet_net_lock_current();
-	lpni = lnet_nid2peerni_locked(id.nid, LNET_NID_ANY, cpt);
+	lpni = lnet_peerni_by_nid_locked(&id.nid, NULL, cpt);
 	if (IS_ERR(lpni)) {
 		rc = PTR_ERR(lpni);
 		goto out;
@@ -4795,7 +4799,7 @@ static int lnet_ping(struct lnet_process_id id4, struct lnet_nid *src_nid,
 	 * and lookup the lpni again
 	 */
 	lnet_peer_ni_decref_locked(lpni);
-	lpni = lnet_find_peer_ni_locked(id.nid);
+	lpni = lnet_peer_ni_find_locked(&id.nid);
 	if (!lpni) {
 		rc = -ENOENT;
 		goto out;
diff --git a/net/lnet/lnet/lib-move.c b/net/lnet/lnet/lib-move.c
index 53e953f..a514472 100644
--- a/net/lnet/lnet/lib-move.c
+++ b/net/lnet/lnet/lib-move.c
@@ -1907,7 +1907,7 @@ struct lnet_ni *
 		return rc;
 	}
 
-	new_lpni = lnet_find_peer_ni_locked(lnet_nid_to_nid4(&lpni->lpni_nid));
+	new_lpni = lnet_peer_ni_find_locked(&lpni->lpni_nid);
 	if (!new_lpni) {
 		lnet_peer_ni_decref_locked(lpni);
 		return -ENOENT;
@@ -2795,7 +2795,7 @@ struct lnet_ni *
 		 * try to send it via non-multi-rail criteria
 		 */
 		if (!IS_ERR(src_lpni)) {
-			/* Drop ref taken by lnet_nid2peerni_locked() */
+			/* Drop ref taken by lnet_peerni_by_nid_locked() */
 			lnet_peer_ni_decref_locked(src_lpni);
 			src_lp = lpni->lpni_peer_net->lpn_peer;
 			if (lnet_peer_is_multi_rail(src_lp) &&
@@ -3523,7 +3523,7 @@ struct lnet_mt_event_info {
 					    ev_info, the_lnet.ln_mt_handler,
 					    true);
 			lnet_net_lock(0);
-			/* lnet_find_peer_ni_locked() grabs a refcount for
+			/* lnet_peer_ni_find_locked() grabs a refcount for
 			 * us. No need to take it explicitly.
 			 */
 			lpni = lnet_peer_ni_find_locked(&nid);
@@ -3546,7 +3546,7 @@ struct lnet_mt_event_info {
 				spin_unlock(&lpni->lpni_lock);
 			}
 
-			/* Drop the ref taken by lnet_find_peer_ni_locked() */
+			/* Drop the ref taken by lnet_peer_ni_find_locked() */
 			lnet_peer_ni_decref_locked(lpni);
 			lnet_net_unlock(0);
 		} else {
diff --git a/net/lnet/lnet/peer.c b/net/lnet/lnet/peer.c
index 3909c5d..7a96a2f 100644
--- a/net/lnet/lnet/peer.c
+++ b/net/lnet/lnet/peer.c
@@ -698,24 +698,6 @@ static void lnet_peer_cancel_discovery(struct lnet_peer *lp)
 }
 
 struct lnet_peer_ni *
-lnet_find_peer_ni_locked(lnet_nid_t nid4)
-{
-	struct lnet_peer_ni *lpni;
-	struct lnet_peer_table *ptable;
-	int cpt;
-	struct lnet_nid nid;
-
-	lnet_nid4_to_nid(nid4, &nid);
-
-	cpt = lnet_nid_cpt_hash(&nid, LNET_CPT_NUMBER);
-
-	ptable = the_lnet.ln_peer_tables[cpt];
-	lpni = lnet_get_peer_ni_locked(ptable, &nid);
-
-	return lpni;
-}
-
-struct lnet_peer_ni *
 lnet_peer_ni_find_locked(struct lnet_nid *nid)
 {
 	struct lnet_peer_ni *lpni;
@@ -731,24 +713,6 @@ struct lnet_peer_ni *
 }
 
 struct lnet_peer_ni *
-lnet_peer_get_ni_locked(struct lnet_peer *lp, lnet_nid_t nid)
-{
-	struct lnet_peer_net *lpn;
-	struct lnet_peer_ni *lpni;
-
-	lpn = lnet_peer_get_net_locked(lp, LNET_NIDNET(nid));
-	if (!lpn)
-		return NULL;
-
-	list_for_each_entry(lpni, &lpn->lpn_peer_nis, lpni_peer_nis) {
-		if (lnet_nid_to_nid4(&lpni->lpni_nid) == nid)
-			return lpni;
-	}
-
-	return NULL;
-}
-
-struct lnet_peer_ni *
 lnet_peer_ni_get_locked(struct lnet_peer *lp, struct lnet_nid *nid)
 {
 	struct lnet_peer_net *lpn;
@@ -767,25 +731,6 @@ struct lnet_peer_ni *
 }
 
 struct lnet_peer *
-lnet_find_peer4(lnet_nid_t nid)
-{
-	struct lnet_peer_ni *lpni;
-	struct lnet_peer *lp = NULL;
-	int cpt;
-
-	cpt = lnet_net_lock_current();
-	lpni = lnet_find_peer_ni_locked(nid);
-	if (lpni) {
-		lp = lpni->lpni_peer_net->lpn_peer;
-		lnet_peer_addref_locked(lp);
-		lnet_peer_ni_decref_locked(lpni);
-	}
-	lnet_net_unlock(cpt);
-
-	return lp;
-}
-
-struct lnet_peer *
 lnet_find_peer(struct lnet_nid *nid)
 {
 	struct lnet_peer_ni *lpni;
@@ -1620,21 +1565,20 @@ struct lnet_peer_net *
  * Call with the lnet_api_mutex held.
  */
 static int
-lnet_peer_add(lnet_nid_t nid4, unsigned int flags)
+lnet_peer_add(struct lnet_nid *nid, unsigned int flags)
 {
-	struct lnet_nid nid;
 	struct lnet_peer *lp;
 	struct lnet_peer_net *lpn;
 	struct lnet_peer_ni *lpni;
 	int rc = 0;
 
-	LASSERT(nid4 != LNET_NID_ANY);
+	LASSERT(nid);
 
 	/*
 	 * No need for the lnet_net_lock here, because the
 	 * lnet_api_mutex is held.
 	 */
-	lpni = lnet_find_peer_ni_locked(nid4);
+	lpni = lnet_peer_ni_find_locked(nid);
 	if (lpni) {
 		/* A peer with this NID already exists. */
 		lp = lpni->lpni_peer_net->lpn_peer;
@@ -1646,13 +1590,13 @@ struct lnet_peer_net *
 		 * that an existing peer is being modified.
 		 */
 		if (lp->lp_state & LNET_PEER_CONFIGURED) {
-			if (lnet_nid_to_nid4(&lp->lp_primary_nid) != nid4)
+			if (!nid_same(&lp->lp_primary_nid, nid))
 				rc = -EEXIST;
 			else if ((lp->lp_state ^ flags) & LNET_PEER_MULTI_RAIL)
 				rc = -EPERM;
 			goto out;
 		} else if (!(flags & LNET_PEER_CONFIGURED)) {
-			if (lnet_nid_to_nid4(&lp->lp_primary_nid) == nid4) {
+			if (nid_same(&lp->lp_primary_nid, nid)) {
 				rc = -EEXIST;
 				goto out;
 			}
@@ -1665,14 +1609,13 @@ struct lnet_peer_net *
 
 	/* Create peer, peer_net, and peer_ni. */
 	rc = -ENOMEM;
-	lnet_nid4_to_nid(nid4, &nid);
-	lp = lnet_peer_alloc(&nid);
+	lp = lnet_peer_alloc(nid);
 	if (!lp)
 		goto out;
-	lpn = lnet_peer_net_alloc(LNET_NID_NET(&nid));
+	lpn = lnet_peer_net_alloc(LNET_NID_NET(nid));
 	if (!lpn)
 		goto out_free_lp;
-	lpni = lnet_peer_ni_alloc(&nid);
+	lpni = lnet_peer_ni_alloc(nid);
 	if (!lpni)
 		goto out_free_lpn;
 
@@ -1684,7 +1627,7 @@ struct lnet_peer_net *
 	kfree(lp);
 out:
 	CDEBUG(D_NET, "peer %s NID flags %#x: %d\n",
-	       libcfs_nid2str(nid4), flags, rc);
+	       libcfs_nidstr(nid), flags, rc);
 	return rc;
 }
 
@@ -1699,17 +1642,15 @@ struct lnet_peer_net *
  *             non-multi-rail peer.
  */
 static int
-lnet_peer_add_nid(struct lnet_peer *lp, lnet_nid_t nid4, unsigned int flags)
+lnet_peer_add_nid(struct lnet_peer *lp, struct lnet_nid *nid,
+		  unsigned int flags)
 {
 	struct lnet_peer_net *lpn;
 	struct lnet_peer_ni *lpni;
-	struct lnet_nid nid;
 	int rc = 0;
 
 	LASSERT(lp);
-	LASSERT(nid4 != LNET_NID_ANY);
-
-	lnet_nid4_to_nid(nid4, &nid);
+	LASSERT(nid);
 
 	/* A configured peer can only be updated through configuration. */
 	if (!(flags & LNET_PEER_CONFIGURED)) {
@@ -1735,7 +1676,7 @@ struct lnet_peer_net *
 		goto out;
 	}
 
-	lpni = lnet_find_peer_ni_locked(nid4);
+	lpni = lnet_peer_ni_find_locked(nid);
 	if (lpni) {
 		/*
 		 * A peer_ni already exists. This is only a problem if
@@ -1764,14 +1705,14 @@ struct lnet_peer_net *
 			}
 			lnet_peer_del(lpni->lpni_peer_net->lpn_peer);
 			lnet_peer_ni_decref_locked(lpni);
-			lpni = lnet_peer_ni_alloc(&nid);
+			lpni = lnet_peer_ni_alloc(nid);
 			if (!lpni) {
 				rc = -ENOMEM;
 				goto out_free_lpni;
 			}
 		}
 	} else {
-		lpni = lnet_peer_ni_alloc(&nid);
+		lpni = lnet_peer_ni_alloc(nid);
 		if (!lpni) {
 			rc = -ENOMEM;
 			goto out_free_lpni;
@@ -1782,9 +1723,9 @@ struct lnet_peer_net *
 	 * Get the peer_net. Check that we're not adding a second
 	 * peer_ni on a peer_net of a non-multi-rail peer.
 	 */
-	lpn = lnet_peer_get_net_locked(lp, LNET_NIDNET(nid4));
+	lpn = lnet_peer_get_net_locked(lp, LNET_NID_NET(nid));
 	if (!lpn) {
-		lpn = lnet_peer_net_alloc(LNET_NIDNET(nid4));
+		lpn = lnet_peer_net_alloc(LNET_NID_NET(nid));
 		if (!lpn) {
 			rc = -ENOMEM;
 			goto out_free_lpni;
@@ -1800,7 +1741,7 @@ struct lnet_peer_net *
 	lnet_peer_ni_decref_locked(lpni);
 out:
 	CDEBUG(D_NET, "peer %s NID %s flags %#x: %d\n",
-	       libcfs_nidstr(&lp->lp_primary_nid), libcfs_nid2str(nid4),
+	       libcfs_nidstr(&lp->lp_primary_nid), libcfs_nidstr(nid),
 	       flags, rc);
 	return rc;
 }
@@ -1811,16 +1752,16 @@ struct lnet_peer_net *
  * Call with the lnet_api_mutex held.
  */
 static int
-lnet_peer_set_primary_nid(struct lnet_peer *lp, lnet_nid_t nid,
+lnet_peer_set_primary_nid(struct lnet_peer *lp, struct lnet_nid *nid,
 			  unsigned int flags)
 {
 	struct lnet_nid old = lp->lp_primary_nid;
 	int rc = 0;
 
-	if (lnet_nid_to_nid4(&lp->lp_primary_nid) == nid)
+	if (nid_same(&lp->lp_primary_nid, nid))
 		goto out;
 
-	lnet_nid4_to_nid(nid, &lp->lp_primary_nid);
+	lp->lp_primary_nid = *nid;
 
 	rc = lnet_peer_add_nid(lp, nid, flags);
 	if (rc) {
@@ -1829,7 +1770,7 @@ struct lnet_peer_net *
 	}
 out:
 	CDEBUG(D_NET, "peer %s NID %s: %d\n",
-	       libcfs_nidstr(&old), libcfs_nid2str(nid), rc);
+	       libcfs_nidstr(&old), libcfs_nidstr(nid), rc);
 
 	return rc;
 }
@@ -1908,16 +1849,20 @@ struct lnet_peer_net *
  * being created/modified/deleted by a different thread.
  */
 int
-lnet_add_peer_ni(lnet_nid_t prim_nid, lnet_nid_t nid, bool mr, bool temp)
+lnet_add_peer_ni(lnet_nid_t prim_nid4, lnet_nid_t nid4, bool mr, bool temp)
 {
+	struct lnet_nid prim_nid, nid;
 	struct lnet_peer *lp = NULL;
 	struct lnet_peer_ni *lpni;
 	unsigned int flags = 0;
 
 	/* The prim_nid must always be specified */
-	if (prim_nid == LNET_NID_ANY)
+	if (prim_nid4 == LNET_NID_ANY)
 		return -EINVAL;
 
+	lnet_nid4_to_nid(prim_nid4, &prim_nid);
+	lnet_nid4_to_nid(nid4, &nid);
+
 	if (!temp)
 		flags = LNET_PEER_CONFIGURED;
 
@@ -1928,11 +1873,11 @@ struct lnet_peer_net *
 	 * If nid isn't specified, we must create a new peer with
 	 * prim_nid as its primary nid.
 	 */
-	if (nid == LNET_NID_ANY)
-		return lnet_peer_add(prim_nid, flags);
+	if (nid4 == LNET_NID_ANY)
+		return lnet_peer_add(&prim_nid, flags);
 
 	/* Look up the prim_nid, which must exist. */
-	lpni = lnet_find_peer_ni_locked(prim_nid);
+	lpni = lnet_peer_ni_find_locked(&prim_nid);
 	if (!lpni)
 		return -ENOENT;
 	lnet_peer_ni_decref_locked(lpni);
@@ -1941,14 +1886,14 @@ struct lnet_peer_net *
 	/* Peer must have been configured. */
 	if (!temp && !(lp->lp_state & LNET_PEER_CONFIGURED)) {
 		CDEBUG(D_NET, "peer %s was not configured\n",
-		       libcfs_nid2str(prim_nid));
+		       libcfs_nidstr(&prim_nid));
 		return -ENOENT;
 	}
 
 	/* Primary NID must match */
-	if (lnet_nid_to_nid4(&lp->lp_primary_nid) != prim_nid) {
+	if (!nid_same(&lp->lp_primary_nid, &prim_nid)) {
 		CDEBUG(D_NET, "prim_nid %s is not primary for peer %s\n",
-		       libcfs_nid2str(prim_nid),
+		       libcfs_nidstr(&prim_nid),
 		       libcfs_nidstr(&lp->lp_primary_nid));
 		return -ENODEV;
 	}
@@ -1956,11 +1901,11 @@ struct lnet_peer_net *
 	/* Multi-Rail flag must match. */
 	if ((lp->lp_state ^ flags) & LNET_PEER_MULTI_RAIL) {
 		CDEBUG(D_NET, "multi-rail state mismatch for peer %s\n",
-		       libcfs_nid2str(prim_nid));
+		       libcfs_nidstr(&prim_nid));
 		return -EPERM;
 	}
 
-	return lnet_peer_add_nid(lp, nid, flags);
+	return lnet_peer_add_nid(lp, &nid, flags);
 }
 
 /*
@@ -1975,24 +1920,26 @@ struct lnet_peer_net *
  * being modified/deleted by a different thread.
  */
 int
-lnet_del_peer_ni(lnet_nid_t prim_nid, lnet_nid_t nid)
+lnet_del_peer_ni(lnet_nid_t prim_nid4, lnet_nid_t nid)
 {
 	struct lnet_peer *lp;
 	struct lnet_peer_ni *lpni;
 	unsigned int flags;
+	struct lnet_nid prim_nid;
 
-	if (prim_nid == LNET_NID_ANY)
+	if (prim_nid4 == LNET_NID_ANY)
 		return -EINVAL;
+	lnet_nid4_to_nid(prim_nid4, &prim_nid);
 
-	lpni = lnet_find_peer_ni_locked(prim_nid);
+	lpni = lnet_peer_ni_find_locked(&prim_nid);
 	if (!lpni)
 		return -ENOENT;
 	lnet_peer_ni_decref_locked(lpni);
 	lp = lpni->lpni_peer_net->lpn_peer;
 
-	if (prim_nid != lnet_nid_to_nid4(&lp->lp_primary_nid)) {
+	if (!nid_same(&prim_nid, &lp->lp_primary_nid)) {
 		CDEBUG(D_NET, "prim_nid %s is not primary for peer %s\n",
-		       libcfs_nid2str(prim_nid),
+		       libcfs_nidstr(&prim_nid),
 		       libcfs_nidstr(&lp->lp_primary_nid));
 		return -ENODEV;
 	}
@@ -2001,7 +1948,7 @@ struct lnet_peer_net *
 	if (lp->lp_rtr_refcount > 0) {
 		lnet_net_unlock(LNET_LOCK_EX);
 		CERROR("%s is a router. Can not be deleted\n",
-		       libcfs_nid2str(prim_nid));
+		       libcfs_nidstr(&prim_nid));
 		return -EBUSY;
 	}
 	lnet_net_unlock(LNET_LOCK_EX);
@@ -2141,19 +2088,6 @@ struct lnet_peer_ni *
 	return lpni;
 }
 
-struct lnet_peer_ni *
-lnet_nid2peerni_locked(lnet_nid_t nid4, lnet_nid_t pref4, int cpt)
-{
-	struct lnet_nid nid, pref;
-
-	lnet_nid4_to_nid(nid4, &nid);
-	lnet_nid4_to_nid(pref4, &pref);
-	if (pref4 == LNET_NID_ANY)
-		return lnet_peerni_by_nid_locked(&nid, NULL, cpt);
-	else
-		return lnet_peerni_by_nid_locked(&nid, &pref, cpt);
-}
-
 bool
 lnet_peer_gw_discovery(struct lnet_peer *lp)
 {
@@ -2964,6 +2898,7 @@ static int lnet_peer_merge_data(struct lnet_peer *lp,
 	lnet_nid_t *curnis = NULL;
 	struct lnet_ni_status *addnis = NULL;
 	lnet_nid_t *delnis = NULL;
+	struct lnet_nid nid;
 	unsigned int flags;
 	int ncurnis;
 	int naddnis;
@@ -3031,7 +2966,8 @@ static int lnet_peer_merge_data(struct lnet_peer *lp,
 				 * peer with the latest information we
 				 * received
 				 */
-				lpni = lnet_find_peer_ni_locked(curnis[i]);
+				lnet_nid4_to_nid(curnis[i], &nid);
+				lpni = lnet_peer_ni_find_locked(&nid);
 				if (lpni) {
 					lpni->lpni_ns_status =
 						pbuf->pb_info.pi_ni[j].ns_status;
@@ -3053,7 +2989,8 @@ static int lnet_peer_merge_data(struct lnet_peer *lp,
 		goto out;
 
 	for (i = 0; i < naddnis; i++) {
-		rc = lnet_peer_add_nid(lp, addnis[i].ns_nid, flags);
+		lnet_nid4_to_nid(addnis[i].ns_nid, &nid);
+		rc = lnet_peer_add_nid(lp, &nid, flags);
 		if (rc) {
 			CERROR("Error adding NID %s to peer %s: %d\n",
 			       libcfs_nid2str(addnis[i].ns_nid),
@@ -3061,7 +2998,7 @@ static int lnet_peer_merge_data(struct lnet_peer *lp,
 			if (rc == -ENOMEM)
 				goto out;
 		}
-		lpni = lnet_find_peer_ni_locked(addnis[i].ns_nid);
+		lpni = lnet_peer_ni_find_locked(&nid);
 		if (lpni) {
 			lpni->lpni_ns_status = addnis[i].ns_status;
 			lnet_peer_ni_decref_locked(lpni);
@@ -3090,7 +3027,8 @@ static int lnet_peer_merge_data(struct lnet_peer *lp,
 	 * peer's lp_peer_nets list, and the peer NI for the primary NID should
 	 * be the first entry in its peer net's lpn_peer_nis list.
 	 */
-	lpni = lnet_find_peer_ni_locked(pbuf->pb_info.pi_ni[1].ns_nid);
+	lnet_nid4_to_nid(pbuf->pb_info.pi_ni[1].ns_nid, &nid);
+	lpni = lnet_peer_ni_find_locked(&nid);
 	if (!lpni) {
 		CERROR("Internal error: Failed to lookup peer NI for primary NID: %s\n",
 		       libcfs_nid2str(pbuf->pb_info.pi_ni[1].ns_nid));
@@ -3286,7 +3224,7 @@ static int lnet_peer_data_present(struct lnet_peer *lp)
 {
 	struct lnet_ping_buffer *pbuf;
 	struct lnet_peer_ni *lpni;
-	lnet_nid_t nid = LNET_NID_ANY;
+	struct lnet_nid nid;
 	unsigned int flags;
 	int rc = 0;
 
@@ -3344,9 +3282,9 @@ static int lnet_peer_data_present(struct lnet_peer *lp)
 		lnet_ping_buffer_decref(pbuf);
 		goto out;
 	}
-	nid = pbuf->pb_info.pi_ni[1].ns_nid;
+	lnet_nid4_to_nid(pbuf->pb_info.pi_ni[1].ns_nid, &nid);
 	if (nid_is_lo0(&lp->lp_primary_nid)) {
-		rc = lnet_peer_set_primary_nid(lp, nid, flags);
+		rc = lnet_peer_set_primary_nid(lp, &nid, flags);
 		if (rc)
 			lnet_ping_buffer_decref(pbuf);
 		else
@@ -3358,19 +3296,19 @@ static int lnet_peer_data_present(struct lnet_peer *lp)
 	 * to update the status of the nids that we currently have
 	 * recorded in that peer.
 	 */
-	} else if (lnet_nid_to_nid4(&lp->lp_primary_nid) == nid ||
+	} else if (nid_same(&lp->lp_primary_nid, &nid) ||
 		   (lnet_is_nid_in_ping_info(lnet_nid_to_nid4(&lp->lp_primary_nid),
 					     &pbuf->pb_info) &&
 		    lnet_is_discovery_disabled(lp))) {
 		rc = lnet_peer_merge_data(lp, pbuf);
 	} else {
-		lpni = lnet_find_peer_ni_locked(nid);
+		lpni = lnet_peer_ni_find_locked(&nid);
 		if (!lpni || lp == lpni->lpni_peer_net->lpn_peer) {
-			rc = lnet_peer_set_primary_nid(lp, nid, flags);
+			rc = lnet_peer_set_primary_nid(lp, &nid, flags);
 			if (rc) {
 				CERROR("Primary NID error %s versus %s: %d\n",
 				       libcfs_nidstr(&lp->lp_primary_nid),
-				       libcfs_nid2str(nid), rc);
+				       libcfs_nidstr(&nid), rc);
 				lnet_ping_buffer_decref(pbuf);
 			} else {
 				rc = lnet_peer_merge_data(lp, pbuf);
@@ -3939,19 +3877,21 @@ void lnet_peer_discovery_stop(void)
 /* Debugging */
 
 void
-lnet_debug_peer(lnet_nid_t nid)
+lnet_debug_peer(lnet_nid_t nid4)
 {
 	char *aliveness = "NA";
 	struct lnet_peer_ni *lp;
+	struct lnet_nid nid;
 	int cpt;
 
-	cpt = lnet_cpt_of_nid(nid, NULL);
+	lnet_nid4_to_nid(nid4, &nid);
+	cpt = lnet_nid2cpt(&nid, NULL);
 	lnet_net_lock(cpt);
 
-	lp = lnet_nid2peerni_locked(nid, LNET_NID_ANY, cpt);
+	lp = lnet_peerni_by_nid_locked(&nid, NULL, cpt);
 	if (IS_ERR(lp)) {
 		lnet_net_unlock(cpt);
-		CDEBUG(D_WARNING, "No peer %s\n", libcfs_nid2str(nid));
+		CDEBUG(D_WARNING, "No peer %s\n", libcfs_nidstr(&nid));
 		return;
 	}
 
@@ -4046,18 +3986,19 @@ int lnet_get_peer_info(struct lnet_ioctl_peer_cfg *cfg, void __user *bulk)
 	struct lnet_peer_ni_credit_info *lpni_info;
 	struct lnet_peer_ni *lpni;
 	struct lnet_peer *lp;
-	lnet_nid_t nid;
+	struct lnet_nid nid;
+	lnet_nid_t nid4;
 	u32 size;
 	int rc;
 
-	lp = lnet_find_peer4(cfg->prcfg_prim_nid);
-
+	lnet_nid4_to_nid(cfg->prcfg_prim_nid, &nid);
+	lp = lnet_find_peer(&nid);
 	if (!lp) {
 		rc = -ENOENT;
 		goto out;
 	}
 
-	size = sizeof(nid) + sizeof(*lpni_info) + sizeof(*lpni_stats) +
+	size = sizeof(nid4) + sizeof(*lpni_info) + sizeof(*lpni_stats) +
 	       sizeof(*lpni_msg_stats) + sizeof(*lpni_hstats);
 	size *= lp->lp_nnis;
 	if (size > cfg->prcfg_size) {
@@ -4094,10 +4035,10 @@ int lnet_get_peer_info(struct lnet_ioctl_peer_cfg *cfg, void __user *bulk)
 	while ((lpni = lnet_get_next_peer_ni_locked(lp, NULL, lpni)) != NULL) {
 		if (!nid_is_nid4(&lpni->lpni_nid))
 			continue;
-		nid = lnet_nid_to_nid4(&lpni->lpni_nid);
-		if (copy_to_user(bulk, &nid, sizeof(nid)))
+		nid4 = lnet_nid_to_nid4(&lpni->lpni_nid);
+		if (copy_to_user(bulk, &nid4, sizeof(nid4)))
 			goto out_free_hstats;
-		bulk += sizeof(nid);
+		bulk += sizeof(nid4);
 
 		memset(lpni_info, 0, sizeof(*lpni_info));
 		snprintf(lpni_info->cr_aliveness, LNET_MAX_STR_LEN, "NA");
@@ -4218,12 +4159,13 @@ int lnet_get_peer_info(struct lnet_ioctl_peer_cfg *cfg, void __user *bulk)
 
 /* Call with the ln_api_mutex held */
 void
-lnet_peer_ni_set_healthv(lnet_nid_t nid, int value, bool all)
+lnet_peer_ni_set_healthv(lnet_nid_t nid4, int value, bool all)
 {
 	struct lnet_peer_table *ptable;
 	struct lnet_peer *lp;
 	struct lnet_peer_net *lpn;
 	struct lnet_peer_ni *lpni;
+	struct lnet_nid nid;
 	int lncpt;
 	int cpt;
 	time64_t now;
@@ -4231,11 +4173,12 @@ int lnet_get_peer_info(struct lnet_ioctl_peer_cfg *cfg, void __user *bulk)
 	if (the_lnet.ln_state != LNET_STATE_RUNNING)
 		return;
 
+	lnet_nid4_to_nid(nid4, &nid);
 	now = ktime_get_seconds();
 
 	if (!all) {
 		lnet_net_lock(LNET_LOCK_EX);
-		lpni = lnet_find_peer_ni_locked(nid);
+		lpni = lnet_peer_ni_find_locked(&nid);
 		if (!lpni) {
 			lnet_net_unlock(LNET_LOCK_EX);
 			return;
diff --git a/net/lnet/lnet/router.c b/net/lnet/lnet/router.c
index b4f7aaa..bbef2b3 100644
--- a/net/lnet/lnet/router.c
+++ b/net/lnet/lnet/router.c
@@ -1199,8 +1199,7 @@ bool lnet_router_checker_active(void)
 		spin_unlock(&rtr->lp_lock);
 
 		/* find the peer_ni associated with the primary NID */
-		lpni = lnet_peer_get_ni_locked(rtr,
-					       lnet_nid_to_nid4(&rtr->lp_primary_nid));
+		lpni = lnet_peer_ni_get_locked(rtr, &rtr->lp_primary_nid);
 		if (!lpni) {
 			CDEBUG(D_NET,
 			       "Expected to find an lpni for %s, but non found\n",
@@ -1701,25 +1700,26 @@ bool lnet_router_checker_active(void)
  * when: notificaiton time.
  */
 int
-lnet_notify(struct lnet_ni *ni, lnet_nid_t nid, bool alive, bool reset,
+lnet_notify(struct lnet_ni *ni, lnet_nid_t nid4, bool alive, bool reset,
 	    time64_t when)
 {
 	struct lnet_peer_ni *lpni = NULL;
 	struct lnet_route *route;
 	struct lnet_peer *lp;
 	time64_t now = ktime_get_seconds();
+	struct lnet_nid nid;
 	int cpt;
 
 	LASSERT(!in_interrupt());
 
 	CDEBUG(D_NET, "%s notifying %s: %s\n",
 	       !ni ? "userspace" : libcfs_nidstr(&ni->ni_nid),
-	       libcfs_nid2str(nid), alive ? "up" : "down");
+	       libcfs_nidstr(&nid), alive ? "up" : "down");
 
 	if (ni &&
-	    LNET_NID_NET(&ni->ni_nid) != LNET_NIDNET(nid)) {
+	    LNET_NID_NET(&ni->ni_nid) != LNET_NID_NET(&nid)) {
 		CWARN("Ignoring notification of %s %s by %s (different net)\n",
-		      libcfs_nid2str(nid), alive ? "birth" : "death",
+		      libcfs_nidstr(&nid), alive ? "birth" : "death",
 		      libcfs_nidstr(&ni->ni_nid));
 		return -EINVAL;
 	}
@@ -1728,7 +1728,7 @@ bool lnet_router_checker_active(void)
 	if (when > now) {
 		CWARN("Ignoring prediction from %s of %s %s %lld seconds in the future\n",
 		      ni ? libcfs_nidstr(&ni->ni_nid) : "userspace",
-		      libcfs_nid2str(nid), alive ? "up" : "down", when - now);
+		      libcfs_nidstr(&nid), alive ? "up" : "down", when - now);
 		return -EINVAL;
 	}
 
@@ -1746,11 +1746,11 @@ bool lnet_router_checker_active(void)
 		return -ESHUTDOWN;
 	}
 
-	lpni = lnet_find_peer_ni_locked(nid);
+	lpni = lnet_peer_ni_find_locked(&nid);
 	if (!lpni) {
 		/* nid not found */
 		lnet_net_unlock(0);
-		CDEBUG(D_NET, "%s not found\n", libcfs_nid2str(nid));
+		CDEBUG(D_NET, "%s not found\n", libcfs_nidstr(&nid));
 		return 0;
 	}
 
diff --git a/net/lnet/lnet/udsp.c b/net/lnet/lnet/udsp.c
index 7fa4f88..2594df1 100644
--- a/net/lnet/lnet/udsp.c
+++ b/net/lnet/lnet/udsp.c
@@ -1052,17 +1052,19 @@ struct lnet_udsp *
 {
 	struct lnet_ni *ni;
 	struct lnet_peer_ni *lpni;
+	struct lnet_nid nid;
 
 	lnet_net_lock(0);
+	lnet_nid4_to_nid(info->cud_nid, &nid);
 	if (!info->cud_peer) {
-		ni = lnet_nid2ni_locked(info->cud_nid, 0);
+		ni = lnet_nid_to_ni_locked(&nid, 0);
 		if (ni)
 			lnet_udsp_get_ni_info(info, ni);
 	} else {
-		lpni = lnet_find_peer_ni_locked(info->cud_nid);
+		lpni = lnet_peer_ni_find_locked(&nid);
 		if (!lpni) {
 			CDEBUG(D_NET, "nid %s is not found\n",
-			       libcfs_nid2str(info->cud_nid));
+			       libcfs_nidstr(&nid));
 		} else {
 			lnet_udsp_get_peer_info(info, lpni);
 			lnet_peer_ni_decref_locked(lpni);
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
