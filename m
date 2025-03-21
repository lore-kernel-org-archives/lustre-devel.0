Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id C3DF3C36001
	for <lustre-devel@archiver.kernel.org>; Fri, 21 Mar 2025 13:33:27 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4ZK2t35bzSz20y0;
	Fri, 21 Mar 2025 06:12:27 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4ZK2nW0DtQz1y66
 for <lustre-devel@lists.lustre.org>; Fri, 21 Mar 2025 06:08:30 -0700 (PDT)
Received: from star2.ccs.ornl.gov (ltm4-e204-208.ccs.ornl.gov [160.91.203.22])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 967B017B5A9;
 Fri, 21 Mar 2025 09:07:14 -0400 (EDT)
Received: by star2.ccs.ornl.gov (Postfix, from userid 2004)
 id 934A7106BE14; Fri, 21 Mar 2025 09:07:14 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Fri, 21 Mar 2025 09:07:02 -0400
Message-ID: <20250321130711.3257092-20-jsimmons@infradead.org>
X-Mailer: git-send-email 2.43.5
In-Reply-To: <20250321130711.3257092-1-jsimmons@infradead.org>
References: <20250321130711.3257092-1-jsimmons@infradead.org>
MIME-Version: 1.0
Subject: [lustre-devel] [PATCH 19/27] lnet: libcfs: move ioctl device to lnet
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
Cc: Chris Horn <chris.horn@hpe.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Mr NeilBrown <neilb@suse.de>

The misc device "/dev/lnet" is currently managed in libcfs code,
despite that fact that it is named "lnet" and almost all ioctl
handlers are in lnet code.

So move the management of the device to lnet code, leaving just
the minimal amount in libcfs:
        case IOC_LIBCFS_CLEAR_DEBUG:
        case IOC_LIBCFS_MARK_DEBUG:

Also rename various parts of the interface from libcfs_ioctl* to
lnet_ioctl*.
ioctl names, data structures, and include files are left unchanged for
now.

Note that the return value from LNetCtl() was previously passed
through notifier_from_errno() and notifier_to_errno().  This had the
effect of turning any positive value to zero.  We need to preserve
that and not return positive results.  PING would return a positive
result.  lnd->lnd_ctl probably doesn't, but due to the difficulty of
auditing, it is safer to always force the result to non-positive.

WC-bug-id: https://jira.whamcloud.com/browse/LU-9859
Lustre-commit: 2d4d7febb124686d4 ("LU-9859 lnet: move ioctl device to lnet")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/50833
Reviewed-by: Chris Horn <chris.horn@hpe.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/libcfs/libcfs.h          |  12 +-
 include/linux/lnet/lib-lnet.h          |   9 +
 include/uapi/linux/lnet/libcfs_ioctl.h |  10 +-
 net/lnet/libcfs/module.c               | 232 +------------------------
 net/lnet/lnet/api-ni.c                 |   3 +-
 net/lnet/lnet/module.c                 | 220 +++++++++++++++++++++--
 net/lnet/selftest/console.c            |   4 +-
 7 files changed, 228 insertions(+), 262 deletions(-)

diff --git a/include/linux/libcfs/libcfs.h b/include/linux/libcfs/libcfs.h
index e29b007946ff..2490ee811d33 100644
--- a/include/linux/libcfs/libcfs.h
+++ b/include/linux/libcfs/libcfs.h
@@ -33,10 +33,9 @@
 #ifndef __LIBCFS_LIBCFS_H__
 #define __LIBCFS_LIBCFS_H__
 
-#include <linux/notifier.h>
 #include <linux/workqueue.h>
-#include <linux/sysctl.h>
 
+#include <uapi/linux/lnet/libcfs_ioctl.h>
 #include <linux/libcfs/libcfs_debug.h>
 #include <linux/libcfs/libcfs_private.h>
 #include <linux/libcfs/libcfs_fail.h>
@@ -45,15 +44,8 @@
 
 typedef s32 timeout_t;
 
-extern struct blocking_notifier_head libcfs_ioctl_list;
-static inline int notifier_from_ioctl_errno(int err)
-{
-	if (err == -EINVAL)
-		return NOTIFY_OK;
-	return notifier_from_errno(err) | NOTIFY_STOP_MASK;
-}
-
 int libcfs_setup(void);
+int libcfs_ioctl(unsigned int cmd, struct libcfs_ioctl_data *data);
 
 extern struct workqueue_struct *cfs_rehash_wq;
 
diff --git a/include/linux/lnet/lib-lnet.h b/include/linux/lnet/lib-lnet.h
index ce4ad5ae7eb7..ffe887525dc9 100644
--- a/include/linux/lnet/lib-lnet.h
+++ b/include/linux/lnet/lib-lnet.h
@@ -1225,4 +1225,13 @@ lnet_set_route_aliveness(struct lnet_route *route, bool alive)
 		       alive ? "up" : "down");
 }
 void lnet_update_ping_buffer(void);
+
+extern struct blocking_notifier_head lnet_ioctl_list;
+static inline int notifier_from_ioctl_errno(int err)
+{
+	if (err == -EINVAL)
+		return NOTIFY_OK;
+	return notifier_from_errno(err) | NOTIFY_STOP_MASK;
+}
+
 #endif
diff --git a/include/uapi/linux/lnet/libcfs_ioctl.h b/include/uapi/linux/lnet/libcfs_ioctl.h
index 2a067cdafc48..7a3a6f8f507e 100644
--- a/include/uapi/linux/lnet/libcfs_ioctl.h
+++ b/include/uapi/linux/lnet/libcfs_ioctl.h
@@ -36,8 +36,8 @@
  *
  */
 
-#ifndef __LIBCFS_IOCTL_H__
-#define __LIBCFS_IOCTL_H__
+#ifndef __UAPI_LIBCFS_IOCTL_H__
+#define __UAPI_LIBCFS_IOCTL_H__
 
 #include <linux/types.h>
 #include <linux/ioctl.h>
@@ -49,8 +49,8 @@
 #define __user
 #endif
 
-#define LIBCFS_IOCTL_VERSION	0x0001000a
-#define LIBCFS_IOCTL_VERSION2	0x0001000b
+#define LNET_IOCTL_VERSION 0x0001000a
+#define LNET_IOCTL_VERSION2 0x0001000b
 
 struct libcfs_ioctl_hdr {
 	__u32 ioc_len;
@@ -159,4 +159,4 @@ struct libcfs_ioctl_data {
 #define IOC_LIBCFS_SET_PEER		_IOWR(IOC_LIBCFS_TYPE, 112, IOCTL_CONFIG_SIZE)
 #define IOC_LIBCFS_MAX_NR				       112
 
-#endif /* __LIBCFS_IOCTL_H__ */
+#endif /* __UAPI_LIBCFS_IOCTL_H__ */
diff --git a/net/lnet/libcfs/module.c b/net/lnet/libcfs/module.c
index 17cb8e4b818f..a8110af3c99f 100644
--- a/net/lnet/libcfs/module.c
+++ b/net/lnet/libcfs/module.c
@@ -29,7 +29,6 @@
 /*
  * This file is part of Lustre, http://www.lustre.org/
  */
-#include <linux/miscdevice.h>
 #include <linux/module.h>
 #include <linux/kernel.h>
 #include <linux/mm.h>
@@ -65,230 +64,26 @@ struct lnet_debugfs_symlink_def {
 
 static struct dentry *lnet_debugfs_root;
 
-BLOCKING_NOTIFIER_HEAD(libcfs_ioctl_list);
-EXPORT_SYMBOL(libcfs_ioctl_list);
-
-static inline size_t libcfs_ioctl_packlen(struct libcfs_ioctl_data *data)
-{
-	size_t len = sizeof(*data);
-
-	len += round_up(data->ioc_inllen1, 8);
-	len += round_up(data->ioc_inllen2, 8);
-	return len;
-}
-
-static inline bool libcfs_ioctl_is_invalid(struct libcfs_ioctl_data *data)
-{
-	const int maxlen = 1 << 30;
-
-	if (data->ioc_hdr.ioc_len > maxlen)
-		return true;
-
-	if (data->ioc_inllen1 > maxlen)
-		return true;
-
-	if (data->ioc_inllen2 > maxlen)
-		return true;
-
-	if (data->ioc_inlbuf1 && !data->ioc_inllen1) {
-		CERROR("LIBCFS ioctl: inlbuf1 pointer but 0 length\n");
-		return true;
-	}
-	if (data->ioc_inlbuf2 && !data->ioc_inllen2) {
-		CERROR("LIBCFS ioctl: inlbuf2 pointer but 0 length\n");
-		return true;
-	}
-	if (data->ioc_pbuf1 && !data->ioc_plen1) {
-		CERROR("LIBCFS ioctl: pbuf1 pointer but 0 length\n");
-		return true;
-	}
-	if (data->ioc_pbuf2 && !data->ioc_plen2) {
-		CERROR("LIBCFS ioctl: pbuf2 pointer but 0 length\n");
-		return true;
-	}
-	if (data->ioc_plen1 && !data->ioc_pbuf1) {
-		CERROR("LIBCFS ioctl: plen1 nonzero but no pbuf1 pointer\n");
-		return true;
-	}
-	if (data->ioc_plen2 && !data->ioc_pbuf2) {
-		CERROR("LIBCFS ioctl: plen2 nonzero but no pbuf2 pointer\n");
-		return true;
-	}
-	if ((u32)libcfs_ioctl_packlen(data) != data->ioc_hdr.ioc_len) {
-		CERROR("LIBCFS ioctl: packlen != ioc_len\n");
-		return true;
-	}
-	if (data->ioc_inllen1 &&
-	    data->ioc_bulk[data->ioc_inllen1 - 1] != '\0') {
-		CERROR("LIBCFS ioctl: inlbuf1 not 0 terminated\n");
-		return true;
-	}
-	if (data->ioc_inllen2 &&
-	    data->ioc_bulk[round_up(data->ioc_inllen1, 8) +
-			   data->ioc_inllen2 - 1] != '\0') {
-		CERROR("LIBCFS ioctl: inlbuf2 not 0 terminated\n");
-		return true;
-	}
-	return false;
-}
-
-static int libcfs_ioctl_data_adjust(struct libcfs_ioctl_data *data)
-{
-	if (libcfs_ioctl_is_invalid(data)) {
-		CERROR("libcfs ioctl: parameter not correctly formatted\n");
-		return -EINVAL;
-	}
-
-	if (data->ioc_inllen1)
-		data->ioc_inlbuf1 = &data->ioc_bulk[0];
-
-	if (data->ioc_inllen2)
-		data->ioc_inlbuf2 = &data->ioc_bulk[0] +
-				    round_up(data->ioc_inllen1, 8);
-
-	return 0;
-}
-
-static int libcfs_ioctl_getdata(struct libcfs_ioctl_hdr **hdr_pp,
-				const struct libcfs_ioctl_hdr __user *uhdr)
-{
-	struct libcfs_ioctl_hdr hdr;
-	int err;
-
-	if (copy_from_user(&hdr, uhdr, sizeof(hdr)))
-		return -EFAULT;
-
-	if (hdr.ioc_version != LIBCFS_IOCTL_VERSION &&
-	    hdr.ioc_version != LIBCFS_IOCTL_VERSION2) {
-		CERROR("libcfs ioctl: version mismatch expected %#x, got %#x\n",
-		       LIBCFS_IOCTL_VERSION, hdr.ioc_version);
-		return -EINVAL;
-	}
-
-	if (hdr.ioc_len < sizeof(hdr)) {
-		CERROR("libcfs ioctl: user buffer too small for ioctl\n");
-		return -EINVAL;
-	}
-
-	if (hdr.ioc_len > LIBCFS_IOC_DATA_MAX) {
-		CERROR("libcfs ioctl: user buffer is too large %d/%d\n",
-		       hdr.ioc_len, LIBCFS_IOC_DATA_MAX);
-		return -EINVAL;
-	}
-
-	*hdr_pp = kvmalloc(hdr.ioc_len, GFP_KERNEL);
-	if (!*hdr_pp)
-		return -ENOMEM;
-
-	if (copy_from_user(*hdr_pp, uhdr, hdr.ioc_len)) {
-		err = -EFAULT;
-		goto free;
-	}
-
-	if ((*hdr_pp)->ioc_version != hdr.ioc_version ||
-	    (*hdr_pp)->ioc_len != hdr.ioc_len) {
-		err = -EINVAL;
-		goto free;
-	}
-
-	return 0;
-
-free:
-	kvfree(*hdr_pp);
-	return err;
-}
-
-static int libcfs_ioctl(unsigned long cmd, void __user *uparam)
+int libcfs_ioctl(unsigned int cmd, struct libcfs_ioctl_data *data)
 {
-	struct libcfs_ioctl_data *data = NULL;
-	struct libcfs_ioctl_hdr *hdr;
-	int err;
-
-	err = libcfs_setup();
-	if (err)
-		return err;
-	/* 'cmd' and permissions get checked in our arch-specific caller */
-	err = libcfs_ioctl_getdata(&hdr, uparam);
-	if (err) {
-		CDEBUG_LIMIT(D_ERROR,
-			     "libcfs ioctl: data header error %d\n", err);
-		return err;
-	}
-
-	if (hdr->ioc_version == LIBCFS_IOCTL_VERSION) {
-		/*
-		 * The libcfs_ioctl_data_adjust() function performs adjustment
-		 * operations on the libcfs_ioctl_data structure to make
-		 * it usable by the code.  This doesn't need to be called
-		 * for new data structures added.
-		 */
-		data = container_of(hdr, struct libcfs_ioctl_data, ioc_hdr);
-		err = libcfs_ioctl_data_adjust(data);
-		if (err)
-			goto out;
-	}
-
-	CDEBUG(D_IOCTL, "libcfs ioctl cmd %lu\n", cmd);
 	switch (cmd) {
 	case IOC_LIBCFS_CLEAR_DEBUG:
 		libcfs_debug_clear_buffer();
 		break;
-
 	case IOC_LIBCFS_MARK_DEBUG:
 		if (!data || !data->ioc_inlbuf1 ||
-		    data->ioc_inlbuf1[data->ioc_inllen1 - 1] != '\0') {
-			err = -EINVAL;
-			goto out;
-		}
+		    data->ioc_inlbuf1[data->ioc_inllen1 - 1] != '\0')
+			return -EINVAL;
+
 		libcfs_debug_mark_buffer(data->ioc_inlbuf1);
 		break;
 
 	default:
-		err = blocking_notifier_call_chain(&libcfs_ioctl_list,
-						   cmd, hdr);
-		if (!(err & NOTIFY_STOP_MASK))
-			/* No-one claimed the ioctl */
-			err = -EINVAL;
-		else
-			err = notifier_to_errno(err);
-		if (copy_to_user(uparam, hdr, hdr->ioc_len) && !err)
-			err = -EFAULT;
-		break;
-	}
-out:
-	kvfree(hdr);
-	return err;
-}
-
-static long
-libcfs_psdev_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
-{
-	if (!capable(CAP_SYS_ADMIN))
-		return -EACCES;
-
-	if (_IOC_TYPE(cmd) != IOC_LIBCFS_TYPE ||
-	    _IOC_NR(cmd) < IOC_LIBCFS_MIN_NR  ||
-	    _IOC_NR(cmd) > IOC_LIBCFS_MAX_NR) {
-		CDEBUG(D_IOCTL, "invalid ioctl ( type %d, nr %d, size %d )\n",
-		       _IOC_TYPE(cmd), _IOC_NR(cmd), _IOC_SIZE(cmd));
 		return -EINVAL;
 	}
-
-	return libcfs_ioctl(cmd, (void __user *)arg);
+	return 0;
 }
-
-static const struct file_operations libcfs_fops = {
-	.owner			= THIS_MODULE,
-	.unlocked_ioctl		= libcfs_psdev_ioctl,
-};
-
-static struct miscdevice libcfs_dev = {
-	.minor			= MISC_DYNAMIC_MINOR,
-	.name			= "lnet",
-	.fops			= &libcfs_fops,
-};
-
-static int libcfs_dev_registered;
+EXPORT_SYMBOL(libcfs_ioctl);
 
 static int proc_dobitmasks(struct ctl_table *table, int write,
 			   void __user *buffer, size_t *lenp, loff_t *ppos)
@@ -836,9 +631,6 @@ int libcfs_setup(void)
 	if (libcfs_active)
 		goto out;
 
-	if (!libcfs_dev_registered)
-		goto err;
-
 	rc = libcfs_debug_init(5 * 1024 * 1024);
 	if (rc < 0) {
 		pr_err("LustreError: libcfs_debug_init: rc = %d\n", rc);
@@ -880,18 +672,11 @@ EXPORT_SYMBOL(libcfs_setup);
 
 static int libcfs_init(void)
 {
-	int rc;
-
 	lnet_insert_debugfs(lnet_table, THIS_MODULE, &debugfs_state);
 	if (!IS_ERR_OR_NULL(lnet_debugfs_root))
 		lnet_insert_debugfs_links(lnet_debugfs_symlinks);
 
-	rc = misc_register(&libcfs_dev);
-	if (rc)
-		CERROR("misc_register: error %d\n", rc);
-	else
-		libcfs_dev_registered = 1;
-	return rc;
+	return 0;
 }
 
 static void libcfs_exit(void)
@@ -909,9 +694,6 @@ static void libcfs_exit(void)
 
 	cfs_crypto_unregister();
 
-	if (libcfs_dev_registered)
-		misc_deregister(&libcfs_dev);
-
 	cfs_cpu_fini();
 
 	/* the below message is checked in test-framework.sh check_mem_leak() */
diff --git a/net/lnet/lnet/api-ni.c b/net/lnet/lnet/api-ni.c
index d87bc33b1103..f8add2c28284 100644
--- a/net/lnet/lnet/api-ni.c
+++ b/net/lnet/lnet/api-ni.c
@@ -4470,6 +4470,7 @@ LNetCtl(unsigned int cmd, void *arg)
 		if (rc < 0)
 			goto report_ping_err;
 		count = rc;
+		rc = 0;
 
 		for (i = 0; i < count; i++) {
 			struct lnet_processid *result;
@@ -4631,7 +4632,7 @@ LNetCtl(unsigned int cmd, void *arg)
 			rc = ni->ni_net->net_lnd->lnd_ctl(ni, cmd, arg);
 
 		lnet_ni_decref(ni);
-		return rc;
+		return rc <= 0 ? rc : 0;
 	}
 	/* not reached */
 }
diff --git a/net/lnet/lnet/module.c b/net/lnet/lnet/module.c
index e6e34dcad90e..edb41ff28d80 100644
--- a/net/lnet/lnet/module.c
+++ b/net/lnet/lnet/module.c
@@ -32,6 +32,7 @@
 
 #define DEBUG_SUBSYSTEM S_LNET
 
+#include <linux/miscdevice.h>
 #include <linux/lnet/lib-lnet.h>
 #include <uapi/linux/lnet/lnet-dlc.h>
 
@@ -178,11 +179,9 @@ lnet_dyn_unconfigure_ni(struct libcfs_ioctl_hdr *hdr)
 }
 
 static int
-lnet_ioctl(struct notifier_block *nb,
-	   unsigned long cmd, void *vdata)
+lnet_ioctl(unsigned int cmd, struct libcfs_ioctl_hdr *hdr)
 {
 	int rc;
-	struct libcfs_ioctl_hdr *hdr = vdata;
 
 	switch (cmd) {
 	case IOC_LIBCFS_CONFIGURE: {
@@ -219,8 +218,7 @@ lnet_ioctl(struct notifier_block *nb,
 		break;
 
 	default:
-		/*
-		 * Passing LNET_PID_ANY only gives me a ref if the net is up
+		/* Passing LNET_PID_ANY only gives me a ref if the net is up
 		 * already; I'll need it to ensure the net can't go down while
 		 * I'm called into it
 		 */
@@ -231,11 +229,198 @@ lnet_ioctl(struct notifier_block *nb,
 		}
 		break;
 	}
-	return notifier_from_ioctl_errno(rc);
+	return rc;
+}
+
+BLOCKING_NOTIFIER_HEAD(lnet_ioctl_list);
+EXPORT_SYMBOL(lnet_ioctl_list);
+
+static inline size_t lnet_ioctl_packlen(struct libcfs_ioctl_data *data)
+{
+	size_t len = sizeof(*data);
+
+	len += round_up(data->ioc_inllen1, 8);
+	len += round_up(data->ioc_inllen2, 8);
+	return len;
+}
+
+static bool lnet_ioctl_is_invalid(struct libcfs_ioctl_data *data)
+{
+	const int maxlen = 1 << 30;
+
+	if (data->ioc_hdr.ioc_len > maxlen)
+		return true;
+
+	if (data->ioc_inllen1 > maxlen)
+		return true;
+
+	if (data->ioc_inllen2 > maxlen)
+		return true;
+
+	if (data->ioc_inlbuf1 && !data->ioc_inllen1)
+		return true;
+
+	if (data->ioc_inlbuf2 && !data->ioc_inllen2)
+		return true;
+
+	if (data->ioc_pbuf1 && !data->ioc_plen1)
+		return true;
+
+	if (data->ioc_pbuf2 && !data->ioc_plen2)
+		return true;
+
+	if (data->ioc_plen1 && !data->ioc_pbuf1)
+		return true;
+
+	if (data->ioc_plen2 && !data->ioc_pbuf2)
+		return true;
+
+	if (lnet_ioctl_packlen(data) != data->ioc_hdr.ioc_len)
+		return true;
+
+	if (data->ioc_inllen1 &&
+	    data->ioc_bulk[round_up(data->ioc_inllen1, 8) +
+			   data->ioc_inllen2 - 1] != '\0')
+		return true;
+
+	return false;
+}
+
+static int lnet_ioctl_data_adjust(struct libcfs_ioctl_data *data)
+{
+	if (lnet_ioctl_is_invalid(data)) {
+		CERROR("lnet ioctl: parameter not correctly formatted\n");
+		return -EINVAL;
+	}
+
+	if (data->ioc_inllen1 != 0)
+		data->ioc_inlbuf1 = &data->ioc_bulk[0];
+
+	if (data->ioc_inllen2 != 0)
+		data->ioc_inlbuf2 = (&data->ioc_bulk[0] +
+				     round_up(data->ioc_inllen1, 8));
+
+	return 0;
+}
+
+static int lnet_ioctl_getdata(struct libcfs_ioctl_hdr **hdr_pp,
+			      struct libcfs_ioctl_hdr __user *uhdr)
+{
+	struct libcfs_ioctl_hdr hdr;
+	int err;
+
+	if (copy_from_user(&hdr, uhdr, sizeof(hdr)))
+		return -EFAULT;
+
+	if (hdr.ioc_version != LNET_IOCTL_VERSION &&
+	    hdr.ioc_version != LNET_IOCTL_VERSION2) {
+		CERROR("lnet ioctl: version mismatch expected %#x, got %#x\n",
+		       LNET_IOCTL_VERSION, hdr.ioc_version);
+		return -EINVAL;
+	}
+
+	if (hdr.ioc_len < sizeof(struct libcfs_ioctl_hdr)) {
+		CERROR("lnet ioctl: user buffer too small for ioctl\n");
+		return -EINVAL;
+	}
+
+	if (hdr.ioc_len > LIBCFS_IOC_DATA_MAX) {
+		CERROR("lnet ioctl: user buffer is too large %d/%d\n",
+		       hdr.ioc_len, LIBCFS_IOC_DATA_MAX);
+		return -EINVAL;
+	}
+
+	*hdr_pp = kmalloc(hdr.ioc_len, GFP_KERNEL);
+	if (!*hdr_pp)
+		return -ENOMEM;
+
+	if (copy_from_user(*hdr_pp, uhdr, hdr.ioc_len)) {
+		err = -EFAULT;
+		goto free;
+	}
+
+	if ((*hdr_pp)->ioc_version != hdr.ioc_version ||
+	    (*hdr_pp)->ioc_len != hdr.ioc_len) {
+		err = -EINVAL;
+		goto free;
+	}
+
+	return 0;
+
+free:
+	kfree(*hdr_pp);
+	return err;
+}
+
+static long
+lnet_psdev_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
+{
+	void __user *uparam = (void __user *)arg;
+	struct libcfs_ioctl_data *data = NULL;
+	struct libcfs_ioctl_hdr *hdr;
+	int err;
+
+	if (!capable(CAP_SYS_ADMIN))
+		return -EACCES;
+
+	if (_IOC_TYPE(cmd) != IOC_LIBCFS_TYPE ||
+	    _IOC_NR(cmd) < IOC_LIBCFS_MIN_NR  ||
+	    _IOC_NR(cmd) > IOC_LIBCFS_MAX_NR) {
+		CDEBUG(D_IOCTL, "invalid ioctl ( type %d, nr %d, size %d )\n",
+		       _IOC_TYPE(cmd), _IOC_NR(cmd), _IOC_SIZE(cmd));
+		return -EINVAL;
+	}
+
+	/* 'cmd' and permissions get checked in our arch-specific caller */
+	err = lnet_ioctl_getdata(&hdr, uparam);
+	if (err != 0) {
+		CDEBUG_LIMIT(D_ERROR,
+			     "lnet ioctl: data header error %d\n", err);
+		return err;
+	}
+
+	if (hdr->ioc_version == LNET_IOCTL_VERSION) {
+		/* The lnet_ioctl_data_adjust() function performs adjustment
+		 * operations on the libcfs_ioctl_data structure to make
+		 * it usable by the code.  This doesn't need to be called
+		 * for new data structures added.
+		 */
+		data = container_of(hdr, struct libcfs_ioctl_data, ioc_hdr);
+		err = lnet_ioctl_data_adjust(data);
+		if (err != 0)
+			goto out;
+	}
+
+	CDEBUG(D_IOCTL, "lnet ioctl cmd %u\n", cmd);
+
+	err = libcfs_ioctl(cmd, data);
+	if (err == -EINVAL)
+		err = lnet_ioctl(cmd, hdr);
+	if (err == -EINVAL) {
+		err = blocking_notifier_call_chain(&lnet_ioctl_list,
+						   cmd, hdr);
+		if (!(err & NOTIFY_STOP_MASK))
+			/* No-one claimed the ioctl */
+			err = -EINVAL;
+		else
+			err = notifier_to_errno(err);
+	}
+	if (copy_to_user(uparam, hdr, hdr->ioc_len) && !err)
+		err = -EFAULT;
+out:
+	kfree(hdr);
+	return err;
 }
 
-static struct notifier_block lnet_ioctl_handler = {
-	.notifier_call		= lnet_ioctl,
+static const struct file_operations lnet_fops = {
+	.owner			= THIS_MODULE,
+	.unlocked_ioctl		= lnet_psdev_ioctl,
+};
+
+static struct miscdevice lnet_dev = {
+	.minor			= MISC_DYNAMIC_MINOR,
+	.name			= "lnet",
+	.fops			= &lnet_fops,
 };
 
 static int __init lnet_init(void)
@@ -248,7 +433,13 @@ static int __init lnet_init(void)
 
 	rc = lnet_lib_init();
 	if (rc) {
-		CERROR("lnet_lib_init: error %d\n", rc);
+		CERROR("lnet_lib_init: rc = %d\n", rc);
+		return rc;
+	}
+
+	rc = misc_register(&lnet_dev);
+	if (rc) {
+		CERROR("misc_register: rc = %d\n", rc);
 		return rc;
 	}
 
@@ -256,10 +447,6 @@ static int __init lnet_init(void)
 	    dead_router_check_interval != INT_MIN)
 		LCONSOLE_WARN("live_router_check_interval and dead_router_check_interval have been deprecated. Use alive_router_check_interval instead. Ignoring these deprecated parameters.\n");
 
-	rc = blocking_notifier_chain_register(&libcfs_ioctl_list,
-					      &lnet_ioctl_handler);
-	LASSERT(!rc);
-
 	if (config_on_load) {
 		/*
 		 * Have to schedule a separate thread to avoid deadlocking
@@ -273,12 +460,7 @@ static int __init lnet_init(void)
 
 static void __exit lnet_exit(void)
 {
-	int rc;
-
-	rc = blocking_notifier_chain_unregister(&libcfs_ioctl_list,
-						&lnet_ioctl_handler);
-	LASSERT(!rc);
-
+	misc_deregister(&lnet_dev);
 	lnet_router_exit();
 	lnet_lib_exit();
 }
diff --git a/net/lnet/selftest/console.c b/net/lnet/selftest/console.c
index b6c98820d0bf..cac1752a51b8 100644
--- a/net/lnet/selftest/console.c
+++ b/net/lnet/selftest/console.c
@@ -1989,7 +1989,7 @@ lstcon_console_init(void)
 	if (rc < 0)
 		goto out;
 
-	rc = blocking_notifier_chain_register(&libcfs_ioctl_list,
+	rc = blocking_notifier_chain_register(&lnet_ioctl_list,
 					      &lstcon_ioctl_handler);
 
 	if (rc < 0) {
@@ -2016,7 +2016,7 @@ lstcon_console_fini(void)
 {
 	int i;
 
-	blocking_notifier_chain_unregister(&libcfs_ioctl_list,
+	blocking_notifier_chain_unregister(&lnet_ioctl_list,
 					   &lstcon_ioctl_handler);
 	lstcon_fini_netlink();
 
-- 
2.39.3

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
