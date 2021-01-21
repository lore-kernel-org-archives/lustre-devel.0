Return-Path: <SRS0=NZgA=GY=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 73025C433E0
	for <lustre-devel@archiver.kernel.org>; Thu, 21 Jan 2021 17:18:25 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 25B1923A5A
	for <lustre-devel@archiver.kernel.org>; Thu, 21 Jan 2021 17:18:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 25B1923A5A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 3206721FE9F;
	Thu, 21 Jan 2021 09:17:52 -0800 (PST)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 47A1D21FC5B
 for <lustre-devel@lists.lustre.org>; Thu, 21 Jan 2021 09:17:14 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 7918B100848E;
 Thu, 21 Jan 2021 12:17:05 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 778AD1B49B; Thu, 21 Jan 2021 12:17:05 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Thu, 21 Jan 2021 12:16:53 -0500
Message-Id: <1611249422-556-31-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1611249422-556-1-git-send-email-jsimmons@infradead.org>
References: <1611249422-556-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 30/39] lustre: ldlm: don't compute sumsq for
 pool stats
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

From: Andreas Dilger <adilger@whamcloud.com>

Remove the calculation of sumsq from the LDLM pool stats, since
these stats are almost never used, while conversely the pools
are updated frequently.

WC-bug-id: https://jira.whamcloud.com/browse/LU-9114
Lustre-commit: 966f6bb550be52e ("LU-9114 ldlm: don't compute sumsq for pool stats")
Signed-off-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/39435
Reviewed-by: Jian Yu <yujian@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ldlm/ldlm_pool.c | 33 +++++++++++----------------------
 1 file changed, 11 insertions(+), 22 deletions(-)

diff --git a/fs/lustre/ldlm/ldlm_pool.c b/fs/lustre/ldlm/ldlm_pool.c
index 9cee24b..2e4d16b 100644
--- a/fs/lustre/ldlm/ldlm_pool.c
+++ b/fs/lustre/ldlm/ldlm_pool.c
@@ -606,38 +606,27 @@ static int ldlm_pool_debugfs_init(struct ldlm_pool *pl)
 	}
 
 	lprocfs_counter_init(pl->pl_stats, LDLM_POOL_GRANTED_STAT,
-			     LPROCFS_CNTR_AVGMINMAX | LPROCFS_CNTR_STDDEV,
-			     "granted", "locks");
+			     LPROCFS_CNTR_AVGMINMAX, "granted", "locks");
 	lprocfs_counter_init(pl->pl_stats, LDLM_POOL_GRANT_STAT,
-			     LPROCFS_CNTR_AVGMINMAX | LPROCFS_CNTR_STDDEV,
-			     "grant", "locks");
+			     LPROCFS_CNTR_AVGMINMAX, "grant", "locks");
 	lprocfs_counter_init(pl->pl_stats, LDLM_POOL_CANCEL_STAT,
-			     LPROCFS_CNTR_AVGMINMAX | LPROCFS_CNTR_STDDEV,
-			     "cancel", "locks");
+			     LPROCFS_CNTR_AVGMINMAX, "cancel", "locks");
 	lprocfs_counter_init(pl->pl_stats, LDLM_POOL_GRANT_RATE_STAT,
-			     LPROCFS_CNTR_AVGMINMAX | LPROCFS_CNTR_STDDEV,
-			     "grant_rate", "locks/s");
+			     LPROCFS_CNTR_AVGMINMAX, "grant_rate", "locks/s");
 	lprocfs_counter_init(pl->pl_stats, LDLM_POOL_CANCEL_RATE_STAT,
-			     LPROCFS_CNTR_AVGMINMAX | LPROCFS_CNTR_STDDEV,
-			     "cancel_rate", "locks/s");
+			     LPROCFS_CNTR_AVGMINMAX, "cancel_rate", "locks/s");
 	lprocfs_counter_init(pl->pl_stats, LDLM_POOL_GRANT_PLAN_STAT,
-			     LPROCFS_CNTR_AVGMINMAX | LPROCFS_CNTR_STDDEV,
-			     "grant_plan", "locks/s");
+			     LPROCFS_CNTR_AVGMINMAX, "grant_plan", "locks/s");
 	lprocfs_counter_init(pl->pl_stats, LDLM_POOL_SLV_STAT,
-			     LPROCFS_CNTR_AVGMINMAX | LPROCFS_CNTR_STDDEV,
-			     "slv", "slv");
+			     LPROCFS_CNTR_AVGMINMAX, "slv", "slv");
 	lprocfs_counter_init(pl->pl_stats, LDLM_POOL_SHRINK_REQTD_STAT,
-			     LPROCFS_CNTR_AVGMINMAX | LPROCFS_CNTR_STDDEV,
-			     "shrink_request", "locks");
+			     LPROCFS_CNTR_AVGMINMAX, "shrink_request", "locks");
 	lprocfs_counter_init(pl->pl_stats, LDLM_POOL_SHRINK_FREED_STAT,
-			     LPROCFS_CNTR_AVGMINMAX | LPROCFS_CNTR_STDDEV,
-			     "shrink_freed", "locks");
+			     LPROCFS_CNTR_AVGMINMAX, "shrink_freed", "locks");
 	lprocfs_counter_init(pl->pl_stats, LDLM_POOL_RECALC_STAT,
-			     LPROCFS_CNTR_AVGMINMAX | LPROCFS_CNTR_STDDEV,
-			     "recalc_freed", "locks");
+			     LPROCFS_CNTR_AVGMINMAX, "recalc_freed", "locks");
 	lprocfs_counter_init(pl->pl_stats, LDLM_POOL_TIMING_STAT,
-			     LPROCFS_CNTR_AVGMINMAX | LPROCFS_CNTR_STDDEV,
-			     "recalc_timing", "sec");
+			     LPROCFS_CNTR_AVGMINMAX, "recalc_timing", "sec");
 	debugfs_create_file("stats", 0644, pl->pl_debugfs_entry, pl->pl_stats,
 			    &lprocfs_stats_seq_fops);
 
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
