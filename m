Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id CD556C05027
	for <lustre-devel@archiver.kernel.org>; Mon, 23 Jan 2023 23:41:18 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4P15VD2Cv3z21BR;
	Mon, 23 Jan 2023 15:12:36 -0800 (PST)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4P15V60Kf7z21BX
 for <lustre-devel@lists.lustre.org>; Mon, 23 Jan 2023 15:12:29 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id B817AE22;
 Mon, 23 Jan 2023 18:00:58 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id B6DEC5898C; Mon, 23 Jan 2023 18:00:58 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon, 23 Jan 2023 18:00:53 -0500
Message-Id: <1674514855-15399-41-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1674514855-15399-1-git-send-email-jsimmons@infradead.org>
References: <1674514855-15399-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 40/42] lnet: validate data sent from user
 land properly
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

Testing with improper setting from user land exposed some bugs in
the kernel's code handling of these cases. For tunables sent from
user land we need to do proper range checking. An improper cast
in the new Netlink tunables code preventing setting the default
LND tunable settings. Also silently ignore trying to set LND
tunables when its not supported. We shouldn't stop NI setup in
this case. Lastly setup the NI tunables to -1 when user land
doesn't provide any input. This tells the LND driver to use it
default values for the tunables. Resolve a double free when
setting up a NI with a non-existing interface. Another fix is for
net locking in lnet_net_cmd().

For lnetctl fix the YAML handling when only conns_per_peer is
requested. I only tested conns_per_peer and NI tunables changes
together before which missed the mentioned case.

Fixes: fafd24988 ("lnet: use Netlink to support old and new NI APIs.")
WC-bug-id: https://jira.whamcloud.com/browse/LU-16460
Lustre-commit: 17a3b5688435ab5f7 ("LU-16460 lnet: validate data sent from user land properly")
Signed-off-by: James Simmons <jsimmons@infradead.org>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/49588
Reviewed-by: Chris Horn <chris.horn@hpe.com>
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
---
 net/lnet/klnds/o2iblnd/o2iblnd.c |  6 +++-
 net/lnet/klnds/socklnd/socklnd.c |  6 +++-
 net/lnet/lnet/api-ni.c           | 47 +++++++++++++++++++-------------
 3 files changed, 38 insertions(+), 21 deletions(-)

diff --git a/net/lnet/klnds/o2iblnd/o2iblnd.c b/net/lnet/klnds/o2iblnd/o2iblnd.c
index cbb3445c7c25..67259569b392 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd.c
+++ b/net/lnet/klnds/o2iblnd/o2iblnd.c
@@ -533,6 +533,7 @@ static int
 kiblnd_nl_set(int cmd, struct nlattr *attr, int type, void *data)
 {
 	struct lnet_lnd_tunables *tunables = data;
+	s64 num;
 
 	if (cmd != LNET_CMD_NETS)
 		return -EOPNOTSUPP;
@@ -563,7 +564,10 @@ kiblnd_nl_set(int cmd, struct nlattr *attr, int type, void *data)
 		tunables->lnd_tun_u.lnd_o2ib.lnd_ntx = nla_get_s64(attr);
 		break;
 	case LNET_NET_O2IBLND_TUNABLES_ATTR_CONNS_PER_PEER:
-		tunables->lnd_tun_u.lnd_o2ib.lnd_conns_per_peer = nla_get_s64(attr);
+		num = nla_get_s64(attr);
+		clamp_t(s64, num, 1, 127);
+		tunables->lnd_tun_u.lnd_o2ib.lnd_conns_per_peer = num;
+		fallthrough;
 	default:
 		break;
 	}
diff --git a/net/lnet/klnds/socklnd/socklnd.c b/net/lnet/klnds/socklnd/socklnd.c
index 0a4fb966f498..cc2b7f46c53b 100644
--- a/net/lnet/klnds/socklnd/socklnd.c
+++ b/net/lnet/klnds/socklnd/socklnd.c
@@ -39,6 +39,7 @@
 
 #include <linux/ethtool.h>
 #include <linux/inetdevice.h>
+#include <linux/kernel.h>
 #include <linux/sunrpc/addr.h>
 #include <net/addrconf.h>
 #include "socklnd.h"
@@ -854,6 +855,7 @@ static int
 ksocknal_nl_set(int cmd, struct nlattr *attr, int type, void *data)
 {
 	struct lnet_lnd_tunables *tunables = data;
+	s64 num;
 
 	if (cmd != LNET_CMD_NETS)
 		return -EOPNOTSUPP;
@@ -862,7 +864,9 @@ ksocknal_nl_set(int cmd, struct nlattr *attr, int type, void *data)
 	    nla_type(attr) != LN_SCALAR_ATTR_INT_VALUE)
 		return -EINVAL;
 
-	tunables->lnd_tun_u.lnd_sock.lnd_conns_per_peer = nla_get_s64(attr);
+	num = nla_get_s64(attr);
+	clamp_t(s64, num, 1, 127);
+	tunables->lnd_tun_u.lnd_sock.lnd_conns_per_peer = num;
 
 	return 0;
 }
diff --git a/net/lnet/lnet/api-ni.c b/net/lnet/lnet/api-ni.c
index 2c7f5211bbee..a4fb95f26788 100644
--- a/net/lnet/lnet/api-ni.c
+++ b/net/lnet/lnet/api-ni.c
@@ -3626,7 +3626,8 @@ int lnet_dyn_add_ni(struct lnet_ioctl_config_ni *conf, u32 net_id,
 
 	mutex_unlock(&the_lnet.ln_api_mutex);
 
-	if (rc)
+	/* If NI already exist delete this new unused copy */
+	if (rc == -EEXIST)
 		lnet_ni_free(ni);
 
 	return rc;
@@ -4868,16 +4869,20 @@ static int lnet_genl_parse_tunables(struct nlattr *settings,
 		num = nla_get_s64(param);
 		switch (type) {
 		case LNET_NET_LOCAL_NI_TUNABLES_ATTR_PEER_TIMEOUT:
-			tun->lt_cmn.lct_peer_timeout = num;
+			if (num >= 0)
+				tun->lt_cmn.lct_peer_timeout = num;
 			break;
 		case LNET_NET_LOCAL_NI_TUNABLES_ATTR_PEER_CREDITS:
-			tun->lt_cmn.lct_peer_tx_credits = num;
+			if (num > 0)
+				tun->lt_cmn.lct_peer_tx_credits = num;
 			break;
 		case LNET_NET_LOCAL_NI_TUNABLES_ATTR_PEER_BUFFER_CREDITS:
-			tun->lt_cmn.lct_peer_rtr_credits = num;
+			if (num > 0)
+				tun->lt_cmn.lct_peer_rtr_credits = num;
 			break;
 		case LNET_NET_LOCAL_NI_TUNABLES_ATTR_CREDITS:
-			tun->lt_cmn.lct_max_tx_credits = num;
+			if (num > 0)
+				tun->lt_cmn.lct_max_tx_credits = num;
 			break;
 		default:
 			rc = -EINVAL;
@@ -4887,25 +4892,21 @@ static int lnet_genl_parse_tunables(struct nlattr *settings,
 	return rc;
 }
 
-static int
-lnet_genl_parse_lnd_tunables(struct nlattr *settings,
-			     struct lnet_ioctl_config_lnd_tunables *tun,
-			     const struct lnet_lnd *lnd)
+static int lnet_genl_parse_lnd_tunables(struct nlattr *settings,
+					struct lnet_lnd_tunables *tun,
+					const struct lnet_lnd *lnd)
 {
 	const struct ln_key_list *list = lnd->lnd_keys;
 	struct nlattr *param;
 	int rem, rc = 0;
 	int i = 1;
 
-	if (!list)
+	/* silently ignore these setting if the LND driver doesn't
+	 * support any LND tunables
+	 */
+	if (!list || !lnd->lnd_nl_set || !list->lkl_maxattr)
 		return 0;
 
-	if (!lnd->lnd_nl_set)
-		return -EOPNOTSUPP;
-
-	if (!list->lkl_maxattr)
-		return -ERANGE;
-
 	nla_for_each_nested(param, settings, rem) {
 		if (nla_type(param) != LN_SCALAR_ATTR_VALUE)
 			continue;
@@ -5007,7 +5008,7 @@ lnet_genl_parse_local_ni(struct nlattr *entry, struct genl_info *info,
 			}
 
 			rc = lnet_genl_parse_lnd_tunables(settings,
-							  tun, lnd);
+							  &tun->lt_tun, lnd);
 			if (rc < 0) {
 				GENL_SET_ERR_MSG(info,
 						 "failed to parse lnd tunables");
@@ -5151,7 +5152,11 @@ static int lnet_net_cmd(struct sk_buff *skb, struct genl_info *info)
 				struct lnet_ioctl_config_lnd_tunables tun;
 
 				memset(&tun, 0, sizeof(tun));
+				/* Use LND defaults */
 				tun.lt_cmn.lct_peer_timeout = -1;
+				tun.lt_cmn.lct_peer_tx_credits = -1;
+				tun.lt_cmn.lct_peer_rtr_credits = -1;
+				tun.lt_cmn.lct_max_tx_credits = -1;
 				conf.lic_ncpts = 0;
 
 				rc = lnet_genl_parse_local_ni(entry, info,
@@ -5176,6 +5181,7 @@ static int lnet_net_cmd(struct sk_buff *skb, struct genl_info *info)
 					if (!net) {
 						GENL_SET_ERR_MSG(info,
 								 "LNet net doesn't exist");
+						lnet_net_unlock(LNET_LOCK_EX);
 						goto out;
 					}
 					list_for_each_entry(ni, &net->net_ni_list,
@@ -5190,7 +5196,6 @@ static int lnet_net_cmd(struct sk_buff *skb, struct genl_info *info)
 
 						lnet_net_unlock(LNET_LOCK_EX);
 						rc = lnet_dyn_del_ni(&ni->ni_nid);
-						lnet_net_lock(LNET_LOCK_EX);
 						if (rc < 0) {
 							GENL_SET_ERR_MSG(info,
 									 "cannot del LNet NI");
@@ -5199,7 +5204,11 @@ static int lnet_net_cmd(struct sk_buff *skb, struct genl_info *info)
 						break;
 					}
 
-					lnet_net_unlock(LNET_LOCK_EX);
+					if (rc < 0) { /* will be -ENODEV */
+						GENL_SET_ERR_MSG(info,
+								 "interface invalid for deleting LNet NI");
+						lnet_net_unlock(LNET_LOCK_EX);
+					}
 				} else {
 					rc = lnet_dyn_add_ni(&conf, net_id, &tun);
 					switch (rc) {
-- 
2.27.0

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
