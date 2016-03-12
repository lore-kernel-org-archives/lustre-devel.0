From: Dilger, Andreas <andreas.dilger@intel.com>
Date: Sat, 12 Mar 2016 01:39:01 +0000
Subject: [lustre-devel] [PATCH 07/10] staging: lustre: cleanup comment
 style for lnet selftest
In-Reply-To: <1457746191-27981-8-git-send-email-jsimmons@infradead.org>
References: <1457746191-27981-1-git-send-email-jsimmons@infradead.org>
	<1457746191-27981-8-git-send-email-jsimmons@infradead.org>
Message-ID: <D308C0DE.13458A%andreas.dilger@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>, "Drokin, Oleg" <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

On 2016/03/11, 18:29, "lustre-devel on behalf of James Simmons"
<lustre-devel-bounces at lists.lustre.org on behalf of
jsimmons@infradead.org> wrote:

>Apply a consistent style for comments in the lnet selftest
>code.
>
>Signed-off-by: James Simmons <jsimmons@infradead.org>
>---
> drivers/staging/lustre/lnet/selftest/brw_test.c  |    8 ++--
> drivers/staging/lustre/lnet/selftest/conctl.c    |   50
>+++++++++++-----------
> drivers/staging/lustre/lnet/selftest/conrpc.c    |   23 +++++-----
> drivers/staging/lustre/lnet/selftest/console.c   |   11 +++--
> drivers/staging/lustre/lnet/selftest/framework.c |   20 ++++----
> drivers/staging/lustre/lnet/selftest/ping_test.c |    2 +-
> drivers/staging/lustre/lnet/selftest/rpc.c       |   46
>++++++++++----------
> drivers/staging/lustre/lnet/selftest/rpc.h       |    2 +-
> drivers/staging/lustre/lnet/selftest/selftest.h  |    3 +-
> drivers/staging/lustre/lnet/selftest/timer.c     |    6 +-
> 10 files changed, 87 insertions(+), 84 deletions(-)
>
>diff --git a/drivers/staging/lustre/lnet/selftest/brw_test.c
>b/drivers/staging/lustre/lnet/selftest/brw_test.c
>index eebc924..6ac4d02 100644
>--- a/drivers/staging/lustre/lnet/selftest/brw_test.c
>+++ b/drivers/staging/lustre/lnet/selftest/brw_test.c
>@@ -86,7 +86,7 @@ brw_client_init(sfw_test_instance_t *tsi)
> 		opc = breq->blk_opc;
> 		flags = breq->blk_flags;
> 		npg = breq->blk_npg;
>-		/*
>+		/**
> 		 * NB: this is not going to work for variable page size,
> 		 * but we have to keep it for compatibility
> 		 */

The "/**" comment opener is only for header comment blocks that
have markup in them.  I don't think that is kernel style for
normal multi-line comments in the code.

Cheers, Andreas

>@@ -95,7 +95,7 @@ brw_client_init(sfw_test_instance_t *tsi)
> 	} else {
> 		test_bulk_req_v1_t *breq = &tsi->tsi_u.bulk_v1;
> 
>-		/*
>+		/**
> 		 * I should never get this step if it's unknown feature
> 		 * because make_session will reject unknown feature
> 		 */
>@@ -283,7 +283,7 @@ brw_client_prep_rpc(sfw_test_unit_t *tsu,
> 	} else {
> 		test_bulk_req_v1_t *breq = &tsi->tsi_u.bulk_v1;
> 
>-		/*
>+		/**
> 		 * I should never get this step if it's unknown feature
> 		 * because make_session will reject unknown feature
> 		 */
>@@ -329,7 +329,7 @@ brw_client_done_rpc(sfw_test_unit_t *tsu,
>srpc_client_rpc_t *rpc)
> 	if (rpc->crpc_status) {
> 		CERROR("BRW RPC to %s failed with %d\n",
> 		       libcfs_id2str(rpc->crpc_dest), rpc->crpc_status);
>-		if (!tsi->tsi_stopping) /* rpc could have been aborted */
>+		if (!tsi->tsi_stopping)	/* rpc could have been aborted */
> 			atomic_inc(&sn->sn_brw_errors);
> 		return;
> 	}
>diff --git a/drivers/staging/lustre/lnet/selftest/conctl.c
>b/drivers/staging/lustre/lnet/selftest/conctl.c
>index 872df72..d045ac5 100644
>--- a/drivers/staging/lustre/lnet/selftest/conctl.c
>+++ b/drivers/staging/lustre/lnet/selftest/conctl.c
>@@ -51,9 +51,9 @@ lst_session_new_ioctl(lstio_session_new_args_t *args)
> 	char *name;
> 	int rc;
> 
>-	if (!args->lstio_ses_idp || /* address for output sid */
>-	    !args->lstio_ses_key ||    /* no key is specified */
>-	    !args->lstio_ses_namep || /* session name */
>+	if (!args->lstio_ses_idp ||	/* address for output sid */
>+	    !args->lstio_ses_key ||	/* no key is specified */
>+	    !args->lstio_ses_namep ||	/* session name */
> 	    args->lstio_ses_nmlen <= 0 ||
> 	    args->lstio_ses_nmlen > LST_NAME_SIZE)
> 		return -EINVAL;
>@@ -95,11 +95,11 @@ lst_session_info_ioctl(lstio_session_info_args_t
>*args)
> {
> 	/* no checking of key */
> 
>-	if (!args->lstio_ses_idp || /* address for output sid */
>-	    !args->lstio_ses_keyp || /* address for output key */
>-	    !args->lstio_ses_featp || /* address for output features */
>-	    !args->lstio_ses_ndinfo || /* address for output ndinfo */
>-	    !args->lstio_ses_namep || /* address for output name */
>+	if (!args->lstio_ses_idp ||	/* address for output sid */
>+	    !args->lstio_ses_keyp ||	/* address for output key */
>+	    !args->lstio_ses_featp ||	/* address for output features */
>+	    !args->lstio_ses_ndinfo ||	/* address for output ndinfo */
>+	    !args->lstio_ses_namep ||	/* address for output name */
> 	    args->lstio_ses_nmlen <= 0 ||
> 	    args->lstio_ses_nmlen > LST_NAME_SIZE)
> 		return -EINVAL;
>@@ -125,7 +125,7 @@ lst_debug_ioctl(lstio_debug_args_t *args)
> 	if (!args->lstio_dbg_resultp)
> 		return -EINVAL;
> 
>-	if (args->lstio_dbg_namep && /* name of batch/group */
>+	if (args->lstio_dbg_namep &&	/* name of batch/group */
> 	    (args->lstio_dbg_nmlen <= 0 ||
> 	     args->lstio_dbg_nmlen > LST_NAME_SIZE))
> 		return -EINVAL;
>@@ -327,7 +327,7 @@ lst_nodes_add_ioctl(lstio_group_nodes_args_t *args)
> 	if (args->lstio_grp_key != console_session.ses_key)
> 		return -EACCES;
> 
>-	if (!args->lstio_grp_idsp || /* array of ids */
>+	if (!args->lstio_grp_idsp ||	/* array of ids */
> 	    args->lstio_grp_count <= 0 ||
> 	    !args->lstio_grp_resultp ||
> 	    !args->lstio_grp_featp ||
>@@ -395,13 +395,13 @@ lst_group_info_ioctl(lstio_group_info_args_t *args)
> 	    args->lstio_grp_nmlen > LST_NAME_SIZE)
> 		return -EINVAL;
> 
>-	if (!args->lstio_grp_entp &&  /* output: group entry */
>-	    !args->lstio_grp_dentsp)  /* output: node entry */
>+	if (!args->lstio_grp_entp &&	/* output: group entry */
>+	    !args->lstio_grp_dentsp)	/* output: node entry */
> 		return -EINVAL;
> 
>-	if (args->lstio_grp_dentsp) { /* have node entry */
>-		if (!args->lstio_grp_idxp || /* node index */
>-		    !args->lstio_grp_ndentp) /* # of node entry */
>+	if (args->lstio_grp_dentsp) {		/* have node entry */
>+		if (!args->lstio_grp_idxp ||	/* node index */
>+		    !args->lstio_grp_ndentp)	/* # of node entry */
> 			return -EINVAL;
> 
> 		if (copy_from_user(&ndent, args->lstio_grp_ndentp,
>@@ -613,18 +613,18 @@ lst_batch_info_ioctl(lstio_batch_info_args_t *args)
> 	if (args->lstio_bat_key != console_session.ses_key)
> 		return -EACCES;
> 
>-	if (!args->lstio_bat_namep || /* batch name */
>+	if (!args->lstio_bat_namep ||	/* batch name */
> 	    args->lstio_bat_nmlen <= 0 ||
> 	    args->lstio_bat_nmlen > LST_NAME_SIZE)
> 		return -EINVAL;
> 
>-	if (!args->lstio_bat_entp && /* output: batch entry */
>-	    !args->lstio_bat_dentsp) /* output: node entry */
>+	if (!args->lstio_bat_entp &&	/* output: batch entry */
>+	    !args->lstio_bat_dentsp)	/* output: node entry */
> 		return -EINVAL;
> 
>-	if (args->lstio_bat_dentsp) { /* have node entry */
>-		if (!args->lstio_bat_idxp || /* node index */
>-		    !args->lstio_bat_ndentp) /* # of node entry */
>+	if (args->lstio_bat_dentsp) {		/* have node entry */
>+		if (!args->lstio_bat_idxp ||	/* node index */
>+		    !args->lstio_bat_ndentp)	/* # of node entry */
> 			return -EINVAL;
> 
> 		if (copy_from_user(&index, args->lstio_bat_idxp,
>@@ -723,18 +723,18 @@ static int lst_test_add_ioctl(lstio_test_args_t
>*args)
> 
> 	if (!args->lstio_tes_resultp ||
> 	    !args->lstio_tes_retp ||
>-	    !args->lstio_tes_bat_name || /* no specified batch */
>+	    !args->lstio_tes_bat_name ||	/* no specified batch */
> 	    args->lstio_tes_bat_nmlen <= 0 ||
> 	    args->lstio_tes_bat_nmlen > LST_NAME_SIZE ||
>-	    !args->lstio_tes_sgrp_name || /* no source group */
>+	    !args->lstio_tes_sgrp_name ||	/* no source group */
> 	    args->lstio_tes_sgrp_nmlen <= 0 ||
> 	    args->lstio_tes_sgrp_nmlen > LST_NAME_SIZE ||
>-	    !args->lstio_tes_dgrp_name || /* no target group */
>+	    !args->lstio_tes_dgrp_name ||	/* no target group */
> 	    args->lstio_tes_dgrp_nmlen <= 0 ||
> 	    args->lstio_tes_dgrp_nmlen > LST_NAME_SIZE)
> 		return -EINVAL;
> 
>-	if (!args->lstio_tes_loop || /* negative is infinite */
>+	if (!args->lstio_tes_loop ||		/* negative is infinite */
> 	    args->lstio_tes_concur <= 0 ||
> 	    args->lstio_tes_dist <= 0 ||
> 	    args->lstio_tes_span <= 0)
>diff --git a/drivers/staging/lustre/lnet/selftest/conrpc.c
>b/drivers/staging/lustre/lnet/selftest/conrpc.c
>index cdb660e..9401e1a 100644
>--- a/drivers/staging/lustre/lnet/selftest/conrpc.c
>+++ b/drivers/staging/lustre/lnet/selftest/conrpc.c
>@@ -60,7 +60,7 @@ lstcon_rpc_done(srpc_client_rpc_t *rpc)
> 	spin_lock(&rpc->crpc_lock);
> 
> 	if (!crpc->crp_trans) {
>-		/*
>+		/**
> 		 * Orphan RPC is not in any transaction,
> 		 * I'm just a poor body and nobody loves me
> 		 */
>@@ -242,7 +242,7 @@ lstcon_rpc_trans_prep(struct list_head *translist,
> 
> 	if (translist) {
> 		list_for_each_entry(trans, translist, tas_link) {
>-			/*
>+			/**
> 			 * Can't enqueue two private transaction on
> 			 * the same object
> 			 */
>@@ -296,8 +296,8 @@ lstcon_rpc_trans_abort(lstcon_rpc_trans_t *trans, int
>error)
> 
> 		spin_lock(&rpc->crpc_lock);
> 
>-		if (!crpc->crp_posted || /* not posted */
>-		    crpc->crp_stamp) { /* rpc done or aborted already */
>+		if (!crpc->crp_posted ||	/* not posted */
>+		    crpc->crp_stamp) {		/* rpc done or aborted already */
> 			if (!crpc->crp_stamp) {
> 				crpc->crp_stamp = cfs_time_current();
> 				crpc->crp_status = -EINTR;
>@@ -563,11 +563,11 @@ lstcon_rpc_trans_destroy(lstcon_rpc_trans_t *trans)
> 			continue;
> 		}
> 
>-		/*
>-		 * rpcs can be still not callbacked (even LNetMDUnlink is called)
>-		 * because huge timeout for inaccessible network, don't make
>-		 * user wait for them, just abandon them, they will be recycled
>-		 * in callback
>+		/**
>+		 * rpcs can be still not callbacked (even LNetMDUnlink is
>+		 * called) because huge timeout for inaccessible network,
>+		 * don't make user wait for them, just abandon them, they
>+		 * will be recycled in callback
> 		 */
> 		LASSERT(crpc->crp_status);
> 
>@@ -941,7 +941,7 @@ lstcon_sesnew_stat_reply(lstcon_rpc_trans_t *trans,
> 
> 	if (!trans->tas_feats_updated) {
> 		spin_lock(&console_session.ses_rpc_lock);
>-		if (!trans->tas_feats_updated) { /* recheck with lock */
>+		if (!trans->tas_feats_updated) {	/* recheck with lock */
> 			trans->tas_feats_updated = 1;
> 			trans->tas_features = reply->msg_ses_feats;
> 		}
>@@ -1181,7 +1181,8 @@ lstcon_rpc_pinger(void *arg)
> 	int count = 0;
> 	int rc;
> 
>-	/* RPC pinger is a special case of transaction,
>+	/**
>+	 * RPC pinger is a special case of transaction,
> 	 * it's called by timer at 8 seconds interval.
> 	 */
> 	mutex_lock(&console_session.ses_mutex);
>diff --git a/drivers/staging/lustre/lnet/selftest/console.c
>b/drivers/staging/lustre/lnet/selftest/console.c
>index 6017f21..25917ac 100644
>--- a/drivers/staging/lustre/lnet/selftest/console.c
>+++ b/drivers/staging/lustre/lnet/selftest/console.c
>@@ -104,7 +104,7 @@ lstcon_node_find(lnet_process_id_t id, lstcon_node_t
>**ndpp, int create)
> 	ndl->ndl_node->nd_timeout = 0;
> 	memset(&ndl->ndl_node->nd_ping, 0, sizeof(lstcon_rpc_t));
> 
>-	/*
>+	/**
> 	 * queued in global hash & list, no refcount is taken by
> 	 * global hash & list, if caller release his refcount,
> 	 * node will be released
>@@ -276,7 +276,7 @@ lstcon_group_find(const char *name, lstcon_group_t
>**grpp)
> 		if (strncmp(grp->grp_name, name, LST_NAME_SIZE))
> 			continue;
> 
>-		lstcon_group_addref(grp);  /* +1 ref for caller */
>+		lstcon_group_addref(grp); /* +1 ref for caller */
> 		*grpp = grp;
> 		return 0;
> 	}
>@@ -608,7 +608,7 @@ lstcon_group_del(char *name)
> 	lstcon_rpc_trans_destroy(trans);
> 
> 	lstcon_group_decref(grp);
>-	/*
>+	/**
> 	 * -ref for session, it's destroyed,
> 	 * status can't be rolled back, destroy group anyway
> 	 */
>@@ -1289,7 +1289,7 @@ lstcon_test_add(char *batch_name, int type, int
>loop,
> 	lstcon_group_t *dst_grp = NULL;
> 	lstcon_batch_t *batch = NULL;
> 
>-	/*
>+	/**
> 	 * verify that a batch of the given name exists, and the groups
> 	 * that will be part of the batch exist and have at least one
> 	 * active node
>@@ -1447,7 +1447,8 @@ lstcon_test_batch_query(char *name, int testidx,
>int client,
> 
> 	lstcon_rpc_trans_postwait(trans, timeout);
> 
>-	if (!testidx && /* query a batch, not a test */
>+	/* query a batch, not a test */
>+	if (!testidx &&
> 	    !lstcon_rpc_stat_failure(lstcon_trans_stat(), 0) &&
> 	    !lstcon_tsbqry_stat_run(lstcon_trans_stat(), 0)) {
> 		/* all RPCs finished, and no active test */
>diff --git a/drivers/staging/lustre/lnet/selftest/framework.c
>b/drivers/staging/lustre/lnet/selftest/framework.c
>index 2ff47d2..ed2f7e9 100644
>--- a/drivers/staging/lustre/lnet/selftest/framework.c
>+++ b/drivers/staging/lustre/lnet/selftest/framework.c
>@@ -226,7 +226,7 @@ __must_hold(&sfw_data.fw_lock)
> 	}
> 
> 	if (nactive)
>-		return;   /* wait for active batches to stop */
>+		return;	/* wait for active batches to stop */
> 
> 	list_del_init(&sn->sn_list);
> 	spin_unlock(&sfw_data.fw_lock);
>@@ -382,7 +382,7 @@ sfw_get_stats(srpc_stat_reqst_t *request,
>srpc_stat_reply_t *reply)
> 	lnet_counters_get(&reply->str_lnet);
> 	srpc_get_counters(&reply->str_rpc);
> 
>-	/*
>+	/**
> 	 * send over the msecs since the session was started
> 	 * with 32 bits to send, this is ~49 days
> 	 */
>@@ -435,7 +435,7 @@ sfw_make_session(srpc_mksn_reqst_t *request,
>srpc_mksn_reply_t *reply)
> 		}
> 	}
> 
>-	/*
>+	/**
> 	 * reject the request if it requires unknown features
> 	 * NB: old version will always accept all features because it's not
> 	 * aware of srpc_msg_t::msg_ses_feats, it's a defect but it's also
>@@ -576,7 +576,7 @@ sfw_load_test(struct sfw_test_instance *tsi)
> 	if (rc) {
> 		CWARN("Failed to reserve enough buffers: service %s, %d needed: %d\n",
> 		      svc->sv_name, nbuf, rc);
>-		/*
>+		/**
> 		 * NB: this error handler is not strictly correct, because
> 		 * it may release more buffers than already allocated,
> 		 * but it doesn't matter because request portal should
>@@ -604,7 +604,7 @@ sfw_unload_test(struct sfw_test_instance *tsi)
> 	if (tsi->tsi_is_client)
> 		return;
> 
>-	/*
>+	/**
> 	 * shrink buffers, because request portal is lazy portal
> 	 * which can grow buffers at runtime so we may leave
> 	 * some buffers behind, but never mind...
>@@ -693,7 +693,7 @@ sfw_unpack_addtest_req(srpc_msg_t *msg)
> 	LASSERT(req->tsr_is_client);
> 
> 	if (msg->msg_magic == SRPC_MSG_MAGIC)
>-		return; /* no flipping needed */
>+		return;	/* no flipping needed */
> 
> 	LASSERT(msg->msg_magic == __swab32(SRPC_MSG_MAGIC));
> 
>@@ -789,7 +789,7 @@ sfw_add_test_instance(sfw_batch_t *tsb, struct
>srpc_server_rpc *rpc)
> 		int j;
> 
> 		dests = page_address(bk->bk_iovs[i / SFW_ID_PER_PAGE].kiov_page);
>-		LASSERT(dests);  /* my pages are within KVM always */
>+		LASSERT(dests);		/* my pages are within KVM always */
> 		id = dests[i % SFW_ID_PER_PAGE];
> 		if (msg->msg_magic != SRPC_MSG_MAGIC)
> 			sfw_unpack_id(id);
>@@ -844,8 +844,8 @@ sfw_test_unit_done(sfw_test_unit_t *tsu)
> 
> 	spin_lock(&sfw_data.fw_lock);
> 
>-	if (!atomic_dec_and_test(&tsb->bat_nactive) ||/* tsb still active */
>-	    sn == sfw_data.fw_session) {		  /* sn also active */
>+	if (!atomic_dec_and_test(&tsb->bat_nactive) ||	/* tsb still active */
>+	    sn == sfw_data.fw_session) {		/* sn also active */
> 		spin_unlock(&sfw_data.fw_lock);
> 		return;
> 	}
>@@ -978,7 +978,7 @@ sfw_run_test(swi_workitem_t *wi)
> 	return 0;
> 
> test_done:
>-	/*
>+	/**
> 	 * No one can schedule me now since:
> 	 * - previous RPC, if any, has done and
> 	 * - no new RPC is initiated.
>diff --git a/drivers/staging/lustre/lnet/selftest/ping_test.c
>b/drivers/staging/lustre/lnet/selftest/ping_test.c
>index 81a4504..e05acce 100644
>--- a/drivers/staging/lustre/lnet/selftest/ping_test.c
>+++ b/drivers/staging/lustre/lnet/selftest/ping_test.c
>@@ -129,7 +129,7 @@ ping_client_done_rpc(sfw_test_unit_t *tsu,
>srpc_client_rpc_t *rpc)
> 	LASSERT(sn);
> 
> 	if (rpc->crpc_status) {
>-		if (!tsi->tsi_stopping) /* rpc could have been aborted */
>+		if (!tsi->tsi_stopping)	/* rpc could have been aborted */
> 			atomic_inc(&sn->sn_ping_errors);
> 		CERROR("Unable to ping %s (%d): %d\n",
> 		       libcfs_id2str(rpc->crpc_dest),
>diff --git a/drivers/staging/lustre/lnet/selftest/rpc.c
>b/drivers/staging/lustre/lnet/selftest/rpc.c
>index 69be7d6..83216aa 100644
>--- a/drivers/staging/lustre/lnet/selftest/rpc.c
>+++ b/drivers/staging/lustre/lnet/selftest/rpc.c
>@@ -276,7 +276,7 @@ srpc_service_init(struct srpc_service *svc)
> 		scd->scd_ev.ev_data = scd;
> 		scd->scd_ev.ev_type = SRPC_REQUEST_RCVD;
> 
>-		/*
>+		/**
> 		 * NB: don't use lst_sched_serial for adding buffer,
> 		 * see details in srpc_service_add_buffers()
> 		 */
>@@ -284,7 +284,7 @@ srpc_service_init(struct srpc_service *svc)
> 				  srpc_add_buffer, lst_sched_test[i]);
> 
> 		if (i && srpc_serv_is_framework(svc)) {
>-			/*
>+			/**
> 			 * NB: framework service only needs srpc_service_cd for
> 			 * one partition, but we allocate for all to make
> 			 * it easier to implement, it will waste a little
>@@ -415,7 +415,7 @@ srpc_post_active_rdma(int portal, __u64 matchbits,
>void *buf, int len,
> 		return -ENOMEM;
> 	}
> 
>-	/*
>+	/**
> 	 * this is kind of an abuse of the LNET_MD_OP_{PUT,GET} options.
> 	 * they're only meaningful for MDs attached to an ME (i.e. passive
> 	 * buffers...
>@@ -434,7 +434,7 @@ srpc_post_active_rdma(int portal, __u64 matchbits,
>void *buf, int len,
> 		       options & LNET_MD_OP_PUT ? "Put" : "Get",
> 		       libcfs_id2str(peer), portal, matchbits, rc);
> 
>-		/*
>+		/**
> 		 * The forthcoming unlink event will complete this operation
> 		 * with failure, so fall through and return success here.
> 		 */
>@@ -479,7 +479,7 @@ __must_hold(&scd->scd_lock)
> 				      msg, sizeof(*msg), &buf->buf_mdh,
> 				      &scd->scd_ev);
> 
>-	/*
>+	/**
> 	 * At this point, a RPC (new or delayed) may have arrived in
> 	 * msg and its event handler has been called. So we must add
> 	 * buf to scd_buf_posted _before_ dropping scd_lock
>@@ -491,7 +491,7 @@ __must_hold(&scd->scd_lock)
> 			return 0;
> 
> 		spin_unlock(&scd->scd_lock);
>-		/*
>+		/**
> 		 * srpc_shutdown_service might have tried to unlink me
> 		 * when my buf_mdh was still invalid
> 		 */
>@@ -520,7 +520,7 @@ srpc_add_buffer(struct swi_workitem *wi)
> 	struct srpc_buffer *buf;
> 	int rc = 0;
> 
>-	/*
>+	/**
> 	 * it's called by workitem scheduler threads, these threads
> 	 * should have been set CPT affinity, so buffers will be posted
> 	 * on CPT local list of Portal
>@@ -602,7 +602,7 @@ srpc_service_add_buffers(struct srpc_service *sv, int
>nbuffer)
> 
> 	cfs_percpt_for_each(scd, i, sv->sv_cpt_data) {
> 		spin_lock(&scd->scd_lock);
>-		/*
>+		/**
> 		 * NB: srpc_service_add_buffers() can be called inside
> 		 * thread context of lst_sched_serial, and we don't normally
> 		 * allow to sleep inside thread context of WI scheduler
>@@ -740,7 +740,7 @@ srpc_abort_service(struct srpc_service *sv)
> 	cfs_percpt_for_each(scd, i, sv->sv_cpt_data) {
> 		spin_lock(&scd->scd_lock);
> 
>-		/*
>+		/**
> 		 * schedule in-flight RPCs to notice the abort, NB:
> 		 * racing with incoming RPCs; complete fix should make test
> 		 * RPCs carry session ID in its headers
>@@ -782,7 +782,7 @@ srpc_shutdown_service(srpc_service_t *sv)
> 
> 		spin_unlock(&scd->scd_lock);
> 
>-		/*
>+		/**
> 		 * OK to traverse scd_buf_posted without lock, since no one
> 		 * touches scd_buf_posted now
> 		 */
>@@ -927,7 +927,7 @@ srpc_server_rpc_done(struct srpc_server_rpc *rpc, int
>status)
> 	spin_lock(&scd->scd_lock);
> 
> 	if (rpc->srpc_reqstbuf) {
>-		/*
>+		/**
> 		 * NB might drop sv_lock in srpc_service_recycle_buffer, but
> 		 * sv won't go away for scd_rpc_active must not be empty
> 		 */
>@@ -937,7 +937,7 @@ srpc_server_rpc_done(struct srpc_server_rpc *rpc, int
>status)
> 
> 	list_del(&rpc->srpc_list); /* from scd->scd_rpc_active */
> 
>-	/*
>+	/**
> 	 * No one can schedule me now since:
> 	 * - I'm not on scd_rpc_active.
> 	 * - all LNet events have been fired.
>@@ -1110,7 +1110,7 @@ srpc_add_client_rpc_timer(srpc_client_rpc_t *rpc)
> 	stt_add_timer(timer);
> }
> 
>-/*
>+/**
>  * Called with rpc->crpc_lock held.
>  *
>  * Upon exit the RPC expiry timer is not queued and the handler is not
>@@ -1157,7 +1157,7 @@ srpc_client_rpc_done(srpc_client_rpc_t *rpc, int
>status)
> 		     rpc->crpc_service, libcfs_id2str(rpc->crpc_dest),
> 		     swi_state2str(wi->swi_state), rpc->crpc_aborted, status);
> 
>-	/*
>+	/**
> 	 * No one can schedule me now since:
> 	 * - RPC timer has been defused.
> 	 * - all LNet events have been fired.
>@@ -1222,7 +1222,7 @@ srpc_send_rpc(swi_workitem_t *wi)
> 		break;
> 
> 	case SWI_STATE_REQUEST_SUBMITTED:
>-		/*
>+		/**
> 		 * CAVEAT EMPTOR: rqtev, rpyev, and bulkev may come in any
> 		 * order; however, they're processed in a strict order:
> 		 * rqt, rpy, and bulk.
>@@ -1273,7 +1273,7 @@ srpc_send_rpc(swi_workitem_t *wi)
> 
> 		rc = do_bulk ? rpc->crpc_bulkev.ev_status : 0;
> 
>-		/*
>+		/**
> 		 * Bulk buffer was unlinked due to remote error. Clear error
> 		 * since reply buffer still contains valid data.
> 		 * NB rpc->crpc_done shouldn't look into bulk data in case of
>@@ -1332,8 +1332,8 @@ srpc_abort_rpc(srpc_client_rpc_t *rpc, int why)
> {
> 	LASSERT(why);
> 
>-	if (rpc->crpc_aborted || /* already aborted */
>-	    rpc->crpc_closed)	 /* callback imminent */
>+	if (rpc->crpc_aborted ||	/* already aborted */
>+	    rpc->crpc_closed)		/* callback imminent */
> 		return;
> 
> 	CDEBUG(D_NET, "Aborting RPC: service %d, peer %s, state %s, why %d\n",
>@@ -1377,7 +1377,7 @@ srpc_send_reply(struct srpc_server_rpc *rpc)
> 	spin_lock(&scd->scd_lock);
> 
> 	if (!sv->sv_shuttingdown && !srpc_serv_is_framework(sv)) {
>-		/*
>+		/**
> 		 * Repost buffer before replying since test client
> 		 * might send me another RPC once it gets the reply
> 		 */
>@@ -1401,7 +1401,7 @@ srpc_send_reply(struct srpc_server_rpc *rpc)
> 				   rpc->srpc_peer, rpc->srpc_self,
> 				   &rpc->srpc_replymdh, ev);
> 	if (rc)
>-		ev->ev_fired = 1;  /* no more event expected */
>+		ev->ev_fired = 1; /* no more event expected */
> 	return rc;
> }
> 
>@@ -1494,7 +1494,7 @@ srpc_lnet_ev_handler(lnet_event_t *ev)
> 		scd->scd_buf_nposted--;
> 
> 		if (sv->sv_shuttingdown) {
>-			/*
>+			/**
> 			 * Leave buffer on scd->scd_buf_nposted since
> 			 * srpc_finish_service needs to traverse it.
> 			 */
>@@ -1509,7 +1509,7 @@ srpc_lnet_ev_handler(lnet_event_t *ev)
> 			scd->scd_buf_err = 0;
> 		}
> 
>-		if (!scd->scd_buf_err && /* adding buffer is enabled */
>+		if (!scd->scd_buf_err &&	/* adding buffer is enabled */
> 		    !scd->scd_buf_adjust &&
> 		    scd->scd_buf_nposted < scd->scd_buf_low) {
> 			scd->scd_buf_adjust = max(scd->scd_buf_total / 2,
>@@ -1531,7 +1531,7 @@ srpc_lnet_ev_handler(lnet_event_t *ev)
> 			       ev->status, ev->mlength,
> 			       msg->msg_type, msg->msg_magic);
> 
>-			/*
>+			/**
> 			 * NB can't call srpc_service_recycle_buffer here since
> 			 * it may call LNetM[DE]Attach. The invalid magic tells
> 			 * srpc_handle_rpc to drop this RPC
>diff --git a/drivers/staging/lustre/lnet/selftest/rpc.h
>b/drivers/staging/lustre/lnet/selftest/rpc.h
>index a79c315..7cbf19d 100644
>--- a/drivers/staging/lustre/lnet/selftest/rpc.h
>+++ b/drivers/staging/lustre/lnet/selftest/rpc.h
>@@ -281,7 +281,7 @@ srpc_unpack_msg_hdr(srpc_msg_t *msg)
> 	if (msg->msg_magic == SRPC_MSG_MAGIC)
> 		return; /* no flipping needed */
> 
>-	/*
>+	/**
> 	 * We do not swap the magic number here as it is needed to
> 	 * determine whether the body needs to be swapped.
> 	 */
>diff --git a/drivers/staging/lustre/lnet/selftest/selftest.h
>b/drivers/staging/lustre/lnet/selftest/selftest.h
>index 288522d..b1460f3 100644
>--- a/drivers/staging/lustre/lnet/selftest/selftest.h
>+++ b/drivers/staging/lustre/lnet/selftest/selftest.h
>@@ -71,7 +71,8 @@ struct srpc_service_cd;
> struct sfw_test_unit;
> struct sfw_test_instance;
> 
>-/* services below SRPC_FRAMEWORK_SERVICE_MAX_ID are framework
>+/**
>+ * services below SRPC_FRAMEWORK_SERVICE_MAX_ID are framework
>  * services, e.g. create/modify session.
>  */
> #define SRPC_SERVICE_DEBUG		0
>diff --git a/drivers/staging/lustre/lnet/selftest/timer.c
>b/drivers/staging/lustre/lnet/selftest/timer.c
>index 8be5252..3e83442 100644
>--- a/drivers/staging/lustre/lnet/selftest/timer.c
>+++ b/drivers/staging/lustre/lnet/selftest/timer.c
>@@ -42,14 +42,14 @@
> 
> #include "selftest.h"
> 
>-/*
>+/**
>  * Timers are implemented as a sorted queue of expiry times. The queue
>  * is slotted, with each slot holding timers which expire in a
>  * 2**STTIMER_MINPOLL (8) second period. The timers in each slot are
>  * sorted by increasing expiry time. The number of slots is 2**7 (128),
>  * to cover a time period of 1024 seconds into the future before
>wrapping.
>  */
>-#define STTIMER_MINPOLL        3   /* log2 min poll interval (8 s) */
>+#define STTIMER_MINPOLL        3	/* log2 min poll interval (8 s) */
> #define STTIMER_SLOTTIME       (1 << STTIMER_MINPOLL)
> #define STTIMER_SLOTTIMEMASK   (~(STTIMER_SLOTTIME - 1))
> #define STTIMER_NSLOTS	       (1 << 7)
>@@ -92,7 +92,7 @@ stt_add_timer(struct stt_timer *timer)
> 	spin_unlock(&stt_data.stt_lock);
> }
> 
>-/*
>+/**
>  * The function returns whether it has deactivated a pending timer or
>not.
>  * (ie. del_timer() of an inactive timer returns 0, del_timer() of an
>  * active timer returns 1.)
>-- 
>1.7.1
>
>_______________________________________________
>lustre-devel mailing list
>lustre-devel at lists.lustre.org
>http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
>


Cheers, Andreas
-- 
Andreas Dilger

Lustre Principal Architect
Intel High Performance Data Division
