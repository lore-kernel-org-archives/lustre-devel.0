From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:11:35 -0500
Subject: [lustre-devel] [PATCH 227/622] lustre: ldlm: don't convert wrong
 resource
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-228-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mikhail Pershin <mpershin@whamcloud.com>

During enqueue the returned lock may have different resource
and local client lock replaces resource too. But there is
a valid race with bl_ast and reply from server, so BL AST
may come earlier and find client lock with old resource.
In that case ldlm_handle_bl_callback() should proceed with
normal cancel and don't use cancel_bits for lock convert.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11836
Lustre-commit: 2bc71659db69 ("LU-11836 ldlm: don't convert wrong resource")
Signed-off-by: Mikhail Pershin <mpershin@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/34264
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ldlm/ldlm_lockd.c | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/fs/lustre/ldlm/ldlm_lockd.c b/fs/lustre/ldlm/ldlm_lockd.c
index 6905ee5..2985e37 100644
--- a/fs/lustre/ldlm/ldlm_lockd.c
+++ b/fs/lustre/ldlm/ldlm_lockd.c
@@ -131,8 +131,14 @@ void ldlm_handle_bl_callback(struct ldlm_namespace *ns,
 		 * NOTE: ld can be NULL or can be not NULL but zeroed if
 		 * passed from ldlm_bl_thread_blwi(), check below used bits
 		 * in ld to make sure it is valid description.
+		 *
+		 * If server may replace lock resource keeping the same cookie,
+		 * never use cancel bits from different resource, full cancel
+		 * is to be used.
 		 */
-		if (ld && ld->l_policy_data.l_inodebits.bits)
+		if (ld && ld->l_policy_data.l_inodebits.bits &&
+		    ldlm_res_eq(&ld->l_resource.lr_name,
+				&lock->l_resource->lr_name))
 			lock->l_policy_data.l_inodebits.cancel_bits =
 				ld->l_policy_data.l_inodebits.cancel_bits;
 		/* if there is no valid ld and lock is cbpending already
-- 
1.8.3.1
