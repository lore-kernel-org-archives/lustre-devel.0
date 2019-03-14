From: NeilBrown <neilb@suse.com>
Date: Thu, 14 Mar 2019 11:11:50 +1100
Subject: [lustre-devel] [PATCH 15/32] lustre: lnet: remove msg_iov from
 lnet_msg.
In-Reply-To: <155252182126.26912.1842463462595601611.stgit@noble.brown>
References: <155252182126.26912.1842463462595601611.stgit@noble.brown>
Message-ID: <155252231035.26912.3904637484494950926.stgit@noble.brown>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

This field is never set, so remove it and remove all
uses of it.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../staging/lustre/include/linux/lnet/lib-types.h  |    1 -
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c |   30 ++++-----------
 .../staging/lustre/lnet/klnds/socklnd/socklnd_cb.c |   39 ++++++--------------
 drivers/staging/lustre/lnet/lnet/lib-move.c        |   16 ++------
 drivers/staging/lustre/lnet/lnet/lo.c              |   17 +++------
 5 files changed, 27 insertions(+), 76 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/lib-types.h b/drivers/staging/lustre/include/linux/lnet/lib-types.h
index e4a3e747389a..23fbbc47bfec 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-types.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-types.h
@@ -114,7 +114,6 @@ struct lnet_msg {
 	unsigned int		 msg_wanted;
 	unsigned int		 msg_offset;
 	unsigned int		 msg_niov;
-	struct kvec		*msg_iov;
 	struct bio_vec		*msg_kiov;
 
 	struct lnet_event	 msg_ev;
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
index bd9810652d09..51eb20ed3326 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -1522,7 +1522,6 @@ kiblnd_send(struct lnet_ni *ni, void *private, struct lnet_msg *lntmsg)
 	int target_is_router = lntmsg->msg_target_is_router;
 	int routing = lntmsg->msg_routing;
 	unsigned int payload_niov = lntmsg->msg_niov;
-	struct kvec *payload_iov = lntmsg->msg_iov;
 	struct bio_vec *payload_kiov = lntmsg->msg_kiov;
 	unsigned int payload_offset = lntmsg->msg_offset;
 	unsigned int payload_nob = lntmsg->msg_len;
@@ -1543,17 +1542,11 @@ kiblnd_send(struct lnet_ni *ni, void *private, struct lnet_msg *lntmsg)
 
 	/* Thread context */
 	LASSERT(!in_interrupt());
-	/* payload is either all vaddrs or all pages */
-	LASSERT(!(payload_kiov && payload_iov));
+	LASSERT(payload_kiov);
 
-	if (payload_kiov)
-		iov_iter_bvec(&from, WRITE,
-			      payload_kiov, payload_niov,
-			      payload_nob + payload_offset);
-	else
-		iov_iter_kvec(&from, WRITE,
-			      payload_iov, payload_niov,
-			      payload_nob + payload_offset);
+	iov_iter_bvec(&from, WRITE,
+		      payload_kiov, payload_niov,
+		      payload_nob + payload_offset);
 
 	iov_iter_advance(&from, payload_offset);
 
@@ -1629,14 +1622,9 @@ kiblnd_send(struct lnet_ni *ni, void *private, struct lnet_msg *lntmsg)
 			return -ENOMEM;
 		}
 
-		if (!payload_kiov)
-			rc = kiblnd_setup_rd_iov(ni, tx, tx->tx_rd,
-						 payload_niov, payload_iov,
-						 payload_offset, payload_nob);
-		else
-			rc = kiblnd_setup_rd_kiov(ni, tx, tx->tx_rd,
-						  payload_niov, payload_kiov,
-						  payload_offset, payload_nob);
+		rc = kiblnd_setup_rd_kiov(ni, tx, tx->tx_rd,
+					  payload_niov, payload_kiov,
+					  payload_offset, payload_nob);
 		if (rc) {
 			CERROR("Can't setup PUT src for %s: %d\n",
 			       libcfs_nid2str(target.nid), rc);
@@ -1690,7 +1678,6 @@ kiblnd_reply(struct lnet_ni *ni, struct kib_rx *rx, struct lnet_msg *lntmsg)
 {
 	struct lnet_process_id target = lntmsg->msg_target;
 	unsigned int niov = lntmsg->msg_niov;
-	struct kvec *iov = lntmsg->msg_iov;
 	struct bio_vec *kiov = lntmsg->msg_kiov;
 	unsigned int offset = lntmsg->msg_offset;
 	unsigned int nob = lntmsg->msg_len;
@@ -1706,9 +1693,6 @@ kiblnd_reply(struct lnet_ni *ni, struct kib_rx *rx, struct lnet_msg *lntmsg)
 
 	if (!nob)
 		rc = 0;
-	else if (!kiov)
-		rc = kiblnd_setup_rd_iov(ni, tx, tx->tx_rd,
-					 niov, iov, offset, nob);
 	else
 		rc = kiblnd_setup_rd_kiov(ni, tx, tx->tx_rd,
 					  niov, kiov, offset, nob);
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
index cbba90c6b9da..ce61d06f3d79 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
@@ -867,7 +867,6 @@ ksocknal_send(struct lnet_ni *ni, void *private, struct lnet_msg *lntmsg)
 	int type = lntmsg->msg_type;
 	struct lnet_process_id target = lntmsg->msg_target;
 	unsigned int payload_niov = lntmsg->msg_niov;
-	struct kvec *payload_iov = lntmsg->msg_iov;
 	struct bio_vec *payload_kiov = lntmsg->msg_kiov;
 	unsigned int payload_offset = lntmsg->msg_offset;
 	unsigned int payload_nob = lntmsg->msg_len;
@@ -884,16 +883,10 @@ ksocknal_send(struct lnet_ni *ni, void *private, struct lnet_msg *lntmsg)
 
 	LASSERT(!payload_nob || payload_niov > 0);
 	LASSERT(payload_niov <= LNET_MAX_IOV);
-	/* payload is either all vaddrs or all pages */
-	LASSERT(!(payload_kiov && payload_iov));
 	LASSERT(!in_interrupt());
 
-	if (payload_iov)
-		desc_size = offsetof(struct ksock_tx,
-				     tx_frags.virt.iov[1 + payload_niov]);
-	else
-		desc_size = offsetof(struct ksock_tx,
-				     tx_frags.paged.kiov[payload_niov]);
+	desc_size = offsetof(struct ksock_tx,
+			     tx_frags.paged.kiov[payload_niov]);
 
 	if (lntmsg->msg_vmflush)
 		mpflag = memalloc_noreclaim_save();
@@ -909,25 +902,15 @@ ksocknal_send(struct lnet_ni *ni, void *private, struct lnet_msg *lntmsg)
 	tx->tx_conn = NULL;		     /* set when assigned a conn */
 	tx->tx_lnetmsg = lntmsg;
 
-	if (payload_iov) {
-		tx->tx_kiov = NULL;
-		tx->tx_nkiov = 0;
-		tx->tx_iov = tx->tx_frags.virt.iov;
-		tx->tx_niov = 1 +
-			      lnet_extract_iov(payload_niov, &tx->tx_iov[1],
-					       payload_niov, payload_iov,
-					       payload_offset, payload_nob);
-	} else {
-		tx->tx_niov = 1;
-		tx->tx_iov = &tx->tx_frags.paged.iov;
-		tx->tx_kiov = tx->tx_frags.paged.kiov;
-		tx->tx_nkiov = lnet_extract_kiov(payload_niov, tx->tx_kiov,
-						 payload_niov, payload_kiov,
-						 payload_offset, payload_nob);
-
-		if (payload_nob >= *ksocknal_tunables.ksnd_zc_min_payload)
-			tx->tx_zc_capable = 1;
-	}
+	tx->tx_niov = 1;
+	tx->tx_iov = &tx->tx_frags.paged.iov;
+	tx->tx_kiov = tx->tx_frags.paged.kiov;
+	tx->tx_nkiov = lnet_extract_kiov(payload_niov, tx->tx_kiov,
+					 payload_niov, payload_kiov,
+					 payload_offset, payload_nob);
+
+	if (payload_nob >= *ksocknal_tunables.ksnd_zc_min_payload)
+		tx->tx_zc_capable = 1;
 
 	tx->tx_msg.ksm_csum = 0;
 	tx->tx_msg.ksm_type = KSOCK_MSG_LNET;
diff --git a/drivers/staging/lustre/lnet/lnet/lib-move.c b/drivers/staging/lustre/lnet/lnet/lib-move.c
index 2938a56cee02..a074807f4d86 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-move.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-move.c
@@ -466,7 +466,6 @@ lnet_ni_recv(struct lnet_ni *ni, void *private, struct lnet_msg *msg,
 	     unsigned int rlen)
 {
 	unsigned int niov = 0;
-	struct kvec *iov = NULL;
 	struct bio_vec *kiov = NULL;
 	struct iov_iter to;
 	int rc;
@@ -486,21 +485,16 @@ lnet_ni_recv(struct lnet_ni *ni, void *private, struct lnet_msg *msg,
 
 		if (mlen) {
 			niov = msg->msg_niov;
-			iov = msg->msg_iov;
 			kiov = msg->msg_kiov;
 
 			LASSERT(niov > 0);
-			LASSERT(!iov != !kiov);
+			LASSERT(kiov);
 		}
 	}
 
-	if (iov) {
-		iov_iter_kvec(&to, READ, iov, niov, mlen + offset);
-		iov_iter_advance(&to, offset);
-	} else {
-		iov_iter_bvec(&to, READ, kiov, niov, mlen + offset);
-		iov_iter_advance(&to, offset);
-	}
+	iov_iter_bvec(&to, READ, kiov, niov, mlen + offset);
+	iov_iter_advance(&to, offset);
+
 	rc = ni->ni_net->net_lnd->lnd_recv(ni, private, msg, delayed, &to, rlen);
 	if (rc < 0)
 		lnet_finalize(msg, rc);
@@ -515,7 +509,6 @@ lnet_setpayloadbuffer(struct lnet_msg *msg)
 	LASSERT(!msg->msg_routing);
 	LASSERT(md);
 	LASSERT(!msg->msg_niov);
-	LASSERT(!msg->msg_iov);
 	LASSERT(!msg->msg_kiov);
 
 	msg->msg_niov = md->md_niov;
@@ -835,7 +828,6 @@ lnet_post_routed_recv_locked(struct lnet_msg *msg, int do_recv)
 	struct lnet_rtrbufpool *rbp;
 	struct lnet_rtrbuf *rb;
 
-	LASSERT(!msg->msg_iov);
 	LASSERT(!msg->msg_kiov);
 	LASSERT(!msg->msg_niov);
 	LASSERT(msg->msg_routing);
diff --git a/drivers/staging/lustre/lnet/lnet/lo.c b/drivers/staging/lustre/lnet/lnet/lo.c
index c8a1eb62c430..f7af2f1d8f80 100644
--- a/drivers/staging/lustre/lnet/lnet/lo.c
+++ b/drivers/staging/lustre/lnet/lnet/lo.c
@@ -49,18 +49,11 @@ lolnd_recv(struct lnet_ni *ni, void *private, struct lnet_msg *lntmsg,
 	struct lnet_msg *sendmsg = private;
 
 	if (lntmsg) {		   /* not discarding */
-		if (sendmsg->msg_iov)
-			lnet_copy_iov2iter(to,
-					   sendmsg->msg_niov,
-					   sendmsg->msg_iov,
-					   sendmsg->msg_offset,
-					   iov_iter_count(to));
-		else
-			lnet_copy_kiov2iter(to,
-					    sendmsg->msg_niov,
-					    sendmsg->msg_kiov,
-					    sendmsg->msg_offset,
-					    iov_iter_count(to));
+		lnet_copy_kiov2iter(to,
+				    sendmsg->msg_niov,
+				    sendmsg->msg_kiov,
+				    sendmsg->msg_offset,
+				    iov_iter_count(to));
 
 		lnet_finalize(lntmsg, 0);
 	}
