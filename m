From: Oleg Drokin <green@linuxhacker.ru>
Date: Sat, 20 Aug 2016 17:34:23 -0400
Subject: [lustre-devel] [PATCH 06/13] lustre: pass iov_iter to ->lnd_recv()
In-Reply-To: <1471728870-518753-1-git-send-email-green@linuxhacker.ru>
References: <1471728870-518753-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1471728870-518753-7-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Al Viro <viro@zeniv.linux.org.uk>, Oleg Drokin <green@linuxhacker.ru>

From: Al Viro <viro@zeniv.linux.org.uk>

Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 .../staging/lustre/include/linux/lnet/lib-types.h  |  5 +---
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h    |  3 +-
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c | 32 ++++++++++++----------
 .../staging/lustre/lnet/klnds/socklnd/socklnd.h    |  4 +--
 .../staging/lustre/lnet/klnds/socklnd/socklnd_cb.c | 21 ++++++--------
 drivers/staging/lustre/lnet/lnet/lib-move.c        | 11 ++++++--
 drivers/staging/lustre/lnet/lnet/lo.c              | 24 ++++++++--------
 7 files changed, 49 insertions(+), 51 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/lib-types.h b/drivers/staging/lustre/include/linux/lnet/lib-types.h
index 7967b01..640ff72 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-types.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-types.h
@@ -220,10 +220,7 @@ typedef struct lnet_lnd {
 	 * credit if the LND does flow control.
 	 */
 	int (*lnd_recv)(struct lnet_ni *ni, void *private, lnet_msg_t *msg,
-			int delayed, unsigned int niov,
-			struct kvec *iov, lnet_kiov_t *kiov,
-			unsigned int offset, unsigned int mlen,
-			unsigned int rlen);
+			int delayed, struct iov_iter *to, unsigned int rlen);
 
 	/*
 	 * lnet_parse() has had to delay processing of this message
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
index 078a0c3..f49483e 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
@@ -1034,5 +1034,4 @@ int  kiblnd_post_rx(struct kib_rx *rx, int credit);
 
 int  kiblnd_send(lnet_ni_t *ni, void *private, lnet_msg_t *lntmsg);
 int  kiblnd_recv(lnet_ni_t *ni, void *private, lnet_msg_t *lntmsg, int delayed,
-		 unsigned int niov, struct kvec *iov, lnet_kiov_t *kiov,
-		 unsigned int offset, unsigned int mlen, unsigned int rlen);
+		 struct iov_iter *to, unsigned int rlen);
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
index 9eb1db6..1b20ae8 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -648,7 +648,7 @@ static int kiblnd_map_tx(lnet_ni_t *ni, struct kib_tx *tx, struct kib_rdma_desc
 
 static int
 kiblnd_setup_rd_iov(lnet_ni_t *ni, struct kib_tx *tx, struct kib_rdma_desc *rd,
-		    unsigned int niov, struct kvec *iov, int offset, int nob)
+		    unsigned int niov, const struct kvec *iov, int offset, int nob)
 {
 	struct kib_net *net = ni->ni_data;
 	struct page *page;
@@ -705,7 +705,7 @@ kiblnd_setup_rd_iov(lnet_ni_t *ni, struct kib_tx *tx, struct kib_rdma_desc *rd,
 
 static int
 kiblnd_setup_rd_kiov(lnet_ni_t *ni, struct kib_tx *tx, struct kib_rdma_desc *rd,
-		     int nkiov, lnet_kiov_t *kiov, int offset, int nob)
+		     int nkiov, const lnet_kiov_t *kiov, int offset, int nob)
 {
 	struct kib_net *net = ni->ni_data;
 	struct scatterlist *sg;
@@ -1719,8 +1719,7 @@ kiblnd_reply(lnet_ni_t *ni, struct kib_rx *rx, lnet_msg_t *lntmsg)
 
 int
 kiblnd_recv(lnet_ni_t *ni, void *private, lnet_msg_t *lntmsg, int delayed,
-	    unsigned int niov, struct kvec *iov, lnet_kiov_t *kiov,
-	    unsigned int offset, unsigned int mlen, unsigned int rlen)
+	    struct iov_iter *to, unsigned int rlen)
 {
 	struct kib_rx *rx = private;
 	struct kib_msg *rxmsg = rx->rx_msg;
@@ -1730,10 +1729,9 @@ kiblnd_recv(lnet_ni_t *ni, void *private, lnet_msg_t *lntmsg, int delayed,
 	int post_credit = IBLND_POSTRX_PEER_CREDIT;
 	int rc = 0;
 
-	LASSERT(mlen <= rlen);
+	LASSERT(iov_iter_count(to) <= rlen);
 	LASSERT(!in_interrupt());
 	/* Either all pages or all vaddrs */
-	LASSERT(!(kiov && iov));
 
 	switch (rxmsg->ibm_type) {
 	default:
@@ -1749,16 +1747,16 @@ kiblnd_recv(lnet_ni_t *ni, void *private, lnet_msg_t *lntmsg, int delayed,
 			break;
 		}
 
-		if (kiov)
-			lnet_copy_flat2kiov(niov, kiov, offset,
+		if (to->type & ITER_BVEC)
+			lnet_copy_flat2kiov(to->nr_segs, to->bvec, to->iov_offset,
 					    IBLND_MSG_SIZE, rxmsg,
 					    offsetof(struct kib_msg, ibm_u.immediate.ibim_payload),
-					    mlen);
+					    iov_iter_count(to));
 		else
-			lnet_copy_flat2iov(niov, iov, offset,
+			lnet_copy_flat2iov(to->nr_segs, to->kvec, to->iov_offset,
 					   IBLND_MSG_SIZE, rxmsg,
 					   offsetof(struct kib_msg, ibm_u.immediate.ibim_payload),
-					   mlen);
+					   iov_iter_count(to));
 		lnet_finalize(ni, lntmsg, 0);
 		break;
 
@@ -1766,7 +1764,7 @@ kiblnd_recv(lnet_ni_t *ni, void *private, lnet_msg_t *lntmsg, int delayed,
 		struct kib_msg	*txmsg;
 		struct kib_rdma_desc *rd;
 
-		if (!mlen) {
+		if (!iov_iter_count(to)) {
 			lnet_finalize(ni, lntmsg, 0);
 			kiblnd_send_completion(rx->rx_conn, IBLND_MSG_PUT_NAK, 0,
 					       rxmsg->ibm_u.putreq.ibprm_cookie);
@@ -1784,12 +1782,16 @@ kiblnd_recv(lnet_ni_t *ni, void *private, lnet_msg_t *lntmsg, int delayed,
 
 		txmsg = tx->tx_msg;
 		rd = &txmsg->ibm_u.putack.ibpam_rd;
-		if (!kiov)
+		if (!(to->type & ITER_BVEC))
 			rc = kiblnd_setup_rd_iov(ni, tx, rd,
-						 niov, iov, offset, mlen);
+						 to->nr_segs, to->kvec,
+						 to->iov_offset,
+						 iov_iter_count(to));
 		else
 			rc = kiblnd_setup_rd_kiov(ni, tx, rd,
-						  niov, kiov, offset, mlen);
+						  to->nr_segs, to->bvec,
+						  to->iov_offset,
+						  iov_iter_count(to));
 		if (rc) {
 			CERROR("Can't setup PUT sink for %s: %d\n",
 			       libcfs_nid2str(conn->ibc_peer->ibp_nid), rc);
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h
index 84a915c..068440e 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h
@@ -614,9 +614,7 @@ void ksocknal_shutdown(lnet_ni_t *ni);
 int ksocknal_ctl(lnet_ni_t *ni, unsigned int cmd, void *arg);
 int ksocknal_send(lnet_ni_t *ni, void *private, lnet_msg_t *lntmsg);
 int ksocknal_recv(lnet_ni_t *ni, void *private, lnet_msg_t *lntmsg,
-		  int delayed, unsigned int niov,
-		  struct kvec *iov, lnet_kiov_t *kiov,
-		  unsigned int offset, unsigned int mlen, unsigned int rlen);
+		  int delayed, struct iov_iter *to, unsigned int rlen);
 int ksocknal_accept(lnet_ni_t *ni, struct socket *sock);
 
 int ksocknal_add_peer(lnet_ni_t *ni, lnet_process_id_t id, __u32 ip, int port);
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
index f8573ed..1bdf962 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
@@ -1325,39 +1325,36 @@ ksocknal_process_receive(struct ksock_conn *conn)
 
 int
 ksocknal_recv(lnet_ni_t *ni, void *private, lnet_msg_t *msg, int delayed,
-	      unsigned int niov, struct kvec *iov, lnet_kiov_t *kiov,
-	      unsigned int offset, unsigned int mlen, unsigned int rlen)
+	      struct iov_iter *to, unsigned int rlen)
 {
 	struct ksock_conn *conn = private;
 	struct ksock_sched *sched = conn->ksnc_scheduler;
 
-	LASSERT(mlen <= rlen);
-	LASSERT(niov <= LNET_MAX_IOV);
+	LASSERT(iov_iter_count(to) <= rlen);
+	LASSERT(to->nr_segs <= LNET_MAX_IOV);
 
 	conn->ksnc_cookie = msg;
-	conn->ksnc_rx_nob_wanted = mlen;
+	conn->ksnc_rx_nob_wanted = iov_iter_count(to);
 	conn->ksnc_rx_nob_left = rlen;
 
-	if (!mlen || iov) {
+	if (to->type & ITER_KVEC) {
 		conn->ksnc_rx_nkiov = 0;
 		conn->ksnc_rx_kiov = NULL;
 		conn->ksnc_rx_iov = conn->ksnc_rx_iov_space.iov;
 		conn->ksnc_rx_niov =
 			lnet_extract_iov(LNET_MAX_IOV, conn->ksnc_rx_iov,
-					 niov, iov, offset, mlen);
+					 to->nr_segs, to->kvec,
+					 to->iov_offset, iov_iter_count(to));
 	} else {
 		conn->ksnc_rx_niov = 0;
 		conn->ksnc_rx_iov = NULL;
 		conn->ksnc_rx_kiov = conn->ksnc_rx_iov_space.kiov;
 		conn->ksnc_rx_nkiov =
 			lnet_extract_kiov(LNET_MAX_IOV, conn->ksnc_rx_kiov,
-					  niov, kiov, offset, mlen);
+					 to->nr_segs, to->bvec,
+					 to->iov_offset, iov_iter_count(to));
 	}
 
-	LASSERT(mlen ==
-		lnet_iov_nob(conn->ksnc_rx_niov, conn->ksnc_rx_iov) +
-		lnet_kiov_nob(conn->ksnc_rx_nkiov, conn->ksnc_rx_kiov));
-
 	LASSERT(conn->ksnc_rx_scheduled);
 
 	spin_lock_bh(&sched->kss_lock);
diff --git a/drivers/staging/lustre/lnet/lnet/lib-move.c b/drivers/staging/lustre/lnet/lnet/lib-move.c
index 7d8d2d6..7387731 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-move.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-move.c
@@ -569,6 +569,7 @@ lnet_ni_recv(lnet_ni_t *ni, void *private, lnet_msg_t *msg, int delayed,
 	unsigned int niov = 0;
 	struct kvec *iov = NULL;
 	lnet_kiov_t *kiov = NULL;
+	struct iov_iter to;
 	int rc;
 
 	LASSERT(!in_interrupt());
@@ -594,8 +595,14 @@ lnet_ni_recv(lnet_ni_t *ni, void *private, lnet_msg_t *msg, int delayed,
 		}
 	}
 
-	rc = ni->ni_lnd->lnd_recv(ni, private, msg, delayed,
-				  niov, iov, kiov, offset, mlen, rlen);
+	if (iov) {
+		iov_iter_kvec(&to, ITER_KVEC | READ, iov, niov, mlen + offset);
+		iov_iter_advance(&to, offset);
+	} else {
+		iov_iter_bvec(&to, ITER_BVEC | READ, kiov, niov, mlen + offset);
+		iov_iter_advance(&to, offset);
+	}
+	rc = ni->ni_lnd->lnd_recv(ni, private, msg, delayed, &to, rlen);
 	if (rc < 0)
 		lnet_finalize(ni, msg, rc);
 }
diff --git a/drivers/staging/lustre/lnet/lnet/lo.c b/drivers/staging/lustre/lnet/lnet/lo.c
index 08402712..131f84d 100644
--- a/drivers/staging/lustre/lnet/lnet/lo.c
+++ b/drivers/staging/lustre/lnet/lnet/lo.c
@@ -42,35 +42,33 @@ lolnd_send(lnet_ni_t *ni, void *private, lnet_msg_t *lntmsg)
 
 static int
 lolnd_recv(lnet_ni_t *ni, void *private, lnet_msg_t *lntmsg,
-	   int delayed, unsigned int niov,
-	   struct kvec *iov, lnet_kiov_t *kiov,
-	   unsigned int offset, unsigned int mlen, unsigned int rlen)
+	   int delayed, struct iov_iter *to, unsigned int rlen)
 {
 	lnet_msg_t *sendmsg = private;
 
 	if (lntmsg) {		   /* not discarding */
 		if (sendmsg->msg_iov) {
-			if (iov)
-				lnet_copy_iov2iov(niov, iov, offset,
+			if (to->type & ITER_KVEC)
+				lnet_copy_iov2iov(to->nr_segs, to->kvec, to->iov_offset,
 						  sendmsg->msg_niov,
 						  sendmsg->msg_iov,
-						  sendmsg->msg_offset, mlen);
+						  sendmsg->msg_offset, iov_iter_count(to));
 			else
-				lnet_copy_iov2kiov(niov, kiov, offset,
+				lnet_copy_iov2kiov(to->nr_segs, to->bvec, to->iov_offset,
 						   sendmsg->msg_niov,
 						   sendmsg->msg_iov,
-						   sendmsg->msg_offset, mlen);
+						   sendmsg->msg_offset, iov_iter_count(to));
 		} else {
-			if (iov)
-				lnet_copy_kiov2iov(niov, iov, offset,
+			if (to->type & ITER_KVEC)
+				lnet_copy_kiov2iov(to->nr_segs, to->kvec, to->iov_offset,
 						   sendmsg->msg_niov,
 						   sendmsg->msg_kiov,
-						   sendmsg->msg_offset, mlen);
+						   sendmsg->msg_offset, iov_iter_count(to));
 			else
-				lnet_copy_kiov2kiov(niov, kiov, offset,
+				lnet_copy_kiov2kiov(to->nr_segs, to->bvec, to->iov_offset,
 						    sendmsg->msg_niov,
 						    sendmsg->msg_kiov,
-						    sendmsg->msg_offset, mlen);
+						    sendmsg->msg_offset, iov_iter_count(to));
 		}
 
 		lnet_finalize(ni, lntmsg, 0);
-- 
2.7.4
