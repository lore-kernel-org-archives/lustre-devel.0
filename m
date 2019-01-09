From: NeilBrown <neilb@suse.com>
Date: Wed, 09 Jan 2019 17:24:02 +1100
Subject: [lustre-devel] [PATCH 25/29] lustre: remove cl_page_cancel()
In-Reply-To: <154701488711.26726.17363928508883972338.stgit@noble>
References: <154701488711.26726.17363928508883972338.stgit@noble>
Message-ID: <154701504264.26726.17608454548660581136.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

cl_page_cancel() is never used, so remove it and various
other things that it is the only user of.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/include/cl_object.h  |   18 -----
 drivers/staging/lustre/lustre/include/lustre_net.h |    1 
 drivers/staging/lustre/lustre/obdclass/cl_page.c   |   20 ------
 drivers/staging/lustre/lustre/osc/osc_cache.c      |   67 --------------------
 .../staging/lustre/lustre/osc/osc_cl_internal.h    |    1 
 drivers/staging/lustre/lustre/osc/osc_internal.h   |    1 
 drivers/staging/lustre/lustre/osc/osc_page.c       |   20 ------
 drivers/staging/lustre/lustre/osc/osc_request.c    |    9 ---
 drivers/staging/lustre/lustre/ptlrpc/client.c      |   15 +---
 9 files changed, 4 insertions(+), 148 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/cl_object.h b/drivers/staging/lustre/lustre/include/cl_object.h
index a1e07f8b5eda..de5d68879740 100644
--- a/drivers/staging/lustre/lustre/include/cl_object.h
+++ b/drivers/staging/lustre/lustre/include/cl_object.h
@@ -969,23 +969,6 @@ struct cl_page_operations {
 	void (*cpo_clip)(const struct lu_env *env,
 			 const struct cl_page_slice *slice,
 			 int from, int to);
-	/**
-	 * \pre  the page was queued for transferring.
-	 * \post page is removed from client's pending list, or -EBUSY
-	 *       is returned if it has already been in transferring.
-	 *
-	 * This is one of seldom page operation which is:
-	 * 0. called from top level;
-	 * 1. don't have vmpage locked;
-	 * 2. every layer should synchronize execution of its ->cpo_cancel()
-	 *    with completion handlers. Osc uses client obd lock for this
-	 *    purpose. Based on there is no vvp_page_cancel and
-	 *    lov_page_cancel(), cpo_cancel is defacto protected by client lock.
-	 *
-	 * \see osc_page_cancel().
-	 */
-	int (*cpo_cancel)(const struct lu_env *env,
-			  const struct cl_page_slice *slice);
 	/**
 	 * Write out a page by kernel. This is only called by ll_writepage
 	 * right now.
@@ -2159,7 +2142,6 @@ int cl_page_cache_add(const struct lu_env *env, struct cl_io *io,
 		      struct cl_page *pg, enum cl_req_type crt);
 void cl_page_clip(const struct lu_env *env, struct cl_page *pg,
 		  int from, int to);
-int cl_page_cancel(const struct lu_env *env, struct cl_page *page);
 int cl_page_flush(const struct lu_env *env, struct cl_io *io,
 		  struct cl_page *pg);
 
diff --git a/drivers/staging/lustre/lustre/include/lustre_net.h b/drivers/staging/lustre/lustre/include/lustre_net.h
index 468a03edefd9..6d328b48a96b 100644
--- a/drivers/staging/lustre/lustre/include/lustre_net.h
+++ b/drivers/staging/lustre/lustre/include/lustre_net.h
@@ -1830,7 +1830,6 @@ struct ptlrpc_request_set *ptlrpc_prep_fcset(int max, set_producer_func func,
 					     void *arg);
 int ptlrpc_check_set(const struct lu_env *env, struct ptlrpc_request_set *set);
 int ptlrpc_set_wait(struct ptlrpc_request_set *);
-void ptlrpc_mark_interrupted(struct ptlrpc_request *req);
 void ptlrpc_set_destroy(struct ptlrpc_request_set *);
 void ptlrpc_set_add_req(struct ptlrpc_request_set *, struct ptlrpc_request *);
 
diff --git a/drivers/staging/lustre/lustre/obdclass/cl_page.c b/drivers/staging/lustre/lustre/obdclass/cl_page.c
index 00df94b87606..217a5ebe1691 100644
--- a/drivers/staging/lustre/lustre/obdclass/cl_page.c
+++ b/drivers/staging/lustre/lustre/obdclass/cl_page.c
@@ -932,26 +932,6 @@ void cl_page_print(const struct lu_env *env, void *cookie,
 }
 EXPORT_SYMBOL(cl_page_print);
 
-/**
- * Cancel a page which is still in a transfer.
- */
-int cl_page_cancel(const struct lu_env *env, struct cl_page *page)
-{
-	const struct cl_page_slice *slice;
-	int result = 0;
-
-	list_for_each_entry(slice, &page->cp_layers, cpl_linkage) {
-		if (slice->cpl_ops->cpo_cancel)
-			result = (*slice->cpl_ops->cpo_cancel)(env, slice);
-		if (result != 0)
-			break;
-	}
-	if (result > 0)
-		result = 0;
-
-	return result;
-}
-
 /**
  * Converts a byte offset within object \a obj into a page index.
  */
diff --git a/drivers/staging/lustre/lustre/osc/osc_cache.c b/drivers/staging/lustre/lustre/osc/osc_cache.c
index 1476f84e6156..79bcaa212339 100644
--- a/drivers/staging/lustre/lustre/osc/osc_cache.c
+++ b/drivers/staging/lustre/lustre/osc/osc_cache.c
@@ -1822,7 +1822,6 @@ static void osc_ap_completion(const struct lu_env *env, struct client_obd *cli,
 	spin_lock(&oap->oap_lock);
 	oap->oap_async_flags = 0;
 	spin_unlock(&oap->oap_lock);
-	oap->oap_interrupted = 0;
 
 	if (oap->oap_cmd & OBD_BRW_WRITE && xid > 0) {
 		spin_lock(&cli->cl_loi_list_lock);
@@ -2591,72 +2590,6 @@ int osc_flush_async_page(const struct lu_env *env, struct cl_io *io,
 	return rc;
 }
 
-/**
- * this is called when a sync waiter receives an interruption.  Its job is to
- * get the caller woken as soon as possible.  If its page hasn't been put in an
- * rpc yet it can dequeue immediately.  Otherwise it has to mark the rpc as
- * desiring interruption which will forcefully complete the rpc once the rpc
- * has timed out.
- */
-int osc_cancel_async_page(const struct lu_env *env, struct osc_page *ops)
-{
-	struct osc_async_page *oap = &ops->ops_oap;
-	struct osc_object *obj = oap->oap_obj;
-	struct client_obd *cli = osc_cli(obj);
-	struct osc_extent *ext;
-	struct osc_extent *found = NULL;
-	struct list_head *plist;
-	pgoff_t index = osc_index(ops);
-	int rc = -EBUSY;
-	int cmd;
-
-	LASSERT(!oap->oap_interrupted);
-	oap->oap_interrupted = 1;
-
-	/* Find out the caching extent */
-	osc_object_lock(obj);
-	if (oap->oap_cmd & OBD_BRW_WRITE) {
-		plist = &obj->oo_urgent_exts;
-		cmd = OBD_BRW_WRITE;
-	} else {
-		plist = &obj->oo_reading_exts;
-		cmd = OBD_BRW_READ;
-	}
-	list_for_each_entry(ext, plist, oe_link) {
-		if (ext->oe_start <= index && ext->oe_end >= index) {
-			LASSERT(ext->oe_state == OES_LOCK_DONE);
-			/* For OES_LOCK_DONE state extent, it has already held
-			 * a refcount for RPC.
-			 */
-			found = osc_extent_get(ext);
-			break;
-		}
-	}
-	if (found) {
-		list_del_init(&found->oe_link);
-		osc_update_pending(obj, cmd, -found->oe_nr_pages);
-		osc_object_unlock(obj);
-
-		osc_extent_finish(env, found, 0, -EINTR);
-		osc_extent_put(env, found);
-		rc = 0;
-	} else {
-		osc_object_unlock(obj);
-		/* ok, it's been put in an rpc. only one oap gets a request
-		 * reference
-		 */
-		if (oap->oap_request) {
-			ptlrpc_mark_interrupted(oap->oap_request);
-			ptlrpcd_wake(oap->oap_request);
-			ptlrpc_req_finished(oap->oap_request);
-			oap->oap_request = NULL;
-		}
-	}
-
-	osc_list_maint(cli, obj);
-	return rc;
-}
-
 int osc_queue_sync_pages(const struct lu_env *env, struct osc_object *obj,
 			 struct list_head *list, int cmd, int brw_flags)
 {
diff --git a/drivers/staging/lustre/lustre/osc/osc_cl_internal.h b/drivers/staging/lustre/lustre/osc/osc_cl_internal.h
index b1a1d241cc6c..3af096e0dbdd 100644
--- a/drivers/staging/lustre/lustre/osc/osc_cl_internal.h
+++ b/drivers/staging/lustre/lustre/osc/osc_cl_internal.h
@@ -380,7 +380,6 @@ int osc_lvb_print(const struct lu_env *env, void *cookie,
 void osc_lru_add_batch(struct client_obd *cli, struct list_head *list);
 void osc_page_submit(const struct lu_env *env, struct osc_page *opg,
 		     enum cl_req_type crt, int brw_flags);
-int osc_cancel_async_page(const struct lu_env *env, struct osc_page *ops);
 int osc_set_async_flags(struct osc_object *obj, struct osc_page *opg,
 			u32 async_flags);
 int osc_prep_async_page(struct osc_object *osc, struct osc_page *ops,
diff --git a/drivers/staging/lustre/lustre/osc/osc_internal.h b/drivers/staging/lustre/lustre/osc/osc_internal.h
index 0354272fe192..586f0dfe3790 100644
--- a/drivers/staging/lustre/lustre/osc/osc_internal.h
+++ b/drivers/staging/lustre/lustre/osc/osc_internal.h
@@ -60,7 +60,6 @@ enum async_flags {
 struct osc_async_page {
 	int				oap_magic;
 	unsigned short			oap_cmd;
-	unsigned short			oap_interrupted:1;
 
 	struct list_head		oap_pending_item;
 	struct list_head		oap_rpc_item;
diff --git a/drivers/staging/lustre/lustre/osc/osc_page.c b/drivers/staging/lustre/lustre/osc/osc_page.c
index 28b12729d7e9..e0187fafcc37 100644
--- a/drivers/staging/lustre/lustre/osc/osc_page.c
+++ b/drivers/staging/lustre/lustre/osc/osc_page.c
@@ -137,11 +137,10 @@ static int osc_page_print(const struct lu_env *env,
 	struct osc_object *obj = cl2osc(slice->cpl_obj);
 	struct client_obd *cli = &osc_export(obj)->exp_obd->u.cli;
 
-	return (*printer)(env, cookie, LUSTRE_OSC_NAME "-page@%p %lu: 1< %#x %d %u %s %s > 2< %llu %u %u %#x %#x | %p %p %p > 3< %d %lu %d > 4< %d %d %d %lu %s | %s %s %s %s > 5< %s %s %s %s | %d %s | %d %s %s>\n",
+	return (*printer)(env, cookie, LUSTRE_OSC_NAME "-page@%p %lu: 1< %#x %d %s %s > 2< %llu %u %u %#x %#x | %p %p %p > 3< %d %lu %d > 4< %d %d %d %lu %s | %s %s %s %s > 5< %s %s %s %s | %d %s | %d %s %s>\n",
 			  opg, osc_index(opg),
 			  /* 1 */
 			  oap->oap_magic, oap->oap_cmd,
-			  oap->oap_interrupted,
 			  osc_list(&oap->oap_pending_item),
 			  osc_list(&oap->oap_rpc_item),
 			  /* 2 */
@@ -216,22 +215,6 @@ static void osc_page_clip(const struct lu_env *env,
 	spin_unlock(&oap->oap_lock);
 }
 
-static int osc_page_cancel(const struct lu_env *env,
-			   const struct cl_page_slice *slice)
-{
-	struct osc_page *opg = cl2osc_page(slice);
-	int rc = 0;
-
-	/* Check if the transferring against this page
-	 * is completed, or not even queued.
-	 */
-	if (opg->ops_transfer_pinned)
-		/* FIXME: may not be interrupted.. */
-		rc = osc_cancel_async_page(env, opg);
-	LASSERT(ergo(rc == 0, opg->ops_transfer_pinned == 0));
-	return rc;
-}
-
 static int osc_page_flush(const struct lu_env *env,
 			  const struct cl_page_slice *slice,
 			  struct cl_io *io)
@@ -247,7 +230,6 @@ static const struct cl_page_operations osc_page_ops = {
 	.cpo_print	 = osc_page_print,
 	.cpo_delete	= osc_page_delete,
 	.cpo_clip	   = osc_page_clip,
-	.cpo_cancel	 = osc_page_cancel,
 	.cpo_flush	  = osc_page_flush
 };
 
diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
index b28fbacbcfbf..ccc491efa982 100644
--- a/drivers/staging/lustre/lustre/osc/osc_request.c
+++ b/drivers/staging/lustre/lustre/osc/osc_request.c
@@ -1635,10 +1635,6 @@ static int osc_brw_redo_request(struct ptlrpc_request *request,
 			LASSERTF(request == oap->oap_request,
 				 "request %p != oap_request %p\n",
 				 request, oap->oap_request);
-			if (oap->oap_interrupted) {
-				ptlrpc_req_finished(new_req);
-				return -EINTR;
-			}
 		}
 	}
 	/* New request takes over pga and oaps from old request.
@@ -1879,7 +1875,6 @@ int osc_build_rpc(const struct lu_env *env, struct client_obd *cli,
 	int mem_tight = 0;
 	int page_count = 0;
 	bool soft_sync = false;
-	bool interrupted = false;
 	int grant = 0;
 	int i;
 	int rc;
@@ -1937,8 +1932,6 @@ int osc_build_rpc(const struct lu_env *env, struct client_obd *cli,
 			else
 				LASSERT(oap->oap_page_off + oap->oap_count ==
 					PAGE_SIZE);
-			if (oap->oap_interrupted)
-				interrupted = true;
 		}
 	}
 
@@ -1968,8 +1961,6 @@ int osc_build_rpc(const struct lu_env *env, struct client_obd *cli,
 
 	req->rq_memalloc = mem_tight != 0;
 	oap->oap_request = ptlrpc_request_addref(req);
-	if (interrupted && !req->rq_intr)
-		ptlrpc_mark_interrupted(req);
 
 	/* Need to update the timestamps after the request is built in case
 	 * we race with setattr (locally or in queue at OST).  If OST gets
diff --git a/drivers/staging/lustre/lustre/ptlrpc/client.c b/drivers/staging/lustre/lustre/ptlrpc/client.c
index 8fafc8dc3f57..f90a3eef5daf 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/client.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/client.c
@@ -2148,17 +2148,6 @@ void ptlrpc_expired_set(struct ptlrpc_request_set *set)
 	}
 }
 
-/**
- * Sets rq_intr flag in \a req under spinlock.
- */
-void ptlrpc_mark_interrupted(struct ptlrpc_request *req)
-{
-	spin_lock(&req->rq_lock);
-	req->rq_intr = 1;
-	spin_unlock(&req->rq_lock);
-}
-EXPORT_SYMBOL(ptlrpc_mark_interrupted);
-
 /**
  * Interrupts (sets interrupted flag) all uncompleted requests in
  * a set \a data. Called when l_wait_event_abortable_timeout receives signal.
@@ -2174,7 +2163,9 @@ static void ptlrpc_interrupted_set(struct ptlrpc_request_set *set)
 		    req->rq_phase != RQ_PHASE_UNREG_RPC)
 			continue;
 
-		ptlrpc_mark_interrupted(req);
+		spin_lock(&req->rq_lock);
+		req->rq_intr = 1;
+		spin_unlock(&req->rq_lock);
 	}
 }
 
