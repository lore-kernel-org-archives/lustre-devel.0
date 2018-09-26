From: James Simmons <jsimmons@infradead.org>
Date: Tue, 25 Sep 2018 22:47:58 -0400
Subject: [lustre-devel] [PATCH 06/25] lustre: lnet: loopback NID in
 lnet_select_pathway()
In-Reply-To: <1537930097-11624-1-git-send-email-jsimmons@infradead.org>
References: <1537930097-11624-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1537930097-11624-7-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Olaf Weber <olaf.weber@hpe.com>

In lnet_select_pathway() sending to the loopback NID is handled
as a special case, because there are no credits involved. (The
loopback NID doesn't use credits, and therefore does not have
any credits. If a message goes through the credit-managing code
it therefore ends up waiting indefinitely for credits to become
available.)

The check whether we're sending over the loopback NID must be
done after we've completed choosing the NI to send over. In its
present location it only handles the case where the loopback
NID was explicitly passed in as the source NID.

(Lustre does not exercise this code path during normal operation,
the bug was encountered while testing code for the peer discovery
feature.)

Signed-off-by: Olaf Weber <olaf.weber@hpe.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-9119
Reviewed-on: https://review.whamcloud.com/26692
Reviewed-by: Doug Oucharek <dougso@me.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lnet/lnet/lib-move.c | 29 +++++++++++++++--------------
 1 file changed, 15 insertions(+), 14 deletions(-)

diff --git a/drivers/staging/lustre/lnet/lnet/lib-move.c b/drivers/staging/lustre/lnet/lnet/lib-move.c
index ea7e2c3..d533b8e 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-move.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-move.c
@@ -1374,20 +1374,6 @@
 		}
 	}
 
-	if (best_ni == the_lnet.ln_loni) {
-		/* No send credit hassles with LOLND */
-		lnet_ni_addref_locked(best_ni, cpt);
-		msg->msg_hdr.dest_nid = cpu_to_le64(best_ni->ni_nid);
-		if (!msg->msg_routing)
-			msg->msg_hdr.src_nid = cpu_to_le64(best_ni->ni_nid);
-		msg->msg_target.nid = best_ni->ni_nid;
-		lnet_msg_commit(msg, cpt);
-		msg->msg_txni = best_ni;
-		lnet_net_unlock(cpt);
-
-		return LNET_CREDIT_OK;
-	}
-
 	/*
 	 * if we already found a best_ni because src_nid is specified and
 	 * best_lpni because we are replying to a message then just send
@@ -1630,6 +1616,21 @@
 	}
 
 send:
+	/* Shortcut for loopback. */
+	if (best_ni == the_lnet.ln_loni) {
+		/* No send credit hassles with LOLND */
+		lnet_ni_addref_locked(best_ni, cpt);
+		msg->msg_hdr.dest_nid = cpu_to_le64(best_ni->ni_nid);
+		if (!msg->msg_routing)
+			msg->msg_hdr.src_nid = cpu_to_le64(best_ni->ni_nid);
+		msg->msg_target.nid = best_ni->ni_nid;
+		lnet_msg_commit(msg, cpt);
+		msg->msg_txni = best_ni;
+		lnet_net_unlock(cpt);
+
+		return LNET_CREDIT_OK;
+	}
+
 	routing = routing || routing2;
 
 	/*
-- 
1.8.3.1
