Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 0BAFCC0219D
	for <lustre-devel@archiver.kernel.org>; Sat,  8 Feb 2025 00:41:20 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4YqWyB48fTz1yWh;
	Fri, 07 Feb 2025 16:32:34 -0800 (PST)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4YqWwB3HXRz1xqB
 for <lustre-devel@lists.lustre.org>; Fri, 07 Feb 2025 16:30:50 -0800 (PST)
Received: from star2.ccs.ornl.gov (ltm-e204-208.ccs.ornl.gov [160.91.203.12])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 346C8899AD6;
 Fri,  7 Feb 2025 19:30:33 -0500 (EST)
Received: by star2.ccs.ornl.gov (Postfix, from userid 2004)
 id 324AD106BE14; Fri,  7 Feb 2025 19:30:33 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Fri,  7 Feb 2025 19:30:27 -0500
Message-ID: <20250208003027.180076-22-jsimmons@infradead.org>
X-Mailer: git-send-email 2.43.5
In-Reply-To: <20250208003027.180076-1-jsimmons@infradead.org>
References: <20250208003027.180076-1-jsimmons@infradead.org>
MIME-Version: 1.0
Subject: [lustre-devel] [PATCH 21/21] lnet: ensure dev notification on lnd
 startup
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
Cc: Frank Sehr <fsehr@whamcloud.com>, Cyril Bordage <cbordage@whamcloud.com>,
 Serguei Smirnov <ssmirnov@whamcloud.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Serguei Smirnov <ssmirnov@whamcloud.com>

Look up device and link state on lnd startup so that
the initial NI state may be set properly.

Reduce code duplication by adding lnet_set_link_fatal_state() and
lnet_get_link_status() functions which are shared across LNDs.
LND-specific versions of these are removed.

This fixes the issue with adding LNet NI using an interface with
cable unplugged which results in the NI state initialized as "up".

Fixes: 91f28da387 ("lnet: use discovered ni status to set initial health")
WC-bug-id: https://jira.whamcloud.com/browse/LU-16836
Lustre-commit: 09c6e2b872287c847 ("LU-16836 lnet: ensure dev notification on lnd startup")
Signed-off-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/51057
Reviewed-by: Frank Sehr <fsehr@whamcloud.com>
Reviewed-by: Cyril Bordage <cbordage@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/lib-lnet.h    |   2 +
 net/lnet/klnds/o2iblnd/o2iblnd.c |  76 ++++++++----------
 net/lnet/klnds/socklnd/socklnd.c | 131 ++++++++++++++++++++++---------
 net/lnet/lnet/config.c           |  32 ++++++++
 4 files changed, 161 insertions(+), 80 deletions(-)

diff --git a/include/linux/lnet/lib-lnet.h b/include/linux/lnet/lib-lnet.h
index 09cf42995f39..ce4ad5ae7eb7 100644
--- a/include/linux/lnet/lib-lnet.h
+++ b/include/linux/lnet/lib-lnet.h
@@ -880,6 +880,8 @@ void lnet_swap_pinginfo(struct lnet_ping_buffer *pbuf);
 int lnet_ping_info_validate(struct lnet_ping_info *pinfo);
 struct lnet_ping_buffer *lnet_ping_buffer_alloc(int bytes, gfp_t gfp);
 void lnet_ping_buffer_free(struct lnet_ping_buffer *pbuf);
+int lnet_get_link_status(struct net_device *dev);
+u32 lnet_set_link_fatal_state(struct lnet_ni *ni, unsigned int link_state);
 
 static inline void lnet_ping_buffer_addref(struct lnet_ping_buffer *pbuf)
 {
diff --git a/net/lnet/klnds/o2iblnd/o2iblnd.c b/net/lnet/klnds/o2iblnd/o2iblnd.c
index fc59f88f0801..c954df32ab50 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd.c
+++ b/net/lnet/klnds/o2iblnd/o2iblnd.c
@@ -1673,21 +1673,6 @@ static void kiblnd_fini_fmr_poolset(struct kib_fmr_poolset *fps)
 	}
 }
 
-static int kiblnd_get_link_status(struct net_device *dev)
-{
-	int ret = -1;
-
-	LASSERT(dev);
-
-	if (!netif_running(dev))
-		ret = 0;
-	/* Some devices may not be providing link settings */
-	else if (dev->ethtool_ops->get_link)
-		ret = dev->ethtool_ops->get_link(dev);
-
-	return ret;
-}
-
 static int
 kiblnd_init_fmr_poolset(struct kib_fmr_poolset *fps, int cpt, int ncpts,
 			struct kib_net *net,
@@ -2385,15 +2370,19 @@ kiblnd_set_ni_fatal_on(struct kib_hca_dev *hdev, int val)
 	struct kib_net *net;
 	u32 ni_state_before;
 	bool update_ping_buf = false;
+	struct lnet_ni *ni = NULL;
 
 	/* for health check */
 	list_for_each_entry(net, &hdev->ibh_dev->ibd_nets, ibn_list) {
+		ni = net->ibn_ni;
 		if (val)
 			CDEBUG(D_NETERROR, "Fatal device error for NI %s\n",
-			       libcfs_nidstr(&net->ibn_ni->ni_nid));
-		ni_state_before = atomic_xchg(&net->ibn_ni->ni_fatal_error_on,
-					      val);
-		if (!update_ping_buf && val != ni_state_before)
+			       libcfs_nidstr(&ni->ni_nid));
+		ni_state_before = lnet_set_link_fatal_state(ni, val);
+
+		if (!update_ping_buf &&
+		    ni->ni_state == LNET_NI_STATE_ACTIVE &&
+		    val != ni_state_before)
 			update_ping_buf = true;
 	}
 
@@ -2689,7 +2678,7 @@ int kiblnd_dev_failover(struct kib_dev *dev, struct net *ns)
 		if (set_fatal) {
 			rcu_read_lock();
 			netdev = dev_get_by_name_rcu(ns, dev->ibd_ifname);
-			if (netdev && (kiblnd_get_link_status(netdev) == 1))
+			if (netdev && (lnet_get_link_status(netdev) == 1))
 				kiblnd_set_ni_fatal_on(dev->ibd_hdev, 0);
 			rcu_read_unlock();
 		}
@@ -2759,6 +2748,7 @@ kiblnd_handle_link_state_change(struct net_device *dev,
 	u32 ni_state_before;
 	bool update_ping_buf = false;
 	const struct in_ifaddr *ifa;
+	int state;
 
 	event_kibdev = kiblnd_dev_search(dev->name);
 
@@ -2773,10 +2763,7 @@ kiblnd_handle_link_state_change(struct net_device *dev,
 		if (!in_dev) {
 			CDEBUG(D_NET, "Interface %s has no IPv4 status.\n",
 			       dev->name);
-			CDEBUG(D_NET, "%s: set link fatal state to 1\n",
-			       libcfs_nidstr(&net->ibn_ni->ni_nid));
-			ni_state_before = atomic_xchg(&ni->ni_fatal_error_on,
-						      1);
+			ni_state_before = lnet_set_link_fatal_state(ni, 1);
 			goto ni_done;
 		}
 		in_dev_for_each_ifa_rtnl(ifa, in_dev) {
@@ -2787,27 +2774,20 @@ kiblnd_handle_link_state_change(struct net_device *dev,
 		if (!found_ip) {
 			CDEBUG(D_NET, "Interface %s has no matching ip\n",
 			       dev->name);
-			CDEBUG(D_NET, "%s: set link fatal state to 1\n",
-			       libcfs_nidstr(&net->ibn_ni->ni_nid));
-			ni_state_before = atomic_xchg(&ni->ni_fatal_error_on,
-						      1);
+			ni_state_before = lnet_set_link_fatal_state(ni, 1);
 			goto ni_done;
 		}
 
 		if (link_down) {
-			CDEBUG(D_NET, "%s: set link fatal state to 1\n",
-			       libcfs_nidstr(&net->ibn_ni->ni_nid));
-			ni_state_before = atomic_xchg(&ni->ni_fatal_error_on,
-						      link_down);
+			ni_state_before = lnet_set_link_fatal_state(ni, 1);
 		} else {
-			CDEBUG(D_NET, "%s: set link fatal state to %u\n",
-			       libcfs_nidstr(&net->ibn_ni->ni_nid),
-			       (kiblnd_get_link_status(dev) == 0));
-			ni_state_before = atomic_xchg(&ni->ni_fatal_error_on,
-						      (kiblnd_get_link_status(dev) == 0));
+			state = (lnet_get_link_status(dev) == 0);
+			ni_state_before = lnet_set_link_fatal_state(ni,
+								    state);
 		}
 ni_done:
 		if (!update_ping_buf &&
+		    (ni->ni_state == LNET_NI_STATE_ACTIVE) &&
 		    (atomic_read(&ni->ni_fatal_error_on) != ni_state_before))
 			update_ping_buf = true;
 	}
@@ -2827,6 +2807,8 @@ kiblnd_handle_inetaddr_change(struct in_ifaddr *ifa, unsigned long event)
 	struct net_device *event_netdev = ifa->ifa_dev->dev;
 	u32 ni_state_before;
 	bool update_ping_buf = false;
+	struct lnet_ni *ni = NULL;
+	bool link_down;
 
 	event_kibdev = kiblnd_dev_search(event_netdev->name);
 
@@ -2838,12 +2820,11 @@ kiblnd_handle_inetaddr_change(struct in_ifaddr *ifa, unsigned long event)
 
 	list_for_each_entry_safe(net, cnxt, &event_kibdev->ibd_nets,
 				 ibn_list) {
-		CDEBUG(D_NET, "%s: set link fatal state to %u\n",
-		       libcfs_nidstr(&net->ibn_ni->ni_nid),
-		       (event == NETDEV_DOWN));
-		ni_state_before = atomic_xchg(&net->ibn_ni->ni_fatal_error_on,
-					      (event == NETDEV_DOWN));
+		ni = net->ibn_ni;
+		link_down = (event == NETDEV_DOWN);
+		ni_state_before = lnet_set_link_fatal_state(ni, link_down);
 		if (!update_ping_buf &&
+		    (ni->ni_state == LNET_NI_STATE_ACTIVE) &&
 		    ((event == NETDEV_DOWN) != ni_state_before))
 			update_ping_buf = true;
 	}
@@ -3199,6 +3180,7 @@ static int kiblnd_startup(struct lnet_ni *ni)
 	int rc;
 	int i;
 	bool newdev;
+	struct net_device *netdev;
 
 	LASSERT(ni->ni_net->net_lnd == &the_o2iblnd);
 
@@ -3312,6 +3294,16 @@ static int kiblnd_startup(struct lnet_ni *ni)
 	/* for health check */
 	if (ibdev->ibd_hdev->ibh_state == IBLND_DEV_PORT_DOWN)
 		kiblnd_set_ni_fatal_on(ibdev->ibd_hdev, 1);
+
+	rcu_read_lock();
+	netdev = dev_get_by_name_rcu(ni->ni_net_ns, net->ibn_dev->ibd_ifname);
+	if ((netdev->reg_state == NETREG_UNREGISTERING ||
+	     netdev->operstate != IF_OPER_UP) ||
+	    lnet_get_link_status(netdev) == 0) {
+		kiblnd_set_ni_fatal_on(ibdev->ibd_hdev, 1);
+	}
+	rcu_read_unlock();
+
 	write_unlock_irqrestore(&kiblnd_data.kib_global_lock, flags);
 
 	net->ibn_init = IBLND_INIT_ALL;
diff --git a/net/lnet/klnds/socklnd/socklnd.c b/net/lnet/klnds/socklnd/socklnd.c
index 6028520308ff..d8fc20d18d44 100644
--- a/net/lnet/klnds/socklnd/socklnd.c
+++ b/net/lnet/klnds/socklnd/socklnd.c
@@ -47,6 +47,77 @@
 static struct lnet_lnd the_ksocklnd;
 struct ksock_nal_data ksocknal_data;
 
+static int ksocknal_ip2index(struct sockaddr *addr, struct lnet_ni *ni,
+			     int *dev_status)
+{
+	struct net_device *dev;
+	int ret = -1;
+	const struct in_ifaddr *ifa;
+
+	*dev_status = -1;
+
+	if (addr->sa_family != AF_INET && addr->sa_family != AF_INET6)
+		return ret;
+
+	rcu_read_lock();
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
+		switch (addr->sa_family) {
+		case AF_INET:
+			in_dev = __in_dev_get_rcu(dev);
+			if (!in_dev)
+				continue;
+
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
+		}
+		if (ret >= 0)
+			break;
+	}
+
+	rcu_read_unlock();
+	if (ret >= 0)
+		*dev_status = 1;
+
+	if ((ret == -1) ||
+	    (dev->reg_state == NETREG_UNREGISTERING ||
+	     dev->operstate != IF_OPER_UP) ||
+	    (lnet_get_link_status(dev) == 0))
+		*dev_status = 0;
+
+	return ret;
+}
+
 static struct ksock_conn_cb *
 ksocknal_create_conn_cb(struct sockaddr *addr)
 {
@@ -1856,25 +1927,6 @@ ksocknal_free_buffers(void)
 	}
 }
 
-static int ksocknal_get_link_status(struct net_device *dev)
-{
-	int ret = -1;
-
-	LASSERT(dev);
-
-	if (!netif_running(dev)) {
-		ret = 0;
-		CDEBUG(D_NET, "device not running\n");
-	}
-	/* Some devices may not be providing link settings */
-	else if (dev->ethtool_ops->get_link) {
-		ret = dev->ethtool_ops->get_link(dev);
-		CDEBUG(D_NET, "get_link returns %u\n", ret);
-	}
-
-	return ret;
-}
-
 static int
 ksocknal_handle_link_state_change(struct net_device *dev,
 				  unsigned char operstate)
@@ -1891,6 +1943,7 @@ ksocknal_handle_link_state_change(struct net_device *dev,
 	u32 ni_state_before;
 	bool update_ping_buf = false;
 	const struct in_ifaddr *ifa;
+	int state;
 
 	ifindex = dev->ifindex;
 
@@ -1921,7 +1974,7 @@ ksocknal_handle_link_state_change(struct net_device *dev,
 			continue;
 
 		if (dev->reg_state == NETREG_UNREGISTERING) {
-			/* Device is being unregitering, we need to clear the
+			/* Device is being unregitered, we need to clear the
 			 * index, it can change when device will be back
 			 */
 			ksi->ksni_index = -1;
@@ -1934,9 +1987,7 @@ ksocknal_handle_link_state_change(struct net_device *dev,
 		if (!in_dev) {
 			CDEBUG(D_NET, "Interface %s has no IPv4 status.\n",
 			       dev->name);
-			CDEBUG(D_NET, "set link fatal state to 1\n");
-			ni_state_before = atomic_xchg(&ni->ni_fatal_error_on,
-						      1);
+			ni_state_before = lnet_set_link_fatal_state(ni, 1);
 			goto ni_done;
 		}
 		in_dev_for_each_ifa_rtnl(ifa, in_dev) {
@@ -1947,24 +1998,20 @@ ksocknal_handle_link_state_change(struct net_device *dev,
 		if (!found_ip) {
 			CDEBUG(D_NET, "Interface %s has no matching ip\n",
 			       dev->name);
-			CDEBUG(D_NET, "set link fatal state to 1\n");
-			ni_state_before = atomic_xchg(&ni->ni_fatal_error_on,
-						      1);
+			ni_state_before = lnet_set_link_fatal_state(ni, 1);
 			goto ni_done;
 		}
 
 		if (link_down) {
-			CDEBUG(D_NET, "set link fatal state to 1\n");
-			ni_state_before = atomic_xchg(&ni->ni_fatal_error_on,
-						      1);
+			ni_state_before = lnet_set_link_fatal_state(ni, 1);
 		} else {
-			CDEBUG(D_NET, "set link fatal state to %u\n",
-			       (ksocknal_get_link_status(dev) == 0));
-			ni_state_before = atomic_xchg(&ni->ni_fatal_error_on,
-						      (ksocknal_get_link_status(dev) == 0));
+			state = (lnet_get_link_status(dev) == 0);
+			ni_state_before = lnet_set_link_fatal_state(ni,
+								    state);
 		}
 ni_done:
 		if (!update_ping_buf &&
+		    (ni->ni_state == LNET_NI_STATE_ACTIVE) &&
 		    (atomic_read(&ni->ni_fatal_error_on) != ni_state_before))
 			update_ping_buf = true;
 	}
@@ -1979,7 +2026,7 @@ ksocknal_handle_link_state_change(struct net_device *dev,
 static int
 ksocknal_handle_inetaddr_change(struct in_ifaddr *ifa, unsigned long event)
 {
-	struct lnet_ni *ni;
+	struct lnet_ni *ni = NULL;
 	struct ksock_net *net;
 	struct ksock_net *cnxt;
 	struct net_device *event_netdev = ifa->ifa_dev->dev;
@@ -1988,6 +2035,7 @@ ksocknal_handle_inetaddr_change(struct in_ifaddr *ifa, unsigned long event)
 	struct sockaddr_in *sa;
 	u32 ni_state_before;
 	bool update_ping_buf = false;
+	bool link_down;
 
 	if (!ksocknal_data.ksnd_nnets)
 		goto out;
@@ -2005,12 +2053,13 @@ ksocknal_handle_inetaddr_change(struct in_ifaddr *ifa, unsigned long event)
 			continue;
 
 		if (sa->sin_addr.s_addr == ifa->ifa_local) {
-			CDEBUG(D_NET, "set link fatal state to %u\n",
-			       (event == NETDEV_DOWN));
 			ni = net->ksnn_ni;
-			ni_state_before = atomic_xchg(&ni->ni_fatal_error_on,
-						      (event == NETDEV_DOWN));
+			link_down = (event == NETDEV_DOWN);
+			ni_state_before = lnet_set_link_fatal_state(ni,
+								    link_down);
+
 			if (!update_ping_buf &&
+			    (ni->ni_state == LNET_NI_STATE_ACTIVE) &&
 			    ((event == NETDEV_DOWN) != ni_state_before))
 				update_ping_buf = true;
 		}
@@ -2455,6 +2504,7 @@ ksocknal_startup(struct lnet_ni *ni)
 	struct ksock_interface *ksi = NULL;
 	struct lnet_inetdev *ifaces = NULL;
 	int rc, if_idx;
+	int dev_status;
 
 	LASSERT(ni->ni_net->net_lnd == &the_ksocklnd);
 
@@ -2521,6 +2571,11 @@ ksocknal_startup(struct lnet_ni *ni)
 	if (rc)
 		goto out_net;
 
+	if (ksocknal_ip2index((struct sockaddr *)&ksi->ksni_addr,
+			      ni, &dev_status) < 0 ||
+	    dev_status <= 0)
+		lnet_set_link_fatal_state(ni, 1);
+
 	list_add(&net->ksnn_list, &ksocknal_data.ksnd_nets);
 	net->ksnn_ni = ni;
 	ksocknal_data.ksnd_nnets++;
diff --git a/net/lnet/lnet/config.c b/net/lnet/lnet/config.c
index c239f9caa0f5..ca498b0670e5 100644
--- a/net/lnet/lnet/config.c
+++ b/net/lnet/lnet/config.c
@@ -34,6 +34,7 @@
 #include <linux/ctype.h>
 #include <linux/inetdevice.h>
 #include <linux/nsproxy.h>
+#include <linux/ethtool.h>
 #include <net/net_namespace.h>
 #include <linux/lnet/lib-lnet.h>
 #include <net/addrconf.h>
@@ -1489,6 +1490,37 @@ lnet_match_networks(const char **networksp, const char *ip2nets,
 	return count;
 }
 
+u32 lnet_set_link_fatal_state(struct lnet_ni *ni, unsigned int link_state)
+{
+	CDEBUG(D_NET, "%s: set link fatal state to %u\n",
+	       libcfs_nidstr(&ni->ni_nid), link_state);
+	return atomic_xchg(&ni->ni_fatal_error_on, link_state);
+}
+EXPORT_SYMBOL(lnet_set_link_fatal_state);
+
+int lnet_get_link_status(struct net_device *dev)
+{
+	int ret = -1;
+
+	if (!dev)
+		return -1;
+
+	if (!netif_running(dev)) {
+		ret = 0;
+		CDEBUG(D_NET, "device idx %d not running\n", dev->ifindex);
+	}
+	/* Some devices may not be providing link settings */
+	else if (dev->ethtool_ops->get_link) {
+		ret = dev->ethtool_ops->get_link(dev);
+		CDEBUG(D_NET, "device idx %d get_link %u\n",
+		       ret,
+		       dev->ifindex);
+	}
+
+	return ret;
+}
+EXPORT_SYMBOL(lnet_get_link_status);
+
 int lnet_inet_enumerate(struct lnet_inetdev **dev_list, struct net *ns, bool v6)
 {
 	struct lnet_inetdev *ifaces = NULL;
-- 
2.39.3

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
