From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Sep 2019 14:55:06 -0400
Subject: [lustre-devel] [PATCH 047/151] lustre: lvbo: pass lock as parameter
 to lvbo_update()
In-Reply-To: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1569869810-23848-48-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mikhal Pershin <mpershin@whamcloud.com>

LVBO lvbo_update call was using ldlm_resource as parameter,
the ldlm_lock parameter is added to recognize DoM resource
in MDT LVBO functions and perform DoM specific actions.

WC-bug-id: https://jira.whamcloud.com/browse/LU-3285
Lustre-commit: 978428ed0476 ("LU-3285 lvbo: pass lock as parameter to lvbo_update()")
Signed-off-by: Mikhal Pershin <mpershin@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/28016
Reviewed-by: Jinshan Xiong <jinshan.xiong@gmail.com>
Reviewed-by: Lai Siyao <lai.siyao@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_dlm.h | 26 ++++++++++++++++----------
 1 file changed, 16 insertions(+), 10 deletions(-)

diff --git a/fs/lustre/include/lustre_dlm.h b/fs/lustre/include/lustre_dlm.h
index b13e0cc..ce287b7 100644
--- a/fs/lustre/include/lustre_dlm.h
+++ b/fs/lustre/include/lustre_dlm.h
@@ -279,9 +279,8 @@ struct ldlm_pool {
  */
 struct ldlm_valblock_ops {
 	int (*lvbo_init)(struct ldlm_resource *res);
-	int (*lvbo_update)(struct ldlm_resource *res,
-			   struct ptlrpc_request *r,
-			   int increase);
+	int (*lvbo_update)(struct ldlm_resource *res, struct ldlm_lock *lock,
+			   struct ptlrpc_request *r,  int increase);
 	int (*lvbo_free)(struct ldlm_resource *res);
 	/* Return size of lvb data appropriate RPC size can be reserved */
 	int (*lvbo_size)(struct ldlm_lock *lock);
@@ -1094,17 +1093,24 @@ static inline struct ldlm_lock *ldlm_handle2lock(const struct lustre_handle *h)
  * Update Lock Value Block Operations (LVBO) on a resource taking into account
  * data from request @r
  */
-static inline int ldlm_res_lvbo_update(struct ldlm_resource *res,
-				       struct ptlrpc_request *r, int increase)
+static inline int ldlm_lvbo_update(struct ldlm_resource *res,
+				   struct ldlm_lock *lock,
+				   struct ptlrpc_request *req, int increase)
 {
-	if (ldlm_res_to_ns(res)->ns_lvbo &&
-	    ldlm_res_to_ns(res)->ns_lvbo->lvbo_update) {
-		return ldlm_res_to_ns(res)->ns_lvbo->lvbo_update(res, r,
-								 increase);
-	}
+	struct ldlm_namespace *ns = ldlm_res_to_ns(res);
+
+	if (ns->ns_lvbo && ns->ns_lvbo->lvbo_update)
+		return ns->ns_lvbo->lvbo_update(res, lock, req, increase);
+
 	return 0;
 }
 
+static inline int ldlm_res_lvbo_update(struct ldlm_resource *res,
+				       struct ptlrpc_request *req, int increase)
+{
+	return ldlm_lvbo_update(res, NULL, req, increase);
+}
+
 int ldlm_error2errno(enum ldlm_error error);
 
 #if LUSTRE_TRACKS_LOCK_EXP_REFS
-- 
1.8.3.1
