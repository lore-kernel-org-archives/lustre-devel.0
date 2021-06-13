Return-Path: <SRS0=27wn=LH=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CC5D9C48BDF
	for <lustre-devel@archiver.kernel.org>; Sun, 13 Jun 2021 23:12:52 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 9113161363
	for <lustre-devel@archiver.kernel.org>; Sun, 13 Jun 2021 23:12:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9113161363
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id D590621F710;
	Sun, 13 Jun 2021 16:12:22 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 8472021D4A8
 for <lustre-devel@lists.lustre.org>; Sun, 13 Jun 2021 16:11:43 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id BFA68100B035;
 Sun, 13 Jun 2021 19:11:38 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id BC4D49C319; Sun, 13 Jun 2021 19:11:38 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 13 Jun 2021 19:11:20 -0400
Message-Id: <1623625897-17706-11-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1623625897-17706-1-git-send-email-jsimmons@infradead.org>
References: <1623625897-17706-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 10/27] lustre: ptlrpc: do not match reply
 with resent RPC
X-BeenThere: lustre-devel@lists.lustre.org
X-Mailman-Version: 2.1.23
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
Cc: Vitaly Fertman <c17818@cray.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Vitaly Fertman <c17818@cray.com>

The server is able to filter by the connection ID, and drop late
coming RPCs of previous connections, however it does not happen for
replies. At the same time, this is a problem in some cases.

Allocate new matchbits for resends and check replies by them, instead
of xid. Connect RPCs are exceptions due to interop with old server -
at the time of connect we do not know yet if the server supports it.

HPE-bug-id: LUS-9596
WC-bug-id: https://jira.whamcloud.com/browse/LU-14594
Lustre-commit: 057fafc018d7369d ("LU-14594 ptlrpc: do not match reply with resent RPC")
Signed-off-by: Vitaly Fertman <c17818@cray.com>
Reviewed-on: https://es-gerrit.dev.cray.com/158446
Reviewed-by: Alexey Lyashkov <c17817@cray.com>
Reviewed-by: Andriy Skulysh <c17819@cray.com>
Tested-by: Elena Gryaznova <c17455@cray.com>
Reviewed-on: https://review.whamcloud.com/43242
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Mike Pershin <mpershin@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_net.h         |  3 +++
 fs/lustre/include/obd_support.h        |  1 +
 fs/lustre/llite/llite_lib.c            |  6 ++++--
 fs/lustre/obdclass/lprocfs_status.c    |  1 +
 fs/lustre/obdclass/obd_mount.c         |  4 +++-
 fs/lustre/obdecho/echo_client.c        |  4 +++-
 fs/lustre/ptlrpc/client.c              | 21 ++++++++++-----------
 fs/lustre/ptlrpc/niobuf.c              | 20 +++++++++++++++-----
 fs/lustre/ptlrpc/pack_generic.c        | 18 ++++++++++++++++++
 fs/lustre/ptlrpc/ptlrpc_internal.h     |  2 +-
 fs/lustre/ptlrpc/service.c             | 18 ++++++++++++++++--
 fs/lustre/ptlrpc/wiretest.c            |  2 ++
 include/uapi/linux/lustre/lustre_idl.h |  1 +
 13 files changed, 78 insertions(+), 23 deletions(-)

diff --git a/fs/lustre/include/lustre_net.h b/fs/lustre/include/lustre_net.h
index f84ee46..c894d0f 100644
--- a/fs/lustre/include/lustre_net.h
+++ b/fs/lustre/include/lustre_net.h
@@ -867,6 +867,8 @@ struct ptlrpc_request {
 	u64				rq_xid;
 	/** bulk match bits */
 	u64				rq_mbits;
+	/** reply match bits */
+	u64				rq_rep_mbits;
 	/**
 	 * List item to for replay list. Not yet committed requests get linked
 	 * there.
@@ -2104,6 +2106,7 @@ int lustre_shrink_msg(struct lustre_msg *msg, int segment,
 timeout_t lustre_msg_get_service_timeout(struct lustre_msg *msg);
 char *lustre_msg_get_jobid(struct lustre_msg *msg);
 u32 lustre_msg_get_cksum(struct lustre_msg *msg);
+u64 lustre_msg_get_mbits(struct lustre_msg *msg);
 u32 lustre_msg_calc_cksum(struct lustre_msg *msg, u32 buf);
 void lustre_msg_set_handle(struct lustre_msg *msg,
 			   struct lustre_handle *handle);
diff --git a/fs/lustre/include/obd_support.h b/fs/lustre/include/obd_support.h
index 4628fab..962a99b 100644
--- a/fs/lustre/include/obd_support.h
+++ b/fs/lustre/include/obd_support.h
@@ -366,6 +366,7 @@
 #define OBD_FAIL_PTLRPC_ROUND_XID			0x530
 #define OBD_FAIL_PTLRPC_CONNECT_RACE			0x531
 #define OBD_FAIL_PTLRPC_IDLE_RACE			0x533
+#define OBD_FAIL_PTLRPC_ENQ_RESEND			0x534
 
 #define OBD_FAIL_OBD_PING_NET				0x600
 /*	OBD_FAIL_OBD_LOG_CANCEL_NET	0x601 obsolete since 1.5 */
diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index e98972d..66444fe 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -315,7 +315,8 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt)
 				   OBD_CONNECT2_PCC |
 				   OBD_CONNECT2_CRUSH | OBD_CONNECT2_LSEEK |
 				   OBD_CONNECT2_GETATTR_PFID |
-				   OBD_CONNECT2_DOM_LVB;
+				   OBD_CONNECT2_DOM_LVB |
+				   OBD_CONNECT2_REP_MBITS;
 
 	if (sbi->ll_flags & LL_SBI_LRU_RESIZE)
 		data->ocd_connect_flags |= OBD_CONNECT_LRU_RESIZE;
@@ -519,7 +520,8 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt)
 				  OBD_CONNECT_FLAGS2 | OBD_CONNECT_GRANT_SHRINK;
 
 	data->ocd_connect_flags2 = OBD_CONNECT2_LOCKAHEAD |
-				   OBD_CONNECT2_INC_XID | OBD_CONNECT2_LSEEK;
+				   OBD_CONNECT2_INC_XID | OBD_CONNECT2_LSEEK |
+				   OBD_CONNECT2_REP_MBITS;
 
 	if (!OBD_FAIL_CHECK(OBD_FAIL_OSC_CONNECT_GRANT_PARAM))
 		data->ocd_connect_flags |= OBD_CONNECT_GRANT_PARAM;
diff --git a/fs/lustre/obdclass/lprocfs_status.c b/fs/lustre/obdclass/lprocfs_status.c
index cd5a2fa..0cad91d 100644
--- a/fs/lustre/obdclass/lprocfs_status.c
+++ b/fs/lustre/obdclass/lprocfs_status.c
@@ -130,6 +130,7 @@
 	"getattr_pfid",		/* 0x20000 */
 	"lseek",		/* 0x40000 */
 	"dom_lvb",		/* 0x80000 */
+	"reply_mbits",		/* 0x100000 */
 	NULL
 };
 
diff --git a/fs/lustre/obdclass/obd_mount.c b/fs/lustre/obdclass/obd_mount.c
index 0a5e338..19684fb 100644
--- a/fs/lustre/obdclass/obd_mount.c
+++ b/fs/lustre/obdclass/obd_mount.c
@@ -395,7 +395,9 @@ int lustre_start_mgc(struct super_block *sb)
 	/* We connect to the MGS at setup, and don't disconnect until cleanup */
 	data->ocd_connect_flags = OBD_CONNECT_VERSION | OBD_CONNECT_AT |
 				  OBD_CONNECT_FULL20 | OBD_CONNECT_IMP_RECOV |
-				  OBD_CONNECT_LVB_TYPE | OBD_CONNECT_BULK_MBITS;
+				  OBD_CONNECT_LVB_TYPE |
+				  OBD_CONNECT_BULK_MBITS | OBD_CONNECT_FLAGS2;
+	data->ocd_connect_flags2 = OBD_CONNECT2_REP_MBITS;
 
 	if (lmd_is_client(lsi->lsi_lmd) &&
 	    lsi->lsi_lmd->lmd_flags & LMD_FLG_NOIR)
diff --git a/fs/lustre/obdecho/echo_client.c b/fs/lustre/obdecho/echo_client.c
index 0452942..c3a12ce 100644
--- a/fs/lustre/obdecho/echo_client.c
+++ b/fs/lustre/obdecho/echo_client.c
@@ -1653,7 +1653,9 @@ static int echo_client_setup(const struct lu_env *env,
 				 OBD_CONNECT_BRW_SIZE |
 				 OBD_CONNECT_GRANT | OBD_CONNECT_FULL20 |
 				 OBD_CONNECT_64BITHASH | OBD_CONNECT_LVB_TYPE |
-				 OBD_CONNECT_FID;
+				 OBD_CONNECT_FID | OBD_CONNECT_FLAGS2;
+	ocd->ocd_connect_flags2 = OBD_CONNECT2_REP_MBITS;
+
 	ocd->ocd_brw_size = DT_MAX_BRW_SIZE;
 	ocd->ocd_version = LUSTRE_VERSION_CODE;
 	ocd->ocd_group = FID_SEQ_ECHO;
diff --git a/fs/lustre/ptlrpc/client.c b/fs/lustre/ptlrpc/client.c
index a812b29..83d269c 100644
--- a/fs/lustre/ptlrpc/client.c
+++ b/fs/lustre/ptlrpc/client.c
@@ -3223,12 +3223,11 @@ u64 ptlrpc_next_xid(void)
  * request to ensure previous bulk fails and avoid problems with lost replies
  * and therefore several transfers landing into the same buffer from different
  * sending attempts.
+ * Also, to avoid previous reply landing to a different sending attempt.
  */
-void ptlrpc_set_bulk_mbits(struct ptlrpc_request *req)
+void ptlrpc_set_mbits(struct ptlrpc_request *req)
 {
-	struct ptlrpc_bulk_desc *bd = req->rq_bulk;
-
-	LASSERT(bd);
+	int md_count = req->rq_bulk ? req->rq_bulk->bd_md_count : 1;
 
 	/*
 	 * Generate new matchbits for all resend requests, including
@@ -3244,7 +3243,7 @@ void ptlrpc_set_bulk_mbits(struct ptlrpc_request *req)
 		 * 'resend for the -EINPROGRESS resend'. To make it simple,
 		 * we opt to generate mbits for all resend cases.
 		 */
-		if (OCD_HAS_FLAG(&bd->bd_import->imp_connect_data,
+		if (OCD_HAS_FLAG(&req->rq_import->imp_connect_data,
 				 BULK_MBITS)) {
 			req->rq_mbits = ptlrpc_next_xid();
 		} else {
@@ -3256,15 +3255,15 @@ void ptlrpc_set_bulk_mbits(struct ptlrpc_request *req)
 			req->rq_mbits = req->rq_xid;
 		}
 
-		CDEBUG(D_HA, "resend bulk old x%llu new x%llu\n",
+		CDEBUG(D_HA, "resend with new mbits old x%llu new x%llu\n",
 		       old_mbits, req->rq_mbits);
 	} else if (!(lustre_msg_get_flags(req->rq_reqmsg) & MSG_REPLAY)) {
 		/* Request being sent first time, use xid as matchbits. */
-		if (OCD_HAS_FLAG(&bd->bd_import->imp_connect_data, BULK_MBITS)
-		    || req->rq_mbits == 0) {
+		if (OCD_HAS_FLAG(&req->rq_import->imp_connect_data,
+				 BULK_MBITS) || req->rq_mbits == 0) {
 			req->rq_mbits = req->rq_xid;
 		} else {
-			req->rq_mbits -= bd->bd_md_count - 1;
+			req->rq_mbits -= md_count - 1;
 		}
 	} else {
 		/*
@@ -3279,12 +3278,12 @@ void ptlrpc_set_bulk_mbits(struct ptlrpc_request *req)
 	 * that server can infer the number of bulks that were prepared,
 	 * see LU-1431
 	 */
-	req->rq_mbits += bd->bd_md_count - 1;
+	req->rq_mbits += md_count - 1;
 
 	/* Set rq_xid as rq_mbits to indicate the final bulk for the old
 	 * server which does not support OBD_CONNECT_BULK_MBITS. LU-6808
 	 */
-	if (!OCD_HAS_FLAG(&bd->bd_import->imp_connect_data, BULK_MBITS))
+	if (!OCD_HAS_FLAG(&req->rq_import->imp_connect_data, BULK_MBITS))
 		req->rq_xid = req->rq_mbits;
 }
 
diff --git a/fs/lustre/ptlrpc/niobuf.c b/fs/lustre/ptlrpc/niobuf.c
index cf9940b..614bb63 100644
--- a/fs/lustre/ptlrpc/niobuf.c
+++ b/fs/lustre/ptlrpc/niobuf.c
@@ -432,7 +432,8 @@ int ptlrpc_send_reply(struct ptlrpc_request *req, int flags)
 			  LNET_ACK_REQ : LNET_NOACK_REQ,
 			  &rs->rs_cb_id, req->rq_self, req->rq_source,
 			  ptlrpc_req2svc(req)->srv_rep_portal,
-			  req->rq_xid, req->rq_reply_off, NULL);
+			  req->rq_rep_mbits ? req->rq_rep_mbits : req->rq_xid,
+			  req->rq_reply_off, NULL);
 out:
 	if (unlikely(rc != 0))
 		ptlrpc_req_drop_rs(req);
@@ -487,7 +488,9 @@ int ptlrpc_error(struct ptlrpc_request *req)
 int ptl_send_rpc(struct ptlrpc_request *request, int noreply)
 {
 	int rc;
+	u32 opc;
 	unsigned int mpflag = 0;
+	bool rep_mbits = false;
 	struct lnet_handle_md bulk_cookie;
 	struct ptlrpc_connection *connection;
 	struct lnet_me *reply_me;
@@ -550,8 +553,14 @@ int ptl_send_rpc(struct ptlrpc_request *request, int noreply)
 			  "Allocating new XID for resend on EINPROGRESS");
 	}
 
-	if (request->rq_bulk) {
-		ptlrpc_set_bulk_mbits(request);
+	opc = lustre_msg_get_opc(request->rq_reqmsg);
+	if (opc != OST_CONNECT && opc != MDS_CONNECT &&
+	    opc != MGS_CONNECT && OCD_HAS_FLAG(&imp->imp_connect_data, FLAGS2))
+		rep_mbits = imp->imp_connect_data.ocd_connect_flags2 &
+			    OBD_CONNECT2_REP_MBITS;
+
+	if (request->rq_bulk || rep_mbits) {
+		ptlrpc_set_mbits(request);
 		lustre_msg_set_mbits(request->rq_reqmsg, request->rq_mbits);
 	}
 
@@ -624,8 +633,9 @@ int ptl_send_rpc(struct ptlrpc_request *request, int noreply)
 		} else {
 			reply_me = LNetMEAttach(request->rq_reply_portal,
 						connection->c_peer,
-						request->rq_xid, 0,
-						LNET_UNLINK, LNET_INS_AFTER);
+						rep_mbits ? request->rq_mbits :
+						request->rq_xid,
+						0, LNET_UNLINK, LNET_INS_AFTER);
 		}
 
 		if (IS_ERR(reply_me)) {
diff --git a/fs/lustre/ptlrpc/pack_generic.c b/fs/lustre/ptlrpc/pack_generic.c
index 047573a..133202d 100644
--- a/fs/lustre/ptlrpc/pack_generic.c
+++ b/fs/lustre/ptlrpc/pack_generic.c
@@ -1230,6 +1230,24 @@ u32 lustre_msg_get_cksum(struct lustre_msg *msg)
 	}
 }
 
+u64 lustre_msg_get_mbits(struct lustre_msg *msg)
+{
+	switch (msg->lm_magic) {
+	case LUSTRE_MSG_MAGIC_V2: {
+		struct ptlrpc_body *pb = lustre_msg_ptlrpc_body(msg);
+
+		if (!pb) {
+			CERROR("invalid msg %p: no ptlrpc body!\n", msg);
+			return 0;
+		}
+		return pb->pb_mbits;
+	}
+	default:
+		CERROR("incorrect message magic: %08x\n", msg->lm_magic);
+		return 0;
+	}
+}
+
 u32 lustre_msg_calc_cksum(struct lustre_msg *msg, u32 buf)
 {
 	switch (msg->lm_magic) {
diff --git a/fs/lustre/ptlrpc/ptlrpc_internal.h b/fs/lustre/ptlrpc/ptlrpc_internal.h
index 62c3c97..f1f414c 100644
--- a/fs/lustre/ptlrpc/ptlrpc_internal.h
+++ b/fs/lustre/ptlrpc/ptlrpc_internal.h
@@ -75,7 +75,7 @@ void ptlrpc_set_add_new_req(struct ptlrpcd_ctl *pc,
 void ptlrpc_expired_set(struct ptlrpc_request_set *set);
 time64_t ptlrpc_set_next_timeout(struct ptlrpc_request_set *set);
 void ptlrpc_resend_req(struct ptlrpc_request *request);
-void ptlrpc_set_bulk_mbits(struct ptlrpc_request *req);
+void ptlrpc_set_mbits(struct ptlrpc_request *req);
 void ptlrpc_assign_next_xid_nolock(struct ptlrpc_request *req);
 u64 ptlrpc_known_replied_xid(struct obd_import *imp);
 void ptlrpc_add_unreplied(struct ptlrpc_request *req);
diff --git a/fs/lustre/ptlrpc/service.c b/fs/lustre/ptlrpc/service.c
index 3d9192d..2917ca3 100644
--- a/fs/lustre/ptlrpc/service.c
+++ b/fs/lustre/ptlrpc/service.c
@@ -1554,6 +1554,7 @@ static int ptlrpc_server_handle_req_in(struct ptlrpc_service_part *svcpt,
 	struct ptlrpc_service *svc = svcpt->scp_service;
 	struct ptlrpc_request *req;
 	u32 deadline;
+	u32 opc;
 	int rc;
 
 	spin_lock(&svcpt->scp_lock);
@@ -1608,8 +1609,9 @@ static int ptlrpc_server_handle_req_in(struct ptlrpc_service_part *svcpt,
 		goto err_req;
 	}
 
+	opc = lustre_msg_get_opc(req->rq_reqmsg);
 	if (OBD_FAIL_CHECK(OBD_FAIL_PTLRPC_DROP_REQ_OPC) &&
-	    lustre_msg_get_opc(req->rq_reqmsg) == cfs_fail_val) {
+	    opc == cfs_fail_val) {
 		CERROR("drop incoming rpc opc %u, x%llu\n",
 		       cfs_fail_val, req->rq_xid);
 		goto err_req;
@@ -1623,7 +1625,7 @@ static int ptlrpc_server_handle_req_in(struct ptlrpc_service_part *svcpt,
 		goto err_req;
 	}
 
-	switch (lustre_msg_get_opc(req->rq_reqmsg)) {
+	switch (opc) {
 	case MDS_WRITEPAGE:
 	case OST_WRITE:
 		req->rq_bulk_write = 1;
@@ -1688,8 +1690,20 @@ static int ptlrpc_server_handle_req_in(struct ptlrpc_service_part *svcpt,
 		req->rq_svc_thread->t_env->le_ses = &req->rq_session;
 	}
 
+
+	if (unlikely(OBD_FAIL_PRECHECK(OBD_FAIL_PTLRPC_ENQ_RESEND) &&
+		     (opc == LDLM_ENQUEUE) &&
+		     (lustre_msg_get_flags(req->rq_reqmsg) & MSG_RESENT)))
+		OBD_FAIL_TIMEOUT(OBD_FAIL_PTLRPC_ENQ_RESEND, 6);
+
 	ptlrpc_at_add_timed(req);
 
+	if (opc != OST_CONNECT && opc != MDS_CONNECT &&
+	    opc != MGS_CONNECT && req->rq_export) {
+		if (exp_connect_flags2(req->rq_export) & OBD_CONNECT2_REP_MBITS)
+			req->rq_rep_mbits = lustre_msg_get_mbits(req->rq_reqmsg);
+	}
+
 	/* Move it over to the request processing queue */
 	rc = ptlrpc_server_request_add(svcpt, req);
 	if (rc)
diff --git a/fs/lustre/ptlrpc/wiretest.c b/fs/lustre/ptlrpc/wiretest.c
index 03fd815..db97748 100644
--- a/fs/lustre/ptlrpc/wiretest.c
+++ b/fs/lustre/ptlrpc/wiretest.c
@@ -1250,6 +1250,8 @@ void lustre_assert_wire_constants(void)
 		 OBD_CONNECT2_LSEEK);
 	LASSERTF(OBD_CONNECT2_DOM_LVB == 0x80000ULL, "found 0x%.16llxULL\n",
 		 OBD_CONNECT2_DOM_LVB);
+	LASSERTF(OBD_CONNECT2_REP_MBITS == 0x100000ULL, "found 0x%.16llxULL\n",
+		 OBD_CONNECT2_REP_MBITS);
 	LASSERTF(OBD_CKSUM_CRC32 == 0x00000001UL, "found 0x%.8xUL\n",
 		 (unsigned int)OBD_CKSUM_CRC32);
 	LASSERTF(OBD_CKSUM_ADLER == 0x00000002UL, "found 0x%.8xUL\n",
diff --git a/include/uapi/linux/lustre/lustre_idl.h b/include/uapi/linux/lustre/lustre_idl.h
index d62b3cd..813e4fc 100644
--- a/include/uapi/linux/lustre/lustre_idl.h
+++ b/include/uapi/linux/lustre/lustre_idl.h
@@ -839,6 +839,7 @@ struct ptlrpc_body_v2 {
 #define OBD_CONNECT2_GETATTR_PFID     0x20000ULL /* pack parent FID in getattr */
 #define OBD_CONNECT2_LSEEK	      0x40000ULL /* SEEK_HOLE/DATA RPC */
 #define OBD_CONNECT2_DOM_LVB	      0x80000ULL /* pack DOM glimpse data in LVB */
+#define OBD_CONNECT2_REP_MBITS	     0x100000ULL /* match reply by mbits, not xid */
 /* XXX README XXX:
  * Please DO NOT add flag values here before first ensuring that this same
  * flag value is not in use on some other branch.  Please clear any such
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
