Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 02016C433F5
	for <lustre-devel@archiver.kernel.org>; Tue, 19 Apr 2022 00:31:28 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 715B44274B3;
	Mon, 18 Apr 2022 17:31:15 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id A1F87425525
 for <lustre-devel@lists.lustre.org>; Mon, 18 Apr 2022 17:31:08 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 322B11005C8B;
 Mon, 18 Apr 2022 20:31:06 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 2853CDABE8; Mon, 18 Apr 2022 20:31:06 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon, 18 Apr 2022 20:31:02 -0400
Message-Id: <1650328264-8763-6-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1650328264-8763-1-git-send-email-jsimmons@infradead.org>
References: <1650328264-8763-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 5/7] lnet: only update gateway NI status on
 discovery
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
Cc: Chris Horn <chris.horn@hpe.com>, Amir Shehata <ashehata@whamcloud.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Chris Horn <chris.horn@hpe.com>

Move the NI status from DOWN to UP only when receiving
a discovery PING. The discovery PING should be the only
message which should update the NI status since it's used
as the gateway NI keep alive mechanism.

This is done to avoid the following scenario:

The gateway itself can push its updates to the peers which
have removed it from its routing table. The peers would
respond to the PUSH with an ACK, the ACK will bring the
gateway's NI status to up. Therefore other peers which have
avoid_asym_router_failure=1 will have their route status
remain up even though the symmetrical route is gone.

Note: there is no way for the gateway to differentiate between
a keep alive discovery and a manually triggered discovery or ping.
However, this a narrow case which will not be handled.

net_last_alive converted to use ktime_get_seconds() instead of
ktime_get_real_seconds() since the NTP adjustment is not needed.

WC-bug-id: https://jira.whamcloud.com/browse/LU-13714
Lustre-commit: 3e3f70eb1ec95f32d ("LU-13714 lnet: only update gateway NI status on discovery")
Signed-off-by: Amir Shehata <ashehata@whamcloud.com>
Signed-off-by: Chris Horn <chris.horn@hpe.com>
Reviewed-on: https://review.whamcloud.com/39176
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: Cyril Bordage <cbordage@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/config.c      |  2 +-
 net/lnet/lnet/lib-move.c    | 16 ++++++++++++----
 net/lnet/lnet/router.c      |  2 +-
 net/lnet/lnet/router_proc.c |  2 +-
 4 files changed, 15 insertions(+), 7 deletions(-)

diff --git a/net/lnet/lnet/config.c b/net/lnet/lnet/config.c
index f499c91..da3d20e 100644
--- a/net/lnet/lnet/config.c
+++ b/net/lnet/lnet/config.c
@@ -350,7 +350,7 @@ struct lnet_net *
 	spin_lock_init(&net->net_lock);
 
 	net->net_id = net_id;
-	net->net_last_alive = ktime_get_real_seconds();
+	net->net_last_alive = ktime_get_seconds();
 
 	net->net_sel_priority = LNET_MAX_SELECTION_PRIORITY;
 
diff --git a/net/lnet/lnet/lib-move.c b/net/lnet/lnet/lib-move.c
index 3ad13d0..0b3986e 100644
--- a/net/lnet/lnet/lib-move.c
+++ b/net/lnet/lnet/lib-move.c
@@ -4250,6 +4250,7 @@ void lnet_monitor_thr_stop(void)
 	u32 type;
 	int rc = 0;
 	int cpt;
+	time64_t now = ktime_get_seconds();
 
 	LASSERT(!in_interrupt());
 
@@ -4301,11 +4302,18 @@ void lnet_monitor_thr_stop(void)
 		return -EPROTO;
 	}
 
-	if (the_lnet.ln_routing &&
-	    ni->ni_net->net_last_alive != ktime_get_real_seconds()) {
+	/* Only update net_last_alive for incoming GETs on the reserved portal
+	 * (i.e. incoming lnet/discovery pings).
+	 * This avoids situations where the router's own traffic results in NI
+	 * status changes
+	 */
+	if (the_lnet.ln_routing && type == LNET_MSG_GET &&
+	    hdr->msg.get.ptl_index == LNET_RESERVED_PORTAL &&
+	    !lnet_islocalnid(&src_nid) &&
+	    ni->ni_net->net_last_alive != now) {
 		lnet_ni_lock(ni);
 		spin_lock(&ni->ni_net->net_lock);
-		ni->ni_net->net_last_alive = ktime_get_real_seconds();
+		ni->ni_net->net_last_alive = now;
 		spin_unlock(&ni->ni_net->net_lock);
 		push = lnet_ni_set_status_locked(ni, LNET_NI_STATUS_UP);
 		lnet_ni_unlock(ni);
@@ -4480,7 +4488,7 @@ void lnet_monitor_thr_stop(void)
 		}
 	}
 
-	lpni->lpni_last_alive = ktime_get_seconds();
+	lpni->lpni_last_alive = now;
 
 	msg->msg_rxpeer = lpni;
 	msg->msg_rxni = ni;
diff --git a/net/lnet/lnet/router.c b/net/lnet/lnet/router.c
index beded3e..60ae15d 100644
--- a/net/lnet/lnet/router.c
+++ b/net/lnet/lnet/router.c
@@ -1044,7 +1044,7 @@ int lnet_get_rtr_pool_cfg(int cpt, struct lnet_ioctl_pool_cfg *pool_cfg)
 
 	timeout = router_ping_timeout + alive_router_check_interval;
 
-	now = ktime_get_real_seconds();
+	now = ktime_get_seconds();
 	list_for_each_entry(net, &the_lnet.ln_nets, net_list) {
 		if (net->net_lnd->lnd_type == LOLND)
 			continue;
diff --git a/net/lnet/lnet/router_proc.c b/net/lnet/lnet/router_proc.c
index a53d6fa..f231da1 100644
--- a/net/lnet/lnet/router_proc.c
+++ b/net/lnet/lnet/router_proc.c
@@ -663,7 +663,7 @@ static int proc_lnet_nis(struct ctl_table *table, int write,
 		if (ni) {
 			struct lnet_tx_queue *tq;
 			char *stat;
-			time64_t now = ktime_get_real_seconds();
+			time64_t now = ktime_get_seconds();
 			time64_t last_alive = -1;
 			int i;
 			int j;
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
