From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:12:25 -0500
Subject: [lustre-devel] [PATCH 277/622] lustre: ptlrpc: ASSERTION
 (req_transno < next_transno) failed
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-278-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Andriy Skulysh <c17819@cray.com>

An update request is checked for duplicates by xid in
is_req_replayed_by_update(). However xid is unique per
client only. It may happen that there are 2 requests
with the same xid from different clients.

Perform lookup by transno, it is unique per MDT.

Cray-bug-id: LUS-6015
WC-bug-id: https://jira.whamcloud.com/browse/LU-11251
Lustre-commit: 53764826b95f ("LU-11251 mdt: ASSERTION (req_transno < next_transno) failed")
Signed-off-by: Andriy Skulysh <c17819@cray.com>
Reviewed-by: Vitaly Fertman <c17818@cray.com>
Reviewed-by: Alexander Boyko <c17825@cray.com>
Reviewed-on: https://review.whamcloud.com/33001
Reviewed-by: Alexandr Boyko <c17825@cray.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/obd_support.h |  3 ++-
 fs/lustre/ptlrpc/client.c       | 11 ++++++++---
 2 files changed, 10 insertions(+), 4 deletions(-)

diff --git a/fs/lustre/include/obd_support.h b/fs/lustre/include/obd_support.h
index 4e956da..837b68d 100644
--- a/fs/lustre/include/obd_support.h
+++ b/fs/lustre/include/obd_support.h
@@ -355,7 +355,8 @@
 #define OBD_FAIL_PTLRPC_DROP_BULK			0x51a
 #define OBD_FAIL_PTLRPC_LONG_REQ_UNLINK			0x51b
 #define OBD_FAIL_PTLRPC_LONG_BOTH_UNLINK		0x51c
-#define OBD_FAIL_PTLRPC_BULK_ATTACH      0x521
+#define OBD_FAIL_PTLRPC_BULK_ATTACH			0x521
+#define OBD_FAIL_PTLRPC_ROUND_XID			0x530
 #define OBD_FAIL_PTLRPC_CONNECT_RACE			0x531
 
 #define OBD_FAIL_OBD_PING_NET				0x600
diff --git a/fs/lustre/ptlrpc/client.c b/fs/lustre/ptlrpc/client.c
index 7c243af..ac16878 100644
--- a/fs/lustre/ptlrpc/client.c
+++ b/fs/lustre/ptlrpc/client.c
@@ -712,6 +712,8 @@ static inline void ptlrpc_assign_next_xid(struct ptlrpc_request *req)
 	spin_unlock(&req->rq_import->imp_lock);
 }
 
+static atomic64_t ptlrpc_last_xid;
+
 int ptlrpc_request_bufs_pack(struct ptlrpc_request *request,
 			     u32 version, int opcode, char **bufs,
 			     struct ptlrpc_cli_ctx *ctx)
@@ -761,7 +763,6 @@ int ptlrpc_request_bufs_pack(struct ptlrpc_request *request,
 	ptlrpc_at_set_req_timeout(request);
 
 	lustre_msg_set_opc(request->rq_reqmsg, opcode);
-	ptlrpc_assign_next_xid(request);
 
 	/* Let's setup deadline for req/reply/bulk unlink for opcode. */
 	if (cfs_fail_val == opcode) {
@@ -776,6 +777,11 @@ int ptlrpc_request_bufs_pack(struct ptlrpc_request *request,
 		} else if (CFS_FAIL_CHECK(OBD_FAIL_PTLRPC_LONG_BOTH_UNLINK)) {
 			fail_t = &request->rq_reply_deadline;
 			fail2_t = &request->rq_bulk_deadline;
+		} else if (CFS_FAIL_CHECK(OBD_FAIL_PTLRPC_ROUND_XID)) {
+			time64_t now = ktime_get_real_seconds();
+
+			atomic64_set(&ptlrpc_last_xid,
+				     ((u64)now >> 4) << 24);
 		}
 
 		if (fail_t) {
@@ -791,6 +797,7 @@ int ptlrpc_request_bufs_pack(struct ptlrpc_request *request,
 			msleep(4 * MSEC_PER_SEC);
 		}
 	}
+	ptlrpc_assign_next_xid(request);
 
 	return 0;
 
@@ -3085,8 +3092,6 @@ void ptlrpc_abort_set(struct ptlrpc_request_set *set)
 	}
 }
 
-static atomic64_t ptlrpc_last_xid;
-
 /**
  * Initialize the XID for the node.  This is common among all requests on
  * this node, and only requires the property that it is monotonically
-- 
1.8.3.1
