Return-Path: <SRS0=o51I=JC=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.9 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,UNWANTED_LANGUAGE_BODY,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CD8B4C43460
	for <lustre-devel@archiver.kernel.org>; Mon,  5 Apr 2021 00:52:07 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 8476861396
	for <lustre-devel@archiver.kernel.org>; Mon,  5 Apr 2021 00:52:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8476861396
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 6298521FBE8;
	Mon,  5 Apr 2021 00:51:47 +0000 (UTC)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 291BB21F8E8
 for <lustre-devel@lists.lustre.org>; Mon,  5 Apr 2021 00:51:23 +0000 (UTC)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id CA1999EA;
 Sun,  4 Apr 2021 20:51:16 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id C711590AA9; Sun,  4 Apr 2021 20:51:16 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun,  4 Apr 2021 20:50:47 -0400
Message-Id: <1617583870-32029-19-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1617583870-32029-1-git-send-email-jsimmons@infradead.org>
References: <1617583870-32029-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 18/41] lnet: ioctl handler for get policy info
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

Add ioctl handler for GET_UDSP_SIZE and GET_UDSP

WC-bug-id: https://jira.whamcloud.com/browse/LU-9121
Lustre-commit: 6248e1cd7fb70f4 ("LU-9121 lnet: ioctl handler for get policy info")
Signed-off-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/34579
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: Chris Horn <chris.horn@hpe.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/udsp.h              |  7 +++
 include/uapi/linux/lnet/libcfs_ioctl.h |  5 +-
 net/lnet/lnet/api-ni.c                 | 64 +++++++++++++++++++++++++
 net/lnet/lnet/udsp.c                   | 88 ++++++++++++++++++++++++++++++++++
 4 files changed, 163 insertions(+), 1 deletion(-)

diff --git a/include/linux/lnet/udsp.h b/include/linux/lnet/udsp.h
index 3683d43..188dce4 100644
--- a/include/linux/lnet/udsp.h
+++ b/include/linux/lnet/udsp.h
@@ -134,4 +134,11 @@ int lnet_udsp_marshal(struct lnet_udsp *udsp,
  */
 int lnet_udsp_demarshal_add(void *bulk, u32 bulk_size);
 
+/**
+ * lnet_udsp_get_construct_info
+ *	get information of how the UDSP policies impacted the given
+ *	construct.
+ */
+void lnet_udsp_get_construct_info(struct lnet_ioctl_construct_udsp_info *info);
+
 #endif /* UDSP_H */
diff --git a/include/uapi/linux/lnet/libcfs_ioctl.h b/include/uapi/linux/lnet/libcfs_ioctl.h
index 9e3c427..d0b29c52 100644
--- a/include/uapi/linux/lnet/libcfs_ioctl.h
+++ b/include/uapi/linux/lnet/libcfs_ioctl.h
@@ -152,6 +152,9 @@ struct libcfs_ioctl_data {
 #define IOC_LIBCFS_GET_RECOVERY_QUEUE	_IOWR(IOC_LIBCFS_TYPE, 104, IOCTL_CONFIG_SIZE)
 #define IOC_LIBCFS_ADD_UDSP		_IOWR(IOC_LIBCFS_TYPE, 105, IOCTL_CONFIG_SIZE)
 #define IOC_LIBCFS_DEL_UDSP		_IOWR(IOC_LIBCFS_TYPE, 106, IOCTL_CONFIG_SIZE)
-#define IOC_LIBCFS_MAX_NR				       106
+#define IOC_LIBCFS_GET_UDSP_SIZE	_IOWR(IOC_LIBCFS_TYPE, 107, IOCTL_CONFIG_SIZE)
+#define IOC_LIBCFS_GET_UDSP		_IOWR(IOC_LIBCFS_TYPE, 108, IOCTL_CONFIG_SIZE)
+#define IOC_LIBCFS_GET_CONST_UDSP_INFO	_IOWR(IOC_LIBCFS_TYPE, 109, IOCTL_CONFIG_SIZE)
+#define IOC_LIBCFS_MAX_NR				       109
 
 #endif /* __LIBCFS_IOCTL_H__ */
diff --git a/net/lnet/lnet/api-ni.c b/net/lnet/lnet/api-ni.c
index 50f7b9e..f121d69 100644
--- a/net/lnet/lnet/api-ni.c
+++ b/net/lnet/lnet/api-ni.c
@@ -4162,6 +4162,70 @@ u32 lnet_get_dlc_seq_locked(void)
 		return rc;
 	}
 
+	case IOC_LIBCFS_GET_UDSP_SIZE: {
+		struct lnet_ioctl_udsp *ioc_udsp = arg;
+		struct lnet_udsp *udsp;
+
+		if (ioc_udsp->iou_hdr.ioc_len < sizeof(*ioc_udsp))
+			return -EINVAL;
+
+		rc = 0;
+
+		mutex_lock(&the_lnet.ln_api_mutex);
+		udsp = lnet_udsp_get_policy(ioc_udsp->iou_idx);
+		if (!udsp) {
+			rc = -ENOENT;
+		} else {
+			/* coming in iou_idx will hold the idx of the udsp
+			 * to get the size of. going out the iou_idx will
+			 * hold the size of the UDSP found at the passed
+			 * in index.
+			 */
+			ioc_udsp->iou_idx = lnet_get_udsp_size(udsp);
+			if (ioc_udsp->iou_idx < 0)
+				rc = -EINVAL;
+		}
+		mutex_unlock(&the_lnet.ln_api_mutex);
+
+		return rc;
+	}
+
+	case IOC_LIBCFS_GET_UDSP: {
+		struct lnet_ioctl_udsp *ioc_udsp = arg;
+		struct lnet_udsp *udsp;
+
+		if (ioc_udsp->iou_hdr.ioc_len < sizeof(*ioc_udsp))
+			return -EINVAL;
+
+		rc = 0;
+
+		mutex_lock(&the_lnet.ln_api_mutex);
+		udsp = lnet_udsp_get_policy(ioc_udsp->iou_idx);
+		if (!udsp)
+			rc = -ENOENT;
+		else
+			rc = lnet_udsp_marshal(udsp, ioc_udsp);
+		mutex_unlock(&the_lnet.ln_api_mutex);
+
+		return rc;
+	}
+
+	case IOC_LIBCFS_GET_CONST_UDSP_INFO: {
+		struct lnet_ioctl_construct_udsp_info *info = arg;
+
+		if (info->cud_hdr.ioc_len < sizeof(*info))
+			return -EINVAL;
+
+		CDEBUG(D_NET, "GET_UDSP_INFO for %s\n",
+		       libcfs_nid2str(info->cud_nid));
+
+		mutex_lock(&the_lnet.ln_api_mutex);
+		lnet_udsp_get_construct_info(info);
+		mutex_unlock(&the_lnet.ln_api_mutex);
+
+		return 0;
+	}
+
 	default:
 		ni = lnet_net2ni_addref(data->ioc_net);
 		if (!ni)
diff --git a/net/lnet/lnet/udsp.c b/net/lnet/lnet/udsp.c
index f686ff2..516db98 100644
--- a/net/lnet/lnet/udsp.c
+++ b/net/lnet/lnet/udsp.c
@@ -980,6 +980,94 @@ struct lnet_udsp *
 	return 0;
 }
 
+static void
+lnet_udsp_get_ni_info(struct lnet_ioctl_construct_udsp_info *info,
+		      struct lnet_ni *ni)
+{
+	struct lnet_nid_list *ne;
+	struct lnet_net *net = ni->ni_net;
+	int i = 0;
+
+	LASSERT(ni);
+
+	info->cud_nid_priority = ni->ni_sel_priority;
+	if (net) {
+		info->cud_net_priority = ni->ni_net->net_sel_priority;
+		list_for_each_entry(ne, &net->net_rtr_pref_nids, nl_list) {
+			if (i < LNET_MAX_SHOW_NUM_NID)
+				info->cud_pref_rtr_nid[i] = ne->nl_nid;
+			else
+				break;
+			i++;
+		}
+	}
+}
+
+static void
+lnet_udsp_get_peer_info(struct lnet_ioctl_construct_udsp_info *info,
+			struct lnet_peer_ni *lpni)
+{
+	struct lnet_nid_list *ne;
+	int i = 0;
+
+	/* peer tree structure needs to be in existence */
+	LASSERT(lpni && lpni->lpni_peer_net &&
+		lpni->lpni_peer_net->lpn_peer);
+
+	info->cud_nid_priority = lpni->lpni_sel_priority;
+	CDEBUG(D_NET, "lpni %s has %d pref nids\n",
+	       libcfs_nid2str(lpni->lpni_nid),
+	       lpni->lpni_pref_nnids);
+	if (lpni->lpni_pref_nnids == 1) {
+		info->cud_pref_nid[0] = lpni->lpni_pref.nid;
+	} else if (lpni->lpni_pref_nnids > 1) {
+		struct list_head *list = &lpni->lpni_pref.nids;
+
+		list_for_each_entry(ne, list, nl_list) {
+			if (i < LNET_MAX_SHOW_NUM_NID)
+				info->cud_pref_nid[i] = ne->nl_nid;
+			else
+				break;
+			i++;
+		}
+	}
+
+	i = 0;
+	list_for_each_entry(ne, &lpni->lpni_rtr_pref_nids, nl_list) {
+		if (i < LNET_MAX_SHOW_NUM_NID)
+			info->cud_pref_rtr_nid[i] = ne->nl_nid;
+		else
+			break;
+		i++;
+	}
+
+	info->cud_net_priority = lpni->lpni_peer_net->lpn_sel_priority;
+}
+
+void
+lnet_udsp_get_construct_info(struct lnet_ioctl_construct_udsp_info *info)
+{
+	struct lnet_ni *ni;
+	struct lnet_peer_ni *lpni;
+
+	lnet_net_lock(0);
+	if (!info->cud_peer) {
+		ni = lnet_nid2ni_locked(info->cud_nid, 0);
+		if (ni)
+			lnet_udsp_get_ni_info(info, ni);
+	} else {
+		lpni = lnet_find_peer_ni_locked(info->cud_nid);
+		if (!lpni) {
+			CDEBUG(D_NET, "nid %s is not found\n",
+			       libcfs_nid2str(info->cud_nid));
+		} else {
+			lnet_udsp_get_peer_info(info, lpni);
+			lnet_peer_ni_decref_locked(lpni);
+		}
+	}
+	lnet_net_unlock(0);
+}
+
 struct lnet_udsp *
 lnet_udsp_alloc(void)
 {
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
