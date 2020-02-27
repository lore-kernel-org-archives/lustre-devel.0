From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:12:02 -0500
Subject: [lustre-devel] [PATCH 254/622] lustre: ldlm: Fix style issues for
 ptlrpcd.c
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-255-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Arshad Hussain <arshad.super@gmail.com>

This patch fixes issues reported by checkpatch
for file fs/lustre/ptlrpc/ptlrpcd.c

WC-bug-id: https://jira.whamcloud.com/browse/LU-6142
Lustre-commit: f64aeebfceb3 ("LU-6142 ldlm: Fix style issues for ptlrpcd.c")
Signed-off-by: Arshad Hussain <arshad.super@gmail.com>
Reviewed-on: https://review.whamcloud.com/34604
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Ben Evans <bevans@cray.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ptlrpc/ptlrpcd.c | 13 ++++++++-----
 1 file changed, 8 insertions(+), 5 deletions(-)

diff --git a/fs/lustre/ptlrpc/ptlrpcd.c b/fs/lustre/ptlrpc/ptlrpcd.c
index e9c03ba..bcf1e46 100644
--- a/fs/lustre/ptlrpc/ptlrpcd.c
+++ b/fs/lustre/ptlrpc/ptlrpcd.c
@@ -238,7 +238,8 @@ void ptlrpcd_add_req(struct ptlrpc_request *req)
 			wait_event_idle(req->rq_set_waitq,
 					!req->rq_set);
 	} else if (req->rq_set) {
-		/* If we have a valid "rq_set", just reuse it to avoid double
+		/*
+		 * If we have a valid "rq_set", just reuse it to avoid double
 		 * linked.
 		 */
 		LASSERT(req->rq_phase == RQ_PHASE_NEW);
@@ -294,7 +295,8 @@ static int ptlrpcd_check(struct lu_env *env, struct ptlrpcd_ctl *pc)
 		spin_unlock(&set->set_new_req_lock);
 	}
 
-	/* We should call lu_env_refill() before handling new requests to make
+	/*
+	 * We should call lu_env_refill() before handling new requests to make
 	 * sure that env key the requests depending on really exists.
 	 */
 	rc2 = lu_env_refill(env);
@@ -316,7 +318,8 @@ static int ptlrpcd_check(struct lu_env *env, struct ptlrpcd_ctl *pc)
 	if (atomic_read(&set->set_remaining))
 		rc |= ptlrpc_check_set(env, set);
 
-	/* NB: ptlrpc_check_set has already moved completed request at the
+	/*
+	 * NB: ptlrpc_check_set has already moved completed request at the
 	 * head of seq::set_requests
 	 */
 	list_for_each_entry_safe(req, tmp, &set->set_requests, rq_set_chain) {
@@ -334,7 +337,8 @@ static int ptlrpcd_check(struct lu_env *env, struct ptlrpcd_ctl *pc)
 		 */
 		rc = atomic_read(&set->set_new_count);
 
-		/* If we have nothing to do, check whether we can take some
+		/*
+		 * If we have nothing to do, check whether we can take some
 		 * work from our partner threads.
 		 */
 		if (rc == 0 && pc->pc_npartners > 0) {
@@ -379,7 +383,6 @@ static int ptlrpcd_check(struct lu_env *env, struct ptlrpcd_ctl *pc)
  * Main ptlrpcd thread.
  * ptlrpc's code paths like to execute in process context, so we have this
  * thread which spins on a set which contains the rpcs and sends them.
- *
  */
 static int ptlrpcd(void *arg)
 {
-- 
1.8.3.1
