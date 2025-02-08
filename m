Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 29247C02199
	for <lustre-devel@archiver.kernel.org>; Sat,  8 Feb 2025 00:37:12 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4YqWwG4FtWz1y26;
	Fri, 07 Feb 2025 16:30:54 -0800 (PST)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4YqWw21XQcz1xPM
 for <lustre-devel@lists.lustre.org>; Fri, 07 Feb 2025 16:30:42 -0800 (PST)
Received: from star2.ccs.ornl.gov (ltm-e204-208.ccs.ornl.gov [160.91.203.12])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 078D388F9E9;
 Fri,  7 Feb 2025 19:30:33 -0500 (EST)
Received: by star2.ccs.ornl.gov (Postfix, from userid 2004)
 id 04586106BE17; Fri,  7 Feb 2025 19:30:33 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Fri,  7 Feb 2025 19:30:15 -0500
Message-ID: <20250208003027.180076-10-jsimmons@infradead.org>
X-Mailer: git-send-email 2.43.5
In-Reply-To: <20250208003027.180076-1-jsimmons@infradead.org>
References: <20250208003027.180076-1-jsimmons@infradead.org>
MIME-Version: 1.0
Subject: [lustre-devel] [PATCH 09/21] lnet: socklnd: remove ksnr_myiface
 from ksock_conn_cb
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

Drop ksnr_myiface: it is no longer needed since socklnd
TCP bonding got removed. There's one interface per
connection cb per peer_ni, and it can be accessed as
net->ksnn_interface.ksni_index.

Fix setting of ksni_nroutes accordingly. Duplication of
interface index in conn_cb and ksnn_interface was causing
the assertion
        ASSERTION( net->ksnn_interface.ksni_nroutes == 0 )
in ksocknal_shutdown() to fail if the corresponding
device is deregistered before lnd shutdown.

Fixes: a669fa61 ("lnet: handles unregister/register events)
WC-bug-id: https://jira.whamcloud.com/browse/LU-16850
Lustre-commit: f6be07c457385cfac ("LU-16850 socklnd: remove ksnr_myiface from ksock_conn_cb")
Signed-off-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/51148
Reviewed-by: Frank Sehr <fsehr@whamcloud.com>
Reviewed-by: Cyril Bordage <cbordage@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/klnds/socklnd/socklnd.c    | 130 ++--------------------------
 net/lnet/klnds/socklnd/socklnd.h    |   1 -
 net/lnet/klnds/socklnd/socklnd_cb.c |   4 +-
 3 files changed, 12 insertions(+), 123 deletions(-)

diff --git a/net/lnet/klnds/socklnd/socklnd.c b/net/lnet/klnds/socklnd/socklnd.c
index 435762f84f27..6028520308ff 100644
--- a/net/lnet/klnds/socklnd/socklnd.c
+++ b/net/lnet/klnds/socklnd/socklnd.c
@@ -47,79 +47,6 @@
 static struct lnet_lnd the_ksocklnd;
 struct ksock_nal_data ksocknal_data;
 
-static struct ksock_interface *
-ksocknal_index2iface(struct lnet_ni *ni, int index)
-{
-	struct ksock_net *net = ni->ni_data;
-	struct ksock_interface *iface;
-
-	iface = &net->ksnn_interface;
-
-	if (iface->ksni_index == index)
-		return iface;
-
-	return NULL;
-}
-
-static int ksocknal_ip2index(struct sockaddr *addr, struct lnet_ni *ni)
-{
-	struct net_device *dev;
-	int ret = -1;
-	const struct in_ifaddr *ifa;
-
-	if (addr->sa_family != AF_INET && addr->sa_family != AF_INET6)
-		return ret;
-
-	rcu_read_lock();
-	for_each_netdev(ni->ni_net_ns, dev) {
-		int flags = dev_get_flags(dev);
-		struct in_device *in_dev;
-
-		if (flags & IFF_LOOPBACK) /* skip the loopback IF */
-			continue;
-
-		if (!(flags & IFF_UP))
-			continue;
-
-		switch (addr->sa_family) {
-		case AF_INET:
-			in_dev = __in_dev_get_rcu(dev);
-			if (!in_dev)
-				continue;
-
-			in_dev_for_each_ifa_rcu(ifa, in_dev) {
-				if (ifa->ifa_local ==
-				    ((struct sockaddr_in *)addr)->sin_addr.s_addr)
-					ret = dev->ifindex;
-			}
-			break;
-#if IS_ENABLED(CONFIG_IPV6)
-		case AF_INET6: {
-			struct inet6_dev *in6_dev;
-			const struct inet6_ifaddr *ifa6;
-			struct sockaddr_in6 *addr6 = (struct sockaddr_in6 *)addr;
-
-			in6_dev = __in6_dev_get(dev);
-			if (!in6_dev)
-				continue;
-
-			list_for_each_entry_rcu(ifa6, &in6_dev->addr_list, if_list) {
-				if (ipv6_addr_cmp(&ifa6->addr,
-						  &addr6->sin6_addr) == 0)
-					ret = dev->ifindex;
-			}
-			break;
-			}
-#endif /* IS_ENABLED(CONFIG_IPV6) */
-		}
-		if (ret >= 0)
-			break;
-	}
-	rcu_read_unlock();
-
-	return ret;
-}
-
 static struct ksock_conn_cb *
 ksocknal_create_conn_cb(struct sockaddr *addr)
 {
@@ -135,7 +62,6 @@ ksocknal_create_conn_cb(struct sockaddr *addr)
 	rpc_copy_addr((struct sockaddr *)&conn_cb->ksnr_addr, addr);
 	rpc_set_port((struct sockaddr *)&conn_cb->ksnr_addr,
 		     rpc_get_port(addr));
-	conn_cb->ksnr_myiface = -1;
 	conn_cb->ksnr_scheduled = 0;
 	conn_cb->ksnr_connecting = 0;
 	conn_cb->ksnr_connected = 0;
@@ -333,6 +259,7 @@ ksocknal_get_peer_info(struct lnet_ni *ni, int index,
 	struct ksock_conn_cb *conn_cb;
 	int i;
 	int rc = -ENOENT;
+	struct ksock_net *net;
 
 	read_lock(&ksocknal_data.ksnd_global_lock);
 
@@ -358,8 +285,9 @@ ksocknal_get_peer_info(struct lnet_ni *ni, int index,
 				struct sockaddr_in *sa;
 
 				sa = (void *)&conn_cb->ksnr_addr;
+				net = ni->ni_data;
 				rc = choose_ipv4_src(myip,
-						     conn_cb->ksnr_myiface,
+						     net->ksnn_interface.ksni_index,
 						     ntohl(sa->sin_addr.s_addr),
 						     ni->ni_net_ns);
 				*peer_ip = ntohl(sa->sin_addr.s_addr);
@@ -500,45 +428,10 @@ static void
 ksocknal_associate_cb_conn_locked(struct ksock_conn_cb *conn_cb,
 				  struct ksock_conn *conn)
 {
-	struct ksock_peer_ni *peer_ni = conn_cb->ksnr_peer;
 	int type = conn->ksnc_type;
-	struct ksock_interface *iface;
-	int conn_iface;
 
-	conn_iface = ksocknal_ip2index((struct sockaddr *)&conn->ksnc_myaddr,
-				       peer_ni->ksnp_ni);
 	conn->ksnc_conn_cb = conn_cb;
 	ksocknal_conn_cb_addref(conn_cb);
-
-	if (conn_cb->ksnr_myiface != conn_iface) {
-		if (conn_cb->ksnr_myiface < 0) {
-			/* conn_cb wasn't bound locally yet (the initial
-			 * conn_cb)
-			 */
-			CDEBUG(D_NET, "Binding %s %pISc to interface %d\n",
-			       libcfs_idstr(&peer_ni->ksnp_id),
-			       &conn_cb->ksnr_addr,
-			       conn_iface);
-		} else {
-			CDEBUG(D_NET,
-			       "Rebinding %s %pISc from interface %d to %d\n",
-			       libcfs_idstr(&peer_ni->ksnp_id),
-			       &conn_cb->ksnr_addr,
-			       conn_cb->ksnr_myiface,
-			       conn_iface);
-
-			iface = ksocknal_index2iface(peer_ni->ksnp_ni,
-						     conn_cb->ksnr_myiface);
-			if (iface)
-				iface->ksni_nroutes--;
-		}
-		conn_cb->ksnr_myiface = conn_iface;
-		iface = ksocknal_index2iface(peer_ni->ksnp_ni,
-					     conn_cb->ksnr_myiface);
-		if (iface)
-			iface->ksni_nroutes++;
-	}
-
 	ksocknal_incr_conn_count(conn_cb, type);
 
 	/* Successful connection => further attempts can
@@ -563,18 +456,16 @@ ksocknal_add_conn_cb_locked(struct ksock_peer_ni *peer_ni,
 	conn_cb->ksnr_peer = peer_ni;
 	ksocknal_peer_addref(peer_ni);
 
-	/* set the conn_cb's interface to the current net's interface */
-	conn_cb->ksnr_myiface = net->ksnn_interface.ksni_index;
-	net->ksnn_interface.ksni_nroutes++;
-
 	/* peer_ni's route list takes over my ref on 'route' */
 	peer_ni->ksnp_conn_cb = conn_cb;
+	net->ksnn_interface.ksni_nroutes++;
 
 	list_for_each_entry(conn, &peer_ni->ksnp_conns, ksnc_list) {
 		if (!rpc_cmp_addr((struct sockaddr *)&conn->ksnc_peeraddr,
 				  (struct sockaddr *)&conn_cb->ksnr_addr))
 			continue;
 
+		CDEBUG(D_NET, "call ksocknal_associate_cb_conn_locked\n");
 		ksocknal_associate_cb_conn_locked(conn_cb, conn);
 		/* keep going (typed conns) */
 	}
@@ -584,9 +475,9 @@ static void
 ksocknal_del_conn_cb_locked(struct ksock_conn_cb *conn_cb)
 {
 	struct ksock_peer_ni *peer_ni = conn_cb->ksnr_peer;
-	struct ksock_interface *iface;
 	struct ksock_conn *conn;
 	struct ksock_conn *cnxt;
+	struct ksock_net *net;
 
 	LASSERT(!conn_cb->ksnr_deleted);
 
@@ -598,12 +489,9 @@ ksocknal_del_conn_cb_locked(struct ksock_conn_cb *conn_cb)
 		ksocknal_close_conn_locked(conn, 0);
 	}
 
-	if (conn_cb->ksnr_myiface >= 0) {
-		iface = ksocknal_index2iface(peer_ni->ksnp_ni,
-					     conn_cb->ksnr_myiface);
-		if (iface)
-			iface->ksni_nroutes--;
-	}
+	net = (struct ksock_net *)(peer_ni->ksnp_ni->ni_data);
+	net->ksnn_interface.ksni_nroutes--;
+	LASSERT(net->ksnn_interface.ksni_nroutes >= 0);
 
 	conn_cb->ksnr_deleted = 1;
 	ksocknal_conn_cb_decref(conn_cb);	/* drop peer_ni's ref */
diff --git a/net/lnet/klnds/socklnd/socklnd.h b/net/lnet/klnds/socklnd/socklnd.h
index 50892b1af344..1c95cfe4bb50 100644
--- a/net/lnet/klnds/socklnd/socklnd.h
+++ b/net/lnet/klnds/socklnd/socklnd.h
@@ -398,7 +398,6 @@ struct ksock_conn_cb {
 							 * can happen next
 							 */
 	time64_t		ksnr_retry_interval;	/* how long between retries */
-	int			ksnr_myiface;		/* my IP */
 	struct sockaddr_storage	ksnr_addr;		/* IP address to connect to */
 	unsigned int		ksnr_scheduled:1;	/* scheduled for attention */
 	unsigned int		ksnr_connecting:1;	/* connection establishment in
diff --git a/net/lnet/klnds/socklnd/socklnd_cb.c b/net/lnet/klnds/socklnd/socklnd_cb.c
index 17ea0cca9255..f04e87a444ba 100644
--- a/net/lnet/klnds/socklnd/socklnd_cb.c
+++ b/net/lnet/klnds/socklnd/socklnd_cb.c
@@ -1795,6 +1795,7 @@ ksocknal_connect(struct ksock_conn_cb *conn_cb)
 	time64_t deadline;
 	bool retry_later = 0;
 	int rc = 0;
+	struct ksock_net *net;
 
 	deadline = ktime_get_seconds() + ksocknal_timeout();
 
@@ -1850,8 +1851,9 @@ ksocknal_connect(struct ksock_conn_cb *conn_cb)
 			goto failed;
 		}
 
+		net = (struct ksock_net *)(peer_ni->ksnp_ni->ni_data);
 		sock = lnet_connect(&peer_ni->ksnp_id.nid,
-				    conn_cb->ksnr_myiface,
+				    net->ksnn_interface.ksni_index,
 				    (struct sockaddr *)&conn_cb->ksnr_addr,
 				    peer_ni->ksnp_ni->ni_net_ns);
 		if (IS_ERR(sock)) {
-- 
2.39.3

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
