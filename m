From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Thu,  1 Oct 2015 00:12:19 -0400
Subject: [lustre-devel] [PATCH 09/32] staging/lustre/ldlm: Remove
	ldlm_init/destroy_export()
In-Reply-To: <1443672762-982936-1-git-send-email-green@linuxhacker.ru>
References: <1443672762-982936-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1443672762-982936-10-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Oleg Drokin <green@linuxhacker.ru>

These functions are used on the server-only, so get rid of them.
Also get rid of ldlm export hash operations and the struct.

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/include/lustre_dlm.h |   2 -
 drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c    | 105 ---------------------
 2 files changed, 107 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_dlm.h b/drivers/staging/lustre/lustre/include/lustre_dlm.h
index 1ac08e1..03eea32 100644
--- a/drivers/staging/lustre/lustre/include/lustre_dlm.h
+++ b/drivers/staging/lustre/lustre/include/lustre_dlm.h
@@ -1114,8 +1114,6 @@ int ldlm_del_waiting_lock(struct ldlm_lock *lock);
 int ldlm_refresh_waiting_lock(struct ldlm_lock *lock, int timeout);
 int ldlm_get_ref(void);
 void ldlm_put_ref(void);
-int ldlm_init_export(struct obd_export *exp);
-void ldlm_destroy_export(struct obd_export *exp);
 struct ldlm_lock *ldlm_request_lock(struct ptlrpc_request *req);
 
 /* ldlm_lock.c */
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
index a78c4a4..57f6128 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
@@ -887,111 +887,6 @@ void ldlm_put_ref(void)
 }
 EXPORT_SYMBOL(ldlm_put_ref);
 
-/*
- * Export handle<->lock hash operations.
- */
-static unsigned
-ldlm_export_lock_hash(struct cfs_hash *hs, const void *key, unsigned mask)
-{
-	return cfs_hash_u64_hash(((struct lustre_handle *)key)->cookie, mask);
-}
-
-static void *
-ldlm_export_lock_key(struct hlist_node *hnode)
-{
-	struct ldlm_lock *lock;
-
-	lock = hlist_entry(hnode, struct ldlm_lock, l_exp_hash);
-	return &lock->l_remote_handle;
-}
-
-static void
-ldlm_export_lock_keycpy(struct hlist_node *hnode, void *key)
-{
-	struct ldlm_lock     *lock;
-
-	lock = hlist_entry(hnode, struct ldlm_lock, l_exp_hash);
-	lock->l_remote_handle = *(struct lustre_handle *)key;
-}
-
-static int
-ldlm_export_lock_keycmp(const void *key, struct hlist_node *hnode)
-{
-	return lustre_handle_equal(ldlm_export_lock_key(hnode), key);
-}
-
-static void *
-ldlm_export_lock_object(struct hlist_node *hnode)
-{
-	return hlist_entry(hnode, struct ldlm_lock, l_exp_hash);
-}
-
-static void
-ldlm_export_lock_get(struct cfs_hash *hs, struct hlist_node *hnode)
-{
-	struct ldlm_lock *lock;
-
-	lock = hlist_entry(hnode, struct ldlm_lock, l_exp_hash);
-	LDLM_LOCK_GET(lock);
-}
-
-static void
-ldlm_export_lock_put(struct cfs_hash *hs, struct hlist_node *hnode)
-{
-	struct ldlm_lock *lock;
-
-	lock = hlist_entry(hnode, struct ldlm_lock, l_exp_hash);
-	LDLM_LOCK_RELEASE(lock);
-}
-
-static cfs_hash_ops_t ldlm_export_lock_ops = {
-	.hs_hash	= ldlm_export_lock_hash,
-	.hs_key	 = ldlm_export_lock_key,
-	.hs_keycmp      = ldlm_export_lock_keycmp,
-	.hs_keycpy      = ldlm_export_lock_keycpy,
-	.hs_object      = ldlm_export_lock_object,
-	.hs_get	 = ldlm_export_lock_get,
-	.hs_put	 = ldlm_export_lock_put,
-	.hs_put_locked  = ldlm_export_lock_put,
-};
-
-int ldlm_init_export(struct obd_export *exp)
-{
-	int rc;
-
-	exp->exp_lock_hash =
-		cfs_hash_create(obd_uuid2str(&exp->exp_client_uuid),
-				HASH_EXP_LOCK_CUR_BITS,
-				HASH_EXP_LOCK_MAX_BITS,
-				HASH_EXP_LOCK_BKT_BITS, 0,
-				CFS_HASH_MIN_THETA, CFS_HASH_MAX_THETA,
-				&ldlm_export_lock_ops,
-				CFS_HASH_DEFAULT | CFS_HASH_REHASH_KEY |
-				CFS_HASH_NBLK_CHANGE);
-
-	if (!exp->exp_lock_hash)
-		return -ENOMEM;
-
-	rc = ldlm_init_flock_export(exp);
-	if (rc)
-		goto err;
-
-	return 0;
-err:
-	ldlm_destroy_export(exp);
-	return rc;
-}
-EXPORT_SYMBOL(ldlm_init_export);
-
-void ldlm_destroy_export(struct obd_export *exp)
-{
-	cfs_hash_putref(exp->exp_lock_hash);
-	exp->exp_lock_hash = NULL;
-
-	ldlm_destroy_flock_export(exp);
-}
-EXPORT_SYMBOL(ldlm_destroy_export);
-
 extern unsigned int ldlm_cancel_unused_locks_before_replay;
 
 static ssize_t cancel_unused_locks_before_replay_show(struct kobject *kobj,
-- 
2.1.0
