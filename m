Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id ADD69C77B70
	for <lustre-devel@archiver.kernel.org>; Mon, 17 Apr 2023 13:56:07 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4Q0T1p1B2Fz21Bq;
	Mon, 17 Apr 2023 06:49:34 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4Q0T036P55z1yFb
 for <lustre-devel@lists.lustre.org>; Mon, 17 Apr 2023 06:48:03 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 7F523100848D;
 Mon, 17 Apr 2023 09:47:24 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 7DF3B375; Mon, 17 Apr 2023 09:47:24 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon, 17 Apr 2023 09:47:07 -0400
Message-Id: <1681739243-29375-12-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1681739243-29375-1-git-send-email-jsimmons@infradead.org>
References: <1681739243-29375-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 11/27] lnet: add 'lock_prim_nid" lnet module
 parameter
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
Cc: Serguei Smirnov <ssmirnov@whamcloud.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Serguei Smirnov <ssmirnov@whamcloud.com>

Add 'lock_prim_nid' lnet module parameter to allow control
of how Lustre peer primary NID is selected.
If set to 1 (default), the NID specified by Lustre when
calling LNet API is designated as primary for the peer,
allowing for non-blocking discovery in the background.
If set to 0, peer discovery is blocking until complete
and the NID listed first in discovery response is designated
as primary.

WC-bug-id: https://jira.whamcloud.com/browse/LU-14668
Lustre-commit: fc7a0d6013b46ebc1 ("LU-14668 lnet: add 'lock_prim_nid" lnet module parameter")
Signed-off-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/50159
Reviewed-by: Chris Horn <chris.horn@hpe.com>
Reviewed-by: Frank Sehr <fsehr@whamcloud.com>
Reviewed-by: Cyril Bordage <cbordage@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/lib-lnet.h |   1 +
 net/lnet/lnet/api-ni.c        |   5 ++
 net/lnet/lnet/peer.c          | 105 +++++++++++++++++++++++++++---------------
 3 files changed, 73 insertions(+), 38 deletions(-)

diff --git a/include/linux/lnet/lib-lnet.h b/include/linux/lnet/lib-lnet.h
index f9f4815..4aa1e5c 100644
--- a/include/linux/lnet/lib-lnet.h
+++ b/include/linux/lnet/lib-lnet.h
@@ -565,6 +565,7 @@ unsigned int lnet_nid_cpt_hash(struct lnet_nid *nid,
 extern int live_router_check_interval;
 extern int dead_router_check_interval;
 extern int portal_rotor;
+extern int lock_prim_nid;
 
 int lnet_lib_init(void);
 void lnet_lib_exit(void);
diff --git a/net/lnet/lnet/api-ni.c b/net/lnet/lnet/api-ni.c
index 9f01dbe..fb596ed 100644
--- a/net/lnet/lnet/api-ni.c
+++ b/net/lnet/lnet/api-ni.c
@@ -208,6 +208,11 @@ static int response_tracking_set(const char *val,
 MODULE_PARM_DESC(lnet_response_tracking,
 		 "(0|1|2|3) LNet Internal Only|GET Reply only|PUT ACK only|Full Tracking (default)");
 
+int lock_prim_nid = 1;
+module_param(lock_prim_nid, int, 0444);
+MODULE_PARM_DESC(lock_prim_nid,
+		 "Whether nid passed down by Lustre is locked as primary");
+
 #define LNET_LND_TIMEOUT_DEFAULT ((LNET_TRANSACTION_TIMEOUT_DEFAULT - 1) / \
 				  (LNET_RETRY_COUNT_DEFAULT + 1))
 unsigned int lnet_lnd_timeout = LNET_LND_TIMEOUT_DEFAULT;
diff --git a/net/lnet/lnet/peer.c b/net/lnet/lnet/peer.c
index ef924ce..f1b0eb0d 100644
--- a/net/lnet/lnet/peer.c
+++ b/net/lnet/lnet/peer.c
@@ -1346,6 +1346,7 @@ struct lnet_peer_ni *
 	struct lnet_nid pnid = LNET_ANY_NID;
 	bool mr;
 	int i, rc;
+	int flags = lock_prim_nid ? LNET_PEER_LOCK_PRIMARY : 0;
 
 	if (!nids || num_nids < 1)
 		return -EINVAL;
@@ -1368,8 +1369,7 @@ struct lnet_peer_ni *
 		lnet_nid4_to_nid(nids[i], &nid);
 		if (LNET_NID_IS_ANY(&pnid)) {
 			lnet_nid4_to_nid(nids[i], &pnid);
-			rc = lnet_add_peer_ni(&pnid, &LNET_ANY_NID, mr,
-					      LNET_PEER_LOCK_PRIMARY);
+			rc = lnet_add_peer_ni(&pnid, &LNET_ANY_NID, mr, flags);
 			if (rc == -EALREADY) {
 				struct lnet_peer *lp;
 
@@ -1385,12 +1385,10 @@ struct lnet_peer_ni *
 			}
 		} else if (lnet_peer_discovery_disabled) {
 			lnet_nid4_to_nid(nids[i], &nid);
-			rc = lnet_add_peer_ni(&nid, &LNET_ANY_NID, mr,
-					      LNET_PEER_LOCK_PRIMARY);
+			rc = lnet_add_peer_ni(&nid, &LNET_ANY_NID, mr, flags);
 		} else {
 			lnet_nid4_to_nid(nids[i], &nid);
-			rc = lnet_add_peer_ni(&pnid, &nid, mr,
-					      LNET_PEER_LOCK_PRIMARY);
+			rc = lnet_add_peer_ni(&pnid, &nid, mr, flags);
 		}
 
 		if (rc && rc != -EEXIST)
@@ -1432,36 +1430,53 @@ void LNetPrimaryNID(struct lnet_nid *nid)
 	 * down then this discovery can introduce long delays into the mount
 	 * process, so skip it if it isn't necessary.
 	 */
+again:
 	spin_lock(&lp->lp_lock);
-	if (!lnet_peer_discovery_disabled &&
-	    (!(lp->lp_state & LNET_PEER_LOCK_PRIMARY) ||
-	     !lnet_peer_is_uptodate_locked(lp))) {
-		/* force a full discovery cycle */
-		lp->lp_state |= LNET_PEER_FORCE_PING | LNET_PEER_FORCE_PUSH |
-				LNET_PEER_LOCK_PRIMARY;
+	if (!(lp->lp_state & LNET_PEER_LOCK_PRIMARY) && lock_prim_nid)
+		lp->lp_state |= LNET_PEER_LOCK_PRIMARY;
+
+	/* DD disabled, nothing to do */
+	if (lnet_peer_discovery_disabled) {
+		*nid = lp->lp_primary_nid;
 		spin_unlock(&lp->lp_lock);
+		goto out_decref;
+	}
 
-		/* start discovery in the background. Messages to that
-		 * peer will not go through until the discovery is
-		 * complete
-		 */
-		rc = lnet_discover_peer_locked(lpni, cpt, false);
-		if (rc)
-			goto out_decref;
-		/* The lpni (or lp) for this NID may have changed and our ref is
-		 * the only thing keeping the old one around. Release the ref
-		 * and lookup the lpni again
-		 */
-		lnet_peer_ni_decref_locked(lpni);
-		lpni = lnet_peer_ni_find_locked(nid);
-		if (!lpni) {
-			rc = -ENOENT;
-			goto out_unlock;
-		}
-		lp = lpni->lpni_peer_net->lpn_peer;
-	} else {
+	/* Peer already up to date, nothing to do */
+	if (lnet_peer_is_uptodate_locked(lp)) {
+		*nid = lp->lp_primary_nid;
 		spin_unlock(&lp->lp_lock);
+		goto out_decref;
 	}
+	spin_unlock(&lp->lp_lock);
+
+	/* If primary nid locking is enabled, discovery is performed
+	 * in the background.
+	 * If primary nid locking is disabled, discovery blocks here.
+	 * Messages to the peer will not go through until the discovery is
+	 * complete.
+	 */
+	if (lock_prim_nid)
+		rc = lnet_discover_peer_locked(lpni, cpt, false);
+	else
+		rc = lnet_discover_peer_locked(lpni, cpt, true);
+	if (rc)
+		goto out_decref;
+
+	/* The lpni (or lp) for this NID may have changed and our ref is
+	 * the only thing keeping the old one around. Release the ref
+	 * and lookup the lpni again
+	 */
+	lnet_peer_ni_decref_locked(lpni);
+	lpni = lnet_peer_ni_find_locked(nid);
+	if (!lpni) {
+		rc = -ENOENT;
+		goto out_unlock;
+	}
+	lp = lpni->lpni_peer_net->lpn_peer;
+
+	if (!lock_prim_nid && !lnet_is_discovery_disabled(lp))
+		goto again;
 	*nid = lp->lp_primary_nid;
 out_decref:
 	lnet_peer_ni_decref_locked(lpni);
@@ -1553,7 +1568,6 @@ struct lnet_peer_net *
 		ptable->pt_peers++;
 	}
 
-
 	/* Update peer state */
 	spin_lock(&lp->lp_lock);
 	if (flags & LNET_PEER_CONFIGURED) {
@@ -1630,10 +1644,8 @@ struct lnet_peer_net *
 				rc = -EPERM;
 			goto out;
 		} else if (lp->lp_state & LNET_PEER_LOCK_PRIMARY) {
-			if (nid_same(&lp->lp_primary_nid, nid)) {
+			if (nid_same(&lp->lp_primary_nid, nid))
 				rc = -EEXIST;
-				goto out;
-			}
 			/* we're trying to recreate an existing peer which
 			 * has already been created and its primary
 			 * locked. This is likely due to two servers
@@ -1641,8 +1653,18 @@ struct lnet_peer_net *
 			 * to that node with the primary NID which was
 			 * first added by Lustre
 			 */
-			rc = -EALREADY;
+			else
+				rc = -EALREADY;
 			goto out;
+		} else if (!(flags & (LNET_PEER_LOCK_PRIMARY | LNET_PEER_CONFIGURED))) {
+			/* if not recreating peer as configured and
+			 * not locking primary nid, no need to
+			 * do anything if primary nid is not being changed
+			 */
+			if (nid_same(&lp->lp_primary_nid, nid)) {
+				rc = -EEXIST;
+				goto out;
+			}
 		}
 		/* Delete and recreate the peer.
 		 * We can get here:
@@ -1952,6 +1974,14 @@ struct lnet_peer_net *
 	lnet_peer_ni_decref_locked(lpni);
 	lp = lpni->lpni_peer_net->lpn_peer;
 
+	/* Peer must have been configured. */
+	if ((flags & LNET_PEER_CONFIGURED) &&
+	    !(lp->lp_state & LNET_PEER_CONFIGURED)) {
+		CDEBUG(D_NET, "peer %s was not configured\n",
+		       libcfs_nidstr(prim_nid));
+		return -ENOENT;
+	}
+
 	/* Primary NID must match */
 	if (!nid_same(&lp->lp_primary_nid, prim_nid)) {
 		CDEBUG(D_NET, "prim_nid %s is not primary for peer %s\n",
@@ -1967,8 +1997,7 @@ struct lnet_peer_net *
 		return -EPERM;
 	}
 
-	if ((flags & LNET_PEER_LOCK_PRIMARY) &&
-	    (lnet_peer_is_uptodate(lp) && (lp->lp_state & LNET_PEER_LOCK_PRIMARY))) {
+	if (lnet_peer_is_uptodate(lp) && !(flags & LNET_PEER_CONFIGURED)) {
 		CDEBUG(D_NET,
 		       "Don't add temporary peer NI for uptodate peer %s\n",
 		       libcfs_nidstr(&lp->lp_primary_nid));
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
