Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 8A079C36000
	for <lustre-devel@archiver.kernel.org>; Fri, 21 Mar 2025 13:45:42 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4ZK2ws4Bs1z1y20;
	Fri, 21 Mar 2025 06:14:53 -0700 (PDT)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4ZK2q70T2rz1yhy
 for <lustre-devel@lists.lustre.org>; Fri, 21 Mar 2025 06:09:55 -0700 (PDT)
Received: from star2.ccs.ornl.gov (ltm3-e204-208.ccs.ornl.gov [160.91.203.26])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id B0B2F893E88;
 Fri, 21 Mar 2025 09:07:14 -0400 (EDT)
Received: by star2.ccs.ornl.gov (Postfix, from userid 2004)
 id AE493106BE18; Fri, 21 Mar 2025 09:07:14 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Fri, 21 Mar 2025 09:07:09 -0400
Message-ID: <20250321130711.3257092-27-jsimmons@infradead.org>
X-Mailer: git-send-email 2.43.5
In-Reply-To: <20250321130711.3257092-1-jsimmons@infradead.org>
References: <20250321130711.3257092-1-jsimmons@infradead.org>
MIME-Version: 1.0
Subject: [lustre-devel] [PATCH 26/27] lustre: ptlrpc:
 OBD_FAIL_PTLRPC_DELAY_SEND_FAIL fixes
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
Cc: Chris Horn <chris.horn@hpe.com>, Alex Deiter <alex.deiter@gmail.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Chris Horn <chris.horn@hpe.com>

Modify test to ensure idle disconnect is enabled for all targets
except OST0000. This prevents an issue where an idle ping is sent to
another target instead of OST0000.

Re-work test to check the debug log for all relevant messages.

Added a debug statement to ptl_send_rpc(), and moved an existing one,
to faciliate debugging any future test failures.

Fixes: ecba969 ("lustre: ptlrpc: Track highest reply XID")
WC-bug-id: https://jira.whamcloud.com/browse/LU-16843
Lustre-commit: fdfdf5c05cf642940 ("LU-16483 tests: replay-single test_200 fixes")
Signed-off-by: Chris Horn <chris.horn@hpe.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/50891
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Alex Deiter <alex.deiter@gmail.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ptlrpc/niobuf.c | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/fs/lustre/ptlrpc/niobuf.c b/fs/lustre/ptlrpc/niobuf.c
index d426d3c678b7..e06857376019 100644
--- a/fs/lustre/ptlrpc/niobuf.c
+++ b/fs/lustre/ptlrpc/niobuf.c
@@ -726,12 +726,15 @@ int ptl_send_rpc(struct ptlrpc_request *request, int noreply)
 	request->rq_deadline = request->rq_sent + request->rq_timeout +
 			       ptlrpc_at_get_net_latency(request);
 
+	DEBUG_REQ(D_INFO, request, "send flags=%x",
+		  lustre_msg_get_flags(request->rq_reqmsg));
+
 	if (unlikely(opc == OBD_PING &&
-	    CFS_FAIL_TIMEOUT(OBD_FAIL_PTLRPC_DELAY_SEND_FAIL, cfs_fail_val)))
+	    CFS_FAIL_TIMEOUT(OBD_FAIL_PTLRPC_DELAY_SEND_FAIL, cfs_fail_val))) {
+		DEBUG_REQ(D_INFO, request, "Simulate delay send failure");
 		goto skip_send;
+	}
 
-	DEBUG_REQ(D_INFO, request, "send flags=%x",
-		  lustre_msg_get_flags(request->rq_reqmsg));
 	rc = ptl_send_buf(&request->rq_req_md_h,
 			  request->rq_reqbuf, request->rq_reqdata_len,
 			  LNET_NOACK_REQ, &request->rq_req_cbid,
-- 
2.39.3

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
