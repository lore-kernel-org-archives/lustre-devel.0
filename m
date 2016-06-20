From: Oleg Drokin <green@linuxhacker.ru>
Date: Sun, 19 Jun 2016 22:07:22 -0400
Subject: [lustre-devel] [PATCH 07/28] staging/lustre/ptlrpc: reorganize
	ptlrpc_request
In-Reply-To: <1466388463-1817551-1-git-send-email-green@linuxhacker.ru>
References: <1466388463-1817551-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1466388463-1817551-8-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Liang Zhen <liang.zhen@intel.com>, Oleg Drokin <green@linuxhacker.ru>

From: Liang Zhen <liang.zhen@intel.com>

ptlrpc_request has some structure members are only for client side,
and some others are only for server side, this patch moved these
members to different structure then putting into an union.

By doing this, size of ptlrpc_request is decreased about 300 bytes,
besides saving memory, it also can reduce memory footprint while
processing.

Signed-off-by: Liang Zhen <liang.zhen@intel.com>
Reviewed-on: http://review.whamcloud.com/8806
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-181
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Bobi Jam <bobijam@gmail.com>
Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/include/lustre_net.h | 341 ++++++++++++---------
 drivers/staging/lustre/lustre/ptlrpc/client.c      |  49 +--
 drivers/staging/lustre/lustre/ptlrpc/events.c      |   5 +-
 drivers/staging/lustre/lustre/ptlrpc/niobuf.c      |   2 +-
 .../staging/lustre/lustre/ptlrpc/ptlrpc_internal.h |  34 ++
 drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c     |   4 +-
 drivers/staging/lustre/lustre/ptlrpc/sec.c         |   9 +-
 7 files changed, 255 insertions(+), 189 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_net.h b/drivers/staging/lustre/lustre/include/lustre_net.h
index dba4d1d..5968c3c 100644
--- a/drivers/staging/lustre/lustre/include/lustre_net.h
+++ b/drivers/staging/lustre/lustre/include/lustre_net.h
@@ -266,6 +266,11 @@
 /* Macro to hide a typecast. */
 #define ptlrpc_req_async_args(req) ((void *)&req->rq_async_args)
 
+struct ptlrpc_replay_async_args {
+	int		praa_old_state;
+	int		praa_old_status;
+};
+
 /**
  * Structure to single define portal connection.
  */
@@ -1243,22 +1248,100 @@ struct ptlrpc_hpreq_ops {
 	void (*hpreq_fini)(struct ptlrpc_request *);
 };
 
-/**
- * Represents remote procedure call.
- *
- * This is a staple structure used by everybody wanting to send a request
- * in Lustre.
- */
-struct ptlrpc_request {
-	/* Request type: one of PTL_RPC_MSG_* */
-	int rq_type;
-	/** Result of request processing */
-	int rq_status;
+struct ptlrpc_cli_req {
+	/** For bulk requests on client only: bulk descriptor */
+	struct ptlrpc_bulk_desc		*cr_bulk;
+	/** optional time limit for send attempts */
+	long				 cr_delay_limit;
+	/** time request was first queued */
+	time_t				 cr_queued_time;
+	/** request sent timeval */
+	struct timespec64		 cr_sent_tv;
+	/** time for request really sent out */
+	time_t				 cr_sent_out;
+	/** when req reply unlink must finish. */
+	time_t				 cr_reply_deadline;
+	/** when req bulk unlink must finish. */
+	time_t				 cr_bulk_deadline;
+	/** Portal to which this request would be sent */
+	short				 cr_req_ptl;
+	/** Portal where to wait for reply and where reply would be sent */
+	short				 cr_rep_ptl;
+	/** request resending number */
+	unsigned int			 cr_resend_nr;
+	/** What was import generation when this request was sent */
+	int				 cr_imp_gen;
+	enum lustre_imp_state		 cr_send_state;
+	/** Per-request waitq introduced by bug 21938 for recovery waiting */
+	wait_queue_head_t		 cr_set_waitq;
+	/** Link item for request set lists */
+	struct list_head		 cr_set_chain;
+	/** link to waited ctx */
+	struct list_head		 cr_ctx_chain;
+
+	/** client's half ctx */
+	struct ptlrpc_cli_ctx		*cr_cli_ctx;
+	/** Link back to the request set */
+	struct ptlrpc_request_set	*cr_set;
+	/** outgoing request MD handle */
+	lnet_handle_md_t		 cr_req_md_h;
+	/** request-out callback parameter */
+	struct ptlrpc_cb_id		 cr_req_cbid;
+	/** incoming reply MD handle */
+	lnet_handle_md_t		 cr_reply_md_h;
+	wait_queue_head_t		 cr_reply_waitq;
+	/** reply callback parameter */
+	struct ptlrpc_cb_id		 cr_reply_cbid;
+	/** Async completion handler, called when reply is received */
+	ptlrpc_interpterer_t		 cr_reply_interp;
+	/** Async completion context */
+	union ptlrpc_async_args		 cr_async_args;
+	/** Opaq data for replay and commit callbacks. */
+	void				*cr_cb_data;
 	/**
-	 * Linkage item through which this request is included into
-	 * sending/delayed lists on client and into rqbd list on server
+	 * Commit callback, called when request is committed and about to be
+	 * freed.
 	 */
-	struct list_head rq_list;
+	void (*cr_commit_cb)(struct ptlrpc_request *);
+	/** Replay callback, called after request is replayed at recovery */
+	void (*cr_replay_cb)(struct ptlrpc_request *);
+};
+
+/** client request member alias */
+/* NB: these alias should NOT be used by any new code, instead they should
+ * be removed step by step to avoid potential abuse
+ */
+#define rq_bulk			rq_cli.cr_bulk
+#define rq_delay_limit		rq_cli.cr_delay_limit
+#define rq_queued_time		rq_cli.cr_queued_time
+#define rq_sent_tv		rq_cli.cr_sent_tv
+#define rq_real_sent		rq_cli.cr_sent_out
+#define rq_reply_deadline	rq_cli.cr_reply_deadline
+#define rq_bulk_deadline	rq_cli.cr_bulk_deadline
+#define rq_nr_resend		rq_cli.cr_resend_nr
+#define rq_request_portal	rq_cli.cr_req_ptl
+#define rq_reply_portal		rq_cli.cr_rep_ptl
+#define rq_import_generation	rq_cli.cr_imp_gen
+#define rq_send_state		rq_cli.cr_send_state
+#define rq_set_chain		rq_cli.cr_set_chain
+#define rq_ctx_chain		rq_cli.cr_ctx_chain
+#define rq_set			rq_cli.cr_set
+#define rq_set_waitq		rq_cli.cr_set_waitq
+#define rq_cli_ctx		rq_cli.cr_cli_ctx
+#define rq_req_md_h		rq_cli.cr_req_md_h
+#define rq_req_cbid		rq_cli.cr_req_cbid
+#define rq_reply_md_h		rq_cli.cr_reply_md_h
+#define rq_reply_waitq		rq_cli.cr_reply_waitq
+#define rq_reply_cbid		rq_cli.cr_reply_cbid
+#define rq_interpret_reply	rq_cli.cr_reply_interp
+#define rq_async_args		rq_cli.cr_async_args
+#define rq_cb_data		rq_cli.cr_cb_data
+#define rq_commit_cb		rq_cli.cr_commit_cb
+#define rq_replay_cb		rq_cli.cr_replay_cb
+
+struct ptlrpc_srv_req {
+	/** initial thread servicing this request */
+	struct ptlrpc_thread		*sr_svc_thread;
 	/**
 	 * Server side list of incoming unserved requests sorted by arrival
 	 * time.  Traversed from time to time to notice about to expire
@@ -1266,27 +1349,81 @@ struct ptlrpc_request {
 	 * know server is alive and well, just very busy to service their
 	 * requests in time
 	 */
-	struct list_head rq_timed_list;
-	/** server-side history, used for debugging purposes. */
-	struct list_head rq_history_list;
+	struct list_head		sr_timed_list;
 	/** server-side per-export list */
-	struct list_head rq_exp_list;
-	/** server-side hp handlers */
-	struct ptlrpc_hpreq_ops *rq_ops;
-
-	/** initial thread servicing this request */
-	struct ptlrpc_thread *rq_svc_thread;
-
+	struct list_head		sr_exp_list;
+	/** server-side history, used for debuging purposes. */
+	struct list_head		sr_hist_list;
 	/** history sequence # */
-	__u64 rq_history_seq;
+	__u64				sr_hist_seq;
+	/** the index of service's srv_at_array into which request is linked */
+	time_t				sr_at_index;
+	/** authed uid */
+	uid_t				sr_auth_uid;
+	/** authed uid mapped to */
+	uid_t				sr_auth_mapped_uid;
+	/** RPC is generated from what part of Lustre */
+	enum lustre_sec_part		sr_sp_from;
+	/** request session context */
+	struct lu_context		sr_ses;
 	/** \addtogroup  nrs
 	 * @{
 	 */
 	/** stub for NRS request */
-	struct ptlrpc_nrs_request rq_nrq;
+	struct ptlrpc_nrs_request	sr_nrq;
 	/** @} nrs */
-	/** the index of service's srv_at_array into which request is linked */
-	u32 rq_at_index;
+	/** request arrival time */
+	struct timespec64		sr_arrival_time;
+	/** server's half ctx */
+	struct ptlrpc_svc_ctx		*sr_svc_ctx;
+	/** (server side), pointed directly into req buffer */
+	struct ptlrpc_user_desc		*sr_user_desc;
+	/** separated reply state */
+	struct ptlrpc_reply_state	*sr_reply_state;
+	/** server-side hp handlers */
+	struct ptlrpc_hpreq_ops		*sr_ops;
+	/** incoming request buffer */
+	struct ptlrpc_request_buffer_desc *sr_rqbd;
+};
+
+/** server request member alias */
+/* NB: these alias should NOT be used by any new code, instead they should
+ * be removed step by step to avoid potential abuse
+ */
+#define rq_svc_thread		rq_srv.sr_svc_thread
+#define rq_timed_list		rq_srv.sr_timed_list
+#define rq_exp_list		rq_srv.sr_exp_list
+#define rq_history_list		rq_srv.sr_hist_list
+#define rq_history_seq		rq_srv.sr_hist_seq
+#define rq_at_index		rq_srv.sr_at_index
+#define rq_auth_uid		rq_srv.sr_auth_uid
+#define rq_auth_mapped_uid	rq_srv.sr_auth_mapped_uid
+#define rq_sp_from		rq_srv.sr_sp_from
+#define rq_session		rq_srv.sr_ses
+#define rq_nrq			rq_srv.sr_nrq
+#define rq_arrival_time		rq_srv.sr_arrival_time
+#define rq_reply_state		rq_srv.sr_reply_state
+#define rq_svc_ctx		rq_srv.sr_svc_ctx
+#define rq_user_desc		rq_srv.sr_user_desc
+#define rq_ops			rq_srv.sr_ops
+#define rq_rqbd			rq_srv.sr_rqbd
+
+/**
+ * Represents remote procedure call.
+ *
+ * This is a staple structure used by everybody wanting to send a request
+ * in Lustre.
+ */
+struct ptlrpc_request {
+	/* Request type: one of PTL_RPC_MSG_* */
+	int				 rq_type;
+	/** Result of request processing */
+	int				 rq_status;
+	/**
+	 * Linkage item through which this request is included into
+	 * sending/delayed lists on client and into rqbd list on server
+	 */
+	struct list_head		 rq_list;
 	/** Lock to protect request flags and some other important bits, like
 	 * rq_list
 	 */
@@ -1327,19 +1464,15 @@ struct ptlrpc_request {
 		/* bulk request, sent to server, but uncommitted */
 		rq_unstable:1;
 
-	unsigned int rq_nr_resend;
-
-	enum rq_phase rq_phase; /* one of RQ_PHASE_* */
-	enum rq_phase rq_next_phase; /* one of RQ_PHASE_* to be used next */
-	atomic_t rq_refcount; /* client-side refcount for SENT race,
-			       * server-side refcount for multiple replies
-			       */
-
-	/** Portal to which this request would be sent */
-	short rq_request_portal;  /* XXX FIXME bug 249 */
-	/** Portal where to wait for reply and where reply would be sent */
-	short rq_reply_portal;    /* XXX FIXME bug 249 */
-
+	/** one of RQ_PHASE_* */
+	enum rq_phase			rq_phase;
+	/** one of RQ_PHASE_* to be used next */
+	enum rq_phase			rq_next_phase;
+	/**
+	 * client-side refcount for SENT race, server-side refcount
+	 * for multiple replies
+	 */
+	atomic_t			rq_refcount;
 	/**
 	 * client-side:
 	 * !rq_truncate : # reply bytes actually received,
@@ -1350,6 +1483,8 @@ struct ptlrpc_request {
 	int rq_reqlen;
 	/** Reply length */
 	int rq_replen;
+	/** Pool if request is from preallocated list */
+	struct ptlrpc_request_pool     *rq_pool;
 	/** Request message - what client sent */
 	struct lustre_msg *rq_reqmsg;
 	/** Reply message - server response */
@@ -1362,19 +1497,20 @@ struct ptlrpc_request {
 	 * List item to for replay list. Not yet committed requests get linked
 	 * there.
 	 * Also see \a rq_replay comment above.
+	 * It's also link chain on obd_export::exp_req_replay_queue
 	 */
 	struct list_head rq_replay_list;
-
+	/** non-shared members for client & server request*/
+	union {
+		struct ptlrpc_cli_req    rq_cli;
+		struct ptlrpc_srv_req    rq_srv;
+	};
 	/**
 	 * security and encryption data
 	 * @{
 	 */
-	struct ptlrpc_cli_ctx   *rq_cli_ctx;     /**< client's half ctx */
-	struct ptlrpc_svc_ctx   *rq_svc_ctx;     /**< server's half ctx */
-	struct list_head	       rq_ctx_chain;   /**< link to waited ctx */
-
-	struct sptlrpc_flavor    rq_flvr;	/**< for client & server */
-	enum lustre_sec_part     rq_sp_from;
+	/** description of flavors for client & server */
+	struct sptlrpc_flavor		rq_flvr;
 
 	/* client/server security flags */
 	unsigned int
@@ -1393,19 +1529,15 @@ struct ptlrpc_request {
 				 rq_pack_bulk:1,
 				 /* doesn't expect reply FIXME */
 				 rq_no_reply:1,
-				 rq_pill_init:1;     /* pill initialized */
-
-	uid_t		    rq_auth_uid;	/* authed uid */
-	uid_t		    rq_auth_mapped_uid; /* authed uid mapped to */
-
-	/* (server side), pointed directly into req buffer */
-	struct ptlrpc_user_desc *rq_user_desc;
-
-	/* various buffer pointers */
-	struct lustre_msg       *rq_reqbuf;      /* req wrapper */
-	char		    *rq_repbuf;      /* rep buffer */
-	struct lustre_msg       *rq_repdata;     /* rep wrapper msg */
-	struct lustre_msg       *rq_clrbuf;      /* only in priv mode */
+				 rq_pill_init:1, /* pill initialized */
+				 rq_srv_req:1; /* server request */
+
+	/** various buffer pointers */
+	struct lustre_msg       *rq_reqbuf;	/**< req wrapper */
+	char			*rq_repbuf;	/**< rep buffer */
+	struct lustre_msg       *rq_repdata;	/**< rep wrapper msg */
+	/** only in priv mode */
+	struct lustre_msg       *rq_clrbuf;
 	int		      rq_reqbuf_len;  /* req wrapper buf len */
 	int		      rq_reqdata_len; /* req wrapper msg len */
 	int		      rq_repbuf_len;  /* rep buffer len */
@@ -1422,97 +1554,28 @@ struct ptlrpc_request {
 	__u32 rq_req_swab_mask;
 	__u32 rq_rep_swab_mask;
 
-	/** What was import generation when this request was sent */
-	int rq_import_generation;
-	enum lustre_imp_state rq_send_state;
-
 	/** how many early replies (for stats) */
 	int rq_early_count;
 
-	/** client+server request */
-	lnet_handle_md_t     rq_req_md_h;
-	struct ptlrpc_cb_id  rq_req_cbid;
-	/** optional time limit for send attempts */
-	long       rq_delay_limit;
-	/** time request was first queued */
-	unsigned long	   rq_queued_time;
-
-	/* server-side... */
-	/** request arrival time */
-	struct timespec64	rq_arrival_time;
-	/** separated reply state */
-	struct ptlrpc_reply_state *rq_reply_state;
-	/** incoming request buffer */
-	struct ptlrpc_request_buffer_desc *rq_rqbd;
-
-	/** client-only incoming reply */
-	lnet_handle_md_t     rq_reply_md_h;
-	wait_queue_head_t	  rq_reply_waitq;
-	struct ptlrpc_cb_id  rq_reply_cbid;
-
+	/** Server-side, export on which request was received */
+	struct obd_export		*rq_export;
+	/** import where request is being sent */
+	struct obd_import		*rq_import;
 	/** our LNet NID */
 	lnet_nid_t	   rq_self;
 	/** Peer description (the other side) */
 	lnet_process_id_t    rq_peer;
-	/** Server-side, export on which request was received */
-	struct obd_export   *rq_export;
-	/** Client side, import where request is being sent */
-	struct obd_import   *rq_import;
-
-	/** Replay callback, called after request is replayed@recovery */
-	void (*rq_replay_cb)(struct ptlrpc_request *);
 	/**
-	 * Commit callback, called when request is committed and about to be
-	 * freed.
+	 * service time estimate (secs)
+	 * If the request is not served by this time, it is marked as timed out.
 	 */
-	void (*rq_commit_cb)(struct ptlrpc_request *);
-	/** Opaq data for replay and commit callbacks. */
-	void  *rq_cb_data;
-
-	/** For bulk requests on client only: bulk descriptor */
-	struct ptlrpc_bulk_desc *rq_bulk;
-
-	/** client outgoing req */
+	int			rq_timeout;
 	/**
 	 * when request/reply sent (secs), or time when request should be sent
 	 */
 	time64_t rq_sent;
-	/** time for request really sent out */
-	time64_t rq_real_sent;
-
-	/** when request must finish. volatile
-	 * so that servers' early reply updates to the deadline aren't
-	 * kept in per-cpu cache
-	 */
-	volatile time64_t rq_deadline;
-	/** when req reply unlink must finish. */
-	time64_t rq_reply_deadline;
-	/** when req bulk unlink must finish. */
-	time64_t rq_bulk_deadline;
-	/**
-	 * service time estimate (secs)
-	 * If the requestsis not served by this time, it is marked as timed out.
-	 */
-	int    rq_timeout;
-
-	/** Multi-rpc bits */
-	/** Per-request waitq introduced by bug 21938 for recovery waiting */
-	wait_queue_head_t rq_set_waitq;
-	/** Link item for request set lists */
-	struct list_head  rq_set_chain;
-	/** Link back to the request set */
-	struct ptlrpc_request_set *rq_set;
-	/** Async completion handler, called when reply is received */
-	ptlrpc_interpterer_t rq_interpret_reply;
-	/** Async completion context */
-	union ptlrpc_async_args rq_async_args;
-
-	/** Pool if request is from preallocated list */
-	struct ptlrpc_request_pool *rq_pool;
-
-	struct lu_context	   rq_session;
-	struct lu_context	   rq_recov_session;
-
+	/** when request must finish. */
+	time64_t		  rq_deadline;
 	/** request format description */
 	struct req_capsule	  rq_pill;
 };
diff --git a/drivers/staging/lustre/lustre/ptlrpc/client.c b/drivers/staging/lustre/lustre/ptlrpc/client.c
index 22bf893..9abd469 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/client.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/client.c
@@ -611,7 +611,6 @@ static int __ptlrpc_request_bufs_pack(struct ptlrpc_request *request,
 	lustre_msg_add_version(request->rq_reqmsg, version);
 	request->rq_send_state = LUSTRE_IMP_FULL;
 	request->rq_type = PTL_RPC_MSG_REQUEST;
-	request->rq_export = NULL;
 
 	request->rq_req_cbid.cbid_fn = request_out_callback;
 	request->rq_req_cbid.cbid_arg = request;
@@ -628,19 +627,7 @@ static int __ptlrpc_request_bufs_pack(struct ptlrpc_request *request,
 
 	ptlrpc_at_set_req_timeout(request);
 
-	spin_lock_init(&request->rq_lock);
-	INIT_LIST_HEAD(&request->rq_list);
-	INIT_LIST_HEAD(&request->rq_timed_list);
-	INIT_LIST_HEAD(&request->rq_replay_list);
-	INIT_LIST_HEAD(&request->rq_ctx_chain);
-	INIT_LIST_HEAD(&request->rq_set_chain);
-	INIT_LIST_HEAD(&request->rq_history_list);
-	INIT_LIST_HEAD(&request->rq_exp_list);
-	init_waitqueue_head(&request->rq_reply_waitq);
-	init_waitqueue_head(&request->rq_set_waitq);
 	request->rq_xid = ptlrpc_next_xid();
-	atomic_set(&request->rq_refcount, 1);
-
 	lustre_msg_set_opc(request->rq_reqmsg, opcode);
 
 	return 0;
@@ -718,7 +705,9 @@ struct ptlrpc_request *__ptlrpc_request_alloc(struct obd_import *imp,
 		request = ptlrpc_prep_req_from_pool(pool);
 
 	if (request) {
-		LASSERTF((unsigned long)imp > 0x1000, "%p\n", imp);
+		ptlrpc_cli_req_init(request);
+
+		LASSERTF((unsigned long)imp > 0x1000, "%p", imp);
 		LASSERT(imp != LP_POISON);
 		LASSERTF((unsigned long)imp->imp_client > 0x1000, "%p\n",
 			 imp->imp_client);
@@ -1235,8 +1224,9 @@ static int after_reply(struct ptlrpc_request *req)
 	}
 
 	ktime_get_real_ts64(&work_start);
-	timediff = (work_start.tv_sec - req->rq_arrival_time.tv_sec) * USEC_PER_SEC +
-		   (work_start.tv_nsec - req->rq_arrival_time.tv_nsec) / NSEC_PER_USEC;
+	timediff = (work_start.tv_sec - req->rq_sent_tv.tv_sec) * USEC_PER_SEC +
+		   (work_start.tv_nsec - req->rq_sent_tv.tv_nsec) /
+								 NSEC_PER_USEC;
 	if (obd->obd_svc_stats) {
 		lprocfs_counter_add(obd->obd_svc_stats, PTLRPC_REQWAIT_CNTR,
 				    timediff);
@@ -2191,11 +2181,11 @@ static void __ptlrpc_free_req(struct ptlrpc_request *request, int locked)
 {
 	if (!request)
 		return;
+	LASSERT(!request->rq_srv_req);
+	LASSERT(!request->rq_export);
 	LASSERTF(!request->rq_receiving_reply, "req %p\n", request);
-	LASSERTF(!request->rq_rqbd, "req %p\n", request);/* client-side */
 	LASSERTF(list_empty(&request->rq_list), "req %p\n", request);
 	LASSERTF(list_empty(&request->rq_set_chain), "req %p\n", request);
-	LASSERTF(list_empty(&request->rq_exp_list), "req %p\n", request);
 	LASSERTF(!request->rq_replay, "req %p\n", request);
 
 	req_capsule_fini(&request->rq_pill);
@@ -2221,10 +2211,7 @@ static void __ptlrpc_free_req(struct ptlrpc_request *request, int locked)
 
 	if (request->rq_repbuf)
 		sptlrpc_cli_free_repbuf(request);
-	if (request->rq_export) {
-		class_export_put(request->rq_export);
-		request->rq_export = NULL;
-	}
+
 	if (request->rq_import) {
 		class_import_put(request->rq_import);
 		request->rq_import = NULL;
@@ -2614,11 +2601,6 @@ int ptlrpc_queue_wait(struct ptlrpc_request *req)
 }
 EXPORT_SYMBOL(ptlrpc_queue_wait);
 
-struct ptlrpc_replay_async_args {
-	int praa_old_state;
-	int praa_old_status;
-};
-
 /**
  * Callback used for replayed requests reply processing.
  * In case of successful reply calls registered request replay callback.
@@ -3013,10 +2995,11 @@ void *ptlrpcd_alloc_work(struct obd_import *imp,
 		return ERR_PTR(-ENOMEM);
 	}
 
+	ptlrpc_cli_req_init(req);
+
 	req->rq_send_state = LUSTRE_IMP_FULL;
 	req->rq_type = PTL_RPC_MSG_REQUEST;
 	req->rq_import = class_import_get(imp);
-	req->rq_export = NULL;
 	req->rq_interpret_reply = work_interpreter;
 	/* don't want reply */
 	req->rq_receiving_reply = 0;
@@ -3026,16 +3009,6 @@ void *ptlrpcd_alloc_work(struct obd_import *imp,
 	req->rq_no_resend = 1;
 	req->rq_pill.rc_fmt = (void *)&worker_format;
 
-	spin_lock_init(&req->rq_lock);
-	INIT_LIST_HEAD(&req->rq_list);
-	INIT_LIST_HEAD(&req->rq_replay_list);
-	INIT_LIST_HEAD(&req->rq_set_chain);
-	INIT_LIST_HEAD(&req->rq_history_list);
-	INIT_LIST_HEAD(&req->rq_exp_list);
-	init_waitqueue_head(&req->rq_reply_waitq);
-	init_waitqueue_head(&req->rq_set_waitq);
-	atomic_set(&req->rq_refcount, 1);
-
 	CLASSERT(sizeof(*args) <= sizeof(req->rq_async_args));
 	args = ptlrpc_req_async_args(req);
 	args->cb = cb;
diff --git a/drivers/staging/lustre/lustre/ptlrpc/events.c b/drivers/staging/lustre/lustre/ptlrpc/events.c
index b8ca7d6..95be4aa 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/events.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/events.c
@@ -324,6 +324,7 @@ void request_in_callback(lnet_event_t *ev)
 		}
 	}
 
+	ptlrpc_srv_req_init(req);
 	/* NB we ABSOLUTELY RELY on req being zeroed, so pointers are NULL,
 	 * flags are reset and scalars are zero.  We only set the message
 	 * size to non-zero if this was a successful receive.
@@ -337,10 +338,6 @@ void request_in_callback(lnet_event_t *ev)
 	req->rq_self = ev->target.nid;
 	req->rq_rqbd = rqbd;
 	req->rq_phase = RQ_PHASE_NEW;
-	spin_lock_init(&req->rq_lock);
-	INIT_LIST_HEAD(&req->rq_timed_list);
-	INIT_LIST_HEAD(&req->rq_exp_list);
-	atomic_set(&req->rq_refcount, 1);
 	if (ev->type == LNET_EVENT_PUT)
 		CDEBUG(D_INFO, "incoming req@%p x%llu msgsize %u\n",
 		       req, req->rq_xid, ev->mlength);
diff --git a/drivers/staging/lustre/lustre/ptlrpc/niobuf.c b/drivers/staging/lustre/lustre/ptlrpc/niobuf.c
index ff9a95c..4e7d68f 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/niobuf.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/niobuf.c
@@ -633,7 +633,7 @@ int ptl_send_rpc(struct ptlrpc_request *request, int noreply)
 
 	OBD_FAIL_TIMEOUT(OBD_FAIL_PTLRPC_DELAY_SEND, request->rq_timeout + 5);
 
-	ktime_get_real_ts64(&request->rq_arrival_time);
+	ktime_get_real_ts64(&request->rq_sent_tv);
 	request->rq_sent = ktime_get_real_seconds();
 	/* We give the server rq_timeout secs to process the req, and
 	 * add the network latency for our local timeout.
diff --git a/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_internal.h b/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_internal.h
index 97e97e2..d3674cb 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_internal.h
+++ b/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_internal.h
@@ -288,4 +288,38 @@ static inline void ptlrpc_reqset_put(struct ptlrpc_request_set *set)
 	if (atomic_dec_and_test(&set->set_refcount))
 		kfree(set);
 }
+
+/** initialise ptlrpc common fields */
+static inline void ptlrpc_req_comm_init(struct ptlrpc_request *req)
+{
+	spin_lock_init(&req->rq_lock);
+	atomic_set(&req->rq_refcount, 1);
+	INIT_LIST_HEAD(&req->rq_list);
+	INIT_LIST_HEAD(&req->rq_replay_list);
+}
+
+/** initialise client side ptlrpc request */
+static inline void ptlrpc_cli_req_init(struct ptlrpc_request *req)
+{
+	struct ptlrpc_cli_req *cr = &req->rq_cli;
+
+	ptlrpc_req_comm_init(req);
+	INIT_LIST_HEAD(&cr->cr_set_chain);
+	INIT_LIST_HEAD(&cr->cr_ctx_chain);
+	init_waitqueue_head(&cr->cr_reply_waitq);
+	init_waitqueue_head(&cr->cr_set_waitq);
+}
+
+/** initialise server side ptlrpc request */
+static inline void ptlrpc_srv_req_init(struct ptlrpc_request *req)
+{
+	struct ptlrpc_srv_req *sr = &req->rq_srv;
+
+	ptlrpc_req_comm_init(req);
+	req->rq_srv_req = 1;
+	INIT_LIST_HEAD(&sr->sr_exp_list);
+	INIT_LIST_HEAD(&sr->sr_timed_list);
+	INIT_LIST_HEAD(&sr->sr_hist_list);
+}
+
 #endif /* PTLRPC_INTERNAL_H */
diff --git a/drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c b/drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c
index b0cf585..0a374b6 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c
@@ -157,9 +157,9 @@ static int ptlrpcd_users;
 
 void ptlrpcd_wake(struct ptlrpc_request *req)
 {
-	struct ptlrpc_request_set *rq_set = req->rq_set;
+	struct ptlrpc_request_set *set = req->rq_set;
 
-	wake_up(&rq_set->set_waitq);
+	wake_up(&set->set_waitq);
 }
 EXPORT_SYMBOL(ptlrpcd_wake);
 
diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec.c b/drivers/staging/lustre/lustre/ptlrpc/sec.c
index f3b4773..dbd819f 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/sec.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/sec.c
@@ -863,11 +863,9 @@ int sptlrpc_import_check_ctx(struct obd_import *imp)
 	if (!req)
 		return -ENOMEM;
 
-	spin_lock_init(&req->rq_lock);
+	ptlrpc_cli_req_init(req);
 	atomic_set(&req->rq_refcount, 10000);
-	INIT_LIST_HEAD(&req->rq_ctx_chain);
-	init_waitqueue_head(&req->rq_reply_waitq);
-	init_waitqueue_head(&req->rq_set_waitq);
+
 	req->rq_import = imp;
 	req->rq_flvr = sec->ps_flvr;
 	req->rq_cli_ctx = ctx;
@@ -1047,6 +1045,8 @@ int sptlrpc_cli_unwrap_early_reply(struct ptlrpc_request *req,
 	if (!early_req)
 		return -ENOMEM;
 
+	ptlrpc_cli_req_init(early_req);
+
 	early_size = req->rq_nob_received;
 	early_bufsz = size_roundup_power2(early_size);
 	early_buf = libcfs_kvzalloc(early_bufsz, GFP_NOFS);
@@ -1095,7 +1095,6 @@ int sptlrpc_cli_unwrap_early_reply(struct ptlrpc_request *req,
 	memcpy(early_buf, req->rq_repbuf, early_size);
 	spin_unlock(&req->rq_lock);
 
-	spin_lock_init(&early_req->rq_lock);
 	early_req->rq_cli_ctx = sptlrpc_cli_ctx_get(req->rq_cli_ctx);
 	early_req->rq_flvr = req->rq_flvr;
 	early_req->rq_repbuf = early_buf;
-- 
2.7.4
