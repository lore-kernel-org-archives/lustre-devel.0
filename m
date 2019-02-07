From: NeilBrown <neilb@suse.com>
Date: Thu, 07 Feb 2019 11:03:33 +1100
Subject: [lustre-devel] [PATCH 21/21] lustre: make exp_refcount in
 obd_export a refcount_t
In-Reply-To: <154949776249.10620.1215070753973826063.stgit@noble.brown>
References: <154949776249.10620.1215070753973826063.stgit@noble.brown>
Message-ID: <154949781349.10620.3269248433038576631.stgit@noble.brown>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

As this is used as a refcount, it should be declared
as one.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../staging/lustre/lustre/include/lustre_export.h  |    2 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_lock.c     |   10 +++++-----
 drivers/staging/lustre/lustre/obdclass/genops.c    |   15 ++++++++-------
 .../staging/lustre/lustre/obdecho/echo_client.c    |    2 +-
 drivers/staging/lustre/lustre/ptlrpc/service.c     |    4 ++--
 5 files changed, 17 insertions(+), 16 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_export.h b/drivers/staging/lustre/lustre/include/lustre_export.h
index 63fa656eb7ba..fb34e0b7de35 100644
--- a/drivers/staging/lustre/lustre/include/lustre_export.h
+++ b/drivers/staging/lustre/lustre/include/lustre_export.h
@@ -67,7 +67,7 @@ struct obd_export {
 	 * what export they are talking to.
 	 */
 	struct portals_handle		exp_handle;
-	atomic_t			exp_refcount;
+	refcount_t			exp_refcount;
 	/**
 	 * Set of counters below is to track where export references are
 	 * kept. The exp_rpc_count is used for reconnect handling also,
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
index cea0e22d064b..f2433dc0e558 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
@@ -1998,7 +1998,7 @@ void _ldlm_lock_debug(struct ldlm_lock *lock,
 				   ldlm_lockname[lock->l_req_mode],
 				   lock->l_flags, nid,
 				   lock->l_remote_handle.cookie,
-				   exp ? atomic_read(&exp->exp_refcount) : -99,
+				   exp ? refcount_read(&exp->exp_refcount) : -99,
 				   lock->l_pid, lock->l_callback_timeout,
 				   lock->l_lvb_type);
 		va_end(args);
@@ -2024,7 +2024,7 @@ void _ldlm_lock_debug(struct ldlm_lock *lock,
 				   lock->l_req_extent.end,
 				   lock->l_flags, nid,
 				   lock->l_remote_handle.cookie,
-				   exp ? atomic_read(&exp->exp_refcount) : -99,
+				   exp ? refcount_read(&exp->exp_refcount) : -99,
 				   lock->l_pid, lock->l_callback_timeout,
 				   lock->l_lvb_type);
 		break;
@@ -2046,7 +2046,7 @@ void _ldlm_lock_debug(struct ldlm_lock *lock,
 				   lock->l_policy_data.l_flock.end,
 				   lock->l_flags, nid,
 				   lock->l_remote_handle.cookie,
-				   exp ? atomic_read(&exp->exp_refcount) : -99,
+				   exp ? refcount_read(&exp->exp_refcount) : -99,
 				   lock->l_pid, lock->l_callback_timeout);
 		break;
 
@@ -2065,7 +2065,7 @@ void _ldlm_lock_debug(struct ldlm_lock *lock,
 				   ldlm_typename[resource->lr_type],
 				   lock->l_flags, nid,
 				   lock->l_remote_handle.cookie,
-				   exp ? atomic_read(&exp->exp_refcount) : -99,
+				   exp ? refcount_read(&exp->exp_refcount) : -99,
 				   lock->l_pid, lock->l_callback_timeout,
 				   lock->l_lvb_type);
 		break;
@@ -2084,7 +2084,7 @@ void _ldlm_lock_debug(struct ldlm_lock *lock,
 				   ldlm_typename[resource->lr_type],
 				   lock->l_flags, nid,
 				   lock->l_remote_handle.cookie,
-				   exp ? atomic_read(&exp->exp_refcount) : -99,
+				   exp ? refcount_read(&exp->exp_refcount) : -99,
 				   lock->l_pid, lock->l_callback_timeout,
 				   lock->l_lvb_type);
 		break;
diff --git a/drivers/staging/lustre/lustre/obdclass/genops.c b/drivers/staging/lustre/lustre/obdclass/genops.c
index dad21d9fa328..39919f1c5b71 100644
--- a/drivers/staging/lustre/lustre/obdclass/genops.c
+++ b/drivers/staging/lustre/lustre/obdclass/genops.c
@@ -757,7 +757,7 @@ static void class_export_destroy(struct obd_export *exp)
 {
 	struct obd_device *obd = exp->exp_obd;
 
-	LASSERT_ATOMIC_ZERO(&exp->exp_refcount);
+	LASSERT(refcount_read(&exp->exp_refcount) == 0);
 	LASSERT(obd);
 
 	CDEBUG(D_IOCTL, "destroying export %p/%s for %s\n", exp,
@@ -793,20 +793,21 @@ static struct portals_handle_ops export_handle_ops = {
 
 struct obd_export *class_export_get(struct obd_export *exp)
 {
-	atomic_inc(&exp->exp_refcount);
+	refcount_inc(&exp->exp_refcount);
 	CDEBUG(D_INFO, "GETting export %p : new refcount %d\n", exp,
-	       atomic_read(&exp->exp_refcount));
+	       refcount_read(&exp->exp_refcount));
 	return exp;
 }
 EXPORT_SYMBOL(class_export_get);
 
 void class_export_put(struct obd_export *exp)
 {
-	LASSERT_ATOMIC_GT_LT(&exp->exp_refcount, 0, LI_POISON);
+	LASSERT(refcount_read(&exp->exp_refcount) >  0);
+	LASSERT(refcount_read(&exp->exp_refcount) < LI_POISON);
 	CDEBUG(D_INFO, "PUTting export %p : new refcount %d\n", exp,
-	       atomic_read(&exp->exp_refcount) - 1);
+	       refcount_read(&exp->exp_refcount) - 1);
 
-	if (atomic_dec_and_test(&exp->exp_refcount)) {
+	if (refcount_dec_and_test(&exp->exp_refcount)) {
 		struct obd_device *obd = exp->exp_obd;
 
 		CDEBUG(D_IOCTL, "final put %p/%s\n",
@@ -856,7 +857,7 @@ static struct obd_export *__class_new_export(struct obd_device *obd,
 
 	export->exp_conn_cnt = 0;
 	/* 2 = class_handle_hash + last */
-	atomic_set(&export->exp_refcount, 2);
+	refcount_set(&export->exp_refcount, 2);
 	atomic_set(&export->exp_rpc_count, 0);
 	atomic_set(&export->exp_cb_count, 0);
 	atomic_set(&export->exp_locks_count, 0);
diff --git a/drivers/staging/lustre/lustre/obdecho/echo_client.c b/drivers/staging/lustre/lustre/obdecho/echo_client.c
index 1b7d98c649b6..317123fd27cb 100644
--- a/drivers/staging/lustre/lustre/obdecho/echo_client.c
+++ b/drivers/staging/lustre/lustre/obdecho/echo_client.c
@@ -1638,7 +1638,7 @@ static int echo_client_cleanup(struct obd_device *obddev)
 		return -EBUSY;
 	}
 
-	LASSERT(atomic_read(&ec->ec_exp->exp_refcount) > 0);
+	LASSERT(refcount_read(&ec->ec_exp->exp_refcount) > 0);
 	rc = obd_disconnect(ec->ec_exp);
 	if (rc != 0)
 		CERROR("fail to disconnect device: %d\n", rc);
diff --git a/drivers/staging/lustre/lustre/ptlrpc/service.c b/drivers/staging/lustre/lustre/ptlrpc/service.c
index 35a59e5a5e9d..b7d44fc21d73 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/service.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/service.c
@@ -1697,7 +1697,7 @@ ptlrpc_server_handle_request(struct ptlrpc_service_part *svcpt,
 	       (request->rq_export ?
 		(char *)request->rq_export->exp_client_uuid.uuid : "0"),
 	       (request->rq_export ?
-		atomic_read(&request->rq_export->exp_refcount) : -99),
+		refcount_read(&request->rq_export->exp_refcount) : -99),
 	       lustre_msg_get_status(request->rq_reqmsg), request->rq_xid,
 	       libcfs_id2str(request->rq_peer),
 	       lustre_msg_get_opc(request->rq_reqmsg));
@@ -1741,7 +1741,7 @@ ptlrpc_server_handle_request(struct ptlrpc_service_part *svcpt,
 	       (request->rq_export ?
 		(char *)request->rq_export->exp_client_uuid.uuid : "0"),
 	       (request->rq_export ?
-		atomic_read(&request->rq_export->exp_refcount) : -99),
+		refcount_read(&request->rq_export->exp_refcount) : -99),
 	       lustre_msg_get_status(request->rq_reqmsg),
 	       request->rq_xid,
 	       libcfs_id2str(request->rq_peer),
