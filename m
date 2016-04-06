From: James Simmons <jsimmons@infradead.org>
Date: Wed,  6 Apr 2016 15:25:31 -0400
Subject: [lustre-devel] [PATCH 05/24] staging: lustre: selftest: convert
	swi_workitem_t to proper struct
In-Reply-To: <1459970750-5377-1-git-send-email-jsimmons@infradead.org>
References: <1459970750-5377-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1459970750-5377-6-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@gmail.com>

Turn typedef swi_workitem_t to proper structure

Signed-off-by: James Simmons <uja.ornl@gmail.com>
---
 drivers/staging/lustre/lnet/selftest/framework.c |    4 +-
 drivers/staging/lustre/lnet/selftest/rpc.c       |    8 +++---
 drivers/staging/lustre/lnet/selftest/selftest.h  |   26 +++++++++++----------
 3 files changed, 20 insertions(+), 18 deletions(-)

diff --git a/drivers/staging/lustre/lnet/selftest/framework.c b/drivers/staging/lustre/lnet/selftest/framework.c
index 40a3da9..b2df184 100644
--- a/drivers/staging/lustre/lnet/selftest/framework.c
+++ b/drivers/staging/lustre/lnet/selftest/framework.c
@@ -942,7 +942,7 @@ sfw_create_test_rpc(sfw_test_unit_t *tsu, lnet_process_id_t peer,
 }
 
 static int
-sfw_run_test(swi_workitem_t *wi)
+sfw_run_test(struct swi_workitem *wi)
 {
 	sfw_test_unit_t *tsu = wi->swi_workitem.wi_data;
 	sfw_test_instance_t *tsi = tsu->tsu_instance;
@@ -993,7 +993,7 @@ test_done:
 static int
 sfw_run_batch(sfw_batch_t *tsb)
 {
-	swi_workitem_t *wi;
+	struct swi_workitem *wi;
 	sfw_test_unit_t *tsu;
 	sfw_test_instance_t *tsi;
 
diff --git a/drivers/staging/lustre/lnet/selftest/rpc.c b/drivers/staging/lustre/lnet/selftest/rpc.c
index 316ccf7..b0d5a89 100644
--- a/drivers/staging/lustre/lnet/selftest/rpc.c
+++ b/drivers/staging/lustre/lnet/selftest/rpc.c
@@ -71,7 +71,7 @@ srpc_serv_portal(int svc_id)
 }
 
 /* forward ref's */
-int srpc_handle_rpc(swi_workitem_t *wi);
+int srpc_handle_rpc(struct swi_workitem *wi);
 
 void srpc_get_counters(srpc_counters_t *cnt)
 {
@@ -963,7 +963,7 @@ srpc_server_rpc_done(struct srpc_server_rpc *rpc, int status)
 
 /* handles an incoming RPC */
 int
-srpc_handle_rpc(swi_workitem_t *wi)
+srpc_handle_rpc(struct swi_workitem *wi)
 {
 	struct srpc_server_rpc *rpc = wi->swi_workitem.wi_data;
 	struct srpc_service_cd *scd = rpc->srpc_scd;
@@ -1140,7 +1140,7 @@ srpc_del_client_rpc_timer(srpc_client_rpc_t *rpc)
 static void
 srpc_client_rpc_done(srpc_client_rpc_t *rpc, int status)
 {
-	swi_workitem_t *wi = &rpc->crpc_wi;
+	struct swi_workitem *wi = &rpc->crpc_wi;
 
 	LASSERT(status || wi->swi_state == SWI_STATE_DONE);
 
@@ -1175,7 +1175,7 @@ srpc_client_rpc_done(srpc_client_rpc_t *rpc, int status)
 
 /* sends an outgoing RPC */
 int
-srpc_send_rpc(swi_workitem_t *wi)
+srpc_send_rpc(struct swi_workitem *wi)
 {
 	int rc = 0;
 	srpc_client_rpc_t *rpc;
diff --git a/drivers/staging/lustre/lnet/selftest/selftest.h b/drivers/staging/lustre/lnet/selftest/selftest.h
index 04e742e..d6799b6 100644
--- a/drivers/staging/lustre/lnet/selftest/selftest.h
+++ b/drivers/staging/lustre/lnet/selftest/selftest.h
@@ -175,19 +175,19 @@ struct srpc_buffer {
 struct swi_workitem;
 typedef int (*swi_action_t) (struct swi_workitem *);
 
-typedef struct swi_workitem {
+struct swi_workitem {
 	struct cfs_wi_sched *swi_sched;
 	struct cfs_workitem swi_workitem;
 	swi_action_t	    swi_action;
 	int		    swi_state;
-} swi_workitem_t;
+};
 
 /* server-side state of a RPC */
 struct srpc_server_rpc {
 	/* chain on srpc_service::*_rpcq */
 	struct list_head       srpc_list;
 	struct srpc_service_cd *srpc_scd;
-	swi_workitem_t	       srpc_wi;
+	struct swi_workitem	srpc_wi;
 	struct srpc_event	srpc_ev;	/* bulk/reply event */
 	lnet_nid_t	       srpc_self;
 	lnet_process_id_t      srpc_peer;
@@ -209,7 +209,7 @@ typedef struct srpc_client_rpc {
 	atomic_t	  crpc_refcount;
 	int		  crpc_timeout;   /* # seconds to wait for reply */
 	struct stt_timer       crpc_timer;
-	swi_workitem_t	  crpc_wi;
+	struct swi_workitem	crpc_wi;
 	lnet_process_id_t crpc_dest;
 
 	void		  (*crpc_done)(struct srpc_client_rpc *);
@@ -273,7 +273,7 @@ struct srpc_service_cd {
 	/** in-flight RPCs */
 	struct list_head	scd_rpc_active;
 	/** workitem for posting buffer */
-	swi_workitem_t		scd_buf_wi;
+	struct swi_workitem	scd_buf_wi;
 	/** CPT id */
 	int			scd_cpt;
 	/** error code for scd_buf_wi */
@@ -404,7 +404,7 @@ typedef struct sfw_test_unit {
 	int		    tsu_loop;	   /* loop count of the test */
 	sfw_test_instance_t *tsu_instance; /* pointer to test instance */
 	void		    *tsu_private;  /* private data */
-	swi_workitem_t	    tsu_worker;    /* workitem of the test unit */
+	struct swi_workitem	tsu_worker;	/* workitem of the test unit */
 } sfw_test_unit_t;
 
 typedef struct sfw_test_case {
@@ -440,7 +440,7 @@ void srpc_abort_rpc(srpc_client_rpc_t *rpc, int why);
 void srpc_free_bulk(struct srpc_bulk *bk);
 struct srpc_bulk *srpc_alloc_bulk(int cpt, unsigned bulk_npg,
 				  unsigned bulk_len, int sink);
-int srpc_send_rpc(swi_workitem_t *wi);
+int srpc_send_rpc(struct swi_workitem *wi);
 int srpc_send_reply(struct srpc_server_rpc *rpc);
 int srpc_add_service(srpc_service_t *sv);
 int srpc_remove_service(srpc_service_t *sv);
@@ -464,13 +464,15 @@ srpc_serv_is_framework(struct srpc_service *svc)
 static inline int
 swi_wi_action(struct cfs_workitem *wi)
 {
-	swi_workitem_t *swi = container_of(wi, swi_workitem_t, swi_workitem);
+	struct swi_workitem *swi;
+
+	swi = container_of(wi, struct swi_workitem, swi_workitem);
 
 	return swi->swi_action(swi);
 }
 
 static inline void
-swi_init_workitem(swi_workitem_t *swi, void *data,
+swi_init_workitem(struct swi_workitem *swi, void *data,
 		  swi_action_t action, struct cfs_wi_sched *sched)
 {
 	swi->swi_sched = sched;
@@ -480,19 +482,19 @@ swi_init_workitem(swi_workitem_t *swi, void *data,
 }
 
 static inline void
-swi_schedule_workitem(swi_workitem_t *wi)
+swi_schedule_workitem(struct swi_workitem *wi)
 {
 	cfs_wi_schedule(wi->swi_sched, &wi->swi_workitem);
 }
 
 static inline void
-swi_exit_workitem(swi_workitem_t *swi)
+swi_exit_workitem(struct swi_workitem *swi)
 {
 	cfs_wi_exit(swi->swi_sched, &swi->swi_workitem);
 }
 
 static inline int
-swi_deschedule_workitem(swi_workitem_t *swi)
+swi_deschedule_workitem(struct swi_workitem *swi)
 {
 	return cfs_wi_deschedule(swi->swi_sched, &swi->swi_workitem);
 }
-- 
1.7.1
