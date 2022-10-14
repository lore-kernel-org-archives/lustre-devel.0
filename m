Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 55627C4332F
	for <lustre-devel@archiver.kernel.org>; Fri, 14 Oct 2022 21:38:29 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4Mq0BB6lNLz21Hv;
	Fri, 14 Oct 2022 14:38:26 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4Mq0B263ntz1xJR
 for <lustre-devel@lists.lustre.org>; Fri, 14 Oct 2022 14:38:18 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id EFD591006F30;
 Fri, 14 Oct 2022 17:38:13 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id EAD36DF4C0; Fri, 14 Oct 2022 17:38:13 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Fri, 14 Oct 2022 17:37:57 -0400
Message-Id: <1665783491-13827-7-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1665783491-13827-1-git-send-email-jsimmons@infradead.org>
References: <1665783491-13827-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 06/20] lnet: add iface index to struct
 lnet_inetdev
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

When getting list of interfaces, get the index as well, as this can be
useful and avoid search the list of interfaces again to find it.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10391
Lustre-commit: 860182ee6e84d391a ("LU-10391 lnet: add iface index to struct lnet_inetdev")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/48569
Reviewed-by: jsimmons <jsimmons@infradead.org>
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: Frank Sehr <fsehr@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/lib-lnet.h    | 1 +
 net/lnet/klnds/socklnd/socklnd.c | 2 +-
 net/lnet/lnet/config.c           | 1 +
 3 files changed, 3 insertions(+), 1 deletion(-)

diff --git a/include/linux/lnet/lib-lnet.h b/include/linux/lnet/lib-lnet.h
index a95919e69802..eb48d2900172 100644
--- a/include/linux/lnet/lib-lnet.h
+++ b/include/linux/lnet/lib-lnet.h
@@ -826,6 +826,7 @@ struct lnet_inetdev {
 	u32	li_flags;
 	u32	li_ipaddr;
 	u32	li_netmask;
+	u32	li_index;
 	char	li_name[IFNAMSIZ];
 };
 
diff --git a/net/lnet/klnds/socklnd/socklnd.c b/net/lnet/klnds/socklnd/socklnd.c
index 2b08501133dc..69cb738796e7 100644
--- a/net/lnet/klnds/socklnd/socklnd.c
+++ b/net/lnet/klnds/socklnd/socklnd.c
@@ -2522,11 +2522,11 @@ ksocknal_startup(struct lnet_ni *ni)
 	}
 
 	ni->ni_dev_cpt = ifaces[i].li_cpt;
+	ksi->ksni_index = ifaces[i].li_index;
 	sa = (void *)&ksi->ksni_addr;
 	memset(sa, 0, sizeof(*sa));
 	sa->sin_family = AF_INET;
 	sa->sin_addr.s_addr = htonl(ifaces[i].li_ipaddr);
-	ksi->ksni_index = ksocknal_ip2index((struct sockaddr *)sa, ni);
 	ksi->ksni_netmask = ifaces[i].li_netmask;
 	strlcpy(ksi->ksni_name, ifaces[i].li_name, sizeof(ksi->ksni_name));
 
diff --git a/net/lnet/lnet/config.c b/net/lnet/lnet/config.c
index da3d20e5bebb..083a9a29697f 100644
--- a/net/lnet/lnet/config.c
+++ b/net/lnet/lnet/config.c
@@ -1538,6 +1538,7 @@ int lnet_inet_enumerate(struct lnet_inetdev **dev_list, struct net *ns)
 
 			ifaces[nip].li_cpt = cpt;
 			ifaces[nip].li_flags = flags;
+			ifaces[nip].li_index = dev->ifindex;
 			ifaces[nip].li_ipaddr = ntohl(ifa->ifa_local);
 			ifaces[nip].li_netmask = ntohl(ifa->ifa_mask);
 			strlcpy(ifaces[nip].li_name, ifa->ifa_label,
-- 
2.27.0

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
