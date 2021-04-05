Return-Path: <SRS0=o51I=JC=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.7 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 21DEAC433ED
	for <lustre-devel@archiver.kernel.org>; Mon,  5 Apr 2021 00:52:56 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id CB1A46138E
	for <lustre-devel@archiver.kernel.org>; Mon,  5 Apr 2021 00:52:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CB1A46138E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 444F0328E03;
	Mon,  5 Apr 2021 00:52:24 +0000 (UTC)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id EBC8A21FB29
 for <lustre-devel@lists.lustre.org>; Mon,  5 Apr 2021 00:51:24 +0000 (UTC)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id E7BE0A1C;
 Sun,  4 Apr 2021 20:51:16 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id E631F90AA8; Sun,  4 Apr 2021 20:51:16 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun,  4 Apr 2021 20:50:54 -0400
Message-Id: <1617583870-32029-26-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1617583870-32029-1-git-send-email-jsimmons@infradead.org>
References: <1617583870-32029-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 25/41] lustre: lov: fixes bitfield in lod qos
 code
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
Cc: Alexander Zarochentsev <c17826@cray.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Rahul Deshmkuh <rahul.deshmukh@seagate.com>

Updating bitfields in struct lod_qos struct is protected
by lq_rw_sem in most places but an update can be lost
due unprotected bitfield access from
lod_qos_thresholdrr_seq_write() and qos_prio_free_store().
This patch fixes it by replacing bitfields with named bits
and atomic bitops.

Cray-bug-id: LUS-4651
WC-bug-id: https://jira.whamcloud.com/browse/LU-7853
Lustre-commit: 3bae39f0a5b98a2 ("LU-7853 lod: fixes bitfield in lod qos code")
Signed-off-by: Rahul Deshmukh <rahul.deshmukh@seagate.com>
Signed-off-by: Alexander Zarochentsev <c17826@cray.com>
Reviewed-on: https://review.whamcloud.com/18812
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Alexander Zarochentsev <alexander.zarochentsev@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lu_object.h     | 17 +++++++++++------
 fs/lustre/lmv/lmv_obd.c           |  2 +-
 fs/lustre/lmv/lproc_lmv.c         |  6 +++---
 fs/lustre/obdclass/lu_tgt_descs.c | 38 ++++++++++++++++++++------------------
 4 files changed, 35 insertions(+), 28 deletions(-)

diff --git a/fs/lustre/include/lu_object.h b/fs/lustre/include/lu_object.h
index 6c47f43..34610d4 100644
--- a/fs/lustre/include/lu_object.h
+++ b/fs/lustre/include/lu_object.h
@@ -1405,6 +1405,15 @@ struct lu_kmem_descr {
 extern u32 lu_context_tags_default;
 extern u32 lu_session_tags_default;
 
+/* bitflags used in rr / qos allocation */
+enum lq_flag {
+	LQ_DIRTY	= 0,	/* recalc qos data */
+	LQ_SAME_SPACE,		/* the OSTs all have approx.
+				 * the same space avail
+				 */
+	LQ_RESET,		/* zero current penalties */
+};
+
 /* round-robin QoS data for LOD/LMV */
 struct lu_qos_rr {
 	spinlock_t		 lqr_alloc;	/* protect allocation index */
@@ -1412,7 +1421,7 @@ struct lu_qos_rr {
 	u32			 lqr_offset_idx;/* aliasing for start_idx */
 	int			 lqr_start_count;/* reseed counter */
 	struct lu_tgt_pool	 lqr_pool;	/* round-robin optimized list */
-	unsigned long		 lqr_dirty:1;	/* recalc round-robin list */
+	unsigned long		 lqr_flags;
 };
 
 /* QoS data per MDS/OSS */
@@ -1482,11 +1491,7 @@ struct lu_qos {
 	unsigned int		 lq_prio_free;	 /* priority for free space */
 	unsigned int		 lq_threshold_rr;/* priority for rr */
 	struct lu_qos_rr	 lq_rr;		 /* round robin qos data */
-	unsigned long		 lq_dirty:1,	 /* recalc qos data */
-				 lq_same_space:1,/* the servers all have approx.
-						  * the same space avail
-						  */
-				 lq_reset:1;	 /* zero current penalties */
+	unsigned long		lq_flags;
 };
 
 struct lu_tgt_descs {
diff --git a/fs/lustre/lmv/lmv_obd.c b/fs/lustre/lmv/lmv_obd.c
index d845118..747786e 100644
--- a/fs/lustre/lmv/lmv_obd.c
+++ b/fs/lustre/lmv/lmv_obd.c
@@ -1303,7 +1303,7 @@ static int lmv_statfs_update(void *cookie, int rc)
 		tgt->ltd_statfs = *osfs;
 		tgt->ltd_statfs_age = ktime_get_seconds();
 		spin_unlock(&lmv->lmv_lock);
-		lmv->lmv_qos.lq_dirty = 1;
+		set_bit(LQ_DIRTY, &lmv->lmv_qos.lq_flags);
 	}
 
 	return rc;
diff --git a/fs/lustre/lmv/lproc_lmv.c b/fs/lustre/lmv/lproc_lmv.c
index 59922b8..85963d2 100644
--- a/fs/lustre/lmv/lproc_lmv.c
+++ b/fs/lustre/lmv/lproc_lmv.c
@@ -133,8 +133,8 @@ static ssize_t qos_prio_free_store(struct kobject *kobj,
 		return -EINVAL;
 
 	lmv->lmv_qos.lq_prio_free = (val << 8) / 100;
-	lmv->lmv_qos.lq_dirty = 1;
-	lmv->lmv_qos.lq_reset = 1;
+	set_bit(LQ_DIRTY, &lmv->lmv_qos.lq_flags);
+	set_bit(LQ_RESET, &lmv->lmv_qos.lq_flags);
 
 	return count;
 }
@@ -170,7 +170,7 @@ static ssize_t qos_threshold_rr_store(struct kobject *kobj,
 		return -EINVAL;
 
 	lmv->lmv_qos.lq_threshold_rr = (val << 8) / 100;
-	lmv->lmv_qos.lq_dirty = 1;
+	set_bit(LQ_DIRTY, &lmv->lmv_qos.lq_flags);
 
 	return count;
 }
diff --git a/fs/lustre/obdclass/lu_tgt_descs.c b/fs/lustre/obdclass/lu_tgt_descs.c
index 469c935..a77ce20 100644
--- a/fs/lustre/obdclass/lu_tgt_descs.c
+++ b/fs/lustre/obdclass/lu_tgt_descs.c
@@ -80,7 +80,7 @@ u64 lu_prandom_u64_max(u64 ep_ro)
 void lu_qos_rr_init(struct lu_qos_rr *lqr)
 {
 	spin_lock_init(&lqr->lqr_alloc);
-	lqr->lqr_dirty = 1;
+	set_bit(LQ_DIRTY, &lqr->lqr_flags);
 }
 EXPORT_SYMBOL(lu_qos_rr_init);
 
@@ -158,9 +158,8 @@ int lu_qos_add_tgt(struct lu_qos *qos, struct lu_tgt_desc *tgt)
 	 */
 	list_add_tail(&svr->lsq_svr_list, &tempsvr->lsq_svr_list);
 
-	qos->lq_dirty = 1;
-	qos->lq_rr.lqr_dirty = 1;
-
+	set_bit(LQ_DIRTY, &qos->lq_flags);
+	set_bit(LQ_DIRTY, &qos->lq_rr.lqr_flags);
 out:
 	up_write(&qos->lq_rw_sem);
 	return rc;
@@ -200,8 +199,8 @@ static int lu_qos_del_tgt(struct lu_qos *qos, struct lu_tgt_desc *ltd)
 		kfree(svr);
 	}
 
-	qos->lq_dirty = 1;
-	qos->lq_rr.lqr_dirty = 1;
+	set_bit(LQ_DIRTY, &qos->lq_flags);
+	set_bit(LQ_DIRTY, &qos->lq_rr.lqr_flags);
 out:
 	up_write(&qos->lq_rw_sem);
 	return rc;
@@ -273,8 +272,8 @@ int lu_tgt_descs_init(struct lu_tgt_descs *ltd, bool is_mdt)
 	/* Set up allocation policy (QoS and RR) */
 	INIT_LIST_HEAD(&ltd->ltd_qos.lq_svr_list);
 	init_rwsem(&ltd->ltd_qos.lq_rw_sem);
-	ltd->ltd_qos.lq_dirty = 1;
-	ltd->ltd_qos.lq_reset = 1;
+	set_bit(LQ_DIRTY, &ltd->ltd_qos.lq_flags);
+	set_bit(LQ_RESET, &ltd->ltd_qos.lq_flags);
 	/* Default priority is toward free space balance */
 	ltd->ltd_qos.lq_prio_free = 232;
 	/* Default threshold for rr (roughly 17%) */
@@ -416,7 +415,8 @@ void ltd_del_tgt(struct lu_tgt_descs *ltd, struct lu_tgt_desc *tgt)
  */
 bool ltd_qos_is_usable(struct lu_tgt_descs *ltd)
 {
-	if (!ltd->ltd_qos.lq_dirty && ltd->ltd_qos.lq_same_space)
+	if (!test_bit(LQ_DIRTY, &ltd->ltd_qos.lq_flags) &&
+	    test_bit(LQ_SAME_SPACE, &ltd->ltd_qos.lq_flags))
 		return false;
 
 	if (ltd->ltd_lov_desc.ld_active_tgt_count < 2)
@@ -456,7 +456,7 @@ int ltd_qos_penalties_calc(struct lu_tgt_descs *ltd)
 	time64_t now, age;
 	int rc;
 
-	if (!qos->lq_dirty) {
+	if (!test_bit(LQ_DIRTY, &qos->lq_flags)) {
 		rc = 0;
 		goto out;
 	}
@@ -531,7 +531,8 @@ int ltd_qos_penalties_calc(struct lu_tgt_descs *ltd)
 		tgt->ltd_qos.ltq_penalty_per_obj >>= 1;
 
 		age = (now - tgt->ltd_qos.ltq_used) >> 3;
-		if (qos->lq_reset || age > 32 * desc->ld_qos_maxage)
+		if (test_bit(LQ_RESET, &qos->lq_flags) ||
+		    age > 32 * desc->ld_qos_maxage)
 			tgt->ltd_qos.ltq_penalty = 0;
 		else if (age > desc->ld_qos_maxage)
 			/* Decay tgt penalty. */
@@ -566,31 +567,32 @@ int ltd_qos_penalties_calc(struct lu_tgt_descs *ltd)
 		svr->lsq_penalty_per_obj >>= 1;
 
 		age = (now - svr->lsq_used) >> 3;
-		if (qos->lq_reset || age > 32 * desc->ld_qos_maxage)
+		if (test_bit(LQ_RESET, &qos->lq_flags) ||
+		    age > 32 * desc->ld_qos_maxage)
 			svr->lsq_penalty = 0;
 		else if (age > desc->ld_qos_maxage)
 			/* Decay server penalty. */
 			svr->lsq_penalty >>= age / desc->ld_qos_maxage;
 	}
 
-	qos->lq_dirty = 0;
-	qos->lq_reset = 0;
+	clear_bit(LQ_DIRTY, &qos->lq_flags);
+	clear_bit(LQ_RESET, &qos->lq_flags);
 
 	/*
 	 * If each tgt has almost same free space, do rr allocation for better
 	 * creation performance
 	 */
-	qos->lq_same_space = 0;
+	clear_bit(LQ_SAME_SPACE, &qos->lq_flags);
 	if ((ba_max * (256 - qos->lq_threshold_rr)) >> 8 < ba_min &&
 	    (ia_max * (256 - qos->lq_threshold_rr)) >> 8 < ia_min) {
-		qos->lq_same_space = 1;
+		set_bit(LQ_SAME_SPACE, &qos->lq_flags);
 		/* Reset weights for the next time we enter qos mode */
-		qos->lq_reset = 1;
+		set_bit(LQ_RESET, &qos->lq_flags);
 	}
 	rc = 0;
 
 out:
-	if (!rc && qos->lq_same_space)
+	if (!rc && test_bit(LQ_SAME_SPACE, &qos->lq_flags))
 		return -EAGAIN;
 
 	return rc;
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
