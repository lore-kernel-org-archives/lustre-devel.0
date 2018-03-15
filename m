From: Doug Oucharek <dougso@me.com>
Date: Wed, 14 Mar 2018 23:18:30 -0700
Subject: [lustre-devel] [PATCH] staging: lustre: o2iblnd: Fix FastReg
 map/unmap for MLX5
Message-ID: <B5E4E902-16A7-4279-BE5A-8117E23286E9@me.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, "Drokin, Oleg" <oleg.drokin@intel.com>, "Dilger, Andreas" <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

The FastReg support in ko2iblnd was not unmapping pool items
causing the items to leak.  In addition, the mapping code
is not growing the pool like we do with FMR.

This patch makes sure we are unmapping FastReg pool elements
when we are done with them.  It also makes sure the pool
will grow when we depleat the pool.

Signed-off-by: Doug Oucharek <doug.s.oucharek@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-9472
Reviewed-on: https://review.whamcloud.com/27015
Reviewed-by: Andrew Perepechko <andrew.perepechko@seagate.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: Doug Oucharek <dougso@me.com>
---
drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c    |  2 +-
drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c | 12 ++++--------
2 files changed, 5 insertions(+), 9 deletions(-)

diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
index 7ae2955..355c816 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
@@ -1702,7 +1702,7 @@ int kiblnd_fmr_pool_map(struct kib_fmr_poolset *fps, struct kib_tx *tx,
				return 0;
			}
			spin_unlock(&fps->fps_lock);
-			rc = -EBUSY;
+			rc = -EAGAIN;
		}

		spin_lock(&fps->fps_lock);
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
index 6690a6c..6ed779ef0 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -48,7 +48,7 @@ static int kiblnd_init_rdma(struct kib_conn *conn, struct kib_tx *tx, int type,
			    __u64 dstcookie);
static void kiblnd_queue_tx_locked(struct kib_tx *tx, struct kib_conn *conn);
static void kiblnd_queue_tx(struct kib_tx *tx, struct kib_conn *conn);
-static void kiblnd_unmap_tx(struct lnet_ni *ni, struct kib_tx *tx);
+static void kiblnd_unmap_tx(struct kib_tx *tx);
static void kiblnd_check_sends_locked(struct kib_conn *conn);

static void
@@ -66,7 +66,7 @@ static int kiblnd_init_rdma(struct kib_conn *conn, struct kib_tx *tx, int type,
	LASSERT(!tx->tx_waiting);	      /* mustn't be awaiting peer response */
	LASSERT(tx->tx_pool);

-	kiblnd_unmap_tx(ni, tx);
+	kiblnd_unmap_tx(tx);

	/* tx may have up to 2 lnet msgs to finalise */
	lntmsg[0] = tx->tx_lntmsg[0]; tx->tx_lntmsg[0] = NULL;
@@ -591,13 +591,9 @@ static int kiblnd_init_rdma(struct kib_conn *conn, struct kib_tx *tx, int type,
	return 0;
}

-static void kiblnd_unmap_tx(struct lnet_ni *ni, struct kib_tx *tx)
+static void kiblnd_unmap_tx(struct kib_tx *tx)
{
-	struct kib_net *net = ni->ni_data;
-
-	LASSERT(net);
-
-	if (net->ibn_fmr_ps)
+	if (tx->fmr.fmr_pfmr || tx->fmr.fmr_frd)
		kiblnd_fmr_pool_unmap(&tx->fmr, tx->tx_status);

	if (tx->tx_nfrags) {
-- 
1.8.3.1
