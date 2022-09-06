Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 2FA7EECAAA1
	for <lustre-devel@archiver.kernel.org>; Tue,  6 Sep 2022 01:56:20 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4MM7ll5t26z1y2M;
	Mon,  5 Sep 2022 18:56:19 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4MM7lG3P2Wz1y6h
 for <lustre-devel@lists.lustre.org>; Mon,  5 Sep 2022 18:55:54 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id DAB49100B031;
 Mon,  5 Sep 2022 21:55:39 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id D8C6137C; Mon,  5 Sep 2022 21:55:39 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon,  5 Sep 2022 21:55:31 -0400
Message-Id: <1662429337-18737-19-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1662429337-18737-1-git-send-email-jsimmons@infradead.org>
References: <1662429337-18737-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 18/24] lnet: Correct net selection for router
 ping
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
Cc: Chris Horn <chris.horn@hpe.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Chris Horn <chris.horn@hpe.com>

lnet_find_best_ni_on_local_net() contains logic for restricting
the NI selection to a net specified by lnet_peer::lp_disc_net_id. The
purpose of this is to ensure that LNet peers ping every interface on
a router at a regular interval as part of the LNet router health
feature. However, this logic is flawed because lnet_msg_discovery()
is used to determine whether the message being sent is a discovery
message, but that function actually determines whether a given message
can _trigger_ discovery.

Introduce a new function, lnet_msg_is_ping(), which determines whether
a given lnet_msg is a GET on the LNET_RESERVED_PORTAL.
Modify lnet_find_best_ni_on_local_net() to restrict NI selection to
lp_disc_net_id iff:
1. lp_disc_net_id is non-zero
2. The peer has the LNET_PEER_RTR_DISCOVERY flag set.
3. lnet_msg_is_ping() returns true

HPE-bug-id: LUS-11017
WC-bug-id: https://jira.whamcloud.com/browse/LU-15929
Lustre-commit: 2431e099b143a4c7e ("LU-15929 lnet: Correct net selection for router ping")
Signed-off-by: Chris Horn <chris.horn@hpe.com>
Reviewed-on: https://review.whamcloud.com/47527
Reviewed-by: Frank Sehr <fsehr@whamcloud.com>
Reviewed-by: Cyril Bordage <cbordage@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/lib-move.c | 25 +++++++++++++++++++++----
 1 file changed, 21 insertions(+), 4 deletions(-)

diff --git a/net/lnet/lnet/lib-move.c b/net/lnet/lnet/lib-move.c
index ec8be8f..3c9602e 100644
--- a/net/lnet/lnet/lib-move.c
+++ b/net/lnet/lnet/lib-move.c
@@ -1577,7 +1577,8 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 	return false;
 }
 
-/*
+/* Can the specified message trigger peer discovery?
+ *
  * Traffic to the LNET_RESERVED_PORTAL may not trigger peer discovery,
  * because such traffic is required to perform discovery. We therefore
  * exclude all GET and PUT on that portal. We also exclude all ACK and
@@ -1591,6 +1592,18 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 	return !(lnet_reserved_msg(msg) || lnet_msg_is_response(msg));
 }
 
+/* Is the specified message an LNet ping?
+ */
+static bool
+lnet_msg_is_ping(struct lnet_msg *msg)
+{
+	if (msg->msg_type == LNET_MSG_GET &&
+	    msg->msg_hdr.msg.get.ptl_index == LNET_RESERVED_PORTAL)
+		return true;
+
+	return false;
+}
+
 #define SRC_SPEC	0x0001
 #define SRC_ANY		0x0002
 #define LOCAL_DST	0x0004
@@ -2228,10 +2241,14 @@ struct lnet_ni *
 	u32 best_net_sel_prio = LNET_MAX_SELECTION_PRIORITY;
 	u32 net_sel_prio;
 
-	/* if this is a discovery message and lp_disc_net_id is
-	 * specified then use that net to send the discovery on.
+	/* If lp_disc_net_id is set, this peer is a router undergoing
+	 * discovery, and this message is an LNet ping, then this may be a
+	 * discovery message and we need to select an NI on the peer net
+	 * specified by lp_disc_net_id
 	 */
-	if (discovery && peer->lp_disc_net_id) {
+	if (peer->lp_disc_net_id &&
+	    (peer->lp_state & LNET_PEER_RTR_DISCOVERY) &&
+	    lnet_msg_is_ping(msg)) {
 		best_lpn = lnet_peer_get_net_locked(peer, peer->lp_disc_net_id);
 		if (best_lpn && lnet_get_net_locked(best_lpn->lpn_net_id))
 			goto select_best_ni;
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
