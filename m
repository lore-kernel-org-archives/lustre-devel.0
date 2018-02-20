From: NeilBrown <neilb@suse.com>
Date: Tue, 20 Feb 2018 13:23:38 +1100
Subject: [lustre-devel] [PATCH 15/21] staging: lustre: ptlrpc: list_for_each
 improvements.
In-Reply-To: <151909308778.25814.9912662268627044409.stgit@noble>
References: <151909308778.25814.9912662268627044409.stgit@noble>
Message-ID: <151909341806.25814.159210690547707508.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, James Simmons <jsimmons@infradead.org>, Andreas Dilger <andreas.dilger@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: lkml <linux-kernel@vger.kernel.org>, lustre <lustre-devel@lists.lustre.org>

1/ use list_for_each_entry_safe() instead of
   list_for_each_safe() and similar.

2/ use list_first_entry() and list_last_entry() where appropriate.

3/ When removing everything from a list, use
     while ((x = list_first_entry_or_null()) {
   as it makes the intent clear

4/ No need to take a spinlock in a structure that is about
   to be freed - we must have exclusive access at this stage.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/ptlrpc/client.c  |   89 +++++++-----------------
 drivers/staging/lustre/lustre/ptlrpc/import.c  |   34 +++------
 drivers/staging/lustre/lustre/ptlrpc/pinger.c  |    8 +-
 drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c |   15 +---
 drivers/staging/lustre/lustre/ptlrpc/recover.c |   26 +++----
 drivers/staging/lustre/lustre/ptlrpc/service.c |   13 +---
 6 files changed, 59 insertions(+), 126 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ptlrpc/client.c b/drivers/staging/lustre/lustre/ptlrpc/client.c
index d4c641d2480c..ca096fadb9c0 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/client.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/client.c
@@ -504,19 +504,16 @@ void ptlrpc_request_cache_free(struct ptlrpc_request *req)
  */
 void ptlrpc_free_rq_pool(struct ptlrpc_request_pool *pool)
 {
-	struct list_head *l, *tmp;
 	struct ptlrpc_request *req;
 
-	spin_lock(&pool->prp_lock);
-	list_for_each_safe(l, tmp, &pool->prp_req_list) {
-		req = list_entry(l, struct ptlrpc_request, rq_list);
+	while ((req = list_first_entry_or_null(&pool->prp_req_list,
+					       struct ptlrpc_request, rq_list))) {
 		list_del(&req->rq_list);
 		LASSERT(req->rq_reqbuf);
 		LASSERT(req->rq_reqbuf_len == pool->prp_rq_size);
 		kvfree(req->rq_reqbuf);
 		ptlrpc_request_cache_free(req);
 	}
-	spin_unlock(&pool->prp_lock);
 	kfree(pool);
 }
 EXPORT_SYMBOL(ptlrpc_free_rq_pool);
@@ -656,16 +653,13 @@ static void __ptlrpc_free_req_to_pool(struct ptlrpc_request *request)
 void ptlrpc_add_unreplied(struct ptlrpc_request *req)
 {
 	struct obd_import	*imp = req->rq_import;
-	struct list_head	*tmp;
 	struct ptlrpc_request	*iter;
 
 	assert_spin_locked(&imp->imp_lock);
 	LASSERT(list_empty(&req->rq_unreplied_list));
 
 	/* unreplied list is sorted by xid in ascending order */
-	list_for_each_prev(tmp, &imp->imp_unreplied_list) {
-		iter = list_entry(tmp, struct ptlrpc_request,
-				  rq_unreplied_list);
+	list_for_each_entry_reverse(iter, &imp->imp_unreplied_list, rq_unreplied_list) {
 
 		LASSERT(req->rq_xid != iter->rq_xid);
 		if (req->rq_xid < iter->rq_xid)
@@ -1001,18 +995,14 @@ struct ptlrpc_request_set *ptlrpc_prep_fcset(int max, set_producer_func func,
  */
 void ptlrpc_set_destroy(struct ptlrpc_request_set *set)
 {
-	struct list_head *tmp;
-	struct list_head *next;
+	struct ptlrpc_request *req;
 	int expected_phase;
 	int n = 0;
 
 	/* Requests on the set should either all be completed, or all be new */
 	expected_phase = (atomic_read(&set->set_remaining) == 0) ?
 			 RQ_PHASE_COMPLETE : RQ_PHASE_NEW;
-	list_for_each(tmp, &set->set_requests) {
-		struct ptlrpc_request *req =
-			list_entry(tmp, struct ptlrpc_request, rq_set_chain);
-
+	list_for_each_entry(req, &set->set_requests, rq_set_chain) {
 		LASSERT(req->rq_phase == expected_phase);
 		n++;
 	}
@@ -1021,9 +1011,9 @@ void ptlrpc_set_destroy(struct ptlrpc_request_set *set)
 		 atomic_read(&set->set_remaining) == n, "%d / %d\n",
 		 atomic_read(&set->set_remaining), n);
 
-	list_for_each_safe(tmp, next, &set->set_requests) {
-		struct ptlrpc_request *req =
-			list_entry(tmp, struct ptlrpc_request, rq_set_chain);
+	while ((req = list_first_entry_or_null(&set->set_requests,
+					       struct ptlrpc_request,
+					       rq_set_chain))) {
 		list_del_init(&req->rq_set_chain);
 
 		LASSERT(req->rq_phase == expected_phase);
@@ -1640,7 +1630,7 @@ static inline int ptlrpc_set_producer(struct ptlrpc_request_set *set)
  */
 int ptlrpc_check_set(const struct lu_env *env, struct ptlrpc_request_set *set)
 {
-	struct list_head *tmp, *next;
+	struct ptlrpc_request *req, *next;
 	struct list_head comp_reqs;
 	int force_timer_recalc = 0;
 
@@ -1648,9 +1638,7 @@ int ptlrpc_check_set(const struct lu_env *env, struct ptlrpc_request_set *set)
 		return 1;
 
 	INIT_LIST_HEAD(&comp_reqs);
-	list_for_each_safe(tmp, next, &set->set_requests) {
-		struct ptlrpc_request *req =
-			list_entry(tmp, struct ptlrpc_request, rq_set_chain);
+	list_for_each_entry_safe(req, next, &set->set_requests, rq_set_chain) {
 		struct obd_import *imp = req->rq_import;
 		int unregistered = 0;
 		int rc = 0;
@@ -2126,13 +2114,11 @@ int ptlrpc_expire_one_request(struct ptlrpc_request *req, int async_unlink)
  */
 void ptlrpc_expired_set(struct ptlrpc_request_set *set)
 {
-	struct list_head *tmp;
+	struct ptlrpc_request *req;
 	time64_t now = ktime_get_real_seconds();
 
 	/* A timeout expired. See which reqs it applies to...  */
-	list_for_each(tmp, &set->set_requests) {
-		struct ptlrpc_request *req =
-			list_entry(tmp, struct ptlrpc_request, rq_set_chain);
+	list_for_each_entry(req, &set->set_requests, rq_set_chain) {
 
 		/* don't expire request waiting for context */
 		if (req->rq_wait_ctx)
@@ -2173,13 +2159,10 @@ EXPORT_SYMBOL(ptlrpc_mark_interrupted);
  */
 static void ptlrpc_interrupted_set(struct ptlrpc_request_set *set)
 {
-	struct list_head *tmp;
-
+	struct ptlrpc_request *req;
 	CDEBUG(D_RPCTRACE, "INTERRUPTED SET %p\n", set);
 
-	list_for_each(tmp, &set->set_requests) {
-		struct ptlrpc_request *req =
-			list_entry(tmp, struct ptlrpc_request, rq_set_chain);
+	list_for_each_entry(req, &set->set_requests, rq_set_chain) {
 
 		if (req->rq_phase != RQ_PHASE_RPC &&
 		    req->rq_phase != RQ_PHASE_UNREG_RPC)
@@ -2194,14 +2177,12 @@ static void ptlrpc_interrupted_set(struct ptlrpc_request_set *set)
  */
 int ptlrpc_set_next_timeout(struct ptlrpc_request_set *set)
 {
-	struct list_head *tmp;
 	time64_t now = ktime_get_real_seconds();
 	int timeout = 0;
 	struct ptlrpc_request *req;
 	time64_t deadline;
 
-	list_for_each(tmp, &set->set_requests) {
-		req = list_entry(tmp, struct ptlrpc_request, rq_set_chain);
+	list_for_each_entry(req, &set->set_requests, rq_set_chain) {
 
 		/* Request in-flight? */
 		if (!(((req->rq_phase == RQ_PHASE_RPC) && !req->rq_waiting) ||
@@ -2240,16 +2221,13 @@ int ptlrpc_set_next_timeout(struct ptlrpc_request_set *set)
  */
 int ptlrpc_set_wait(struct ptlrpc_request_set *set)
 {
-	struct list_head *tmp;
 	struct ptlrpc_request *req;
 	int rc, timeout;
 
 	if (set->set_producer)
 		(void)ptlrpc_set_producer(set);
 	else
-		list_for_each(tmp, &set->set_requests) {
-			req = list_entry(tmp, struct ptlrpc_request,
-					 rq_set_chain);
+		list_for_each_entry(req, &set->set_requests, rq_set_chain) {
 			if (req->rq_phase == RQ_PHASE_NEW)
 				(void)ptlrpc_send_new_req(req);
 		}
@@ -2322,9 +2300,7 @@ int ptlrpc_set_wait(struct ptlrpc_request_set *set)
 		 * the error cases -eeb.
 		 */
 		if (rc == 0 && atomic_read(&set->set_remaining) == 0) {
-			list_for_each(tmp, &set->set_requests) {
-				req = list_entry(tmp, struct ptlrpc_request,
-						 rq_set_chain);
+			list_for_each_entry(req, &set->set_requests, rq_set_chain) {
 				spin_lock(&req->rq_lock);
 				req->rq_invalid_rqset = 1;
 				spin_unlock(&req->rq_lock);
@@ -2335,9 +2311,7 @@ int ptlrpc_set_wait(struct ptlrpc_request_set *set)
 	LASSERT(atomic_read(&set->set_remaining) == 0);
 
 	rc = set->set_rc; /* rq_status of already freed requests if any */
-	list_for_each(tmp, &set->set_requests) {
-		req = list_entry(tmp, struct ptlrpc_request, rq_set_chain);
-
+	list_for_each_entry(req, &set->set_requests, rq_set_chain) {
 		LASSERT(req->rq_phase == RQ_PHASE_COMPLETE);
 		if (req->rq_status != 0)
 			rc = req->rq_status;
@@ -2716,8 +2690,7 @@ EXPORT_SYMBOL(ptlrpc_request_addref);
 void ptlrpc_retain_replayable_request(struct ptlrpc_request *req,
 				      struct obd_import *imp)
 {
-	struct list_head *tmp;
-
+	struct ptlrpc_request *iter;
 	assert_spin_locked(&imp->imp_lock);
 
 	if (req->rq_transno == 0) {
@@ -2744,10 +2717,7 @@ void ptlrpc_retain_replayable_request(struct ptlrpc_request *req,
 	LASSERT(imp->imp_replayable);
 	/* Balanced in ptlrpc_free_committed, usually. */
 	ptlrpc_request_addref(req);
-	list_for_each_prev(tmp, &imp->imp_replay_list) {
-		struct ptlrpc_request *iter =
-			list_entry(tmp, struct ptlrpc_request, rq_replay_list);
-
+	list_for_each_entry_reverse(iter, &imp->imp_replay_list, rq_replay_list) {
 		/*
 		 * We may have duplicate transnos if we create and then
 		 * open a file, or for closes retained if to match creating
@@ -2955,7 +2925,7 @@ int ptlrpc_replay_req(struct ptlrpc_request *req)
  */
 void ptlrpc_abort_inflight(struct obd_import *imp)
 {
-	struct list_head *tmp, *n;
+	struct ptlrpc_request *req, *n;
 
 	/*
 	 * Make sure that no new requests get processed for this import.
@@ -2969,10 +2939,7 @@ void ptlrpc_abort_inflight(struct obd_import *imp)
 	 * locked?  Also, how do we know if the requests on the list are
 	 * being freed at this time?
 	 */
-	list_for_each_safe(tmp, n, &imp->imp_sending_list) {
-		struct ptlrpc_request *req =
-			list_entry(tmp, struct ptlrpc_request, rq_list);
-
+	list_for_each_entry_safe(req, n, &imp->imp_sending_list, rq_list) {
 		DEBUG_REQ(D_RPCTRACE, req, "inflight");
 
 		spin_lock(&req->rq_lock);
@@ -2984,10 +2951,7 @@ void ptlrpc_abort_inflight(struct obd_import *imp)
 		spin_unlock(&req->rq_lock);
 	}
 
-	list_for_each_safe(tmp, n, &imp->imp_delayed_list) {
-		struct ptlrpc_request *req =
-			list_entry(tmp, struct ptlrpc_request, rq_list);
-
+	list_for_each_entry_safe(req, n, &imp->imp_delayed_list, rq_list) {
 		DEBUG_REQ(D_RPCTRACE, req, "aborting waiting req");
 
 		spin_lock(&req->rq_lock);
@@ -3014,12 +2978,9 @@ void ptlrpc_abort_inflight(struct obd_import *imp)
  */
 void ptlrpc_abort_set(struct ptlrpc_request_set *set)
 {
-	struct list_head *tmp, *pos;
-
-	list_for_each_safe(pos, tmp, &set->set_requests) {
-		struct ptlrpc_request *req =
-			list_entry(pos, struct ptlrpc_request, rq_set_chain);
+	struct ptlrpc_request *req, *tmp;
 
+	list_for_each_entry_safe(req, tmp, &set->set_requests, rq_set_chain) {
 		spin_lock(&req->rq_lock);
 		if (req->rq_phase != RQ_PHASE_RPC) {
 			spin_unlock(&req->rq_lock);
diff --git a/drivers/staging/lustre/lustre/ptlrpc/import.c b/drivers/staging/lustre/lustre/ptlrpc/import.c
index faf0f606f013..a2c4fc3488b1 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/import.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/import.c
@@ -242,15 +242,13 @@ ptlrpc_inflight_deadline(struct ptlrpc_request *req, time64_t now)
 static unsigned int ptlrpc_inflight_timeout(struct obd_import *imp)
 {
 	time64_t now = ktime_get_real_seconds();
-	struct list_head *tmp, *n;
-	struct ptlrpc_request *req;
+	struct ptlrpc_request *req, *n;
 	unsigned int timeout = 0;
 
 	spin_lock(&imp->imp_lock);
-	list_for_each_safe(tmp, n, &imp->imp_sending_list) {
-		req = list_entry(tmp, struct ptlrpc_request, rq_list);
+	list_for_each_entry_safe(req, n, &imp->imp_sending_list, rq_list)
 		timeout = max(ptlrpc_inflight_deadline(req, now), timeout);
-	}
+
 	spin_unlock(&imp->imp_lock);
 	return timeout;
 }
@@ -263,8 +261,7 @@ static unsigned int ptlrpc_inflight_timeout(struct obd_import *imp)
  */
 void ptlrpc_invalidate_import(struct obd_import *imp)
 {
-	struct list_head *tmp, *n;
-	struct ptlrpc_request *req;
+	struct ptlrpc_request *req, *n;
 	unsigned int timeout;
 	int rc;
 
@@ -336,19 +333,13 @@ void ptlrpc_invalidate_import(struct obd_import *imp)
 				 */
 				rc = 0;
 			} else {
-				list_for_each_safe(tmp, n,
-						   &imp->imp_sending_list) {
-					req = list_entry(tmp,
-							 struct ptlrpc_request,
-							 rq_list);
+				list_for_each_entry_safe(req, n,
+							 &imp->imp_sending_list, rq_list) {
 					DEBUG_REQ(D_ERROR, req,
 						  "still on sending list");
 				}
-				list_for_each_safe(tmp, n,
-						   &imp->imp_delayed_list) {
-					req = list_entry(tmp,
-							 struct ptlrpc_request,
-							 rq_list);
+				list_for_each_entry_safe(req, n,
+							 &imp->imp_delayed_list, rq_list) {
 					DEBUG_REQ(D_ERROR, req,
 						  "still on delayed list");
 				}
@@ -557,14 +548,13 @@ static int import_select_connection(struct obd_import *imp)
 static int ptlrpc_first_transno(struct obd_import *imp, __u64 *transno)
 {
 	struct ptlrpc_request *req;
-	struct list_head *tmp;
 
 	/* The requests in committed_list always have smaller transnos than
 	 * the requests in replay_list
 	 */
 	if (!list_empty(&imp->imp_committed_list)) {
-		tmp = imp->imp_committed_list.next;
-		req = list_entry(tmp, struct ptlrpc_request, rq_replay_list);
+		req = list_first_entry(&imp->imp_committed_list,
+				       struct ptlrpc_request, rq_replay_list);
 		*transno = req->rq_transno;
 		if (req->rq_transno == 0) {
 			DEBUG_REQ(D_ERROR, req,
@@ -574,8 +564,8 @@ static int ptlrpc_first_transno(struct obd_import *imp, __u64 *transno)
 		return 1;
 	}
 	if (!list_empty(&imp->imp_replay_list)) {
-		tmp = imp->imp_replay_list.next;
-		req = list_entry(tmp, struct ptlrpc_request, rq_replay_list);
+		req = list_first_entry(&imp->imp_replay_list,
+				       struct ptlrpc_request, rq_replay_list);
 		*transno = req->rq_transno;
 		if (req->rq_transno == 0) {
 			DEBUG_REQ(D_ERROR, req, "zero transno in replay_list");
diff --git a/drivers/staging/lustre/lustre/ptlrpc/pinger.c b/drivers/staging/lustre/lustre/ptlrpc/pinger.c
index 639070f6e68e..b5f3cfee8e75 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/pinger.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/pinger.c
@@ -230,17 +230,13 @@ static int ptlrpc_pinger_main(void *arg)
 		unsigned long this_ping = cfs_time_current();
 		long time_to_next_wake;
 		struct timeout_item *item;
-		struct list_head *iter;
+		struct obd_import *imp;
 
 		mutex_lock(&pinger_mutex);
 		list_for_each_entry(item, &timeout_list, ti_chain) {
 			item->ti_cb(item, item->ti_cb_data);
 		}
-		list_for_each(iter, &pinger_imports) {
-			struct obd_import *imp =
-				list_entry(iter, struct obd_import,
-					   imp_pinger_chain);
-
+		list_for_each_entry(imp, &pinger_imports, imp_pinger_chain) {
 			ptlrpc_pinger_process_import(imp, this_ping);
 			/* obd_timeout might have changed */
 			if (imp->imp_pingable && imp->imp_next_ping &&
diff --git a/drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c b/drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c
index 6ed77521d025..c0fa13942bd8 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c
@@ -197,17 +197,14 @@ ptlrpcd_select_pc(struct ptlrpc_request *req)
 static int ptlrpcd_steal_rqset(struct ptlrpc_request_set *des,
 			       struct ptlrpc_request_set *src)
 {
-	struct list_head *tmp, *pos;
-	struct ptlrpc_request *req;
+	struct ptlrpc_request *req, *tmp;
 	int rc = 0;
 
 	spin_lock(&src->set_new_req_lock);
 	if (likely(!list_empty(&src->set_new_requests))) {
-		list_for_each_safe(pos, tmp, &src->set_new_requests) {
-			req = list_entry(pos, struct ptlrpc_request,
-					 rq_set_chain);
+		list_for_each_entry_safe(req, tmp, &src->set_new_requests, rq_set_chain)
 			req->rq_set = des;
-		}
+
 		list_splice_init(&src->set_new_requests, &des->set_requests);
 		rc = atomic_read(&src->set_new_count);
 		atomic_add(rc, &des->set_remaining);
@@ -273,8 +270,7 @@ static inline void ptlrpc_reqset_get(struct ptlrpc_request_set *set)
  */
 static int ptlrpcd_check(struct lu_env *env, struct ptlrpcd_ctl *pc)
 {
-	struct list_head *tmp, *pos;
-	struct ptlrpc_request *req;
+	struct ptlrpc_request *req, *tmp;
 	struct ptlrpc_request_set *set = pc->pc_set;
 	int rc = 0;
 	int rc2;
@@ -320,8 +316,7 @@ static int ptlrpcd_check(struct lu_env *env, struct ptlrpcd_ctl *pc)
 	/* NB: ptlrpc_check_set has already moved completed request at the
 	 * head of seq::set_requests
 	 */
-	list_for_each_safe(pos, tmp, &set->set_requests) {
-		req = list_entry(pos, struct ptlrpc_request, rq_set_chain);
+	list_for_each_entry_safe(req, tmp, &set->set_requests, rq_set_chain) {
 		if (req->rq_phase != RQ_PHASE_COMPLETE)
 			break;
 
diff --git a/drivers/staging/lustre/lustre/ptlrpc/recover.c b/drivers/staging/lustre/lustre/ptlrpc/recover.c
index 5bb9f9fe91d8..2ea0a7ff87dd 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/recover.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/recover.c
@@ -66,8 +66,7 @@ void ptlrpc_initiate_recovery(struct obd_import *imp)
 int ptlrpc_replay_next(struct obd_import *imp, int *inflight)
 {
 	int rc = 0;
-	struct list_head *tmp, *pos;
-	struct ptlrpc_request *req = NULL;
+	struct ptlrpc_request *req = NULL, *pos;
 	__u64 last_transno;
 
 	*inflight = 0;
@@ -86,8 +85,8 @@ int ptlrpc_replay_next(struct obd_import *imp, int *inflight)
 
 	/* Replay all the committed open requests on committed_list first */
 	if (!list_empty(&imp->imp_committed_list)) {
-		tmp = imp->imp_committed_list.prev;
-		req = list_entry(tmp, struct ptlrpc_request, rq_replay_list);
+		req = list_last_entry(&imp->imp_committed_list,
+				      struct ptlrpc_request, rq_replay_list);
 
 		/* The last request on committed_list hasn't been replayed */
 		if (req->rq_transno > last_transno) {
@@ -119,13 +118,13 @@ int ptlrpc_replay_next(struct obd_import *imp, int *inflight)
 	 * the imp_replay_list
 	 */
 	if (!req) {
-		list_for_each_safe(tmp, pos, &imp->imp_replay_list) {
-			req = list_entry(tmp, struct ptlrpc_request,
-					 rq_replay_list);
-
-			if (req->rq_transno > last_transno)
+		struct ptlrpc_request *tmp;
+		list_for_each_entry_safe(tmp, pos, &imp->imp_replay_list,
+					 rq_replay_list) {
+			if (tmp->rq_transno > last_transno) {
+				req = tmp;
 				break;
-			req = NULL;
+			}
 		}
 	}
 
@@ -211,13 +210,10 @@ int ptlrpc_resend(struct obd_import *imp)
  */
 void ptlrpc_wake_delayed(struct obd_import *imp)
 {
-	struct list_head *tmp, *pos;
-	struct ptlrpc_request *req;
+	struct ptlrpc_request *req, *pos;
 
 	spin_lock(&imp->imp_lock);
-	list_for_each_safe(tmp, pos, &imp->imp_delayed_list) {
-		req = list_entry(tmp, struct ptlrpc_request, rq_list);
-
+	list_for_each_entry_safe(req, pos, &imp->imp_delayed_list, rq_list) {
 		DEBUG_REQ(D_HA, req, "waking (set %p):", req->rq_set);
 		ptlrpc_client_wake_req(req);
 	}
diff --git a/drivers/staging/lustre/lustre/ptlrpc/service.c b/drivers/staging/lustre/lustre/ptlrpc/service.c
index 99aeb291f3f2..49417228b621 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/service.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/service.c
@@ -726,8 +726,6 @@ static void ptlrpc_server_drop_request(struct ptlrpc_request *req)
 	struct ptlrpc_service_part *svcpt = rqbd->rqbd_svcpt;
 	struct ptlrpc_service *svc = svcpt->scp_service;
 	int refcount;
-	struct list_head *tmp;
-	struct list_head *nxt;
 
 	if (!atomic_dec_and_test(&req->rq_refcount))
 		return;
@@ -776,9 +774,7 @@ static void ptlrpc_server_drop_request(struct ptlrpc_request *req)
 			/* remove rqbd's reqs from svc's req history while
 			 * I've got the service lock
 			 */
-			list_for_each(tmp, &rqbd->rqbd_reqs) {
-				req = list_entry(tmp, struct ptlrpc_request,
-						 rq_list);
+			list_for_each_entry(req, &rqbd->rqbd_reqs, rq_list) {
 				/* Track the highest culled req seq */
 				if (req->rq_history_seq >
 				    svcpt->scp_hist_seq_culled) {
@@ -790,10 +786,9 @@ static void ptlrpc_server_drop_request(struct ptlrpc_request *req)
 
 			spin_unlock(&svcpt->scp_lock);
 
-			list_for_each_safe(tmp, nxt, &rqbd->rqbd_reqs) {
-				req = list_entry(rqbd->rqbd_reqs.next,
-						 struct ptlrpc_request,
-						 rq_list);
+			while ((req = list_first_entry_or_null(
+					&rqbd->rqbd_reqs,
+					struct ptlrpc_request, rq_list))) {
 				list_del(&req->rq_list);
 				ptlrpc_server_free_request(req);
 			}
