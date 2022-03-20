Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id EA0EFC433FE
	for <lustre-devel@archiver.kernel.org>; Sun, 20 Mar 2022 13:32:14 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 13BAC21F9A7;
	Sun, 20 Mar 2022 06:31:47 -0700 (PDT)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 2BF3721CAB7
 for <lustre-devel@lists.lustre.org>; Sun, 20 Mar 2022 06:31:12 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 0EBD9EDC;
 Sun, 20 Mar 2022 09:31:08 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 08ADED5A47; Sun, 20 Mar 2022 09:31:08 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 20 Mar 2022 09:30:24 -0400
Message-Id: <1647783064-20688-11-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1647783064-20688-1-git-send-email-jsimmons@infradead.org>
References: <1647783064-20688-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 10/50] lustre: fld: repeat rpc in
 fld_client_rpc after EAGAIN
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
Cc: Vladimir Saveliev <vlaidimir.saveliev@hpe.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Vladimir Saveliev <vlaidimir.saveliev@hpe.com>

Timeout-ed rpc sent by fld_client_rpc() may lead to client operation
failure.

Have fld_client_rpc() to repeat rpc in case of EAGAIN after a while.

Typo in fld_client_rpc() in failure simulation is fixed.

HPE-bug-id: LUS-8652
WC-bug-id: https://jira.whamcloud.com/browse/LU-13468
Lustre-commit: b1acf734f31c13d29 ("LU-13468 fld: repeat rpc in fld_client_rpc after EAGAIN")
Signed-off-by: Vladimir Saveliev <vlaidimir.saveliev@hpe.com>
Reviewed-on: https://review.whamcloud.com/38302
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Andriy Skulysh <andriy.skulysh@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/fld/fld_request.c | 20 ++++++++++++++------
 1 file changed, 14 insertions(+), 6 deletions(-)

diff --git a/fs/lustre/fld/fld_request.c b/fs/lustre/fld/fld_request.c
index 7260a14..4180bcf 100644
--- a/fs/lustre/fld/fld_request.c
+++ b/fs/lustre/fld/fld_request.c
@@ -39,7 +39,8 @@
 #define DEBUG_SUBSYSTEM S_FLD
 
 #include <linux/module.h>
-#include <asm/div64.h>
+#include <linux/math64.h>
+#include <linux/delay.h>
 
 #include <obd.h>
 #include <obd_class.h>
@@ -314,6 +315,7 @@ int fld_client_rpc(struct obd_export *exp,
 	LASSERT(exp);
 
 	imp = class_exp2cliimp(exp);
+again:
 	switch (fld_op) {
 	case FLD_QUERY:
 		req = ptlrpc_request_alloc_pack(imp, &RQF_FLD_QUERY,
@@ -361,7 +363,7 @@ int fld_client_rpc(struct obd_export *exp,
 	req->rq_reply_portal = MDC_REPLY_PORTAL;
 	ptlrpc_at_set_req_timeout(req);
 
-	if (OBD_FAIL_CHECK(OBD_FAIL_FLD_QUERY_REQ && req->rq_no_delay)) {
+	if (OBD_FAIL_CHECK(OBD_FAIL_FLD_QUERY_REQ) && req->rq_no_delay) {
 		/* the same error returned by ptlrpc_import_delay_req */
 		rc = -EAGAIN;
 		req->rq_status = rc;
@@ -373,12 +375,18 @@ int fld_client_rpc(struct obd_export *exp,
 
 	if (rc != 0) {
 		if (imp->imp_state != LUSTRE_IMP_CLOSED && !imp->imp_deactive) {
-			/*
-			 * Since LWP is not replayable, so notify the caller
-			 * to retry if needed after a while.
-			 */
+			/* LWP is not replayable, retry after a while. */
 			rc = -EAGAIN;
 		}
+		if (rc == -EAGAIN) {
+			ptlrpc_req_finished(req);
+			if (msleep_interruptible(2 * MSEC_PER_SEC)) {
+				rc = -EINTR;
+				goto out_req;
+			}
+			rc = 0;
+			goto again;
+		}
 		goto out_req;
 	}
 
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
