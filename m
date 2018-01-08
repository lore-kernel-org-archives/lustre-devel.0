From: NeilBrown <neilb@suse.com>
Date: Mon, 08 Jan 2018 14:28:13 +1100
Subject: [lustre-devel] [PATCH 10/19] staging: lustre: simplify waiting in
 ptlrpc_invalidate_import()
In-Reply-To: <151538168618.23920.8261096424342988792.stgit@noble>
References: <151538168618.23920.8261096424342988792.stgit@noble>
Message-ID: <151538209368.23920.17745110760039469689.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, James Simmons <jsimmons@infradead.org>, Andreas Dilger <andreas.dilger@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: lkml <linux-kernel@vger.kernel.org>, lustre <lustre-devel@lists.lustre.org>

This waiter currently wakes up every second to re-test if
imp_flight is zero.  If we ensure wakeup is called whenever
imp_flight is decremented to zero, we can just have a simple
wait_event_idle_timeout().

So add a wake_up_all to the one place it is missing, and simplify
the wait_event.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/ptlrpc/client.c |    3 ++-
 drivers/staging/lustre/lustre/ptlrpc/import.c |   21 ++++++++-------------
 2 files changed, 10 insertions(+), 14 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ptlrpc/client.c b/drivers/staging/lustre/lustre/ptlrpc/client.c
index 0ab13f8e5993..81b7a7046d82 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/client.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/client.c
@@ -1588,7 +1588,8 @@ static int ptlrpc_send_new_req(struct ptlrpc_request *req)
 		spin_lock(&imp->imp_lock);
 		if (!list_empty(&req->rq_list)) {
 			list_del_init(&req->rq_list);
-			atomic_dec(&req->rq_import->imp_inflight);
+			if (atomic_dec_and_test(&req->rq_import->imp_inflight))
+				wake_up_all(&req->rq_import->imp_recovery_waitq);
 		}
 		spin_unlock(&imp->imp_lock);
 		ptlrpc_rqphase_move(req, RQ_PHASE_NEW);
diff --git a/drivers/staging/lustre/lustre/ptlrpc/import.c b/drivers/staging/lustre/lustre/ptlrpc/import.c
index ed210550f61f..5d62c9de27eb 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/import.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/import.c
@@ -265,7 +265,6 @@ void ptlrpc_invalidate_import(struct obd_import *imp)
 {
 	struct list_head *tmp, *n;
 	struct ptlrpc_request *req;
-	struct l_wait_info lwi;
 	unsigned int timeout;
 	int rc;
 
@@ -306,19 +305,15 @@ void ptlrpc_invalidate_import(struct obd_import *imp)
 		 * callbacks. Cap it at obd_timeout -- these should all
 		 * have been locally cancelled by ptlrpc_abort_inflight.
 		 */
-		lwi = LWI_TIMEOUT_INTERVAL(
-			cfs_timeout_cap(timeout * HZ),
-			(timeout > 1) ? HZ :
-			HZ / 2,
-			NULL, NULL);
-		rc = l_wait_event(imp->imp_recovery_waitq,
-				  (atomic_read(&imp->imp_inflight) == 0),
-				  &lwi);
-		if (rc) {
+		rc = wait_event_idle_timeout(imp->imp_recovery_waitq,
+					     atomic_read(&imp->imp_inflight) == 0,
+					     obd_timeout * HZ);
+
+		if (rc == 0) {
 			const char *cli_tgt = obd2cli_tgt(imp->imp_obd);
 
-			CERROR("%s: rc = %d waiting for callback (%d != 0)\n",
-			       cli_tgt, rc,
+			CERROR("%s: timeout waiting for callback (%d != 0)\n",
+			       cli_tgt,
 			       atomic_read(&imp->imp_inflight));
 
 			spin_lock(&imp->imp_lock);
@@ -365,7 +360,7 @@ void ptlrpc_invalidate_import(struct obd_import *imp)
 			}
 			spin_unlock(&imp->imp_lock);
 		}
-	} while (rc != 0);
+	} while (rc == 0);
 
 	/*
 	 * Let's additionally check that no new rpcs added to import in
