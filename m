Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 78C36C25B50
	for <lustre-devel@archiver.kernel.org>; Mon, 23 Jan 2023 23:34:26 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4P15Rx2tQVz216F;
	Mon, 23 Jan 2023 15:10:37 -0800 (PST)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4P15Mq256Nz226J
 for <lustre-devel@lists.lustre.org>; Mon, 23 Jan 2023 15:07:03 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 7F8B3A04;
 Mon, 23 Jan 2023 18:00:58 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 7DA6C58994; Mon, 23 Jan 2023 18:00:58 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon, 23 Jan 2023 18:00:39 -0500
Message-Id: <1674514855-15399-27-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1674514855-15399-1-git-send-email-jsimmons@infradead.org>
References: <1674514855-15399-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 26/42] lnet: Allow IP specification
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
Cc: Frank Sehr <fsehr@whamcloud.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Frank Sehr <fsehr@whamcloud.com>

Allows selecting an interface by specifying an IP address in the NID.
All variations of interface and IP address are considered.

1 no interface and no IP address is specified: Select first interface
2 interface and no IP: Select main IP address
3 no interface and IP specified: Select first interface
  that has the IP address
4 interface and IP specified: Verify that interface and IP match

The change does not have any effect on current configurations and
will be active when the changes in lnetctl, YAML or
module parameter are applied.
This patch effects only socklnd component. A macro is defined in
lnet-types.h to check if an IP address is set (IPV4 or IPV6).
Further IPV6 changes are not integrated.

For further reference please read

IP specification in LNet
https://wiki.whamcloud.com/display/LNet/IP+specification+in+LNet

WC-bug-id: https://jira.whamcloud.com/browse/LU-13642
Lustre-commit: 14cdcd61985aa0209 ("LU-13642 lnet: Allow IP specification")
Signed-off-by: Frank Sehr <fsehr@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/47660
Reviewed-by: Neil Brown <neilb@suse.de>
Reviewed-by: Cyril Bordage <cbordage@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/lib-lnet.h        |  3 ++
 include/uapi/linux/lnet/lnet-types.h | 37 ++++++++++++-------
 net/lnet/klnds/socklnd/socklnd.c     | 53 +++++++++++++---------------
 net/lnet/lnet/config.c               | 50 ++++++++++++++++++++++++++
 4 files changed, 101 insertions(+), 42 deletions(-)

diff --git a/include/linux/lnet/lib-lnet.h b/include/linux/lnet/lib-lnet.h
index ba68d50e677d..25289f5bba39 100644
--- a/include/linux/lnet/lib-lnet.h
+++ b/include/linux/lnet/lib-lnet.h
@@ -838,6 +838,9 @@ struct lnet_inetdev {
 
 int lnet_inet_enumerate(struct lnet_inetdev **dev_list, struct net *ns,
 			bool v6);
+int lnet_inet_select(struct lnet_ni *ni, struct lnet_inetdev *ifaces,
+		     int num_ifaces);
+
 void lnet_sock_setbuf(struct socket *socket, int txbufsize, int rxbufsize);
 void lnet_sock_getbuf(struct socket *socket, int *txbufsize, int *rxbufsize);
 int lnet_sock_getaddr(struct socket *socket, bool remote,
diff --git a/include/uapi/linux/lnet/lnet-types.h b/include/uapi/linux/lnet/lnet-types.h
index 304add9957ef..8a1d2d749b4b 100644
--- a/include/uapi/linux/lnet/lnet-types.h
+++ b/include/uapi/linux/lnet/lnet-types.h
@@ -90,11 +90,6 @@ static inline __u32 LNET_NIDNET(lnet_nid_t nid)
 	return (nid >> 32) & 0xffffffff;
 }
 
-static inline lnet_nid_t LNET_MKNID(__u32 net, __u32 addr)
-{
-	return (((__u64)net) << 32) | addr;
-}
-
 static inline __u32 LNET_NETNUM(__u32 net)
 {
 	return net & 0xffff;
@@ -110,25 +105,41 @@ static inline __u32 LNET_MKNET(__u32 type, __u32 num)
 	return (type << 16) | num;
 }
 
+static inline lnet_nid_t LNET_MKNID(__u32 net, __u32 addr)
+{
+	return (((__u64)net) << 32) | addr;
+}
+
 /** The lolnd NID (i.e. myself) */
 #define LNET_NID_LO_0 LNET_MKNID(LNET_MKNET(LOLND, 0), 0)
 
 #define LNET_NET_ANY LNET_NIDNET(LNET_NID_ANY)
 
-/* check for address set */
-static inline bool nid_addr_is_set(const struct lnet_nid *nid)
+static inline bool nid_is_nid4(const struct lnet_nid *nid)
 {
-	int sum = 0, i;
+	return NID_ADDR_BYTES(nid) == 4;
+}
 
-	for (i = 0; i < NID_ADDR_BYTES(nid); i++)
-		sum |= nid->nid_addr[i];
+static inline bool nid_is_ipv4(const struct lnet_nid *nid)
+{
+	return NID_ADDR_BYTES(nid) == 4;
+}
 
-	return sum ? true : false;
+static inline bool nid_is_ipv6(const struct lnet_nid *nid)
+{
+	return NID_ADDR_BYTES(nid) == 16;
 }
 
-static inline int nid_is_nid4(const struct lnet_nid *nid)
+/* check for address set */
+static inline bool nid_addr_is_set(const struct lnet_nid *nid)
 {
-	return NID_ADDR_BYTES(nid) == 4;
+	int i;
+
+	for (i = 0; i < NID_ADDR_BYTES(nid); i++)
+		if (nid->nid_addr[i])
+			return true;
+
+	return false;
 }
 
 /* LOLND may not be defined yet, so we cannot use an inline */
diff --git a/net/lnet/klnds/socklnd/socklnd.c b/net/lnet/klnds/socklnd/socklnd.c
index 07e056845b24..0a4fb966f498 100644
--- a/net/lnet/klnds/socklnd/socklnd.c
+++ b/net/lnet/klnds/socklnd/socklnd.c
@@ -2542,8 +2542,7 @@ ksocknal_startup(struct lnet_ni *ni)
 	struct ksock_net *net;
 	struct ksock_interface *ksi = NULL;
 	struct lnet_inetdev *ifaces = NULL;
-	int i = 0;
-	int rc;
+	int rc, if_idx;
 
 	LASSERT(ni->ni_net->net_lnd == &the_ksocklnd);
 
@@ -2555,7 +2554,7 @@ ksocknal_startup(struct lnet_ni *ni)
 
 	net = kzalloc(sizeof(*net), GFP_NOFS);
 	if (!net)
-		goto fail_0;
+		goto out_base;
 
 	net->ksnn_incarnation = ktime_get_real_ns();
 	ni->ni_data = net;
@@ -2564,55 +2563,51 @@ ksocknal_startup(struct lnet_ni *ni)
 
 	rc = lnet_inet_enumerate(&ifaces, ni->ni_net_ns, true);
 	if (rc < 0)
-		goto fail_1;
+		goto out_net;
 
 	ksi = &net->ksnn_interface;
-	/* Use the first discovered interface or look in the list */
-	if (ni->ni_interface) {
-		for (i = 0; i < rc; i++) {
-			if (strcmp(ifaces[i].li_name, ni->ni_interface) == 0)
-				break;
-		}
-		/* ni_interface doesn't contain the interface we want */
-		if (i == rc) {
-			CERROR("ksocklnd: failed to find interface %s\n",
-			       ni->ni_interface);
-			goto fail_1;
-		}
-	} else {
-		rc = lnet_ni_add_interface(ni, ifaces[i].li_name);
+
+	/* Interface and/or IP address is specified otherwise default to
+	 * the first Interface
+	 */
+	if_idx = lnet_inet_select(ni, ifaces, rc);
+	if (if_idx < 0)
+		goto out_net;
+
+	if (!ni->ni_interface) {
+		rc = lnet_ni_add_interface(ni, ifaces[if_idx].li_name);
 		if (rc < 0)
 			CWARN("ksocklnd failed to allocate ni_interface\n");
 	}
 
-	ni->ni_dev_cpt = ifaces[i].li_cpt;
-	ksi->ksni_index = ifaces[i].li_index;
-	if (ifaces[i].li_ipv6) {
+	ni->ni_dev_cpt = ifaces[if_idx].li_cpt;
+	ksi->ksni_index = ifaces[if_idx].li_index;
+	if (ifaces[if_idx].li_ipv6) {
 		struct sockaddr_in6 *sa;
 		sa = (void *)&ksi->ksni_addr;
 		memset(sa, 0, sizeof(*sa));
 		sa->sin6_family = AF_INET6;
-		memcpy(&sa->sin6_addr, ifaces[i].li_ipv6addr,
+		memcpy(&sa->sin6_addr, ifaces[if_idx].li_ipv6addr,
 		       sizeof(struct in6_addr));
 		ni->ni_nid.nid_size = sizeof(struct in6_addr) - 4;
-		memcpy(&ni->ni_nid.nid_addr, ifaces[i].li_ipv6addr,
+		memcpy(&ni->ni_nid.nid_addr, ifaces[if_idx].li_ipv6addr,
 		       sizeof(struct in6_addr));
 	} else {
 		struct sockaddr_in *sa;
 		sa = (void *)&ksi->ksni_addr;
 		memset(sa, 0, sizeof(*sa));
 		sa->sin_family = AF_INET;
-		sa->sin_addr.s_addr = htonl(ifaces[i].li_ipaddr);
-		ksi->ksni_netmask = ifaces[i].li_netmask;
+		sa->sin_addr.s_addr = htonl(ifaces[if_idx].li_ipaddr);
+		ksi->ksni_netmask = ifaces[if_idx].li_netmask;
 		ni->ni_nid.nid_size = 4 - 4;
 		ni->ni_nid.nid_addr[0] = sa->sin_addr.s_addr;
 	}
-	strlcpy(ksi->ksni_name, ifaces[i].li_name, sizeof(ksi->ksni_name));
+	strlcpy(ksi->ksni_name, ifaces[if_idx].li_name, sizeof(ksi->ksni_name));
 
 	/* call it before add it to ksocknal_data.ksnd_nets */
 	rc = ksocknal_net_start_threads(net, ni->ni_cpts, ni->ni_ncpts);
 	if (rc)
-		goto fail_1;
+		goto out_net;
 
 	list_add(&net->ksnn_list, &ksocknal_data.ksnd_nets);
 	net->ksnn_ni = ni;
@@ -2620,9 +2615,9 @@ ksocknal_startup(struct lnet_ni *ni)
 
 	return 0;
 
-fail_1:
+out_net:
 	kfree(net);
-fail_0:
+out_base:
 	if (!ksocknal_data.ksnd_nnets)
 		ksocknal_base_shutdown();
 
diff --git a/net/lnet/lnet/config.c b/net/lnet/lnet/config.c
index 5bfae4e46910..0c4405f0f13b 100644
--- a/net/lnet/lnet/config.c
+++ b/net/lnet/lnet/config.c
@@ -1615,6 +1615,56 @@ int lnet_inet_enumerate(struct lnet_inetdev **dev_list, struct net *ns, bool v6)
 }
 EXPORT_SYMBOL(lnet_inet_enumerate);
 
+int lnet_inet_select(struct lnet_ni *ni,
+		     struct lnet_inetdev *ifaces,
+		     int num_ifaces)
+{
+	bool addr_set = nid_addr_is_set(&ni->ni_nid);
+	int if_idx;
+
+	/* default to first interface if both interface and NID unspecified */
+	if (!ni->ni_interface && !addr_set)
+		return 0;
+
+	for (if_idx = 0; if_idx < num_ifaces; if_idx++) {
+		if (ni->ni_interface &&
+		    strcmp(ni->ni_interface, ifaces[if_idx].li_name) != 0)
+			/* not the specified interface */
+			continue;
+
+		if (!addr_set)
+			/* IP unspecified, use IP of first matching interface */
+			break;
+
+		if (ifaces[if_idx].li_ipv6 &&
+		    nid_is_ipv6(&ni->ni_nid)) {
+			if (memcmp(ni->ni_nid.nid_addr,
+				   ifaces[if_idx].li_ipv6addr,
+				   sizeof(struct in6_addr)) == 0)
+				break;
+		} else if (!ifaces[if_idx].li_ipv6 &&
+			   nid_is_ipv4(&ni->ni_nid)) {
+			if (ni->ni_nid.nid_addr[0] ==
+			    htonl(ifaces[if_idx].li_ipaddr))
+				break;
+		}
+	}
+
+	if (if_idx < num_ifaces)
+		return if_idx;
+
+	if (ni->ni_interface)
+		CERROR("ksocklnd: failed to find interface %s%s%s\n",
+		       ni->ni_interface, addr_set ? "@" : "",
+		       addr_set ? libcfs_nidstr(&ni->ni_nid) : "");
+	else
+		CERROR("ksocklnd: failed to find IP address %s\n",
+		       libcfs_nidstr(&ni->ni_nid));
+
+	return -EINVAL;
+}
+EXPORT_SYMBOL(lnet_inet_select);
+
 int
 lnet_parse_ip2nets(const char **networksp, const char *ip2nets)
 {
-- 
2.27.0

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
