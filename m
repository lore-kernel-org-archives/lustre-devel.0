From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:14:15 -0500
Subject: [lustre-devel] [PATCH 387/622] lustre: osc: cancel osc_lock list
 traversal once found the lock is being used
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-388-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Gu Zheng <gzheng@ddn.com>

Currently, in osc_ldlm_weigh_ast, it walks osc_lock list (oo_ol_list)
to check whether target dlm is being used, normally, if found, it needs
to skip the rest ones and cancel the traversal, but it doesn't, let's
fix it here.

Fixes: 3f3a24dc5d7d ("LU-3259 clio: cl_lock simplification")
WC-bug-id: https://jira.whamcloud.com/browse/LU-11518
Lustre-commit: eb9aa909343b ("LU-11518 osc: cancel osc_lock list traversal once found the lock is being used")
Signed-off-by: Gu Zheng <gzheng@ddn.com>
Reviewed-on: https://review.whamcloud.com/35396
Reviewed-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Li Xi <lixi@ddn.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/osc/osc_lock.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/fs/lustre/osc/osc_lock.c b/fs/lustre/osc/osc_lock.c
index 29d8373..e01bf5f 100644
--- a/fs/lustre/osc/osc_lock.c
+++ b/fs/lustre/osc/osc_lock.c
@@ -687,9 +687,10 @@ unsigned long osc_ldlm_weigh_ast(struct ldlm_lock *dlmlock)
 
 	spin_lock(&obj->oo_ol_spin);
 	list_for_each_entry(oscl, &obj->oo_ol_list, ols_nextlock_oscobj) {
-		if (oscl->ols_dlmlock && oscl->ols_dlmlock != dlmlock)
-			continue;
-		found = true;
+		if (oscl->ols_dlmlock == dlmlock) {
+			found = true;
+			break;
+		}
 	}
 	spin_unlock(&obj->oo_ol_spin);
 	if (found) {
-- 
1.8.3.1
