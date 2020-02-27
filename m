From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:13:09 -0500
Subject: [lustre-devel] [PATCH 321/622] lnet: detach response tracker
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-322-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <ashehata@whamcloud.com>

We need to unlink the response tracker from MDs even if the
corresponding message failed to send.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12201
Lustre-commit: 1bb91b966d15 ("LU-12201 lnet: detach response tracker")
Signed-off-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/34770
Reviewed-by: Olaf Weber <olaf.weber@hpe.com>
Reviewed-by: Sebastien Buisson <sbuisson@ddn.com>
Reviewed-by: Chris Horn <hornc@cray.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/lib-msg.c | 7 +------
 1 file changed, 1 insertion(+), 6 deletions(-)

diff --git a/net/lnet/lnet/lib-msg.c b/net/lnet/lnet/lib-msg.c
index 146e23c..a245942 100644
--- a/net/lnet/lnet/lib-msg.c
+++ b/net/lnet/lnet/lib-msg.c
@@ -771,12 +771,7 @@
 	}
 
 	if (unlink) {
-		/* if this is an ACK or a REPLY then make sure to remove the
-		 * response tracker.
-		 */
-		if (msg->msg_ev.type == LNET_EVENT_REPLY ||
-		    msg->msg_ev.type == LNET_EVENT_ACK)
-			lnet_detach_rsp_tracker(msg->msg_md, cpt);
+		lnet_detach_rsp_tracker(md, cpt);
 		lnet_md_unlink(md);
 	}
 
-- 
1.8.3.1
