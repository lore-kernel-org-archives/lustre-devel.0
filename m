Return-Path: <SRS0=o51I=JC=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.7 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 976CAC433B4
	for <lustre-devel@archiver.kernel.org>; Mon,  5 Apr 2021 00:51:50 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 521CE6138E
	for <lustre-devel@archiver.kernel.org>; Mon,  5 Apr 2021 00:51:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 521CE6138E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 4A3C832C515;
	Mon,  5 Apr 2021 00:51:37 +0000 (UTC)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id E381421F8DD
 for <lustre-devel@lists.lustre.org>; Mon,  5 Apr 2021 00:51:22 +0000 (UTC)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id C58B39E9;
 Sun,  4 Apr 2021 20:51:16 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id C347C90AB2; Sun,  4 Apr 2021 20:51:16 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun,  4 Apr 2021 20:50:46 -0400
Message-Id: <1617583870-32029-18-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1617583870-32029-1-git-send-email-jsimmons@infradead.org>
References: <1617583870-32029-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 17/41] lnet: ioctl handler for "delete policy"
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

From: Sonia Sharma <sharmaso@whamcloud.com>

The ioctl handler for "delete policy" deletes
a policy with the given index value. It
returns 0 if a policy with that index is found
else it returns -EINVAL.

WC-bug-id: https://jira.whamcloud.com/browse/LU-9121
Lustre-commit: 8258e7235c7047b ("LU-9121 lnet: ioctl handler for "delete policy"")
Signed-off-by: Sonia Sharma <sharmaso@whamcloud.com>
Signed-off-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/34552
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: Chris Horn <chris.horn@hpe.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/uapi/linux/lnet/libcfs_ioctl.h |  3 ++-
 net/lnet/lnet/api-ni.c                 | 20 ++++++++++++++++++++
 2 files changed, 22 insertions(+), 1 deletion(-)

diff --git a/include/uapi/linux/lnet/libcfs_ioctl.h b/include/uapi/linux/lnet/libcfs_ioctl.h
index 6cffa01..9e3c427 100644
--- a/include/uapi/linux/lnet/libcfs_ioctl.h
+++ b/include/uapi/linux/lnet/libcfs_ioctl.h
@@ -151,6 +151,7 @@ struct libcfs_ioctl_data {
 #define IOC_LIBCFS_GET_LOCAL_HSTATS	_IOWR(IOC_LIBCFS_TYPE, 103, IOCTL_CONFIG_SIZE)
 #define IOC_LIBCFS_GET_RECOVERY_QUEUE	_IOWR(IOC_LIBCFS_TYPE, 104, IOCTL_CONFIG_SIZE)
 #define IOC_LIBCFS_ADD_UDSP		_IOWR(IOC_LIBCFS_TYPE, 105, IOCTL_CONFIG_SIZE)
-#define IOC_LIBCFS_MAX_NR				       105
+#define IOC_LIBCFS_DEL_UDSP		_IOWR(IOC_LIBCFS_TYPE, 106, IOCTL_CONFIG_SIZE)
+#define IOC_LIBCFS_MAX_NR				       106
 
 #endif /* __LIBCFS_IOCTL_H__ */
diff --git a/net/lnet/lnet/api-ni.c b/net/lnet/lnet/api-ni.c
index fe8da30..50f7b9e 100644
--- a/net/lnet/lnet/api-ni.c
+++ b/net/lnet/lnet/api-ni.c
@@ -4142,6 +4142,26 @@ u32 lnet_get_dlc_seq_locked(void)
 		return rc;
 	}
 
+	case IOC_LIBCFS_DEL_UDSP: {
+		struct lnet_ioctl_udsp *ioc_udsp = arg;
+		int idx = ioc_udsp->iou_idx;
+
+		if (ioc_udsp->iou_hdr.ioc_len < sizeof(*ioc_udsp))
+			return -EINVAL;
+
+		mutex_lock(&the_lnet.ln_api_mutex);
+		rc = lnet_udsp_del_policy(idx);
+		if (!rc) {
+			rc = lnet_udsp_apply_policies(NULL, false);
+			CDEBUG(D_NET, "policy re-application returned %d\n",
+			       rc);
+			rc = 0;
+		}
+		mutex_unlock(&the_lnet.ln_api_mutex);
+
+		return rc;
+	}
+
 	default:
 		ni = lnet_net2ni_addref(data->ioc_net);
 		if (!ni)
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
