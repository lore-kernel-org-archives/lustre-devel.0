Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id E5E00C19F29
	for <lustre-devel@archiver.kernel.org>; Thu,  4 Aug 2022 01:39:25 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4LyrxT3TnXz23K5;
	Wed,  3 Aug 2022 18:39:25 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4Lyrwf66KLz23Jw
 for <lustre-devel@lists.lustre.org>; Wed,  3 Aug 2022 18:38:42 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id E62D6100B033;
 Wed,  3 Aug 2022 21:38:23 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id E44F582CCE; Wed,  3 Aug 2022 21:38:23 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Wed,  3 Aug 2022 21:38:08 -0400
Message-Id: <1659577097-19253-24-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1659577097-19253-1-git-send-email-jsimmons@infradead.org>
References: <1659577097-19253-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 23/32] lnet: o2iblnd: add debug messages for
 IB
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
Cc: Cyril Bordage <cbordage@whamcloud.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Cyril Bordage <cbordage@whamcloud.com>

If net debug is enabled, information about connection, when
tx status is ECONNABORTED, is collected (only for IB).

WC-bug-id: https://jira.whamcloud.com/browse/LU-15925
Lustre-commit: 9153049bdc7ec8217 ("LU-15925 lnet: add debug messages for IB")
Signed-off-by: Cyril Bordage <cbordage@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/47583
Reviewed-by: Frank Sehr <fsehr@whamcloud.com>
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/klnds/o2iblnd/o2iblnd_cb.c | 18 ++++++++++++++++--
 1 file changed, 16 insertions(+), 2 deletions(-)

diff --git a/net/lnet/klnds/o2iblnd/o2iblnd_cb.c b/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
index 01fa499..d4d8954 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -276,6 +276,13 @@ static int kiblnd_init_rdma(struct kib_conn *conn, struct kib_tx *tx, int type,
 
 	if (!tx->tx_status) {		/* success so far */
 		if (status < 0) {	/* failed? */
+			if (status == -ECONNABORTED) {
+				CDEBUG(D_NET,
+				       "bad status for connection to %s with completion type %x\n",
+				       libcfs_nid2str(conn->ibc_peer->ibp_nid),
+				       txtype);
+			}
+
 			tx->tx_status = status;
 			tx->tx_hstatus = LNET_MSG_STATUS_REMOTE_ERROR;
 		} else if (txtype == IBLND_MSG_GET_REQ) {
@@ -812,6 +819,8 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 
 	/* I'm still holding ibc_lock! */
 	if (conn->ibc_state != IBLND_CONN_ESTABLISHED) {
+		CDEBUG(D_NET, "connection to %s is not established\n",
+		       conn->ibc_peer ? libcfs_nid2str(conn->ibc_peer->ibp_nid) : "NULL");
 		rc = -ECONNABORTED;
 	} else if (tx->tx_pool->tpo_pool.po_failed ||
 		 conn->ibc_hdev != tx->tx_pool->tpo_hdev) {
@@ -1153,6 +1162,9 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 	LASSERT(conn->ibc_state >= IBLND_CONN_ESTABLISHED);
 
 	if (conn->ibc_state >= IBLND_CONN_DISCONNECTED) {
+		CDEBUG(D_NET, "connection with %s is disconnected\n",
+		       conn->ibc_peer ? libcfs_nid2str(conn->ibc_peer->ibp_nid) : "NULL");
+
 		tx->tx_status = -ECONNABORTED;
 		tx->tx_waiting = 0;
 		if (tx->tx_conn) {
@@ -2141,10 +2153,12 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 
 	kiblnd_set_conn_state(conn, IBLND_CONN_DISCONNECTED);
 
-	/*
-	 * Complete all tx descs not waiting for sends to complete.
+	/* Complete all tx descs not waiting for sends to complete.
 	 * NB we should be safe from RDMA now that the QP has changed state
 	 */
+	CDEBUG(D_NET, "abort connection with %s\n",
+	       libcfs_nid2str(conn->ibc_peer->ibp_nid));
+
 	kiblnd_abort_txs(conn, &conn->ibc_tx_noops);
 	kiblnd_abort_txs(conn, &conn->ibc_tx_queue);
 	kiblnd_abort_txs(conn, &conn->ibc_tx_queue_rsrvd);
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
