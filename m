From: Chris Hanna <hannac@iu.edu>
Date: Wed,  3 Jun 2015 10:28:26 -0400
Subject: [lustre-devel] [PATCH] staging: lustre: ptlrpc: clean up whitespace
	and align function params
Message-ID: <1433341706-8073-1-git-send-email-hannac@iu.edu>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Minor changes to remove excessive whitespace and improve
readability of ptlrpc functions.

Signed-off-by: Chris Hanna <hannac@iu.edu>
---
 drivers/staging/lustre/lustre/ptlrpc/client.c      |   90 ++++----
 drivers/staging/lustre/lustre/ptlrpc/events.c      |   60 +++---
 drivers/staging/lustre/lustre/ptlrpc/import.c      |    8 +-
 drivers/staging/lustre/lustre/ptlrpc/layout.c      |   70 +++---
 drivers/staging/lustre/lustre/ptlrpc/llog_client.c |   82 ++++----
 .../staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c    |  104 +++++-----
 drivers/staging/lustre/lustre/ptlrpc/niobuf.c      |   62 +++---
 drivers/staging/lustre/lustre/ptlrpc/nrs.c         |  146 ++++++------
 drivers/staging/lustre/lustre/ptlrpc/nrs_fifo.c    |    4 +-
 .../staging/lustre/lustre/ptlrpc/pack_generic.c    |   18 +-
 drivers/staging/lustre/lustre/ptlrpc/pinger.c      |    4 +-
 drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c     |    6 +-
 drivers/staging/lustre/lustre/ptlrpc/sec.c         |   96 ++++----
 drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c    |   48 ++--
 drivers/staging/lustre/lustre/ptlrpc/sec_config.c  |   60 +++---
 drivers/staging/lustre/lustre/ptlrpc/sec_gc.c      |    2 +-
 drivers/staging/lustre/lustre/ptlrpc/sec_lproc.c   |    4 +-
 drivers/staging/lustre/lustre/ptlrpc/sec_null.c    |    8 +-
 drivers/staging/lustre/lustre/ptlrpc/sec_plain.c   |   78 ++++----
 drivers/staging/lustre/lustre/ptlrpc/service.c     |  238 ++++++++++----------
 20 files changed, 594 insertions(+), 594 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ptlrpc/client.c b/drivers/staging/lustre/lustre/ptlrpc/client.c
index 347110e..35ebe0f 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/client.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/client.c
@@ -57,8 +57,8 @@ void ptlrpc_init_client(int req_portal, int rep_portal, char *name,
 			struct ptlrpc_client *cl)
 {
 	cl->cli_request_portal = req_portal;
-	cl->cli_reply_portal   = rep_portal;
-	cl->cli_name	   = name;
+	cl->cli_reply_portal = rep_portal;
+	cl->cli_name = name;
 }
 EXPORT_SYMBOL(ptlrpc_init_client);
 
@@ -68,9 +68,9 @@ EXPORT_SYMBOL(ptlrpc_init_client);
 struct ptlrpc_connection *ptlrpc_uuid_to_connection(struct obd_uuid *uuid)
 {
 	struct ptlrpc_connection *c;
-	lnet_nid_t		self;
-	lnet_process_id_t	 peer;
-	int		       err;
+	lnet_nid_t self;
+	lnet_process_id_t peer;
+	int err;
 
 	/* ptlrpc_uuid_to_peer() initializes its 2nd parameter
 	 * before accessing its values. */
@@ -148,7 +148,7 @@ struct ptlrpc_bulk_desc *ptlrpc_prep_bulk_imp(struct ptlrpc_request *req,
 	desc->bd_import = class_import_get(imp);
 	desc->bd_req = req;
 
-	desc->bd_cbid.cbid_fn  = client_bulk_callback;
+	desc->bd_cbid.cbid_fn = client_bulk_callback;
 	desc->bd_cbid.cbid_arg = desc;
 
 	/* This makes req own desc, and free it when she frees herself */
@@ -343,8 +343,8 @@ static int unpack_reply(struct ptlrpc_request *req)
 static int ptlrpc_at_recv_early_reply(struct ptlrpc_request *req)
 {
 	struct ptlrpc_request *early_req;
-	time_t		 olddl;
-	int		    rc;
+	time_t olddl;
+	int rc;
 
 	req->rq_early = 0;
 	spin_unlock(&req->rq_lock);
@@ -580,8 +580,8 @@ static int __ptlrpc_request_bufs_pack(struct ptlrpc_request *request,
 				      int count, __u32 *lengths, char **bufs,
 				      struct ptlrpc_cli_ctx *ctx)
 {
-	struct obd_import  *imp = request->rq_import;
-	int		 rc;
+	struct obd_import *imp = request->rq_import;
+	int rc;
 
 	if (unlikely(ctx))
 		request->rq_cli_ctx = sptlrpc_cli_ctx_get(ctx);
@@ -605,10 +605,10 @@ static int __ptlrpc_request_bufs_pack(struct ptlrpc_request *request,
 	request->rq_type = PTL_RPC_MSG_REQUEST;
 	request->rq_export = NULL;
 
-	request->rq_req_cbid.cbid_fn  = request_out_callback;
+	request->rq_req_cbid.cbid_fn = request_out_callback;
 	request->rq_req_cbid.cbid_arg = request;
 
-	request->rq_reply_cbid.cbid_fn  = reply_in_callback;
+	request->rq_reply_cbid.cbid_fn = reply_in_callback;
 	request->rq_reply_cbid.cbid_arg = request;
 
 	request->rq_reply_deadline = 0;
@@ -761,8 +761,8 @@ EXPORT_SYMBOL(ptlrpc_request_alloc);
  * initialize its buffer structure according to capsule template \a format.
  */
 struct ptlrpc_request *ptlrpc_request_alloc_pool(struct obd_import *imp,
-					    struct ptlrpc_request_pool *pool,
-					    const struct req_format *format)
+						 struct ptlrpc_request_pool *pool,
+						 const struct req_format *format)
 {
 	return ptlrpc_request_alloc_internal(imp, pool, format);
 }
@@ -789,11 +789,11 @@ EXPORT_SYMBOL(ptlrpc_request_free);
  * Returns allocated request or NULL on error.
  */
 struct ptlrpc_request *ptlrpc_request_alloc_pack(struct obd_import *imp,
-						const struct req_format *format,
-						__u32 version, int opcode)
+						 const struct req_format *format,
+						 __u32 version, int opcode)
 {
 	struct ptlrpc_request *req = ptlrpc_request_alloc(imp, format);
-	int		    rc;
+	int rc;
 
 	if (req) {
 		rc = ptlrpc_request_pack(req, version, opcode);
@@ -820,7 +820,7 @@ ptlrpc_prep_req_pool(struct obd_import *imp,
 		     struct ptlrpc_request_pool *pool)
 {
 	struct ptlrpc_request *request;
-	int		    rc;
+	int rc;
 
 	request = __ptlrpc_request_alloc(imp, pool);
 	if (!request)
@@ -868,9 +868,9 @@ struct ptlrpc_request_set *ptlrpc_prep_set(void)
 	INIT_LIST_HEAD(&set->set_new_requests);
 	INIT_LIST_HEAD(&set->set_cblist);
 	set->set_max_inflight = UINT_MAX;
-	set->set_producer     = NULL;
+	set->set_producer = NULL;
 	set->set_producer_arg = NULL;
-	set->set_rc	   = 0;
+	set->set_rc = 0;
 
 	return set;
 }
@@ -894,9 +894,9 @@ struct ptlrpc_request_set *ptlrpc_prep_fcset(int max, set_producer_func func,
 	if (!set)
 		return NULL;
 
-	set->set_max_inflight  = max;
-	set->set_producer      = func;
-	set->set_producer_arg  = arg;
+	set->set_max_inflight = max;
+	set->set_producer = func;
+	set->set_producer_arg = arg;
 
 	return set;
 }
@@ -912,10 +912,10 @@ EXPORT_SYMBOL(ptlrpc_prep_fcset);
  */
 void ptlrpc_set_destroy(struct ptlrpc_request_set *set)
 {
-	struct list_head       *tmp;
-	struct list_head       *next;
-	int	       expected_phase;
-	int	       n = 0;
+	struct list_head *tmp;
+	struct list_head *next;
+	int expected_phase;
+	int n = 0;
 
 	/* Requests on the set should either all be completed, or all be new */
 	expected_phase = (atomic_read(&set->set_remaining) == 0) ?
@@ -1013,7 +1013,7 @@ EXPORT_SYMBOL(ptlrpc_set_add_req);
  * Currently only used for ptlrpcd.
  */
 void ptlrpc_set_add_new_req(struct ptlrpcd_ctl *pc,
-			   struct ptlrpc_request *req)
+			    struct ptlrpc_request *req)
 {
 	struct ptlrpc_request_set *set = pc->pc_set;
 	int count, i;
@@ -1400,7 +1400,7 @@ static int after_reply(struct ptlrpc_request *req)
  */
 static int ptlrpc_send_new_req(struct ptlrpc_request *req)
 {
-	struct obd_import     *imp = req->rq_import;
+	struct obd_import *imp = req->rq_import;
 	int rc;
 
 	LASSERT(req->rq_phase == RQ_PHASE_NEW);
@@ -1669,7 +1669,7 @@ int ptlrpc_check_set(const struct lu_env *env, struct ptlrpc_request_set *set)
 					continue;
 				}
 
-				if (status != 0)  {
+				if (status != 0) {
 					req->rq_status = status;
 					ptlrpc_rqphase_move(req,
 						RQ_PHASE_INTERPRET);
@@ -1969,8 +1969,8 @@ int ptlrpc_expire_one_request(struct ptlrpc_request *req, int async_unlink)
 int ptlrpc_expired_set(void *data)
 {
 	struct ptlrpc_request_set *set = data;
-	struct list_head		*tmp;
-	time_t		     now = get_seconds();
+	struct list_head *tmp;
+	time_t now = get_seconds();
 
 	LASSERT(set != NULL);
 
@@ -2052,11 +2052,11 @@ EXPORT_SYMBOL(ptlrpc_interrupted_set);
  */
 int ptlrpc_set_next_timeout(struct ptlrpc_request_set *set)
 {
-	struct list_head	    *tmp;
-	time_t		 now = get_seconds();
-	int		    timeout = 0;
+	struct list_head *tmp;
+	time_t now = get_seconds();
+	int timeout = 0;
 	struct ptlrpc_request *req;
-	int		    deadline;
+	int deadline;
 
 	list_for_each(tmp, &set->set_requests) {
 		req = list_entry(tmp, struct ptlrpc_request, rq_set_chain);
@@ -2105,10 +2105,10 @@ EXPORT_SYMBOL(ptlrpc_set_next_timeout);
  */
 int ptlrpc_set_wait(struct ptlrpc_request_set *set)
 {
-	struct list_head	    *tmp;
+	struct list_head *tmp;
 	struct ptlrpc_request *req;
-	struct l_wait_info     lwi;
-	int		    rc, timeout;
+	struct l_wait_info lwi;
+	int rc, timeout;
 
 	if (set->set_producer)
 		(void)ptlrpc_set_producer(set);
@@ -2353,8 +2353,8 @@ EXPORT_SYMBOL(ptlrpc_req_xid);
  */
 int ptlrpc_unregister_reply(struct ptlrpc_request *request, int async)
 {
-	int		rc;
-	wait_queue_head_t       *wq;
+	int rc;
+	wait_queue_head_t *wq;
 	struct l_wait_info lwi;
 
 	/*
@@ -2471,7 +2471,7 @@ void ptlrpc_free_committed(struct obd_import *imp)
 {
 	struct ptlrpc_request *req, *saved;
 	struct ptlrpc_request *last_req = NULL; /* temporary fire escape */
-	bool		       skip_committed_list = true;
+	bool skip_committed_list = true;
 
 	LASSERT(imp != NULL);
 	assert_spin_locked(&imp->imp_lock);
@@ -3023,8 +3023,8 @@ EXPORT_SYMBOL(ptlrpc_sample_next_xid);
  *    have delay before it really runs by ptlrpcd thread.
  */
 struct ptlrpc_work_async_args {
-	int   (*cb)(const struct lu_env *, void *);
-	void   *cbdata;
+	int (*cb)(const struct lu_env *, void *);
+	void *cbdata;
 };
 
 static void ptlrpcd_add_work_req(struct ptlrpc_request *req)
@@ -3113,7 +3113,7 @@ void *ptlrpcd_alloc_work(struct obd_import *imp,
 
 	CLASSERT(sizeof(*args) <= sizeof(req->rq_async_args));
 	args = ptlrpc_req_async_args(req);
-	args->cb     = cb;
+	args->cb = cb;
 	args->cbdata = cbdata;
 
 	return req;
diff --git a/drivers/staging/lustre/lustre/ptlrpc/events.c b/drivers/staging/lustre/lustre/ptlrpc/events.c
index 7f8644e..8cb1929 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/events.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/events.c
@@ -53,7 +53,7 @@ lnet_handle_eq_t   ptlrpc_eq_h;
  */
 void request_out_callback(lnet_event_t *ev)
 {
-	struct ptlrpc_cb_id   *cbid = ev->md.user_ptr;
+	struct ptlrpc_cb_id *cbid = ev->md.user_ptr;
 	struct ptlrpc_request *req = cbid->cbid_arg;
 
 	LASSERT(ev->type == LNET_EVENT_SEND ||
@@ -86,7 +86,7 @@ void request_out_callback(lnet_event_t *ev)
  */
 void reply_in_callback(lnet_event_t *ev)
 {
-	struct ptlrpc_cb_id   *cbid = ev->md.user_ptr;
+	struct ptlrpc_cb_id *cbid = ev->md.user_ptr;
 	struct ptlrpc_request *req = cbid->cbid_arg;
 
 	DEBUG_REQ(D_NET, req, "type %d, status %d", ev->type, ev->status);
@@ -172,9 +172,9 @@ out_wake:
  */
 void client_bulk_callback(lnet_event_t *ev)
 {
-	struct ptlrpc_cb_id     *cbid = ev->md.user_ptr;
+	struct ptlrpc_cb_id *cbid = ev->md.user_ptr;
 	struct ptlrpc_bulk_desc *desc = cbid->cbid_arg;
-	struct ptlrpc_request   *req;
+	struct ptlrpc_request *req;
 
 	LASSERT((desc->bd_type == BULK_PUT_SINK &&
 		 ev->type == LNET_EVENT_PUT) ||
@@ -245,9 +245,9 @@ void client_bulk_callback(lnet_event_t *ev)
 static void ptlrpc_req_add_history(struct ptlrpc_service_part *svcpt,
 				   struct ptlrpc_request *req)
 {
-	__u64	sec = req->rq_arrival_time.tv_sec;
-	__u32	usec = req->rq_arrival_time.tv_usec >> 4; /* usec / 16 */
-	__u64	new_seq;
+	__u64 sec = req->rq_arrival_time.tv_sec;
+	__u32 usec = req->rq_arrival_time.tv_usec >> 4; /* usec / 16 */
+	__u64 new_seq;
 
 	/* set sequence ID for request and add it to history list,
 	 * it must be called with hold svcpt::scp_lock */
@@ -281,11 +281,11 @@ static void ptlrpc_req_add_history(struct ptlrpc_service_part *svcpt,
  */
 void request_in_callback(lnet_event_t *ev)
 {
-	struct ptlrpc_cb_id		  *cbid = ev->md.user_ptr;
+	struct ptlrpc_cb_id *cbid = ev->md.user_ptr;
 	struct ptlrpc_request_buffer_desc *rqbd = cbid->cbid_arg;
-	struct ptlrpc_service_part	  *svcpt = rqbd->rqbd_svcpt;
-	struct ptlrpc_service	     *service = svcpt->scp_service;
-	struct ptlrpc_request	     *req;
+	struct ptlrpc_service_part *svcpt = rqbd->rqbd_svcpt;
+	struct ptlrpc_service *service = svcpt->scp_service;
+	struct ptlrpc_request *req;
 
 	LASSERT(ev->type == LNET_EVENT_PUT ||
 		ev->type == LNET_EVENT_UNLINK);
@@ -380,7 +380,7 @@ void request_in_callback(lnet_event_t *ev)
  */
 void reply_out_callback(lnet_event_t *ev)
 {
-	struct ptlrpc_cb_id	  *cbid = ev->md.user_ptr;
+	struct ptlrpc_cb_id *cbid = ev->md.user_ptr;
 	struct ptlrpc_reply_state *rs = cbid->cbid_arg;
 	struct ptlrpc_service_part *svcpt = rs->rs_svcpt;
 
@@ -433,17 +433,17 @@ static void ptlrpc_master_callback(lnet_event_t *ev)
 }
 
 int ptlrpc_uuid_to_peer(struct obd_uuid *uuid,
-			 lnet_process_id_t *peer, lnet_nid_t *self)
+			lnet_process_id_t *peer, lnet_nid_t *self)
 {
-	int	       best_dist = 0;
-	__u32	     best_order = 0;
-	int	       count = 0;
-	int	       rc = -ENOENT;
-	int	       portals_compatibility;
-	int	       dist;
-	__u32	     order;
-	lnet_nid_t	dst_nid;
-	lnet_nid_t	src_nid;
+	int best_dist = 0;
+	__u32 best_order = 0;
+	int count = 0;
+	int rc = -ENOENT;
+	int portals_compatibility;
+	int dist;
+	__u32 order;
+	lnet_nid_t dst_nid;
+	lnet_nid_t src_nid;
 
 	portals_compatibility = LNetCtl(IOC_LIBCFS_PORTALS_COMPATIBILITY, NULL);
 
@@ -487,10 +487,10 @@ int ptlrpc_uuid_to_peer(struct obd_uuid *uuid,
 
 void ptlrpc_ni_fini(void)
 {
-	wait_queue_head_t	 waitq;
-	struct l_wait_info  lwi;
-	int		 rc;
-	int		 retries;
+	wait_queue_head_t waitq;
+	struct l_wait_info lwi;
+	int rc;
+	int retries;
 
 	/* Wait for the event queue to become idle since there may still be
 	 * messages in flight with pending events (i.e. the fire-and-forget
@@ -523,7 +523,7 @@ void ptlrpc_ni_fini(void)
 
 lnet_pid_t ptl_get_pid(void)
 {
-	lnet_pid_t	pid;
+	lnet_pid_t pid;
 
 	pid = LUSTRE_SRV_LNET_PID;
 	return pid;
@@ -531,8 +531,8 @@ lnet_pid_t ptl_get_pid(void)
 
 int ptlrpc_ni_init(void)
 {
-	int	      rc;
-	lnet_pid_t       pid;
+	int rc;
+	lnet_pid_t pid;
 
 	pid = ptl_get_pid();
 	CDEBUG(D_NET, "My pid is: %x\n", pid);
@@ -563,7 +563,7 @@ int ptlrpc_ni_init(void)
 
 int ptlrpc_init_portals(void)
 {
-	int   rc = ptlrpc_ni_init();
+	int rc = ptlrpc_ni_init();
 
 	if (rc != 0) {
 		CERROR("network initialisation failed\n");
diff --git a/drivers/staging/lustre/lustre/ptlrpc/import.c b/drivers/staging/lustre/lustre/ptlrpc/import.c
index d5fc689..c9b8481 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/import.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/import.c
@@ -119,7 +119,7 @@ int ptlrpc_init_import(struct obd_import *imp)
 	spin_lock(&imp->imp_lock);
 
 	imp->imp_generation++;
-	imp->imp_state =  LUSTRE_IMP_NEW;
+	imp->imp_state = LUSTRE_IMP_NEW;
 
 	spin_unlock(&imp->imp_lock);
 
@@ -369,7 +369,7 @@ void ptlrpc_invalidate_import(struct obd_import *imp)
 						   imp_unregistering));
 			}
 			spin_unlock(&imp->imp_lock);
-		  }
+		}
 	} while (rc != 0);
 
 	/*
@@ -559,7 +559,7 @@ static int import_select_connection(struct obd_import *imp)
 		ptlrpc_connection_put(imp->imp_connection);
 	imp->imp_connection = ptlrpc_connection_addref(imp_conn->oic_conn);
 
-	dlmexp =  class_conn2export(&imp->imp_dlm_handle);
+	dlmexp = class_conn2export(&imp->imp_dlm_handle);
 	LASSERT(dlmexp != NULL);
 	if (dlmexp->exp_connection)
 		ptlrpc_connection_put(dlmexp->exp_connection);
@@ -1490,7 +1490,7 @@ int ptlrpc_disconnect_import(struct obd_import *imp, int noclose)
 					INITIAL_CONNECT_TIMEOUT);
 
 		IMPORT_SET_STATE(imp, LUSTRE_IMP_CONNECTING);
-		req->rq_send_state =  LUSTRE_IMP_CONNECTING;
+		req->rq_send_state = LUSTRE_IMP_CONNECTING;
 		ptlrpc_request_set_replen(req);
 		rc = ptlrpc_queue_wait(req);
 		ptlrpc_req_finished(req);
diff --git a/drivers/staging/lustre/lustre/ptlrpc/layout.c b/drivers/staging/lustre/lustre/ptlrpc/layout.c
index a42335e..d14c200 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/layout.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/layout.c
@@ -807,11 +807,11 @@ struct req_capsule;
 /*
  * Request fields.
  */
-#define DEFINE_MSGF(name, flags, size, swabber, dumper) {       \
-	.rmf_name    = (name),				  \
-	.rmf_flags   = (flags),				 \
-	.rmf_size    = (size),				  \
-	.rmf_swabber = (void (*)(void *))(swabber),	      \
+#define DEFINE_MSGF(name, flags, size, swabber, dumper) {	\
+	.rmf_name    = (name),					\
+	.rmf_flags   = (flags),					\
+	.rmf_size    = (size),					\
+	.rmf_swabber = (void (*)(void *))(swabber),		\
 	.rmf_dumper  = (void (*)(void *))(dumper)		\
 }
 
@@ -1164,25 +1164,25 @@ EXPORT_SYMBOL(RMF_SWAP_LAYOUTS);
 
 struct req_format {
 	const char *rf_name;
-	int	 rf_idx;
+	int rf_idx;
 	struct {
-		int			  nr;
+		int nr;
 		const struct req_msg_field **d;
 	} rf_fields[RCL_NR];
 };
 
-#define DEFINE_REQ_FMT(name, client, client_nr, server, server_nr) {    \
-	.rf_name   = name,					      \
-	.rf_fields = {						  \
+#define DEFINE_REQ_FMT(name, client, client_nr, server, server_nr) {	\
+	.rf_name = name,						\
+	.rf_fields = {							\
 		[RCL_CLIENT] = {					\
 			.nr = client_nr,				\
-			.d  = client				    \
-		},						      \
+			.d = client					\
+		},							\
 		[RCL_SERVER] = {					\
 			.nr = server_nr,				\
-			.d  = server				    \
-		}						       \
-	}							       \
+			.d = server					\
+		}							\
+	}								\
 }
 
 #define DEFINE_REQ_FMT0(name, client, server)				  \
@@ -1769,10 +1769,10 @@ EXPORT_SYMBOL(req_capsule_set);
  * field of a \a pill's \a rc_fmt's RMF's.
  */
 int req_capsule_filled_sizes(struct req_capsule *pill,
-			   enum req_location loc)
+			     enum req_location loc)
 {
 	const struct req_format *fmt = pill->rc_fmt;
-	int		      i;
+	int i;
 
 	LASSERT(fmt != NULL);
 
@@ -1806,8 +1806,8 @@ EXPORT_SYMBOL(req_capsule_filled_sizes);
 int req_capsule_server_pack(struct req_capsule *pill)
 {
 	const struct req_format *fmt;
-	int		      count;
-	int		      rc;
+	int count;
+	int rc;
 
 	LASSERT(pill->rc_loc == RCL_SERVER);
 	fmt = pill->rc_fmt;
@@ -1857,11 +1857,11 @@ swabber_dumper_helper(struct req_capsule *pill,
 		      int offset,
 		      void *value, int len, int dump, void (*swabber)(void *))
 {
-	void    *p;
-	int     i;
-	int     n;
-	int     do_swab;
-	int     inout = loc == RCL_CLIENT;
+	void *p;
+	int i;
+	int n;
+	int do_swab;
+	int inout = loc == RCL_CLIENT;
 
 	swabber = swabber ?: field->rmf_swabber;
 
@@ -1936,10 +1936,10 @@ static void *__req_capsule_get(struct req_capsule *pill,
 			       int dump)
 {
 	const struct req_format *fmt;
-	struct lustre_msg       *msg;
-	void		    *value;
-	int		      len;
-	int		      offset;
+	struct lustre_msg *msg;
+	void *value;
+	int len;
+	int offset;
 
 	void *(*getter)(struct lustre_msg *m, int n, int minlen);
 
@@ -2000,10 +2000,10 @@ static void *__req_capsule_get(struct req_capsule *pill,
  */
 static void __req_capsule_dump(struct req_capsule *pill, enum req_location loc)
 {
-	const struct    req_format *fmt;
-	const struct    req_msg_field *field;
-	int	     len;
-	int	     i;
+	const struct req_format *fmt;
+	const struct req_msg_field *field;
+	int len;
+	int i;
 
 	fmt = pill->rc_fmt;
 
@@ -2350,9 +2350,9 @@ void req_capsule_shrink(struct req_capsule *pill,
 			enum req_location loc)
 {
 	const struct req_format *fmt;
-	struct lustre_msg       *msg;
-	int		      len;
-	int		      offset;
+	struct lustre_msg *msg;
+	int len;
+	int offset;
 
 	fmt = pill->rc_fmt;
 	LASSERT(fmt != NULL);
diff --git a/drivers/staging/lustre/lustre/ptlrpc/llog_client.c b/drivers/staging/lustre/lustre/ptlrpc/llog_client.c
index e9baf5b..1c701e0 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/llog_client.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/llog_client.c
@@ -49,29 +49,29 @@
 #include "../include/lustre_net.h"
 #include <linux/list.h>
 
-#define LLOG_CLIENT_ENTRY(ctxt, imp) do {			     \
-	mutex_lock(&ctxt->loc_mutex);			     \
-	if (ctxt->loc_imp) {					  \
-		imp = class_import_get(ctxt->loc_imp);		\
-	} else {						      \
-		CERROR("ctxt->loc_imp == NULL for context idx %d."    \
-		       "Unable to complete MDS/OSS recovery,"	 \
-		       "but I'll try again next time.  Not fatal.\n", \
-		       ctxt->loc_idx);				\
-		imp = NULL;					   \
-		mutex_unlock(&ctxt->loc_mutex);		   \
-		return (-EINVAL);				     \
-	}							     \
-	mutex_unlock(&ctxt->loc_mutex);			   \
+#define LLOG_CLIENT_ENTRY(ctxt, imp) do {				\
+	mutex_lock(&ctxt->loc_mutex);					\
+	if (ctxt->loc_imp) {						\
+		imp = class_import_get(ctxt->loc_imp);			\
+	} else {							\
+		CERROR("ctxt->loc_imp == NULL for context idx %d."	\
+		       "Unable to complete MDS/OSS recovery,"		\
+		       "but I'll try again next time.  Not fatal.\n",	\
+		       ctxt->loc_idx);					\
+		imp = NULL;						\
+		mutex_unlock(&ctxt->loc_mutex);				\
+		return (-EINVAL);					\
+	}								\
+	mutex_unlock(&ctxt->loc_mutex);					\
 } while (0)
 
-#define LLOG_CLIENT_EXIT(ctxt, imp) do {			      \
-	mutex_lock(&ctxt->loc_mutex);			     \
-	if (ctxt->loc_imp != imp)				     \
-		CWARN("loc_imp has changed from %p to %p\n",	  \
-		       ctxt->loc_imp, imp);			   \
-	class_import_put(imp);					\
-	mutex_unlock(&ctxt->loc_mutex);			   \
+#define LLOG_CLIENT_EXIT(ctxt, imp) do {				\
+	mutex_lock(&ctxt->loc_mutex);					\
+	if (ctxt->loc_imp != imp)					\
+		CWARN("loc_imp has changed from %p to %p\n",		\
+		       ctxt->loc_imp, imp);				\
+	class_import_put(imp);						\
+	mutex_unlock(&ctxt->loc_mutex);					\
 } while (0)
 
 /* This is a callback from the llog_* functions.
@@ -80,11 +80,11 @@ static int llog_client_open(const struct lu_env *env,
 			    struct llog_handle *lgh, struct llog_logid *logid,
 			    char *name, enum llog_open_param open_param)
 {
-	struct obd_import     *imp;
-	struct llogd_body     *body;
-	struct llog_ctxt      *ctxt = lgh->lgh_ctxt;
+	struct obd_import *imp;
+	struct llogd_body *body;
+	struct llog_ctxt *ctxt = lgh->lgh_ctxt;
 	struct ptlrpc_request *req = NULL;
-	int		    rc;
+	int rc;
 
 	LLOG_CLIENT_ENTRY(ctxt, imp);
 
@@ -145,10 +145,10 @@ out:
 static int llog_client_destroy(const struct lu_env *env,
 			       struct llog_handle *loghandle)
 {
-	struct obd_import     *imp;
+	struct obd_import *imp;
 	struct ptlrpc_request *req = NULL;
-	struct llogd_body     *body;
-	int		    rc;
+	struct llogd_body *body;
+	int rc;
 
 	LLOG_CLIENT_ENTRY(loghandle->lgh_ctxt, imp);
 	req = ptlrpc_request_alloc_pack(imp, &RQF_LLOG_ORIGIN_HANDLE_DESTROY,
@@ -182,11 +182,11 @@ static int llog_client_next_block(const struct lu_env *env,
 				  int *cur_idx, int next_idx,
 				  __u64 *cur_offset, void *buf, int len)
 {
-	struct obd_import     *imp;
+	struct obd_import *imp;
 	struct ptlrpc_request *req = NULL;
-	struct llogd_body     *body;
-	void		  *ptr;
-	int		    rc;
+	struct llogd_body *body;
+	void *ptr;
+	int rc;
 
 	LLOG_CLIENT_ENTRY(loghandle->lgh_ctxt, imp);
 	req = ptlrpc_request_alloc_pack(imp, &RQF_LLOG_ORIGIN_HANDLE_NEXT_BLOCK,
@@ -240,11 +240,11 @@ static int llog_client_prev_block(const struct lu_env *env,
 				  struct llog_handle *loghandle,
 				  int prev_idx, void *buf, int len)
 {
-	struct obd_import     *imp;
+	struct obd_import *imp;
 	struct ptlrpc_request *req = NULL;
-	struct llogd_body     *body;
-	void		  *ptr;
-	int		    rc;
+	struct llogd_body *body;
+	void *ptr;
+	int rc;
 
 	LLOG_CLIENT_ENTRY(loghandle->lgh_ctxt, imp);
 	req = ptlrpc_request_alloc_pack(imp, &RQF_LLOG_ORIGIN_HANDLE_PREV_BLOCK,
@@ -292,12 +292,12 @@ err_exit:
 static int llog_client_read_header(const struct lu_env *env,
 				   struct llog_handle *handle)
 {
-	struct obd_import     *imp;
+	struct obd_import *imp;
 	struct ptlrpc_request *req = NULL;
-	struct llogd_body     *body;
-	struct llog_log_hdr   *hdr;
-	struct llog_rec_hdr   *llh_hdr;
-	int		    rc;
+	struct llogd_body *body;
+	struct llog_log_hdr *hdr;
+	struct llog_rec_hdr *llh_hdr;
+	int rc;
 
 	LLOG_CLIENT_ENTRY(handle->lgh_ctxt, imp);
 	req = ptlrpc_request_alloc_pack(imp, &RQF_LLOG_ORIGIN_HANDLE_READ_HEADER,
diff --git a/drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c b/drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c
index 1362160..c04ae50 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c
@@ -261,8 +261,8 @@ ptlrpc_lprocfs_req_history_len_seq_show(struct seq_file *m, void *v)
 {
 	struct ptlrpc_service *svc = m->private;
 	struct ptlrpc_service_part *svcpt;
-	int	total = 0;
-	int	i;
+	int total = 0;
+	int i;
 
 	ptlrpc_service_for_each_part(svcpt, i, svc)
 		total += svcpt->scp_hist_nrqbds;
@@ -277,8 +277,8 @@ ptlrpc_lprocfs_req_history_max_seq_show(struct seq_file *m, void *n)
 {
 	struct ptlrpc_service *svc = m->private;
 	struct ptlrpc_service_part *svcpt;
-	int	total = 0;
-	int	i;
+	int total = 0;
+	int i;
 
 	ptlrpc_service_for_each_part(svcpt, i, svc)
 		total += svc->srv_hist_nrqbds_cpt_max;
@@ -289,13 +289,13 @@ ptlrpc_lprocfs_req_history_max_seq_show(struct seq_file *m, void *n)
 
 static ssize_t
 ptlrpc_lprocfs_req_history_max_seq_write(struct file *file,
-					const char __user *buffer,
-					size_t count, loff_t *off)
+					 const char __user *buffer,
+					 size_t count, loff_t *off)
 {
 	struct ptlrpc_service *svc = ((struct seq_file *)file->private_data)->private;
-	int			    bufpages;
-	int			    val;
-	int			    rc;
+	int bufpages;
+	int val;
+	int rc;
 
 	rc = lprocfs_write_helper(buffer, count, &val);
 	if (rc < 0)
@@ -478,17 +478,17 @@ void nrs_policy_get_info_locked(struct ptlrpc_nrs_policy *policy,
  */
 static int ptlrpc_lprocfs_nrs_seq_show(struct seq_file *m, void *n)
 {
-	struct ptlrpc_service	       *svc = m->private;
-	struct ptlrpc_service_part     *svcpt;
-	struct ptlrpc_nrs	       *nrs;
-	struct ptlrpc_nrs_policy       *policy;
-	struct ptlrpc_nrs_pol_info     *infos;
-	struct ptlrpc_nrs_pol_info	tmp;
-	unsigned			num_pols;
-	unsigned			pol_idx = 0;
-	bool				hp = false;
-	int				i;
-	int				rc = 0;
+	struct ptlrpc_service *svc = m->private;
+	struct ptlrpc_service_part *svcpt;
+	struct ptlrpc_nrs *nrs;
+	struct ptlrpc_nrs_policy *policy;
+	struct ptlrpc_nrs_pol_info *infos;
+	struct ptlrpc_nrs_pol_info tmp;
+	unsigned num_pols;
+	unsigned pol_idx = 0;
+	bool hp = false;
+	int i;
+	int rc = 0;
 
 	/**
 	 * Serialize NRS core lprocfs operations with policy registration/
@@ -638,15 +638,15 @@ unlock:
  * regular and high-priority (if the service has one) NRS head.
  */
 static ssize_t ptlrpc_lprocfs_nrs_seq_write(struct file *file,
-					const char __user *buffer,
-					size_t count, loff_t *off)
+					    const char __user *buffer,
+					    size_t count, loff_t *off)
 {
 	struct ptlrpc_service *svc = ((struct seq_file *)file->private_data)->private;
-	enum ptlrpc_nrs_queue_type	queue = PTLRPC_NRS_QUEUE_BOTH;
-	char			       *cmd;
-	char			       *cmd_copy = NULL;
-	char			       *token;
-	int				rc = 0;
+	enum ptlrpc_nrs_queue_type queue = PTLRPC_NRS_QUEUE_BOTH;
+	char *cmd;
+	char *cmd_copy = NULL;
+	char *token;
+	int rc = 0;
 
 	if (count >= LPROCFS_NRS_WR_MAX_CMD)
 		return -EINVAL;
@@ -729,8 +729,8 @@ ptlrpc_lprocfs_svc_req_history_seek(struct ptlrpc_service_part *svcpt,
 				    struct ptlrpc_srh_iterator *srhi,
 				    __u64 seq)
 {
-	struct list_head		*e;
-	struct ptlrpc_request	*req;
+	struct list_head *e;
+	struct ptlrpc_request *req;
 
 	if (srhi->srhi_req != NULL &&
 	    srhi->srhi_seq > svcpt->scp_hist_seq_culled &&
@@ -860,12 +860,12 @@ static void *
 ptlrpc_lprocfs_svc_req_history_next(struct seq_file *s,
 				    void *iter, loff_t *pos)
 {
-	struct ptlrpc_service		*svc = s->private;
-	struct ptlrpc_srh_iterator	*srhi = iter;
-	struct ptlrpc_service_part	*svcpt;
-	__u64				seq;
-	int				rc;
-	int				i;
+	struct ptlrpc_service *svc = s->private;
+	struct ptlrpc_srh_iterator *srhi = iter;
+	struct ptlrpc_service_part *svcpt;
+	__u64 seq;
+	int rc;
+	int i;
 
 	for (i = srhi->srhi_idx; i < svc->srv_ncpts; i++) {
 		svcpt = svc->srv_parts[i];
@@ -923,11 +923,11 @@ EXPORT_SYMBOL(target_print_req);
 
 static int ptlrpc_lprocfs_svc_req_history_show(struct seq_file *s, void *iter)
 {
-	struct ptlrpc_service		*svc = s->private;
-	struct ptlrpc_srh_iterator	*srhi = iter;
-	struct ptlrpc_service_part	*svcpt;
-	struct ptlrpc_request		*req;
-	int				rc;
+	struct ptlrpc_service *svc = s->private;
+	struct ptlrpc_srh_iterator *srhi = iter;
+	struct ptlrpc_service_part *svcpt;
+	struct ptlrpc_request *req;
+	int rc;
 
 	LASSERT(srhi->srhi_idx < svc->srv_ncpts);
 
@@ -972,8 +972,8 @@ ptlrpc_lprocfs_svc_req_history_open(struct inode *inode, struct file *file)
 		.next  = ptlrpc_lprocfs_svc_req_history_next,
 		.show  = ptlrpc_lprocfs_svc_req_history_show,
 	};
-	struct seq_file       *seqf;
-	int		    rc;
+	struct seq_file *seqf;
+	int rc;
 
 	rc = seq_open(file, &sops);
 	if (rc)
@@ -987,13 +987,13 @@ ptlrpc_lprocfs_svc_req_history_open(struct inode *inode, struct file *file)
 /* See also lprocfs_rd_timeouts */
 static int ptlrpc_lprocfs_timeouts_seq_show(struct seq_file *m, void *n)
 {
-	struct ptlrpc_service		*svc = m->private;
-	struct ptlrpc_service_part	*svcpt;
-	struct dhms			ts;
-	time_t				worstt;
-	unsigned int			cur;
-	unsigned int			worst;
-	int				i;
+	struct ptlrpc_service *svc = m->private;
+	struct ptlrpc_service_part *svcpt;
+	struct dhms ts;
+	time_t worstt;
+	unsigned int cur;
+	unsigned int worst;
+	int i;
 
 	if (AT_OFF) {
 		seq_printf(m, "adaptive timeouts off, using obd_timeout %u\n",
@@ -1215,8 +1215,8 @@ int lprocfs_wr_evict_client(struct file *file, const char __user *buffer,
 			    size_t count, loff_t *off)
 {
 	struct obd_device *obd = ((struct seq_file *)file->private_data)->private;
-	char	      *kbuf;
-	char	      *tmpbuf;
+	char *kbuf;
+	char *tmpbuf;
 
 	kbuf = kzalloc(BUFLEN, GFP_NOFS);
 	if (kbuf == NULL)
@@ -1264,7 +1264,7 @@ int lprocfs_wr_ping(struct file *file, const char __user *buffer,
 {
 	struct obd_device *obd = ((struct seq_file *)file->private_data)->private;
 	struct ptlrpc_request *req;
-	int		    rc;
+	int rc;
 
 	LPROCFS_CLIMP_CHECK(obd);
 	req = ptlrpc_prep_ping(obd->u.cli.cl_import);
diff --git a/drivers/staging/lustre/lustre/ptlrpc/niobuf.c b/drivers/staging/lustre/lustre/ptlrpc/niobuf.c
index 2fa2585..92c746b 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/niobuf.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/niobuf.c
@@ -52,17 +52,17 @@ static int ptl_send_buf(lnet_handle_md_t *mdh, void *base, int len,
 			struct ptlrpc_connection *conn, int portal, __u64 xid,
 			unsigned int offset)
 {
-	int	      rc;
-	lnet_md_t	 md;
+	int rc;
+	lnet_md_t md;
 
 	LASSERT(portal != 0);
 	LASSERT(conn != NULL);
 	CDEBUG(D_INFO, "conn=%p id %s\n", conn, libcfs_id2str(conn->c_peer));
-	md.start     = base;
-	md.length    = len;
+	md.start = base;
+	md.length = len;
 	md.threshold = (ack == LNET_ACK_REQ) ? 2 : 1;
-	md.options   = PTLRPC_MD_OPTIONS;
-	md.user_ptr  = cbid;
+	md.options = PTLRPC_MD_OPTIONS;
+	md.user_ptr = cbid;
 	md.eq_handle = ptlrpc_eq_h;
 
 	if (unlikely(ack == LNET_ACK_REQ &&
@@ -120,8 +120,8 @@ int ptlrpc_register_bulk(struct ptlrpc_request *req)
 	int posted_md;
 	int total_md;
 	__u64 xid;
-	lnet_handle_me_t  me_h;
-	lnet_md_t	 md;
+	lnet_handle_me_t me_h;
+	lnet_md_t md;
 
 	if (OBD_FAIL_CHECK(OBD_FAIL_PTLRPC_BULK_GET_NET))
 		return 0;
@@ -243,9 +243,9 @@ EXPORT_SYMBOL(ptlrpc_register_bulk);
 int ptlrpc_unregister_bulk(struct ptlrpc_request *req, int async)
 {
 	struct ptlrpc_bulk_desc *desc = req->rq_bulk;
-	wait_queue_head_t	     *wq;
-	struct l_wait_info       lwi;
-	int		      rc;
+	wait_queue_head_t *wq;
+	struct l_wait_info lwi;
+	int rc;
 
 	LASSERT(!in_interrupt());     /* might sleep */
 
@@ -301,8 +301,8 @@ EXPORT_SYMBOL(ptlrpc_unregister_bulk);
 
 static void ptlrpc_at_set_reply(struct ptlrpc_request *req, int flags)
 {
-	struct ptlrpc_service_part	*svcpt = req->rq_rqbd->rqbd_svcpt;
-	struct ptlrpc_service		*svc = svcpt->scp_service;
+	struct ptlrpc_service_part *svcpt = req->rq_rqbd->rqbd_svcpt;
+	struct ptlrpc_service *svc = svcpt->scp_service;
 	int service_time = max_t(int, get_seconds() -
 				 req->rq_arrival_time.tv_sec, 1);
 
@@ -353,8 +353,8 @@ static void ptlrpc_at_set_reply(struct ptlrpc_request *req, int flags)
 int ptlrpc_send_reply(struct ptlrpc_request *req, int flags)
 {
 	struct ptlrpc_reply_state *rs = req->rq_reply_state;
-	struct ptlrpc_connection  *conn;
-	int			rc;
+	struct ptlrpc_connection *conn;
+	int rc;
 
 	/* We must already have a reply buffer (only ptlrpc_error() may be
 	 * called without one). The reply generated by sptlrpc layer (e.g.
@@ -491,8 +491,8 @@ int ptl_send_rpc(struct ptlrpc_request *request, int noreply)
 	int rc2;
 	int mpflag = 0;
 	struct ptlrpc_connection *connection;
-	lnet_handle_me_t  reply_me_h;
-	lnet_md_t	 reply_md;
+	lnet_handle_me_t reply_me_h;
+	lnet_md_t reply_md;
 	struct obd_device *obd = request->rq_import->imp_obd;
 
 	if (OBD_FAIL_CHECK(OBD_FAIL_PTLRPC_DROP_RPC))
@@ -594,15 +594,15 @@ int ptl_send_rpc(struct ptlrpc_request *request, int noreply)
 	spin_unlock(&request->rq_lock);
 
 	if (!noreply) {
-		reply_md.start     = request->rq_repbuf;
-		reply_md.length    = request->rq_repbuf_len;
+		reply_md.start = request->rq_repbuf;
+		reply_md.length = request->rq_repbuf_len;
 		/* Allow multiple early replies */
 		reply_md.threshold = LNET_MD_THRESH_INF;
 		/* Manage remote for early replies */
-		reply_md.options   = PTLRPC_MD_OPTIONS | LNET_MD_OP_PUT |
+		reply_md.options = PTLRPC_MD_OPTIONS | LNET_MD_OP_PUT |
 			LNET_MD_MANAGE_REMOTE |
 			LNET_MD_TRUNCATE; /* allow to make EOVERFLOW error */;
-		reply_md.user_ptr  = &request->rq_reply_cbid;
+		reply_md.user_ptr = &request->rq_reply_cbid;
 		reply_md.eq_handle = ptlrpc_eq_h;
 
 		/* We must see the unlink callback to unset rq_reply_unlink,
@@ -682,11 +682,11 @@ EXPORT_SYMBOL(ptl_send_rpc);
  */
 int ptlrpc_register_rqbd(struct ptlrpc_request_buffer_desc *rqbd)
 {
-	struct ptlrpc_service	  *service = rqbd->rqbd_svcpt->scp_service;
-	static lnet_process_id_t  match_id = {LNET_NID_ANY, LNET_PID_ANY};
-	int			  rc;
-	lnet_md_t		 md;
-	lnet_handle_me_t	  me_h;
+	struct ptlrpc_service *service = rqbd->rqbd_svcpt->scp_service;
+	static lnet_process_id_t match_id = {LNET_NID_ANY, LNET_PID_ANY};
+	int rc;
+	lnet_md_t md;
+	lnet_handle_me_t me_h;
 
 	CDEBUG(D_NET, "LNetMEAttach: portal %d\n",
 	       service->srv_req_portal);
@@ -709,12 +709,12 @@ int ptlrpc_register_rqbd(struct ptlrpc_request_buffer_desc *rqbd)
 	LASSERT(rqbd->rqbd_refcount == 0);
 	rqbd->rqbd_refcount = 1;
 
-	md.start     = rqbd->rqbd_buffer;
-	md.length    = service->srv_buf_size;
-	md.max_size  = service->srv_max_req_size;
+	md.start = rqbd->rqbd_buffer;
+	md.length = service->srv_buf_size;
+	md.max_size = service->srv_max_req_size;
 	md.threshold = LNET_MD_THRESH_INF;
-	md.options   = PTLRPC_MD_OPTIONS | LNET_MD_OP_PUT | LNET_MD_MAX_SIZE;
-	md.user_ptr  = &rqbd->rqbd_cbid;
+	md.options = PTLRPC_MD_OPTIONS | LNET_MD_OP_PUT | LNET_MD_MAX_SIZE;
+	md.user_ptr = &rqbd->rqbd_cbid;
 	md.eq_handle = ptlrpc_eq_h;
 
 	rc = LNetMDAttach(me_h, md, LNET_UNLINK, &rqbd->rqbd_md_h);
diff --git a/drivers/staging/lustre/lustre/ptlrpc/nrs.c b/drivers/staging/lustre/lustre/ptlrpc/nrs.c
index d38a1af..9516aca 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/nrs.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/nrs.c
@@ -188,8 +188,8 @@ static void nrs_policy_stop_primary(struct ptlrpc_nrs *nrs)
  */
 static int nrs_policy_start_locked(struct ptlrpc_nrs_policy *policy)
 {
-	struct ptlrpc_nrs      *nrs = policy->pol_nrs;
-	int			rc = 0;
+	struct ptlrpc_nrs *nrs = policy->pol_nrs;
+	int rc = 0;
 
 	/**
 	 * Don't allow multiple starting which is too complex, and has no real
@@ -377,15 +377,15 @@ static void nrs_resource_put(struct ptlrpc_nrs_resource *res)
  */
 static
 struct ptlrpc_nrs_resource *nrs_resource_get(struct ptlrpc_nrs_policy *policy,
-					      struct ptlrpc_nrs_request *nrq,
-					      bool moving_req)
+					     struct ptlrpc_nrs_request *nrq,
+					     bool moving_req)
 {
 	/**
 	 * Set to NULL to traverse the resource hierarchy from the top.
 	 */
 	struct ptlrpc_nrs_resource *res = NULL;
 	struct ptlrpc_nrs_resource *tmp = NULL;
-	int			    rc;
+	int rc;
 
 	while (1) {
 		rc = policy->pol_desc->pd_ops->op_res_get(policy, nrq, res,
@@ -432,8 +432,8 @@ static void nrs_resource_get_safe(struct ptlrpc_nrs *nrs,
 				  struct ptlrpc_nrs_resource **resp,
 				  bool moving_req)
 {
-	struct ptlrpc_nrs_policy   *primary = NULL;
-	struct ptlrpc_nrs_policy   *fallback = NULL;
+	struct ptlrpc_nrs_policy *primary = NULL;
+	struct ptlrpc_nrs_policy *fallback = NULL;
 
 	memset(resp, 0, sizeof(resp[0]) * NRS_RES_MAX);
 
@@ -484,8 +484,8 @@ static void nrs_resource_get_safe(struct ptlrpc_nrs *nrs,
 static void nrs_resource_put_safe(struct ptlrpc_nrs_resource **resp)
 {
 	struct ptlrpc_nrs_policy *pols[NRS_RES_MAX];
-	struct ptlrpc_nrs	 *nrs = NULL;
-	int			  i;
+	struct ptlrpc_nrs *nrs = NULL;
+	int i;
 
 	for (i = 0; i < NRS_RES_MAX; i++) {
 		if (resp[i] != NULL) {
@@ -530,7 +530,7 @@ static void nrs_resource_put_safe(struct ptlrpc_nrs_resource **resp)
  */
 static inline
 struct ptlrpc_nrs_request *nrs_request_get(struct ptlrpc_nrs_policy *policy,
-					    bool peek, bool force)
+					   bool peek, bool force)
 {
 	struct ptlrpc_nrs_request *nrq;
 
@@ -556,8 +556,8 @@ struct ptlrpc_nrs_request *nrs_request_get(struct ptlrpc_nrs_policy *policy,
 static inline void nrs_request_enqueue(struct ptlrpc_nrs_request *nrq)
 {
 	struct ptlrpc_nrs_policy *policy;
-	int			  rc;
-	int			  i;
+	int rc;
+	int i;
 
 	/**
 	 * Try in descending order, because the primary policy (if any) is
@@ -628,8 +628,8 @@ static inline void nrs_request_stop(struct ptlrpc_nrs_request *nrq)
 static int nrs_policy_ctl(struct ptlrpc_nrs *nrs, char *name,
 			  enum ptlrpc_nrs_ctl opc, void *arg)
 {
-	struct ptlrpc_nrs_policy       *policy;
-	int				rc = 0;
+	struct ptlrpc_nrs_policy *policy;
+	int rc = 0;
 
 	spin_lock(&nrs->nrs_lock);
 
@@ -733,10 +733,10 @@ static int nrs_policy_unregister(struct ptlrpc_nrs *nrs, char *name)
 static int nrs_policy_register(struct ptlrpc_nrs *nrs,
 			       struct ptlrpc_nrs_pol_desc *desc)
 {
-	struct ptlrpc_nrs_policy       *policy;
-	struct ptlrpc_nrs_policy       *tmp;
-	struct ptlrpc_service_part     *svcpt = nrs->nrs_svcpt;
-	int				rc;
+	struct ptlrpc_nrs_policy *policy;
+	struct ptlrpc_nrs_policy *tmp;
+	struct ptlrpc_service_part *svcpt = nrs->nrs_svcpt;
+	int rc;
 
 	LASSERT(svcpt != NULL);
 	LASSERT(desc->pd_ops != NULL);
@@ -752,10 +752,10 @@ static int nrs_policy_register(struct ptlrpc_nrs *nrs,
 	if (policy == NULL)
 		return -ENOMEM;
 
-	policy->pol_nrs     = nrs;
-	policy->pol_desc    = desc;
-	policy->pol_state   = NRS_POL_STATE_STOPPED;
-	policy->pol_flags   = desc->pd_flags;
+	policy->pol_nrs = nrs;
+	policy->pol_desc = desc;
+	policy->pol_state = NRS_POL_STATE_STOPPED;
+	policy->pol_flags = desc->pd_flags;
 
 	INIT_LIST_HEAD(&policy->pol_list);
 	INIT_LIST_HEAD(&policy->pol_list_queued);
@@ -804,7 +804,7 @@ static int nrs_policy_register(struct ptlrpc_nrs *nrs,
  */
 static void ptlrpc_nrs_req_add_nolock(struct ptlrpc_request *req)
 {
-	struct ptlrpc_nrs_policy       *policy;
+	struct ptlrpc_nrs_policy *policy;
 
 	LASSERT(req->rq_nrq.nr_initialized);
 	LASSERT(!req->rq_nrq.nr_enqueued);
@@ -829,7 +829,7 @@ static void ptlrpc_nrs_req_add_nolock(struct ptlrpc_request *req)
  */
 static void ptlrpc_nrs_hpreq_add_nolock(struct ptlrpc_request *req)
 {
-	int	opc = lustre_msg_get_opc(req->rq_reqmsg);
+	int opc = lustre_msg_get_opc(req->rq_reqmsg);
 
 	spin_lock(&req->rq_lock);
 	req->rq_hp = 1;
@@ -872,9 +872,9 @@ static int nrs_register_policies_locked(struct ptlrpc_nrs *nrs)
 {
 	struct ptlrpc_nrs_pol_desc *desc;
 	/* for convenience */
-	struct ptlrpc_service_part	 *svcpt = nrs->nrs_svcpt;
-	struct ptlrpc_service		 *svc = svcpt->scp_service;
-	int				  rc = -EINVAL;
+	struct ptlrpc_service_part *svcpt = nrs->nrs_svcpt;
+	struct ptlrpc_service *svc = svcpt->scp_service;
+	int rc = -EINVAL;
 
 	LASSERT(mutex_is_locked(&nrs_core.nrs_mutex));
 
@@ -912,7 +912,7 @@ static int nrs_register_policies_locked(struct ptlrpc_nrs *nrs)
 static int nrs_svcpt_setup_locked0(struct ptlrpc_nrs *nrs,
 				   struct ptlrpc_service_part *svcpt)
 {
-	enum ptlrpc_nrs_queue_type	queue;
+	enum ptlrpc_nrs_queue_type queue;
 
 	LASSERT(mutex_is_locked(&nrs_core.nrs_mutex));
 
@@ -943,8 +943,8 @@ static int nrs_svcpt_setup_locked0(struct ptlrpc_nrs *nrs,
  */
 static int nrs_svcpt_setup_locked(struct ptlrpc_service_part *svcpt)
 {
-	struct ptlrpc_nrs	       *nrs;
-	int				rc;
+	struct ptlrpc_nrs *nrs;
+	int rc;
 
 	LASSERT(mutex_is_locked(&nrs_core.nrs_mutex));
 
@@ -988,11 +988,11 @@ out:
  */
 static void nrs_svcpt_cleanup_locked(struct ptlrpc_service_part *svcpt)
 {
-	struct ptlrpc_nrs	       *nrs;
-	struct ptlrpc_nrs_policy       *policy;
-	struct ptlrpc_nrs_policy       *tmp;
-	int				rc;
-	bool				hp = false;
+	struct ptlrpc_nrs *nrs;
+	struct ptlrpc_nrs_policy *policy;
+	struct ptlrpc_nrs_policy *tmp;
+	int rc;
+	bool hp = false;
 
 	LASSERT(mutex_is_locked(&nrs_core.nrs_mutex));
 
@@ -1028,7 +1028,7 @@ again:
  */
 static struct ptlrpc_nrs_pol_desc *nrs_policy_find_desc_locked(const char *name)
 {
-	struct ptlrpc_nrs_pol_desc     *tmp;
+	struct ptlrpc_nrs_pol_desc *tmp;
 
 	list_for_each_entry(tmp, &nrs_core.nrs_policies, pd_list) {
 		if (strncmp(tmp->pd_name, name, NRS_POL_NAME_MAX) == 0)
@@ -1051,11 +1051,11 @@ static struct ptlrpc_nrs_pol_desc *nrs_policy_find_desc_locked(const char *name)
  */
 static int nrs_policy_unregister_locked(struct ptlrpc_nrs_pol_desc *desc)
 {
-	struct ptlrpc_nrs	       *nrs;
-	struct ptlrpc_service	       *svc;
-	struct ptlrpc_service_part     *svcpt;
-	int				i;
-	int				rc = 0;
+	struct ptlrpc_nrs *nrs;
+	struct ptlrpc_service *svc;
+	struct ptlrpc_service_part *svcpt;
+	int i;
+	int rc = 0;
 
 	LASSERT(mutex_is_locked(&nrs_core.nrs_mutex));
 	LASSERT(mutex_is_locked(&ptlrpc_all_services_mutex));
@@ -1115,9 +1115,9 @@ again:
  */
 int ptlrpc_nrs_policy_register(struct ptlrpc_nrs_pol_conf *conf)
 {
-	struct ptlrpc_service	       *svc;
-	struct ptlrpc_nrs_pol_desc     *desc;
-	int				rc = 0;
+	struct ptlrpc_service *svc;
+	struct ptlrpc_nrs_pol_desc *desc;
+	int rc = 0;
 
 	LASSERT(conf != NULL);
 	LASSERT(conf->nc_ops != NULL);
@@ -1162,12 +1162,12 @@ int ptlrpc_nrs_policy_register(struct ptlrpc_nrs_pol_conf *conf)
 	}
 
 	strncpy(desc->pd_name, conf->nc_name, NRS_POL_NAME_MAX);
-	desc->pd_ops		 = conf->nc_ops;
-	desc->pd_compat		 = conf->nc_compat;
+	desc->pd_ops = conf->nc_ops;
+	desc->pd_compat = conf->nc_compat;
 	desc->pd_compat_svc_name = conf->nc_compat_svc_name;
 	if ((conf->nc_flags & PTLRPC_NRS_FL_REG_EXTERN) != 0)
-		desc->pd_owner	 = conf->nc_owner;
-	desc->pd_flags		 = conf->nc_flags;
+		desc->pd_owner = conf->nc_owner;
+	desc->pd_flags = conf->nc_flags;
 	atomic_set(&desc->pd_refs, 0);
 
 	/**
@@ -1187,17 +1187,17 @@ int ptlrpc_nrs_policy_register(struct ptlrpc_nrs_pol_conf *conf)
 	mutex_lock(&ptlrpc_all_services_mutex);
 
 	list_for_each_entry(svc, &ptlrpc_all_services, srv_list) {
-		struct ptlrpc_service_part     *svcpt;
-		int				i;
-		int				rc2;
+		struct ptlrpc_service_part *svcpt;
+		int i;
+		int rc2;
 
 		if (!nrs_policy_compatible(svc, desc) ||
 		    unlikely(svc->srv_is_stopping))
 			continue;
 
 		ptlrpc_service_for_each_part(svcpt, i, svc) {
-			struct ptlrpc_nrs      *nrs;
-			bool			hp = false;
+			struct ptlrpc_nrs *nrs;
+			bool hp = false;
 again:
 			nrs = nrs_svcpt2nrs(svcpt, hp);
 			rc = nrs_policy_register(nrs, desc);
@@ -1267,8 +1267,8 @@ EXPORT_SYMBOL(ptlrpc_nrs_policy_register);
  */
 int ptlrpc_nrs_policy_unregister(struct ptlrpc_nrs_pol_conf *conf)
 {
-	struct ptlrpc_nrs_pol_desc	*desc;
-	int				 rc;
+	struct ptlrpc_nrs_pol_desc *desc;
+	int rc;
 
 	LASSERT(conf != NULL);
 
@@ -1331,10 +1331,10 @@ EXPORT_SYMBOL(ptlrpc_nrs_policy_unregister);
  */
 int ptlrpc_service_nrs_setup(struct ptlrpc_service *svc)
 {
-	struct ptlrpc_service_part	       *svcpt;
-	const struct ptlrpc_nrs_pol_desc       *desc;
-	int					i;
-	int					rc = 0;
+	struct ptlrpc_service_part *svcpt;
+	const struct ptlrpc_nrs_pol_desc *desc;
+	int i;
+	int rc = 0;
 
 	mutex_lock(&nrs_core.nrs_mutex);
 
@@ -1376,9 +1376,9 @@ failed:
  */
 void ptlrpc_service_nrs_cleanup(struct ptlrpc_service *svc)
 {
-	struct ptlrpc_service_part	     *svcpt;
-	const struct ptlrpc_nrs_pol_desc     *desc;
-	int				      i;
+	struct ptlrpc_service_part *svcpt;
+	const struct ptlrpc_nrs_pol_desc *desc;
+	int i;
 
 	mutex_lock(&nrs_core.nrs_mutex);
 
@@ -1417,7 +1417,7 @@ void ptlrpc_service_nrs_cleanup(struct ptlrpc_service *svc)
 void ptlrpc_nrs_req_initialize(struct ptlrpc_service_part *svcpt,
 			       struct ptlrpc_request *req, bool hp)
 {
-	struct ptlrpc_nrs	*nrs = nrs_svcpt2nrs(svcpt, hp);
+	struct ptlrpc_nrs *nrs = nrs_svcpt2nrs(svcpt, hp);
 
 	memset(&req->rq_nrq, 0, sizeof(req->rq_nrq));
 	nrs_resource_get_safe(nrs, &req->rq_nrq, req->rq_nrq.nr_res_ptrs,
@@ -1525,8 +1525,8 @@ struct ptlrpc_request *
 ptlrpc_nrs_req_get_nolock0(struct ptlrpc_service_part *svcpt, bool hp,
 			   bool peek, bool force)
 {
-	struct ptlrpc_nrs	  *nrs = nrs_svcpt2nrs(svcpt, hp);
-	struct ptlrpc_nrs_policy  *policy;
+	struct ptlrpc_nrs *nrs = nrs_svcpt2nrs(svcpt, hp);
+	struct ptlrpc_nrs_policy *policy;
 	struct ptlrpc_nrs_request *nrq;
 
 	/**
@@ -1596,10 +1596,10 @@ bool ptlrpc_nrs_req_pending_nolock(struct ptlrpc_service_part *svcpt, bool hp)
  */
 void ptlrpc_nrs_req_hp_move(struct ptlrpc_request *req)
 {
-	struct ptlrpc_service_part	*svcpt = req->rq_rqbd->rqbd_svcpt;
-	struct ptlrpc_nrs_request	*nrq = &req->rq_nrq;
-	struct ptlrpc_nrs_resource	*res1[NRS_RES_MAX];
-	struct ptlrpc_nrs_resource	*res2[NRS_RES_MAX];
+	struct ptlrpc_service_part *svcpt = req->rq_rqbd->rqbd_svcpt;
+	struct ptlrpc_nrs_request *nrq = &req->rq_nrq;
+	struct ptlrpc_nrs_resource *res1[NRS_RES_MAX];
+	struct ptlrpc_nrs_resource *res2[NRS_RES_MAX];
 
 	/**
 	 * Obtain the high-priority NRS head resources.
@@ -1661,9 +1661,9 @@ int ptlrpc_nrs_policy_control(const struct ptlrpc_service *svc,
 			      enum ptlrpc_nrs_queue_type queue, char *name,
 			      enum ptlrpc_nrs_ctl opc, bool single, void *arg)
 {
-	struct ptlrpc_service_part     *svcpt;
-	int				i;
-	int				rc = 0;
+	struct ptlrpc_service_part *svcpt;
+	int i;
+	int rc = 0;
 
 	LASSERT(opc != PTLRPC_NRS_CTL_INVALID);
 
@@ -1711,7 +1711,7 @@ extern struct ptlrpc_nrs_pol_conf nrs_conf_fifo;
  */
 int ptlrpc_nrs_init(void)
 {
-	int	rc;
+	int rc;
 
 	mutex_init(&nrs_core.nrs_mutex);
 	INIT_LIST_HEAD(&nrs_core.nrs_policies);
diff --git a/drivers/staging/lustre/lustre/ptlrpc/nrs_fifo.c b/drivers/staging/lustre/lustre/ptlrpc/nrs_fifo.c
index 6a61c85..8e21f0c 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/nrs_fifo.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/nrs_fifo.c
@@ -160,9 +160,9 @@ static int nrs_fifo_res_get(struct ptlrpc_nrs_policy *policy,
  */
 static
 struct ptlrpc_nrs_request *nrs_fifo_req_get(struct ptlrpc_nrs_policy *policy,
-					     bool peek, bool force)
+					    bool peek, bool force)
 {
-	struct nrs_fifo_head	  *head = policy->pol_private;
+	struct nrs_fifo_head *head = policy->pol_private;
 	struct ptlrpc_nrs_request *nrq;
 
 	nrq = unlikely(list_empty(&head->fh_list)) ? NULL :
diff --git a/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c b/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
index b51af9b..2787bfd 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
@@ -279,8 +279,8 @@ lustre_get_emerg_rs(struct ptlrpc_service_part *svcpt)
 
 	/* See if we have anything in a pool, and wait if nothing */
 	while (list_empty(&svcpt->scp_rep_idle)) {
-		struct l_wait_info	lwi;
-		int			rc;
+		struct l_wait_info lwi;
+		int rc;
 
 		spin_unlock(&svcpt->scp_rep_lock);
 		/* If we cannot get anything for some long time, we better
@@ -321,7 +321,7 @@ int lustre_pack_reply_v2(struct ptlrpc_request *req, int count,
 			 __u32 *lens, char **bufs, int flags)
 {
 	struct ptlrpc_reply_state *rs;
-	int			msg_len, rc;
+	int msg_len, rc;
 
 	LASSERT(req->rq_reply_state == NULL);
 
@@ -440,8 +440,8 @@ EXPORT_SYMBOL(lustre_msg_buf);
 int lustre_shrink_msg_v2(struct lustre_msg_v2 *msg, int segment,
 			 unsigned int newlen, int move_data)
 {
-	char   *tail = NULL, *newpos;
-	int     tail_len = 0, n;
+	char *tail = NULL, *newpos;
+	int tail_len = 0, n;
 
 	LASSERT(msg);
 	LASSERT(msg->lm_bufcount > segment);
@@ -1577,8 +1577,8 @@ int do_set_info_async(struct obd_import *imp,
 		      struct ptlrpc_request_set *set)
 {
 	struct ptlrpc_request *req;
-	char		  *tmp;
-	int		    rc;
+	char *tmp;
+	int rc;
 
 	req = ptlrpc_request_alloc(imp, &RQF_OBD_SET_INFO);
 	if (req == NULL)
@@ -1688,7 +1688,7 @@ void lustre_swab_connect(struct obd_connect_data *ocd)
 	CLASSERT(offsetof(typeof(*ocd), paddingF) != 0);
 }
 
-void lustre_swab_obdo(struct obdo  *o)
+void lustre_swab_obdo(struct obdo *o)
 {
 	__swab64s(&o->o_valid);
 	lustre_swab_ost_id(&o->o_oi);
@@ -2179,7 +2179,7 @@ EXPORT_SYMBOL(lustre_swab_lov_user_md_objects);
 
 void lustre_swab_ldlm_res_id(struct ldlm_res_id *id)
 {
-	int  i;
+	int i;
 
 	for (i = 0; i < RES_NAME_SIZE; i++)
 		__swab64s(&id->name[i]);
diff --git a/drivers/staging/lustre/lustre/ptlrpc/pinger.c b/drivers/staging/lustre/lustre/ptlrpc/pinger.c
index 9fc8156..61e33be 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/pinger.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/pinger.c
@@ -546,8 +546,8 @@ void ptlrpc_pinger_wake_up(void)
 #define PET_TERMINATE 2
 
 static int pet_refcount;
-static int	       pet_state;
-static wait_queue_head_t       pet_waitq;
+static int pet_state;
+static wait_queue_head_t pet_waitq;
 static LIST_HEAD(pet_list);
 static DEFINE_SPINLOCK(pet_lock);
 
diff --git a/drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c b/drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c
index 5ba3e6e..e591cff 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c
@@ -68,9 +68,9 @@
 #include "ptlrpc_internal.h"
 
 struct ptlrpcd {
-	int		pd_size;
-	int		pd_index;
-	int		pd_nthreads;
+	int pd_size;
+	int pd_index;
+	int pd_nthreads;
 	struct ptlrpcd_ctl pd_thread_rcv;
 	struct ptlrpcd_ctl pd_threads[0];
 };
diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec.c b/drivers/staging/lustre/lustre/ptlrpc/sec.c
index bcfd0b0..8798fab 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/sec.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/sec.c
@@ -113,10 +113,10 @@ static
 struct ptlrpc_sec_policy *sptlrpc_wireflavor2policy(__u32 flavor)
 {
 	static DEFINE_MUTEX(load_mutex);
-	static atomic_t       loaded = ATOMIC_INIT(0);
+	static atomic_t loaded = ATOMIC_INIT(0);
 	struct ptlrpc_sec_policy *policy;
-	__u16		     number = SPTLRPC_FLVR_POLICY(flavor);
-	__u16		     flag = 0;
+	__u16 number = SPTLRPC_FLVR_POLICY(flavor);
+	__u16 flag = 0;
 
 	if (number >= SPTLRPC_POLICY_MAX)
 		return NULL;
@@ -339,7 +339,7 @@ int sptlrpc_cli_ctx_display(struct ptlrpc_cli_ctx *ctx, char *buf, int bufsize)
 
 static int import_sec_check_expire(struct obd_import *imp)
 {
-	int     adapt = 0;
+	int adapt = 0;
 
 	spin_lock(&imp->imp_lock);
 	if (imp->imp_sec_expire &&
@@ -359,7 +359,7 @@ static int import_sec_check_expire(struct obd_import *imp)
 static int import_sec_validate_get(struct obd_import *imp,
 				   struct ptlrpc_sec **sec)
 {
-	int     rc;
+	int rc;
 
 	if (unlikely(imp->imp_sec_expire)) {
 		rc = import_sec_check_expire(imp);
@@ -447,10 +447,10 @@ int sptlrpc_req_ctx_switch(struct ptlrpc_request *req,
 			   struct ptlrpc_cli_ctx *oldctx,
 			   struct ptlrpc_cli_ctx *newctx)
 {
-	struct sptlrpc_flavor   old_flvr;
-	char		   *reqmsg = NULL; /* to workaround old gcc */
-	int		     reqmsg_size;
-	int		     rc = 0;
+	struct sptlrpc_flavor old_flvr;
+	char *reqmsg = NULL; /* to workaround old gcc */
+	int reqmsg_size;
+	int rc = 0;
 
 	LASSERT(req->rq_reqmsg);
 	LASSERT(req->rq_reqlen);
@@ -514,7 +514,7 @@ int sptlrpc_req_replace_dead_ctx(struct ptlrpc_request *req)
 {
 	struct ptlrpc_cli_ctx *oldctx = req->rq_cli_ctx;
 	struct ptlrpc_cli_ctx *newctx;
-	int		    rc;
+	int rc;
 
 	LASSERT(oldctx);
 
@@ -629,10 +629,10 @@ void req_off_ctx_list(struct ptlrpc_request *req, struct ptlrpc_cli_ctx *ctx)
  */
 int sptlrpc_req_refresh_ctx(struct ptlrpc_request *req, long timeout)
 {
-	struct ptlrpc_cli_ctx  *ctx = req->rq_cli_ctx;
-	struct ptlrpc_sec      *sec;
-	struct l_wait_info      lwi;
-	int		     rc;
+	struct ptlrpc_cli_ctx *ctx = req->rq_cli_ctx;
+	struct ptlrpc_sec *sec;
+	struct l_wait_info lwi;
+	int rc;
 
 	LASSERT(ctx);
 
@@ -878,7 +878,7 @@ void sptlrpc_request_out_callback(struct ptlrpc_request *req)
  */
 int sptlrpc_import_check_ctx(struct obd_import *imp)
 {
-	struct ptlrpc_sec     *sec;
+	struct ptlrpc_sec *sec;
 	struct ptlrpc_cli_ctx *ctx;
 	struct ptlrpc_request *req = NULL;
 	int rc;
@@ -974,7 +974,7 @@ int sptlrpc_cli_wrap_request(struct ptlrpc_request *req)
 static int do_cli_unwrap_reply(struct ptlrpc_request *req)
 {
 	struct ptlrpc_cli_ctx *ctx = req->rq_cli_ctx;
-	int		    rc;
+	int rc;
 
 	LASSERT(ctx);
 	LASSERT(ctx->cc_sec);
@@ -1082,10 +1082,10 @@ int sptlrpc_cli_unwrap_reply(struct ptlrpc_request *req)
 int sptlrpc_cli_unwrap_early_reply(struct ptlrpc_request *req,
 				   struct ptlrpc_request **req_ret)
 {
-	struct ptlrpc_request  *early_req;
-	char		   *early_buf;
-	int		     early_bufsz, early_size;
-	int		     rc;
+	struct ptlrpc_request *early_req;
+	char *early_buf;
+	int early_bufsz, early_size;
+	int rc;
 
 	early_req = ptlrpc_request_cache_alloc(GFP_NOFS);
 	if (early_req == NULL)
@@ -1273,13 +1273,13 @@ EXPORT_SYMBOL(sptlrpc_sec_put);
  */
 static
 struct ptlrpc_sec *sptlrpc_sec_create(struct obd_import *imp,
-				       struct ptlrpc_svc_ctx *svc_ctx,
-				       struct sptlrpc_flavor *sf,
-				       enum lustre_sec_part sp)
+				      struct ptlrpc_svc_ctx *svc_ctx,
+				      struct sptlrpc_flavor *sf,
+				      enum lustre_sec_part sp)
 {
 	struct ptlrpc_sec_policy *policy;
-	struct ptlrpc_sec	*sec;
-	char		      str[32];
+	struct ptlrpc_sec *sec;
+	char str[32];
 
 	if (svc_ctx) {
 		LASSERT(imp->imp_dlm_fake == 1);
@@ -1369,7 +1369,7 @@ static void sptlrpc_import_sec_adapt_inplace(struct obd_import *imp,
 					     struct ptlrpc_sec *sec,
 					     struct sptlrpc_flavor *sf)
 {
-	char    str1[32], str2[32];
+	char str1[32], str2[32];
 
 	if (sec->ps_flvr.sf_flags != sf->sf_flags)
 		CDEBUG(D_SEC, "changing sec flags: %s -> %s\n",
@@ -1394,12 +1394,12 @@ int sptlrpc_import_sec_adapt(struct obd_import *imp,
 			     struct ptlrpc_svc_ctx *svc_ctx,
 			     struct sptlrpc_flavor *flvr)
 {
-	struct ptlrpc_connection   *conn;
-	struct sptlrpc_flavor       sf;
-	struct ptlrpc_sec	  *sec, *newsec;
-	enum lustre_sec_part	sp;
-	char			str[24];
-	int			 rc = 0;
+	struct ptlrpc_connection *conn;
+	struct sptlrpc_flavor sf;
+	struct ptlrpc_sec *sec, *newsec;
+	enum lustre_sec_part sp;
+	char str[24];
+	int rc = 0;
 
 	might_sleep();
 
@@ -1436,7 +1436,7 @@ int sptlrpc_import_sec_adapt(struct obd_import *imp,
 
 	sec = sptlrpc_import_sec_ref(imp);
 	if (sec) {
-		char    str2[24];
+		char str2[24];
 
 		if (flavor_equal(&sf, &sec->ps_flvr))
 			goto out;
@@ -1585,8 +1585,8 @@ void sptlrpc_cli_free_reqbuf(struct ptlrpc_request *req)
 void _sptlrpc_enlarge_msg_inplace(struct lustre_msg *msg,
 				  int segment, int newsize)
 {
-	void   *src, *dst;
-	int     oldsize, oldmsg_size, movesize;
+	void *src, *dst;
+	int oldsize, oldmsg_size, movesize;
 
 	LASSERT(segment < msg->lm_bufcount);
 	LASSERT(msg->lm_buflens[segment] <= newsize);
@@ -1635,9 +1635,9 @@ EXPORT_SYMBOL(_sptlrpc_enlarge_msg_inplace);
 int sptlrpc_cli_enlarge_reqbuf(struct ptlrpc_request *req,
 			       int segment, int newsize)
 {
-	struct ptlrpc_cli_ctx    *ctx = req->rq_cli_ctx;
-	struct ptlrpc_sec_cops   *cops;
-	struct lustre_msg	*msg = req->rq_reqmsg;
+	struct ptlrpc_cli_ctx *ctx = req->rq_cli_ctx;
+	struct ptlrpc_sec_cops *cops;
+	struct lustre_msg *msg = req->rq_reqmsg;
 
 	LASSERT(ctx);
 	LASSERT(msg);
@@ -1748,7 +1748,7 @@ static int flavor_allowed(struct sptlrpc_flavor *exp,
 int sptlrpc_target_export_check(struct obd_export *exp,
 				struct ptlrpc_request *req)
 {
-	struct sptlrpc_flavor   flavor;
+	struct sptlrpc_flavor flavor;
 
 	if (exp == NULL)
 		return 0;
@@ -1926,8 +1926,8 @@ EXPORT_SYMBOL(sptlrpc_target_export_check);
 void sptlrpc_target_update_exp_flavor(struct obd_device *obd,
 				      struct sptlrpc_rule_set *rset)
 {
-	struct obd_export       *exp;
-	struct sptlrpc_flavor    new_flvr;
+	struct obd_export *exp;
+	struct sptlrpc_flavor new_flvr;
 
 	LASSERT(obd);
 
@@ -2019,8 +2019,8 @@ static int sptlrpc_svc_check_from(struct ptlrpc_request *req, int svc_rc)
 int sptlrpc_svc_unwrap_request(struct ptlrpc_request *req)
 {
 	struct ptlrpc_sec_policy *policy;
-	struct lustre_msg	*msg = req->rq_reqbuf;
-	int		       rc;
+	struct lustre_msg *msg = req->rq_reqbuf;
+	int rc;
 
 	LASSERT(msg);
 	LASSERT(req->rq_reqmsg == NULL);
@@ -2231,8 +2231,8 @@ int sptlrpc_cli_unwrap_bulk_read(struct ptlrpc_request *req,
 				 struct ptlrpc_bulk_desc *desc,
 				 int nob)
 {
-	struct ptlrpc_cli_ctx  *ctx;
-	int		     rc;
+	struct ptlrpc_cli_ctx *ctx;
+	int rc;
 
 	LASSERT(req->rq_bulk_read && !req->rq_bulk_write);
 
@@ -2256,8 +2256,8 @@ EXPORT_SYMBOL(sptlrpc_cli_unwrap_bulk_read);
 int sptlrpc_cli_unwrap_bulk_write(struct ptlrpc_request *req,
 				  struct ptlrpc_bulk_desc *desc)
 {
-	struct ptlrpc_cli_ctx  *ctx;
-	int		     rc;
+	struct ptlrpc_cli_ctx *ctx;
+	int rc;
 
 	LASSERT(!req->rq_bulk_read && req->rq_bulk_write);
 
@@ -2329,7 +2329,7 @@ EXPORT_SYMBOL(sptlrpc_pack_user_desc);
 int sptlrpc_unpack_user_desc(struct lustre_msg *msg, int offset, int swabbed)
 {
 	struct ptlrpc_user_desc *pud;
-	int		      i;
+	int i;
 
 	pud = lustre_msg_buf(msg, offset, sizeof(*pud));
 	if (!pud)
diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c b/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c
index 97edc91..ea35ca5 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c
@@ -62,7 +62,7 @@
 #define POINTERS_PER_PAGE	(PAGE_CACHE_SIZE / sizeof(void *))
 #define PAGES_PER_POOL		(POINTERS_PER_PAGE)
 
-#define IDLE_IDX_MAX	    (100)
+#define IDLE_IDX_MAX	 (100)
 #define IDLE_IDX_WEIGHT	 (3)
 
 #define CACHE_QUIESCENT_PERIOD  (20)
@@ -173,8 +173,8 @@ int sptlrpc_proc_enc_pool_seq_show(struct seq_file *m, void *v)
 
 static void enc_pools_release_free_pages(long npages)
 {
-	int     p_idx, g_idx;
-	int     p_idx_max1, p_idx_max2;
+	int p_idx, g_idx;
+	int p_idx_max1, p_idx_max2;
 
 	LASSERT(npages > 0);
 	LASSERT(npages <= page_pools.epp_free_pages);
@@ -284,7 +284,7 @@ int npages_to_npools(unsigned long npages)
 static unsigned long enc_pools_cleanup(struct page ***pools, int npools)
 {
 	unsigned long cleaned = 0;
-	int	   i, j;
+	int i, j;
 
 	for (i = 0; i < npools; i++) {
 		if (pools[i]) {
@@ -311,9 +311,9 @@ static unsigned long enc_pools_cleanup(struct page ***pools, int npools)
  */
 static void enc_pools_insert(struct page ***pools, int npools, int npages)
 {
-	int     freeslot;
-	int     op_idx, np_idx, og_idx, ng_idx;
-	int     cur_npools, end_npools;
+	int freeslot;
+	int op_idx, np_idx, og_idx, ng_idx;
+	int cur_npools, end_npools;
 
 	LASSERT(npages > 0);
 	LASSERT(page_pools.epp_total_pages+npages <= page_pools.epp_max_pages);
@@ -393,9 +393,9 @@ static void enc_pools_insert(struct page ***pools, int npools, int npages)
 static int enc_pools_add_pages(int npages)
 {
 	static DEFINE_MUTEX(add_pages_mutex);
-	struct page   ***pools;
-	int	     npools, alloced = 0;
-	int	     i, j, rc = -ENOMEM;
+	struct page ***pools;
+	int npools, alloced = 0;
+	int i, j, rc = -ENOMEM;
 
 	if (npages < PTLRPC_MAX_BRW_PAGES)
 		npages = PTLRPC_MAX_BRW_PAGES;
@@ -494,12 +494,12 @@ static int enc_pools_should_grow(int page_needed, long now)
  */
 int sptlrpc_enc_pool_get_pages(struct ptlrpc_bulk_desc *desc)
 {
-	wait_queue_t  waitlink;
-	unsigned long   this_idle = -1;
-	unsigned long      tick = 0;
-	long	    now;
-	int	     p_idx, g_idx;
-	int	     i;
+	wait_queue_t waitlink;
+	unsigned long this_idle = -1;
+	unsigned long tick = 0;
+	long now;
+	int p_idx, g_idx;
+	int i;
 
 	LASSERT(desc->bd_iov_count > 0);
 	LASSERT(desc->bd_iov_count <= page_pools.epp_max_pages);
@@ -609,8 +609,8 @@ EXPORT_SYMBOL(sptlrpc_enc_pool_get_pages);
 
 void sptlrpc_enc_pool_put_pages(struct ptlrpc_bulk_desc *desc)
 {
-	int     p_idx, g_idx;
-	int     i;
+	int p_idx, g_idx;
+	int i;
 
 	if (desc->bd_enc_iov == NULL)
 		return;
@@ -658,7 +658,7 @@ EXPORT_SYMBOL(sptlrpc_enc_pool_put_pages);
  */
 int sptlrpc_enc_pool_add_user(void)
 {
-	int     need_grow = 0;
+	int need_grow = 0;
 
 	spin_lock(&page_pools.epp_lock);
 	if (page_pools.epp_growing == 0 && page_pools.epp_total_pages == 0) {
@@ -842,11 +842,11 @@ EXPORT_SYMBOL(bulk_sec_desc_unpack);
 int sptlrpc_get_bulk_checksum(struct ptlrpc_bulk_desc *desc, __u8 alg,
 			      void *buf, int buflen)
 {
-	struct cfs_crypto_hash_desc	*hdesc;
-	int				hashsize;
-	char				hashbuf[64];
-	unsigned int			bufsize;
-	int				i, err;
+	struct cfs_crypto_hash_desc *hdesc;
+	int hashsize;
+	char hashbuf[64];
+	unsigned int bufsize;
+	int i, err;
 
 	LASSERT(alg > BULK_HASH_ALG_NULL && alg < BULK_HASH_ALG_MAX);
 	LASSERT(buflen >= 4);
diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec_config.c b/drivers/staging/lustre/lustre/ptlrpc/sec_config.c
index 16dbf3f..31da43e 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/sec_config.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/sec_config.c
@@ -94,8 +94,8 @@ EXPORT_SYMBOL(sptlrpc_target_sec_part);
  */
 int sptlrpc_parse_flavor(const char *str, struct sptlrpc_flavor *flvr)
 {
-	char	    buf[32];
-	char	   *bulk, *alg;
+	char buf[32];
+	char *bulk, *alg;
 
 	memset(flvr, 0, sizeof(*flvr));
 
@@ -182,8 +182,8 @@ static void sptlrpc_rule_init(struct sptlrpc_rule *rule)
  */
 int sptlrpc_parse_rule(char *param, struct sptlrpc_rule *rule)
 {
-	char	   *flavor, *dir;
-	int	     rc;
+	char *flavor, *dir;
+	int rc;
 
 	sptlrpc_rule_init(rule);
 
@@ -309,9 +309,9 @@ static inline int rule_match_net(struct sptlrpc_rule *r1,
 int sptlrpc_rule_set_merge(struct sptlrpc_rule_set *rset,
 			   struct sptlrpc_rule *rule)
 {
-	struct sptlrpc_rule      *p = rset->srs_rules;
-	int		       spec_dir, spec_net;
-	int		       rc, n, match = 0;
+	struct sptlrpc_rule *p = rset->srs_rules;
+	int spec_dir, spec_net;
+	int rc, n, match = 0;
 
 	might_sleep();
 
@@ -403,8 +403,8 @@ int sptlrpc_rule_set_choose(struct sptlrpc_rule_set *rset,
 			    lnet_nid_t nid,
 			    struct sptlrpc_flavor *sf)
 {
-	struct sptlrpc_rule    *r;
-	int		     n;
+	struct sptlrpc_rule *r;
+	int n;
 
 	for (n = 0; n < rset->srs_nrule; n++) {
 		r = &rset->srs_rules[n];
@@ -433,7 +433,7 @@ EXPORT_SYMBOL(sptlrpc_rule_set_choose);
 void sptlrpc_rule_set_dump(struct sptlrpc_rule_set *rset)
 {
 	struct sptlrpc_rule *r;
-	int     n;
+	int n;
 
 	for (n = 0; n < rset->srs_nrule; n++) {
 		r = &rset->srs_rules[n];
@@ -474,8 +474,8 @@ static inline int is_hex(char c)
 
 static void target2fsname(const char *tgt, char *fsname, int buflen)
 {
-	const char     *ptr;
-	int	     len;
+	const char *ptr;
+	int len;
 
 	ptr = strrchr(tgt, '-');
 	if (ptr) {
@@ -583,8 +583,8 @@ static int sptlrpc_conf_merge_rule(struct sptlrpc_conf *conf,
 				   const char *target,
 				   struct sptlrpc_rule *rule)
 {
-	struct sptlrpc_conf_tgt  *conf_tgt;
-	struct sptlrpc_rule_set  *rule_set;
+	struct sptlrpc_conf_tgt *conf_tgt;
+	struct sptlrpc_rule_set *rule_set;
 
 	/* fsname == target means general rules for the whole fs */
 	if (strcmp(conf->sc_fsname, target) == 0) {
@@ -610,10 +610,10 @@ static int sptlrpc_conf_merge_rule(struct sptlrpc_conf *conf,
 static int __sptlrpc_process_config(struct lustre_cfg *lcfg,
 				    struct sptlrpc_conf *conf)
 {
-	char		   *target, *param;
-	char		    fsname[MTI_NAME_MAXLEN];
-	struct sptlrpc_rule     rule;
-	int		     rc;
+	char *target, *param;
+	char fsname[MTI_NAME_MAXLEN];
+	struct sptlrpc_rule rule;
+	int rc;
 
 	target = lustre_cfg_string(lcfg, 1);
 	if (target == NULL) {
@@ -671,8 +671,8 @@ EXPORT_SYMBOL(sptlrpc_process_config);
 
 static int logname2fsname(const char *logname, char *buf, int buflen)
 {
-	char   *ptr;
-	int     len;
+	char *ptr;
+	int len;
 
 	ptr = strrchr(logname, '-');
 	if (ptr == NULL || strcmp(ptr, "-sptlrpc")) {
@@ -690,7 +690,7 @@ static int logname2fsname(const char *logname, char *buf, int buflen)
 void sptlrpc_conf_log_update_begin(const char *logname)
 {
 	struct sptlrpc_conf *conf;
-	char		 fsname[16];
+	char fsname[16];
 
 	if (logname2fsname(logname, fsname, sizeof(fsname)))
 		return;
@@ -716,7 +716,7 @@ EXPORT_SYMBOL(sptlrpc_conf_log_update_begin);
 void sptlrpc_conf_log_update_end(const char *logname)
 {
 	struct sptlrpc_conf *conf;
-	char		 fsname[16];
+	char fsname[16];
 
 	if (logname2fsname(logname, fsname, sizeof(fsname)))
 		return;
@@ -741,7 +741,7 @@ EXPORT_SYMBOL(sptlrpc_conf_log_update_end);
 
 void sptlrpc_conf_log_start(const char *logname)
 {
-	char		 fsname[16];
+	char fsname[16];
 
 	if (logname2fsname(logname, fsname, sizeof(fsname)))
 		return;
@@ -755,7 +755,7 @@ EXPORT_SYMBOL(sptlrpc_conf_log_start);
 void sptlrpc_conf_log_stop(const char *logname)
 {
 	struct sptlrpc_conf *conf;
-	char		 fsname[16];
+	char fsname[16];
 
 	if (logname2fsname(logname, fsname, sizeof(fsname)))
 		return;
@@ -799,10 +799,10 @@ void sptlrpc_conf_choose_flavor(enum lustre_sec_part from,
 				lnet_nid_t nid,
 				struct sptlrpc_flavor *sf)
 {
-	struct sptlrpc_conf     *conf;
+	struct sptlrpc_conf *conf;
 	struct sptlrpc_conf_tgt *conf_tgt;
-	char		     name[MTI_NAME_MAXLEN];
-	int		      len, rc = 0;
+	char name[MTI_NAME_MAXLEN];
+	int len, rc = 0;
 
 	target2fsname(target->uuid, name, sizeof(name));
 
@@ -858,7 +858,7 @@ EXPORT_SYMBOL(sptlrpc_target_choose_flavor);
  */
 void sptlrpc_conf_client_adapt(struct obd_device *obd)
 {
-	struct obd_import  *imp;
+	struct obd_import *imp;
 
 	LASSERT(strcmp(obd->obd_type->typ_name, LUSTRE_MDC_NAME) == 0 ||
 		strcmp(obd->obd_type->typ_name, LUSTRE_OSC_NAME) == 0);
@@ -880,7 +880,7 @@ void sptlrpc_conf_client_adapt(struct obd_device *obd)
 }
 EXPORT_SYMBOL(sptlrpc_conf_client_adapt);
 
-int  sptlrpc_conf_init(void)
+int sptlrpc_conf_init(void)
 {
 	mutex_init(&sptlrpc_conf_lock);
 	return 0;
@@ -888,7 +888,7 @@ int  sptlrpc_conf_init(void)
 
 void sptlrpc_conf_fini(void)
 {
-	struct sptlrpc_conf  *conf, *conf_next;
+	struct sptlrpc_conf *conf, *conf_next;
 
 	mutex_lock(&sptlrpc_conf_lock);
 	list_for_each_entry_safe(conf, conf_next, &sptlrpc_confs, sc_list) {
diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec_gc.c b/drivers/staging/lustre/lustre/ptlrpc/sec_gc.c
index 81de68e..cdad608 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/sec_gc.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/sec_gc.c
@@ -164,7 +164,7 @@ static void sec_do_gc(struct ptlrpc_sec *sec)
 static int sec_gc_main(void *arg)
 {
 	struct ptlrpc_thread *thread = (struct ptlrpc_thread *) arg;
-	struct l_wait_info    lwi;
+	struct l_wait_info lwi;
 
 	unshare_fs_struct();
 
diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec_lproc.c b/drivers/staging/lustre/lustre/ptlrpc/sec_lproc.c
index 982512f..68fcac1 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/sec_lproc.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/sec_lproc.c
@@ -74,7 +74,7 @@ static int sptlrpc_info_lprocfs_seq_show(struct seq_file *seq, void *v)
 	struct obd_device *dev = seq->private;
 	struct client_obd *cli = &dev->u.cli;
 	struct ptlrpc_sec *sec = NULL;
-	char	       str[32];
+	char str[32];
 
 	LASSERT(strcmp(dev->obd_type->typ_name, LUSTRE_OSC_NAME) == 0 ||
 		strcmp(dev->obd_type->typ_name, LUSTRE_MDC_NAME) == 0 ||
@@ -134,7 +134,7 @@ LPROC_SEQ_FOPS_RO(sptlrpc_ctxs_lprocfs);
 
 int sptlrpc_lprocfs_cliobd_attach(struct obd_device *dev)
 {
-	int     rc;
+	int rc;
 
 	if (strcmp(dev->obd_type->typ_name, LUSTRE_OSC_NAME) != 0 &&
 	    strcmp(dev->obd_type->typ_name, LUSTRE_MDC_NAME) != 0 &&
diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec_null.c b/drivers/staging/lustre/lustre/ptlrpc/sec_null.c
index 4e13243..8c28b6b 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/sec_null.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/sec_null.c
@@ -92,7 +92,7 @@ int null_ctx_sign(struct ptlrpc_cli_ctx *ctx, struct ptlrpc_request *req)
 static
 int null_ctx_verify(struct ptlrpc_cli_ctx *ctx, struct ptlrpc_request *req)
 {
-	__u32   cksums, cksumc;
+	__u32 cksums, cksumc;
 
 	LASSERT(req->rq_repdata);
 
@@ -226,9 +226,9 @@ int null_enlarge_reqbuf(struct ptlrpc_sec *sec,
 			struct ptlrpc_request *req,
 			int segment, int newsize)
 {
-	struct lustre_msg      *newbuf;
-	struct lustre_msg      *oldbuf = req->rq_reqmsg;
-	int		     oldsize, newmsg_size, alloc_size;
+	struct lustre_msg *newbuf;
+	struct lustre_msg *oldbuf = req->rq_reqmsg;
+	int oldsize, newmsg_size, alloc_size;
 
 	LASSERT(req->rq_reqbuf);
 	LASSERT(req->rq_reqbuf == req->rq_reqmsg);
diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec_plain.c b/drivers/staging/lustre/lustre/ptlrpc/sec_plain.c
index 65f3ab4..ed39970 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/sec_plain.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/sec_plain.c
@@ -136,7 +136,7 @@ static int plain_verify_bulk_csum(struct ptlrpc_bulk_desc *desc,
 				  struct plain_bulk_token *tokenr)
 {
 	struct plain_bulk_token tokenv;
-	int		     rc;
+	int rc;
 
 	if (hash_alg == BULK_HASH_ALG_NULL)
 		return 0;
@@ -154,8 +154,8 @@ static int plain_verify_bulk_csum(struct ptlrpc_bulk_desc *desc,
 
 static void corrupt_bulk_data(struct ptlrpc_bulk_desc *desc)
 {
-	char	   *ptr;
-	unsigned int    off, i;
+	char *ptr;
+	unsigned int off, i;
 
 	for (i = 0; i < desc->bd_iov_count; i++) {
 		if (desc->bd_iov[i].kiov_len == 0)
@@ -190,7 +190,7 @@ int plain_ctx_validate(struct ptlrpc_cli_ctx *ctx)
 static
 int plain_ctx_sign(struct ptlrpc_cli_ctx *ctx, struct ptlrpc_request *req)
 {
-	struct lustre_msg   *msg = req->rq_reqbuf;
+	struct lustre_msg *msg = req->rq_reqbuf;
 	struct plain_header *phdr;
 
 	msg->lm_secflvr = req->rq_flvr.sf_rpc;
@@ -214,10 +214,10 @@ int plain_ctx_sign(struct ptlrpc_cli_ctx *ctx, struct ptlrpc_request *req)
 static
 int plain_ctx_verify(struct ptlrpc_cli_ctx *ctx, struct ptlrpc_request *req)
 {
-	struct lustre_msg   *msg = req->rq_repdata;
+	struct lustre_msg *msg = req->rq_repdata;
 	struct plain_header *phdr;
-	__u32		cksum;
-	int		  swabbed;
+	__u32 cksum;
+	int swabbed;
 
 	if (msg->lm_bufcount != PLAIN_PACK_SEGMENTS) {
 		CERROR("unexpected reply buf count %u\n", msg->lm_bufcount);
@@ -290,8 +290,8 @@ int plain_cli_wrap_bulk(struct ptlrpc_cli_ctx *ctx,
 			struct ptlrpc_bulk_desc *desc)
 {
 	struct ptlrpc_bulk_sec_desc *bsd;
-	struct plain_bulk_token     *token;
-	int			  rc;
+	struct plain_bulk_token *token;
+	int rc;
 
 	LASSERT(req->rq_pack_bulk);
 	LASSERT(req->rq_reqbuf->lm_bufcount == PLAIN_PACK_SEGMENTS);
@@ -333,9 +333,9 @@ int plain_cli_unwrap_bulk(struct ptlrpc_cli_ctx *ctx,
 			  struct ptlrpc_bulk_desc *desc)
 {
 	struct ptlrpc_bulk_sec_desc *bsdv;
-	struct plain_bulk_token     *tokenv;
-	int			  rc;
-	int			  i, nob;
+	struct plain_bulk_token *tokenv;
+	int rc;
+	int i, nob;
 
 	LASSERT(req->rq_pack_bulk);
 	LASSERT(req->rq_reqbuf->lm_bufcount == PLAIN_PACK_SEGMENTS);
@@ -374,7 +374,7 @@ int plain_cli_unwrap_bulk(struct ptlrpc_cli_ctx *ctx,
 static
 struct ptlrpc_cli_ctx *plain_sec_install_ctx(struct plain_sec *plsec)
 {
-	struct ptlrpc_cli_ctx  *ctx, *ctx_new;
+	struct ptlrpc_cli_ctx *ctx, *ctx_new;
 
 	ctx_new = kzalloc(sizeof(*ctx_new), GFP_NOFS);
 
@@ -413,7 +413,7 @@ struct ptlrpc_cli_ctx *plain_sec_install_ctx(struct plain_sec *plsec)
 static
 void plain_destroy_sec(struct ptlrpc_sec *sec)
 {
-	struct plain_sec       *plsec = sec2plsec(sec);
+	struct plain_sec *plsec = sec2plsec(sec);
 
 	LASSERT(sec->ps_policy == &plain_policy);
 	LASSERT(sec->ps_import);
@@ -437,9 +437,9 @@ struct ptlrpc_sec *plain_create_sec(struct obd_import *imp,
 				    struct ptlrpc_svc_ctx *svc_ctx,
 				    struct sptlrpc_flavor *sf)
 {
-	struct plain_sec       *plsec;
-	struct ptlrpc_sec      *sec;
-	struct ptlrpc_cli_ctx  *ctx;
+	struct plain_sec *plsec;
+	struct ptlrpc_sec *sec;
+	struct ptlrpc_cli_ctx *ctx;
 
 	LASSERT(SPTLRPC_FLVR_POLICY(sf->sf_rpc) == SPTLRPC_POLICY_PLAIN);
 
@@ -483,8 +483,8 @@ struct ptlrpc_cli_ctx *plain_lookup_ctx(struct ptlrpc_sec *sec,
 					struct vfs_cred *vcred,
 					int create, int remove_dead)
 {
-	struct plain_sec       *plsec = sec2plsec(sec);
-	struct ptlrpc_cli_ctx  *ctx;
+	struct plain_sec *plsec = sec2plsec(sec);
+	struct ptlrpc_cli_ctx *ctx;
 
 	read_lock(&plsec->pls_lock);
 	ctx = plsec->pls_ctx;
@@ -517,8 +517,8 @@ static
 int plain_flush_ctx_cache(struct ptlrpc_sec *sec,
 			  uid_t uid, int grace, int force)
 {
-	struct plain_sec       *plsec = sec2plsec(sec);
-	struct ptlrpc_cli_ctx  *ctx;
+	struct plain_sec *plsec = sec2plsec(sec);
+	struct ptlrpc_cli_ctx *ctx;
 
 	/* do nothing unless caller want to flush for 'all' */
 	if (uid != -1)
@@ -540,7 +540,7 @@ int plain_alloc_reqbuf(struct ptlrpc_sec *sec,
 		       int msgsize)
 {
 	__u32 buflens[PLAIN_PACK_SEGMENTS] = { 0, };
-	int   alloc_len;
+	int alloc_len;
 
 	buflens[PLAIN_PACK_HDR_OFF] = sizeof(struct plain_header);
 	buflens[PLAIN_PACK_MSG_OFF] = msgsize;
@@ -635,9 +635,9 @@ int plain_enlarge_reqbuf(struct ptlrpc_sec *sec,
 			 struct ptlrpc_request *req,
 			 int segment, int newsize)
 {
-	struct lustre_msg      *newbuf;
-	int		     oldsize;
-	int		     newmsg_size, newbuf_size;
+	struct lustre_msg *newbuf;
+	int oldsize;
+	int newmsg_size, newbuf_size;
 
 	LASSERT(req->rq_reqbuf);
 	LASSERT(req->rq_reqbuf_len >= req->rq_reqlen);
@@ -709,9 +709,9 @@ static struct ptlrpc_svc_ctx plain_svc_ctx = {
 static
 int plain_accept(struct ptlrpc_request *req)
 {
-	struct lustre_msg   *msg = req->rq_reqbuf;
+	struct lustre_msg *msg = req->rq_reqbuf;
 	struct plain_header *phdr;
-	int		  swabbed;
+	int swabbed;
 
 	LASSERT(SPTLRPC_FLVR_POLICY(req->rq_flvr.sf_rpc) ==
 		SPTLRPC_POLICY_PLAIN);
@@ -780,9 +780,9 @@ int plain_accept(struct ptlrpc_request *req)
 static
 int plain_alloc_rs(struct ptlrpc_request *req, int msgsize)
 {
-	struct ptlrpc_reply_state   *rs;
-	__u32			buflens[PLAIN_PACK_SEGMENTS] = { 0, };
-	int			  rs_size = sizeof(*rs);
+	struct ptlrpc_reply_state *rs;
+	__u32 buflens[PLAIN_PACK_SEGMENTS] = { 0, };
+	int rs_size = sizeof(*rs);
 
 	LASSERT(msgsize % 8 == 0);
 
@@ -833,9 +833,9 @@ static
 int plain_authorize(struct ptlrpc_request *req)
 {
 	struct ptlrpc_reply_state *rs = req->rq_reply_state;
-	struct lustre_msg_v2      *msg = rs->rs_repbuf;
-	struct plain_header       *phdr;
-	int			len;
+	struct lustre_msg_v2 *msg = rs->rs_repbuf;
+	struct plain_header *phdr;
+	int len;
 
 	LASSERT(rs);
 	LASSERT(msg);
@@ -880,10 +880,10 @@ static
 int plain_svc_unwrap_bulk(struct ptlrpc_request *req,
 			  struct ptlrpc_bulk_desc *desc)
 {
-	struct ptlrpc_reply_state   *rs = req->rq_reply_state;
+	struct ptlrpc_reply_state *rs = req->rq_reply_state;
 	struct ptlrpc_bulk_sec_desc *bsdr, *bsdv;
-	struct plain_bulk_token     *tokenr;
-	int			  rc;
+	struct plain_bulk_token *tokenr;
+	int rc;
 
 	LASSERT(req->rq_bulk_write);
 	LASSERT(req->rq_pack_bulk);
@@ -914,10 +914,10 @@ static
 int plain_svc_wrap_bulk(struct ptlrpc_request *req,
 			struct ptlrpc_bulk_desc *desc)
 {
-	struct ptlrpc_reply_state   *rs = req->rq_reply_state;
+	struct ptlrpc_reply_state *rs = req->rq_reply_state;
 	struct ptlrpc_bulk_sec_desc *bsdr, *bsdv;
-	struct plain_bulk_token     *tokenv;
-	int			  rc;
+	struct plain_bulk_token *tokenv;
+	int rc;
 
 	LASSERT(req->rq_bulk_read);
 	LASSERT(req->rq_pack_bulk);
diff --git a/drivers/staging/lustre/lustre/ptlrpc/service.c b/drivers/staging/lustre/lustre/ptlrpc/service.c
index 454d1a8..25ccbcb 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/service.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/service.c
@@ -72,7 +72,7 @@ struct mutex ptlrpc_all_services_mutex;
 struct ptlrpc_request_buffer_desc *
 ptlrpc_alloc_rqbd(struct ptlrpc_service_part *svcpt)
 {
-	struct ptlrpc_service		  *svc = svcpt->scp_service;
+	struct ptlrpc_service *svc = svcpt->scp_service;
 	struct ptlrpc_request_buffer_desc *rqbd;
 
 	rqbd = kzalloc_node(sizeof(*rqbd), GFP_NOFS,
@@ -121,10 +121,10 @@ ptlrpc_free_rqbd(struct ptlrpc_request_buffer_desc *rqbd)
 int
 ptlrpc_grow_req_bufs(struct ptlrpc_service_part *svcpt, int post)
 {
-	struct ptlrpc_service		  *svc = svcpt->scp_service;
+	struct ptlrpc_service *svc = svcpt->scp_service;
 	struct ptlrpc_request_buffer_desc *rqbd;
-	int				rc = 0;
-	int				i;
+	int rc = 0;
+	int i;
 
 	if (svcpt->scp_rqbd_allocating)
 		goto try_post;
@@ -186,7 +186,7 @@ ptlrpc_save_lock(struct ptlrpc_request *req,
 		 struct lustre_handle *lock, int mode, int no_ack)
 {
 	struct ptlrpc_reply_state *rs = req->rq_reply_state;
-	int			idx;
+	int idx;
 
 	LASSERT(rs != NULL);
 	LASSERT(rs->rs_nlocks < RS_MAX_LOCKS);
@@ -275,8 +275,8 @@ static void rs_batch_init(struct rs_batch *b)
 static struct ptlrpc_hr_thread *
 ptlrpc_hr_select(struct ptlrpc_service_part *svcpt)
 {
-	struct ptlrpc_hr_partition	*hrp;
-	unsigned int			rotor;
+	struct ptlrpc_hr_partition *hrp;
+	unsigned int rotor;
 
 	if (svcpt->scp_cpt >= 0 &&
 	    svcpt->scp_service->srv_cptable == ptlrpc_hr.hr_cpt_table) {
@@ -431,8 +431,8 @@ static int
 ptlrpc_server_post_idle_rqbds(struct ptlrpc_service_part *svcpt)
 {
 	struct ptlrpc_request_buffer_desc *rqbd;
-	int				  rc;
-	int				  posted = 0;
+	int rc;
+	int posted = 0;
 
 	for (;;) {
 		spin_lock(&svcpt->scp_lock);
@@ -489,11 +489,11 @@ static void
 ptlrpc_server_nthreads_check(struct ptlrpc_service *svc,
 			     struct ptlrpc_service_conf *conf)
 {
-	struct ptlrpc_service_thr_conf	*tc = &conf->psc_thr;
-	unsigned			init;
-	unsigned			total;
-	unsigned			nthrs;
-	int				weight;
+	struct ptlrpc_service_thr_conf *tc = &conf->psc_thr;
+	unsigned init;
+	unsigned total;
+	unsigned nthrs;
+	int weight;
 
 	/*
 	 * Common code for estimating & validating threads number.
@@ -517,7 +517,7 @@ ptlrpc_server_nthreads_check(struct ptlrpc_service *svc,
 		 * be up to 8 * nthrs_max */
 		total = min(tc->tc_nthrs_max * 8, tc->tc_nthrs_user);
 		nthrs = total / svc->srv_ncpts;
-		init  = max(init, nthrs);
+		init = max(init, nthrs);
 		goto out;
 	}
 
@@ -531,7 +531,7 @@ ptlrpc_server_nthreads_check(struct ptlrpc_service *svc,
 
 	nthrs = tc->tc_nthrs_base;
 	if (svc->srv_ncpts == 1) {
-		int	i;
+		int i;
 
 		/* NB: Increase the base number if it's single partition
 		 * and total number of cores/HTs is larger or equal to 4.
@@ -543,7 +543,7 @@ ptlrpc_server_nthreads_check(struct ptlrpc_service *svc,
 	}
 
 	if (tc->tc_thr_factor != 0) {
-		int	  factor = tc->tc_thr_factor;
+		int factor = tc->tc_thr_factor;
 		const int fade = 4;
 
 		/*
@@ -595,9 +595,9 @@ ptlrpc_service_part_init(struct ptlrpc_service *svc,
 			 struct ptlrpc_service_part *svcpt, int cpt)
 {
 	struct ptlrpc_at_array	*array;
-	int			size;
-	int			index;
-	int			rc;
+	int size;
+	int index;
+	int rc;
 
 	svcpt->scp_cpt = cpt;
 	INIT_LIST_HEAD(&svcpt->scp_threads);
@@ -627,8 +627,8 @@ ptlrpc_service_part_init(struct ptlrpc_service *svc,
 	array = &svcpt->scp_at_array;
 
 	size = at_est2timeout(at_max);
-	array->paa_size     = size;
-	array->paa_count    = 0;
+	array->paa_size = size;
+	array->paa_count = 0;
 	array->paa_deadline = -1;
 
 	/* allocate memory for scp_at_array (ptlrpc_at_array) */
@@ -683,15 +683,15 @@ ptlrpc_register_service(struct ptlrpc_service_conf *conf,
 			struct kset *parent,
 			struct dentry *debugfs_entry)
 {
-	struct ptlrpc_service_cpt_conf	*cconf = &conf->psc_cpt;
-	struct ptlrpc_service		*service;
-	struct ptlrpc_service_part	*svcpt;
-	struct cfs_cpt_table		*cptable;
-	__u32				*cpts = NULL;
-	int				ncpts;
-	int				cpt;
-	int				rc;
-	int				i;
+	struct ptlrpc_service_cpt_conf *cconf = &conf->psc_cpt;
+	struct ptlrpc_service *service;
+	struct ptlrpc_service_part *svcpt;
+	struct cfs_cpt_table *cptable;
+	__u32 *cpts = NULL;
+	int ncpts;
+	int cpt;
+	int rc;
+	int i;
 
 	LASSERT(conf->psc_buf.bc_nbufs > 0);
 	LASSERT(conf->psc_buf.bc_buf_size >=
@@ -707,7 +707,7 @@ ptlrpc_register_service(struct ptlrpc_service_conf *conf,
 	} else {
 		ncpts = cfs_cpt_number(cptable);
 		if (cconf->cc_pattern != NULL) {
-			struct cfs_expr_list	*el;
+			struct cfs_expr_list *el;
 
 			rc = cfs_expr_list_parse(cconf->cc_pattern,
 						 strlen(cconf->cc_pattern),
@@ -737,9 +737,9 @@ ptlrpc_register_service(struct ptlrpc_service_conf *conf,
 		return ERR_PTR(-ENOMEM);
 	}
 
-	service->srv_cptable		= cptable;
-	service->srv_cpts		= cpts;
-	service->srv_ncpts		= ncpts;
+	service->srv_cptable = cptable;
+	service->srv_cpts = cpts;
+	service->srv_ncpts = ncpts;
 
 	service->srv_cpt_bits = 0; /* it's zero already, easy to read... */
 	while ((1 << service->srv_cpt_bits) < cfs_cpt_number(cptable))
@@ -747,18 +747,18 @@ ptlrpc_register_service(struct ptlrpc_service_conf *conf,
 
 	/* public members */
 	spin_lock_init(&service->srv_lock);
-	service->srv_name		= conf->psc_name;
-	service->srv_watchdog_factor	= conf->psc_watchdog_factor;
+	service->srv_name = conf->psc_name;
+	service->srv_watchdog_factor = conf->psc_watchdog_factor;
 	INIT_LIST_HEAD(&service->srv_list); /* for safety of cleanup */
 
 	/* buffer configuration */
-	service->srv_nbuf_per_group	= test_req_buffer_pressure ?
+	service->srv_nbuf_per_group = test_req_buffer_pressure ?
 					  1 : conf->psc_buf.bc_nbufs;
-	service->srv_max_req_size	= conf->psc_buf.bc_req_max_size +
+	service->srv_max_req_size = conf->psc_buf.bc_req_max_size +
 					  SPTLRPC_MAX_PAYLOAD;
-	service->srv_buf_size		= conf->psc_buf.bc_buf_size;
-	service->srv_rep_portal		= conf->psc_buf.bc_rep_portal;
-	service->srv_req_portal		= conf->psc_buf.bc_req_portal;
+	service->srv_buf_size = conf->psc_buf.bc_buf_size;
+	service->srv_rep_portal	= conf->psc_buf.bc_rep_portal;
+	service->srv_req_portal	= conf->psc_buf.bc_req_portal;
 
 	/* Increase max reply size to next power of two */
 	service->srv_max_reply_size = 1;
@@ -766,10 +766,10 @@ ptlrpc_register_service(struct ptlrpc_service_conf *conf,
 	       conf->psc_buf.bc_rep_max_size + SPTLRPC_MAX_PAYLOAD)
 		service->srv_max_reply_size <<= 1;
 
-	service->srv_thread_name	= conf->psc_thr.tc_thr_name;
-	service->srv_ctx_tags		= conf->psc_thr.tc_ctx_tags;
-	service->srv_hpreq_ratio	= PTLRPC_SVC_HP_RATIO;
-	service->srv_ops		= conf->psc_ops;
+	service->srv_thread_name = conf->psc_thr.tc_thr_name;
+	service->srv_ctx_tags = conf->psc_thr.tc_ctx_tags;
+	service->srv_hpreq_ratio = PTLRPC_SVC_HP_RATIO;
+	service->srv_ops = conf->psc_ops;
 
 	for (i = 0; i < ncpts; i++) {
 		if (!conf->psc_thr.tc_cpu_affinity)
@@ -859,11 +859,11 @@ static void ptlrpc_server_free_request(struct ptlrpc_request *req)
 void ptlrpc_server_drop_request(struct ptlrpc_request *req)
 {
 	struct ptlrpc_request_buffer_desc *rqbd = req->rq_rqbd;
-	struct ptlrpc_service_part	  *svcpt = rqbd->rqbd_svcpt;
-	struct ptlrpc_service		  *svc = svcpt->scp_service;
-	int				refcount;
-	struct list_head			*tmp;
-	struct list_head			*nxt;
+	struct ptlrpc_service_part *svcpt = rqbd->rqbd_svcpt;
+	struct ptlrpc_service *svc = svcpt->scp_service;
+	int refcount;
+	struct list_head *tmp;
+	struct list_head *nxt;
 
 	if (!atomic_dec_and_test(&req->rq_refcount))
 		return;
@@ -1387,7 +1387,7 @@ static int ptlrpc_at_check_timed(struct ptlrpc_service_part *svcpt)
 	struct ptlrpc_at_array *array = &svcpt->scp_at_array;
 	struct ptlrpc_request *rq, *n;
 	struct list_head work_list;
-	__u32  index, count;
+	__u32 index, count;
 	time_t deadline;
 	time_t now = get_seconds();
 	long delay;
@@ -1732,10 +1732,10 @@ static int
 ptlrpc_server_handle_req_in(struct ptlrpc_service_part *svcpt,
 			    struct ptlrpc_thread *thread)
 {
-	struct ptlrpc_service	*svc = svcpt->scp_service;
-	struct ptlrpc_request	*req;
-	__u32			deadline;
-	int			rc;
+	struct ptlrpc_service *svc = svcpt->scp_service;
+	struct ptlrpc_request *req;
+	__u32 deadline;
+	int rc;
 
 	spin_lock(&svcpt->scp_lock);
 	if (list_empty(&svcpt->scp_req_incoming)) {
@@ -1876,11 +1876,11 @@ ptlrpc_server_handle_request(struct ptlrpc_service_part *svcpt,
 {
 	struct ptlrpc_service *svc = svcpt->scp_service;
 	struct ptlrpc_request *request;
-	struct timeval	 work_start;
-	struct timeval	 work_end;
-	long		   timediff;
-	int		    rc;
-	int		    fail_opc = 0;
+	struct timeval work_start;
+	struct timeval work_end;
+	long timediff;
+	int rc;
+	int fail_opc = 0;
 
 	request = ptlrpc_server_request_get(svcpt, false);
 	if (request == NULL)
@@ -2032,10 +2032,10 @@ static int
 ptlrpc_handle_rs(struct ptlrpc_reply_state *rs)
 {
 	struct ptlrpc_service_part *svcpt = rs->rs_svcpt;
-	struct ptlrpc_service     *svc = svcpt->scp_service;
-	struct obd_export	 *exp;
-	int			nlocks;
-	int			been_handled;
+	struct ptlrpc_service *svc = svcpt->scp_service;
+	struct obd_export *exp;
+	int nlocks;
+	int been_handled;
 
 	exp = rs->rs_export;
 
@@ -2262,10 +2262,10 @@ ptlrpc_wait_event(struct ptlrpc_service_part *svcpt,
  */
 static int ptlrpc_main(void *arg)
 {
-	struct ptlrpc_thread		*thread = (struct ptlrpc_thread *)arg;
-	struct ptlrpc_service_part	*svcpt = thread->t_svcpt;
-	struct ptlrpc_service		*svc = svcpt->scp_service;
-	struct ptlrpc_reply_state	*rs;
+	struct ptlrpc_thread *thread = (struct ptlrpc_thread *)arg;
+	struct ptlrpc_service_part *svcpt = thread->t_svcpt;
+	struct ptlrpc_service *svc = svcpt->scp_service;
+	struct ptlrpc_reply_state *rs;
 	struct group_info *ginfo = NULL;
 	struct lu_env *env;
 	int counter = 0, rc = 0;
@@ -2464,11 +2464,11 @@ static int hrt_dont_sleep(struct ptlrpc_hr_thread *hrt,
  */
 static int ptlrpc_hr_main(void *arg)
 {
-	struct ptlrpc_hr_thread		*hrt = (struct ptlrpc_hr_thread *)arg;
-	struct ptlrpc_hr_partition	*hrp = hrt->hrt_partition;
-	LIST_HEAD			(replies);
-	char				threadname[20];
-	int				rc;
+	struct ptlrpc_hr_thread	*hrt = (struct ptlrpc_hr_thread *)arg;
+	struct ptlrpc_hr_partition *hrp = hrt->hrt_partition;
+	LIST_HEAD	(replies);
+	char threadname[20];
+	int rc;
 
 	snprintf(threadname, sizeof(threadname), "ptlrpc_hr%02d_%03d",
 		 hrp->hrp_cpt, hrt->hrt_id);
@@ -2505,9 +2505,9 @@ static int ptlrpc_hr_main(void *arg)
 
 static void ptlrpc_stop_hr_threads(void)
 {
-	struct ptlrpc_hr_partition	*hrp;
-	int				i;
-	int				j;
+	struct ptlrpc_hr_partition *hrp;
+	int i;
+	int j;
 
 	ptlrpc_hr.hr_stopping = 1;
 
@@ -2529,12 +2529,12 @@ static void ptlrpc_stop_hr_threads(void)
 
 static int ptlrpc_start_hr_threads(void)
 {
-	struct ptlrpc_hr_partition	*hrp;
-	int				i;
-	int				j;
+	struct ptlrpc_hr_partition *hrp;
+	int i;
+	int j;
 
 	cfs_percpt_for_each(hrp, i, ptlrpc_hr.hr_partitions) {
-		int	rc = 0;
+		int rc = 0;
 
 		for (j = 0; j < hrp->hrp_nthrs; j++) {
 			struct	ptlrpc_hr_thread *hrt = &hrp->hrp_thrs[j];
@@ -2561,9 +2561,9 @@ static int ptlrpc_start_hr_threads(void)
 
 static void ptlrpc_svcpt_stop_threads(struct ptlrpc_service_part *svcpt)
 {
-	struct l_wait_info	lwi = { 0 };
-	struct ptlrpc_thread	*thread;
-	LIST_HEAD		(zombie);
+	struct l_wait_info lwi = { 0 };
+	struct ptlrpc_thread *thread;
+	LIST_HEAD	(zombie);
 
 	CDEBUG(D_INFO, "Stopping threads for service %s\n",
 	       svcpt->scp_service->srv_name);
@@ -2612,7 +2612,7 @@ static void ptlrpc_svcpt_stop_threads(struct ptlrpc_service_part *svcpt)
 void ptlrpc_stop_all_threads(struct ptlrpc_service *svc)
 {
 	struct ptlrpc_service_part *svcpt;
-	int			   i;
+	int i;
 
 	ptlrpc_service_for_each_part(svcpt, i, svc) {
 		if (svcpt->scp_service != NULL)
@@ -2623,9 +2623,9 @@ EXPORT_SYMBOL(ptlrpc_stop_all_threads);
 
 int ptlrpc_start_threads(struct ptlrpc_service *svc)
 {
-	int	rc = 0;
-	int	i;
-	int	j;
+	int rc = 0;
+	int i;
+	int j;
 
 	/* We require 2 threads min, see note in ptlrpc_server_handle_request */
 	LASSERT(svc->srv_nthrs_cpt_init >= PTLRPC_NTHRS_INIT);
@@ -2654,10 +2654,10 @@ EXPORT_SYMBOL(ptlrpc_start_threads);
 
 int ptlrpc_start_thread(struct ptlrpc_service_part *svcpt, int wait)
 {
-	struct l_wait_info	lwi = { 0 };
-	struct ptlrpc_thread	*thread;
-	struct ptlrpc_service	*svc;
-	int			rc;
+	struct l_wait_info lwi = { 0 };
+	struct ptlrpc_thread *thread;
+	struct ptlrpc_service *svc;
+	int rc;
 
 	LASSERT(svcpt != NULL);
 
@@ -2759,12 +2759,12 @@ int ptlrpc_start_thread(struct ptlrpc_service_part *svcpt, int wait)
 
 int ptlrpc_hr_init(void)
 {
-	struct ptlrpc_hr_partition	*hrp;
-	struct ptlrpc_hr_thread		*hrt;
-	int				rc;
-	int				i;
-	int				j;
-	int				weight;
+	struct ptlrpc_hr_partition *hrp;
+	struct ptlrpc_hr_thread	*hrt;
+	int rc;
+	int i;
+	int j;
+	int weight;
 
 	memset(&ptlrpc_hr, 0, sizeof(ptlrpc_hr));
 	ptlrpc_hr.hr_cpt_table = cfs_cpt_table;
@@ -2817,8 +2817,8 @@ out:
 
 void ptlrpc_hr_fini(void)
 {
-	struct ptlrpc_hr_partition	*hrp;
-	int				i;
+	struct ptlrpc_hr_partition *hrp;
+	int i;
 
 	if (ptlrpc_hr.hr_partitions == NULL)
 		return;
@@ -2858,8 +2858,8 @@ static void ptlrpc_wait_replies(struct ptlrpc_service_part *svcpt)
 static void
 ptlrpc_service_del_atimer(struct ptlrpc_service *svc)
 {
-	struct ptlrpc_service_part	*svcpt;
-	int				i;
+	struct ptlrpc_service_part *svcpt;
+	int i;
 
 	/* early disarm AT timer... */
 	ptlrpc_service_for_each_part(svcpt, i, svc) {
@@ -2871,11 +2871,11 @@ ptlrpc_service_del_atimer(struct ptlrpc_service *svc)
 static void
 ptlrpc_service_unlink_rqbd(struct ptlrpc_service *svc)
 {
-	struct ptlrpc_service_part	  *svcpt;
+	struct ptlrpc_service_part *svcpt;
 	struct ptlrpc_request_buffer_desc *rqbd;
-	struct l_wait_info		  lwi;
-	int				  rc;
-	int				  i;
+	struct l_wait_info lwi;
+	int rc;
+	int i;
 
 	/* All history will be culled when the next request buffer is
 	 * freed in ptlrpc_service_purge_all() */
@@ -2927,11 +2927,11 @@ ptlrpc_service_unlink_rqbd(struct ptlrpc_service *svc)
 static void
 ptlrpc_service_purge_all(struct ptlrpc_service *svc)
 {
-	struct ptlrpc_service_part		*svcpt;
-	struct ptlrpc_request_buffer_desc	*rqbd;
-	struct ptlrpc_request			*req;
-	struct ptlrpc_reply_state		*rs;
-	int					i;
+	struct ptlrpc_service_part *svcpt;
+	struct ptlrpc_request_buffer_desc *rqbd;
+	struct ptlrpc_request *req;
+	struct ptlrpc_reply_state *rs;
+	int i;
 
 	ptlrpc_service_for_each_part(svcpt, i, svc) {
 		if (svcpt->scp_service == NULL)
@@ -2995,9 +2995,9 @@ ptlrpc_service_purge_all(struct ptlrpc_service *svc)
 static void
 ptlrpc_service_free(struct ptlrpc_service *svc)
 {
-	struct ptlrpc_service_part	*svcpt;
-	struct ptlrpc_at_array		*array;
-	int				i;
+	struct ptlrpc_service_part *svcpt;
+	struct ptlrpc_at_array *array;
+	int i;
 
 	ptlrpc_service_for_each_part(svcpt, i, svc) {
 		if (svcpt->scp_service == NULL)
@@ -3056,9 +3056,9 @@ EXPORT_SYMBOL(ptlrpc_unregister_service);
  * to be shot, so it's intentionally non-aggressive. */
 int ptlrpc_svcpt_health_check(struct ptlrpc_service_part *svcpt)
 {
-	struct ptlrpc_request		*request = NULL;
-	struct timeval			right_now;
-	long				timediff;
+	struct ptlrpc_request *request = NULL;
+	struct timeval right_now;
+	long timediff;
 
 	do_gettimeofday(&right_now);
 
@@ -3090,8 +3090,8 @@ int ptlrpc_svcpt_health_check(struct ptlrpc_service_part *svcpt)
 int
 ptlrpc_service_health_check(struct ptlrpc_service *svc)
 {
-	struct ptlrpc_service_part	*svcpt;
-	int				i;
+	struct ptlrpc_service_part *svcpt;
+	int i;
 
 	if (svc == NULL)
 		return 0;
-- 
1.7.1
