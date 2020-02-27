From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:16:56 -0500
Subject: [lustre-devel] [PATCH 548/622] lustre: ptlrpc: always reset
 generation for idle reconnect
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-549-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Wang Shilong <wshilong@ddn.com>

Idle reconnetion is common case and reconnections will
be quick mostly, so always reset generation for this case,
otherwise, it will make application fail just for Idle
reconnection feature.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12378
Lustre-commit: 94fbe511ba96 ("LU-12378 ptlrpc: always reset generation for idle reconnect")
Signed-off-by: Wang Shilong <wshilong@ddn.com>
Reviewed-on: https://review.whamcloud.com/35052
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Alex Zhuravlev <bzzz@whamcloud.com>
Reviewed-by: Li Xi <lixi@ddn.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ptlrpc/import.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/lustre/ptlrpc/import.c b/fs/lustre/ptlrpc/import.c
index 813d3c8..028dd65 100644
--- a/fs/lustre/ptlrpc/import.c
+++ b/fs/lustre/ptlrpc/import.c
@@ -1674,7 +1674,8 @@ static void ptlrpc_reset_reqs_generation(struct obd_import *imp)
 			rq_list) {
 		spin_lock(&old->rq_lock);
 		if (old->rq_import_generation == imp->imp_generation - 1 &&
-		    !old->rq_no_resend)
+		    ((imp->imp_initiated_at == imp->imp_generation) ||
+		     !old->rq_no_resend))
 			old->rq_import_generation = imp->imp_generation;
 		spin_unlock(&old->rq_lock);
 	}
-- 
1.8.3.1
