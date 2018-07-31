From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Jul 2018 22:26:16 -0400
Subject: [lustre-devel] [PATCH 24/31] lustre: obdclass: use static
 initializer macros where possible
In-Reply-To: <1533003983-29311-1-git-send-email-jsimmons@infradead.org>
References: <1533003983-29311-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1533003983-29311-25-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: "John L. Hammond" <jhammond@whamcloud.com>

In obdclass replace module load time initialization of several
atomics, lists, locks, mutexes, wait queues, etc with static
initialization using the kernel provided macros.

Signed-off-by: John L. Hammond <jhammond@whamcloud.com>
WC-id: https://jira.whamcloud.com/browse/LU-9010
Reviewed-on: https://review.whamcloud.com/24827
Reviewed-by: Steve Guminski <stephenx.guminski@intel.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/lu_object.h  |  6 -----
 drivers/staging/lustre/lustre/include/obd_class.h  |  6 -----
 drivers/staging/lustre/lustre/obdclass/class_obd.c | 26 +++++-----------------
 drivers/staging/lustre/lustre/obdclass/genops.c    |  5 ++++-
 drivers/staging/lustre/lustre/obdclass/lu_object.c | 15 -------------
 .../staging/lustre/lustre/obdclass/lustre_peer.c   | 16 ++-----------
 6 files changed, 12 insertions(+), 62 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lu_object.h b/drivers/staging/lustre/lustre/include/lu_object.h
index 4153db7..47f8021 100644
--- a/drivers/staging/lustre/lustre/include/lu_object.h
+++ b/drivers/staging/lustre/lustre/include/lu_object.h
@@ -330,12 +330,6 @@ struct lu_device_type {
 	 * Number of existing device type instances.
 	 */
 	atomic_t				ldt_device_nr;
-	/**
-	 * Linkage into a global list of all device types.
-	 *
-	 * \see lu_device_types.
-	 */
-	struct list_head			      ldt_linkage;
 };
 
 /**
diff --git a/drivers/staging/lustre/lustre/include/obd_class.h b/drivers/staging/lustre/lustre/include/obd_class.h
index e772e3d..184da99 100644
--- a/drivers/staging/lustre/lustre/include/obd_class.h
+++ b/drivers/staging/lustre/lustre/include/obd_class.h
@@ -48,7 +48,6 @@
 #define OBD_STATFS_FOR_MDT0	0x0004
 
 /* OBD Device Declarations */
-extern struct obd_device *obd_devs[MAX_OBD_DEVICES];
 extern rwlock_t obd_dev_lock;
 
 /* OBD Operations Declarations */
@@ -59,7 +58,6 @@
 struct lu_device_type;
 
 /* genops.c */
-extern struct list_head obd_types;
 struct obd_export *class_conn2export(struct lustre_handle *conn);
 int class_register_type(struct obd_ops *dt_ops, struct md_ops *md_ops,
 			const char *name, struct lu_device_type *ldt);
@@ -133,7 +131,6 @@ void class_decref(struct obd_device *obd,
 int class_config_llog_handler(const struct lu_env *env,
 			      struct llog_handle *handle,
 			      struct llog_rec_hdr *rec, void *data);
-int class_add_uuid(const char *uuid, __u64 nid);
 
 /* obdecho */
 void lprocfs_echo_init_vars(struct lprocfs_static_vars *lvars);
@@ -1576,13 +1573,10 @@ struct lwp_register_item {
 int class_add_uuid(const char *uuid, __u64 nid);
 int class_del_uuid(const char *uuid);
 int class_check_uuid(struct obd_uuid *uuid, __u64 nid);
-void class_init_uuidlist(void);
-void class_exit_uuidlist(void);
 
 /* class_obd.c */
 extern char obd_jobid_node[];
 extern struct miscdevice obd_psdev;
-extern spinlock_t obd_types_lock;
 int class_procfs_init(void);
 int class_procfs_clean(void);
 
diff --git a/drivers/staging/lustre/lustre/obdclass/class_obd.c b/drivers/staging/lustre/lustre/obdclass/class_obd.c
index 04e55fc..05ae6e1 100644
--- a/drivers/staging/lustre/lustre/obdclass/class_obd.c
+++ b/drivers/staging/lustre/lustre/obdclass/class_obd.c
@@ -49,10 +49,6 @@
 #include <uapi/linux/lnet/libcfs_ioctl.h>
 #include "llog_internal.h"
 
-struct obd_device *obd_devs[MAX_OBD_DEVICES];
-struct list_head obd_types;
-DEFINE_RWLOCK(obd_dev_lock);
-
 /* The following are visible and mutable through /sys/fs/lustre. */
 unsigned int obd_debug_peer_on_timeout;
 EXPORT_SYMBOL(obd_debug_peer_on_timeout);
@@ -455,28 +451,25 @@ static int obd_init_checks(void)
 
 static int __init obdclass_init(void)
 {
-	int i, err;
+	int err;
 
 	LCONSOLE_INFO("Lustre: Build Version: " LUSTRE_VERSION_STRING "\n");
 
-	spin_lock_init(&obd_types_lock);
-
 	err = libcfs_setup();
 	if (err)
 		return err;
 
-	obd_zombie_impexp_init();
+	err = obd_zombie_impexp_init();
+	if (err)
+		return err;
 
 	err = obd_init_checks();
 	if (err)
 		goto cleanup_zombie_impexp;
 
-	class_init_uuidlist();
 	err = class_handle_init();
 	if (err)
-		goto cleanup_uuidlist;
-
-	INIT_LIST_HEAD(&obd_types);
+		goto cleanup_zombie_impexp;
 
 	err = misc_register(&obd_psdev);
 	if (err) {
@@ -484,10 +477,6 @@ static int __init obdclass_init(void)
 		goto cleanup_class_handle;
 	}
 
-	/* This struct is already zeroed for us (static global) */
-	for (i = 0; i < class_devno_max(); i++)
-		obd_devs[i] = NULL;
-
 	/* Default the dirty page cache cap to 1/2 of system memory.
 	 * For clients with less memory, a larger fraction is needed
 	 * for other purposes (mostly for BGL).
@@ -550,9 +539,6 @@ static int __init obdclass_init(void)
 cleanup_class_handle:
 	class_handle_cleanup();
 
-cleanup_uuidlist:
-	class_exit_uuidlist();
-
 cleanup_zombie_impexp:
 	obd_zombie_impexp_stop();
 
@@ -571,7 +557,7 @@ static void obdclass_exit(void)
 	class_procfs_clean();
 
 	class_handle_cleanup();
-	class_exit_uuidlist();
+	class_del_uuid(NULL); /* Delete all UUIDs. */
 	obd_zombie_impexp_stop();
 }
 
diff --git a/drivers/staging/lustre/lustre/obdclass/genops.c b/drivers/staging/lustre/lustre/obdclass/genops.c
index 8454b44..532418e 100644
--- a/drivers/staging/lustre/lustre/obdclass/genops.c
+++ b/drivers/staging/lustre/lustre/obdclass/genops.c
@@ -41,7 +41,10 @@
 #include <lprocfs_status.h>
 #include <lustre_kernelcomm.h>
 
-spinlock_t obd_types_lock;
+static DEFINE_SPINLOCK(obd_types_lock);
+static LIST_HEAD(obd_types);
+DEFINE_RWLOCK(obd_dev_lock);
+static struct obd_device *obd_devs[MAX_OBD_DEVICES];
 
 static struct kmem_cache *obd_device_cachep;
 struct kmem_cache *obdo_cachep;
diff --git a/drivers/staging/lustre/lustre/obdclass/lu_object.c b/drivers/staging/lustre/lustre/obdclass/lu_object.c
index 2d24eb6..cb57abf 100644
--- a/drivers/staging/lustre/lustre/obdclass/lu_object.c
+++ b/drivers/staging/lustre/lustre/obdclass/lu_object.c
@@ -764,35 +764,20 @@ struct lu_object *lu_object_find_slice(const struct lu_env *env,
 }
 EXPORT_SYMBOL(lu_object_find_slice);
 
-/**
- * Global list of all device types.
- */
-static LIST_HEAD(lu_device_types);
-
 int lu_device_type_init(struct lu_device_type *ldt)
 {
 	int result = 0;
 
 	atomic_set(&ldt->ldt_device_nr, 0);
-	INIT_LIST_HEAD(&ldt->ldt_linkage);
 	if (ldt->ldt_ops->ldto_init)
 		result = ldt->ldt_ops->ldto_init(ldt);
 
-	if (!result) {
-		spin_lock(&obd_types_lock);
-		list_add(&ldt->ldt_linkage, &lu_device_types);
-		spin_unlock(&obd_types_lock);
-	}
-
 	return result;
 }
 EXPORT_SYMBOL(lu_device_type_init);
 
 void lu_device_type_fini(struct lu_device_type *ldt)
 {
-	spin_lock(&obd_types_lock);
-	list_del_init(&ldt->ldt_linkage);
-	spin_unlock(&obd_types_lock);
 	if (ldt->ldt_ops->ldto_fini)
 		ldt->ldt_ops->ldto_fini(ldt);
 }
diff --git a/drivers/staging/lustre/lustre/obdclass/lustre_peer.c b/drivers/staging/lustre/lustre/obdclass/lustre_peer.c
index 7fc62b7..5705b0a 100644
--- a/drivers/staging/lustre/lustre/obdclass/lustre_peer.c
+++ b/drivers/staging/lustre/lustre/obdclass/lustre_peer.c
@@ -51,20 +51,8 @@ struct uuid_nid_data {
 };
 
 /* FIXME: This should probably become more elegant than a global linked list */
-static struct list_head	g_uuid_list;
-static spinlock_t	g_uuid_lock;
-
-void class_init_uuidlist(void)
-{
-	INIT_LIST_HEAD(&g_uuid_list);
-	spin_lock_init(&g_uuid_lock);
-}
-
-void class_exit_uuidlist(void)
-{
-	/* delete all */
-	class_del_uuid(NULL);
-}
+static LIST_HEAD(g_uuid_list);
+static DEFINE_SPINLOCK(g_uuid_lock);
 
 int lustre_uuid_to_peer(const char *uuid, lnet_nid_t *peer_nid, int index)
 {
-- 
1.8.3.1
