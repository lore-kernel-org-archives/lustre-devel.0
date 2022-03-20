Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id B7974C433F5
	for <lustre-devel@archiver.kernel.org>; Sun, 20 Mar 2022 13:31:30 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id AA67221F9CF;
	Sun, 20 Mar 2022 06:31:22 -0700 (PDT)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id B42A321CA89
 for <lustre-devel@lists.lustre.org>; Sun, 20 Mar 2022 06:31:13 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 2104EEE3;
 Sun, 20 Mar 2022 09:31:08 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 1D433D5A47; Sun, 20 Mar 2022 09:31:08 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 20 Mar 2022 09:30:30 -0400
Message-Id: <1647783064-20688-17-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1647783064-20688-1-git-send-email-jsimmons@infradead.org>
References: <1647783064-20688-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 16/50] lnet: change lnet_hdr to store large
 nids.
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

'struct lnet_hdr' now has large-addr nids.  They are converted to
4-byte-addr on transmit, and converted back on receive.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10391
Lustre-commit: 5bb421cdfd4ce6a29 ("LU-10391 lnet: change lnet_hdr to store large nids.")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/43604
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/lib-lnet.h       |  8 +++---
 include/uapi/linux/lnet/lnet-idl.h  |  4 +--
 net/lnet/klnds/o2iblnd/o2iblnd_cb.c |  2 +-
 net/lnet/klnds/socklnd/socklnd_cb.c |  2 +-
 net/lnet/lnet/lib-move.c            | 49 ++++++++++++++++---------------------
 net/lnet/lnet/lib-msg.c             | 16 ++++++------
 net/lnet/lnet/lib-ptl.c             |  4 +--
 net/lnet/lnet/net_fault.c           |  8 +++---
 8 files changed, 43 insertions(+), 50 deletions(-)

diff --git a/include/linux/lnet/lib-lnet.h b/include/linux/lnet/lib-lnet.h
index 3c3a9d2..8c4940f 100644
--- a/include/linux/lnet/lib-lnet.h
+++ b/include/linux/lnet/lib-lnet.h
@@ -482,8 +482,8 @@ static inline void lnet_hdr_from_nid4(struct lnet_hdr *hdr,
 {
 	const struct _lnet_hdr_nid4 *hdr_nid4 = (void *)vhdr;
 
-	hdr->dest_nid = le64_to_cpu(hdr_nid4->dest_nid);
-	hdr->src_nid = le64_to_cpu(hdr_nid4->src_nid);
+	lnet_nid4_to_nid(le64_to_cpu(hdr_nid4->dest_nid), &hdr->dest_nid);
+	lnet_nid4_to_nid(le64_to_cpu(hdr_nid4->src_nid), &hdr->src_nid);
 	hdr->dest_pid = le32_to_cpu(hdr_nid4->dest_pid);
 	hdr->src_pid = le32_to_cpu(hdr_nid4->src_pid);
 	hdr->type = le32_to_cpu(hdr_nid4->type);
@@ -497,8 +497,8 @@ static inline void lnet_hdr_to_nid4(const struct lnet_hdr *hdr,
 {
 	struct _lnet_hdr_nid4 *hdr_nid4 = (void *)vhdr;
 
-	hdr_nid4->dest_nid = cpu_to_le64(hdr->dest_nid);
-	hdr_nid4->src_nid = cpu_to_le64(hdr->src_nid);
+	hdr_nid4->dest_nid = cpu_to_le64(lnet_nid_to_nid4(&hdr->dest_nid));
+	hdr_nid4->src_nid = cpu_to_le64(lnet_nid_to_nid4(&hdr->src_nid));
 	hdr_nid4->dest_pid = cpu_to_le32(hdr->dest_pid);
 	hdr_nid4->src_pid = cpu_to_le32(hdr->src_pid);
 	hdr_nid4->type = cpu_to_le32(hdr->type);
diff --git a/include/uapi/linux/lnet/lnet-idl.h b/include/uapi/linux/lnet/lnet-idl.h
index a19da76..74036e7 100644
--- a/include/uapi/linux/lnet/lnet-idl.h
+++ b/include/uapi/linux/lnet/lnet-idl.h
@@ -154,8 +154,8 @@ struct lnet_hello {
  *  All fields before the union are in host-byte-order.
  */
 struct lnet_hdr {
-	lnet_nid_t		dest_nid;
-	lnet_nid_t		src_nid;
+	struct lnet_nid		dest_nid;
+	struct lnet_nid		src_nid;
 	lnet_pid_t		dest_pid;
 	lnet_pid_t		src_pid;
 	__u32			type;		/* enum lnet_msg_type */
diff --git a/net/lnet/klnds/o2iblnd/o2iblnd_cb.c b/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
index 8f24e26..c1be2f7 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -1762,7 +1762,7 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 		nob = offsetof(struct kib_msg, ibm_u.immediate.ibim_payload[rlen]);
 		if (nob > rx->rx_nob) {
 			CERROR("Immediate message from %s too big: %d(%d)\n",
-			       libcfs_nid2str(lntmsg->msg_hdr.src_nid),
+			       libcfs_nidstr(&lntmsg->msg_hdr.src_nid),
 			       nob, rx->rx_nob);
 			rc = -EPROTO;
 			break;
diff --git a/net/lnet/klnds/socklnd/socklnd_cb.c b/net/lnet/klnds/socklnd/socklnd_cb.c
index 40f3e79..925494b 100644
--- a/net/lnet/klnds/socklnd/socklnd_cb.c
+++ b/net/lnet/klnds/socklnd/socklnd_cb.c
@@ -1184,7 +1184,7 @@ struct ksock_conn_cb *
 
 			/* Substitute process ID assigned at connection time */
 			hdr.src_pid = id->pid;
-			hdr.src_nid = lnet_nid_to_nid4(&id->nid);
+			hdr.src_nid = id->nid;
 		}
 
 		conn->ksnc_rx_state = SOCKNAL_RX_PARSE;
diff --git a/net/lnet/lnet/lib-move.c b/net/lnet/lnet/lib-move.c
index f55b525..f4c24ff 100644
--- a/net/lnet/lnet/lib-move.c
+++ b/net/lnet/lnet/lib-move.c
@@ -528,7 +528,7 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 	memset(&msg->msg_hdr, 0, sizeof(msg->msg_hdr));
 	msg->msg_hdr.type = type;
 	/* dest_nid will be overwritten by lnet_select_pathway() */
-	msg->msg_hdr.dest_nid = target.nid;
+	lnet_nid4_to_nid(target.nid, &msg->msg_hdr.dest_nid);
 	msg->msg_hdr.dest_pid = target.pid;
 	/* src_nid will be set later */
 	msg->msg_hdr.src_pid = the_lnet.ln_pid;
@@ -1626,11 +1626,9 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 
 	/* No send credit hassles with LOLND */
 	lnet_ni_addref_locked(the_lnet.ln_loni, cpt);
-	msg->msg_hdr.dest_nid =
-		lnet_nid_to_nid4(&the_lnet.ln_loni->ni_nid);
+	msg->msg_hdr.dest_nid = the_lnet.ln_loni->ni_nid;
 	if (!msg->msg_routing)
-		msg->msg_hdr.src_nid =
-			lnet_nid_to_nid4(&the_lnet.ln_loni->ni_nid);
+		msg->msg_hdr.src_nid = the_lnet.ln_loni->ni_nid;
 	msg->msg_target.nid = the_lnet.ln_loni->ni_nid;
 	lnet_msg_commit(msg, cpt);
 	msg->msg_txni = the_lnet.ln_loni;
@@ -1726,8 +1724,7 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 	 * originator and set it here.
 	 */
 	if (!msg->msg_routing)
-		msg->msg_hdr.src_nid =
-			lnet_nid_to_nid4(&msg->msg_txni->ni_nid);
+		msg->msg_hdr.src_nid = msg->msg_txni->ni_nid;
 
 	if (routing) {
 		msg->msg_target_is_router = 1;
@@ -1741,15 +1738,12 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 		 * lnet_select_pathway() function and is never changed.
 		 * It's safe to use it here.
 		 */
-		/* FIXME handle large-addr nid */
-		msg->msg_hdr.dest_nid =
-			lnet_nid_to_nid4(&final_dst_lpni->lpni_nid);
+		msg->msg_hdr.dest_nid = final_dst_lpni->lpni_nid;
 	} else {
 		/* if we're not routing set the dest_nid to the best peer
 		 * ni NID that we picked earlier in the algorithm.
 		 */
-		msg->msg_hdr.dest_nid =
-			lnet_nid_to_nid4(&msg->msg_txpeer->lpni_nid);
+		msg->msg_hdr.dest_nid = msg->msg_txpeer->lpni_nid;
 	}
 
 	/* if we have response tracker block update it with the next hop
@@ -1768,10 +1762,10 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 	rc = lnet_post_send_locked(msg, 0);
 	if (!rc)
 		CDEBUG(D_NET, "TRACE: %s(%s:%s) -> %s(%s:%s) %s : %s try# %d\n",
-		       libcfs_nid2str(msg->msg_hdr.src_nid),
+		       libcfs_nidstr(&msg->msg_hdr.src_nid),
 		       libcfs_nidstr(&msg->msg_txni->ni_nid),
 		       libcfs_nidstr(&sd->sd_src_nid),
-		       libcfs_nid2str(msg->msg_hdr.dest_nid),
+		       libcfs_nidstr(&msg->msg_hdr.dest_nid),
 		       libcfs_nidstr(&sd->sd_dst_nid),
 		       libcfs_nidstr(&msg->msg_txpeer->lpni_nid),
 		       libcfs_nidstr(&sd->sd_rtr_nid),
@@ -2789,8 +2783,8 @@ struct lnet_ni *
 		struct lnet_peer *src_lp;
 		struct lnet_peer_ni *src_lpni;
 
-		src_lpni = lnet_nid2peerni_locked(msg->msg_hdr.src_nid,
-						  LNET_NID_ANY, cpt);
+		src_lpni = lnet_peerni_by_nid_locked(&msg->msg_hdr.src_nid,
+						     NULL, cpt);
 		/* We don't fail the send if we hit any errors here. We'll just
 		 * try to send it via non-multi-rail criteria
 		 */
@@ -3104,11 +3098,11 @@ struct lnet_mt_event_info {
 
 		list_del_init(&msg->msg_list);
 
-		lpni = lnet_find_peer_ni_locked(msg->msg_hdr.dest_nid);
+		lpni = lnet_peer_ni_find_locked(&msg->msg_hdr.dest_nid);
 		if (!lpni) {
 			lnet_net_unlock(cpt);
 			CERROR("Expected that a peer is already created for %s\n",
-			       libcfs_nid2str(msg->msg_hdr.dest_nid));
+			       libcfs_nidstr(&msg->msg_hdr.dest_nid));
 			msg->msg_no_resend = true;
 			lnet_finalize(msg, -EFAULT);
 			lnet_net_lock(cpt);
@@ -3994,7 +3988,7 @@ void lnet_monitor_thr_stop(void)
 	le32_to_cpus(&hdr->msg.get.sink_length);
 	le32_to_cpus(&hdr->msg.get.src_offset);
 
-	source_id.nid = hdr->src_nid;
+	source_id.nid = lnet_nid_to_nid4(&hdr->src_nid);
 	source_id.pid = hdr->src_pid;
 	/* Primary peer NID */
 	info.mi_id.nid = msg->msg_initiator;
@@ -4062,7 +4056,7 @@ void lnet_monitor_thr_stop(void)
 	cpt = lnet_cpt_of_cookie(hdr->msg.reply.dst_wmd.wh_object_cookie);
 	lnet_res_lock(cpt);
 
-	src.nid = hdr->src_nid;
+	src.nid = lnet_nid_to_nid4(&hdr->src_nid);
 	src.pid = hdr->src_pid;
 
 	/* NB handles only looked up by creator (no flips) */
@@ -4121,7 +4115,7 @@ void lnet_monitor_thr_stop(void)
 	struct lnet_libmd *md;
 	int cpt;
 
-	src.nid = hdr->src_nid;
+	src.nid = lnet_nid_to_nid4(&hdr->src_nid);
 	src.pid = hdr->src_pid;
 
 	/* Convert ack fields to host byte order */
@@ -4261,8 +4255,8 @@ void lnet_monitor_thr_stop(void)
 	lnet_nid4_to_nid(from_nid4, &from_nid);
 
 	type = hdr->type;
-	src_nid = hdr->src_nid;
-	dest_nid = hdr->dest_nid;
+	src_nid = lnet_nid_to_nid4(&hdr->src_nid);
+	dest_nid = lnet_nid_to_nid4(&hdr->dest_nid);
 	dest_pid = hdr->dest_pid;
 	payload_length = hdr->payload_length;
 
@@ -4554,7 +4548,7 @@ void lnet_monitor_thr_stop(void)
 
 		list_del(&msg->msg_list);
 
-		id.nid = msg->msg_hdr.src_nid;
+		id.nid = lnet_nid_to_nid4(&msg->msg_hdr.src_nid);
 		id.pid = msg->msg_hdr.src_pid;
 
 		LASSERT(!msg->msg_md);
@@ -4599,11 +4593,10 @@ void lnet_monitor_thr_stop(void)
 
 		list_del(&msg->msg_list);
 
-		/*
-		 * md won't disappear under me, since each msg
+		/* md won't disappear under me, since each msg
 		 * holds a ref on it
 		 */
-		id.nid = msg->msg_hdr.src_nid;
+		id.nid = lnet_nid_to_nid4(&msg->msg_hdr.src_nid);
 		id.pid = msg->msg_hdr.src_pid;
 
 		LASSERT(msg->msg_rx_delayed);
@@ -4870,7 +4863,7 @@ struct lnet_msg *
 		getmsg->msg_txpeer->lpni_peer_net->lpn_peer->lp_primary_nid;
 	msg->msg_from = peer_id->nid;
 	msg->msg_type = LNET_MSG_GET; /* flag this msg as an "optimized" GET */
-	msg->msg_hdr.src_nid = lnet_nid_to_nid4(&peer_id->nid);
+	msg->msg_hdr.src_nid = peer_id->nid;
 	msg->msg_hdr.payload_length = getmd->md_length;
 	msg->msg_receiving = 1; /* required by lnet_msg_attach_md */
 
diff --git a/net/lnet/lnet/lib-msg.c b/net/lnet/lnet/lib-msg.c
index 62a02ac..9a4e268 100644
--- a/net/lnet/lnet/lib-msg.c
+++ b/net/lnet/lnet/lib-msg.c
@@ -66,7 +66,7 @@
 
 	if (ev_type == LNET_EVENT_SEND) {
 		/* event for active message */
-		lnet_nid4_to_nid(hdr->dest_nid, &ev->target.nid);
+		ev->target.nid = hdr->dest_nid;
 		ev->target.pid = hdr->dest_pid;
 		ev->initiator.nid = LNET_ANY_NID;
 		ev->initiator.pid = the_lnet.ln_pid;
@@ -76,13 +76,13 @@
 	} else {
 		/* event for passive message */
 		ev->target.pid = hdr->dest_pid;
-		lnet_nid4_to_nid(hdr->dest_nid, &ev->target.nid);
+		ev->target.nid = hdr->dest_nid;
 		ev->initiator.pid = hdr->src_pid;
 		/* Multi-Rail: resolve src_nid to "primary" peer NID */
 		ev->initiator.nid = msg->msg_initiator;
 		/* Multi-Rail: track source NID. */
 		ev->source.pid = hdr->src_pid;
-		lnet_nid4_to_nid(hdr->src_nid, &ev->source.nid);
+		ev->source.nid = hdr->src_nid;
 		ev->rlength = hdr->payload_length;
 		ev->sender = msg->msg_from;
 		ev->mlength = msg->msg_wanted;
@@ -638,15 +638,15 @@
 	 * this message consumed. The message will
 	 * consume another credit when it gets resent.
 	 */
-	lnet_nid4_to_nid(msg->msg_hdr.dest_nid, &msg->msg_target.nid);
+	msg->msg_target.nid = msg->msg_hdr.dest_nid;
 	lnet_msg_decommit_tx(msg, -EAGAIN);
 	msg->msg_sending = 0;
 	msg->msg_receiving = 0;
 	msg->msg_target_is_router = 0;
 
 	CDEBUG(D_NET, "%s->%s:%s:%s - queuing msg (%p) for resend\n",
-	       libcfs_nid2str(msg->msg_hdr.src_nid),
-	       libcfs_nid2str(msg->msg_hdr.dest_nid),
+	       libcfs_nidstr(&msg->msg_hdr.src_nid),
+	       libcfs_nidstr(&msg->msg_hdr.dest_nid),
 	       lnet_msgtyp2str(msg->msg_type),
 	       lnet_health_error2str(msg->msg_health_status), msg);
 
@@ -1116,9 +1116,9 @@
 
 	CDEBUG(D_NET,
 	       "src %s(%s)->dst %s: %s simulate health error: %s\n",
-	       libcfs_nid2str(msg->msg_hdr.src_nid),
+	       libcfs_nidstr(&msg->msg_hdr.src_nid),
 	       libcfs_nidstr(&msg->msg_txni->ni_nid),
-	       libcfs_nid2str(msg->msg_hdr.dest_nid),
+	       libcfs_nidstr(&msg->msg_hdr.dest_nid),
 	       lnet_msgtyp2str(msg->msg_type),
 	       lnet_health_error2str(*hstatus));
 
diff --git a/net/lnet/lnet/lib-ptl.c b/net/lnet/lnet/lib-ptl.c
index 30628e5..0aad9a8 100644
--- a/net/lnet/lnet/lib-ptl.c
+++ b/net/lnet/lnet/lib-ptl.c
@@ -279,8 +279,8 @@ struct lnet_match_table *
 		return mtable;
 
 	/* it's a wildcard portal */
-	routed = LNET_NIDNET(msg->msg_hdr.src_nid) !=
-		 LNET_NIDNET(msg->msg_hdr.dest_nid);
+	routed = LNET_NID_NET(&msg->msg_hdr.src_nid) !=
+		 LNET_NID_NET(&msg->msg_hdr.dest_nid);
 
 	if (portal_rotor == LNET_PTL_ROTOR_OFF ||
 	    (portal_rotor != LNET_PTL_ROTOR_ON && !routed)) {
diff --git a/net/lnet/lnet/net_fault.c b/net/lnet/lnet/net_fault.c
index ee45767..1f08b38 100644
--- a/net/lnet/lnet/net_fault.c
+++ b/net/lnet/lnet/net_fault.c
@@ -427,8 +427,8 @@ struct lnet_drop_rule {
 		     lnet_nid_t local_nid,
 		     enum lnet_msg_hstatus *hstatus)
 {
-	lnet_nid_t src = hdr->src_nid;
-	lnet_nid_t dst = hdr->dest_nid;
+	lnet_nid_t src = lnet_nid_to_nid4(&hdr->src_nid);
+	lnet_nid_t dst = lnet_nid_to_nid4(&hdr->dest_nid);
 	unsigned int typ = hdr->type;
 	struct lnet_drop_rule *rule;
 	unsigned int ptl = -1;
@@ -605,8 +605,8 @@ struct delay_daemon_data {
 lnet_delay_rule_match_locked(struct lnet_hdr *hdr, struct lnet_msg *msg)
 {
 	struct lnet_delay_rule *rule;
-	lnet_nid_t src = hdr->src_nid;
-	lnet_nid_t dst = hdr->dest_nid;
+	lnet_nid_t src = lnet_nid_to_nid4(&hdr->src_nid);
+	lnet_nid_t dst = lnet_nid_to_nid4(&hdr->dest_nid);
 	unsigned int typ = hdr->type;
 	unsigned int ptl = -1;
 
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
