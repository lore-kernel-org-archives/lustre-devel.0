From: Doug Oucharek <dougso@me.com>
Date: Thu, 15 Mar 2018 14:53:46 -0700
Subject: [lustre-devel] [PATCH] staging: lustre: o2iblnd: Enable Multiple
 OPA Endpoints between Nodes
Message-ID: <2253BE75-D4ED-4021-BBA1-BCBF2C6770CB@me.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, "Drokin, Oleg" <oleg.drokin@intel.com>, "Dilger, Andreas" <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

OPA driver optimizations are based on the MPI model where it is
expected to have multiple endpoints between two given nodes. To
enable this optimization for Lustre, we need to make it possible,
via an LND-specific tuneable, to create multiple endpoints and to
balance the traffic over them.

Both sides of a connection must have this patch for it to work.
Only the active side of the connection (usually the client)
needs to have the new tuneable set > 1.

Signed-off-by: Doug Oucharek <doug.s.oucharek@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-8943
Reviewed-on: https://review.whamcloud.com/25168
Reviewed-by: Amir Shehata <amir.shehata@intel.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: Doug Oucharek <dougso@me.com>
---
.../lustre/include/uapi/linux/lnet/lnet-dlc.h      |  3 ++-
.../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h    | 17 ++++++++++++---
.../staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c | 25 +++++++++++++++-------
.../lustre/lnet/klnds/o2iblnd/o2iblnd_modparams.c  |  9 ++++++++
4 files changed, 42 insertions(+), 12 deletions(-)

diff --git a/drivers/staging/lustre/include/uapi/linux/lnet/lnet-dlc.h b/drivers/staging/lustre/include/uapi/linux/lnet/lnet-dlc.h
index e45d828..c1619f4 100644
--- a/drivers/staging/lustre/include/uapi/linux/lnet/lnet-dlc.h
+++ b/drivers/staging/lustre/include/uapi/linux/lnet/lnet-dlc.h
@@ -53,7 +53,8 @@ struct lnet_ioctl_config_o2iblnd_tunables {
	__u32 lnd_fmr_pool_size;
	__u32 lnd_fmr_flush_trigger;
	__u32 lnd_fmr_cache;
-	__u32 pad;
+	__u16 lnd_conns_per_peer;
+	__u16 pad;
};

struct lnet_ioctl_config_lnd_tunables {
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
index b18911d..af5f573 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
@@ -568,6 +568,8 @@ struct kib_peer {
	lnet_nid_t       ibp_nid;         /* who's on the other end(s) */
	struct lnet_ni	*ibp_ni;         /* LNet interface */
	struct list_head ibp_conns;       /* all active connections */
+	struct kib_conn	*ibp_next_conn;  /* next connection to send on for
+					    round robin */
	struct list_head ibp_tx_queue;    /* msgs waiting for a conn */
	__u64            ibp_incarnation; /* incarnation of peer */
	/* when (in jiffies) I was last alive */
@@ -581,7 +583,7 @@ struct kib_peer {
	/* current active connection attempts */
	unsigned short		ibp_connecting;
	/* reconnect this peer later */
-	unsigned short		ibp_reconnecting:1;
+	unsigned char		ibp_reconnecting;
	/* counter of how many times we triggered a conn race */
	unsigned char		ibp_races;
	/* # consecutive reconnection attempts to this peer */
@@ -744,10 +746,19 @@ struct kib_peer {
static inline struct kib_conn *
kiblnd_get_conn_locked(struct kib_peer *peer)
{
+	struct list_head *next;
+
	LASSERT(!list_empty(&peer->ibp_conns));

-	/* just return the first connection */
-	return list_entry(peer->ibp_conns.next, struct kib_conn, ibc_list);
+	/* Advance to next connection, be sure to skip the head node */
+	if (!peer->ibp_next_conn ||
+	    peer->ibp_next_conn->ibc_list.next == &peer->ibp_conns)
+		next = peer->ibp_conns.next;
+	else
+		next = peer->ibp_next_conn->ibc_list.next;
+	peer->ibp_next_conn = list_entry(next, struct kib_conn, ibc_list);
+
+	return peer->ibp_next_conn;
}

static inline int
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
index 6690a6c..3cb1f720 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -1250,7 +1250,6 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,

	LASSERT(net);
	LASSERT(peer->ibp_connecting > 0);
-	LASSERT(!peer->ibp_reconnecting);

	cmid = kiblnd_rdma_create_id(kiblnd_cm_callback, peer, RDMA_PS_TCP,
				     IB_QPT_RC);
@@ -1332,7 +1331,7 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,

	LASSERT(!peer->ibp_accepting && !peer->ibp_connecting &&
		list_empty(&peer->ibp_conns));
-	peer->ibp_reconnecting = 0;
+	peer->ibp_reconnecting--;

	if (!kiblnd_peer_active(peer)) {
		list_splice_init(&peer->ibp_tx_queue, &txs);
@@ -1365,6 +1364,8 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
	rwlock_t *g_lock = &kiblnd_data.kib_global_lock;
	unsigned long flags;
	int rc;
+	int		   i;
+	struct lnet_ioctl_config_o2iblnd_tunables *tunables;

	/*
	 * If I get here, I've committed to send, so I complete the tx with
@@ -1461,7 +1462,8 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,

	/* Brand new peer */
	LASSERT(!peer->ibp_connecting);
-	peer->ibp_connecting = 1;
+	tunables = &peer->ibp_ni->ni_lnd_tunables->lt_tun_u.lt_o2ib;
+	peer->ibp_connecting = tunables->lnd_conns_per_peer;

	/* always called with a ref on ni, which prevents ni being shutdown */
	LASSERT(!((struct kib_net *)ni->ni_data)->ibn_shutdown);
@@ -1474,7 +1476,8 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,

	write_unlock_irqrestore(g_lock, flags);

-	kiblnd_connect_peer(peer);
+	for (i = 0; i < tunables->lnd_conns_per_peer; i++)
+		kiblnd_connect_peer(peer);
	kiblnd_peer_decref(peer);
}

@@ -1923,6 +1926,9 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
	}

	dev = ((struct kib_net *)peer->ibp_ni->ni_data)->ibn_dev;
+	if (peer->ibp_next_conn == conn)
+		/* clear next_conn so it won't be used */
+		peer->ibp_next_conn = NULL;
	list_del(&conn->ibc_list);
	/* connd (see below) takes over ibc_list's ref */

@@ -2192,7 +2198,11 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
	kiblnd_conn_addref(conn);
	write_unlock_irqrestore(&kiblnd_data.kib_global_lock, flags);

-	/* Schedule blocked txs */
+	/* Schedule blocked txs
+	 * Note: if we are running with conns_per_peer > 1, these blocked
+ 	 * txs will all get scheduled to the first connection which gets
+ 	 * scheduled.  We won't be using round robin on this first batch.
+ 	 */
	spin_lock(&conn->ibc_lock);
	list_for_each_entry_safe(tx, tmp, &txs, tx_list) {
		list_del(&tx->tx_list);
@@ -2561,7 +2571,6 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,

	LASSERT(conn->ibc_state == IBLND_CONN_ACTIVE_CONNECT);
	LASSERT(peer->ibp_connecting > 0);     /* 'conn' at least */
-	LASSERT(!peer->ibp_reconnecting);

	if (cp) {
		msg_size = cp->ibcp_max_msg_size;
@@ -2579,7 +2588,7 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
	 */
	reconnect = (!list_empty(&peer->ibp_tx_queue) ||
		     peer->ibp_version != version) &&
-		    peer->ibp_connecting == 1 &&
+		    peer->ibp_connecting &&
		    !peer->ibp_accepting;
	if (!reconnect) {
		reason = "no need";
@@ -2640,7 +2649,7 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
	}

	conn->ibc_reconnect = 1;
-	peer->ibp_reconnecting = 1;
+	peer->ibp_reconnecting++;
	peer->ibp_version = version;
	if (incarnation)
		peer->ibp_incarnation = incarnation;
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_modparams.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_modparams.c
index b923540..39d0792 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_modparams.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_modparams.c
@@ -57,6 +57,10 @@
module_param(nscheds, int, 0444);
MODULE_PARM_DESC(nscheds, "number of threads in each scheduler pool");

+static unsigned int conns_per_peer = 1;
+module_param(conns_per_peer, uint, 0444);
+MODULE_PARM_DESC(conns_per_peer, "number of connections per peer");
+
/* NB: this value is shared by all CPTs, it can grow at runtime */
static int ntx = 512;
module_param(ntx, int, 0444);
@@ -271,6 +275,10 @@ int kiblnd_tunables_setup(struct lnet_ni *ni)
		tunables->lnd_fmr_flush_trigger = fmr_flush_trigger;
	if (!tunables->lnd_fmr_cache)
		tunables->lnd_fmr_cache = fmr_cache;
+	if (!tunables->lnd_conns_per_peer) {
+		tunables->lnd_conns_per_peer = (conns_per_peer) ?
+			conns_per_peer : 1;
+	}

	return 0;
}
@@ -284,4 +292,5 @@ void kiblnd_tunables_init(void)
	default_tunables.lnd_fmr_pool_size = fmr_pool_size;
	default_tunables.lnd_fmr_flush_trigger = fmr_flush_trigger;
	default_tunables.lnd_fmr_cache = fmr_cache;
+	default_tunables.lnd_conns_per_peer = conns_per_peer;
}
-- 
1.8.3.1
