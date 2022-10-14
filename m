Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 8A481C43217
	for <lustre-devel@archiver.kernel.org>; Fri, 14 Oct 2022 21:38:44 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4Mq0BX16P7z1y2t;
	Fri, 14 Oct 2022 14:38:44 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4Mq0B83mtKz21H2
 for <lustre-devel@lists.lustre.org>; Fri, 14 Oct 2022 14:38:24 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 18AE110084E1;
 Fri, 14 Oct 2022 17:38:14 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 152E6DD53C; Fri, 14 Oct 2022 17:38:14 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Fri, 14 Oct 2022 17:38:04 -0400
Message-Id: <1665783491-13827-14-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1665783491-13827-1-git-send-email-jsimmons@infradead.org>
References: <1665783491-13827-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 13/20] lnet: use %pISc for formatting IP
 addresses
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

The Linux kernel's printf functionality understands %pIS to means that
a the address in a 'struct sockaddr' should be formated, either as
IPv4 or IPv6.  For IPv6, the verbose format showing all 16 bytes
whether zero or not is used.

To get the more familiar "compressed" format where strings of :0000:
are replaced with ::, we need to add the 'c' flag.  This is ignored
for IPv4.

When requesting the port as well ("%pISp), the 'c' and 'p' can appear
in either order.

So this patch changes all %pIS to %pISc as we always want the
compressed format.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10391
Lustre-commit: ed6b125bab5f7e383 ("LU-10391 lnet: use %pISc for formatting IP addresses")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/48685
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/klnds/socklnd/socklnd.c       | 18 +++++------
 net/lnet/klnds/socklnd/socklnd_cb.c    | 44 +++++++++++++-------------
 net/lnet/klnds/socklnd/socklnd_proto.c | 30 +++++++++---------
 net/lnet/lnet/acceptor.c               | 34 ++++++++++----------
 net/lnet/lnet/lib-socket.c             |  2 +-
 5 files changed, 64 insertions(+), 64 deletions(-)

diff --git a/net/lnet/klnds/socklnd/socklnd.c b/net/lnet/klnds/socklnd/socklnd.c
index 89696977ac63..8999580b67b4 100644
--- a/net/lnet/klnds/socklnd/socklnd.c
+++ b/net/lnet/klnds/socklnd/socklnd.c
@@ -527,13 +527,13 @@ ksocknal_associate_cb_conn_locked(struct ksock_conn_cb *conn_cb,
 			/* conn_cb wasn't bound locally yet (the initial
 			 * conn_cb)
 			 */
-			CDEBUG(D_NET, "Binding %s %pIS to interface %d\n",
+			CDEBUG(D_NET, "Binding %s %pISc to interface %d\n",
 			       libcfs_idstr(&peer_ni->ksnp_id),
 			       &conn_cb->ksnr_addr,
 			       conn_iface);
 		} else {
 			CDEBUG(D_NET,
-			       "Rebinding %s %pIS from interface %d to %d\n",
+			       "Rebinding %s %pISc from interface %d to %d\n",
 			       libcfs_idstr(&peer_ni->ksnp_id),
 			       &conn_cb->ksnr_addr,
 			       conn_cb->ksnr_myiface,
@@ -835,7 +835,7 @@ ksocknal_accept(struct lnet_ni *ni, struct socket *sock)
 	cr = kzalloc(sizeof(*cr), GFP_NOFS);
 	if (!cr) {
 		LCONSOLE_ERROR_MSG(0x12f,
-				   "Dropping connection request from %pIS: memory exhausted\n",
+				   "Dropping connection request from %pISc: memory exhausted\n",
 				   &peer);
 		return -ENOMEM;
 	}
@@ -1113,7 +1113,7 @@ ksocknal_create_conn(struct lnet_ni *ni, struct ksock_conn_cb *conn_cb,
 	if (active &&
 	    !rpc_cmp_addr((struct sockaddr *)&conn_cb->ksnr_addr,
 			  (struct sockaddr *)&conn->ksnc_peeraddr)) {
-		CERROR("Route %s %pIS connected to %pIS\n",
+		CERROR("Route %s %pISc connected to %pISc\n",
 		       libcfs_idstr(&peer_ni->ksnp_id),
 		       &conn_cb->ksnr_addr,
 		       &conn->ksnc_peeraddr);
@@ -1183,7 +1183,7 @@ ksocknal_create_conn(struct lnet_ni *ni, struct ksock_conn_cb *conn_cb,
 	 *	socket callbacks.
 	 */
 	CDEBUG(D_NET,
-	       "New conn %s p %d.x %pIS -> %pISp incarnation:%lld sched[%d]\n",
+	       "New conn %s p %d.x %pISc -> %pIScp incarnation:%lld sched[%d]\n",
 	       libcfs_idstr(&peerid), conn->ksnc_proto->pro_version,
 	       &conn->ksnc_myaddr, &conn->ksnc_peeraddr,
 	       incarnation, cpt);
@@ -1552,7 +1552,7 @@ ksocknal_destroy_conn(struct ksock_conn *conn)
 	case SOCKNAL_RX_LNET_PAYLOAD:
 		last_rcv = conn->ksnc_rx_deadline -
 			   ksocknal_timeout();
-		CERROR("Completing partial receive from %s[%d], ip %pISp, with error, wanted: %zd, left: %d, last alive is %lld secs ago\n",
+		CERROR("Completing partial receive from %s[%d], ip %pIScp, with error, wanted: %zd, left: %d, last alive is %lld secs ago\n",
 		       libcfs_idstr(&conn->ksnc_peer->ksnp_id),
 		       conn->ksnc_type,
 		       &conn->ksnc_peeraddr,
@@ -1565,21 +1565,21 @@ ksocknal_destroy_conn(struct ksock_conn *conn)
 		break;
 	case SOCKNAL_RX_LNET_HEADER:
 		if (conn->ksnc_rx_started)
-			CERROR("Incomplete receive of lnet header from %s, ip %pISp, with error, protocol: %d.x.\n",
+			CERROR("Incomplete receive of lnet header from %s, ip %pIScp, with error, protocol: %d.x.\n",
 			       libcfs_idstr(&conn->ksnc_peer->ksnp_id),
 			       &conn->ksnc_peeraddr,
 			       conn->ksnc_proto->pro_version);
 		break;
 	case SOCKNAL_RX_KSM_HEADER:
 		if (conn->ksnc_rx_started)
-			CERROR("Incomplete receive of ksock message from %s, ip %pISp, with error, protocol: %d.x.\n",
+			CERROR("Incomplete receive of ksock message from %s, ip %pIScp, with error, protocol: %d.x.\n",
 			       libcfs_idstr(&conn->ksnc_peer->ksnp_id),
 			       &conn->ksnc_peeraddr,
 			       conn->ksnc_proto->pro_version);
 		break;
 	case SOCKNAL_RX_SLOP:
 		if (conn->ksnc_rx_started)
-			CERROR("Incomplete receive of slops from %s, ip %pISp, with error\n",
+			CERROR("Incomplete receive of slops from %s, ip %pIScp, with error\n",
 			       libcfs_idstr(&conn->ksnc_peer->ksnp_id),
 			       &conn->ksnc_peeraddr);
 	       break;
diff --git a/net/lnet/klnds/socklnd/socklnd_cb.c b/net/lnet/klnds/socklnd/socklnd_cb.c
index 308d8b0d6366..b2da535fbfbe 100644
--- a/net/lnet/klnds/socklnd/socklnd_cb.c
+++ b/net/lnet/klnds/socklnd/socklnd_cb.c
@@ -533,15 +533,15 @@ ksocknal_process_transmit(struct ksock_conn *conn, struct ksock_tx *tx)
 	if (!conn->ksnc_closing) {
 		switch (rc) {
 		case -ECONNRESET:
-			LCONSOLE_WARN("Host %pIS reset our connection while we were sending data; it may have rebooted.\n",
+			LCONSOLE_WARN("Host %pISc reset our connection while we were sending data; it may have rebooted.\n",
 				      &conn->ksnc_peeraddr);
 			break;
 		default:
-			LCONSOLE_WARN("There was an unexpected network error while writing to %pIS: %d.\n",
+			LCONSOLE_WARN("There was an unexpected network error while writing to %pISc: %d.\n",
 				      &conn->ksnc_peeraddr, rc);
 			break;
 		}
-		CDEBUG(D_NET, "[%p] Error %d on write to %s ip %pISp\n",
+		CDEBUG(D_NET, "[%p] Error %d on write to %s ip %pIScp\n",
 		       conn, rc, libcfs_idstr(&conn->ksnc_peer->ksnp_id),
 		       &conn->ksnc_peeraddr);
 	}
@@ -676,7 +676,7 @@ ksocknal_queue_tx_locked(struct ksock_tx *tx, struct ksock_conn *conn)
 	 */
 	LASSERT(!conn->ksnc_closing);
 
-	CDEBUG(D_NET, "Sending to %s ip %pISp\n",
+	CDEBUG(D_NET, "Sending to %s ip %pIScp\n",
 	       libcfs_idstr(&conn->ksnc_peer->ksnp_id),
 	       &conn->ksnc_peeraddr);
 
@@ -777,7 +777,7 @@ ksocknal_find_connectable_conn_cb_locked(struct ksock_peer_ni *peer_ni)
 	if (!(conn_cb->ksnr_retry_interval == 0 || /* first attempt */
 	      now >= conn_cb->ksnr_timeout)) {
 		CDEBUG(D_NET,
-		       "Too soon to retry route %pIS (cnted %d, interval %lld, %lld secs later)\n",
+		       "Too soon to retry route %pISc (cnted %d, interval %lld, %lld secs later)\n",
 		       &conn_cb->ksnr_addr,
 		       conn_cb->ksnr_connected,
 		       conn_cb->ksnr_retry_interval,
@@ -1095,11 +1095,11 @@ ksocknal_process_receive(struct ksock_conn *conn)
 			LASSERT(rc != -EAGAIN);
 
 			if (!rc)
-				CDEBUG(D_NET, "[%p] EOF from %s ip %pISp\n",
+				CDEBUG(D_NET, "[%p] EOF from %s ip %pIScp\n",
 				       conn, libcfs_idstr(ksnp_id),
 				       &conn->ksnc_peeraddr);
 			else if (!conn->ksnc_closing)
-				CERROR("[%p] Error %d on read from %s ip %pISp\n",
+				CERROR("[%p] Error %d on read from %s ip %pIScp\n",
 				       conn, rc, libcfs_idstr(ksnp_id),
 				       &conn->ksnc_peeraddr);
 
@@ -1653,7 +1653,7 @@ ksocknal_recv_hello(struct lnet_ni *ni, struct ksock_conn *conn,
 	rc = lnet_sock_read(sock, &hello->kshm_magic,
 			    sizeof(hello->kshm_magic), timeout);
 	if (rc) {
-		CERROR("Error %d reading HELLO from %pIS\n",
+		CERROR("Error %d reading HELLO from %pISc\n",
 		       rc, &conn->ksnc_peeraddr);
 		LASSERT(rc < 0);
 		return rc;
@@ -1663,7 +1663,7 @@ ksocknal_recv_hello(struct lnet_ni *ni, struct ksock_conn *conn,
 	    hello->kshm_magic != __swab32(LNET_PROTO_MAGIC) &&
 	    hello->kshm_magic != le32_to_cpu(LNET_PROTO_TCP_MAGIC)) {
 		/* Unexpected magic! */
-		CERROR("Bad magic(1) %#08x (%#08x expected) from %pIS\n",
+		CERROR("Bad magic(1) %#08x (%#08x expected) from %pISc\n",
 		       __cpu_to_le32(hello->kshm_magic),
 		       LNET_PROTO_TCP_MAGIC, &conn->ksnc_peeraddr);
 		return -EPROTO;
@@ -1672,7 +1672,7 @@ ksocknal_recv_hello(struct lnet_ni *ni, struct ksock_conn *conn,
 	rc = lnet_sock_read(sock, &hello->kshm_version,
 			    sizeof(hello->kshm_version), timeout);
 	if (rc) {
-		CERROR("Error %d reading HELLO from %pIS\n",
+		CERROR("Error %d reading HELLO from %pISc\n",
 		       rc, &conn->ksnc_peeraddr);
 		LASSERT(rc < 0);
 		return rc;
@@ -1696,7 +1696,7 @@ ksocknal_recv_hello(struct lnet_ni *ni, struct ksock_conn *conn,
 					    hello);
 		}
 
-		CERROR("Unknown protocol version (%d.x expected) from %pIS\n",
+		CERROR("Unknown protocol version (%d.x expected) from %pISc\n",
 		       conn->ksnc_proto->pro_version,
 		       &conn->ksnc_peeraddr);
 
@@ -1709,7 +1709,7 @@ ksocknal_recv_hello(struct lnet_ni *ni, struct ksock_conn *conn,
 	/* receive the rest of hello message anyway */
 	rc = conn->ksnc_proto->pro_recv_hello(conn, hello, timeout);
 	if (rc) {
-		CERROR("Error %d reading or checking hello from from %pIS\n",
+		CERROR("Error %d reading or checking hello from from %pISc\n",
 		       rc, &conn->ksnc_peeraddr);
 		LASSERT(rc < 0);
 		return rc;
@@ -1718,7 +1718,7 @@ ksocknal_recv_hello(struct lnet_ni *ni, struct ksock_conn *conn,
 	*incarnation = hello->kshm_src_incarnation;
 
 	if (LNET_NID_IS_ANY(&hello->kshm_src_nid)) {
-		CERROR("Expecting a HELLO hdr with a NID, but got LNET_NID_ANY from %pIS\n",
+		CERROR("Expecting a HELLO hdr with a NID, but got LNET_NID_ANY from %pISc\n",
 		       &conn->ksnc_peeraddr);
 		return -EPROTO;
 	}
@@ -1746,7 +1746,7 @@ ksocknal_recv_hello(struct lnet_ni *ni, struct ksock_conn *conn,
 		/* peer_ni determines type */
 		conn->ksnc_type = ksocknal_invert_type(hello->kshm_ctype);
 		if (conn->ksnc_type == SOCKLND_CONN_NONE) {
-			CERROR("Unexpected type %d from %s ip %pIS\n",
+			CERROR("Unexpected type %d from %s ip %pISc\n",
 			       hello->kshm_ctype, libcfs_idstr(peerid),
 			       &conn->ksnc_peeraddr);
 			return -EPROTO;
@@ -1758,7 +1758,7 @@ ksocknal_recv_hello(struct lnet_ni *ni, struct ksock_conn *conn,
 	if (peerid->pid != recv_id.pid ||
 	    !nid_same(&peerid->nid,  &recv_id.nid)) {
 		LCONSOLE_ERROR_MSG(0x130,
-				   "Connected successfully to %s on host %pIS, but they claimed they were %s; please check your Lustre configuration.\n",
+				   "Connected successfully to %s on host %pISc, but they claimed they were %s; please check your Lustre configuration.\n",
 				   libcfs_idstr(peerid),
 				   &conn->ksnc_peeraddr,
 				   libcfs_idstr(&recv_id));
@@ -1771,7 +1771,7 @@ ksocknal_recv_hello(struct lnet_ni *ni, struct ksock_conn *conn,
 	}
 
 	if (ksocknal_invert_type(hello->kshm_ctype) != conn->ksnc_type) {
-		CERROR("Mismatched types: me %d, %s ip %pIS %d\n",
+		CERROR("Mismatched types: me %d, %s ip %pISc %d\n",
 		       conn->ksnc_type, libcfs_idstr(peerid),
 		       &conn->ksnc_peeraddr, hello->kshm_ctype);
 		return -EPROTO;
@@ -2149,7 +2149,7 @@ ksocknal_connd(void *arg)
 			if (ksocknal_connect(conn_cb)) {
 				/* consecutive retry */
 				if (cons_retry++ > SOCKNAL_INSANITY_RECONN) {
-					CWARN("massive consecutive re-connecting to %pIS\n",
+					CWARN("massive consecutive re-connecting to %pISc\n",
 					      &conn_cb->ksnr_addr);
 					cons_retry = 0;
 				}
@@ -2211,17 +2211,17 @@ ksocknal_find_timed_out_conn(struct ksock_peer_ni *peer_ni)
 
 			switch (error) {
 			case ECONNRESET:
-				CNETERR("A connection with %s (%pISp) was reset; it may have rebooted.\n",
+				CNETERR("A connection with %s (%pIScp) was reset; it may have rebooted.\n",
 					libcfs_idstr(&peer_ni->ksnp_id),
 					&conn->ksnc_peeraddr);
 				break;
 			case ETIMEDOUT:
-				CNETERR("A connection with %s (%pISp) timed out; the network or node may be down.\n",
+				CNETERR("A connection with %s (%pIScp) timed out; the network or node may be down.\n",
 					libcfs_idstr(&peer_ni->ksnp_id),
 					&conn->ksnc_peeraddr);
 				break;
 			default:
-				CNETERR("An unexpected network error %d occurred with %s (%pISp\n",
+				CNETERR("An unexpected network error %d occurred with %s (%pIScp\n",
 					error,
 					libcfs_idstr(&peer_ni->ksnp_id),
 					&conn->ksnc_peeraddr);
@@ -2235,7 +2235,7 @@ ksocknal_find_timed_out_conn(struct ksock_peer_ni *peer_ni)
 		    ktime_get_seconds() >= conn->ksnc_rx_deadline) {
 			/* Timed out incomplete incoming message */
 			ksocknal_conn_addref(conn);
-			CNETERR("Timeout receiving from %s (%pISp), state %d wanted %zd left %d\n",
+			CNETERR("Timeout receiving from %s (%pIScp), state %d wanted %zd left %d\n",
 				libcfs_idstr(&peer_ni->ksnp_id),
 				&conn->ksnc_peeraddr,
 				conn->ksnc_rx_state,
@@ -2257,7 +2257,7 @@ ksocknal_find_timed_out_conn(struct ksock_peer_ni *peer_ni)
 					    tx_list)
 				tx->tx_hstatus =
 					LNET_MSG_STATUS_LOCAL_TIMEOUT;
-			CNETERR("Timeout sending data to %s (%pISp) the network or that node may be down.\n",
+			CNETERR("Timeout sending data to %s (%pIScp) the network or that node may be down.\n",
 				libcfs_idstr(&peer_ni->ksnp_id),
 				&conn->ksnc_peeraddr);
 			spin_unlock_bh(&sched->kss_lock);
diff --git a/net/lnet/klnds/socklnd/socklnd_proto.c b/net/lnet/klnds/socklnd/socklnd_proto.c
index 0a93d572ea68..4d92a1c93aad 100644
--- a/net/lnet/klnds/socklnd/socklnd_proto.c
+++ b/net/lnet/klnds/socklnd/socklnd_proto.c
@@ -548,7 +548,7 @@ ksocknal_send_hello_v1(struct ksock_conn *conn, struct ksock_hello_msg *hello)
 
 	rc = lnet_sock_write(sock, hdr, sizeof(*hdr), lnet_acceptor_timeout());
 	if (rc) {
-		CNETERR("Error %d sending HELLO hdr to %pISp\n",
+		CNETERR("Error %d sending HELLO hdr to %pIScp\n",
 			rc, &conn->ksnc_peeraddr);
 		goto out;
 	}
@@ -563,7 +563,7 @@ ksocknal_send_hello_v1(struct ksock_conn *conn, struct ksock_hello_msg *hello)
 			     hello->kshm_nips * sizeof(u32),
 			     lnet_acceptor_timeout());
 	if (rc) {
-		CNETERR("Error %d sending HELLO payload (%d) to %pISp\n",
+		CNETERR("Error %d sending HELLO payload (%d) to %pIScp\n",
 			rc, hello->kshm_nips,
 			&conn->ksnc_peeraddr);
 	}
@@ -621,7 +621,7 @@ ksocknal_send_hello_v2(struct ksock_conn *conn, struct ksock_hello_msg *hello)
 			     lnet_acceptor_timeout());
 	kfree(hello4);
 	if (rc) {
-		CNETERR("Error %d sending HELLO hdr to %pISp\n",
+		CNETERR("Error %d sending HELLO hdr to %pIScp\n",
 			rc, &conn->ksnc_peeraddr);
 		return rc;
 	}
@@ -633,7 +633,7 @@ ksocknal_send_hello_v2(struct ksock_conn *conn, struct ksock_hello_msg *hello)
 			     hello->kshm_nips * sizeof(u32),
 			     lnet_acceptor_timeout());
 	if (rc) {
-		CNETERR("Error %d sending HELLO payload (%d) to %pISp\n",
+		CNETERR("Error %d sending HELLO payload (%d) to %pIScp\n",
 			rc, hello->kshm_nips,
 			&conn->ksnc_peeraddr);
 	}
@@ -654,7 +654,7 @@ ksocknal_send_hello_v4(struct ksock_conn *conn, struct ksock_hello_msg *hello)
 			     lnet_acceptor_timeout());
 
 	if (rc != 0)
-		CNETERR("Error %d sending HELLO hdr to %pISp\n",
+		CNETERR("Error %d sending HELLO hdr to %pIScp\n",
 			rc, &conn->ksnc_peeraddr);
 	return rc;
 }
@@ -679,7 +679,7 @@ ksocknal_recv_hello_v1(struct ksock_conn *conn, struct ksock_hello_msg *hello,
 						    src_nid),
 			    timeout);
 	if (rc) {
-		CERROR("Error %d reading rest of HELLO hdr from %pIS\n",
+		CERROR("Error %d reading rest of HELLO hdr from %pISc\n",
 		       rc, &conn->ksnc_peeraddr);
 		LASSERT(rc < 0 && rc != -EALREADY);
 		goto out;
@@ -687,7 +687,7 @@ ksocknal_recv_hello_v1(struct ksock_conn *conn, struct ksock_hello_msg *hello,
 
 	/* ...and check we got what we expected */
 	if (hdr->type != cpu_to_le32(LNET_MSG_HELLO)) {
-		CERROR("Expecting a HELLO hdr, but got type %d from %pIS\n",
+		CERROR("Expecting a HELLO hdr, but got type %d from %pISc\n",
 		       le32_to_cpu(hdr->type),
 		       &conn->ksnc_peeraddr);
 		rc = -EPROTO;
@@ -701,7 +701,7 @@ ksocknal_recv_hello_v1(struct ksock_conn *conn, struct ksock_hello_msg *hello,
 	hello->kshm_nips = le32_to_cpu(hdr->payload_length) / sizeof(u32);
 
 	if (hello->kshm_nips > LNET_INTERFACES_NUM) {
-		CERROR("Bad nips %d from ip %pIS\n",
+		CERROR("Bad nips %d from ip %pISc\n",
 		       hello->kshm_nips, &conn->ksnc_peeraddr);
 		rc = -EPROTO;
 		goto out;
@@ -713,7 +713,7 @@ ksocknal_recv_hello_v1(struct ksock_conn *conn, struct ksock_hello_msg *hello,
 	rc = lnet_sock_read(sock, hello->kshm_ips,
 			    hello->kshm_nips * sizeof(u32), timeout);
 	if (rc) {
-		CERROR("Error %d reading IPs from ip %pIS\n",
+		CERROR("Error %d reading IPs from ip %pISc\n",
 		       rc, &conn->ksnc_peeraddr);
 		LASSERT(rc < 0 && rc != -EALREADY);
 		goto out;
@@ -723,7 +723,7 @@ ksocknal_recv_hello_v1(struct ksock_conn *conn, struct ksock_hello_msg *hello,
 		hello->kshm_ips[i] = __le32_to_cpu(hello->kshm_ips[i]);
 
 		if (!hello->kshm_ips[i]) {
-			CERROR("Zero IP[%d] from ip %pIS\n",
+			CERROR("Zero IP[%d] from ip %pISc\n",
 			       i, &conn->ksnc_peeraddr);
 			rc = -EPROTO;
 			break;
@@ -754,7 +754,7 @@ ksocknal_recv_hello_v2(struct ksock_conn *conn, struct ksock_hello_msg *hello,
 			    offsetof(struct ksock_hello_msg_nid4, kshm_src_nid),
 			    timeout);
 	if (rc) {
-		CERROR("Error %d reading HELLO from %pIS\n",
+		CERROR("Error %d reading HELLO from %pISc\n",
 		       rc, &conn->ksnc_peeraddr);
 		LASSERT(rc < 0 && rc != -EALREADY);
 		return rc;
@@ -783,7 +783,7 @@ ksocknal_recv_hello_v2(struct ksock_conn *conn, struct ksock_hello_msg *hello,
 	}
 
 	if (hello->kshm_nips > LNET_INTERFACES_NUM) {
-		CERROR("Bad nips %d from ip %pIS\n",
+		CERROR("Bad nips %d from ip %pISc\n",
 		       hello->kshm_nips, &conn->ksnc_peeraddr);
 		return -EPROTO;
 	}
@@ -794,7 +794,7 @@ ksocknal_recv_hello_v2(struct ksock_conn *conn, struct ksock_hello_msg *hello,
 	rc = lnet_sock_read(sock, hello->kshm_ips,
 			    hello->kshm_nips * sizeof(u32), timeout);
 	if (rc) {
-		CERROR("Error %d reading IPs from ip %pIS\n",
+		CERROR("Error %d reading IPs from ip %pISc\n",
 		       rc, &conn->ksnc_peeraddr);
 		LASSERT(rc < 0 && rc != -EALREADY);
 		return rc;
@@ -805,7 +805,7 @@ ksocknal_recv_hello_v2(struct ksock_conn *conn, struct ksock_hello_msg *hello,
 			__swab32s(&hello->kshm_ips[i]);
 
 		if (!hello->kshm_ips[i]) {
-			CERROR("Zero IP[%d] from ip %pIS\n",
+			CERROR("Zero IP[%d] from ip %pISc\n",
 			       i, &conn->ksnc_peeraddr);
 			return -EPROTO;
 		}
@@ -831,7 +831,7 @@ ksocknal_recv_hello_v4(struct ksock_conn *conn, struct ksock_hello_msg *hello,
 			    offsetof(struct ksock_hello_msg, kshm_src_nid),
 			    timeout);
 	if (rc) {
-		CERROR("Error %d reading HELLO from %pIS\n",
+		CERROR("Error %d reading HELLO from %pISc\n",
 		       rc, &conn->ksnc_peeraddr);
 		LASSERT(rc < 0 && rc != -EALREADY);
 		return rc;
diff --git a/net/lnet/lnet/acceptor.c b/net/lnet/lnet/acceptor.c
index 2306760210ae..6e219085cb53 100644
--- a/net/lnet/lnet/acceptor.c
+++ b/net/lnet/lnet/acceptor.c
@@ -91,37 +91,37 @@ lnet_connect_console_error(int rc, struct lnet_nid *peer_nid,
 	switch (rc) {
 	/* "normal" errors */
 	case -ECONNREFUSED:
-		CNETERR("Connection to %s at host %pISp was refused: check that Lustre is running on that node.\n",
+		CNETERR("Connection to %s at host %pIScp was refused: check that Lustre is running on that node.\n",
 			libcfs_nidstr(peer_nid), sa);
 		break;
 	case -EHOSTUNREACH:
 	case -ENETUNREACH:
-		CNETERR("Connection to %s at host %pIS was unreachable: the network or that node may be down, or Lustre may be misconfigured.\n",
+		CNETERR("Connection to %s at host %pISc was unreachable: the network or that node may be down, or Lustre may be misconfigured.\n",
 			libcfs_nidstr(peer_nid), sa);
 		break;
 	case -ETIMEDOUT:
-		CNETERR("Connection to %s at host %pISp took too long: that node may be hung or experiencing high load.\n",
+		CNETERR("Connection to %s at host %pIScp took too long: that node may be hung or experiencing high load.\n",
 			libcfs_nidstr(peer_nid), sa);
 		break;
 	case -ECONNRESET:
 		LCONSOLE_ERROR_MSG(0x11b,
-				   "Connection to %s at host %pISp was reset: is it running a compatible version of Lustre and is %s one of its NIDs?\n",
+				   "Connection to %s at host %pIScp was reset: is it running a compatible version of Lustre and is %s one of its NIDs?\n",
 				   libcfs_nidstr(peer_nid), sa,
 				   libcfs_nidstr(peer_nid));
 		break;
 	case -EPROTO:
 		LCONSOLE_ERROR_MSG(0x11c,
-				   "Protocol error connecting to %s at host %pISp: is it running a compatible version of Lustre?\n",
+				   "Protocol error connecting to %s at host %pIScp: is it running a compatible version of Lustre?\n",
 				   libcfs_nidstr(peer_nid), sa);
 		break;
 	case -EADDRINUSE:
 		LCONSOLE_ERROR_MSG(0x11d,
-				   "No privileged ports available to connect to %s at host %pISp\n",
+				   "No privileged ports available to connect to %s at host %pIScp\n",
 				   libcfs_nidstr(peer_nid), sa);
 		break;
 	default:
 		LCONSOLE_ERROR_MSG(0x11e,
-				   "Unexpected error %d connecting to %s at host %pISp\n",
+				   "Unexpected error %d connecting to %s at host %pIScp\n",
 				   rc, libcfs_nidstr(peer_nid), sa);
 		break;
 	}
@@ -237,7 +237,7 @@ lnet_accept(struct socket *sock, u32 magic)
 					     accept_timeout);
 
 			if (rc)
-				CERROR("Error sending magic+version in response to LNET magic from %pIS: %d\n",
+				CERROR("Error sending magic+version in response to LNET magic from %pISc: %d\n",
 				       &peer, rc);
 			return -EPROTO;
 		}
@@ -248,7 +248,7 @@ lnet_accept(struct socket *sock, u32 magic)
 			str = "unrecognised";
 
 		LCONSOLE_ERROR_MSG(0x11f,
-				   "Refusing connection from %pIS magic %08x: %s acceptor protocol\n",
+				   "Refusing connection from %pISc magic %08x: %s acceptor protocol\n",
 				   &peer, magic, str);
 		return -EPROTO;
 	}
@@ -258,7 +258,7 @@ lnet_accept(struct socket *sock, u32 magic)
 	rc = lnet_sock_read(sock, &cr.acr_version, sizeof(cr.acr_version),
 			    accept_timeout);
 	if (rc) {
-		CERROR("Error %d reading connection request version from %pIS\n",
+		CERROR("Error %d reading connection request version from %pISc\n",
 		       rc, &peer);
 		return -EIO;
 	}
@@ -281,7 +281,7 @@ lnet_accept(struct socket *sock, u32 magic)
 
 		rc = lnet_sock_write(sock, &cr, sizeof(cr), accept_timeout);
 		if (rc)
-			CERROR("Error sending magic+version in response to version %d from %pIS: %d\n",
+			CERROR("Error sending magic+version in response to version %d from %pISc: %d\n",
 			       peer_version, &peer, rc);
 		return -EPROTO;
 
@@ -311,7 +311,7 @@ lnet_accept(struct socket *sock, u32 magic)
 		break;
 	}
 	if (rc) {
-		CERROR("Error %d reading connection request from %pIS\n",
+		CERROR("Error %d reading connection request from %pISc\n",
 		       rc, &peer);
 		return -EIO;
 	}
@@ -323,7 +323,7 @@ lnet_accept(struct socket *sock, u32 magic)
 		if (ni)
 			lnet_ni_decref(ni);
 		LCONSOLE_ERROR_MSG(0x120,
-				   "Refusing connection from %pIS for %s: No matching NI\n",
+				   "Refusing connection from %pISc for %s: No matching NI\n",
 				   &peer, libcfs_nidstr(&nid));
 		return -EPERM;
 	}
@@ -332,12 +332,12 @@ lnet_accept(struct socket *sock, u32 magic)
 		/* This catches a request for the loopback LND */
 		lnet_ni_decref(ni);
 		LCONSOLE_ERROR_MSG(0x121,
-				   "Refusing connection from %pIS for %s: NI doesn not accept IP connections\n",
+				   "Refusing connection from %pISc for %s: NI doesn not accept IP connections\n",
 				   &peer, libcfs_nidstr(&nid));
 		return -EPERM;
 	}
 
-	CDEBUG(D_NET, "Accept %s from %pIS\n", libcfs_nidstr(&nid), &peer);
+	CDEBUG(D_NET, "Accept %s from %pISc\n", libcfs_nidstr(&nid), &peer);
 
 	rc = ni->ni_net->net_lnd->lnd_accept(ni, sock);
 
@@ -430,7 +430,7 @@ lnet_acceptor(void *arg)
 		if (secure &&
 		    rpc_get_port((struct sockaddr *)&peer) >
 		    LNET_ACCEPTOR_MAX_RESERVED_PORT) {
-			CERROR("Refusing connection from %pISp: insecure port\n",
+			CERROR("Refusing connection from %pIScp: insecure port\n",
 			       &peer);
 			goto failed;
 		}
@@ -438,7 +438,7 @@ lnet_acceptor(void *arg)
 		rc = lnet_sock_read(newsock, &magic, sizeof(magic),
 				    accept_timeout);
 		if (rc) {
-			CERROR("Error %d reading connection request from %pIS\n",
+			CERROR("Error %d reading connection request from %pISc\n",
 			       rc, &peer);
 			goto failed;
 		}
diff --git a/net/lnet/lnet/lib-socket.c b/net/lnet/lnet/lib-socket.c
index 01f375ed96a3..e6236c98261d 100644
--- a/net/lnet/lnet/lib-socket.c
+++ b/net/lnet/lnet/lib-socket.c
@@ -401,7 +401,7 @@ lnet_sock_connect(int interface, int local_port,
 	 * port...
 	 */
 	CDEBUG_LIMIT(rc == -EADDRNOTAVAIL ? D_NET : D_NETERROR,
-		     "Error %d connecting %d -> %pISp\n", rc,
+		     "Error %d connecting %d -> %pIScp\n", rc,
 		     local_port, peeraddr);
 
 	sock_release(sock);
-- 
2.27.0

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
