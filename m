From: James Simmons <jsimmons@infradead.org>
Date: Tue,  2 Jun 2020 20:59:57 -0400
Subject: [lustre-devel] [PATCH 18/22] lnet: lnd: Allow independent ko2iblnd
 timeout
In-Reply-To: <1591146001-27171-1-git-send-email-jsimmons@infradead.org>
References: <1591146001-27171-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1591146001-27171-19-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Chris Horn <hornc@cray.com>

Allow ko2iblnd timeout parameter to be set independent of the
lnet_transaction_timeout and retry_count.

WC-bug-id: https://jira.whamcloud.com/browse/LU-13510
Lustre-commit: 0c038ee2f613e ("LU-13510 lnd: Allow independent ko2iblnd timeout")
Signed-off-by: Chris Horn <hornc@cray.com>
Reviewed-on: https://review.whamcloud.com/38459
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/klnds/o2iblnd/o2iblnd.h           |  6 ++++++
 net/lnet/klnds/o2iblnd/o2iblnd_cb.c        | 10 +++++-----
 net/lnet/klnds/o2iblnd/o2iblnd_modparams.c |  2 +-
 3 files changed, 12 insertions(+), 6 deletions(-)

diff --git a/net/lnet/klnds/o2iblnd/o2iblnd.h b/net/lnet/klnds/o2iblnd/o2iblnd.h
index 8aa79d5..f60a69d 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd.h
+++ b/net/lnet/klnds/o2iblnd/o2iblnd.h
@@ -642,6 +642,12 @@ struct kib_peer_ni {
 
 int kiblnd_msg_queue_size(int version, struct lnet_ni *ni);
 
+static inline int kiblnd_timeout(void)
+{
+	return *kiblnd_tunables.kib_timeout ? *kiblnd_tunables.kib_timeout :
+	       lnet_get_lnd_timeout();
+}
+
 static inline int
 kiblnd_concurrent_sends(int version, struct lnet_ni *ni)
 {
diff --git a/net/lnet/klnds/o2iblnd/o2iblnd_cb.c b/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
index f7c802f..09a46d6 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -1160,7 +1160,7 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 		return;
 	}
 
-	timeout_ns = lnet_get_lnd_timeout() * NSEC_PER_SEC;
+	timeout_ns = kiblnd_timeout() * NSEC_PER_SEC;
 	tx->tx_queued = 1;
 	tx->tx_deadline = ktime_add_ns(ktime_get(), timeout_ns);
 
@@ -1289,12 +1289,12 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
 
 	if (*kiblnd_tunables.kib_use_priv_port) {
 		rc = kiblnd_resolve_addr(cmid, &srcaddr, &dstaddr,
-					 lnet_get_lnd_timeout() * 1000);
+					 kiblnd_timeout() * 1000);
 	} else {
 		rc = rdma_resolve_addr(cmid,
 				       (struct sockaddr *)&srcaddr,
 				       (struct sockaddr *)&dstaddr,
-				       lnet_get_lnd_timeout() * 1000);
+				       kiblnd_timeout() * 1000);
 	}
 	if (rc != 0) {
 		/* Can't initiate address resolution:  */
@@ -3021,7 +3021,7 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
 			rc = event->status;
 		} else {
 			rc = rdma_resolve_route(cmid,
-						lnet_get_lnd_timeout() * 1000);
+						kiblnd_timeout() * 1000);
 			if (!rc) {
 				struct kib_net *net = peer_ni->ibp_ni->ni_data;
 				struct kib_dev *dev = net->ibn_dev;
@@ -3437,7 +3437,7 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
 			 * interval.
 			 */
 
-			lnd_timeout = lnet_get_lnd_timeout();
+			lnd_timeout = kiblnd_timeout();
 			if (lnd_timeout > n * p)
 				chunk = (chunk * n * p) / lnd_timeout;
 			if (!chunk)
diff --git a/net/lnet/klnds/o2iblnd/o2iblnd_modparams.c b/net/lnet/klnds/o2iblnd/o2iblnd_modparams.c
index c9e14ec..7407ced 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd_modparams.c
+++ b/net/lnet/klnds/o2iblnd/o2iblnd_modparams.c
@@ -45,7 +45,7 @@
 module_param(cksum, int, 0644);
 MODULE_PARM_DESC(cksum, "set non-zero to enable message (not RDMA) checksums");
 
-static int timeout = 50;
+static int timeout;
 module_param(timeout, int, 0644);
 MODULE_PARM_DESC(timeout, "timeout (seconds)");
 
-- 
1.8.3.1
