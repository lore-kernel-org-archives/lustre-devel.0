From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:17:18 -0500
Subject: [lustre-devel] [PATCH 570/622] lnet: Refactor
 lnet_find_best_lpni_on_net
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-571-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Chris Horn <hornc@cray.com>

Replace lnet_send_data argument.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12756
Lustre-commit: 80edb2ad72ba ("LU-12756 lnet: Refactor lnet_find_best_lpni_on_net")
Signed-off-by: Chris Horn <hornc@cray.com>
Reviewed-on: https://review.whamcloud.com/36534
Reviewed-by: Alexandr Boyko <c17825@cray.com>
Reviewed-by: Alexey Lyashkov <c17817@cray.com>
Reviewed-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/lib-move.c | 23 ++++++++++++-----------
 1 file changed, 12 insertions(+), 11 deletions(-)

diff --git a/net/lnet/lnet/lib-move.c b/net/lnet/lnet/lib-move.c
index 73f9d20..c8266f0 100644
--- a/net/lnet/lnet/lib-move.c
+++ b/net/lnet/lnet/lib-move.c
@@ -1247,8 +1247,8 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 
 /* Prerequisite: the best_ni should already be set in the sd */
 static inline struct lnet_peer_ni *
-lnet_find_best_lpni_on_net(struct lnet_send_data *sd, struct lnet_peer *peer,
-			   u32 net_id)
+lnet_find_best_lpni_on_net(struct lnet_ni *lni, lnet_nid_t dst_nid,
+			   struct lnet_peer *peer, u32 net_id)
 {
 	struct lnet_peer_net *peer_net;
 
@@ -1264,8 +1264,7 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 		return NULL;
 	}
 
-	return lnet_select_peer_ni(sd->sd_best_ni, sd->sd_dst_nid,
-				   peer, peer_net);
+	return lnet_select_peer_ni(lni, dst_nid, peer, peer_net);
 }
 
 static int
@@ -1278,13 +1277,12 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 	struct lnet_peer *lp2 = r2->lr_gateway;
 	struct lnet_peer_ni *lpni1;
 	struct lnet_peer_ni *lpni2;
-	struct lnet_send_data sd;
 	int rc;
 
-	sd.sd_best_ni = NULL;
-	sd.sd_dst_nid = LNET_NID_ANY;
-	lpni1 = lnet_find_best_lpni_on_net(&sd, lp1, r1->lr_lnet);
-	lpni2 = lnet_find_best_lpni_on_net(&sd, lp2, r2->lr_lnet);
+	lpni1 = lnet_find_best_lpni_on_net(NULL, LNET_NID_ANY, lp1,
+					   r1->lr_lnet);
+	lpni2 = lnet_find_best_lpni_on_net(NULL, LNET_NID_ANY, lp2,
+					   r2->lr_lnet);
 	LASSERT(lpni1 && lpni2);
 
 	if (r1->lr_priority < r2->lr_priority) {
@@ -1878,7 +1876,9 @@ struct lnet_ni *
 			return -EHOSTUNREACH;
 		}
 
-		sd->sd_best_lpni = lnet_find_best_lpni_on_net(sd, lp,
+		sd->sd_best_lpni = lnet_find_best_lpni_on_net(sd->sd_best_ni,
+							      sd->sd_dst_nid,
+							      lp,
 							      best_lpn->lpn_net_id);
 		if (!sd->sd_best_lpni) {
 			CERROR("peer %s down\n",
@@ -2191,7 +2191,8 @@ struct lnet_ni *
 					lnet_msg_discovery(sd->sd_msg));
 	if (sd->sd_best_ni) {
 		sd->sd_best_lpni =
-		  lnet_find_best_lpni_on_net(sd, sd->sd_peer,
+		  lnet_find_best_lpni_on_net(sd->sd_best_ni, sd->sd_dst_nid,
+					     sd->sd_peer,
 					     sd->sd_best_ni->ni_net->net_id);
 
 		/* if we're successful in selecting a peer_ni on the local
-- 
1.8.3.1
