From: SF Markus Elfring <elfring@users.sourceforge.net>
Date: Tue, 26 Jul 2016 21:04:34 +0200
Subject: [lustre-devel] [PATCH 04/12] staging: lustre: Split a condition
 check in class_register_type()
In-Reply-To: <59d94e70-7476-728e-5f63-013557ec2db9@users.sourceforge.net>
References: <566ABCD9.1060404@users.sourceforge.net>
	<566D7733.1030102@users.sourceforge.net>
	<56784D83.7080108@users.sourceforge.net>
	<56784F0C.6040007@users.sourceforge.net>
	<20151221234857.GA27079@kroah.com>
	<59d94e70-7476-728e-5f63-013557ec2db9@users.sourceforge.net>
Message-ID: <bfc42c86-3dd1-bef6-e451-1428326d58f2@users.sourceforge.net>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: devel@driverdev.osuosl.org, lustre-devel@lists.lustre.org, Andreas Dilger <andreas.dilger@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Oleg Drokin <oleg.drokin@intel.com>
Cc: LKML <linux-kernel@vger.kernel.org>, kernel-janitors@vger.kernel.org, Julia Lawall <julia.lawall@lip6.fr>, Bhumika Goyal <bhumirks@gmail.com>

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Tue, 26 Jul 2016 14:10:55 +0200

The kfree() function was called in up to three cases by the
class_register_type() function during error handling even if
the passed data structure element contained a null pointer.

* Split a condition check for memory allocation failures.

* Improve this implementation detail by the introduction of a few
  jump labels.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/staging/lustre/lustre/obdclass/genops.c | 22 +++++++++++++++++-----
 1 file changed, 17 insertions(+), 5 deletions(-)

diff --git a/drivers/staging/lustre/lustre/obdclass/genops.c b/drivers/staging/lustre/lustre/obdclass/genops.c
index 10dd145..fd5e61f 100644
--- a/drivers/staging/lustre/lustre/obdclass/genops.c
+++ b/drivers/staging/lustre/lustre/obdclass/genops.c
@@ -158,13 +158,22 @@ int class_register_type(struct obd_ops *dt_ops, struct md_ops *md_ops,
 		return rc;
 
 	type->typ_dt_ops = kzalloc(sizeof(*type->typ_dt_ops), GFP_NOFS);
+	if (!type->typ_dt_ops) {
+		rc = -ENOMEM;
+		goto free_type;
+	}
+
 	type->typ_md_ops = kzalloc(sizeof(*type->typ_md_ops), GFP_NOFS);
-	type->typ_name = kzalloc(strlen(name) + 1, GFP_NOFS);
+	if (!type->typ_dt_ops) {
+		rc = -ENOMEM;
+		goto free_dt_ops;
+	}
 
-	if (!type->typ_dt_ops ||
-	    !type->typ_md_ops ||
-	    !type->typ_name)
-		goto free_name;
+	type->typ_name = kzalloc(strlen(name) + 1, GFP_NOFS);
+	if (!type->typ_name) {
+		rc = -ENOMEM;
+		goto free_md_ops;
+	}
 
 	*(type->typ_dt_ops) = *dt_ops;
 	/* md_ops is optional */
@@ -205,8 +214,11 @@ put_object:
 	kobject_put(type->typ_kobj);
 free_name:
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
2.9.2
