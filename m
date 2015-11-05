From: SF Markus Elfring <elfring@users.sourceforge.net>
Date: Thu, 5 Nov 2015 13:15:52 +0100
Subject: [lustre-devel] [PATCH 1/3] staging: lustre: Delete unnecessary
 checks before two function calls
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
Message-ID: <563B4878.7000106@users.sourceforge.net>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Thu, 5 Nov 2015 10:18:45 +0100

The functions kobject_put() and kset_unregister() test whether their
argument is NULL and then return immediately.
Thus the tests around their calls are not needed.

This issue was detected by using the Coccinelle software.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c | 10 +++-------
 drivers/staging/lustre/lustre/lmv/lmv_obd.c     |  5 ++---
 drivers/staging/lustre/lustre/lov/lov_obd.c     |  4 +---
 drivers/staging/lustre/lustre/obdclass/genops.c |  6 ++----
 4 files changed, 8 insertions(+), 17 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
index ca11511..e67e84b 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
@@ -1062,13 +1062,9 @@ static int ldlm_cleanup(void)
 	if (ldlm_state->ldlm_cb_service != NULL)
 		ptlrpc_unregister_service(ldlm_state->ldlm_cb_service);
 
-	if (ldlm_ns_kset)
-		kset_unregister(ldlm_ns_kset);
-	if (ldlm_svc_kset)
-		kset_unregister(ldlm_svc_kset);
-	if (ldlm_kobj)
-		kobject_put(ldlm_kobj);
-
+	kset_unregister(ldlm_ns_kset);
+	kset_unregister(ldlm_svc_kset);
+	kobject_put(ldlm_kobj);
 	ldlm_debugfs_cleanup();
 
 	kfree(ldlm_state);
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_obd.c b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
index 635a93c..c3c8e8c 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_obd.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
@@ -240,7 +240,7 @@ static int lmv_connect(const struct lu_env *env,
 	if (data->ocd_connect_flags & OBD_CONNECT_REAL)
 		rc = lmv_check_connect(obd);
 
-	if (rc && lmv->lmv_tgts_kobj)
+	if (rc)
 		kobject_put(lmv->lmv_tgts_kobj);
 
 	return rc;
@@ -646,8 +646,7 @@ static int lmv_disconnect(struct obd_export *exp)
 		lmv_disconnect_mdc(obd, lmv->tgts[i]);
 	}
 
-	if (lmv->lmv_tgts_kobj)
-		kobject_put(lmv->lmv_tgts_kobj);
+	kobject_put(lmv->lmv_tgts_kobj);
 
 out_local:
 	/*
diff --git a/drivers/staging/lustre/lustre/lov/lov_obd.c b/drivers/staging/lustre/lustre/lov/lov_obd.c
index 7abe484..910c62c 100644
--- a/drivers/staging/lustre/lustre/lov/lov_obd.c
+++ b/drivers/staging/lustre/lustre/lov/lov_obd.c
@@ -109,9 +109,7 @@ static void lov_putref(struct obd_device *obd)
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
index 6477aeb..a1cf8e1 100644
--- a/drivers/staging/lustre/lustre/obdclass/genops.c
+++ b/drivers/staging/lustre/lustre/obdclass/genops.c
@@ -216,8 +216,7 @@ int class_register_type(struct obd_ops *dt_ops, struct md_ops *md_ops,
 	return 0;
 
  failed:
-	if (type->typ_kobj)
-		kobject_put(type->typ_kobj);
+	kobject_put(type->typ_kobj);
 	kfree(type->typ_name);
 	kfree(type->typ_md_ops);
 	kfree(type->typ_dt_ops);
@@ -244,8 +243,7 @@ int class_unregister_type(const char *name)
 		return -EBUSY;
 	}
 
-	if (type->typ_kobj)
-		kobject_put(type->typ_kobj);
+	kobject_put(type->typ_kobj);
 
 	if (!IS_ERR_OR_NULL(type->typ_debugfs_entry))
 		ldebugfs_remove(&type->typ_debugfs_entry);
-- 
2.6.2
