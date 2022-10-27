Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 60AF7FA3741
	for <lustre-devel@archiver.kernel.org>; Thu, 27 Oct 2022 14:29:26 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4MynlR6jtrz22Qr;
	Thu, 27 Oct 2022 07:15:47 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4Mynky05vWz21CD
 for <lustre-devel@lists.lustre.org>; Thu, 27 Oct 2022 07:15:21 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id C4C18100910F;
 Thu, 27 Oct 2022 10:05:44 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 9176EFD4E1; Thu, 27 Oct 2022 10:05:44 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Thu, 27 Oct 2022 10:05:41 -0400
Message-Id: <1666879542-10737-15-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1666879542-10737-1-git-send-email-jsimmons@infradead.org>
References: <1666879542-10737-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 14/15] lnet: use 'fallthrough' pseudo keyword
 for switch
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
Cc: Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Jian Yu <yujian@whamcloud.com>

'/* fallthrough */' hits implicit-fallthrough error with GCC 11.

This patch replaces the existing '/* fallthrough */' comments and
its variants with the 'fallthrough' pseudo keyword, which was added
by Linux kernel commit v5.4-rc2-141-g294f69e662d1.

WC-bug-id: https://jira.whamcloud.com/browse/LU-15220
Lustre-commit: 8fed107588b74c2a8 ("LU-15220 lnet: use 'fallthrough' pseudo keyword for switch")
Signed-off-by: Jian Yu <yujian@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/45566
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/klnds/o2iblnd/o2iblnd.c    |  4 ++--
 net/lnet/klnds/o2iblnd/o2iblnd_cb.c |  5 ++---
 net/lnet/klnds/socklnd/socklnd.c    |  3 ++-
 net/lnet/klnds/socklnd/socklnd_cb.c |  2 +-
 net/lnet/lnet/lib-move.c            |  4 ++--
 net/lnet/lnet/net_fault.c           |  2 +-
 net/lnet/selftest/conctl.c          |  2 +-
 net/lnet/selftest/module.c          |  8 ++++----
 net/lnet/selftest/rpc.c             | 21 +++++++++++----------
 9 files changed, 26 insertions(+), 25 deletions(-)

diff --git a/net/lnet/klnds/o2iblnd/o2iblnd.c b/net/lnet/klnds/o2iblnd/o2iblnd.c
index d2e4ce9..94ff926 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd.c
+++ b/net/lnet/klnds/o2iblnd/o2iblnd.c
@@ -2841,7 +2841,7 @@ static void kiblnd_base_shutdown(void)
 				       !atomic_read(&kiblnd_data.kib_nthreads),
 				       "Waiting for %d threads to terminate\n",
 				       atomic_read(&kiblnd_data.kib_nthreads));
-		/* fall through */
+		fallthrough;
 
 	case IBLND_INIT_NOTHING:
 		break;
@@ -2898,7 +2898,7 @@ static void kiblnd_shutdown(struct lnet_ni *ni)
 				       "%s: waiting for %d conns to clean\n",
 				       libcfs_nidstr(&ni->ni_nid),
 				       atomic_read(&net->ibn_nconns));
-		/* fall through */
+		fallthrough;
 
 	case IBLND_INIT_NOTHING:
 		LASSERT(!atomic_read(&net->ibn_nconns));
diff --git a/net/lnet/klnds/o2iblnd/o2iblnd_cb.c b/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
index 3e3be065..b16841e 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -1821,9 +1821,8 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 	switch (rxmsg->ibm_type) {
 	default:
 		LBUG();
-
+		fallthrough;
 	case IBLND_MSG_IMMEDIATE:
-		/* fallthrough */
 		nob = offsetof(struct kib_msg, ibm_u.immediate.ibim_payload[rlen]);
 		if (nob > rx->rx_nob) {
 			CERROR("Immediate message from %s too big: %d(%d)\n",
@@ -2918,7 +2917,7 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 			}
 			break;
 		}
-		/* fall through */
+		fallthrough;
 	default:
 		CNETERR("%s rejected: reason %d, size %d\n",
 			libcfs_nid2str(peer_ni->ibp_nid), reason, priv_nob);
diff --git a/net/lnet/klnds/socklnd/socklnd.c b/net/lnet/klnds/socklnd/socklnd.c
index 996d3a9..e8f8020 100644
--- a/net/lnet/klnds/socklnd/socklnd.c
+++ b/net/lnet/klnds/socklnd/socklnd.c
@@ -2135,7 +2135,8 @@ static int ksocknal_inetaddr_event(struct notifier_block *unused,
 	switch (ksocknal_data.ksnd_init) {
 	default:
 		LASSERT(0);
-		/* fall through */
+		fallthrough;
+
 	case SOCKNAL_INIT_ALL:
 	case SOCKNAL_INIT_DATA:
 		hash_for_each(ksocknal_data.ksnd_peers, i, peer_ni, ksnp_list)
diff --git a/net/lnet/klnds/socklnd/socklnd_cb.c b/net/lnet/klnds/socklnd/socklnd_cb.c
index f358875..15fba9d 100644
--- a/net/lnet/klnds/socklnd/socklnd_cb.c
+++ b/net/lnet/klnds/socklnd/socklnd_cb.c
@@ -1254,7 +1254,7 @@ struct ksock_conn_cb *
 			ksocknal_close_conn_and_siblings(conn, rc);
 			return -EPROTO;
 		}
-		/* Fall through */
+		fallthrough;
 
 	case SOCKNAL_RX_SLOP:
 		/* starting new packet? */
diff --git a/net/lnet/lnet/lib-move.c b/net/lnet/lnet/lib-move.c
index d465789..225acca 100644
--- a/net/lnet/lnet/lib-move.c
+++ b/net/lnet/lnet/lib-move.c
@@ -3804,7 +3804,7 @@ struct lnet_mt_event_info {
 	case LNET_EVENT_UNLINK:
 		CDEBUG(D_NET, "%s recovery ping unlinked\n",
 		       libcfs_nidstr(&ev_info->mt_nid));
-		/* fall-through */
+		fallthrough;
 	case LNET_EVENT_REPLY:
 		lnet_handle_recovery_reply(ev_info, event->status, false,
 					   event->type == LNET_EVENT_UNLINK);
@@ -4012,7 +4012,7 @@ void lnet_monitor_thr_stop(void)
 			ready_delay = true;
 			goto again;
 		}
-		/* fall through */
+		fallthrough;
 
 	case LNET_MATCHMD_DROP:
 		CNETERR("Dropping PUT from %s portal %d match %llu offset %d length %d: %d\n",
diff --git a/net/lnet/lnet/net_fault.c b/net/lnet/lnet/net_fault.c
index fe7a07c..77cdb73 100644
--- a/net/lnet/lnet/net_fault.c
+++ b/net/lnet/lnet/net_fault.c
@@ -721,7 +721,7 @@ struct delay_daemon_data {
 			case LNET_CREDIT_OK:
 				lnet_ni_recv(ni, msg->msg_private, msg, 0,
 					     0, msg->msg_len, msg->msg_len);
-				/* fall through */
+				fallthrough;
 			case LNET_CREDIT_WAIT:
 				continue;
 			default: /* failures */
diff --git a/net/lnet/selftest/conctl.c b/net/lnet/selftest/conctl.c
index b6dc4ee..ede7fe5 100644
--- a/net/lnet/selftest/conctl.c
+++ b/net/lnet/selftest/conctl.c
@@ -136,7 +136,7 @@
 
 	case LST_OPC_BATCHSRV:
 		client = 0;
-		/* fall through */
+		fallthrough;
 	case LST_OPC_BATCHCLI:
 		if (!args->lstio_dbg_namep)
 			goto out;
diff --git a/net/lnet/selftest/module.c b/net/lnet/selftest/module.c
index f6a3ec2..333f392 100644
--- a/net/lnet/selftest/module.c
+++ b/net/lnet/selftest/module.c
@@ -57,13 +57,13 @@ enum {
 	switch (lst_init_step) {
 	case LST_INIT_CONSOLE:
 		lstcon_console_fini();
-		/* fall through */
+		fallthrough;
 	case LST_INIT_FW:
 		sfw_shutdown();
-		/* fall through */
+		fallthrough;
 	case LST_INIT_RPC:
 		srpc_shutdown();
-		/* fall through */
+		fallthrough;
 	case LST_INIT_WI_TEST:
 		for (i = 0;
 		     i < cfs_cpt_number(lnet_cpt_table()); i++) {
@@ -73,7 +73,7 @@ enum {
 		}
 		kvfree(lst_test_wq);
 		lst_test_wq = NULL;
-		/* fall through */
+		fallthrough;
 	case LST_INIT_WI_SERIAL:
 		destroy_workqueue(lst_serial_wq);
 		lst_serial_wq = NULL;
diff --git a/net/lnet/selftest/rpc.c b/net/lnet/selftest/rpc.c
index c376019..c75addc 100644
--- a/net/lnet/selftest/rpc.c
+++ b/net/lnet/selftest/rpc.c
@@ -1018,6 +1018,7 @@ struct srpc_bulk *
 	switch (wi->swi_state) {
 	default:
 		LBUG();
+		fallthrough;
 	case SWI_STATE_NEWBORN: {
 		struct srpc_msg *msg;
 		struct srpc_generic_reply *reply;
@@ -1059,7 +1060,7 @@ struct srpc_bulk *
 			ev->ev_status = rc;
 		}
 	}
-		/* fall through */
+	fallthrough;
 	case SWI_STATE_BULK_STARTED:
 		LASSERT(!rpc->srpc_bulk || ev->ev_fired);
 
@@ -1255,8 +1256,7 @@ struct srpc_bulk *
 			break;
 
 		wi->swi_state = SWI_STATE_REQUEST_SENT;
-		/* perhaps more events */
-		/* fall through */
+		fallthrough;
 	case SWI_STATE_REQUEST_SENT: {
 		enum srpc_msg_type type = srpc_service2reply(rpc->crpc_service);
 
@@ -1288,7 +1288,7 @@ struct srpc_bulk *
 
 		wi->swi_state = SWI_STATE_REPLY_RECEIVED;
 	}
-		/* fall through */
+	fallthrough;
 	case SWI_STATE_REPLY_RECEIVED:
 		if (do_bulk && !rpc->crpc_bulkev.ev_fired)
 			break;
@@ -1462,11 +1462,11 @@ struct srpc_client_rpc *
 		CERROR("Unknown event: status %d, type %d, lnet %d\n",
 		       rpcev->ev_status, rpcev->ev_type, rpcev->ev_lnet);
 		LBUG();
+		fallthrough;
 	case SRPC_REQUEST_SENT:
 		if (!ev->status && ev->type != LNET_EVENT_UNLINK)
 			atomic_inc(&RPC_STAT32(SRPC_RPC_SENT));
-
-		/* fall through */
+		fallthrough;
 	case SRPC_REPLY_RCVD:
 	case SRPC_BULK_REQ_RCVD:
 		crpc = rpcev->ev_data;
@@ -1588,7 +1588,7 @@ struct srpc_client_rpc *
 
 		if (!ev->unlinked)
 			break; /* wait for final event */
-		/* fall through */
+		fallthrough;
 	case SRPC_BULK_PUT_SENT:
 		if (!ev->status && ev->type != LNET_EVENT_UNLINK) {
 			atomic64_t *data;
@@ -1600,7 +1600,7 @@ struct srpc_client_rpc *
 
 			atomic64_add(ev->mlength, data);
 		}
-		/* fall through */
+		fallthrough;
 	case SRPC_REPLY_SENT:
 		srpc = rpcev->ev_data;
 		scd = srpc->srpc_scd;
@@ -1673,6 +1673,7 @@ struct srpc_client_rpc *
 	switch (state) {
 	default:
 		LBUG();
+		fallthrough;
 	case SRPC_STATE_RUNNING:
 		spin_lock(&srpc_data.rpc_glock);
 
@@ -1686,13 +1687,13 @@ struct srpc_client_rpc *
 		spin_unlock(&srpc_data.rpc_glock);
 
 		stt_shutdown();
-		/* fall through */
+		fallthrough;
 	case SRPC_STATE_EQ_INIT:
 		rc = LNetClearLazyPortal(SRPC_FRAMEWORK_REQUEST_PORTAL);
 		rc = LNetClearLazyPortal(SRPC_REQUEST_PORTAL);
 		LASSERT(!rc);
 		lnet_assert_handler_unused(srpc_data.rpc_lnet_handler);
-		/* fall through */
+		fallthrough;
 	case SRPC_STATE_NI_INIT:
 		LNetNIFini();
 	}
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
