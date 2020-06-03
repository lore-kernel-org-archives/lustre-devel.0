From: James Simmons <jsimmons@infradead.org>
Date: Tue,  2 Jun 2020 20:59:59 -0400
Subject: [lustre-devel] [PATCH 20/22] lnet: lnd: gracefully handle
 unexpected events
In-Reply-To: <1591146001-27171-1-git-send-email-jsimmons@infradead.org>
References: <1591146001-27171-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1591146001-27171-21-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <ashehata@whamcloud.com>

When a tx completes kiblnd_tx_complete() callback is invoked.
We ensure:
LASSERT (tx->tx_sending > 0);
However this assert is being triggered in some rare scenarios.
The reason tx_sending would be 0 at this point is because:
 1. ib_post_send() failed but OFED stack is still sending
    a tx complete event.
 2. We're getting two different events for the same tx

Instead of asserting, ignore that tx_complete event and print
the tx pointer and its status.

WC-bug-id: https://jira.whamcloud.com/browse/LU-13553
Lustre-commit: 60f9f539e686f ("LU-13553 lnd: gracefully handle unexpected events")
Signed-off-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/38669
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/klnds/o2iblnd/o2iblnd_cb.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/net/lnet/klnds/o2iblnd/o2iblnd_cb.c b/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
index 09a46d6..40e196d 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -969,7 +969,11 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 	struct kib_conn *conn = tx->tx_conn;
 	int idle;
 
-	LASSERT(tx->tx_sending > 0);
+	if (tx->tx_sending <= 0) {
+		CERROR("Received an event on a freed tx: %p status %d\n",
+		       tx, tx->tx_status);
+		return;
+	}
 
 	if (failed) {
 		if (conn->ibc_state == IBLND_CONN_ESTABLISHED)
-- 
1.8.3.1
