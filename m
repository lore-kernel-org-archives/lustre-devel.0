From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Oct 2016 18:11:48 -0400
Subject: [lustre-devel] [PATCH 14/29] staging: lustre: ptlrpc: Do not resend
	req with allow_replay
In-Reply-To: <1477606323-30325-1-git-send-email-jsimmons@infradead.org>
References: <1477606323-30325-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1477606323-30325-15-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, wang di <di.wang@intel.com>, James Simmons <jsimmons@infradead.org>

From: wang di <di.wang@intel.com>

If the request is allowed to be sent during recovery,
and it is not timeout yet, then we do not need to
resend it in the final stage of recovery.

Unnecessary resend will cause the bulk request to resend the
request with different mbit, but same xid, and on the remote
server side, it will drop such request with same xid, so it
will never get the bulk in this case.

Signed-off-by: wang di <di.wang@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6780
Reviewed-on: http://review.whamcloud.com/15458
Reviewed-by: Alex Zhuravlev <alexey.zhuravlev@intel.com>
Reviewed-by: Liang Zhen <liang.zhen@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/ptlrpc/recover.c |    8 +++++++-
 1 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ptlrpc/recover.c b/drivers/staging/lustre/lustre/ptlrpc/recover.c
index 405faf0..aa96534 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/recover.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/recover.c
@@ -194,7 +194,13 @@ int ptlrpc_resend(struct obd_import *imp)
 		LASSERTF((long)req > PAGE_SIZE && req != LP_POISON,
 			 "req %p bad\n", req);
 		LASSERTF(req->rq_type != LI_POISON, "req %p freed\n", req);
-		if (!ptlrpc_no_resend(req))
+
+		/*
+		 * If the request is allowed to be sent during replay and it
+		 * is not timeout yet, then it does not need to be resent.
+		 */
+		if (!ptlrpc_no_resend(req) &&
+		    (req->rq_timedout || !req->rq_allow_replay))
 			ptlrpc_resend_req(req);
 	}
 	spin_unlock(&imp->imp_lock);
-- 
1.7.1
