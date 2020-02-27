From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:08:36 -0500
Subject: [lustre-devel] [PATCH 048/622] lustre: ldlm: fix for l_lru usage
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-49-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Yang Sheng <ys@whamcloud.com>

Fixes for lock convert code to prevent false assertion and
busy locks in LRU:
- ensure no l_readers and l_writers when add lock to LRU after
  convert.
- don't verify l_lru without ns_lock.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11003
Lustre-commit: 2a77dd3bee76 ("LU-11003 ldlm: fix for l_lru usage")
Signed-off-by: Yang Sheng <ys@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/32309
Reviewed-by: Fan Yong <fan.yong@intel.com>
Reviewed-by: Mikhal Pershin <mpershin@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ldlm/ldlm_inodebits.c |  1 -
 fs/lustre/ldlm/ldlm_request.c   | 19 +++++++++++--------
 2 files changed, 11 insertions(+), 9 deletions(-)

diff --git a/fs/lustre/ldlm/ldlm_inodebits.c b/fs/lustre/ldlm/ldlm_inodebits.c
index e74928e..ddbf8d4 100644
--- a/fs/lustre/ldlm/ldlm_inodebits.c
+++ b/fs/lustre/ldlm/ldlm_inodebits.c
@@ -171,7 +171,6 @@ int ldlm_cli_dropbits(struct ldlm_lock *lock, u64 drop_bits)
 		ldlm_set_cbpending(lock);
 		ldlm_set_bl_ast(lock);
 		unlock_res_and_lock(lock);
-		LASSERT(list_empty(&lock->l_lru));
 		goto exit;
 	}
 
diff --git a/fs/lustre/ldlm/ldlm_request.c b/fs/lustre/ldlm/ldlm_request.c
index 67c23fc..5833f59 100644
--- a/fs/lustre/ldlm/ldlm_request.c
+++ b/fs/lustre/ldlm/ldlm_request.c
@@ -881,21 +881,25 @@ static int lock_convert_interpret(const struct lu_env *env,
 	} else {
 		ldlm_clear_converting(lock);
 
-		/* Concurrent BL AST has arrived, it may cause another convert
-		 * or cancel so just exit here.
+		/* Concurrent BL AST may arrive and cause another convert
+		 * or cancel so just do nothing here if bl_ast is set,
+		 * finish with convert otherwise.
 		 */
 		if (!ldlm_is_bl_ast(lock)) {
 			struct ldlm_namespace *ns = ldlm_lock_to_ns(lock);
 
 			/* Drop cancel_bits since there are no more converts
-			 * and put lock into LRU if it is not there yet.
+			 * and put lock into LRU if it is still not used and
+			 * is not there yet.
 			 */
 			lock->l_policy_data.l_inodebits.cancel_bits = 0;
-			spin_lock(&ns->ns_lock);
-			if (!list_empty(&lock->l_lru))
+			if (!lock->l_readers && !lock->l_writers) {
+				spin_lock(&ns->ns_lock);
+				/* there is check for list_empty() inside */
 				ldlm_lock_remove_from_lru_nolock(lock);
-			ldlm_lock_add_to_lru_nolock(lock);
-			spin_unlock(&ns->ns_lock);
+				ldlm_lock_add_to_lru_nolock(lock);
+				spin_unlock(&ns->ns_lock);
+			}
 		}
 	}
 	unlock_res_and_lock(lock);
@@ -903,7 +907,6 @@ static int lock_convert_interpret(const struct lu_env *env,
 	if (rc) {
 		lock_res_and_lock(lock);
 		if (ldlm_is_converting(lock)) {
-			LASSERT(list_empty(&lock->l_lru));
 			ldlm_clear_converting(lock);
 			ldlm_set_cbpending(lock);
 			ldlm_set_bl_ast(lock);
-- 
1.8.3.1
