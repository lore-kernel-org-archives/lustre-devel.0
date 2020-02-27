From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:12:30 -0500
Subject: [lustre-devel] [PATCH 282/622] lustre: ptlrpc: Fix style issues for
 service.c
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-283-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Arshad Hussain <arshad.super@gmail.com>

This patch fixes issues reported by checkpatch
for file fs/lustre/ptlrpc/service.c

WC-bug-id: https://jira.whamcloud.com/browse/LU-6142
Lustre-commit: cb82520d2474 ("LU-6142 ptlrpc: Fix style issues for service.c")
Signed-off-by: Arshad Hussain <arshad.super@gmail.com>
Reviewed-on: https://review.whamcloud.com/34605
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Ben Evans <bevans@cray.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ptlrpc/service.c | 159 +++++++++++++++++++++++++++++----------------
 1 file changed, 102 insertions(+), 57 deletions(-)

diff --git a/fs/lustre/ptlrpc/service.c b/fs/lustre/ptlrpc/service.c
index 362102b..1513f51 100644
--- a/fs/lustre/ptlrpc/service.c
+++ b/fs/lustre/ptlrpc/service.c
@@ -145,7 +145,8 @@ static int ptlrpc_grow_req_bufs(struct ptlrpc_service_part *svcpt, int post)
 	spin_unlock(&svcpt->scp_lock);
 
 	for (i = 0; i < svc->srv_nbuf_per_group; i++) {
-		/* NB: another thread might have recycled enough rqbds, we
+		/*
+		 * NB: another thread might have recycled enough rqbds, we
 		 * need to make sure it wouldn't over-allocate, see LU-1212.
 		 */
 		if (svcpt->scp_nrqbds_posted >= svc->srv_nbuf_per_group ||
@@ -321,7 +322,8 @@ static int ptlrpc_server_post_idle_rqbds(struct ptlrpc_service_part *svcpt)
 	svcpt->scp_nrqbds_posted--;
 	list_move_tail(&rqbd->rqbd_list, &svcpt->scp_rqbd_idle);
 
-	/* Don't complain if no request buffers are posted right now; LNET
+	/*
+	 * Don't complain if no request buffers are posted right now; LNET
 	 * won't drop requests because we set the portal lazy!
 	 */
 
@@ -362,13 +364,15 @@ static void ptlrpc_server_nthreads_check(struct ptlrpc_service *svc,
 	init = PTLRPC_NTHRS_INIT + (svc->srv_ops.so_hpreq_handler != NULL);
 	init = max_t(int, init, tc->tc_nthrs_init);
 
-	/* NB: please see comments in lustre_lnet.h for definition
+	/*
+	 * NB: please see comments in lustre_lnet.h for definition
 	 * details of these members
 	 */
 	LASSERT(tc->tc_nthrs_max != 0);
 
 	if (tc->tc_nthrs_user != 0) {
-		/* In case there is a reason to test a service with many
+		/*
+		 * In case there is a reason to test a service with many
 		 * threads, we give a less strict check here, it can
 		 * be up to 8 * nthrs_max
 		 */
@@ -380,7 +384,8 @@ static void ptlrpc_server_nthreads_check(struct ptlrpc_service *svc,
 
 	total = tc->tc_nthrs_max;
 	if (tc->tc_nthrs_base == 0) {
-		/* don't care about base threads number per partition,
+		/*
+		 * don't care about base threads number per partition,
 		 * this is most for non-affinity service
 		 */
 		nthrs = total / svc->srv_ncpts;
@@ -391,7 +396,8 @@ static void ptlrpc_server_nthreads_check(struct ptlrpc_service *svc,
 	if (svc->srv_ncpts == 1) {
 		int i;
 
-		/* NB: Increase the base number if it's single partition
+		/*
+		 * NB: Increase the base number if it's single partition
 		 * and total number of cores/HTs is larger or equal to 4.
 		 * result will always < 2 * nthrs_base
 		 */
@@ -419,7 +425,8 @@ static void ptlrpc_server_nthreads_check(struct ptlrpc_service *svc,
 		 */
 		/* weight is # of HTs */
 		preempt_disable();
-		if (cpumask_weight(topology_sibling_cpumask(smp_processor_id())) > 1) {
+		if (cpumask_weight
+		    (topology_sibling_cpumask(smp_processor_id())) > 1) {
 			/* depress thread factor for hyper-thread */
 			factor = factor - (factor >> 1) + (factor >> 3);
 		}
@@ -511,7 +518,8 @@ static int ptlrpc_service_part_init(struct ptlrpc_service *svc,
 
 	timer_setup(&svcpt->scp_at_timer, ptlrpc_at_timer, 0);
 
-	/* At SOW, service time should be quick; 10s seems generous. If client
+	/*
+	 * At SOW, service time should be quick; 10s seems generous. If client
 	 * timeout is less than this, we'll be sending an early reply.
 	 */
 	at_init(&svcpt->scp_at_estimate, 10, 0);
@@ -520,7 +528,8 @@ static int ptlrpc_service_part_init(struct ptlrpc_service *svc,
 	svcpt->scp_service = svc;
 	/* Now allocate the request buffers, but don't post them now */
 	rc = ptlrpc_grow_req_bufs(svcpt, 0);
-	/* We shouldn't be under memory pressure at startup, so
+	/*
+	 * We shouldn't be under memory pressure at startup, so
 	 * fail if we can't allocate all our buffers at this time.
 	 */
 	if (rc != 0)
@@ -719,7 +728,8 @@ static void ptlrpc_server_free_request(struct ptlrpc_request *req)
 	LASSERT(atomic_read(&req->rq_refcount) == 0);
 	LASSERT(list_empty(&req->rq_timed_list));
 
-	/* DEBUG_REQ() assumes the reply state of a request with a valid
+	/*
+	 * DEBUG_REQ() assumes the reply state of a request with a valid
 	 * ref will not be destroyed until that reference is dropped.
 	 */
 	ptlrpc_req_drop_rs(req);
@@ -727,7 +737,8 @@ static void ptlrpc_server_free_request(struct ptlrpc_request *req)
 	sptlrpc_svc_ctx_decref(req);
 
 	if (req != &req->rq_rqbd->rqbd_req) {
-		/* NB request buffers use an embedded
+		/*
+		 * NB request buffers use an embedded
 		 * req if the incoming req unlinked the
 		 * MD; this isn't one of them!
 		 */
@@ -751,7 +762,8 @@ static void ptlrpc_server_drop_request(struct ptlrpc_request *req)
 
 	if (req->rq_at_linked) {
 		spin_lock(&svcpt->scp_at_lock);
-		/* recheck with lock, in case it's unlinked by
+		/*
+		 * recheck with lock, in case it's unlinked by
 		 * ptlrpc_at_check_timed()
 		 */
 		if (likely(req->rq_at_linked))
@@ -777,7 +789,8 @@ static void ptlrpc_server_drop_request(struct ptlrpc_request *req)
 		list_move_tail(&rqbd->rqbd_list, &svcpt->scp_hist_rqbds);
 		svcpt->scp_hist_nrqbds++;
 
-		/* cull some history?
+		/*
+		 * cull some history?
 		 * I expect only about 1 or 2 rqbds need to be recycled here
 		 */
 		while (svcpt->scp_hist_nrqbds > svc->srv_hist_nrqbds_cpt_max) {
@@ -788,11 +801,12 @@ static void ptlrpc_server_drop_request(struct ptlrpc_request *req)
 			list_del(&rqbd->rqbd_list);
 			svcpt->scp_hist_nrqbds--;
 
-			/* remove rqbd's reqs from svc's req history while
+			/*
+			 * remove rqbd's reqs from svc's req history while
 			 * I've got the service lock
 			 */
 			list_for_each_entry(req, &rqbd->rqbd_reqs, rq_list) {
-				/* Track the highest culled req seq */
+				/* Track the highest culled */
 				if (req->rq_history_seq >
 				    svcpt->scp_hist_seq_culled) {
 					svcpt->scp_hist_seq_culled =
@@ -980,7 +994,8 @@ static int ptlrpc_at_add_timed(struct ptlrpc_request *req)
 
 	div_u64_rem(req->rq_deadline, array->paa_size, &index);
 	if (array->paa_reqs_count[index] > 0) {
-		/* latest rpcs will have the latest deadlines in the list,
+		/*
+		 * latest rpcs will have the latest deadlines in the list,
 		 * so search backward.
 		 */
 		list_for_each_entry_reverse(rq, &array->paa_reqs_array[index],
@@ -1043,7 +1058,8 @@ static int ptlrpc_at_send_early_reply(struct ptlrpc_request *req)
 	time64_t newdl;
 	int rc;
 
-	/* deadline is when the client expects us to reply, margin is the
+	/*
+	 * deadline is when the client expects us to reply, margin is the
 	 * difference between clients' and servers' expectations
 	 */
 	DEBUG_REQ(D_ADAPTTO, req,
@@ -1057,14 +1073,15 @@ static int ptlrpc_at_send_early_reply(struct ptlrpc_request *req)
 
 	if (olddl < 0) {
 		DEBUG_REQ(D_WARNING, req,
-			  "Already past deadline (%+lds), not sending early reply. Consider increasing at_early_margin (%d)?",
-			  olddl, at_early_margin);
+			  "Already past deadline (%+llds), not sending early reply. Consider increasing at_early_margin (%d)?",
+			  (s64)olddl, at_early_margin);
 
 		/* Return an error so we're not re-added to the timed list. */
 		return -ETIMEDOUT;
 	}
 
-	if (!(lustre_msghdr_get_flags(req->rq_reqmsg) & MSGHDR_AT_SUPPORT)) {
+	if (!(lustre_msghdr_get_flags(req->rq_reqmsg) &
+	     MSGHDR_AT_SUPPORT)) {
 		DEBUG_REQ(D_INFO, req,
 			  "Wanted to ask client for more time, but no AT support");
 		return -ENOSYS;
@@ -1082,7 +1099,8 @@ static int ptlrpc_at_send_early_reply(struct ptlrpc_request *req)
 		    ktime_get_real_seconds() - req->rq_arrival_time.tv_sec);
 	newdl = req->rq_arrival_time.tv_sec + at_get(&svcpt->scp_at_estimate);
 
-	/* Check to see if we've actually increased the deadline -
+	/*
+	 * Check to see if we've actually increased the deadline -
 	 * we may be past adaptive_max
 	 */
 	if (req->rq_deadline >= newdl) {
@@ -1159,7 +1177,8 @@ static int ptlrpc_at_send_early_reply(struct ptlrpc_request *req)
 		DEBUG_REQ(D_ERROR, req, "Early reply send failed %d", rc);
 	}
 
-	/* Free the (early) reply state from lustre_pack_reply.
+	/*
+	 * Free the (early) reply state from lustre_pack_reply.
 	 * (ptlrpc_send_reply takes it's own rs ref, so this is safe here)
 	 */
 	ptlrpc_req_drop_rs(reqcopy);
@@ -1175,7 +1194,8 @@ static int ptlrpc_at_send_early_reply(struct ptlrpc_request *req)
 	return rc;
 }
 
-/* Send early replies to everybody expiring within at_early_margin
+/*
+ * Send early replies to everybody expiring within at_early_margin
  * asking for at_extra time
  */
 static void ptlrpc_at_check_timed(struct ptlrpc_service_part *svcpt)
@@ -1211,7 +1231,8 @@ static void ptlrpc_at_check_timed(struct ptlrpc_service_part *svcpt)
 		return;
 	}
 
-	/* We're close to a timeout, and we don't know how much longer the
+	/*
+	 * We're close to a timeout, and we don't know how much longer the
 	 * server will take. Send early replies to everyone expiring soon.
 	 */
 	INIT_LIST_HEAD(&work_list);
@@ -1258,7 +1279,8 @@ static void ptlrpc_at_check_timed(struct ptlrpc_service_part *svcpt)
 	       "timeout in %+ds, asking for %d secs on %d early replies\n",
 	       first, at_extra, counter);
 	if (first < 0) {
-		/* We're already past request deadlines before we even get a
+		/*
+		 * We're already past request deadlines before we even get a
 		 * chance to send early replies
 		 */
 		LCONSOLE_WARN("%s: This server is not able to keep up with request traffic (cpu-bound).\n",
@@ -1269,7 +1291,8 @@ static void ptlrpc_at_check_timed(struct ptlrpc_service_part *svcpt)
 		      at_get(&svcpt->scp_at_estimate), delay);
 	}
 
-	/* we took additional refcount so entries can't be deleted from list, no
+	/*
+	 * we took additional refcount so entries can't be deleted from list, no
 	 * locking is needed
 	 */
 	while ((rq = list_first_entry_or_null(&work_list,
@@ -1285,8 +1308,10 @@ static void ptlrpc_at_check_timed(struct ptlrpc_service_part *svcpt)
 }
 
 /**
+ *
  * Put the request to the export list if the request may become
  * a high priority one.
+
  */
 static int ptlrpc_server_hpreq_init(struct ptlrpc_service_part *svcpt,
 				    struct ptlrpc_request *req)
@@ -1300,7 +1325,8 @@ static int ptlrpc_server_hpreq_init(struct ptlrpc_service_part *svcpt,
 		LASSERT(rc == 0);
 	}
 	if (req->rq_export && req->rq_ops) {
-		/* Perform request specific check. We should do this check
+		/*
+		 * Perform request specific check. We should do this check
 		 * before the request is added into exp_hp_rpcs list otherwise
 		 * it may hit swab race at LU-1044.
 		 */
@@ -1310,9 +1336,10 @@ static int ptlrpc_server_hpreq_init(struct ptlrpc_service_part *svcpt,
 				req->rq_status = rc;
 				ptlrpc_error(req);
 			}
-			/** can only return error,
+			/*
+			 * can only return error,
 			 * 0 for normal request,
-			 *  or 1 for high priority request
+			 * or 1 for high priority request
 			 */
 			LASSERT(rc <= 1);
 		}
@@ -1331,7 +1358,8 @@ static int ptlrpc_server_hpreq_init(struct ptlrpc_service_part *svcpt,
 static void ptlrpc_server_hpreq_fini(struct ptlrpc_request *req)
 {
 	if (req->rq_export && req->rq_ops) {
-		/* refresh lock timeout again so that client has more
+		/*
+		 * refresh lock timeout again so that client has more
 		 * room to send lock cancel RPC.
 		 */
 		if (req->rq_ops->hpreq_fini)
@@ -1357,7 +1385,7 @@ static int ptlrpc_server_request_add(struct ptlrpc_service_part  *svcpt,
 	return 0;
 }
 
-/**
+/*
  * Allow to handle high priority request
  * User can call it w/o any lock but need to hold
  * ptlrpc_service_part::scp_req_lock to get reliable result
@@ -1521,7 +1549,8 @@ static int ptlrpc_server_handle_req_in(struct ptlrpc_service_part *svcpt,
 			       struct ptlrpc_request, rq_list);
 	list_del_init(&req->rq_list);
 	svcpt->scp_nreqs_incoming--;
-	/* Consider this still a "queued" request as far as stats are
+	/*
+	 * Consider this still a "queued" request as far as stats are
 	 * concerned
 	 */
 	spin_unlock(&svcpt->scp_lock);
@@ -1556,7 +1585,7 @@ static int ptlrpc_server_handle_req_in(struct ptlrpc_service_part *svcpt,
 
 	rc = lustre_unpack_req_ptlrpc_body(req, MSG_PTLRPC_BODY_OFF);
 	if (rc) {
-		CERROR("error unpacking ptlrpc body: ptl %d from %s x%llu\n",
+		CERROR("error unpacking ptlrpc body: ptl %d from %s x %llu\n",
 		       svc->srv_req_portal, libcfs_id2str(req->rq_peer),
 		       req->rq_xid);
 		goto err_req;
@@ -1615,8 +1644,9 @@ static int ptlrpc_server_handle_req_in(struct ptlrpc_service_part *svcpt,
 	/* Set rpc server deadline and add it to the timed list */
 	deadline = (lustre_msghdr_get_flags(req->rq_reqmsg) &
 		    MSGHDR_AT_SUPPORT) ?
-		   /* The max time the client expects us to take */
-		   lustre_msg_get_timeout(req->rq_reqmsg) : obd_timeout;
+		    /* The max time the client expects us to take */
+		    lustre_msg_get_timeout(req->rq_reqmsg) : obd_timeout;
+
 	req->rq_deadline = req->rq_arrival_time.tv_sec + deadline;
 	if (unlikely(deadline == 0)) {
 		DEBUG_REQ(D_ERROR, req, "Dropping request with 0 timeout");
@@ -1625,11 +1655,12 @@ static int ptlrpc_server_handle_req_in(struct ptlrpc_service_part *svcpt,
 
 	req->rq_svc_thread = thread;
 	if (thread) {
-		/* initialize request session, it is needed for request
+		/*
+		 * initialize request session, it is needed for request
 		 * processing by target
 		 */
-		rc = lu_context_init(&req->rq_session,
-				     LCT_SERVER_SESSION | LCT_NOREF);
+		rc = lu_context_init(&req->rq_session, LCT_SERVER_SESSION |
+						       LCT_NOREF);
 		if (rc) {
 			CERROR("%s: failure to initialize session: rc = %d\n",
 			       thread->t_name, rc);
@@ -1710,7 +1741,8 @@ static int ptlrpc_server_handle_request(struct ptlrpc_service_part *svcpt,
 			goto put_conn;
 	}
 
-	/* Discard requests queued for longer than the deadline.
+	/*
+	 * Discard requests queued for longer than the deadline.
 	 * The deadline is increased if we send an early reply.
 	 */
 	if (ktime_get_real_seconds() > request->rq_deadline) {
@@ -1827,7 +1859,8 @@ static int ptlrpc_handle_rs(struct ptlrpc_reply_state *rs)
 	list_del_init(&rs->rs_exp_list);
 	spin_unlock(&exp->exp_lock);
 
-	/* The disk commit callback holds exp_uncommitted_replies_lock while it
+	/*
+	 * The disk commit callback holds exp_uncommitted_replies_lock while it
 	 * iterates over newly committed replies, removing them from
 	 * exp_uncommitted_replies.  It then drops this lock and schedules the
 	 * replies it found for handling here.
@@ -1864,7 +1897,8 @@ static int ptlrpc_handle_rs(struct ptlrpc_reply_state *rs)
 	rs->rs_nlocks = 0;		/* locks still on rs_locks! */
 
 	if (nlocks == 0 && !been_handled) {
-		/* If we see this, we should already have seen the warning
+		/*
+		 * If we see this, we should already have seen the warning
 		 * in mds_steal_ack_locks()
 		 */
 		CDEBUG(D_HA,
@@ -1916,7 +1950,8 @@ static void ptlrpc_check_rqbd_pool(struct ptlrpc_service_part *svcpt)
 
 	/* NB I'm not locking; just looking. */
 
-	/* CAVEAT EMPTOR: We might be allocating buffers here because we've
+	/*
+	 * CAVEAT EMPTOR: We might be allocating buffers here because we've
 	 * allowed the request history to grow out of control.  We could put a
 	 * sanity check on that here and cull some history if we need the
 	 * space.
@@ -2194,7 +2229,8 @@ static int ptlrpc_main(void *arg)
 	LASSERT(svcpt->scp_nthrs_starting == 1);
 	svcpt->scp_nthrs_starting--;
 
-	/* SVC_STOPPING may already be set here if someone else is trying
+	/*
+	 * SVC_STOPPING may already be set here if someone else is trying
 	 * to stop the service while this new thread has been dynamically
 	 * forked. We still set SVC_RUNNING to let our creator know that
 	 * we are now running, however we will exit as soon as possible
@@ -2254,7 +2290,8 @@ static int ptlrpc_main(void *arg)
 
 		if (ptlrpc_rqbd_pending(svcpt) &&
 		    ptlrpc_server_post_idle_rqbds(svcpt) < 0) {
-			/* I just failed to repost request buffers.
+			/*
+			 * I just failed to repost request buffers.
 			 * Wait for a timeout (unless something else
 			 * happens) before I try again
 			 */
@@ -2262,8 +2299,8 @@ static int ptlrpc_main(void *arg)
 			CDEBUG(D_RPCTRACE, "Posted buffers: %d\n",
 			       svcpt->scp_nrqbds_posted);
 		}
-
-		/* If the number of threads has been tuned downward and this
+		/*
+		 * If the number of threads has been tuned downward and this
 		 * thread should be stopped, then stop in reverse order so the
 		 * the threads always have contiguous thread index values.
 		 */
@@ -2285,7 +2322,6 @@ static int ptlrpc_main(void *arg)
 out:
 	CDEBUG(D_RPCTRACE, "%s: service thread [%p:%u] %d exiting: rc = %d\n",
 	       thread->t_name, thread, thread->t_pid, thread->t_id, rc);
-
 	spin_lock(&svcpt->scp_lock);
 	if (thread_test_and_clear_flags(thread, SVC_STARTING))
 		svcpt->scp_nthrs_starting--;
@@ -2546,7 +2582,8 @@ int ptlrpc_start_thread(struct ptlrpc_service_part *svcpt, int wait)
 	}
 
 	if (svcpt->scp_nthrs_starting != 0) {
-		/* serialize starting because some modules (obdfilter)
+		/*
+		 * serialize starting because some modules (obdfilter)
 		 * might require unique and contiguous t_id
 		 */
 		LASSERT(svcpt->scp_nthrs_starting == 1);
@@ -2589,7 +2626,8 @@ int ptlrpc_start_thread(struct ptlrpc_service_part *svcpt, int wait)
 		spin_lock(&svcpt->scp_lock);
 		--svcpt->scp_nthrs_starting;
 		if (thread_is_stopping(thread)) {
-			/* this ptlrpc_thread is being handled
+			/*
+			 * this ptlrpc_thread is being handled
 			 * by ptlrpc_svcpt_stop_threads now
 			 */
 			thread_add_flags(thread, SVC_STOPPED);
@@ -2616,7 +2654,7 @@ int ptlrpc_start_thread(struct ptlrpc_service_part *svcpt, int wait)
 int ptlrpc_hr_init(void)
 {
 	struct ptlrpc_hr_partition *hrp;
-	struct ptlrpc_hr_thread	*hrt;
+	struct ptlrpc_hr_thread *hrt;
 	int rc;
 	int i;
 	int j;
@@ -2736,7 +2774,8 @@ static void ptlrpc_wait_replies(struct ptlrpc_service_part *svcpt)
 	int rc;
 	int i;
 
-	/* All history will be culled when the next request buffer is
+	/*
+	 * All history will be culled when the next request buffer is
 	 * freed in ptlrpc_service_purge_all()
 	 */
 	svc->srv_hist_nrqbds_cpt_max = 0;
@@ -2748,7 +2787,8 @@ static void ptlrpc_wait_replies(struct ptlrpc_service_part *svcpt)
 		if (!svcpt->scp_service)
 			break;
 
-		/* Unlink all the request buffers.  This forces a 'final'
+		/*
+		 * Unlink all the request buffers.  This forces a 'final'
 		 * event with its 'unlink' flag set for each posted rqbd
 		 */
 		list_for_each_entry(rqbd, &svcpt->scp_rqbd_posted,
@@ -2762,13 +2802,15 @@ static void ptlrpc_wait_replies(struct ptlrpc_service_part *svcpt)
 		if (!svcpt->scp_service)
 			break;
 
-		/* Wait for the network to release any buffers
+		/*
+		 * Wait for the network to release any buffers
 		 * it's currently filling
 		 */
 		spin_lock(&svcpt->scp_lock);
 		while (svcpt->scp_nrqbds_posted != 0) {
 			spin_unlock(&svcpt->scp_lock);
-			/* Network access will complete in finite time but
+			/*
+			 * Network access will complete in finite time but
 			 * the HUGE timeout lets us CWARN for visibility
 			 * of sluggish LNDs
 			 */
@@ -2811,7 +2853,8 @@ static void ptlrpc_wait_replies(struct ptlrpc_service_part *svcpt)
 		}
 		spin_unlock(&svcpt->scp_rep_lock);
 
-		/* purge the request queue.  NB No new replies (rqbds
+		/*
+		 * purge the request queue.  NB No new replies (rqbds
 		 * all unlinked) and no service threads, so I'm the only
 		 * thread noodling the request queue now
 		 */
@@ -2831,12 +2874,14 @@ static void ptlrpc_wait_replies(struct ptlrpc_service_part *svcpt)
 		LASSERT(list_empty(&svcpt->scp_rqbd_posted));
 		LASSERT(svcpt->scp_nreqs_incoming == 0);
 		LASSERT(svcpt->scp_nreqs_active == 0);
-		/* history should have been culled by
+		/*
+		 * history should have been culled by
 		 * ptlrpc_server_finish_request
 		 */
 		LASSERT(svcpt->scp_hist_nrqbds == 0);
 
-		/* Now free all the request buffers since nothing
+		/*
+		 * Now free all the request buffers since nothing
 		 * references them any more...
 		 */
 
-- 
1.8.3.1
