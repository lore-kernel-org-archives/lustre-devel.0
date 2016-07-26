From: SF Markus Elfring <elfring@users.sourceforge.net>
Date: Tue, 26 Jul 2016 21:02:33 +0200
Subject: [lustre-devel] [PATCH 03/12] staging: lustre: One function call
 less in class_register_type() after error detection
In-Reply-To: <59d94e70-7476-728e-5f63-013557ec2db9@users.sourceforge.net>
References: <566ABCD9.1060404@users.sourceforge.net>
	<566D7733.1030102@users.sourceforge.net>
	<56784D83.7080108@users.sourceforge.net>
	<56784F0C.6040007@users.sourceforge.net>
	<20151221234857.GA27079@kroah.com>
	<59d94e70-7476-728e-5f63-013557ec2db9@users.sourceforge.net>
Message-ID: <a92aee0c-7a2c-a509-c19e-44cc9d8335a1@users.sourceforge.net>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: devel@driverdev.osuosl.org, lustre-devel@lists.lustre.org, Andreas Dilger <andreas.dilger@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Oleg Drokin <oleg.drokin@intel.com>
Cc: LKML <linux-kernel@vger.kernel.org>, kernel-janitors@vger.kernel.org, Julia Lawall <julia.lawall@lip6.fr>, Bhumika Goyal <bhumirks@gmail.com>

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Tue, 26 Jul 2016 13:40:47 +0200

The kobject_put() function was called in a few cases by the
class_register_type() function during error handling even if the passed
data structure element did not contain a pointer for a valid data item.

Adjust jump targets according to the Linux coding style convention.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/staging/lustre/lustre/obdclass/genops.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/staging/lustre/lustre/obdclass/genops.c b/drivers/staging/lustre/lustre/obdclass/genops.c
index 1b5aa9b..10dd145 100644
--- a/drivers/staging/lustre/lustre/obdclass/genops.c
+++ b/drivers/staging/lustre/lustre/obdclass/genops.c
@@ -164,7 +164,7 @@ int class_register_type(struct obd_ops *dt_ops, struct md_ops *md_ops,
 	if (!type->typ_dt_ops ||
 	    !type->typ_md_ops ||
 	    !type->typ_name)
-		goto failed;
+		goto free_name;
 
 	*(type->typ_dt_ops) = *dt_ops;
 	/* md_ops is optional */
@@ -180,20 +180,20 @@ int class_register_type(struct obd_ops *dt_ops, struct md_ops *md_ops,
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
 
 	if (ldt) {
 		type->typ_lu = ldt;
 		rc = lu_device_type_init(ldt);
 		if (rc != 0)
-			goto failed;
+			goto put_object;
 	}
 
 	spin_lock(&obd_types_lock);
@@ -201,9 +201,9 @@ int class_register_type(struct obd_ops *dt_ops, struct md_ops *md_ops,
 	spin_unlock(&obd_types_lock);
 
 	return 0;
-
- failed:
+put_object:
 	kobject_put(type->typ_kobj);
+free_name:
 	kfree(type->typ_name);
 	kfree(type->typ_md_ops);
 	kfree(type->typ_dt_ops);
-- 
2.9.2
