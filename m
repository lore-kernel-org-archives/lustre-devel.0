Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id C8135C77B76
	for <lustre-devel@archiver.kernel.org>; Mon, 17 Apr 2023 13:56:13 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4Q0T2634bYz21H2;
	Mon, 17 Apr 2023 06:49:50 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4Q0Szb2MjNz1yD0
 for <lustre-devel@lists.lustre.org>; Mon, 17 Apr 2023 06:47:39 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 717FA1006C90;
 Mon, 17 Apr 2023 09:47:24 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 702B9375; Mon, 17 Apr 2023 09:47:24 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon, 17 Apr 2023 09:47:04 -0400
Message-Id: <1681739243-29375-9-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1681739243-29375-1-git-send-email-jsimmons@infradead.org>
References: <1681739243-29375-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 08/27] lnet: handle multi-rail setups
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

For multi-rail setups we can push more than one interface at a
time to setup the local NIs but our netlink code ignored all but
one interface. Refactor both lnet_genl_parse_local_ni() and
lnet_net_cmd() to setup all the passed in interfaces. Also remove
setting ni to NULL in the NI deletion case which causes an oops
when we have more than one interface.

WC-bug-id: https://jira.whamcloud.com/browse/LU-9680
Lustre-commit: 6fab1fe4a5c5615d4 ("LU-9680 lnet: handle multi-rail setups")
Signed-off-by: James Simmons <jsimmons@infradead.org>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/50026
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: Chris Horn <chris.horn@hpe.com>
Reviewed-by: Cyril Bordage <cbordage@whamcloud.com>
Reviewed-by: Frank Sehr <fsehr@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
---
 fs/lustre/obdclass/kernelcomm.c |   7 +-
 net/lnet/lnet/api-ni.c          | 183 ++++++++++++++++++++++------------------
 net/lnet/selftest/conctl.c      |   7 +-
 3 files changed, 111 insertions(+), 86 deletions(-)

diff --git a/fs/lustre/obdclass/kernelcomm.c b/fs/lustre/obdclass/kernelcomm.c
index 5682d4e..0cf3c44 100644
--- a/fs/lustre/obdclass/kernelcomm.c
+++ b/fs/lustre/obdclass/kernelcomm.c
@@ -116,7 +116,12 @@ static int lustre_device_list_start(struct netlink_callback *cb)
 		struct nlattr *dev;
 		int rem;
 
-		nla_for_each_attr(dev, params, msg_len, rem) {
+		if (!(nla_type(params) & LN_SCALAR_ATTR_LIST)) {
+			NL_SET_ERR_MSG(extack, "no configuration");
+			goto report_err;
+		}
+
+		nla_for_each_nested(dev, params, rem) {
 			struct nlattr *prop;
 			int rem2;
 
diff --git a/net/lnet/lnet/api-ni.c b/net/lnet/lnet/api-ni.c
index 9095d4e..8b0ab53 100644
--- a/net/lnet/lnet/api-ni.c
+++ b/net/lnet/lnet/api-ni.c
@@ -4695,7 +4695,12 @@ static int lnet_net_show_start(struct netlink_callback *cb)
 		return 0;
 
 	params = genlmsg_data(gnlh);
-	nla_for_each_attr(top, params, msg_len, rem) {
+	if (!(nla_type(params) & LN_SCALAR_ATTR_LIST)) {
+		NL_SET_ERR_MSG(extack, "invalid configuration");
+		return -EINVAL;
+	}
+
+	nla_for_each_nested(top, params, rem) {
 		struct nlattr *net;
 		int rem2;
 
@@ -4703,7 +4708,7 @@ static int lnet_net_show_start(struct netlink_callback *cb)
 			char filter[LNET_NIDSTR_SIZE];
 
 			if (nla_type(net) != LN_SCALAR_ATTR_VALUE ||
-			    nla_strcmp(net, "name") != 0)
+			    nla_strcmp(net, "net type") != 0)
 				continue;
 
 			net = nla_next(net, &rem2);
@@ -4931,12 +4936,21 @@ static int lnet_genl_parse_lnd_tunables(struct nlattr *settings,
 static int
 lnet_genl_parse_local_ni(struct nlattr *entry, struct genl_info *info,
 			 int net_id, struct lnet_ioctl_config_ni *conf,
-			 struct lnet_ioctl_config_lnd_tunables *tun,
 			 bool *ni_list)
 {
+	bool create = info->nlhdr->nlmsg_flags & NLM_F_CREATE;
+	struct lnet_ioctl_config_lnd_tunables tun;
 	struct nlattr *settings;
 	int rem3, rc = 0;
 
+	memset(&tun, 0, sizeof(tun));
+	/* Use LND defaults */
+	tun.lt_cmn.lct_peer_timeout = -1;
+	tun.lt_cmn.lct_peer_tx_credits = -1;
+	tun.lt_cmn.lct_peer_rtr_credits = -1;
+	tun.lt_cmn.lct_max_tx_credits = -1;
+	conf->lic_ncpts = 0;
+
 	nla_for_each_nested(settings, entry, rem3) {
 		if (nla_type(settings) != LN_SCALAR_ATTR_VALUE)
 			continue;
@@ -4983,7 +4997,7 @@ static int lnet_genl_parse_lnd_tunables(struct nlattr *settings,
 				goto out;
 			}
 
-			rc = lnet_genl_parse_tunables(settings, tun);
+			rc = lnet_genl_parse_tunables(settings, &tun);
 			if (rc < 0) {
 				GENL_SET_ERR_MSG(info,
 						 "failed to parse tunables");
@@ -5010,7 +5024,7 @@ static int lnet_genl_parse_lnd_tunables(struct nlattr *settings,
 			}
 
 			rc = lnet_genl_parse_lnd_tunables(settings,
-							  &tun->lt_tun, lnd);
+							  &tun.lt_tun, lnd);
 			if (rc < 0) {
 				GENL_SET_ERR_MSG(info,
 						 "failed to parse lnd tunables");
@@ -5052,6 +5066,73 @@ static int lnet_genl_parse_lnd_tunables(struct nlattr *settings,
 			}
 		}
 	}
+
+	if (!create) {
+		struct lnet_net *net;
+		struct lnet_ni *ni;
+
+		rc = -ENODEV;
+		if (!strlen(conf->lic_ni_intf)) {
+			GENL_SET_ERR_MSG(info,
+					 "interface is missing");
+			goto out;
+		}
+
+		lnet_net_lock(LNET_LOCK_EX);
+		net = lnet_get_net_locked(net_id);
+		if (!net) {
+			GENL_SET_ERR_MSG(info,
+					 "LNet net doesn't exist");
+			lnet_net_unlock(LNET_LOCK_EX);
+			goto out;
+		}
+
+		list_for_each_entry(ni, &net->net_ni_list,
+				    ni_netlist) {
+			if (!ni->ni_interface ||
+			    strcmp(ni->ni_interface,
+				   conf->lic_ni_intf) != 0)
+				continue;
+
+			lnet_net_unlock(LNET_LOCK_EX);
+			rc = lnet_dyn_del_ni(&ni->ni_nid);
+			if (rc < 0) {
+				GENL_SET_ERR_MSG(info,
+						 "cannot del LNet NI");
+				goto out;
+			}
+			break;
+		}
+
+		if (rc < 0) { /* will be -ENODEV */
+			GENL_SET_ERR_MSG(info,
+					 "interface invalid for deleting LNet NI");
+			lnet_net_unlock(LNET_LOCK_EX);
+		}
+	} else {
+		if (!strlen(conf->lic_ni_intf)) {
+			GENL_SET_ERR_MSG(info,
+					 "interface is missing");
+			goto out;
+		}
+
+		rc = lnet_dyn_add_ni(conf, net_id, &tun);
+		switch (rc) {
+		case -ENOENT:
+			GENL_SET_ERR_MSG(info,
+					 "cannot parse net");
+			break;
+		case -ERANGE:
+			GENL_SET_ERR_MSG(info,
+					 "invalid CPT set");
+			break;
+		default:
+			GENL_SET_ERR_MSG(info,
+					 "cannot add LNet NI");
+		case 0:
+			break;
+		}
+	}
 out:
 	return rc;
 }
@@ -5070,7 +5151,12 @@ static int lnet_net_cmd(struct sk_buff *skb, struct genl_info *info)
 		return -ENOMSG;
 	}
 
-	nla_for_each_attr(attr, params, msg_len, rem) {
+	if (!(nla_type(params) & LN_SCALAR_ATTR_LIST)) {
+		GENL_SET_ERR_MSG(info, "invalid configuration");
+		return -EINVAL;
+	}
+
+	nla_for_each_nested(attr, params, rem) {
 		struct lnet_ioctl_config_ni conf;
 		u32 net_id = LNET_NET_ANY;
 		struct nlattr *entry;
@@ -5149,85 +5235,13 @@ static int lnet_net_cmd(struct sk_buff *skb, struct genl_info *info)
 				break;
 			}
 			case LN_SCALAR_ATTR_LIST: {
-				bool create = info->nlhdr->nlmsg_flags &
-					      NLM_F_CREATE;
-				struct lnet_ioctl_config_lnd_tunables tun;
-
-				memset(&tun, 0, sizeof(tun));
-				/* Use LND defaults */
-				tun.lt_cmn.lct_peer_timeout = -1;
-				tun.lt_cmn.lct_peer_tx_credits = -1;
-				tun.lt_cmn.lct_peer_rtr_credits = -1;
-				tun.lt_cmn.lct_max_tx_credits = -1;
-				conf.lic_ncpts = 0;
-
-				rc = lnet_genl_parse_local_ni(entry, info,
-							      net_id, &conf,
-							      &tun, &ni_list);
-				if (rc < 0)
-					goto out;
+				struct nlattr *interface;
+				int rem3;
 
-				if (!create) {
-					struct lnet_net *net;
-					struct lnet_ni *ni;
-
-					rc = -ENODEV;
-					if (!strlen(conf.lic_ni_intf)) {
-						GENL_SET_ERR_MSG(info,
-								 "interface is missing");
-						goto out;
-					}
-
-					lnet_net_lock(LNET_LOCK_EX);
-					net = lnet_get_net_locked(net_id);
-					if (!net) {
-						GENL_SET_ERR_MSG(info,
-								 "LNet net doesn't exist");
-						lnet_net_unlock(LNET_LOCK_EX);
-						goto out;
-					}
-					list_for_each_entry(ni, &net->net_ni_list,
-							    ni_netlist) {
-						if (!ni->ni_interface ||
-						    strncmp(ni->ni_interface,
-							    conf.lic_ni_intf,
-							    strlen(conf.lic_ni_intf)) != 0) {
-							ni = NULL;
-							continue;
-						}
-
-						lnet_net_unlock(LNET_LOCK_EX);
-						rc = lnet_dyn_del_ni(&ni->ni_nid);
-						if (rc < 0) {
-							GENL_SET_ERR_MSG(info,
-									 "cannot del LNet NI");
-							goto out;
-						}
-						break;
-					}
-
-					if (rc < 0) { /* will be -ENODEV */
-						GENL_SET_ERR_MSG(info,
-								 "interface invalid for deleting LNet NI");
-						lnet_net_unlock(LNET_LOCK_EX);
-					}
-				} else {
-					rc = lnet_dyn_add_ni(&conf, net_id, &tun);
-					switch (rc) {
-					case -ENOENT:
-						GENL_SET_ERR_MSG(info,
-								 "cannot parse net");
-						break;
-					case -ERANGE:
-						GENL_SET_ERR_MSG(info,
-								 "invalid CPT set");
-					fallthrough;
-					default:
-						GENL_SET_ERR_MSG(info,
-								 "cannot add LNet NI");
-					case 0:
-						break;
-					}
+				nla_for_each_nested(interface, entry, rem3) {
+					rc = lnet_genl_parse_local_ni(interface, info,
+								      net_id, &conf,
+								      &ni_list);
 					if (rc < 0)
 						goto out;
 				}
@@ -5593,6 +5607,7 @@ static int lnet_ping_show_dump(struct sk_buff *msg,
 static const struct genl_ops lnet_genl_ops[] = {
 	{
 		.cmd		= LNET_CMD_NETS,
+		.flags		= GENL_ADMIN_PERM,
 		.start		= lnet_net_show_start,
 		.dumpit		= lnet_net_show_dump,
 		.done		= lnet_net_show_done,
diff --git a/net/lnet/selftest/conctl.c b/net/lnet/selftest/conctl.c
index ea590b2..a7ec0d5 100644
--- a/net/lnet/selftest/conctl.c
+++ b/net/lnet/selftest/conctl.c
@@ -1024,7 +1024,12 @@ static int lst_groups_show_start(struct netlink_callback *cb)
 	}
 	glist->lggl_verbose = true;
 
-	nla_for_each_attr(groups, params, msg_len, rem) {
+	if (!(nla_type(params) & LN_SCALAR_ATTR_LIST)) {
+		NL_SET_ERR_MSG(extack, "no configuration");
+		goto report_err;
+	}
+
+	nla_for_each_nested(groups, params, rem) {
 		struct lst_genl_group_prop *prop = NULL;
 		struct nlattr *group;
 		int rem2;
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
