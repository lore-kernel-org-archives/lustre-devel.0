Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 676ECC77B70
	for <lustre-devel@archiver.kernel.org>; Sun,  9 Apr 2023 12:42:55 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4PvWVn21Rxz22Zg;
	Sun,  9 Apr 2023 05:24:01 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4PvWTF30cXz22Xd
 for <lustre-devel@lists.lustre.org>; Sun,  9 Apr 2023 05:22:41 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 651091008491;
 Sun,  9 Apr 2023 08:13:28 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 63D062AB; Sun,  9 Apr 2023 08:13:28 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun,  9 Apr 2023 08:13:15 -0400
Message-Id: <1681042400-15491-36-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1681042400-15491-1-git-send-email-jsimmons@infradead.org>
References: <1681042400-15491-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 35/40] lustre: ldlm: BL_AST lock cancel still
 can be batched
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
Cc: Vitaly Fertman <vitaly.fertman@hpe.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Vitaly Fertman <vitaly.fertman@hpe.com>

The previous patch makes BLAST locks to be cancelled separately.
However the main problem is flushing the data under the other batched
locks, thus still possible to batch it with those with no data.
Could be optimized for not yet CANCELLING locks only, otherwise it is
already in the l_bl_ast list.

Fixes: 1ada5c64 ("lustre: ldlm: send the cancel RPC asap")
WC-bug-id: https://jira.whamcloud.com/browse/LU-16285
Lustre-commit: 9d79f92076b6a9ca7 ("LU-16285 ldlm: BL_AST lock cancel still can be batched")
Signed-off-by: Vitaly Fertman <vitaly.fertman@hpe.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/50158
Reviewed-by: Yang Sheng <ys@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_dlm.h |  1 -
 fs/lustre/ldlm/ldlm_lockd.c    |  3 ++-
 fs/lustre/ldlm/ldlm_request.c  | 42 +++++++++++++++++++++++++-----------------
 3 files changed, 27 insertions(+), 19 deletions(-)

diff --git a/fs/lustre/include/lustre_dlm.h b/fs/lustre/include/lustre_dlm.h
index 3a4f152..d08c48f 100644
--- a/fs/lustre/include/lustre_dlm.h
+++ b/fs/lustre/include/lustre_dlm.h
@@ -593,7 +593,6 @@ enum ldlm_cancel_flags {
 	LCF_BL_AST     = 0x4, /* Cancel locks marked as LDLM_FL_BL_AST
 			       * in the same RPC
 			       */
-	LCF_ONE_LOCK	= 0x8,	/* Cancel locks pack only one lock. */
 };
 
 struct ldlm_flock {
diff --git a/fs/lustre/ldlm/ldlm_lockd.c b/fs/lustre/ldlm/ldlm_lockd.c
index 3a085db..abd853b 100644
--- a/fs/lustre/ldlm/ldlm_lockd.c
+++ b/fs/lustre/ldlm/ldlm_lockd.c
@@ -700,7 +700,8 @@ static int ldlm_callback_handler(struct ptlrpc_request *req)
 		 * we can tell the server we have no lock. Otherwise, we
 		 * should send cancel after dropping the cache.
 		 */
-		if (ldlm_is_ast_sent(lock) || ldlm_is_failed(lock)) {
+		if ((ldlm_is_canceling(lock) && ldlm_is_bl_done(lock)) ||
+		     ldlm_is_failed(lock)) {
 			LDLM_DEBUG(lock,
 				   "callback on lock %#llx - lock disappeared",
 				   dlm_req->lock_handle[0].cookie);
diff --git a/fs/lustre/ldlm/ldlm_request.c b/fs/lustre/ldlm/ldlm_request.c
index ef3ad28..11071d9 100644
--- a/fs/lustre/ldlm/ldlm_request.c
+++ b/fs/lustre/ldlm/ldlm_request.c
@@ -1055,8 +1055,9 @@ static int _ldlm_cancel_pack(struct ptlrpc_request *req, struct ldlm_lock *lock,
  * Prepare and send a batched cancel RPC. It will include @count lock
  * handles of locks given in @cancels list.
  */
-static int ldlm_cli_cancel_req(struct obd_export *exp, void *ptr,
-			       int count, enum ldlm_cancel_flags flags)
+static int ldlm_cli_cancel_req(struct obd_export *exp, struct ldlm_lock *lock,
+			       struct list_head *head, int count,
+			       enum ldlm_cancel_flags flags)
 {
 	struct ptlrpc_request *req = NULL;
 	struct obd_import *imp;
@@ -1065,6 +1066,7 @@ static int ldlm_cli_cancel_req(struct obd_export *exp, void *ptr,
 
 	LASSERT(exp);
 	LASSERT(count > 0);
+	LASSERT(!head || !lock);
 
 	CFS_FAIL_TIMEOUT(OBD_FAIL_LDLM_PAUSE_CANCEL, cfs_fail_val);
 
@@ -1104,10 +1106,7 @@ static int ldlm_cli_cancel_req(struct obd_export *exp, void *ptr,
 		req->rq_reply_portal = LDLM_CANCEL_REPLY_PORTAL;
 		ptlrpc_at_set_req_timeout(req);
 
-		if (flags & LCF_ONE_LOCK)
-			rc = _ldlm_cancel_pack(req, ptr, NULL, count);
-		else
-			rc = _ldlm_cancel_pack(req, NULL, ptr, count);
+		rc = _ldlm_cancel_pack(req, lock, head, count);
 		if (rc == 0) {
 			ptlrpc_req_finished(req);
 			sent = count;
@@ -1265,7 +1264,8 @@ int ldlm_cli_cancel(const struct lustre_handle *lockh,
 		    enum ldlm_cancel_flags flags)
 {
 	struct obd_export *exp;
-	int avail, count = 1, bl_ast = 0;
+	int avail, count = 1, separate = 0;
+	enum ldlm_lru_flags lru_flags = 0;
 	u64 rc = 0;
 	struct ldlm_namespace *ns;
 	struct ldlm_lock *lock;
@@ -1286,7 +1286,8 @@ int ldlm_cli_cancel(const struct lustre_handle *lockh,
 			LDLM_LOCK_RELEASE(lock);
 			return 0;
 		}
-		bl_ast = 1;
+		if (ldlm_is_canceling(lock))
+			separate = 1;
 	} else if (ldlm_is_canceling(lock)) {
 		/* Lock is being canceled and the caller doesn't want to wait */
 		unlock_res_and_lock(lock);
@@ -1308,11 +1309,18 @@ int ldlm_cli_cancel(const struct lustre_handle *lockh,
 	if (rc == LDLM_FL_LOCAL_ONLY || flags & LCF_LOCAL) {
 		LDLM_LOCK_RELEASE(lock);
 		return 0;
+	} else if (rc == LDLM_FL_BL_AST) {
+		/* BL_AST lock must not wait. */
+		lru_flags |= LDLM_LRU_FLAG_NO_WAIT;
 	}
 
 	exp = lock->l_conn_export;
-	if (bl_ast) { /* Send RPC immedaitly for LDLM_FL_BL_AST */
-		ldlm_cli_cancel_req(exp, lock, count, flags | LCF_ONE_LOCK);
+	/* If a lock has been taken from lru for a batched cancel and a later
+	 * BL_AST came, send a CANCEL RPC individually for it right away, not
+	 * waiting for the batch to be handled.
+	 */
+	if (separate) {
+		ldlm_cli_cancel_req(exp, lock, NULL, 1, flags);
 		LDLM_LOCK_RELEASE(lock);
 		return 0;
 	}
@@ -1332,7 +1340,7 @@ int ldlm_cli_cancel(const struct lustre_handle *lockh,
 
 		ns = ldlm_lock_to_ns(lock);
 		count += ldlm_cancel_lru_local(ns, &cancels, 0, avail - 1,
-					       LCF_BL_AST, 0);
+					       LCF_BL_AST, lru_flags);
 	}
 	ldlm_cli_cancel_list(&cancels, count, NULL, flags);
 
@@ -1345,7 +1353,7 @@ int ldlm_cli_cancel(const struct lustre_handle *lockh,
  * Return the number of cancelled locks.
  */
 int ldlm_cli_cancel_list_local(struct list_head *cancels, int count,
-			       enum ldlm_cancel_flags flags)
+			       enum ldlm_cancel_flags cancel_flags)
 {
 	LIST_HEAD(head);
 	struct ldlm_lock *lock, *next;
@@ -1357,7 +1365,7 @@ int ldlm_cli_cancel_list_local(struct list_head *cancels, int count,
 		if (left-- == 0)
 			break;
 
-		if (flags & LCF_LOCAL) {
+		if (cancel_flags & LCF_LOCAL) {
 			rc = LDLM_FL_LOCAL_ONLY;
 			ldlm_lock_cancel(lock);
 		} else {
@@ -1369,7 +1377,7 @@ int ldlm_cli_cancel_list_local(struct list_head *cancels, int count,
 		 * with the LDLM_FL_BL_AST flag in a separate RPC from
 		 * the one being generated now.
 		 */
-		if (!(flags & LCF_BL_AST) && (rc == LDLM_FL_BL_AST)) {
+		if (!(cancel_flags & LCF_BL_AST) && (rc == LDLM_FL_BL_AST)) {
 			LDLM_DEBUG(lock, "Cancel lock separately");
 			list_move(&lock->l_bl_ast, &head);
 			bl_ast++;
@@ -1384,7 +1392,7 @@ int ldlm_cli_cancel_list_local(struct list_head *cancels, int count,
 	}
 	if (bl_ast > 0) {
 		count -= bl_ast;
-		ldlm_cli_cancel_list(&head, bl_ast, NULL, 0);
+		ldlm_cli_cancel_list(&head, bl_ast, NULL, cancel_flags);
 	}
 
 	return count;
@@ -1887,11 +1895,11 @@ int ldlm_cli_cancel_list(struct list_head *cancels, int count,
 				ldlm_cancel_pack(req, cancels, count);
 			else
 				res = ldlm_cli_cancel_req(lock->l_conn_export,
-							  cancels, count,
+							  NULL, cancels, count,
 							  flags);
 		} else {
 			res = ldlm_cli_cancel_req(lock->l_conn_export,
-						  cancels, 1, flags);
+						  NULL, cancels, 1, flags);
 		}
 
 		if (res < 0) {
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
