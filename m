Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id BCCEDC433FE
	for <lustre-devel@archiver.kernel.org>; Sun, 20 Mar 2022 13:33:48 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id B47F521FD0D;
	Sun, 20 Mar 2022 06:32:36 -0700 (PDT)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 9F96B21CAD9
 for <lustre-devel@lists.lustre.org>; Sun, 20 Mar 2022 06:31:16 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 435A5EF1;
 Sun, 20 Mar 2022 09:31:08 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 416ECD5A47; Sun, 20 Mar 2022 09:31:08 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 20 Mar 2022 09:30:40 -0400
Message-Id: <1647783064-20688-27-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1647783064-20688-1-git-send-email-jsimmons@infradead.org>
References: <1647783064-20688-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 26/50] lnet: change src_nid arg to
 lnet_parse() to 16byte
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

lnet_parse() now gets the source nid as 'struct lnet_nid *'.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10391
Lustre-commit: eb0eedbb1a68297b8 ("LU-10391 lnet: change src_nid arg to lnet_parse() to 16byte")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/43614
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Chris Horn <chris.horn@hpe.com>
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/lib-lnet.h       |  2 +-
 net/lnet/klnds/o2iblnd/o2iblnd_cb.c | 10 +++++++---
 net/lnet/klnds/socklnd/socklnd_cb.c |  2 +-
 net/lnet/lnet/lib-move.c            | 39 +++++++++++++++++--------------------
 net/lnet/lnet/lo.c                  |  3 +--
 5 files changed, 28 insertions(+), 28 deletions(-)

diff --git a/include/linux/lnet/lib-lnet.h b/include/linux/lnet/lib-lnet.h
index fe2fd83..33fee17 100644
--- a/include/linux/lnet/lib-lnet.h
+++ b/include/linux/lnet/lib-lnet.h
@@ -706,7 +706,7 @@ void lnet_ptl_attach_md(struct lnet_me *me, struct lnet_libmd *md,
 
 /* message functions */
 int lnet_parse(struct lnet_ni *ni, struct lnet_hdr *hdr,
-	       lnet_nid_t fromnid, void *private, int rdma_req);
+	       struct lnet_nid *fromnid, void *private, int rdma_req);
 int lnet_parse_local(struct lnet_ni *ni, struct lnet_msg *msg);
 int lnet_parse_forward_locked(struct lnet_ni *ni, struct lnet_msg *msg);
 
diff --git a/net/lnet/klnds/o2iblnd/o2iblnd_cb.c b/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
index c1be2f7..983599f 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -323,6 +323,7 @@ static int kiblnd_init_rdma(struct kib_conn *conn, struct kib_tx *tx, int type,
 	int rc2;
 	int post_credit;
 	struct lnet_hdr hdr;
+	struct lnet_nid srcnid;
 
 	LASSERT(conn->ibc_state >= IBLND_CONN_ESTABLISHED);
 
@@ -382,7 +383,8 @@ static int kiblnd_init_rdma(struct kib_conn *conn, struct kib_tx *tx, int type,
 	case IBLND_MSG_IMMEDIATE:
 		post_credit = IBLND_POSTRX_DONT_POST;
 		lnet_hdr_from_nid4(&hdr, &msg->ibm_u.immediate.ibim_hdr);
-		rc = lnet_parse(ni, &hdr, msg->ibm_srcnid, rx, 0);
+		lnet_nid4_to_nid(msg->ibm_srcnid, &srcnid);
+		rc = lnet_parse(ni, &hdr, &srcnid, rx, 0);
 		if (rc < 0)		/* repost on error */
 			post_credit = IBLND_POSTRX_PEER_CREDIT;
 		break;
@@ -390,7 +392,8 @@ static int kiblnd_init_rdma(struct kib_conn *conn, struct kib_tx *tx, int type,
 	case IBLND_MSG_PUT_REQ:
 		post_credit = IBLND_POSTRX_DONT_POST;
 		lnet_hdr_from_nid4(&hdr, &msg->ibm_u.putreq.ibprm_hdr);
-		rc = lnet_parse(ni, &hdr, msg->ibm_srcnid, rx, 1);
+		lnet_nid4_to_nid(msg->ibm_srcnid, &srcnid);
+		rc = lnet_parse(ni, &hdr, &srcnid, rx, 1);
 		if (rc < 0)		/* repost on error */
 			post_credit = IBLND_POSTRX_PEER_CREDIT;
 		break;
@@ -454,7 +457,8 @@ static int kiblnd_init_rdma(struct kib_conn *conn, struct kib_tx *tx, int type,
 	case IBLND_MSG_GET_REQ:
 		post_credit = IBLND_POSTRX_DONT_POST;
 		lnet_hdr_from_nid4(&hdr, &msg->ibm_u.get.ibgm_hdr);
-		rc = lnet_parse(ni, &hdr, msg->ibm_srcnid, rx, 1);
+		lnet_nid4_to_nid(msg->ibm_srcnid, &srcnid);
+		rc = lnet_parse(ni, &hdr, &srcnid, rx, 1);
 		if (rc < 0)		/* repost on error */
 			post_credit = IBLND_POSTRX_PEER_CREDIT;
 		break;
diff --git a/net/lnet/klnds/socklnd/socklnd_cb.c b/net/lnet/klnds/socklnd/socklnd_cb.c
index af35c49..adec183 100644
--- a/net/lnet/klnds/socklnd/socklnd_cb.c
+++ b/net/lnet/klnds/socklnd/socklnd_cb.c
@@ -1189,7 +1189,7 @@ struct ksock_conn_cb *
 		ksocknal_conn_addref(conn);     /* ++ref while parsing */
 
 		rc = lnet_parse(conn->ksnc_peer->ksnp_ni, &hdr,
-				lnet_nid_to_nid4(&conn->ksnc_peer->ksnp_id.nid),
+				&conn->ksnc_peer->ksnp_id.nid,
 				conn, 0);
 		if (rc < 0) {
 			/* I just received garbage: give up on this conn */
diff --git a/net/lnet/lnet/lib-move.c b/net/lnet/lnet/lib-move.c
index 051bea1..8a90822 100644
--- a/net/lnet/lnet/lib-move.c
+++ b/net/lnet/lnet/lib-move.c
@@ -4229,8 +4229,8 @@ void lnet_monitor_thr_stop(void)
 EXPORT_SYMBOL(lnet_msgtyp2str);
 
 int
-lnet_parse(struct lnet_ni *ni, struct lnet_hdr *hdr, lnet_nid_t from_nid4,
-	   void *private, int rdma_req)
+lnet_parse(struct lnet_ni *ni, struct lnet_hdr *hdr,
+	   struct lnet_nid *from_nid, void *private, int rdma_req)
 {
 	struct lnet_peer_ni *lpni;
 	struct lnet_msg *msg;
@@ -4238,7 +4238,6 @@ void lnet_monitor_thr_stop(void)
 	lnet_pid_t dest_pid;
 	struct lnet_nid dest_nid;
 	struct lnet_nid src_nid;
-	struct lnet_nid from_nid;
 	bool push = false;
 	int for_me;
 	u32 type;
@@ -4247,8 +4246,6 @@ void lnet_monitor_thr_stop(void)
 
 	LASSERT(!in_interrupt());
 
-	lnet_nid4_to_nid(from_nid4, &from_nid);
-
 	type = hdr->type;
 	src_nid = hdr->src_nid;
 	dest_nid = hdr->dest_nid;
@@ -4256,7 +4253,7 @@ void lnet_monitor_thr_stop(void)
 	payload_length = hdr->payload_length;
 
 	for_me = nid_same(&ni->ni_nid, &dest_nid);
-	cpt = lnet_nid2cpt(&from_nid, ni);
+	cpt = lnet_nid2cpt(from_nid, ni);
 
 	CDEBUG(D_NET, "TRACE: %s(%s) <- %s : %s\n",
 	       libcfs_nidstr(&dest_nid),
@@ -4269,7 +4266,7 @@ void lnet_monitor_thr_stop(void)
 	case LNET_MSG_GET:
 		if (payload_length > 0) {
 			CERROR("%s, src %s: bad %s payload %d (0 expected)\n",
-			       libcfs_nid2str(from_nid4),
+			       libcfs_nidstr(from_nid),
 			       libcfs_nidstr(&src_nid),
 			       lnet_msgtyp2str(type), payload_length);
 			return -EPROTO;
@@ -4281,7 +4278,7 @@ void lnet_monitor_thr_stop(void)
 		if (payload_length >
 		   (u32)(for_me ? LNET_MAX_PAYLOAD : LNET_MTU)) {
 			CERROR("%s, src %s: bad %s payload %d (%d max expected)\n",
-			       libcfs_nid2str(from_nid4),
+			       libcfs_nidstr(from_nid),
 			       libcfs_nidstr(&src_nid),
 			       lnet_msgtyp2str(type),
 			       payload_length,
@@ -4292,7 +4289,7 @@ void lnet_monitor_thr_stop(void)
 
 	default:
 		CERROR("%s, src %s: Bad message type 0x%x\n",
-		       libcfs_nid2str(from_nid4),
+		       libcfs_nidstr(from_nid),
 		       libcfs_nidstr(&src_nid), type);
 		return -EPROTO;
 	}
@@ -4319,7 +4316,7 @@ void lnet_monitor_thr_stop(void)
 		if (LNET_NID_NET(&dest_nid) == LNET_NID_NET(&ni->ni_nid)) {
 			/* should have gone direct */
 			CERROR("%s, src %s: Bad dest nid %s (should have been sent direct)\n",
-			       libcfs_nid2str(from_nid4),
+			       libcfs_nidstr(from_nid),
 			       libcfs_nidstr(&src_nid),
 			       libcfs_nidstr(&dest_nid));
 			return -EPROTO;
@@ -4330,7 +4327,7 @@ void lnet_monitor_thr_stop(void)
 			 * this node's NID on its own network
 			 */
 			CERROR("%s, src %s: Bad dest nid %s (it's my nid but on a different network)\n",
-			       libcfs_nid2str(from_nid4),
+			       libcfs_nidstr(from_nid),
 			       libcfs_nidstr(&src_nid),
 			       libcfs_nidstr(&dest_nid));
 			return -EPROTO;
@@ -4338,7 +4335,7 @@ void lnet_monitor_thr_stop(void)
 
 		if (rdma_req && type == LNET_MSG_GET) {
 			CERROR("%s, src %s: Bad optimized GET for %s (final destination must be me)\n",
-			       libcfs_nid2str(from_nid4),
+			       libcfs_nidstr(from_nid),
 			       libcfs_nidstr(&src_nid),
 			       libcfs_nidstr(&dest_nid));
 			return -EPROTO;
@@ -4346,7 +4343,7 @@ void lnet_monitor_thr_stop(void)
 
 		if (!the_lnet.ln_routing) {
 			CERROR("%s, src %s: Dropping message for %s (routing not enabled)\n",
-			       libcfs_nid2str(from_nid4),
+			       libcfs_nidstr(from_nid),
 			       libcfs_nidstr(&src_nid),
 			       libcfs_nidstr(&dest_nid));
 			goto drop;
@@ -4360,7 +4357,7 @@ void lnet_monitor_thr_stop(void)
 	if (!list_empty(&the_lnet.ln_test_peers) &&	/* normally we don't */
 	    fail_peer(&src_nid, 0)) {			/* shall we now? */
 		CERROR("%s, src %s: Dropping %s to simulate failure\n",
-		       libcfs_nid2str(from_nid4), libcfs_nidstr(&src_nid),
+		       libcfs_nidstr(from_nid), libcfs_nidstr(&src_nid),
 		       lnet_msgtyp2str(type));
 		goto drop;
 	}
@@ -4369,7 +4366,7 @@ void lnet_monitor_thr_stop(void)
 	if (!list_empty(&the_lnet.ln_drop_rules) &&
 	    lnet_drop_rule_match(hdr, lnet_nid_to_nid4(&ni->ni_nid), NULL)) {
 		CDEBUG(D_NET, "%s, src %s, dst %s: Dropping %s to simulate silent message loss\n",
-		       libcfs_nid2str(from_nid4), libcfs_nidstr(&src_nid),
+		       libcfs_nidstr(from_nid), libcfs_nidstr(&src_nid),
 		       libcfs_nidstr(&dest_nid), lnet_msgtyp2str(type));
 		goto drop;
 	}
@@ -4377,7 +4374,7 @@ void lnet_monitor_thr_stop(void)
 	msg = kmem_cache_zalloc(lnet_msg_cachep, GFP_NOFS);
 	if (!msg) {
 		CERROR("%s, src %s: Dropping %s (out of memory)\n",
-		       libcfs_nid2str(from_nid4), libcfs_nidstr(&src_nid),
+		       libcfs_nidstr(from_nid), libcfs_nidstr(&src_nid),
 		       lnet_msgtyp2str(type));
 		goto drop;
 	}
@@ -4394,7 +4391,7 @@ void lnet_monitor_thr_stop(void)
 	msg->msg_offset = 0;
 	msg->msg_hdr = *hdr;
 	/* for building message event */
-	msg->msg_from = from_nid;
+	msg->msg_from = *from_nid;
 	if (!for_me) {
 		msg->msg_target.pid = dest_pid;
 		msg->msg_target.nid = dest_nid;
@@ -4402,12 +4399,12 @@ void lnet_monitor_thr_stop(void)
 	}
 
 	lnet_net_lock(cpt);
-	lpni = lnet_peerni_by_nid_locked(&from_nid, &ni->ni_nid, cpt);
+	lpni = lnet_peerni_by_nid_locked(from_nid, &ni->ni_nid, cpt);
 	if (IS_ERR(lpni)) {
 		lnet_net_unlock(cpt);
 		rc = PTR_ERR(lpni);
 		CERROR("%s, src %s: Dropping %s (error %d looking up sender)\n",
-		       libcfs_nid2str(from_nid4), libcfs_nidstr(&src_nid),
+		       libcfs_nidstr(from_nid), libcfs_nidstr(&src_nid),
 		       lnet_msgtyp2str(type), rc);
 		kfree(msg);
 		if (rc == -ESHUTDOWN)
@@ -4422,7 +4419,7 @@ void lnet_monitor_thr_stop(void)
 	 */
 	if (((lnet_drop_asym_route && for_me) ||
 	     !lpni->lpni_peer_net->lpn_peer->lp_alive) &&
-	    LNET_NID_NET(&src_nid) != LNET_NIDNET(from_nid4)) {
+	    LNET_NID_NET(&src_nid) != LNET_NID_NET(from_nid)) {
 		u32 src_net_id = LNET_NID_NET(&src_nid);
 		struct lnet_peer *gw = lpni->lpni_peer_net->lpn_peer;
 		struct lnet_route *route;
@@ -4457,7 +4454,7 @@ void lnet_monitor_thr_stop(void)
 			 * => asymmetric routing detected but forbidden
 			 */
 			CERROR("%s, src %s: Dropping asymmetrical route %s\n",
-			       libcfs_nid2str(from_nid4),
+			       libcfs_nidstr(from_nid),
 			       libcfs_nidstr(&src_nid), lnet_msgtyp2str(type));
 			kfree(msg);
 			goto drop;
diff --git a/net/lnet/lnet/lo.c b/net/lnet/lnet/lo.c
index 3d3dcf8..90155b5 100644
--- a/net/lnet/lnet/lo.c
+++ b/net/lnet/lnet/lo.c
@@ -40,8 +40,7 @@
 	LASSERT(!lntmsg->msg_routing);
 	LASSERT(!lntmsg->msg_target_is_router);
 
-	return lnet_parse(ni, &lntmsg->msg_hdr,
-			  lnet_nid_to_nid4(&ni->ni_nid), lntmsg, 0);
+	return lnet_parse(ni, &lntmsg->msg_hdr, &ni->ni_nid, lntmsg, 0);
 }
 
 static int
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
