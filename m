From: James Simmons <jsimmons@infradead.org>
Date: Sat, 13 Jun 2020 12:27:16 -0400
Subject: [lustre-devel] [PATCH 20/20] lnet: o2iblnd: 'Timed out tx' error
 message
In-Reply-To: <1592065636-28333-1-git-send-email-jsimmons@infradead.org>
References: <1592065636-28333-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1592065636-28333-21-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Sonia Sharma <sharmaso@whamcloud.com>

Fix the error message in kiblnd_check_txs_locked()
to report the total RDMA time outstanding rather
than the number of seconds past the deadline.

This patch also adds time_on_activeq to struct kib_tx
so the time spent by tx in internal queue and active
queue can be tracked and reported. This would help
in diagnosing the issue.

WC-bug-id: https://jira.whamcloud.com/browse/LU-1742
Lustre-commit: 7308662efc02f ("LU-1742 o2iblnd: 'Timed out tx' error message")
Signed-off-by: Sonia Sharma <sharmaso@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/33235
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Stephen Champion <stephen.champion@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/klnds/o2iblnd/o2iblnd.h    |  2 ++
 net/lnet/klnds/o2iblnd/o2iblnd_cb.c | 26 ++++++++++++++++++++++----
 2 files changed, 24 insertions(+), 4 deletions(-)

diff --git a/net/lnet/klnds/o2iblnd/o2iblnd.h b/net/lnet/klnds/o2iblnd/o2iblnd.h
index f60a69d..dc09e5e 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd.h
+++ b/net/lnet/klnds/o2iblnd/o2iblnd.h
@@ -541,6 +541,8 @@ struct kib_tx {					/* transmit message */
 	bool			tx_gaps;
 	struct kib_fmr		tx_fmr;		/* FMR */
 	int			tx_dmadir;	/* dma direction */
+	/* time when tx added on ibc_active_txs */
+	ktime_t			tx_on_activeq;
 };
 
 struct kib_connvars {
diff --git a/net/lnet/klnds/o2iblnd/o2iblnd_cb.c b/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
index 40e196d..f421cdf 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -821,6 +821,7 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 	 */
 	tx->tx_sending++;
 	list_add(&tx->tx_list, &conn->ibc_active_txs);
+	tx->tx_on_activeq = ktime_get();
 
 	/* I'm still holding ibc_lock! */
 	if (conn->ibc_state != IBLND_CONN_ESTABLISHED) {
@@ -3169,6 +3170,8 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
 static int
 kiblnd_check_txs_locked(struct kib_conn *conn, struct list_head *txs)
 {
+	bool active_txs = strcmp(kiblnd_queue2str(conn, txs),
+				 "active_txs") == 0;
 	struct kib_tx *tx;
 
 	list_for_each_entry(tx, txs, tx_list) {
@@ -3179,13 +3182,28 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
 			LASSERT(tx->tx_waiting || tx->tx_sending);
 		}
 
-		if (ktime_compare(ktime_get(), tx->tx_deadline) >= 0) {
-			CERROR("Timed out tx: %s, %lld seconds\n",
+		if (ktime_compare(ktime_get(), tx->tx_deadline) < 0)
+			continue;
+
+		if (!active_txs) {
+			CERROR("Timed out tx: %s, outstanding RDMA time: %lld sec\n",
 			       kiblnd_queue2str(conn, txs),
+			       *kiblnd_tunables.kib_timeout +
+			       (ktime_ms_delta(ktime_get(),
+					      tx->tx_deadline) / MSEC_PER_SEC));
+		} else {
+			CERROR("Timed out tx: %s, time in internal queue: %lld sec, time in active queue: %lld sec, outstanding RDMA time: %lld sec\n",
+			       kiblnd_queue2str(conn, txs),
+			       ktime_ms_delta(tx->tx_deadline,
+					      tx->tx_on_activeq) / MSEC_PER_SEC,
 			       ktime_ms_delta(ktime_get(),
-					      tx->tx_deadline) / MSEC_PER_SEC);
-			return 1;
+					      tx->tx_on_activeq) / MSEC_PER_SEC,
+			       *kiblnd_tunables.kib_timeout +
+			       (ktime_ms_delta(ktime_get(),
+					       tx->tx_deadline) / MSEC_PER_SEC));
 		}
+
+		return 1;
 	}
 
 	return 0;
-- 
1.8.3.1
