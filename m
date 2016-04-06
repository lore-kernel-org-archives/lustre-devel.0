From: James Simmons <jsimmons@infradead.org>
Date: Wed,  6 Apr 2016 15:25:30 -0400
Subject: [lustre-devel] [PATCH 04/24] staging: lustre: selftest: convert
	srpc_buffer_t to proper struct
In-Reply-To: <1459970750-5377-1-git-send-email-jsimmons@infradead.org>
References: <1459970750-5377-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1459970750-5377-5-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@gmail.com>

Turn typedef srpc_buffer_t to proper structure

Signed-off-by: James Simmons <uja.ornl@gmail.com>
---
 drivers/staging/lustre/lnet/selftest/rpc.c      |   12 ++++++------
 drivers/staging/lustre/lnet/selftest/selftest.h |    6 +++---
 2 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/drivers/staging/lustre/lnet/selftest/rpc.c b/drivers/staging/lustre/lnet/selftest/rpc.c
index 387c306..316ccf7 100644
--- a/drivers/staging/lustre/lnet/selftest/rpc.c
+++ b/drivers/staging/lustre/lnet/selftest/rpc.c
@@ -697,7 +697,7 @@ srpc_finish_service(struct srpc_service *sv)
 
 /* called with sv->sv_lock held */
 static void
-srpc_service_recycle_buffer(struct srpc_service_cd *scd, srpc_buffer_t *buf)
+srpc_service_recycle_buffer(struct srpc_service_cd *scd, struct srpc_buffer *buf)
 __must_hold(&scd->scd_lock)
 {
 	if (!scd->scd_svc->sv_shuttingdown && scd->scd_buf_adjust >= 0) {
@@ -759,7 +759,7 @@ srpc_shutdown_service(srpc_service_t *sv)
 {
 	struct srpc_service_cd *scd;
 	struct srpc_server_rpc *rpc;
-	srpc_buffer_t *buf;
+	struct srpc_buffer *buf;
 	int i;
 
 	CDEBUG(D_NET, "Shutting down service: id %d, name %s\n",
@@ -903,7 +903,7 @@ srpc_server_rpc_done(struct srpc_server_rpc *rpc, int status)
 {
 	struct srpc_service_cd *scd = rpc->srpc_scd;
 	struct srpc_service *sv = scd->scd_svc;
-	srpc_buffer_t *buffer;
+	struct srpc_buffer *buffer;
 
 	LASSERT(status || rpc->srpc_wi.swi_state == SWI_STATE_DONE);
 
@@ -948,7 +948,7 @@ srpc_server_rpc_done(struct srpc_server_rpc *rpc, int status)
 
 	if (!sv->sv_shuttingdown && !list_empty(&scd->scd_buf_blocked)) {
 		buffer = list_entry(scd->scd_buf_blocked.next,
-				    srpc_buffer_t, buf_list);
+				    struct srpc_buffer, buf_list);
 		list_del(&buffer->buf_list);
 
 		srpc_init_server_rpc(rpc, scd, buffer);
@@ -1413,7 +1413,7 @@ srpc_lnet_ev_handler(lnet_event_t *ev)
 	struct srpc_event *rpcev = ev->md.user_ptr;
 	srpc_client_rpc_t *crpc;
 	struct srpc_server_rpc *srpc;
-	srpc_buffer_t *buffer;
+	struct srpc_buffer *buffer;
 	srpc_service_t *sv;
 	srpc_msg_t *msg;
 	srpc_msg_type_t type;
@@ -1486,7 +1486,7 @@ srpc_lnet_ev_handler(lnet_event_t *ev)
 		LASSERT(ev->type != LNET_EVENT_UNLINK ||
 			sv->sv_shuttingdown);
 
-		buffer = container_of(ev->md.start, srpc_buffer_t, buf_msg);
+		buffer = container_of(ev->md.start, struct srpc_buffer, buf_msg);
 		buffer->buf_peer = ev->initiator;
 		buffer->buf_self = ev->target.nid;
 
diff --git a/drivers/staging/lustre/lnet/selftest/selftest.h b/drivers/staging/lustre/lnet/selftest/selftest.h
index fdf62cc..04e742e 100644
--- a/drivers/staging/lustre/lnet/selftest/selftest.h
+++ b/drivers/staging/lustre/lnet/selftest/selftest.h
@@ -164,13 +164,13 @@ struct srpc_bulk {
 };
 
 /* message buffer descriptor */
-typedef struct srpc_buffer {
+struct srpc_buffer {
 	struct list_head  buf_list; /* chain on srpc_service::*_msgq */
 	srpc_msg_t	  buf_msg;
 	lnet_handle_md_t  buf_mdh;
 	lnet_nid_t	  buf_self;
 	lnet_process_id_t buf_peer;
-} srpc_buffer_t;
+};
 
 struct swi_workitem;
 typedef int (*swi_action_t) (struct swi_workitem *);
@@ -193,7 +193,7 @@ struct srpc_server_rpc {
 	lnet_process_id_t      srpc_peer;
 	srpc_msg_t	       srpc_replymsg;
 	lnet_handle_md_t       srpc_replymdh;
-	srpc_buffer_t	       *srpc_reqstbuf;
+	struct srpc_buffer	*srpc_reqstbuf;
 	struct srpc_bulk	*srpc_bulk;
 
 	unsigned int	       srpc_aborted; /* being given up */
-- 
1.7.1
