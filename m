From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:08:43 -0500
Subject: [lustre-devel] [PATCH 055/622] lustre: ldlm: handle lock converts
 in cancel handler
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-56-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mikhail Pershin <mpershin@whamcloud.com>

- Use cancel portals and high-priority handling for lock
  converts. Update ldlm_cancel_handler to understand
  LDLM_CONVERT RPC for that.
- Use ns_dirty_age_limit for lock convert - don't convert too old
  locks.
- Check for empty converts and skip such

WC-bug-id: https://jira.whamcloud.com/browse/LU-10175
Lustre-commit: 541902a3f934 ("LU-10175 ldlm: handle lock converts in cancel handler")
Signed-off-by: Mikhail Pershin <mpershin@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/32314
Reviewed-by: Fan Yong <fan.yong@intel.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_export.h |  6 ++++++
 fs/lustre/ldlm/ldlm_inodebits.c   | 19 ++++++++++++++-----
 fs/lustre/ldlm/ldlm_request.c     | 39 +++++++++++++++++++++++++++++++--------
 fs/lustre/llite/llite_lib.c       |  2 +-
 fs/lustre/llite/namei.c           |  7 ++++++-
 5 files changed, 58 insertions(+), 15 deletions(-)

diff --git a/fs/lustre/include/lustre_export.h b/fs/lustre/include/lustre_export.h
index de3b109..57cf68b 100644
--- a/fs/lustre/include/lustre_export.h
+++ b/fs/lustre/include/lustre_export.h
@@ -269,9 +269,15 @@ static inline int exp_connect_flr(struct obd_export *exp)
 	return !!(exp_connect_flags2(exp) & OBD_CONNECT2_FLR);
 }
 
+static inline int exp_connect_lock_convert(struct obd_export *exp)
+{
+	return !!(exp_connect_flags2(exp) & OBD_CONNECT2_LOCK_CONVERT);
+}
+
 struct obd_export *class_conn2export(struct lustre_handle *conn);
 
 #define KKUC_CT_DATA_MAGIC	0x092013cea
+
 struct kkuc_ct_data {
 	u32			kcd_magic;
 	u32			kcd_archive;
diff --git a/fs/lustre/ldlm/ldlm_inodebits.c b/fs/lustre/ldlm/ldlm_inodebits.c
index ddbf8d4..9cf3c5f 100644
--- a/fs/lustre/ldlm/ldlm_inodebits.c
+++ b/fs/lustre/ldlm/ldlm_inodebits.c
@@ -81,7 +81,7 @@ int ldlm_inodebits_drop(struct ldlm_lock *lock, u64 to_drop)
 
 	/* Just return if there are no conflicting bits */
 	if ((lock->l_policy_data.l_inodebits.bits & to_drop) == 0) {
-		LDLM_WARN(lock, "try to drop unset bits %#llx/%#llx\n",
+		LDLM_WARN(lock, "try to drop unset bits %#llx/%#llx",
 			  lock->l_policy_data.l_inodebits.bits, to_drop);
 		/* nothing to do */
 		return 0;
@@ -111,7 +111,7 @@ int ldlm_cli_dropbits(struct ldlm_lock *lock, u64 drop_bits)
 
 	ldlm_lock2handle(lock, &lockh);
 	lock_res_and_lock(lock);
-	/* check if all bits are cancelled */
+	/* check if all bits are blocked */
 	if (!(lock->l_policy_data.l_inodebits.bits & ~drop_bits)) {
 		unlock_res_and_lock(lock);
 		/* return error to continue with cancel */
@@ -119,6 +119,13 @@ int ldlm_cli_dropbits(struct ldlm_lock *lock, u64 drop_bits)
 		goto exit;
 	}
 
+	/* check if no common bits, consider this as successful convert */
+	if (!(lock->l_policy_data.l_inodebits.bits & drop_bits)) {
+		unlock_res_and_lock(lock);
+		rc = 0;
+		goto exit;
+	}
+
 	/* check if there is race with cancel */
 	if (ldlm_is_canceling(lock) || ldlm_is_cancel(lock)) {
 		unlock_res_and_lock(lock);
@@ -167,9 +174,11 @@ int ldlm_cli_dropbits(struct ldlm_lock *lock, u64 drop_bits)
 	rc = ldlm_cli_convert(lock, &flags);
 	if (rc) {
 		lock_res_and_lock(lock);
-		ldlm_clear_converting(lock);
-		ldlm_set_cbpending(lock);
-		ldlm_set_bl_ast(lock);
+		if (ldlm_is_converting(lock)) {
+			ldlm_clear_converting(lock);
+			ldlm_set_cbpending(lock);
+			ldlm_set_bl_ast(lock);
+		}
 		unlock_res_and_lock(lock);
 		goto exit;
 	}
diff --git a/fs/lustre/ldlm/ldlm_request.c b/fs/lustre/ldlm/ldlm_request.c
index 5833f59..ad54bd2 100644
--- a/fs/lustre/ldlm/ldlm_request.c
+++ b/fs/lustre/ldlm/ldlm_request.c
@@ -854,7 +854,7 @@ static int lock_convert_interpret(const struct lu_env *env,
 			   aa->lock_handle.cookie, reply->lock_handle.cookie,
 			   req->rq_export->exp_client_uuid.uuid,
 			   libcfs_id2str(req->rq_peer));
-		rc = -ESTALE;
+		rc = ELDLM_NO_LOCK_DATA;
 		goto out;
 	}
 
@@ -905,15 +905,30 @@ static int lock_convert_interpret(const struct lu_env *env,
 	unlock_res_and_lock(lock);
 out:
 	if (rc) {
+		int flag;
+
 		lock_res_and_lock(lock);
 		if (ldlm_is_converting(lock)) {
 			ldlm_clear_converting(lock);
 			ldlm_set_cbpending(lock);
 			ldlm_set_bl_ast(lock);
+			lock->l_policy_data.l_inodebits.cancel_bits = 0;
 		}
 		unlock_res_and_lock(lock);
-	}
 
+		/* fallback to normal lock cancel. If rc means there is no
+		 * valid lock on server, do only local cancel
+		 */
+		if (rc == ELDLM_NO_LOCK_DATA)
+			flag = LCF_LOCAL;
+		else
+			flag = LCF_ASYNC;
+
+		rc = ldlm_cli_cancel(&aa->lock_handle, flag);
+		if (rc < 0)
+			LDLM_DEBUG(lock, "failed to cancel lock: rc = %d\n",
+				   rc);
+	}
 	LDLM_LOCK_PUT(lock);
 	return rc;
 }
@@ -942,6 +957,15 @@ int ldlm_cli_convert(struct ldlm_lock *lock, u32 *flags)
 		return -EINVAL;
 	}
 
+	/* this is better to check earlier and it is done so already,
+	 * but this check is kept too as final one to issue an error
+	 * if any new code will miss such check.
+	 */
+	if (!exp_connect_lock_convert(exp)) {
+		LDLM_ERROR(lock, "server doesn't support lock convert\n");
+		return -EPROTO;
+	}
+
 	if (lock->l_resource->lr_type != LDLM_IBITS) {
 		LDLM_ERROR(lock, "convert works with IBITS locks only.");
 		return -EINVAL;
@@ -970,13 +994,12 @@ int ldlm_cli_convert(struct ldlm_lock *lock, u32 *flags)
 
 	ptlrpc_request_set_replen(req);
 
-	/* That could be useful to use cancel portals for convert as well
-	 * as high-priority handling. This will require changes in
-	 * ldlm_cancel_handler to understand convert RPC as well.
-	 *
-	 * req->rq_request_portal = LDLM_CANCEL_REQUEST_PORTAL;
-	 * req->rq_reply_portal = LDLM_CANCEL_REPLY_PORTAL;
+	/*
+	 * Use cancel portals for convert as well as high-priority handling.
 	 */
+	req->rq_request_portal = LDLM_CANCEL_REQUEST_PORTAL;
+	req->rq_reply_portal = LDLM_CANCEL_REPLY_PORTAL;
+
 	ptlrpc_at_set_req_timeout(req);
 
 	if (exp->exp_obd->obd_svc_stats)
diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index dff349f..0844318 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -209,7 +209,7 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt)
 				  OBD_CONNECT_GRANT_PARAM |
 				  OBD_CONNECT_SHORTIO | OBD_CONNECT_FLAGS2;
 
-	data->ocd_connect_flags2 = OBD_CONNECT2_FLR;
+	data->ocd_connect_flags2 = OBD_CONNECT2_FLR | OBD_CONNECT2_LOCK_CONVERT;
 
 	if (sbi->ll_flags & LL_SBI_LRU_RESIZE)
 		data->ocd_connect_flags |= OBD_CONNECT_LRU_RESIZE;
diff --git a/fs/lustre/llite/namei.c b/fs/lustre/llite/namei.c
index 8b1a1ca..f835abb 100644
--- a/fs/lustre/llite/namei.c
+++ b/fs/lustre/llite/namei.c
@@ -371,11 +371,16 @@ void ll_lock_cancel_bits(struct ldlm_lock *lock, u64 to_cancel)
  */
 int ll_md_need_convert(struct ldlm_lock *lock)
 {
+	struct ldlm_namespace *ns = ldlm_lock_to_ns(lock);
 	struct inode *inode;
 	u64 wanted = lock->l_policy_data.l_inodebits.cancel_bits;
 	u64 bits = lock->l_policy_data.l_inodebits.bits & ~wanted;
 	enum ldlm_mode mode = LCK_MINMODE;
 
+	if (!lock->l_conn_export ||
+	    !exp_connect_lock_convert(lock->l_conn_export))
+		return 0;
+
 	if (!wanted || !bits || ldlm_is_cancel(lock))
 		return 0;
 
@@ -410,7 +415,7 @@ int ll_md_need_convert(struct ldlm_lock *lock)
 	lock_res_and_lock(lock);
 	if (ktime_after(ktime_get(),
 			ktime_add(lock->l_last_used,
-				  ktime_set(10, 0)))) {
+				  ktime_set(ns->ns_dirty_age_limit, 0)))) {
 		unlock_res_and_lock(lock);
 		return 0;
 	}
-- 
1.8.3.1
