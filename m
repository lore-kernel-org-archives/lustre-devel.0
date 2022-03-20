Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 21899C433F5
	for <lustre-devel@archiver.kernel.org>; Sun, 20 Mar 2022 13:33:31 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 51AE021FB10;
	Sun, 20 Mar 2022 06:32:25 -0700 (PDT)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 65CBA21CAEF
 for <lustre-devel@lists.lustre.org>; Sun, 20 Mar 2022 06:31:12 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 11F92EDD;
 Sun, 20 Mar 2022 09:31:08 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 0C504D6A26; Sun, 20 Mar 2022 09:31:08 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 20 Mar 2022 09:30:25 -0400
Message-Id: <1647783064-20688-12-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1647783064-20688-1-git-send-email-jsimmons@infradead.org>
References: <1647783064-20688-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 11/50] lustre: fld: don't obtain a slot for
 fld request
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
Cc: Andriy Skulysh <c17819@cray.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Andriy Skulysh <c17819@cray.com>

fld_client_rpc() is called with ldlm_lock held.
Thus it can cause deadlock on obtainig request slot:

Request slot can be ommited for fld request as they
are sent to separate FLD_REQUEST_PORTAL portal.

HPE-bug-id: LUS-10576
WC-bug-id: https://jira.whamcloud.com/browse/LU-15401
Lustre-commit: be5ed6b393e0268ff ("LU-15401 fld: don't obtain a slot for fld request")
Signed-off-by: Andriy Skulysh <c17819@cray.com>
Reviewed-by: Vitaly Fertman <c17818@cray.com>
Reviewed-by: Andrew Perepechko <c17827@cray.com>
Reviewed-on: https://review.whamcloud.com/45956
Reviewed-by: Andrew Perepechko <andrew.perepechko@hpe.com>
Reviewed-by: Vitaly Fertman <vitaly.fertman@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/fld/fld_request.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/fs/lustre/fld/fld_request.c b/fs/lustre/fld/fld_request.c
index 4180bcf..b365dc2 100644
--- a/fs/lustre/fld/fld_request.c
+++ b/fs/lustre/fld/fld_request.c
@@ -368,9 +368,7 @@ int fld_client_rpc(struct obd_export *exp,
 		rc = -EAGAIN;
 		req->rq_status = rc;
 	} else {
-		obd_get_request_slot(&exp->exp_obd->u.cli);
 		rc = ptlrpc_queue_wait(req);
-		obd_put_request_slot(&exp->exp_obd->u.cli);
 	}
 
 	if (rc != 0) {
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
