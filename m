Return-Path: <SRS0=Kfxm=MZ=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.7 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B2D9FC4338F
	for <lustre-devel@archiver.kernel.org>; Mon,  2 Aug 2021 19:52:10 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 7277260FC2
	for <lustre-devel@archiver.kernel.org>; Mon,  2 Aug 2021 19:52:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.1 mail.kernel.org 7277260FC2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 0B611352F66;
	Mon,  2 Aug 2021 12:51:49 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 35FF4352D06
 for <lustre-devel@lists.lustre.org>; Mon,  2 Aug 2021 12:51:03 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id A38FC100F364;
 Mon,  2 Aug 2021 15:50:53 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id A2AD8C2F53; Mon,  2 Aug 2021 15:50:53 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon,  2 Aug 2021 15:50:51 -0400
Message-Id: <1627933851-7603-32-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1627933851-7603-1-git-send-email-jsimmons@infradead.org>
References: <1627933851-7603-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 26/26] lnet: add "stats reset" to lnetctl
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
Cc: Cyril Bordage <cbordage@whamcloud.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Cyril Bordage <cbordage@whamcloud.com>

This new command resets stats shown by "lnetctl stats show". It could
be useful when debugging connectivity issues, by making easier the
process to detect the changes in stats from the clean state rather
than on top of historical values.

WC-bug-id: https://jira.whamcloud.com/browse/LU-13299
Lustre-commit: db0b09018e771146 ("LU-13299 lnet: add "stats reset" to lnetctl")
Signed-off-by: Cyril Bordage <cbordage@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/44150
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/uapi/linux/lnet/libcfs_ioctl.h | 3 ++-
 net/lnet/lnet/api-ni.c                 | 8 ++++++++
 2 files changed, 10 insertions(+), 1 deletion(-)

diff --git a/include/uapi/linux/lnet/libcfs_ioctl.h b/include/uapi/linux/lnet/libcfs_ioctl.h
index 2c900ef..7b1c880 100644
--- a/include/uapi/linux/lnet/libcfs_ioctl.h
+++ b/include/uapi/linux/lnet/libcfs_ioctl.h
@@ -155,6 +155,7 @@ struct libcfs_ioctl_data {
 #define IOC_LIBCFS_GET_UDSP_SIZE	_IOWR(IOC_LIBCFS_TYPE, 107, IOCTL_CONFIG_SIZE)
 #define IOC_LIBCFS_GET_UDSP		_IOWR(IOC_LIBCFS_TYPE, 108, IOCTL_CONFIG_SIZE)
 #define IOC_LIBCFS_GET_CONST_UDSP_INFO	_IOWR(IOC_LIBCFS_TYPE, 109, IOCTL_CONFIG_SIZE)
-#define IOC_LIBCFS_MAX_NR				       109
+#define IOC_LIBCFS_RESET_LNET_STATS	_IOWR(IOC_LIBCFS_TYPE, 110, IOCTL_CONFIG_SIZE)
+#define IOC_LIBCFS_MAX_NR				       110
 
 #endif /* __LIBCFS_IOCTL_H__ */
diff --git a/net/lnet/lnet/api-ni.c b/net/lnet/lnet/api-ni.c
index 4513d8d..c7df936 100644
--- a/net/lnet/lnet/api-ni.c
+++ b/net/lnet/lnet/api-ni.c
@@ -3886,6 +3886,14 @@ u32 lnet_get_dlc_seq_locked(void)
 		return rc;
 	}
 
+	case IOC_LIBCFS_RESET_LNET_STATS:
+	{
+		mutex_lock(&the_lnet.ln_api_mutex);
+		lnet_counters_reset();
+		mutex_unlock(&the_lnet.ln_api_mutex);
+		return 0;
+	}
+
 	case IOC_LIBCFS_CONFIG_RTR:
 		config = arg;
 
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
