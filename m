From: James Simmons <jsimmons@infradead.org>
Date: Sat, 28 Jan 2017 19:04:35 -0500
Subject: [lustre-devel] [PATCH 07/60] staging: lustre: ptlrpc: set proper
	mbits for EINPROGRESS resend
In-Reply-To: <1485648328-2141-1-git-send-email-jsimmons@infradead.org>
References: <1485648328-2141-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1485648328-2141-8-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Niu Yawei <yawei.niu@intel.com>, James Simmons <jsimmons@infradead.org>

From: Niu Yawei <yawei.niu@intel.com>

Set mbits for EINPROGRESS resend in ptl_send_rpc().

Signed-off-by: Niu Yawei <yawei.niu@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-8193
Reviewed-on: http://review.whamcloud.com/20377
Reviewed-by: Liang Zhen <liang.zhen@intel.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/ptlrpc/client.c | 7 +++++--
 drivers/staging/lustre/lustre/ptlrpc/niobuf.c | 5 +++--
 2 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ptlrpc/client.c b/drivers/staging/lustre/lustre/ptlrpc/client.c
index 8047413..3c18ab6 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/client.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/client.c
@@ -3123,8 +3123,11 @@ void ptlrpc_set_bulk_mbits(struct ptlrpc_request *req)
 			req->rq_mbits = ptlrpc_next_xid();
 		} else {
 			/* old version transfers rq_xid to peer as matchbits */
-			req->rq_mbits = ptlrpc_next_xid();
-			req->rq_xid = req->rq_mbits;
+			spin_lock(&req->rq_import->imp_lock);
+			list_del_init(&req->rq_unreplied_list);
+			ptlrpc_assign_next_xid_nolock(req);
+			req->rq_mbits = req->rq_xid;
+			spin_unlock(&req->rq_import->imp_lock);
 		}
 
 		CDEBUG(D_HA, "resend bulk old x%llu new x%llu\n",
diff --git a/drivers/staging/lustre/lustre/ptlrpc/niobuf.c b/drivers/staging/lustre/lustre/ptlrpc/niobuf.c
index da1209e..b870184 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/niobuf.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/niobuf.c
@@ -522,13 +522,14 @@ int ptl_send_rpc(struct ptlrpc_request *request, int noreply)
 		 */
 		spin_lock(&imp->imp_lock);
 		ptlrpc_assign_next_xid_nolock(request);
-		request->rq_mbits = request->rq_xid;
 		min_xid = ptlrpc_known_replied_xid(imp);
 		spin_unlock(&imp->imp_lock);
 
 		lustre_msg_set_last_xid(request->rq_reqmsg, min_xid);
 		DEBUG_REQ(D_RPCTRACE, request, "Allocating new xid for resend on EINPROGRESS");
-	} else if (request->rq_bulk) {
+	}
+
+	if (request->rq_bulk) {
 		ptlrpc_set_bulk_mbits(request);
 		lustre_msg_set_mbits(request->rq_reqmsg, request->rq_mbits);
 	}
-- 
1.8.3.1
