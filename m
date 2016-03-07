From: James Simmons <jsimmons@infradead.org>
Date: Mon,  7 Mar 2016 18:10:16 -0500
Subject: [lustre-devel] [PATCH v2 1/9] staging: lustre: LNet drop rule
	implementation
In-Reply-To: <1457392224-2592-1-git-send-email-jsimmons@infradead.org>
References: <1457392224-2592-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1457392224-2592-2-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Liang Zhen <liang.zhen@intel.com>

From: Liang Zhen <liang.zhen@intel.com>

This is implementation of LNet Drop Rule, which can randomly drop
LNet messages at specified rate.

LNet Drop Rule can only be applied to receive side of message. User
can add drop_rule either on end point of cluster (client/server) or
on LNet routers.

Here are lctl command to control LNet Drop Rules:
 - net_drop_add -s SRC_NID -d DEST_NID --rate VALUE
   drop 1/@VALUE of messages from @SRC_NID to @DEST_NID

 - net_drop_del -s SRC_NID -d DEST_NID
   remove all drop rules from @SRC_NID to @DEST_NID

 - net_drop_list
   list all drop rules on current node

 Examples:
 - lctl net_drop_add -s *@o2ib0 -d 192.168.1.102 at tcp 1000
   add new drop rule, it will drop 1/1000 messages from network o2ib0
   to 192.168.1.102 at tcp

 - lctl net_drop_add -s 10.8.6.123 at o2ib1 -d * 500
   add new drop rule, it will drop 1/500 messages from 10.8.6.123 at o2ib1
   to all nodes

Signed-off-by: Liang Zhen <liang.zhen@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5435
Reviewed-on: http://review.whamcloud.com/11314
Reviewed-by: Bobi Jam <bobijam@gmail.com>
Reviewed-by: Amir Shehata <amir.shehata@intel.com>
Reviewed-by: Johann Lombardi <johann.lombardi@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 .../lustre/include/linux/libcfs/libcfs_ioctl.h     |    1 +
 .../staging/lustre/include/linux/lnet/lib-lnet.h   |   10 +
 .../staging/lustre/include/linux/lnet/lib-types.h  |    2 +
 .../staging/lustre/include/linux/lnet/lnetctl.h    |   83 ++++
 drivers/staging/lustre/lnet/lnet/Makefile          |    2 +-
 drivers/staging/lustre/lnet/lnet/api-ni.c          |    6 +
 drivers/staging/lustre/lnet/lnet/lib-move.c        |    8 +
 drivers/staging/lustre/lnet/lnet/net_fault.c       |  434 ++++++++++++++++++++
 8 files changed, 545 insertions(+), 1 deletions(-)
 create mode 100644 drivers/staging/lustre/lnet/lnet/net_fault.c

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_ioctl.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_ioctl.h
index f788631..5ca99bd 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_ioctl.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_ioctl.h
@@ -121,6 +121,7 @@ struct libcfs_ioctl_handler {
 #define IOC_LIBCFS_PING		    _IOWR('e', 61, long)
 /*	#define IOC_LIBCFS_DEBUG_PEER	      _IOWR('e', 62, long) */
 #define IOC_LIBCFS_LNETST		  _IOWR('e', 63, long)
+#define	IOC_LIBCFS_LNET_FAULT		_IOWR('e', 64, long)
 /* lnd ioctls */
 #define IOC_LIBCFS_REGISTER_MYNID	  _IOWR('e', 70, long)
 #define IOC_LIBCFS_CLOSE_CONNECTION	_IOWR('e', 71, long)
diff --git a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
index 84642dc..7b3f858 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
@@ -578,6 +578,16 @@ char *lnet_msgtyp2str(int type);
 void lnet_print_hdr(lnet_hdr_t *hdr);
 int lnet_fail_nid(lnet_nid_t nid, unsigned int threshold);
 
+/** \addtogroup lnet_fault_simulation @{ */
+
+int lnet_fault_ctl(int cmd, struct libcfs_ioctl_data *data);
+int lnet_fault_init(void);
+void lnet_fault_fini(void);
+
+bool lnet_drop_rule_match(lnet_hdr_t *hdr);
+
+/** @} lnet_fault_simulation */
+
 void lnet_counters_get(lnet_counters_t *counters);
 void lnet_counters_reset(void);
 
diff --git a/drivers/staging/lustre/include/linux/lnet/lib-types.h b/drivers/staging/lustre/include/linux/lnet/lib-types.h
index d2513db..cb09a8a 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-types.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-types.h
@@ -40,6 +40,7 @@
 #include <linux/types.h>
 
 #include "types.h"
+#include "lnetctl.h"
 
 /* Max payload size */
 #define LNET_MAX_PAYLOAD      CONFIG_LNET_MAX_PAYLOAD
@@ -572,6 +573,7 @@ typedef struct {
 	struct lnet_peer_table		**ln_peer_tables;
 	/* failure simulation */
 	struct list_head		  ln_test_peers;
+	struct list_head		  ln_drop_rules;
 
 	struct list_head		  ln_nis;	/* LND instances */
 	/* NIs bond on specific CPT(s) */
diff --git a/drivers/staging/lustre/include/linux/lnet/lnetctl.h b/drivers/staging/lustre/include/linux/lnet/lnetctl.h
index 4b64f62..ec33bf8 100644
--- a/drivers/staging/lustre/include/linux/lnet/lnetctl.h
+++ b/drivers/staging/lustre/include/linux/lnet/lnetctl.h
@@ -17,6 +17,89 @@
 
 #include "types.h"
 
+/** \addtogroup lnet_fault_simulation
+ * @{
+ */
+
+enum {
+	LNET_CTL_DROP_ADD,
+	LNET_CTL_DROP_DEL,
+	LNET_CTL_DROP_RESET,
+	LNET_CTL_DROP_LIST,
+};
+
+#define LNET_ACK_BIT		BIT(0)
+#define LNET_PUT_BIT		BIT(1)
+#define LNET_GET_BIT		BIT(2)
+#define LNET_REPLY_BIT		BIT(3)
+
+/** ioctl parameter for LNet fault simulation */
+struct lnet_fault_attr {
+	/**
+	 * source NID of drop rule
+	 * LNET_NID_ANY is wildcard for all sources
+	 * 255.255.255.255 at net is wildcard for all addresses from @net
+	 */
+	lnet_nid_t			fa_src;
+	/** destination NID of drop rule, see \a dr_src for details */
+	lnet_nid_t			fa_dst;
+	/**
+	 * Portal mask to drop, -1 means all portals, for example:
+	 * fa_ptl_mask = (1 << _LDLM_CB_REQUEST_PORTAL ) |
+	 *		 (1 << LDLM_CANCEL_REQUEST_PORTAL)
+	 *
+	 * If it is non-zero then only PUT and GET will be filtered, otherwise
+	 * there is no portal filter, all matched messages will be checked.
+	 */
+	__u64				fa_ptl_mask;
+	/**
+	 * message types to drop, for example:
+	 * dra_type = LNET_DROP_ACK_BIT | LNET_DROP_PUT_BIT
+	 *
+	 * If it is non-zero then only specified message types are filtered,
+	 * otherwise all message types will be checked.
+	 */
+	__u32				fa_msg_mask;
+	union {
+		/** message drop simulation */
+		struct {
+			/** drop rate of this rule */
+			__u32			da_rate;
+			/**
+			 * time interval of message drop, it is exclusive
+			 * with da_rate
+			 */
+			__u32			da_interval;
+		} drop;
+		/** TODO: add more */
+		__u64			space[8];
+	} u;
+};
+
+/** fault simluation stats */
+struct lnet_fault_stat {
+	/** total # matched messages */
+	__u64				fs_count;
+	/** # dropped LNET_MSG_PUT by this rule */
+	__u64				fs_put;
+	/** # dropped LNET_MSG_ACK by this rule */
+	__u64				fs_ack;
+	/** # dropped LNET_MSG_GET by this rule */
+	__u64				fs_get;
+	/** # dropped LNET_MSG_REPLY by this rule */
+	__u64				fs_reply;
+	union {
+		struct {
+			/** total # dropped messages */
+			__u64			ds_dropped;
+		} drop;
+		/** TODO: add more */
+		__u64			space[8];
+	} u;
+};
+
+/** @} lnet_fault_simulation */
+
 #define LNET_DEV_ID 0
 #define LNET_DEV_PATH "/dev/lnet"
 #define LNET_DEV_MAJOR 10
diff --git a/drivers/staging/lustre/lnet/lnet/Makefile b/drivers/staging/lustre/lnet/lnet/Makefile
index e276fe2..4c81fa1 100644
--- a/drivers/staging/lustre/lnet/lnet/Makefile
+++ b/drivers/staging/lustre/lnet/lnet/Makefile
@@ -1,6 +1,6 @@
 obj-$(CONFIG_LNET) += lnet.o
 
-lnet-y := api-ni.o config.o nidstrings.o			\
+lnet-y := api-ni.o config.o nidstrings.o net_fault.o		\
 	  lib-me.o lib-msg.o lib-eq.o lib-md.o lib-ptl.o	\
 	  lib-socket.o lib-move.o module.o lo.o			\
 	  router.o router_proc.o acceptor.o peer.o
diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
index 99cdf9e..4d77ca3 100644
--- a/drivers/staging/lustre/lnet/lnet/api-ni.c
+++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
@@ -550,6 +550,7 @@ lnet_prepare(lnet_pid_t requested_pid)
 	INIT_LIST_HEAD(&the_lnet.ln_nis_cpt);
 	INIT_LIST_HEAD(&the_lnet.ln_nis_zombie);
 	INIT_LIST_HEAD(&the_lnet.ln_routers);
+	INIT_LIST_HEAD(&the_lnet.ln_drop_rules);
 
 	rc = lnet_create_remote_nets_table();
 	if (rc)
@@ -1564,6 +1565,7 @@ LNetNIInit(lnet_pid_t requested_pid)
 	if (rc)
 		goto err_stop_ping;
 
+	lnet_fault_init();
 	lnet_router_debugfs_init();
 
 	mutex_unlock(&the_lnet.ln_api_mutex);
@@ -1616,6 +1618,7 @@ LNetNIFini(void)
 	} else {
 		LASSERT(!the_lnet.ln_niinit_self);
 
+		lnet_fault_fini();
 		lnet_router_debugfs_fini();
 		lnet_router_checker_stop();
 		lnet_ping_target_fini();
@@ -2030,6 +2033,9 @@ LNetCtl(unsigned int cmd, void *arg)
 		lnet_net_unlock(LNET_LOCK_EX);
 		return 0;
 
+	case IOC_LIBCFS_LNET_FAULT:
+		return lnet_fault_ctl(data->ioc_flags, data);
+
 	case IOC_LIBCFS_PING:
 		id.nid = data->ioc_nid;
 		id.pid = data->ioc_u32[0];
diff --git a/drivers/staging/lustre/lnet/lnet/lib-move.c b/drivers/staging/lustre/lnet/lnet/lib-move.c
index 2d187e4..7a0f185 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-move.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-move.c
@@ -1931,6 +1931,14 @@ lnet_parse(lnet_ni_t *ni, lnet_hdr_t *hdr, lnet_nid_t from_nid,
 		goto drop;
 	}
 
+	if (!list_empty(&the_lnet.ln_drop_rules) &&
+	    lnet_drop_rule_match(hdr)) {
+		CDEBUG(D_NET, "%s, src %s, dst %s: Dropping %s to simulate silent message loss\n",
+		       libcfs_nid2str(from_nid), libcfs_nid2str(src_nid),
+		       libcfs_nid2str(dest_nid), lnet_msgtyp2str(type));
+		goto drop;
+	}
+
 	msg = lnet_msg_alloc();
 	if (!msg) {
 		CERROR("%s, src %s: Dropping %s (out of memory)\n",
diff --git a/drivers/staging/lustre/lnet/lnet/net_fault.c b/drivers/staging/lustre/lnet/lnet/net_fault.c
new file mode 100644
index 0000000..a700562
--- /dev/null
+++ b/drivers/staging/lustre/lnet/lnet/net_fault.c
@@ -0,0 +1,434 @@
+/*
+ * GPL HEADER START
+ *
+ * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 only,
+ * as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License version 2 for more details (a copy is included
+ * in the LICENSE file that accompanied this code).
+ *
+ * You should have received a copy of the GNU General Public License
+ * version 2 along with this program; If not, see
+ * http://www.gnu.org/licenses/gpl-2.0.html
+ *
+ * GPL HEADER END
+ */
+/*
+ * Copyright (c) 2014, Intel Corporation.
+ */
+/*
+ * This file is part of Lustre, http://www.lustre.org/
+ * Lustre is a trademark of Seagate, Inc.
+ *
+ * lnet/lnet/net_fault.c
+ *
+ * Lustre network fault simulation
+ *
+ * Author: liang.zhen at intel.com
+ */
+
+#define DEBUG_SUBSYSTEM S_LNET
+
+#include "../../include/linux/lnet/lib-lnet.h"
+#include "../../include/linux/lnet/lnetctl.h"
+
+#define LNET_MSG_MASK		(LNET_PUT_BIT | LNET_ACK_BIT | \
+				 LNET_GET_BIT | LNET_REPLY_BIT)
+
+struct lnet_drop_rule {
+	/** link chain on the_lnet.ln_drop_rules */
+	struct list_head	dr_link;
+	/** attributes of this rule */
+	struct lnet_fault_attr	dr_attr;
+	/** lock to protect \a dr_drop_at and \a dr_stat */
+	spinlock_t		dr_lock;
+	/**
+	 * the message sequence to drop, which means message is dropped when
+	 * dr_stat.drs_count == dr_drop_at
+	 */
+	unsigned long		dr_drop_at;
+	/**
+	 * seconds to drop the next message, it's exclusive with dr_drop_at
+	 */
+	unsigned long		dr_drop_time;
+	/** baseline to caculate dr_drop_time */
+	unsigned long		dr_time_base;
+	/** statistic of dropped messages */
+	struct lnet_fault_stat	dr_stat;
+};
+
+static bool
+lnet_fault_nid_match(lnet_nid_t nid, lnet_nid_t msg_nid)
+{
+	if (nid == msg_nid || nid == LNET_NID_ANY)
+		return true;
+
+	if (LNET_NIDNET(nid) != LNET_NIDNET(msg_nid))
+		return false;
+
+	/* 255.255.255.255 at net is wildcard for all addresses in a network */
+	return LNET_NIDADDR(nid) == LNET_NIDADDR(LNET_NID_ANY);
+}
+
+static bool
+lnet_fault_attr_match(struct lnet_fault_attr *attr, lnet_nid_t src,
+		      lnet_nid_t dst, unsigned int type, unsigned int portal)
+{
+	if (!lnet_fault_nid_match(attr->fa_src, src) ||
+	    !lnet_fault_nid_match(attr->fa_dst, dst))
+		return false;
+
+	if (!(attr->fa_msg_mask & (1 << type)))
+		return false;
+
+	/**
+	 * NB: ACK and REPLY have no portal, but they should have been
+	 * rejected by message mask
+	 */
+	if (attr->fa_ptl_mask && /* has portal filter */
+	    !(attr->fa_ptl_mask & (1ULL << portal)))
+		return false;
+
+	return true;
+}
+
+static int
+lnet_fault_attr_validate(struct lnet_fault_attr *attr)
+{
+	if (!attr->fa_msg_mask)
+		attr->fa_msg_mask = LNET_MSG_MASK; /* all message types */
+
+	if (!attr->fa_ptl_mask) /* no portal filter */
+		return 0;
+
+	/* NB: only PUT and GET can be filtered if portal filter has been set */
+	attr->fa_msg_mask &= LNET_GET_BIT | LNET_PUT_BIT;
+	if (!attr->fa_msg_mask) {
+		CDEBUG(D_NET, "can't find valid message type bits %x\n",
+		       attr->fa_msg_mask);
+		return -EINVAL;
+	}
+	return 0;
+}
+
+static void
+lnet_fault_stat_inc(struct lnet_fault_stat *stat, unsigned int type)
+{
+	/* NB: fs_counter is NOT updated by this function */
+	switch (type) {
+	case LNET_MSG_PUT:
+		stat->fs_put++;
+		return;
+	case LNET_MSG_ACK:
+		stat->fs_ack++;
+		return;
+	case LNET_MSG_GET:
+		stat->fs_get++;
+		return;
+	case LNET_MSG_REPLY:
+		stat->fs_reply++;
+		return;
+	}
+}
+
+/**
+ * Add a new drop rule to LNet
+ * There is no check for duplicated drop rule, all rules will be checked for
+ * incoming message.
+ */
+static int
+lnet_drop_rule_add(struct lnet_fault_attr *attr)
+{
+	struct lnet_drop_rule *rule;
+
+	if (!attr->u.drop.da_rate == !attr->u.drop.da_interval) {
+		CDEBUG(D_NET, "invalid rate %d or interval %d\n",
+		       attr->u.drop.da_rate, attr->u.drop.da_interval);
+		return -EINVAL;
+	}
+
+	if (lnet_fault_attr_validate(attr))
+		return -EINVAL;
+
+	CFS_ALLOC_PTR(rule);
+	if (!rule)
+		return -ENOMEM;
+
+	spin_lock_init(&rule->dr_lock);
+
+	rule->dr_attr = *attr;
+	if (attr->u.drop.da_interval) {
+		rule->dr_time_base = cfs_time_shift(attr->u.drop.da_interval);
+		rule->dr_drop_time = cfs_time_shift(cfs_rand() %
+						    attr->u.drop.da_interval);
+	} else {
+		rule->dr_drop_at = cfs_rand() % attr->u.drop.da_rate;
+	}
+
+	lnet_net_lock(LNET_LOCK_EX);
+	list_add(&rule->dr_link, &the_lnet.ln_drop_rules);
+	lnet_net_unlock(LNET_LOCK_EX);
+
+	CDEBUG(D_NET, "Added drop rule: src %s, dst %s, rate %d, interval %d\n",
+	       libcfs_nid2str(attr->fa_src), libcfs_nid2str(attr->fa_src),
+	       attr->u.drop.da_rate, attr->u.drop.da_interval);
+	return 0;
+}
+
+/**
+ * Remove matched drop rules from lnet, all rules that can match \a src and
+ * \a dst will be removed.
+ * If \a src is zero, then all rules have \a dst as destination will be remove
+ * If \a dst is zero, then all rules have \a src as source will be removed
+ * If both of them are zero, all rules will be removed
+ */
+static int
+lnet_drop_rule_del(lnet_nid_t src, lnet_nid_t dst)
+{
+	struct lnet_drop_rule *rule;
+	struct lnet_drop_rule *tmp;
+	struct list_head zombies;
+	int n = 0;
+
+	INIT_LIST_HEAD(&zombies);
+
+	lnet_net_lock(LNET_LOCK_EX);
+	list_for_each_entry_safe(rule, tmp, &the_lnet.ln_drop_rules, dr_link) {
+		if (rule->dr_attr.fa_src != src && src)
+			continue;
+
+		if (rule->dr_attr.fa_dst != dst && dst)
+			continue;
+
+		list_move(&rule->dr_link, &zombies);
+	}
+	lnet_net_unlock(LNET_LOCK_EX);
+
+	list_for_each_entry_safe(rule, tmp, &zombies, dr_link) {
+		CDEBUG(D_NET, "Remove drop rule: src %s->dst: %s (1/%d, %d)\n",
+		       libcfs_nid2str(rule->dr_attr.fa_src),
+		       libcfs_nid2str(rule->dr_attr.fa_dst),
+		       rule->dr_attr.u.drop.da_rate,
+		       rule->dr_attr.u.drop.da_interval);
+
+		list_del(&rule->dr_link);
+		CFS_FREE_PTR(rule);
+		n++;
+	}
+
+	return n;
+}
+
+/**
+ * List drop rule at position of \a pos
+ */
+static int
+lnet_drop_rule_list(int pos, struct lnet_fault_attr *attr,
+		    struct lnet_fault_stat *stat)
+{
+	struct lnet_drop_rule *rule;
+	int cpt;
+	int i = 0;
+	int rc = -ENOENT;
+
+	cpt = lnet_net_lock_current();
+	list_for_each_entry(rule, &the_lnet.ln_drop_rules, dr_link) {
+		if (i++ < pos)
+			continue;
+
+		spin_lock(&rule->dr_lock);
+		*attr = rule->dr_attr;
+		*stat = rule->dr_stat;
+		spin_unlock(&rule->dr_lock);
+		rc = 0;
+		break;
+	}
+
+	lnet_net_unlock(cpt);
+	return rc;
+}
+
+/**
+ * reset counters for all drop rules
+ */
+static void
+lnet_drop_rule_reset(void)
+{
+	struct lnet_drop_rule *rule;
+	int cpt;
+
+	cpt = lnet_net_lock_current();
+
+	list_for_each_entry(rule, &the_lnet.ln_drop_rules, dr_link) {
+		struct lnet_fault_attr *attr = &rule->dr_attr;
+
+		spin_lock(&rule->dr_lock);
+
+		memset(&rule->dr_stat, 0, sizeof(rule->dr_stat));
+		if (attr->u.drop.da_rate) {
+			rule->dr_drop_at = cfs_rand() % attr->u.drop.da_rate;
+		} else {
+			rule->dr_drop_time = cfs_time_shift(cfs_rand() %
+						attr->u.drop.da_interval);
+			rule->dr_time_base = cfs_time_shift(attr->u.drop.da_interval);
+		}
+		spin_unlock(&rule->dr_lock);
+	}
+
+	lnet_net_unlock(cpt);
+}
+
+/**
+ * check source/destination NID, portal, message type and drop rate,
+ * decide whether should drop this message or not
+ */
+static bool
+drop_rule_match(struct lnet_drop_rule *rule, lnet_nid_t src,
+		lnet_nid_t dst, unsigned int type, unsigned int portal)
+{
+	struct lnet_fault_attr *attr = &rule->dr_attr;
+	bool drop;
+
+	if (!lnet_fault_attr_match(attr, src, dst, type, portal))
+		return false;
+
+	/* match this rule, check drop rate now */
+	spin_lock(&rule->dr_lock);
+	if (rule->dr_drop_time) { /* time based drop */
+		unsigned long now = cfs_time_current();
+
+		rule->dr_stat.fs_count++;
+		drop = cfs_time_aftereq(now, rule->dr_drop_time);
+		if (drop) {
+			if (cfs_time_after(now, rule->dr_time_base))
+				rule->dr_time_base = now;
+
+			rule->dr_drop_time = rule->dr_time_base +
+					     cfs_time_seconds(cfs_rand() %
+						attr->u.drop.da_interval);
+			rule->dr_time_base += cfs_time_seconds(attr->u.drop.da_interval);
+
+			CDEBUG(D_NET, "Drop Rule %s->%s: next drop : %lu\n",
+			       libcfs_nid2str(attr->fa_src),
+			       libcfs_nid2str(attr->fa_dst),
+			       rule->dr_drop_time);
+		}
+
+	} else { /* rate based drop */
+		drop = rule->dr_stat.fs_count++ == rule->dr_drop_at;
+
+		if (!do_div(rule->dr_stat.fs_count, attr->u.drop.da_rate)) {
+			rule->dr_drop_at = rule->dr_stat.fs_count +
+					   cfs_rand() % attr->u.drop.da_rate;
+			CDEBUG(D_NET, "Drop Rule %s->%s: next drop: %lu\n",
+			       libcfs_nid2str(attr->fa_src),
+			       libcfs_nid2str(attr->fa_dst), rule->dr_drop_at);
+		}
+	}
+
+	if (drop) { /* drop this message, update counters */
+		lnet_fault_stat_inc(&rule->dr_stat, type);
+		rule->dr_stat.u.drop.ds_dropped++;
+	}
+
+	spin_unlock(&rule->dr_lock);
+	return drop;
+}
+
+/**
+ * Check if message from \a src to \a dst can match any existed drop rule
+ */
+bool
+lnet_drop_rule_match(lnet_hdr_t *hdr)
+{
+	struct lnet_drop_rule *rule;
+	lnet_nid_t src = le64_to_cpu(hdr->src_nid);
+	lnet_nid_t dst = le64_to_cpu(hdr->dest_nid);
+	unsigned int typ = le32_to_cpu(hdr->type);
+	unsigned int ptl = -1;
+	bool drop = false;
+	int cpt;
+
+	/**
+	 * NB: if Portal is specified, then only PUT and GET will be
+	 * filtered by drop rule
+	 */
+	if (typ == LNET_MSG_PUT)
+		ptl = le32_to_cpu(hdr->msg.put.ptl_index);
+	else if (typ == LNET_MSG_GET)
+		ptl = le32_to_cpu(hdr->msg.get.ptl_index);
+
+	cpt = lnet_net_lock_current();
+	list_for_each_entry(rule, &the_lnet.ln_drop_rules, dr_link) {
+		drop = drop_rule_match(rule, src, dst, typ, ptl);
+		if (drop)
+			break;
+	}
+
+	lnet_net_unlock(cpt);
+	return drop;
+}
+
+int
+lnet_fault_ctl(int opc, struct libcfs_ioctl_data *data)
+{
+	struct lnet_fault_attr *attr;
+	struct lnet_fault_stat *stat;
+
+	attr = (struct lnet_fault_attr *)data->ioc_inlbuf1;
+
+	switch (opc) {
+	default:
+		return -EINVAL;
+
+	case LNET_CTL_DROP_ADD:
+		if (!attr)
+			return -EINVAL;
+
+		return lnet_drop_rule_add(attr);
+
+	case LNET_CTL_DROP_DEL:
+		if (!attr)
+			return -EINVAL;
+
+		data->ioc_count = lnet_drop_rule_del(attr->fa_src,
+						     attr->fa_dst);
+		return 0;
+
+	case LNET_CTL_DROP_RESET:
+		lnet_drop_rule_reset();
+		return 0;
+
+	case LNET_CTL_DROP_LIST:
+		stat = (struct lnet_fault_stat *)data->ioc_inlbuf2;
+		if (!attr || !stat)
+			return -EINVAL;
+
+		return lnet_drop_rule_list(data->ioc_count, attr, stat);
+	}
+}
+
+int
+lnet_fault_init(void)
+{
+	CLASSERT(LNET_PUT_BIT == 1 << LNET_MSG_PUT);
+	CLASSERT(LNET_ACK_BIT == 1 << LNET_MSG_ACK);
+	CLASSERT(LNET_GET_BIT == 1 << LNET_MSG_GET);
+	CLASSERT(LNET_REPLY_BIT == 1 << LNET_MSG_REPLY);
+
+	return 0;
+}
+
+void
+lnet_fault_fini(void)
+{
+	lnet_drop_rule_del(0, 0);
+
+	LASSERT(list_empty(&the_lnet.ln_drop_rules));
+}
-- 
1.7.1
