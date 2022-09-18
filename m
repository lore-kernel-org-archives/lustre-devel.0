Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 4BA92C6FA90
	for <lustre-devel@archiver.kernel.org>; Sun, 18 Sep 2022 05:22:27 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4MVbm14xCWz1yBX;
	Sat, 17 Sep 2022 22:22:25 -0700 (PDT)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4MVblx5BCSz1wLC
 for <lustre-devel@lists.lustre.org>; Sat, 17 Sep 2022 22:22:21 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id D7B598F02;
 Sun, 18 Sep 2022 01:22:16 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id CDF2027E2; Sun, 18 Sep 2022 01:22:16 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 18 Sep 2022 01:21:54 -0400
Message-Id: <1663478534-19917-5-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1663478534-19917-1-git-send-email-jsimmons@infradead.org>
References: <1663478534-19917-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 04/24] lustre: ptlrpc: change rq_peer to
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

rq_peer in struct ptlrpc_request can now store large NIDs.
ptlrpc_connection_get() and others now take a
struct lnet_processid

WC-bug-id: https://jira.whamcloud.com/browse/LU-10391
Lustre-commit: afb9714c097fc6ec5 ("LU-10391 ptlrpc: change rq_peer to struct lnet_nid")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/44638
Reviewed-by: Frank Sehr <fsehr@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Chris Horn <chris.horn@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_net.h  |  6 +++---
 fs/lustre/ldlm/ldlm_lockd.c     |  6 +++---
 fs/lustre/ldlm/ldlm_request.c   |  2 +-
 fs/lustre/ptlrpc/client.c       |  4 ++--
 fs/lustre/ptlrpc/connection.c   |  5 ++---
 fs/lustre/ptlrpc/events.c       | 14 +++++++-------
 fs/lustre/ptlrpc/lproc_ptlrpc.c |  2 +-
 fs/lustre/ptlrpc/niobuf.c       |  3 ++-
 fs/lustre/ptlrpc/nrs_delay.c    |  2 +-
 fs/lustre/ptlrpc/nrs_fifo.c     |  4 ++--
 fs/lustre/ptlrpc/sec.c          |  2 +-
 fs/lustre/ptlrpc/service.c      | 12 ++++++------
 12 files changed, 31 insertions(+), 31 deletions(-)

diff --git a/fs/lustre/include/lustre_net.h b/fs/lustre/include/lustre_net.h
index d564e28..da90d4f 100644
--- a/fs/lustre/include/lustre_net.h
+++ b/fs/lustre/include/lustre_net.h
@@ -943,7 +943,7 @@ struct ptlrpc_request {
 	/** our LNet NID */
 	struct lnet_nid		rq_self;
 	/** Peer description (the other side) */
-	struct lnet_process_id	rq_peer;
+	struct lnet_processid	rq_peer;
 	/** Descriptor for the NID from which the peer sent the request. */
 	struct lnet_process_id	rq_source;
 	/**
@@ -1706,7 +1706,7 @@ static inline bool nrs_policy_compat_one(const struct ptlrpc_service *svc,
 
 /* ptlrpc/events.c */
 int ptlrpc_uuid_to_peer(struct obd_uuid *uuid,
-			struct lnet_process_id *peer,
+			struct lnet_processid *peer,
 			struct lnet_nid *self,
 			u32 refnet);
 /**
@@ -1722,7 +1722,7 @@ int ptlrpc_uuid_to_peer(struct obd_uuid *uuid,
 /** @} */
 
 /* ptlrpc/connection.c */
-struct ptlrpc_connection *ptlrpc_connection_get(struct lnet_process_id peer,
+struct ptlrpc_connection *ptlrpc_connection_get(struct lnet_processid *peer,
 						struct lnet_nid *self,
 						struct obd_uuid *uuid);
 
diff --git a/fs/lustre/ldlm/ldlm_lockd.c b/fs/lustre/ldlm/ldlm_lockd.c
index 9f89766..0ff4e3a 100644
--- a/fs/lustre/ldlm/ldlm_lockd.c
+++ b/fs/lustre/ldlm/ldlm_lockd.c
@@ -584,9 +584,9 @@ static inline void ldlm_callback_errmsg(struct ptlrpc_request *req,
 					const struct lustre_handle *handle)
 {
 	DEBUG_REQ((req->rq_no_reply || rc) ? D_WARNING : D_DLMTRACE, req,
-		  "%s: [nid %s] [rc %d] [lock %#llx]",
-		  msg, libcfs_id2str(req->rq_peer), rc,
-		  handle ? handle->cookie : 0);
+		  "%s: NID=%s lock=%#llx: rc = %d",
+		  msg, libcfs_idstr(&req->rq_peer),
+		  handle ? handle->cookie : 0, rc);
 	if (req->rq_no_reply)
 		CWARN("No reply was sent, maybe cause bug 21636.\n");
 	else if (rc)
diff --git a/fs/lustre/ldlm/ldlm_request.c b/fs/lustre/ldlm/ldlm_request.c
index f59778e..56ae9b1 100644
--- a/fs/lustre/ldlm/ldlm_request.c
+++ b/fs/lustre/ldlm/ldlm_request.c
@@ -2100,7 +2100,7 @@ static int replay_lock_interpret(const struct lu_env *env,
 		CERROR("received replay ack for unknown local cookie %#llx remote cookie %#llx from server %s id %s\n",
 		       aa->lock_handle.cookie, reply->lock_handle.cookie,
 		       req->rq_export->exp_client_uuid.uuid,
-		       libcfs_id2str(req->rq_peer));
+		       libcfs_idstr(&req->rq_peer));
 		rc = -ESTALE;
 		goto out;
 	}
diff --git a/fs/lustre/ptlrpc/client.c b/fs/lustre/ptlrpc/client.c
index 7ca7d35..069ffdf 100644
--- a/fs/lustre/ptlrpc/client.c
+++ b/fs/lustre/ptlrpc/client.c
@@ -106,7 +106,7 @@ struct ptlrpc_connection *ptlrpc_uuid_to_connection(struct obd_uuid *uuid,
 {
 	struct ptlrpc_connection *c;
 	struct lnet_nid self;
-	struct lnet_process_id peer;
+	struct lnet_processid peer;
 	int err;
 
 	/*
@@ -120,7 +120,7 @@ struct ptlrpc_connection *ptlrpc_uuid_to_connection(struct obd_uuid *uuid,
 		return NULL;
 	}
 
-	c = ptlrpc_connection_get(peer, &self, uuid);
+	c = ptlrpc_connection_get(&peer, &self, uuid);
 	if (c) {
 		memcpy(c->c_remote_uuid.uuid,
 		       uuid->uuid, sizeof(c->c_remote_uuid.uuid));
diff --git a/fs/lustre/ptlrpc/connection.c b/fs/lustre/ptlrpc/connection.c
index 74a1c6a..dad6641 100644
--- a/fs/lustre/ptlrpc/connection.c
+++ b/fs/lustre/ptlrpc/connection.c
@@ -76,13 +76,12 @@ static int lnet_process_id_cmp(struct rhashtable_compare_arg *arg,
 };
 
 struct ptlrpc_connection *
-ptlrpc_connection_get(struct lnet_process_id peer4, struct lnet_nid *self,
+ptlrpc_connection_get(struct lnet_processid *peer_orig, struct lnet_nid *self,
 		      struct obd_uuid *uuid)
 {
 	struct ptlrpc_connection *conn, *conn2;
-	struct lnet_processid peer;
+	struct lnet_processid peer = *peer_orig;
 
-	lnet_pid4_to_pid(peer4, &peer);
 	LNetPrimaryNID(&peer.nid);
 	conn = rhashtable_lookup_fast(&conn_hash, &peer, conn_hash_params);
 	if (conn) {
diff --git a/fs/lustre/ptlrpc/events.c b/fs/lustre/ptlrpc/events.c
index 793c078..6b6fd97 100644
--- a/fs/lustre/ptlrpc/events.c
+++ b/fs/lustre/ptlrpc/events.c
@@ -346,7 +346,7 @@ void request_in_callback(struct lnet_event *ev)
 		req->rq_reqdata_len = ev->mlength;
 	ktime_get_real_ts64(&req->rq_arrival_time);
 	/* Multi-Rail: keep track of both initiator and source NID. */
-	req->rq_peer = lnet_pid_to_pid4(&ev->initiator);
+	req->rq_peer = ev->initiator;
 	req->rq_source = lnet_pid_to_pid4(&ev->source);
 	req->rq_self = ev->target.nid;
 	req->rq_rqbd = rqbd;
@@ -356,7 +356,7 @@ void request_in_callback(struct lnet_event *ev)
 		       req, req->rq_xid, ev->mlength);
 
 	CDEBUG(D_RPCTRACE, "peer: %s (source: %s)\n",
-	       libcfs_id2str(req->rq_peer), libcfs_id2str(req->rq_source));
+	       libcfs_idstr(&req->rq_peer), libcfs_id2str(req->rq_source));
 
 	spin_lock(&svcpt->scp_lock);
 
@@ -468,7 +468,7 @@ static void ptlrpc_master_callback(struct lnet_event *ev)
 }
 
 int ptlrpc_uuid_to_peer(struct obd_uuid *uuid,
-			struct lnet_process_id *peer,
+			struct lnet_processid *peer,
 			struct lnet_nid *self,
 			u32 refnet)
 {
@@ -494,8 +494,8 @@ int ptlrpc_uuid_to_peer(struct obd_uuid *uuid,
 			continue;
 
 		if (dist == 0) {		/* local! use loopback LND */
-			peer->nid = LNET_NID_LO_0;
-			lnet_nid4_to_nid(peer->nid, self);
+			lnet_nid4_to_nid(LNET_NID_LO_0, self);
+			peer->nid = *self;
 			rc = 0;
 			break;
 		}
@@ -506,13 +506,13 @@ int ptlrpc_uuid_to_peer(struct obd_uuid *uuid,
 			best_dist = dist;
 			best_order = order;
 
-			peer->nid = lnet_nid_to_nid4(&dst_nid);
+			peer->nid = dst_nid;
 			*self = src_nid;
 			rc = 0;
 		}
 	}
 
-	CDEBUG(D_NET, "%s->%s\n", uuid->uuid, libcfs_id2str(*peer));
+	CDEBUG(D_NET, "%s->%s\n", uuid->uuid, libcfs_idstr(peer));
 	return rc;
 }
 
diff --git a/fs/lustre/ptlrpc/lproc_ptlrpc.c b/fs/lustre/ptlrpc/lproc_ptlrpc.c
index bb17a69..603259d 100644
--- a/fs/lustre/ptlrpc/lproc_ptlrpc.c
+++ b/fs/lustre/ptlrpc/lproc_ptlrpc.c
@@ -1009,7 +1009,7 @@ static int ptlrpc_lprocfs_svc_req_history_show(struct seq_file *s, void *iter)
 				req->rq_export->exp_obd->obd_name :
 				libcfs_nidstr_r(&req->rq_self, nidstr,
 						sizeof(nidstr)),
-			   libcfs_id2str(req->rq_peer), req->rq_xid,
+			   libcfs_idstr(&req->rq_peer), req->rq_xid,
 			   req->rq_reqlen, ptlrpc_rqphase2str(req),
 			   (s64)req->rq_arrival_time.tv_sec,
 			   (s64)req->rq_arrival_time.tv_nsec / NSEC_PER_USEC,
diff --git a/fs/lustre/ptlrpc/niobuf.c b/fs/lustre/ptlrpc/niobuf.c
index 3a10411..099f105 100644
--- a/fs/lustre/ptlrpc/niobuf.c
+++ b/fs/lustre/ptlrpc/niobuf.c
@@ -416,7 +416,8 @@ int ptlrpc_send_reply(struct ptlrpc_request *req, int flags)
 	ptlrpc_at_set_reply(req, flags);
 
 	if (!req->rq_export || !req->rq_export->exp_connection)
-		conn = ptlrpc_connection_get(req->rq_peer, &req->rq_self, NULL);
+		conn = ptlrpc_connection_get(&req->rq_peer, &req->rq_self,
+					     NULL);
 	else
 		conn = ptlrpc_connection_addref(req->rq_export->exp_connection);
 
diff --git a/fs/lustre/ptlrpc/nrs_delay.c b/fs/lustre/ptlrpc/nrs_delay.c
index 5b4c2a9..127f00c 100644
--- a/fs/lustre/ptlrpc/nrs_delay.c
+++ b/fs/lustre/ptlrpc/nrs_delay.c
@@ -296,7 +296,7 @@ static void nrs_delay_req_stop(struct ptlrpc_nrs_policy *policy,
 
 	DEBUG_REQ(D_RPCTRACE, req,
 		  "NRS: finished delayed request from %s after %llds",
-		  libcfs_id2str(req->rq_peer),
+		  libcfs_idstr(&req->rq_peer),
 		  (s64)(nrq->nr_u.delay.req_start_time -
 			req->rq_srv.sr_arrival_time.tv_sec));
 }
diff --git a/fs/lustre/ptlrpc/nrs_fifo.c b/fs/lustre/ptlrpc/nrs_fifo.c
index d0eaebc..1689616 100644
--- a/fs/lustre/ptlrpc/nrs_fifo.c
+++ b/fs/lustre/ptlrpc/nrs_fifo.c
@@ -175,7 +175,7 @@ struct ptlrpc_nrs_request *nrs_fifo_req_get(struct ptlrpc_nrs_policy *policy,
 		list_del_init(&nrq->nr_u.fifo.fr_list);
 
 		CDEBUG(D_RPCTRACE, "NRS start %s request from %s, seq: %llu\n",
-		       policy->pol_desc->pd_name, libcfs_id2str(req->rq_peer),
+		       policy->pol_desc->pd_name, libcfs_idstr(&req->rq_peer),
 		       nrq->nr_u.fifo.fr_sequence);
 	}
 
@@ -237,7 +237,7 @@ static void nrs_fifo_req_stop(struct ptlrpc_nrs_policy *policy,
 						  rq_nrq);
 
 	CDEBUG(D_RPCTRACE, "NRS stop %s request from %s, seq: %llu\n",
-	       policy->pol_desc->pd_name, libcfs_id2str(req->rq_peer),
+	       policy->pol_desc->pd_name, libcfs_idstr(&req->rq_peer),
 	       nrq->nr_u.fifo.fr_sequence);
 }
 
diff --git a/fs/lustre/ptlrpc/sec.c b/fs/lustre/ptlrpc/sec.c
index f2d0340..976df0b 100644
--- a/fs/lustre/ptlrpc/sec.c
+++ b/fs/lustre/ptlrpc/sec.c
@@ -2097,7 +2097,7 @@ int sptlrpc_svc_unwrap_request(struct ptlrpc_request *req)
 		break;
 	default:
 		CERROR("error unpacking request from %s x%llu\n",
-		       libcfs_id2str(req->rq_peer), req->rq_xid);
+		       libcfs_idstr(&req->rq_peer), req->rq_xid);
 		return SECSVC_DROP;
 	}
 
diff --git a/fs/lustre/ptlrpc/service.c b/fs/lustre/ptlrpc/service.c
index 7db6f52..277fbdb 100644
--- a/fs/lustre/ptlrpc/service.c
+++ b/fs/lustre/ptlrpc/service.c
@@ -1595,7 +1595,7 @@ static int ptlrpc_server_handle_req_in(struct ptlrpc_service_part *svcpt,
 		rc = ptlrpc_unpack_req_msg(req, req->rq_reqlen);
 		if (rc != 0) {
 			CERROR("error unpacking request: ptl %d from %s x%llu\n",
-			       svc->srv_req_portal, libcfs_id2str(req->rq_peer),
+			       svc->srv_req_portal, libcfs_idstr(&req->rq_peer),
 			       req->rq_xid);
 			goto err_req;
 		}
@@ -1604,7 +1604,7 @@ static int ptlrpc_server_handle_req_in(struct ptlrpc_service_part *svcpt,
 	rc = lustre_unpack_req_ptlrpc_body(req, MSG_PTLRPC_BODY_OFF);
 	if (rc) {
 		CERROR("error unpacking ptlrpc body: ptl %d from %s x %llu\n",
-		       svc->srv_req_portal, libcfs_id2str(req->rq_peer),
+		       svc->srv_req_portal, libcfs_idstr(&req->rq_peer),
 		       req->rq_xid);
 		goto err_req;
 	}
@@ -1621,7 +1621,7 @@ static int ptlrpc_server_handle_req_in(struct ptlrpc_service_part *svcpt,
 	if (lustre_msg_get_type(req->rq_reqmsg) != PTL_RPC_MSG_REQUEST) {
 		CERROR("wrong packet type received (type=%u) from %s\n",
 		       lustre_msg_get_type(req->rq_reqmsg),
-		       libcfs_id2str(req->rq_peer));
+		       libcfs_idstr(&req->rq_peer));
 		goto err_req;
 	}
 
@@ -1779,7 +1779,7 @@ static int ptlrpc_server_handle_request(struct ptlrpc_service_part *svcpt,
 	if (ktime_get_real_seconds() > request->rq_deadline) {
 		DEBUG_REQ(D_ERROR, request,
 			  "Dropping timed-out request from %s: deadline %lld/%llds ago",
-			  libcfs_id2str(request->rq_peer),
+			  libcfs_idstr(&request->rq_peer),
 			  request->rq_deadline -
 			  request->rq_arrival_time.tv_sec,
 			  ktime_get_real_seconds() - request->rq_deadline);
@@ -1794,7 +1794,7 @@ static int ptlrpc_server_handle_request(struct ptlrpc_service_part *svcpt,
 	       (request->rq_export ?
 		refcount_read(&request->rq_export->exp_handle.h_ref) : -99),
 	       lustre_msg_get_status(request->rq_reqmsg), request->rq_xid,
-	       libcfs_id2str(request->rq_peer),
+	       libcfs_idstr(&request->rq_peer),
 	       lustre_msg_get_opc(request->rq_reqmsg),
 	       lustre_msg_get_jobid(request->rq_reqmsg) ?: "");
 
@@ -1836,7 +1836,7 @@ static int ptlrpc_server_handle_request(struct ptlrpc_service_part *svcpt,
 		refcount_read(&request->rq_export->exp_handle.h_ref) : -99),
 	       lustre_msg_get_status(request->rq_reqmsg),
 	       request->rq_xid,
-	       libcfs_id2str(request->rq_peer),
+	       libcfs_idstr(&request->rq_peer),
 	       lustre_msg_get_opc(request->rq_reqmsg),
 	       lustre_msg_get_jobid(request->rq_reqmsg) ?: "",
 	       timediff_usecs,
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
