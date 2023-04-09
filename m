Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id F0D38C77B70
	for <lustre-devel@archiver.kernel.org>; Sun,  9 Apr 2023 12:38:37 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4PvWQv6r7Jz22TX;
	Sun,  9 Apr 2023 05:20:39 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4PvWNJ4GZRz22PM
 for <lustre-devel@lists.lustre.org>; Sun,  9 Apr 2023 05:18:24 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 43479100848A;
 Sun,  9 Apr 2023 08:13:28 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 420632B3; Sun,  9 Apr 2023 08:13:28 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun,  9 Apr 2023 08:13:08 -0400
Message-Id: <1681042400-15491-29-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1681042400-15491-1-git-send-email-jsimmons@infradead.org>
References: <1681042400-15491-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 28/40] lnet: Peers added via kernel API
 should be permanent
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
Cc: Chris Horn <chris.horn@hpe.com>, Amir Shehata <ashehata@whamcloud.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Chris Horn <chris.horn@hpe.com>

The LNetAddPeer() API allows Lustre to predefine the Peer for LNet.
Originally these peers would be temporary and potentially re-created
via discovery. Instead, let's make these peers permanent. This allows
Lustre to dictate the primary NID of the peer. LNet makes sure this
primary NID is not changed afterwards.

WC-bug-id: https://jira.whamcloud.com/browse/LU-14668
Lustre-commit: 41733dadd8ad0e87e ("LU-14668 lnet: Peers added via kernel API should be permanent")
Signed-off-by: Amir Shehata <ashehata@whamcloud.com>
Signed-off-by: Chris Horn <chris.horn@hpe.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/43788
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: Cyril Bordage <cbordage@whamcloud.com>
Reviewed-by: Frank Sehr <fsehr@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/lib-lnet.h |  3 +--
 net/lnet/lnet/api-ni.c        |  2 +-
 net/lnet/lnet/peer.c          | 34 +++++++++++++++++-----------------
 3 files changed, 19 insertions(+), 20 deletions(-)

diff --git a/include/linux/lnet/lib-lnet.h b/include/linux/lnet/lib-lnet.h
index d03dcf8..a8aa924 100644
--- a/include/linux/lnet/lib-lnet.h
+++ b/include/linux/lnet/lib-lnet.h
@@ -953,8 +953,7 @@ bool lnet_peer_is_pref_rtr_locked(struct lnet_peer_ni *lpni,
 int lnet_peer_add_pref_rtr(struct lnet_peer_ni *lpni, struct lnet_nid *nid);
 int lnet_peer_ni_set_non_mr_pref_nid(struct lnet_peer_ni *lpni,
 				     struct lnet_nid *nid);
-int lnet_add_peer_ni(struct lnet_nid *key_nid, struct lnet_nid *nid, bool mr,
-		     bool temp);
+int lnet_user_add_peer_ni(struct lnet_nid *key_nid, struct lnet_nid *nid, bool mr);
 int lnet_del_peer_ni(struct lnet_nid *key_nid, struct lnet_nid *nid);
 int lnet_get_peer_info(struct lnet_ioctl_peer_cfg *cfg, void __user *bulk);
 int lnet_get_peer_ni_info(u32 peer_index, u64 *nid,
diff --git a/net/lnet/lnet/api-ni.c b/net/lnet/lnet/api-ni.c
index a4fb95f..20093a9 100644
--- a/net/lnet/lnet/api-ni.c
+++ b/net/lnet/lnet/api-ni.c
@@ -4239,7 +4239,7 @@ u32 lnet_get_dlc_seq_locked(void)
 		mutex_lock(&the_lnet.ln_api_mutex);
 		lnet_nid4_to_nid(cfg->prcfg_prim_nid, &prim_nid);
 		lnet_nid4_to_nid(cfg->prcfg_cfg_nid, &nid);
-		rc = lnet_add_peer_ni(&prim_nid, &nid, cfg->prcfg_mr, false);
+		rc = lnet_user_add_peer_ni(&prim_nid, &nid, cfg->prcfg_mr);
 		mutex_unlock(&the_lnet.ln_api_mutex);
 		return rc;
 	}
diff --git a/net/lnet/lnet/peer.c b/net/lnet/lnet/peer.c
index 0539cb4..fa2ca54 100644
--- a/net/lnet/lnet/peer.c
+++ b/net/lnet/lnet/peer.c
@@ -42,6 +42,8 @@
 #define LNET_REDISCOVER_PEER	(1)
 
 static int lnet_peer_queue_for_discovery(struct lnet_peer *lp);
+static int lnet_add_peer_ni(struct lnet_nid *prim_nid, struct lnet_nid *nid, bool mr,
+			    unsigned int flags);
 
 static void
 lnet_peer_remove_from_remote_list(struct lnet_peer_ni *lpni)
@@ -1366,7 +1368,8 @@ struct lnet_peer_ni *
 		lnet_nid4_to_nid(nids[i], &nid);
 		if (LNET_NID_IS_ANY(&pnid)) {
 			lnet_nid4_to_nid(nids[i], &pnid);
-			rc = lnet_add_peer_ni(&pnid, &LNET_ANY_NID, mr, true);
+			rc = lnet_add_peer_ni(&pnid, &LNET_ANY_NID, mr,
+					      LNET_PEER_LOCK_PRIMARY);
 			if (rc == -EALREADY) {
 				struct lnet_peer *lp;
 
@@ -1382,10 +1385,12 @@ struct lnet_peer_ni *
 			}
 		} else if (lnet_peer_discovery_disabled) {
 			lnet_nid4_to_nid(nids[i], &nid);
-			rc = lnet_add_peer_ni(&nid, &LNET_ANY_NID, mr, true);
+			rc = lnet_add_peer_ni(&nid, &LNET_ANY_NID, mr,
+					      LNET_PEER_LOCK_PRIMARY);
 		} else {
 			lnet_nid4_to_nid(nids[i], &nid);
-			rc = lnet_add_peer_ni(&pnid, &nid, mr, true);
+			rc = lnet_add_peer_ni(&pnid, &nid, mr,
+					      LNET_PEER_LOCK_PRIMARY);
 		}
 
 		if (rc && rc != -EEXIST)
@@ -1918,22 +1923,18 @@ struct lnet_peer_net *
  * The caller must hold ln_api_mutex. This prevents the peer from
  * being created/modified/deleted by a different thread.
  */
-int
+static int
 lnet_add_peer_ni(struct lnet_nid *prim_nid, struct lnet_nid *nid, bool mr,
-		 bool temp)
+		 unsigned int flags)
 __must_hold(&the_lnet.ln_api_mutex)
 {
 	struct lnet_peer *lp = NULL;
 	struct lnet_peer_ni *lpni;
-	unsigned int flags = 0;
 
 	/* The prim_nid must always be specified */
 	if (LNET_NID_IS_ANY(prim_nid))
 		return -EINVAL;
 
-	if (!temp)
-		flags = LNET_PEER_CONFIGURED;
-
 	if (mr)
 		flags |= LNET_PEER_MULTI_RAIL;
 
@@ -1951,13 +1952,6 @@ struct lnet_peer_net *
 	lnet_peer_ni_decref_locked(lpni);
 	lp = lpni->lpni_peer_net->lpn_peer;
 
-	/* Peer must have been configured. */
-	if (!temp && !(lp->lp_state & LNET_PEER_CONFIGURED)) {
-		CDEBUG(D_NET, "peer %s was not configured\n",
-		       libcfs_nidstr(prim_nid));
-		return -ENOENT;
-	}
-
 	/* Primary NID must match */
 	if (!nid_same(&lp->lp_primary_nid, prim_nid)) {
 		CDEBUG(D_NET, "prim_nid %s is not primary for peer %s\n",
@@ -1973,7 +1967,8 @@ struct lnet_peer_net *
 		return -EPERM;
 	}
 
-	if (temp && lnet_peer_is_uptodate(lp)) {
+	if ((flags & LNET_PEER_LOCK_PRIMARY) &&
+	    (lnet_peer_is_uptodate(lp) && (lp->lp_state & LNET_PEER_LOCK_PRIMARY))) {
 		CDEBUG(D_NET,
 		       "Don't add temporary peer NI for uptodate peer %s\n",
 		       libcfs_nidstr(&lp->lp_primary_nid));
@@ -1983,6 +1978,11 @@ struct lnet_peer_net *
 	return lnet_peer_add_nid(lp, nid, flags);
 }
 
+int lnet_user_add_peer_ni(struct lnet_nid *prim_nid, struct lnet_nid *nid, bool mr)
+{
+	return lnet_add_peer_ni(prim_nid, nid, mr, LNET_PEER_CONFIGURED);
+}
+
 /*
  * Implementation of IOC_LIBCFS_DEL_PEER_NI.
  *
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
