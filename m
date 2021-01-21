Return-Path: <SRS0=NZgA=GY=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CC776C433DB
	for <lustre-devel@archiver.kernel.org>; Thu, 21 Jan 2021 17:17:27 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 12CC323A57
	for <lustre-devel@archiver.kernel.org>; Thu, 21 Jan 2021 17:17:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 12CC323A57
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id E713521FCCE;
	Thu, 21 Jan 2021 09:17:20 -0800 (PST)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 65FA821FA40
 for <lustre-devel@lists.lustre.org>; Thu, 21 Jan 2021 09:17:08 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 35DD21008050;
 Thu, 21 Jan 2021 12:17:05 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 320A71B49B; Thu, 21 Jan 2021 12:17:05 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Thu, 21 Jan 2021 12:16:31 -0500
Message-Id: <1611249422-556-9-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1611249422-556-1-git-send-email-jsimmons@infradead.org>
References: <1611249422-556-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 08/39] lustre: osc: prevent overflow of
 o_dropped
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

From: Olaf Faaland <faaland1@llnl.gov>

In osc_announce_cached(), prevent o_dropped from overflowing.
Necessary because o_dropped AKA o_misc is 32 bits, but cl_lost_grant
is 64 bits.

Add a CDEBUG call so we can tell whether this happened.

WC-bug-id: https://jira.whamcloud.com/browse/LU-14125
Lustre-commit: 82e9a11056a552 ("LU-14125 osc: prevent overflow of o_dropped")
Signed-off-by: Olaf Faaland <faaland1@llnl.gov>
Reviewed-on: https://review.whamcloud.com/40659
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/osc/osc_request.c | 18 ++++++++++++++----
 1 file changed, 14 insertions(+), 4 deletions(-)

diff --git a/fs/lustre/osc/osc_request.c b/fs/lustre/osc/osc_request.c
index f225ccd..4a4b5ef 100644
--- a/fs/lustre/osc/osc_request.c
+++ b/fs/lustre/osc/osc_request.c
@@ -754,11 +754,21 @@ static void osc_announce_cached(struct client_obd *cli, struct obdo *oa,
 				    ~(PTLRPC_MAX_BRW_SIZE * 4UL));
 	}
 	oa->o_grant = cli->cl_avail_grant + cli->cl_reserved_grant;
-	oa->o_dropped = cli->cl_lost_grant;
-	cli->cl_lost_grant = 0;
+	/* o_dropped AKA o_misc is 32 bits, but cl_lost_grant is 64 bits */
+	if (cli->cl_lost_grant > INT_MAX) {
+		CDEBUG(D_CACHE,
+		       "%s: avoided o_dropped overflow: cl_lost_grant %lu\n",
+		       cli_name(cli), cli->cl_lost_grant);
+		oa->o_dropped = INT_MAX;
+	} else {
+		oa->o_dropped = cli->cl_lost_grant;
+	}
+	cli->cl_lost_grant -= oa->o_dropped;
 	spin_unlock(&cli->cl_loi_list_lock);
-	CDEBUG(D_CACHE, "dirty: %llu undirty: %u dropped %u grant: %llu\n",
-	       oa->o_dirty, oa->o_undirty, oa->o_dropped, oa->o_grant);
+	CDEBUG(D_CACHE,
+	       "%s: dirty: %llu undirty: %u dropped %u grant: %llu cl_lost_grant %lu\n",
+	       cli_name(cli), oa->o_dirty, oa->o_undirty, oa->o_dropped,
+	       oa->o_grant, cli->cl_lost_grant);
 }
 
 void osc_update_next_shrink(struct client_obd *cli)
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
