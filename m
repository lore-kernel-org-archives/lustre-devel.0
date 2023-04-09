Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 0852DC77B70
	for <lustre-devel@archiver.kernel.org>; Sun,  9 Apr 2023 12:44:43 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4PvWW41vsfz22ZH;
	Sun,  9 Apr 2023 05:24:16 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4PvWVL2tFlz22ZJ
 for <lustre-devel@lists.lustre.org>; Sun,  9 Apr 2023 05:23:38 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 6989E1008492;
 Sun,  9 Apr 2023 08:13:28 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 684822B2; Sun,  9 Apr 2023 08:13:28 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun,  9 Apr 2023 08:13:16 -0400
Message-Id: <1681042400-15491-37-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1681042400-15491-1-git-send-email-jsimmons@infradead.org>
References: <1681042400-15491-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 36/40] lnet: lnet_parse_route uses wrong loop
 var
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
Cc: Chris Horn <chris.horn@hpe.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Chris Horn <chris.horn@hpe.com>

When looping over the gateways list, we're referencing the wrong
loop variable to get the gateway nid (ltb instead of ltb2).

Fixes: 1a77031c36 ("lustre: lnet/config: convert list_for_each to list_for_each_entry")
WC-bug-id: https://jira.whamcloud.com/browse/LU-16606
Lustre-commit: 0a414b1077a2f9dbc ("LU-16606 lnet: lnet_parse_route uses wrong loop var")
Signed-off-by: Chris Horn <chris.horn@hpe.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/50173
Reviewed-by: jsimmons <jsimmons@infradead.org>
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/config.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/lnet/lnet/config.c b/net/lnet/lnet/config.c
index a54e1db..c239f9c 100644
--- a/net/lnet/lnet/config.c
+++ b/net/lnet/lnet/config.c
@@ -1168,7 +1168,7 @@ struct lnet_ni *
 		LASSERT(net != LNET_NET_ANY);
 
 		list_for_each_entry(ltb2, &gateways, ltb_list) {
-			LASSERT(libcfs_strnid(&nid, ltb->ltb_text) == 0);
+			LASSERT(libcfs_strnid(&nid, ltb2->ltb_text) == 0);
 
 			if (lnet_islocalnid(&nid)) {
 				*im_a_router = 1;
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
