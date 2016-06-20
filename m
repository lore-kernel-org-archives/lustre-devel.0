From: Oleg Drokin <green@linuxhacker.ru>
Date: Mon, 20 Jun 2016 16:55:51 -0400
Subject: [lustre-devel] [PATCH v2 28/29] staging/lustre/libcfs: Do not call
	kthread_run in wrong state
In-Reply-To: <1466456152-2199975-1-git-send-email-green@linuxhacker.ru>
References: <1466456152-2199975-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1466456152-2199975-29-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

kthread_run might sleep during an allocation, and so
it's considered unsafe to call with a state that's not
RUNNABLE.
Move the state setting to after kthread_run call.

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lnet/libcfs/debug.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lnet/libcfs/debug.c b/drivers/staging/lustre/lnet/libcfs/debug.c
index 75a2a42..42b15a7 100644
--- a/drivers/staging/lustre/lnet/libcfs/debug.c
+++ b/drivers/staging/lustre/lnet/libcfs/debug.c
@@ -362,12 +362,12 @@ void libcfs_debug_dumplog(void)
 	 * get to schedule()
 	 */
 	init_waitqueue_entry(&wait, current);
-	set_current_state(TASK_INTERRUPTIBLE);
 	add_wait_queue(&debug_ctlwq, &wait);
 
 	dumper = kthread_run(libcfs_debug_dumplog_thread,
 			     (void *)(long)current_pid(),
 			     "libcfs_debug_dumper");
+	set_current_state(TASK_INTERRUPTIBLE);
 	if (IS_ERR(dumper))
 		pr_err("LustreError: cannot start log dump thread: %ld\n",
 		       PTR_ERR(dumper));
-- 
2.7.4
