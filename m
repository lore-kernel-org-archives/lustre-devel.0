From: James Simmons <jsimmons@infradead.org>
Date: Wed, 15 Jul 2020 16:45:06 -0400
Subject: [lustre-devel] [PATCH 25/37] lnet: socklnd: use need_resched()
In-Reply-To: <1594845918-29027-1-git-send-email-jsimmons@infradead.org>
References: <1594845918-29027-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1594845918-29027-26-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mr NeilBrown <neilb@suse.de>

Rather than using a counter to decide when to drop the lock and see if
we need to reshedule we can use need_resched(), which is a precise
test instead of a guess.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12678
Lustre-commit: 3f848f85ba3d3 ("LU-12678 socklnd: use need_resched()")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/39128
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Shaun Tancheff <shaun.tancheff@hpe.com>
Reviewed-by: Chris Horn <chris.horn@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/klnds/socklnd/socklnd.h    |  1 -
 net/lnet/klnds/socklnd/socklnd_cb.c | 12 +++---------
 2 files changed, 3 insertions(+), 10 deletions(-)

diff --git a/net/lnet/klnds/socklnd/socklnd.h b/net/lnet/klnds/socklnd/socklnd.h
index 0ac3637..0a0f0a7 100644
--- a/net/lnet/klnds/socklnd/socklnd.h
+++ b/net/lnet/klnds/socklnd/socklnd.h
@@ -55,7 +55,6 @@
 #define SOCKNAL_NSCHEDS_HIGH	(SOCKNAL_NSCHEDS << 1)
 
 #define SOCKNAL_PEER_HASH_BITS	7     /* # log2 of # of peer_ni lists */
-#define SOCKNAL_RESCHED		100   /* # scheduler loops before reschedule */
 #define SOCKNAL_INSANITY_RECONN	5000  /* connd is trying on reconn infinitely */
 #define SOCKNAL_ENOMEM_RETRY	1     /* seconds between retries */
 
diff --git a/net/lnet/klnds/socklnd/socklnd_cb.c b/net/lnet/klnds/socklnd/socklnd_cb.c
index 623478c..936054ee 100644
--- a/net/lnet/klnds/socklnd/socklnd_cb.c
+++ b/net/lnet/klnds/socklnd/socklnd_cb.c
@@ -1328,7 +1328,6 @@ int ksocknal_scheduler(void *arg)
 	struct ksock_conn *conn;
 	struct ksock_tx *tx;
 	int rc;
-	int nloops = 0;
 	long id = (long)arg;
 
 	sched = ksocknal_data.ksnd_schedulers[KSOCK_THREAD_CPT(id)];
@@ -1470,12 +1469,10 @@ int ksocknal_scheduler(void *arg)
 
 			did_something = 1;
 		}
-		if (!did_something ||		/* nothing to do */
-		    ++nloops == SOCKNAL_RESCHED) { /* hogging CPU? */
+		if (!did_something ||	/* nothing to do */
+		    need_resched()) {	/* hogging CPU? */
 			spin_unlock_bh(&sched->kss_lock);
 
-			nloops = 0;
-
 			if (!did_something) {   /* wait for something to do */
 				rc = wait_event_interruptible_exclusive(
 					sched->kss_waitq,
@@ -2080,7 +2077,6 @@ void ksocknal_write_callback(struct ksock_conn *conn)
 	spinlock_t *connd_lock = &ksocknal_data.ksnd_connd_lock;
 	struct ksock_connreq *cr;
 	wait_queue_entry_t wait;
-	int nloops = 0;
 	int cons_retry = 0;
 
 	init_waitqueue_entry(&wait, current);
@@ -2158,10 +2154,9 @@ void ksocknal_write_callback(struct ksock_conn *conn)
 		}
 
 		if (dropped_lock) {
-			if (++nloops < SOCKNAL_RESCHED)
+			if (!need_resched())
 				continue;
 			spin_unlock_bh(connd_lock);
-			nloops = 0;
 			cond_resched();
 			spin_lock_bh(connd_lock);
 			continue;
@@ -2173,7 +2168,6 @@ void ksocknal_write_callback(struct ksock_conn *conn)
 					 &wait);
 		spin_unlock_bh(connd_lock);
 
-		nloops = 0;
 		schedule_timeout(timeout);
 
 		remove_wait_queue(&ksocknal_data.ksnd_connd_waitq, &wait);
-- 
1.8.3.1
