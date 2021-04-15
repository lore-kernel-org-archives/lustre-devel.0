Return-Path: <SRS0=FD7t=JM=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 542F0C433ED
	for <lustre-devel@archiver.kernel.org>; Thu, 15 Apr 2021 04:03:17 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 5724B60230
	for <lustre-devel@archiver.kernel.org>; Thu, 15 Apr 2021 04:03:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5724B60230
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 4FE4732F4D6;
	Wed, 14 Apr 2021 21:03:06 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 56B1C32F493
 for <lustre-devel@lists.lustre.org>; Wed, 14 Apr 2021 21:02:50 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 66EA1100F34D;
 Thu, 15 Apr 2021 00:02:45 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 643BE91890; Thu, 15 Apr 2021 00:02:45 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Thu, 15 Apr 2021 00:02:04 -0400
Message-Id: <1618459361-17909-13-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1618459361-17909-1-git-send-email-jsimmons@infradead.org>
References: <1618459361-17909-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 12/49] lustre: fixup ldlm_pool and lu_object
 shrinker failure cases
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

For ldlm_pools, ldlm_pools_fini() can be called when ldlm_pools_init()
fails, or even in case where it hasn't been called.  So add a static
flag to ensure we ldlm_pools_fini() does undo things that haven't been
done.

For lu_global_init() we need to add proper cleanup if anything fails.

Fixes: ab33cb5ad1e57 ("drivers: lustre: obdclass: check result of register_shrinker()")
WC-bug-id: https://jira.whamcloud.com/browse/LU-12477
Lustre-commit: 812b2ccf0284df42 ("LU-12477 lustre: check return status of register_shrinker()")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/40883
Reviewed-by: Yang Sheng <ys@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ldlm/ldlm_pool.c     | 43 +++++++++++++++++++-----------------------
 fs/lustre/obdclass/lu_object.c | 39 +++++++++++++++++++-------------------
 2 files changed, 38 insertions(+), 44 deletions(-)

diff --git a/fs/lustre/ldlm/ldlm_pool.c b/fs/lustre/ldlm/ldlm_pool.c
index 2e4d16b..b93ad4d 100644
--- a/fs/lustre/ldlm/ldlm_pool.c
+++ b/fs/lustre/ldlm/ldlm_pool.c
@@ -889,6 +889,12 @@ static unsigned long ldlm_pools_cli_scan(struct shrinker *s,
 			       sc->gfp_mask);
 }
 
+static struct shrinker ldlm_pools_cli_shrinker = {
+	.count_objects	= ldlm_pools_cli_count,
+	.scan_objects	= ldlm_pools_cli_scan,
+	.seeks		= DEFAULT_SEEKS,
+};
+
 static void ldlm_pools_recalc(struct work_struct *ws);
 static DECLARE_DELAYED_WORK(ldlm_recalc_pools, ldlm_pools_recalc);
 
@@ -976,40 +982,29 @@ static void ldlm_pools_recalc(struct work_struct *ws)
 	schedule_delayed_work(&ldlm_recalc_pools, delay * HZ);
 }
 
-static int ldlm_pools_thread_start(void)
-{
-	time64_t delay = LDLM_POOL_CLI_DEF_RECALC_PERIOD;
-
-	schedule_delayed_work(&ldlm_recalc_pools, delay);
-
-	return 0;
-}
-
-static void ldlm_pools_thread_stop(void)
-{
-	cancel_delayed_work_sync(&ldlm_recalc_pools);
-}
-
-static struct shrinker ldlm_pools_cli_shrinker = {
-	.count_objects	= ldlm_pools_cli_count,
-	.scan_objects	= ldlm_pools_cli_scan,
-	.seeks		= DEFAULT_SEEKS,
-};
+static bool ldlm_pools_init_done;
 
 int ldlm_pools_init(void)
 {
+	time64_t delay = LDLM_POOL_CLI_DEF_RECALC_PERIOD;
 	int rc;
 
-	rc = ldlm_pools_thread_start();
-	if (!rc)
-		rc = register_shrinker(&ldlm_pools_cli_shrinker);
+	rc = register_shrinker(&ldlm_pools_cli_shrinker);
+	if (rc)
+		goto out;
 
+	schedule_delayed_work(&ldlm_recalc_pools, delay);
+	ldlm_pools_init_done = true;
+out:
 	return rc;
 }
 
 void ldlm_pools_fini(void)
 {
-	unregister_shrinker(&ldlm_pools_cli_shrinker);
+	if (ldlm_pools_init_done) {
+		unregister_shrinker(&ldlm_pools_cli_shrinker);
 
-	ldlm_pools_thread_stop();
+		cancel_delayed_work_sync(&ldlm_recalc_pools);
+	}
 }
+
diff --git a/fs/lustre/obdclass/lu_object.c b/fs/lustre/obdclass/lu_object.c
index e8fc328..fcf0739 100644
--- a/fs/lustre/obdclass/lu_object.c
+++ b/fs/lustre/obdclass/lu_object.c
@@ -2138,10 +2138,8 @@ int lu_global_init(void)
 
 	LU_CONTEXT_KEY_INIT(&lu_global_key);
 	result = lu_context_key_register(&lu_global_key);
-	if (result != 0) {
-		lu_ref_global_fini();
-		return result;
-	}
+	if (result != 0)
+		goto out_lu_ref;
 
 	/*
 	 * At this level, we don't know what tags are needed, so allocate them
@@ -2153,8 +2151,7 @@ int lu_global_init(void)
 	up_write(&lu_sites_guard);
 	if (result != 0) {
 		lu_context_key_degister(&lu_global_key);
-		lu_ref_global_fini();
-		return result;
+		goto out_lu_ref;
 	}
 
 	/*
@@ -2163,23 +2160,25 @@ int lu_global_init(void)
 	 * lu_object/inode cache consuming all the memory.
 	 */
 	result = register_shrinker(&lu_site_shrinker);
-	if (result == 0) {
-		result = rhashtable_init(&lu_env_rhash, &lu_env_rhash_params);
-		if (result != 0)
-			unregister_shrinker(&lu_site_shrinker);
-	}
-	if (result != 0) {
-		/* Order explained in lu_global_fini(). */
-		lu_context_key_degister(&lu_global_key);
+	if (result)
+		goto out_env;
 
-		down_write(&lu_sites_guard);
-		lu_env_fini(&lu_shrink_env);
-		up_write(&lu_sites_guard);
+	result = rhashtable_init(&lu_env_rhash, &lu_env_rhash_params);
+	if (result)
+		goto out_shrinker;
 
-		lu_ref_global_fini();
-		return result;
-	}
+	return result;
 
+out_shrinker:
+	unregister_shrinker(&lu_site_shrinker);
+out_env:
+	/* Order explained in lu_global_fini(). */
+	lu_context_key_degister(&lu_global_key);
+	down_write(&lu_sites_guard);
+	lu_env_fini(&lu_shrink_env);
+	up_write(&lu_sites_guard);
+out_lu_ref:
+	lu_ref_global_fini();
 	return result;
 }
 
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
