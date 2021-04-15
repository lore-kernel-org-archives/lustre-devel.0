Return-Path: <SRS0=FD7t=JM=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B050EC433ED
	for <lustre-devel@archiver.kernel.org>; Thu, 15 Apr 2021 04:04:04 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 7202360230
	for <lustre-devel@archiver.kernel.org>; Thu, 15 Apr 2021 04:04:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7202360230
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 2873030A303;
	Wed, 14 Apr 2021 21:03:32 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 37CE432F545
 for <lustre-devel@lists.lustre.org>; Wed, 14 Apr 2021 21:02:53 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 83FCB100F357;
 Thu, 15 Apr 2021 00:02:45 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 8327591884; Thu, 15 Apr 2021 00:02:45 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Thu, 15 Apr 2021 00:02:14 -0400
Message-Id: <1618459361-17909-23-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1618459361-17909-1-git-send-email-jsimmons@infradead.org>
References: <1618459361-17909-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 22/49] lnet: libcfs: restore
 LNET_DUMP_ON_PANIC functionality.
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

The functionality enabled by CONFIG_LNET_DUMP_ON_PANIC was never
implemented for the Linux client.

Restore this functionality.

While we are there, add conditional-compliation for other code that is
only needed when this is enabled.

WC-bug-id: https://jira.whamcloud.com/browse/LU-14427
Lustre-commit: f9b75c5fb4d4e397 ("LU-14427 libcfs: restore LNET_DUMP_ON_PANIC functionality.")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/41488
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/Kconfig            | 9 +++++++++
 net/lnet/libcfs/debug.c     | 9 +++++++++
 net/lnet/libcfs/tracefile.c | 2 ++
 3 files changed, 20 insertions(+)

diff --git a/net/lnet/Kconfig b/net/lnet/Kconfig
index 6062a82..b5ee5fa 100644
--- a/net/lnet/Kconfig
+++ b/net/lnet/Kconfig
@@ -8,6 +8,15 @@ config LNET
 	  case of Lustre routers only the LNet layer is required. Lately other
 	  projects are also looking into using LNet as their networking API as well.
 
+config LNET_DUMP_ON_PANIC
+	bool "LNet dump logs on panic"
+	depends on LNET
+	help
+	  Special funcitonality to enable collecting extra logs when LNet panics.
+	  Normally only used by developers for debugging purposes.
+
+	  If unsure, say N.
+
 config LNET_SELFTEST
 	tristate "Lustre networking self testing"
 	depends on LNET
diff --git a/net/lnet/libcfs/debug.c b/net/lnet/libcfs/debug.c
index e68dd91..e519fdb 100644
--- a/net/lnet/libcfs/debug.c
+++ b/net/lnet/libcfs/debug.c
@@ -503,6 +503,15 @@ static int panic_notifier(struct notifier_block *self, unsigned long unused1,
 	libcfs_panic_in_progress = 1;
 	mb();
 
+#ifdef CONFIG_LNET_DUMP_ON_PANIC
+	/* This is currently disabled because it spews far too much to the
+	 * console on the rare cases it is ever triggered.
+	 */
+	if (in_interrupt())
+		cfs_trace_debug_print();
+	else
+		libcfs_debug_dumplog_internal((void *)(long)current->pid);
+#endif
 	return 0;
 }
 
diff --git a/net/lnet/libcfs/tracefile.c b/net/lnet/libcfs/tracefile.c
index 4e1900d..32bab98 100644
--- a/net/lnet/libcfs/tracefile.c
+++ b/net/lnet/libcfs/tracefile.c
@@ -764,6 +764,7 @@ static void put_pages_on_daemon_list(struct page_collection *pc)
 	}
 }
 
+#ifdef CONFIG_LNET_DUMP_ON_PANIC
 void cfs_trace_debug_print(void)
 {
 	struct page_collection pc;
@@ -801,6 +802,7 @@ void cfs_trace_debug_print(void)
 		cfs_tage_free(tage);
 	}
 }
+#endif /* CONFIG_LNET_DUMP_ON_PANIC */
 
 int cfs_tracefile_dump_all_pages(char *filename)
 {
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
