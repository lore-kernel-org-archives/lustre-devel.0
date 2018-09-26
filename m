From: James Simmons <jsimmons@infradead.org>
Date: Tue, 25 Sep 2018 22:48:08 -0400
Subject: [lustre-devel] [PATCH 16/25] lustre: o2iblnd: kill timedout txs
 from ibp_tx_queue
In-Reply-To: <1537930097-11624-1-git-send-email-jsimmons@infradead.org>
References: <1537930097-11624-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1537930097-11624-17-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Sergey Cheremencev <c17829@cray.com>

Sometimes connection can't be established for a long time
due to rejections and produces cycle of reconnections.
Peer is not removed in each iteration unlike connection.
Thus until connection becomes established txs live in
peer->ibp_tx_queue. This patch adds tx_deadline checking
for txs from peer tx_queue.

Signed-off-by: Sergey Cheremencev <c17829@cray.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-9094
Seagate-bug-id: MRP-4056
Reviewed-on: https://review.whamcloud.com/25376
Reviewed-by: Doug Oucharek <dougso@me.com>
Reviewed-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c    | 19 +++++++++++++++++--
 1 file changed, 17 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
index dc71554..3218999 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -3159,8 +3159,10 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
 {
 	LIST_HEAD(closes);
 	LIST_HEAD(checksends);
+	LIST_HEAD(timedout_txs);
 	struct list_head *peers = &kiblnd_data.kib_peers[idx];
 	struct kib_peer_ni *peer_ni;
+	struct kib_tx *tx_tmp, *tx;
 	struct kib_conn *conn;
 	unsigned long flags;
 
@@ -3169,9 +3171,19 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
 	 * RDMAs to time out, so we just use a shared lock while we
 	 * take a look...
 	 */
-	read_lock_irqsave(&kiblnd_data.kib_global_lock, flags);
+	write_lock_irqsave(&kiblnd_data.kib_global_lock, flags);
 
 	list_for_each_entry(peer_ni, peers, ibp_list) {
+		/* Check tx_deadline */
+		list_for_each_entry_safe(tx, tx_tmp, &peer_ni->ibp_tx_queue, tx_list) {
+			if (ktime_compare(ktime_get(), tx->tx_deadline) >= 0) {
+				CWARN("Timed out tx for %s: %lld seconds\n",
+				      libcfs_nid2str(peer_ni->ibp_nid),
+				      ktime_ms_delta(ktime_get(),
+						     tx->tx_deadline) / MSEC_PER_SEC);
+				list_move(&tx->tx_list, &timedout_txs);
+			}
+		}
 
 		list_for_each_entry(conn, &peer_ni->ibp_conns, ibc_list) {
 			int timedout;
@@ -3207,7 +3219,10 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
 		}
 	}
 
-	read_unlock_irqrestore(&kiblnd_data.kib_global_lock, flags);
+	write_unlock_irqrestore(&kiblnd_data.kib_global_lock, flags);
+
+	if (!list_empty(&timedout_txs))
+		kiblnd_txlist_done(&timedout_txs, -ETIMEDOUT);
 
 	/*
 	 * Handle timeout by closing the whole
-- 
1.8.3.1
