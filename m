From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:11:13 -0500
Subject: [lustre-devel] [PATCH 205/622] lustre: llog: add startcat for
 wrapped catalog
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-206-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Alexander Boyko <c17825@cray.com>

The osp_sync_thread loop for a llog_cat_process has a mistake.
When llog_cat_process has reached a bottom of catalog, the processing
restarts with 0. Which means a default processing. In this case a
catalog is wrapped and processing starts from a llh_cat_idx. But
records at the bottom were processed already, and were not cancelled
yet. The next message appears at log.
osp_sync_interpret()) reply req ffff8800123e3600/1, rc -2, transno 0

llog_cat_process support startcat index for processing catalog.
In this case the processing starts from startcat index. But if
catalog is wrapped startcat index is ignored.

The patch adds supporting of startcat index for wrapped catalog.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10913
Cray-bug-id: LUS-6765
Lustre-commit: 8109c9e1718d ("LU-10913 llog: add startcat for wrapped catalog")
Signed-off-by: Alexander Boyko <c17825@cray.com>
Reviewed-on: https://review.whamcloud.com/33749
Reviewed-by: Sergey Cheremencev <c17829@cray.com>
Reviewed-by: Alexander Zarochentsev <c17826@cray.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/obdclass/llog_cat.c          | 33 ++++++++++++++++++++++++---------
 include/uapi/linux/lustre/lustre_idl.h |  5 +++++
 2 files changed, 29 insertions(+), 9 deletions(-)

diff --git a/fs/lustre/obdclass/llog_cat.c b/fs/lustre/obdclass/llog_cat.c
index ca97e08..30b0ac5 100644
--- a/fs/lustre/obdclass/llog_cat.c
+++ b/fs/lustre/obdclass/llog_cat.c
@@ -222,7 +222,7 @@ static int llog_cat_process_or_fork(const struct lu_env *env,
 	LASSERT(llh->llh_flags & LLOG_F_IS_CAT);
 	d.lpd_data = data;
 	d.lpd_cb = cb;
-	d.lpd_startcat = startcat;
+	d.lpd_startcat = (startcat == LLOG_CAT_FIRST ? 0 : startcat);
 	d.lpd_startidx = startidx;
 
 	if (llh->llh_cat_idx > cat_llh->lgh_last_idx) {
@@ -231,14 +231,29 @@ static int llog_cat_process_or_fork(const struct lu_env *env,
 		CWARN("%s: catlog " DFID " crosses index zero\n",
 		      cat_llh->lgh_ctxt->loc_obd->obd_name,
 		      PFID(&cat_llh->lgh_id.lgl_oi.oi_fid));
-
-		cd.lpcd_first_idx = llh->llh_cat_idx;
-		cd.lpcd_last_idx = 0;
-		rc = llog_process_or_fork(env, cat_llh, cat_cb, &d, &cd, fork);
-		if (rc != 0)
-			return rc;
-
-		cd.lpcd_first_idx = 0;
+		/*startcat = 0 is default value for general processing */
+		if ((startcat != LLOG_CAT_FIRST &&
+		    startcat >= llh->llh_cat_idx) || !startcat) {
+			/* processing the catalog part at the end */
+			cd.lpcd_first_idx = (startcat ? startcat :
+					     llh->llh_cat_idx);
+			cd.lpcd_last_idx = 0;
+			rc = llog_process_or_fork(env, cat_llh, cat_cb,
+						  &d, &cd, fork);
+			/* Reset the startcat because it has already reached
+			 * catalog bottom.
+			 */
+			startcat = 0;
+			if (rc != 0)
+				return rc;
+		}
+		/* processing the catalog part at the beginning */
+		cd.lpcd_first_idx = (startcat == LLOG_CAT_FIRST) ? 0 : startcat;
+		/* Note, the processing will stop at the lgh_last_idx value,
+		 * and it could be increased during processing. So records
+		 * between current lgh_last_idx and lgh_last_idx in future
+		 * would left unprocessed.
+		 */
 		cd.lpcd_last_idx = cat_llh->lgh_last_idx;
 		rc = llog_process_or_fork(env, cat_llh, cat_cb, &d, &cd, fork);
 	} else {
diff --git a/include/uapi/linux/lustre/lustre_idl.h b/include/uapi/linux/lustre/lustre_idl.h
index 77b9539..76068ee 100644
--- a/include/uapi/linux/lustre/lustre_idl.h
+++ b/include/uapi/linux/lustre/lustre_idl.h
@@ -2618,6 +2618,11 @@ enum llog_flag {
 			  LLOG_F_EXT_X_OMODE | LLOG_F_EXT_X_XATTR,
 };
 
+/* means first record of catalog */
+enum {
+	LLOG_CAT_FIRST = -1,
+};
+
 /* On-disk header structure of each log object, stored in little endian order */
 #define LLOG_MIN_CHUNK_SIZE	8192
 #define LLOG_HEADER_SIZE	(96)	/* sizeof (llog_log_hdr) +
-- 
1.8.3.1
