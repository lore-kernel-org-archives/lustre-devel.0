Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id DC120C433F5
	for <lustre-devel@archiver.kernel.org>; Sun, 28 Nov 2021 23:28:41 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id AA10C20111A;
	Sun, 28 Nov 2021 15:28:24 -0800 (PST)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 3AD19200F3F
 for <lustre-devel@lists.lustre.org>; Sun, 28 Nov 2021 15:28:02 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id AA438260;
 Sun, 28 Nov 2021 18:27:56 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id A8F67C1AC9; Sun, 28 Nov 2021 18:27:56 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 28 Nov 2021 18:27:47 -0500
Message-Id: <1638142074-5945-13-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1638142074-5945-1-git-send-email-jsimmons@infradead.org>
References: <1638142074-5945-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 12/19] lustre: ptlrpc: remove bogus LASSERT
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
Cc: Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Andreas Dilger <adilger@whamcloud.com>

In the error case, it isn't possible for rc to be both -ENOMEM and
0 at the same time, so remove the incorrect LASSERT(rc == 0) to
avoid crashing the system on an allocation failure.

Improve error messages to conform to code style.

Fixes: c8c95f49fd73 ("lnet: me: discard struct lnet_handle_me")
WC-bug-id: https://jira.whamcloud.com/browse/LU-12678
Lustre-commit: 49769c1eea52e067d ("LU-12678 ptlrpc: remove bogus LASSERT")
Signed-off-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/45421
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Chris Horn <chris.horn@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ptlrpc/niobuf.c | 11 ++++++-----
 1 file changed, 6 insertions(+), 5 deletions(-)

diff --git a/fs/lustre/ptlrpc/niobuf.c b/fs/lustre/ptlrpc/niobuf.c
index c5bbf5a..da04d4e 100644
--- a/fs/lustre/ptlrpc/niobuf.c
+++ b/fs/lustre/ptlrpc/niobuf.c
@@ -774,7 +774,7 @@ int ptlrpc_register_rqbd(struct ptlrpc_request_buffer_desc *rqbd)
 	struct lnet_md md;
 	struct lnet_me *me;
 
-	CDEBUG(D_NET, "LNetMEAttach: portal %d\n",
+	CDEBUG(D_NET, "%s: registering portal %d\n", service->srv_name,
 	       service->srv_req_portal);
 
 	if (OBD_FAIL_CHECK(OBD_FAIL_PTLRPC_RQBD))
@@ -789,8 +789,9 @@ int ptlrpc_register_rqbd(struct ptlrpc_request_buffer_desc *rqbd)
 			  rqbd->rqbd_svcpt->scp_cpt >= 0 ?
 			  LNET_INS_LOCAL : LNET_INS_AFTER);
 	if (IS_ERR(me)) {
-		CERROR("LNetMEAttach failed: %ld\n", PTR_ERR(me));
-		return -ENOMEM;
+		CERROR("%s: LNetMEAttach failed: rc = %ld\n",
+		       service->srv_name, PTR_ERR(me));
+		return PTR_ERR(me);
 	}
 
 	LASSERT(rqbd->rqbd_refcount == 0);
@@ -810,9 +811,9 @@ int ptlrpc_register_rqbd(struct ptlrpc_request_buffer_desc *rqbd)
 		return 0;
 	}
 
-	CERROR("ptlrpc: LNetMDAttach failed: rc = %d\n", rc);
+	CERROR("%s: LNetMDAttach failed: rc = %d\n", service->srv_name, rc);
 	LASSERT(rc == -ENOMEM);
 	rqbd->rqbd_refcount = 0;
 
-	return -ENOMEM;
+	return rc;
 }
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
