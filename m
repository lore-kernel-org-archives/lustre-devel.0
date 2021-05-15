Return-Path: <SRS0=EXfh=KK=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.7 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6EA49C433B4
	for <lustre-devel@archiver.kernel.org>; Sat, 15 May 2021 13:06:43 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 26D45611C9
	for <lustre-devel@archiver.kernel.org>; Sat, 15 May 2021 13:06:43 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 26D45611C9
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 131FF21FB1C;
	Sat, 15 May 2021 06:06:29 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 0D81721CAD2
 for <lustre-devel@lists.lustre.org>; Sat, 15 May 2021 06:06:14 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 7860D100676E;
 Sat, 15 May 2021 09:06:12 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 6EA3193BCC; Sat, 15 May 2021 09:06:12 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sat, 15 May 2021 09:05:58 -0400
Message-Id: <1621083970-32463-2-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1621083970-32463-1-git-send-email-jsimmons@infradead.org>
References: <1621083970-32463-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 01/13] lnet: Allow delayed sends
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

The net_delay_add has some code related to delaying sends, but it
isn't fully implemented. Modify lnet_post_send_locked() to check
whether the message being sent matches a rule and should be delayed.

Fix some bugs with how the delay timers were set and checked.

HPE-bug-id: LUS-7651
WC-bug-id: https://jira.whamcloud.com/browse/LU-14627
Lustre-commit: ab14f3bc852e7081 ("LU-14627 lnet: Allow delayed sends")
Signed-off-by: Chris Horn <chris.horn@hpe.com>
Reviewed-on: https://review.whamcloud.com/43416
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/lib-lnet.h |  1 +
 net/lnet/lnet/lib-move.c      |  8 +++++++-
 net/lnet/lnet/net_fault.c     | 24 +++++++++++++++++++-----
 3 files changed, 27 insertions(+), 6 deletions(-)

diff --git a/include/linux/lnet/lib-lnet.h b/include/linux/lnet/lib-lnet.h
index 674f9d1..6b9e926 100644
--- a/include/linux/lnet/lib-lnet.h
+++ b/include/linux/lnet/lib-lnet.h
@@ -630,6 +630,7 @@ void lnet_recv(struct lnet_ni *ni, void *private, struct lnet_msg *msg,
 void lnet_ni_recv(struct lnet_ni *ni, void *private, struct lnet_msg *msg,
 		  int delayed, unsigned int offset,
 		  unsigned int mlen, unsigned int rlen);
+void lnet_ni_send(struct lnet_ni *ni, struct lnet_msg *msg);
 
 struct lnet_msg *lnet_create_reply_msg(struct lnet_ni *ni,
 				       struct lnet_msg *get_msg);
diff --git a/net/lnet/lnet/lib-move.c b/net/lnet/lnet/lib-move.c
index cb0943e..6d0637c 100644
--- a/net/lnet/lnet/lib-move.c
+++ b/net/lnet/lnet/lib-move.c
@@ -530,7 +530,7 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 	msg->msg_hdr.payload_length = cpu_to_le32(len);
 }
 
-static void
+void
 lnet_ni_send(struct lnet_ni *ni, struct lnet_msg *msg)
 {
 	void *priv = msg->msg_private;
@@ -733,6 +733,12 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 		}
 	}
 
+	if (unlikely(!list_empty(&the_lnet.ln_delay_rules)) &&
+	    lnet_delay_rule_match_locked(&msg->msg_hdr, msg)) {
+		msg->msg_tx_delayed = 1;
+		return LNET_CREDIT_WAIT;
+	}
+
 	/* unset the tx_delay flag as we're going to send it now */
 	msg->msg_tx_delayed = 0;
 
diff --git a/net/lnet/lnet/net_fault.c b/net/lnet/lnet/net_fault.c
index 515aa05..0d19da4 100644
--- a/net/lnet/lnet/net_fault.c
+++ b/net/lnet/lnet/net_fault.c
@@ -536,6 +536,7 @@ struct delay_daemon_data {
 {
 	struct lnet_fault_attr *attr = &rule->dl_attr;
 	bool delay;
+	time64_t now = ktime_get_seconds();
 
 	if (!lnet_fault_attr_match(attr, src, LNET_NID_ANY,
 				   dst, type, portal))
@@ -544,8 +545,6 @@ struct delay_daemon_data {
 	/* match this rule, check delay rate now */
 	spin_lock(&rule->dl_lock);
 	if (rule->dl_delay_time) { /* time based delay */
-		time64_t now = ktime_get_seconds();
-
 		rule->dl_stat.fs_count++;
 		delay = now >= rule->dl_delay_time;
 		if (delay) {
@@ -587,10 +586,11 @@ struct delay_daemon_data {
 	rule->dl_stat.u.delay.ls_delayed++;
 
 	list_add_tail(&msg->msg_list, &rule->dl_msg_list);
-	msg->msg_delay_send = ktime_get_seconds() + attr->u.delay.la_latency;
+	msg->msg_delay_send = now + attr->u.delay.la_latency;
 	if (rule->dl_msg_send == -1) {
 		rule->dl_msg_send = msg->msg_delay_send;
-		mod_timer(&rule->dl_timer, jiffies + rule->dl_msg_send * HZ);
+		mod_timer(&rule->dl_timer,
+			  jiffies + attr->u.delay.la_latency * HZ);
 	}
 
 	spin_unlock(&rule->dl_lock);
@@ -662,7 +662,8 @@ struct delay_daemon_data {
 		msg = list_first_entry(&rule->dl_msg_list,
 				       struct lnet_msg, msg_list);
 		rule->dl_msg_send = msg->msg_delay_send;
-		mod_timer(&rule->dl_timer, jiffies + rule->dl_msg_send * HZ);
+		mod_timer(&rule->dl_timer,
+			  jiffies + (msg->msg_delay_send - now) * HZ);
 	}
 	spin_unlock(&rule->dl_lock);
 }
@@ -678,6 +679,19 @@ struct delay_daemon_data {
 		int cpt;
 		int rc;
 
+		if (msg->msg_sending) {
+			/* Delayed send */
+			list_del_init(&msg->msg_list);
+			ni = msg->msg_txni;
+			CDEBUG(D_NET, "TRACE: msg %p %s -> %s : %s\n", msg,
+			       libcfs_nid2str(ni->ni_nid),
+			       libcfs_nid2str(msg->msg_txpeer->lpni_nid),
+			       lnet_msgtyp2str(msg->msg_type));
+			lnet_ni_send(ni, msg);
+			continue;
+		}
+
+		/* Delayed receive */
 		LASSERT(msg->msg_rxpeer);
 		LASSERT(msg->msg_rxni);
 
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
