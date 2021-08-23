Return-Path: <SRS0=6+cL=NO=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B4E9EC4338F
	for <lustre-devel@archiver.kernel.org>; Mon, 23 Aug 2021 02:28:03 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 618B0611F2
	for <lustre-devel@archiver.kernel.org>; Mon, 23 Aug 2021 02:28:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.1 mail.kernel.org 618B0611F2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 7C42521CBB1;
	Sun, 22 Aug 2021 19:27:58 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 95A9721CAB9
 for <lustre-devel@lists.lustre.org>; Sun, 22 Aug 2021 19:27:52 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 300CB100BAFC;
 Sun, 22 Aug 2021 22:27:48 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 276E8B6C67; Sun, 22 Aug 2021 22:27:48 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 22 Aug 2021 22:27:40 -0400
Message-Id: <1629685666-4533-10-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1629685666-4533-1-git-send-email-jsimmons@infradead.org>
References: <1629685666-4533-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 09/15] lnet: socklnd: allow dynamic setting
 of conns_per_peer
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

Modify lnetctl and associated code to allow dynamic setting
of conns_per_peer lnd parameter per ni.

The parameter can be set for a specific active nid:
        lnetctl net set --nid 192.168.122.10@tcp --conns-per-peer=4

Or when adding a new net, taking effect on the new nid:
        lnetctl net add --net tcp --if eth0 --conns-per-peer=1

By default, conns_per_peer value specified as the module parameter
shall be used.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12815
Lustre-commit: a5cbe7883db6d77b ("LU-12815 socklnd: allow dynamic setting of conns_per_peer")
Signed-off-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/41463
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/lib-lnet.h              |  3 ++
 include/uapi/linux/lnet/libcfs_ioctl.h     |  3 +-
 include/uapi/linux/lnet/lnet-dlc.h         | 14 ++++++
 net/lnet/klnds/socklnd/socklnd.c           | 70 +++++++++++++++---------------
 net/lnet/klnds/socklnd/socklnd.h           |  4 ++
 net/lnet/klnds/socklnd/socklnd_modparams.c | 55 +++++++++++++++++++++--
 net/lnet/lnet/api-ni.c                     | 43 ++++++++++++++++++
 7 files changed, 154 insertions(+), 38 deletions(-)

diff --git a/include/linux/lnet/lib-lnet.h b/include/linux/lnet/lib-lnet.h
index ed54477..760c093 100644
--- a/include/linux/lnet/lib-lnet.h
+++ b/include/linux/lnet/lib-lnet.h
@@ -86,6 +86,9 @@
 #define DEFAULT_PEER_CREDITS	8
 #define DEFAULT_CREDITS	256
 
+/* default number of connections per peer */
+#define DEFAULT_CONNS_PER_PEER	1
+
 int choose_ipv4_src(u32 *ret, int interface, u32 dst_ipaddr, struct net *ns);
 
 bool lnet_is_route_alive(struct lnet_route *route);
diff --git a/include/uapi/linux/lnet/libcfs_ioctl.h b/include/uapi/linux/lnet/libcfs_ioctl.h
index 7b1c880..f2ae76c 100644
--- a/include/uapi/linux/lnet/libcfs_ioctl.h
+++ b/include/uapi/linux/lnet/libcfs_ioctl.h
@@ -156,6 +156,7 @@ struct libcfs_ioctl_data {
 #define IOC_LIBCFS_GET_UDSP		_IOWR(IOC_LIBCFS_TYPE, 108, IOCTL_CONFIG_SIZE)
 #define IOC_LIBCFS_GET_CONST_UDSP_INFO	_IOWR(IOC_LIBCFS_TYPE, 109, IOCTL_CONFIG_SIZE)
 #define IOC_LIBCFS_RESET_LNET_STATS	_IOWR(IOC_LIBCFS_TYPE, 110, IOCTL_CONFIG_SIZE)
-#define IOC_LIBCFS_MAX_NR				       110
+#define IOC_LIBCFS_SET_CONNS_PER_PEER	_IOWR(IOC_LIBCFS_TYPE, 111, IOCTL_CONFIG_SIZE)
+#define IOC_LIBCFS_MAX_NR				       111
 
 #endif /* __LIBCFS_IOCTL_H__ */
diff --git a/include/uapi/linux/lnet/lnet-dlc.h b/include/uapi/linux/lnet/lnet-dlc.h
index ef60224..2ca70eb 100644
--- a/include/uapi/linux/lnet/lnet-dlc.h
+++ b/include/uapi/linux/lnet/lnet-dlc.h
@@ -81,9 +81,16 @@ struct lnet_ioctl_config_o2iblnd_tunables {
 	__u16 lnd_ntx;
 };
 
+struct lnet_ioctl_config_socklnd_tunables {
+	__u32 lnd_version;
+	__u16 lnd_conns_per_peer;
+	__u16 lnd_pad;
+};
+
 struct lnet_lnd_tunables {
 	union {
 		struct lnet_ioctl_config_o2iblnd_tunables lnd_o2ib;
+		struct lnet_ioctl_config_socklnd_tunables lnd_sock;
 	} lnd_tun_u;
 };
 
@@ -280,6 +287,13 @@ struct lnet_ioctl_reset_health_cfg {
 	lnet_nid_t rh_nid;
 };
 
+struct lnet_ioctl_reset_conns_per_peer_cfg {
+	struct libcfs_ioctl_hdr rcpp_hdr;
+	__u16 rcpp_all:1;
+	__s16 rcpp_value;
+	lnet_nid_t rcpp_nid;
+};
+
 struct lnet_ioctl_recovery_list {
 	struct libcfs_ioctl_hdr rlst_hdr;
 	enum lnet_health_type rlst_type:32;
diff --git a/net/lnet/klnds/socklnd/socklnd.c b/net/lnet/klnds/socklnd/socklnd.c
index cbbbb0c..96cb0e0 100644
--- a/net/lnet/klnds/socklnd/socklnd.c
+++ b/net/lnet/klnds/socklnd/socklnd.c
@@ -37,7 +37,7 @@
  * Author: Eric Barton <eric@bartonsoftware.com>
  */
 
-#include <linux/pci.h>
+#include <linux/ethtool.h>
 #include <linux/inetdevice.h>
 #include <linux/sunrpc/addr.h>
 #include "socklnd.h"
@@ -135,6 +135,7 @@ static int ksocknal_ip2index(struct sockaddr *addr, struct lnet_ni *ni)
 	conn_cb->ksnr_ctrl_conn_count = 0;
 	conn_cb->ksnr_blki_conn_count = 0;
 	conn_cb->ksnr_blko_conn_count = 0;
+	conn_cb->ksnr_max_conns = 0;
 
 	return conn_cb;
 }
@@ -394,6 +395,19 @@ struct ksock_peer_ni *
 	return count;
 }
 
+static unsigned int
+ksocknal_get_conns_per_peer(struct ksock_peer_ni *peer_ni)
+{
+	struct lnet_ni *ni = peer_ni->ksnp_ni;
+	struct lnet_ioctl_config_socklnd_tunables *tunables;
+
+	LASSERT(ni);
+
+	tunables = &ni->ni_lnd_tunables.lnd_tun_u.lnd_sock;
+
+	return tunables->lnd_conns_per_peer;
+}
+
 static void
 ksocknal_incr_conn_count(struct ksock_conn_cb *conn_cb,
 			 int type)
@@ -409,19 +423,16 @@ struct ksock_peer_ni *
 		break;
 	case SOCKLND_CONN_BULK_IN:
 		conn_cb->ksnr_blki_conn_count++;
-		if (conn_cb->ksnr_blki_conn_count >=
-		    *ksocknal_tunables.ksnd_conns_per_peer)
+		if (conn_cb->ksnr_blki_conn_count >= conn_cb->ksnr_max_conns)
 			conn_cb->ksnr_connected |= BIT(type);
 		break;
 	case SOCKLND_CONN_BULK_OUT:
 		conn_cb->ksnr_blko_conn_count++;
-		if (conn_cb->ksnr_blko_conn_count >=
-		    *ksocknal_tunables.ksnd_conns_per_peer)
+		if (conn_cb->ksnr_blko_conn_count >= conn_cb->ksnr_max_conns)
 			conn_cb->ksnr_connected |= BIT(type);
 		break;
 	case SOCKLND_CONN_ANY:
-		if (conn_cb->ksnr_conn_count >=
-		    *ksocknal_tunables.ksnd_conns_per_peer)
+		if (conn_cb->ksnr_conn_count >= conn_cb->ksnr_max_conns)
 			conn_cb->ksnr_connected |= BIT(type);
 		break;
 	default:
@@ -429,9 +440,8 @@ struct ksock_peer_ni *
 		break;
 	}
 
-	CDEBUG(D_NET, "Add conn type %d, ksnr_connected %x conns_per_peer %d\n",
-	       type, conn_cb->ksnr_connected,
-	       *ksocknal_tunables.ksnd_conns_per_peer);
+	CDEBUG(D_NET, "Add conn type %d, ksnr_connected %x ksnr_max_conns %d\n",
+	       type, conn_cb->ksnr_connected, conn_cb->ksnr_max_conns);
 }
 
 static void
@@ -597,6 +607,13 @@ struct ksock_peer_ni *
 
 	ksocknal_add_conn_cb_locked(peer_ni, conn_cb);
 
+	/* Remember conns_per_peer setting at the time
+	 * of connection initiation. It will define the
+	 * max number of conns per type for this conn_cb
+	 * while it's in use.
+	 */
+	conn_cb->ksnr_max_conns = ksocknal_get_conns_per_peer(peer_ni);
+
 	write_unlock_bh(&ksocknal_data.ksnd_global_lock);
 
 	return 0;
@@ -1002,7 +1019,13 @@ struct ksock_peer_ni *
 				continue;
 
 			num_dup++;
-			if (num_dup < *ksocknal_tunables.ksnd_conns_per_peer)
+			/* If max conns per type is not registered in conn_cb
+			 * as ksnr_max_conns, use ni's conns_per_peer
+			 */
+			if ((peer_ni->ksnp_conn_cb &&
+			     num_dup < peer_ni->ksnp_conn_cb->ksnr_max_conns) ||
+			    (!peer_ni->ksnp_conn_cb &&
+			     num_dup < ksocknal_get_conns_per_peer(peer_ni)))
 				continue;
 
 			/* Reply on a passive connection attempt so the peer_ni
@@ -1229,7 +1252,7 @@ struct ksock_peer_ni *
 		 * of the given type got created
 		 */
 		if (ksocknal_get_conn_count_by_type(conn_cb, conn->ksnc_type) ==
-		    *ksocknal_tunables.ksnd_conns_per_peer)
+		    conn_cb->ksnr_max_conns)
 			LASSERT((conn_cb->ksnr_connected &
 				BIT(conn->ksnc_type)) != 0);
 
@@ -2288,7 +2311,6 @@ static int ksocknal_device_event(struct notifier_block *unused,
 ksocknal_startup(struct lnet_ni *ni)
 {
 	struct ksock_net *net;
-	struct lnet_ioctl_config_lnd_cmn_tunables *net_tunables;
 	struct ksock_interface *ksi = NULL;
 	struct lnet_inetdev *ifaces = NULL;
 	struct sockaddr_in *sa;
@@ -2309,28 +2331,8 @@ static int ksocknal_device_event(struct notifier_block *unused,
 
 	net->ksnn_incarnation = ktime_get_real_ns();
 	ni->ni_data = net;
-	net_tunables = &ni->ni_net->net_tunables;
-
-	if (net_tunables->lct_peer_timeout == -1)
-		net_tunables->lct_peer_timeout =
-			*ksocknal_tunables.ksnd_peertimeout;
-
-	if (net_tunables->lct_max_tx_credits == -1)
-		net_tunables->lct_max_tx_credits =
-			*ksocknal_tunables.ksnd_credits;
-
-	if (net_tunables->lct_peer_tx_credits == -1)
-		net_tunables->lct_peer_tx_credits =
-			*ksocknal_tunables.ksnd_peertxcredits;
-
-	if (net_tunables->lct_peer_tx_credits >
-	    net_tunables->lct_max_tx_credits)
-		net_tunables->lct_peer_tx_credits =
-			net_tunables->lct_max_tx_credits;
 
-	if (net_tunables->lct_peer_rtr_credits == -1)
-		net_tunables->lct_peer_rtr_credits =
-			*ksocknal_tunables.ksnd_peerrtrcredits;
+	ksocknal_tunables_setup(ni);
 
 	rc = lnet_inet_enumerate(&ifaces, ni->ni_net_ns);
 	if (rc < 0)
diff --git a/net/lnet/klnds/socklnd/socklnd.h b/net/lnet/klnds/socklnd/socklnd.h
index 45103a3..7a55492 100644
--- a/net/lnet/klnds/socklnd/socklnd.h
+++ b/net/lnet/klnds/socklnd/socklnd.h
@@ -403,6 +403,9 @@ struct ksock_conn_cb {
 	int			ksnr_conn_count;	/* total # conns for
 							 * this cb
 							 */
+	unsigned int		ksnr_max_conns;		/* conns_per_peer at
+							 * peer creation
+							 */
 };
 
 #define SOCKNAL_KEEPALIVE_PING	1	/* cookie for keepalive ping */
@@ -696,6 +699,7 @@ int ksocknal_lib_get_conn_tunables(struct ksock_conn *conn, int *txmem,
 void ksocknal_write_callback(struct ksock_conn *conn);
 
 int ksocknal_tunables_init(void);
+void ksocknal_tunables_setup(struct lnet_ni *ni);
 
 void ksocknal_lib_csum_tx(struct ksock_tx *tx);
 
diff --git a/net/lnet/klnds/socklnd/socklnd_modparams.c b/net/lnet/klnds/socklnd/socklnd_modparams.c
index bc772e4..c6cce1e 100644
--- a/net/lnet/klnds/socklnd/socklnd_modparams.c
+++ b/net/lnet/klnds/socklnd/socklnd_modparams.c
@@ -24,6 +24,8 @@
 #include <asm/hypervisor.h>
 #endif
 
+#define CURRENT_LND_VERSION 1
+
 static int sock_timeout;
 module_param(sock_timeout, int, 0644);
 MODULE_PARM_DESC(sock_timeout, "dead socket timeout (seconds)");
@@ -139,8 +141,8 @@
 module_param(zc_recv_min_nfrags, int, 0644);
 MODULE_PARM_DESC(zc_recv_min_nfrags, "minimum # of fragments to enable ZC recv");
 
-static unsigned int conns_per_peer = 1;
-module_param(conns_per_peer, uint, 0444);
+static unsigned int conns_per_peer = DEFAULT_CONNS_PER_PEER;
+module_param(conns_per_peer, uint, 0644);
 MODULE_PARM_DESC(conns_per_peer, "number of connections per peer");
 
 #if SOCKNAL_VERSION_DEBUG
@@ -150,9 +152,13 @@
 #endif
 
 struct ksock_tunables ksocknal_tunables;
+static struct lnet_ioctl_config_socklnd_tunables default_tunables;
 
 int ksocknal_tunables_init(void)
 {
+	default_tunables.lnd_version = CURRENT_LND_VERSION;
+	default_tunables.lnd_conns_per_peer = conns_per_peer;
+
 	/* initialize ksocknal_tunables structure */
 	ksocknal_tunables.ksnd_timeout = &sock_timeout;
 	ksocknal_tunables.ksnd_nscheds = &nscheds;
@@ -201,4 +207,47 @@ int ksocknal_tunables_init(void)
 		*ksocknal_tunables.ksnd_zc_min_payload = (16 << 20) + 1;
 
 	return 0;
-};
+}
+
+void ksocknal_tunables_setup(struct lnet_ni *ni)
+{
+	struct lnet_ioctl_config_socklnd_tunables *tunables;
+	struct lnet_ioctl_config_lnd_cmn_tunables *net_tunables;
+
+	/* If no tunables specified, setup default tunables */
+	if (!ni->ni_lnd_tunables_set)
+		memcpy(&ni->ni_lnd_tunables.lnd_tun_u.lnd_sock,
+		       &default_tunables, sizeof(*tunables));
+
+	tunables = &ni->ni_lnd_tunables.lnd_tun_u.lnd_sock;
+
+	/* Current API version */
+	tunables->lnd_version = CURRENT_LND_VERSION;
+
+	net_tunables = &ni->ni_net->net_tunables;
+
+	if (net_tunables->lct_peer_timeout == -1)
+		net_tunables->lct_peer_timeout =
+			*ksocknal_tunables.ksnd_peertimeout;
+
+	if (net_tunables->lct_max_tx_credits == -1)
+		net_tunables->lct_max_tx_credits =
+			*ksocknal_tunables.ksnd_credits;
+
+	if (net_tunables->lct_peer_tx_credits == -1)
+		net_tunables->lct_peer_tx_credits =
+			*ksocknal_tunables.ksnd_peertxcredits;
+
+	if (net_tunables->lct_peer_tx_credits >
+	    net_tunables->lct_max_tx_credits)
+		net_tunables->lct_peer_tx_credits =
+			net_tunables->lct_max_tx_credits;
+
+	if (net_tunables->lct_peer_rtr_credits == -1)
+		net_tunables->lct_peer_rtr_credits =
+			*ksocknal_tunables.ksnd_peerrtrcredits;
+
+	if (!tunables->lnd_conns_per_peer)
+		tunables->lnd_conns_per_peer = (conns_per_peer) ?
+			conns_per_peer : DEFAULT_CONNS_PER_PEER;
+}
diff --git a/net/lnet/lnet/api-ni.c b/net/lnet/lnet/api-ni.c
index 370c1d6..bb5fb56 100644
--- a/net/lnet/lnet/api-ni.c
+++ b/net/lnet/lnet/api-ni.c
@@ -3657,6 +3657,30 @@ u32 lnet_get_dlc_seq_locked(void)
 	lnet_net_unlock(LNET_LOCK_EX);
 }
 
+static void
+lnet_ni_set_conns_per_peer(lnet_nid_t nid, int value, bool all)
+{
+	struct lnet_net *net;
+	struct lnet_ni *ni;
+
+	lnet_net_lock(LNET_LOCK_EX);
+	list_for_each_entry(net, &the_lnet.ln_nets, net_list) {
+		list_for_each_entry(ni, &net->net_ni_list, ni_netlist) {
+			if (ni->ni_nid != nid && !all)
+				continue;
+			if (LNET_NETTYP(net->net_id) == SOCKLND)
+				ni->ni_lnd_tunables.lnd_tun_u.lnd_sock.lnd_conns_per_peer = value;
+			else if (LNET_NETTYP(net->net_id) == O2IBLND)
+				ni->ni_lnd_tunables.lnd_tun_u.lnd_o2ib.lnd_conns_per_peer = value;
+			if (!all) {
+				lnet_net_unlock(LNET_LOCK_EX);
+				return;
+			}
+		}
+	}
+	lnet_net_unlock(LNET_LOCK_EX);
+}
+
 static int
 lnet_get_local_ni_hstats(struct lnet_ioctl_local_ni_hstats *stats)
 {
@@ -4086,6 +4110,25 @@ u32 lnet_get_dlc_seq_locked(void)
 		return 0;
 	}
 
+	case IOC_LIBCFS_SET_CONNS_PER_PEER: {
+		struct lnet_ioctl_reset_conns_per_peer_cfg *cfg = arg;
+		int value;
+
+		if (cfg->rcpp_hdr.ioc_len < sizeof(*cfg))
+			return -EINVAL;
+		if (cfg->rcpp_value < 0)
+			value = 1;
+		else
+			value = cfg->rcpp_value;
+		CDEBUG(D_NET,
+		       "Setting conns_per_peer to %d for %s. all = %d\n",
+		       value, libcfs_nid2str(cfg->rcpp_nid), cfg->rcpp_all);
+		mutex_lock(&the_lnet.ln_api_mutex);
+		lnet_ni_set_conns_per_peer(cfg->rcpp_nid, value, cfg->rcpp_all);
+		mutex_unlock(&the_lnet.ln_api_mutex);
+		return 0;
+	}
+
 	case IOC_LIBCFS_NOTIFY_ROUTER: {
 		time64_t deadline = ktime_get_real_seconds() - data->ioc_u64[0];
 
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
