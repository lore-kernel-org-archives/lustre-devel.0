From: James Simmons <jsimmons@infradead.org>
Date: Mon, 17 Sep 2018 13:30:17 -0400
Subject: [lustre-devel] [PATCH 07/30] lustre: llog: update llog print format
 to use FIDs
In-Reply-To: <1537205440-6656-1-git-send-email-jsimmons@infradead.org>
References: <1537205440-6656-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1537205440-6656-8-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Andreas Dilger <adilger@whamcloud.com>

Print llog identifiers using FIDs instead of OSTID format, which has
been deprecated since 2.3.

Signed-off-by: Andreas Dilger <adilger@whamcloud.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-9153
Reviewed-on: https://review.whamcloud.com/25640
Reviewed-by: Henri Doreau <henri.doreau@cea.fr>
Reviewed-by: Faccini Bruno <bruno.faccini@intel.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/obdclass/llog_cat.c  | 28 ++++++++++++----------
 drivers/staging/lustre/lustre/obdclass/llog_swab.c |  4 ++--
 2 files changed, 17 insertions(+), 15 deletions(-)

diff --git a/drivers/staging/lustre/lustre/obdclass/llog_cat.c b/drivers/staging/lustre/lustre/obdclass/llog_cat.c
index 58dbd50..172a368 100644
--- a/drivers/staging/lustre/lustre/obdclass/llog_cat.c
+++ b/drivers/staging/lustre/lustre/obdclass/llog_cat.c
@@ -79,10 +79,10 @@ static int llog_cat_id2handle(const struct lu_env *env,
 		if (ostid_id(&cgl->lgl_oi) == ostid_id(&logid->lgl_oi) &&
 		    ostid_seq(&cgl->lgl_oi) == ostid_seq(&logid->lgl_oi)) {
 			if (cgl->lgl_ogen != logid->lgl_ogen) {
-				CERROR("%s: log " DOSTID " generation %x != %x\n",
-				       loghandle->lgh_ctxt->loc_obd->obd_name,
-				       POSTID(&logid->lgl_oi), cgl->lgl_ogen,
-				       logid->lgl_ogen);
+				CWARN("%s: log " DFID " generation %x != %x\n",
+				      loghandle->lgh_ctxt->loc_obd->obd_name,
+				      PFID(&logid->lgl_oi.oi_fid),
+				      cgl->lgl_ogen, logid->lgl_ogen);
 				continue;
 			}
 			loghandle->u.phd.phd_cat_handle = cathandle;
@@ -96,9 +96,9 @@ static int llog_cat_id2handle(const struct lu_env *env,
 	rc = llog_open(env, cathandle->lgh_ctxt, &loghandle, logid, NULL,
 		       LLOG_OPEN_EXISTS);
 	if (rc < 0) {
-		CERROR("%s: error opening log id " DOSTID ":%x: rc = %d\n",
+		CERROR("%s: error opening log id " DFID ":%x: rc = %d\n",
 		       cathandle->lgh_ctxt->loc_obd->obd_name,
-		       POSTID(&logid->lgl_oi), logid->lgl_ogen, rc);
+		       PFID(&logid->lgl_oi.oi_fid), logid->lgl_ogen, rc);
 		return rc;
 	}
 
@@ -153,15 +153,16 @@ static int llog_cat_process_cb(const struct lu_env *env,
 		CERROR("invalid record in catalog\n");
 		return -EINVAL;
 	}
-	CDEBUG(D_HA, "processing log " DOSTID ":%x at index %u of catalog "
-	       DOSTID "\n", POSTID(&lir->lid_id.lgl_oi), lir->lid_id.lgl_ogen,
-	       rec->lrh_index, POSTID(&cat_llh->lgh_id.lgl_oi));
+	CDEBUG(D_HA,
+	       "processing log " DFID ":%x at index %u of catalog " DFID "\n",
+	       PFID(&lir->lid_id.lgl_oi.oi_fid), lir->lid_id.lgl_ogen,
+	       rec->lrh_index, PFID(&cat_llh->lgh_id.lgl_oi.oi_fid));
 
 	rc = llog_cat_id2handle(env, cat_llh, &llh, &lir->lid_id);
 	if (rc) {
-		CERROR("%s: cannot find handle for llog " DOSTID ": %d\n",
+		CERROR("%s: cannot find handle for llog " DFID ": %d\n",
 		       cat_llh->lgh_ctxt->loc_obd->obd_name,
-		       POSTID(&lir->lid_id.lgl_oi), rc);
+		       PFID(&lir->lid_id.lgl_oi.oi_fid), rc);
 		return rc;
 	}
 
@@ -206,8 +207,9 @@ static int llog_cat_process_or_fork(const struct lu_env *env,
 	if (llh->llh_cat_idx > cat_llh->lgh_last_idx) {
 		struct llog_process_cat_data cd;
 
-		CWARN("catlog " DOSTID " crosses index zero\n",
-		      POSTID(&cat_llh->lgh_id.lgl_oi));
+		CWARN("%s: catlog " DFID " crosses index zero\n",
+		      cat_llh->lgh_ctxt->loc_obd->obd_name,
+		      PFID(&cat_llh->lgh_id.lgl_oi.oi_fid));
 
 		cd.lpcd_first_idx = llh->llh_cat_idx;
 		cd.lpcd_last_idx = 0;
diff --git a/drivers/staging/lustre/lustre/obdclass/llog_swab.c b/drivers/staging/lustre/lustre/obdclass/llog_swab.c
index 3803056..f18330f 100644
--- a/drivers/staging/lustre/lustre/obdclass/llog_swab.c
+++ b/drivers/staging/lustre/lustre/obdclass/llog_swab.c
@@ -45,8 +45,8 @@
 static void print_llogd_body(struct llogd_body *d)
 {
 	CDEBUG(D_OTHER, "llogd body: %p\n", d);
-	CDEBUG(D_OTHER, "\tlgd_logid.lgl_oi: " DOSTID "\n",
-	       POSTID(&d->lgd_logid.lgl_oi));
+	CDEBUG(D_OTHER, "\tlgd_logid.lgl_oi: " DFID "\n",
+	       PFID(&d->lgd_logid.lgl_oi.oi_fid));
 	CDEBUG(D_OTHER, "\tlgd_logid.lgl_ogen: %#x\n", d->lgd_logid.lgl_ogen);
 	CDEBUG(D_OTHER, "\tlgd_ctxt_idx: %#x\n", d->lgd_ctxt_idx);
 	CDEBUG(D_OTHER, "\tlgd_llh_flags: %#x\n", d->lgd_llh_flags);
-- 
1.8.3.1
