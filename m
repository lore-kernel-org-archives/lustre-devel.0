From: James Simmons <jsimmons@infradead.org>
Date: Fri,  2 Dec 2016 19:53:21 -0500
Subject: [lustre-devel] [PATCH 14/22] staging: lustre: obd: add callback for
	llog_cat_process_or_fork
In-Reply-To: <1480726409-20350-1-git-send-email-jsimmons@infradead.org>
References: <1480726409-20350-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1480726409-20350-15-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Alexander Boyko <alexander.boyko@seagate.com>, James Simmons <jsimmons@infradead.org>

From: Alexander Boyko <alexander.boyko@seagate.com>

Currently llog_process_or_fork() is hard coded to
always pass the function pointer llog_cat_process_cb().
Change llog_cat_process_or_fork() to pass in any
function pointer which will allow us more options
for llog_cat callback routines in the future.

Signed-off-by: Alexander Boyko <alexander.boyko@seagate.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-7156
Seagate-bug-id: MRP-2383
Reviewed-on: http://review.whamcloud.com/16416
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Nathaniel Clark <nathaniel.l.clark@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/obdclass/llog_cat.c |   16 +++++++---------
 1 files changed, 7 insertions(+), 9 deletions(-)

diff --git a/drivers/staging/lustre/lustre/obdclass/llog_cat.c b/drivers/staging/lustre/lustre/obdclass/llog_cat.c
index ce8e2f6..de9d01d 100644
--- a/drivers/staging/lustre/lustre/obdclass/llog_cat.c
+++ b/drivers/staging/lustre/lustre/obdclass/llog_cat.c
@@ -188,7 +188,8 @@ static int llog_cat_process_cb(const struct lu_env *env,
 
 static int llog_cat_process_or_fork(const struct lu_env *env,
 				    struct llog_handle *cat_llh,
-				    llog_cb_t cb, void *data, int startcat,
+				    llog_cb_t cat_cb, llog_cb_t cb,
+				    void *data, int startcat,
 				    int startidx, bool fork)
 {
 	struct llog_process_data d;
@@ -209,18 +210,15 @@ static int llog_cat_process_or_fork(const struct lu_env *env,
 
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
@@ -229,7 +227,7 @@ static int llog_cat_process_or_fork(const struct lu_env *env,
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
1.7.1
