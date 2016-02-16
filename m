From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Tue, 16 Feb 2016 00:46:58 -0500
Subject: [lustre-devel] [PATCH 26/45] staging/lustre/ptlrpc: Adjust NULL
	comparison codestyle
In-Reply-To: <1455601637-3847710-1-git-send-email-green@linuxhacker.ru>
References: <1455601637-3847710-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1455601637-3847710-27-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

All instances of "x == NULL" are changed to "!x" and
"x != NULL" to "x"

Also remove some redundant assertions.

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/ptlrpc/client.c      | 75 +++++++++----------
 drivers/staging/lustre/lustre/ptlrpc/connection.c  |  2 +-
 drivers/staging/lustre/lustre/ptlrpc/events.c      |  2 +-
 drivers/staging/lustre/lustre/ptlrpc/import.c      |  9 ++-
 drivers/staging/lustre/lustre/ptlrpc/layout.c      | 26 +++----
 drivers/staging/lustre/lustre/ptlrpc/llog_client.c | 20 +++---
 drivers/staging/lustre/lustre/ptlrpc/llog_net.c    |  2 +-
 .../staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c    | 31 ++++----
 drivers/staging/lustre/lustre/ptlrpc/niobuf.c      | 30 ++++----
 drivers/staging/lustre/lustre/ptlrpc/nrs.c         | 84 +++++++++++-----------
 drivers/staging/lustre/lustre/ptlrpc/nrs_fifo.c    |  6 +-
 .../staging/lustre/lustre/ptlrpc/pack_generic.c    | 14 ++--
 drivers/staging/lustre/lustre/ptlrpc/pinger.c      |  5 +-
 drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c     | 16 ++---
 drivers/staging/lustre/lustre/ptlrpc/recover.c     |  6 +-
 drivers/staging/lustre/lustre/ptlrpc/sec.c         | 54 +++++++-------
 drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c    | 12 ++--
 drivers/staging/lustre/lustre/ptlrpc/sec_config.c  | 24 +++----
 drivers/staging/lustre/lustre/ptlrpc/sec_lproc.c   |  6 +-
 drivers/staging/lustre/lustre/ptlrpc/sec_null.c    |  4 +-
 drivers/staging/lustre/lustre/ptlrpc/sec_plain.c   | 16 ++---
 drivers/staging/lustre/lustre/ptlrpc/service.c     | 76 ++++++++++----------
 22 files changed, 244 insertions(+), 276 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ptlrpc/client.c b/drivers/staging/lustre/lustre/ptlrpc/client.c
index 1cc3c69..9b89068 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/client.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/client.c
@@ -145,7 +145,7 @@ struct ptlrpc_bulk_desc *ptlrpc_prep_bulk_imp(struct ptlrpc_request *req,
 
 	LASSERT(type == BULK_PUT_SINK || type == BULK_GET_SOURCE);
 	desc = ptlrpc_new_bulk(npages, max_brw, type, portal);
-	if (desc == NULL)
+	if (!desc)
 		return NULL;
 
 	desc->bd_import_generation = req->rq_import_generation;
@@ -171,7 +171,7 @@ void __ptlrpc_prep_bulk_page(struct ptlrpc_bulk_desc *desc,
 			     struct page *page, int pageoffset, int len, int pin)
 {
 	LASSERT(desc->bd_iov_count < desc->bd_max_iov);
-	LASSERT(page != NULL);
+	LASSERT(page);
 	LASSERT(pageoffset >= 0);
 	LASSERT(len > 0);
 	LASSERT(pageoffset + len <= PAGE_CACHE_SIZE);
@@ -193,7 +193,6 @@ void __ptlrpc_free_bulk(struct ptlrpc_bulk_desc *desc, int unpin)
 {
 	int i;
 
-	LASSERT(desc != NULL);
 	LASSERT(desc->bd_iov_count != LI_POISON); /* not freed already */
 	LASSERT(desc->bd_md_count == 0);	 /* network hands off */
 	LASSERT((desc->bd_export != NULL) ^ (desc->bd_import != NULL));
@@ -412,7 +411,7 @@ int ptlrpc_request_cache_init(void)
 	request_cache = kmem_cache_create("ptlrpc_cache",
 					  sizeof(struct ptlrpc_request),
 					  0, SLAB_HWCACHE_ALIGN, NULL);
-	return request_cache == NULL ? -ENOMEM : 0;
+	return !request_cache ? -ENOMEM : 0;
 }
 
 void ptlrpc_request_cache_fini(void)
@@ -442,8 +441,6 @@ void ptlrpc_free_rq_pool(struct ptlrpc_request_pool *pool)
 	struct list_head *l, *tmp;
 	struct ptlrpc_request *req;
 
-	LASSERT(pool != NULL);
-
 	spin_lock(&pool->prp_lock);
 	list_for_each_safe(l, tmp, &pool->prp_req_list) {
 		req = list_entry(l, struct ptlrpc_request, rq_list);
@@ -753,7 +750,7 @@ ptlrpc_request_alloc_internal(struct obd_import *imp,
 	struct ptlrpc_request *request;
 
 	request = __ptlrpc_request_alloc(imp, pool);
-	if (request == NULL)
+	if (!request)
 		return NULL;
 
 	req_capsule_init(&request->rq_pill, request, RCL_CLIENT);
@@ -952,10 +949,10 @@ void ptlrpc_set_add_req(struct ptlrpc_request_set *set,
 	atomic_inc(&set->set_remaining);
 	req->rq_queued_time = cfs_time_current();
 
-	if (req->rq_reqmsg != NULL)
+	if (req->rq_reqmsg)
 		lustre_msg_set_jobid(req->rq_reqmsg, NULL);
 
-	if (set->set_producer != NULL)
+	if (set->set_producer)
 		/*
 		 * If the request set has a producer callback, the RPC must be
 		 * sent straight away
@@ -975,7 +972,7 @@ void ptlrpc_set_add_new_req(struct ptlrpcd_ctl *pc,
 	struct ptlrpc_request_set *set = pc->pc_set;
 	int count, i;
 
-	LASSERT(req->rq_set == NULL);
+	LASSERT(!req->rq_set);
 	LASSERT(test_bit(LIOD_STOP, &pc->pc_flags) == 0);
 
 	spin_lock(&set->set_new_req_lock);
@@ -1016,7 +1013,6 @@ static int ptlrpc_import_delay_req(struct obd_import *imp,
 {
 	int delay = 0;
 
-	LASSERT(status != NULL);
 	*status = 0;
 
 	if (req->rq_ctx_init || req->rq_ctx_fini) {
@@ -1079,7 +1075,7 @@ static int ptlrpc_console_allow(struct ptlrpc_request *req)
 	__u32 opc;
 	int err;
 
-	LASSERT(req->rq_reqmsg != NULL);
+	LASSERT(req->rq_reqmsg);
 	opc = lustre_msg_get_opc(req->rq_reqmsg);
 
 	/*
@@ -1168,7 +1164,7 @@ static int after_reply(struct ptlrpc_request *req)
 	struct timespec64 work_start;
 	long timediff;
 
-	LASSERT(obd != NULL);
+	LASSERT(obd);
 	/* repbuf must be unlinked */
 	LASSERT(!req->rq_receiving_reply && !req->rq_reply_unlink);
 
@@ -1248,7 +1244,7 @@ static int after_reply(struct ptlrpc_request *req)
 	ktime_get_real_ts64(&work_start);
 	timediff = (work_start.tv_sec - req->rq_arrival_time.tv_sec) * USEC_PER_SEC +
 		   (work_start.tv_nsec - req->rq_arrival_time.tv_nsec) / NSEC_PER_USEC;
-	if (obd->obd_svc_stats != NULL) {
+	if (obd->obd_svc_stats) {
 		lprocfs_counter_add(obd->obd_svc_stats, PTLRPC_REQWAIT_CNTR,
 				    timediff);
 		ptlrpc_lprocfs_rpc_sent(req, timediff);
@@ -1311,7 +1307,7 @@ static int after_reply(struct ptlrpc_request *req)
 			/* version recovery */
 			ptlrpc_save_versions(req);
 			ptlrpc_retain_replayable_request(req, imp);
-		} else if (req->rq_commit_cb != NULL &&
+		} else if (req->rq_commit_cb &&
 			   list_empty(&req->rq_replay_list)) {
 			/*
 			 * NB: don't call rq_commit_cb if it's already on
@@ -1438,7 +1434,7 @@ static inline int ptlrpc_set_producer(struct ptlrpc_request_set *set)
 {
 	int remaining, rc;
 
-	LASSERT(set->set_producer != NULL);
+	LASSERT(set->set_producer);
 
 	remaining = atomic_read(&set->set_remaining);
 
@@ -1751,7 +1747,7 @@ int ptlrpc_check_set(const struct lu_env *env, struct ptlrpc_request_set *set)
 			 * process the reply. Similarly if the RPC returned
 			 * an error, and therefore the bulk will never arrive.
 			 */
-			if (req->rq_bulk == NULL || req->rq_status < 0) {
+			if (!req->rq_bulk || req->rq_status < 0) {
 				ptlrpc_rqphase_move(req, RQ_PHASE_INTERPRET);
 				goto interpret;
 			}
@@ -1803,7 +1799,7 @@ interpret:
 		}
 		ptlrpc_rqphase_move(req, RQ_PHASE_COMPLETE);
 
-		CDEBUG(req->rq_reqmsg != NULL ? D_RPCTRACE : 0,
+		CDEBUG(req->rq_reqmsg ? D_RPCTRACE : 0,
 		       "Completed RPC pname:cluuid:pid:xid:nid:opc %s:%s:%d:%llu:%s:%d\n",
 		       current_comm(), imp->imp_obd->obd_uuid.uuid,
 		       lustre_msg_get_status(req->rq_reqmsg), req->rq_xid,
@@ -1883,7 +1879,7 @@ int ptlrpc_expire_one_request(struct ptlrpc_request *req, int async_unlink)
 		      "timed out for sent delay" : "timed out for slow reply"),
 		  (s64)req->rq_sent, (s64)req->rq_real_sent);
 
-	if (imp != NULL && obd_debug_peer_on_timeout)
+	if (imp && obd_debug_peer_on_timeout)
 		LNetDebugPeer(imp->imp_connection->c_peer);
 
 	ptlrpc_unregister_reply(req, async_unlink);
@@ -1892,7 +1888,7 @@ int ptlrpc_expire_one_request(struct ptlrpc_request *req, int async_unlink)
 	if (obd_dump_on_timeout)
 		libcfs_debug_dumplog();
 
-	if (imp == NULL) {
+	if (!imp) {
 		DEBUG_REQ(D_HA, req, "NULL import: already cleaned up?");
 		return 1;
 	}
@@ -1945,8 +1941,6 @@ int ptlrpc_expired_set(void *data)
 	struct list_head *tmp;
 	time64_t now = ktime_get_real_seconds();
 
-	LASSERT(set != NULL);
-
 	/* A timeout expired. See which reqs it applies to...  */
 	list_for_each(tmp, &set->set_requests) {
 		struct ptlrpc_request *req =
@@ -2003,7 +1997,6 @@ void ptlrpc_interrupted_set(void *data)
 	struct ptlrpc_request_set *set = data;
 	struct list_head *tmp;
 
-	LASSERT(set != NULL);
 	CDEBUG(D_RPCTRACE, "INTERRUPTED SET %p\n", set);
 
 	list_for_each(tmp, &set->set_requests) {
@@ -2175,7 +2168,7 @@ int ptlrpc_set_wait(struct ptlrpc_request_set *set)
 			rc = req->rq_status;
 	}
 
-	if (set->set_interpret != NULL) {
+	if (set->set_interpret) {
 		int (*interpreter)(struct ptlrpc_request_set *set, void *, int) =
 			set->set_interpret;
 		rc = interpreter(set, set->set_arg, rc);
@@ -2207,10 +2200,10 @@ EXPORT_SYMBOL(ptlrpc_set_wait);
  */
 static void __ptlrpc_free_req(struct ptlrpc_request *request, int locked)
 {
-	if (request == NULL)
+	if (!request)
 		return;
 	LASSERTF(!request->rq_receiving_reply, "req %p\n", request);
-	LASSERTF(request->rq_rqbd == NULL, "req %p\n", request);/* client-side */
+	LASSERTF(!request->rq_rqbd, "req %p\n", request);/* client-side */
 	LASSERTF(list_empty(&request->rq_list), "req %p\n", request);
 	LASSERTF(list_empty(&request->rq_set_chain), "req %p\n", request);
 	LASSERTF(list_empty(&request->rq_exp_list), "req %p\n", request);
@@ -2222,7 +2215,7 @@ static void __ptlrpc_free_req(struct ptlrpc_request *request, int locked)
 	 * We must take it off the imp_replay_list first.  Otherwise, we'll set
 	 * request->rq_reqmsg to NULL while osc_close is dereferencing it.
 	 */
-	if (request->rq_import != NULL) {
+	if (request->rq_import) {
 		if (!locked)
 			spin_lock(&request->rq_import->imp_lock);
 		list_del_init(&request->rq_replay_list);
@@ -2237,20 +2230,20 @@ static void __ptlrpc_free_req(struct ptlrpc_request *request, int locked)
 		LBUG();
 	}
 
-	if (request->rq_repbuf != NULL)
+	if (request->rq_repbuf)
 		sptlrpc_cli_free_repbuf(request);
-	if (request->rq_export != NULL) {
+	if (request->rq_export) {
 		class_export_put(request->rq_export);
 		request->rq_export = NULL;
 	}
-	if (request->rq_import != NULL) {
+	if (request->rq_import) {
 		class_import_put(request->rq_import);
 		request->rq_import = NULL;
 	}
-	if (request->rq_bulk != NULL)
+	if (request->rq_bulk)
 		ptlrpc_free_bulk_pin(request->rq_bulk);
 
-	if (request->rq_reqbuf != NULL || request->rq_clrbuf != NULL)
+	if (request->rq_reqbuf || request->rq_clrbuf)
 		sptlrpc_cli_free_reqbuf(request);
 
 	if (request->rq_cli_ctx)
@@ -2270,7 +2263,7 @@ static void __ptlrpc_free_req(struct ptlrpc_request *request, int locked)
  */
 static int __ptlrpc_req_finished(struct ptlrpc_request *request, int locked)
 {
-	if (request == NULL)
+	if (!request)
 		return 1;
 
 	if (request == LP_POISON ||
@@ -2352,7 +2345,7 @@ int ptlrpc_unregister_reply(struct ptlrpc_request *request, int async)
 	 * a chance to run reply_in_callback(), and to make sure we've
 	 * unlinked before returning a req to the pool.
 	 */
-	if (request->rq_set != NULL)
+	if (request->rq_set)
 		wq = &request->rq_set->set_waitq;
 	else
 		wq = &request->rq_reply_waitq;
@@ -2387,7 +2380,7 @@ static void ptlrpc_free_request(struct ptlrpc_request *req)
 	req->rq_replay = 0;
 	spin_unlock(&req->rq_lock);
 
-	if (req->rq_commit_cb != NULL)
+	if (req->rq_commit_cb)
 		req->rq_commit_cb(req);
 	list_del_init(&req->rq_replay_list);
 
@@ -2428,7 +2421,6 @@ void ptlrpc_free_committed(struct obd_import *imp)
 	struct ptlrpc_request *last_req = NULL; /* temporary fire escape */
 	bool skip_committed_list = true;
 
-	LASSERT(imp != NULL);
 	assert_spin_locked(&imp->imp_lock);
 
 	if (imp->imp_peer_committed_transno == imp->imp_last_transno_checked &&
@@ -2612,11 +2604,11 @@ int ptlrpc_queue_wait(struct ptlrpc_request *req)
 	struct ptlrpc_request_set *set;
 	int rc;
 
-	LASSERT(req->rq_set == NULL);
+	LASSERT(!req->rq_set);
 	LASSERT(!req->rq_receiving_reply);
 
 	set = ptlrpc_prep_set();
-	if (set == NULL) {
+	if (!set) {
 		CERROR("Unable to allocate ptlrpc set.");
 		return -ENOMEM;
 	}
@@ -2848,8 +2840,6 @@ void ptlrpc_abort_set(struct ptlrpc_request_set *set)
 {
 	struct list_head *tmp, *pos;
 
-	LASSERT(set != NULL);
-
 	list_for_each_safe(pos, tmp, &set->set_requests) {
 		struct ptlrpc_request *req =
 			list_entry(pos, struct ptlrpc_request,
@@ -2995,7 +2985,6 @@ static int work_interpreter(const struct lu_env *env,
 	struct ptlrpc_work_async_args *arg = data;
 
 	LASSERT(ptlrpcd_check_work(req));
-	LASSERT(arg->cb != NULL);
 
 	rc = arg->cb(env, arg->cbdata);
 
@@ -3027,12 +3016,12 @@ void *ptlrpcd_alloc_work(struct obd_import *imp,
 
 	might_sleep();
 
-	if (cb == NULL)
+	if (!cb)
 		return ERR_PTR(-EINVAL);
 
 	/* copy some code from deprecated fakereq. */
 	req = ptlrpc_request_cache_alloc(GFP_NOFS);
-	if (req == NULL) {
+	if (!req) {
 		CERROR("ptlrpc: run out of memory!\n");
 		return ERR_PTR(-ENOMEM);
 	}
diff --git a/drivers/staging/lustre/lustre/ptlrpc/connection.c b/drivers/staging/lustre/lustre/ptlrpc/connection.c
index da1f0b1..062db13 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/connection.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/connection.c
@@ -172,7 +172,7 @@ conn_keycmp(const void *key, struct hlist_node *hnode)
 	struct ptlrpc_connection *conn;
 	const lnet_process_id_t *conn_key;
 
-	LASSERT(key != NULL);
+	LASSERT(key);
 	conn_key = key;
 	conn = hlist_entry(hnode, struct ptlrpc_connection, c_hash);
 
diff --git a/drivers/staging/lustre/lustre/ptlrpc/events.c b/drivers/staging/lustre/lustre/ptlrpc/events.c
index 07e76a2..64eaa0e 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/events.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/events.c
@@ -312,7 +312,7 @@ void request_in_callback(lnet_event_t *ev)
 			return;
 		}
 		req = ptlrpc_request_cache_alloc(GFP_ATOMIC);
-		if (req == NULL) {
+		if (!req) {
 			CERROR("Can't allocate incoming request descriptor: Dropping %s RPC from %s\n",
 			       service->srv_name,
 			       libcfs_id2str(ev->initiator));
diff --git a/drivers/staging/lustre/lustre/ptlrpc/import.c b/drivers/staging/lustre/lustre/ptlrpc/import.c
index f752c78..bd0fa3c 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/import.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/import.c
@@ -553,7 +553,6 @@ static int import_select_connection(struct obd_import *imp)
 	imp->imp_connection = ptlrpc_connection_addref(imp_conn->oic_conn);
 
 	dlmexp = class_conn2export(&imp->imp_dlm_handle);
-	LASSERT(dlmexp != NULL);
 	ptlrpc_connection_put(dlmexp->exp_connection);
 	dlmexp->exp_connection = ptlrpc_connection_addref(imp_conn->oic_conn);
 	class_export_put(dlmexp);
@@ -687,7 +686,7 @@ int ptlrpc_connect_import(struct obd_import *imp)
 		goto out;
 
 	request = ptlrpc_request_alloc(imp, &RQF_MDS_CONNECT);
-	if (request == NULL) {
+	if (!request) {
 		rc = -ENOMEM;
 		goto out;
 	}
@@ -817,7 +816,7 @@ static int ptlrpc_connect_interpret(const struct lu_env *env,
 	ocd = req_capsule_server_sized_get(&request->rq_pill,
 					   &RMF_CONNECT_DATA, ret);
 
-	if (ocd == NULL) {
+	if (!ocd) {
 		CERROR("%s: no connect data from server\n",
 		       imp->imp_obd->obd_name);
 		rc = -EPROTO;
@@ -1162,7 +1161,7 @@ out:
 			struct obd_connect_data *ocd;
 
 			/* reply message might not be ready */
-			if (request->rq_repmsg == NULL)
+			if (!request->rq_repmsg)
 				return -EPROTO;
 
 			ocd = req_capsule_server_get(&request->rq_pill,
@@ -1243,7 +1242,7 @@ static int signal_completed_replay(struct obd_import *imp)
 
 	req = ptlrpc_request_alloc_pack(imp, &RQF_OBD_PING, LUSTRE_OBD_VERSION,
 					OBD_PING);
-	if (req == NULL) {
+	if (!req) {
 		atomic_dec(&imp->imp_replay_inflight);
 		return -ENOMEM;
 	}
diff --git a/drivers/staging/lustre/lustre/ptlrpc/layout.c b/drivers/staging/lustre/lustre/ptlrpc/layout.c
index c0e613c..9601b2a 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/layout.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/layout.c
@@ -1712,7 +1712,7 @@ void req_capsule_init(struct req_capsule *pill,
 	 * high-priority RPC queue getting peeked at before ost_handle()
 	 * handles an OST RPC.
 	 */
-	if (req != NULL && pill == &req->rq_pill && req->rq_pill_init)
+	if (req && pill == &req->rq_pill && req->rq_pill_init)
 		return;
 
 	memset(pill, 0, sizeof(*pill));
@@ -1720,7 +1720,7 @@ void req_capsule_init(struct req_capsule *pill,
 	pill->rc_loc = location;
 	req_capsule_init_area(pill);
 
-	if (req != NULL && pill == &req->rq_pill)
+	if (req && pill == &req->rq_pill)
 		req->rq_pill_init = 1;
 }
 EXPORT_SYMBOL(req_capsule_init);
@@ -1752,7 +1752,7 @@ static struct lustre_msg *__req_msg(const struct req_capsule *pill,
  */
 void req_capsule_set(struct req_capsule *pill, const struct req_format *fmt)
 {
-	LASSERT(pill->rc_fmt == NULL || pill->rc_fmt == fmt);
+	LASSERT(!pill->rc_fmt || pill->rc_fmt == fmt);
 	LASSERT(__req_format_is_sane(fmt));
 
 	pill->rc_fmt = fmt;
@@ -1773,8 +1773,6 @@ int req_capsule_filled_sizes(struct req_capsule *pill,
 	const struct req_format *fmt = pill->rc_fmt;
 	int i;
 
-	LASSERT(fmt != NULL);
-
 	for (i = 0; i < fmt->rf_fields[loc].nr; ++i) {
 		if (pill->rc_area[loc][i] == -1) {
 			pill->rc_area[loc][i] =
@@ -1810,7 +1808,7 @@ int req_capsule_server_pack(struct req_capsule *pill)
 
 	LASSERT(pill->rc_loc == RCL_SERVER);
 	fmt = pill->rc_fmt;
-	LASSERT(fmt != NULL);
+	LASSERT(fmt);
 
 	count = req_capsule_filled_sizes(pill, RCL_SERVER);
 	rc = lustre_pack_reply(pill->rc_req, count,
@@ -1865,7 +1863,7 @@ swabber_dumper_helper(struct req_capsule *pill,
 	swabber = swabber ?: field->rmf_swabber;
 
 	if (ptlrpc_buf_need_swab(pill->rc_req, inout, offset) &&
-	    swabber != NULL && value != NULL)
+	    swabber && value)
 		do_swab = 1;
 	else
 		do_swab = 0;
@@ -1947,17 +1945,15 @@ static void *__req_capsule_get(struct req_capsule *pill,
 		[RCL_SERVER] = "server"
 	};
 
-	LASSERT(pill != NULL);
-	LASSERT(pill != LP_POISON);
 	fmt = pill->rc_fmt;
-	LASSERT(fmt != NULL);
+	LASSERT(fmt);
 	LASSERT(fmt != LP_POISON);
 	LASSERT(__req_format_is_sane(fmt));
 
 	offset = __req_capsule_offset(pill, field, loc);
 
 	msg = __req_msg(pill, loc);
-	LASSERT(msg != NULL);
+	LASSERT(msg);
 
 	getter = (field->rmf_flags & RMF_F_STRING) ?
 		(typeof(getter))lustre_msg_string : lustre_msg_buf;
@@ -1980,7 +1976,7 @@ static void *__req_capsule_get(struct req_capsule *pill,
 	}
 	value = getter(msg, offset, len);
 
-	if (value == NULL) {
+	if (!value) {
 		DEBUG_REQ(D_ERROR, pill->rc_req,
 			  "Wrong buffer for field `%s' (%d of %d) in format `%s': %d vs. %d (%s)\n",
 			  field->rmf_name, offset, lustre_msg_bufcount(msg),
@@ -2209,7 +2205,7 @@ void req_capsule_extend(struct req_capsule *pill, const struct req_format *fmt)
 
 	const struct req_format *old;
 
-	LASSERT(pill->rc_fmt != NULL);
+	LASSERT(pill->rc_fmt);
 	LASSERT(__req_format_is_sane(fmt));
 
 	old = pill->rc_fmt;
@@ -2222,7 +2218,7 @@ void req_capsule_extend(struct req_capsule *pill, const struct req_format *fmt)
 			const struct req_msg_field *ofield = FMT_FIELD(old, i, j);
 
 			/* "opaque" fields can be transmogrified */
-			if (ofield->rmf_swabber == NULL &&
+			if (!ofield->rmf_swabber &&
 			    (ofield->rmf_flags & ~RMF_F_NO_SIZE_CHECK) == 0 &&
 			    (ofield->rmf_size == -1 ||
 			    ofield->rmf_flags == RMF_F_NO_SIZE_CHECK))
@@ -2289,7 +2285,7 @@ void req_capsule_shrink(struct req_capsule *pill,
 	int offset;
 
 	fmt = pill->rc_fmt;
-	LASSERT(fmt != NULL);
+	LASSERT(fmt);
 	LASSERT(__req_format_is_sane(fmt));
 	LASSERT(req_capsule_has_field(pill, field, loc));
 	LASSERT(req_capsule_field_present(pill, field, loc));
diff --git a/drivers/staging/lustre/lustre/ptlrpc/llog_client.c b/drivers/staging/lustre/lustre/ptlrpc/llog_client.c
index e877020..8ef5e45 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/llog_client.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/llog_client.c
@@ -93,7 +93,7 @@ static int llog_client_open(const struct lu_env *env,
 	LASSERT(lgh);
 
 	req = ptlrpc_request_alloc(imp, &RQF_LLOG_ORIGIN_HANDLE_CREATE);
-	if (req == NULL) {
+	if (!req) {
 		rc = -ENOMEM;
 		goto out;
 	}
@@ -130,7 +130,7 @@ static int llog_client_open(const struct lu_env *env,
 		goto out;
 
 	body = req_capsule_server_get(&req->rq_pill, &RMF_LLOGD_BODY);
-	if (body == NULL) {
+	if (!body) {
 		rc = -EFAULT;
 		goto out;
 	}
@@ -158,7 +158,7 @@ static int llog_client_next_block(const struct lu_env *env,
 	req = ptlrpc_request_alloc_pack(imp, &RQF_LLOG_ORIGIN_HANDLE_NEXT_BLOCK,
 					LUSTRE_LOG_VERSION,
 					LLOG_ORIGIN_HANDLE_NEXT_BLOCK);
-	if (req == NULL) {
+	if (!req) {
 		rc = -ENOMEM;
 		goto err_exit;
 	}
@@ -179,14 +179,14 @@ static int llog_client_next_block(const struct lu_env *env,
 		goto out;
 
 	body = req_capsule_server_get(&req->rq_pill, &RMF_LLOGD_BODY);
-	if (body == NULL) {
+	if (!body) {
 		rc = -EFAULT;
 		goto out;
 	}
 
 	/* The log records are swabbed as they are processed */
 	ptr = req_capsule_server_get(&req->rq_pill, &RMF_EADATA);
-	if (ptr == NULL) {
+	if (!ptr) {
 		rc = -EFAULT;
 		goto out;
 	}
@@ -216,7 +216,7 @@ static int llog_client_prev_block(const struct lu_env *env,
 	req = ptlrpc_request_alloc_pack(imp, &RQF_LLOG_ORIGIN_HANDLE_PREV_BLOCK,
 					LUSTRE_LOG_VERSION,
 					LLOG_ORIGIN_HANDLE_PREV_BLOCK);
-	if (req == NULL) {
+	if (!req) {
 		rc = -ENOMEM;
 		goto err_exit;
 	}
@@ -236,13 +236,13 @@ static int llog_client_prev_block(const struct lu_env *env,
 		goto out;
 
 	body = req_capsule_server_get(&req->rq_pill, &RMF_LLOGD_BODY);
-	if (body == NULL) {
+	if (!body) {
 		rc = -EFAULT;
 		goto out;
 	}
 
 	ptr = req_capsule_server_get(&req->rq_pill, &RMF_EADATA);
-	if (ptr == NULL) {
+	if (!ptr) {
 		rc = -EFAULT;
 		goto out;
 	}
@@ -269,7 +269,7 @@ static int llog_client_read_header(const struct lu_env *env,
 	req = ptlrpc_request_alloc_pack(imp, &RQF_LLOG_ORIGIN_HANDLE_READ_HEADER,
 					LUSTRE_LOG_VERSION,
 					LLOG_ORIGIN_HANDLE_READ_HEADER);
-	if (req == NULL) {
+	if (!req) {
 		rc = -ENOMEM;
 		goto err_exit;
 	}
@@ -285,7 +285,7 @@ static int llog_client_read_header(const struct lu_env *env,
 		goto out;
 
 	hdr = req_capsule_server_get(&req->rq_pill, &RMF_LLOG_LOG_HDR);
-	if (hdr == NULL) {
+	if (!hdr) {
 		rc = -EFAULT;
 		goto out;
 	}
diff --git a/drivers/staging/lustre/lustre/ptlrpc/llog_net.c b/drivers/staging/lustre/lustre/ptlrpc/llog_net.c
index dac66f5..fbccb62 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/llog_net.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/llog_net.c
@@ -58,7 +58,7 @@ int llog_initiator_connect(struct llog_ctxt *ctxt)
 
 	LASSERT(ctxt);
 	new_imp = ctxt->loc_obd->u.cli.cl_import;
-	LASSERTF(ctxt->loc_imp == NULL || ctxt->loc_imp == new_imp,
+	LASSERTF(!ctxt->loc_imp || ctxt->loc_imp == new_imp,
 		 "%p - %p\n", ctxt->loc_imp, new_imp);
 	mutex_lock(&ctxt->loc_mutex);
 	if (ctxt->loc_imp != new_imp) {
diff --git a/drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c b/drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c
index cc55b79..a4a857f 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c
@@ -192,15 +192,15 @@ ptlrpc_ldebugfs_register(struct dentry *root, char *dir,
 	unsigned int svc_counter_config = LPROCFS_CNTR_AVGMINMAX |
 					  LPROCFS_CNTR_STDDEV;
 
-	LASSERT(*debugfs_root_ret == NULL);
-	LASSERT(*stats_ret == NULL);
+	LASSERT(!*debugfs_root_ret);
+	LASSERT(!*stats_ret);
 
 	svc_stats = lprocfs_alloc_stats(EXTRA_MAX_OPCODES+LUSTRE_MAX_OPCODES,
 					0);
-	if (svc_stats == NULL)
+	if (!svc_stats)
 		return;
 
-	if (dir != NULL) {
+	if (dir) {
 		svc_debugfs_entry = ldebugfs_register(dir, root, NULL, NULL);
 		if (IS_ERR(svc_debugfs_entry)) {
 			lprocfs_free_stats(&svc_stats);
@@ -246,11 +246,11 @@ ptlrpc_ldebugfs_register(struct dentry *root, char *dir,
 
 	rc = ldebugfs_register_stats(svc_debugfs_entry, name, svc_stats);
 	if (rc < 0) {
-		if (dir != NULL)
+		if (dir)
 			ldebugfs_remove(&svc_debugfs_entry);
 		lprocfs_free_stats(&svc_stats);
 	} else {
-		if (dir != NULL)
+		if (dir)
 			*debugfs_root_ret = svc_debugfs_entry;
 		*stats_ret = svc_stats;
 	}
@@ -456,8 +456,6 @@ static const char *nrs_state2str(enum ptlrpc_nrs_pol_state state)
 static void nrs_policy_get_info_locked(struct ptlrpc_nrs_policy *policy,
 				struct ptlrpc_nrs_pol_info *info)
 {
-	LASSERT(policy != NULL);
-	LASSERT(info != NULL);
 	assert_spin_locked(&policy->pol_nrs->nrs_lock);
 
 	memcpy(info->pi_name, policy->pol_desc->pd_name, NRS_POL_NAME_MAX);
@@ -508,7 +506,7 @@ static int ptlrpc_lprocfs_nrs_seq_show(struct seq_file *m, void *n)
 	spin_unlock(&nrs->nrs_lock);
 
 	infos = kcalloc(num_pols, sizeof(*infos), GFP_NOFS);
-	if (infos == NULL) {
+	if (!infos) {
 		rc = -ENOMEM;
 		goto unlock;
 	}
@@ -676,7 +674,7 @@ static ssize_t ptlrpc_lprocfs_nrs_seq_write(struct file *file,
 	/**
 	 * No [reg|hp] token has been specified
 	 */
-	if (cmd == NULL)
+	if (!cmd)
 		goto default_queue;
 
 	/**
@@ -733,8 +731,7 @@ ptlrpc_lprocfs_svc_req_history_seek(struct ptlrpc_service_part *svcpt,
 	struct list_head *e;
 	struct ptlrpc_request *req;
 
-	if (srhi->srhi_req != NULL &&
-	    srhi->srhi_seq > svcpt->scp_hist_seq_culled &&
+	if (srhi->srhi_req && srhi->srhi_seq > svcpt->scp_hist_seq_culled &&
 	    srhi->srhi_seq <= seq) {
 		/* If srhi_req was set previously, hasn't been culled and
 		 * we're searching for a seq on or after it (i.e. more
@@ -927,7 +924,7 @@ static int ptlrpc_lprocfs_svc_req_history_show(struct seq_file *s, void *iter)
 			   (s64)req->rq_arrival_time.tv_sec,
 			   (long)(req->rq_sent - req->rq_arrival_time.tv_sec),
 			   (long)(req->rq_sent - req->rq_deadline));
-		if (svc->srv_ops.so_req_printer == NULL)
+		if (!svc->srv_ops.so_req_printer)
 			seq_putc(s, '\n');
 		else
 			svc->srv_ops.so_req_printer(s, srhi->srhi_req);
@@ -1103,7 +1100,7 @@ void ptlrpc_ldebugfs_register_service(struct dentry *entry,
 				 "stats", &svc->srv_debugfs_entry,
 				 &svc->srv_stats);
 
-	if (svc->srv_debugfs_entry == NULL)
+	if (IS_ERR_OR_NULL(svc->srv_debugfs_entry))
 		return;
 
 	ldebugfs_add_vars(svc->srv_debugfs_entry, lproc_vars, NULL);
@@ -1129,7 +1126,7 @@ void ptlrpc_lprocfs_rpc_sent(struct ptlrpc_request *req, long amount)
 	int opc = opcode_offset(op);
 
 	svc_stats = req->rq_import->imp_obd->obd_svc_stats;
-	if (svc_stats == NULL || opc <= 0)
+	if (!svc_stats || opc <= 0)
 		return;
 	LASSERT(opc < LUSTRE_MAX_OPCODES);
 	if (!(op == LDLM_ENQUEUE || op == MDS_REINT))
@@ -1166,7 +1163,7 @@ EXPORT_SYMBOL(ptlrpc_lprocfs_brw);
 
 void ptlrpc_lprocfs_unregister_service(struct ptlrpc_service *svc)
 {
-	if (svc->srv_debugfs_entry != NULL)
+	if (!IS_ERR_OR_NULL(svc->srv_debugfs_entry))
 		ldebugfs_remove(&svc->srv_debugfs_entry);
 
 	if (svc->srv_stats)
@@ -1198,7 +1195,7 @@ int lprocfs_wr_ping(struct file *file, const char __user *buffer,
 
 	req = ptlrpc_prep_ping(obd->u.cli.cl_import);
 	up_read(&obd->u.cli.cl_sem);
-	if (req == NULL)
+	if (!req)
 		return -ENOMEM;
 
 	req->rq_send_state = LUSTRE_IMP_FULL;
diff --git a/drivers/staging/lustre/lustre/ptlrpc/niobuf.c b/drivers/staging/lustre/lustre/ptlrpc/niobuf.c
index c5d7ff5..4cce26d 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/niobuf.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/niobuf.c
@@ -56,7 +56,6 @@ static int ptl_send_buf(lnet_handle_md_t *mdh, void *base, int len,
 	lnet_md_t md;
 
 	LASSERT(portal != 0);
-	LASSERT(conn != NULL);
 	CDEBUG(D_INFO, "conn=%p id %s\n", conn, libcfs_id2str(conn->c_peer));
 	md.start = base;
 	md.length = len;
@@ -130,7 +129,7 @@ static int ptlrpc_register_bulk(struct ptlrpc_request *req)
 	LASSERT(desc->bd_md_count == 0);
 	LASSERT(desc->bd_md_max_brw <= PTLRPC_BULK_OPS_COUNT);
 	LASSERT(desc->bd_iov_count <= PTLRPC_MAX_BRW_PAGES);
-	LASSERT(desc->bd_req != NULL);
+	LASSERT(desc->bd_req);
 	LASSERT(desc->bd_type == BULK_PUT_SINK ||
 		desc->bd_type == BULK_GET_SOURCE);
 
@@ -273,7 +272,7 @@ int ptlrpc_unregister_bulk(struct ptlrpc_request *req, int async)
 	if (async)
 		return 0;
 
-	if (req->rq_set != NULL)
+	if (req->rq_set)
 		wq = &req->rq_set->set_waitq;
 	else
 		wq = &req->rq_reply_waitq;
@@ -305,8 +304,7 @@ static void ptlrpc_at_set_reply(struct ptlrpc_request *req, int flags)
 				 req->rq_arrival_time.tv_sec, 1);
 
 	if (!(flags & PTLRPC_REPLY_EARLY) &&
-	    (req->rq_type != PTL_RPC_MSG_ERR) &&
-	    (req->rq_reqmsg != NULL) &&
+	    (req->rq_type != PTL_RPC_MSG_ERR) && req->rq_reqmsg &&
 	    !(lustre_msg_get_flags(req->rq_reqmsg) &
 	      (MSG_RESENT | MSG_REPLAY |
 	       MSG_REQ_REPLAY_DONE | MSG_LOCK_REPLAY_DONE))) {
@@ -360,10 +358,10 @@ int ptlrpc_send_reply(struct ptlrpc_request *req, int flags)
 	 * target_queue_final_reply().
 	 */
 	LASSERT(req->rq_no_reply == 0);
-	LASSERT(req->rq_reqbuf != NULL);
-	LASSERT(rs != NULL);
+	LASSERT(req->rq_reqbuf);
+	LASSERT(rs);
 	LASSERT((flags & PTLRPC_REPLY_MAYBE_DIFFICULT) || !rs->rs_difficult);
-	LASSERT(req->rq_repmsg != NULL);
+	LASSERT(req->rq_repmsg);
 	LASSERT(req->rq_repmsg == rs->rs_msg);
 	LASSERT(rs->rs_cb_id.cbid_fn == reply_out_callback);
 	LASSERT(rs->rs_cb_id.cbid_arg == rs);
@@ -403,12 +401,12 @@ int ptlrpc_send_reply(struct ptlrpc_request *req, int flags)
 
 	ptlrpc_at_set_reply(req, flags);
 
-	if (req->rq_export == NULL || req->rq_export->exp_connection == NULL)
+	if (!req->rq_export || !req->rq_export->exp_connection)
 		conn = ptlrpc_connection_get(req->rq_peer, req->rq_self, NULL);
 	else
 		conn = ptlrpc_connection_addref(req->rq_export->exp_connection);
 
-	if (unlikely(conn == NULL)) {
+	if (unlikely(!conn)) {
 		CERROR("not replying on NULL connection\n"); /* bug 9635 */
 		return -ENOTCONN;
 	}
@@ -503,7 +501,7 @@ int ptl_send_rpc(struct ptlrpc_request *request, int noreply)
 	LASSERT(!((lustre_msg_get_flags(request->rq_reqmsg) & MSG_REPLAY) &&
 		(request->rq_import->imp_state == LUSTRE_IMP_FULL)));
 
-	if (unlikely(obd != NULL && obd->obd_fail)) {
+	if (unlikely(obd && obd->obd_fail)) {
 		CDEBUG(D_HA, "muting rpc for failed imp obd %s\n",
 			obd->obd_name);
 		/* this prevents us from waiting in ptlrpc_queue_wait */
@@ -535,7 +533,7 @@ int ptl_send_rpc(struct ptlrpc_request *request, int noreply)
 		goto out;
 
 	/* bulk register should be done after wrap_request() */
-	if (request->rq_bulk != NULL) {
+	if (request->rq_bulk) {
 		rc = ptlrpc_register_bulk(request);
 		if (rc != 0)
 			goto out;
@@ -543,9 +541,9 @@ int ptl_send_rpc(struct ptlrpc_request *request, int noreply)
 
 	if (!noreply) {
 		LASSERT(request->rq_replen != 0);
-		if (request->rq_repbuf == NULL) {
-			LASSERT(request->rq_repdata == NULL);
-			LASSERT(request->rq_repmsg == NULL);
+		if (!request->rq_repbuf) {
+			LASSERT(!request->rq_repdata);
+			LASSERT(!request->rq_repmsg);
 			rc = sptlrpc_cli_alloc_repbuf(request,
 						      request->rq_replen);
 			if (rc) {
@@ -623,7 +621,7 @@ int ptl_send_rpc(struct ptlrpc_request *request, int noreply)
 
 	/* add references on request for request_out_callback */
 	ptlrpc_request_addref(request);
-	if (obd != NULL && obd->obd_svc_stats != NULL)
+	if (obd && obd->obd_svc_stats)
 		lprocfs_counter_add(obd->obd_svc_stats, PTLRPC_REQACTIVE_CNTR,
 			atomic_read(&request->rq_import->imp_inflight));
 
diff --git a/drivers/staging/lustre/lustre/ptlrpc/nrs.c b/drivers/staging/lustre/lustre/ptlrpc/nrs.c
index 57acf8c..ed40be6 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/nrs.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/nrs.c
@@ -57,7 +57,7 @@ struct nrs_core nrs_core;
 
 static int nrs_policy_init(struct ptlrpc_nrs_policy *policy)
 {
-	return policy->pol_desc->pd_ops->op_policy_init != NULL ?
+	return policy->pol_desc->pd_ops->op_policy_init ?
 	       policy->pol_desc->pd_ops->op_policy_init(policy) : 0;
 }
 
@@ -66,7 +66,7 @@ static void nrs_policy_fini(struct ptlrpc_nrs_policy *policy)
 	LASSERT(policy->pol_ref == 0);
 	LASSERT(policy->pol_req_queued == 0);
 
-	if (policy->pol_desc->pd_ops->op_policy_fini != NULL)
+	if (policy->pol_desc->pd_ops->op_policy_fini)
 		policy->pol_desc->pd_ops->op_policy_fini(policy);
 }
 
@@ -82,7 +82,7 @@ static int nrs_policy_ctl_locked(struct ptlrpc_nrs_policy *policy,
 	if (policy->pol_state == NRS_POL_STATE_STOPPED)
 		return -ENODEV;
 
-	return policy->pol_desc->pd_ops->op_policy_ctl != NULL ?
+	return policy->pol_desc->pd_ops->op_policy_ctl ?
 	       policy->pol_desc->pd_ops->op_policy_ctl(policy, opc, arg) :
 	       -ENOSYS;
 }
@@ -91,7 +91,7 @@ static void nrs_policy_stop0(struct ptlrpc_nrs_policy *policy)
 {
 	struct ptlrpc_nrs *nrs = policy->pol_nrs;
 
-	if (policy->pol_desc->pd_ops->op_policy_stop != NULL) {
+	if (policy->pol_desc->pd_ops->op_policy_stop) {
 		spin_unlock(&nrs->nrs_lock);
 
 		policy->pol_desc->pd_ops->op_policy_stop(policy);
@@ -154,7 +154,7 @@ static void nrs_policy_stop_primary(struct ptlrpc_nrs *nrs)
 {
 	struct ptlrpc_nrs_policy *tmp = nrs->nrs_policy_primary;
 
-	if (tmp == NULL)
+	if (!tmp)
 		return;
 
 	nrs->nrs_policy_primary = NULL;
@@ -220,12 +220,12 @@ static int nrs_policy_start_locked(struct ptlrpc_nrs_policy *policy)
 		 * nrs_policy_flags::PTLRPC_NRS_FL_FALLBACK flag set can
 		 * register with NRS core.
 		 */
-		LASSERT(nrs->nrs_policy_fallback == NULL);
+		LASSERT(!nrs->nrs_policy_fallback);
 	} else {
 		/**
 		 * Shouldn't start primary policy if w/o fallback policy.
 		 */
-		if (nrs->nrs_policy_fallback == NULL)
+		if (!nrs->nrs_policy_fallback)
 			return -EPERM;
 
 		if (policy->pol_state == NRS_POL_STATE_STARTED)
@@ -348,10 +348,10 @@ static void nrs_resource_put(struct ptlrpc_nrs_resource *res)
 {
 	struct ptlrpc_nrs_policy *policy = res->res_policy;
 
-	if (policy->pol_desc->pd_ops->op_res_put != NULL) {
+	if (policy->pol_desc->pd_ops->op_res_put) {
 		struct ptlrpc_nrs_resource *parent;
 
-		for (; res != NULL; res = parent) {
+		for (; res; res = parent) {
 			parent = res->res_parent;
 			policy->pol_desc->pd_ops->op_res_put(policy, res);
 		}
@@ -390,12 +390,11 @@ struct ptlrpc_nrs_resource *nrs_resource_get(struct ptlrpc_nrs_policy *policy,
 		rc = policy->pol_desc->pd_ops->op_res_get(policy, nrq, res,
 							  &tmp, moving_req);
 		if (rc < 0) {
-			if (res != NULL)
+			if (res)
 				nrs_resource_put(res);
 			return NULL;
 		}
 
-		LASSERT(tmp != NULL);
 		tmp->res_parent = res;
 		tmp->res_policy = policy;
 		res = tmp;
@@ -445,7 +444,7 @@ static void nrs_resource_get_safe(struct ptlrpc_nrs *nrs,
 	nrs_policy_get_locked(fallback);
 
 	primary = nrs->nrs_policy_primary;
-	if (primary != NULL)
+	if (primary)
 		nrs_policy_get_locked(primary);
 
 	spin_unlock(&nrs->nrs_lock);
@@ -454,9 +453,9 @@ static void nrs_resource_get_safe(struct ptlrpc_nrs *nrs,
 	 * Obtain resource hierarchy references.
 	 */
 	resp[NRS_RES_FALLBACK] = nrs_resource_get(fallback, nrq, moving_req);
-	LASSERT(resp[NRS_RES_FALLBACK] != NULL);
+	LASSERT(resp[NRS_RES_FALLBACK]);
 
-	if (primary != NULL) {
+	if (primary) {
 		resp[NRS_RES_PRIMARY] = nrs_resource_get(primary, nrq,
 							 moving_req);
 		/**
@@ -465,7 +464,7 @@ static void nrs_resource_get_safe(struct ptlrpc_nrs *nrs,
 		 * reference on the policy as it will not be used for this
 		 * request.
 		 */
-		if (resp[NRS_RES_PRIMARY] == NULL)
+		if (!resp[NRS_RES_PRIMARY])
 			nrs_policy_put(primary);
 	}
 }
@@ -485,7 +484,7 @@ static void nrs_resource_put_safe(struct ptlrpc_nrs_resource **resp)
 	int i;
 
 	for (i = 0; i < NRS_RES_MAX; i++) {
-		if (resp[i] != NULL) {
+		if (resp[i]) {
 			pols[i] = resp[i]->res_policy;
 			nrs_resource_put(resp[i]);
 			resp[i] = NULL;
@@ -526,7 +525,7 @@ struct ptlrpc_nrs_request *nrs_request_get(struct ptlrpc_nrs_policy *policy,
 
 	nrq = policy->pol_desc->pd_ops->op_req_get(policy, peek, force);
 
-	LASSERT(ergo(nrq != NULL, nrs_request_policy(nrq) == policy));
+	LASSERT(ergo(nrq, nrs_request_policy(nrq) == policy));
 
 	return nrq;
 }
@@ -552,7 +551,7 @@ static inline void nrs_request_enqueue(struct ptlrpc_nrs_request *nrq)
 	 * the preferred choice.
 	 */
 	for (i = NRS_RES_MAX - 1; i >= 0; i--) {
-		if (nrq->nr_res_ptrs[i] == NULL)
+		if (!nrq->nr_res_ptrs[i])
 			continue;
 
 		nrq->nr_res_idx = i;
@@ -622,7 +621,7 @@ static int nrs_policy_ctl(struct ptlrpc_nrs *nrs, char *name,
 	spin_lock(&nrs->nrs_lock);
 
 	policy = nrs_policy_find_locked(nrs, name);
-	if (policy == NULL) {
+	if (!policy) {
 		rc = -ENOENT;
 		goto out;
 	}
@@ -644,7 +643,7 @@ static int nrs_policy_ctl(struct ptlrpc_nrs *nrs, char *name,
 		break;
 	}
 out:
-	if (policy != NULL)
+	if (policy)
 		nrs_policy_put_locked(policy);
 
 	spin_unlock(&nrs->nrs_lock);
@@ -669,7 +668,7 @@ static int nrs_policy_unregister(struct ptlrpc_nrs *nrs, char *name)
 	spin_lock(&nrs->nrs_lock);
 
 	policy = nrs_policy_find_locked(nrs, name);
-	if (policy == NULL) {
+	if (!policy) {
 		spin_unlock(&nrs->nrs_lock);
 
 		CERROR("Can't find NRS policy %s\n", name);
@@ -702,7 +701,7 @@ static int nrs_policy_unregister(struct ptlrpc_nrs *nrs, char *name)
 
 	nrs_policy_fini(policy);
 
-	LASSERT(policy->pol_private == NULL);
+	LASSERT(!policy->pol_private);
 	kfree(policy);
 
 	return 0;
@@ -726,18 +725,16 @@ static int nrs_policy_register(struct ptlrpc_nrs *nrs,
 	struct ptlrpc_service_part *svcpt = nrs->nrs_svcpt;
 	int rc;
 
-	LASSERT(svcpt != NULL);
-	LASSERT(desc->pd_ops != NULL);
-	LASSERT(desc->pd_ops->op_res_get != NULL);
-	LASSERT(desc->pd_ops->op_req_get != NULL);
-	LASSERT(desc->pd_ops->op_req_enqueue != NULL);
-	LASSERT(desc->pd_ops->op_req_dequeue != NULL);
-	LASSERT(desc->pd_compat != NULL);
+	LASSERT(desc->pd_ops->op_res_get);
+	LASSERT(desc->pd_ops->op_req_get);
+	LASSERT(desc->pd_ops->op_req_enqueue);
+	LASSERT(desc->pd_ops->op_req_dequeue);
+	LASSERT(desc->pd_compat);
 
 	policy = kzalloc_node(sizeof(*policy), GFP_NOFS,
 			cfs_cpt_spread_node(svcpt->scp_service->srv_cptable,
 					    svcpt->scp_cpt));
-	if (policy == NULL)
+	if (!policy)
 		return -ENOMEM;
 
 	policy->pol_nrs = nrs;
@@ -757,7 +754,7 @@ static int nrs_policy_register(struct ptlrpc_nrs *nrs,
 	spin_lock(&nrs->nrs_lock);
 
 	tmp = nrs_policy_find_locked(nrs, policy->pol_desc->pd_name);
-	if (tmp != NULL) {
+	if (tmp) {
 		CERROR("NRS policy %s has been registered, can't register it for %s\n",
 		       policy->pol_desc->pd_name,
 		       svcpt->scp_service->srv_name);
@@ -947,14 +944,14 @@ static int nrs_svcpt_setup_locked(struct ptlrpc_service_part *svcpt)
 	/**
 	 * Optionally allocate a high-priority NRS head.
 	 */
-	if (svcpt->scp_service->srv_ops.so_hpreq_handler == NULL)
+	if (!svcpt->scp_service->srv_ops.so_hpreq_handler)
 		goto out;
 
 	svcpt->scp_nrs_hp =
 		kzalloc_node(sizeof(*svcpt->scp_nrs_hp), GFP_NOFS,
 			cfs_cpt_spread_node(svcpt->scp_service->srv_cptable,
 					    svcpt->scp_cpt));
-	if (svcpt->scp_nrs_hp == NULL) {
+	if (!svcpt->scp_nrs_hp) {
 		rc = -ENOMEM;
 		goto out;
 	}
@@ -1079,7 +1076,7 @@ again:
 			}
 		}
 
-		if (desc->pd_ops->op_lprocfs_fini != NULL)
+		if (desc->pd_ops->op_lprocfs_fini)
 			desc->pd_ops->op_lprocfs_fini(svc);
 	}
 
@@ -1107,13 +1104,12 @@ static int ptlrpc_nrs_policy_register(struct ptlrpc_nrs_pol_conf *conf)
 	struct ptlrpc_nrs_pol_desc *desc;
 	int rc = 0;
 
-	LASSERT(conf != NULL);
-	LASSERT(conf->nc_ops != NULL);
-	LASSERT(conf->nc_compat != NULL);
+	LASSERT(conf->nc_ops);
+	LASSERT(conf->nc_compat);
 	LASSERT(ergo(conf->nc_compat == nrs_policy_compat_one,
-		conf->nc_compat_svc_name != NULL));
+		conf->nc_compat_svc_name));
 	LASSERT(ergo((conf->nc_flags & PTLRPC_NRS_FL_REG_EXTERN) != 0,
-		     conf->nc_owner != NULL));
+		     conf->nc_owner));
 
 	conf->nc_name[NRS_POL_NAME_MAX - 1] = '\0';
 
@@ -1136,7 +1132,7 @@ static int ptlrpc_nrs_policy_register(struct ptlrpc_nrs_pol_conf *conf)
 
 	mutex_lock(&nrs_core.nrs_mutex);
 
-	if (nrs_policy_find_desc_locked(conf->nc_name) != NULL) {
+	if (nrs_policy_find_desc_locked(conf->nc_name)) {
 		CERROR("NRS: failing to register policy %s which has already been registered with NRS core!\n",
 		       conf->nc_name);
 		rc = -EEXIST;
@@ -1214,7 +1210,7 @@ again:
 		 * No need to take a reference to other modules here, as we
 		 * will be calling from the module's init() function.
 		 */
-		if (desc->pd_ops->op_lprocfs_init != NULL) {
+		if (desc->pd_ops->op_lprocfs_init) {
 			rc = desc->pd_ops->op_lprocfs_init(svc);
 			if (rc != 0) {
 				rc2 = nrs_policy_unregister_locked(desc);
@@ -1278,7 +1274,7 @@ int ptlrpc_service_nrs_setup(struct ptlrpc_service *svc)
 		if (!nrs_policy_compatible(svc, desc))
 			continue;
 
-		if (desc->pd_ops->op_lprocfs_init != NULL) {
+		if (desc->pd_ops->op_lprocfs_init) {
 			rc = desc->pd_ops->op_lprocfs_init(svc);
 			if (rc != 0)
 				goto failed;
@@ -1319,7 +1315,7 @@ void ptlrpc_service_nrs_cleanup(struct ptlrpc_service *svc)
 		if (!nrs_policy_compatible(svc, desc))
 			continue;
 
-		if (desc->pd_ops->op_lprocfs_fini != NULL)
+		if (desc->pd_ops->op_lprocfs_fini)
 			desc->pd_ops->op_lprocfs_fini(svc);
 	}
 
@@ -1459,7 +1455,7 @@ ptlrpc_nrs_req_get_nolock0(struct ptlrpc_service_part *svcpt, bool hp,
 	list_for_each_entry(policy, &nrs->nrs_policy_queued,
 				pol_list_queued) {
 		nrq = nrs_request_get(policy, peek, force);
-		if (nrq != NULL) {
+		if (nrq) {
 			if (likely(!peek)) {
 				nrq->nr_started = 1;
 
diff --git a/drivers/staging/lustre/lustre/ptlrpc/nrs_fifo.c b/drivers/staging/lustre/lustre/ptlrpc/nrs_fifo.c
index 8e21f0c..77894f8 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/nrs_fifo.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/nrs_fifo.c
@@ -83,7 +83,7 @@ static int nrs_fifo_start(struct ptlrpc_nrs_policy *policy)
 	head = kzalloc_node(sizeof(*head), GFP_NOFS,
 			    cfs_cpt_spread_node(nrs_pol2cptab(policy),
 						nrs_pol2cptid(policy)));
-	if (head == NULL)
+	if (!head)
 		return -ENOMEM;
 
 	INIT_LIST_HEAD(&head->fh_list);
@@ -104,7 +104,7 @@ static void nrs_fifo_stop(struct ptlrpc_nrs_policy *policy)
 {
 	struct nrs_fifo_head *head = policy->pol_private;
 
-	LASSERT(head != NULL);
+	LASSERT(head);
 	LASSERT(list_empty(&head->fh_list));
 
 	kfree(head);
@@ -169,7 +169,7 @@ struct ptlrpc_nrs_request *nrs_fifo_req_get(struct ptlrpc_nrs_policy *policy,
 	      list_entry(head->fh_list.next, struct ptlrpc_nrs_request,
 			     nr_u.fifo.fr_list);
 
-	if (likely(!peek && nrq != NULL)) {
+	if (likely(!peek && nrq)) {
 		struct ptlrpc_request *req = container_of(nrq,
 							  struct ptlrpc_request,
 							  rq_nrq);
diff --git a/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c b/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
index f3cb518..36a6ece 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
@@ -183,7 +183,7 @@ void lustre_init_msg_v2(struct lustre_msg_v2 *msg, int count, __u32 *lens,
 	for (i = 0; i < count; i++)
 		msg->lm_buflens[i] = lens[i];
 
-	if (bufs == NULL)
+	if (!bufs)
 		return;
 
 	ptr = (char *)msg + lustre_msg_hdr_size_v2(count);
@@ -306,7 +306,7 @@ int lustre_pack_reply_v2(struct ptlrpc_request *req, int count,
 	struct ptlrpc_reply_state *rs;
 	int msg_len, rc;
 
-	LASSERT(req->rq_reply_state == NULL);
+	LASSERT(!req->rq_reply_state);
 
 	if ((flags & LPRFL_EARLY_REPLY) == 0) {
 		spin_lock(&req->rq_lock);
@@ -383,7 +383,6 @@ void *lustre_msg_buf_v2(struct lustre_msg_v2 *m, int n, int min_size)
 {
 	int i, offset, buflen, bufcount;
 
-	LASSERT(m != NULL);
 	LASSERT(n >= 0);
 
 	bufcount = m->lm_bufcount;
@@ -488,7 +487,7 @@ void lustre_free_reply_state(struct ptlrpc_reply_state *rs)
 	LASSERT(!rs->rs_difficult || rs->rs_handled);
 	LASSERT(!rs->rs_on_net);
 	LASSERT(!rs->rs_scheduled);
-	LASSERT(rs->rs_export == NULL);
+	LASSERT(!rs->rs_export);
 	LASSERT(rs->rs_nlocks == 0);
 	LASSERT(list_empty(&rs->rs_exp_list));
 	LASSERT(list_empty(&rs->rs_obd_list));
@@ -705,7 +704,7 @@ char *lustre_msg_string(struct lustre_msg *m, int index, int max_len)
 		LASSERTF(0, "incorrect message magic: %08x\n", m->lm_magic);
 	}
 
-	if (str == NULL) {
+	if (!str) {
 		CERROR("can't unpack string in msg %p buffer[%d]\n", m, index);
 		return NULL;
 	}
@@ -740,7 +739,6 @@ static inline void *__lustre_swab_buf(struct lustre_msg *msg, int index,
 {
 	void *ptr = NULL;
 
-	LASSERT(msg != NULL);
 	switch (msg->lm_magic) {
 	case LUSTRE_MSG_MAGIC_V2:
 		ptr = lustre_msg_buf_v2(msg, index, min_size);
@@ -1377,7 +1375,7 @@ void lustre_msg_set_jobid(struct lustre_msg *msg, char *jobid)
 				       sizeof(struct ptlrpc_body));
 		LASSERTF(pb, "invalid msg %p: no ptlrpc body!\n", msg);
 
-		if (jobid != NULL)
+		if (jobid)
 			memcpy(pb->pb_jobid, jobid, JOBSTATS_JOBID_SIZE);
 		else if (pb->pb_jobid[0] == '\0')
 			lustre_get_jobid(pb->pb_jobid);
@@ -1427,7 +1425,7 @@ int do_set_info_async(struct obd_import *imp,
 	int rc;
 
 	req = ptlrpc_request_alloc(imp, &RQF_OBD_SET_INFO);
-	if (req == NULL)
+	if (!req)
 		return -ENOMEM;
 
 	req_capsule_set_size(&req->rq_pill, &RMF_SETINFO_KEY,
diff --git a/drivers/staging/lustre/lustre/ptlrpc/pinger.c b/drivers/staging/lustre/lustre/ptlrpc/pinger.c
index fb2d523..aae9b52 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/pinger.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/pinger.c
@@ -68,7 +68,7 @@ int ptlrpc_obd_ping(struct obd_device *obd)
 	struct ptlrpc_request *req;
 
 	req = ptlrpc_prep_ping(obd->u.cli.cl_import);
-	if (req == NULL)
+	if (!req)
 		return -ENOMEM;
 
 	req->rq_send_state = LUSTRE_IMP_FULL;
@@ -86,7 +86,7 @@ static int ptlrpc_ping(struct obd_import *imp)
 	struct ptlrpc_request *req;
 
 	req = ptlrpc_prep_ping(imp);
-	if (req == NULL) {
+	if (!req) {
 		CERROR("OOM trying to ping %s->%s\n",
 		       imp->imp_obd->obd_uuid.uuid,
 		       obd2cli_tgt(imp->imp_obd));
@@ -489,7 +489,6 @@ int ptlrpc_del_timeout_client(struct list_head *obd_list,
 			break;
 		}
 	}
-	LASSERTF(ti != NULL, "ti is NULL !\n");
 	if (list_empty(&ti->ti_obd_list)) {
 		list_del(&ti->ti_chain);
 		kfree(ti);
diff --git a/drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c b/drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c
index 60fb0ce..f847383 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c
@@ -163,8 +163,6 @@ void ptlrpcd_wake(struct ptlrpc_request *req)
 {
 	struct ptlrpc_request_set *rq_set = req->rq_set;
 
-	LASSERT(rq_set != NULL);
-
 	wake_up(&rq_set->set_waitq);
 }
 EXPORT_SYMBOL(ptlrpcd_wake);
@@ -176,7 +174,7 @@ ptlrpcd_select_pc(struct ptlrpc_request *req)
 	int		cpt;
 	int		idx;
 
-	if (req != NULL && req->rq_send_state != LUSTRE_IMP_FULL)
+	if (req && req->rq_send_state != LUSTRE_IMP_FULL)
 		return &ptlrpcd_rcv;
 
 	cpt = cfs_cpt_current(cfs_cpt_table, 1);
@@ -240,7 +238,7 @@ void ptlrpcd_add_req(struct ptlrpc_request *req)
 
 		req->rq_invalid_rqset = 0;
 		spin_unlock(&req->rq_lock);
-		l_wait_event(req->rq_set_waitq, (req->rq_set == NULL), &lwi);
+		l_wait_event(req->rq_set_waitq, !req->rq_set, &lwi);
 	} else if (req->rq_set) {
 		/* If we have a valid "rq_set", just reuse it to avoid double
 		 * linked. */
@@ -349,12 +347,12 @@ static int ptlrpcd_check(struct lu_env *env, struct ptlrpcd_ctl *pc)
 				partner = pc->pc_partners[pc->pc_cursor++];
 				if (pc->pc_cursor >= pc->pc_npartners)
 					pc->pc_cursor = 0;
-				if (partner == NULL)
+				if (!partner)
 					continue;
 
 				spin_lock(&partner->pc_lock);
 				ps = partner->pc_set;
-				if (ps == NULL) {
+				if (!ps) {
 					spin_unlock(&partner->pc_lock);
 					continue;
 				}
@@ -580,7 +578,7 @@ int ptlrpcd_start(struct ptlrpcd_ctl *pc)
 	return 0;
 
 out_set:
-	if (pc->pc_set != NULL) {
+	if (pc->pc_set) {
 		struct ptlrpc_request_set *set = pc->pc_set;
 
 		spin_lock(&pc->pc_lock);
@@ -631,7 +629,7 @@ void ptlrpcd_free(struct ptlrpcd_ctl *pc)
 
 out:
 	if (pc->pc_npartners > 0) {
-		LASSERT(pc->pc_partners != NULL);
+		LASSERT(pc->pc_partners);
 
 		kfree(pc->pc_partners);
 		pc->pc_partners = NULL;
@@ -645,7 +643,7 @@ static void ptlrpcd_fini(void)
 	int i;
 	int j;
 
-	if (ptlrpcds != NULL) {
+	if (ptlrpcds) {
 		for (i = 0; i < ptlrpcds_num; i++) {
 			if (!ptlrpcds[i])
 				break;
diff --git a/drivers/staging/lustre/lustre/ptlrpc/recover.c b/drivers/staging/lustre/lustre/ptlrpc/recover.c
index 4359cac..d923197 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/recover.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/recover.c
@@ -138,7 +138,7 @@ int ptlrpc_replay_next(struct obd_import *imp, int *inflight)
 
 	/* All the requests in committed list have been replayed, let's replay
 	 * the imp_replay_list */
-	if (req == NULL) {
+	if (!req) {
 		list_for_each_safe(tmp, pos, &imp->imp_replay_list) {
 			req = list_entry(tmp, struct ptlrpc_request,
 					 rq_replay_list);
@@ -153,14 +153,14 @@ int ptlrpc_replay_next(struct obd_import *imp, int *inflight)
 	 * has occurred), then stop on the matching req and send it again.
 	 * If, however, the last sent transno has been committed then we
 	 * continue replay from the next request. */
-	if (req != NULL && imp->imp_resend_replay)
+	if (req && imp->imp_resend_replay)
 		lustre_msg_add_flags(req->rq_reqmsg, MSG_RESENT);
 
 	spin_lock(&imp->imp_lock);
 	imp->imp_resend_replay = 0;
 	spin_unlock(&imp->imp_lock);
 
-	if (req != NULL) {
+	if (req) {
 		rc = ptlrpc_replay_req(req);
 		if (rc) {
 			CERROR("recovery replay error %d for req %llu\n",
diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec.c b/drivers/staging/lustre/lustre/ptlrpc/sec.c
index 39f5261..c91e131 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/sec.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/sec.c
@@ -94,7 +94,7 @@ int sptlrpc_unregister_policy(struct ptlrpc_sec_policy *policy)
 	LASSERT(number < SPTLRPC_POLICY_MAX);
 
 	write_lock(&policy_lock);
-	if (unlikely(policies[number] == NULL)) {
+	if (unlikely(!policies[number])) {
 		write_unlock(&policy_lock);
 		CERROR("%s: already unregistered\n", policy->sp_name);
 		return -EINVAL;
@@ -126,11 +126,11 @@ struct ptlrpc_sec_policy *sptlrpc_wireflavor2policy(__u32 flavor)
 		policy = policies[number];
 		if (policy && !try_module_get(policy->sp_owner))
 			policy = NULL;
-		if (policy == NULL)
+		if (!policy)
 			flag = atomic_read(&loaded);
 		read_unlock(&policy_lock);
 
-		if (policy != NULL || flag != 0 ||
+		if (policy || flag != 0 ||
 		    number != SPTLRPC_POLICY_GSS)
 			break;
 
@@ -327,7 +327,7 @@ static int import_sec_validate_get(struct obd_import *imp,
 	}
 
 	*sec = sptlrpc_import_sec_ref(imp);
-	if (*sec == NULL) {
+	if (!*sec) {
 		CERROR("import %p (%s) with no sec\n",
 		       imp, ptlrpc_import_state_name(imp->imp_state));
 		return -EACCES;
@@ -429,7 +429,7 @@ int sptlrpc_req_ctx_switch(struct ptlrpc_request *req,
 	reqmsg_size = req->rq_reqlen;
 	if (reqmsg_size != 0) {
 		reqmsg = libcfs_kvzalloc(reqmsg_size, GFP_NOFS);
-		if (reqmsg == NULL)
+		if (!reqmsg)
 			return -ENOMEM;
 		memcpy(reqmsg, req->rq_reqmsg, reqmsg_size);
 	}
@@ -938,7 +938,7 @@ static int do_cli_unwrap_reply(struct ptlrpc_request *req)
 	LASSERT(ctx->cc_sec);
 	LASSERT(req->rq_repbuf);
 	LASSERT(req->rq_repdata);
-	LASSERT(req->rq_repmsg == NULL);
+	LASSERT(!req->rq_repmsg);
 
 	req->rq_rep_swab_mask = 0;
 
@@ -1000,8 +1000,8 @@ static int do_cli_unwrap_reply(struct ptlrpc_request *req)
 int sptlrpc_cli_unwrap_reply(struct ptlrpc_request *req)
 {
 	LASSERT(req->rq_repbuf);
-	LASSERT(req->rq_repdata == NULL);
-	LASSERT(req->rq_repmsg == NULL);
+	LASSERT(!req->rq_repdata);
+	LASSERT(!req->rq_repmsg);
 	LASSERT(req->rq_reply_off + req->rq_nob_received <= req->rq_repbuf_len);
 
 	if (req->rq_reply_off == 0 &&
@@ -1046,13 +1046,13 @@ int sptlrpc_cli_unwrap_early_reply(struct ptlrpc_request *req,
 	int rc;
 
 	early_req = ptlrpc_request_cache_alloc(GFP_NOFS);
-	if (early_req == NULL)
+	if (!early_req)
 		return -ENOMEM;
 
 	early_size = req->rq_nob_received;
 	early_bufsz = size_roundup_power2(early_size);
 	early_buf = libcfs_kvzalloc(early_bufsz, GFP_NOFS);
-	if (early_buf == NULL) {
+	if (!early_buf) {
 		rc = -ENOMEM;
 		goto err_req;
 	}
@@ -1067,8 +1067,8 @@ int sptlrpc_cli_unwrap_early_reply(struct ptlrpc_request *req,
 	}
 
 	LASSERT(req->rq_repbuf);
-	LASSERT(req->rq_repdata == NULL);
-	LASSERT(req->rq_repmsg == NULL);
+	LASSERT(!req->rq_repdata);
+	LASSERT(!req->rq_repmsg);
 
 	if (req->rq_reply_off != 0) {
 		CERROR("early reply with offset %u\n", req->rq_reply_off);
@@ -1354,12 +1354,12 @@ int sptlrpc_import_sec_adapt(struct obd_import *imp,
 
 	might_sleep();
 
-	if (imp == NULL)
+	if (!imp)
 		return 0;
 
 	conn = imp->imp_connection;
 
-	if (svc_ctx == NULL) {
+	if (!svc_ctx) {
 		struct client_obd *cliobd = &imp->imp_obd->u.cli;
 		/*
 		 * normal import, determine flavor from rule set, except
@@ -1447,11 +1447,11 @@ static void import_flush_ctx_common(struct obd_import *imp,
 {
 	struct ptlrpc_sec *sec;
 
-	if (imp == NULL)
+	if (!imp)
 		return;
 
 	sec = sptlrpc_import_sec_ref(imp);
-	if (sec == NULL)
+	if (!sec)
 		return;
 
 	sec_cop_flush_ctx_cache(sec, uid, grace, force);
@@ -1484,7 +1484,7 @@ int sptlrpc_cli_alloc_reqbuf(struct ptlrpc_request *req, int msgsize)
 	LASSERT(ctx);
 	LASSERT(ctx->cc_sec);
 	LASSERT(ctx->cc_sec->ps_policy);
-	LASSERT(req->rq_reqmsg == NULL);
+	LASSERT(!req->rq_reqmsg);
 	LASSERT_ATOMIC_POS(&ctx->cc_refcount);
 
 	policy = ctx->cc_sec->ps_policy;
@@ -1515,7 +1515,7 @@ void sptlrpc_cli_free_reqbuf(struct ptlrpc_request *req)
 	LASSERT(ctx->cc_sec->ps_policy);
 	LASSERT_ATOMIC_POS(&ctx->cc_refcount);
 
-	if (req->rq_reqbuf == NULL && req->rq_clrbuf == NULL)
+	if (!req->rq_reqbuf && !req->rq_clrbuf)
 		return;
 
 	policy = ctx->cc_sec->ps_policy;
@@ -1632,7 +1632,7 @@ void sptlrpc_cli_free_repbuf(struct ptlrpc_request *req)
 	LASSERT(ctx->cc_sec->ps_policy);
 	LASSERT_ATOMIC_POS(&ctx->cc_refcount);
 
-	if (req->rq_repbuf == NULL)
+	if (!req->rq_repbuf)
 		return;
 	LASSERT(req->rq_repbuf_len);
 
@@ -1684,12 +1684,12 @@ int sptlrpc_target_export_check(struct obd_export *exp,
 {
 	struct sptlrpc_flavor flavor;
 
-	if (exp == NULL)
+	if (!exp)
 		return 0;
 
 	/* client side export has no imp_reverse, skip
 	 * FIXME maybe we should check flavor this as well??? */
-	if (exp->exp_imp_reverse == NULL)
+	if (!exp->exp_imp_reverse)
 		return 0;
 
 	/* don't care about ctx fini rpc */
@@ -1915,9 +1915,9 @@ int sptlrpc_svc_unwrap_request(struct ptlrpc_request *req)
 	int rc;
 
 	LASSERT(msg);
-	LASSERT(req->rq_reqmsg == NULL);
-	LASSERT(req->rq_repmsg == NULL);
-	LASSERT(req->rq_svc_ctx == NULL);
+	LASSERT(!req->rq_reqmsg);
+	LASSERT(!req->rq_repmsg);
+	LASSERT(!req->rq_svc_ctx);
 
 	req->rq_req_swab_mask = 0;
 
@@ -1994,7 +1994,7 @@ int sptlrpc_svc_alloc_rs(struct ptlrpc_request *req, int msglen)
 
 		/* failed alloc, try emergency pool */
 		rs = lustre_get_emerg_rs(svcpt);
-		if (rs == NULL)
+		if (!rs)
 			return -ENOMEM;
 
 		req->rq_reply_state = rs;
@@ -2059,7 +2059,7 @@ void sptlrpc_svc_ctx_addref(struct ptlrpc_request *req)
 {
 	struct ptlrpc_svc_ctx *ctx = req->rq_svc_ctx;
 
-	if (ctx != NULL)
+	if (ctx)
 		atomic_inc(&ctx->sc_refcount);
 }
 
@@ -2067,7 +2067,7 @@ void sptlrpc_svc_ctx_decref(struct ptlrpc_request *req)
 {
 	struct ptlrpc_svc_ctx *ctx = req->rq_svc_ctx;
 
-	if (ctx == NULL)
+	if (!ctx)
 		return;
 
 	LASSERT_ATOMIC_POS(&ctx->sc_refcount);
diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c b/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c
index 52a6c51..ca04e65 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c
@@ -195,7 +195,7 @@ static void enc_pools_release_free_pages(long npages)
 
 	while (npages--) {
 		LASSERT(page_pools.epp_pools[p_idx]);
-		LASSERT(page_pools.epp_pools[p_idx][g_idx] != NULL);
+		LASSERT(page_pools.epp_pools[p_idx][g_idx]);
 
 		__free_page(page_pools.epp_pools[p_idx][g_idx]);
 		page_pools.epp_pools[p_idx][g_idx] = NULL;
@@ -316,7 +316,7 @@ void sptlrpc_enc_pool_put_pages(struct ptlrpc_bulk_desc *desc)
 	int p_idx, g_idx;
 	int i;
 
-	if (desc->bd_enc_iov == NULL)
+	if (!desc->bd_enc_iov)
 		return;
 
 	LASSERT(desc->bd_iov_count > 0);
@@ -331,9 +331,9 @@ void sptlrpc_enc_pool_put_pages(struct ptlrpc_bulk_desc *desc)
 	LASSERT(page_pools.epp_pools[p_idx]);
 
 	for (i = 0; i < desc->bd_iov_count; i++) {
-		LASSERT(desc->bd_enc_iov[i].kiov_page != NULL);
+		LASSERT(desc->bd_enc_iov[i].kiov_page);
 		LASSERT(g_idx != 0 || page_pools.epp_pools[p_idx]);
-		LASSERT(page_pools.epp_pools[p_idx][g_idx] == NULL);
+		LASSERT(!page_pools.epp_pools[p_idx][g_idx]);
 
 		page_pools.epp_pools[p_idx][g_idx] =
 					desc->bd_enc_iov[i].kiov_page;
@@ -412,7 +412,7 @@ int sptlrpc_enc_pool_init(void)
 	page_pools.epp_st_max_wait = 0;
 
 	enc_pools_alloc();
-	if (page_pools.epp_pools == NULL)
+	if (!page_pools.epp_pools)
 		return -ENOMEM;
 
 	register_shrinker(&pools_shrinker);
@@ -475,7 +475,7 @@ int bulk_sec_desc_unpack(struct lustre_msg *msg, int offset, int swabbed)
 	int			  size = msg->lm_buflens[offset];
 
 	bsd = lustre_msg_buf(msg, offset, sizeof(*bsd));
-	if (bsd == NULL) {
+	if (!bsd) {
 		CERROR("Invalid bulk sec desc: size %d\n", size);
 		return -EINVAL;
 	}
diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec_config.c b/drivers/staging/lustre/lustre/ptlrpc/sec_config.c
index 4b0b81c..93b91bf 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/sec_config.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/sec_config.c
@@ -78,7 +78,7 @@ int sptlrpc_parse_flavor(const char *str, struct sptlrpc_flavor *flvr)
 
 	memset(flvr, 0, sizeof(*flvr));
 
-	if (str == NULL || str[0] == '\0') {
+	if (!str || str[0] == '\0') {
 		flvr->sf_rpc = SPTLRPC_FLVR_INVALID;
 		return 0;
 	}
@@ -103,7 +103,7 @@ int sptlrpc_parse_flavor(const char *str, struct sptlrpc_flavor *flvr)
 			 * format: plain-hash:<hash_alg>
 			 */
 			alg = strchr(bulk, ':');
-			if (alg == NULL)
+			if (!alg)
 				goto err_out;
 			*alg++ = '\0';
 
@@ -166,7 +166,7 @@ static int sptlrpc_parse_rule(char *param, struct sptlrpc_rule *rule)
 	sptlrpc_rule_init(rule);
 
 	flavor = strchr(param, '=');
-	if (flavor == NULL) {
+	if (!flavor) {
 		CERROR("invalid param, no '='\n");
 		return -EINVAL;
 	}
@@ -216,7 +216,7 @@ static int sptlrpc_parse_rule(char *param, struct sptlrpc_rule *rule)
 static void sptlrpc_rule_set_free(struct sptlrpc_rule_set *rset)
 {
 	LASSERT(rset->srs_nslot ||
-		(rset->srs_nrule == 0 && rset->srs_rules == NULL));
+		(rset->srs_nrule == 0 && !rset->srs_rules));
 
 	if (rset->srs_nslot) {
 		kfree(rset->srs_rules);
@@ -241,7 +241,7 @@ static int sptlrpc_rule_set_expand(struct sptlrpc_rule_set *rset)
 
 	/* better use realloc() if available */
 	rules = kcalloc(nslot, sizeof(*rset->srs_rules), GFP_NOFS);
-	if (rules == NULL)
+	if (!rules)
 		return -ENOMEM;
 
 	if (rset->srs_nrule) {
@@ -450,7 +450,7 @@ static void target2fsname(const char *tgt, char *fsname, int buflen)
 	}
 
 	/* if we didn't find the pattern, treat the whole string as fsname */
-	if (ptr == NULL)
+	if (!ptr)
 		len = strlen(tgt);
 	else
 		len = ptr - tgt;
@@ -579,13 +579,13 @@ static int __sptlrpc_process_config(struct lustre_cfg *lcfg,
 	int rc;
 
 	target = lustre_cfg_string(lcfg, 1);
-	if (target == NULL) {
+	if (!target) {
 		CERROR("missing target name\n");
 		return -EINVAL;
 	}
 
 	param = lustre_cfg_string(lcfg, 2);
-	if (param == NULL) {
+	if (!param) {
 		CERROR("missing parameter\n");
 		return -EINVAL;
 	}
@@ -603,12 +603,12 @@ static int __sptlrpc_process_config(struct lustre_cfg *lcfg,
 	if (rc)
 		return -EINVAL;
 
-	if (conf == NULL) {
+	if (!conf) {
 		target2fsname(target, fsname, sizeof(fsname));
 
 		mutex_lock(&sptlrpc_conf_lock);
 		conf = sptlrpc_conf_get(fsname, 0);
-		if (conf == NULL) {
+		if (!conf) {
 			CERROR("can't find conf\n");
 			rc = -ENOMEM;
 		} else {
@@ -638,7 +638,7 @@ static int logname2fsname(const char *logname, char *buf, int buflen)
 	int len;
 
 	ptr = strrchr(logname, '-');
-	if (ptr == NULL || strcmp(ptr, "-sptlrpc")) {
+	if (!ptr || strcmp(ptr, "-sptlrpc")) {
 		CERROR("%s is not a sptlrpc config log\n", logname);
 		return -EINVAL;
 	}
@@ -772,7 +772,7 @@ void sptlrpc_conf_choose_flavor(enum lustre_sec_part from,
 	mutex_lock(&sptlrpc_conf_lock);
 
 	conf = sptlrpc_conf_get(name, 0);
-	if (conf == NULL)
+	if (!conf)
 		goto out;
 
 	/* convert uuid name (supposed end with _UUID) to target name */
diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec_lproc.c b/drivers/staging/lustre/lustre/ptlrpc/sec_lproc.c
index bda9a77..e610a8d 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/sec_lproc.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/sec_lproc.c
@@ -82,7 +82,7 @@ static int sptlrpc_info_lprocfs_seq_show(struct seq_file *seq, void *v)
 
 	if (cli->cl_import)
 		sec = sptlrpc_import_sec_ref(cli->cl_import);
-	if (sec == NULL)
+	if (!sec)
 		goto out;
 
 	sec_flags2str(sec->ps_flvr.sf_flags, str, sizeof(str));
@@ -121,7 +121,7 @@ static int sptlrpc_ctxs_lprocfs_seq_show(struct seq_file *seq, void *v)
 
 	if (cli->cl_import)
 		sec = sptlrpc_import_sec_ref(cli->cl_import);
-	if (sec == NULL)
+	if (!sec)
 		goto out;
 
 	if (sec->ps_policy->sp_cops->display)
@@ -178,7 +178,7 @@ int sptlrpc_lproc_init(void)
 {
 	int rc;
 
-	LASSERT(sptlrpc_debugfs_dir == NULL);
+	LASSERT(!sptlrpc_debugfs_dir);
 
 	sptlrpc_debugfs_dir = ldebugfs_register("sptlrpc", debugfs_lustre_root,
 						sptlrpc_lprocfs_vars, NULL);
diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec_null.c b/drivers/staging/lustre/lustre/ptlrpc/sec_null.c
index ebfa609..446837d 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/sec_null.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/sec_null.c
@@ -250,7 +250,7 @@ int null_enlarge_reqbuf(struct ptlrpc_sec *sec,
 		alloc_size = size_roundup_power2(newmsg_size);
 
 		newbuf = libcfs_kvzalloc(alloc_size, GFP_NOFS);
-		if (newbuf == NULL)
+		if (!newbuf)
 			return -ENOMEM;
 
 		/* Must lock this, so that otherwise unprotected change of
@@ -319,7 +319,7 @@ int null_alloc_rs(struct ptlrpc_request *req, int msgsize)
 		LASSERT(rs->rs_size >= rs_size);
 	} else {
 		rs = libcfs_kvzalloc(rs_size, GFP_NOFS);
-		if (rs == NULL)
+		if (!rs)
 			return -ENOMEM;
 
 		rs->rs_size = rs_size;
diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec_plain.c b/drivers/staging/lustre/lustre/ptlrpc/sec_plain.c
index 905a414..cffddc0 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/sec_plain.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/sec_plain.c
@@ -104,7 +104,7 @@ static int plain_unpack_bsd(struct lustre_msg *msg, int swabbed)
 		return -EPROTO;
 
 	bsd = lustre_msg_buf(msg, PLAIN_PACK_BULK_OFF, PLAIN_BSD_SIZE);
-	if (bsd == NULL) {
+	if (!bsd) {
 		CERROR("bulk sec desc has short size %d\n",
 		       lustre_msg_buflen(msg, PLAIN_PACK_BULK_OFF));
 		return -EPROTO;
@@ -227,7 +227,7 @@ int plain_ctx_verify(struct ptlrpc_cli_ctx *ctx, struct ptlrpc_request *req)
 	swabbed = ptlrpc_rep_need_swab(req);
 
 	phdr = lustre_msg_buf(msg, PLAIN_PACK_HDR_OFF, sizeof(*phdr));
-	if (phdr == NULL) {
+	if (!phdr) {
 		CERROR("missing plain header\n");
 		return -EPROTO;
 	}
@@ -419,7 +419,7 @@ void plain_destroy_sec(struct ptlrpc_sec *sec)
 	LASSERT(sec->ps_import);
 	LASSERT(atomic_read(&sec->ps_refcount) == 0);
 	LASSERT(atomic_read(&sec->ps_nctx) == 0);
-	LASSERT(plsec->pls_ctx == NULL);
+	LASSERT(!plsec->pls_ctx);
 
 	class_import_put(sec->ps_import);
 
@@ -468,7 +468,7 @@ struct ptlrpc_sec *plain_create_sec(struct obd_import *imp,
 	/* install ctx immediately if this is a reverse sec */
 	if (svc_ctx) {
 		ctx = plain_sec_install_ctx(plsec);
-		if (ctx == NULL) {
+		if (!ctx) {
 			plain_destroy_sec(sec);
 			return NULL;
 		}
@@ -492,7 +492,7 @@ struct ptlrpc_cli_ctx *plain_lookup_ctx(struct ptlrpc_sec *sec,
 		atomic_inc(&ctx->cc_refcount);
 	read_unlock(&plsec->pls_lock);
 
-	if (unlikely(ctx == NULL))
+	if (unlikely(!ctx))
 		ctx = plain_sec_install_ctx(plsec);
 
 	return ctx;
@@ -665,7 +665,7 @@ int plain_enlarge_reqbuf(struct ptlrpc_sec *sec,
 		newbuf_size = size_roundup_power2(newbuf_size);
 
 		newbuf = libcfs_kvzalloc(newbuf_size, GFP_NOFS);
-		if (newbuf == NULL)
+		if (!newbuf)
 			return -ENOMEM;
 
 		/* Must lock this, so that otherwise unprotected change of
@@ -732,7 +732,7 @@ int plain_accept(struct ptlrpc_request *req)
 	swabbed = ptlrpc_req_need_swab(req);
 
 	phdr = lustre_msg_buf(msg, PLAIN_PACK_HDR_OFF, sizeof(*phdr));
-	if (phdr == NULL) {
+	if (!phdr) {
 		CERROR("missing plain header\n");
 		return -EPROTO;
 	}
@@ -801,7 +801,7 @@ int plain_alloc_rs(struct ptlrpc_request *req, int msgsize)
 		LASSERT(rs->rs_size >= rs_size);
 	} else {
 		rs = libcfs_kvzalloc(rs_size, GFP_NOFS);
-		if (rs == NULL)
+		if (!rs)
 			return -ENOMEM;
 
 		rs->rs_size = rs_size;
diff --git a/drivers/staging/lustre/lustre/ptlrpc/service.c b/drivers/staging/lustre/lustre/ptlrpc/service.c
index 8598300..38dbba5 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/service.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/service.c
@@ -77,7 +77,7 @@ ptlrpc_alloc_rqbd(struct ptlrpc_service_part *svcpt)
 	rqbd = kzalloc_node(sizeof(*rqbd), GFP_NOFS,
 			    cfs_cpt_spread_node(svc->srv_cptable,
 						svcpt->scp_cpt));
-	if (rqbd == NULL)
+	if (!rqbd)
 		return NULL;
 
 	rqbd->rqbd_svcpt = svcpt;
@@ -89,7 +89,7 @@ ptlrpc_alloc_rqbd(struct ptlrpc_service_part *svcpt)
 						svcpt->scp_cpt,
 						svc->srv_buf_size,
 						GFP_KERNEL);
-	if (rqbd->rqbd_buffer == NULL) {
+	if (!rqbd->rqbd_buffer) {
 		kfree(rqbd);
 		return NULL;
 	}
@@ -150,7 +150,7 @@ ptlrpc_grow_req_bufs(struct ptlrpc_service_part *svcpt, int post)
 
 		rqbd = ptlrpc_alloc_rqbd(svcpt);
 
-		if (rqbd == NULL) {
+		if (!rqbd) {
 			CERROR("%s: Can't allocate request buffer\n",
 			       svc->srv_name);
 			rc = -ENOMEM;
@@ -490,7 +490,7 @@ ptlrpc_service_part_init(struct ptlrpc_service *svc,
 	array->paa_reqs_array =
 		kzalloc_node(sizeof(struct list_head) * size, GFP_NOFS,
 			     cfs_cpt_spread_node(svc->srv_cptable, cpt));
-	if (array->paa_reqs_array == NULL)
+	if (!array->paa_reqs_array)
 		return -ENOMEM;
 
 	for (index = 0; index < size; index++)
@@ -499,7 +499,7 @@ ptlrpc_service_part_init(struct ptlrpc_service *svc,
 	array->paa_reqs_count =
 		kzalloc_node(sizeof(__u32) * size, GFP_NOFS,
 			     cfs_cpt_spread_node(svc->srv_cptable, cpt));
-	if (array->paa_reqs_count == NULL)
+	if (!array->paa_reqs_count)
 		goto free_reqs_array;
 
 	setup_timer(&svcpt->scp_at_timer, ptlrpc_at_timer,
@@ -556,14 +556,14 @@ ptlrpc_register_service(struct ptlrpc_service_conf *conf,
 	LASSERT(conf->psc_thr.tc_ctx_tags != 0);
 
 	cptable = cconf->cc_cptable;
-	if (cptable == NULL)
+	if (!cptable)
 		cptable = cfs_cpt_table;
 
 	if (!conf->psc_thr.tc_cpu_affinity) {
 		ncpts = 1;
 	} else {
 		ncpts = cfs_cpt_number(cptable);
-		if (cconf->cc_pattern != NULL) {
+		if (cconf->cc_pattern) {
 			struct cfs_expr_list *el;
 
 			rc = cfs_expr_list_parse(cconf->cc_pattern,
@@ -632,11 +632,11 @@ ptlrpc_register_service(struct ptlrpc_service_conf *conf,
 		if (!conf->psc_thr.tc_cpu_affinity)
 			cpt = CFS_CPT_ANY;
 		else
-			cpt = cpts != NULL ? cpts[i] : i;
+			cpt = cpts ? cpts[i] : i;
 
 		svcpt = kzalloc_node(sizeof(*svcpt), GFP_NOFS,
 				     cfs_cpt_spread_node(cptable, cpt));
-		if (svcpt == NULL) {
+		if (!svcpt) {
 			rc = -ENOMEM;
 			goto failed;
 		}
@@ -846,7 +846,7 @@ static void ptlrpc_server_finish_active_request(
 
 	ptlrpc_nrs_req_finalize(req);
 
-	if (req->rq_export != NULL)
+	if (req->rq_export)
 		class_export_rpc_dec(req->rq_export);
 
 	ptlrpc_server_finish_request(svcpt, req);
@@ -869,13 +869,13 @@ static int ptlrpc_check_req(struct ptlrpc_request *req)
 			  req->rq_export->exp_conn_cnt);
 		return -EEXIST;
 	}
-	if (unlikely(obd == NULL || obd->obd_fail)) {
+	if (unlikely(!obd || obd->obd_fail)) {
 		/*
 		 * Failing over, don't handle any more reqs, send
 		 * error response instead.
 		 */
 		CDEBUG(D_RPCTRACE, "Dropping req %p for failed obd %s\n",
-		       req, (obd != NULL) ? obd->obd_name : "unknown");
+		       req, obd ? obd->obd_name : "unknown");
 		rc = -ENODEV;
 	} else if (lustre_msg_get_flags(req->rq_reqmsg) &
 		   (MSG_REPLAY | MSG_REQ_REPLAY_DONE)) {
@@ -1044,7 +1044,7 @@ static int ptlrpc_at_send_early_reply(struct ptlrpc_request *req)
 	newdl = ktime_get_real_seconds() + at_get(&svcpt->scp_at_estimate);
 
 	reqcopy = ptlrpc_request_cache_alloc(GFP_NOFS);
-	if (reqcopy == NULL)
+	if (!reqcopy)
 		return -ENOMEM;
 	reqmsg = libcfs_kvzalloc(req->rq_reqlen, GFP_NOFS);
 	if (!reqmsg) {
@@ -1074,7 +1074,7 @@ static int ptlrpc_at_send_early_reply(struct ptlrpc_request *req)
 	/* Connection ref */
 	reqcopy->rq_export = class_conn2export(
 				     lustre_msg_get_handle(reqcopy->rq_reqmsg));
-	if (reqcopy->rq_export == NULL) {
+	if (!reqcopy->rq_export) {
 		rc = -ENODEV;
 		goto out;
 	}
@@ -1316,7 +1316,7 @@ static bool ptlrpc_server_allow_high(struct ptlrpc_service_part *svcpt,
 		     CFS_FAIL_PRECHECK(OBD_FAIL_PTLRPC_CANCEL_RESEND))) {
 		/* leave just 1 thread for normal RPCs */
 		running = PTLRPC_NTHRS_INIT;
-		if (svcpt->scp_service->srv_ops.so_hpreq_handler != NULL)
+		if (svcpt->scp_service->srv_ops.so_hpreq_handler)
 			running += 1;
 	}
 
@@ -1355,7 +1355,7 @@ static bool ptlrpc_server_allow_normal(struct ptlrpc_service_part *svcpt,
 		     CFS_FAIL_PRECHECK(OBD_FAIL_PTLRPC_CANCEL_RESEND))) {
 		/* leave just 1 thread for normal RPCs */
 		running = PTLRPC_NTHRS_INIT;
-		if (svcpt->scp_service->srv_ops.so_hpreq_handler != NULL)
+		if (svcpt->scp_service->srv_ops.so_hpreq_handler)
 			running += 1;
 	}
 
@@ -1405,7 +1405,7 @@ ptlrpc_server_request_get(struct ptlrpc_service_part *svcpt, bool force)
 
 	if (ptlrpc_server_high_pending(svcpt, force)) {
 		req = ptlrpc_nrs_req_get_nolock(svcpt, true, force);
-		if (req != NULL) {
+		if (req) {
 			svcpt->scp_hreq_count++;
 			goto got_request;
 		}
@@ -1413,7 +1413,7 @@ ptlrpc_server_request_get(struct ptlrpc_service_part *svcpt, bool force)
 
 	if (ptlrpc_server_normal_pending(svcpt, force)) {
 		req = ptlrpc_nrs_req_get_nolock(svcpt, false, force);
-		if (req != NULL) {
+		if (req) {
 			svcpt->scp_hreq_count = 0;
 			goto got_request;
 		}
@@ -1598,7 +1598,7 @@ ptlrpc_server_handle_request(struct ptlrpc_service_part *svcpt,
 	int fail_opc = 0;
 
 	request = ptlrpc_server_request_get(svcpt, false);
-	if (request == NULL)
+	if (!request)
 		return 0;
 
 	if (OBD_FAIL_CHECK(OBD_FAIL_PTLRPC_HPREQ_NOTIMEOUT))
@@ -1620,7 +1620,7 @@ ptlrpc_server_handle_request(struct ptlrpc_service_part *svcpt,
 	timediff = timespec64_sub(work_start, request->rq_arrival_time);
 	timediff_usecs = timediff.tv_sec * USEC_PER_SEC +
 			 timediff.tv_nsec / NSEC_PER_USEC;
-	if (likely(svc->srv_stats != NULL)) {
+	if (likely(svc->srv_stats)) {
 		lprocfs_counter_add(svc->srv_stats, PTLRPC_REQWAIT_CNTR,
 				    timediff_usecs);
 		lprocfs_counter_add(svc->srv_stats, PTLRPC_REQQDEPTH_CNTR,
@@ -1718,7 +1718,7 @@ put_conn:
 	       request->rq_status,
 	       (request->rq_repmsg ?
 		lustre_msg_get_status(request->rq_repmsg) : -999));
-	if (likely(svc->srv_stats != NULL && request->rq_reqmsg != NULL)) {
+	if (likely(svc->srv_stats && request->rq_reqmsg)) {
 		__u32 op = lustre_msg_get_opc(request->rq_reqmsg);
 		int opc = opcode_offset(op);
 
@@ -2008,7 +2008,7 @@ static int ptlrpc_main(void *arg)
 	set_current_groups(ginfo);
 	put_group_info(ginfo);
 
-	if (svc->srv_ops.so_thr_init != NULL) {
+	if (svc->srv_ops.so_thr_init) {
 		rc = svc->srv_ops.so_thr_init(thread);
 		if (rc)
 			goto out;
@@ -2132,10 +2132,10 @@ out_srv_fini:
 	/*
 	 * deconstruct service specific state created by ptlrpc_start_thread()
 	 */
-	if (svc->srv_ops.so_thr_done != NULL)
+	if (svc->srv_ops.so_thr_done)
 		svc->srv_ops.so_thr_done(thread);
 
-	if (env != NULL) {
+	if (env) {
 		lu_context_fini(&env->le_ctx);
 		kfree(env);
 	}
@@ -2229,14 +2229,14 @@ static void ptlrpc_stop_hr_threads(void)
 	ptlrpc_hr.hr_stopping = 1;
 
 	cfs_percpt_for_each(hrp, i, ptlrpc_hr.hr_partitions) {
-		if (hrp->hrp_thrs == NULL)
+		if (!hrp->hrp_thrs)
 			continue; /* uninitialized */
 		for (j = 0; j < hrp->hrp_nthrs; j++)
 			wake_up_all(&hrp->hrp_thrs[j].hrt_waitq);
 	}
 
 	cfs_percpt_for_each(hrp, i, ptlrpc_hr.hr_partitions) {
-		if (hrp->hrp_thrs == NULL)
+		if (!hrp->hrp_thrs)
 			continue; /* uninitialized */
 		wait_event(ptlrpc_hr.hr_waitq,
 			       atomic_read(&hrp->hrp_nstopped) ==
@@ -2333,7 +2333,7 @@ static void ptlrpc_stop_all_threads(struct ptlrpc_service *svc)
 	int i;
 
 	ptlrpc_service_for_each_part(svcpt, i, svc) {
-		if (svcpt->scp_service != NULL)
+		if (svcpt->scp_service)
 			ptlrpc_svcpt_stop_threads(svcpt);
 	}
 }
@@ -2376,8 +2376,6 @@ int ptlrpc_start_thread(struct ptlrpc_service_part *svcpt, int wait)
 	struct ptlrpc_service *svc;
 	int rc;
 
-	LASSERT(svcpt != NULL);
-
 	svc = svcpt->scp_service;
 
 	CDEBUG(D_RPCTRACE, "%s[%d] started %d min %d max %d\n",
@@ -2396,7 +2394,7 @@ int ptlrpc_start_thread(struct ptlrpc_service_part *svcpt, int wait)
 	thread = kzalloc_node(sizeof(*thread), GFP_NOFS,
 			      cfs_cpt_spread_node(svc->srv_cptable,
 						  svcpt->scp_cpt));
-	if (thread == NULL)
+	if (!thread)
 		return -ENOMEM;
 	init_waitqueue_head(&thread->t_ctl_waitq);
 
@@ -2488,7 +2486,7 @@ int ptlrpc_hr_init(void)
 
 	ptlrpc_hr.hr_partitions = cfs_percpt_alloc(ptlrpc_hr.hr_cpt_table,
 						   sizeof(*hrp));
-	if (ptlrpc_hr.hr_partitions == NULL)
+	if (!ptlrpc_hr.hr_partitions)
 		return -ENOMEM;
 
 	init_waitqueue_head(&ptlrpc_hr.hr_waitq);
@@ -2509,7 +2507,7 @@ int ptlrpc_hr_init(void)
 			kzalloc_node(hrp->hrp_nthrs * sizeof(*hrt), GFP_NOFS,
 				cfs_cpt_spread_node(ptlrpc_hr.hr_cpt_table,
 						    i));
-		if (hrp->hrp_thrs == NULL) {
+		if (!hrp->hrp_thrs) {
 			rc = -ENOMEM;
 			goto out;
 		}
@@ -2537,7 +2535,7 @@ void ptlrpc_hr_fini(void)
 	struct ptlrpc_hr_partition *hrp;
 	int i;
 
-	if (ptlrpc_hr.hr_partitions == NULL)
+	if (!ptlrpc_hr.hr_partitions)
 		return;
 
 	ptlrpc_stop_hr_threads();
@@ -2577,7 +2575,7 @@ ptlrpc_service_del_atimer(struct ptlrpc_service *svc)
 
 	/* early disarm AT timer... */
 	ptlrpc_service_for_each_part(svcpt, i, svc) {
-		if (svcpt->scp_service != NULL)
+		if (svcpt->scp_service)
 			del_timer(&svcpt->scp_at_timer);
 	}
 }
@@ -2599,7 +2597,7 @@ ptlrpc_service_unlink_rqbd(struct ptlrpc_service *svc)
 	LASSERT(rc == 0);
 
 	ptlrpc_service_for_each_part(svcpt, i, svc) {
-		if (svcpt->scp_service == NULL)
+		if (!svcpt->scp_service)
 			break;
 
 		/* Unlink all the request buffers.  This forces a 'final'
@@ -2612,7 +2610,7 @@ ptlrpc_service_unlink_rqbd(struct ptlrpc_service *svc)
 	}
 
 	ptlrpc_service_for_each_part(svcpt, i, svc) {
-		if (svcpt->scp_service == NULL)
+		if (!svcpt->scp_service)
 			break;
 
 		/* Wait for the network to release any buffers
@@ -2648,7 +2646,7 @@ ptlrpc_service_purge_all(struct ptlrpc_service *svc)
 	int i;
 
 	ptlrpc_service_for_each_part(svcpt, i, svc) {
-		if (svcpt->scp_service == NULL)
+		if (!svcpt->scp_service)
 			break;
 
 		spin_lock(&svcpt->scp_rep_lock);
@@ -2714,7 +2712,7 @@ ptlrpc_service_free(struct ptlrpc_service *svc)
 	int i;
 
 	ptlrpc_service_for_each_part(svcpt, i, svc) {
-		if (svcpt->scp_service == NULL)
+		if (!svcpt->scp_service)
 			break;
 
 		/* In case somebody rearmed this in the meantime */
@@ -2730,7 +2728,7 @@ ptlrpc_service_free(struct ptlrpc_service *svc)
 	ptlrpc_service_for_each_part(svcpt, i, svc)
 		kfree(svcpt);
 
-	if (svc->srv_cpts != NULL)
+	if (svc->srv_cpts)
 		cfs_expr_list_values_free(svc->srv_cpts, svc->srv_ncpts);
 
 	kfree(svc);
-- 
2.1.0
