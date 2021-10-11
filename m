Return-Path: <SRS0=0agL=O7=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9CBBAC433EF
	for <lustre-devel@archiver.kernel.org>; Mon, 11 Oct 2021 17:41:13 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 5147460E78
	for <lustre-devel@archiver.kernel.org>; Mon, 11 Oct 2021 17:41:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.1 mail.kernel.org 5147460E78
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 6AEE8380DCE;
	Mon, 11 Oct 2021 10:41:04 -0700 (PDT)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 9389821FDCE
 for <lustre-devel@lists.lustre.org>; Mon, 11 Oct 2021 10:40:56 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id BEF99277;
 Mon, 11 Oct 2021 13:40:51 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id BB5FDD5A42; Mon, 11 Oct 2021 13:40:51 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon, 11 Oct 2021 13:40:40 -0400
Message-Id: <1633974049-26490-12-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1633974049-26490-1-git-send-email-jsimmons@infradead.org>
References: <1633974049-26490-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 11/20] lustre: ptlrpc: handle reply and
 resend reorder
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
Cc: Alexey Lyashkov <alexey.lyashkov@hpe.com>,
 Alexander Boyko <alexander.boyko@hpe.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Alexander Boyko <alexander.boyko@hpe.com>

ptlrpc can't detect a bulk transfer timeout
if rpc and bulk are reordered on router.
We should fail a bulk for situations where bulk is not
completed (after bulk timeout LNET_EVENT_UNLINK is set).

HPE-bug-id: LUS-7445, LUS-7569
WC-bug-id: https://jira.whamcloud.com/browse/LU-12567
Lustre-commit: f7f31f8f969f410cc ("LU-12567 ptlrpc: handle reply and resend reorder")
Signed-off-by: Alexander Boyko <alexander.boyko@hpe.com>
Signed-off-by: Alexey Lyashkov <alexey.lyashkov@hpe.com>
Reviewed-on: https://review.whamcloud.com/35571
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ptlrpc/client.c | 5 ++++-
 fs/lustre/ptlrpc/events.c | 3 +--
 2 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/fs/lustre/ptlrpc/client.c b/fs/lustre/ptlrpc/client.c
index 83d269c..e800000 100644
--- a/fs/lustre/ptlrpc/client.c
+++ b/fs/lustre/ptlrpc/client.c
@@ -2075,7 +2075,10 @@ int ptlrpc_check_set(const struct lu_env *env, struct ptlrpc_request_set *set)
 			 * was good after getting the REPLY for her GET or
 			 * the ACK for her PUT.
 			 */
-			DEBUG_REQ(D_ERROR, req, "bulk transfer failed");
+			DEBUG_REQ(D_ERROR, req, "bulk transfer failed %d/%d/%d",
+				  req->rq_status,
+				  req->rq_bulk->bd_nob,
+				  req->rq_bulk->bd_nob_transferred);
 			req->rq_status = -EIO;
 		}
 
diff --git a/fs/lustre/ptlrpc/events.c b/fs/lustre/ptlrpc/events.c
index c81181d..559d811 100644
--- a/fs/lustre/ptlrpc/events.c
+++ b/fs/lustre/ptlrpc/events.c
@@ -219,10 +219,9 @@ void client_bulk_callback(struct lnet_event *ev)
 		spin_lock(&req->rq_lock);
 		req->rq_net_err = 1;
 		spin_unlock(&req->rq_lock);
+		desc->bd_failure = 1;
 	}
 
-	if (ev->status != 0)
-		desc->bd_failure = 1;
 
 	/* NB don't unlock till after wakeup; desc can disappear under us
 	 * otherwise
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
