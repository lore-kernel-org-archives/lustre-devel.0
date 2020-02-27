From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:08:02 -0500
Subject: [lustre-devel] [PATCH 014/622] lustre: mdc: fix possible NULL
 pointer dereference
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-15-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Andreas Dilger <adilger@whamcloud.com>

Fix two static analysis errors.

fs/lustre/mdc/mdc_dev.c: in mdc_enqueue_send(), pointer 'matched' return
    from call to function 'ldlm_handle2lock' at line 704 may be NULL
    and will be dereferenced at line 705.
If client is evicted between ldlm_lock_match() and ldlm_handle2lock()
the lock pointer could be NULL.

fs/lustre/lov/lov_dev.c:488 in lov_process_config, sscanf format
    specification '%d' expects type 'int' for 'd', but parameter 3
    has a different type '__u32'.
Converting to kstrtou32() requires changing the "index" variable type
from __u32 to u32, which is fine since it is only used internally,
fix up the few functions that are also passing "__u32 index" and the
resulting checkpatch.pl warnings.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10264
Lustre-commit: b89206476174 ("LU-10264 mdc: fix possible NULL pointer dereference")
Signed-off-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/31621
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Bob Glossman <bob.glossman@intel.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/lov/lov_obd.c | 45 ++++++++++++++++++++++++---------------------
 fs/lustre/mdc/mdc_dev.c |  2 +-
 2 files changed, 25 insertions(+), 22 deletions(-)

diff --git a/fs/lustre/lov/lov_obd.c b/fs/lustre/lov/lov_obd.c
index 1708fa9..26637bc 100644
--- a/fs/lustre/lov/lov_obd.c
+++ b/fs/lustre/lov/lov_obd.c
@@ -312,7 +312,8 @@ static int lov_disconnect(struct obd_export *exp)
 {
 	struct obd_device *obd = class_exp2obd(exp);
 	struct lov_obd *lov = &obd->u.lov;
-	int i, rc;
+	u32 index;
+	int rc;
 
 	if (!lov->lov_tgts)
 		goto out;
@@ -321,19 +322,19 @@ static int lov_disconnect(struct obd_export *exp)
 	lov->lov_connects--;
 	if (lov->lov_connects != 0) {
 		/* why should there be more than 1 connect? */
-		CERROR("disconnect #%d\n", lov->lov_connects);
+		CWARN("%s: unexpected disconnect #%d\n",
+		      obd->obd_name, lov->lov_connects);
 		goto out;
 	}
 
-	/* Let's hold another reference so lov_del_obd doesn't spin through
-	 * putref every time
-	 */
+	/* hold another ref so lov_del_obd() doesn't spin in putref each time */
 	lov_tgts_getref(obd);
 
-	for (i = 0; i < lov->desc.ld_tgt_count; i++) {
-		if (lov->lov_tgts[i] && lov->lov_tgts[i]->ltd_exp) {
-			/* Disconnection is the last we know about an obd */
-			lov_del_target(obd, i, NULL, lov->lov_tgts[i]->ltd_gen);
+	for (index = 0; index < lov->desc.ld_tgt_count; index++) {
+		if (lov->lov_tgts[index] && lov->lov_tgts[index]->ltd_exp) {
+			/* Disconnection is the last we know about an OBD */
+			lov_del_target(obd, index, NULL,
+				       lov->lov_tgts[index]->ltd_gen);
 		}
 	}
 
@@ -490,13 +491,12 @@ static int lov_add_target(struct obd_device *obd, struct obd_uuid *uuidp,
 	       uuidp->uuid, index, gen, active);
 
 	if (gen <= 0) {
-		CERROR("request to add OBD %s with invalid generation: %d\n",
-		       uuidp->uuid, gen);
+		CERROR("%s: request to add '%s' with invalid generation: %d\n",
+		       obd->obd_name, uuidp->uuid, gen);
 		return -EINVAL;
 	}
 
-	tgt_obd = class_find_client_obd(uuidp, LUSTRE_OSC_NAME,
-					&obd->obd_uuid);
+	tgt_obd = class_find_client_obd(uuidp, LUSTRE_OSC_NAME, &obd->obd_uuid);
 	if (!tgt_obd)
 		return -EINVAL;
 
@@ -504,10 +504,11 @@ static int lov_add_target(struct obd_device *obd, struct obd_uuid *uuidp,
 
 	if ((index < lov->lov_tgt_size) && lov->lov_tgts[index]) {
 		tgt = lov->lov_tgts[index];
-		CERROR("UUID %s already assigned at LOV target index %d\n",
-		       obd_uuid2str(&tgt->ltd_uuid), index);
+		rc = -EEXIST;
+		CERROR("%s: UUID %s already assigned at index %d: rc = %d\n",
+		       obd->obd_name, obd_uuid2str(&tgt->ltd_uuid), index, rc);
 		mutex_unlock(&lov->lov_lock);
-		return -EEXIST;
+		return rc;
 	}
 
 	if (index >= lov->lov_tgt_size) {
@@ -602,8 +603,8 @@ static int lov_add_target(struct obd_device *obd, struct obd_uuid *uuidp,
 
 out:
 	if (rc) {
-		CERROR("add failed (%d), deleting %s\n", rc,
-		       obd_uuid2str(&tgt->ltd_uuid));
+		CERROR("%s: add failed, deleting %s: rc = %d\n",
+		       obd->obd_name, obd_uuid2str(&tgt->ltd_uuid), rc);
 		lov_del_target(obd, index, NULL, 0);
 	}
 	lov_tgts_putref(obd);
@@ -860,6 +861,7 @@ int lov_process_config_base(struct obd_device *obd, struct lustre_cfg *lcfg,
 	case LCFG_LOV_DEL_OBD: {
 		u32 index;
 		int gen;
+
 		/* lov_modify_tgts add  0:lov_mdsA  1:ost1_UUID  2:0  3:1 */
 		if (LUSTRE_CFG_BUFLEN(lcfg, 1) > sizeof(obd_uuid.uuid)) {
 			rc = -EINVAL;
@@ -868,11 +870,11 @@ int lov_process_config_base(struct obd_device *obd, struct lustre_cfg *lcfg,
 
 		obd_str2uuid(&obd_uuid,  lustre_cfg_buf(lcfg, 1));
 
-		rc = kstrtoint(lustre_cfg_buf(lcfg, 2), 10, indexp);
-		if (rc < 0)
+		rc = kstrtou32(lustre_cfg_buf(lcfg, 2), 10, indexp);
+		if (rc)
 			goto out;
 		rc = kstrtoint(lustre_cfg_buf(lcfg, 3), 10, genp);
-		if (rc < 0)
+		if (rc)
 			goto out;
 		index = *indexp;
 		gen = *genp;
@@ -882,6 +884,7 @@ int lov_process_config_base(struct obd_device *obd, struct lustre_cfg *lcfg,
 			rc = lov_add_target(obd, &obd_uuid, index, gen, 0);
 		else
 			rc = lov_del_target(obd, index, &obd_uuid, gen);
+
 		goto out;
 	}
 	case LCFG_PARAM: {
diff --git a/fs/lustre/mdc/mdc_dev.c b/fs/lustre/mdc/mdc_dev.c
index ca0822d..80e3120 100644
--- a/fs/lustre/mdc/mdc_dev.c
+++ b/fs/lustre/mdc/mdc_dev.c
@@ -684,7 +684,7 @@ int mdc_enqueue_send(const struct lu_env *env, struct obd_export *exp,
 			return ELDLM_OK;
 
 		matched = ldlm_handle2lock(&lockh);
-		if (ldlm_is_kms_ignore(matched))
+		if (!matched || ldlm_is_kms_ignore(matched))
 			goto no_match;
 
 		if (mdc_set_dom_lock_data(env, matched, einfo->ei_cbdata)) {
-- 
1.8.3.1
