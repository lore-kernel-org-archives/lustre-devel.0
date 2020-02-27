From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:17:10 -0500
Subject: [lustre-devel] [PATCH 562/622] lnet: use list_move where
 appropriate.
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-563-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: NeilBrown <neilb@suse.com>

There are several places in lustre where "list_del" (or occasionally
"list_del_init") is followed by "list_add" or "list_add_tail" which
moves the object to a different list.
These can be combined into "list_move" or "list_move_tail".

WC-bug-id: https://jira.whamcloud.com/browse/LU-12678
Lustre-commit: 590089790fee ("LU-12678 lnet: use list_move where appropriate.")
Signed-off-by: NeilBrown <neilb@suse.com>
Reviewed-on: https://review.whamcloud.com/36339
Reviewed-by: Neil Brown <neilb@suse.de>
Reviewed-by: Shaun Tancheff <stancheff@cray.com>
Reviewed-by: Petros Koutoupis <pkoutoupis@cray.com>
Reviewed-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/klnds/o2iblnd/o2iblnd.c       | 10 ++++------
 net/lnet/klnds/o2iblnd/o2iblnd_cb.c    |  6 ++----
 net/lnet/klnds/socklnd/socklnd.c       |  3 +--
 net/lnet/klnds/socklnd/socklnd_cb.c    |  3 +--
 net/lnet/klnds/socklnd/socklnd_proto.c |  3 +--
 net/lnet/lnet/config.c                 |  3 +--
 net/lnet/lnet/lib-move.c               |  9 +++------
 net/lnet/selftest/console.c            |  6 ++----
 8 files changed, 15 insertions(+), 28 deletions(-)

diff --git a/net/lnet/klnds/o2iblnd/o2iblnd.c b/net/lnet/klnds/o2iblnd/o2iblnd.c
index 04e121b..37d8235 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd.c
+++ b/net/lnet/klnds/o2iblnd/o2iblnd.c
@@ -1565,11 +1565,10 @@ static void kiblnd_fail_fmr_poolset(struct kib_fmr_poolset *fps,
 					       struct kib_fmr_pool,
 					       fpo_list)) != NULL) {
 		fpo->fpo_failed = 1;
-		list_del(&fpo->fpo_list);
 		if (!fpo->fpo_map_count)
-			list_add(&fpo->fpo_list, zombies);
+			list_move(&fpo->fpo_list, zombies);
 		else
-			list_add(&fpo->fpo_list, &fps->fps_failed_pool_list);
+			list_move(&fpo->fpo_list, &fps->fps_failed_pool_list);
 	}
 
 	spin_unlock(&fps->fps_lock);
@@ -1887,11 +1886,10 @@ static void kiblnd_fail_poolset(struct kib_poolset *ps, struct list_head *zombie
 					      struct kib_pool,
 					      po_list)) == NULL) {
 		po->po_failed = 1;
-		list_del(&po->po_list);
 		if (!po->po_allocated)
-			list_add(&po->po_list, zombies);
+			list_move(&po->po_list, zombies);
 		else
-			list_add(&po->po_list, &ps->ps_failed_pool_list);
+			list_move(&po->po_list, &ps->ps_failed_pool_list);
 	}
 	spin_unlock(&ps->ps_lock);
 }
diff --git a/net/lnet/klnds/o2iblnd/o2iblnd_cb.c b/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
index fcd9db2..f769a45 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -986,8 +986,7 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 	       (tx = list_first_entry_or_null(
 		       &conn->ibc_tx_queue_rsrvd,
 		       struct kib_tx, tx_list)) != NULL) {
-		list_del(&tx->tx_list);
-		list_add_tail(&tx->tx_list, &conn->ibc_tx_queue);
+		list_move_tail(&tx->tx_list, &conn->ibc_tx_queue);
 		conn->ibc_reserved_credits--;
 	}
 
@@ -2118,8 +2117,7 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
 		 */
 		if (!tx->tx_sending) {
 			tx->tx_queued = 0;
-			list_del(&tx->tx_list);
-			list_add(&tx->tx_list, &zombies);
+			list_move(&tx->tx_list, &zombies);
 		}
 	}
 
diff --git a/net/lnet/klnds/socklnd/socklnd.c b/net/lnet/klnds/socklnd/socklnd.c
index 1d0bedb..593c205 100644
--- a/net/lnet/klnds/socklnd/socklnd.c
+++ b/net/lnet/klnds/socklnd/socklnd.c
@@ -1537,8 +1537,7 @@ struct ksock_peer_ni *
 
 		tx->tx_msg.ksm_zc_cookies[0] = 0;
 		tx->tx_zc_aborted = 1; /* mark it as not-acked */
-		list_del(&tx->tx_zc_list);
-		list_add(&tx->tx_zc_list, &zlist);
+		list_move(&tx->tx_zc_list, &zlist);
 	}
 
 	spin_unlock(&peer_ni->ksnp_lock);
diff --git a/net/lnet/klnds/socklnd/socklnd_cb.c b/net/lnet/klnds/socklnd/socklnd_cb.c
index 2b93331..996b231 100644
--- a/net/lnet/klnds/socklnd/socklnd_cb.c
+++ b/net/lnet/klnds/socklnd/socklnd_cb.c
@@ -2312,8 +2312,7 @@ void ksocknal_write_callback(struct ksock_conn *conn)
 
 		tx->tx_hstatus = LNET_MSG_STATUS_LOCAL_TIMEOUT;
 
-		list_del(&tx->tx_list);
-		list_add_tail(&tx->tx_list, &stale_txs);
+		list_move_tail(&tx->tx_list, &stale_txs);
 	}
 
 	write_unlock_bh(&ksocknal_data.ksnd_global_lock);
diff --git a/net/lnet/klnds/socklnd/socklnd_proto.c b/net/lnet/klnds/socklnd/socklnd_proto.c
index c6ea302..887ed2d 100644
--- a/net/lnet/klnds/socklnd/socklnd_proto.c
+++ b/net/lnet/klnds/socklnd/socklnd_proto.c
@@ -437,8 +437,7 @@
 		if (c == cookie1 || c == cookie2 ||
 		    (cookie1 < c && c < cookie2)) {
 			tx->tx_msg.ksm_zc_cookies[0] = 0;
-			list_del(&tx->tx_zc_list);
-			list_add(&tx->tx_zc_list, &zlist);
+			list_move(&tx->tx_zc_list, &zlist);
 
 			if (!--count)
 				break;
diff --git a/net/lnet/lnet/config.c b/net/lnet/lnet/config.c
index f521b0b..8994882 100644
--- a/net/lnet/lnet/config.c
+++ b/net/lnet/lnet/config.c
@@ -1533,8 +1533,7 @@ struct lnet_ni *
 		list_for_each_safe(t, t2, &current_nets) {
 			tb = list_entry(t, struct lnet_text_buf, ltb_list);
 
-			list_del(&tb->ltb_list);
-			list_add_tail(&tb->ltb_list, &matched_nets);
+			list_move_tail(&tb->ltb_list, &matched_nets);
 
 			len += snprintf(networks + len, sizeof(networks) - len,
 					"%s%s", !len ? "" : ",",
diff --git a/net/lnet/lnet/lib-move.c b/net/lnet/lnet/lib-move.c
index 6a2833c..da73009 100644
--- a/net/lnet/lnet/lib-move.c
+++ b/net/lnet/lnet/lib-move.c
@@ -195,8 +195,7 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 		if (!tp->tp_threshold ||    /* needs culling anyway */
 		    nid == LNET_NID_ANY ||       /* removing all entries */
 		    tp->tp_nid == nid) {	  /* matched this one */
-			list_del(&tp->tp_list);
-			list_add(&tp->tp_list, &cull);
+			list_move(&tp->tp_list, &cull);
 		}
 	}
 
@@ -236,8 +235,7 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 				 * since we may be at interrupt priority on
 				 * incoming messages.
 				 */
-				list_del(&tp->tp_list);
-				list_add(&tp->tp_list, &cull);
+				list_move(&tp->tp_list, &cull);
 			}
 			continue;
 		}
@@ -251,8 +249,7 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 				if (outgoing &&
 				    !tp->tp_threshold) {
 					/* see above */
-					list_del(&tp->tp_list);
-					list_add(&tp->tp_list, &cull);
+					list_move(&tp->tp_list, &cull);
 				}
 			}
 			break;
diff --git a/net/lnet/selftest/console.c b/net/lnet/selftest/console.c
index abc342c..9f32c1f 100644
--- a/net/lnet/selftest/console.c
+++ b/net/lnet/selftest/console.c
@@ -316,12 +316,10 @@ static void lstcon_group_ndlink_release(struct lstcon_group *,
 	unsigned int idx = LNET_NIDADDR(ndl->ndl_node->nd_id.nid) %
 					LST_NODE_HASHSIZE;
 
-	list_del(&ndl->ndl_hlink);
-	list_del(&ndl->ndl_link);
 	old->grp_nnode--;
 
-	list_add_tail(&ndl->ndl_hlink, &new->grp_ndl_hash[idx]);
-	list_add_tail(&ndl->ndl_link, &new->grp_ndl_list);
+	list_move_tail(&ndl->ndl_hlink, &new->grp_ndl_hash[idx]);
+	list_move_tail(&ndl->ndl_link, &new->grp_ndl_list);
 	new->grp_nnode++;
 }
 
-- 
1.8.3.1
