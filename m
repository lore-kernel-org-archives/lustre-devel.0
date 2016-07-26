From: SF Markus Elfring <elfring@users.sourceforge.net>
Date: Tue, 26 Jul 2016 21:12:22 +0200
Subject: [lustre-devel] [PATCH 10/12] staging: lustre: Rename jump labels in
 mgc_process_recover_log()
In-Reply-To: <59d94e70-7476-728e-5f63-013557ec2db9@users.sourceforge.net>
References: <566ABCD9.1060404@users.sourceforge.net>
	<566D7733.1030102@users.sourceforge.net>
	<56784D83.7080108@users.sourceforge.net>
	<56784F0C.6040007@users.sourceforge.net>
	<20151221234857.GA27079@kroah.com>
	<59d94e70-7476-728e-5f63-013557ec2db9@users.sourceforge.net>
Message-ID: <7f6e1800-cb60-ef60-6f41-e883d75bea23@users.sourceforge.net>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: devel@driverdev.osuosl.org, lustre-devel@lists.lustre.org, Andreas Dilger <andreas.dilger@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Oleg Drokin <oleg.drokin@intel.com>
Cc: LKML <linux-kernel@vger.kernel.org>, kernel-janitors@vger.kernel.org, Julia Lawall <julia.lawall@lip6.fr>, Bhumika Goyal <bhumirks@gmail.com>

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Tue, 26 Jul 2016 19:29:11 +0200

Adjust jump targets according to the Linux coding style convention.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/staging/lustre/lustre/mgc/mgc_request.c | 19 +++++++++----------
 1 file changed, 9 insertions(+), 10 deletions(-)

diff --git a/drivers/staging/lustre/lustre/mgc/mgc_request.c b/drivers/staging/lustre/lustre/mgc/mgc_request.c
index 2207af7..ff60b9b 100644
--- a/drivers/staging/lustre/lustre/mgc/mgc_request.c
+++ b/drivers/staging/lustre/lustre/mgc/mgc_request.c
@@ -1362,7 +1362,7 @@ again:
 
 	rc = ptlrpc_request_pack(req, LUSTRE_MGS_VERSION, MGS_CONFIG_READ);
 	if (rc)
-		goto out;
+		goto finish_request;
 
 	/* pack request */
 	body = req_capsule_client_get(&req->rq_pill, &RMF_MGS_CONFIG_BODY);
@@ -1370,7 +1370,7 @@ again:
 	if (strlcpy(body->mcb_name, cld->cld_logname, sizeof(body->mcb_name))
 	    >= sizeof(body->mcb_name)) {
 		rc = -E2BIG;
-		goto out;
+		goto finish_request;
 	}
 	body->mcb_offset = cfg->cfg_last_idx + 1;
 	body->mcb_type   = cld->cld_type;
@@ -1382,7 +1382,7 @@ again:
 				    MGS_BULK_PORTAL);
 	if (!desc) {
 		rc = -ENOMEM;
-		goto out;
+		goto finish_request;
 	}
 
 	for (i = 0; i < nrpages; i++)
@@ -1391,12 +1391,12 @@ again:
 	ptlrpc_request_set_replen(req);
 	rc = ptlrpc_queue_wait(req);
 	if (rc)
-		goto out;
+		goto finish_request;
 
 	res = req_capsule_server_get(&req->rq_pill, &RMF_MGS_CONFIG_RES);
 	if (res->mcr_size < res->mcr_offset) {
 		rc = -EINVAL;
-		goto out;
+		goto finish_request;
 	}
 
 	/* always update the index even though it might have errors with
@@ -1411,18 +1411,18 @@ again:
 	ealen = sptlrpc_cli_unwrap_bulk_read(req, req->rq_bulk, 0);
 	if (ealen < 0) {
 		rc = ealen;
-		goto out;
+		goto finish_request;
 	}
 
 	if (ealen > nrpages << PAGE_SHIFT) {
 		rc = -EINVAL;
-		goto out;
+		goto finish_request;
 	}
 
 	if (ealen == 0) { /* no logs transferred */
 		if (!eof)
 			rc = -EINVAL;
-		goto out;
+		goto finish_request;
 	}
 
 	mne_swab = !!ptlrpc_rep_need_swab(req);
@@ -1453,8 +1453,7 @@ again:
 
 		ealen -= PAGE_SIZE;
 	}
-
-out:
+finish_request:
 	ptlrpc_req_finished(req);
 
 	if (rc == 0 && !eof)
-- 
2.9.2
