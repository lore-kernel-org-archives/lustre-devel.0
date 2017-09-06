From: Tyson Whitehead <twhitehead@gmail.com>
Date: Wed, 06 Sep 2017 12:05:01 -0400
Subject: [lustre-devel] [PATCH 2/2] LU-6808 ptlrpc: no need to reassign
	mbits for replay
Message-ID: <2356378.V5F8jgOxsl@whitehead.beowulf.uwo.ca>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Niu Yawei <yawei.niu@intel.com>

It's not necessary reassgin & re-adjust rq_mbits for replay
request in ptlrpc_set_bulk_mbits(), they all must have already
been correctly assigned before.

Such unecessary reassign could make the first matchbit not
PTLRPC_BULK_OPS_MASK aligned, that'll trigger LASSERT in
ptlrpc_register_bulk():

- ptlrpc_set_bulk_mbits() is called when first time sending
  request, rq_mbits is set as xid, which is BULK_OPS aligned;

- ptlrpc_set_bulk_mbits() continue to adjust the mbits for
  multi-bulk RPC, rq_mbits is not aligned anymore, then rq_xid
  is changed accordingly if client is connecting to an old
  server, so rq_xid became unaligned too;

- The request is replayed, ptlrpc_set_bulk_mbits() reassign
  the rq_mbits as rq_xid, which isn't aligned already, but
  ptlrpc_register_bulk() still assumes this value as the
  first matchbits and LASSERT it's BULK_OPS aligned.

Signed-off-by: Niu Yawei <yawei.niu@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6808
Reviewed-on: http://review.whamcloud.com/23048
Tested-by: Jenkins
Reviewed-by: Fan Yong <fan.yong@intel.com>
Reviewed-by: Alex Zhuravlev <alexey.zhuravlev@intel.com>
Tested-by: Maloo <hpdd-maloo@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: Tyson Whitehead <twhitehead@gmail.com>
---
 drivers/staging/lustre/lustre/ptlrpc/client.c | 34 +++++++++++++++++++--------
 1 file changed, 24 insertions(+), 10 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ptlrpc/client.c b/drivers/staging/lustre/lustre/ptlrpc/client.c
index 0f9db5526ba5..6ddbd1289a2f 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/client.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/client.c
@@ -3116,26 +3116,37 @@ void ptlrpc_set_bulk_mbits(struct ptlrpc_request *req)
 
 	LASSERT(bd);
 
-	if (!req->rq_resend) {
-		/* this request has a new xid, just use it as bulk matchbits */
-		req->rq_mbits = req->rq_xid;
-
-	} else { /* needs to generate a new matchbits for resend */
-		u64 old_mbits = req->rq_mbits;
-
+	/* Generate new matchbits for all resend requests, including
+	 * resend replay. */
+	if (req->rq_resend) {
+		__u64 old_mbits = req->rq_mbits;
+
+		/* First time resend on -EINPROGRESS will generate new xid,
+		 * so we can actually use the rq_xid as rq_mbits in such case,
+		 * however, it's bit hard to distinguish such resend with a
+		 * 'resend for the -EINPROGRESS resend'. To make it simple,
+		 * we opt to generate mbits for all resend cases. */
 		if (OCD_HAS_FLAG(&bd->bd_import->imp_connect_data, BULK_MBITS)){
 			req->rq_mbits = ptlrpc_next_xid();
 		} else {
-			/* old version transfers rq_xid to peer as matchbits */
+			/* Old version transfers rq_xid to peer as
+			 * matchbits. */
 			spin_lock(&req->rq_import->imp_lock);
 			list_del_init(&req->rq_unreplied_list);
 			ptlrpc_assign_next_xid_nolock(req);
-			req->rq_mbits = req->rq_xid;
 			spin_unlock(&req->rq_import->imp_lock);
+			req->rq_mbits = req->rq_xid;
 		}
 
 		CDEBUG(D_HA, "resend bulk old x%llu new x%llu\n",
 		       old_mbits, req->rq_mbits);
+	} else if (!(lustre_msg_get_flags(req->rq_reqmsg) & MSG_REPLAY)) {
+		/* Request being sent first time, use xid as matchbits. */
+		req->rq_mbits = req->rq_xid;
+	} else {
+		/* Replay request, xid and matchbits have already been
+		 * correctly assigned. */
+		return;
 	}
 
 	/*
@@ -3146,7 +3157,10 @@ void ptlrpc_set_bulk_mbits(struct ptlrpc_request *req)
 	req->rq_mbits += DIV_ROUND_UP(bd->bd_iov_count, LNET_MAX_IOV) - 1;
 
 	/* Set rq_xid as rq_mbits to indicate the final bulk for the old
-	 * server which does not support OBD_CONNECT_BULK_MBITS. LU-6808 */
+	 * server which does not support OBD_CONNECT_BULK_MBITS. LU-6808.
+	 *
+	 * It's ok to directly set the rq_xid here, since this xid bump
+	 * won't affect the request position in unreplied list. */
 	if (!OCD_HAS_FLAG(&bd->bd_import->imp_connect_data, BULK_MBITS))
 		req->rq_xid = req->rq_mbits;
 }
-- 
2.14.0
