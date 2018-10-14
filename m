From: James Simmons <jsimmons@infradead.org>
Date: Sun, 14 Oct 2018 14:55:29 -0400
Subject: [lustre-devel] [PATCH 07/10] lustre: lnd: remove concurrent_sends
 tunable
In-Reply-To: <1539543332-28679-1-git-send-email-jsimmons@infradead.org>
References: <1539543332-28679-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1539543332-28679-8-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <ashehata@whamcloud.com>

Concurrent sends tunable was intended to limit the number of in-flight
transfers per connection. However queue depth does the exact same job.
So for example if the queue depth is negotiated to 16 and
concurrent_sends is set to 32, the maximum number of in-flight
transfers doesn't exceed 16. There is no need to keep concurrent_sends
around since it doesn't add any unique functionality

Signed-off-by: Amir Shehata <ashehata@whamcloud.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-10291
Reviewed-on: https://review.whamcloud.com/30312
WC-bug-id: https://jira.whamcloud.com/browse/LU-10459
Reviewed-on: https://review.whamcloud.com/30751
Reviewed-by: Alexey Lyashkov <c17817@cray.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Doug Oucharek <dougso@me.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h    | 23 +----------------
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c |  5 ++--
 .../lustre/lnet/klnds/o2iblnd/o2iblnd_modparams.c  | 29 +---------------------
 3 files changed, 4 insertions(+), 53 deletions(-)

diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
index c6c8106..c882345 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
@@ -141,8 +141,7 @@ struct kib_tunables {
 #define IBLND_RECV_WRS(c)	IBLND_RX_MSGS(c)
 
 #define IBLND_CQ_ENTRIES(c)	\
-	(IBLND_RECV_WRS(c) + 2 * kiblnd_concurrent_sends(c->ibc_version, \
-							 c->ibc_peer->ibp_ni))
+	(IBLND_RECV_WRS(c) + 2 * c->ibc_queue_depth)
 
 struct kib_hca_dev;
 
@@ -617,26 +616,6 @@ struct kib_peer_ni {
 
 int kiblnd_msg_queue_size(int version, struct lnet_ni *ni);
 
-static inline int
-kiblnd_concurrent_sends(int version, struct lnet_ni *ni)
-{
-	struct lnet_ioctl_config_o2iblnd_tunables *tunables;
-	int concurrent_sends;
-
-	tunables = &ni->ni_lnd_tunables.lnd_tun_u.lnd_o2ib;
-	concurrent_sends = tunables->lnd_concurrent_sends;
-
-	if (version == IBLND_MSG_VERSION_1) {
-		if (concurrent_sends > IBLND_MSG_QUEUE_SIZE_V1 * 2)
-			return IBLND_MSG_QUEUE_SIZE_V1 * 2;
-
-		if (concurrent_sends < IBLND_MSG_QUEUE_SIZE_V1 / 2)
-			return IBLND_MSG_QUEUE_SIZE_V1 / 2;
-	}
-
-	return concurrent_sends;
-}
-
 static inline void
 kiblnd_hdev_addref_locked(struct kib_hca_dev *hdev)
 {
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
index 9d30f31..1f31798 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -787,7 +787,6 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 {
 	struct kib_msg *msg = tx->tx_msg;
 	struct kib_peer_ni *peer_ni = conn->ibc_peer;
-	struct lnet_ni *ni = peer_ni->ibp_ni;
 	int ver = conn->ibc_version;
 	int rc;
 	int done;
@@ -803,7 +802,7 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 	LASSERT(conn->ibc_credits >= 0);
 	LASSERT(conn->ibc_credits <= conn->ibc_queue_depth);
 
-	if (conn->ibc_nsends_posted == kiblnd_concurrent_sends(ver, ni)) {
+	if (conn->ibc_nsends_posted == conn->ibc_queue_depth) {
 		/* tx completions outstanding... */
 		CDEBUG(D_NET, "%s: posted enough\n",
 		       libcfs_nid2str(peer_ni->ibp_nid));
@@ -953,7 +952,7 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 		return;
 	}
 
-	LASSERT(conn->ibc_nsends_posted <= kiblnd_concurrent_sends(ver, ni));
+	LASSERT(conn->ibc_nsends_posted <= conn->ibc_queue_depth);
 	LASSERT(!IBLND_OOB_CAPABLE(ver) ||
 		conn->ibc_noops_posted <= IBLND_OOB_MSGS(ver));
 	LASSERT(conn->ibc_reserved_credits >= 0);
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_modparams.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_modparams.c
index 7fc6a8a..47e8a60 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_modparams.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_modparams.c
@@ -109,7 +109,7 @@
 
 static int concurrent_sends;
 module_param(concurrent_sends, int, 0444);
-MODULE_PARM_DESC(concurrent_sends, "send work-queue sizing");
+MODULE_PARM_DESC(concurrent_sends, "send work-queue sizing (obsolete)");
 
 static bool use_fastreg_gaps;
 module_param(use_fastreg_gaps, bool, 0444);
@@ -277,32 +277,6 @@ int kiblnd_tunables_setup(struct lnet_ni *ni)
 	if (tunables->lnd_peercredits_hiw >= net_tunables->lct_peer_tx_credits)
 		tunables->lnd_peercredits_hiw = net_tunables->lct_peer_tx_credits - 1;
 
-	if (tunables->lnd_concurrent_sends == 0)
-		tunables->lnd_concurrent_sends = net_tunables->lct_peer_tx_credits;
-
-	if (!tunables->lnd_concurrent_sends) {
-		if (tunables->lnd_map_on_demand > 0 &&
-		    tunables->lnd_map_on_demand <= IBLND_MAX_RDMA_FRAGS / 8) {
-			tunables->lnd_concurrent_sends =
-					net_tunables->lct_peer_tx_credits * 2;
-		} else {
-			tunables->lnd_concurrent_sends =
-				net_tunables->lct_peer_tx_credits;
-		}
-	}
-
-	if (tunables->lnd_concurrent_sends > net_tunables->lct_peer_tx_credits * 2)
-		tunables->lnd_concurrent_sends = net_tunables->lct_peer_tx_credits * 2;
-
-	if (tunables->lnd_concurrent_sends < net_tunables->lct_peer_tx_credits / 2)
-		tunables->lnd_concurrent_sends = net_tunables->lct_peer_tx_credits / 2;
-
-	if (tunables->lnd_concurrent_sends < net_tunables->lct_peer_tx_credits) {
-		CWARN("Concurrent sends %d is lower than message queue size: %d, performance may drop slightly.\n",
-		      tunables->lnd_concurrent_sends,
-		      net_tunables->lct_peer_tx_credits);
-	}
-
 	if (!tunables->lnd_fmr_pool_size)
 		tunables->lnd_fmr_pool_size = fmr_pool_size;
 	if (!tunables->lnd_fmr_flush_trigger)
@@ -324,7 +298,6 @@ void kiblnd_tunables_init(void)
 	default_tunables.lnd_version = 0;
 	default_tunables.lnd_peercredits_hiw = peer_credits_hiw;
 	default_tunables.lnd_map_on_demand = map_on_demand;
-	default_tunables.lnd_concurrent_sends = concurrent_sends;
 	default_tunables.lnd_fmr_pool_size = fmr_pool_size;
 	default_tunables.lnd_fmr_flush_trigger = fmr_flush_trigger;
 	default_tunables.lnd_fmr_cache = fmr_cache;
-- 
1.8.3.1
