Return-Path: <SRS0=FD7t=JM=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 26E48C433ED
	for <lustre-devel@archiver.kernel.org>; Thu, 15 Apr 2021 04:03:55 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id DAAF360230
	for <lustre-devel@archiver.kernel.org>; Thu, 15 Apr 2021 04:03:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DAAF360230
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 926E932CA76;
	Wed, 14 Apr 2021 21:03:27 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 0CC2E32F509
 for <lustre-devel@lists.lustre.org>; Wed, 14 Apr 2021 21:02:52 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 77E04100F353;
 Thu, 15 Apr 2021 00:02:45 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 76E6291884; Thu, 15 Apr 2021 00:02:45 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Thu, 15 Apr 2021 00:02:10 -0400
Message-Id: <1618459361-17909-19-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1618459361-17909-1-git-send-email-jsimmons@infradead.org>
References: <1618459361-17909-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 18/49] lustre: osc: fix performance
 regression in osc_extent_merge()
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

The following IOR performance regression was reported at LU-14424:

Client Version		NP	Write(MB/s)	Read(MB/s)
Lustre-2.13.0		1	803		3293
Lustre-2.14.0-RC1	1	529	 	3092
Lustre-2.13.0		16	6962		12021
Lustre-2.14.0-RC1	16	5127		11951

This was tracked down to commit 85ebb57ddc5b. Restore the original
performance with fix in this patch.

Fixes: 85ebb57ddc5b ("lustre: osc: simplify osc_extent_find()")
WC-bug-id: https://jira.whamcloud.com/browse/LU-9679
WC-bug-id: https://jira.whamcloud.com/browse/LU-14424
Lustre-commit: 3e6b7a785cab514a ("LU-9679 osc: simplify osc_extent_find()")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/41691
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/osc/osc_cache.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/fs/lustre/osc/osc_cache.c b/fs/lustre/osc/osc_cache.c
index 4abe8ba..e85f320 100644
--- a/fs/lustre/osc/osc_cache.c
+++ b/fs/lustre/osc/osc_cache.c
@@ -568,7 +568,8 @@ static int osc_extent_merge(const struct lu_env *env, struct osc_extent *cur,
 	if (!victim)
 		return -EINVAL;
 
-	if (victim->oe_state != OES_CACHE || victim->oe_fsync_wait)
+	if (victim->oe_state != OES_INV &&
+	    (victim->oe_state != OES_CACHE || victim->oe_fsync_wait))
 		return -EBUSY;
 
 	if (cur->oe_max_end != victim->oe_max_end)
@@ -809,7 +810,6 @@ static struct osc_extent *osc_extent_find(const struct lu_env *env,
 		if (osc_extent_merge(env, ext, cur) == 0) {
 			LASSERT(*grants >= chunksize);
 			*grants -= chunksize;
-			found = osc_extent_hold(ext);
 
 			/*
 			 * Try to merge with the next one too because we
@@ -819,6 +819,7 @@ static struct osc_extent *osc_extent_find(const struct lu_env *env,
 				/* we can save extent tax from next extent */
 				*grants += cli->cl_grant_extent_tax;
 
+			found = osc_extent_hold(ext);
 			break;
 		}
 	}
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
