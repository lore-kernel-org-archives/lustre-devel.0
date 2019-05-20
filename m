From: James Simmons <jsimmons@infradead.org>
Date: Mon, 20 May 2019 08:50:54 -0400
Subject: [lustre-devel] [PATCH v2 12/29] lustre: obdclass: fix module load
 locking.
In-Reply-To: <1558356671-29599-1-git-send-email-jsimmons@infradead.org>
References: <1558356671-29599-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1558356671-29599-13-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: NeilBrown <neilb@suse.com>

Safe module loading requires that we try_module_get() in a context
where the module cannot be unloaded, typically protected by
a spinlock that module-unload has to take.
This doesn't currently happen in class_get_type().

As free_module() calls synchronize_rcu() between calling the
exit function and freeing the module, we can use rcu_read_lock()
to check if the exit function has been called, and try_module_get()
if it hasn't.

We must also check the return status of try_module_get().

Reviewed-by: James Simmons <jsimmons@infradead.org>
Signed-off-by: NeilBrown <neilb@suse.com>
---
 fs/lustre/obdclass/genops.c | 25 ++++++++++++++++++++++---
 1 file changed, 22 insertions(+), 3 deletions(-)

diff --git a/fs/lustre/obdclass/genops.c b/fs/lustre/obdclass/genops.c
index 6d33414..00181e3 100644
--- a/fs/lustre/obdclass/genops.c
+++ b/fs/lustre/obdclass/genops.c
@@ -100,20 +100,31 @@ static struct obd_type *class_get_type(const char *name)
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
+
+		if (dt_ops && try_module_get(dt_ops->owner)) {
 			atomic_inc(&type->typ_refcnt);
 			/* class_search_type() returned a counted reference,
 			 * but we don't need that count any more as
@@ -125,6 +136,7 @@ static struct obd_type *class_get_type(const char *name)
 			type = NULL;
 		}
 	}
+	rcu_read_unlock();
 	return type;
 }
 
@@ -209,11 +221,18 @@ int class_unregister_type(const char *name)
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
 	if (atomic_read(&type->typ_refcnt)) {
 		CERROR("type %s has refcount (%d)\n", name, atomic_read(&type->typ_refcnt));
 		/* This is a bad situation, let's make the best of it */
 		/* Remove ops, but leave the name for debugging */
-		type->typ_dt_ops = NULL;
 		type->typ_md_ops = NULL;
 		kobject_put(&type->typ_kobj);
 		return -EBUSY;
-- 
1.8.3.1
