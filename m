From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:07:50 -0500
Subject: [lustre-devel] [PATCH 002/622] lustre: osc_cache: remove
 __might_sleep()
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-3-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

The patch 'simplify osc_wake_cache_waiters()' created a new
wrapper wait_event_idle_exclusive_timeout_cmd() which includes
a __might_sleep() test. This was causing the following back
trace:

kernel: BUG: sleeping function called from invalid context at fs/lustre/osc/osc_cache.c:1635
kernel: in_atomic(): 1, irqs_disabled(): 0, non_block: 0, pid: 19374, name: cp
kernel: INFO: lockdep is turned off.
kernel: Preemption disabled at:
kernel: [<0000000000000000>] 0x0
kernel: CPU: 11 PID: 19374 Comm: cp Tainted: G        W         5.4.0-rc5+ #1
kernel: Call Trace:
kernel: dump_stack+0x5e/0x8b
kernel: ___might_sleep+0x205/0x260
kernel: osc_queue_async_io+0x1104/0x1de0 [osc]
kernel: ? _raw_spin_unlock+0x2e/0x50
kernel: ? libcfs_debug_msg+0x6ab/0xc80 [libcfs]
kernel: ? vvp_io_setattr_start+0x200/0x200 [lustre]
kernel: osc_page_cache_add+0x2c/0xa0 [osc]
kernel: osc_io_commit_async+0x1a8/0x420 [osc]
kernel: cl_io_commit_async+0x58/0x80 [obdclass]
kernel: ? vvp_io_setattr_start+0x200/0x200 [lustre:1

This can be called from an atomic context and examing the code
suggest we don't need __might_sleep() so lets remove it.

Fixes: def8e96d4f3d ("lustre: osc_cache: simplify osc_wake_cache_waiters()")

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/osc/osc_cache.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/fs/lustre/osc/osc_cache.c b/fs/lustre/osc/osc_cache.c
index 3189eb3..2ed7ca2 100644
--- a/fs/lustre/osc/osc_cache.c
+++ b/fs/lustre/osc/osc_cache.c
@@ -1570,7 +1570,6 @@ static bool osc_enter_cache_try(struct client_obd *cli,
 					      cmd1, cmd2)		\
 ({									\
 	long __ret = timeout;						\
-	might_sleep();							\
 	if (!___wait_cond_timeout(condition))				\
 		__ret = __wait_event_idle_exclusive_timeout_cmd(	\
 			wq_head, condition, timeout, cmd1, cmd2);	\
-- 
1.8.3.1
