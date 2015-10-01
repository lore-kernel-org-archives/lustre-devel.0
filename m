From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Thu,  1 Oct 2015 00:12:37 -0400
Subject: [lustre-devel] [PATCH 27/32] staging/lustre: Remove ns_is_server()
In-Reply-To: <1443672762-982936-1-git-send-email-green@linuxhacker.ru>
References: <1443672762-982936-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1443672762-982936-28-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Oleg Drokin <green@linuxhacker.ru>

Since the code we have is Lustre-client only, this function
always returns 0, so drop it and amend all the callsites to
drop dead code.
One of the places also sets LDLM_FL_NS_SRV to indicate a lock
is in a server namespace. This too cannot happen in this code,
so drop all such checks as well.

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/include/lustre_dlm.h | 13 -------------
 drivers/staging/lustre/lustre/ldlm/l_lock.c        |  7 ++-----
 drivers/staging/lustre/lustre/ldlm/ldlm_lock.c     | 14 --------------
 drivers/staging/lustre/lustre/ldlm/ldlm_pool.c     | 16 ++--------------
 4 files changed, 4 insertions(+), 46 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_dlm.h b/drivers/staging/lustre/lustre/include/lustre_dlm.h
index 1e40203..49b5a07 100644
--- a/drivers/staging/lustre/lustre/include/lustre_dlm.h
+++ b/drivers/staging/lustre/lustre/include/lustre_dlm.h
@@ -465,19 +465,6 @@ struct ldlm_namespace {
 };
 
 /**
- * Returns 1 if namespace \a ns is a server namespace.
- */
-static inline int ns_is_server(struct ldlm_namespace *ns)
-{
-	LASSERT(ns != NULL);
-	LASSERT(!(ns->ns_client & ~(LDLM_NAMESPACE_CLIENT |
-				    LDLM_NAMESPACE_SERVER)));
-	LASSERT(ns->ns_client == LDLM_NAMESPACE_CLIENT ||
-		ns->ns_client == LDLM_NAMESPACE_SERVER);
-	return ns->ns_client == LDLM_NAMESPACE_SERVER;
-}
-
-/**
  * Returns 1 if namespace \a ns supports early lock cancel (ELC).
  */
 static inline int ns_connect_cancelset(struct ldlm_namespace *ns)
diff --git a/drivers/staging/lustre/lustre/ldlm/l_lock.c b/drivers/staging/lustre/lustre/ldlm/l_lock.c
index cd8ab40..e5d1344 100644
--- a/drivers/staging/lustre/lustre/ldlm/l_lock.c
+++ b/drivers/staging/lustre/lustre/ldlm/l_lock.c
@@ -50,9 +50,7 @@
  */
 struct ldlm_resource *lock_res_and_lock(struct ldlm_lock *lock)
 {
-	/* on server-side resource of lock doesn't change */
-	if ((lock->l_flags & LDLM_FL_NS_SRV) == 0)
-		spin_lock(&lock->l_lock);
+	spin_lock(&lock->l_lock);
 
 	lock_res(lock->l_resource);
 
@@ -70,7 +68,6 @@ void unlock_res_and_lock(struct ldlm_lock *lock)
 	lock->l_flags &= ~LDLM_FL_RES_LOCKED;
 
 	unlock_res(lock->l_resource);
-	if ((lock->l_flags & LDLM_FL_NS_SRV) == 0)
-		spin_unlock(&lock->l_lock);
+	spin_unlock(&lock->l_lock);
 }
 EXPORT_SYMBOL(unlock_res_and_lock);
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
index 6d5e7af..827e5df 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
@@ -237,11 +237,6 @@ int ldlm_lock_remove_from_lru(struct ldlm_lock *lock)
 	struct ldlm_namespace *ns = ldlm_lock_to_ns(lock);
 	int rc;
 
-	if (lock->l_flags & LDLM_FL_NS_SRV) {
-		LASSERT(list_empty(&lock->l_lru));
-		return 0;
-	}
-
 	spin_lock(&ns->ns_lock);
 	rc = ldlm_lock_remove_from_lru_nolock(lock);
 	spin_unlock(&ns->ns_lock);
@@ -286,11 +281,6 @@ void ldlm_lock_touch_in_lru(struct ldlm_lock *lock)
 {
 	struct ldlm_namespace *ns = ldlm_lock_to_ns(lock);
 
-	if (lock->l_flags & LDLM_FL_NS_SRV) {
-		LASSERT(list_empty(&lock->l_lru));
-		return;
-	}
-
 	spin_lock(&ns->ns_lock);
 	if (!list_empty(&lock->l_lru)) {
 		ldlm_lock_remove_from_lru_nolock(lock);
@@ -799,8 +789,6 @@ void ldlm_lock_decref_internal(struct ldlm_lock *lock, __u32 mode)
 	    (lock->l_flags & LDLM_FL_CBPENDING)) {
 		/* If we received a blocked AST and this was the last reference,
 		 * run the callback. */
-		if ((lock->l_flags & LDLM_FL_NS_SRV) && lock->l_export)
-			CERROR("FL_CBPENDING set on non-local lock--just a warning\n");
 
 		LDLM_DEBUG(lock, "final decref done on cbpending lock");
 
@@ -1486,8 +1474,6 @@ struct ldlm_lock *ldlm_lock_create(struct ldlm_namespace *ns,
 	lock->l_req_mode = mode;
 	lock->l_ast_data = data;
 	lock->l_pid = current_pid();
-	if (ns_is_server(ns))
-		lock->l_flags |= LDLM_FL_NS_SRV;
 	if (cbs) {
 		lock->l_blocking_ast = cbs->lcs_blocking;
 		lock->l_completion_ast = cbs->lcs_completion;
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c b/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c
index 94cdf5f..dac1b6f 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c
@@ -656,8 +656,8 @@ EXPORT_SYMBOL(ldlm_pool_setup);
 
 static int lprocfs_pool_state_seq_show(struct seq_file *m, void *unused)
 {
-	int granted, grant_rate, cancel_rate, grant_step;
-	int grant_speed, grant_plan, lvf;
+	int granted, grant_rate, cancel_rate;
+	int grant_speed, lvf;
 	struct ldlm_pool *pl = m->private;
 	__u64 slv, clv;
 	__u32 limit;
@@ -666,13 +666,11 @@ static int lprocfs_pool_state_seq_show(struct seq_file *m, void *unused)
 	slv = pl->pl_server_lock_volume;
 	clv = pl->pl_client_lock_volume;
 	limit = ldlm_pool_get_limit(pl);
-	grant_plan = pl->pl_grant_plan;
 	granted = atomic_read(&pl->pl_granted);
 	grant_rate = atomic_read(&pl->pl_grant_rate);
 	cancel_rate = atomic_read(&pl->pl_cancel_rate);
 	grant_speed = grant_rate - cancel_rate;
 	lvf = atomic_read(&pl->pl_lock_volume_factor);
-	grant_step = ldlm_pool_t2gsp(pl->pl_recalc_period);
 	spin_unlock(&pl->pl_lock);
 
 	seq_printf(m, "LDLM pool state (%s):\n"
@@ -681,11 +679,6 @@ static int lprocfs_pool_state_seq_show(struct seq_file *m, void *unused)
 		      "  LVF: %d\n",
 		      pl->pl_name, slv, clv, lvf);
 
-	if (ns_is_server(ldlm_pl2ns(pl))) {
-		seq_printf(m, "  GSP: %d%%\n"
-			      "  GP:  %d\n",
-			      grant_step, grant_plan);
-	}
 	seq_printf(m, "  GR:  %d\n  CR:  %d\n  GS:  %d\n"
 		      "  G:   %d\n  L:   %d\n",
 		      grant_rate, cancel_rate, grant_speed,
@@ -966,8 +959,6 @@ void ldlm_pool_add(struct ldlm_pool *pl, struct ldlm_lock *lock)
 	 * enqueue/cancel rpc. Also we do not want to run out of stack
 	 * with too long call paths.
 	 */
-	if (ns_is_server(ldlm_pl2ns(pl)))
-		ldlm_pool_recalc(pl);
 }
 EXPORT_SYMBOL(ldlm_pool_add);
 
@@ -987,9 +978,6 @@ void ldlm_pool_del(struct ldlm_pool *pl, struct ldlm_lock *lock)
 	atomic_inc(&pl->pl_cancel_rate);
 
 	lprocfs_counter_incr(pl->pl_stats, LDLM_POOL_CANCEL_STAT);
-
-	if (ns_is_server(ldlm_pl2ns(pl)))
-		ldlm_pool_recalc(pl);
 }
 EXPORT_SYMBOL(ldlm_pool_del);
 
-- 
2.1.0
