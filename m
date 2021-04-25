Return-Path: <SRS0=Gt0B=JW=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.7 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3E08DC433B4
	for <lustre-devel@archiver.kernel.org>; Sun, 25 Apr 2021 20:08:52 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id D6CB761260
	for <lustre-devel@archiver.kernel.org>; Sun, 25 Apr 2021 20:08:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D6CB761260
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 6AEC421F7DB;
	Sun, 25 Apr 2021 13:08:48 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 0B0BB21F513
 for <lustre-devel@lists.lustre.org>; Sun, 25 Apr 2021 13:08:42 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 067F5100848C;
 Sun, 25 Apr 2021 16:08:40 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id EDA1B69A7D; Sun, 25 Apr 2021 16:08:39 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 25 Apr 2021 16:08:09 -0400
Message-Id: <1619381316-7719-3-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1619381316-7719-1-git-send-email-jsimmons@infradead.org>
References: <1619381316-7719-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 02/29] lnet: allow creation of IPv6 socket.
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

With this patch, lnet_sock_create() can make IPv6 sockets.  If an
interface and destination is given, completely different code is
needed to bind the local address.

When no interface or destination is given, an IPv6 socket is always
created, so lnet_acceptor() needs to request that IPv4 connections are
accepted as well, and lnet_sock_getaddr() needs to detect mapped v4
addresses and present them as true v4 addresses.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10391
Lustre-commit: e4fa181abf103219 ("LU-10391 lnet: allow creation of IPv6 socket.")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/37705
Reviewed-by: Shaun Tancheff <shaun.tancheff@hpe.com>
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/lib-socket.c | 85 +++++++++++++++++++++++++++++++++++-----------
 1 file changed, 65 insertions(+), 20 deletions(-)

diff --git a/net/lnet/lnet/lib-socket.c b/net/lnet/lnet/lib-socket.c
index 5c5366f..eb6559c 100644
--- a/net/lnet/lnet/lib-socket.c
+++ b/net/lnet/lnet/lib-socket.c
@@ -35,6 +35,8 @@
 #include <linux/if.h>
 #include <linux/in.h>
 #include <linux/net.h>
+#include <net/addrconf.h>
+#include <net/ipv6.h>
 #include <linux/file.h>
 #include <linux/pagemap.h>
 /* For sys_open & sys_close */
@@ -141,7 +143,7 @@
 }
 EXPORT_SYMBOL(lnet_sock_read);
 
-int choose_ipv4_src(__u32 *ret, int interface, __u32 dst_ipaddr, struct net *ns)
+int choose_ipv4_src(u32 *ret, int interface, u32 dst_ipaddr, struct net *ns)
 {
 	struct net_device *dev;
 	struct in_device *in_dev;
@@ -181,8 +183,12 @@ int choose_ipv4_src(__u32 *ret, int interface, __u32 dst_ipaddr, struct net *ns)
 	struct socket *sock;
 	int rc;
 	int option;
+	int family;
 
-	rc = sock_create_kern(ns, PF_INET, SOCK_STREAM, 0, &sock);
+	family = AF_INET6;
+	if (remaddr)
+		family = remaddr->sa_family;
+	rc = sock_create_kern(ns, family, SOCK_STREAM, 0, &sock);
 	if (rc) {
 		CERROR("Can't create socket: %d\n", rc);
 		return ERR_PTR(rc);
@@ -197,25 +203,44 @@ int choose_ipv4_src(__u32 *ret, int interface, __u32 dst_ipaddr, struct net *ns)
 	}
 
 	if (interface >= 0 || local_port) {
-		struct sockaddr_in locaddr = {};
-
-		locaddr.sin_family = AF_INET;
-		locaddr.sin_addr.s_addr = INADDR_ANY;
-		if (interface >= 0) {
-			struct sockaddr_in *sin = (void *)remaddr;
-			u32 ip;
-
-			rc = choose_ipv4_src(&ip,
-					     interface,
-					     ntohl(sin->sin_addr.s_addr),
-					     ns);
-			if (rc)
-				goto failed;
-			locaddr.sin_addr.s_addr = htonl(ip);
+		struct sockaddr_storage locaddr = {};
+		struct sockaddr_in *sin = (void *)&locaddr;
+		struct sockaddr_in6 *sin6 = (void *)&locaddr;
+
+		switch (family) {
+		case AF_INET:
+			sin->sin_family = AF_INET;
+			sin->sin_addr.s_addr = INADDR_ANY;
+			if (interface >= 0 && remaddr) {
+				struct sockaddr_in *rem = (void *)remaddr;
+				u32 ip;
+
+				rc = choose_ipv4_src(&ip,
+						     interface,
+						     ntohl(rem->sin_addr.s_addr),
+						     ns);
+				if (rc)
+					goto failed;
+				sin->sin_addr.s_addr = htonl(ip);
+			}
+			sin->sin_port = htons(local_port);
+			break;
+		case AF_INET6:
+			sin6->sin6_family = AF_INET6;
+			sin6->sin6_addr = in6addr_any;
+			if (interface >= 0 && remaddr) {
+				struct sockaddr_in6 *rem = (void *)remaddr;
+
+				ipv6_dev_get_saddr(ns,
+						   dev_get_by_index(ns,
+								    interface),
+						   &rem->sin6_addr, 0,
+						   &sin6->sin6_addr);
+			}
+			sin6->sin6_port = htons(local_port);
+			break;
 		}
 
-		locaddr.sin_port = htons(local_port);
-
 		rc = kernel_bind(sock, (struct sockaddr *)&locaddr,
 				 sizeof(locaddr));
 		if (rc == -EADDRINUSE) {
@@ -281,7 +306,19 @@ int choose_ipv4_src(__u32 *ret, int interface, __u32 dst_ipaddr, struct net *ns)
 		       rc, remote ? "peer" : "local");
 		return rc;
 	}
-
+	if (peer->ss_family == AF_INET6) {
+		struct sockaddr_in6 *in6 = (void *)peer;
+		struct sockaddr_in *in = (void *)peer;
+		short port = in6->sin6_port;
+
+		if (ipv6_addr_v4mapped(&in6->sin6_addr)) {
+			/* Pretend it is a v4 socket */
+			memset(in, 0, sizeof(*in));
+			in->sin_family = AF_INET;
+			in->sin_port = port;
+			memcpy(&in->sin_addr, &in6->sin6_addr.s6_addr32[3], 4);
+		}
+	}
 	return 0;
 }
 EXPORT_SYMBOL(lnet_sock_getaddr);
@@ -303,6 +340,7 @@ struct socket *
 lnet_sock_listen(int local_port, int backlog, struct net *ns)
 {
 	struct socket *sock;
+	int val = 0;
 	int rc;
 
 	sock = lnet_sock_create(-1, NULL, local_port, ns);
@@ -314,6 +352,13 @@ struct socket *
 		return ERR_PTR(rc);
 	}
 
+	/* Make sure we get both IPv4 and IPv6 connections.
+	 * This is the default, but it can be overridden so
+	 * we force it back.
+	 */
+	kernel_setsockopt(sock, IPPROTO_IPV6, IPV6_V6ONLY,
+			  (char *)&val, sizeof(val));
+
 	rc = kernel_listen(sock, backlog);
 	if (!rc)
 		return sock;
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
