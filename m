From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Thu,  1 Oct 2015 00:12:34 -0400
Subject: [lustre-devel] [PATCH 24/32] staging/lustre/ldlm: Remove unused
	ldlm_resource_insert_lock_after()
In-Reply-To: <1443672762-982936-1-git-send-email-green@linuxhacker.ru>
References: <1443672762-982936-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1443672762-982936-25-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Oleg Drokin <green@linuxhacker.ru>

It was only used on the server.

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/ldlm/ldlm_internal.h |  2 --
 drivers/staging/lustre/lustre/ldlm/ldlm_resource.c | 26 ----------------------
 2 files changed, 28 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h b/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h
index 1293f13..56805d0 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h
@@ -116,8 +116,6 @@ int ldlm_get_enq_timeout(struct ldlm_lock *lock);
 
 /* ldlm_resource.c */
 int ldlm_resource_putref_locked(struct ldlm_resource *res);
-void ldlm_resource_insert_lock_after(struct ldlm_lock *original,
-				     struct ldlm_lock *new);
 void ldlm_namespace_free_prior(struct ldlm_namespace *ns,
 			       struct obd_import *imp, int force);
 void ldlm_namespace_free_post(struct ldlm_namespace *ns);
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c b/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
index cd65efe..9906372 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
@@ -1281,32 +1281,6 @@ void ldlm_resource_add_lock(struct ldlm_resource *res, struct list_head *head,
 	list_add_tail(&lock->l_res_link, head);
 }
 
-/**
- * Insert a lock into resource after specified lock.
- *
- * Obtain resource description from the lock we are inserting after.
- */
-void ldlm_resource_insert_lock_after(struct ldlm_lock *original,
-				     struct ldlm_lock *new)
-{
-	struct ldlm_resource *res = original->l_resource;
-
-	check_res_locked(res);
-
-	ldlm_resource_dump(D_INFO, res);
-	LDLM_DEBUG(new, "About to insert this lock after %p:\n", original);
-
-	if (new->l_flags & LDLM_FL_DESTROYED) {
-		CDEBUG(D_OTHER, "Lock destroyed, not adding to resource\n");
-		goto out;
-	}
-
-	LASSERT(list_empty(&new->l_res_link));
-
-	list_add(&new->l_res_link, &original->l_res_link);
- out:;
-}
-
 void ldlm_resource_unlink_lock(struct ldlm_lock *lock)
 {
 	int type = lock->l_resource->lr_type;
-- 
2.1.0
