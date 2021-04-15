Return-Path: <SRS0=FD7t=JM=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 59D8AC433ED
	for <lustre-devel@archiver.kernel.org>; Thu, 15 Apr 2021 04:03:44 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 14105610CB
	for <lustre-devel@archiver.kernel.org>; Thu, 15 Apr 2021 04:03:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 14105610CB
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id B6F0732F76D;
	Wed, 14 Apr 2021 21:03:21 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 14D2132F64F
 for <lustre-devel@lists.lustre.org>; Wed, 14 Apr 2021 21:02:56 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id A3C74100F361;
 Thu, 15 Apr 2021 00:02:45 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id A2C1691883; Thu, 15 Apr 2021 00:02:45 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Thu, 15 Apr 2021 00:02:24 -0400
Message-Id: <1618459361-17909-33-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1618459361-17909-1-git-send-email-jsimmons@infradead.org>
References: <1618459361-17909-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 32/49] lustre: quota: make used for pool
 correct
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
Cc: Sergey Cheremencev <sergey.cheremencev@hpe.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Sergey Cheremencev <sergey.cheremencev@hpe.com>

Before this patch used space for quota pool
was a sum of a space used by user at all OSTs
in a system. Now it is fixed and lfs quota --pool
takes into account only OSTs form the pool.
With option -v it also shows only OSTs from the pool.

WC-bug-id: https://jira.whamcloud.com/browse/LU-13359
Lustre-commit: 6b9f849fd5f49ce6 ("LU-13359 quota: make used for pool correct")
Signed-off-by: Sergey Cheremencev <sergey.cheremencev@hpe.com>
Reviewed-on: https://review.whamcloud.com/39298
Reviewed-by: Petros Koutoupis <petros.koutoupis@hpe.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/dir.c        | 13 +++++++++++--
 fs/lustre/lov/lov_internal.h |  3 +++
 fs/lustre/lov/lov_obd.c      | 37 ++++++++++++++++++++++++++++++++-----
 fs/lustre/lov/lov_pool.c     |  2 +-
 4 files changed, 47 insertions(+), 8 deletions(-)

diff --git a/fs/lustre/llite/dir.c b/fs/lustre/llite/dir.c
index c42cff7..5dc93f4 100644
--- a/fs/lustre/llite/dir.c
+++ b/fs/lustre/llite/dir.c
@@ -1169,14 +1169,22 @@ int quotactl_ioctl(struct ll_sb_info *sbi, struct if_quotactl *qctl)
 		    !(oqctl->qc_dqblk.dqb_valid & QIF_SPACE) &&
 		    !oqctl->qc_dqblk.dqb_curspace) {
 			struct obd_quotactl *oqctl_tmp;
+			int qctl_len = sizeof(*oqctl_tmp) + LOV_MAXPOOLNAME + 1;
 
-			oqctl_tmp = kzalloc(sizeof(*oqctl_tmp), GFP_NOFS);
+			oqctl_tmp = kzalloc(qctl_len, GFP_NOFS);
 			if (!oqctl_tmp) {
 				rc = -ENOMEM;
 				goto out;
 			}
 
-			oqctl_tmp->qc_cmd = Q_GETOQUOTA;
+			if (cmd == LUSTRE_Q_GETQUOTAPOOL) {
+				oqctl_tmp->qc_cmd = LUSTRE_Q_GETQUOTAPOOL;
+				memcpy(oqctl_tmp->qc_poolname,
+				       qctl->qc_poolname,
+				       LOV_MAXPOOLNAME + 1);
+			} else {
+				oqctl_tmp->qc_cmd = Q_GETOQUOTA;
+			}
 			oqctl_tmp->qc_id = oqctl->qc_id;
 			oqctl_tmp->qc_type = oqctl->qc_type;
 
@@ -1190,6 +1198,7 @@ int quotactl_ioctl(struct ll_sb_info *sbi, struct if_quotactl *qctl)
 			}
 
 			/* collect space & inode usage from MDTs */
+			oqctl_tmp->qc_cmd = Q_GETOQUOTA;
 			oqctl_tmp->qc_dqblk.dqb_curspace = 0;
 			oqctl_tmp->qc_dqblk.dqb_curinodes = 0;
 			rc = obd_quotactl(sbi->ll_md_exp, oqctl_tmp);
diff --git a/fs/lustre/lov/lov_internal.h b/fs/lustre/lov/lov_internal.h
index 2e1e2dd..d26e68b 100644
--- a/fs/lustre/lov/lov_internal.h
+++ b/fs/lustre/lov/lov_internal.h
@@ -379,4 +379,7 @@ static inline void lov_lsm2layout(struct lov_stripe_md *lsm,
 		ol->ol_comp_id = 0;
 	}
 }
+
+extern const struct rhashtable_params pools_hash_params;
+extern void lov_pool_putref(struct pool_desc *pool);
 #endif
diff --git a/fs/lustre/lov/lov_obd.c b/fs/lustre/lov/lov_obd.c
index 4f574ad..95fcd57 100644
--- a/fs/lustre/lov/lov_obd.c
+++ b/fs/lustre/lov/lov_obd.c
@@ -1220,14 +1220,34 @@ static int lov_quotactl(struct obd_device *obd, struct obd_export *exp,
 {
 	struct lov_obd *lov = &obd->u.lov;
 	struct lov_tgt_desc *tgt;
+	struct pool_desc *pool = NULL;
 	u64 curspace = 0;
 	u64 bhardlimit = 0;
 	int i, rc = 0;
 
 	if (oqctl->qc_cmd != Q_GETOQUOTA &&
-	    oqctl->qc_cmd != LUSTRE_Q_SETQUOTA) {
-		CERROR("bad quota opc %x for lov obd\n", oqctl->qc_cmd);
-		return -EFAULT;
+	    oqctl->qc_cmd != LUSTRE_Q_SETQUOTA &&
+	    oqctl->qc_cmd != LUSTRE_Q_GETQUOTAPOOL) {
+		rc = -EFAULT;
+		CERROR("%s: bad quota opc %x for lov obd: rc = %d\n",
+		       obd->obd_name, oqctl->qc_cmd, rc);
+		return rc;
+	}
+
+	if (oqctl->qc_cmd == LUSTRE_Q_GETQUOTAPOOL) {
+		rcu_read_lock();
+		pool = rhashtable_lookup(&lov->lov_pools_hash_body,
+					 oqctl->qc_poolname,
+					 pools_hash_params);
+		if (pool && !atomic_inc_not_zero(&pool->pool_refcount))
+			pool = NULL;
+		rcu_read_unlock();
+		if (!pool)
+			return -ENOENT;
+		/* Set Q_GETOQUOTA back as targets report it's own
+		 * usage and doesn't care about pools
+		 */
+		oqctl->qc_cmd = Q_GETOQUOTA;
 	}
 
 	/* for lov tgt */
@@ -1240,11 +1260,16 @@ static int lov_quotactl(struct obd_device *obd, struct obd_export *exp,
 		if (!tgt)
 			continue;
 
+		if (pool &&
+		    tgt_check_index(tgt->ltd_index, &pool->pool_obds))
+			continue;
+
 		if (!tgt->ltd_active || tgt->ltd_reap) {
 			if (oqctl->qc_cmd == Q_GETOQUOTA &&
 			    lov->lov_tgts[i]->ltd_activate) {
-				rc = -EREMOTEIO;
-				CERROR("ost %d is inactive\n", i);
+				rc = -ENETDOWN;
+				CERROR("%s: ost %d is inactive: rc = %d\n",
+				       obd->obd_name, i, rc);
 			} else {
 				CDEBUG(D_HA, "ost %d is inactive\n", i);
 			}
@@ -1264,6 +1289,8 @@ static int lov_quotactl(struct obd_device *obd, struct obd_export *exp,
 		}
 	}
 	lov_tgts_putref(obd);
+	if (pool)
+		lov_pool_putref(pool);
 
 	if (oqctl->qc_cmd == Q_GETOQUOTA) {
 		oqctl->qc_dqblk.dqb_curspace = curspace;
diff --git a/fs/lustre/lov/lov_pool.c b/fs/lustre/lov/lov_pool.c
index 2617974..de8aed9 100644
--- a/fs/lustre/lov/lov_pool.c
+++ b/fs/lustre/lov/lov_pool.c
@@ -63,7 +63,7 @@ static int pool_cmpfn(struct rhashtable_compare_arg *arg, const void *obj)
 	return strcmp(pool_name, pool->pool_name);
 }
 
-static const struct rhashtable_params pools_hash_params = {
+const struct rhashtable_params pools_hash_params = {
 	.key_len	= 1, /* actually variable */
 	.key_offset	= offsetof(struct pool_desc, pool_name),
 	.head_offset	= offsetof(struct pool_desc, pool_hash),
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
