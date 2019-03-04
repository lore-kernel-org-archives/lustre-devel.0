From: NeilBrown <neilb@suse.com>
Date: Mon, 04 Mar 2019 17:31:39 +1100
Subject: [lustre-devel] [PATCH 28/28] lustre: use list_move where
 appropriate.
In-Reply-To: <155168107971.31333.14345309795939467246.stgit@noble.brown>
References: <155168107971.31333.14345309795939467246.stgit@noble.brown>
Message-ID: <155168109908.31333.7931063184032585647.stgit@noble.brown>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

There are several places in lustre where "list_del" (or occasionally
"list_del_init") is followed by "list_add" or "list_add_tail" which
moves the object to a different list.
These can be combined into "list_move" or "list_move_tail".

Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c    |   10 ++++------
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c |    6 ++----
 .../staging/lustre/lnet/klnds/socklnd/socklnd.c    |    3 +--
 .../staging/lustre/lnet/klnds/socklnd/socklnd_cb.c |    3 +--
 .../lustre/lnet/klnds/socklnd/socklnd_proto.c      |    3 +--
 drivers/staging/lustre/lnet/lnet/config.c          |    3 +--
 drivers/staging/lustre/lnet/lnet/lib-move.c        |   16 ++++++----------
 drivers/staging/lustre/lnet/selftest/console.c     |    7 ++-----
 drivers/staging/lustre/lustre/ldlm/ldlm_lib.c      |    5 ++---
 drivers/staging/lustre/lustre/ldlm/ldlm_request.c  |    3 +--
 drivers/staging/lustre/lustre/ptlrpc/client.c      |   10 ++++------
 drivers/staging/lustre/lustre/ptlrpc/import.c      |    3 +--
 drivers/staging/lustre/lustre/ptlrpc/service.c     |   13 ++++---------
 13 files changed, 30 insertions(+), 55 deletions(-)

diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
index d67a197e718d..94388b406149 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
@@ -1555,11 +1555,10 @@ static void kiblnd_fail_fmr_poolset(struct kib_fmr_poolset *fps,
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
@@ -1877,11 +1876,10 @@ static void kiblnd_fail_poolset(struct kib_poolset *ps, struct list_head *zombie
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
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
index b9585f607463..3579d90df98d 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -961,8 +961,7 @@ kiblnd_check_sends_locked(struct kib_conn *conn)
 	       (tx = list_first_entry_or_null(
 		       &conn->ibc_tx_queue_rsrvd,
 		       struct kib_tx, tx_list)) != NULL) {
-		list_del(&tx->tx_list);
-		list_add_tail(&tx->tx_list, &conn->ibc_tx_queue);
+		list_move_tail(&tx->tx_list, &conn->ibc_tx_queue);
 		conn->ibc_reserved_credits--;
 	}
 
@@ -2051,8 +2050,7 @@ kiblnd_abort_txs(struct kib_conn *conn, struct list_head *txs)
 
 		if (!tx->tx_sending) {
 			tx->tx_queued = 0;
-			list_del(&tx->tx_list);
-			list_add(&tx->tx_list, &zombies);
+			list_move(&tx->tx_list, &zombies);
 		}
 	}
 
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
index 08feaf7ce33a..922ba76f5913 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
@@ -1560,8 +1560,7 @@ ksocknal_finalize_zcreq(struct ksock_conn *conn)
 
 		tx->tx_msg.ksm_zc_cookies[0] = 0;
 		tx->tx_zc_aborted = 1; /* mark it as not-acked */
-		list_del(&tx->tx_zc_list);
-		list_add(&tx->tx_zc_list, &zlist);
+		list_move(&tx->tx_zc_list, &zlist);
 	}
 
 	spin_unlock(&peer_ni->ksnp_lock);
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
index 208b8d360d5c..cbba90c6b9da 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
@@ -2255,8 +2255,7 @@ ksocknal_flush_stale_txs(struct ksock_peer *peer_ni)
 		if (ktime_get_seconds() < tx->tx_deadline)
 			break;
 
-		list_del(&tx->tx_list);
-		list_add_tail(&tx->tx_list, &stale_txs);
+		list_move_tail(&tx->tx_list, &stale_txs);
 	}
 
 	write_unlock_bh(&ksocknal_data.ksnd_global_lock);
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_proto.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_proto.c
index e8b95affee96..fca63763c260 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_proto.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_proto.c
@@ -437,8 +437,7 @@ ksocknal_handle_zcack(struct ksock_conn *conn, u64 cookie1, u64 cookie2)
 		if (c == cookie1 || c == cookie2 ||
 		    (cookie1 < c && c < cookie2)) {
 			tx->tx_msg.ksm_zc_cookies[0] = 0;
-			list_del(&tx->tx_zc_list);
-			list_add(&tx->tx_zc_list, &zlist);
+			list_move(&tx->tx_zc_list, &zlist);
 
 			if (!--count)
 				break;
diff --git a/drivers/staging/lustre/lnet/lnet/config.c b/drivers/staging/lustre/lnet/lnet/config.c
index f34844465d01..1ec4afd1800c 100644
--- a/drivers/staging/lustre/lnet/lnet/config.c
+++ b/drivers/staging/lustre/lnet/lnet/config.c
@@ -1530,8 +1530,7 @@ lnet_match_networks(char **networksp, char *ip2nets, u32 *ipaddrs, int nip)
 		list_for_each_safe(t, t2, &current_nets) {
 			tb = list_entry(t, struct lnet_text_buf, ltb_list);
 
-			list_del(&tb->ltb_list);
-			list_add_tail(&tb->ltb_list, &matched_nets);
+			list_move_tail(&tb->ltb_list, &matched_nets);
 
 			len += snprintf(networks + len, sizeof(networks) - len,
 					"%s%s", !len ? "" : ",",
diff --git a/drivers/staging/lustre/lnet/lnet/lib-move.c b/drivers/staging/lustre/lnet/lnet/lib-move.c
index 875d2898154f..17f1c4a1029c 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-move.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-move.c
@@ -175,12 +175,10 @@ lnet_fail_nid(lnet_nid_t nid, unsigned int threshold)
 	list_for_each_safe(el, next, &the_lnet.ln_test_peers) {
 		tp = list_entry(el, struct lnet_test_peer, tp_list);
 
-		if (!tp->tp_threshold ||    /* needs culling anyway */
-		    nid == LNET_NID_ANY ||       /* removing all entries */
-		    tp->tp_nid == nid) {	  /* matched this one */
-			list_del(&tp->tp_list);
-			list_add(&tp->tp_list, &cull);
-		}
+		if (!tp->tp_threshold ||	/* needs culling anyway */
+		    nid == LNET_NID_ANY ||	/* removing all entries */
+		    tp->tp_nid == nid)		/* matched this one */
+			list_move(&tp->tp_list, &cull);
 	}
 
 	lnet_net_unlock(0);
@@ -219,8 +217,7 @@ fail_peer(lnet_nid_t nid, int outgoing)
 				 * since we may be at interrupt priority on
 				 * incoming messages.
 				 */
-				list_del(&tp->tp_list);
-				list_add(&tp->tp_list, &cull);
+				list_move(&tp->tp_list, &cull);
 			}
 			continue;
 		}
@@ -234,8 +231,7 @@ fail_peer(lnet_nid_t nid, int outgoing)
 				if (outgoing &&
 				    !tp->tp_threshold) {
 					/* see above */
-					list_del(&tp->tp_list);
-					list_add(&tp->tp_list, &cull);
+					list_move(&tp->tp_list, &cull);
 				}
 			}
 			break;
diff --git a/drivers/staging/lustre/lnet/selftest/console.c b/drivers/staging/lustre/lnet/selftest/console.c
index abc342c6a842..dfd2b94acf90 100644
--- a/drivers/staging/lustre/lnet/selftest/console.c
+++ b/drivers/staging/lustre/lnet/selftest/console.c
@@ -316,12 +316,9 @@ lstcon_group_ndlink_move(struct lstcon_group *old,
 	unsigned int idx = LNET_NIDADDR(ndl->ndl_node->nd_id.nid) %
 					LST_NODE_HASHSIZE;
 
-	list_del(&ndl->ndl_hlink);
-	list_del(&ndl->ndl_link);
 	old->grp_nnode--;
-
-	list_add_tail(&ndl->ndl_hlink, &new->grp_ndl_hash[idx]);
-	list_add_tail(&ndl->ndl_link, &new->grp_ndl_list);
+	list_move_tail(&ndl->ndl_hlink, &new->grp_ndl_hash[idx]);
+	list_move_tail(&ndl->ndl_link, &new->grp_ndl_list);
 	new->grp_nnode++;
 }
 
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c
index 9c61b332a51c..2274e0cc0cdf 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c
@@ -86,9 +86,8 @@ static int import_set_conn(struct obd_import *imp, struct obd_uuid *uuid,
 	list_for_each_entry(item, &imp->imp_conn_list, oic_item) {
 		if (obd_uuid_equals(uuid, &item->oic_uuid)) {
 			if (priority) {
-				list_del(&item->oic_item);
-				list_add(&item->oic_item,
-					 &imp->imp_conn_list);
+				list_move(&item->oic_item,
+					  &imp->imp_conn_list);
 				item->oic_last_attempt = 0;
 			}
 			CDEBUG(D_HA, "imp %p@%s: found existing conn %s%s\n",
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
index a614d7419b8f..fbb12f540dbd 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
@@ -1101,8 +1101,7 @@ int ldlm_cli_cancel_list_local(struct list_head *cancels, int count,
 		 */
 		if (!(flags & LCF_BL_AST) && (rc == LDLM_FL_BL_AST)) {
 			LDLM_DEBUG(lock, "Cancel lock separately");
-			list_del_init(&lock->l_bl_ast);
-			list_add(&lock->l_bl_ast, &head);
+			list_move(&lock->l_bl_ast, &head);
 			bl_ast++;
 			continue;
 		}
diff --git a/drivers/staging/lustre/lustre/ptlrpc/client.c b/drivers/staging/lustre/lustre/ptlrpc/client.c
index da1ccd8f9dcc..e24c9c5eb90d 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/client.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/client.c
@@ -1803,9 +1803,8 @@ int ptlrpc_check_set(const struct lu_env *env, struct ptlrpc_request_set *set)
 					 * put on delay list - only if we wait
 					 * recovery finished - before send
 					 */
-					list_del_init(&req->rq_list);
-					list_add_tail(&req->rq_list,
-						      &imp->imp_delayed_list);
+					list_move_tail(&req->rq_list,
+						       &imp->imp_delayed_list);
 					spin_unlock(&imp->imp_lock);
 					continue;
 				}
@@ -1826,9 +1825,8 @@ int ptlrpc_check_set(const struct lu_env *env, struct ptlrpc_request_set *set)
 					goto interpret;
 				}
 
-				list_del_init(&req->rq_list);
-				list_add_tail(&req->rq_list,
-					      &imp->imp_sending_list);
+				list_move_tail(&req->rq_list,
+					       &imp->imp_sending_list);
 
 				spin_unlock(&imp->imp_lock);
 
diff --git a/drivers/staging/lustre/lustre/ptlrpc/import.c b/drivers/staging/lustre/lustre/ptlrpc/import.c
index 18823d52e06b..a68b870faad2 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/import.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/import.c
@@ -757,8 +757,7 @@ static int ptlrpc_connect_set_flags(struct obd_import *imp,
 	}
 
 	spin_lock(&imp->imp_lock);
-	list_del(&imp->imp_conn_current->oic_item);
-	list_add(&imp->imp_conn_current->oic_item, &imp->imp_conn_list);
+	list_move(&imp->imp_conn_current->oic_item, &imp->imp_conn_list);
 	imp->imp_last_success_conn = imp->imp_conn_current->oic_last_attempt;
 
 	spin_unlock(&imp->imp_lock);
diff --git a/drivers/staging/lustre/lustre/ptlrpc/service.c b/drivers/staging/lustre/lustre/ptlrpc/service.c
index 5e541ca0dc00..c6b95c721167 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/service.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/service.c
@@ -302,11 +302,10 @@ ptlrpc_server_post_idle_rqbds(struct ptlrpc_service_part *svcpt)
 		rqbd = list_first_entry(&svcpt->scp_rqbd_idle,
 					struct ptlrpc_request_buffer_desc,
 					rqbd_list);
-		list_del(&rqbd->rqbd_list);
 
 		/* assume we will post successfully */
 		svcpt->scp_nrqbds_posted++;
-		list_add(&rqbd->rqbd_list, &svcpt->scp_rqbd_posted);
+		list_move(&rqbd->rqbd_list, &svcpt->scp_rqbd_posted);
 
 		spin_unlock(&svcpt->scp_lock);
 
@@ -320,8 +319,7 @@ ptlrpc_server_post_idle_rqbds(struct ptlrpc_service_part *svcpt)
 	spin_lock(&svcpt->scp_lock);
 
 	svcpt->scp_nrqbds_posted--;
-	list_del(&rqbd->rqbd_list);
-	list_add_tail(&rqbd->rqbd_list, &svcpt->scp_rqbd_idle);
+	list_move_tail(&rqbd->rqbd_list, &svcpt->scp_rqbd_idle);
 
 	/* Don't complain if no request buffers are posted right now; LNET
 	 * won't drop requests because we set the portal lazy!
@@ -760,9 +758,7 @@ static void ptlrpc_server_drop_request(struct ptlrpc_request *req)
 	refcount = --(rqbd->rqbd_refcount);
 	if (refcount == 0) {
 		/* request buffer is now idle: add to history */
-		list_del(&rqbd->rqbd_list);
-
-		list_add_tail(&rqbd->rqbd_list, &svcpt->scp_hist_rqbds);
+		list_move_tail(&rqbd->rqbd_list, &svcpt->scp_hist_rqbds);
 		svcpt->scp_hist_nrqbds++;
 
 		/* cull some history?
@@ -2350,8 +2346,7 @@ static void ptlrpc_svcpt_stop_threads(struct ptlrpc_service_part *svcpt)
 						  struct ptlrpc_thread,
 						  t_link)) != NULL) {
 		if (thread_is_stopped(thread)) {
-			list_del(&thread->t_link);
-			list_add(&thread->t_link, &zombie);
+			list_move(&thread->t_link, &zombie);
 			continue;
 		}
 		spin_unlock(&svcpt->scp_lock);
