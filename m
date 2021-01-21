Return-Path: <SRS0=NZgA=GY=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BD150C433E0
	for <lustre-devel@archiver.kernel.org>; Thu, 21 Jan 2021 17:19:09 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 58EAF23A57
	for <lustre-devel@archiver.kernel.org>; Thu, 21 Jan 2021 17:19:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 58EAF23A57
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 561AA21FDE7;
	Thu, 21 Jan 2021 09:18:14 -0800 (PST)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 603C621FC95
 for <lustre-devel@lists.lustre.org>; Thu, 21 Jan 2021 09:17:15 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 850CF1008492;
 Thu, 21 Jan 2021 12:17:05 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 845511B49B; Thu, 21 Jan 2021 12:17:05 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Thu, 21 Jan 2021 12:16:57 -0500
Message-Id: <1611249422-556-35-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1611249422-556-1-git-send-email-jsimmons@infradead.org>
References: <1611249422-556-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 34/39] lnet: socklnd: announce deprecation of
 'use_tcp_bonding'
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
Cc: Serguei Smirnov <ssmirnov@whamcloud.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Serguei Smirnov <ssmirnov@whamcloud.com>

Add warning to be printed if 'use_tcp_bonding' option is used
notifying the user that the feature is being deprecated.
It is suggested to use MR configuration with dynamic discovery
instead.

Multi-Rail feature doesn't need to be explicitly enabled.
To use MR instead of tcp bonding, group the interfaces
on the same network using the lnetctl utility:

	lnetctl net add --net tcp --if eth2,eth3

or via the modprobe configuration file (/etc/modprobe.d/lnet.conf
or /etc/modprobe.d/lustre.conf):

	options lnet networks="tcp(eth2,eth3)"

and make sure dynamic discovery is enabled:

	lnetctl set discovery 1

MR will aggregate the throughput of all configured and available
networks/interfaces shared between peer nodes.

WC-bug-id: https://jira.whamcloud.com/browse/LU-13641
Lustre-commit: 1a2bf911b97936 ("LU-13641 socklnd: announce deprecation of 'use_tcp_bonding'")
Signed-off-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/41088
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Cyril Bordage <cbordage@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/api-ni.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/net/lnet/lnet/api-ni.c b/net/lnet/lnet/api-ni.c
index 322b25d..c3bf444 100644
--- a/net/lnet/lnet/api-ni.c
+++ b/net/lnet/lnet/api-ni.c
@@ -70,7 +70,7 @@ struct lnet the_lnet = {
 static int use_tcp_bonding = false;
 module_param(use_tcp_bonding, int, 0444);
 MODULE_PARM_DESC(use_tcp_bonding,
-		 "Set to 1 to use socklnd bonding. 0 to use Multi-Rail");
+		 "use_tcp_bonding parameter has been deprecated");
 
 unsigned int lnet_numa_range;
 EXPORT_SYMBOL(lnet_numa_range);
@@ -2610,8 +2610,10 @@ void lnet_lib_exit(void)
 		goto err_empty_list;
 	}
 
-	/*
-	 * If LNet is being initialized via DLC it is possible
+	if (use_tcp_bonding)
+		CWARN("'use_tcp_bonding' option has been deprecated. See LU-13641\n");
+
+	/* If LNet is being initialized via DLC it is possible
 	 * that the user requests not to load module parameters (ones which
 	 * are supported by DLC) on initialization.  Therefore, make sure not
 	 * to load networks, routes and forwarding from module parameters
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
