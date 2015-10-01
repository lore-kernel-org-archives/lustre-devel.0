From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Thu,  1 Oct 2015 00:12:36 -0400
Subject: [lustre-devel] [PATCH 26/32] staging/lustre: Remove ns_is_client()
In-Reply-To: <1443672762-982936-1-git-send-email-green@linuxhacker.ru>
References: <1443672762-982936-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1443672762-982936-27-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Oleg Drokin <green@linuxhacker.ru>

Since staging tree code is just the client, ns_is_client is always
true, so change all callers as such and drop all the
dead code for when it's false.

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/include/lustre_dlm.h | 13 ----------
 drivers/staging/lustre/lustre/ldlm/ldlm_flock.c    | 28 +++------------------
 drivers/staging/lustre/lustre/ldlm/ldlm_lock.c     |  5 +---
 drivers/staging/lustre/lustre/ldlm/ldlm_request.c  |  9 +++----
 drivers/staging/lustre/lustre/ldlm/ldlm_resource.c | 29 ++++++++--------------
 5 files changed, 17 insertions(+), 67 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_dlm.h b/drivers/staging/lustre/lustre/include/lustre_dlm.h
index 360c7f7..1e40203 100644
--- a/drivers/staging/lustre/lustre/include/lustre_dlm.h
+++ b/drivers/staging/lustre/lustre/include/lustre_dlm.h
@@ -465,19 +465,6 @@ struct ldlm_namespace {
 };
 
 /**
- * Returns 1 if namespace \a ns is a client namespace.
- */
-static inline int ns_is_client(struct ldlm_namespace *ns)
-{
-	LASSERT(ns != NULL);
-	LASSERT(!(ns->ns_client & ~(LDLM_NAMESPACE_CLIENT |
-				    LDLM_NAMESPACE_SERVER)));
-	LASSERT(ns->ns_client == LDLM_NAMESPACE_CLIENT ||
-		ns->ns_client == LDLM_NAMESPACE_SERVER);
-	return ns->ns_client == LDLM_NAMESPACE_CLIENT;
-}
-
-/**
  * Returns 1 if namespace \a ns is a server namespace.
  */
 static inline int ns_is_server(struct ldlm_namespace *ns)
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c b/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c
index 14e6782..7241c34 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c
@@ -63,9 +63,6 @@
 #include <linux/list.h>
 #include "ldlm_internal.h"
 
-int ldlm_flock_blocking_ast(struct ldlm_lock *lock, struct ldlm_lock_desc *desc,
-			    void *data, int flag);
-
 /**
  * list_for_remaining_safe - iterate over the remaining entries in a list
  *	      and safeguard against removal of a list entry.
@@ -254,7 +251,6 @@ ldlm_process_flock_lock(struct ldlm_lock *req, __u64 *flags, int first_enq,
 	struct ldlm_lock *new = req;
 	struct ldlm_lock *new2 = NULL;
 	ldlm_mode_t mode = req->l_req_mode;
-	int local = ns_is_client(ns);
 	int added = (mode == LCK_NL);
 	int overlaps = 0;
 	int splitted = 0;
@@ -269,14 +265,9 @@ ldlm_process_flock_lock(struct ldlm_lock *req, __u64 *flags, int first_enq,
 
 	*err = ELDLM_OK;
 
-	if (local) {
-		/* No blocking ASTs are sent to the clients for
-		 * Posix file & record locks */
-		req->l_blocking_ast = NULL;
-	} else {
-		/* Called on the server for lock cancels. */
-		req->l_blocking_ast = ldlm_flock_blocking_ast;
-	}
+	/* No blocking ASTs are sent to the clients for
+	 * Posix file & record locks */
+	req->l_blocking_ast = NULL;
 
 reprocess:
 	if ((*flags == LDLM_FL_WAIT_NOREPROC) || (mode == LCK_NL)) {
@@ -708,19 +699,6 @@ granted:
 }
 EXPORT_SYMBOL(ldlm_flock_completion_ast);
 
-int ldlm_flock_blocking_ast(struct ldlm_lock *lock, struct ldlm_lock_desc *desc,
-			    void *data, int flag)
-{
-	LASSERT(lock);
-	LASSERT(flag == LDLM_CB_CANCELING);
-
-	/* take lock off the deadlock detection hash list. */
-	lock_res_and_lock(lock);
-	ldlm_flock_blocking_unlink(lock);
-	unlock_res_and_lock(lock);
-	return 0;
-}
-
 void ldlm_flock_policy_wire18_to_local(const ldlm_wire_policy_data_t *wpolicy,
 				       ldlm_policy_data_t *lpolicy)
 {
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
index e586d33..6d5e7af 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
@@ -480,8 +480,6 @@ int ldlm_lock_change_resource(struct ldlm_namespace *ns, struct ldlm_lock *lock,
 	struct ldlm_resource *newres;
 	int type;
 
-	LASSERT(ns_is_client(ns));
-
 	lock_res_and_lock(lock);
 	if (memcmp(new_resid, &lock->l_resource->lr_name,
 		   sizeof(lock->l_resource->lr_name)) == 0) {
@@ -816,8 +814,7 @@ void ldlm_lock_decref_internal(struct ldlm_lock *lock, __u32 mode)
 		if ((lock->l_flags & LDLM_FL_ATOMIC_CB) ||
 		    ldlm_bl_to_thread_lock(ns, NULL, lock) != 0)
 			ldlm_handle_bl_callback(ns, NULL, lock);
-	} else if (ns_is_client(ns) &&
-		   !lock->l_readers && !lock->l_writers &&
+	} else if (!lock->l_readers && !lock->l_writers &&
 		   !(lock->l_flags & LDLM_FL_NO_LRU) &&
 		   !(lock->l_flags & LDLM_FL_BL_AST)) {
 
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
index 2d28fc2..04f4144 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
@@ -266,8 +266,7 @@ noreproc:
 		spin_unlock(&imp->imp_lock);
 	}
 
-	if (ns_is_client(ldlm_lock_to_ns(lock)) &&
-	    OBD_FAIL_CHECK_RESET(OBD_FAIL_LDLM_INTR_CP_AST,
+	if (OBD_FAIL_CHECK_RESET(OBD_FAIL_LDLM_INTR_CP_AST,
 				 OBD_FAIL_LDLM_CP_BL_RACE | OBD_FAIL_ONCE)) {
 		lock->l_flags |= LDLM_FL_FAIL_LOC;
 		rc = -EINTR;
@@ -817,10 +816,8 @@ static __u64 ldlm_cli_cancel_local(struct ldlm_lock *lock)
 		}
 		ldlm_lock_cancel(lock);
 	} else {
-		if (ns_is_client(ldlm_lock_to_ns(lock))) {
-			LDLM_ERROR(lock, "Trying to cancel local lock");
-			LBUG();
-		}
+		LDLM_ERROR(lock, "Trying to cancel local lock");
+		LBUG();
 	}
 
 	return rc;
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c b/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
index 9906372..402fe60 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
@@ -718,11 +718,12 @@ static void cleanup_resource(struct ldlm_resource *res, struct list_head *q,
 			     __u64 flags)
 {
 	struct list_head *tmp;
-	int rc = 0, client = ns_is_client(ldlm_res_to_ns(res));
+	int rc = 0;
 	bool local_only = !!(flags & LDLM_FL_LOCAL_ONLY);
 
 	do {
 		struct ldlm_lock *lock = NULL;
+		struct lustre_handle lockh;
 
 		/* First, we look for non-cleaned-yet lock
 		 * all cleaned locks are marked by CLEANED flag. */
@@ -767,20 +768,11 @@ static void cleanup_resource(struct ldlm_resource *res, struct list_head *q,
 			continue;
 		}
 
-		if (client) {
-			struct lustre_handle lockh;
-
-			unlock_res(res);
-			ldlm_lock2handle(lock, &lockh);
-			rc = ldlm_cli_cancel(&lockh, LCF_ASYNC);
-			if (rc)
-				CERROR("ldlm_cli_cancel: %d\n", rc);
-		} else {
-			ldlm_resource_unlink_lock(lock);
-			unlock_res(res);
-			LDLM_DEBUG(lock, "Freeing a lock still held by a client node");
-			ldlm_lock_destroy(lock);
-		}
+		unlock_res(res);
+		ldlm_lock2handle(lock, &lockh);
+		rc = ldlm_cli_cancel(&lockh, LCF_ASYNC);
+		if (rc)
+			CERROR("ldlm_cli_cancel: %d\n", rc);
 		LDLM_LOCK_RELEASE(lock);
 	} while (1);
 }
@@ -1165,7 +1157,7 @@ ldlm_resource_get(struct ldlm_namespace *ns, struct ldlm_resource *parent,
 	 * namespace. If so, and this is a client namespace, we need to move
 	 * the namespace into the active namespaces list to be patrolled by
 	 * the ldlm_poold. */
-	if (ns_is_client(ns) && ns_refcount == 1) {
+	if (ns_refcount == 1) {
 		mutex_lock(ldlm_namespace_lock(LDLM_NAMESPACE_CLIENT));
 		ldlm_namespace_move_to_active_locked(ns, LDLM_NAMESPACE_CLIENT);
 		mutex_unlock(ldlm_namespace_lock(LDLM_NAMESPACE_CLIENT));
@@ -1346,9 +1338,8 @@ void ldlm_namespace_dump(int level, struct ldlm_namespace *ns)
 	if (!((libcfs_debug | D_ERROR) & level))
 		return;
 
-	CDEBUG(level, "--- Namespace: %s (rc: %d, side: %s)\n",
-	       ldlm_ns_name(ns), atomic_read(&ns->ns_bref),
-	       ns_is_client(ns) ? "client" : "server");
+	CDEBUG(level, "--- Namespace: %s (rc: %d, side: client)\n",
+	       ldlm_ns_name(ns), atomic_read(&ns->ns_bref));
 
 	if (time_before(cfs_time_current(), ns->ns_next_dump))
 		return;
-- 
2.1.0
