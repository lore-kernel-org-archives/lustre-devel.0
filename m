From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:13:32 -0500
Subject: [lustre-devel] [PATCH 344/622] lnet: consider
 alive_router_check_interval
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-345-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <ashehata@whamcloud.com>

Consider router_check_interval when waking up the monitor thread,
to make sure you wakeup the monitor thread at the earliest possible
time.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11300
Lustre-commit: 434456256f30 ("LU-11300 lnet: consider alive_router_check_interval")
Signed-off-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/33298
Reviewed-by: Olaf Weber <olaf.weber@hpe.com>
Reviewed-by: Sebastien Buisson <sbuisson@ddn.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/lib-move.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/lnet/lnet/lib-move.c b/net/lnet/lnet/lib-move.c
index 054ae48..90b4e3f 100644
--- a/net/lnet/lnet/lib-move.c
+++ b/net/lnet/lnet/lib-move.c
@@ -3142,7 +3142,8 @@ struct lnet_mt_event_info {
 		 * is waking up unnecessarily.
 		 */
 		interval = min(lnet_recovery_interval,
-			       lnet_transaction_timeout / 2);
+			       min((unsigned int)alive_router_check_interval,
+				   lnet_transaction_timeout / 2));
 		wait_event_interruptible_timeout(the_lnet.ln_mt_waitq,
 						 false, HZ * interval);
 	}
-- 
1.8.3.1
