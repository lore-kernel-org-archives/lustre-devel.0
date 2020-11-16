From: James Simmons <jsimmons@infradead.org>
Date: Sun, 15 Nov 2020 19:59:52 -0500
Subject: [lustre-devel] [PATCH 19/28] lustre: ldlm: BL AST vs failed lock
 enqueue race
In-Reply-To: <1605488401-981-1-git-send-email-jsimmons@infradead.org>
References: <1605488401-981-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1605488401-981-20-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Andriy Skulysh <c17819@cray.com>

failed_lock_cleanup() marks the lock with LDLM_FL_LOCAL_ONLY,
so cancel request isn't sent.

Mark failed lock with LDLM_FL_LOCAL_ONLY only
if BL AST wasn't received.
Add server's lock handle to BL AST RPC.
So client will be able to cancel the lock
even if enqueue fails.

HPE-bug-id: LUS-8493, LUS-8830
WC-bug-id: https://jira.whamcloud.com/browse/LU-13989
Lustre-commit: c1be044913dde3 ("LU-13989 ldlm: BL AST vs failed lock enqueue race")
Signed-off-by: Andriy Skulysh <c17819@cray.com>
Reviewed-on: https://review.whamcloud.com/40046
Reviewed-by: Vladimir Saveliev <c17830@cray.com>
Reviewed-by: Alexander Boyko <c17825@cray.com>
Reviewed-by: Vitaly Fertman <c17818@cray.com>
Reviewed-by: Alexander Boyko <alexander.boyko@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ldlm/ldlm_lockd.c   | 2 ++
 fs/lustre/ldlm/ldlm_request.c | 5 ++++-
 2 files changed, 6 insertions(+), 1 deletion(-)

diff --git a/fs/lustre/ldlm/ldlm_lockd.c b/fs/lustre/ldlm/ldlm_lockd.c
index 1ae65b829..6f498cc 100644
--- a/fs/lustre/ldlm/ldlm_lockd.c
+++ b/fs/lustre/ldlm/ldlm_lockd.c
@@ -698,6 +698,8 @@ static int ldlm_callback_handler(struct ptlrpc_request *req)
 		ldlm_lock_remove_from_lru(lock);
 		ldlm_set_bl_ast(lock);
 	}
+	if (lock->l_remote_handle.cookie == 0)
+		lock->l_remote_handle = dlm_req->lock_handle[1];
 	unlock_res_and_lock(lock);
 
 	/*
diff --git a/fs/lustre/ldlm/ldlm_request.c b/fs/lustre/ldlm/ldlm_request.c
index dd897ec..74bcba2 100644
--- a/fs/lustre/ldlm/ldlm_request.c
+++ b/fs/lustre/ldlm/ldlm_request.c
@@ -317,8 +317,11 @@ static void failed_lock_cleanup(struct ldlm_namespace *ns,
 		 * bl_ast and -EINVAL reply is sent to server anyways.
 		 * b=17645
 		 */
-		lock->l_flags |= LDLM_FL_LOCAL_ONLY | LDLM_FL_FAILED |
+		lock->l_flags |= LDLM_FL_FAILED |
 				 LDLM_FL_ATOMIC_CB | LDLM_FL_CBPENDING;
+		if (!(ldlm_is_bl_ast(lock) &&
+		      lock->l_remote_handle.cookie != 0))
+			lock->l_flags |= LDLM_FL_LOCAL_ONLY;
 		need_cancel = 1;
 	}
 	unlock_res_and_lock(lock);
-- 
1.8.3.1
