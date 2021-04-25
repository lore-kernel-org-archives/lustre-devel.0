Return-Path: <SRS0=Gt0B=JW=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.7 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AD3DAC433B4
	for <lustre-devel@archiver.kernel.org>; Sun, 25 Apr 2021 20:08:47 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 31390611CC
	for <lustre-devel@archiver.kernel.org>; Sun, 25 Apr 2021 20:08:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 31390611CC
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id D2FAB21F77B;
	Sun, 25 Apr 2021 13:08:45 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 5666721F513
 for <lustre-devel@lists.lustre.org>; Sun, 25 Apr 2021 13:08:42 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 08C17100848D;
 Sun, 25 Apr 2021 16:08:40 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 00CB569A85; Sun, 25 Apr 2021 16:08:40 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 25 Apr 2021 16:08:11 -0400
Message-Id: <1619381316-7719-5-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1619381316-7719-1-git-send-email-jsimmons@infradead.org>
References: <1619381316-7719-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 04/29] lnet: handle possiblity of IPv6 being
 unavailable.
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

If CONFIG_IPV6 is not enabled, the attempt to create an IPv6 socket
for accepting new incoming connections will fail.  In that case
we need to creae an IPv4 socket instead.

Also ipv6_dev_get_saddr will not be available, so we must not include
the code that tries to use it.

Fixes: 7314102c80ae ("lnet: allow creation of IPv6 socket")
WC-bug-id: https://jira.whamcloud.com/browse/LU-14477
Lustre-commit: 6376551ca266f839 ("LU-14477 lnet: handle possiblity of IPv6 being unavailable.")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/41791
Reviewed-by: Alex Zhuravlev <bzzz@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/lib-socket.c | 20 ++++++++++++++++----
 1 file changed, 16 insertions(+), 4 deletions(-)

diff --git a/net/lnet/lnet/lib-socket.c b/net/lnet/lnet/lib-socket.c
index ee675ae..317d3cf 100644
--- a/net/lnet/lnet/lib-socket.c
+++ b/net/lnet/lnet/lib-socket.c
@@ -188,7 +188,13 @@ int choose_ipv4_src(u32 *ret, int interface, u32 dst_ipaddr, struct net *ns)
 	family = AF_INET6;
 	if (remaddr)
 		family = remaddr->sa_family;
+retry:
 	rc = sock_create_kern(ns, family, SOCK_STREAM, 0, &sock);
+	if (rc == -EAFNOSUPPORT && family == AF_INET6 && !remaddr) {
+		family = AF_INET;
+		goto retry;
+	}
+
 	if (rc) {
 		CERROR("Can't create socket: %d\n", rc);
 		return ERR_PTR(rc);
@@ -204,11 +210,11 @@ int choose_ipv4_src(u32 *ret, int interface, u32 dst_ipaddr, struct net *ns)
 
 	if (interface >= 0 || local_port) {
 		struct sockaddr_storage locaddr = {};
-		struct sockaddr_in *sin = (void *)&locaddr;
-		struct sockaddr_in6 *sin6 = (void *)&locaddr;
 
 		switch (family) {
-		case AF_INET:
+		case AF_INET: {
+			struct sockaddr_in *sin = (void *)&locaddr;
+
 			sin->sin_family = AF_INET;
 			sin->sin_addr.s_addr = INADDR_ANY;
 			if (interface >= 0 && remaddr) {
@@ -225,7 +231,11 @@ int choose_ipv4_src(u32 *ret, int interface, u32 dst_ipaddr, struct net *ns)
 			}
 			sin->sin_port = htons(local_port);
 			break;
-		case AF_INET6:
+		}
+#if IS_ENABLED(CONFIG_IPV6)
+		case AF_INET6: {
+			struct sockaddr_in6 *sin6 = (void *)&locaddr;
+
 			sin6->sin6_family = AF_INET6;
 			sin6->sin6_addr = in6addr_any;
 			if (interface >= 0 && remaddr) {
@@ -240,6 +250,8 @@ int choose_ipv4_src(u32 *ret, int interface, u32 dst_ipaddr, struct net *ns)
 			sin6->sin6_port = htons(local_port);
 			break;
 		}
+#endif /* IS_ENABLED(CONFIG_IPV6) */
+		}
 
 		rc = kernel_bind(sock, (struct sockaddr *)&locaddr,
 				 sizeof(locaddr));
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
