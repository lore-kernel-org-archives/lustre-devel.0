From: James Simmons <jsimmons@infradead.org>
Date: Thu,  4 Aug 2016 12:53:03 -0400
Subject: [lustre-devel] [PATCH 27/31] staging: lustre: ptlrpc: request gets
	stuck in UNREGISTERING phase
In-Reply-To: <1470329587-18768-1-git-send-email-jsimmons@infradead.org>
References: <1470329587-18768-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1470329587-18768-28-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Andriy Skulysh <Andriy_Skulysh@xyratex.com>, James Simmons <jsimmons@infradead.org>

From: Andriy Skulysh <Andriy_Skulysh@xyratex.com>

Exit condition from UNREGISTERING phase is releasing of
both reply and bulk buffers.

Call ptlrpc_unregister_bulk() if ptlrpc_unregister_reply()
wasn't completed in async mode before switching to
UNREGISTERING phase.

Signed-off-by: Andriy Skulysh <Andriy_Skulysh@xyratex.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5259
Xyratex-bug-id: MRP-1960
Reviewed-on: http://review.whamcloud.com/10846
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Ann Koehler <amk@cray.com>
Reviewed-by: Liang Zhen <liang.zhen@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/ptlrpc/client.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ptlrpc/client.c b/drivers/staging/lustre/lustre/ptlrpc/client.c
index ddb08ea..1ddc408 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/client.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/client.c
@@ -1630,8 +1630,10 @@ int ptlrpc_check_set(const struct lu_env *env, struct ptlrpc_request_set *set)
 			    req->rq_waiting || req->rq_wait_ctx) {
 				int status;
 
-				if (!ptlrpc_unregister_reply(req, 1))
+				if (!ptlrpc_unregister_reply(req, 1)) {
+					ptlrpc_unregister_bulk(req, 1);
 					continue;
+				}
 
 				spin_lock(&imp->imp_lock);
 				if (ptlrpc_import_delay_req(imp, req,
-- 
1.7.1
