From: James Simmons <jsimmons@infradead.org>
Date: Mon, 25 May 2020 18:07:44 -0400
Subject: [lustre-devel] [PATCH 07/45] lnet: remove msg_iov from lnet_msg.
In-Reply-To: <1590444502-20533-1-git-send-email-jsimmons@infradead.org>
References: <1590444502-20533-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1590444502-20533-8-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mr NeilBrown <neilb@suse.de>

This field is never set, so remove it and remove all uses of it.

Conversely, msg_kiov is always non-NULL, so remove code that depends
on it being NULL.

WC-bug-id: https://jira.whamcloud.com/browse/LU-13004
Lustre-commit: 585e6df77ebf2 ("LU-13004 lnet: remove msg_iov from lnet_msg.")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/37844
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Shaun Tancheff <shaun.tancheff@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/lib-types.h      |  1 -
 net/lnet/klnds/o2iblnd/o2iblnd_cb.c | 34 ++++++++------------------------
 net/lnet/klnds/socklnd/socklnd_cb.c | 39 +++++++++++--------------------------
 net/lnet/lnet/lib-move.c            | 16 ++++-----------
 net/lnet/lnet/lo.c                  | 17 +++++-----------
 5 files changed, 28 insertions(+), 79 deletions(-)

diff --git a/include/linux/lnet/lib-types.h b/include/linux/lnet/lib-types.h
index 9a11aa5..1a71483 100644
--- a/include/linux/lnet/lib-types.h
+++ b/include/linux/lnet/lib-types.h
@@ -164,7 +164,6 @@ struct lnet_msg {
 	unsigned int		 msg_wanted;
 	unsigned int		 msg_offset;
 	unsigned int		 msg_niov;
-	struct kvec		*msg_iov;
 	struct bio_vec		*msg_kiov;
 
 	struct lnet_event	 msg_ev;
diff --git a/net/lnet/klnds/o2iblnd/o2iblnd_cb.c b/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
index 7f782fb..18edb1e 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -1564,7 +1564,6 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
 	int target_is_router = lntmsg->msg_target_is_router;
 	int routing = lntmsg->msg_routing;
 	unsigned int payload_niov = lntmsg->msg_niov;
-	struct kvec *payload_iov = lntmsg->msg_iov;
 	struct bio_vec *payload_kiov = lntmsg->msg_kiov;
 	unsigned int payload_offset = lntmsg->msg_offset;
 	unsigned int payload_nob = lntmsg->msg_len;
@@ -1585,17 +1584,10 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
 
 	/* Thread context */
 	LASSERT(!in_interrupt());
-	/* payload is either all vaddrs or all pages */
-	LASSERT(!(payload_kiov && payload_iov));
 
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
 
@@ -1627,9 +1619,8 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
 		ibmsg = tx->tx_msg;
 		rd = &ibmsg->ibm_u.get.ibgm_rd;
 		rc = kiblnd_setup_rd_kiov(ni, tx, rd,
-					  lntmsg->msg_md->md_niov,
-					  lntmsg->msg_md->md_kiov,
-					  0, lntmsg->msg_md->md_length);
+					  payload_niov, payload_kiov,
+					  payload_offset, payload_nob);
 		if (rc) {
 			CERROR("Can't setup GET sink for %s: %d\n",
 			       libcfs_nid2str(target.nid), rc);
@@ -1672,14 +1663,9 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
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
@@ -1733,7 +1719,6 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
 {
 	struct lnet_process_id target = lntmsg->msg_target;
 	unsigned int niov = lntmsg->msg_niov;
-	struct kvec *iov = lntmsg->msg_iov;
 	struct bio_vec *kiov = lntmsg->msg_kiov;
 	unsigned int offset = lntmsg->msg_offset;
 	unsigned int nob = lntmsg->msg_len;
@@ -1749,9 +1734,6 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
 
 	if (!nob)
 		rc = 0;
-	else if (!kiov)
-		rc = kiblnd_setup_rd_iov(ni, tx, tx->tx_rd,
-					 niov, iov, offset, nob);
 	else
 		rc = kiblnd_setup_rd_kiov(ni, tx, tx->tx_rd,
 					  niov, kiov, offset, nob);
diff --git a/net/lnet/klnds/socklnd/socklnd_cb.c b/net/lnet/klnds/socklnd/socklnd_cb.c
index 9d5e03b..83fcb28 100644
--- a/net/lnet/klnds/socklnd/socklnd_cb.c
+++ b/net/lnet/klnds/socklnd/socklnd_cb.c
@@ -914,7 +914,6 @@ struct ksock_route *
 	int type = lntmsg->msg_type;
 	struct lnet_process_id target = lntmsg->msg_target;
 	unsigned int payload_niov = lntmsg->msg_niov;
-	struct kvec *payload_iov = lntmsg->msg_iov;
 	struct bio_vec *payload_kiov = lntmsg->msg_kiov;
 	unsigned int payload_offset = lntmsg->msg_offset;
 	unsigned int payload_nob = lntmsg->msg_len;
@@ -931,16 +930,10 @@ struct ksock_route *
 
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
@@ -956,25 +949,15 @@ struct ksock_route *
 	tx->tx_conn = NULL;		/* set when assigned a conn */
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
diff --git a/net/lnet/lnet/lib-move.c b/net/lnet/lnet/lib-move.c
index dc49e60..6ef9978 100644
--- a/net/lnet/lnet/lib-move.c
+++ b/net/lnet/lnet/lib-move.c
@@ -485,7 +485,6 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 	     unsigned int rlen)
 {
 	unsigned int niov = 0;
-	struct kvec *iov = NULL;
 	struct bio_vec *kiov = NULL;
 	struct iov_iter to;
 	int rc;
@@ -505,21 +504,16 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 
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
@@ -534,7 +528,6 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 	LASSERT(!msg->msg_routing);
 	LASSERT(md);
 	LASSERT(!msg->msg_niov);
-	LASSERT(!msg->msg_iov);
 	LASSERT(!msg->msg_kiov);
 
 	msg->msg_niov = md->md_niov;
@@ -809,7 +802,6 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 	struct lnet_rtrbufpool *rbp;
 	struct lnet_rtrbuf *rb;
 
-	LASSERT(!msg->msg_iov);
 	LASSERT(!msg->msg_kiov);
 	LASSERT(!msg->msg_niov);
 	LASSERT(msg->msg_routing);
diff --git a/net/lnet/lnet/lo.c b/net/lnet/lnet/lo.c
index c19a5b5..58b0ee9 100644
--- a/net/lnet/lnet/lo.c
+++ b/net/lnet/lnet/lo.c
@@ -51,18 +51,11 @@
 	struct lnet_msg *sendmsg = private;
 
 	if (lntmsg) {		/* not discarding */
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
-- 
1.8.3.1
