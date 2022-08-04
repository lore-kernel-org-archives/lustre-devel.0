Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 7B8A3C19F29
	for <lustre-devel@archiver.kernel.org>; Thu,  4 Aug 2022 01:39:45 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4Lyrxs07DLz23Jv;
	Wed,  3 Aug 2022 18:39:44 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4LyrwY3PkBz23JG
 for <lustre-devel@lists.lustre.org>; Wed,  3 Aug 2022 18:38:37 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id CFE62100B006;
 Wed,  3 Aug 2022 21:38:23 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id CE4ED80795; Wed,  3 Aug 2022 21:38:23 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Wed,  3 Aug 2022 21:38:01 -0400
Message-Id: <1659577097-19253-17-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1659577097-19253-1-git-send-email-jsimmons@infradead.org>
References: <1659577097-19253-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 16/32] lustre: sec: handle read-only flag
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

From: Sebastien Buisson <sbuisson@ddn.com>

Add a new 'readonly_mount' property to nodemaps on the server
side. When this property is set, we return -EROFS from server
side if the client is not mounting read-only. So the client
will have to specify the read-only mount option to be allowed
to mount.

WC-bug-id: https://jira.whamcloud.com/browse/LU-15451
Lustre-commit: e7ce67de92dea6870 ("LU-15451 sec: read-only nodemap flag")
Signed-off-by: Sebastien Buisson <sbuisson@ddn.com>
Reviewed-on: https://review.whamcloud.com/46149
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ptlrpc/import.c | 4 ++--
 fs/lustre/ptlrpc/niobuf.c | 3 ++-
 2 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/fs/lustre/ptlrpc/import.c b/fs/lustre/ptlrpc/import.c
index a5fdb8a8..697b3c3 100644
--- a/fs/lustre/ptlrpc/import.c
+++ b/fs/lustre/ptlrpc/import.c
@@ -1306,10 +1306,10 @@ static int ptlrpc_connect_interpret(const struct lu_env *env,
 		time64_t next_connect;
 
 		import_set_state_nolock(imp, LUSTRE_IMP_DISCON);
-		if (rc == -EACCES) {
+		if (rc == -EACCES || rc == -EROFS) {
 			/*
 			 * Give up trying to reconnect
-			 * EACCES means client has no permission for connection
+			 * EROFS means client must mount read-only
 			 */
 			imp->imp_obd->obd_no_recov = 1;
 			ptlrpc_deactivate_import_nolock(imp);
diff --git a/fs/lustre/ptlrpc/niobuf.c b/fs/lustre/ptlrpc/niobuf.c
index 94a0329..be1811a 100644
--- a/fs/lustre/ptlrpc/niobuf.c
+++ b/fs/lustre/ptlrpc/niobuf.c
@@ -472,7 +472,8 @@ int ptlrpc_send_error(struct ptlrpc_request *req, int may_be_difficult)
 
 	if (req->rq_status != -ENOSPC && req->rq_status != -EACCES &&
 	    req->rq_status != -EPERM && req->rq_status != -ENOENT &&
-	    req->rq_status != -EINPROGRESS && req->rq_status != -EDQUOT)
+	    req->rq_status != -EINPROGRESS && req->rq_status != -EDQUOT &&
+	    req->rq_status != -EROFS)
 		req->rq_type = PTL_RPC_MSG_ERR;
 
 	rc = ptlrpc_send_reply(req, may_be_difficult);
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
