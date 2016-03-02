From: James Simmons <jsimmons@infradead.org>
Date: Wed,  2 Mar 2016 17:02:10 -0500
Subject: [lustre-devel] [PATCH 27/27] staging: lustre: do less intense
	allocating retry for ko2iblnd
In-Reply-To: <1456956130-6110-1-git-send-email-jsimmons@infradead.org>
References: <1456956130-6110-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1456956130-6110-28-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Liang Zhen <liang.zhen@intel.com>

From: Liang Zhen <liang.zhen@intel.com>

ko2iblnd may retry too frequent for growing pools, all schedulers
are spinning if another thread is in progress of allocating a new
pool and can't finish right away because of high system load.

Signed-off-by: Liang Zhen <liang.zhen@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-7054
Reviewed-on: http://review.whamcloud.com/16470
Reviewed-by: Doug Oucharek <doug.s.oucharek@intel.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c    |   20 ++++++++++++++++----
 1 files changed, 16 insertions(+), 4 deletions(-)

diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
index 135ccf1..0d32e65 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
@@ -1218,6 +1218,7 @@ static kib_hca_dev_t *kiblnd_current_hdev(kib_dev_t *dev)
 		if (!(i++ % 50))
 			CDEBUG(D_NET, "%s: Wait for failover\n",
 			       dev->ibd_ifname);
+		set_current_state(TASK_INTERRUPTIBLE);
 		schedule_timeout(cfs_time_seconds(1) / 100);
 
 		read_lock_irqsave(&kiblnd_data.kib_global_lock, flags);
@@ -1684,6 +1685,9 @@ struct list_head *kiblnd_pool_alloc_node(kib_poolset_t *ps)
 {
 	struct list_head *node;
 	kib_pool_t *pool;
+	unsigned int interval = 1;
+	unsigned long time_before;
+	unsigned int trips = 0;
 	int rc;
 
  again:
@@ -1709,9 +1713,15 @@ struct list_head *kiblnd_pool_alloc_node(kib_poolset_t *ps)
 	if (ps->ps_increasing) {
 		/* another thread is allocating a new pool */
 		spin_unlock(&ps->ps_lock);
-		CDEBUG(D_NET, "Another thread is allocating new %s pool, waiting for her to complete\n",
-		       ps->ps_name);
-		schedule();
+		trips++;
+		CDEBUG(D_NET, "Another thread is allocating new %s pool, waiting %d HZs for her to complete. trips = %d\n",
+		       ps->ps_name, interval, trips);
+
+		set_current_state(TASK_INTERRUPTIBLE);
+		schedule_timeout(interval);
+		if (interval < cfs_time_seconds(1))
+			interval *= 2;
+
 		goto again;
 	}
 
@@ -1725,8 +1735,10 @@ struct list_head *kiblnd_pool_alloc_node(kib_poolset_t *ps)
 	spin_unlock(&ps->ps_lock);
 
 	CDEBUG(D_NET, "%s pool exhausted, allocate new pool\n", ps->ps_name);
-
+	time_before = cfs_time_current();
 	rc = ps->ps_pool_create(ps, ps->ps_pool_size, &pool);
+	CDEBUG(D_NET, "ps_pool_create took %lu HZ to complete",
+	       cfs_time_current() - time_before);
 
 	spin_lock(&ps->ps_lock);
 	ps->ps_increasing = 0;
-- 
1.7.1
