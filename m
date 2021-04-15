Return-Path: <SRS0=FD7t=JM=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.9 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,UNWANTED_LANGUAGE_BODY,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 50D20C43460
	for <lustre-devel@archiver.kernel.org>; Thu, 15 Apr 2021 04:02:53 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id E7636610CB
	for <lustre-devel@archiver.kernel.org>; Thu, 15 Apr 2021 04:02:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E7636610CB
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 029FE32F504;
	Wed, 14 Apr 2021 21:02:51 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id E1A5032F3FA
 for <lustre-devel@lists.lustre.org>; Wed, 14 Apr 2021 21:02:46 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 4DA23100F331;
 Thu, 15 Apr 2021 00:02:45 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 4249491884; Thu, 15 Apr 2021 00:02:45 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Thu, 15 Apr 2021 00:01:53 -0400
Message-Id: <1618459361-17909-2-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1618459361-17909-1-git-send-email-jsimmons@infradead.org>
References: <1618459361-17909-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 01/49] lnet: libcfs: Fix for unconfigured
 arch_stackwalk
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
Cc: Shaun Tancheff <shaun.tancheff@hpe.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Shaun Tancheff <shaun.tancheff@hpe.com>

On aarch64 CONFIG_ARCH_STACKWALK is not defined and
save_stack_trace_tsk() is not available.

HPE-bug-id: LUS-9518
WC-bug-id: https://jira.whamcloud.com/browse/LU-14099
Lustre-commit: 58ac9d3f1844701 ("LU-14099 build: Fix for unconfigured arch_stackwalk")
Signed-off-by: Shaun Tancheff <shaun.tancheff@hpe.com>
Reviewed-on: https://review.whamcloud.com/40503
Reviewed-by: Jian Yu <yujian@whamcloud.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/libcfs/debug.c | 28 ++++++++++++++++++----------
 1 file changed, 18 insertions(+), 10 deletions(-)

diff --git a/net/lnet/libcfs/debug.c b/net/lnet/libcfs/debug.c
index ba32a99..e68dd91 100644
--- a/net/lnet/libcfs/debug.c
+++ b/net/lnet/libcfs/debug.c
@@ -451,32 +451,40 @@ void __noreturn lbug_with_loc(struct libcfs_debug_msg_data *msgdata)
 EXPORT_SYMBOL(lbug_with_loc);
 
 #ifdef CONFIG_STACKTRACE
+
 #define MAX_ST_ENTRIES 100
 static DEFINE_SPINLOCK(st_lock);
 
 static void libcfs_call_trace(struct task_struct *tsk)
 {
 	static unsigned long entries[MAX_ST_ENTRIES];
+#ifdef CONFIG_ARCH_STACKWALK
 	unsigned int nr_entries;
 
+	spin_lock(&st_lock);
 	pr_info("Pid: %d, comm: %.20s %s %s\n", tsk->pid, tsk->comm,
 		init_utsname()->release, init_utsname()->version);
 	pr_info("Call Trace:\n");
-
-	spin_lock(&st_lock);
 	nr_entries = stack_trace_save_tsk(tsk, entries,
 					  MAX_ST_ENTRIES, 0);
-
 	stack_trace_print(entries, nr_entries, 0);
 	spin_unlock(&st_lock);
-}
 #else /* !CONFIG_STACKTRACE */
-static void libcfs_call_trace(struct task_struct *tsk)
-{
-	if (tsk == current)
-		dump_stack();
-	else
-		CWARN("can't show stack: kernel doesn't export show_task\n");
+	struct stack_trace trace;
+
+	trace.nr_entries = 0;
+	trace.max_entries = MAX_ST_ENTRIES;
+	trace.entries = entries;
+	trace.skip = 0;
+
+	spin_lock(&st_lock);
+	pr_info("Pid: %d, comm: %.20s %s %s\n", tsk->pid, tsk->comm,
+		init_utsname()->release, init_utsname()->version);
+	pr_info("Call Trace:\n");
+	save_stack_trace_tsk(tsk, &trace);
+	stack_trace_print(entries, nr_entries, 0);
+	spin_unlock(&st_lock);
+#endif
 }
 #endif /* !CONFIG_STACKTRACE */
 
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
