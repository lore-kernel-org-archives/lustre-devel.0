Return-Path: <SRS0=Gt0B=JW=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.7 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 34937C433ED
	for <lustre-devel@archiver.kernel.org>; Sun, 25 Apr 2021 20:08:55 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id C3F6F611CC
	for <lustre-devel@archiver.kernel.org>; Sun, 25 Apr 2021 20:08:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C3F6F611CC
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 7BFA021F816;
	Sun, 25 Apr 2021 13:08:50 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id A014821F513
 for <lustre-devel@lists.lustre.org>; Sun, 25 Apr 2021 13:08:41 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 03DAD100848B;
 Sun, 25 Apr 2021 16:08:40 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id EB9C069A64; Sun, 25 Apr 2021 16:08:39 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 25 Apr 2021 16:08:08 -0400
Message-Id: <1619381316-7719-2-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1619381316-7719-1-git-send-email-jsimmons@infradead.org>
References: <1619381316-7719-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 01/29] lnet: socklnd: use sockaddr instead of
 u32 addresses.
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

LNet/socklnd often uses u32 to hold an ipv4 address.
As we want to extend socklnd to work with IPv6 addresses too,
this needs to change.

This patch changes many u32s to variants of 'struct sockaddr'.

Library code from sunrpc is used for copying and comparing addresses
   rpc_copy_addr() and rpc_cmp_addr()
and for extracting or setting the port:
   rpc_get_port() and rpc_set_port().

The "%pIS" printf format is used for printing a sockaddr (works for
both IPv4 and IPv6), and "%pISp" for printing the address with the
port.

The u32 is in host-byte-order, while addresses in sockaddr are
always network-order, so htonl and ntohl are used as needed.

When storing an address (e.g. in a structure), 'struct
sockaddr_storage' is used.  When passing an address to a function,
'struct sockaddr' is used.  When an address is known to be IPv4 (i.e.
when converting to or from u32), 'struct sockaddr_in' is used.

The following functions are changed to take a 'struct sockaddr*'
argument:

 lnet_connect()
 lnet_connect_console_error()
 lnet_sock_getaddr()
 ksocknal_ip2iface()
 ksocknal_ip2index()
 ksocknal_create_route()
 ksocknal_connecting()
 ksocknal_close_peer_conns_locked()
 ksocknal_peer_del_interface_locked()

The following structures have had fields changed to 'struct
sockaddr_storage'

 struct ksock_interface:
      ksni_ipaddr -> ksni_addr
 struct ksock_conn
      ksnc_myipaddr -> ksnc_myaddr
      ksnc_ipaddr and ksnc_port -> ksnc_peeraddr
 struct ksock_route
      ksnr_myipaddr -> ksnr_myaddr
      ksnr_ipaddr and ksnr_port -> ksnr_addr

Assorted strings have been joined onto a single line, and various
indented have been changed from space to tabs.

There should be no behaviour changes, though the structures mentioned
above will now be a little larger.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10391
Lustre-commit: c35c1babc7466ed ("LU-10391 socklnd: use sockaddr instead of __u32 addresses.")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/37704
Reviewed-by: Shaun Tancheff <shaun.tancheff@hpe.com>
Reviewed-by: Aurelien Degremont <degremoa@amazon.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/lib-lnet.h          |   9 +-
 net/lnet/klnds/socklnd/socklnd.c       | 330 +++++++++++++++++++++++----------
 net/lnet/klnds/socklnd/socklnd.h       |  12 +-
 net/lnet/klnds/socklnd/socklnd_cb.c    | 132 +++++++------
 net/lnet/klnds/socklnd/socklnd_lib.c   |   7 +-
 net/lnet/klnds/socklnd/socklnd_proto.c |  52 +++---
 net/lnet/lnet/acceptor.c               | 113 ++++++-----
 net/lnet/lnet/lib-socket.c             |  14 +-
 8 files changed, 392 insertions(+), 277 deletions(-)

diff --git a/include/linux/lnet/lib-lnet.h b/include/linux/lnet/lib-lnet.h
index e4dbe0e..2e88d80 100644
--- a/include/linux/lnet/lib-lnet.h
+++ b/include/linux/lnet/lib-lnet.h
@@ -713,10 +713,10 @@ void lnet_copy_kiov2iter(struct iov_iter *to,
 void lnet_register_lnd(struct lnet_lnd *lnd);
 void lnet_unregister_lnd(struct lnet_lnd *lnd);
 
-struct socket *lnet_connect(lnet_nid_t peer_nid, int interface, u32 peer_ip,
-			    int peer_port, struct net *ns);
+struct socket *lnet_connect(lnet_nid_t peer_nid, int interface,
+			    struct sockaddr *peeraddr, struct net *ns);
 void lnet_connect_console_error(int rc, lnet_nid_t peer_nid,
-				u32 peer_ip, int port);
+				struct sockaddr *sa);
 int lnet_count_acceptor_nets(void);
 int lnet_acceptor_timeout(void);
 int lnet_acceptor_port(void);
@@ -738,7 +738,8 @@ struct lnet_inetdev {
 int lnet_inet_enumerate(struct lnet_inetdev **dev_list, struct net *ns);
 int lnet_sock_setbuf(struct socket *socket, int txbufsize, int rxbufsize);
 int lnet_sock_getbuf(struct socket *socket, int *txbufsize, int *rxbufsize);
-int lnet_sock_getaddr(struct socket *socket, bool remote, u32 *ip, int *port);
+int lnet_sock_getaddr(struct socket *socket, bool remote,
+		      struct sockaddr_storage *peer);
 int lnet_sock_write(struct socket *sock, void *buffer, int nob, int timeout);
 int lnet_sock_read(struct socket *sock, void *buffer, int nob, int timeout);
 
diff --git a/net/lnet/klnds/socklnd/socklnd.c b/net/lnet/klnds/socklnd/socklnd.c
index 589a835..d5fe84d 100644
--- a/net/lnet/klnds/socklnd/socklnd.c
+++ b/net/lnet/klnds/socklnd/socklnd.c
@@ -40,13 +40,14 @@
 
 #include <linux/pci.h>
 #include <linux/inetdevice.h>
+#include <linux/sunrpc/addr.h>
 #include "socklnd.h"
 
 static struct lnet_lnd the_ksocklnd;
 struct ksock_nal_data ksocknal_data;
 
 static struct ksock_interface *
-ksocknal_ip2iface(struct lnet_ni *ni, u32 ip)
+ksocknal_ip2iface(struct lnet_ni *ni, struct sockaddr *addr)
 {
 	struct ksock_net *net = ni->ni_data;
 	int i;
@@ -56,7 +57,7 @@
 		LASSERT(i < LNET_INTERFACES_NUM);
 		iface = &net->ksnn_interfaces[i];
 
-		if (iface->ksni_ipaddr == ip)
+		if (rpc_cmp_addr((struct sockaddr *)&iface->ksni_addr, addr))
 			return iface;
 	}
 
@@ -81,12 +82,16 @@
 	return NULL;
 }
 
-static int ksocknal_ip2index(__u32 ipaddress, struct lnet_ni *ni)
+static int ksocknal_ip2index(struct sockaddr *addr, struct lnet_ni *ni)
 {
 	struct net_device *dev;
 	int ret = -1;
 	const struct in_ifaddr *ifa;
 
+	if (addr->sa_family != AF_INET)
+		/* No IPv6 support yet */
+		return ret;
+
 	rcu_read_lock();
 	for_each_netdev(ni->ni_net_ns, dev) {
 		int flags = dev_get_flags(dev);
@@ -103,7 +108,8 @@ static int ksocknal_ip2index(__u32 ipaddress, struct lnet_ni *ni)
 			continue;
 
 		in_dev_for_each_ifa_rcu(ifa, in_dev) {
-			if (ntohl(ifa->ifa_local) == ipaddress)
+			if (ifa->ifa_local ==
+			    ((struct sockaddr_in *)addr)->sin_addr.s_addr)
 				ret = dev->ifindex;
 		}
 		if (ret >= 0)
@@ -115,7 +121,7 @@ static int ksocknal_ip2index(__u32 ipaddress, struct lnet_ni *ni)
 }
 
 static struct ksock_route *
-ksocknal_create_route(u32 ipaddr, int port)
+ksocknal_create_route(struct sockaddr *addr)
 {
 	struct ksock_route *route;
 
@@ -126,9 +132,9 @@ static int ksocknal_ip2index(__u32 ipaddress, struct lnet_ni *ni)
 	refcount_set(&route->ksnr_refcount, 1);
 	route->ksnr_peer = NULL;
 	route->ksnr_retry_interval = 0;		/* OK to connect at any time */
-	route->ksnr_ipaddr = ipaddr;
+	rpc_copy_addr((struct sockaddr *)&route->ksnr_addr, addr);
+	rpc_set_port((struct sockaddr *)&route->ksnr_addr, rpc_get_port(addr));
 	route->ksnr_myiface = -1;
-	route->ksnr_port = port;
 	route->ksnr_scheduled = 0;
 	route->ksnr_connecting = 0;
 	route->ksnr_connected = 0;
@@ -259,14 +265,16 @@ struct ksock_peer_ni *
 ksocknal_unlink_peer_locked(struct ksock_peer_ni *peer_ni)
 {
 	int i;
-	u32 ip;
 	struct ksock_interface *iface;
 
 	for (i = 0; i < peer_ni->ksnp_n_passive_ips; i++) {
+		struct sockaddr_in sa = { .sin_family = AF_INET };
+
 		LASSERT(i < LNET_INTERFACES_NUM);
-		ip = peer_ni->ksnp_passive_ips[i];
+		sa.sin_addr.s_addr = htonl(peer_ni->ksnp_passive_ips[i]);
 
-		iface = ksocknal_ip2iface(peer_ni->ksnp_ni, ip);
+		iface = ksocknal_ip2iface(peer_ni->ksnp_ni,
+					  (struct sockaddr *)&sa);
 		/*
 		 * All IPs in peer_ni->ksnp_passive_ips[] come from the
 		 * interface list, therefore the call must succeed.
@@ -339,11 +347,22 @@ struct ksock_peer_ni *
 				continue;
 
 			*id = peer_ni->ksnp_id;
-			rc = choose_ipv4_src(myip, route->ksnr_myiface,
-					     route->ksnr_ipaddr,
-					     ni->ni_net_ns);
-			*peer_ip = route->ksnr_ipaddr;
-			*port = route->ksnr_port;
+			if (route->ksnr_addr.ss_family == AF_INET) {
+				struct sockaddr_in *sa;
+
+				sa = (void *)&route->ksnr_addr;
+				rc = choose_ipv4_src(myip,
+						     route->ksnr_myiface,
+						     ntohl(sa->sin_addr.s_addr),
+						     ni->ni_net_ns);
+				*peer_ip = ntohl(sa->sin_addr.s_addr);
+				*port = ntohs(sa->sin_port);
+			} else {
+				*myip = 0xFFFFFFFF;
+				*peer_ip = 0xFFFFFFFF;
+				*port = 0;
+				rc = -ENOTSUPP;
+			}
 			*conn_count = route->ksnr_conn_count;
 			*share_count = route->ksnr_share_count;
 			goto out;
@@ -361,24 +380,25 @@ struct ksock_peer_ni *
 	struct ksock_peer_ni *peer_ni = route->ksnr_peer;
 	int type = conn->ksnc_type;
 	struct ksock_interface *iface;
-	int conn_iface = ksocknal_ip2index(conn->ksnc_myipaddr,
-					   route->ksnr_peer->ksnp_ni);
+	int conn_iface;
 
+	conn_iface = ksocknal_ip2index((struct sockaddr *)&conn->ksnc_myaddr,
+				       route->ksnr_peer->ksnp_ni);
 	conn->ksnc_route = route;
 	ksocknal_route_addref(route);
 
 	if (route->ksnr_myiface != conn_iface) {
 		if (route->ksnr_myiface < 0) {
 			/* route wasn't bound locally yet (the initial route) */
-			CDEBUG(D_NET, "Binding %s %pI4h to interface %d\n",
+			CDEBUG(D_NET, "Binding %s %pIS to interface %d\n",
 			       libcfs_id2str(peer_ni->ksnp_id),
-			       &route->ksnr_ipaddr,
+			       &route->ksnr_addr,
 			       conn_iface);
 		} else {
 			CDEBUG(D_NET,
-			       "Rebinding %s %pI4h from interface %d to %d\n",
+			       "Rebinding %s %pIS from interface %d to %d\n",
 			       libcfs_id2str(peer_ni->ksnp_id),
-			       &route->ksnr_ipaddr,
+			       &route->ksnr_addr,
 			       route->ksnr_myiface,
 			       conn_iface);
 
@@ -420,10 +440,11 @@ struct ksock_peer_ni *
 
 	/* LASSERT(unique) */
 	list_for_each_entry(route2, &peer_ni->ksnp_routes, ksnr_list) {
-		if (route2->ksnr_ipaddr == route->ksnr_ipaddr) {
-			CERROR("Duplicate route %s %pI4h\n",
+		if (rpc_cmp_addr((struct sockaddr *)&route2->ksnr_addr,
+				 (struct sockaddr *)&route->ksnr_addr)) {
+			CERROR("Duplicate route %s %pIS\n",
 			       libcfs_id2str(peer_ni->ksnp_id),
-			       &route->ksnr_ipaddr);
+			       &route->ksnr_addr);
 			LBUG();
 		}
 	}
@@ -439,7 +460,8 @@ struct ksock_peer_ni *
 	list_add_tail(&route->ksnr_list, &peer_ni->ksnp_routes);
 
 	list_for_each_entry(conn, &peer_ni->ksnp_conns, ksnc_list) {
-		if (conn->ksnc_ipaddr != route->ksnr_ipaddr)
+		if (!rpc_cmp_addr((struct sockaddr *)&conn->ksnc_peeraddr,
+				  (struct sockaddr *)&route->ksnr_addr))
 			continue;
 
 		ksocknal_associate_route_conn_locked(route, conn);
@@ -494,6 +516,7 @@ struct ksock_peer_ni *
 	struct ksock_peer_ni *peer2;
 	struct ksock_route *route;
 	struct ksock_route *route2;
+	struct sockaddr_in sa = {.sin_family = AF_INET};
 
 	if (id.nid == LNET_NID_ANY ||
 	    id.pid == LNET_PID_ANY)
@@ -504,7 +527,9 @@ struct ksock_peer_ni *
 	if (IS_ERR(peer_ni))
 		return PTR_ERR(peer_ni);
 
-	route = ksocknal_create_route(ipaddr, port);
+	sa.sin_addr.s_addr = htonl(ipaddr);
+	sa.sin_port = htons(port);
+	route = ksocknal_create_route((struct sockaddr *)&sa);
 	if (!route) {
 		ksocknal_peer_decref(peer_ni);
 		return -ENOMEM;
@@ -525,7 +550,9 @@ struct ksock_peer_ni *
 	}
 
 	list_for_each_entry(route2, &peer_ni->ksnp_routes, ksnr_list) {
-		if (route2->ksnr_ipaddr == ipaddr) {
+		struct sockaddr_in *sa = (void *)&route->ksnr_addr;
+
+		if (ipaddr != ntohl(sa->sin_addr.s_addr)) {
 			/* Route already exists, use the old one */
 			ksocknal_route_decref(route);
 			route2->ksnr_share_count++;
@@ -557,8 +584,10 @@ struct ksock_peer_ni *
 
 	list_for_each_entry_safe(route, rnxt, &peer_ni->ksnp_routes,
 				 ksnr_list) {
+		struct sockaddr_in *sa = (void *)&route->ksnr_addr;
+
 		/* no match */
-		if (!(!ip || route->ksnr_ipaddr == ip))
+		if (!(!ip || ntohl(sa->sin_addr.s_addr) == ip))
 			continue;
 
 		route->ksnr_share_count = 0;
@@ -705,7 +734,7 @@ struct ksock_peer_ni *
 ksocknal_local_ipvec(struct lnet_ni *ni, u32 *ipaddrs)
 {
 	struct ksock_net *net = ni->ni_data;
-	int i;
+	int i, j;
 	int nip;
 
 	read_lock(&ksocknal_data.ksnd_global_lock);
@@ -713,22 +742,23 @@ struct ksock_peer_ni *
 	nip = net->ksnn_ninterfaces;
 	LASSERT(nip <= LNET_INTERFACES_NUM);
 
+	for (i = 0, j = 0; i < nip; i++)
+		if (net->ksnn_interfaces[i].ksni_addr.ss_family == AF_INET) {
+			struct sockaddr_in *sa =
+				(void *)&net->ksnn_interfaces[i].ksni_addr;
+
+			ipaddrs[j] = ntohl(sa->sin_addr.s_addr);
+			LASSERT(ipaddrs[j] != 0);
+			j += 1;
+		}
+	nip = j;
+
+	read_unlock(&ksocknal_data.ksnd_global_lock);
 	/*
 	 * Only offer interfaces for additional connections if I have
 	 * more than one.
 	 */
-	if (nip < 2) {
-		read_unlock(&ksocknal_data.ksnd_global_lock);
-		return 0;
-	}
-
-	for (i = 0; i < nip; i++) {
-		ipaddrs[i] = net->ksnn_interfaces[i].ksni_ipaddr;
-		LASSERT(ipaddrs[i]);
-	}
-
-	read_unlock(&ksocknal_data.ksnd_global_lock);
-	return nip;
+	return nip < 2 ? 0 : nip;
 }
 
 static int
@@ -740,12 +770,18 @@ struct ksock_peer_ni *
 	int this_xor;
 	int this_netmatch;
 	int i;
+	struct sockaddr_in *sa;
+	u32 ip;
+
+	sa = (struct sockaddr_in *)&iface->ksni_addr;
+	LASSERT(sa->sin_family == AF_INET);
+	ip = ntohl(sa->sin_addr.s_addr);
 
 	for (i = 0; i < nips; i++) {
 		if (!ips[i])
 			continue;
 
-		this_xor = ips[i] ^ iface->ksni_ipaddr;
+		this_xor = ips[i] ^ ip;
 		this_netmatch = !(this_xor & iface->ksni_netmask) ? 1 : 0;
 
 		if (!(best < 0 ||
@@ -814,13 +850,19 @@ struct ksock_peer_ni *
 		 */
 		if (i < peer_ni->ksnp_n_passive_ips) {
 			/* Old interface. */
-			ip = peer_ni->ksnp_passive_ips[i];
-			best_iface = ksocknal_ip2iface(peer_ni->ksnp_ni, ip);
+			struct sockaddr_in sa = { .sin_family = AF_INET};
+
+			sa.sin_addr.s_addr =
+				htonl(peer_ni->ksnp_passive_ips[i]);
+			best_iface = ksocknal_ip2iface(peer_ni->ksnp_ni,
+						       (struct sockaddr *)&sa);
 
 			/* peer_ni passive ips are kept up to date */
 			LASSERT(best_iface);
 		} else {
 			/* choose a new interface */
+			struct sockaddr_in *sa;
+
 			LASSERT(i == peer_ni->ksnp_n_passive_ips);
 
 			best_iface = NULL;
@@ -829,7 +871,10 @@ struct ksock_peer_ni *
 
 			for (j = 0; j < net->ksnn_ninterfaces; j++) {
 				iface = &net->ksnn_interfaces[j];
-				ip = iface->ksni_ipaddr;
+				sa = (void *)&iface->ksni_addr;
+				if (sa->sin_family != AF_INET)
+					continue;
+				ip = ntohl(sa->sin_addr.s_addr);
 
 				for (k = 0;
 				     k < peer_ni->ksnp_n_passive_ips;
@@ -860,7 +905,8 @@ struct ksock_peer_ni *
 			LASSERT(best_iface);
 
 			best_iface->ksni_npeers++;
-			ip = best_iface->ksni_ipaddr;
+			sa = (void *)&best_iface->ksni_addr;
+			ip = ntohl(sa->sin_addr.s_addr);
 			peer_ni->ksnp_passive_ips[i] = ip;
 			peer_ni->ksnp_n_passive_ips = i + 1;
 		}
@@ -916,11 +962,20 @@ struct ksock_peer_ni *
 
 	for (i = 0; i < npeer_ipaddrs; i++) {
 		if (newroute) {
-			newroute->ksnr_ipaddr = peer_ipaddrs[i];
+			struct sockaddr_in *sa = (void *)&newroute->ksnr_addr;
+
+			memset(sa, 0, sizeof(*sa));
+			sa->sin_family = AF_INET;
+			sa->sin_addr.s_addr = htonl(peer_ipaddrs[i]);
 		} else {
+			struct sockaddr_in sa = {.sin_family = AF_INET};
+
 			write_unlock_bh(global_lock);
 
-			newroute = ksocknal_create_route(peer_ipaddrs[i], port);
+			sa.sin_addr.s_addr = htonl(peer_ipaddrs[i]);
+			sa.sin_port = htons(port);
+			newroute =
+				ksocknal_create_route((struct sockaddr *)&sa);
 			if (!newroute)
 				return;
 
@@ -934,7 +989,8 @@ struct ksock_peer_ni *
 
 		/* Already got a route? */
 		list_for_each_entry(route, &peer_ni->ksnp_routes, ksnr_list)
-			if (route->ksnr_ipaddr != newroute->ksnr_ipaddr)
+			if (rpc_cmp_addr((struct sockaddr *)&route->ksnr_addr,
+					 (struct sockaddr *)&newroute->ksnr_addr))
 				goto next_ipaddr;
 
 		best_iface = NULL;
@@ -945,6 +1001,8 @@ struct ksock_peer_ni *
 
 		/* Select interface to connect from */
 		for (j = 0; j < net->ksnn_ninterfaces; j++) {
+			u32 iface_ip, route_ip;
+
 			iface = &net->ksnn_interfaces[j];
 
 			/* Using this interface already? */
@@ -953,9 +1011,20 @@ struct ksock_peer_ni *
 				if (route->ksnr_myiface == iface->ksni_index)
 					goto next_iface;
 
-			this_netmatch = (!((iface->ksni_ipaddr ^
-					   newroute->ksnr_ipaddr) &
-					   iface->ksni_netmask)) ? 1 : 0;
+			if (iface->ksni_addr.ss_family != AF_INET)
+				continue;
+			if (newroute->ksnr_addr.ss_family != AF_INET)
+				continue;
+
+			iface_ip =
+				ntohl(((struct sockaddr_in *)
+				      &iface->ksni_addr)->sin_addr.s_addr);
+			route_ip =
+				ntohl(((struct sockaddr_in *)
+				      &newroute->ksnr_addr)->sin_addr.s_addr);
+
+			this_netmatch = ((iface_ip ^ route_ip) &
+					  iface->ksni_netmask) ? 1 : 0;
 
 			if (!(!best_iface ||
 			      best_netmatch < this_netmatch ||
@@ -992,16 +1061,16 @@ struct ksock_peer_ni *
 {
 	struct ksock_connreq *cr;
 	int rc;
-	u32 peer_ip;
-	int peer_port;
+	struct sockaddr_storage peer;
 
-	rc = lnet_sock_getaddr(sock, 1, &peer_ip, &peer_port);
+	rc = lnet_sock_getaddr(sock, true, &peer);
 	LASSERT(!rc);			/* we succeeded before */
 
 	cr = kzalloc(sizeof(*cr), GFP_NOFS);
 	if (!cr) {
-		LCONSOLE_ERROR_MSG(0x12f, "Dropping connection request from %pI4h: memory exhausted\n",
-				   &peer_ip);
+		LCONSOLE_ERROR_MSG(0x12f,
+				   "Dropping connection request from %pIS: memory exhausted\n",
+				   &peer);
 		return -ENOMEM;
 	}
 
@@ -1019,12 +1088,12 @@ struct ksock_peer_ni *
 }
 
 static int
-ksocknal_connecting(struct ksock_peer_ni *peer_ni, u32 ipaddr)
+ksocknal_connecting(struct ksock_peer_ni *peer_ni, struct sockaddr *sa)
 {
 	struct ksock_route *route;
 
 	list_for_each_entry(route, &peer_ni->ksnp_routes, ksnr_list) {
-		if (route->ksnr_ipaddr == ipaddr)
+		if (rpc_cmp_addr((struct sockaddr *)&route->ksnr_addr, sa))
 			return route->ksnr_connecting;
 	}
 	return 0;
@@ -1044,6 +1113,7 @@ struct ksock_peer_ni *
 	struct ksock_peer_ni *peer2;
 	struct ksock_sched *sched;
 	struct ksock_hello_msg *hello;
+	struct sockaddr_in *sa;
 	int cpt;
 	struct ksock_tx *tx;
 	struct ksock_tx *txtmp;
@@ -1182,7 +1252,8 @@ struct ksock_peer_ni *
 		 * favour of higher NID...
 		 */
 		if (peerid.nid < ni->ni_nid &&
-		    ksocknal_connecting(peer_ni, conn->ksnc_ipaddr)) {
+		    ksocknal_connecting(peer_ni, ((struct sockaddr *)
+						 &conn->ksnc_peeraddr))) {
 			rc = EALREADY;
 			warn = "connection race resolution";
 			goto failed_2;
@@ -1212,7 +1283,7 @@ struct ksock_peer_ni *
 	if (peer_ni->ksnp_proto != conn->ksnc_proto ||
 	    peer_ni->ksnp_incarnation != incarnation) {
 		/* peer_ni rebooted or I've got the wrong protocol version */
-		ksocknal_close_peer_conns_locked(peer_ni, 0, 0);
+		ksocknal_close_peer_conns_locked(peer_ni, NULL, 0);
 
 		peer_ni->ksnp_proto = NULL;
 		rc = ESTALE;
@@ -1235,14 +1306,17 @@ struct ksock_peer_ni *
 		goto failed_2;
 	}
 
-	/*
-	 * Refuse to duplicate an existing connection, unless this is a
+	/* Refuse to duplicate an existing connection, unless this is a
 	 * loopback connection
 	 */
-	if (conn->ksnc_ipaddr != conn->ksnc_myipaddr) {
+	sa = (void *)&conn->ksnc_myaddr;
+	if (!rpc_cmp_addr((struct sockaddr *)&conn->ksnc_peeraddr,
+			  (struct sockaddr *)&conn->ksnc_myaddr)) {
 		list_for_each_entry(conn2, &peer_ni->ksnp_conns, ksnc_list) {
-			if (conn2->ksnc_ipaddr != conn->ksnc_ipaddr ||
-			    conn2->ksnc_myipaddr != conn->ksnc_myipaddr ||
+			if (!rpc_cmp_addr((struct sockaddr *)&conn2->ksnc_peeraddr,
+					  (struct sockaddr *)&conn->ksnc_peeraddr) ||
+			    !rpc_cmp_addr((struct sockaddr *)&conn2->ksnc_myaddr,
+					  (struct sockaddr *)&conn->ksnc_myaddr) ||
 			    conn2->ksnc_type != conn->ksnc_type)
 				continue;
 
@@ -1265,11 +1339,12 @@ struct ksock_peer_ni *
 	 * code below probably isn't going to work.
 	 */
 	if (active &&
-	    route->ksnr_ipaddr != conn->ksnc_ipaddr) {
-		CERROR("Route %s %pI4h connected to %pI4h\n",
+	    !rpc_cmp_addr((struct sockaddr *)&route->ksnr_addr,
+			  (struct sockaddr *)&conn->ksnc_peeraddr)) {
+		CERROR("Route %s %pIS connected to %pIS\n",
 		       libcfs_id2str(peer_ni->ksnp_id),
-		       &route->ksnr_ipaddr,
-		       &conn->ksnc_ipaddr);
+		       &route->ksnr_addr,
+		       &conn->ksnc_peeraddr);
 	}
 
 	/*
@@ -1279,7 +1354,8 @@ struct ksock_peer_ni *
 	 * continually create duplicate routes.
 	 */
 	list_for_each_entry(route, &peer_ni->ksnp_routes, ksnr_list) {
-		if (route->ksnr_ipaddr != conn->ksnc_ipaddr)
+		if (!rpc_cmp_addr((struct sockaddr *)&route->ksnr_addr,
+				  (struct sockaddr *)&conn->ksnc_peeraddr))
 			continue;
 
 		ksocknal_associate_route_conn_locked(route, conn);
@@ -1341,14 +1417,16 @@ struct ksock_peer_ni *
 	 *	socket callbacks.
 	 */
 	CDEBUG(D_NET,
-	       "New conn %s p %d.x %pI4h -> %pI4h/%d incarnation:%lld sched[%d]\n",
+	       "New conn %s p %d.x %pIS -> %pISp incarnation:%lld sched[%d]\n",
 	       libcfs_id2str(peerid), conn->ksnc_proto->pro_version,
-	       &conn->ksnc_myipaddr, &conn->ksnc_ipaddr,
-	       conn->ksnc_port, incarnation, cpt);
+	       &conn->ksnc_myaddr, &conn->ksnc_peeraddr,
+	       incarnation, cpt);
 
 	if (active) {
+		struct sockaddr *addr = (struct sockaddr *)&conn->ksnc_peeraddr;
+
 		/* additional routes after interface exchange? */
-		ksocknal_create_routes(peer_ni, conn->ksnc_port,
+		ksocknal_create_routes(peer_ni, rpc_get_port(addr),
 				       hello->kshm_ips, hello->kshm_nips);
 	} else {
 		hello->kshm_nips = ksocknal_select_ips(peer_ni, hello->kshm_ips,
@@ -1696,9 +1774,9 @@ struct ksock_peer_ni *
 	case SOCKNAL_RX_LNET_PAYLOAD:
 		last_rcv = conn->ksnc_rx_deadline -
 			   ksocknal_timeout();
-		CERROR("Completing partial receive from %s[%d], ip %pI4h:%d, with error, wanted: %zd, left: %d, last alive is %lld secs ago\n",
+		CERROR("Completing partial receive from %s[%d], ip %pISp, with error, wanted: %zd, left: %d, last alive is %lld secs ago\n",
 		       libcfs_id2str(conn->ksnc_peer->ksnp_id), conn->ksnc_type,
-		       &conn->ksnc_ipaddr, conn->ksnc_port,
+		       &conn->ksnc_peeraddr,
 		       iov_iter_count(&conn->ksnc_rx_to), conn->ksnc_rx_nob_left,
 		       ktime_get_seconds() - last_rcv);
 		if (conn->ksnc_lnet_msg)
@@ -1708,23 +1786,23 @@ struct ksock_peer_ni *
 		break;
 	case SOCKNAL_RX_LNET_HEADER:
 		if (conn->ksnc_rx_started)
-			CERROR("Incomplete receive of lnet header from %s, ip %pI4h:%d, with error, protocol: %d.x.\n",
+			CERROR("Incomplete receive of lnet header from %s, ip %pISp, with error, protocol: %d.x.\n",
 			       libcfs_id2str(conn->ksnc_peer->ksnp_id),
-			       &conn->ksnc_ipaddr, conn->ksnc_port,
+			       &conn->ksnc_peeraddr,
 			       conn->ksnc_proto->pro_version);
 		break;
 	case SOCKNAL_RX_KSM_HEADER:
 		if (conn->ksnc_rx_started)
-			CERROR("Incomplete receive of ksock message from %s, ip %pI4h:%d, with error, protocol: %d.x.\n",
+			CERROR("Incomplete receive of ksock message from %s, ip %pISp, with error, protocol: %d.x.\n",
 			       libcfs_id2str(conn->ksnc_peer->ksnp_id),
-			       &conn->ksnc_ipaddr, conn->ksnc_port,
+			       &conn->ksnc_peeraddr,
 			       conn->ksnc_proto->pro_version);
 		break;
 	case SOCKNAL_RX_SLOP:
 		if (conn->ksnc_rx_started)
-			CERROR("Incomplete receive of slops from %s, ip %pI4h:%d, with error\n",
+			CERROR("Incomplete receive of slops from %s, ip %pISp, with error\n",
 			       libcfs_id2str(conn->ksnc_peer->ksnp_id),
-			       &conn->ksnc_ipaddr, conn->ksnc_port);
+			       &conn->ksnc_peeraddr);
 	       break;
 	default:
 		LBUG();
@@ -1738,14 +1816,16 @@ struct ksock_peer_ni *
 
 int
 ksocknal_close_peer_conns_locked(struct ksock_peer_ni *peer_ni,
-				 u32 ipaddr, int why)
+				 struct sockaddr *addr, int why)
 {
 	struct ksock_conn *conn;
 	struct ksock_conn *cnxt;
 	int count = 0;
 
 	list_for_each_entry_safe(conn, cnxt, &peer_ni->ksnp_conns, ksnc_list) {
-		if (!ipaddr || conn->ksnc_ipaddr == ipaddr) {
+		if (!addr ||
+		    rpc_cmp_addr(addr,
+				 (struct sockaddr *)&conn->ksnc_peeraddr)) {
 			count++;
 			ksocknal_close_conn_locked(conn, why);
 		}
@@ -1757,13 +1837,13 @@ struct ksock_peer_ni *
 int
 ksocknal_close_conn_and_siblings(struct ksock_conn *conn, int why)
 {
+	struct sockaddr *paddr = (struct sockaddr *)&conn->ksnc_peeraddr;
 	struct ksock_peer_ni *peer_ni = conn->ksnc_peer;
-	u32 ipaddr = conn->ksnc_ipaddr;
 	int count;
 
 	write_lock_bh(&ksocknal_data.ksnd_global_lock);
 
-	count = ksocknal_close_peer_conns_locked(peer_ni, ipaddr, why);
+	count = ksocknal_close_peer_conns_locked(peer_ni, paddr, why);
 
 	write_unlock_bh(&ksocknal_data.ksnd_global_lock);
 
@@ -1779,6 +1859,7 @@ struct ksock_peer_ni *
 	int hi;
 	int i;
 	int count = 0;
+	struct sockaddr_in sa = {.sin_family = AF_INET};
 
 	write_lock_bh(&ksocknal_data.ksnd_global_lock);
 
@@ -1790,6 +1871,7 @@ struct ksock_peer_ni *
 		hi = HASH_SIZE(ksocknal_data.ksnd_peers) - 1;
 	}
 
+	sa.sin_addr.s_addr = htonl(ipaddr);
 	for (i = lo; i <= hi; i++) {
 		hlist_for_each_entry_safe(peer_ni, pnxt,
 					  &ksocknal_data.ksnd_peers[i],
@@ -1801,7 +1883,8 @@ struct ksock_peer_ni *
 				continue;
 
 			count += ksocknal_close_peer_conns_locked(peer_ni,
-								  ipaddr, 0);
+								  ipaddr  ? (struct sockaddr *)&sa : NULL,
+								  0);
 		}
 	}
 
@@ -1923,6 +2006,7 @@ static int ksocknal_push(struct lnet_ni *ni, struct lnet_process_id id)
 {
 	struct ksock_net *net = ni->ni_data;
 	struct ksock_interface *iface;
+	struct sockaddr_in sa = { .sin_family = AF_INET };
 	int rc;
 	int i;
 	int j;
@@ -1934,7 +2018,8 @@ static int ksocknal_push(struct lnet_ni *ni, struct lnet_process_id id)
 
 	write_lock_bh(&ksocknal_data.ksnd_global_lock);
 
-	iface = ksocknal_ip2iface(ni, ipaddress);
+	sa.sin_addr.s_addr = htonl(ipaddress);
+	iface = ksocknal_ip2iface(ni, (struct sockaddr *)&sa);
 	if (iface) {
 		/* silently ignore dups */
 		rc = 0;
@@ -1943,8 +2028,10 @@ static int ksocknal_push(struct lnet_ni *ni, struct lnet_process_id id)
 	} else {
 		iface = &net->ksnn_interfaces[net->ksnn_ninterfaces++];
 
-		iface->ksni_index = ksocknal_ip2index(ipaddress, ni);
-		iface->ksni_ipaddr = ipaddress;
+		iface->ksni_index = ksocknal_ip2index((struct sockaddr *)&sa,
+						      ni);
+		rpc_copy_addr((struct sockaddr *)&iface->ksni_addr,
+			      (struct sockaddr *)&sa);
 		iface->ksni_netmask = netmask;
 		iface->ksni_nroutes = 0;
 		iface->ksni_npeers = 0;
@@ -2008,7 +2095,7 @@ static int ksocknal_push(struct lnet_ni *ni, struct lnet_process_id id)
 	}
 
 	list_for_each_entry_safe(conn, cnxt, &peer_ni->ksnp_conns, ksnc_list)
-		if (conn->ksnc_myipaddr == ipaddr)
+		if (conn->ksnc_route->ksnr_myiface == index)
 			ksocknal_close_conn_locked(conn, 0);
 }
 
@@ -2020,16 +2107,23 @@ static int ksocknal_push(struct lnet_ni *ni, struct lnet_process_id id)
 	struct hlist_node *nxt;
 	struct ksock_peer_ni *peer_ni;
 	u32 this_ip;
+	struct sockaddr_in sa = {.sin_family = AF_INET };
 	int index;
 	int i;
 	int j;
 
-	index = ksocknal_ip2index(ipaddress, ni);
+	sa.sin_addr.s_addr = htonl(ipaddress);
+	index = ksocknal_ip2index((struct sockaddr *)&sa, ni);
 
 	write_lock_bh(&ksocknal_data.ksnd_global_lock);
 
 	for (i = 0; i < net->ksnn_ninterfaces; i++) {
-		this_ip = net->ksnn_interfaces[i].ksni_ipaddr;
+		struct sockaddr_in *sa =
+			(void *)&net->ksnn_interfaces[i].ksni_addr;
+
+		if (sa->sin_family != AF_INET)
+			continue;
+		this_ip = ntohl(sa->sin_addr.s_addr);
 
 		if (!(!ipaddress || ipaddress == this_ip))
 			continue;
@@ -2068,6 +2162,7 @@ static int ksocknal_push(struct lnet_ni *ni, struct lnet_process_id id)
 	case IOC_LIBCFS_GET_INTERFACE: {
 		struct ksock_net *net = ni->ni_data;
 		struct ksock_interface *iface;
+		struct sockaddr_in *sa;
 
 		read_lock(&ksocknal_data.ksnd_global_lock);
 
@@ -2077,7 +2172,11 @@ static int ksocknal_push(struct lnet_ni *ni, struct lnet_process_id id)
 			rc = 0;
 			iface = &net->ksnn_interfaces[data->ioc_count];
 
-			data->ioc_u32[0] = iface->ksni_ipaddr;
+			sa = (void *)&iface->ksni_addr;
+			if (sa->sin_family == AF_INET)
+				data->ioc_u32[0] = ntohl(sa->sin_addr.s_addr);
+			else
+				data->ioc_u32[0] = 0xFFFFFFFF;
 			data->ioc_u32[1] = iface->ksni_netmask;
 			data->ioc_u32[2] = iface->ksni_npeers;
 			data->ioc_u32[3] = iface->ksni_nroutes;
@@ -2137,19 +2236,30 @@ static int ksocknal_push(struct lnet_ni *ni, struct lnet_process_id id)
 		int rxmem;
 		int nagle;
 		struct ksock_conn *conn;
+		struct sockaddr_in *psa;
+		struct sockaddr_in *mysa;
 
 		conn = ksocknal_get_conn_by_idx(ni, data->ioc_count);
 		if (!conn)
 			return -ENOENT;
 
+		mysa = (void *)&conn->ksnc_myaddr;
+		psa = (void *)&conn->ksnc_peeraddr;
 		ksocknal_lib_get_conn_tunables(conn, &txmem, &rxmem, &nagle);
 
 		data->ioc_count = txmem;
 		data->ioc_nid = conn->ksnc_peer->ksnp_id.nid;
 		data->ioc_flags = nagle;
-		data->ioc_u32[0] = conn->ksnc_ipaddr;
-		data->ioc_u32[1] = conn->ksnc_port;
-		data->ioc_u32[2] = conn->ksnc_myipaddr;
+		if (psa->sin_family == AF_INET)
+			data->ioc_u32[0] = ntohl(psa->sin_addr.s_addr);
+		else
+			data->ioc_u32[0] = 0xFFFFFFFF;
+		data->ioc_u32[1] = rpc_get_port((struct sockaddr *)
+						&conn->ksnc_peeraddr);
+		if (mysa->sin_family == AF_INET)
+			data->ioc_u32[2] = ntohl(mysa->sin_addr.s_addr);
+		else
+			data->ioc_u32[2] = 0xFFFFFFFF;
 		data->ioc_u32[3] = conn->ksnc_type;
 		data->ioc_u32[4] = conn->ksnc_scheduler->kss_cpt;
 		data->ioc_u32[5] = rxmem;
@@ -2650,13 +2760,18 @@ static int ksocknal_push(struct lnet_ni *ni, struct lnet_process_id id)
 		goto fail_1;
 
 	if (!ni->ni_interfaces[0]) {
+		struct sockaddr_in *sa;
+
 		ksi = &net->ksnn_interfaces[0];
+		sa = (void *)&ksi->ksni_addr;
 
 		/* Use the first discovered interface */
 		net->ksnn_ninterfaces = 1;
 		ni->ni_dev_cpt = ifaces[0].li_cpt;
-		ksi->ksni_ipaddr = ifaces[0].li_ipaddr;
-		ksi->ksni_index = ksocknal_ip2index(ksi->ksni_ipaddr, ni);
+		memset(sa, 0, sizeof(*sa));
+		sa->sin_family = AF_INET;
+		sa->sin_addr.s_addr = htonl(ifaces[0].li_ipaddr);
+		ksi->ksni_index = ksocknal_ip2index((struct sockaddr *)sa, ni);
 		ksi->ksni_netmask = ifaces[0].li_netmask;
 		strlcpy(ksi->ksni_name, ifaces[0].li_name,
 			sizeof(ksi->ksni_name));
@@ -2689,15 +2804,22 @@ static int ksocknal_push(struct lnet_ni *ni, struct lnet_process_id id)
 			}
 
 			for (j = 0; j < rc; j++) {
+				struct sockaddr_in *sa;
+
 				if (strcmp(ifaces[j].li_name,
 					   ni->ni_interfaces[i]) != 0)
 					continue;
 
 				ksi = &net->ksnn_interfaces[net->ksnn_ninterfaces];
+				sa = (void *)&ksi->ksni_addr;
 				ni->ni_dev_cpt = ifaces[j].li_cpt;
-				ksi->ksni_ipaddr = ifaces[j].li_ipaddr;
+				memset(sa, 0, sizeof(*sa));
+				sa->sin_family = AF_INET;
+				sa->sin_addr.s_addr =
+					htonl(ifaces[j].li_ipaddr);
 				ksi->ksni_index =
-					ksocknal_ip2index(ksi->ksni_ipaddr, ni);
+					ksocknal_ip2index((struct sockaddr *)sa,
+							  ni);
 				ksi->ksni_netmask = ifaces[j].li_netmask;
 				strlcpy(ksi->ksni_name, ifaces[j].li_name,
 					sizeof(ksi->ksni_name));
@@ -2730,7 +2852,9 @@ static int ksocknal_push(struct lnet_ni *ni, struct lnet_process_id id)
 		goto fail_1;
 
 	LASSERT(ksi);
-	ni->ni_nid = LNET_MKNID(LNET_NIDNET(ni->ni_nid), ksi->ksni_ipaddr);
+	LASSERT(ksi->ksni_addr.ss_family == AF_INET);
+	ni->ni_nid = LNET_MKNID(LNET_NIDNET(ni->ni_nid),
+				ntohl(((struct sockaddr_in *)&ksi->ksni_addr)->sin_addr.s_addr));
 	list_add(&net->ksnn_list, &ksocknal_data.ksnd_nets);
 
 	ksocknal_data.ksnd_nnets++;
diff --git a/net/lnet/klnds/socklnd/socklnd.h b/net/lnet/klnds/socklnd/socklnd.h
index 261cbb46..83f0e3c 100644
--- a/net/lnet/klnds/socklnd/socklnd.h
+++ b/net/lnet/klnds/socklnd/socklnd.h
@@ -100,7 +100,7 @@ struct ksock_sched {				/* per scheduler state */
 
 struct ksock_interface {			/* in-use interface */
 	int		ksni_index;		/* Linux interface index */
-	u32		ksni_ipaddr;		/* interface's IP address */
+	struct sockaddr_storage ksni_addr;	/* interface's address */
 	u32		ksni_netmask;		/* interface's network mask */
 	int		ksni_nroutes;		/* # routes using (active) */
 	int		ksni_npeers;		/* # peers using (passive) */
@@ -316,9 +316,8 @@ struct ksock_conn {
 	refcount_t		ksnc_sock_refcount;	/* sock refcount */
 	struct ksock_sched     *ksnc_scheduler;		/* who schedules this connection
 							 */
-	u32			ksnc_myipaddr;		/* my IP */
-	u32			ksnc_ipaddr;		/* peer_ni's IP */
-	int			ksnc_port;		/* peer_ni's port */
+	struct sockaddr_storage	ksnc_myaddr;		/* my address */
+	struct sockaddr_storage ksnc_peeraddr;		/* peer_ni's address */
 	signed int		ksnc_type:3;		/* type of connection, should be
 							 * signed value
 							 */
@@ -381,8 +380,7 @@ struct ksock_route {
 							 */
 	time64_t		ksnr_retry_interval;	/* how long between retries */
 	int			ksnr_myiface;		/* my IP */
-	u32			ksnr_ipaddr;		/* IP address to connect to */
-	int			ksnr_port;		/* port to connect to */
+	struct sockaddr_storage	ksnr_addr;		/* IP address to connect to */
 	unsigned int		ksnr_scheduled:1;	/* scheduled for attention */
 	unsigned int		ksnr_connecting:1;	/* connection establishment in
 							 * progress
@@ -624,7 +622,7 @@ int ksocknal_create_conn(struct lnet_ni *ni, struct ksock_route *route,
 void ksocknal_terminate_conn(struct ksock_conn *conn);
 void ksocknal_destroy_conn(struct ksock_conn *conn);
 int ksocknal_close_peer_conns_locked(struct ksock_peer_ni *peer_ni,
-				     u32 ipaddr, int why);
+				     struct sockaddr *peer, int why);
 int ksocknal_close_conn_and_siblings(struct ksock_conn *conn, int why);
 int ksocknal_close_matching_conns(struct lnet_process_id id, u32 ipaddr);
 struct ksock_conn *ksocknal_find_conn_locked(struct ksock_peer_ni *peer_ni,
diff --git a/net/lnet/klnds/socklnd/socklnd_cb.c b/net/lnet/klnds/socklnd/socklnd_cb.c
index b1146dc..bfc4e2e 100644
--- a/net/lnet/klnds/socklnd/socklnd_cb.c
+++ b/net/lnet/klnds/socklnd/socklnd_cb.c
@@ -23,6 +23,7 @@
  */
 
 #include <linux/sched/mm.h>
+#include <linux/sunrpc/addr.h>
 #include "socklnd.h"
 
 struct ksock_tx *
@@ -532,19 +533,17 @@ struct ksock_tx *
 	if (!conn->ksnc_closing) {
 		switch (rc) {
 		case -ECONNRESET:
-			LCONSOLE_WARN("Host %pI4h reset our connection while we were sending data; it may have rebooted.\n",
-				      &conn->ksnc_ipaddr);
+			LCONSOLE_WARN("Host %pIS reset our connection while we were sending data; it may have rebooted.\n",
+				      &conn->ksnc_peeraddr);
 			break;
 		default:
-			LCONSOLE_WARN("There was an unexpected network error while writing to %pI4h: %d.\n",
-				      &conn->ksnc_ipaddr, rc);
+			LCONSOLE_WARN("There was an unexpected network error while writing to %pIS: %d.\n",
+				      &conn->ksnc_peeraddr, rc);
 			break;
 		}
-		CDEBUG(D_NET, "[%p] Error %d on write to %s ip %pI4h:%d\n",
-		       conn, rc,
-		       libcfs_id2str(conn->ksnc_peer->ksnp_id),
-		       &conn->ksnc_ipaddr,
-		       conn->ksnc_port);
+		CDEBUG(D_NET, "[%p] Error %d on write to %s ip %pISp\n",
+		       conn, rc, libcfs_id2str(conn->ksnc_peer->ksnp_id),
+		       &conn->ksnc_peeraddr);
 	}
 
 	if (tx->tx_zc_checked)
@@ -676,9 +675,9 @@ struct ksock_conn *
 	 */
 	LASSERT(!conn->ksnc_closing);
 
-	CDEBUG(D_NET, "Sending to %s ip %pI4h:%d\n",
+	CDEBUG(D_NET, "Sending to %s ip %pISp\n",
 	       libcfs_id2str(conn->ksnc_peer->ksnp_id),
-	       &conn->ksnc_ipaddr, conn->ksnc_port);
+	       &conn->ksnc_peeraddr);
 
 	ksocknal_tx_prep(conn, tx);
 
@@ -774,8 +773,8 @@ struct ksock_route *
 		if (!(!route->ksnr_retry_interval || /* first attempt */
 		      now >= route->ksnr_timeout)) {
 			CDEBUG(D_NET,
-			       "Too soon to retry route %pI4h (cnted %d, interval %lld, %lld secs later)\n",
-			       &route->ksnr_ipaddr,
+			       "Too soon to retry route %pIS (cnted %d, interval %lld, %lld secs later)\n",
+			       &route->ksnr_addr,
 			       route->ksnr_connected,
 			       route->ksnr_retry_interval,
 			       route->ksnr_timeout - now);
@@ -1081,20 +1080,20 @@ struct ksock_route *
 		rc = ksocknal_receive(conn);
 
 		if (rc <= 0) {
+			struct lnet_process_id ksnp_id;
+
+			ksnp_id = conn->ksnc_peer->ksnp_id;
+
 			LASSERT(rc != -EAGAIN);
 
 			if (!rc)
-				CDEBUG(D_NET, "[%p] EOF from %s ip %pI4h:%d\n",
-				       conn,
-				       libcfs_id2str(conn->ksnc_peer->ksnp_id),
-				       &conn->ksnc_ipaddr,
-				       conn->ksnc_port);
+				CDEBUG(D_NET, "[%p] EOF from %s ip %pISp\n",
+				       conn, libcfs_id2str(ksnp_id),
+				       &conn->ksnc_peeraddr);
 			else if (!conn->ksnc_closing)
-				CERROR("[%p] Error %d on read from %s ip %pI4h:%d\n",
-				       conn, rc,
-				       libcfs_id2str(conn->ksnc_peer->ksnp_id),
-				       &conn->ksnc_ipaddr,
-				       conn->ksnc_port);
+				CERROR("[%p] Error %d on read from %s ip %pISp\n",
+				       conn, rc, libcfs_id2str(ksnp_id),
+				       &conn->ksnc_peeraddr);
 
 			/* it's not an error if conn is being closed */
 			ksocknal_close_conn_and_siblings(conn,
@@ -1647,8 +1646,8 @@ void ksocknal_write_callback(struct ksock_conn *conn)
 	rc = lnet_sock_read(sock, &hello->kshm_magic,
 			    sizeof(hello->kshm_magic), timeout);
 	if (rc) {
-		CERROR("Error %d reading HELLO from %pI4h\n",
-		       rc, &conn->ksnc_ipaddr);
+		CERROR("Error %d reading HELLO from %pIS\n",
+		       rc, &conn->ksnc_peeraddr);
 		LASSERT(rc < 0);
 		return rc;
 	}
@@ -1657,18 +1656,17 @@ void ksocknal_write_callback(struct ksock_conn *conn)
 	    hello->kshm_magic != __swab32(LNET_PROTO_MAGIC) &&
 	    hello->kshm_magic != le32_to_cpu(LNET_PROTO_TCP_MAGIC)) {
 		/* Unexpected magic! */
-		CERROR("Bad magic(1) %#08x (%#08x expected) from %pI4h\n",
+		CERROR("Bad magic(1) %#08x (%#08x expected) from %pIS\n",
 		       __cpu_to_le32(hello->kshm_magic),
-		       LNET_PROTO_TCP_MAGIC,
-		       &conn->ksnc_ipaddr);
+		       LNET_PROTO_TCP_MAGIC, &conn->ksnc_peeraddr);
 		return -EPROTO;
 	}
 
 	rc = lnet_sock_read(sock, &hello->kshm_version,
 			    sizeof(hello->kshm_version), timeout);
 	if (rc) {
-		CERROR("Error %d reading HELLO from %pI4h\n",
-		       rc, &conn->ksnc_ipaddr);
+		CERROR("Error %d reading HELLO from %pIS\n",
+		       rc, &conn->ksnc_peeraddr);
 		LASSERT(rc < 0);
 		return rc;
 	}
@@ -1690,9 +1688,9 @@ void ksocknal_write_callback(struct ksock_conn *conn)
 			ksocknal_send_hello(ni, conn, ni->ni_nid, hello);
 		}
 
-		CERROR("Unknown protocol version (%d.x expected) from %pI4h\n",
+		CERROR("Unknown protocol version (%d.x expected) from %pIS\n",
 		       conn->ksnc_proto->pro_version,
-		       &conn->ksnc_ipaddr);
+		       &conn->ksnc_peeraddr);
 
 		return -EPROTO;
 	}
@@ -1703,8 +1701,8 @@ void ksocknal_write_callback(struct ksock_conn *conn)
 	/* receive the rest of hello message anyway */
 	rc = conn->ksnc_proto->pro_recv_hello(conn, hello, timeout);
 	if (rc) {
-		CERROR("Error %d reading or checking hello from from %pI4h\n",
-		       rc, &conn->ksnc_ipaddr);
+		CERROR("Error %d reading or checking hello from from %pIS\n",
+		       rc, &conn->ksnc_peeraddr);
 		LASSERT(rc < 0);
 		return rc;
 	}
@@ -1712,17 +1710,21 @@ void ksocknal_write_callback(struct ksock_conn *conn)
 	*incarnation = hello->kshm_src_incarnation;
 
 	if (hello->kshm_src_nid == LNET_NID_ANY) {
-		CERROR("Expecting a HELLO hdr with a NID, but got LNET_NID_ANY from %pI4h\n",
-		       &conn->ksnc_ipaddr);
+		CERROR("Expecting a HELLO hdr with a NID, but got LNET_NID_ANY from %pIS\n",
+		       &conn->ksnc_peeraddr);
 		return -EPROTO;
 	}
 
 	if (!active &&
-	    conn->ksnc_port > LNET_ACCEPTOR_MAX_RESERVED_PORT) {
+	    rpc_get_port((struct sockaddr *)&conn->ksnc_peeraddr) >
+	    LNET_ACCEPTOR_MAX_RESERVED_PORT) {
 		/* Userspace NAL assigns peer_ni process ID from socket */
-		recv_id.pid = conn->ksnc_port | LNET_PID_USERFLAG;
+		recv_id.pid = rpc_get_port((struct sockaddr *)
+					   &conn->ksnc_peeraddr) |
+					   LNET_PID_USERFLAG;
 		recv_id.nid = LNET_MKNID(LNET_NIDNET(ni->ni_nid),
-					 conn->ksnc_ipaddr);
+					 ntohl(((struct sockaddr_in *)
+					 &conn->ksnc_peeraddr)->sin_addr.s_addr));
 	} else {
 		recv_id.nid = hello->kshm_src_nid;
 		recv_id.pid = hello->kshm_src_pid;
@@ -1734,9 +1736,9 @@ void ksocknal_write_callback(struct ksock_conn *conn)
 		/* peer_ni determines type */
 		conn->ksnc_type = ksocknal_invert_type(hello->kshm_ctype);
 		if (conn->ksnc_type == SOCKLND_CONN_NONE) {
-			CERROR("Unexpected type %d from %s ip %pI4h\n",
+			CERROR("Unexpected type %d from %s ip %pIS\n",
 			       hello->kshm_ctype, libcfs_id2str(*peerid),
-			       &conn->ksnc_ipaddr);
+			       &conn->ksnc_peeraddr);
 			return -EPROTO;
 		}
 
@@ -1745,9 +1747,10 @@ void ksocknal_write_callback(struct ksock_conn *conn)
 
 	if (peerid->pid != recv_id.pid ||
 	    peerid->nid != recv_id.nid) {
-		LCONSOLE_ERROR_MSG(0x130, "Connected successfully to %s on host %pI4h, but they claimed they were %s; please check your Lustre configuration.\n",
+		LCONSOLE_ERROR_MSG(0x130,
+				   "Connected successfully to %s on host %pIS, but they claimed they were %s; please check your Lustre configuration.\n",
 				   libcfs_id2str(*peerid),
-				   &conn->ksnc_ipaddr,
+				   &conn->ksnc_peeraddr,
 				   libcfs_id2str(recv_id));
 		return -EPROTO;
 	}
@@ -1758,9 +1761,9 @@ void ksocknal_write_callback(struct ksock_conn *conn)
 	}
 
 	if (ksocknal_invert_type(hello->kshm_ctype) != conn->ksnc_type) {
-		CERROR("Mismatched types: me %d, %s ip %pI4h %d\n",
+		CERROR("Mismatched types: me %d, %s ip %pIS %d\n",
 		       conn->ksnc_type, libcfs_id2str(*peerid),
-		       &conn->ksnc_ipaddr, hello->kshm_ctype);
+		       &conn->ksnc_peeraddr, hello->kshm_ctype);
 		return -EPROTO;
 	}
 
@@ -1829,14 +1832,14 @@ void ksocknal_write_callback(struct ksock_conn *conn)
 		if (ktime_get_seconds() >= deadline) {
 			rc = -ETIMEDOUT;
 			lnet_connect_console_error(rc, peer_ni->ksnp_id.nid,
-						   route->ksnr_ipaddr,
-						   route->ksnr_port);
+						   (struct sockaddr *)
+						   &route->ksnr_addr);
 			goto failed;
 		}
 
 		sock = lnet_connect(peer_ni->ksnp_id.nid,
 				    route->ksnr_myiface,
-				    route->ksnr_ipaddr, route->ksnr_port,
+				    (struct sockaddr *)&route->ksnr_addr,
 				    peer_ni->ksnp_ni->ni_net_ns);
 		if (IS_ERR(sock)) {
 			rc = PTR_ERR(sock);
@@ -1846,8 +1849,8 @@ void ksocknal_write_callback(struct ksock_conn *conn)
 		rc = ksocknal_create_conn(peer_ni->ksnp_ni, route, sock, type);
 		if (rc < 0) {
 			lnet_connect_console_error(rc, peer_ni->ksnp_id.nid,
-						   route->ksnr_ipaddr,
-						   route->ksnr_port);
+						   (struct sockaddr *)
+						   &route->ksnr_addr);
 			goto failed;
 		}
 
@@ -2135,8 +2138,8 @@ void ksocknal_write_callback(struct ksock_conn *conn)
 			if (ksocknal_connect(route)) {
 				/* consecutive retry */
 				if (cons_retry++ > SOCKNAL_INSANITY_RECONN) {
-					CWARN("massive consecutive re-connecting to %pI4h\n",
-					      &route->ksnr_ipaddr);
+					CWARN("massive consecutive re-connecting to %pIS\n",
+					      &route->ksnr_addr);
 					cons_retry = 0;
 				}
 			} else {
@@ -2195,23 +2198,20 @@ void ksocknal_write_callback(struct ksock_conn *conn)
 
 			switch (error) {
 			case ECONNRESET:
-				CNETERR("A connection with %s (%pI4h:%d) was reset; it may have rebooted.\n",
+				CNETERR("A connection with %s (%pISp) was reset; it may have rebooted.\n",
 					libcfs_id2str(peer_ni->ksnp_id),
-					&conn->ksnc_ipaddr,
-					conn->ksnc_port);
+					&conn->ksnc_peeraddr);
 				break;
 			case ETIMEDOUT:
-				CNETERR("A connection with %s (%pI4h:%d) timed out; the network or node may be down.\n",
+				CNETERR("A connection with %s (%pISp) timed out; the network or node may be down.\n",
 					libcfs_id2str(peer_ni->ksnp_id),
-					&conn->ksnc_ipaddr,
-					conn->ksnc_port);
+					&conn->ksnc_peeraddr);
 				break;
 			default:
-				CNETERR("An unexpected network error %d occurred with %s (%pI4h:%d\n",
+				CNETERR("An unexpected network error %d occurred with %s (%pISp\n",
 					error,
 					libcfs_id2str(peer_ni->ksnp_id),
-					&conn->ksnc_ipaddr,
-					conn->ksnc_port);
+					&conn->ksnc_peeraddr);
 				break;
 			}
 
@@ -2222,10 +2222,9 @@ void ksocknal_write_callback(struct ksock_conn *conn)
 		    ktime_get_seconds() >= conn->ksnc_rx_deadline) {
 			/* Timed out incomplete incoming message */
 			ksocknal_conn_addref(conn);
-			CNETERR("Timeout receiving from %s (%pI4h:%d), state %d wanted %zd left %d\n",
+			CNETERR("Timeout receiving from %s (%pISp), state %d wanted %zd left %d\n",
 				libcfs_id2str(peer_ni->ksnp_id),
-				&conn->ksnc_ipaddr,
-				conn->ksnc_port,
+				&conn->ksnc_peeraddr,
 				conn->ksnc_rx_state,
 				iov_iter_count(&conn->ksnc_rx_to),
 				conn->ksnc_rx_nob_left);
@@ -2244,10 +2243,9 @@ void ksocknal_write_callback(struct ksock_conn *conn)
 					    tx_list)
 				tx->tx_hstatus =
 					LNET_MSG_STATUS_LOCAL_TIMEOUT;
-			CNETERR("Timeout sending data to %s (%pI4h:%d) the network or that node may be down.\n",
+			CNETERR("Timeout sending data to %s (%pISp) the network or that node may be down.\n",
 				libcfs_id2str(peer_ni->ksnp_id),
-				&conn->ksnc_ipaddr,
-				conn->ksnc_port);
+				&conn->ksnc_peeraddr);
 			return conn;
 		}
 	}
diff --git a/net/lnet/klnds/socklnd/socklnd_lib.c b/net/lnet/klnds/socklnd/socklnd_lib.c
index 1d6cd0e..6ce5ca4 100644
--- a/net/lnet/klnds/socklnd/socklnd_lib.c
+++ b/net/lnet/klnds/socklnd/socklnd_lib.c
@@ -37,8 +37,8 @@
 int
 ksocknal_lib_get_conn_addrs(struct ksock_conn *conn)
 {
-	int rc = lnet_sock_getaddr(conn->ksnc_sock, 1, &conn->ksnc_ipaddr,
-				   &conn->ksnc_port);
+	int rc = lnet_sock_getaddr(conn->ksnc_sock, true,
+				   &conn->ksnc_peeraddr);
 
 	/* Didn't need the {get,put}connsock dance to deref ksnc_sock... */
 	LASSERT(!conn->ksnc_closing);
@@ -48,7 +48,8 @@
 		return rc;
 	}
 
-	rc = lnet_sock_getaddr(conn->ksnc_sock, 0, &conn->ksnc_myipaddr, NULL);
+	rc = lnet_sock_getaddr(conn->ksnc_sock, false,
+			       &conn->ksnc_myaddr);
 	if (rc) {
 		CERROR("Error %d getting sock local IP\n", rc);
 		return rc;
diff --git a/net/lnet/klnds/socklnd/socklnd_proto.c b/net/lnet/klnds/socklnd/socklnd_proto.c
index bc9f349..0a6072b 100644
--- a/net/lnet/klnds/socklnd/socklnd_proto.c
+++ b/net/lnet/klnds/socklnd/socklnd_proto.c
@@ -499,8 +499,8 @@
 
 	rc = lnet_sock_write(sock, hdr, sizeof(*hdr), lnet_acceptor_timeout());
 	if (rc) {
-		CNETERR("Error %d sending HELLO hdr to %pI4h/%d\n",
-			rc, &conn->ksnc_ipaddr, conn->ksnc_port);
+		CNETERR("Error %d sending HELLO hdr to %pISp\n",
+			rc, &conn->ksnc_peeraddr);
 		goto out;
 	}
 
@@ -514,9 +514,9 @@
 			     hello->kshm_nips * sizeof(u32),
 			     lnet_acceptor_timeout());
 	if (rc) {
-		CNETERR("Error %d sending HELLO payload (%d) to %pI4h/%d\n",
+		CNETERR("Error %d sending HELLO payload (%d) to %pISp\n",
 			rc, hello->kshm_nips,
-			&conn->ksnc_ipaddr, conn->ksnc_port);
+			&conn->ksnc_peeraddr);
 	}
 out:
 	kfree(hdr);
@@ -542,8 +542,8 @@
 	rc = lnet_sock_write(sock, hello, offsetof(struct ksock_hello_msg, kshm_ips),
 			     lnet_acceptor_timeout());
 	if (rc) {
-		CNETERR("Error %d sending HELLO hdr to %pI4h/%d\n",
-			rc, &conn->ksnc_ipaddr, conn->ksnc_port);
+		CNETERR("Error %d sending HELLO hdr to %pISp\n",
+			rc, &conn->ksnc_peeraddr);
 		return rc;
 	}
 
@@ -554,9 +554,9 @@
 			     hello->kshm_nips * sizeof(u32),
 			     lnet_acceptor_timeout());
 	if (rc) {
-		CNETERR("Error %d sending HELLO payload (%d) to %pI4h/%d\n",
+		CNETERR("Error %d sending HELLO payload (%d) to %pISp\n",
 			rc, hello->kshm_nips,
-			&conn->ksnc_ipaddr, conn->ksnc_port);
+			&conn->ksnc_peeraddr);
 	}
 
 	return rc;
@@ -581,17 +581,17 @@
 			    sizeof(*hdr) - offsetof(struct lnet_hdr, src_nid),
 			    timeout);
 	if (rc) {
-		CERROR("Error %d reading rest of HELLO hdr from %pI4h\n",
-		       rc, &conn->ksnc_ipaddr);
+		CERROR("Error %d reading rest of HELLO hdr from %pIS\n",
+		       rc, &conn->ksnc_peeraddr);
 		LASSERT(rc < 0 && rc != -EALREADY);
 		goto out;
 	}
 
 	/* ...and check we got what we expected */
 	if (hdr->type != cpu_to_le32(LNET_MSG_HELLO)) {
-		CERROR("Expecting a HELLO hdr, but got type %d from %pI4h\n",
+		CERROR("Expecting a HELLO hdr, but got type %d from %pIS\n",
 		       le32_to_cpu(hdr->type),
-		       &conn->ksnc_ipaddr);
+		       &conn->ksnc_peeraddr);
 		rc = -EPROTO;
 		goto out;
 	}
@@ -603,8 +603,8 @@
 	hello->kshm_nips = le32_to_cpu(hdr->payload_length) / sizeof(u32);
 
 	if (hello->kshm_nips > LNET_INTERFACES_NUM) {
-		CERROR("Bad nips %d from ip %pI4h\n",
-		       hello->kshm_nips, &conn->ksnc_ipaddr);
+		CERROR("Bad nips %d from ip %pIS\n",
+		       hello->kshm_nips, &conn->ksnc_peeraddr);
 		rc = -EPROTO;
 		goto out;
 	}
@@ -615,8 +615,8 @@
 	rc = lnet_sock_read(sock, hello->kshm_ips,
 			    hello->kshm_nips * sizeof(u32), timeout);
 	if (rc) {
-		CERROR("Error %d reading IPs from ip %pI4h\n",
-		       rc, &conn->ksnc_ipaddr);
+		CERROR("Error %d reading IPs from ip %pIS\n",
+		       rc, &conn->ksnc_peeraddr);
 		LASSERT(rc < 0 && rc != -EALREADY);
 		goto out;
 	}
@@ -625,8 +625,8 @@
 		hello->kshm_ips[i] = __le32_to_cpu(hello->kshm_ips[i]);
 
 		if (!hello->kshm_ips[i]) {
-			CERROR("Zero IP[%d] from ip %pI4h\n",
-			       i, &conn->ksnc_ipaddr);
+			CERROR("Zero IP[%d] from ip %pIS\n",
+			       i, &conn->ksnc_peeraddr);
 			rc = -EPROTO;
 			break;
 		}
@@ -655,8 +655,8 @@
 				     offsetof(struct ksock_hello_msg, kshm_src_nid),
 			    timeout);
 	if (rc) {
-		CERROR("Error %d reading HELLO from %pI4h\n",
-		       rc, &conn->ksnc_ipaddr);
+		CERROR("Error %d reading HELLO from %pIS\n",
+		       rc, &conn->ksnc_peeraddr);
 		LASSERT(rc < 0 && rc != -EALREADY);
 		return rc;
 	}
@@ -673,8 +673,8 @@
 	}
 
 	if (hello->kshm_nips > LNET_INTERFACES_NUM) {
-		CERROR("Bad nips %d from ip %pI4h\n",
-		       hello->kshm_nips, &conn->ksnc_ipaddr);
+		CERROR("Bad nips %d from ip %pIS\n",
+		       hello->kshm_nips, &conn->ksnc_peeraddr);
 		return -EPROTO;
 	}
 
@@ -684,8 +684,8 @@
 	rc = lnet_sock_read(sock, hello->kshm_ips,
 			    hello->kshm_nips * sizeof(u32), timeout);
 	if (rc) {
-		CERROR("Error %d reading IPs from ip %pI4h\n",
-		       rc, &conn->ksnc_ipaddr);
+		CERROR("Error %d reading IPs from ip %pIS\n",
+		       rc, &conn->ksnc_peeraddr);
 		LASSERT(rc < 0 && rc != -EALREADY);
 		return rc;
 	}
@@ -695,8 +695,8 @@
 			__swab32s(&hello->kshm_ips[i]);
 
 		if (!hello->kshm_ips[i]) {
-			CERROR("Zero IP[%d] from ip %pI4h\n",
-			       i, &conn->ksnc_ipaddr);
+			CERROR("Zero IP[%d] from ip %pIS\n",
+			       i, &conn->ksnc_peeraddr);
 			return -EPROTO;
 		}
 	}
diff --git a/net/lnet/lnet/acceptor.c b/net/lnet/lnet/acceptor.c
index 55c056f..5765a08 100644
--- a/net/lnet/lnet/acceptor.c
+++ b/net/lnet/lnet/acceptor.c
@@ -35,6 +35,7 @@
 #include <linux/completion.h>
 #include <net/sock.h>
 #include <linux/lnet/lib-lnet.h>
+#include <linux/sunrpc/addr.h>
 
 static int accept_port = 988;
 static int accept_backlog = 127;
@@ -86,53 +87,51 @@
 
 void
 lnet_connect_console_error(int rc, lnet_nid_t peer_nid,
-			   u32 peer_ip, int peer_port)
+			   struct sockaddr *sa)
 {
 	switch (rc) {
 	/* "normal" errors */
 	case -ECONNREFUSED:
-		CNETERR("Connection to %s at host %pI4h on port %d was refused: check that Lustre is running on that node.\n",
-			libcfs_nid2str(peer_nid),
-			&peer_ip, peer_port);
+		CNETERR("Connection to %s at host %pISp was refused: check that Lustre is running on that node.\n",
+			libcfs_nid2str(peer_nid), sa);
 		break;
 	case -EHOSTUNREACH:
 	case -ENETUNREACH:
-		CNETERR("Connection to %s at host %pI4h was unreachable: the network or that node may be down, or Lustre may be misconfigured.\n",
-			libcfs_nid2str(peer_nid), &peer_ip);
+		CNETERR("Connection to %s at host %pIS was unreachable: the network or that node may be down, or Lustre may be misconfigured.\n",
+			libcfs_nid2str(peer_nid), sa);
 		break;
 	case -ETIMEDOUT:
-		CNETERR("Connection to %s at host %pI4h on port %d took too long: that node may be hung or experiencing high load.\n",
-			libcfs_nid2str(peer_nid),
-			&peer_ip, peer_port);
+		CNETERR("Connection to %s at host %pISp took too long: that node may be hung or experiencing high load.\n",
+			libcfs_nid2str(peer_nid), sa);
 		break;
 	case -ECONNRESET:
-		LCONSOLE_ERROR_MSG(0x11b, "Connection to %s at host %pI4h on port %d was reset: is it running a compatible version of Lustre and is %s one of its NIDs?\n",
-				   libcfs_nid2str(peer_nid),
-				   &peer_ip, peer_port,
+		LCONSOLE_ERROR_MSG(0x11b,
+				   "Connection to %s at host %pISp was reset: is it running a compatible version of Lustre and is %s one of its NIDs?\n",
+				   libcfs_nid2str(peer_nid), sa,
 				   libcfs_nid2str(peer_nid));
 		break;
 	case -EPROTO:
-		LCONSOLE_ERROR_MSG(0x11c, "Protocol error connecting to %s at host %pI4h on port %d: is it running a compatible version of Lustre?\n",
-				   libcfs_nid2str(peer_nid),
-				   &peer_ip, peer_port);
+		LCONSOLE_ERROR_MSG(0x11c,
+				   "Protocol error connecting to %s at host %pISp: is it running a compatible version of Lustre?\n",
+				   libcfs_nid2str(peer_nid), sa);
 		break;
 	case -EADDRINUSE:
-		LCONSOLE_ERROR_MSG(0x11d, "No privileged ports available to connect to %s at host %pI4h on port %d\n",
-				   libcfs_nid2str(peer_nid),
-				   &peer_ip, peer_port);
+		LCONSOLE_ERROR_MSG(0x11d,
+				   "No privileged ports available to connect to %s at host %pISp\n",
+				   libcfs_nid2str(peer_nid), sa);
 		break;
 	default:
-		LCONSOLE_ERROR_MSG(0x11e, "Unexpected error %d connecting to %s at host %pI4h on port %d\n",
-				   rc, libcfs_nid2str(peer_nid),
-				   &peer_ip, peer_port);
+		LCONSOLE_ERROR_MSG(0x11e,
+				   "Unexpected error %d connecting to %s at host %pISp\n",
+				   rc, libcfs_nid2str(peer_nid), sa);
 		break;
 	}
 }
 EXPORT_SYMBOL(lnet_connect_console_error);
 
 struct socket *
-lnet_connect(lnet_nid_t peer_nid, int interface, u32 peer_ip,
-	     int peer_port, struct net *ns)
+lnet_connect(lnet_nid_t peer_nid, int interface, struct sockaddr *peeraddr,
+	     struct net *ns)
 {
 	struct lnet_acceptor_connreq cr;
 	struct socket *sock;
@@ -141,16 +140,13 @@ struct socket *
 
 	BUILD_BUG_ON(sizeof(cr) > 16);		/* too big to be on the stack */
 
+	LASSERT(peeraddr->sa_family == AF_INET);
+
 	for (port = LNET_ACCEPTOR_MAX_RESERVED_PORT;
 	     port >= LNET_ACCEPTOR_MIN_RESERVED_PORT;
 	     --port) {
 		/* Iterate through reserved ports. */
-		struct sockaddr_in paddr = { .sin_family = AF_INET };
-
-		paddr.sin_addr.s_addr = htonl(peer_ip);
-		paddr.sin_port = htons(peer_port);
-		sock = lnet_sock_connect(interface, port,
-					 (struct sockaddr *)&paddr, ns);
+		sock = lnet_sock_connect(interface, port, peeraddr, ns);
 		if (IS_ERR(sock)) {
 			rc = PTR_ERR(sock);
 			if (rc == -EADDRINUSE || rc == -EADDRNOTAVAIL)
@@ -186,7 +182,7 @@ struct socket *
 failed_sock:
 	sock_release(sock);
 failed:
-	lnet_connect_console_error(rc, peer_nid, peer_ip, peer_port);
+	lnet_connect_console_error(rc, peer_nid, peeraddr);
 	return ERR_PTR(rc);
 }
 EXPORT_SYMBOL(lnet_connect);
@@ -195,8 +191,7 @@ struct socket *
 lnet_accept(struct socket *sock, u32 magic)
 {
 	struct lnet_acceptor_connreq cr;
-	u32 peer_ip;
-	int peer_port;
+	struct sockaddr_storage peer;
 	int rc;
 	int flip;
 	struct lnet_ni *ni;
@@ -204,7 +199,7 @@ struct socket *
 
 	LASSERT(sizeof(cr) <= 16);		/* not too big for the stack */
 
-	rc = lnet_sock_getaddr(sock, 1, &peer_ip, &peer_port);
+	rc = lnet_sock_getaddr(sock, true, &peer);
 	LASSERT(!rc);				/* we succeeded before */
 
 	if (!lnet_accept_magic(magic, LNET_PROTO_ACCEPTOR_MAGIC)) {
@@ -222,8 +217,8 @@ struct socket *
 					     accept_timeout);
 
 			if (rc)
-				CERROR("Error sending magic+version in response to LNET magic from %pI4h: %d\n",
-				       &peer_ip, rc);
+				CERROR("Error sending magic+version in response to LNET magic from %pIS: %d\n",
+				       &peer, rc);
 			return -EPROTO;
 		}
 
@@ -232,8 +227,9 @@ struct socket *
 		else
 			str = "unrecognised";
 
-		LCONSOLE_ERROR_MSG(0x11f, "Refusing connection from %pI4h magic %08x: %s acceptor protocol\n",
-				   &peer_ip, magic, str);
+		LCONSOLE_ERROR_MSG(0x11f,
+				   "Refusing connection from %pIS magic %08x: %s acceptor protocol\n",
+				   &peer, magic, str);
 		return -EPROTO;
 	}
 
@@ -242,8 +238,8 @@ struct socket *
 	rc = lnet_sock_read(sock, &cr.acr_version, sizeof(cr.acr_version),
 			    accept_timeout);
 	if (rc) {
-		CERROR("Error %d reading connection request version from %pI4h\n",
-		       rc, &peer_ip);
+		CERROR("Error %d reading connection request version from %pIS\n",
+		       rc, &peer);
 		return -EIO;
 	}
 
@@ -265,8 +261,8 @@ struct socket *
 
 		rc = lnet_sock_write(sock, &cr, sizeof(cr), accept_timeout);
 		if (rc)
-			CERROR("Error sending magic+version in response to version %d from %pI4h: %d\n",
-			       peer_version, &peer_ip, rc);
+			CERROR("Error sending magic+version in response to version %d from %pIS: %d\n",
+			       peer_version, &peer, rc);
 		return -EPROTO;
 	}
 
@@ -275,8 +271,8 @@ struct socket *
 			    offsetof(struct lnet_acceptor_connreq, acr_nid),
 			    accept_timeout);
 	if (rc) {
-		CERROR("Error %d reading connection request from %pI4h\n",
-		       rc, &peer_ip);
+		CERROR("Error %d reading connection request from %pIS\n",
+		       rc, &peer);
 		return -EIO;
 	}
 
@@ -288,21 +284,23 @@ struct socket *
 	    ni->ni_nid != cr.acr_nid) { /* right NET, wrong NID! */
 		if (ni)
 			lnet_ni_decref(ni);
-		LCONSOLE_ERROR_MSG(0x120, "Refusing connection from %pI4h for %s: No matching NI\n",
-				   &peer_ip, libcfs_nid2str(cr.acr_nid));
+		LCONSOLE_ERROR_MSG(0x120,
+				   "Refusing connection from %pIS for %s: No matching NI\n",
+				   &peer, libcfs_nid2str(cr.acr_nid));
 		return -EPERM;
 	}
 
 	if (!ni->ni_net->net_lnd->lnd_accept) {
 		/* This catches a request for the loopback LND */
 		lnet_ni_decref(ni);
-		LCONSOLE_ERROR_MSG(0x121, "Refusing connection from %pI4h for %s: NI doesn not accept IP connections\n",
-				   &peer_ip, libcfs_nid2str(cr.acr_nid));
+		LCONSOLE_ERROR_MSG(0x121,
+				   "Refusing connection from %pIS for %s: NI doesn not accept IP connections\n",
+				   &peer, libcfs_nid2str(cr.acr_nid));
 		return -EPERM;
 	}
 
-	CDEBUG(D_NET, "Accept %s from %pI4h\n",
-	       libcfs_nid2str(cr.acr_nid), &peer_ip);
+	CDEBUG(D_NET, "Accept %s from %pIS\n",
+	       libcfs_nid2str(cr.acr_nid), &peer);
 
 	rc = ni->ni_net->net_lnd->lnd_accept(ni, sock);
 
@@ -326,8 +324,7 @@ static void lnet_acceptor_ready(struct sock *sk)
 	struct socket *newsock;
 	int rc;
 	u32 magic;
-	u32 peer_ip;
-	int peer_port;
+	struct sockaddr_storage peer;
 	int secure = (int)((long)arg);
 
 	LASSERT(!lnet_acceptor_state.pta_sock);
@@ -387,23 +384,25 @@ static void lnet_acceptor_ready(struct sock *sk)
 		/* make sure we call lnet_sock_accept() again, until it fails */
 		atomic_set(&lnet_acceptor_state.pta_ready, 1);
 
-		rc = lnet_sock_getaddr(newsock, 1, &peer_ip, &peer_port);
+		rc = lnet_sock_getaddr(newsock, true, &peer);
 		if (rc) {
 			CERROR("Can't determine new connection's address\n");
 			goto failed;
 		}
 
-		if (secure && peer_port > LNET_ACCEPTOR_MAX_RESERVED_PORT) {
-			CERROR("Refusing connection from %pI4h: insecure port %d\n",
-			       &peer_ip, peer_port);
+		if (secure &&
+		    rpc_get_port((struct sockaddr *)&peer) >
+		    LNET_ACCEPTOR_MAX_RESERVED_PORT) {
+			CERROR("Refusing connection from %pISp: insecure port\n",
+			       &peer);
 			goto failed;
 		}
 
 		rc = lnet_sock_read(newsock, &magic, sizeof(magic),
 				    accept_timeout);
 		if (rc) {
-			CERROR("Error %d reading connection request from %pI4h\n",
-			       rc, &peer_ip);
+			CERROR("Error %d reading connection request from %pIS\n",
+			       rc, &peer);
 			goto failed;
 		}
 
diff --git a/net/lnet/lnet/lib-socket.c b/net/lnet/lnet/lib-socket.c
index e082b52..5c5366f 100644
--- a/net/lnet/lnet/lib-socket.c
+++ b/net/lnet/lnet/lib-socket.c
@@ -267,27 +267,21 @@ int choose_ipv4_src(__u32 *ret, int interface, __u32 dst_ipaddr, struct net *ns)
 EXPORT_SYMBOL(lnet_sock_setbuf);
 
 int
-lnet_sock_getaddr(struct socket *sock, bool remote, u32 *ip, int *port)
+lnet_sock_getaddr(struct socket *sock, bool remote,
+		  struct sockaddr_storage *peer)
 {
-	struct sockaddr_in sin;
 	int rc;
 
 	if (remote)
-		rc = kernel_getpeername(sock, (struct sockaddr *)&sin);
+		rc = kernel_getpeername(sock, (struct sockaddr *)peer);
 	else
-		rc = kernel_getsockname(sock, (struct sockaddr *)&sin);
+		rc = kernel_getsockname(sock, (struct sockaddr *)peer);
 	if (rc < 0) {
 		CERROR("Error %d getting sock %s IP/port\n",
 		       rc, remote ? "peer" : "local");
 		return rc;
 	}
 
-	if (ip)
-		*ip = ntohl(sin.sin_addr.s_addr);
-
-	if (port)
-		*port = ntohs(sin.sin_port);
-
 	return 0;
 }
 EXPORT_SYMBOL(lnet_sock_getaddr);
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
