From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Sep 2019 14:55:17 -0400
Subject: [lustre-devel] [PATCH 058/151] lustre: ldlm: migrate the rest of
 the code to 64 bit time
In-Reply-To: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1569869810-23848-59-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Replace the last cfs_time_current_sec() to avoid the overflow
issues in 2038 with ktime_get_real_seconds(). Reduce the jiffies
usage to the bare minimum which is useage for mod_timer() and
schedule_timeout(). This makes the ldlm totally 64 bit time
compliant.

WC-bug-id: https://jira.whamcloud.com/browse/LU-9019
Lustre-commit: e920be681451 ("LU-9019 ldlm: migrate the rest of the code to 64 bit time")
Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-on: https://review.whamcloud.com/29295
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: John L. Hammond <jhammond@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_dlm.h |  4 ++--
 fs/lustre/include/lustre_net.h | 11 +++++------
 fs/lustre/ldlm/ldlm_lock.c     | 10 +++++-----
 fs/lustre/ldlm/ldlm_lockd.c    |  2 +-
 fs/lustre/ldlm/ldlm_request.c  | 14 +++++++-------
 fs/lustre/ldlm/ldlm_resource.c |  8 +++-----
 fs/lustre/ptlrpc/client.c      |  4 ++--
 fs/lustre/ptlrpc/import.c      |  2 +-
 8 files changed, 26 insertions(+), 29 deletions(-)

diff --git a/fs/lustre/include/lustre_dlm.h b/fs/lustre/include/lustre_dlm.h
index 28b5cfa..fbcd981 100644
--- a/fs/lustre/include/lustre_dlm.h
+++ b/fs/lustre/include/lustre_dlm.h
@@ -418,7 +418,7 @@ struct ldlm_namespace {
 	 * \see ldlm_namespace_dump. Increased by 10 seconds every time
 	 * it is called.
 	 */
-	unsigned long		ns_next_dump;
+	time64_t		ns_next_dump;
 
 	/**
 	 * LVB operations for this namespace.
@@ -754,7 +754,7 @@ struct ldlm_lock {
 	 * under this lock.
 	 * \see ost_rw_prolong_locks
 	 */
-	unsigned long			l_callback_timeout;
+	time64_t			l_callback_timeout;
 
 	/** Local PID of process which created this lock. */
 	u32				l_pid;
diff --git a/fs/lustre/include/lustre_net.h b/fs/lustre/include/lustre_net.h
index a0a974c..8500db5 100644
--- a/fs/lustre/include/lustre_net.h
+++ b/fs/lustre/include/lustre_net.h
@@ -534,9 +534,9 @@ struct ptlrpc_cli_req {
 	/** For bulk requests on client only: bulk descriptor */
 	struct ptlrpc_bulk_desc		*cr_bulk;
 	/** optional time limit for send attempts */
-	long				 cr_delay_limit;
+	time64_t			 cr_delay_limit;
 	/** time request was first queued */
-	unsigned long			 cr_queued_time;
+	time64_t			 cr_queued_time;
 	/** request sent in nanosseconds */
 	ktime_t				 cr_sent_ns;
 	/** time for request really sent out */
@@ -867,8 +867,9 @@ struct ptlrpc_request {
 	/**
 	 * service time estimate (secs)
 	 * If the request is not served by this time, it is marked as timed out.
+	 * Do not change to time64_t since this is transmitted over the wire.
 	 */
-	int			rq_timeout;
+	time_t			rq_timeout;
 	/**
 	 * when request/reply sent (secs), or time when request should be sent
 	 */
@@ -2221,10 +2222,8 @@ static inline int ptlrpc_req_get_repsize(struct ptlrpc_request *req)
 static inline int ptlrpc_send_limit_expired(struct ptlrpc_request *req)
 {
 	if (req->rq_delay_limit != 0 &&
-	    time_before(req->rq_queued_time + req->rq_delay_limit * HZ,
-			jiffies)) {
+	    req->rq_queued_time + req->rq_delay_limit < ktime_get_seconds())
 		return 1;
-	}
 	return 0;
 }
 
diff --git a/fs/lustre/ldlm/ldlm_lock.c b/fs/lustre/ldlm/ldlm_lock.c
index 6b4dd41..ef6c5e8 100644
--- a/fs/lustre/ldlm/ldlm_lock.c
+++ b/fs/lustre/ldlm/ldlm_lock.c
@@ -1996,7 +1996,7 @@ void _ldlm_lock_debug(struct ldlm_lock *lock,
 
 	if (!resource) {
 		libcfs_debug_msg(msgdata,
-				 "%pV ns: \?\? lock: %p/%#llx lrc: %d/%d,%d mode: %s/%s res: \?\? rrc=\?\? type: \?\?\? flags: %#llx nid: %s remote: %#llx expref: %d pid: %u timeout: %lu lvb_type: %d\n",
+				 "%pV ns: \?\? lock: %p/%#llx lrc: %d/%d,%d mode: %s/%s res: \?\? rrc=\?\? type: \?\?\? flags: %#llx nid: %s remote: %#llx expref: %d pid: %u timeout: %lld lvb_type: %d\n",
 				 &vaf,
 				 lock,
 				 lock->l_handle.h_cookie,
@@ -2016,7 +2016,7 @@ void _ldlm_lock_debug(struct ldlm_lock *lock,
 	switch (resource->lr_type) {
 	case LDLM_EXTENT:
 		libcfs_debug_msg(msgdata,
-				 "%pV ns: %s lock: %p/%#llx lrc: %d/%d,%d mode: %s/%s res: " DLDLMRES " rrc: %d type: %s [%llu->%llu] (req %llu->%llu) flags: %#llx nid: %s remote: %#llx expref: %d pid: %u timeout: %lu lvb_type: %d\n",
+				 "%pV ns: %s lock: %p/%#llx lrc: %d/%d,%d mode: %s/%s res: " DLDLMRES " rrc: %d type: %s [%llu->%llu] (req %llu->%llu) flags: %#llx nid: %s remote: %#llx expref: %d pid: %u timeout: %lld lvb_type: %d\n",
 				 &vaf,
 				 ldlm_lock_to_ns_name(lock), lock,
 				 lock->l_handle.h_cookie,
@@ -2040,7 +2040,7 @@ void _ldlm_lock_debug(struct ldlm_lock *lock,
 
 	case LDLM_FLOCK:
 		libcfs_debug_msg(msgdata,
-				 "%pV ns: %s lock: %p/%#llx lrc: %d/%d,%d mode: %s/%s res: " DLDLMRES " rrc: %d type: %s pid: %d [%llu->%llu] flags: %#llx nid: %s remote: %#llx expref: %d pid: %u timeout: %lu\n",
+				 "%pV ns: %s lock: %p/%#llx lrc: %d/%d,%d mode: %s/%s res: " DLDLMRES " rrc: %d type: %s pid: %d [%llu->%llu] flags: %#llx nid: %s remote: %#llx expref: %d pid: %u timeout: %lld\n",
 				 &vaf,
 				 ldlm_lock_to_ns_name(lock), lock,
 				 lock->l_handle.h_cookie,
@@ -2062,7 +2062,7 @@ void _ldlm_lock_debug(struct ldlm_lock *lock,
 
 	case LDLM_IBITS:
 		libcfs_debug_msg(msgdata,
-				 "%pV ns: %s lock: %p/%#llx lrc: %d/%d,%d mode: %s/%s res: " DLDLMRES " bits %#llx rrc: %d type: %s flags: %#llx nid: %s remote: %#llx expref: %d pid: %u timeout: %lu lvb_type: %d\n",
+				 "%pV ns: %s lock: %p/%#llx lrc: %d/%d,%d mode: %s/%s res: " DLDLMRES " bits %#llx rrc: %d type: %s flags: %#llx nid: %s remote: %#llx expref: %d pid: %u timeout: %lld lvb_type: %d\n",
 				 &vaf,
 				 ldlm_lock_to_ns_name(lock),
 				 lock, lock->l_handle.h_cookie,
@@ -2083,7 +2083,7 @@ void _ldlm_lock_debug(struct ldlm_lock *lock,
 
 	default:
 		libcfs_debug_msg(msgdata,
-				 "%pV ns: %s lock: %p/%#llx lrc: %d/%d,%d mode: %s/%s res: " DLDLMRES " rrc: %d type: %s flags: %#llx nid: %s remote: %#llx expref: %d pid: %u timeout: %lu lvb_type: %d\n",
+				 "%pV ns: %s lock: %p/%#llx lrc: %d/%d,%d mode: %s/%s res: " DLDLMRES " rrc: %d type: %s flags: %#llx nid: %s remote: %#llx expref: %d pid: %u timeout: %lld lvb_type: %d\n",
 				 &vaf,
 				 ldlm_lock_to_ns_name(lock),
 				 lock, lock->l_handle.h_cookie,
diff --git a/fs/lustre/ldlm/ldlm_lockd.c b/fs/lustre/ldlm/ldlm_lockd.c
index 83f5a22..2c21e7d 100644
--- a/fs/lustre/ldlm/ldlm_lockd.c
+++ b/fs/lustre/ldlm/ldlm_lockd.c
@@ -160,7 +160,7 @@ static void ldlm_handle_cp_callback(struct ptlrpc_request *req,
 	LDLM_DEBUG(lock, "client completion callback handler START");
 
 	if (OBD_FAIL_CHECK(OBD_FAIL_LDLM_CANCEL_BL_CB_RACE)) {
-		int to = HZ;
+		long to = HZ;
 
 		while (to > 0) {
 			schedule_timeout_interruptible(to);
diff --git a/fs/lustre/ldlm/ldlm_request.c b/fs/lustre/ldlm/ldlm_request.c
index 6089ac4..13b323a 100644
--- a/fs/lustre/ldlm/ldlm_request.c
+++ b/fs/lustre/ldlm/ldlm_request.c
@@ -110,16 +110,16 @@ static void ldlm_expired_completion_wait(struct ldlm_lock *lock, u32 conn_cnt)
 	struct obd_device *obd;
 
 	if (!lock->l_conn_export) {
-		static unsigned long next_dump, last_dump;
+		static time64_t next_dump, last_dump;
 
 		LDLM_ERROR(lock,
 			   "lock timed out (enqueued at %lld, %llds ago); not entering recovery in server code, just going back to sleep",
 			   (s64)lock->l_last_activity,
 			   (s64)(ktime_get_real_seconds() -
 				 lock->l_last_activity));
-		if (time_after(jiffies, next_dump)) {
+		if (ktime_get_seconds() > next_dump) {
 			last_dump = next_dump;
-			next_dump = jiffies + 300 * HZ;
+			next_dump = ktime_get_seconds() + 300;
 			ldlm_namespace_dump(D_DLMTRACE,
 					    ldlm_lock_to_ns(lock));
 			if (last_dump == 0)
@@ -150,9 +150,9 @@ static void ldlm_expired_completion_wait(struct ldlm_lock *lock, u32 conn_cnt)
 /* We use the same basis for both server side and client side functions
  * from a single node.
  */
-static unsigned int ldlm_cp_timeout(struct ldlm_lock *lock)
+static time64_t ldlm_cp_timeout(struct ldlm_lock *lock)
 {
-	unsigned int timeout;
+	time64_t timeout;
 
 	if (AT_OFF)
 		return obd_timeout;
@@ -163,7 +163,7 @@ static unsigned int ldlm_cp_timeout(struct ldlm_lock *lock)
 	 * doesn't respond reasonably, and then give us the lock.
 	 */
 	timeout = at_get(ldlm_lock_to_ns_at(lock));
-	return max(3 * timeout, ldlm_enqueue_min);
+	return max(3 * timeout, (time64_t) ldlm_enqueue_min);
 }
 
 /**
@@ -218,7 +218,7 @@ int ldlm_completion_ast(struct ldlm_lock *lock, u64 flags, void *data)
 	/* XXX ALLOCATE - 160 bytes */
 	struct obd_device *obd;
 	struct obd_import *imp = NULL;
-	u32 timeout;
+	time64_t timeout;
 	u32 conn_cnt = 0;
 	int rc = 0;
 
diff --git a/fs/lustre/ldlm/ldlm_resource.c b/fs/lustre/ldlm/ldlm_resource.c
index bf8abd4..de0ae1a 100644
--- a/fs/lustre/ldlm/ldlm_resource.c
+++ b/fs/lustre/ldlm/ldlm_resource.c
@@ -274,7 +274,6 @@ static ssize_t lru_max_age_store(struct kobject *kobj, struct attribute *attr,
 	int scale = NSEC_PER_MSEC;
 	unsigned long long tmp;
 	char *buf;
-	int err;
 
 	/* Did the user ask in seconds or milliseconds. Default is in ms */
 	buf = strstr(buffer, "ms");
@@ -287,8 +286,7 @@ static ssize_t lru_max_age_store(struct kobject *kobj, struct attribute *attr,
 	if (buf)
 		*buf = '\0';
 
-	err = kstrtoull(buffer, 10, &tmp);
-	if (err != 0)
+	if (kstrtoull(buffer, 10, &tmp))
 		return -EINVAL;
 
 	ns->ns_max_age = ktime_set(0, tmp * scale);
@@ -1283,14 +1281,14 @@ void ldlm_namespace_dump(int level, struct ldlm_namespace *ns)
 	CDEBUG(level, "--- Namespace: %s (rc: %d, side: client)\n",
 	       ldlm_ns_name(ns), atomic_read(&ns->ns_bref));
 
-	if (time_before(jiffies, ns->ns_next_dump))
+	if (ktime_get_seconds() < ns->ns_next_dump)
 		return;
 
 	cfs_hash_for_each_nolock(ns->ns_rs_hash,
 				 ldlm_res_hash_dump,
 				 (void *)(unsigned long)level, 0);
 	spin_lock(&ns->ns_lock);
-	ns->ns_next_dump = jiffies + 10 * HZ;
+	ns->ns_next_dump = ktime_get_seconds() + 10;
 	spin_unlock(&ns->ns_lock);
 }
 
diff --git a/fs/lustre/ptlrpc/client.c b/fs/lustre/ptlrpc/client.c
index e0b2b91..da7077a 100644
--- a/fs/lustre/ptlrpc/client.c
+++ b/fs/lustre/ptlrpc/client.c
@@ -1084,7 +1084,7 @@ void ptlrpc_set_add_req(struct ptlrpc_request_set *set,
 	list_add_tail(&req->rq_set_chain, &set->set_requests);
 	req->rq_set = set;
 	atomic_inc(&set->set_remaining);
-	req->rq_queued_time = jiffies;
+	req->rq_queued_time = ktime_get_seconds();
 
 	if (req->rq_reqmsg)
 		lustre_msg_set_jobid(req->rq_reqmsg, NULL);
@@ -1115,7 +1115,7 @@ void ptlrpc_set_add_new_req(struct ptlrpcd_ctl *pc,
 	spin_lock(&set->set_new_req_lock);
 	/* The set takes over the caller's request reference.  */
 	req->rq_set = set;
-	req->rq_queued_time = jiffies;
+	req->rq_queued_time = ktime_get_seconds();
 	list_add_tail(&req->rq_set_chain, &set->set_new_requests);
 	count = atomic_inc_return(&set->set_new_count);
 	spin_unlock(&set->set_new_req_lock);
diff --git a/fs/lustre/ptlrpc/import.c b/fs/lustre/ptlrpc/import.c
index e1fc2ef..32aceb9 100644
--- a/fs/lustre/ptlrpc/import.c
+++ b/fs/lustre/ptlrpc/import.c
@@ -717,7 +717,7 @@ int ptlrpc_connect_import(struct obd_import *imp)
 		lustre_msg_add_op_flags(request->rq_reqmsg,
 					MSG_CONNECT_TRANSNO);
 
-	DEBUG_REQ(D_RPCTRACE, request, "(re)connect request (timeout %d)",
+	DEBUG_REQ(D_RPCTRACE, request, "(re)connect request (timeout %ld)",
 		  request->rq_timeout);
 	ptlrpcd_add_req(request);
 	rc = 0;
-- 
1.8.3.1
