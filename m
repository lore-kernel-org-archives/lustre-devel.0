Return-Path: <SRS0=Gt0B=JW=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.7 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4B515C43460
	for <lustre-devel@archiver.kernel.org>; Sun, 25 Apr 2021 20:09:36 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 0F2216124B
	for <lustre-devel@archiver.kernel.org>; Sun, 25 Apr 2021 20:09:36 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0F2216124B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id EBD8C21F81B;
	Sun, 25 Apr 2021 13:09:14 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id B8F6121F513
 for <lustre-devel@lists.lustre.org>; Sun, 25 Apr 2021 13:08:45 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 26A9010087C9;
 Sun, 25 Apr 2021 16:08:40 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 25A4E69A63; Sun, 25 Apr 2021 16:08:40 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 25 Apr 2021 16:08:22 -0400
Message-Id: <1619381316-7719-16-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1619381316-7719-1-git-send-email-jsimmons@infradead.org>
References: <1619381316-7719-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 15/29] lustre: lmv: don't include struct
 lu_qos_rr in client
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
Cc: Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Mr NeilBrown <neilb@suse.de>

The 'lqrr' field in 'struct lu_qos' is not used on the client (lmv).
So make it server-only for use in lod. We can safely remove it from
the Linux client.

WC-bug-id: https://jira.whamcloud.com/browse/LU-8837
Lustre-commit: b6882c8ae4f47e93 ("LU-8837 lmv: don't include struct lu_qos_rr in client")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/41950
Reviewed-by: Lai Siyao <lai.siyao@whamcloud.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lu_object.h     | 22 +++++-----------------
 fs/lustre/obdclass/lu_tgt_descs.c | 11 -----------
 2 files changed, 5 insertions(+), 28 deletions(-)

diff --git a/fs/lustre/include/lu_object.h b/fs/lustre/include/lu_object.h
index 75bb6c3..0aa28c7 100644
--- a/fs/lustre/include/lu_object.h
+++ b/fs/lustre/include/lu_object.h
@@ -1413,16 +1413,6 @@ enum lq_flag {
 	LQ_RESET,		/* zero current penalties */
 };
 
-/* round-robin QoS data for LOD/LMV */
-struct lu_qos_rr {
-	spinlock_t		 lqr_alloc;	/* protect allocation index */
-	u32			 lqr_start_idx;	/* start index of new inode */
-	u32			 lqr_offset_idx;/* aliasing for start_idx */
-	int			 lqr_start_count;/* reseed counter */
-	struct lu_tgt_pool	 lqr_pool;	/* round-robin optimized list */
-	unsigned long		 lqr_flags;
-};
-
 /* QoS data per MDS/OSS */
 struct lu_svr_qos {
 	struct obd_uuid		 lsq_uuid;	/* ptlrpc's c_remote_uuid */
@@ -1484,12 +1474,11 @@ struct lu_tgt_desc_idx {
 
 /* QoS data for LOD/LMV */
 struct lu_qos {
-	struct list_head	 lq_svr_list;	 /* lu_svr_qos list */
-	struct rw_semaphore	 lq_rw_sem;
-	u32			 lq_active_svr_count;
-	unsigned int		 lq_prio_free;	 /* priority for free space */
-	unsigned int		 lq_threshold_rr;/* priority for rr */
-	struct lu_qos_rr	 lq_rr;		 /* round robin qos data */
+	struct list_head	lq_svr_list;	 /* lu_svr_qos list */
+	struct rw_semaphore	lq_rw_sem;
+	u32			lq_active_svr_count;
+	unsigned int		lq_prio_free;	 /* priority for free space */
+	unsigned int		lq_threshold_rr;/* priority for rr */
 	unsigned long		lq_flags;
 };
 
@@ -1525,7 +1514,6 @@ struct lu_tgt_descs {
 		ldi_tgt[(index) % TGT_PTRS_PER_BLOCK]
 
 u64 lu_prandom_u64_max(u64 ep_ro);
-void lu_qos_rr_init(struct lu_qos_rr *lqr);
 int lu_qos_add_tgt(struct lu_qos *qos, struct lu_tgt_desc *ltd);
 void lu_tgt_qos_weight_calc(struct lu_tgt_desc *tgt);
 
diff --git a/fs/lustre/obdclass/lu_tgt_descs.c b/fs/lustre/obdclass/lu_tgt_descs.c
index ef30ee3..cb62ce4 100644
--- a/fs/lustre/obdclass/lu_tgt_descs.c
+++ b/fs/lustre/obdclass/lu_tgt_descs.c
@@ -77,13 +77,6 @@ u64 lu_prandom_u64_max(u64 ep_ro)
 }
 EXPORT_SYMBOL(lu_prandom_u64_max);
 
-void lu_qos_rr_init(struct lu_qos_rr *lqr)
-{
-	spin_lock_init(&lqr->lqr_alloc);
-	set_bit(LQ_DIRTY, &lqr->lqr_flags);
-}
-EXPORT_SYMBOL(lu_qos_rr_init);
-
 /**
  * Add a new target to Quality of Service (QoS) target table.
  *
@@ -159,7 +152,6 @@ int lu_qos_add_tgt(struct lu_qos *qos, struct lu_tgt_desc *tgt)
 	list_add_tail(&svr->lsq_svr_list, &tempsvr->lsq_svr_list);
 
 	set_bit(LQ_DIRTY, &qos->lq_flags);
-	set_bit(LQ_DIRTY, &qos->lq_rr.lqr_flags);
 out:
 	up_write(&qos->lq_rw_sem);
 	return rc;
@@ -200,7 +192,6 @@ static int lu_qos_del_tgt(struct lu_qos *qos, struct lu_tgt_desc *ltd)
 	}
 
 	set_bit(LQ_DIRTY, &qos->lq_flags);
-	set_bit(LQ_DIRTY, &qos->lq_rr.lqr_flags);
 out:
 	up_write(&qos->lq_rw_sem);
 	return rc;
@@ -282,8 +273,6 @@ int lu_tgt_descs_init(struct lu_tgt_descs *ltd, bool is_mdt)
 	if (is_mdt)
 		ltd->ltd_lmv_desc.ld_pattern = LMV_HASH_TYPE_DEFAULT;
 
-	lu_qos_rr_init(&ltd->ltd_qos.lq_rr);
-
 	return 0;
 }
 EXPORT_SYMBOL(lu_tgt_descs_init);
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
