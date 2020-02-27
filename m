From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:08:37 -0500
Subject: [lustre-devel] [PATCH 049/622] lustre: lov: Move lov_tgts_kobj init
 to lov_setup
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-50-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Oleg Drokin <green@whamcloud.com>

and free it in lov_cleanup.
This looks like a more robust solution vs doint it in lov_putref
esp. since we know refcount there crosses 0 repeatedly, confusing
things.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11015
Lustre-commit: 313ac16698db ("LU-11015 lov: Move lov_tgts_kobj init to lov_setup")
Signed-off-by: Oleg Drokin <green@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/32367
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: John L. Hammond <jhammond@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/lov/lov_obd.c | 15 ++++++++-------
 1 file changed, 8 insertions(+), 7 deletions(-)

diff --git a/fs/lustre/lov/lov_obd.c b/fs/lustre/lov/lov_obd.c
index 26637bc..9449aa9 100644
--- a/fs/lustre/lov/lov_obd.c
+++ b/fs/lustre/lov/lov_obd.c
@@ -110,10 +110,6 @@ void lov_tgts_putref(struct obd_device *obd)
 			/* Disconnect */
 			__lov_del_obd(obd, tgt);
 		}
-
-		if (lov->lov_tgts_kobj)
-			kobject_put(lov->lov_tgts_kobj);
-
 	} else {
 		mutex_unlock(&lov->lov_lock);
 	}
@@ -235,9 +231,6 @@ static int lov_connect(const struct lu_env *env,
 
 	lov_tgts_getref(obd);
 
-	lov->lov_tgts_kobj = kobject_create_and_add("target_obds",
-						    &obd->obd_kset.kobj);
-
 	for (i = 0; i < lov->desc.ld_tgt_count; i++) {
 		tgt = lov->lov_tgts[i];
 		if (!tgt || obd_uuid_empty(&tgt->ltd_uuid))
@@ -784,6 +777,9 @@ int lov_setup(struct obd_device *obd, struct lustre_cfg *lcfg)
 	if (rc)
 		goto out_tunables;
 
+	lov->lov_tgts_kobj = kobject_create_and_add("target_obds",
+						    &obd->obd_kset.kobj);
+
 	return 0;
 
 out_tunables:
@@ -799,6 +795,11 @@ static int lov_cleanup(struct obd_device *obd)
 	struct lov_obd *lov = &obd->u.lov;
 	struct pool_desc *pool, *tmp;
 
+	if (lov->lov_tgts_kobj) {
+		kobject_put(lov->lov_tgts_kobj);
+		lov->lov_tgts_kobj = NULL;
+	}
+
 	list_for_each_entry_safe(pool, tmp, &lov->lov_pool_list, pool_list) {
 		/* free pool structs */
 		CDEBUG(D_INFO, "delete pool %p\n", pool);
-- 
1.8.3.1
