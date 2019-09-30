From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Sep 2019 14:54:34 -0400
Subject: [lustre-devel] [PATCH 015/151] lustre: ldlm: Don't check opcode
 with NULL rq_reqmsg
In-Reply-To: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1569869810-23848-16-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Jeremy Filizetti <jeremy.filizetti@gmail.com>

When GSS is enabled it's possible to have a NULL rq_reqmsg
if a bad signature or no context is returned during the unwrap
of the request.  Don't check the opcode in this case.

WC-bug-id: https://jira.whamcloud.com/browse/LU-7508
Lustre-commit: 3f4572caef5f ("LU-7508 ldlm: Don't check opcode with NULL rq_reqmsg")
Signed-off-by: Jeremy Filizetti <jeremy.filizetti@gmail.com>
Reviewed-on: http://review.whamcloud.com/17414
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Sebastien Buisson <sbuisson@ddn.com>
Reviewed-by: John L. Hammond <jhammond@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ldlm/ldlm_lib.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/fs/lustre/ldlm/ldlm_lib.c b/fs/lustre/ldlm/ldlm_lib.c
index a3b8df4..04982b8 100644
--- a/fs/lustre/ldlm/ldlm_lib.c
+++ b/fs/lustre/ldlm/ldlm_lib.c
@@ -689,8 +689,12 @@ int target_pack_pool_reply(struct ptlrpc_request *req)
 		DEBUG_REQ(D_ERROR, req, "dropping reply");
 		return -ECOMM;
 	}
-	if (unlikely(lustre_msg_get_opc(req->rq_reqmsg) == MDS_REINT &&
-		     OBD_FAIL_CHECK(OBD_FAIL_MDS_REINT_MULTI_NET_REP)))
+	/* We can have a null rq_reqmsg in the event of bad signature or
+	 * no context when unwrapping
+	 */
+	if (req->rq_reqmsg &&
+	    unlikely(lustre_msg_get_opc(req->rq_reqmsg) == MDS_REINT &&
+	    OBD_FAIL_CHECK(OBD_FAIL_MDS_REINT_MULTI_NET_REP)))
 		return -ECOMM;
 
 	if (unlikely(rc)) {
-- 
1.8.3.1
