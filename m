From: James Simmons <jsimmons@infradead.org>
Date: Wed, 15 Jul 2020 16:45:17 -0400
Subject: [lustre-devel] [PATCH 36/37] lnet: socklnd: change ksnd_nthreads to
 atomic_t
In-Reply-To: <1594845918-29027-1-git-send-email-jsimmons@infradead.org>
References: <1594845918-29027-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1594845918-29027-37-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mr NeilBrown <neilb@suse.de>

This variable is treated like an atomic_t, but a global spinlock is
used to protect updates - and also unnecessarily to protect reads.

Change to atomic_t and avoid using the spinlock.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12678
Lustre-commit: 4b0d3c0e41201 ("LU-12678 socklnd: change ksnd_nthreads to atomic_t")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/39121
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Chris Horn <chris.horn@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/klnds/socklnd/socklnd.c    | 4 ++--
 net/lnet/klnds/socklnd/socklnd.h    | 2 +-
 net/lnet/klnds/socklnd/socklnd_cb.c | 8 ++------
 3 files changed, 5 insertions(+), 9 deletions(-)

diff --git a/net/lnet/klnds/socklnd/socklnd.c b/net/lnet/klnds/socklnd/socklnd.c
index 22a73c3..91925475 100644
--- a/net/lnet/klnds/socklnd/socklnd.c
+++ b/net/lnet/klnds/socklnd/socklnd.c
@@ -2260,9 +2260,9 @@ static int ksocknal_push(struct lnet_ni *ni, struct lnet_process_id id)
 		}
 
 		wait_var_event_warning(&ksocknal_data.ksnd_nthreads,
-				       ksocknal_data.ksnd_nthreads == 0,
+				       atomic_read(&ksocknal_data.ksnd_nthreads) == 0,
 				       "waiting for %d threads to terminate\n",
-				       ksocknal_data.ksnd_nthreads);
+				       atomic_read(&ksocknal_data.ksnd_nthreads));
 
 		ksocknal_free_buffers();
 
diff --git a/net/lnet/klnds/socklnd/socklnd.h b/net/lnet/klnds/socklnd/socklnd.h
index df863f2..350f2c8 100644
--- a/net/lnet/klnds/socklnd/socklnd.h
+++ b/net/lnet/klnds/socklnd/socklnd.h
@@ -196,7 +196,7 @@ struct ksock_nal_data {
 							 * known peers
 							 */
 
-	int			ksnd_nthreads;		/* # live threads */
+	atomic_t		ksnd_nthreads;		/* # live threads */
 	int			ksnd_shuttingdown;	/* tell threads to exit
 							 */
 	struct ksock_sched	**ksnd_schedulers;	/* schedulers info */
diff --git a/net/lnet/klnds/socklnd/socklnd_cb.c b/net/lnet/klnds/socklnd/socklnd_cb.c
index 9b3b604..a1c0c3d 100644
--- a/net/lnet/klnds/socklnd/socklnd_cb.c
+++ b/net/lnet/klnds/socklnd/socklnd_cb.c
@@ -976,19 +976,15 @@ struct ksock_route *
 	if (IS_ERR(task))
 		return PTR_ERR(task);
 
-	write_lock_bh(&ksocknal_data.ksnd_global_lock);
-	ksocknal_data.ksnd_nthreads++;
-	write_unlock_bh(&ksocknal_data.ksnd_global_lock);
+	atomic_inc(&ksocknal_data.ksnd_nthreads);
 	return 0;
 }
 
 void
 ksocknal_thread_fini(void)
 {
-	write_lock_bh(&ksocknal_data.ksnd_global_lock);
-	if (--ksocknal_data.ksnd_nthreads == 0)
+	if (atomic_dec_and_test(&ksocknal_data.ksnd_nthreads))
 		wake_up_var(&ksocknal_data.ksnd_nthreads);
-	write_unlock_bh(&ksocknal_data.ksnd_global_lock);
 }
 
 int
-- 
1.8.3.1
