Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 1F4B4C0218F
	for <lustre-devel@archiver.kernel.org>; Sun,  2 Feb 2025 21:00:30 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4YmMFl6fRrz20t5;
	Sun, 02 Feb 2025 12:50:03 -0800 (PST)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4YmMCy4j98z20x0
 for <lustre-devel@lists.lustre.org>; Sun, 02 Feb 2025 12:48:30 -0800 (PST)
Received: from star2.ccs.ornl.gov (ltm-e204-208.ccs.ornl.gov [160.91.203.12])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id EC1C118236E;
 Sun,  2 Feb 2025 15:46:41 -0500 (EST)
Received: by star2.ccs.ornl.gov (Postfix, from userid 2004)
 id E9215106BE15; Sun,  2 Feb 2025 15:46:41 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun,  2 Feb 2025 15:46:21 -0500
Message-ID: <20250202204633.1148872-22-jsimmons@infradead.org>
X-Mailer: git-send-email 2.43.5
In-Reply-To: <20250202204633.1148872-1-jsimmons@infradead.org>
References: <20250202204633.1148872-1-jsimmons@infradead.org>
MIME-Version: 1.0
Subject: [lustre-devel] [PATCH 21/33] lnet: collect data about routes by
 using Netlink
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
Cc: Chris Horn <chris.horn@hpe.com>, Cyril Bordage <cbordage@whamcloud.com>,
 Serguei Smirnov <ssmirnov@whamcloud.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

Migrate the LNet route API to use the Netlink API for
the case of collecting data about routes. This change also
allows large NID support for IPv6. Support for adding and
deleting routes with Netlink will be done in an follow on
patch.

WC-bug-id: https://jira.whamcloud.com/browse/LU-9680
Lustre-commit: 4ccac8297d0a60027 ("LU-9680 lnet: collect data about routes by using Netlink")
Signed-off-by: James Simmons <jsimmons@infradead.org>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/49839
WC-bug-id: https://jira.whamcloud.com/brose/LU-10391
Lustre-commit: 7d9643b5b9373b1f8 ("LU-10391 lnet: use GFP_ATOMIC for alloc under spinlock")
Signed-off-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/53597
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: Chris Horn <chris.horn@hpe.com>
Reviewed-by: Cyril Bordage <cbordage@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
---
 include/linux/lnet/lib-types.h     |  40 +++
 include/uapi/linux/lnet/lnet-dlc.h |   7 +-
 net/lnet/lnet/api-ni.c             | 396 +++++++++++++++++++++++++++++
 3 files changed, 440 insertions(+), 3 deletions(-)

diff --git a/include/linux/lnet/lib-types.h b/include/linux/lnet/lib-types.h
index bc9f0020f93a..0de7654e3a67 100644
--- a/include/linux/lnet/lib-types.h
+++ b/include/linux/lnet/lib-types.h
@@ -557,6 +557,46 @@ enum lnet_net_local_ni_tunables_attr {
 
 #define LNET_NET_LOCAL_NI_TUNABLES_ATTR_MAX (__LNET_NET_LOCAL_NI_TUNABLES_ATTR_MAX_PLUS_ONE - 1)
 
+/** enum lnet_route_attrs		      - LNet route netlink
+ *						attributes that describe
+ *						LNet routes
+ *
+ * @LNET_ROUTE_ATTR_UNSPEC:			unspecified attribute to
+ *						catch errors
+ *
+ * @LNET_ROUTE_ATTR_HDR:			grouping for LNet route data
+ *						(NLA_NUL_STRING)
+ * @LNET_ROUTE_ATTR_NET:			LNet remote network reached
+ *						by the route (NLA_STRING)
+ * @LNET_ROUTE_ATTR_GATEWAY:			gateway for the route
+ *						(NLA_STRING)
+ * @LNET_ROUTE_ATTR_HOP:			route hop count (NLA_S32)
+ *
+ * @LNET_ROUTE_ATTR_PRIORITY:			rank of this network path
+ *						(NLA_U32)
+ * @LNET_ROUTE_ATTR_HEALTH_SENSITIVITY:		rate of health value change
+ *						for the route (NLA_U32)
+ * @LNET_ROUTE_ATTR_STATE:			state of route (NLA_STRING)
+ *
+ * @LNET_ROUTE_ATTR_TYPE:			Report if we support multi-hop
+ *						(NLA_STRING)
+ */
+enum lnet_route_attrs {
+	LNET_ROUTE_ATTR_UNSPEC = 0,
+
+	LNET_ROUTE_ATTR_HDR,
+	LNET_ROUTE_ATTR_NET,
+	LNET_ROUTE_ATTR_GATEWAY,
+	LNET_ROUTE_ATTR_HOP,
+	LNET_ROUTE_ATTR_PRIORITY,
+	LNET_ROUTE_ATTR_HEALTH_SENSITIVITY,
+	LNET_ROUTE_ATTR_STATE,
+	LNET_ROUTE_ATTR_TYPE,
+	__LNET_ROUTE_ATTR_MAX_PLUS_ONE,
+};
+
+#define LNET_ROUTE_ATTR_MAX (__LNET_ROUTE_ATTR_MAX_PLUS_ONE - 1)
+
 /** LNet netlink ping API */
 
 /** enum lnet_ping_atts				      - LNet ping netlink properties
diff --git a/include/uapi/linux/lnet/lnet-dlc.h b/include/uapi/linux/lnet/lnet-dlc.h
index fc1d40ce8756..d7592f3fd1f8 100644
--- a/include/uapi/linux/lnet/lnet-dlc.h
+++ b/include/uapi/linux/lnet/lnet-dlc.h
@@ -54,10 +54,11 @@
 
 /* enum lnet_commands	      - Supported core LNet Netlink commands
  *
- *  @LNET_CMD_UNSPEC:		unspecified command to catch errors
+ * @LNET_CMD_UNSPEC:		unspecified command to catch errors
  *
- *  @LNET_CMD_NETS:		command to manage the LNet networks
- *  @LNET_CMD_PING:		command to send pings to LNet connections
+ * @LNET_CMD_NETS:		command to manage the LNet networks
+ * @LNET_CMD_ROUTES:		command to manage LNet routes
+ * @LNET_CMD_PING:		command to send pings to LNet connections
  */
 enum lnet_commands {
 	LNET_CMD_UNSPEC		= 0,
diff --git a/net/lnet/lnet/api-ni.c b/net/lnet/lnet/api-ni.c
index fa42cfd99aa7..d3d51acdf2ad 100644
--- a/net/lnet/lnet/api-ni.c
+++ b/net/lnet/lnet/api-ni.c
@@ -5322,6 +5322,395 @@ static int lnet_net_cmd(struct sk_buff *skb, struct genl_info *info)
 	return rc;
 }
 
+/** LNet route handling */
+
+/* We can't use struct lnet_ioctl_config_data since it lacks
+ * support for large NIDS
+ */
+struct lnet_route_properties {
+	struct lnet_nid		lrp_gateway;
+	u32			lrp_net;
+	s32			lrp_hop;
+	u32			lrp_flags;
+	u32			lrp_priority;
+	u32			lrp_sensitivity;
+};
+
+struct lnet_genl_route_list {
+	unsigned int				lgrl_index;
+	unsigned int				lgrl_count;
+	GENRADIX(struct lnet_route_properties)	lgrl_list;
+};
+
+static inline struct lnet_genl_route_list *
+lnet_route_dump_ctx(struct netlink_callback *cb)
+{
+	return (struct lnet_genl_route_list *)cb->args[0];
+}
+
+static int lnet_route_show_done(struct netlink_callback *cb)
+{
+	struct lnet_genl_route_list *rlist = lnet_route_dump_ctx(cb);
+
+	if (rlist) {
+		genradix_free(&rlist->lgrl_list);
+		kfree(rlist);
+	}
+	cb->args[0] = 0;
+
+	return 0;
+}
+
+int lnet_scan_route(struct lnet_genl_route_list *rlist,
+		    struct lnet_route_properties *settings)
+{
+	struct lnet_remotenet *rnet;
+	struct list_head *rn_list;
+	struct lnet_route *route;
+	int cpt, i, rc = 0;
+
+	cpt = lnet_net_lock_current();
+
+	for (i = 0; i < LNET_REMOTE_NETS_HASH_SIZE; i++) {
+		rn_list = &the_lnet.ln_remote_nets_hash[i];
+		list_for_each_entry(rnet, rn_list, lrn_list) {
+			if (settings->lrp_net != LNET_NET_ANY &&
+			    settings->lrp_net != rnet->lrn_net)
+				continue;
+
+			list_for_each_entry(route, &rnet->lrn_routes,
+					    lr_list) {
+				struct lnet_route_properties *prop;
+
+				if (!LNET_NID_IS_ANY(&settings->lrp_gateway) &&
+				    !nid_same(&settings->lrp_gateway,
+					      &route->lr_nid)) {
+					continue;
+				}
+
+				if (settings->lrp_hop != -1 &&
+				    settings->lrp_hop != route->lr_hops)
+					continue;
+
+				if (settings->lrp_priority != -1 &&
+				    settings->lrp_priority != route->lr_priority)
+					continue;
+
+				if (settings->lrp_sensitivity != -1 &&
+				    settings->lrp_sensitivity !=
+				    route->lr_gateway->lp_health_sensitivity)
+					continue;
+
+				prop = genradix_ptr_alloc(&rlist->lgrl_list,
+							  rlist->lgrl_count++,
+							  GFP_ATOMIC);
+				if (!prop) {
+					rc = -ENOMEM;
+					goto failed_alloc;
+				}
+
+				prop->lrp_net = rnet->lrn_net;
+				prop->lrp_gateway = route->lr_nid;
+				prop->lrp_hop = route->lr_hops;
+				prop->lrp_priority = route->lr_priority;
+				prop->lrp_sensitivity =
+					route->lr_gateway->lp_health_sensitivity;
+				if (lnet_is_route_alive(route))
+					prop->lrp_flags |= LNET_RT_ALIVE;
+				else
+					prop->lrp_flags &= ~LNET_RT_ALIVE;
+				if (route->lr_single_hop)
+					prop->lrp_flags &= ~LNET_RT_MULTI_HOP;
+				else
+					prop->lrp_flags |= LNET_RT_MULTI_HOP;
+			}
+		}
+	}
+
+failed_alloc:
+	lnet_net_unlock(cpt);
+	return rc;
+}
+
+/* LNet route ->start() handler for GET requests */
+static int lnet_route_show_start(struct netlink_callback *cb)
+{
+	struct genlmsghdr *gnlh = nlmsg_data(cb->nlh);
+	struct netlink_ext_ack *extack = cb->extack;
+	struct lnet_genl_route_list *rlist;
+	int msg_len = genlmsg_len(gnlh);
+	int rc = 0;
+
+	if (the_lnet.ln_refcount == 0 ||
+	    the_lnet.ln_state != LNET_STATE_RUNNING) {
+		NL_SET_ERR_MSG(extack, "Network is down");
+		return -ENETDOWN;
+	}
+
+	rlist = kzalloc(sizeof(*rlist), GFP_KERNEL);
+	if (!rlist) {
+		NL_SET_ERR_MSG(extack, "No memory for route list");
+		return -ENOMEM;
+	}
+
+	genradix_init(&rlist->lgrl_list);
+	rlist->lgrl_count = 0;
+	rlist->lgrl_index = 0;
+	cb->args[0] = (long)rlist;
+
+	mutex_lock(&the_lnet.ln_api_mutex);
+	if (!msg_len) {
+		struct lnet_route_properties tmp = {
+			.lrp_gateway		= LNET_ANY_NID,
+			.lrp_net		= LNET_NET_ANY,
+			.lrp_hop		= -1,
+			.lrp_priority		= -1,
+			.lrp_sensitivity	= -1,
+		};
+
+		rc = lnet_scan_route(rlist, &tmp);
+		if (rc < 0) {
+			NL_SET_ERR_MSG(extack,
+				       "failed to allocate router data");
+			goto report_err;
+		}
+	} else {
+		struct nlattr *params = genlmsg_data(gnlh);
+		struct nlattr *attr;
+		int rem;
+
+		nla_for_each_nested(attr, params, rem) {
+			struct lnet_route_properties tmp = {
+				.lrp_gateway		= LNET_ANY_NID,
+				.lrp_net		= LNET_NET_ANY,
+				.lrp_hop		= -1,
+				.lrp_priority		= -1,
+				.lrp_sensitivity	= -1,
+			};
+			struct nlattr *route;
+			int rem2;
+
+			if (nla_type(attr) != LN_SCALAR_ATTR_LIST)
+				continue;
+
+			nla_for_each_nested(route, attr, rem2) {
+				if (nla_type(route) != LN_SCALAR_ATTR_VALUE)
+					continue;
+
+				if (nla_strcmp(route, "net") == 0) {
+					char nw[LNET_NIDSTR_SIZE];
+
+					route = nla_next(route, &rem2);
+					if (nla_type(route) !=
+					    LN_SCALAR_ATTR_VALUE) {
+						NL_SET_ERR_MSG(extack,
+							       "invalid net param");
+						rc = -EINVAL;
+						goto report_err;
+					}
+
+					rc = nla_strlcpy(nw, route, sizeof(nw));
+					if (rc < 0) {
+						NL_SET_ERR_MSG(extack,
+							       "failed to get route param");
+						goto report_err;
+					}
+					rc = 0;
+					tmp.lrp_net = libcfs_str2net(strim(nw));
+				} else if (nla_strcmp(route, "gateway") == 0) {
+					char gw[LNET_NIDSTR_SIZE];
+
+					route = nla_next(route, &rem2);
+					if (nla_type(route) !=
+					    LN_SCALAR_ATTR_VALUE) {
+						NL_SET_ERR_MSG(extack,
+							       "invalid gateway param");
+						rc = -EINVAL;
+						goto report_err;
+					}
+
+					rc = nla_strlcpy(gw, route, sizeof(gw));
+					if (rc < 0) {
+						NL_SET_ERR_MSG(extack,
+							       "failed to get route param");
+						goto report_err;
+					}
+					rc = 0;
+					libcfs_strnid(&tmp.lrp_gateway, strim(gw));
+				} else if (nla_strcmp(route, "hop") == 0) {
+					route = nla_next(route, &rem2);
+					if (nla_type(route) !=
+					    LN_SCALAR_ATTR_INT_VALUE) {
+						NL_SET_ERR_MSG(extack,
+							       "invalid hop param");
+						rc = -EINVAL;
+						goto report_err;
+					}
+
+					tmp.lrp_hop = nla_get_s64(route);
+					if (tmp.lrp_hop != -1)
+						clamp_t(s32, tmp.lrp_hop, 1, 127);
+				} else if (nla_strcmp(route, "priority") == 0) {
+					route = nla_next(route, &rem2);
+					if (nla_type(route) !=
+					    LN_SCALAR_ATTR_INT_VALUE) {
+						NL_SET_ERR_MSG(extack,
+							       "invalid priority param");
+						rc = -EINVAL;
+						goto report_err;
+					}
+
+					tmp.lrp_priority = nla_get_s64(route);
+				}
+			}
+
+			rc = lnet_scan_route(rlist, &tmp);
+			if (rc < 0) {
+				NL_SET_ERR_MSG(extack,
+					       "failed to allocate router data");
+				goto report_err;
+			}
+		}
+	}
+report_err:
+	mutex_unlock(&the_lnet.ln_api_mutex);
+
+	if (rc < 0)
+		lnet_route_show_done(cb);
+
+	return rc;
+}
+
+static const struct ln_key_list route_props_list = {
+	.lkl_maxattr			= LNET_ROUTE_ATTR_MAX,
+	.lkl_list			= {
+		[LNET_ROUTE_ATTR_HDR]			= {
+			.lkp_value			= "route",
+			.lkp_key_format			= LNKF_SEQUENCE | LNKF_MAPPING,
+			.lkp_data_type			= NLA_NUL_STRING,
+		},
+		[LNET_ROUTE_ATTR_NET]			= {
+			.lkp_value			= "net",
+			.lkp_data_type			= NLA_STRING
+		},
+		[LNET_ROUTE_ATTR_GATEWAY]		= {
+			.lkp_value			= "gateway",
+			.lkp_data_type			= NLA_STRING
+		},
+		[LNET_ROUTE_ATTR_HOP]			= {
+			.lkp_value			= "hop",
+			.lkp_data_type			= NLA_S32
+		},
+		[LNET_ROUTE_ATTR_PRIORITY]		= {
+			.lkp_value			= "priority",
+			.lkp_data_type			= NLA_U32
+		},
+		[LNET_ROUTE_ATTR_HEALTH_SENSITIVITY]	= {
+			.lkp_value			= "health_sensitivity",
+			.lkp_data_type			= NLA_U32
+		},
+		[LNET_ROUTE_ATTR_STATE]	= {
+			.lkp_value			= "state",
+			.lkp_data_type			= NLA_STRING,
+		},
+		[LNET_ROUTE_ATTR_TYPE]	= {
+			.lkp_value			= "type",
+			.lkp_data_type			= NLA_STRING,
+		},
+	},
+};
+
+static int lnet_route_show_dump(struct sk_buff *msg,
+				struct netlink_callback *cb)
+{
+	struct lnet_genl_route_list *rlist = lnet_route_dump_ctx(cb);
+	struct genlmsghdr *gnlh = nlmsg_data(cb->nlh);
+	struct netlink_ext_ack *extack = cb->extack;
+	int portid = NETLINK_CB(cb->skb).portid;
+	int seq = cb->nlh->nlmsg_seq;
+	int idx = rlist->lgrl_index;
+	int rc = 0;
+
+	if (!rlist->lgrl_count) {
+		NL_SET_ERR_MSG(extack, "No routes found");
+		rc = -ENOENT;
+		goto send_error;
+	}
+
+	if (!idx) {
+		const struct ln_key_list *all[] = {
+			&route_props_list, NULL
+		};
+
+		rc = lnet_genl_send_scalar_list(msg, portid, seq,
+						&lnet_family,
+						NLM_F_CREATE | NLM_F_MULTI,
+						LNET_CMD_ROUTES, all);
+		if (rc < 0) {
+			NL_SET_ERR_MSG(extack, "failed to send key table");
+			goto send_error;
+		}
+	}
+
+	/* If not routes found send an empty message and not an error */
+	if (!rlist->lgrl_count) {
+		void *hdr;
+
+		hdr = genlmsg_put(msg, portid, seq, &lnet_family,
+				  NLM_F_MULTI, LNET_CMD_ROUTES);
+		if (!hdr) {
+			NL_SET_ERR_MSG(extack, "failed to send values");
+			genlmsg_cancel(msg, hdr);
+			rc = -EMSGSIZE;
+			goto send_error;
+		}
+		genlmsg_end(msg, hdr);
+
+		goto send_error;
+	}
+
+	while (idx < rlist->lgrl_count) {
+		struct lnet_route_properties *prop;
+		void *hdr;
+
+		prop = genradix_ptr(&rlist->lgrl_list, idx++);
+
+		hdr = genlmsg_put(msg, portid, seq, &lnet_family,
+				  NLM_F_MULTI, LNET_CMD_ROUTES);
+		if (!hdr) {
+			NL_SET_ERR_MSG(extack, "failed to send values");
+			genlmsg_cancel(msg, hdr);
+			rc = -EMSGSIZE;
+			goto send_error;
+		}
+
+		if (idx == 1)
+			nla_put_string(msg, LNET_ROUTE_ATTR_HDR, "");
+
+		nla_put_string(msg, LNET_ROUTE_ATTR_NET,
+			       libcfs_net2str(prop->lrp_net));
+		nla_put_string(msg, LNET_ROUTE_ATTR_GATEWAY,
+			       libcfs_nidstr(&prop->lrp_gateway));
+		if (gnlh->version) {
+			nla_put_s32(msg, LNET_ROUTE_ATTR_HOP, prop->lrp_hop);
+			nla_put_u32(msg, LNET_ROUTE_ATTR_PRIORITY, prop->lrp_priority);
+			nla_put_u32(msg, LNET_ROUTE_ATTR_HEALTH_SENSITIVITY,
+				    prop->lrp_sensitivity);
+
+			nla_put_string(msg, LNET_ROUTE_ATTR_STATE,
+				       prop->lrp_flags & LNET_RT_ALIVE ?
+				       "up" : "down");
+			nla_put_string(msg, LNET_ROUTE_ATTR_TYPE,
+				       prop->lrp_flags & LNET_RT_MULTI_HOP ?
+				       "multi-hop" : "single-hop");
+		}
+		genlmsg_end(msg, hdr);
+	}
+	rlist->lgrl_index = idx;
+send_error:
+	return rc;
+};
+
 static inline struct lnet_genl_ping_list *
 lnet_ping_dump_ctx(struct netlink_callback *cb)
 {
@@ -5654,6 +6043,7 @@ static int lnet_ping_show_dump(struct sk_buff *msg,
 static const struct genl_multicast_group lnet_mcast_grps[] = {
 	{ .name	=	"ip2net",	},
 	{ .name =	"net",		},
+	{ .name	=	"route",	},
 	{ .name	=	"ping",		},
 };
 
@@ -5666,6 +6056,12 @@ static const struct genl_ops lnet_genl_ops[] = {
 		.done		= lnet_net_show_done,
 		.doit		= lnet_net_cmd,
 	},
+	{
+		.cmd		= LNET_CMD_ROUTES,
+		.start		= lnet_route_show_start,
+		.dumpit		= lnet_route_show_dump,
+		.done		= lnet_route_show_done,
+	},
 	{
 		.cmd		= LNET_CMD_PING,
 		.start		= lnet_ping_show_start,
-- 
2.39.3

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
