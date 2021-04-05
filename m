Return-Path: <SRS0=o51I=JC=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.7 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0A73CC43460
	for <lustre-devel@archiver.kernel.org>; Mon,  5 Apr 2021 00:51:40 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id B37066138E
	for <lustre-devel@archiver.kernel.org>; Mon,  5 Apr 2021 00:51:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B37066138E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 95E50327FB1;
	Mon,  5 Apr 2021 00:51:31 +0000 (UTC)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id E50B321F521
 for <lustre-devel@lists.lustre.org>; Mon,  5 Apr 2021 00:51:19 +0000 (UTC)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id A21326BC;
 Sun,  4 Apr 2021 20:51:16 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 9CE2590AA8; Sun,  4 Apr 2021 20:51:16 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun,  4 Apr 2021 20:50:36 -0400
Message-Id: <1617583870-32029-8-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1617583870-32029-1-git-send-email-jsimmons@infradead.org>
References: <1617583870-32029-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 07/41] lnet: UDSP storage and marshalled
 structs
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
Cc: Amir Shehata <ashehata@whamcloud.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Amir Shehata <ashehata@whamcloud.com>

Commit the structures which will be used by kernel space
to store the UDSPs. This commit also adds the IOCTL structures
which are used for marshalling the UDSPs between user and
kernel space.

WC-bug-id: https://jira.whamcloud.com/browse/LU-9121
Lustre-commit: 6427da97ef6e90e5 ("LU-9121 lnet: UDSP storage and marshalled structs")
Signed-off-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/34253
Reviewed-by: James Simmons <jsimmons@infradead.org>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/lib-types.h       | 45 ++++++++++++++++++
 include/uapi/linux/lnet/lnet-dlc.h   | 90 ++++++++++++++++++++++++++++++++++--
 include/uapi/linux/lnet/lnet-types.h | 14 ++++++
 net/lnet/lnet/api-ni.c               |  1 +
 4 files changed, 147 insertions(+), 3 deletions(-)

diff --git a/include/linux/lnet/lib-types.h b/include/linux/lnet/lib-types.h
index 7c9d7e2..a8bd5a5 100644
--- a/include/linux/lnet/lib-types.h
+++ b/include/linux/lnet/lib-types.h
@@ -995,6 +995,49 @@ struct lnet_msg_container {
 	void			**msc_resenders;
 };
 
+/* This UDSP structures need to match the user space liblnetconfig structures
+ * in order for the marshall and unmarshall functions to be common.
+ */
+
+/* Net is described as a
+ *  1. net type
+ *  2. num range
+ */
+struct lnet_ud_net_descr {
+	u32 udn_net_type;
+	struct list_head udn_net_num_range;
+};
+
+/* each NID range is defined as
+ *  1. net descriptor
+ *  2. address range descriptor
+ */
+struct lnet_ud_nid_descr {
+	struct lnet_ud_net_descr ud_net_id;
+	struct list_head ud_addr_range;
+	u32 ud_mem_size;
+};
+
+/* a UDSP rule can have up to three user defined NID descriptors
+ *	- src: defines the local NID range for the rule
+ *	- dst: defines the peer NID range for the rule
+ *	- rte: defines the router NID range for the rule
+ *
+ * An action union defines the action to take when the rule
+ * is matched
+ */
+struct lnet_udsp {
+	struct list_head udsp_on_list;
+	u32 udsp_idx;
+	struct lnet_ud_nid_descr udsp_src;
+	struct lnet_ud_nid_descr udsp_dst;
+	struct lnet_ud_nid_descr udsp_rte;
+	enum lnet_udsp_action_type udsp_action_type;
+	union {
+		u32 udsp_priority;
+	} udsp_action;
+};
+
 /* Peer Discovery states */
 #define LNET_DC_STATE_SHUTDOWN		0	/* not started */
 #define LNET_DC_STATE_RUNNING		1	/* started up OK */
@@ -1176,6 +1219,8 @@ struct lnet {
 	 * work loops
 	 */
 	struct completion		ln_started;
+	/* UDSP list */
+	struct list_head		ln_udsp_list;
 };
 
 #endif
diff --git a/include/uapi/linux/lnet/lnet-dlc.h b/include/uapi/linux/lnet/lnet-dlc.h
index 2a87071..ca1f8ae 100644
--- a/include/uapi/linux/lnet/lnet-dlc.h
+++ b/include/uapi/linux/lnet/lnet-dlc.h
@@ -26,8 +26,8 @@
  * Author: Amir Shehata <amir.shehata@intel.com>
  */
 
-#ifndef LNET_DLC_H
-#define LNET_DLC_H
+#ifndef _LNET_DLC_H_
+#define _LNET_DLC_H_
 
 #include <linux/lnet/libcfs_ioctl.h>
 #include <linux/lnet/lnet-types.h>
@@ -292,4 +292,88 @@ struct lnet_ioctl_lnet_stats {
 	struct lnet_counters st_cntrs;
 };
 
-#endif /* LNET_DLC_H */
+/* An IP, numeric NID or a Net number is composed of 1 or more of these
+ * descriptor structures.
+ */
+struct lnet_range_expr {
+	__u32 re_lo;
+	__u32 re_hi;
+	__u32 re_stride;
+};
+
+/* le_count identifies the number of lnet_range_expr in the bulk
+ * which follows
+ */
+struct lnet_expressions {
+	__u32 le_count;
+};
+
+/* A net descriptor has the net type, IE: O2IBLND, SOCKLND, etc and an
+ * expression describing a net number range.
+ */
+struct lnet_ioctl_udsp_net_descr {
+	__u32 ud_net_type;
+	struct lnet_expressions ud_net_num_expr;
+};
+
+/* The UDSP descriptor header contains the type of matching criteria, SRC,
+ * DST, RTE, etc and how many lnet_expressions compose the LNet portion of
+ * the LNet NID. For example an IP can be
+ * composed of 4 lnet_expressions , a gni can be composed of 1
+ */
+struct lnet_ioctl_udsp_descr_hdr {
+	/* The literals SRC, DST and RTE are encoded
+	 * here.
+	 */
+	__u32 ud_descr_type;
+	__u32 ud_descr_count;
+};
+
+/* each matching expression in the UDSP is described with this.
+ * The bulk format is as follows:
+ *	1. 1x struct lnet_ioctl_udsp_net_descr
+ *		-> the net part of the NID
+ *	2. >=0 struct lnet_expressions
+ *		-> the address part of the NID
+ */
+struct lnet_ioctl_udsp_descr {
+	struct lnet_ioctl_udsp_descr_hdr iud_src_hdr;
+	struct lnet_ioctl_udsp_net_descr iud_net;
+};
+
+/* The cumulative UDSP descriptor
+ * The bulk format is as follows:
+ *	1. >=1 struct lnet_ioctl_udsp_descr
+ *
+ * The size indicated in iou_hdr is the total size of the UDSP.
+ *
+ */
+struct lnet_ioctl_udsp {
+	struct libcfs_ioctl_hdr iou_hdr;
+	__s32 iou_idx;
+	__u32 iou_action_type;
+	__u32 iou_bulk_size;
+	union {
+		__u32 priority;
+	} iou_action;
+	void __user *iou_bulk;
+};
+
+/* structure used to request udsp instantiation information on the
+ * specified construct.
+ *   cud_nid: the NID of the local or remote NI to pull info on.
+ *   cud_nid_priority: NID prio of the requested NID.
+ *   cud_net_priority: net prio of network of the requested NID.
+ *   cud_pref_nid: array of preferred NIDs if it exists.
+ */
+struct lnet_ioctl_construct_udsp_info {
+	struct libcfs_ioctl_hdr cud_hdr;
+	__u32 cud_peer:1;
+	lnet_nid_t cud_nid;
+	__u32 cud_nid_priority;
+	__u32 cud_net_priority;
+	lnet_nid_t cud_pref_nid[LNET_MAX_SHOW_NUM_NID];
+	lnet_nid_t cud_pref_rtr_nid[LNET_MAX_SHOW_NUM_NID];
+};
+
+#endif /* _LNET_DLC_H_ */
diff --git a/include/uapi/linux/lnet/lnet-types.h b/include/uapi/linux/lnet/lnet-types.h
index 3324792..5bf9917 100644
--- a/include/uapi/linux/lnet/lnet-types.h
+++ b/include/uapi/linux/lnet/lnet-types.h
@@ -709,6 +709,20 @@ enum lnet_ack_req {
 	/** Request that no acknowledgment should be generated. */
 	LNET_NOACK_REQ
 };
+
+/**
+ * UDSP action types. There are two available actions:
+ *	1. PRIORITY - set priority of matching LNet constructs
+ *	2. PREFERRED LIST - set preferred list of matching LNet constructs
+ */
+enum lnet_udsp_action_type {
+	EN_LNET_UDSP_ACTION_NONE = 0,
+	/** assign a priority to matching constructs */
+	EN_LNET_UDSP_ACTION_PRIORITY = 1,
+	/** assign a preferred list of NIDs to matching constructs */
+	EN_LNET_UDSP_ACTION_PREFERRED_LIST = 2,
+};
+
 /** @} lnet_data */
 
 /** @} lnet */
diff --git a/net/lnet/lnet/api-ni.c b/net/lnet/lnet/api-ni.c
index c3bf444..3acc86e 100644
--- a/net/lnet/lnet/api-ni.c
+++ b/net/lnet/lnet/api-ni.c
@@ -1154,6 +1154,7 @@ struct list_head **
 	INIT_LIST_HEAD(&the_lnet.ln_dc_expired);
 	INIT_LIST_HEAD(&the_lnet.ln_mt_localNIRecovq);
 	INIT_LIST_HEAD(&the_lnet.ln_mt_peerNIRecovq);
+	INIT_LIST_HEAD(&the_lnet.ln_udsp_list);
 	init_waitqueue_head(&the_lnet.ln_dc_waitq);
 	the_lnet.ln_mt_handler = NULL;
 	init_completion(&the_lnet.ln_started);
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
