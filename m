Return-Path: <SRS0=Gt0B=JW=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.7 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0ABD6C433B4
	for <lustre-devel@archiver.kernel.org>; Sun, 25 Apr 2021 20:09:02 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id C033D611CC
	for <lustre-devel@archiver.kernel.org>; Sun, 25 Apr 2021 20:09:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C033D611CC
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 5E28E21F86A;
	Sun, 25 Apr 2021 13:08:54 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id F1AD821F513
 for <lustre-devel@lists.lustre.org>; Sun, 25 Apr 2021 13:08:42 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 0FD8F10084F5;
 Sun, 25 Apr 2021 16:08:40 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 0414369A8C; Sun, 25 Apr 2021 16:08:40 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 25 Apr 2021 16:08:12 -0400
Message-Id: <1619381316-7719-6-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1619381316-7719-1-git-send-email-jsimmons@infradead.org>
References: <1619381316-7719-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 05/29] lnet: socklnd: remove tcp bonding
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

TCP bonding in the socklnd has become obsolete with LNet
Multi-Rail and there's no evidence it's being used anywhere.
Remove it to keep the code simple.

WC-bug-id: https://jira.whamcloud.com/browse/LU-13641
Lustre-commit: d123c47a18adbf56 ("LU-13641 socklnd: remove tcp bonding")
Signed-off-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/40000
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Chris Horn <chris.horn@hpe.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/lib-lnet.h      |   3 +-
 include/linux/lnet/lib-types.h     |   5 +-
 include/uapi/linux/lnet/lnet-dlc.h |   5 +-
 net/lnet/klnds/o2iblnd/o2iblnd.c   |  16 +-
 net/lnet/klnds/socklnd/socklnd.c   | 683 +++----------------------------------
 net/lnet/klnds/socklnd/socklnd.h   |   3 +-
 net/lnet/lnet/api-ni.c             |  58 +---
 net/lnet/lnet/config.c             |  58 +---
 8 files changed, 91 insertions(+), 740 deletions(-)

diff --git a/include/linux/lnet/lib-lnet.h b/include/linux/lnet/lib-lnet.h
index 2e88d80..4712e2d 100644
--- a/include/linux/lnet/lib-lnet.h
+++ b/include/linux/lnet/lib-lnet.h
@@ -793,8 +793,7 @@ int lnet_push_target_post(struct lnet_ping_buffer *pbuf,
 
 int lnet_parse_ip2nets(const char **networksp, const char *ip2nets);
 int lnet_parse_routes(const char *route_str, int *im_a_router);
-int lnet_parse_networks(struct list_head *nilist, const char *networks,
-			bool use_tcp_bonding);
+int lnet_parse_networks(struct list_head *nilist, const char *networks);
 bool lnet_net_unique(u32 net_id, struct list_head *nilist,
 		     struct lnet_net **net);
 bool lnet_ni_unique_net(struct list_head *nilist, char *iface);
diff --git a/include/linux/lnet/lib-types.h b/include/linux/lnet/lib-types.h
index ce067b3..f479efe 100644
--- a/include/linux/lnet/lib-types.h
+++ b/include/linux/lnet/lib-types.h
@@ -496,10 +496,9 @@ struct lnet_ni {
 	u32			ni_sel_priority;
 
 	/*
-	 * equivalent interfaces to use
-	 * This is an array because socklnd bonding can still be configured
+	 * equivalent interface to use
 	 */
-	char			*ni_interfaces[LNET_INTERFACES_NUM];
+	char			*ni_interface;
 	/* original net namespace */
 	struct net		*ni_net_ns;
 };
diff --git a/include/uapi/linux/lnet/lnet-dlc.h b/include/uapi/linux/lnet/lnet-dlc.h
index e775dfe..b375d0a 100644
--- a/include/uapi/linux/lnet/lnet-dlc.h
+++ b/include/uapi/linux/lnet/lnet-dlc.h
@@ -93,7 +93,7 @@ struct lnet_ioctl_config_lnd_tunables {
 };
 
 struct lnet_ioctl_net_config {
-	char ni_interfaces[LNET_INTERFACES_NUM][LNET_MAX_STR_LEN];
+	char ni_interface[LNET_MAX_STR_LEN];
 	__u32 ni_status;
 	__u32 ni_cpts[LNET_MAX_SHOW_NUM_CPT];
 	char cfg_bulk[0];
@@ -222,12 +222,11 @@ struct lnet_ioctl_element_msg_stats {
 struct lnet_ioctl_config_ni {
 	struct libcfs_ioctl_hdr lic_cfg_hdr;
 	lnet_nid_t		lic_nid;
-	char			lic_ni_intf[LNET_INTERFACES_NUM][LNET_MAX_STR_LEN];
+	char			lic_ni_intf[LNET_MAX_STR_LEN];
 	char			lic_legacy_ip2nets[LNET_MAX_STR_LEN];
 	__u32			lic_cpts[LNET_MAX_SHOW_NUM_CPT];
 	__u32			lic_ncpts;
 	__u32			lic_status;
-	__u32			lic_tcp_bonding;
 	__u32			lic_idx;
 	__s32			lic_dev_cpt;
 	char			pad[4];
diff --git a/net/lnet/klnds/o2iblnd/o2iblnd.c b/net/lnet/klnds/o2iblnd/o2iblnd.c
index 01cc1ed..782e29b 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd.c
+++ b/net/lnet/klnds/o2iblnd/o2iblnd.c
@@ -2822,20 +2822,12 @@ static int kiblnd_startup(struct lnet_ni *ni)
 	if (rc)
 		goto net_failed;
 
-	/* ni_interfaces is only to support legacy pre Multi-Rail
-	 * tcp bonding for ksocklnd. Multi-Rail wants each secondary
-	 * IP to be treated as an unique 'struct ni' interfaces instead.
+	/* Multi-Rail wants each secondary
+	 * IP to be treated as an unique 'struct ni' interface.
 	 */
-	if (ni->ni_interfaces[0]) {
+	if (ni->ni_interface) {
 		/* Use the IPoIB interface specified in 'networks=' */
-
-		if (ni->ni_interfaces[1]) {
-			CERROR("ko2iblnd: Multiple interfaces not supported\n");
-			rc = -EINVAL;
-			goto failed;
-		}
-
-		ifname = ni->ni_interfaces[0];
+		ifname = ni->ni_interface;
 	} else {
 		ifname = *kiblnd_tunables.kib_default_ipif;
 	}
diff --git a/net/lnet/klnds/socklnd/socklnd.c b/net/lnet/klnds/socklnd/socklnd.c
index d5fe84d..55d1ba5 100644
--- a/net/lnet/klnds/socklnd/socklnd.c
+++ b/net/lnet/klnds/socklnd/socklnd.c
@@ -50,16 +50,12 @@
 ksocknal_ip2iface(struct lnet_ni *ni, struct sockaddr *addr)
 {
 	struct ksock_net *net = ni->ni_data;
-	int i;
 	struct ksock_interface *iface;
 
-	for (i = 0; i < net->ksnn_ninterfaces; i++) {
-		LASSERT(i < LNET_INTERFACES_NUM);
-		iface = &net->ksnn_interfaces[i];
+	iface = &net->ksnn_interface;
 
-		if (rpc_cmp_addr((struct sockaddr *)&iface->ksni_addr, addr))
-			return iface;
-	}
+	if (rpc_cmp_addr((struct sockaddr *)&iface->ksni_addr, addr))
+		return iface;
 
 	return NULL;
 }
@@ -68,16 +64,12 @@
 ksocknal_index2iface(struct lnet_ni *ni, int index)
 {
 	struct ksock_net *net = ni->ni_data;
-	int i;
 	struct ksock_interface *iface;
 
-	for (i = 0; i < net->ksnn_ninterfaces; i++) {
-		LASSERT(i < LNET_INTERFACES_NUM);
-		iface = &net->ksnn_interfaces[i];
+	iface = &net->ksnn_interface;
 
-		if (iface->ksni_index == index)
-			return iface;
-	}
+	if (iface->ksni_index == index)
+		return iface;
 
 	return NULL;
 }
@@ -436,7 +428,6 @@ struct ksock_peer_ni *
 	LASSERT(!route->ksnr_scheduled);
 	LASSERT(!route->ksnr_connecting);
 	LASSERT(!route->ksnr_connected);
-	LASSERT(net->ksnn_ninterfaces > 0);
 
 	/* LASSERT(unique) */
 	list_for_each_entry(route2, &peer_ni->ksnp_routes, ksnr_list) {
@@ -453,8 +444,8 @@ struct ksock_peer_ni *
 	ksocknal_peer_addref(peer_ni);
 
 	/* set the route's interface to the current net's interface */
-	route->ksnr_myiface = net->ksnn_interfaces[0].ksni_index;
-	net->ksnn_interfaces[0].ksni_nroutes++;
+	route->ksnr_myiface = net->ksnn_interface.ksni_index;
+	net->ksnn_interface.ksni_nroutes++;
 
 	/* peer_ni's routelist takes over my ref on 'route' */
 	list_add_tail(&route->ksnr_list, &peer_ni->ksnp_routes);
@@ -730,332 +721,6 @@ struct ksock_peer_ni *
 	return sched;
 }
 
-static int
-ksocknal_local_ipvec(struct lnet_ni *ni, u32 *ipaddrs)
-{
-	struct ksock_net *net = ni->ni_data;
-	int i, j;
-	int nip;
-
-	read_lock(&ksocknal_data.ksnd_global_lock);
-
-	nip = net->ksnn_ninterfaces;
-	LASSERT(nip <= LNET_INTERFACES_NUM);
-
-	for (i = 0, j = 0; i < nip; i++)
-		if (net->ksnn_interfaces[i].ksni_addr.ss_family == AF_INET) {
-			struct sockaddr_in *sa =
-				(void *)&net->ksnn_interfaces[i].ksni_addr;
-
-			ipaddrs[j] = ntohl(sa->sin_addr.s_addr);
-			LASSERT(ipaddrs[j] != 0);
-			j += 1;
-		}
-	nip = j;
-
-	read_unlock(&ksocknal_data.ksnd_global_lock);
-	/*
-	 * Only offer interfaces for additional connections if I have
-	 * more than one.
-	 */
-	return nip < 2 ? 0 : nip;
-}
-
-static int
-ksocknal_match_peerip(struct ksock_interface *iface, u32 *ips, int nips)
-{
-	int best_netmatch = 0;
-	int best_xor = 0;
-	int best = -1;
-	int this_xor;
-	int this_netmatch;
-	int i;
-	struct sockaddr_in *sa;
-	u32 ip;
-
-	sa = (struct sockaddr_in *)&iface->ksni_addr;
-	LASSERT(sa->sin_family == AF_INET);
-	ip = ntohl(sa->sin_addr.s_addr);
-
-	for (i = 0; i < nips; i++) {
-		if (!ips[i])
-			continue;
-
-		this_xor = ips[i] ^ ip;
-		this_netmatch = !(this_xor & iface->ksni_netmask) ? 1 : 0;
-
-		if (!(best < 0 ||
-		      best_netmatch < this_netmatch ||
-		      (best_netmatch == this_netmatch &&
-		       best_xor > this_xor)))
-			continue;
-
-		best = i;
-		best_netmatch = this_netmatch;
-		best_xor = this_xor;
-	}
-
-	LASSERT(best >= 0);
-	return best;
-}
-
-static int
-ksocknal_select_ips(struct ksock_peer_ni *peer_ni, u32 *peerips, int n_peerips)
-{
-	rwlock_t *global_lock = &ksocknal_data.ksnd_global_lock;
-	struct ksock_net *net = peer_ni->ksnp_ni->ni_data;
-	struct ksock_interface *iface;
-	struct ksock_interface *best_iface;
-	int n_ips;
-	int i;
-	int j;
-	int k;
-	u32 ip;
-	u32 xor;
-	int this_netmatch;
-	int best_netmatch;
-	int best_npeers;
-
-	/*
-	 * CAVEAT EMPTOR: We do all our interface matching with an
-	 * exclusive hold of global lock at IRQ priority.  We're only
-	 * expecting to be dealing with small numbers of interfaces, so the
-	 * O(n**3)-ness shouldn't matter
-	 */
-	/*
-	 * Also note that I'm not going to return more than n_peerips
-	 * interfaces, even if I have more myself
-	 */
-	write_lock_bh(global_lock);
-
-	LASSERT(n_peerips <= LNET_INTERFACES_NUM);
-	LASSERT(net->ksnn_ninterfaces <= LNET_INTERFACES_NUM);
-
-	/*
-	 * Only match interfaces for additional connections
-	 * if I have > 1 interface
-	 */
-	n_ips = (net->ksnn_ninterfaces < 2) ? 0 :
-		min(n_peerips, net->ksnn_ninterfaces);
-
-	for (i = 0; peer_ni->ksnp_n_passive_ips < n_ips; i++) {
-		/*	      ^ yes really... */
-
-		/*
-		 * If we have any new interfaces, first tick off all the
-		 * peer_ni IPs that match old interfaces, then choose new
-		 * interfaces to match the remaining peer_ni IPS.
-		 * We don't forget interfaces we've stopped using; we might
-		 * start using them again...
-		 */
-		if (i < peer_ni->ksnp_n_passive_ips) {
-			/* Old interface. */
-			struct sockaddr_in sa = { .sin_family = AF_INET};
-
-			sa.sin_addr.s_addr =
-				htonl(peer_ni->ksnp_passive_ips[i]);
-			best_iface = ksocknal_ip2iface(peer_ni->ksnp_ni,
-						       (struct sockaddr *)&sa);
-
-			/* peer_ni passive ips are kept up to date */
-			LASSERT(best_iface);
-		} else {
-			/* choose a new interface */
-			struct sockaddr_in *sa;
-
-			LASSERT(i == peer_ni->ksnp_n_passive_ips);
-
-			best_iface = NULL;
-			best_netmatch = 0;
-			best_npeers = 0;
-
-			for (j = 0; j < net->ksnn_ninterfaces; j++) {
-				iface = &net->ksnn_interfaces[j];
-				sa = (void *)&iface->ksni_addr;
-				if (sa->sin_family != AF_INET)
-					continue;
-				ip = ntohl(sa->sin_addr.s_addr);
-
-				for (k = 0;
-				     k < peer_ni->ksnp_n_passive_ips;
-				     k++)
-					if (peer_ni->ksnp_passive_ips[k] == ip)
-						break;
-
-				if (k < peer_ni->ksnp_n_passive_ips)
-					/* using it already */
-					continue;
-
-				k = ksocknal_match_peerip(iface, peerips,
-							  n_peerips);
-				xor = ip ^ peerips[k];
-				this_netmatch = !(xor & iface->ksni_netmask) ? 1 : 0;
-
-				if (!(!best_iface ||
-				      best_netmatch < this_netmatch ||
-				      (best_netmatch == this_netmatch &&
-				       best_npeers > iface->ksni_npeers)))
-					continue;
-
-				best_iface = iface;
-				best_netmatch = this_netmatch;
-				best_npeers = iface->ksni_npeers;
-			}
-
-			LASSERT(best_iface);
-
-			best_iface->ksni_npeers++;
-			sa = (void *)&best_iface->ksni_addr;
-			ip = ntohl(sa->sin_addr.s_addr);
-			peer_ni->ksnp_passive_ips[i] = ip;
-			peer_ni->ksnp_n_passive_ips = i + 1;
-		}
-
-		/* mark the best matching peer_ni IP used */
-		j = ksocknal_match_peerip(best_iface, peerips, n_peerips);
-		peerips[j] = 0;
-	}
-
-	/* Overwrite input peer_ni IP addresses */
-	memcpy(peerips, peer_ni->ksnp_passive_ips, n_ips * sizeof(*peerips));
-
-	write_unlock_bh(global_lock);
-
-	return n_ips;
-}
-
-static void
-ksocknal_create_routes(struct ksock_peer_ni *peer_ni, int port,
-		       u32 *peer_ipaddrs, int npeer_ipaddrs)
-{
-	struct ksock_route *newroute = NULL;
-	rwlock_t *global_lock = &ksocknal_data.ksnd_global_lock;
-	struct lnet_ni *ni = peer_ni->ksnp_ni;
-	struct ksock_net *net = ni->ni_data;
-	struct ksock_route *route;
-	struct ksock_interface *iface;
-	struct ksock_interface *best_iface;
-	int best_netmatch;
-	int this_netmatch;
-	int best_nroutes;
-	int i;
-	int j;
-
-	/*
-	 * CAVEAT EMPTOR: We do all our interface matching with an
-	 * exclusive hold of global lock at IRQ priority.  We're only
-	 * expecting to be dealing with small numbers of interfaces, so the
-	 * O(n**3)-ness here shouldn't matter
-	 */
-	write_lock_bh(global_lock);
-
-	if (net->ksnn_ninterfaces < 2) {
-		/*
-		 * Only create additional connections
-		 * if I have > 1 interface
-		 */
-		write_unlock_bh(global_lock);
-		return;
-	}
-
-	LASSERT(npeer_ipaddrs <= LNET_INTERFACES_NUM);
-
-	for (i = 0; i < npeer_ipaddrs; i++) {
-		if (newroute) {
-			struct sockaddr_in *sa = (void *)&newroute->ksnr_addr;
-
-			memset(sa, 0, sizeof(*sa));
-			sa->sin_family = AF_INET;
-			sa->sin_addr.s_addr = htonl(peer_ipaddrs[i]);
-		} else {
-			struct sockaddr_in sa = {.sin_family = AF_INET};
-
-			write_unlock_bh(global_lock);
-
-			sa.sin_addr.s_addr = htonl(peer_ipaddrs[i]);
-			sa.sin_port = htons(port);
-			newroute =
-				ksocknal_create_route((struct sockaddr *)&sa);
-			if (!newroute)
-				return;
-
-			write_lock_bh(global_lock);
-		}
-
-		if (peer_ni->ksnp_closing) {
-			/* peer_ni got closed under me */
-			break;
-		}
-
-		/* Already got a route? */
-		list_for_each_entry(route, &peer_ni->ksnp_routes, ksnr_list)
-			if (rpc_cmp_addr((struct sockaddr *)&route->ksnr_addr,
-					 (struct sockaddr *)&newroute->ksnr_addr))
-				goto next_ipaddr;
-
-		best_iface = NULL;
-		best_nroutes = 0;
-		best_netmatch = 0;
-
-		LASSERT(net->ksnn_ninterfaces <= LNET_INTERFACES_NUM);
-
-		/* Select interface to connect from */
-		for (j = 0; j < net->ksnn_ninterfaces; j++) {
-			u32 iface_ip, route_ip;
-
-			iface = &net->ksnn_interfaces[j];
-
-			/* Using this interface already? */
-			list_for_each_entry(route, &peer_ni->ksnp_routes,
-					    ksnr_list)
-				if (route->ksnr_myiface == iface->ksni_index)
-					goto next_iface;
-
-			if (iface->ksni_addr.ss_family != AF_INET)
-				continue;
-			if (newroute->ksnr_addr.ss_family != AF_INET)
-				continue;
-
-			iface_ip =
-				ntohl(((struct sockaddr_in *)
-				      &iface->ksni_addr)->sin_addr.s_addr);
-			route_ip =
-				ntohl(((struct sockaddr_in *)
-				      &newroute->ksnr_addr)->sin_addr.s_addr);
-
-			this_netmatch = ((iface_ip ^ route_ip) &
-					  iface->ksni_netmask) ? 1 : 0;
-
-			if (!(!best_iface ||
-			      best_netmatch < this_netmatch ||
-			      (best_netmatch == this_netmatch &&
-			       best_nroutes > iface->ksni_nroutes)))
-				continue;
-
-			best_iface = iface;
-			best_netmatch = this_netmatch;
-			best_nroutes = iface->ksni_nroutes;
-next_iface:
-			;
-		}
-
-		if (!best_iface)
-			continue;
-
-		newroute->ksnr_myiface = best_iface->ksni_index;
-		best_iface->ksni_nroutes++;
-
-		ksocknal_add_route_locked(peer_ni, newroute);
-		newroute = NULL;
-next_ipaddr:
-		;
-	}
-
-	write_unlock_bh(global_lock);
-	if (newroute)
-		ksocknal_route_decref(newroute);
-}
-
 int
 ksocknal_accept(struct lnet_ni *ni, struct socket *sock)
 {
@@ -1177,7 +842,7 @@ struct ksock_peer_ni *
 		LASSERT(ni == peer_ni->ksnp_ni);
 
 		/* Active connection sends HELLO eagerly */
-		hello->kshm_nips = ksocknal_local_ipvec(ni, hello->kshm_ips);
+		hello->kshm_nips =  0;
 		peerid = peer_ni->ksnp_id;
 
 		write_lock_bh(global_lock);
@@ -1422,15 +1087,8 @@ struct ksock_peer_ni *
 	       &conn->ksnc_myaddr, &conn->ksnc_peeraddr,
 	       incarnation, cpt);
 
-	if (active) {
-		struct sockaddr *addr = (struct sockaddr *)&conn->ksnc_peeraddr;
-
-		/* additional routes after interface exchange? */
-		ksocknal_create_routes(peer_ni, rpc_get_port(addr),
-				       hello->kshm_ips, hello->kshm_nips);
-	} else {
-		hello->kshm_nips = ksocknal_select_ips(peer_ni, hello->kshm_ips,
-						       hello->kshm_nips);
+	if (!active) {
+		hello->kshm_nips = 0;
 		rc = ksocknal_send_hello(ni, conn, peerid.nid, hello);
 	}
 
@@ -2001,156 +1659,6 @@ static int ksocknal_push(struct lnet_ni *ni, struct lnet_process_id id)
 	return rc;
 }
 
-static int
-ksocknal_add_interface(struct lnet_ni *ni, u32 ipaddress, u32 netmask)
-{
-	struct ksock_net *net = ni->ni_data;
-	struct ksock_interface *iface;
-	struct sockaddr_in sa = { .sin_family = AF_INET };
-	int rc;
-	int i;
-	int j;
-	struct ksock_peer_ni *peer_ni;
-	struct ksock_route *route;
-
-	if (!ipaddress || !netmask)
-		return -EINVAL;
-
-	write_lock_bh(&ksocknal_data.ksnd_global_lock);
-
-	sa.sin_addr.s_addr = htonl(ipaddress);
-	iface = ksocknal_ip2iface(ni, (struct sockaddr *)&sa);
-	if (iface) {
-		/* silently ignore dups */
-		rc = 0;
-	} else if (net->ksnn_ninterfaces == LNET_INTERFACES_NUM) {
-		rc = -ENOSPC;
-	} else {
-		iface = &net->ksnn_interfaces[net->ksnn_ninterfaces++];
-
-		iface->ksni_index = ksocknal_ip2index((struct sockaddr *)&sa,
-						      ni);
-		rpc_copy_addr((struct sockaddr *)&iface->ksni_addr,
-			      (struct sockaddr *)&sa);
-		iface->ksni_netmask = netmask;
-		iface->ksni_nroutes = 0;
-		iface->ksni_npeers = 0;
-
-		hash_for_each(ksocknal_data.ksnd_peers, i, peer_ni, ksnp_list) {
-			for (j = 0; j < peer_ni->ksnp_n_passive_ips; j++)
-				if (peer_ni->ksnp_passive_ips[j] == ipaddress)
-					iface->ksni_npeers++;
-
-			list_for_each_entry(route, &peer_ni->ksnp_routes,
-					    ksnr_list) {
-				if (route->ksnr_myiface ==
-				    iface->ksni_index)
-					iface->ksni_nroutes++;
-			}
-		}
-
-		rc = 0;
-		/*
-		 * NB only new connections will pay attention to the
-		 * new interface!
-		 */
-	}
-
-	write_unlock_bh(&ksocknal_data.ksnd_global_lock);
-
-	return rc;
-}
-
-static void
-ksocknal_peer_del_interface_locked(struct ksock_peer_ni *peer_ni,
-				   u32 ipaddr, int index)
-{
-	struct ksock_route *route;
-	struct ksock_route *rnxt;
-	struct ksock_conn *conn;
-	struct ksock_conn *cnxt;
-	int i;
-	int j;
-
-	for (i = 0; i < peer_ni->ksnp_n_passive_ips; i++)
-		if (peer_ni->ksnp_passive_ips[i] == ipaddr) {
-			for (j = i + 1; j < peer_ni->ksnp_n_passive_ips; j++)
-				peer_ni->ksnp_passive_ips[j - 1] =
-					peer_ni->ksnp_passive_ips[j];
-			peer_ni->ksnp_n_passive_ips--;
-			break;
-		}
-
-	list_for_each_entry_safe(route, rnxt, &peer_ni->ksnp_routes,
-				 ksnr_list) {
-		if (route->ksnr_myiface != index)
-			continue;
-
-		if (route->ksnr_share_count) {
-			/* Manually created; keep, but unbind */
-			route->ksnr_myiface = -1;
-		} else {
-			ksocknal_del_route_locked(route);
-		}
-	}
-
-	list_for_each_entry_safe(conn, cnxt, &peer_ni->ksnp_conns, ksnc_list)
-		if (conn->ksnc_route->ksnr_myiface == index)
-			ksocknal_close_conn_locked(conn, 0);
-}
-
-static int
-ksocknal_del_interface(struct lnet_ni *ni, u32 ipaddress)
-{
-	struct ksock_net *net = ni->ni_data;
-	int rc = -ENOENT;
-	struct hlist_node *nxt;
-	struct ksock_peer_ni *peer_ni;
-	u32 this_ip;
-	struct sockaddr_in sa = {.sin_family = AF_INET };
-	int index;
-	int i;
-	int j;
-
-	sa.sin_addr.s_addr = htonl(ipaddress);
-	index = ksocknal_ip2index((struct sockaddr *)&sa, ni);
-
-	write_lock_bh(&ksocknal_data.ksnd_global_lock);
-
-	for (i = 0; i < net->ksnn_ninterfaces; i++) {
-		struct sockaddr_in *sa =
-			(void *)&net->ksnn_interfaces[i].ksni_addr;
-
-		if (sa->sin_family != AF_INET)
-			continue;
-		this_ip = ntohl(sa->sin_addr.s_addr);
-
-		if (!(!ipaddress || ipaddress == this_ip))
-			continue;
-
-		rc = 0;
-
-		for (j = i + 1; j < net->ksnn_ninterfaces; j++)
-			net->ksnn_interfaces[j - 1] =
-				net->ksnn_interfaces[j];
-
-		net->ksnn_ninterfaces--;
-
-		hash_for_each_safe(ksocknal_data.ksnd_peers, j,
-				   nxt, peer_ni, ksnp_list) {
-			if (peer_ni->ksnp_ni != ni)
-				continue;
-
-			ksocknal_peer_del_interface_locked(peer_ni,
-							   this_ip, index);
-		}
-	}
-
-	write_unlock_bh(&ksocknal_data.ksnd_global_lock);
-
-	return rc;
-}
-
 int
 ksocknal_ctl(struct lnet_ni *ni, unsigned int cmd, void *arg)
 {
@@ -2166,11 +1674,11 @@ static int ksocknal_push(struct lnet_ni *ni, struct lnet_process_id id)
 
 		read_lock(&ksocknal_data.ksnd_global_lock);
 
-		if (data->ioc_count >= (u32)net->ksnn_ninterfaces) {
+		if (data->ioc_count >= 1) {
 			rc = -ENOENT;
 		} else {
 			rc = 0;
-			iface = &net->ksnn_interfaces[data->ioc_count];
+			iface = &net->ksnn_interface;
 
 			sa = (void *)&iface->ksni_addr;
 			if (sa->sin_family == AF_INET)
@@ -2186,15 +1694,6 @@ static int ksocknal_push(struct lnet_ni *ni, struct lnet_process_id id)
 		return rc;
 	}
 
-	case IOC_LIBCFS_ADD_INTERFACE:
-		return ksocknal_add_interface(ni,
-					      data->ioc_u32[0], /* IP address */
-					      data->ioc_u32[1]); /* net mask */
-
-	case IOC_LIBCFS_DEL_INTERFACE:
-		return ksocknal_del_interface(ni,
-					      data->ioc_u32[0]); /* IP address */
-
 	case IOC_LIBCFS_GET_PEER: {
 		u32 myip = 0;
 		u32 ip = 0;
@@ -2554,7 +2053,6 @@ static int ksocknal_push(struct lnet_ni *ni, struct lnet_process_id id)
 ksocknal_shutdown(struct lnet_ni *ni)
 {
 	struct ksock_net *net = ni->ni_data;
-	int i;
 	struct lnet_process_id anyid = { 0 };
 
 	anyid.nid = LNET_NID_ANY;
@@ -2578,12 +2076,8 @@ static int ksocknal_push(struct lnet_ni *ni, struct lnet_process_id id)
 			       atomic_read(&net->ksnn_npeers) -
 			       SOCKNAL_SHUTDOWN_BIAS);
 
-
-
-	for (i = 0; i < net->ksnn_ninterfaces; i++) {
-		LASSERT(!net->ksnn_interfaces[i].ksni_npeers);
-		LASSERT(!net->ksnn_interfaces[i].ksni_nroutes);
-	}
+	LASSERT(net->ksnn_interface.ksni_npeers == 0);
+	LASSERT(net->ksnn_interface.ksni_nroutes == 0);
 
 	list_del(&net->ksnn_list);
 	kfree(net);
@@ -2596,41 +2090,31 @@ static int ksocknal_push(struct lnet_ni *ni, struct lnet_process_id id)
 static int
 ksocknal_search_new_ipif(struct ksock_net *net)
 {
+	char *ifnam = &net->ksnn_interface.ksni_name[0];
+	char *colon = strchr(ifnam, ':');
+	bool found = false;
+	struct ksock_net *tmp;
 	int new_ipif = 0;
-	int i;
-
-	for (i = 0; i < net->ksnn_ninterfaces; i++) {
-		char *ifnam = &net->ksnn_interfaces[i].ksni_name[0];
-		char *colon = strchr(ifnam, ':');
-		bool found  = false;
-		struct ksock_net *tmp;
-		int j;
 
-		if (colon) /* ignore alias device */
-			*colon = 0;
+	if (colon)
+		*colon = 0;
 
-		list_for_each_entry(tmp, &ksocknal_data.ksnd_nets, ksnn_list) {
-			for (j = 0; !found && j < tmp->ksnn_ninterfaces; j++) {
-				char *ifnam2 =
-					&tmp->ksnn_interfaces[j].ksni_name[0];
-				char *colon2 = strchr(ifnam2, ':');
+	list_for_each_entry(tmp, &ksocknal_data.ksnd_nets, ksnn_list) {
+		char *ifnam2 = &tmp->ksnn_interface.ksni_name[0];
+		char *colon2 = strchr(ifnam2, ':');
 
-				if (colon2)
-					*colon2 = 0;
-
-				found = !strcmp(ifnam, ifnam2);
-				if (colon2)
-					*colon2 = ':';
-			}
-			if (found)
-				break;
-		}
+		if (colon2)
+			*colon2 = 0;
 
-		new_ipif += !found;
-		if (colon)
-			*colon = ':';
+		found = !strcmp(ifnam, ifnam2);
+		if (colon2)
+			*colon2 = ':';
 	}
 
+	new_ipif += !found;
+	if (colon)
+		*colon = ':';
+
 	return new_ipif;
 }
 
@@ -2713,10 +2197,9 @@ static int ksocknal_push(struct lnet_ni *ni, struct lnet_process_id id)
 	struct lnet_ioctl_config_lnd_cmn_tunables *net_tunables;
 	struct ksock_interface *ksi = NULL;
 	struct lnet_inetdev *ifaces = NULL;
+	struct sockaddr_in *sa;
 	int i = 0;
 	int rc;
-	struct net_device *net_dev;
-	int node_id;
 
 	LASSERT(ni->ni_net->net_lnd == &the_ksocklnd);
 
@@ -2759,92 +2242,29 @@ static int ksocknal_push(struct lnet_ni *ni, struct lnet_process_id id)
 	if (rc < 0)
 		goto fail_1;
 
-	if (!ni->ni_interfaces[0]) {
-		struct sockaddr_in *sa;
-
-		ksi = &net->ksnn_interfaces[0];
-		sa = (void *)&ksi->ksni_addr;
-
-		/* Use the first discovered interface */
-		net->ksnn_ninterfaces = 1;
-		ni->ni_dev_cpt = ifaces[0].li_cpt;
-		memset(sa, 0, sizeof(*sa));
-		sa->sin_family = AF_INET;
-		sa->sin_addr.s_addr = htonl(ifaces[0].li_ipaddr);
-		ksi->ksni_index = ksocknal_ip2index((struct sockaddr *)sa, ni);
-		ksi->ksni_netmask = ifaces[0].li_netmask;
-		strlcpy(ksi->ksni_name, ifaces[0].li_name,
-			sizeof(ksi->ksni_name));
-	} else {
-		/* Before Multi-Rail ksocklnd would manage
-		 * multiple interfaces with its own tcp bonding.
-		 * If we encounter an old configuration using
-		 * this tcp bonding approach then we need to
-		 * handle more than one ni_interfaces.
-		 *
-		 * In Multi-Rail configuration only ONE ni_interface
-		 * should exist. Each IP alias should be mapped to
-		 * each 'struct net_ni'.
-		 */
-		for (i = 0; i < LNET_INTERFACES_NUM; i++) {
-			int j;
-
-			if (!ni->ni_interfaces[i])
+	ksi = &net->ksnn_interface;
+	/* Use the first discovered interface or look in the list */
+	if (ni->ni_interface) {
+		for (i = 0; i < rc; i++)
+			if (strcmp(ifaces[i].li_name, ni->ni_interface) == 0)
 				break;
 
-			for (j = 0; j < LNET_INTERFACES_NUM;  j++) {
-				if (i != j && ni->ni_interfaces[j] &&
-				    strcmp(ni->ni_interfaces[i],
-					   ni->ni_interfaces[j]) == 0) {
-					rc = -EEXIST;
-					CERROR("ksocklnd: found duplicate %s at %d and %d, rc = %d\n",
-					       ni->ni_interfaces[i], i, j, rc);
-					goto fail_1;
-				}
-			}
-
-			for (j = 0; j < rc; j++) {
-				struct sockaddr_in *sa;
-
-				if (strcmp(ifaces[j].li_name,
-					   ni->ni_interfaces[i]) != 0)
-					continue;
-
-				ksi = &net->ksnn_interfaces[net->ksnn_ninterfaces];
-				sa = (void *)&ksi->ksni_addr;
-				ni->ni_dev_cpt = ifaces[j].li_cpt;
-				memset(sa, 0, sizeof(*sa));
-				sa->sin_family = AF_INET;
-				sa->sin_addr.s_addr =
-					htonl(ifaces[j].li_ipaddr);
-				ksi->ksni_index =
-					ksocknal_ip2index((struct sockaddr *)sa,
-							  ni);
-				ksi->ksni_netmask = ifaces[j].li_netmask;
-				strlcpy(ksi->ksni_name, ifaces[j].li_name,
-					sizeof(ksi->ksni_name));
-				net->ksnn_ninterfaces++;
-				break;
-			}
-		}
-
-		/* ni_interfaces don't map to all network interfaces */
-		if (!ksi || net->ksnn_ninterfaces != i) {
-			CERROR("ksocklnd: requested %d but only %d interfaces found\n",
-			       i, net->ksnn_ninterfaces);
+		/* ni_interface doesn't contain the interface we want */
+		if (i == rc) {
+			CERROR("ksocklnd: failed to find interface %s\n",
+			       ni->ni_interface);
 			goto fail_1;
 		}
 	}
 
-	net_dev = dev_get_by_name(&init_net,
-				  net->ksnn_interfaces[0].ksni_name);
-	if (net_dev) {
-		node_id = dev_to_node(&net_dev->dev);
-		ni->ni_dev_cpt = cfs_cpt_of_node(lnet_cpt_table(), node_id);
-		dev_put(net_dev);
-	} else {
-		ni->ni_dev_cpt = CFS_CPT_ANY;
-	}
+	ni->ni_dev_cpt = ifaces[i].li_cpt;
+	sa = (void *)&ksi->ksni_addr;
+	memset(sa, 0, sizeof(*sa));
+	sa->sin_family = AF_INET;
+	sa->sin_addr.s_addr = htonl(ifaces[i].li_ipaddr);
+	ksi->ksni_index = ksocknal_ip2index((struct sockaddr *)sa, ni);
+	ksi->ksni_netmask = ifaces[i].li_netmask;
+	strlcpy(ksi->ksni_name, ifaces[i].li_name, sizeof(ksi->ksni_name));
 
 	/* call it before add it to ksocknal_data.ksnd_nets */
 	rc = ksocknal_net_start_threads(net, ni->ni_cpts, ni->ni_ncpts);
@@ -2856,7 +2276,6 @@ static int ksocknal_push(struct lnet_ni *ni, struct lnet_process_id id)
 	ni->ni_nid = LNET_MKNID(LNET_NIDNET(ni->ni_nid),
 				ntohl(((struct sockaddr_in *)&ksi->ksni_addr)->sin_addr.s_addr));
 	list_add(&net->ksnn_list, &ksocknal_data.ksnd_nets);
-
 	ksocknal_data.ksnd_nnets++;
 
 	return 0;
diff --git a/net/lnet/klnds/socklnd/socklnd.h b/net/lnet/klnds/socklnd/socklnd.h
index 83f0e3c..e6df3ed 100644
--- a/net/lnet/klnds/socklnd/socklnd.h
+++ b/net/lnet/klnds/socklnd/socklnd.h
@@ -169,8 +169,7 @@ struct ksock_net {
 	u64			ksnn_incarnation;	/* my epoch */
 	struct list_head	ksnn_list;		/* chain on global list */
 	atomic_t		ksnn_npeers;		/* # peers */
-	int			ksnn_ninterfaces;	/* IP interfaces */
-	struct ksock_interface	ksnn_interfaces[LNET_INTERFACES_NUM];
+	struct ksock_interface	ksnn_interface;		/* IP interface */
 };
 
 /* When the ksock_net is shut down, this bias is added to
diff --git a/net/lnet/lnet/api-ni.c b/net/lnet/lnet/api-ni.c
index 0c0b304..27640c7 100644
--- a/net/lnet/lnet/api-ni.c
+++ b/net/lnet/lnet/api-ni.c
@@ -68,10 +68,10 @@ struct lnet the_lnet = {
 module_param(rnet_htable_size, int, 0444);
 MODULE_PARM_DESC(rnet_htable_size, "size of remote network hash table");
 
-static int use_tcp_bonding = false;
+static int use_tcp_bonding;
 module_param(use_tcp_bonding, int, 0444);
 MODULE_PARM_DESC(use_tcp_bonding,
-		 "use_tcp_bonding parameter has been deprecated");
+		 "use_tcp_bonding parameter has been removed");
 
 unsigned int lnet_numa_range;
 EXPORT_SYMBOL(lnet_numa_range);
@@ -2480,19 +2480,6 @@ static void lnet_push_target_fini(void)
 	 * After than we want to delete the network being added,
 	 * to avoid a memory leak.
 	 */
-
-	/*
-	 * When a network uses TCP bonding then all its interfaces
-	 * must be specified when the network is first defined: the
-	 * TCP bonding code doesn't allow for interfaces to be added
-	 * or removed.
-	 */
-	if (net_l && net_l != net && use_tcp_bonding &&
-	    LNET_NETTYP(net_l->net_id) == SOCKLND) {
-		rc = -EINVAL;
-		goto failed0;
-	}
-
 	while ((ni = list_first_entry_or_null(&net->net_ni_added,
 					      struct lnet_ni,
 					      ni_netlist)) != NULL) {
@@ -2501,7 +2488,7 @@ static void lnet_push_target_fini(void)
 		/* make sure that the the NI we're about to start
 		 * up is actually unique. if it's not fail. */
 		if (!lnet_ni_unique_net(&net_l->net_ni_list,
-					ni->ni_interfaces[0])) {
+					ni->ni_interface)) {
 			rc = -EEXIST;
 			goto failed1;
 		}
@@ -2746,7 +2733,7 @@ void lnet_lib_exit(void)
 	}
 
 	if (use_tcp_bonding)
-		CWARN("'use_tcp_bonding' option has been deprecated. See LU-13641\n");
+		CWARN("use_tcp_bonding has been removed. Use Multi-Rail and Dynamic Discovery instead, see LU-13641\n");
 
 	/* If LNet is being initialized via DLC it is possible
 	 * that the user requests not to load module parameters (ones which
@@ -2756,8 +2743,7 @@ void lnet_lib_exit(void)
 	 * routes if it has been loaded
 	 */
 	if (!the_lnet.ln_nis_from_mod_params) {
-		rc = lnet_parse_networks(&net_head, lnet_get_networks(),
-					 use_tcp_bonding);
+		rc = lnet_parse_networks(&net_head, lnet_get_networks());
 		if (rc < 0)
 			goto err_empty_list;
 	}
@@ -2907,14 +2893,10 @@ void lnet_lib_exit(void)
 	if (!ni || !cfg_ni || !tun)
 		return;
 
-	if (ni->ni_interfaces[0]) {
-		for (i = 0; i < ARRAY_SIZE(ni->ni_interfaces); i++) {
-			if (ni->ni_interfaces[i]) {
-				strncpy(cfg_ni->lic_ni_intf[i],
-					ni->ni_interfaces[i],
-					sizeof(cfg_ni->lic_ni_intf[i]));
-			}
-		}
+	if (ni->ni_interface) {
+		strncpy(cfg_ni->lic_ni_intf,
+			ni->ni_interface,
+			sizeof(cfg_ni->lic_ni_intf));
 	}
 
 	cfg_ni->lic_nid = ni->ni_nid;
@@ -2922,7 +2904,6 @@ void lnet_lib_exit(void)
 		cfg_ni->lic_status = LNET_NI_STATUS_UP;
 	else
 		cfg_ni->lic_status = ni->ni_status->ns_status;
-	cfg_ni->lic_tcp_bonding = use_tcp_bonding;
 	cfg_ni->lic_dev_cpt = ni->ni_dev_cpt;
 
 	memcpy(&tun->lt_cmn, &ni->ni_net->net_tunables, sizeof(tun->lt_cmn));
@@ -2988,17 +2969,12 @@ void lnet_lib_exit(void)
 	if (!net_config)
 		return;
 
-	BUILD_BUG_ON(ARRAY_SIZE(ni->ni_interfaces) !=
-		     ARRAY_SIZE(net_config->ni_interfaces));
-
-	for (i = 0; i < ARRAY_SIZE(ni->ni_interfaces); i++) {
-		if (!ni->ni_interfaces[i])
-			break;
+	if (!ni->ni_interface)
+		return;
 
-		strncpy(net_config->ni_interfaces[i],
-			ni->ni_interfaces[i],
-			sizeof(net_config->ni_interfaces[i]));
-	}
+	strncpy(net_config->ni_interface,
+		ni->ni_interface,
+		sizeof(net_config->ni_interface));
 
 	config->cfg_nid = ni->ni_nid;
 	config->cfg_config_u.cfg_net.net_peer_timeout =
@@ -3339,7 +3315,7 @@ static int lnet_handle_legacy_ip2nets(char *ip2nets,
 	if (rc < 0)
 		return rc;
 
-	rc = lnet_parse_networks(&net_head, nets, use_tcp_bonding);
+	rc = lnet_parse_networks(&net_head, nets);
 	if (rc < 0)
 		return rc;
 
@@ -3404,7 +3380,7 @@ int lnet_dyn_add_ni(struct lnet_ioctl_config_ni *conf)
 	}
 
 	ni = lnet_ni_alloc_w_cpt_array(net, conf->lic_cpts, conf->lic_ncpts,
-				       conf->lic_ni_intf[0]);
+				       conf->lic_ni_intf);
 	if (!ni)
 		return -ENOMEM;
 
@@ -3523,7 +3499,7 @@ int lnet_dyn_del_ni(struct lnet_ioctl_config_ni *conf)
 	const char *nets = conf->cfg_config_u.cfg_net.net_intf;
 
 	/* Create a net/ni structures for the network string */
-	rc = lnet_parse_networks(&net_head, nets, use_tcp_bonding);
+	rc = lnet_parse_networks(&net_head, nets);
 	if (rc <= 0)
 		return rc == 0 ? -EINVAL : rc;
 
diff --git a/net/lnet/lnet/config.c b/net/lnet/lnet/config.c
index 10a7fe9..ee68c63 100644
--- a/net/lnet/lnet/config.c
+++ b/net/lnet/lnet/config.c
@@ -112,24 +112,8 @@ struct lnet_text_buf {		/* tmp struct for parsing routes */
 	list_for_each(tmp, nilist) {
 		ni = list_entry(tmp, struct lnet_ni, ni_netlist);
 
-		if (ni->ni_interfaces[0] &&
-		    strncmp(ni->ni_interfaces[0], iface, strlen(iface)) == 0)
-			return false;
-	}
-
-	return true;
-}
-
-/* check that the NI is unique to the interfaces with in the same NI.
- * This is only a consideration if use_tcp_bonding is set */
-static bool
-lnet_ni_unique_ni(char *iface_list[LNET_INTERFACES_NUM], char *iface)
-{
-	int i;
-
-	for (i = 0; i < LNET_INTERFACES_NUM; i++) {
-		if (iface_list[i] &&
-		    strncmp(iface_list[i], iface, strlen(iface)) == 0)
+		if (ni->ni_interface &&
+		    strncmp(ni->ni_interface, iface, strlen(iface)) == 0)
 			return false;
 	}
 
@@ -293,8 +277,6 @@ struct lnet_text_buf {		/* tmp struct for parsing routes */
 void
 lnet_ni_free(struct lnet_ni *ni)
 {
-	int i;
-
 	lnet_net_remove_cpts(ni->ni_cpts, ni->ni_ncpts, ni->ni_net);
 
 	if (ni->ni_refs)
@@ -305,8 +287,7 @@ struct lnet_text_buf {		/* tmp struct for parsing routes */
 
 	kfree(ni->ni_cpts);
 
-	for (i = 0; i < LNET_INTERFACES_NUM && ni->ni_interfaces[i]; i++)
-		kfree(ni->ni_interfaces[i]);
+	kfree(ni->ni_interface);
 
 	/* release reference to net namespace */
 	if (ni->ni_net_ns)
@@ -394,29 +375,25 @@ struct lnet_net *
 	if (!ni)
 		return -ENOMEM;
 
-	if (!lnet_ni_unique_ni(ni->ni_interfaces, iface))
-		return -EINVAL;
-
 	/* Allocate a separate piece of memory and copy
 	 * into it the string, so we don't have
 	 * a depencency on the tokens string.  This way we
 	 * can free the tokens at the end of the function.
-	 * The newly allocated ni_interfaces[] can be
+	 * The newly allocated ni_interface[] can be
 	 * freed when freeing the NI */
-	while (niface < LNET_INTERFACES_NUM &&
-	       ni->ni_interfaces[niface])
+	if (ni->ni_interface)
 		niface++;
 
-	if (niface >= LNET_INTERFACES_NUM) {
+	if (niface >= 1) {
 		LCONSOLE_ERROR_MSG(0x115, "Too many interfaces "
 				   "for net %s\n",
 				   libcfs_net2str(LNET_NIDNET(ni->ni_nid)));
 		return -EINVAL;
 	}
 
-	ni->ni_interfaces[niface] = kstrdup(iface, GFP_KERNEL);
+	ni->ni_interface = kstrdup(iface, GFP_KERNEL);
 
-	if (!ni->ni_interfaces[niface]) {
+	if (!ni->ni_interface) {
 		CERROR("Can't allocate net interface name\n");
 		return -ENOMEM;
 	}
@@ -572,8 +549,7 @@ struct lnet_ni *
  * nilist.
  */
 int
-lnet_parse_networks(struct list_head *netlist, const char *networks,
-		    bool use_tcp_bonding)
+lnet_parse_networks(struct list_head *netlist, const char *networks)
 {
 	struct cfs_expr_list *net_el = NULL;
 	struct cfs_expr_list *ni_el = NULL;
@@ -712,8 +688,7 @@ struct lnet_ni *
 		if (IS_ERR_OR_NULL(net))
 			goto failed;
 
-		if (!nistr ||
-		    (use_tcp_bonding && LNET_NETTYP(net_id) == SOCKLND)) {
+		if (!nistr) {
 			/*
 			 * No interface list was specified, allocate a
 			 * ni using the defaults.
@@ -792,16 +767,9 @@ struct lnet_ni *
 				goto failed_syntax;
 			}
 
-			if (use_tcp_bonding &&
-			    LNET_NETTYP(net->net_id) == SOCKLND) {
-				rc = lnet_ni_add_interface(ni, name);
-				if (rc != 0)
-					goto failed;
-			} else {
-				ni = lnet_ni_alloc(net, ni_el, name);
-				if (IS_ERR_OR_NULL(ni))
-					goto failed;
-			}
+			ni = lnet_ni_alloc(net, ni_el, name);
+			if (IS_ERR_OR_NULL(ni))
+				goto failed;
 
 			if (ni_el) {
 				if (ni_el != net_el) {
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
