From: Cihangir Akturk <cakturk@gmail.com>
Date: Thu,  7 Sep 2017 13:57:42 +0300
Subject: [lustre-devel] [PATCH] staging: lustre: avoid going through
	unlock/lock overhead
Message-ID: <1504781862-15577-1-git-send-email-cakturk@gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org
Cc: devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, oleg.drokin@intel.com, andreas.dilger@intel.com, jsimmons@infradead.org, gregkh@linuxfoundation.org, Cihangir Akturk <cakturk@gmail.com>

Unlocking a spin lock and then immediately locking without doing
anything useful in between buys us nothing, except wasting CPU cycles.

Also code size gets smaller.

Before:

 text  data   bss    dec    hex filename
70415  2356  4108  76879  12c4f drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.o

After:

 text  data   bss    dec    hex filename
70095  2356  4108  76559  12b0f drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.o

Signed-off-by: Cihangir Akturk <cakturk@gmail.com>
---
 drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c | 18 ++++++++----------
 1 file changed, 8 insertions(+), 10 deletions(-)

diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
index 64763aa..5d9cd33 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
@@ -1624,8 +1624,9 @@ int kiblnd_fmr_pool_map(struct kib_fmr_poolset *fps, struct kib_tx *tx,
 	__u64 version;
 	int rc;
 
- again:
+again:
 	spin_lock(&fps->fps_lock);
+again_locked:
 	version = fps->fps_version;
 	list_for_each_entry(fpo, &fps->fps_pool_list, fpo_list) {
 		fpo->fpo_deadline = cfs_time_shift(IBLND_POOL_DEADLINE);
@@ -1722,10 +1723,8 @@ int kiblnd_fmr_pool_map(struct kib_fmr_poolset *fps, struct kib_tx *tx,
 		}
 
 		/* EAGAIN and ... */
-		if (version != fps->fps_version) {
-			spin_unlock(&fps->fps_lock);
-			goto again;
-		}
+		if (version != fps->fps_version)
+			goto again_locked;
 	}
 
 	if (fps->fps_increasing) {
@@ -1754,9 +1753,8 @@ int kiblnd_fmr_pool_map(struct kib_fmr_poolset *fps, struct kib_tx *tx,
 	} else {
 		fps->fps_next_retry = cfs_time_shift(IBLND_POOL_RETRY);
 	}
-	spin_unlock(&fps->fps_lock);
 
-	goto again;
+	goto again_locked;
 }
 
 static void kiblnd_fini_pool(struct kib_pool *pool)
@@ -1901,8 +1899,9 @@ struct list_head *kiblnd_pool_alloc_node(struct kib_poolset *ps)
 	unsigned int trips = 0;
 	int rc;
 
- again:
+again:
 	spin_lock(&ps->ps_lock);
+again_locked:
 	list_for_each_entry(pool, &ps->ps_pool_list, po_list) {
 		if (list_empty(&pool->po_free_list))
 			continue;
@@ -1960,9 +1959,8 @@ struct list_head *kiblnd_pool_alloc_node(struct kib_poolset *ps)
 		CERROR("Can't allocate new %s pool because out of memory\n",
 		       ps->ps_name);
 	}
-	spin_unlock(&ps->ps_lock);
 
-	goto again;
+	goto again_locked;
 }
 
 static void kiblnd_destroy_tx_pool(struct kib_pool *pool)
-- 
2.7.4
