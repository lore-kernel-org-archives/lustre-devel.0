Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 3E831C05027
	for <lustre-devel@archiver.kernel.org>; Mon, 23 Jan 2023 23:19:53 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4P15Mq71yXz226G;
	Mon, 23 Jan 2023 15:07:03 -0800 (PST)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4P15K25X4rz21B7
 for <lustre-devel@lists.lustre.org>; Mon, 23 Jan 2023 15:04:38 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 58ADD91F;
 Mon, 23 Jan 2023 18:00:58 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 5459C58994; Mon, 23 Jan 2023 18:00:58 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon, 23 Jan 2023 18:00:29 -0500
Message-Id: <1674514855-15399-17-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1674514855-15399-1-git-send-email-jsimmons@infradead.org>
References: <1674514855-15399-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 16/42] lnet: selftest: lst read-outside of
 allocation
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
Cc: Alexey Lyashkov <alexey.lyashkov@hpe.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Alexey Lyashkov <alexey.lyashkov@hpe.com>

lnet_selftest want a some parameters from userspace,
but it never sends. It caused a read of outside of allocation
like
  BUG: KASAN: slab-out-of-bounds in lstcon_testrpc_prep+0x19e7/0x1bb0
  Read of size 4 at addr ffff8888bbaa866c by task lt-lst/6371

WC-bug-id: https://jira.whamcloud.com/browse/LU-16157
Lustre-commit: 222fbed52e02122c7 ("LU-16157 lnet: lst read-outside of allocation")
Signed-off-by: Alexey Lyashkov <alexey.lyashkov@hpe.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/48547
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/selftest/conrpc.c | 22 ++++++++++++++++------
 1 file changed, 16 insertions(+), 6 deletions(-)

diff --git a/net/lnet/selftest/conrpc.c b/net/lnet/selftest/conrpc.c
index 8096c467041a..4f427dd85265 100644
--- a/net/lnet/selftest/conrpc.c
+++ b/net/lnet/selftest/conrpc.c
@@ -780,8 +780,13 @@ lstcon_pingrpc_prep(struct lst_test_ping_param *param, struct srpc_test_reqst *r
 {
 	struct test_ping_req *prq = &req->tsr_u.ping;
 
-	prq->png_size = param->png_size;
-	prq->png_flags = param->png_flags;
+	if (param) {
+		prq->png_size = param->png_size;
+		prq->png_flags = param->png_flags;
+	} else {
+		prq->png_size = 0;
+		prq->png_flags = 0;
+	}
 	/* TODO dest */
 	return 0;
 }
@@ -896,12 +901,17 @@ lstcon_testrpc_prep(struct lstcon_node *nd, int transop, unsigned int feats,
 	trq->tsr_stop_onerr = !!test->tes_stop_onerr;
 
 	switch (test->tes_type) {
-	case LST_TEST_PING:
+	case LST_TEST_PING: {
+		struct lst_test_ping_param *data = NULL;
+
 		trq->tsr_service = SRPC_SERVICE_PING;
-		rc = lstcon_pingrpc_prep((struct lst_test_ping_param *)
-					 &test->tes_param[0], trq);
-		break;
+		if (test->tes_paramlen)
+			data = ((struct lst_test_ping_param *)
+				&test->tes_param[0]);
 
+		rc = lstcon_pingrpc_prep(data, trq);
+		break;
+	}
 	case LST_TEST_BULK:
 		trq->tsr_service = SRPC_SERVICE_BRW;
 		if (!(feats & LST_FEAT_BULK_LEN)) {
-- 
2.27.0

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
