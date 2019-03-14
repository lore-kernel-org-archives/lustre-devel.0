From: NeilBrown <neilb@suse.com>
Date: Thu, 14 Mar 2019 11:11:49 +1100
Subject: [lustre-devel] [PATCH 11/32] lustre: lnet: don't embed whole
 lnet_md in lnet_event
In-Reply-To: <155252182126.26912.1842463462595601611.stgit@noble.brown>
References: <155252182126.26912.1842463462595601611.stgit@noble.brown>
Message-ID: <155252230973.26912.12212435530719753134.stgit@noble.brown>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Of the several fields that are copied into the lnet_md which is
embedded in an lnet_event, only three are ever used:
  start, user_ptr, md_options

Rather than allocating space for the whole structure, copying only
some in, and then using even few; just store the fields that are
needed.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../staging/lustre/include/linux/lnet/lib-lnet.h   |    2 +-
 .../lustre/include/uapi/linux/lnet/lnet-types.h    |    9 +++++---
 drivers/staging/lustre/lnet/lnet/api-ni.c          |    4 ++--
 drivers/staging/lustre/lnet/lnet/lib-md.c          |   19 ++++-------------
 drivers/staging/lustre/lnet/lnet/lib-msg.c         |    4 ++--
 drivers/staging/lustre/lnet/lnet/peer.c            |   10 +++++----
 drivers/staging/lustre/lnet/lnet/router.c          |    2 +-
 drivers/staging/lustre/lnet/selftest/rpc.c         |    5 +++--
 drivers/staging/lustre/lustre/ptlrpc/events.c      |   22 ++++++++++----------
 9 files changed, 34 insertions(+), 43 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
index c6a9a5fb3c96..7275d517df5a 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
@@ -628,7 +628,7 @@ void lnet_copy_kiov2iter(struct iov_iter *to,
 void lnet_me_unlink(struct lnet_me *me);
 
 void lnet_md_unlink(struct lnet_libmd *md);
-void lnet_md_deconstruct(struct lnet_libmd *lmd, struct lnet_md *umd);
+void lnet_md_deconstruct(struct lnet_libmd *lmd, struct lnet_event *ev);
 struct page *lnet_kvaddr_to_page(unsigned long vaddr);
 int lnet_cpt_of_md(struct lnet_libmd *md, unsigned int offset);
 
diff --git a/drivers/staging/lustre/include/uapi/linux/lnet/lnet-types.h b/drivers/staging/lustre/include/uapi/linux/lnet/lnet-types.h
index e66f8861ecf0..9e6baf3058fe 100644
--- a/drivers/staging/lustre/include/uapi/linux/lnet/lnet-types.h
+++ b/drivers/staging/lustre/include/uapi/linux/lnet/lnet-types.h
@@ -624,11 +624,12 @@ struct lnet_event {
 	 */
 	struct lnet_handle_md	md_handle;
 	/**
-	 * A snapshot of the state of the MD immediately after the event has
-	 * been processed. In particular, the threshold field in md will
-	 * reflect the value of the threshold after the operation occurred.
+	 * A snapshot of relevant state of the MD immediately after the event
+	 * has been processed.
 	 */
-	struct lnet_md		md;
+	void			*md_start;
+	void			*md_user_ptr;
+	unsigned int		md_options;
 	/**
 	 * 64 bits of out-of-band user data. Only valid for LNET_EVENT_PUT.
 	 * \see LNetPut
diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
index 12b3c4445905..13a874e630fe 100644
--- a/drivers/staging/lustre/lnet/lnet/api-ni.c
+++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
@@ -1135,7 +1135,7 @@ lnet_ping_target_destroy(void)
 static void
 lnet_ping_target_event_handler(struct lnet_event *event)
 {
-	struct lnet_ping_buffer *pbuf = event->md.user_ptr;
+	struct lnet_ping_buffer *pbuf = event->md_user_ptr;
 
 	if (event->unlinked)
 		lnet_ping_buffer_decref(pbuf);
@@ -1404,7 +1404,7 @@ int lnet_push_target_resize(void)
 
 static void lnet_push_target_event_handler(struct lnet_event *ev)
 {
-	struct lnet_ping_buffer *pbuf = ev->md.user_ptr;
+	struct lnet_ping_buffer *pbuf = ev->md_user_ptr;
 
 	if (pbuf->pb_info.pi_magic == __swab32(LNET_PROTO_PING_MAGIC))
 		lnet_swap_pinginfo(pbuf);
diff --git a/drivers/staging/lustre/lnet/lnet/lib-md.c b/drivers/staging/lustre/lnet/lnet/lib-md.c
index acc6b239d391..fdca4655206e 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-md.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-md.c
@@ -268,22 +268,11 @@ lnet_md_link(struct lnet_libmd *md, struct lnet_handle_eq eq_handle, int cpt)
 
 /* must be called with lnet_res_lock held */
 void
-lnet_md_deconstruct(struct lnet_libmd *lmd, struct lnet_md *umd)
+lnet_md_deconstruct(struct lnet_libmd *lmd, struct lnet_event *ev)
 {
-	/* NB this doesn't copy out all the iov entries so when a
-	 * discontiguous MD is copied out, the target gets to know the
-	 * original iov pointer (in start) and the number of entries it had
-	 * and that's all.
-	 */
-	umd->start = lmd->md_start;
-	umd->length = !(lmd->md_options &
-			LNET_MD_KIOV) ?
-		      lmd->md_length : lmd->md_niov;
-	umd->threshold = lmd->md_threshold;
-	umd->max_size = lmd->md_max_size;
-	umd->options = lmd->md_options;
-	umd->user_ptr = lmd->md_user_ptr;
-	lnet_eq2handle(&umd->eq_handle, lmd->md_eq);
+	ev->md_start = lmd->md_start;
+	ev->md_options = lmd->md_options;
+	ev->md_user_ptr = lmd->md_user_ptr;
 }
 
 static int
diff --git a/drivers/staging/lustre/lnet/lnet/lib-msg.c b/drivers/staging/lustre/lnet/lnet/lib-msg.c
index 02620fe2a0fa..a5f3aa4c9561 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-msg.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-msg.c
@@ -47,7 +47,7 @@ lnet_build_unlink_event(struct lnet_libmd *md, struct lnet_event *ev)
 	ev->status = 0;
 	ev->unlinked = 1;
 	ev->type = LNET_EVENT_UNLINK;
-	lnet_md_deconstruct(md, &ev->md);
+	lnet_md_deconstruct(md, ev);
 	lnet_md2handle(&ev->md_handle, md);
 }
 
@@ -360,7 +360,7 @@ lnet_msg_attach_md(struct lnet_msg *msg, struct lnet_libmd *md,
 
 	/* build umd in event */
 	lnet_md2handle(&msg->msg_ev.md_handle, md);
-	lnet_md_deconstruct(md, &msg->msg_ev.md);
+	lnet_md_deconstruct(md, &msg->msg_ev);
 }
 
 void
diff --git a/drivers/staging/lustre/lnet/lnet/peer.c b/drivers/staging/lustre/lnet/lnet/peer.c
index ade7f23b3bf4..3938e741a7a0 100644
--- a/drivers/staging/lustre/lnet/lnet/peer.c
+++ b/drivers/staging/lustre/lnet/lnet/peer.c
@@ -1774,7 +1774,7 @@ static void lnet_peer_discovery_complete(struct lnet_peer *lp)
  */
 void lnet_peer_push_event(struct lnet_event *ev)
 {
-	struct lnet_ping_buffer *pbuf = ev->md.user_ptr;
+	struct lnet_ping_buffer *pbuf = ev->md_user_ptr;
 	struct lnet_peer *lp;
 
 	/* lnet_find_peer() adds a refcount */
@@ -2059,7 +2059,7 @@ lnet_discovery_event_ack(struct lnet_peer *lp, struct lnet_event *ev)
 {
 	struct lnet_ping_buffer *pbuf;
 
-	pbuf = LNET_PING_INFO_TO_BUFFER(ev->md.start);
+	pbuf = LNET_PING_INFO_TO_BUFFER(ev->md_start);
 	spin_lock(&lp->lp_lock);
 	lp->lp_state &= ~LNET_PEER_PUSH_SENT;
 	lp->lp_push_error = ev->status;
@@ -2096,7 +2096,7 @@ lnet_discovery_event_reply(struct lnet_peer *lp, struct lnet_event *ev)
 		goto out;
 	}
 
-	pbuf = LNET_PING_INFO_TO_BUFFER(ev->md.start);
+	pbuf = LNET_PING_INFO_TO_BUFFER(ev->md_start);
 	if (pbuf->pb_info.pi_magic == __swab32(LNET_PROTO_PING_MAGIC))
 		lnet_swap_pinginfo(pbuf);
 
@@ -2278,7 +2278,7 @@ lnet_discovery_event_unlink(struct lnet_peer *lp, struct lnet_event *ev)
  */
 static void lnet_discovery_event_handler(struct lnet_event *event)
 {
-	struct lnet_peer *lp = event->md.user_ptr;
+	struct lnet_peer *lp = event->md_user_ptr;
 	struct lnet_ping_buffer *pbuf;
 	int rc;
 
@@ -2308,7 +2308,7 @@ static void lnet_discovery_event_handler(struct lnet_event *event)
 	}
 	lnet_net_lock(LNET_LOCK_EX);
 	if (event->unlinked) {
-		pbuf = LNET_PING_INFO_TO_BUFFER(event->md.start);
+		pbuf = LNET_PING_INFO_TO_BUFFER(event->md_start);
 		lnet_ping_buffer_decref(pbuf);
 		lnet_peer_decref_locked(lp);
 	}
diff --git a/drivers/staging/lustre/lnet/lnet/router.c b/drivers/staging/lustre/lnet/lnet/router.c
index bcde61d2a984..31481b4a7ed3 100644
--- a/drivers/staging/lustre/lnet/lnet/router.c
+++ b/drivers/staging/lustre/lnet/lnet/router.c
@@ -748,7 +748,7 @@ lnet_parse_rc_info(struct lnet_rc_data *rcd)
 static void
 lnet_router_checker_event(struct lnet_event *event)
 {
-	struct lnet_rc_data *rcd = event->md.user_ptr;
+	struct lnet_rc_data *rcd = event->md_user_ptr;
 	struct lnet_peer_ni *lp;
 
 	LASSERT(rcd);
diff --git a/drivers/staging/lustre/lnet/selftest/rpc.c b/drivers/staging/lustre/lnet/selftest/rpc.c
index abb6f8fb011e..6dc80ec07c4c 100644
--- a/drivers/staging/lustre/lnet/selftest/rpc.c
+++ b/drivers/staging/lustre/lnet/selftest/rpc.c
@@ -1403,7 +1403,7 @@ static void
 srpc_lnet_ev_handler(struct lnet_event *ev)
 {
 	struct srpc_service_cd *scd;
-	struct srpc_event *rpcev = ev->md.user_ptr;
+	struct srpc_event *rpcev = ev->md_user_ptr;
 	struct srpc_client_rpc *crpc;
 	struct srpc_server_rpc *srpc;
 	struct srpc_buffer *buffer;
@@ -1480,7 +1480,8 @@ srpc_lnet_ev_handler(struct lnet_event *ev)
 		LASSERT(ev->type != LNET_EVENT_UNLINK ||
 			sv->sv_shuttingdown);
 
-		buffer = container_of(ev->md.start, struct srpc_buffer, buf_msg);
+		buffer = container_of(ev->md_start, struct srpc_buffer,
+				      buf_msg);
 		buffer->buf_peer = ev->source;
 		buffer->buf_self = ev->target.nid;
 
diff --git a/drivers/staging/lustre/lustre/ptlrpc/events.c b/drivers/staging/lustre/lustre/ptlrpc/events.c
index 0c16a2c9d2ed..5bb5fb2b7354 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/events.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/events.c
@@ -50,7 +50,7 @@ struct lnet_handle_eq ptlrpc_eq_h;
  */
 void request_out_callback(struct lnet_event *ev)
 {
-	struct ptlrpc_cb_id *cbid = ev->md.user_ptr;
+	struct ptlrpc_cb_id *cbid = ev->md_user_ptr;
 	struct ptlrpc_request *req = cbid->cbid_arg;
 	bool wakeup = false;
 
@@ -89,18 +89,18 @@ void request_out_callback(struct lnet_event *ev)
  */
 void reply_in_callback(struct lnet_event *ev)
 {
-	struct ptlrpc_cb_id *cbid = ev->md.user_ptr;
+	struct ptlrpc_cb_id *cbid = ev->md_user_ptr;
 	struct ptlrpc_request *req = cbid->cbid_arg;
 
 	DEBUG_REQ(D_NET, req, "type %d, status %d", ev->type, ev->status);
 
 	LASSERT(ev->type == LNET_EVENT_PUT || ev->type == LNET_EVENT_UNLINK);
-	LASSERT(ev->md.start == req->rq_repbuf);
+	LASSERT(ev->md_start == req->rq_repbuf);
 	LASSERT(ev->offset + ev->mlength <= req->rq_repbuf_len);
 	/* We've set LNET_MD_MANAGE_REMOTE for all outgoing requests
 	 * for adaptive timeouts' early reply.
 	 */
-	LASSERT((ev->md.options & LNET_MD_MANAGE_REMOTE) != 0);
+	LASSERT((ev->md_options & LNET_MD_MANAGE_REMOTE) != 0);
 
 	spin_lock(&req->rq_lock);
 
@@ -179,7 +179,7 @@ void reply_in_callback(struct lnet_event *ev)
  */
 void client_bulk_callback(struct lnet_event *ev)
 {
-	struct ptlrpc_cb_id *cbid = ev->md.user_ptr;
+	struct ptlrpc_cb_id *cbid = ev->md_user_ptr;
 	struct ptlrpc_bulk_desc *desc = cbid->cbid_arg;
 	struct ptlrpc_request *req;
 
@@ -292,7 +292,7 @@ static void ptlrpc_req_add_history(struct ptlrpc_service_part *svcpt,
  */
 void request_in_callback(struct lnet_event *ev)
 {
-	struct ptlrpc_cb_id *cbid = ev->md.user_ptr;
+	struct ptlrpc_cb_id *cbid = ev->md_user_ptr;
 	struct ptlrpc_request_buffer_desc *rqbd = cbid->cbid_arg;
 	struct ptlrpc_service_part *svcpt = rqbd->rqbd_svcpt;
 	struct ptlrpc_service *service = svcpt->scp_service;
@@ -300,8 +300,8 @@ void request_in_callback(struct lnet_event *ev)
 
 	LASSERT(ev->type == LNET_EVENT_PUT ||
 		ev->type == LNET_EVENT_UNLINK);
-	LASSERT((char *)ev->md.start >= rqbd->rqbd_buffer);
-	LASSERT((char *)ev->md.start + ev->offset + ev->mlength <=
+	LASSERT((char *)ev->md_start >= rqbd->rqbd_buffer);
+	LASSERT((char *)ev->md_start + ev->offset + ev->mlength <=
 		rqbd->rqbd_buffer + service->srv_buf_size);
 
 	CDEBUG((ev->status == 0) ? D_NET : D_ERROR,
@@ -338,7 +338,7 @@ void request_in_callback(struct lnet_event *ev)
 	 * size to non-zero if this was a successful receive.
 	 */
 	req->rq_xid = ev->match_bits;
-	req->rq_reqbuf = ev->md.start + ev->offset;
+	req->rq_reqbuf = ev->md_start + ev->offset;
 	if (ev->type == LNET_EVENT_PUT && ev->status == 0)
 		req->rq_reqdata_len = ev->mlength;
 	ktime_get_real_ts64(&req->rq_arrival_time);
@@ -395,7 +395,7 @@ void request_in_callback(struct lnet_event *ev)
  */
 void reply_out_callback(struct lnet_event *ev)
 {
-	struct ptlrpc_cb_id *cbid = ev->md.user_ptr;
+	struct ptlrpc_cb_id *cbid = ev->md_user_ptr;
 	struct ptlrpc_reply_state *rs = cbid->cbid_arg;
 	struct ptlrpc_service_part *svcpt = rs->rs_svcpt;
 
@@ -435,7 +435,7 @@ void reply_out_callback(struct lnet_event *ev)
 
 static void ptlrpc_master_callback(struct lnet_event *ev)
 {
-	struct ptlrpc_cb_id *cbid = ev->md.user_ptr;
+	struct ptlrpc_cb_id *cbid = ev->md_user_ptr;
 	void (*callback)(struct lnet_event *ev) = cbid->cbid_fn;
 
 	/* Honestly, it's best to find out early. */
