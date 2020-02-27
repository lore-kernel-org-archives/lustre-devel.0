From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:18:05 -0500
Subject: [lustre-devel] [PATCH 617/622] lustre: ptlrpc: use
 l_wait_event_abortable in ptlrpcd_add_reg()
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-618-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mr NeilBrown <neilb@suse.com>

Using wait_event_idle() will ignore signals which is not what we
want in ptlrpcd_add_req(). Change it to l_wait_event_abortable().

WC-bug-id: https://jira.whamcloud.com/browse/LU-10467
Lustre-commit: ca6c35cab141 ("LU-10467 lustre: convert users of back_to_sleep()")
Signed-off-by: Mr NeilBrown <neilb@suse.com>
Reviewed-on: https://review.whamcloud.com/35980
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Petros Koutoupis <pkoutoupis@cray.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ptlrpc/ptlrpcd.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/lustre/ptlrpc/ptlrpcd.c b/fs/lustre/ptlrpc/ptlrpcd.c
index 1a1fa05..533f592 100644
--- a/fs/lustre/ptlrpc/ptlrpcd.c
+++ b/fs/lustre/ptlrpc/ptlrpcd.c
@@ -235,8 +235,8 @@ void ptlrpcd_add_req(struct ptlrpc_request *req)
 		if (wait_event_idle_timeout(req->rq_set_waitq,
 					    !req->rq_set,
 					    5 * HZ) == 0)
-			wait_event_idle(req->rq_set_waitq,
-					!req->rq_set);
+			l_wait_event_abortable(req->rq_set_waitq,
+					       !req->rq_set);
 	} else if (req->rq_set) {
 		/*
 		 * If we have a valid "rq_set", just reuse it to avoid double
-- 
1.8.3.1
