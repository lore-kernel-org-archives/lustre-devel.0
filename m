Return-Path: <SRS0=Kfxm=MZ=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.7 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3D7BBC4338F
	for <lustre-devel@archiver.kernel.org>; Mon,  2 Aug 2021 19:54:22 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 0267960FC2
	for <lustre-devel@archiver.kernel.org>; Mon,  2 Aug 2021 19:54:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.1 mail.kernel.org 0267960FC2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 2F975351FD1;
	Mon,  2 Aug 2021 12:54:19 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 8496635286A
 for <lustre-devel@lists.lustre.org>; Mon,  2 Aug 2021 12:50:55 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 53C4F1007A8F;
 Mon,  2 Aug 2021 15:50:53 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 4B3B5C2F53; Mon,  2 Aug 2021 15:50:53 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon,  2 Aug 2021 15:50:23 -0400
Message-Id: <1627933851-7603-4-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1627933851-7603-1-git-send-email-jsimmons@infradead.org>
References: <1627933851-7603-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 03/25] lnet: discard lnet_current_net_count
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
Cc: Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Mr NeilBrown <neilb@suse.de>

The variable lnet_current_net_count is never used.  So remove it.
The function lnet_get_net_count() is only used to update thar
variable, so remove it too.

WC-bug-id: https://jira.whamcloud.com/browse/LU-6142
Lsutre-commit: a39f07804153f4f4 ("LU-6142 lnet: discard lnet_current_net_count")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/44089
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/lib-lnet.h |  1 -
 net/lnet/lnet/api-ni.c        | 22 ----------------------
 2 files changed, 23 deletions(-)

diff --git a/include/linux/lnet/lib-lnet.h b/include/linux/lnet/lib-lnet.h
index f56ecab..3677a12 100644
--- a/include/linux/lnet/lib-lnet.h
+++ b/include/linux/lnet/lib-lnet.h
@@ -804,7 +804,6 @@ bool lnet_net_unique(u32 net_id, struct list_head *nilist,
 bool lnet_ni_unique_net(struct list_head *nilist, char *iface);
 void lnet_incr_dlc_seq(void);
 u32 lnet_get_dlc_seq_locked(void);
-int lnet_get_net_count(void);
 
 struct lnet_peer_net *lnet_get_next_peer_net_locked(struct lnet_peer *lp,
 						    u32 prev_lpn_id);
diff --git a/net/lnet/lnet/api-ni.c b/net/lnet/lnet/api-ni.c
index dc9020d..ec28139 100644
--- a/net/lnet/lnet/api-ni.c
+++ b/net/lnet/lnet/api-ni.c
@@ -196,8 +196,6 @@ static void lnet_set_lnd_timeout(void)
 			   (lnet_retry_count + 1);
 }
 
-unsigned int lnet_current_net_count;
-
 /*
  * This sequence number keeps track of how many times DLC was used to
  * update the local NIs. It is incremented when a NI is added or
@@ -1671,23 +1669,6 @@ struct lnet_ping_buffer *
 	return count;
 }
 
-int
-lnet_get_net_count(void)
-{
-	struct lnet_net *net;
-	int count = 0;
-
-	lnet_net_lock(0);
-
-	list_for_each_entry(net, &the_lnet.ln_nets, net_list) {
-		count++;
-	}
-
-	lnet_net_unlock(0);
-
-	return count;
-}
-
 void
 lnet_swap_pinginfo(struct lnet_ping_buffer *pbuf)
 {
@@ -2516,9 +2497,6 @@ static void lnet_push_target_fini(void)
 		lnet_net_unlock(LNET_LOCK_EX);
 	}
 
-	/* update net count */
-	lnet_current_net_count = lnet_get_net_count();
-
 	return ni_count;
 
 failed1:
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
