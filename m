Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 37474C433F5
	for <lustre-devel@archiver.kernel.org>; Fri, 14 Jan 2022 01:38:53 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id EEE493AD923;
	Thu, 13 Jan 2022 17:38:40 -0800 (PST)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 89D9321FF8F
 for <lustre-devel@lists.lustre.org>; Thu, 13 Jan 2022 17:38:07 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id ACA43100F320;
 Thu, 13 Jan 2022 20:38:04 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id A34EEE07E3; Thu, 13 Jan 2022 20:38:04 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Thu, 13 Jan 2022 20:37:42 -0500
Message-Id: <1642124283-10148-4-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1642124283-10148-1-git-send-email-jsimmons@infradead.org>
References: <1642124283-10148-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 03/24] lnet: o2iblnd: cleanup
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
Cc: Alexey Lyashkov <alexey.lyashkov@hpe.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Alexey Lyashkov <alexey.lyashkov@hpe.com>

simplify kiblnd_send by avoid code duplication.
lets pickup idle tx first.

HPE-bug-id: LUS-1796
WC-bug-id: https://jira.whamcloud.com/browse/LU-14008
Lustre-commit: 3916b9d7226ebb21c ("LU-14008 o2iblnd: cleanup")
Signed-off-by: Alexey Lyashkov <alexey.lyashkov@hpe.com>
Reviewed-on: https://review.whamcloud.com/40260
Reviewed-by: Chris Horn <chris.horn@hpe.com>
Reviewed-by: Alexander Boyko <alexander.boyko@hpe.com>
Reviewed-by: Cyril Bordage <cbordage@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/klnds/o2iblnd/o2iblnd_cb.c | 43 ++++++++++++++-----------------------
 net/lnet/lnet/lib-move.c            |  1 +
 2 files changed, 17 insertions(+), 27 deletions(-)

diff --git a/net/lnet/klnds/o2iblnd/o2iblnd_cb.c b/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
index db13f41..7560fe1 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -1543,6 +1543,15 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 
 	iov_iter_advance(&from, payload_offset);
 
+	tx = kiblnd_get_idle_tx(ni, target.nid);
+	if (!tx) {
+		CERROR("Can't allocate %s txd for %s\n",
+		       lnet_msgtyp2str(type),
+		       libcfs_nid2str(target.nid));
+		return -ENOMEM;
+	}
+	ibmsg = tx->tx_msg;
+
 	switch (type) {
 	default:
 		LBUG();
@@ -1561,14 +1570,6 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 		if (nob <= IBLND_MSG_SIZE && !lntmsg->msg_rdma_force)
 			break;		/* send IMMEDIATE */
 
-		tx = kiblnd_get_idle_tx(ni, target.nid);
-		if (!tx) {
-			CERROR("Can't allocate txd for GET to %s\n",
-			       libcfs_nid2str(target.nid));
-			return -ENOMEM;
-		}
-
-		ibmsg = tx->tx_msg;
 		rd = &ibmsg->ibm_u.get.ibgm_rd;
 		rc = kiblnd_setup_rd_kiov(ni, tx, rd,
 					  payload_niov, payload_kiov,
@@ -1595,7 +1596,8 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 			return -EIO;
 		}
 
-		tx->tx_lntmsg[0] = lntmsg;	/* finalise lntmsg[0,1] on completion */
+		/* finalise lntmsg[0,1] on completion */
+		tx->tx_lntmsg[0] = lntmsg;
 		tx->tx_waiting = 1;		/* waiting for GET_DONE */
 		kiblnd_launch_tx(ni, tx, target.nid);
 		return 0;
@@ -1607,14 +1609,6 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 		if (nob <= IBLND_MSG_SIZE && !lntmsg->msg_rdma_force)
 			break;			/* send IMMEDIATE */
 
-		tx = kiblnd_get_idle_tx(ni, target.nid);
-		if (!tx) {
-			CERROR("Can't allocate %s txd for %s\n",
-			       type == LNET_MSG_PUT ? "PUT" : "REPLY",
-			       libcfs_nid2str(target.nid));
-			return -ENOMEM;
-		}
-
 		rc = kiblnd_setup_rd_kiov(ni, tx, tx->tx_rd,
 					  payload_niov, payload_kiov,
 					  payload_offset, payload_nob);
@@ -1625,12 +1619,12 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 			return -EIO;
 		}
 
-		ibmsg = tx->tx_msg;
 		ibmsg->ibm_u.putreq.ibprm_hdr = *hdr;
 		ibmsg->ibm_u.putreq.ibprm_cookie = tx->tx_cookie;
 		kiblnd_init_tx_msg(ni, tx, IBLND_MSG_PUT_REQ, sizeof(struct kib_putreq_msg));
 
-		tx->tx_lntmsg[0] = lntmsg;	/* finalise lntmsg on completion */
+		/* finalise lntmsg on completion */
+		tx->tx_lntmsg[0] = lntmsg;
 		tx->tx_waiting = 1;		/* waiting for PUT_{ACK,NAK} */
 		kiblnd_launch_tx(ni, tx, target.nid);
 		return 0;
@@ -1641,13 +1635,6 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 	LASSERT(offsetof(struct kib_msg, ibm_u.immediate.ibim_payload[payload_nob])
 		 <= IBLND_MSG_SIZE);
 
-	tx = kiblnd_get_idle_tx(ni, target.nid);
-	if (!tx) {
-		CERROR("Can't send %d to %s: tx descs exhausted\n",
-		       type, libcfs_nid2str(target.nid));
-		return -ENOMEM;
-	}
-
 	ibmsg = tx->tx_msg;
 	ibmsg->ibm_u.immediate.ibim_hdr = *hdr;
 
@@ -1661,7 +1648,9 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 	nob = offsetof(struct kib_immediate_msg, ibim_payload[payload_nob]);
 	kiblnd_init_tx_msg(ni, tx, IBLND_MSG_IMMEDIATE, nob);
 
-	tx->tx_lntmsg[0] = lntmsg;		/* finalise lntmsg on completion */
+	/* finalise lntmsg on completion */
+	tx->tx_lntmsg[0] = lntmsg;
+
 	kiblnd_launch_tx(ni, tx, target.nid);
 	return 0;
 }
diff --git a/net/lnet/lnet/lib-move.c b/net/lnet/lnet/lib-move.c
index caffa30..133397e 100644
--- a/net/lnet/lnet/lib-move.c
+++ b/net/lnet/lnet/lib-move.c
@@ -4215,6 +4215,7 @@ void lnet_monitor_thr_stop(void)
 		return "<UNKNOWN>";
 	}
 }
+EXPORT_SYMBOL(lnet_msgtyp2str);
 
 int
 lnet_parse(struct lnet_ni *ni, struct lnet_hdr *hdr, lnet_nid_t from_nid4,
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
