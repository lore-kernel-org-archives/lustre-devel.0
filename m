Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 8972BC4332F
	for <lustre-devel@archiver.kernel.org>; Sun, 20 Nov 2022 14:43:14 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4NFXpX0b4fz22Pg;
	Sun, 20 Nov 2022 06:24:36 -0800 (PST)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4NFXpL2trYz1yDb
 for <lustre-devel@lists.lustre.org>; Sun, 20 Nov 2022 06:24:26 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id F1A401009357;
 Sun, 20 Nov 2022 09:17:09 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id EE6CCE8B88; Sun, 20 Nov 2022 09:17:09 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 20 Nov 2022 09:17:05 -0500
Message-Id: <1668953828-10909-20-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1668953828-10909-1-git-send-email-jsimmons@infradead.org>
References: <1668953828-10909-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 19/22] lnet: find correct primary for peer
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

If the peer has a large-address for the primary, it can now be found.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10391
Lustre-commit: 022b46d887603f703 ("LU-10391 lnet: find correct primary for peer")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/44632
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: Frank Sehr <fsehr@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/peer.c | 41 ++++++++++++++++++++++++++++++++++-------
 1 file changed, 34 insertions(+), 7 deletions(-)

diff --git a/net/lnet/lnet/peer.c b/net/lnet/lnet/peer.c
index b33d6ac..a1305b6 100644
--- a/net/lnet/lnet/peer.c
+++ b/net/lnet/lnet/peer.c
@@ -2585,11 +2585,40 @@ static void lnet_peer_clear_discovery_error(struct lnet_peer *lp)
 	       libcfs_nidstr(&lp->lp_primary_nid), ev->status);
 }
 
+static bool find_primary(struct lnet_nid *nid,
+			 struct lnet_ping_buffer *pbuf)
+{
+	struct lnet_ping_info *pi = &pbuf->pb_info;
+	struct lnet_ping_iter piter;
+	u32 *stp;
+
+	if (pi->pi_features & LNET_PING_FEAT_PRIMARY_LARGE) {
+		/* First large nid is primary */
+		for (stp = ping_iter_first(&piter, pbuf, nid);
+		     stp;
+		     stp = ping_iter_next(&piter, nid)) {
+			if (nid_is_nid4(nid))
+				continue;
+			/* nid has already been copied in */
+			return true;
+		}
+		/* no large nids ... weird ... ignore the flag
+		 * and use first nid.
+		 */
+	}
+	/* pi_nids[1] is primary */
+	if (pi->pi_nnis < 2)
+		return false;
+	lnet_nid4_to_nid(pbuf->pb_info.pi_ni[1].ns_nid, nid);
+	return true;
+}
+
 /* Handle a Reply message. This is the reply to a Ping message. */
 static void
 lnet_discovery_event_reply(struct lnet_peer *lp, struct lnet_event *ev)
 {
 	struct lnet_ping_buffer *pbuf;
+	struct lnet_nid primary;
 	int infobytes;
 	int rc;
 	bool ping_feat_disc;
@@ -2731,9 +2760,8 @@ static void lnet_peer_clear_discovery_error(struct lnet_peer *lp)
 	 * available if the reply came from a Multi-Rail peer.
 	 */
 	if (pbuf->pb_info.pi_features & LNET_PING_FEAT_MULTI_RAIL &&
-	    pbuf->pb_info.pi_nnis > 1 &&
-	    lnet_nid_to_nid4(&lp->lp_primary_nid) ==
-	    pbuf->pb_info.pi_ni[1].ns_nid) {
+	    find_primary(&primary, pbuf) &&
+	    nid_same(&lp->lp_primary_nid, &primary)) {
 		if (LNET_PING_BUFFER_SEQNO(pbuf) < lp->lp_peer_seqno)
 			CDEBUG(D_NET,
 			       "peer %s: seq# got %u have %u. peer rebooted?\n",
@@ -3081,11 +3109,11 @@ static int lnet_peer_merge_data(struct lnet_peer *lp,
 	 * peer's lp_peer_nets list, and the peer NI for the primary NID should
 	 * be the first entry in its peer net's lpn_peer_nis list.
 	 */
-	lnet_nid4_to_nid(pbuf->pb_info.pi_ni[1].ns_nid, &nid);
+	find_primary(&nid, pbuf);
 	lpni = lnet_peer_ni_find_locked(&nid);
 	if (!lpni) {
 		CERROR("Internal error: Failed to lookup peer NI for primary NID: %s\n",
-		       libcfs_nid2str(pbuf->pb_info.pi_ni[1].ns_nid));
+		       libcfs_nidstr(&nid));
 		goto out;
 	}
 
@@ -3341,11 +3369,10 @@ static int lnet_peer_data_present(struct lnet_peer *lp)
 	 * primary NID to the correct value here. Moreover, this peer
 	 * can show up with only the loopback NID in the ping buffer.
 	 */
-	if (pbuf->pb_info.pi_nnis <= 1) {
+	if (!find_primary(&nid, pbuf)) {
 		lnet_ping_buffer_decref(pbuf);
 		goto out;
 	}
-	lnet_nid4_to_nid(pbuf->pb_info.pi_ni[1].ns_nid, &nid);
 	if (nid_is_lo0(&lp->lp_primary_nid)) {
 		rc = lnet_peer_set_primary_nid(lp, &nid, flags);
 		if (rc)
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
