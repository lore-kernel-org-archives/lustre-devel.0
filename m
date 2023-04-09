Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id B2EC6C77B61
	for <lustre-devel@archiver.kernel.org>; Sun,  9 Apr 2023 12:35:03 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4PvWP30GBSz1yDy;
	Sun,  9 Apr 2023 05:19:03 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4PvWJf5JlDz215y
 for <lustre-devel@lists.lustre.org>; Sun,  9 Apr 2023 05:15:14 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 15CAC1008480;
 Sun,  9 Apr 2023 08:13:28 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 149372B2; Sun,  9 Apr 2023 08:13:28 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun,  9 Apr 2023 08:12:58 -0400
Message-Id: <1681042400-15491-19-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1681042400-15491-1-git-send-email-jsimmons@infradead.org>
References: <1681042400-15491-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 18/40] lustre: tgt: skip free inodes in OST
 weights
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
Cc: Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Andreas Dilger <adilger@whamcloud.com>

In lu_tgt_qos_weight_calc() calculate the target weight consistently
with how the per-OST and per-OSS penalty calculation is done in
ltd_qos_penalties_calc().  Otherwise, the QOS weighting calculations
combine two different units, which incorrectly weighs allocations on
OST with more free inodes over those with more free space.

Fixes: 1fa303725063 ("lustre: lmv: share object alloc QoS code with LMV")
WC-bug-id: https://jira.whamcloud.com/browse/LU-16501
Lustre-commit: 511bf2f4ccd1482d6 ("LU-16501 tgt: skip free inodes in OST weights")
Signed-off-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/49890
Reviewed-by: Artem Blagodarenko <ablagodarenko@ddn.com>
Reviewed-by: Lai Siyao <lai.siyao@whamcloud.com>
Reviewed-by: Sergey Cheremencev <scherementsev@ddn.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lu_object.h     | 14 ++++++++++++-
 fs/lustre/lmv/lmv_obd.c           |  4 ++--
 fs/lustre/obdclass/lu_tgt_descs.c | 41 ++++++++++++++++-----------------------
 3 files changed, 32 insertions(+), 27 deletions(-)

diff --git a/fs/lustre/include/lu_object.h b/fs/lustre/include/lu_object.h
index 4e101fa..0562f806 100644
--- a/fs/lustre/include/lu_object.h
+++ b/fs/lustre/include/lu_object.h
@@ -1539,6 +1539,18 @@ struct lu_tgt_desc {
 			ltd_connecting:1;  /* target is connecting */
 };
 
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
 /* number of pointers at 2nd level */
 #define TGT_PTRS_PER_BLOCK	(PAGE_SIZE / sizeof(void *))
 /* number of pointers at 1st level - only need as many as max OST/MDT count */
@@ -1593,7 +1605,7 @@ struct lu_tgt_descs {
 u64 lu_prandom_u64_max(u64 ep_ro);
 int lu_qos_add_tgt(struct lu_qos *qos, struct lu_tgt_desc *ltd);
 int lu_qos_del_tgt(struct lu_qos *qos, struct lu_tgt_desc *ltd);
-void lu_tgt_qos_weight_calc(struct lu_tgt_desc *tgt);
+void lu_tgt_qos_weight_calc(struct lu_tgt_desc *tgt, bool is_mdt);
 
 int lu_tgt_descs_init(struct lu_tgt_descs *ltd, bool is_mdt);
 void lu_tgt_descs_fini(struct lu_tgt_descs *ltd);
diff --git a/fs/lustre/lmv/lmv_obd.c b/fs/lustre/lmv/lmv_obd.c
index 99604e8..1b6e4aa 100644
--- a/fs/lustre/lmv/lmv_obd.c
+++ b/fs/lustre/lmv/lmv_obd.c
@@ -1512,7 +1512,7 @@ static struct lu_tgt_desc *lmv_locate_tgt_qos(struct lmv_obd *lmv,
 		}
 
 		tgt->ltd_qos.ltq_usable = 1;
-		lu_tgt_qos_weight_calc(tgt);
+		lu_tgt_qos_weight_calc(tgt, true);
 		if (tgt->ltd_index == op_data->op_mds)
 			cur = tgt;
 		total_avail += tgt->ltd_qos.ltq_avail;
@@ -1613,7 +1613,7 @@ static struct lu_tgt_desc *lmv_locate_tgt_lf(struct lmv_obd *lmv)
 		}
 
 		tgt->ltd_qos.ltq_usable = 1;
-		lu_tgt_qos_weight_calc(tgt);
+		lu_tgt_qos_weight_calc(tgt, true);
 		avail += tgt->ltd_qos.ltq_avail;
 		if (!min || min->ltd_qos.ltq_avail > tgt->ltd_qos.ltq_avail)
 			min = tgt;
diff --git a/fs/lustre/obdclass/lu_tgt_descs.c b/fs/lustre/obdclass/lu_tgt_descs.c
index 7394789..35e7c7c 100644
--- a/fs/lustre/obdclass/lu_tgt_descs.c
+++ b/fs/lustre/obdclass/lu_tgt_descs.c
@@ -198,33 +198,26 @@ int lu_qos_del_tgt(struct lu_qos *qos, struct lu_tgt_desc *ltd)
 }
 EXPORT_SYMBOL(lu_qos_del_tgt);
 
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
 /**
  * Calculate weight for a given tgt.
  *
- * The final tgt weight is bavail >> 16 * iavail >> 8 minus the tgt and server
- * penalties.  See ltd_qos_penalties_calc() for how penalties are calculated.
+ * The final tgt weight uses only free space for OSTs, but combines
+ * both free space and inodes for MDTs, minus tgt and server penalties.
+ * See ltd_qos_penalties_calc() for how penalties are calculated.
  *
  * @tgt		target descriptor
+ * @is_mdt	target table is for MDT selection (use inodes)
  */
-void lu_tgt_qos_weight_calc(struct lu_tgt_desc *tgt)
+void lu_tgt_qos_weight_calc(struct lu_tgt_desc *tgt, bool is_mdt)
 {
 	struct lu_tgt_qos *ltq = &tgt->ltd_qos;
 	u64 penalty;
 
-	ltq->ltq_avail = (tgt_statfs_bavail(tgt) >> 16) *
-			 (tgt_statfs_iavail(tgt) >> 8);
+	if (is_mdt)
+		ltq->ltq_avail = (tgt_statfs_bavail(tgt) >> 16) *
+				 (tgt_statfs_iavail(tgt) >> 8);
+	else
+		ltq->ltq_avail = tgt_statfs_bavail(tgt) >> 8;
 	penalty = ltq->ltq_penalty + ltq->ltq_svr->lsq_penalty;
 	if (ltq->ltq_avail < penalty)
 		ltq->ltq_weight = 0;
@@ -512,11 +505,10 @@ int ltd_qos_penalties_calc(struct lu_tgt_descs *ltd)
 
 		/*
 		 * per-tgt penalty is
-		 * prio * bavail * iavail / (num_tgt - 1) / 2
+		 * prio * bavail * iavail / (num_tgt - 1) / prio_max / 2
 		 */
-		tgt->ltd_qos.ltq_penalty_per_obj = prio_wide * ba * ia >> 8;
+		tgt->ltd_qos.ltq_penalty_per_obj = prio_wide * ba * ia >> 9;
 		do_div(tgt->ltd_qos.ltq_penalty_per_obj, num_active);
-		tgt->ltd_qos.ltq_penalty_per_obj >>= 1;
 
 		age = (now - tgt->ltd_qos.ltq_used) >> 3;
 		if (test_bit(LQ_RESET, &qos->lq_flags) ||
@@ -563,14 +555,11 @@ int ltd_qos_penalties_calc(struct lu_tgt_descs *ltd)
 			svr->lsq_penalty >>= age / desc->ld_qos_maxage;
 	}
 
-	clear_bit(LQ_DIRTY, &qos->lq_flags);
-	clear_bit(LQ_RESET, &qos->lq_flags);
 
 	/*
 	 * If each tgt has almost same free space, do rr allocation for better
 	 * creation performance
 	 */
-	clear_bit(LQ_SAME_SPACE, &qos->lq_flags);
 	if (((ba_max * (QOS_THRESHOLD_MAX - qos->lq_threshold_rr)) /
 	    QOS_THRESHOLD_MAX) < ba_min &&
 	    ((ia_max * (QOS_THRESHOLD_MAX - qos->lq_threshold_rr)) /
@@ -578,7 +567,11 @@ int ltd_qos_penalties_calc(struct lu_tgt_descs *ltd)
 		set_bit(LQ_SAME_SPACE, &qos->lq_flags);
 		/* Reset weights for the next time we enter qos mode */
 		set_bit(LQ_RESET, &qos->lq_flags);
+	} else {
+		clear_bit(LQ_SAME_SPACE, &qos->lq_flags);
+		clear_bit(LQ_RESET, &qos->lq_flags);
 	}
+	clear_bit(LQ_DIRTY, &qos->lq_flags);
 	rc = 0;
 
 out:
@@ -653,7 +646,7 @@ int ltd_qos_update(struct lu_tgt_descs *ltd, struct lu_tgt_desc *tgt,
 		else
 			ltq->ltq_penalty -= ltq->ltq_penalty_per_obj;
 
-		lu_tgt_qos_weight_calc(tgt);
+		lu_tgt_qos_weight_calc(tgt, ltd->ltd_is_mdt);
 
 		/* Recalc the total weight of usable osts */
 		if (ltq->ltq_usable)
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
