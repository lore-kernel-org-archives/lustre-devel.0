From: NeilBrown <neilb@suse.com>
Date: Tue, 13 Feb 2018 08:22:36 +1100
Subject: [lustre-devel] [PATCH 02/19] staging: lustre: discard SVC_SIGNAL
 and related functions
In-Reply-To: <151847037709.22826.16175867257667686132.stgit@noble>
References: <151847037709.22826.16175867257667686132.stgit@noble>
Message-ID: <151847055648.22826.5480938397433602648.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: lkml <linux-kernel@vger.kernel.org>, lustre <lustre-devel@lists.lustre.org>

This flag is never set, so remove checks and remove
the flag.

Reviewed-by: James Simmons <jsimmons@infradead.org>
Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/include/lustre_net.h |    6 ------
 drivers/staging/lustre/lustre/ptlrpc/sec_gc.c      |    4 +---
 2 files changed, 1 insertion(+), 9 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_net.h b/drivers/staging/lustre/lustre/include/lustre_net.h
index 3ff5de4770e8..4c665eca2467 100644
--- a/drivers/staging/lustre/lustre/include/lustre_net.h
+++ b/drivers/staging/lustre/lustre/include/lustre_net.h
@@ -1260,7 +1260,6 @@ enum {
 	SVC_STARTING    = 1 << 2,
 	SVC_RUNNING     = 1 << 3,
 	SVC_EVENT       = 1 << 4,
-	SVC_SIGNAL      = 1 << 5,
 };
 
 #define PTLRPC_THR_NAME_LEN		32
@@ -1333,11 +1332,6 @@ static inline int thread_is_event(struct ptlrpc_thread *thread)
 	return !!(thread->t_flags & SVC_EVENT);
 }
 
-static inline int thread_is_signal(struct ptlrpc_thread *thread)
-{
-	return !!(thread->t_flags & SVC_SIGNAL);
-}
-
 static inline void thread_clear_flags(struct ptlrpc_thread *thread, __u32 flags)
 {
 	thread->t_flags &= ~flags;
diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec_gc.c b/drivers/staging/lustre/lustre/ptlrpc/sec_gc.c
index 8d1e0edfcede..d85c8638c009 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/sec_gc.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/sec_gc.c
@@ -153,7 +153,6 @@ static int sec_gc_main(void *arg)
 	while (1) {
 		struct ptlrpc_sec *sec;
 
-		thread_clear_flags(thread, SVC_SIGNAL);
 		sec_process_ctx_list();
 again:
 		/* go through sec list do gc.
@@ -184,8 +183,7 @@ static int sec_gc_main(void *arg)
 		lwi = LWI_TIMEOUT(msecs_to_jiffies(SEC_GC_INTERVAL * MSEC_PER_SEC),
 				  NULL, NULL);
 		l_wait_event(thread->t_ctl_waitq,
-			     thread_is_stopping(thread) ||
-			     thread_is_signal(thread),
+			     thread_is_stopping(thread),
 			     &lwi);
 
 		if (thread_test_and_clear_flags(thread, SVC_STOPPING))
