Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 5BDCFC19F29
	for <lustre-devel@archiver.kernel.org>; Thu,  4 Aug 2022 01:40:07 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4LyryG5XK0z231H;
	Wed,  3 Aug 2022 18:40:06 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4LyrwW148Nz23JV
 for <lustre-devel@lists.lustre.org>; Wed,  3 Aug 2022 18:38:35 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id C66FF100B003;
 Wed,  3 Aug 2022 21:38:23 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id C49BF905FD; Wed,  3 Aug 2022 21:38:23 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Wed,  3 Aug 2022 21:37:58 -0400
Message-Id: <1659577097-19253-14-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1659577097-19253-1-git-send-email-jsimmons@infradead.org>
References: <1659577097-19253-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 13/32] lnet: change lnet_*_peer_ni to take
 struct lnet_nid
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

lnet_add_peer_ni() and lnet_del_peer_ni() now take
struct lnet_nid rather than lnet_nid_t.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10391
Lustre-commit: d9af9b5a7ee706660 ("LU-10391 lnet: change lnet_*_peer_ni to take struct lnet_nid")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/44625
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Chris Horn <chris.horn@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/lib-lnet.h |  5 +--
 net/lnet/lnet/api-ni.c        | 14 +++++---
 net/lnet/lnet/peer.c          | 74 +++++++++++++++++++++----------------------
 3 files changed, 49 insertions(+), 44 deletions(-)

diff --git a/include/linux/lnet/lib-lnet.h b/include/linux/lnet/lib-lnet.h
index 3bdb49e..5a83190 100644
--- a/include/linux/lnet/lib-lnet.h
+++ b/include/linux/lnet/lib-lnet.h
@@ -930,8 +930,9 @@ bool lnet_peer_is_pref_rtr_locked(struct lnet_peer_ni *lpni,
 int lnet_peer_add_pref_rtr(struct lnet_peer_ni *lpni, struct lnet_nid *nid);
 int lnet_peer_ni_set_non_mr_pref_nid(struct lnet_peer_ni *lpni,
 				     struct lnet_nid *nid);
-int lnet_add_peer_ni(lnet_nid_t key_nid, lnet_nid_t nid, bool mr, bool temp);
-int lnet_del_peer_ni(lnet_nid_t key_nid, lnet_nid_t nid);
+int lnet_add_peer_ni(struct lnet_nid *key_nid, struct lnet_nid *nid, bool mr,
+		     bool temp);
+int lnet_del_peer_ni(struct lnet_nid *key_nid, struct lnet_nid *nid);
 int lnet_get_peer_info(struct lnet_ioctl_peer_cfg *cfg, void __user *bulk);
 int lnet_get_peer_ni_info(u32 peer_index, u64 *nid,
 			  char alivness[LNET_MAX_STR_LEN],
diff --git a/net/lnet/lnet/api-ni.c b/net/lnet/lnet/api-ni.c
index 124ec86..7c94d16 100644
--- a/net/lnet/lnet/api-ni.c
+++ b/net/lnet/lnet/api-ni.c
@@ -4176,27 +4176,31 @@ u32 lnet_get_dlc_seq_locked(void)
 
 	case IOC_LIBCFS_ADD_PEER_NI: {
 		struct lnet_ioctl_peer_cfg *cfg = arg;
+		struct lnet_nid prim_nid;
 
 		if (cfg->prcfg_hdr.ioc_len < sizeof(*cfg))
 			return -EINVAL;
 
 		mutex_lock(&the_lnet.ln_api_mutex);
-		rc = lnet_add_peer_ni(cfg->prcfg_prim_nid,
-				      cfg->prcfg_cfg_nid,
-				      cfg->prcfg_mr, false);
+		lnet_nid4_to_nid(cfg->prcfg_prim_nid, &prim_nid);
+		lnet_nid4_to_nid(cfg->prcfg_cfg_nid, &nid);
+		rc = lnet_add_peer_ni(&prim_nid, &nid, cfg->prcfg_mr, false);
 		mutex_unlock(&the_lnet.ln_api_mutex);
 		return rc;
 	}
 
 	case IOC_LIBCFS_DEL_PEER_NI: {
 		struct lnet_ioctl_peer_cfg *cfg = arg;
+		struct lnet_nid prim_nid;
 
 		if (cfg->prcfg_hdr.ioc_len < sizeof(*cfg))
 			return -EINVAL;
 
 		mutex_lock(&the_lnet.ln_api_mutex);
-		rc = lnet_del_peer_ni(cfg->prcfg_prim_nid,
-				      cfg->prcfg_cfg_nid);
+		lnet_nid4_to_nid(cfg->prcfg_prim_nid, &prim_nid);
+		lnet_nid4_to_nid(cfg->prcfg_cfg_nid, &nid);
+		rc = lnet_del_peer_ni(&prim_nid,
+				      &nid);
 		mutex_unlock(&the_lnet.ln_api_mutex);
 		return rc;
 	}
diff --git a/net/lnet/lnet/peer.c b/net/lnet/lnet/peer.c
index 7a96a2f..8d81a7d 100644
--- a/net/lnet/lnet/peer.c
+++ b/net/lnet/lnet/peer.c
@@ -519,15 +519,14 @@ static void lnet_peer_cancel_discovery(struct lnet_peer *lp)
  *  -EBUSY:  The lnet_peer_ni is the primary, and not the only peer_ni.
  */
 static int
-lnet_peer_del_nid(struct lnet_peer *lp, lnet_nid_t nid4, unsigned int flags)
+lnet_peer_del_nid(struct lnet_peer *lp, struct lnet_nid *nid,
+		  unsigned int flags)
 {
 	struct lnet_peer_ni *lpni;
 	struct lnet_nid primary_nid = lp->lp_primary_nid;
-	struct lnet_nid nid;
 	int rc = 0;
 	bool force = (flags & LNET_PEER_RTR_NI_FORCE_DEL) ? true : false;
 
-	lnet_nid4_to_nid(nid4, &nid);
 	if (!(flags & LNET_PEER_CONFIGURED)) {
 		if (lp->lp_state & LNET_PEER_CONFIGURED) {
 			rc = -EPERM;
@@ -535,7 +534,7 @@ static void lnet_peer_cancel_discovery(struct lnet_peer *lp)
 		}
 	}
 
-	lpni = lnet_peer_ni_find_locked(&nid);
+	lpni = lnet_peer_ni_find_locked(nid);
 	if (!lpni) {
 		rc = -ENOENT;
 		goto out;
@@ -550,14 +549,14 @@ static void lnet_peer_cancel_discovery(struct lnet_peer *lp)
 	 * This function only allows deletion of the primary NID if it
 	 * is the only NID.
 	 */
-	if (nid_same(&nid, &lp->lp_primary_nid) && lp->lp_nnis != 1 && !force) {
+	if (nid_same(nid, &lp->lp_primary_nid) && lp->lp_nnis != 1 && !force) {
 		rc = -EBUSY;
 		goto out;
 	}
 
 	lnet_net_lock(LNET_LOCK_EX);
 
-	if (nid_same(&nid, &lp->lp_primary_nid) && lp->lp_nnis != 1 && force) {
+	if (nid_same(nid, &lp->lp_primary_nid) && lp->lp_nnis != 1 && force) {
 		struct lnet_peer_ni *lpni2;
 		/* assign the next peer_ni to be the primary */
 		lpni2 = lnet_get_next_peer_ni_locked(lp, NULL, lpni);
@@ -570,7 +569,7 @@ static void lnet_peer_cancel_discovery(struct lnet_peer *lp)
 
 out:
 	CDEBUG(D_NET, "peer %s NID %s flags %#x: %d\n",
-	       libcfs_nidstr(&primary_nid), libcfs_nidstr(&nid),
+	       libcfs_nidstr(&primary_nid), libcfs_nidstr(nid),
 	       flags, rc);
 
 	return rc;
@@ -1333,7 +1332,7 @@ struct lnet_peer_ni *
 int
 LNetAddPeer(lnet_nid_t *nids, u32 num_nids)
 {
-	lnet_nid_t pnid = 0;
+	struct lnet_nid pnid = LNET_ANY_NID;
 	bool mr;
 	int i, rc;
 
@@ -1350,16 +1349,21 @@ struct lnet_peer_ni *
 
 	rc = 0;
 	for (i = 0; i < num_nids; i++) {
+		struct lnet_nid nid;
+
 		if (nids[i] == LNET_NID_LO_0)
 			continue;
 
-		if (!pnid) {
-			pnid = nids[i];
-			rc = lnet_add_peer_ni(pnid, LNET_NID_ANY, mr, true);
+		lnet_nid4_to_nid(nids[i], &nid);
+		if (LNET_NID_IS_ANY(&pnid)) {
+			lnet_nid4_to_nid(nids[i], &pnid);
+			rc = lnet_add_peer_ni(&pnid, &LNET_ANY_NID, mr, true);
 		} else if (lnet_peer_discovery_disabled) {
-			rc = lnet_add_peer_ni(nids[i], LNET_NID_ANY, mr, true);
+			lnet_nid4_to_nid(nids[i], &nid);
+			rc = lnet_add_peer_ni(&nid, &LNET_ANY_NID, mr, true);
 		} else {
-			rc = lnet_add_peer_ni(pnid, nids[i], mr, true);
+			lnet_nid4_to_nid(nids[i], &nid);
+			rc = lnet_add_peer_ni(&pnid, &nid, mr, true);
 		}
 
 		if (rc && rc != -EEXIST)
@@ -1849,20 +1853,17 @@ struct lnet_peer_net *
  * being created/modified/deleted by a different thread.
  */
 int
-lnet_add_peer_ni(lnet_nid_t prim_nid4, lnet_nid_t nid4, bool mr, bool temp)
+lnet_add_peer_ni(struct lnet_nid *prim_nid, struct lnet_nid *nid, bool mr,
+		 bool temp)
 {
-	struct lnet_nid prim_nid, nid;
 	struct lnet_peer *lp = NULL;
 	struct lnet_peer_ni *lpni;
 	unsigned int flags = 0;
 
 	/* The prim_nid must always be specified */
-	if (prim_nid4 == LNET_NID_ANY)
+	if (LNET_NID_IS_ANY(prim_nid))
 		return -EINVAL;
 
-	lnet_nid4_to_nid(prim_nid4, &prim_nid);
-	lnet_nid4_to_nid(nid4, &nid);
-
 	if (!temp)
 		flags = LNET_PEER_CONFIGURED;
 
@@ -1873,11 +1874,11 @@ struct lnet_peer_net *
 	 * If nid isn't specified, we must create a new peer with
 	 * prim_nid as its primary nid.
 	 */
-	if (nid4 == LNET_NID_ANY)
-		return lnet_peer_add(&prim_nid, flags);
+	if (LNET_NID_IS_ANY(nid))
+		return lnet_peer_add(prim_nid, flags);
 
 	/* Look up the prim_nid, which must exist. */
-	lpni = lnet_peer_ni_find_locked(&prim_nid);
+	lpni = lnet_peer_ni_find_locked(prim_nid);
 	if (!lpni)
 		return -ENOENT;
 	lnet_peer_ni_decref_locked(lpni);
@@ -1886,14 +1887,14 @@ struct lnet_peer_net *
 	/* Peer must have been configured. */
 	if (!temp && !(lp->lp_state & LNET_PEER_CONFIGURED)) {
 		CDEBUG(D_NET, "peer %s was not configured\n",
-		       libcfs_nidstr(&prim_nid));
+		       libcfs_nidstr(prim_nid));
 		return -ENOENT;
 	}
 
 	/* Primary NID must match */
-	if (!nid_same(&lp->lp_primary_nid, &prim_nid)) {
+	if (!nid_same(&lp->lp_primary_nid, prim_nid)) {
 		CDEBUG(D_NET, "prim_nid %s is not primary for peer %s\n",
-		       libcfs_nidstr(&prim_nid),
+		       libcfs_nidstr(prim_nid),
 		       libcfs_nidstr(&lp->lp_primary_nid));
 		return -ENODEV;
 	}
@@ -1901,11 +1902,11 @@ struct lnet_peer_net *
 	/* Multi-Rail flag must match. */
 	if ((lp->lp_state ^ flags) & LNET_PEER_MULTI_RAIL) {
 		CDEBUG(D_NET, "multi-rail state mismatch for peer %s\n",
-		       libcfs_nidstr(&prim_nid));
+		       libcfs_nidstr(prim_nid));
 		return -EPERM;
 	}
 
-	return lnet_peer_add_nid(lp, &nid, flags);
+	return lnet_peer_add_nid(lp, nid, flags);
 }
 
 /*
@@ -1920,26 +1921,24 @@ struct lnet_peer_net *
  * being modified/deleted by a different thread.
  */
 int
-lnet_del_peer_ni(lnet_nid_t prim_nid4, lnet_nid_t nid)
+lnet_del_peer_ni(struct lnet_nid *prim_nid, struct lnet_nid *nid)
 {
 	struct lnet_peer *lp;
 	struct lnet_peer_ni *lpni;
 	unsigned int flags;
-	struct lnet_nid prim_nid;
 
-	if (prim_nid4 == LNET_NID_ANY)
+	if (!prim_nid || LNET_NID_IS_ANY(prim_nid))
 		return -EINVAL;
-	lnet_nid4_to_nid(prim_nid4, &prim_nid);
 
-	lpni = lnet_peer_ni_find_locked(&prim_nid);
+	lpni = lnet_peer_ni_find_locked(prim_nid);
 	if (!lpni)
 		return -ENOENT;
 	lnet_peer_ni_decref_locked(lpni);
 	lp = lpni->lpni_peer_net->lpn_peer;
 
-	if (!nid_same(&prim_nid, &lp->lp_primary_nid)) {
+	if (!nid_same(prim_nid, &lp->lp_primary_nid)) {
 		CDEBUG(D_NET, "prim_nid %s is not primary for peer %s\n",
-		       libcfs_nidstr(&prim_nid),
+		       libcfs_nidstr(prim_nid),
 		       libcfs_nidstr(&lp->lp_primary_nid));
 		return -ENODEV;
 	}
@@ -1948,12 +1947,12 @@ struct lnet_peer_net *
 	if (lp->lp_rtr_refcount > 0) {
 		lnet_net_unlock(LNET_LOCK_EX);
 		CERROR("%s is a router. Can not be deleted\n",
-		       libcfs_nidstr(&prim_nid));
+		       libcfs_nidstr(prim_nid));
 		return -EBUSY;
 	}
 	lnet_net_unlock(LNET_LOCK_EX);
 
-	if (nid == LNET_NID_ANY || nid == lnet_nid_to_nid4(&lp->lp_primary_nid))
+	if (LNET_NID_IS_ANY(nid) || nid_same(nid, &lp->lp_primary_nid))
 		return lnet_peer_del(lp);
 
 	flags = LNET_PEER_CONFIGURED;
@@ -3011,9 +3010,10 @@ static int lnet_peer_merge_data(struct lnet_peer *lp,
 		 * being told that the router changed its primary_nid
 		 * then it's okay to delete it.
 		 */
+		lnet_nid4_to_nid(delnis[i], &nid);
 		if (lp->lp_rtr_refcount > 0)
 			flags |= LNET_PEER_RTR_NI_FORCE_DEL;
-		rc = lnet_peer_del_nid(lp, delnis[i], flags);
+		rc = lnet_peer_del_nid(lp, &nid, flags);
 		if (rc) {
 			CERROR("Error deleting NID %s from peer %s: %d\n",
 			       libcfs_nid2str(delnis[i]),
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
