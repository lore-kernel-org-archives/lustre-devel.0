From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Sep 2019 14:56:14 -0400
Subject: [lustre-devel] [PATCH 115/151] lnet: safe access in debug print
In-Reply-To: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1569869810-23848-116-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <ashehata@whamcloud.com>

Move debug print within the cpt lock to keep
peer access safe.

WC-bug-id: https://jira.whamcloud.com/browse/LU-9919
Lustre-commit: 7c9ffeac1b69 ("LU-9919 lnet: safe access in debug print")
Signed-off-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/28771
Reviewed-by: John L. Hammond <jhammond@whamcloud.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/lib-move.c | 9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

diff --git a/net/lnet/lnet/lib-move.c b/net/lnet/lnet/lib-move.c
index 202372d..eee4510a 100644
--- a/net/lnet/lnet/lib-move.c
+++ b/net/lnet/lnet/lib-move.c
@@ -1422,11 +1422,10 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 		msg->msg_rtr_nid_param = rtr_nid;
 		msg->msg_sending = 0;
 		list_add_tail(&msg->msg_list, &peer->lp_dc_pendq);
-		lnet_peer_ni_decref_locked(lpni);
-		lnet_net_unlock(cpt);
-
 		CDEBUG(D_NET, "%s pending discovery\n",
 		       libcfs_nid2str(peer->lp_primary_nid));
+		lnet_peer_ni_decref_locked(lpni);
+		lnet_net_unlock(cpt);
 
 		return LNET_DC_WAIT;
 	}
@@ -1560,10 +1559,10 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 				best_lpni->lpni_net->net_id, cpt);
 			/* If there is no best_ni we don't have a route */
 			if (!best_ni) {
-				lnet_net_unlock(cpt);
 				CERROR("no path to %s from net %s\n",
 				       libcfs_nid2str(best_lpni->lpni_nid),
 				       libcfs_net2str(best_lpni->lpni_net->net_id));
+				lnet_net_unlock(cpt);
 				return -EHOSTUNREACH;
 			}
 			lpni = list_first_entry(&peer_net->lpn_peer_nis,
@@ -1718,9 +1717,9 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 		 * move onto the next peer_ni in the peer
 		 */
 		if (!best_gw) {
-			lnet_net_unlock(cpt);
 			LCONSOLE_WARN("No route to peer from %s\n",
 				      libcfs_nid2str(best_ni->ni_nid));
+			lnet_net_unlock(cpt);
 			return -EHOSTUNREACH;
 		}
 
-- 
1.8.3.1
