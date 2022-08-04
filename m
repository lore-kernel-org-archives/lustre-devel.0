Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 99310C19F2D
	for <lustre-devel@archiver.kernel.org>; Thu,  4 Aug 2022 01:39:58 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4Lyry61hWPz23L3;
	Wed,  3 Aug 2022 18:39:58 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4Lyrwh2Ktzz23Hf
 for <lustre-devel@lists.lustre.org>; Wed,  3 Aug 2022 18:38:44 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id EC225100B035;
 Wed,  3 Aug 2022 21:38:23 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id EAA828D626; Wed,  3 Aug 2022 21:38:23 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Wed,  3 Aug 2022 21:38:10 -0400
Message-Id: <1659577097-19253-26-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1659577097-19253-1-git-send-email-jsimmons@infradead.org>
References: <1659577097-19253-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 25/32] lustre: quota: skip non-exist or inact
 tgt for lfs_quota
X-BeenThere: lustre-devel@lists.lustre.org
X-Mailman-Version: 2.1.39
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
Cc: Hongchao Zhang <hongchao@whamcloud.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Hongchao Zhang <hongchao@whamcloud.com>

The nonexistent or inactive targets (MDC or OSC) should be skipped
for quota reporting.

WC-bug-id: https://jira.whamcloud.com/browse/LU-14472
Lustre-commit: b54b7ce43929ce7ff ("LU-14472 quota: skip non-exist or inact tgt for lfs_quota")
Signed-off-by: Hongchao Zhang <hongchao@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/41771
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Feng, Lei <flei@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/dir.c   |  8 +++-----
 fs/lustre/lmv/lmv_obd.c | 15 +++++++++++++--
 fs/lustre/lov/lov_obd.c | 13 ++++++++++++-
 3 files changed, 28 insertions(+), 8 deletions(-)

diff --git a/fs/lustre/llite/dir.c b/fs/lustre/llite/dir.c
index 2b63c48..26c9ec3 100644
--- a/fs/lustre/llite/dir.c
+++ b/fs/lustre/llite/dir.c
@@ -1215,10 +1215,9 @@ int quotactl_ioctl(struct super_block *sb, struct if_quotactl *qctl)
 			break;
 		}
 
+		qctl->qc_cmd = cmd;
 		if (rc)
 			return rc;
-
-		qctl->qc_cmd = cmd;
 	} else {
 		struct obd_quotactl *oqctl;
 		int oqctl_len = sizeof(*oqctl);
@@ -2009,10 +2008,9 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 		}
 
 		rc = quotactl_ioctl(inode->i_sb, qctl);
-		if (rc == 0 && copy_to_user((void __user *)arg, qctl,
-					    sizeof(*qctl)))
+		if ((rc == 0 || rc == -ENODATA) &&
+		    copy_to_user((void __user *)arg, qctl, sizeof(*qctl)))
 			rc = -EFAULT;
-
 out_quotactl:
 		kfree(qctl);
 		return rc;
diff --git a/fs/lustre/lmv/lmv_obd.c b/fs/lustre/lmv/lmv_obd.c
index 8656d6b..6c0eb03 100644
--- a/fs/lustre/lmv/lmv_obd.c
+++ b/fs/lustre/lmv/lmv_obd.c
@@ -845,6 +845,7 @@ static int lmv_iocontrol(unsigned int cmd, struct obd_export *exp,
 	case OBD_IOC_QUOTACTL: {
 		struct if_quotactl *qctl = karg;
 		struct obd_quotactl *oqctl;
+		struct obd_import *imp;
 
 		if (qctl->qc_valid == QC_MDTIDX) {
 			tgt = lmv_tgt(lmv, qctl->qc_idx);
@@ -863,9 +864,19 @@ static int lmv_iocontrol(unsigned int cmd, struct obd_export *exp,
 			return -EINVAL;
 		}
 
-		if (!tgt || !tgt->ltd_exp)
+		if (!tgt)
+			return -ENODEV;
+
+		if (!tgt->ltd_exp)
 			return -EINVAL;
 
+		imp = class_exp2cliimp(tgt->ltd_exp);
+		if (!tgt->ltd_active && imp->imp_state != LUSTRE_IMP_IDLE) {
+			qctl->qc_valid = QC_MDTIDX;
+			qctl->obd_uuid = tgt->ltd_uuid;
+			return -ENODATA;
+		}
+
 		oqctl = kzalloc(sizeof(*oqctl), GFP_KERNEL);
 		if (!oqctl)
 			return -ENOMEM;
@@ -3122,7 +3133,7 @@ static int lmv_get_info(const struct lu_env *env, struct obd_export *exp,
 			exp->exp_connect_data = *(struct obd_connect_data *)val;
 		return rc;
 	} else if (KEY_IS(KEY_TGT_COUNT)) {
-		*((int *)val) = lmv->lmv_mdt_descs.ltd_lmv_desc.ld_tgt_count;
+		*((int *)val) = lmv->lmv_mdt_descs.ltd_tgts_size;
 		return 0;
 	}
 
diff --git a/fs/lustre/lov/lov_obd.c b/fs/lustre/lov/lov_obd.c
index 161226f..d2fe8c3 100644
--- a/fs/lustre/lov/lov_obd.c
+++ b/fs/lustre/lov/lov_obd.c
@@ -1021,13 +1021,17 @@ static int lov_iocontrol(unsigned int cmd, struct obd_export *exp, int len,
 		struct if_quotactl *qctl = karg;
 		struct lov_tgt_desc *tgt = NULL;
 		struct obd_quotactl *oqctl;
+		struct obd_import *imp;
 
 		if (qctl->qc_valid == QC_OSTIDX) {
 			if (count <= qctl->qc_idx)
 				return -EINVAL;
 
 			tgt = lov->lov_tgts[qctl->qc_idx];
-			if (!tgt || !tgt->ltd_exp)
+			if (!tgt)
+				return -ENODEV;
+
+			if (!tgt->ltd_exp)
 				return -EINVAL;
 		} else if (qctl->qc_valid == QC_UUID) {
 			for (i = 0; i < count; i++) {
@@ -1050,6 +1054,13 @@ static int lov_iocontrol(unsigned int cmd, struct obd_export *exp, int len,
 			return -EAGAIN;
 
 		LASSERT(tgt && tgt->ltd_exp);
+		imp = class_exp2cliimp(tgt->ltd_exp);
+		if (!tgt->ltd_active && imp->imp_state != LUSTRE_IMP_IDLE) {
+			qctl->qc_valid = QC_OSTIDX;
+			qctl->obd_uuid = tgt->ltd_uuid;
+			return -ENODATA;
+		}
+
 		oqctl = kzalloc(sizeof(*oqctl), GFP_NOFS);
 		if (!oqctl)
 			return -ENOMEM;
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
