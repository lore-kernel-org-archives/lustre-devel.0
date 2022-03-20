Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id F0B22C433EF
	for <lustre-devel@archiver.kernel.org>; Sun, 20 Mar 2022 13:31:25 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 22ADD21F9A0;
	Sun, 20 Mar 2022 06:31:20 -0700 (PDT)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 0707221CA7D
 for <lustre-devel@lists.lustre.org>; Sun, 20 Mar 2022 06:31:11 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 06E04EDA;
 Sun, 20 Mar 2022 09:31:08 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id EA8B1FCF3C; Sun, 20 Mar 2022 09:31:07 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 20 Mar 2022 09:30:20 -0400
Message-Id: <1647783064-20688-7-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1647783064-20688-1-git-send-email-jsimmons@infradead.org>
References: <1647783064-20688-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 06/50] lnet: socklnd: prepare for new
 KSOCK_MSG type
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

Various places in socklnd assume there are only two message type:
KSOCK_MSG_NOOP and KSOCK_MSG_LNET.  We will soon add another type to
support a new lnet_hdr type with large addresses.
So do some cleanup first:

- get rid of ksock_lnet_msg - it doesn't add anything to lnet_hdr
- separate out 'struct ksock_hdr'.  We often want the size of this
  header, and instead request the offset of a field in ksock_msg.
- introduce switch statements in a couple of places to handle the
  different types of ksock_msg.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10391
Lustre-commit: 6940303aad5375bb2 ("LU-10391 socklnd: prepare for new KSOCK_MSG type")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/43601
Reviewed-by: Chris Horn <chris.horn@hpe.com>
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/socklnd.h           | 38 ++++++++++++--------------
 net/lnet/klnds/socklnd/socklnd_cb.c    | 50 +++++++++++++++++-----------------
 net/lnet/klnds/socklnd/socklnd_proto.c | 49 ++++++++++++++++++++-------------
 3 files changed, 73 insertions(+), 64 deletions(-)

diff --git a/include/linux/lnet/socklnd.h b/include/linux/lnet/socklnd.h
index 9f318b7..97ae0e2 100644
--- a/include/linux/lnet/socklnd.h
+++ b/include/linux/lnet/socklnd.h
@@ -52,33 +52,31 @@ struct ksock_hello_msg {
 	u32		kshm_ips[0];	/* IP addrs */
 } __packed;
 
-struct ksock_lnet_msg {
-	struct lnet_hdr	ksnm_hdr;	/* lnet hdr */
-
-	/*
-	 * ksnm_payload is removed because of winnt compiler's limitation:
-	 * zero-sized array can only be placed at the tail of [nested]
-	 * structure definitions. lnet payload will be stored just after
-	 * the body of structure ksock_lnet_msg_t
-	 */
+struct ksock_msg_hdr {
+	u32		ksh_type;		/* type of socklnd message */
+	u32		ksh_csum;		/* checksum if != 0 */
+	u64		ksh_zc_cookies[2];	/* Zero-Copy request/ACK
+						 * cookie
+						 */
 } __packed;
 
+#define KSOCK_MSG_NOOP	0xC0	/* empty */
+#define KSOCK_MSG_LNET	0xC1	/* lnet msg */
+
 struct ksock_msg {
-	u32		ksm_type;		/* type of socklnd message */
-	u32		ksm_csum;		/* checksum if != 0 */
-	u64		ksm_zc_cookies[2];	/* Zero-Copy request/ACK cookie */
+	struct ksock_msg_hdr	ksm_kh;
 	union {
-		struct ksock_lnet_msg lnetmsg; /* lnet message, it's empty if
-						* it's NOOP
-						*/
+		/* case ksm_kh.ksh_type == KSOCK_MSG_NOOP */
+		/* - nothing */
+		/* case ksm_kh.ksh_type == KSOCK_MSG_LNET */
+		struct lnet_hdr lnetmsg;
 	} __packed ksm_u;
 } __packed;
+#define ksm_type ksm_kh.ksh_type
+#define ksm_csum ksm_kh.ksh_csum
+#define ksm_zc_cookies ksm_kh.ksh_zc_cookies
 
-#define KSOCK_MSG_NOOP	0xC0	/* ksm_u empty */
-#define KSOCK_MSG_LNET	0xC1	/* lnet msg */
-
-/*
- * We need to know this number to parse hello msg from ksocklnd in
+/* We need to know this number to parse hello msg from ksocklnd in
  * other LND (usocklnd, for example)
  */
 #define KSOCK_PROTO_V2	2
diff --git a/net/lnet/klnds/socklnd/socklnd_cb.c b/net/lnet/klnds/socklnd/socklnd_cb.c
index d0c3628..feab2a07 100644
--- a/net/lnet/klnds/socklnd/socklnd_cb.c
+++ b/net/lnet/klnds/socklnd/socklnd_cb.c
@@ -1007,10 +1007,10 @@ struct ksock_conn_cb *
 		case  KSOCK_PROTO_V3:
 			conn->ksnc_rx_state = SOCKNAL_RX_KSM_HEADER;
 			kvec->iov_base = &conn->ksnc_msg;
-			kvec->iov_len = offsetof(struct ksock_msg, ksm_u);
-			conn->ksnc_rx_nob_left = offsetof(struct ksock_msg, ksm_u);
+			kvec->iov_len = sizeof(struct ksock_msg_hdr);
+			conn->ksnc_rx_nob_left = sizeof(struct ksock_msg_hdr);
 			iov_iter_kvec(&conn->ksnc_rx_to, READ, kvec, 1,
-				      offsetof(struct ksock_msg, ksm_u));
+				      sizeof(struct ksock_msg_hdr));
 			break;
 
 		case KSOCK_PROTO_V1:
@@ -1111,16 +1111,6 @@ struct ksock_conn_cb *
 			__swab64s(&conn->ksnc_msg.ksm_zc_cookies[1]);
 		}
 
-		if (conn->ksnc_msg.ksm_type != KSOCK_MSG_NOOP &&
-		    conn->ksnc_msg.ksm_type != KSOCK_MSG_LNET) {
-			CERROR("%s: Unknown message type: %x\n",
-			       libcfs_idstr(&conn->ksnc_peer->ksnp_id),
-			       conn->ksnc_msg.ksm_type);
-			ksocknal_new_packet(conn, 0);
-			ksocknal_close_conn_and_siblings(conn, -EPROTO);
-			return -EPROTO;
-		}
-
 		if (conn->ksnc_msg.ksm_type == KSOCK_MSG_NOOP &&
 		    conn->ksnc_msg.ksm_csum &&     /* has checksum */
 		    conn->ksnc_msg.ksm_csum != conn->ksnc_rx_csum) {
@@ -1154,21 +1144,31 @@ struct ksock_conn_cb *
 			}
 		}
 
-		if (conn->ksnc_msg.ksm_type == KSOCK_MSG_NOOP) {
+		switch (conn->ksnc_msg.ksm_type) {
+		case KSOCK_MSG_NOOP:
 			ksocknal_new_packet(conn, 0);
 			return 0;       /* NOOP is done and just return */
-		}
 
-		conn->ksnc_rx_state = SOCKNAL_RX_LNET_HEADER;
-		conn->ksnc_rx_nob_left = sizeof(struct ksock_lnet_msg);
+		case KSOCK_MSG_LNET:
+			conn->ksnc_rx_state = SOCKNAL_RX_LNET_HEADER;
+			conn->ksnc_rx_nob_left = sizeof(struct lnet_hdr);
+
+			kvec->iov_base = &conn->ksnc_msg.ksm_u.lnetmsg;
+			kvec->iov_len = sizeof(struct lnet_hdr);
 
-		kvec->iov_base = &conn->ksnc_msg.ksm_u.lnetmsg;
-		kvec->iov_len = sizeof(struct ksock_lnet_msg);
+			iov_iter_kvec(&conn->ksnc_rx_to, READ, kvec, 1,
+				      sizeof(struct lnet_hdr));
 
-		iov_iter_kvec(&conn->ksnc_rx_to, READ, kvec, 1,
-			      sizeof(struct ksock_lnet_msg));
+			goto again;     /* read lnet header now */
 
-		goto again;     /* read lnet header now */
+		default:
+			CERROR("%s: Unknown message type: %x\n",
+			       libcfs_idstr(&conn->ksnc_peer->ksnp_id),
+			       conn->ksnc_msg.ksm_type);
+			ksocknal_new_packet(conn, 0);
+			ksocknal_close_conn_and_siblings(conn, -EPROTO);
+			return -EPROTO;
+		}
 
 	case SOCKNAL_RX_LNET_HEADER:
 		/* unpack message header */
@@ -1176,7 +1176,7 @@ struct ksock_conn_cb *
 
 		if (conn->ksnc_peer->ksnp_id.pid & LNET_PID_USERFLAG) {
 			/* Userspace peer_ni */
-			lhdr = &conn->ksnc_msg.ksm_u.lnetmsg.ksnm_hdr;
+			lhdr = &conn->ksnc_msg.ksm_u.lnetmsg;
 			id = &conn->ksnc_peer->ksnp_id;
 
 			/* Substitute process ID assigned at connection time */
@@ -1188,7 +1188,7 @@ struct ksock_conn_cb *
 		ksocknal_conn_addref(conn);     /* ++ref while parsing */
 
 		rc = lnet_parse(conn->ksnc_peer->ksnp_ni,
-				&conn->ksnc_msg.ksm_u.lnetmsg.ksnm_hdr,
+				&conn->ksnc_msg.ksm_u.lnetmsg,
 				lnet_nid_to_nid4(&conn->ksnc_peer->ksnp_id.nid),
 				conn, 0);
 		if (rc < 0) {
@@ -1225,7 +1225,7 @@ struct ksock_conn_cb *
 		if (!rc && conn->ksnc_msg.ksm_zc_cookies[0]) {
 			LASSERT(conn->ksnc_proto != &ksocknal_protocol_v1x);
 
-			lhdr = &conn->ksnc_msg.ksm_u.lnetmsg.ksnm_hdr;
+			lhdr = &conn->ksnc_msg.ksm_u.lnetmsg;
 			id = &conn->ksnc_peer->ksnp_id;
 
 			rc = conn->ksnc_proto->pro_handle_zcreq(conn,
diff --git a/net/lnet/klnds/socklnd/socklnd_proto.c b/net/lnet/klnds/socklnd/socklnd_proto.c
index c3ba070..2ecffb1 100644
--- a/net/lnet/klnds/socklnd/socklnd_proto.c
+++ b/net/lnet/klnds/socklnd/socklnd_proto.c
@@ -287,11 +287,12 @@
 
 	if (!tx || !tx->tx_lnetmsg) {
 		/* noop packet */
-		nob = offsetof(struct ksock_msg, ksm_u);
+		nob = sizeof(struct ksock_msg_hdr);
 	} else {
 		nob = tx->tx_lnetmsg->msg_len +
 		      ((conn->ksnc_proto == &ksocknal_protocol_v1x) ?
-		       sizeof(struct lnet_hdr) : sizeof(struct ksock_msg));
+		       0 : sizeof(struct ksock_msg_hdr) +
+			   sizeof(struct lnet_hdr));
 	}
 
 	/* default checking for typed connection */
@@ -325,9 +326,10 @@
 	int nob;
 
 	if (!tx || !tx->tx_lnetmsg)
-		nob = offsetof(struct ksock_msg, ksm_u);
+		nob = sizeof(struct ksock_msg_hdr);
 	else
-		nob = tx->tx_lnetmsg->msg_len + sizeof(struct ksock_msg);
+		nob = sizeof(struct ksock_msg_hdr) + sizeof(struct lnet_hdr) +
+		      tx->tx_lnetmsg->msg_len;
 
 	switch (conn->ksnc_type) {
 	default:
@@ -721,24 +723,33 @@
 static void
 ksocknal_pack_msg_v2(struct ksock_tx *tx)
 {
-	tx->tx_hdr.iov_base = &tx->tx_msg;
-
-	if (tx->tx_lnetmsg) {
-		LASSERT(tx->tx_msg.ksm_type != KSOCK_MSG_NOOP);
+	int hdr_size;
 
-		tx->tx_msg.ksm_u.lnetmsg.ksnm_hdr = tx->tx_lnetmsg->msg_hdr;
-		tx->tx_hdr.iov_len = sizeof(struct ksock_msg);
-		tx->tx_nob = sizeof(struct ksock_msg) + tx->tx_lnetmsg->msg_len;
-		tx->tx_resid = sizeof(struct ksock_msg) + tx->tx_lnetmsg->msg_len;
-	} else {
-		LASSERT(tx->tx_msg.ksm_type == KSOCK_MSG_NOOP);
+	tx->tx_hdr.iov_base = &tx->tx_msg;
 
-		tx->tx_hdr.iov_len = offsetof(struct ksock_msg, ksm_u.lnetmsg.ksnm_hdr);
-		tx->tx_nob = offsetof(struct ksock_msg,  ksm_u.lnetmsg.ksnm_hdr);
-		tx->tx_resid = offsetof(struct ksock_msg,  ksm_u.lnetmsg.ksnm_hdr);
+	switch (tx->tx_msg.ksm_type) {
+	case KSOCK_MSG_LNET:
+		LASSERT(tx->tx_lnetmsg);
+		hdr_size = sizeof(struct ksock_msg_hdr) +
+			   sizeof(struct lnet_hdr);
+
+		tx->tx_msg.ksm_u.lnetmsg = tx->tx_lnetmsg->msg_hdr;
+		tx->tx_hdr.iov_len = hdr_size;
+		tx->tx_nob = hdr_size + tx->tx_lnetmsg->msg_len;
+		tx->tx_resid = hdr_size + tx->tx_lnetmsg->msg_len;
+		break;
+	case KSOCK_MSG_NOOP:
+		LASSERT(!tx->tx_lnetmsg);
+		hdr_size = sizeof(struct ksock_msg_hdr);
+
+		tx->tx_hdr.iov_len = hdr_size;
+		tx->tx_nob = hdr_size;
+		tx->tx_resid = hdr_size;
+		break;
+	default:
+		LASSERT(0);
 	}
-	/*
-	 * Don't checksum before start sending, because packet can be
+	/* Don't checksum before start sending, because packet can be
 	 * piggybacked with ACK
 	 */
 }
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
