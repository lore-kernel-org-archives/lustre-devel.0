From: James Simmons <jsimmons@infradead.org>
Date: Sun,  2 Oct 2016 22:27:58 -0400
Subject: [lustre-devel] [PATCH 02/41] staging: lustre: obdclass: Add synchro
	in lu_context_key_degister()
In-Reply-To: <1475461717-21631-1-git-send-email-jsimmons@infradead.org>
References: <1475461717-21631-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1475461717-21631-3-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Patrick Valentin <patrick.valentin@bull.net>, Gregoire Pichon <gregoire.pichon@bull.net>, James Simmons <jsimmons@infradead.org>

From: Patrick Valentin <patrick.valentin@bull.net>

When unloading a module, it may happen that lu_context_key_degister()
removes a key while a thread is either registering it in a new
context (lu_context_init(), lu_context_refill()), or using it when
exiting from a context (lu_context__exit(), lu_context__fini()).

In these cases, we reference a key which no longer exists, and
the system crashes either because we use a *POISON'ed* pointer
in key_fini() -> key->lct_fini(), or because one of the following
assertions fails:
 - lu_context_key_degister():
        ASSERTION(cfs_atomic_read(&key->lct_used) == 1)
                  failed: key has instances: 2

 - lu_context_exit():
        ASSERTION(key != NULL)

 - key_fini():
        ASSERTION(atomic_read(&key->lct_used) > 1)

This can also leads to SLAB objects which are not freed:
        slab error in kmem_cache_destroy(): cache `echo_thread_kmem':
                   Can't free all objects

Note: ptlrpc service threads need to call lu_context_init/fini in
each loop (for each RPC), and this could be a big performance issue
on fat SMP machines if we add serialization by a spinlock and need
to lock/unlock it for multiple times for each RPC.

So the aim of this patch, which only impacts some low frequently used
functions, is:
  1) to add a synchronization in lu_context_key_quiesce(), also called
     by lu_context_key_degister(), to wait until all key::lct_init()
     methods have completed, by serializing with keys_fill()
  2) to add a synchronization in lu_context_key_degister(), to wait
     until all transient contexts referencing this key have run
     key::lct_fini() method

Signed-off-by: Patrick Valentin <patrick.valentin@bull.net>
Signed-off-by: Gregoire Pichon <gregoire.pichon@bull.net>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6049
Reviewed-on: http://review.whamcloud.com/13164
Reviewed-by: Fan Yong <fan.yong@intel.com>
Reviewed-by: Alex Zhuravlev <alexey.zhuravlev@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/obdclass/lu_object.c |   58 ++++++++++++++++++--
 1 files changed, 54 insertions(+), 4 deletions(-)

diff --git a/drivers/staging/lustre/lustre/obdclass/lu_object.c b/drivers/staging/lustre/lustre/obdclass/lu_object.c
index f0e74c6..e031fd2 100644
--- a/drivers/staging/lustre/lustre/obdclass/lu_object.c
+++ b/drivers/staging/lustre/lustre/obdclass/lu_object.c
@@ -1311,6 +1311,7 @@ enum {
 static struct lu_context_key *lu_keys[LU_CONTEXT_KEY_NR] = { NULL, };
 
 static DEFINE_SPINLOCK(lu_keys_guard);
+static atomic_t lu_key_initing_cnt = ATOMIC_INIT(0);
 
 /**
  * Global counter incremented whenever key is registered, unregistered,
@@ -1385,6 +1386,19 @@ void lu_context_key_degister(struct lu_context_key *key)
 	++key_set_version;
 	spin_lock(&lu_keys_guard);
 	key_fini(&lu_shrink_env.le_ctx, key->lct_index);
+
+	/**
+	 * Wait until all transient contexts referencing this key have
+	 * run lu_context_key::lct_fini() method.
+	 */
+	while (atomic_read(&key->lct_used) > 1) {
+		spin_unlock(&lu_keys_guard);
+		CDEBUG(D_INFO, "lu_context_key_degister: \"%s\" %p, %d\n",
+		       key->lct_owner ? key->lct_owner->name : "", key,
+		       atomic_read(&key->lct_used));
+		schedule();
+		spin_lock(&lu_keys_guard);
+	}
 	if (lu_keys[key->lct_index]) {
 		lu_keys[key->lct_index] = NULL;
 		lu_ref_fini(&key->lct_reference);
@@ -1510,11 +1524,26 @@ void lu_context_key_quiesce(struct lu_context_key *key)
 		 * XXX layering violation.
 		 */
 		cl_env_cache_purge(~0);
-		key->lct_tags |= LCT_QUIESCENT;
 		/*
 		 * XXX memory barrier has to go here.
 		 */
 		spin_lock(&lu_keys_guard);
+		key->lct_tags |= LCT_QUIESCENT;
+
+		/**
+		 * Wait until all lu_context_key::lct_init() methods
+		 * have completed.
+		 */
+		while (atomic_read(&lu_key_initing_cnt) > 0) {
+			spin_unlock(&lu_keys_guard);
+			CDEBUG(D_INFO, "lu_context_key_quiesce: \"%s\" %p, %d (%d)\n",
+			       key->lct_owner ? key->lct_owner->name : "",
+			       key, atomic_read(&key->lct_used),
+			atomic_read(&lu_key_initing_cnt));
+			schedule();
+			spin_lock(&lu_keys_guard);
+		}
+
 		list_for_each_entry(ctx, &lu_context_remembered, lc_remember)
 			key_fini(ctx, key->lct_index);
 		spin_unlock(&lu_keys_guard);
@@ -1546,6 +1575,19 @@ static int keys_fill(struct lu_context *ctx)
 {
 	unsigned int i;
 
+	/*
+	 * A serialisation with lu_context_key_quiesce() is needed, but some
+	 * "key->lct_init()" are calling kernel memory allocation routine and
+	 * can't be called while holding a spin_lock.
+	 * "lu_keys_guard" is held while incrementing "lu_key_initing_cnt"
+	 * to ensure the start of the serialisation.
+	 * An atomic_t variable is still used, in order not to reacquire the
+	 * lock when decrementing the counter.
+	 */
+	spin_lock(&lu_keys_guard);
+	atomic_inc(&lu_key_initing_cnt);
+	spin_unlock(&lu_keys_guard);
+
 	LINVRNT(ctx->lc_value);
 	for (i = 0; i < ARRAY_SIZE(lu_keys); ++i) {
 		struct lu_context_key *key;
@@ -1563,12 +1605,19 @@ static int keys_fill(struct lu_context *ctx)
 			LINVRNT(key->lct_init);
 			LINVRNT(key->lct_index == i);
 
+			LASSERT(key->lct_owner);
+			if (!(ctx->lc_tags & LCT_NOREF) &&
+			    !try_module_get(key->lct_owner)) {
+				/* module is unloading, skip this key */
+				continue;
+			}
+
 			value = key->lct_init(ctx, key);
-			if (IS_ERR(value))
+			if (unlikely(IS_ERR(value))) {
+				atomic_dec(&lu_key_initing_cnt);
 				return PTR_ERR(value);
+			}
 
-			if (!(ctx->lc_tags & LCT_NOREF))
-				try_module_get(key->lct_owner);
 			lu_ref_add_atomic(&key->lct_reference, "ctx", ctx);
 			atomic_inc(&key->lct_used);
 			/*
@@ -1582,6 +1631,7 @@ static int keys_fill(struct lu_context *ctx)
 		}
 		ctx->lc_version = key_set_version;
 	}
+	atomic_dec(&lu_key_initing_cnt);
 	return 0;
 }
 
-- 
1.7.1
