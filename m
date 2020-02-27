From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:15:04 -0500
Subject: [lustre-devel] [PATCH 436/622] lustre: osc: Fix dom handling in
 weight_ast
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-437-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Patrick Farrell <pfarrell@whamcloud.com>

The DOM bit can be cancelled at any time during calls to
weigh_ast, so:

1. We cannot assert that it is present
2. We cannot use it to identify the !LDLM_EXTENT case when
calling osc_lock_weight

WC-bug-id: https://jira.whamcloud.com/browse/LU-12343
Lustre-commit: 92c4ad14d4b1 ("LU-12343 osc: Fix dom handling in weight_ast")
Signed-off-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/34966
Reviewed-by: Mike Pershin <mpershin@whamcloud.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/osc/osc_lock.c | 14 ++++++++++----
 1 file changed, 10 insertions(+), 4 deletions(-)

diff --git a/fs/lustre/osc/osc_lock.c b/fs/lustre/osc/osc_lock.c
index e01bf5f..33fdc7e7 100644
--- a/fs/lustre/osc/osc_lock.c
+++ b/fs/lustre/osc/osc_lock.c
@@ -673,7 +673,8 @@ unsigned long osc_ldlm_weigh_ast(struct ldlm_lock *dlmlock)
 		return 1;
 
 	LASSERT(dlmlock->l_resource->lr_type == LDLM_EXTENT ||
-		ldlm_has_dom(dlmlock));
+		dlmlock->l_resource->lr_type == LDLM_IBITS);
+
 	lock_res_and_lock(dlmlock);
 	obj = dlmlock->l_ast_data;
 	if (obj)
@@ -701,12 +702,17 @@ unsigned long osc_ldlm_weigh_ast(struct ldlm_lock *dlmlock)
 		goto out;
 	}
 
-	if (ldlm_has_dom(dlmlock))
-		weight = osc_lock_weight(env, obj, 0, OBD_OBJECT_EOF);
-	else
+	if (dlmlock->l_resource->lr_type == LDLM_EXTENT)
 		weight = osc_lock_weight(env, obj,
 					 dlmlock->l_policy_data.l_extent.start,
 					 dlmlock->l_policy_data.l_extent.end);
+	else if (ldlm_has_dom(dlmlock))
+		weight = osc_lock_weight(env, obj, 0, OBD_OBJECT_EOF);
+	/* The DOM bit can be cancelled at any time; in that case, we know
+	 * there are no pages, so just return weight of 0
+	 */
+	else
+		weight = 0;
 
 out:
 	if (obj)
-- 
1.8.3.1
