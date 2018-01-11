From: NeilBrown <neilb@suse.com>
Date: Thu, 11 Jan 2018 15:06:40 +1100
Subject: [lustre-devel] [PATCH 1/2] staging: lustre: lnet: convert selftest
 to use workqueues
In-Reply-To: <151564345630.21794.1667069238139184132.stgit@noble>
References: <151564345630.21794.1667069238139184132.stgit@noble>
Message-ID: <151564360053.21794.4058863911958997341.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, James Simmons <jsimmons@infradead.org>, Andreas Dilger <andreas.dilger@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Tejun Heo <tj@kernel.org>

Instead of the cfs workitem library, use workqueues.

As lnet wants to provide a cpu mask of allowed cpus, it
needs to be a WQ_UNBOUND work queue so that tasks can
run on cpus other than where they were submitted.

This patch also exported apply_workqueue_attrs() which is
a documented part of the workqueue API, that isn't currently
exported.  lustre needs it to allow workqueue thread to be limited
to a subset of CPUs.

Acked-by: Tejun Heo <tj@kernel.org> (for export of apply_workqueue_attrs)
Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lnet/selftest/framework.c |   10 +---
 drivers/staging/lustre/lnet/selftest/module.c    |   39 ++++++++------
 drivers/staging/lustre/lnet/selftest/rpc.c       |   61 +++++++++-------------
 drivers/staging/lustre/lnet/selftest/selftest.h  |   40 ++++++--------
 kernel/workqueue.c                               |    1 
 5 files changed, 69 insertions(+), 82 deletions(-)

diff --git a/drivers/staging/lustre/lnet/selftest/framework.c b/drivers/staging/lustre/lnet/selftest/framework.c
index 2e1126552e18..c7697f66f663 100644
--- a/drivers/staging/lustre/lnet/selftest/framework.c
+++ b/drivers/staging/lustre/lnet/selftest/framework.c
@@ -941,15 +941,13 @@ sfw_create_test_rpc(struct sfw_test_unit *tsu, struct lnet_process_id peer,
 	return 0;
 }
 
-static int
+static void
 sfw_run_test(struct swi_workitem *wi)
 {
 	struct sfw_test_unit *tsu = container_of(wi, struct sfw_test_unit, tsu_worker);
 	struct sfw_test_instance *tsi = tsu->tsu_instance;
 	struct srpc_client_rpc *rpc = NULL;
 
-	LASSERT(wi == &tsu->tsu_worker);
-
 	if (tsi->tsi_ops->tso_prep_rpc(tsu, tsu->tsu_dest, &rpc)) {
 		LASSERT(!rpc);
 		goto test_done;
@@ -975,7 +973,7 @@ sfw_run_test(struct swi_workitem *wi)
 	rpc->crpc_timeout = rpc_timeout;
 	srpc_post_rpc(rpc);
 	spin_unlock(&rpc->crpc_lock);
-	return 0;
+	return;
 
 test_done:
 	/*
@@ -985,9 +983,7 @@ sfw_run_test(struct swi_workitem *wi)
 	 * - my batch is still active; no one can run it again now.
 	 * Cancel pending schedules and prevent future schedule attempts:
 	 */
-	swi_exit_workitem(wi);
 	sfw_test_unit_done(tsu);
-	return 1;
 }
 
 static int
@@ -1017,7 +1013,7 @@ sfw_run_batch(struct sfw_batch *tsb)
 			tsu->tsu_loop = tsi->tsi_loop;
 			wi = &tsu->tsu_worker;
 			swi_init_workitem(wi, sfw_run_test,
-					  lst_sched_test[lnet_cpt_of_nid(tsu->tsu_dest.nid)]);
+					  lst_test_wq[lnet_cpt_of_nid(tsu->tsu_dest.nid)]);
 			swi_schedule_workitem(wi);
 		}
 	}
diff --git a/drivers/staging/lustre/lnet/selftest/module.c b/drivers/staging/lustre/lnet/selftest/module.c
index ba4b6145c953..aa6bfd5baf2f 100644
--- a/drivers/staging/lustre/lnet/selftest/module.c
+++ b/drivers/staging/lustre/lnet/selftest/module.c
@@ -47,8 +47,8 @@ enum {
 
 static int lst_init_step = LST_INIT_NONE;
 
-struct cfs_wi_sched *lst_sched_serial;
-struct cfs_wi_sched **lst_sched_test;
+struct workqueue_struct *lst_serial_wq;
+struct workqueue_struct **lst_test_wq;
 
 static void
 lnet_selftest_exit(void)
@@ -68,16 +68,16 @@ lnet_selftest_exit(void)
 	case LST_INIT_WI_TEST:
 		for (i = 0;
 		     i < cfs_cpt_number(lnet_cpt_table()); i++) {
-			if (!lst_sched_test[i])
+			if (!lst_test_wq[i])
 				continue;
-			cfs_wi_sched_destroy(lst_sched_test[i]);
+			destroy_workqueue(lst_test_wq[i]);
 		}
-		kvfree(lst_sched_test);
-		lst_sched_test = NULL;
+		kvfree(lst_test_wq);
+		lst_test_wq = NULL;
 		/* fall through */
 	case LST_INIT_WI_SERIAL:
-		cfs_wi_sched_destroy(lst_sched_serial);
-		lst_sched_serial = NULL;
+		destroy_workqueue(lst_serial_wq);
+		lst_serial_wq = NULL;
 	case LST_INIT_NONE:
 		break;
 	default:
@@ -92,33 +92,40 @@ lnet_selftest_init(void)
 	int rc;
 	int i;
 
-	rc = cfs_wi_sched_create("lst_s", lnet_cpt_table(), CFS_CPT_ANY,
-				 1, &lst_sched_serial);
-	if (rc) {
+	lst_serial_wq = alloc_ordered_workqueue("lst_s", 0);
+	if (!lst_serial_wq) {
 		CERROR("Failed to create serial WI scheduler for LST\n");
 		return rc;
 	}
 	lst_init_step = LST_INIT_WI_SERIAL;
 
 	nscheds = cfs_cpt_number(lnet_cpt_table());
-	lst_sched_test = kvmalloc_array(nscheds, sizeof(lst_sched_test[0]),
+	lst_test_wq = kvmalloc_array(nscheds, sizeof(lst_test_wq[0]),
 					GFP_KERNEL | __GFP_ZERO);
-	if (!lst_sched_test)
+	if (!lst_test_wq)
 		goto error;
 
 	lst_init_step = LST_INIT_WI_TEST;
 	for (i = 0; i < nscheds; i++) {
 		int nthrs = cfs_cpt_weight(lnet_cpt_table(), i);
+		struct workqueue_attrs attrs;
 
 		/* reserve@least one CPU for LND */
 		nthrs = max(nthrs - 1, 1);
-		rc = cfs_wi_sched_create("lst_t", lnet_cpt_table(), i,
-					 nthrs, &lst_sched_test[i]);
-		if (rc) {
+		lst_test_wq[i] = alloc_workqueue("lst_t", WQ_UNBOUND, nthrs);
+		if (!lst_test_wq[i]) {
 			CWARN("Failed to create CPU partition affinity WI scheduler %d for LST\n",
 			      i);
 			goto error;
 		}
+		attrs.nice = 0;
+		#ifdef CONFIG_CPUMASK_OFFSTACK
+		attrs.cpumask = lnet_cpt_table()->ctb_parts[i].cpt_cpumask;
+		#else
+		cpumask_copy(attrs.cpumask, lnet_cpt_table()->ctb_parts[i].cpt_cpumask);
+		#endif
+		attrs.no_numa = false;
+		apply_workqueue_attrs(lst_test_wq[i], &attrs);
 	}
 
 	rc = srpc_startup();
diff --git a/drivers/staging/lustre/lnet/selftest/rpc.c b/drivers/staging/lustre/lnet/selftest/rpc.c
index b6c9ab92c288..f8198ad1046e 100644
--- a/drivers/staging/lustre/lnet/selftest/rpc.c
+++ b/drivers/staging/lustre/lnet/selftest/rpc.c
@@ -68,7 +68,7 @@ srpc_serv_portal(int svc_id)
 }
 
 /* forward ref's */
-int srpc_handle_rpc(struct swi_workitem *wi);
+void srpc_handle_rpc(struct swi_workitem *wi);
 
 void srpc_get_counters(struct srpc_counters *cnt)
 {
@@ -178,7 +178,7 @@ srpc_init_server_rpc(struct srpc_server_rpc *rpc,
 	memset(rpc, 0, sizeof(*rpc));
 	swi_init_workitem(&rpc->srpc_wi, srpc_handle_rpc,
 			  srpc_serv_is_framework(scd->scd_svc) ?
-			  lst_sched_serial : lst_sched_test[scd->scd_cpt]);
+			  lst_serial_wq : lst_test_wq[scd->scd_cpt]);
 
 	rpc->srpc_ev.ev_fired = 1; /* no event expected now */
 
@@ -242,7 +242,7 @@ srpc_service_nrpcs(struct srpc_service *svc)
 	       max(nrpcs, SFW_FRWK_WI_MIN) : max(nrpcs, SFW_TEST_WI_MIN);
 }
 
-int srpc_add_buffer(struct swi_workitem *wi);
+void srpc_add_buffer(struct swi_workitem *wi);
 
 static int
 srpc_service_init(struct srpc_service *svc)
@@ -277,11 +277,11 @@ srpc_service_init(struct srpc_service *svc)
 		scd->scd_ev.ev_type = SRPC_REQUEST_RCVD;
 
 		/*
-		 * NB: don't use lst_sched_serial for adding buffer,
+		 * NB: don't use lst_serial_wq for adding buffer,
 		 * see details in srpc_service_add_buffers()
 		 */
 		swi_init_workitem(&scd->scd_buf_wi,
-				  srpc_add_buffer, lst_sched_test[i]);
+				  srpc_add_buffer, lst_test_wq[i]);
 
 		if (i && srpc_serv_is_framework(svc)) {
 			/*
@@ -513,7 +513,7 @@ __must_hold(&scd->scd_lock)
 	return rc;
 }
 
-int
+void
 srpc_add_buffer(struct swi_workitem *wi)
 {
 	struct srpc_service_cd *scd = container_of(wi, struct srpc_service_cd, scd_buf_wi);
@@ -572,7 +572,6 @@ srpc_add_buffer(struct swi_workitem *wi)
 	}
 
 	spin_unlock(&scd->scd_lock);
-	return 0;
 }
 
 int
@@ -604,15 +603,15 @@ srpc_service_add_buffers(struct srpc_service *sv, int nbuffer)
 		spin_lock(&scd->scd_lock);
 		/*
 		 * NB: srpc_service_add_buffers() can be called inside
-		 * thread context of lst_sched_serial, and we don't normally
+		 * thread context of lst_serial_wq, and we don't normally
 		 * allow to sleep inside thread context of WI scheduler
 		 * because it will block current scheduler thread from doing
 		 * anything else, even worse, it could deadlock if it's
 		 * waiting on result from another WI of the same scheduler.
 		 * However, it's safe at here because scd_buf_wi is scheduled
-		 * by thread in a different WI scheduler (lst_sched_test),
+		 * by thread in a different WI scheduler (lst_test_wq),
 		 * so we don't have any risk of deadlock, though this could
-		 * block all WIs pending on lst_sched_serial for a moment
+		 * block all WIs pending on lst_serial_wq for a moment
 		 * which is not good but not fatal.
 		 */
 		lst_wait_until(scd->scd_buf_err ||
@@ -659,11 +658,9 @@ srpc_finish_service(struct srpc_service *sv)
 	LASSERT(sv->sv_shuttingdown); /* srpc_shutdown_service called */
 
 	cfs_percpt_for_each(scd, i, sv->sv_cpt_data) {
+		swi_cancel_workitem(&scd->scd_buf_wi);
+
 		spin_lock(&scd->scd_lock);
-		if (!swi_deschedule_workitem(&scd->scd_buf_wi)) {
-			spin_unlock(&scd->scd_lock);
-			return 0;
-		}
 
 		if (scd->scd_buf_nposted > 0) {
 			CDEBUG(D_NET, "waiting for %d posted buffers to unlink\n",
@@ -679,11 +676,9 @@ srpc_finish_service(struct srpc_service *sv)
 
 		rpc = list_entry(scd->scd_rpc_active.next,
 				 struct srpc_server_rpc, srpc_list);
-		CNETERR("Active RPC %p on shutdown: sv %s, peer %s, wi %s scheduled %d running %d, ev fired %d type %d status %d lnet %d\n",
+		CNETERR("Active RPC %p on shutdown: sv %s, peer %s, wi %s, ev fired %d type %d status %d lnet %d\n",
 			rpc, sv->sv_name, libcfs_id2str(rpc->srpc_peer),
 			swi_state2str(rpc->srpc_wi.swi_state),
-			rpc->srpc_wi.swi_workitem.wi_scheduled,
-			rpc->srpc_wi.swi_workitem.wi_running,
 			rpc->srpc_ev.ev_fired, rpc->srpc_ev.ev_type,
 			rpc->srpc_ev.ev_status, rpc->srpc_ev.ev_lnet);
 		spin_unlock(&scd->scd_lock);
@@ -946,7 +941,6 @@ srpc_server_rpc_done(struct srpc_server_rpc *rpc, int status)
 	 * Cancel pending schedules and prevent future schedule attempts:
 	 */
 	LASSERT(rpc->srpc_ev.ev_fired);
-	swi_exit_workitem(&rpc->srpc_wi);
 
 	if (!sv->sv_shuttingdown && !list_empty(&scd->scd_buf_blocked)) {
 		buffer = list_entry(scd->scd_buf_blocked.next,
@@ -964,7 +958,7 @@ srpc_server_rpc_done(struct srpc_server_rpc *rpc, int status)
 }
 
 /* handles an incoming RPC */
-int
+void
 srpc_handle_rpc(struct swi_workitem *wi)
 {
 	struct srpc_server_rpc *rpc = container_of(wi, struct srpc_server_rpc, srpc_wi);
@@ -986,9 +980,8 @@ srpc_handle_rpc(struct swi_workitem *wi)
 
 		if (ev->ev_fired) { /* no more event, OK to finish */
 			srpc_server_rpc_done(rpc, -ESHUTDOWN);
-			return 1;
 		}
-		return 0;
+		return;
 	}
 
 	spin_unlock(&scd->scd_lock);
@@ -1006,7 +999,7 @@ srpc_handle_rpc(struct swi_workitem *wi)
 		if (!msg->msg_magic) {
 			/* moaned already in srpc_lnet_ev_handler */
 			srpc_server_rpc_done(rpc, EBADMSG);
-			return 1;
+			return;
 		}
 
 		srpc_unpack_msg_hdr(msg);
@@ -1022,7 +1015,7 @@ srpc_handle_rpc(struct swi_workitem *wi)
 			LASSERT(!reply->status || !rpc->srpc_bulk);
 			if (rc) {
 				srpc_server_rpc_done(rpc, rc);
-				return 1;
+				return;
 			}
 		}
 
@@ -1031,7 +1024,7 @@ srpc_handle_rpc(struct swi_workitem *wi)
 		if (rpc->srpc_bulk) {
 			rc = srpc_do_bulk(rpc);
 			if (!rc)
-				return 0; /* wait for bulk */
+				return; /* wait for bulk */
 
 			LASSERT(ev->ev_fired);
 			ev->ev_status = rc;
@@ -1049,16 +1042,16 @@ srpc_handle_rpc(struct swi_workitem *wi)
 
 			if (rc) {
 				srpc_server_rpc_done(rpc, rc);
-				return 1;
+				return;
 			}
 		}
 
 		wi->swi_state = SWI_STATE_REPLY_SUBMITTED;
 		rc = srpc_send_reply(rpc);
 		if (!rc)
-			return 0; /* wait for reply */
+			return; /* wait for reply */
 		srpc_server_rpc_done(rpc, rc);
-		return 1;
+		return;
 
 	case SWI_STATE_REPLY_SUBMITTED:
 		if (!ev->ev_fired) {
@@ -1071,10 +1064,8 @@ srpc_handle_rpc(struct swi_workitem *wi)
 
 		wi->swi_state = SWI_STATE_DONE;
 		srpc_server_rpc_done(rpc, ev->ev_status);
-		return 1;
+		return;
 	}
-
-	return 0;
 }
 
 static void
@@ -1169,7 +1160,6 @@ srpc_client_rpc_done(struct srpc_client_rpc *rpc, int status)
 	 * Cancel pending schedules and prevent future schedule attempts:
 	 */
 	LASSERT(!srpc_event_pending(rpc));
-	swi_exit_workitem(wi);
 
 	spin_unlock(&rpc->crpc_lock);
 
@@ -1177,7 +1167,7 @@ srpc_client_rpc_done(struct srpc_client_rpc *rpc, int status)
 }
 
 /* sends an outgoing RPC */
-int
+void
 srpc_send_rpc(struct swi_workitem *wi)
 {
 	int rc = 0;
@@ -1213,7 +1203,7 @@ srpc_send_rpc(struct swi_workitem *wi)
 		rc = srpc_prepare_reply(rpc);
 		if (rc) {
 			srpc_client_rpc_done(rpc, rc);
-			return 1;
+			return;
 		}
 
 		rc = srpc_prepare_bulk(rpc);
@@ -1290,7 +1280,7 @@ srpc_send_rpc(struct swi_workitem *wi)
 
 		wi->swi_state = SWI_STATE_DONE;
 		srpc_client_rpc_done(rpc, rc);
-		return 1;
+		return;
 	}
 
 	if (rc) {
@@ -1307,10 +1297,9 @@ srpc_send_rpc(struct swi_workitem *wi)
 
 		if (!srpc_event_pending(rpc)) {
 			srpc_client_rpc_done(rpc, -EINTR);
-			return 1;
+			return;
 		}
 	}
-	return 0;
 }
 
 struct srpc_client_rpc *
diff --git a/drivers/staging/lustre/lnet/selftest/selftest.h b/drivers/staging/lustre/lnet/selftest/selftest.h
index 465417263ef1..ad04534f000c 100644
--- a/drivers/staging/lustre/lnet/selftest/selftest.h
+++ b/drivers/staging/lustre/lnet/selftest/selftest.h
@@ -169,11 +169,11 @@ struct srpc_buffer {
 };
 
 struct swi_workitem;
-typedef int (*swi_action_t) (struct swi_workitem *);
+typedef void (*swi_action_t) (struct swi_workitem *);
 
 struct swi_workitem {
-	struct cfs_wi_sched *swi_sched;
-	struct cfs_workitem swi_workitem;
+	struct workqueue_struct *swi_wq;
+	struct work_struct  swi_work;
 	swi_action_t	    swi_action;
 	int		    swi_state;
 };
@@ -444,7 +444,7 @@ void srpc_free_bulk(struct srpc_bulk *bk);
 struct srpc_bulk *srpc_alloc_bulk(int cpt, unsigned int off,
 				  unsigned int bulk_npg, unsigned int bulk_len,
 				  int sink);
-int srpc_send_rpc(struct swi_workitem *wi);
+void srpc_send_rpc(struct swi_workitem *wi);
 int srpc_send_reply(struct srpc_server_rpc *rpc);
 int srpc_add_service(struct srpc_service *sv);
 int srpc_remove_service(struct srpc_service *sv);
@@ -456,8 +456,8 @@ void srpc_service_remove_buffers(struct srpc_service *sv, int nbuffer);
 void srpc_get_counters(struct srpc_counters *cnt);
 void srpc_set_counters(const struct srpc_counters *cnt);
 
-extern struct cfs_wi_sched *lst_sched_serial;
-extern struct cfs_wi_sched **lst_sched_test;
+extern struct workqueue_struct *lst_serial_wq;
+extern struct workqueue_struct **lst_test_wq;
 
 static inline int
 srpc_serv_is_framework(struct srpc_service *svc)
@@ -465,42 +465,36 @@ srpc_serv_is_framework(struct srpc_service *svc)
 	return svc->sv_id < SRPC_FRAMEWORK_SERVICE_MAX_ID;
 }
 
-static inline int
-swi_wi_action(struct cfs_workitem *wi)
+static void
+swi_wi_action(struct work_struct *wi)
 {
 	struct swi_workitem *swi;
 
-	swi = container_of(wi, struct swi_workitem, swi_workitem);
+	swi = container_of(wi, struct swi_workitem, swi_work);
 
-	return swi->swi_action(swi);
+	swi->swi_action(swi);
 }
 
 static inline void
 swi_init_workitem(struct swi_workitem *swi,
-		  swi_action_t action, struct cfs_wi_sched *sched)
+		  swi_action_t action, struct workqueue_struct *wq)
 {
-	swi->swi_sched = sched;
+	swi->swi_wq = wq;
 	swi->swi_action = action;
 	swi->swi_state = SWI_STATE_NEWBORN;
-	cfs_wi_init(&swi->swi_workitem, swi_wi_action);
+	INIT_WORK(&swi->swi_work, swi_wi_action);
 }
 
 static inline void
 swi_schedule_workitem(struct swi_workitem *wi)
 {
-	cfs_wi_schedule(wi->swi_sched, &wi->swi_workitem);
-}
-
-static inline void
-swi_exit_workitem(struct swi_workitem *swi)
-{
-	cfs_wi_exit(swi->swi_sched, &swi->swi_workitem);
+	queue_work(wi->swi_wq, &wi->swi_work);
 }
 
 static inline int
-swi_deschedule_workitem(struct swi_workitem *swi)
+swi_cancel_workitem(struct swi_workitem *swi)
 {
-	return cfs_wi_deschedule(swi->swi_sched, &swi->swi_workitem);
+	return cancel_work_sync(&swi->swi_work);
 }
 
 int sfw_startup(void);
@@ -534,7 +528,7 @@ srpc_init_client_rpc(struct srpc_client_rpc *rpc, struct lnet_process_id peer,
 
 	INIT_LIST_HEAD(&rpc->crpc_list);
 	swi_init_workitem(&rpc->crpc_wi, srpc_send_rpc,
-			  lst_sched_test[lnet_cpt_of_nid(peer.nid)]);
+			  lst_test_wq[lnet_cpt_of_nid(peer.nid)]);
 	spin_lock_init(&rpc->crpc_lock);
 	atomic_set(&rpc->crpc_refcount, 1); /* 1 ref for caller */
 
diff --git a/kernel/workqueue.c b/kernel/workqueue.c
index 43d18cb46308..d1d460bb9b02 100644
--- a/kernel/workqueue.c
+++ b/kernel/workqueue.c
@@ -3806,6 +3806,7 @@ int apply_workqueue_attrs(struct workqueue_struct *wq,
 
 	return ret;
 }
+EXPORT_SYMBOL_GPL(apply_workqueue_attrs);
 
 /**
  * wq_update_unbound_numa - update NUMA affinity of a wq for CPU hot[un]plug
