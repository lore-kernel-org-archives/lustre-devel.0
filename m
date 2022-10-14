Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id B0EEAC4332F
	for <lustre-devel@archiver.kernel.org>; Fri, 14 Oct 2022 21:38:23 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4Mq0B60hZ5z1y60;
	Fri, 14 Oct 2022 14:38:22 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4Mq0B00BrWz1xJR
 for <lustre-devel@lists.lustre.org>; Fri, 14 Oct 2022 14:38:16 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id DF97D1006F1A;
 Fri, 14 Oct 2022 17:38:13 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id D7AA7DD53C; Fri, 14 Oct 2022 17:38:13 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Fri, 14 Oct 2022 17:37:52 -0400
Message-Id: <1665783491-13827-2-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1665783491-13827-1-git-send-email-jsimmons@infradead.org>
References: <1665783491-13827-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 01/20] lustre: ptlrpc: protect rq_repmsg in
 ptlrpc_req_drop_rs()
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
Cc: Lei Feng <flei@whamcloud.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Lei Feng <flei@whamcloud.com>

There is a race condition that: on server side, one thread sent
reply message and is deleting the reply message, another is
searching for existing request and print some debug information
in _debug_req() if there is a duplicated request. They both operate on
req->rq_repmsg but it is not protected in ptlrpc_req_drop_rs().
So we protected it with req->rq_early_free_lock.

WC-bug-id: https://jira.whamcloud.com/browse/LU-15986
Lustre-commit: aaef545cff2dd9584 ("LU-15986 ptlrpc: protect rq_repmsg in ptlrpc_req_drop_rs()")
Signed-off-by: Lei Feng <flei@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/47839
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Li Xi <lixi@ddn.com>
Reviewed-by: Qian Yingjin <qian@ddn.com>
Reviewed-by: Andrew Perepechko <andrew.perepechko@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_net.h | 9 ++++++++-
 fs/lustre/ptlrpc/service.c     | 1 +
 2 files changed, 9 insertions(+), 1 deletion(-)

diff --git a/fs/lustre/include/lustre_net.h b/fs/lustre/include/lustre_net.h
index f8d28619a6d7..1605fcc64fc4 100644
--- a/fs/lustre/include/lustre_net.h
+++ b/fs/lustre/include/lustre_net.h
@@ -2234,9 +2234,16 @@ static inline void ptlrpc_req_drop_rs(struct ptlrpc_request *req)
 {
 	if (!req->rq_reply_state)
 		return; /* shouldn't occur */
+
+	/* req_repmsg equals rq_reply_state->rs_msg,
+	 * so set it to NULL before rq_reply_state is possibly freed
+	 */
+	spin_lock(&req->rq_early_free_lock);
+	req->rq_repmsg = NULL;
+	spin_unlock(&req->rq_early_free_lock);
+
 	ptlrpc_rs_decref(req->rq_reply_state);
 	req->rq_reply_state = NULL;
-	req->rq_repmsg = NULL;
 }
 
 static inline u32 lustre_request_magic(struct ptlrpc_request *req)
diff --git a/fs/lustre/ptlrpc/service.c b/fs/lustre/ptlrpc/service.c
index 277fbdbc590a..59fe1f4aa18f 100644
--- a/fs/lustre/ptlrpc/service.c
+++ b/fs/lustre/ptlrpc/service.c
@@ -1136,6 +1136,7 @@ static int ptlrpc_at_send_early_reply(struct ptlrpc_request *req)
 	}
 
 	*reqcopy = *req;
+	spin_lock_init(&reqcopy->rq_early_free_lock);
 	reqcopy->rq_reply_state = NULL;
 	reqcopy->rq_rep_swab_mask = 0;
 	reqcopy->rq_pack_bulk = 0;
-- 
2.27.0

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
