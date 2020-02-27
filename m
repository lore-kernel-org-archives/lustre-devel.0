From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:15:54 -0500
Subject: [lustre-devel] [PATCH 486/622] lustre: lmv: share object alloc QoS
 code with LMV
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-487-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Lai Siyao <lai.siyao@whamcloud.com>

Move object alloc QoS code to obdclass, so that LMV and LOD
can share the same code.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11213
Lustre-commit: d3090bb2b486 ("LU-11213 lod: share object alloc QoS code with LMV")
Signed-off-by: Lai Siyao <lai.siyao@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/35219
Reviewed-by: Hongchao Zhang <hongchao@whamcloud.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lu_object.h |   7 +
 fs/lustre/lmv/Makefile        |   2 +-
 fs/lustre/lmv/lmv_internal.h  |   4 -
 fs/lustre/lmv/lmv_obd.c       |  87 +++++++++
 fs/lustre/lmv/lmv_qos.c       | 411 ------------------------------------------
 fs/lustre/obdclass/lu_qos.c   | 303 +++++++++++++++++++++++++++++++
 6 files changed, 398 insertions(+), 416 deletions(-)
 delete mode 100644 fs/lustre/lmv/lmv_qos.c

diff --git a/fs/lustre/include/lu_object.h b/fs/lustre/include/lu_object.h
index c30c06d..eaf20ea 100644
--- a/fs/lustre/include/lu_object.h
+++ b/fs/lustre/include/lu_object.h
@@ -1442,6 +1442,13 @@ struct lu_qos {
 void lu_qos_rr_init(struct lu_qos_rr *lqr);
 int lqos_add_tgt(struct lu_qos *qos, struct lu_tgt_desc *ltd);
 int lqos_del_tgt(struct lu_qos *qos, struct lu_tgt_desc *ltd);
+bool lqos_is_usable(struct lu_qos *qos, u32 active_tgt_nr);
+int lqos_calc_penalties(struct lu_qos *qos, struct lu_tgt_descs *ltd,
+			u32 active_tgt_nr, u32 maxage, bool is_mdt);
+void lqos_calc_weight(struct lu_tgt_desc *tgt);
+int lqos_recalc_weight(struct lu_qos *qos, struct lu_tgt_descs *ltd,
+		       struct lu_tgt_desc *tgt, u32 active_tgt_nr,
+		       u64 *total_wt);
 u64 lu_prandom_u64_max(u64 ep_ro);
 
 int lu_tgt_descs_init(struct lu_tgt_descs *ltd);
diff --git a/fs/lustre/lmv/Makefile b/fs/lustre/lmv/Makefile
index 6f9a19c..ad470bf 100644
--- a/fs/lustre/lmv/Makefile
+++ b/fs/lustre/lmv/Makefile
@@ -1,4 +1,4 @@
 ccflags-y += -I$(srctree)/$(src)/../include
 
 obj-$(CONFIG_LUSTRE_FS) += lmv.o
-lmv-y := lmv_obd.o lmv_intent.o lmv_fld.o lproc_lmv.o lmv_qos.o
+lmv-y := lmv_obd.o lmv_intent.o lmv_fld.o lproc_lmv.o
diff --git a/fs/lustre/lmv/lmv_internal.h b/fs/lustre/lmv/lmv_internal.h
index e0c3ba0..d95fa3f 100644
--- a/fs/lustre/lmv/lmv_internal.h
+++ b/fs/lustre/lmv/lmv_internal.h
@@ -218,10 +218,6 @@ static inline bool lmv_dir_retry_check_update(struct md_op_data *op_data)
 struct lmv_tgt_desc *lmv_locate_tgt(struct lmv_obd *lmv,
 				    struct md_op_data *op_data);
 
-/* lmv_qos.c */
-struct lu_tgt_desc *lmv_locate_tgt_qos(struct lmv_obd *lmv, u32 *mdt);
-struct lu_tgt_desc *lmv_locate_tgt_rr(struct lmv_obd *lmv, u32 *mdt);
-
 /* lproc_lmv.c */
 int lmv_tunables_init(struct obd_device *obd);
 
diff --git a/fs/lustre/lmv/lmv_obd.c b/fs/lustre/lmv/lmv_obd.c
index 8d682b4..2959b18 100644
--- a/fs/lustre/lmv/lmv_obd.c
+++ b/fs/lustre/lmv/lmv_obd.c
@@ -1518,6 +1518,93 @@ static int lmv_close(struct obd_export *exp, struct md_op_data *op_data,
 	return md_close(tgt->ltd_exp, op_data, mod, request);
 }
 
+static struct lu_tgt_desc *lmv_locate_tgt_qos(struct lmv_obd *lmv, u32 *mdt)
+{
+	struct lu_tgt_desc *tgt;
+	u64 total_weight = 0;
+	u64 cur_weight = 0;
+	u64 rand;
+	int rc;
+
+	if (!lqos_is_usable(&lmv->lmv_qos, lmv->desc.ld_active_tgt_count))
+		return ERR_PTR(-EAGAIN);
+
+	down_write(&lmv->lmv_qos.lq_rw_sem);
+
+	if (!lqos_is_usable(&lmv->lmv_qos, lmv->desc.ld_active_tgt_count)) {
+		tgt = ERR_PTR(-EAGAIN);
+		goto unlock;
+	}
+
+	rc = lqos_calc_penalties(&lmv->lmv_qos, &lmv->lmv_mdt_descs,
+				 lmv->desc.ld_active_tgt_count,
+				 lmv->desc.ld_qos_maxage, true);
+	if (rc) {
+		tgt = ERR_PTR(rc);
+		goto unlock;
+	}
+
+	lmv_foreach_tgt(lmv, tgt) {
+		tgt->ltd_qos.ltq_usable = 0;
+		if (!tgt->ltd_exp || !tgt->ltd_active)
+			continue;
+
+		tgt->ltd_qos.ltq_usable = 1;
+		lqos_calc_weight(tgt);
+		total_weight += tgt->ltd_qos.ltq_weight;
+	}
+
+	rand = lu_prandom_u64_max(total_weight);
+
+	lmv_foreach_connected_tgt(lmv, tgt) {
+		if (!tgt->ltd_qos.ltq_usable)
+			continue;
+
+		cur_weight += tgt->ltd_qos.ltq_weight;
+		if (cur_weight < rand)
+			continue;
+
+		*mdt = tgt->ltd_index;
+		lqos_recalc_weight(&lmv->lmv_qos, &lmv->lmv_mdt_descs, tgt,
+				   lmv->desc.ld_active_tgt_count,
+				   &total_weight);
+		rc = 0;
+		goto unlock;
+	}
+
+	/* no proper target found */
+	tgt = ERR_PTR(-EAGAIN);
+	goto unlock;
+unlock:
+	up_write(&lmv->lmv_qos.lq_rw_sem);
+
+	return tgt;
+}
+
+static struct lu_tgt_desc *lmv_locate_tgt_rr(struct lmv_obd *lmv, u32 *mdt)
+{
+	struct lu_tgt_desc *tgt;
+	int i;
+	int index;
+
+	spin_lock(&lmv->lmv_qos.lq_rr.lqr_alloc);
+	for (i = 0; i < lmv->desc.ld_tgt_count; i++) {
+		index = (i + lmv->lmv_qos_rr_index) % lmv->desc.ld_tgt_count;
+		tgt = lmv_tgt(lmv, index);
+		if (!tgt || !tgt->ltd_exp || !tgt->ltd_active)
+			continue;
+
+		*mdt = tgt->ltd_index;
+		lmv->lmv_qos_rr_index = (*mdt + 1) % lmv->desc.ld_tgt_count;
+		spin_unlock(&lmv->lmv_qos.lq_rr.lqr_alloc);
+
+		return tgt;
+	}
+	spin_unlock(&lmv->lmv_qos.lq_rr.lqr_alloc);
+
+	return ERR_PTR(-ENODEV);
+}
+
 static struct lmv_tgt_desc *
 lmv_locate_tgt_by_name(struct lmv_obd *lmv, struct lmv_stripe_md *lsm,
 		       const char *name, int namelen, struct lu_fid *fid,
diff --git a/fs/lustre/lmv/lmv_qos.c b/fs/lustre/lmv/lmv_qos.c
deleted file mode 100644
index 0bee7c0..0000000
--- a/fs/lustre/lmv/lmv_qos.c
+++ /dev/null
@@ -1,411 +0,0 @@
-// SPDX-License-Identifier: GPL-2.0
-/*
- * GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; If not, see
- * http://www.gnu.org/licenses/gpl-2.0.html
- *
- * GPL HEADER END
- */
-/*
- * This file is part of Lustre, http://www.lustre.org/
- *
- * lustre/lmv/lmv_qos.c
- *
- * LMV QoS.
- * These are the only exported functions, they provide some generic
- * infrastructure for object allocation QoS
- *
- */
-
-#define DEBUG_SUBSYSTEM S_LMV
-
-#include <asm/div64.h>
-#include <uapi/linux/lustre/lustre_idl.h>
-#include <lustre_swab.h>
-#include <obd_class.h>
-
-#include "lmv_internal.h"
-
-static inline u64 tgt_statfs_bavail(struct lu_tgt_desc *tgt)
-{
-	struct obd_statfs *statfs = &tgt->ltd_statfs;
-
-	return statfs->os_bavail * statfs->os_bsize;
-}
-
-static inline u64 tgt_statfs_iavail(struct lu_tgt_desc *tgt)
-{
-	return tgt->ltd_statfs.os_ffree;
-}
-
-/**
- * Calculate penalties per-tgt and per-server
- *
- * Re-calculate penalties when the configuration changes, active targets
- * change and after statfs refresh (all these are reflected by lq_dirty flag).
- * On every MDT and MDS: decay the penalty by half for every 8x the update
- * interval that the device has been idle. That gives lots of time for the
- * statfs information to be updated (which the penalty is only a proxy for),
- * and avoids penalizing MDS/MDTs under light load.
- * See lmv_qos_calc_weight() for how penalties are factored into the weight.
- *
- * @lmv			LMV device
- *
- * Return:		0 on success
- *			-EAGAIN	if the number of MDTs isn't enough or all
- *			MDT spaces are almost the same
- */
-static int lmv_qos_calc_ppts(struct lmv_obd *lmv)
-{
-	struct lu_qos *qos = &lmv->lmv_qos;
-	struct lu_tgt_desc *tgt;
-	struct lu_svr_qos *svr;
-	u64 ba_max, ba_min, ba;
-	u64 ia_max, ia_min, ia;
-	u32 num_active;
-	int prio_wide;
-	time64_t now, age;
-	u32 maxage = lmv->desc.ld_qos_maxage;
-	int rc = 0;
-
-
-	if (!qos->lq_dirty)
-		goto out;
-
-	num_active = lmv->desc.ld_active_tgt_count;
-	if (num_active < 2) {
-		rc = -EAGAIN;
-		goto out;
-	}
-
-	/* find bavail on each server */
-	list_for_each_entry(svr, &qos->lq_svr_list, lsq_svr_list) {
-		svr->lsq_bavail = 0;
-		svr->lsq_iavail = 0;
-	}
-	qos->lq_active_svr_count = 0;
-
-	/*
-	 * How badly user wants to select targets "widely" (not recently chosen
-	 * and not on recent MDS's).  As opposed to "freely" (free space avail.)
-	 * 0-256
-	 */
-	prio_wide = 256 - qos->lq_prio_free;
-
-	ba_min = (u64)(-1);
-	ba_max = 0;
-	ia_min = (u64)(-1);
-	ia_max = 0;
-	now = ktime_get_real_seconds();
-
-	/* Calculate server penalty per object */
-	lmv_foreach_tgt(lmv, tgt) {
-		if (!tgt->ltd_exp || !tgt->ltd_active)
-			continue;
-
-		/* bavail >> 16 to avoid overflow */
-		ba = tgt_statfs_bavail(tgt) >> 16;
-		if (!ba)
-			continue;
-
-		ba_min = min(ba, ba_min);
-		ba_max = max(ba, ba_max);
-
-		/* iavail >> 8 to avoid overflow */
-		ia = tgt_statfs_iavail(tgt) >> 8;
-		if (!ia)
-			continue;
-
-		ia_min = min(ia, ia_min);
-		ia_max = max(ia, ia_max);
-
-		/* Count the number of usable MDS's */
-		if (tgt->ltd_qos.ltq_svr->lsq_bavail == 0)
-			qos->lq_active_svr_count++;
-		tgt->ltd_qos.ltq_svr->lsq_bavail += ba;
-		tgt->ltd_qos.ltq_svr->lsq_iavail += ia;
-
-		/*
-		 * per-MDT penalty is
-		 * prio * bavail * iavail / (num_tgt - 1) / 2
-		 */
-		tgt->ltd_qos.ltq_penalty_per_obj = prio_wide * ba * ia;
-		do_div(tgt->ltd_qos.ltq_penalty_per_obj, num_active - 1);
-		tgt->ltd_qos.ltq_penalty_per_obj >>= 1;
-
-		age = (now - tgt->ltd_qos.ltq_used) >> 3;
-		if (qos->lq_reset || age > 32 * maxage)
-			tgt->ltd_qos.ltq_penalty = 0;
-		else if (age > maxage)
-			/* Decay tgt penalty. */
-			tgt->ltd_qos.ltq_penalty >>= (age / maxage);
-	}
-
-	num_active = qos->lq_active_svr_count;
-	if (num_active < 2) {
-		/*
-		 * If there's only 1 MDS, we can't penalize it, so instead
-		 * we have to double the MDT penalty
-		 */
-		num_active = 2;
-		lmv_foreach_tgt(lmv, tgt) {
-			if (!tgt->ltd_exp || !tgt->ltd_active)
-				continue;
-
-			tgt->ltd_qos.ltq_penalty_per_obj <<= 1;
-		}
-	}
-
-	/*
-	 * Per-MDS penalty is
-	 * prio * bavail * iavail / server_tgts / (num_svr - 1) / 2
-	 */
-	list_for_each_entry(svr, &qos->lq_svr_list, lsq_svr_list) {
-		ba = svr->lsq_bavail;
-		ia = svr->lsq_iavail;
-		svr->lsq_penalty_per_obj = prio_wide * ba  * ia;
-		do_div(ba, svr->lsq_tgt_count * (num_active - 1));
-		svr->lsq_penalty_per_obj >>= 1;
-
-		age = (now - svr->lsq_used) >> 3;
-		if (qos->lq_reset || age > 32 * maxage)
-			svr->lsq_penalty = 0;
-		else if (age > maxage)
-			/* Decay server penalty. */
-			svr->lsq_penalty >>= age / maxage;
-	}
-
-	qos->lq_dirty = 0;
-	qos->lq_reset = 0;
-
-	/*
-	 * If each MDT has almost same free space, do rr allocation for better
-	 * creation performance
-	 */
-	qos->lq_same_space = 0;
-	if ((ba_max * (256 - qos->lq_threshold_rr)) >> 8 < ba_min &&
-	    (ia_max * (256 - qos->lq_threshold_rr)) >> 8 < ia_min) {
-		qos->lq_same_space = 1;
-		/* Reset weights for the next time we enter qos mode */
-		qos->lq_reset = 1;
-	}
-	rc = 0;
-
-out:
-	if (!rc && qos->lq_same_space)
-		return -EAGAIN;
-
-	return rc;
-}
-
-static inline bool lmv_qos_is_usable(struct lmv_obd *lmv)
-{
-	if (!lmv->lmv_qos.lq_dirty && lmv->lmv_qos.lq_same_space)
-		return false;
-
-	if (lmv->desc.ld_active_tgt_count < 2)
-		return false;
-
-	return true;
-}
-
-/**
- * Calculate weight for a given MDT.
- *
- * The final MDT weight is bavail >> 16 * iavail >> 8 minus the MDT and MDS
- * penalties.  See lmv_qos_calc_ppts() for how penalties are calculated.
- *
- * \param[in] tgt	MDT target descriptor
- */
-static void lmv_qos_calc_weight(struct lu_tgt_desc *tgt)
-{
-	struct lu_tgt_qos *ltq = &tgt->ltd_qos;
-	u64 temp, temp2;
-
-	temp = (tgt_statfs_bavail(tgt) >> 16) * (tgt_statfs_iavail(tgt) >> 8);
-	temp2 = ltq->ltq_penalty + ltq->ltq_svr->lsq_penalty;
-	if (temp < temp2)
-		ltq->ltq_weight = 0;
-	else
-		ltq->ltq_weight = temp - temp2;
-}
-
-/**
- * Re-calculate weights.
- *
- * The function is called when some target was used for a new object. In
- * this case we should re-calculate all the weights to keep new allocations
- * balanced well.
- *
- * \param[in] lmv	LMV device
- * \param[in] tgt	target where a new object was placed
- * \param[out] total_wt	new total weight for the pool
- *
- * \retval		0
- */
-static int lmv_qos_used(struct lmv_obd *lmv, struct lu_tgt_desc *tgt,
-			u64 *total_wt)
-{
-	struct lu_tgt_qos *ltq;
-	struct lu_svr_qos *svr;
-
-	ltq = &tgt->ltd_qos;
-	LASSERT(ltq);
-
-	/* Don't allocate on this device anymore, until the next alloc_qos */
-	ltq->ltq_usable = 0;
-
-	svr = ltq->ltq_svr;
-
-	/*
-	 * Decay old penalty by half (we're adding max penalty, and don't
-	 * want it to run away.)
-	 */
-	ltq->ltq_penalty >>= 1;
-	svr->lsq_penalty >>= 1;
-
-	/* mark the MDS and MDT as recently used */
-	ltq->ltq_used = svr->lsq_used = ktime_get_real_seconds();
-
-	/* Set max penalties for this MDT and MDS */
-	ltq->ltq_penalty += ltq->ltq_penalty_per_obj *
-			    lmv->desc.ld_active_tgt_count;
-	svr->lsq_penalty += svr->lsq_penalty_per_obj *
-		lmv->lmv_qos.lq_active_svr_count;
-
-	/* Decrease all MDS penalties */
-	list_for_each_entry(svr, &lmv->lmv_qos.lq_svr_list, lsq_svr_list) {
-		if (svr->lsq_penalty < svr->lsq_penalty_per_obj)
-			svr->lsq_penalty = 0;
-		else
-			svr->lsq_penalty -= svr->lsq_penalty_per_obj;
-	}
-
-	*total_wt = 0;
-	/* Decrease all MDT penalties */
-	lmv_foreach_tgt(lmv, tgt) {
-		if (!tgt->ltd_exp || !tgt->ltd_active)
-			continue;
-
-		if (ltq->ltq_penalty < ltq->ltq_penalty_per_obj)
-			ltq->ltq_penalty = 0;
-		else
-			ltq->ltq_penalty -= ltq->ltq_penalty_per_obj;
-
-		lmv_qos_calc_weight(tgt);
-
-		/* Recalc the total weight of usable osts */
-		if (ltq->ltq_usable)
-			*total_wt += ltq->ltq_weight;
-
-		CDEBUG(D_OTHER,
-		       "recalc tgt %d usable=%d avail=%llu tgtppo=%llu tgtp=%llu svrppo=%llu svrp=%llu wt=%llu\n",
-		       tgt->ltd_index, ltq->ltq_usable,
-		       tgt_statfs_bavail(tgt) >> 10,
-		       ltq->ltq_penalty_per_obj >> 10,
-		       ltq->ltq_penalty >> 10,
-		       ltq->ltq_svr->lsq_penalty_per_obj >> 10,
-		       ltq->ltq_svr->lsq_penalty >> 10,
-		       ltq->ltq_weight >> 10);
-	}
-
-	return 0;
-}
-
-struct lu_tgt_desc *lmv_locate_tgt_qos(struct lmv_obd *lmv, u32 *mdt)
-{
-	struct lu_tgt_desc *tgt;
-	u64 total_weight = 0;
-	u64 cur_weight = 0;
-	u64 rand;
-	int rc;
-
-	if (!lmv_qos_is_usable(lmv))
-		return ERR_PTR(-EAGAIN);
-
-	down_write(&lmv->lmv_qos.lq_rw_sem);
-
-	if (!lmv_qos_is_usable(lmv)) {
-		tgt = ERR_PTR(-EAGAIN);
-		goto unlock;
-	}
-
-	rc = lmv_qos_calc_ppts(lmv);
-	if (rc) {
-		tgt = ERR_PTR(rc);
-		goto unlock;
-	}
-
-	lmv_foreach_tgt(lmv, tgt) {
-		tgt->ltd_qos.ltq_usable = 0;
-		if (!tgt->ltd_exp || !tgt->ltd_active)
-			continue;
-
-		tgt->ltd_qos.ltq_usable = 1;
-		lmv_qos_calc_weight(tgt);
-		total_weight += tgt->ltd_qos.ltq_weight;
-	}
-
-	rand = lu_prandom_u64_max(total_weight);
-
-	lmv_foreach_tgt(lmv, tgt) {
-		if (!tgt->ltd_qos.ltq_usable)
-			continue;
-
-		cur_weight += tgt->ltd_qos.ltq_weight;
-		if (cur_weight < rand)
-			continue;
-
-		*mdt = tgt->ltd_index;
-		lmv_qos_used(lmv, tgt, &total_weight);
-		rc = 0;
-		goto unlock;
-	}
-
-	/* no proper target found */
-	tgt = ERR_PTR(-EAGAIN);
-	goto unlock;
-unlock:
-	up_write(&lmv->lmv_qos.lq_rw_sem);
-
-	return tgt;
-}
-
-struct lu_tgt_desc *lmv_locate_tgt_rr(struct lmv_obd *lmv, u32 *mdt)
-{
-	struct lu_tgt_desc *tgt;
-	int i;
-
-	spin_lock(&lmv->lmv_qos.lq_rr.lqr_alloc);
-	for (i = 0; i < lmv->desc.ld_tgt_count; i++) {
-		tgt = lmv_tgt(lmv,
-			(i + lmv->lmv_qos_rr_index) % lmv->desc.ld_tgt_count);
-		if (!tgt || !tgt->ltd_exp || !tgt->ltd_active)
-			continue;
-
-		*mdt = tgt->ltd_index;
-		lmv->lmv_qos_rr_index =
-			(i + lmv->lmv_qos_rr_index + 1) %
-			lmv->desc.ld_tgt_count;
-		spin_unlock(&lmv->lmv_qos.lq_rr.lqr_alloc);
-
-		return tgt;
-	}
-	spin_unlock(&lmv->lmv_qos.lq_rr.lqr_alloc);
-
-	return ERR_PTR(-ENODEV);
-}
diff --git a/fs/lustre/obdclass/lu_qos.c b/fs/lustre/obdclass/lu_qos.c
index d4803e8..e77e81d 100644
--- a/fs/lustre/obdclass/lu_qos.c
+++ b/fs/lustre/obdclass/lu_qos.c
@@ -207,3 +207,306 @@ u64 lu_prandom_u64_max(u64 ep_ro)
 	return rand;
 }
 EXPORT_SYMBOL(lu_prandom_u64_max);
+
+static inline u64 tgt_statfs_bavail(struct lu_tgt_desc *tgt)
+{
+	struct obd_statfs *statfs = &tgt->ltd_statfs;
+
+	return statfs->os_bavail * statfs->os_bsize;
+}
+
+static inline u64 tgt_statfs_iavail(struct lu_tgt_desc *tgt)
+{
+	return tgt->ltd_statfs.os_ffree;
+}
+
+/**
+ * Calculate penalties per-tgt and per-server
+ *
+ * Re-calculate penalties when the configuration changes, active targets
+ * change and after statfs refresh (all these are reflected by lq_dirty flag).
+ * On every tgt and server: decay the penalty by half for every 8x the update
+ * interval that the device has been idle. That gives lots of time for the
+ * statfs information to be updated (which the penalty is only a proxy for),
+ * and avoids penalizing server/tgt under light load.
+ * See lqos_calc_weight() for how penalties are factored into the weight.
+ *
+ * @qos			lu_qos
+ * @ltd			lu_tgt_descs
+ * @active_tgt_nr	active tgt number
+ * @ maxage		qos max age
+ * @is_mdt		MDT will count inode usage
+ *
+ * Return:		0 on success
+ *			-EAGAIN the number of tgt isn't enough or all
+ *			tgt spaces are almost the same
+ */
+int lqos_calc_penalties(struct lu_qos *qos, struct lu_tgt_descs *ltd,
+			u32 active_tgt_nr, u32 maxage, bool is_mdt)
+{
+	struct lu_tgt_desc *tgt;
+	struct lu_svr_qos *svr;
+	u64 ba_max, ba_min, ba;
+	u64 ia_max, ia_min, ia = 1;
+	u32 num_active;
+	int prio_wide;
+	time64_t now, age;
+	int rc;
+
+	if (!qos->lq_dirty) {
+		rc = 0;
+		goto out;
+	}
+
+	num_active = active_tgt_nr - 1;
+	if (num_active < 1) {
+		rc = -EAGAIN;
+		goto out;
+	}
+
+	/* find bavail on each server */
+	list_for_each_entry(svr, &qos->lq_svr_list, lsq_svr_list) {
+		svr->lsq_bavail = 0;
+		/* if inode is not counted, set to 1 to ignore */
+		svr->lsq_iavail = is_mdt ? 0 : 1;
+	}
+	qos->lq_active_svr_count = 0;
+
+	/*
+	 * How badly user wants to select targets "widely" (not recently chosen
+	 * and not on recent MDS's).  As opposed to "freely" (free space avail.)
+	 * 0-256
+	 */
+	prio_wide = 256 - qos->lq_prio_free;
+
+	ba_min = (u64)(-1);
+	ba_max = 0;
+	ia_min = (u64)(-1);
+	ia_max = 0;
+	now = ktime_get_real_seconds();
+
+	/* Calculate server penalty per object */
+	ltd_foreach_tgt(ltd, tgt) {
+		if (!tgt->ltd_active)
+			continue;
+
+		/* when inode is counted, bavail >> 16 to avoid overflow */
+		ba = tgt_statfs_bavail(tgt);
+		if (is_mdt)
+			ba >>= 16;
+		else
+			ba >>= 8;
+		if (!ba)
+			continue;
+
+		ba_min = min(ba, ba_min);
+		ba_max = max(ba, ba_max);
+
+		/* Count the number of usable servers */
+		if (tgt->ltd_qos.ltq_svr->lsq_bavail == 0)
+			qos->lq_active_svr_count++;
+		tgt->ltd_qos.ltq_svr->lsq_bavail += ba;
+
+		if (is_mdt) {
+			/* iavail >> 8 to avoid overflow */
+			ia = tgt_statfs_iavail(tgt) >> 8;
+			if (!ia)
+				continue;
+
+			ia_min = min(ia, ia_min);
+			ia_max = max(ia, ia_max);
+
+			tgt->ltd_qos.ltq_svr->lsq_iavail += ia;
+		}
+
+		/*
+		 * per-tgt penalty is
+		 * prio * bavail * iavail / (num_tgt - 1) / 2
+		 */
+		tgt->ltd_qos.ltq_penalty_per_obj = prio_wide * ba * ia;
+		do_div(tgt->ltd_qos.ltq_penalty_per_obj, num_active);
+		tgt->ltd_qos.ltq_penalty_per_obj >>= 1;
+
+		age = (now - tgt->ltd_qos.ltq_used) >> 3;
+		if (qos->lq_reset || age > 32 * maxage)
+			tgt->ltd_qos.ltq_penalty = 0;
+		else if (age > maxage)
+			/* Decay tgt penalty. */
+			tgt->ltd_qos.ltq_penalty >>= (age / maxage);
+	}
+
+	num_active = qos->lq_active_svr_count - 1;
+	if (num_active < 1) {
+		/*
+		 * If there's only 1 server, we can't penalize it, so instead
+		 * we have to double the tgt penalty
+		 */
+		num_active = 1;
+		ltd_foreach_tgt(ltd, tgt) {
+			if (!tgt->ltd_active)
+				continue;
+
+			tgt->ltd_qos.ltq_penalty_per_obj <<= 1;
+		}
+	}
+
+	/*
+	 * Per-server penalty is
+	 * prio * bavail * iavail / server_tgts / (num_svr - 1) / 2
+	 */
+	list_for_each_entry(svr, &qos->lq_svr_list, lsq_svr_list) {
+		ba = svr->lsq_bavail;
+		ia = svr->lsq_iavail;
+		svr->lsq_penalty_per_obj = prio_wide * ba  * ia;
+		do_div(ba, svr->lsq_tgt_count * num_active);
+		svr->lsq_penalty_per_obj >>= 1;
+
+		age = (now - svr->lsq_used) >> 3;
+		if (qos->lq_reset || age > 32 * maxage)
+			svr->lsq_penalty = 0;
+		else if (age > maxage)
+			/* Decay server penalty. */
+			svr->lsq_penalty >>= age / maxage;
+	}
+
+	qos->lq_dirty = 0;
+	qos->lq_reset = 0;
+
+	/*
+	 * If each tgt has almost same free space, do rr allocation for better
+	 * creation performance
+	 */
+	qos->lq_same_space = 0;
+	if ((ba_max * (256 - qos->lq_threshold_rr)) >> 8 < ba_min &&
+	    (ia_max * (256 - qos->lq_threshold_rr)) >> 8 < ia_min) {
+		qos->lq_same_space = 1;
+		/* Reset weights for the next time we enter qos mode */
+		qos->lq_reset = 1;
+	}
+	rc = 0;
+
+out:
+	if (!rc && qos->lq_same_space)
+		return -EAGAIN;
+
+	return rc;
+}
+EXPORT_SYMBOL(lqos_calc_penalties);
+
+bool lqos_is_usable(struct lu_qos *qos, u32 active_tgt_nr)
+{
+	if (!qos->lq_dirty && qos->lq_same_space)
+		return false;
+
+	if (active_tgt_nr < 2)
+		return false;
+
+	return true;
+}
+EXPORT_SYMBOL(lqos_is_usable);
+
+/**
+ * Calculate weight for a given tgt.
+ *
+ * The final tgt weight is bavail >> 16 * iavail >> 8 minus the tgt and server
+ * penalties.  See lqos_calc_ppts() for how penalties are calculated.
+ *
+ * @tgt		target descriptor
+ */
+void lqos_calc_weight(struct lu_tgt_desc *tgt)
+{
+	struct lu_tgt_qos *ltq = &tgt->ltd_qos;
+	u64 temp, temp2;
+
+	temp = (tgt_statfs_bavail(tgt) >> 16) * (tgt_statfs_iavail(tgt) >> 8);
+	temp2 = ltq->ltq_penalty + ltq->ltq_svr->lsq_penalty;
+	if (temp < temp2)
+		ltq->ltq_weight = 0;
+	else
+		ltq->ltq_weight = temp - temp2;
+}
+EXPORT_SYMBOL(lqos_calc_weight);
+
+/**
+ * Re-calculate weights.
+ *
+ * The function is called when some target was used for a new object. In
+ * this case we should re-calculate all the weights to keep new allocations
+ * balanced well.
+ *
+ * @qos			lu_qos
+ * @ltd			lu_tgt_descs
+ * @tgt			target where a new object was placed
+ * @active_tgt_nr	active tgt number
+ * @total_wt		new total weight for the pool
+ *
+ * Return:		0
+ */
+int lqos_recalc_weight(struct lu_qos *qos, struct lu_tgt_descs *ltd,
+		       struct lu_tgt_desc *tgt, u32 active_tgt_nr,
+		       u64 *total_wt)
+{
+	struct lu_tgt_qos *ltq;
+	struct lu_svr_qos *svr;
+
+	ltq = &tgt->ltd_qos;
+	LASSERT(ltq);
+
+	/* Don't allocate on this device anymore, until the next alloc_qos */
+	ltq->ltq_usable = 0;
+
+	svr = ltq->ltq_svr;
+
+	/*
+	 * Decay old penalty by half (we're adding max penalty, and don't
+	 * want it to run away.)
+	 */
+	ltq->ltq_penalty >>= 1;
+	svr->lsq_penalty >>= 1;
+
+	/* mark the server and tgt as recently used */
+	ltq->ltq_used = svr->lsq_used = ktime_get_real_seconds();
+
+	/* Set max penalties for this tgt and server */
+	ltq->ltq_penalty += ltq->ltq_penalty_per_obj * active_tgt_nr;
+	svr->lsq_penalty += svr->lsq_penalty_per_obj * active_tgt_nr;
+
+	/* Decrease all MDS penalties */
+	list_for_each_entry(svr, &qos->lq_svr_list, lsq_svr_list) {
+		if (svr->lsq_penalty < svr->lsq_penalty_per_obj)
+			svr->lsq_penalty = 0;
+		else
+			svr->lsq_penalty -= svr->lsq_penalty_per_obj;
+	}
+
+	*total_wt = 0;
+	/* Decrease all tgt penalties */
+	ltd_foreach_tgt(ltd, tgt) {
+		if (!tgt->ltd_active)
+			continue;
+
+		if (ltq->ltq_penalty < ltq->ltq_penalty_per_obj)
+			ltq->ltq_penalty = 0;
+		else
+			ltq->ltq_penalty -= ltq->ltq_penalty_per_obj;
+
+		lqos_calc_weight(tgt);
+
+		/* Recalc the total weight of usable osts */
+		if (ltq->ltq_usable)
+			*total_wt += ltq->ltq_weight;
+
+		CDEBUG(D_OTHER,
+		       "recalc tgt %d usable=%d avail=%llu tgtppo=%llu tgtp=%llu svrppo=%llu svrp=%llu wt=%llu\n",
+		       tgt->ltd_index, ltq->ltq_usable,
+		       tgt_statfs_bavail(tgt) >> 10,
+		       ltq->ltq_penalty_per_obj >> 10,
+		       ltq->ltq_penalty >> 10,
+		       ltq->ltq_svr->lsq_penalty_per_obj >> 10,
+		       ltq->ltq_svr->lsq_penalty >> 10,
+		       ltq->ltq_weight >> 10);
+	}
+
+	return 0;
+}
+EXPORT_SYMBOL(lqos_recalc_weight);
-- 
1.8.3.1
