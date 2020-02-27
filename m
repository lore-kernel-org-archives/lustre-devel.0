From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:11:27 -0500
Subject: [lustre-devel] [PATCH 219/622] lnet: use right rtr address
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-220-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Alexey Lyashkov <c17817@cray.com>

use a sender router to avoid credits distribution problem.
Sender is preferable rtr now.

Cray-bug-id: LUS-6490
WC-bug-id: https://jira.whamcloud.com/browse/LU-11413
Lustre-commit: 3f4520608130 ("LU-11413 lnet: use right rtr address")
Signed-off-by: Alexey Lyashkov <c17817@cray.com>
Reviewed-on: https://review.whamcloud.com/34031
Reviewed-by: Chris Horn <hornc@cray.com>
Reviewed-by: Olaf Weber <olaf.weber@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/lib-move.c | 2 +-
 net/lnet/lnet/lib-msg.c  | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/lnet/lnet/lib-move.c b/net/lnet/lnet/lib-move.c
index f5548eb..468de06 100644
--- a/net/lnet/lnet/lib-move.c
+++ b/net/lnet/lnet/lib-move.c
@@ -3558,7 +3558,7 @@ void lnet_monitor_thr_stop(void)
 	lnet_ni_recv(ni, msg->msg_private, NULL, 0, 0, 0, 0);
 	msg->msg_receiving = 0;
 
-	rc = lnet_send(ni->ni_nid, msg, LNET_NID_ANY);
+	rc = lnet_send(ni->ni_nid, msg, msg->msg_from);
 	if (rc < 0) {
 		/* didn't get as far as lnet_ni_send() */
 		CERROR("%s: Unable to send REPLY for GET from %s: %d\n",
diff --git a/net/lnet/lnet/lib-msg.c b/net/lnet/lnet/lib-msg.c
index af0675e..0738bf7 100644
--- a/net/lnet/lnet/lib-msg.c
+++ b/net/lnet/lnet/lib-msg.c
@@ -401,7 +401,7 @@
 		 * NB: we probably want to use NID of msg::msg_from as 3rd
 		 * parameter (router NID) if it's routed message
 		 */
-		rc = lnet_send(msg->msg_ev.target.nid, msg, LNET_NID_ANY);
+		rc = lnet_send(msg->msg_ev.target.nid, msg, msg->msg_from);
 
 		lnet_net_lock(cpt);
 		/*
-- 
1.8.3.1
