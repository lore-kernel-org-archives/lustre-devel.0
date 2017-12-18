From: NeilBrown <neilb@suse.com>
Date: Mon, 18 Dec 2017 12:25:19 +1100
Subject: [lustre-devel] [PATCH 2/4] staging: lustre: libcfs: remove wi_data
 from cfs_workitem
In-Reply-To: <151356013394.15912.9645528414310488005.stgit@noble>
References: <151356013394.15912.9645528414310488005.stgit@noble>
Message-ID: <151356031915.15912.4949412570489146428.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: lkml <linux-kernel@vger.kernel.org>, lustre <lustre-devel@lists.lustre.org>

In every case, the value passed via wi_data can be determined
from the cfs_workitem pointer using container_of().

So use container_of(), and discard wi_data.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../lustre/include/linux/libcfs/libcfs_workitem.h  |    5 +----
 drivers/staging/lustre/lnet/selftest/framework.c   |    4 ++--
 drivers/staging/lustre/lnet/selftest/rpc.c         |   10 +++++-----
 drivers/staging/lustre/lnet/selftest/selftest.h    |    6 +++---
 4 files changed, 11 insertions(+), 14 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_workitem.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_workitem.h
index fc780f608e57..ddaca33a13ac 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_workitem.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_workitem.h
@@ -75,8 +75,6 @@ struct cfs_workitem {
 	struct list_head       wi_list;
 	/** working function */
 	cfs_wi_action_t  wi_action;
-	/** arg for working function */
-	void	    *wi_data;
 	/** in running */
 	unsigned short   wi_running:1;
 	/** scheduled */
@@ -84,13 +82,12 @@ struct cfs_workitem {
 };
 
 static inline void
-cfs_wi_init(struct cfs_workitem *wi, void *data, cfs_wi_action_t action)
+cfs_wi_init(struct cfs_workitem *wi, cfs_wi_action_t action)
 {
 	INIT_LIST_HEAD(&wi->wi_list);
 
 	wi->wi_running   = 0;
 	wi->wi_scheduled = 0;
-	wi->wi_data      = data;
 	wi->wi_action    = action;
 }
 
diff --git a/drivers/staging/lustre/lnet/selftest/framework.c b/drivers/staging/lustre/lnet/selftest/framework.c
index 4592ece98d95..2e1126552e18 100644
--- a/drivers/staging/lustre/lnet/selftest/framework.c
+++ b/drivers/staging/lustre/lnet/selftest/framework.c
@@ -944,7 +944,7 @@ sfw_create_test_rpc(struct sfw_test_unit *tsu, struct lnet_process_id peer,
 static int
 sfw_run_test(struct swi_workitem *wi)
 {
-	struct sfw_test_unit *tsu = wi->swi_workitem.wi_data;
+	struct sfw_test_unit *tsu = container_of(wi, struct sfw_test_unit, tsu_worker);
 	struct sfw_test_instance *tsi = tsu->tsu_instance;
 	struct srpc_client_rpc *rpc = NULL;
 
@@ -1016,7 +1016,7 @@ sfw_run_batch(struct sfw_batch *tsb)
 			atomic_inc(&tsi->tsi_nactive);
 			tsu->tsu_loop = tsi->tsi_loop;
 			wi = &tsu->tsu_worker;
-			swi_init_workitem(wi, tsu, sfw_run_test,
+			swi_init_workitem(wi, sfw_run_test,
 					  lst_sched_test[lnet_cpt_of_nid(tsu->tsu_dest.nid)]);
 			swi_schedule_workitem(wi);
 		}
diff --git a/drivers/staging/lustre/lnet/selftest/rpc.c b/drivers/staging/lustre/lnet/selftest/rpc.c
index e195b9ee544c..4ebb5a1107be 100644
--- a/drivers/staging/lustre/lnet/selftest/rpc.c
+++ b/drivers/staging/lustre/lnet/selftest/rpc.c
@@ -176,7 +176,7 @@ srpc_init_server_rpc(struct srpc_server_rpc *rpc,
 		     struct srpc_buffer *buffer)
 {
 	memset(rpc, 0, sizeof(*rpc));
-	swi_init_workitem(&rpc->srpc_wi, rpc, srpc_handle_rpc,
+	swi_init_workitem(&rpc->srpc_wi, srpc_handle_rpc,
 			  srpc_serv_is_framework(scd->scd_svc) ?
 			  lst_sched_serial : lst_sched_test[scd->scd_cpt]);
 
@@ -280,7 +280,7 @@ srpc_service_init(struct srpc_service *svc)
 		 * NB: don't use lst_sched_serial for adding buffer,
 		 * see details in srpc_service_add_buffers()
 		 */
-		swi_init_workitem(&scd->scd_buf_wi, scd,
+		swi_init_workitem(&scd->scd_buf_wi,
 				  srpc_add_buffer, lst_sched_test[i]);
 
 		if (i && srpc_serv_is_framework(svc)) {
@@ -517,7 +517,7 @@ __must_hold(&scd->scd_lock)
 int
 srpc_add_buffer(struct swi_workitem *wi)
 {
-	struct srpc_service_cd *scd = wi->swi_workitem.wi_data;
+	struct srpc_service_cd *scd = container_of(wi, struct srpc_service_cd, scd_buf_wi);
 	struct srpc_buffer *buf;
 	int rc = 0;
 
@@ -968,7 +968,7 @@ srpc_server_rpc_done(struct srpc_server_rpc *rpc, int status)
 int
 srpc_handle_rpc(struct swi_workitem *wi)
 {
-	struct srpc_server_rpc *rpc = wi->swi_workitem.wi_data;
+	struct srpc_server_rpc *rpc = container_of(wi, struct srpc_server_rpc, srpc_wi);
 	struct srpc_service_cd *scd = rpc->srpc_scd;
 	struct srpc_service *sv = scd->scd_svc;
 	struct srpc_event *ev = &rpc->srpc_ev;
@@ -1188,7 +1188,7 @@ srpc_send_rpc(struct swi_workitem *wi)
 
 	LASSERT(wi);
 
-	rpc = wi->swi_workitem.wi_data;
+	rpc = container_of(wi, struct srpc_client_rpc, crpc_wi);
 
 	LASSERT(rpc);
 	LASSERT(wi == &rpc->crpc_wi);
diff --git a/drivers/staging/lustre/lnet/selftest/selftest.h b/drivers/staging/lustre/lnet/selftest/selftest.h
index b23a953d8efe..465417263ef1 100644
--- a/drivers/staging/lustre/lnet/selftest/selftest.h
+++ b/drivers/staging/lustre/lnet/selftest/selftest.h
@@ -476,13 +476,13 @@ swi_wi_action(struct cfs_workitem *wi)
 }
 
 static inline void
-swi_init_workitem(struct swi_workitem *swi, void *data,
+swi_init_workitem(struct swi_workitem *swi,
 		  swi_action_t action, struct cfs_wi_sched *sched)
 {
 	swi->swi_sched = sched;
 	swi->swi_action = action;
 	swi->swi_state = SWI_STATE_NEWBORN;
-	cfs_wi_init(&swi->swi_workitem, data, swi_wi_action);
+	cfs_wi_init(&swi->swi_workitem, swi_wi_action);
 }
 
 static inline void
@@ -533,7 +533,7 @@ srpc_init_client_rpc(struct srpc_client_rpc *rpc, struct lnet_process_id peer,
 				crpc_bulk.bk_iovs[nbulkiov]));
 
 	INIT_LIST_HEAD(&rpc->crpc_list);
-	swi_init_workitem(&rpc->crpc_wi, rpc, srpc_send_rpc,
+	swi_init_workitem(&rpc->crpc_wi, srpc_send_rpc,
 			  lst_sched_test[lnet_cpt_of_nid(peer.nid)]);
 	spin_lock_init(&rpc->crpc_lock);
 	atomic_set(&rpc->crpc_refcount, 1); /* 1 ref for caller */
