Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 7A6CCC6FA8B
	for <lustre-devel@archiver.kernel.org>; Sun, 18 Sep 2022 05:22:43 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4MVbmK5RPtz1yFN;
	Sat, 17 Sep 2022 22:22:41 -0700 (PDT)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4MVbm127sxz1y7v
 for <lustre-devel@lists.lustre.org>; Sat, 17 Sep 2022 22:22:25 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id E15618F08;
 Sun, 18 Sep 2022 01:22:16 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id D9B6DE8BA5; Sun, 18 Sep 2022 01:22:16 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 18 Sep 2022 01:21:57 -0400
Message-Id: <1663478534-19917-8-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1663478534-19917-1-git-send-email-jsimmons@infradead.org>
References: <1663478534-19917-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 07/24] lustre: ptlrpc: pass lnet_nid for self
 to ptl_send_buf()
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

The 'self' arg to ptl_send_buf() is now a pointer to a
'struct lnet_nid', and can be NULL meaning "ANY NID".

LNetPut() already accepts NULL as the self pointer.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10391
Lustre-commit: 3f7e728d91dd9f113 ("LU-10391 ptlrpc: pass lnet_nid for self to ptl_send_buf()")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/44641
Reviewed-by: Frank Sehr <fsehr@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Chris Horn <chris.horn@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ptlrpc/niobuf.c | 11 ++++-------
 1 file changed, 4 insertions(+), 7 deletions(-)

diff --git a/fs/lustre/ptlrpc/niobuf.c b/fs/lustre/ptlrpc/niobuf.c
index 8f19e92..670bfb0 100644
--- a/fs/lustre/ptlrpc/niobuf.c
+++ b/fs/lustre/ptlrpc/niobuf.c
@@ -46,15 +46,12 @@
  */
 static int ptl_send_buf(struct lnet_handle_md *mdh, void *base, int len,
 			enum lnet_ack_req ack, struct ptlrpc_cb_id *cbid,
-			lnet_nid_t self4, struct lnet_processid *peer_id,
+			struct lnet_nid *self, struct lnet_processid *peer_id,
 			int portal, u64 xid, unsigned int offset,
 			struct lnet_handle_md *bulk_cookie)
 {
 	int rc;
 	struct lnet_md md;
-	struct lnet_nid self;
-
-	lnet_nid4_to_nid(self4, &self);
 
 	LASSERT(portal != 0);
 	CDEBUG(D_INFO, "peer_id %s\n", libcfs_idstr(peer_id));
@@ -88,7 +85,7 @@ static int ptl_send_buf(struct lnet_handle_md *mdh, void *base, int len,
 
 	percpu_ref_get(&ptlrpc_pending);
 
-	rc = LNetPut(&self, *mdh, ack,
+	rc = LNetPut(self, *mdh, ack,
 		     peer_id, portal, xid, offset, 0);
 	if (unlikely(rc != 0)) {
 		int rc2;
@@ -434,7 +431,7 @@ int ptlrpc_send_reply(struct ptlrpc_request *req, int flags)
 	rc = ptl_send_buf(&rs->rs_md_h, rs->rs_repbuf, rs->rs_repdata_len,
 			  (rs->rs_difficult && !rs->rs_no_ack) ?
 			  LNET_ACK_REQ : LNET_NOACK_REQ,
-			  &rs->rs_cb_id, lnet_nid_to_nid4(&req->rq_self),
+			  &rs->rs_cb_id, &req->rq_self,
 			  &req->rq_source,
 			  ptlrpc_req2svc(req)->srv_rep_portal,
 			  req->rq_rep_mbits ? req->rq_rep_mbits : req->rq_xid,
@@ -726,7 +723,7 @@ int ptl_send_rpc(struct ptlrpc_request *request, int noreply)
 	rc = ptl_send_buf(&request->rq_req_md_h,
 			  request->rq_reqbuf, request->rq_reqdata_len,
 			  LNET_NOACK_REQ, &request->rq_req_cbid,
-			  LNET_NID_ANY,
+			  NULL,
 			  &connection->c_peer,
 			  request->rq_request_portal,
 			  request->rq_xid, 0, &bulk_cookie);
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
