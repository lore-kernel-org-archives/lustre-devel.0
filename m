Return-Path: <SRS0=WSMT=J7=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 503A4C433ED
	for <lustre-devel@archiver.kernel.org>; Tue,  4 May 2021 00:10:33 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 53E0261185
	for <lustre-devel@archiver.kernel.org>; Tue,  4 May 2021 00:10:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 53E0261185
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 9D70C21F7AE;
	Mon,  3 May 2021 17:10:28 -0700 (PDT)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id BEB3321F3B4
 for <lustre-devel@lists.lustre.org>; Mon,  3 May 2021 17:10:22 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 223E5EDE;
 Mon,  3 May 2021 20:10:20 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 1A7CC8AD42; Mon,  3 May 2021 20:10:20 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon,  3 May 2021 20:10:06 -0400
Message-Id: <1620087016-17857-5-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1620087016-17857-1-git-send-email-jsimmons@infradead.org>
References: <1620087016-17857-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 04/14] lnet: Deprecate lnet_recovery_interval
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

We no longer use a static recovery interval, so remove its remaining
uses and add warning that it has been deprecated.

HPE-bug-id: LUS-9109
C-bug-id: https://jira.whamcloud.com/browse/LU-13569
Lustre-commit: 79ab0535622782c82 ("LU-13569 lnet: Deprecate lnet_recovery_interval")
Signed-off-by: Chris Horn <chris.horn@hpe.com>
Reviewed-on: https://review.whamcloud.com/39722
Reviewed-by: Neil Brown <neilb@suse.de>
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/api-ni.c   | 26 ++------------------------
 net/lnet/lnet/lib-move.c | 19 +++----------------
 2 files changed, 5 insertions(+), 40 deletions(-)

diff --git a/net/lnet/lnet/api-ni.c b/net/lnet/lnet/api-ni.c
index cc40040..d6a8c1b 100644
--- a/net/lnet/lnet/api-ni.c
+++ b/net/lnet/lnet/api-ni.c
@@ -110,7 +110,7 @@ static int recovery_interval_set(const char *val,
 		__param_check(name, p, int)
 module_param(lnet_recovery_interval, recovery_interval, 0644);
 MODULE_PARM_DESC(lnet_recovery_interval,
-		 "Interval to recover unhealthy interfaces in seconds");
+		 "DEPRECATED Interval to recover unhealthy interfaces in seconds");
 
 unsigned int lnet_recovery_limit;
 module_param(lnet_recovery_limit, uint, 0644);
@@ -253,29 +253,7 @@ static int lnet_discover(struct lnet_process_id id, u32 force,
 static int
 recovery_interval_set(const char *val, const struct kernel_param *kp)
 {
-	int rc;
-	unsigned int *interval = (unsigned int *)kp->arg;
-	unsigned long value;
-
-	rc = kstrtoul(val, 0, &value);
-	if (rc) {
-		CERROR("Invalid module parameter value for 'lnet_recovery_interval'\n");
-		return rc;
-	}
-
-	if (value < 1) {
-		CERROR("lnet_recovery_interval must be at least 1 second\n");
-		return -EINVAL;
-	}
-
-	/* The purpose of locking the api_mutex here is to ensure that
-	 * the correct value ends up stored properly.
-	 */
-	mutex_lock(&the_lnet.ln_api_mutex);
-
-	*interval = value;
-
-	mutex_unlock(&the_lnet.ln_api_mutex);
+	CWARN("'lnet_recovery_interval' has been deprecated\n");
 
 	return 0;
 }
diff --git a/net/lnet/lnet/lib-move.c b/net/lnet/lnet/lib-move.c
index 46c88d0..cb0943e 100644
--- a/net/lnet/lnet/lib-move.c
+++ b/net/lnet/lnet/lib-move.c
@@ -3480,9 +3480,7 @@ struct lnet_mt_event_info {
 static int
 lnet_monitor_thread(void *arg)
 {
-	time64_t recovery_timeout = 0;
 	time64_t rsp_timeout = 0;
-	int interval;
 	time64_t now;
 
 	wait_for_completion(&the_lnet.ln_started);
@@ -3509,11 +3507,8 @@ struct lnet_mt_event_info {
 			rsp_timeout = now + (lnet_transaction_timeout / 2);
 		}
 
-		if (now >= recovery_timeout) {
-			lnet_recover_local_nis();
-			lnet_recover_peer_nis();
-			recovery_timeout = now + lnet_recovery_interval;
-		}
+		lnet_recover_local_nis();
+		lnet_recover_peer_nis();
 
 		/* TODO do we need to check if we should sleep without
 		 * timeout?  Technically, an active system will always
@@ -3522,17 +3517,9 @@ struct lnet_mt_event_info {
 		 * if we wake up every 1 second? Although, we've seen
 		 * cases where we get a complaint that an idle thread
 		 * is waking up unnecessarily.
-		 *
-		 * Take into account the current net_count when you wake
-		 * up for alive router checking, since we need to check
-		 * possibly as many networks as we have configured.
 		 */
-		interval = min(lnet_recovery_interval,
-			       min((unsigned int)alive_router_check_interval /
-					lnet_current_net_count,
-				   lnet_transaction_timeout / 2));
 		wait_for_completion_interruptible_timeout(&the_lnet.ln_mt_wait_complete,
-							  interval * HZ);
+							  HZ);
 		/* Must re-init the completion before testing anything,
 		 * including ln_mt_state.
 		 */
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
