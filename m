From: James Simmons <jsimmons@infradead.org>
Date: Tue, 25 Sep 2018 22:48:13 -0400
Subject: [lustre-devel] [PATCH 21/25] lustre: lnet: set LND tunables properly
In-Reply-To: <1537930097-11624-1-git-send-email-jsimmons@infradead.org>
References: <1537930097-11624-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1537930097-11624-22-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <ashehata@whamcloud.com>

Make sure to set all NIs to the proper LND tunables
specified.

Add ntx tunable to dynamic configuration. This way all
tunables required to tune OPA performance can be configured
via lnetctl, allowing the ability to tune OPA network and IB
network differently

Signed-off-by: Amir Shehata <ashehata@whamcloud.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-9536
Reviewed-on: https://review.whamcloud.com/27263
Reviewed-by: Doug Oucharek <dougso@me.com>
Reviewed-by: Sonia Sharma <sharmaso@whamcloud.com>
Reviewed-by: Olaf Weber <olaf.weber@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/include/uapi/linux/lnet/lnet-dlc.h  |  2 +-
 drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c        | 14 +++++++++-----
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd_modparams.c  |  4 +++-
 3 files changed, 13 insertions(+), 7 deletions(-)

diff --git a/drivers/staging/lustre/include/uapi/linux/lnet/lnet-dlc.h b/drivers/staging/lustre/include/uapi/linux/lnet/lnet-dlc.h
index 07516fd..8f03aa3 100644
--- a/drivers/staging/lustre/include/uapi/linux/lnet/lnet-dlc.h
+++ b/drivers/staging/lustre/include/uapi/linux/lnet/lnet-dlc.h
@@ -66,7 +66,7 @@ struct lnet_ioctl_config_o2iblnd_tunables {
 	__u32 lnd_fmr_flush_trigger;
 	__u32 lnd_fmr_cache;
 	__u16 lnd_conns_per_peer;
-	__u16 pad;
+	__u16 lnd_ntx;
 };
 
 struct lnet_lnd_tunables {
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
index 0ce9962..50c0c00 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
@@ -2034,9 +2034,13 @@ static void kiblnd_destroy_tx_pool(struct kib_pool *pool)
 	kfree(tpo);
 }
 
-static int kiblnd_tx_pool_size(int ncpts)
+static int kiblnd_tx_pool_size(struct lnet_ni *ni, int ncpts)
 {
-	int ntx = *kiblnd_tunables.kib_ntx / ncpts;
+	struct lnet_ioctl_config_o2iblnd_tunables *tunables;
+	int ntx;
+
+	tunables = &ni->ni_lnd_tunables.lnd_tun_u.lnd_o2ib;
+	ntx = tunables->lnd_ntx / ncpts;
 
 	return max(IBLND_TX_POOL, ntx);
 }
@@ -2176,10 +2180,10 @@ static int kiblnd_net_init_pools(struct kib_net *net, struct lnet_ni *ni,
 
 	tunables = &ni->ni_lnd_tunables.lnd_tun_u.lnd_o2ib;
 
-	if (tunables->lnd_fmr_pool_size < *kiblnd_tunables.kib_ntx / 4) {
+	if (tunables->lnd_fmr_pool_size < tunables->lnd_ntx / 4) {
 		CERROR("Can't set fmr pool size (%d) < ntx / 4(%d)\n",
 		       tunables->lnd_fmr_pool_size,
-		       *kiblnd_tunables.kib_ntx / 4);
+		       tunables->lnd_ntx / 4);
 		rc = -EINVAL;
 		goto failed;
 	}
@@ -2237,7 +2241,7 @@ static int kiblnd_net_init_pools(struct kib_net *net, struct lnet_ni *ni,
 		cpt = !cpts ? i : cpts[i];
 		rc = kiblnd_init_poolset(&net->ibn_tx_ps[cpt]->tps_poolset,
 					 cpt, net, "TX",
-					 kiblnd_tx_pool_size(ncpts),
+					 kiblnd_tx_pool_size(ni, ncpts),
 					 kiblnd_create_tx_pool,
 					 kiblnd_destroy_tx_pool,
 					 kiblnd_tx_init, NULL);
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_modparams.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_modparams.c
index 3bb537e..0f2ad91 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_modparams.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_modparams.c
@@ -157,7 +157,6 @@ struct kib_tunables kiblnd_tunables = {
 	.kib_cksum             = &cksum,
 	.kib_timeout           = &timeout,
 	.kib_keepalive         = &keepalive,
-	.kib_ntx               = &ntx,
 	.kib_default_ipif      = &ipif_name,
 	.kib_retry_count       = &retry_count,
 	.kib_rnr_retry_count   = &rnr_retry_count,
@@ -282,6 +281,8 @@ int kiblnd_tunables_setup(struct lnet_ni *ni)
 		tunables->lnd_fmr_flush_trigger = fmr_flush_trigger;
 	if (!tunables->lnd_fmr_cache)
 		tunables->lnd_fmr_cache = fmr_cache;
+	if (!tunables->lnd_ntx)
+		tunables->lnd_ntx = ntx;
 	if (!tunables->lnd_conns_per_peer) {
 		tunables->lnd_conns_per_peer = (conns_per_peer) ?
 			conns_per_peer : 1;
@@ -299,5 +300,6 @@ void kiblnd_tunables_init(void)
 	default_tunables.lnd_fmr_pool_size = fmr_pool_size;
 	default_tunables.lnd_fmr_flush_trigger = fmr_flush_trigger;
 	default_tunables.lnd_fmr_cache = fmr_cache;
+	default_tunables.lnd_ntx = ntx;
 	default_tunables.lnd_conns_per_peer = conns_per_peer;
 }
-- 
1.8.3.1
