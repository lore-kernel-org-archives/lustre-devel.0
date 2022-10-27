Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 604C5ECAAA1
	for <lustre-devel@archiver.kernel.org>; Thu, 27 Oct 2022 14:24:43 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4Myngt6WDkz227B;
	Thu, 27 Oct 2022 07:12:42 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4Myngk266rz216F
 for <lustre-devel@lists.lustre.org>; Thu, 27 Oct 2022 07:12:34 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 8A8A81009107;
 Thu, 27 Oct 2022 10:05:44 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 874E2FD4F7; Thu, 27 Oct 2022 10:05:44 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Thu, 27 Oct 2022 10:05:38 -0400
Message-Id: <1666879542-10737-12-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1666879542-10737-1-git-send-email-jsimmons@infradead.org>
References: <1666879542-10737-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 11/15] lnet: add mechanism for dumping lnd
 peer debug info
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
Cc: Serguei Smirnov <ssmirnov@whamcloud.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Serguei Smirnov <ssmirnov@whamcloud.com>

Add ability to dump lnd peer debug info:
        lnetctl debug peer --nid=<nid>

The debug info is dumped to the log as D_CONSOLE by the respective
lnd and can be retrieved with "lctl dk" or seen in syslog.
This mechanism has been added for socklnd and o2iblnd peers.

WC-bug-id: https://jira.whamcloud.com/browse/LU-15234
Lustre-commit: 950e59ced18d49e9f ("LU-15234 lnet: add mechanism for dumping lnd peer debug info")
Signed-off-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/48566
Reviewed-by: Frank Sehr <fsehr@whamcloud.com>
Reviewed-by: Cyril Bordage <cbordage@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/klnds/o2iblnd/o2iblnd.c | 96 +++++++++++++++++++++++++++++++++++++++-
 net/lnet/klnds/socklnd/socklnd.c | 51 ++++++++++++++++++++-
 2 files changed, 143 insertions(+), 4 deletions(-)

diff --git a/net/lnet/klnds/o2iblnd/o2iblnd.c b/net/lnet/klnds/o2iblnd/o2iblnd.c
index 14dd686..d2e4ce9 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd.c
+++ b/net/lnet/klnds/o2iblnd/o2iblnd.c
@@ -422,7 +422,96 @@ void kiblnd_unlink_peer_locked(struct kib_peer_ni *peer_ni)
 	kiblnd_peer_decref(peer_ni);
 }
 
-static int kiblnd_get_peer_info(struct lnet_ni *ni, int index,
+static void
+kiblnd_debug_rx(struct kib_rx *rx)
+{
+	CDEBUG(D_CONSOLE, "      %p msg_type %x cred %d\n",
+	       rx, rx->rx_msg->ibm_type,
+	       rx->rx_msg->ibm_credits);
+}
+
+static void
+kiblnd_debug_tx(struct kib_tx *tx)
+{
+	CDEBUG(D_CONSOLE,
+	       "      %p snd %d q %d w %d rc %d dl %lld cookie %#llx msg %s%s type %x cred %d\n",
+	       tx, tx->tx_sending, tx->tx_queued, tx->tx_waiting,
+	       tx->tx_status, ktime_to_ns(tx->tx_deadline), tx->tx_cookie,
+	       !tx->tx_lntmsg[0] ? "-" : "!",
+	       !tx->tx_lntmsg[1] ? "-" : "!",
+	       tx->tx_msg->ibm_type, tx->tx_msg->ibm_credits);
+}
+
+static void
+kiblnd_debug_conn(struct kib_conn *conn)
+{
+	struct list_head *tmp;
+	int i;
+
+	spin_lock(&conn->ibc_lock);
+
+	CDEBUG(D_CONSOLE, "conn[%d] %p [version %x] -> %s:\n",
+	       atomic_read(&conn->ibc_refcount), conn,
+	       conn->ibc_version, libcfs_nid2str(conn->ibc_peer->ibp_nid));
+	CDEBUG(D_CONSOLE,
+	       "   state %d nposted %d/%d cred %d o_cred %d r_cred %d\n",
+	       conn->ibc_state, conn->ibc_noops_posted,
+	       conn->ibc_nsends_posted, conn->ibc_credits,
+	       conn->ibc_outstanding_credits, conn->ibc_reserved_credits);
+	CDEBUG(D_CONSOLE, "   comms_err %d\n", conn->ibc_comms_error);
+
+	CDEBUG(D_CONSOLE, "   early_rxs:\n");
+	list_for_each(tmp, &conn->ibc_early_rxs)
+		kiblnd_debug_rx(list_entry(tmp, struct kib_rx, rx_list));
+
+	CDEBUG(D_CONSOLE, "   tx_noops:\n");
+	list_for_each(tmp, &conn->ibc_tx_noops)
+		kiblnd_debug_tx(list_entry(tmp, struct kib_tx, tx_list));
+
+	CDEBUG(D_CONSOLE, "   tx_queue_nocred:\n");
+	list_for_each(tmp, &conn->ibc_tx_queue_nocred)
+		kiblnd_debug_tx(list_entry(tmp, struct kib_tx, tx_list));
+
+	CDEBUG(D_CONSOLE, "   tx_queue_rsrvd:\n");
+	list_for_each(tmp, &conn->ibc_tx_queue_rsrvd)
+		kiblnd_debug_tx(list_entry(tmp, struct kib_tx, tx_list));
+
+	CDEBUG(D_CONSOLE, "   tx_queue:\n");
+	list_for_each(tmp, &conn->ibc_tx_queue)
+		kiblnd_debug_tx(list_entry(tmp, struct kib_tx, tx_list));
+
+	CDEBUG(D_CONSOLE, "   active_txs:\n");
+	list_for_each(tmp, &conn->ibc_active_txs)
+		kiblnd_debug_tx(list_entry(tmp, struct kib_tx, tx_list));
+
+	CDEBUG(D_CONSOLE, "   rxs:\n");
+	for (i = 0; i < IBLND_RX_MSGS(conn); i++)
+		kiblnd_debug_rx(&conn->ibc_rxs[i]);
+
+	spin_unlock(&conn->ibc_lock);
+}
+
+static void
+kiblnd_dump_peer_debug_info(struct kib_peer_ni *peer_ni)
+{
+	struct kib_conn *conn;
+	struct kib_conn *cnxt;
+	int count = 0;
+
+	CDEBUG(D_CONSOLE, "[last_alive, races, reconnected, error]: %lld, %d, %d, %d\n",
+	       peer_ni->ibp_last_alive,
+	       peer_ni->ibp_races,
+	       peer_ni->ibp_reconnected,
+	       peer_ni->ibp_error);
+	list_for_each_entry_safe(conn, cnxt, &peer_ni->ibp_conns,
+				 ibc_list) {
+		CDEBUG(D_CONSOLE, "Conn %d:\n", count);
+		kiblnd_debug_conn(conn);
+		count++;
+	}
+}
+
+static int kiblnd_get_peer_info(struct lnet_ni *ni, lnet_nid_t nid, int index,
 				lnet_nid_t *nidp, int *count)
 {
 	struct kib_peer_ni *peer_ni;
@@ -437,6 +526,9 @@ static int kiblnd_get_peer_info(struct lnet_ni *ni, int index,
 		if (peer_ni->ibp_ni != ni)
 			continue;
 
+		if (peer_ni->ibp_nid == nid)
+			kiblnd_dump_peer_debug_info(peer_ni);
+
 		if (index-- > 0)
 			continue;
 
@@ -1065,7 +1157,7 @@ static int kiblnd_ctl(struct lnet_ni *ni, unsigned int cmd, void *arg)
 		lnet_nid_t nid = 0;
 		int count = 0;
 
-		rc = kiblnd_get_peer_info(ni, data->ioc_count,
+		rc = kiblnd_get_peer_info(ni, data->ioc_nid, data->ioc_count,
 					  &nid, &count);
 		data->ioc_nid = nid;
 		data->ioc_count = count;
diff --git a/net/lnet/klnds/socklnd/socklnd.c b/net/lnet/klnds/socklnd/socklnd.c
index 8d3c0d6..996d3a9 100644
--- a/net/lnet/klnds/socklnd/socklnd.c
+++ b/net/lnet/klnds/socklnd/socklnd.c
@@ -277,6 +277,52 @@ struct ksock_peer_ni *
 	ksocknal_peer_decref(peer_ni);
 }
 
+static void
+ksocknal_dump_peer_debug_info(struct ksock_peer_ni *peer_ni)
+{
+	struct ksock_conn *conn;
+	struct list_head *ctmp;
+	struct list_head *txtmp;
+	int ccount = 0;
+	int txcount = 0;
+
+	list_for_each(ctmp, &peer_ni->ksnp_conns) {
+		conn = list_entry(ctmp, struct ksock_conn, ksnc_list);
+
+		if (!list_empty(&conn->ksnc_tx_queue))
+			list_for_each(txtmp, &conn->ksnc_tx_queue) txcount++;
+
+		CDEBUG(D_CONSOLE, "Conn %d [type, closing, crefcnt, srefcnt]: %d, %d, %d, %d\n",
+		       ccount,
+		       conn->ksnc_type,
+		       conn->ksnc_closing,
+		       refcount_read(&conn->ksnc_conn_refcount),
+		       refcount_read(&conn->ksnc_sock_refcount));
+		CDEBUG(D_CONSOLE, "Conn %d rx [scheduled, ready, state]: %d, %d, %d\n",
+		       ccount,
+		       conn->ksnc_rx_scheduled,
+		       conn->ksnc_rx_ready,
+		       conn->ksnc_rx_state);
+		CDEBUG(D_CONSOLE,
+		       "Conn %d tx [txqcnt, scheduled, last_post, ready, deadline]: %d, %d, %lld, %d, %lld\n",
+		       ccount,
+		       txcount,
+		       conn->ksnc_tx_scheduled,
+		       conn->ksnc_tx_last_post,
+		       conn->ksnc_rx_ready,
+		       conn->ksnc_rx_deadline);
+
+		if (conn->ksnc_scheduler)
+			CDEBUG(D_CONSOLE, "Conn %d sched [nconns, cpt]: %d, %d\n",
+			       ccount,
+			       conn->ksnc_scheduler->kss_nconns,
+			       conn->ksnc_scheduler->kss_cpt);
+
+		txcount = 0;
+		ccount++;
+	}
+}
+
 static int
 ksocknal_get_peer_info(struct lnet_ni *ni, int index,
 		       struct lnet_processid *id, u32 *myip, u32 *peer_ip,
@@ -295,9 +341,9 @@ struct ksock_peer_ni *
 		if (index-- > 0)
 			continue;
 
+		*id = peer_ni->ksnp_id;
 		conn_cb = peer_ni->ksnp_conn_cb;
 		if (!conn_cb) {
-			*id = peer_ni->ksnp_id;
 			*myip = 0;
 			*peer_ip = 0;
 			*port = 0;
@@ -305,7 +351,8 @@ struct ksock_peer_ni *
 			*share_count = 0;
 			rc = 0;
 		} else {
-			*id = peer_ni->ksnp_id;
+			ksocknal_dump_peer_debug_info(peer_ni);
+
 			if (conn_cb->ksnr_addr.ss_family == AF_INET) {
 				struct sockaddr_in *sa;
 
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
