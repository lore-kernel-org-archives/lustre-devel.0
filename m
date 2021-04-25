Return-Path: <SRS0=Gt0B=JW=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.7 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 42E6CC43460
	for <lustre-devel@archiver.kernel.org>; Sun, 25 Apr 2021 20:09:05 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id E4E1461260
	for <lustre-devel@archiver.kernel.org>; Sun, 25 Apr 2021 20:09:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E4E1461260
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 2AA2421F6D3;
	Sun, 25 Apr 2021 13:08:56 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 9118C21F513
 for <lustre-devel@lists.lustre.org>; Sun, 25 Apr 2021 13:08:42 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 0B58810084DD;
 Sun, 25 Apr 2021 16:08:40 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id F1E1469A7E; Sun, 25 Apr 2021 16:08:39 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 25 Apr 2021 16:08:10 -0400
Message-Id: <1619381316-7719-4-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1619381316-7719-1-git-send-email-jsimmons@infradead.org>
References: <1619381316-7719-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 03/29] lnet: allow lnet_connect() to use IPv6
 addresses
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

Now that we can created and bind IPv6 sockets, connecting to them is
trivial.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10391
Lustre-commit: fb40f0b62d77d69 ("LU-10391 lnet: allow lnet_connect() to use IPv6 addresses.")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/37706
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: Aurelien Degremont <degremoa@amazon.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/acceptor.c   | 3 ++-
 net/lnet/lnet/lib-socket.c | 2 +-
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/lnet/lnet/acceptor.c b/net/lnet/lnet/acceptor.c
index 5765a08..d326e39 100644
--- a/net/lnet/lnet/acceptor.c
+++ b/net/lnet/lnet/acceptor.c
@@ -140,7 +140,8 @@ struct socket *
 
 	BUILD_BUG_ON(sizeof(cr) > 16);		/* too big to be on the stack */
 
-	LASSERT(peeraddr->sa_family == AF_INET);
+	LASSERT(peeraddr->sa_family == AF_INET ||
+		peeraddr->sa_family == AF_INET6);
 
 	for (port = LNET_ACCEPTOR_MAX_RESERVED_PORT;
 	     port >= LNET_ACCEPTOR_MIN_RESERVED_PORT;
diff --git a/net/lnet/lnet/lib-socket.c b/net/lnet/lnet/lib-socket.c
index eb6559c..ee675ae 100644
--- a/net/lnet/lnet/lib-socket.c
+++ b/net/lnet/lnet/lib-socket.c
@@ -380,7 +380,7 @@ struct socket *
 	if (IS_ERR(sock))
 		return sock;
 
-	rc = kernel_connect(sock, peeraddr, sizeof(struct sockaddr_in), 0);
+	rc = kernel_connect(sock, peeraddr, sizeof(struct sockaddr_in6), 0);
 	if (!rc)
 		return sock;
 
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
