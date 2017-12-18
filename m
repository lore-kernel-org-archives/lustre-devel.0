From: NeilBrown <neilb@suse.com>
Date: Mon, 18 Dec 2017 18:18:00 +1100
Subject: [lustre-devel] [PATCH 10/16] staging: lustre: remove
 back_to_sleep() and use loops.
In-Reply-To: <151358127190.5099.12792810096274074963.stgit@noble>
References: <151358127190.5099.12792810096274074963.stgit@noble>
Message-ID: <151358148016.5099.17721203202254142965.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: lkml <linux-kernel@vger.kernel.org>, lustre <lustre-devel@lists.lustre.org>

When 'back_to_sleep()' is passed as the 'timeout' function,
the effect is to wait indefinitely for the event, polling
on the timeout in case we missed a wake_up.
If LWI_ON_SIGNAL_NOOP is given, then also abort (at the timeout)
if a "fatal" signal is pending.

Make this more obvious is both places "back_to_sleep()" is
used, adding l_fatal_signal_pending() to allow testing for
"fatal" signals.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/include/lustre_lib.h |    8 ++++----
 drivers/staging/lustre/lustre/ptlrpc/import.c      |   11 ++++++-----
 drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c     |    8 ++++----
 3 files changed, 14 insertions(+), 13 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_lib.h b/drivers/staging/lustre/lustre/include/lustre_lib.h
index d64306291b47..d157ed35a0bf 100644
--- a/drivers/staging/lustre/lustre/include/lustre_lib.h
+++ b/drivers/staging/lustre/lustre/include/lustre_lib.h
@@ -140,10 +140,6 @@ void target_send_reply(struct ptlrpc_request *req, int rc, int fail_id);
  * XXX nikita: some ptlrpc daemon threads have races of that sort.
  *
  */
-static inline int back_to_sleep(void *arg)
-{
-	return 0;
-}
 
 #define LWI_ON_SIGNAL_NOOP ((void (*)(void *))(-1))
 
@@ -200,6 +196,10 @@ struct l_wait_info {
 #define LUSTRE_FATAL_SIGS (sigmask(SIGKILL) | sigmask(SIGINT) |		\
 			   sigmask(SIGTERM) | sigmask(SIGQUIT) |	\
 			   sigmask(SIGALRM))
+static inline int l_fatal_signal_pending(struct task_struct *p)
+{
+	return signal_pending(p) && sigtestsetmask(&p->pending.signal, LUSTRE_FATAL_SIGS);
+}
 
 /**
  * wait_queue_entry_t of Linux (version < 2.6.34) is a FIFO list for exclusively
diff --git a/drivers/staging/lustre/lustre/ptlrpc/import.c b/drivers/staging/lustre/lustre/ptlrpc/import.c
index b6cef8e97435..decaa9bccdc8 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/import.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/import.c
@@ -1496,7 +1496,6 @@ int ptlrpc_disconnect_import(struct obd_import *imp, int noclose)
 	}
 
 	if (ptlrpc_import_in_recovery(imp)) {
-		struct l_wait_info lwi;
 		long timeout;
 
 		if (AT_OFF) {
@@ -1510,10 +1509,12 @@ int ptlrpc_disconnect_import(struct obd_import *imp, int noclose)
 			timeout = at_get(&imp->imp_at.iat_service_estimate[idx]) * HZ;
 		}
 
-		lwi = LWI_TIMEOUT_INTR(cfs_timeout_cap(timeout),
-				       back_to_sleep, LWI_ON_SIGNAL_NOOP, NULL);
-		rc = l_wait_event(imp->imp_recovery_waitq,
-				  !ptlrpc_import_in_recovery(imp), &lwi);
+		while (wait_event_timeout(imp->imp_recovery_waitq,
+					  !ptlrpc_import_in_recovery(imp),
+					  cfs_timeout_cap(timeout)) == 0)
+			if (l_fatal_signal_pending(current))
+				break;
+			/* else just keep waiting */
 	}
 
 	spin_lock(&imp->imp_lock);
diff --git a/drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c b/drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c
index dad2f9290f70..0bdf1f54629b 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c
@@ -230,12 +230,12 @@ void ptlrpcd_add_req(struct ptlrpc_request *req)
 
 	spin_lock(&req->rq_lock);
 	if (req->rq_invalid_rqset) {
-		struct l_wait_info lwi = LWI_TIMEOUT(5 * HZ,
-						     back_to_sleep, NULL);
-
 		req->rq_invalid_rqset = 0;
 		spin_unlock(&req->rq_lock);
-		l_wait_event(req->rq_set_waitq, !req->rq_set, &lwi);
+		while (wait_event_timeout(req->rq_set_waitq,
+					  !req->rq_set,
+					  5 * HZ) == 0)
+			;
 	} else if (req->rq_set) {
 		/* If we have a valid "rq_set", just reuse it to avoid double
 		 * linked.
