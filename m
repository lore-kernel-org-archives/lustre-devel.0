Return-Path: <SRS0=FD7t=JM=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6D578C43461
	for <lustre-devel@archiver.kernel.org>; Thu, 15 Apr 2021 04:06:04 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 378A8613A9
	for <lustre-devel@archiver.kernel.org>; Thu, 15 Apr 2021 04:06:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 378A8613A9
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 6FAC532BF53;
	Wed, 14 Apr 2021 21:04:28 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id A176132F601
 for <lustre-devel@lists.lustre.org>; Wed, 14 Apr 2021 21:02:59 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id CC9E6100F375;
 Thu, 15 Apr 2021 00:02:45 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id CB64B9188E; Thu, 15 Apr 2021 00:02:45 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Thu, 15 Apr 2021 00:02:37 -0400
Message-Id: <1618459361-17909-46-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1618459361-17909-1-git-send-email-jsimmons@infradead.org>
References: <1618459361-17909-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 45/49] lnet: Recover peer NI w/exponential
 backoff interval
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

Perform LNet recovery pings of peer NIs with an exponential backoff
interval.
 - The interval is equal to 2^(number failed pings) up to a maximum
   of 900 seconds (15 minutes).
 - When a message is received the count of failed pings for the
   associated peer NI is reset to 0 so that recovery can happen more
   quickly.

HPE-bug-id: LUS-9109
WC-bug-id: https://jira.whamcloud.com/browse/LU-13569
Lustre-commit: 917553c537a8860 ("LU-13569 lnet: Recover peer NI w/exponential backoff interval")
Signed-off-by: Chris Horn <chris.horn@hpe.com>
Reviewed-on: https://review.whamcloud.com/39720
Reviewed-by: Neil Brown <neilb@suse.de>
Reviewed-by: Alexander Boyko <alexander.boyko@hpe.com>
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/lib-lnet.h  | 22 ++++++++++++++++++++++
 include/linux/lnet/lib-types.h |  6 ++++++
 net/lnet/lnet/lib-move.c       |  8 ++++++++
 net/lnet/lnet/lib-msg.c        |  6 +++++-
 net/lnet/lnet/peer.c           | 11 ++++++++++-
 5 files changed, 51 insertions(+), 2 deletions(-)

diff --git a/include/linux/lnet/lib-lnet.h b/include/linux/lnet/lib-lnet.h
index e30d0c4..8b369dd 100644
--- a/include/linux/lnet/lib-lnet.h
+++ b/include/linux/lnet/lib-lnet.h
@@ -910,6 +910,28 @@ int lnet_get_peer_ni_info(u32 peer_index, u64 *nid,
 	return false;
 }
 
+#define LNET_RECOVERY_INTERVAL_MAX 900
+static inline unsigned int
+lnet_get_next_recovery_ping(unsigned int ping_count, time64_t now)
+{
+	unsigned int interval;
+
+	/* 2^9 = 512, 2^10 = 1024 */
+	if (ping_count > 9)
+		interval = LNET_RECOVERY_INTERVAL_MAX;
+	else
+		interval = 1 << ping_count;
+
+	return now + interval;
+}
+
+static inline void
+lnet_peer_ni_set_next_ping(struct lnet_peer_ni *lpni, time64_t now)
+{
+	lpni->lpni_next_ping =
+		lnet_get_next_recovery_ping(lpni->lpni_ping_count, now);
+}
+
 /*
  * A peer NI is alive if it satisfies the following two conditions:
  *  1. peer NI health >= LNET_MAX_HEALTH_VALUE * router_sensitivity_percentage
diff --git a/include/linux/lnet/lib-types.h b/include/linux/lnet/lib-types.h
index cc451cf..af8f61e 100644
--- a/include/linux/lnet/lib-types.h
+++ b/include/linux/lnet/lib-types.h
@@ -573,6 +573,12 @@ struct lnet_peer_ni {
 	atomic_t		 lpni_healthv;
 	/* recovery ping mdh */
 	struct lnet_handle_md	 lpni_recovery_ping_mdh;
+	/* When to send the next recovery ping */
+	time64_t		 lpni_next_ping;
+	/* How many pings sent during current recovery period did not receive
+	 * a reply. NB: reset whenever _any_ message arrives from this peer NI
+	 */
+	unsigned int		 lpni_ping_count;
 	/* CPT this peer attached on */
 	int			 lpni_cpt;
 	/* state flags -- protected by lpni_lock */
diff --git a/net/lnet/lnet/lib-move.c b/net/lnet/lnet/lib-move.c
index bdcba54..ad1517d 100644
--- a/net/lnet/lnet/lib-move.c
+++ b/net/lnet/lnet/lib-move.c
@@ -3398,6 +3398,12 @@ struct lnet_mt_event_info {
 		}
 
 		spin_unlock(&lpni->lpni_lock);
+
+		if (now < lpni->lpni_next_ping) {
+			lnet_net_unlock(0);
+			continue;
+		}
+
 		lnet_net_unlock(0);
 
 		/* NOTE: we're racing with peer deletion from user space.
@@ -3446,6 +3452,8 @@ struct lnet_mt_event_info {
 				continue;
 			}
 
+			lpni->lpni_ping_count++;
+
 			lpni->lpni_recovery_ping_mdh = mdh;
 			lnet_peer_ni_add_to_recoveryq_locked(lpni,
 							     &processed_list,
diff --git a/net/lnet/lnet/lib-msg.c b/net/lnet/lnet/lib-msg.c
index 2e8fea7..0a4a317 100644
--- a/net/lnet/lnet/lib-msg.c
+++ b/net/lnet/lnet/lib-msg.c
@@ -863,8 +863,11 @@
 
 	switch (hstatus) {
 	case LNET_MSG_STATUS_OK:
-		/* increment the local ni health weather we successfully
+		/* increment the local ni health whether we successfully
 		 * received or sent a message on it.
+		 *
+		 * Ping counts are reset to 0 as appropriate to allow for
+		 * faster recovery.
 		 */
 		lnet_inc_healthv(&ni->ni_healthv, lnet_health_sensitivity);
 		/* It's possible msg_txpeer is NULL in the LOLND
@@ -875,6 +878,7 @@
 		 * as indication that the router is fully healthy.
 		 */
 		if (lpni && msg->msg_rx_committed) {
+			lpni->lpni_ping_count = 0;
 			/* If we're receiving a message from the router or
 			 * I'm a router, then set that lpni's health to
 			 * maximum so we can commence communication
diff --git a/net/lnet/lnet/peer.c b/net/lnet/lnet/peer.c
index f9af5da..15fcb5e 100644
--- a/net/lnet/lnet/peer.c
+++ b/net/lnet/lnet/peer.c
@@ -4006,14 +4006,23 @@ int lnet_get_peer_info(struct lnet_ioctl_peer_cfg *cfg, void __user *bulk)
 		CDEBUG(D_NET, "lpni %s aged out last alive %lld\n",
 		       libcfs_nid2str(lpni->lpni_nid),
 		       lpni->lpni_last_alive);
+		/* Reset the ping count so that if this peer NI is added back to
+		 * the recovery queue we will send the first ping right away.
+		 */
+		lpni->lpni_ping_count = 0;
 		return;
 	}
 
 	/* This peer NI is going on the recovery queue, so take a ref on it */
 	lnet_peer_ni_addref_locked(lpni);
 
-	CDEBUG(D_NET, "%s added to recovery queue. last alive: %lld health: %d\n",
+	lnet_peer_ni_set_next_ping(lpni, now);
+
+	CDEBUG(D_NET,
+	       "%s added to recovery queue. ping count: %u next ping: %lld last alive: %lld health: %d\n",
 	       libcfs_nid2str(lpni->lpni_nid),
+	       lpni->lpni_ping_count,
+	       lpni->lpni_next_ping,
 	       lpni->lpni_last_alive,
 	       atomic_read(&lpni->lpni_healthv));
 
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
