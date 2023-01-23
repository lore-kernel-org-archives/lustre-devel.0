Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id E9663C25B50
	for <lustre-devel@archiver.kernel.org>; Mon, 23 Jan 2023 23:03:31 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4P15Fb4MtSz1y6Q;
	Mon, 23 Jan 2023 15:01:39 -0800 (PST)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4P15Dx63b4z1wSM
 for <lustre-devel@lists.lustre.org>; Mon, 23 Jan 2023 15:01:05 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 202426C6;
 Mon, 23 Jan 2023 18:00:58 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 1685158991; Mon, 23 Jan 2023 18:00:58 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon, 23 Jan 2023 18:00:15 -0500
Message-Id: <1674514855-15399-3-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1674514855-15399-1-git-send-email-jsimmons@infradead.org>
References: <1674514855-15399-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 02/42] lnet: lnet_peer_merge_data to
 understand large addr
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

Large addr now understood.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10391
Lustre-commit: 57bcd6aa7f5f347de ("LU-10391 lnet: lnet_peer_merge_data to understand large addr")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/44630
Reviewed-by: Frank Sehr <fsehr@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Chris Horn <chris.horn@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/peer.c | 84 ++++++++++++++++++++++++++++++--------------
 1 file changed, 57 insertions(+), 27 deletions(-)

diff --git a/net/lnet/lnet/peer.c b/net/lnet/lnet/peer.c
index 8c603c903521..a9759860a5cd 100644
--- a/net/lnet/lnet/peer.c
+++ b/net/lnet/lnet/peer.c
@@ -2917,6 +2917,8 @@ u32 *ping_iter_first(struct lnet_ping_iter *pi,
 	 */
 	if (nid)
 		lnet_nid4_to_nid(pbuf->pb_info.pi_ni[0].ns_nid, nid);
+
+	pi->pos += sizeof(struct lnet_ni_status);
 	return &pbuf->pb_info.pi_ni[0].ns_status;
 }
 
@@ -2953,6 +2955,19 @@ u32 *ping_iter_next(struct lnet_ping_iter *pi, struct lnet_nid *nid)
 	return NULL;
 }
 
+static int ping_info_count_entries(struct lnet_ping_buffer *pbuf)
+{
+	struct lnet_ping_iter pi;
+	u32 *st;
+	int nnis = 0;
+
+	for (st = ping_iter_first(&pi, pbuf, NULL); st;
+	     st = ping_iter_next(&pi, NULL))
+		nnis += 1;
+
+	return nnis;
+}
+
 /*
  * Build a peer from incoming data.
  *
@@ -2976,10 +2991,14 @@ static int lnet_peer_merge_data(struct lnet_peer *lp,
 {
 	struct lnet_peer_net *lpn;
 	struct lnet_peer_ni *lpni;
-	lnet_nid_t *curnis = NULL;
-	struct lnet_ni_status *addnis = NULL;
-	lnet_nid_t *delnis = NULL;
+	struct lnet_nid *curnis = NULL;
+	struct lnet_ni_large_status *addnis = NULL;
+	struct lnet_nid *delnis = NULL;
+	struct lnet_ping_iter pi;
 	struct lnet_nid nid;
+	u32 *stp;
+	struct lnet_nid primary = {};
+	bool want_large_primary;
 	unsigned int flags;
 	int ncurnis;
 	int naddnis;
@@ -3003,7 +3022,8 @@ static int lnet_peer_merge_data(struct lnet_peer *lp,
 		lp->lp_state &= ~LNET_PEER_ROUTER_ENABLED;
 	spin_unlock(&lp->lp_lock);
 
-	nnis = max_t(int, lp->lp_nnis, pbuf->pb_info.pi_nnis);
+	nnis = ping_info_count_entries(pbuf);
+	nnis = max_t(int, lp->lp_nnis, nnis);
 	curnis = kmalloc_array(nnis, sizeof(*curnis), GFP_NOFS);
 	addnis = kmalloc_array(nnis, sizeof(*addnis), GFP_NOFS);
 	delnis = kmalloc_array(nnis, sizeof(*delnis), GFP_NOFS);
@@ -3018,18 +3038,31 @@ static int lnet_peer_merge_data(struct lnet_peer *lp,
 	/* Construct the list of NIDs present in peer. */
 	lpni = NULL;
 	while ((lpni = lnet_get_next_peer_ni_locked(lp, NULL, lpni)) != NULL)
-		curnis[ncurnis++] = lnet_nid_to_nid4(&lpni->lpni_nid);
+		curnis[ncurnis++] = lpni->lpni_nid;
 
-	/*
-	 * Check for NIDs in pbuf not present in curnis[].
-	 * The loop starts at 1 to skip the loopback NID.
+	/* Check for NIDs in pbuf not present in curnis[].
+	 * Skip the first, which is loop-back.  Take second as
+	 * primary, unless a large primary is found.
 	 */
-	for (i = 1; i < pbuf->pb_info.pi_nnis; i++) {
+	ping_iter_first(&pi, pbuf, NULL);
+	stp = ping_iter_next(&pi, &nid);
+	if (stp)
+		primary = nid;
+	want_large_primary = (pbuf->pb_info.pi_features &
+			      LNET_PING_FEAT_PRIMARY_LARGE);
+	for (; stp; stp = ping_iter_next(&pi, &nid)) {
 		for (j = 0; j < ncurnis; j++)
-			if (pbuf->pb_info.pi_ni[i].ns_nid == curnis[j])
+			if (nid_same(&nid, &curnis[j]))
 				break;
-		if (j == ncurnis)
-			addnis[naddnis++] = pbuf->pb_info.pi_ni[i];
+		if (j == ncurnis) {
+			addnis[naddnis].ns_nid = nid;
+			addnis[naddnis].ns_status = *stp;
+			naddnis += 1;
+		}
+		if (want_large_primary && nid.nid_size) {
+			primary = nid;
+			want_large_primary = false;
+		}
 	}
 	/*
 	 * Check for NIDs in curnis[] not present in pbuf.
@@ -3039,25 +3072,24 @@ static int lnet_peer_merge_data(struct lnet_peer *lp,
 	 * present in curnis[] then this peer is for this node.
 	 */
 	for (i = 0; i < ncurnis; i++) {
-		if (curnis[i] == LNET_NID_LO_0)
+		if (nid_is_lo0(&curnis[i]))
 			continue;
-		for (j = 1; j < pbuf->pb_info.pi_nnis; j++) {
-			if (curnis[i] == pbuf->pb_info.pi_ni[j].ns_nid) {
+		ping_iter_first(&pi, pbuf, NULL);
+		while ((stp = ping_iter_next(&pi, &nid)) != NULL) {
+			if (nid_same(&curnis[i], &nid)) {
 				/* update the information we cache for the
 				 * peer with the latest information we
 				 * received
 				 */
-				lnet_nid4_to_nid(curnis[i], &nid);
-				lpni = lnet_peer_ni_find_locked(&nid);
+				lpni = lnet_peer_ni_find_locked(&curnis[i]);
 				if (lpni) {
-					lpni->lpni_ns_status =
-						pbuf->pb_info.pi_ni[j].ns_status;
+					lpni->lpni_ns_status = *stp;
 					lnet_peer_ni_decref_locked(lpni);
 				}
 				break;
 			}
 		}
-		if (j == pbuf->pb_info.pi_nnis)
+		if (!stp)
 			delnis[ndelnis++] = curnis[i];
 	}
 
@@ -3070,16 +3102,15 @@ static int lnet_peer_merge_data(struct lnet_peer *lp,
 		goto out;
 
 	for (i = 0; i < naddnis; i++) {
-		lnet_nid4_to_nid(addnis[i].ns_nid, &nid);
-		rc = lnet_peer_add_nid(lp, &nid, flags);
+		rc = lnet_peer_add_nid(lp, &addnis[i].ns_nid, flags);
 		if (rc) {
 			CERROR("Error adding NID %s to peer %s: %d\n",
-			       libcfs_nid2str(addnis[i].ns_nid),
+			       libcfs_nidstr(&addnis[i].ns_nid),
 			       libcfs_nidstr(&lp->lp_primary_nid), rc);
 			if (rc == -ENOMEM)
 				goto out;
 		}
-		lpni = lnet_peer_ni_find_locked(&nid);
+		lpni = lnet_peer_ni_find_locked(&addnis[i].ns_nid);
 		if (lpni) {
 			lpni->lpni_ns_status = addnis[i].ns_status;
 			lnet_peer_ni_decref_locked(lpni);
@@ -3092,13 +3123,12 @@ static int lnet_peer_merge_data(struct lnet_peer *lp,
 		 * being told that the router changed its primary_nid
 		 * then it's okay to delete it.
 		 */
-		lnet_nid4_to_nid(delnis[i], &nid);
 		if (lp->lp_rtr_refcount > 0)
 			flags |= LNET_PEER_RTR_NI_FORCE_DEL;
-		rc = lnet_peer_del_nid(lp, &nid, flags);
+		rc = lnet_peer_del_nid(lp, &delnis[i], flags);
 		if (rc) {
 			CERROR("Error deleting NID %s from peer %s: %d\n",
-			       libcfs_nid2str(delnis[i]),
+			       libcfs_nidstr(&delnis[i]),
 			       libcfs_nidstr(&lp->lp_primary_nid), rc);
 			if (rc == -ENOMEM)
 				goto out;
-- 
2.27.0

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
