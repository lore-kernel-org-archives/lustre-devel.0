Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 731B8C05027
	for <lustre-devel@archiver.kernel.org>; Mon, 23 Jan 2023 23:06:48 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4P15Gb1d2Fz1yFN;
	Mon, 23 Jan 2023 15:02:31 -0800 (PST)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4P15F00sk2z1xJL
 for <lustre-devel@lists.lustre.org>; Mon, 23 Jan 2023 15:01:08 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 272836C8;
 Mon, 23 Jan 2023 18:00:58 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 1F06F58995; Mon, 23 Jan 2023 18:00:58 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon, 23 Jan 2023 18:00:17 -0500
Message-Id: <1674514855-15399-5-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1674514855-15399-1-git-send-email-jsimmons@infradead.org>
References: <1674514855-15399-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 04/42] lnet: Drop LNet message if deadline
 exceeded
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

The LNet message deadline is set when a message is committed for
sending. A message can be queued while waiting for send credit(s)
after it has been committed. Thus, it is possible for a message
deadline to be exceeded while on the queue. We should check for this
when posting messages to LND layer.

HPE-bug-id: LUS-11333
WC-bug-id: https://jira.whamcloud.com/browse/LU-16303
Lustre-commit: 52db11cdceef0851b ("LU-16303 lnet: Drop LNet message if deadline exceeded")
Signed-off-by: Chris Horn <chris.horn@hpe.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/49078
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: Frank Sehr <fsehr@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/lib-move.c | 57 +++++++++++++++++++++++++++-------------
 net/lnet/lnet/lib-msg.c  |  2 +-
 2 files changed, 40 insertions(+), 19 deletions(-)

diff --git a/net/lnet/lnet/lib-move.c b/net/lnet/lnet/lib-move.c
index 225accaf5d08..f602492ee75f 100644
--- a/net/lnet/lnet/lib-move.c
+++ b/net/lnet/lnet/lib-move.c
@@ -572,41 +572,52 @@ lnet_ni_eager_recv(struct lnet_ni *ni, struct lnet_msg *msg)
 	return rc;
 }
 
-/* returns true if this message should be dropped */
-static bool
+/* Returns:
+ *  -ETIMEDOUT if the message deadline has been exceeded
+ *  -EHOSTUNREACH if the peer is down
+ *  0 if this message should not be dropped
+ */
+static int
 lnet_check_message_drop(struct lnet_ni *ni, struct lnet_peer_ni *lpni,
 			struct lnet_msg *msg)
 {
+	/* Drop message if we've exceeded the message deadline */
+	if (ktime_after(ktime_get(), msg->msg_deadline))
+		return -ETIMEDOUT;
+
 	if (msg->msg_target.pid & LNET_PID_USERFLAG)
-		return false;
+		return 0;
 
 	if (!lnet_peer_aliveness_enabled(lpni))
-		return false;
+		return 0;
 
 	/* If we're resending a message, let's attempt to send it even if
 	 * the peer is down to fulfill our resend quota on the message
 	 */
 	if (msg->msg_retry_count > 0)
-		return false;
+		return 0;
 
-	/* try and send recovery messages irregardless */
+	/* try and send recovery messages regardless */
 	if (msg->msg_recovery)
-		return false;
+		return 0;
 
 	/* always send any responses */
 	if (lnet_msg_is_response(msg))
-		return false;
+		return 0;
 
 	/* always send non-routed messages */
 	if (!msg->msg_routing)
-		return false;
+		return 0;
 
 	/* assume peer_ni is alive as long as we're within the configured
 	 * peer timeout
 	 */
-	return ktime_get_seconds() >=
-		(lpni->lpni_last_alive +
-		 lpni->lpni_net->net_tunables.lct_peer_timeout);
+	if (ktime_get_seconds() >=
+	    (lpni->lpni_last_alive +
+	     lpni->lpni_net->net_tunables.lct_peer_timeout))
+		return -EHOSTUNREACH;
+
+	return 0;
 }
 
 /**
@@ -628,6 +639,7 @@ lnet_post_send_locked(struct lnet_msg *msg, int do_send)
 	struct lnet_ni *ni = msg->msg_txni;
 	int cpt = msg->msg_tx_cpt;
 	struct lnet_tx_queue *tq = ni->ni_tx_queues[cpt];
+	int rc;
 
 	/* non-lnet_send() callers have checked before */
 	LASSERT(!do_send || msg->msg_tx_delayed);
@@ -639,7 +651,8 @@ lnet_post_send_locked(struct lnet_msg *msg, int do_send)
 		LASSERT(!nid_same(&lp->lpni_nid, &the_lnet.ln_loni->ni_nid));
 
 	/* NB 'lp' is always the next hop */
-	if (lnet_check_message_drop(ni, lp, msg)) {
+	rc = lnet_check_message_drop(ni, lp, msg);
+	if (rc) {
 		the_lnet.ln_counters[cpt]->lct_common.lcc_drop_count++;
 		the_lnet.ln_counters[cpt]->lct_common.lcc_drop_length +=
 			msg->msg_len;
@@ -653,14 +666,22 @@ lnet_post_send_locked(struct lnet_msg *msg, int do_send)
 					msg->msg_type,
 					LNET_STATS_TYPE_DROP);
 
-		CNETERR("Dropping message for %s: peer not alive\n",
-			libcfs_idstr(&msg->msg_target));
-		msg->msg_health_status = LNET_MSG_STATUS_REMOTE_DROPPED;
+		if (rc == -EHOSTUNREACH) {
+			CNETERR("Dropping message for %s: peer not alive\n",
+				libcfs_idstr(&msg->msg_target));
+			msg->msg_health_status = LNET_MSG_STATUS_REMOTE_DROPPED;
+		} else {
+			CNETERR("Dropping message for %s: exceeded message deadline\n",
+				libcfs_idstr(&msg->msg_target));
+			msg->msg_health_status =
+				LNET_MSG_STATUS_NETWORK_TIMEOUT;
+		}
+
 		if (do_send)
-			lnet_finalize(msg, -EHOSTUNREACH);
+			lnet_finalize(msg, rc);
 
 		lnet_net_lock(cpt);
-		return -EHOSTUNREACH;
+		return rc;
 	}
 
 	if (msg->msg_md &&
diff --git a/net/lnet/lnet/lib-msg.c b/net/lnet/lnet/lib-msg.c
index 898d8670aedf..82d117dc6b61 100644
--- a/net/lnet/lnet/lib-msg.c
+++ b/net/lnet/lnet/lib-msg.c
@@ -779,7 +779,7 @@ lnet_health_check(struct lnet_msg *msg)
 		lo = true;
 
 	if (hstatus != LNET_MSG_STATUS_OK &&
-	    ktime_compare(ktime_get(), msg->msg_deadline) >= 0)
+	    ktime_after(ktime_get(), msg->msg_deadline))
 		return -1;
 
 	/* always prefer txni/txpeer if they message is committed for both
-- 
2.27.0

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
