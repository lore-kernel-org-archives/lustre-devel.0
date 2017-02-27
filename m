From: James Simmons <jsimmons@infradead.org>
Date: Sun, 26 Feb 2017 19:41:28 -0500
Subject: [lustre-devel] [PATCH 03/34] staging: lustre: lnet: change
	lnet_handle_md_t to proper struct
In-Reply-To: <1488156119-19670-1-git-send-email-jsimmons@infradead.org>
References: <1488156119-19670-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1488156119-19670-4-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@yahoo.com>

Change lnet_handle_md_t from a typedef of another typedef into
a proper stand alone structure. Create the inline functions
LNetInvalidateMDHandle and LNetMDHandleIsInvalid to handle this
new piece of data.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-on: https://review.whamcloud.com/20831
Reviewed-by: Olaf Weber <olaf@sgi.com>
Reviewed-by: Doug Oucharek <doug.s.oucharek@intel.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/include/linux/lnet/api.h    | 10 ++++-----
 .../staging/lustre/include/linux/lnet/lib-lnet.h   |  4 ++--
 .../staging/lustre/include/linux/lnet/lib-types.h  |  4 ++--
 drivers/staging/lustre/include/linux/lnet/types.h  | 25 ++++++++++++++++++++--
 drivers/staging/lustre/lnet/lnet/api-ni.c          | 21 ++++++++++--------
 drivers/staging/lustre/lnet/lnet/lib-md.c          |  7 +++---
 drivers/staging/lustre/lnet/lnet/lib-move.c        |  4 ++--
 drivers/staging/lustre/lnet/lnet/router.c          | 12 +++++------
 drivers/staging/lustre/lnet/selftest/rpc.c         | 10 ++++-----
 drivers/staging/lustre/lnet/selftest/selftest.h    | 16 +++++++-------
 drivers/staging/lustre/lustre/include/lustre_net.h | 10 ++++-----
 drivers/staging/lustre/lustre/ptlrpc/client.c      |  2 +-
 drivers/staging/lustre/lustre/ptlrpc/niobuf.c      |  4 ++--
 13 files changed, 77 insertions(+), 52 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/api.h b/drivers/staging/lustre/include/linux/lnet/api.h
index 1db4e00..32c3f56 100644
--- a/drivers/staging/lustre/include/linux/lnet/api.h
+++ b/drivers/staging/lustre/include/linux/lnet/api.h
@@ -128,13 +128,13 @@ int LNetMEInsert(lnet_handle_me_t  current_in,
 int LNetMDAttach(lnet_handle_me_t  current_in,
 		 lnet_md_t	   md_in,
 		 lnet_unlink_t     unlink_in,
-		 lnet_handle_md_t *handle_out);
+		 struct lnet_handle_md *md_handle_out);
 
 int LNetMDBind(lnet_md_t	   md_in,
 	       lnet_unlink_t       unlink_in,
-	       lnet_handle_md_t   *handle_out);
+	       struct lnet_handle_md *md_handle_out);
 
-int LNetMDUnlink(lnet_handle_md_t md_in);
+int LNetMDUnlink(struct lnet_handle_md md_in);
 /** @} lnet_md */
 
 /** \defgroup lnet_eq Events and event queues
@@ -180,7 +180,7 @@ int LNetEQPoll(struct lnet_handle_eq *eventqs_in,
  * @{
  */
 int LNetPut(lnet_nid_t	      self,
-	    lnet_handle_md_t  md_in,
+	    struct lnet_handle_md md_in,
 	    lnet_ack_req_t    ack_req_in,
 	    lnet_process_id_t target_in,
 	    unsigned int      portal_in,
@@ -189,7 +189,7 @@ int LNetPut(lnet_nid_t	      self,
 	    __u64	      hdr_data_in);
 
 int LNetGet(lnet_nid_t	      self,
-	    lnet_handle_md_t  md_in,
+	    struct lnet_handle_md md_in,
 	    lnet_process_id_t target_in,
 	    unsigned int      portal_in,
 	    __u64	      match_bits_in,
diff --git a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
index 808d886..344a8a5 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
@@ -301,13 +301,13 @@ void lnet_res_lh_initialize(struct lnet_res_container *rec,
 }
 
 static inline void
-lnet_md2handle(lnet_handle_md_t *handle, lnet_libmd_t *md)
+lnet_md2handle(struct lnet_handle_md *handle, lnet_libmd_t *md)
 {
 	handle->cookie = md->md_lh.lh_cookie;
 }
 
 static inline lnet_libmd_t *
-lnet_handle2md(lnet_handle_md_t *handle)
+lnet_handle2md(struct lnet_handle_md *handle)
 {
 	/* ALWAYS called with resource lock held */
 	lnet_libhandle_t *lh;
diff --git a/drivers/staging/lustre/include/linux/lnet/lib-types.h b/drivers/staging/lustre/include/linux/lnet/lib-types.h
index 199e194..7ce0091 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-types.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-types.h
@@ -299,7 +299,7 @@ struct lnet_tx_queue {
 typedef struct {
 	/* chain on the_lnet.ln_zombie_rcd or ln_deathrow_rcd */
 	struct list_head	 rcd_list;
-	lnet_handle_md_t	 rcd_mdh;	/* ping buffer MD */
+	struct lnet_handle_md	 rcd_mdh;	/* ping buffer MD */
 	struct lnet_peer	*rcd_gateway;	/* reference to gateway */
 	struct lnet_ping_info	*rcd_pinginfo;	/* ping buffer */
 } lnet_rc_data_t;
@@ -597,7 +597,7 @@ struct lnet_msg_container {
 	/* percpt router buffer pools */
 	lnet_rtrbufpool_t		**ln_rtrpools;
 
-	lnet_handle_md_t		  ln_ping_target_md;
+	struct lnet_handle_md		  ln_ping_target_md;
 	struct lnet_handle_eq		  ln_ping_target_eq;
 	struct lnet_ping_info		 *ln_ping_info;
 
diff --git a/drivers/staging/lustre/include/linux/lnet/types.h b/drivers/staging/lustre/include/linux/lnet/types.h
index ebf87cd..8dcf3f9 100644
--- a/drivers/staging/lustre/include/linux/lnet/types.h
+++ b/drivers/staging/lustre/include/linux/lnet/types.h
@@ -284,7 +284,6 @@ struct lnet_ping_info {
 	__u64	 cookie;
 } lnet_handle_any_t;
 
-typedef lnet_handle_any_t lnet_handle_md_t;
 typedef lnet_handle_any_t lnet_handle_me_t;
 
 #define LNET_WIRE_HANDLE_COOKIE_NONE   (-1)
@@ -339,6 +338,28 @@ static inline int LNetEQHandleIsInvalid(struct lnet_handle_eq h)
 	return (LNET_WIRE_HANDLE_COOKIE_NONE == h.cookie);
 }
 
+struct lnet_handle_md {
+	u64	cookie;
+};
+
+/**
+ * Invalidate md handle @h.
+ */
+static inline void LNetInvalidateMDHandle(struct lnet_handle_md *h)
+{
+	h->cookie = LNET_WIRE_HANDLE_COOKIE_NONE;
+}
+
+/**
+ * Check whether eq handle @h is invalid.
+ *
+ * @return 1 if handle is invalid, 0 if valid.
+ */
+static inline int LNetMDHandleIsInvalid(struct lnet_handle_md h)
+{
+	return (LNET_WIRE_HANDLE_COOKIE_NONE == h.cookie);
+}
+
 /**
  * Global process ID.
  */
@@ -611,7 +632,7 @@ static inline int LNetEQHandleIsInvalid(struct lnet_handle_eq h)
 	 * The handle to the MD associated with the event. The handle may be
 	 * invalid if the MD has been unlinked.
 	 */
-	lnet_handle_md_t	md_handle;
+	struct lnet_handle_md	md_handle;
 	/**
 	 * A snapshot of the state of the MD immediately after the event has
 	 * been processed. In particular, the threshold field in md will
diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
index 0564e93..c9d754d 100644
--- a/drivers/staging/lustre/lnet/lnet/api-ni.c
+++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
@@ -896,7 +896,8 @@ static void lnet_assert_wire_constants(void)
 }
 
 static int
-lnet_ping_info_setup(struct lnet_ping_info **ppinfo, lnet_handle_md_t *md_handle,
+lnet_ping_info_setup(struct lnet_ping_info **ppinfo,
+		     struct lnet_handle_md *md_handle,
 		     int ni_count, bool set_eq)
 {
 	lnet_process_id_t id = {LNET_NID_ANY, LNET_PID_ANY};
@@ -961,12 +962,13 @@ static void lnet_assert_wire_constants(void)
 }
 
 static void
-lnet_ping_md_unlink(struct lnet_ping_info *pinfo, lnet_handle_md_t *md_handle)
+lnet_ping_md_unlink(struct lnet_ping_info *pinfo,
+		    struct lnet_handle_md *md_handle)
 {
 	sigset_t blocked = cfs_block_allsigs();
 
 	LNetMDUnlink(*md_handle);
-	LNetInvalidateHandle(md_handle);
+	LNetInvalidateMDHandle(md_handle);
 
 	/* NB md could be busy; this just starts the unlink */
 	while (pinfo->pi_features != LNET_PING_FEAT_INVAL) {
@@ -1003,10 +1005,11 @@ static void lnet_assert_wire_constants(void)
 }
 
 static void
-lnet_ping_target_update(struct lnet_ping_info *pinfo, lnet_handle_md_t md_handle)
+lnet_ping_target_update(struct lnet_ping_info *pinfo,
+			struct lnet_handle_md md_handle)
 {
 	struct lnet_ping_info *old_pinfo = NULL;
-	lnet_handle_md_t old_md;
+	struct lnet_handle_md old_md;
 
 	/* switch the NIs to point to the new ping info created */
 	lnet_net_lock(LNET_LOCK_EX);
@@ -1497,7 +1500,7 @@ void lnet_lib_exit(void)
 	int rc;
 	int ni_count;
 	struct lnet_ping_info *pinfo;
-	lnet_handle_md_t md_handle;
+	struct lnet_handle_md md_handle;
 	struct list_head net_head;
 
 	INIT_LIST_HEAD(&net_head);
@@ -1755,7 +1758,7 @@ void lnet_lib_exit(void)
 {
 	char *nets = conf->cfg_config_u.cfg_net.net_intf;
 	struct lnet_ping_info *pinfo;
-	lnet_handle_md_t md_handle;
+	struct lnet_handle_md md_handle;
 	struct lnet_ni *ni;
 	struct list_head net_head;
 	lnet_remotenet_t *rnet;
@@ -1835,7 +1838,7 @@ void lnet_lib_exit(void)
 {
 	lnet_ni_t *ni;
 	struct lnet_ping_info *pinfo;
-	lnet_handle_md_t md_handle;
+	struct lnet_handle_md md_handle;
 	int rc;
 
 	/* don't allow userspace to shutdown the LOLND */
@@ -2139,7 +2142,7 @@ static int lnet_ping(lnet_process_id_t id, int timeout_ms,
 		     lnet_process_id_t __user *ids, int n_ids)
 {
 	struct lnet_handle_eq eqh;
-	lnet_handle_md_t mdh;
+	struct lnet_handle_md mdh;
 	lnet_event_t event;
 	lnet_md_t md = { NULL };
 	int which;
diff --git a/drivers/staging/lustre/lnet/lnet/lib-md.c b/drivers/staging/lustre/lnet/lnet/lib-md.c
index d97e046..f155839 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-md.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-md.c
@@ -268,7 +268,7 @@
  */
 int
 LNetMDAttach(lnet_handle_me_t meh, lnet_md_t umd,
-	     lnet_unlink_t unlink, lnet_handle_md_t *handle)
+	     lnet_unlink_t unlink, struct lnet_handle_md *handle)
 {
 	LIST_HEAD(matches);
 	LIST_HEAD(drops);
@@ -350,7 +350,8 @@
  * LNetInvalidateHandle() on it.
  */
 int
-LNetMDBind(lnet_md_t umd, lnet_unlink_t unlink, lnet_handle_md_t *handle)
+LNetMDBind(lnet_md_t umd, lnet_unlink_t unlink,
+	   struct lnet_handle_md *handle)
 {
 	lnet_libmd_t *md;
 	int cpt;
@@ -425,7 +426,7 @@
  * \retval -ENOENT If \a mdh does not point to a valid MD object.
  */
 int
-LNetMDUnlink(lnet_handle_md_t mdh)
+LNetMDUnlink(struct lnet_handle_md mdh)
 {
 	lnet_event_t ev;
 	lnet_libmd_t *md;
diff --git a/drivers/staging/lustre/lnet/lnet/lib-move.c b/drivers/staging/lustre/lnet/lnet/lib-move.c
index 6b0be6c..88d87eb 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-move.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-move.c
@@ -1988,7 +1988,7 @@
  * \see lnet_event_t::hdr_data and lnet_event_kind_t.
  */
 int
-LNetPut(lnet_nid_t self, lnet_handle_md_t mdh, lnet_ack_req_t ack,
+LNetPut(lnet_nid_t self, struct lnet_handle_md mdh, lnet_ack_req_t ack,
 	lnet_process_id_t target, unsigned int portal,
 	__u64 match_bits, unsigned int offset,
 	__u64 hdr_data)
@@ -2193,7 +2193,7 @@
  * \retval -ENOENT Invalid MD object.
  */
 int
-LNetGet(lnet_nid_t self, lnet_handle_md_t mdh,
+LNetGet(lnet_nid_t self, struct lnet_handle_md mdh,
 	lnet_process_id_t target, unsigned int portal,
 	__u64 match_bits, unsigned int offset)
 {
diff --git a/drivers/staging/lustre/lnet/lnet/router.c b/drivers/staging/lustre/lnet/lnet/router.c
index ba80221..eb14ce2 100644
--- a/drivers/staging/lustre/lnet/lnet/router.c
+++ b/drivers/staging/lustre/lnet/lnet/router.c
@@ -739,7 +739,7 @@ int lnet_get_rtr_pool_cfg(int idx, struct lnet_ioctl_pool_cfg *pool_cfg)
 	LASSERT(rcd);
 
 	if (event->unlinked) {
-		LNetInvalidateHandle(&rcd->rcd_mdh);
+		LNetInvalidateMDHandle(&rcd->rcd_mdh);
 		return;
 	}
 
@@ -882,7 +882,7 @@ int lnet_get_rtr_pool_cfg(int idx, struct lnet_ioctl_pool_cfg *pool_cfg)
 {
 	LASSERT(list_empty(&rcd->rcd_list));
 	/* detached from network */
-	LASSERT(LNetHandleIsInvalid(rcd->rcd_mdh));
+	LASSERT(LNetMDHandleIsInvalid(rcd->rcd_mdh));
 
 	if (rcd->rcd_gateway) {
 		int cpt = rcd->rcd_gateway->lp_cpt;
@@ -913,7 +913,7 @@ int lnet_get_rtr_pool_cfg(int idx, struct lnet_ioctl_pool_cfg *pool_cfg)
 	if (!rcd)
 		goto out;
 
-	LNetInvalidateHandle(&rcd->rcd_mdh);
+	LNetInvalidateMDHandle(&rcd->rcd_mdh);
 	INIT_LIST_HEAD(&rcd->rcd_list);
 
 	LIBCFS_ALLOC(pi, LNET_PINGINFO_SIZE);
@@ -957,7 +957,7 @@ int lnet_get_rtr_pool_cfg(int idx, struct lnet_ioctl_pool_cfg *pool_cfg)
 
  out:
 	if (rcd) {
-		if (!LNetHandleIsInvalid(rcd->rcd_mdh)) {
+		if (!LNetMDHandleIsInvalid(rcd->rcd_mdh)) {
 			rc = LNetMDUnlink(rcd->rcd_mdh);
 			LASSERT(!rc);
 		}
@@ -1023,7 +1023,7 @@ int lnet_get_rtr_pool_cfg(int idx, struct lnet_ioctl_pool_cfg *pool_cfg)
 					     cfs_time_seconds(secs)))) {
 		int rc;
 		lnet_process_id_t id;
-		lnet_handle_md_t mdh;
+		struct lnet_handle_md mdh;
 
 		id.nid = rtr->lp_nid;
 		id.pid = LNET_PID_LUSTRE;
@@ -1171,7 +1171,7 @@ int lnet_get_rtr_pool_cfg(int idx, struct lnet_ioctl_pool_cfg *pool_cfg)
 	while (!list_empty(&the_lnet.ln_rcd_zombie)) {
 		list_for_each_entry_safe(rcd, tmp, &the_lnet.ln_rcd_zombie,
 					 rcd_list) {
-			if (LNetHandleIsInvalid(rcd->rcd_mdh))
+			if (LNetMDHandleIsInvalid(rcd->rcd_mdh))
 				list_move(&rcd->rcd_list, &head);
 		}
 
diff --git a/drivers/staging/lustre/lnet/selftest/rpc.c b/drivers/staging/lustre/lnet/selftest/rpc.c
index 3f070eb..af99962 100644
--- a/drivers/staging/lustre/lnet/selftest/rpc.c
+++ b/drivers/staging/lustre/lnet/selftest/rpc.c
@@ -185,7 +185,7 @@ struct srpc_bulk *
 	rpc->srpc_reqstbuf = buffer;
 	rpc->srpc_peer = buffer->buf_peer;
 	rpc->srpc_self = buffer->buf_self;
-	LNetInvalidateHandle(&rpc->srpc_replymdh);
+	LNetInvalidateMDHandle(&rpc->srpc_replymdh);
 }
 
 static void
@@ -356,7 +356,7 @@ struct srpc_bulk *
 static int
 srpc_post_passive_rdma(int portal, int local, __u64 matchbits, void *buf,
 		       int len, int options, lnet_process_id_t peer,
-		       lnet_handle_md_t *mdh, struct srpc_event *ev)
+		       struct lnet_handle_md *mdh, struct srpc_event *ev)
 {
 	int rc;
 	lnet_md_t md;
@@ -395,7 +395,7 @@ struct srpc_bulk *
 static int
 srpc_post_active_rdma(int portal, __u64 matchbits, void *buf, int len,
 		      int options, lnet_process_id_t peer, lnet_nid_t self,
-		      lnet_handle_md_t *mdh, struct srpc_event *ev)
+		      struct lnet_handle_md *mdh, struct srpc_event *ev)
 {
 	int rc;
 	lnet_md_t md;
@@ -448,7 +448,7 @@ struct srpc_bulk *
 
 static int
 srpc_post_passive_rqtbuf(int service, int local, void *buf, int len,
-			 lnet_handle_md_t *mdh, struct srpc_event *ev)
+			 struct lnet_handle_md *mdh, struct srpc_event *ev)
 {
 	lnet_process_id_t any = { 0 };
 
@@ -468,7 +468,7 @@ struct srpc_bulk *
 	struct srpc_msg	*msg = &buf->buf_msg;
 	int rc;
 
-	LNetInvalidateHandle(&buf->buf_mdh);
+	LNetInvalidateMDHandle(&buf->buf_mdh);
 	list_add(&buf->buf_list, &scd->scd_buf_posted);
 	scd->scd_buf_nposted++;
 	spin_unlock(&scd->scd_lock);
diff --git a/drivers/staging/lustre/lnet/selftest/selftest.h b/drivers/staging/lustre/lnet/selftest/selftest.h
index f259480..91088c6 100644
--- a/drivers/staging/lustre/lnet/selftest/selftest.h
+++ b/drivers/staging/lustre/lnet/selftest/selftest.h
@@ -153,7 +153,7 @@ struct srpc_event {
 /* bulk descriptor */
 struct srpc_bulk {
 	int		 bk_len;     /* len of bulk data */
-	lnet_handle_md_t bk_mdh;
+	struct lnet_handle_md	bk_mdh;
 	int		 bk_sink;    /* sink/source */
 	int		 bk_niov;    /* # iov in bk_iovs */
 	lnet_kiov_t	 bk_iovs[0];
@@ -163,7 +163,7 @@ struct srpc_bulk {
 struct srpc_buffer {
 	struct list_head  buf_list; /* chain on srpc_service::*_msgq */
 	struct srpc_msg	  buf_msg;
-	lnet_handle_md_t  buf_mdh;
+	struct lnet_handle_md	buf_mdh;
 	lnet_nid_t	  buf_self;
 	lnet_process_id_t buf_peer;
 };
@@ -188,7 +188,7 @@ struct srpc_server_rpc {
 	lnet_nid_t	       srpc_self;
 	lnet_process_id_t      srpc_peer;
 	struct srpc_msg		srpc_replymsg;
-	lnet_handle_md_t       srpc_replymdh;
+	struct lnet_handle_md	srpc_replymdh;
 	struct srpc_buffer	*srpc_reqstbuf;
 	struct srpc_bulk	*srpc_bulk;
 
@@ -225,8 +225,8 @@ struct srpc_client_rpc {
 	/* bulk, request(reqst), and reply exchanged on wire */
 	struct srpc_msg		crpc_reqstmsg;
 	struct srpc_msg		crpc_replymsg;
-	lnet_handle_md_t  crpc_reqstmdh;
-	lnet_handle_md_t  crpc_replymdh;
+	struct lnet_handle_md	crpc_reqstmdh;
+	struct lnet_handle_md	crpc_replymdh;
 	struct srpc_bulk	crpc_bulk;
 };
 
@@ -545,9 +545,9 @@ struct srpc_bulk *srpc_alloc_bulk(int cpt, unsigned int off,
 	rpc->crpc_bulk.bk_niov = nbulkiov;
 	rpc->crpc_done = rpc_done;
 	rpc->crpc_fini = rpc_fini;
-	LNetInvalidateHandle(&rpc->crpc_reqstmdh);
-	LNetInvalidateHandle(&rpc->crpc_replymdh);
-	LNetInvalidateHandle(&rpc->crpc_bulk.bk_mdh);
+	LNetInvalidateMDHandle(&rpc->crpc_reqstmdh);
+	LNetInvalidateMDHandle(&rpc->crpc_replymdh);
+	LNetInvalidateMDHandle(&rpc->crpc_bulk.bk_mdh);
 
 	/* no event is expected at this point */
 	rpc->crpc_bulkev.ev_fired = 1;
diff --git a/drivers/staging/lustre/lustre/include/lustre_net.h b/drivers/staging/lustre/lustre/include/lustre_net.h
index 7955cbf..c28c4ac 100644
--- a/drivers/staging/lustre/lustre/include/lustre_net.h
+++ b/drivers/staging/lustre/lustre/include/lustre_net.h
@@ -457,7 +457,7 @@ struct ptlrpc_reply_state {
 	struct obd_export     *rs_export;
 	struct ptlrpc_service_part *rs_svcpt;
 	/** Lnet metadata handle for the reply */
-	lnet_handle_md_t       rs_md_h;
+	struct lnet_handle_md		rs_md_h;
 
 	/** Context for the service thread */
 	struct ptlrpc_svc_ctx *rs_svc_ctx;
@@ -586,11 +586,11 @@ struct ptlrpc_cli_req {
 	/** Link back to the request set */
 	struct ptlrpc_request_set	*cr_set;
 	/** outgoing request MD handle */
-	lnet_handle_md_t		 cr_req_md_h;
+	struct lnet_handle_md		 cr_req_md_h;
 	/** request-out callback parameter */
 	struct ptlrpc_cb_id		 cr_req_cbid;
 	/** incoming reply MD handle */
-	lnet_handle_md_t		 cr_reply_md_h;
+	struct lnet_handle_md		 cr_reply_md_h;
 	wait_queue_head_t		 cr_reply_waitq;
 	/** reply callback parameter */
 	struct ptlrpc_cb_id		 cr_reply_cbid;
@@ -1225,7 +1225,7 @@ struct ptlrpc_bulk_desc {
 	int			bd_md_count;	/* # valid entries in bd_mds */
 	int			bd_md_max_brw;	/* max entries in bd_mds */
 	/** array of associated MDs */
-	lnet_handle_md_t	bd_mds[PTLRPC_BULK_OPS_COUNT];
+	struct lnet_handle_md	bd_mds[PTLRPC_BULK_OPS_COUNT];
 
 	union {
 		struct {
@@ -1376,7 +1376,7 @@ struct ptlrpc_request_buffer_desc {
 	/** Back pointer to service for which this buffer is registered */
 	struct ptlrpc_service_part *rqbd_svcpt;
 	/** LNet descriptor */
-	lnet_handle_md_t       rqbd_md_h;
+	struct lnet_handle_md		rqbd_md_h;
 	int		    rqbd_refcount;
 	/** The buffer itself */
 	char		  *rqbd_buffer;
diff --git a/drivers/staging/lustre/lustre/ptlrpc/client.c b/drivers/staging/lustre/lustre/ptlrpc/client.c
index 45b9aec..5645c31 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/client.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/client.c
@@ -151,7 +151,7 @@ struct ptlrpc_bulk_desc *ptlrpc_new_bulk(unsigned int nfrags,
 	 * node. Negotiated ocd_brw_size will always be <= this number.
 	 */
 	for (i = 0; i < PTLRPC_BULK_OPS_COUNT; i++)
-		LNetInvalidateHandle(&desc->bd_mds[i]);
+		LNetInvalidateMDHandle(&desc->bd_mds[i]);
 
 	return desc;
 free_desc:
diff --git a/drivers/staging/lustre/lustre/ptlrpc/niobuf.c b/drivers/staging/lustre/lustre/ptlrpc/niobuf.c
index 352f614..64b8ce0 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/niobuf.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/niobuf.c
@@ -43,7 +43,7 @@
  * over \a conn connection to portal \a portal.
  * Returns 0 on success or error code.
  */
-static int ptl_send_buf(lnet_handle_md_t *mdh, void *base, int len,
+static int ptl_send_buf(struct lnet_handle_md *mdh, void *base, int len,
 			lnet_ack_req_t ack, struct ptlrpc_cb_id *cbid,
 			struct ptlrpc_connection *conn, int portal, __u64 xid,
 			unsigned int offset)
@@ -94,7 +94,7 @@ static int ptl_send_buf(lnet_handle_md_t *mdh, void *base, int len,
 	return 0;
 }
 
-static void mdunlink_iterate_helper(lnet_handle_md_t *bd_mds, int count)
+static void mdunlink_iterate_helper(struct lnet_handle_md *bd_mds, int count)
 {
 	int i;
 
-- 
1.8.3.1
