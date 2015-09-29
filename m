From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Mon, 28 Sep 2015 23:43:48 -0400
Subject: [lustre-devel] [PATCH 05/29] staging/lustre: Remove unused reply
	state batches code
In-Reply-To: <1443498252-1974801-1-git-send-email-green@linuxhacker.ru>
References: <1443498252-1974801-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1443498252-1974801-6-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Oleg Drokin <green@linuxhacker.ru>

rs_batch is used on the server only.

Reported-by: Arnd Bergmann <arnd@arndb.de>
Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/include/lustre_net.h |   6 +-
 drivers/staging/lustre/lustre/ptlrpc/service.c     | 145 ---------------------
 2 files changed, 1 insertion(+), 150 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_net.h b/drivers/staging/lustre/lustre/include/lustre_net.h
index a928631..e7faf0e 100644
--- a/drivers/staging/lustre/lustre/include/lustre_net.h
+++ b/drivers/staging/lustre/lustre/include/lustre_net.h
@@ -429,8 +429,7 @@ struct ptlrpc_reply_state {
 	unsigned long	  rs_on_net:1;   /* reply_out_callback pending? */
 	unsigned long	  rs_prealloc:1; /* rs from prealloc list */
 	unsigned long	  rs_committed:1;/* the transaction was committed
-						 and the rs was dispatched
-						 by ptlrpc_commit_replies */
+					  * and the rs was dispatched */
 	/** Size of the state */
 	int		    rs_size;
 	/** opcode */
@@ -2525,9 +2524,6 @@ struct ptlrpc_service_conf {
  *
  * @{
  */
-void ptlrpc_save_lock(struct ptlrpc_request *req,
-		      struct lustre_handle *lock, int mode, int no_ack);
-void ptlrpc_commit_replies(struct obd_export *exp);
 void ptlrpc_dispatch_difficult_reply(struct ptlrpc_reply_state *rs);
 void ptlrpc_schedule_difficult_reply(struct ptlrpc_reply_state *rs);
 int ptlrpc_hpreq_handler(struct ptlrpc_request *req);
diff --git a/drivers/staging/lustre/lustre/ptlrpc/service.c b/drivers/staging/lustre/lustre/ptlrpc/service.c
index cdc7e62..506fc36 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/service.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/service.c
@@ -179,33 +179,6 @@ ptlrpc_grow_req_bufs(struct ptlrpc_service_part *svcpt, int post)
 	return rc;
 }
 
-/**
- * Part of Rep-Ack logic.
- * Puts a lock and its mode into reply state associated to request reply.
- */
-void
-ptlrpc_save_lock(struct ptlrpc_request *req,
-		 struct lustre_handle *lock, int mode, int no_ack)
-{
-	struct ptlrpc_reply_state *rs = req->rq_reply_state;
-	int idx;
-
-	LASSERT(rs != NULL);
-	LASSERT(rs->rs_nlocks < RS_MAX_LOCKS);
-
-	if (req->rq_export->exp_disconnected) {
-		ldlm_lock_decref(lock, mode);
-	} else {
-		idx = rs->rs_nlocks++;
-		rs->rs_locks[idx] = *lock;
-		rs->rs_modes[idx] = mode;
-		rs->rs_difficult = 1;
-		rs->rs_no_ack = !!no_ack;
-	}
-}
-EXPORT_SYMBOL(ptlrpc_save_lock);
-
-
 struct ptlrpc_hr_partition;
 
 struct ptlrpc_hr_thread {
@@ -246,32 +219,10 @@ struct ptlrpc_hr_service {
 	struct ptlrpc_hr_partition	**hr_partitions;
 };
 
-struct rs_batch {
-	struct list_head			rsb_replies;
-	unsigned int			rsb_n_replies;
-	struct ptlrpc_service_part	*rsb_svcpt;
-};
-
 /** reply handling service. */
 static struct ptlrpc_hr_service		ptlrpc_hr;
 
 /**
- * maximum number of replies scheduled in one batch
- */
-#define MAX_SCHEDULED 256
-
-/**
- * Initialize a reply batch.
- *
- * \param b batch
- */
-static void rs_batch_init(struct rs_batch *b)
-{
-	memset(b, 0, sizeof(*b));
-	INIT_LIST_HEAD(&b->rsb_replies);
-}
-
-/**
  * Choose an hr thread to dispatch requests to.
  */
 static struct ptlrpc_hr_thread *
@@ -297,76 +248,6 @@ ptlrpc_hr_select(struct ptlrpc_service_part *svcpt)
 }
 
 /**
- * Dispatch all replies accumulated in the batch to one from
- * dedicated reply handling threads.
- *
- * \param b batch
- */
-static void rs_batch_dispatch(struct rs_batch *b)
-{
-	if (b->rsb_n_replies != 0) {
-		struct ptlrpc_hr_thread	*hrt;
-
-		hrt = ptlrpc_hr_select(b->rsb_svcpt);
-
-		spin_lock(&hrt->hrt_lock);
-		list_splice_init(&b->rsb_replies, &hrt->hrt_queue);
-		spin_unlock(&hrt->hrt_lock);
-
-		wake_up(&hrt->hrt_waitq);
-		b->rsb_n_replies = 0;
-	}
-}
-
-/**
- * Add a reply to a batch.
- * Add one reply object to a batch, schedule batched replies if overload.
- *
- * \param b batch
- * \param rs reply
- */
-static void rs_batch_add(struct rs_batch *b, struct ptlrpc_reply_state *rs)
-{
-	struct ptlrpc_service_part *svcpt = rs->rs_svcpt;
-
-	if (svcpt != b->rsb_svcpt || b->rsb_n_replies >= MAX_SCHEDULED) {
-		if (b->rsb_svcpt != NULL) {
-			rs_batch_dispatch(b);
-			spin_unlock(&b->rsb_svcpt->scp_rep_lock);
-		}
-		spin_lock(&svcpt->scp_rep_lock);
-		b->rsb_svcpt = svcpt;
-	}
-	spin_lock(&rs->rs_lock);
-	rs->rs_scheduled_ever = 1;
-	if (rs->rs_scheduled == 0) {
-		list_move(&rs->rs_list, &b->rsb_replies);
-		rs->rs_scheduled = 1;
-		b->rsb_n_replies++;
-	}
-	rs->rs_committed = 1;
-	spin_unlock(&rs->rs_lock);
-}
-
-/**
- * Reply batch finalization.
- * Dispatch remaining replies from the batch
- * and release remaining spinlock.
- *
- * \param b batch
- */
-static void rs_batch_fini(struct rs_batch *b)
-{
-	if (b->rsb_svcpt != NULL) {
-		rs_batch_dispatch(b);
-		spin_unlock(&b->rsb_svcpt->scp_rep_lock);
-	}
-}
-
-#define DECLARE_RS_BATCH(b)     struct rs_batch b
-
-
-/**
  * Put reply state into a queue for processing because we received
  * ACK from the client
  */
@@ -403,32 +284,6 @@ ptlrpc_schedule_difficult_reply(struct ptlrpc_reply_state *rs)
 }
 EXPORT_SYMBOL(ptlrpc_schedule_difficult_reply);
 
-void ptlrpc_commit_replies(struct obd_export *exp)
-{
-	struct ptlrpc_reply_state *rs, *nxt;
-	DECLARE_RS_BATCH(batch);
-
-	rs_batch_init(&batch);
-	/* Find any replies that have been committed and get their service
-	 * to attend to complete them. */
-
-	/* CAVEAT EMPTOR: spinlock ordering!!! */
-	spin_lock(&exp->exp_uncommitted_replies_lock);
-	list_for_each_entry_safe(rs, nxt, &exp->exp_uncommitted_replies,
-				     rs_obd_list) {
-		LASSERT(rs->rs_difficult);
-		/* VBR: per-export last_committed */
-		LASSERT(rs->rs_export);
-		if (rs->rs_transno <= exp->exp_last_committed) {
-			list_del_init(&rs->rs_obd_list);
-			rs_batch_add(&batch, rs);
-		}
-	}
-	spin_unlock(&exp->exp_uncommitted_replies_lock);
-	rs_batch_fini(&batch);
-}
-EXPORT_SYMBOL(ptlrpc_commit_replies);
-
 static int
 ptlrpc_server_post_idle_rqbds(struct ptlrpc_service_part *svcpt)
 {
-- 
2.1.0
