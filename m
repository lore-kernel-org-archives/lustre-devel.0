From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:16:19 -0500
Subject: [lustre-devel] [PATCH 511/622] lnet: fix peer_ni selection
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-512-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <ashehata@whamcloud.com>

When selecting a peer-ni we must use the same peer NID
through all the messages which belong to the same RPC.
This is necessary in order to ensure we do the RDMA over
the optimal interface.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12893
Lustre-commit: 94ee26738884 ("LU-12893 lnet: fix peer_ni selection")
Signed-off-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/36552
Reviewed-by: Chris Horn <hornc@cray.com>
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradaed.org>
---
 net/lnet/lnet/lib-move.c | 17 +++++------------
 1 file changed, 5 insertions(+), 12 deletions(-)

diff --git a/net/lnet/lnet/lib-move.c b/net/lnet/lnet/lib-move.c
index 6da0be4..b8278ad 100644
--- a/net/lnet/lnet/lib-move.c
+++ b/net/lnet/lnet/lib-move.c
@@ -1710,8 +1710,11 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
  * Local Destination
  * MR Peer
  *
- * Run the selection algorithm on the peer NIs unless we're sending
- * a response, in this case just send to the destination
+ * Don't run the selection algorithm on the peer NIs. By specifying the
+ * local NID, we're also saying that we should always use the destination NID
+ * provided. This handles the case where we should be using the same
+ * destination NID for the all the messages which belong to the same RPC
+ * request.
  */
 static int
 lnet_handle_spec_local_mr_dst(struct lnet_send_data *sd)
@@ -1724,16 +1727,6 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 		return -EINVAL;
 	}
 
-	/* only run the selection algorithm to pick the peer_ni if we're
-	 * sending a GET or a PUT. Responses are sent to the same
-	 * destination NID provided.
-	 */
-	if (!(sd->sd_send_case & SND_RESP)) {
-		sd->sd_best_lpni =
-		  lnet_find_best_lpni_on_net(sd, sd->sd_peer,
-					     sd->sd_best_ni->ni_net->net_id);
-	}
-
 	if (sd->sd_best_lpni &&
 	    sd->sd_best_lpni->lpni_nid == the_lnet.ln_loni->ni_nid)
 		return lnet_handle_lo_send(sd);
-- 
1.8.3.1
