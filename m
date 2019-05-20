From: James Simmons <jsimmons@infradead.org>
Date: Mon, 20 May 2019 08:51:09 -0400
Subject: [lustre-devel] [PATCH 27/29] lustre: ldlm: discard l_lock from
 struct ldlm_lock.
In-Reply-To: <1558356671-29599-1-git-send-email-jsimmons@infradead.org>
References: <1558356671-29599-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1558356671-29599-28-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: NeilBrown <neilb@suse.com>

This spinlock (l_lock) is only used to stablise the l_resource
pointer while taking a spinlock on the resource.

This is not necessary - it is sufficient to take the resource
spinlock, and then check if l_resource has changed or not.  If it
hasn't then it cannot change until the resource spinlock is dropped.

We must ensure this is safe even if the resource is freed before
lock_res_and_lock() managed to get the lock.  To do this we mark the
slab as SLAB_TYPESAFE_BY_RCU and initialise the lock in an
init_once() function, but not on every allocate (and specifically
don't zero the whole srtuct on each allocation).
This means that if we find a resource after taking the RCU read lock,
then it is always safe to take and then drop the spinlock.
After taking the spinlock, we can check if it is more generally safe
to use.

Discarding l_lock shrinks 'struct ldlm_lock' which helps save memory.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 fs/lustre/include/lustre_dlm.h |  5 -----
 fs/lustre/ldlm/l_lock.c        | 20 ++++++++++++--------
 fs/lustre/ldlm/ldlm_lock.c     | 26 +++++++++++++-------------
 fs/lustre/ldlm/ldlm_lockd.c    | 21 ++++++++++++++++++++-
 fs/lustre/ldlm/ldlm_resource.c |  9 +++++----
 5 files changed, 50 insertions(+), 31 deletions(-)

diff --git a/fs/lustre/include/lustre_dlm.h b/fs/lustre/include/lustre_dlm.h
index fd9b0f8..3417661 100644
--- a/fs/lustre/include/lustre_dlm.h
+++ b/fs/lustre/include/lustre_dlm.h
@@ -591,11 +591,6 @@ struct ldlm_lock {
 	 */
 	struct portals_handle		l_handle;
 	/**
-	 * Internal spinlock protects l_resource.  We should hold this lock
-	 * first before taking res_lock.
-	 */
-	spinlock_t			l_lock;
-	/**
 	 * Pointer to actual resource this lock is in.
 	 * ldlm_lock_change_resource() can change this.
 	 */
diff --git a/fs/lustre/ldlm/l_lock.c b/fs/lustre/ldlm/l_lock.c
index 296259a..0ba4942 100644
--- a/fs/lustre/ldlm/l_lock.c
+++ b/fs/lustre/ldlm/l_lock.c
@@ -45,15 +45,21 @@
  * being an atomic operation.
  */
 struct ldlm_resource *lock_res_and_lock(struct ldlm_lock *lock)
-				__acquires(&lock->l_lock)
 				__acquires(&lock->l_resource->lr_lock)
 {
-	spin_lock(&lock->l_lock);
+	struct ldlm_resource *res;
 
-	lock_res(lock->l_resource);
-
-	ldlm_set_res_locked(lock);
-	return lock->l_resource;
+	rcu_read_lock();
+	while (1) {
+		res = rcu_dereference(lock->l_resource);
+		lock_res(res);
+		if (res == lock->l_resource) {
+			ldlm_set_res_locked(lock);
+			rcu_read_unlock();
+			return res;
+		}
+		unlock_res(res);
+	}
 }
 EXPORT_SYMBOL(lock_res_and_lock);
 
@@ -62,12 +68,10 @@ struct ldlm_resource *lock_res_and_lock(struct ldlm_lock *lock)
  */
 void unlock_res_and_lock(struct ldlm_lock *lock)
 		__releases(&lock->l_resource->lr_lock)
-		__releases(&lock->l_lock)
 {
 	/* on server-side resource of lock doesn't change */
 	ldlm_clear_res_locked(lock);
 
 	unlock_res(lock->l_resource);
-	spin_unlock(&lock->l_lock);
 }
 EXPORT_SYMBOL(unlock_res_and_lock);
diff --git a/fs/lustre/ldlm/ldlm_lock.c b/fs/lustre/ldlm/ldlm_lock.c
index 5ac7723..e62dad1 100644
--- a/fs/lustre/ldlm/ldlm_lock.c
+++ b/fs/lustre/ldlm/ldlm_lock.c
@@ -383,7 +383,6 @@ static struct ldlm_lock *ldlm_lock_new(struct ldlm_resource *resource)
 	if (!lock)
 		return NULL;
 
-	spin_lock_init(&lock->l_lock);
 	lock->l_resource = resource;
 	lu_ref_add(&resource->lr_reference, "lock", lock);
 
@@ -452,12 +451,13 @@ int ldlm_lock_change_resource(struct ldlm_namespace *ns, struct ldlm_lock *lock,
 
 	lu_ref_add(&newres->lr_reference, "lock", lock);
 	/*
-	 * To flip the lock from the old to the new resource, lock, oldres and
-	 * newres have to be locked. Resource spin-locks are nested within
-	 * lock->l_lock, and are taken in the memory address order to avoid
-	 * dead-locks.
+	 * To flip the lock from the old to the new resource, oldres
+	 * and newres have to be locked. Resource spin-locks are taken
+	 * in the memory address order to avoid dead-locks.
+	 * As this is the only circumstance where ->l_resource
+	 * can change, and this cannot race with itself, it is safe
+	 * to access lock->l_resource without being careful about locking.
 	 */
-	spin_lock(&lock->l_lock);
 	oldres = lock->l_resource;
 	if (oldres < newres) {
 		lock_res(oldres);
@@ -468,9 +468,9 @@ int ldlm_lock_change_resource(struct ldlm_namespace *ns, struct ldlm_lock *lock,
 	}
 	LASSERT(memcmp(new_resid, &oldres->lr_name,
 		       sizeof(oldres->lr_name)) != 0);
-	lock->l_resource = newres;
+	rcu_assign_pointer(lock->l_resource, newres);
 	unlock_res(oldres);
-	unlock_res_and_lock(lock);
+	unlock_res(newres);
 
 	/* ...and the flowers are still standing! */
 	lu_ref_del(&oldres->lr_reference, "lock", lock);
@@ -1964,11 +1964,11 @@ void _ldlm_lock_debug(struct ldlm_lock *lock,
 	va_list args;
 	struct va_format vaf;
 
-	if (spin_trylock(&lock->l_lock)) {
-		if (lock->l_resource)
-			resource = ldlm_resource_getref(lock->l_resource);
-		spin_unlock(&lock->l_lock);
-	}
+	rcu_read_lock();
+	resource = rcu_dereference(lock->l_resource);
+	if (resource && !atomic_inc_not_zero(&resource->lr_refcount))
+		resource = NULL;
+	rcu_read_unlock();
 
 	va_start(args, fmt);
 	vaf.fmt = fmt;
diff --git a/fs/lustre/ldlm/ldlm_lockd.c b/fs/lustre/ldlm/ldlm_lockd.c
index 589b89d..ea87fd6 100644
--- a/fs/lustre/ldlm/ldlm_lockd.c
+++ b/fs/lustre/ldlm/ldlm_lockd.c
@@ -1097,6 +1097,23 @@ static int ldlm_cleanup(void)
 	return 0;
 }
 
+void ldlm_resource_init_once(void *p)
+{
+	/*
+	 * It is import to initialise the spinlock only once,
+	 * as ldlm_lock_change_resource() could try to lock
+	 * the resource *after* it has been freed and possibly
+	 * reused. SLAB_TYPESAFE_BY_RCU ensures the memory won't
+	 * be freed while the lock is being taken, but we need to
+	 * ensure that it doesn't get reinitialized either.
+	 */
+	struct ldlm_resource *res = p;
+
+	memset(res, 0, sizeof(*res));
+	mutex_init(&res->lr_lvb_mutex);
+	spin_lock_init(&res->lr_lock);
+}
+
 int ldlm_init(void)
 {
 	mutex_init(&ldlm_ref_mutex);
@@ -1104,7 +1121,9 @@ int ldlm_init(void)
 	mutex_init(ldlm_namespace_lock(LDLM_NAMESPACE_CLIENT));
 	ldlm_resource_slab = kmem_cache_create("ldlm_resources",
 					       sizeof(struct ldlm_resource), 0,
-					       SLAB_HWCACHE_ALIGN, NULL);
+					       SLAB_TYPESAFE_BY_RCU |
+					       SLAB_HWCACHE_ALIGN,
+					       ldlm_resource_init_once);
 	if (!ldlm_resource_slab)
 		return -ENOMEM;
 
diff --git a/fs/lustre/ldlm/ldlm_resource.c b/fs/lustre/ldlm/ldlm_resource.c
index 45b2e97..d79f70d 100644
--- a/fs/lustre/ldlm/ldlm_resource.c
+++ b/fs/lustre/ldlm/ldlm_resource.c
@@ -994,12 +994,14 @@ static struct ldlm_resource *ldlm_resource_new(enum ldlm_type ldlm_type)
 {
 	struct ldlm_resource *res;
 
-	res = kmem_cache_zalloc(ldlm_resource_slab, GFP_NOFS);
+	res = kmem_cache_alloc(ldlm_resource_slab, GFP_NOFS);
 	if (!res)
 		return NULL;
 
 	INIT_LIST_HEAD(&res->lr_granted);
 	INIT_LIST_HEAD(&res->lr_waiting);
+	res->lr_lvb_inode = NULL;
+	res->lr_lvb_len = 0;
 
 	if (ldlm_type == LDLM_EXTENT) {
 		int idx;
@@ -1017,16 +1019,15 @@ static struct ldlm_resource *ldlm_resource_new(enum ldlm_type ldlm_type)
 			res->lr_itree[idx].lit_mode = 1 << idx;
 			res->lr_itree[idx].lit_root = RB_ROOT_CACHED;
 		}
-	}
+	} else
+		res->lr_itree = NULL;
 
 	atomic_set(&res->lr_refcount, 1);
-	spin_lock_init(&res->lr_lock);
 	lu_ref_init(&res->lr_reference);
 
 	/* The creator of the resource must unlock the mutex after LVB
 	 * initialization.
 	 */
-	mutex_init(&res->lr_lvb_mutex);
 	mutex_lock(&res->lr_lvb_mutex);
 
 	return res;
-- 
1.8.3.1
