From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:10:07 -0500
Subject: [lustre-devel] [PATCH 139/622] lustre: ldlm: don't apply ELC to
 converting and DOM locks
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-140-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mikhail Pershin <mpershin@whamcloud.com>

Prevent ELC for locks being converted and for locks
having DOM bit set to avoid data flush without need.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11276
Lustre-commit: 70a01a6c9c7c ("LU-11276 ldlm: don't apply ELC to converting and DOM locks")
Signed-off-by: Mikhail Pershin <mpershin@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/33125
Reviewed-by: Lai Siyao <lai.siyao@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ldlm/ldlm_request.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/fs/lustre/ldlm/ldlm_request.c b/fs/lustre/ldlm/ldlm_request.c
index 9d3330c..1afe9a5 100644
--- a/fs/lustre/ldlm/ldlm_request.c
+++ b/fs/lustre/ldlm/ldlm_request.c
@@ -1823,7 +1823,8 @@ int ldlm_cancel_resource_local(struct ldlm_resource *res,
 		/* If somebody is already doing CANCEL, or blocking AST came,
 		 * skip this lock.
 		 */
-		if (ldlm_is_bl_ast(lock) || ldlm_is_canceling(lock))
+		if (ldlm_is_bl_ast(lock) || ldlm_is_canceling(lock) ||
+		    ldlm_is_converting(lock))
 			continue;
 
 		if (lockmode_compat(lock->l_granted_mode, mode))
@@ -1831,10 +1832,11 @@ int ldlm_cancel_resource_local(struct ldlm_resource *res,
 
 		/* If policy is given and this is IBITS lock, add to list only
 		 * those locks that match by policy.
+		 * Skip locks with DoM bit always to don't flush data.
 		 */
 		if (policy && (lock->l_resource->lr_type == LDLM_IBITS) &&
-		    !(lock->l_policy_data.l_inodebits.bits &
-		      policy->l_inodebits.bits))
+		    (!(lock->l_policy_data.l_inodebits.bits &
+		      policy->l_inodebits.bits) || ldlm_has_dom(lock)))
 			continue;
 
 		/* See CBPENDING comment in ldlm_cancel_lru */
-- 
1.8.3.1
