From: NeilBrown <neilb@suse.com>
Date: Thu, 14 Mar 2019 11:11:50 +1100
Subject: [lustre-devel] [PATCH 16/32] lustre: lnet: simplify ksock_tx.
In-Reply-To: <155252182126.26912.1842463462595601611.stgit@noble.brown>
References: <155252182126.26912.1842463462595601611.stgit@noble.brown>
Message-ID: <155252231047.26912.17702236984184248672.stgit@noble.brown>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

The tx_frags union in 'struct ksock_tx' is largely unnecessary.
The payload is always bio_vec, the only kvec is a header.
So replace the union with just those two fields.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../staging/lustre/lnet/klnds/socklnd/socklnd.h    |   14 ++++----------
 .../staging/lustre/lnet/klnds/socklnd/socklnd_cb.c |    8 ++++----
 2 files changed, 8 insertions(+), 14 deletions(-)

diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h
index add2744c9d8d..738c7cd2b484 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h
@@ -289,18 +289,12 @@ struct ksock_tx {				/* transmit packet */
 	time64_t		tx_deadline;	/* when (in secs) tx times out */
 	struct ksock_msg	tx_msg;		/* socklnd message buffer */
 	int			tx_desc_size;	/* size of this descriptor */
-	union {
-		struct {
-			struct kvec	iov;	/* virt hdr */
-			struct bio_vec	kiov[0];/* paged payload */
-		} paged;
-		struct {
-			struct kvec	iov[1];	/* virt hdr + payload */
-		} virt;
-	} tx_frags;
+
+	struct kvec		tx_hdr;		/* virt hdr */
+	struct bio_vec		tx_payload[0];	/* paged payload */
 };
 
-#define KSOCK_NOOP_TX_SIZE (offsetof(struct ksock_tx, tx_frags.paged.kiov[0]))
+#define KSOCK_NOOP_TX_SIZE (offsetof(struct ksock_tx, tx_payload[0]))
 
 /* network zero copy callback descriptor embedded in struct ksock_tx */
 
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
index ce61d06f3d79..f137c875ed66 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
@@ -78,7 +78,7 @@ ksocknal_alloc_tx_noop(u64 cookie, int nonblk)
 	tx->tx_lnetmsg = NULL;
 	tx->tx_kiov = NULL;
 	tx->tx_nkiov = 0;
-	tx->tx_iov = tx->tx_frags.virt.iov;
+	tx->tx_iov = &tx->tx_hdr;
 	tx->tx_niov = 1;
 	tx->tx_nonblk = nonblk;
 
@@ -886,7 +886,7 @@ ksocknal_send(struct lnet_ni *ni, void *private, struct lnet_msg *lntmsg)
 	LASSERT(!in_interrupt());
 
 	desc_size = offsetof(struct ksock_tx,
-			     tx_frags.paged.kiov[payload_niov]);
+			     tx_payload[payload_niov]);
 
 	if (lntmsg->msg_vmflush)
 		mpflag = memalloc_noreclaim_save();
@@ -903,8 +903,8 @@ ksocknal_send(struct lnet_ni *ni, void *private, struct lnet_msg *lntmsg)
 	tx->tx_lnetmsg = lntmsg;
 
 	tx->tx_niov = 1;
-	tx->tx_iov = &tx->tx_frags.paged.iov;
-	tx->tx_kiov = tx->tx_frags.paged.kiov;
+	tx->tx_iov = &tx->tx_hdr;
+	tx->tx_kiov = tx->tx_payload;
 	tx->tx_nkiov = lnet_extract_kiov(payload_niov, tx->tx_kiov,
 					 payload_niov, payload_kiov,
 					 payload_offset, payload_nob);
