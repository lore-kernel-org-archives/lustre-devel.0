Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 02341C4332F
	for <lustre-devel@archiver.kernel.org>; Sun, 20 Nov 2022 14:22:44 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4NFXgg0KdCz1yDG;
	Sun, 20 Nov 2022 06:18:39 -0800 (PST)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4NFXfc46k0z1wfv
 for <lustre-devel@lists.lustre.org>; Sun, 20 Nov 2022 06:17:44 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id C001A1007B72;
 Sun, 20 Nov 2022 09:17:09 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id BAFA5E8B88; Sun, 20 Nov 2022 09:17:09 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 20 Nov 2022 09:16:52 -0500
Message-Id: <1668953828-10909-7-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1668953828-10909-1-git-send-email-jsimmons@infradead.org>
References: <1668953828-10909-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 06/22] lnet: use Netlink to support old and
 new NI APIs.
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

The LNet layer uses two different sets of ioctls. One ioctl set is
for Multi-Rail and the other is an older API. Both are in heavy
use and with the upcoming support for IPv6 we are looking at an
explosion of ioctls. The solution is to move the LNet layer to
Netlink which can easily handle all the differences between the
APIs. This also resolves a long standing issue of the user land
API constantly changing in a non-compatible way with previous
versions.

This patch unifies the handling the LNet NI to use Netlink and is
fully aware of the new large NID addressing.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10003
Lustre-commit: 8f8f6e2f36e56e53e ("LU-10003 lnet: use Netlink to support old and new NI APIs.")
Signed-off-by: James Simmons <jsimmons@infradead.org>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/48814
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: Neil Brown <neilb@suse.de>
Reviewed-by: Frank Sehr <fsehr@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
---
 include/linux/lnet/lib-lnet.h          |   6 +-
 include/linux/lnet/lib-types.h         | 103 +++++
 include/uapi/linux/lnet/libcfs_ioctl.h |   2 +-
 include/uapi/linux/lnet/lnet-dlc.h     |  23 +
 include/uapi/linux/lnet/lnet-types.h   |  15 +
 net/lnet/klnds/o2iblnd/o2iblnd.c       |  88 +++-
 net/lnet/klnds/o2iblnd/o2iblnd.h       |  16 +
 net/lnet/klnds/socklnd/socklnd.c       |  37 +-
 net/lnet/klnds/socklnd/socklnd.h       |   9 +
 net/lnet/lnet/api-ni.c                 | 779 +++++++++++++++++++++++++++++++--
 net/lnet/lnet/config.c                 |   4 +-
 net/lnet/lnet/module.c                 |  42 +-
 12 files changed, 1054 insertions(+), 70 deletions(-)

diff --git a/include/linux/lnet/lib-lnet.h b/include/linux/lnet/lib-lnet.h
index bd4acef..13ce2bf 100644
--- a/include/linux/lnet/lib-lnet.h
+++ b/include/linux/lnet/lib-lnet.h
@@ -457,6 +457,7 @@ struct lnet_ni *
 struct lnet_ni *
 lnet_ni_alloc_w_cpt_array(struct lnet_net *net, u32 *cpts, u32 ncpts,
 			  char *iface);
+int lnet_ni_add_interface(struct lnet_ni *ni, char *iface);
 
 static inline int
 lnet_nid2peerhash(struct lnet_nid *nid)
@@ -622,8 +623,9 @@ void lnet_rtr_transfer_to_peer(struct lnet_peer *src,
 struct lnet_remotenet *lnet_find_rnet_locked(u32 net);
 int lnet_dyn_add_net(struct lnet_ioctl_config_data *conf);
 int lnet_dyn_del_net(u32 net);
-int lnet_dyn_add_ni(struct lnet_ioctl_config_ni *conf);
-int lnet_dyn_del_ni(struct lnet_ioctl_config_ni *conf);
+int lnet_dyn_add_ni(struct lnet_ioctl_config_ni *conf, u32 net,
+		    struct lnet_ioctl_config_lnd_tunables *tun);
+int lnet_dyn_del_ni(struct lnet_nid *nid);
 int lnet_clear_lazy_portal(struct lnet_ni *ni, int portal, char *reason);
 struct lnet_net *lnet_get_net_locked(u32 net_id);
 void lnet_net_clr_pref_rtrs(struct lnet_net *net);
diff --git a/include/linux/lnet/lib-types.h b/include/linux/lnet/lib-types.h
index 499385b..2d3b044 100644
--- a/include/linux/lnet/lib-types.h
+++ b/include/linux/lnet/lib-types.h
@@ -335,6 +335,11 @@ struct lnet_lnd {
 	/* get dma_dev priority */
 	unsigned int (*lnd_get_dev_prio)(struct lnet_ni *ni,
 					 unsigned int dev_idx);
+
+	/* Handle LND specific Netlink handling */
+	int (*lnd_nl_set)(int cmd, struct nlattr *attr, int type, void *data);
+
+	const struct ln_key_list *lnd_keys;
 };
 
 /* FIXME !!!!! The abstract for GPU page support (PCI peer2peer)
@@ -464,6 +469,104 @@ struct lnet_net {
 	struct list_head	net_rtr_pref_nids;
 };
 
+/* Normally Netlink atttributes are defined in UAPI headers but Lustre is
+ * different in that the ABI is in a constant state of change unlike other
+ * Netlink interfaces. LNet sends a special header to help user land handle
+ * the differences.
+ */
+
+/** enum lnet_net_attrs		      - LNet NI netlink properties
+ *					attributes that describe LNet 'NI'
+ *					These values are used to piece together
+ *					messages for sending and receiving.
+ *
+ * @LNET_NET_ATTR_UNSPEC:		unspecified attribute to catch errors
+ *
+ * @LNET_NET_ATTR_HDR:			grouping for LNet net data (NLA_NESTED)
+ * @LNET_NET_ATTR_TYPE:			LNet net this NI belongs to (NLA_STRING)
+ * @LNET_NET_ATTR_LOCAL:		Local NI information (NLA_NESTED)
+ */
+enum lnet_net_attrs {
+	LNET_NET_ATTR_UNSPEC = 0,
+
+	LNET_NET_ATTR_HDR,
+	LNET_NET_ATTR_TYPE,
+	LNET_NET_ATTR_LOCAL,
+
+	__LNET_NET_ATTR_MAX_PLUS_ONE,
+};
+
+#define LNET_NET_ATTR_MAX (__LNET_NET_ATTR_MAX_PLUS_ONE - 1)
+
+/** enum lnet_net_local_ni_attrs      - LNet local NI netlink properties
+ *					attributes that describe local NI
+ *
+ * @LNET_NET_LOCAL_NI_ATTR_UNSPEC:	unspecified attribute to catch errors
+ *
+ * @LNET_NET_LOCAL_NI_ATTR_NID:		NID that represents this NI (NLA_STRING)
+ * @LNET_NET_LOCAL_NI_ATTR_STATUS:	State of this NI (NLA_STRING)
+ * @LNET_NET_LOCAL_NI_ATTR_INTERFACE:	Defines physical devices (NLA_NESTED)
+ *					Used to be many devices but no longer.
+ */
+enum lnet_net_local_ni_attrs {
+	LNET_NET_LOCAL_NI_ATTR_UNSPEC = 0,
+
+	LNET_NET_LOCAL_NI_ATTR_NID,
+	LNET_NET_LOCAL_NI_ATTR_STATUS,
+	LNET_NET_LOCAL_NI_ATTR_INTERFACE,
+
+	__LNET_NET_LOCAL_NI_ATTR_MAX_PLUS_ONE,
+};
+
+#define LNET_NET_LOCAL_NI_ATTR_MAX (__LNET_NET_LOCAL_NI_ATTR_MAX_PLUS_ONE - 1)
+
+/** enum lnet_net_local_ni_intf_attrs - LNet NI device netlink properties
+ *					attribute that reports the device
+ *					in use
+ *
+ * @LNET_NET_LOCAL_NI_INTF_ATTR_UNSPEC:	unspecified attribute to catch errors
+ *
+ * @LNET_NET_LOCAL_NI_INTF_ATTR_TYPE:	Physcial device interface (NLA_STRING)
+ */
+enum lnet_net_local_ni_intf_attrs {
+	LNET_NET_LOCAL_NI_INTF_ATTR_UNSPEC = 0,
+
+	LNET_NET_LOCAL_NI_INTF_ATTR_TYPE,
+
+	__LNET_NET_LOCAL_NI_INTF_ATTR_MAX_PLUS_ONE,
+};
+
+#define LNET_NET_LOCAL_NI_INTF_ATTR_MAX (__LNET_NET_LOCAL_NI_INTF_ATTR_MAX_PLUS_ONE - 1)
+
+/** enum lnet_net_local_ni_tunables_attrs	      - LNet NI tunables
+ *							netlink properties.
+ *							Performance options
+ *							for your NI.
+ *
+ * @LNET_NET_LOCAL_NI_TUNABLES_ATTR_UNSPEC:		unspecified attribute
+ *							to catch errors
+ *
+ * @LNET_NET_LOCAL_NI_TUNABLES_ATTR_PEER_TIMEOUT:	Timeout for LNet peer.
+ *							(NLA_S32)
+ * @LNET_NET_LOCAL_NI_TUNABLES_ATTR_PEER_CREDITS:	Credits for LNet peer.
+ *							(NLA_S32)
+ * @LNET_NET_LOCAL_NI_TUNABLES_ATTR_PEER_BUFFER_CREDITS: Buffer credits for
+ *							 LNet peer. (NLA_S32)
+ * @LNET_NET_LOCAL_NI_TUNABLES_ATTR_CREDITS:		Credits for LNet peer
+ *							TX. (NLA_S32)
+ */
+enum lnet_net_local_ni_tunables_attr {
+	LNET_NET_LOCAL_NI_TUNABLES_ATTR_UNSPEC = 0,
+
+	LNET_NET_LOCAL_NI_TUNABLES_ATTR_PEER_TIMEOUT,
+	LNET_NET_LOCAL_NI_TUNABLES_ATTR_PEER_CREDITS,
+	LNET_NET_LOCAL_NI_TUNABLES_ATTR_PEER_BUFFER_CREDITS,
+	LNET_NET_LOCAL_NI_TUNABLES_ATTR_CREDITS,
+	__LNET_NET_LOCAL_NI_TUNABLES_ATTR_MAX_PLUS_ONE,
+};
+
+#define LNET_NET_LOCAL_NI_TUNABLES_ATTR_MAX (__LNET_NET_LOCAL_NI_TUNABLES_ATTR_MAX_PLUS_ONE - 1)
+
 struct lnet_ni {
 	spinlock_t		ni_lock;
 	/* chain on the lnet_net structure */
diff --git a/include/uapi/linux/lnet/libcfs_ioctl.h b/include/uapi/linux/lnet/libcfs_ioctl.h
index f2ae76c..89ac075 100644
--- a/include/uapi/linux/lnet/libcfs_ioctl.h
+++ b/include/uapi/linux/lnet/libcfs_ioctl.h
@@ -94,7 +94,7 @@ struct libcfs_ioctl_data {
 #define IOC_LIBCFS_MARK_DEBUG		_IOWR('e', 32, IOCTL_LIBCFS_TYPE)
 /* IOC_LIBCFS_MEMHOG obsolete in 2.8.0, was _IOWR('e', 36, IOCTL_LIBCFS_TYPE) */
 /* lnet ioctls */
-#define IOC_LIBCFS_GET_NI		_IOWR('e', 50, IOCTL_LIBCFS_TYPE)
+/* IOC_LIBCFS_GET_NI obsolete in 2.16, was _IOWR('e', 50, IOCTL_LIBCFS_TYPE) */
 #define IOC_LIBCFS_FAIL_NID		_IOWR('e', 51, IOCTL_LIBCFS_TYPE)
 #define IOC_LIBCFS_NOTIFY_ROUTER	_IOWR('e', 55, IOCTL_LIBCFS_TYPE)
 #define IOC_LIBCFS_UNCONFIGURE		_IOWR('e', 56, IOCTL_LIBCFS_TYPE)
diff --git a/include/uapi/linux/lnet/lnet-dlc.h b/include/uapi/linux/lnet/lnet-dlc.h
index 415968a..58697c1 100644
--- a/include/uapi/linux/lnet/lnet-dlc.h
+++ b/include/uapi/linux/lnet/lnet-dlc.h
@@ -49,6 +49,29 @@
 #define __user
 #endif
 
+#define LNET_GENL_NAME		"lnet"
+#define LNET_GENL_VERSION	0x05
+
+/* enum lnet_commands	      - Supported core LNet Netlink commands
+ *
+ *  @LNET_CMD_UNSPEC:		unspecified command to catch errors
+ *
+ *  @LNET_CMD_NETS:		command to manage the LNet networks
+ */
+enum lnet_commands {
+	LNET_CMD_UNSPEC		= 0,
+
+	LNET_CMD_CONFIGURE	= 1,
+	LNET_CMD_NETS		= 2,
+	LNET_CMD_PEERS		= 3,
+	LNET_CMD_ROUTES		= 4,
+	LNET_CMD_CONNS		= 5,
+
+	__LNET_CMD_MAX_PLUS_ONE
+};
+
+#define LNET_CMD_MAX (__LNET_CMD_MAX_PLUS_ONE - 1)
+
 /*
  * To allow for future enhancements to extend the tunables
  * add a hdr to this structure, so that the version can be set
diff --git a/include/uapi/linux/lnet/lnet-types.h b/include/uapi/linux/lnet/lnet-types.h
index 5a2ea45..304add9 100644
--- a/include/uapi/linux/lnet/lnet-types.h
+++ b/include/uapi/linux/lnet/lnet-types.h
@@ -37,8 +37,12 @@
 #include <linux/types.h>
 #include <linux/lnet/lnet-idl.h>
 
+#include <linux/types.h>
 #include <linux/string.h>
 #include <asm/byteorder.h>
+#ifndef __KERNEL__
+#include <stdbool.h>
+#endif
 
 /** \addtogroup lnet
  * @{
@@ -111,6 +115,17 @@ static inline __u32 LNET_MKNET(__u32 type, __u32 num)
 
 #define LNET_NET_ANY LNET_NIDNET(LNET_NID_ANY)
 
+/* check for address set */
+static inline bool nid_addr_is_set(const struct lnet_nid *nid)
+{
+	int sum = 0, i;
+
+	for (i = 0; i < NID_ADDR_BYTES(nid); i++)
+		sum |= nid->nid_addr[i];
+
+	return sum ? true : false;
+}
+
 static inline int nid_is_nid4(const struct lnet_nid *nid)
 {
 	return NID_ADDR_BYTES(nid) == 4;
diff --git a/net/lnet/klnds/o2iblnd/o2iblnd.c b/net/lnet/klnds/o2iblnd/o2iblnd.c
index 94ff926..cbb3445 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd.c
+++ b/net/lnet/klnds/o2iblnd/o2iblnd.c
@@ -491,6 +491,86 @@ void kiblnd_unlink_peer_locked(struct kib_peer_ni *peer_ni)
 	spin_unlock(&conn->ibc_lock);
 }
 
+static const struct ln_key_list kiblnd_tunables_keys = {
+	.lkl_maxattr                    = LNET_NET_O2IBLND_TUNABLES_ATTR_MAX,
+	.lkl_list			= {
+		[LNET_NET_O2IBLND_TUNABLES_ATTR_HIW_PEER_CREDITS]  = {
+			.lkp_value	= "peercredits_hiw",
+			.lkp_data_type	= NLA_U32
+		},
+		[LNET_NET_O2IBLND_TUNABLES_ATTR_MAP_ON_DEMAND]  = {
+			.lkp_value	= "map_on_demand",
+			.lkp_data_type	= NLA_FLAG
+		},
+		[LNET_NET_O2IBLND_TUNABLES_ATTR_CONCURRENT_SENDS]  = {
+			.lkp_value	= "concurrent_sends",
+			.lkp_data_type	= NLA_U32
+		},
+		[LNET_NET_O2IBLND_TUNABLES_ATTR_FMR_POOL_SIZE]  = {
+			.lkp_value	= "fmr_pool_size",
+			.lkp_data_type	= NLA_U32
+		},
+		[LNET_NET_O2IBLND_TUNABLES_ATTR_FMR_FLUSH_TRIGGER]  = {
+			.lkp_value	= "fmr_flush_trigger",
+			.lkp_data_type	= NLA_U32
+		},
+		[LNET_NET_O2IBLND_TUNABLES_ATTR_FMR_CACHE]  = {
+			.lkp_value	= "fmr_cache",
+			.lkp_data_type	= NLA_U32
+		},
+		[LNET_NET_O2IBLND_TUNABLES_ATTR_NTX]  = {
+			.lkp_value	= "ntx",
+			.lkp_data_type	= NLA_U16
+		},
+		[LNET_NET_O2IBLND_TUNABLES_ATTR_CONNS_PER_PEER]  = {
+			.lkp_value	= "conns_per_peer",
+			.lkp_data_type	= NLA_U16
+		},
+	},
+};
+
+static int
+kiblnd_nl_set(int cmd, struct nlattr *attr, int type, void *data)
+{
+	struct lnet_lnd_tunables *tunables = data;
+
+	if (cmd != LNET_CMD_NETS)
+		return -EOPNOTSUPP;
+
+	if (nla_type(attr) != LN_SCALAR_ATTR_INT_VALUE)
+		return -EINVAL;
+
+	switch (type) {
+	case LNET_NET_O2IBLND_TUNABLES_ATTR_HIW_PEER_CREDITS:
+		tunables->lnd_tun_u.lnd_o2ib.lnd_peercredits_hiw = nla_get_s64(attr);
+		break;
+	case LNET_NET_O2IBLND_TUNABLES_ATTR_MAP_ON_DEMAND:
+		tunables->lnd_tun_u.lnd_o2ib.lnd_map_on_demand = nla_get_s64(attr);
+		break;
+	case LNET_NET_O2IBLND_TUNABLES_ATTR_CONCURRENT_SENDS:
+		tunables->lnd_tun_u.lnd_o2ib.lnd_concurrent_sends = nla_get_s64(attr);
+		break;
+	case LNET_NET_O2IBLND_TUNABLES_ATTR_FMR_POOL_SIZE:
+		tunables->lnd_tun_u.lnd_o2ib.lnd_fmr_pool_size = nla_get_s64(attr);
+		break;
+	case LNET_NET_O2IBLND_TUNABLES_ATTR_FMR_FLUSH_TRIGGER:
+		tunables->lnd_tun_u.lnd_o2ib.lnd_fmr_flush_trigger = nla_get_s64(attr);
+		break;
+	case LNET_NET_O2IBLND_TUNABLES_ATTR_FMR_CACHE:
+		tunables->lnd_tun_u.lnd_o2ib.lnd_fmr_cache = nla_get_s64(attr);
+		break;
+	case LNET_NET_O2IBLND_TUNABLES_ATTR_NTX:
+		tunables->lnd_tun_u.lnd_o2ib.lnd_ntx = nla_get_s64(attr);
+		break;
+	case LNET_NET_O2IBLND_TUNABLES_ATTR_CONNS_PER_PEER:
+		tunables->lnd_tun_u.lnd_o2ib.lnd_conns_per_peer = nla_get_s64(attr);
+	default:
+		break;
+	}
+
+	return 0;
+}
+
 static void
 kiblnd_dump_peer_debug_info(struct kib_peer_ni *peer_ni)
 {
@@ -3173,7 +3253,11 @@ static int kiblnd_startup(struct lnet_ni *ni)
 
 	net->ibn_dev = ibdev;
 	ni->ni_nid.nid_addr[0] = cpu_to_be32(ibdev->ibd_ifip);
-
+	if (!ni->ni_interface) {
+		rc = lnet_ni_add_interface(ni, ifaces[i].li_name);
+		if (rc < 0)
+			CWARN("ko2iblnd failed to allocate ni_interface\n");
+	}
 	ni->ni_dev_cpt = ifaces[i].li_cpt;
 
 	rc = kiblnd_dev_start_threads(ibdev, newdev, ni->ni_cpts, ni->ni_ncpts);
@@ -3220,6 +3304,8 @@ static int kiblnd_startup(struct lnet_ni *ni)
 	.lnd_send	= kiblnd_send,
 	.lnd_recv	= kiblnd_recv,
 	.lnd_get_dev_prio = kiblnd_get_dev_prio,
+	.lnd_nl_set	= kiblnd_nl_set,
+	.lnd_keys	= &kiblnd_tunables_keys,
 };
 
 static void ko2inlnd_assert_wire_constants(void)
diff --git a/net/lnet/klnds/o2iblnd/o2iblnd.h b/net/lnet/klnds/o2iblnd/o2iblnd.h
index bef7a55..e3c069b 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd.h
+++ b/net/lnet/klnds/o2iblnd/o2iblnd.h
@@ -65,6 +65,22 @@
 #include <linux/lnet/lib-lnet.h>
 #include "o2iblnd-idl.h"
 
+enum kiblnd_ni_lnd_tunables_attr {
+	LNET_NET_O2IBLND_TUNABLES_ATTR_UNSPEC = 0,
+
+	LNET_NET_O2IBLND_TUNABLES_ATTR_HIW_PEER_CREDITS,
+	LNET_NET_O2IBLND_TUNABLES_ATTR_CONCURRENT_SENDS,
+	LNET_NET_O2IBLND_TUNABLES_ATTR_MAP_ON_DEMAND,
+	LNET_NET_O2IBLND_TUNABLES_ATTR_FMR_POOL_SIZE,
+	LNET_NET_O2IBLND_TUNABLES_ATTR_FMR_FLUSH_TRIGGER,
+	LNET_NET_O2IBLND_TUNABLES_ATTR_FMR_CACHE,
+	LNET_NET_O2IBLND_TUNABLES_ATTR_NTX,
+	LNET_NET_O2IBLND_TUNABLES_ATTR_CONNS_PER_PEER,
+	__LNET_NET_O2IBLND_TUNABLES_ATTR_MAX_PLUS_ONE,
+};
+
+#define LNET_NET_O2IBLND_TUNABLES_ATTR_MAX (__LNET_NET_O2IBLND_TUNABLES_ATTR_MAX_PLUS_ONE - 1)
+
 #define IBLND_PEER_HASH_BITS		7	/* log2 of # peer_ni lists */
 
 #define IBLND_N_SCHED			2
diff --git a/net/lnet/klnds/socklnd/socklnd.c b/net/lnet/klnds/socklnd/socklnd.c
index e8f8020..21fccfa 100644
--- a/net/lnet/klnds/socklnd/socklnd.c
+++ b/net/lnet/klnds/socklnd/socklnd.c
@@ -840,6 +840,33 @@ struct ksock_peer_ni *
 	return 0;
 }
 
+static const struct ln_key_list ksocknal_tunables_keys = {
+	.lkl_maxattr			= LNET_NET_SOCKLND_TUNABLES_ATTR_MAX,
+	.lkl_list			= {
+		[LNET_NET_SOCKLND_TUNABLES_ATTR_CONNS_PER_PEER]  = {
+			.lkp_value	= "conns_per_peer",
+			.lkp_data_type	= NLA_S32
+		},
+	},
+};
+
+static int
+ksocknal_nl_set(int cmd, struct nlattr *attr, int type, void *data)
+{
+	struct lnet_lnd_tunables *tunables = data;
+
+	if (cmd != LNET_CMD_NETS)
+		return -EOPNOTSUPP;
+
+	if (type != LNET_NET_SOCKLND_TUNABLES_ATTR_CONNS_PER_PEER ||
+	    nla_type(attr) != LN_SCALAR_ATTR_INT_VALUE)
+		return -EINVAL;
+
+	tunables->lnd_tun_u.lnd_sock.lnd_conns_per_peer = nla_get_s64(attr);
+
+	return 0;
+}
+
 static int
 ksocknal_connecting(struct ksock_conn_cb *conn_cb, struct sockaddr *sa)
 {
@@ -2520,16 +2547,20 @@ static int ksocknal_inetaddr_event(struct notifier_block *unused,
 	ksi = &net->ksnn_interface;
 	/* Use the first discovered interface or look in the list */
 	if (ni->ni_interface) {
-		for (i = 0; i < rc; i++)
+		for (i = 0; i < rc; i++) {
 			if (strcmp(ifaces[i].li_name, ni->ni_interface) == 0)
 				break;
-
+		}
 		/* ni_interface doesn't contain the interface we want */
 		if (i == rc) {
 			CERROR("ksocklnd: failed to find interface %s\n",
 			       ni->ni_interface);
 			goto fail_1;
 		}
+	} else {
+		rc = lnet_ni_add_interface(ni, ifaces[i].li_name);
+		if (rc < 0)
+			CWARN("ksocklnd failed to allocate ni_interface\n");
 	}
 
 	ni->ni_dev_cpt = ifaces[i].li_cpt;
@@ -2590,6 +2621,8 @@ static void __exit ksocklnd_exit(void)
 	.lnd_recv		= ksocknal_recv,
 	.lnd_notify_peer_down	= ksocknal_notify_gw_down,
 	.lnd_accept		= ksocknal_accept,
+	.lnd_nl_set		= ksocknal_nl_set,
+	.lnd_keys		= &ksocknal_tunables_keys,
 };
 
 static int __init ksocklnd_init(void)
diff --git a/net/lnet/klnds/socklnd/socklnd.h b/net/lnet/klnds/socklnd/socklnd.h
index bb68a3d..50892b1 100644
--- a/net/lnet/klnds/socklnd/socklnd.h
+++ b/net/lnet/klnds/socklnd/socklnd.h
@@ -74,6 +74,15 @@
 # define SOCKNAL_RISK_KMAP_DEADLOCK	1
 #endif
 
+enum ksocklnd_ni_lnd_tunables_attr {
+	LNET_NET_SOCKLND_TUNABLES_ATTR_UNSPEC = 0,
+
+	LNET_NET_SOCKLND_TUNABLES_ATTR_CONNS_PER_PEER,
+	__LNET_NET_SOCKLND_TUNABLES_ATTR_MAX_PLUS_ONE,
+};
+
+#define LNET_NET_SOCKLND_TUNABLES_ATTR_MAX (__LNET_NET_SOCKLND_TUNABLES_ATTR_MAX_PLUS_ONE - 1)
+
 /* per scheduler state */
 struct ksock_sched {				/* per scheduler state */
 	spinlock_t		kss_lock;	/* serialise */
diff --git a/net/lnet/lnet/api-ni.c b/net/lnet/lnet/api-ni.c
index 9459fc0..af875ba 100644
--- a/net/lnet/lnet/api-ni.c
+++ b/net/lnet/lnet/api-ni.c
@@ -34,6 +34,8 @@
 #include <linux/log2.h>
 #include <linux/ktime.h>
 #include <linux/moduleparam.h>
+#include <linux/sched/signal.h>
+#include <net/genetlink.h>
 
 #include <linux/lnet/udsp.h>
 #include <linux/lnet/lib-lnet.h>
@@ -2498,6 +2500,36 @@ static void lnet_push_target_fini(void)
 	return rc;
 }
 
+static struct lnet_lnd *lnet_load_lnd(u32 lnd_type)
+{
+	struct lnet_lnd *lnd;
+	int rc = 0;
+
+	mutex_lock(&the_lnet.ln_lnd_mutex);
+	lnd = lnet_find_lnd_by_type(lnd_type);
+	if (!lnd) {
+		mutex_unlock(&the_lnet.ln_lnd_mutex);
+		rc = request_module("%s", libcfs_lnd2modname(lnd_type));
+		mutex_lock(&the_lnet.ln_lnd_mutex);
+
+		lnd = lnet_find_lnd_by_type(lnd_type);
+		if (!lnd) {
+			mutex_unlock(&the_lnet.ln_lnd_mutex);
+			CERROR("Can't load LND %s, module %s, rc=%d\n",
+			       libcfs_lnd2str(lnd_type),
+			       libcfs_lnd2modname(lnd_type), rc);
+#ifndef HAVE_MODULE_LOADING_SUPPORT
+			LCONSOLE_ERROR_MSG(0x104,
+					   "Your kernel must be compiled with kernel module loading support.");
+#endif
+			return ERR_PTR(-EINVAL);
+		}
+	}
+	mutex_unlock(&the_lnet.ln_lnd_mutex);
+
+	return lnd;
+}
+
 static int
 lnet_startup_lndnet(struct lnet_net *net, struct lnet_lnd_tunables *tun)
 {
@@ -2525,27 +2557,14 @@ static void lnet_push_target_fini(void)
 	if (lnet_net_unique(net->net_id, &the_lnet.ln_nets, &net_l)) {
 		lnd_type = LNET_NETTYP(net->net_id);
 
-		mutex_lock(&the_lnet.ln_lnd_mutex);
-		lnd = lnet_find_lnd_by_type(lnd_type);
-
-		if (!lnd) {
-			mutex_unlock(&the_lnet.ln_lnd_mutex);
-			rc = request_module("%s", libcfs_lnd2modname(lnd_type));
-			mutex_lock(&the_lnet.ln_lnd_mutex);
-
-			lnd = lnet_find_lnd_by_type(lnd_type);
-			if (!lnd) {
-				mutex_unlock(&the_lnet.ln_lnd_mutex);
-				CERROR("Can't load LND %s, module %s, rc=%d\n",
-				libcfs_lnd2str(lnd_type),
-				libcfs_lnd2modname(lnd_type), rc);
-				rc = -EINVAL;
-				goto failed0;
-			}
+		lnd = lnet_load_lnd(lnd_type);
+		if (IS_ERR(lnd)) {
+			rc = PTR_ERR(lnd);
+			goto failed0;
 		}
 
+		mutex_lock(&the_lnet.ln_lnd_mutex);
 		net->net_lnd = lnd;
-
 		mutex_unlock(&the_lnet.ln_lnd_mutex);
 
 		net_l = net;
@@ -2766,6 +2785,8 @@ int lnet_genl_send_scalar_list(struct sk_buff *msg, u32 portid, u32 seq,
 }
 EXPORT_SYMBOL(lnet_genl_send_scalar_list);
 
+static struct genl_family lnet_family;
+
 /**
  * Initialize LNet library.
  *
@@ -2803,6 +2824,13 @@ int lnet_lib_init(void)
 		return rc;
 	}
 
+	rc = genl_register_family(&lnet_family);
+	if (rc != 0) {
+		lnet_destroy_locks();
+		CERROR("Can't register LNet netlink family: %d\n", rc);
+		return rc;
+	}
+
 	the_lnet.ln_refcount = 0;
 	INIT_LIST_HEAD(&the_lnet.ln_net_zombie);
 	INIT_LIST_HEAD(&the_lnet.ln_msg_resend);
@@ -2846,6 +2874,7 @@ void lnet_lib_exit(void)
 	for (i = 0; i < NUM_LNDS; i++)
 		LASSERT(!the_lnet.ln_lnds[i]);
 	lnet_destroy_locks();
+	genl_unregister_family(&lnet_family);
 }
 
 /**
@@ -3525,31 +3554,24 @@ static int lnet_handle_legacy_ip2nets(char *ip2nets,
 	return rc;
 }
 
-int lnet_dyn_add_ni(struct lnet_ioctl_config_ni *conf)
+int lnet_dyn_add_ni(struct lnet_ioctl_config_ni *conf, u32 net_id,
+		    struct lnet_ioctl_config_lnd_tunables *tun)
 {
 	struct lnet_net *net;
 	struct lnet_ni *ni;
-	struct lnet_ioctl_config_lnd_tunables *tun = NULL;
 	int rc, i;
-	u32 net_id, lnd_type;
-
-	/* get the tunables if they are available */
-	if (conf->lic_cfg_hdr.ioc_len >=
-	    sizeof(*conf) + sizeof(*tun))
-		tun = (struct lnet_ioctl_config_lnd_tunables *)
-			conf->lic_bulk;
+	u32 lnd_type;
 
 	/* handle legacy ip2nets from DLC */
 	if (conf->lic_legacy_ip2nets[0] != '\0')
 		return lnet_handle_legacy_ip2nets(conf->lic_legacy_ip2nets,
 						  tun);
 
-	net_id = LNET_NIDNET(conf->lic_nid);
 	lnd_type = LNET_NETTYP(net_id);
 
 	if (!libcfs_isknown_lnd(lnd_type)) {
 		CERROR("No valid net and lnd information provided\n");
-		return -EINVAL;
+		return -ENOENT;
 	}
 
 	net = lnet_net_alloc(net_id, NULL);
@@ -3559,7 +3581,7 @@ int lnet_dyn_add_ni(struct lnet_ioctl_config_ni *conf)
 	for (i = 0; i < conf->lic_ncpts; i++) {
 		if (conf->lic_cpts[i] >= LNET_CPT_NUMBER) {
 			lnet_net_free(net);
-			return -EINVAL;
+			return -ERANGE;
 		}
 	}
 
@@ -3588,16 +3610,15 @@ int lnet_dyn_add_ni(struct lnet_ioctl_config_ni *conf)
 	return rc;
 }
 
-int lnet_dyn_del_ni(struct lnet_ioctl_config_ni *conf)
+int lnet_dyn_del_ni(struct lnet_nid *nid)
 {
 	struct lnet_net *net;
 	struct lnet_ni *ni;
-	u32 net_id = LNET_NIDNET(conf->lic_nid);
+	u32 net_id = LNET_NID_NET(nid);
 	struct lnet_ping_buffer *pbuf;
 	struct lnet_handle_md ping_mdh;
 	int net_bytes, rc;
 	bool net_empty;
-	u32 addr;
 
 	/* don't allow userspace to shutdown the LOLND */
 	if (LNET_NETTYP(net_id) == LOLND)
@@ -3619,8 +3640,7 @@ int lnet_dyn_del_ni(struct lnet_ioctl_config_ni *conf)
 		goto unlock_net;
 	}
 
-	addr = LNET_NIDADDR(conf->lic_nid);
-	if (addr == 0) {
+	if (!nid_addr_is_set(nid)) {
 		/* remove the entire net */
 		net_bytes = lnet_get_net_ni_bytes_locked(net);
 
@@ -3642,10 +3662,9 @@ int lnet_dyn_del_ni(struct lnet_ioctl_config_ni *conf)
 		goto unlock_api_mutex;
 	}
 
-	ni = lnet_nid2ni_locked(conf->lic_nid, 0);
+	ni = lnet_nid_to_ni_locked(nid, 0);
 	if (!ni) {
-		CERROR("nid %s not found\n",
-		       libcfs_nid2str(conf->lic_nid));
+		CERROR("nid %s not found\n", libcfs_nidstr(nid));
 		rc = -ENOENT;
 		goto unlock_net;
 	}
@@ -3952,8 +3971,6 @@ u32 lnet_get_dlc_seq_locked(void)
 {
 	struct libcfs_ioctl_data *data = arg;
 	struct lnet_ioctl_config_data *config;
-	struct lnet_process_id id4 = {};
-	struct lnet_processid id = {};
 	struct lnet_ni *ni;
 	struct lnet_nid nid;
 	int rc;
@@ -3963,11 +3980,6 @@ u32 lnet_get_dlc_seq_locked(void)
 		     sizeof(struct lnet_ioctl_config_data));
 
 	switch (cmd) {
-	case IOC_LIBCFS_GET_NI:
-		rc = LNetGetId(data->ioc_count, &id);
-		data->ioc_nid = lnet_nid_to_nid4(&id.nid);
-		return rc;
-
 	case IOC_LIBCFS_FAIL_NID:
 		return lnet_fail_nid(data->ioc_nid, data->ioc_count);
 
@@ -4351,6 +4363,7 @@ u32 lnet_get_dlc_seq_locked(void)
 		return lnet_fault_ctl(data->ioc_flags, data);
 
 	case IOC_LIBCFS_PING: {
+		struct lnet_process_id id4;
 		signed long timeout;
 
 		id4.nid = data->ioc_nid;
@@ -4561,6 +4574,682 @@ u32 lnet_get_dlc_seq_locked(void)
 }
 EXPORT_SYMBOL(LNetCtl);
 
+static const struct ln_key_list net_props_list = {
+	.lkl_maxattr			= LNET_NET_ATTR_MAX,
+	.lkl_list			= {
+		[LNET_NET_ATTR_HDR]		= {
+			.lkp_value		= "net",
+			.lkp_key_format		= LNKF_SEQUENCE | LNKF_MAPPING,
+			.lkp_data_type		= NLA_NUL_STRING,
+		},
+		[LNET_NET_ATTR_TYPE]		= {
+			.lkp_value		= "net type",
+			.lkp_data_type		= NLA_STRING
+		},
+		[LNET_NET_ATTR_LOCAL]           = {
+			.lkp_value		= "local NI(s)",
+			.lkp_key_format		= LNKF_SEQUENCE | LNKF_MAPPING,
+			.lkp_data_type		= NLA_NESTED
+		},
+	},
+};
+
+static struct ln_key_list local_ni_list = {
+	.lkl_maxattr			= LNET_NET_LOCAL_NI_ATTR_MAX,
+	.lkl_list			= {
+		[LNET_NET_LOCAL_NI_ATTR_NID]	= {
+			.lkp_value		= "nid",
+			.lkp_data_type		= NLA_STRING
+		},
+		[LNET_NET_LOCAL_NI_ATTR_STATUS] = {
+			.lkp_value		= "status",
+			.lkp_data_type		= NLA_STRING
+		},
+		[LNET_NET_LOCAL_NI_ATTR_INTERFACE] = {
+			.lkp_value		= "interfaces",
+			.lkp_key_format		= LNKF_MAPPING,
+			.lkp_data_type		= NLA_NESTED
+		},
+	},
+};
+
+static const struct ln_key_list local_ni_interfaces_list = {
+	.lkl_maxattr			= LNET_NET_LOCAL_NI_INTF_ATTR_MAX,
+	.lkl_list			= {
+		[LNET_NET_LOCAL_NI_INTF_ATTR_TYPE] = {
+			.lkp_value	= "0",
+			.lkp_data_type	= NLA_STRING
+		},
+	},
+};
+
+/* Use an index since the traversal is across LNet nets and ni collections */
+struct lnet_genl_net_list {
+	unsigned int	lngl_net_id;
+	unsigned int	lngl_idx;
+};
+
+static inline struct lnet_genl_net_list *
+lnet_net_dump_ctx(struct netlink_callback *cb)
+{
+	return (struct lnet_genl_net_list *)cb->args[0];
+}
+
+static int lnet_net_show_done(struct netlink_callback *cb)
+{
+	struct lnet_genl_net_list *nlist = lnet_net_dump_ctx(cb);
+
+	kfree(nlist);
+	cb->args[0] = 0;
+
+	return 0;
+}
+
+/* LNet net ->start() handler for GET requests */
+static int lnet_net_show_start(struct netlink_callback *cb)
+{
+	struct genlmsghdr *gnlh = nlmsg_data(cb->nlh);
+	struct netlink_ext_ack *extack = cb->extack;
+	struct lnet_genl_net_list *nlist;
+	int msg_len = genlmsg_len(gnlh);
+	struct nlattr *params, *top;
+	int rem, rc = 0;
+
+	if (the_lnet.ln_refcount == 0) {
+		NL_SET_ERR_MSG(extack, "LNet stack down");
+		return -ENETDOWN;
+	}
+
+	nlist = kmalloc(sizeof(*nlist), GFP_KERNEL);
+	if (!nlist)
+		return -ENOMEM;
+
+	nlist->lngl_net_id = LNET_NET_ANY;
+	nlist->lngl_idx = 0;
+	cb->args[0] = (long)nlist;
+
+	if (!msg_len)
+		return 0;
+
+	params = genlmsg_data(gnlh);
+	nla_for_each_attr(top, params, msg_len, rem) {
+		struct nlattr *net;
+		int rem2;
+
+		nla_for_each_nested(net, top, rem2) {
+			char filter[LNET_NIDSTR_SIZE];
+
+			if (nla_type(net) != LN_SCALAR_ATTR_VALUE ||
+			    nla_strcmp(net, "name") != 0)
+				continue;
+
+			net = nla_next(net, &rem2);
+			if (nla_type(net) != LN_SCALAR_ATTR_VALUE) {
+				NL_SET_ERR_MSG(extack, "invalid config param");
+				rc = -EINVAL;
+				goto report_err;
+			}
+
+			rc = nla_strlcpy(filter, net, sizeof(filter));
+			if (rc < 0) {
+				NL_SET_ERR_MSG(extack, "failed to get param");
+				goto report_err;
+			}
+			rc = 0;
+
+			nlist->lngl_net_id = libcfs_str2net(filter);
+			if (nlist->lngl_net_id == LNET_NET_ANY) {
+				NL_SET_ERR_MSG(extack, "cannot parse net");
+				rc = -ENOENT;
+				goto report_err;
+			}
+		}
+	}
+report_err:
+	if (rc < 0)
+		lnet_net_show_done(cb);
+
+	return rc;
+}
+
+static int lnet_net_show_dump(struct sk_buff *msg,
+			      struct netlink_callback *cb)
+{
+	struct lnet_genl_net_list *nlist = lnet_net_dump_ctx(cb);
+	struct netlink_ext_ack *extack = cb->extack;
+	int portid = NETLINK_CB(cb->skb).portid;
+	int seq = cb->nlh->nlmsg_seq;
+	struct lnet_net *net;
+	int idx = 0, rc = 0;
+	bool found = false;
+	void *hdr = NULL;
+
+	if (!nlist->lngl_idx) {
+		const struct ln_key_list *all[] = {
+			&net_props_list, &local_ni_list,
+			&local_ni_interfaces_list,
+			NULL
+		};
+
+		rc = lnet_genl_send_scalar_list(msg, portid, seq,
+						&lnet_family,
+						NLM_F_CREATE | NLM_F_MULTI,
+						LNET_CMD_NETS, all);
+		if (rc < 0) {
+			NL_SET_ERR_MSG(extack, "failed to send key table");
+			goto send_error;
+		}
+	}
+
+	lnet_net_lock(LNET_LOCK_EX);
+
+	list_for_each_entry(net, &the_lnet.ln_nets, net_list) {
+		struct lnet_ni *ni;
+
+		if (nlist->lngl_net_id != LNET_NET_ANY &&
+		    nlist->lngl_net_id != net->net_id)
+			continue;
+
+		list_for_each_entry(ni, &net->net_ni_list, ni_netlist) {
+			struct nlattr *local_ni, *ni_attr;
+			char *status = "up";
+
+			if (idx++ < nlist->lngl_idx)
+				continue;
+
+			hdr = genlmsg_put(msg, portid, seq, &lnet_family,
+					  NLM_F_MULTI, LNET_CMD_NETS);
+			if (!hdr) {
+				NL_SET_ERR_MSG(extack, "failed to send values");
+				rc = -EMSGSIZE;
+				goto net_unlock;
+			}
+
+			if (idx == 1)
+				nla_put_string(msg, LNET_NET_ATTR_HDR, "");
+
+			nla_put_string(msg, LNET_NET_ATTR_TYPE,
+				       libcfs_net2str(net->net_id));
+			found = true;
+
+			local_ni = nla_nest_start(msg, LNET_NET_ATTR_LOCAL);
+			ni_attr = nla_nest_start(msg, idx - 1);
+
+			lnet_ni_lock(ni);
+			nla_put_string(msg, LNET_NET_LOCAL_NI_ATTR_NID,
+				       libcfs_nidstr(&ni->ni_nid));
+			if (nid_is_lo0(&ni->ni_nid) &&
+			    *ni->ni_status != LNET_NI_STATUS_UP)
+				status = "down";
+			nla_put_string(msg, LNET_NET_LOCAL_NI_ATTR_STATUS, "up");
+
+			if (!nid_is_lo0(&ni->ni_nid) && ni->ni_interface) {
+				struct nlattr *intf_nest, *intf_attr;
+
+				intf_nest = nla_nest_start(msg,
+							   LNET_NET_LOCAL_NI_ATTR_INTERFACE);
+				intf_attr = nla_nest_start(msg, 0);
+				nla_put_string(msg,
+					       LNET_NET_LOCAL_NI_INTF_ATTR_TYPE,
+					       ni->ni_interface);
+				nla_nest_end(msg, intf_attr);
+				nla_nest_end(msg, intf_nest);
+			}
+
+			lnet_ni_unlock(ni);
+			nla_nest_end(msg, ni_attr);
+			nla_nest_end(msg, local_ni);
+
+			genlmsg_end(msg, hdr);
+		}
+	}
+
+	if (!found) {
+		struct nlmsghdr *nlh = nlmsg_hdr(msg);
+
+		nlmsg_cancel(msg, nlh);
+		NL_SET_ERR_MSG(extack, "Network is down");
+		rc = -ESRCH;
+	}
+net_unlock:
+	lnet_net_unlock(LNET_LOCK_EX);
+send_error:
+	nlist->lngl_idx = idx;
+
+	return rc;
+}
+
+static int lnet_genl_parse_tunables(struct nlattr *settings,
+				    struct lnet_ioctl_config_lnd_tunables *tun)
+{
+	struct nlattr *param;
+	int rem, rc = 0;
+
+	nla_for_each_nested(param, settings, rem) {
+		int type = LNET_NET_LOCAL_NI_TUNABLES_ATTR_UNSPEC;
+		s64 num;
+
+		if (nla_type(param) != LN_SCALAR_ATTR_VALUE)
+			continue;
+
+		if (nla_strcmp(param, "peer_timeout") == 0)
+			type = LNET_NET_LOCAL_NI_TUNABLES_ATTR_PEER_TIMEOUT;
+		else if (nla_strcmp(param, "peer_credits") == 0)
+			type = LNET_NET_LOCAL_NI_TUNABLES_ATTR_PEER_CREDITS;
+		else if (nla_strcmp(param, "peer_buffer_credits") == 0)
+			type = LNET_NET_LOCAL_NI_TUNABLES_ATTR_PEER_BUFFER_CREDITS;
+		else if (nla_strcmp(param, "credits") == 0)
+			type = LNET_NET_LOCAL_NI_TUNABLES_ATTR_CREDITS;
+
+		param = nla_next(param, &rem);
+		if (nla_type(param) != LN_SCALAR_ATTR_INT_VALUE)
+			return -EINVAL;
+
+		num = nla_get_s64(param);
+		switch (type) {
+		case LNET_NET_LOCAL_NI_TUNABLES_ATTR_PEER_TIMEOUT:
+			tun->lt_cmn.lct_peer_timeout = num;
+			break;
+		case LNET_NET_LOCAL_NI_TUNABLES_ATTR_PEER_CREDITS:
+			tun->lt_cmn.lct_peer_tx_credits = num;
+			break;
+		case LNET_NET_LOCAL_NI_TUNABLES_ATTR_PEER_BUFFER_CREDITS:
+			tun->lt_cmn.lct_peer_rtr_credits = num;
+			break;
+		case LNET_NET_LOCAL_NI_TUNABLES_ATTR_CREDITS:
+			tun->lt_cmn.lct_max_tx_credits = num;
+			break;
+		default:
+			rc = -EINVAL;
+			break;
+		}
+	}
+	return rc;
+}
+
+static int
+lnet_genl_parse_lnd_tunables(struct nlattr *settings,
+			     struct lnet_ioctl_config_lnd_tunables *tun,
+			     const struct lnet_lnd *lnd)
+{
+	const struct ln_key_list *list = lnd->lnd_keys;
+	struct nlattr *param;
+	int rem, rc = 0;
+	int i = 1;
+
+	if (!list)
+		return 0;
+
+	if (!lnd->lnd_nl_set)
+		return -EOPNOTSUPP;
+
+	if (!list->lkl_maxattr)
+		return -ERANGE;
+
+	nla_for_each_nested(param, settings, rem) {
+		if (nla_type(param) != LN_SCALAR_ATTR_VALUE)
+			continue;
+
+		for (i = 1; i <= list->lkl_maxattr; i++) {
+			if (!list->lkl_list[i].lkp_value ||
+			    nla_strcmp(param, list->lkl_list[i].lkp_value) != 0)
+				continue;
+
+			param = nla_next(param, &rem);
+			rc = lnd->lnd_nl_set(LNET_CMD_NETS, param, i, tun);
+			if (rc < 0)
+				return rc;
+		}
+	}
+
+	return rc;
+}
+
+static int
+lnet_genl_parse_local_ni(struct nlattr *entry, struct genl_info *info,
+			 int net_id, struct lnet_ioctl_config_ni *conf,
+			 struct lnet_ioctl_config_lnd_tunables *tun,
+			 bool *ni_list)
+{
+	struct nlattr *settings;
+	int rem3, rc = 0;
+
+	nla_for_each_nested(settings, entry, rem3) {
+		if (nla_type(settings) != LN_SCALAR_ATTR_VALUE)
+			continue;
+
+		if (nla_strcmp(settings, "interfaces") == 0) {
+			struct nlattr *intf;
+			int rem4;
+
+			settings = nla_next(settings, &rem3);
+			if (nla_type(settings) !=
+			    LN_SCALAR_ATTR_LIST) {
+				GENL_SET_ERR_MSG(info,
+						 "invalid interfaces");
+				rc = -EINVAL;
+				goto out;
+			}
+
+			nla_for_each_nested(intf, settings, rem4) {
+				intf = nla_next(intf, &rem4);
+				if (nla_type(intf) !=
+				    LN_SCALAR_ATTR_VALUE) {
+					GENL_SET_ERR_MSG(info,
+							 "0 key is invalid");
+					rc = -EINVAL;
+					goto out;
+				}
+
+				rc = nla_strlcpy(conf->lic_ni_intf, intf,
+						 sizeof(conf->lic_ni_intf));
+				if (rc < 0) {
+					GENL_SET_ERR_MSG(info,
+							 "failed to parse interfaces");
+					goto out;
+				}
+			}
+			*ni_list = true;
+		} else if (nla_strcmp(settings, "tunables") == 0) {
+			settings = nla_next(settings, &rem3);
+			if (nla_type(settings) !=
+			    LN_SCALAR_ATTR_LIST) {
+				GENL_SET_ERR_MSG(info,
+						 "invalid tunables");
+				rc = -EINVAL;
+				goto out;
+			}
+
+			rc = lnet_genl_parse_tunables(settings, tun);
+			if (rc < 0) {
+				GENL_SET_ERR_MSG(info,
+						 "failed to parse tunables");
+				goto out;
+			}
+		} else if ((nla_strcmp(settings, "lnd tunables") == 0)) {
+			const struct lnet_lnd *lnd;
+
+			lnd = lnet_load_lnd(LNET_NETTYP(net_id));
+			if (IS_ERR(lnd)) {
+				GENL_SET_ERR_MSG(info,
+						 "LND type not supported");
+				rc = PTR_ERR(lnd);
+				goto out;
+			}
+
+			settings = nla_next(settings, &rem3);
+			if (nla_type(settings) !=
+			    LN_SCALAR_ATTR_LIST) {
+				GENL_SET_ERR_MSG(info,
+						 "lnd tunables should be list\n");
+				rc = -EINVAL;
+				goto out;
+			}
+
+			rc = lnet_genl_parse_lnd_tunables(settings,
+							  tun, lnd);
+			if (rc < 0) {
+				GENL_SET_ERR_MSG(info,
+						 "failed to parse lnd tunables");
+				goto out;
+			}
+		} else if (nla_strcmp(settings, "CPT") == 0) {
+			struct nlattr *cpt;
+			int rem4;
+
+			settings = nla_next(settings, &rem3);
+			if (nla_type(settings) != LN_SCALAR_ATTR_LIST) {
+				GENL_SET_ERR_MSG(info,
+						 "CPT should be list");
+				rc = -EINVAL;
+				goto out;
+			}
+
+			nla_for_each_nested(cpt, settings, rem4) {
+				s64 core;
+
+				if (nla_type(cpt) !=
+				    LN_SCALAR_ATTR_INT_VALUE) {
+					GENL_SET_ERR_MSG(info,
+							 "invalid CPT config");
+					rc = -EINVAL;
+					goto out;
+				}
+
+				core = nla_get_s64(cpt);
+				if (core >= LNET_CPT_NUMBER) {
+					GENL_SET_ERR_MSG(info,
+							 "invalid CPT value");
+					rc = -ERANGE;
+					goto out;
+				}
+
+				conf->lic_cpts[conf->lic_ncpts] = core;
+				conf->lic_ncpts++;
+			}
+		}
+	}
+out:
+	return rc;
+}
+
+static int lnet_net_cmd(struct sk_buff *skb, struct genl_info *info)
+{
+	struct nlmsghdr *nlh = nlmsg_hdr(skb);
+	struct genlmsghdr *gnlh = nlmsg_data(nlh);
+	struct nlattr *params = genlmsg_data(gnlh);
+	int msg_len, rem, rc = 0;
+	struct nlattr *attr;
+
+	msg_len = genlmsg_len(gnlh);
+	if (!msg_len) {
+		GENL_SET_ERR_MSG(info, "no configuration");
+		return -ENOMSG;
+	}
+
+	nla_for_each_attr(attr, params, msg_len, rem) {
+		struct lnet_ioctl_config_ni conf;
+		u32 net_id = LNET_NET_ANY;
+		struct nlattr *entry;
+		bool ni_list = false;
+		int rem2;
+
+		if (nla_type(attr) != LN_SCALAR_ATTR_LIST)
+			continue;
+
+		nla_for_each_nested(entry, attr, rem2) {
+			switch (nla_type(entry)) {
+			case LN_SCALAR_ATTR_VALUE: {
+				ssize_t len;
+
+				memset(&conf, 0, sizeof(conf));
+				if (nla_strcmp(entry, "ip2net") == 0) {
+					entry = nla_next(entry, &rem2);
+					if (nla_type(entry) !=
+					    LN_SCALAR_ATTR_VALUE) {
+						GENL_SET_ERR_MSG(info,
+								 "ip2net has invalid key");
+						rc = -EINVAL;
+						goto out;
+					}
+
+					len = nla_strlcpy(conf.lic_legacy_ip2nets,
+							  entry,
+							  sizeof(conf.lic_legacy_ip2nets));
+					if (len < 0) {
+						GENL_SET_ERR_MSG(info,
+								 "ip2net key string is invalid");
+						rc = len;
+						goto out;
+					}
+					ni_list = true;
+				} else if (nla_strcmp(entry, "net type") == 0) {
+					char tmp[LNET_NIDSTR_SIZE];
+
+					entry = nla_next(entry, &rem2);
+					if (nla_type(entry) !=
+					    LN_SCALAR_ATTR_VALUE) {
+						GENL_SET_ERR_MSG(info,
+								 "net type has invalid key");
+						rc = -EINVAL;
+						goto out;
+					}
+
+					len = nla_strlcpy(tmp, entry,
+							  sizeof(tmp));
+					if (len < 0) {
+						GENL_SET_ERR_MSG(info,
+								 "net type key string is invalid");
+						rc = len;
+						goto out;
+					}
+
+					net_id = libcfs_str2net(tmp);
+					if (!net_id) {
+						GENL_SET_ERR_MSG(info,
+								 "cannot parse net");
+						rc = -ENODEV;
+						goto out;
+					}
+					if (LNET_NETTYP(net_id) == LOLND) {
+						GENL_SET_ERR_MSG(info,
+								 "setting @lo not allowed");
+						rc = -ENODEV;
+						goto out;
+					}
+					conf.lic_legacy_ip2nets[0] = '\0';
+					conf.lic_ni_intf[0] = '\0';
+					ni_list = false;
+				}
+				if (rc < 0)
+					goto out;
+				break;
+			}
+			case LN_SCALAR_ATTR_LIST: {
+				bool create = info->nlhdr->nlmsg_flags &
+					      NLM_F_CREATE;
+				struct lnet_ioctl_config_lnd_tunables tun;
+
+				memset(&tun, 0, sizeof(tun));
+				tun.lt_cmn.lct_peer_timeout = -1;
+				conf.lic_ncpts = 0;
+
+				rc = lnet_genl_parse_local_ni(entry, info,
+							      net_id, &conf,
+							      &tun, &ni_list);
+				if (rc < 0)
+					goto out;
+
+				if (!create) {
+					struct lnet_net *net;
+					struct lnet_ni *ni;
+
+					rc = -ENODEV;
+					if (!strlen(conf.lic_ni_intf)) {
+						GENL_SET_ERR_MSG(info,
+								 "interface is missing");
+						goto out;
+					}
+
+					lnet_net_lock(LNET_LOCK_EX);
+					net = lnet_get_net_locked(net_id);
+					if (!net) {
+						GENL_SET_ERR_MSG(info,
+								 "LNet net doesn't exist");
+						goto out;
+					}
+					list_for_each_entry(ni, &net->net_ni_list,
+							    ni_netlist) {
+						if (!ni->ni_interface ||
+						    strncmp(ni->ni_interface,
+							    conf.lic_ni_intf,
+							    strlen(conf.lic_ni_intf)) != 0) {
+							ni = NULL;
+							continue;
+						}
+
+						lnet_net_unlock(LNET_LOCK_EX);
+						rc = lnet_dyn_del_ni(&ni->ni_nid);
+						lnet_net_lock(LNET_LOCK_EX);
+						if (rc < 0) {
+							GENL_SET_ERR_MSG(info,
+									 "cannot del LNet NI");
+							goto out;
+						}
+						break;
+					}
+
+					lnet_net_unlock(LNET_LOCK_EX);
+				} else {
+					rc = lnet_dyn_add_ni(&conf, net_id, &tun);
+					switch (rc) {
+					case -ENOENT:
+						GENL_SET_ERR_MSG(info,
+								 "cannot parse net");
+						break;
+					case -ERANGE:
+						GENL_SET_ERR_MSG(info,
+								 "invalid CPT set");
+					fallthrough;
+					default:
+						GENL_SET_ERR_MSG(info,
+								 "cannot add LNet NI");
+					case 0:
+						break;
+					}
+					if (rc < 0)
+						goto out;
+				}
+				break;
+			}
+			/* it is possible a newer version of the user land send
+			 * values older kernels doesn't handle. So silently
+			 * ignore these values
+			 */
+			default:
+				break;
+			}
+		}
+
+		/* Handle case of just sent NET with no list of NIDs */
+		if (!(info->nlhdr->nlmsg_flags & NLM_F_CREATE) && !ni_list) {
+			rc = lnet_dyn_del_net(net_id);
+			if (rc < 0) {
+				GENL_SET_ERR_MSG(info,
+						 "cannot del network");
+			}
+		}
+	}
+out:
+	return rc;
+}
+
+static const struct genl_multicast_group lnet_mcast_grps[] = {
+	{ .name	=	"ip2net",	},
+	{ .name =	"net",		},
+};
+
+static const struct genl_ops lnet_genl_ops[] = {
+	{
+		.cmd		= LNET_CMD_NETS,
+		.start		= lnet_net_show_start,
+		.dumpit		= lnet_net_show_dump,
+		.done		= lnet_net_show_done,
+		.doit		= lnet_net_cmd,
+	},
+};
+
+static struct genl_family lnet_family = {
+	.name		= LNET_GENL_NAME,
+	.version	= LNET_GENL_VERSION,
+	.module		= THIS_MODULE,
+	.netnsok	= true,
+	.ops		= lnet_genl_ops,
+	.n_ops		= ARRAY_SIZE(lnet_genl_ops),
+	.mcgrps		= lnet_mcast_grps,
+	.n_mcgrps	= ARRAY_SIZE(lnet_mcast_grps),
+};
+
 void LNetDebugPeer(struct lnet_processid *id)
 {
 	lnet_debug_peer(lnet_nid_to_nid4(&id->nid));
diff --git a/net/lnet/lnet/config.c b/net/lnet/lnet/config.c
index cebc725..4b2d776 100644
--- a/net/lnet/lnet/config.c
+++ b/net/lnet/lnet/config.c
@@ -367,8 +367,7 @@ struct lnet_net *
 	return net;
 }
 
-static int
-lnet_ni_add_interface(struct lnet_ni *ni, char *iface)
+int lnet_ni_add_interface(struct lnet_ni *ni, char *iface)
 {
 	if (!ni)
 		return -ENOMEM;
@@ -395,6 +394,7 @@ struct lnet_net *
 
 	return 0;
 }
+EXPORT_SYMBOL(lnet_ni_add_interface);
 
 static struct lnet_ni *
 lnet_ni_alloc_common(struct lnet_net *net, char *iface)
diff --git a/net/lnet/lnet/module.c b/net/lnet/lnet/module.c
index 9d7b39a..6e41e4b 100644
--- a/net/lnet/lnet/module.c
+++ b/net/lnet/lnet/module.c
@@ -41,8 +41,7 @@
 
 static DEFINE_MUTEX(lnet_config_mutex);
 
-static int
-lnet_configure(void *arg)
+int lnet_configure(void *arg)
 {
 	/* 'arg' only there so I can be passed to cfs_create_thread() */
 	int rc = 0;
@@ -68,8 +67,7 @@
 	return rc;
 }
 
-static int
-lnet_unconfigure(void)
+int lnet_unconfigure(void)
 {
 	int refcount;
 
@@ -134,16 +132,26 @@
 {
 	struct lnet_ioctl_config_ni *conf =
 		(struct lnet_ioctl_config_ni *)hdr;
-	int rc;
+	int rc = -EINVAL;
 
 	if (conf->lic_cfg_hdr.ioc_len < sizeof(*conf))
-		return -EINVAL;
+		return rc;
 
 	mutex_lock(&lnet_config_mutex);
-	if (the_lnet.ln_niinit_self)
-		rc = lnet_dyn_add_ni(conf);
-	else
-		rc = -EINVAL;
+	if (the_lnet.ln_niinit_self) {
+		struct lnet_ioctl_config_lnd_tunables *tun = NULL;
+		struct lnet_nid nid;
+		u32 net_id;
+
+		/* get the tunables if they are available */
+		if (conf->lic_cfg_hdr.ioc_len >=
+		    sizeof(*conf) + sizeof(*tun))
+			tun = (struct lnet_ioctl_config_lnd_tunables *) conf->lic_bulk;
+
+		lnet_nid4_to_nid(conf->lic_nid, &nid);
+		net_id = LNET_NID_NET(&nid);
+		rc = lnet_dyn_add_ni(conf, net_id, tun);
+	}
 	mutex_unlock(&lnet_config_mutex);
 
 	return rc;
@@ -154,16 +162,16 @@
 {
 	struct lnet_ioctl_config_ni *conf =
 		(struct lnet_ioctl_config_ni *)hdr;
-	int rc;
+	struct lnet_nid nid;
+	int rc = EINVAL;
 
-	if (conf->lic_cfg_hdr.ioc_len < sizeof(*conf))
-		return -EINVAL;
+	if (conf->lic_cfg_hdr.ioc_len < sizeof(*conf) ||
+	    !the_lnet.ln_niinit_self)
+		return rc;
 
+	lnet_nid4_to_nid(conf->lic_nid, &nid);
 	mutex_lock(&lnet_config_mutex);
-	if (the_lnet.ln_niinit_self)
-		rc = lnet_dyn_del_ni(conf);
-	else
-		rc = -EINVAL;
+	rc = lnet_dyn_del_ni(&nid);
 	mutex_unlock(&lnet_config_mutex);
 
 	return rc;
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
