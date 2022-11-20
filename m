Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 94B2DC4332F
	for <lustre-devel@archiver.kernel.org>; Sun, 20 Nov 2022 14:41:29 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4NFXnT0zZDz1y6P;
	Sun, 20 Nov 2022 06:23:41 -0800 (PST)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4NFXnC6qf3z2278
 for <lustre-devel@lists.lustre.org>; Sun, 20 Nov 2022 06:23:27 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id EF2C11009356;
 Sun, 20 Nov 2022 09:17:09 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id EB19EE8B8B; Sun, 20 Nov 2022 09:17:09 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 20 Nov 2022 09:17:04 -0500
Message-Id: <1668953828-10909-19-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1668953828-10909-1-git-send-email-jsimmons@infradead.org>
References: <1668953828-10909-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 18/22] lnet: extend lnet_is_nid_in_ping_info()
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

lnet_is_nid_in_ping_info() now checks the ping_info for both
nid4 and larger nids.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10391
Lustre-commit: 56bcfbf22d91b96c3 ("LU-10391 lnet: extend lnet_is_nid_in_ping_info()")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/44629
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Reviewed-by: Frank Sehr <fsehr@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/lib-lnet.h |  9 ++++++
 net/lnet/lnet/peer.c          | 71 +++++++++++++++++++++++++++++++++++++------
 2 files changed, 70 insertions(+), 10 deletions(-)

diff --git a/include/linux/lnet/lib-lnet.h b/include/linux/lnet/lib-lnet.h
index 13ce2bf..7ce6cff 100644
--- a/include/linux/lnet/lib-lnet.h
+++ b/include/linux/lnet/lib-lnet.h
@@ -886,6 +886,15 @@ static inline void lnet_ping_buffer_decref(struct lnet_ping_buffer *pbuf)
 	}
 }
 
+struct lnet_ping_iter {
+	struct lnet_ping_info	*pinfo;
+	void			*pos, *end;
+};
+
+u32 *ping_iter_first(struct lnet_ping_iter *pi, struct lnet_ping_buffer *pbuf,
+		     struct lnet_nid *nid);
+u32 *ping_iter_next(struct lnet_ping_iter *pi, struct lnet_nid *nid);
+
 static inline int lnet_push_target_resize_needed(void)
 {
 	return the_lnet.ln_push_target->pb_nbytes < the_lnet.ln_push_target_nbytes;
diff --git a/net/lnet/lnet/peer.c b/net/lnet/lnet/peer.c
index 35b135e..b33d6ac 100644
--- a/net/lnet/lnet/peer.c
+++ b/net/lnet/lnet/peer.c
@@ -2875,6 +2875,56 @@ static void lnet_discovery_event_handler(struct lnet_event *event)
 	lnet_net_unlock(LNET_LOCK_EX);
 }
 
+u32 *ping_iter_first(struct lnet_ping_iter *pi,
+		     struct lnet_ping_buffer *pbuf,
+		     struct lnet_nid *nid)
+{
+	pi->pinfo = &pbuf->pb_info;
+	pi->pos = &pbuf->pb_info.pi_ni;
+	pi->end = (void *)pi->pinfo +
+		  min_t(int, pbuf->pb_nbytes,
+			lnet_ping_info_size(pi->pinfo));
+	/* lnet_ping_info_validiate ensures there will be one
+	 * lnet_ni_status at the start
+	 */
+	if (nid)
+		lnet_nid4_to_nid(pbuf->pb_info.pi_ni[0].ns_nid, nid);
+	return &pbuf->pb_info.pi_ni[0].ns_status;
+}
+
+u32 *ping_iter_next(struct lnet_ping_iter *pi, struct lnet_nid *nid)
+{
+	int off = offsetof(struct lnet_ping_info, pi_ni[pi->pinfo->pi_nnis]);
+
+	if (pi->pos < ((void *)pi->pinfo + off)) {
+		struct lnet_ni_status *ns = pi->pos;
+
+		pi->pos = ns + 1;
+		if (pi->pos > pi->end)
+			return NULL;
+		if (nid)
+			lnet_nid4_to_nid(ns->ns_nid, nid);
+		return &ns->ns_status;
+	}
+
+	while (pi->pinfo->pi_features & LNET_PING_FEAT_LARGE_ADDR) {
+		struct lnet_ni_large_status *lns = pi->pos;
+
+		if (pi->pos + 8 > pi->end)
+			/* Not safe to examine next */
+			return NULL;
+		pi->pos = lnet_ping_sts_next(lns);
+		if (pi->pos > pi->end)
+			return NULL;
+		if (NID_BYTES(&lns->ns_nid) > sizeof(struct lnet_nid))
+			continue;
+		if (nid)
+			*nid = lns->ns_nid;
+		return &lns->ns_status;
+	}
+	return NULL;
+}
+
 /*
  * Build a peer from incoming data.
  *
@@ -3140,16 +3190,18 @@ static int lnet_peer_merge_data(struct lnet_peer *lp,
 	return 0;
 }
 
-static bool lnet_is_nid_in_ping_info(lnet_nid_t nid,
-				     struct lnet_ping_info *pinfo)
+static bool lnet_is_nid_in_ping_info(struct lnet_nid *nid,
+				     struct lnet_ping_buffer *pbuf)
 {
-	int i;
-
-	for (i = 0; i < pinfo->pi_nnis; i++) {
-		if (pinfo->pi_ni[i].ns_nid == nid)
+	struct lnet_ping_iter pi;
+	struct lnet_nid pnid;
+	u32 *st;
+
+	for (st = ping_iter_first(&pi, pbuf, &pnid);
+	     st;
+	     st = ping_iter_next(&pi, &pnid))
+		if (nid_same(nid, &pnid))
 			return true;
-	}
-
 	return false;
 }
 
@@ -3308,8 +3360,7 @@ static int lnet_peer_data_present(struct lnet_peer *lp)
 	 * recorded in that peer.
 	 */
 	} else if (nid_same(&lp->lp_primary_nid, &nid) ||
-		   (lnet_is_nid_in_ping_info(lnet_nid_to_nid4(&lp->lp_primary_nid),
-					     &pbuf->pb_info) &&
+		   (lnet_is_nid_in_ping_info(&lp->lp_primary_nid, pbuf) &&
 		    lnet_is_discovery_disabled(lp))) {
 		rc = lnet_peer_merge_data(lp, pbuf);
 	} else {
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
