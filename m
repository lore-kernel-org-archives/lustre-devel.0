From: James Simmons <jsimmons@infradead.org>
Date: Wed, 15 Jul 2020 16:44:53 -0400
Subject: [lustre-devel] [PATCH 12/37] lustre: ptlrpc: re-enterable
 signal_completed_replay()
In-Reply-To: <1594845918-29027-1-git-send-email-jsimmons@infradead.org>
References: <1594845918-29027-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1594845918-29027-13-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mikhail Pershin <mpershin@whamcloud.com>

The signal_completed_replay() can meet race conditions while
checking imp_replay_inflight counter, so remove assertion and
check race conditions instead.

Fixes: 8cc7f22847 ("lustre: ptlrpc: limit rate of lock replays")
WC-bug-id: https://jira.whamcloud.com/browse/LU-13600
Lustre-commit: 24451f3790503 ("LU-13600 ptlrpc: re-enterable signal_completed_replay()")
Signed-off-by: Mikhail Pershin <mpershin@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/39140
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Hongchao Zhang <hongchao@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ptlrpc/import.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/lustre/ptlrpc/import.c b/fs/lustre/ptlrpc/import.c
index 7ec3638..1b62b81 100644
--- a/fs/lustre/ptlrpc/import.c
+++ b/fs/lustre/ptlrpc/import.c
@@ -1407,8 +1407,8 @@ static int signal_completed_replay(struct obd_import *imp)
 	if (unlikely(OBD_FAIL_CHECK(OBD_FAIL_PTLRPC_FINISH_REPLAY)))
 		return 0;
 
-	LASSERT(atomic_read(&imp->imp_replay_inflight) == 0);
-	atomic_inc(&imp->imp_replay_inflight);
+	if (!atomic_add_unless(&imp->imp_replay_inflight, 1, 1))
+		return 0;
 
 	req = ptlrpc_request_alloc_pack(imp, &RQF_OBD_PING, LUSTRE_OBD_VERSION,
 					OBD_PING);
-- 
1.8.3.1
