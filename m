Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id AEA81C05027
	for <lustre-devel@archiver.kernel.org>; Mon, 23 Jan 2023 23:29:21 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4P15QK614Vz22V8;
	Mon, 23 Jan 2023 15:09:13 -0800 (PST)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4P15MH1FR9z1yDm
 for <lustre-devel@lists.lustre.org>; Mon, 23 Jan 2023 15:06:35 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 74F569F6;
 Mon, 23 Jan 2023 18:00:58 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 71B5758987; Mon, 23 Jan 2023 18:00:58 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon, 23 Jan 2023 18:00:36 -0500
Message-Id: <1674514855-15399-24-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1674514855-15399-1-git-send-email-jsimmons@infradead.org>
References: <1674514855-15399-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 23/42] lustre: ptlrpc: don't panic during
 reconnection
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
Cc: Alexander Boyko <alexander.boyko@hpe.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Alexander Boyko <alexander.boyko@hpe.com>

ptlrpc_send_rpc() could race with ptlrpc_connect_import_locked()
in the middle of assertion check and this leads to a wrong panic.
Assertion checks

(AT_OFF || imp->imp_state != LUSTRE_IMP_FULL ||

reconnect changes import state and flags
and second part

(imp->imp_msghdr_flags & MSGHDR_AT_SUPPORT) ||
!(imp->imp_connect_data.ocd_connect_flags & OBD_CONNECT_AT)))

MSGHDR_AT_SUPPORT is disabled during client reconnection.
It is not good to use locking at this hot part, so fix changes
assertion to a report.

HPE-bug-id: LUS-10985
WC-bug-id: https://jira.whamcloud.com/browse/LU-16297
Lustre-commit: df31c4c0b39b88459 ("LU-16297 ptlrpc: don't panic during reconnection")
Signed-off-by: Alexander Boyko <alexander.boyko@hpe.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/49029
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Alexander Zarochentsev <alexander.zarochentsev@hpe.com>
Reviewed-by: Mikhail Pershin <mpershin@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ptlrpc/niobuf.c | 19 +++++++++++++------
 1 file changed, 13 insertions(+), 6 deletions(-)

diff --git a/fs/lustre/ptlrpc/niobuf.c b/fs/lustre/ptlrpc/niobuf.c
index 670bfb0de02f..09f68157b883 100644
--- a/fs/lustre/ptlrpc/niobuf.c
+++ b/fs/lustre/ptlrpc/niobuf.c
@@ -579,13 +579,20 @@ int ptl_send_rpc(struct ptlrpc_request *request, int noreply)
 
 	/**
 	 * For enabled AT all request should have AT_SUPPORT in the
-	 * FULL import state when OBD_CONNECT_AT is set
+	 * FULL import state when OBD_CONNECT_AT is set.
+	 * This check has a race with ptlrpc_connect_import_locked()
+	 * with low chance, don't panic, only report.
 	 */
-	LASSERT(AT_OFF || imp->imp_state != LUSTRE_IMP_FULL ||
-		(imp->imp_msghdr_flags & MSGHDR_AT_SUPPORT) ||
-		!(imp->imp_connect_data.ocd_connect_flags &
-		OBD_CONNECT_AT));
-
+	if (!(AT_OFF || imp->imp_state != LUSTRE_IMP_FULL ||
+	    (imp->imp_msghdr_flags & MSGHDR_AT_SUPPORT) ||
+	    !(imp->imp_connect_data.ocd_connect_flags & OBD_CONNECT_AT))) {
+		DEBUG_REQ(D_HA, request,
+			  "Wrong state of import detected, AT=%d, imp=%d, msghdr=%d, conn=%d\n",
+			  AT_OFF, imp->imp_state != LUSTRE_IMP_FULL,
+			  (imp->imp_msghdr_flags & MSGHDR_AT_SUPPORT),
+			  !(imp->imp_connect_data.ocd_connect_flags &
+			    OBD_CONNECT_AT));
+	}
 	if (request->rq_resend)
 		lustre_msg_add_flags(request->rq_reqmsg, MSG_RESENT);
 
-- 
2.27.0

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
