From: James Simmons <jsimmons@infradead.org>
Date: Wed, 26 Jul 2017 11:22:25 -0400
Subject: [lustre-devel] [PATCH 09/20] staging: lustre: ptlrpc: no need to
	reassign mbits for replay
In-Reply-To: <1501082556-17962-1-git-send-email-jsimmons@infradead.org>
References: <1501082556-17962-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1501082556-17962-10-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Niu Yawei <yawei.niu@intel.com>, James Simmons <jsimmons@infradead.org>

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
Reviewed-by: Fan Yong <fan.yong@intel.com>
Reviewed-by: Alex Zhuravlev <alexey.zhuravlev@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/ptlrpc/client.c | 28 +++++++++++++++++++++------
 1 file changed, 22 insertions(+), 6 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ptlrpc/client.c b/drivers/staging/lustre/lustre/ptlrpc/client.c
index 1c77792..1247686 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/client.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/client.c
@@ -3116,13 +3116,20 @@ void ptlrpc_set_bulk_mbits(struct ptlrpc_request *req)
 
 	LASSERT(bd);
 
-	if (!req->rq_resend) {
-		/* this request has a new xid, just use it as bulk matchbits */
-		req->rq_mbits = req->rq_xid;
-
-	} else { /* needs to generate a new matchbits for resend */
+	/*
+	 * Generate new matchbits for all resend requests, including
+	 * resend replay.
+	 */
+	if (req->rq_resend) {
 		u64 old_mbits = req->rq_mbits;
 
+		/*
+		 * First time resend on -EINPROGRESS will generate new xid,
+		 * so we can actually use the rq_xid as rq_mbits in such case,
+		 * however, it's bit hard to distinguish such resend with a
+		 * 'resend for the -EINPROGRESS resend'. To make it simple,
+		 * we opt to generate mbits for all resend cases.
+		 */
 		if ((bd->bd_import->imp_connect_data.ocd_connect_flags &
 		     OBD_CONNECT_BULK_MBITS)) {
 			req->rq_mbits = ptlrpc_next_xid();
@@ -3131,12 +3138,21 @@ void ptlrpc_set_bulk_mbits(struct ptlrpc_request *req)
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
+		/*
+		 * Replay request, xid and matchbits have already been
+		 * correctly assigned.
+		 */
+		return;
 	}
 
 	/*
-- 
1.8.3.1
