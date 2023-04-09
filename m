Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id E545DC77B70
	for <lustre-devel@archiver.kernel.org>; Sun,  9 Apr 2023 12:18:47 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4PvWJ94PCfz1yFH;
	Sun,  9 Apr 2023 05:14:49 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4PvWHD3Tsgz1y7x
 for <lustre-devel@lists.lustre.org>; Sun,  9 Apr 2023 05:14:00 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id D9C571008275;
 Sun,  9 Apr 2023 08:13:27 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id D59DB2AB; Sun,  9 Apr 2023 08:13:27 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun,  9 Apr 2023 08:12:47 -0400
Message-Id: <1681042400-15491-8-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1681042400-15491-1-git-send-email-jsimmons@infradead.org>
References: <1681042400-15491-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 07/40] lustre: ldlm: send the cancel RPC asap
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
Cc: Yang Sheng <ys@whamcloud.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Yang Sheng <ys@whamcloud.com>

This patch try to send cancel RPC ASAP when bl_ast
received from server. The exist problem is that
lock could be added in regular queue before bl_ast
arrived since other reason. It will prevent lock
canceling in timely manner. The other problem is
that we collect many locks in one RPC to save
the network traffic. But this process could take
a long time when dirty pages flushing.

- The lock canceling will be processed even lock has
  been added to bl queue while bl_ast arrived. Unless
  the cancel RPC has been sent.
- Send the cancel RPC immediately for bl_ast lock. Don't
  try to add more locks in such case.

WC-bug-id: https://jira.whamcloud.com/browse/LU-16285
Lustre-commit: b65374d96b2027213 ("LU-16285 ldlm: send the cancel RPC asap")
Signed-off-by: Yang Sheng <ys@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/49527
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Qian Yingjin <qian@ddn.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_dlm.h |   1 +
 fs/lustre/ldlm/ldlm_lockd.c    |   9 ++--
 fs/lustre/ldlm/ldlm_request.c  | 100 ++++++++++++++++++++++++++++-------------
 3 files changed, 75 insertions(+), 35 deletions(-)

diff --git a/fs/lustre/include/lustre_dlm.h b/fs/lustre/include/lustre_dlm.h
index d08c48f..3a4f152 100644
--- a/fs/lustre/include/lustre_dlm.h
+++ b/fs/lustre/include/lustre_dlm.h
@@ -593,6 +593,7 @@ enum ldlm_cancel_flags {
 	LCF_BL_AST     = 0x4, /* Cancel locks marked as LDLM_FL_BL_AST
 			       * in the same RPC
 			       */
+	LCF_ONE_LOCK	= 0x8,	/* Cancel locks pack only one lock. */
 };
 
 struct ldlm_flock {
diff --git a/fs/lustre/ldlm/ldlm_lockd.c b/fs/lustre/ldlm/ldlm_lockd.c
index 0ff4e3a..3a085db 100644
--- a/fs/lustre/ldlm/ldlm_lockd.c
+++ b/fs/lustre/ldlm/ldlm_lockd.c
@@ -700,8 +700,7 @@ static int ldlm_callback_handler(struct ptlrpc_request *req)
 		 * we can tell the server we have no lock. Otherwise, we
 		 * should send cancel after dropping the cache.
 		 */
-		if ((ldlm_is_canceling(lock) && ldlm_is_bl_done(lock)) ||
-		    ldlm_is_failed(lock)) {
+		if (ldlm_is_ast_sent(lock) || ldlm_is_failed(lock)) {
 			LDLM_DEBUG(lock,
 				   "callback on lock %#llx - lock disappeared",
 				   dlm_req->lock_handle[0].cookie);
@@ -736,7 +735,7 @@ static int ldlm_callback_handler(struct ptlrpc_request *req)
 
 	switch (lustre_msg_get_opc(req->rq_reqmsg)) {
 	case LDLM_BL_CALLBACK:
-		CDEBUG(D_INODE, "blocking ast\n");
+		LDLM_DEBUG(lock, "blocking ast\n");
 		req_capsule_extend(&req->rq_pill, &RQF_LDLM_BL_CALLBACK);
 		if (!ldlm_is_cancel_on_block(lock)) {
 			rc = ldlm_callback_reply(req, 0);
@@ -748,14 +747,14 @@ static int ldlm_callback_handler(struct ptlrpc_request *req)
 			ldlm_handle_bl_callback(ns, &dlm_req->lock_desc, lock);
 		break;
 	case LDLM_CP_CALLBACK:
-		CDEBUG(D_INODE, "completion ast\n");
+		LDLM_DEBUG(lock, "completion ast\n");
 		req_capsule_extend(&req->rq_pill, &RQF_LDLM_CP_CALLBACK);
 		rc = ldlm_handle_cp_callback(req, ns, dlm_req, lock);
 		if (!OBD_FAIL_CHECK(OBD_FAIL_LDLM_CANCEL_BL_CB_RACE))
 			ldlm_callback_reply(req, rc);
 		break;
 	case LDLM_GL_CALLBACK:
-		CDEBUG(D_INODE, "glimpse ast\n");
+		LDLM_DEBUG(lock, "glimpse ast\n");
 		req_capsule_extend(&req->rq_pill, &RQF_LDLM_GL_CALLBACK);
 		ldlm_handle_gl_callback(req, ns, dlm_req, lock);
 		break;
diff --git a/fs/lustre/ldlm/ldlm_request.c b/fs/lustre/ldlm/ldlm_request.c
index 8b244d7..ef3ad28 100644
--- a/fs/lustre/ldlm/ldlm_request.c
+++ b/fs/lustre/ldlm/ldlm_request.c
@@ -994,14 +994,34 @@ static u64 ldlm_cli_cancel_local(struct ldlm_lock *lock)
 	return rc;
 }
 
+static inline int __ldlm_pack_lock(struct ldlm_lock *lock,
+				   struct ldlm_request *dlm)
+{
+	LASSERT(lock->l_conn_export);
+	lock_res_and_lock(lock);
+	if (ldlm_is_ast_sent(lock)) {
+		unlock_res_and_lock(lock);
+		return 0;
+	}
+	ldlm_set_ast_sent(lock);
+	unlock_res_and_lock(lock);
+
+	/* Pack the lock handle to the given request buffer. */
+	LDLM_DEBUG(lock, "packing");
+	dlm->lock_handle[dlm->lock_count++] = lock->l_remote_handle;
+
+	return 1;
+}
+#define ldlm_cancel_pack(req, head, count) \
+		_ldlm_cancel_pack(req, NULL, head, count)
+
 /**
  * Pack @count locks in @head into ldlm_request buffer of request @req.
  */
-static void ldlm_cancel_pack(struct ptlrpc_request *req,
+static int _ldlm_cancel_pack(struct ptlrpc_request *req, struct ldlm_lock *lock,
 			     struct list_head *head, int count)
 {
 	struct ldlm_request *dlm;
-	struct ldlm_lock *lock;
 	int max, packed = 0;
 
 	dlm = req_capsule_client_get(&req->rq_pill, &RMF_DLM_REQ);
@@ -1019,24 +1039,23 @@ static void ldlm_cancel_pack(struct ptlrpc_request *req,
 	 * so that the server cancel would call filter_lvbo_update() less
 	 * frequently.
 	 */
-	list_for_each_entry(lock, head, l_bl_ast) {
-		if (!count--)
-			break;
-		LASSERT(lock->l_conn_export);
-		/* Pack the lock handle to the given request buffer. */
-		LDLM_DEBUG(lock, "packing");
-		dlm->lock_handle[dlm->lock_count++] = lock->l_remote_handle;
-		packed++;
+	if (lock) { /* only pack one lock */
+		packed = __ldlm_pack_lock(lock, dlm);
+	} else {
+		list_for_each_entry(lock, head, l_bl_ast) {
+			if (!count--)
+				break;
+			packed += __ldlm_pack_lock(lock, dlm);
+		}
 	}
-	CDEBUG(D_DLMTRACE, "%d locks packed\n", packed);
+	return packed;
 }
 
 /**
  * Prepare and send a batched cancel RPC. It will include @count lock
  * handles of locks given in @cancels list.
  */
-static int ldlm_cli_cancel_req(struct obd_export *exp,
-			       struct list_head *cancels,
+static int ldlm_cli_cancel_req(struct obd_export *exp, void *ptr,
 			       int count, enum ldlm_cancel_flags flags)
 {
 	struct ptlrpc_request *req = NULL;
@@ -1085,7 +1104,15 @@ static int ldlm_cli_cancel_req(struct obd_export *exp,
 		req->rq_reply_portal = LDLM_CANCEL_REPLY_PORTAL;
 		ptlrpc_at_set_req_timeout(req);
 
-		ldlm_cancel_pack(req, cancels, count);
+		if (flags & LCF_ONE_LOCK)
+			rc = _ldlm_cancel_pack(req, ptr, NULL, count);
+		else
+			rc = _ldlm_cancel_pack(req, NULL, ptr, count);
+		if (rc == 0) {
+			ptlrpc_req_finished(req);
+			sent = count;
+			goto out;
+		}
 
 		ptlrpc_request_set_replen(req);
 		if (flags & LCF_ASYNC) {
@@ -1235,10 +1262,10 @@ int ldlm_cli_convert(struct ldlm_lock *lock,
  * Lock must not have any readers or writers by this time.
  */
 int ldlm_cli_cancel(const struct lustre_handle *lockh,
-		    enum ldlm_cancel_flags cancel_flags)
+		    enum ldlm_cancel_flags flags)
 {
 	struct obd_export *exp;
-	int avail, count = 1;
+	int avail, count = 1, bl_ast = 0;
 	u64 rc = 0;
 	struct ldlm_namespace *ns;
 	struct ldlm_lock *lock;
@@ -1253,11 +1280,17 @@ int ldlm_cli_cancel(const struct lustre_handle *lockh,
 	lock_res_and_lock(lock);
 	LASSERT(!ldlm_is_converting(lock));
 
-	/* Lock is being canceled and the caller doesn't want to wait */
-	if (ldlm_is_canceling(lock)) {
+	if (ldlm_is_bl_ast(lock)) {
+		if (ldlm_is_ast_sent(lock)) {
+			unlock_res_and_lock(lock);
+			LDLM_LOCK_RELEASE(lock);
+			return 0;
+		}
+		bl_ast = 1;
+	} else if (ldlm_is_canceling(lock)) {
+		/* Lock is being canceled and the caller doesn't want to wait */
 		unlock_res_and_lock(lock);
-
-		if (!(cancel_flags & LCF_ASYNC))
+		if (flags & LCF_ASYNC)
 			wait_event_idle(lock->l_waitq, is_bl_done(lock));
 
 		LDLM_LOCK_RELEASE(lock);
@@ -1267,24 +1300,30 @@ int ldlm_cli_cancel(const struct lustre_handle *lockh,
 	ldlm_set_canceling(lock);
 	unlock_res_and_lock(lock);
 
-	if (cancel_flags & LCF_LOCAL)
+	if (flags & LCF_LOCAL)
 		OBD_FAIL_TIMEOUT(OBD_FAIL_LDLM_LOCAL_CANCEL_PAUSE,
 				 cfs_fail_val);
 
 	rc = ldlm_cli_cancel_local(lock);
-	if (rc == LDLM_FL_LOCAL_ONLY || cancel_flags & LCF_LOCAL) {
+	if (rc == LDLM_FL_LOCAL_ONLY || flags & LCF_LOCAL) {
 		LDLM_LOCK_RELEASE(lock);
 		return 0;
 	}
-	/*
-	 * Even if the lock is marked as LDLM_FL_BL_AST, this is a LDLM_CANCEL
-	 * RPC which goes to canceld portal, so we can cancel other LRU locks
-	 * here and send them all as one LDLM_CANCEL RPC.
-	 */
-	LASSERT(list_empty(&lock->l_bl_ast));
-	list_add(&lock->l_bl_ast, &cancels);
 
 	exp = lock->l_conn_export;
+	if (bl_ast) { /* Send RPC immedaitly for LDLM_FL_BL_AST */
+		ldlm_cli_cancel_req(exp, lock, count, flags | LCF_ONE_LOCK);
+		LDLM_LOCK_RELEASE(lock);
+		return 0;
+	}
+
+	LASSERT(list_empty(&lock->l_bl_ast));
+	list_add(&lock->l_bl_ast, &cancels);
+	/*
+	 * This is a LDLM_CANCEL RPC which goes to canceld portal,
+	 * so we can cancel other LRU locks here and send them all
+	 * as one LDLM_CANCEL RPC.
+	 */
 	if (exp_connect_cancelset(exp)) {
 		avail = ldlm_format_handles_avail(class_exp2cliimp(exp),
 						  &RQF_LDLM_CANCEL,
@@ -1295,7 +1334,8 @@ int ldlm_cli_cancel(const struct lustre_handle *lockh,
 		count += ldlm_cancel_lru_local(ns, &cancels, 0, avail - 1,
 					       LCF_BL_AST, 0);
 	}
-	ldlm_cli_cancel_list(&cancels, count, NULL, cancel_flags);
+	ldlm_cli_cancel_list(&cancels, count, NULL, flags);
+
 	return 0;
 }
 EXPORT_SYMBOL(ldlm_cli_cancel);
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
