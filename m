From: SF Markus Elfring <elfring@users.sourceforge.net>
Date: Sun, 13 Dec 2015 14:57:38 +0100
Subject: [lustre-devel] [PATCH 5/7] staging: lustre: Less checks in
 mgc_process_recover_log() after error detection
In-Reply-To: <566D7733.1030102@users.sourceforge.net>
References: <566ABCD9.1060404@users.sourceforge.net>
	<566D7733.1030102@users.sourceforge.net>
Message-ID: <566D7952.7090401@users.sourceforge.net>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Sun, 13 Dec 2015 12:21:17 +0100

A few checks would be performed by the mgc_process_recover_log() function
even if it is known already that the passed variable "pages" contained
a null pointer.

* Let us return directly if a call of the kcalloc() function failed.

* Move assignments for the variables "eof" and "req" behind
  this memory allocation.

* Delete a sanity check then.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/staging/lustre/lustre/mgc/mgc_request.c | 25 ++++++++++++-------------
 1 file changed, 12 insertions(+), 13 deletions(-)

diff --git a/drivers/staging/lustre/lustre/mgc/mgc_request.c b/drivers/staging/lustre/lustre/mgc/mgc_request.c
index da130f4..f3b4c30 100644
--- a/drivers/staging/lustre/lustre/mgc/mgc_request.c
+++ b/drivers/staging/lustre/lustre/mgc/mgc_request.c
@@ -1285,14 +1285,14 @@ static int mgc_apply_recover_logs(struct obd_device *mgc,
 static int mgc_process_recover_log(struct obd_device *obd,
 				   struct config_llog_data *cld)
 {
-	struct ptlrpc_request *req = NULL;
+	struct ptlrpc_request *req;
 	struct config_llog_instance *cfg = &cld->cld_cfg;
 	struct mgs_config_body *body;
 	struct mgs_config_res  *res;
 	struct ptlrpc_bulk_desc *desc;
 	struct page **pages;
 	int nrpages;
-	bool eof = true;
+	bool eof;
 	bool mne_swab;
 	int i;
 	int ealen;
@@ -1309,10 +1309,11 @@ static int mgc_process_recover_log(struct obd_device *obd,
 		nrpages = CONFIG_READ_NRPAGES_INIT;
 
 	pages = kcalloc(nrpages, sizeof(*pages), GFP_KERNEL);
-	if (pages == NULL) {
-		rc = -ENOMEM;
-		goto out;
-	}
+	if (!pages)
+		return -ENOMEM;
+
+	req = NULL;
+	eof = true;
 
 	for (i = 0; i < nrpages; i++) {
 		pages[i] = alloc_page(GFP_KERNEL);
@@ -1432,14 +1433,12 @@ out:
 	if (rc == 0 && !eof)
 		goto again;
 
-	if (pages) {
-		for (i = 0; i < nrpages; i++) {
-			if (pages[i] == NULL)
-				break;
-			__free_page(pages[i]);
-		}
-		kfree(pages);
+	for (i = 0; i < nrpages; i++) {
+		if (pages[i] == NULL)
+			break;
+		__free_page(pages[i]);
 	}
+	kfree(pages);
 	return rc;
 }
 
-- 
2.6.3
