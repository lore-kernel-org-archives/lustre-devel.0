Return-Path: <SRS0=Kfxm=MZ=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.7 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 558B9C4338F
	for <lustre-devel@archiver.kernel.org>; Mon,  2 Aug 2021 19:54:35 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id A4B7260F36
	for <lustre-devel@archiver.kernel.org>; Mon,  2 Aug 2021 19:54:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.1 mail.kernel.org A4B7260F36
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id CA473352F18;
	Mon,  2 Aug 2021 12:54:25 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 13D5335286A
 for <lustre-devel@lists.lustre.org>; Mon,  2 Aug 2021 12:50:56 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 5A74F1007AA6;
 Mon,  2 Aug 2021 15:50:53 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 528E0C2F56; Mon,  2 Aug 2021 15:50:53 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon,  2 Aug 2021 15:50:25 -0400
Message-Id: <1627933851-7603-6-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1627933851-7603-1-git-send-email-jsimmons@infradead.org>
References: <1627933851-7603-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 05/25] lnet: print device status in net show
 command
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

A device can be in fatal state, if the cable was disconnected, or the
port brought down on the switch side. In these cases, the LND (o2iblnd
for now), will flag the device in fatal state. That device will not be
used any further. However, it's health will not be decremented. This
causes some confusion when examining the state of the node.
It is better to print the device status in the output of the lnetctl
net show command.

WC-bug-id: https://jira.whamcloud.com/browse/LU-14114
Lustre-commit: f75ff33d9fbefd69 ("LU-14114 lnet: print device status in net show command")
Signed-off-by: Cyril Bordage <cbordage@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/44169
Reviewed-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-by: Chris Horn <chris.horn@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/uapi/linux/lnet/lnet-dlc.h | 1 +
 net/lnet/lnet/api-ni.c             | 2 ++
 2 files changed, 3 insertions(+)

diff --git a/include/uapi/linux/lnet/lnet-dlc.h b/include/uapi/linux/lnet/lnet-dlc.h
index c1c063f..ef60224 100644
--- a/include/uapi/linux/lnet/lnet-dlc.h
+++ b/include/uapi/linux/lnet/lnet-dlc.h
@@ -190,6 +190,7 @@ struct lnet_ioctl_local_ni_hstats {
 	__u32 hlni_local_no_route;
 	__u32 hlni_local_timeout;
 	__u32 hlni_local_error;
+	__s32 hlni_fatal_error;
 	__s32 hlni_health_value;
 	__u32 hlni_ping_count;
 	__u64 hlni_next_ping;
diff --git a/net/lnet/lnet/api-ni.c b/net/lnet/lnet/api-ni.c
index ec28139..4513d8d 100644
--- a/net/lnet/lnet/api-ni.c
+++ b/net/lnet/lnet/api-ni.c
@@ -3692,6 +3692,8 @@ u32 lnet_get_dlc_seq_locked(void)
 		atomic_read(&ni->ni_hstats.hlt_local_timeout);
 	stats->hlni_local_error =
 		atomic_read(&ni->ni_hstats.hlt_local_error);
+	stats->hlni_fatal_error =
+		atomic_read(&ni->ni_fatal_error_on);
 	stats->hlni_health_value =
 		atomic_read(&ni->ni_healthv);
 	stats->hlni_ping_count = ni->ni_ping_count;
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
