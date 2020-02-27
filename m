From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:17:17 -0500
Subject: [lustre-devel] [PATCH 569/622] lustre: obdclass: don't skip records
 for wrapped catalog
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-570-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Alexander Boyko <c17825@cray.com>

osp_sync_thread() uses opd_sync_last_catalog_idx as a start point of
catalog processing. It is used at llog_cat_process_cb also, to skip
records from processing. When catalog is wrapped, processing starts
from second part of catalog and then a first part. So, a first part
would be skipped at llog_cat_process_cb() base on lpd_startcat.

osp_sync_thread() restarts a processing loop with a
opd_sync_last_catalog_idx. For a wrapped it increases last
index and one more increase do a llog_process_thread. This leads
to a skipped records at catalog, they would not be processed.
The patch fixes these issues.
It also adds sanity test 135 and 136 as regression tests.

WC-bug-id: https://jira.whamcloud.com/browse/LU-13069
Lustre-commit: cc1092291932 ("LU-13069 obdclass: don't skip records for wrapped catalog")
Signed-off-by: Alexander Boyko <c17825@cray.com>
Cray-bug-id: LUS-8053,LUS-8236
Reviewed-on: https://review.whamcloud.com/36996
Reviewed-by: Andriy Skulysh <c17819@cray.com>
Reviewed-by: Alexander Zarochentsev <c17826@cray.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/obd_support.h | 2 ++
 fs/lustre/obdclass/llog.c       | 9 +++++++++
 fs/lustre/obdclass/llog_cat.c   | 1 +
 3 files changed, 12 insertions(+)

diff --git a/fs/lustre/include/obd_support.h b/fs/lustre/include/obd_support.h
index 5969b6b..a26ac76 100644
--- a/fs/lustre/include/obd_support.h
+++ b/fs/lustre/include/obd_support.h
@@ -447,6 +447,8 @@
 /* was	OBD_FAIL_LLOG_CATINFO_NET			0x1309 until 2.3 */
 #define OBD_FAIL_MDS_SYNC_CAPA_SL			0x1310
 #define OBD_FAIL_SEQ_ALLOC				0x1311
+#define OBD_FAIL_PLAIN_RECORDS			    0x1319
+#define OBD_FAIL_CATALOG_FULL_CHECK		    0x131a
 
 #define OBD_FAIL_LLITE					0x1400
 #define OBD_FAIL_LLITE_FAULT_TRUNC_RACE			0x1401
diff --git a/fs/lustre/obdclass/llog.c b/fs/lustre/obdclass/llog.c
index 4e9fd17..620ebc6 100644
--- a/fs/lustre/obdclass/llog.c
+++ b/fs/lustre/obdclass/llog.c
@@ -453,6 +453,8 @@ int llog_process_or_fork(const struct lu_env *env,
 			 llog_cb_t cb, void *data, void *catdata, bool fork)
 {
 	struct llog_process_info *lpi;
+	struct llog_process_data *d = data;
+	struct llog_process_cat_data *cd = catdata;
 	int rc;
 
 	lpi = kzalloc(sizeof(*lpi), GFP_KERNEL);
@@ -463,6 +465,13 @@ int llog_process_or_fork(const struct lu_env *env,
 	lpi->lpi_cbdata = data;
 	lpi->lpi_catdata = catdata;
 
+	CDEBUG(D_OTHER,
+	       "Processing " DFID " flags 0x%03x startcat %d startidx %d first_idx %d last_idx %d\n",
+	       PFID(&loghandle->lgh_id.lgl_oi.oi_fid),
+	       loghandle->lgh_hdr->llh_flags, d ? d->lpd_startcat : -1,
+	       d ? d->lpd_startidx : -1, cd ? cd->lpcd_first_idx : -1,
+	       cd ? cd->lpcd_last_idx : -1);
+
 	if (fork) {
 		struct task_struct *task;
 
diff --git a/fs/lustre/obdclass/llog_cat.c b/fs/lustre/obdclass/llog_cat.c
index 30b0ac5..75226f4 100644
--- a/fs/lustre/obdclass/llog_cat.c
+++ b/fs/lustre/obdclass/llog_cat.c
@@ -244,6 +244,7 @@ static int llog_cat_process_or_fork(const struct lu_env *env,
 			 * catalog bottom.
 			 */
 			startcat = 0;
+			d.lpd_startcat = 0;
 			if (rc != 0)
 				return rc;
 		}
-- 
1.8.3.1
