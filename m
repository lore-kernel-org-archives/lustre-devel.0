From: James Simmons <jsimmons@infradead.org>
Date: Mon, 20 May 2019 08:50:53 -0400
Subject: [lustre-devel] [PATCH v2 11/29] lustre: obdclass: don't copy ops
 structures in to new type.
In-Reply-To: <1558356671-29599-1-git-send-email-jsimmons@infradead.org>
References: <1558356671-29599-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1558356671-29599-12-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: NeilBrown <neilb@suse.com>

The obd_ops and md_ops structures passed to class_register_type() are
read-only, and have a lifetime that is exceeds the lifetime of the
obd_type - they are static in a module which unregisters the type before
being unloaded.

So there is no need to copy the ops, just store a pointer.

Also mark all the structures as read-only to confirm they don't get
written.  This is best-practice for structures of function pointers.

Reviewed-by: James Simmons <jsimmons@infradead.org>
Signed-off-by: NeilBrown <neilb@suse.com>
---
 fs/lustre/include/obd.h         |  4 ++--
 fs/lustre/include/obd_class.h   |  3 ++-
 fs/lustre/lmv/lmv_obd.c         |  4 ++--
 fs/lustre/lov/lov_obd.c         |  2 +-
 fs/lustre/mdc/mdc_request.c     |  4 ++--
 fs/lustre/mgc/mgc_request.c     |  2 +-
 fs/lustre/obdclass/genops.c     | 22 ++++++----------------
 fs/lustre/obdecho/echo_client.c |  2 +-
 fs/lustre/osc/osc_request.c     |  2 +-
 9 files changed, 18 insertions(+), 27 deletions(-)

diff --git a/fs/lustre/include/obd.h b/fs/lustre/include/obd.h
index 61fb815..3bdde31 100644
--- a/fs/lustre/include/obd.h
+++ b/fs/lustre/include/obd.h
@@ -99,8 +99,8 @@ struct obd_info {
 };
 
 struct obd_type {
-	struct obd_ops		*typ_dt_ops;
-	struct md_ops		*typ_md_ops;
+	const struct obd_ops	*typ_dt_ops;
+	const struct md_ops	*typ_md_ops;
 	struct dentry		*typ_debugfs_entry;
 	atomic_t		 typ_refcnt;
 	struct lu_device_type	*typ_lu;
diff --git a/fs/lustre/include/obd_class.h b/fs/lustre/include/obd_class.h
index a853ed5..a3394b2 100644
--- a/fs/lustre/include/obd_class.h
+++ b/fs/lustre/include/obd_class.h
@@ -60,7 +60,8 @@
 
 /* genops.c */
 struct obd_export *class_conn2export(struct lustre_handle *conn);
-int class_register_type(struct obd_ops *dt_ops, struct md_ops *md_ops,
+int class_register_type(const struct obd_ops *dt_ops,
+			const struct md_ops *md_ops,
 			const char *name, struct lu_device_type *ldt);
 int class_unregister_type(const char *name);
 
diff --git a/fs/lustre/lmv/lmv_obd.c b/fs/lustre/lmv/lmv_obd.c
index aae80c7..64ebaf3 100644
--- a/fs/lustre/lmv/lmv_obd.c
+++ b/fs/lustre/lmv/lmv_obd.c
@@ -3043,7 +3043,7 @@ static int lmv_merge_attr(struct obd_export *exp,
 	return 0;
 }
 
-static struct obd_ops lmv_obd_ops = {
+static const struct obd_ops lmv_obd_ops = {
 	.owner			= THIS_MODULE,
 	.setup			= lmv_setup,
 	.cleanup		= lmv_cleanup,
@@ -3060,7 +3060,7 @@ static int lmv_merge_attr(struct obd_export *exp,
 	.quotactl		= lmv_quotactl
 };
 
-static struct md_ops lmv_md_ops = {
+static const struct md_ops lmv_md_ops = {
 	.get_root		= lmv_get_root,
 	.null_inode		= lmv_null_inode,
 	.close			= lmv_close,
diff --git a/fs/lustre/lov/lov_obd.c b/fs/lustre/lov/lov_obd.c
index 203923f..652ed6a 100644
--- a/fs/lustre/lov/lov_obd.c
+++ b/fs/lustre/lov/lov_obd.c
@@ -1332,7 +1332,7 @@ static int lov_quotactl(struct obd_device *obd, struct obd_export *exp,
 	return rc;
 }
 
-static struct obd_ops lov_obd_ops = {
+static const struct obd_ops lov_obd_ops = {
 	.owner		= THIS_MODULE,
 	.setup		= lov_setup,
 	.cleanup	= lov_cleanup,
diff --git a/fs/lustre/mdc/mdc_request.c b/fs/lustre/mdc/mdc_request.c
index 705a4e3..6f933b5 100644
--- a/fs/lustre/mdc/mdc_request.c
+++ b/fs/lustre/mdc/mdc_request.c
@@ -2571,7 +2571,7 @@ static int mdc_process_config(struct obd_device *obd, u32 len, void *buf)
 	return count > 0 ? 0 : count;
 }
 
-static struct obd_ops mdc_obd_ops = {
+static const struct obd_ops mdc_obd_ops = {
 	.owner			= THIS_MODULE,
 	.setup			= mdc_setup,
 	.precleanup		= mdc_precleanup,
@@ -2593,7 +2593,7 @@ static int mdc_process_config(struct obd_device *obd, u32 len, void *buf)
 	.quotactl		= mdc_quotactl,
 };
 
-static struct md_ops mdc_md_ops = {
+static const struct md_ops mdc_md_ops = {
 	.get_root		= mdc_get_root,
 	.null_inode		= mdc_null_inode,
 	.close			= mdc_close,
diff --git a/fs/lustre/mgc/mgc_request.c b/fs/lustre/mgc/mgc_request.c
index d8be54d..1eca81a 100644
--- a/fs/lustre/mgc/mgc_request.c
+++ b/fs/lustre/mgc/mgc_request.c
@@ -1810,7 +1810,7 @@ static int mgc_process_config(struct obd_device *obd, u32 len, void *buf)
 	return rc;
 }
 
-static struct obd_ops mgc_obd_ops = {
+static const struct obd_ops mgc_obd_ops = {
 	.owner		= THIS_MODULE,
 	.setup		= mgc_setup,
 	.precleanup	= mgc_precleanup,
diff --git a/fs/lustre/obdclass/genops.c b/fs/lustre/obdclass/genops.c
index 9c9ad9c..6d33414 100644
--- a/fs/lustre/obdclass/genops.c
+++ b/fs/lustre/obdclass/genops.c
@@ -141,8 +141,6 @@ static void class_sysfs_release(struct kobject *kobj)
 
 	debugfs_remove_recursive(type->typ_debugfs_entry);
 
-	kfree(type->typ_md_ops);
-	kfree(type->typ_dt_ops);
 	kfree(type);
 }
 
@@ -153,7 +151,8 @@ static void class_sysfs_release(struct kobject *kobj)
 
 #define CLASS_MAX_NAME 1024
 
-int class_register_type(struct obd_ops *dt_ops, struct md_ops *md_ops,
+int class_register_type(const struct obd_ops *dt_ops,
+			const struct md_ops *md_ops,
 			const char *name,
 			struct lu_device_type *ldt)
 {
@@ -182,17 +181,8 @@ int class_register_type(struct obd_ops *dt_ops, struct md_ops *md_ops,
 
 	type->typ_debugfs_entry = debugfs_create_dir(name, debugfs_lustre_root);
 
-	type->typ_dt_ops = kzalloc(sizeof(*type->typ_dt_ops), GFP_NOFS);
-	type->typ_md_ops = kzalloc(sizeof(*type->typ_md_ops), GFP_NOFS);
-
-	if (!type->typ_dt_ops ||
-	    !type->typ_md_ops)
-		goto failed;
-
-	*type->typ_dt_ops = *dt_ops;
-	/* md_ops is optional */
-	if (md_ops)
-		*type->typ_md_ops = *md_ops;
+	type->typ_dt_ops = dt_ops;
+	type->typ_md_ops = md_ops;
 
 	if (ldt) {
 		type->typ_lu = ldt;
@@ -223,8 +213,8 @@ int class_unregister_type(const char *name)
 		CERROR("type %s has refcount (%d)\n", name, atomic_read(&type->typ_refcnt));
 		/* This is a bad situation, let's make the best of it */
 		/* Remove ops, but leave the name for debugging */
-		kfree(type->typ_dt_ops);
-		kfree(type->typ_md_ops);
+		type->typ_dt_ops = NULL;
+		type->typ_md_ops = NULL;
 		kobject_put(&type->typ_kobj);
 		return -EBUSY;
 	}
diff --git a/fs/lustre/obdecho/echo_client.c b/fs/lustre/obdecho/echo_client.c
index 317123f..baf34c8 100644
--- a/fs/lustre/obdecho/echo_client.c
+++ b/fs/lustre/obdecho/echo_client.c
@@ -1676,7 +1676,7 @@ static int echo_client_disconnect(struct obd_export *exp)
 	return rc;
 }
 
-static struct obd_ops echo_client_obd_ops = {
+static const struct obd_ops echo_client_obd_ops = {
 	.owner			= THIS_MODULE,
 	.iocontrol		= echo_client_iocontrol,
 	.connect		= echo_client_connect,
diff --git a/fs/lustre/osc/osc_request.c b/fs/lustre/osc/osc_request.c
index 104bf43..9484b9a 100644
--- a/fs/lustre/osc/osc_request.c
+++ b/fs/lustre/osc/osc_request.c
@@ -2988,7 +2988,7 @@ static int osc_process_config(struct obd_device *obd, u32 len, void *buf)
 	return osc_process_config_base(obd, buf);
 }
 
-static struct obd_ops osc_obd_ops = {
+static const struct obd_ops osc_obd_ops = {
 	.owner		= THIS_MODULE,
 	.setup		= osc_setup,
 	.precleanup	= osc_precleanup,
-- 
1.8.3.1
