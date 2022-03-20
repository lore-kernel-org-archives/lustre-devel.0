Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 419C9C433F5
	for <lustre-devel@archiver.kernel.org>; Sun, 20 Mar 2022 13:31:44 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 1D1F321FA4D;
	Sun, 20 Mar 2022 06:31:30 -0700 (PDT)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 68C3621CB5B
 for <lustre-devel@lists.lustre.org>; Sun, 20 Mar 2022 06:31:13 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 1C749EE2;
 Sun, 20 Mar 2022 09:31:08 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 19E40DF88F; Sun, 20 Mar 2022 09:31:08 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 20 Mar 2022 09:30:29 -0400
Message-Id: <1647783064-20688-16-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1647783064-20688-1-git-send-email-jsimmons@infradead.org>
References: <1647783064-20688-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 15/50] lnet: separate lnet_hdr in msg from
 that in lnd.
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

The lnet_hdr stored in an lnet_msg has fields which are sometimes in
le byte order and sometimes in host byte order.

The various lnds need all these fields to be in le byte order for
transmission or reception over the network.

To support larger (IPv6) NIDs, we will need the lnet_hdr in lnet_msg
to store these NIDs, but the lnd will need both 4byte-addr and 16-byte
lnds depending on protocol negotiation.

This patch separates out the two to make the conversion easier to
follow.

'struct lnet_hdr' is now used within common lnet code, and is not
stored in network buffers.

lnd_send will convert from 'struct lnet_hdr' to whatever is required
in the network buffer.  When lnet_parse() is called, the network
buffer will be converted to a 'struct lnet_hdr' first, and that will
be passed to lnet_parse().

The common fields of 'struct lnet_hdr' are always in host byte order.
The command specific fields (now in 'union lnet_cmd_hdr') have not
been changed and are sometimes host-byte-order and sometimes
l3-byte-order.

The new 'struct lnet_hdr_nid4' is used in network buffers.  It is
opaque - there are no subfields to access.  Very few places in the lnd
code want to access fields anyway.

New functions lnet_hdr_to_nid4() and lnet_hdr_from_nid4() can
convert between the lnet_hdr_nid4 to the internal lnet_hdr.

'struct _lnet_hdr_nid4' is provided to access fields inside 'struct
lnet_hdr_nid4' when that is really needed.  It is used by the to/from
functions and a couple of other places.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10391
Lustre-commit: 4ea5cf154a4663a73 ("LU-10391 lnet: separate lnet_hdr in msg from that in lnd.")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/43603
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Chris Horn <chris.horn@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/lib-lnet.h          | 30 +++++++++++
 include/linux/lnet/socklnd.h           |  2 +-
 include/uapi/linux/lnet/lnet-idl.h     | 40 +++++++++++---
 net/lnet/klnds/o2iblnd/o2iblnd-idl.h   |  6 +--
 net/lnet/klnds/o2iblnd/o2iblnd_cb.c    | 22 ++++----
 net/lnet/klnds/socklnd/socklnd.h       |  3 +-
 net/lnet/klnds/socklnd/socklnd_cb.c    | 42 ++++++++-------
 net/lnet/klnds/socklnd/socklnd_proto.c | 37 +++++++------
 net/lnet/lnet/api-ni.c                 | 96 +++++++++++++++++-----------------
 net/lnet/lnet/lib-move.c               | 43 +++++++--------
 net/lnet/lnet/lib-msg.c                |  4 +-
 net/lnet/lnet/net_fault.c              | 12 ++---
 12 files changed, 198 insertions(+), 139 deletions(-)

diff --git a/include/linux/lnet/lib-lnet.h b/include/linux/lnet/lib-lnet.h
index 9441265..3c3a9d2 100644
--- a/include/linux/lnet/lib-lnet.h
+++ b/include/linux/lnet/lib-lnet.h
@@ -477,6 +477,36 @@ struct lnet_ni *
 		((1U << the_lnet.ln_remote_nets_hbits) - 1)];
 }
 
+static inline void lnet_hdr_from_nid4(struct lnet_hdr *hdr,
+				      const struct lnet_hdr_nid4 *vhdr)
+{
+	const struct _lnet_hdr_nid4 *hdr_nid4 = (void *)vhdr;
+
+	hdr->dest_nid = le64_to_cpu(hdr_nid4->dest_nid);
+	hdr->src_nid = le64_to_cpu(hdr_nid4->src_nid);
+	hdr->dest_pid = le32_to_cpu(hdr_nid4->dest_pid);
+	hdr->src_pid = le32_to_cpu(hdr_nid4->src_pid);
+	hdr->type = le32_to_cpu(hdr_nid4->type);
+	hdr->payload_length = le32_to_cpu(hdr_nid4->payload_length);
+
+	hdr->msg = hdr_nid4->msg;
+}
+
+static inline void lnet_hdr_to_nid4(const struct lnet_hdr *hdr,
+				    struct lnet_hdr_nid4 *vhdr)
+{
+	struct _lnet_hdr_nid4 *hdr_nid4 = (void *)vhdr;
+
+	hdr_nid4->dest_nid = cpu_to_le64(hdr->dest_nid);
+	hdr_nid4->src_nid = cpu_to_le64(hdr->src_nid);
+	hdr_nid4->dest_pid = cpu_to_le32(hdr->dest_pid);
+	hdr_nid4->src_pid = cpu_to_le32(hdr->src_pid);
+	hdr_nid4->type = cpu_to_le32(hdr->type);
+	hdr_nid4->payload_length = cpu_to_le32(hdr->payload_length);
+
+	hdr_nid4->msg = hdr->msg;
+}
+
 extern struct lnet_lnd the_lolnd;
 extern int avoid_asym_router_failure;
 
diff --git a/include/linux/lnet/socklnd.h b/include/linux/lnet/socklnd.h
index 97ae0e2..025112b 100644
--- a/include/linux/lnet/socklnd.h
+++ b/include/linux/lnet/socklnd.h
@@ -69,7 +69,7 @@ struct ksock_msg {
 		/* case ksm_kh.ksh_type == KSOCK_MSG_NOOP */
 		/* - nothing */
 		/* case ksm_kh.ksh_type == KSOCK_MSG_LNET */
-		struct lnet_hdr lnetmsg;
+		struct lnet_hdr_nid4 lnetmsg_nid4;
 	} __packed ksm_u;
 } __packed;
 #define ksm_type ksm_kh.ksh_type
diff --git a/include/uapi/linux/lnet/lnet-idl.h b/include/uapi/linux/lnet/lnet-idl.h
index b14723e..a19da76 100644
--- a/include/uapi/linux/lnet/lnet-idl.h
+++ b/include/uapi/linux/lnet/lnet-idl.h
@@ -142,7 +142,32 @@ struct lnet_hello {
 	__u32			type;
 } __attribute__((packed));
 
+union lnet_cmd_hdr {
+	struct lnet_ack		ack;
+	struct lnet_put		put;
+	struct lnet_get		get;
+	struct lnet_reply	reply;
+	struct lnet_hello	hello;
+} __attribute__((packed));
+
+/* This is used for message headers that lnet code is manipulating.
+ *  All fields before the union are in host-byte-order.
+ */
 struct lnet_hdr {
+	lnet_nid_t		dest_nid;
+	lnet_nid_t		src_nid;
+	lnet_pid_t		dest_pid;
+	lnet_pid_t		src_pid;
+	__u32			type;		/* enum lnet_msg_type */
+	__u32			payload_length;	/* payload data to follow */
+	/*<------__u64 aligned------->*/
+	union lnet_cmd_hdr	msg;
+} __attribute__((packed));
+
+/* This is used to support conversion between an lnet_hdr and
+ * the content of a network message.
+ */
+struct _lnet_hdr_nid4 {
 	lnet_nid_t	dest_nid;
 	lnet_nid_t	src_nid;
 	lnet_pid_t	dest_pid;
@@ -150,13 +175,14 @@ struct lnet_hdr {
 	__u32		type;		/* enum lnet_msg_type */
 	__u32		payload_length;	/* payload data to follow */
 	/*<------__u64 aligned------->*/
-	union {
-		struct lnet_ack		ack;
-		struct lnet_put		put;
-		struct lnet_get		get;
-		struct lnet_reply	reply;
-		struct lnet_hello	hello;
-	} msg;
+	union lnet_cmd_hdr msg;
+} __attribute__((packed));
+
+/* This is stored in a network message buffer.  Content cannot be accessed
+ * without converting to an lnet_hdr.
+ */
+struct lnet_hdr_nid4 {
+	char	_bytes[sizeof(struct _lnet_hdr_nid4)];
 } __attribute__((packed));
 
 /* A HELLO message contains a magic number and protocol version
diff --git a/net/lnet/klnds/o2iblnd/o2iblnd-idl.h b/net/lnet/klnds/o2iblnd/o2iblnd-idl.h
index f8972d16..7f6a5b61 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd-idl.h
+++ b/net/lnet/klnds/o2iblnd/o2iblnd-idl.h
@@ -50,7 +50,7 @@ struct kib_connparams {
 } __packed;
 
 struct kib_immediate_msg {
-	struct lnet_hdr		ibim_hdr;	/* portals header */
+	struct lnet_hdr_nid4	ibim_hdr;	/* portals header */
 	char			ibim_payload[0];/* piggy-backed payload */
 } __packed;
 
@@ -66,7 +66,7 @@ struct kib_rdma_desc {
 } __packed;
 
 struct kib_putreq_msg {
-	struct lnet_hdr		ibprm_hdr;	/* portals header */
+	struct lnet_hdr_nid4	ibprm_hdr;	/* portals header */
 	u64			ibprm_cookie;	/* opaque completion cookie */
 } __packed;
 
@@ -77,7 +77,7 @@ struct kib_putack_msg {
 } __packed;
 
 struct kib_get_msg {
-	struct lnet_hdr		ibgm_hdr;	/* portals header */
+	struct lnet_hdr_nid4	ibgm_hdr;	/* portals header */
 	u64			ibgm_cookie;	/* opaque completion cookie */
 	struct kib_rdma_desc	ibgm_rd;	/* rdma descriptor */
 } __packed;
diff --git a/net/lnet/klnds/o2iblnd/o2iblnd_cb.c b/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
index d657366..8f24e26 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -322,6 +322,7 @@ static int kiblnd_init_rdma(struct kib_conn *conn, struct kib_tx *tx, int type,
 	int rc = 0;
 	int rc2;
 	int post_credit;
+	struct lnet_hdr hdr;
 
 	LASSERT(conn->ibc_state >= IBLND_CONN_ESTABLISHED);
 
@@ -380,16 +381,16 @@ static int kiblnd_init_rdma(struct kib_conn *conn, struct kib_tx *tx, int type,
 
 	case IBLND_MSG_IMMEDIATE:
 		post_credit = IBLND_POSTRX_DONT_POST;
-		rc = lnet_parse(ni, &msg->ibm_u.immediate.ibim_hdr,
-				msg->ibm_srcnid, rx, 0);
+		lnet_hdr_from_nid4(&hdr, &msg->ibm_u.immediate.ibim_hdr);
+		rc = lnet_parse(ni, &hdr, msg->ibm_srcnid, rx, 0);
 		if (rc < 0)		/* repost on error */
 			post_credit = IBLND_POSTRX_PEER_CREDIT;
 		break;
 
 	case IBLND_MSG_PUT_REQ:
 		post_credit = IBLND_POSTRX_DONT_POST;
-		rc = lnet_parse(ni, &msg->ibm_u.putreq.ibprm_hdr,
-				msg->ibm_srcnid, rx, 1);
+		lnet_hdr_from_nid4(&hdr, &msg->ibm_u.putreq.ibprm_hdr);
+		rc = lnet_parse(ni, &hdr, msg->ibm_srcnid, rx, 1);
 		if (rc < 0)		/* repost on error */
 			post_credit = IBLND_POSTRX_PEER_CREDIT;
 		break;
@@ -452,8 +453,8 @@ static int kiblnd_init_rdma(struct kib_conn *conn, struct kib_tx *tx, int type,
 
 	case IBLND_MSG_GET_REQ:
 		post_credit = IBLND_POSTRX_DONT_POST;
-		rc = lnet_parse(ni, &msg->ibm_u.get.ibgm_hdr,
-				msg->ibm_srcnid, rx, 1);
+		lnet_hdr_from_nid4(&hdr, &msg->ibm_u.get.ibgm_hdr);
+		rc = lnet_parse(ni, &hdr, msg->ibm_srcnid, rx, 1);
 		if (rc < 0)		/* repost on error */
 			post_credit = IBLND_POSTRX_PEER_CREDIT;
 		break;
@@ -1595,7 +1596,7 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 
 		nob = offsetof(struct kib_get_msg, ibgm_rd.rd_frags[rd->rd_nfrags]);
 		ibmsg->ibm_u.get.ibgm_cookie = tx->tx_cookie;
-		ibmsg->ibm_u.get.ibgm_hdr = *hdr;
+		lnet_hdr_to_nid4(hdr, &ibmsg->ibm_u.get.ibgm_hdr);
 
 		kiblnd_init_tx_msg(ni, tx, IBLND_MSG_GET_REQ, nob);
 
@@ -1630,7 +1631,7 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 			return -EIO;
 		}
 
-		ibmsg->ibm_u.putreq.ibprm_hdr = *hdr;
+		lnet_hdr_to_nid4(hdr, &ibmsg->ibm_u.putreq.ibprm_hdr);
 		ibmsg->ibm_u.putreq.ibprm_cookie = tx->tx_cookie;
 		kiblnd_init_tx_msg(ni, tx, IBLND_MSG_PUT_REQ, sizeof(struct kib_putreq_msg));
 
@@ -1647,7 +1648,7 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 		 <= IBLND_MSG_SIZE);
 
 	ibmsg = tx->tx_msg;
-	ibmsg->ibm_u.immediate.ibim_hdr = *hdr;
+	lnet_hdr_to_nid4(hdr, &ibmsg->ibm_u.immediate.ibim_hdr);
 
 	rc = copy_from_iter(&ibmsg->ibm_u.immediate.ibim_payload, payload_nob,
 			    &from);
@@ -1757,10 +1758,11 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 		LBUG();
 
 	case IBLND_MSG_IMMEDIATE:
+		/* fallthrough */
 		nob = offsetof(struct kib_msg, ibm_u.immediate.ibim_payload[rlen]);
 		if (nob > rx->rx_nob) {
 			CERROR("Immediate message from %s too big: %d(%d)\n",
-			       libcfs_nid2str(rxmsg->ibm_u.immediate.ibim_hdr.src_nid),
+			       libcfs_nid2str(lntmsg->msg_hdr.src_nid),
 			       nob, rx->rx_nob);
 			rc = -EPROTO;
 			break;
diff --git a/net/lnet/klnds/socklnd/socklnd.h b/net/lnet/klnds/socklnd/socklnd.h
index 4607ef7..5d0be68 100644
--- a/net/lnet/klnds/socklnd/socklnd.h
+++ b/net/lnet/klnds/socklnd/socklnd.h
@@ -355,7 +355,8 @@ struct ksock_conn {
 							 * V2.x message takes the
 							 * whole struct
 							 * V1.x message is a bare
-							 * struct lnet_hdr, it's stored in
+							 * struct lnet_hdr_nid4, it's
+							 * stored in
 							 * ksnc_msg.ksm_u.lnetmsg
 							 */
 	/* WRITER */
diff --git a/net/lnet/klnds/socklnd/socklnd_cb.c b/net/lnet/klnds/socklnd/socklnd_cb.c
index dede642..40f3e79 100644
--- a/net/lnet/klnds/socklnd/socklnd_cb.c
+++ b/net/lnet/klnds/socklnd/socklnd_cb.c
@@ -1006,21 +1006,23 @@ struct ksock_conn_cb *
 		case  KSOCK_PROTO_V2:
 		case  KSOCK_PROTO_V3:
 			conn->ksnc_rx_state = SOCKNAL_RX_KSM_HEADER;
-			kvec->iov_base = &conn->ksnc_msg;
-			kvec->iov_len = sizeof(struct ksock_msg_hdr);
 			conn->ksnc_rx_nob_left = sizeof(struct ksock_msg_hdr);
+
+			kvec->iov_base = &conn->ksnc_msg;
+			kvec->iov_len = conn->ksnc_rx_nob_left;
 			iov_iter_kvec(&conn->ksnc_rx_to, READ, kvec, 1,
-				      sizeof(struct ksock_msg_hdr));
+				      kvec->iov_len);
 			break;
 
 		case KSOCK_PROTO_V1:
-			/* Receiving bare struct lnet_hdr */
+			/* Receiving bare struct lnet_hdr_nid4 */
 			conn->ksnc_rx_state = SOCKNAL_RX_LNET_HEADER;
-			kvec->iov_base = &conn->ksnc_msg.ksm_u.lnetmsg;
-			kvec->iov_len = sizeof(struct lnet_hdr);
-			conn->ksnc_rx_nob_left = sizeof(struct lnet_hdr);
+			conn->ksnc_rx_nob_left = sizeof(struct lnet_hdr_nid4);
+
+			kvec->iov_base = &conn->ksnc_msg.ksm_u.lnetmsg_nid4;
+			kvec->iov_len = conn->ksnc_rx_nob_left;
 			iov_iter_kvec(&conn->ksnc_rx_to, READ, kvec, 1,
-				      sizeof(struct lnet_hdr));
+				      kvec->iov_len);
 			break;
 
 		default:
@@ -1059,8 +1061,9 @@ struct ksock_conn_cb *
 ksocknal_process_receive(struct ksock_conn *conn)
 {
 	struct kvec *kvec = conn->ksnc_rx_iov_space;
-	struct lnet_hdr *lhdr;
+	struct _lnet_hdr_nid4 *lhdr;
 	struct lnet_processid *id;
+	struct lnet_hdr hdr;
 	int rc;
 
 	LASSERT(refcount_read(&conn->ksnc_conn_refcount) > 0);
@@ -1151,13 +1154,12 @@ struct ksock_conn_cb *
 
 		case KSOCK_MSG_LNET:
 			conn->ksnc_rx_state = SOCKNAL_RX_LNET_HEADER;
-			conn->ksnc_rx_nob_left = sizeof(struct lnet_hdr);
-
-			kvec->iov_base = &conn->ksnc_msg.ksm_u.lnetmsg;
-			kvec->iov_len = sizeof(struct lnet_hdr);
+			conn->ksnc_rx_nob_left = sizeof(struct lnet_hdr_nid4);
 
+			kvec->iov_base = &conn->ksnc_msg.ksm_u.lnetmsg_nid4;
+			kvec->iov_len = conn->ksnc_rx_nob_left;
 			iov_iter_kvec(&conn->ksnc_rx_to, READ, kvec, 1,
-				      sizeof(struct lnet_hdr));
+				      kvec->iov_len);
 
 			goto again;     /* read lnet header now */
 
@@ -1174,21 +1176,21 @@ struct ksock_conn_cb *
 		/* unpack message header */
 		conn->ksnc_proto->pro_unpack(&conn->ksnc_msg);
 
+		lnet_hdr_from_nid4(&hdr, &conn->ksnc_msg.ksm_u.lnetmsg_nid4);
+
 		if (conn->ksnc_peer->ksnp_id.pid & LNET_PID_USERFLAG) {
 			/* Userspace peer_ni */
-			lhdr = &conn->ksnc_msg.ksm_u.lnetmsg;
 			id = &conn->ksnc_peer->ksnp_id;
 
 			/* Substitute process ID assigned at connection time */
-			lhdr->src_pid = cpu_to_le32(id->pid);
-			lhdr->src_nid = cpu_to_le64(lnet_nid_to_nid4(&id->nid));
+			hdr.src_pid = id->pid;
+			hdr.src_nid = lnet_nid_to_nid4(&id->nid);
 		}
 
 		conn->ksnc_rx_state = SOCKNAL_RX_PARSE;
 		ksocknal_conn_addref(conn);     /* ++ref while parsing */
 
-		rc = lnet_parse(conn->ksnc_peer->ksnp_ni,
-				&conn->ksnc_msg.ksm_u.lnetmsg,
+		rc = lnet_parse(conn->ksnc_peer->ksnp_ni, &hdr,
 				lnet_nid_to_nid4(&conn->ksnc_peer->ksnp_id.nid),
 				conn, 0);
 		if (rc < 0) {
@@ -1225,7 +1227,7 @@ struct ksock_conn_cb *
 		if (!rc && conn->ksnc_msg.ksm_zc_cookies[0]) {
 			LASSERT(conn->ksnc_proto != &ksocknal_protocol_v1x);
 
-			lhdr = &conn->ksnc_msg.ksm_u.lnetmsg;
+			lhdr = (void *)&conn->ksnc_msg.ksm_u.lnetmsg_nid4;
 			id = &conn->ksnc_peer->ksnp_id;
 
 			rc = conn->ksnc_proto->pro_handle_zcreq(conn,
diff --git a/net/lnet/klnds/socklnd/socklnd_proto.c b/net/lnet/klnds/socklnd/socklnd_proto.c
index 2ecffb1..20a582b 100644
--- a/net/lnet/klnds/socklnd/socklnd_proto.c
+++ b/net/lnet/klnds/socklnd/socklnd_proto.c
@@ -292,7 +292,7 @@
 		nob = tx->tx_lnetmsg->msg_len +
 		      ((conn->ksnc_proto == &ksocknal_protocol_v1x) ?
 		       0 : sizeof(struct ksock_msg_hdr) +
-			   sizeof(struct lnet_hdr));
+			   sizeof(struct lnet_hdr_nid4));
 	}
 
 	/* default checking for typed connection */
@@ -328,7 +328,8 @@
 	if (!tx || !tx->tx_lnetmsg)
 		nob = sizeof(struct ksock_msg_hdr);
 	else
-		nob = sizeof(struct ksock_msg_hdr) + sizeof(struct lnet_hdr) +
+		nob = sizeof(struct ksock_msg_hdr) +
+		      sizeof(struct lnet_hdr_nid4) +
 		      tx->tx_lnetmsg->msg_len;
 
 	switch (conn->ksnc_type) {
@@ -460,23 +461,23 @@
 ksocknal_send_hello_v1(struct ksock_conn *conn, struct ksock_hello_msg *hello)
 {
 	struct socket *sock = conn->ksnc_sock;
-	struct lnet_hdr *hdr;
+	struct _lnet_hdr_nid4 *hdr;
 	struct lnet_magicversion *hmv;
 	int rc;
 	int i;
 
-	BUILD_BUG_ON(sizeof(struct lnet_magicversion) != offsetof(struct lnet_hdr, src_nid));
+	BUILD_BUG_ON(sizeof(struct lnet_magicversion) !=
+		     offsetof(struct _lnet_hdr_nid4, src_nid));
 
 	hdr = kzalloc(sizeof(*hdr), GFP_NOFS);
 	if (!hdr) {
-		CERROR("Can't allocate struct lnet_hdr\n");
+		CERROR("Can't allocate struct lnet_hdr_nid4\n");
 		return -ENOMEM;
 	}
 
 	hmv = (struct lnet_magicversion *)&hdr->dest_nid;
 
-	/*
-	 * Re-organize V2.x message header to V1.x (struct lnet_hdr)
+	/* Re-organize V2.x message header to V1.x (struct lnet_hdr)
 	 * header and send out
 	 */
 	hmv->magic = cpu_to_le32(LNET_PROTO_TCP_MAGIC);
@@ -569,18 +570,19 @@
 		       int timeout)
 {
 	struct socket *sock = conn->ksnc_sock;
-	struct lnet_hdr *hdr;
+	struct _lnet_hdr_nid4 *hdr;
 	int rc;
 	int i;
 
 	hdr = kzalloc(sizeof(*hdr), GFP_NOFS);
 	if (!hdr) {
-		CERROR("Can't allocate struct lnet_hdr\n");
+		CERROR("Can't allocate struct lnet_hdr_nid4\n");
 		return -ENOMEM;
 	}
 
 	rc = lnet_sock_read(sock, &hdr->src_nid,
-			    sizeof(*hdr) - offsetof(struct lnet_hdr, src_nid),
+			    sizeof(*hdr) - offsetof(struct _lnet_hdr_nid4,
+						    src_nid),
 			    timeout);
 	if (rc) {
 		CERROR("Error %d reading rest of HELLO hdr from %pIS\n",
@@ -713,11 +715,13 @@
 	LASSERT(tx->tx_msg.ksm_type != KSOCK_MSG_NOOP);
 	LASSERT(tx->tx_lnetmsg);
 
-	tx->tx_hdr.iov_base = &tx->tx_lnetmsg->msg_hdr;
-	tx->tx_hdr.iov_len = sizeof(struct lnet_hdr);
+	lnet_hdr_to_nid4(&tx->tx_lnetmsg->msg_hdr,
+			 &tx->tx_msg.ksm_u.lnetmsg_nid4);
+	tx->tx_hdr.iov_base = (void *)&tx->tx_msg.ksm_u.lnetmsg_nid4;
+	tx->tx_hdr.iov_len = sizeof(struct lnet_hdr_nid4);
 
-	tx->tx_nob = tx->tx_lnetmsg->msg_len + sizeof(struct lnet_hdr);
-	tx->tx_resid = tx->tx_lnetmsg->msg_len + sizeof(struct lnet_hdr);
+	tx->tx_nob = tx->tx_lnetmsg->msg_len + sizeof(struct lnet_hdr_nid4);
+	tx->tx_resid = tx->tx_nob;
 }
 
 static void
@@ -731,9 +735,10 @@
 	case KSOCK_MSG_LNET:
 		LASSERT(tx->tx_lnetmsg);
 		hdr_size = sizeof(struct ksock_msg_hdr) +
-			   sizeof(struct lnet_hdr);
+			   sizeof(struct lnet_hdr_nid4);
 
-		tx->tx_msg.ksm_u.lnetmsg = tx->tx_lnetmsg->msg_hdr;
+		lnet_hdr_to_nid4(&tx->tx_lnetmsg->msg_hdr,
+				 &tx->tx_msg.ksm_u.lnetmsg_nid4);
 		tx->tx_hdr.iov_len = hdr_size;
 		tx->tx_nob = hdr_size + tx->tx_lnetmsg->msg_len;
 		tx->tx_resid = hdr_size + tx->tx_lnetmsg->msg_len;
diff --git a/net/lnet/lnet/api-ni.c b/net/lnet/lnet/api-ni.c
index d61c03a..2221b19 100644
--- a/net/lnet/lnet/api-ni.c
+++ b/net/lnet/lnet/api-ni.c
@@ -702,64 +702,64 @@ static void lnet_assert_wire_constants(void)
 	BUILD_BUG_ON((int)offsetof(struct lnet_magicversion, version_minor) != 6);
 	BUILD_BUG_ON((int)sizeof(((struct lnet_magicversion *)0)->version_minor) != 2);
 
-	/* Checks for struct struct lnet_hdr */
-	BUILD_BUG_ON((int)sizeof(struct lnet_hdr) != 72);
-	BUILD_BUG_ON((int)offsetof(struct lnet_hdr, dest_nid) != 0);
-	BUILD_BUG_ON((int)sizeof(((struct lnet_hdr *)0)->dest_nid) != 8);
-	BUILD_BUG_ON((int)offsetof(struct lnet_hdr, src_nid) != 8);
-	BUILD_BUG_ON((int)sizeof(((struct lnet_hdr *)0)->src_nid) != 8);
-	BUILD_BUG_ON((int)offsetof(struct lnet_hdr, dest_pid) != 16);
-	BUILD_BUG_ON((int)sizeof(((struct lnet_hdr *)0)->dest_pid) != 4);
-	BUILD_BUG_ON((int)offsetof(struct lnet_hdr, src_pid) != 20);
-	BUILD_BUG_ON((int)sizeof(((struct lnet_hdr *)0)->src_pid) != 4);
-	BUILD_BUG_ON((int)offsetof(struct lnet_hdr, type) != 24);
-	BUILD_BUG_ON((int)sizeof(((struct lnet_hdr *)0)->type) != 4);
-	BUILD_BUG_ON((int)offsetof(struct lnet_hdr, payload_length) != 28);
-	BUILD_BUG_ON((int)sizeof(((struct lnet_hdr *)0)->payload_length) != 4);
-	BUILD_BUG_ON((int)offsetof(struct lnet_hdr, msg) != 32);
-	BUILD_BUG_ON((int)sizeof(((struct lnet_hdr *)0)->msg) != 40);
+	/* Checks for struct _lnet_hdr_nid4 */
+	BUILD_BUG_ON((int)sizeof(struct _lnet_hdr_nid4) != 72);
+	BUILD_BUG_ON((int)offsetof(struct _lnet_hdr_nid4, dest_nid) != 0);
+	BUILD_BUG_ON((int)sizeof(((struct _lnet_hdr_nid4 *)0)->dest_nid) != 8);
+	BUILD_BUG_ON((int)offsetof(struct _lnet_hdr_nid4, src_nid) != 8);
+	BUILD_BUG_ON((int)sizeof(((struct _lnet_hdr_nid4 *)0)->src_nid) != 8);
+	BUILD_BUG_ON((int)offsetof(struct _lnet_hdr_nid4, dest_pid) != 16);
+	BUILD_BUG_ON((int)sizeof(((struct _lnet_hdr_nid4 *)0)->dest_pid) != 4);
+	BUILD_BUG_ON((int)offsetof(struct _lnet_hdr_nid4, src_pid) != 20);
+	BUILD_BUG_ON((int)sizeof(((struct _lnet_hdr_nid4 *)0)->src_pid) != 4);
+	BUILD_BUG_ON((int)offsetof(struct _lnet_hdr_nid4, type) != 24);
+	BUILD_BUG_ON((int)sizeof(((struct _lnet_hdr_nid4 *)0)->type) != 4);
+	BUILD_BUG_ON((int)offsetof(struct _lnet_hdr_nid4, payload_length) != 28);
+	BUILD_BUG_ON((int)sizeof(((struct _lnet_hdr_nid4 *)0)->payload_length) != 4);
+	BUILD_BUG_ON((int)offsetof(struct _lnet_hdr_nid4, msg) != 32);
+	BUILD_BUG_ON((int)sizeof(((struct _lnet_hdr_nid4 *)0)->msg) != 40);
 
 	/* Ack */
-	BUILD_BUG_ON((int)offsetof(struct lnet_hdr, msg.ack.dst_wmd) != 32);
-	BUILD_BUG_ON((int)sizeof(((struct lnet_hdr *)0)->msg.ack.dst_wmd) != 16);
-	BUILD_BUG_ON((int)offsetof(struct lnet_hdr, msg.ack.match_bits) != 48);
-	BUILD_BUG_ON((int)sizeof(((struct lnet_hdr *)0)->msg.ack.match_bits) != 8);
-	BUILD_BUG_ON((int)offsetof(struct lnet_hdr, msg.ack.mlength) != 56);
-	BUILD_BUG_ON((int)sizeof(((struct lnet_hdr *)0)->msg.ack.mlength) != 4);
+	BUILD_BUG_ON((int)offsetof(struct _lnet_hdr_nid4, msg.ack.dst_wmd) != 32);
+	BUILD_BUG_ON((int)sizeof(((struct _lnet_hdr_nid4 *)0)->msg.ack.dst_wmd) != 16);
+	BUILD_BUG_ON((int)offsetof(struct _lnet_hdr_nid4, msg.ack.match_bits) != 48);
+	BUILD_BUG_ON((int)sizeof(((struct _lnet_hdr_nid4 *)0)->msg.ack.match_bits) != 8);
+	BUILD_BUG_ON((int)offsetof(struct _lnet_hdr_nid4, msg.ack.mlength) != 56);
+	BUILD_BUG_ON((int)sizeof(((struct _lnet_hdr_nid4 *)0)->msg.ack.mlength) != 4);
 
 	/* Put */
-	BUILD_BUG_ON((int)offsetof(struct lnet_hdr, msg.put.ack_wmd) != 32);
-	BUILD_BUG_ON((int)sizeof(((struct lnet_hdr *)0)->msg.put.ack_wmd) != 16);
-	BUILD_BUG_ON((int)offsetof(struct lnet_hdr, msg.put.match_bits) != 48);
-	BUILD_BUG_ON((int)sizeof(((struct lnet_hdr *)0)->msg.put.match_bits) != 8);
-	BUILD_BUG_ON((int)offsetof(struct lnet_hdr, msg.put.hdr_data) != 56);
-	BUILD_BUG_ON((int)sizeof(((struct lnet_hdr *)0)->msg.put.hdr_data) != 8);
-	BUILD_BUG_ON((int)offsetof(struct lnet_hdr, msg.put.ptl_index) != 64);
-	BUILD_BUG_ON((int)sizeof(((struct lnet_hdr *)0)->msg.put.ptl_index) != 4);
-	BUILD_BUG_ON((int)offsetof(struct lnet_hdr, msg.put.offset) != 68);
-	BUILD_BUG_ON((int)sizeof(((struct lnet_hdr *)0)->msg.put.offset) != 4);
+	BUILD_BUG_ON((int)offsetof(struct _lnet_hdr_nid4, msg.put.ack_wmd) != 32);
+	BUILD_BUG_ON((int)sizeof(((struct _lnet_hdr_nid4 *)0)->msg.put.ack_wmd) != 16);
+	BUILD_BUG_ON((int)offsetof(struct _lnet_hdr_nid4, msg.put.match_bits) != 48);
+	BUILD_BUG_ON((int)sizeof(((struct _lnet_hdr_nid4 *)0)->msg.put.match_bits) != 8);
+	BUILD_BUG_ON((int)offsetof(struct _lnet_hdr_nid4, msg.put.hdr_data) != 56);
+	BUILD_BUG_ON((int)sizeof(((struct _lnet_hdr_nid4 *)0)->msg.put.hdr_data) != 8);
+	BUILD_BUG_ON((int)offsetof(struct _lnet_hdr_nid4, msg.put.ptl_index) != 64);
+	BUILD_BUG_ON((int)sizeof(((struct _lnet_hdr_nid4 *)0)->msg.put.ptl_index) != 4);
+	BUILD_BUG_ON((int)offsetof(struct _lnet_hdr_nid4, msg.put.offset) != 68);
+	BUILD_BUG_ON((int)sizeof(((struct _lnet_hdr_nid4 *)0)->msg.put.offset) != 4);
 
 	/* Get */
-	BUILD_BUG_ON((int)offsetof(struct lnet_hdr, msg.get.return_wmd) != 32);
-	BUILD_BUG_ON((int)sizeof(((struct lnet_hdr *)0)->msg.get.return_wmd) != 16);
-	BUILD_BUG_ON((int)offsetof(struct lnet_hdr, msg.get.match_bits) != 48);
-	BUILD_BUG_ON((int)sizeof(((struct lnet_hdr *)0)->msg.get.match_bits) != 8);
-	BUILD_BUG_ON((int)offsetof(struct lnet_hdr, msg.get.ptl_index) != 56);
-	BUILD_BUG_ON((int)sizeof(((struct lnet_hdr *)0)->msg.get.ptl_index) != 4);
-	BUILD_BUG_ON((int)offsetof(struct lnet_hdr, msg.get.src_offset) != 60);
-	BUILD_BUG_ON((int)sizeof(((struct lnet_hdr *)0)->msg.get.src_offset) != 4);
-	BUILD_BUG_ON((int)offsetof(struct lnet_hdr, msg.get.sink_length) != 64);
-	BUILD_BUG_ON((int)sizeof(((struct lnet_hdr *)0)->msg.get.sink_length) != 4);
+	BUILD_BUG_ON((int)offsetof(struct _lnet_hdr_nid4, msg.get.return_wmd) != 32);
+	BUILD_BUG_ON((int)sizeof(((struct _lnet_hdr_nid4 *)0)->msg.get.return_wmd) != 16);
+	BUILD_BUG_ON((int)offsetof(struct _lnet_hdr_nid4, msg.get.match_bits) != 48);
+	BUILD_BUG_ON((int)sizeof(((struct _lnet_hdr_nid4 *)0)->msg.get.match_bits) != 8);
+	BUILD_BUG_ON((int)offsetof(struct _lnet_hdr_nid4, msg.get.ptl_index) != 56);
+	BUILD_BUG_ON((int)sizeof(((struct _lnet_hdr_nid4 *)0)->msg.get.ptl_index) != 4);
+	BUILD_BUG_ON((int)offsetof(struct _lnet_hdr_nid4, msg.get.src_offset) != 60);
+	BUILD_BUG_ON((int)sizeof(((struct _lnet_hdr_nid4 *)0)->msg.get.src_offset) != 4);
+	BUILD_BUG_ON((int)offsetof(struct _lnet_hdr_nid4, msg.get.sink_length) != 64);
+	BUILD_BUG_ON((int)sizeof(((struct _lnet_hdr_nid4 *)0)->msg.get.sink_length) != 4);
 
 	/* Reply */
-	BUILD_BUG_ON((int)offsetof(struct lnet_hdr, msg.reply.dst_wmd) != 32);
-	BUILD_BUG_ON((int)sizeof(((struct lnet_hdr *)0)->msg.reply.dst_wmd) != 16);
+	BUILD_BUG_ON((int)offsetof(struct _lnet_hdr_nid4, msg.reply.dst_wmd) != 32);
+	BUILD_BUG_ON((int)sizeof(((struct _lnet_hdr_nid4 *)0)->msg.reply.dst_wmd) != 16);
 
 	/* Hello */
-	BUILD_BUG_ON((int)offsetof(struct lnet_hdr, msg.hello.incarnation) != 32);
-	BUILD_BUG_ON((int)sizeof(((struct lnet_hdr *)0)->msg.hello.incarnation) != 8);
-	BUILD_BUG_ON((int)offsetof(struct lnet_hdr, msg.hello.type) != 40);
-	BUILD_BUG_ON((int)sizeof(((struct lnet_hdr *)0)->msg.hello.type) != 4);
+	BUILD_BUG_ON((int)offsetof(struct _lnet_hdr_nid4, msg.hello.incarnation) != 32);
+	BUILD_BUG_ON((int)sizeof(((struct _lnet_hdr_nid4 *)0)->msg.hello.incarnation) != 8);
+	BUILD_BUG_ON((int)offsetof(struct _lnet_hdr_nid4, msg.hello.type) != 40);
+	BUILD_BUG_ON((int)sizeof(((struct _lnet_hdr_nid4 *)0)->msg.hello.type) != 4);
 
 	/* Checks for struct lnet_ni_status and related constants */
 	BUILD_BUG_ON(LNET_NI_STATUS_INVALID != 0x00000000);
diff --git a/net/lnet/lnet/lib-move.c b/net/lnet/lnet/lib-move.c
index de3e0ac..f55b525 100644
--- a/net/lnet/lnet/lib-move.c
+++ b/net/lnet/lnet/lib-move.c
@@ -526,13 +526,13 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 		lnet_setpayloadbuffer(msg);
 
 	memset(&msg->msg_hdr, 0, sizeof(msg->msg_hdr));
-	msg->msg_hdr.type = cpu_to_le32(type);
+	msg->msg_hdr.type = type;
 	/* dest_nid will be overwritten by lnet_select_pathway() */
-	msg->msg_hdr.dest_nid = cpu_to_le64(target.nid);
-	msg->msg_hdr.dest_pid = cpu_to_le32(target.pid);
+	msg->msg_hdr.dest_nid = target.nid;
+	msg->msg_hdr.dest_pid = target.pid;
 	/* src_nid will be set later */
-	msg->msg_hdr.src_pid = cpu_to_le32(the_lnet.ln_pid);
-	msg->msg_hdr.payload_length = cpu_to_le32(len);
+	msg->msg_hdr.src_pid = the_lnet.ln_pid;
+	msg->msg_hdr.payload_length = len;
 }
 
 void
@@ -705,7 +705,7 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 			!list_empty(&lp->lpni_txq));
 
 		msg->msg_peertxcredit = 1;
-		lp->lpni_txqnob += msg->msg_len + sizeof(struct lnet_hdr);
+		lp->lpni_txqnob += msg->msg_len + sizeof(struct lnet_hdr_nid4);
 		lp->lpni_txcredits--;
 
 		if (lp->lpni_txcredits < lp->lpni_mintxcredits)
@@ -903,7 +903,8 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 		LASSERT((txpeer->lpni_txcredits < 0) ==
 			!list_empty(&txpeer->lpni_txq));
 
-		txpeer->lpni_txqnob -= msg->msg_len + sizeof(struct lnet_hdr);
+		txpeer->lpni_txqnob -=	msg->msg_len +
+					sizeof(struct lnet_hdr_nid4);
 		LASSERT(txpeer->lpni_txqnob >= 0);
 
 		txpeer->lpni_txcredits++;
@@ -1626,10 +1627,10 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 	/* No send credit hassles with LOLND */
 	lnet_ni_addref_locked(the_lnet.ln_loni, cpt);
 	msg->msg_hdr.dest_nid =
-		cpu_to_le64(lnet_nid_to_nid4(&the_lnet.ln_loni->ni_nid));
+		lnet_nid_to_nid4(&the_lnet.ln_loni->ni_nid);
 	if (!msg->msg_routing)
 		msg->msg_hdr.src_nid =
-			cpu_to_le64(lnet_nid_to_nid4(&the_lnet.ln_loni->ni_nid));
+			lnet_nid_to_nid4(&the_lnet.ln_loni->ni_nid);
 	msg->msg_target.nid = the_lnet.ln_loni->ni_nid;
 	lnet_msg_commit(msg, cpt);
 	msg->msg_txni = the_lnet.ln_loni;
@@ -1726,7 +1727,7 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 	 */
 	if (!msg->msg_routing)
 		msg->msg_hdr.src_nid =
-			cpu_to_le64(lnet_nid_to_nid4(&msg->msg_txni->ni_nid));
+			lnet_nid_to_nid4(&msg->msg_txni->ni_nid);
 
 	if (routing) {
 		msg->msg_target_is_router = 1;
@@ -1742,13 +1743,13 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 		 */
 		/* FIXME handle large-addr nid */
 		msg->msg_hdr.dest_nid =
-			cpu_to_le64(lnet_nid_to_nid4(&final_dst_lpni->lpni_nid));
+			lnet_nid_to_nid4(&final_dst_lpni->lpni_nid);
 	} else {
 		/* if we're not routing set the dest_nid to the best peer
 		 * ni NID that we picked earlier in the algorithm.
 		 */
 		msg->msg_hdr.dest_nid =
-			cpu_to_le64(lnet_nid_to_nid4(&msg->msg_txpeer->lpni_nid));
+			lnet_nid_to_nid4(&msg->msg_txpeer->lpni_nid);
 	}
 
 	/* if we have response tracker block update it with the next hop
@@ -4259,11 +4260,11 @@ void lnet_monitor_thr_stop(void)
 
 	lnet_nid4_to_nid(from_nid4, &from_nid);
 
-	type = le32_to_cpu(hdr->type);
-	src_nid = le64_to_cpu(hdr->src_nid);
-	dest_nid = le64_to_cpu(hdr->dest_nid);
-	dest_pid = le32_to_cpu(hdr->dest_pid);
-	payload_length = le32_to_cpu(hdr->payload_length);
+	type = hdr->type;
+	src_nid = hdr->src_nid;
+	dest_nid = hdr->dest_nid;
+	dest_pid = hdr->dest_pid;
+	payload_length = hdr->payload_length;
 
 	/* FIXME handle large-addr nids */
 	for_me = (lnet_nid_to_nid4(&ni->ni_nid) == dest_nid);
@@ -4411,14 +4412,6 @@ void lnet_monitor_thr_stop(void)
 		msg->msg_target.pid = dest_pid;
 		lnet_nid4_to_nid(dest_nid, &msg->msg_target.nid);
 		msg->msg_routing = 1;
-	} else {
-		/* convert common msg->hdr fields to host byteorder */
-		msg->msg_hdr.type = type;
-		msg->msg_hdr.src_nid = src_nid;
-		le32_to_cpus(&msg->msg_hdr.src_pid);
-		msg->msg_hdr.dest_nid = dest_nid;
-		msg->msg_hdr.dest_pid = dest_pid;
-		msg->msg_hdr.payload_length = payload_length;
 	}
 
 	lnet_net_lock(cpt);
diff --git a/net/lnet/lnet/lib-msg.c b/net/lnet/lnet/lib-msg.c
index 4102c7b..62a02ac 100644
--- a/net/lnet/lnet/lib-msg.c
+++ b/net/lnet/lnet/lib-msg.c
@@ -66,8 +66,8 @@
 
 	if (ev_type == LNET_EVENT_SEND) {
 		/* event for active message */
-		lnet_nid4_to_nid(le64_to_cpu(hdr->dest_nid), &ev->target.nid);
-		ev->target.pid = le32_to_cpu(hdr->dest_pid);
+		lnet_nid4_to_nid(hdr->dest_nid, &ev->target.nid);
+		ev->target.pid = hdr->dest_pid;
 		ev->initiator.nid = LNET_ANY_NID;
 		ev->initiator.pid = the_lnet.ln_pid;
 		ev->source.nid = LNET_ANY_NID;
diff --git a/net/lnet/lnet/net_fault.c b/net/lnet/lnet/net_fault.c
index 02fc1ae..ee45767 100644
--- a/net/lnet/lnet/net_fault.c
+++ b/net/lnet/lnet/net_fault.c
@@ -427,9 +427,9 @@ struct lnet_drop_rule {
 		     lnet_nid_t local_nid,
 		     enum lnet_msg_hstatus *hstatus)
 {
-	lnet_nid_t src = le64_to_cpu(hdr->src_nid);
-	lnet_nid_t dst = le64_to_cpu(hdr->dest_nid);
-	unsigned int typ = le32_to_cpu(hdr->type);
+	lnet_nid_t src = hdr->src_nid;
+	lnet_nid_t dst = hdr->dest_nid;
+	unsigned int typ = hdr->type;
 	struct lnet_drop_rule *rule;
 	unsigned int ptl = -1;
 	bool drop = false;
@@ -605,9 +605,9 @@ struct delay_daemon_data {
 lnet_delay_rule_match_locked(struct lnet_hdr *hdr, struct lnet_msg *msg)
 {
 	struct lnet_delay_rule *rule;
-	lnet_nid_t src = le64_to_cpu(hdr->src_nid);
-	lnet_nid_t dst = le64_to_cpu(hdr->dest_nid);
-	unsigned int typ = le32_to_cpu(hdr->type);
+	lnet_nid_t src = hdr->src_nid;
+	lnet_nid_t dst = hdr->dest_nid;
+	unsigned int typ = hdr->type;
 	unsigned int ptl = -1;
 
 	/* NB: called with hold of lnet_net_lock */
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
