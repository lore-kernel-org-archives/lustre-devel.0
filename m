From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:09:41 -0500
Subject: [lustre-devel] [PATCH 113/622] lustre: ptlrpc: race in AT early
 reply
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-114-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Hongchao Zhang <hongchao@whamcloud.com>

In ptlrpc_at_check_timed, the refcount of the request could
be already dropped to zero, the ptlrpc_server_drop_request
could continue without the "scp_at_lock" and free the request
by writing 0x5a5a5a5a5a5a5a5a to the memory, but the following
"atomic_inc_not_zero(&rq->rq_refcount)" will return nonzero and
cause freed request to be used in ptlrpc_at_send_early_reply.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11281
Lustre-commit: 48e409e65edd ("LU-11281 ptlrpc: race in AT early reply")
Signed-off-by: Hongchao Zhang <hongchao@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/33071
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Lai Siyao <lai.siyao@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ptlrpc/service.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/fs/lustre/ptlrpc/service.c b/fs/lustre/ptlrpc/service.c
index cf920ae..a9155b2 100644
--- a/fs/lustre/ptlrpc/service.c
+++ b/fs/lustre/ptlrpc/service.c
@@ -1224,14 +1224,18 @@ static void ptlrpc_at_check_timed(struct ptlrpc_service_part *svcpt)
 				break;
 			}
 
-			ptlrpc_at_remove_timed(rq);
 			/**
 			 * ptlrpc_server_drop_request() may drop
 			 * refcount to 0 already. Let's check this and
 			 * don't add entry to work_list
 			 */
-			if (likely(atomic_inc_not_zero(&rq->rq_refcount)))
+			if (likely(atomic_inc_not_zero(&rq->rq_refcount))) {
+				ptlrpc_at_remove_timed(rq);
 				list_add(&rq->rq_timed_list, &work_list);
+			} else {
+				ptlrpc_at_remove_timed(rq);
+			}
+
 			counter++;
 		}
 
-- 
1.8.3.1
