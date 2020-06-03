From: James Simmons <jsimmons@infradead.org>
Date: Tue,  2 Jun 2020 20:59:41 -0400
Subject: [lustre-devel] [PATCH 02/22] lustre: use BIT() macro where
 appropriate in include
In-Reply-To: <1591146001-27171-1-git-send-email-jsimmons@infradead.org>
References: <1591146001-27171-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1591146001-27171-3-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mr NeilBrown <neilb@suse.de>

When accessing a bit in a bitmap/mask/flags-word it can be more
readable to use BIT(num) rather than "1 << num".

This patch makes that change to various places in lustre/include.

WC-bug-id: https://jira.whamcloud.com/browse/LU-6142
Lustre-commit: c438fba7f068b ("LU-6142 lustre: use BIT() macro where appropriate in include")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/38376
Reviewed-by: Olaf Faaland-LLNL <faaland1@llnl.gov>
Reviewed-by: Gian-Carlo DeFazio <defazio1@llnl.gov>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/cl_object.h  | 14 +++++++-------
 fs/lustre/include/lu_object.h  | 36 ++++++++++++++++++------------------
 fs/lustre/include/lustre_dlm.h |  8 ++++----
 fs/lustre/include/lustre_net.h | 32 ++++++++++++++++----------------
 fs/lustre/include/lustre_sec.h | 12 ++++++------
 fs/lustre/include/obd.h        |  2 +-
 6 files changed, 52 insertions(+), 52 deletions(-)

diff --git a/fs/lustre/include/cl_object.h b/fs/lustre/include/cl_object.h
index cde89f67..a0b9e87 100644
--- a/fs/lustre/include/cl_object.h
+++ b/fs/lustre/include/cl_object.h
@@ -176,13 +176,13 @@ struct cl_attr {
  * Fields in cl_attr that are being set.
  */
 enum cl_attr_valid {
-	CAT_SIZE   = 1 << 0,
-	CAT_KMS    = 1 << 1,
-	CAT_MTIME  = 1 << 3,
-	CAT_ATIME  = 1 << 4,
-	CAT_CTIME  = 1 << 5,
-	CAT_BLOCKS = 1 << 6,
-	CAT_UID    = 1 << 7,
+	CAT_SIZE	= BIT(0),
+	CAT_KMS		= BIT(1),
+	CAT_MTIME	= BIT(3),
+	CAT_ATIME	= BIT(4),
+	CAT_CTIME	= BIT(5),
+	CAT_BLOCKS	= BIT(6),
+	CAT_UID		= BIT(7),
 	CAT_GID		= BIT(8),
 	CAT_PROJID	= BIT(9),
 };
diff --git a/fs/lustre/include/lu_object.h b/fs/lustre/include/lu_object.h
index 6886177..2a2f38e 100644
--- a/fs/lustre/include/lu_object.h
+++ b/fs/lustre/include/lu_object.h
@@ -299,11 +299,11 @@ struct lu_device {
  */
 enum lu_device_tag {
 	/** this is meta-data device */
-	LU_DEVICE_MD = (1 << 0),
+	LU_DEVICE_MD	= BIT(0),
 	/** this is data device */
-	LU_DEVICE_DT = (1 << 1),
+	LU_DEVICE_DT	= BIT(1),
 	/** data device in the client stack */
-	LU_DEVICE_CL = (1 << 2)
+	LU_DEVICE_CL	= BIT(2)
 };
 
 /**
@@ -477,8 +477,8 @@ enum lu_object_header_flags {
 };
 
 enum lu_object_header_attr {
-	LOHA_EXISTS	= 1 << 0,
-	LOHA_REMOTE	= 1 << 1,
+	LOHA_EXISTS	= BIT(0),
+	LOHA_REMOTE	= BIT(1),
 	/**
 	 * UNIX file type is stored in S_IFMT bits.
 	 */
@@ -874,7 +874,7 @@ struct lu_rdpg {
 };
 
 enum lu_xattr_flags {
-	LU_XATTR_REPLACE = (1 << 0),
+	LU_XATTR_REPLACE = BIT(0),
 	LU_XATTR_CREATE	 = BIT(1),
 	LU_XATTR_MERGE   = BIT(2),
 	LU_XATTR_SPLIT	 = BIT(3),
@@ -964,36 +964,36 @@ enum lu_context_tag {
 	/**
 	 * Thread on md server
 	 */
-	LCT_MD_THREAD		= 1 << 0,
+	LCT_MD_THREAD		= BIT(0),
 	/**
 	 * Thread on dt server
 	 */
-	LCT_DT_THREAD		= 1 << 1,
+	LCT_DT_THREAD		= BIT(1),
 	/**
 	 * Context for transaction handle
 	 */
-	LCT_TX_HANDLE		= 1 << 2,
+	LCT_TX_HANDLE		= BIT(2),
 	/**
 	 * Thread on client
 	 */
-	LCT_CL_THREAD		= 1 << 3,
+	LCT_CL_THREAD		= BIT(3),
 	/**
 	 * A per-request session on a server, and a per-system-call session on
 	 * a client.
 	 */
-	LCT_SESSION		= 1 << 4,
+	LCT_SESSION		= BIT(4),
 	/**
 	 * A per-request data on OSP device
 	 */
-	LCT_OSP_THREAD		= 1 << 5,
+	LCT_OSP_THREAD		= BIT(5),
 	/**
 	 * MGS device thread
 	 */
-	LCT_MG_THREAD		= 1 << 6,
+	LCT_MG_THREAD		= BIT(6),
 	/**
 	 * Context for local operations
 	 */
-	LCT_LOCAL		= 1 << 7,
+	LCT_LOCAL		= BIT(7),
 	/**
 	 * session for server thread
 	 **/
@@ -1003,20 +1003,20 @@ enum lu_context_tag {
 	 * non-NULL lu_context_key::lct_exit() method. This is used to
 	 * optimize lu_context_exit() call.
 	 */
-	LCT_HAS_EXIT		= 1 << 28,
+	LCT_HAS_EXIT		= BIT(28),
 	/**
 	 * Don't add references for modules creating key values in that context.
 	 * This is only for contexts used internally by lu_object framework.
 	 */
-	LCT_NOREF		= 1 << 29,
+	LCT_NOREF		= BIT(29),
 	/**
 	 * Key is being prepared for retiring, don't create new values for it.
 	 */
-	LCT_QUIESCENT		= 1 << 30,
+	LCT_QUIESCENT		= BIT(30),
 	/**
 	 * Context should be remembered.
 	 */
-	LCT_REMEMBER		= 1 << 31,
+	LCT_REMEMBER		= BIT(31),
 	/**
 	 * Contexts usable in cache shrinker thread.
 	 */
diff --git a/fs/lustre/include/lustre_dlm.h b/fs/lustre/include/lustre_dlm.h
index 174b314..74c380e 100644
--- a/fs/lustre/include/lustre_dlm.h
+++ b/fs/lustre/include/lustre_dlm.h
@@ -91,8 +91,8 @@ enum ldlm_error {
  * first speaking to a server.
  */
 enum ldlm_side {
-	LDLM_NAMESPACE_SERVER = 1 << 0,
-	LDLM_NAMESPACE_CLIENT = 1 << 1
+	LDLM_NAMESPACE_SERVER = 0x01,
+	LDLM_NAMESPACE_CLIENT = 0x02
 };
 
 /**
@@ -293,8 +293,8 @@ struct ldlm_valblock_ops {
  * Greedy means release cached locks aggressively
  */
 enum ldlm_appetite {
-	LDLM_NAMESPACE_GREEDY = 1 << 0,
-	LDLM_NAMESPACE_MODEST = 1 << 1
+	LDLM_NAMESPACE_GREEDY = BIT(0),
+	LDLM_NAMESPACE_MODEST = BIT(1),
 };
 
 struct ldlm_ns_bucket {
diff --git a/fs/lustre/include/lustre_net.h b/fs/lustre/include/lustre_net.h
index cad69a0..a94d826 100644
--- a/fs/lustre/include/lustre_net.h
+++ b/fs/lustre/include/lustre_net.h
@@ -386,8 +386,8 @@ struct ptlrpc_client {
 
 /** state flags of requests */
 /* XXX only ones left are those used by the bulk descs as well! */
-#define PTL_RPC_FL_INTR      (1 << 0)  /* reply wait was interrupted by user */
-#define PTL_RPC_FL_TIMEOUT   (1 << 7)  /* request timed out waiting for reply */
+#define PTL_RPC_FL_INTR      BIT(0)  /* reply wait was interrupted by user */
+#define PTL_RPC_FL_TIMEOUT   BIT(7)  /* request timed out waiting for reply */
 
 #define REQ_MAX_ACK_LOCKS 8
 
@@ -1013,7 +1013,7 @@ static inline bool ptlrpc_nrs_req_can_move(struct ptlrpc_request *req)
 static inline bool lustre_req_swabbed(struct ptlrpc_request *req, size_t index)
 {
 	LASSERT(index < sizeof(req->rq_req_swab_mask) * 8);
-	return req->rq_req_swab_mask & (1 << index);
+	return req->rq_req_swab_mask & BIT(index);
 }
 
 /**
@@ -1022,7 +1022,7 @@ static inline bool lustre_req_swabbed(struct ptlrpc_request *req, size_t index)
 static inline bool lustre_rep_swabbed(struct ptlrpc_request *req, size_t index)
 {
 	LASSERT(index < sizeof(req->rq_rep_swab_mask) * 8);
-	return req->rq_rep_swab_mask & (1 << index);
+	return req->rq_rep_swab_mask & BIT(index);
 }
 
 /**
@@ -1048,8 +1048,8 @@ static inline void lustre_set_req_swabbed(struct ptlrpc_request *req,
 					  size_t index)
 {
 	LASSERT(index < sizeof(req->rq_req_swab_mask) * 8);
-	LASSERT((req->rq_req_swab_mask & (1 << index)) == 0);
-	req->rq_req_swab_mask |= 1 << index;
+	LASSERT((req->rq_req_swab_mask & BIT(index)) == 0);
+	req->rq_req_swab_mask |= BIT(index);
 }
 
 /**
@@ -1059,8 +1059,8 @@ static inline void lustre_set_rep_swabbed(struct ptlrpc_request *req,
 					  size_t index)
 {
 	LASSERT(index < sizeof(req->rq_rep_swab_mask) * 8);
-	LASSERT((req->rq_rep_swab_mask & (1 << index)) == 0);
-	req->rq_rep_swab_mask |= 1 << index;
+	LASSERT((req->rq_rep_swab_mask & BIT(index)) == 0);
+	req->rq_rep_swab_mask |= BIT(index);
 }
 
 /**
@@ -1274,10 +1274,10 @@ struct ptlrpc_bulk_desc {
 };
 
 enum {
-	SVC_STOPPED     = 1 << 0,
-	SVC_STOPPING    = 1 << 1,
-	SVC_STARTING    = 1 << 2,
-	SVC_RUNNING     = 1 << 3,
+	SVC_STOPPED     = BIT(0),
+	SVC_STOPPING    = BIT(1),
+	SVC_STARTING    = BIT(2),
+	SVC_RUNNING     = BIT(3),
 };
 
 #define PTLRPC_THR_NAME_LEN		32
@@ -1694,21 +1694,21 @@ enum ptlrpcd_ctl_flags {
 	/**
 	 * Ptlrpc thread start flag.
 	 */
-	LIOD_START       = 1 << 0,
+	LIOD_START	= BIT(0),
 	/**
 	 * Ptlrpc thread stop flag.
 	 */
-	LIOD_STOP	= 1 << 1,
+	LIOD_STOP	= BIT(1),
 	/**
 	 * Ptlrpc thread force flag (only stop force so far).
 	 * This will cause aborting any inflight rpcs handled
 	 * by thread if LIOD_STOP is specified.
 	 */
-	LIOD_FORCE       = 1 << 2,
+	LIOD_FORCE       = BIT(2),
 	/**
 	 * This is a recovery ptlrpc thread.
 	 */
-	LIOD_RECOVERY    = 1 << 3,
+	LIOD_RECOVERY    = BIT(3),
 };
 
 /**
diff --git a/fs/lustre/include/lustre_sec.h b/fs/lustre/include/lustre_sec.h
index e265868..aec30bc 100644
--- a/fs/lustre/include/lustre_sec.h
+++ b/fs/lustre/include/lustre_sec.h
@@ -467,12 +467,12 @@ struct ptlrpc_ctx_ops {
 #define PTLRPC_CTX_CACHED_BIT		(8)  /* in ctx cache (hash etc.) */
 #define PTLRPC_CTX_ETERNAL_BIT		(9)  /* always valid */
 
-#define PTLRPC_CTX_NEW			(1 << PTLRPC_CTX_NEW_BIT)
-#define PTLRPC_CTX_UPTODATE		(1 << PTLRPC_CTX_UPTODATE_BIT)
-#define PTLRPC_CTX_DEAD			(1 << PTLRPC_CTX_DEAD_BIT)
-#define PTLRPC_CTX_ERROR		(1 << PTLRPC_CTX_ERROR_BIT)
-#define PTLRPC_CTX_CACHED		(1 << PTLRPC_CTX_CACHED_BIT)
-#define PTLRPC_CTX_ETERNAL		(1 << PTLRPC_CTX_ETERNAL_BIT)
+#define PTLRPC_CTX_NEW			BIT(PTLRPC_CTX_NEW_BIT)
+#define PTLRPC_CTX_UPTODATE		BIT(PTLRPC_CTX_UPTODATE_BIT)
+#define PTLRPC_CTX_DEAD			BIT(PTLRPC_CTX_DEAD_BIT)
+#define PTLRPC_CTX_ERROR		BIT(PTLRPC_CTX_ERROR_BIT)
+#define PTLRPC_CTX_CACHED		BIT(PTLRPC_CTX_CACHED_BIT)
+#define PTLRPC_CTX_ETERNAL		BIT(PTLRPC_CTX_ETERNAL_BIT)
 
 #define PTLRPC_CTX_STATUS_MASK	       (PTLRPC_CTX_NEW_BIT	| \
 					PTLRPC_CTX_UPTODATE	| \
diff --git a/fs/lustre/include/obd.h b/fs/lustre/include/obd.h
index bf3273a..0ff19c8 100644
--- a/fs/lustre/include/obd.h
+++ b/fs/lustre/include/obd.h
@@ -702,7 +702,7 @@ enum md_cli_flags {
 	CLI_HASH64		= BIT(2),
 	CLI_API32		= BIT(3),
 	CLI_MIGRATE		= BIT(4),
-	CLI_DIRTY_DATA	= 1 << 5,
+	CLI_DIRTY_DATA		= BIT(5),
 };
 
 enum md_op_code {
-- 
1.8.3.1
