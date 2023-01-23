Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 30496C05027
	for <lustre-devel@archiver.kernel.org>; Mon, 23 Jan 2023 23:39:24 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4P15T83Y19z22ZS;
	Mon, 23 Jan 2023 15:11:40 -0800 (PST)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4P15SV4grcz22Yt
 for <lustre-devel@lists.lustre.org>; Mon, 23 Jan 2023 15:11:06 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id B29BFE20;
 Mon, 23 Jan 2023 18:00:58 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id AD8A758991; Mon, 23 Jan 2023 18:00:58 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon, 23 Jan 2023 18:00:51 -0500
Message-Id: <1674514855-15399-39-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1674514855-15399-1-git-send-email-jsimmons@infradead.org>
References: <1674514855-15399-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 38/42] lnet: use Netlink to support LNet ping
 commands
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

Completely replace the old pre-MR ping command ioctl using
Netlink which will also handle large NIDs. We do update
IOC_LIBCFS_PING_PEER, which only supports only small NIDs,
so older tools will keep working.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10003
Lustre-commit: d137e9823ca1e97fc ("LU-10003 lnet: use Netlink to support LNet ping commands")
Signed-off-by: James Simmons <jsimmons@infradead.org>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/49360
Reviewed-by: Cyril Bordage <cbordage@whamcloud.com>
Reviewed-by: Chris Horn <chris.horn@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
---
 include/linux/lnet/lib-lnet.h          |   1 +
 include/linux/lnet/lib-types.h         |  46 +++
 include/uapi/linux/lnet/libcfs_ioctl.h |   2 +-
 include/uapi/linux/lnet/lnet-dlc.h     |   2 +
 net/lnet/lnet/api-ni.c                 | 491 +++++++++++++++++++++----
 net/lnet/lnet/nidstrings.c             |  24 ++
 net/lnet/lnet/peer.c                   |   2 +-
 7 files changed, 495 insertions(+), 73 deletions(-)

diff --git a/include/linux/lnet/lib-lnet.h b/include/linux/lnet/lib-lnet.h
index 25289f5bba39..ed28af6fe8d5 100644
--- a/include/linux/lnet/lib-lnet.h
+++ b/include/linux/lnet/lib-lnet.h
@@ -895,6 +895,7 @@ struct lnet_ping_iter {
 u32 *ping_iter_first(struct lnet_ping_iter *pi, struct lnet_ping_buffer *pbuf,
 		     struct lnet_nid *nid);
 u32 *ping_iter_next(struct lnet_ping_iter *pi, struct lnet_nid *nid);
+int ping_info_count_entries(struct lnet_ping_buffer *pbuf);
 
 static inline int lnet_push_target_resize_needed(void)
 {
diff --git a/include/linux/lnet/lib-types.h b/include/linux/lnet/lib-types.h
index 73d962f18e06..eb54e754ad95 100644
--- a/include/linux/lnet/lib-types.h
+++ b/include/linux/lnet/lib-types.h
@@ -62,6 +62,7 @@ static inline char *libcfs_nidstr(const struct lnet_nid *nid)
 
 int libcfs_strnid(struct lnet_nid *nid, const char *str);
 char *libcfs_idstr(struct lnet_processid *id);
+int libcfs_strid(struct lnet_processid *id, const char *str);
 
 int cfs_match_nid_net(struct lnet_nid *nid, u32 net,
 		      struct list_head *net_num_list,
@@ -567,6 +568,51 @@ enum lnet_net_local_ni_tunables_attr {
 
 #define LNET_NET_LOCAL_NI_TUNABLES_ATTR_MAX (__LNET_NET_LOCAL_NI_TUNABLES_ATTR_MAX_PLUS_ONE - 1)
 
+/** LNet netlink ping API */
+
+/** enum lnet_ping_atts				      - LNet ping netlink properties
+ *							attributes to describe ping format
+ *							These values are used to piece together
+ *							messages for sending and receiving.
+ *
+ * @LNET_PING_ATTR_UNSPEC:				unspecified attribute to catch errors
+ *
+ * @LNET_PING_ATTR_HDR:					grouping for LNet ping data (NLA_NUL_STRING)
+ * @LNET_PING_ATTR_PRIMARY_NID:				Source NID for ping request (NLA_STRING)
+ * @LNET_PING_ATTR_ERRNO:				error code if we fail to ping (NLA_S16)
+ * @LNET_PING_ATTR_MULTIRAIL:				Report if MR is supported (NLA_FLAG)
+ * @LNET_PING_ATTR_PEER_NI_LIST:			List of peer NI's (NLA_NESTED)
+ */
+enum lnet_ping_attr {
+	LNET_PING_ATTR_UNSPEC = 0,
+
+	LNET_PING_ATTR_HDR,
+	LNET_PING_ATTR_PRIMARY_NID,
+	LNET_PING_ATTR_ERRNO,
+	LNET_PING_ATTR_MULTIRAIL,
+	LNET_PING_ATTR_PEER_NI_LIST,
+	__LNET_PING_ATTR_MAX_PLUS_ONE,
+};
+
+#define LNET_PING_ATTR_MAX (__LNET_PING_ATTR_MAX_PLUS_ONE - 1)
+
+/** enium lnet_ping_peer_ni_attr		      - LNet peer ni information reported by
+ *							ping command. A list of these are
+ *							returned with a ping request.
+ *
+ * @LNET_PING_PEER_NI_ATTR_UNSPEC:			unspecified attribute to catch errrors
+ *
+ * @LNET_PING_PEER_NI_ATTR_NID:				NID address of peer NI. (NLA_STRING)
+ */
+enum lnet_ping_peer_ni_attr {
+	LNET_PING_PEER_NI_ATTR_UNSPEC = 0,
+
+	LNET_PING_PEER_NI_ATTR_NID,
+	__LNET_PING_PEER_NI_ATTR_MAX_PLUS_ONE,
+};
+
+#define LNET_PING_PEER_NI_ATTR_MAX (__LNET_PING_PEER_NI_ATTR_MAX_PLUS_ONE - 1)
+
 struct lnet_ni {
 	spinlock_t		ni_lock;
 	/* chain on the lnet_net structure */
diff --git a/include/uapi/linux/lnet/libcfs_ioctl.h b/include/uapi/linux/lnet/libcfs_ioctl.h
index 89ac0758c1b1..e012532fc88a 100644
--- a/include/uapi/linux/lnet/libcfs_ioctl.h
+++ b/include/uapi/linux/lnet/libcfs_ioctl.h
@@ -102,7 +102,7 @@ struct libcfs_ioctl_data {
 #define IOC_LIBCFS_LNET_DIST		_IOWR('e', 58, IOCTL_LIBCFS_TYPE)
 #define IOC_LIBCFS_CONFIGURE		_IOWR('e', 59, IOCTL_LIBCFS_TYPE)
 #define IOC_LIBCFS_TESTPROTOCOMPAT	_IOWR('e', 60, IOCTL_LIBCFS_TYPE)
-#define IOC_LIBCFS_PING			_IOWR('e', 61, IOCTL_LIBCFS_TYPE)
+/* IOC_LIBCFS_PING obsolete in 2.16, was _IOWR('e', 61, IOCTL_LIBCFS_TYPE) */
 #define IOC_LIBCFS_PING_PEER		_IOWR('e', 62, IOCTL_LIBCFS_TYPE)
 #define IOC_LIBCFS_LNETST		_IOWR('e', 63, IOCTL_LIBCFS_TYPE)
 #define IOC_LIBCFS_LNET_FAULT		_IOWR('e', 64, IOCTL_LIBCFS_TYPE)
diff --git a/include/uapi/linux/lnet/lnet-dlc.h b/include/uapi/linux/lnet/lnet-dlc.h
index 58697c134d6a..63578a04a286 100644
--- a/include/uapi/linux/lnet/lnet-dlc.h
+++ b/include/uapi/linux/lnet/lnet-dlc.h
@@ -57,6 +57,7 @@
  *  @LNET_CMD_UNSPEC:		unspecified command to catch errors
  *
  *  @LNET_CMD_NETS:		command to manage the LNet networks
+ *  @LNET_CMD_PING:		command to send pings to LNet connections
  */
 enum lnet_commands {
 	LNET_CMD_UNSPEC		= 0,
@@ -66,6 +67,7 @@ enum lnet_commands {
 	LNET_CMD_PEERS		= 3,
 	LNET_CMD_ROUTES		= 4,
 	LNET_CMD_CONNS		= 5,
+	LNET_CMD_PING		= 6,
 
 	__LNET_CMD_MAX_PLUS_ONE
 };
diff --git a/net/lnet/lnet/api-ni.c b/net/lnet/lnet/api-ni.c
index 18dc3e7cccc6..2c7f5211bbee 100644
--- a/net/lnet/lnet/api-ni.c
+++ b/net/lnet/lnet/api-ni.c
@@ -31,6 +31,9 @@
  */
 
 #define DEBUG_SUBSYSTEM S_LNET
+
+#include <linux/ctype.h>
+#include <linux/generic-radix-tree.h>
 #include <linux/log2.h>
 #include <linux/ktime.h>
 #include <linux/moduleparam.h>
@@ -223,8 +226,23 @@ static void lnet_set_lnd_timeout(void)
  */
 static atomic_t lnet_dlc_seq_no = ATOMIC_INIT(0);
 
-static int lnet_ping(struct lnet_process_id id4, struct lnet_nid *src_nid,
-		     signed long timeout, struct lnet_process_id __user *ids,
+struct lnet_fail_ping {
+	struct lnet_processid		lfp_id;
+	int				lfp_errno;
+};
+
+struct lnet_genl_ping_list {
+	unsigned int			lgpl_index;
+	unsigned int			lgpl_list_count;
+	unsigned int			lgpl_failed_count;
+	signed long			lgpl_timeout;
+	struct lnet_nid			lgpl_src_nid;
+	GENRADIX(struct lnet_fail_ping)	lgpl_failed;
+	GENRADIX(struct lnet_processid)	lgpl_list;
+};
+
+static int lnet_ping(struct lnet_processid *id, struct lnet_nid *src_nid,
+		     signed long timeout, struct lnet_genl_ping_list *plist,
 		     int n_ids);
 
 static int lnet_discover(struct lnet_process_id id, u32 force,
@@ -4367,35 +4385,15 @@ LNetCtl(unsigned int cmd, void *arg)
 	case IOC_LIBCFS_LNET_FAULT:
 		return lnet_fault_ctl(data->ioc_flags, data);
 
-	case IOC_LIBCFS_PING: {
-		struct lnet_process_id id4;
-		signed long timeout;
-
-		id4.nid = data->ioc_nid;
-		id4.pid = data->ioc_u32[0];
-
-		/* If timeout is negative then set default of 3 minutes */
-		if (((s32)data->ioc_u32[1] <= 0) ||
-		    data->ioc_u32[1] > (DEFAULT_PEER_TIMEOUT * MSEC_PER_SEC))
-			timeout = DEFAULT_PEER_TIMEOUT * HZ;
-		else
-			timeout = msecs_to_jiffies(data->ioc_u32[1]);
-
-		rc = lnet_ping(id4, &LNET_ANY_NID, timeout, data->ioc_pbuf1,
-			       data->ioc_plen1 / sizeof(struct lnet_process_id));
-
-		if (rc < 0)
-			return rc;
-
-		data->ioc_count = rc;
-		return 0;
-	}
-
 	case IOC_LIBCFS_PING_PEER: {
 		struct lnet_ioctl_ping_data *ping = arg;
+		struct lnet_process_id __user *ids = ping->ping_buf;
 		struct lnet_nid src_nid = LNET_ANY_NID;
+		struct lnet_genl_ping_list plist;
+		struct lnet_processid id;
 		struct lnet_peer *lp;
 		signed long timeout;
+		int count, i;
 
 		/* Check if the supplied ping data supports source nid
 		 * NB: This check is sufficient if lnet_ioctl_ping_data has
@@ -4416,15 +4414,30 @@ LNetCtl(unsigned int cmd, void *arg)
 		else
 			timeout = msecs_to_jiffies(ping->op_param);
 
-		rc = lnet_ping(ping->ping_id, &src_nid, timeout,
-			       ping->ping_buf,
+		id.pid = ping->ping_id.pid;
+		lnet_nid4_to_nid(ping->ping_id.nid, &id.nid);
+		rc = lnet_ping(&id, &src_nid, timeout, &plist,
 			       ping->ping_count);
 		if (rc < 0)
-			return rc;
+			goto report_ping_err;
+		count = rc;
+
+		for (i = 0; i < count; i++) {
+			struct lnet_processid *result;
+			struct lnet_process_id tmpid;
+
+			result = genradix_ptr(&plist.lgpl_list, i);
+			memset(&tmpid, 0, sizeof(tmpid));
+			tmpid.pid = result->pid;
+			tmpid.nid = lnet_nid_to_nid4(&result->nid);
+			if (copy_to_user(&ids[i], &tmpid, sizeof(tmpid))) {
+				rc = -EFAULT;
+				goto report_ping_err;
+			}
+		}
 
 		mutex_lock(&the_lnet.ln_api_mutex);
-		lnet_nid4_to_nid(ping->ping_id.nid, &nid);
-		lp = lnet_find_peer(&nid);
+		lp = lnet_find_peer(&id.nid);
 		if (lp) {
 			ping->ping_id.nid =
 				lnet_nid_to_nid4(&lp->lp_primary_nid);
@@ -4433,8 +4446,10 @@ LNetCtl(unsigned int cmd, void *arg)
 		}
 		mutex_unlock(&the_lnet.ln_api_mutex);
 
-		ping->ping_count = rc;
-		return 0;
+		ping->ping_count = count;
+report_ping_err:
+		genradix_free(&plist.lgpl_list);
+		return rc;
 	}
 
 	case IOC_LIBCFS_DISCOVER: {
@@ -5229,9 +5244,339 @@ static int lnet_net_cmd(struct sk_buff *skb, struct genl_info *info)
 	return rc;
 }
 
+static inline struct lnet_genl_ping_list *
+lnet_ping_dump_ctx(struct netlink_callback *cb)
+{
+	return (struct lnet_genl_ping_list *)cb->args[0];
+}
+
+static int lnet_ping_show_done(struct netlink_callback *cb)
+{
+	struct lnet_genl_ping_list *plist = lnet_ping_dump_ctx(cb);
+
+	if (plist) {
+		genradix_free(&plist->lgpl_failed);
+		genradix_free(&plist->lgpl_list);
+		kfree(plist);
+		cb->args[0] = 0;
+	}
+
+	return 0;
+}
+
+/* LNet ping ->start() handler for GET requests */
+static int lnet_ping_show_start(struct netlink_callback *cb)
+{
+	struct genlmsghdr *gnlh = nlmsg_data(cb->nlh);
+	struct netlink_ext_ack *extack = cb->extack;
+	struct lnet_genl_ping_list *plist;
+	int msg_len = genlmsg_len(gnlh);
+	struct nlattr *params, *top;
+	int rem, rc = 0;
+
+	if (the_lnet.ln_refcount == 0) {
+		NL_SET_ERR_MSG(extack, "Network is down");
+		return -ENETDOWN;
+	}
+
+	if (!msg_len) {
+		NL_SET_ERR_MSG(extack, "Ping needs NID targets");
+		return -ENOENT;
+	}
+
+	plist = kzalloc(sizeof(*plist), GFP_KERNEL);
+	if (!plist) {
+		NL_SET_ERR_MSG(extack, "failed to setup ping list");
+		return -ENOMEM;
+	}
+	genradix_init(&plist->lgpl_list);
+	plist->lgpl_timeout = DEFAULT_PEER_TIMEOUT * HZ;
+	plist->lgpl_src_nid = LNET_ANY_NID;
+	plist->lgpl_index = 0;
+	plist->lgpl_list_count = 0;
+	cb->args[0] = (long)plist;
+
+	params = genlmsg_data(gnlh);
+	nla_for_each_attr(top, params, msg_len, rem) {
+		struct nlattr *nids;
+		int rem2;
+
+		switch (nla_type(top)) {
+		case LN_SCALAR_ATTR_VALUE:
+			if (nla_strcmp(top, "timeout") == 0) {
+				s64 timeout;
+
+				top = nla_next(top, &rem);
+				if (nla_type(top) != LN_SCALAR_ATTR_INT_VALUE) {
+					NL_SET_ERR_MSG(extack,
+						       "invalid timeout param");
+					rc = -EINVAL;
+					goto report_err;
+				}
+
+				/* If timeout is negative then set default of
+				 * 3 minutes
+				 */
+				timeout = nla_get_s64(top);
+				if (timeout > 0 &&
+				    timeout < (DEFAULT_PEER_TIMEOUT * MSEC_PER_SEC))
+					plist->lgpl_timeout =
+						nsecs_to_jiffies(timeout * NSEC_PER_MSEC);
+			} else if (nla_strcmp(top, "source") == 0) {
+				char nidstr[LNET_NIDSTR_SIZE + 1];
+
+				top = nla_next(top, &rem);
+				if (nla_type(top) != LN_SCALAR_ATTR_VALUE) {
+					NL_SET_ERR_MSG(extack,
+						       "invalid source param");
+					rc = -EINVAL;
+					goto report_err;
+				}
+
+				rc = nla_strlcpy(nidstr, top, sizeof(nidstr));
+				if (rc < 0) {
+					NL_SET_ERR_MSG(extack,
+						       "failed to parse source nid");
+					goto report_err;
+				}
+
+				rc = libcfs_strnid(&plist->lgpl_src_nid,
+						   strim(nidstr));
+				if (rc < 0) {
+					NL_SET_ERR_MSG(extack,
+						       "invalid source nid");
+					goto report_err;
+				}
+				rc = 0;
+			}
+			break;
+		case LN_SCALAR_ATTR_LIST:
+			nla_for_each_nested(nids, top, rem2) {
+				char nid[LNET_NIDSTR_SIZE + 1];
+				struct lnet_processid *id;
+
+				if (nla_type(nids) != LN_SCALAR_ATTR_VALUE)
+					continue;
+
+				memset(nid, 0, sizeof(nid));
+				rc = nla_strlcpy(nid, nids, sizeof(nid));
+				if (rc < 0) {
+					NL_SET_ERR_MSG(extack,
+						       "failed to get NID");
+					goto report_err;
+				}
+
+				id = genradix_ptr_alloc(&plist->lgpl_list,
+							plist->lgpl_list_count++,
+							GFP_ATOMIC);
+				if (!id) {
+					NL_SET_ERR_MSG(extack,
+						       "failed to allocate NID");
+					rc = -ENOMEM;
+					goto report_err;
+				}
+
+				rc = libcfs_strid(id, strim(nid));
+				if (rc < 0) {
+					NL_SET_ERR_MSG(extack, "invalid NID");
+					goto report_err;
+				}
+				rc = 0;
+			}
+			fallthrough;
+		default:
+			break;
+		}
+	}
+report_err:
+	if (rc < 0)
+		lnet_ping_show_done(cb);
+
+	return rc;
+}
+
+static const struct ln_key_list ping_props_list = {
+	.lkl_maxattr			= LNET_PING_ATTR_MAX,
+	.lkl_list			= {
+		[LNET_PING_ATTR_HDR]            = {
+			.lkp_value              = "ping",
+			.lkp_key_format		= LNKF_SEQUENCE | LNKF_MAPPING,
+			.lkp_data_type		= NLA_NUL_STRING,
+		},
+		[LNET_PING_ATTR_PRIMARY_NID]	= {
+			.lkp_value		= "primary nid",
+			.lkp_data_type          = NLA_STRING
+		},
+		[LNET_PING_ATTR_ERRNO]		= {
+			.lkp_value		= "errno",
+			.lkp_data_type		= NLA_S16
+		},
+		[LNET_PING_ATTR_MULTIRAIL]	= {
+			.lkp_value              = "Multi-Rail",
+			.lkp_data_type          = NLA_FLAG
+		},
+		[LNET_PING_ATTR_PEER_NI_LIST]	= {
+			.lkp_value		= "peer_ni",
+			.lkp_key_format         = LNKF_SEQUENCE | LNKF_MAPPING,
+			.lkp_data_type          = NLA_NESTED
+		},
+	},
+};
+
+static struct ln_key_list ping_peer_ni_list = {
+	.lkl_maxattr			= LNET_PING_PEER_NI_ATTR_MAX,
+	.lkl_list                       = {
+		[LNET_PING_PEER_NI_ATTR_NID]	= {
+			.lkp_value		= "nid",
+			.lkp_data_type		= NLA_STRING
+		},
+	},
+};
+
+static int lnet_ping_show_dump(struct sk_buff *msg,
+			       struct netlink_callback *cb)
+{
+	struct lnet_genl_ping_list *plist = lnet_ping_dump_ctx(cb);
+	struct genlmsghdr *gnlh = nlmsg_data(cb->nlh);
+	struct netlink_ext_ack *extack = cb->extack;
+	int portid = NETLINK_CB(cb->skb).portid;
+	int seq = cb->nlh->nlmsg_seq;
+	int idx = plist->lgpl_index;
+	int rc = 0, i = 0;
+
+	if (!plist->lgpl_index) {
+		const struct ln_key_list *all[] = {
+			&ping_props_list, &ping_peer_ni_list, NULL
+		};
+
+		rc = lnet_genl_send_scalar_list(msg, portid, seq,
+						&lnet_family,
+						NLM_F_CREATE | NLM_F_MULTI,
+						LNET_CMD_PING, all);
+		if (rc < 0) {
+			NL_SET_ERR_MSG(extack, "failed to send key table");
+			goto send_error;
+		}
+
+		genradix_init(&plist->lgpl_failed);
+	}
+
+	while (idx < plist->lgpl_list_count) {
+		struct lnet_nid primary_nid = LNET_ANY_NID;
+		struct lnet_genl_ping_list peers;
+		struct lnet_processid *id;
+		struct nlattr *nid_list;
+		struct lnet_peer *lp;
+		bool mr_flag = false;
+		unsigned int count;
+		void *hdr = NULL;
+
+		id = genradix_ptr(&plist->lgpl_list, idx++);
+		if (nid_is_lo0(&id->nid))
+			continue;
+
+		rc = lnet_ping(id, &plist->lgpl_src_nid, plist->lgpl_timeout,
+			       &peers, lnet_interfaces_max);
+		if (rc < 0) {
+			struct lnet_fail_ping *fail;
+
+			fail = genradix_ptr_alloc(&plist->lgpl_failed,
+						  plist->lgpl_failed_count++,
+						  GFP_ATOMIC);
+			if (!fail) {
+				NL_SET_ERR_MSG(extack,
+					       "failed to allocate failed NID");
+				goto send_error;
+			}
+			fail->lfp_id = *id;
+			fail->lfp_errno = rc;
+			goto cant_reach;
+		}
+
+		mutex_lock(&the_lnet.ln_api_mutex);
+		lp = lnet_find_peer(&id->nid);
+		if (lp) {
+			primary_nid = lp->lp_primary_nid;
+			mr_flag = lnet_peer_is_multi_rail(lp);
+			lnet_peer_decref_locked(lp);
+		}
+		mutex_unlock(&the_lnet.ln_api_mutex);
+
+		hdr = genlmsg_put(msg, portid, seq, &lnet_family,
+				  NLM_F_MULTI, LNET_CMD_PING);
+		if (!hdr) {
+			NL_SET_ERR_MSG(extack, "failed to send values");
+			genlmsg_cancel(msg, hdr);
+			rc = -EMSGSIZE;
+			goto send_error;
+		}
+
+		if (i++ == 0)
+			nla_put_string(msg, LNET_PING_ATTR_HDR, "");
+
+		nla_put_string(msg, LNET_PING_ATTR_PRIMARY_NID,
+			       libcfs_nidstr(&primary_nid));
+		if (mr_flag)
+			nla_put_flag(msg, LNET_PING_ATTR_MULTIRAIL);
+
+		nid_list = nla_nest_start(msg, LNET_PING_ATTR_PEER_NI_LIST);
+		for (count = 0; count < rc; count++) {
+			struct lnet_processid *result;
+			struct nlattr *nid_attr;
+			char *idstr;
+
+			result = genradix_ptr(&peers.lgpl_list, count);
+			if (nid_is_lo0(&result->nid))
+				continue;
+
+			nid_attr = nla_nest_start(msg, count + 1);
+			if (gnlh->version == 1)
+				idstr = libcfs_nidstr(&result->nid);
+			else
+				idstr = libcfs_idstr(result);
+			nla_put_string(msg, LNET_PING_PEER_NI_ATTR_NID, idstr);
+			nla_nest_end(msg, nid_attr);
+		}
+		nla_nest_end(msg, nid_list);
+		genlmsg_end(msg, hdr);
+cant_reach:
+		genradix_free(&peers.lgpl_list);
+	}
+
+	for (i = 0; i < plist->lgpl_failed_count; i++) {
+		struct lnet_fail_ping *fail;
+		void *hdr;
+
+		fail = genradix_ptr(&plist->lgpl_failed, i);
+
+		hdr = genlmsg_put(msg, portid, seq, &lnet_family,
+				  NLM_F_MULTI, LNET_CMD_PING);
+		if (!hdr) {
+			NL_SET_ERR_MSG(extack, "failed to send failed values");
+			genlmsg_cancel(msg, hdr);
+			rc = -EMSGSIZE;
+			goto send_error;
+		}
+
+		if (i == 0)
+			nla_put_string(msg, LNET_PING_ATTR_HDR, "");
+
+		nla_put_string(msg, LNET_PING_ATTR_PRIMARY_NID,
+			       libcfs_nidstr(&fail->lfp_id.nid));
+		nla_put_s16(msg, LNET_PING_ATTR_ERRNO, fail->lfp_errno);
+		genlmsg_end(msg, hdr);
+	}
+	rc = 0; /* don't treat it as an error */
+
+	plist->lgpl_index = idx;
+send_error:
+	return rc;
+}
+
 static const struct genl_multicast_group lnet_mcast_grps[] = {
 	{ .name	=	"ip2net",	},
 	{ .name =	"net",		},
+	{ .name	=	"ping",		},
 };
 
 static const struct genl_ops lnet_genl_ops[] = {
@@ -5242,6 +5587,12 @@ static const struct genl_ops lnet_genl_ops[] = {
 		.done		= lnet_net_show_done,
 		.doit		= lnet_net_cmd,
 	},
+	{
+		.cmd		= LNET_CMD_PING,
+		.start		= lnet_ping_show_start,
+		.dumpit		= lnet_ping_show_dump,
+		.done		= lnet_ping_show_done,
+	},
 };
 
 static struct genl_family lnet_family = {
@@ -5337,29 +5688,26 @@ lnet_ping_event_handler(struct lnet_event *event)
 		complete(&pd->completion);
 }
 
-/* lnet_ping() only works with nid4 nids, so we can calculate
- * size from number of nids
- */
-#define LNET_PING_INFO_SIZE(NNIDS) \
-	offsetof(struct lnet_ping_info, pi_ni[NNIDS])
-
-static int lnet_ping(struct lnet_process_id id4, struct lnet_nid *src_nid,
-		     signed long timeout, struct lnet_process_id __user *ids,
+static int lnet_ping(struct lnet_processid *id, struct lnet_nid *src_nid,
+		     signed long timeout, struct lnet_genl_ping_list *plist,
 		     int n_ids)
 {
+	int id_bytes = sizeof(struct lnet_ni_status); /* For 0@lo */
 	struct lnet_md md = { NULL };
 	struct ping_data pd = { 0 };
 	struct lnet_ping_buffer *pbuf;
-	struct lnet_process_id tmpid;
-	struct lnet_processid id;
-	int id_bytes;
-	int i;
+	struct lnet_processid pid;
+	struct lnet_ping_iter pi;
+	int i = 0;
+	u32 *st;
 	int nob;
 	int rc;
 	int rc2;
 
+	genradix_init(&plist->lgpl_list);
+
 	/* n_ids limit is arbitrary */
-	if (n_ids <= 0 || id4.nid == LNET_NID_ANY)
+	if (n_ids <= 0 || LNET_NID_IS_ANY(&id->nid))
 		return -EINVAL;
 
 	/* if the user buffer has more space than the lnet_interfaces_max
@@ -5368,10 +5716,10 @@ static int lnet_ping(struct lnet_process_id id4, struct lnet_nid *src_nid,
 	if (n_ids > lnet_interfaces_max)
 		n_ids = lnet_interfaces_max;
 
-	if (id4.pid == LNET_PID_ANY)
-		id4.pid = LNET_PID_LUSTRE;
+	if (id->pid == LNET_PID_ANY)
+		id->pid = LNET_PID_LUSTRE;
 
-	id_bytes = LNET_PING_INFO_SIZE(n_ids);
+	id_bytes += lnet_ping_sts_size(&id->nid) * n_ids;
 	pbuf = lnet_ping_buffer_alloc(id_bytes, GFP_NOFS);
 	if (!pbuf)
 		return -ENOMEM;
@@ -5393,8 +5741,7 @@ static int lnet_ping(struct lnet_process_id id4, struct lnet_nid *src_nid,
 		goto fail_ping_buffer_decref;
 	}
 
-	lnet_pid4_to_pid(id4, &id);
-	rc = LNetGet(src_nid, pd.mdh, &id, LNET_RESERVED_PORTAL,
+	rc = LNetGet(src_nid, pd.mdh, id, LNET_RESERVED_PORTAL,
 		     LNET_PROTO_PING_MATCHBITS, 0, false);
 	if (rc) {
 		/* Don't CERROR; this could be deliberate! */
@@ -5410,6 +5757,7 @@ static int lnet_ping(struct lnet_process_id id4, struct lnet_nid *src_nid,
 		LNetMDUnlink(pd.mdh);
 		wait_for_completion(&pd.completion);
 	}
+
 	if (!pd.replied) {
 		rc = pd.rc ?: -EIO;
 		goto fail_ping_buffer_decref;
@@ -5420,9 +5768,9 @@ static int lnet_ping(struct lnet_process_id id4, struct lnet_nid *src_nid,
 
 	rc = -EPROTO;		/* if I can't parse... */
 
-	if (nob < 8) {
+	if (nob < LNET_PING_INFO_HDR_SIZE) {
 		CERROR("%s: ping info too short %d\n",
-		       libcfs_idstr(&id), nob);
+		       libcfs_idstr(id), nob);
 		goto fail_ping_buffer_decref;
 	}
 
@@ -5430,54 +5778,55 @@ static int lnet_ping(struct lnet_process_id id4, struct lnet_nid *src_nid,
 		lnet_swap_pinginfo(pbuf);
 	} else if (pbuf->pb_info.pi_magic != LNET_PROTO_PING_MAGIC) {
 		CERROR("%s: Unexpected magic %08x\n",
-		       libcfs_idstr(&id), pbuf->pb_info.pi_magic);
+		       libcfs_idstr(id), pbuf->pb_info.pi_magic);
 		goto fail_ping_buffer_decref;
 	}
 
 	if (!(pbuf->pb_info.pi_features & LNET_PING_FEAT_NI_STATUS)) {
 		CERROR("%s: ping w/o NI status: 0x%x\n",
-		       libcfs_idstr(&id), pbuf->pb_info.pi_features);
+		       libcfs_idstr(id), pbuf->pb_info.pi_features);
 		goto fail_ping_buffer_decref;
 	}
 
 	/* Test if smaller than lnet_pinginfo with just one pi_ni status info.
 	 * That one might contain size when large nids are used.
 	 */
-	if (nob < LNET_PING_INFO_SIZE(1)) {
+	if (nob < offsetof(struct lnet_ping_info, pi_ni[1])) {
 		CERROR("%s: Short reply %d(%lu min)\n",
-		       libcfs_idstr(&id), nob, LNET_PING_INFO_SIZE(1));
+		       libcfs_idstr(id), nob,
+		       offsetof(struct lnet_ping_info, pi_ni[1]));
 		goto fail_ping_buffer_decref;
 	}
 
-	if (pbuf->pb_info.pi_nnis < n_ids) {
-		n_ids = pbuf->pb_info.pi_nnis;
+	if (ping_info_count_entries(pbuf) < n_ids) {
+		n_ids = ping_info_count_entries(pbuf);
 		id_bytes = lnet_ping_info_size(&pbuf->pb_info);
 	}
 
 	if (nob < id_bytes) {
 		CERROR("%s: Short reply %d(%d expected)\n",
-		       libcfs_idstr(&id), nob, id_bytes);
+		       libcfs_idstr(id), nob, id_bytes);
 		goto fail_ping_buffer_decref;
 	}
 
-	rc = -EFAULT;		/* if I segv in copy_to_user()... */
-
-	memset(&tmpid, 0, sizeof(tmpid));
-	for (i = 0; i < n_ids; i++) {
-		tmpid.pid = pbuf->pb_info.pi_pid;
-		tmpid.nid = pbuf->pb_info.pi_ni[i].ns_nid;
-		if (copy_to_user(&ids[i], &tmpid, sizeof(tmpid)))
+	for (st = ping_iter_first(&pi, pbuf, &pid.nid);
+	     st;
+	     st = ping_iter_next(&pi, &pid.nid)) {
+		id = genradix_ptr_alloc(&plist->lgpl_list, i++, GFP_ATOMIC);
+		if (!id) {
+			rc = -ENOMEM;
 			goto fail_ping_buffer_decref;
-	}
-	rc = pbuf->pb_info.pi_nnis;
+		}
 
+		id->pid = pbuf->pb_info.pi_pid;
+		id->nid = pid.nid;
+	}
+	rc = i;
 fail_ping_buffer_decref:
 	lnet_ping_buffer_decref(pbuf);
 	return rc;
 }
 
-#undef LNET_PING_INFO_SIZE
-
 static int
 lnet_discover(struct lnet_process_id id4, u32 force,
 	      struct lnet_process_id __user *ids,
diff --git a/net/lnet/lnet/nidstrings.c b/net/lnet/lnet/nidstrings.c
index ac2aa973a412..b5a585507d6a 100644
--- a/net/lnet/lnet/nidstrings.c
+++ b/net/lnet/lnet/nidstrings.c
@@ -1170,6 +1170,30 @@ libcfs_idstr(struct lnet_processid *id)
 }
 EXPORT_SYMBOL(libcfs_idstr);
 
+int
+libcfs_strid(struct lnet_processid *id, const char *str)
+{
+	char *tmp = strchr(str, '-');
+
+	id->pid = LNET_PID_LUSTRE;
+	if (tmp &&
+	    strncmp("LNET_PID_ANY-", str, tmp - str) != 0) {
+		char pid[LNET_NIDSTR_SIZE];
+		int rc;
+
+		strscpy(pid, str, tmp - str);
+		rc = kstrtou32(pid, 10, &id->pid);
+		if (rc < 0)
+			return rc;
+		tmp++;
+	} else {
+		tmp = (char *)str;
+	}
+
+	return libcfs_strnid(&id->nid, tmp);
+}
+EXPORT_SYMBOL(libcfs_strid);
+
 int
 libcfs_str2anynid(lnet_nid_t *nidp, const char *str)
 {
diff --git a/net/lnet/lnet/peer.c b/net/lnet/lnet/peer.c
index a9759860a5cd..da1f8d4d67a3 100644
--- a/net/lnet/lnet/peer.c
+++ b/net/lnet/lnet/peer.c
@@ -2955,7 +2955,7 @@ u32 *ping_iter_next(struct lnet_ping_iter *pi, struct lnet_nid *nid)
 	return NULL;
 }
 
-static int ping_info_count_entries(struct lnet_ping_buffer *pbuf)
+int ping_info_count_entries(struct lnet_ping_buffer *pbuf)
 {
 	struct lnet_ping_iter pi;
 	u32 *st;
-- 
2.27.0

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
