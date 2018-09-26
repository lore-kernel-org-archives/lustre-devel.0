From: James Simmons <jsimmons@infradead.org>
Date: Tue, 25 Sep 2018 22:48:15 -0400
Subject: [lustre-devel] [PATCH 23/25] lustre: lnd: pending transmits dropped
 silently
In-Reply-To: <1537930097-11624-1-git-send-email-jsimmons@infradead.org>
References: <1537930097-11624-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1537930097-11624-24-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <ashehata@whamcloud.com>

list_add was being used erroneously. The logic should be to move
the txs on ibp_tx_queue on a local list which is then processed.
The code, however, did the reverse, which would result in the
pending txs not processed and thus dropped silently. This in turn
would lead to peers reference counts at the LNet layer not
decremented since lnet_finalize() might not be called for a message.

Initialize local list and use list_splice_init() to move
transmits on the ibp_tx_queue to the local list.

Signed-off-by: Amir Shehata <ashehata@whamcloud.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-10682
Reviewed-on: https://review.whamcloud.com/31374
Reviewed-by: Doug Oucharek <dougso@me.com>
Reviewed-by: Sonia Sharma <sharmaso@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
index 346d368..f2a01eb 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -2150,8 +2150,8 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
 	}
 
 	/* grab pending txs while I have the lock */
-	list_add(&txs, &peer_ni->ibp_tx_queue);
-	list_del_init(&peer_ni->ibp_tx_queue);
+	INIT_LIST_HEAD(&txs);
+	list_splice_init(&peer_ni->ibp_tx_queue, &txs);
 
 	if (!kiblnd_peer_active(peer_ni) ||	/* peer_ni has been deleted */
 	    conn->ibc_comms_error) {       /* error has happened already */
-- 
1.8.3.1
