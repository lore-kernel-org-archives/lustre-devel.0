From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:08:32 -0500
Subject: [lustre-devel] [PATCH 044/622] lustre: build: armv7 client build
 fixes
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-45-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Andrew Perepechko <c17827@cray.com>

This commit is supposed to fix armv7 Lustre client
build, mostly 64-bit division related changes.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10964
Lustre-commit: 0300a6efd226 ("LU-10964 build: armv7 client build fixes")
Signed-off-by: Andrew Perepechko <c17827@cray.com>
Reviewed-on: https://review.whamcloud.com/32194
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Alexander Zarochentsev <c17826@cray.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ldlm/ldlm_request.c | 3 ++-
 fs/lustre/ptlrpc/import.c     | 2 +-
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/fs/lustre/ldlm/ldlm_request.c b/fs/lustre/ldlm/ldlm_request.c
index dd4d958..3991a8f 100644
--- a/fs/lustre/ldlm/ldlm_request.c
+++ b/fs/lustre/ldlm/ldlm_request.c
@@ -1408,7 +1408,8 @@ static enum ldlm_policy_res ldlm_cancel_lrur_policy(struct ldlm_namespace *ns,
 
 	slv = ldlm_pool_get_slv(pl);
 	lvf = ldlm_pool_get_lvf(pl);
-	la = ktime_to_ns(ktime_sub(cur, lock->l_last_used)) / NSEC_PER_SEC;
+	la = div_u64(ktime_to_ns(ktime_sub(cur, lock->l_last_used)),
+		     NSEC_PER_SEC);
 	lv = lvf * la * unused;
 
 	/* Inform pool about current CLV to see it via debugfs. */
diff --git a/fs/lustre/ptlrpc/import.c b/fs/lustre/ptlrpc/import.c
index f69b907..5d6546d 100644
--- a/fs/lustre/ptlrpc/import.c
+++ b/fs/lustre/ptlrpc/import.c
@@ -289,7 +289,7 @@ void ptlrpc_invalidate_import(struct obd_import *imp)
 		 */
 		if (!OBD_FAIL_CHECK(OBD_FAIL_PTLRPC_LONG_REPL_UNLINK)) {
 			timeout = ptlrpc_inflight_timeout(imp);
-			timeout += timeout / 3;
+			timeout += div_u64(timeout, 3);
 
 			if (timeout == 0)
 				timeout = obd_timeout;
-- 
1.8.3.1
