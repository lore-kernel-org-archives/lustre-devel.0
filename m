Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 0AF4AC4332F
	for <lustre-devel@archiver.kernel.org>; Fri, 14 Oct 2022 21:38:57 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4Mq0Bm5Lg3z21Jp;
	Fri, 14 Oct 2022 14:38:56 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4Mq0BD6Wfgz21D4
 for <lustre-devel@lists.lustre.org>; Fri, 14 Oct 2022 14:38:28 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 2FCC3100CA15;
 Fri, 14 Oct 2022 17:38:14 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 2E049DD535; Fri, 14 Oct 2022 17:38:14 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Fri, 14 Oct 2022 17:38:10 -0400
Message-Id: <1665783491-13827-20-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1665783491-13827-1-git-send-email-jsimmons@infradead.org>
References: <1665783491-13827-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 19/20] lnet: o2iblnd: detect link state to
 set fatal error on ni
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
Cc: Serguei Smirnov <ssmirnov@whamcloud.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Serguei Smirnov <ssmirnov@whamcloud.com>

To avoid selecting lnet ni which corresponds to a downed link
for sending, add a mechanism for detecting ip-layer link events
in o2iblnd. On ip link up/down events, find corresponding
ni and toggle ni_fatal_error_on flag. This complements the
existing mechanism for ib-layer link event handling.

WC-bug-id: https://jira.whamcloud.com/browse/LU-16051
Lustre-commit: 30d73908087d5b2f0 ("LU-16051 o2iblnd: detect link state to set fatal error on ni")
Signed-off-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/48644
Reviewed-by: Frank Sehr <fsehr@whamcloud.com>
Reviewed-by: Chris Horn <chris.horn@hpe.com>
Reviewed-by: Cyril Bordage <cbordage@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/klnds/o2iblnd/o2iblnd.c | 219 ++++++++++++++++++++++++++-----
 1 file changed, 186 insertions(+), 33 deletions(-)

diff --git a/net/lnet/klnds/o2iblnd/o2iblnd.c b/net/lnet/klnds/o2iblnd/o2iblnd.c
index c713528a7e7c..d5ca1a3dd25c 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd.c
+++ b/net/lnet/klnds/o2iblnd/o2iblnd.c
@@ -2527,6 +2527,184 @@ void kiblnd_destroy_dev(struct kib_dev *dev)
 	kfree(dev);
 }
 
+static struct kib_dev *
+kiblnd_dev_search(char *ifname)
+{
+	struct kib_dev *alias = NULL;
+	struct kib_dev *dev;
+	char *colon;
+	char *colon2;
+
+	colon = strchr(ifname, ':');
+	list_for_each_entry(dev, &kiblnd_data.kib_devs, ibd_list) {
+		if (strcmp(&dev->ibd_ifname[0], ifname) == 0)
+			return dev;
+
+		if (alias)
+			continue;
+
+		colon2 = strchr(dev->ibd_ifname, ':');
+		if (colon)
+			*colon = 0;
+		if (colon2)
+			*colon2 = 0;
+
+		if (strcmp(&dev->ibd_ifname[0], ifname) == 0)
+			alias = dev;
+
+		if (colon)
+			*colon = ':';
+		if (colon2)
+			*colon2 = ':';
+	}
+	return alias;
+}
+
+static int
+kiblnd_handle_link_state_change(struct net_device *dev,
+				unsigned char operstate)
+{
+	struct lnet_ni *ni = NULL;
+	struct kib_dev *event_kibdev;
+	struct kib_net *net;
+	struct kib_net *cnxt;
+	bool link_down = !(operstate == IF_OPER_UP);
+	struct in_device *in_dev;
+	bool found_ip = false;
+	const struct in_ifaddr *ifa;
+
+	event_kibdev = kiblnd_dev_search(dev->name);
+
+	if (!event_kibdev)
+		goto out;
+
+	list_for_each_entry_safe(net, cnxt, &event_kibdev->ibd_nets, ibn_list) {
+		found_ip = false;
+
+		ni = net->ibn_ni;
+
+		in_dev = __in_dev_get_rtnl(dev);
+		if (!in_dev) {
+			CDEBUG(D_NET, "Interface %s has no IPv4 status.\n",
+			       dev->name);
+			CDEBUG(D_NET, "%s: set link fatal state to 1\n",
+			       libcfs_nidstr(&net->ibn_ni->ni_nid));
+			atomic_set(&ni->ni_fatal_error_on, 1);
+			continue;
+		}
+		in_dev_for_each_ifa_rtnl(ifa, in_dev) {
+			if (htonl(event_kibdev->ibd_ifip) == ifa->ifa_local)
+				found_ip = true;
+		}
+
+		if (!found_ip) {
+			CDEBUG(D_NET, "Interface %s has no matching ip\n",
+			       dev->name);
+			CDEBUG(D_NET, "%s: set link fatal state to 1\n",
+			       libcfs_nidstr(&net->ibn_ni->ni_nid));
+			atomic_set(&ni->ni_fatal_error_on, 1);
+			continue;
+		}
+
+		if (link_down) {
+			CDEBUG(D_NET, "%s: set link fatal state to 1\n",
+			       libcfs_nidstr(&net->ibn_ni->ni_nid));
+			atomic_set(&ni->ni_fatal_error_on, link_down);
+		} else {
+			CDEBUG(D_NET, "%s: set link fatal state to %u\n",
+			       libcfs_nidstr(&net->ibn_ni->ni_nid),
+			       (kiblnd_get_link_status(dev) == 0));
+			atomic_set(&ni->ni_fatal_error_on,
+				   (kiblnd_get_link_status(dev) == 0));
+		}
+	}
+out:
+	return 0;
+}
+
+static int
+kiblnd_handle_inetaddr_change(struct in_ifaddr *ifa, unsigned long event)
+{
+	struct kib_dev *event_kibdev;
+	struct kib_net *net;
+	struct kib_net *cnxt;
+	struct net_device *event_netdev = ifa->ifa_dev->dev;
+
+	event_kibdev = kiblnd_dev_search(event_netdev->name);
+
+	if (!event_kibdev)
+		goto out;
+
+	if (htonl(event_kibdev->ibd_ifip) != ifa->ifa_local)
+		goto out;
+
+	list_for_each_entry_safe(net, cnxt, &event_kibdev->ibd_nets,
+				 ibn_list) {
+		CDEBUG(D_NET, "%s: set link fatal state to %u\n",
+		       libcfs_nidstr(&net->ibn_ni->ni_nid),
+		       (event == NETDEV_DOWN));
+		atomic_set(&net->ibn_ni->ni_fatal_error_on,
+			   (event == NETDEV_DOWN));
+	}
+out:
+	return 0;
+}
+
+/************************************
+ * Net device notifier event handler
+ ************************************/
+static int kiblnd_device_event(struct notifier_block *unused,
+			       unsigned long event, void *ptr)
+{
+	struct net_device *dev = netdev_notifier_info_to_dev(ptr);
+	unsigned char operstate;
+
+	operstate = dev->operstate;
+
+	CDEBUG(D_NET, "devevent: status=%ld, iface=%s ifindex %d state %u\n",
+	       event, dev->name, dev->ifindex, operstate);
+
+	switch (event) {
+	case NETDEV_UP:
+	case NETDEV_DOWN:
+	case NETDEV_CHANGE:
+		kiblnd_handle_link_state_change(dev, operstate);
+		break;
+	}
+
+	return NOTIFY_OK;
+}
+
+/************************************
+ * Inetaddr notifier event handler
+ ************************************/
+static int kiblnd_inetaddr_event(struct notifier_block *unused,
+				 unsigned long event, void *ptr)
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
+		kiblnd_handle_inetaddr_change(ifa, event);
+		break;
+	}
+
+	return NOTIFY_OK;
+}
+
+static struct notifier_block kiblnd_dev_notifier_block = {
+	.notifier_call = kiblnd_device_event,
+};
+
+static struct notifier_block kiblnd_inetaddr_notifier_block = {
+	.notifier_call = kiblnd_inetaddr_event,
+};
+
 static void kiblnd_base_shutdown(void)
 {
 	struct kib_sched_info *sched;
@@ -2535,6 +2713,11 @@ static void kiblnd_base_shutdown(void)
 
 	LASSERT(list_empty(&kiblnd_data.kib_devs));
 
+	if (kiblnd_data.kib_init == IBLND_INIT_ALL) {
+		unregister_netdevice_notifier(&kiblnd_dev_notifier_block);
+		unregister_inetaddr_notifier(&kiblnd_inetaddr_notifier_block);
+	}
+
 	switch (kiblnd_data.kib_init) {
 	default:
 		LBUG();
@@ -2723,6 +2906,9 @@ static int kiblnd_base_startup(struct net *ns)
 		goto failed;
 	}
 
+	register_netdevice_notifier(&kiblnd_dev_notifier_block);
+	register_inetaddr_notifier(&kiblnd_inetaddr_notifier_block);
+
 	/* flag everything initialised */
 	kiblnd_data.kib_init = IBLND_INIT_ALL;
 	/*****************************************************/
@@ -2799,39 +2985,6 @@ static int kiblnd_dev_start_threads(struct kib_dev *dev, bool newdev, u32 *cpts,
 	return 0;
 }
 
-static struct kib_dev *
-kiblnd_dev_search(char *ifname)
-{
-	struct kib_dev *alias = NULL;
-	struct kib_dev *dev;
-	char            *colon;
-	char            *colon2;
-
-	colon = strchr(ifname, ':');
-	list_for_each_entry(dev, &kiblnd_data.kib_devs, ibd_list) {
-		if (strcmp(&dev->ibd_ifname[0], ifname) == 0)
-			return dev;
-
-		if (alias)
-			continue;
-
-		colon2 = strchr(dev->ibd_ifname, ':');
-		if (colon)
-			*colon = 0;
-		if (colon2)
-			*colon2 = 0;
-
-		if (strcmp(&dev->ibd_ifname[0], ifname) == 0)
-			alias = dev;
-
-		if (colon)
-			*colon = ':';
-		if (colon2)
-			*colon2 = ':';
-	}
-	return alias;
-}
-
 static int kiblnd_startup(struct lnet_ni *ni)
 {
 	char *ifname = NULL;
-- 
2.27.0

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
