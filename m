From: NeilBrown <neilb@suse.com>
Date: Tue, 25 Sep 2018 11:07:15 +1000
Subject: [lustre-devel] [PATCH 13/34] LU-7734 lnet: Primary NID and traffic
 distribution
In-Reply-To: <153783752960.32103.8394391715843917125.stgit@noble>
References: <153783752960.32103.8394391715843917125.stgit@noble>
Message-ID: <153783763535.32103.1496474509485326901.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <amir.shehata@intel.com>

When receiving messages from a multi-rail peer we must keep track of
both the source NID and the primary NID of the peer. When sending a
reply message or RPC respone, the source NID is preferred. But most
other uses require identifcation of the peer regardless of which
source NID the message came from, and so the primary NID of the peer
must then be used.

An example for this is the creation of match entries. Another occurs
when an event is created: the initiator should be the primary NID, to
ensure upper layers (PtlRPC and Lustre) always see the same NID for
that peer.

This change also contains code to have PtlRPC use LNET_NID_ANY for
the 'self' parameter of LNetPut() and LNetGet() when it doesn't care
which NI it sends from, and to provide a local/peer NID pair when it
does. This can be broken out into a separate change.

Signed-off-by: Olaf Weber <olaf@sgi.com>
Signed-off-by: Amir Shehata <amir.shehata@intel.com>
Change-Id: If4391f2537a94f5784e8c61ae03aad266b2f8e7d
Reviewed-on: http://review.whamcloud.com/18938
Tested-by: Maloo <hpdd-maloo@intel.com>
Reviewed-by: Doug Oucharek <doug.s.oucharek@intel.com>
Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../staging/lustre/include/linux/lnet/lib-lnet.h   |    1 
 .../staging/lustre/include/linux/lnet/lib-types.h  |    2 +
 .../lustre/include/uapi/linux/lnet/lnet-types.h    |    4 +-
 drivers/staging/lustre/lnet/lnet/lib-move.c        |   49 ++++++++++++--------
 drivers/staging/lustre/lnet/lnet/lib-msg.c         |   10 +++-
 drivers/staging/lustre/lnet/lnet/lib-ptl.c         |    3 +
 drivers/staging/lustre/lnet/lnet/peer.c            |   18 +++++++
 drivers/staging/lustre/lustre/include/lustre_net.h |    2 +
 drivers/staging/lustre/lustre/ptlrpc/events.c      |    5 ++
 drivers/staging/lustre/lustre/ptlrpc/niobuf.c      |   16 +++----
 10 files changed, 77 insertions(+), 33 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
index c338e31b2cdd..0259cd2251ed 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
@@ -652,6 +652,7 @@ int lnet_find_or_create_peer_locked(lnet_nid_t dst_nid, int cpt,
 int lnet_nid2peerni_locked(struct lnet_peer_ni **lpp, lnet_nid_t nid, int cpt);
 struct lnet_peer_ni *lnet_find_peer_ni_locked(lnet_nid_t nid);
 void lnet_peer_net_added(struct lnet_net *net);
+lnet_nid_t lnet_peer_primary_nid(lnet_nid_t nid);
 void lnet_peer_tables_cleanup(struct lnet_ni *ni);
 void lnet_peer_uninit(void);
 int lnet_peer_tables_create(void);
diff --git a/drivers/staging/lustre/include/linux/lnet/lib-types.h b/drivers/staging/lustre/include/linux/lnet/lib-types.h
index 5083b72ca20f..dbcd9b3da914 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-types.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-types.h
@@ -61,6 +61,8 @@ struct lnet_msg {
 	struct list_head	msg_list;	   /* Q for credits/MD */
 
 	struct lnet_process_id	msg_target;
+	/* Primary NID of the source. */
+	lnet_nid_t		msg_initiator;
 	/* where is it from, it's only for building event */
 	lnet_nid_t		msg_from;
 	__u32			msg_type;
diff --git a/drivers/staging/lustre/include/uapi/linux/lnet/lnet-types.h b/drivers/staging/lustre/include/uapi/linux/lnet/lnet-types.h
index 5770876201c8..e80ef4182e5d 100644
--- a/drivers/staging/lustre/include/uapi/linux/lnet/lnet-types.h
+++ b/drivers/staging/lustre/include/uapi/linux/lnet/lnet-types.h
@@ -563,10 +563,12 @@ struct lnet_event {
 	struct lnet_process_id	target;
 	/** The identifier (nid, pid) of the initiator. */
 	struct lnet_process_id	initiator;
+	/** The source NID on the initiator. */
+	struct lnet_process_id	source;
 	/**
 	 * The NID of the immediate sender. If the request has been forwarded
 	 * by routers, this is the NID of the last hop; otherwise it's the
-	 * same as the initiator.
+	 * same as the source.
 	 */
 	lnet_nid_t		sender;
 	/** Indicates the type of the event. */
diff --git a/drivers/staging/lustre/lnet/lnet/lib-move.c b/drivers/staging/lustre/lnet/lnet/lib-move.c
index bf2256da6122..5153de984ede 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-move.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-move.c
@@ -1189,23 +1189,6 @@ lnet_select_pathway(lnet_nid_t src_nid, lnet_nid_t dst_nid,
 		}
 	}
 
-	if (best_ni == the_lnet.ln_loni) {
-		/* No send credit hassles with LOLND */
-		msg->msg_hdr.dest_nid = cpu_to_le64(best_ni->ni_nid);
-		if (!msg->msg_routing)
-			msg->msg_hdr.src_nid = cpu_to_le64(best_ni->ni_nid);
-		msg->msg_target.nid = best_ni->ni_nid;
-		lnet_msg_commit(msg, cpt);
-
-		lnet_ni_addref_locked(best_ni, cpt);
-		lnet_net_unlock(cpt);
-		msg->msg_txni = best_ni;
-		lnet_ni_send(best_ni, msg);
-
-		*lo_sent = true;
-		return 0;
-	}
-
 	if (best_ni)
 		goto pick_peer;
 
@@ -1389,6 +1372,23 @@ lnet_select_pathway(lnet_nid_t src_nid, lnet_nid_t dst_nid,
 		goto send;
 
 pick_peer:
+	if (best_ni == the_lnet.ln_loni) {
+		/* No send credit hassles with LOLND */
+		lnet_ni_addref_locked(best_ni, cpt);
+		msg->msg_hdr.dest_nid = cpu_to_le64(best_ni->ni_nid);
+		if (!msg->msg_routing)
+			msg->msg_hdr.src_nid = cpu_to_le64(best_ni->ni_nid);
+		msg->msg_target.nid = best_ni->ni_nid;
+		lnet_msg_commit(msg, cpt);
+
+		lnet_net_unlock(cpt);
+		msg->msg_txni = best_ni;
+		lnet_ni_send(best_ni, msg);
+
+		*lo_sent = true;
+		return 0;
+	}
+
 	lpni = NULL;
 
 	if (msg->msg_type == LNET_MSG_REPLY ||
@@ -1674,7 +1674,8 @@ lnet_parse_put(struct lnet_ni *ni, struct lnet_msg *msg)
 	le32_to_cpus(&hdr->msg.put.ptl_index);
 	le32_to_cpus(&hdr->msg.put.offset);
 
-	info.mi_id.nid	= hdr->src_nid;
+	/* Primary peer NID. */
+	info.mi_id.nid	= msg->msg_initiator;
 	info.mi_id.pid	= hdr->src_pid;
 	info.mi_opc	= LNET_MD_OP_PUT;
 	info.mi_portal	= hdr->msg.put.ptl_index;
@@ -1725,6 +1726,7 @@ lnet_parse_get(struct lnet_ni *ni, struct lnet_msg *msg, int rdma_get)
 {
 	struct lnet_match_info info;
 	struct lnet_hdr *hdr = &msg->msg_hdr;
+	struct lnet_process_id source_id;
 	struct lnet_handle_wire reply_wmd;
 	int rc;
 
@@ -1734,7 +1736,10 @@ lnet_parse_get(struct lnet_ni *ni, struct lnet_msg *msg, int rdma_get)
 	le32_to_cpus(&hdr->msg.get.sink_length);
 	le32_to_cpus(&hdr->msg.get.src_offset);
 
-	info.mi_id.nid  = hdr->src_nid;
+	source_id.nid   = hdr->src_nid;
+	source_id.pid   = hdr->src_pid;
+	/* Primary peer NID */
+	info.mi_id.nid  = msg->msg_initiator;
 	info.mi_id.pid  = hdr->src_pid;
 	info.mi_opc     = LNET_MD_OP_GET;
 	info.mi_portal  = hdr->msg.get.ptl_index;
@@ -1756,7 +1761,7 @@ lnet_parse_get(struct lnet_ni *ni, struct lnet_msg *msg, int rdma_get)
 
 	reply_wmd = hdr->msg.get.return_wmd;
 
-	lnet_prep_send(msg, LNET_MSG_REPLY, info.mi_id,
+	lnet_prep_send(msg, LNET_MSG_REPLY, source_id,
 		       msg->msg_offset, msg->msg_wanted);
 
 	msg->msg_hdr.msg.reply.dst_wmd = reply_wmd;
@@ -2200,6 +2205,8 @@ lnet_parse(struct lnet_ni *ni, struct lnet_hdr *hdr, lnet_nid_t from_nid,
 		msg->msg_hdr.dest_pid	= dest_pid;
 		msg->msg_hdr.payload_length = payload_length;
 	}
+	/* Multi-Rail: Primary NID of source. */
+	msg->msg_initiator = lnet_peer_primary_nid(src_nid);
 
 	lnet_net_lock(cpt);
 	rc = lnet_nid2peerni_locked(&msg->msg_rxpeer, from_nid, cpt);
@@ -2518,6 +2525,8 @@ lnet_create_reply_msg(struct lnet_ni *ni, struct lnet_msg *getmsg)
 	       libcfs_nid2str(ni->ni_nid), libcfs_id2str(peer_id), getmd);
 
 	/* setup information for lnet_build_msg_event */
+	msg->msg_initiator = lnet_peer_primary_nid(peer_id.nid);
+	/* Cheaper: msg->msg_initiator = getmsg->msg_txpeer->lp_nid; */
 	msg->msg_from = peer_id.nid;
 	msg->msg_type = LNET_MSG_GET; /* flag this msg as an "optimized" GET */
 	msg->msg_hdr.src_nid = peer_id.nid;
diff --git a/drivers/staging/lustre/lnet/lnet/lib-msg.c b/drivers/staging/lustre/lnet/lnet/lib-msg.c
index 27bdefa161cc..8628899e1631 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-msg.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-msg.c
@@ -70,13 +70,19 @@ lnet_build_msg_event(struct lnet_msg *msg, enum lnet_event_kind ev_type)
 		ev->target.pid    = le32_to_cpu(hdr->dest_pid);
 		ev->initiator.nid = LNET_NID_ANY;
 		ev->initiator.pid = the_lnet.ln_pid;
+		ev->source.nid	  = LNET_NID_ANY;
+		ev->source.pid    = the_lnet.ln_pid;
 		ev->sender        = LNET_NID_ANY;
 	} else {
 		/* event for passive message */
 		ev->target.pid    = hdr->dest_pid;
 		ev->target.nid    = hdr->dest_nid;
 		ev->initiator.pid = hdr->src_pid;
-		ev->initiator.nid = hdr->src_nid;
+		/* Multi-Rail: resolve src_nid to "primary" peer NID */
+		ev->initiator.nid = msg->msg_initiator;
+		/* Multi-Rail: track source NID. */
+		ev->source.pid	  = hdr->src_pid;
+		ev->source.nid	  = hdr->src_nid;
 		ev->rlength       = hdr->payload_length;
 		ev->sender        = msg->msg_from;
 		ev->mlength       = msg->msg_wanted;
@@ -381,7 +387,7 @@ lnet_complete_msg_locked(struct lnet_msg *msg, int cpt)
 
 		ack_wmd = msg->msg_hdr.msg.put.ack_wmd;
 
-		lnet_prep_send(msg, LNET_MSG_ACK, msg->msg_ev.initiator, 0, 0);
+		lnet_prep_send(msg, LNET_MSG_ACK, msg->msg_ev.source, 0, 0);
 
 		msg->msg_hdr.msg.ack.dst_wmd = ack_wmd;
 		msg->msg_hdr.msg.ack.match_bits = msg->msg_ev.match_bits;
diff --git a/drivers/staging/lustre/lnet/lnet/lib-ptl.c b/drivers/staging/lustre/lnet/lnet/lib-ptl.c
index c8d8162cc706..d4033530112e 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-ptl.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-ptl.c
@@ -687,7 +687,8 @@ lnet_ptl_attach_md(struct lnet_me *me, struct lnet_libmd *md,
 		LASSERT(msg->msg_rx_delayed || head == &ptl->ptl_msg_stealing);
 
 		hdr = &msg->msg_hdr;
-		info.mi_id.nid  = hdr->src_nid;
+		/* Multi-Rail: Primary peer NID */
+		info.mi_id.nid  = msg->msg_initiator;
 		info.mi_id.pid  = hdr->src_pid;
 		info.mi_opc     = LNET_MD_OP_PUT;
 		info.mi_portal  = hdr->msg.put.ptl_index;
diff --git a/drivers/staging/lustre/lnet/lnet/peer.c b/drivers/staging/lustre/lnet/lnet/peer.c
index a760e43bcf7e..bde7b6214668 100644
--- a/drivers/staging/lustre/lnet/lnet/peer.c
+++ b/drivers/staging/lustre/lnet/lnet/peer.c
@@ -394,6 +394,24 @@ lnet_peer_is_ni_pref_locked(struct lnet_peer_ni *lpni, struct lnet_ni *ni)
 	return false;
 }
 
+lnet_nid_t
+lnet_peer_primary_nid(lnet_nid_t nid)
+{
+	struct lnet_peer_ni *lpni;
+	lnet_nid_t primary_nid = nid;
+	int cpt;
+
+	cpt = lnet_net_lock_current();
+	lpni = lnet_find_peer_ni_locked(nid);
+	if (lpni) {
+		primary_nid = lpni->lpni_peer_net->lpn_peer->lp_primary_nid;
+		lnet_peer_ni_decref_locked(lpni);
+	}
+	lnet_net_unlock(cpt);
+
+	return primary_nid;
+}
+
 static void
 lnet_try_destroy_peer_hierarchy_locked(struct lnet_peer_ni *lpni)
 {
diff --git a/drivers/staging/lustre/lustre/include/lustre_net.h b/drivers/staging/lustre/lustre/include/lustre_net.h
index 361b8970368e..2dbd20851b39 100644
--- a/drivers/staging/lustre/lustre/include/lustre_net.h
+++ b/drivers/staging/lustre/lustre/include/lustre_net.h
@@ -882,6 +882,8 @@ struct ptlrpc_request {
 	lnet_nid_t	   rq_self;
 	/** Peer description (the other side) */
 	struct lnet_process_id	rq_peer;
+	/** Descriptor for the NID from which the peer sent the request. */
+	struct lnet_process_id	rq_source;
 	/**
 	 * service time estimate (secs)
 	 * If the request is not served by this time, it is marked as timed out.
diff --git a/drivers/staging/lustre/lustre/ptlrpc/events.c b/drivers/staging/lustre/lustre/ptlrpc/events.c
index ebf985ec17a1..ab6dd74d0ae3 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/events.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/events.c
@@ -342,7 +342,9 @@ void request_in_callback(struct lnet_event *ev)
 	if (ev->type == LNET_EVENT_PUT && ev->status == 0)
 		req->rq_reqdata_len = ev->mlength;
 	ktime_get_real_ts64(&req->rq_arrival_time);
+	/* Multi-Rail: keep track of both initiator and source NID. */
 	req->rq_peer = ev->initiator;
+	req->rq_source = ev->source;
 	req->rq_self = ev->target.nid;
 	req->rq_rqbd = rqbd;
 	req->rq_phase = RQ_PHASE_NEW;
@@ -350,7 +352,8 @@ void request_in_callback(struct lnet_event *ev)
 		CDEBUG(D_INFO, "incoming req@%p x%llu msgsize %u\n",
 		       req, req->rq_xid, ev->mlength);
 
-	CDEBUG(D_RPCTRACE, "peer: %s\n", libcfs_id2str(req->rq_peer));
+	CDEBUG(D_RPCTRACE, "peer: %s (source: %s)\n",
+	       libcfs_id2str(req->rq_peer), libcfs_id2str(req->rq_source));
 
 	spin_lock(&svcpt->scp_lock);
 
diff --git a/drivers/staging/lustre/lustre/ptlrpc/niobuf.c b/drivers/staging/lustre/lustre/ptlrpc/niobuf.c
index 2897afb8806c..d0bcd8827f8a 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/niobuf.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/niobuf.c
@@ -47,14 +47,14 @@
  */
 static int ptl_send_buf(struct lnet_handle_md *mdh, void *base, int len,
 			enum lnet_ack_req ack, struct ptlrpc_cb_id *cbid,
-			struct ptlrpc_connection *conn, int portal, __u64 xid,
-			unsigned int offset)
+			lnet_nid_t self, struct lnet_process_id peer_id,
+			int portal, __u64 xid, unsigned int offset)
 {
 	int rc;
 	struct lnet_md md;
 
 	LASSERT(portal != 0);
-	CDEBUG(D_INFO, "conn=%p id %s\n", conn, libcfs_id2str(conn->c_peer));
+	CDEBUG(D_INFO, "peer_id %s\n", libcfs_id2str(peer_id));
 	md.start = base;
 	md.length = len;
 	md.threshold = (ack == LNET_ACK_REQ) ? 2 : 1;
@@ -79,8 +79,8 @@ static int ptl_send_buf(struct lnet_handle_md *mdh, void *base, int len,
 	CDEBUG(D_NET, "Sending %d bytes to portal %d, xid %lld, offset %u\n",
 	       len, portal, xid, offset);
 
-	rc = LNetPut(conn->c_self, *mdh, ack,
-		     conn->c_peer, portal, xid, offset, 0);
+	rc = LNetPut(self, *mdh, ack,
+		     peer_id, portal, xid, offset, 0);
 	if (unlikely(rc != 0)) {
 		int rc2;
 		/* We're going to get an UNLINK event when I unlink below,
@@ -88,7 +88,7 @@ static int ptl_send_buf(struct lnet_handle_md *mdh, void *base, int len,
 		 * I fall through and return success here!
 		 */
 		CERROR("LNetPut(%s, %d, %lld) failed: %d\n",
-		       libcfs_id2str(conn->c_peer), portal, xid, rc);
+		       libcfs_id2str(peer_id), portal, xid, rc);
 		rc2 = LNetMDUnlink(*mdh);
 		LASSERTF(rc2 == 0, "rc2 = %d\n", rc2);
 	}
@@ -415,7 +415,7 @@ int ptlrpc_send_reply(struct ptlrpc_request *req, int flags)
 	rc = ptl_send_buf(&rs->rs_md_h, rs->rs_repbuf, rs->rs_repdata_len,
 			  (rs->rs_difficult && !rs->rs_no_ack) ?
 			  LNET_ACK_REQ : LNET_NOACK_REQ,
-			  &rs->rs_cb_id, conn,
+			  &rs->rs_cb_id, req->rq_self, req->rq_source,
 			  ptlrpc_req2svc(req)->srv_rep_portal,
 			  req->rq_xid, req->rq_reply_off);
 out:
@@ -683,7 +683,7 @@ int ptl_send_rpc(struct ptlrpc_request *request, int noreply)
 	rc = ptl_send_buf(&request->rq_req_md_h,
 			  request->rq_reqbuf, request->rq_reqdata_len,
 			  LNET_NOACK_REQ, &request->rq_req_cbid,
-			  connection,
+			  LNET_NID_ANY, connection->c_peer,
 			  request->rq_request_portal,
 			  request->rq_xid, 0);
 	if (likely(rc == 0))
