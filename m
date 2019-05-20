From: James Simmons <jsimmons@infradead.org>
Date: Mon, 20 May 2019 08:50:52 -0400
Subject: [lustre-devel] [PATCH v2 10/29] lustre: obd_type: discard
 obd_type_lock
In-Reply-To: <1558356671-29599-1-git-send-email-jsimmons@infradead.org>
References: <1558356671-29599-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1558356671-29599-11-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: NeilBrown <neilb@suse.com>

This lock is only used to protect typ_refcnt, so change
that to an atomic_t and discard the lock.

The lock also covers calls to try_module_get and module_put,
but this serves no purpose as it does not prevent the module
from being unloaded.

Finally, the return value for the call to try_module_get is
ignored, which is not safe.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 fs/lustre/include/obd.h         |  3 +--
 fs/lustre/include/obd_class.h   |  1 -
 fs/lustre/mdc/mdc_request.c     |  2 +-
 fs/lustre/mgc/mgc_request.c     |  7 -------
 fs/lustre/obdclass/genops.c     | 29 ++++++++++++++---------------
 fs/lustre/obdclass/lu_object.c  |  2 +-
 fs/lustre/obdclass/obd_config.c | 19 -------------------
 7 files changed, 17 insertions(+), 46 deletions(-)

diff --git a/fs/lustre/include/obd.h b/fs/lustre/include/obd.h
index 4c58b91..61fb815 100644
--- a/fs/lustre/include/obd.h
+++ b/fs/lustre/include/obd.h
@@ -102,9 +102,8 @@ struct obd_type {
 	struct obd_ops		*typ_dt_ops;
 	struct md_ops		*typ_md_ops;
 	struct dentry		*typ_debugfs_entry;
-	int			 typ_refcnt;
+	atomic_t		 typ_refcnt;
 	struct lu_device_type	*typ_lu;
-	spinlock_t		 obd_type_lock;
 	struct kobject		 typ_kobj;
 };
 #define typ_name typ_kobj.name
diff --git a/fs/lustre/include/obd_class.h b/fs/lustre/include/obd_class.h
index 742cb9a4..a853ed5 100644
--- a/fs/lustre/include/obd_class.h
+++ b/fs/lustre/include/obd_class.h
@@ -210,7 +210,6 @@ struct lustre_profile {
 struct lustre_profile *class_get_profile(const char *prof);
 void class_del_profile(const char *prof);
 void class_put_profile(struct lustre_profile *lprof);
-void class_del_profiles(void);
 
 #if LUSTRE_TRACKS_LOCK_EXP_REFS
 
diff --git a/fs/lustre/mdc/mdc_request.c b/fs/lustre/mdc/mdc_request.c
index bc764f9..705a4e3 100644
--- a/fs/lustre/mdc/mdc_request.c
+++ b/fs/lustre/mdc/mdc_request.c
@@ -2542,7 +2542,7 @@ static int mdc_init_ea_size(struct obd_export *exp, u32 easize, u32 def_easize)
 static int mdc_precleanup(struct obd_device *obd)
 {
 	/* Failsafe, ok if racy */
-	if (obd->obd_type->typ_refcnt <= 1)
+	if (atomic_read(&obd->obd_type->typ_refcnt) <= 1)
 		libcfs_kkuc_group_rem(0, KUC_GRP_HSM);
 
 	mdc_changelog_cdev_finish(obd);
diff --git a/fs/lustre/mgc/mgc_request.c b/fs/lustre/mgc/mgc_request.c
index 84ba6d0..d8be54d 100644
--- a/fs/lustre/mgc/mgc_request.c
+++ b/fs/lustre/mgc/mgc_request.c
@@ -712,13 +712,6 @@ static int mgc_precleanup(struct obd_device *obd)
 
 static int mgc_cleanup(struct obd_device *obd)
 {
-	/* COMPAT_146 - old config logs may have added profiles we don't
-	 * know about
-	 */
-	if (obd->obd_type->typ_refcnt <= 1)
-		/* Only for the last mgc */
-		class_del_profiles();
-
 	lprocfs_obd_cleanup(obd);
 	ptlrpcd_decref();
 
diff --git a/fs/lustre/obdclass/genops.c b/fs/lustre/obdclass/genops.c
index 3f46298..9c9ad9c 100644
--- a/fs/lustre/obdclass/genops.c
+++ b/fs/lustre/obdclass/genops.c
@@ -113,15 +113,17 @@ static struct obd_type *class_get_type(const char *name)
 		}
 	}
 	if (type) {
-		spin_lock(&type->obd_type_lock);
-		type->typ_refcnt++;
-		try_module_get(type->typ_dt_ops->owner);
-		spin_unlock(&type->obd_type_lock);
-		/* class_search_type() returned a counted reference,
-		 * but we don't need that count any more as
-		 * we have one through typ_refcnt.
-		 */
-		kobject_put(&type->typ_kobj);
+		if (try_module_get(type->typ_dt_ops->owner)) {
+			atomic_inc(&type->typ_refcnt);
+			/* class_search_type() returned a counted reference,
+			 * but we don't need that count any more as
+			 * we have one through typ_refcnt.
+			 */
+			kobject_put(&type->typ_kobj);
+		} else {
+			kobject_put(&type->typ_kobj);
+			type = NULL;
+		}
 	}
 	return type;
 }
@@ -129,10 +131,8 @@ static struct obd_type *class_get_type(const char *name)
 void class_put_type(struct obd_type *type)
 {
 	LASSERT(type);
-	spin_lock(&type->obd_type_lock);
-	type->typ_refcnt--;
 	module_put(type->typ_dt_ops->owner);
-	spin_unlock(&type->obd_type_lock);
+	atomic_dec(&type->typ_refcnt);
 }
 
 static void class_sysfs_release(struct kobject *kobj)
@@ -193,7 +193,6 @@ int class_register_type(struct obd_ops *dt_ops, struct md_ops *md_ops,
 	/* md_ops is optional */
 	if (md_ops)
 		*type->typ_md_ops = *md_ops;
-	spin_lock_init(&type->obd_type_lock);
 
 	if (ldt) {
 		type->typ_lu = ldt;
@@ -220,8 +219,8 @@ int class_unregister_type(const char *name)
 		return -EINVAL;
 	}
 
-	if (type->typ_refcnt) {
-		CERROR("type %s has refcount (%d)\n", name, type->typ_refcnt);
+	if (atomic_read(&type->typ_refcnt)) {
+		CERROR("type %s has refcount (%d)\n", name, atomic_read(&type->typ_refcnt));
 		/* This is a bad situation, let's make the best of it */
 		/* Remove ops, but leave the name for debugging */
 		kfree(type->typ_dt_ops);
diff --git a/fs/lustre/obdclass/lu_object.c b/fs/lustre/obdclass/lu_object.c
index 9c872db..770cc1b 100644
--- a/fs/lustre/obdclass/lu_object.c
+++ b/fs/lustre/obdclass/lu_object.c
@@ -1267,7 +1267,7 @@ void lu_stack_fini(const struct lu_env *env, struct lu_device *top)
 		next = ldt->ldt_ops->ldto_device_free(env, scan);
 		type = ldt->ldt_obd_type;
 		if (type) {
-			type->typ_refcnt--;
+			atomic_dec(&type->typ_refcnt);
 			class_put_type(type);
 		}
 	}
diff --git a/fs/lustre/obdclass/obd_config.c b/fs/lustre/obdclass/obd_config.c
index 0cdadea4..0da69f6 100644
--- a/fs/lustre/obdclass/obd_config.c
+++ b/fs/lustre/obdclass/obd_config.c
@@ -743,25 +743,6 @@ void class_put_profile(struct lustre_profile *lprof)
 }
 EXPORT_SYMBOL(class_put_profile);
 
-/* COMPAT_146 */
-void class_del_profiles(void)
-{
-	struct lustre_profile *lprof, *n;
-
-	spin_lock(&lustre_profile_list_lock);
-	list_for_each_entry_safe(lprof, n, &lustre_profile_list, lp_list) {
-		list_del(&lprof->lp_list);
-		lprof->lp_list_deleted = true;
-		spin_unlock(&lustre_profile_list_lock);
-
-		class_put_profile(lprof);
-
-		spin_lock(&lustre_profile_list_lock);
-	}
-	spin_unlock(&lustre_profile_list_lock);
-}
-EXPORT_SYMBOL(class_del_profiles);
-
 /* We can't call lquota_process_config directly because
  * it lives in a module that must be loaded after this one.
  */
-- 
1.8.3.1
