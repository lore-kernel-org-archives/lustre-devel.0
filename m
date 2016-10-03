From: James Simmons <jsimmons@infradead.org>
Date: Sun,  2 Oct 2016 22:28:24 -0400
Subject: [lustre-devel] [PATCH 28/41] staging: lustre: hsm: make HSM
	modification requests replayable
In-Reply-To: <1475461717-21631-1-git-send-email-jsimmons@infradead.org>
References: <1475461717-21631-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1475461717-21631-29-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Mikhail Pershin <mike.pershin@intel.com>, James Simmons <jsimmons@infradead.org>

From: Mikhail Pershin <mike.pershin@intel.com>

There are several HSM requests which modify data on server and
reply on Lustre recovery, e.g. they should replay changes in
case of recovery.

Patch allows such requests to be replayed in recovery time and
they are issued from client using mdc_rpc_lock to serialize them
and avoid concurrent last_rcvd update on server.

Signed-off-by: Mikhail Pershin <mike.pershin@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5939
Reviewed-on: http://review.whamcloud.com/13684
Reviewed-by: Jinshan Xiong <jinshan.xiong@intel.com>
Reviewed-by: Faccini Bruno <bruno.faccini@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/mdc/mdc_request.c |   12 +++++++++---
 1 files changed, 9 insertions(+), 3 deletions(-)

diff --git a/drivers/staging/lustre/lustre/mdc/mdc_request.c b/drivers/staging/lustre/lustre/mdc/mdc_request.c
index 7b9fb90..1d1eaa5 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_request.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_request.c
@@ -1505,7 +1505,9 @@ static int mdc_ioc_hsm_progress(struct obd_export *exp,
 
 	ptlrpc_request_set_replen(req);
 
-	rc = mdc_queue_wait(req);
+	mdc_get_rpc_lock(exp->exp_obd->u.cli.cl_rpc_lock, NULL);
+	rc = ptlrpc_queue_wait(req);
+	mdc_put_rpc_lock(exp->exp_obd->u.cli.cl_rpc_lock, NULL);
 out:
 	ptlrpc_req_finished(req);
 	return rc;
@@ -1683,7 +1685,9 @@ static int mdc_ioc_hsm_state_set(struct obd_export *exp,
 
 	ptlrpc_request_set_replen(req);
 
-	rc = mdc_queue_wait(req);
+	mdc_get_rpc_lock(exp->exp_obd->u.cli.cl_rpc_lock, NULL);
+	rc = ptlrpc_queue_wait(req);
+	mdc_put_rpc_lock(exp->exp_obd->u.cli.cl_rpc_lock, NULL);
 out:
 	ptlrpc_req_finished(req);
 	return rc;
@@ -1746,7 +1750,9 @@ static int mdc_ioc_hsm_request(struct obd_export *exp,
 
 	ptlrpc_request_set_replen(req);
 
-	rc = mdc_queue_wait(req);
+	mdc_get_rpc_lock(exp->exp_obd->u.cli.cl_rpc_lock, NULL);
+	rc = ptlrpc_queue_wait(req);
+	mdc_put_rpc_lock(exp->exp_obd->u.cli.cl_rpc_lock, NULL);
 out:
 	ptlrpc_req_finished(req);
 	return rc;
-- 
1.7.1
