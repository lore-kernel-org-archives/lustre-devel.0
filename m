From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Thu,  1 Oct 2015 00:12:33 -0400
Subject: [lustre-devel] [PATCH 23/32] staging/lustre/ldlm: Remove unused
	ldlm_reprocess_all*()
In-Reply-To: <1443672762-982936-1-git-send-email-green@linuxhacker.ru>
References: <1443672762-982936-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1443672762-982936-24-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Oleg Drokin <green@linuxhacker.ru>

They are only used on the server.
Also remove helper functions and cleanup callsites.

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/include/lustre_dlm.h |  2 -
 drivers/staging/lustre/lustre/ldlm/ldlm_flock.c    |  1 -
 drivers/staging/lustre/lustre/ldlm/ldlm_lock.c     | 48 ----------------------
 drivers/staging/lustre/lustre/ldlm/ldlm_request.c  |  4 --
 4 files changed, 55 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_dlm.h b/drivers/staging/lustre/lustre/include/lustre_dlm.h
index c0b2c61..9608373 100644
--- a/drivers/staging/lustre/lustre/include/lustre_dlm.h
+++ b/drivers/staging/lustre/lustre/include/lustre_dlm.h
@@ -1215,8 +1215,6 @@ ldlm_mode_t ldlm_lock_match(struct ldlm_namespace *ns, __u64 flags,
 ldlm_mode_t ldlm_revalidate_lock_handle(struct lustre_handle *lockh,
 					__u64 *bits);
 void ldlm_lock_cancel(struct ldlm_lock *lock);
-void ldlm_reprocess_all(struct ldlm_resource *res);
-void ldlm_reprocess_all_ns(struct ldlm_namespace *ns);
 void ldlm_lock_dump_handle(int level, struct lustre_handle *);
 void ldlm_unlink_lock_skiplist(struct ldlm_lock *req);
 
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c b/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c
index bb8ecc8..14e6782 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c
@@ -523,7 +523,6 @@ reprocess:
 	/* At this point we're granting the lock request. */
 	req->l_granted_mode = req->l_req_mode;
 
-	/* Add req to the granted queue before calling ldlm_reprocess_all(). */
 	if (!added) {
 		list_del_init(&req->l_res_link);
 		/* insert new lock before ownlocks in list. */
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
index 5a07669..e586d33 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
@@ -1786,54 +1786,6 @@ out:
 	return rc;
 }
 
-static int reprocess_one_queue(struct ldlm_resource *res, void *closure)
-{
-	ldlm_reprocess_all(res);
-	return LDLM_ITER_CONTINUE;
-}
-
-static int ldlm_reprocess_res(struct cfs_hash *hs, struct cfs_hash_bd *bd,
-			      struct hlist_node *hnode, void *arg)
-{
-	struct ldlm_resource *res = cfs_hash_object(hs, hnode);
-	int    rc;
-
-	rc = reprocess_one_queue(res, arg);
-
-	return rc == LDLM_ITER_STOP;
-}
-
-/**
- * Iterate through all resources on a namespace attempting to grant waiting
- * locks.
- */
-void ldlm_reprocess_all_ns(struct ldlm_namespace *ns)
-{
-	if (ns != NULL) {
-		cfs_hash_for_each_nolock(ns->ns_rs_hash,
-					 ldlm_reprocess_res, NULL);
-	}
-}
-EXPORT_SYMBOL(ldlm_reprocess_all_ns);
-
-/**
- * Try to grant all waiting locks on a resource.
- *
- * Calls ldlm_reprocess_queue on converting and waiting queues.
- *
- * Typically called after some resource locks are cancelled to see
- * if anything could be granted as a result of the cancellation.
- */
-void ldlm_reprocess_all(struct ldlm_resource *res)
-{
-	LIST_HEAD(rpc_list);
-
-	if (!ns_is_client(ldlm_res_to_ns(res))) {
-		CERROR("This is client-side-only module, cannot handle LDLM_NAMESPACE_SERVER resource type lock.\n");
-		LBUG();
-	}
-}
-
 /**
  * Helper function to call blocking AST for LDLM lock \a lock in a
  * "cancelling" mode.
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
index a9159fd..15e1980 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
@@ -188,7 +188,6 @@ int ldlm_completion_ast_async(struct ldlm_lock *lock, __u64 flags, void *data)
 	}
 
 	LDLM_DEBUG(lock, "client-side enqueue returned a blocked lock, going forward");
-	ldlm_reprocess_all(lock->l_resource);
 	return 0;
 }
 EXPORT_SYMBOL(ldlm_completion_ast_async);
@@ -892,9 +891,6 @@ static __u64 ldlm_cli_cancel_local(struct ldlm_lock *lock)
 			LDLM_ERROR(lock, "Trying to cancel local lock");
 			LBUG();
 		}
-		LDLM_DEBUG(lock, "server-side local cancel");
-		ldlm_lock_cancel(lock);
-		ldlm_reprocess_all(lock->l_resource);
 	}
 
 	return rc;
-- 
2.1.0
