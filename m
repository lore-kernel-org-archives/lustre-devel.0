From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:15:00 -0500
Subject: [lustre-devel] [PATCH 432/622] lnet: handle unlink before send
 completes
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-433-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <ashehata@whamcloud.com>

If LNetMDUnlink() is called on an md with md->md_refcount > 0 then
the eq callback isn't called.
There is a scenario where the response times out before the send
completes. So we have a refcount on the MD. The Unlink callback gets
dropped on the floor. Send completes, but because we've already timed
out, the REPLY for the GET is dropped. Now we're left with a peer
that is in the following state:
LNET_PEER_MULTI_RAIL
LNET_PEER_DISCOVERING
LNET_PEER_PING_SENT
But no more events are coming to it, and the discovery never
completes.

This scenario can get RPCs stuck as well if the response times out
before the send completes.

The solution is to set the event status to -ETIMEDOUT to inform
the send event handler that it should not expect a reply

WC-bug-id: https://jira.whamcloud.com/browse/LU-10931
Lustre-commit: d8fc5c23fe54 ("LU-10931 lnet: handle unlink before send completes")
Signed-off-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/35444
Reviewed-by: Chris Horn <hornc@cray.com>
Reviewed-by: Alexandr Boyko <c17825@cray.com>
Reviewed-by: Olaf Weber <olaf.weber@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/lib-msg.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/net/lnet/lnet/lib-msg.c b/net/lnet/lnet/lib-msg.c
index 805d5b9..0d6c363 100644
--- a/net/lnet/lnet/lib-msg.c
+++ b/net/lnet/lnet/lib-msg.c
@@ -820,7 +820,12 @@
 
 	unlink = lnet_md_unlinkable(md);
 	if (md->md_eq) {
-		msg->msg_ev.status = status;
+		if ((md->md_flags & LNET_MD_FLAG_ABORTED) && !status) {
+			msg->msg_ev.status = -ETIMEDOUT;
+			CDEBUG(D_NET, "md 0x%p already unlinked\n", md);
+		} else {
+			msg->msg_ev.status = status;
+		}
 		msg->msg_ev.unlinked = unlink;
 		lnet_eq_enqueue_event(md->md_eq, &msg->msg_ev);
 	}
-- 
1.8.3.1
