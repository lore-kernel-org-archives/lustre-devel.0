From: James Simmons <jsimmons@infradead.org>
Date: Sun, 21 Jul 2019 22:12:21 -0400
Subject: [lustre-devel] [PATCH 09/10] lustre: ptlrpc: make ptlrpc_last_xid
 an atomic64_t
In-Reply-To: <1563761542-3708-1-git-send-email-jsimmons@infradead.org>
References: <1563761542-3708-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1563761542-3708-10-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: NeilBrown <neilb@suse.com>

This variable is treated like an atomic64_t,
so change it's type and simplify the code.

Signed-off-by: NeilBrown <neilb@suse.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-4423
Reviewed-on: https://review.whamcloud.com/35510
Reviewed-by: Shaun Tancheff <stancheff@cray.com>
Reviewed-by: Petros Koutoupis <pkoutoupis@cray.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ptlrpc/client.c | 39 ++++++++++-----------------------------
 1 file changed, 10 insertions(+), 29 deletions(-)

diff --git a/fs/lustre/ptlrpc/client.c b/fs/lustre/ptlrpc/client.c
index 5f3dc3f..5c0a3ec 100644
--- a/fs/lustre/ptlrpc/client.c
+++ b/fs/lustre/ptlrpc/client.c
@@ -3062,8 +3062,7 @@ void ptlrpc_abort_set(struct ptlrpc_request_set *set)
 	}
 }
 
-static u64 ptlrpc_last_xid;
-static spinlock_t ptlrpc_last_xid_lock;
+static atomic64_t ptlrpc_last_xid;
 
 /**
  * Initialize the XID for the node.  This is common among all requests on
@@ -3084,19 +3083,20 @@ void ptlrpc_abort_set(struct ptlrpc_request_set *set)
 void ptlrpc_init_xid(void)
 {
 	time64_t now = ktime_get_real_seconds();
+	u64 xid;
 
-	spin_lock_init(&ptlrpc_last_xid_lock);
 	if (now < YEAR_2004) {
-		get_random_bytes(&ptlrpc_last_xid, sizeof(ptlrpc_last_xid));
-		ptlrpc_last_xid >>= 2;
-		ptlrpc_last_xid |= (1ULL << 61);
+		get_random_bytes(&xid, sizeof(xid));
+		xid >>= 2;
+		xid |= (1ULL << 61);
 	} else {
-		ptlrpc_last_xid = (u64)now << 20;
+		xid = (u64)now << 20;
 	}
 
 	/* Always need to be aligned to a power-of-two for multi-bulk BRW */
 	BUILD_BUG_ON(((PTLRPC_BULK_OPS_COUNT - 1) & PTLRPC_BULK_OPS_COUNT) != 0);
-	ptlrpc_last_xid &= PTLRPC_BULK_OPS_MASK;
+	xid &= PTLRPC_BULK_OPS_MASK;
+	atomic64_set(&ptlrpc_last_xid, xid);
 }
 
 /**
@@ -3113,14 +3113,7 @@ void ptlrpc_init_xid(void)
  */
 u64 ptlrpc_next_xid(void)
 {
-	u64 next;
-
-	spin_lock(&ptlrpc_last_xid_lock);
-	next = ptlrpc_last_xid + PTLRPC_BULK_OPS_COUNT;
-	ptlrpc_last_xid = next;
-	spin_unlock(&ptlrpc_last_xid_lock);
-
-	return next;
+	return atomic64_add_return(PTLRPC_BULK_OPS_COUNT, &ptlrpc_last_xid);
 }
 
 /**
@@ -3195,19 +3188,7 @@ void ptlrpc_set_bulk_mbits(struct ptlrpc_request *req)
  */
 u64 ptlrpc_sample_next_xid(void)
 {
-#if BITS_PER_LONG == 32
-	/* need to avoid possible word tearing on 32-bit systems */
-	u64 next;
-
-	spin_lock(&ptlrpc_last_xid_lock);
-	next = ptlrpc_last_xid + PTLRPC_BULK_OPS_COUNT;
-	spin_unlock(&ptlrpc_last_xid_lock);
-
-	return next;
-#else
-	/* No need to lock, since returned value is racy anyways */
-	return ptlrpc_last_xid + PTLRPC_BULK_OPS_COUNT;
-#endif
+	return atomic64_read(&ptlrpc_last_xid) + PTLRPC_BULK_OPS_COUNT;
 }
 EXPORT_SYMBOL(ptlrpc_sample_next_xid);
 
-- 
1.8.3.1
