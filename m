From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:16:11 -0500
Subject: [lustre-devel] [PATCH 503/622] lustre: ptlrpc: fix watchdog
 ratelimit logic
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-504-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Andreas Dilger <adilger@whamcloud.com>

The ptlrpc-level watchdog ratelimiting is broken. The kernel prints:

    mdt00_009: service thread pid 18935 was inactive for 72s.
    Watchdog stack traces are limited to 3 per 300s, skipping...

even though there hasn't been any stack trace printed before.

It looks like the __ratelimit() return value is backward from
what one would expect from normal English grammar, namely that
if __ratelimit() returns true the action should NOT be limited.

Fix the logic checking the __ratelimit() return value, and add a
check in sanity test_422 (which forces a service thread timeout)
to ensure that the watchdog sometimes prints a full stack.

Fixes: aeaf46886c7b ("lustre: ptlrpc: add watchdog for ptlrpc service threads")
WC-bug-id: https://jira.whamcloud.com/browse/LU-12838
Lustre-commit: 594c79f2f855 ("LU-12838 ptlrpc: fix watchdog ratelimit logic")
Signed-off-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/36409
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Neil Brown <neilb@suse.de>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ptlrpc/service.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/lustre/ptlrpc/service.c b/fs/lustre/ptlrpc/service.c
index b2a33a3..fe0e108 100644
--- a/fs/lustre/ptlrpc/service.c
+++ b/fs/lustre/ptlrpc/service.c
@@ -2067,7 +2067,8 @@ static void ptlrpc_watchdog_fire(struct work_struct *w)
 	s64 ms_lapse = ktime_ms_delta(ktime_get(), thread->t_touched);
 	u32 ms_frac = do_div(ms_lapse, MSEC_PER_SEC);
 
-	if (!__ratelimit(&watchdog_limit)) {
+	/* ___ratelimit() returns true if the action is NOT ratelimited */
+	if (__ratelimit(&watchdog_limit)) {
 		/* below message is checked in sanity-quota.sh test_6,18 */
 		LCONSOLE_WARN("%s: service thread pid %u was inactive for %llu.%.03u seconds. The thread might be hung, or it might only be slow and will resume later. Dumping the stack trace for debugging purposes:\n",
 			      thread->t_task->comm, thread->t_task->pid,
-- 
1.8.3.1
