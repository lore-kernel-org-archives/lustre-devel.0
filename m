Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id ADA97C433EF
	for <lustre-devel@archiver.kernel.org>; Sun, 20 Mar 2022 13:32:42 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id C525D21FB81;
	Sun, 20 Mar 2022 06:32:00 -0700 (PDT)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 8AC6821CABE
 for <lustre-devel@lists.lustre.org>; Sun, 20 Mar 2022 06:31:21 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 90EDE1029;
 Sun, 20 Mar 2022 09:31:08 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 8E076D6A26; Sun, 20 Mar 2022 09:31:08 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 20 Mar 2022 09:30:59 -0400
Message-Id: <1647783064-20688-46-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1647783064-20688-1-git-send-email-jsimmons@infradead.org>
References: <1647783064-20688-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 45/50] lnet: Don't use pref NI for reserved
 portal
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
Cc: Chris Horn <chris.horn@hpe.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Chris Horn <chris.horn@hpe.com>

Don't use the preferred NI when sending traffic on the LNet reserved
portal. This allows local recovery pings to utilize any local NI as
source in the case where we do not have a multi-rail peer entry for
the local host. This is typically the case when MR is not being
configured statically (i.e. when discovery is being used for MR
configuration).

lnet_get_best_ni() was modified to include health values of the NIs
being compared in its debug output.

HPE-bug-id: LUS-10658
WC-bug-id: https://jira.whamcloud.com/browse/LU-15446
lustre-commit: a2815441381cb6cee ("LU-15446 lnet: Don't use pref NI for reserved portal")
Signed-off-by: Chris Horn <chris.horn@hpe.com>
Reviewed-on: https://review.whamcloud.com/46078
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: Andriy Skulysh <andriy.skulysh@hpe.com>
Reviewed-by: Alexey Lyashkov <alexey.lyashkov@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
---
 net/lnet/lnet/lib-move.c | 61 +++++++++++++++++++++++++++---------------------
 1 file changed, 34 insertions(+), 27 deletions(-)

diff --git a/net/lnet/lnet/lib-move.c b/net/lnet/lnet/lib-move.c
index 8a90822..3ad13d0 100644
--- a/net/lnet/lnet/lib-move.c
+++ b/net/lnet/lnet/lib-move.c
@@ -1516,13 +1516,13 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 
 		if (best_ni)
 			CDEBUG(D_NET,
-			       "compare ni %s [c:%d, d:%d, s:%d, p:%u, g:%u] with best_ni %s [c:%d, d:%d, s:%d, p:%u, g:%u]\n",
+			       "compare ni %s [c:%d, d:%d, s:%d, p:%u, g:%u, h:%d] with best_ni %s [c:%d, d:%d, s:%d, p:%u, g:%u, h:%d]\n",
 			       libcfs_nidstr(&ni->ni_nid), ni_credits, distance,
-			       ni->ni_seq, ni_sel_prio, ni_dev_prio,
+			       ni->ni_seq, ni_sel_prio, ni_dev_prio, ni_healthv,
 			       (best_ni) ? libcfs_nidstr(&best_ni->ni_nid)
 			       : "not selected", best_credits, shortest_distance,
 			       (best_ni) ? best_ni->ni_seq : 0,
-			       best_sel_prio, best_dev_prio);
+			       best_sel_prio, best_dev_prio, best_healthv);
 		else
 			goto select_ni;
 
@@ -1569,6 +1569,19 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 	return best_ni;
 }
 
+static bool
+lnet_reserved_msg(struct lnet_msg *msg)
+{
+	if (msg->msg_type == LNET_MSG_PUT) {
+		if (msg->msg_hdr.msg.put.ptl_index == LNET_RESERVED_PORTAL)
+			return true;
+	} else if (msg->msg_type == LNET_MSG_GET) {
+		if (msg->msg_hdr.msg.get.ptl_index == LNET_RESERVED_PORTAL)
+			return true;
+	}
+	return false;
+}
+
 /*
  * Traffic to the LNET_RESERVED_PORTAL may not trigger peer discovery,
  * because such traffic is required to perform discovery. We therefore
@@ -1580,14 +1593,7 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 static bool
 lnet_msg_discovery(struct lnet_msg *msg)
 {
-	if (msg->msg_type == LNET_MSG_PUT) {
-		if (msg->msg_hdr.msg.put.ptl_index != LNET_RESERVED_PORTAL)
-			return true;
-	} else if (msg->msg_type == LNET_MSG_GET) {
-		if (msg->msg_hdr.msg.get.ptl_index != LNET_RESERVED_PORTAL)
-			return true;
-	}
-	return false;
+	return !(lnet_reserved_msg(msg) || lnet_msg_is_response(msg));
 }
 
 #define SRC_SPEC	0x0001
@@ -2334,7 +2340,6 @@ struct lnet_ni *
 lnet_select_preferred_best_ni(struct lnet_send_data *sd)
 {
 	struct lnet_ni *best_ni = NULL;
-	struct lnet_peer_ni *best_lpni = sd->sd_best_lpni;
 
 	/* We must use a consistent source address when sending to a
 	 * non-MR peer. However, a non-MR peer can have multiple NIDs
@@ -2344,25 +2349,27 @@ struct lnet_ni *
 	 *
 	 * So we need to pick the NI the peer prefers for this
 	 * particular network.
+	 *
+	 * An exception is traffic on LNET_RESERVED_PORTAL. Internal LNet
+	 * traffic doesn't care which source NI is used, and we don't actually
+	 * want to restrict local recovery pings to a single source NI.
 	 */
+	if (!lnet_reserved_msg(sd->sd_msg))
+		best_ni = lnet_find_existing_preferred_best_ni(sd->sd_best_lpni,
+							       sd->sd_cpt);
 
-	best_ni = lnet_find_existing_preferred_best_ni(sd->sd_best_lpni,
-						       sd->sd_cpt);
+	if (!best_ni)
+		best_ni = lnet_find_best_ni_on_spec_net(NULL, sd->sd_peer,
+							sd->sd_best_lpni->lpni_peer_net,
+							sd->sd_msg,
+							sd->sd_md_cpt);
 
-	/* if best_ni is still not set just pick one */
+	/* If there is no best_ni we don't have a route */
 	if (!best_ni) {
-		best_ni =
-			lnet_find_best_ni_on_spec_net(NULL, sd->sd_peer,
-						      sd->sd_best_lpni->lpni_peer_net,
-						      sd->sd_msg,
-						      sd->sd_md_cpt);
-		/* If there is no best_ni we don't have a route */
-		if (!best_ni) {
-			CERROR("no path to %s from net %s\n",
-			       libcfs_nidstr(&best_lpni->lpni_nid),
-			       libcfs_net2str(best_lpni->lpni_net->net_id));
-			return -EHOSTUNREACH;
-		}
+		CERROR("no path to %s from net %s\n",
+		       libcfs_nidstr(&sd->sd_best_lpni->lpni_nid),
+		       libcfs_net2str(sd->sd_best_lpni->lpni_net->net_id));
+		return -EHOSTUNREACH;
 	}
 
 	sd->sd_best_ni = best_ni;
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
