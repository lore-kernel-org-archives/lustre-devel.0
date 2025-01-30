Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 54837C0218A
	for <lustre-devel@archiver.kernel.org>; Thu, 30 Jan 2025 14:13:19 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4YkLYt6N1zz1xfS;
	Thu, 30 Jan 2025 06:12:02 -0800 (PST)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4YkLYd5lkCz1xPH
 for <lustre-devel@lists.lustre.org>; Thu, 30 Jan 2025 06:11:49 -0800 (PST)
Received: from star2.ccs.ornl.gov (ltm3-e204-208.ccs.ornl.gov [160.91.203.26])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id ECB1C182336;
 Thu, 30 Jan 2025 09:11:32 -0500 (EST)
Received: by star2.ccs.ornl.gov (Postfix, from userid 2004)
 id E9E79106BE17; Thu, 30 Jan 2025 09:11:32 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Thu, 30 Jan 2025 09:10:57 -0500
Message-ID: <20250130141115.950749-8-jsimmons@infradead.org>
X-Mailer: git-send-email 2.43.5
In-Reply-To: <20250130141115.950749-1-jsimmons@infradead.org>
References: <20250130141115.950749-1-jsimmons@infradead.org>
MIME-Version: 1.0
Subject: [lustre-devel] [PATCH 07/25] lustre: ptlrpc: Track highest reply XID
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
Cc: Chris Horn <chris.horn@hpe.com>, Serguei Smirnov <ssmirnov@whamcloud.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Chris Horn <chris.horn@hpe.com>

Keep track of the highest XID that we've received a reply for.
When an OBD_PING expires, do not disconnect the import if the failed
XID is less than or equal to the last reply XID. This avoids situation
where a lost OBD_PING rpc causes a reconnect even though we've
completed other RPCs in the meantime.

HPE-bug-id: LUS-11474
WC-bug-id: https://jira.whamcloud.com/browse/LU-16483
Lustre-commit: eb1f4a5222039be9f7 ("LU-16483 ptlrpc: Track highest reply XID")
Signed-off-by: Chris Horn <chris.horn@hpe.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/49807
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_import.h |  4 +++-
 fs/lustre/include/obd_support.h   |  1 +
 fs/lustre/ptlrpc/client.c         | 29 +++++++++++++++++++++--------
 fs/lustre/ptlrpc/events.c         |  3 +++
 fs/lustre/ptlrpc/niobuf.c         |  5 +++++
 5 files changed, 33 insertions(+), 9 deletions(-)

diff --git a/fs/lustre/include/lustre_import.h b/fs/lustre/include/lustre_import.h
index ac46aaef09bf..4789bba8a0b9 100644
--- a/fs/lustre/include/lustre_import.h
+++ b/fs/lustre/include/lustre_import.h
@@ -198,8 +198,10 @@ struct obd_import {
 
 	/** List of not replied requests */
 	struct list_head		imp_unreplied_list;
-	/** Known maximal replied XID */
+	/** XID below which we know all replies have been received */
 	u64				imp_known_replied_xid;
+	/** highest XID for which we have received a reply */
+	u64				imp_highest_replied_xid;
 
 	/** obd device for this import */
 	struct obd_device	       *imp_obd;
diff --git a/fs/lustre/include/obd_support.h b/fs/lustre/include/obd_support.h
index 55196ce8e3f4..ab7899cd1384 100644
--- a/fs/lustre/include/obd_support.h
+++ b/fs/lustre/include/obd_support.h
@@ -369,6 +369,7 @@ extern char obd_jobid_var[];
 #define OBD_FAIL_PTLRPC_CONNECT_RACE			0x531
 #define OBD_FAIL_PTLRPC_IDLE_RACE			0x533
 #define OBD_FAIL_PTLRPC_ENQ_RESEND			0x534
+#define OBD_FAIL_PTLRPC_DELAY_SEND_FAIL			0x535
 
 #define OBD_FAIL_OBD_PING_NET				0x600
 /*	OBD_FAIL_OBD_LOG_CANCEL_NET	0x601 obsolete since 1.5 */
diff --git a/fs/lustre/ptlrpc/client.c b/fs/lustre/ptlrpc/client.c
index 13c27977b14d..7a267e67e45c 100644
--- a/fs/lustre/ptlrpc/client.c
+++ b/fs/lustre/ptlrpc/client.c
@@ -1289,12 +1289,9 @@ static int ptlrpc_import_delay_req(struct obd_import *imp,
  * Return:	false if no message should be printed
  *		true if console message should be printed
  */
-static bool ptlrpc_console_allow(struct ptlrpc_request *req)
+static bool ptlrpc_console_allow(struct ptlrpc_request *req, u32 opc, int err)
 {
-	u32 opc;
-
 	LASSERT(req->rq_reqmsg);
-	opc = lustre_msg_get_opc(req->rq_reqmsg);
 
 	/* Suppress particular reconnect errors which are to be expected. */
 	if (opc == OST_CONNECT || opc == MDS_CONNECT || opc == MGS_CONNECT) {
@@ -1316,6 +1313,15 @@ static bool ptlrpc_console_allow(struct ptlrpc_request *req)
 			return false;
 	}
 
+	if (opc == LDLM_ENQUEUE && err == -EAGAIN)
+		/* -EAGAIN is normal when using POSIX flocks */
+		return false;
+
+	if (opc == OBD_PING && (err == -ENODEV || err == -ENOTCONN) &&
+	    (req->rq_xid & 0xf) != 10)
+		/* Suppress most ping requests, they may fail occasionally */
+		return false;
+
 	return true;
 }
 
@@ -1334,8 +1340,7 @@ static int ptlrpc_check_status(struct ptlrpc_request *req)
 		u32 opc = lustre_msg_get_opc(req->rq_reqmsg);
 
 		/* -EAGAIN is normal when using POSIX flocks */
-		if (ptlrpc_console_allow(req) &&
-		    !(opc == LDLM_ENQUEUE && rc == -EAGAIN))
+		if (ptlrpc_console_allow(req, opc, rc))
 			LCONSOLE_ERROR_MSG(0x011,
 					   "%s: operation %s to node %s failed: rc = %d\n",
 					   imp->imp_obd->obd_name,
@@ -2226,13 +2231,19 @@ EXPORT_SYMBOL(ptlrpc_check_set);
 int ptlrpc_expire_one_request(struct ptlrpc_request *req, int async_unlink)
 {
 	struct obd_import *imp = req->rq_import;
+	unsigned int debug_mask = D_RPCTRACE;
 	int rc = 0;
+	u32 opc;
 
 	spin_lock(&req->rq_lock);
 	req->rq_timedout = 1;
 	spin_unlock(&req->rq_lock);
 
-	DEBUG_REQ(D_WARNING, req, "Request sent has %s: [sent %lld/real %lld]",
+	opc = lustre_msg_get_opc(req->rq_reqmsg);
+	if (ptlrpc_console_allow(req, opc,
+				 lustre_msg_get_status(req->rq_reqmsg)))
+		debug_mask = D_WARNING;
+	DEBUG_REQ(debug_mask, req, "Request sent has %s: [sent %lld/real %lld]",
 		  req->rq_net_err ? "failed due to network error" :
 		     ((req->rq_real_sent == 0 ||
 		       req->rq_real_sent < req->rq_sent ||
@@ -2286,7 +2297,9 @@ int ptlrpc_expire_one_request(struct ptlrpc_request *req, int async_unlink)
 		rc = 1;
 	}
 
-	ptlrpc_fail_import(imp, lustre_msg_get_conn_cnt(req->rq_reqmsg));
+	if (opc != OBD_PING || req->rq_xid > imp->imp_highest_replied_xid)
+		ptlrpc_fail_import(imp,
+				   lustre_msg_get_conn_cnt(req->rq_reqmsg));
 
 	return rc;
 }
diff --git a/fs/lustre/ptlrpc/events.c b/fs/lustre/ptlrpc/events.c
index 17ef775923db..93ff704ac4ec 100644
--- a/fs/lustre/ptlrpc/events.c
+++ b/fs/lustre/ptlrpc/events.c
@@ -171,6 +171,9 @@ void reply_in_callback(struct lnet_event *ev)
 	if (lustre_msg_get_opc(req->rq_reqmsg) != OBD_PING)
 		req->rq_import->imp_last_reply_time = ktime_get_real_seconds();
 
+	if (req->rq_xid > req->rq_import->imp_highest_replied_xid)
+		req->rq_import->imp_highest_replied_xid = req->rq_xid;
+
 out_wake:
 	/* NB don't unlock till after wakeup; req can disappear under us
 	 * since we don't have our own ref
diff --git a/fs/lustre/ptlrpc/niobuf.c b/fs/lustre/ptlrpc/niobuf.c
index 09f68157b883..ccc2caab3876 100644
--- a/fs/lustre/ptlrpc/niobuf.c
+++ b/fs/lustre/ptlrpc/niobuf.c
@@ -725,6 +725,10 @@ int ptl_send_rpc(struct ptlrpc_request *request, int noreply)
 	request->rq_deadline = request->rq_sent + request->rq_timeout +
 			       ptlrpc_at_get_net_latency(request);
 
+	if (unlikely(opc == OBD_PING &&
+	    OBD_FAIL_TIMEOUT(OBD_FAIL_PTLRPC_DELAY_SEND_FAIL, cfs_fail_val)))
+		goto skip_send;
+
 	DEBUG_REQ(D_INFO, request, "send flags=%x",
 		  lustre_msg_get_flags(request->rq_reqmsg));
 	rc = ptl_send_buf(&request->rq_req_md_h,
@@ -737,6 +741,7 @@ int ptl_send_rpc(struct ptlrpc_request *request, int noreply)
 	if (likely(rc == 0))
 		goto out;
 
+skip_send:
 	request->rq_req_unlinked = 1;
 	ptlrpc_req_finished(request);
 	if (noreply)
-- 
2.39.3

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
