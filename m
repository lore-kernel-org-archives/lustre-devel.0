From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:13:04 -0500
Subject: [lustre-devel] [PATCH 316/622] lnet: recovery event handling broken
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-317-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <ashehata@whamcloud.com>

Don't increment health on unlink event.
If a SEND fails an unlink will follow so no need to do any
special processing on SEND event. If SEND succeeds then we
wait for the reply.
When queuing a message on the NI recovery queue only do so
if the MT thread is still running.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12080
Lustre-commit: 5409e620e025 ("LU-12080 lnet: recovery event handling broken")
Signed-off-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/34445
Reviewed-by: Olaf Weber <olaf.weber@hpe.com>
Reviewed-by: Sebastien Buisson <sbuisson@ddn.com>
Reviewed-by: Chris Horn <hornc@cray.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/lib-move.c | 9 +++++----
 net/lnet/lnet/lib-msg.c  | 5 +++++
 2 files changed, 10 insertions(+), 4 deletions(-)

diff --git a/net/lnet/lnet/lib-move.c b/net/lnet/lnet/lib-move.c
index 809d2b6..a6df9ba 100644
--- a/net/lnet/lnet/lib-move.c
+++ b/net/lnet/lnet/lib-move.c
@@ -3197,7 +3197,7 @@ struct lnet_mt_event_info {
 
 static void
 lnet_handle_recovery_reply(struct lnet_mt_event_info *ev_info,
-			   int status)
+			   int status, bool unlink_event)
 {
 	lnet_nid_t nid = ev_info->mt_nid;
 
@@ -3228,7 +3228,8 @@ struct lnet_mt_event_info {
 		 * carry forward too much information.
 		 * In the peer case, it'll naturally be incremented
 		 */
-		lnet_inc_healthv(&ni->ni_healthv);
+		if (!unlink_event)
+			lnet_inc_healthv(&ni->ni_healthv);
 	} else {
 		struct lnet_peer_ni *lpni;
 		int cpt;
@@ -3273,14 +3274,14 @@ struct lnet_mt_event_info {
 		       libcfs_nid2str(ev_info->mt_nid));
 		/* fall-through */
 	case LNET_EVENT_REPLY:
-		lnet_handle_recovery_reply(ev_info, event->status);
+		lnet_handle_recovery_reply(ev_info, event->status,
+					   event->type == LNET_EVENT_UNLINK);
 		break;
 	case LNET_EVENT_SEND:
 		CDEBUG(D_NET, "%s recovery message sent %s:%d\n",
 		       libcfs_nid2str(ev_info->mt_nid),
 		       (event->status) ? "unsuccessfully" :
 		       "successfully", event->status);
-		lnet_handle_recovery_reply(ev_info, event->status);
 		break;
 	default:
 		CERROR("Unexpected event: %d\n", event->type);
diff --git a/net/lnet/lnet/lib-msg.c b/net/lnet/lnet/lib-msg.c
index 0738bf7..146e23c 100644
--- a/net/lnet/lnet/lib-msg.c
+++ b/net/lnet/lnet/lib-msg.c
@@ -521,6 +521,11 @@
 		return;
 
 	lnet_net_lock(0);
+	/* the mt could've shutdown and cleaned up the queues */
+	if (the_lnet.ln_mt_state != LNET_MT_STATE_RUNNING) {
+		lnet_net_unlock(0);
+		return;
+	}
 	lnet_handle_remote_failure_locked(lpni);
 	lnet_net_unlock(0);
 }
-- 
1.8.3.1
