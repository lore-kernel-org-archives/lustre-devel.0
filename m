From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Thu,  1 Oct 2015 00:12:18 -0400
Subject: [lustre-devel] [PATCH 08/32] staging/lustre/ldlm: Remove unused
	ldlm_cancel_locks_for_exports()
In-Reply-To: <1443672762-982936-1-git-send-email-green@linuxhacker.ru>
References: <1443672762-982936-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1443672762-982936-9-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Oleg Drokin <green@linuxhacker.ru>

This is only used on the server in case a client gets disconnected.

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/ldlm/ldlm_internal.h |  2 -
 drivers/staging/lustre/lustre/ldlm/ldlm_lock.c     | 50 ----------------------
 2 files changed, 52 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h b/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h
index fa4b7c7..e870b3e 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h
@@ -164,8 +164,6 @@ void ldlm_lock_add_to_lru(struct ldlm_lock *lock);
 void ldlm_lock_touch_in_lru(struct ldlm_lock *lock);
 void ldlm_lock_destroy_nolock(struct ldlm_lock *lock);
 
-void ldlm_cancel_locks_for_export(struct obd_export *export);
-
 /* ldlm_lockd.c */
 int ldlm_bl_to_thread_lock(struct ldlm_namespace *ns, struct ldlm_lock_desc *ld,
 			   struct ldlm_lock *lock);
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
index 12eb5ac..b257b89 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
@@ -2012,56 +2012,6 @@ struct export_cl_data {
 };
 
 /**
- * Iterator function for ldlm_cancel_locks_for_export.
- * Cancels passed locks.
- */
-int ldlm_cancel_locks_for_export_cb(struct cfs_hash *hs, struct cfs_hash_bd *bd,
-				    struct hlist_node *hnode, void *data)
-
-{
-	struct export_cl_data	*ecl = (struct export_cl_data *)data;
-	struct obd_export	*exp  = ecl->ecl_exp;
-	struct ldlm_lock     *lock = cfs_hash_object(hs, hnode);
-	struct ldlm_resource *res;
-
-	res = ldlm_resource_getref(lock->l_resource);
-	LDLM_LOCK_GET(lock);
-
-	LDLM_DEBUG(lock, "export %p", exp);
-	ldlm_res_lvbo_update(res, NULL, 1);
-	ldlm_lock_cancel(lock);
-	ldlm_reprocess_all(res);
-	ldlm_resource_putref(res);
-	LDLM_LOCK_RELEASE(lock);
-
-	ecl->ecl_loop++;
-	if ((ecl->ecl_loop & -ecl->ecl_loop) == ecl->ecl_loop) {
-		CDEBUG(D_INFO,
-		       "Cancel lock %p for export %p (loop %d), still have %d locks left on hash table.\n",
-		       lock, exp, ecl->ecl_loop,
-		       atomic_read(&hs->hs_count));
-	}
-
-	return 0;
-}
-
-/**
- * Cancel all locks for given export.
- *
- * Typically called on client disconnection/eviction
- */
-void ldlm_cancel_locks_for_export(struct obd_export *exp)
-{
-	struct export_cl_data	ecl = {
-		.ecl_exp	= exp,
-		.ecl_loop	= 0,
-	};
-
-	cfs_hash_for_each_empty(exp->exp_lock_hash,
-				ldlm_cancel_locks_for_export_cb, &ecl);
-}
-
-/**
  * Downgrade an exclusive lock.
  *
  * A fast variant of ldlm_lock_convert for conversion of exclusive
-- 
2.1.0
