Return-Path: <SRS0=FD7t=JM=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A986BC433ED
	for <lustre-devel@archiver.kernel.org>; Thu, 15 Apr 2021 04:03:51 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 550F1610CB
	for <lustre-devel@archiver.kernel.org>; Thu, 15 Apr 2021 04:03:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 550F1610CB
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id A9085247A5E;
	Wed, 14 Apr 2021 21:03:25 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 60DEE32F65E
 for <lustre-devel@lists.lustre.org>; Wed, 14 Apr 2021 21:02:56 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id A6ED0100F362;
 Thu, 15 Apr 2021 00:02:45 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id A5C3F9188E; Thu, 15 Apr 2021 00:02:45 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Thu, 15 Apr 2021 00:02:25 -0400
Message-Id: <1618459361-17909-34-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1618459361-17909-1-git-send-email-jsimmons@infradead.org>
References: <1618459361-17909-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 33/49] lustre: quota: call rhashtable_lookup
 near params decl
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

rhashtable_lookup() is an inline function which depends - for
performancs - on the 'rhashtable_params' being visible and
consnt.  So it should only be called in the same file that
declared the params.

recent patch make pools_hash_params an external variable and calls
rhashtable_lookup from a separate file, which will break the
optimisation.

So add lov_pool_find() and use it to maintainer optimization.

WC-bug-id: https://jira.whamcloud.com/browse/LU-13359
Fixes: 226a0a32c6b3 ("lustre: quota: make used for pool correct")
Lustre-commit: 1d116c8ff68fc784 ("LU-13359 quota: call rhashtable_lookup near params decl")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/39676
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Sergey Cheremencev <sergey.cheremencev@hpe.com>
Reviewed-by: Petros Koutoupis <petros.koutoupis@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/lov/lov_internal.h |  4 ++--
 fs/lustre/lov/lov_obd.c      |  8 +-------
 fs/lustre/lov/lov_pool.c     | 18 +++++++++++++++++-
 3 files changed, 20 insertions(+), 10 deletions(-)

diff --git a/fs/lustre/lov/lov_internal.h b/fs/lustre/lov/lov_internal.h
index d26e68b..e58235a 100644
--- a/fs/lustre/lov/lov_internal.h
+++ b/fs/lustre/lov/lov_internal.h
@@ -380,6 +380,6 @@ static inline void lov_lsm2layout(struct lov_stripe_md *lsm,
 	}
 }
 
-extern const struct rhashtable_params pools_hash_params;
-extern void lov_pool_putref(struct pool_desc *pool);
+struct pool_desc *lov_pool_find(struct obd_device *obd, char *poolname);
+void lov_pool_putref(struct pool_desc *pool);
 #endif
diff --git a/fs/lustre/lov/lov_obd.c b/fs/lustre/lov/lov_obd.c
index 95fcd57..29b0645 100644
--- a/fs/lustre/lov/lov_obd.c
+++ b/fs/lustre/lov/lov_obd.c
@@ -1235,13 +1235,7 @@ static int lov_quotactl(struct obd_device *obd, struct obd_export *exp,
 	}
 
 	if (oqctl->qc_cmd == LUSTRE_Q_GETQUOTAPOOL) {
-		rcu_read_lock();
-		pool = rhashtable_lookup(&lov->lov_pools_hash_body,
-					 oqctl->qc_poolname,
-					 pools_hash_params);
-		if (pool && !atomic_inc_not_zero(&pool->pool_refcount))
-			pool = NULL;
-		rcu_read_unlock();
+		pool = lov_pool_find(obd, oqctl->qc_poolname);
 		if (!pool)
 			return -ENOENT;
 		/* Set Q_GETOQUOTA back as targets report it's own
diff --git a/fs/lustre/lov/lov_pool.c b/fs/lustre/lov/lov_pool.c
index de8aed9..8fbc6ee 100644
--- a/fs/lustre/lov/lov_pool.c
+++ b/fs/lustre/lov/lov_pool.c
@@ -63,7 +63,7 @@ static int pool_cmpfn(struct rhashtable_compare_arg *arg, const void *obj)
 	return strcmp(pool_name, pool->pool_name);
 }
 
-const struct rhashtable_params pools_hash_params = {
+static const struct rhashtable_params pools_hash_params = {
 	.key_len	= 1, /* actually variable */
 	.key_offset	= offsetof(struct pool_desc, pool_name),
 	.head_offset	= offsetof(struct pool_desc, pool_hash),
@@ -317,6 +317,22 @@ int lov_pool_new(struct obd_device *obd, char *poolname)
 	return rc;
 }
 
+struct pool_desc *lov_pool_find(struct obd_device *obd, char *poolname)
+{
+	struct pool_desc *pool;
+	struct lov_obd *lov = &obd->u.lov;
+
+	rcu_read_lock();
+	pool = rhashtable_lookup(&lov->lov_pools_hash_body,
+				 poolname,
+				 pools_hash_params);
+	if (pool && !atomic_inc_not_zero(&pool->pool_refcount))
+		pool = NULL;
+	rcu_read_unlock();
+
+	return pool;
+}
+
 int lov_pool_del(struct obd_device *obd, char *poolname)
 {
 	struct lov_obd *lov;
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
