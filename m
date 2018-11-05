From: James Simmons <jsimmons@infradead.org>
Date: Mon,  5 Nov 2018 13:18:07 -0500
Subject: [lustre-devel] [PATCH] lustre: remove iter type from
 iov_iter_[b|k]vec()
Message-ID: <1541441887-15064-1-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

The linux commit aa563d7bca6e ("iov_iter: Separate type from
direction and use accessor functions) removed the iter type
from both iov_iter_bvec() and iov_iter_kvec(). Update lustre
to this change. Without it we see in testing:

WARNING: CPU: 2 PID: 3088 at lib/iov_iter.c:1082 iov_iter_kvec+0x25/0x30

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c  | 4 ++--
 drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c  | 8 ++++----
 drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib.c | 4 ++--
 drivers/staging/lustre/lnet/lnet/lib-move.c             | 4 ++--
 drivers/staging/lustre/lnet/lnet/lib-socket.c           | 4 ++--
 5 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
index 23ce59e..57fe037 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -1548,11 +1548,11 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
 	LASSERT(!(payload_kiov && payload_iov));
 
 	if (payload_kiov)
-		iov_iter_bvec(&from, ITER_BVEC | WRITE,
+		iov_iter_bvec(&from, WRITE,
 			      payload_kiov, payload_niov,
 			      payload_nob + payload_offset);
 	else
-		iov_iter_kvec(&from, ITER_KVEC | WRITE,
+		iov_iter_kvec(&from, WRITE,
 			      payload_iov, payload_niov,
 			      payload_nob + payload_offset);
 
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
index c401896..4abf0eb 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
@@ -1001,7 +1001,7 @@ struct ksock_route *
 			kvec->iov_base = &conn->ksnc_msg;
 			kvec->iov_len = offsetof(struct ksock_msg, ksm_u);
 			conn->ksnc_rx_nob_left = offsetof(struct ksock_msg, ksm_u);
-			iov_iter_kvec(&conn->ksnc_rx_to, READ|ITER_KVEC, kvec,
+			iov_iter_kvec(&conn->ksnc_rx_to, READ, kvec,
 					1, offsetof(struct ksock_msg, ksm_u));
 			break;
 
@@ -1011,7 +1011,7 @@ struct ksock_route *
 			kvec->iov_base = &conn->ksnc_msg.ksm_u.lnetmsg;
 			kvec->iov_len = sizeof(struct lnet_hdr);
 			conn->ksnc_rx_nob_left = sizeof(struct lnet_hdr);
-			iov_iter_kvec(&conn->ksnc_rx_to, READ|ITER_KVEC, kvec,
+			iov_iter_kvec(&conn->ksnc_rx_to, READ, kvec,
 					1, sizeof(struct lnet_hdr));
 			break;
 
@@ -1043,7 +1043,7 @@ struct ksock_route *
 	} while (nob_to_skip &&    /* mustn't overflow conn's rx iov */
 		 niov < sizeof(conn->ksnc_rx_iov_space) / sizeof(struct iovec));
 
-	iov_iter_kvec(&conn->ksnc_rx_to, READ|ITER_KVEC, kvec, niov, skipped);
+	iov_iter_kvec(&conn->ksnc_rx_to, READ, kvec, niov, skipped);
 	return 0;
 }
 
@@ -1157,7 +1157,7 @@ struct ksock_route *
 		kvec->iov_base = &conn->ksnc_msg.ksm_u.lnetmsg;
 		kvec->iov_len = sizeof(struct ksock_lnet_msg);
 
-		iov_iter_kvec(&conn->ksnc_rx_to, READ|ITER_KVEC, kvec,
+		iov_iter_kvec(&conn->ksnc_rx_to, READ, kvec,
 				1, sizeof(struct ksock_lnet_msg));
 
 		goto again;     /* read lnet header now */
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib.c
index 33847b9..686c2d3 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib.c
@@ -92,7 +92,7 @@
 	    nob < tx->tx_resid)
 		msg.msg_flags |= MSG_MORE;
 
-	iov_iter_kvec(&msg.msg_iter, WRITE | ITER_KVEC,
+	iov_iter_kvec(&msg.msg_iter, WRITE,
 		      tx->tx_iov, tx->tx_niov, nob);
 	return sock_sendmsg(sock, &msg);
 }
@@ -140,7 +140,7 @@
 		    nob < tx->tx_resid)
 			msg.msg_flags |= MSG_MORE;
 
-		iov_iter_bvec(&msg.msg_iter, WRITE | ITER_BVEC,
+		iov_iter_bvec(&msg.msg_iter, WRITE,
 			      kiov, tx->tx_nkiov, nob);
 		rc = sock_sendmsg(sock, &msg);
 	}
diff --git a/drivers/staging/lustre/lnet/lnet/lib-move.c b/drivers/staging/lustre/lnet/lnet/lib-move.c
index 5694d85..eaa1dfa 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-move.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-move.c
@@ -498,10 +498,10 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 	}
 
 	if (iov) {
-		iov_iter_kvec(&to, ITER_KVEC | READ, iov, niov, mlen + offset);
+		iov_iter_kvec(&to, READ, iov, niov, mlen + offset);
 		iov_iter_advance(&to, offset);
 	} else {
-		iov_iter_bvec(&to, ITER_BVEC | READ, kiov, niov, mlen + offset);
+		iov_iter_bvec(&to, READ, kiov, niov, mlen + offset);
 		iov_iter_advance(&to, offset);
 	}
 	rc = ni->ni_net->net_lnd->lnd_recv(ni, private, msg, delayed, &to, rlen);
diff --git a/drivers/staging/lustre/lnet/lnet/lib-socket.c b/drivers/staging/lustre/lnet/lnet/lib-socket.c
index d9c62d3..62a742e 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-socket.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-socket.c
@@ -58,7 +58,7 @@
 	 * Caller may pass a zero timeout if she thinks the socket buffer is
 	 * empty enough to take the whole message immediately
 	 */
-	iov_iter_kvec(&msg.msg_iter, WRITE | ITER_KVEC, &iov, 1, nob);
+	iov_iter_kvec(&msg.msg_iter, WRITE, &iov, 1, nob);
 	for (;;) {
 		msg.msg_flags = !timeout ? MSG_DONTWAIT : 0;
 		if (timeout) {
@@ -113,7 +113,7 @@
 	LASSERT(nob > 0);
 	LASSERT(jiffies_left > 0);
 
-	iov_iter_kvec(&msg.msg_iter, READ | ITER_KVEC, &iov, 1, nob);
+	iov_iter_kvec(&msg.msg_iter, READ, &iov, 1, nob);
 
 	for (;;) {
 		/* Set receive timeout to remaining time */
-- 
1.8.3.1
