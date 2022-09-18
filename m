Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 476DCC6FA86
	for <lustre-devel@archiver.kernel.org>; Sun, 18 Sep 2022 05:22:36 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4MVbm951yTz1yDm;
	Sat, 17 Sep 2022 22:22:33 -0700 (PDT)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4MVbly3Lbpz1y6l
 for <lustre-devel@lists.lustre.org>; Sat, 17 Sep 2022 22:22:22 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id DB6298F03;
 Sun, 18 Sep 2022 01:22:16 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id D338027E5; Sun, 18 Sep 2022 01:22:16 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 18 Sep 2022 01:21:55 -0400
Message-Id: <1663478534-19917-6-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1663478534-19917-1-git-send-email-jsimmons@infradead.org>
References: <1663478534-19917-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 05/24] lustre: ptlrpc: change rq_source to
 struct lnet_nid
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

From: Mr NeilBrown <neilb@suse.de>

rq_source in struct ptlrpc_request can now store large NIDs.
ptl_send_buf() now takes a struct lnet_processid for the peer.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10391
Lustre-commit: 1c250cbfa127a1517 ("LU-10391 ptlrpc: change rq_source to struct lnet_nid")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/44639
Reviewed-by: Frank Sehr <fsehr@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Chris Horn <chris.horn@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_net.h |  2 +-
 fs/lustre/ptlrpc/events.c      |  4 ++--
 fs/lustre/ptlrpc/niobuf.c      | 14 ++++++--------
 3 files changed, 9 insertions(+), 11 deletions(-)

diff --git a/fs/lustre/include/lustre_net.h b/fs/lustre/include/lustre_net.h
index da90d4f..d9aa530 100644
--- a/fs/lustre/include/lustre_net.h
+++ b/fs/lustre/include/lustre_net.h
@@ -945,7 +945,7 @@ struct ptlrpc_request {
 	/** Peer description (the other side) */
 	struct lnet_processid	rq_peer;
 	/** Descriptor for the NID from which the peer sent the request. */
-	struct lnet_process_id	rq_source;
+	struct lnet_processid	rq_source;
 	/**
 	 * service time estimate (secs)
 	 * If the request is not served by this time, it is marked as timed out.
diff --git a/fs/lustre/ptlrpc/events.c b/fs/lustre/ptlrpc/events.c
index 6b6fd97..e6313af 100644
--- a/fs/lustre/ptlrpc/events.c
+++ b/fs/lustre/ptlrpc/events.c
@@ -347,7 +347,7 @@ void request_in_callback(struct lnet_event *ev)
 	ktime_get_real_ts64(&req->rq_arrival_time);
 	/* Multi-Rail: keep track of both initiator and source NID. */
 	req->rq_peer = ev->initiator;
-	req->rq_source = lnet_pid_to_pid4(&ev->source);
+	req->rq_source = ev->source;
 	req->rq_self = ev->target.nid;
 	req->rq_rqbd = rqbd;
 	req->rq_phase = RQ_PHASE_NEW;
@@ -356,7 +356,7 @@ void request_in_callback(struct lnet_event *ev)
 		       req, req->rq_xid, ev->mlength);
 
 	CDEBUG(D_RPCTRACE, "peer: %s (source: %s)\n",
-	       libcfs_idstr(&req->rq_peer), libcfs_id2str(req->rq_source));
+	       libcfs_idstr(&req->rq_peer), libcfs_idstr(&req->rq_source));
 
 	spin_lock(&svcpt->scp_lock);
 
diff --git a/fs/lustre/ptlrpc/niobuf.c b/fs/lustre/ptlrpc/niobuf.c
index 099f105..8f19e92 100644
--- a/fs/lustre/ptlrpc/niobuf.c
+++ b/fs/lustre/ptlrpc/niobuf.c
@@ -46,20 +46,18 @@
  */
 static int ptl_send_buf(struct lnet_handle_md *mdh, void *base, int len,
 			enum lnet_ack_req ack, struct ptlrpc_cb_id *cbid,
-			lnet_nid_t self4, struct lnet_process_id peer_id4,
+			lnet_nid_t self4, struct lnet_processid *peer_id,
 			int portal, u64 xid, unsigned int offset,
 			struct lnet_handle_md *bulk_cookie)
 {
 	int rc;
 	struct lnet_md md;
 	struct lnet_nid self;
-	struct lnet_processid peer_id;
 
 	lnet_nid4_to_nid(self4, &self);
-	lnet_pid4_to_pid(peer_id4, &peer_id);
 
 	LASSERT(portal != 0);
-	CDEBUG(D_INFO, "peer_id %s\n", libcfs_id2str(peer_id4));
+	CDEBUG(D_INFO, "peer_id %s\n", libcfs_idstr(peer_id));
 	md.start = base;
 	md.length = len;
 	md.threshold = (ack == LNET_ACK_REQ) ? 2 : 1;
@@ -91,7 +89,7 @@ static int ptl_send_buf(struct lnet_handle_md *mdh, void *base, int len,
 	percpu_ref_get(&ptlrpc_pending);
 
 	rc = LNetPut(&self, *mdh, ack,
-		     &peer_id, portal, xid, offset, 0);
+		     peer_id, portal, xid, offset, 0);
 	if (unlikely(rc != 0)) {
 		int rc2;
 		/* We're going to get an UNLINK event when I unlink below,
@@ -99,7 +97,7 @@ static int ptl_send_buf(struct lnet_handle_md *mdh, void *base, int len,
 		 * I fall through and return success here!
 		 */
 		CERROR("LNetPut(%s, %d, %lld) failed: %d\n",
-		       libcfs_id2str(peer_id4), portal, xid, rc);
+		       libcfs_idstr(peer_id), portal, xid, rc);
 		rc2 = LNetMDUnlink(*mdh);
 		LASSERTF(rc2 == 0, "rc2 = %d\n", rc2);
 	}
@@ -437,7 +435,7 @@ int ptlrpc_send_reply(struct ptlrpc_request *req, int flags)
 			  (rs->rs_difficult && !rs->rs_no_ack) ?
 			  LNET_ACK_REQ : LNET_NOACK_REQ,
 			  &rs->rs_cb_id, lnet_nid_to_nid4(&req->rq_self),
-			  req->rq_source,
+			  &req->rq_source,
 			  ptlrpc_req2svc(req)->srv_rep_portal,
 			  req->rq_rep_mbits ? req->rq_rep_mbits : req->rq_xid,
 			  req->rq_reply_off, NULL);
@@ -729,7 +727,7 @@ int ptl_send_rpc(struct ptlrpc_request *request, int noreply)
 			  request->rq_reqbuf, request->rq_reqdata_len,
 			  LNET_NOACK_REQ, &request->rq_req_cbid,
 			  LNET_NID_ANY,
-			  lnet_pid_to_pid4(&connection->c_peer),
+			  &connection->c_peer,
 			  request->rq_request_portal,
 			  request->rq_xid, 0, &bulk_cookie);
 	if (likely(rc == 0))
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
