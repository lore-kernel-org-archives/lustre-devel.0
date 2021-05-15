Return-Path: <SRS0=EXfh=KK=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.7 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D1750C433B4
	for <lustre-devel@archiver.kernel.org>; Sat, 15 May 2021 13:06:39 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 88311611C9
	for <lustre-devel@archiver.kernel.org>; Sat, 15 May 2021 13:06:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 88311611C9
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 0F8B021FAFA;
	Sat, 15 May 2021 06:06:27 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id C5A5F21E068
 for <lustre-devel@lists.lustre.org>; Sat, 15 May 2021 06:06:16 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 91A3D1006EA0;
 Sat, 15 May 2021 09:06:12 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 8D54498124; Sat, 15 May 2021 09:06:12 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sat, 15 May 2021 09:06:08 -0400
Message-Id: <1621083970-32463-12-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1621083970-32463-1-git-send-email-jsimmons@infradead.org>
References: <1621083970-32463-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 11/13] lustre: lmv: qos stay on current MDT
 if less full
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

From: Andreas Dilger <adilger@whamcloud.com>

Keep "space balanced" subdirectories on the parent MDT if it is less
full than average, since it doesn't make sense to select another MDT
which may occasionally be *more* full.  This also reduces random
"MDT jumping" and needless remote directories.

Reduce the QOS threshold for space balanced LMV layouts, so that the
MDTs don't become too imbalanced before trying to fix the problem.

Change the LUSTRE_OP_MKDIR opcode to be 1 instead of 0, so it can
be seen that a valid opcode has been stored into the structure.

WC-bug-id: https://jira.whamcloud.com/browse/LU-13439
Lustre-commit: 94da640afc0f ("LU-13439 lmv: qos stay on current MDT if less full")
Signed-off-by: Lai Siyao <lai.siyao@whamcloud.com>
Signed-off-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/43445
Reviewed-by: Mike Pershin <mpershin@whamcloud.com>
Reviewed-by: Hongchao Zhang <hongchao@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lu_object.h     |  6 ++++++
 fs/lustre/include/obd.h           | 10 +++++-----
 fs/lustre/lmv/lmv_obd.c           | 22 +++++++++++++++++++---
 fs/lustre/obdclass/lu_tgt_descs.c | 18 +++++++++++++-----
 4 files changed, 43 insertions(+), 13 deletions(-)

diff --git a/fs/lustre/include/lu_object.h b/fs/lustre/include/lu_object.h
index 3a71d6b..b1d7577 100644
--- a/fs/lustre/include/lu_object.h
+++ b/fs/lustre/include/lu_object.h
@@ -1457,6 +1457,12 @@ struct lu_tgt_qos {
 };
 
 /* target descriptor */
+#define LOV_QOS_DEF_THRESHOLD_RR_PCT	17
+#define LMV_QOS_DEF_THRESHOLD_RR_PCT	5
+
+#define LOV_QOS_DEF_PRIO_FREE		90
+#define LMV_QOS_DEF_PRIO_FREE		90
+
 struct lu_tgt_desc {
 	union {
 		struct dt_device	*ltd_tgt;
diff --git a/fs/lustre/include/obd.h b/fs/lustre/include/obd.h
index efd4538..678953a 100644
--- a/fs/lustre/include/obd.h
+++ b/fs/lustre/include/obd.h
@@ -718,11 +718,11 @@ enum md_cli_flags {
 };
 
 enum md_op_code {
-	LUSTRE_OPC_MKDIR	= 0,
-	LUSTRE_OPC_SYMLINK	= 1,
-	LUSTRE_OPC_MKNOD	= 2,
-	LUSTRE_OPC_CREATE	= 3,
-	LUSTRE_OPC_ANY		= 5,
+	LUSTRE_OPC_MKDIR = 1,
+	LUSTRE_OPC_SYMLINK,
+	LUSTRE_OPC_MKNOD,
+	LUSTRE_OPC_CREATE,
+	LUSTRE_OPC_ANY,
 };
 
 /**
diff --git a/fs/lustre/lmv/lmv_obd.c b/fs/lustre/lmv/lmv_obd.c
index 552ef07..fb89047 100644
--- a/fs/lustre/lmv/lmv_obd.c
+++ b/fs/lustre/lmv/lmv_obd.c
@@ -1429,9 +1429,10 @@ static int lmv_close(struct obd_export *exp, struct md_op_data *op_data,
 
 static struct lu_tgt_desc *lmv_locate_tgt_qos(struct lmv_obd *lmv, u32 *mdt)
 {
-	struct lu_tgt_desc *tgt;
+	struct lu_tgt_desc *tgt, *cur = NULL;
 	u64 total_weight = 0;
 	u64 cur_weight = 0;
+	int total_usable = 0;
 	u64 rand;
 	int rc;
 
@@ -1452,15 +1453,30 @@ static struct lu_tgt_desc *lmv_locate_tgt_qos(struct lmv_obd *lmv, u32 *mdt)
 	}
 
 	lmv_foreach_tgt(lmv, tgt) {
-		tgt->ltd_qos.ltq_usable = 0;
-		if (!tgt->ltd_exp || !tgt->ltd_active)
+		if (!tgt->ltd_exp || !tgt->ltd_active) {
+			tgt->ltd_qos.ltq_usable = 0;
 			continue;
+		}
 
 		tgt->ltd_qos.ltq_usable = 1;
 		lu_tgt_qos_weight_calc(tgt);
+		if (tgt->ltd_index == *mdt) {
+			cur = tgt;
+			cur_weight = tgt->ltd_qos.ltq_weight;
+		}
 		total_weight += tgt->ltd_qos.ltq_weight;
+		total_usable++;
+	}
+
+	/* if current MDT has higher-than-average space, stay on same MDT */
+	rand = total_weight / total_usable;
+	if (cur_weight >= rand) {
+		tgt = cur;
+		rc = 0;
+		goto unlock;
 	}
 
+	cur_weight = 0;
 	rand = lu_prandom_u64_max(total_weight);
 
 	lmv_foreach_connected_tgt(lmv, tgt) {
diff --git a/fs/lustre/obdclass/lu_tgt_descs.c b/fs/lustre/obdclass/lu_tgt_descs.c
index 83f4675..2a2b30a 100644
--- a/fs/lustre/obdclass/lu_tgt_descs.c
+++ b/fs/lustre/obdclass/lu_tgt_descs.c
@@ -265,13 +265,21 @@ int lu_tgt_descs_init(struct lu_tgt_descs *ltd, bool is_mdt)
 	init_rwsem(&ltd->ltd_qos.lq_rw_sem);
 	set_bit(LQ_DIRTY, &ltd->ltd_qos.lq_flags);
 	set_bit(LQ_RESET, &ltd->ltd_qos.lq_flags);
-	/* Default priority is toward free space balance */
-	ltd->ltd_qos.lq_prio_free = 232;
-	/* Default threshold for rr (roughly 17%) */
-	ltd->ltd_qos.lq_threshold_rr = 43;
 	ltd->ltd_is_mdt = is_mdt;
-	if (is_mdt)
+	/* MDT imbalance threshold is low to balance across MDTs
+	 * relatively quickly, because each directory may result
+	 * in a large number of files/subdirs created therein.
+	 */
+	if (is_mdt) {
 		ltd->ltd_lmv_desc.ld_pattern = LMV_HASH_TYPE_DEFAULT;
+		ltd->ltd_qos.lq_prio_free = LMV_QOS_DEF_PRIO_FREE * 256 / 100;
+		ltd->ltd_qos.lq_threshold_rr =
+			LMV_QOS_DEF_THRESHOLD_RR_PCT * 256 / 100;
+	} else {
+		ltd->ltd_qos.lq_prio_free = LOV_QOS_DEF_PRIO_FREE * 256 / 100;
+		ltd->ltd_qos.lq_threshold_rr =
+			LOV_QOS_DEF_THRESHOLD_RR_PCT * 256 / 100;
+	}
 
 	return 0;
 }
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
