From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:16:40 -0500
Subject: [lustre-devel] [PATCH 532/622] lustre: handle: move refcount into
 the lustre_handle.
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-533-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: NeilBrown <neilb@suse.com>

Most objects with a lustre_handle have a refcount. The exception
is mdt_mfd which uses locking (med_open_lock) to manage its
lifetime. The lustre_handles code currently needs a call-out to
increment its refcount. To simplify things, move the refcount
into the lustre_hanle (which will be largely ignored by mdt_mfd)
and discard the call-out.

To avoid warnings when refcount debugging is enabled the refcount
of mdt_mfd is initialized to 1, and decremeneted after any
class_handle2object() call which would have incremented it.

In order to preserve the same debug messages, we store an object type
name in the portals_handle_ops, and use that in a CDEBUG() when
incrementing the ref count.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12542
Lustre-commit: 1d1f6c8908b3 ("LU-12542 handle: move refcount into the lustre_handle.")
Signed-off-by: NeilBrown <neilb@suse.com>
Reviewed-on: https://review.whamcloud.com/35794
Reviewed-by: Neil Brown <neilb@suse.de>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Shaun Tancheff <stancheff@cray.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_dlm.h      |  6 ------
 fs/lustre/include/lustre_export.h   |  3 +--
 fs/lustre/include/lustre_handles.h  |  4 +++-
 fs/lustre/ldlm/ldlm_lock.c          | 36 +++++++++++++++---------------------
 fs/lustre/obdclass/genops.c         | 25 ++++++++++---------------
 fs/lustre/obdclass/lustre_handles.c |  5 ++++-
 fs/lustre/obdecho/echo_client.c     |  2 +-
 fs/lustre/ptlrpc/service.c          |  4 ++--
 8 files changed, 36 insertions(+), 49 deletions(-)

diff --git a/fs/lustre/include/lustre_dlm.h b/fs/lustre/include/lustre_dlm.h
index f7d2d9c..7621d1e 100644
--- a/fs/lustre/include/lustre_dlm.h
+++ b/fs/lustre/include/lustre_dlm.h
@@ -598,12 +598,6 @@ struct ldlm_lock {
 	 */
 	struct portals_handle		l_handle;
 	/**
-	 * Lock reference count.
-	 * This is how many users have pointers to actual structure, so that
-	 * we do not accidentally free lock structure that is in use.
-	 */
-	atomic_t			l_refc;
-	/**
 	 * Internal spinlock protects l_resource.  We should hold this lock
 	 * first before taking res_lock.
 	 */
diff --git a/fs/lustre/include/lustre_export.h b/fs/lustre/include/lustre_export.h
index 967ce37..878dedd 100644
--- a/fs/lustre/include/lustre_export.h
+++ b/fs/lustre/include/lustre_export.h
@@ -67,12 +67,11 @@ struct obd_export {
 	 * what export they are talking to.
 	 */
 	struct portals_handle		exp_handle;
-	refcount_t			exp_refcount;
 	/**
 	 * Set of counters below is to track where export references are
 	 * kept. The exp_rpc_count is used for reconnect handling also,
 	 * the cb_count and locks_count are for debug purposes only for now.
-	 * The sum of them should be less than exp_refcount by 3
+	 * The sum of them should be less than exp_handle.href by 3
 	 */
 	atomic_t			exp_rpc_count; /* RPC references */
 	atomic_t			exp_cb_count; /* Commit callback references */
diff --git a/fs/lustre/include/lustre_handles.h b/fs/lustre/include/lustre_handles.h
index 0440970..7c93d72 100644
--- a/fs/lustre/include/lustre_handles.h
+++ b/fs/lustre/include/lustre_handles.h
@@ -46,8 +46,9 @@
 #include <linux/types.h>
 
 struct portals_handle_ops {
-	void (*hop_addref)(void *object);
 	void (*hop_free)(void *object, int size);
+	/* hop_type is used for some debugging messages */
+	char *hop_type;
 };
 
 /* These handles are most easily used by having them appear at the very top of
@@ -66,6 +67,7 @@ struct portals_handle {
 	struct list_head		h_link;
 	u64				h_cookie;
 	const struct portals_handle_ops	*h_ops;
+	refcount_t			h_ref;
 
 	/* newly added fields to handle the RCU issue. -jxiong */
 	struct rcu_head			h_rcu;
diff --git a/fs/lustre/ldlm/ldlm_lock.c b/fs/lustre/ldlm/ldlm_lock.c
index d14221a..62d2c1d 100644
--- a/fs/lustre/ldlm/ldlm_lock.c
+++ b/fs/lustre/ldlm/ldlm_lock.c
@@ -148,7 +148,7 @@ const char *ldlm_it2str(enum ldlm_intent_flags it)
  */
 struct ldlm_lock *ldlm_lock_get(struct ldlm_lock *lock)
 {
-	atomic_inc(&lock->l_refc);
+	refcount_inc(&lock->l_handle.h_ref);
 	return lock;
 }
 EXPORT_SYMBOL(ldlm_lock_get);
@@ -161,8 +161,8 @@ struct ldlm_lock *ldlm_lock_get(struct ldlm_lock *lock)
 void ldlm_lock_put(struct ldlm_lock *lock)
 {
 	LASSERT(lock->l_resource != LP_POISON);
-	LASSERT(atomic_read(&lock->l_refc) > 0);
-	if (atomic_dec_and_test(&lock->l_refc)) {
+	LASSERT(refcount_read(&lock->l_handle.h_ref) > 0);
+	if (refcount_dec_and_test(&lock->l_handle.h_ref)) {
 		struct ldlm_resource *res;
 
 		LDLM_DEBUG(lock,
@@ -358,12 +358,6 @@ void ldlm_lock_destroy_nolock(struct ldlm_lock *lock)
 	}
 }
 
-/* this is called by portals_handle2object with the handle lock taken */
-static void lock_handle_addref(void *lock)
-{
-	LDLM_LOCK_GET((struct ldlm_lock *)lock);
-}
-
 static void lock_handle_free(void *lock, int size)
 {
 	LASSERT(size == sizeof(struct ldlm_lock));
@@ -371,8 +365,8 @@ static void lock_handle_free(void *lock, int size)
 }
 
 static struct portals_handle_ops lock_handle_ops = {
-	.hop_addref = lock_handle_addref,
 	.hop_free   = lock_handle_free,
+	.hop_type   = "ldlm",
 };
 
 /**
@@ -397,7 +391,7 @@ static struct ldlm_lock *ldlm_lock_new(struct ldlm_resource *resource)
 	lock->l_resource = resource;
 	lu_ref_add(&resource->lr_reference, "lock", lock);
 
-	atomic_set(&lock->l_refc, 2);
+	refcount_set(&lock->l_handle.h_ref, 2);
 	INIT_LIST_HEAD(&lock->l_res_link);
 	INIT_LIST_HEAD(&lock->l_lru);
 	INIT_LIST_HEAD(&lock->l_pending_chain);
@@ -1896,13 +1890,13 @@ void _ldlm_lock_debug(struct ldlm_lock *lock,
 				 &vaf,
 				 lock,
 				 lock->l_handle.h_cookie,
-				 atomic_read(&lock->l_refc),
+				 refcount_read(&lock->l_handle.h_ref),
 				 lock->l_readers, lock->l_writers,
 				 ldlm_lockname[lock->l_granted_mode],
 				 ldlm_lockname[lock->l_req_mode],
 				 lock->l_flags, nid,
 				 lock->l_remote_handle.cookie,
-				 exp ? refcount_read(&exp->exp_refcount) : -99,
+				 exp ? refcount_read(&exp->exp_handle.h_ref) : -99,
 				 lock->l_pid, lock->l_callback_timeout,
 				 lock->l_lvb_type);
 		va_end(args);
@@ -1916,7 +1910,7 @@ void _ldlm_lock_debug(struct ldlm_lock *lock,
 				 &vaf,
 				 ldlm_lock_to_ns_name(lock), lock,
 				 lock->l_handle.h_cookie,
-				 atomic_read(&lock->l_refc),
+				 refcount_read(&lock->l_handle.h_ref),
 				 lock->l_readers, lock->l_writers,
 				 ldlm_lockname[lock->l_granted_mode],
 				 ldlm_lockname[lock->l_req_mode],
@@ -1929,7 +1923,7 @@ void _ldlm_lock_debug(struct ldlm_lock *lock,
 				 lock->l_req_extent.end,
 				 lock->l_flags, nid,
 				 lock->l_remote_handle.cookie,
-				 exp ? refcount_read(&exp->exp_refcount) : -99,
+				 exp ? refcount_read(&exp->exp_handle.h_ref) : -99,
 				 lock->l_pid, lock->l_callback_timeout,
 				 lock->l_lvb_type);
 		break;
@@ -1940,7 +1934,7 @@ void _ldlm_lock_debug(struct ldlm_lock *lock,
 				 &vaf,
 				 ldlm_lock_to_ns_name(lock), lock,
 				 lock->l_handle.h_cookie,
-				 atomic_read(&lock->l_refc),
+				 refcount_read(&lock->l_handle.h_ref),
 				 lock->l_readers, lock->l_writers,
 				 ldlm_lockname[lock->l_granted_mode],
 				 ldlm_lockname[lock->l_req_mode],
@@ -1952,7 +1946,7 @@ void _ldlm_lock_debug(struct ldlm_lock *lock,
 				 lock->l_policy_data.l_flock.end,
 				 lock->l_flags, nid,
 				 lock->l_remote_handle.cookie,
-				 exp ? refcount_read(&exp->exp_refcount) : -99,
+				 exp ? refcount_read(&exp->exp_handle.h_ref) : -99,
 				 lock->l_pid, lock->l_callback_timeout);
 		break;
 
@@ -1962,7 +1956,7 @@ void _ldlm_lock_debug(struct ldlm_lock *lock,
 				 &vaf,
 				 ldlm_lock_to_ns_name(lock),
 				 lock, lock->l_handle.h_cookie,
-				 atomic_read(&lock->l_refc),
+				 refcount_read(&lock->l_handle.h_ref),
 				 lock->l_readers, lock->l_writers,
 				 ldlm_lockname[lock->l_granted_mode],
 				 ldlm_lockname[lock->l_req_mode],
@@ -1972,7 +1966,7 @@ void _ldlm_lock_debug(struct ldlm_lock *lock,
 				 ldlm_typename[resource->lr_type],
 				 lock->l_flags, nid,
 				 lock->l_remote_handle.cookie,
-				 exp ? refcount_read(&exp->exp_refcount) : -99,
+				 exp ? refcount_read(&exp->exp_handle.h_ref) : -99,
 				 lock->l_pid, lock->l_callback_timeout,
 				 lock->l_lvb_type);
 		break;
@@ -1983,7 +1977,7 @@ void _ldlm_lock_debug(struct ldlm_lock *lock,
 				 &vaf,
 				 ldlm_lock_to_ns_name(lock),
 				 lock, lock->l_handle.h_cookie,
-				 atomic_read(&lock->l_refc),
+				 refcount_read(&lock->l_handle.h_ref),
 				 lock->l_readers, lock->l_writers,
 				 ldlm_lockname[lock->l_granted_mode],
 				 ldlm_lockname[lock->l_req_mode],
@@ -1992,7 +1986,7 @@ void _ldlm_lock_debug(struct ldlm_lock *lock,
 				 ldlm_typename[resource->lr_type],
 				 lock->l_flags, nid,
 				 lock->l_remote_handle.cookie,
-				 exp ? refcount_read(&exp->exp_refcount) : -99,
+				 exp ? refcount_read(&exp->exp_handle.h_ref) : -99,
 				 lock->l_pid, lock->l_callback_timeout,
 				 lock->l_lvb_type);
 		break;
diff --git a/fs/lustre/obdclass/genops.c b/fs/lustre/obdclass/genops.c
index 5d4e421..7f841d5 100644
--- a/fs/lustre/obdclass/genops.c
+++ b/fs/lustre/obdclass/genops.c
@@ -708,7 +708,7 @@ static void class_export_destroy(struct obd_export *exp)
 {
 	struct obd_device *obd = exp->exp_obd;
 
-	LASSERT(refcount_read(&exp->exp_refcount) == 0);
+	LASSERT(refcount_read(&exp->exp_handle.h_ref) == 0);
 	LASSERT(obd);
 
 	CDEBUG(D_IOCTL, "destroying export %p/%s for %s\n", exp,
@@ -732,33 +732,28 @@ static void class_export_destroy(struct obd_export *exp)
 	OBD_FREE_RCU(exp, sizeof(*exp), &exp->exp_handle);
 }
 
-static void export_handle_addref(void *export)
-{
-	class_export_get(export);
-}
-
 static struct portals_handle_ops export_handle_ops = {
-	.hop_addref	= export_handle_addref,
 	.hop_free	= NULL,
+	.hop_type	= "export",
 };
 
 struct obd_export *class_export_get(struct obd_export *exp)
 {
-	refcount_inc(&exp->exp_refcount);
-	CDEBUG(D_INFO, "GETting export %p : new refcount %d\n", exp,
-	       refcount_read(&exp->exp_refcount));
+	refcount_inc(&exp->exp_handle.h_ref);
+	CDEBUG(D_INFO, "GET export %p refcount=%d\n", exp,
+	       refcount_read(&exp->exp_handle.h_ref));
 	return exp;
 }
 EXPORT_SYMBOL(class_export_get);
 
 void class_export_put(struct obd_export *exp)
 {
-	LASSERT(refcount_read(&exp->exp_refcount) >  0);
-	LASSERT(refcount_read(&exp->exp_refcount) < LI_POISON);
+	LASSERT(refcount_read(&exp->exp_handle.h_ref) >  0);
+	LASSERT(refcount_read(&exp->exp_handle.h_ref) < LI_POISON);
 	CDEBUG(D_INFO, "PUTting export %p : new refcount %d\n", exp,
-	       refcount_read(&exp->exp_refcount) - 1);
+	       refcount_read(&exp->exp_handle.h_ref) - 1);
 
-	if (refcount_dec_and_test(&exp->exp_refcount)) {
+	if (refcount_dec_and_test(&exp->exp_handle.h_ref)) {
 		struct obd_device *obd = exp->exp_obd;
 
 		CDEBUG(D_IOCTL, "final put %p/%s\n",
@@ -809,7 +804,7 @@ static struct obd_export *__class_new_export(struct obd_device *obd,
 
 	export->exp_conn_cnt = 0;
 	/* 2 = class_handle_hash + last */
-	refcount_set(&export->exp_refcount, 2);
+	refcount_set(&export->exp_handle.h_ref, 2);
 	atomic_set(&export->exp_rpc_count, 0);
 	atomic_set(&export->exp_cb_count, 0);
 	atomic_set(&export->exp_locks_count, 0);
diff --git a/fs/lustre/obdclass/lustre_handles.c b/fs/lustre/obdclass/lustre_handles.c
index 7fa3ef6..95a34db 100644
--- a/fs/lustre/obdclass/lustre_handles.c
+++ b/fs/lustre/obdclass/lustre_handles.c
@@ -152,7 +152,10 @@ void *class_handle2object(u64 cookie, const struct portals_handle_ops *ops)
 
 		spin_lock(&h->h_lock);
 		if (likely(h->h_in != 0)) {
-			h->h_ops->hop_addref(h);
+			refcount_inc(&h->h_ref);
+			CDEBUG(D_INFO, "GET %s %p refcount=%d\n",
+			       h->h_ops->hop_type, h,
+			       refcount_read(&h->h_ref));
 			retval = h;
 		}
 		spin_unlock(&h->h_lock);
diff --git a/fs/lustre/obdecho/echo_client.c b/fs/lustre/obdecho/echo_client.c
index 8e04636..c473f547 100644
--- a/fs/lustre/obdecho/echo_client.c
+++ b/fs/lustre/obdecho/echo_client.c
@@ -1669,7 +1669,7 @@ static int echo_client_cleanup(struct obd_device *obddev)
 	lu_session_tags_clear(ECHO_SES_TAG & ~LCT_SESSION);
 	lu_context_tags_clear(ECHO_DT_CTX_TAG);
 
-	LASSERT(refcount_read(&ec->ec_exp->exp_refcount) > 0);
+	LASSERT(refcount_read(&ec->ec_exp->exp_handle.h_ref) > 0);
 	rc = obd_disconnect(ec->ec_exp);
 	if (rc != 0)
 		CERROR("fail to disconnect device: %d\n", rc);
diff --git a/fs/lustre/ptlrpc/service.c b/fs/lustre/ptlrpc/service.c
index fe0e108..c874487 100644
--- a/fs/lustre/ptlrpc/service.c
+++ b/fs/lustre/ptlrpc/service.c
@@ -1768,7 +1768,7 @@ static int ptlrpc_server_handle_request(struct ptlrpc_service_part *svcpt,
 	       (request->rq_export ?
 		(char *)request->rq_export->exp_client_uuid.uuid : "0"),
 	       (request->rq_export ?
-		refcount_read(&request->rq_export->exp_refcount) : -99),
+		refcount_read(&request->rq_export->exp_handle.h_ref) : -99),
 	       lustre_msg_get_status(request->rq_reqmsg), request->rq_xid,
 	       libcfs_id2str(request->rq_peer),
 	       lustre_msg_get_opc(request->rq_reqmsg),
@@ -1809,7 +1809,7 @@ static int ptlrpc_server_handle_request(struct ptlrpc_service_part *svcpt,
 	       (request->rq_export ?
 		(char *)request->rq_export->exp_client_uuid.uuid : "0"),
 	       (request->rq_export ?
-		refcount_read(&request->rq_export->exp_refcount) : -99),
+		refcount_read(&request->rq_export->exp_handle.h_ref) : -99),
 	       lustre_msg_get_status(request->rq_reqmsg),
 	       request->rq_xid,
 	       libcfs_id2str(request->rq_peer),
-- 
1.8.3.1
