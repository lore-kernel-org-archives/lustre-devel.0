From: James Simmons <jsimmons@infradead.org>
Date: Sun, 15 Nov 2020 19:59:47 -0500
Subject: [lustre-devel] [PATCH 14/28] lnet: o2iblnd: 'Timed out tx' error
 message
In-Reply-To: <1605488401-981-1-git-send-email-jsimmons@infradead.org>
References: <1605488401-981-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1605488401-981-15-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Brian Behlendorf <behlendorf1@llnl.gov>

Trivial fix to report the total RDMA time outstanding rather
than the number of seconds past the deadline.

WC-bug-id: https://jira.whamcloud.com/browse/LU-1742
Lustre-commit: 2be289a2b1f12b ("LU-1742 o2iblnd: 'Timed out tx' error message")
Signed-off-by: Brian Behlendorf <behlendorf1@llnl.gov>
Reviewed-on: https://review.whamcloud.com/3622
Reviewed-by: Chris Horn <chris.horn@hpe.com>
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/klnds/o2iblnd/o2iblnd_cb.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/lnet/klnds/o2iblnd/o2iblnd_cb.c b/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
index 9de733d..3d7026b 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -3219,6 +3219,7 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 		if (ktime_compare(ktime_get(), tx->tx_deadline) >= 0) {
 			CERROR("Timed out tx: %s, %lld seconds\n",
 			       kiblnd_queue2str(conn, txs),
+			       kiblnd_timeout() +
 			       ktime_ms_delta(ktime_get(),
 					      tx->tx_deadline) / MSEC_PER_SEC);
 			return 1;
-- 
1.8.3.1
