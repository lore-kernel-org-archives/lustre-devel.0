From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:14:49 -0500
Subject: [lustre-devel] [PATCH 421/622] lnet: Defer rspt cleanup when MD
 queued for unlink
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-422-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Chris Horn <hornc@cray.com>

When an MD is queued for unlink its lnet_libhandle is invalidated so
that future lookups of the MD fail. As a result, the monitor thread
cannot detach the response tracker from such an MD, and instead must
wait for the remaining operations on the MD to complete before it can
safely free the response tracker and remove it from the list. Freeing
the memory while there are pending operations on the MD can result
in a use after free situation when the final operation on the MD
completes and we attempt to remove the response tracker from the MD
via the lnet_msg_detach_md()->lnet_detach_rsp_tracker() call chain.

Here we introduce zombie lists for such response trackers. This will
allow us to also handle the case where there are response trackers
on the monitor queue during LNet shutdown. In this instance the
zombie response trackers will be freed when either all the operations
on the MD have completed (this free'ing is performed by
lnet_detach_rsp_tracker()) or after the LND Nets have shutdown since
we are ensured there will not be any more operations on the
associated MDs (this free'ing is performed by
lnet_clean_zombie_rstqs()).

Three other small changes are included in this patch:
 - When deleting the response tracker from the monitor's list we
   should use list_del() rather than list_del_init() since we'll
   be freeing the response tracker after removing it from the list.
 - Perform a single ktime_get() call for each local queue.
 - Move the check of whether the local queue is empty outside of
   the net lock.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12568
Lustre-commit: 4a4ac34de42c ("LU-12568 lnet: Defer rspt cleanup when MD queued for unlink")
Signed-off-by: Chris Horn <hornc@cray.com>
Reviewed-on: https://review.whamcloud.com/35576
Reviewed-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-by: Alexandr Boyko <c17825@cray.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/lib-lnet.h  |   3 +
 include/linux/lnet/lib-types.h |   7 +++
 net/lnet/lnet/api-ni.c         |  31 ++++++++++
 net/lnet/lnet/lib-move.c       | 134 +++++++++++++++++++++++++++--------------
 4 files changed, 131 insertions(+), 44 deletions(-)

diff --git a/include/linux/lnet/lib-lnet.h b/include/linux/lnet/lib-lnet.h
index dd0075b..b1407b3 100644
--- a/include/linux/lnet/lib-lnet.h
+++ b/include/linux/lnet/lib-lnet.h
@@ -571,6 +571,8 @@ int lnet_send_ping(lnet_nid_t dest_nid, struct lnet_handle_md *mdh, int nnis,
 void lnet_schedule_blocked_locked(struct lnet_rtrbufpool *rbp);
 void lnet_drop_routed_msgs_locked(struct list_head *list, int cpt);
 
+struct list_head **lnet_create_array_of_queues(void);
+
 /* portals functions */
 /* portals attributes */
 static inline int
@@ -641,6 +643,7 @@ struct lnet_msg *lnet_create_reply_msg(struct lnet_ni *ni,
 void lnet_set_reply_msg_len(struct lnet_ni *ni, struct lnet_msg *msg,
 			    unsigned int len);
 void lnet_detach_rsp_tracker(struct lnet_libmd *md, int cpt);
+void lnet_clean_zombie_rstqs(void);
 
 void lnet_finalize(struct lnet_msg *msg, int rc);
 bool lnet_send_error_simulation(struct lnet_msg *msg,
diff --git a/include/linux/lnet/lib-types.h b/include/linux/lnet/lib-types.h
index 1009a69..904ef7a 100644
--- a/include/linux/lnet/lib-types.h
+++ b/include/linux/lnet/lib-types.h
@@ -1158,6 +1158,13 @@ struct lnet {
 	 * based on the mdh cookie.
 	 */
 	struct list_head		**ln_mt_rstq;
+	/*
+	 * A response tracker becomes a zombie when the associated MD is queued
+	 * for unlink before the response tracker is detached from the MD. An
+	 * entry on a zombie list can be freed when either the remaining
+	 * operations on the MD complete or when LNet has shut down.
+	 */
+	struct list_head		**ln_mt_zombie_rstqs;
 	/* recovery eq handler */
 	struct lnet_handle_eq		ln_mt_eqh;
 
diff --git a/net/lnet/lnet/api-ni.c b/net/lnet/lnet/api-ni.c
index aa5ca52..e773839 100644
--- a/net/lnet/lnet/api-ni.c
+++ b/net/lnet/lnet/api-ni.c
@@ -1028,6 +1028,26 @@ struct lnet_libhandle *
 	list_add(&lh->lh_hash_chain, &rec->rec_lh_hash[hash]);
 }
 
+struct list_head **
+lnet_create_array_of_queues(void)
+{
+	struct list_head **qs;
+	struct list_head *q;
+	int i;
+
+	qs = cfs_percpt_alloc(lnet_cpt_table(),
+			      sizeof(struct list_head));
+	if (!qs) {
+		CERROR("Failed to allocate queues\n");
+		return NULL;
+	}
+
+	cfs_percpt_for_each(q, i, qs)
+		INIT_LIST_HEAD(q);
+
+	return qs;
+}
+
 static int lnet_unprepare(void);
 
 static int
@@ -1120,6 +1140,12 @@ struct lnet_libhandle *
 		goto failed;
 	}
 
+	the_lnet.ln_mt_zombie_rstqs = lnet_create_array_of_queues();
+	if (!the_lnet.ln_mt_zombie_rstqs) {
+		rc = -ENOMEM;
+		goto failed;
+	}
+
 	return 0;
 
 failed:
@@ -1144,6 +1170,11 @@ struct lnet_libhandle *
 	LASSERT(list_empty(&the_lnet.ln_test_peers));
 	LASSERT(list_empty(&the_lnet.ln_nets));
 
+	if (the_lnet.ln_mt_zombie_rstqs) {
+		lnet_clean_zombie_rstqs();
+		the_lnet.ln_mt_zombie_rstqs = NULL;
+	}
+
 	if (!LNetEQHandleIsInvalid(the_lnet.ln_mt_eqh)) {
 		rc = LNetEQFree(the_lnet.ln_mt_eqh);
 		LNetInvalidateEQHandle(&the_lnet.ln_mt_eqh);
diff --git a/net/lnet/lnet/lib-move.c b/net/lnet/lnet/lib-move.c
index 413397c..322998a 100644
--- a/net/lnet/lnet/lib-move.c
+++ b/net/lnet/lnet/lib-move.c
@@ -2556,24 +2556,55 @@ struct lnet_mt_event_info {
 		return;
 
 	rspt = md->md_rspt_ptr;
-	md->md_rspt_ptr = NULL;
 
 	/* debug code */
 	LASSERT(rspt->rspt_cpt == cpt);
 
-	/* invalidate the handle to indicate that a response has been
-	 * received, which will then lead the monitor thread to clean up
-	 * the rspt block.
-	 */
-	LNetInvalidateMDHandle(&rspt->rspt_mdh);
+	md->md_rspt_ptr = NULL;
+
+	if (LNetMDHandleIsInvalid(rspt->rspt_mdh)) {
+		/* The monitor thread has invalidated this handle because the
+		 * response timed out, but it failed to lookup the MD. That
+		 * means this response tracker is on the zombie list. We can
+		 * safely remove it under the resource lock (held by caller) and
+		 * free the response tracker block.
+		 */
+		list_del(&rspt->rspt_on_list);
+		lnet_rspt_free(rspt, cpt);
+	} else {
+		/* invalidate the handle to indicate that a response has been
+		 * received, which will then lead the monitor thread to clean up
+		 * the rspt block.
+		 */
+		LNetInvalidateMDHandle(&rspt->rspt_mdh);
+	}
+}
+
+void
+lnet_clean_zombie_rstqs(void)
+{
+	struct lnet_rsp_tracker *rspt, *tmp;
+	int i;
+
+	cfs_cpt_for_each(i, lnet_cpt_table()) {
+		list_for_each_entry_safe(rspt, tmp,
+					 the_lnet.ln_mt_zombie_rstqs[i],
+					 rspt_on_list) {
+			list_del(&rspt->rspt_on_list);
+			lnet_rspt_free(rspt, i);
+		}
+	}
+
+	cfs_percpt_free(the_lnet.ln_mt_zombie_rstqs);
 }
 
 static void
-lnet_finalize_expired_responses(bool force)
+lnet_finalize_expired_responses(void)
 {
 	struct lnet_libmd *md;
 	struct list_head local_queue;
 	struct lnet_rsp_tracker *rspt, *tmp;
+	ktime_t now;
 	int i;
 
 	if (!the_lnet.ln_mt_rstq)
@@ -2590,6 +2621,8 @@ struct lnet_mt_event_info {
 		list_splice_init(the_lnet.ln_mt_rstq[i], &local_queue);
 		lnet_net_unlock(i);
 
+		now = ktime_get();
+
 		list_for_each_entry_safe(rspt, tmp, &local_queue,
 					 rspt_on_list) {
 			/* The rspt mdh will be invalidated when a response
@@ -2605,42 +2638,74 @@ struct lnet_mt_event_info {
 			lnet_res_lock(i);
 			if (LNetMDHandleIsInvalid(rspt->rspt_mdh)) {
 				lnet_res_unlock(i);
-				list_del_init(&rspt->rspt_on_list);
+				list_del(&rspt->rspt_on_list);
 				lnet_rspt_free(rspt, i);
 				continue;
 			}
 
-			if (ktime_compare(ktime_get(),
-					  rspt->rspt_deadline) >= 0 ||
-			    force) {
+			if (ktime_compare(now, rspt->rspt_deadline) >= 0 ||
+			    the_lnet.ln_mt_state == LNET_MT_STATE_SHUTDOWN) {
 				struct lnet_peer_ni *lpni;
 				lnet_nid_t nid;
 
 				md = lnet_handle2md(&rspt->rspt_mdh);
 				if (!md) {
+					/* MD has been queued for unlink, but
+					 * rspt hasn't been detached (Note we've
+					 * checked above that the rspt_mdh is
+					 * valid). Since we cannot lookup the MD
+					 * we're unable to detach the rspt
+					 * ourselves. Thus, move the rspt to the
+					 * zombie list where we'll wait for
+					 * either:
+					 *   1. The remaining operations on the
+					 *   MD to complete. In this case the
+					 *   final operation will result in
+					 *   lnet_msg_detach_md()->
+					 *   lnet_detach_rsp_tracker() where
+					 *   we will clean up this response
+					 *   tracker.
+					 *   2. LNet to shutdown. In this case
+					 *   we'll wait until after all LND Nets
+					 *   have shutdown and then we can
+					 *   safely free any remaining response
+					 *   tracker blocks on the zombie list.
+					 * Note: We need to hold the resource
+					 * lock when adding to the zombie list
+					 * because we may have concurrent access
+					 * with lnet_detach_rsp_tracker().
+					 */
 					LNetInvalidateMDHandle(&rspt->rspt_mdh);
+					list_move(&rspt->rspt_on_list,
+						  the_lnet.ln_mt_zombie_rstqs[i]);
 					lnet_res_unlock(i);
-					list_del_init(&rspt->rspt_on_list);
-					lnet_rspt_free(rspt, i);
 					continue;
 				}
 				LASSERT(md->md_rspt_ptr == rspt);
 				md->md_rspt_ptr = NULL;
 				lnet_res_unlock(i);
 
+				LNetMDUnlink(rspt->rspt_mdh);
+
+				nid = rspt->rspt_next_hop_nid;
+
+				list_del(&rspt->rspt_on_list);
+				lnet_rspt_free(rspt, i);
+
+				/* If we're shutting down we just want to clean
+				 * up the rspt blocks
+				 */
+				if (the_lnet.ln_mt_state ==
+				    LNET_MT_STATE_SHUTDOWN)
+					continue;
+
 				lnet_net_lock(i);
 				the_lnet.ln_counters[i]->lct_health.lch_response_timeout_count++;
 				lnet_net_unlock(i);
 
-				list_del_init(&rspt->rspt_on_list);
-
-				nid = rspt->rspt_next_hop_nid;
-
 				CDEBUG(D_NET,
 				       "Response timeout: md = %p: nid = %s\n",
 				       md, libcfs_nid2str(nid));
-				LNetMDUnlink(rspt->rspt_mdh);
-				lnet_rspt_free(rspt, i);
 
 				/* If there is a timeout on the response
 				 * from the next hop decrement its health
@@ -2659,10 +2724,11 @@ struct lnet_mt_event_info {
 			}
 		}
 
-		lnet_net_lock(i);
-		if (!list_empty(&local_queue))
+		if (!list_empty(&local_queue)) {
+			lnet_net_lock(i);
 			list_splice(&local_queue, the_lnet.ln_mt_rstq[i]);
-		lnet_net_unlock(i);
+			lnet_net_unlock(i);
+		}
 	}
 }
 
@@ -2927,26 +2993,6 @@ struct lnet_mt_event_info {
 	lnet_net_unlock(0);
 }
 
-static struct list_head **
-lnet_create_array_of_queues(void)
-{
-	struct list_head **qs;
-	struct list_head *q;
-	int i;
-
-	qs = cfs_percpt_alloc(lnet_cpt_table(),
-			      sizeof(struct list_head));
-	if (!qs) {
-		CERROR("Failed to allocate queues\n");
-		return NULL;
-	}
-
-	cfs_percpt_for_each(q, i, qs)
-		INIT_LIST_HEAD(q);
-
-	return qs;
-}
-
 static int
 lnet_resendqs_create(void)
 {
@@ -3204,7 +3250,7 @@ struct lnet_mt_event_info {
 		lnet_resend_pending_msgs();
 
 		if (now >= rsp_timeout) {
-			lnet_finalize_expired_responses(false);
+			lnet_finalize_expired_responses();
 			rsp_timeout = now + (lnet_transaction_timeout / 2);
 		}
 
@@ -3422,7 +3468,7 @@ struct lnet_mt_event_info {
 static void
 lnet_rsp_tracker_clean(void)
 {
-	lnet_finalize_expired_responses(true);
+	lnet_finalize_expired_responses();
 
 	cfs_percpt_free(the_lnet.ln_mt_rstq);
 	the_lnet.ln_mt_rstq = NULL;
-- 
1.8.3.1
