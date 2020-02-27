From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:13:54 -0500
Subject: [lustre-devel] [PATCH 366/622] lustre: ldlm: layout lock fixes
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-367-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Vitaly Fertman <c17818@cray.com>

as the intent_layout operation becomes more frequent with SEL,
cancel existent layout locks in advance and reuse ELC to deliver
cancels to MDS

as clients are given LCK_EX layout locks, take into account this
mode as well in ldlm_lock_match

Cray-bug-id: LUS-2528
WC-bug-id: https://jira.whamcloud.com/browse/LU-10070
Lustre-commit: 51f23ffa4dae ("LU-10070 ldlm: layout lock fixes")
Signed-off-by: Vitaly Fertman <c17818@cray.com>
Reviewed-on: https://review.whamcloud.com/35232
Reviewed-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-by: Mike Pershin <mpershin@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/file.c    |  3 ++-
 fs/lustre/mdc/mdc_locks.c | 12 ++++++++++--
 2 files changed, 12 insertions(+), 3 deletions(-)

diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index a27c06c..9321b84 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -4978,7 +4978,8 @@ int ll_layout_refresh(struct inode *inode, u32 *gen)
 		 * match it before grabbing layout lock mutex.
 		 */
 		mode = ll_take_md_lock(inode, MDS_INODELOCK_LAYOUT, &lockh, 0,
-				       LCK_CR | LCK_CW | LCK_PR | LCK_PW);
+				       LCK_CR | LCK_CW | LCK_PR |
+				       LCK_PW | LCK_EX);
 		if (mode != 0) { /* hit cached lock */
 			rc = ll_layout_lock_set(&lockh, mode, inode);
 			if (rc == -EAGAIN)
diff --git a/fs/lustre/mdc/mdc_locks.c b/fs/lustre/mdc/mdc_locks.c
index cf6bc9d..5885bbd 100644
--- a/fs/lustre/mdc/mdc_locks.c
+++ b/fs/lustre/mdc/mdc_locks.c
@@ -580,18 +580,26 @@ static struct ptlrpc_request *mdc_intent_layout_pack(struct obd_export *exp,
 						     struct md_op_data *op_data)
 {
 	struct obd_device *obd = class_exp2obd(exp);
+	struct list_head cancels = LIST_HEAD_INIT(cancels);
 	struct ptlrpc_request *req;
 	struct ldlm_intent *lit;
 	struct layout_intent *layout;
-	int rc;
+	int count = 0, rc;
 
 	req = ptlrpc_request_alloc(class_exp2cliimp(exp),
 				   &RQF_LDLM_INTENT_LAYOUT);
 	if (!req)
 		return ERR_PTR(-ENOMEM);
 
+	if (fid_is_sane(&op_data->op_fid2) && (it->it_op & IT_LAYOUT) &&
+	    (it->it_flags & FMODE_WRITE)) {
+		count = mdc_resource_get_unused(exp, &op_data->op_fid2,
+						&cancels, LCK_EX,
+						MDS_INODELOCK_LAYOUT);
+	}
+
 	req_capsule_set_size(&req->rq_pill, &RMF_EADATA, RCL_CLIENT, 0);
-	rc = ldlm_prep_enqueue_req(exp, req, NULL, 0);
+	rc = ldlm_prep_enqueue_req(exp, req, &cancels, count);
 	if (rc) {
 		ptlrpc_request_free(req);
 		return ERR_PTR(rc);
-- 
1.8.3.1
