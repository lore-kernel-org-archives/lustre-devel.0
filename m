Return-Path: <SRS0=6+cL=NO=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B4987C4320A
	for <lustre-devel@archiver.kernel.org>; Mon, 23 Aug 2021 02:28:19 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 725A2611F2
	for <lustre-devel@archiver.kernel.org>; Mon, 23 Aug 2021 02:28:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.1 mail.kernel.org 725A2611F2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id A7F0121E059;
	Sun, 22 Aug 2021 19:28:06 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 297F321CAB2
 for <lustre-devel@lists.lustre.org>; Sun, 22 Aug 2021 19:27:54 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 39ECD100BB05;
 Sun, 22 Aug 2021 22:27:48 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 36ECFB6C92; Sun, 22 Aug 2021 22:27:48 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 22 Aug 2021 22:27:45 -0400
Message-Id: <1629685666-4533-15-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1629685666-4533-1-git-send-email-jsimmons@infradead.org>
References: <1629685666-4533-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 14/15] lnet: socklnd: set conns_per_peer
 based on link speed
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

Specifying conns_per_peer=0 for a ni is now used to set
the conns_per_peer as a function of the corresponding link speed
as follows:
    conns_per_peer = (ilog2(Gbps) / 2 + 1)

Listed below are the resulting defaults for common link speeds:
    100Gbps, 200Gbps    -> 4
    50Gbps              -> 3
    5Gbps, 10Gbps       -> 2
    less than 4Gbps     -> 1

WC-bug-id: https://jira.whamcloud.com/browse/LU-12815
Lustre-commit: c44afcfb72a1c2fd ("LU-12815 socklnd: set conns_per_peer based on link speed")
Signed-off-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/44417
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/klnds/socklnd/socklnd_modparams.c | 75 +++++++++++++++++++++++++++++-
 1 file changed, 73 insertions(+), 2 deletions(-)

diff --git a/net/lnet/klnds/socklnd/socklnd_modparams.c b/net/lnet/klnds/socklnd/socklnd_modparams.c
index c6cce1e..72f9df2 100644
--- a/net/lnet/klnds/socklnd/socklnd_modparams.c
+++ b/net/lnet/klnds/socklnd/socklnd_modparams.c
@@ -23,6 +23,8 @@
 #if defined(__x86_64__) || defined(__i386__)
 #include <asm/hypervisor.h>
 #endif
+#include <linux/inetdevice.h>
+#include <linux/ethtool.h>
 
 #define CURRENT_LND_VERSION 1
 
@@ -154,6 +156,75 @@
 struct ksock_tunables ksocknal_tunables;
 static struct lnet_ioctl_config_socklnd_tunables default_tunables;
 
+static int ksocklnd_ni_get_eth_intf_speed(struct lnet_ni *ni)
+{
+	const struct in_ifaddr *ifa;
+	struct net_device *dev;
+	int intf_idx = -1;
+	int ret = -1;
+
+	rtnl_lock();
+	for_each_netdev(ni->ni_net_ns, dev) {
+		int flags = dev_get_flags(dev);
+		struct in_device *in_dev;
+
+		if (flags & IFF_LOOPBACK) /* skip the loopback IF */
+			continue;
+
+		if (!(flags & IFF_UP))
+			continue;
+
+		in_dev = __in_dev_get_rcu(dev);
+		if (!in_dev)
+			continue;
+
+		in_dev_for_each_ifa_rcu(ifa, in_dev) {
+			if (strcmp(ifa->ifa_label, ni->ni_interface) == 0)
+				intf_idx = dev->ifindex;
+		}
+		if (intf_idx >= 0)
+			break;
+	}
+	if (intf_idx >= 0) {
+		struct ethtool_link_ksettings cmd;
+		int ethtool_ret;
+
+		/* Some devices may not be providing link settings */
+		ethtool_ret = __ethtool_get_link_ksettings(dev, &cmd);
+		if (!ethtool_ret)
+			ret = cmd.base.speed;
+		else
+			ret = ethtool_ret;
+	}
+	rtnl_unlock();
+
+	return ret;
+}
+
+static int ksocklnd_speed2cpp(int speed)
+{
+	/* Use the minimum of 1Gbps to avoid calling ilog2 with 0 */
+	if (speed < 1000)
+		speed = 1000;
+
+	/* Pick heuristically optimal conns_per_peer value
+	 * for the specified ethernet interface speed (Mbps)
+	 */
+	return ilog2(speed / 1000) / 2 + 1;
+}
+
+static int ksocklnd_lookup_conns_per_peer(struct lnet_ni *ni)
+{
+	int cpp = DEFAULT_CONNS_PER_PEER;
+	int speed = ksocklnd_ni_get_eth_intf_speed(ni);
+
+	CDEBUG(D_NET, "intf %s speed %d\n", ni->ni_interface, speed);
+	if (speed > 0)
+		cpp = ksocklnd_speed2cpp(speed);
+
+	return cpp;
+}
+
 int ksocknal_tunables_init(void)
 {
 	default_tunables.lnd_version = CURRENT_LND_VERSION;
@@ -248,6 +319,6 @@ void ksocknal_tunables_setup(struct lnet_ni *ni)
 			*ksocknal_tunables.ksnd_peerrtrcredits;
 
 	if (!tunables->lnd_conns_per_peer)
-		tunables->lnd_conns_per_peer = (conns_per_peer) ?
-			conns_per_peer : DEFAULT_CONNS_PER_PEER;
+		tunables->lnd_conns_per_peer =
+			ksocklnd_lookup_conns_per_peer(ni);
 }
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
