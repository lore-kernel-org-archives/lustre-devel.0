Return-Path: <SRS0=Xi2l=P3=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D77A0C433F5
	for <lustre-devel@archiver.kernel.org>; Mon,  8 Nov 2021 15:08:08 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 7F8316115A
	for <lustre-devel@archiver.kernel.org>; Mon,  8 Nov 2021 15:08:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.1 mail.kernel.org 7F8316115A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 0449221F348;
	Mon,  8 Nov 2021 07:08:02 -0800 (PST)
Received: from smtp3.ccs.ornl.gov (SMTP3.CCS.ORNL.GOV [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 77D3221C967
 for <lustre-devel@lists.lustre.org>; Mon,  8 Nov 2021 07:07:50 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 263822228;
 Mon,  8 Nov 2021 10:07:46 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 23217E07E7; Mon,  8 Nov 2021 10:07:46 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon,  8 Nov 2021 10:07:37 -0500
Message-Id: <1636384063-13838-10-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1636384063-13838-1-git-send-email-jsimmons@infradead.org>
References: <1636384063-13838-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 09/15] lustre: dne: dir migrate in QOS mode
X-BeenThere: lustre-devel@lists.lustre.org
X-Mailman-Version: 2.1.23
Precedence: list
List-Id: "For discussing Lustre software development."
 <lustre-devel-lustre.org>
List-Unsubscribe: <http://lists.lustre.org/options.cgi/lustre-devel-lustre.org>, 
 <mailto:lustre-devel-request@lists.lustre.org?subject=unsubscribe>
List-Archive: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/>
List-Post: <mailto:lustre-devel@lists.lustre.org>
List-Help: <mailto:lustre-devel-request@lists.lustre.org?subject=help>
List-Subscribe: <http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org>, 
 <mailto:lustre-devel-request@lists.lustre.org?subject=subscribe>
Cc: Lai Siyao <lai.siyao@whamcloud.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Lai Siyao <lai.siyao@whamcloud.com>

Support "lfs migrate -m -1 ..." to migrate directory to MDTs by
space and inode usage, if system is balanced, the target MDT is
chosen in roundrobin mode, otherwise the less full MDTs will be
chosen, and the most full MDT is avoided.

Another minor change: if directory is migrated to specific MDTs,
and the target stripe count is more than 1, its subdirs may not be
migrated to the specified MDT in the command, but migrated to the
MDT where its parent stripe is located (subdir will be striped too),
as can avoid unnecessary remote directories. NB, for command like
"lfs migrate -m 0,1,2 ...", though the subdir may be located on
either MDT0, MDT1 or MDT2, its stripes will be striped over these
three MDTs, but for command like "lfs migrate -m 0 -c 3...", the
subdir may be striped on other MDTs if the subdir is not located on
MDT0.

WC-bug-id: https://jira.whamcloud.com/browse/LU-13076
Lustre-commit: 378c7567876b430d0 ("LU-13076 dne: dir migrate in QOS mode")
Signed-off-by: Lai Siyao <lai.siyao@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/44886
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Hongchao Zhang <hongchao@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/lmv/lmv_obd.c | 176 +++++++++++++++++++++++++++++++++++++++++++-----
 1 file changed, 158 insertions(+), 18 deletions(-)

diff --git a/fs/lustre/lmv/lmv_obd.c b/fs/lustre/lmv/lmv_obd.c
index fb64b6c..b31f943 100644
--- a/fs/lustre/lmv/lmv_obd.c
+++ b/fs/lustre/lmv/lmv_obd.c
@@ -1427,7 +1427,7 @@ static int lmv_close(struct obd_export *exp, struct md_op_data *op_data,
 	return md_close(tgt->ltd_exp, op_data, mod, request);
 }
 
-static struct lu_tgt_desc *lmv_locate_tgt_qos(struct lmv_obd *lmv, u32 *mdt,
+static struct lu_tgt_desc *lmv_locate_tgt_qos(struct lmv_obd *lmv, u32 mdt,
 					      unsigned short dir_depth)
 {
 	struct lu_tgt_desc *tgt, *cur = NULL;
@@ -1462,7 +1462,7 @@ static struct lu_tgt_desc *lmv_locate_tgt_qos(struct lmv_obd *lmv, u32 *mdt,
 
 		tgt->ltd_qos.ltq_usable = 1;
 		lu_tgt_qos_weight_calc(tgt);
-		if (tgt->ltd_index == *mdt)
+		if (tgt->ltd_index == mdt)
 			cur = tgt;
 		total_avail += tgt->ltd_qos.ltq_avail;
 		total_weight += tgt->ltd_qos.ltq_weight;
@@ -1477,7 +1477,6 @@ static struct lu_tgt_desc *lmv_locate_tgt_qos(struct lmv_obd *lmv, u32 *mdt,
 	       (total_usable * 256 * (1 + dir_depth / 4));
 	if (cur && cur->ltd_qos.ltq_avail >= rand) {
 		tgt = cur;
-		rc = 0;
 		goto unlock;
 	}
 
@@ -1491,9 +1490,7 @@ static struct lu_tgt_desc *lmv_locate_tgt_qos(struct lmv_obd *lmv, u32 *mdt,
 		if (cur_weight < rand)
 			continue;
 
-		*mdt = tgt->ltd_index;
 		ltd_qos_update(&lmv->lmv_mdt_descs, tgt, &total_weight);
-		rc = 0;
 		goto unlock;
 	}
 
@@ -1506,7 +1503,7 @@ static struct lu_tgt_desc *lmv_locate_tgt_qos(struct lmv_obd *lmv, u32 *mdt,
 	return tgt;
 }
 
-static struct lu_tgt_desc *lmv_locate_tgt_rr(struct lmv_obd *lmv, u32 *mdt)
+static struct lu_tgt_desc *lmv_locate_tgt_rr(struct lmv_obd *lmv)
 {
 	struct lu_tgt_desc *tgt;
 	int i;
@@ -1520,8 +1517,7 @@ static struct lu_tgt_desc *lmv_locate_tgt_rr(struct lmv_obd *lmv, u32 *mdt)
 		if (!tgt || !tgt->ltd_exp || !tgt->ltd_active)
 			continue;
 
-		*mdt = tgt->ltd_index;
-		lmv->lmv_qos_rr_index = (*mdt + 1) %
+		lmv->lmv_qos_rr_index = (tgt->ltd_index + 1) %
 					lmv->lmv_mdt_descs.ltd_tgts_size;
 		spin_unlock(&lmv->lmv_lock);
 
@@ -1532,6 +1528,65 @@ static struct lu_tgt_desc *lmv_locate_tgt_rr(struct lmv_obd *lmv, u32 *mdt)
 	return ERR_PTR(-ENODEV);
 }
 
+/* locate MDT which is less full (avoid the most full MDT) */
+static struct lu_tgt_desc *lmv_locate_tgt_lf(struct lmv_obd *lmv)
+{
+	struct lu_tgt_desc *min = NULL;
+	struct lu_tgt_desc *tgt;
+	u64 avail = 0;
+	u64 rand;
+
+	if (!ltd_qos_is_usable(&lmv->lmv_mdt_descs))
+		return ERR_PTR(-EAGAIN);
+
+	down_write(&lmv->lmv_qos.lq_rw_sem);
+
+	if (!ltd_qos_is_usable(&lmv->lmv_mdt_descs)) {
+		tgt = ERR_PTR(-EAGAIN);
+		goto unlock;
+	}
+
+	lmv_foreach_tgt(lmv, tgt) {
+		if (!tgt->ltd_exp || !tgt->ltd_active) {
+			tgt->ltd_qos.ltq_usable = 0;
+			continue;
+		}
+
+		tgt->ltd_qos.ltq_usable = 1;
+		lu_tgt_qos_weight_calc(tgt);
+		avail += tgt->ltd_qos.ltq_avail;
+		if (!min || min->ltd_qos.ltq_avail > tgt->ltd_qos.ltq_avail)
+			min = tgt;
+	}
+
+	/* avoid the most full MDT */
+	if (min)
+		avail -= min->ltd_qos.ltq_avail;
+
+	rand = lu_prandom_u64_max(avail);
+	avail = 0;
+	lmv_foreach_connected_tgt(lmv, tgt) {
+		if (!tgt->ltd_qos.ltq_usable)
+			continue;
+
+		if (tgt == min)
+			continue;
+
+		avail += tgt->ltd_qos.ltq_avail;
+		if (avail < rand)
+			continue;
+
+		goto unlock;
+	}
+
+	/* no proper target found */
+	tgt = ERR_PTR(-EAGAIN);
+unlock:
+	up_write(&lmv->lmv_qos.lq_rw_sem);
+
+	return tgt;
+}
+
 /* locate MDT by file name, for striped directory, the file name hash decides
  * which stripe its dirent is stored.
  */
@@ -1847,7 +1902,7 @@ int lmv_create(struct obd_export *exp, struct md_op_data *op_data,
 	} else if (lmv_op_qos_mkdir(op_data)) {
 		struct lmv_tgt_desc *tmp = tgt;
 
-		tgt = lmv_locate_tgt_qos(lmv, &op_data->op_mds,
+		tgt = lmv_locate_tgt_qos(lmv, op_data->op_mds,
 					 op_data->op_dir_depth);
 		if (tgt == ERR_PTR(-EAGAIN)) {
 			if (ltd_qos_is_balanced(&lmv->lmv_mdt_descs) &&
@@ -1858,11 +1913,12 @@ int lmv_create(struct obd_export *exp, struct md_op_data *op_data,
 				 */
 				tgt = tmp;
 			else
-				tgt = lmv_locate_tgt_rr(lmv, &op_data->op_mds);
+				tgt = lmv_locate_tgt_rr(lmv);
 		}
 		if (IS_ERR(tgt))
 			return PTR_ERR(tgt);
 
+		op_data->op_mds = tgt->ltd_index;
 		/*
 		 * only update statfs after QoS mkdir, this means the cached
 		 * statfs may be stale, and current mkdir may not follow QoS
@@ -2069,6 +2125,53 @@ static int lmv_link(struct obd_export *exp, struct md_op_data *op_data,
 	return md_link(tgt->ltd_exp, op_data, request);
 }
 
+/* migrate the top directory */
+static inline bool lmv_op_topdir_migrate(const struct md_op_data *op_data)
+{
+	if (!S_ISDIR(op_data->op_mode))
+		return false;
+
+	if (lmv_dir_layout_changing(op_data->op_mea1))
+		return false;
+
+	return true;
+}
+
+/* migrate top dir to specific MDTs */
+static inline bool lmv_topdir_specific_migrate(const struct md_op_data *op_data)
+{
+	const struct lmv_user_md *lum = op_data->op_data;
+
+	if (!lmv_op_topdir_migrate(op_data))
+		return false;
+
+	return le32_to_cpu(lum->lum_stripe_offset) != LMV_OFFSET_DEFAULT;
+}
+
+/* migrate top dir in QoS mode if user issued "lfs migrate -m -1..." */
+static inline bool lmv_topdir_qos_migrate(const struct md_op_data *op_data)
+{
+	const struct lmv_user_md *lum = op_data->op_data;
+
+	if (!lmv_op_topdir_migrate(op_data))
+		return false;
+
+	return le32_to_cpu(lum->lum_stripe_offset) == LMV_OFFSET_DEFAULT;
+}
+
+static inline bool lmv_subdir_specific_migrate(const struct md_op_data *op_data)
+{
+	const struct lmv_user_md *lum = op_data->op_data;
+
+	if (!S_ISDIR(op_data->op_mode))
+		return false;
+
+	if (!lmv_dir_layout_changing(op_data->op_mea1))
+		return false;
+
+	return le32_to_cpu(lum->lum_stripe_offset) != LMV_OFFSET_DEFAULT;
+}
+
 static int lmv_migrate(struct obd_export *exp, struct md_op_data *op_data,
 			const char *name, size_t namelen,
 			struct ptlrpc_request **request)
@@ -2133,19 +2236,56 @@ static int lmv_migrate(struct obd_export *exp, struct md_op_data *op_data,
 	if (IS_ERR(child_tgt))
 		return PTR_ERR(child_tgt);
 
-	/* for directory, migrate to MDT specified by lum_stripe_offset;
-	 * otherwise migrate to the target stripe of parent, but parent
-	 * directory may have finished migration (normally current file too),
-	 * allocate FID on MDT lum_stripe_offset, and server will check
-	 * whether file was migrated already.
-	 */
-	if (S_ISDIR(op_data->op_mode) || !tp_tgt) {
+	if (lmv_topdir_specific_migrate(op_data)) {
 		struct lmv_user_md *lum = op_data->op_data;
 
 		op_data->op_mds = le32_to_cpu(lum->lum_stripe_offset);
-	} else  {
+	} else if (lmv_topdir_qos_migrate(op_data)) {
+		tgt = lmv_locate_tgt_lf(lmv);
+		if (tgt == ERR_PTR(-EAGAIN))
+			tgt = lmv_locate_tgt_rr(lmv);
+		if (IS_ERR(tgt))
+			return PTR_ERR(tgt);
+
+		op_data->op_mds = tgt->ltd_index;
+	} else if (lmv_subdir_specific_migrate(op_data)) {
+		struct lmv_user_md *lum = op_data->op_data;
+		u32 i;
+
+		LASSERT(tp_tgt);
+		if (le32_to_cpu(lum->lum_magic) == LMV_USER_MAGIC_SPECIFIC) {
+			/* adjust MDTs in lum, since subdir is located on where
+			 * its parent stripe is, not the first specified MDT.
+			 */
+			for (i = 0; i < le32_to_cpu(lum->lum_stripe_count);
+			     i++) {
+				if (le32_to_cpu(lum->lum_objects[i].lum_mds) ==
+				    tp_tgt->ltd_index)
+					break;
+			}
+
+			if (i == le32_to_cpu(lum->lum_stripe_count))
+				return -ENODEV;
+
+			lum->lum_objects[i].lum_mds =
+				lum->lum_objects[0].lum_mds;
+			lum->lum_objects[0].lum_mds =
+				cpu_to_le32(tp_tgt->ltd_index);
+		}
+		/* NB, the above adjusts subdir migration for command like
+		 * "lfs migrate -m 0,1,2 ...", but for migration like
+		 * "lfs migrate -m 0 -c 2 ...", the top dir is migrated to MDT0
+		 * and MDT1, however its subdir may be migrated to MDT1 and MDT2
+		 */
+
+		lum->lum_stripe_offset = cpu_to_le32(tp_tgt->ltd_index);
 		op_data->op_mds = tp_tgt->ltd_index;
+	} else if (tp_tgt) {
+		op_data->op_mds = tp_tgt->ltd_index;
+	} else {
+		op_data->op_mds = sp_tgt->ltd_index;
 	}
+
 	rc = lmv_fid_alloc(NULL, exp, &target_fid, op_data);
 	if (rc)
 		return rc;
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
