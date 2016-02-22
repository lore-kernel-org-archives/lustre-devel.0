From: James Simmons <jsimmons@infradead.org>
Date: Mon, 22 Feb 2016 17:29:03 -0500
Subject: [lustre-devel] [PATCH 02/24] staging: lustre: Dynamic LNet
	Configuration (DLC) show command
In-Reply-To: <1456180165-1105-1-git-send-email-jsimmons@infradead.org>
References: <1456180165-1105-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1456180165-1105-3-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Amir Shehata <amir.shehata@intel.com>

From: Amir Shehata <amir.shehata@intel.com>

This is the fifth patch of a set of patches that enables DLC.

This patch adds the new structures which will be used
in the IOCTL communication.  It also added a set of
show operations to show buffers, networks, statistics
and peer information.

Signed-off-by: Amir Shehata <amir.shehata@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-2456
Reviewed-on: http://review.whamcloud.com/8022
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Doug Oucharek <doug.s.oucharek@intel.com>
Reviewed-by: James Simmons <uja.ornl@gmail.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 .../lustre/include/linux/libcfs/libcfs_ioctl.h     |   26 ++++-
 .../staging/lustre/include/linux/lnet/lib-dlc.h    |  122 ++++++++++++++++++++
 .../staging/lustre/include/linux/lnet/lib-lnet.h   |    5 +
 drivers/staging/lustre/lnet/lnet/api-ni.c          |   56 ++++++++-
 drivers/staging/lustre/lnet/lnet/module.c          |    4 +
 drivers/staging/lustre/lnet/lnet/peer.c            |   61 ++++++++++
 .../lustre/lustre/libcfs/linux/linux-module.c      |    3 +-
 drivers/staging/lustre/lustre/libcfs/module.c      |   15 ++-
 8 files changed, 277 insertions(+), 15 deletions(-)
 create mode 100644 drivers/staging/lustre/include/linux/lnet/lib-dlc.h

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_ioctl.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_ioctl.h
index 0598702..f788631 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_ioctl.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_ioctl.h
@@ -41,7 +41,8 @@
 #ifndef __LIBCFS_IOCTL_H__
 #define __LIBCFS_IOCTL_H__
 
-#define LIBCFS_IOCTL_VERSION 0x0001000a
+#define LIBCFS_IOCTL_VERSION	0x0001000a
+#define LIBCFS_IOCTL_VERSION2	0x0001000b
 
 struct libcfs_ioctl_hdr {
 	__u32 ioc_len;
@@ -111,9 +112,6 @@ struct libcfs_ioctl_handler {
 /* lnet ioctls */
 #define IOC_LIBCFS_GET_NI		  _IOWR('e', 50, long)
 #define IOC_LIBCFS_FAIL_NID		_IOWR('e', 51, long)
-#define IOC_LIBCFS_ADD_ROUTE	       _IOWR('e', 52, long)
-#define IOC_LIBCFS_DEL_ROUTE	       _IOWR('e', 53, long)
-#define IOC_LIBCFS_GET_ROUTE	       _IOWR('e', 54, long)
 #define IOC_LIBCFS_NOTIFY_ROUTER	   _IOWR('e', 55, long)
 #define IOC_LIBCFS_UNCONFIGURE	     _IOWR('e', 56, long)
 /*	#define IOC_LIBCFS_PORTALS_COMPATIBILITY   _IOWR('e', 57, long) */
@@ -136,7 +134,25 @@ struct libcfs_ioctl_handler {
 #define IOC_LIBCFS_DEL_INTERFACE	   _IOWR('e', 79, long)
 #define IOC_LIBCFS_GET_INTERFACE	   _IOWR('e', 80, long)
 
-#define IOC_LIBCFS_MAX_NR			     80
+/*
+ * DLC Specific IOCTL numbers.
+ * In order to maintain backward compatibility with any possible external
+ * tools which might be accessing the IOCTL numbers, a new group of IOCTL
+ * number have been allocated.
+ */
+#define IOCTL_CONFIG_SIZE		struct lnet_ioctl_config_data
+#define IOC_LIBCFS_ADD_ROUTE		_IOWR(IOC_LIBCFS_TYPE, 81, IOCTL_CONFIG_SIZE)
+#define IOC_LIBCFS_DEL_ROUTE		_IOWR(IOC_LIBCFS_TYPE, 82, IOCTL_CONFIG_SIZE)
+#define IOC_LIBCFS_GET_ROUTE		_IOWR(IOC_LIBCFS_TYPE, 83, IOCTL_CONFIG_SIZE)
+#define IOC_LIBCFS_ADD_NET		_IOWR(IOC_LIBCFS_TYPE, 84, IOCTL_CONFIG_SIZE)
+#define IOC_LIBCFS_DEL_NET		_IOWR(IOC_LIBCFS_TYPE, 85, IOCTL_CONFIG_SIZE)
+#define IOC_LIBCFS_GET_NET		_IOWR(IOC_LIBCFS_TYPE, 86, IOCTL_CONFIG_SIZE)
+#define IOC_LIBCFS_CONFIG_RTR		_IOWR(IOC_LIBCFS_TYPE, 87, IOCTL_CONFIG_SIZE)
+#define IOC_LIBCFS_ADD_BUF		_IOWR(IOC_LIBCFS_TYPE, 88, IOCTL_CONFIG_SIZE)
+#define IOC_LIBCFS_GET_BUF		_IOWR(IOC_LIBCFS_TYPE, 89, IOCTL_CONFIG_SIZE)
+#define IOC_LIBCFS_GET_PEER_INFO	_IOWR(IOC_LIBCFS_TYPE, 90, IOCTL_CONFIG_SIZE)
+#define IOC_LIBCFS_GET_LNET_STATS	_IOWR(IOC_LIBCFS_TYPE, 91, IOCTL_CONFIG_SIZE)
+#define IOC_LIBCFS_MAX_NR		91
 
 static inline int libcfs_ioctl_packlen(struct libcfs_ioctl_data *data)
 {
diff --git a/drivers/staging/lustre/include/linux/lnet/lib-dlc.h b/drivers/staging/lustre/include/linux/lnet/lib-dlc.h
new file mode 100644
index 0000000..84a19e9
--- /dev/null
+++ b/drivers/staging/lustre/include/linux/lnet/lib-dlc.h
@@ -0,0 +1,122 @@
+/*
+ * LGPL HEADER START
+ *
+ * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
+ *
+ * This library is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU Lesser General Public
+ * License as published by the Free Software Foundation; either
+ * version 2.1 of the License, or (at your option) any later version.
+ *
+ * This library is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
+ * Lesser General Public License for more details.
+ *
+ * You should have received a copy of the GNU Lesser General Public
+ * License along with this library.
+ *
+ * LGPL HEADER END
+ *
+ */
+/*
+ * Copyright (c) 2014, Intel Corporation.
+ */
+/*
+ * Author: Amir Shehata <amir.shehata@intel.com>
+ */
+
+#ifndef LNET_DLC_H
+#define LNET_DLC_H
+
+#include "../libcfs/libcfs_ioctl.h"
+#include "types.h"
+
+#define MAX_NUM_SHOW_ENTRIES	32
+#define LNET_MAX_STR_LEN	128
+#define LNET_MAX_SHOW_NUM_CPT	128
+#define LNET_UNDEFINED_HOPS	((__u32) -1)
+
+struct lnet_ioctl_net_config {
+	char ni_interfaces[LNET_MAX_INTERFACES][LNET_MAX_STR_LEN];
+	__u32 ni_status;
+	__u32 ni_cpts[LNET_MAX_SHOW_NUM_CPT];
+};
+
+#define LNET_TINY_BUF_IDX	0
+#define LNET_SMALL_BUF_IDX	1
+#define LNET_LARGE_BUF_IDX	2
+
+/* # different router buffer pools */
+#define LNET_NRBPOOLS		(LNET_LARGE_BUF_IDX + 1)
+
+struct lnet_ioctl_pool_cfg {
+	struct {
+		__u32 pl_npages;
+		__u32 pl_nbuffers;
+		__u32 pl_credits;
+		__u32 pl_mincredits;
+	} pl_pools[LNET_NRBPOOLS];
+	__u32 pl_routing;
+};
+
+struct lnet_ioctl_config_data {
+	struct libcfs_ioctl_hdr cfg_hdr;
+
+	__u32 cfg_net;
+	__u32 cfg_count;
+	__u64 cfg_nid;
+	__u32 cfg_ncpts;
+
+	union {
+		struct {
+			__u32 rtr_hop;
+			__u32 rtr_priority;
+			__u32 rtr_flags;
+		} cfg_route;
+		struct {
+			char net_intf[LNET_MAX_STR_LEN];
+			__s32 net_peer_timeout;
+			__s32 net_peer_tx_credits;
+			__s32 net_peer_rtr_credits;
+			__s32 net_max_tx_credits;
+			__u32 net_cksum_algo;
+			__u32 net_pad;
+		} cfg_net;
+		struct {
+			__u32 buf_enable;
+			__s32 buf_tiny;
+			__s32 buf_small;
+			__s32 buf_large;
+		} cfg_buffers;
+	} cfg_config_u;
+
+	char cfg_bulk[0];
+};
+
+struct lnet_ioctl_peer {
+	struct libcfs_ioctl_hdr pr_hdr;
+	__u32 pr_count;
+	__u32 pr_pad;
+	__u64 pr_nid;
+
+	union {
+		struct {
+			char cr_aliveness[LNET_MAX_STR_LEN];
+			__u32 cr_refcount;
+			__u32 cr_ni_peer_tx_credits;
+			__u32 cr_peer_tx_credits;
+			__u32 cr_peer_rtr_credits;
+			__u32 cr_peer_min_rtr_credits;
+			__u32 cr_peer_tx_qnob;
+			__u32 cr_ncpt;
+		} pr_peer_credits;
+	} pr_lnd_u;
+};
+
+struct lnet_ioctl_lnet_stats {
+	struct libcfs_ioctl_hdr st_hdr;
+	struct lnet_counters st_cntrs;
+};
+
+#endif /* LNET_DLC_H */
diff --git a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
index 0592e30..1157819 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
@@ -693,6 +693,11 @@ void lnet_peer_tables_cleanup(lnet_ni_t *ni);
 void lnet_peer_tables_destroy(void);
 int lnet_peer_tables_create(void);
 void lnet_debug_peer(lnet_nid_t nid);
+int lnet_get_peers(int count, __u64 *nid, char *alivness,
+		   int *ncpt, int *refcount,
+		   int *ni_peer_tx_credits, int *peer_tx_credits,
+		   int *peer_rtr_credits, int *peer_min_rtr_credtis,
+		   int *peer_tx_qnob);
 
 static inline void
 lnet_peer_set_alive(lnet_peer_t *lp)
diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
index 933f345..b2b914a 100644
--- a/drivers/staging/lustre/lnet/lnet/api-ni.c
+++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
@@ -39,6 +39,7 @@
 #include <linux/ktime.h>
 
 #include "../../include/linux/lnet/lib-lnet.h"
+#include "../../include/linux/lnet/lib-dlc.h"
 
 #define D_LNI D_CONSOLE
 
@@ -1743,6 +1744,7 @@ int
 LNetCtl(unsigned int cmd, void *arg)
 {
 	struct libcfs_ioctl_data *data = arg;
+	struct lnet_ioctl_config_data *config;
 	lnet_process_id_t id = {0};
 	lnet_ni_t *ni;
 	int rc;
@@ -1767,16 +1769,60 @@ LNetCtl(unsigned int cmd, void *arg)
 		return rc ? rc : lnet_check_routes();
 
 	case IOC_LIBCFS_DEL_ROUTE:
+		config = arg;
+
+		if (config->cfg_hdr.ioc_len < sizeof(*config))
+			return -EINVAL;
+
 		mutex_lock(&the_lnet.ln_api_mutex);
-		rc = lnet_del_route(data->ioc_net, data->ioc_nid);
+		rc = lnet_del_route(config->cfg_net, config->cfg_nid);
 		mutex_unlock(&the_lnet.ln_api_mutex);
 		return rc;
 
 	case IOC_LIBCFS_GET_ROUTE:
-		return lnet_get_route(data->ioc_count,
-				      &data->ioc_net, &data->ioc_count,
-				      &data->ioc_nid, &data->ioc_flags,
-				      &data->ioc_priority);
+		config = arg;
+
+		if (config->cfg_hdr.ioc_len < sizeof(*config))
+			return -EINVAL;
+
+		return lnet_get_route(config->cfg_count,
+				      &config->cfg_net,
+				      &config->cfg_config_u.cfg_route.rtr_hop,
+				      &config->cfg_nid,
+				      &config->cfg_config_u.cfg_route.rtr_flags,
+				      &config->cfg_config_u.cfg_route.rtr_priority);
+
+	case IOC_LIBCFS_ADD_NET:
+		return 0;
+
+	case IOC_LIBCFS_DEL_NET:
+		return 0;
+
+	case IOC_LIBCFS_GET_NET:
+		return 0;
+
+	case IOC_LIBCFS_GET_LNET_STATS: {
+		struct lnet_ioctl_lnet_stats *lnet_stats = arg;
+
+		if (lnet_stats->st_hdr.ioc_len < sizeof(*lnet_stats))
+			return -EINVAL;
+
+		lnet_counters_get(&lnet_stats->st_cntrs);
+		return 0;
+	}
+
+	case IOC_LIBCFS_CONFIG_RTR:
+		return 0;
+
+	case IOC_LIBCFS_ADD_BUF:
+		return 0;
+
+	case IOC_LIBCFS_GET_BUF:
+		return 0;
+
+	case IOC_LIBCFS_GET_PEER_INFO:
+		return 0;
+
 	case IOC_LIBCFS_NOTIFY_ROUTER:
 		secs_passed = (ktime_get_real_seconds() - data->ioc_u64[0]);
 		return lnet_notify(NULL, data->ioc_nid, data->ioc_flags,
diff --git a/drivers/staging/lustre/lnet/lnet/module.c b/drivers/staging/lustre/lnet/lnet/module.c
index 46f5241..27213f1 100644
--- a/drivers/staging/lustre/lnet/lnet/module.c
+++ b/drivers/staging/lustre/lnet/lnet/module.c
@@ -36,6 +36,7 @@
 
 #define DEBUG_SUBSYSTEM S_LNET
 #include "../../include/linux/lnet/lib-lnet.h"
+#include "../../include/linux/lnet/lib-dlc.h"
 
 static int config_on_load;
 module_param(config_on_load, int, 0444);
@@ -95,6 +96,9 @@ lnet_ioctl(unsigned int cmd, struct libcfs_ioctl_hdr *hdr)
 	case IOC_LIBCFS_UNCONFIGURE:
 		return lnet_unconfigure();
 
+	case IOC_LIBCFS_ADD_NET:
+		return LNetCtl(cmd, hdr);
+
 	default:
 		/*
 		 * Passing LNET_PID_ANY only gives me a ref if the net is up
diff --git a/drivers/staging/lustre/lnet/lnet/peer.c b/drivers/staging/lustre/lnet/lnet/peer.c
index 42b2d44..5771708 100644
--- a/drivers/staging/lustre/lnet/lnet/peer.c
+++ b/drivers/staging/lustre/lnet/lnet/peer.c
@@ -39,6 +39,7 @@
 #define DEBUG_SUBSYSTEM S_LNET
 
 #include "../../include/linux/lnet/lib-lnet.h"
+#include "../../include/linux/lnet/lib-dlc.h"
 
 int
 lnet_peer_tables_create(void)
@@ -392,3 +393,63 @@ lnet_debug_peer(lnet_nid_t nid)
 
 	lnet_net_unlock(cpt);
 }
+
+int lnet_get_peers(int count, __u64 *nid, char *aliveness,
+		   int *ncpt, int *refcount,
+		   int *ni_peer_tx_credits, int *peer_tx_credits,
+		   int *peer_rtr_credits, int *peer_min_rtr_credits,
+		   int *peer_tx_qnob)
+{
+	struct lnet_peer_table *peer_table;
+	lnet_peer_t *lp;
+	int j;
+	int lncpt, found = 0;
+
+	/* get the number of CPTs */
+	lncpt = cfs_percpt_number(the_lnet.ln_peer_tables);
+
+	/*
+	 * if the cpt number to be examined is >= the number of cpts in
+	 * the system then indicate that there are no more cpts to examin
+	 */
+	if (*ncpt >= lncpt)
+		return -ENOENT;
+
+	/* get the current table */
+	peer_table = the_lnet.ln_peer_tables[*ncpt];
+	/* if the ptable is NULL then there are no more cpts to examine */
+	if (!peer_table)
+		return -ENOENT;
+
+	lnet_net_lock(*ncpt);
+
+	for (j = 0; j < LNET_PEER_HASH_SIZE && !found; j++) {
+		struct list_head *peers = &peer_table->pt_hash[j];
+
+		list_for_each_entry(lp, peers, lp_hashlist) {
+			if (count-- > 0)
+				continue;
+
+			snprintf(aliveness, LNET_MAX_STR_LEN, "NA");
+			if (lnet_isrouter(lp) ||
+			    lnet_peer_aliveness_enabled(lp))
+				snprintf(aliveness, LNET_MAX_STR_LEN,
+					 lp->lp_alive ? "up" : "down");
+
+			*nid = lp->lp_nid;
+			*refcount = lp->lp_refcount;
+			*ni_peer_tx_credits = lp->lp_ni->ni_peertxcredits;
+			*peer_tx_credits = lp->lp_txcredits;
+			*peer_rtr_credits = lp->lp_rtrcredits;
+			*peer_min_rtr_credits = lp->lp_mintxcredits;
+			*peer_tx_qnob = lp->lp_txqnob;
+
+			found = 1;
+		}
+	}
+	lnet_net_unlock(*ncpt);
+
+	*ncpt = lncpt;
+
+	return found ? 0 : -ENOENT;
+}
diff --git a/drivers/staging/lustre/lustre/libcfs/linux/linux-module.c b/drivers/staging/lustre/lustre/libcfs/linux/linux-module.c
index f62c5bc..ebc60ac 100644
--- a/drivers/staging/lustre/lustre/libcfs/linux/linux-module.c
+++ b/drivers/staging/lustre/lustre/libcfs/linux/linux-module.c
@@ -65,7 +65,8 @@ int libcfs_ioctl_getdata_len(const struct libcfs_ioctl_hdr __user *arg,
 	if (copy_from_user(&hdr, arg, sizeof(hdr)))
 		return -EFAULT;
 
-	if (hdr.ioc_version != LIBCFS_IOCTL_VERSION) {
+	if (hdr.ioc_version != LIBCFS_IOCTL_VERSION &&
+	    hdr.ioc_version != LIBCFS_IOCTL_VERSION2) {
 		CERROR("LNET: version mismatch expected %#x, got %#x\n",
 		       LIBCFS_IOCTL_VERSION, hdr.ioc_version);
 		return -EINVAL;
diff --git a/drivers/staging/lustre/lustre/libcfs/module.c b/drivers/staging/lustre/lustre/libcfs/module.c
index 1cb6c80..05e2c56 100644
--- a/drivers/staging/lustre/lustre/libcfs/module.c
+++ b/drivers/staging/lustre/lustre/libcfs/module.c
@@ -54,13 +54,15 @@
 
 # define DEBUG_SUBSYSTEM S_LNET
 
-#define LIBCFS_MAX_IOCTL_BUF_LEN 2048
+#define LNET_MAX_IOCTL_BUF_LEN (sizeof(struct lnet_ioctl_net_config) + \
+				sizeof(struct lnet_ioctl_config_data))
 
 #include "../../include/linux/libcfs/libcfs.h"
 #include <asm/div64.h>
 
 #include "../../include/linux/libcfs/libcfs_crypto.h"
 #include "../../include/linux/lnet/lib-lnet.h"
+#include "../../include/linux/lnet/lib-dlc.h"
 #include "../../include/linux/lnet/lnet.h"
 #include "tracefile.h"
 
@@ -123,8 +125,13 @@ static int libcfs_ioctl_handle(struct cfs_psdev_file *pfile, unsigned long cmd,
 	struct libcfs_ioctl_data *data = NULL;
 	int err = -EINVAL;
 
-	if ((cmd <= IOC_LIBCFS_LNETST) ||
-	    (cmd >= IOC_LIBCFS_REGISTER_MYNID)) {
+	/*
+	 * The libcfs_ioctl_data_adjust() function performs adjustment
+	 * operations on the libcfs_ioctl_data structure to make
+	 * it usable by the code.  This doesn't need to be called
+	 * for new data structures added.
+	 */
+	if (hdr->ioc_version == LIBCFS_IOCTL_VERSION) {
 		data = container_of(hdr, struct libcfs_ioctl_data, ioc_hdr);
 		err = libcfs_ioctl_data_adjust(data);
 		if (err)
@@ -183,7 +190,7 @@ static int libcfs_ioctl(struct cfs_psdev_file *pfile, unsigned long cmd,
 	 * do a check here to restrict the size of the memory
 	 * to allocate to guard against DoS attacks.
 	 */
-	if (buf_len > LIBCFS_MAX_IOCTL_BUF_LEN) {
+	if (buf_len > LNET_MAX_IOCTL_BUF_LEN) {
 		CERROR("LNET: user buffer exceeds kernel buffer\n");
 		return -EINVAL;
 	}
-- 
1.7.1
