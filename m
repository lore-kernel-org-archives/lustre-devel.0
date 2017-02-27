From: James Simmons <jsimmons@infradead.org>
Date: Sun, 26 Feb 2017 19:41:26 -0500
Subject: [lustre-devel] [PATCH 01/34] staging: lustre: socklnd: change UAPI
	typedefs to proper structure
In-Reply-To: <1488156119-19670-1-git-send-email-jsimmons@infradead.org>
References: <1488156119-19670-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1488156119-19670-2-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@yahoo.com>

The upstream kernel requires proper structures so
convert all the UAPI typedefs in socklnd.h.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6142
Reviewed-on: https://review.whamcloud.com/18506
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Doug Oucharek <doug.s.oucharek@intel.com>
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/include/linux/lnet/socklnd.h    | 14 ++++----
 .../staging/lustre/lnet/klnds/socklnd/socklnd.c    |  8 ++---
 .../staging/lustre/lnet/klnds/socklnd/socklnd.h    | 14 ++++----
 .../staging/lustre/lnet/klnds/socklnd/socklnd_cb.c | 22 ++++++-------
 .../lustre/lnet/klnds/socklnd/socklnd_proto.c      | 38 +++++++++++-----------
 5 files changed, 48 insertions(+), 48 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/socklnd.h b/drivers/staging/lustre/include/linux/lnet/socklnd.h
index acf20ce..dd5bc0e 100644
--- a/drivers/staging/lustre/include/linux/lnet/socklnd.h
+++ b/drivers/staging/lustre/include/linux/lnet/socklnd.h
@@ -45,7 +45,7 @@
 
 #define SOCKLND_CONN_ACK	SOCKLND_CONN_BULK_IN
 
-typedef struct {
+struct ksock_hello_msg {
 	__u32		kshm_magic;	/* magic number of socklnd message */
 	__u32		kshm_version;	/* version of socklnd message */
 	lnet_nid_t      kshm_src_nid;	/* sender's nid */
@@ -57,9 +57,9 @@
 	__u32		kshm_ctype;	/* connection type */
 	__u32		kshm_nips;	/* # IP addrs */
 	__u32		kshm_ips[0];	/* IP addrs */
-} WIRE_ATTR ksock_hello_msg_t;
+} WIRE_ATTR;
 
-typedef struct {
+struct ksock_lnet_msg {
 	struct lnet_hdr	ksnm_hdr;	/* lnet hdr */
 
 	/*
@@ -68,17 +68,17 @@
 	 * structure definitions. lnet payload will be stored just after
 	 * the body of structure ksock_lnet_msg_t
 	 */
-} WIRE_ATTR ksock_lnet_msg_t;
+} WIRE_ATTR;
 
-typedef struct {
+struct ksock_msg {
 	__u32	ksm_type;		/* type of socklnd message */
 	__u32	ksm_csum;		/* checksum if != 0 */
 	__u64	ksm_zc_cookies[2];	/* Zero-Copy request/ACK cookie */
 	union {
-		ksock_lnet_msg_t lnetmsg;/* lnet message, it's empty if
+		struct ksock_lnet_msg lnetmsg; /* lnet message, it's empty if
 					  * it's NOOP */
 	} WIRE_ATTR ksm_u;
-} WIRE_ATTR ksock_msg_t;
+} WIRE_ATTR;
 
 #define KSOCK_MSG_NOOP	0xC0	/* ksm_u empty */
 #define KSOCK_MSG_LNET	0xC1	/* lnet msg */
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
index f25de3d..3b08aff 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
@@ -1038,7 +1038,7 @@ struct ksock_peer *
 	struct ksock_peer *peer = NULL;
 	struct ksock_peer *peer2;
 	struct ksock_sched *sched;
-	ksock_hello_msg_t *hello;
+	struct ksock_hello_msg *hello;
 	int cpt;
 	struct ksock_tx *tx;
 	struct ksock_tx *txtmp;
@@ -1077,7 +1077,7 @@ struct ksock_peer *
 	conn->ksnc_tx_carrier = NULL;
 	atomic_set(&conn->ksnc_tx_nob, 0);
 
-	LIBCFS_ALLOC(hello, offsetof(ksock_hello_msg_t,
+	LIBCFS_ALLOC(hello, offsetof(struct ksock_hello_msg,
 				     kshm_ips[LNET_MAX_INTERFACES]));
 	if (!hello) {
 		rc = -ENOMEM;
@@ -1341,7 +1341,7 @@ struct ksock_peer *
 		rc = ksocknal_send_hello(ni, conn, peerid.nid, hello);
 	}
 
-	LIBCFS_FREE(hello, offsetof(ksock_hello_msg_t,
+	LIBCFS_FREE(hello, offsetof(struct ksock_hello_msg,
 				    kshm_ips[LNET_MAX_INTERFACES]));
 
 	/*
@@ -1423,7 +1423,7 @@ struct ksock_peer *
 
 failed_1:
 	if (hello)
-		LIBCFS_FREE(hello, offsetof(ksock_hello_msg_t,
+		LIBCFS_FREE(hello, offsetof(struct ksock_hello_msg,
 					    kshm_ips[LNET_MAX_INTERFACES]));
 
 	LIBCFS_FREE(conn, sizeof(*conn));
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h
index 9e86563..3631998 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h
@@ -287,7 +287,7 @@ struct ksock_tx {			   /* transmit packet */
 	lnet_msg_t        *tx_lnetmsg;     /* lnet message for lnet_finalize()
 					    */
 	unsigned long     tx_deadline;     /* when (in jiffies) tx times out */
-	ksock_msg_t       tx_msg;          /* socklnd message buffer */
+	struct ksock_msg       tx_msg;          /* socklnd message buffer */
 	int               tx_desc_size;    /* size of this descriptor */
 	union {
 		struct {
@@ -369,7 +369,7 @@ struct ksock_conn {
 					       */
 	void               *ksnc_cookie;      /* rx lnet_finalize passthru arg
 					       */
-	ksock_msg_t        ksnc_msg;          /* incoming message buffer:
+	struct ksock_msg        ksnc_msg;          /* incoming message buffer:
 					       * V2.x message takes the
 					       * whole struct
 					       * V1.x message is a bare
@@ -474,16 +474,16 @@ struct ksock_proto {
 	int        pro_version;
 
 	/* handshake function */
-	int        (*pro_send_hello)(struct ksock_conn *, ksock_hello_msg_t *);
+	int        (*pro_send_hello)(struct ksock_conn *, struct ksock_hello_msg *);
 
 	/* handshake function */
-	int        (*pro_recv_hello)(struct ksock_conn *, ksock_hello_msg_t *, int);
+	int        (*pro_recv_hello)(struct ksock_conn *, struct ksock_hello_msg *, int);
 
 	/* message pack */
 	void       (*pro_pack)(struct ksock_tx *);
 
 	/* message unpack */
-	void       (*pro_unpack)(ksock_msg_t *);
+	void       (*pro_unpack)(struct ksock_msg *);
 
 	/* queue tx on the connection */
 	struct ksock_tx *(*pro_queue_tx_msg)(struct ksock_conn *, struct ksock_tx *);
@@ -691,9 +691,9 @@ int  ksocknal_launch_packet(lnet_ni_t *ni, struct ksock_tx *tx,
 int ksocknal_connd(void *arg);
 int ksocknal_reaper(void *arg);
 int ksocknal_send_hello(lnet_ni_t *ni, struct ksock_conn *conn,
-			lnet_nid_t peer_nid, ksock_hello_msg_t *hello);
+			lnet_nid_t peer_nid, struct ksock_hello_msg *hello);
 int ksocknal_recv_hello(lnet_ni_t *ni, struct ksock_conn *conn,
-			ksock_hello_msg_t *hello, lnet_process_id_t *id,
+			struct ksock_hello_msg *hello, lnet_process_id_t *id,
 			__u64 *incarnation);
 void ksocknal_read_callback(struct ksock_conn *conn);
 void ksocknal_write_callback(struct ksock_conn *conn);
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
index 4c9f927..9fbae62 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
@@ -695,7 +695,7 @@ struct ksock_conn *
 ksocknal_queue_tx_locked(struct ksock_tx *tx, struct ksock_conn *conn)
 {
 	struct ksock_sched *sched = conn->ksnc_scheduler;
-	ksock_msg_t *msg = &tx->tx_msg;
+	struct ksock_msg *msg = &tx->tx_msg;
 	struct ksock_tx *ztx = NULL;
 	int bufnob = 0;
 
@@ -1072,9 +1072,9 @@ struct ksock_route *
 			conn->ksnc_rx_iov = (struct kvec *)&conn->ksnc_rx_iov_space;
 			conn->ksnc_rx_iov[0].iov_base = &conn->ksnc_msg;
 
-			conn->ksnc_rx_nob_wanted = offsetof(ksock_msg_t, ksm_u);
-			conn->ksnc_rx_nob_left = offsetof(ksock_msg_t, ksm_u);
-			conn->ksnc_rx_iov[0].iov_len  = offsetof(ksock_msg_t, ksm_u);
+			conn->ksnc_rx_nob_wanted = offsetof(struct ksock_msg, ksm_u);
+			conn->ksnc_rx_nob_left = offsetof(struct ksock_msg, ksm_u);
+			conn->ksnc_rx_iov[0].iov_len = offsetof(struct ksock_msg, ksm_u);
 			break;
 
 		case KSOCK_PROTO_V1:
@@ -1232,12 +1232,12 @@ struct ksock_route *
 		}
 
 		conn->ksnc_rx_state = SOCKNAL_RX_LNET_HEADER;
-		conn->ksnc_rx_nob_wanted = sizeof(ksock_lnet_msg_t);
-		conn->ksnc_rx_nob_left = sizeof(ksock_lnet_msg_t);
+		conn->ksnc_rx_nob_wanted = sizeof(struct ksock_lnet_msg);
+		conn->ksnc_rx_nob_left = sizeof(struct ksock_lnet_msg);
 
 		conn->ksnc_rx_iov = (struct kvec *)&conn->ksnc_rx_iov_space;
 		conn->ksnc_rx_iov[0].iov_base = &conn->ksnc_msg.ksm_u.lnetmsg;
-		conn->ksnc_rx_iov[0].iov_len  = sizeof(ksock_lnet_msg_t);
+		conn->ksnc_rx_iov[0].iov_len = sizeof(struct ksock_lnet_msg);
 
 		conn->ksnc_rx_niov = 1;
 		conn->ksnc_rx_kiov = NULL;
@@ -1633,7 +1633,7 @@ void ksocknal_write_callback(struct ksock_conn *conn)
 }
 
 static struct ksock_proto *
-ksocknal_parse_proto_version(ksock_hello_msg_t *hello)
+ksocknal_parse_proto_version(struct ksock_hello_msg *hello)
 {
 	__u32 version = 0;
 
@@ -1664,7 +1664,7 @@ void ksocknal_write_callback(struct ksock_conn *conn)
 		struct lnet_magicversion *hmv = (struct lnet_magicversion *)hello;
 
 		BUILD_BUG_ON(sizeof(struct lnet_magicversion) !=
-			 offsetof(ksock_hello_msg_t, kshm_src_nid));
+			     offsetof(struct ksock_hello_msg, kshm_src_nid));
 
 		if (hmv->version_major == cpu_to_le16(KSOCK_PROTO_V1_MAJOR) &&
 		    hmv->version_minor == cpu_to_le16(KSOCK_PROTO_V1_MINOR))
@@ -1676,7 +1676,7 @@ void ksocknal_write_callback(struct ksock_conn *conn)
 
 int
 ksocknal_send_hello(lnet_ni_t *ni, struct ksock_conn *conn,
-		    lnet_nid_t peer_nid, ksock_hello_msg_t *hello)
+		    lnet_nid_t peer_nid, struct ksock_hello_msg *hello)
 {
 	/* CAVEAT EMPTOR: this byte flips 'ipaddrs' */
 	struct ksock_net *net = (struct ksock_net *)ni->ni_data;
@@ -1714,7 +1714,7 @@ void ksocknal_write_callback(struct ksock_conn *conn)
 
 int
 ksocknal_recv_hello(lnet_ni_t *ni, struct ksock_conn *conn,
-		    ksock_hello_msg_t *hello, lnet_process_id_t *peerid,
+		    struct ksock_hello_msg *hello, lnet_process_id_t *peerid,
 		    __u64 *incarnation)
 {
 	/* Return < 0	fatal error
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_proto.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_proto.c
index d367e74..84be9a5 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_proto.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_proto.c
@@ -287,11 +287,11 @@
 
 	if (!tx || !tx->tx_lnetmsg) {
 		/* noop packet */
-		nob = offsetof(ksock_msg_t, ksm_u);
+		nob = offsetof(struct ksock_msg, ksm_u);
 	} else {
 		nob = tx->tx_lnetmsg->msg_len +
 		      ((conn->ksnc_proto == &ksocknal_protocol_v1x) ?
-		       sizeof(struct lnet_hdr) : sizeof(ksock_msg_t));
+		       sizeof(struct lnet_hdr) : sizeof(struct ksock_msg));
 	}
 
 	/* default checking for typed connection */
@@ -325,9 +325,9 @@
 	int nob;
 
 	if (!tx || !tx->tx_lnetmsg)
-		nob = offsetof(ksock_msg_t, ksm_u);
+		nob = offsetof(struct ksock_msg, ksm_u);
 	else
-		nob = tx->tx_lnetmsg->msg_len + sizeof(ksock_msg_t);
+		nob = tx->tx_lnetmsg->msg_len + sizeof(struct ksock_msg);
 
 	switch (conn->ksnc_type) {
 	default:
@@ -456,7 +456,7 @@
 }
 
 static int
-ksocknal_send_hello_v1(struct ksock_conn *conn, ksock_hello_msg_t *hello)
+ksocknal_send_hello_v1(struct ksock_conn *conn, struct ksock_hello_msg *hello)
 {
 	struct socket *sock = conn->ksnc_sock;
 	struct lnet_hdr *hdr;
@@ -531,7 +531,7 @@
 }
 
 static int
-ksocknal_send_hello_v2(struct ksock_conn *conn, ksock_hello_msg_t *hello)
+ksocknal_send_hello_v2(struct ksock_conn *conn, struct ksock_hello_msg *hello)
 {
 	struct socket *sock = conn->ksnc_sock;
 	int rc;
@@ -549,7 +549,7 @@
 		LNET_UNLOCK();
 	}
 
-	rc = lnet_sock_write(sock, hello, offsetof(ksock_hello_msg_t, kshm_ips),
+	rc = lnet_sock_write(sock, hello, offsetof(struct ksock_hello_msg, kshm_ips),
 			     lnet_acceptor_timeout());
 	if (rc) {
 		CNETERR("Error %d sending HELLO hdr to %pI4h/%d\n",
@@ -573,7 +573,7 @@
 }
 
 static int
-ksocknal_recv_hello_v1(struct ksock_conn *conn, ksock_hello_msg_t *hello,
+ksocknal_recv_hello_v1(struct ksock_conn *conn, struct ksock_hello_msg *hello,
 		       int timeout)
 {
 	struct socket *sock = conn->ksnc_sock;
@@ -649,7 +649,7 @@
 }
 
 static int
-ksocknal_recv_hello_v2(struct ksock_conn *conn, ksock_hello_msg_t *hello,
+ksocknal_recv_hello_v2(struct ksock_conn *conn, struct ksock_hello_msg *hello,
 		       int timeout)
 {
 	struct socket *sock = conn->ksnc_sock;
@@ -662,8 +662,8 @@
 		conn->ksnc_flip = 1;
 
 	rc = lnet_sock_read(sock, &hello->kshm_src_nid,
-			    offsetof(ksock_hello_msg_t, kshm_ips) -
-				     offsetof(ksock_hello_msg_t, kshm_src_nid),
+			    offsetof(struct ksock_hello_msg, kshm_ips) -
+				     offsetof(struct ksock_hello_msg, kshm_src_nid),
 			    timeout);
 	if (rc) {
 		CERROR("Error %d reading HELLO from %pI4h\n",
@@ -738,15 +738,15 @@
 		LASSERT(tx->tx_msg.ksm_type != KSOCK_MSG_NOOP);
 
 		tx->tx_msg.ksm_u.lnetmsg.ksnm_hdr = tx->tx_lnetmsg->msg_hdr;
-		tx->tx_iov[0].iov_len = sizeof(ksock_msg_t);
-		tx->tx_nob = sizeof(ksock_msg_t) + tx->tx_lnetmsg->msg_len;
-		tx->tx_resid = sizeof(ksock_msg_t) + tx->tx_lnetmsg->msg_len;
+		tx->tx_iov[0].iov_len = sizeof(struct ksock_msg);
+		tx->tx_nob = sizeof(struct ksock_msg) + tx->tx_lnetmsg->msg_len;
+		tx->tx_resid = sizeof(struct ksock_msg) + tx->tx_lnetmsg->msg_len;
 	} else {
 		LASSERT(tx->tx_msg.ksm_type == KSOCK_MSG_NOOP);
 
-		tx->tx_iov[0].iov_len = offsetof(ksock_msg_t, ksm_u.lnetmsg.ksnm_hdr);
-		tx->tx_nob = offsetof(ksock_msg_t,  ksm_u.lnetmsg.ksnm_hdr);
-		tx->tx_resid = offsetof(ksock_msg_t,  ksm_u.lnetmsg.ksnm_hdr);
+		tx->tx_iov[0].iov_len = offsetof(struct ksock_msg, ksm_u.lnetmsg.ksnm_hdr);
+		tx->tx_nob = offsetof(struct ksock_msg,  ksm_u.lnetmsg.ksnm_hdr);
+		tx->tx_resid = offsetof(struct ksock_msg,  ksm_u.lnetmsg.ksnm_hdr);
 	}
 	/*
 	 * Don't checksum before start sending, because packet can be
@@ -755,7 +755,7 @@
 }
 
 static void
-ksocknal_unpack_msg_v1(ksock_msg_t *msg)
+ksocknal_unpack_msg_v1(struct ksock_msg *msg)
 {
 	msg->ksm_csum = 0;
 	msg->ksm_type = KSOCK_MSG_LNET;
@@ -764,7 +764,7 @@
 }
 
 static void
-ksocknal_unpack_msg_v2(ksock_msg_t *msg)
+ksocknal_unpack_msg_v2(struct ksock_msg *msg)
 {
 	return;  /* Do nothing */
 }
-- 
1.8.3.1
