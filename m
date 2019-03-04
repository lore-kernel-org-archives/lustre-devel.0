From: NeilBrown <neilb@suse.com>
Date: Mon, 04 Mar 2019 17:31:38 +1100
Subject: [lustre-devel] [PATCH 06/28] lustre: obdclass: don't copy ops
 structures in to new type.
In-Reply-To: <155168107971.31333.14345309795939467246.stgit@noble.brown>
References: <155168107971.31333.14345309795939467246.stgit@noble.brown>
Message-ID: <155168109829.31333.13564841187188502779.stgit@noble.brown>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

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
 drivers/staging/lustre/lustre/include/obd.h        |    4 ++--
 drivers/staging/lustre/lustre/include/obd_class.h  |    3 ++-
 drivers/staging/lustre/lustre/lmv/lmv_obd.c        |    4 ++--
 drivers/staging/lustre/lustre/lov/lov_obd.c        |    2 +-
 drivers/staging/lustre/lustre/mdc/mdc_request.c    |    4 ++--
 drivers/staging/lustre/lustre/mgc/mgc_request.c    |    2 +-
 drivers/staging/lustre/lustre/obdclass/genops.c    |   22 +++++---------------
 .../staging/lustre/lustre/obdecho/echo_client.c    |    2 +-
 drivers/staging/lustre/lustre/osc/osc_request.c    |    2 +-
 9 files changed, 18 insertions(+), 27 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/obd.h b/drivers/staging/lustre/lustre/include/obd.h
index 61fb8159af20..3bdde312e4a6 100644
--- a/drivers/staging/lustre/lustre/include/obd.h
+++ b/drivers/staging/lustre/lustre/include/obd.h
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
diff --git a/drivers/staging/lustre/lustre/include/obd_class.h b/drivers/staging/lustre/lustre/include/obd_class.h
index bf6ce3284bef..4567ef3b21dc 100644
--- a/drivers/staging/lustre/lustre/include/obd_class.h
+++ b/drivers/staging/lustre/lustre/include/obd_class.h
@@ -61,7 +61,8 @@ struct lu_device_type;
 /* genops.c */
 struct obd_export *class_conn2export(struct lustre_handle *conn);
 struct kobject *class_setup_tunables(const char *name);
-int class_register_type(struct obd_ops *dt_ops, struct md_ops *md_ops,
+int class_register_type(const struct obd_ops *dt_ops,
+			const struct md_ops *md_ops,
 			const char *name, struct lu_device_type *ldt);
 int class_unregister_type(const char *name);
 
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_obd.c b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
index aae80c7f725b..64ebaf399530 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_obd.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
@@ -3043,7 +3043,7 @@ static int lmv_merge_attr(struct obd_export *exp,
 	return 0;
 }
 
-static struct obd_ops lmv_obd_ops = {
+static const struct obd_ops lmv_obd_ops = {
 	.owner			= THIS_MODULE,
 	.setup			= lmv_setup,
 	.cleanup		= lmv_cleanup,
@@ -3060,7 +3060,7 @@ static struct obd_ops lmv_obd_ops = {
 	.quotactl		= lmv_quotactl
 };
 
-static struct md_ops lmv_md_ops = {
+static const struct md_ops lmv_md_ops = {
 	.get_root		= lmv_get_root,
 	.null_inode		= lmv_null_inode,
 	.close			= lmv_close,
diff --git a/drivers/staging/lustre/lustre/lov/lov_obd.c b/drivers/staging/lustre/lustre/lov/lov_obd.c
index 203923f9bd96..652ed6a20af3 100644
--- a/drivers/staging/lustre/lustre/lov/lov_obd.c
+++ b/drivers/staging/lustre/lustre/lov/lov_obd.c
@@ -1332,7 +1332,7 @@ static int lov_quotactl(struct obd_device *obd, struct obd_export *exp,
 	return rc;
 }
 
-static struct obd_ops lov_obd_ops = {
+static const struct obd_ops lov_obd_ops = {
 	.owner		= THIS_MODULE,
 	.setup		= lov_setup,
 	.cleanup	= lov_cleanup,
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_request.c b/drivers/staging/lustre/lustre/mdc/mdc_request.c
index 705a4e3b518a..6f933b511366 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_request.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_request.c
@@ -2571,7 +2571,7 @@ static int mdc_process_config(struct obd_device *obd, u32 len, void *buf)
 	return count > 0 ? 0 : count;
 }
 
-static struct obd_ops mdc_obd_ops = {
+static const struct obd_ops mdc_obd_ops = {
 	.owner			= THIS_MODULE,
 	.setup			= mdc_setup,
 	.precleanup		= mdc_precleanup,
@@ -2593,7 +2593,7 @@ static struct obd_ops mdc_obd_ops = {
 	.quotactl		= mdc_quotactl,
 };
 
-static struct md_ops mdc_md_ops = {
+static const struct md_ops mdc_md_ops = {
 	.get_root		= mdc_get_root,
 	.null_inode		= mdc_null_inode,
 	.close			= mdc_close,
diff --git a/drivers/staging/lustre/lustre/mgc/mgc_request.c b/drivers/staging/lustre/lustre/mgc/mgc_request.c
index 0580afa2755d..5ce49e708287 100644
--- a/drivers/staging/lustre/lustre/mgc/mgc_request.c
+++ b/drivers/staging/lustre/lustre/mgc/mgc_request.c
@@ -1817,7 +1817,7 @@ static int mgc_process_config(struct obd_device *obd, u32 len, void *buf)
 	return rc;
 }
 
-static struct obd_ops mgc_obd_ops = {
+static const struct obd_ops mgc_obd_ops = {
 	.owner		= THIS_MODULE,
 	.setup		= mgc_setup,
 	.precleanup	= mgc_precleanup,
diff --git a/drivers/staging/lustre/lustre/obdclass/genops.c b/drivers/staging/lustre/lustre/obdclass/genops.c
index 02d829617519..dc09c302a246 100644
--- a/drivers/staging/lustre/lustre/obdclass/genops.c
+++ b/drivers/staging/lustre/lustre/obdclass/genops.c
@@ -153,8 +153,6 @@ static void class_sysfs_release(struct kobject *kobj)
 	if (type->typ_lu)
 		lu_device_type_fini(type->typ_lu);
 
-	kfree(type->typ_md_ops);
-	kfree(type->typ_dt_ops);
 	kfree(type);
 }
 
@@ -185,7 +183,8 @@ EXPORT_SYMBOL(class_setup_tunables);
 
 #define CLASS_MAX_NAME 1024
 
-int class_register_type(struct obd_ops *dt_ops, struct md_ops *md_ops,
+int class_register_type(const struct obd_ops *dt_ops,
+			const struct md_ops *md_ops,
 			const char *name,
 			struct lu_device_type *ldt)
 {
@@ -210,17 +209,8 @@ int class_register_type(struct obd_ops *dt_ops, struct md_ops *md_ops,
 	type->typ_kobj.kset = lustre_kset;
 	kobject_init(&type->typ_kobj, &class_ktype);
 
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
 
 	rc = kobject_add(&type->typ_kobj, &lustre_kset->kobj, "%s", name);
 	if (rc)
@@ -258,8 +248,8 @@ int class_unregister_type(const char *name)
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
diff --git a/drivers/staging/lustre/lustre/obdecho/echo_client.c b/drivers/staging/lustre/lustre/obdecho/echo_client.c
index 317123fd27cb..baf34c85c4b5 100644
--- a/drivers/staging/lustre/lustre/obdecho/echo_client.c
+++ b/drivers/staging/lustre/lustre/obdecho/echo_client.c
@@ -1676,7 +1676,7 @@ static int echo_client_disconnect(struct obd_export *exp)
 	return rc;
 }
 
-static struct obd_ops echo_client_obd_ops = {
+static const struct obd_ops echo_client_obd_ops = {
 	.owner			= THIS_MODULE,
 	.iocontrol		= echo_client_iocontrol,
 	.connect		= echo_client_connect,
diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
index 104bf4391fef..9484b9a90483 100644
--- a/drivers/staging/lustre/lustre/osc/osc_request.c
+++ b/drivers/staging/lustre/lustre/osc/osc_request.c
@@ -2988,7 +2988,7 @@ static int osc_process_config(struct obd_device *obd, u32 len, void *buf)
 	return osc_process_config_base(obd, buf);
 }
 
-static struct obd_ops osc_obd_ops = {
+static const struct obd_ops osc_obd_ops = {
 	.owner		= THIS_MODULE,
 	.setup		= osc_setup,
 	.precleanup	= osc_precleanup,
