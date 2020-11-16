From: James Simmons <jsimmons@infradead.org>
Date: Sun, 15 Nov 2020 19:59:48 -0500
Subject: [lustre-devel] [PATCH 15/28] lustre: ldlm: Fix unbounded
 OBD_FAIL_LDLM_CANCEL_BL_CB_RACE wait
In-Reply-To: <1605488401-981-1-git-send-email-jsimmons@infradead.org>
References: <1605488401-981-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1605488401-981-16-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Oleg Drokin <green@whamcloud.com>

in ldlm_handle_cp_callback the while loop is clearly supposed
to be limited by the "to" value of 1 second, but is not.
Seems to have been broken by all the Solaris porting in HEAD
all the way back in 2008.
Restore the to assignment to make it not hang indefinitely.

Fixes: adde80ff ("Land b_head_libcfs onto OpenSFS tree HEAD")
WC-bug-id: https://jira.whamcloud.com/browse/LU-14069
Lustre-commit: 5da99051e58b9e ("LU-14069 ldlm: Fix unbounded OBD_FAIL_LDLM_CANCEL_BL_CB_RACE wait")
Signed-off-by: Oleg Drokin <green@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/40375
Reviewed-by: Mike Pershin <mpershin@whamcloud.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ldlm/ldlm_lockd.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/lustre/ldlm/ldlm_lockd.c b/fs/lustre/ldlm/ldlm_lockd.c
index 4a91a7f..1ae65b829 100644
--- a/fs/lustre/ldlm/ldlm_lockd.c
+++ b/fs/lustre/ldlm/ldlm_lockd.c
@@ -223,7 +223,7 @@ static int ldlm_handle_cp_callback(struct ptlrpc_request *req,
 		ldlm_callback_reply(req, 0);
 
 		while (to > 0) {
-			schedule_timeout_interruptible(to);
+			to = schedule_timeout_interruptible(to);
 			if (ldlm_is_granted(lock) ||
 			    ldlm_is_destroyed(lock))
 				break;
-- 
1.8.3.1
