From: SF Markus Elfring <elfring@users.sourceforge.net>
Date: Sun, 13 Dec 2015 14:52:48 +0100
Subject: [lustre-devel] [PATCH 1/7] staging: lustre: Delete unnecessary goto
 statements in six functions
In-Reply-To: <566D7733.1030102@users.sourceforge.net>
References: <566ABCD9.1060404@users.sourceforge.net>
	<566D7733.1030102@users.sourceforge.net>
Message-ID: <566D7830.9060000@users.sourceforge.net>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Sun, 13 Dec 2015 09:30:47 +0100

Six goto statements referred to a source code position directly behind them.
Thus omit such unnecessary jumps.

This issue was detected by using the Coccinelle software.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/staging/lustre/lustre/llite/namei.c     | 1 -
 drivers/staging/lustre/lustre/mdc/mdc_request.c | 7 -------
 2 files changed, 8 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/namei.c b/drivers/staging/lustre/lustre/llite/namei.c
index 64db5e8..2113dd4 100644
--- a/drivers/staging/lustre/lustre/llite/namei.c
+++ b/drivers/staging/lustre/lustre/llite/namei.c
@@ -554,7 +554,6 @@ static struct dentry *ll_lookup_it(struct inode *parent, struct dentry *dentry,
 		retval = NULL;
 	else
 		retval = dentry;
-	goto out;
  out:
 	if (req)
 		ptlrpc_req_finished(req);
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_request.c b/drivers/staging/lustre/lustre/mdc/mdc_request.c
index 294c050..920b1e9 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_request.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_request.c
@@ -1181,7 +1181,6 @@ static int mdc_ioc_hsm_progress(struct obd_export *exp,
 	ptlrpc_request_set_replen(req);
 
 	rc = mdc_queue_wait(req);
-	goto out;
 out:
 	ptlrpc_req_finished(req);
 	return rc;
@@ -1216,7 +1215,6 @@ static int mdc_ioc_hsm_ct_register(struct obd_import *imp, __u32 archives)
 	ptlrpc_request_set_replen(req);
 
 	rc = mdc_queue_wait(req);
-	goto out;
 out:
 	ptlrpc_req_finished(req);
 	return rc;
@@ -1282,7 +1280,6 @@ static int mdc_ioc_hsm_ct_unregister(struct obd_import *imp)
 	ptlrpc_request_set_replen(req);
 
 	rc = mdc_queue_wait(req);
-	goto out;
 out:
 	ptlrpc_req_finished(req);
 	return rc;
@@ -1362,8 +1359,6 @@ static int mdc_ioc_hsm_state_set(struct obd_export *exp,
 	ptlrpc_request_set_replen(req);
 
 	rc = mdc_queue_wait(req);
-	goto out;
-
 out:
 	ptlrpc_req_finished(req);
 	return rc;
@@ -1427,8 +1422,6 @@ static int mdc_ioc_hsm_request(struct obd_export *exp,
 	ptlrpc_request_set_replen(req);
 
 	rc = mdc_queue_wait(req);
-	goto out;
-
 out:
 	ptlrpc_req_finished(req);
 	return rc;
-- 
2.6.3
