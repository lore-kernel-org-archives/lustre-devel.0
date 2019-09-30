From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Sep 2019 14:55:42 -0400
Subject: [lustre-devel] [PATCH 083/151] lustre: obd: free obd_svc_stats when
 all users are gone
In-Reply-To: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1569869810-23848-84-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Bruno Faccini <bruno.faccini@intel.com>

During object device shutdown obd_svc_stats must only be freed
after all access methods from user-land are no longer possible
to prevent any race and further crash.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10224
Lustre-commit: ffc843a0aacd (LU-10224 obd: free obd_svc_stats when all users are gone")
Signed-off-by: Bruno Faccini <bruno.faccini@intel.com>
Reviewed-on: https://review.whamcloud.com/30249
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/mdc/mdc_request.c     | 1 -
 fs/lustre/osc/osc_request.c     | 1 -
 fs/lustre/ptlrpc/lproc_ptlrpc.c | 4 ++++
 3 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/fs/lustre/mdc/mdc_request.c b/fs/lustre/mdc/mdc_request.c
index 9bae3a5..1a0f05a 100644
--- a/fs/lustre/mdc/mdc_request.c
+++ b/fs/lustre/mdc/mdc_request.c
@@ -2584,7 +2584,6 @@ static int mdc_precleanup(struct obd_device *obd)
 
 	obd_cleanup_client_import(obd);
 	ptlrpc_lprocfs_unregister_obd(obd);
-	lprocfs_obd_cleanup(obd);
 	ldebugfs_free_md_stats(obd);
 	mdc_llog_finish(obd);
 	return 0;
diff --git a/fs/lustre/osc/osc_request.c b/fs/lustre/osc/osc_request.c
index 5581f42..2dce087 100644
--- a/fs/lustre/osc/osc_request.c
+++ b/fs/lustre/osc/osc_request.c
@@ -3070,7 +3070,6 @@ static int osc_precleanup(struct obd_device *obd)
 	osc_precleanup_common(obd);
 
 	ptlrpc_lprocfs_unregister_obd(obd);
-	lprocfs_obd_cleanup(obd);
 	return 0;
 }
 
diff --git a/fs/lustre/ptlrpc/lproc_ptlrpc.c b/fs/lustre/ptlrpc/lproc_ptlrpc.c
index 6ce4d9e..02713076 100644
--- a/fs/lustre/ptlrpc/lproc_ptlrpc.c
+++ b/fs/lustre/ptlrpc/lproc_ptlrpc.c
@@ -1172,6 +1172,10 @@ void ptlrpc_lprocfs_unregister_service(struct ptlrpc_service *svc)
 
 void ptlrpc_lprocfs_unregister_obd(struct obd_device *obd)
 {
+	/* cleanup first to allow concurrent access to device's
+	 * stats via debugfs to complete safely
+	 */
+	lprocfs_obd_cleanup(obd);
 	debugfs_remove_recursive(obd->obd_svc_debugfs_entry);
 
 	if (obd->obd_svc_stats)
-- 
1.8.3.1
