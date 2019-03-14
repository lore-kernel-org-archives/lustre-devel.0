From: NeilBrown <neilb@suse.com>
Date: Thu, 14 Mar 2019 11:11:51 +1100
Subject: [lustre-devel] [PATCH 24/32] lustre: ptlrpc: discard cb_list and
 ptlrpc_set_cbdata; 
In-Reply-To: <155252182126.26912.1842463462595601611.stgit@noble.brown>
References: <155252182126.26912.1842463462595601611.stgit@noble.brown>
Message-ID: <155252231117.26912.1607797445240466639.stgit@noble.brown>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

This field is never set, and no objects of the struct
are ever created, so both can be discarded.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/include/lustre_net.h |   18 ------------------
 drivers/staging/lustre/lustre/ptlrpc/client.c      |   13 -------------
 2 files changed, 31 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_net.h b/drivers/staging/lustre/lustre/include/lustre_net.h
index 73d50fe39501..8c61b02a0ae5 100644
--- a/drivers/staging/lustre/lustre/include/lustre_net.h
+++ b/drivers/staging/lustre/lustre/include/lustre_net.h
@@ -356,12 +356,6 @@ struct ptlrpc_request_set {
 	wait_queue_head_t	*set_wakeup_ptr;
 	/** List of requests in the set */
 	struct list_head	set_requests;
-	/**
-	 * List of completion callbacks to be called when the set is completed
-	 * This is only used if @set_interpret is NULL.
-	 * Links struct ptlrpc_set_cbdata.
-	 */
-	struct list_head	set_cblist;
 	/** Completion callback, if only one. */
 	set_interpreter_func	set_interpret;
 	/** opaq argument passed to completion @set_interpret callback. */
@@ -386,18 +380,6 @@ struct ptlrpc_request_set {
 	void			*set_producer_arg;
 };
 
-/**
- * Description of a single ptrlrpc_set callback
- */
-struct ptlrpc_set_cbdata {
-	/** List linkage item */
-	struct list_head	psc_item;
-	/** Pointer to interpreting function */
-	set_interpreter_func    psc_interpret;
-	/** Opaq argument to pass to the callback */
-	void			*psc_data;
-};
-
 struct ptlrpc_bulk_desc;
 struct ptlrpc_service_part;
 struct ptlrpc_service;
diff --git a/drivers/staging/lustre/lustre/ptlrpc/client.c b/drivers/staging/lustre/lustre/ptlrpc/client.c
index ddf44c854200..1ee1ad4ca088 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/client.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/client.c
@@ -932,7 +932,6 @@ struct ptlrpc_request_set *ptlrpc_prep_set(void)
 	atomic_set(&set->set_remaining, 0);
 	spin_lock_init(&set->set_new_req_lock);
 	INIT_LIST_HEAD(&set->set_new_requests);
-	INIT_LIST_HEAD(&set->set_cblist);
 	set->set_max_inflight = UINT_MAX;
 	set->set_producer = NULL;
 	set->set_producer_arg = NULL;
@@ -2297,18 +2296,6 @@ int ptlrpc_set_wait(struct ptlrpc_request_set *set)
 		int (*interpreter)(struct ptlrpc_request_set *set, void *, int) =
 			set->set_interpret;
 		rc = interpreter(set, set->set_arg, rc);
-	} else {
-		struct ptlrpc_set_cbdata *cbdata, *n;
-		int err;
-
-		list_for_each_entry_safe(cbdata, n,
-					 &set->set_cblist, psc_item) {
-			list_del_init(&cbdata->psc_item);
-			err = cbdata->psc_interpret(set, cbdata->psc_data, rc);
-			if (err && !rc)
-				rc = err;
-			kfree(cbdata);
-		}
 	}
 
 	return rc;
