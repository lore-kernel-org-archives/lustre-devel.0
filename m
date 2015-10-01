From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Thu,  1 Oct 2015 00:12:32 -0400
Subject: [lustre-devel] [PATCH 22/32] staging/lustre/ldlm: Remove intent
	policies handler.
In-Reply-To: <1443672762-982936-1-git-send-email-green@linuxhacker.ru>
References: <1443672762-982936-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1443672762-982936-23-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Oleg Drokin <green@linuxhacker.ru>

This includes ldlm_register_intent(), ns_policy field in the namespace
and all of it's users, as this could only happen on the server.

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/include/lustre_dlm.h |  8 --
 drivers/staging/lustre/lustre/ldlm/ldlm_lock.c     | 85 ++++------------------
 2 files changed, 13 insertions(+), 80 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_dlm.h b/drivers/staging/lustre/lustre/include/lustre_dlm.h
index 5a72f22..c0b2c61 100644
--- a/drivers/staging/lustre/lustre/include/lustre_dlm.h
+++ b/drivers/staging/lustre/lustre/include/lustre_dlm.h
@@ -271,10 +271,6 @@ struct ldlm_pool {
 	struct completion	 pl_kobj_unregister;
 };
 
-typedef int (*ldlm_res_policy)(struct ldlm_namespace *, struct ldlm_lock **,
-			       void *req_cookie, ldlm_mode_t mode, __u64 flags,
-			       void *data);
-
 typedef int (*ldlm_cancel_for_recovery)(struct ldlm_lock *lock);
 
 /**
@@ -427,9 +423,6 @@ struct ldlm_namespace {
 	 */
 	unsigned long		ns_next_dump;
 
-	/** "policy" function that does actual lock conflict determination */
-	ldlm_res_policy		ns_policy;
-
 	/**
 	 * LVB operations for this namespace.
 	 * \see struct ldlm_valblock_ops
@@ -1113,7 +1106,6 @@ void ldlm_put_ref(void);
 struct ldlm_lock *ldlm_request_lock(struct ptlrpc_request *req);
 
 /* ldlm_lock.c */
-void ldlm_register_intent(struct ldlm_namespace *ns, ldlm_res_policy arg);
 void ldlm_lock2handle(const struct ldlm_lock *lock,
 		      struct lustre_handle *lockh);
 struct ldlm_lock *__ldlm_handle2lock(const struct lustre_handle *, __u64 flags);
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
index 133936e..5a07669 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
@@ -151,13 +151,6 @@ char *ldlm_it2str(int it)
 }
 EXPORT_SYMBOL(ldlm_it2str);
 
-
-void ldlm_register_intent(struct ldlm_namespace *ns, ldlm_res_policy arg)
-{
-	ns->ns_policy = arg;
-}
-EXPORT_SYMBOL(ldlm_register_intent);
-
 /*
  * REFCOUNTED LOCK OBJECTS
  */
@@ -1532,13 +1525,11 @@ out:
 
 /**
  * Enqueue (request) a lock.
+ * On the client this is called from ldlm_cli_enqueue_fini
+ * after we already got an initial reply from the server with some status.
  *
  * Does not block. As a result of enqueue the lock would be put
  * into granted or waiting list.
- *
- * If namespace has intent policy sent and the lock has LDLM_FL_HAS_INTENT flag
- * set, skip all the enqueueing and delegate lock processing to intent policy
- * function.
  */
 ldlm_error_t ldlm_lock_enqueue(struct ldlm_namespace *ns,
 			       struct ldlm_lock **lockp,
@@ -1546,43 +1537,12 @@ ldlm_error_t ldlm_lock_enqueue(struct ldlm_namespace *ns,
 {
 	struct ldlm_lock *lock = *lockp;
 	struct ldlm_resource *res = lock->l_resource;
-	int local = ns_is_client(ldlm_res_to_ns(res));
 	ldlm_error_t rc = ELDLM_OK;
-	struct ldlm_interval *node = NULL;
 
 	lock->l_last_activity = ktime_get_real_seconds();
-	/* policies are not executed on the client or during replay */
-	if ((*flags & (LDLM_FL_HAS_INTENT|LDLM_FL_REPLAY)) == LDLM_FL_HAS_INTENT
-	    && !local && ns->ns_policy) {
-		rc = ns->ns_policy(ns, lockp, cookie, lock->l_req_mode, *flags,
-				   NULL);
-		if (rc == ELDLM_LOCK_REPLACED) {
-			/* The lock that was returned has already been granted,
-			 * and placed into lockp.  If it's not the same as the
-			 * one we passed in, then destroy the old one and our
-			 * work here is done. */
-			if (lock != *lockp) {
-				ldlm_lock_destroy(lock);
-				LDLM_LOCK_RELEASE(lock);
-			}
-			*flags |= LDLM_FL_LOCK_CHANGED;
-			return 0;
-		} else if (rc != ELDLM_OK ||
-			   (rc == ELDLM_OK && (*flags & LDLM_FL_INTENT_ONLY))) {
-			ldlm_lock_destroy(lock);
-			return rc;
-		}
-	}
-
-	/* For a replaying lock, it might be already in granted list. So
-	 * unlinking the lock will cause the interval node to be freed, we
-	 * have to allocate the interval node early otherwise we can't regrant
-	 * this lock in the future. - jay */
-	if (!local && (*flags & LDLM_FL_REPLAY) && res->lr_type == LDLM_EXTENT)
-		OBD_SLAB_ALLOC_PTR_GFP(node, ldlm_interval_slab, GFP_NOFS);
 
 	lock_res_and_lock(lock);
-	if (local && lock->l_req_mode == lock->l_granted_mode) {
+	if (lock->l_req_mode == lock->l_granted_mode) {
 		/* The server returned a blocked lock, but it was granted
 		 * before we got a chance to actually enqueue it.  We don't
 		 * need to do anything else. */
@@ -1592,48 +1552,29 @@ ldlm_error_t ldlm_lock_enqueue(struct ldlm_namespace *ns,
 	}
 
 	ldlm_resource_unlink_lock(lock);
-	if (res->lr_type == LDLM_EXTENT && lock->l_tree_node == NULL) {
-		if (node == NULL) {
-			ldlm_lock_destroy_nolock(lock);
-			rc = -ENOMEM;
-			goto out;
-		}
 
-		INIT_LIST_HEAD(&node->li_group);
-		ldlm_interval_attach(node, lock);
-		node = NULL;
-	}
+	/* Cannot happen unless on the server */
+	if (res->lr_type == LDLM_EXTENT && !lock->l_tree_node)
+		LBUG();
 
 	/* Some flags from the enqueue want to make it into the AST, via the
 	 * lock's l_flags. */
 	lock->l_flags |= *flags & LDLM_FL_AST_DISCARD_DATA;
 
-	/* This distinction between local lock trees is very important; a client
+	/*
+	 * This distinction between local lock trees is very important; a client
 	 * namespace only has information about locks taken by that client, and
 	 * thus doesn't have enough information to decide for itself if it can
 	 * be granted (below).  In this case, we do exactly what the server
 	 * tells us to do, as dictated by the 'flags'.
-	 *
-	 * We do exactly the same thing during recovery, when the server is
-	 * more or less trusting the clients not to lie.
-	 *
-	 * FIXME (bug 268): Detect obvious lies by checking compatibility in
-	 * granted/converting queues. */
-	if (local) {
-		if (*flags & (LDLM_FL_BLOCK_WAIT | LDLM_FL_BLOCK_GRANTED))
-			ldlm_resource_add_lock(res, &res->lr_waiting, lock);
-		else
-			ldlm_grant_lock(lock, NULL);
-		goto out;
-	} else {
-		CERROR("This is client-side-only module, cannot handle LDLM_NAMESPACE_SERVER resource type lock.\n");
-		LBUG();
-	}
+	 */
+	if (*flags & (LDLM_FL_BLOCK_WAIT | LDLM_FL_BLOCK_GRANTED))
+		ldlm_resource_add_lock(res, &res->lr_waiting, lock);
+	else
+		ldlm_grant_lock(lock, NULL);
 
 out:
 	unlock_res_and_lock(lock);
-	if (node)
-		OBD_SLAB_FREE(node, ldlm_interval_slab, sizeof(*node));
 	return rc;
 }
 
-- 
2.1.0
