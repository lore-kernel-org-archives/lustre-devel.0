From: James Simmons <jsimmons@infradead.org>
Date: Tue, 16 Aug 2016 16:19:04 -0400
Subject: [lustre-devel] [PATCH 51/80] staging: lustre: lmv: Match MDT where
	the FID locates first
In-Reply-To: <1471378773-24590-1-git-send-email-jsimmons@infradead.org>
References: <1471378773-24590-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1471378773-24590-52-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, wang di <di.wang@intel.com>, James Simmons <jsimmons@infradead.org>

From: wang di <di.wang@intel.com>

With DNE every object can have two locks in different namespaces:
lookup lock in space of MDT storing direntry and update/open lock
in space of MDT storing inode. In lmv_find_cbdata/lmv_lock_lock,
it should try the MDT that the FID maps to first, since this can
be easily found, and only try others if that fails.

In the error handler of lmv_add_targets, it should check whether
ld_tgt_count is being increased before ld_tgt_count is being -1.

Signed-off-by: wang di <di.wang@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-4098
Reviewed-on: http://review.whamcloud.com/8019
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Fan Yong <fan.yong@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/lmv/lmv_internal.h |   45 +++++++++++++-----
 drivers/staging/lustre/lustre/lmv/lmv_obd.c      |   57 +++++++++++++++-------
 2 files changed, 73 insertions(+), 29 deletions(-)

diff --git a/drivers/staging/lustre/lustre/lmv/lmv_internal.h b/drivers/staging/lustre/lustre/lmv/lmv_internal.h
index dbd1da6..faf6a7b 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_internal.h
+++ b/drivers/staging/lustre/lustre/lmv/lmv_internal.h
@@ -64,35 +64,56 @@ int lmv_revalidate_slaves(struct obd_export *exp, struct mdt_body *mbody,
 			  int extra_lock_flags);
 
 static inline struct lmv_tgt_desc *
-lmv_get_target(struct lmv_obd *lmv, u32 mds)
+lmv_get_target(struct lmv_obd *lmv, u32 mdt_idx, int *index)
 {
-	int count = lmv->desc.ld_tgt_count;
 	int i;
 
-	for (i = 0; i < count; i++) {
+	for (i = 0; i < lmv->desc.ld_tgt_count; i++) {
 		if (!lmv->tgts[i])
 			continue;
 
-		if (lmv->tgts[i]->ltd_idx == mds)
+		if (lmv->tgts[i]->ltd_idx == mdt_idx) {
+			if (index)
+				*index = i;
 			return lmv->tgts[i];
+		}
 	}
 
 	return ERR_PTR(-ENODEV);
 }
 
-static inline struct lmv_tgt_desc *
-lmv_find_target(struct lmv_obd *lmv, const struct lu_fid *fid)
+static inline int
+lmv_find_target_index(struct lmv_obd *lmv, const struct lu_fid *fid)
 {
-	u32 mds = 0;
-	int rc;
+	struct lmv_tgt_desc *ltd;
+	u32 mdt_idx = 0;
+	int index = 0;
 
 	if (lmv->desc.ld_tgt_count > 1) {
-		rc = lmv_fld_lookup(lmv, fid, &mds);
-		if (rc)
-			return ERR_PTR(rc);
+		int rc;
+
+		rc = lmv_fld_lookup(lmv, fid, &mdt_idx);
+		if (rc < 0)
+			return rc;
 	}
 
-	return lmv_get_target(lmv, mds);
+	ltd = lmv_get_target(lmv, mdt_idx, &index);
+	if (IS_ERR(ltd))
+		return PTR_ERR(ltd);
+
+	return index;
+}
+
+static inline struct lmv_tgt_desc *
+lmv_find_target(struct lmv_obd *lmv, const struct lu_fid *fid)
+{
+	int index;
+
+	index = lmv_find_target_index(lmv, fid);
+	if (index < 0)
+		return ERR_PTR(index);
+
+	return lmv->tgts[index];
 }
 
 static inline int lmv_stripe_md_size(int stripe_count)
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_obd.c b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
index 9821f69..6917a03 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_obd.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
@@ -480,6 +480,7 @@ static int lmv_add_target(struct obd_device *obd, struct obd_uuid *uuidp,
 {
 	struct lmv_obd      *lmv = &obd->u.lmv;
 	struct lmv_tgt_desc *tgt;
+	int orig_tgt_count = 0;
 	int		  rc = 0;
 
 	CDEBUG(D_CONFIG, "Target uuid: %s. index %d\n", uuidp->uuid, index);
@@ -549,14 +550,17 @@ static int lmv_add_target(struct obd_device *obd, struct obd_uuid *uuidp,
 	tgt->ltd_uuid = *uuidp;
 	tgt->ltd_active = 0;
 	lmv->tgts[index] = tgt;
-	if (index >= lmv->desc.ld_tgt_count)
+	if (index >= lmv->desc.ld_tgt_count) {
+		orig_tgt_count = lmv->desc.ld_tgt_count;
 		lmv->desc.ld_tgt_count = index + 1;
+	}
 
 	if (lmv->connected) {
 		rc = lmv_connect_mdc(obd, tgt);
 		if (rc) {
 			spin_lock(&lmv->lmv_lock);
-			lmv->desc.ld_tgt_count--;
+			if (lmv->desc.ld_tgt_count == index + 1)
+				lmv->desc.ld_tgt_count = orig_tgt_count;
 			memset(tgt, 0, sizeof(*tgt));
 			spin_unlock(&lmv->lmv_lock);
 		} else {
@@ -1263,7 +1267,7 @@ int __lmv_fid_alloc(struct lmv_obd *lmv, struct lu_fid *fid, u32 mds)
 	struct lmv_tgt_desc	*tgt;
 	int			 rc;
 
-	tgt = lmv_get_target(lmv, mds);
+	tgt = lmv_get_target(lmv, mds, NULL);
 	if (IS_ERR(tgt))
 		return PTR_ERR(tgt);
 
@@ -1610,6 +1614,7 @@ static int lmv_find_cbdata(struct obd_export *exp, const struct lu_fid *fid,
 {
 	struct obd_device   *obd = exp->exp_obd;
 	struct lmv_obd      *lmv = &obd->u.lmv;
+	int tgt;
 	int		  i;
 	int		  rc;
 
@@ -1622,12 +1627,22 @@ static int lmv_find_cbdata(struct obd_export *exp, const struct lu_fid *fid,
 	/*
 	 * With DNE every object can have two locks in different namespaces:
 	 * lookup lock in space of MDT storing direntry and update/open lock in
-	 * space of MDT storing inode.
+	 * space of MDT storing inode. Try the MDT that the FID maps to first,
+	 * since this can be easily found, and only try others if that fails.
 	 */
-	for (i = 0; i < lmv->desc.ld_tgt_count; i++) {
-		if (!lmv->tgts[i] || !lmv->tgts[i]->ltd_exp)
+	for (i = 0, tgt = lmv_find_target_index(lmv, fid);
+	     i < lmv->desc.ld_tgt_count;
+	     i++, tgt = (tgt + 1) % lmv->desc.ld_tgt_count) {
+		if (tgt < 0) {
+			CDEBUG(D_HA, "%s: "DFID" is inaccessible: rc = %d\n",
+			       obd->obd_name, PFID(fid), tgt);
+			tgt = 0;
+		}
+
+		if (!lmv->tgts[tgt] || !lmv->tgts[tgt]->ltd_exp)
 			continue;
-		rc = md_find_cbdata(lmv->tgts[i]->ltd_exp, fid, it, data);
+
+		rc = md_find_cbdata(lmv->tgts[tgt]->ltd_exp, fid, it, data);
 		if (rc)
 			return rc;
 	}
@@ -1676,7 +1691,7 @@ lmv_locate_target_for_name(struct lmv_obd *lmv, struct lmv_stripe_md *lsm,
 
 	*fid = oinfo->lmo_fid;
 	*mds = oinfo->lmo_mds;
-	tgt = lmv_get_target(lmv, *mds);
+	tgt = lmv_get_target(lmv, *mds, NULL);
 
 	CDEBUG(D_INFO, "locate on mds %u "DFID"\n", *mds, PFID(fid));
 	return tgt;
@@ -2866,24 +2881,32 @@ static enum ldlm_mode lmv_lock_match(struct obd_export *exp, __u64 flags,
 	struct obd_device       *obd = exp->exp_obd;
 	struct lmv_obd	  *lmv = &obd->u.lmv;
 	enum ldlm_mode	      rc;
+	int tgt;
 	int		      i;
 
 	CDEBUG(D_INODE, "Lock match for "DFID"\n", PFID(fid));
 
 	/*
-	 * With CMD every object can have two locks in different namespaces:
-	 * lookup lock in space of mds storing direntry and update/open lock in
-	 * space of mds storing inode. Thus we check all targets, not only that
-	 * one fid was created in.
+	 * With DNE every object can have two locks in different namespaces:
+	 * lookup lock in space of MDT storing direntry and update/open lock in
+	 * space of MDT storing inode.  Try the MDT that the FID maps to first,
+	 * since this can be easily found, and only try others if that fails.
 	 */
-	for (i = 0; i < lmv->desc.ld_tgt_count; i++) {
-		struct lmv_tgt_desc *tgt = lmv->tgts[i];
+	for (i = 0, tgt = lmv_find_target_index(lmv, fid);
+	     i < lmv->desc.ld_tgt_count;
+	     i++, tgt = (tgt + 1) % lmv->desc.ld_tgt_count) {
+		if (tgt < 0) {
+			CDEBUG(D_HA, "%s: "DFID" is inaccessible: rc = %d\n",
+			       obd->obd_name, PFID(fid), tgt);
+			tgt = 0;
+		}
 
-		if (!tgt || !tgt->ltd_exp || !tgt->ltd_active)
+		if (!lmv->tgts[tgt] || !lmv->tgts[tgt]->ltd_exp ||
+		    !lmv->tgts[tgt]->ltd_active)
 			continue;
 
-		rc = md_lock_match(tgt->ltd_exp, flags, fid, type, policy, mode,
-				   lockh);
+		rc = md_lock_match(lmv->tgts[tgt]->ltd_exp, flags, fid,
+				   type, policy, mode, lockh);
 		if (rc)
 			return rc;
 	}
-- 
1.7.1
