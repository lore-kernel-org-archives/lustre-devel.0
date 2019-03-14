From: NeilBrown <neilb@suse.com>
Date: Thu, 14 Mar 2019 11:11:51 +1100
Subject: [lustre-devel] [PATCH 26/32] lustre: ptlrpc: don't use
 list_for_each_entry_safe unnecessarily.
In-Reply-To: <155252182126.26912.1842463462595601611.stgit@noble.brown>
References: <155252182126.26912.1842463462595601611.stgit@noble.brown>
Message-ID: <155252231140.26912.8140429396611661381.stgit@noble.brown>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

list_for_each_entry_safe() is only needed if the body of the
loop might change the list, or if it might drop a lock that would
otherwise prevent the list from being changed.

When the body does neither of these, list_for_each_entry() should be
preferred as it makes the behaviour of the loop more clear to readers.

In each of the cases changed there, the list cannot change while the
loop proceeds.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/ptlrpc/client.c  |   10 +++++-----
 drivers/staging/lustre/lustre/ptlrpc/import.c  |   14 +++++++-------
 drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c |    4 ++--
 drivers/staging/lustre/lustre/ptlrpc/recover.c |   14 +++++++-------
 4 files changed, 21 insertions(+), 21 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ptlrpc/client.c b/drivers/staging/lustre/lustre/ptlrpc/client.c
index 476435633694..71bb563765cc 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/client.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/client.c
@@ -2916,7 +2916,7 @@ int ptlrpc_replay_req(struct ptlrpc_request *req)
  */
 void ptlrpc_abort_inflight(struct obd_import *imp)
 {
-	struct ptlrpc_request *req, *n;
+	struct ptlrpc_request *req;
 
 	/*
 	 * Make sure that no new requests get processed for this import.
@@ -2930,7 +2930,7 @@ void ptlrpc_abort_inflight(struct obd_import *imp)
 	 * locked?  Also, how do we know if the requests on the list are
 	 * being freed at this time?
 	 */
-	list_for_each_entry_safe(req, n, &imp->imp_sending_list, rq_list) {
+	list_for_each_entry(req, &imp->imp_sending_list, rq_list) {
 		DEBUG_REQ(D_RPCTRACE, req, "inflight");
 
 		spin_lock(&req->rq_lock);
@@ -2942,7 +2942,7 @@ void ptlrpc_abort_inflight(struct obd_import *imp)
 		spin_unlock(&req->rq_lock);
 	}
 
-	list_for_each_entry_safe(req, n, &imp->imp_delayed_list, rq_list) {
+	list_for_each_entry(req, &imp->imp_delayed_list, rq_list) {
 		DEBUG_REQ(D_RPCTRACE, req, "aborting waiting req");
 
 		spin_lock(&req->rq_lock);
@@ -2969,9 +2969,9 @@ void ptlrpc_abort_inflight(struct obd_import *imp)
  */
 void ptlrpc_abort_set(struct ptlrpc_request_set *set)
 {
-	struct ptlrpc_request *req, *tmp;
+	struct ptlrpc_request *req;
 
-	list_for_each_entry_safe(req, tmp, &set->set_requests, rq_set_chain) {
+	list_for_each_entry(req, &set->set_requests, rq_set_chain) {
 		spin_lock(&req->rq_lock);
 		if (req->rq_phase != RQ_PHASE_RPC) {
 			spin_unlock(&req->rq_lock);
diff --git a/drivers/staging/lustre/lustre/ptlrpc/import.c b/drivers/staging/lustre/lustre/ptlrpc/import.c
index db4ed6dbf362..26a976865fbd 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/import.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/import.c
@@ -244,11 +244,11 @@ ptlrpc_inflight_deadline(struct ptlrpc_request *req, time64_t now)
 static unsigned int ptlrpc_inflight_timeout(struct obd_import *imp)
 {
 	time64_t now = ktime_get_real_seconds();
-	struct ptlrpc_request *req, *n;
+	struct ptlrpc_request *req;
 	unsigned int timeout = 0;
 
 	spin_lock(&imp->imp_lock);
-	list_for_each_entry_safe(req, n, &imp->imp_sending_list, rq_list)
+	list_for_each_entry(req, &imp->imp_sending_list, rq_list)
 		timeout = max(ptlrpc_inflight_deadline(req, now), timeout);
 
 	spin_unlock(&imp->imp_lock);
@@ -263,7 +263,7 @@ static unsigned int ptlrpc_inflight_timeout(struct obd_import *imp)
  */
 void ptlrpc_invalidate_import(struct obd_import *imp)
 {
-	struct ptlrpc_request *req, *n;
+	struct ptlrpc_request *req;
 	unsigned int timeout;
 	int rc;
 
@@ -335,13 +335,13 @@ void ptlrpc_invalidate_import(struct obd_import *imp)
 				 */
 				rc = 0;
 			} else {
-				list_for_each_entry_safe(req, n,
-							 &imp->imp_sending_list, rq_list) {
+				list_for_each_entry(req, &imp->imp_sending_list,
+						    rq_list) {
 					DEBUG_REQ(D_ERROR, req,
 						  "still on sending list");
 				}
-				list_for_each_entry_safe(req, n,
-							 &imp->imp_delayed_list, rq_list) {
+				list_for_each_entry(req, &imp->imp_delayed_list,
+						    rq_list) {
 					DEBUG_REQ(D_ERROR, req,
 						  "still on delayed list");
 				}
diff --git a/drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c b/drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c
index f0ac2962d64a..c295e9943bf7 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c
@@ -200,12 +200,12 @@ ptlrpcd_select_pc(struct ptlrpc_request *req)
 static int ptlrpcd_steal_rqset(struct ptlrpc_request_set *des,
 			       struct ptlrpc_request_set *src)
 {
-	struct ptlrpc_request *req, *tmp;
+	struct ptlrpc_request *req;
 	int rc = 0;
 
 	spin_lock(&src->set_new_req_lock);
 	if (likely(!list_empty(&src->set_new_requests))) {
-		list_for_each_entry_safe(req, tmp, &src->set_new_requests, rq_set_chain)
+		list_for_each_entry(req, &src->set_new_requests, rq_set_chain)
 			req->rq_set = des;
 
 		list_splice_init(&src->set_new_requests, &des->set_requests);
diff --git a/drivers/staging/lustre/lustre/ptlrpc/recover.c b/drivers/staging/lustre/lustre/ptlrpc/recover.c
index af672ab5b212..f33e4c541a17 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/recover.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/recover.c
@@ -66,7 +66,7 @@ void ptlrpc_initiate_recovery(struct obd_import *imp)
 int ptlrpc_replay_next(struct obd_import *imp, int *inflight)
 {
 	int rc = 0;
-	struct ptlrpc_request *req = NULL, *pos;
+	struct ptlrpc_request *req = NULL;
 	u64 last_transno;
 
 	*inflight = 0;
@@ -120,8 +120,8 @@ int ptlrpc_replay_next(struct obd_import *imp, int *inflight)
 	if (!req) {
 		struct ptlrpc_request *tmp;
 
-		list_for_each_entry_safe(tmp, pos, &imp->imp_replay_list,
-					 rq_replay_list) {
+		list_for_each_entry(tmp, &imp->imp_replay_list,
+				    rq_replay_list) {
 			if (tmp->rq_transno > last_transno) {
 				req = tmp;
 				break;
@@ -172,7 +172,7 @@ int ptlrpc_replay_next(struct obd_import *imp, int *inflight)
  */
 int ptlrpc_resend(struct obd_import *imp)
 {
-	struct ptlrpc_request *req, *next;
+	struct ptlrpc_request *req;
 
 	/* As long as we're in recovery, nothing should be added to the sending
 	 * list, so we don't need to hold the lock during this iteration and
@@ -186,7 +186,7 @@ int ptlrpc_resend(struct obd_import *imp)
 		return -1;
 	}
 
-	list_for_each_entry_safe(req, next, &imp->imp_sending_list, rq_list) {
+	list_for_each_entry(req, &imp->imp_sending_list, rq_list) {
 		LASSERTF((long)req > PAGE_SIZE && req != LP_POISON,
 			 "req %p bad\n", req);
 		LASSERTF(req->rq_type != LI_POISON, "req %p freed\n", req);
@@ -211,10 +211,10 @@ int ptlrpc_resend(struct obd_import *imp)
  */
 void ptlrpc_wake_delayed(struct obd_import *imp)
 {
-	struct ptlrpc_request *req, *pos;
+	struct ptlrpc_request *req;
 
 	spin_lock(&imp->imp_lock);
-	list_for_each_entry_safe(req, pos, &imp->imp_delayed_list, rq_list) {
+	list_for_each_entry(req, &imp->imp_delayed_list, rq_list) {
 		DEBUG_REQ(D_HA, req, "waking (set %p):", req->rq_set);
 		ptlrpc_client_wake_req(req);
 	}
