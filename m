From: SF Markus Elfring <elfring@users.sourceforge.net>
Date: Thu, 5 Nov 2015 13:20:33 +0100
Subject: [lustre-devel] [PATCH 3/3] staging: lustre: Less function calls in
 class_register_type() after error detection
In-Reply-To: <563B473C.5090508@users.sourceforge.net>
References: <5307CAA2.8060406@users.sourceforge.net>
	<alpine.DEB.2.02.1402212321410.2043@localhost6.localdomain6>
	<530A086E.8010901@users.sourceforge.net>
	<alpine.DEB.2.02.1402231635510.1985@localhost6.localdomain6>
	<530A72AA.3000601@users.sourceforge.net>
	<alpine.DEB.2.02.1402240658210.2090@localhost6.localdomain6>
	<530B5FB6.6010207@users.sourceforge.net>
	<alpine.DEB.2.10.1402241710370.2074@hadrien>
	<530C5E18.1020800@users.sourceforge.net>
	<alpine.DEB.2.10.1402251014170.2080@hadrien>
	<530CD2C4.4050903@users.sourceforge.net>
	<alpine.DEB.2.10.1402251840450.7035@hadrien>
	<530CF8FF.8080600@users.sourceforge.net>
	<alpine.DEB.2.02.1402252117150.2047@localhost6.localdomain6>
	<530DD06F.4090703@users.sourceforge.net>
	<alpine.DEB.2.02.1402262129250.2221@localhost6.localdomain6>
	<5317A59D.4@users.sourceforge.net>
	<563B473C.5090508@users.sourceforge.net>
Message-ID: <563B4991.90005@users.sourceforge.net>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Thu, 5 Nov 2015 12:48:58 +0100

The functions "kfree" and "kobject_put" were called in a few cases by the
function "class_register_type" during error handling even if the passed
variable contained a null pointer.

This implementation detail could be improved by the adjustment of
jump targets.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/staging/lustre/lustre/obdclass/genops.c | 26 +++++++++++++++----------
 1 file changed, 16 insertions(+), 10 deletions(-)

diff --git a/drivers/staging/lustre/lustre/obdclass/genops.c b/drivers/staging/lustre/lustre/obdclass/genops.c
index acb86f0..4d99a39 100644
--- a/drivers/staging/lustre/lustre/obdclass/genops.c
+++ b/drivers/staging/lustre/lustre/obdclass/genops.c
@@ -171,13 +171,16 @@ int class_register_type(struct obd_ops *dt_ops, struct md_ops *md_ops,
 		return rc;
 
 	type->typ_dt_ops = kzalloc(sizeof(*type->typ_dt_ops), GFP_NOFS);
+	if (!type->typ_dt_ops)
+		goto free_type;
+
 	type->typ_md_ops = kzalloc(sizeof(*type->typ_md_ops), GFP_NOFS);
-	type->typ_name = kzalloc(strlen(name) + 1, GFP_NOFS);
+	if (!type->typ_md_ops)
+		goto free_dt_ops;
 
-	if (!type->typ_dt_ops ||
-	    !type->typ_md_ops ||
-	    !type->typ_name)
-		goto failed;
+	type->typ_name = kzalloc(strlen(name) + 1, GFP_NOFS);
+	if (!type->typ_name)
+		goto free_md_ops;
 
 	*(type->typ_dt_ops) = *dt_ops;
 	/* md_ops is optional */
@@ -193,20 +196,20 @@ int class_register_type(struct obd_ops *dt_ops, struct md_ops *md_ops,
 		rc = type->typ_debugfs_entry ? PTR_ERR(type->typ_debugfs_entry)
 					     : -ENOMEM;
 		type->typ_debugfs_entry = NULL;
-		goto failed;
+		goto free_name;
 	}
 
 	type->typ_kobj = kobject_create_and_add(type->typ_name, lustre_kobj);
 	if (!type->typ_kobj) {
 		rc = -ENOMEM;
-		goto failed;
+		goto free_name;
 	}
 
 	if (ldt != NULL) {
 		type->typ_lu = ldt;
 		rc = lu_device_type_init(ldt);
 		if (rc != 0)
-			goto failed;
+			goto put_object;
 	}
 
 	spin_lock(&obd_types_lock);
@@ -214,12 +217,15 @@ int class_register_type(struct obd_ops *dt_ops, struct md_ops *md_ops,
 	spin_unlock(&obd_types_lock);
 
 	return 0;
-
- failed:
+put_object:
 	kobject_put(type->typ_kobj);
+free_name:
 	kfree(type->typ_name);
+free_md_ops:
 	kfree(type->typ_md_ops);
+free_dt_ops:
 	kfree(type->typ_dt_ops);
+free_type:
 	kfree(type);
 	return rc;
 }
-- 
2.6.2
