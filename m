Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id A3DF7ECAAA1
	for <lustre-devel@archiver.kernel.org>; Thu, 27 Oct 2022 14:09:54 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4MynXz2pygz1y5x;
	Thu, 27 Oct 2022 07:06:43 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4MynWv3vkVz1wLC
 for <lustre-devel@lists.lustre.org>; Thu, 27 Oct 2022 07:05:47 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 6E2C810090F4;
 Thu, 27 Oct 2022 10:05:44 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 65A39FD4E9; Thu, 27 Oct 2022 10:05:44 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Thu, 27 Oct 2022 10:05:29 -0400
Message-Id: <1666879542-10737-3-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1666879542-10737-1-git-send-email-jsimmons@infradead.org>
References: <1666879542-10737-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 02/15] lnet: support IPv6 in
 lnet_inet_enumerate()
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

lnet_inet_enumerate() can now optionally report IPv6 addresses on
interfaces.  We use this in socklnd to determine the address of the
interface.

Unlike IPv4, different IPv6 addresses associated with a single
interface cannot be associated with different labels (e.g. eth0:2).
This means that lnet_inet_enumerate() must report the same name for
each address.  For now, we only report the first non-temporary address
to avoid any confusion.

The network mask provided with IPv4 is only use for reporting
information for an ioctl.  It isn't clear this will be useful for
IPv6, so no netmask is collected.

To save a bit of space in struct lnet_inetdev{} which much now hold a
16byte address, we replace he 4byte flag with a 1byte bool as only the
IFF_MASTER flag is ever of interest.  Another bool is needed to report
of the address is IPv6.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10391
Lustre-commit: 781499eee645a635d ("LU-10391 lnet: support IPv6 in lnet_inet_enumerate()")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/48572
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/lib-lnet.h    | 15 +++++---
 net/lnet/klnds/o2iblnd/o2iblnd.c |  4 +--
 net/lnet/klnds/socklnd/socklnd.c | 39 +++++++++++++-------
 net/lnet/lnet/config.c           | 77 ++++++++++++++++++++++++++++++++++------
 4 files changed, 105 insertions(+), 30 deletions(-)

diff --git a/include/linux/lnet/lib-lnet.h b/include/linux/lnet/lib-lnet.h
index eb48d29..bd4acef 100644
--- a/include/linux/lnet/lib-lnet.h
+++ b/include/linux/lnet/lib-lnet.h
@@ -823,14 +823,21 @@ void lnet_connect_console_error(int rc, struct lnet_nid *peer_nid,
 
 struct lnet_inetdev {
 	u32	li_cpt;
-	u32	li_flags;
-	u32	li_ipaddr;
-	u32	li_netmask;
+	union {
+		struct {
+			u32	li_ipaddr;
+			u32	li_netmask;
+		};
+		u32	li_ipv6addr[4];
+	};
 	u32	li_index;
+	bool	li_iff_master;
+	bool	li_ipv6;
 	char	li_name[IFNAMSIZ];
 };
 
-int lnet_inet_enumerate(struct lnet_inetdev **dev_list, struct net *ns);
+int lnet_inet_enumerate(struct lnet_inetdev **dev_list, struct net *ns,
+			bool v6);
 void lnet_sock_setbuf(struct socket *socket, int txbufsize, int rxbufsize);
 void lnet_sock_getbuf(struct socket *socket, int *txbufsize, int *rxbufsize);
 int lnet_sock_getaddr(struct socket *socket, bool remote,
diff --git a/net/lnet/klnds/o2iblnd/o2iblnd.c b/net/lnet/klnds/o2iblnd/o2iblnd.c
index d5ca1a3..14dd686 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd.c
+++ b/net/lnet/klnds/o2iblnd/o2iblnd.c
@@ -3034,7 +3034,7 @@ static int kiblnd_startup(struct lnet_ni *ni)
 		goto failed;
 	}
 
-	rc = lnet_inet_enumerate(&ifaces, ni->ni_net_ns);
+	rc = lnet_inet_enumerate(&ifaces, ni->ni_net_ns, false);
 	if (rc < 0)
 		goto failed;
 
@@ -3062,7 +3062,7 @@ static int kiblnd_startup(struct lnet_ni *ni)
 		ibdev->ibd_ifip = ifaces[i].li_ipaddr;
 		strlcpy(ibdev->ibd_ifname, ifaces[i].li_name,
 			sizeof(ibdev->ibd_ifname));
-		ibdev->ibd_can_failover = !!(ifaces[i].li_flags & IFF_MASTER);
+		ibdev->ibd_can_failover = ifaces[i].li_iff_master;
 
 		INIT_LIST_HEAD(&ibdev->ibd_nets);
 		INIT_LIST_HEAD(&ibdev->ibd_list); /* not yet in kib_devs */
diff --git a/net/lnet/klnds/socklnd/socklnd.c b/net/lnet/klnds/socklnd/socklnd.c
index 00e33c8..8d3c0d6 100644
--- a/net/lnet/klnds/socklnd/socklnd.c
+++ b/net/lnet/klnds/socklnd/socklnd.c
@@ -1744,11 +1744,13 @@ static int ksocknal_push(struct lnet_ni *ni, struct lnet_processid *id)
 			iface = &net->ksnn_interface;
 
 			sa = (void *)&iface->ksni_addr;
-			if (sa->sin_family == AF_INET)
+			if (sa->sin_family == AF_INET) {
 				data->ioc_u32[0] = ntohl(sa->sin_addr.s_addr);
-			else
+				data->ioc_u32[1] = iface->ksni_netmask;
+			} else {
 				data->ioc_u32[0] = 0xFFFFFFFF;
-			data->ioc_u32[1] = iface->ksni_netmask;
+				data->ioc_u32[1] = 0;
+			}
 			data->ioc_u32[2] = iface->ksni_npeers;
 			data->ioc_u32[3] = iface->ksni_nroutes;
 		}
@@ -2443,7 +2445,6 @@ static int ksocknal_inetaddr_event(struct notifier_block *unused,
 	struct ksock_net *net;
 	struct ksock_interface *ksi = NULL;
 	struct lnet_inetdev *ifaces = NULL;
-	struct sockaddr_in *sa;
 	int i = 0;
 	int rc;
 
@@ -2464,7 +2465,7 @@ static int ksocknal_inetaddr_event(struct notifier_block *unused,
 
 	ksocknal_tunables_setup(ni);
 
-	rc = lnet_inet_enumerate(&ifaces, ni->ni_net_ns);
+	rc = lnet_inet_enumerate(&ifaces, ni->ni_net_ns, true);
 	if (rc < 0)
 		goto fail_1;
 
@@ -2485,11 +2486,26 @@ static int ksocknal_inetaddr_event(struct notifier_block *unused,
 
 	ni->ni_dev_cpt = ifaces[i].li_cpt;
 	ksi->ksni_index = ifaces[i].li_index;
-	sa = (void *)&ksi->ksni_addr;
-	memset(sa, 0, sizeof(*sa));
-	sa->sin_family = AF_INET;
-	sa->sin_addr.s_addr = htonl(ifaces[i].li_ipaddr);
-	ksi->ksni_netmask = ifaces[i].li_netmask;
+	if (ifaces[i].li_ipv6) {
+		struct sockaddr_in6 *sa;
+		sa = (void *)&ksi->ksni_addr;
+		memset(sa, 0, sizeof(*sa));
+		sa->sin6_family = AF_INET6;
+		memcpy(&sa->sin6_addr, ifaces[i].li_ipv6addr,
+		       sizeof(struct in6_addr));
+		ni->ni_nid.nid_size = sizeof(struct in6_addr) - 4;
+		memcpy(&ni->ni_nid.nid_addr, ifaces[i].li_ipv6addr,
+		       sizeof(struct in6_addr));
+	} else {
+		struct sockaddr_in *sa;
+		sa = (void *)&ksi->ksni_addr;
+		memset(sa, 0, sizeof(*sa));
+		sa->sin_family = AF_INET;
+		sa->sin_addr.s_addr = htonl(ifaces[i].li_ipaddr);
+		ksi->ksni_netmask = ifaces[i].li_netmask;
+		ni->ni_nid.nid_size = 4 - 4;
+		ni->ni_nid.nid_addr[0] = sa->sin_addr.s_addr;
+	}
 	strlcpy(ksi->ksni_name, ifaces[i].li_name, sizeof(ksi->ksni_name));
 
 	/* call it before add it to ksocknal_data.ksnd_nets */
@@ -2497,9 +2513,6 @@ static int ksocknal_inetaddr_event(struct notifier_block *unused,
 	if (rc)
 		goto fail_1;
 
-	LASSERT(ksi);
-	LASSERT(ksi->ksni_addr.ss_family == AF_INET);
-	ni->ni_nid.nid_addr[0] = ((struct sockaddr_in *)&ksi->ksni_addr)->sin_addr.s_addr;
 	list_add(&net->ksnn_list, &ksocknal_data.ksnd_nets);
 	net->ksnn_ni = ni;
 	ksocknal_data.ksnd_nnets++;
diff --git a/net/lnet/lnet/config.c b/net/lnet/lnet/config.c
index 083a9a2..cebc725 100644
--- a/net/lnet/lnet/config.c
+++ b/net/lnet/lnet/config.c
@@ -31,11 +31,12 @@
  */
 
 #define DEBUG_SUBSYSTEM S_LNET
+#include <linux/ctype.h>
+#include <linux/inetdevice.h>
 #include <linux/nsproxy.h>
 #include <net/net_namespace.h>
-#include <linux/ctype.h>
 #include <linux/lnet/lib-lnet.h>
-#include <linux/inetdevice.h>
+#include <net/addrconf.h>
 
 struct lnet_text_buf {		/* tmp struct for parsing routes */
 	struct list_head	ltb_list;	/* stash on lists */
@@ -1488,7 +1489,7 @@ struct lnet_ni *
 	return count;
 }
 
-int lnet_inet_enumerate(struct lnet_inetdev **dev_list, struct net *ns)
+int lnet_inet_enumerate(struct lnet_inetdev **dev_list, struct net *ns, bool v6)
 {
 	struct lnet_inetdev *ifaces = NULL;
 	struct net_device *dev;
@@ -1500,6 +1501,8 @@ int lnet_inet_enumerate(struct lnet_inetdev **dev_list, struct net *ns)
 		int flags = dev_get_flags(dev);
 		const struct in_ifaddr *ifa;
 		struct in_device *in_dev;
+		struct inet6_dev *in6_dev;
+		const struct inet6_ifaddr *ifa6;
 		int node_id;
 		int cpt;
 
@@ -1511,15 +1514,18 @@ int lnet_inet_enumerate(struct lnet_inetdev **dev_list, struct net *ns)
 			      dev->name);
 			continue;
 		}
+
+		node_id = dev_to_node(&dev->dev);
+		cpt = cfs_cpt_of_node(lnet_cpt_table(), node_id);
+
 		in_dev = __in_dev_get_rtnl(dev);
 		if (!in_dev) {
-			CWARN("lnet: Interface %s has no IPv4 status.\n",
-			      dev->name);
-			continue;
+			if (!v6)
+				CWARN("lnet: Interface %s has no IPv4 status.\n",
+				      dev->name);
+			goto try_v6;
 		}
 
-		node_id = dev_to_node(&dev->dev);
-		cpt = cfs_cpt_of_node(lnet_cpt_table(), node_id);
 		in_dev_for_each_ifa_rtnl(ifa, in_dev) {
 			if (nip >= nalloc) {
 				struct lnet_inetdev *tmp;
@@ -1537,7 +1543,8 @@ int lnet_inet_enumerate(struct lnet_inetdev **dev_list, struct net *ns)
 			}
 
 			ifaces[nip].li_cpt = cpt;
-			ifaces[nip].li_flags = flags;
+			ifaces[nip].li_iff_master = !!(flags & IFF_MASTER);
+			ifaces[nip].li_ipv6 = false;
 			ifaces[nip].li_index = dev->ifindex;
 			ifaces[nip].li_ipaddr = ntohl(ifa->ifa_local);
 			ifaces[nip].li_netmask = ntohl(ifa->ifa_mask);
@@ -1545,6 +1552,53 @@ int lnet_inet_enumerate(struct lnet_inetdev **dev_list, struct net *ns)
 				sizeof(ifaces[nip].li_name));
 			nip++;
 		}
+	try_v6:
+		if (!v6)
+			continue;
+#if IS_ENABLED(CONFIG_IPV6)
+		in6_dev = __in6_dev_get(dev);
+		if (!in6_dev) {
+			if (!in_dev)
+				CWARN("lnet: Interface %s has no IP status.\n",
+				      dev->name);
+			continue;
+		}
+
+		list_for_each_entry_rcu(ifa6, &in6_dev->addr_list, if_list) {
+			if (ifa6->flags & IFA_F_TEMPORARY)
+				continue;
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
+			}
+
+			ifaces[nip].li_cpt = cpt;
+			ifaces[nip].li_iff_master = !!(flags & IFF_MASTER);
+			ifaces[nip].li_ipv6 = true;
+			ifaces[nip].li_index = dev->ifindex;
+			memcpy(ifaces[nip].li_ipv6addr,
+			       &ifa6->addr, sizeof(struct in6_addr));
+			strlcpy(ifaces[nip].li_name, dev->name,
+				sizeof(ifaces[nip].li_name));
+			nip++;
+			/* As different IPv6 addresses don't have unique
+			 * labels, it is safest just to use the first
+			 * and ignore the rest.
+			 */
+			break;
+		}
+#endif /* IS_ENABLED(CONFIG_IPV6) */
+
 	}
 unlock_rtnl:
 	rtnl_unlock();
@@ -1569,9 +1623,10 @@ int lnet_inet_enumerate(struct lnet_inetdev **dev_list, struct net *ns)
 	int i;
 
 	if (current->nsproxy && current->nsproxy->net_ns)
-		nip = lnet_inet_enumerate(&ifaces, current->nsproxy->net_ns);
+		nip = lnet_inet_enumerate(&ifaces, current->nsproxy->net_ns,
+					  false);
 	else
-		nip = lnet_inet_enumerate(&ifaces, &init_net);
+		nip = lnet_inet_enumerate(&ifaces, &init_net, false);
 	if (nip < 0) {
 		if (nip != -ENOENT) {
 			LCONSOLE_ERROR_MSG(0x117,
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
