Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 97487C433EF
	for <lustre-devel@archiver.kernel.org>; Tue, 19 Apr 2022 00:31:10 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 023C842731D;
	Mon, 18 Apr 2022 17:31:10 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 9E8A6425525
 for <lustre-devel@lists.lustre.org>; Mon, 18 Apr 2022 17:31:07 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 2203210058CA;
 Mon, 18 Apr 2022 20:31:06 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 1B86DD6E76; Mon, 18 Apr 2022 20:31:06 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon, 18 Apr 2022 20:30:58 -0400
Message-Id: <1650328264-8763-2-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1650328264-8763-1-git-send-email-jsimmons@infradead.org>
References: <1650328264-8763-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 1/7] lustre: ptlrpc: unregister reply buffer
 on rq_err
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
 Alexander Zarochentsev <alexander.zarochentsev@hpe.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Alexander Zarochentsev <alexander.zarochentsev@hpe.com>

Unregister reply buffer on rq_err and prevent a late reply from
modifying request flags in INTERPRET state.

HPE-bug-id: LUS-10717
Fixes: b06c1d17e488 ("lustre: mgc: do not ignore target registration failure")
WC-bug-id: https://jira.whamcloud.com/browse/LU-15435
Lustre-commit: d8012811cc6ff9c7f ("LU-15435 ptlrpc: unregister reply buffer on rq_err")
Signed-off-by: Alexander Zarochentsev <alexander.zarochentsev@hpe.com>
Signed-off-by: Alexey Lyashkov <alexey.lyashkov@hpe.com>
Reviewed-on: https://review.whamcloud.com/46132
Reviewed-by: Alexander Boyko <alexander.boyko@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ptlrpc/client.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/fs/lustre/ptlrpc/client.c b/fs/lustre/ptlrpc/client.c
index ec0cd5f..685d6e2 100644
--- a/fs/lustre/ptlrpc/client.c
+++ b/fs/lustre/ptlrpc/client.c
@@ -1857,6 +1857,11 @@ int ptlrpc_check_set(const struct lu_env *env, struct ptlrpc_request_set *set)
 		}
 
 		if (req->rq_err) {
+			if (!ptlrpc_unregister_reply(req, 1)) {
+				ptlrpc_unregister_bulk(req, 1);
+				continue;
+			}
+
 			spin_lock(&req->rq_lock);
 			req->rq_replied = 0;
 			spin_unlock(&req->rq_lock);
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
