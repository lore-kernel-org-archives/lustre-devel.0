From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:11:34 -0500
Subject: [lustre-devel] [PATCH 226/622] lustre: ptlrpc: handle proper import
 states for recovery
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-227-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Wang Shilong <wshilong@ddn.com>

There are two problems:

See following assertion:

    lod_add_device() lustre-OSTe42a-osc-MDT0000:
                     can't set up pool, failed with -12
    osp_disconnect() ASSERTION( imp != ((void *)0) ) failed:
    osp_disconnect() LBUG
    CPU: 1 PID: 10059 Comm: llog_process_th

Problem is obd_disconnect() will cleanup @imp and set NULL.
 ->osp_obd_disconnect
    ->class_manual_cleanup
       ->class_process_config
          ->class_cleanup
             ->obd_precleanup
                ->osp_device_fini
                   ->client_obd_cleanup

While ldo_process_config() will try to access @imp again:
 ->ldo_process_config
    ->osp_shutdown
       ->osp_disconnect
          ->LASSERT(imp != NULL)

Another problem is if we failed before obd_connect().
we will hang on with mount:
 ->ldo_process_config
    ->osp_shutdown
       ->osp_disconnect
          ->ptlrpc_disconnect_import
             ->rc = l_wait_event(imp->imp_recovery_waitq,
                                 !ptlrpc_import_in_recovery(imp), &lwi);

Since connect is not called, imp state will stay LUSTRE_IMP_NEW.
Fix this by check whether we are in recovery properly, only consider
we are in recovery if we are in following states:

 LUSTRE_IMP_CONNECTING = 4,
 LUSTRE_IMP_REPLAY     = 5,
 LUSTRE_IMP_REPLAY_LOCKS = 6,
 LUSTRE_IMP_REPLAY_WAIT  = 7,
 LUSTRE_IMP_RECOVER    = 8,

WC-bug-id: https://jira.whamcloud.com/browse/LU-11243
Lustre-commit: f28353b3d810 ("LU-11243 lod: fix assertion and hang upon lod_add_device failure")
Signed-off-by: Wang Shilong <wshilong@ddn.com>
Reviewed-on: https://review.whamcloud.com/32994
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Gu Zheng <gzheng@ddn.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ptlrpc/recover.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/fs/lustre/ptlrpc/recover.c b/fs/lustre/ptlrpc/recover.c
index ceab288..e26612d 100644
--- a/fs/lustre/ptlrpc/recover.c
+++ b/fs/lustre/ptlrpc/recover.c
@@ -367,9 +367,8 @@ int ptlrpc_import_in_recovery(struct obd_import *imp)
 	int in_recovery = 1;
 
 	spin_lock(&imp->imp_lock);
-	if (imp->imp_state == LUSTRE_IMP_FULL ||
-	    imp->imp_state == LUSTRE_IMP_CLOSED ||
-	    imp->imp_state == LUSTRE_IMP_DISCON ||
+	if (imp->imp_state <= LUSTRE_IMP_DISCON ||
+	    imp->imp_state >= LUSTRE_IMP_FULL ||
 	    imp->imp_obd->obd_no_recov)
 		in_recovery = 0;
 	spin_unlock(&imp->imp_lock);
-- 
1.8.3.1
