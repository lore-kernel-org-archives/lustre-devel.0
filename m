Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 19040C433FE
	for <lustre-devel@archiver.kernel.org>; Fri, 14 Oct 2022 21:38:47 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4Mq0BZ5bVWz1y56;
	Fri, 14 Oct 2022 14:38:46 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4Mq0B75Vxtz21GQ
 for <lustre-devel@lists.lustre.org>; Fri, 14 Oct 2022 14:38:23 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 1540210084DE;
 Fri, 14 Oct 2022 17:38:14 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 11F44DD6ED; Fri, 14 Oct 2022 17:38:14 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Fri, 14 Oct 2022 17:38:03 -0400
Message-Id: <1665783491-13827-13-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1665783491-13827-1-git-send-email-jsimmons@infradead.org>
References: <1665783491-13827-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 12/20] lustre: obdclass: user netlink to
 collect devices information
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

Our utilities can report to users a device list with various bits
of data using the debugfs file 'devices'. This debugfs file is
only by default available to root which prevents regular users
from collecting information. Enable non-root users to collect
the same information for lctl dl using netlink. The advantage of
using netlink is that it also removes the 8K ioctl limit. Add the
ability to present this data in YAML format as well.

WC-bug-id: https://jira.whamcloud.com/browse/LU-9680
Lustre-commit: 86ba46c24430f67bb ("LU-9680 obdclass: user netlink to collect devices information")
Signed-off-by: James Simmons <jsimmons@infradead.org>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/31618
Reviewed-by: Jian Yu <yujian@whamcloud.com>
Reviewed-by: Neil Brown <neilb@suse.de>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
---
 fs/lustre/include/lustre_kernelcomm.h         |  37 ++-
 fs/lustre/obdclass/class_obd.c                |  14 +-
 fs/lustre/obdclass/kernelcomm.c               | 257 +++++++++++++++++-
 include/uapi/linux/lustre/lustre_kernelcomm.h |  18 ++
 4 files changed, 315 insertions(+), 11 deletions(-)

diff --git a/fs/lustre/include/lustre_kernelcomm.h b/fs/lustre/include/lustre_kernelcomm.h
index bd5376b2a672..db725ab8a0f9 100644
--- a/fs/lustre/include/lustre_kernelcomm.h
+++ b/fs/lustre/include/lustre_kernelcomm.h
@@ -41,11 +41,46 @@
 /* For declarations shared with userspace */
 #include <uapi/linux/lustre/lustre_kernelcomm.h>
 
+/**
+ * enum lustre_device_attrs	      - Lustre general top-level netlink
+ *					attributes that describe lustre
+ *					'devices'. These values are used
+ *					to piece togther messages for
+ *					sending and receiving.
+ *
+ * @LUSTRE_DEVICE_ATTR_UNSPEC:		unspecified attribute to catch errors
+ *
+ * @LUSTRE_DEVICE_ATTR_HDR:		Netlink group this data is for
+ *					(NLA_NUL_STRING)
+ * @LUSTRE_DEVICE_ATTR_INDEX:		device number used as an index (NLA_U16)
+ * @LUSTRE_DEVICE_ATTR_STATUS:		status of the device (NLA_STRING)
+ * @LUSTRE_DEVICE_ATTR_CLASS:		class the device belongs to (NLA_STRING)
+ * @LUSTRE_DEVICE_ATTR_NAME:		name of the device (NLA_STRING)
+ * @LUSTRE_DEVICE_ATTR_UUID:		UUID of the device (NLA_STRING)
+ * @LUSTRE_DEVICE_ATTR_REFCOUNT:	refcount of the device (NLA_U32)
+ */
+enum lustre_device_attrs {
+	LUSTRE_DEVICE_ATTR_UNSPEC = 0,
+
+	LUSTRE_DEVICE_ATTR_HDR,
+	LUSTRE_DEVICE_ATTR_INDEX,
+	LUSTRE_DEVICE_ATTR_STATUS,
+	LUSTRE_DEVICE_ATTR_CLASS,
+	LUSTRE_DEVICE_ATTR_NAME,
+	LUSTRE_DEVICE_ATTR_UUID,
+	LUSTRE_DEVICE_ATTR_REFCOUNT,
+
+	__LUSTRE_DEVICE_ATTR_MAX_PLUS_ONE
+};
+
+#define LUSTRE_DEVICE_ATTR_MAX (__LUSTRE_DEVICE_ATTR_MAX_PLUS_ONE - 1)
+
 /* prototype for callback function on kuc groups */
 typedef int (*libcfs_kkuc_cb_t)(void *data, void *cb_arg);
 
 /* Kernel methods */
-void libcfs_kkuc_init(void);
+int libcfs_kkuc_init(void);
+void libcfs_kkuc_fini(void);
 int libcfs_kkuc_group_put(const struct obd_uuid *uuid, int group, void *data);
 int libcfs_kkuc_group_add(struct file *fp, const struct obd_uuid *uuid, int uid,
 			  int group, void *data, size_t data_len);
diff --git a/fs/lustre/obdclass/class_obd.c b/fs/lustre/obdclass/class_obd.c
index f455ed752c15..67a94222a664 100644
--- a/fs/lustre/obdclass/class_obd.c
+++ b/fs/lustre/obdclass/class_obd.c
@@ -671,15 +671,17 @@ static int __init obdclass_init(void)
 	if (err)
 		return err;
 
-	libcfs_kkuc_init();
+	err = obd_init_checks();
+	if (err)
+		return err;
 
-	err = obd_zombie_impexp_init();
+	err = libcfs_kkuc_init();
 	if (err)
 		return err;
 
-	err = obd_init_checks();
+	err = obd_zombie_impexp_init();
 	if (err)
-		goto cleanup_zombie_impexp;
+		goto cleanup_kkuc;
 
 	err = class_handle_init();
 	if (err)
@@ -754,6 +756,9 @@ static int __init obdclass_init(void)
 cleanup_zombie_impexp:
 	obd_zombie_impexp_stop();
 
+cleanup_kkuc:
+	libcfs_kkuc_fini();
+
 	return err;
 }
 
@@ -771,6 +776,7 @@ static void obdclass_exit(void)
 	class_handle_cleanup();
 	class_del_uuid(NULL); /* Delete all UUIDs. */
 	obd_zombie_impexp_stop();
+	libcfs_kkuc_fini();
 }
 
 void obd_heat_clear(struct obd_heat_instance *instance, int count)
diff --git a/fs/lustre/obdclass/kernelcomm.c b/fs/lustre/obdclass/kernelcomm.c
index e59b6aadf097..5682d4e1ab53 100644
--- a/fs/lustre/obdclass/kernelcomm.c
+++ b/fs/lustre/obdclass/kernelcomm.c
@@ -38,16 +38,254 @@
 #define DEBUG_SUBSYSTEM S_CLASS
 
 #include <linux/file.h>
-#include <linux/libcfs/libcfs.h>
+#include <linux/glob.h>
+#include <net/genetlink.h>
+#include <net/sock.h>
+
+#include <obd_class.h>
 #include <obd_support.h>
 #include <lustre_kernelcomm.h>
 
+static struct genl_family lustre_family;
+
+static struct ln_key_list device_list = {
+	.lkl_maxattr			= LUSTRE_DEVICE_ATTR_MAX,
+	.lkl_list			= {
+		[LUSTRE_DEVICE_ATTR_HDR]	= {
+			.lkp_value		= "devices",
+			.lkp_key_format		= LNKF_SEQUENCE | LNKF_MAPPING,
+			.lkp_data_type		= NLA_NUL_STRING,
+		},
+		[LUSTRE_DEVICE_ATTR_INDEX]	= {
+			.lkp_value		= "index",
+			.lkp_data_type		= NLA_U16
+		},
+		[LUSTRE_DEVICE_ATTR_STATUS]	= {
+			.lkp_value		= "status",
+			.lkp_data_type		= NLA_STRING
+		},
+		[LUSTRE_DEVICE_ATTR_CLASS]	= {
+			.lkp_value		= "type",
+			.lkp_data_type		= NLA_STRING
+		},
+		[LUSTRE_DEVICE_ATTR_NAME]	= {
+			.lkp_value		= "name",
+			.lkp_data_type		= NLA_STRING
+		},
+		[LUSTRE_DEVICE_ATTR_UUID]	= {
+			.lkp_value		= "uuid",
+			.lkp_data_type		= NLA_STRING
+		},
+		[LUSTRE_DEVICE_ATTR_REFCOUNT]	= {
+			.lkp_value		= "refcount",
+			.lkp_data_type		= NLA_U32
+		},
+	},
+};
+
+struct genl_dev_list {
+	struct obd_device	*gdl_target;
+	unsigned int		gdl_start;
+};
+
+static inline struct genl_dev_list *
+device_dump_ctx(struct netlink_callback *cb)
+{
+	return (struct genl_dev_list *)cb->args[0];
+}
+
+/* generic ->start() handler for GET requests */
+static int lustre_device_list_start(struct netlink_callback *cb)
+{
+	struct genlmsghdr *gnlh = nlmsg_data(cb->nlh);
+	struct netlink_ext_ack *extack = cb->extack;
+	struct genl_dev_list *glist;
+	int msg_len, rc = 0;
+
+	glist = kmalloc(sizeof(*glist), GFP_KERNEL);
+	if (!glist)
+		return -ENOMEM;
+
+	cb->args[0] = (long)glist;
+	glist->gdl_target = NULL;
+	glist->gdl_start = 0;
+
+	msg_len = genlmsg_len(gnlh);
+	if (msg_len > 0) {
+		struct nlattr *params = genlmsg_data(gnlh);
+		struct nlattr *dev;
+		int rem;
+
+		nla_for_each_attr(dev, params, msg_len, rem) {
+			struct nlattr *prop;
+			int rem2;
+
+			nla_for_each_nested(prop, dev, rem2) {
+				char name[MAX_OBD_NAME];
+				struct obd_device *obd;
+
+				if (nla_type(prop) != LN_SCALAR_ATTR_VALUE ||
+				    nla_strcmp(prop, "name") != 0)
+					continue;
+
+				prop = nla_next(prop, &rem2);
+				if (nla_type(prop) != LN_SCALAR_ATTR_VALUE) {
+					rc = -EINVAL;
+					goto report_err;
+				}
+
+				rc = nla_strlcpy(name, prop, sizeof(name));
+				if (rc < 0)
+					goto report_err;
+				rc = 0;
+
+				obd = class_name2obd(name);
+				if (obd)
+					glist->gdl_target = obd;
+			}
+		}
+		if (!glist->gdl_target) {
+			NL_SET_ERR_MSG(extack, "No devices found");
+			rc = -ENOENT;
+		}
+	}
+report_err:
+	if (rc < 0) {
+		kfree(glist);
+		cb->args[0] = 0;
+	}
+	return rc;
+}
+
+static int lustre_device_list_dump(struct sk_buff *msg,
+				   struct netlink_callback *cb)
+{
+	struct genl_dev_list *glist = device_dump_ctx(cb);
+	struct obd_device *filter = glist->gdl_target;
+	struct netlink_ext_ack *extack = cb->extack;
+	int portid = NETLINK_CB(cb->skb).portid;
+	int seq = cb->nlh->nlmsg_seq;
+	int idx, rc = 0;
+
+	if (glist->gdl_start == 0) {
+		const struct ln_key_list *all[] = {
+			&device_list, NULL
+		};
+
+		rc = lnet_genl_send_scalar_list(msg, portid, seq,
+						&lustre_family,
+						NLM_F_CREATE | NLM_F_MULTI,
+						LUSTRE_CMD_DEVICES, all);
+		if (rc < 0) {
+			NL_SET_ERR_MSG(extack, "failed to send key table");
+			return rc;
+		}
+	}
+
+	for (idx = glist->gdl_start; idx < class_devno_max(); idx++) {
+		struct obd_device *obd;
+		const char *status;
+		void *hdr;
+
+		obd = class_num2obd(idx);
+		if (!obd)
+			continue;
+
+		if (filter && filter != obd)
+			continue;
+
+		hdr = genlmsg_put(msg, portid, seq, &lustre_family,
+				  NLM_F_MULTI, LUSTRE_CMD_DEVICES);
+		if (!hdr) {
+			NL_SET_ERR_MSG(extack, "failed to send values");
+			genlmsg_cancel(msg, hdr);
+			rc = -EMSGSIZE;
+			break;
+		}
+
+		if (idx == 0)
+			nla_put_string(msg, LUSTRE_DEVICE_ATTR_HDR, "");
+
+		nla_put_u16(msg, LUSTRE_DEVICE_ATTR_INDEX, obd->obd_minor);
+
+		/* Collect only the index value for a single obd */
+		if (filter) {
+			genlmsg_end(msg, hdr);
+			idx++;
+			break;
+		}
+
+		if (obd->obd_stopping)
+			status = "ST";
+		else if (obd->obd_inactive)
+			status = "IN";
+		else if (obd->obd_set_up)
+			status = "UP";
+		else if (obd->obd_attached)
+			status = "AT";
+		else
+			status = "--";
+
+		nla_put_string(msg, LUSTRE_DEVICE_ATTR_STATUS, status);
+
+		nla_put_string(msg, LUSTRE_DEVICE_ATTR_CLASS,
+			       obd->obd_type->typ_name);
+
+		nla_put_string(msg, LUSTRE_DEVICE_ATTR_NAME,
+			       obd->obd_name);
+
+		nla_put_string(msg, LUSTRE_DEVICE_ATTR_UUID,
+			       obd->obd_uuid.uuid);
+
+		nla_put_u32(msg, LUSTRE_DEVICE_ATTR_REFCOUNT,
+			    atomic_read(&obd->obd_refcount));
+
+		genlmsg_end(msg, hdr);
+	}
+
+	glist->gdl_start = idx;
+	return rc < 0 ? rc : msg->len;
+}
+
+int lustre_device_done(struct netlink_callback *cb)
+{
+	struct genl_dev_list *glist;
+
+	glist = device_dump_ctx(cb);
+	kfree(glist);
+	cb->args[0] = 0;
+
+	return 0;
+}
+
+static const struct genl_multicast_group lustre_mcast_grps[] = {
+	{ .name		= "devices",		},
+};
+
+static const struct genl_ops lustre_genl_ops[] = {
+	{
+		.cmd		= LUSTRE_CMD_DEVICES,
+		.start		= lustre_device_list_start,
+		.dumpit		= lustre_device_list_dump,
+		.done		= lustre_device_done,
+	},
+};
+
+static struct genl_family lustre_family = {
+	.name		= LUSTRE_GENL_NAME,
+	.version	= LUSTRE_GENL_VERSION,
+	.module		= THIS_MODULE,
+	.ops		= lustre_genl_ops,
+	.n_ops		= ARRAY_SIZE(lustre_genl_ops),
+	.mcgrps		= lustre_mcast_grps,
+	.n_mcgrps	= ARRAY_SIZE(lustre_mcast_grps),
+};
+
 /**
  * libcfs_kkuc_msg_put - send an message from kernel to userspace
- *
- * @fp:		to send the message to
- * @payload:	Payload data. First field of payload is always
- *		struct kuc_hdr
+ * @param fp	to send the message to
+ * @param payload Payload data. First field of payload is always
+ *  struct kuc_hdr
  */
 static int libcfs_kkuc_msg_put(struct file *filp, void *payload)
 {
@@ -104,12 +342,19 @@ static inline bool libcfs_kkuc_group_is_valid(unsigned int group)
 	return group < ARRAY_SIZE(kkuc_groups);
 }
 
-void libcfs_kkuc_init(void)
+int libcfs_kkuc_init(void)
 {
 	int group;
 
 	for (group = 0; group < ARRAY_SIZE(kkuc_groups); group++)
 		INIT_LIST_HEAD(&kkuc_groups[group]);
+
+	return genl_register_family(&lustre_family);
+}
+
+void libcfs_kkuc_fini(void)
+{
+	genl_unregister_family(&lustre_family);
 }
 
 /** Add a receiver to a broadcast group
diff --git a/include/uapi/linux/lustre/lustre_kernelcomm.h b/include/uapi/linux/lustre/lustre_kernelcomm.h
index 744eeb674f72..91bb686d33e9 100644
--- a/include/uapi/linux/lustre/lustre_kernelcomm.h
+++ b/include/uapi/linux/lustre/lustre_kernelcomm.h
@@ -39,6 +39,24 @@
 
 #include <linux/types.h>
 
+#define LUSTRE_GENL_NAME		"lustre"
+#define LUSTRE_GENL_VERSION		0x1
+
+/*
+ * enum lustre_commands		      - Supported Lustre Netlink commands
+ *
+ * @LUSTRE_CMD_UNSPEC:			unspecified command to catch errors
+ * @LUSTRE_CMD_DEVICES:			command to manage the Lustre devices
+ */
+enum lustre_commands {
+	LUSTRE_CMD_UNSPEC	= 0,
+	LUSTRE_CMD_DEVICES	= 1,
+
+	__LUSTRE_CMD_MAX_PLUS_ONE
+};
+
+#define LUSTRE_CMD_MAX	(__LUSTRE_CMD_MAX_PLUS_ONE - 1)
+
 /* KUC message header.
  * All current and future KUC messages should use this header.
  * To avoid having to include Lustre headers from libcfs, define this here.
-- 
2.27.0

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
