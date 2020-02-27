From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:09:47 -0500
Subject: [lustre-devel] [PATCH 119/622] lustre: mdc: move RPC semaphore code
 to lustre/osp
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-120-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Andreas Dilger <adilger@whamcloud.com>

The "MDC RPC semaphore" is no longer used by MDC code since patch
http://review.whamcloud.com/14374 "LU-5319 mdc: manage number of
modify RPCs in flight" landed.  It is only still used by the OSP
currently in the OpenSFS branch. While there are plans to remove
this from the OSP as well, it makes sense to move all of this
code from MDC to OSP so that it will also be cleaned up when that
functionality lands.

WC-bug-id: https://jira.whamcloud.com/browse/LU-6864
Lustre-commit: 040ca57f2ebd ("LU-6864 mdc: move RPC semaphore code to lustre/osp")
Signed-off-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/32412
Reviewed-by: Lai Siyao <lai.siyao@whamcloud.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Mike Pershin <mpershin@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_mdc.h  | 96 -----------------------------------------
 fs/lustre/include/obd.h         |  2 -
 fs/lustre/include/obd_support.h |  2 +-
 3 files changed, 1 insertion(+), 99 deletions(-)

diff --git a/fs/lustre/include/lustre_mdc.h b/fs/lustre/include/lustre_mdc.h
index 208989f..aecb6ee 100644
--- a/fs/lustre/include/lustre_mdc.h
+++ b/fs/lustre/include/lustre_mdc.h
@@ -60,102 +60,6 @@
 struct ptlrpc_request;
 struct obd_device;
 
-/**
- * Serializes in-flight MDT-modifying RPC requests to preserve idempotency.
- *
- * This mutex is used to implement execute-once semantics on the MDT.
- * The MDT stores the last transaction ID and result for every client in
- * its last_rcvd file. If the client doesn't get a reply, it can safely
- * resend the request and the MDT will reconstruct the reply being aware
- * that the request has already been executed. Without this lock,
- * execution status of concurrent in-flight requests would be
- * overwritten.
- *
- * This design limits the extent to which we can keep a full pipeline of
- * in-flight requests from a single client.  This limitation could be
- * overcome by allowing multiple slots per client in the last_rcvd file.
- */
-struct mdc_rpc_lock {
-	/** Lock protecting in-flight RPC concurrency. */
-	struct mutex		rpcl_mutex;
-	/** Intent associated with currently executing request. */
-	struct lookup_intent	*rpcl_it;
-	/** Used for MDS/RPC load testing purposes. */
-	int			rpcl_fakes;
-};
-
-#define MDC_FAKE_RPCL_IT ((void *)0x2c0012bfUL)
-
-static inline void mdc_init_rpc_lock(struct mdc_rpc_lock *lck)
-{
-	mutex_init(&lck->rpcl_mutex);
-	lck->rpcl_it = NULL;
-}
-
-static inline void mdc_get_rpc_lock(struct mdc_rpc_lock *lck,
-				    struct lookup_intent *it)
-{
-	if (it && (it->it_op == IT_GETATTR || it->it_op == IT_LOOKUP ||
-		   it->it_op == IT_LAYOUT || it->it_op == IT_READDIR))
-		return;
-
-	/* This would normally block until the existing request finishes.
-	 * If fail_loc is set it will block until the regular request is
-	 * done, then set rpcl_it to MDC_FAKE_RPCL_IT.  Once that is set
-	 * it will only be cleared when all fake requests are finished.
-	 * Only when all fake requests are finished can normal requests
-	 * be sent, to ensure they are recoverable again.
-	 */
-again:
-	mutex_lock(&lck->rpcl_mutex);
-
-	if (CFS_FAIL_CHECK_QUIET(OBD_FAIL_MDC_RPCS_SEM)) {
-		lck->rpcl_it = MDC_FAKE_RPCL_IT;
-		lck->rpcl_fakes++;
-		mutex_unlock(&lck->rpcl_mutex);
-		return;
-	}
-
-	/* This will only happen when the CFS_FAIL_CHECK() was
-	 * just turned off but there are still requests in progress.
-	 * Wait until they finish.  It doesn't need to be efficient
-	 * in this extremely rare case, just have low overhead in
-	 * the common case when it isn't true.
-	 */
-	while (unlikely(lck->rpcl_it == MDC_FAKE_RPCL_IT)) {
-		mutex_unlock(&lck->rpcl_mutex);
-		schedule_timeout_uninterruptible(HZ / 4);
-		goto again;
-	}
-
-	LASSERT(!lck->rpcl_it);
-	lck->rpcl_it = it;
-}
-
-static inline void mdc_put_rpc_lock(struct mdc_rpc_lock *lck,
-				    struct lookup_intent *it)
-{
-	if (it && (it->it_op == IT_GETATTR || it->it_op == IT_LOOKUP ||
-		   it->it_op == IT_LAYOUT || it->it_op == IT_READDIR))
-		return;
-
-	if (lck->rpcl_it == MDC_FAKE_RPCL_IT) { /* OBD_FAIL_MDC_RPCS_SEM */
-		mutex_lock(&lck->rpcl_mutex);
-
-		LASSERTF(lck->rpcl_fakes > 0, "%d\n", lck->rpcl_fakes);
-		lck->rpcl_fakes--;
-
-		if (lck->rpcl_fakes == 0)
-			lck->rpcl_it = NULL;
-
-	} else {
-		LASSERTF(it == lck->rpcl_it, "%p != %p\n", it, lck->rpcl_it);
-		lck->rpcl_it = NULL;
-	}
-
-	mutex_unlock(&lck->rpcl_mutex);
-}
-
 static inline void mdc_get_mod_rpc_slot(struct ptlrpc_request *req,
 					struct lookup_intent *it)
 {
diff --git a/fs/lustre/include/obd.h b/fs/lustre/include/obd.h
index b404391..3910c10 100644
--- a/fs/lustre/include/obd.h
+++ b/fs/lustre/include/obd.h
@@ -304,8 +304,6 @@ struct client_obd {
 	atomic_t		cl_destroy_in_flight;
 	wait_queue_head_t	cl_destroy_waitq;
 
-	struct mdc_rpc_lock     *cl_rpc_lock;
-
 	/* modify rpcs in flight
 	 * currently used for metadata only
 	 */
diff --git a/fs/lustre/include/obd_support.h b/fs/lustre/include/obd_support.h
index 04ef76f..c2db38f 100644
--- a/fs/lustre/include/obd_support.h
+++ b/fs/lustre/include/obd_support.h
@@ -385,7 +385,7 @@
 #define OBD_FAIL_MDC_ENQUEUE_PAUSE			0x801
 #define OBD_FAIL_MDC_OLD_EXT_FLAGS			0x802
 #define OBD_FAIL_MDC_GETATTR_ENQUEUE			0x803
-#define OBD_FAIL_MDC_RPCS_SEM				0x804
+#define OBD_FAIL_MDC_RPCS_SEM				0x804 /* deprecated */
 #define OBD_FAIL_MDC_LIGHTWEIGHT			0x805
 #define OBD_FAIL_MDC_CLOSE				0x806
 #define OBD_FAIL_MDC_MERGE				0x807
-- 
1.8.3.1
