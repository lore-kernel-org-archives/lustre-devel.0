From: Oleg Drokin <green@linuxhacker.ru>
Date: Wed, 24 Aug 2016 11:11:52 -0400
Subject: [lustre-devel] [PATCH v2 2/8] staging/lustre/mdc: fix panic at
	mdc_free_open()
In-Reply-To: <1472051518-745466-1-git-send-email-green@linuxhacker.ru>
References: <1472051518-745466-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1472051518-745466-3-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Alexander Boyko <alexander.boyko@seagate.com>, Oleg Drokin <green@linuxhacker.ru>

From: Alexander Boyko <alexander.boyko@seagate.com>

Assertion was happened for open request when rq_replay is set
to 1.
    ASSERTION(mod->mod_open_req->rq_replay == 0)
But this situation is not fatal for client, and could happened
when mdc_close() failed.
The fix allow to free such requests. If mdc_close fail, MDS doesn`t
receive close request from client. And in a worst case client would
be evicted.

The test recreates issue when mdc_close failed and
client asserts:
   ASSERTION( mod->mod_open_req->rq_replay == 0 ) failed

Signed-off-by: Alexander Boyko <alexander.boyko@seagate.com>
Seagate-bug-id: MRP-3156
Reviewed-on: http://review.whamcloud.com/17495
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5282
Reviewed-by: Alex Zhuravlev <alexey.zhuravlev@intel.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 .../staging/lustre/lustre/include/obd_support.h    |  1 +
 drivers/staging/lustre/lustre/mdc/mdc_request.c    | 56 ++++++++++++++--------
 2 files changed, 38 insertions(+), 19 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/obd_support.h b/drivers/staging/lustre/lustre/include/obd_support.h
index 0c29a33..4a9fe88 100644
--- a/drivers/staging/lustre/lustre/include/obd_support.h
+++ b/drivers/staging/lustre/lustre/include/obd_support.h
@@ -402,6 +402,7 @@ extern char obd_jobid_var[];
 #define OBD_FAIL_MDC_GETATTR_ENQUEUE     0x803
 #define OBD_FAIL_MDC_RPCS_SEM		 0x804
 #define OBD_FAIL_MDC_LIGHTWEIGHT	 0x805
+#define OBD_FAIL_MDC_CLOSE		 0x806
 
 #define OBD_FAIL_MGS		     0x900
 #define OBD_FAIL_MGS_ALL_REQUEST_NET     0x901
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_request.c b/drivers/staging/lustre/lustre/mdc/mdc_request.c
index 91c0b45..313889a 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_request.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_request.c
@@ -677,9 +677,15 @@ static void mdc_free_open(struct md_open_data *mod)
 	    imp_connect_disp_stripe(mod->mod_open_req->rq_import))
 		committed = 1;
 
-	LASSERT(mod->mod_open_req->rq_replay == 0);
-
-	DEBUG_REQ(D_RPCTRACE, mod->mod_open_req, "free open request\n");
+	/*
+	 * No reason to asssert here if the open request has
+	 * rq_replay == 1. It means that mdc_close failed, and
+	 * close request wasn`t sent. It is not fatal to client.
+	 * The worst thing is eviction if the client gets open lock
+	 */
+	DEBUG_REQ(D_RPCTRACE, mod->mod_open_req,
+		  "free open request rq_replay = %d\n",
+		   mod->mod_open_req->rq_replay);
 
 	ptlrpc_request_committed(mod->mod_open_req, committed);
 	if (mod->mod_close_req)
@@ -749,22 +755,10 @@ static int mdc_close(struct obd_export *exp, struct md_op_data *op_data,
 	}
 
 	*request = NULL;
-	req = ptlrpc_request_alloc(class_exp2cliimp(exp), req_fmt);
-	if (!req)
-		return -ENOMEM;
-
-	rc = ptlrpc_request_pack(req, LUSTRE_MDS_VERSION, MDS_CLOSE);
-	if (rc) {
-		ptlrpc_request_free(req);
-		return rc;
-	}
-
-	/* To avoid a livelock (bug 7034), we need to send CLOSE RPCs to a
-	 * portal whose threads are not taking any DLM locks and are therefore
-	 * always progressing
-	 */
-	req->rq_request_portal = MDS_READPAGE_PORTAL;
-	ptlrpc_at_set_req_timeout(req);
+	if (OBD_FAIL_CHECK(OBD_FAIL_MDC_CLOSE))
+		req = NULL;
+	else
+		req = ptlrpc_request_alloc(class_exp2cliimp(exp), req_fmt);
 
 	/* Ensure that this close's handle is fixed up during replay. */
 	if (likely(mod)) {
@@ -785,6 +779,29 @@ static int mdc_close(struct obd_export *exp, struct md_op_data *op_data,
 		 CDEBUG(D_HA,
 			"couldn't find open req; expecting close error\n");
 	}
+	if (!req) {
+		/*
+		 * TODO: repeat close after errors
+		 */
+		CWARN("%s: close of FID "DFID" failed, file reference will be dropped when this client unmounts or is evicted\n",
+		      obd->obd_name, PFID(&op_data->op_fid1));
+		rc = -ENOMEM;
+		goto out;
+	}
+
+	rc = ptlrpc_request_pack(req, LUSTRE_MDS_VERSION, MDS_CLOSE);
+	if (rc) {
+		ptlrpc_request_free(req);
+		goto out;
+	}
+
+	/*
+	 * To avoid a livelock (bug 7034), we need to send CLOSE RPCs to a
+	 * portal whose threads are not taking any DLM locks and are therefore
+	 * always progressing
+	 */
+	req->rq_request_portal = MDS_READPAGE_PORTAL;
+	ptlrpc_at_set_req_timeout(req);
 
 	mdc_close_pack(req, op_data);
 
@@ -830,6 +847,7 @@ static int mdc_close(struct obd_export *exp, struct md_op_data *op_data,
 		}
 	}
 
+out:
 	if (mod) {
 		if (rc != 0)
 			mod->mod_close_req = NULL;
-- 
2.7.4
