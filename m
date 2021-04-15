Return-Path: <SRS0=FD7t=JM=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 56D7CC433B4
	for <lustre-devel@archiver.kernel.org>; Thu, 15 Apr 2021 04:04:13 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 19D20610CB
	for <lustre-devel@archiver.kernel.org>; Thu, 15 Apr 2021 04:04:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 19D20610CB
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id CBE3C21CA55;
	Wed, 14 Apr 2021 21:03:35 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 7257D32F583
 for <lustre-devel@lists.lustre.org>; Wed, 14 Apr 2021 21:02:53 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 893C1100F358;
 Thu, 15 Apr 2021 00:02:45 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 8665591883; Thu, 15 Apr 2021 00:02:45 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Thu, 15 Apr 2021 00:02:15 -0400
Message-Id: <1618459361-17909-24-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1618459361-17909-1-git-send-email-jsimmons@infradead.org>
References: <1618459361-17909-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 23/49] lustre: ptlrpc: fix ASSERTION on
 scp_rqbd_posted
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
Cc: Yang Sheng <ys@whamcloud.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Yang Sheng <ys@whamcloud.com>

The request may be referenced by other target even the threads
of service were stopped. It caused by some portal shared among
different services. Just wait the request to be released as a
workaround.

LustreError: (service.c::ptlrpc_service_purge_all())
    ASSERTION( list_empty(&svcpt->scp_rqbd_posted) ) failed:
LustreError: (service.c::ptlrpc_service_purge_all()) LBUG
Pid: 21, comm: umount 3.10.0 #1 SMP
Call Trace:
  [<a01c47dc>] libcfs_call_trace+0x8c/0xc0 [libcfs]
  [<a01c488c>] lbug_with_loc+0x4c/0xa0 [libcfs]
  [<a0b534dd>] ptlrpc_unregister_service+0xced/0xd90 [ptlrpc]
  [<a005e122>] ost_cleanup+0x82/0x1b0 [ost]
  [<a08e0bfa>] class_free_dev+0x1ca/0x630 [obdclass]
  [<a08e1240>] class_export_put+0x1e0/0x2b0 [obdclass]
  [<a08e2cc5>] class_unlink_export+0x135/0x170 [obdclass]
  [<a08f8030>] class_decref+0x80/0x160 [obdclass]
  [<a08f8481>] class_detach+0x1b1/0x2e0 [obdclass]
  [<a08fef21>] class_process_config+0x1a91/0x2820 [obdclass]
  [<a08ffe90>] class_manual_cleanup+0x1e0/0x6d0 [obdclass]
  [<a092a115>] server_stop_servers+0xd5/0x160 [obdclass]
  [<a092f6c6>] server_put_super+0x126/0xca0 [obdclass]
  [<8121068a>] generic_shutdown_super+0x6a/0xf0
  [<81210a62>] kill_anon_super+0x12/0x20
  [<a09027e2>] lustre_kill_super+0x32/0x50 [obdclass]
  [<81210e59>] deactivate_locked_super+0x49/0x60
  [<812115a6>] deactivate_super+0x46/0x60
  [<8123019f>] cleanup_mnt+0x3f/0x80
  [<81230232>] __cleanup_mnt+0x12/0x20
  [<810ab085>] task_work_run+0xb5/0xf0
  [<8102ac12>] do_notify_resume+0x92/0xb0
  [<81783c83>] int_signal+0x12/0x17
   Kernel panic - not syncing: LBUG

WC-bug-id: https://jira.whamcloud.com/browse/LU-11289
Lustre-commit: b635a0435d13d843 ("LU-11289 ptlrpc: fix ASSERTION on scp_rqbd_posted")
Signed-off-by: Yang Sheng <ys@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/41936
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ptlrpc/service.c | 18 +++++++++++++++++-
 1 file changed, 17 insertions(+), 1 deletion(-)

diff --git a/fs/lustre/ptlrpc/service.c b/fs/lustre/ptlrpc/service.c
index f3f94d4..427215c 100644
--- a/fs/lustre/ptlrpc/service.c
+++ b/fs/lustre/ptlrpc/service.c
@@ -2922,7 +2922,23 @@ static void ptlrpc_wait_replies(struct ptlrpc_service_part *svcpt)
 			ptlrpc_server_finish_active_request(svcpt, req);
 		}
 
-		LASSERT(list_empty(&svcpt->scp_rqbd_posted));
+		/*
+		 * The portal may be shared by several services (eg:OUT_PORTAL).
+		 * So the request could be referenced by other target. So we
+		 * have to wait the ptlrpc_server_drop_request invoked.
+		 *
+		 * TODO: move the req_buffer as global rather than per service.
+		 */
+		spin_lock(&svcpt->scp_lock);
+		while (!list_empty(&svcpt->scp_rqbd_posted)) {
+			spin_unlock(&svcpt->scp_lock);
+			wait_event_idle_timeout(svcpt->scp_waitq,
+				list_empty(&svcpt->scp_rqbd_posted),
+				HZ);
+			spin_lock(&svcpt->scp_lock);
+		}
+		spin_unlock(&svcpt->scp_lock);
+
 		LASSERT(svcpt->scp_nreqs_incoming == 0);
 		LASSERT(svcpt->scp_nreqs_active == 0);
 		/*
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
