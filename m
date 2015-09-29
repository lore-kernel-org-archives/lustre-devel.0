From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Mon, 28 Sep 2015 23:43:51 -0400
Subject: [lustre-devel] [PATCH 08/29] staging/lustre: Remove unused
	ptlrpcd_add_rqset()
In-Reply-To: <1443498252-1974801-1-git-send-email-green@linuxhacker.ru>
References: <1443498252-1974801-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1443498252-1974801-9-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Oleg Drokin <green@linuxhacker.ru>

No point in retaining it if it's unused.

Reported-by: Arnd Bergmann <arnd@arndb.de>
Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/include/lustre_net.h |  1 -
 drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c     | 42 ----------------------
 2 files changed, 43 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_net.h b/drivers/staging/lustre/lustre/include/lustre_net.h
index 090484b..6df3e70 100644
--- a/drivers/staging/lustre/lustre/include/lustre_net.h
+++ b/drivers/staging/lustre/lustre/include/lustre_net.h
@@ -2902,7 +2902,6 @@ void ptlrpcd_stop(struct ptlrpcd_ctl *pc, int force);
 void ptlrpcd_free(struct ptlrpcd_ctl *pc);
 void ptlrpcd_wake(struct ptlrpc_request *req);
 void ptlrpcd_add_req(struct ptlrpc_request *req);
-void ptlrpcd_add_rqset(struct ptlrpc_request_set *set);
 int ptlrpcd_addref(void);
 void ptlrpcd_decref(void);
 
diff --git a/drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c b/drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c
index 00efdbf..ce036a1 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c
@@ -196,48 +196,6 @@ ptlrpcd_select_pc(struct ptlrpc_request *req)
 }
 
 /**
- * Move all request from an existing request set to the ptlrpcd queue.
- * All requests from the set must be in phase RQ_PHASE_NEW.
- */
-void ptlrpcd_add_rqset(struct ptlrpc_request_set *set)
-{
-	struct list_head *tmp, *pos;
-	struct ptlrpcd_ctl *pc;
-	struct ptlrpc_request_set *new;
-	int count, i;
-
-	pc = ptlrpcd_select_pc(NULL);
-	new = pc->pc_set;
-
-	list_for_each_safe(pos, tmp, &set->set_requests) {
-		struct ptlrpc_request *req =
-			list_entry(pos, struct ptlrpc_request,
-				       rq_set_chain);
-
-		LASSERT(req->rq_phase == RQ_PHASE_NEW);
-		req->rq_set = new;
-		req->rq_queued_time = cfs_time_current();
-	}
-
-	spin_lock(&new->set_new_req_lock);
-	list_splice_init(&set->set_requests, &new->set_new_requests);
-	i = atomic_read(&set->set_remaining);
-	count = atomic_add_return(i, &new->set_new_count);
-	atomic_set(&set->set_remaining, 0);
-	spin_unlock(&new->set_new_req_lock);
-	if (count == i) {
-		wake_up(&new->set_waitq);
-
-		/* XXX: It maybe unnecessary to wakeup all the partners. But to
-		 *      guarantee the async RPC can be processed ASAP, we have
-		 *      no other better choice. It maybe fixed in future. */
-		for (i = 0; i < pc->pc_npartners; i++)
-			wake_up(&pc->pc_partners[i]->pc_set->set_waitq);
-	}
-}
-EXPORT_SYMBOL(ptlrpcd_add_rqset);
-
-/**
  * Return transferred RPCs count.
  */
 static int ptlrpcd_steal_rqset(struct ptlrpc_request_set *des,
-- 
2.1.0
