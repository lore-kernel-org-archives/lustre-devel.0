Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 5632BC77B70
	for <lustre-devel@archiver.kernel.org>; Sun,  9 Apr 2023 12:30:19 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4PvWMB3SWnz21JY;
	Sun,  9 Apr 2023 05:17:26 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4PvWJR0HG3z1yGG
 for <lustre-devel@lists.lustre.org>; Sun,  9 Apr 2023 05:15:02 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 0C964100827E;
 Sun,  9 Apr 2023 08:13:28 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 0B5C42B3; Sun,  9 Apr 2023 08:13:28 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun,  9 Apr 2023 08:12:56 -0400
Message-Id: <1681042400-15491-17-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1681042400-15491-1-git-send-email-jsimmons@infradead.org>
References: <1681042400-15491-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 16/40] lustre: ptlrpc: clarify AT error
 message
X-BeenThere: lustre-devel@lists.lustre.org
X-Mailman-Version: 2.1.39
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

From: Aurelien Degremont <degremoa@amazon.com>

Clarify the error message related to passed deadline
for AT early replies. It was indicating that the system
was CPU bound which is most of the time wrong, as the issue
is rather communication failure delaying RPC traffic.
This could be confusing to people which will look for
CPU resource consumption where the network traffic is
more at cause.

Also try to use less cryptic keywords which makes only
sense to the feature developer, and not to admins.

WC-bug-id: https://jira.whamcloud.com/browse/LU-930
Lustre-commit: 9ce04000fba07706c ("LU-930 ptlrpc: clarify AT error message")
Signed-off-by: Aurelien Degremont <degremoa@amazon.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/49548
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Yang Sheng <ys@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ptlrpc/service.c | 11 +++++------
 1 file changed, 5 insertions(+), 6 deletions(-)

diff --git a/fs/lustre/ptlrpc/service.c b/fs/lustre/ptlrpc/service.c
index aaf7529..bf76272 100644
--- a/fs/lustre/ptlrpc/service.c
+++ b/fs/lustre/ptlrpc/service.c
@@ -1303,12 +1303,11 @@ static void ptlrpc_at_check_timed(struct ptlrpc_service_part *svcpt)
 		 * We're already past request deadlines before we even get a
 		 * chance to send early replies
 		 */
-		LCONSOLE_WARN("%s: This server is not able to keep up with request traffic (cpu-bound).\n",
-			      svcpt->scp_service->srv_name);
-		CWARN("earlyQ=%d reqQ=%d recA=%d, svcEst=%d, delay=%lldms\n",
-		      counter, svcpt->scp_nreqs_incoming,
-		      svcpt->scp_nreqs_active,
-		      at_get(&svcpt->scp_at_estimate), delay_ms);
+		LCONSOLE_WARN("'%s' is processing requests too slowly, client may timeout. Late by %ds, missed %d early replies (reqs waiting=%d active=%d, at_estimate=%d, delay=%lldms)\n",
+			      svcpt->scp_service->srv_name, -first, counter,
+			      svcpt->scp_nreqs_incoming,
+			      svcpt->scp_nreqs_active,
+			      at_get(&svcpt->scp_at_estimate), delay_ms);
 	}
 
 	/*
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
