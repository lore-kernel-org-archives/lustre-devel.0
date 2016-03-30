From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Wed, 30 Mar 2016 19:48:35 -0400
Subject: [lustre-devel] [PATCH v2 14/46] staging/lustre/lmv: remove
	lmv_init_{lock, unlock}()
In-Reply-To: <1459381747-2886687-1-git-send-email-green@linuxhacker.ru>
References: <1459381747-2886687-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1459381747-2886687-15-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, "John L. Hammond" <john.hammond@intel.com>, Oleg Drokin <green@linuxhacker.ru>

From: "John L. Hammond" <john.hammond@intel.com>

In struct lmv_obd rename the init_mutex member to
lmv_init_mutex. Remove the compat macros lmv_init_{lock,unlock}() and
use mutex_{lock,unlock}(&lmv->lmv_init_mutex) instead.

Signed-off-by: John L. Hammond <john.hammond@intel.com>
Reviewed-on: http://review.whamcloud.com/12115
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-2675
Reviewed-by: Bob Glossman <bob.glossman@intel.com>
Reviewed-by: James Simmons <uja.ornl@gmail.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/include/obd.h      |  2 +-
 drivers/staging/lustre/lustre/lmv/lmv_internal.h |  3 ---
 drivers/staging/lustre/lustre/lmv/lmv_obd.c      | 24 ++++++++++++------------
 3 files changed, 13 insertions(+), 16 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/obd.h b/drivers/staging/lustre/lustre/include/obd.h
index 26182ca..15c514c 100644
--- a/drivers/staging/lustre/lustre/include/obd.h
+++ b/drivers/staging/lustre/lustre/include/obd.h
@@ -512,7 +512,7 @@ struct lmv_obd {
 	struct obd_uuid		cluuid;
 	struct obd_export	*exp;
 
-	struct mutex		init_mutex;
+	struct mutex		lmv_init_mutex;
 	int			connected;
 	int			max_easize;
 	int			max_def_easize;
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_internal.h b/drivers/staging/lustre/lustre/lmv/lmv_internal.h
index 8a00871..7007e4c 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_internal.h
+++ b/drivers/staging/lustre/lustre/lmv/lmv_internal.h
@@ -42,9 +42,6 @@
 
 #define LMV_MAX_TGT_COUNT 128
 
-#define lmv_init_lock(lmv)   mutex_lock(&lmv->init_mutex)
-#define lmv_init_unlock(lmv) mutex_unlock(&lmv->init_mutex)
-
 #define LL_IT2STR(it)					\
 	((it) ? ldlm_it2str((it)->it_op) : "0")
 
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_obd.c b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
index e3a7216..8bd2dc5 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_obd.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
@@ -425,7 +425,7 @@ static int lmv_add_target(struct obd_device *obd, struct obd_uuid *uuidp,
 
 	CDEBUG(D_CONFIG, "Target uuid: %s. index %d\n", uuidp->uuid, index);
 
-	lmv_init_lock(lmv);
+	mutex_lock(&lmv->lmv_init_mutex);
 
 	if (lmv->desc.ld_tgt_count == 0) {
 		struct obd_device *mdc_obd;
@@ -433,7 +433,7 @@ static int lmv_add_target(struct obd_device *obd, struct obd_uuid *uuidp,
 		mdc_obd = class_find_client_obd(uuidp, LUSTRE_MDC_NAME,
 						&obd->obd_uuid);
 		if (!mdc_obd) {
-			lmv_init_unlock(lmv);
+			mutex_unlock(&lmv->lmv_init_mutex);
 			CERROR("%s: Target %s not attached: rc = %d\n",
 			       obd->obd_name, uuidp->uuid, -EINVAL);
 			return -EINVAL;
@@ -445,7 +445,7 @@ static int lmv_add_target(struct obd_device *obd, struct obd_uuid *uuidp,
 		CERROR("%s: UUID %s already assigned at LOV target index %d: rc = %d\n",
 		       obd->obd_name,
 		       obd_uuid2str(&tgt->ltd_uuid), index, -EEXIST);
-		lmv_init_unlock(lmv);
+		mutex_unlock(&lmv->lmv_init_mutex);
 		return -EEXIST;
 	}
 
@@ -459,7 +459,7 @@ static int lmv_add_target(struct obd_device *obd, struct obd_uuid *uuidp,
 			newsize <<= 1;
 		newtgts = kcalloc(newsize, sizeof(*newtgts), GFP_NOFS);
 		if (!newtgts) {
-			lmv_init_unlock(lmv);
+			mutex_unlock(&lmv->lmv_init_mutex);
 			return -ENOMEM;
 		}
 
@@ -481,7 +481,7 @@ static int lmv_add_target(struct obd_device *obd, struct obd_uuid *uuidp,
 
 	tgt = kzalloc(sizeof(*tgt), GFP_NOFS);
 	if (!tgt) {
-		lmv_init_unlock(lmv);
+		mutex_unlock(&lmv->lmv_init_mutex);
 		return -ENOMEM;
 	}
 
@@ -507,7 +507,7 @@ static int lmv_add_target(struct obd_device *obd, struct obd_uuid *uuidp,
 		}
 	}
 
-	lmv_init_unlock(lmv);
+	mutex_unlock(&lmv->lmv_init_mutex);
 	return rc;
 }
 
@@ -522,14 +522,14 @@ int lmv_check_connect(struct obd_device *obd)
 	if (lmv->connected)
 		return 0;
 
-	lmv_init_lock(lmv);
+	mutex_lock(&lmv->lmv_init_mutex);
 	if (lmv->connected) {
-		lmv_init_unlock(lmv);
+		mutex_unlock(&lmv->lmv_init_mutex);
 		return 0;
 	}
 
 	if (lmv->desc.ld_tgt_count == 0) {
-		lmv_init_unlock(lmv);
+		mutex_unlock(&lmv->lmv_init_mutex);
 		CERROR("%s: no targets configured.\n", obd->obd_name);
 		return -EINVAL;
 	}
@@ -551,7 +551,7 @@ int lmv_check_connect(struct obd_device *obd)
 	lmv->connected = 1;
 	easize = lmv_get_easize(lmv);
 	lmv_init_ea_size(obd->obd_self_export, easize, 0, 0, 0);
-	lmv_init_unlock(lmv);
+	mutex_unlock(&lmv->lmv_init_mutex);
 	return 0;
 
  out_disc:
@@ -572,7 +572,7 @@ int lmv_check_connect(struct obd_device *obd)
 		}
 	}
 	class_disconnect(lmv->exp);
-	lmv_init_unlock(lmv);
+	mutex_unlock(&lmv->lmv_init_mutex);
 	return rc;
 }
 
@@ -1269,7 +1269,7 @@ static int lmv_setup(struct obd_device *obd, struct lustre_cfg *lcfg)
 	lmv->lmv_placement = PLACEMENT_CHAR_POLICY;
 
 	spin_lock_init(&lmv->lmv_lock);
-	mutex_init(&lmv->init_mutex);
+	mutex_init(&lmv->lmv_init_mutex);
 
 	lprocfs_lmv_init_vars(&lvars);
 
-- 
2.1.0
