Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 7EF3AECAAD3
	for <lustre-devel@archiver.kernel.org>; Tue,  6 Sep 2022 01:55:55 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4MM7lF73nhz1y6p;
	Mon,  5 Sep 2022 18:55:53 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4MM7l23tVfz1wn4
 for <lustre-devel@lists.lustre.org>; Mon,  5 Sep 2022 18:55:42 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 9CF3B100AFF6;
 Mon,  5 Sep 2022 21:55:39 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 93BC058994; Mon,  5 Sep 2022 21:55:39 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon,  5 Sep 2022 21:55:15 -0400
Message-Id: <1662429337-18737-3-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1662429337-18737-1-git-send-email-jsimmons@infradead.org>
References: <1662429337-18737-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 02/24] lustre: lmv: always space-balance r-r
 directories
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
Cc: Lai Siyao <lai.siyao@whamcloud.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Lai Siyao <lai.siyao@whamcloud.com>

If the MDT free space is imbalanced, use QOS space balancing for
round-robin subdirectory creation, regardless of the depth
of the directory tree.  Otherwise, new subdirectories created
in parents with round-robin default layout may suddenly become
"sticky" on the parent MDT and upset the space balancing and
load distribution.

Fixes: a8948860e4 ("lustre: lmv: improve MDT QOS space balance")
WC-bug-id: https://jira.whamcloud.com/browse/LU-15850
Signed-off-by: Lai Siyao <lai.siyao@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/47578
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Hongchao Zhang <hongchao@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/lmv/lmv_obd.c | 38 ++++++++++++++++++++++----------------
 1 file changed, 22 insertions(+), 16 deletions(-)

diff --git a/fs/lustre/lmv/lmv_obd.c b/fs/lustre/lmv/lmv_obd.c
index 6c0eb03..0988b1a 100644
--- a/fs/lustre/lmv/lmv_obd.c
+++ b/fs/lustre/lmv/lmv_obd.c
@@ -55,6 +55,7 @@
 #include "lmv_internal.h"
 
 static int lmv_check_connect(struct obd_device *obd);
+static inline bool lmv_op_default_rr_mkdir(const struct md_op_data *op_data);
 
 void lmv_activate_target(struct lmv_obd *lmv, struct lmv_tgt_desc *tgt,
 			 int activate)
@@ -1446,8 +1447,8 @@ static int lmv_close(struct obd_export *exp, struct md_op_data *op_data,
 	return md_close(tgt->ltd_exp, op_data, mod, request);
 }
 
-static struct lu_tgt_desc *lmv_locate_tgt_qos(struct lmv_obd *lmv, u32 mdt,
-					      unsigned short dir_depth)
+static struct lu_tgt_desc *lmv_locate_tgt_qos(struct lmv_obd *lmv,
+					      struct md_op_data *op_data)
 {
 	struct lu_tgt_desc *tgt, *cur = NULL;
 	u64 total_avail = 0;
@@ -1481,23 +1482,31 @@ static struct lu_tgt_desc *lmv_locate_tgt_qos(struct lmv_obd *lmv, u32 mdt,
 
 		tgt->ltd_qos.ltq_usable = 1;
 		lu_tgt_qos_weight_calc(tgt);
-		if (tgt->ltd_index == mdt)
+		if (tgt->ltd_index == op_data->op_mds)
 			cur = tgt;
 		total_avail += tgt->ltd_qos.ltq_avail;
 		total_weight += tgt->ltd_qos.ltq_weight;
 		total_usable++;
 	}
 
-	/* if current MDT has above-average space, within range of the QOS
-	 * threshold, stay on the same MDT to avoid creating needless remote
-	 * MDT directories. It's more likely for low level directories
-	 * "16 / (dir_depth + 10)" is the factor to make it more unlikely for
-	 * top level directories, while more likely for low levels.
+	/* If current MDT has above-average space and dir is not aleady using
+	 * round-robin to spread across more MDTs, stay on the parent MDT
+	 * to avoid creating needless remote MDT directories.  Remote dirs
+	 * close to the root balance space more effectively than bottom dirs,
+	 * so prefer to create remote dirs at top level of directory tree.
+	 * "16 / (dir_depth + 10)" is the factor to make it less likely
+	 * for top-level directories to stay local unless they have more than
+	 * average free space, while deep dirs prefer local until more full.
+	 *    depth=0 -> 160%, depth=3 -> 123%, depth=6 -> 100%,
+	 *    depth=9 -> 84%, depth=12 -> 73%, depth=15 -> 64%
 	 */
-	rand = total_avail * 16 / (total_usable * (dir_depth + 10));
-	if (cur && cur->ltd_qos.ltq_avail >= rand) {
-		tgt = cur;
-		goto unlock;
+	if (!lmv_op_default_rr_mkdir(op_data)) {
+		rand = total_avail * 16 /
+			(total_usable * (op_data->op_dir_depth + 10));
+		if (cur && cur->ltd_qos.ltq_avail >= rand) {
+			tgt = cur;
+			goto unlock;
+		}
 	}
 
 	rand = lu_prandom_u64_max(total_weight);
@@ -1836,9 +1845,6 @@ static inline bool lmv_op_default_rr_mkdir(const struct md_op_data *op_data)
 {
 	const struct lmv_stripe_md *lsm = op_data->op_default_mea1;
 
-	if (!lmv_op_default_qos_mkdir(op_data))
-		return false;
-
 	return (op_data->op_flags & MF_RR_MKDIR) ||
 	       (lsm && lsm->lsm_md_max_inherit_rr != LMV_INHERIT_RR_NONE) ||
 	       fid_is_root(&op_data->op_fid1);
@@ -1873,7 +1879,7 @@ static struct lu_tgt_desc *lmv_locate_tgt_by_space(struct lmv_obd *lmv,
 {
 	struct lmv_tgt_desc *tmp = tgt;
 
-	tgt = lmv_locate_tgt_qos(lmv, op_data->op_mds, op_data->op_dir_depth);
+	tgt = lmv_locate_tgt_qos(lmv, op_data);
 	if (tgt == ERR_PTR(-EAGAIN)) {
 		if (ltd_qos_is_balanced(&lmv->lmv_mdt_descs) &&
 		    !lmv_op_default_rr_mkdir(op_data) &&
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
