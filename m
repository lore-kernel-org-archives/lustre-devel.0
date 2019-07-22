From: James Simmons <jsimmons@infradead.org>
Date: Sun, 21 Jul 2019 22:12:16 -0400
Subject: [lustre-devel] [PATCH 04/10] lustre: mgc: remove llog_process_lock
In-Reply-To: <1563761542-3708-1-git-send-email-jsimmons@infradead.org>
References: <1563761542-3708-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1563761542-3708-5-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: NeilBrown <neilb@suse.com>

This mutex is never used, so remove it.

Signed-off-by: NeilBrown <neilb@suse.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-4423
Reviewed-on: https://review.whamcloud.com/35293
Reviewed-by: Petros Koutoupis <pkoutoupis@cray.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/mgc/mgc_request.c | 6 +-----
 1 file changed, 1 insertion(+), 5 deletions(-)

diff --git a/fs/lustre/mgc/mgc_request.c b/fs/lustre/mgc/mgc_request.c
index fa0be5c..581ffb0 100644
--- a/fs/lustre/mgc/mgc_request.c
+++ b/fs/lustre/mgc/mgc_request.c
@@ -384,8 +384,6 @@ struct config_llog_data *do_config_log_add(struct obd_device *obd,
 	return ERR_PTR(rc);
 }
 
-static DEFINE_MUTEX(llog_process_lock);
-
 static inline void config_mark_cld_stop(struct config_llog_data *cld)
 {
 	if (!cld)
@@ -1538,9 +1536,7 @@ static int mgc_process_cfg_log(struct obd_device *mgc,
 	__llog_ctxt_put(env, ctxt);
 
 	/*
-	 * update settings on existing OBDs. doing it inside
-	 * of llog_process_lock so no device is attaching/detaching
-	 * in parallel.
+	 * update settings on existing OBDs.
 	 * the logname must be <fsname>-sptlrpc
 	 */
 	if (sptlrpc_started) {
-- 
1.8.3.1
