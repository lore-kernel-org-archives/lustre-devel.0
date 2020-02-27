From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:15:48 -0500
Subject: [lustre-devel] [PATCH 480/622] lustre: mdc: hold obd while
 processing changelog
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-481-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Hongchao Zhang <hongchao@whamcloud.com>

During read/write changelog, the corresponding obd_device should
be held to protect it from being released by umount.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11626
Lustre-commit: d7bb6647cd4d ("LU-11626 mdc: hold obd while processing changelog")
Signed-off-by: Hongchao Zhang <hongchao@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/35784
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Emoly Liu <emoly@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/mdc/mdc_changelog.c | 121 ++++++++++++++++++++++++------------------
 1 file changed, 70 insertions(+), 51 deletions(-)

diff --git a/fs/lustre/mdc/mdc_changelog.c b/fs/lustre/mdc/mdc_changelog.c
index 9af0541..043549d 100644
--- a/fs/lustre/mdc/mdc_changelog.c
+++ b/fs/lustre/mdc/mdc_changelog.c
@@ -69,8 +69,10 @@ struct chlg_registered_dev {
 };
 
 struct chlg_reader_state {
-	/* Device this state is associated with */
-	struct chlg_registered_dev *crs_dev;
+	/* Shortcut to the corresponding OBD device */
+	struct obd_device	*crs_obd;
+	/* the corresponding chlg_registered_dev */
+	struct chlg_registered_dev *crs_ced;
 	/* Producer thread (if any) */
 	struct task_struct	*crs_prod_task;
 	/* An error occurred that prevents from reading further */
@@ -109,6 +111,41 @@ enum {
 };
 
 /**
+ * Deregister a changelog character device whose refcount has reached zero.
+ */
+static void chlg_dev_clear(struct kref *kref)
+{
+	struct chlg_registered_dev *entry = container_of(kref,
+						struct chlg_registered_dev,
+						ced_refs);
+
+	list_del(&entry->ced_link);
+	misc_deregister(&entry->ced_misc);
+	kfree(entry);
+}
+
+static inline struct obd_device *chlg_obd_get(struct chlg_registered_dev *dev)
+{
+	struct obd_device *obd;
+
+	mutex_lock(&chlg_registered_dev_lock);
+	if (list_empty(&dev->ced_obds))
+		return NULL;
+
+	obd = list_first_entry(&dev->ced_obds, struct obd_device,
+			       u.cli.cl_chg_dev_linkage);
+	class_incref(obd, "changelog", dev);
+	mutex_unlock(&chlg_registered_dev_lock);
+	return obd;
+}
+
+static inline void chlg_obd_put(struct chlg_registered_dev *dev,
+			 struct obd_device *obd)
+{
+	class_decref(obd, "changelog", dev);
+}
+
+/**
  * ChangeLog catalog processing callback invoked on each record.
  * If the current record is eligible to userland delivery, push
  * it into the crs_rec_queue where the consumer code will fetch it.
@@ -142,7 +179,7 @@ static int chlg_read_cat_process_cb(const struct lu_env *env,
 	if (rec->cr_hdr.lrh_type != CHANGELOG_REC) {
 		rc = -EINVAL;
 		CERROR("%s: not a changelog rec %x/%d in llog : rc = %d\n",
-		       crs->crs_dev->ced_name, rec->cr_hdr.lrh_type,
+		       crs->crs_obd->obd_name, rec->cr_hdr.lrh_type,
 		       rec->cr.cr_type, rc);
 		return rc;
 	}
@@ -193,17 +230,6 @@ static void enq_record_delete(struct chlg_rec_entry *rec)
 	kfree(rec);
 }
 
-/*
- * Find any OBD device associated with this reader
- * chlg_registered_dev_lock is held.
- */
-static inline struct obd_device *chlg_obd_get(struct chlg_registered_dev *dev)
-{
-	return list_first_entry_or_null(&dev->ced_obds,
-					struct obd_device,
-					u.cli.cl_chg_dev_linkage);
-}
-
 /**
  * Record prefetch thread entry point. Opens the changelog catalog and starts
  * reading records.
@@ -215,27 +241,28 @@ static inline struct obd_device *chlg_obd_get(struct chlg_registered_dev *dev)
 static int chlg_load(void *args)
 {
 	struct chlg_reader_state *crs = args;
+	struct chlg_registered_dev *ced = crs->crs_ced;
 	struct obd_device *obd;
 	struct llog_ctxt *ctx = NULL;
 	struct llog_handle *llh = NULL;
 	int rc;
 
-	mutex_lock(&chlg_registered_dev_lock);
-	obd = chlg_obd_get(crs->crs_dev);
-	if (!obd) {
-		rc = -ENOENT;
-		goto err_out;
-	}
+	crs->crs_last_catidx = -1;
+	crs->crs_last_idx = 0;
+
+again:
+	obd = chlg_obd_get(ced);
+	if (!obd)
+		return -ENODEV;
+
+	crs->crs_obd = obd;
+
 	ctx = llog_get_context(obd, LLOG_CHANGELOG_REPL_CTXT);
 	if (!ctx) {
 		rc = -ENOENT;
 		goto err_out;
 	}
 
-	crs->crs_last_catidx = -1;
-	crs->crs_last_idx = 0;
-
-again:
 	rc = llog_open(NULL, ctx, &llh, NULL, CHANGELOG_CATALOG,
 		       LLOG_OPEN_EXISTS);
 	if (rc) {
@@ -268,6 +295,8 @@ static int chlg_load(void *args)
 	}
 	if (!kthread_should_stop() && crs->crs_poll) {
 		llog_cat_close(NULL, llh);
+		llog_ctxt_put(ctx);
+		class_decref(obd, "changelog", crs);
 		schedule_timeout_interruptible(HZ);
 		goto again;
 	}
@@ -275,7 +304,6 @@ static int chlg_load(void *args)
 	crs->crs_eof = true;
 
 err_out:
-	mutex_unlock(&chlg_registered_dev_lock);
 	if (rc < 0)
 		crs->crs_err = rc;
 
@@ -287,6 +315,8 @@ static int chlg_load(void *args)
 	if (ctx)
 		llog_ctxt_put(ctx);
 
+	crs->crs_obd = NULL;
+	chlg_obd_put(ced, obd);
 	wait_event_idle(crs->crs_waitq_prod, kthread_should_stop());
 
 	return rc;
@@ -454,19 +484,19 @@ static int chlg_clear(struct chlg_reader_state *crs, u32 reader, u64 record)
 		.cs_recno = record,
 		.cs_id    = reader
 	};
-	int ret;
+	int rc;
 
-	mutex_lock(&chlg_registered_dev_lock);
-	obd = chlg_obd_get(crs->crs_dev);
+	obd = chlg_obd_get(crs->crs_ced);
 	if (!obd)
-		ret = -ENOENT;
-	else
-		ret = obd_set_info_async(NULL, obd->obd_self_export,
-					 strlen(KEY_CHANGELOG_CLEAR),
-					 KEY_CHANGELOG_CLEAR, sizeof(cs),
-					 &cs, NULL);
-	mutex_unlock(&chlg_registered_dev_lock);
-	return ret;
+		return -ENODEV;
+
+	rc = obd_set_info_async(NULL, obd->obd_self_export,
+				strlen(KEY_CHANGELOG_CLEAR),
+				KEY_CHANGELOG_CLEAR, sizeof(cs),
+				&cs, NULL);
+	chlg_obd_put(crs->crs_ced, obd);
+
+	return rc;
 }
 
 /** Maximum changelog control command size */
@@ -540,7 +570,8 @@ static int chlg_open(struct inode *inode, struct file *file)
 	if (!crs)
 		return -ENOMEM;
 
-	crs->crs_dev = dev;
+	kref_get(&dev->ced_refs);
+	crs->crs_ced = dev;
 	crs->crs_err = false;
 	crs->crs_eof = false;
 
@@ -564,6 +595,7 @@ static int chlg_open(struct inode *inode, struct file *file)
 	return 0;
 
 err_crs:
+	kref_put(&dev->ced_refs, chlg_dev_clear);
 	kfree(crs);
 	return rc;
 }
@@ -589,6 +621,7 @@ static int chlg_release(struct inode *inode, struct file *file)
 	list_for_each_entry_safe(rec, tmp, &crs->crs_rec_queue, enq_linkage)
 		enq_record_delete(rec);
 
+	kref_put(&crs->crs_ced->ced_refs, chlg_dev_clear);
 	kfree(crs);
 	return rc;
 }
@@ -763,20 +796,6 @@ int mdc_changelog_cdev_init(struct obd_device *obd)
 }
 
 /**
- * Deregister a changelog character device whose refcount has reached zero.
- */
-static void chlg_dev_clear(struct kref *kref)
-{
-	struct chlg_registered_dev *entry = container_of(kref,
-							 struct chlg_registered_dev,
-							 ced_refs);
-	LASSERT(mutex_is_locked(&chlg_registered_dev_lock));
-	list_del(&entry->ced_link);
-	misc_deregister(&entry->ced_misc);
-	kfree(entry);
-}
-
-/**
  * Release OBD, decrease reference count of the corresponding changelog device.
  */
 void mdc_changelog_cdev_finish(struct obd_device *obd)
-- 
1.8.3.1
