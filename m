Return-Path: <SRS0=HxeM=ML=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 317B1C07E9B
	for <lustre-devel@archiver.kernel.org>; Mon, 19 Jul 2021 12:32:47 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id E65226112D
	for <lustre-devel@archiver.kernel.org>; Mon, 19 Jul 2021 12:32:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E65226112D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id EAE3C34F996;
	Mon, 19 Jul 2021 05:32:31 -0700 (PDT)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 453FA34F962
 for <lustre-devel@lists.lustre.org>; Mon, 19 Jul 2021 05:32:19 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id A0EA86BF;
 Mon, 19 Jul 2021 08:32:15 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 8F5C5BD1CE; Mon, 19 Jul 2021 08:32:15 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon, 19 Jul 2021 08:32:00 -0400
Message-Id: <1626697933-6971-6-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1626697933-6971-1-git-send-email-jsimmons@infradead.org>
References: <1626697933-6971-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 05/18] lustre: lmv: compare space to mkdir on
 parent MDT
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

In QOS subdirectory creation, subdirectories are kept on parent MDT
if it is less full than average, however it checks weight other than
free space, while "weight = free space - penalty", if MDTs have
different penalties, the result is not accurate, therefore this may
not work.

Check free space instead, and loosen the critirion to allow the
free space within the range of QOS threshold.

Fixes: 6a7e36a787eb ("lustre: lmv: qos stay on current MDT if less full")
WC-bug-id: https://jira.whamcloud.com/browse/LU-14762
Lustre-commit: 002c2a80266b23c1 ("LU-14762 lmv: compare space to mkdir on parent MDT")
Signed-off-by: Lai Siyao <lai.siyao@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/43997
Reviewed-by: Hongchao Zhang <hongchao@whamcloud.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lu_object.h     |  3 ++-
 fs/lustre/lmv/lmv_obd.c           | 17 ++++++++++-------
 fs/lustre/obdclass/lu_tgt_descs.c | 11 ++++++-----
 3 files changed, 18 insertions(+), 13 deletions(-)

diff --git a/fs/lustre/include/lu_object.h b/fs/lustre/include/lu_object.h
index bbc4533..84e0489 100644
--- a/fs/lustre/include/lu_object.h
+++ b/fs/lustre/include/lu_object.h
@@ -1434,7 +1434,7 @@ struct lu_svr_qos {
 	struct obd_uuid		 lsq_uuid;	/* ptlrpc's c_remote_uuid */
 	struct list_head	 lsq_svr_list;	/* link to lq_svr_list */
 	u64			 lsq_bavail;	/* total bytes avail on svr */
-	u64			 lsq_iavail;	/* tital inode avail on svr */
+	u64			 lsq_iavail;	/* total inode avail on svr */
 	u64			 lsq_penalty;	/* current penalty */
 	u64			 lsq_penalty_per_obj; /* penalty decrease
 						       * every obj
@@ -1451,6 +1451,7 @@ struct lu_tgt_qos {
 	u64			 ltq_penalty_per_obj; /* penalty decrease
 						       * every obj
 						       */
+	u64			 ltq_avail;	/* bytes/inode avail */
 	u64			 ltq_weight;	/* net weighting */
 	time64_t		 ltq_used;	/* last used time, seconds */
 	bool			 ltq_usable:1;	/* usable for striping */
diff --git a/fs/lustre/lmv/lmv_obd.c b/fs/lustre/lmv/lmv_obd.c
index ac88d20..2f84028 100644
--- a/fs/lustre/lmv/lmv_obd.c
+++ b/fs/lustre/lmv/lmv_obd.c
@@ -1430,6 +1430,7 @@ static int lmv_close(struct obd_export *exp, struct md_op_data *op_data,
 static struct lu_tgt_desc *lmv_locate_tgt_qos(struct lmv_obd *lmv, u32 *mdt)
 {
 	struct lu_tgt_desc *tgt, *cur = NULL;
+	u64 total_avail = 0;
 	u64 total_weight = 0;
 	u64 cur_weight = 0;
 	int total_usable = 0;
@@ -1460,23 +1461,25 @@ static struct lu_tgt_desc *lmv_locate_tgt_qos(struct lmv_obd *lmv, u32 *mdt)
 
 		tgt->ltd_qos.ltq_usable = 1;
 		lu_tgt_qos_weight_calc(tgt);
-		if (tgt->ltd_index == *mdt) {
+		if (tgt->ltd_index == *mdt)
 			cur = tgt;
-			cur_weight = tgt->ltd_qos.ltq_weight;
-		}
+		total_avail += tgt->ltd_qos.ltq_avail;
 		total_weight += tgt->ltd_qos.ltq_weight;
 		total_usable++;
 	}
 
-	/* if current MDT has higher-than-average space, stay on same MDT */
-	rand = total_weight / total_usable;
-	if (cur_weight >= rand) {
+	/* if current MDT has above-average space, within range of the QOS
+	 * threshold, stay on the same MDT to avoid creating needless remote
+	 * MDT directories.
+	 */
+	rand = total_avail * (256 - lmv->lmv_qos.lq_threshold_rr) /
+	       (total_usable * 256);
+	if (cur && cur->ltd_qos.ltq_avail >= rand) {
 		tgt = cur;
 		rc = 0;
 		goto unlock;
 	}
 
-	cur_weight = 0;
 	rand = lu_prandom_u64_max(total_weight);
 
 	lmv_foreach_connected_tgt(lmv, tgt) {
diff --git a/fs/lustre/obdclass/lu_tgt_descs.c b/fs/lustre/obdclass/lu_tgt_descs.c
index 2a2b30a..935cff6 100644
--- a/fs/lustre/obdclass/lu_tgt_descs.c
+++ b/fs/lustre/obdclass/lu_tgt_descs.c
@@ -220,14 +220,15 @@ static inline u64 tgt_statfs_iavail(struct lu_tgt_desc *tgt)
 void lu_tgt_qos_weight_calc(struct lu_tgt_desc *tgt)
 {
 	struct lu_tgt_qos *ltq = &tgt->ltd_qos;
-	u64 temp, temp2;
+	u64 penalty;
 
-	temp = (tgt_statfs_bavail(tgt) >> 16) * (tgt_statfs_iavail(tgt) >> 8);
-	temp2 = ltq->ltq_penalty + ltq->ltq_svr->lsq_penalty;
-	if (temp < temp2)
+	ltq->ltq_avail = (tgt_statfs_bavail(tgt) >> 16) *
+			 (tgt_statfs_iavail(tgt) >> 8);
+	penalty = ltq->ltq_penalty + ltq->ltq_svr->lsq_penalty;
+	if (ltq->ltq_avail < penalty)
 		ltq->ltq_weight = 0;
 	else
-		ltq->ltq_weight = temp - temp2;
+		ltq->ltq_weight = ltq->ltq_avail - penalty;
 }
 EXPORT_SYMBOL(lu_tgt_qos_weight_calc);
 
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
