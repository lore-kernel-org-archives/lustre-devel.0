From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:13:16 -0500
Subject: [lustre-devel] [PATCH 328/622] lnet: select LO interface for sending
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-329-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <ashehata@whamcloud.com>

In the following scenario

Lustre->LNetPrimaryNID with 0 at lo
Discover is initiated on 0 at lo
The peer is created with 0 at lo and <addr>@<net>
The interface health of the peer's <addr>@<net> is decremented
LNetPut() to self
selection algorithm selects 0 at lo to send to

This exposes an issue where we try and go through the peer credit
management algorithm, but because there are no credits associated with
0 at lo we end up indefinitely queuing the message. ptlrpc will then get
stuck waiting for send completion on the message.

This was exposed via conf-sanity 32a

WC-bug-id: https://jira.whamcloud.com/browse/LU-12339
Lustre-commit: 69d1535ebdac ("LU-12339 lnet: select LO interface for sending")
Signed-off-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/34957
Reviewed-by: Olaf Weber <olaf.weber@hpe.com>
Reviewed-by: Chris Horn <hornc@cray.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/lib-move.c | 53 ++++++++++++++++++++++++++++++++++--------------
 1 file changed, 38 insertions(+), 15 deletions(-)

diff --git a/net/lnet/lnet/lib-move.c b/net/lnet/lnet/lib-move.c
index de5951a..75049ec 100644
--- a/net/lnet/lnet/lib-move.c
+++ b/net/lnet/lnet/lib-move.c
@@ -751,6 +751,8 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 	LASSERT(!do_send || msg->msg_tx_delayed);
 	LASSERT(!msg->msg_receiving);
 	LASSERT(msg->msg_tx_committed);
+	/* can't get here if we're sending to the loopback interface */
+	LASSERT(lp->lpni_nid != the_lnet.ln_loni->ni_nid);
 
 	/* NB 'lp' is always the next hop */
 	if (!(msg->msg_target.pid & LNET_PID_USERFLAG) &&
@@ -1426,6 +1428,25 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 #define SRC_ANY_ROUTER_NMR_DST	(SRC_ANY | REMOTE_DST | NMR_DST)
 
 static int
+lnet_handle_lo_send(struct lnet_send_data *sd)
+{
+	struct lnet_msg *msg = sd->sd_msg;
+	int cpt = sd->sd_cpt;
+
+	/* No send credit hassles with LOLND */
+	lnet_ni_addref_locked(the_lnet.ln_loni, cpt);
+	msg->msg_hdr.dest_nid = cpu_to_le64(the_lnet.ln_loni->ni_nid);
+	if (!msg->msg_routing)
+		msg->msg_hdr.src_nid =
+			cpu_to_le64(the_lnet.ln_loni->ni_nid);
+	msg->msg_target.nid = the_lnet.ln_loni->ni_nid;
+	lnet_msg_commit(msg, cpt);
+	msg->msg_txni = the_lnet.ln_loni;
+
+	return LNET_CREDIT_OK;
+}
+
+static int
 lnet_handle_send(struct lnet_send_data *sd)
 {
 	struct lnet_ni *best_ni = sd->sd_best_ni;
@@ -1733,7 +1754,10 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 					     sd->sd_best_ni->ni_net->net_id);
 	}
 
-	if (sd->sd_best_lpni)
+	if (sd->sd_best_lpni &&
+	    sd->sd_best_lpni->lpni_nid == the_lnet.ln_loni->ni_nid)
+		return lnet_handle_lo_send(sd);
+	else if (sd->sd_best_lpni)
 		return lnet_handle_send(sd);
 
 	CERROR("can't send to %s. no NI on %s\n",
@@ -2074,7 +2098,15 @@ struct lnet_ni *
 		 * try and see if we can reach it over another routed
 		 * network
 		 */
-		if (sd->sd_best_lpni) {
+		if (sd->sd_best_lpni &&
+		    sd->sd_best_lpni->lpni_nid == the_lnet.ln_loni->ni_nid) {
+			/* in case we initially started with a routed
+			 * destination, let's reset to local
+			 */
+			sd->sd_send_case &= ~REMOTE_DST;
+			sd->sd_send_case |= LOCAL_DST;
+			return lnet_handle_lo_send(sd);
+		} else if (sd->sd_best_lpni) {
 			/* in case we initially started with a routed
 			 * destination, let's reset to local
 			 */
@@ -2284,19 +2316,12 @@ struct lnet_ni *
 	 * is no need to go through any selection. We can just shortcut
 	 * the entire process and send over lolnd
 	 */
+	send_data.sd_msg = msg;
+	send_data.sd_cpt = cpt;
 	if (LNET_NETTYP(LNET_NIDNET(dst_nid)) == LOLND) {
-		/* No send credit hassles with LOLND */
-		lnet_ni_addref_locked(the_lnet.ln_loni, cpt);
-		msg->msg_hdr.dest_nid = cpu_to_le64(the_lnet.ln_loni->ni_nid);
-		if (!msg->msg_routing)
-			msg->msg_hdr.src_nid =
-				cpu_to_le64(the_lnet.ln_loni->ni_nid);
-		msg->msg_target.nid = the_lnet.ln_loni->ni_nid;
-		lnet_msg_commit(msg, cpt);
-		msg->msg_txni = the_lnet.ln_loni;
+		rc = lnet_handle_lo_send(&send_data);
 		lnet_net_unlock(cpt);
-
-		return LNET_CREDIT_OK;
+		return rc;
 	}
 
 	/* find an existing peer_ni, or create one and mark it as having been
@@ -2376,7 +2401,6 @@ struct lnet_ni *
 		send_case |= SND_RESP;
 
 	/* assign parameters to the send_data */
-	send_data.sd_msg = msg;
 	send_data.sd_rtr_nid = rtr_nid;
 	send_data.sd_src_nid = src_nid;
 	send_data.sd_dst_nid = dst_nid;
@@ -2387,7 +2411,6 @@ struct lnet_ni *
 	send_data.sd_final_dst_lpni = lpni;
 	send_data.sd_peer = peer;
 	send_data.sd_md_cpt = md_cpt;
-	send_data.sd_cpt = cpt;
 	send_data.sd_send_case = send_case;
 
 	rc = lnet_handle_send_case_locked(&send_data);
-- 
1.8.3.1
