From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:12:39 -0500
Subject: [lustre-devel] [PATCH 291/622] lustre: ptlrpc: Fix style issues for
 llog_client.c
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-292-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Arshad Hussain <arshad.super@gmail.com>

This patch fixes issues reported by checkpatch
for file fs/lustre/ptlrpc/llog_client.c

WC-bug-id: https://jira.whamcloud.com/browse/LU-6142
Lustre-commit: b0372d346200 ("LU-6142 ptlrpc: Fix style issues for llog_client.c")
Signed-off-by: Arshad Hussain <arshad.super@gmail.com>
Reviewed-on: https://review.whamcloud.com/34900
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ptlrpc/llog_client.c | 15 +++++++++------
 1 file changed, 9 insertions(+), 6 deletions(-)

diff --git a/fs/lustre/ptlrpc/llog_client.c b/fs/lustre/ptlrpc/llog_client.c
index e5ff080..ff1ca36 100644
--- a/fs/lustre/ptlrpc/llog_client.c
+++ b/fs/lustre/ptlrpc/llog_client.c
@@ -55,7 +55,7 @@
 		       ctxt->loc_idx);					\
 		imp = NULL;						\
 		mutex_unlock(&ctxt->loc_mutex);				\
-		return (-EINVAL);					\
+		return -EINVAL;						\
 	}								\
 	mutex_unlock(&ctxt->loc_mutex);					\
 } while (0)
@@ -64,12 +64,13 @@
 	mutex_lock(&ctxt->loc_mutex);					\
 	if (ctxt->loc_imp != imp)					\
 		CWARN("loc_imp has changed from %p to %p\n",		\
-		       ctxt->loc_imp, imp);				\
+		      ctxt->loc_imp, imp);				\
 	class_import_put(imp);						\
 	mutex_unlock(&ctxt->loc_mutex);					\
 } while (0)
 
-/* This is a callback from the llog_* functions.
+/*
+ * This is a callback from the llog_* functions.
  * Assumes caller has already pushed us into the kernel context.
  */
 static int llog_client_open(const struct lu_env *env,
@@ -171,7 +172,8 @@ static int llog_client_next_block(const struct lu_env *env,
 	req_capsule_set_size(&req->rq_pill, &RMF_EADATA, RCL_SERVER, len);
 	ptlrpc_request_set_replen(req);
 	rc = ptlrpc_queue_wait(req);
-	/* -EIO has a special meaning here. If llog_osd_next_block()
+	/*
+	 * -EIO has a special meaning here. If llog_osd_next_block()
 	 * reaches the end of the log without finding the desired
 	 * record then it updates *cur_offset and *cur_idx and returns
 	 * -EIO. In llog_process_thread() we use this to detect
@@ -338,8 +340,9 @@ static int llog_client_read_header(const struct lu_env *env,
 static int llog_client_close(const struct lu_env *env,
 			     struct llog_handle *handle)
 {
-	/* this doesn't call LLOG_ORIGIN_HANDLE_CLOSE because
-	 *  the servers all close the file at the end of every
+	/*
+	 * this doesn't call LLOG_ORIGIN_HANDLE_CLOSE because
+	 * the servers all close the file at the end of every
 	 * other LLOG_ RPC.
 	 */
 	return 0;
-- 
1.8.3.1
