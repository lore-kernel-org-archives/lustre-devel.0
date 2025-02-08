Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 9AFA4C02199
	for <lustre-devel@archiver.kernel.org>; Sat,  8 Feb 2025 00:31:00 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4YqWw46Ymhz1xRx;
	Fri, 07 Feb 2025 16:30:44 -0800 (PST)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4YqWvw2Bkvz1wsW
 for <lustre-devel@lists.lustre.org>; Fri, 07 Feb 2025 16:30:36 -0800 (PST)
Received: from star2.ccs.ornl.gov (ltm4-e204-208.ccs.ornl.gov [160.91.203.22])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id E9BFF88F9DB;
 Fri,  7 Feb 2025 19:30:32 -0500 (EST)
Received: by star2.ccs.ornl.gov (Postfix, from userid 2004)
 id DEF3D106BE18; Fri,  7 Feb 2025 19:30:32 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Fri,  7 Feb 2025 19:30:09 -0500
Message-ID: <20250208003027.180076-4-jsimmons@infradead.org>
X-Mailer: git-send-email 2.43.5
In-Reply-To: <20250208003027.180076-1-jsimmons@infradead.org>
References: <20250208003027.180076-1-jsimmons@infradead.org>
MIME-Version: 1.0
Subject: [lustre-devel] [PATCH 03/21] lustre: ptlrpc: replace OBD_ -> CFS_
 macros
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
Cc: Arshad Hussain <arshad.hussain@aeoncomputing.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Timothy Day <timday@amazon.com>

Replace OBD macros that are simply redefinitions
of CFS macros.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12610
Lustre-commit: 3e24d50046e59a552 ("LU-12610 ptlrpc: replace OBD_ -> CFS_ macros")
Signed-off-by: Timothy Day <timday@amazon.com>
Signed-off-by: Ben Evans <beevans@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/50684
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Arshad Hussain <arshad.hussain@aeoncomputing.com>
Reviewed-by: Neil Brown <neilb@suse.de>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ptlrpc/client.c    | 20 ++++++++++----------
 fs/lustre/ptlrpc/import.c    | 12 ++++++------
 fs/lustre/ptlrpc/niobuf.c    | 21 +++++++++++----------
 fs/lustre/ptlrpc/pinger.c    |  2 +-
 fs/lustre/ptlrpc/ptlrpcd.c   |  2 +-
 fs/lustre/ptlrpc/recover.c   |  4 ++--
 fs/lustre/ptlrpc/sec_plain.c |  4 ++--
 fs/lustre/ptlrpc/service.c   | 16 ++++++++--------
 8 files changed, 41 insertions(+), 40 deletions(-)

diff --git a/fs/lustre/ptlrpc/client.c b/fs/lustre/ptlrpc/client.c
index 7a267e67e45c..80eed1b67b9b 100644
--- a/fs/lustre/ptlrpc/client.c
+++ b/fs/lustre/ptlrpc/client.c
@@ -1829,13 +1829,13 @@ int ptlrpc_check_set(const struct lu_env *env, struct ptlrpc_request_set *set)
 			LASSERT(req->rq_next_phase != RQ_PHASE_UNDEFINED);
 
 			if (req->rq_req_deadline &&
-			    !OBD_FAIL_CHECK(OBD_FAIL_PTLRPC_LONG_REQ_UNLINK))
+			    !CFS_FAIL_CHECK(OBD_FAIL_PTLRPC_LONG_REQ_UNLINK))
 				req->rq_req_deadline = 0;
 			if (req->rq_reply_deadline &&
-			    !OBD_FAIL_CHECK(OBD_FAIL_PTLRPC_LONG_REPL_UNLINK))
+			    !CFS_FAIL_CHECK(OBD_FAIL_PTLRPC_LONG_REPL_UNLINK))
 				req->rq_reply_deadline = 0;
 			if (req->rq_bulk_deadline &&
-			    !OBD_FAIL_CHECK(OBD_FAIL_PTLRPC_LONG_BULK_UNLINK))
+			    !CFS_FAIL_CHECK(OBD_FAIL_PTLRPC_LONG_BULK_UNLINK))
 				req->rq_bulk_deadline = 0;
 
 			/*
@@ -1856,13 +1856,13 @@ int ptlrpc_check_set(const struct lu_env *env, struct ptlrpc_request_set *set)
 			 * Turn fail_loc off to prevent it from looping
 			 * forever.
 			 */
-			if (OBD_FAIL_CHECK(OBD_FAIL_PTLRPC_LONG_REPL_UNLINK)) {
-				OBD_FAIL_CHECK_ORSET(OBD_FAIL_PTLRPC_LONG_REPL_UNLINK,
-						     OBD_FAIL_ONCE);
+			if (CFS_FAIL_CHECK(OBD_FAIL_PTLRPC_LONG_REPL_UNLINK)) {
+				CFS_FAIL_CHECK_ORSET(OBD_FAIL_PTLRPC_LONG_REPL_UNLINK,
+						     CFS_FAIL_ONCE);
 			}
-			if (OBD_FAIL_CHECK(OBD_FAIL_PTLRPC_LONG_BULK_UNLINK)) {
-				OBD_FAIL_CHECK_ORSET(OBD_FAIL_PTLRPC_LONG_BULK_UNLINK,
-						     OBD_FAIL_ONCE);
+			if (CFS_FAIL_CHECK(OBD_FAIL_PTLRPC_LONG_BULK_UNLINK)) {
+				CFS_FAIL_CHECK_ORSET(OBD_FAIL_PTLRPC_LONG_BULK_UNLINK,
+						     CFS_FAIL_ONCE);
 			}
 
 			/* Move to next phase if reply was successfully
@@ -2702,7 +2702,7 @@ static int ptlrpc_unregister_reply(struct ptlrpc_request *request, int async)
 	LASSERT(!in_interrupt());
 
 	/* Let's setup deadline for reply unlink. */
-	if (OBD_FAIL_CHECK(OBD_FAIL_PTLRPC_LONG_REPL_UNLINK) &&
+	if (CFS_FAIL_CHECK(OBD_FAIL_PTLRPC_LONG_REPL_UNLINK) &&
 	    async && request->rq_reply_deadline == 0 && cfs_fail_val == 0)
 		request->rq_reply_deadline = ktime_get_real_seconds() +
 					     PTLRPC_REQ_LONG_UNLINK;
diff --git a/fs/lustre/ptlrpc/import.c b/fs/lustre/ptlrpc/import.c
index 697b3c36fb1b..47e805b773ab 100644
--- a/fs/lustre/ptlrpc/import.c
+++ b/fs/lustre/ptlrpc/import.c
@@ -298,8 +298,8 @@ void ptlrpc_invalidate_import(struct obd_import *imp)
 	if (!imp->imp_invalid || imp->imp_obd->obd_no_recov)
 		ptlrpc_deactivate_import(imp);
 
-	if (OBD_FAIL_PRECHECK(OBD_FAIL_PTLRPC_CONNECT_RACE)) {
-		OBD_RACE(OBD_FAIL_PTLRPC_CONNECT_RACE);
+	if (CFS_FAIL_PRECHECK(OBD_FAIL_PTLRPC_CONNECT_RACE)) {
+		CFS_RACE(OBD_FAIL_PTLRPC_CONNECT_RACE);
 		msleep(10 * MSEC_PER_SEC);
 	}
 	CFS_FAIL_TIMEOUT(OBD_FAIL_MGS_CONNECT_NET, 3 * cfs_fail_val / 2);
@@ -316,7 +316,7 @@ void ptlrpc_invalidate_import(struct obd_import *imp)
 		 * out. Use obd_timeout if calculated value is smaller
 		 * than it.
 		 */
-		if (!OBD_FAIL_CHECK(OBD_FAIL_PTLRPC_LONG_REPL_UNLINK)) {
+		if (!CFS_FAIL_CHECK(OBD_FAIL_PTLRPC_LONG_REPL_UNLINK)) {
 			timeout = ptlrpc_inflight_timeout(imp);
 			timeout += div_u64(timeout, 3);
 
@@ -1436,7 +1436,7 @@ static int signal_completed_replay(struct obd_import *imp)
 {
 	struct ptlrpc_request *req;
 
-	if (unlikely(OBD_FAIL_CHECK(OBD_FAIL_PTLRPC_FINISH_REPLAY)))
+	if (unlikely(CFS_FAIL_CHECK(OBD_FAIL_PTLRPC_FINISH_REPLAY)))
 		return 0;
 
 	if (!atomic_add_unless(&imp->imp_replay_inflight, 1, 1))
@@ -1835,12 +1835,12 @@ int ptlrpc_disconnect_and_idle_import(struct obd_import *imp)
 
 	req->rq_interpret_reply = ptlrpc_disconnect_idle_interpret;
 
-	if (OBD_FAIL_PRECHECK(OBD_FAIL_PTLRPC_IDLE_RACE)) {
+	if (CFS_FAIL_PRECHECK(OBD_FAIL_PTLRPC_IDLE_RACE)) {
 		u32 idx;
 
 		server_name2index(imp->imp_obd->obd_name, &idx, NULL);
 		if (idx == 0)
-			OBD_RACE(OBD_FAIL_PTLRPC_IDLE_RACE);
+			CFS_RACE(OBD_FAIL_PTLRPC_IDLE_RACE);
 	}
 
 	spin_lock(&imp->imp_lock);
diff --git a/fs/lustre/ptlrpc/niobuf.c b/fs/lustre/ptlrpc/niobuf.c
index ccc2caab3876..d426d3c678b7 100644
--- a/fs/lustre/ptlrpc/niobuf.c
+++ b/fs/lustre/ptlrpc/niobuf.c
@@ -68,10 +68,11 @@ static int ptl_send_buf(struct lnet_handle_md *mdh, void *base, int len,
 		md.options |= LNET_MD_BULK_HANDLE;
 	}
 
-	if (unlikely(ack == LNET_ACK_REQ &&
-		     OBD_FAIL_CHECK_ORSET(OBD_FAIL_PTLRPC_ACK, OBD_FAIL_ONCE)))
+	if (CFS_FAIL_CHECK_ORSET(OBD_FAIL_PTLRPC_ACK, OBD_FAIL_ONCE) &&
+	    ack == LNET_ACK_REQ) {
 		/* don't ask for the ack to simulate failing client */
 		ack = LNET_NOACK_REQ;
+	}
 
 	rc = LNetMDBind(&md, LNET_UNLINK, mdh);
 	if (unlikely(rc != 0)) {
@@ -128,7 +129,7 @@ static int ptlrpc_register_bulk(struct ptlrpc_request *req)
 	struct lnet_me *me;
 	struct lnet_md md;
 
-	if (OBD_FAIL_CHECK(OBD_FAIL_PTLRPC_BULK_GET_NET))
+	if (CFS_FAIL_CHECK(OBD_FAIL_PTLRPC_BULK_GET_NET))
 		return 0;
 
 	/* NB no locking required until desc is on the network */
@@ -183,7 +184,7 @@ static int ptlrpc_register_bulk(struct ptlrpc_request *req)
 		ptlrpc_fill_bulk_md(&md, desc, posted_md);
 
 		if (posted_md > 0 && posted_md + 1 == desc->bd_md_count &&
-		    OBD_FAIL_CHECK(OBD_FAIL_PTLRPC_BULK_ATTACH)) {
+		    CFS_FAIL_CHECK(OBD_FAIL_PTLRPC_BULK_ATTACH)) {
 			rc = -ENOMEM;
 		} else {
 			me = LNetMEAttach(desc->bd_portal, &peer, mbits, 0,
@@ -255,7 +256,7 @@ int ptlrpc_unregister_bulk(struct ptlrpc_request *req, int async)
 		desc->bd_registered = 0;
 
 	/* Let's setup deadline for reply unlink. */
-	if (OBD_FAIL_CHECK(OBD_FAIL_PTLRPC_LONG_BULK_UNLINK) &&
+	if (CFS_FAIL_CHECK(OBD_FAIL_PTLRPC_LONG_BULK_UNLINK) &&
 	    async && req->rq_bulk_deadline == 0 && cfs_fail_val == 0)
 		req->rq_bulk_deadline = ktime_get_real_seconds() +
 					PTLRPC_REQ_LONG_UNLINK;
@@ -504,7 +505,7 @@ int ptl_send_rpc(struct ptlrpc_request *request, int noreply)
 
 	bulk_cookie.cookie = LNET_WIRE_HANDLE_COOKIE_NONE;
 
-	if (OBD_FAIL_CHECK(OBD_FAIL_PTLRPC_DROP_RPC))
+	if (CFS_FAIL_CHECK(OBD_FAIL_PTLRPC_DROP_RPC))
 		return 0;
 
 	LASSERT(request->rq_type == PTL_RPC_MSG_REQUEST);
@@ -640,7 +641,7 @@ int ptl_send_rpc(struct ptlrpc_request *request, int noreply)
 
 		peer = connection->c_peer;
 		if (request->rq_bulk &&
-		    OBD_FAIL_CHECK(OBD_FAIL_PTLRPC_BULK_REPLY_ATTACH)) {
+		    CFS_FAIL_CHECK(OBD_FAIL_PTLRPC_BULK_REPLY_ATTACH)) {
 			reply_me = ERR_PTR(-ENOMEM);
 		} else {
 			reply_me = LNetMEAttach(request->rq_reply_portal,
@@ -715,7 +716,7 @@ int ptl_send_rpc(struct ptlrpc_request *request, int noreply)
 		lprocfs_counter_add(obd->obd_svc_stats, PTLRPC_REQACTIVE_CNTR,
 			atomic_read(&imp->imp_inflight));
 
-	OBD_FAIL_TIMEOUT(OBD_FAIL_PTLRPC_DELAY_SEND, request->rq_timeout + 5);
+	CFS_FAIL_TIMEOUT(OBD_FAIL_PTLRPC_DELAY_SEND, request->rq_timeout + 5);
 
 	request->rq_sent_ns = ktime_get_real();
 	request->rq_sent = ktime_get_real_seconds();
@@ -726,7 +727,7 @@ int ptl_send_rpc(struct ptlrpc_request *request, int noreply)
 			       ptlrpc_at_get_net_latency(request);
 
 	if (unlikely(opc == OBD_PING &&
-	    OBD_FAIL_TIMEOUT(OBD_FAIL_PTLRPC_DELAY_SEND_FAIL, cfs_fail_val)))
+	    CFS_FAIL_TIMEOUT(OBD_FAIL_PTLRPC_DELAY_SEND_FAIL, cfs_fail_val)))
 		goto skip_send;
 
 	DEBUG_REQ(D_INFO, request, "send flags=%x",
@@ -790,7 +791,7 @@ int ptlrpc_register_rqbd(struct ptlrpc_request_buffer_desc *rqbd)
 	CDEBUG(D_NET, "%s: registering portal %d\n", service->srv_name,
 	       service->srv_req_portal);
 
-	if (OBD_FAIL_CHECK(OBD_FAIL_PTLRPC_RQBD))
+	if (CFS_FAIL_CHECK(OBD_FAIL_PTLRPC_RQBD))
 		return -ENOMEM;
 
 	/* NB: CPT affinity service should use new LNet flag LNET_INS_LOCAL,
diff --git a/fs/lustre/ptlrpc/pinger.c b/fs/lustre/ptlrpc/pinger.c
index 76a08442c870..5bcf00469c12 100644
--- a/fs/lustre/ptlrpc/pinger.c
+++ b/fs/lustre/ptlrpc/pinger.c
@@ -155,7 +155,7 @@ static int ptlrpc_ping(struct obd_import *imp)
 static inline int imp_is_deactive(struct obd_import *imp)
 {
 	return (imp->imp_deactive ||
-		OBD_FAIL_CHECK(OBD_FAIL_PTLRPC_IMP_DEACTIVE));
+		CFS_FAIL_CHECK(OBD_FAIL_PTLRPC_IMP_DEACTIVE));
 }
 
 static inline time64_t ptlrpc_next_reconnect(struct obd_import *imp)
diff --git a/fs/lustre/ptlrpc/ptlrpcd.c b/fs/lustre/ptlrpc/ptlrpcd.c
index 7342db8e56a3..f9152752f4dc 100644
--- a/fs/lustre/ptlrpc/ptlrpcd.c
+++ b/fs/lustre/ptlrpc/ptlrpcd.c
@@ -60,7 +60,7 @@
 #include <lustre_lib.h>
 #include <lustre_ha.h>
 #include <obd_class.h>		/* for obd_zombie */
-#include <obd_support.h>	/* for OBD_FAIL_CHECK */
+#include <obd_support.h>
 #include <cl_object.h>		/* cl_env_{get,put}() */
 #include <lprocfs_status.h>
 
diff --git a/fs/lustre/ptlrpc/recover.c b/fs/lustre/ptlrpc/recover.c
index 6ba31c133ed0..4af8388d1cbc 100644
--- a/fs/lustre/ptlrpc/recover.c
+++ b/fs/lustre/ptlrpc/recover.c
@@ -200,7 +200,7 @@ int ptlrpc_resend(struct obd_import *imp)
 	}
 	spin_unlock(&imp->imp_lock);
 
-	OBD_FAIL_TIMEOUT(OBD_FAIL_LDLM_ENQUEUE_OLD_EXPORT, 2);
+	CFS_FAIL_TIMEOUT(OBD_FAIL_LDLM_ENQUEUE_OLD_EXPORT, 2);
 	return 0;
 }
 
@@ -330,7 +330,7 @@ int ptlrpc_recover_import(struct obd_import *imp, char *new_uuid, int async)
 	if (rc)
 		goto out;
 
-	OBD_RACE(OBD_FAIL_PTLRPC_CONNECT_RACE);
+	CFS_RACE(OBD_FAIL_PTLRPC_CONNECT_RACE);
 
 	rc = ptlrpc_connect_import(imp);
 	if (rc)
diff --git a/fs/lustre/ptlrpc/sec_plain.c b/fs/lustre/ptlrpc/sec_plain.c
index d546722ce398..858d71d7f432 100644
--- a/fs/lustre/ptlrpc/sec_plain.c
+++ b/fs/lustre/ptlrpc/sec_plain.c
@@ -313,7 +313,7 @@ int plain_cli_wrap_bulk(struct ptlrpc_cli_ctx *ctx,
 		 * for sending we only compute the wrong checksum instead
 		 * of corrupting the data so it is still correct on a redo
 		 */
-		if (OBD_FAIL_CHECK(OBD_FAIL_OSC_CHECKSUM_SEND) &&
+		if (CFS_FAIL_CHECK(OBD_FAIL_OSC_CHECKSUM_SEND) &&
 		    req->rq_flvr.u_bulk.hash.hash_alg != BULK_HASH_ALG_NULL)
 			token->pbt_hash[0] ^= 0x1;
 	}
@@ -944,7 +944,7 @@ int plain_svc_wrap_bulk(struct ptlrpc_request *req,
 		CERROR("bulk read: server failed to compute checksum: %d\n",
 		       rc);
 	} else {
-		if (OBD_FAIL_CHECK(OBD_FAIL_OSC_CHECKSUM_RECEIVE))
+		if (CFS_FAIL_CHECK(OBD_FAIL_OSC_CHECKSUM_RECEIVE))
 			corrupt_bulk_data(desc);
 	}
 
diff --git a/fs/lustre/ptlrpc/service.c b/fs/lustre/ptlrpc/service.c
index bf7627227a5a..3acf1bbed0ef 100644
--- a/fs/lustre/ptlrpc/service.c
+++ b/fs/lustre/ptlrpc/service.c
@@ -1610,7 +1610,7 @@ static int ptlrpc_server_handle_req_in(struct ptlrpc_service_part *svcpt,
 	}
 
 	opc = lustre_msg_get_opc(req->rq_reqmsg);
-	if (OBD_FAIL_CHECK(OBD_FAIL_PTLRPC_DROP_REQ_OPC) &&
+	if (CFS_FAIL_CHECK(OBD_FAIL_PTLRPC_DROP_REQ_OPC) &&
 	    opc == cfs_fail_val) {
 		CERROR("drop incoming rpc opc %u, x%llu\n",
 		       cfs_fail_val, req->rq_xid);
@@ -1691,10 +1691,10 @@ static int ptlrpc_server_handle_req_in(struct ptlrpc_service_part *svcpt,
 	}
 
 
-	if (unlikely(OBD_FAIL_PRECHECK(OBD_FAIL_PTLRPC_ENQ_RESEND) &&
+	if (unlikely(CFS_FAIL_PRECHECK(OBD_FAIL_PTLRPC_ENQ_RESEND) &&
 		     (opc == LDLM_ENQUEUE) &&
 		     (lustre_msg_get_flags(req->rq_reqmsg) & MSG_RESENT)))
-		OBD_FAIL_TIMEOUT(OBD_FAIL_PTLRPC_ENQ_RESEND, 6);
+		CFS_FAIL_TIMEOUT(OBD_FAIL_PTLRPC_ENQ_RESEND, 6);
 
 	ptlrpc_at_add_timed(req);
 
@@ -1738,19 +1738,19 @@ static int ptlrpc_server_handle_request(struct ptlrpc_service_part *svcpt,
 	if (!request)
 		return 0;
 
-	if (OBD_FAIL_CHECK(OBD_FAIL_PTLRPC_HPREQ_NOTIMEOUT))
+	if (CFS_FAIL_CHECK(OBD_FAIL_PTLRPC_HPREQ_NOTIMEOUT))
 		fail_opc = OBD_FAIL_PTLRPC_HPREQ_NOTIMEOUT;
-	else if (OBD_FAIL_CHECK(OBD_FAIL_PTLRPC_HPREQ_TIMEOUT))
+	else if (CFS_FAIL_CHECK(OBD_FAIL_PTLRPC_HPREQ_TIMEOUT))
 		fail_opc = OBD_FAIL_PTLRPC_HPREQ_TIMEOUT;
 
 	if (unlikely(fail_opc)) {
 		if (request->rq_export && request->rq_ops)
-			OBD_FAIL_TIMEOUT(fail_opc, 4);
+			CFS_FAIL_TIMEOUT(fail_opc, 4);
 	}
 
 	ptlrpc_rqphase_move(request, RQ_PHASE_INTERPRET);
 
-	if (OBD_FAIL_CHECK(OBD_FAIL_PTLRPC_DUMP_LOG))
+	if (CFS_FAIL_CHECK(OBD_FAIL_PTLRPC_DUMP_LOG))
 		libcfs_debug_dumplog();
 
 	work_start = ktime_get_real();
@@ -2633,7 +2633,7 @@ static int ptlrpc_start_thread(struct ptlrpc_service_part *svcpt, int wait)
 		return -ESRCH;
 
 	if (!ptlrpc_threads_increasable(svcpt) ||
-	    (OBD_FAIL_CHECK(OBD_FAIL_TGT_TOOMANY_THREADS) &&
+	    (CFS_FAIL_CHECK(OBD_FAIL_TGT_TOOMANY_THREADS) &&
 	     svcpt->scp_nthrs_running == svc->srv_nthrs_cpt_init - 1))
 		return -EMFILE;
 
-- 
2.39.3

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
