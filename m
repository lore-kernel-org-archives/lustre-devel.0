Return-Path: <SRS0=GtYW=HL=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 16B83C433DB
	for <lustre-devel@archiver.kernel.org>; Tue,  9 Feb 2021 00:54:57 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id C8E6364E77
	for <lustre-devel@archiver.kernel.org>; Tue,  9 Feb 2021 00:54:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C8E6364E77
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id BB2D130FAB6;
	Mon,  8 Feb 2021 16:54:48 -0800 (PST)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 9F78530F95B
 for <lustre-devel@lists.lustre.org>; Mon,  8 Feb 2021 16:54:32 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 06CAF1006EBF;
 Mon,  8 Feb 2021 19:54:29 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 044A44CC22; Mon,  8 Feb 2021 19:54:29 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon,  8 Feb 2021 19:54:26 -0500
Message-Id: <1612832067-1449-9-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1612832067-1449-1-git-send-email-jsimmons@infradead.org>
References: <1612832067-1449-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 8/9] lustre: osc: avoid crash if ocd reset
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

Avoid divide-by-zero if OSC obd_connect_data is not fully initialized.
cl_ocd_grant_param is only set after cl_max_extent_pages is OK to use.

WC-bug-id: https://jira.whamcloud.com/browse/LU-14283
Lustre-commit: 1ec58a2e6ef98ba ("LU-14283 osc: avoid crash if ocd reset")
Signed-off-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/41225
Reviewed-by: John L. Hammond <jhammond@whamcloud.com>
Reviewed-by: Wang Shilong <wshilong@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/obd.h     |  8 +++++---
 fs/lustre/osc/osc_request.c | 11 +++++------
 2 files changed, 10 insertions(+), 9 deletions(-)

diff --git a/fs/lustre/include/obd.h b/fs/lustre/include/obd.h
index de62005..9957105 100644
--- a/fs/lustre/include/obd.h
+++ b/fs/lustre/include/obd.h
@@ -206,6 +206,11 @@ struct client_obd {
 	 */
 	u32			 cl_dom_min_inline_repsize;
 
+	/* checksumming for data sent over the network */
+	unsigned int		 cl_checksum:1,	/* 0 = disabled, 1 = enabled */
+				 cl_checksum_dump:1, /* same */
+				 cl_ocd_grant_param:1;
+	/* supported checksum types that are worked out at connect time */
 	enum lustre_sec_part     cl_sp_me;
 	enum lustre_sec_part     cl_sp_to;
 	struct sptlrpc_flavor    cl_flvr_mgc;   /* fixed flavor of mgc->mgs */
@@ -334,9 +339,6 @@ struct client_obd {
 	struct list_head	 cl_flight_waiters;
 	u32			 cl_rpcs_in_flight;
 
-	/* checksumming for data sent over the network */
-	unsigned int		cl_checksum:1,	/* 0 = disabled, 1 = enabled */
-				cl_checksum_dump:1; /* same */
 	/* supported checksum types that are worked out at connect time */
 	u32			cl_supp_cksum_types;
 	/* checksum algorithm to be used */
diff --git a/fs/lustre/osc/osc_request.c b/fs/lustre/osc/osc_request.c
index 8d3688f..be722c9 100644
--- a/fs/lustre/osc/osc_request.c
+++ b/fs/lustre/osc/osc_request.c
@@ -702,7 +702,7 @@ static void osc_announce_cached(struct client_obd *cli, struct obdo *oa,
 
 	oa->o_valid |= bits;
 	spin_lock(&cli->cl_loi_list_lock);
-	if (OCD_HAS_FLAG(&cli->cl_import->imp_connect_data, GRANT_PARAM))
+	if (cli->cl_ocd_grant_param)
 		oa->o_dirty = cli->cl_dirty_grant;
 	else
 		oa->o_dirty = cli->cl_dirty_pages << PAGE_SHIFT;
@@ -735,8 +735,7 @@ static void osc_announce_cached(struct client_obd *cli, struct obdo *oa,
 		nrpages *= cli->cl_max_rpcs_in_flight + 1;
 		nrpages = max(nrpages, cli->cl_dirty_max_pages);
 		undirty = nrpages << PAGE_SHIFT;
-		if (OCD_HAS_FLAG(&cli->cl_import->imp_connect_data,
-				 GRANT_PARAM)) {
+		if (cli->cl_ocd_grant_param) {
 			int nrextents;
 
 			/*
@@ -1070,10 +1069,10 @@ void osc_init_grant(struct client_obd *cli, struct obd_connect_data *ocd)
 					     ~chunk_mask) & chunk_mask;
 		/* determine maximum extent size, in #pages */
 		size = (u64)ocd->ocd_grant_max_blks << ocd->ocd_grant_blkbits;
-		cli->cl_max_extent_pages = size >> PAGE_SHIFT;
-		if (!cli->cl_max_extent_pages)
-			cli->cl_max_extent_pages = 1;
+		cli->cl_max_extent_pages = (size >> PAGE_SHIFT) ? : 1;
+		cli->cl_ocd_grant_param = 1;
 	} else {
+		cli->cl_ocd_grant_param = 0;
 		cli->cl_grant_extent_tax = 0;
 		cli->cl_chunkbits = PAGE_SHIFT;
 		cli->cl_max_extent_pages = DT_MAX_BRW_PAGES;
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
