Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 074F8C32771
	for <lustre-devel@archiver.kernel.org>; Sun, 18 Sep 2022 05:22:26 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4MVbm13GvZz1y81;
	Sat, 17 Sep 2022 22:22:25 -0700 (PDT)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4MVblw1DHFz1wLC
 for <lustre-devel@lists.lustre.org>; Sat, 17 Sep 2022 22:22:20 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id D3F828AB4;
 Sun, 18 Sep 2022 01:22:16 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id C5C16E8B93; Sun, 18 Sep 2022 01:22:16 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 18 Sep 2022 01:21:52 -0400
Message-Id: <1663478534-19917-3-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1663478534-19917-1-git-send-email-jsimmons@infradead.org>
References: <1663478534-19917-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 02/24] lustre: ptlrpc: change rq_self to
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

rq_self in struct ptlrpc_request can now store largs NIDs.
ptlrpc_connection_get() is also changed to received a
'struct lnet_nid'.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10391
Lustre-commit: 37ba07f338293d249 ("LU-10391 ptlrpc: change rq_self to struct lnet_nid")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/44636
Reviewed-by: Frank Sehr <fsehr@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Chris Horn <chris.horn@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_net.h  |  7 ++++---
 fs/lustre/ptlrpc/client.c       |  4 ++--
 fs/lustre/ptlrpc/connection.c   |  4 ++--
 fs/lustre/ptlrpc/events.c       | 10 ++++++----
 fs/lustre/ptlrpc/lproc_ptlrpc.c |  4 ++--
 fs/lustre/ptlrpc/niobuf.c       |  5 +++--
 6 files changed, 19 insertions(+), 15 deletions(-)

diff --git a/fs/lustre/include/lustre_net.h b/fs/lustre/include/lustre_net.h
index f70cc7c..3a35b03 100644
--- a/fs/lustre/include/lustre_net.h
+++ b/fs/lustre/include/lustre_net.h
@@ -941,7 +941,7 @@ struct ptlrpc_request {
 	/** import where request is being sent */
 	struct obd_import	*rq_import;
 	/** our LNet NID */
-	lnet_nid_t		rq_self;
+	struct lnet_nid		rq_self;
 	/** Peer description (the other side) */
 	struct lnet_process_id	rq_peer;
 	/** Descriptor for the NID from which the peer sent the request. */
@@ -1706,7 +1706,8 @@ static inline bool nrs_policy_compat_one(const struct ptlrpc_service *svc,
 
 /* ptlrpc/events.c */
 int ptlrpc_uuid_to_peer(struct obd_uuid *uuid,
-			struct lnet_process_id *peer, lnet_nid_t *self);
+			struct lnet_process_id *peer,
+			struct lnet_nid *self);
 /**
  * These callbacks are invoked by LNet when something happened to
  * underlying buffer
@@ -1721,7 +1722,7 @@ int ptlrpc_uuid_to_peer(struct obd_uuid *uuid,
 
 /* ptlrpc/connection.c */
 struct ptlrpc_connection *ptlrpc_connection_get(struct lnet_process_id peer,
-						lnet_nid_t self,
+						struct lnet_nid *self,
 						struct obd_uuid *uuid);
 
 static inline void  ptlrpc_connection_put(struct ptlrpc_connection *conn)
diff --git a/fs/lustre/ptlrpc/client.c b/fs/lustre/ptlrpc/client.c
index 685d6e2..7a4a9c9 100644
--- a/fs/lustre/ptlrpc/client.c
+++ b/fs/lustre/ptlrpc/client.c
@@ -105,7 +105,7 @@ struct ptlrpc_connection *ptlrpc_uuid_to_connection(struct obd_uuid *uuid,
 						    lnet_nid_t nid4refnet)
 {
 	struct ptlrpc_connection *c;
-	lnet_nid_t self;
+	struct lnet_nid self;
 	struct lnet_process_id peer;
 	int err;
 
@@ -121,7 +121,7 @@ struct ptlrpc_connection *ptlrpc_uuid_to_connection(struct obd_uuid *uuid,
 		return NULL;
 	}
 
-	c = ptlrpc_connection_get(peer, self, uuid);
+	c = ptlrpc_connection_get(peer, &self, uuid);
 	if (c) {
 		memcpy(c->c_remote_uuid.uuid,
 		       uuid->uuid, sizeof(c->c_remote_uuid.uuid));
diff --git a/fs/lustre/ptlrpc/connection.c b/fs/lustre/ptlrpc/connection.c
index 58161fe..74a1c6a 100644
--- a/fs/lustre/ptlrpc/connection.c
+++ b/fs/lustre/ptlrpc/connection.c
@@ -76,7 +76,7 @@ static int lnet_process_id_cmp(struct rhashtable_compare_arg *arg,
 };
 
 struct ptlrpc_connection *
-ptlrpc_connection_get(struct lnet_process_id peer4, lnet_nid_t self,
+ptlrpc_connection_get(struct lnet_process_id peer4, struct lnet_nid *self,
 		      struct obd_uuid *uuid)
 {
 	struct ptlrpc_connection *conn, *conn2;
@@ -95,7 +95,7 @@ struct ptlrpc_connection *
 		return NULL;
 
 	conn->c_peer = peer;
-	lnet_nid4_to_nid(self, &conn->c_self);
+	conn->c_self = *self;
 	atomic_set(&conn->c_refcount, 1);
 	if (uuid)
 		obd_str2uuid(&conn->c_remote_uuid, uuid->uuid);
diff --git a/fs/lustre/ptlrpc/events.c b/fs/lustre/ptlrpc/events.c
index 140ea85..231eace 100644
--- a/fs/lustre/ptlrpc/events.c
+++ b/fs/lustre/ptlrpc/events.c
@@ -348,7 +348,7 @@ void request_in_callback(struct lnet_event *ev)
 	/* Multi-Rail: keep track of both initiator and source NID. */
 	req->rq_peer = lnet_pid_to_pid4(&ev->initiator);
 	req->rq_source = lnet_pid_to_pid4(&ev->source);
-	req->rq_self = lnet_nid_to_nid4(&ev->target.nid);
+	req->rq_self = ev->target.nid;
 	req->rq_rqbd = rqbd;
 	req->rq_phase = RQ_PHASE_NEW;
 	if (ev->type == LNET_EVENT_PUT)
@@ -468,7 +468,8 @@ static void ptlrpc_master_callback(struct lnet_event *ev)
 }
 
 int ptlrpc_uuid_to_peer(struct obd_uuid *uuid,
-			struct lnet_process_id *peer, lnet_nid_t *self)
+			struct lnet_process_id *peer,
+			struct lnet_nid *self)
 {
 	int best_dist = 0;
 	u32 best_order = 0;
@@ -492,7 +493,8 @@ int ptlrpc_uuid_to_peer(struct obd_uuid *uuid,
 			continue;
 
 		if (dist == 0) {		/* local! use loopback LND */
-			peer->nid = *self = LNET_NID_LO_0;
+			peer->nid = LNET_NID_LO_0;
+			lnet_nid4_to_nid(peer->nid, self);
 			rc = 0;
 			break;
 		}
@@ -504,7 +506,7 @@ int ptlrpc_uuid_to_peer(struct obd_uuid *uuid,
 			best_order = order;
 
 			peer->nid = lnet_nid_to_nid4(&dst_nid);
-			*self = lnet_nid_to_nid4(&src_nid);
+			*self = src_nid;
 			rc = 0;
 		}
 	}
diff --git a/fs/lustre/ptlrpc/lproc_ptlrpc.c b/fs/lustre/ptlrpc/lproc_ptlrpc.c
index 52010cb..bb17a69 100644
--- a/fs/lustre/ptlrpc/lproc_ptlrpc.c
+++ b/fs/lustre/ptlrpc/lproc_ptlrpc.c
@@ -1007,8 +1007,8 @@ static int ptlrpc_lprocfs_svc_req_history_show(struct seq_file *s, void *iter)
 			   req->rq_history_seq,
 			   req->rq_export && req->rq_export->exp_obd ?
 				req->rq_export->exp_obd->obd_name :
-				libcfs_nid2str_r(req->rq_self, nidstr,
-						 sizeof(nidstr)),
+				libcfs_nidstr_r(&req->rq_self, nidstr,
+						sizeof(nidstr)),
 			   libcfs_id2str(req->rq_peer), req->rq_xid,
 			   req->rq_reqlen, ptlrpc_rqphase2str(req),
 			   (s64)req->rq_arrival_time.tv_sec,
diff --git a/fs/lustre/ptlrpc/niobuf.c b/fs/lustre/ptlrpc/niobuf.c
index be1811a..3a10411 100644
--- a/fs/lustre/ptlrpc/niobuf.c
+++ b/fs/lustre/ptlrpc/niobuf.c
@@ -416,7 +416,7 @@ int ptlrpc_send_reply(struct ptlrpc_request *req, int flags)
 	ptlrpc_at_set_reply(req, flags);
 
 	if (!req->rq_export || !req->rq_export->exp_connection)
-		conn = ptlrpc_connection_get(req->rq_peer, req->rq_self, NULL);
+		conn = ptlrpc_connection_get(req->rq_peer, &req->rq_self, NULL);
 	else
 		conn = ptlrpc_connection_addref(req->rq_export->exp_connection);
 
@@ -435,7 +435,8 @@ int ptlrpc_send_reply(struct ptlrpc_request *req, int flags)
 	rc = ptl_send_buf(&rs->rs_md_h, rs->rs_repbuf, rs->rs_repdata_len,
 			  (rs->rs_difficult && !rs->rs_no_ack) ?
 			  LNET_ACK_REQ : LNET_NOACK_REQ,
-			  &rs->rs_cb_id, req->rq_self, req->rq_source,
+			  &rs->rs_cb_id, lnet_nid_to_nid4(&req->rq_self),
+			  req->rq_source,
 			  ptlrpc_req2svc(req)->srv_rep_portal,
 			  req->rq_rep_mbits ? req->rq_rep_mbits : req->rq_xid,
 			  req->rq_reply_off, NULL);
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
