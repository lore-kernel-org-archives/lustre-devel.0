From: SF Markus Elfring <elfring@users.sourceforge.net>
Date: Tue, 26 Jul 2016 21:00:15 +0200
Subject: [lustre-devel] [PATCH 02/12] staging: lustre: Delete unnecessary
 checks before the function call "kobject_put"
In-Reply-To: <59d94e70-7476-728e-5f63-013557ec2db9@users.sourceforge.net>
References: <566ABCD9.1060404@users.sourceforge.net>
	<566D7733.1030102@users.sourceforge.net>
	<56784D83.7080108@users.sourceforge.net>
	<56784F0C.6040007@users.sourceforge.net>
	<20151221234857.GA27079@kroah.com>
	<59d94e70-7476-728e-5f63-013557ec2db9@users.sourceforge.net>
Message-ID: <48f00283-1648-e3f5-a76c-1ced01a4f231@users.sourceforge.net>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: devel@driverdev.osuosl.org, lustre-devel@lists.lustre.org, Andreas Dilger <andreas.dilger@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Oleg Drokin <oleg.drokin@intel.com>
Cc: LKML <linux-kernel@vger.kernel.org>, kernel-janitors@vger.kernel.org, Julia Lawall <julia.lawall@lip6.fr>, Bhumika Goyal <bhumirks@gmail.com>

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Tue, 26 Jul 2016 13:00:32 +0200

The kobject_put() function tests whether its argument is NULL and then
returns immediately. Thus the test around the calls is not needed.

This issue was detected by using the Coccinelle software.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c | 4 +---
 drivers/staging/lustre/lustre/lmv/lmv_obd.c     | 5 ++---
 drivers/staging/lustre/lustre/lov/lov_obd.c     | 4 +---
 drivers/staging/lustre/lustre/obdclass/genops.c | 6 ++----
 4 files changed, 6 insertions(+), 13 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
index 2c1c2fc..52c5dd4 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
@@ -1069,9 +1069,7 @@ static int ldlm_cleanup(void)
 
 	kset_unregister(ldlm_ns_kset);
 	kset_unregister(ldlm_svc_kset);
-	if (ldlm_kobj)
-		kobject_put(ldlm_kobj);
-
+	kobject_put(ldlm_kobj);
 	ldlm_debugfs_cleanup();
 
 	kfree(ldlm_state);
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_obd.c b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
index 0e1588a..8c2e5b3 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_obd.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
@@ -238,7 +238,7 @@ static int lmv_connect(const struct lu_env *env,
 	if (data && data->ocd_connect_flags & OBD_CONNECT_REAL)
 		rc = lmv_check_connect(obd);
 
-	if (rc && lmv->lmv_tgts_kobj)
+	if (rc)
 		kobject_put(lmv->lmv_tgts_kobj);
 
 	return rc;
@@ -648,8 +648,7 @@ static int lmv_disconnect(struct obd_export *exp)
 		lmv_disconnect_mdc(obd, lmv->tgts[i]);
 	}
 
-	if (lmv->lmv_tgts_kobj)
-		kobject_put(lmv->lmv_tgts_kobj);
+	kobject_put(lmv->lmv_tgts_kobj);
 
 out_local:
 	/*
diff --git a/drivers/staging/lustre/lustre/lov/lov_obd.c b/drivers/staging/lustre/lustre/lov/lov_obd.c
index 9b92d55..df701f7 100644
--- a/drivers/staging/lustre/lustre/lov/lov_obd.c
+++ b/drivers/staging/lustre/lustre/lov/lov_obd.c
@@ -106,9 +106,7 @@ static void lov_putref(struct obd_device *obd)
 			__lov_del_obd(obd, tgt);
 		}
 
-		if (lov->lov_tgts_kobj)
-			kobject_put(lov->lov_tgts_kobj);
-
+		kobject_put(lov->lov_tgts_kobj);
 	} else {
 		mutex_unlock(&lov->lov_lock);
 	}
diff --git a/drivers/staging/lustre/lustre/obdclass/genops.c b/drivers/staging/lustre/lustre/obdclass/genops.c
index 99c2da6..1b5aa9b 100644
--- a/drivers/staging/lustre/lustre/obdclass/genops.c
+++ b/drivers/staging/lustre/lustre/obdclass/genops.c
@@ -203,8 +203,7 @@ int class_register_type(struct obd_ops *dt_ops, struct md_ops *md_ops,
 	return 0;
 
  failed:
-	if (type->typ_kobj)
-		kobject_put(type->typ_kobj);
+	kobject_put(type->typ_kobj);
 	kfree(type->typ_name);
 	kfree(type->typ_md_ops);
 	kfree(type->typ_dt_ops);
@@ -231,8 +230,7 @@ int class_unregister_type(const char *name)
 		return -EBUSY;
 	}
 
-	if (type->typ_kobj)
-		kobject_put(type->typ_kobj);
+	kobject_put(type->typ_kobj);
 
 	if (!IS_ERR_OR_NULL(type->typ_debugfs_entry))
 		ldebugfs_remove(&type->typ_debugfs_entry);
-- 
2.9.2
