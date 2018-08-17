From: James Simmons <jsimmons@infradead.org>
Date: Thu, 16 Aug 2018 23:10:22 -0400
Subject: [lustre-devel] [PATCH 19/38] lustre: obdclass: swap obd device
 attrs and default_attrs
In-Reply-To: <1534475441-15543-1-git-send-email-jsimmons@infradead.org>
References: <1534475441-15543-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1534475441-15543-20-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Currently the obd_ktype sets its default_attr field to the
universal obd_def_attr and attaches additional attributes.
Reverse this by making obd device specific attributes the
default and add obd_def_attr as the extra.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-8066
Reviewed-on: https://review.whamcloud.com/28948
Reviewed-by: John L. Hammond <jhammond@whamcloud.com>
Reviewed-by: Sonia Sharma <sharmaso@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/obdclass/lprocfs_status.c | 16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
index c032458..d370fbb 100644
--- a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
+++ b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
@@ -989,7 +989,7 @@ int lprocfs_rd_connect_flags(struct seq_file *m, void *data)
 }
 EXPORT_SYMBOL(lprocfs_rd_connect_flags);
 
-static struct attribute *obd_def_attrs[] = {
+static const struct attribute *obd_def_attrs[] = {
 	&lustre_attr_blocksize.attr,
 	&lustre_attr_kbytestotal.attr,
 	&lustre_attr_kbytesfree.attr,
@@ -1009,7 +1009,6 @@ static void obd_sysfs_release(struct kobject *kobj)
 }
 
 static struct kobj_type obd_ktype = {
-	.default_attrs	= obd_def_attrs,
 	.sysfs_ops	= &lustre_sysfs_ops,
 	.release	= obd_sysfs_release,
 };
@@ -1019,6 +1018,7 @@ int lprocfs_obd_setup(struct obd_device *obd,
 {
 	int rc = 0;
 
+	obd_ktype.default_attrs = attrs->attrs;
 	init_completion(&obd->obd_kobj_unregister);
 	rc = kobject_init_and_add(&obd->obd_kobj, &obd_ktype,
 				  obd->obd_type->typ_kobj,
@@ -1026,12 +1026,10 @@ int lprocfs_obd_setup(struct obd_device *obd,
 	if (rc)
 		return rc;
 
-	if (attrs) {
-		rc = sysfs_create_group(&obd->obd_kobj, attrs);
-		if (rc) {
-			kobject_put(&obd->obd_kobj);
-			return rc;
-		}
+	rc = sysfs_create_files(&obd->obd_kobj, obd_def_attrs);
+	if (rc) {
+		kobject_put(&obd->obd_kobj);
+		return rc;
 	}
 
 	obd->obd_debugfs_entry = debugfs_create_dir(obd->obd_name,
@@ -1049,6 +1047,8 @@ int lprocfs_obd_cleanup(struct obd_device *obd)
 
 	debugfs_remove_recursive(obd->obd_debugfs_entry);
 
+	sysfs_remove_files(&obd->obd_kobj, obd_def_attrs);
+
 	kobject_put(&obd->obd_kobj);
 	wait_for_completion(&obd->obd_kobj_unregister);
 
-- 
1.8.3.1
