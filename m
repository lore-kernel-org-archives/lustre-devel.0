From: James Simmons <jsimmons@infradead.org>
Date: Wed,  6 Apr 2016 15:25:28 -0400
Subject: [lustre-devel] [PATCH 02/24] staging: lustre: selftest: convert
	srpc_event_t to proper struct
In-Reply-To: <1459970750-5377-1-git-send-email-jsimmons@infradead.org>
References: <1459970750-5377-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1459970750-5377-3-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@gmail.com>

Turn typedef srpc_event_t to proper structure

Signed-off-by: James Simmons <uja.ornl@gmail.com>
---
 drivers/staging/lustre/lnet/selftest/rpc.c      |   20 ++++++++++----------
 drivers/staging/lustre/lnet/selftest/selftest.h |   14 +++++++-------
 2 files changed, 17 insertions(+), 17 deletions(-)

diff --git a/drivers/staging/lustre/lnet/selftest/rpc.c b/drivers/staging/lustre/lnet/selftest/rpc.c
index 5d8908d..ba75b34 100644
--- a/drivers/staging/lustre/lnet/selftest/rpc.c
+++ b/drivers/staging/lustre/lnet/selftest/rpc.c
@@ -357,7 +357,7 @@ srpc_remove_service(srpc_service_t *sv)
 static int
 srpc_post_passive_rdma(int portal, int local, __u64 matchbits, void *buf,
 		       int len, int options, lnet_process_id_t peer,
-		       lnet_handle_md_t *mdh, srpc_event_t *ev)
+		       lnet_handle_md_t *mdh, struct srpc_event *ev)
 {
 	int rc;
 	lnet_md_t md;
@@ -396,7 +396,7 @@ srpc_post_passive_rdma(int portal, int local, __u64 matchbits, void *buf,
 static int
 srpc_post_active_rdma(int portal, __u64 matchbits, void *buf, int len,
 		      int options, lnet_process_id_t peer, lnet_nid_t self,
-		      lnet_handle_md_t *mdh, srpc_event_t *ev)
+		      lnet_handle_md_t *mdh, struct srpc_event *ev)
 {
 	int rc;
 	lnet_md_t md;
@@ -449,7 +449,7 @@ srpc_post_active_rdma(int portal, __u64 matchbits, void *buf, int len,
 
 static int
 srpc_post_passive_rqtbuf(int service, int local, void *buf, int len,
-			 lnet_handle_md_t *mdh, srpc_event_t *ev)
+			 lnet_handle_md_t *mdh, struct srpc_event *ev)
 {
 	lnet_process_id_t any = { 0 };
 
@@ -794,7 +794,7 @@ srpc_shutdown_service(srpc_service_t *sv)
 static int
 srpc_send_request(srpc_client_rpc_t *rpc)
 {
-	srpc_event_t *ev = &rpc->crpc_reqstev;
+	struct srpc_event *ev = &rpc->crpc_reqstev;
 	int rc;
 
 	ev->ev_fired = 0;
@@ -816,7 +816,7 @@ srpc_send_request(srpc_client_rpc_t *rpc)
 static int
 srpc_prepare_reply(srpc_client_rpc_t *rpc)
 {
-	srpc_event_t *ev = &rpc->crpc_replyev;
+	struct srpc_event *ev = &rpc->crpc_replyev;
 	__u64 *id = &rpc->crpc_reqstmsg.msg_body.reqst.rpyid;
 	int rc;
 
@@ -841,7 +841,7 @@ static int
 srpc_prepare_bulk(srpc_client_rpc_t *rpc)
 {
 	srpc_bulk_t *bk = &rpc->crpc_bulk;
-	srpc_event_t *ev = &rpc->crpc_bulkev;
+	struct srpc_event *ev = &rpc->crpc_bulkev;
 	__u64 *id = &rpc->crpc_reqstmsg.msg_body.reqst.bulkid;
 	int rc;
 	int opt;
@@ -873,7 +873,7 @@ srpc_prepare_bulk(srpc_client_rpc_t *rpc)
 static int
 srpc_do_bulk(struct srpc_server_rpc *rpc)
 {
-	srpc_event_t *ev = &rpc->srpc_ev;
+	struct srpc_event *ev = &rpc->srpc_ev;
 	srpc_bulk_t *bk = rpc->srpc_bulk;
 	__u64 id = rpc->srpc_reqstbuf->buf_msg.msg_body.reqst.bulkid;
 	int rc;
@@ -968,7 +968,7 @@ srpc_handle_rpc(swi_workitem_t *wi)
 	struct srpc_server_rpc *rpc = wi->swi_workitem.wi_data;
 	struct srpc_service_cd *scd = rpc->srpc_scd;
 	struct srpc_service *sv = scd->scd_svc;
-	srpc_event_t *ev = &rpc->srpc_ev;
+	struct srpc_event *ev = &rpc->srpc_ev;
 	int rc = 0;
 
 	LASSERT(wi == &rpc->srpc_wi);
@@ -1363,7 +1363,7 @@ srpc_post_rpc(srpc_client_rpc_t *rpc)
 int
 srpc_send_reply(struct srpc_server_rpc *rpc)
 {
-	srpc_event_t *ev = &rpc->srpc_ev;
+	struct srpc_event *ev = &rpc->srpc_ev;
 	struct srpc_msg *msg = &rpc->srpc_replymsg;
 	struct srpc_buffer *buffer = rpc->srpc_reqstbuf;
 	struct srpc_service_cd *scd = rpc->srpc_scd;
@@ -1410,7 +1410,7 @@ static void
 srpc_lnet_ev_handler(lnet_event_t *ev)
 {
 	struct srpc_service_cd *scd;
-	srpc_event_t *rpcev = ev->md.user_ptr;
+	struct srpc_event *rpcev = ev->md.user_ptr;
 	srpc_client_rpc_t *crpc;
 	struct srpc_server_rpc *srpc;
 	srpc_buffer_t *buffer;
diff --git a/drivers/staging/lustre/lnet/selftest/selftest.h b/drivers/staging/lustre/lnet/selftest/selftest.h
index 00d73a1..43972eb 100644
--- a/drivers/staging/lustre/lnet/selftest/selftest.h
+++ b/drivers/staging/lustre/lnet/selftest/selftest.h
@@ -146,13 +146,13 @@ enum srpc_event_type {
 };
 
 /* RPC event */
-typedef struct {
+struct srpc_event {
 	enum srpc_event_type	ev_type;	/* what's up */
 	lnet_event_kind_t ev_lnet;   /* LNet event type */
 	int		  ev_fired;  /* LNet event fired? */
 	int		  ev_status; /* LNet event status */
 	void		  *ev_data;  /* owning server/client RPC */
-} srpc_event_t;
+};
 
 typedef struct {
 	int		 bk_len;     /* len of bulk data */
@@ -187,7 +187,7 @@ struct srpc_server_rpc {
 	struct list_head       srpc_list;
 	struct srpc_service_cd *srpc_scd;
 	swi_workitem_t	       srpc_wi;
-	srpc_event_t	       srpc_ev;      /* bulk/reply event */
+	struct srpc_event	srpc_ev;	/* bulk/reply event */
 	lnet_nid_t	       srpc_self;
 	lnet_process_id_t      srpc_peer;
 	srpc_msg_t	       srpc_replymsg;
@@ -221,9 +221,9 @@ typedef struct srpc_client_rpc {
 	unsigned int	  crpc_closed:1;  /* completed */
 
 	/* RPC events */
-	srpc_event_t	  crpc_bulkev;	  /* bulk event */
-	srpc_event_t	  crpc_reqstev;   /* request event */
-	srpc_event_t	  crpc_replyev;   /* reply event */
+	struct srpc_event	crpc_bulkev;	/* bulk event */
+	struct srpc_event	crpc_reqstev;	/* request event */
+	struct srpc_event	crpc_replyev;	/* reply event */
 
 	/* bulk, request(reqst), and reply exchanged on wire */
 	srpc_msg_t	  crpc_reqstmsg;
@@ -266,7 +266,7 @@ struct srpc_service_cd {
 	/** backref to service */
 	struct srpc_service	*scd_svc;
 	/** event buffer */
-	srpc_event_t		scd_ev;
+	struct srpc_event	scd_ev;
 	/** free RPC descriptors */
 	struct list_head	scd_rpc_free;
 	/** in-flight RPCs */
-- 
1.7.1
