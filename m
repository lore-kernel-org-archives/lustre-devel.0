From: James Simmons <jsimmons@infradead.org>
Date: Tue, 12 Apr 2016 16:14:09 -0400
Subject: [lustre-devel] [PATCH v2 09/16] staging: lustre: ptlrpc: return a
	meaningful status from ptlrpcd_init()
In-Reply-To: <1460492056-31792-1-git-send-email-jsimmons@infradead.org>
References: <1460492056-31792-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1460492056-31792-10-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Swapnil Pimpale <spimpale@ddn.com>, James Simmons <jsimmons@infradead.org>

From: Swapnil Pimpale <spimpale@ddn.com>

This patch has the following:
1) Fix for the return value from ptlrpcd_init(). It will now return a
   correct status instead of returning zero always.
2) ptlrpcd_addref() should not increment ptlrpcd_users on error.
3) Added code in a mdc_setup() and mgc_setup() to test the return
   value of ptlrpcd_addref() and return on error.

Signed-off-by: Swapnil Pimpale <spimpale@ddn.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-3808
Reviewed-on: http://review.whamcloud.com/7522
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/mdc/mdc_request.c |    9 ++++++---
 drivers/staging/lustre/lustre/mgc/mgc_request.c |    5 ++++-
 drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c  |    5 ++++-
 3 files changed, 14 insertions(+), 5 deletions(-)

diff --git a/drivers/staging/lustre/lustre/mdc/mdc_request.c b/drivers/staging/lustre/lustre/mdc/mdc_request.c
index 6023c2c..5f1ac58 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_request.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_request.c
@@ -2314,12 +2314,14 @@ static int mdc_setup(struct obd_device *obd, struct lustre_cfg *cfg)
 		return -ENOMEM;
 	mdc_init_rpc_lock(cli->cl_rpc_lock);
 
-	ptlrpcd_addref();
+	rc = ptlrpcd_addref();
+	if (rc < 0)
+		goto err_rpc_lock;
 
 	cli->cl_close_lock = kzalloc(sizeof(*cli->cl_close_lock), GFP_NOFS);
 	if (!cli->cl_close_lock) {
 		rc = -ENOMEM;
-		goto err_rpc_lock;
+		goto err_ptlrpcd_decref;
 	}
 	mdc_init_rpc_lock(cli->cl_close_lock);
 
@@ -2345,9 +2347,10 @@ static int mdc_setup(struct obd_device *obd, struct lustre_cfg *cfg)
 
 err_close_lock:
 	kfree(cli->cl_close_lock);
+err_ptlrpcd_decref:
+	ptlrpcd_decref();
 err_rpc_lock:
 	kfree(cli->cl_rpc_lock);
-	ptlrpcd_decref();
 	return rc;
 }
 
diff --git a/drivers/staging/lustre/lustre/mgc/mgc_request.c b/drivers/staging/lustre/lustre/mgc/mgc_request.c
index 3924b09..0f75040 100644
--- a/drivers/staging/lustre/lustre/mgc/mgc_request.c
+++ b/drivers/staging/lustre/lustre/mgc/mgc_request.c
@@ -734,7 +734,9 @@ static int mgc_setup(struct obd_device *obd, struct lustre_cfg *lcfg)
 	struct task_struct *task;
 	int rc;
 
-	ptlrpcd_addref();
+	rc = ptlrpcd_addref();
+	if (rc < 0)
+		goto err_noref;
 
 	rc = client_obd_setup(obd, lcfg);
 	if (rc)
@@ -773,6 +775,7 @@ err_cleanup:
 	client_obd_cleanup(obd);
 err_decref:
 	ptlrpcd_decref();
+err_noref:
 	return rc;
 }
 
diff --git a/drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c b/drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c
index dbc3376..76a355a 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c
@@ -909,8 +909,11 @@ int ptlrpcd_addref(void)
 	int rc = 0;
 
 	mutex_lock(&ptlrpcd_mutex);
-	if (++ptlrpcd_users == 1)
+	if (++ptlrpcd_users == 1) {
 		rc = ptlrpcd_init();
+		if (rc < 0)
+			ptlrpcd_users--;
+	}
 	mutex_unlock(&ptlrpcd_mutex);
 	return rc;
 }
-- 
1.7.1
