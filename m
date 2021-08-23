Return-Path: <SRS0=6+cL=NO=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6EA01C4320A
	for <lustre-devel@archiver.kernel.org>; Mon, 23 Aug 2021 02:28:39 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 2BFCD61360
	for <lustre-devel@archiver.kernel.org>; Mon, 23 Aug 2021 02:28:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.1 mail.kernel.org 2BFCD61360
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 4E9B021EB6D;
	Sun, 22 Aug 2021 19:28:17 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 65A2521CAB1
 for <lustre-devel@lists.lustre.org>; Sun, 22 Aug 2021 19:27:51 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 24EE1100BAF8;
 Sun, 22 Aug 2021 22:27:48 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 15AF7B6C91; Sun, 22 Aug 2021 22:27:48 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 22 Aug 2021 22:27:35 -0400
Message-Id: <1629685666-4533-5-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1629685666-4533-1-git-send-email-jsimmons@infradead.org>
References: <1629685666-4533-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 04/15] lnet: Reflect ni_fatal in NI status
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

If the ni_fatal_error_on flag is set on an NI then that NI should be
considered down.

HPE-bug-id: LUS-10167
WC-bug-id: https://jira.whamcloud.com/browse/LU-14790
Lustre-commit: d77e95cc6d4e947b ("LU-14790 lnet: Reflect ni_fatal in NI status")
Signed-off-by: Chris Horn <chris.horn@hpe.com>
Reviewed-on: https://review.whamcloud.com/44072
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: Cyril Bordage <cbordage@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/lib-lnet.h | 14 ++++++++++++++
 net/lnet/lnet/api-ni.c        | 14 +++-----------
 net/lnet/lnet/router_proc.c   |  2 +-
 3 files changed, 18 insertions(+), 12 deletions(-)

diff --git a/include/linux/lnet/lib-lnet.h b/include/linux/lnet/lib-lnet.h
index 3677a12..ed54477 100644
--- a/include/linux/lnet/lib-lnet.h
+++ b/include/linux/lnet/lib-lnet.h
@@ -116,6 +116,20 @@
 	return update;
 }
 
+static inline unsigned int
+lnet_ni_get_status_locked(struct lnet_ni *ni)
+__must_hold(&ni->ni_lock)
+{
+	if (ni->ni_nid == LNET_NID_LO_0)
+		return LNET_NI_STATUS_UP;
+	else if (atomic_read(&ni->ni_fatal_error_on))
+		return LNET_NI_STATUS_DOWN;
+	else if (ni->ni_status)
+		return ni->ni_status->ns_status;
+	else
+		return LNET_NI_STATUS_UP;
+}
+
 static inline bool
 lnet_ni_set_status(struct lnet_ni *ni, u32 status)
 {
diff --git a/net/lnet/lnet/api-ni.c b/net/lnet/lnet/api-ni.c
index c7df936..370c1d6 100644
--- a/net/lnet/lnet/api-ni.c
+++ b/net/lnet/lnet/api-ni.c
@@ -1829,9 +1829,7 @@ struct lnet_ping_buffer *
 			ns->ns_nid = ni->ni_nid;
 
 			lnet_ni_lock(ni);
-			ns->ns_status = ni->ni_status ?
-					ni->ni_status->ns_status :
-						LNET_NI_STATUS_UP;
+			ns->ns_status = lnet_ni_get_status_locked(ni);
 			ni->ni_status = ns;
 			lnet_ni_unlock(ni);
 
@@ -2936,10 +2934,7 @@ void lnet_lib_exit(void)
 	}
 
 	cfg_ni->lic_nid = ni->ni_nid;
-	if (ni->ni_nid == LNET_NID_LO_0)
-		cfg_ni->lic_status = LNET_NI_STATUS_UP;
-	else
-		cfg_ni->lic_status = ni->ni_status->ns_status;
+	cfg_ni->lic_status = lnet_ni_get_status_locked(ni);
 	cfg_ni->lic_dev_cpt = ni->ni_dev_cpt;
 
 	memcpy(&tun->lt_cmn, &ni->ni_net->net_tunables, sizeof(tun->lt_cmn));
@@ -3022,10 +3017,7 @@ void lnet_lib_exit(void)
 	config->cfg_config_u.cfg_net.net_peer_rtr_credits =
 		ni->ni_net->net_tunables.lct_peer_rtr_credits;
 
-	if (ni->ni_nid == LNET_NID_LO_0)
-		net_config->ni_status = LNET_NI_STATUS_UP;
-	else
-		net_config->ni_status = ni->ni_status->ns_status;
+	net_config->ni_status = lnet_ni_get_status_locked(ni);
 
 	if (ni->ni_cpts) {
 		int num_cpts = min(ni->ni_ncpts, LNET_MAX_SHOW_NUM_CPT);
diff --git a/net/lnet/lnet/router_proc.c b/net/lnet/lnet/router_proc.c
index 0de6681..43f70b6 100644
--- a/net/lnet/lnet/router_proc.c
+++ b/net/lnet/lnet/router_proc.c
@@ -673,7 +673,7 @@ static int proc_lnet_nis(struct ctl_table *table, int write,
 
 			lnet_ni_lock(ni);
 			LASSERT(ni->ni_status);
-			stat = (ni->ni_status->ns_status ==
+			stat = (lnet_ni_get_status_locked(ni) ==
 				LNET_NI_STATUS_UP) ? "up" : "down";
 			lnet_ni_unlock(ni);
 
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
