From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Thu,  1 Oct 2015 00:12:21 -0400
Subject: [lustre-devel] [PATCH 11/32] staging/lustre/ldlm: Get rid of
	lr_converting queue
In-Reply-To: <1443672762-982936-1-git-send-email-green@linuxhacker.ru>
References: <1443672762-982936-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1443672762-982936-12-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Oleg Drokin <green@linuxhacker.ru>

Now that we removed all the lock conversion functions,
also get rid of the converson queue since nothing could ever
get there anyway.

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/include/lustre_dlm.h |  2 --
 drivers/staging/lustre/lustre/ldlm/ldlm_lock.c     | 10 +---------
 drivers/staging/lustre/lustre/ldlm/ldlm_request.c  |  9 ---------
 drivers/staging/lustre/lustre/ldlm/ldlm_resource.c | 12 ------------
 4 files changed, 1 insertion(+), 32 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_dlm.h b/drivers/staging/lustre/lustre/include/lustre_dlm.h
index bea526b..40377b2 100644
--- a/drivers/staging/lustre/lustre/include/lustre_dlm.h
+++ b/drivers/staging/lustre/lustre/include/lustre_dlm.h
@@ -883,8 +883,6 @@ struct ldlm_resource {
 	 * @{ */
 	/** List of locks in granted state */
 	struct list_head		lr_granted;
-	/** List of locks waiting to change their granted mode (converted) */
-	struct list_head		lr_converting;
 	/**
 	 * List of locks that could not be granted due to conflicts and
 	 * that are waiting for conflicts to go away */
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
index 0597fec..7f9d3c1 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
@@ -1260,12 +1260,6 @@ ldlm_mode_t ldlm_lock_match(struct ldlm_namespace *ns, __u64 flags,
 		rc = 0;
 		goto out;
 	}
-	lock = search_queue(&res->lr_converting, &mode, policy, old_lock,
-			    flags, unref);
-	if (lock != NULL) {
-		rc = 1;
-		goto out;
-	}
 	lock = search_queue(&res->lr_waiting, &mode, policy, old_lock,
 			    flags, unref);
 	if (lock != NULL) {
@@ -1634,9 +1628,7 @@ ldlm_error_t ldlm_lock_enqueue(struct ldlm_namespace *ns,
 	 * FIXME (bug 268): Detect obvious lies by checking compatibility in
 	 * granted/converting queues. */
 	if (local) {
-		if (*flags & LDLM_FL_BLOCK_CONV)
-			ldlm_resource_add_lock(res, &res->lr_converting, lock);
-		else if (*flags & (LDLM_FL_BLOCK_WAIT | LDLM_FL_BLOCK_GRANTED))
+		if (*flags & (LDLM_FL_BLOCK_WAIT | LDLM_FL_BLOCK_GRANTED))
 			ldlm_resource_add_lock(res, &res->lr_waiting, lock);
 		else
 			ldlm_grant_lock(lock, NULL);
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
index 5bd66c3..760c745 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
@@ -1878,15 +1878,6 @@ int ldlm_resource_foreach(struct ldlm_resource *res, ldlm_iterator_t iter,
 		}
 	}
 
-	list_for_each_safe(tmp, next, &res->lr_converting) {
-		lock = list_entry(tmp, struct ldlm_lock, l_res_link);
-
-		if (iter(lock, closure) == LDLM_ITER_STOP) {
-			rc = LDLM_ITER_STOP;
-			goto out;
-		}
-	}
-
 	list_for_each_safe(tmp, next, &res->lr_waiting) {
 		lock = list_entry(tmp, struct ldlm_lock, l_res_link);
 
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c b/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
index cc212b9..dac2ec2 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
@@ -792,7 +792,6 @@ static int ldlm_resource_clean(struct cfs_hash *hs, struct cfs_hash_bd *bd,
 	__u64 flags = *(__u64 *)arg;
 
 	cleanup_resource(res, &res->lr_granted, flags);
-	cleanup_resource(res, &res->lr_converting, flags);
 	cleanup_resource(res, &res->lr_waiting, flags);
 
 	return 0;
@@ -1059,7 +1058,6 @@ static struct ldlm_resource *ldlm_resource_new(void)
 		return NULL;
 
 	INIT_LIST_HEAD(&res->lr_granted);
-	INIT_LIST_HEAD(&res->lr_converting);
 	INIT_LIST_HEAD(&res->lr_waiting);
 
 	/* Initialize interval trees for each lock mode. */
@@ -1224,11 +1222,6 @@ static void __ldlm_resource_putref_final(struct cfs_hash_bd *bd,
 		LBUG();
 	}
 
-	if (!list_empty(&res->lr_converting)) {
-		ldlm_resource_dump(D_ERROR, res);
-		LBUG();
-	}
-
 	if (!list_empty(&res->lr_waiting)) {
 		ldlm_resource_dump(D_ERROR, res);
 		LBUG();
@@ -1451,11 +1444,6 @@ void ldlm_resource_dump(int level, struct ldlm_resource *res)
 			}
 		}
 	}
-	if (!list_empty(&res->lr_converting)) {
-		CDEBUG(level, "Converting locks:\n");
-		list_for_each_entry(lock, &res->lr_converting, l_res_link)
-			LDLM_DEBUG_LIMIT(level, lock, "###");
-	}
 	if (!list_empty(&res->lr_waiting)) {
 		CDEBUG(level, "Waiting locks:\n");
 		list_for_each_entry(lock, &res->lr_waiting, l_res_link)
-- 
2.1.0
