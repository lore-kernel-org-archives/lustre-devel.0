From: James Simmons <jsimmons@infradead.org>
Date: Sun, 26 Feb 2017 19:41:50 -0500
Subject: [lustre-devel] [PATCH 25/34] staging: lustre: lnet: change
	lnet_event_t to proper structure
In-Reply-To: <1488156119-19670-1-git-send-email-jsimmons@infradead.org>
References: <1488156119-19670-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1488156119-19670-26-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@yahoo.com>

Change lnet_event_t from typedef to proper structure.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-on: https://review.whamcloud.com/20831
Reviewed-by: Olaf Weber <olaf@sgi.com>
Reviewed-by: Doug Oucharek <doug.s.oucharek@intel.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/include/linux/lnet/api.h       |  4 ++--
 drivers/staging/lustre/include/linux/lnet/lib-lnet.h  |  4 ++--
 drivers/staging/lustre/include/linux/lnet/lib-types.h |  4 ++--
 drivers/staging/lustre/include/linux/lnet/types.h     |  6 +++---
 drivers/staging/lustre/lnet/lnet/api-ni.c             |  4 ++--
 drivers/staging/lustre/lnet/lnet/lib-eq.c             | 16 ++++++++--------
 drivers/staging/lustre/lnet/lnet/lib-md.c             |  2 +-
 drivers/staging/lustre/lnet/lnet/lib-me.c             |  2 +-
 drivers/staging/lustre/lnet/lnet/lib-move.c           |  2 +-
 drivers/staging/lustre/lnet/lnet/lib-msg.c            |  8 ++++----
 drivers/staging/lustre/lnet/lnet/router.c             |  2 +-
 drivers/staging/lustre/lnet/selftest/rpc.c            |  2 +-
 drivers/staging/lustre/lustre/include/lustre_net.h    | 12 ++++++------
 drivers/staging/lustre/lustre/ptlrpc/events.c         | 14 +++++++-------
 14 files changed, 41 insertions(+), 41 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/api.h b/drivers/staging/lustre/include/linux/lnet/api.h
index 8609206..b46a769 100644
--- a/drivers/staging/lustre/include/linux/lnet/api.h
+++ b/drivers/staging/lustre/include/linux/lnet/api.h
@@ -148,7 +148,7 @@ int LNetMDBind(struct lnet_md md_in,
  *
  * In addition to the lnet_handle_eq, the LNet API defines two types
  * associated with events: The ::lnet_event_kind_t defines the kinds of events
- * that can be stored in an EQ. The lnet_event_t defines a structure that
+ * that can be stored in an EQ. The lnet_event defines a structure that
  * holds the information about with an event.
  *
  * There are five functions for dealing with EQs: LNetEQAlloc() is used to
@@ -168,7 +168,7 @@ int LNetEQAlloc(unsigned int       count_in,
 int LNetEQPoll(struct lnet_handle_eq *eventqs_in,
 	       int		 neq_in,
 	       int		 timeout_ms,
-	       lnet_event_t     *event_out,
+	       struct lnet_event *event_out,
 	       int		*which_eq_out);
 /** @} lnet_eq */
 
diff --git a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
index a6cf5be..d770a03 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
@@ -485,12 +485,12 @@ int lnet_dyn_add_ni(lnet_pid_t requested_pid,
 void lnet_msg_attach_md(struct lnet_msg *msg, struct lnet_libmd *md,
 			unsigned int offset, unsigned int mlen);
 void lnet_msg_detach_md(struct lnet_msg *msg, int status);
-void lnet_build_unlink_event(struct lnet_libmd *md, lnet_event_t *ev);
+void lnet_build_unlink_event(struct lnet_libmd *md, struct lnet_event *ev);
 void lnet_build_msg_event(struct lnet_msg *msg, lnet_event_kind_t ev_type);
 void lnet_msg_commit(struct lnet_msg *msg, int cpt);
 void lnet_msg_decommit(struct lnet_msg *msg, int cpt, int status);
 
-void lnet_eq_enqueue_event(struct lnet_eq *eq, lnet_event_t *ev);
+void lnet_eq_enqueue_event(struct lnet_eq *eq, struct lnet_event *ev);
 void lnet_prep_send(struct lnet_msg *msg, int type, lnet_process_id_t target,
 		    unsigned int offset, unsigned int len);
 int lnet_send(lnet_nid_t nid, struct lnet_msg *msg, lnet_nid_t rtr_nid);
diff --git a/drivers/staging/lustre/include/linux/lnet/lib-types.h b/drivers/staging/lustre/include/linux/lnet/lib-types.h
index c98af93..808a05c 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-types.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-types.h
@@ -104,7 +104,7 @@ struct lnet_msg {
 	struct kvec		*msg_iov;
 	lnet_kiov_t		*msg_kiov;
 
-	lnet_event_t		 msg_ev;
+	struct lnet_event	 msg_ev;
 	struct lnet_hdr		 msg_hdr;
 };
 
@@ -123,7 +123,7 @@ struct lnet_eq {
 	lnet_seq_t		  eq_deq_seq;
 	unsigned int		  eq_size;
 	lnet_eq_handler_t	  eq_callback;
-	lnet_event_t		 *eq_events;
+	struct lnet_event	 *eq_events;
 	int			**eq_refs;	/* percpt refcount for EQ */
 };
 
diff --git a/drivers/staging/lustre/include/linux/lnet/types.h b/drivers/staging/lustre/include/linux/lnet/types.h
index bc3f3e3..53eb1da 100644
--- a/drivers/staging/lustre/include/linux/lnet/types.h
+++ b/drivers/staging/lustre/include/linux/lnet/types.h
@@ -568,7 +568,7 @@ struct lnet_md {
 /**
  * Information about an event on a MD.
  */
-typedef struct {
+struct lnet_event {
 	/** The identifier (nid, pid) of the target. */
 	lnet_process_id_t	target;
 	/** The identifier (nid, pid) of the initiator. */
@@ -635,7 +635,7 @@ struct lnet_md {
 	 * to each event.
 	 */
 	volatile lnet_seq_t	sequence;
-} lnet_event_t;
+};
 
 /**
  * Event queue handler function type.
@@ -647,7 +647,7 @@ struct lnet_md {
  * The handler must not block, must be reentrant, and must not call any LNet
  * API functions. It should return as quickly as possible.
  */
-typedef void (*lnet_eq_handler_t)(lnet_event_t *event);
+typedef void (*lnet_eq_handler_t)(struct lnet_event *event);
 #define LNET_EQ_HANDLER_NONE NULL
 /** @} lnet_eq */
 
diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
index 53c9427..1d2004f 100644
--- a/drivers/staging/lustre/lnet/lnet/api-ni.c
+++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
@@ -888,7 +888,7 @@ struct lnet_ni  *
 }
 
 static void
-lnet_ping_event_handler(lnet_event_t *event)
+lnet_ping_event_handler(struct lnet_event *event)
 {
 	struct lnet_ping_info *pinfo = event->md.user_ptr;
 
@@ -2133,7 +2133,7 @@ static int lnet_ping(lnet_process_id_t id, int timeout_ms,
 {
 	struct lnet_handle_eq eqh;
 	struct lnet_handle_md mdh;
-	lnet_event_t event;
+	struct lnet_event event;
 	struct lnet_md md = { NULL };
 	int which;
 	int unlinked = 0;
diff --git a/drivers/staging/lustre/lnet/lnet/lib-eq.c b/drivers/staging/lustre/lnet/lnet/lib-eq.c
index 4369df3..ce4b835 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-eq.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-eq.c
@@ -93,7 +93,7 @@
 		return -ENOMEM;
 
 	if (count) {
-		LIBCFS_ALLOC(eq->eq_events, count * sizeof(lnet_event_t));
+		LIBCFS_ALLOC(eq->eq_events, count * sizeof(struct lnet_event));
 		if (!eq->eq_events)
 			goto failed;
 		/*
@@ -131,7 +131,7 @@
 
 failed:
 	if (eq->eq_events)
-		LIBCFS_FREE(eq->eq_events, count * sizeof(lnet_event_t));
+		LIBCFS_FREE(eq->eq_events, count * sizeof(struct lnet_event));
 
 	if (eq->eq_refs)
 		cfs_percpt_free(eq->eq_refs);
@@ -155,7 +155,7 @@
 LNetEQFree(struct lnet_handle_eq eqh)
 {
 	struct lnet_eq *eq;
-	lnet_event_t *events = NULL;
+	struct lnet_event *events = NULL;
 	int **refs = NULL;
 	int *ref;
 	int rc = 0;
@@ -201,7 +201,7 @@
 	lnet_res_unlock(LNET_LOCK_EX);
 
 	if (events)
-		LIBCFS_FREE(events, size * sizeof(lnet_event_t));
+		LIBCFS_FREE(events, size * sizeof(struct lnet_event));
 	if (refs)
 		cfs_percpt_free(refs);
 
@@ -210,7 +210,7 @@
 EXPORT_SYMBOL(LNetEQFree);
 
 void
-lnet_eq_enqueue_event(struct lnet_eq *eq, lnet_event_t *ev)
+lnet_eq_enqueue_event(struct lnet_eq *eq, struct lnet_event *ev)
 {
 	/* MUST called with resource lock hold but w/o lnet_eq_wait_lock */
 	int index;
@@ -239,10 +239,10 @@
 }
 
 static int
-lnet_eq_dequeue_event(struct lnet_eq *eq, lnet_event_t *ev)
+lnet_eq_dequeue_event(struct lnet_eq *eq, struct lnet_event *ev)
 {
 	int new_index = eq->eq_deq_seq & (eq->eq_size - 1);
-	lnet_event_t *new_event = &eq->eq_events[new_index];
+	struct lnet_event *new_event = &eq->eq_events[new_index];
 	int rc;
 
 	/* must called with lnet_eq_wait_lock hold */
@@ -371,7 +371,7 @@
  */
 int
 LNetEQPoll(struct lnet_handle_eq *eventqs, int neq, int timeout_ms,
-	   lnet_event_t *event, int *which)
+	   struct lnet_event *event, int *which)
 {
 	int wait = 1;
 	int rc;
diff --git a/drivers/staging/lustre/lnet/lnet/lib-md.c b/drivers/staging/lustre/lnet/lnet/lib-md.c
index a3f8927..872f63f 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-md.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-md.c
@@ -428,7 +428,7 @@
 int
 LNetMDUnlink(struct lnet_handle_md mdh)
 {
-	lnet_event_t ev;
+	struct lnet_event ev;
 	struct lnet_libmd *md;
 	int cpt;
 
diff --git a/drivers/staging/lustre/lnet/lnet/lib-me.c b/drivers/staging/lustre/lnet/lnet/lib-me.c
index 75922a5..7614088 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-me.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-me.c
@@ -224,7 +224,7 @@
 {
 	struct lnet_me *me;
 	struct lnet_libmd *md;
-	lnet_event_t ev;
+	struct lnet_event ev;
 	int cpt;
 
 	LASSERT(the_lnet.ln_refcount > 0);
diff --git a/drivers/staging/lustre/lnet/lnet/lib-move.c b/drivers/staging/lustre/lnet/lnet/lib-move.c
index aea899e..96fb7fc 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-move.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-move.c
@@ -1987,7 +1987,7 @@
  * \retval -ENOMEM Memory allocation failure.
  * \retval -ENOENT Invalid MD object.
  *
- * \see lnet_event_t::hdr_data and lnet_event_kind_t.
+ * \see lnet_event::hdr_data and lnet_event_kind_t.
  */
 int
 LNetPut(lnet_nid_t self, struct lnet_handle_md mdh, lnet_ack_req_t ack,
diff --git a/drivers/staging/lustre/lnet/lnet/lib-msg.c b/drivers/staging/lustre/lnet/lnet/lib-msg.c
index 4b5e3a8..b9b0259 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-msg.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-msg.c
@@ -39,7 +39,7 @@
 #include "../../include/linux/lnet/lib-lnet.h"
 
 void
-lnet_build_unlink_event(struct lnet_libmd *md, lnet_event_t *ev)
+lnet_build_unlink_event(struct lnet_libmd *md, struct lnet_event *ev)
 {
 	memset(ev, 0, sizeof(*ev));
 
@@ -57,7 +57,7 @@
 lnet_build_msg_event(struct lnet_msg *msg, lnet_event_kind_t ev_type)
 {
 	struct lnet_hdr *hdr = &msg->msg_hdr;
-	lnet_event_t *ev  = &msg->msg_ev;
+	struct lnet_event *ev  = &msg->msg_ev;
 
 	LASSERT(!msg->msg_routing);
 
@@ -165,7 +165,7 @@
 lnet_msg_decommit_tx(struct lnet_msg *msg, int status)
 {
 	struct lnet_counters	*counters;
-	lnet_event_t *ev = &msg->msg_ev;
+	struct lnet_event *ev = &msg->msg_ev;
 
 	LASSERT(msg->msg_tx_committed);
 	if (status)
@@ -217,7 +217,7 @@
 lnet_msg_decommit_rx(struct lnet_msg *msg, int status)
 {
 	struct lnet_counters *counters;
-	lnet_event_t *ev = &msg->msg_ev;
+	struct lnet_event *ev = &msg->msg_ev;
 
 	LASSERT(!msg->msg_tx_committed); /* decommitted or never committed */
 	LASSERT(msg->msg_rx_committed);
diff --git a/drivers/staging/lustre/lnet/lnet/router.c b/drivers/staging/lustre/lnet/lnet/router.c
index c9edc10..84092ad 100644
--- a/drivers/staging/lustre/lnet/lnet/router.c
+++ b/drivers/staging/lustre/lnet/lnet/router.c
@@ -733,7 +733,7 @@ int lnet_get_rtr_pool_cfg(int idx, struct lnet_ioctl_pool_cfg *pool_cfg)
 }
 
 static void
-lnet_router_checker_event(lnet_event_t *event)
+lnet_router_checker_event(struct lnet_event *event)
 {
 	struct lnet_rc_data *rcd = event->md.user_ptr;
 	struct lnet_peer *lp;
diff --git a/drivers/staging/lustre/lnet/selftest/rpc.c b/drivers/staging/lustre/lnet/selftest/rpc.c
index e70785c..f56f740 100644
--- a/drivers/staging/lustre/lnet/selftest/rpc.c
+++ b/drivers/staging/lustre/lnet/selftest/rpc.c
@@ -1408,7 +1408,7 @@ struct srpc_client_rpc *
 
 /* when in kernel always called with LNET_LOCK() held, and in thread context */
 static void
-srpc_lnet_ev_handler(lnet_event_t *ev)
+srpc_lnet_ev_handler(struct lnet_event *ev)
 {
 	struct srpc_service_cd *scd;
 	struct srpc_event *rpcev = ev->md.user_ptr;
diff --git a/drivers/staging/lustre/lustre/include/lustre_net.h b/drivers/staging/lustre/lustre/include/lustre_net.h
index c28c4ac..c7c7c3a 100644
--- a/drivers/staging/lustre/lustre/include/lustre_net.h
+++ b/drivers/staging/lustre/lustre/include/lustre_net.h
@@ -400,7 +400,7 @@ struct ptlrpc_set_cbdata {
  * ptlrpc callback & work item stuff
  */
 struct ptlrpc_cb_id {
-	void   (*cbid_fn)(lnet_event_t *ev);     /* specific callback fn */
+	void   (*cbid_fn)(struct lnet_event *ev); /* specific callback fn */
 	void    *cbid_arg;		      /* additional arg */
 };
 
@@ -1757,11 +1757,11 @@ int ptlrpc_uuid_to_peer(struct obd_uuid *uuid,
  * underlying buffer
  * @{
  */
-void request_out_callback(lnet_event_t *ev);
-void reply_in_callback(lnet_event_t *ev);
-void client_bulk_callback(lnet_event_t *ev);
-void request_in_callback(lnet_event_t *ev);
-void reply_out_callback(lnet_event_t *ev);
+void request_out_callback(struct lnet_event *ev);
+void reply_in_callback(struct lnet_event *ev);
+void client_bulk_callback(struct lnet_event *ev);
+void request_in_callback(struct lnet_event *ev);
+void reply_out_callback(struct lnet_event *ev);
 /** @} */
 
 /* ptlrpc/connection.c */
diff --git a/drivers/staging/lustre/lustre/ptlrpc/events.c b/drivers/staging/lustre/lustre/ptlrpc/events.c
index ca11b03..3aec148 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/events.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/events.c
@@ -47,7 +47,7 @@
 /*
  *  Client's outgoing request callback
  */
-void request_out_callback(lnet_event_t *ev)
+void request_out_callback(struct lnet_event *ev)
 {
 	struct ptlrpc_cb_id *cbid = ev->md.user_ptr;
 	struct ptlrpc_request *req = cbid->cbid_arg;
@@ -86,7 +86,7 @@ void request_out_callback(lnet_event_t *ev)
 /*
  * Client's incoming reply callback
  */
-void reply_in_callback(lnet_event_t *ev)
+void reply_in_callback(struct lnet_event *ev)
 {
 	struct ptlrpc_cb_id *cbid = ev->md.user_ptr;
 	struct ptlrpc_request *req = cbid->cbid_arg;
@@ -176,7 +176,7 @@ void reply_in_callback(lnet_event_t *ev)
 /*
  * Client's bulk has been written/read
  */
-void client_bulk_callback(lnet_event_t *ev)
+void client_bulk_callback(struct lnet_event *ev)
 {
 	struct ptlrpc_cb_id *cbid = ev->md.user_ptr;
 	struct ptlrpc_bulk_desc *desc = cbid->cbid_arg;
@@ -289,7 +289,7 @@ static void ptlrpc_req_add_history(struct ptlrpc_service_part *svcpt,
 /*
  * Server's incoming request callback
  */
-void request_in_callback(lnet_event_t *ev)
+void request_in_callback(struct lnet_event *ev)
 {
 	struct ptlrpc_cb_id *cbid = ev->md.user_ptr;
 	struct ptlrpc_request_buffer_desc *rqbd = cbid->cbid_arg;
@@ -389,7 +389,7 @@ void request_in_callback(lnet_event_t *ev)
 /*
  *  Server's outgoing reply callback
  */
-void reply_out_callback(lnet_event_t *ev)
+void reply_out_callback(struct lnet_event *ev)
 {
 	struct ptlrpc_cb_id *cbid = ev->md.user_ptr;
 	struct ptlrpc_reply_state *rs = cbid->cbid_arg;
@@ -429,10 +429,10 @@ void reply_out_callback(lnet_event_t *ev)
 	}
 }
 
-static void ptlrpc_master_callback(lnet_event_t *ev)
+static void ptlrpc_master_callback(struct lnet_event *ev)
 {
 	struct ptlrpc_cb_id *cbid = ev->md.user_ptr;
-	void (*callback)(lnet_event_t *ev) = cbid->cbid_fn;
+	void (*callback)(struct lnet_event *ev) = cbid->cbid_fn;
 
 	/* Honestly, it's best to find out early. */
 	LASSERT(cbid->cbid_arg != LP_POISON);
-- 
1.8.3.1
