Return-Path: <SRS0=Gt0B=JW=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.7 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4253FC433B4
	for <lustre-devel@archiver.kernel.org>; Sun, 25 Apr 2021 20:10:06 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id F3522611CC
	for <lustre-devel@archiver.kernel.org>; Sun, 25 Apr 2021 20:10:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F3522611CC
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id F407F21F7B5;
	Sun, 25 Apr 2021 13:09:33 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 0470E21F7DB
 for <lustre-devel@lists.lustre.org>; Sun, 25 Apr 2021 13:08:48 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 3FFF210087D2;
 Sun, 25 Apr 2021 16:08:40 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 3DC4269A63; Sun, 25 Apr 2021 16:08:40 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 25 Apr 2021 16:08:30 -0400
Message-Id: <1619381316-7719-24-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1619381316-7719-1-git-send-email-jsimmons@infradead.org>
References: <1619381316-7719-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 23/29] lustre: ldlm: discard l_lock from
 struct ldlm_lock.
X-BeenThere: lustre-devel@lists.lustre.org
X-Mailman-Version: 2.1.23
Precedence: list
List-Id: "For discussing Lustre software development."
 <lustre-devel-lustre.org>
List-Unsubscribe: <http://lists.lustre.org/options.cgi/lustre-devel-lustre.org>, 
 <mailto:lustre-devel-request@lists.lustre.org?subject=unsubscribe>
List-Archive: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/>
List-Post: <mailto:lustre-devel@lists.lustre.org>
List-Help: <mailto:lustre-devel-request@lists.lustre.org?subject=help>
List-Subscribe: <http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org>, 
 <mailto:lustre-devel-request@lists.lustre.org?subject=subscribe>
Cc: Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Mr NeilBrown <neilb@suse.de>

This spinlock (l_lock) is only used to stablise the l_resource
pointer while taking a spinlock on the resource.

This is not necessary - it is sufficient to take the resource
spinlock, and then check if l_resource has changed or not.  If it
hasn't then it cannot change until the resource spinlock is dropped.

We must ensure this is safe even if the resource is freed before
lock_res_and_lock() managed to get the lock.  To do this we mark the
slab as SLAB_TYPESAFE_BY_RCU and initialise the lock in an
init_once() function, but not on every allocate (and specifically
don't zero the whole struct on each allocation). This means that if
we find a resource after taking the RCU read lock, then it is always
safe to take and then drop the spinlock. After taking the spinlock,
we can check if it is more generally safe to use.

Discarding l_lock shrinks 'struct ldlm_lock' which helps save memory.

WC-bug-id: https://jira.whamcloud.com/browse/LU-4801
Lustre-commit: bb6edb7b8eeec65f4 ("LU-4801 ldlm: discard l_lock from struct ldlm_lock.")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/39811
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_dlm.h | 17 +++++++++--------
 fs/lustre/ldlm/l_lock.c        | 27 +++++++++++++++------------
 fs/lustre/ldlm/ldlm_lock.c     | 28 ++++++++++++++--------------
 fs/lustre/ldlm/ldlm_lockd.c    | 22 +++++++++++++++++++++-
 fs/lustre/ldlm/ldlm_resource.c | 12 +++++-------
 5 files changed, 64 insertions(+), 42 deletions(-)

diff --git a/fs/lustre/include/lustre_dlm.h b/fs/lustre/include/lustre_dlm.h
index f1828df..1fc199b 100644
--- a/fs/lustre/include/lustre_dlm.h
+++ b/fs/lustre/include/lustre_dlm.h
@@ -649,13 +649,10 @@ struct ldlm_lock {
 	 */
 	struct portals_handle		l_handle;
 	/**
-	 * Internal spinlock protects l_resource.  We should hold this lock
-	 * first before taking res_lock.
-	 */
-	spinlock_t			l_lock;
-	/**
 	 * Pointer to actual resource this lock is in.
-	 * ldlm_lock_change_resource() can change this.
+	 * ldlm_lock_change_resource() can change this on the client.
+	 * When this is possible, rcu must be used to stablise
+	 * the resource while we lock and check it hasn't been changed.
 	 */
 	struct ldlm_resource		*l_resource;
 	/**
@@ -889,9 +886,13 @@ struct ldlm_resource {
 
 	/**
 	 * List item for list in namespace hash.
-	 * protected by ns_lock
+	 * protected by ns_lock.
+	 * Shared with linkage for RCU-delayed free.
 	 */
-	struct hlist_node		lr_hash;
+	union {
+		struct hlist_node		lr_hash;
+		struct rcu_head			lr_rcu;
+	};
 
 	/** Reference count for this resource */
 	atomic_t			lr_refcount;
diff --git a/fs/lustre/ldlm/l_lock.c b/fs/lustre/ldlm/l_lock.c
index 296259a..3531420 100644
--- a/fs/lustre/ldlm/l_lock.c
+++ b/fs/lustre/ldlm/l_lock.c
@@ -41,19 +41,25 @@
  *
  * LDLM locking uses resource to serialize access to locks
  * but there is a case when we change resource of lock upon
- * enqueue reply. We rely on lock->l_resource = new_res
+ * enqueue reply. We rely on rcu_assign_pointer(lock->l_resource, new_res)
  * being an atomic operation.
  */
 struct ldlm_resource *lock_res_and_lock(struct ldlm_lock *lock)
-				__acquires(&lock->l_lock)
-				__acquires(&lock->l_resource->lr_lock)
+__acquires(&lock->l_resource->lr_lock)
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
 
@@ -61,13 +67,10 @@ struct ldlm_resource *lock_res_and_lock(struct ldlm_lock *lock)
  * Unlock a lock and its resource previously locked with lock_res_and_lock
  */
 void unlock_res_and_lock(struct ldlm_lock *lock)
-		__releases(&lock->l_resource->lr_lock)
-		__releases(&lock->l_lock)
+__releases(&lock->l_resource->lr_lock)
 {
-	/* on server-side resource of lock doesn't change */
 	ldlm_clear_res_locked(lock);
 
 	unlock_res(lock->l_resource);
-	spin_unlock(&lock->l_lock);
 }
 EXPORT_SYMBOL(unlock_res_and_lock);
diff --git a/fs/lustre/ldlm/ldlm_lock.c b/fs/lustre/ldlm/ldlm_lock.c
index b7ce0bb..c872455 100644
--- a/fs/lustre/ldlm/ldlm_lock.c
+++ b/fs/lustre/ldlm/ldlm_lock.c
@@ -385,8 +385,7 @@ static struct ldlm_lock *ldlm_lock_new(struct ldlm_resource *resource)
 	if (!lock)
 		return NULL;
 
-	spin_lock_init(&lock->l_lock);
-	lock->l_resource = resource;
+	RCU_INIT_POINTER(lock->l_resource, resource);
 	lu_ref_add(&resource->lr_reference, "lock", lock);
 
 	refcount_set(&lock->l_handle.h_ref, 2);
@@ -455,12 +454,13 @@ int ldlm_lock_change_resource(struct ldlm_namespace *ns, struct ldlm_lock *lock,
 
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
@@ -471,9 +471,9 @@ int ldlm_lock_change_resource(struct ldlm_namespace *ns, struct ldlm_lock *lock,
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
@@ -1875,11 +1875,11 @@ void _ldlm_lock_debug(struct ldlm_lock *lock,
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
index 6f498cc..7d8bae2 100644
--- a/fs/lustre/ldlm/ldlm_lockd.c
+++ b/fs/lustre/ldlm/ldlm_lockd.c
@@ -1208,6 +1208,23 @@ static int ldlm_cleanup(void)
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
@@ -1215,7 +1232,9 @@ int ldlm_init(void)
 	mutex_init(ldlm_namespace_lock(LDLM_NAMESPACE_CLIENT));
 	ldlm_resource_slab = kmem_cache_create("ldlm_resources",
 					       sizeof(struct ldlm_resource), 0,
-					       SLAB_HWCACHE_ALIGN, NULL);
+					       SLAB_TYPESAFE_BY_RCU |
+					       SLAB_HWCACHE_ALIGN,
+					       ldlm_resource_init_once);
 	if (!ldlm_resource_slab)
 		return -ENOMEM;
 
@@ -1248,6 +1267,7 @@ void ldlm_exit(void)
 {
 	if (ldlm_refcount)
 		CERROR("ldlm_refcount is %d in %s!\n", ldlm_refcount, __func__);
+	synchronize_rcu();
 	kmem_cache_destroy(ldlm_resource_slab);
 	/*
 	 * ldlm_lock_put() use RCU to call ldlm_lock_free, so need call
diff --git a/fs/lustre/ldlm/ldlm_resource.c b/fs/lustre/ldlm/ldlm_resource.c
index 481f14e..6e3feb2 100644
--- a/fs/lustre/ldlm/ldlm_resource.c
+++ b/fs/lustre/ldlm/ldlm_resource.c
@@ -1064,12 +1064,14 @@ static struct ldlm_resource *ldlm_resource_new(enum ldlm_type ldlm_type)
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
@@ -1087,17 +1089,13 @@ static struct ldlm_resource *ldlm_resource_new(enum ldlm_type ldlm_type)
 			res->lr_itree[idx].lit_mode = BIT(idx);
 			res->lr_itree[idx].lit_root = RB_ROOT_CACHED;
 		}
+	} else {
+		res->lr_itree = NULL;
 	}
 
 	atomic_set(&res->lr_refcount, 1);
-	spin_lock_init(&res->lr_lock);
 	lu_ref_init(&res->lr_reference);
 
-	/* Since LVB init can be delayed now, there is no longer need to
-	 * immediately acquire mutex here.
-	 */
-	mutex_init(&res->lr_lvb_mutex);
-
 	return res;
 }
 
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
