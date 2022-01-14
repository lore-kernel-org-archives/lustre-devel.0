Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 6274BC433F5
	for <lustre-devel@archiver.kernel.org>; Fri, 14 Jan 2022 01:38:36 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id DB7693AD9A0;
	Thu, 13 Jan 2022 17:38:26 -0800 (PST)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 361583AD812
 for <lustre-devel@lists.lustre.org>; Thu, 13 Jan 2022 17:38:09 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id C2D08100F32C;
 Thu, 13 Jan 2022 20:38:04 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id BE109DF4C4; Thu, 13 Jan 2022 20:38:04 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Thu, 13 Jan 2022 20:37:48 -0500
Message-Id: <1642124283-10148-10-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1642124283-10148-1-git-send-email-jsimmons@infradead.org>
References: <1642124283-10148-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 09/24] lustre: lmv: set default LMV for "lfs
 mkdir -c 1"
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

With the introduction of filesystem-wide default LMV, dirs will be
created on MDT by space usage, but if dir is created by
"lfs mkdir -c 1 ...", its subdirs should be kept on the same MDT.
To achieve this, set default LMV on such dirs, NB if user doesn't
want this, he needs to create dir with
"lfs mkdir -c 1 --max-inherit=0 ...".

The policy to choose MDT in mkdir is as below:
1. is "lfs mkdir -i N"? mkdir on MDT N.
2. is "lfs mkdir -i -1"? mkdir by space usage.
3. is starting MDT specified in default LMV? mkdir on MDT N.
4. is default LMV space balanced? mkdir by space usage.

WC-bug-id: https://jira.whamcloud.com/browse/LU-14560
Lustre-commit: bc2d7f065af6b4f9a ("LU-13560 lod: set default LMV for "lfs mkdir -c 1")
Signed-off-by: Lai Siyao <lai.siyao@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/45290
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Hongchao Zhang <hongchao@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/lmv/lmv_obd.c | 104 +++++++++++++++++++++++++++---------------------
 1 file changed, 58 insertions(+), 46 deletions(-)

diff --git a/fs/lustre/lmv/lmv_obd.c b/fs/lustre/lmv/lmv_obd.c
index c87f37f..55816a1 100644
--- a/fs/lustre/lmv/lmv_obd.c
+++ b/fs/lustre/lmv/lmv_obd.c
@@ -1770,46 +1770,39 @@ int lmv_old_layout_lookup(struct lmv_obd *lmv, struct md_op_data *op_data)
 	return rc;
 }
 
+/* mkdir by QoS upon 'lfs mkdir -i -1'.
+ *
+ * NB, mkdir by QoS only if parent is not striped, this is to avoid remote
+ * directories under striped directory.
+ */
 static inline bool lmv_op_user_qos_mkdir(const struct md_op_data *op_data)
 {
 	const struct lmv_user_md *lum = op_data->op_data;
 
+	if (op_data->op_code != LUSTRE_OPC_MKDIR)
+		return false;
+
+	if (lmv_dir_striped(op_data->op_mea1))
+		return false;
+
 	return (op_data->op_cli_flags & CLI_SET_MEA) && lum &&
 	       le32_to_cpu(lum->lum_magic) == LMV_USER_MAGIC &&
 	       le32_to_cpu(lum->lum_stripe_offset) == LMV_OFFSET_DEFAULT;
 }
 
+/* mkdir by QoS if either ROOT or parent default LMV is space balanced. */
 static inline bool lmv_op_default_qos_mkdir(const struct md_op_data *op_data)
 {
 	const struct lmv_stripe_md *lsm = op_data->op_default_mea1;
 
-	return (op_data->op_flags & MF_QOS_MKDIR) ||
-	       (lsm && lsm->lsm_md_master_mdt_index == LMV_OFFSET_DEFAULT);
-}
-
-/* mkdir by QoS in three cases:
- * 1. ROOT default LMV is space balanced.
- * 2. 'lfs mkdir -i -1'
- * 3. parent default LMV master_mdt_index is -1
- *
- * NB, mkdir by QoS only if parent is not striped, this is to avoid remote
- * directories under striped directory.
- */
-static inline bool lmv_op_qos_mkdir(const struct md_op_data *op_data)
-{
 	if (op_data->op_code != LUSTRE_OPC_MKDIR)
 		return false;
 
 	if (lmv_dir_striped(op_data->op_mea1))
 		return false;
 
-	if (lmv_op_user_qos_mkdir(op_data))
-		return true;
-
-	if (lmv_op_default_qos_mkdir(op_data))
-		return true;
-
-	return false;
+	return (op_data->op_flags & MF_QOS_MKDIR) ||
+	       (lsm && lsm->lsm_md_master_mdt_index == LMV_OFFSET_DEFAULT);
 }
 
 /* if parent default LMV is space balanced, and
@@ -1853,6 +1846,38 @@ static inline bool lmv_op_user_specific_mkdir(const struct md_op_data *op_data)
 			LMV_OFFSET_DEFAULT;
 }
 
+/* locate MDT by space usage */
+static struct lu_tgt_desc *lmv_locate_tgt_by_space(struct lmv_obd *lmv,
+						   struct md_op_data *op_data,
+						   struct lmv_tgt_desc *tgt)
+{
+	struct lmv_tgt_desc *tmp = tgt;
+
+	tgt = lmv_locate_tgt_qos(lmv, op_data->op_mds, op_data->op_dir_depth);
+	if (tgt == ERR_PTR(-EAGAIN)) {
+		if (ltd_qos_is_balanced(&lmv->lmv_mdt_descs) &&
+		    !lmv_op_default_rr_mkdir(op_data) &&
+		    !lmv_op_user_qos_mkdir(op_data))
+			/* if not necessary, don't create remote directory. */
+			tgt = tmp;
+		else
+			tgt = lmv_locate_tgt_rr(lmv);
+	}
+
+	/*
+	 * only update statfs after QoS mkdir, this means the cached statfs may
+	 * be stale, and current mkdir may not follow QoS accurately, but it's
+	 * not serious, and avoids periodic statfs when client doesn't mkdir by
+	 * QoS.
+	 */
+	if (!IS_ERR(tgt)) {
+		op_data->op_mds = tgt->ltd_index;
+		lmv_statfs_check_update(lmv2obd_dev(lmv), tgt);
+	}
+
+	return tgt;
+}
+
 int lmv_create(struct obd_export *exp, struct md_op_data *op_data,
 		const void *data, size_t datalen, umode_t mode, uid_t uid,
 		gid_t gid, kernel_cap_t cap_effective, u64 rdev,
@@ -1886,6 +1911,12 @@ int lmv_create(struct obd_export *exp, struct md_op_data *op_data,
 	if (IS_ERR(tgt))
 		return PTR_ERR(tgt);
 
+	/* the order to apply policy in mkdir:
+	 * 1. is "lfs mkdir -i N"? mkdir on MDT N.
+	 * 2. is "lfs mkdir -i -1"? mkdir by space usage.
+	 * 3. is starting MDT specified in default LMV? mkdir on MDT N.
+	 * 4. is default LMV space balanced? mkdir by space usage.
+	 */
 	if (lmv_op_user_specific_mkdir(op_data)) {
 		struct lmv_user_md *lum = op_data->op_data;
 
@@ -1893,39 +1924,20 @@ int lmv_create(struct obd_export *exp, struct md_op_data *op_data,
 		tgt = lmv_tgt(lmv, op_data->op_mds);
 		if (!tgt)
 			return -ENODEV;
+	} else if (lmv_op_user_qos_mkdir(op_data)) {
+		tgt = lmv_locate_tgt_by_space(lmv, op_data, tgt);
+		if (IS_ERR(tgt))
+			return PTR_ERR(tgt);
 	} else if (lmv_op_default_specific_mkdir(op_data)) {
 		op_data->op_mds =
 			op_data->op_default_mea1->lsm_md_master_mdt_index;
 		tgt = lmv_tgt(lmv, op_data->op_mds);
 		if (!tgt)
 			return -ENODEV;
-	} else if (lmv_op_qos_mkdir(op_data)) {
-		struct lmv_tgt_desc *tmp = tgt;
-
-		tgt = lmv_locate_tgt_qos(lmv, op_data->op_mds,
-					 op_data->op_dir_depth);
-		if (tgt == ERR_PTR(-EAGAIN)) {
-			if (ltd_qos_is_balanced(&lmv->lmv_mdt_descs) &&
-			    !lmv_op_default_rr_mkdir(op_data) &&
-			    !lmv_op_user_qos_mkdir(op_data))
-				/* if it's not necessary, don't create remote
-				 * directory.
-				 */
-				tgt = tmp;
-			else
-				tgt = lmv_locate_tgt_rr(lmv);
-		}
+	} else if (lmv_op_default_qos_mkdir(op_data)) {
+		tgt = lmv_locate_tgt_by_space(lmv, op_data, tgt);
 		if (IS_ERR(tgt))
 			return PTR_ERR(tgt);
-
-		op_data->op_mds = tgt->ltd_index;
-		/*
-		 * only update statfs after QoS mkdir, this means the cached
-		 * statfs may be stale, and current mkdir may not follow QoS
-		 * accurately, but it's not serious, and avoids periodic statfs
-		 * when client doesn't mkdir by QoS.
-		 */
-		lmv_statfs_check_update(obd, tgt);
 	}
 
 retry:
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
