Return-Path: <SRS0=FD7t=JM=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DDDCFC433B4
	for <lustre-devel@archiver.kernel.org>; Thu, 15 Apr 2021 04:03:37 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 8FFCB60230
	for <lustre-devel@archiver.kernel.org>; Thu, 15 Apr 2021 04:03:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8FFCB60230
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 1EB0132F512;
	Wed, 14 Apr 2021 21:03:18 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 86AAC32F62E
 for <lustre-devel@lists.lustre.org>; Wed, 14 Apr 2021 21:02:55 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 9D70A100F35F;
 Thu, 15 Apr 2021 00:02:45 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 9C69A91884; Thu, 15 Apr 2021 00:02:45 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Thu, 15 Apr 2021 00:02:22 -0400
Message-Id: <1618459361-17909-31-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1618459361-17909-1-git-send-email-jsimmons@infradead.org>
References: <1618459361-17909-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 30/49] lustre: ptlrpc: mark some functions as
 static
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

The functions
 ptlrpc_start_threads,
 ptlrpc_start_thread,

are only used in the same file that defines them, so mark them as
'static' and remove the declarations from include files.

WC-bug-id: https://jira.whamcloud.com/browse/LU-8837
Lustre-commit: f77e53d3656504c ("LU-8837 ptlrpc: mark some functions as static")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/41947
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Aurelien Degremont <degremoa@amazon.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_net.h     | 1 -
 fs/lustre/ptlrpc/ptlrpc_internal.h | 1 -
 fs/lustre/ptlrpc/service.c         | 6 ++++--
 3 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/fs/lustre/include/lustre_net.h b/fs/lustre/include/lustre_net.h
index a9aa363..2b98468 100644
--- a/fs/lustre/include/lustre_net.h
+++ b/fs/lustre/include/lustre_net.h
@@ -2009,7 +2009,6 @@ struct ptlrpc_service *ptlrpc_register_service(struct ptlrpc_service_conf *conf,
 					       struct kset *parent,
 					       struct dentry *debugfs_entry);
 
-int ptlrpc_start_threads(struct ptlrpc_service *svc);
 int ptlrpc_unregister_service(struct ptlrpc_service *service);
 
 int ptlrpc_hr_init(void);
diff --git a/fs/lustre/ptlrpc/ptlrpc_internal.h b/fs/lustre/ptlrpc/ptlrpc_internal.h
index bb4759ce..248f9cb 100644
--- a/fs/lustre/ptlrpc/ptlrpc_internal.h
+++ b/fs/lustre/ptlrpc/ptlrpc_internal.h
@@ -55,7 +55,6 @@
 extern lnet_handler_t ptlrpc_handler;
 extern struct percpu_ref ptlrpc_pending;
 
-int ptlrpc_start_thread(struct ptlrpc_service_part *svcpt, int wait);
 /* ptlrpcd.c */
 int ptlrpcd_start(struct ptlrpcd_ctl *pc);
 
diff --git a/fs/lustre/ptlrpc/service.c b/fs/lustre/ptlrpc/service.c
index 427215c..070eecc 100644
--- a/fs/lustre/ptlrpc/service.c
+++ b/fs/lustre/ptlrpc/service.c
@@ -67,6 +67,8 @@
 static int ptlrpc_server_post_idle_rqbds(struct ptlrpc_service_part *svcpt);
 static void ptlrpc_server_hpreq_fini(struct ptlrpc_request *req);
 static void ptlrpc_at_remove_timed(struct ptlrpc_request *req);
+static int ptlrpc_start_threads(struct ptlrpc_service *svc);
+static int ptlrpc_start_thread(struct ptlrpc_service_part *svcpt, int wait);
 
 /** Holds a list of all PTLRPC services */
 LIST_HEAD(ptlrpc_all_services);
@@ -2566,7 +2568,7 @@ static void ptlrpc_stop_all_threads(struct ptlrpc_service *svc)
 	}
 }
 
-int ptlrpc_start_threads(struct ptlrpc_service *svc)
+static int ptlrpc_start_threads(struct ptlrpc_service *svc)
 {
 	int rc = 0;
 	int i;
@@ -2596,7 +2598,7 @@ int ptlrpc_start_threads(struct ptlrpc_service *svc)
 	return rc;
 }
 
-int ptlrpc_start_thread(struct ptlrpc_service_part *svcpt, int wait)
+static int ptlrpc_start_thread(struct ptlrpc_service_part *svcpt, int wait)
 {
 	struct ptlrpc_thread *thread;
 	struct ptlrpc_service *svc;
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
