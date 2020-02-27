From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:16:48 -0500
Subject: [lustre-devel] [PATCH 540/622] lnet: timers: correctly offset
 mod_timer.
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-541-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

During a high level code review of the lustre time code it was
discovered that some of the mod_timer() calles was missing
adding the current jiffies value to the timeout that converted
to jiffies from seconds. Add this proper offset.

Fixes: 5109c2502543 ("staging: lustre: lnet: move ping and delay injection to time64_t")

WC-bug-id: https://jira.whamcloud.com/browse/LU-12931
Lustre-commit: e150810faa5 ("LU-12931 timers: correctly offset mod_timer.")
Signed-off-by: James Simmons <jsimmons@infradead.org>
Reviewed-on: https://review.whamcloud.com/36688
Reviewed-by: Neil Brown <neilb@suse.de>
Reviewed-by: Alex Zhuravlev <bzzz@whamcloud.com>
Reviewed-by: Shaun Tancheff <stancheff@cray.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/net_fault.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/lnet/lnet/net_fault.c b/net/lnet/lnet/net_fault.c
index e43b1e1..8408e93 100644
--- a/net/lnet/lnet/net_fault.c
+++ b/net/lnet/lnet/net_fault.c
@@ -487,7 +487,7 @@ struct lnet_delay_rule {
 	/** baseline to caculate dl_delay_time */
 	time64_t		dl_time_base;
 	/** jiffies to send the next delayed message */
-	unsigned long		dl_msg_send;
+	time64_t		dl_msg_send;
 	/** delayed message list */
 	struct list_head	dl_msg_list;
 	/** statistic of delayed messages */
@@ -592,7 +592,7 @@ struct delay_daemon_data {
 	msg->msg_delay_send = ktime_get_seconds() + attr->u.delay.la_latency;
 	if (rule->dl_msg_send == -1) {
 		rule->dl_msg_send = msg->msg_delay_send;
-		mod_timer(&rule->dl_timer, rule->dl_msg_send);
+		mod_timer(&rule->dl_timer, jiffies + rule->dl_msg_send * HZ);
 	}
 
 	spin_unlock(&rule->dl_lock);
@@ -664,7 +664,7 @@ struct delay_daemon_data {
 		msg = list_first_entry(&rule->dl_msg_list,
 				       struct lnet_msg, msg_list);
 		rule->dl_msg_send = msg->msg_delay_send;
-		mod_timer(&rule->dl_timer, rule->dl_msg_send);
+		mod_timer(&rule->dl_timer, jiffies + rule->dl_msg_send * HZ);
 	}
 	spin_unlock(&rule->dl_lock);
 }
-- 
1.8.3.1
