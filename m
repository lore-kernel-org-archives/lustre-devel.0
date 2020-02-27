From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:09:32 -0500
Subject: [lustre-devel] [PATCH 104/622] lustre: ldlm: correct logic in
 ldlm_prepare_lru_list()
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-105-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: "John L. Hammond" <jhammond@whamcloud.com>

In ldlm_prepare_lru_list() fix an (x != a || x != b) type error and
correct a use after free.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11075
Lustre-commit: aecafb57d5b6 ("LU-11075 ldlm: correct logic in ldlm_prepare_lru_list()")
Signed-off-by: John L. Hammond <jhammond@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/32660
Reviewed-by: Mike Pershin <mpershin@whamcloud.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ldlm/ldlm_request.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/fs/lustre/ldlm/ldlm_request.c b/fs/lustre/ldlm/ldlm_request.c
index bc441f0..f045d30 100644
--- a/fs/lustre/ldlm/ldlm_request.c
+++ b/fs/lustre/ldlm/ldlm_request.c
@@ -1643,7 +1643,7 @@ static int ldlm_prepare_lru_list(struct ldlm_namespace *ns,
 			/* No locks which got blocking requests. */
 			LASSERT(!ldlm_is_bl_ast(lock));
 
-			if (!ldlm_is_canceling(lock) ||
+			if (!ldlm_is_canceling(lock) &&
 			    !ldlm_is_converting(lock))
 				break;
 
@@ -1686,7 +1686,6 @@ static int ldlm_prepare_lru_list(struct ldlm_namespace *ns,
 
 		if (result == LDLM_POLICY_SKIP_LOCK) {
 			lu_ref_del(&lock->l_reference, __func__, current);
-			LDLM_LOCK_RELEASE(lock);
 			if (no_wait) {
 				spin_lock(&ns->ns_lock);
 				if (!list_empty(&lock->l_lru) &&
@@ -1694,6 +1693,8 @@ static int ldlm_prepare_lru_list(struct ldlm_namespace *ns,
 					ns->ns_last_pos = &lock->l_lru;
 				spin_unlock(&ns->ns_lock);
 			}
+
+			LDLM_LOCK_RELEASE(lock);
 			continue;
 		}
 
-- 
1.8.3.1
