From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:08:21 -0500
Subject: [lustre-devel] [PATCH 033/622] lustre: mdc: deny layout swap for
 DoM file
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-34-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mikhail Pershin <mpershin@whamcloud.com>

Layout swap is prohibited for DoM files until LU-10177
will be implemented. The only exception is the new layout
having the same DoM component.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10910
Lustre-commit: 51c11d7cfaff ("LU-10910 mdd: deny layout swap for DoM file")
Signed-off-by: Mikhail Pershin <mpershin@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/32044
Reviewed-by: Fan Yong <fan.yong@intel.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/mdc/mdc_dev.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/lustre/mdc/mdc_dev.c b/fs/lustre/mdc/mdc_dev.c
index 80e3120..21dc83e 100644
--- a/fs/lustre/mdc/mdc_dev.c
+++ b/fs/lustre/mdc/mdc_dev.c
@@ -149,7 +149,8 @@ struct ldlm_lock *mdc_dlmlock_at_pgoff(const struct lu_env *env,
 	 * writers can share a single PW lock.
 	 */
 	mode = mdc_dom_lock_match(env, osc_export(obj), resname, LDLM_IBITS,
-				  policy, LCK_PR | LCK_PW, &flags, obj, &lockh,
+				  policy, LCK_PR | LCK_PW | LCK_GROUP, &flags,
+				  obj, &lockh,
 				  dap_flags & OSC_DAP_FL_CANCELING);
 	if (mode) {
 		lock = ldlm_handle2lock(&lockh);
-- 
1.8.3.1
