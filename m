From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:10:10 -0500
Subject: [lustre-devel] [PATCH 142/622] lustre: ldlm: check double grant
 race after resource change
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-143-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Li Dongyang <dongyang.li@anu.edu.au>

In ldlm_handle_cp_callback(), we call lock_res_and_lock and then
check if the ldlm lock has already been granted.
If the lock resource has changed, we release the lock and go ahead
allocating new resource, then grabs the lock again before calling
ldlm_grant_lock().
However this gives another thread an opportunity to grab the lock
and pass the check, while we change the resource. Eventually the
other thread calls ldlm_grant_lock() on the same ldlm lock and
triggers a LASSERT.

Fix the issue by doing double grant race check after changing the
lock resource.

WC-bug-id: https://jira.whamcloud.com/browse/LU-8391
Lustre-commit: fef1020406a0 ("LU-8391 ldlm: check double grant race after resource change")
Signed-off-by: Li Dongyang <dongyang.li@anu.edu.au>
Reviewed-on: https://review.whamcloud.com/21275
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Jinshan Xiong <jinshan.xiong@gmail.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ldlm/ldlm_lockd.c | 29 +++++++++++++++--------------
 1 file changed, 15 insertions(+), 14 deletions(-)

diff --git a/fs/lustre/ldlm/ldlm_lockd.c b/fs/lustre/ldlm/ldlm_lockd.c
index 204b11b..6905ee5 100644
--- a/fs/lustre/ldlm/ldlm_lockd.c
+++ b/fs/lustre/ldlm/ldlm_lockd.c
@@ -214,6 +214,21 @@ static void ldlm_handle_cp_callback(struct ptlrpc_request *req,
 	}
 
 	lock_res_and_lock(lock);
+
+	if (!ldlm_res_eq(&dlm_req->lock_desc.l_resource.lr_name,
+			 &lock->l_resource->lr_name)) {
+		ldlm_resource_unlink_lock(lock);
+		unlock_res_and_lock(lock);
+		rc = ldlm_lock_change_resource(ns, lock,
+				&dlm_req->lock_desc.l_resource.lr_name);
+		if (rc < 0) {
+			LDLM_ERROR(lock, "Failed to allocate resource");
+			goto out;
+		}
+		LDLM_DEBUG(lock, "completion AST, new resource");
+		lock_res_and_lock(lock);
+	}
+
 	if (ldlm_is_destroyed(lock) ||
 	    lock->l_granted_mode == lock->l_req_mode) {
 		/* bug 11300: the lock has already been granted */
@@ -240,20 +255,6 @@ static void ldlm_handle_cp_callback(struct ptlrpc_request *req,
 	}
 
 	ldlm_resource_unlink_lock(lock);
-	if (memcmp(&dlm_req->lock_desc.l_resource.lr_name,
-		   &lock->l_resource->lr_name,
-		   sizeof(lock->l_resource->lr_name)) != 0) {
-		unlock_res_and_lock(lock);
-		rc = ldlm_lock_change_resource(ns, lock,
-					       &dlm_req->lock_desc.l_resource.lr_name);
-		if (rc < 0) {
-			LDLM_ERROR(lock, "Failed to allocate resource");
-			goto out;
-		}
-		LDLM_DEBUG(lock, "completion AST, new resource");
-		CERROR("change resource!\n");
-		lock_res_and_lock(lock);
-	}
 
 	if (dlm_req->lock_flags & LDLM_FL_AST_SENT) {
 		/* BL_AST locks are not needed in LRU.
-- 
1.8.3.1
