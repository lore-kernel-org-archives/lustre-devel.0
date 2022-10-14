Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id BFE47C43217
	for <lustre-devel@archiver.kernel.org>; Fri, 14 Oct 2022 21:38:31 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4Mq0BG518Sz21D4;
	Fri, 14 Oct 2022 14:38:30 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4Mq0B421GBz1y57
 for <lustre-devel@lists.lustre.org>; Fri, 14 Oct 2022 14:38:20 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 0187B1006F3D;
 Fri, 14 Oct 2022 17:38:13 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id EFFE8DD535; Fri, 14 Oct 2022 17:38:13 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Fri, 14 Oct 2022 17:37:58 -0400
Message-Id: <1665783491-13827-8-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1665783491-13827-1-git-send-email-jsimmons@infradead.org>
References: <1665783491-13827-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 07/20] lnet: ksocklnd: support IPv6 in
 ksocknal_ip2index()
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

From: Mr NeilBrown <neilb@suse.de>

ksocknal_ip2index() can now find the interface index for an IPv6
address.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10391
Lustre-commit: c0fdf9efbf927db40 ("LU-10391 socklnd: support IPv6 in ksocknal_ip2index()")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/48570
Reviewed-by: jsimmons <jsimmons@infradead.org>
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: Frank Sehr <fsehr@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/klnds/socklnd/socklnd.c | 40 +++++++++++++++++++++++++-------
 1 file changed, 31 insertions(+), 9 deletions(-)

diff --git a/net/lnet/klnds/socklnd/socklnd.c b/net/lnet/klnds/socklnd/socklnd.c
index 69cb738796e7..89696977ac63 100644
--- a/net/lnet/klnds/socklnd/socklnd.c
+++ b/net/lnet/klnds/socklnd/socklnd.c
@@ -40,6 +40,7 @@
 #include <linux/ethtool.h>
 #include <linux/inetdevice.h>
 #include <linux/sunrpc/addr.h>
+#include <net/addrconf.h>
 #include "socklnd.h"
 
 static struct lnet_lnd the_ksocklnd;
@@ -79,8 +80,7 @@ static int ksocknal_ip2index(struct sockaddr *addr, struct lnet_ni *ni)
 	int ret = -1;
 	const struct in_ifaddr *ifa;
 
-	if (addr->sa_family != AF_INET)
-		/* No IPv6 support yet */
+	if (addr->sa_family != AF_INET && addr->sa_family != AF_INET6)
 		return ret;
 
 	rcu_read_lock();
@@ -94,14 +94,36 @@ static int ksocknal_ip2index(struct sockaddr *addr, struct lnet_ni *ni)
 		if (!(flags & IFF_UP))
 			continue;
 
-		in_dev = __in_dev_get_rcu(dev);
-		if (!in_dev)
-			continue;
+		switch (addr->sa_family) {
+		case AF_INET:
+			in_dev = __in_dev_get_rcu(dev);
+			if (!in_dev)
+				continue;
 
-		in_dev_for_each_ifa_rcu(ifa, in_dev) {
-			if (ifa->ifa_local ==
-			    ((struct sockaddr_in *)addr)->sin_addr.s_addr)
-				ret = dev->ifindex;
+			in_dev_for_each_ifa_rcu(ifa, in_dev) {
+				if (ifa->ifa_local ==
+				    ((struct sockaddr_in *)addr)->sin_addr.s_addr)
+					ret = dev->ifindex;
+			}
+			break;
+#if IS_ENABLED(CONFIG_IPV6)
+		case AF_INET6: {
+			struct inet6_dev *in6_dev;
+			const struct inet6_ifaddr *ifa6;
+			struct sockaddr_in6 *addr6 = (struct sockaddr_in6 *)addr;
+
+			in6_dev = __in6_dev_get(dev);
+			if (!in6_dev)
+				continue;
+
+			list_for_each_entry_rcu(ifa6, &in6_dev->addr_list, if_list) {
+				if (ipv6_addr_cmp(&ifa6->addr,
+						  &addr6->sin6_addr) == 0)
+					ret = dev->ifindex;
+			}
+			break;
+			}
+#endif /* IS_ENABLED(CONFIG_IPV6) */
 		}
 		if (ret >= 0)
 			break;
-- 
2.27.0

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
