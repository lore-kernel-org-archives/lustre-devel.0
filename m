Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 6B2D9C433F5
	for <lustre-devel@archiver.kernel.org>; Sun, 20 Mar 2022 13:31:17 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id E8F1A21E0C3;
	Sun, 20 Mar 2022 06:31:14 -0700 (PDT)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 1B18121CA7D
 for <lustre-devel@lists.lustre.org>; Sun, 20 Mar 2022 06:31:10 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id EBBFCED5;
 Sun, 20 Mar 2022 09:31:07 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id DDFBBE421B; Sun, 20 Mar 2022 09:31:07 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 20 Mar 2022 09:30:17 -0400
Message-Id: <1647783064-20688-4-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1647783064-20688-1-git-send-email-jsimmons@infradead.org>
References: <1647783064-20688-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 03/50] lnet: extend nids in struct lnet_msg
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
Cc: Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Mr NeilBrown <neilb@suse.de>

struct lnet_msg contains 3 nids and one process_id (which itself
contains a nid.  Replace each of these with the 'struct lnet_nid'
version.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10391
Lustre-commit: 57c03f3070753146a ("LU-10391 lnet: extend nids in struct lnet_msg")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/43598
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Alexey Lyashkov <alexey.lyashkov@hpe.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/lib-lnet.h       |  2 +-
 include/linux/lnet/lib-types.h      | 10 +++---
 net/lnet/klnds/o2iblnd/o2iblnd_cb.c | 29 ++++++++--------
 net/lnet/klnds/socklnd/socklnd_cb.c |  8 ++---
 net/lnet/lnet/lib-move.c            | 68 +++++++++++++++++++------------------
 net/lnet/lnet/lib-msg.c             | 21 ++++++------
 net/lnet/lnet/lib-ptl.c             |  2 +-
 net/lnet/lnet/peer.c                | 24 ++++++-------
 8 files changed, 81 insertions(+), 83 deletions(-)

diff --git a/include/linux/lnet/lib-lnet.h b/include/linux/lnet/lib-lnet.h
index 02eae6b..29a6252 100644
--- a/include/linux/lnet/lib-lnet.h
+++ b/include/linux/lnet/lib-lnet.h
@@ -853,7 +853,7 @@ struct lnet_peer_ni *lnet_peer_ni_get_locked(struct lnet_peer *lp,
 struct lnet_peer_ni *lnet_peer_ni_find_locked(struct lnet_nid *nid);
 struct lnet_peer *lnet_find_peer(lnet_nid_t nid);
 void lnet_peer_net_added(struct lnet_net *net);
-lnet_nid_t lnet_peer_primary_nid_locked(lnet_nid_t nid);
+void lnet_peer_primary_nid_locked(lnet_nid_t nid, struct lnet_nid *result);
 int lnet_discover_peer_locked(struct lnet_peer_ni *lpni, int cpt, bool block);
 void lnet_peer_queue_message(struct lnet_peer *lp, struct lnet_msg *msg);
 int lnet_peer_discovery_start(void);
diff --git a/include/linux/lnet/lib-types.h b/include/linux/lnet/lib-types.h
index eb736a5..40767e6 100644
--- a/include/linux/lnet/lib-types.h
+++ b/include/linux/lnet/lib-types.h
@@ -114,19 +114,19 @@ struct lnet_msg {
 	struct list_head	msg_activelist;
 	struct list_head	msg_list;	/* Q for credits/MD */
 
-	struct lnet_process_id	msg_target;
+	struct lnet_processid	msg_target;
 	/* Primary NID of the source. */
-	lnet_nid_t		msg_initiator;
+	struct lnet_nid		msg_initiator;
 	/* where is it from, it's only for building event */
-	lnet_nid_t		msg_from;
+	struct lnet_nid		msg_from;
 	u32			msg_type;
 
 	/*
 	 * hold parameters in case message is with held due
 	 * to discovery
 	 */
-	lnet_nid_t		msg_src_nid_param;
-	lnet_nid_t		msg_rtr_nid_param;
+	struct lnet_nid		msg_src_nid_param;
+	struct lnet_nid		msg_rtr_nid_param;
 
 	/*
 	 * Deadline for the message after which it will be finalized if it
diff --git a/net/lnet/klnds/o2iblnd/o2iblnd_cb.c b/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
index 7560fe1..8168a26 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -1512,7 +1512,7 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 {
 	struct lnet_hdr *hdr = &lntmsg->msg_hdr;
 	int type = lntmsg->msg_type;
-	struct lnet_process_id target = lntmsg->msg_target;
+	struct lnet_processid *target = &lntmsg->msg_target;
 	int target_is_router = lntmsg->msg_target_is_router;
 	int routing = lntmsg->msg_routing;
 	unsigned int payload_niov = lntmsg->msg_niov;
@@ -1527,9 +1527,8 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 	int rc;
 
 	/* NB 'private' is different depending on what we're sending.... */
-
 	CDEBUG(D_NET, "sending %d bytes in %d frags to %s\n",
-	       payload_nob, payload_niov, libcfs_id2str(target));
+	       payload_nob, payload_niov, libcfs_idstr(target));
 
 	LASSERT(!payload_nob || payload_niov > 0);
 	LASSERT(payload_niov <= LNET_MAX_IOV);
@@ -1543,11 +1542,11 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 
 	iov_iter_advance(&from, payload_offset);
 
-	tx = kiblnd_get_idle_tx(ni, target.nid);
+	tx = kiblnd_get_idle_tx(ni, lnet_nid_to_nid4(&target->nid));
 	if (!tx) {
 		CERROR("Can't allocate %s txd for %s\n",
 		       lnet_msgtyp2str(type),
-		       libcfs_nid2str(target.nid));
+		       libcfs_nidstr(&target->nid));
 		return -ENOMEM;
 	}
 	ibmsg = tx->tx_msg;
@@ -1576,7 +1575,7 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 					  payload_offset, payload_nob);
 		if (rc) {
 			CERROR("Can't setup GET sink for %s: %d\n",
-			       libcfs_nid2str(target.nid), rc);
+			       libcfs_nidstr(&target->nid), rc);
 			tx->tx_hstatus = LNET_MSG_STATUS_LOCAL_ERROR;
 			kiblnd_tx_done(tx);
 			return -EIO;
@@ -1591,7 +1590,7 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 		tx->tx_lntmsg[1] = lnet_create_reply_msg(ni, lntmsg);
 		if (!tx->tx_lntmsg[1]) {
 			CERROR("Can't create reply for GET -> %s\n",
-			       libcfs_nid2str(target.nid));
+			       libcfs_nidstr(&target->nid));
 			kiblnd_tx_done(tx);
 			return -EIO;
 		}
@@ -1599,7 +1598,7 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 		/* finalise lntmsg[0,1] on completion */
 		tx->tx_lntmsg[0] = lntmsg;
 		tx->tx_waiting = 1;		/* waiting for GET_DONE */
-		kiblnd_launch_tx(ni, tx, target.nid);
+		kiblnd_launch_tx(ni, tx, lnet_nid_to_nid4(&target->nid));
 		return 0;
 
 	case LNET_MSG_REPLY:
@@ -1614,7 +1613,7 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 					  payload_offset, payload_nob);
 		if (rc) {
 			CERROR("Can't setup PUT src for %s: %d\n",
-			       libcfs_nid2str(target.nid), rc);
+			       libcfs_nidstr(&target->nid), rc);
 			kiblnd_tx_done(tx);
 			return -EIO;
 		}
@@ -1626,7 +1625,7 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 		/* finalise lntmsg on completion */
 		tx->tx_lntmsg[0] = lntmsg;
 		tx->tx_waiting = 1;		/* waiting for PUT_{ACK,NAK} */
-		kiblnd_launch_tx(ni, tx, target.nid);
+		kiblnd_launch_tx(ni, tx, lnet_nid_to_nid4(&target->nid));
 		return 0;
 	}
 
@@ -1651,14 +1650,14 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 	/* finalise lntmsg on completion */
 	tx->tx_lntmsg[0] = lntmsg;
 
-	kiblnd_launch_tx(ni, tx, target.nid);
+	kiblnd_launch_tx(ni, tx, lnet_nid_to_nid4(&target->nid));
 	return 0;
 }
 
 static void
 kiblnd_reply(struct lnet_ni *ni, struct kib_rx *rx, struct lnet_msg *lntmsg)
 {
-	struct lnet_process_id target = lntmsg->msg_target;
+	struct lnet_processid *target = &lntmsg->msg_target;
 	unsigned int niov = lntmsg->msg_niov;
 	struct bio_vec *kiov = lntmsg->msg_kiov;
 	unsigned int offset = lntmsg->msg_offset;
@@ -1669,7 +1668,7 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 	tx = kiblnd_get_idle_tx(ni, rx->rx_conn->ibc_peer->ibp_nid);
 	if (!tx) {
 		CERROR("Can't get tx for REPLY to %s\n",
-		       libcfs_nid2str(target.nid));
+		       libcfs_nidstr(&target->nid));
 		goto failed_0;
 	}
 
@@ -1681,7 +1680,7 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 
 	if (rc) {
 		CERROR("Can't setup GET src for %s: %d\n",
-		       libcfs_nid2str(target.nid), rc);
+		       libcfs_nidstr(&target->nid), rc);
 		goto failed_1;
 	}
 
@@ -1691,7 +1690,7 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 			      rx->rx_msg->ibm_u.get.ibgm_cookie);
 	if (rc < 0) {
 		CERROR("Can't setup rdma for GET from %s: %d\n",
-		       libcfs_nid2str(target.nid), rc);
+		       libcfs_nidstr(&target->nid), rc);
 		goto failed_1;
 	}
 
diff --git a/net/lnet/klnds/socklnd/socklnd_cb.c b/net/lnet/klnds/socklnd/socklnd_cb.c
index b2a1267..d0c3628 100644
--- a/net/lnet/klnds/socklnd/socklnd_cb.c
+++ b/net/lnet/klnds/socklnd/socklnd_cb.c
@@ -911,7 +911,7 @@ struct ksock_conn_cb *
 {
 	unsigned int mpflag = 0;
 	int type = lntmsg->msg_type;
-	struct lnet_processid target;
+	struct lnet_processid *target = &lntmsg->msg_target;
 	unsigned int payload_niov = lntmsg->msg_niov;
 	struct bio_vec *payload_kiov = lntmsg->msg_kiov;
 	unsigned int payload_offset = lntmsg->msg_offset;
@@ -923,11 +923,9 @@ struct ksock_conn_cb *
 	/* NB 'private' is different depending on what we're sending.
 	 * Just ignore it...
 	 */
-	target.pid = lntmsg->msg_target.pid;
-	lnet_nid4_to_nid(lntmsg->msg_target.nid, &target.nid);
 
 	CDEBUG(D_NET, "sending %u bytes in %d frags to %s\n",
-	       payload_nob, payload_niov, libcfs_idstr(&target));
+	       payload_nob, payload_niov, libcfs_idstr(target));
 
 	LASSERT(!payload_nob || payload_niov > 0);
 	LASSERT(payload_niov <= LNET_MAX_IOV);
@@ -965,7 +963,7 @@ struct ksock_conn_cb *
 	tx->tx_msg.ksm_zc_cookies[1] = 0;
 
 	/* The first fragment will be set later in pro_pack */
-	rc = ksocknal_launch_packet(ni, tx, &target);
+	rc = ksocknal_launch_packet(ni, tx, target);
 	if (mpflag)
 		memalloc_noreclaim_restore(mpflag);
 
diff --git a/net/lnet/lnet/lib-move.c b/net/lnet/lnet/lib-move.c
index 8d4fd4d..83c93ca 100644
--- a/net/lnet/lnet/lib-move.c
+++ b/net/lnet/lnet/lib-move.c
@@ -517,7 +517,8 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 	       unsigned int offset, unsigned int len)
 {
 	msg->msg_type = type;
-	msg->msg_target = target;
+	msg->msg_target.pid = target.pid;
+	lnet_nid4_to_nid(target.nid, &msg->msg_target.nid);
 	msg->msg_len = len;
 	msg->msg_offset = offset;
 
@@ -567,7 +568,7 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 	if (rc) {
 		CERROR("recv from %s / send to %s aborted: eager_recv failed %d\n",
 		       libcfs_nidstr(&msg->msg_rxpeer->lpni_nid),
-		       libcfs_id2str(msg->msg_target), rc);
+		       libcfs_idstr(&msg->msg_target), rc);
 		LASSERT(rc < 0); /* required by my callers */
 	}
 
@@ -671,7 +672,7 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 					LNET_STATS_TYPE_DROP);
 
 		CNETERR("Dropping message for %s: peer not alive\n",
-			libcfs_id2str(msg->msg_target));
+			libcfs_idstr(&msg->msg_target));
 		msg->msg_health_status = LNET_MSG_STATUS_REMOTE_DROPPED;
 		if (do_send)
 			lnet_finalize(msg, -EHOSTUNREACH);
@@ -685,12 +686,12 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 		lnet_net_unlock(cpt);
 
 		CNETERR("Aborting message for %s: LNetM[DE]Unlink() already called on the MD/ME.\n",
-			libcfs_id2str(msg->msg_target));
+			libcfs_idstr(&msg->msg_target));
 		if (do_send) {
 			msg->msg_no_resend = true;
 			CDEBUG(D_NET,
 			       "msg %p to %s canceled and will not be resent\n",
-			       msg, libcfs_id2str(msg->msg_target));
+			       msg, libcfs_idstr(&msg->msg_target));
 			lnet_finalize(msg, -ECANCELED);
 		}
 
@@ -1629,7 +1630,7 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 	if (!msg->msg_routing)
 		msg->msg_hdr.src_nid =
 			cpu_to_le64(lnet_nid_to_nid4(&the_lnet.ln_loni->ni_nid));
-	msg->msg_target.nid = lnet_nid_to_nid4(&the_lnet.ln_loni->ni_nid);
+	msg->msg_target.nid = the_lnet.ln_loni->ni_nid;
 	lnet_msg_commit(msg, cpt);
 	msg->msg_txni = the_lnet.ln_loni;
 
@@ -1711,8 +1712,7 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 	 * what was originally set in the target or it will be the NID of
 	 * a router if this message should be routed
 	 */
-	/* FIXME handle large-addr nids */
-	msg->msg_target.nid = lnet_nid_to_nid4(&msg->msg_txpeer->lpni_nid);
+	msg->msg_target.nid = msg->msg_txpeer->lpni_nid;
 
 	/* lnet_msg_commit assigns the correct cpt to the message, which
 	 * is used to decrement the correct refcount on the ni when it's
@@ -2730,8 +2730,8 @@ struct lnet_ni *
 	 * continuing the same sequence of messages. Similarly, rtr_nid will
 	 * affect our choice of next hop.
 	 */
-	msg->msg_src_nid_param = src_nid;
-	msg->msg_rtr_nid_param = rtr_nid;
+	lnet_nid4_to_nid(src_nid, &msg->msg_src_nid_param);
+	lnet_nid4_to_nid(rtr_nid, &msg->msg_rtr_nid_param);
 
 	/* If necessary, perform discovery on the peer that owns this peer_ni.
 	 * Note, this can result in the ownership of this peer_ni changing
@@ -2844,7 +2844,7 @@ struct lnet_ni *
 int
 lnet_send(lnet_nid_t src_nid, struct lnet_msg *msg, lnet_nid_t rtr_nid)
 {
-	lnet_nid_t dst_nid = msg->msg_target.nid;
+	lnet_nid_t dst_nid = lnet_nid_to_nid4(&msg->msg_target.nid);
 	int rc;
 
 	/*
@@ -3107,17 +3107,18 @@ struct lnet_mt_event_info {
 			lnet_net_unlock(cpt);
 			CDEBUG(D_NET,
 			       "resending %s->%s: %s recovery %d try# %d\n",
-			       libcfs_nid2str(msg->msg_src_nid_param),
-			       libcfs_id2str(msg->msg_target),
+			       libcfs_nidstr(&msg->msg_src_nid_param),
+			       libcfs_idstr(&msg->msg_target),
 			       lnet_msgtyp2str(msg->msg_type),
 			       msg->msg_recovery,
 			       msg->msg_retry_count);
-			rc = lnet_send(msg->msg_src_nid_param, msg,
-				       msg->msg_rtr_nid_param);
+			rc = lnet_send(lnet_nid_to_nid4(&msg->msg_src_nid_param),
+				       msg,
+				       lnet_nid_to_nid4(&msg->msg_rtr_nid_param));
 			if (rc) {
 				CERROR("Error sending %s to %s: %d\n",
 				       lnet_msgtyp2str(msg->msg_type),
-				       libcfs_id2str(msg->msg_target), rc);
+				       libcfs_idstr(&msg->msg_target), rc);
 				msg->msg_no_resend = true;
 				lnet_finalize(msg, rc);
 			}
@@ -3920,14 +3921,14 @@ void lnet_monitor_thr_stop(void)
 	le32_to_cpus(&hdr->msg.put.offset);
 
 	/* Primary peer NID. */
-	lnet_nid4_to_nid(msg->msg_initiator, &info.mi_id.nid);
+	info.mi_id.nid = msg->msg_initiator;
 	info.mi_id.pid = hdr->src_pid;
 	info.mi_opc = LNET_MD_OP_PUT;
 	info.mi_portal = hdr->msg.put.ptl_index;
 	info.mi_rlength	= hdr->payload_length;
 	info.mi_roffset	= hdr->msg.put.offset;
 	info.mi_mbits = hdr->msg.put.match_bits;
-	info.mi_cpt = lnet_cpt_of_nid(msg->msg_initiator, ni);
+	info.mi_cpt = lnet_nid2cpt(&msg->msg_initiator, ni);
 
 	msg->msg_rx_ready_delay = !ni->ni_net->net_lnd->lnd_eager_recv;
 	ready_delay = msg->msg_rx_ready_delay;
@@ -3984,14 +3985,14 @@ void lnet_monitor_thr_stop(void)
 	source_id.nid = hdr->src_nid;
 	source_id.pid = hdr->src_pid;
 	/* Primary peer NID */
-	lnet_nid4_to_nid(msg->msg_initiator, &info.mi_id.nid);
+	info.mi_id.nid = msg->msg_initiator;
 	info.mi_id.pid = hdr->src_pid;
 	info.mi_opc = LNET_MD_OP_GET;
 	info.mi_portal = hdr->msg.get.ptl_index;
 	info.mi_rlength = hdr->msg.get.sink_length;
 	info.mi_roffset = hdr->msg.get.src_offset;
 	info.mi_mbits = hdr->msg.get.match_bits;
-	info.mi_cpt = lnet_cpt_of_nid(msg->msg_initiator, ni);
+	info.mi_cpt = lnet_nid2cpt(&msg->msg_initiator, ni);
 
 	rc = lnet_ptl_match_md(&info, msg);
 	if (rc == LNET_MATCHMD_DROP) {
@@ -4023,7 +4024,8 @@ void lnet_monitor_thr_stop(void)
 	msg->msg_receiving = 0;
 
 	/* FIXME need to handle large-addr nid */
-	rc = lnet_send(lnet_nid_to_nid4(&ni->ni_nid), msg, msg->msg_from);
+	rc = lnet_send(lnet_nid_to_nid4(&ni->ni_nid), msg,
+		       lnet_nid_to_nid4(&msg->msg_from));
 	if (rc < 0) {
 		/* didn't get as far as lnet_ni_send() */
 		CERROR("%s: Unable to send REPLY for GET from %s: %d\n",
@@ -4395,10 +4397,10 @@ void lnet_monitor_thr_stop(void)
 	msg->msg_offset = 0;
 	msg->msg_hdr = *hdr;
 	/* for building message event */
-	msg->msg_from = from_nid4;
+	msg->msg_from = from_nid;
 	if (!for_me) {
 		msg->msg_target.pid = dest_pid;
-		msg->msg_target.nid = dest_nid;
+		lnet_nid4_to_nid(dest_nid, &msg->msg_target.nid);
 		msg->msg_routing = 1;
 	} else {
 		/* convert common msg->hdr fields to host byteorder */
@@ -4491,7 +4493,7 @@ void lnet_monitor_thr_stop(void)
 	msg->msg_rxni = ni;
 	lnet_ni_addref_locked(ni, cpt);
 	/* Multi-Rail: Primary NID of source. */
-	msg->msg_initiator = lnet_peer_primary_nid_locked(src_nid);
+	lnet_peer_primary_nid_locked(src_nid, &msg->msg_initiator);
 
 	/* mark the status of this lpni as UP since we received a message
 	 * from it. The ping response reports back the ns_status which is
@@ -4827,7 +4829,7 @@ struct lnet_msg *
 	 */
 	struct lnet_msg *msg;
 	struct lnet_libmd *getmd = getmsg->msg_md;
-	struct lnet_process_id peer_id = getmsg->msg_target;
+	struct lnet_processid *peer_id = &getmsg->msg_target;
 	int cpt;
 
 	LASSERT(!getmsg->msg_target_is_router);
@@ -4836,7 +4838,7 @@ struct lnet_msg *
 	msg = kmem_cache_zalloc(lnet_msg_cachep, GFP_NOFS);
 	if (!msg) {
 		CERROR("%s: Dropping REPLY from %s: can't allocate msg\n",
-		       libcfs_nidstr(&ni->ni_nid), libcfs_id2str(peer_id));
+		       libcfs_nidstr(&ni->ni_nid), libcfs_idstr(peer_id));
 		goto drop;
 	}
 
@@ -4847,7 +4849,7 @@ struct lnet_msg *
 
 	if (!getmd->md_threshold) {
 		CERROR("%s: Dropping REPLY from %s for inactive MD %p\n",
-		       libcfs_nidstr(&ni->ni_nid), libcfs_id2str(peer_id),
+		       libcfs_nidstr(&ni->ni_nid), libcfs_idstr(peer_id),
 		       getmd);
 		lnet_res_unlock(cpt);
 		goto drop;
@@ -4856,21 +4858,21 @@ struct lnet_msg *
 	LASSERT(!getmd->md_offset);
 
 	CDEBUG(D_NET, "%s: Reply from %s md %p\n",
-	       libcfs_nidstr(&ni->ni_nid), libcfs_id2str(peer_id), getmd);
+	       libcfs_nidstr(&ni->ni_nid), libcfs_idstr(peer_id), getmd);
 
 	/* setup information for lnet_build_msg_event */
 	msg->msg_initiator =
-		lnet_nid_to_nid4(&getmsg->msg_txpeer->lpni_peer_net->lpn_peer->lp_primary_nid);
-	msg->msg_from = peer_id.nid;
+		getmsg->msg_txpeer->lpni_peer_net->lpn_peer->lp_primary_nid;
+	msg->msg_from = peer_id->nid;
 	msg->msg_type = LNET_MSG_GET; /* flag this msg as an "optimized" GET */
-	msg->msg_hdr.src_nid = peer_id.nid;
+	msg->msg_hdr.src_nid = lnet_nid_to_nid4(&peer_id->nid);
 	msg->msg_hdr.payload_length = getmd->md_length;
 	msg->msg_receiving = 1; /* required by lnet_msg_attach_md */
 
 	lnet_msg_attach_md(msg, getmd, getmd->md_offset, getmd->md_length);
 	lnet_res_unlock(cpt);
 
-	cpt = lnet_cpt_of_nid(peer_id.nid, ni);
+	cpt = lnet_nid2cpt(&peer_id->nid, ni);
 
 	lnet_net_lock(cpt);
 	lnet_msg_commit(msg, cpt);
@@ -4881,7 +4883,7 @@ struct lnet_msg *
 	return msg;
 
 drop:
-	cpt = lnet_cpt_of_nid(peer_id.nid, ni);
+	cpt = lnet_nid2cpt(&peer_id->nid, ni);
 
 	lnet_net_lock(cpt);
 	lnet_incr_stats(&ni->ni_stats, LNET_MSG_GET, LNET_STATS_TYPE_DROP);
diff --git a/net/lnet/lnet/lib-msg.c b/net/lnet/lnet/lib-msg.c
index 12768b2..980f93d 100644
--- a/net/lnet/lnet/lib-msg.c
+++ b/net/lnet/lnet/lib-msg.c
@@ -79,12 +79,12 @@
 		ev->target.nid = hdr->dest_nid;
 		ev->initiator.pid = hdr->src_pid;
 		/* Multi-Rail: resolve src_nid to "primary" peer NID */
-		ev->initiator.nid = msg->msg_initiator;
+		ev->initiator.nid = lnet_nid_to_nid4(&msg->msg_initiator);
 		/* Multi-Rail: track source NID. */
 		ev->source.pid = hdr->src_pid;
 		ev->source.nid = hdr->src_nid;
 		ev->rlength = hdr->payload_length;
-		ev->sender = msg->msg_from;
+		ev->sender = lnet_nid_to_nid4(&msg->msg_from);
 		ev->mlength = msg->msg_wanted;
 		ev->offset = msg->msg_offset;
 	}
@@ -396,7 +396,8 @@
 		msg->msg_hdr.msg.ack.match_bits = msg->msg_ev.match_bits;
 		msg->msg_hdr.msg.ack.mlength = cpu_to_le32(msg->msg_ev.mlength);
 
-		rc = lnet_send(msg->msg_ev.target.nid, msg, msg->msg_from);
+		rc = lnet_send(msg->msg_ev.target.nid, msg,
+			       lnet_nid_to_nid4(&msg->msg_from));
 
 		lnet_net_lock(cpt);
 		/*
@@ -636,7 +637,7 @@
 	 * this message consumed. The message will
 	 * consume another credit when it gets resent.
 	 */
-	msg->msg_target.nid = msg->msg_hdr.dest_nid;
+	lnet_nid4_to_nid(msg->msg_hdr.dest_nid, &msg->msg_target.nid);
 	lnet_msg_decommit_tx(msg, -EAGAIN);
 	msg->msg_sending = 0;
 	msg->msg_receiving = 0;
@@ -692,8 +693,8 @@
 	/* don't resend recovery messages */
 	if (msg->msg_recovery) {
 		CDEBUG(D_NET, "msg %s->%s is a recovery ping. retry# %d\n",
-		       libcfs_nid2str(msg->msg_from),
-		       libcfs_nid2str(msg->msg_target.nid),
+		       libcfs_nidstr(&msg->msg_from),
+		       libcfs_nidstr(&msg->msg_target.nid),
 		       msg->msg_retry_count);
 		return -ENOTRECOVERABLE;
 	}
@@ -703,8 +704,8 @@
 	 */
 	if (msg->msg_no_resend) {
 		CDEBUG(D_NET, "msg %s->%s requested no resend. retry# %d\n",
-		       libcfs_nid2str(msg->msg_from),
-		       libcfs_nid2str(msg->msg_target.nid),
+		       libcfs_nidstr(&msg->msg_from),
+		       libcfs_nidstr(&msg->msg_target.nid),
 		       msg->msg_retry_count);
 		return -ENOTRECOVERABLE;
 	}
@@ -712,8 +713,8 @@
 	/* check if the message has exceeded the number of retries */
 	if (msg->msg_retry_count >= lnet_retry_count) {
 		CNETERR("msg %s->%s exceeded retry count %d\n",
-			libcfs_nid2str(msg->msg_from),
-			libcfs_nid2str(msg->msg_target.nid),
+			libcfs_nidstr(&msg->msg_from),
+			libcfs_nidstr(&msg->msg_target.nid),
 			msg->msg_retry_count);
 		return -ENOTRECOVERABLE;
 	}
diff --git a/net/lnet/lnet/lib-ptl.c b/net/lnet/lnet/lib-ptl.c
index d367c00..30628e5 100644
--- a/net/lnet/lnet/lib-ptl.c
+++ b/net/lnet/lnet/lib-ptl.c
@@ -690,7 +690,7 @@ struct list_head *
 
 		hdr = &msg->msg_hdr;
 		/* Multi-Rail: Primary peer NID */
-		lnet_nid4_to_nid(msg->msg_initiator, &info.mi_id.nid);
+		info.mi_id.nid = msg->msg_initiator;
 		info.mi_id.pid = hdr->src_pid;
 		info.mi_opc = LNET_MD_OP_PUT;
 		info.mi_portal = hdr->msg.put.ptl_index;
diff --git a/net/lnet/lnet/peer.c b/net/lnet/lnet/peer.c
index 057a1db..9cb06d2 100644
--- a/net/lnet/lnet/peer.c
+++ b/net/lnet/lnet/peer.c
@@ -1325,20 +1325,18 @@ struct lnet_peer_ni *
 	}
 }
 
-lnet_nid_t
-lnet_peer_primary_nid_locked(lnet_nid_t nid)
+void
+lnet_peer_primary_nid_locked(lnet_nid_t nid, struct lnet_nid *result)
 {
 	/* FIXME handle large-addr nid */
 	struct lnet_peer_ni *lpni;
-	lnet_nid_t primary_nid = nid;
 
+	lnet_nid4_to_nid(nid, result);
 	lpni = lnet_find_peer_ni_locked(nid);
 	if (lpni) {
-		primary_nid = lnet_nid_to_nid4(&lpni->lpni_peer_net->lpn_peer->lp_primary_nid);
+		*result = lpni->lpni_peer_net->lpn_peer->lp_primary_nid;
 		lnet_peer_ni_decref_locked(lpni);
 	}
-
-	return primary_nid;
 }
 
 bool
@@ -2297,13 +2295,13 @@ static void lnet_peer_discovery_complete(struct lnet_peer *lp, int dc_error)
 
 		CDEBUG(D_NET, "sending pending message %s to target %s\n",
 		       lnet_msgtyp2str(msg->msg_type),
-		       libcfs_id2str(msg->msg_target));
-		rc = lnet_send(msg->msg_src_nid_param, msg,
-			       msg->msg_rtr_nid_param);
+		       libcfs_idstr(&msg->msg_target));
+		rc = lnet_send(lnet_nid_to_nid4(&msg->msg_src_nid_param), msg,
+			       lnet_nid_to_nid4(&msg->msg_rtr_nid_param));
 		if (rc < 0) {
 			CNETERR("Error sending %s to %s: %d\n",
 				lnet_msgtyp2str(msg->msg_type),
-				libcfs_id2str(msg->msg_target), rc);
+				libcfs_idstr(&msg->msg_target), rc);
 			lnet_finalize(msg, rc);
 		}
 	}
@@ -3699,12 +3697,12 @@ static void lnet_resend_msgs(void)
 
 	list_for_each_entry_safe(msg, tmp, &resend, msg_list) {
 		list_del_init(&msg->msg_list);
-		rc = lnet_send(msg->msg_src_nid_param, msg,
-			       msg->msg_rtr_nid_param);
+		rc = lnet_send(lnet_nid_to_nid4(&msg->msg_src_nid_param), msg,
+			       lnet_nid_to_nid4(&msg->msg_rtr_nid_param));
 		if (rc < 0) {
 			CNETERR("Error sending %s to %s: %d\n",
 				lnet_msgtyp2str(msg->msg_type),
-				libcfs_id2str(msg->msg_target), rc);
+				libcfs_idstr(&msg->msg_target), rc);
 			lnet_finalize(msg, rc);
 		}
 	}
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
