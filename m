Return-Path: <SRS0=o51I=JC=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.7 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7D592C43461
	for <lustre-devel@archiver.kernel.org>; Mon,  5 Apr 2021 00:51:39 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 2345861396
	for <lustre-devel@archiver.kernel.org>; Mon,  5 Apr 2021 00:51:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2345861396
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 33D4C21FB1A;
	Mon,  5 Apr 2021 00:51:31 +0000 (UTC)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 743D021F700
 for <lustre-devel@lists.lustre.org>; Mon,  5 Apr 2021 00:51:21 +0000 (UTC)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id B2CA96CE;
 Sun,  4 Apr 2021 20:51:16 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id B0D5D90AA8; Sun,  4 Apr 2021 20:51:16 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun,  4 Apr 2021 20:50:41 -0400
Message-Id: <1617583870-32029-13-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1617583870-32029-1-git-send-email-jsimmons@infradead.org>
References: <1617583870-32029-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 12/41] lnet: UDSP handling
X-BeenThere: lustre-devel@lists.lustre.org
X-Mailman-Version: 2.1.23
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
Cc: Serguei Smirnov <ssmirnov@whamcloud.com>,
 Amir Shehata <ashehata@whamcloud.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Amir Shehata <ashehata@whamcloud.com>

This patch adds the following functionality:
1. Add UDSPs
2. Delete UDSPs
3. Apply UDSPs

- Adding a local network udsp: if multiple local networks are
available, each one can have a priority.
- Adding a local NID udsp: after a local network is chosen,
if there are multiple NIs, each one can have a priority.
- Adding a remote NID udsp: assign priority to peer NIDs.
- Adding a NID pair udsp: allows to specify local] NIDs
to be added to the list on the specified peer NIs. When
selecting a peer NI, the one with the local NID being used
on its list is preferred.
- Adding a Router udsp: similar to the NID pair udsp.
Specified router NIDs are added on the list on the specified
peer NIs. When sending to the remote peer, remote net is
selected and the peer NID is selected. The router which has
its nid on the peer NI list is preferred.
- Deleting a udsp: use the specified policy index to remove it
from the policy list.

Generally, the syntax is as follows
 lnetctl policy <add | del | show>
  --src: ip2nets syntax specifying the local NID to match
  --dst: ip2nets syntax specifying the remote NID to match
  --rte: ip2nets syntax specifying the router NID to match
  --priority: Priority to apply to rule matches
  --idx: Index of where to insert the rule. By default it appends
     to the end of the rule list

WC-bug-id: https://jira.whamcloud.com/browse/LU-9121
Lustre-commit: e5ea6387eb9f882 ("LU-9121 lnet: UDSP handling")
Signed-off-by: Amir Shehata <ashehata@whamcloud.com>
Signed-off-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/34354
Reviewed-by: Chris Horn <chris.horn@hpe.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/lib-lnet.h    |   38 ++
 include/linux/lnet/udsp.h        |  117 +++++
 include/uapi/linux/lnet/nidstr.h |    4 +
 net/lnet/lnet/Makefile           |    2 +-
 net/lnet/lnet/api-ni.c           |   87 ++++
 net/lnet/lnet/nidstrings.c       |   66 +++
 net/lnet/lnet/peer.c             |    6 +
 net/lnet/lnet/udsp.c             | 1051 ++++++++++++++++++++++++++++++++++++++
 8 files changed, 1370 insertions(+), 1 deletion(-)
 create mode 100644 include/linux/lnet/udsp.h
 create mode 100644 net/lnet/lnet/udsp.c

diff --git a/include/linux/lnet/lib-lnet.h b/include/linux/lnet/lib-lnet.h
index 5152c0a70..1efac9b 100644
--- a/include/linux/lnet/lib-lnet.h
+++ b/include/linux/lnet/lib-lnet.h
@@ -95,6 +95,7 @@
 extern struct kmem_cache *lnet_small_mds_cachep; /* <= LNET_SMALL_MD_SIZE bytes
 						  * MDs kmem_cache
 						  */
+extern struct kmem_cache *lnet_udsp_cachep;
 extern struct kmem_cache *lnet_rspt_cachep;
 extern struct kmem_cache *lnet_msg_cachep;
 
@@ -513,6 +514,11 @@ int lnet_get_peer_list(u32 *countp, u32 *sizep,
 		       struct lnet_process_id __user *ids);
 extern void lnet_peer_ni_set_healthv(lnet_nid_t nid, int value, bool all);
 extern void lnet_peer_ni_add_to_recoveryq_locked(struct lnet_peer_ni *lpni);
+extern int lnet_peer_add_pref_nid(struct lnet_peer_ni *lpni, lnet_nid_t nid);
+extern void lnet_peer_clr_pref_nids(struct lnet_peer_ni *lpni);
+extern int lnet_peer_del_pref_nid(struct lnet_peer_ni *lpni, lnet_nid_t nid);
+void lnet_peer_ni_set_selection_priority(struct lnet_peer_ni *lpni,
+					 u32 priority);
 
 void lnet_router_debugfs_init(void);
 void lnet_router_debugfs_fini(void);
@@ -531,6 +537,8 @@ void lnet_rtr_transfer_to_peer(struct lnet_peer *src,
 int lnet_dyn_del_ni(struct lnet_ioctl_config_ni *conf);
 int lnet_clear_lazy_portal(struct lnet_ni *ni, int portal, char *reason);
 struct lnet_net *lnet_get_net_locked(u32 net_id);
+void lnet_net_clr_pref_rtrs(struct lnet_net *net);
+int lnet_net_add_pref_rtr(struct lnet_net *net, lnet_nid_t gw_nid);
 
 int lnet_islocalnid(lnet_nid_t nid);
 int lnet_islocalnet(u32 net);
@@ -670,6 +678,17 @@ int lnet_delay_rule_list(int pos, struct lnet_fault_attr *attr,
 void lnet_counters_get_common(struct lnet_counters_common *common);
 int lnet_counters_get(struct lnet_counters *counters);
 void lnet_counters_reset(void);
+static inline void
+lnet_ni_set_sel_priority_locked(struct lnet_ni *ni, u32 priority)
+{
+	ni->ni_sel_priority = priority;
+}
+
+static inline void
+lnet_net_set_sel_priority_locked(struct lnet_net *net, u32 priority)
+{
+	net->net_sel_priority = priority;
+}
 
 unsigned int lnet_iov_nob(unsigned int niov, struct kvec *iov);
 unsigned int lnet_kiov_nob(unsigned int niov, struct bio_vec *iov);
@@ -825,6 +844,13 @@ int lnet_get_peer_ni_info(u32 peer_index, u64 *nid,
 			  u32 *peer_tx_qnob);
 int lnet_get_peer_ni_hstats(struct lnet_ioctl_peer_ni_hstats *stats);
 
+static inline void
+lnet_peer_net_set_sel_priority_locked(struct lnet_peer_net *lpn, u32 priority)
+{
+	lpn->lpn_sel_priority = priority;
+}
+
+
 static inline struct lnet_peer_net *
 lnet_find_peer_net_locked(struct lnet_peer *peer, u32 net_id)
 {
@@ -968,6 +994,18 @@ int lnet_get_peer_ni_info(u32 peer_index, u64 *nid,
 	lnet_atomic_add_unless_max(healthv, value, LNET_MAX_HEALTH_VALUE);
 }
 
+static inline int
+lnet_get_list_len(struct list_head *list)
+{
+	struct list_head *l;
+	int count = 0;
+
+	list_for_each(l, list)
+		count++;
+
+	return count;
+}
+
 void lnet_incr_stats(struct lnet_element_stats *stats,
 		     enum lnet_msg_type msg_type,
 		     enum lnet_stats_type stats_type);
diff --git a/include/linux/lnet/udsp.h b/include/linux/lnet/udsp.h
new file mode 100644
index 0000000..265cb42
--- /dev/null
+++ b/include/linux/lnet/udsp.h
@@ -0,0 +1,117 @@
+// SPDX-License-Identifier: GPL-2.0
+/*
+ * Copyright (c) 2007, 2010, Oracle and/or its affiliates. All rights reserved.
+ *
+ * Copyright (c) 2011, 2017, Intel Corporation.
+ *
+ * Copyright (c) 2018-2020 Data Direct Networks.
+ *
+ *   This file is part of Lustre, https://wiki.whamcloud.com/
+ *
+ *   Portals is free software; you can redistribute it and/or
+ *   modify it under the terms of version 2 of the GNU General Public
+ *   License as published by the Free Software Foundation.
+ *
+ *   Portals is distributed in the hope that it will be useful,
+ *   but WITHOUT ANY WARRANTY; without even the implied warranty of
+ *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ *   GNU General Public License for more details.
+ *
+ *   You should have received a copy of the GNU General Public License
+ *   version 2 along with this program; If not, see
+ *   http://www.gnu.org/licenses/gpl-2.0.html
+ *
+ * Author: Amir Shehata
+ */
+
+#ifndef UDSP_H
+#define UDSP_H
+
+#include <linux/lnet/lib-lnet.h>
+
+/**
+ * lnet_udsp_add_policy
+ *	Add a policy \new in position \idx
+ *	Must be called with api_mutex held
+ */
+int lnet_udsp_add_policy(struct lnet_udsp *new, int idx);
+
+/**
+ * lnet_udsp_get_policy
+ *	get a policy in position \idx
+ *	Must be called with api_mutex held
+ */
+struct lnet_udsp *lnet_udsp_get_policy(int idx);
+
+/**
+ * lnet_udsp_del_policy
+ *	Delete a policy from position \idx
+ *	Must be called with api_mutex held
+ */
+int lnet_udsp_del_policy(int idx);
+
+/**
+ * lnet_udsp_apply_policies
+ *	apply all stored policies across the system
+ *	Must be called with api_mutex held
+ *	Must NOT be called with lnet_net_lock held
+ *	udsp: NULL to apply on all existing udsps
+ *	      non-NULL to apply to specified udsp
+ *	revert: true to revert policy application
+ */
+int lnet_udsp_apply_policies(struct lnet_udsp *udsp, bool revert);
+
+/**
+ * lnet_udsp_apply_policies_on_lpni
+ *	apply all stored policies on specified \lpni
+ *	Must be called with api_mutex held
+ *	Must be called with LNET_LOCK_EX
+ */
+int lnet_udsp_apply_policies_on_lpni(struct lnet_peer_ni *lpni);
+
+/**
+ * lnet_udsp_apply_policies_on_lpn
+ *	Must be called with api_mutex held
+ *	apply all stored policies on specified \lpn
+ *	Must be called with LNET_LOCK_EX
+ */
+int lnet_udsp_apply_policies_on_lpn(struct lnet_peer_net *lpn);
+
+/**
+ * lnet_udsp_apply_policies_on_ni
+ *	apply all stored policies on specified \ni
+ *	Must be called with api_mutex held
+ *	Must be called with LNET_LOCK_EX
+ */
+int lnet_udsp_apply_policies_on_ni(struct lnet_ni *ni);
+
+/**
+ * lnet_udsp_apply_policies_on_net
+ *	apply all stored policies on specified \net
+ *	Must be called with api_mutex held
+ *	Must be called with LNET_LOCK_EX
+ */
+int lnet_udsp_apply_policies_on_net(struct lnet_net *net);
+
+/**
+ * lnet_udsp_alloc
+ *	Allocates a UDSP block and initializes it.
+ *	Return NULL if allocation fails
+ *	pointer to UDSP otherwise.
+ */
+struct lnet_udsp *lnet_udsp_alloc(void);
+
+/**
+ * lnet_udsp_free
+ *	Free a UDSP and all its descriptors
+ */
+void lnet_udsp_free(struct lnet_udsp *udsp);
+
+/**
+ * lnet_udsp_destroy
+ *	Free all the UDSPs
+ *	force: true to indicate shutdown in progress
+ */
+void lnet_udsp_destroy(bool shutdown);
+
+#endif /* UDSP_H */
diff --git a/include/uapi/linux/lnet/nidstr.h b/include/uapi/linux/lnet/nidstr.h
index 34ba497..021ee0e 100644
--- a/include/uapi/linux/lnet/nidstr.h
+++ b/include/uapi/linux/lnet/nidstr.h
@@ -97,6 +97,10 @@ static inline char *libcfs_nid2str(lnet_nid_t nid)
 int cfs_parse_nidlist(char *str, int len, struct list_head *list);
 int cfs_print_nidlist(char *buffer, int count, struct list_head *list);
 int cfs_match_nid(lnet_nid_t nid, struct list_head *list);
+int cfs_match_nid_net(lnet_nid_t nid, __u32 net, struct list_head *net_num_list,
+		      struct list_head *addr);
+int cfs_match_net(__u32 net_id, __u32 net_type,
+		  struct list_head *net_num_list);
 
 int cfs_ip_addr_parse(char *str, int len, struct list_head *list);
 int cfs_ip_addr_match(__u32 addr, struct list_head *list);
diff --git a/net/lnet/lnet/Makefile b/net/lnet/lnet/Makefile
index 4442e07..9918008 100644
--- a/net/lnet/lnet/Makefile
+++ b/net/lnet/lnet/Makefile
@@ -2,7 +2,7 @@
 
 obj-$(CONFIG_LNET) += lnet.o
 
-lnet-y := api-ni.o config.o nidstrings.o net_fault.o		\
+lnet-y := api-ni.o config.o nidstrings.o net_fault.o udsp.o	\
 	  lib-me.o lib-msg.o lib-md.o lib-ptl.o			\
 	  lib-socket.o lib-move.o module.o lo.o			\
 	  router.o router_proc.o acceptor.o peer.o
diff --git a/net/lnet/lnet/api-ni.c b/net/lnet/lnet/api-ni.c
index 2c31b06..4809c76 100644
--- a/net/lnet/lnet/api-ni.c
+++ b/net/lnet/lnet/api-ni.c
@@ -36,6 +36,7 @@
 #include <linux/ktime.h>
 #include <linux/moduleparam.h>
 
+#include <linux/lnet/udsp.h>
 #include <linux/lnet/lib-lnet.h>
 #include <uapi/linux/lnet/lnet-dlc.h>
 
@@ -538,6 +539,7 @@ static int lnet_discover(struct lnet_process_id id, u32 force,
 struct kmem_cache *lnet_small_mds_cachep;  /* <= LNET_SMALL_MD_SIZE bytes
 					    *  MDs kmem_cache
 					    */
+struct kmem_cache *lnet_udsp_cachep;	   /* udsp cache */
 struct kmem_cache *lnet_rspt_cachep;	   /* response tracker cache */
 struct kmem_cache *lnet_msg_cachep;
 
@@ -558,6 +560,12 @@ static int lnet_discover(struct lnet_process_id id, u32 force,
 	if (!lnet_small_mds_cachep)
 		return -ENOMEM;
 
+	lnet_udsp_cachep = kmem_cache_create("lnet_udsp",
+					     sizeof(struct lnet_udsp),
+					     0, 0, NULL);
+	if (!lnet_udsp_cachep)
+		return -ENOMEM;
+
 	lnet_rspt_cachep = kmem_cache_create("lnet_rspt",
 					     sizeof(struct lnet_rsp_tracker),
 					     0, 0, NULL);
@@ -582,6 +590,9 @@ static int lnet_discover(struct lnet_process_id id, u32 force,
 	kmem_cache_destroy(lnet_rspt_cachep);
 	lnet_rspt_cachep = NULL;
 
+	kmem_cache_destroy(lnet_udsp_cachep);
+	lnet_udsp_cachep = NULL;
+
 	kmem_cache_destroy(lnet_small_mds_cachep);
 	lnet_small_mds_cachep = NULL;
 
@@ -1261,6 +1272,7 @@ struct list_head **
 		the_lnet.ln_counters = NULL;
 	}
 	lnet_destroy_remote_nets_table();
+	lnet_udsp_destroy(true);
 	lnet_slab_cleanup();
 
 	return 0;
@@ -1313,6 +1325,81 @@ struct lnet_net *
 	return NULL;
 }
 
+void
+lnet_net_clr_pref_rtrs(struct lnet_net *net)
+{
+	struct list_head zombies;
+	struct lnet_nid_list *ne;
+	struct lnet_nid_list *tmp;
+
+	INIT_LIST_HEAD(&zombies);
+
+	lnet_net_lock(LNET_LOCK_EX);
+	list_splice_init(&net->net_rtr_pref_nids, &zombies);
+	lnet_net_unlock(LNET_LOCK_EX);
+
+	list_for_each_entry_safe(ne, tmp, &zombies, nl_list) {
+		list_del_init(&ne->nl_list);
+		kfree(ne);
+	}
+}
+
+int
+lnet_net_add_pref_rtr(struct lnet_net *net,
+		      lnet_nid_t gw_nid)
+__must_hold(&the_lnet.ln_api_mutex)
+{
+	struct lnet_nid_list *ne;
+
+	/* This function is called with api_mutex held. When the api_mutex
+	 * is held the list can not be modified, as it is only modified as
+	 * a result of applying a UDSP and that happens under api_mutex
+	 * lock.
+	 */
+	list_for_each_entry(ne, &net->net_rtr_pref_nids, nl_list) {
+		if (ne->nl_nid == gw_nid)
+			return -EEXIST;
+	}
+
+	ne = kzalloc(sizeof(*ne), GFP_KERNEL);
+	if (!ne)
+		return -ENOMEM;
+
+	ne->nl_nid = gw_nid;
+
+	/* Lock the cpt to protect against addition and checks in the
+	 * selection algorithm
+	 */
+	lnet_net_lock(LNET_LOCK_EX);
+	list_add(&ne->nl_list, &net->net_rtr_pref_nids);
+	lnet_net_unlock(LNET_LOCK_EX);
+
+	return 0;
+}
+
+bool
+lnet_net_is_pref_rtr_locked(struct lnet_net *net, lnet_nid_t rtr_nid)
+{
+	struct lnet_nid_list *ne;
+
+	CDEBUG(D_NET, "%s: rtr pref emtpy: %d\n",
+	       libcfs_net2str(net->net_id),
+	       list_empty(&net->net_rtr_pref_nids));
+
+	if (list_empty(&net->net_rtr_pref_nids))
+		return false;
+
+	list_for_each_entry(ne, &net->net_rtr_pref_nids, nl_list) {
+		CDEBUG(D_NET, "Comparing pref %s with gw %s\n",
+		       libcfs_nid2str(ne->nl_nid),
+		       libcfs_nid2str(rtr_nid));
+		if (rtr_nid == ne->nl_nid)
+			return true;
+	}
+
+	return false;
+}
+
 unsigned int
 lnet_nid_cpt_hash(lnet_nid_t nid, unsigned int number)
 {
diff --git a/net/lnet/lnet/nidstrings.c b/net/lnet/lnet/nidstrings.c
index f260092..b1cd86b 100644
--- a/net/lnet/lnet/nidstrings.c
+++ b/net/lnet/lnet/nidstrings.c
@@ -706,6 +706,72 @@ int cfs_print_nidlist(char *buffer, int count, struct list_head *nidlist)
 static const size_t libcfs_nnetstrfns = ARRAY_SIZE(libcfs_netstrfns);
 
 static struct netstrfns *
+type2net_info(u32 net_type)
+{
+	int i;
+
+	for (i = 0; i < libcfs_nnetstrfns; i++) {
+		if (libcfs_netstrfns[i].nf_type == net_type)
+			return &libcfs_netstrfns[i];
+	}
+
+	return NULL;
+}
+
+int
+cfs_match_net(u32 net_id, u32 net_type, struct list_head *net_num_list)
+{
+	u32 net_num;
+
+	if (!net_num_list)
+		return 0;
+
+	if (net_type != LNET_NETTYP(net_id))
+		return 0;
+
+	net_num = LNET_NETNUM(net_id);
+
+	/* if there is a net number but the list passed in is empty, then
+	 * there is no match.
+	 */
+	if (!net_num && list_empty(net_num_list))
+		return 1;
+	else if (list_empty(net_num_list))
+		return 0;
+
+	if (!libcfs_num_match(net_num, net_num_list))
+		return 0;
+
+	return 1;
+}
+
+int
+cfs_match_nid_net(lnet_nid_t nid, u32 net_type,
+		  struct list_head *net_num_list,
+		  struct list_head *addr)
+{
+	u32 address;
+	struct netstrfns *nf;
+
+	if (!addr || !net_num_list)
+		return 0;
+
+	nf = type2net_info(LNET_NETTYP(LNET_NIDNET(nid)));
+	if (!nf || !net_num_list || !addr)
+		return 0;
+
+	address = LNET_NIDADDR(nid);
+
+	/* if either the address or net number don't match then no match */
+	if (!nf->nf_match_addr(address, addr) ||
+	    !cfs_match_net(LNET_NIDNET(nid), net_type, net_num_list))
+		return 0;
+
+	return 1;
+}
+EXPORT_SYMBOL(cfs_match_nid_net);
+
+static struct netstrfns *
 libcfs_lnd2netstrfns(u32 lnd)
 {
 	int i;
diff --git a/net/lnet/lnet/peer.c b/net/lnet/lnet/peer.c
index bbd43c8..b4b8edd 100644
--- a/net/lnet/lnet/peer.c
+++ b/net/lnet/lnet/peer.c
@@ -1054,6 +1054,12 @@ struct lnet_peer_ni *
 	return rc;
 }
 
+void
+lnet_peer_ni_set_selection_priority(struct lnet_peer_ni *lpni, u32 priority)
+{
+	lpni->lpni_sel_priority = priority;
+}
+
 /*
  * Clear the preferred NIDs from a non-multi-rail peer.
  */
diff --git a/net/lnet/lnet/udsp.c b/net/lnet/lnet/udsp.c
new file mode 100644
index 0000000..85e31fe
--- /dev/null
+++ b/net/lnet/lnet/udsp.c
@@ -0,0 +1,1051 @@
+// SPDX-License-Identifier: GPL-2.0
+/*
+ * Copyright (c) 2007, 2010, Oracle and/or its affiliates. All rights reserved.
+ *
+ * Copyright (c) 2011, 2017, Intel Corporation.
+ *
+ * Copyright (c) 2018-2020 Data Direct Networks.
+ *
+ *   This file is part of Lustre, https://wiki.whamcloud.com/
+ *
+ *   Portals is free software; you can redistribute it and/or
+ *   modify it under the terms of version 2 of the GNU General Public
+ *   License as published by the Free Software Foundation.
+ *
+ *   Portals is distributed in the hope that it will be useful,
+ *   but WITHOUT ANY WARRANTY; without even the implied warranty of
+ *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ *   GNU General Public License for more details.
+ *
+ *   You should have received a copy of the GNU General Public License
+ *   version 2 along with this program; If not, see
+ *   http://www.gnu.org/licenses/gpl-2.0.html
+ *
+ *   net/lnet/lnet/udsp.c
+ *
+ *   User Defined Selection Policies (UDSP) are introduced to add
+ *   ability of fine traffic control. The policies are instantiated
+ *   on LNet constructs and allow preference of some constructs
+ *   over others as an extension of the selection algorithm.
+ *   The order of operation is defined by the selection algorithm logical flow:
+ *
+ *   1. Iterate over all the networks that a peer can be reached on
+ *      and select the best local network
+ *      - The remote network with the highest priority is examined
+ *        (Network Rule)
+ *      - The local network with the highest priority is selected
+ *        (Network Rule)
+ *      - The local NI with the highest priority is selected
+ *        (NID Rule)
+ *   2. If the peer is a remote peer and has no local networks,
+ *      - then select the remote peer network with the highest priority
+ *        (Network Rule)
+ *      - Select the highest priority remote peer_ni on the network selected
+ *        (NID Rule)
+ *      - Now that the peer's network and NI are decided, select the router
+ *        in round robin from the peer NI's preferred router list.
+ *        (Router Rule)
+ *      - Select the highest priority local NI on the local net of the
+ *        selected route.
+ *        (NID Rule)
+ *   3. Otherwise for local peers, select the peer_ni from the peer.
+ *      - highest priority peer NI is selected
+ *        (NID Rule)
+ *      - Select the peer NI which has the local NI selected on its
+ *        preferred list.
+ *        (NID Pair Rule)
+ *
+ *   Accordingly, the User Interface allows for the following:
+ *   - Adding a local network udsp: if multiple local networks are
+ *     available, each one can have a priority.
+ *   - Adding a local NID udsp: after a local network is chosen,
+ *     if there are multiple NIs, each one can have a priority.
+ *   - Adding a remote NID udsp: assign priority to a peer NID.
+ *   - Adding a NID pair udsp: allows to specify local NIDs
+ *     to be added on the list on the specified peer NIs
+ *     When selecting a peer NI, the one with the
+ *     local NID being used on its list is preferred.
+ *   - Adding a Router udsp: similar to the NID pair udsp.
+ *     Specified router NIDs are added on the list on the specified peer NIs.
+ *     When sending to a remote peer, remote net is selected and the peer NID
+ *     is selected. The router which has its nid on the peer NI list
+ *     is preferred.
+ *   - Deleting a udsp: use the specified policy index to remove it
+ *     from the policy list.
+ *
+ *   Generally, the syntax is as follows
+ *     lnetctl policy <add | del | show>
+ *      --src:      ip2nets syntax specifying the local NID to match
+ *      --dst:      ip2nets syntax specifying the remote NID to match
+ *      --rte:      ip2nets syntax specifying the router NID to match
+ *      --priority: Priority to apply to rule matches
+ *      --idx:      Index of where to insert or delete the rule
+ *                  By default add appends to the end of the rule list
+ *
+ * Author: Amir Shehata
+ */
+
+#include <linux/uaccess.h>
+
+#include <linux/lnet/udsp.h>
+#include <linux/libcfs/libcfs.h>
+
+struct udsp_info {
+	struct lnet_peer_ni *udi_lpni;
+	struct lnet_peer_net *udi_lpn;
+	struct lnet_ni *udi_ni;
+	struct lnet_net *udi_net;
+	struct lnet_ud_nid_descr *udi_match;
+	struct lnet_ud_nid_descr *udi_action;
+	u32 udi_priority;
+	enum lnet_udsp_action_type udi_type;
+	bool udi_local;
+	bool udi_revert;
+};
+
+typedef int (*udsp_apply_rule)(struct udsp_info *);
+
+enum udsp_apply {
+	UDSP_APPLY_ON_PEERS = 0,
+	UDSP_APPLY_PRIO_ON_NIS = 1,
+	UDSP_APPLY_RTE_ON_NETS = 2,
+	UDSP_APPLY_MAX_ENUM = 3,
+};
+
+#define RULE_NOT_APPLICABLE -1
+
+static inline bool
+lnet_udsp_is_net_rule(struct lnet_ud_nid_descr *match)
+{
+	return list_empty(&match->ud_addr_range);
+}
+
+static bool
+lnet_udsp_expr_list_equal(struct list_head *e1,
+			  struct list_head *e2)
+{
+	struct cfs_expr_list *expr1;
+	struct cfs_expr_list *expr2;
+	struct cfs_range_expr *range1, *range2;
+
+	if (list_empty(e1) && list_empty(e2))
+		return true;
+
+	if (lnet_get_list_len(e1) != lnet_get_list_len(e2))
+		return false;
+
+	expr2 = list_first_entry(e2, struct cfs_expr_list, el_link);
+
+	list_for_each_entry(expr1, e1, el_link) {
+		if (lnet_get_list_len(&expr1->el_exprs) !=
+		    lnet_get_list_len(&expr2->el_exprs))
+			return false;
+
+		range2 = list_first_entry(&expr2->el_exprs,
+					  struct cfs_range_expr,
+					  re_link);
+
+		list_for_each_entry(range1, &expr1->el_exprs, re_link) {
+			if (range1->re_lo != range2->re_lo ||
+			    range1->re_hi != range2->re_hi ||
+			    range1->re_stride != range2->re_stride)
+				return false;
+			range2 = list_next_entry(range2, re_link);
+		}
+		expr2 = list_next_entry(expr2, el_link);
+	}
+
+	return true;
+}
+
+static bool
+lnet_udsp_nid_descr_equal(struct lnet_ud_nid_descr *e1,
+			  struct lnet_ud_nid_descr *e2)
+{
+	if (e1->ud_net_id.udn_net_type != e2->ud_net_id.udn_net_type ||
+	    !lnet_udsp_expr_list_equal(&e1->ud_net_id.udn_net_num_range,
+				       &e2->ud_net_id.udn_net_num_range) ||
+	    !lnet_udsp_expr_list_equal(&e1->ud_addr_range, &e2->ud_addr_range))
+		return false;
+
+	return true;
+}
+
+static bool
+lnet_udsp_action_equal(struct lnet_udsp *e1, struct lnet_udsp *e2)
+{
+	if (e1->udsp_action_type != e2->udsp_action_type)
+		return false;
+
+	if (e1->udsp_action_type == EN_LNET_UDSP_ACTION_PRIORITY &&
+	    e1->udsp_action.udsp_priority != e2->udsp_action.udsp_priority)
+		return false;
+
+	return true;
+}
+
+static bool
+lnet_udsp_equal(struct lnet_udsp *e1, struct lnet_udsp *e2)
+{
+	/* check each NID descr */
+	if (!lnet_udsp_nid_descr_equal(&e1->udsp_src, &e2->udsp_src) ||
+	    !lnet_udsp_nid_descr_equal(&e1->udsp_dst, &e2->udsp_dst) ||
+	    !lnet_udsp_nid_descr_equal(&e1->udsp_rte, &e2->udsp_rte))
+		return false;
+
+	return true;
+}
+
+/* it is enough to look at the net type of the descriptor. If the criteria
+ * is present the net must be specified
+ */
+static inline bool
+lnet_udsp_criteria_present(struct lnet_ud_nid_descr *descr)
+{
+	return (descr->ud_net_id.udn_net_type != 0);
+}
+
+static int
+lnet_udsp_apply_rule_on_ni(struct udsp_info *udi)
+{
+	int rc;
+	struct lnet_ni *ni = udi->udi_ni;
+	struct lnet_ud_nid_descr *ni_match = udi->udi_match;
+	u32 priority = (udi->udi_revert) ? -1 : udi->udi_priority;
+
+	rc = cfs_match_nid_net(ni->ni_nid,
+			       ni_match->ud_net_id.udn_net_type,
+			       &ni_match->ud_net_id.udn_net_num_range,
+			       &ni_match->ud_addr_range);
+	if (!rc)
+		return 0;
+
+	CDEBUG(D_NET, "apply udsp on ni %s\n",
+	       libcfs_nid2str(ni->ni_nid));
+
+	/* Detected match. Set NIDs priority */
+	lnet_ni_set_sel_priority_locked(ni, priority);
+
+	return 0;
+}
+
+static int
+lnet_udsp_apply_rte_list_on_net(struct lnet_net *net,
+				struct lnet_ud_nid_descr *rte_action,
+				bool revert)
+{
+	struct lnet_remotenet *rnet;
+	struct list_head *rn_list;
+	struct lnet_route *route;
+	struct lnet_peer_ni *lpni;
+	bool cleared = false;
+	lnet_nid_t gw_nid, gw_prim_nid;
+	int rc = 0;
+	int i;
+
+	for (i = 0; i < LNET_REMOTE_NETS_HASH_SIZE; i++) {
+		rn_list = &the_lnet.ln_remote_nets_hash[i];
+		list_for_each_entry(rnet, rn_list, lrn_list) {
+			list_for_each_entry(route, &rnet->lrn_routes, lr_list) {
+				/* look if gw nid on the same net matches */
+				gw_prim_nid = route->lr_gateway->lp_primary_nid;
+				lpni = NULL;
+				while ((lpni = lnet_get_next_peer_ni_locked(route->lr_gateway,
+									    NULL,
+									    lpni)) != NULL) {
+					if (!lnet_get_net_locked(lpni->lpni_peer_net->lpn_net_id))
+						continue;
+					gw_nid = lpni->lpni_nid;
+					rc = cfs_match_nid_net(gw_nid,
+							       rte_action->ud_net_id.udn_net_type,
+							       &rte_action->ud_net_id.udn_net_num_range,
+							       &rte_action->ud_addr_range);
+					if (rc)
+						break;
+				}
+				/* match gw primary nid on a remote network */
+				if (!rc) {
+					gw_nid = gw_prim_nid;
+					rc = cfs_match_nid_net(gw_nid,
+							       rte_action->ud_net_id.udn_net_type,
+							       &rte_action->ud_net_id.udn_net_num_range,
+							       &rte_action->ud_addr_range);
+				}
+				if (!rc)
+					continue;
+				lnet_net_unlock(LNET_LOCK_EX);
+				if (!cleared || revert) {
+					lnet_net_clr_pref_rtrs(net);
+					cleared = true;
+					if (revert) {
+						lnet_net_lock(LNET_LOCK_EX);
+						continue;
+					}
+				}
+				/* match. Add to pref NIDs */
+				CDEBUG(D_NET, "udsp net->gw: %s->%s\n",
+				       libcfs_net2str(net->net_id),
+				       libcfs_nid2str(gw_prim_nid));
+				rc = lnet_net_add_pref_rtr(net, gw_prim_nid);
+				lnet_net_lock(LNET_LOCK_EX);
+				/* success if EEXIST return */
+				if (rc && rc != -EEXIST) {
+					CERROR("Failed to add %s to %s pref rtr list\n",
+					       libcfs_nid2str(gw_prim_nid),
+					       libcfs_net2str(net->net_id));
+					return rc;
+				}
+			}
+		}
+	}
+
+	return rc;
+}
+
+static int
+lnet_udsp_apply_rte_rule_on_nets(struct udsp_info *udi)
+{
+	int rc = 0;
+	int last_failure = 0;
+	struct lnet_net *net;
+	struct lnet_ud_nid_descr *match = udi->udi_match;
+	struct lnet_ud_nid_descr *rte_action = udi->udi_action;
+
+	list_for_each_entry(net, &the_lnet.ln_nets, net_list) {
+		if (LNET_NETTYP(net->net_id) != match->ud_net_id.udn_net_type)
+			continue;
+
+		rc = cfs_match_net(net->net_id,
+				   match->ud_net_id.udn_net_type,
+				   &match->ud_net_id.udn_net_num_range);
+		if (!rc)
+			continue;
+
+		CDEBUG(D_NET, "apply rule on %s\n",
+		       libcfs_net2str(net->net_id));
+		rc = lnet_udsp_apply_rte_list_on_net(net, rte_action,
+						     udi->udi_revert);
+		if (rc)
+			last_failure = rc;
+	}
+
+	return last_failure;
+}
+
+static int
+lnet_udsp_apply_rte_rule_on_net(struct udsp_info *udi)
+{
+	int rc = 0;
+	struct lnet_net *net = udi->udi_net;
+	struct lnet_ud_nid_descr *match = udi->udi_match;
+	struct lnet_ud_nid_descr *rte_action = udi->udi_action;
+
+	rc = cfs_match_net(net->net_id,
+			   match->ud_net_id.udn_net_type,
+			   &match->ud_net_id.udn_net_num_range);
+	if (!rc)
+		return 0;
+
+	CDEBUG(D_NET, "apply rule on %s\n",
+	       libcfs_net2str(net->net_id));
+	rc = lnet_udsp_apply_rte_list_on_net(net, rte_action,
+					     udi->udi_revert);
+
+	return rc;
+}
+
+static int
+lnet_udsp_apply_prio_rule_on_net(struct udsp_info *udi)
+{
+	int rc;
+	struct lnet_ud_nid_descr *match = udi->udi_match;
+	struct lnet_net *net = udi->udi_net;
+	u32 priority = (udi->udi_revert) ? -1 : udi->udi_priority;
+
+	if (!lnet_udsp_is_net_rule(match))
+		return RULE_NOT_APPLICABLE;
+
+	rc = cfs_match_net(net->net_id,
+			   match->ud_net_id.udn_net_type,
+			   &match->ud_net_id.udn_net_num_range);
+	if (!rc)
+		return 0;
+
+	CDEBUG(D_NET, "apply rule on %s\n",
+	       libcfs_net2str(net->net_id));
+
+	lnet_net_set_sel_priority_locked(net, priority);
+
+	return 0;
+}
+
+static int
+lnet_udsp_apply_rule_on_nis(struct udsp_info *udi)
+{
+	int rc = 0;
+	struct lnet_ni *ni;
+	struct lnet_net *net;
+	struct lnet_ud_nid_descr *ni_match = udi->udi_match;
+	int last_failure = 0;
+
+	list_for_each_entry(net, &the_lnet.ln_nets, net_list) {
+		if (LNET_NETTYP(net->net_id) !=
+		    ni_match->ud_net_id.udn_net_type)
+			continue;
+
+		udi->udi_net = net;
+		if (!lnet_udsp_apply_prio_rule_on_net(udi))
+			continue;
+
+		list_for_each_entry(ni, &net->net_ni_list, ni_netlist) {
+			udi->udi_ni = ni;
+			rc = lnet_udsp_apply_rule_on_ni(udi);
+			if (rc)
+				last_failure = rc;
+		}
+	}
+
+	return last_failure;
+}
+
+static int
+lnet_udsp_apply_rte_list_on_lpni(struct lnet_peer_ni *lpni,
+				 struct lnet_ud_nid_descr *rte_action,
+				 bool revert)
+{
+	struct lnet_remotenet *rnet;
+	struct list_head *rn_list;
+	struct lnet_route *route;
+	bool cleared = false;
+	lnet_nid_t gw_nid;
+	int rc = 0;
+	int i;
+
+	for (i = 0; i < LNET_REMOTE_NETS_HASH_SIZE; i++) {
+		rn_list = &the_lnet.ln_remote_nets_hash[i];
+		list_for_each_entry(rnet, rn_list, lrn_list) {
+			list_for_each_entry(route, &rnet->lrn_routes, lr_list) {
+				gw_nid = route->lr_gateway->lp_primary_nid;
+				rc = cfs_match_nid_net(gw_nid,
+						       rte_action->ud_net_id.udn_net_type,
+						       &rte_action->ud_net_id.udn_net_num_range,
+						       &rte_action->ud_addr_range);
+				if (!rc)
+					continue;
+				lnet_net_unlock(LNET_LOCK_EX);
+				if (!cleared || revert) {
+					CDEBUG(D_NET,
+					       "%spref rtr nids from lpni %s\n",
+					       (revert) ? "revert " : "clear ",
+					       libcfs_nid2str(lpni->lpni_nid));
+					lnet_peer_clr_pref_rtrs(lpni);
+					cleared = true;
+					if (revert) {
+						lnet_net_lock(LNET_LOCK_EX);
+						continue;
+					}
+				}
+				CDEBUG(D_NET,
+				       "add gw nid %s as preferred for peer %s\n",
+				       libcfs_nid2str(gw_nid),
+				       libcfs_nid2str(lpni->lpni_nid));
+				/* match. Add to pref NIDs */
+				rc = lnet_peer_add_pref_rtr(lpni, gw_nid);
+				lnet_net_lock(LNET_LOCK_EX);
+				/* success if EEXIST return */
+				if (rc && rc != -EEXIST) {
+					CERROR("Failed to add %s to %s pref rtr list\n",
+					       libcfs_nid2str(gw_nid),
+					       libcfs_nid2str(lpni->lpni_nid));
+					return rc;
+				}
+			}
+		}
+	}
+
+	return rc;
+}
+
+static int
+lnet_udsp_apply_ni_list(struct lnet_peer_ni *lpni,
+			struct lnet_ud_nid_descr *ni_action,
+			bool revert)
+{
+	int rc = 0;
+	struct lnet_ni *ni;
+	struct lnet_net *net;
+	bool cleared = false;
+
+	list_for_each_entry(net, &the_lnet.ln_nets, net_list) {
+		if (LNET_NETTYP(net->net_id) !=
+		    ni_action->ud_net_id.udn_net_type)
+			continue;
+		list_for_each_entry(ni, &net->net_ni_list, ni_netlist) {
+			rc = cfs_match_nid_net(ni->ni_nid,
+					       ni_action->ud_net_id.udn_net_type,
+					       &ni_action->ud_net_id.udn_net_num_range,
+					       &ni_action->ud_addr_range);
+			if (!rc)
+				continue;
+			lnet_net_unlock(LNET_LOCK_EX);
+			if (!cleared || revert) {
+				lnet_peer_clr_pref_nids(lpni);
+				CDEBUG(D_NET, "%spref nids from lpni %s\n",
+				       (revert) ? "revert " : "clear ",
+				       libcfs_nid2str(lpni->lpni_nid));
+				cleared = true;
+				if (revert) {
+					lnet_net_lock(LNET_LOCK_EX);
+					continue;
+				}
+			}
+			CDEBUG(D_NET, "add nid %s as preferred for peer %s\n",
+			       libcfs_nid2str(ni->ni_nid),
+			       libcfs_nid2str(lpni->lpni_nid));
+			/* match. Add to pref NIDs */
+			rc = lnet_peer_add_pref_nid(lpni, ni->ni_nid);
+			lnet_net_lock(LNET_LOCK_EX);
+			/* success if EEXIST return */
+			if (rc && rc != -EEXIST) {
+				CERROR("Failed to add %s to %s pref nid list\n",
+				       libcfs_nid2str(ni->ni_nid),
+				       libcfs_nid2str(lpni->lpni_nid));
+				return rc;
+			}
+		}
+	}
+
+	return rc;
+}
+
+static int
+lnet_udsp_apply_rule_on_lpni(struct udsp_info *udi)
+{
+	int rc;
+	struct lnet_peer_ni *lpni = udi->udi_lpni;
+	struct lnet_ud_nid_descr *lp_match = udi->udi_match;
+	struct lnet_ud_nid_descr *action = udi->udi_action;
+	u32 priority = (udi->udi_revert) ? -1 : udi->udi_priority;
+	bool local = udi->udi_local;
+	enum lnet_udsp_action_type type = udi->udi_type;
+
+	rc = cfs_match_nid_net(lpni->lpni_nid,
+			       lp_match->ud_net_id.udn_net_type,
+			       &lp_match->ud_net_id.udn_net_num_range,
+			       &lp_match->ud_addr_range);
+
+	/* check if looking for a net match */
+	if (!rc &&
+	    (lnet_get_list_len(&lp_match->ud_addr_range) ||
+	     !cfs_match_net(udi->udi_lpn->lpn_net_id,
+			    lp_match->ud_net_id.udn_net_type,
+			    &lp_match->ud_net_id.udn_net_num_range))) {
+		return 0;
+	}
+
+	if (type == EN_LNET_UDSP_ACTION_PREFERRED_LIST && local) {
+		rc = lnet_udsp_apply_ni_list(lpni, action,
+					     udi->udi_revert);
+		if (rc)
+			return rc;
+	} else if (type == EN_LNET_UDSP_ACTION_PREFERRED_LIST &&
+			!local) {
+		rc = lnet_udsp_apply_rte_list_on_lpni(lpni, action,
+						      udi->udi_revert);
+		if (rc)
+			return rc;
+	} else {
+		lnet_peer_ni_set_selection_priority(lpni, priority);
+	}
+
+	return 0;
+}
+
+static int
+lnet_udsp_apply_rule_on_lpn(struct udsp_info *udi)
+{
+	int rc;
+	struct lnet_ud_nid_descr *match = udi->udi_match;
+	struct lnet_peer_net *lpn = udi->udi_lpn;
+	u32 priority = (udi->udi_revert) ? -1 : udi->udi_priority;
+
+	if (udi->udi_type == EN_LNET_UDSP_ACTION_PREFERRED_LIST ||
+	    !lnet_udsp_is_net_rule(match))
+		return RULE_NOT_APPLICABLE;
+
+	rc = cfs_match_net(lpn->lpn_net_id,
+			   match->ud_net_id.udn_net_type,
+			   &match->ud_net_id.udn_net_num_range);
+	if (!rc)
+		return 0;
+
+	CDEBUG(D_NET, "apply rule on lpn %s\n",
+	       libcfs_net2str(lpn->lpn_net_id));
+	lnet_peer_net_set_sel_priority_locked(lpn, priority);
+
+	return 0;
+}
+
+static int
+lnet_udsp_apply_rule_on_lpnis(struct udsp_info *udi)
+{
+	/* iterate over all the peers in the system and find if any of the
+	 * peers match the criteria. If they do, clear the preferred list
+	 * and add the new list
+	 */
+	int lncpt = cfs_percpt_number(the_lnet.ln_peer_tables);
+	struct lnet_ud_nid_descr *lp_match = udi->udi_match;
+	struct lnet_peer_table *ptable;
+	struct lnet_peer_net *lpn;
+	struct lnet_peer_ni *lpni;
+	struct lnet_peer *lp;
+	int last_failure = 0;
+	int cpt;
+	int rc;
+
+	for (cpt = 0; cpt < lncpt; cpt++) {
+		ptable = the_lnet.ln_peer_tables[cpt];
+		list_for_each_entry(lp, &ptable->pt_peer_list, lp_peer_list) {
+			CDEBUG(D_NET, "udsp examining lp %s\n",
+			       libcfs_nid2str(lp->lp_primary_nid));
+			list_for_each_entry(lpn,
+					    &lp->lp_peer_nets,
+					    lpn_peer_nets) {
+				CDEBUG(D_NET, "udsp examining lpn %s\n",
+				       libcfs_net2str(lpn->lpn_net_id));
+
+				if (LNET_NETTYP(lpn->lpn_net_id) !=
+				    lp_match->ud_net_id.udn_net_type)
+					continue;
+
+				udi->udi_lpn = lpn;
+
+				if (!lnet_udsp_apply_rule_on_lpn(udi))
+					continue;
+
+				list_for_each_entry(lpni,
+						    &lpn->lpn_peer_nis,
+						    lpni_peer_nis) {
+					CDEBUG(D_NET,
+					       "udsp examining lpni %s\n",
+					       libcfs_nid2str(lpni->lpni_nid));
+					udi->udi_lpni = lpni;
+					rc = lnet_udsp_apply_rule_on_lpni(udi);
+					if (rc)
+						last_failure = rc;
+				}
+			}
+		}
+	}
+
+	return last_failure;
+}
+
+static int
+lnet_udsp_apply_single_policy(struct lnet_udsp *udsp, struct udsp_info *udi,
+			      udsp_apply_rule *cbs)
+{
+	int rc;
+
+	if (lnet_udsp_criteria_present(&udsp->udsp_dst) &&
+	    lnet_udsp_criteria_present(&udsp->udsp_src)) {
+		/* NID Pair rule */
+		if (!cbs[UDSP_APPLY_ON_PEERS])
+			return 0;
+
+		if (udsp->udsp_action_type !=
+			EN_LNET_UDSP_ACTION_PREFERRED_LIST) {
+			CERROR("Bad action type. Expected %d got %d\n",
+			       EN_LNET_UDSP_ACTION_PREFERRED_LIST,
+			       udsp->udsp_action_type);
+			return 0;
+		}
+		udi->udi_match = &udsp->udsp_dst;
+		udi->udi_action = &udsp->udsp_src;
+		udi->udi_type = EN_LNET_UDSP_ACTION_PREFERRED_LIST;
+		udi->udi_local = true;
+
+		CDEBUG(D_NET, "applying udsp (%p) dst->src\n",
+		       udsp);
+		rc = cbs[UDSP_APPLY_ON_PEERS](udi);
+		if (rc)
+			return rc;
+	} else if (lnet_udsp_criteria_present(&udsp->udsp_dst) &&
+		   lnet_udsp_criteria_present(&udsp->udsp_rte)) {
+		/* Router rule */
+		if (!cbs[UDSP_APPLY_ON_PEERS])
+			return 0;
+
+		if (udsp->udsp_action_type !=
+			EN_LNET_UDSP_ACTION_PREFERRED_LIST) {
+			CERROR("Bad action type. Expected %d got %d\n",
+			       EN_LNET_UDSP_ACTION_PREFERRED_LIST,
+			       udsp->udsp_action_type);
+			return 0;
+		}
+
+		if (lnet_udsp_criteria_present(&udsp->udsp_src)) {
+			CERROR("only one of src or dst can be specified\n");
+			return 0;
+		}
+		udi->udi_match = &udsp->udsp_dst;
+		udi->udi_action = &udsp->udsp_rte;
+		udi->udi_type = EN_LNET_UDSP_ACTION_PREFERRED_LIST;
+		udi->udi_local = false;
+
+		CDEBUG(D_NET, "applying udsp (%p) dst->rte\n",
+		       udsp);
+		rc = cbs[UDSP_APPLY_ON_PEERS](udi);
+		if (rc)
+			return rc;
+	} else if (lnet_udsp_criteria_present(&udsp->udsp_dst)) {
+		/* destination priority rule */
+		if (!cbs[UDSP_APPLY_ON_PEERS])
+			return 0;
+
+		if (udsp->udsp_action_type !=
+			EN_LNET_UDSP_ACTION_PRIORITY) {
+			CERROR("Bad action type. Expected %d got %d\n",
+			       EN_LNET_UDSP_ACTION_PRIORITY,
+			       udsp->udsp_action_type);
+			return 0;
+		}
+		udi->udi_match = &udsp->udsp_dst;
+		udi->udi_type = EN_LNET_UDSP_ACTION_PRIORITY;
+		if (udsp->udsp_action_type !=
+		    EN_LNET_UDSP_ACTION_PRIORITY) {
+			udi->udi_priority = 0;
+		} else {
+			udi->udi_priority = udsp->udsp_action.udsp_priority;
+		}
+		udi->udi_local = true;
+
+		CDEBUG(D_NET, "applying udsp (%p) on destination\n",
+		       udsp);
+		rc = cbs[UDSP_APPLY_ON_PEERS](udi);
+		if (rc)
+			return rc;
+	} else if (lnet_udsp_criteria_present(&udsp->udsp_src)) {
+		/* source priority rule */
+		if (!cbs[UDSP_APPLY_PRIO_ON_NIS])
+			return 0;
+
+		if (udsp->udsp_action_type !=
+			EN_LNET_UDSP_ACTION_PRIORITY) {
+			CERROR("Bad action type. Expected %d got %d\n",
+			       EN_LNET_UDSP_ACTION_PRIORITY,
+			       udsp->udsp_action_type);
+			return 0;
+		}
+		udi->udi_match = &udsp->udsp_src;
+		udi->udi_type = EN_LNET_UDSP_ACTION_PRIORITY;
+		if (udsp->udsp_action_type !=
+		    EN_LNET_UDSP_ACTION_PRIORITY) {
+			udi->udi_priority = 0;
+		} else {
+			udi->udi_priority = udsp->udsp_action.udsp_priority;
+		}
+		udi->udi_local = true;
+
+		CDEBUG(D_NET, "applying udsp (%p) on source\n",
+		       udsp);
+		rc = cbs[UDSP_APPLY_PRIO_ON_NIS](udi);
+	} else {
+		CERROR("Bad UDSP policy\n");
+		return 0;
+	}
+
+	return 0;
+}
+
+static int
+lnet_udsp_apply_policies_helper(struct lnet_udsp *udsp, struct udsp_info *udi,
+				udsp_apply_rule *cbs)
+{
+	int rc;
+	int last_failure = 0;
+
+	if (udsp)
+		return lnet_udsp_apply_single_policy(udsp, udi, cbs);
+
+	list_for_each_entry_reverse(udsp,
+				    &the_lnet.ln_udsp_list,
+				    udsp_on_list) {
+		rc = lnet_udsp_apply_single_policy(udsp, udi, cbs);
+		if (rc)
+			last_failure = rc;
+	}
+
+	return last_failure;
+}
+
+int
+lnet_udsp_apply_policies_on_ni(struct lnet_ni *ni)
+{
+	struct udsp_info udi;
+	udsp_apply_rule cbs[UDSP_APPLY_MAX_ENUM] = {NULL};
+
+	memset(&udi, 0, sizeof(udi));
+
+	udi.udi_ni = ni;
+
+	cbs[UDSP_APPLY_PRIO_ON_NIS] = lnet_udsp_apply_rule_on_ni;
+
+	return lnet_udsp_apply_policies_helper(NULL, &udi, cbs);
+}
+
+int
+lnet_udsp_apply_policies_on_net(struct lnet_net *net)
+{
+	struct udsp_info udi;
+	udsp_apply_rule cbs[UDSP_APPLY_MAX_ENUM] = {NULL};
+
+	memset(&udi, 0, sizeof(udi));
+
+	udi.udi_net = net;
+
+	cbs[UDSP_APPLY_PRIO_ON_NIS] = lnet_udsp_apply_prio_rule_on_net;
+	cbs[UDSP_APPLY_RTE_ON_NETS] = lnet_udsp_apply_rte_rule_on_net;
+
+	return lnet_udsp_apply_policies_helper(NULL, &udi, cbs);
+}
+
+int
+lnet_udsp_apply_policies_on_lpni(struct lnet_peer_ni *lpni)
+{
+	struct udsp_info udi;
+	udsp_apply_rule cbs[UDSP_APPLY_MAX_ENUM] = {NULL};
+
+	memset(&udi, 0, sizeof(udi));
+
+	udi.udi_lpni = lpni;
+
+	cbs[UDSP_APPLY_ON_PEERS] = lnet_udsp_apply_rule_on_lpni;
+
+	return lnet_udsp_apply_policies_helper(NULL, &udi, cbs);
+}
+
+int
+lnet_udsp_apply_policies_on_lpn(struct lnet_peer_net *lpn)
+{
+	struct udsp_info udi;
+	udsp_apply_rule cbs[UDSP_APPLY_MAX_ENUM] = {NULL};
+
+	memset(&udi, 0, sizeof(udi));
+
+	udi.udi_lpn = lpn;
+
+	cbs[UDSP_APPLY_ON_PEERS] = lnet_udsp_apply_rule_on_lpn;
+
+	return lnet_udsp_apply_policies_helper(NULL, &udi, cbs);
+}
+
+int
+lnet_udsp_apply_policies(struct lnet_udsp *udsp, bool revert)
+{
+	int rc;
+	struct udsp_info udi;
+	udsp_apply_rule cbs[UDSP_APPLY_MAX_ENUM] = {NULL};
+
+	memset(&udi, 0, sizeof(udi));
+
+	cbs[UDSP_APPLY_ON_PEERS] = lnet_udsp_apply_rule_on_lpnis;
+	cbs[UDSP_APPLY_PRIO_ON_NIS] = lnet_udsp_apply_rule_on_nis;
+	cbs[UDSP_APPLY_RTE_ON_NETS] = lnet_udsp_apply_rte_rule_on_nets;
+
+	udi.udi_revert = revert;
+
+	lnet_net_lock(LNET_LOCK_EX);
+	rc = lnet_udsp_apply_policies_helper(udsp, &udi, cbs);
+	lnet_net_unlock(LNET_LOCK_EX);
+
+	return rc;
+}
+
+struct lnet_udsp *
+lnet_udsp_get_policy(int idx)
+{
+	int i = 0;
+	struct lnet_udsp *udsp = NULL;
+	bool found = false;
+
+	CDEBUG(D_NET, "Get UDSP at idx = %d\n", idx);
+
+	if (idx < 0)
+		return NULL;
+
+	list_for_each_entry(udsp, &the_lnet.ln_udsp_list, udsp_on_list) {
+		CDEBUG(D_NET, "iterating over upsp %d:%d:%d\n",
+		       udsp->udsp_idx, i, idx);
+		if (i == idx) {
+			found = true;
+			break;
+		}
+		i++;
+	}
+
+	CDEBUG(D_NET, "Found UDSP (%p)\n", udsp);
+
+	if (!found)
+		return NULL;
+
+	return udsp;
+}
+
+int
+lnet_udsp_add_policy(struct lnet_udsp *new, int idx)
+{
+	struct lnet_udsp *udsp;
+	struct lnet_udsp *insert = NULL;
+	int i = 0;
+
+	list_for_each_entry(udsp, &the_lnet.ln_udsp_list, udsp_on_list) {
+		CDEBUG(D_NET, "found udsp i = %d:%d, idx = %d\n",
+		       i, udsp->udsp_idx, idx);
+		if (i == idx) {
+			insert = udsp;
+			new->udsp_idx = idx;
+		}
+		i++;
+		if (lnet_udsp_equal(udsp, new)) {
+			if (!lnet_udsp_action_equal(udsp, new) &&
+			    udsp->udsp_action_type == EN_LNET_UDSP_ACTION_PRIORITY &&
+			    new->udsp_action_type == EN_LNET_UDSP_ACTION_PRIORITY) {
+				udsp->udsp_action.udsp_priority = new->udsp_action.udsp_priority;
+				CDEBUG(D_NET,
+				       "udsp: %p index %d updated priority to %d\n",
+				       udsp,
+				       udsp->udsp_idx,
+				       udsp->udsp_action.udsp_priority);
+				return 0;
+			}
+			return -EALREADY;
+		}
+	}
+
+	if (insert) {
+		list_add(&new->udsp_on_list, insert->udsp_on_list.prev);
+		i = 0;
+		list_for_each_entry(udsp,
+				    &the_lnet.ln_udsp_list,
+				    udsp_on_list) {
+			if (i <= idx) {
+				i++;
+				continue;
+			}
+			udsp->udsp_idx++;
+		}
+	} else {
+		list_add_tail(&new->udsp_on_list, &the_lnet.ln_udsp_list);
+		new->udsp_idx = i;
+	}
+
+	CDEBUG(D_NET, "udsp: %p added at index %d\n", new, new->udsp_idx);
+
+	CDEBUG(D_NET, "udsp list:\n");
+	list_for_each_entry(udsp, &the_lnet.ln_udsp_list, udsp_on_list)
+		CDEBUG(D_NET, "udsp %p:%d\n", udsp, udsp->udsp_idx);
+
+	return 0;
+}
+
+int
+lnet_udsp_del_policy(int idx)
+{
+	struct lnet_udsp *udsp;
+	struct lnet_udsp *tmp;
+	bool removed = false;
+
+	if (idx < 0) {
+		lnet_udsp_destroy(false);
+		return 0;
+	}
+
+	CDEBUG(D_NET, "del udsp at idx = %d\n", idx);
+
+	list_for_each_entry_safe(udsp,
+				 tmp,
+				 &the_lnet.ln_udsp_list,
+				 udsp_on_list) {
+		if (removed)
+			udsp->udsp_idx--;
+		if (udsp->udsp_idx == idx && !removed) {
+			list_del_init(&udsp->udsp_on_list);
+			lnet_udsp_apply_policies(udsp, true);
+			lnet_udsp_free(udsp);
+			removed = true;
+		}
+	}
+
+	return 0;
+}
+
+struct lnet_udsp *
+lnet_udsp_alloc(void)
+{
+	struct lnet_udsp *udsp;
+
+	udsp = kmem_cache_alloc(lnet_udsp_cachep, GFP_NOFS | __GFP_ZERO);
+
+	if (!udsp)
+		return NULL;
+
+	INIT_LIST_HEAD(&udsp->udsp_on_list);
+	INIT_LIST_HEAD(&udsp->udsp_src.ud_addr_range);
+	INIT_LIST_HEAD(&udsp->udsp_src.ud_net_id.udn_net_num_range);
+	INIT_LIST_HEAD(&udsp->udsp_dst.ud_addr_range);
+	INIT_LIST_HEAD(&udsp->udsp_dst.ud_net_id.udn_net_num_range);
+	INIT_LIST_HEAD(&udsp->udsp_rte.ud_addr_range);
+	INIT_LIST_HEAD(&udsp->udsp_rte.ud_net_id.udn_net_num_range);
+
+	CDEBUG(D_MALLOC, "udsp alloc %p\n", udsp);
+	return udsp;
+}
+
+static void
+lnet_udsp_nid_descr_free(struct lnet_ud_nid_descr *nid_descr)
+{
+	struct list_head *net_range = &nid_descr->ud_net_id.udn_net_num_range;
+
+	if (!lnet_udsp_criteria_present(nid_descr))
+		return;
+
+	/* memory management is a bit tricky here. When we allocate the
+	 * memory to store the NID descriptor we allocate a large buffer
+	 * for all the data, so we need to free the entire buffer at
+	 * once. If the net is present the net_range->next points to that
+	 * buffer otherwise if the ud_addr_range is present then it's the
+	 * ud_addr_range.next
+	 */
+	if (!list_empty(net_range))
+		kfree(net_range->next);
+	else if (!list_empty(&nid_descr->ud_addr_range))
+		kfree(nid_descr->ud_addr_range.next);
+}
+
+void
+lnet_udsp_free(struct lnet_udsp *udsp)
+{
+	lnet_udsp_nid_descr_free(&udsp->udsp_src);
+	lnet_udsp_nid_descr_free(&udsp->udsp_dst);
+	lnet_udsp_nid_descr_free(&udsp->udsp_rte);
+
+	CDEBUG(D_MALLOC, "udsp free %p\n", udsp);
+	kmem_cache_free(lnet_udsp_cachep, udsp);
+}
+
+void
+lnet_udsp_destroy(bool shutdown)
+{
+	struct lnet_udsp *udsp, *tmp;
+
+	CDEBUG(D_NET, "Destroying UDSPs in the system\n");
+
+	list_for_each_entry_safe(udsp, tmp, &the_lnet.ln_udsp_list,
+				 udsp_on_list) {
+		list_del(&udsp->udsp_on_list);
+		if (!shutdown)
+			lnet_udsp_apply_policies(udsp, true);
+		lnet_udsp_free(udsp);
+	}
+}
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
