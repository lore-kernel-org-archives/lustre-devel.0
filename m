Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id CB38FC433F5
	for <lustre-devel@archiver.kernel.org>; Sun, 20 Mar 2022 13:31:54 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 2757621FA85;
	Sun, 20 Mar 2022 06:31:36 -0700 (PDT)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id B559A21EB66
 for <lustre-devel@lists.lustre.org>; Sun, 20 Mar 2022 06:31:15 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 38929EEE;
 Sun, 20 Mar 2022 09:31:08 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 355C1D6A26; Sun, 20 Mar 2022 09:31:08 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 20 Mar 2022 09:30:37 -0400
Message-Id: <1647783064-20688-24-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1647783064-20688-1-git-send-email-jsimmons@infradead.org>
References: <1647783064-20688-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 23/50] lnet: socklnd: add hello message
 version 4
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

KSOCK_PROTO_V4 uses a 'hello' message that contains
lnet_hdr_nid16 with 16 byte addresses

WC-bug-id: https://jira.whamcloud.com/browse/LU-10391
Lustre-commit: 7b31ef0bbac99bfd0 ("LU-10391 socklnd: add hello message version 4")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/43611
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/lib-lnet.h          |  26 ++++++
 include/linux/lnet/socklnd.h           |   5 ++
 include/uapi/linux/lnet/lnet-types.h   |   4 +
 net/lnet/klnds/socklnd/socklnd.h       |   1 +
 net/lnet/klnds/socklnd/socklnd_cb.c    |   9 +-
 net/lnet/klnds/socklnd/socklnd_proto.c | 154 ++++++++++++++++++++++++++++++++-
 6 files changed, 194 insertions(+), 5 deletions(-)

diff --git a/include/linux/lnet/lib-lnet.h b/include/linux/lnet/lib-lnet.h
index ce18897..0155111 100644
--- a/include/linux/lnet/lib-lnet.h
+++ b/include/linux/lnet/lib-lnet.h
@@ -507,6 +507,32 @@ static inline void lnet_hdr_to_nid4(const struct lnet_hdr *hdr,
 	hdr_nid4->msg = hdr->msg;
 }
 
+static inline void lnet_hdr_from_nid16(struct lnet_hdr *hdr,
+				       const struct lnet_hdr_nid16 *vhdr)
+{
+	const struct lnet_hdr *hdr16 = (void *)vhdr;
+
+	hdr->dest_nid = hdr16->dest_nid;
+	hdr->src_nid = hdr16->src_nid;
+	hdr->dest_pid = le32_to_cpu(hdr16->dest_pid);
+	hdr->src_pid = le32_to_cpu(hdr16->src_pid);
+	hdr->type = le32_to_cpu(hdr16->type);
+	hdr->payload_length = le32_to_cpu(hdr16->payload_length);
+}
+
+static inline void lnet_hdr_to_nid16(const struct lnet_hdr *hdr,
+				     struct lnet_hdr_nid16 *vhdr)
+{
+	struct lnet_hdr *hdr16 = (void *)vhdr;
+
+	hdr16->dest_nid = hdr->dest_nid;
+	hdr16->src_nid = hdr->src_nid;
+	hdr16->dest_pid = cpu_to_le32(hdr->dest_pid);
+	hdr16->src_pid = cpu_to_le32(hdr->src_pid);
+	hdr16->type = cpu_to_le32(hdr->type);
+	hdr16->payload_length = cpu_to_le32(hdr->payload_length);
+}
+
 extern struct lnet_lnd the_lolnd;
 extern int avoid_asym_router_failure;
 
diff --git a/include/linux/lnet/socklnd.h b/include/linux/lnet/socklnd.h
index ddfcf76..092ba6e 100644
--- a/include/linux/lnet/socklnd.h
+++ b/include/linux/lnet/socklnd.h
@@ -84,6 +84,10 @@ struct ksock_msg {
 		/* - nothing */
 		/* case ksm_kh.ksh_type == KSOCK_MSG_LNET */
 		struct lnet_hdr_nid4 lnetmsg_nid4;
+		/* case ksm_kh.ksh_type == KSOCK_MSG_LNET &&
+		 *      kshm_version >= KSOCK_PROTO_V4
+		 */
+		struct lnet_hdr_nid16 lnetmsg_nid16;
 	} __packed ksm_u;
 } __packed;
 #define ksm_type ksm_kh.ksh_type
@@ -95,5 +99,6 @@ struct ksock_msg {
  */
 #define KSOCK_PROTO_V2	2
 #define KSOCK_PROTO_V3	3
+#define KSOCK_PROTO_V4	4
 
 #endif
diff --git a/include/uapi/linux/lnet/lnet-types.h b/include/uapi/linux/lnet/lnet-types.h
index 4818271..eacc401 100644
--- a/include/uapi/linux/lnet/lnet-types.h
+++ b/include/uapi/linux/lnet/lnet-types.h
@@ -308,6 +308,10 @@ enum lnet_ins_pos {
  * @{
  */
 
+struct lnet_hdr_nid16 {
+	char	_bytes[sizeof(struct lnet_hdr)];
+} __attribute__((packed));
+
 /**
  * Event queue handler function type.
  *
diff --git a/net/lnet/klnds/socklnd/socklnd.h b/net/lnet/klnds/socklnd/socklnd.h
index 094f635..13abe20 100644
--- a/net/lnet/klnds/socklnd/socklnd.h
+++ b/net/lnet/klnds/socklnd/socklnd.h
@@ -500,6 +500,7 @@ struct ksock_proto {
 extern const struct ksock_proto ksocknal_protocol_v1x;
 extern const struct ksock_proto ksocknal_protocol_v2x;
 extern const struct ksock_proto ksocknal_protocol_v3x;
+extern const struct ksock_proto ksocknal_protocol_v4x;
 
 #define KSOCK_PROTO_V1_MAJOR	LNET_PROTO_TCP_VERSION_MAJOR
 #define KSOCK_PROTO_V1_MINOR	LNET_PROTO_TCP_VERSION_MINOR
diff --git a/net/lnet/klnds/socklnd/socklnd_cb.c b/net/lnet/klnds/socklnd/socklnd_cb.c
index c93f43f..af35c49 100644
--- a/net/lnet/klnds/socklnd/socklnd_cb.c
+++ b/net/lnet/klnds/socklnd/socklnd_cb.c
@@ -1925,11 +1925,11 @@ void ksocknal_write_callback(struct ksock_conn *conn)
 		if (!list_empty(&peer_ni->ksnp_conns)) {
 			conn = list_first_entry(&peer_ni->ksnp_conns,
 						struct ksock_conn, ksnc_list);
-			LASSERT(conn->ksnc_proto == &ksocknal_protocol_v3x);
+			LASSERT(conn->ksnc_proto == &ksocknal_protocol_v3x ||
+				conn->ksnc_proto == &ksocknal_protocol_v4x);
 		}
 
-		/*
-		 * take all the blocked packets while I've got the lock and
+		/* take all the blocked packets while I've got the lock and
 		 * complete below...
 		 */
 		list_splice_init(&peer_ni->ksnp_tx_queue, &zombies);
@@ -2297,7 +2297,8 @@ void ksocknal_write_callback(struct ksock_conn *conn)
 	if (list_empty(&peer_ni->ksnp_conns))
 		return 0;
 
-	if (peer_ni->ksnp_proto != &ksocknal_protocol_v3x)
+	if (peer_ni->ksnp_proto != &ksocknal_protocol_v3x &&
+	    peer_ni->ksnp_proto != &ksocknal_protocol_v4x)
 		return 0;
 
 	if (*ksocknal_tunables.ksnd_keepalive <= 0 ||
diff --git a/net/lnet/klnds/socklnd/socklnd_proto.c b/net/lnet/klnds/socklnd/socklnd_proto.c
index 783c62f..0a93d57 100644
--- a/net/lnet/klnds/socklnd/socklnd_proto.c
+++ b/net/lnet/klnds/socklnd/socklnd_proto.c
@@ -365,6 +365,51 @@
 	}
 }
 
+static int
+ksocknal_match_tx_v4(struct ksock_conn *conn, struct ksock_tx *tx, int nonblk)
+{
+	int nob;
+
+	if (!tx || !tx->tx_lnetmsg)
+		nob = sizeof(struct ksock_msg_hdr);
+	else
+		nob = sizeof(struct ksock_msg_hdr) +
+			sizeof(struct lnet_hdr_nid16) +
+			tx->tx_lnetmsg->msg_len;
+
+	switch (conn->ksnc_type) {
+	default:
+		CERROR("ksnc_type bad: %u\n", conn->ksnc_type);
+		LBUG();
+	case SOCKLND_CONN_ANY:
+		return SOCKNAL_MATCH_NO;
+
+	case SOCKLND_CONN_ACK:
+		if (nonblk)
+			return SOCKNAL_MATCH_YES;
+		else if (!tx || !tx->tx_lnetmsg)
+			return SOCKNAL_MATCH_MAY;
+		else
+			return SOCKNAL_MATCH_NO;
+
+	case SOCKLND_CONN_BULK_OUT:
+		if (nonblk)
+			return SOCKNAL_MATCH_NO;
+		else if (nob < *ksocknal_tunables.ksnd_min_bulk)
+			return SOCKNAL_MATCH_MAY;
+		else
+			return SOCKNAL_MATCH_YES;
+
+	case SOCKLND_CONN_CONTROL:
+		if (nonblk)
+			return SOCKNAL_MATCH_NO;
+		else if (nob >= *ksocknal_tunables.ksnd_min_bulk)
+			return SOCKNAL_MATCH_MAY;
+		else
+			return SOCKNAL_MATCH_YES;
+	}
+}
+
 /* (Sink) handle incoming ZC request from sender */
 static int
 ksocknal_handle_zcreq(struct ksock_conn *c, u64 cookie, int remote)
@@ -425,7 +470,8 @@
 	count = (cookie1 > cookie2) ? 2 : (cookie2 - cookie1 + 1);
 
 	if (cookie2 == SOCKNAL_KEEPALIVE_PING &&
-	    conn->ksnc_proto == &ksocknal_protocol_v3x) {
+	    (conn->ksnc_proto == &ksocknal_protocol_v3x ||
+	     conn->ksnc_proto == &ksocknal_protocol_v4x)) {
 		/* keepalive PING for V3.x, just ignore it */
 		return count == 1 ? 0 : -EPROTO;
 	}
@@ -596,6 +642,24 @@
 }
 
 static int
+ksocknal_send_hello_v4(struct ksock_conn *conn, struct ksock_hello_msg *hello)
+{
+	struct socket *sock = conn->ksnc_sock;
+	int rc;
+
+	hello->kshm_magic   = LNET_PROTO_MAGIC;
+	hello->kshm_version = conn->ksnc_proto->pro_version;
+
+	rc = lnet_sock_write(sock, hello, sizeof(*hello),
+			     lnet_acceptor_timeout());
+
+	if (rc != 0)
+		CNETERR("Error %d sending HELLO hdr to %pISp\n",
+			rc, &conn->ksnc_peeraddr);
+	return rc;
+}
+
+static int
 ksocknal_recv_hello_v1(struct ksock_conn *conn, struct ksock_hello_msg *hello,
 		       int timeout)
 {
@@ -750,6 +814,40 @@
 	return 0;
 }
 
+static int
+ksocknal_recv_hello_v4(struct ksock_conn *conn, struct ksock_hello_msg *hello,
+		       int timeout)
+{
+	struct socket *sock = conn->ksnc_sock;
+	int rc;
+
+	if (hello->kshm_magic == LNET_PROTO_MAGIC)
+		conn->ksnc_flip = 0;
+	else
+		conn->ksnc_flip = 1;
+
+	rc = lnet_sock_read(sock, &hello->kshm_src_nid,
+			    sizeof(*hello) -
+			    offsetof(struct ksock_hello_msg, kshm_src_nid),
+			    timeout);
+	if (rc) {
+		CERROR("Error %d reading HELLO from %pIS\n",
+		       rc, &conn->ksnc_peeraddr);
+		LASSERT(rc < 0 && rc != -EALREADY);
+		return rc;
+	}
+
+	if (conn->ksnc_flip) {
+		__swab32s(&hello->kshm_src_pid);
+		__swab32s(&hello->kshm_dst_pid);
+		__swab64s(&hello->kshm_src_incarnation);
+		__swab64s(&hello->kshm_dst_incarnation);
+		__swab32s(&hello->kshm_ctype);
+	}
+
+	return 0;
+}
+
 static void
 ksocknal_pack_msg_v1(struct ksock_tx *tx)
 {
@@ -802,6 +900,41 @@
 }
 
 static void
+ksocknal_pack_msg_v4(struct ksock_tx *tx)
+{
+	int hdr_size;
+
+	tx->tx_hdr.iov_base = (void *)&tx->tx_msg;
+
+	switch (tx->tx_msg.ksm_type) {
+	case KSOCK_MSG_LNET:
+		LASSERT(tx->tx_lnetmsg);
+		hdr_size = (sizeof(struct ksock_msg_hdr) +
+				sizeof(struct lnet_hdr_nid16));
+
+		lnet_hdr_to_nid16(&tx->tx_lnetmsg->msg_hdr,
+				  &tx->tx_msg.ksm_u.lnetmsg_nid16);
+		tx->tx_hdr.iov_len = hdr_size;
+		tx->tx_resid = hdr_size + tx->tx_lnetmsg->msg_len;
+		tx->tx_nob = hdr_size + tx->tx_lnetmsg->msg_len;
+		break;
+	case KSOCK_MSG_NOOP:
+		LASSERT(!tx->tx_lnetmsg);
+		hdr_size = sizeof(struct ksock_msg_hdr);
+
+		tx->tx_hdr.iov_len = hdr_size;
+		tx->tx_resid = hdr_size;
+		tx->tx_nob = hdr_size;
+		break;
+	default:
+		LASSERT(0);
+	}
+	/* Don't checksum before start sending, because packet can be
+	 * piggybacked with ACK
+	 */
+}
+
+static void
 ksocknal_unpack_msg_v1(struct ksock_msg *msg, struct lnet_hdr *hdr)
 {
 	msg->ksm_csum = 0;
@@ -817,6 +950,12 @@
 	lnet_hdr_from_nid4(hdr, &msg->ksm_u.lnetmsg_nid4);
 }
 
+static void
+ksocknal_unpack_msg_v4(struct ksock_msg *msg, struct lnet_hdr *hdr)
+{
+	lnet_hdr_from_nid16(hdr, &msg->ksm_u.lnetmsg_nid16);
+}
+
 const struct ksock_proto ksocknal_protocol_v1x = {
 	.pro_version		= KSOCK_PROTO_V1,
 	.pro_send_hello		= ksocknal_send_hello_v1,
@@ -855,3 +994,16 @@
 	.pro_handle_zcack	= ksocknal_handle_zcack,
 	.pro_match_tx		= ksocknal_match_tx_v3
 };
+
+const struct ksock_proto ksocknal_protocol_v4x = {
+	.pro_version		= KSOCK_PROTO_V4,
+	.pro_send_hello		= ksocknal_send_hello_v4,
+	.pro_recv_hello		= ksocknal_recv_hello_v4,
+	.pro_pack		= ksocknal_pack_msg_v4,
+	.pro_unpack		= ksocknal_unpack_msg_v4,
+	.pro_queue_tx_msg	= ksocknal_queue_tx_msg_v2,
+	.pro_queue_tx_zcack	= ksocknal_queue_tx_zcack_v3,
+	.pro_handle_zcreq	= ksocknal_handle_zcreq,
+	.pro_handle_zcack	= ksocknal_handle_zcack,
+	.pro_match_tx		= ksocknal_match_tx_v4,
+};
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
