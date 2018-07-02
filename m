From: James Simmons <jsimmons@infradead.org>
Date: Mon,  2 Jul 2018 19:24:31 -0400
Subject: [lustre-devel] [PATCH 14/18] lustre: obd: add callback for
 llog_cat_process_or_fork
In-Reply-To: <1530573875-20465-1-git-send-email-jsimmons@infradead.org>
References: <1530573875-20465-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1530573875-20465-15-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Alexander Boyko <c17825@cray.com>

Currently llog_process_or_fork() is hard coded to
always pass the function pointer llog_cat_process_cb().
Change llog_cat_process_or_fork() to pass in any
function pointer which will allow us more options
for llog_cat callback routines in the future.

Signed-off-by: Alexander Boyko <c17825@cray.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-7156
Seagate-bug-id: MRP-2383
Reviewed-on: http://review.whamcloud.com/16416
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Nathaniel Clark <nathaniel.l.clark@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/obdclass/llog_cat.c | 16 +++++++---------
 1 file changed, 7 insertions(+), 9 deletions(-)

diff --git a/drivers/staging/lustre/lustre/obdclass/llog_cat.c b/drivers/staging/lustre/lustre/obdclass/llog_cat.c
index d9c63ad..58dbd50 100644
--- a/drivers/staging/lustre/lustre/obdclass/llog_cat.c
+++ b/drivers/staging/lustre/lustre/obdclass/llog_cat.c
@@ -189,7 +189,8 @@ static int llog_cat_process_cb(const struct lu_env *env,
 
 static int llog_cat_process_or_fork(const struct lu_env *env,
 				    struct llog_handle *cat_llh,
-				    llog_cb_t cb, void *data, int startcat,
+				    llog_cb_t cat_cb, llog_cb_t cb,
+				    void *data, int startcat,
 				    int startidx, bool fork)
 {
 	struct llog_process_data d;
@@ -210,18 +211,15 @@ static int llog_cat_process_or_fork(const struct lu_env *env,
 
 		cd.lpcd_first_idx = llh->llh_cat_idx;
 		cd.lpcd_last_idx = 0;
-		rc = llog_process_or_fork(env, cat_llh, llog_cat_process_cb,
-					  &d, &cd, fork);
+		rc = llog_process_or_fork(env, cat_llh, cat_cb, &d, &cd, fork);
 		if (rc != 0)
 			return rc;
 
 		cd.lpcd_first_idx = 0;
 		cd.lpcd_last_idx = cat_llh->lgh_last_idx;
-		rc = llog_process_or_fork(env, cat_llh, llog_cat_process_cb,
-					  &d, &cd, fork);
+		rc = llog_process_or_fork(env, cat_llh, cat_cb, &d, &cd, fork);
 	} else {
-		rc = llog_process_or_fork(env, cat_llh, llog_cat_process_cb,
-					  &d, NULL, fork);
+		rc = llog_process_or_fork(env, cat_llh, cat_cb, &d, NULL, fork);
 	}
 
 	return rc;
@@ -230,7 +228,7 @@ static int llog_cat_process_or_fork(const struct lu_env *env,
 int llog_cat_process(const struct lu_env *env, struct llog_handle *cat_llh,
 		     llog_cb_t cb, void *data, int startcat, int startidx)
 {
-	return llog_cat_process_or_fork(env, cat_llh, cb, data, startcat,
-					startidx, false);
+	return llog_cat_process_or_fork(env, cat_llh, llog_cat_process_cb, cb,
+					data, startcat, startidx, false);
 }
 EXPORT_SYMBOL(llog_cat_process);
-- 
1.8.3.1
