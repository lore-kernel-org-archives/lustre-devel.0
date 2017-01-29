From: James Simmons <jsimmons@infradead.org>
Date: Sat, 28 Jan 2017 19:05:21 -0500
Subject: [lustre-devel] [PATCH 53/60] staging: lustre: ptlrpc: update replay
	cursor when close during replay
In-Reply-To: <1485648328-2141-1-git-send-email-jsimmons@infradead.org>
References: <1485648328-2141-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1485648328-2141-54-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Niu Yawei <yawei.niu@intel.com>, James Simmons <jsimmons@infradead.org>

From: Niu Yawei <yawei.niu@intel.com>

The replay cursor should be updated properly when close happened
during replay, otherwise, ptlrpc_replay_next() could run into a
dead loop due to an invalid replay cursor:

- replay cursor is moved to an open request during replay;
- application close that open file, so the rq_replay of the open
  request is cleared;
- ptlrpc_replay_next() calls ptlrpc_free_committed() to free
  committed/closed requests, the open request is removed from
  the committed list, so the replay cursor is changed to an
  empty list_head now. The open request won't be freed now since
  it's still held by the pending close request;
- ptlrpc_replay_next() continue to move the replay cursor to
  next and run into a dead loop at the end;

Another change in this patch is to remove the out of date comments
in ptlrpc_replay_next() and cover the whole process of finding
replay request within imp_lock, because:

1. With two separated replay lists and replay cursor introduced,
   finding replay request won't take much time as before, it's
   not necessary to do this "lock -> unlock -> lock -> unlock"
   trick anymore;

2. Nowadays there are various kind of non-replay requests are
   allowed during recovery, so ptlrpc_free_committed() may run in
   parallel to remove an open request while ptlrpc_replay_next()
   is iterating the open requests list;

Signed-off-by: Niu Yawei <yawei.niu@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-8765
Reviewed-on: https://review.whamcloud.com/23418
Reviewed-by: Yang Sheng <yang.sheng@intel.com>
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/ptlrpc/client.c  | 15 ++++++++++-----
 drivers/staging/lustre/lustre/ptlrpc/recover.c | 23 +----------------------
 2 files changed, 11 insertions(+), 27 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ptlrpc/client.c b/drivers/staging/lustre/lustre/ptlrpc/client.c
index 332b360..8dfb40f 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/client.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/client.c
@@ -2662,11 +2662,16 @@ void ptlrpc_free_committed(struct obd_import *imp)
 	list_for_each_entry_safe(req, saved, &imp->imp_committed_list,
 				 rq_replay_list) {
 		LASSERT(req->rq_transno != 0);
-		if (req->rq_import_generation < imp->imp_generation) {
-			DEBUG_REQ(D_RPCTRACE, req, "free stale open request");
-			ptlrpc_free_request(req);
-		} else if (!req->rq_replay) {
-			DEBUG_REQ(D_RPCTRACE, req, "free closed open request");
+		if (req->rq_import_generation < imp->imp_generation ||
+		    !req->rq_replay) {
+			DEBUG_REQ(D_RPCTRACE, req, "free %s open request",
+				  req->rq_import_generation <
+				  imp->imp_generation ? "stale" : "closed");
+
+			if (imp->imp_replay_cursor == &req->rq_replay_list)
+				imp->imp_replay_cursor =
+					req->rq_replay_list.next;
+
 			ptlrpc_free_request(req);
 		}
 	}
diff --git a/drivers/staging/lustre/lustre/ptlrpc/recover.c b/drivers/staging/lustre/lustre/ptlrpc/recover.c
index c03e113..7b58545 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/recover.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/recover.c
@@ -78,28 +78,11 @@ int ptlrpc_replay_next(struct obd_import *imp, int *inflight)
 	imp->imp_last_transno_checked = 0;
 	ptlrpc_free_committed(imp);
 	last_transno = imp->imp_last_replay_transno;
-	spin_unlock(&imp->imp_lock);
 
 	CDEBUG(D_HA, "import %p from %s committed %llu last %llu\n",
 	       imp, obd2cli_tgt(imp->imp_obd),
 	       imp->imp_peer_committed_transno, last_transno);
 
-	/* Do I need to hold a lock across this iteration?  We shouldn't be
-	 * racing with any additions to the list, because we're in recovery
-	 * and are therefore not processing additional requests to add.  Calls
-	 * to ptlrpc_free_committed might commit requests, but nothing "newer"
-	 * than the one we're replaying (it can't be committed until it's
-	 * replayed, and we're doing that here).  l_f_e_safe protects against
-	 * problems with the current request being committed, in the unlikely
-	 * event of that race.  So, in conclusion, I think that it's safe to
-	 * perform this list-walk without the imp_lock held.
-	 *
-	 * But, the {mdc,osc}_replay_open callbacks both iterate
-	 * request lists, and have comments saying they assume the
-	 * imp_lock is being held by ptlrpc_replay, but it's not. it's
-	 * just a little race...
-	 */
-
 	/* Replay all the committed open requests on committed_list first */
 	if (!list_empty(&imp->imp_committed_list)) {
 		tmp = imp->imp_committed_list.prev;
@@ -107,10 +90,6 @@ int ptlrpc_replay_next(struct obd_import *imp, int *inflight)
 
 		/* The last request on committed_list hasn't been replayed */
 		if (req->rq_transno > last_transno) {
-			/* Since the imp_committed_list is immutable before
-			 * all of it's requests being replayed, it's safe to
-			 * use a cursor to accelerate the search
-			 */
 			if (!imp->imp_resend_replay ||
 			    imp->imp_replay_cursor == &imp->imp_committed_list)
 				imp->imp_replay_cursor = imp->imp_replay_cursor->next;
@@ -124,6 +103,7 @@ int ptlrpc_replay_next(struct obd_import *imp, int *inflight)
 					break;
 
 				req = NULL;
+				LASSERT(!list_empty(imp->imp_replay_cursor));
 				imp->imp_replay_cursor =
 					imp->imp_replay_cursor->next;
 			}
@@ -156,7 +136,6 @@ int ptlrpc_replay_next(struct obd_import *imp, int *inflight)
 	if (req && imp->imp_resend_replay)
 		lustre_msg_add_flags(req->rq_reqmsg, MSG_RESENT);
 
-	spin_lock(&imp->imp_lock);
 	/* The resend replay request may have been removed from the
 	 * unreplied list.
 	 */
-- 
1.8.3.1
