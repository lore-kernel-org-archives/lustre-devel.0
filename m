Return-Path: <SRS0=JyPa=L7=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 58A91C07E95
	for <lustre-devel@archiver.kernel.org>; Wed,  7 Jul 2021 19:12:14 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 1D98561C48
	for <lustre-devel@archiver.kernel.org>; Wed,  7 Jul 2021 19:12:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1D98561C48
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id D6DE6338A3E;
	Wed,  7 Jul 2021 12:11:55 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id B20DA21F888
 for <lustre-devel@lists.lustre.org>; Wed,  7 Jul 2021 12:11:20 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 4056410090E6;
 Wed,  7 Jul 2021 15:11:18 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 3939E9D8BD; Wed,  7 Jul 2021 15:11:18 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Wed,  7 Jul 2021 15:11:05 -0400
Message-Id: <1625685076-1964-5-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1625685076-1964-1-git-send-email-jsimmons@infradead.org>
References: <1625685076-1964-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 04/15] lnet: Add health ping stats
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
Cc: Chris Horn <chris.horn@hpe.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Chris Horn <chris.horn@hpe.com>

Add the NI and peer NI ping count and next ping timestamp to
detailed output of lnetctl peer and net output.

HPE-bug-id: LUS-9109
WC-bug-id: https://jira.whamcloud.com/browse/LU-13569
Lustre-commit: 4c7e4aa576296603 ("LU-13569 lnet: Add health ping stats")
Signed-off-by: Chris Horn <chris.horn@hpe.com>
Reviewed-on: https://review.whamcloud.com/40314
Reviewed-by: Alexander Boyko <alexander.boyko@hpe.com>
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/uapi/linux/lnet/lnet-dlc.h | 4 ++++
 net/lnet/lnet/api-ni.c             | 2 ++
 net/lnet/lnet/peer.c               | 7 +++++--
 3 files changed, 11 insertions(+), 2 deletions(-)

diff --git a/include/uapi/linux/lnet/lnet-dlc.h b/include/uapi/linux/lnet/lnet-dlc.h
index b375d0a..c1c063f 100644
--- a/include/uapi/linux/lnet/lnet-dlc.h
+++ b/include/uapi/linux/lnet/lnet-dlc.h
@@ -191,6 +191,8 @@ struct lnet_ioctl_local_ni_hstats {
 	__u32 hlni_local_timeout;
 	__u32 hlni_local_error;
 	__s32 hlni_health_value;
+	__u32 hlni_ping_count;
+	__u64 hlni_next_ping;
 };
 
 struct lnet_ioctl_peer_ni_hstats {
@@ -199,6 +201,8 @@ struct lnet_ioctl_peer_ni_hstats {
 	__u32 hlpni_remote_error;
 	__u32 hlpni_network_timeout;
 	__s32 hlpni_health_value;
+	__u32 hlpni_ping_count;
+	__u64 hlpni_next_ping;
 };
 
 struct lnet_ioctl_element_msg_stats {
diff --git a/net/lnet/lnet/api-ni.c b/net/lnet/lnet/api-ni.c
index d6a8c1b..e52bb41 100644
--- a/net/lnet/lnet/api-ni.c
+++ b/net/lnet/lnet/api-ni.c
@@ -3634,6 +3634,8 @@ u32 lnet_get_dlc_seq_locked(void)
 		atomic_read(&ni->ni_hstats.hlt_local_error);
 	stats->hlni_health_value =
 		atomic_read(&ni->ni_healthv);
+	stats->hlni_ping_count = ni->ni_ping_count;
+	stats->hlni_next_ping = ni->ni_next_ping;
 
 unlock:
 	lnet_net_unlock(cpt);
diff --git a/net/lnet/lnet/peer.c b/net/lnet/lnet/peer.c
index 2fc784d..76b2d2f 100644
--- a/net/lnet/lnet/peer.c
+++ b/net/lnet/lnet/peer.c
@@ -3986,6 +3986,8 @@ int lnet_get_peer_info(struct lnet_ioctl_peer_cfg *cfg, void __user *bulk)
 			atomic_read(&lpni->lpni_hstats.hlt_remote_error);
 		lpni_hstats->hlpni_health_value =
 			atomic_read(&lpni->lpni_healthv);
+		lpni_hstats->hlpni_ping_count = lpni->lpni_ping_count;
+		lpni_hstats->hlpni_next_ping = lpni->lpni_next_ping;
 		if (copy_to_user(bulk, lpni_hstats, sizeof(*lpni_hstats)))
 			goto out_free_hstats;
 		bulk += sizeof(*lpni_hstats);
@@ -4081,7 +4083,7 @@ int lnet_get_peer_info(struct lnet_ioctl_peer_cfg *cfg, void __user *bulk)
 			lnet_net_unlock(LNET_LOCK_EX);
 			return;
 		}
-		atomic_set(&lpni->lpni_healthv, value);
+		lnet_set_lpni_healthv_locked(lpni, value);
 		lnet_peer_ni_add_to_recoveryq_locked(lpni,
 						     &the_lnet.ln_mt_peerNIRecovq, now);
 		lnet_peer_ni_decref_locked(lpni);
@@ -4102,7 +4104,8 @@ int lnet_get_peer_info(struct lnet_ioctl_peer_cfg *cfg, void __user *bulk)
 					    lpn_peer_nets) {
 				list_for_each_entry(lpni, &lpn->lpn_peer_nis,
 						    lpni_peer_nis) {
-					atomic_set(&lpni->lpni_healthv, value);
+					lnet_set_lpni_healthv_locked(lpni,
+								     value);
 					lnet_peer_ni_add_to_recoveryq_locked(lpni,
 									     &the_lnet.ln_mt_peerNIRecovq,
 									     now);
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
