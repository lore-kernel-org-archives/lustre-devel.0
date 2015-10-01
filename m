From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Thu,  1 Oct 2015 00:12:23 -0400
Subject: [lustre-devel] [PATCH 13/32] staging/lustre/ldlm: Remove unused
	ldlm_init/fini_flock_export
In-Reply-To: <1443672762-982936-1-git-send-email-green@linuxhacker.ru>
References: <1443672762-982936-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1443672762-982936-14-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Oleg Drokin <green@linuxhacker.ru>

And all supporting export infrastructure. There's no use for it
all on client.

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/ldlm/ldlm_flock.c    | 102 ---------------------
 drivers/staging/lustre/lustre/ldlm/ldlm_internal.h |   2 -
 2 files changed, 104 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c b/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c
index ab670fc..bb8ecc8 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c
@@ -755,105 +755,3 @@ void ldlm_flock_policy_local_to_wire(const ldlm_policy_data_t *lpolicy,
 	wpolicy->l_flock.lfw_pid = lpolicy->l_flock.pid;
 	wpolicy->l_flock.lfw_owner = lpolicy->l_flock.owner;
 }
-
-/*
- * Export handle<->flock hash operations.
- */
-static unsigned
-ldlm_export_flock_hash(struct cfs_hash *hs, const void *key, unsigned mask)
-{
-	return cfs_hash_u64_hash(*(__u64 *)key, mask);
-}
-
-static void *
-ldlm_export_flock_key(struct hlist_node *hnode)
-{
-	struct ldlm_lock *lock;
-
-	lock = hlist_entry(hnode, struct ldlm_lock, l_exp_flock_hash);
-	return &lock->l_policy_data.l_flock.owner;
-}
-
-static int
-ldlm_export_flock_keycmp(const void *key, struct hlist_node *hnode)
-{
-	return !memcmp(ldlm_export_flock_key(hnode), key, sizeof(__u64));
-}
-
-static void *
-ldlm_export_flock_object(struct hlist_node *hnode)
-{
-	return hlist_entry(hnode, struct ldlm_lock, l_exp_flock_hash);
-}
-
-static void
-ldlm_export_flock_get(struct cfs_hash *hs, struct hlist_node *hnode)
-{
-	struct ldlm_lock *lock;
-	struct ldlm_flock *flock;
-
-	lock = hlist_entry(hnode, struct ldlm_lock, l_exp_flock_hash);
-	LDLM_LOCK_GET(lock);
-
-	flock = &lock->l_policy_data.l_flock;
-	LASSERT(flock->blocking_export != NULL);
-	class_export_get(flock->blocking_export);
-	flock->blocking_refs++;
-}
-
-static void
-ldlm_export_flock_put(struct cfs_hash *hs, struct hlist_node *hnode)
-{
-	struct ldlm_lock *lock;
-	struct ldlm_flock *flock;
-
-	lock = hlist_entry(hnode, struct ldlm_lock, l_exp_flock_hash);
-	LDLM_LOCK_RELEASE(lock);
-
-	flock = &lock->l_policy_data.l_flock;
-	LASSERT(flock->blocking_export != NULL);
-	class_export_put(flock->blocking_export);
-	if (--flock->blocking_refs == 0) {
-		flock->blocking_owner = 0;
-		flock->blocking_export = NULL;
-	}
-}
-
-static cfs_hash_ops_t ldlm_export_flock_ops = {
-	.hs_hash	= ldlm_export_flock_hash,
-	.hs_key	 = ldlm_export_flock_key,
-	.hs_keycmp      = ldlm_export_flock_keycmp,
-	.hs_object      = ldlm_export_flock_object,
-	.hs_get	 = ldlm_export_flock_get,
-	.hs_put	 = ldlm_export_flock_put,
-	.hs_put_locked  = ldlm_export_flock_put,
-};
-
-int ldlm_init_flock_export(struct obd_export *exp)
-{
-	if (strcmp(exp->exp_obd->obd_type->typ_name, LUSTRE_MDT_NAME) != 0)
-		return 0;
-
-	exp->exp_flock_hash =
-		cfs_hash_create(obd_uuid2str(&exp->exp_client_uuid),
-				HASH_EXP_LOCK_CUR_BITS,
-				HASH_EXP_LOCK_MAX_BITS,
-				HASH_EXP_LOCK_BKT_BITS, 0,
-				CFS_HASH_MIN_THETA, CFS_HASH_MAX_THETA,
-				&ldlm_export_flock_ops,
-				CFS_HASH_DEFAULT | CFS_HASH_NBLK_CHANGE);
-	if (!exp->exp_flock_hash)
-		return -ENOMEM;
-
-	return 0;
-}
-EXPORT_SYMBOL(ldlm_init_flock_export);
-
-void ldlm_destroy_flock_export(struct obd_export *exp)
-{
-	if (exp->exp_flock_hash) {
-		cfs_hash_putref(exp->exp_flock_hash);
-		exp->exp_flock_hash = NULL;
-	}
-}
-EXPORT_SYMBOL(ldlm_destroy_flock_export);
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h b/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h
index e870b3e..1293f13 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h
@@ -188,8 +188,6 @@ void ldlm_extent_unlink_lock(struct ldlm_lock *lock);
 int ldlm_process_flock_lock(struct ldlm_lock *req, __u64 *flags,
 			    int first_enq, ldlm_error_t *err,
 			    struct list_head *work_list);
-int ldlm_init_flock_export(struct obd_export *exp);
-void ldlm_destroy_flock_export(struct obd_export *exp);
 
 /* l_lock.c */
 void l_check_ns_lock(struct ldlm_namespace *ns);
-- 
2.1.0
