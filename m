Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id A1F13C05027
	for <lustre-devel@archiver.kernel.org>; Mon, 23 Jan 2023 23:36:26 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4P15SH0bgBz22YM;
	Mon, 23 Jan 2023 15:10:55 -0800 (PST)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4P15S14gvyz22XB
 for <lustre-devel@lists.lustre.org>; Mon, 23 Jan 2023 15:10:41 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id ACF6FE1F;
 Mon, 23 Jan 2023 18:00:58 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id A971558994; Mon, 23 Jan 2023 18:00:58 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon, 23 Jan 2023 18:00:50 -0500
Message-Id: <1674514855-15399-38-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1674514855-15399-1-git-send-email-jsimmons@infradead.org>
References: <1674514855-15399-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 37/42] lnet: selftest: migrate LNet selftest
 group handling to Netlink
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

Replace the LSTIO_GROUP_LIST and LSTIO_GROUP_INFO ioctls with a Netlink
backend. Make this transitition transparent to the user. Be aware this
newer version of lnet_selftest.ko doesn't support older versions of the
lst tool. While the old interface allows only setting one group up at
a time the Netlink interface can be used to setup many groups at one
time. Currently we don't change the interface to handle larger NIDs but
this new interface will allow us to use the new NID format in a follow
on patch.

WC-bug-id: https://jira.whamcloud.com/browse/LU-8915
Lustre-commit: a6c2d277d09ce9b33 ("LU-8915 lnet: migrate LNet selftest group handling to Netlink")
Signed-off-by: James Simmons <jsimmons@infradead.org>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/49314
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: Chris Horn <chris.horn@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
---
 include/uapi/linux/lnet/lnetst.h |   2 +
 net/lnet/selftest/conctl.c       | 421 +++++++++++++++++++++++++------
 net/lnet/selftest/console.c      |  27 +-
 net/lnet/selftest/console.h      |   4 +-
 net/lnet/selftest/selftest.h     |  60 ++++-
 5 files changed, 405 insertions(+), 109 deletions(-)

diff --git a/include/uapi/linux/lnet/lnetst.h b/include/uapi/linux/lnet/lnetst.h
index d04496dd0701..2d5c40250125 100644
--- a/include/uapi/linux/lnet/lnetst.h
+++ b/include/uapi/linux/lnet/lnetst.h
@@ -583,11 +583,13 @@ struct sfw_counters {
  *
  * @LNET_SELFTEST_CMD_UNSPEC:		unspecified command to catch errors
  * @LNET_SELFTEST_CMD_SESSIONS:		command to manage sessions
+ * @LNET_SELFTEST_CMD_GROUPS:		command to manage selftest groups
  */
 enum lnet_selftest_commands {
 	LNET_SELFTEST_CMD_UNSPEC	= 0,
 
 	LNET_SELFTEST_CMD_SESSIONS	= 1,
+	LNET_SELFTEST_CMD_GROUPS	= 2,
 
 	__LNET_SELFTEST_CMD_MAX_PLUS_ONE,
 };
diff --git a/net/lnet/selftest/conctl.c b/net/lnet/selftest/conctl.c
index aa118851d183..ea590b26779b 100644
--- a/net/lnet/selftest/conctl.c
+++ b/net/lnet/selftest/conctl.c
@@ -35,7 +35,7 @@
  *
  * Author: Liang Zhen <liangzhen@clusterfs.com>
  */
-
+#include <linux/generic-radix-tree.h>
 #include <linux/lnet/lib-lnet.h>
 #include "console.h"
 
@@ -247,78 +247,6 @@ lst_nodes_add_ioctl(struct lstio_group_nodes_args *args)
 	return rc;
 }
 
-static int
-lst_group_list_ioctl(struct lstio_group_list_args *args)
-{
-	if (args->lstio_grp_key != console_session.ses_key)
-		return -EACCES;
-
-	if (args->lstio_grp_idx < 0 ||
-	    !args->lstio_grp_namep ||
-	    args->lstio_grp_nmlen <= 0 ||
-	    args->lstio_grp_nmlen > LST_NAME_SIZE)
-		return -EINVAL;
-
-	return lstcon_group_list(args->lstio_grp_idx,
-				 args->lstio_grp_nmlen,
-				 args->lstio_grp_namep);
-}
-
-static int
-lst_group_info_ioctl(struct lstio_group_info_args *args)
-{
-	char name[LST_NAME_SIZE + 1];
-	int ndent;
-	int index;
-	int rc;
-
-	if (args->lstio_grp_key != console_session.ses_key)
-		return -EACCES;
-
-	if (!args->lstio_grp_namep ||
-	    args->lstio_grp_nmlen <= 0 ||
-	    args->lstio_grp_nmlen > LST_NAME_SIZE)
-		return -EINVAL;
-
-	if (!args->lstio_grp_entp &&	/* output: group entry */
-	    !args->lstio_grp_dentsp)	/* output: node entry */
-		return -EINVAL;
-
-	if (args->lstio_grp_dentsp) {		/* have node entry */
-		if (!args->lstio_grp_idxp ||	/* node index */
-		    !args->lstio_grp_ndentp)	/* # of node entry */
-			return -EINVAL;
-
-		if (copy_from_user(&ndent, args->lstio_grp_ndentp,
-				   sizeof(ndent)) ||
-		    copy_from_user(&index, args->lstio_grp_idxp,
-				   sizeof(index)))
-			return -EFAULT;
-
-		if (ndent <= 0 || index < 0)
-			return -EINVAL;
-	}
-
-	if (copy_from_user(name, args->lstio_grp_namep,
-			   args->lstio_grp_nmlen))
-		return -EFAULT;
-
-	name[args->lstio_grp_nmlen] = 0;
-
-	rc = lstcon_group_info(name, args->lstio_grp_entp,
-			       &index, &ndent, args->lstio_grp_dentsp);
-
-	if (rc)
-		return rc;
-
-	if (args->lstio_grp_dentsp &&
-	    (copy_to_user(args->lstio_grp_idxp, &index, sizeof(index)) ||
-	     copy_to_user(args->lstio_grp_ndentp, &ndent, sizeof(ndent))))
-		return -EFAULT;
-
-	return 0;
-}
-
 static int
 lst_batch_add_ioctl(struct lstio_batch_add_args *args)
 {
@@ -690,10 +618,9 @@ lstcon_ioctl_entry(struct notifier_block *nb,
 		rc = lst_nodes_add_ioctl((struct lstio_group_nodes_args *)buf);
 		break;
 	case LSTIO_GROUP_LIST:
-		rc = lst_group_list_ioctl((struct lstio_group_list_args *)buf);
-		break;
+		fallthrough;
 	case LSTIO_GROUP_INFO:
-		rc = lst_group_info_ioctl((struct lstio_group_info_args *)buf);
+		rc = -EOPNOTSUPP;
 		break;
 	case LSTIO_BATCH_ADD:
 		rc = lst_batch_add_ioctl((struct lstio_batch_add_args *)buf);
@@ -982,8 +909,340 @@ static int lst_sessions_cmd(struct sk_buff *skb, struct genl_info *info)
 	return rc;
 }
 
+static char *lst_node_state2str(int state)
+{
+	if (state == LST_NODE_ACTIVE)
+		return "Active";
+	if (state == LST_NODE_BUSY)
+		return "Busy";
+	if (state == LST_NODE_DOWN)
+		return "Down";
+
+	return "Unknown";
+}
+
+int lst_node_str2state(char *str)
+{
+	int state = 0;
+
+	if (strcasecmp(str, "Active") == 0)
+		state = LST_NODE_ACTIVE;
+	else if (strcasecmp(str, "Busy") == 0)
+		state = LST_NODE_BUSY;
+	else if (strcasecmp(str, "Down") == 0)
+		state = LST_NODE_DOWN;
+	else if (strcasecmp(str, "Unknown") == 0)
+		state = LST_NODE_UNKNOWN;
+	else if (strcasecmp(str, "Invalid") == 0)
+		state = LST_NODE_UNKNOWN | LST_NODE_DOWN | LST_NODE_BUSY;
+	return state;
+}
+
+struct lst_genl_group_prop {
+	struct lstcon_group	*lggp_grp;
+	int			lggp_state_filter;
+};
+
+struct lst_genl_group_list {
+	GENRADIX(struct lst_genl_group_prop)	lggl_groups;
+	unsigned int				lggl_count;
+	unsigned int				lggl_index;
+	bool					lggl_verbose;
+};
+
+static inline struct lst_genl_group_list *
+lst_group_dump_ctx(struct netlink_callback *cb)
+{
+	return (struct lst_genl_group_list *)cb->args[0];
+}
+
+static int lst_groups_show_done(struct netlink_callback *cb)
+{
+	struct lst_genl_group_list *glist = lst_group_dump_ctx(cb);
+
+	if (glist) {
+		int i;
+
+		for (i = 0; i < glist->lggl_count; i++) {
+			struct lst_genl_group_prop *prop;
+
+			prop = genradix_ptr(&glist->lggl_groups, i);
+			if (!prop || !prop->lggp_grp)
+				continue;
+			lstcon_group_decref(prop->lggp_grp);
+		}
+		genradix_free(&glist->lggl_groups);
+		kfree(glist);
+	}
+	cb->args[0] = 0;
+
+	return 0;
+}
+
+/* LNet selftest groups ->start() handler for GET requests */
+static int lst_groups_show_start(struct netlink_callback *cb)
+{
+	struct genlmsghdr *gnlh = nlmsg_data(cb->nlh);
+	struct netlink_ext_ack *extack = cb->extack;
+	struct nlattr *params = genlmsg_data(gnlh);
+	struct lst_genl_group_list *glist;
+	int msg_len = genlmsg_len(gnlh);
+	struct lstcon_group *grp;
+	struct nlattr *groups;
+	int rem, rc = 0;
+
+	glist = kzalloc(sizeof(*glist), GFP_KERNEL);
+	if (!glist)
+		return -ENOMEM;
+
+	genradix_init(&glist->lggl_groups);
+	cb->args[0] = (long)glist;
+
+	if (!msg_len) {
+		list_for_each_entry(grp, &console_session.ses_grp_list,
+				    grp_link) {
+			struct lst_genl_group_prop *prop;
+
+			prop = genradix_ptr_alloc(&glist->lggl_groups,
+						  glist->lggl_count++,
+						  GFP_ATOMIC);
+			if (!prop) {
+				NL_SET_ERR_MSG(extack,
+					       "failed to allocate group info");
+				rc = -ENOMEM;
+				goto report_err;
+			}
+			lstcon_group_addref(grp);  /* +1 ref for caller */
+			prop->lggp_grp = grp;
+		}
+
+		if (!glist->lggl_count) {
+			NL_SET_ERR_MSG(extack, "No groups found");
+			rc = -ENOENT;
+		}
+		goto report_err;
+	}
+	glist->lggl_verbose = true;
+
+	nla_for_each_attr(groups, params, msg_len, rem) {
+		struct lst_genl_group_prop *prop = NULL;
+		struct nlattr *group;
+		int rem2;
+
+		if (nla_type(groups) != LN_SCALAR_ATTR_LIST)
+			continue;
+
+		nla_for_each_nested(group, groups, rem2) {
+			if (nla_type(group) == LN_SCALAR_ATTR_VALUE) {
+				char name[LST_NAME_SIZE];
+
+				prop = genradix_ptr_alloc(&glist->lggl_groups,
+							  glist->lggl_count++,
+							  GFP_ATOMIC);
+				if (!prop) {
+					NL_SET_ERR_MSG(extack,
+						       "failed to allocate group info");
+					rc = -ENOMEM;
+					goto report_err;
+				}
+
+				rc = nla_strlcpy(name, group, sizeof(name));
+				if (rc < 0) {
+					NL_SET_ERR_MSG(extack,
+						       "failed to get name");
+					goto report_err;
+				}
+				rc = lstcon_group_find(name, &prop->lggp_grp);
+				if (rc < 0) {
+					/* don't stop reporting groups if one
+					 * doesn't exist.
+					 */
+					CWARN("LNet selftest group %s does not exit\n",
+					      name);
+					rc = 0;
+				}
+			} else if (nla_type(group) == LN_SCALAR_ATTR_LIST) {
+				struct nlattr *attr;
+				int rem3;
+
+				if (!prop) {
+					NL_SET_ERR_MSG(extack,
+						       "missing group information");
+					rc = -EINVAL;
+					goto report_err;
+				}
+
+				nla_for_each_nested(attr, group, rem3) {
+					char tmp[16];
+
+					if (nla_type(attr) != LN_SCALAR_ATTR_VALUE ||
+					    nla_strcmp(attr, "status") != 0)
+						continue;
+
+					attr = nla_next(attr, &rem3);
+					if (nla_type(attr) !=
+					    LN_SCALAR_ATTR_VALUE) {
+						NL_SET_ERR_MSG(extack,
+							       "invalid config param");
+						rc = -EINVAL;
+						goto report_err;
+					}
+
+					rc = nla_strlcpy(tmp, attr, sizeof(tmp));
+					if (rc < 0) {
+						NL_SET_ERR_MSG(extack,
+							       "failed to get prop attr");
+						goto report_err;
+					}
+					rc = 0;
+					prop->lggp_state_filter |=
+						lst_node_str2state(tmp);
+				}
+			}
+		}
+	}
+	if (!glist->lggl_count) {
+		NL_SET_ERR_MSG(extack, "No groups found");
+		rc = -ENOENT;
+	}
+report_err:
+	if (rc < 0)
+		lst_groups_show_done(cb);
+
+	return rc;
+}
+
+static const struct ln_key_list lst_group_keys = {
+	.lkl_maxattr			= LNET_SELFTEST_GROUP_MAX,
+	.lkl_list			= {
+		[LNET_SELFTEST_GROUP_ATTR_HDR]	= {
+			.lkp_value		= "groups",
+			.lkp_key_format		= LNKF_SEQUENCE,
+			.lkp_data_type		= NLA_NUL_STRING,
+		},
+		[LNET_SELFTEST_GROUP_ATTR_NAME]	= {
+			.lkp_data_type		= NLA_STRING,
+		},
+		[LNET_SELFTEST_GROUP_ATTR_NODELIST] = {
+			.lkp_key_format		= LNKF_MAPPING | LNKF_SEQUENCE,
+			.lkp_data_type		= NLA_NESTED,
+		},
+	},
+};
+
+static const struct ln_key_list lst_group_nodelist_keys = {
+	.lkl_maxattr			= LNET_SELFTEST_GROUP_NODELIST_PROP_MAX,
+	.lkl_list			= {
+		[LNET_SELFTEST_GROUP_NODELIST_PROP_ATTR_NID] = {
+			.lkp_value		= "nid",
+			.lkp_data_type		= NLA_STRING,
+		},
+		[LNET_SELFTEST_GROUP_NODELIST_PROP_ATTR_STATUS] = {
+			.lkp_value		= "status",
+			.lkp_data_type		= NLA_STRING,
+		},
+	},
+};
+
+static int lst_groups_show_dump(struct sk_buff *msg,
+				struct netlink_callback *cb)
+{
+	struct lst_genl_group_list *glist = lst_group_dump_ctx(cb);
+	struct netlink_ext_ack *extack = cb->extack;
+	int portid = NETLINK_CB(cb->skb).portid;
+	int seq = cb->nlh->nlmsg_seq;
+	int idx = 0, rc = 0;
+
+	if (!glist->lggl_index) {
+		const struct ln_key_list *all[] = {
+			&lst_group_keys, &lst_group_nodelist_keys, NULL
+		};
+
+		rc = lnet_genl_send_scalar_list(msg, portid, seq, &lst_family,
+						NLM_F_CREATE | NLM_F_MULTI,
+						LNET_SELFTEST_CMD_GROUPS, all);
+		if (rc < 0) {
+			NL_SET_ERR_MSG(extack, "failed to send key table");
+			goto send_error;
+		}
+	}
+
+	for (idx = glist->lggl_index; idx < glist->lggl_count; idx++) {
+		struct lst_genl_group_prop *group;
+		struct lstcon_ndlink *ndl;
+		struct nlattr *nodelist;
+		unsigned int count = 1;
+		void *hdr;
+
+		group = genradix_ptr(&glist->lggl_groups, idx);
+		if (!group)
+			continue;
+
+		hdr = genlmsg_put(msg, portid, seq, &lst_family,
+				  NLM_F_MULTI, LNET_SELFTEST_CMD_GROUPS);
+		if (!hdr) {
+			NL_SET_ERR_MSG(extack, "failed to send values");
+			rc = -EMSGSIZE;
+			goto send_error;
+		}
+
+		if (idx == 0)
+			nla_put_string(msg, LNET_SELFTEST_GROUP_ATTR_HDR, "");
+
+		nla_put_string(msg, LNET_SELFTEST_GROUP_ATTR_NAME,
+			       group->lggp_grp->grp_name);
+
+		if (!glist->lggl_verbose)
+			goto skip_details;
+
+		nodelist = nla_nest_start(msg,
+					  LNET_SELFTEST_GROUP_ATTR_NODELIST);
+		list_for_each_entry(ndl, &group->lggp_grp->grp_ndl_list,
+				    ndl_link) {
+			struct nlattr *node = nla_nest_start(msg, count);
+			char *ndstate;
+
+			if (group->lggp_state_filter &&
+			    !(group->lggp_state_filter & ndl->ndl_node->nd_state))
+				continue;
+
+			nla_put_string(msg,
+				       LNET_SELFTEST_GROUP_NODELIST_PROP_ATTR_NID,
+				       libcfs_id2str(ndl->ndl_node->nd_id));
+
+			ndstate = lst_node_state2str(ndl->ndl_node->nd_state);
+			nla_put_string(msg,
+				       LNET_SELFTEST_GROUP_NODELIST_PROP_ATTR_STATUS,
+				       ndstate);
+			nla_nest_end(msg, node);
+		}
+		nla_nest_end(msg, nodelist);
+skip_details:
+		genlmsg_end(msg, hdr);
+	}
+	glist->lggl_index = idx;
+send_error:
+	return rc;
+}
+
+#ifndef HAVE_NETLINK_CALLBACK_START
+static int lst_old_groups_show_dump(struct sk_buff *msg,
+				    struct netlink_callback *cb)
+{
+	if (!cb->args[0]) {
+		int rc = lst_groups_show_start(cb);
+
+		if (rc < 0)
+			return rc;
+	}
+
+	return lst_groups_show_dump(msg, cb);
+}
+#endif
+
 static const struct genl_multicast_group lst_mcast_grps[] = {
 	{ .name = "sessions",		},
+	{ .name	= "groups",		},
 };
 
 static const struct genl_ops lst_genl_ops[] = {
@@ -992,6 +1251,16 @@ static const struct genl_ops lst_genl_ops[] = {
 		.dumpit		= lst_sessions_show_dump,
 		.doit		= lst_sessions_cmd,
 	},
+	{
+		.cmd		= LNET_SELFTEST_CMD_GROUPS,
+#ifdef HAVE_NETLINK_CALLBACK_START
+		.start		= lst_groups_show_start,
+		.dumpit		= lst_groups_show_dump,
+#else
+		.dumpit		= lst_old_groups_show_dump,
+#endif
+		.done		= lst_groups_show_done,
+	},
 };
 
 static struct genl_family lst_family = {
diff --git a/net/lnet/selftest/console.c b/net/lnet/selftest/console.c
index 1ed619114b2b..b6c98820d0bf 100644
--- a/net/lnet/selftest/console.c
+++ b/net/lnet/selftest/console.c
@@ -224,8 +224,7 @@ lstcon_group_alloc(char *name, struct lstcon_group **grpp)
 	return 0;
 }
 
-static void
-lstcon_group_addref(struct lstcon_group *grp)
+void lstcon_group_addref(struct lstcon_group *grp)
 {
 	grp->grp_ref++;
 }
@@ -245,8 +244,7 @@ lstcon_group_drain(struct lstcon_group *grp, int keep)
 	}
 }
 
-static void
-lstcon_group_decref(struct lstcon_group *grp)
+void lstcon_group_decref(struct lstcon_group *grp)
 {
 	int i;
 
@@ -264,8 +262,7 @@ lstcon_group_decref(struct lstcon_group *grp)
 	kfree(grp);
 }
 
-static int
-lstcon_group_find(const char *name, struct lstcon_group **grpp)
+int lstcon_group_find(const char *name, struct lstcon_group **grpp)
 {
 	struct lstcon_group *grp;
 
@@ -717,24 +714,6 @@ lstcon_group_refresh(char *name, struct list_head __user *result_up)
 	return rc;
 }
 
-int
-lstcon_group_list(int index, int len, char __user *name_up)
-{
-	struct lstcon_group *grp;
-
-	LASSERT(index >= 0);
-	LASSERT(name_up);
-
-	list_for_each_entry(grp, &console_session.ses_grp_list, grp_link) {
-		if (!index--) {
-			return copy_to_user(name_up, grp->grp_name, len) ?
-					    -EFAULT : 0;
-		}
-	}
-
-	return -ENOENT;
-}
-
 static int
 lstcon_nodes_getent(struct list_head *head, int *index_p,
 		    int *count_p, struct lstcon_node_ent __user *dents_up)
diff --git a/net/lnet/selftest/console.h b/net/lnet/selftest/console.h
index dd416dc82f35..40f33e97d7f3 100644
--- a/net/lnet/selftest/console.h
+++ b/net/lnet/selftest/console.h
@@ -206,6 +206,9 @@ int lstcon_nodes_debug(int timeout, int nnd,
 		       struct list_head __user *result_up);
 int lstcon_group_add(char *name);
 int lstcon_group_del(char *name);
+void lstcon_group_addref(struct lstcon_group *grp);
+void lstcon_group_decref(struct lstcon_group *grp);
+int lstcon_group_find(const char *name, struct lstcon_group **grpp);
 int lstcon_group_clean(char *name, int args);
 int lstcon_group_refresh(char *name, struct list_head __user *result_up);
 int lstcon_nodes_add(char *name, int nnd, struct lnet_process_id __user *nds_up,
@@ -216,7 +219,6 @@ int lstcon_nodes_remove(char *name, int nnd,
 int lstcon_group_info(char *name, struct lstcon_ndlist_ent __user *gent_up,
 		      int *index_p, int *ndent_p,
 		      struct lstcon_node_ent __user *ndents_up);
-int lstcon_group_list(int idx, int len, char __user *name_up);
 int lstcon_batch_add(char *name);
 int lstcon_batch_run(char *name, int timeout,
 		     struct list_head __user *result_up);
diff --git a/net/lnet/selftest/selftest.h b/net/lnet/selftest/selftest.h
index 5bffe7394dc2..5d0b47fe7e49 100644
--- a/net/lnet/selftest/selftest.h
+++ b/net/lnet/selftest/selftest.h
@@ -52,19 +52,19 @@
 /* enum lnet_selftest_session_attrs   - LNet selftest session Netlink
  *					attributes
  *
- * @LNET_SELFTEST_SESSION_UNSPEC:	unspecified attribute to catch errors
- * @LNET_SELFTEST_SESSION_PAD:		padding for 64-bit attributes, ignore
+ *  @LNET_SELFTEST_SESSION_UNSPEC:	unspecified attribute to catch errors
+ *  @LNET_SELFTEST_SESSION_PAD:		padding for 64-bit attributes, ignore
  *
- * @LENT_SELFTEST_SESSION_HDR:		Netlink group this data is for
+ *  @LENT_SELFTEST_SESSION_HDR:		Netlink group this data is for
  *					(NLA_NUL_STRING)
- * @LNET_SELFTEST_SESSION_NAME:	name of this session (NLA_STRING)
- * @LNET_SELFTEST_SESSION_KEY:		key used to represent the session
+ *  @LNET_SELFTEST_SESSION_NAME:	name of this session (NLA_STRING)
+ *  @LNET_SELFTEST_SESSION_KEY:		key used to represent the session
  *					(NLA_U32)
- * @LNET_SELFTEST_SESSION_TIMESTAMP:	timestamp when the session was created
+ *  @LNET_SELFTEST_SESSION_TIMESTAMP:	timestamp when the session was created
  *					(NLA_S64)
- * @LNET_SELFTEST_SESSION_NID:		NID of the node selftest ran on
+ *  @LNET_SELFTEST_SESSION_NID:		NID of the node selftest ran on
  *					(NLA_STRING)
- * @LNET_SELFTEST_SESSION_NODE_COUNT:	Number of nodes in use (NLA_U16)
+ *  @LNET_SELFTEST_SESSION_NODE_COUNT:	Number of nodes in use (NLA_U16)
  */
 enum lnet_selftest_session_attrs {
 	LNET_SELFTEST_SESSION_UNSPEC = 0,
@@ -82,6 +82,50 @@ enum lnet_selftest_session_attrs {
 
 #define LNET_SELFTEST_SESSION_MAX	(__LNET_SELFTEST_SESSION_MAX_PLUS_ONE - 1)
 
+/* enum lnet_selftest_group_attrs     - LNet selftest group Netlink attributes
+ *
+ *  @LNET_SELFTEST_GROUP_ATTR_UNSPEC:	unspecified attribute to catch errors
+ *
+ *  @LENT_SELFTEST_GROUP_ATTR_HDR:	Netlink group this data is for
+ *					(NLA_NUL_STRING)
+ *  @LNET_SELFTEST_GROUP_ATTR_NAME:	name of this group (NLA_STRING)
+ *  @LNET_SELFTEST_GROUP_ATTR_NODELIST:	List of nodes belonging to the group
+ *					(NLA_NESTED)
+ */
+enum lnet_selftest_group_attrs {
+	LNET_SELFTEST_GROUP_ATTR_UNSPEC = 0,
+
+	LNET_SELFTEST_GROUP_ATTR_HDR,
+	LNET_SELFTEST_GROUP_ATTR_NAME,
+	LNET_SELFTEST_GROUP_ATTR_NODELIST,
+
+	__LNET_SELFTEST_GROUP_MAX_PLUS_ONE,
+};
+
+#define LNET_SELFTEST_GROUP_MAX			(__LNET_SELFTEST_GROUP_MAX_PLUS_ONE - 1)
+
+/* enum lnet_selftest_group_nodelist_prop_attrs	      - Netlink attributes for
+ *							the properties of the
+ *							nodes that belong to a
+ *							group
+ *
+ *  @LNET_SELFTEST_GROUP_NODELIST_PROP_ATTR_UNSPEC:	unspecified attribute
+ *							to catch errors
+ *
+ *  @LNET_SELFTEST_GROUP_NODELIST_PROP_ATTR_NID:	Nodes's NID (NLA_STRING)
+ *  @LNET_SELFTEST_GROUP_NODELIST_PROP_ATTR_STATUS:	Status of the node
+ *							(NLA_STRING)
+ */
+enum lnet_selftest_group_nodelist_prop_attrs {
+	LNET_SELFTEST_GROUP_NODELIST_PROP_ATTR_UNSPEC = 0,
+
+	LNET_SELFTEST_GROUP_NODELIST_PROP_ATTR_NID,
+	LNET_SELFTEST_GROUP_NODELIST_PROP_ATTR_STATUS,
+	__LNET_SELFTEST_GROUP_NODELIST_PROP_MAX_PLUS_ONE,
+};
+
+#define LNET_SELFTEST_GROUP_NODELIST_PROP_MAX	(__LNET_SELFTEST_GROUP_NODELIST_PROP_MAX_PLUS_ONE - 1)
+
 #define SWI_STATE_NEWBORN		0
 #define SWI_STATE_REPLY_SUBMITTED	1
 #define SWI_STATE_REPLY_SENT		2
-- 
2.27.0

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
