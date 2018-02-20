From: NeilBrown <neilb@suse.com>
Date: Tue, 20 Feb 2018 13:23:37 +1100
Subject: [lustre-devel] [PATCH 04/21] staging: lustre: remove unnecessary
 cfs_block_allsigs() calls
In-Reply-To: <151909308778.25814.9912662268627044409.stgit@noble>
References: <151909308778.25814.9912662268627044409.stgit@noble>
Message-ID: <151909341766.25814.10094434408580614776.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, James Simmons <jsimmons@infradead.org>, Andreas Dilger <andreas.dilger@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: lkml <linux-kernel@vger.kernel.org>, lustre <lustre-devel@lists.lustre.org>

Threads started by kthread_run() ignore all signals,
as kthreadd() calls ignore_signals(), and this is
inherited by all children.
So there is no need to call cfs_block_allsigs() in functions
that are only run from kthread_run().

Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c |    6 ------
 .../staging/lustre/lnet/klnds/socklnd/socklnd_cb.c |    6 ------
 drivers/staging/lustre/lnet/lnet/acceptor.c        |    2 --
 drivers/staging/lustre/lnet/lnet/router.c          |    2 --
 drivers/staging/lustre/lnet/selftest/timer.c       |    2 --
 5 files changed, 18 deletions(-)

diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
index ca094555e04b..6690a6cd4e34 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -3288,8 +3288,6 @@ kiblnd_connd(void *arg)
 	int peer_index = 0;
 	unsigned long deadline = jiffies;
 
-	cfs_block_allsigs();
-
 	init_waitqueue_entry(&wait, current);
 	kiblnd_data.kib_connd = current;
 
@@ -3542,8 +3540,6 @@ kiblnd_scheduler(void *arg)
 	int busy_loops = 0;
 	int rc;
 
-	cfs_block_allsigs();
-
 	init_waitqueue_entry(&wait, current);
 
 	sched = kiblnd_data.kib_scheds[KIB_THREAD_CPT(id)];
@@ -3676,8 +3672,6 @@ kiblnd_failover_thread(void *arg)
 
 	LASSERT(*kiblnd_tunables.kib_dev_failover);
 
-	cfs_block_allsigs();
-
 	init_waitqueue_entry(&wait, current);
 	write_lock_irqsave(glock, flags);
 
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
index 63e452f666bf..6ab002c006ab 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
@@ -1324,8 +1324,6 @@ int ksocknal_scheduler(void *arg)
 	info = ksocknal_data.ksnd_sched_info[KSOCK_THREAD_CPT(id)];
 	sched = &info->ksi_scheds[KSOCK_THREAD_SID(id)];
 
-	cfs_block_allsigs();
-
 	rc = cfs_cpt_bind(lnet_cpt_table(), info->ksi_cpt);
 	if (rc) {
 		CWARN("Can't set CPU partition affinity to %d: %d\n",
@@ -2078,8 +2076,6 @@ ksocknal_connd(void *arg)
 	int nloops = 0;
 	int cons_retry = 0;
 
-	cfs_block_allsigs();
-
 	init_waitqueue_entry(&wait, current);
 
 	spin_lock_bh(connd_lock);
@@ -2472,8 +2468,6 @@ ksocknal_reaper(void *arg)
 	int peer_index = 0;
 	unsigned long deadline = cfs_time_current();
 
-	cfs_block_allsigs();
-
 	INIT_LIST_HEAD(&enomem_conns);
 	init_waitqueue_entry(&wait, current);
 
diff --git a/drivers/staging/lustre/lnet/lnet/acceptor.c b/drivers/staging/lustre/lnet/lnet/acceptor.c
index 6c1f4941d4ba..fb478e20e204 100644
--- a/drivers/staging/lustre/lnet/lnet/acceptor.c
+++ b/drivers/staging/lustre/lnet/lnet/acceptor.c
@@ -335,8 +335,6 @@ lnet_acceptor(void *arg)
 
 	LASSERT(!lnet_acceptor_state.pta_sock);
 
-	cfs_block_allsigs();
-
 	rc = lnet_sock_listen(&lnet_acceptor_state.pta_sock, 0, accept_port,
 			      accept_backlog);
 	if (rc) {
diff --git a/drivers/staging/lustre/lnet/lnet/router.c b/drivers/staging/lustre/lnet/lnet/router.c
index ec1d3e58519a..a3c3f4959f46 100644
--- a/drivers/staging/lustre/lnet/lnet/router.c
+++ b/drivers/staging/lustre/lnet/lnet/router.c
@@ -1226,8 +1226,6 @@ lnet_router_checker(void *arg)
 	struct lnet_peer *rtr;
 	struct list_head *entry;
 
-	cfs_block_allsigs();
-
 	while (the_lnet.ln_rc_state == LNET_RC_STATE_RUNNING) {
 		__u64 version;
 		int cpt;
diff --git a/drivers/staging/lustre/lnet/selftest/timer.c b/drivers/staging/lustre/lnet/selftest/timer.c
index 9716afeb3c94..1b2c5fc81358 100644
--- a/drivers/staging/lustre/lnet/selftest/timer.c
+++ b/drivers/staging/lustre/lnet/selftest/timer.c
@@ -170,8 +170,6 @@ stt_timer_main(void *arg)
 {
 	int rc = 0;
 
-	cfs_block_allsigs();
-
 	while (!stt_data.stt_shuttingdown) {
 		stt_check_timers(&stt_data.stt_prev_slot);
 
