From: James Simmons <jsimmons@infradead.org>
Date: Mon, 25 May 2020 18:08:16 -0400
Subject: [lustre-devel] [PATCH 39/45] lnet: simplify ksock_tx.
In-Reply-To: <1590444502-20533-1-git-send-email-jsimmons@infradead.org>
References: <1590444502-20533-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1590444502-20533-40-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mr NeilBrown <neilb@suse.de>

The tx_frags union in 'struct ksock_tx' is largely unnecessary.  The
payload is always lnet_kiov_t, the only kvec is a header.  So replace
the union with just those two fields.

WC-bug-id: https://jira.whamcloud.com/browse/LU-13004
Lustre-commit: 28ffde29603b1 ("LU-13004 lnet: simplify ksock_tx.")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/37850
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Shaun Tancheff <shaun.tancheff@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/klnds/socklnd/socklnd.h    | 13 +++----------
 net/lnet/klnds/socklnd/socklnd_cb.c |  8 ++++----
 2 files changed, 7 insertions(+), 14 deletions(-)

diff --git a/net/lnet/klnds/socklnd/socklnd.h b/net/lnet/klnds/socklnd/socklnd.h
index 2504e52..f85eb3c 100644
--- a/net/lnet/klnds/socklnd/socklnd.h
+++ b/net/lnet/klnds/socklnd/socklnd.h
@@ -291,18 +291,11 @@ struct ksock_tx {				/* transmit packet */
 	struct ksock_msg	tx_msg;		/* socklnd message buffer */
 	int			tx_desc_size;	/* size of this descriptor */
 	enum lnet_msg_hstatus	tx_hstatus;	/* health status of tx */
-	union {
-		struct {
-			struct kvec	iov;	/* virt hdr */
-			struct bio_vec	kiov[0];/* paged payload */
-		} paged;
-		struct {
-			struct kvec	iov[1];	/* virt hdr + payload */
-		} virt;
-	} tx_frags;
+	struct kvec		tx_hdr;		/* virt hdr */
+	struct bio_vec		tx_payload[0];	/* paged payload */
 };
 
-#define KSOCK_NOOP_TX_SIZE (offsetof(struct ksock_tx, tx_frags.paged.kiov[0]))
+#define KSOCK_NOOP_TX_SIZE (offsetof(struct ksock_tx, tx_payload[0]))
 
 /* network zero copy callback descriptor embedded in struct ksock_tx */
 
diff --git a/net/lnet/klnds/socklnd/socklnd_cb.c b/net/lnet/klnds/socklnd/socklnd_cb.c
index 83fcb28..b40fbf1 100644
--- a/net/lnet/klnds/socklnd/socklnd_cb.c
+++ b/net/lnet/klnds/socklnd/socklnd_cb.c
@@ -79,7 +79,7 @@ struct ksock_tx *
 	tx->tx_lnetmsg = NULL;
 	tx->tx_kiov = NULL;
 	tx->tx_nkiov = 0;
-	tx->tx_iov = tx->tx_frags.virt.iov;
+	tx->tx_iov = &tx->tx_hdr;
 	tx->tx_niov = 1;
 	tx->tx_nonblk = nonblk;
 
@@ -933,7 +933,7 @@ struct ksock_route *
 	LASSERT(!in_interrupt());
 
 	desc_size = offsetof(struct ksock_tx,
-			     tx_frags.paged.kiov[payload_niov]);
+			     tx_payload[payload_niov]);
 
 	if (lntmsg->msg_vmflush)
 		mpflag = memalloc_noreclaim_save();
@@ -950,8 +950,8 @@ struct ksock_route *
 	tx->tx_lnetmsg = lntmsg;
 
 	tx->tx_niov = 1;
-	tx->tx_iov = &tx->tx_frags.paged.iov;
-	tx->tx_kiov = tx->tx_frags.paged.kiov;
+	tx->tx_iov = &tx->tx_hdr;
+	tx->tx_kiov = tx->tx_payload;
 	tx->tx_nkiov = lnet_extract_kiov(payload_niov, tx->tx_kiov,
 					 payload_niov, payload_kiov,
 					 payload_offset, payload_nob);
-- 
1.8.3.1
