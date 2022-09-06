Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 9E139ECAAD3
	for <lustre-devel@archiver.kernel.org>; Tue,  6 Sep 2022 01:56:29 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4MM7lx2Lwyz1y52;
	Mon,  5 Sep 2022 18:56:29 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4MM7lF58GJz1y6h
 for <lustre-devel@lists.lustre.org>; Mon,  5 Sep 2022 18:55:53 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id D916D100B030;
 Mon,  5 Sep 2022 21:55:39 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id D5109589A0; Mon,  5 Sep 2022 21:55:39 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon,  5 Sep 2022 21:55:30 -0400
Message-Id: <1662429337-18737-18-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1662429337-18737-1-git-send-email-jsimmons@infradead.org>
References: <1662429337-18737-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 17/24] lnet: LNet peer aliveness broken
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

The peer health feature used on LNet routers is intended to detect if
a peer is dead or alive by keeping track of the last time it received
a message from the peer. If the last alive value is outside of a
configurable interval then the peer is considered dead and the router
will drop messages to that peer rather than attempt to send to it.

This feature no longer works as intended because even if the
last alive value is outside the interval the router will still
consider the peer NI to be alive if the health value of the NI and
the cached status both indicate the peer NI is alive.

So even if a router has not received any messages from the client in
days, as long as the router thinks the peer's interfaces are healthy
then it will consider the peer alive. This doesn't make any sense as
peers are supposed to regularly ping the router, and if they don't do
so then they should not be considered alive.

Fix the issue by relying solely on the last alive value to determine
peer aliveness. Do not consider the health value or cached status
when determining whether to drop the message.

lnet_peer_alive_locked() has single caller that only checks whether
zero was returned. We can convert lnet_peer_alive_locked() to return
bool rather than int.

Rename lnet_peer_alive_locked() to lnet_check_message_drop() to
better reflect the purpose of the function. The return value is
inverted to reflect the name change.

WC-bug-id: https://jira.whamcloud.com/browse/LU-15595
Lustre-commit: caf6095ade66f70d4 ("LU-15595 lnet: LNet peer aliveness broken")
Signed-off-by: Chris Horn <chris.horn@hpe.com>
Reviewed-on: https://review.whamcloud.com/46623
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: Cyril Bordage <cbordage@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/lib-move.c | 51 +++++++++++++++---------------------------------
 1 file changed, 16 insertions(+), 35 deletions(-)

diff --git a/net/lnet/lnet/lib-move.c b/net/lnet/lnet/lib-move.c
index 3b20a1b7..ec8be8f 100644
--- a/net/lnet/lnet/lib-move.c
+++ b/net/lnet/lnet/lib-move.c
@@ -572,55 +572,37 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 	return rc;
 }
 
+/* returns true if this message should be dropped */
 static bool
-lnet_is_peer_deadline_passed(struct lnet_peer_ni *lpni, time64_t now)
+lnet_check_message_drop(struct lnet_ni *ni, struct lnet_peer_ni *lpni,
+			struct lnet_msg *msg)
 {
-	time64_t deadline;
-
-	deadline = lpni->lpni_last_alive +
-		   lpni->lpni_net->net_tunables.lct_peer_timeout;
-
-	/* assume peer_ni is alive as long as we're within the configured
-	 * peer timeout
-	 */
-	if (deadline > now)
+	if (msg->msg_target.pid & LNET_PID_USERFLAG)
 		return false;
 
-	return true;
-}
-
-/*
- * NB: returns 1 when alive, 0 when dead, negative when error;
- *     may drop the lnet_net_lock
- */
-static int
-lnet_peer_alive_locked(struct lnet_ni *ni, struct lnet_peer_ni *lpni,
-		       struct lnet_msg *msg)
-{
-	time64_t now = ktime_get_seconds();
-
 	if (!lnet_peer_aliveness_enabled(lpni))
-		return -ENODEV;
+		return false;
 
-	/*
-	 * If we're resending a message, let's attempt to send it even if
+	/* If we're resending a message, let's attempt to send it even if
 	 * the peer is down to fulfill our resend quota on the message
 	 */
 	if (msg->msg_retry_count > 0)
-		return 1;
+		return false;
 
 	/* try and send recovery messages irregardless */
 	if (msg->msg_recovery)
-		return 1;
+		return false;
 
 	/* always send any responses */
 	if (lnet_msg_is_response(msg))
-		return 1;
-
-	if (!lnet_is_peer_deadline_passed(lpni, now))
-		return true;
+		return false;
 
-	return lnet_is_peer_ni_alive(lpni);
+	/* assume peer_ni is alive as long as we're within the configured
+	 * peer timeout
+	 */
+	return ktime_get_seconds() >=
+		(lpni->lpni_last_alive +
+		 lpni->lpni_net->net_tunables.lct_peer_timeout);
 }
 
 /**
@@ -653,8 +635,7 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 		LASSERT(!nid_same(&lp->lpni_nid, &the_lnet.ln_loni->ni_nid));
 
 	/* NB 'lp' is always the next hop */
-	if (!(msg->msg_target.pid & LNET_PID_USERFLAG) &&
-	    !lnet_peer_alive_locked(ni, lp, msg)) {
+	if (lnet_check_message_drop(ni, lp, msg)) {
 		the_lnet.ln_counters[cpt]->lct_common.lcc_drop_count++;
 		the_lnet.ln_counters[cpt]->lct_common.lcc_drop_length +=
 			msg->msg_len;
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
