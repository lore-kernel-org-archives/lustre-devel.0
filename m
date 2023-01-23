Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 18BDAC54EAA
	for <lustre-devel@archiver.kernel.org>; Mon, 23 Jan 2023 23:42:47 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4P15Vj6RX0z21Br;
	Mon, 23 Jan 2023 15:13:01 -0800 (PST)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4P15VY0HHlz1yCR
 for <lustre-devel@lists.lustre.org>; Mon, 23 Jan 2023 15:12:52 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id BE307E27;
 Mon, 23 Jan 2023 18:00:58 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id BB72058994; Mon, 23 Jan 2023 18:00:58 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon, 23 Jan 2023 18:00:54 -0500
Message-Id: <1674514855-15399-42-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1674514855-15399-1-git-send-email-jsimmons@infradead.org>
References: <1674514855-15399-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 41/42] lnet: modify lnet_inetdev to work with
 large NIDS
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

Change li_ipv6 field in struct lnet_inetdev to li_size which
now represents the size of the NID address. This will work
with the GUID of Inifiniband as well. Second change is
to store li_ipaddr always in network format. This will allow
direct comparsion between li_ipaddr and the nid_addr of
struct lnet_nid. We will ensure AF_IB will also be in the
same format as what will be stored in struct lnet_nid.
Implement setup with a NID address for the ko2iblnd LND driver.

WC-bug-id: https://jira.whamcloud.com/browse/LU-13642
Lustre-commit: 0b406c91d175b6cdb ("LU-13642 lnet: modify lnet_inetdev to work with large NIDS")
Signed-off-by: James Simmons <jsimmons@infradead.org>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/49525
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: Neil Brown <neilb@suse.de>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
---
 include/linux/lnet/lib-lnet.h        |  2 +-
 include/uapi/linux/lnet/lnet-types.h | 10 ---------
 net/lnet/klnds/o2iblnd/o2iblnd.c     | 16 ++++++++------
 net/lnet/klnds/socklnd/socklnd.c     |  6 +++---
 net/lnet/lnet/config.c               | 32 ++++++++++++++--------------
 5 files changed, 30 insertions(+), 36 deletions(-)

diff --git a/include/linux/lnet/lib-lnet.h b/include/linux/lnet/lib-lnet.h
index ed28af6fe8d5..d03dcf849bd1 100644
--- a/include/linux/lnet/lib-lnet.h
+++ b/include/linux/lnet/lib-lnet.h
@@ -832,7 +832,7 @@ struct lnet_inetdev {
 	};
 	u32	li_index;
 	bool	li_iff_master;
-	bool	li_ipv6;
+	u32	li_size;
 	char	li_name[IFNAMSIZ];
 };
 
diff --git a/include/uapi/linux/lnet/lnet-types.h b/include/uapi/linux/lnet/lnet-types.h
index 8a1d2d749b4b..6c6a66ebfd44 100644
--- a/include/uapi/linux/lnet/lnet-types.h
+++ b/include/uapi/linux/lnet/lnet-types.h
@@ -120,16 +120,6 @@ static inline bool nid_is_nid4(const struct lnet_nid *nid)
 	return NID_ADDR_BYTES(nid) == 4;
 }
 
-static inline bool nid_is_ipv4(const struct lnet_nid *nid)
-{
-	return NID_ADDR_BYTES(nid) == 4;
-}
-
-static inline bool nid_is_ipv6(const struct lnet_nid *nid)
-{
-	return NID_ADDR_BYTES(nid) == 16;
-}
-
 /* check for address set */
 static inline bool nid_addr_is_set(const struct lnet_nid *nid)
 {
diff --git a/net/lnet/klnds/o2iblnd/o2iblnd.c b/net/lnet/klnds/o2iblnd/o2iblnd.c
index 67259569b392..c1dfbe58eeb8 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd.c
+++ b/net/lnet/klnds/o2iblnd/o2iblnd.c
@@ -3202,6 +3202,9 @@ static int kiblnd_startup(struct lnet_ni *ni)
 		ifname = ni->ni_interface;
 	} else {
 		ifname = *kiblnd_tunables.kib_default_ipif;
+		rc = libcfs_strnid(&ni->ni_nid, ifname);
+		if (rc < 0 || ni->ni_nid.nid_type != O2IBLND)
+			memset(&ni->ni_nid, 0, sizeof(ni->ni_nid));
 	}
 
 	if (strlen(ifname) >= sizeof(ibdev->ibd_ifname)) {
@@ -3214,12 +3217,13 @@ static int kiblnd_startup(struct lnet_ni *ni)
 	if (rc < 0)
 		goto failed;
 
-	for (i = 0; i < rc; i++) {
-		if (strcmp(ifname, ifaces[i].li_name) == 0)
-			break;
-	}
+	i = lnet_inet_select(ni, ifaces, rc);
+	if (i < 0)
+		goto failed;
 
-	if (i == rc) {
+	if (nid_addr_is_set(&ni->ni_nid)) {
+		strscpy(ifname, ifaces[i].li_name, sizeof(ifname));
+	} else if (strcmp(ifname, ifaces[i].li_name) != 0) {
 		CERROR("ko2iblnd: No matching interfaces\n");
 		rc = -ENOENT;
 		goto failed;
@@ -3235,7 +3239,7 @@ static int kiblnd_startup(struct lnet_ni *ni)
 			goto failed;
 		}
 
-		ibdev->ibd_ifip = ifaces[i].li_ipaddr;
+		ibdev->ibd_ifip = ntohl(ifaces[i].li_ipaddr);
 		strlcpy(ibdev->ibd_ifname, ifaces[i].li_name,
 			sizeof(ibdev->ibd_ifname));
 		ibdev->ibd_can_failover = ifaces[i].li_iff_master;
diff --git a/net/lnet/klnds/socklnd/socklnd.c b/net/lnet/klnds/socklnd/socklnd.c
index cc2b7f46c53b..b8d6e287a093 100644
--- a/net/lnet/klnds/socklnd/socklnd.c
+++ b/net/lnet/klnds/socklnd/socklnd.c
@@ -2586,7 +2586,7 @@ ksocknal_startup(struct lnet_ni *ni)
 
 	ni->ni_dev_cpt = ifaces[if_idx].li_cpt;
 	ksi->ksni_index = ifaces[if_idx].li_index;
-	if (ifaces[if_idx].li_ipv6) {
+	if (ifaces[if_idx].li_size == sizeof(struct in6_addr)) {
 		struct sockaddr_in6 *sa;
 		sa = (void *)&ksi->ksni_addr;
 		memset(sa, 0, sizeof(*sa));
@@ -2601,9 +2601,9 @@ ksocknal_startup(struct lnet_ni *ni)
 		sa = (void *)&ksi->ksni_addr;
 		memset(sa, 0, sizeof(*sa));
 		sa->sin_family = AF_INET;
-		sa->sin_addr.s_addr = htonl(ifaces[if_idx].li_ipaddr);
+		sa->sin_addr.s_addr = ifaces[if_idx].li_ipaddr;
 		ksi->ksni_netmask = ifaces[if_idx].li_netmask;
-		ni->ni_nid.nid_size = 4 - 4;
+		ni->ni_nid.nid_size = 0;
 		ni->ni_nid.nid_addr[0] = sa->sin_addr.s_addr;
 	}
 	strlcpy(ksi->ksni_name, ifaces[if_idx].li_name, sizeof(ksi->ksni_name));
diff --git a/net/lnet/lnet/config.c b/net/lnet/lnet/config.c
index 0c4405f0f13b..a54e1dbe3e2e 100644
--- a/net/lnet/lnet/config.c
+++ b/net/lnet/lnet/config.c
@@ -1546,9 +1546,9 @@ int lnet_inet_enumerate(struct lnet_inetdev **dev_list, struct net *ns, bool v6)
 
 			ifaces[nip].li_cpt = cpt;
 			ifaces[nip].li_iff_master = !!(flags & IFF_MASTER);
-			ifaces[nip].li_ipv6 = false;
+			ifaces[nip].li_size = sizeof(ifa->ifa_local);
 			ifaces[nip].li_index = dev->ifindex;
-			ifaces[nip].li_ipaddr = ntohl(ifa->ifa_local);
+			ifaces[nip].li_ipaddr = ifa->ifa_local;
 			ifaces[nip].li_netmask = ntohl(ifa->ifa_mask);
 			strlcpy(ifaces[nip].li_name, ifa->ifa_label,
 				sizeof(ifaces[nip].li_name));
@@ -1586,7 +1586,7 @@ int lnet_inet_enumerate(struct lnet_inetdev **dev_list, struct net *ns, bool v6)
 
 			ifaces[nip].li_cpt = cpt;
 			ifaces[nip].li_iff_master = !!(flags & IFF_MASTER);
-			ifaces[nip].li_ipv6 = true;
+			ifaces[nip].li_size = sizeof(struct in6_addr);
 			ifaces[nip].li_index = dev->ifindex;
 			memcpy(ifaces[nip].li_ipv6addr,
 			       &ifa6->addr, sizeof(struct in6_addr));
@@ -1636,16 +1636,14 @@ int lnet_inet_select(struct lnet_ni *ni,
 			/* IP unspecified, use IP of first matching interface */
 			break;
 
-		if (ifaces[if_idx].li_ipv6 &&
-		    nid_is_ipv6(&ni->ni_nid)) {
-			if (memcmp(ni->ni_nid.nid_addr,
-				   ifaces[if_idx].li_ipv6addr,
-				   sizeof(struct in6_addr)) == 0)
-				break;
-		} else if (!ifaces[if_idx].li_ipv6 &&
-			   nid_is_ipv4(&ni->ni_nid)) {
-			if (ni->ni_nid.nid_addr[0] ==
-			    htonl(ifaces[if_idx].li_ipaddr))
+		if (ifaces[if_idx].li_size == NID_ADDR_BYTES(&ni->ni_nid)) {
+			char *addr = (char *)&ifaces[if_idx].li_ipaddr;
+
+			if (ifaces[if_idx].li_size != 4)
+				addr = (char *)ifaces[if_idx].li_ipv6addr;
+
+			if (memcmp(ni->ni_nid.nid_addr, addr,
+				   ifaces[if_idx].li_size) == 0)
 				break;
 		}
 	}
@@ -1654,11 +1652,13 @@ int lnet_inet_select(struct lnet_ni *ni,
 		return if_idx;
 
 	if (ni->ni_interface)
-		CERROR("ksocklnd: failed to find interface %s%s%s\n",
+		CERROR("%s: failed to find interface %s%s%s\n",
+		       libcfs_lnd2modname(ni->ni_nid.nid_type),
 		       ni->ni_interface, addr_set ? "@" : "",
 		       addr_set ? libcfs_nidstr(&ni->ni_nid) : "");
 	else
-		CERROR("ksocklnd: failed to find IP address %s\n",
+		CERROR("%s: failed to find IP address %s\n",
+		       libcfs_lnd2modname(ni->ni_nid.nid_type),
 		       libcfs_nidstr(&ni->ni_nid));
 
 	return -EINVAL;
@@ -1700,7 +1700,7 @@ lnet_parse_ip2nets(const char **networksp, const char *ip2nets)
 	}
 
 	for (i = 0; i < nip; i++)
-		ipaddrs[i] = ifaces[i].li_ipaddr;
+		ipaddrs[i] = ntohl(ifaces[i].li_ipaddr);
 
 	rc = lnet_match_networks(networksp, ip2nets, ipaddrs, nip);
 	if (rc < 0) {
-- 
2.27.0

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
