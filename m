From: James Simmons <jsimmons@infradead.org>
Date: Thu, 10 Nov 2016 12:30:38 -0500
Subject: [lustre-devel] [PATCH 08/35] staging: lustre: lmv: lock necessary
	part of lmv_add_target
In-Reply-To: <1478799065-24841-1-git-send-email-jsimmons@infradead.org>
References: <1478799065-24841-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1478799065-24841-9-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, wang di <di.wang@intel.com>, James Simmons <jsimmons@infradead.org>

From: wang di <di.wang@intel.com>

Release lmv_init_mutex once the new target is added
into lmv_tgt_desc, so lmv_obd_connect will not be
serialized.

New target should be allowed to added to fld client
lists, so FLD can always choose new added target to
do the FLD lookup request, and also remove some noise
error messages in this process.

Signed-off-by: wang di <di.wang@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6713
Reviewed-on: http://review.whamcloud.com/15269
Reviewed-by: Niu Yawei <yawei.niu@intel.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/fld/fld_internal.h   |    5 --
 drivers/staging/lustre/lustre/fld/fld_request.c    |    8 ---
 drivers/staging/lustre/lustre/include/lustre_fld.h |    2 -
 drivers/staging/lustre/lustre/lmv/lmv_obd.c        |   53 ++++++++++----------
 4 files changed, 27 insertions(+), 41 deletions(-)

diff --git a/drivers/staging/lustre/lustre/fld/fld_internal.h b/drivers/staging/lustre/lustre/fld/fld_internal.h
index 08eaec7..4a7f0b7 100644
--- a/drivers/staging/lustre/lustre/fld/fld_internal.h
+++ b/drivers/staging/lustre/lustre/fld/fld_internal.h
@@ -62,11 +62,6 @@
 #include "../include/lustre_req_layout.h"
 #include "../include/lustre_fld.h"
 
-enum {
-	LUSTRE_FLD_INIT = 1 << 0,
-	LUSTRE_FLD_RUN  = 1 << 1
-};
-
 struct fld_stats {
 	__u64   fst_count;
 	__u64   fst_cache;
diff --git a/drivers/staging/lustre/lustre/fld/fld_request.c b/drivers/staging/lustre/lustre/fld/fld_request.c
index 0de72b7..4cade7a 100644
--- a/drivers/staging/lustre/lustre/fld/fld_request.c
+++ b/drivers/staging/lustre/lustre/fld/fld_request.c
@@ -159,11 +159,6 @@ int fld_client_add_target(struct lu_client_fld *fld,
 	LASSERT(name);
 	LASSERT(tar->ft_srv || tar->ft_exp);
 
-	if (fld->lcf_flags != LUSTRE_FLD_INIT) {
-		CERROR("%s: Attempt to add target %s (idx %llu) on fly - skip it\n",
-		       fld->lcf_name, name, tar->ft_idx);
-		return 0;
-	}
 	CDEBUG(D_INFO, "%s: Adding target %s (idx %llu)\n",
 	       fld->lcf_name, name, tar->ft_idx);
 
@@ -282,7 +277,6 @@ int fld_client_init(struct lu_client_fld *fld,
 	fld->lcf_count = 0;
 	spin_lock_init(&fld->lcf_lock);
 	fld->lcf_hash = &fld_hash[hash];
-	fld->lcf_flags = LUSTRE_FLD_INIT;
 	INIT_LIST_HEAD(&fld->lcf_targets);
 
 	cache_size = FLD_CLIENT_CACHE_SIZE /
@@ -421,8 +415,6 @@ int fld_client_lookup(struct lu_client_fld *fld, u64 seq, u32 *mds,
 	struct lu_fld_target *target;
 	int rc;
 
-	fld->lcf_flags |= LUSTRE_FLD_RUN;
-
 	rc = fld_cache_lookup(fld->lcf_cache, seq, &res);
 	if (rc == 0) {
 		*mds = res.lsr_index;
diff --git a/drivers/staging/lustre/lustre/include/lustre_fld.h b/drivers/staging/lustre/lustre/include/lustre_fld.h
index 932410d..6ef1b03 100644
--- a/drivers/staging/lustre/lustre/include/lustre_fld.h
+++ b/drivers/staging/lustre/lustre/include/lustre_fld.h
@@ -103,8 +103,6 @@ struct lu_client_fld {
 
 	/** Client fld debugfs entry name. */
 	char			 lcf_name[LUSTRE_MDT_MAXNAMELEN];
-
-	int			 lcf_flags;
 };
 
 /* Client methods */
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_obd.c b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
index ca78aff..2338556 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_obd.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
@@ -387,27 +387,23 @@ static int lmv_add_target(struct obd_device *obd, struct obd_uuid *uuidp,
 			  __u32 index, int gen)
 {
 	struct lmv_obd      *lmv = &obd->u.lmv;
+	struct obd_device *mdc_obd;
 	struct lmv_tgt_desc *tgt;
 	int orig_tgt_count = 0;
 	int		  rc = 0;
 
 	CDEBUG(D_CONFIG, "Target uuid: %s. index %d\n", uuidp->uuid, index);
 
-	mutex_lock(&lmv->lmv_init_mutex);
-
-	if (lmv->desc.ld_tgt_count == 0) {
-		struct obd_device *mdc_obd;
-
-		mdc_obd = class_find_client_obd(uuidp, LUSTRE_MDC_NAME,
-						&obd->obd_uuid);
-		if (!mdc_obd) {
-			mutex_unlock(&lmv->lmv_init_mutex);
-			CERROR("%s: Target %s not attached: rc = %d\n",
-			       obd->obd_name, uuidp->uuid, -EINVAL);
-			return -EINVAL;
-		}
+	mdc_obd = class_find_client_obd(uuidp, LUSTRE_MDC_NAME,
+					&obd->obd_uuid);
+	if (!mdc_obd) {
+		CERROR("%s: Target %s not attached: rc = %d\n",
+		       obd->obd_name, uuidp->uuid, -EINVAL);
+		return -EINVAL;
 	}
 
+	mutex_lock(&lmv->lmv_init_mutex);
+
 	if ((index < lmv->tgts_size) && lmv->tgts[index]) {
 		tgt = lmv->tgts[index];
 		CERROR("%s: UUID %s already assigned at LOV target index %d: rc = %d\n",
@@ -463,22 +459,27 @@ static int lmv_add_target(struct obd_device *obd, struct obd_uuid *uuidp,
 		lmv->desc.ld_tgt_count = index + 1;
 	}
 
-	if (lmv->connected) {
-		rc = lmv_connect_mdc(obd, tgt);
-		if (rc) {
-			spin_lock(&lmv->lmv_lock);
-			if (lmv->desc.ld_tgt_count == index + 1)
-				lmv->desc.ld_tgt_count = orig_tgt_count;
-			memset(tgt, 0, sizeof(*tgt));
-			spin_unlock(&lmv->lmv_lock);
-		} else {
-			int easize = sizeof(struct lmv_stripe_md) +
-				lmv->desc.ld_tgt_count * sizeof(struct lu_fid);
-			lmv_init_ea_size(obd->obd_self_export, easize, 0);
-		}
+	if (!lmv->connected) {
+		/* lmv_check_connect() will connect this target. */
+		mutex_unlock(&lmv->lmv_init_mutex);
+		return rc;
 	}
 
+	/* Otherwise let's connect it ourselves */
 	mutex_unlock(&lmv->lmv_init_mutex);
+	rc = lmv_connect_mdc(obd, tgt);
+	if (rc) {
+		spin_lock(&lmv->lmv_lock);
+		if (lmv->desc.ld_tgt_count == index + 1)
+			lmv->desc.ld_tgt_count = orig_tgt_count;
+		memset(tgt, 0, sizeof(*tgt));
+		spin_unlock(&lmv->lmv_lock);
+	} else {
+		int easize = sizeof(struct lmv_stripe_md) +
+			     lmv->desc.ld_tgt_count * sizeof(struct lu_fid);
+		lmv_init_ea_size(obd->obd_self_export, easize, 0);
+	}
+
 	return rc;
 }
 
-- 
1.7.1
