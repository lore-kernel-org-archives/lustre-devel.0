From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:08:45 -0500
Subject: [lustre-devel] [PATCH 057/622] lustre: ldlm: don't add canceling
 lock back to LRU
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-58-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mikhail Pershin <mpershin@whamcloud.com>

When lock is converted check it is not canceling before
adding it back to LRU.

Lustre-commit: ad52f394bd82 ("LU-11003 ldlm: don't add canceling lock back to LRU")
Signed-off-by: Mikhail Pershin <mpershin@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/32692
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: John L. Hammond <jhammond@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ldlm/ldlm_request.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/lustre/ldlm/ldlm_request.c b/fs/lustre/ldlm/ldlm_request.c
index ad54bd2..bc441f0 100644
--- a/fs/lustre/ldlm/ldlm_request.c
+++ b/fs/lustre/ldlm/ldlm_request.c
@@ -893,7 +893,8 @@ static int lock_convert_interpret(const struct lu_env *env,
 			 * is not there yet.
 			 */
 			lock->l_policy_data.l_inodebits.cancel_bits = 0;
-			if (!lock->l_readers && !lock->l_writers) {
+			if (!lock->l_readers && !lock->l_writers &&
+			    !ldlm_is_canceling(lock)) {
 				spin_lock(&ns->ns_lock);
 				/* there is check for list_empty() inside */
 				ldlm_lock_remove_from_lru_nolock(lock);
-- 
1.8.3.1
