From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:11:47 -0500
Subject: [lustre-devel] [PATCH 239/622] lustre: ldlm: Lost lease lock on
 migrate error
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-240-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Andriy Skulysh <c17819@cray.com>

All the file operations have the following locking order - parent,
child. If a lock for a child is returned to the client, the following
operations on this file are done by the child fid.

However, the migrate is an exception - it takes the lease lock first and
takes the PW parent lock next during the MDS_REINT.

At the same time, if there is a parallel racing operation (open) which
has taken a lock on parent (conflicting with the next MDS_REINT) and
is trying to take a lock on child - it is blocked until
the lease cancel comes.

The lease cancel is piggy-backed on the MDS_REINT RPC and is handled
at the end of the operation, trying to take the conflicting parent lock
first - thus a deadlock occurs.

At the same time, the lease lock is not supposed to block anything, it
is just an indicator on the server there is no other conflicting
operation has occurred during the migration - thus
set LDLM_FL_CANCEL_ON_BLOCK on it and the conflicting operation
will not be blocked.

In this case, the MDS_REINT will return -EAGAIN as the lease
is cancelled and the client will retry its migration.

Cray-bug-id: LUS-6811
WC-bug-id: https://jira.whamcloud.com/browse/LU-11926
Lustre-commit: ae7ca90713b4 ("LU-11926 ldlm: Lost lease lock on migrate error")
Signed-off-by: Andriy Skulysh <c17819@cray.com>
Reviewed-on: https://review.whamcloud.com/34182
Reviewed-by: Vitaly Fertman <c17818@cray.com>
Reviewed-by: Alexandr Boyko <c17825@cray.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/obd_support.h | 1 +
 fs/lustre/ldlm/ldlm_lockd.c     | 3 ---
 fs/lustre/ldlm/ldlm_request.c   | 4 ++++
 fs/lustre/llite/file.c          | 4 +++-
 4 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/fs/lustre/include/obd_support.h b/fs/lustre/include/obd_support.h
index 39547a0..a60fa07 100644
--- a/fs/lustre/include/obd_support.h
+++ b/fs/lustre/include/obd_support.h
@@ -302,6 +302,7 @@
 #define OBD_FAIL_LDLM_CP_CB_WAIT5			0x323
 
 #define OBD_FAIL_LDLM_GRANT_CHECK			0x32a
+#define OBD_FAIL_LDLM_LOCAL_CANCEL_PAUSE		0x32c
 
 /* LOCKLESS IO */
 #define OBD_FAIL_LDLM_SET_CONTENTION			0x385
diff --git a/fs/lustre/ldlm/ldlm_lockd.c b/fs/lustre/ldlm/ldlm_lockd.c
index db0da99..ea146aa 100644
--- a/fs/lustre/ldlm/ldlm_lockd.c
+++ b/fs/lustre/ldlm/ldlm_lockd.c
@@ -149,9 +149,6 @@ void ldlm_handle_bl_callback(struct ldlm_namespace *ns,
 	}
 	ldlm_set_cbpending(lock);
 
-	if (ldlm_is_cancel_on_block(lock))
-		ldlm_set_cancel(lock);
-
 	do_ast = !lock->l_readers && !lock->l_writers;
 	unlock_res_and_lock(lock);
 
diff --git a/fs/lustre/ldlm/ldlm_request.c b/fs/lustre/ldlm/ldlm_request.c
index 7c3935f..fb564f4 100644
--- a/fs/lustre/ldlm/ldlm_request.c
+++ b/fs/lustre/ldlm/ldlm_request.c
@@ -1293,6 +1293,10 @@ int ldlm_cli_cancel(const struct lustre_handle *lockh,
 	ldlm_set_canceling(lock);
 	unlock_res_and_lock(lock);
 
+	if (cancel_flags & LCF_LOCAL)
+		OBD_FAIL_TIMEOUT(OBD_FAIL_LDLM_LOCAL_CANCEL_PAUSE,
+				 cfs_fail_val);
+
 	rc = ldlm_cli_cancel_local(lock);
 	if (rc == LDLM_FL_LOCAL_ONLY || cancel_flags & LCF_LOCAL) {
 		LDLM_LOCK_RELEASE(lock);
diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index 4560ae0..7ec1099 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -3934,7 +3934,9 @@ int ll_migrate(struct inode *parent, struct file *file, struct lmv_user_md *lum,
 	if (!rc) {
 		LASSERT(request);
 		ll_update_times(request, parent);
+	}
 
+	if (rc == 0 || rc == -EAGAIN) {
 		body = req_capsule_server_get(&request->rq_pill, &RMF_MDT_BODY);
 		LASSERT(body);
 
@@ -3957,7 +3959,7 @@ int ll_migrate(struct inode *parent, struct file *file, struct lmv_user_md *lum,
 		request = NULL;
 	}
 
-	/* Try again if the file layout has changed. */
+	/* Try again if the lease has cancelled. */
 	if (rc == -EAGAIN && S_ISREG(child_inode->i_mode))
 		goto again;
 
-- 
1.8.3.1
