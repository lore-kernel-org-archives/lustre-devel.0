From: SF Markus Elfring <elfring@users.sourceforge.net>
Date: Sun, 13 Dec 2015 14:58:33 +0100
Subject: [lustre-devel] [PATCH 6/7] staging: lustre: A few checks less in
 mgc_process_recover_log() after error detection
In-Reply-To: <566D7733.1030102@users.sourceforge.net>
References: <566ABCD9.1060404@users.sourceforge.net>
	<566D7733.1030102@users.sourceforge.net>
Message-ID: <566D7989.6090205@users.sourceforge.net>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Sun, 13 Dec 2015 13:03:58 +0100

A few checks would be performed by the mgc_process_recover_log() function
even if it was determined that a call of the alloc_page() function failed.

* This implementation detail could be improved by adjustments
  for jump targets according to the Linux coding style convention.

* Move the assignment for the variable "eof" behind the memory allocation.

* Delete another sanity check then.

* The variable "req" will eventually be set to an appropriate pointer
  from a call of the ptlrpc_request_alloc() function.
  Thus let us omit the explicit initialisation before.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/staging/lustre/lustre/mgc/mgc_request.c | 32 +++++++++++--------------
 1 file changed, 14 insertions(+), 18 deletions(-)

diff --git a/drivers/staging/lustre/lustre/mgc/mgc_request.c b/drivers/staging/lustre/lustre/mgc/mgc_request.c
index f3b4c30..7048722 100644
--- a/drivers/staging/lustre/lustre/mgc/mgc_request.c
+++ b/drivers/staging/lustre/lustre/mgc/mgc_request.c
@@ -1312,17 +1312,15 @@ static int mgc_process_recover_log(struct obd_device *obd,
 	if (!pages)
 		return -ENOMEM;
 
-	req = NULL;
-	eof = true;
-
 	for (i = 0; i < nrpages; i++) {
 		pages[i] = alloc_page(GFP_KERNEL);
 		if (pages[i] == NULL) {
 			rc = -ENOMEM;
-			goto out;
+			goto free_pages;
 		}
 	}
 
+	eof = true;
 again:
 	LASSERT(cld_is_recover(cld));
 	LASSERT(mutex_is_locked(&cld->cld_lock));
@@ -1330,12 +1328,12 @@ again:
 				   &RQF_MGS_CONFIG_READ);
 	if (req == NULL) {
 		rc = -ENOMEM;
-		goto out;
+		goto free_pages;
 	}
 
 	rc = ptlrpc_request_pack(req, LUSTRE_MGS_VERSION, MGS_CONFIG_READ);
 	if (rc)
-		goto out;
+		goto finish_request;
 
 	/* pack request */
 	body = req_capsule_client_get(&req->rq_pill, &RMF_MGS_CONFIG_BODY);
@@ -1344,7 +1342,7 @@ again:
 	if (strlcpy(body->mcb_name, cld->cld_logname, sizeof(body->mcb_name))
 	    >= sizeof(body->mcb_name)) {
 		rc = -E2BIG;
-		goto out;
+		goto finish_request;
 	}
 	body->mcb_offset = cfg->cfg_last_idx + 1;
 	body->mcb_type   = cld->cld_type;
@@ -1356,7 +1354,7 @@ again:
 				    MGS_BULK_PORTAL);
 	if (desc == NULL) {
 		rc = -ENOMEM;
-		goto out;
+		goto finish_request;
 	}
 
 	for (i = 0; i < nrpages; i++)
@@ -1365,12 +1363,12 @@ again:
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
@@ -1384,18 +1382,18 @@ again:
 	ealen = sptlrpc_cli_unwrap_bulk_read(req, req->rq_bulk, 0);
 	if (ealen < 0) {
 		rc = ealen;
-		goto out;
+		goto finish_request;
 	}
 
 	if (ealen > nrpages << PAGE_CACHE_SHIFT) {
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
@@ -1425,14 +1423,12 @@ again:
 
 		ealen -= PAGE_CACHE_SIZE;
 	}
-
-out:
-	if (req)
-		ptlrpc_req_finished(req);
+finish_request:
+	ptlrpc_req_finished(req);
 
 	if (rc == 0 && !eof)
 		goto again;
-
+free_pages:
 	for (i = 0; i < nrpages; i++) {
 		if (pages[i] == NULL)
 			break;
-- 
2.6.3
