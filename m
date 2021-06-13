Return-Path: <SRS0=27wn=LH=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4BB9FC48BE8
	for <lustre-devel@archiver.kernel.org>; Sun, 13 Jun 2021 23:11:55 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id CC17D61360
	for <lustre-devel@archiver.kernel.org>; Sun, 13 Jun 2021 23:11:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CC17D61360
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id CB97421F3D6;
	Sun, 13 Jun 2021 16:11:49 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 0FECC21C959
 for <lustre-devel@lists.lustre.org>; Sun, 13 Jun 2021 16:11:42 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id B8754100B009;
 Sun, 13 Jun 2021 19:11:38 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id AF1059C317; Sun, 13 Jun 2021 19:11:38 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 13 Jun 2021 19:11:16 -0400
Message-Id: <1623625897-17706-7-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1623625897-17706-1-git-send-email-jsimmons@infradead.org>
References: <1623625897-17706-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 06/27] lustre: pcc: don't alloc FID in LLITE
 for pcc open
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

ll_lookup_it(IT_OPEN) always alloc FID on MDT0 for pcc open, but
the open request is sent to MDT where the name hash points to,
which may be different from the MDT where the FID is, which will
trigger osp_md_create() assertion because file is created remotely.

This FID allocation is not necessary, and it can be left to be done
in lmv_intent_open() by LMV layer, because the MDT is chosen in
LMV. Then when it's done, the FID allocated can be used to initialize
PCC inode.

WC-bug-id: https://jira.whamcloud.com/browse/LU-13852
Lustre-commit: 223728a97c397e6e ("LU-13852 pcc: don't alloc FID in LLITE for pcc open")
Signed-off-by: Lai Siyao <lai.siyao@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/39568
Reviewed-by: Yingjin Qian <qian@ddn.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/namei.c    | 29 +++++++++++------------------
 fs/lustre/lmv/lmv_intent.c |  6 ++----
 2 files changed, 13 insertions(+), 22 deletions(-)

diff --git a/fs/lustre/llite/namei.c b/fs/lustre/llite/namei.c
index f5f34b0..a2f5d8d 100644
--- a/fs/lustre/llite/namei.c
+++ b/fs/lustre/llite/namei.c
@@ -912,8 +912,6 @@ static struct dentry *ll_lookup_it(struct inode *parent, struct dentry *dentry,
 	}
 
 	if (pca && pca->pca_dataset) {
-		struct pcc_dataset *dataset = pca->pca_dataset;
-
 		lum = kzalloc(sizeof(*lum), GFP_NOFS);
 		if (!lum) {
 			retval = ERR_PTR(-ENOMEM);
@@ -924,22 +922,7 @@ static struct dentry *ll_lookup_it(struct inode *parent, struct dentry *dentry,
 		lum->lmm_pattern = LOV_PATTERN_F_RELEASED | LOV_PATTERN_RAID0;
 		op_data->op_data = lum;
 		op_data->op_data_size = sizeof(*lum);
-		op_data->op_archive_id = dataset->pccd_rwid;
-
-		rc = obd_fid_alloc(NULL, ll_i2mdexp(parent), &op_data->op_fid2,
-				   op_data);
-		if (rc) {
-			retval = ERR_PTR(rc);
-			goto out;
-		}
-
-		rc = pcc_inode_create(parent->i_sb, dataset, &op_data->op_fid2,
-				      &pca->pca_dentry);
-		if (rc) {
-			retval = ERR_PTR(rc);
-			goto out;
-		}
-
+		op_data->op_archive_id = pca->pca_dataset->pccd_rwid;
 		it->it_flags |= MDS_OPEN_PCC;
 	}
 
@@ -980,6 +963,16 @@ static struct dentry *ll_lookup_it(struct inode *parent, struct dentry *dentry,
 		goto out;
 	}
 
+	if (pca && pca->pca_dataset) {
+		rc = pcc_inode_create(parent->i_sb, pca->pca_dataset,
+				      &op_data->op_fid2,
+				      &pca->pca_dentry);
+		if (rc) {
+			retval = ERR_PTR(rc);
+			goto out;
+		}
+	}
+
 	/* dir layout may change */
 	ll_unlock_md_op_lsm(op_data);
 	rc = ll_lookup_it_finish(req, it, parent, &dentry,
diff --git a/fs/lustre/lmv/lmv_intent.c b/fs/lustre/lmv/lmv_intent.c
index 398bd17..88201e6 100644
--- a/fs/lustre/lmv/lmv_intent.c
+++ b/fs/lustre/lmv/lmv_intent.c
@@ -349,8 +349,7 @@ static int lmv_intent_open(struct obd_export *exp, struct md_op_data *op_data,
 		op_data->op_mds = tgt->ltd_index;
 	} else {
 		LASSERT(fid_is_sane(&op_data->op_fid1));
-		LASSERT(it->it_flags & MDS_OPEN_PCC ||
-			fid_is_zero(&op_data->op_fid2));
+		LASSERT(fid_is_zero(&op_data->op_fid2));
 		LASSERT(op_data->op_name);
 
 		tgt = lmv_locate_tgt(lmv, op_data);
@@ -361,8 +360,7 @@ static int lmv_intent_open(struct obd_export *exp, struct md_op_data *op_data,
 	/* If it is ready to open the file by FID, do not need
 	 * allocate FID at all, otherwise it will confuse MDT
 	 */
-	if ((it->it_op & IT_CREAT) && !(it->it_flags & MDS_OPEN_BY_FID ||
-					it->it_flags & MDS_OPEN_PCC)) {
+	if ((it->it_op & IT_CREAT) && !(it->it_flags & MDS_OPEN_BY_FID)) {
 		/*
 		 * For lookup(IT_CREATE) cases allocate new fid and setup FLD
 		 * for it.
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
