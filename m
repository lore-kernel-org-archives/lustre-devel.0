Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 543B5C433FE
	for <lustre-devel@archiver.kernel.org>; Sun, 20 Nov 2022 14:34:46 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4NFXkQ3gPFz21J5;
	Sun, 20 Nov 2022 06:21:02 -0800 (PST)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4NFXj95zYTz21Bb
 for <lustre-devel@lists.lustre.org>; Sun, 20 Nov 2022 06:19:57 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id D8C4410084E2;
 Sun, 20 Nov 2022 09:17:09 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id D6609E8B84; Sun, 20 Nov 2022 09:17:09 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 20 Nov 2022 09:16:59 -0500
Message-Id: <1668953828-10909-14-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1668953828-10909-1-git-send-email-jsimmons@infradead.org>
References: <1668953828-10909-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 13/22] lnet: selftest: migrate LNet selftest
 session handling to Netlink
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

The currently LNet selftest ioctl interface has a few issues which
can be resolved using Netlink. The first is the current API using
struct list_head is disliked by the Linux VFS maintainers. While
we technically don't need to use the struct list_head directly
its still confusing and passing pointers from userland to kernel
space is also frowned on.

Second issue that is exposed with debug kernels is that ioctl
handling done with the lstcon_ioctl_handler can easily end up
in a might_sleep state.

The new Netlink work is also needed for the IPv6 support. Update
the session handling to work with large NIDs. Internally use
struct lst_session_id which supports large NIDs instead of
struct lst_sid.

Lastly we have been wanting YAMl handling with LNet selftest
(LU-10975) which comes naturally with this work.

WC-bug-id: https://jira.whamcloud.com/browse/LU-8915
Signed-off-by: James Simmons <jsimmons@infradead.org>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/43298
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Reviewed-by: Frank Sehr <fsehr@whamcloud.com>
---
 include/uapi/linux/lnet/lnetst.h |  21 ++-
 net/lnet/selftest/conctl.c       | 349 +++++++++++++++++++++++++++++++--------
 net/lnet/selftest/conrpc.c       |  28 +++-
 net/lnet/selftest/console.c      |  81 +++------
 net/lnet/selftest/console.h      |  68 ++++----
 net/lnet/selftest/framework.c    |  43 +++--
 net/lnet/selftest/selftest.h     |  78 +++++++--
 7 files changed, 477 insertions(+), 191 deletions(-)

diff --git a/include/uapi/linux/lnet/lnetst.h b/include/uapi/linux/lnet/lnetst.h
index af0435f1..d04496d 100644
--- a/include/uapi/linux/lnet/lnetst.h
+++ b/include/uapi/linux/lnet/lnetst.h
@@ -84,8 +84,6 @@ struct lst_sid {
 	__s64		ses_stamp;	/* time stamp */
 };					/*** session id */
 
-extern struct lst_sid LST_INVALID_SID;
-
 struct lst_bid {
 	__u64	bat_id;		/* unique id in session */
 };				/*** batch id (group of tests) */
@@ -577,4 +575,23 @@ struct sfw_counters {
 	__u32 ping_errors;
 } __packed;
 
+#define LNET_SELFTEST_GENL_NAME		"lnet_selftest"
+#define LNET_SELFTEST_GENL_VERSION	0x1
+
+/* enum lnet_selftest_commands	      - Supported core LNet Selftest Netlink
+ *					commands
+ *
+ * @LNET_SELFTEST_CMD_UNSPEC:		unspecified command to catch errors
+ * @LNET_SELFTEST_CMD_SESSIONS:		command to manage sessions
+ */
+enum lnet_selftest_commands {
+	LNET_SELFTEST_CMD_UNSPEC	= 0,
+
+	LNET_SELFTEST_CMD_SESSIONS	= 1,
+
+	__LNET_SELFTEST_CMD_MAX_PLUS_ONE,
+};
+
+#define LNET_SELFTEST_CMD_MAX (__LNET_SELFTEST_CMD_MAX_PLUS_ONE - 1)
+
 #endif
diff --git a/net/lnet/selftest/conctl.c b/net/lnet/selftest/conctl.c
index ede7fe5..aa11885 100644
--- a/net/lnet/selftest/conctl.c
+++ b/net/lnet/selftest/conctl.c
@@ -40,67 +40,6 @@
 #include "console.h"
 
 static int
-lst_session_new_ioctl(struct lstio_session_new_args *args)
-{
-	char name[LST_NAME_SIZE + 1];
-	int rc;
-
-	if (!args->lstio_ses_idp ||	/* address for output sid */
-	    !args->lstio_ses_key ||	/* no key is specified */
-	    !args->lstio_ses_namep ||	/* session name */
-	    args->lstio_ses_nmlen <= 0 ||
-	    args->lstio_ses_nmlen > LST_NAME_SIZE)
-		return -EINVAL;
-
-	if (copy_from_user(name, args->lstio_ses_namep,
-			   args->lstio_ses_nmlen)) {
-		return -EFAULT;
-	}
-
-	name[args->lstio_ses_nmlen] = 0;
-
-	rc = lstcon_session_new(name,
-				args->lstio_ses_key,
-				args->lstio_ses_feats,
-				args->lstio_ses_timeout,
-				args->lstio_ses_force,
-				args->lstio_ses_idp);
-
-	return rc;
-}
-
-static int
-lst_session_end_ioctl(struct lstio_session_end_args *args)
-{
-	if (args->lstio_ses_key != console_session.ses_key)
-		return -EACCES;
-
-	return lstcon_session_end();
-}
-
-static int
-lst_session_info_ioctl(struct lstio_session_info_args *args)
-{
-	/* no checking of key */
-
-	if (!args->lstio_ses_idp ||	/* address for output sid */
-	    !args->lstio_ses_keyp ||	/* address for output key */
-	    !args->lstio_ses_featp ||	/* address for output features */
-	    !args->lstio_ses_ndinfo ||	/* address for output ndinfo */
-	    !args->lstio_ses_namep ||	/* address for output name */
-	    args->lstio_ses_nmlen <= 0 ||
-	    args->lstio_ses_nmlen > LST_NAME_SIZE)
-		return -EINVAL;
-
-	return lstcon_session_info(args->lstio_ses_idp,
-				   args->lstio_ses_keyp,
-				   args->lstio_ses_featp,
-				   args->lstio_ses_ndinfo,
-				   args->lstio_ses_namep,
-				   args->lstio_ses_nmlen);
-}
-
-static int
 lst_debug_ioctl(struct lstio_debug_args *args)
 {
 	char name[LST_NAME_SIZE + 1];
@@ -729,13 +668,11 @@ static int lst_test_add_ioctl(struct lstio_test_args *args)
 
 	switch (opc) {
 	case LSTIO_SESSION_NEW:
-		rc = lst_session_new_ioctl((struct lstio_session_new_args *)buf);
-		break;
+		fallthrough;
 	case LSTIO_SESSION_END:
-		rc = lst_session_end_ioctl((struct lstio_session_end_args *)buf);
-		break;
+		fallthrough;
 	case LSTIO_SESSION_INFO:
-		rc = lst_session_info_ioctl((struct lstio_session_info_args *)buf);
+		rc = -EOPNOTSUPP;
 		break;
 	case LSTIO_DEBUG:
 		rc = lst_debug_ioctl((struct lstio_debug_args *)buf);
@@ -797,3 +734,283 @@ static int lst_test_add_ioctl(struct lstio_test_args *args)
 
 	return notifier_from_ioctl_errno(rc);
 }
+
+static struct genl_family lst_family;
+
+static const struct ln_key_list lst_session_keys = {
+	.lkl_maxattr			= LNET_SELFTEST_SESSION_MAX,
+	.lkl_list			= {
+		[LNET_SELFTEST_SESSION_HDR]	= {
+			.lkp_value		= "session",
+			.lkp_key_format		= LNKF_MAPPING,
+			.lkp_data_type		= NLA_NUL_STRING,
+		},
+		[LNET_SELFTEST_SESSION_NAME]	= {
+			.lkp_value		= "name",
+			.lkp_data_type		= NLA_STRING,
+		},
+		[LNET_SELFTEST_SESSION_KEY]	= {
+			.lkp_value		= "key",
+			.lkp_data_type		= NLA_U32,
+		},
+		[LNET_SELFTEST_SESSION_TIMESTAMP] = {
+			.lkp_value		= "timestamp",
+			.lkp_data_type		= NLA_S64,
+		},
+		[LNET_SELFTEST_SESSION_NID]	= {
+			.lkp_value		= "nid",
+			.lkp_data_type		= NLA_STRING,
+		},
+		[LNET_SELFTEST_SESSION_NODE_COUNT] = {
+			.lkp_value		= "nodes",
+			.lkp_data_type		= NLA_U16,
+		},
+	},
+};
+
+static int lst_sessions_show_dump(struct sk_buff *msg,
+				  struct netlink_callback *cb)
+{
+	const struct ln_key_list *all[] = {
+		&lst_session_keys, NULL
+	};
+	struct netlink_ext_ack *extack = cb->extack;
+	int portid = NETLINK_CB(cb->skb).portid;
+	int seq = cb->nlh->nlmsg_seq;
+	unsigned int node_count = 0;
+	struct lstcon_ndlink *ndl;
+	int flag = NLM_F_MULTI;
+	int rc = 0;
+	void *hdr;
+
+	if (console_session.ses_state != LST_SESSION_ACTIVE) {
+		NL_SET_ERR_MSG(extack, "session is not active");
+		rc = -ESRCH;
+		goto out_unlock;
+	}
+
+	list_for_each_entry(ndl, &console_session.ses_ndl_list, ndl_link)
+		node_count++;
+
+	rc = lnet_genl_send_scalar_list(msg, portid, seq, &lst_family,
+					NLM_F_CREATE | NLM_F_MULTI,
+					LNET_SELFTEST_CMD_SESSIONS, all);
+	if (rc < 0) {
+		NL_SET_ERR_MSG(extack, "failed to send key table");
+		goto out_unlock;
+	}
+
+	if (console_session.ses_force)
+		flag |= NLM_F_REPLACE;
+
+	hdr = genlmsg_put(msg, portid, seq, &lst_family, flag,
+			  LNET_SELFTEST_CMD_SESSIONS);
+	if (!hdr) {
+		NL_SET_ERR_MSG(extack, "failed to send values");
+		genlmsg_cancel(msg, hdr);
+		rc = -EMSGSIZE;
+		goto out_unlock;
+	}
+
+	nla_put_string(msg, LNET_SELFTEST_SESSION_NAME,
+		       console_session.ses_name);
+	nla_put_u32(msg, LNET_SELFTEST_SESSION_KEY,
+		    console_session.ses_key);
+	nla_put_u64_64bit(msg, LNET_SELFTEST_SESSION_TIMESTAMP,
+			  console_session.ses_id.ses_stamp,
+			  LNET_SELFTEST_SESSION_PAD);
+	nla_put_string(msg, LNET_SELFTEST_SESSION_NID,
+		       libcfs_nidstr(&console_session.ses_id.ses_nid));
+	nla_put_u16(msg, LNET_SELFTEST_SESSION_NODE_COUNT,
+		    node_count);
+	genlmsg_end(msg, hdr);
+out_unlock:
+	return rc;
+}
+
+static int lst_sessions_cmd(struct sk_buff *skb, struct genl_info *info)
+{
+	struct sk_buff *msg = NULL;
+	int rc = 0;
+
+	mutex_lock(&console_session.ses_mutex);
+
+	console_session.ses_laststamp = ktime_get_real_seconds();
+
+	if (console_session.ses_shutdown) {
+		GENL_SET_ERR_MSG(info, "session is shutdown");
+		rc = -ESHUTDOWN;
+		goto out_unlock;
+	}
+
+	if (console_session.ses_expired)
+		lstcon_session_end();
+
+	if (!(info->nlhdr->nlmsg_flags & NLM_F_CREATE) &&
+	    console_session.ses_state == LST_SESSION_NONE) {
+		GENL_SET_ERR_MSG(info, "session is not active");
+		rc = -ESRCH;
+		goto out_unlock;
+	}
+
+	memset(&console_session.ses_trans_stat, 0,
+	       sizeof(struct lstcon_trans_stat));
+
+	if (!(info->nlhdr->nlmsg_flags & NLM_F_CREATE)) {
+		lstcon_session_end();
+		goto out_unlock;
+	}
+
+	if (info->attrs[LN_SCALAR_ATTR_LIST]) {
+		struct genlmsghdr *gnlh = nlmsg_data(info->nlhdr);
+		const struct ln_key_list *all[] = {
+			&lst_session_keys, NULL
+		};
+		char name[LST_NAME_SIZE];
+		struct nlmsghdr *nlh;
+		struct nlattr *item;
+		bool force = false;
+		s64 timeout = 300;
+		void *hdr;
+		int rem;
+
+		if (info->nlhdr->nlmsg_flags & NLM_F_REPLACE)
+			force = true;
+
+		nla_for_each_nested(item, info->attrs[LN_SCALAR_ATTR_LIST],
+				    rem) {
+			if (nla_type(item) != LN_SCALAR_ATTR_VALUE)
+				continue;
+
+			if (nla_strcmp(item, "name") == 0) {
+				ssize_t len;
+
+				item = nla_next(item, &rem);
+				if (nla_type(item) != LN_SCALAR_ATTR_VALUE) {
+					rc = -EINVAL;
+					goto err_conf;
+				}
+
+				len = nla_strlcpy(name, item, sizeof(name));
+				if (len < 0)
+					rc = len;
+			} else if (nla_strcmp(item, "timeout") == 0) {
+				item = nla_next(item, &rem);
+				if (nla_type(item) !=
+				    LN_SCALAR_ATTR_INT_VALUE) {
+					rc = -EINVAL;
+					goto err_conf;
+				}
+
+				timeout = nla_get_s64(item);
+				if (timeout < 0)
+					rc = -ERANGE;
+			}
+			if (rc < 0) {
+err_conf:
+				GENL_SET_ERR_MSG(info,
+						 "failed to get config");
+				goto out_unlock;
+			}
+		}
+
+		rc = lstcon_session_new(name, info->nlhdr->nlmsg_pid,
+					gnlh->version, timeout,
+					force);
+		if (rc < 0) {
+			GENL_SET_ERR_MSG(info, "new session creation failed");
+			lstcon_session_end();
+			goto out_unlock;
+		}
+
+		msg = genlmsg_new(GENLMSG_DEFAULT_SIZE, GFP_KERNEL);
+		if (!msg) {
+			GENL_SET_ERR_MSG(info, "msg allocation failed");
+			rc = -ENOMEM;
+			goto out_unlock;
+		}
+
+		rc = lnet_genl_send_scalar_list(msg, info->snd_portid,
+						info->snd_seq, &lst_family,
+						NLM_F_CREATE | NLM_F_MULTI,
+						LNET_SELFTEST_CMD_SESSIONS,
+						all);
+		if (rc < 0) {
+			GENL_SET_ERR_MSG(info, "failed to send key table");
+			goto out_unlock;
+		}
+
+		hdr = genlmsg_put(msg, info->snd_portid, info->snd_seq,
+				  &lst_family, NLM_F_MULTI,
+				  LNET_SELFTEST_CMD_SESSIONS);
+		if (!hdr) {
+			GENL_SET_ERR_MSG(info, "failed to send values");
+			genlmsg_cancel(msg, hdr);
+			rc = -EMSGSIZE;
+			goto out_unlock;
+		}
+
+		nla_put_string(msg, LNET_SELFTEST_SESSION_NAME,
+			       console_session.ses_name);
+		nla_put_u32(msg, LNET_SELFTEST_SESSION_KEY,
+			    console_session.ses_key);
+		nla_put_u64_64bit(msg, LNET_SELFTEST_SESSION_TIMESTAMP,
+				  console_session.ses_id.ses_stamp,
+				  LNET_SELFTEST_SESSION_PAD);
+		nla_put_string(msg, LNET_SELFTEST_SESSION_NID,
+			       libcfs_nidstr(&console_session.ses_id.ses_nid));
+		nla_put_u16(msg, LNET_SELFTEST_SESSION_NODE_COUNT, 0);
+
+		genlmsg_end(msg, hdr);
+
+		nlh = nlmsg_put(msg, info->snd_portid, info->snd_seq,
+				NLMSG_DONE, 0, NLM_F_MULTI);
+		if (!nlh) {
+			GENL_SET_ERR_MSG(info, "failed to complete message");
+			genlmsg_cancel(msg, hdr);
+			rc = -ENOMEM;
+			goto out_unlock;
+		}
+		rc = genlmsg_reply(msg, info);
+		if (rc)
+			GENL_SET_ERR_MSG(info, "failed to send reply");
+	}
+out_unlock:
+	if (rc < 0 && msg)
+		nlmsg_free(msg);
+	mutex_unlock(&console_session.ses_mutex);
+	return rc;
+}
+
+static const struct genl_multicast_group lst_mcast_grps[] = {
+	{ .name = "sessions",		},
+};
+
+static const struct genl_ops lst_genl_ops[] = {
+	{
+		.cmd		= LNET_SELFTEST_CMD_SESSIONS,
+		.dumpit		= lst_sessions_show_dump,
+		.doit		= lst_sessions_cmd,
+	},
+};
+
+static struct genl_family lst_family = {
+	.name		= LNET_SELFTEST_GENL_NAME,
+	.version	= LNET_SELFTEST_GENL_VERSION,
+	.maxattr	= LN_SCALAR_MAX,
+	.module		= THIS_MODULE,
+	.ops		= lst_genl_ops,
+	.n_ops		= ARRAY_SIZE(lst_genl_ops),
+	.mcgrps		= lst_mcast_grps,
+	.n_mcgrps	= ARRAY_SIZE(lst_mcast_grps),
+};
+
+int lstcon_init_netlink(void)
+{
+	return genl_register_family(&lst_family);
+}
+
+void lstcon_fini_netlink(void)
+{
+	genl_unregister_family(&lst_family);
+}
diff --git a/net/lnet/selftest/conrpc.c b/net/lnet/selftest/conrpc.c
index 0170219..8096c46 100644
--- a/net/lnet/selftest/conrpc.c
+++ b/net/lnet/selftest/conrpc.c
@@ -602,7 +602,9 @@ void lstcon_rpc_stat_reply(struct lstcon_rpc_trans *, struct srpc_msg *,
 			return rc;
 
 		msrq = &(*crpc)->crp_rpc->crpc_reqstmsg.msg_body.mksn_reqst;
-		msrq->mksn_sid = console_session.ses_id;
+		msrq->mksn_sid.ses_stamp = console_session.ses_id.ses_stamp;
+		msrq->mksn_sid.ses_nid =
+			lnet_nid_to_nid4(&console_session.ses_id.ses_nid);
 		msrq->mksn_force = console_session.ses_force;
 		strlcpy(msrq->mksn_name, console_session.ses_name,
 			sizeof(msrq->mksn_name));
@@ -615,7 +617,9 @@ void lstcon_rpc_stat_reply(struct lstcon_rpc_trans *, struct srpc_msg *,
 			return rc;
 
 		rsrq = &(*crpc)->crp_rpc->crpc_reqstmsg.msg_body.rmsn_reqst;
-		rsrq->rmsn_sid = console_session.ses_id;
+		rsrq->rmsn_sid.ses_stamp = console_session.ses_id.ses_stamp;
+		rsrq->rmsn_sid.ses_nid =
+			lnet_nid_to_nid4(&console_session.ses_id.ses_nid);
 		break;
 
 	default:
@@ -638,7 +642,9 @@ void lstcon_rpc_stat_reply(struct lstcon_rpc_trans *, struct srpc_msg *,
 
 	drq = &(*crpc)->crp_rpc->crpc_reqstmsg.msg_body.dbg_reqst;
 
-	drq->dbg_sid = console_session.ses_id;
+	drq->dbg_sid.ses_stamp = console_session.ses_id.ses_stamp;
+	drq->dbg_sid.ses_nid =
+		lnet_nid_to_nid4(&console_session.ses_id.ses_nid);
 	drq->dbg_flags = 0;
 
 	return rc;
@@ -658,7 +664,9 @@ void lstcon_rpc_stat_reply(struct lstcon_rpc_trans *, struct srpc_msg *,
 
 	brq = &(*crpc)->crp_rpc->crpc_reqstmsg.msg_body.bat_reqst;
 
-	brq->bar_sid = console_session.ses_id;
+	brq->bar_sid.ses_stamp = console_session.ses_id.ses_stamp;
+	brq->bar_sid.ses_nid =
+		lnet_nid_to_nid4(&console_session.ses_id.ses_nid);
 	brq->bar_bid = tsb->tsb_id;
 	brq->bar_testidx = tsb->tsb_index;
 	brq->bar_opc = transop == LST_TRANS_TSBRUN ? SRPC_BATCH_OPC_RUN :
@@ -690,7 +698,9 @@ void lstcon_rpc_stat_reply(struct lstcon_rpc_trans *, struct srpc_msg *,
 
 	srq = &(*crpc)->crp_rpc->crpc_reqstmsg.msg_body.stat_reqst;
 
-	srq->str_sid = console_session.ses_id;
+	srq->str_sid.ses_stamp = console_session.ses_id.ses_stamp;
+	srq->str_sid.ses_nid =
+		lnet_nid_to_nid4(&console_session.ses_id.ses_nid);
 	srq->str_type = 0; /* XXX remove it */
 
 	return 0;
@@ -877,7 +887,9 @@ void lstcon_rpc_stat_reply(struct lstcon_rpc_trans *, struct srpc_msg *,
 		trq->tsr_loop = test->tes_loop;
 	}
 
-	trq->tsr_sid = console_session.ses_id;
+	trq->tsr_sid.ses_stamp = console_session.ses_id.ses_stamp;
+	trq->tsr_sid.ses_nid =
+		lnet_nid_to_nid4(&console_session.ses_id.ses_nid);
 	trq->tsr_bid = test->tes_hdr.tsb_id;
 	trq->tsr_concur = test->tes_concur;
 	trq->tsr_is_client = (transop == LST_TRANS_TSBCLIADD) ? 1 : 0;
@@ -1259,7 +1271,9 @@ void lstcon_rpc_stat_reply(struct lstcon_rpc_trans *, struct srpc_msg *,
 
 		drq = &crpc->crp_rpc->crpc_reqstmsg.msg_body.dbg_reqst;
 
-		drq->dbg_sid = console_session.ses_id;
+		drq->dbg_sid.ses_stamp = console_session.ses_id.ses_stamp;
+		drq->dbg_sid.ses_nid =
+			lnet_nid_to_nid4(&console_session.ses_id.ses_nid);
 		drq->dbg_flags = 0;
 
 		lstcon_rpc_trans_addreq(trans, crpc);
diff --git a/net/lnet/selftest/console.c b/net/lnet/selftest/console.c
index 85e9300..1ed6191 100644
--- a/net/lnet/selftest/console.c
+++ b/net/lnet/selftest/console.c
@@ -1679,27 +1679,32 @@ static void lstcon_group_ndlink_release(struct lstcon_group *,
 }
 
 int
-lstcon_session_match(struct lst_sid sid)
+lstcon_session_match(struct lst_sid id)
 {
-	return (console_session.ses_id.ses_nid == sid.ses_nid &&
-		console_session.ses_id.ses_stamp == sid.ses_stamp) ? 1 : 0;
+	struct lst_session_id sid;
+
+	sid.ses_stamp = id.ses_stamp;
+	lnet_nid4_to_nid(id.ses_nid, &sid.ses_nid);
+
+	return (nid_same(&console_session.ses_id.ses_nid, &sid.ses_nid) &&
+		console_session.ses_id.ses_stamp == sid.ses_stamp) ?  1 : 0;
 }
 
 static void
-lstcon_new_session_id(struct lst_sid *sid)
+lstcon_new_session_id(struct lst_session_id *sid)
 {
 	struct lnet_processid id;
 
 	LASSERT(console_session.ses_state == LST_SESSION_NONE);
 
 	LNetGetId(1, &id);
-	sid->ses_nid = lnet_nid_to_nid4(&id.nid);
+	sid->ses_nid = id.nid;
 	sid->ses_stamp = div_u64(ktime_get_ns(), NSEC_PER_MSEC);
 }
 
 int
 lstcon_session_new(char *name, int key, unsigned int feats,
-		   int timeout, int force, struct lst_sid __user *sid_up)
+		   int timeout, int force)
 {
 	int rc = 0;
 	int i;
@@ -1731,7 +1736,6 @@ static void lstcon_group_ndlink_release(struct lstcon_group *,
 	lstcon_new_session_id(&console_session.ses_id);
 
 	console_session.ses_key = key;
-	console_session.ses_state = LST_SESSION_ACTIVE;
 	console_session.ses_force = !!force;
 	console_session.ses_features = feats;
 	console_session.ses_feats_updated = 0;
@@ -1757,52 +1761,12 @@ static void lstcon_group_ndlink_release(struct lstcon_group *,
 		return rc;
 	}
 
-	if (!copy_to_user(sid_up, &console_session.ses_id,
-			  sizeof(struct lst_sid)))
-		return rc;
-
-	lstcon_session_end();
-
-	return -EFAULT;
-}
-
-int
-lstcon_session_info(struct lst_sid __user *sid_up, int __user *key_up,
-		    unsigned __user *featp,
-		    struct lstcon_ndlist_ent __user *ndinfo_up,
-		    char __user *name_up, int len)
-{
-	struct lstcon_ndlist_ent *entp;
-	struct lstcon_ndlink *ndl;
-	int rc = 0;
-
-	if (console_session.ses_state != LST_SESSION_ACTIVE)
-		return -ESRCH;
-
-	entp = kzalloc(sizeof(*entp), GFP_NOFS);
-	if (!entp)
-		return -ENOMEM;
-
-	list_for_each_entry(ndl, &console_session.ses_ndl_list, ndl_link)
-		LST_NODE_STATE_COUNTER(ndl->ndl_node, entp);
-
-	if (copy_to_user(sid_up, &console_session.ses_id,
-			 sizeof(*sid_up)) ||
-	    copy_to_user(key_up, &console_session.ses_key,
-			 sizeof(*key_up)) ||
-	    copy_to_user(featp, &console_session.ses_features,
-			 sizeof(*featp)) ||
-	    copy_to_user(ndinfo_up, entp, sizeof(*entp)) ||
-	    copy_to_user(name_up, console_session.ses_name, len))
-		rc = -EFAULT;
-
-	kfree(entp);
+	console_session.ses_state = LST_SESSION_ACTIVE;
 
 	return rc;
 }
 
-int
-lstcon_session_end(void)
+int lstcon_session_end(void)
 {
 	struct lstcon_rpc_trans *trans;
 	struct lstcon_group *grp;
@@ -1907,9 +1871,10 @@ static void lstcon_group_ndlink_release(struct lstcon_group *,
 
 	mutex_lock(&console_session.ses_mutex);
 
-	jrep->join_sid = console_session.ses_id;
+	jrep->join_sid.ses_stamp = console_session.ses_id.ses_stamp;
+	jrep->join_sid.ses_nid = lnet_nid_to_nid4(&console_session.ses_id.ses_nid);
 
-	if (console_session.ses_id.ses_nid == LNET_NID_ANY) {
+	if (LNET_NID_IS_ANY(&console_session.ses_id.ses_nid)) {
 		jrep->join_status = ESRCH;
 		goto out;
 	}
@@ -2041,14 +2006,21 @@ static void lstcon_init_acceptor_service(void)
 		goto out;
 	}
 
+	rc = lstcon_init_netlink();
+	if (rc < 0)
+		goto out;
+
 	rc = blocking_notifier_chain_register(&libcfs_ioctl_list,
 					      &lstcon_ioctl_handler);
 
-	if (!rc) {
-		lstcon_rpc_module_init();
-		return 0;
+	if (rc < 0) {
+		lstcon_fini_netlink();
+		goto out;
 	}
 
+	lstcon_rpc_module_init();
+	return 0;
+
 out:
 	srpc_shutdown_service(&lstcon_acceptor_service);
 	srpc_remove_service(&lstcon_acceptor_service);
@@ -2067,6 +2039,7 @@ static void lstcon_init_acceptor_service(void)
 
 	blocking_notifier_chain_unregister(&libcfs_ioctl_list,
 					   &lstcon_ioctl_handler);
+	lstcon_fini_netlink();
 
 	mutex_lock(&console_session.ses_mutex);
 
diff --git a/net/lnet/selftest/console.h b/net/lnet/selftest/console.h
index 93aa515..dd416dc 100644
--- a/net/lnet/selftest/console.h
+++ b/net/lnet/selftest/console.h
@@ -136,36 +136,34 @@ struct lstcon_test {
 #define LST_CONSOLE_TIMEOUT	300	/* default console timeout */
 
 struct lstcon_session {
-	struct mutex	   ses_mutex;		/* only 1 thread in session */
-	struct lst_sid	   ses_id;		/* global session id */
-	int		   ses_key;		/* local session key */
-	int		   ses_state;		/* state of session */
-	int		   ses_timeout;		/* timeout in seconds */
-	time64_t	   ses_laststamp;	/* last operation stamp (secs) */
-	unsigned int	   ses_features;	/* tests features of the session */
-	unsigned int	   ses_feats_updated:1; /* features are synced with
-						 * remote test nodes
-						 */
-	unsigned int	   ses_force:1;		/* force creating */
-	unsigned int	   ses_shutdown:1;	/* session is shutting down */
-	unsigned int	   ses_expired:1;	/* console is timedout */
-	u64		   ses_id_cookie;	/* batch id cookie */
-	char		   ses_name[LST_NAME_SIZE];/* session name */
-	struct lstcon_rpc_trans
-			   *ses_ping;		/* session pinger */
-	struct stt_timer   ses_ping_timer;	/* timer for pinger */
-	struct lstcon_trans_stat
-			   ses_trans_stat;	/* transaction stats */
-
-	struct list_head   ses_trans_list;	/* global list of transaction */
-	struct list_head   ses_grp_list;	/* global list of groups */
-	struct list_head   ses_bat_list;	/* global list of batches */
-	struct list_head   ses_ndl_list;	/* global list of nodes */
-	struct list_head   *ses_ndl_hash;	/* hash table of nodes */
-
-	spinlock_t	   ses_rpc_lock;	/* serialize */
-	atomic_t	   ses_rpc_counter;	/* # of initialized RPCs */
-	struct list_head   ses_rpc_freelist;	/* idle console rpc */
+	struct mutex		ses_mutex;	/* only 1 thread in session */
+	struct lst_session_id	ses_id;		/* global session id */
+	u32			ses_key;	/* local session key */
+	int			ses_state;	/* state of session */
+	int			ses_timeout;	/* timeout in seconds */
+	time64_t		ses_laststamp;	/* last operation stamp (secs) */
+	unsigned int		ses_features;	/* tests features of the session */
+	unsigned int		ses_feats_updated:1; /* features are synced with
+						      * remote test nodes
+						      */
+	unsigned int		ses_force:1;	/* force creating */
+	unsigned int		ses_shutdown:1;	/* session is shutting down */
+	unsigned int		ses_expired:1;	/* console is timedout */
+	u64			ses_id_cookie;	/* batch id cookie */
+	char			ses_name[LST_NAME_SIZE];/* session name */
+	struct lstcon_rpc_trans *ses_ping;	/* session pinger */
+	struct stt_timer	ses_ping_timer;	/* timer for pinger */
+	struct lstcon_trans_stat ses_trans_stat;/* transaction stats */
+
+	struct list_head	ses_trans_list;	/* global list of transaction */
+	struct list_head	ses_grp_list;	/* global list of groups */
+	struct list_head	ses_bat_list;	/* global list of batches */
+	struct list_head	ses_ndl_list;	/* global list of nodes */
+	struct list_head	*ses_ndl_hash;	/* hash table of nodes */
+
+	spinlock_t		ses_rpc_lock;	/* serialize */
+	atomic_t		ses_rpc_counter;/* # of initialized RPCs */
+	struct list_head	ses_rpc_freelist;/* idle console rpc */
 }; /* session descriptor */
 
 extern struct lstcon_session	console_session;
@@ -186,14 +184,16 @@ struct lstcon_session {
 
 int lstcon_ioctl_entry(struct notifier_block *nb,
 		       unsigned long cmd, void *vdata);
+
+int lstcon_init_netlink(void);
+void lstcon_fini_netlink(void);
+
 int lstcon_console_init(void);
 int lstcon_console_fini(void);
+
 int lstcon_session_match(struct lst_sid sid);
 int lstcon_session_new(char *name, int key, unsigned int version,
-		       int timeout, int flags, struct lst_sid __user *sid_up);
-int lstcon_session_info(struct lst_sid __user *sid_up, int __user *key,
-			unsigned __user *verp, struct lstcon_ndlist_ent __user *entp,
-			char __user *name_up, int len);
+		       int timeout, int flags);
 int lstcon_session_end(void);
 int lstcon_session_debug(int timeout, struct list_head __user *result_up);
 int lstcon_session_feats_check(unsigned int feats);
diff --git a/net/lnet/selftest/framework.c b/net/lnet/selftest/framework.c
index e84904e..0dd0421 100644
--- a/net/lnet/selftest/framework.c
+++ b/net/lnet/selftest/framework.c
@@ -39,7 +39,7 @@
 
 #include "selftest.h"
 
-struct lst_sid LST_INVALID_SID = { .ses_nid = LNET_NID_ANY, .ses_stamp = -1 };
+struct lst_session_id LST_INVALID_SID = { .ses_nid = LNET_ANY_NID, .ses_stamp = -1};
 
 static int session_timeout = 100;
 module_param(session_timeout, int, 0444);
@@ -244,7 +244,7 @@
 	LASSERT(sn == sfw_data.fw_session);
 
 	CWARN("Session expired! sid: %s-%llu, name: %s\n",
-	      libcfs_nid2str(sn->sn_id.ses_nid),
+	      libcfs_nidstr(&sn->sn_id.ses_nid),
 	      sn->sn_id.ses_stamp, &sn->sn_name[0]);
 
 	sn->sn_timer_active = 0;
@@ -268,7 +268,8 @@
 	strlcpy(&sn->sn_name[0], name, sizeof(sn->sn_name));
 
 	sn->sn_timer_active = 0;
-	sn->sn_id = sid;
+	sn->sn_id.ses_stamp = sid.ses_stamp;
+	lnet_nid4_to_nid(sid.ses_nid, &sn->sn_id.ses_nid);
 	sn->sn_features = features;
 	sn->sn_timeout = session_timeout;
 	sn->sn_started = ktime_get();
@@ -357,6 +358,18 @@
 	return bat;
 }
 
+static struct lst_sid get_old_sid(struct sfw_session *sn)
+{
+	struct lst_sid sid = { .ses_nid = LNET_NID_ANY, .ses_stamp = -1 };
+
+	if (sn) {
+		sid.ses_stamp = sn->sn_id.ses_stamp;
+		sid.ses_nid = lnet_nid_to_nid4(&sn->sn_id.ses_nid);
+	}
+
+	return sid;
+}
+
 static int
 sfw_get_stats(struct srpc_stat_reqst *request, struct srpc_stat_reply *reply)
 {
@@ -364,7 +377,7 @@
 	struct sfw_counters *cnt = &reply->str_fw;
 	struct sfw_batch *bat;
 
-	reply->str_sid = !sn ? LST_INVALID_SID : sn->sn_id;
+	reply->str_sid = get_old_sid(sn);
 
 	if (request->str_sid.ses_nid == LNET_NID_ANY) {
 		reply->str_status = EINVAL;
@@ -407,14 +420,14 @@
 	int cplen = 0;
 
 	if (request->mksn_sid.ses_nid == LNET_NID_ANY) {
-		reply->mksn_sid = !sn ? LST_INVALID_SID : sn->sn_id;
+		reply->mksn_sid = get_old_sid(sn);
 		reply->mksn_status = EINVAL;
 		return 0;
 	}
 
 	if (sn) {
 		reply->mksn_status = 0;
-		reply->mksn_sid = sn->sn_id;
+		reply->mksn_sid = get_old_sid(sn);
 		reply->mksn_timeout = sn->sn_timeout;
 
 		if (sfw_sid_equal(request->mksn_sid, sn->sn_id)) {
@@ -464,7 +477,7 @@
 	spin_unlock(&sfw_data.fw_lock);
 
 	reply->mksn_status = 0;
-	reply->mksn_sid = sn->sn_id;
+	reply->mksn_sid = get_old_sid(sn);
 	reply->mksn_timeout = sn->sn_timeout;
 	return 0;
 }
@@ -475,7 +488,7 @@
 {
 	struct sfw_session *sn = sfw_data.fw_session;
 
-	reply->rmsn_sid = !sn ? LST_INVALID_SID : sn->sn_id;
+	reply->rmsn_sid = get_old_sid(sn);
 
 	if (request->rmsn_sid.ses_nid == LNET_NID_ANY) {
 		reply->rmsn_status = EINVAL;
@@ -497,7 +510,7 @@
 	spin_unlock(&sfw_data.fw_lock);
 
 	reply->rmsn_status = 0;
-	reply->rmsn_sid = LST_INVALID_SID;
+	reply->rmsn_sid = get_old_sid(NULL);
 	LASSERT(!sfw_data.fw_session);
 	return 0;
 }
@@ -510,12 +523,12 @@
 
 	if (!sn) {
 		reply->dbg_status = ESRCH;
-		reply->dbg_sid = LST_INVALID_SID;
+		reply->dbg_sid = get_old_sid(NULL);
 		return 0;
 	}
 
 	reply->dbg_status = 0;
-	reply->dbg_sid = sn->sn_id;
+	reply->dbg_sid = get_old_sid(sn);
 	reply->dbg_timeout = sn->sn_timeout;
 	if (strlcpy(reply->dbg_name, &sn->sn_name[0], sizeof(reply->dbg_name))
 	    >= sizeof(reply->dbg_name))
@@ -1119,7 +1132,7 @@
 	struct sfw_batch *bat;
 
 	request = &rpc->srpc_reqstbuf->buf_msg.msg_body.tes_reqst;
-	reply->tsr_sid = !sn ? LST_INVALID_SID : sn->sn_id;
+	reply->tsr_sid = get_old_sid(sn);
 
 	if (!request->tsr_loop ||
 	    !request->tsr_concur ||
@@ -1187,7 +1200,7 @@
 	int rc = 0;
 	struct sfw_batch *bat;
 
-	reply->bar_sid = !sn ? LST_INVALID_SID : sn->sn_id;
+	reply->bar_sid = get_old_sid(sn);
 
 	if (!sn || !sfw_sid_equal(request->bar_sid, sn->sn_id)) {
 		reply->bar_status = ESRCH;
@@ -1266,7 +1279,9 @@
 			CNETERR("Features of framework RPC don't match features of current session: %x/%x\n",
 				request->msg_ses_feats, sn->sn_features);
 			reply->msg_body.reply.status = EPROTO;
-			reply->msg_body.reply.sid = sn->sn_id;
+			reply->msg_body.reply.sid.ses_stamp = sn->sn_id.ses_stamp;
+			reply->msg_body.reply.sid.ses_nid =
+				lnet_nid_to_nid4(&sn->sn_id.ses_nid);
 			goto out;
 		}
 
diff --git a/net/lnet/selftest/selftest.h b/net/lnet/selftest/selftest.h
index 223a432..5bffe73 100644
--- a/net/lnet/selftest/selftest.h
+++ b/net/lnet/selftest/selftest.h
@@ -49,6 +49,39 @@
 #define MADE_WITHOUT_COMPROMISE
 #endif
 
+/* enum lnet_selftest_session_attrs   - LNet selftest session Netlink
+ *					attributes
+ *
+ * @LNET_SELFTEST_SESSION_UNSPEC:	unspecified attribute to catch errors
+ * @LNET_SELFTEST_SESSION_PAD:		padding for 64-bit attributes, ignore
+ *
+ * @LENT_SELFTEST_SESSION_HDR:		Netlink group this data is for
+ *					(NLA_NUL_STRING)
+ * @LNET_SELFTEST_SESSION_NAME:	name of this session (NLA_STRING)
+ * @LNET_SELFTEST_SESSION_KEY:		key used to represent the session
+ *					(NLA_U32)
+ * @LNET_SELFTEST_SESSION_TIMESTAMP:	timestamp when the session was created
+ *					(NLA_S64)
+ * @LNET_SELFTEST_SESSION_NID:		NID of the node selftest ran on
+ *					(NLA_STRING)
+ * @LNET_SELFTEST_SESSION_NODE_COUNT:	Number of nodes in use (NLA_U16)
+ */
+enum lnet_selftest_session_attrs {
+	LNET_SELFTEST_SESSION_UNSPEC = 0,
+	LNET_SELFTEST_SESSION_PAD = LNET_SELFTEST_SESSION_UNSPEC,
+
+	LNET_SELFTEST_SESSION_HDR,
+	LNET_SELFTEST_SESSION_NAME,
+	LNET_SELFTEST_SESSION_KEY,
+	LNET_SELFTEST_SESSION_TIMESTAMP,
+	LNET_SELFTEST_SESSION_NID,
+	LNET_SELFTEST_SESSION_NODE_COUNT,
+
+	__LNET_SELFTEST_SESSION_MAX_PLUS_ONE,
+};
+
+#define LNET_SELFTEST_SESSION_MAX	(__LNET_SELFTEST_SESSION_MAX_PLUS_ONE - 1)
+
 #define SWI_STATE_NEWBORN		0
 #define SWI_STATE_REPLY_SUBMITTED	1
 #define SWI_STATE_REPLY_SENT		2
@@ -318,23 +351,40 @@ struct srpc_service {
 	int (*sv_bulk_ready)(struct srpc_server_rpc *, int);
 };
 
+struct lst_session_id {
+	s64			ses_stamp;	/* time stamp in milliseconds */
+	struct lnet_nid		ses_nid;	/* nid of console node */
+};						/*** session id (large addr) */
+
+extern struct lst_session_id LST_INVALID_SID;
+
 struct sfw_session {
-	struct list_head sn_list;    /* chain on fw_zombie_sessions */
-	struct lst_sid	 sn_id;      /* unique identifier */
-	unsigned int	 sn_timeout; /* # seconds' inactivity to expire */
-	int		 sn_timer_active;
-	unsigned int	 sn_features;
-	struct stt_timer      sn_timer;
-	struct list_head sn_batches; /* list of batches */
-	char		 sn_name[LST_NAME_SIZE];
-	atomic_t	 sn_refcount;
-	atomic_t	 sn_brw_errors;
-	atomic_t	 sn_ping_errors;
-	ktime_t		 sn_started;
+	/* chain on fw_zombie_sessions */
+	struct list_head	sn_list;
+	struct lst_session_id	sn_id;		/* unique identifier */
+	/* # seconds' inactivity to expire */
+	unsigned int		sn_timeout;
+	int			sn_timer_active;
+	unsigned int		sn_features;
+	struct stt_timer	sn_timer;
+	struct list_head	sn_batches; /* list of batches */
+	char			sn_name[LST_NAME_SIZE];
+	atomic_t		sn_refcount;
+	atomic_t		sn_brw_errors;
+	atomic_t		sn_ping_errors;
+	ktime_t			sn_started;
 };
 
-#define sfw_sid_equal(sid0, sid1)     ((sid0).ses_nid == (sid1).ses_nid && \
-				       (sid0).ses_stamp == (sid1).ses_stamp)
+static inline int sfw_sid_equal(struct lst_sid sid0,
+				struct lst_session_id sid1)
+{
+	struct lnet_nid ses_nid;
+
+	lnet_nid4_to_nid(sid0.ses_nid, &ses_nid);
+
+	return ((sid0.ses_stamp == sid1.ses_stamp) &&
+		nid_same(&ses_nid, &sid1.ses_nid));
+}
 
 struct sfw_batch {
 	struct list_head bat_list;	/* chain on sn_batches */
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
