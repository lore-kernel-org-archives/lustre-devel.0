Return-Path: <SRS0=o51I=JC=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.7 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3E8AFC433B4
	for <lustre-devel@archiver.kernel.org>; Mon,  5 Apr 2021 00:52:32 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id EFAFF6138E
	for <lustre-devel@archiver.kernel.org>; Mon,  5 Apr 2021 00:52:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EFAFF6138E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 8A4D821FB74;
	Mon,  5 Apr 2021 00:52:04 +0000 (UTC)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id A90EB21F8AA
 for <lustre-devel@lists.lustre.org>; Mon,  5 Apr 2021 00:51:22 +0000 (UTC)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id C0E6E6DF;
 Sun,  4 Apr 2021 20:51:16 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id BF81490AA8; Sun,  4 Apr 2021 20:51:16 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun,  4 Apr 2021 20:50:45 -0400
Message-Id: <1617583870-32029-17-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1617583870-32029-1-git-send-email-jsimmons@infradead.org>
References: <1617583870-32029-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 16/41] lnet: Add the ioctl handler for "add
 policy"
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

The ioctl handler for "add policy" de-marshals the
udsp rules passed from userspace and then add the
rules if there is no copy of the same rules already
added. Apply the rules to the existing LNet
constructs.

WC-bug-id: https://jira.whamcloud.com/browse/LU-9121
Lustre-commit: 1fdb21ac697c368 ("LU-9121 lnet: Add the ioctl handler for "add policy"")
Signed-off-by: Sonia Sharma <sharmaso@whamcloud.com>
Signed-off-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/34514
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: Chris Horn <chris.horn@hpe.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/uapi/linux/lnet/libcfs_ioctl.h |  3 ++-
 net/lnet/lnet/api-ni.c                 | 16 ++++++++++++++++
 2 files changed, 18 insertions(+), 1 deletion(-)

diff --git a/include/uapi/linux/lnet/libcfs_ioctl.h b/include/uapi/linux/lnet/libcfs_ioctl.h
index c9d42361..6cffa01 100644
--- a/include/uapi/linux/lnet/libcfs_ioctl.h
+++ b/include/uapi/linux/lnet/libcfs_ioctl.h
@@ -150,6 +150,7 @@ struct libcfs_ioctl_data {
 #define IOC_LIBCFS_SET_HEALHV		_IOWR(IOC_LIBCFS_TYPE, 102, IOCTL_CONFIG_SIZE)
 #define IOC_LIBCFS_GET_LOCAL_HSTATS	_IOWR(IOC_LIBCFS_TYPE, 103, IOCTL_CONFIG_SIZE)
 #define IOC_LIBCFS_GET_RECOVERY_QUEUE	_IOWR(IOC_LIBCFS_TYPE, 104, IOCTL_CONFIG_SIZE)
-#define IOC_LIBCFS_MAX_NR		104
+#define IOC_LIBCFS_ADD_UDSP		_IOWR(IOC_LIBCFS_TYPE, 105, IOCTL_CONFIG_SIZE)
+#define IOC_LIBCFS_MAX_NR				       105
 
 #endif /* __LIBCFS_IOCTL_H__ */
diff --git a/net/lnet/lnet/api-ni.c b/net/lnet/lnet/api-ni.c
index 9ff2776..fe8da30 100644
--- a/net/lnet/lnet/api-ni.c
+++ b/net/lnet/lnet/api-ni.c
@@ -4126,6 +4126,22 @@ u32 lnet_get_dlc_seq_locked(void)
 		return 0;
 	}
 
+	case IOC_LIBCFS_ADD_UDSP: {
+		struct lnet_ioctl_udsp *ioc_udsp = arg;
+		u32 bulk_size = ioc_udsp->iou_hdr.ioc_len;
+
+		mutex_lock(&the_lnet.ln_api_mutex);
+		rc = lnet_udsp_demarshal_add(arg, bulk_size);
+		if (!rc) {
+			rc = lnet_udsp_apply_policies(NULL, false);
+			CDEBUG(D_NET, "policy application returned %d\n", rc);
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
