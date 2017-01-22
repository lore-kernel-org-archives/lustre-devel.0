From: James Simmons <jsimmons@infradead.org>
Date: Sat, 21 Jan 2017 19:40:31 -0500
Subject: [lustre-devel] [PATCH 7/8] staging: lustre: lnet: change lnet_hdr_t
	to proper structure
In-Reply-To: <1485045632-5886-1-git-send-email-jsimmons@infradead.org>
References: <1485045632-5886-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1485045632-5886-8-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@yahoo.com>

Change lnet_hdr_t from typedef to proper structure.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6142
Reviewed-on: https://review.whamcloud.com/24566
Reviewed-by: Doug Oucharek <doug.s.oucharek@intel.com>
Reviewed-by: Olaf Weber <olaf@sgi.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/include/linux/lnet/lib-lnet.h   |  8 +-
 .../staging/lustre/include/linux/lnet/lib-types.h  |  2 +-
 .../staging/lustre/include/linux/lnet/socklnd.h    |  2 +-
 drivers/staging/lustre/include/linux/lnet/types.h  |  6 +-
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h    |  6 +-
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c |  2 +-
 .../staging/lustre/lnet/klnds/socklnd/socklnd.h    |  2 +-
 .../staging/lustre/lnet/klnds/socklnd/socklnd_cb.c | 10 +--
 .../lustre/lnet/klnds/socklnd/socklnd_proto.c      | 22 ++---
 drivers/staging/lustre/lnet/lnet/api-ni.c          | 96 +++++++++++-----------
 drivers/staging/lustre/lnet/lnet/lib-move.c        | 18 ++--
 drivers/staging/lustre/lnet/lnet/lib-msg.c         |  2 +-
 drivers/staging/lustre/lnet/lnet/lib-ptl.c         |  2 +-
 drivers/staging/lustre/lnet/lnet/net_fault.c       |  4 +-
 14 files changed, 91 insertions(+), 91 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
index 8f164a9..3d19402 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
@@ -552,7 +552,7 @@ void lnet_ptl_attach_md(lnet_me_t *me, lnet_libmd_t *md,
 void lnet_portals_destroy(void);
 
 /* message functions */
-int lnet_parse(lnet_ni_t *ni, lnet_hdr_t *hdr,
+int lnet_parse(lnet_ni_t *ni, struct lnet_hdr *hdr,
 	       lnet_nid_t fromnid, void *private, int rdma_req);
 int lnet_parse_local(lnet_ni_t *ni, lnet_msg_t *msg);
 int lnet_parse_forward_locked(lnet_ni_t *ni, lnet_msg_t *msg);
@@ -579,7 +579,7 @@ void lnet_drop_message(lnet_ni_t *ni, int cpt, void *private,
 int lnet_msg_containers_create(void);
 
 char *lnet_msgtyp2str(int type);
-void lnet_print_hdr(lnet_hdr_t *hdr);
+void lnet_print_hdr(struct lnet_hdr *hdr);
 int lnet_fail_nid(lnet_nid_t nid, unsigned int threshold);
 
 /** \addtogroup lnet_fault_simulation @{ */
@@ -588,7 +588,7 @@ void lnet_drop_message(lnet_ni_t *ni, int cpt, void *private,
 int lnet_fault_init(void);
 void lnet_fault_fini(void);
 
-bool lnet_drop_rule_match(lnet_hdr_t *hdr);
+bool lnet_drop_rule_match(struct lnet_hdr *hdr);
 
 int lnet_delay_rule_add(struct lnet_fault_attr *attr);
 int lnet_delay_rule_del(lnet_nid_t src, lnet_nid_t dst, bool shutdown);
@@ -596,7 +596,7 @@ int lnet_delay_rule_list(int pos, struct lnet_fault_attr *attr,
 			 struct lnet_fault_stat *stat);
 void lnet_delay_rule_reset(void);
 void lnet_delay_rule_check(void);
-bool lnet_delay_rule_match_locked(lnet_hdr_t *hdr, struct lnet_msg *msg);
+bool lnet_delay_rule_match_locked(struct lnet_hdr *hdr, struct lnet_msg *msg);
 
 /** @} lnet_fault_simulation */
 
diff --git a/drivers/staging/lustre/include/linux/lnet/lib-types.h b/drivers/staging/lustre/include/linux/lnet/lib-types.h
index 942549b..9850398 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-types.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-types.h
@@ -105,7 +105,7 @@
 	lnet_kiov_t		*msg_kiov;
 
 	lnet_event_t		 msg_ev;
-	lnet_hdr_t		 msg_hdr;
+	struct lnet_hdr		 msg_hdr;
 } lnet_msg_t;
 
 typedef struct lnet_libhandle {
diff --git a/drivers/staging/lustre/include/linux/lnet/socklnd.h b/drivers/staging/lustre/include/linux/lnet/socklnd.h
index bc32403..7d24a91 100644
--- a/drivers/staging/lustre/include/linux/lnet/socklnd.h
+++ b/drivers/staging/lustre/include/linux/lnet/socklnd.h
@@ -60,7 +60,7 @@
 } WIRE_ATTR ksock_hello_msg_t;
 
 typedef struct {
-	lnet_hdr_t	ksnm_hdr;	/* lnet hdr */
+	struct lnet_hdr	ksnm_hdr;	/* lnet hdr */
 
 	/*
 	 * ksnm_payload is removed because of winnt compiler's limitation:
diff --git a/drivers/staging/lustre/include/linux/lnet/types.h b/drivers/staging/lustre/include/linux/lnet/types.h
index a6233be..1448fa4 100644
--- a/drivers/staging/lustre/include/linux/lnet/types.h
+++ b/drivers/staging/lustre/include/linux/lnet/types.h
@@ -177,7 +177,7 @@ struct lnet_handle_wire {
 	__u32			type;
 } WIRE_ATTR lnet_hello_t;
 
-typedef struct {
+struct lnet_hdr {
 	lnet_nid_t	dest_nid;
 	lnet_nid_t	src_nid;
 	lnet_pid_t	dest_pid;
@@ -192,7 +192,7 @@ struct lnet_handle_wire {
 		lnet_reply_t	reply;
 		lnet_hello_t	hello;
 	} msg;
-} WIRE_ATTR lnet_hdr_t;
+} WIRE_ATTR;
 
 /*
  * A HELLO message contains a magic number and protocol version
@@ -202,7 +202,7 @@ struct lnet_handle_wire {
  * This is for use by byte-stream LNDs (e.g. TCP/IP) to check the peer is
  * running the same protocol and to find out its NID. These LNDs should
  * exchange HELLO messages when a connection is first established.  Individual
- * LNDs can put whatever else they fancy in lnet_hdr_t::msg.
+ * LNDs can put whatever else they fancy in struct lnet_hdr::msg.
  */
 struct lnet_magicversion {
 	__u32	magic;		/* LNET_PROTO_TCP_MAGIC */
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
index 1457697..2cb4298 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
@@ -364,7 +364,7 @@ struct kib_connparams {
 } WIRE_ATTR;
 
 struct kib_immediate_msg {
-	lnet_hdr_t   ibim_hdr;        /* portals header */
+	struct lnet_hdr	ibim_hdr;        /* portals header */
 	char         ibim_payload[0]; /* piggy-backed payload */
 } WIRE_ATTR;
 
@@ -380,7 +380,7 @@ struct kib_rdma_desc {
 } WIRE_ATTR;
 
 struct kib_putreq_msg {
-	lnet_hdr_t      ibprm_hdr;    /* portals header */
+	struct lnet_hdr	ibprm_hdr;    /* portals header */
 	__u64           ibprm_cookie; /* opaque completion cookie */
 } WIRE_ATTR;
 
@@ -391,7 +391,7 @@ struct kib_putack_msg {
 } WIRE_ATTR;
 
 struct kib_get_msg {
-	lnet_hdr_t      ibgm_hdr;     /* portals header */
+	struct lnet_hdr ibgm_hdr;     /* portals header */
 	__u64           ibgm_cookie;  /* opaque completion cookie */
 	struct kib_rdma_desc ibgm_rd;      /* rdma descriptor */
 } WIRE_ATTR;
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
index c7917ab..14dbc53 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -1490,7 +1490,7 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
 int
 kiblnd_send(lnet_ni_t *ni, void *private, lnet_msg_t *lntmsg)
 {
-	lnet_hdr_t *hdr = &lntmsg->msg_hdr;
+	struct lnet_hdr *hdr = &lntmsg->msg_hdr;
 	int type = lntmsg->msg_type;
 	lnet_process_id_t target = lntmsg->msg_target;
 	int target_is_router = lntmsg->msg_target_is_router;
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h
index 842c453..9e86563 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h
@@ -373,7 +373,7 @@ struct ksock_conn {
 					       * V2.x message takes the
 					       * whole struct
 					       * V1.x message is a bare
-					       * lnet_hdr_t, it's stored in
+					       * struct lnet_hdr, it's stored in
 					       * ksnc_msg.ksm_u.lnetmsg
 					       */
 	/* WRITER */
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
index 42b67b0..3531e7d 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
@@ -1073,14 +1073,14 @@ struct ksock_route *
 			break;
 
 		case KSOCK_PROTO_V1:
-			/* Receiving bare lnet_hdr_t */
+			/* Receiving bare struct lnet_hdr */
 			conn->ksnc_rx_state = SOCKNAL_RX_LNET_HEADER;
-			conn->ksnc_rx_nob_wanted = sizeof(lnet_hdr_t);
-			conn->ksnc_rx_nob_left = sizeof(lnet_hdr_t);
+			conn->ksnc_rx_nob_wanted = sizeof(struct lnet_hdr);
+			conn->ksnc_rx_nob_left = sizeof(struct lnet_hdr);
 
 			conn->ksnc_rx_iov = (struct kvec *)&conn->ksnc_rx_iov_space;
 			conn->ksnc_rx_iov[0].iov_base = &conn->ksnc_msg.ksm_u.lnetmsg;
-			conn->ksnc_rx_iov[0].iov_len = sizeof(lnet_hdr_t);
+			conn->ksnc_rx_iov[0].iov_len = sizeof(struct lnet_hdr);
 			break;
 
 		default:
@@ -1126,7 +1126,7 @@ struct ksock_route *
 static int
 ksocknal_process_receive(struct ksock_conn *conn)
 {
-	lnet_hdr_t *lhdr;
+	struct lnet_hdr *lhdr;
 	lnet_process_id_t *id;
 	int rc;
 
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_proto.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_proto.c
index 420597b..b36f181 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_proto.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_proto.c
@@ -291,7 +291,7 @@
 	} else {
 		nob = tx->tx_lnetmsg->msg_len +
 		      ((conn->ksnc_proto == &ksocknal_protocol_v1x) ?
-		       sizeof(lnet_hdr_t) : sizeof(ksock_msg_t));
+		       sizeof(struct lnet_hdr) : sizeof(ksock_msg_t));
 	}
 
 	/* default checking for typed connection */
@@ -459,23 +459,23 @@
 ksocknal_send_hello_v1(struct ksock_conn *conn, ksock_hello_msg_t *hello)
 {
 	struct socket *sock = conn->ksnc_sock;
-	lnet_hdr_t *hdr;
+	struct lnet_hdr *hdr;
 	struct lnet_magicversion *hmv;
 	int rc;
 	int i;
 
-	CLASSERT(sizeof(struct lnet_magicversion) == offsetof(lnet_hdr_t, src_nid));
+	CLASSERT(sizeof(struct lnet_magicversion) == offsetof(struct lnet_hdr, src_nid));
 
 	LIBCFS_ALLOC(hdr, sizeof(*hdr));
 	if (!hdr) {
-		CERROR("Can't allocate lnet_hdr_t\n");
+		CERROR("Can't allocate struct lnet_hdr\n");
 		return -ENOMEM;
 	}
 
 	hmv = (struct lnet_magicversion *)&hdr->dest_nid;
 
 	/*
-	 * Re-organize V2.x message header to V1.x (lnet_hdr_t)
+	 * Re-organize V2.x message header to V1.x (struct lnet_hdr)
 	 * header and send out
 	 */
 	hmv->magic         = cpu_to_le32(LNET_PROTO_TCP_MAGIC);
@@ -577,18 +577,18 @@
 		       int timeout)
 {
 	struct socket *sock = conn->ksnc_sock;
-	lnet_hdr_t *hdr;
+	struct lnet_hdr *hdr;
 	int rc;
 	int i;
 
 	LIBCFS_ALLOC(hdr, sizeof(*hdr));
 	if (!hdr) {
-		CERROR("Can't allocate lnet_hdr_t\n");
+		CERROR("Can't allocate struct lnet_hdr\n");
 		return -ENOMEM;
 	}
 
 	rc = lnet_sock_read(sock, &hdr->src_nid,
-			    sizeof(*hdr) - offsetof(lnet_hdr_t, src_nid),
+			    sizeof(*hdr) - offsetof(struct lnet_hdr, src_nid),
 			    timeout);
 	if (rc) {
 		CERROR("Error %d reading rest of HELLO hdr from %pI4h\n",
@@ -723,10 +723,10 @@
 	LASSERT(tx->tx_lnetmsg);
 
 	tx->tx_iov[0].iov_base = &tx->tx_lnetmsg->msg_hdr;
-	tx->tx_iov[0].iov_len  = sizeof(lnet_hdr_t);
+	tx->tx_iov[0].iov_len  = sizeof(struct lnet_hdr);
 
-	tx->tx_nob = tx->tx_lnetmsg->msg_len + sizeof(lnet_hdr_t);
-	tx->tx_resid = tx->tx_lnetmsg->msg_len + sizeof(lnet_hdr_t);
+	tx->tx_nob = tx->tx_lnetmsg->msg_len + sizeof(struct lnet_hdr);
+	tx->tx_resid = tx->tx_lnetmsg->msg_len + sizeof(struct lnet_hdr);
 }
 
 static void
diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
index fd4153b..79f8534 100644
--- a/drivers/staging/lustre/lnet/lnet/api-ni.c
+++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
@@ -205,64 +205,64 @@ static void lnet_assert_wire_constants(void)
 	CLASSERT((int)offsetof(struct lnet_magicversion, version_minor) == 6);
 	CLASSERT((int)sizeof(((struct lnet_magicversion *)0)->version_minor) == 2);
 
-	/* Checks for struct lnet_hdr_t */
-	CLASSERT((int)sizeof(lnet_hdr_t) == 72);
-	CLASSERT((int)offsetof(lnet_hdr_t, dest_nid) == 0);
-	CLASSERT((int)sizeof(((lnet_hdr_t *)0)->dest_nid) == 8);
-	CLASSERT((int)offsetof(lnet_hdr_t, src_nid) == 8);
-	CLASSERT((int)sizeof(((lnet_hdr_t *)0)->src_nid) == 8);
-	CLASSERT((int)offsetof(lnet_hdr_t, dest_pid) == 16);
-	CLASSERT((int)sizeof(((lnet_hdr_t *)0)->dest_pid) == 4);
-	CLASSERT((int)offsetof(lnet_hdr_t, src_pid) == 20);
-	CLASSERT((int)sizeof(((lnet_hdr_t *)0)->src_pid) == 4);
-	CLASSERT((int)offsetof(lnet_hdr_t, type) == 24);
-	CLASSERT((int)sizeof(((lnet_hdr_t *)0)->type) == 4);
-	CLASSERT((int)offsetof(lnet_hdr_t, payload_length) == 28);
-	CLASSERT((int)sizeof(((lnet_hdr_t *)0)->payload_length) == 4);
-	CLASSERT((int)offsetof(lnet_hdr_t, msg) == 32);
-	CLASSERT((int)sizeof(((lnet_hdr_t *)0)->msg) == 40);
+	/* Checks for struct struct lnet_hdr */
+	CLASSERT((int)sizeof(struct lnet_hdr) == 72);
+	CLASSERT((int)offsetof(struct lnet_hdr, dest_nid) == 0);
+	CLASSERT((int)sizeof(((struct lnet_hdr *)0)->dest_nid) == 8);
+	CLASSERT((int)offsetof(struct lnet_hdr, src_nid) == 8);
+	CLASSERT((int)sizeof(((struct lnet_hdr *)0)->src_nid) == 8);
+	CLASSERT((int)offsetof(struct lnet_hdr, dest_pid) == 16);
+	CLASSERT((int)sizeof(((struct lnet_hdr *)0)->dest_pid) == 4);
+	CLASSERT((int)offsetof(struct lnet_hdr, src_pid) == 20);
+	CLASSERT((int)sizeof(((struct lnet_hdr *)0)->src_pid) == 4);
+	CLASSERT((int)offsetof(struct lnet_hdr, type) == 24);
+	CLASSERT((int)sizeof(((struct lnet_hdr *)0)->type) == 4);
+	CLASSERT((int)offsetof(struct lnet_hdr, payload_length) == 28);
+	CLASSERT((int)sizeof(((struct lnet_hdr *)0)->payload_length) == 4);
+	CLASSERT((int)offsetof(struct lnet_hdr, msg) == 32);
+	CLASSERT((int)sizeof(((struct lnet_hdr *)0)->msg) == 40);
 
 	/* Ack */
-	CLASSERT((int)offsetof(lnet_hdr_t, msg.ack.dst_wmd) == 32);
-	CLASSERT((int)sizeof(((lnet_hdr_t *)0)->msg.ack.dst_wmd) == 16);
-	CLASSERT((int)offsetof(lnet_hdr_t, msg.ack.match_bits) == 48);
-	CLASSERT((int)sizeof(((lnet_hdr_t *)0)->msg.ack.match_bits) == 8);
-	CLASSERT((int)offsetof(lnet_hdr_t, msg.ack.mlength) == 56);
-	CLASSERT((int)sizeof(((lnet_hdr_t *)0)->msg.ack.mlength) == 4);
+	CLASSERT((int)offsetof(struct lnet_hdr, msg.ack.dst_wmd) == 32);
+	CLASSERT((int)sizeof(((struct lnet_hdr *)0)->msg.ack.dst_wmd) == 16);
+	CLASSERT((int)offsetof(struct lnet_hdr, msg.ack.match_bits) == 48);
+	CLASSERT((int)sizeof(((struct lnet_hdr *)0)->msg.ack.match_bits) == 8);
+	CLASSERT((int)offsetof(struct lnet_hdr, msg.ack.mlength) == 56);
+	CLASSERT((int)sizeof(((struct lnet_hdr *)0)->msg.ack.mlength) == 4);
 
 	/* Put */
-	CLASSERT((int)offsetof(lnet_hdr_t, msg.put.ack_wmd) == 32);
-	CLASSERT((int)sizeof(((lnet_hdr_t *)0)->msg.put.ack_wmd) == 16);
-	CLASSERT((int)offsetof(lnet_hdr_t, msg.put.match_bits) == 48);
-	CLASSERT((int)sizeof(((lnet_hdr_t *)0)->msg.put.match_bits) == 8);
-	CLASSERT((int)offsetof(lnet_hdr_t, msg.put.hdr_data) == 56);
-	CLASSERT((int)sizeof(((lnet_hdr_t *)0)->msg.put.hdr_data) == 8);
-	CLASSERT((int)offsetof(lnet_hdr_t, msg.put.ptl_index) == 64);
-	CLASSERT((int)sizeof(((lnet_hdr_t *)0)->msg.put.ptl_index) == 4);
-	CLASSERT((int)offsetof(lnet_hdr_t, msg.put.offset) == 68);
-	CLASSERT((int)sizeof(((lnet_hdr_t *)0)->msg.put.offset) == 4);
+	CLASSERT((int)offsetof(struct lnet_hdr, msg.put.ack_wmd) == 32);
+	CLASSERT((int)sizeof(((struct lnet_hdr *)0)->msg.put.ack_wmd) == 16);
+	CLASSERT((int)offsetof(struct lnet_hdr, msg.put.match_bits) == 48);
+	CLASSERT((int)sizeof(((struct lnet_hdr *)0)->msg.put.match_bits) == 8);
+	CLASSERT((int)offsetof(struct lnet_hdr, msg.put.hdr_data) == 56);
+	CLASSERT((int)sizeof(((struct lnet_hdr *)0)->msg.put.hdr_data) == 8);
+	CLASSERT((int)offsetof(struct lnet_hdr, msg.put.ptl_index) == 64);
+	CLASSERT((int)sizeof(((struct lnet_hdr *)0)->msg.put.ptl_index) == 4);
+	CLASSERT((int)offsetof(struct lnet_hdr, msg.put.offset) == 68);
+	CLASSERT((int)sizeof(((struct lnet_hdr *)0)->msg.put.offset) == 4);
 
 	/* Get */
-	CLASSERT((int)offsetof(lnet_hdr_t, msg.get.return_wmd) == 32);
-	CLASSERT((int)sizeof(((lnet_hdr_t *)0)->msg.get.return_wmd) == 16);
-	CLASSERT((int)offsetof(lnet_hdr_t, msg.get.match_bits) == 48);
-	CLASSERT((int)sizeof(((lnet_hdr_t *)0)->msg.get.match_bits) == 8);
-	CLASSERT((int)offsetof(lnet_hdr_t, msg.get.ptl_index) == 56);
-	CLASSERT((int)sizeof(((lnet_hdr_t *)0)->msg.get.ptl_index) == 4);
-	CLASSERT((int)offsetof(lnet_hdr_t, msg.get.src_offset) == 60);
-	CLASSERT((int)sizeof(((lnet_hdr_t *)0)->msg.get.src_offset) == 4);
-	CLASSERT((int)offsetof(lnet_hdr_t, msg.get.sink_length) == 64);
-	CLASSERT((int)sizeof(((lnet_hdr_t *)0)->msg.get.sink_length) == 4);
+	CLASSERT((int)offsetof(struct lnet_hdr, msg.get.return_wmd) == 32);
+	CLASSERT((int)sizeof(((struct lnet_hdr *)0)->msg.get.return_wmd) == 16);
+	CLASSERT((int)offsetof(struct lnet_hdr, msg.get.match_bits) == 48);
+	CLASSERT((int)sizeof(((struct lnet_hdr *)0)->msg.get.match_bits) == 8);
+	CLASSERT((int)offsetof(struct lnet_hdr, msg.get.ptl_index) == 56);
+	CLASSERT((int)sizeof(((struct lnet_hdr *)0)->msg.get.ptl_index) == 4);
+	CLASSERT((int)offsetof(struct lnet_hdr, msg.get.src_offset) == 60);
+	CLASSERT((int)sizeof(((struct lnet_hdr *)0)->msg.get.src_offset) == 4);
+	CLASSERT((int)offsetof(struct lnet_hdr, msg.get.sink_length) == 64);
+	CLASSERT((int)sizeof(((struct lnet_hdr *)0)->msg.get.sink_length) == 4);
 
 	/* Reply */
-	CLASSERT((int)offsetof(lnet_hdr_t, msg.reply.dst_wmd) == 32);
-	CLASSERT((int)sizeof(((lnet_hdr_t *)0)->msg.reply.dst_wmd) == 16);
+	CLASSERT((int)offsetof(struct lnet_hdr, msg.reply.dst_wmd) == 32);
+	CLASSERT((int)sizeof(((struct lnet_hdr *)0)->msg.reply.dst_wmd) == 16);
 
 	/* Hello */
-	CLASSERT((int)offsetof(lnet_hdr_t, msg.hello.incarnation) == 32);
-	CLASSERT((int)sizeof(((lnet_hdr_t *)0)->msg.hello.incarnation) == 8);
-	CLASSERT((int)offsetof(lnet_hdr_t, msg.hello.type) == 40);
-	CLASSERT((int)sizeof(((lnet_hdr_t *)0)->msg.hello.type) == 4);
+	CLASSERT((int)offsetof(struct lnet_hdr, msg.hello.incarnation) == 32);
+	CLASSERT((int)sizeof(((struct lnet_hdr *)0)->msg.hello.incarnation) == 8);
+	CLASSERT((int)offsetof(struct lnet_hdr, msg.hello.type) == 40);
+	CLASSERT((int)sizeof(((struct lnet_hdr *)0)->msg.hello.type) == 4);
 }
 
 static lnd_t *
diff --git a/drivers/staging/lustre/lnet/lnet/lib-move.c b/drivers/staging/lustre/lnet/lnet/lib-move.c
index 595fde8..6b0be6c 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-move.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-move.c
@@ -641,7 +641,7 @@
 			!list_empty(&lp->lp_txq));
 
 		msg->msg_peertxcredit = 1;
-		lp->lp_txqnob += msg->msg_len + sizeof(lnet_hdr_t);
+		lp->lp_txqnob += msg->msg_len + sizeof(struct lnet_hdr);
 		lp->lp_txcredits--;
 
 		if (lp->lp_txcredits < lp->lp_mintxcredits)
@@ -811,7 +811,7 @@
 		LASSERT((txpeer->lp_txcredits < 0) ==
 			!list_empty(&txpeer->lp_txq));
 
-		txpeer->lp_txqnob -= msg->msg_len + sizeof(lnet_hdr_t);
+		txpeer->lp_txqnob -= msg->msg_len + sizeof(struct lnet_hdr);
 		LASSERT(txpeer->lp_txqnob >= 0);
 
 		txpeer->lp_txcredits++;
@@ -1245,7 +1245,7 @@
 static void
 lnet_recv_put(lnet_ni_t *ni, lnet_msg_t *msg)
 {
-	lnet_hdr_t *hdr = &msg->msg_hdr;
+	struct lnet_hdr *hdr = &msg->msg_hdr;
 
 	if (msg->msg_wanted)
 		lnet_setpayloadbuffer(msg);
@@ -1266,7 +1266,7 @@
 static int
 lnet_parse_put(lnet_ni_t *ni, lnet_msg_t *msg)
 {
-	lnet_hdr_t *hdr = &msg->msg_hdr;
+	struct lnet_hdr *hdr = &msg->msg_hdr;
 	struct lnet_match_info info;
 	bool ready_delay;
 	int rc;
@@ -1325,7 +1325,7 @@
 lnet_parse_get(lnet_ni_t *ni, lnet_msg_t *msg, int rdma_get)
 {
 	struct lnet_match_info info;
-	lnet_hdr_t *hdr = &msg->msg_hdr;
+	struct lnet_hdr *hdr = &msg->msg_hdr;
 	struct lnet_handle_wire reply_wmd;
 	int rc;
 
@@ -1389,7 +1389,7 @@
 lnet_parse_reply(lnet_ni_t *ni, lnet_msg_t *msg)
 {
 	void *private = msg->msg_private;
-	lnet_hdr_t *hdr = &msg->msg_hdr;
+	struct lnet_hdr *hdr = &msg->msg_hdr;
 	lnet_process_id_t src = {0};
 	lnet_libmd_t *md;
 	int rlength;
@@ -1453,7 +1453,7 @@
 static int
 lnet_parse_ack(lnet_ni_t *ni, lnet_msg_t *msg)
 {
-	lnet_hdr_t *hdr = &msg->msg_hdr;
+	struct lnet_hdr *hdr = &msg->msg_hdr;
 	lnet_process_id_t src = {0};
 	lnet_libmd_t *md;
 	int cpt;
@@ -1576,7 +1576,7 @@
 }
 
 void
-lnet_print_hdr(lnet_hdr_t *hdr)
+lnet_print_hdr(struct lnet_hdr *hdr)
 {
 	lnet_process_id_t src = {0};
 	lnet_process_id_t dst = {0};
@@ -1634,7 +1634,7 @@
 }
 
 int
-lnet_parse(lnet_ni_t *ni, lnet_hdr_t *hdr, lnet_nid_t from_nid,
+lnet_parse(lnet_ni_t *ni, struct lnet_hdr *hdr, lnet_nid_t from_nid,
 	   void *private, int rdma_req)
 {
 	int rc = 0;
diff --git a/drivers/staging/lustre/lnet/lnet/lib-msg.c b/drivers/staging/lustre/lnet/lnet/lib-msg.c
index 1262616..7ee164e 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-msg.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-msg.c
@@ -56,7 +56,7 @@
 void
 lnet_build_msg_event(lnet_msg_t *msg, lnet_event_kind_t ev_type)
 {
-	lnet_hdr_t *hdr = &msg->msg_hdr;
+	struct lnet_hdr *hdr = &msg->msg_hdr;
 	lnet_event_t *ev  = &msg->msg_ev;
 
 	LASSERT(!msg->msg_routing);
diff --git a/drivers/staging/lustre/lnet/lnet/lib-ptl.c b/drivers/staging/lustre/lnet/lnet/lib-ptl.c
index 3947e8b..fa515af 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-ptl.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-ptl.c
@@ -680,7 +680,7 @@ struct list_head *
  again:
 	list_for_each_entry_safe(msg, tmp, head, msg_list) {
 		struct lnet_match_info info;
-		lnet_hdr_t *hdr;
+		struct lnet_hdr *hdr;
 		int rc;
 
 		LASSERT(msg->msg_rx_delayed || head == &ptl->ptl_msg_stealing);
diff --git a/drivers/staging/lustre/lnet/lnet/net_fault.c b/drivers/staging/lustre/lnet/lnet/net_fault.c
index e4aceb7..bb6e457 100644
--- a/drivers/staging/lustre/lnet/lnet/net_fault.c
+++ b/drivers/staging/lustre/lnet/lnet/net_fault.c
@@ -349,7 +349,7 @@ struct lnet_drop_rule {
  * Check if message from \a src to \a dst can match any existed drop rule
  */
 bool
-lnet_drop_rule_match(lnet_hdr_t *hdr)
+lnet_drop_rule_match(struct lnet_hdr *hdr)
 {
 	struct lnet_drop_rule *rule;
 	lnet_nid_t src = le64_to_cpu(hdr->src_nid);
@@ -530,7 +530,7 @@ struct delay_daemon_data {
  * will be delayed if there is a match.
  */
 bool
-lnet_delay_rule_match_locked(lnet_hdr_t *hdr, struct lnet_msg *msg)
+lnet_delay_rule_match_locked(struct lnet_hdr *hdr, struct lnet_msg *msg)
 {
 	struct lnet_delay_rule *rule;
 	lnet_nid_t src = le64_to_cpu(hdr->src_nid);
-- 
1.8.3.1
