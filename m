From: James Simmons <jsimmons@infradead.org>
Date: Mon, 17 Sep 2018 13:30:16 -0400
Subject: [lustre-devel] [PATCH 06/30] lustre: ptlrpc: Prevent possible
 dereference of NULL pointers
In-Reply-To: <1537205440-6656-1-git-send-email-jsimmons@infradead.org>
References: <1537205440-6656-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1537205440-6656-7-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Steve Guminski <stephenx.guminski@intel.com>

Check pointers for NULL before passing to other functions.

Signed-off-by: Steve Guminski <stephenx.guminski@intel.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-9076
Reviewed-on: https://review.whamcloud.com/25909
Reviewed-by: John L. Hammond <jhammond@whamcloud.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/ptlrpc/client.c | 14 ++++++++------
 1 file changed, 8 insertions(+), 6 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ptlrpc/client.c b/drivers/staging/lustre/lustre/ptlrpc/client.c
index 4bf26a4..eddb920 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/client.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/client.c
@@ -1978,12 +1978,14 @@ int ptlrpc_check_set(const struct lu_env *env, struct ptlrpc_request_set *set)
 		}
 		ptlrpc_rqphase_move(req, RQ_PHASE_COMPLETE);
 
-		CDEBUG(req->rq_reqmsg ? D_RPCTRACE : 0,
-		       "Completed RPC pname:cluuid:pid:xid:nid:opc %s:%s:%d:%llu:%s:%d\n",
-		       current->comm, imp->imp_obd->obd_uuid.uuid,
-		       lustre_msg_get_status(req->rq_reqmsg), req->rq_xid,
-		       libcfs_nid2str(imp->imp_connection->c_peer.nid),
-		       lustre_msg_get_opc(req->rq_reqmsg));
+		if (req->rq_reqmsg)
+			CDEBUG(D_RPCTRACE,
+			       "Completed RPC pname:cluuid:pid:xid:nid:opc %s:%s:%d:%llu:%s:%d\n",
+			       current->comm, imp->imp_obd->obd_uuid.uuid,
+			       lustre_msg_get_status(req->rq_reqmsg),
+			       req->rq_xid,
+			       libcfs_nid2str(imp->imp_connection->c_peer.nid),
+			       lustre_msg_get_opc(req->rq_reqmsg));
 
 		spin_lock(&imp->imp_lock);
 		/*
-- 
1.8.3.1
