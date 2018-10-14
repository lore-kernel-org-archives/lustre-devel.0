From: James Simmons <jsimmons@infradead.org>
Date: Sun, 14 Oct 2018 14:58:02 -0400
Subject: [lustre-devel] [PATCH 12/28] lustre: ptlrpc: do not wakeup every
 second
In-Reply-To: <1539543498-29105-1-git-send-email-jsimmons@infradead.org>
References: <1539543498-29105-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1539543498-29105-13-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Alex Zhuravlev <bzzz@whamcloud.com>

Even if there are no RPC requests on the set, there is no need to
wake up every second. The thread is woken up when a request is added
to the set or when the STOP bit is set, so it is sufficient to only
wake up when there are requests on the set to worry about.

Signed-off-by: Alex Zhuravlev <bzzz@whamcloud.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-9660
Reviewed-on: https://review.whamcloud.com/28776
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Patrick Farrell <paf@cray.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c b/drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c
index c201a88..5b4977b 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c
@@ -371,7 +371,7 @@ static int ptlrpcd_check(struct lu_env *env, struct ptlrpcd_ctl *pc)
 		}
 	}
 
-	return rc;
+	return rc || test_bit(LIOD_STOP, &pc->pc_flags);
 }
 
 /**
@@ -441,7 +441,7 @@ static int ptlrpcd(void *arg)
 		lu_context_enter(env.le_ses);
 		if (wait_event_idle_timeout(set->set_waitq,
 					    ptlrpcd_check(&env, pc),
-					    (timeout ? timeout : 1) * HZ) == 0)
+					    timeout * HZ) == 0)
 			ptlrpc_expired_set(set);
 
 		lu_context_exit(&env.le_ctx);
-- 
1.8.3.1
