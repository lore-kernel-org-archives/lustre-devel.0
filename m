Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 63B33C0218F
	for <lustre-devel@archiver.kernel.org>; Sun,  2 Feb 2025 21:09:06 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4YmMHF1dB5z21bq;
	Sun, 02 Feb 2025 12:51:21 -0800 (PST)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4YmMFL6S5Qz210q
 for <lustre-devel@lists.lustre.org>; Sun, 02 Feb 2025 12:49:42 -0800 (PST)
Received: from star2.ccs.ornl.gov (ltm3-e204-208.ccs.ornl.gov [160.91.203.26])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 11FE5182373;
 Sun,  2 Feb 2025 15:46:42 -0500 (EST)
Received: by star2.ccs.ornl.gov (Postfix, from userid 2004)
 id 103F9106BE17; Sun,  2 Feb 2025 15:46:42 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun,  2 Feb 2025 15:46:28 -0500
Message-ID: <20250202204633.1148872-29-jsimmons@infradead.org>
X-Mailer: git-send-email 2.43.5
In-Reply-To: <20250202204633.1148872-1-jsimmons@infradead.org>
References: <20250202204633.1148872-1-jsimmons@infradead.org>
MIME-Version: 1.0
Subject: [lustre-devel] [PATCH 28/33] lustre: ldlm: replace OBD_ -> CFS_
 macros
X-BeenThere: lustre-devel@lists.lustre.org
X-Mailman-Version: 2.1.39
Precedence: list
List-Id: "For discussing Lustre software development."
 <lustre-devel-lustre.org>
List-Unsubscribe: <http://lists.lustre.org/options.cgi/lustre-devel-lustre.org>, 
 <mailto:lustre-devel-request@lists.lustre.org?subject=unsubscribe>
List-Archive: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/>
List-Post: <mailto:lustre-devel@lists.lustre.org>
List-Help: <mailto:lustre-devel-request@lists.lustre.org?subject=help>
List-Subscribe: <http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org>, 
 <mailto:lustre-devel-request@lists.lustre.org?subject=subscribe>
Cc: Arshad Hussain <arshad.hussain@aeoncomputing.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Timothy Day <timday@amazon.com>

Replace OBD macros that are simply redefinitions
of CFS macros.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12610
Lustre-commit: 5770020076b339f82 ("LU-12610 ldlm: replace OBD_ -> CFS_ macros")
Signed-off-by: Timothy Day <timday@amazon.com>
Signed-off-by: Ben Evans <beevans@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/50685
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Arshad Hussain <arshad.hussain@aeoncomputing.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ldlm/ldlm_extent.c   |  2 +-
 fs/lustre/ldlm/ldlm_flock.c    | 16 ++++++++--------
 fs/lustre/ldlm/ldlm_lib.c      |  4 ++--
 fs/lustre/ldlm/ldlm_lock.c     |  6 +++---
 fs/lustre/ldlm/ldlm_lockd.c    | 18 +++++++++---------
 fs/lustre/ldlm/ldlm_request.c  |  8 ++++----
 fs/lustre/ldlm/ldlm_resource.c |  2 +-
 7 files changed, 28 insertions(+), 28 deletions(-)

diff --git a/fs/lustre/ldlm/ldlm_extent.c b/fs/lustre/ldlm/ldlm_extent.c
index 4533bdbe7fb1..15ce512cf10c 100644
--- a/fs/lustre/ldlm/ldlm_extent.c
+++ b/fs/lustre/ldlm/ldlm_extent.c
@@ -168,7 +168,7 @@ void ldlm_extent_add_lock(struct ldlm_resource *res,
 	 */
 	ldlm_resource_add_lock(res, &res->lr_granted, lock);
 
-	if (OBD_FAIL_CHECK(OBD_FAIL_LDLM_GRANT_CHECK)) {
+	if (CFS_FAIL_CHECK(OBD_FAIL_LDLM_GRANT_CHECK)) {
 		struct ldlm_lock *lck;
 
 		list_for_each_entry_reverse(lck, &res->lr_granted,
diff --git a/fs/lustre/ldlm/ldlm_flock.c b/fs/lustre/ldlm/ldlm_flock.c
index 4ca69f8c51e4..4906a075e63a 100644
--- a/fs/lustre/ldlm/ldlm_flock.c
+++ b/fs/lustre/ldlm/ldlm_flock.c
@@ -315,12 +315,12 @@ ldlm_flock_completion_ast(struct ldlm_lock *lock, u64 flags, void *data)
 	struct file_lock *getlk = lock->l_ast_data;
 	int rc = 0;
 
-	OBD_FAIL_TIMEOUT(OBD_FAIL_LDLM_CP_CB_WAIT2, 4);
-	if (OBD_FAIL_PRECHECK(OBD_FAIL_LDLM_CP_CB_WAIT3)) {
+	CFS_FAIL_TIMEOUT(OBD_FAIL_LDLM_CP_CB_WAIT2, 4);
+	if (CFS_FAIL_PRECHECK(OBD_FAIL_LDLM_CP_CB_WAIT3)) {
 		lock_res_and_lock(lock);
 		lock->l_flags |= LDLM_FL_FAIL_LOC;
 		unlock_res_and_lock(lock);
-		OBD_FAIL_TIMEOUT(OBD_FAIL_LDLM_CP_CB_WAIT3, 4);
+		CFS_FAIL_TIMEOUT(OBD_FAIL_LDLM_CP_CB_WAIT3, 4);
 	}
 	CDEBUG(D_DLMTRACE, "flags: 0x%llx data: %p getlk: %p\n",
 	       flags, data, getlk);
@@ -360,22 +360,22 @@ ldlm_flock_completion_ast(struct ldlm_lock *lock, u64 flags, void *data)
 	}
 
 granted:
-	OBD_FAIL_TIMEOUT(OBD_FAIL_LDLM_CP_CB_WAIT, 10);
+	CFS_FAIL_TIMEOUT(OBD_FAIL_LDLM_CP_CB_WAIT, 10);
 
-	if (OBD_FAIL_PRECHECK(OBD_FAIL_LDLM_CP_CB_WAIT4)) {
+	if (CFS_FAIL_PRECHECK(OBD_FAIL_LDLM_CP_CB_WAIT4)) {
 		lock_res_and_lock(lock);
 		/* DEADLOCK is always set with CBPENDING */
 		lock->l_flags |= LDLM_FL_FLOCK_DEADLOCK | LDLM_FL_CBPENDING;
 		unlock_res_and_lock(lock);
-		OBD_FAIL_TIMEOUT(OBD_FAIL_LDLM_CP_CB_WAIT4, 4);
+		CFS_FAIL_TIMEOUT(OBD_FAIL_LDLM_CP_CB_WAIT4, 4);
 	}
-	if (OBD_FAIL_PRECHECK(OBD_FAIL_LDLM_CP_CB_WAIT5)) {
+	if (CFS_FAIL_PRECHECK(OBD_FAIL_LDLM_CP_CB_WAIT5)) {
 		lock_res_and_lock(lock);
 		/* DEADLOCK is always set with CBPENDING */
 		lock->l_flags |= LDLM_FL_FAIL_LOC |
 				 LDLM_FL_FLOCK_DEADLOCK | LDLM_FL_CBPENDING;
 		unlock_res_and_lock(lock);
-		OBD_FAIL_TIMEOUT(OBD_FAIL_LDLM_CP_CB_WAIT5, 4);
+		CFS_FAIL_TIMEOUT(OBD_FAIL_LDLM_CP_CB_WAIT5, 4);
 	}
 
 	lock_res_and_lock(lock);
diff --git a/fs/lustre/ldlm/ldlm_lib.c b/fs/lustre/ldlm/ldlm_lib.c
index 726f70c43e19..c9a10f0d87ea 100644
--- a/fs/lustre/ldlm/ldlm_lib.c
+++ b/fs/lustre/ldlm/ldlm_lib.c
@@ -753,7 +753,7 @@ EXPORT_SYMBOL(target_pack_pool_reply);
 static int
 target_send_reply_msg(struct ptlrpc_request *req, int rc, int fail_id)
 {
-	if (OBD_FAIL_CHECK_ORSET(fail_id & ~OBD_FAIL_ONCE, OBD_FAIL_ONCE)) {
+	if (CFS_FAIL_CHECK_ORSET(fail_id & ~CFS_FAIL_ONCE, CFS_FAIL_ONCE)) {
 		DEBUG_REQ(D_ERROR, req, "dropping reply");
 		return -ECOMM;
 	}
@@ -763,7 +763,7 @@ target_send_reply_msg(struct ptlrpc_request *req, int rc, int fail_id)
 	 */
 	if (req->rq_reqmsg &&
 	    unlikely(lustre_msg_get_opc(req->rq_reqmsg) == MDS_REINT &&
-	    OBD_FAIL_CHECK(OBD_FAIL_MDS_REINT_MULTI_NET_REP)))
+	    CFS_FAIL_CHECK(OBD_FAIL_MDS_REINT_MULTI_NET_REP)))
 		return -ECOMM;
 
 	if (unlikely(rc)) {
diff --git a/fs/lustre/ldlm/ldlm_lock.c b/fs/lustre/ldlm/ldlm_lock.c
index 8659aa5c0cc8..5fcae3864483 100644
--- a/fs/lustre/ldlm/ldlm_lock.c
+++ b/fs/lustre/ldlm/ldlm_lock.c
@@ -790,7 +790,7 @@ void ldlm_lock_decref_internal(struct ldlm_lock *lock, enum ldlm_mode mode)
 		unlock_res_and_lock(lock);
 
 		if (ldlm_is_fail_loc(lock))
-			OBD_RACE(OBD_FAIL_LDLM_CP_BL_RACE);
+			CFS_RACE(OBD_FAIL_LDLM_CP_BL_RACE);
 
 		if (ldlm_is_atomic_cb(lock) ||
 		    ldlm_bl_to_thread_lock(ns, NULL, lock) != 0)
@@ -806,7 +806,7 @@ void ldlm_lock_decref_internal(struct ldlm_lock *lock, enum ldlm_mode mode)
 		LDLM_DEBUG(lock, "add lock into lru list");
 
 		if (ldlm_is_fail_loc(lock))
-			OBD_RACE(OBD_FAIL_LDLM_CP_BL_RACE);
+			CFS_RACE(OBD_FAIL_LDLM_CP_BL_RACE);
 
 		ldlm_pool_recalc(&ns->ns_pool, true);
 	} else {
@@ -1588,7 +1588,7 @@ struct ldlm_lock *ldlm_lock_create(struct ldlm_namespace *ns,
 	}
 
 	lock->l_lvb_type = lvb_type;
-	if (OBD_FAIL_CHECK(OBD_FAIL_LDLM_NEW_LOCK)) {
+	if (CFS_FAIL_CHECK(OBD_FAIL_LDLM_NEW_LOCK)) {
 		rc = -ENOENT;
 		goto out;
 	}
diff --git a/fs/lustre/ldlm/ldlm_lockd.c b/fs/lustre/ldlm/ldlm_lockd.c
index abd853babe1b..a839ff2177d1 100644
--- a/fs/lustre/ldlm/ldlm_lockd.c
+++ b/fs/lustre/ldlm/ldlm_lockd.c
@@ -218,7 +218,7 @@ static int ldlm_handle_cp_callback(struct ptlrpc_request *req,
 
 	LDLM_DEBUG(lock, "client completion callback handler START");
 
-	if (OBD_FAIL_CHECK(OBD_FAIL_LDLM_CANCEL_BL_CB_RACE)) {
+	if (CFS_FAIL_CHECK(OBD_FAIL_LDLM_CANCEL_BL_CB_RACE)) {
 		long to = HZ;
 
 		ldlm_callback_reply(req, 0);
@@ -328,7 +328,7 @@ static int ldlm_handle_cp_callback(struct ptlrpc_request *req,
 	LDLM_DEBUG(lock, "callback handler finished, about to run_ast_work");
 
 	/* Let Enqueue to call osc_lock_upcall() and initialize l_ast_data */
-	OBD_FAIL_TIMEOUT(OBD_FAIL_OSC_CP_ENQ_RACE, 2);
+	CFS_FAIL_TIMEOUT(OBD_FAIL_OSC_CP_ENQ_RACE, 2);
 
 	ldlm_run_ast_work(ns, &ast_list, LDLM_WORK_CP_AST);
 
@@ -625,18 +625,18 @@ static int ldlm_callback_handler(struct ptlrpc_request *req)
 
 	switch (lustre_msg_get_opc(req->rq_reqmsg)) {
 	case LDLM_BL_CALLBACK:
-		if (OBD_FAIL_CHECK(OBD_FAIL_LDLM_BL_CALLBACK_NET)) {
+		if (CFS_FAIL_CHECK(OBD_FAIL_LDLM_BL_CALLBACK_NET)) {
 			if (cfs_fail_err)
 				ldlm_callback_reply(req, -(int)cfs_fail_err);
 			return 0;
 		}
 		break;
 	case LDLM_CP_CALLBACK:
-		if (OBD_FAIL_CHECK(OBD_FAIL_LDLM_CP_CALLBACK_NET))
+		if (CFS_FAIL_CHECK(OBD_FAIL_LDLM_CP_CALLBACK_NET))
 			return 0;
 		break;
 	case LDLM_GL_CALLBACK:
-		if (OBD_FAIL_CHECK(OBD_FAIL_LDLM_GL_CALLBACK_NET))
+		if (CFS_FAIL_CHECK(OBD_FAIL_LDLM_GL_CALLBACK_NET))
 			return 0;
 		break;
 	case LDLM_SET_INFO:
@@ -667,7 +667,7 @@ static int ldlm_callback_handler(struct ptlrpc_request *req)
 	 * Force a known safe race, send a cancel to the server for a lock
 	 * which the server has already started a blocking callback on.
 	 */
-	if (OBD_FAIL_CHECK(OBD_FAIL_LDLM_CANCEL_BL_CB_RACE) &&
+	if (CFS_FAIL_CHECK(OBD_FAIL_LDLM_CANCEL_BL_CB_RACE) &&
 	    lustre_msg_get_opc(req->rq_reqmsg) == LDLM_BL_CALLBACK) {
 		rc = ldlm_cli_cancel(&dlm_req->lock_handle[0], 0);
 		if (rc < 0)
@@ -687,7 +687,7 @@ static int ldlm_callback_handler(struct ptlrpc_request *req)
 
 	if (ldlm_is_fail_loc(lock) &&
 	    lustre_msg_get_opc(req->rq_reqmsg) == LDLM_BL_CALLBACK)
-		OBD_RACE(OBD_FAIL_LDLM_CP_BL_RACE);
+		CFS_RACE(OBD_FAIL_LDLM_CP_BL_RACE);
 
 	/* Copy hints/flags (e.g. LDLM_FL_DISCARD_DATA) from AST. */
 	lock_res_and_lock(lock);
@@ -751,7 +751,7 @@ static int ldlm_callback_handler(struct ptlrpc_request *req)
 		LDLM_DEBUG(lock, "completion ast\n");
 		req_capsule_extend(&req->rq_pill, &RQF_LDLM_CP_CALLBACK);
 		rc = ldlm_handle_cp_callback(req, ns, dlm_req, lock);
-		if (!OBD_FAIL_CHECK(OBD_FAIL_LDLM_CANCEL_BL_CB_RACE))
+		if (!CFS_FAIL_CHECK(OBD_FAIL_LDLM_CANCEL_BL_CB_RACE))
 			ldlm_callback_reply(req, rc);
 		break;
 	case LDLM_GL_CALLBACK:
@@ -879,7 +879,7 @@ static int ldlm_bl_thread_blwi(struct ldlm_bl_pool *blp,
 	if (blwi->blwi_mem_pressure)
 		flags = memalloc_noreclaim_save();
 
-	OBD_FAIL_TIMEOUT(OBD_FAIL_LDLM_PAUSE_CANCEL2, 4);
+	CFS_FAIL_TIMEOUT(OBD_FAIL_LDLM_PAUSE_CANCEL2, 4);
 
 	if (blwi->blwi_count) {
 		int count;
diff --git a/fs/lustre/ldlm/ldlm_request.c b/fs/lustre/ldlm/ldlm_request.c
index 57cf1c075b04..bccce8b8e5e8 100644
--- a/fs/lustre/ldlm/ldlm_request.c
+++ b/fs/lustre/ldlm/ldlm_request.c
@@ -270,7 +270,7 @@ int ldlm_completion_ast(struct ldlm_lock *lock, u64 flags, void *data)
 		conn_cnt = imp->imp_conn_cnt;
 		spin_unlock(&imp->imp_lock);
 	}
-	if (OBD_FAIL_CHECK_RESET(OBD_FAIL_LDLM_INTR_CP_AST,
+	if (CFS_FAIL_CHECK_RESET(OBD_FAIL_LDLM_INTR_CP_AST,
 				 OBD_FAIL_LDLM_CP_BL_RACE | OBD_FAIL_ONCE)) {
 		ldlm_set_fail_loc(lock);
 		rc = -EINTR;
@@ -1026,7 +1026,7 @@ static u64 ldlm_cli_cancel_local(struct ldlm_lock *lock)
 		bool local_only;
 
 		LDLM_DEBUG(lock, "client-side cancel");
-		OBD_FAIL_TIMEOUT(OBD_FAIL_LDLM_PAUSE_CANCEL_LOCAL,
+		CFS_FAIL_TIMEOUT(OBD_FAIL_LDLM_PAUSE_CANCEL_LOCAL,
 				 cfs_fail_val);
 
 		/* Set this flag to prevent others from getting new references*/
@@ -1360,7 +1360,7 @@ int ldlm_cli_cancel(const struct lustre_handle *lockh,
 	unlock_res_and_lock(lock);
 
 	if (flags & LCF_LOCAL)
-		OBD_FAIL_TIMEOUT(OBD_FAIL_LDLM_LOCAL_CANCEL_PAUSE,
+		CFS_FAIL_TIMEOUT(OBD_FAIL_LDLM_LOCAL_CANCEL_PAUSE,
 				 cfs_fail_val);
 
 	rc = ldlm_cli_cancel_local(lock);
@@ -2328,7 +2328,7 @@ static void ldlm_cancel_unused_locks_for_replay(struct ldlm_namespace *ns)
 	       "Dropping as many unused locks as possible before replay for namespace %s (%d)\n",
 	       ldlm_ns_name(ns), ns->ns_nr_unused);
 
-	OBD_FAIL_TIMEOUT(OBD_FAIL_LDLM_REPLAY_PAUSE, cfs_fail_val);
+	CFS_FAIL_TIMEOUT(OBD_FAIL_LDLM_REPLAY_PAUSE, cfs_fail_val);
 
 	/*
 	 * We don't need to care whether or not LRU resize is enabled
diff --git a/fs/lustre/ldlm/ldlm_resource.c b/fs/lustre/ldlm/ldlm_resource.c
index 28f64b6c0c04..7da47976e994 100644
--- a/fs/lustre/ldlm/ldlm_resource.c
+++ b/fs/lustre/ldlm/ldlm_resource.c
@@ -1170,7 +1170,7 @@ ldlm_resource_get(struct ldlm_namespace *ns, const struct ldlm_res_id *name,
 
 	cfs_hash_bd_unlock(ns->ns_rs_hash, &bd, 1);
 
-	OBD_FAIL_TIMEOUT(OBD_FAIL_LDLM_CREATE_RESOURCE, 2);
+	CFS_FAIL_TIMEOUT(OBD_FAIL_LDLM_CREATE_RESOURCE, 2);
 
 	/* Let's see if we happened to be the very first resource in this
 	 * namespace. If so, and this is a client namespace, we need to move
-- 
2.39.3

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
