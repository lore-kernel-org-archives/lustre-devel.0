Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 84DA0C433FE
	for <lustre-devel@archiver.kernel.org>; Sun, 20 Nov 2022 14:30:46 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4NFXhw1fLFz219Q;
	Sun, 20 Nov 2022 06:19:44 -0800 (PST)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4NFXhl5PPnz215t
 for <lustre-devel@lists.lustre.org>; Sun, 20 Nov 2022 06:19:35 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id CFF341008260;
 Sun, 20 Nov 2022 09:17:09 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id C9463E8B8B; Sun, 20 Nov 2022 09:17:09 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 20 Nov 2022 09:16:56 -0500
Message-Id: <1668953828-10909-11-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1668953828-10909-1-git-send-email-jsimmons@infradead.org>
References: <1668953828-10909-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 10/22] lnet: fix build issue when IPv6 is
 disabled.
X-BeenThere: lustre-devel@lists.lustre.org
X-Mailman-Version: 2.1.39
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

struct inet6_dev and struct inet6_ifaddr are not defined if IPv6
is not configured for the Linux kernel.

Fixes: 351a6df78c3 ("lnet: support IPv6 in lnet_inet_enumerate()")
WC-bug-id: https://jira.whamcloud.com/browse/LU-10391
Lustre-commit: 896cd5b7bcf94d4fd ("LU-10391 lnet: fix build issue when IPv6 is disabled.")
Signed-off-by: James Simmons <jsimmons@infradead.org>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/48990
Reviewed-by: Chris Horn <chris.horn@hpe.com>
Reviewed-by: Neil Brown <neilb@suse.de>
Reviewed-by: Frank Sehr <fsehr@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
---
 net/lnet/lnet/config.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/lnet/lnet/config.c b/net/lnet/lnet/config.c
index 4b2d776..5bfae4e 100644
--- a/net/lnet/lnet/config.c
+++ b/net/lnet/lnet/config.c
@@ -1501,8 +1501,10 @@ int lnet_inet_enumerate(struct lnet_inetdev **dev_list, struct net *ns, bool v6)
 		int flags = dev_get_flags(dev);
 		const struct in_ifaddr *ifa;
 		struct in_device *in_dev;
+#if IS_ENABLED(CONFIG_IPV6)
 		struct inet6_dev *in6_dev;
 		const struct inet6_ifaddr *ifa6;
+#endif
 		int node_id;
 		int cpt;
 
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
