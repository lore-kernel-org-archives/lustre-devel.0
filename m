From: James Simmons <jsimmons@infradead.org>
Date: Wed, 15 Jul 2020 16:45:04 -0400
Subject: [lustre-devel] [PATCH 23/37] lnet: o2iblnd: use need_resched()
In-Reply-To: <1594845918-29027-1-git-send-email-jsimmons@infradead.org>
References: <1594845918-29027-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1594845918-29027-24-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mr NeilBrown <neilb@suse.de>

Rather than using a counter to decide when to drop
the lock and see if we need to reshedule we can
use need_resched(), which is a precise test instead of a guess.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12678
Lustre-commit: dcd799269f693 ("LU-12678 o2iblnd: use need_resched()")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/39125
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Shaun Tancheff <shaun.tancheff@hpe.com>
Reviewed-by: Chris Horn <chris.horn@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/klnds/o2iblnd/o2iblnd.h    | 2 --
 net/lnet/klnds/o2iblnd/o2iblnd_cb.c | 5 +----
 2 files changed, 1 insertion(+), 6 deletions(-)

diff --git a/net/lnet/klnds/o2iblnd/o2iblnd.h b/net/lnet/klnds/o2iblnd/o2iblnd.h
index f60a69d..9a2fb42 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd.h
+++ b/net/lnet/klnds/o2iblnd/o2iblnd.h
@@ -67,8 +67,6 @@
 #include <linux/lnet/lib-lnet.h>
 
 #define IBLND_PEER_HASH_SIZE		101	/* # peer_ni lists */
-/* # scheduler loops before reschedule */
-#define IBLND_RESCHED			100
 
 #define IBLND_N_SCHED			2
 #define IBLND_N_SCHED_HIGH		4
diff --git a/net/lnet/klnds/o2iblnd/o2iblnd_cb.c b/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
index 3b9d10d..2c670a33 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -3605,7 +3605,6 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
 	unsigned long flags;
 	struct ib_wc wc;
 	int did_something;
-	int busy_loops = 0;
 	int rc;
 
 	init_waitqueue_entry(&wait, current);
@@ -3621,11 +3620,10 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
 	spin_lock_irqsave(&sched->ibs_lock, flags);
 
 	while (!kiblnd_data.kib_shutdown) {
-		if (busy_loops++ >= IBLND_RESCHED) {
+		if (need_resched()) {
 			spin_unlock_irqrestore(&sched->ibs_lock, flags);
 
 			cond_resched();
-			busy_loops = 0;
 
 			spin_lock_irqsave(&sched->ibs_lock, flags);
 		}
@@ -3718,7 +3716,6 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
 		spin_unlock_irqrestore(&sched->ibs_lock, flags);
 
 		schedule();
-		busy_loops = 0;
 
 		remove_wait_queue(&sched->ibs_waitq, &wait);
 		spin_lock_irqsave(&sched->ibs_lock, flags);
-- 
1.8.3.1
