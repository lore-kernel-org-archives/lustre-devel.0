From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Mon, 28 Sep 2015 23:43:59 -0400
Subject: [lustre-devel] [PATCH 16/29] staging/lustre/ptlrpc: Drop unused
	client code
In-Reply-To: <1443498252-1974801-1-git-send-email-green@linuxhacker.ru>
References: <1443498252-1974801-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1443498252-1974801-17-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Oleg Drokin <green@linuxhacker.ru>

These client request/import functions are not used anywhere,
so drop them.

Reported-by: Arnd Bergmann <arnd@arndb.de>
Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/include/lustre_net.h | 13 ---
 drivers/staging/lustre/lustre/ptlrpc/client.c      | 95 ----------------------
 drivers/staging/lustre/lustre/ptlrpc/import.c      | 11 ---
 3 files changed, 119 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_net.h b/drivers/staging/lustre/lustre/include/lustre_net.h
index 6df3e70..a486c1d 100644
--- a/drivers/staging/lustre/lustre/include/lustre_net.h
+++ b/drivers/staging/lustre/lustre/include/lustre_net.h
@@ -2356,22 +2356,17 @@ void ptlrpc_request_committed(struct ptlrpc_request *req, int force);
 
 void ptlrpc_init_client(int req_portal, int rep_portal, char *name,
 			struct ptlrpc_client *);
-void ptlrpc_cleanup_client(struct obd_import *imp);
 struct ptlrpc_connection *ptlrpc_uuid_to_connection(struct obd_uuid *uuid);
 
 int ptlrpc_queue_wait(struct ptlrpc_request *req);
 int ptlrpc_replay_req(struct ptlrpc_request *req);
 int ptlrpc_unregister_reply(struct ptlrpc_request *req, int async);
-void ptlrpc_restart_req(struct ptlrpc_request *req);
 void ptlrpc_abort_inflight(struct obd_import *imp);
-void ptlrpc_cleanup_imp(struct obd_import *imp);
 void ptlrpc_abort_set(struct ptlrpc_request_set *set);
 
 struct ptlrpc_request_set *ptlrpc_prep_set(void);
 struct ptlrpc_request_set *ptlrpc_prep_fcset(int max, set_producer_func func,
 					     void *arg);
-int ptlrpc_set_add_cb(struct ptlrpc_request_set *set,
-		      set_interpreter_func fn, void *data);
 int ptlrpc_set_next_timeout(struct ptlrpc_request_set *);
 int ptlrpc_check_set(const struct lu_env *env, struct ptlrpc_request_set *set);
 int ptlrpc_set_wait(struct ptlrpc_request_set *);
@@ -2405,15 +2400,7 @@ struct ptlrpc_request *ptlrpc_request_alloc_pack(struct obd_import *imp,
 int ptlrpc_request_bufs_pack(struct ptlrpc_request *request,
 			     __u32 version, int opcode, char **bufs,
 			     struct ptlrpc_cli_ctx *ctx);
-struct ptlrpc_request *ptlrpc_prep_req(struct obd_import *imp, __u32 version,
-				       int opcode, int count, __u32 *lengths,
-				       char **bufs);
-struct ptlrpc_request *ptlrpc_prep_req_pool(struct obd_import *imp,
-					     __u32 version, int opcode,
-					    int count, __u32 *lengths, char **bufs,
-					    struct ptlrpc_request_pool *pool);
 void ptlrpc_req_finished(struct ptlrpc_request *request);
-void ptlrpc_req_finished_with_imp_lock(struct ptlrpc_request *request);
 struct ptlrpc_request *ptlrpc_request_addref(struct ptlrpc_request *req);
 struct ptlrpc_bulk_desc *ptlrpc_prep_bulk_imp(struct ptlrpc_request *req,
 					      unsigned npages, unsigned max_brw,
diff --git a/drivers/staging/lustre/lustre/ptlrpc/client.c b/drivers/staging/lustre/lustre/ptlrpc/client.c
index d013d4b..6aaa5dd 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/client.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/client.c
@@ -802,48 +802,6 @@ struct ptlrpc_request *ptlrpc_request_alloc_pack(struct obd_import *imp,
 EXPORT_SYMBOL(ptlrpc_request_alloc_pack);
 
 /**
- * Prepare request (fetched from pool \a pool if not NULL) on import \a imp
- * for operation \a opcode. Request would contain \a count buffers.
- * Sizes of buffers are described in array \a lengths and buffers themselves
- * are provided by a pointer \a bufs.
- * Returns prepared request structure pointer or NULL on error.
- */
-struct ptlrpc_request *
-ptlrpc_prep_req_pool(struct obd_import *imp,
-		     __u32 version, int opcode,
-		     int count, __u32 *lengths, char **bufs,
-		     struct ptlrpc_request_pool *pool)
-{
-	struct ptlrpc_request *request;
-	int rc;
-
-	request = __ptlrpc_request_alloc(imp, pool);
-	if (!request)
-		return NULL;
-
-	rc = __ptlrpc_request_bufs_pack(request, version, opcode, count,
-					lengths, bufs, NULL);
-	if (rc) {
-		ptlrpc_request_free(request);
-		request = NULL;
-	}
-	return request;
-}
-EXPORT_SYMBOL(ptlrpc_prep_req_pool);
-
-/**
- * Same as ptlrpc_prep_req_pool, but without pool
- */
-struct ptlrpc_request *
-ptlrpc_prep_req(struct obd_import *imp, __u32 version, int opcode, int count,
-		__u32 *lengths, char **bufs)
-{
-	return ptlrpc_prep_req_pool(imp, version, opcode, count, lengths, bufs,
-				    NULL);
-}
-EXPORT_SYMBOL(ptlrpc_prep_req);
-
-/**
  * Allocate and initialize new request set structure on the current CPT.
  * Returns a pointer to the newly allocated set structure or NULL on error.
  */
@@ -959,28 +917,6 @@ void ptlrpc_set_destroy(struct ptlrpc_request_set *set)
 EXPORT_SYMBOL(ptlrpc_set_destroy);
 
 /**
- * Add a callback function \a fn to the set.
- * This function would be called when all requests on this set are completed.
- * The function will be passed \a data argument.
- */
-int ptlrpc_set_add_cb(struct ptlrpc_request_set *set,
-		      set_interpreter_func fn, void *data)
-{
-	struct ptlrpc_set_cbdata *cbdata;
-
-	cbdata = kzalloc(sizeof(*cbdata), GFP_NOFS);
-	if (!cbdata)
-		return -ENOMEM;
-
-	cbdata->psc_interpret = fn;
-	cbdata->psc_data = data;
-	list_add_tail(&cbdata->psc_item, &set->set_cblist);
-
-	return 0;
-}
-EXPORT_SYMBOL(ptlrpc_set_add_cb);
-
-/**
  * Add a new request to the general purpose request set.
  * Assumes request reference from the caller.
  */
@@ -2282,18 +2218,6 @@ static void __ptlrpc_free_req(struct ptlrpc_request *request, int locked)
 		ptlrpc_request_cache_free(request);
 }
 
-static int __ptlrpc_req_finished(struct ptlrpc_request *request, int locked);
-/**
- * Drop one request reference. Must be called with import imp_lock held.
- * When reference count drops to zero, request is freed.
- */
-void ptlrpc_req_finished_with_imp_lock(struct ptlrpc_request *request)
-{
-	assert_spin_locked(&request->rq_import->imp_lock);
-	(void)__ptlrpc_req_finished(request, 1);
-}
-EXPORT_SYMBOL(ptlrpc_req_finished_with_imp_lock);
-
 /**
  * Helper function
  * Drops one reference count for request \a request.
@@ -2535,11 +2459,6 @@ free_req:
 	}
 }
 
-void ptlrpc_cleanup_client(struct obd_import *imp)
-{
-}
-EXPORT_SYMBOL(ptlrpc_cleanup_client);
-
 /**
  * Schedule previously sent request for resend.
  * For bulk requests we assign new xid (to avoid problems with
@@ -2578,20 +2497,6 @@ void ptlrpc_resend_req(struct ptlrpc_request *req)
 }
 EXPORT_SYMBOL(ptlrpc_resend_req);
 
-/* XXX: this function and rq_status are currently unused */
-void ptlrpc_restart_req(struct ptlrpc_request *req)
-{
-	DEBUG_REQ(D_HA, req, "restarting (possibly-)completed request");
-	req->rq_status = -ERESTARTSYS;
-
-	spin_lock(&req->rq_lock);
-	req->rq_restart = 1;
-	req->rq_timedout = 0;
-	ptlrpc_client_wake_req(req);
-	spin_unlock(&req->rq_lock);
-}
-EXPORT_SYMBOL(ptlrpc_restart_req);
-
 /**
  * Grab additional reference on a request \a req
  */
diff --git a/drivers/staging/lustre/lustre/ptlrpc/import.c b/drivers/staging/lustre/lustre/ptlrpc/import.c
index 9ff1a22..1ac265d 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/import.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/import.c
@@ -142,7 +142,6 @@ void deuuidify(char *uuid, const char *prefix, char **uuid_start, int *uuid_len)
 		    UUID_STR, strlen(UUID_STR)))
 		*uuid_len -= strlen(UUID_STR);
 }
-EXPORT_SYMBOL(deuuidify);
 
 /**
  * Returns true if import was FULL, false if import was already not
@@ -1503,16 +1502,6 @@ out:
 }
 EXPORT_SYMBOL(ptlrpc_disconnect_import);
 
-void ptlrpc_cleanup_imp(struct obd_import *imp)
-{
-	spin_lock(&imp->imp_lock);
-	IMPORT_SET_STATE_NOLOCK(imp, LUSTRE_IMP_CLOSED);
-	imp->imp_generation++;
-	spin_unlock(&imp->imp_lock);
-	ptlrpc_abort_inflight(imp);
-}
-EXPORT_SYMBOL(ptlrpc_cleanup_imp);
-
 /* Adaptive Timeout utils */
 extern unsigned int at_min, at_max, at_history;
 
-- 
2.1.0
