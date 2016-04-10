From: James Simmons <jsimmons@infradead.org>
Date: Sun, 10 Apr 2016 09:13:40 -0400
Subject: [lustre-devel] [PATCH 17/17] staging: lustre: hsm: don't use real
	suppgid
In-Reply-To: <1460294020-2111-1-git-send-email-jsimmons@infradead.org>
References: <1460294020-2111-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1460294020-2111-18-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, "John L. Hammond" <john.hammond@intel.com>, James Simmons <jsimmons@infradead.org>

From: John L. Hammond <john.hammond@intel.com>

In the MDC HSM handlers that do not pack a real suppgid, use -1 rather
than 0 for the suppgid in mdt_body.

Signed-off-by: John L. Hammond <john.hammond@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-3866
Reviewed-on: http://review.whamcloud.com/7565
Reviewed-by: Aurelien Degremont <aurelien.degremont@cea.fr>
Reviewed-by: Faccini Bruno <bruno.faccini@intel.com>
Reviewed-by: Jinshan Xiong <jinshan.xiong@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/mdc/mdc_request.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/staging/lustre/lustre/mdc/mdc_request.c b/drivers/staging/lustre/lustre/mdc/mdc_request.c
index 97f8669..513290f 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_request.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_request.c
@@ -1169,7 +1169,7 @@ static int mdc_ioc_hsm_progress(struct obd_export *exp,
 		goto out;
 	}
 
-	mdc_pack_body(req, NULL, OBD_MD_FLRMTPERM, 0, 0, 0);
+	mdc_pack_body(req, NULL, OBD_MD_FLRMTPERM, 0, -1, 0);
 
 	/* Copy hsm_progress struct */
 	req_hpk = req_capsule_client_get(&req->rq_pill, &RMF_MDS_HSM_PROGRESS);
@@ -1203,7 +1203,7 @@ static int mdc_ioc_hsm_ct_register(struct obd_import *imp, __u32 archives)
 		goto out;
 	}
 
-	mdc_pack_body(req, NULL, OBD_MD_FLRMTPERM, 0, 0, 0);
+	mdc_pack_body(req, NULL, OBD_MD_FLRMTPERM, 0, -1, 0);
 
 	/* Copy hsm_progress struct */
 	archive_mask = req_capsule_client_get(&req->rq_pill,
@@ -1278,7 +1278,7 @@ static int mdc_ioc_hsm_ct_unregister(struct obd_import *imp)
 		goto out;
 	}
 
-	mdc_pack_body(req, NULL, OBD_MD_FLRMTPERM, 0, 0, 0);
+	mdc_pack_body(req, NULL, OBD_MD_FLRMTPERM, 0, -1, 0);
 
 	ptlrpc_request_set_replen(req);
 
@@ -1395,7 +1395,7 @@ static int mdc_ioc_hsm_request(struct obd_export *exp,
 		return rc;
 	}
 
-	mdc_pack_body(req, NULL, OBD_MD_FLRMTPERM, 0, 0, 0);
+	mdc_pack_body(req, NULL, OBD_MD_FLRMTPERM, 0, -1, 0);
 
 	/* Copy hsm_request struct */
 	req_hr = req_capsule_client_get(&req->rq_pill, &RMF_MDS_HSM_REQUEST);
-- 
1.7.1
