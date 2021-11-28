Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 093B7C433EF
	for <lustre-devel@archiver.kernel.org>; Sun, 28 Nov 2021 23:28:24 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 9266B21C90A;
	Sun, 28 Nov 2021 15:28:14 -0800 (PST)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 5C7B6200EB1
 for <lustre-devel@lists.lustre.org>; Sun, 28 Nov 2021 15:27:59 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 8A2CE240;
 Sun, 28 Nov 2021 18:27:56 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 78E06C1AC9; Sun, 28 Nov 2021 18:27:56 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 28 Nov 2021 18:27:36 -0500
Message-Id: <1638142074-5945-2-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1638142074-5945-1-git-send-email-jsimmons@infradead.org>
References: <1638142074-5945-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 01/19] lnet: fix delay rule crash
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
Cc: Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

The following crash was captured in testing:

LNetError: 25912:0:(net_fault.c:520:delay_rule_decref()) ASSERTION( list_empty(&rule->dl_sched_link) ) failed:
LNetError: 25912:0:(net_fault.c:520:delay_rule_decref()) LBUG
Pid: 25912, comm: lnet_dd 5.7.0-rc7+ #1 SMP PREEMPT Fri Aug 20 16:17:11 EDT 2021
Call Trace:
libcfs_call_trace+0x62/0x80 [libcfs]
lbug_with_loc+0x41/0xa0 [libcfs]
delay_rule_decref+0x6e/0xe0 [lnet]
lnet_delay_rule_check+0x65/0x110 [lnet]
lnet_delay_rule_daemon+0x76/0x120 [lnet]

The fix is revert the list changes in lnet_delay_rule_check().

Fixes: da4bdd3701 ("lustre: use list_first_entry() in lnet/lnet subdirectory.")
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/net_fault.c | 16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff --git a/net/lnet/lnet/net_fault.c b/net/lnet/lnet/net_fault.c
index 06366df..02fc1ae 100644
--- a/net/lnet/lnet/net_fault.c
+++ b/net/lnet/lnet/net_fault.c
@@ -744,15 +744,15 @@ struct delay_daemon_data {
 			break;
 
 		spin_lock_bh(&delay_dd.dd_lock);
-		rule = list_first_entry_or_null(&delay_dd.dd_sched_rules,
-						struct lnet_delay_rule,
-						dl_sched_link);
-		if (!rule)
-			list_del_init(&rule->dl_sched_link);
-		spin_unlock_bh(&delay_dd.dd_lock);
-
-		if (!rule)
+		if (list_empty(&delay_dd.dd_sched_rules)) {
+			spin_unlock_bh(&delay_dd.dd_lock);
 			break;
+		}
+
+		rule = list_entry(delay_dd.dd_sched_rules.next,
+				  struct lnet_delay_rule, dl_sched_link);
+		list_del_init(&rule->dl_sched_link);
+		spin_unlock_bh(&delay_dd.dd_lock);
 
 		delayed_msg_check(rule, false, &msgs);
 		delay_rule_decref(rule); /* -1 for delay_dd.dd_sched_rules */
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
