From: James Simmons <jsimmons@infradead.org>
Date: Sat, 12 Mar 2016 13:00:36 -0500
Subject: [lustre-devel] [PATCH 6/6] staging: lustre: cleanup comment style
	for lnet selftest
In-Reply-To: <1457805636-23859-1-git-send-email-jsimmons@infradead.org>
References: <1457805636-23859-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1457805636-23859-7-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

Apply a consistent style for comments in the lnet selftest
code. Realign some of the comments to make it easier to read.
This also fixes a few checkpatch issues as well.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lnet/selftest/brw_test.c  |    2 +-
 drivers/staging/lustre/lnet/selftest/conctl.c    |   50 +++++++++++-----------
 drivers/staging/lustre/lnet/selftest/conrpc.c    |   17 ++++----
 drivers/staging/lustre/lnet/selftest/console.c   |    5 +-
 drivers/staging/lustre/lnet/selftest/framework.c |   12 +++---
 drivers/staging/lustre/lnet/selftest/ping_test.c |    2 +-
 drivers/staging/lustre/lnet/selftest/rpc.c       |    8 ++--
 drivers/staging/lustre/lnet/selftest/timer.c     |    2 +-
 8 files changed, 50 insertions(+), 48 deletions(-)

diff --git a/drivers/staging/lustre/lnet/selftest/brw_test.c b/drivers/staging/lustre/lnet/selftest/brw_test.c
index 69812fc..b33c356 100644
--- a/drivers/staging/lustre/lnet/selftest/brw_test.c
+++ b/drivers/staging/lustre/lnet/selftest/brw_test.c
@@ -327,7 +327,7 @@ brw_client_done_rpc(sfw_test_unit_t *tsu, srpc_client_rpc_t *rpc)
 	if (rpc->crpc_status) {
 		CERROR("BRW RPC to %s failed with %d\n",
 		       libcfs_id2str(rpc->crpc_dest), rpc->crpc_status);
-		if (!tsi->tsi_stopping) /* rpc could have been aborted */
+		if (!tsi->tsi_stopping)	/* rpc could have been aborted */
 			atomic_inc(&sn->sn_brw_errors);
 		return;
 	}
diff --git a/drivers/staging/lustre/lnet/selftest/conctl.c b/drivers/staging/lustre/lnet/selftest/conctl.c
index 5c7cb72..6e2a81d 100644
--- a/drivers/staging/lustre/lnet/selftest/conctl.c
+++ b/drivers/staging/lustre/lnet/selftest/conctl.c
@@ -51,9 +51,9 @@ lst_session_new_ioctl(lstio_session_new_args_t *args)
 	char *name;
 	int rc;
 
-	if (!args->lstio_ses_idp || /* address for output sid */
-	    !args->lstio_ses_key ||    /* no key is specified */
-	    !args->lstio_ses_namep || /* session name */
+	if (!args->lstio_ses_idp ||	/* address for output sid */
+	    !args->lstio_ses_key ||	/* no key is specified */
+	    !args->lstio_ses_namep ||	/* session name */
 	    args->lstio_ses_nmlen <= 0 ||
 	    args->lstio_ses_nmlen > LST_NAME_SIZE)
 		return -EINVAL;
@@ -95,11 +95,11 @@ lst_session_info_ioctl(lstio_session_info_args_t *args)
 {
 	/* no checking of key */
 
-	if (!args->lstio_ses_idp || /* address for output sid */
-	    !args->lstio_ses_keyp || /* address for output key */
-	    !args->lstio_ses_featp || /* address for output features */
-	    !args->lstio_ses_ndinfo || /* address for output ndinfo */
-	    !args->lstio_ses_namep || /* address for output name */
+	if (!args->lstio_ses_idp ||	/* address for output sid */
+	    !args->lstio_ses_keyp ||	/* address for output key */
+	    !args->lstio_ses_featp ||	/* address for output features */
+	    !args->lstio_ses_ndinfo ||	/* address for output ndinfo */
+	    !args->lstio_ses_namep ||	/* address for output name */
 	    args->lstio_ses_nmlen <= 0 ||
 	    args->lstio_ses_nmlen > LST_NAME_SIZE)
 		return -EINVAL;
@@ -125,7 +125,7 @@ lst_debug_ioctl(lstio_debug_args_t *args)
 	if (!args->lstio_dbg_resultp)
 		return -EINVAL;
 
-	if (args->lstio_dbg_namep && /* name of batch/group */
+	if (args->lstio_dbg_namep &&	/* name of batch/group */
 	    (args->lstio_dbg_nmlen <= 0 ||
 	     args->lstio_dbg_nmlen > LST_NAME_SIZE))
 		return -EINVAL;
@@ -326,7 +326,7 @@ lst_nodes_add_ioctl(lstio_group_nodes_args_t *args)
 	if (args->lstio_grp_key != console_session.ses_key)
 		return -EACCES;
 
-	if (!args->lstio_grp_idsp || /* array of ids */
+	if (!args->lstio_grp_idsp ||	/* array of ids */
 	    args->lstio_grp_count <= 0 ||
 	    !args->lstio_grp_resultp ||
 	    !args->lstio_grp_featp ||
@@ -394,13 +394,13 @@ lst_group_info_ioctl(lstio_group_info_args_t *args)
 	    args->lstio_grp_nmlen > LST_NAME_SIZE)
 		return -EINVAL;
 
-	if (!args->lstio_grp_entp &&  /* output: group entry */
-	    !args->lstio_grp_dentsp)  /* output: node entry */
+	if (!args->lstio_grp_entp &&	/* output: group entry */
+	    !args->lstio_grp_dentsp)	/* output: node entry */
 		return -EINVAL;
 
-	if (args->lstio_grp_dentsp) { /* have node entry */
-		if (!args->lstio_grp_idxp || /* node index */
-		    !args->lstio_grp_ndentp) /* # of node entry */
+	if (args->lstio_grp_dentsp) {		/* have node entry */
+		if (!args->lstio_grp_idxp ||	/* node index */
+		    !args->lstio_grp_ndentp)	/* # of node entry */
 			return -EINVAL;
 
 		if (copy_from_user(&ndent, args->lstio_grp_ndentp,
@@ -612,18 +612,18 @@ lst_batch_info_ioctl(lstio_batch_info_args_t *args)
 	if (args->lstio_bat_key != console_session.ses_key)
 		return -EACCES;
 
-	if (!args->lstio_bat_namep || /* batch name */
+	if (!args->lstio_bat_namep ||	/* batch name */
 	    args->lstio_bat_nmlen <= 0 ||
 	    args->lstio_bat_nmlen > LST_NAME_SIZE)
 		return -EINVAL;
 
-	if (!args->lstio_bat_entp && /* output: batch entry */
-	    !args->lstio_bat_dentsp) /* output: node entry */
+	if (!args->lstio_bat_entp &&	/* output: batch entry */
+	    !args->lstio_bat_dentsp)	/* output: node entry */
 		return -EINVAL;
 
-	if (args->lstio_bat_dentsp) { /* have node entry */
-		if (!args->lstio_bat_idxp || /* node index */
-		    !args->lstio_bat_ndentp) /* # of node entry */
+	if (args->lstio_bat_dentsp) {		/* have node entry */
+		if (!args->lstio_bat_idxp ||	/* node index */
+		    !args->lstio_bat_ndentp)	/* # of node entry */
 			return -EINVAL;
 
 		if (copy_from_user(&index, args->lstio_bat_idxp,
@@ -722,18 +722,18 @@ static int lst_test_add_ioctl(lstio_test_args_t *args)
 
 	if (!args->lstio_tes_resultp ||
 	    !args->lstio_tes_retp ||
-	    !args->lstio_tes_bat_name || /* no specified batch */
+	    !args->lstio_tes_bat_name ||	/* no specified batch */
 	    args->lstio_tes_bat_nmlen <= 0 ||
 	    args->lstio_tes_bat_nmlen > LST_NAME_SIZE ||
-	    !args->lstio_tes_sgrp_name || /* no source group */
+	    !args->lstio_tes_sgrp_name ||	/* no source group */
 	    args->lstio_tes_sgrp_nmlen <= 0 ||
 	    args->lstio_tes_sgrp_nmlen > LST_NAME_SIZE ||
-	    !args->lstio_tes_dgrp_name || /* no target group */
+	    !args->lstio_tes_dgrp_name ||	/* no target group */
 	    args->lstio_tes_dgrp_nmlen <= 0 ||
 	    args->lstio_tes_dgrp_nmlen > LST_NAME_SIZE)
 		return -EINVAL;
 
-	if (!args->lstio_tes_loop || /* negative is infinite */
+	if (!args->lstio_tes_loop ||		/* negative is infinite */
 	    args->lstio_tes_concur <= 0 ||
 	    args->lstio_tes_dist <= 0 ||
 	    args->lstio_tes_span <= 0)
diff --git a/drivers/staging/lustre/lnet/selftest/conrpc.c b/drivers/staging/lustre/lnet/selftest/conrpc.c
index d11869a..3908c10 100644
--- a/drivers/staging/lustre/lnet/selftest/conrpc.c
+++ b/drivers/staging/lustre/lnet/selftest/conrpc.c
@@ -296,8 +296,8 @@ lstcon_rpc_trans_abort(lstcon_rpc_trans_t *trans, int error)
 
 		spin_lock(&rpc->crpc_lock);
 
-		if (!crpc->crp_posted || /* not posted */
-		    crpc->crp_stamp) { /* rpc done or aborted already */
+		if (!crpc->crp_posted ||	/* not posted */
+		    crpc->crp_stamp) {		/* rpc done or aborted already */
 			if (!crpc->crp_stamp) {
 				crpc->crp_stamp = cfs_time_current();
 				crpc->crp_status = -EINTR;
@@ -562,10 +562,10 @@ lstcon_rpc_trans_destroy(lstcon_rpc_trans_t *trans)
 		}
 
 		/*
-		 * rpcs can be still not callbacked (even LNetMDUnlink is called)
-		 * because huge timeout for inaccessible network, don't make
-		 * user wait for them, just abandon them, they will be recycled
-		 * in callback
+		 * rpcs can be still not callbacked (even LNetMDUnlink is
+		 * called) because huge timeout for inaccessible network,
+		 * don't make user wait for them, just abandon them, they
+		 * will be recycled in callback
 		 */
 		LASSERT(crpc->crp_status);
 
@@ -938,7 +938,7 @@ lstcon_sesnew_stat_reply(lstcon_rpc_trans_t *trans,
 
 	if (!trans->tas_feats_updated) {
 		spin_lock(&console_session.ses_rpc_lock);
-		if (!trans->tas_feats_updated) { /* recheck with lock */
+		if (!trans->tas_feats_updated) {	/* recheck with lock */
 			trans->tas_feats_updated = 1;
 			trans->tas_features = reply->msg_ses_feats;
 		}
@@ -1178,7 +1178,8 @@ lstcon_rpc_pinger(void *arg)
 	int count = 0;
 	int rc;
 
-	/* RPC pinger is a special case of transaction,
+	/*
+	 * RPC pinger is a special case of transaction,
 	 * it's called by timer at 8 seconds interval.
 	 */
 	mutex_lock(&console_session.ses_mutex);
diff --git a/drivers/staging/lustre/lnet/selftest/console.c b/drivers/staging/lustre/lnet/selftest/console.c
index 6ec8952..dcfc83d 100644
--- a/drivers/staging/lustre/lnet/selftest/console.c
+++ b/drivers/staging/lustre/lnet/selftest/console.c
@@ -277,7 +277,7 @@ lstcon_group_find(const char *name, lstcon_group_t **grpp)
 		if (strncmp(grp->grp_name, name, LST_NAME_SIZE))
 			continue;
 
-		lstcon_group_addref(grp);  /* +1 ref for caller */
+		lstcon_group_addref(grp); /* +1 ref for caller */
 		*grpp = grp;
 		return 0;
 	}
@@ -1446,7 +1446,8 @@ lstcon_test_batch_query(char *name, int testidx, int client,
 
 	lstcon_rpc_trans_postwait(trans, timeout);
 
-	if (!testidx && /* query a batch, not a test */
+	/* query a batch, not a test */
+	if (!testidx &&
 	    !lstcon_rpc_stat_failure(lstcon_trans_stat(), 0) &&
 	    !lstcon_tsbqry_stat_run(lstcon_trans_stat(), 0)) {
 		/* all RPCs finished, and no active test */
diff --git a/drivers/staging/lustre/lnet/selftest/framework.c b/drivers/staging/lustre/lnet/selftest/framework.c
index 0f32f0b..aa646a7 100644
--- a/drivers/staging/lustre/lnet/selftest/framework.c
+++ b/drivers/staging/lustre/lnet/selftest/framework.c
@@ -226,7 +226,7 @@ __must_hold(&sfw_data.fw_lock)
 	}
 
 	if (nactive)
-		return;   /* wait for active batches to stop */
+		return;	/* wait for active batches to stop */
 
 	list_del_init(&sn->sn_list);
 	spin_unlock(&sfw_data.fw_lock);
@@ -693,7 +693,7 @@ sfw_unpack_addtest_req(srpc_msg_t *msg)
 	LASSERT(req->tsr_is_client);
 
 	if (msg->msg_magic == SRPC_MSG_MAGIC)
-		return; /* no flipping needed */
+		return;	/* no flipping needed */
 
 	LASSERT(msg->msg_magic == __swab32(SRPC_MSG_MAGIC));
 
@@ -789,7 +789,7 @@ sfw_add_test_instance(sfw_batch_t *tsb, struct srpc_server_rpc *rpc)
 		int j;
 
 		dests = page_address(bk->bk_iovs[i / SFW_ID_PER_PAGE].kiov_page);
-		LASSERT(dests);  /* my pages are within KVM always */
+		LASSERT(dests);		/* my pages are within KVM always */
 		id = dests[i % SFW_ID_PER_PAGE];
 		if (msg->msg_magic != SRPC_MSG_MAGIC)
 			sfw_unpack_id(id);
@@ -844,8 +844,8 @@ sfw_test_unit_done(sfw_test_unit_t *tsu)
 
 	spin_lock(&sfw_data.fw_lock);
 
-	if (!atomic_dec_and_test(&tsb->bat_nactive) ||/* tsb still active */
-	    sn == sfw_data.fw_session) {		  /* sn also active */
+	if (!atomic_dec_and_test(&tsb->bat_nactive) ||	/* tsb still active */
+	    sn == sfw_data.fw_session) {		/* sn also active */
 		spin_unlock(&sfw_data.fw_lock);
 		return;
 	}
@@ -1273,7 +1273,7 @@ sfw_handle_server_rpc(struct srpc_server_rpc *rpc)
 		}
 
 	} else if (request->msg_ses_feats & ~LST_FEATS_MASK) {
-		/**
+		/*
 		 * NB: at this point, old version will ignore features and
 		 * create new session anyway, so console should be able
 		 * to handle this
diff --git a/drivers/staging/lustre/lnet/selftest/ping_test.c b/drivers/staging/lustre/lnet/selftest/ping_test.c
index 438fca2..c7c50be 100644
--- a/drivers/staging/lustre/lnet/selftest/ping_test.c
+++ b/drivers/staging/lustre/lnet/selftest/ping_test.c
@@ -129,7 +129,7 @@ ping_client_done_rpc(sfw_test_unit_t *tsu, srpc_client_rpc_t *rpc)
 	LASSERT(sn);
 
 	if (rpc->crpc_status) {
-		if (!tsi->tsi_stopping) /* rpc could have been aborted */
+		if (!tsi->tsi_stopping)	/* rpc could have been aborted */
 			atomic_inc(&sn->sn_ping_errors);
 		CERROR("Unable to ping %s (%d): %d\n",
 		       libcfs_id2str(rpc->crpc_dest),
diff --git a/drivers/staging/lustre/lnet/selftest/rpc.c b/drivers/staging/lustre/lnet/selftest/rpc.c
index 69be7d6..ab8ba37 100644
--- a/drivers/staging/lustre/lnet/selftest/rpc.c
+++ b/drivers/staging/lustre/lnet/selftest/rpc.c
@@ -1332,8 +1332,8 @@ srpc_abort_rpc(srpc_client_rpc_t *rpc, int why)
 {
 	LASSERT(why);
 
-	if (rpc->crpc_aborted || /* already aborted */
-	    rpc->crpc_closed)	 /* callback imminent */
+	if (rpc->crpc_aborted ||	/* already aborted */
+	    rpc->crpc_closed)		/* callback imminent */
 		return;
 
 	CDEBUG(D_NET, "Aborting RPC: service %d, peer %s, state %s, why %d\n",
@@ -1401,7 +1401,7 @@ srpc_send_reply(struct srpc_server_rpc *rpc)
 				   rpc->srpc_peer, rpc->srpc_self,
 				   &rpc->srpc_replymdh, ev);
 	if (rc)
-		ev->ev_fired = 1;  /* no more event expected */
+		ev->ev_fired = 1; /* no more event expected */
 	return rc;
 }
 
@@ -1509,7 +1509,7 @@ srpc_lnet_ev_handler(lnet_event_t *ev)
 			scd->scd_buf_err = 0;
 		}
 
-		if (!scd->scd_buf_err && /* adding buffer is enabled */
+		if (!scd->scd_buf_err &&	/* adding buffer is enabled */
 		    !scd->scd_buf_adjust &&
 		    scd->scd_buf_nposted < scd->scd_buf_low) {
 			scd->scd_buf_adjust = max(scd->scd_buf_total / 2,
diff --git a/drivers/staging/lustre/lnet/selftest/timer.c b/drivers/staging/lustre/lnet/selftest/timer.c
index ef8a8a7..b6c4aae 100644
--- a/drivers/staging/lustre/lnet/selftest/timer.c
+++ b/drivers/staging/lustre/lnet/selftest/timer.c
@@ -49,7 +49,7 @@
  * sorted by increasing expiry time. The number of slots is 2**7 (128),
  * to cover a time period of 1024 seconds into the future before wrapping.
  */
-#define STTIMER_MINPOLL        3   /* log2 min poll interval (8 s) */
+#define STTIMER_MINPOLL        3	/* log2 min poll interval (8 s) */
 #define STTIMER_SLOTTIME       (1 << STTIMER_MINPOLL)
 #define STTIMER_SLOTTIMEMASK   (~(STTIMER_SLOTTIME - 1))
 #define STTIMER_NSLOTS	       (1 << 7)
-- 
1.7.1
