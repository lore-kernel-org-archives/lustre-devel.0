Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 79AA9C0218F
	for <lustre-devel@archiver.kernel.org>; Sun,  2 Feb 2025 20:53:23 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4YmMD65BLvz1yG6;
	Sun, 02 Feb 2025 12:48:38 -0800 (PST)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4YmMBN2jtcz1yWh
 for <lustre-devel@lists.lustre.org>; Sun, 02 Feb 2025 12:47:08 -0800 (PST)
Received: from star2.ccs.ornl.gov (ltm3-e204-208.ccs.ornl.gov [160.91.203.26])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id B970B182336;
 Sun,  2 Feb 2025 15:46:41 -0500 (EST)
Received: by star2.ccs.ornl.gov (Postfix, from userid 2004)
 id B5C6E106BE18; Sun,  2 Feb 2025 15:46:41 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun,  2 Feb 2025 15:46:08 -0500
Message-ID: <20250202204633.1148872-9-jsimmons@infradead.org>
X-Mailer: git-send-email 2.43.5
In-Reply-To: <20250202204633.1148872-1-jsimmons@infradead.org>
References: <20250202204633.1148872-1-jsimmons@infradead.org>
MIME-Version: 1.0
Subject: [lustre-devel] [PATCH 08/33] lnet: selftest: manage the workqueue
 state properly
X-BeenThere: lustre-devel@lists.lustre.org
X-Mailman-Version: 2.1.39
Precedence: list
List-Id: "For discussing Lustre software development."
 <lustre-devel-lustre.org>
List-Unsubscribe: <http://lists.lustre.org/options.cgi/lustre-devel-lustre.org>, 
 <mailto:lustre-devel-request@lists.lustre.org?subject=unsubscribe>
List-Archive: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/>
List-Post: <mailto:lustre-devel@lists.lustre.org>
List-Help: <mailto:lustre-devel-request@lists.lustre.org?subject=help>
List-Subscribe: <http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org>, 
 <mailto:lustre-devel-request@lists.lustre.org?subject=subscribe>
Cc: Chris Horn <chris.horn@hpe.com>, Frank Sehr <fsehr@whamcloud.com>,
 Serguei Smirnov <ssmirnov@whamcloud.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Mr NeilBrown <neilb@suse.de>

As lnet wants to provide a cpu mask of allowed cpus, it
needs to be a WQ_UNBOUND work queue so that tasks can
run on cpus other than where they were submitted.
We use alloc_ordered_workqueue for lst_sched_serial (now called
lst_serial_wq) - "ordered" means the same as "serial" did.
We use cfs_cpt_bind_queue() for the other workqueues which sets up the
CPU mask as required.

An important difference with workqueues is that there is no equivalent
to cfs_wi_exit() which can be called in the action function and which
will ensure the function is not called again - and that the item is no
longer queued.

To provide similar semantics we treat swi_state == SWI_STATE_DONE as
meaning that the wi is complete and any further calls must be no-op.
We also call cancel_work_sync() (via swi_cancel_workitem()) before
freeing or reusing memory that held a work-item.

To ensure the same exclusion that cfs_wi_exit() provided the state is
set and tested under a lock - either crpc_lock, scd_lock, or tsi_lock
depending on which structure the wi is embedded in.

Another minor difference is that with workqueues the action function
returns void, not an int.

Also change SWI_STATE_* from #define to an enum.  The only place these
values are ever stored is in one field in a struct.

These changes allow LNe selftest to work again.

Fixes: 6106c0f824 ("staging: lustre: lnet: convert selftest to use workqueues")
WC-bug-id: https://jira.whamcloud.com/browse/LU-9859
Lustre-commit: 51dd6269c91dab7543 ("LU-9859 lnet: convert selftest to use workqueues")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/36991
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: Chris Horn <chris.horn@hpe.com>
Reviewed-by: Frank Sehr <fsehr@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/selftest/framework.c | 29 +++++++++++++++++++++--------
 net/lnet/selftest/module.c    | 15 +++++++++------
 net/lnet/selftest/rpc.c       | 31 ++++++++++++++++---------------
 net/lnet/selftest/selftest.h  | 27 +++++++++++++++------------
 4 files changed, 61 insertions(+), 41 deletions(-)

diff --git a/net/lnet/selftest/framework.c b/net/lnet/selftest/framework.c
index 0dd0421ef8f6..4a7dbc9d786c 100644
--- a/net/lnet/selftest/framework.c
+++ b/net/lnet/selftest/framework.c
@@ -545,6 +545,7 @@ sfw_test_rpc_fini(struct srpc_client_rpc *rpc)
 
 	/* Called with hold of tsi->tsi_lock */
 	LASSERT(list_empty(&rpc->crpc_list));
+	rpc->crpc_wi.swi_state = SWI_STATE_DONE;
 	list_add(&rpc->crpc_list, &tsi->tsi_free_rpcs);
 }
 
@@ -651,6 +652,7 @@ sfw_destroy_test_instance(struct sfw_test_instance *tsi)
 					       struct srpc_client_rpc,
 					       crpc_list)) != NULL) {
 		list_del(&rpc->crpc_list);
+		swi_cancel_workitem(&rpc->crpc_wi);
 		kfree(rpc);
 	}
 
@@ -937,6 +939,7 @@ sfw_create_test_rpc(struct sfw_test_unit *tsu, struct lnet_process_id peer,
 					     blklen, sfw_test_rpc_done,
 					     sfw_test_rpc_fini, tsu);
 	} else {
+		swi_cancel_workitem(&rpc->crpc_wi);
 		srpc_init_client_rpc(rpc, peer, tsi->tsi_service, nblk,
 				     blklen, sfw_test_rpc_done,
 				     sfw_test_rpc_fini, tsu);
@@ -962,14 +965,20 @@ sfw_run_test(struct swi_workitem *wi)
 
 	if (tsi->tsi_ops->tso_prep_rpc(tsu, tsu->tsu_dest, &rpc)) {
 		LASSERT(!rpc);
+		wi->swi_state = SWI_STATE_DONE;
 		goto test_done;
 	}
 
 	LASSERT(rpc);
 
 	spin_lock(&tsi->tsi_lock);
+	if (wi->swi_state == SWI_STATE_DONE) {
+		spin_unlock(&tsi->tsi_lock);
+		return;
+	}
 
 	if (tsi->tsi_stopping) {
+		wi->swi_state = SWI_STATE_DONE;
 		list_add(&rpc->crpc_list, &tsi->tsi_free_rpcs);
 		spin_unlock(&tsi->tsi_lock);
 		goto test_done;
@@ -979,6 +988,7 @@ sfw_run_test(struct swi_workitem *wi)
 		tsu->tsu_loop--;
 
 	list_add_tail(&rpc->crpc_list, &tsi->tsi_active_rpcs);
+	wi->swi_state = SWI_STATE_RUNNING;
 	spin_unlock(&tsi->tsi_lock);
 
 	spin_lock(&rpc->crpc_lock);
@@ -1021,12 +1031,14 @@ sfw_run_batch(struct sfw_batch *tsb)
 		atomic_inc(&tsb->bat_nactive);
 
 		list_for_each_entry(tsu, &tsi->tsi_units, tsu_list) {
+			int cpt;
+
 			atomic_inc(&tsi->tsi_nactive);
 			tsu->tsu_loop = tsi->tsi_loop;
 			wi = &tsu->tsu_worker;
-			swi_init_workitem(wi, sfw_run_test,
-					  lst_test_wq[lnet_cpt_of_nid(tsu->tsu_dest.nid,
-							  NULL)]);
+
+			cpt = lnet_cpt_of_nid(tsu->tsu_dest.nid, NULL);
+			swi_init_workitem(wi, sfw_run_test, lst_test_wq[cpt]);
 			swi_schedule_workitem(wi);
 		}
 	}
@@ -1406,14 +1418,15 @@ sfw_create_rpc(struct lnet_process_id peer, int service,
 		rpc = list_first_entry(&sfw_data.fw_zombie_rpcs,
 				       struct srpc_client_rpc, crpc_list);
 		list_del(&rpc->crpc_list);
-
-		srpc_init_client_rpc(rpc, peer, service, 0, 0,
-				     done, sfw_client_rpc_fini, priv);
 	}
-
 	spin_unlock(&sfw_data.fw_lock);
 
-	if (!rpc) {
+	if (rpc) {
+		/* Ensure that rpc is done */
+		swi_cancel_workitem(&rpc->crpc_wi);
+		srpc_init_client_rpc(rpc, peer, service, 0, 0,
+				     done, sfw_client_rpc_fini, priv);
+	} else {
 		rpc = srpc_create_client_rpc(peer, service,
 					     nbulkiov, bulklen, done,
 					     nbulkiov ?  NULL :
diff --git a/net/lnet/selftest/module.c b/net/lnet/selftest/module.c
index 333f392b22bc..3743bce0cccd 100644
--- a/net/lnet/selftest/module.c
+++ b/net/lnet/selftest/module.c
@@ -88,7 +88,7 @@ static int
 lnet_selftest_init(void)
 {
 	int nscheds;
-	int rc;
+	int rc = -ENOMEM;
 	int i;
 
 	rc = libcfs_setup();
@@ -118,11 +118,14 @@ lnet_selftest_init(void)
 
 		/* reserve at least one CPU for LND */
 		nthrs = max(nthrs - 1, 1);
-		lst_test_wq[i] = alloc_workqueue("lst_t", WQ_UNBOUND, nthrs);
-		if (!lst_test_wq[i]) {
-			CWARN("Failed to create CPU partition affinity WI scheduler %d for LST\n",
-			      i);
-			rc = -ENOMEM;
+		lst_test_wq[i] = cfs_cpt_bind_workqueue("lst_t",
+							lnet_cpt_table(), 0,
+							i, nthrs);
+		if (IS_ERR(lst_test_wq[i])) {
+			rc = PTR_ERR(lst_test_wq[i]);
+			CERROR("Failed to create CPU partition affinity WI scheduler %d for LST: rc = %d\n",
+			       i, rc);
+			lst_test_wq[i] = NULL;
 			goto error;
 		}
 
diff --git a/net/lnet/selftest/rpc.c b/net/lnet/selftest/rpc.c
index c75addc74cad..f5730ada7d85 100644
--- a/net/lnet/selftest/rpc.c
+++ b/net/lnet/selftest/rpc.c
@@ -93,8 +93,7 @@ srpc_serv_portal(int svc_id)
 }
 
 /* forward ref's */
-void srpc_handle_rpc(struct swi_workitem *wi);
-
+static void srpc_handle_rpc(struct swi_workitem *wi);
 
 void srpc_get_counters(struct srpc_counters *cnt)
 {
@@ -295,8 +294,7 @@ srpc_service_init(struct srpc_service *svc)
 		scd->scd_ev.ev_data = scd;
 		scd->scd_ev.ev_type = SRPC_REQUEST_RCVD;
 
-		/*
-		 * NB: don't use lst_serial_wq for adding buffer,
+		/* NB: don't use lst_serial_wq for adding buffer,
 		 * see details in srpc_service_add_buffers()
 		 */
 		swi_init_workitem(&scd->scd_buf_wi,
@@ -601,6 +599,7 @@ srpc_add_buffer(struct swi_workitem *wi)
 		scd->scd_buf_posting--;
 	}
 
+	wi->swi_state = SWI_STATE_RUNNING;
 	spin_unlock(&scd->scd_lock);
 }
 
@@ -933,8 +932,6 @@ srpc_server_rpc_done(struct srpc_server_rpc *rpc, int status)
 	struct srpc_service *sv = scd->scd_svc;
 	struct srpc_buffer *buffer;
 
-	LASSERT(status || rpc->srpc_wi.swi_state == SWI_STATE_DONE);
-
 	rpc->srpc_status = status;
 
 	CDEBUG_LIMIT(!status ? D_NET : D_NETERROR,
@@ -969,6 +966,7 @@ srpc_server_rpc_done(struct srpc_server_rpc *rpc, int status)
 	 * Cancel pending schedules and prevent future schedule attempts:
 	 */
 	LASSERT(rpc->srpc_ev.ev_fired);
+	rpc->srpc_wi.swi_state = SWI_STATE_DONE;
 
 	if (!sv->sv_shuttingdown && !list_empty(&scd->scd_buf_blocked)) {
 		buffer = list_first_entry(&scd->scd_buf_blocked,
@@ -986,8 +984,7 @@ srpc_server_rpc_done(struct srpc_server_rpc *rpc, int status)
 }
 
 /* handles an incoming RPC */
-void
-srpc_handle_rpc(struct swi_workitem *wi)
+static void srpc_handle_rpc(struct swi_workitem *wi)
 {
 	struct srpc_server_rpc *rpc = container_of(wi, struct srpc_server_rpc,
 						   srpc_wi);
@@ -996,20 +993,22 @@ srpc_handle_rpc(struct swi_workitem *wi)
 	struct srpc_event *ev = &rpc->srpc_ev;
 	int rc = 0;
 
-	LASSERT(wi == &rpc->srpc_wi);
-
 	spin_lock(&scd->scd_lock);
+	if (wi->swi_state == SWI_STATE_DONE) {
+		spin_unlock(&scd->scd_lock);
+		return;
+	}
 
 	if (sv->sv_shuttingdown || rpc->srpc_aborted) {
+		wi->swi_state = SWI_STATE_DONE;
 		spin_unlock(&scd->scd_lock);
 
 		if (rpc->srpc_bulk)
 			LNetMDUnlink(rpc->srpc_bulk->bk_mdh);
 		LNetMDUnlink(rpc->srpc_replymdh);
 
-		if (ev->ev_fired) { /* no more event, OK to finish */
+		if (ev->ev_fired) /* no more event, OK to finish */
 			srpc_server_rpc_done(rpc, -ESHUTDOWN);
-		}
 		return;
 	}
 
@@ -1069,7 +1068,6 @@ srpc_handle_rpc(struct swi_workitem *wi)
 
 			if (sv->sv_bulk_ready)
 				rc = (*sv->sv_bulk_ready) (rpc, rc);
-
 			if (rc) {
 				srpc_server_rpc_done(rpc, rc);
 				return;
@@ -1164,8 +1162,6 @@ srpc_client_rpc_done(struct srpc_client_rpc *rpc, int status)
 {
 	struct swi_workitem *wi = &rpc->crpc_wi;
 
-	LASSERT(status || wi->swi_state == SWI_STATE_DONE);
-
 	spin_lock(&rpc->crpc_lock);
 
 	rpc->crpc_closed = 1;
@@ -1188,6 +1184,7 @@ srpc_client_rpc_done(struct srpc_client_rpc *rpc, int status)
 	 * Cancel pending schedules and prevent future schedule attempts:
 	 */
 	LASSERT(!srpc_event_pending(rpc));
+	wi->swi_state = SWI_STATE_DONE;
 
 	spin_unlock(&rpc->crpc_lock);
 
@@ -1214,6 +1211,10 @@ srpc_send_rpc(struct swi_workitem *wi)
 	do_bulk = rpc->crpc_bulk.bk_niov > 0;
 
 	spin_lock(&rpc->crpc_lock);
+	if (wi->swi_state == SWI_STATE_DONE) {
+		spin_unlock(&rpc->crpc_lock);
+		return;
+	}
 
 	if (rpc->crpc_aborted) {
 		spin_unlock(&rpc->crpc_lock);
diff --git a/net/lnet/selftest/selftest.h b/net/lnet/selftest/selftest.h
index 5d0b47fe7e49..ceefd850f996 100644
--- a/net/lnet/selftest/selftest.h
+++ b/net/lnet/selftest/selftest.h
@@ -126,14 +126,18 @@ enum lnet_selftest_group_nodelist_prop_attrs {
 
 #define LNET_SELFTEST_GROUP_NODELIST_PROP_MAX	(__LNET_SELFTEST_GROUP_NODELIST_PROP_MAX_PLUS_ONE - 1)
 
-#define SWI_STATE_NEWBORN		0
-#define SWI_STATE_REPLY_SUBMITTED	1
-#define SWI_STATE_REPLY_SENT		2
-#define SWI_STATE_REQUEST_SUBMITTED	3
-#define SWI_STATE_REQUEST_SENT		4
-#define SWI_STATE_REPLY_RECEIVED	5
-#define SWI_STATE_BULK_STARTED		6
-#define SWI_STATE_DONE			10
+enum lsr_swi_state {
+	SWI_STATE_DONE = 0,
+	SWI_STATE_NEWBORN,
+	SWI_STATE_REPLY_SUBMITTED,
+	SWI_STATE_REPLY_SENT,
+	SWI_STATE_REQUEST_SUBMITTED,
+	SWI_STATE_REQUEST_SENT,
+	SWI_STATE_REPLY_RECEIVED,
+	SWI_STATE_BULK_STARTED,
+	SWI_STATE_RUNNING,
+	SWI_STATE_PAUSE,
+};
 
 /* forward refs */
 struct srpc_service;
@@ -248,9 +252,9 @@ typedef void (*swi_action_t) (struct swi_workitem *);
 
 struct swi_workitem {
 	struct workqueue_struct *swi_wq;
-	struct work_struct  swi_work;
-	swi_action_t	    swi_action;
-	int		    swi_state;
+	struct work_struct	swi_work;
+	swi_action_t		swi_action;
+	enum lsr_swi_state	swi_state;
 };
 
 /* server-side state of a RPC */
@@ -562,7 +566,6 @@ swi_wi_action(struct work_struct *wi)
 	struct swi_workitem *swi;
 
 	swi = container_of(wi, struct swi_workitem, swi_work);
-
 	swi->swi_action(swi);
 }
 
-- 
2.39.3

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
