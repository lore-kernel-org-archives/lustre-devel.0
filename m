From: NeilBrown <neilb@suse.com>
Date: Tue, 19 Feb 2019 11:09:05 +1100
Subject: [lustre-devel] [PATCH 09/37] lustre: obdclass: fix module load
 locking.
In-Reply-To: <155053473693.24125.6976971762921761309.stgit@noble.brown>
References: <155053473693.24125.6976971762921761309.stgit@noble.brown>
Message-ID: <155053494536.24125.16645429190038913975.stgit@noble.brown>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Safe module loading requires that we try_module_get() in a context
where the module cannot be unloaded, typically protected by
a spinlock that module-unload has to take.
This doesn't currently happen in class_get_type().

As free_module() calls synchronize_rcu() between calling the
exit function and freeing the module, we can use rcu_read_lock()
to check if the exit function has been called, and try_module_get()
if it hasn't.

We must also check the return status of try_module_get().

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/obdclass/genops.c |   24 ++++++++++++++++++++---
 1 file changed, 21 insertions(+), 3 deletions(-)

diff --git a/drivers/staging/lustre/lustre/obdclass/genops.c b/drivers/staging/lustre/lustre/obdclass/genops.c
index d013e9a358f1..1d1a6b2d436e 100644
--- a/drivers/staging/lustre/lustre/obdclass/genops.c
+++ b/drivers/staging/lustre/lustre/obdclass/genops.c
@@ -98,21 +98,31 @@ static struct obd_type *class_get_type(const char *name)
 {
 	struct obd_type *type;
 
+	rcu_read_lock();
 	type = class_search_type(name);
 
 	if (!type) {
 		const char *modname = name;
 
+		rcu_read_unlock();
 		if (!request_module("%s", modname)) {
 			CDEBUG(D_INFO, "Loaded module '%s'\n", modname);
-			type = class_search_type(name);
 		} else {
 			LCONSOLE_ERROR_MSG(0x158, "Can't load module '%s'\n",
 					   modname);
 		}
+		rcu_read_lock();
+		type = class_search_type(name);
 	}
 	if (type) {
-		if (try_module_get(type->typ_dt_ops->owner)) {
+		/*
+		 * Holding rcu_read_lock() matches the synchronize_rcu() call
+		 * in free_module() and ensures that if type->typ_dt_ops is
+		 * not yet NULL, then the module won't be freed until after
+		 * we rcu_read_unlock().
+		 */
+		const struct obd_ops *dt_ops = READ_ONCE(type->typ_dt_ops);
+		if (dt_ops && try_module_get(dt_ops->owner)) {
 			refcount_inc(&type->typ_refcnt);
 			/* class_search_type() returned a counted reference,
 			 * but we don't need that count any more as
@@ -124,6 +134,7 @@ static struct obd_type *class_get_type(const char *name)
 			type = NULL;
 		}
 	}
+	rcu_read_unlock();
 	return type;
 }
 
@@ -213,11 +224,18 @@ int class_unregister_type(const char *name)
 		return -EINVAL;
 	}
 
+	/*
+	 * Ensure that class_get_type doesn't try to get the module
+	 * as it could be freed before the obd_type is released.
+	 * synchronize_rcu() will be called before the module
+	 * is freed.
+	 */
+	type->typ_dt_ops = NULL;
+
 	if (refcount_read(&type->typ_refcnt)) {
 		CERROR("type %s has refcount (%d)\n", name, refcount_read(&type->typ_refcnt));
 		/* This is a bad situation, let's make the best of it */
 		/* Remove ops, but leave the name for debugging */
-		type->typ_dt_ops = NULL;
 		type->typ_md_ops = NULL;
 		kobject_put(&type->typ_kobj);
 		return -EBUSY;
