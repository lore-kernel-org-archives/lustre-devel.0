From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:13:06 -0500
Subject: [lustre-devel] [PATCH 318/622] lnet: handle remote health error
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-319-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <ashehata@whamcloud.com>

When a peer is dead set the health status to REMOTE_DROPPED
in order to handle health properly for the peer.
When dropping a routed message set REMOTE_ERROR. Routed messages
are dropped when the routing feature is turned off which could
be considered a configuration error if it happens in the middle
of traffic. Therefore, it's better to flag this issue at this
point without resending the message.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12344
Lustre-commit: b45e3d96fc4d ("LU-12344 lnet: handle remote health error")
Signed-off-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/34967
Reviewed-by: Olaf Weber <olaf.weber@hpe.com>
Reviewed-by: Chris Horn <hornc@cray.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/lib-move.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/net/lnet/lnet/lib-move.c b/net/lnet/lnet/lib-move.c
index 7c135c4..8eeb5ec 100644
--- a/net/lnet/lnet/lib-move.c
+++ b/net/lnet/lnet/lib-move.c
@@ -770,7 +770,7 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 
 		CNETERR("Dropping message for %s: peer not alive\n",
 			libcfs_id2str(msg->msg_target));
-		msg->msg_health_status = LNET_MSG_STATUS_LOCAL_DROPPED;
+		msg->msg_health_status = LNET_MSG_STATUS_REMOTE_DROPPED;
 		if (do_send)
 			lnet_finalize(msg, -EHOSTUNREACH);
 
@@ -786,6 +786,9 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 			libcfs_id2str(msg->msg_target));
 		if (do_send) {
 			msg->msg_no_resend = true;
+			CDEBUG(D_NET,
+			       "msg %p to %s canceled and will not be resent\n",
+			       msg, libcfs_id2str(msg->msg_target));
 			lnet_finalize(msg, -ECANCELED);
 		}
 
@@ -1065,6 +1068,7 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 			     0, 0, 0, msg->msg_hdr.payload_length);
 		list_del_init(&msg->msg_list);
 		msg->msg_no_resend = true;
+		msg->msg_health_status = LNET_MSG_STATUS_REMOTE_ERROR;
 		lnet_finalize(msg, -ECANCELED);
 	}
 
-- 
1.8.3.1
