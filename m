From: James Simmons <jsimmons@infradead.org>
Date: Mon, 20 May 2019 08:51:00 -0400
Subject: [lustre-devel] [PATCH v2 18/29] lustre: discard OBD_FREE_RCU
In-Reply-To: <1558356671-29599-1-git-send-email-jsimmons@infradead.org>
References: <1558356671-29599-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1558356671-29599-19-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: NeilBrown <neilb@suse.com>

OBD_FREE_RCU and the hop_free call-back together form an overly
complex mechanism equivalent to kfree_rcu() or call_rcu(...).
Discard them and use the simpler approach.

This removes the only use for the field h_size, so discard
that too.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 fs/lustre/include/lustre_handles.h  |  3 ---
 fs/lustre/include/obd_support.h     | 10 ----------
 fs/lustre/ldlm/ldlm_lock.c          | 16 ++++++++--------
 fs/lustre/obdclass/genops.c         |  6 ++----
 fs/lustre/obdclass/lustre_handles.c | 15 ---------------
 5 files changed, 10 insertions(+), 40 deletions(-)

diff --git a/fs/lustre/include/lustre_handles.h b/fs/lustre/include/lustre_handles.h
index be5d41b..8fb4285 100644
--- a/fs/lustre/include/lustre_handles.h
+++ b/fs/lustre/include/lustre_handles.h
@@ -46,7 +46,6 @@
 #include <linux/types.h>
 
 struct portals_handle_ops {
-	void (*hop_free)(void *object, int size);
 	/* hop_type is used for some debugging messages */
 	char *hop_type;
 };
@@ -72,7 +71,6 @@ struct portals_handle {
 	/* newly added fields to handle the RCU issue. -jxiong */
 	struct rcu_head			h_rcu;
 	spinlock_t			h_lock;
-	unsigned int			h_size:31;
 	unsigned int			h_in:1;
 };
 
@@ -83,7 +81,6 @@ void class_handle_hash(struct portals_handle *,
 		       const struct portals_handle_ops *ops);
 void class_handle_unhash(struct portals_handle *);
 void *class_handle2object(u64 cookie, const struct portals_handle_ops *ops);
-void class_handle_free_cb(struct rcu_head *rcu);
 int class_handle_init(void);
 void class_handle_cleanup(void);
 
diff --git a/fs/lustre/include/obd_support.h b/fs/lustre/include/obd_support.h
index 3e15cac..91d6a86 100644
--- a/fs/lustre/include/obd_support.h
+++ b/fs/lustre/include/obd_support.h
@@ -503,16 +503,6 @@
 #define POISON_PAGE(page, val) do { } while (0)
 #endif
 
-#define OBD_FREE_RCU(ptr, size, handle)			\
-do {							\
-	struct portals_handle *__h = (handle);		\
-							\
-	__h->h_cookie = (unsigned long)(ptr);		\
-	__h->h_size = (size);				\
-	call_rcu(&__h->h_rcu, class_handle_free_cb);	\
-	POISON_PTR(ptr);				\
-} while (0)
-
 #define KEY_IS(str)					\
 	(keylen >= (sizeof(str) - 1) &&			\
 	memcmp(key, str, (sizeof(str) - 1)) == 0)
diff --git a/fs/lustre/ldlm/ldlm_lock.c b/fs/lustre/ldlm/ldlm_lock.c
index ecd3f4a..18f018d 100644
--- a/fs/lustre/ldlm/ldlm_lock.c
+++ b/fs/lustre/ldlm/ldlm_lock.c
@@ -153,6 +153,13 @@ struct ldlm_lock *ldlm_lock_get(struct ldlm_lock *lock)
 }
 EXPORT_SYMBOL(ldlm_lock_get);
 
+static void lock_handle_free(struct rcu_head *rcu)
+{
+	struct ldlm_lock *lock = container_of(rcu, struct ldlm_lock,
+					      l_handle.h_rcu);
+	kmem_cache_free(ldlm_lock_slab, lock);
+}
+
 /**
  * Release lock reference.
  *
@@ -186,7 +193,7 @@ void ldlm_lock_put(struct ldlm_lock *lock)
 		kfree(lock->l_lvb_data);
 
 		lu_ref_fini(&lock->l_reference);
-		OBD_FREE_RCU(lock, sizeof(*lock), &lock->l_handle);
+		call_rcu(&lock->l_handle.h_rcu, lock_handle_free);
 	}
 }
 EXPORT_SYMBOL(ldlm_lock_put);
@@ -356,14 +363,7 @@ void ldlm_lock_destroy_nolock(struct ldlm_lock *lock)
 	}
 }
 
-static void lock_handle_free(void *lock, int size)
-{
-	LASSERT(size == sizeof(struct ldlm_lock));
-	kmem_cache_free(ldlm_lock_slab, lock);
-}
-
 static struct portals_handle_ops lock_handle_ops = {
-	.hop_free   = lock_handle_free,
 	.hop_type   = "ldlm",
 };
 
diff --git a/fs/lustre/obdclass/genops.c b/fs/lustre/obdclass/genops.c
index c6dc3ba..1d1d457 100644
--- a/fs/lustre/obdclass/genops.c
+++ b/fs/lustre/obdclass/genops.c
@@ -743,11 +743,10 @@ static void class_export_destroy(struct obd_export *exp)
 	if (exp != obd->obd_self_export)
 		class_decref(obd, "export", exp);
 
-	OBD_FREE_RCU(exp, sizeof(*exp), &exp->exp_handle);
+	kfree_rcu(exp, exp_handle.h_rcu);
 }
 
 static struct portals_handle_ops export_handle_ops = {
-	.hop_free	= NULL,
 	.hop_type	= "export",
 };
 
@@ -934,11 +933,10 @@ static void class_import_destroy(struct obd_import *imp)
 
 	LASSERT(!imp->imp_sec);
 	class_decref(imp->imp_obd, "import", imp);
-	OBD_FREE_RCU(imp, sizeof(*imp), &imp->imp_handle);
+	kfree_rcu(imp, imp_handle.h_rcu);
 }
 
 static struct portals_handle_ops import_handle_ops = {
-	.hop_free	= NULL,
 	.hop_type	= "import",
 };
 
diff --git a/fs/lustre/obdclass/lustre_handles.c b/fs/lustre/obdclass/lustre_handles.c
index 32cd6ae..8aece57 100644
--- a/fs/lustre/obdclass/lustre_handles.c
+++ b/fs/lustre/obdclass/lustre_handles.c
@@ -167,21 +167,6 @@ void *class_handle2object(u64 cookie, const struct portals_handle_ops *ops)
 }
 EXPORT_SYMBOL(class_handle2object);
 
-void class_handle_free_cb(struct rcu_head *rcu)
-{
-	struct portals_handle *h;
-	void *ptr;
-
-	h = container_of(rcu, struct portals_handle, h_rcu);
-	ptr = (void *)(unsigned long)h->h_cookie;
-
-	if (h->h_ops->hop_free)
-		h->h_ops->hop_free(ptr, h->h_size);
-	else
-		kfree(ptr);
-}
-EXPORT_SYMBOL(class_handle_free_cb);
-
 int class_handle_init(void)
 {
 	struct handle_bucket *bucket;
-- 
1.8.3.1
