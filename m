From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:12:10 -0500
Subject: [lustre-devel] [PATCH 262/622] lnet: lnd: bring back
 concurrent_sends
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-263-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <ashehata@whamcloud.com>

Revert "lustre: lnd: remove concurrent_sends tunable"

This reverts commit 0d4b38f73774f8363d6c419b16d3b34d23ad1ca9.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11931
Lustre-commit: 83e45ead69ba ("LU-11931 lnd: bring back concurrent_sends")
Signed-off-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/34646
Reviewed-by: Alexey Lyashkov <c17817@cray.com>
Reviewed-by: Chris Horn <hornc@cray.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/klnds/o2iblnd/o2iblnd.h           | 24 +++++++++++++++++++++++-
 net/lnet/klnds/o2iblnd/o2iblnd_cb.c        |  5 +++--
 net/lnet/klnds/o2iblnd/o2iblnd_modparams.c | 30 +++++++++++++++++++++++++++---
 3 files changed, 53 insertions(+), 6 deletions(-)

diff --git a/net/lnet/klnds/o2iblnd/o2iblnd.h b/net/lnet/klnds/o2iblnd/o2iblnd.h
index 44f1d84..baf1006 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd.h
+++ b/net/lnet/klnds/o2iblnd/o2iblnd.h
@@ -136,7 +136,9 @@ struct kib_tunables {
 /* WRs and CQEs (per connection) */
 #define IBLND_RECV_WRS(c)	IBLND_RX_MSGS(c)
 
-#define IBLND_CQ_ENTRIES(c)	(IBLND_RECV_WRS(c) + kiblnd_send_wrs(c))
+#define IBLND_CQ_ENTRIES(c)	\
+	(IBLND_RECV_WRS(c) + 2 * kiblnd_concurrent_sends(c->ibc_version, \
+							 c->ibc_peer->ibp_ni))
 
 struct kib_hca_dev;
 
@@ -635,6 +637,26 @@ struct kib_peer_ni {
 
 int kiblnd_msg_queue_size(int version, struct lnet_ni *ni);
 
+static inline int
+kiblnd_concurrent_sends(int version, struct lnet_ni *ni)
+{
+	struct lnet_ioctl_config_o2iblnd_tunables *tunables;
+	int concurrent_sends;
+
+	tunables = &ni->ni_lnd_tunables.lnd_tun_u.lnd_o2ib;
+	concurrent_sends = tunables->lnd_concurrent_sends;
+
+	if (version == IBLND_MSG_VERSION_1) {
+		if (concurrent_sends > IBLND_MSG_QUEUE_SIZE_V1 * 2)
+			return IBLND_MSG_QUEUE_SIZE_V1 * 2;
+
+		if (concurrent_sends < IBLND_MSG_QUEUE_SIZE_V1 / 2)
+			return IBLND_MSG_QUEUE_SIZE_V1 / 2;
+	}
+
+	return concurrent_sends;
+}
+
 static inline void
 kiblnd_hdev_addref_locked(struct kib_hca_dev *hdev)
 {
diff --git a/net/lnet/klnds/o2iblnd/o2iblnd_cb.c b/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
index 68ab7d5..fa5c93a 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -806,6 +806,7 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 {
 	struct kib_msg *msg = tx->tx_msg;
 	struct kib_peer_ni *peer_ni = conn->ibc_peer;
+	struct lnet_ni *ni = peer_ni->ibp_ni;
 	int ver = conn->ibc_version;
 	int rc;
 	int done;
@@ -821,7 +822,7 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 	LASSERT(conn->ibc_credits >= 0);
 	LASSERT(conn->ibc_credits <= conn->ibc_queue_depth);
 
-	if (conn->ibc_nsends_posted == conn->ibc_queue_depth) {
+	if (conn->ibc_nsends_posted == kiblnd_concurrent_sends(ver, ni)) {
 		/* tx completions outstanding... */
 		CDEBUG(D_NET, "%s: posted enough\n",
 		       libcfs_nid2str(peer_ni->ibp_nid));
@@ -976,7 +977,7 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 		return;
 	}
 
-	LASSERT(conn->ibc_nsends_posted <= conn->ibc_queue_depth);
+	LASSERT(conn->ibc_nsends_posted <= kiblnd_concurrent_sends(ver, ni));
 	LASSERT(!IBLND_OOB_CAPABLE(ver) ||
 		conn->ibc_noops_posted <= IBLND_OOB_MSGS(ver));
 	LASSERT(conn->ibc_reserved_credits >= 0);
diff --git a/net/lnet/klnds/o2iblnd/o2iblnd_modparams.c b/net/lnet/klnds/o2iblnd/o2iblnd_modparams.c
index b5df7fe..c9e14ec 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd_modparams.c
+++ b/net/lnet/klnds/o2iblnd/o2iblnd_modparams.c
@@ -109,7 +109,7 @@
 
 static int concurrent_sends;
 module_param(concurrent_sends, int, 0444);
-MODULE_PARM_DESC(concurrent_sends, "send work-queue sizing (obsolete)");
+MODULE_PARM_DESC(concurrent_sends, "send work-queue sizing");
 
 static bool use_fastreg_gaps;
 module_param(use_fastreg_gaps, bool, 0444);
@@ -272,10 +272,33 @@ int kiblnd_tunables_setup(struct lnet_ni *ni)
 		tunables->lnd_peercredits_hiw = peer_credits_hiw;
 
 	if (tunables->lnd_peercredits_hiw < net_tunables->lct_peer_tx_credits / 2)
-		tunables->lnd_peercredits_hiw = net_tunables->lct_peer_tx_credits / 2;
+		tunables->lnd_peercredits_hiw =
+			net_tunables->lct_peer_tx_credits / 2;
 
 	if (tunables->lnd_peercredits_hiw >= net_tunables->lct_peer_tx_credits)
-		tunables->lnd_peercredits_hiw = net_tunables->lct_peer_tx_credits - 1;
+		tunables->lnd_peercredits_hiw =
+			net_tunables->lct_peer_tx_credits - 1;
+
+	if (tunables->lnd_concurrent_sends == 0)
+		tunables->lnd_concurrent_sends =
+			net_tunables->lct_peer_tx_credits;
+
+	if (tunables->lnd_concurrent_sends >
+	    net_tunables->lct_peer_tx_credits * 2)
+		tunables->lnd_concurrent_sends =
+			net_tunables->lct_peer_tx_credits * 2;
+
+	if (tunables->lnd_concurrent_sends <
+	    net_tunables->lct_peer_tx_credits / 2)
+		tunables->lnd_concurrent_sends =
+			net_tunables->lct_peer_tx_credits / 2;
+
+	if (tunables->lnd_concurrent_sends <
+	    net_tunables->lct_peer_tx_credits) {
+		CWARN("Concurrent sends %d is lower than message queue size: %d, performance may drop slightly.\n",
+		      tunables->lnd_concurrent_sends,
+		      net_tunables->lct_peer_tx_credits);
+	}
 
 	if (!tunables->lnd_fmr_pool_size)
 		tunables->lnd_fmr_pool_size = fmr_pool_size;
@@ -298,6 +321,7 @@ void kiblnd_tunables_init(void)
 	default_tunables.lnd_version = 0;
 	default_tunables.lnd_peercredits_hiw = peer_credits_hiw;
 	default_tunables.lnd_map_on_demand = map_on_demand;
+	default_tunables.lnd_concurrent_sends = concurrent_sends;
 	default_tunables.lnd_fmr_pool_size = fmr_pool_size;
 	default_tunables.lnd_fmr_flush_trigger = fmr_flush_trigger;
 	default_tunables.lnd_fmr_cache = fmr_cache;
-- 
1.8.3.1
