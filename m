From: NeilBrown <neilb@suse.com>
Date: Thu, 14 Mar 2019 11:11:50 +1100
Subject: [lustre-devel] [PATCH 17/32] lustre: socklnd: discard tx_iov.
In-Reply-To: <155252182126.26912.1842463462595601611.stgit@noble.brown>
References: <155252182126.26912.1842463462595601611.stgit@noble.brown>
Message-ID: <155252231059.26912.10541325763537609171.stgit@noble.brown>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

tx_iov always points to tx_hdr, so we can discard tx_iov,
and just use &tx_hdr.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../staging/lustre/lnet/klnds/socklnd/socklnd.h    |    3 +-
 .../staging/lustre/lnet/klnds/socklnd/socklnd_cb.c |   34 +++++++++-----------
 .../lustre/lnet/klnds/socklnd/socklnd_lib.c        |   20 +++++-------
 .../lustre/lnet/klnds/socklnd/socklnd_proto.c      |   17 ++++++----
 4 files changed, 34 insertions(+), 40 deletions(-)

diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h
index 738c7cd2b484..c57b80232c1b 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h
@@ -276,7 +276,6 @@ struct ksock_tx {				/* transmit packet */
 	int			tx_nob;		/* # packet bytes */
 	int			tx_resid;	/* residual bytes */
 	int			tx_niov;	/* # packet iovec frags */
-	struct kvec		*tx_iov;	/* packet iovec frags */
 	int			tx_nkiov;	/* # packet page frags */
 	unsigned short		tx_zc_aborted;	/* aborted ZC request */
 	unsigned short		tx_zc_capable:1;/* payload is large enough for ZC */
@@ -684,7 +683,7 @@ void ksocknal_lib_reset_callback(struct socket *sock, struct ksock_conn *conn);
 void ksocknal_lib_push_conn(struct ksock_conn *conn);
 int ksocknal_lib_get_conn_addrs(struct ksock_conn *conn);
 int ksocknal_lib_setup_sock(struct socket *so);
-int ksocknal_lib_send_iov(struct ksock_conn *conn, struct ksock_tx *tx);
+int ksocknal_lib_send_hdr(struct ksock_conn *conn, struct ksock_tx *tx);
 int ksocknal_lib_send_kiov(struct ksock_conn *conn, struct ksock_tx *tx);
 void ksocknal_lib_eager_ack(struct ksock_conn *conn);
 int ksocknal_lib_recv(struct ksock_conn *conn);
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
index f137c875ed66..d3fd7735649e 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
@@ -78,7 +78,6 @@ ksocknal_alloc_tx_noop(u64 cookie, int nonblk)
 	tx->tx_lnetmsg = NULL;
 	tx->tx_kiov = NULL;
 	tx->tx_nkiov = 0;
-	tx->tx_iov = &tx->tx_hdr;
 	tx->tx_niov = 1;
 	tx->tx_nonblk = nonblk;
 
@@ -108,16 +107,16 @@ ksocknal_free_tx(struct ksock_tx *tx)
 }
 
 static int
-ksocknal_send_iov(struct ksock_conn *conn, struct ksock_tx *tx)
+ksocknal_send_hdr(struct ksock_conn *conn, struct ksock_tx *tx)
 {
-	struct kvec *iov = tx->tx_iov;
+	struct kvec *iov = &tx->tx_hdr;
 	int nob;
 	int rc;
 
 	LASSERT(tx->tx_niov > 0);
 
-	/* Never touch tx->tx_iov inside ksocknal_lib_send_iov() */
-	rc = ksocknal_lib_send_iov(conn, tx);
+	/* Never change tx->tx_hdr inside ksocknal_lib_send_hdr() */
+	rc = ksocknal_lib_send_hdr(conn, tx);
 
 	if (rc <= 0)			    /* sent nothing? */
 		return rc;
@@ -127,19 +126,17 @@ ksocknal_send_iov(struct ksock_conn *conn, struct ksock_tx *tx)
 	tx->tx_resid -= nob;
 
 	/* "consume" iov */
-	do {
-		LASSERT(tx->tx_niov > 0);
 
-		if (nob < (int)iov->iov_len) {
-			iov->iov_base = (void *)((char *)iov->iov_base + nob);
-			iov->iov_len -= nob;
-			return rc;
-		}
+	LASSERT(tx->tx_niov == 1);
 
-		nob -= iov->iov_len;
-		tx->tx_iov = ++iov;
-		tx->tx_niov--;
-	} while (nob);
+	if (nob < (int)iov->iov_len) {
+		iov->iov_base = (void *)((char *)iov->iov_base + nob);
+		iov->iov_len -= nob;
+		return rc;
+	}
+
+	LASSERT(nob == iov->iov_len);
+	tx->tx_niov--;
 
 	return rc;
 }
@@ -206,7 +203,7 @@ ksocknal_transmit(struct ksock_conn *conn, struct ksock_tx *tx)
 			ksocknal_data.ksnd_enomem_tx--;
 			rc = -EAGAIN;
 		} else if (tx->tx_niov) {
-			rc = ksocknal_send_iov(conn, tx);
+			rc = ksocknal_send_hdr(conn, tx);
 		} else {
 			rc = ksocknal_send_kiov(conn, tx);
 		}
@@ -648,7 +645,7 @@ ksocknal_queue_tx_locked(struct ksock_tx *tx, struct ksock_conn *conn)
 	 * We always expect at least 1 mapped fragment containing the
 	 * complete ksocknal message header.
 	 */
-	LASSERT(lnet_iov_nob(tx->tx_niov, tx->tx_iov) +
+	LASSERT(lnet_iov_nob(tx->tx_niov, &tx->tx_hdr) +
 		lnet_kiov_nob(tx->tx_nkiov, tx->tx_kiov) ==
 		(unsigned int)tx->tx_nob);
 	LASSERT(tx->tx_niov >= 1);
@@ -903,7 +900,6 @@ ksocknal_send(struct lnet_ni *ni, void *private, struct lnet_msg *lntmsg)
 	tx->tx_lnetmsg = lntmsg;
 
 	tx->tx_niov = 1;
-	tx->tx_iov = &tx->tx_hdr;
 	tx->tx_kiov = tx->tx_payload;
 	tx->tx_nkiov = lnet_extract_kiov(payload_niov, tx->tx_kiov,
 					 payload_niov, payload_kiov,
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib.c
index a190869eb5b2..a4dc384c298e 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib.c
@@ -73,11 +73,11 @@ ksocknal_lib_zc_capable(struct ksock_conn *conn)
 }
 
 int
-ksocknal_lib_send_iov(struct ksock_conn *conn, struct ksock_tx *tx)
+ksocknal_lib_send_hdr(struct ksock_conn *conn, struct ksock_tx *tx)
 {
 	struct msghdr msg = { .msg_flags = MSG_DONTWAIT };
 	struct socket *sock = conn->ksnc_sock;
-	int nob, i;
+	int nob;
 
 	if (*ksocknal_tunables.ksnd_enable_csum	&&		/* checksum enabled */
 	    conn->ksnc_proto == &ksocknal_protocol_v2x &&	/* V2.x connection */
@@ -85,15 +85,15 @@ ksocknal_lib_send_iov(struct ksock_conn *conn, struct ksock_tx *tx)
 	    !tx->tx_msg.ksm_csum)				/* not checksummed */
 		ksocknal_lib_csum_tx(tx);
 
-	for (nob = i = 0; i < tx->tx_niov; i++)
-		nob += tx->tx_iov[i].iov_len;
+	if (tx->tx_niov)
+		nob += tx->tx_hdr.iov_len;
 
 	if (!list_empty(&conn->ksnc_tx_queue) ||
 	    nob < tx->tx_resid)
 		msg.msg_flags |= MSG_MORE;
 
 	iov_iter_kvec(&msg.msg_iter, WRITE,
-		      tx->tx_iov, tx->tx_niov, nob);
+		      &tx->tx_hdr, tx->tx_niov, nob);
 	return sock_sendmsg(sock, &msg);
 }
 
@@ -208,14 +208,14 @@ ksocknal_lib_csum_tx(struct ksock_tx *tx)
 	u32 csum;
 	void *base;
 
-	LASSERT(tx->tx_iov[0].iov_base == &tx->tx_msg);
+	LASSERT(tx->tx_hdr.iov_base == &tx->tx_msg);
 	LASSERT(tx->tx_conn);
 	LASSERT(tx->tx_conn->ksnc_proto == &ksocknal_protocol_v2x);
 
 	tx->tx_msg.ksm_csum = 0;
 
-	csum = crc32_le(~0, tx->tx_iov[0].iov_base,
-			tx->tx_iov[0].iov_len);
+	csum = crc32_le(~0, tx->tx_hdr.iov_base,
+			tx->tx_hdr.iov_len);
 
 	if (tx->tx_kiov) {
 		for (i = 0; i < tx->tx_nkiov; i++) {
@@ -226,10 +226,6 @@ ksocknal_lib_csum_tx(struct ksock_tx *tx)
 
 			kunmap(tx->tx_kiov[i].bv_page);
 		}
-	} else {
-		for (i = 1; i < tx->tx_niov; i++)
-			csum = crc32_le(csum, tx->tx_iov[i].iov_base,
-					tx->tx_iov[i].iov_len);
 	}
 
 	if (*ksocknal_tunables.ksnd_inject_csum_error) {
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_proto.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_proto.c
index fca63763c260..7f32946e922f 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_proto.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_proto.c
@@ -721,8 +721,8 @@ ksocknal_pack_msg_v1(struct ksock_tx *tx)
 	LASSERT(tx->tx_msg.ksm_type != KSOCK_MSG_NOOP);
 	LASSERT(tx->tx_lnetmsg);
 
-	tx->tx_iov[0].iov_base = &tx->tx_lnetmsg->msg_hdr;
-	tx->tx_iov[0].iov_len = sizeof(struct lnet_hdr);
+	tx->tx_hdr.iov_base = &tx->tx_lnetmsg->msg_hdr;
+	tx->tx_hdr.iov_len = sizeof(struct lnet_hdr);
 
 	tx->tx_nob = tx->tx_lnetmsg->msg_len + sizeof(struct lnet_hdr);
 	tx->tx_resid = tx->tx_lnetmsg->msg_len + sizeof(struct lnet_hdr);
@@ -731,21 +731,24 @@ ksocknal_pack_msg_v1(struct ksock_tx *tx)
 static void
 ksocknal_pack_msg_v2(struct ksock_tx *tx)
 {
-	tx->tx_iov[0].iov_base = &tx->tx_msg;
+	tx->tx_hdr.iov_base = &tx->tx_msg;
 
 	if (tx->tx_lnetmsg) {
 		LASSERT(tx->tx_msg.ksm_type != KSOCK_MSG_NOOP);
 
 		tx->tx_msg.ksm_u.lnetmsg.ksnm_hdr = tx->tx_lnetmsg->msg_hdr;
-		tx->tx_iov[0].iov_len = sizeof(struct ksock_msg);
+		tx->tx_hdr.iov_len = sizeof(struct ksock_msg);
 		tx->tx_nob = sizeof(struct ksock_msg) + tx->tx_lnetmsg->msg_len;
 		tx->tx_resid = sizeof(struct ksock_msg) + tx->tx_lnetmsg->msg_len;
 	} else {
 		LASSERT(tx->tx_msg.ksm_type == KSOCK_MSG_NOOP);
 
-		tx->tx_iov[0].iov_len = offsetof(struct ksock_msg, ksm_u.lnetmsg.ksnm_hdr);
-		tx->tx_nob = offsetof(struct ksock_msg,  ksm_u.lnetmsg.ksnm_hdr);
-		tx->tx_resid = offsetof(struct ksock_msg,  ksm_u.lnetmsg.ksnm_hdr);
+		tx->tx_hdr.iov_len = offsetof(struct ksock_msg,
+					      ksm_u.lnetmsg.ksnm_hdr);
+		tx->tx_nob = offsetof(struct ksock_msg,
+				      ksm_u.lnetmsg.ksnm_hdr);
+		tx->tx_resid = offsetof(struct ksock_msg,
+					ksm_u.lnetmsg.ksnm_hdr);
 	}
 	/*
 	 * Don't checksum before start sending, because packet can be
