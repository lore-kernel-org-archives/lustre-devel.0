Return-Path: <SRS0=Xi2l=P3=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A54A3C433EF
	for <lustre-devel@archiver.kernel.org>; Mon,  8 Nov 2021 15:08:25 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 6A43A61027
	for <lustre-devel@archiver.kernel.org>; Mon,  8 Nov 2021 15:08:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.1 mail.kernel.org 6A43A61027
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 07C3C21F34B;
	Mon,  8 Nov 2021 07:08:14 -0800 (PST)
Received: from smtp3.ccs.ornl.gov (SMTP3.CCS.ORNL.GOV [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 93BFF21C967
 for <lustre-devel@lists.lustre.org>; Mon,  8 Nov 2021 07:07:49 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 1DC1C2226;
 Mon,  8 Nov 2021 10:07:46 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 19B0CE07E1; Mon,  8 Nov 2021 10:07:46 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon,  8 Nov 2021 10:07:35 -0500
Message-Id: <1636384063-13838-8-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1636384063-13838-1-git-send-email-jsimmons@infradead.org>
References: <1636384063-13838-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 07/15] lustre: ptlrpc: recalc timer on
 EINPROGRESS reply
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
Cc: Alexander Zarochentsev <alexander.zarochentsev@hpe.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Alexander Zarochentsev <alexander.zarochentsev@hpe.com>

ptlrpcd doesn't recalculate wait queue timer after
getting -EINPROGRESS reply. It may delay request resend
till its timing out.

HPE-bug-id: LUS-10366
WC-bug-id: https://jira.whamcloud.com/browse/LU-15115
Lustre-commit: 9a5bace55a5ddb8a9 ("LU-15115 ptlrpc: recalc timer on EINPROGRESS reply")
Signed-off-by: Alexander Zarochentsev <alexander.zarochentsev@hpe.com>
Reviewed-on: https://review.whamcloud.com/45266
Reviewed-by: Andriy Skulysh <andriy.skulysh@hpe.com>
Reviewed-by: Alexander Boyko <alexander.boyko@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ptlrpc/client.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/fs/lustre/ptlrpc/client.c b/fs/lustre/ptlrpc/client.c
index e800000..dedb5db 100644
--- a/fs/lustre/ptlrpc/client.c
+++ b/fs/lustre/ptlrpc/client.c
@@ -2047,8 +2047,10 @@ int ptlrpc_check_set(const struct lu_env *env, struct ptlrpc_request_set *set)
 				continue;
 
 			req->rq_status = after_reply(req);
-			if (req->rq_resend)
+			if (req->rq_resend) {
+				force_timer_recalc = 1;
 				continue;
+			}
 
 			/*
 			 * If there is no bulk associated with this request,
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
