From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:12:08 -0500
Subject: [lustre-devel] [PATCH 260/622] lustre: ptlrpc: allow stopping
 threads above threads_max
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-261-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Andreas Dilger <adilger@whamcloud.com>

If a service "threads_max" parameter is set below the number of
running threads, stop each highest-numbered running thread until
the running thread count is below threads_max.  Stopping nly the
last thread ensures the thread t_id numbers are always contiguous
rather than having gaps.  If the threads are started again they
will again be assigned contiguous t_id values.

Each thread is stopped only after it has finished processing an
incoming request, so running threads may not immediately stop
when the tunable is changed.

Also fix function declarations in file to match proper coding style.

WC-bug-id: https://jira.whamcloud.com/browse/LU-947
Lustre-commit: 183cb1e3cdd2 ("LU-947 ptlrpc: allow stopping threads above threads_max")
Signed-off-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/34400
Reviewed-by: Wang Shilong <wshilong@ddn.com>
Reviewed-by: Hongchao Zhang <hongchao@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ptlrpc/service.c | 124 +++++++++++++++++++++++++--------------------
 1 file changed, 69 insertions(+), 55 deletions(-)

diff --git a/fs/lustre/ptlrpc/service.c b/fs/lustre/ptlrpc/service.c
index 7bc578c..362102b 100644
--- a/fs/lustre/ptlrpc/service.c
+++ b/fs/lustre/ptlrpc/service.c
@@ -106,8 +106,7 @@
 	return rqbd;
 }
 
-static void
-ptlrpc_free_rqbd(struct ptlrpc_request_buffer_desc *rqbd)
+static void ptlrpc_free_rqbd(struct ptlrpc_request_buffer_desc *rqbd)
 {
 	struct ptlrpc_service_part *svcpt = rqbd->rqbd_svcpt;
 
@@ -123,8 +122,7 @@
 	kfree(rqbd);
 }
 
-static int
-ptlrpc_grow_req_bufs(struct ptlrpc_service_part *svcpt, int post)
+static int ptlrpc_grow_req_bufs(struct ptlrpc_service_part *svcpt, int post)
 {
 	struct ptlrpc_service *svc = svcpt->scp_service;
 	struct ptlrpc_request_buffer_desc *rqbd;
@@ -230,8 +228,8 @@ struct ptlrpc_hr_service {
 /**
  * Choose an hr thread to dispatch requests to.
  */
-static struct ptlrpc_hr_thread *
-ptlrpc_hr_select(struct ptlrpc_service_part *svcpt)
+static
+struct ptlrpc_hr_thread *ptlrpc_hr_select(struct ptlrpc_service_part *svcpt)
 {
 	struct ptlrpc_hr_partition *hrp;
 	unsigned int rotor;
@@ -270,8 +268,7 @@ void ptlrpc_dispatch_difficult_reply(struct ptlrpc_reply_state *rs)
 	wake_up(&hrt->hrt_waitq);
 }
 
-void
-ptlrpc_schedule_difficult_reply(struct ptlrpc_reply_state *rs)
+void ptlrpc_schedule_difficult_reply(struct ptlrpc_reply_state *rs)
 {
 	assert_spin_locked(&rs->rs_svcpt->scp_rep_lock);
 	assert_spin_locked(&rs->rs_lock);
@@ -288,8 +285,7 @@ void ptlrpc_dispatch_difficult_reply(struct ptlrpc_reply_state *rs)
 }
 EXPORT_SYMBOL(ptlrpc_schedule_difficult_reply);
 
-static int
-ptlrpc_server_post_idle_rqbds(struct ptlrpc_service_part *svcpt)
+static int ptlrpc_server_post_idle_rqbds(struct ptlrpc_service_part *svcpt)
 {
 	struct ptlrpc_request_buffer_desc *rqbd;
 	int rc;
@@ -345,9 +341,8 @@ static void ptlrpc_at_timer(struct timer_list *t)
 	wake_up(&svcpt->scp_waitq);
 }
 
-static void
-ptlrpc_server_nthreads_check(struct ptlrpc_service *svc,
-			     struct ptlrpc_service_conf *conf)
+static void ptlrpc_server_nthreads_check(struct ptlrpc_service *svc,
+					 struct ptlrpc_service_conf *conf)
 {
 	struct ptlrpc_service_thr_conf *tc = &conf->psc_thr;
 	unsigned int init;
@@ -457,9 +452,8 @@ static void ptlrpc_at_timer(struct timer_list *t)
 /**
  * Initialize percpt data for a service
  */
-static int
-ptlrpc_service_part_init(struct ptlrpc_service *svc,
-			 struct ptlrpc_service_part *svcpt, int cpt)
+static int ptlrpc_service_part_init(struct ptlrpc_service *svc,
+				    struct ptlrpc_service_part *svcpt, int cpt)
 {
 	struct ptlrpc_at_array *array;
 	int size;
@@ -549,10 +543,9 @@ static void ptlrpc_at_timer(struct timer_list *t)
  * This includes starting serving threads , allocating and posting rqbds and
  * so on.
  */
-struct ptlrpc_service *
-ptlrpc_register_service(struct ptlrpc_service_conf *conf,
-			struct kset *parent,
-			struct dentry *debugfs_entry)
+struct ptlrpc_service *ptlrpc_register_service(struct ptlrpc_service_conf *conf,
+					       struct kset *parent,
+					       struct dentry *debugfs_entry)
 {
 	struct ptlrpc_service_cpt_conf *cconf = &conf->psc_cpt;
 	struct ptlrpc_service *service;
@@ -1019,8 +1012,7 @@ static int ptlrpc_at_add_timed(struct ptlrpc_request *req)
 	return 0;
 }
 
-static void
-ptlrpc_at_remove_timed(struct ptlrpc_request *req)
+static void ptlrpc_at_remove_timed(struct ptlrpc_request *req)
 {
 	struct ptlrpc_at_array *array;
 
@@ -1351,7 +1343,7 @@ static void ptlrpc_server_hpreq_fini(struct ptlrpc_request *req)
 	}
 }
 
-static int ptlrpc_server_request_add(struct ptlrpc_service_part *svcpt,
+static int ptlrpc_server_request_add(struct ptlrpc_service_part  *svcpt,
 				     struct ptlrpc_request *req)
 {
 	int rc;
@@ -1453,8 +1445,9 @@ static bool ptlrpc_server_normal_pending(struct ptlrpc_service_part *svcpt,
  * \see ptlrpc_server_allow_normal
  * \see ptlrpc_server_allow high
  */
-static inline bool
-ptlrpc_server_request_pending(struct ptlrpc_service_part *svcpt, bool force)
+static inline
+bool ptlrpc_server_request_pending(struct ptlrpc_service_part *svcpt,
+				   bool force)
 {
 	return ptlrpc_server_high_pending(svcpt, force) ||
 	       ptlrpc_server_normal_pending(svcpt, force);
@@ -1510,9 +1503,8 @@ static bool ptlrpc_server_normal_pending(struct ptlrpc_service_part *svcpt,
  * All incoming requests pass through here before getting into
  * ptlrpc_server_handle_req later on.
  */
-static int
-ptlrpc_server_handle_req_in(struct ptlrpc_service_part *svcpt,
-			    struct ptlrpc_thread *thread)
+static int ptlrpc_server_handle_req_in(struct ptlrpc_service_part *svcpt,
+				       struct ptlrpc_thread *thread)
 {
 	struct ptlrpc_service *svc = svcpt->scp_service;
 	struct ptlrpc_request *req;
@@ -1668,9 +1660,8 @@ static bool ptlrpc_server_normal_pending(struct ptlrpc_service_part *svcpt,
  * Main incoming request handling logic.
  * Calls handler function from service to do actual processing.
  */
-static int
-ptlrpc_server_handle_request(struct ptlrpc_service_part *svcpt,
-			     struct ptlrpc_thread *thread)
+static int ptlrpc_server_handle_request(struct ptlrpc_service_part *svcpt,
+					struct ptlrpc_thread *thread)
 {
 	struct ptlrpc_service *svc = svcpt->scp_service;
 	struct ptlrpc_request *request;
@@ -1817,8 +1808,7 @@ static bool ptlrpc_server_normal_pending(struct ptlrpc_service_part *svcpt,
 /**
  * An internal function to process a single reply state object.
  */
-static int
-ptlrpc_handle_rs(struct ptlrpc_reply_state *rs)
+static int ptlrpc_handle_rs(struct ptlrpc_reply_state *rs)
 {
 	struct ptlrpc_service_part *svcpt = rs->rs_svcpt;
 	struct ptlrpc_service *svc = svcpt->scp_service;
@@ -1918,8 +1908,7 @@ static bool ptlrpc_server_normal_pending(struct ptlrpc_service_part *svcpt,
 	return 1;
 }
 
-static void
-ptlrpc_check_rqbd_pool(struct ptlrpc_service_part *svcpt)
+static void ptlrpc_check_rqbd_pool(struct ptlrpc_service_part *svcpt)
 {
 	int avail = svcpt->scp_nrqbds_posted;
 	int low_water = test_req_buffer_pressure ? 0 :
@@ -1942,8 +1931,7 @@ static bool ptlrpc_server_normal_pending(struct ptlrpc_service_part *svcpt,
 	}
 }
 
-static inline int
-ptlrpc_threads_enough(struct ptlrpc_service_part *svcpt)
+static inline int ptlrpc_threads_enough(struct ptlrpc_service_part *svcpt)
 {
 	return svcpt->scp_nreqs_active <
 	       svcpt->scp_nthrs_running - 1 -
@@ -1955,8 +1943,7 @@ static bool ptlrpc_server_normal_pending(struct ptlrpc_service_part *svcpt,
  * user can call it w/o any lock but need to hold
  * ptlrpc_service_part::scp_lock to get reliable result
  */
-static inline int
-ptlrpc_threads_increasable(struct ptlrpc_service_part *svcpt)
+static inline int ptlrpc_threads_increasable(struct ptlrpc_service_part *svcpt)
 {
 	return svcpt->scp_nthrs_running +
 	       svcpt->scp_nthrs_starting <
@@ -1966,22 +1953,47 @@ static bool ptlrpc_server_normal_pending(struct ptlrpc_service_part *svcpt,
 /**
  * too many requests and allowed to create more threads
  */
-static inline int
-ptlrpc_threads_need_create(struct ptlrpc_service_part *svcpt)
+static inline int ptlrpc_threads_need_create(struct ptlrpc_service_part *svcpt)
 {
 	return !ptlrpc_threads_enough(svcpt) &&
 		ptlrpc_threads_increasable(svcpt);
 }
 
-static inline int
-ptlrpc_thread_stopping(struct ptlrpc_thread *thread)
+static inline int ptlrpc_thread_stopping(struct ptlrpc_thread *thread)
 {
 	return thread_is_stopping(thread) ||
 	       thread->t_svcpt->scp_service->srv_is_stopping;
 }
 
-static inline int
-ptlrpc_rqbd_pending(struct ptlrpc_service_part *svcpt)
+/* stop the highest numbered thread if there are too many threads running */
+static inline bool ptlrpc_thread_should_stop(struct ptlrpc_thread *thread)
+{
+	struct ptlrpc_service_part *svcpt = thread->t_svcpt;
+
+	return thread->t_id >= svcpt->scp_service->srv_nthrs_cpt_limit &&
+		thread->t_id == svcpt->scp_thr_nextid - 1;
+}
+
+static void ptlrpc_stop_thread(struct ptlrpc_thread *thread)
+{
+	CDEBUG(D_INFO, "Stopping thread %s #%u\n",
+	       thread->t_svcpt->scp_service->srv_thread_name, thread->t_id);
+	thread_add_flags(thread, SVC_STOPPING);
+}
+
+static inline void ptlrpc_thread_stop(struct ptlrpc_thread *thread)
+{
+	struct ptlrpc_service_part *svcpt = thread->t_svcpt;
+
+	spin_lock(&svcpt->scp_lock);
+	if (ptlrpc_thread_should_stop(thread)) {
+		ptlrpc_stop_thread(thread);
+		svcpt->scp_thr_nextid--;
+	}
+	spin_unlock(&svcpt->scp_lock);
+}
+
+static inline int ptlrpc_rqbd_pending(struct ptlrpc_service_part *svcpt)
 {
 	return !list_empty(&svcpt->scp_rqbd_idle) &&
 	       svcpt->scp_rqbd_timeout == 0;
@@ -2250,14 +2262,19 @@ static int ptlrpc_main(void *arg)
 			CDEBUG(D_RPCTRACE, "Posted buffers: %d\n",
 			       svcpt->scp_nrqbds_posted);
 		}
+
+		/* If the number of threads has been tuned downward and this
+		 * thread should be stopped, then stop in reverse order so the
+		 * the threads always have contiguous thread index values.
+		 */
+		if (unlikely(ptlrpc_thread_should_stop(thread)))
+			ptlrpc_thread_stop(thread);
 	}
 
 	ptlrpc_watchdog_disable(&thread->t_watchdog);
 
 out_srv_fini:
-	/*
-	 * deconstruct service specific state created by ptlrpc_start_thread()
-	 */
+	/* deconstruct service thread state created by ptlrpc_start_thread() */
 	if (svc->srv_ops.so_thr_done)
 		svc->srv_ops.so_thr_done(thread);
 
@@ -2266,8 +2283,8 @@ static int ptlrpc_main(void *arg)
 		kfree(env);
 	}
 out:
-	CDEBUG(D_RPCTRACE, "service thread [ %p : %u ] %d exiting: rc %d\n",
-	       thread, thread->t_pid, thread->t_id, rc);
+	CDEBUG(D_RPCTRACE, "%s: service thread [%p:%u] %d exiting: rc = %d\n",
+	       thread->t_name, thread, thread->t_pid, thread->t_id, rc);
 
 	spin_lock(&svcpt->scp_lock);
 	if (thread_test_and_clear_flags(thread, SVC_STARTING))
@@ -2416,11 +2433,8 @@ static void ptlrpc_svcpt_stop_threads(struct ptlrpc_service_part *svcpt)
 
 	spin_lock(&svcpt->scp_lock);
 	/* let the thread know that we would like it to stop asap */
-	list_for_each_entry(thread, &svcpt->scp_threads, t_link) {
-		CDEBUG(D_INFO, "Stopping thread %s #%u\n",
-		       svcpt->scp_service->srv_thread_name, thread->t_id);
-		thread_add_flags(thread, SVC_STOPPING);
-	}
+	list_for_each_entry(thread, &svcpt->scp_threads, t_link)
+		ptlrpc_stop_thread(thread);
 
 	wake_up_all(&svcpt->scp_waitq);
 
-- 
1.8.3.1
