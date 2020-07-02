From: James Simmons <jsimmons@infradead.org>
Date: Wed,  1 Jul 2020 20:04:48 -0400
Subject: [lustre-devel] [PATCH 08/18] lustre: mdc: chlg device could be used
 after free
In-Reply-To: <1593648298-10571-1-git-send-email-jsimmons@infradead.org>
References: <1593648298-10571-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1593648298-10571-9-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Hongchao Zhang <hongchao@whamcloud.com>

There are some issue of the usage of dynamic devices used by
the changelog in MDC, which could cause the device to be used
after it is freed.

WC-bug-id: https://jira.whamcloud.com/browse/LU-13508
Lustre-commit: 1e992e94eaf8a ("LU-13508 mdc: chlg device could be used after free")
Signed-off-by: Hongchao Zhang <hongchao@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/38658
Reviewed-by: John L. Hammond <jhammond@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/mdc/mdc_changelog.c | 46 ++++++++++++++++++++-----------------------
 fs/lustre/mdc/mdc_internal.h  |  1 +
 fs/lustre/mdc/mdc_request.c   |  8 +++++---
 3 files changed, 27 insertions(+), 28 deletions(-)

diff --git a/fs/lustre/mdc/mdc_changelog.c b/fs/lustre/mdc/mdc_changelog.c
index 3aace7e..8531edb 100644
--- a/fs/lustre/mdc/mdc_changelog.c
+++ b/fs/lustre/mdc/mdc_changelog.c
@@ -61,7 +61,7 @@ struct chlg_registered_dev {
 	char			ced_name[32];
 	/* changelog char device */
 	struct cdev		ced_cdev;
-	struct device		*ced_device;
+	struct device		ced_device;
 	/* OBDs referencing this device (multiple mount point) */
 	struct list_head	ced_obds;
 	/* Reference counter for proper deregistration */
@@ -112,7 +112,7 @@ enum {
 	CDEV_CHLG_MAX_PREFETCH = 1024,
 };
 
-static DEFINE_IDR(chlg_minor_idr);
+DEFINE_IDR(mdc_changelog_minor_idr);
 static DEFINE_SPINLOCK(chlg_minor_lock);
 
 static int chlg_minor_alloc(int *pminor)
@@ -122,7 +122,7 @@ static int chlg_minor_alloc(int *pminor)
 
 	idr_preload(GFP_KERNEL);
 	spin_lock(&chlg_minor_lock);
-	minor = idr_alloc(&chlg_minor_idr, minor_allocated, 0,
+	minor = idr_alloc(&mdc_changelog_minor_idr, minor_allocated, 0,
 			  MDC_CHANGELOG_DEV_COUNT, GFP_NOWAIT);
 	spin_unlock(&chlg_minor_lock);
 	idr_preload_end();
@@ -137,7 +137,7 @@ static int chlg_minor_alloc(int *pminor)
 static void chlg_minor_free(int minor)
 {
 	spin_lock(&chlg_minor_lock);
-	idr_remove(&chlg_minor_idr, minor);
+	idr_remove(&mdc_changelog_minor_idr, minor);
 	spin_unlock(&chlg_minor_lock);
 }
 
@@ -160,8 +160,8 @@ static void chlg_dev_clear(struct kref *kref)
 			     ced_refs);
 
 	list_del(&entry->ced_link);
-	cdev_del(&entry->ced_cdev);
-	device_destroy(mdc_changelog_class, entry->ced_cdev.dev);
+	cdev_device_del(&entry->ced_cdev, &entry->ced_device);
+	put_device(&entry->ced_device);
 }
 
 static inline struct obd_device *chlg_obd_get(struct chlg_registered_dev *dev)
@@ -790,8 +790,6 @@ int mdc_changelog_cdev_init(struct obd_device *obd)
 {
 	struct chlg_registered_dev *exist;
 	struct chlg_registered_dev *entry;
-	struct device *device;
-	dev_t dev;
 	int minor, rc;
 
 	entry = kzalloc(sizeof(*entry), GFP_KERNEL);
@@ -816,35 +814,33 @@ int mdc_changelog_cdev_init(struct obd_device *obd)
 	list_add_tail(&obd->u.cli.cl_chg_dev_linkage, &entry->ced_obds);
 	list_add_tail(&entry->ced_link, &chlg_registered_devices);
 
-	/* Register new character device */
-	cdev_init(&entry->ced_cdev, &chlg_fops);
-	entry->ced_cdev.owner = THIS_MODULE;
-
 	rc = chlg_minor_alloc(&minor);
 	if (rc)
 		goto out_unlock;
 
-	dev = MKDEV(MAJOR(mdc_changelog_dev), minor);
-	rc = cdev_add(&entry->ced_cdev, dev, 1);
+	device_initialize(&entry->ced_device);
+	entry->ced_device.devt = MKDEV(MAJOR(mdc_changelog_dev), minor);
+	entry->ced_device.class = mdc_changelog_class;
+	entry->ced_device.release = chlg_device_release;
+	dev_set_drvdata(&entry->ced_device, entry);
+	rc = dev_set_name(&entry->ced_device, "%s-%s", MDC_CHANGELOG_DEV_NAME,
+			  entry->ced_name);
 	if (rc)
 		goto out_minor;
 
-	device = device_create(mdc_changelog_class, NULL, dev, entry, "%s-%s",
-			       MDC_CHANGELOG_DEV_NAME, entry->ced_name);
-	if (IS_ERR(device)) {
-		rc = PTR_ERR(device);
-		goto out_cdev;
-	}
-
-	device->release = chlg_device_release;
-	entry->ced_device = device;
+	/* Register new character device */
+	cdev_init(&entry->ced_cdev, &chlg_fops);
+	entry->ced_cdev.owner = THIS_MODULE;
+	rc = cdev_device_add(&entry->ced_cdev, &entry->ced_device);
+	if (rc)
+		goto out_device_name;
 
 	entry = NULL;	/* prevent it from being freed below */
 	rc = 0;
 	goto out_unlock;
 
-out_cdev:
-	cdev_del(&entry->ced_cdev);
+out_device_name:
+	kfree_const(entry->ced_device.kobj.name);
 
 out_minor:
 	chlg_minor_free(minor);
diff --git a/fs/lustre/mdc/mdc_internal.h b/fs/lustre/mdc/mdc_internal.h
index 9656231..b7ccc58 100644
--- a/fs/lustre/mdc/mdc_internal.h
+++ b/fs/lustre/mdc/mdc_internal.h
@@ -142,6 +142,7 @@ enum ldlm_mode mdc_lock_match(struct obd_export *exp, u64 flags,
 #define MDC_CHANGELOG_DEV_NAME "changelog"
 extern struct class *mdc_changelog_class;
 extern dev_t mdc_changelog_dev;
+extern struct idr mdc_changelog_minor_idr;
 
 int mdc_changelog_cdev_init(struct obd_device *obd);
 
diff --git a/fs/lustre/mdc/mdc_request.c b/fs/lustre/mdc/mdc_request.c
index 369114b..d6d9f43 100644
--- a/fs/lustre/mdc/mdc_request.c
+++ b/fs/lustre/mdc/mdc_request.c
@@ -3013,10 +3013,12 @@ static int __init mdc_init(void)
 	rc = class_register_type(&mdc_obd_ops, &mdc_md_ops,
 				 LUSTRE_MDC_NAME, &mdc_device_type);
 	if (rc)
-		goto out_dev;
+		goto out_class;
 
 	return 0;
 
+out_class:
+	class_destroy(mdc_changelog_class);
 out_dev:
 	unregister_chrdev_region(mdc_changelog_dev, MDC_CHANGELOG_DEV_COUNT);
 	return rc;
@@ -3024,9 +3026,9 @@ static int __init mdc_init(void)
 
 static void __exit mdc_exit(void)
 {
-	class_destroy(mdc_changelog_class);
-	unregister_chrdev_region(mdc_changelog_dev, MDC_CHANGELOG_DEV_COUNT);
 	class_unregister_type(LUSTRE_MDC_NAME);
+	class_destroy(mdc_changelog_class);
+	idr_destroy(&mdc_changelog_minor_idr);
 }
 
 MODULE_AUTHOR("OpenSFS, Inc. <http://www.lustre.org/>");
-- 
1.8.3.1
