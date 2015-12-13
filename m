From: SF Markus Elfring <elfring@users.sourceforge.net>
Date: Sun, 13 Dec 2015 14:55:46 +0100
Subject: [lustre-devel] [PATCH 3/7] staging: lustre: Rename a jump label for
 a kfree(key) call
In-Reply-To: <566D7733.1030102@users.sourceforge.net>
References: <566ABCD9.1060404@users.sourceforge.net>
	<566D7733.1030102@users.sourceforge.net>
Message-ID: <566D78E2.9060209@users.sourceforge.net>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Sun, 13 Dec 2015 10:56:35 +0100

This issue was detected by using the Coccinelle software.

Choose a jump label according to the current Linux coding style convention.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/staging/lustre/lustre/mdc/mdc_request.c | 11 +++++------
 1 file changed, 5 insertions(+), 6 deletions(-)

diff --git a/drivers/staging/lustre/lustre/mdc/mdc_request.c b/drivers/staging/lustre/lustre/mdc/mdc_request.c
index 2a76685..2085ba6 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_request.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_request.c
@@ -1125,7 +1125,7 @@ static int mdc_ioc_fid2path(struct obd_export *exp, struct getinfo_fid2path *gf)
 
 	if (!fid_is_sane(&gf->gf_fid)) {
 		rc = -EINVAL;
-		goto out;
+		goto free_key;
 	}
 
 	/* Val is struct getinfo_fid2path result plus path */
@@ -1133,20 +1133,19 @@ static int mdc_ioc_fid2path(struct obd_export *exp, struct getinfo_fid2path *gf)
 
 	rc = obd_get_info(NULL, exp, keylen, key, &vallen, gf, NULL);
 	if (rc != 0 && rc != -EREMOTE)
-		goto out;
+		goto free_key;
 
 	if (vallen <= sizeof(*gf)) {
 		rc = -EPROTO;
-		goto out;
+		goto free_key;
 	} else if (vallen > sizeof(*gf) + gf->gf_pathlen) {
 		rc = -EOVERFLOW;
-		goto out;
+		goto free_key;
 	}
 
 	CDEBUG(D_IOCTL, "path get "DFID" from %llu #%d\n%s\n",
 	       PFID(&gf->gf_fid), gf->gf_recno, gf->gf_linkno, gf->gf_path);
-
-out:
+free_key:
 	kfree(key);
 	return rc;
 }
-- 
2.6.3
