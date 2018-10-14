From: James Simmons <jsimmons@infradead.org>
Date: Sun, 14 Oct 2018 14:58:13 -0400
Subject: [lustre-devel] [PATCH 23/28] lustre: llog: fix EOF handling in
 llog_client_next_block()
In-Reply-To: <1539543498-29105-1-git-send-email-jsimmons@infradead.org>
References: <1539543498-29105-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1539543498-29105-24-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: "John L. Hammond" <jhammond@whamcloud.com>

In llog_client_next_block() update *cur_idx and *cur_offset in the
special case that the handler has returned -EIO after reaching the end
of the log without finding the desired record. This fixes client side
EOF detection in llog_process_thread().

Signed-off-by: John L. Hammond <jhammond@whamcloud.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-10267
Reviewed-on: https://review.whamcloud.com/30313
Reviewed-by: Mike Pershin <mpershin@whamcloud.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/ptlrpc/llog_client.c | 24 ++++++++++++++++++----
 1 file changed, 20 insertions(+), 4 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ptlrpc/llog_client.c b/drivers/staging/lustre/lustre/ptlrpc/llog_client.c
index 946d538..6ddd93c 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/llog_client.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/llog_client.c
@@ -171,8 +171,21 @@ static int llog_client_next_block(const struct lu_env *env,
 	req_capsule_set_size(&req->rq_pill, &RMF_EADATA, RCL_SERVER, len);
 	ptlrpc_request_set_replen(req);
 	rc = ptlrpc_queue_wait(req);
-	if (rc)
+	/* -EIO has a special meaning here. If llog_osd_next_block()
+	 * reaches the end of the log without finding the desired
+	 * record then it updates *cur_offset and *cur_idx and returns
+	 * -EIO. In llog_process_thread() we use this to detect
+	 * EOF. But we must be careful to distinguish between -EIO
+	 * coming from llog_osd_next_block() and -EIO coming from
+	 * ptlrpc or below.
+	 */
+	if (rc == -EIO) {
+		if (!req->rq_repmsg ||
+		    lustre_msg_get_status(req->rq_repmsg) != -EIO)
+			goto out;
+	} else if (rc < 0) {
 		goto out;
+	}
 
 	body = req_capsule_server_get(&req->rq_pill, &RMF_LLOGD_BODY);
 	if (!body) {
@@ -180,6 +193,12 @@ static int llog_client_next_block(const struct lu_env *env,
 		goto out;
 	}
 
+	*cur_idx = body->lgd_saved_index;
+	*cur_offset = body->lgd_cur_offset;
+
+	if (rc < 0)
+		goto out;
+
 	/* The log records are swabbed as they are processed */
 	ptr = req_capsule_server_get(&req->rq_pill, &RMF_EADATA);
 	if (!ptr) {
@@ -187,9 +206,6 @@ static int llog_client_next_block(const struct lu_env *env,
 		goto out;
 	}
 
-	*cur_idx = body->lgd_saved_index;
-	*cur_offset = body->lgd_cur_offset;
-
 	memcpy(buf, ptr, len);
 out:
 	ptlrpc_req_finished(req);
-- 
1.8.3.1
