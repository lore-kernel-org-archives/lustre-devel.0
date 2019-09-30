From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Sep 2019 14:54:24 -0400
Subject: [lustre-devel] [PATCH 005/151] lnet: consoldate secondary IP
 address handling
In-Reply-To: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1569869810-23848-6-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

The last piece of code with broken secondary IP address
support is lnet_parse_ip2nets(). We could fix it like
o2iblnd or socklnd was done but since the LND drivers
resolved those issues instead we can move the handling
out of the LND drivers into one place in the LNet core.
To do this we introduce struct lnet_inetdev which is
a collection of data that the current LNet layer requires.
The new function lnet_inet_enumerate() is used to collect
this information.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11893
Linux-commit: b770d7117f35a ("LU-11893 lnet: consoldate secondary IP address handling")
Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-on: https://review.whamcloud.com/34993
Reviewed-by: Olaf Weber <olaf.weber@hpe.com>
Reviewed-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/lib-lnet.h    |  10 +++
 net/lnet/klnds/o2iblnd/o2iblnd.c | 167 ++++++++++-----------------------------
 net/lnet/klnds/socklnd/socklnd.c | 121 +++++++++++-----------------
 net/lnet/lnet/config.c           | 121 ++++++++++++++++------------
 4 files changed, 170 insertions(+), 249 deletions(-)

diff --git a/include/linux/lnet/lib-lnet.h b/include/linux/lnet/lib-lnet.h
index e60c446..776896a 100644
--- a/include/linux/lnet/lib-lnet.h
+++ b/include/linux/lnet/lib-lnet.h
@@ -36,6 +36,7 @@
 #ifndef __LNET_LIB_LNET_H__
 #define __LNET_LIB_LNET_H__
 
+#include <linux/netdevice.h>
 #include <linux/libcfs/libcfs.h>
 #include <linux/libcfs/libcfs_cpu.h>
 #include <linux/libcfs/libcfs_string.h>
@@ -649,6 +650,15 @@ void lnet_connect_console_error(int rc, lnet_nid_t peer_nid,
 int lnet_acceptor_start(void);
 void lnet_acceptor_stop(void);
 
+struct lnet_inetdev {
+	u32	li_cpt;
+	u32	li_flags;
+	u32	li_ipaddr;
+	u32	li_netmask;
+	char	li_name[IFNAMSIZ];
+};
+
+int lnet_inet_enumerate(struct lnet_inetdev **dev_list);
 int lnet_sock_setbuf(struct socket *socket, int txbufsize, int rxbufsize);
 int lnet_sock_getbuf(struct socket *socket, int *txbufsize, int *rxbufsize);
 int lnet_sock_getaddr(struct socket *socket, bool remote, u32 *ip, int *port);
diff --git a/net/lnet/klnds/o2iblnd/o2iblnd.c b/net/lnet/klnds/o2iblnd/o2iblnd.c
index e952c0c..d780108 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd.c
+++ b/net/lnet/klnds/o2iblnd/o2iblnd.c
@@ -2553,81 +2553,6 @@ void kiblnd_destroy_dev(struct kib_dev *dev)
 	kfree(dev);
 }
 
-static struct kib_dev *kiblnd_create_dev(char *ifname)
-{
-	const struct in_ifaddr *ifa;
-	struct net_device *netdev;
-	struct kib_dev *dev = NULL;
-	int flags;
-	int rc;
-
-	rtnl_lock();
-	for_each_netdev(&init_net, netdev) {
-		struct in_device *in_dev;
-
-		if (strcmp(netdev->name, "lo") == 0) /* skip the loopback IF */
-			continue;
-
-		flags = dev_get_flags(netdev);
-		if (!(flags & IFF_UP)) {
-			CWARN("Can't query IPoIB interface %s: it's down\n",
-			      netdev->name);
-			continue;
-		}
-
-		in_dev = __in_dev_get_rtnl(netdev);
-		if (!in_dev) {
-			CWARN("Interface %s has no IPv4 status.\n",
-			      netdev->name);
-			continue;
-		}
-
-		in_dev_for_each_ifa_rcu(ifa, in_dev) {
-			if (strcmp(ifname, ifa->ifa_label) == 0) {
-				dev = kzalloc(sizeof(*dev), GFP_NOFS);
-				if (!dev)
-					goto unlock;
-
-				dev->ibd_can_failover = !!(flags & IFF_MASTER);
-				dev->ibd_ifip = ntohl(ifa->ifa_local);
-
-				INIT_LIST_HEAD(&dev->ibd_nets);
-				/* not yet in kib_devs */
-				INIT_LIST_HEAD(&dev->ibd_list);
-				INIT_LIST_HEAD(&dev->ibd_fail_list);
-				break;
-			}
-		}
-	}
-	rtnl_unlock();
-
-	if (!dev) {
-		CERROR("Can't find any usable interfaces\n");
-		return NULL;
-	}
-
-	if (dev->ibd_ifip == 0) {
-		CERROR("Can't initialize device: no IP address\n");
-		goto free_dev;
-	}
-	strcpy(&dev->ibd_ifname[0], ifname);
-
-	/* initialize the device */
-	rc = kiblnd_dev_failover(dev);
-	if (rc) {
-		CERROR("Can't initialize device: %d\n", rc);
-		goto free_dev;
-	}
-
-	list_add_tail(&dev->ibd_list, &kiblnd_data.kib_devs);
-	return dev;
-unlock:
-	rtnl_unlock();
-free_dev:
-	kfree(dev);
-	return NULL;
-}
-
 static void kiblnd_base_shutdown(void)
 {
 	struct kib_sched_info *sched;
@@ -2887,8 +2812,7 @@ static int kiblnd_start_schedulers(struct kib_sched_info *sched)
 	return rc;
 }
 
-static int kiblnd_dev_start_threads(struct kib_dev *dev, int newdev, u32 *cpts,
-				    int ncpts)
+static int kiblnd_dev_start_threads(struct kib_dev *dev, u32 *cpts, int ncpts)
 {
 	int cpt;
 	int rc;
@@ -2900,7 +2824,7 @@ static int kiblnd_dev_start_threads(struct kib_dev *dev, int newdev, u32 *cpts,
 		cpt = !cpts ? i : cpts[i];
 		sched = kiblnd_data.kib_scheds[cpt];
 
-		if (!newdev && sched->ibs_nthreads > 0)
+		if (sched->ibs_nthreads > 0)
 			continue;
 
 		rc = kiblnd_start_schedulers(kiblnd_data.kib_scheds[cpt]);
@@ -2913,47 +2837,15 @@ static int kiblnd_dev_start_threads(struct kib_dev *dev, int newdev, u32 *cpts,
 	return 0;
 }
 
-static struct kib_dev *kiblnd_dev_search(char *ifname)
-{
-	struct kib_dev *alias = NULL;
-	struct kib_dev *dev;
-	char *colon;
-	char *colon2;
-
-	colon = strchr(ifname, ':');
-	list_for_each_entry(dev, &kiblnd_data.kib_devs, ibd_list) {
-		if (!strcmp(&dev->ibd_ifname[0], ifname))
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
-		if (!strcmp(&dev->ibd_ifname[0], ifname))
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
 	char *ifname;
+	struct lnet_inetdev *ifaces = NULL;
 	struct kib_dev *ibdev = NULL;
 	struct kib_net *net;
 	unsigned long flags;
 	int rc;
-	int newdev;
-	int node_id;
+	int i;
 
 	LASSERT(ni->ni_net->net_lnd == &the_o2iblnd);
 
@@ -2981,9 +2873,8 @@ static int kiblnd_startup(struct lnet_ni *ni)
 	if (ni->ni_interfaces[0]) {
 		/* Use the IPoIB interface specified in 'networks=' */
 
-		BUILD_BUG_ON(LNET_INTERFACES_NUM <= 1);
 		if (ni->ni_interfaces[1]) {
-			CERROR("Multiple interfaces not supported\n");
+			CERROR("ko2iblnd: Multiple interfaces not supported\n");
 			goto failed;
 		}
 
@@ -2997,24 +2888,51 @@ static int kiblnd_startup(struct lnet_ni *ni)
 		goto failed;
 	}
 
-	ibdev = kiblnd_dev_search(ifname);
+	rc = lnet_inet_enumerate(&ifaces);
+	if (rc < 0)
+		goto failed;
+
+	for (i = 0; i < rc; i++) {
+		if (strcmp(ifname, ifaces[i].li_name) == 0)
+			break;
+	}
+
+	if (i == rc) {
+		CERROR("ko2iblnd: No matching interfaces\n");
+		rc = -ENOENT;
+		goto failed;
+	}
 
-	newdev = !ibdev;
-	/* hmm...create kib_dev even for alias */
-	if (!ibdev || strcmp(&ibdev->ibd_ifname[0], ifname))
-		ibdev = kiblnd_create_dev(ifname);
+	ibdev = kzalloc(sizeof(*ibdev), GFP_KERNEL);
+	if (!ibdev) {
+		rc = -ENOMEM;
+		goto failed;
+	}
+
+	ibdev->ibd_ifip = ifaces[i].li_ipaddr;
+	strlcpy(ibdev->ibd_ifname, ifaces[i].li_name,
+		sizeof(ibdev->ibd_ifname));
+	ibdev->ibd_can_failover = !!(ifaces[i].li_flags & IFF_MASTER);
 
-	if (!ibdev)
+	INIT_LIST_HEAD(&ibdev->ibd_nets);
+	INIT_LIST_HEAD(&ibdev->ibd_list); /* not yet in kib_devs */
+	INIT_LIST_HEAD(&ibdev->ibd_fail_list);
+
+	/* initialize the device */
+	rc = kiblnd_dev_failover(ibdev);
+	if (rc) {
+		CERROR("ko2iblnd: Can't initialize device: rc = %d\n", rc);
 		goto failed;
+	}
 
-	node_id = dev_to_node(ibdev->ibd_hdev->ibh_ibdev->dma_device);
-	ni->ni_dev_cpt = cfs_cpt_of_node(lnet_cpt_table(), node_id);
+	list_add_tail(&ibdev->ibd_list, &kiblnd_data.kib_devs);
 
 	net->ibn_dev = ibdev;
 	ni->ni_nid = LNET_MKNID(LNET_NIDNET(ni->ni_nid), ibdev->ibd_ifip);
 
-	rc = kiblnd_dev_start_threads(ibdev, newdev,
-				      ni->ni_cpts, ni->ni_ncpts);
+	ni->ni_dev_cpt = ifaces[i].li_cpt;
+
+	rc = kiblnd_dev_start_threads(ibdev, ni->ni_cpts, ni->ni_ncpts);
 	if (rc)
 		goto failed;
 
@@ -3037,6 +2955,7 @@ static int kiblnd_startup(struct lnet_ni *ni)
 	if (!net->ibn_dev && ibdev)
 		kiblnd_destroy_dev(ibdev);
 
+	kfree(ifaces);
 net_failed:
 	kiblnd_shutdown(ni);
 
diff --git a/net/lnet/klnds/socklnd/socklnd.c b/net/lnet/klnds/socklnd/socklnd.c
index 1c957dc..d2c72b0 100644
--- a/net/lnet/klnds/socklnd/socklnd.c
+++ b/net/lnet/klnds/socklnd/socklnd.c
@@ -2602,63 +2602,6 @@ static int ksocknal_push(struct lnet_ni *ni, struct lnet_process_id id)
 }
 
 static int
-ksocknal_enumerate_interfaces(struct ksock_net *net, char *iname)
-{
-	struct net_device *dev;
-
-	rtnl_lock();
-	for_each_netdev(&init_net, dev) {
-		/* The iname specified by a user land configuration can
-		 * map to an ifa_label so always treat iname as an ifa_label.
-		 * If iname is NULL then fall back to the net device name.
-		 */
-		const char *name = iname ? iname : dev->name;
-		const struct in_ifaddr *ifa;
-		struct in_device *in_dev;
-
-		if (strcmp(dev->name, "lo") == 0) /* skip the loopback IF */
-			continue;
-
-		if (!(dev_get_flags(dev) & IFF_UP)) {
-			CWARN("Ignoring interface %s (down)\n", dev->name);
-			continue;
-		}
-
-		in_dev = __in_dev_get_rtnl(dev);
-		if (!in_dev) {
-			CWARN("Interface %s has no IPv4 status.\n", dev->name);
-			continue;
-		}
-
-		in_dev_for_each_ifa_rcu(ifa, in_dev) {
-			if (strcmp(name, ifa->ifa_label) == 0) {
-				int idx = net->ksnn_ninterfaces;
-				struct ksock_interface *ksi;
-
-				if (idx >= ARRAY_SIZE(net->ksnn_interfaces)) {
-					rtnl_unlock();
-					return -E2BIG;
-				}
-
-				ksi = &net->ksnn_interfaces[idx];
-				ksi->ksni_ipaddr = ntohl(ifa->ifa_local);
-				ksi->ksni_netmask = ifa->ifa_mask;
-				strlcpy(ksi->ksni_name,
-					name, sizeof(ksi->ksni_name));
-				net->ksnn_ninterfaces++;
-				break;
-			}
-		}
-	}
-	rtnl_unlock();
-
-	if (net->ksnn_ninterfaces == 0)
-		CERROR("Can't find any usable interfaces\n");
-
-	return net->ksnn_ninterfaces > 0 ? 0 : -ENOENT;
-}
-
-static int
 ksocknal_search_new_ipif(struct ksock_net *net)
 {
 	int new_ipif = 0;
@@ -2777,8 +2720,10 @@ static int ksocknal_push(struct lnet_ni *ni, struct lnet_process_id id)
 ksocknal_startup(struct lnet_ni *ni)
 {
 	struct ksock_net *net;
+	struct ksock_interface *ksi = NULL;
+	struct lnet_inetdev *ifaces = NULL;
+	int i = 0;
 	int rc;
-	int i;
 	struct net_device *net_dev;
 	int node_id;
 
@@ -2809,11 +2754,20 @@ static int ksocknal_push(struct lnet_ni *ni, struct lnet_process_id id)
 		ni->ni_net->net_tunables_set = true;
 	}
 
-	net->ksnn_ninterfaces = 0;
+	rc = lnet_inet_enumerate(&ifaces);
+	if (rc < 0)
+		goto fail_1;
+
 	if (!ni->ni_interfaces[0]) {
-		rc = ksocknal_enumerate_interfaces(net, NULL);
-		if (rc <= 0)
-			goto fail_1;
+		ksi = &net->ksnn_interfaces[0];
+
+		/* Use the first discovered interface */
+		net->ksnn_ninterfaces = 1;
+		ni->ni_dev_cpt = ifaces[0].li_cpt;
+		ksi->ksni_ipaddr = ifaces[0].li_ipaddr;
+		ksi->ksni_netmask = ifaces[0].li_netmask;
+		strlcpy(ksi->ksni_name, ifaces[0].li_name,
+			sizeof(ksi->ksni_name));
 	} else {
 		/* Before Multi-Rail ksocklnd would manage
 		 * multiple interfaces with its own tcp bonding.
@@ -2831,23 +2785,38 @@ static int ksocknal_push(struct lnet_ni *ni, struct lnet_process_id id)
 			if (!ni->ni_interfaces[i])
 				break;
 
-			for (j = 0; j < net->ksnn_ninterfaces;  j++) {
-				struct ksock_interface *ksi;
-
-				ksi = &net->ksnn_interfaces[j];
-
-				if (strcmp(ni->ni_interfaces[i],
-					   ksi->ksni_name) == 0) {
-					CERROR("found duplicate %s\n",
-					       ksi->ksni_name);
+			for (j = 0; j < LNET_INTERFACES_NUM;  j++) {
+				if (i != j && ni->ni_interfaces[j] &&
+				    strcmp(ni->ni_interfaces[i],
+					   ni->ni_interfaces[j]) == 0) {
 					rc = -EEXIST;
+					CERROR("ksocklnd: found duplicate %s at %d and %d, rc = %d\n",
+					       ni->ni_interfaces[i], i, j, rc);
 					goto fail_1;
 				}
 			}
 
-			rc = ksocknal_enumerate_interfaces(net, ni->ni_interfaces[i]);
-			if (rc <= 0)
-				goto fail_1;
+			for (j = 0; j < rc; j++) {
+				if (strcmp(ifaces[j].li_name,
+					   ni->ni_interfaces[i]) != 0)
+					continue;
+
+				ksi = &net->ksnn_interfaces[j];
+				ni->ni_dev_cpt = ifaces[j].li_cpt;
+				ksi->ksni_ipaddr = ifaces[j].li_ipaddr;
+				ksi->ksni_netmask = ifaces[j].li_netmask;
+				strlcpy(ksi->ksni_name, ifaces[j].li_name,
+					sizeof(ksi->ksni_name));
+				net->ksnn_ninterfaces++;
+				break;
+			}
+		}
+
+		/* ni_interfaces don't map to all network interfaces */
+		if (!ksi || net->ksnn_ninterfaces != i) {
+			CERROR("ksocklnd: requested %d but only %d interfaces found\n",
+			       i, net->ksnn_ninterfaces);
+			goto fail_1;
 		}
 	}
 
@@ -2866,8 +2835,8 @@ static int ksocknal_push(struct lnet_ni *ni, struct lnet_process_id id)
 	if (rc)
 		goto fail_1;
 
-	ni->ni_nid = LNET_MKNID(LNET_NIDNET(ni->ni_nid),
-				net->ksnn_interfaces[0].ksni_ipaddr);
+	LASSERT(ksi);
+	ni->ni_nid = LNET_MKNID(LNET_NIDNET(ni->ni_nid), ksi->ksni_ipaddr);
 	list_add(&net->ksnn_list, &ksocknal_data.ksnd_nets);
 
 	ksocknal_data.ksnd_nnets++;
diff --git a/net/lnet/lnet/config.c b/net/lnet/lnet/config.c
index 851b6c0..6dda6e5 100644
--- a/net/lnet/lnet/config.c
+++ b/net/lnet/lnet/config.c
@@ -1560,97 +1560,120 @@ struct lnet_ni *
 	return count;
 }
 
-static int
-lnet_ipaddr_enumerate(u32 **ipaddrsp)
+int lnet_inet_enumerate(struct lnet_inetdev **dev_list)
 {
+	struct lnet_inetdev *ifaces = NULL;
 	struct net_device *dev;
-	u32 *ipaddrs;
-	int nalloc = 64;
-	int nip;
-
-	ipaddrs = kcalloc(nalloc, sizeof(*ipaddrs), GFP_KERNEL);
-	if (!ipaddrs) {
-		CERROR("Can't allocate ipaddrs[%d]\n", nalloc);
-		return -ENOMEM;
-	}
+	int nalloc = 0;
+	int nip = 0;
 
 	rtnl_lock();
 	for_each_netdev(&init_net, dev) {
+		int flags = dev_get_flags(dev);
 		const struct in_ifaddr *ifa;
 		struct in_device *in_dev;
+		int node_id;
+		int cpt;
 
-		if (strcmp(dev->name, "lo") == 0)
+		if (flags & IFF_LOOPBACK) /* skip the loopback IF */
 			continue;
 
-		if (!(dev_get_flags(dev) & IFF_UP)) {
-			CWARN("Ignoring interface %s: it's down\n", dev->name);
+		if (!(flags & IFF_UP)) {
+			CWARN("lnet: Ignoring interface %s: it's down\n",
+			      dev->name);
 			continue;
 		}
 		in_dev = __in_dev_get_rtnl(dev);
 		if (!in_dev) {
-			CWARN("Interface %s has no IPv4 status.\n", dev->name);
+			CWARN("lnet: Interface %s has no IPv4 status.\n",
+			      dev->name);
 			continue;
 		}
 
-		if (nip >= nalloc) {
-			u32 *ipaddrs2;
-			nalloc += nalloc;
-			ipaddrs2 = krealloc(ipaddrs, nalloc * sizeof(*ipaddrs2),
-					    GFP_KERNEL);
-			if (ipaddrs2 == NULL) {
-				kfree(ipaddrs);
-				CERROR("Can't allocate ipaddrs[%d]\n", nalloc);
-				return -ENOMEM;
+		node_id = dev_to_node(&dev->dev);
+		cpt = cfs_cpt_of_node(lnet_cpt_table(), node_id);
+		in_dev_for_each_ifa_rtnl(ifa, in_dev) {
+			if (nip >= nalloc) {
+				struct lnet_inetdev *tmp;
+
+				nalloc += LNET_INTERFACES_NUM;
+				tmp = krealloc(ifaces, nalloc * sizeof(*tmp),
+					       GFP_KERNEL);
+				if (!tmp) {
+					kfree(ifaces);
+					ifaces = NULL;
+					nip = -ENOMEM;
+					goto unlock_rtnl;
+				}
+				ifaces = tmp;
 			}
-			ipaddrs = ipaddrs2;
-		}
 
-		in_dev_for_each_ifa_rcu(ifa, in_dev)
-			if (!(ifa->ifa_flags & IFA_F_SECONDARY) &&
-			    strcmp(ifa->ifa_label, dev->name) == 0) {
-				ipaddrs[nip++] = ifa->ifa_local;
-				break;
-			}
+			ifaces[nip].li_cpt = cpt;
+			ifaces[nip].li_flags = flags;
+			ifaces[nip].li_ipaddr = ntohl(ifa->ifa_local);
+			ifaces[nip].li_netmask = ntohl(ifa->ifa_mask);
+			strlcpy(ifaces[nip].li_name, ifa->ifa_label,
+				sizeof(ifaces[nip].li_name));
+			nip++;
+		}
 	}
+unlock_rtnl:
 	rtnl_unlock();
 
-	*ipaddrsp = ipaddrs;
+	if (nip == 0) {
+		CERROR("lnet: Can't find any usable interfaces, rc = -ENOENT\n");
+		nip = -ENOENT;
+	}
+
+	*dev_list = ifaces;
 	return nip;
 }
+EXPORT_SYMBOL(lnet_inet_enumerate);
 
 int
 lnet_parse_ip2nets(char **networksp, char *ip2nets)
 {
+	struct lnet_inetdev *ifaces = NULL;
 	u32 *ipaddrs = NULL;
-	int nip = lnet_ipaddr_enumerate(&ipaddrs);
+	int nip;
 	int rc;
+	int i;
 
+	nip = lnet_inet_enumerate(&ifaces);
 	if (nip < 0) {
-		LCONSOLE_ERROR_MSG(0x117,
-				   "Error %d enumerating local IP interfaces for ip2nets to match\n",
-				   nip);
+		if (nip != -ENOENT) {
+			LCONSOLE_ERROR_MSG(0x117,
+					   "Error %d enumerating local IP interfaces for ip2nets to match\n",
+					   nip);
+		} else {
+			LCONSOLE_ERROR_MSG(0x118,
+					   "No local IP interfaces for ip2nets to match\n");
+		}
 		return nip;
 	}
 
-	if (!nip) {
-		LCONSOLE_ERROR_MSG(0x118,
-				   "No local IP interfaces for ip2nets to match\n");
-		return -ENOENT;
+	ipaddrs = kcalloc(nip, sizeof(*ipaddrs), GFP_KERNEL);
+	if (!ipaddrs) {
+		rc = -ENOMEM;
+		CERROR("lnet: Can't allocate ipaddrs[%d], rc = %d\n",
+		       nip, rc);
+		goto out_free_addrs;
 	}
 
-	rc = lnet_match_networks(networksp, ip2nets, ipaddrs, nip);
-	kfree(ipaddrs);
+	for (i = 0; i < nip; i++)
+		ipaddrs[i] = ifaces[i].li_ipaddr;
 
+	rc = lnet_match_networks(networksp, ip2nets, ipaddrs, nip);
 	if (rc < 0) {
 		LCONSOLE_ERROR_MSG(0x119, "Error %d parsing ip2nets\n", rc);
-		return rc;
-	}
-
-	if (!rc) {
+	} else if (!rc) {
 		LCONSOLE_ERROR_MSG(0x11a,
 				   "ip2nets does not match any local IP interfaces\n");
-		return -ENOENT;
+		rc = -ENOENT;
 	}
 
-	return 0;
+	kfree(ipaddrs);
+out_free_addrs:
+	kfree(ifaces);
+	return rc > 0 ? 0 : rc;
 }
-- 
1.8.3.1
