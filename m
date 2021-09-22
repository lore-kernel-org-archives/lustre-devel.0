Return-Path: <SRS0=2ypu=OM=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4EE4BC433FE
	for <lustre-devel@archiver.kernel.org>; Wed, 22 Sep 2021 02:21:01 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 123C860F4C
	for <lustre-devel@archiver.kernel.org>; Wed, 22 Sep 2021 02:21:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.1 mail.kernel.org 123C860F4C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id C12CB21C8F2;
	Tue, 21 Sep 2021 19:21:00 -0700 (PDT)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 995D921F268
 for <lustre-devel@lists.lustre.org>; Tue, 21 Sep 2021 19:20:10 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 2DA6F475;
 Tue, 21 Sep 2021 22:20:04 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 2ACC7FF4BC; Tue, 21 Sep 2021 22:20:04 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Tue, 21 Sep 2021 22:19:53 -0400
Message-Id: <1632277201-6920-17-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1632277201-6920-1-git-send-email-jsimmons@infradead.org>
References: <1632277201-6920-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 16/24] lnet: socklnd: fix link state detection
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

Due to matching only the device index, link detection implemented
in LU-14742 has issues with confusing the link events for the
virtual interfaces with the link events for the interface that
LNet was actually configured to use. Fix this by improving
the identification of the event source: use both device name and
device index.

Also, to make sure the link fatal state is cleared only when
the device is bound to the IP address used at NI creation,
subscribe to inetaddr events in addition to the netdev events.

Fixes: 1db29e184712 ("lnet: socklnd: detect link state to set fatal error on ni")
WC-bug-id: https://jira.whamcloud.com/browse/LU-14954
Lustre-commit: 008795508d65bb40b ("LU-14954 socklnd: fix link state detection")
Signed-off-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/44732
Reviewed-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-by: Cyril Bordage <cbordage@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/klnds/socklnd/socklnd.c | 132 ++++++++++++++++++++++++++++++++++++---
 1 file changed, 122 insertions(+), 10 deletions(-)

diff --git a/net/lnet/klnds/socklnd/socklnd.c b/net/lnet/klnds/socklnd/socklnd.c
index 7397ac7..b014aa8 100644
--- a/net/lnet/klnds/socklnd/socklnd.c
+++ b/net/lnet/klnds/socklnd/socklnd.c
@@ -1896,11 +1896,15 @@ static int ksocknal_get_link_status(struct net_device *dev)
 
 	LASSERT(dev);
 
-	if (!netif_running(dev))
+	if (!netif_running(dev)) {
 		ret = 0;
+		CDEBUG(D_NET, "device not running\n");
+	}
 	/* Some devices may not be providing link settings */
-	else if (dev->ethtool_ops->get_link)
+	else if (dev->ethtool_ops->get_link) {
 		ret = dev->ethtool_ops->get_link(dev);
+		CDEBUG(D_NET, "get_link returns %u\n", ret);
+	}
 
 	return ret;
 }
@@ -1909,11 +1913,16 @@ static int ksocknal_get_link_status(struct net_device *dev)
 ksocknal_handle_link_state_change(struct net_device *dev,
 				  unsigned char operstate)
 {
-	struct lnet_ni *ni;
+	struct lnet_ni *ni = NULL;
 	struct ksock_net *net;
 	struct ksock_net *cnxt;
 	int ifindex;
 	unsigned char link_down = !(operstate == IF_OPER_UP);
+	struct in_device *in_dev;
+	bool found_ip = false;
+	struct ksock_interface *ksi = NULL;
+	struct sockaddr_in *sa;
+	const struct in_ifaddr *ifa;
 
 	ifindex = dev->ifindex;
 
@@ -1922,20 +1931,91 @@ static int ksocknal_get_link_status(struct net_device *dev)
 
 	list_for_each_entry_safe(net, cnxt, &ksocknal_data.ksnd_nets,
 				 ksnn_list) {
-		if (net->ksnn_interface.ksni_index != ifindex)
+
+		ksi = &net->ksnn_interface;
+		sa = (void *)&ksi->ksni_addr;
+		found_ip = false;
+
+		if (ksi->ksni_index != ifindex ||
+		    strcmp(ksi->ksni_name, dev->name))
 			continue;
+
 		ni = net->ksnn_ni;
-		if (link_down)
+
+		in_dev = __in_dev_get_rtnl(dev);
+		if (!in_dev) {
+			CDEBUG(D_NET, "Interface %s has no IPv4 status.\n",
+			       dev->name);
+			CDEBUG(D_NET, "set link fatal state to 1\n");
+			atomic_set(&ni->ni_fatal_error_on, 1);
+			continue;
+		}
+		in_dev_for_each_ifa_rtnl(ifa, in_dev) {
+			if (sa->sin_addr.s_addr == ifa->ifa_local)
+				found_ip = true;
+		}
+
+		if (!found_ip) {
+			CDEBUG(D_NET, "Interface %s has no matching ip\n",
+			       dev->name);
+			CDEBUG(D_NET, "set link fatal state to 1\n");
+			atomic_set(&ni->ni_fatal_error_on, 1);
+			continue;
+		}
+
+		if (link_down) {
+			CDEBUG(D_NET, "set link fatal state to 1\n");
 			atomic_set(&ni->ni_fatal_error_on, link_down);
-		else
+		} else {
+			CDEBUG(D_NET, "set link fatal state to %u\n",
+			       (ksocknal_get_link_status(dev) == 0));
 			atomic_set(&ni->ni_fatal_error_on,
 				   (ksocknal_get_link_status(dev) == 0));
+		}
 	}
 out:
 	return 0;
 }
 
 
+static int
+ksocknal_handle_inetaddr_change(struct in_ifaddr *ifa, unsigned long event)
+{
+	struct lnet_ni *ni;
+	struct ksock_net *net;
+	struct ksock_net *cnxt;
+	struct net_device *event_netdev = ifa->ifa_dev->dev;
+	int ifindex;
+	struct ksock_interface *ksi = NULL;
+	struct sockaddr_in *sa;
+
+	if (!ksocknal_data.ksnd_nnets)
+		goto out;
+
+	ifindex = event_netdev->ifindex;
+
+	list_for_each_entry_safe(net, cnxt, &ksocknal_data.ksnd_nets,
+				 ksnn_list) {
+
+		ksi = &net->ksnn_interface;
+		sa = (void *)&ksi->ksni_addr;
+
+		if (ksi->ksni_index != ifindex ||
+		    strcmp(ksi->ksni_name, event_netdev->name))
+			continue;
+
+		if (sa->sin_addr.s_addr == ifa->ifa_local) {
+			CDEBUG(D_NET, "set link fatal state to %u\n",
+			       (event == NETDEV_DOWN));
+			ni = net->ksnn_ni;
+			atomic_set(&ni->ni_fatal_error_on,
+				   (event == NETDEV_DOWN));
+		}
+	}
+out:
+	return 0;
+}
+
 /************************************
  * Net device notifier event handler
  ************************************/
@@ -1947,6 +2027,9 @@ static int ksocknal_device_event(struct notifier_block *unused,
 
 	operstate = dev->operstate;
 
+	CDEBUG(D_NET, "devevent: status=%ld, iface=%s ifindex %d state %u\n",
+	       event, dev->name, dev->ifindex, operstate);
+
 	switch (event) {
 	case NETDEV_UP:
 	case NETDEV_DOWN:
@@ -1958,10 +2041,36 @@ static int ksocknal_device_event(struct notifier_block *unused,
 	return NOTIFY_OK;
 }
 
-static struct notifier_block ksocknal_notifier_block = {
+/************************************
+ * Inetaddr notifier event handler
+ ************************************/
+static int ksocknal_inetaddr_event(struct notifier_block *unused,
+				   unsigned long event, void *ptr)
+{
+	struct in_ifaddr *ifa = ptr;
+
+	CDEBUG(D_NET, "addrevent: status %ld ip addr %pI4, netmask %pI4.\n",
+	       event, &ifa->ifa_address, &ifa->ifa_mask);
+
+	switch (event) {
+	case NETDEV_UP:
+	case NETDEV_DOWN:
+	case NETDEV_CHANGE:
+		ksocknal_handle_inetaddr_change(ifa, event);
+		break;
+
+	}
+	return NOTIFY_OK;
+}
+
+static struct notifier_block ksocknal_dev_notifier_block = {
 	.notifier_call = ksocknal_device_event,
 };
 
+static struct notifier_block ksocknal_inetaddr_notifier_block = {
+	.notifier_call = ksocknal_inetaddr_event,
+};
+
 static void
 ksocknal_base_shutdown(void)
 {
@@ -1971,8 +2080,10 @@ static int ksocknal_device_event(struct notifier_block *unused,
 
 	LASSERT(!ksocknal_data.ksnd_nnets);
 
-	if (ksocknal_data.ksnd_init == SOCKNAL_INIT_ALL)
-		unregister_netdevice_notifier(&ksocknal_notifier_block);
+	if (ksocknal_data.ksnd_init == SOCKNAL_INIT_ALL) {
+		unregister_netdevice_notifier(&ksocknal_dev_notifier_block);
+		unregister_inetaddr_notifier(&ksocknal_inetaddr_notifier_block);
+	}
 
 	switch (ksocknal_data.ksnd_init) {
 	default:
@@ -2135,7 +2246,8 @@ static int ksocknal_device_event(struct notifier_block *unused,
 		goto failed;
 	}
 
-	register_netdevice_notifier(&ksocknal_notifier_block);
+	register_netdevice_notifier(&ksocknal_dev_notifier_block);
+	register_inetaddr_notifier(&ksocknal_inetaddr_notifier_block);
 
 	/* flag everything initialised */
 	ksocknal_data.ksnd_init = SOCKNAL_INIT_ALL;
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
