From: James Simmons <jsimmons@infradead.org>
Date: Mon, 20 May 2019 08:50:59 -0400
Subject: [lustre-devel] [PATCH v2 17/29] lustre: handle: move refcount into
 the lustre_handle.
In-Reply-To: <1558356671-29599-1-git-send-email-jsimmons@infradead.org>
References: <1558356671-29599-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1558356671-29599-18-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: NeilBrown <neilb@suse.com>

Every object with a lustre_handle has (and must have) a refcount.
The lustre_handles code needs a call-out to increment this.
To simplify things, move the refcount into the lustre_handle
and discard the call-out.

In order to preserve the same debug messages, we store an object type
name in the portals_handle_ops, and use that in a CDEBUG() when
incrementing the ref count.

Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Signed-off-by: NeilBrown <neilb@suse.com>
---
 fs/lustre/include/lustre_dlm.h      |  6 -----
 fs/lustre/include/lustre_export.h   |  1 -
 fs/lustre/include/lustre_handles.h  |  4 ++-
 fs/lustre/include/lustre_import.h   |  2 --
 fs/lustre/ldlm/ldlm_lock.c          | 36 +++++++++++---------------
 fs/lustre/obdclass/genops.c         | 50 +++++++++++++++----------------------
 fs/lustre/obdclass/lustre_handles.c |  5 +++-
 fs/lustre/obdecho/echo_client.c     |  2 +-
 fs/lustre/ptlrpc/service.c          |  4 +--
 9 files changed, 45 insertions(+), 65 deletions(-)

diff --git a/fs/lustre/include/lustre_dlm.h b/fs/lustre/include/lustre_dlm.h
index 1bd5119..fd9b0f8 100644
--- a/fs/lustre/include/lustre_dlm.h
+++ b/fs/lustre/include/lustre_dlm.h
@@ -591,12 +591,6 @@ struct ldlm_lock {
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
index fb34e0b..d053233 100644
--- a/fs/lustre/include/lustre_export.h
+++ b/fs/lustre/include/lustre_export.h
@@ -67,7 +67,6 @@ struct obd_export {
 	 * what export they are talking to.
 	 */
 	struct portals_handle		exp_handle;
-	refcount_t			exp_refcount;
 	/**
 	 * Set of counters below is to track where export references are
 	 * kept. The exp_rpc_count is used for reconnect handling also,
diff --git a/fs/lustre/include/lustre_handles.h b/fs/lustre/include/lustre_handles.h
index 9a4b1a8..be5d41b 100644
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
diff --git a/fs/lustre/include/lustre_import.h b/fs/lustre/include/lustre_import.h
index fc1f87c..6c830da 100644
--- a/fs/lustre/include/lustre_import.h
+++ b/fs/lustre/include/lustre_import.h
@@ -154,8 +154,6 @@ struct import_state_hist {
 struct obd_import {
 	/** Local handle (== id) for this import. */
 	struct portals_handle		imp_handle;
-	/** Reference counter */
-	atomic_t			imp_refcount;
 	struct lustre_handle		imp_dlm_handle; /* client's ldlm export */
 	/** Currently active connection */
 	struct ptlrpc_connection       *imp_connection;
diff --git a/fs/lustre/ldlm/ldlm_lock.c b/fs/lustre/ldlm/ldlm_lock.c
index 768cccc..ecd3f4a 100644
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
@@ -356,12 +356,6 @@ void ldlm_lock_destroy_nolock(struct ldlm_lock *lock)
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
@@ -369,8 +363,8 @@ static void lock_handle_free(void *lock, int size)
 }
 
 static struct portals_handle_ops lock_handle_ops = {
-	.hop_addref = lock_handle_addref,
 	.hop_free   = lock_handle_free,
+	.hop_type   = "ldlm",
 };
 
 /**
@@ -395,7 +389,7 @@ static struct ldlm_lock *ldlm_lock_new(struct ldlm_resource *resource)
 	lock->l_resource = resource;
 	lu_ref_add(&resource->lr_reference, "lock", lock);
 
-	atomic_set(&lock->l_refc, 2);
+	refcount_set(&lock->l_handle.h_ref, 2);
 	INIT_LIST_HEAD(&lock->l_res_link);
 	INIT_LIST_HEAD(&lock->l_lru);
 	INIT_LIST_HEAD(&lock->l_pending_chain);
@@ -1996,13 +1990,13 @@ void _ldlm_lock_debug(struct ldlm_lock *lock,
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
@@ -2016,7 +2010,7 @@ void _ldlm_lock_debug(struct ldlm_lock *lock,
 				 &vaf,
 				 ldlm_lock_to_ns_name(lock), lock,
 				 lock->l_handle.h_cookie,
-				 atomic_read(&lock->l_refc),
+				 refcount_read(&lock->l_handle.h_ref),
 				 lock->l_readers, lock->l_writers,
 				 ldlm_lockname[lock->l_granted_mode],
 				 ldlm_lockname[lock->l_req_mode],
@@ -2029,7 +2023,7 @@ void _ldlm_lock_debug(struct ldlm_lock *lock,
 				 lock->l_req_extent.end,
 				 lock->l_flags, nid,
 				 lock->l_remote_handle.cookie,
-				 exp ? refcount_read(&exp->exp_refcount) : -99,
+				 exp ? refcount_read(&exp->exp_handle.h_ref) : -99,
 				 lock->l_pid, lock->l_callback_timeout,
 				 lock->l_lvb_type);
 		break;
@@ -2040,7 +2034,7 @@ void _ldlm_lock_debug(struct ldlm_lock *lock,
 				 &vaf,
 				 ldlm_lock_to_ns_name(lock), lock,
 				 lock->l_handle.h_cookie,
-				 atomic_read(&lock->l_refc),
+				 refcount_read(&lock->l_handle.h_ref),
 				 lock->l_readers, lock->l_writers,
 				 ldlm_lockname[lock->l_granted_mode],
 				 ldlm_lockname[lock->l_req_mode],
@@ -2052,7 +2046,7 @@ void _ldlm_lock_debug(struct ldlm_lock *lock,
 				 lock->l_policy_data.l_flock.end,
 				 lock->l_flags, nid,
 				 lock->l_remote_handle.cookie,
-				 exp ? refcount_read(&exp->exp_refcount) : -99,
+				 exp ? refcount_read(&exp->exp_handle.h_ref) : -99,
 				 lock->l_pid, lock->l_callback_timeout);
 		break;
 
@@ -2062,7 +2056,7 @@ void _ldlm_lock_debug(struct ldlm_lock *lock,
 				 &vaf,
 				 ldlm_lock_to_ns_name(lock),
 				 lock, lock->l_handle.h_cookie,
-				 atomic_read(&lock->l_refc),
+				 refcount_read(&lock->l_handle.h_ref),
 				 lock->l_readers, lock->l_writers,
 				 ldlm_lockname[lock->l_granted_mode],
 				 ldlm_lockname[lock->l_req_mode],
@@ -2072,7 +2066,7 @@ void _ldlm_lock_debug(struct ldlm_lock *lock,
 				 ldlm_typename[resource->lr_type],
 				 lock->l_flags, nid,
 				 lock->l_remote_handle.cookie,
-				 exp ? refcount_read(&exp->exp_refcount) : -99,
+				 exp ? refcount_read(&exp->exp_handle.h_ref) : -99,
 				 lock->l_pid, lock->l_callback_timeout,
 				 lock->l_lvb_type);
 		break;
@@ -2083,7 +2077,7 @@ void _ldlm_lock_debug(struct ldlm_lock *lock,
 				 &vaf,
 				 ldlm_lock_to_ns_name(lock),
 				 lock, lock->l_handle.h_cookie,
-				 atomic_read(&lock->l_refc),
+				 refcount_read(&lock->l_handle.h_ref),
 				 lock->l_readers, lock->l_writers,
 				 ldlm_lockname[lock->l_granted_mode],
 				 ldlm_lockname[lock->l_req_mode],
@@ -2092,7 +2086,7 @@ void _ldlm_lock_debug(struct ldlm_lock *lock,
 				 ldlm_typename[resource->lr_type],
 				 lock->l_flags, nid,
 				 lock->l_remote_handle.cookie,
-				 exp ? refcount_read(&exp->exp_refcount) : -99,
+				 exp ? refcount_read(&exp->exp_handle.h_ref) : -99,
 				 lock->l_pid, lock->l_callback_timeout,
 				 lock->l_lvb_type);
 		break;
diff --git a/fs/lustre/obdclass/genops.c b/fs/lustre/obdclass/genops.c
index f1fb64b..c6dc3ba 100644
--- a/fs/lustre/obdclass/genops.c
+++ b/fs/lustre/obdclass/genops.c
@@ -722,7 +722,7 @@ static void class_export_destroy(struct obd_export *exp)
 {
 	struct obd_device *obd = exp->exp_obd;
 
-	LASSERT(refcount_read(&exp->exp_refcount) == 0);
+	LASSERT(refcount_read(&exp->exp_handle.h_ref) == 0);
 	LASSERT(obd);
 
 	CDEBUG(D_IOCTL, "destroying export %p/%s for %s\n", exp,
@@ -746,33 +746,28 @@ static void class_export_destroy(struct obd_export *exp)
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
@@ -822,7 +817,7 @@ static struct obd_export *__class_new_export(struct obd_device *obd,
 
 	export->exp_conn_cnt = 0;
 	/* 2 = class_handle_hash + last */
-	refcount_set(&export->exp_refcount, 2);
+	refcount_set(&export->exp_handle.h_ref, 2);
 	atomic_set(&export->exp_rpc_count, 0);
 	atomic_set(&export->exp_cb_count, 0);
 	atomic_set(&export->exp_locks_count, 0);
@@ -925,7 +920,7 @@ static void class_import_destroy(struct obd_import *imp)
 	CDEBUG(D_IOCTL, "destroying import %p for %s\n", imp,
 	       imp->imp_obd->obd_name);
 
-	LASSERT_ATOMIC_ZERO(&imp->imp_refcount);
+	LASSERT(refcount_read(&imp->imp_handle.h_ref) == 0);
 
 	ptlrpc_put_connection_superhack(imp->imp_connection);
 
@@ -942,21 +937,16 @@ static void class_import_destroy(struct obd_import *imp)
 	OBD_FREE_RCU(imp, sizeof(*imp), &imp->imp_handle);
 }
 
-static void import_handle_addref(void *import)
-{
-	class_import_get(import);
-}
-
 static struct portals_handle_ops import_handle_ops = {
-	.hop_addref	= import_handle_addref,
 	.hop_free	= NULL,
+	.hop_type	= "import",
 };
 
 struct obd_import *class_import_get(struct obd_import *import)
 {
-	atomic_inc(&import->imp_refcount);
-	CDEBUG(D_INFO, "import %p refcount=%d obd=%s\n", import,
-	       atomic_read(&import->imp_refcount),
+	refcount_inc(&import->imp_handle.h_ref);
+	CDEBUG(D_INFO, "GET import %p refcount=%d obd=%s\n", import,
+	       refcount_read(&import->imp_handle.h_ref),
 	       import->imp_obd->obd_name);
 	return import;
 }
@@ -964,19 +954,19 @@ struct obd_import *class_import_get(struct obd_import *import)
 
 void class_import_put(struct obd_import *imp)
 {
-	LASSERT_ATOMIC_GT_LT(&imp->imp_refcount, 0, LI_POISON);
+	LASSERT(refcount_read(&imp->imp_handle.h_ref) > 0);
 
 	CDEBUG(D_INFO, "import %p refcount=%d obd=%s\n", imp,
-	       atomic_read(&imp->imp_refcount) - 1,
+	       refcount_read(&imp->imp_handle.h_ref) - 1,
 	       imp->imp_obd->obd_name);
 
-	if (atomic_dec_and_test(&imp->imp_refcount)) {
+	if (refcount_dec_and_test(&imp->imp_handle.h_ref)) {
 		CDEBUG(D_INFO, "final put import %p\n", imp);
 		obd_zombie_import_add(imp);
 	}
 
 	/* catch possible import put race */
-	LASSERT_ATOMIC_GE_LT(&imp->imp_refcount, 0, LI_POISON);
+	LASSERT(refcount_read(&imp->imp_handle.h_ref) >= 0);
 }
 EXPORT_SYMBOL(class_import_put);
 
@@ -1026,7 +1016,7 @@ struct obd_import *class_new_import(struct obd_device *obd)
 	init_waitqueue_head(&imp->imp_recovery_waitq);
 	INIT_WORK(&imp->imp_zombie_work, obd_zombie_imp_cull);
 
-	atomic_set(&imp->imp_refcount, 2);
+	refcount_set(&imp->imp_handle.h_ref, 2);
 	atomic_set(&imp->imp_unregistering, 0);
 	atomic_set(&imp->imp_inflight, 0);
 	atomic_set(&imp->imp_replay_inflight, 0);
diff --git a/fs/lustre/obdclass/lustre_handles.c b/fs/lustre/obdclass/lustre_handles.c
index 32b70d6..32cd6ae 100644
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
index baf34c8..6f00eee 100644
--- a/fs/lustre/obdecho/echo_client.c
+++ b/fs/lustre/obdecho/echo_client.c
@@ -1638,7 +1638,7 @@ static int echo_client_cleanup(struct obd_device *obddev)
 		return -EBUSY;
 	}
 
-	LASSERT(refcount_read(&ec->ec_exp->exp_refcount) > 0);
+	LASSERT(refcount_read(&ec->ec_exp->exp_handle.h_ref) > 0);
 	rc = obd_disconnect(ec->ec_exp);
 	if (rc != 0)
 		CERROR("fail to disconnect device: %d\n", rc);
diff --git a/fs/lustre/ptlrpc/service.c b/fs/lustre/ptlrpc/service.c
index 5a7e9fa..5e541ca 100644
--- a/fs/lustre/ptlrpc/service.c
+++ b/fs/lustre/ptlrpc/service.c
@@ -1697,7 +1697,7 @@ static bool ptlrpc_server_normal_pending(struct ptlrpc_service_part *svcpt,
 	       (request->rq_export ?
 		(char *)request->rq_export->exp_client_uuid.uuid : "0"),
 	       (request->rq_export ?
-		refcount_read(&request->rq_export->exp_refcount) : -99),
+		refcount_read(&request->rq_export->exp_handle.h_ref) : -99),
 	       lustre_msg_get_status(request->rq_reqmsg), request->rq_xid,
 	       libcfs_id2str(request->rq_peer),
 	       lustre_msg_get_opc(request->rq_reqmsg));
@@ -1741,7 +1741,7 @@ static bool ptlrpc_server_normal_pending(struct ptlrpc_service_part *svcpt,
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
