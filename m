Return-Path: <SRS0=JyPa=L7=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BA696C07E95
	for <lustre-devel@archiver.kernel.org>; Wed,  7 Jul 2021 19:11:39 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 6D00B61A13
	for <lustre-devel@archiver.kernel.org>; Wed,  7 Jul 2021 19:11:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6D00B61A13
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 0C5ED3379F4;
	Wed,  7 Jul 2021 12:11:32 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 013F921F978
 for <lustre-devel@lists.lustre.org>; Wed,  7 Jul 2021 12:11:23 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 5C9B1100F3E1;
 Wed,  7 Jul 2021 15:11:18 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 5B8D69D8BA; Wed,  7 Jul 2021 15:11:18 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Wed,  7 Jul 2021 15:11:16 -0400
Message-Id: <1625685076-1964-16-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1625685076-1964-1-git-send-email-jsimmons@infradead.org>
References: <1625685076-1964-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 15/15] lustre: mgc: configurable
 wait-to-reprocess time
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

From: Alex Zhuravlev <bzzz@whamcloud.com>

so we can set it shorter, for testing purposes at least. to change
minimal wait time MGC module option 'mgc_requeue_timeout_min'
should be used (in seconds). additionally a random value upto
mgc_requeue_timeout_min is added to avoid a flood of config re-read
requests from clients. if mgc_requeue_timeout_min is set to 0,
then random part will be upto 1 second.

ost-pools: before: 5840s, after:a 3474s
sanity-flr: before: 1575s, after: 1381s
sanity-quota: before: 10679s, after: 9703s

WC-bug-id: https://jira.whamcloud.com/browse/LU-14516
Lustre-commit: 04b2da6180d3c8eda ("LU-14516 mgc: configurable wait-to-reprocess time")
Signed-off-by: Alex Zhuravlev <bzzz@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/42020
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Aurelien Degremont <degremoa@amazon.com>
Reviewed-by: Sebastien Buisson <sbuisson@ddn.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/mgc/mgc_internal.h |  8 ++++++++
 fs/lustre/mgc/mgc_request.c  | 44 +++++++++++++++++++++++++++++++++-----------
 2 files changed, 41 insertions(+), 11 deletions(-)

diff --git a/fs/lustre/mgc/mgc_internal.h b/fs/lustre/mgc/mgc_internal.h
index a2a09d4..91f5fa1 100644
--- a/fs/lustre/mgc/mgc_internal.h
+++ b/fs/lustre/mgc/mgc_internal.h
@@ -43,6 +43,14 @@
 
 int mgc_process_log(struct obd_device *mgc, struct config_llog_data *cld);
 
+/* this timeout represents how many seconds MGC should wait before
+ * requeue config and recover lock to the MGS. We need to randomize this
+ * in order to not flood the MGS.
+ */
+#define MGC_TIMEOUT_MIN_SECONDS		5
+
+extern unsigned int mgc_requeue_timeout_min;
+
 static inline bool cld_is_sptlrpc(struct config_llog_data *cld)
 {
 	return cld->cld_type == MGS_CFG_T_SPTLRPC;
diff --git a/fs/lustre/mgc/mgc_request.c b/fs/lustre/mgc/mgc_request.c
index 1dfc74b..50044aa2 100644
--- a/fs/lustre/mgc/mgc_request.c
+++ b/fs/lustre/mgc/mgc_request.c
@@ -530,13 +530,6 @@ static void do_requeue(struct config_llog_data *cld)
 	up_read(&cld->cld_mgcexp->exp_obd->u.cli.cl_sem);
 }
 
-/* this timeout represents how many seconds MGC should wait before
- * requeue config and recover lock to the MGS. We need to randomize this
- * in order to not flood the MGS.
- */
-#define MGC_TIMEOUT_MIN_SECONDS   5
-#define MGC_TIMEOUT_RAND_CENTISEC 500
-
 static int mgc_requeue_thread(void *data)
 {
 	bool first = true;
@@ -548,7 +541,6 @@ static int mgc_requeue_thread(void *data)
 	rq_state |= RQ_RUNNING;
 	while (!(rq_state & RQ_STOP)) {
 		struct config_llog_data *cld, *cld_prev;
-		int rand = prandom_u32_max(MGC_TIMEOUT_RAND_CENTISEC);
 		int to;
 
 		/* Any new or requeued lostlocks will change the state */
@@ -565,11 +557,11 @@ static int mgc_requeue_thread(void *data)
 		 * random so everyone doesn't try to reconnect at once.
 		 */
 		/* rand is centi-seconds, "to" is in centi-HZ */
-		to = MGC_TIMEOUT_MIN_SECONDS * HZ * 100;
-		to += rand * HZ;
+		to = mgc_requeue_timeout_min == 0 ? 1 : mgc_requeue_timeout_min;
+		to = mgc_requeue_timeout_min * HZ + prandom_u32_max(to * HZ);
 		wait_event_idle_timeout(rq_waitq,
 					rq_state & (RQ_STOP | RQ_PRECLEANUP),
-					to/100);
+					to);
 
 		/*
 		 * iterate & processing through the list. for each cld, process
@@ -1835,6 +1827,36 @@ static int mgc_process_config(struct obd_device *obd, u32 len, void *buf)
 	.process_config	= mgc_process_config,
 };
 
+static int mgc_param_requeue_timeout_min_set(const char *val,
+					     const struct kernel_param *kp)
+{
+	int rc;
+	unsigned int num;
+
+	rc = kstrtouint(val, 0, &num);
+	if (rc < 0)
+		return rc;
+	if (num > 120)
+		return -EINVAL;
+
+	mgc_requeue_timeout_min = num;
+
+	return 0;
+}
+
+static struct kernel_param_ops param_ops_requeue_timeout_min = {
+	.set = mgc_param_requeue_timeout_min_set,
+	.get = param_get_uint,
+};
+
+#define param_check_requeue_timeout_min(name, p) \
+		__param_check(name, p, unsigned int)
+
+unsigned int mgc_requeue_timeout_min = MGC_TIMEOUT_MIN_SECONDS;
+module_param_call(mgc_requeue_timeout_min, mgc_param_requeue_timeout_min_set,
+		  param_get_uint, &param_ops_requeue_timeout_min, 0644);
+MODULE_PARM_DESC(mgc_requeue_timeout_min, "Minimal requeue time to refresh logs");
+
 static int __init mgc_init(void)
 {
 	int rc;
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
