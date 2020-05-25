From: James Simmons <jsimmons@infradead.org>
Date: Mon, 25 May 2020 18:08:17 -0400
Subject: [lustre-devel] [PATCH 40/45] lnet: socklnd: discard tx_iov.
In-Reply-To: <1590444502-20533-1-git-send-email-jsimmons@infradead.org>
References: <1590444502-20533-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1590444502-20533-41-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mr NeilBrown <neilb@suse.de>

tx_iov always points to tx_hdr, so we can discard tx_iov, and just use
&tx_hdr.

WC-bug-id: https://jira.whamcloud.com/browse/LU-13004
Lustre-commit: 89637985b9897 ("LU-13004 socklnd: discard tx_iov.")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/37851
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Shaun Tancheff <shaun.tancheff@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/klnds/socklnd/socklnd.h       |  3 +--
 net/lnet/klnds/socklnd/socklnd_cb.c    | 33 ++++++++++++++-------------------
 net/lnet/klnds/socklnd/socklnd_lib.c   | 32 +++++++++++++-------------------
 net/lnet/klnds/socklnd/socklnd_proto.c | 10 +++++-----
 4 files changed, 33 insertions(+), 45 deletions(-)

diff --git a/net/lnet/klnds/socklnd/socklnd.h b/net/lnet/klnds/socklnd/socklnd.h
index f85eb3c..6c77b75 100644
--- a/net/lnet/klnds/socklnd/socklnd.h
+++ b/net/lnet/klnds/socklnd/socklnd.h
@@ -277,7 +277,6 @@ struct ksock_tx {				/* transmit packet */
 	int			tx_nob;		/* # packet bytes */
 	int			tx_resid;	/* residual bytes */
 	int			tx_niov;	/* # packet iovec frags */
-	struct kvec		*tx_iov;	/* packet iovec frags */
 	int			tx_nkiov;	/* # packet page frags */
 	unsigned short		tx_zc_aborted;	/* aborted ZC request */
 	unsigned short		tx_zc_capable:1;/* payload is large enough for ZC */
@@ -675,7 +674,7 @@ int ksocknal_recv_hello(struct lnet_ni *ni, struct ksock_conn *conn,
 void ksocknal_lib_push_conn(struct ksock_conn *conn);
 int ksocknal_lib_get_conn_addrs(struct ksock_conn *conn);
 int ksocknal_lib_setup_sock(struct socket *so);
-int ksocknal_lib_send_iov(struct ksock_conn *conn, struct ksock_tx *tx);
+int ksocknal_lib_send_hdr(struct ksock_conn *conn, struct ksock_tx *tx);
 int ksocknal_lib_send_kiov(struct ksock_conn *conn, struct ksock_tx *tx);
 void ksocknal_lib_eager_ack(struct ksock_conn *conn);
 int ksocknal_lib_recv(struct ksock_conn *conn);
diff --git a/net/lnet/klnds/socklnd/socklnd_cb.c b/net/lnet/klnds/socklnd/socklnd_cb.c
index b40fbf1..c03f91c7 100644
--- a/net/lnet/klnds/socklnd/socklnd_cb.c
+++ b/net/lnet/klnds/socklnd/socklnd_cb.c
@@ -79,7 +79,6 @@ struct ksock_tx *
 	tx->tx_lnetmsg = NULL;
 	tx->tx_kiov = NULL;
 	tx->tx_nkiov = 0;
-	tx->tx_iov = &tx->tx_hdr;
 	tx->tx_niov = 1;
 	tx->tx_nonblk = nonblk;
 
@@ -109,16 +108,16 @@ struct ksock_tx *
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
+	/* Never touch tx->tx_hdr inside ksocknal_lib_send_hdr() */
+	rc = ksocknal_lib_send_hdr(conn, tx);
 
 	if (rc <= 0)			/* sent nothing? */
 		return rc;
@@ -128,19 +127,16 @@ struct ksock_tx *
 	tx->tx_resid -= nob;
 
 	/* "consume" iov */
-	do {
-		LASSERT(tx->tx_niov > 0);
+	LASSERT(tx->tx_niov == 1);
 
-		if (nob < (int)iov->iov_len) {
-			iov->iov_base = (void *)((char *)iov->iov_base + nob);
-			iov->iov_len -= nob;
-			return rc;
-		}
+	if (nob < (int)iov->iov_len) {
+		iov->iov_base += nob;
+		iov->iov_len -= nob;
+		return rc;
+	}
 
-		nob -= iov->iov_len;
-		tx->tx_iov = ++iov;
-		tx->tx_niov--;
-	} while (nob);
+	LASSERT(nob == iov->iov_len);
+	tx->tx_niov--;
 
 	return rc;
 }
@@ -207,7 +203,7 @@ struct ksock_tx *
 			ksocknal_data.ksnd_enomem_tx--;
 			rc = -EAGAIN;
 		} else if (tx->tx_niov) {
-			rc = ksocknal_send_iov(conn, tx);
+			rc = ksocknal_send_hdr(conn, tx);
 		} else {
 			rc = ksocknal_send_kiov(conn, tx);
 		}
@@ -694,7 +690,7 @@ struct ksock_conn *
 	 * We always expect at least 1 mapped fragment containing the
 	 * complete ksocknal message header.
 	 */
-	LASSERT(lnet_iov_nob(tx->tx_niov, tx->tx_iov) +
+	LASSERT(lnet_iov_nob(tx->tx_niov, &tx->tx_hdr) +
 		lnet_kiov_nob(tx->tx_nkiov, tx->tx_kiov) ==
 		(unsigned int)tx->tx_nob);
 	LASSERT(tx->tx_niov >= 1);
@@ -950,7 +946,6 @@ struct ksock_route *
 	tx->tx_lnetmsg = lntmsg;
 
 	tx->tx_niov = 1;
-	tx->tx_iov = &tx->tx_hdr;
 	tx->tx_kiov = tx->tx_payload;
 	tx->tx_nkiov = lnet_extract_kiov(payload_niov, tx->tx_kiov,
 					 payload_niov, payload_kiov,
diff --git a/net/lnet/klnds/socklnd/socklnd_lib.c b/net/lnet/klnds/socklnd/socklnd_lib.c
index 251c28f..2adc99c 100644
--- a/net/lnet/klnds/socklnd/socklnd_lib.c
+++ b/net/lnet/klnds/socklnd/socklnd_lib.c
@@ -73,11 +73,11 @@
 }
 
 int
-ksocknal_lib_send_iov(struct ksock_conn *conn, struct ksock_tx *tx)
+ksocknal_lib_send_hdr(struct ksock_conn *conn, struct ksock_tx *tx)
 {
 	struct msghdr msg = { .msg_flags = MSG_DONTWAIT };
 	struct socket *sock = conn->ksnc_sock;
-	int nob, i;
+	int nob = 0;
 
 	if (*ksocknal_tunables.ksnd_enable_csum	&&		/* checksum enabled */
 	    conn->ksnc_proto == &ksocknal_protocol_v2x &&	/* V2.x connection */
@@ -85,15 +85,15 @@
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
 
@@ -208,28 +208,22 @@ static int lustre_csum(struct kvec *v, void *context)
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
 
-	if (tx->tx_kiov) {
-		for (i = 0; i < tx->tx_nkiov; i++) {
-			base = kmap(tx->tx_kiov[i].bv_page) +
-			       tx->tx_kiov[i].bv_offset;
+	for (i = 0; i < tx->tx_nkiov; i++) {
+		base = kmap(tx->tx_kiov[i].bv_page) +
+		       tx->tx_kiov[i].bv_offset;
 
-			csum = crc32_le(csum, base, tx->tx_kiov[i].bv_len);
+		csum = crc32_le(csum, base, tx->tx_kiov[i].bv_len);
 
-			kunmap(tx->tx_kiov[i].bv_page);
-		}
-	} else {
-		for (i = 1; i < tx->tx_niov; i++)
-			csum = crc32_le(csum, tx->tx_iov[i].iov_base,
-					tx->tx_iov[i].iov_len);
+		kunmap(tx->tx_kiov[i].bv_page);
 	}
 
 	if (*ksocknal_tunables.ksnd_inject_csum_error) {
diff --git a/net/lnet/klnds/socklnd/socklnd_proto.c b/net/lnet/klnds/socklnd/socklnd_proto.c
index 183bb39..bc9f349 100644
--- a/net/lnet/klnds/socklnd/socklnd_proto.c
+++ b/net/lnet/klnds/socklnd/socklnd_proto.c
@@ -711,8 +711,8 @@
 	LASSERT(tx->tx_msg.ksm_type != KSOCK_MSG_NOOP);
 	LASSERT(tx->tx_lnetmsg);
 
-	tx->tx_iov[0].iov_base = &tx->tx_lnetmsg->msg_hdr;
-	tx->tx_iov[0].iov_len = sizeof(struct lnet_hdr);
+	tx->tx_hdr.iov_base = &tx->tx_lnetmsg->msg_hdr;
+	tx->tx_hdr.iov_len = sizeof(struct lnet_hdr);
 
 	tx->tx_nob = tx->tx_lnetmsg->msg_len + sizeof(struct lnet_hdr);
 	tx->tx_resid = tx->tx_lnetmsg->msg_len + sizeof(struct lnet_hdr);
@@ -721,19 +721,19 @@
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
+		tx->tx_hdr.iov_len = offsetof(struct ksock_msg, ksm_u.lnetmsg.ksnm_hdr);
 		tx->tx_nob = offsetof(struct ksock_msg,  ksm_u.lnetmsg.ksnm_hdr);
 		tx->tx_resid = offsetof(struct ksock_msg,  ksm_u.lnetmsg.ksnm_hdr);
 	}
-- 
1.8.3.1
