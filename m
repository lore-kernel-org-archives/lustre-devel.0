Return-Path: <SRS0=NZgA=GY=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 50E06C433E0
	for <lustre-devel@archiver.kernel.org>; Thu, 21 Jan 2021 17:18:37 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id E63C823A5B
	for <lustre-devel@archiver.kernel.org>; Thu, 21 Jan 2021 17:18:36 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E63C823A5B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 4D52221FCB2;
	Thu, 21 Jan 2021 09:17:57 -0800 (PST)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id B5BA921FC28
 for <lustre-devel@lists.lustre.org>; Thu, 21 Jan 2021 09:17:13 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 72275100848C;
 Thu, 21 Jan 2021 12:17:05 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 714F11B49E; Thu, 21 Jan 2021 12:17:05 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Thu, 21 Jan 2021 12:16:51 -0500
Message-Id: <1611249422-556-29-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1611249422-556-1-git-send-email-jsimmons@infradead.org>
References: <1611249422-556-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 28/39] lustre: dom: non-blocking enqueue for
 DOM locks
X-BeenThere: lustre-devel@lists.lustre.org
X-Mailman-Version: 2.1.23
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
Cc: Mikhail Pershin <mpershin@whamcloud.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Mikhail Pershin <mpershin@whamcloud.com>

DOM lock enqueue waits for blocking locks on MDT due to
ATOMIC flag, so MDT thread is blocked until lock is granted.
When many clients attempt to write to shared file that may
cause server thread starvation and lock contention. Switch
to non-atomic lock enqueue for DOM locks.

- switch IO lock to non-intent enqueue, so it doesn't consume
  server thread for a long time being blocked
- on client take LVB from l_lvb_data updated by completion AST and
  update l_ost_lvb used by DoM
- make glimpse performing similarly on MDT and OST, it uses one
  format with no intent buffer and return data in LVB buffer
- introduce new connect flag 'dom_lvb' for compatibility reasons
- on server handle glimpse for both old and new clients by filling
  either LVB reply buffer or mdt_body buffer
- don't take RPC slot for a DOM enqueue like it is done for EXTENT
  locks, update ldlm_cli_enqueue_fini() to accept ldlm_enqueue_info
  as parameter
- check that there is no atomic local lock issued with mandatory DOM
  bit, trybits should be used

WC-bug-id: https://jira.whamcloud.com/browse/LU-10664
Lustre-commit: 3c75d2522786a2a ("LU-10664 dom: non-blocking enqueue for DOM locks")
Signed-off-by: Mikhail Pershin <mpershin@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/36903
Reviewed-by: Vitaly Fertman <vitaly.fertman@hpe.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_dlm.h         |   3 +-
 fs/lustre/include/lustre_export.h      |   5 ++
 fs/lustre/ldlm/ldlm_request.c          |  66 +++++++--------
 fs/lustre/llite/llite_lib.c            |   3 +-
 fs/lustre/mdc/mdc_dev.c                | 144 +++++++++++++++++++--------------
 fs/lustre/mdc/mdc_internal.h           |  10 +++
 fs/lustre/mdc/mdc_locks.c              |   9 ++-
 fs/lustre/obdclass/lprocfs_status.c    |   1 +
 fs/lustre/osc/osc_request.c            |  39 ++-------
 fs/lustre/ptlrpc/wiretest.c            |   2 +
 include/uapi/linux/lustre/lustre_idl.h |   1 +
 11 files changed, 147 insertions(+), 136 deletions(-)

diff --git a/fs/lustre/include/lustre_dlm.h b/fs/lustre/include/lustre_dlm.h
index e4c95a2..8156f75 100644
--- a/fs/lustre/include/lustre_dlm.h
+++ b/fs/lustre/include/lustre_dlm.h
@@ -1341,8 +1341,7 @@ int ldlm_prep_elc_req(struct obd_export *exp,
 
 struct ptlrpc_request *ldlm_enqueue_pack(struct obd_export *exp, int lvb_len);
 int ldlm_cli_enqueue_fini(struct obd_export *exp, struct ptlrpc_request *req,
-			  enum ldlm_type type, u8 with_policy,
-			  enum ldlm_mode mode,
+			  struct ldlm_enqueue_info *einfo, u8 with_policy,
 			  u64 *flags, void *lvb, u32 lvb_len,
 			  const struct lustre_handle *lockh, int rc);
 int ldlm_cli_convert_req(struct ldlm_lock *lock, u32 *flags, u64 new_bits);
diff --git a/fs/lustre/include/lustre_export.h b/fs/lustre/include/lustre_export.h
index ed49a97..4cc88ef 100644
--- a/fs/lustre/include/lustre_export.h
+++ b/fs/lustre/include/lustre_export.h
@@ -290,6 +290,11 @@ static inline int exp_connect_lseek(struct obd_export *exp)
 	return !!(exp_connect_flags2(exp) & OBD_CONNECT2_LSEEK);
 }
 
+static inline int exp_connect_dom_lvb(struct obd_export *exp)
+{
+	return !!(exp_connect_flags2(exp) & OBD_CONNECT2_DOM_LVB);
+}
+
 enum {
 	/* archive_ids in array format */
 	KKUC_CT_DATA_ARRAY_MAGIC	= 0x092013cea,
diff --git a/fs/lustre/ldlm/ldlm_request.c b/fs/lustre/ldlm/ldlm_request.c
index 86b10a7..1c2ecf2 100644
--- a/fs/lustre/ldlm/ldlm_request.c
+++ b/fs/lustre/ldlm/ldlm_request.c
@@ -355,9 +355,12 @@ static void failed_lock_cleanup(struct ldlm_namespace *ns,
 	}
 }
 
-static bool ldlm_request_slot_needed(enum ldlm_type type)
+static bool ldlm_request_slot_needed(struct ldlm_enqueue_info *einfo)
 {
-	return type == LDLM_FLOCK || type == LDLM_IBITS;
+	/* exclude EXTENT locks and DOM-only IBITS locks because they
+	 * are asynchronous and don't wait on server being blocked.
+	 */
+	return einfo->ei_type == LDLM_FLOCK || einfo->ei_type == LDLM_IBITS;
 }
 
 /**
@@ -366,19 +369,19 @@ static bool ldlm_request_slot_needed(enum ldlm_type type)
  * Called after receiving reply from server.
  */
 int ldlm_cli_enqueue_fini(struct obd_export *exp, struct ptlrpc_request *req,
-			  enum ldlm_type type, u8 with_policy,
-			  enum ldlm_mode mode,
-			  u64 *flags, void *lvb, u32 lvb_len,
-			  const struct lustre_handle *lockh, int rc)
+			  struct ldlm_enqueue_info *einfo,
+			  u8 with_policy, u64 *ldlm_flags, void *lvb,
+			  u32 lvb_len, const struct lustre_handle *lockh,
+			  int rc)
 {
 	struct ldlm_namespace *ns = exp->exp_obd->obd_namespace;
 	const struct lu_env *env = NULL;
-	int is_replay = *flags & LDLM_FL_REPLAY;
+	int is_replay = *ldlm_flags & LDLM_FL_REPLAY;
 	struct ldlm_lock *lock;
 	struct ldlm_reply *reply;
 	int cleanup_phase = 1;
 
-	if (ldlm_request_slot_needed(type))
+	if (ldlm_request_slot_needed(einfo))
 		obd_put_request_slot(&req->rq_import->imp_obd->u.cli);
 
 	ptlrpc_put_mod_rpc_slot(req);
@@ -386,7 +389,7 @@ int ldlm_cli_enqueue_fini(struct obd_export *exp, struct ptlrpc_request *req,
 	lock = ldlm_handle2lock(lockh);
 	/* ldlm_cli_enqueue is holding a reference on this lock. */
 	if (!lock) {
-		LASSERT(type == LDLM_FLOCK);
+		LASSERT(einfo->ei_type == LDLM_FLOCK);
 		return -ENOLCK;
 	}
 
@@ -443,20 +446,20 @@ int ldlm_cli_enqueue_fini(struct obd_export *exp, struct ptlrpc_request *req,
 	lock_res_and_lock(lock);
 	lock->l_remote_handle = reply->lock_handle;
 
-	*flags = ldlm_flags_from_wire(reply->lock_flags);
+	*ldlm_flags = ldlm_flags_from_wire(reply->lock_flags);
 	lock->l_flags |= ldlm_flags_from_wire(reply->lock_flags &
 					      LDLM_FL_INHERIT_MASK);
 	unlock_res_and_lock(lock);
 
 	CDEBUG(D_INFO, "local: %p, remote cookie: %#llx, flags: 0x%llx\n",
-	       lock, reply->lock_handle.cookie, *flags);
+	       lock, reply->lock_handle.cookie, *ldlm_flags);
 
 	/*
 	 * If enqueue returned a blocked lock but the completion handler has
 	 * already run, then it fixed up the resource and we don't need to do it
 	 * again.
 	 */
-	if ((*flags) & LDLM_FL_LOCK_CHANGED) {
+	if ((*ldlm_flags) & LDLM_FL_LOCK_CHANGED) {
 		int newmode = reply->lock_desc.l_req_mode;
 
 		LASSERT(!is_replay);
@@ -490,12 +493,12 @@ int ldlm_cli_enqueue_fini(struct obd_export *exp, struct ptlrpc_request *req,
 						     &lock->l_policy_data);
 		}
 
-		if (type != LDLM_PLAIN)
+		if (einfo->ei_type != LDLM_PLAIN)
 			LDLM_DEBUG(lock,
 				   "client-side enqueue, new policy data");
 	}
 
-	if ((*flags) & LDLM_FL_AST_SENT) {
+	if ((*ldlm_flags) & LDLM_FL_AST_SENT) {
 		lock_res_and_lock(lock);
 		ldlm_bl_desc2lock(&reply->lock_desc, lock);
 		lock->l_flags |= LDLM_FL_CBPENDING |  LDLM_FL_BL_AST;
@@ -526,9 +529,10 @@ int ldlm_cli_enqueue_fini(struct obd_export *exp, struct ptlrpc_request *req,
 	}
 
 	if (!is_replay) {
-		rc = ldlm_lock_enqueue(env, ns, &lock, NULL, flags);
+		rc = ldlm_lock_enqueue(env, ns, &lock, NULL, ldlm_flags);
 		if (lock->l_completion_ast) {
-			int err = lock->l_completion_ast(lock, *flags, NULL);
+			int err = lock->l_completion_ast(lock, *ldlm_flags,
+							 NULL);
 
 			if (!rc)
 				rc = err;
@@ -548,7 +552,7 @@ int ldlm_cli_enqueue_fini(struct obd_export *exp, struct ptlrpc_request *req,
 	LDLM_DEBUG(lock, "client-side enqueue END");
 cleanup:
 	if (cleanup_phase == 1 && rc)
-		failed_lock_cleanup(ns, lock, mode);
+		failed_lock_cleanup(ns, lock, einfo->ei_mode);
 	/* Put lock 2 times, the second reference is held by ldlm_cli_enqueue */
 	LDLM_LOCK_PUT(lock);
 	LDLM_LOCK_RELEASE(lock);
@@ -811,24 +815,15 @@ int ldlm_cli_enqueue(struct obd_export *exp, struct ptlrpc_request **reqp,
 
 	/* extended LDLM opcodes in client stats */
 	if (exp->exp_obd->obd_svc_stats != NULL) {
-		bool glimpse = *flags & LDLM_FL_HAS_INTENT;
-
-		/* OST glimpse has no intent buffer */
-		if (req_capsule_has_field(&req->rq_pill, &RMF_LDLM_INTENT,
-					  RCL_CLIENT)) {
-			struct ldlm_intent *it;
-
-			it = req_capsule_client_get(&req->rq_pill,
-						    &RMF_LDLM_INTENT);
-			glimpse = (it && (it->opc == IT_GLIMPSE));
-		}
-
-		if (!glimpse)
-			ldlm_svc_get_eopc(body, exp->exp_obd->obd_svc_stats);
-		else
+		/* glimpse is intent with no intent buffer */
+		if (*flags & LDLM_FL_HAS_INTENT &&
+		    !req_capsule_has_field(&req->rq_pill, &RMF_LDLM_INTENT,
+					   RCL_CLIENT))
 			lprocfs_counter_incr(exp->exp_obd->obd_svc_stats,
 					     PTLRPC_LAST_CNTR +
 					     LDLM_GLIMPSE_ENQUEUE);
+		else
+			ldlm_svc_get_eopc(body, exp->exp_obd->obd_svc_stats);
 	}
 
 	/* It is important to obtain modify RPC slot first (if applicable), so
@@ -838,7 +833,7 @@ int ldlm_cli_enqueue(struct obd_export *exp, struct ptlrpc_request **reqp,
 	if (einfo->ei_enq_slot)
 		ptlrpc_get_mod_rpc_slot(req);
 
-	if (ldlm_request_slot_needed(einfo->ei_type)) {
+	if (ldlm_request_slot_needed(einfo)) {
 		rc = obd_get_request_slot(&req->rq_import->imp_obd->u.cli);
 		if (rc) {
 			if (einfo->ei_enq_slot)
@@ -858,9 +853,8 @@ int ldlm_cli_enqueue(struct obd_export *exp, struct ptlrpc_request **reqp,
 
 	rc = ptlrpc_queue_wait(req);
 
-	err = ldlm_cli_enqueue_fini(exp, req, einfo->ei_type, policy ? 1 : 0,
-				    einfo->ei_mode, flags, lvb, lvb_len,
-				    lockh, rc);
+	err = ldlm_cli_enqueue_fini(exp, req, einfo, policy ? 1 : 0, flags,
+				    lvb, lvb_len, lockh, rc);
 
 	/*
 	 * If ldlm_cli_enqueue_fini did not find the lock, we need to free
diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index 570d51a..3139669 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -265,7 +265,8 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt)
 				   OBD_CONNECT2_ASYNC_DISCARD |
 				   OBD_CONNECT2_PCC |
 				   OBD_CONNECT2_CRUSH | OBD_CONNECT2_LSEEK |
-				   OBD_CONNECT2_GETATTR_PFID;
+				   OBD_CONNECT2_GETATTR_PFID |
+				   OBD_CONNECT2_DOM_LVB;
 
 	if (sbi->ll_flags & LL_SBI_LRU_RESIZE)
 		data->ocd_connect_flags |= OBD_CONNECT_LRU_RESIZE;
diff --git a/fs/lustre/mdc/mdc_dev.c b/fs/lustre/mdc/mdc_dev.c
index 214fd31..e86e69d 100644
--- a/fs/lustre/mdc/mdc_dev.c
+++ b/fs/lustre/mdc/mdc_dev.c
@@ -294,20 +294,16 @@ void mdc_lock_lockless_cancel(const struct lu_env *env,
  * Helper for osc_dlm_blocking_ast() handling discrepancies between cl_lock
  * and ldlm_lock caches.
  */
-static int mdc_dlm_blocking_ast0(const struct lu_env *env,
-				 struct ldlm_lock *dlmlock,
-				 int flag)
+static int mdc_dlm_canceling(const struct lu_env *env,
+			     struct ldlm_lock *dlmlock)
 {
 	struct cl_object *obj = NULL;
 	int result = 0;
 	bool discard;
 	enum cl_lock_mode mode = CLM_READ;
 
-	LASSERT(flag == LDLM_CB_CANCELING);
-	LASSERT(dlmlock);
-
 	lock_res_and_lock(dlmlock);
-	if (dlmlock->l_granted_mode != dlmlock->l_req_mode) {
+	if (!ldlm_is_granted(dlmlock)) {
 		dlmlock->l_ast_data = NULL;
 		unlock_res_and_lock(dlmlock);
 		return 0;
@@ -349,11 +345,11 @@ static int mdc_dlm_blocking_ast0(const struct lu_env *env,
 }
 
 int mdc_ldlm_blocking_ast(struct ldlm_lock *dlmlock,
-			  struct ldlm_lock_desc *new, void *data, int flag)
+			  struct ldlm_lock_desc *new, void *data, int reason)
 {
 	int rc = 0;
 
-	switch (flag) {
+	switch (reason) {
 	case LDLM_CB_BLOCKING: {
 		struct lustre_handle lockh;
 
@@ -384,7 +380,7 @@ int mdc_ldlm_blocking_ast(struct ldlm_lock *dlmlock,
 			break;
 		}
 
-		rc = mdc_dlm_blocking_ast0(env, dlmlock, flag);
+		rc = mdc_dlm_canceling(env, dlmlock);
 		cl_env_put(env, &refcheck);
 		break;
 	}
@@ -430,6 +426,7 @@ void mdc_lock_lvb_update(const struct lu_env *env, struct osc_object *osc,
 			attr->cat_kms = size;
 			setkms = 1;
 		}
+		ldlm_lock_allow_match_locked(dlmlock);
 	}
 
 	/* The size should not be less than the kms */
@@ -479,7 +476,7 @@ static void mdc_lock_granted(const struct lu_env *env, struct osc_lock *oscl,
 
 	/* Lock must have been granted. */
 	lock_res_and_lock(dlmlock);
-	if (dlmlock->l_granted_mode == dlmlock->l_req_mode) {
+	if (ldlm_is_granted(dlmlock)) {
 		struct cl_lock_descr *descr = &oscl->ols_cl.cls_lock->cll_descr;
 
 		/* extend the lock extent, otherwise it will have problem when
@@ -505,7 +502,7 @@ static void mdc_lock_granted(const struct lu_env *env, struct osc_lock *oscl,
 
 /**
  * Lock upcall function that is executed either when a reply to ENQUEUE rpc is
- * received from a server, or after osc_enqueue_base() matched a local DLM
+ * received from a server, or after mdc_enqueue_base() matched a local DLM
  * lock.
  */
 static int mdc_lock_upcall(void *cookie, struct lustre_handle *lockh,
@@ -561,51 +558,64 @@ static int mdc_lock_upcall(void *cookie, struct lustre_handle *lockh,
 	return rc;
 }
 
+/* This is needed only for old servers (before 2.14) support */
 int mdc_fill_lvb(struct ptlrpc_request *req, struct ost_lvb *lvb)
 {
 	struct mdt_body *body;
 
+	/* get LVB data from mdt_body otherwise */
 	body = req_capsule_server_get(&req->rq_pill, &RMF_MDT_BODY);
 	if (!body)
 		return -EPROTO;
 
-	lvb->lvb_mtime = body->mbo_mtime;
-	lvb->lvb_atime = body->mbo_atime;
-	lvb->lvb_ctime = body->mbo_ctime;
-	lvb->lvb_blocks = body->mbo_dom_blocks;
-	lvb->lvb_size = body->mbo_dom_size;
+	if (!(body->mbo_valid & OBD_MD_DOM_SIZE))
+		return -EPROTO;
 
+	mdc_body2lvb(body, lvb);
 	return 0;
 }
 
-int mdc_enqueue_fini(struct ptlrpc_request *req, osc_enqueue_upcall_f upcall,
-		     void *cookie, struct lustre_handle *lockh,
-		     enum ldlm_mode mode, u64 *flags, int errcode)
+int mdc_enqueue_fini(struct obd_export *exp, struct ptlrpc_request *req,
+		     osc_enqueue_upcall_f upcall, void *cookie,
+		     struct lustre_handle *lockh, enum ldlm_mode mode,
+		     u64 *flags, int errcode)
 {
 	struct osc_lock *ols = cookie;
-	struct ldlm_lock *lock;
+	bool glimpse = *flags & LDLM_FL_HAS_INTENT;
 	int rc = 0;
 
-	/* The request was created before ldlm_cli_enqueue call. */
-	if (errcode == ELDLM_LOCK_ABORTED) {
+	/* needed only for glimpse from an old server (< 2.14) */
+	if (glimpse && !exp_connect_dom_lvb(exp))
+		rc = mdc_fill_lvb(req, &ols->ols_lvb);
+
+	if (glimpse && errcode == ELDLM_LOCK_ABORTED) {
 		struct ldlm_reply *rep;
 
 		rep = req_capsule_server_get(&req->rq_pill, &RMF_DLM_REP);
-		LASSERT(rep);
-
-		rep->lock_policy_res2 =
-			ptlrpc_status_ntoh(rep->lock_policy_res2);
-		if (rep->lock_policy_res2)
-			errcode = rep->lock_policy_res2;
-
-		rc = mdc_fill_lvb(req, &ols->ols_lvb);
+		if (likely(rep)) {
+			rep->lock_policy_res2 =
+				ptlrpc_status_ntoh(rep->lock_policy_res2);
+			if (rep->lock_policy_res2)
+				errcode = rep->lock_policy_res2;
+		} else {
+			rc = -EPROTO;
+		}
 		*flags |= LDLM_FL_LVB_READY;
 	} else if (errcode == ELDLM_OK) {
+		struct ldlm_lock *lock;
+
 		/* Callers have references, should be valid always */
 		lock = ldlm_handle2lock(lockh);
-		LASSERT(lock);
 
-		rc = mdc_fill_lvb(req, &lock->l_ost_lvb);
+		/* At this point ols_lvb must be filled with correct LVB either
+		 * by mdc_fill_lvb() above or by ldlm_cli_enqueue_fini().
+		 * DoM uses l_ost_lvb to store LVB data, so copy it here from
+		 * just updated ols_lvb.
+		 */
+		lock_res_and_lock(lock);
+		memcpy(&lock->l_ost_lvb, &ols->ols_lvb,
+		       sizeof(lock->l_ost_lvb));
+		unlock_res_and_lock(lock);
 		LDLM_LOCK_PUT(lock);
 		*flags |= LDLM_FL_LVB_READY;
 	}
@@ -629,6 +639,10 @@ int mdc_enqueue_interpret(const struct lu_env *env, struct ptlrpc_request *req,
 	struct ldlm_lock *lock;
 	struct lustre_handle *lockh = &aa->oa_lockh;
 	enum ldlm_mode mode = aa->oa_mode;
+	struct ldlm_enqueue_info einfo = {
+		.ei_type = aa->oa_type,
+		.ei_mode = mode,
+	};
 
 	LASSERT(!aa->oa_speculative);
 
@@ -643,7 +657,7 @@ int mdc_enqueue_interpret(const struct lu_env *env, struct ptlrpc_request *req,
 	/* Take an additional reference so that a blocking AST that
 	 * ldlm_cli_enqueue_fini() might post for a failed lock, is guaranteed
 	 * to arrive after an upcall has been executed by
-	 * osc_enqueue_fini().
+	 * mdc_enqueue_fini().
 	 */
 	ldlm_lock_addref(lockh, mode);
 
@@ -654,12 +668,12 @@ int mdc_enqueue_interpret(const struct lu_env *env, struct ptlrpc_request *req,
 	OBD_FAIL_TIMEOUT(OBD_FAIL_OSC_CP_ENQ_RACE, 1);
 
 	/* Complete obtaining the lock procedure. */
-	rc = ldlm_cli_enqueue_fini(aa->oa_exp, req, aa->oa_type, 1,
-				   aa->oa_mode, aa->oa_flags, NULL, 0,
-				   lockh, rc);
+	rc = ldlm_cli_enqueue_fini(aa->oa_exp, req, &einfo, 1, aa->oa_flags,
+				   aa->oa_lvb, aa->oa_lvb ?
+				   sizeof(*aa->oa_lvb) : 0, lockh, rc);
 	/* Complete mdc stuff. */
-	rc = mdc_enqueue_fini(req, aa->oa_upcall, aa->oa_cookie, lockh, mode,
-			      aa->oa_flags, rc);
+	rc = mdc_enqueue_fini(aa->oa_exp, req, aa->oa_upcall, aa->oa_cookie,
+			      lockh, mode, aa->oa_flags, rc);
 
 	OBD_FAIL_TIMEOUT(OBD_FAIL_OSC_CP_CANCEL_RACE, 10);
 
@@ -678,8 +692,7 @@ int mdc_enqueue_interpret(const struct lu_env *env, struct ptlrpc_request *req,
  */
 int mdc_enqueue_send(const struct lu_env *env, struct obd_export *exp,
 		     struct ldlm_res_id *res_id, u64 *flags,
-		     union ldlm_policy_data *policy,
-		     struct ost_lvb *lvb, int kms_valid,
+		     union ldlm_policy_data *policy, struct ost_lvb *lvb,
 		     osc_enqueue_upcall_f upcall, void *cookie,
 		     struct ldlm_enqueue_info *einfo, int async)
 {
@@ -692,17 +705,16 @@ int mdc_enqueue_send(const struct lu_env *env, struct obd_export *exp,
 	u64 match_flags = *flags;
 	LIST_HEAD(cancels);
 	int rc, count;
+	int lvb_size;
+	bool compat_glimpse = glimpse && !exp_connect_dom_lvb(exp);
 
 	mode = einfo->ei_mode;
 	if (einfo->ei_mode == LCK_PR)
 		mode |= LCK_PW;
 
+	match_flags |= LDLM_FL_LVB_READY;
 	if (glimpse)
 		match_flags |= LDLM_FL_BLOCK_GRANTED;
-	/* DOM locking uses LDLM_FL_KMS_IGNORE to mark locks wich have no valid
-	 * LVB information, e.g. canceled locks or locks of just pruned object,
-	 * such locks should be skipped.
-	 */
 	mode = ldlm_lock_match(obd->obd_namespace, match_flags, res_id,
 			       einfo->ei_type, policy, mode, &lockh);
 	if (mode) {
@@ -733,7 +745,9 @@ int mdc_enqueue_send(const struct lu_env *env, struct obd_export *exp,
 	if (*flags & (LDLM_FL_TEST_LOCK | LDLM_FL_MATCH_LOCK))
 		return -ENOLCK;
 
-	req = ptlrpc_request_alloc(class_exp2cliimp(exp), &RQF_LDLM_INTENT);
+	/* Glimpse is intent on old server */
+	req = ptlrpc_request_alloc(class_exp2cliimp(exp), compat_glimpse ?
+				   &RQF_LDLM_INTENT : &RQF_LDLM_ENQUEUE);
 	if (!req)
 		return -ENOMEM;
 
@@ -751,20 +765,27 @@ int mdc_enqueue_send(const struct lu_env *env, struct obd_export *exp,
 		return rc;
 	}
 
-	/* pack the intent */
-	lit = req_capsule_client_get(&req->rq_pill, &RMF_LDLM_INTENT);
-	lit->opc = glimpse ? IT_GLIMPSE : IT_BRW;
-
-	req_capsule_set_size(&req->rq_pill, &RMF_MDT_MD, RCL_SERVER, 0);
-	req_capsule_set_size(&req->rq_pill, &RMF_ACL, RCL_SERVER, 0);
-	ptlrpc_request_set_replen(req);
+	if (compat_glimpse) {
+		/* pack the glimpse intent */
+		lit = req_capsule_client_get(&req->rq_pill, &RMF_LDLM_INTENT);
+		lit->opc = IT_GLIMPSE;
+	}
 
 	/* users of mdc_enqueue() can pass this flag for ldlm_lock_match() */
 	*flags &= ~LDLM_FL_BLOCK_GRANTED;
-	/* All MDC IO locks are intents */
-	*flags |= LDLM_FL_HAS_INTENT;
-	rc = ldlm_cli_enqueue(exp, &req, einfo, res_id, policy, flags, NULL,
-			      0, LVB_T_NONE, &lockh, async);
+	if (compat_glimpse) {
+		req_capsule_set_size(&req->rq_pill, &RMF_MDT_MD, RCL_SERVER, 0);
+		req_capsule_set_size(&req->rq_pill, &RMF_ACL, RCL_SERVER, 0);
+		lvb_size = 0;
+	} else {
+		lvb_size = sizeof(*lvb);
+		req_capsule_set_size(&req->rq_pill, &RMF_DLM_LVB, RCL_SERVER,
+				     lvb_size);
+	}
+	ptlrpc_request_set_replen(req);
+
+	rc = ldlm_cli_enqueue(exp, &req, einfo, res_id, policy, flags, lvb,
+			      lvb_size, LVB_T_OST, &lockh, async);
 	if (async) {
 		if (!rc) {
 			struct osc_enqueue_args *aa;
@@ -778,7 +799,7 @@ int mdc_enqueue_send(const struct lu_env *env, struct obd_export *exp,
 			aa->oa_cookie = cookie;
 			aa->oa_speculative = false;
 			aa->oa_flags = flags;
-			aa->oa_lvb = lvb;
+			aa->oa_lvb = compat_glimpse ? NULL : lvb;
 
 			req->rq_interpret_reply = mdc_enqueue_interpret;
 			ptlrpcd_add_req(req);
@@ -788,7 +809,7 @@ int mdc_enqueue_send(const struct lu_env *env, struct obd_export *exp,
 		return rc;
 	}
 
-	rc = mdc_enqueue_fini(req, upcall, cookie, &lockh, einfo->ei_mode,
+	rc = mdc_enqueue_fini(exp, req, upcall, cookie, &lockh, einfo->ei_mode,
 			      flags, rc);
 	ptlrpc_req_finished(req);
 	return rc;
@@ -874,8 +895,7 @@ static int mdc_lock_enqueue(const struct lu_env *env,
 	mdc_lock_build_policy(env, lock, policy);
 	LASSERT(!oscl->ols_speculative);
 	result = mdc_enqueue_send(env, osc_export(osc), resname,
-				  &oscl->ols_flags, policy,
-				  &oscl->ols_lvb, osc->oo_oinfo->loi_kms_valid,
+				  &oscl->ols_flags, policy, &oscl->ols_lvb,
 				  upcall, cookie, &oscl->ols_einfo, async);
 	if (result == 0) {
 		if (osc_lock_is_lockless(oscl)) {
@@ -1429,7 +1449,7 @@ static int mdc_object_flush(const struct lu_env *env, struct cl_object *obj,
 	 * so init it here with given osc_object.
 	 */
 	mdc_set_dom_lock_data(lock, cl2osc(obj));
-	return mdc_dlm_blocking_ast0(env, lock, LDLM_CB_CANCELING);
+	return mdc_dlm_canceling(env, lock);
 }
 
 static const struct cl_object_operations mdc_ops = {
diff --git a/fs/lustre/mdc/mdc_internal.h b/fs/lustre/mdc/mdc_internal.h
index 065cba5..91e8240 100644
--- a/fs/lustre/mdc/mdc_internal.h
+++ b/fs/lustre/mdc/mdc_internal.h
@@ -168,6 +168,16 @@ int mdc_unpack_acl(struct ptlrpc_request *req, struct lustre_md *md)
 }
 #endif
 
+static inline void mdc_body2lvb(struct mdt_body *body, struct ost_lvb *lvb)
+{
+	LASSERT(body->mbo_valid & OBD_MD_DOM_SIZE);
+	lvb->lvb_mtime = body->mbo_mtime;
+	lvb->lvb_atime = body->mbo_atime;
+	lvb->lvb_ctime = body->mbo_ctime;
+	lvb->lvb_blocks = body->mbo_dom_blocks;
+	lvb->lvb_size = body->mbo_dom_size;
+}
+
 static inline unsigned long hash_x_index(u64 hash, int hash64)
 {
 	if (BITS_PER_LONG == 32 && hash64)
diff --git a/fs/lustre/mdc/mdc_locks.c b/fs/lustre/mdc/mdc_locks.c
index 8bbb9e1..dbf402a 100644
--- a/fs/lustre/mdc/mdc_locks.c
+++ b/fs/lustre/mdc/mdc_locks.c
@@ -872,7 +872,10 @@ static int mdc_finish_enqueue(struct obd_export *exp,
 		LDLM_DEBUG(lock, "DoM lock is returned by: %s, size: %llu",
 			   ldlm_it2str(it->it_op), body->mbo_dom_size);
 
-		rc = mdc_fill_lvb(req, &lock->l_ost_lvb);
+		lock_res_and_lock(lock);
+		mdc_body2lvb(body, &lock->l_ost_lvb);
+		ldlm_lock_allow_match_locked(lock);
+		unlock_res_and_lock(lock);
 	}
 out_lock:
 	LDLM_LOCK_PUT(lock);
@@ -1368,8 +1371,8 @@ static int mdc_intent_getattr_async_interpret(const struct lu_env *env,
 	if (OBD_FAIL_CHECK(OBD_FAIL_MDC_GETATTR_ENQUEUE))
 		rc = -ETIMEDOUT;
 
-	rc = ldlm_cli_enqueue_fini(exp, req, einfo->ei_type, 1, einfo->ei_mode,
-				   &flags, NULL, 0, lockh, rc);
+	rc = ldlm_cli_enqueue_fini(exp, req, einfo, 1, &flags, NULL, 0,
+				   lockh, rc);
 	if (rc < 0) {
 		CERROR("%s: ldlm_cli_enqueue_fini() failed: rc = %d\n",
 		       exp->exp_obd->obd_name, rc);
diff --git a/fs/lustre/obdclass/lprocfs_status.c b/fs/lustre/obdclass/lprocfs_status.c
index 6ce0a5d..0ed1bd5 100644
--- a/fs/lustre/obdclass/lprocfs_status.c
+++ b/fs/lustre/obdclass/lprocfs_status.c
@@ -130,6 +130,7 @@
 	"fidmap",		/* 0x10000 */
 	"getattr_pfid",		/* 0x20000 */
 	"lseek",		/* 0x40000 */
+	"dom_lvb",		/* 0x80000 */
 	NULL
 };
 
diff --git a/fs/lustre/osc/osc_request.c b/fs/lustre/osc/osc_request.c
index 4a4b5ef..a6a8cac 100644
--- a/fs/lustre/osc/osc_request.c
+++ b/fs/lustre/osc/osc_request.c
@@ -2684,6 +2684,10 @@ int osc_enqueue_interpret(const struct lu_env *env, struct ptlrpc_request *req,
 	struct ost_lvb *lvb = aa->oa_lvb;
 	u32 lvb_len = sizeof(*lvb);
 	u64 flags = 0;
+	struct ldlm_enqueue_info einfo = {
+		.ei_type = aa->oa_type,
+		.ei_mode = mode,
+	};
 
 	/* ldlm_cli_enqueue is holding a reference on the lock, so it must
 	 * be valid.
@@ -2712,9 +2716,8 @@ int osc_enqueue_interpret(const struct lu_env *env, struct ptlrpc_request *req,
 	}
 
 	/* Complete obtaining the lock procedure. */
-	rc = ldlm_cli_enqueue_fini(aa->oa_exp, req, aa->oa_type, 1,
-				   aa->oa_mode, aa->oa_flags, lvb, lvb_len,
-				   lockh, rc);
+	rc = ldlm_cli_enqueue_fini(aa->oa_exp, req, &einfo, 1, aa->oa_flags,
+				   lvb, lvb_len, lockh, rc);
 	/* Complete osc stuff. */
 	rc = osc_enqueue_fini(req, aa->oa_upcall, aa->oa_cookie, lockh, mode,
 			      aa->oa_flags, aa->oa_speculative, rc);
@@ -2821,22 +2824,6 @@ int osc_enqueue_base(struct obd_export *exp, struct ldlm_res_id *res_id,
 
 	if (*flags & (LDLM_FL_TEST_LOCK | LDLM_FL_MATCH_LOCK))
 		return -ENOLCK;
-	if (intent) {
-		req = ptlrpc_request_alloc(class_exp2cliimp(exp),
-					   &RQF_LDLM_ENQUEUE_LVB);
-		if (!req)
-			return -ENOMEM;
-
-		rc = ldlm_prep_enqueue_req(exp, req, NULL, 0);
-		if (rc) {
-			ptlrpc_request_free(req);
-			return rc;
-		}
-
-		req_capsule_set_size(&req->rq_pill, &RMF_DLM_LVB, RCL_SERVER,
-				     sizeof(*lvb));
-		ptlrpc_request_set_replen(req);
-	}
 
 	/* users of osc_enqueue() can pass this flag for ldlm_lock_match() */
 	*flags &= ~LDLM_FL_BLOCK_GRANTED;
@@ -2869,16 +2856,12 @@ int osc_enqueue_base(struct obd_export *exp, struct ldlm_res_id *res_id,
 
 			req->rq_interpret_reply = osc_enqueue_interpret;
 			ptlrpc_set_add_req(rqset, req);
-		} else if (intent) {
-			ptlrpc_req_finished(req);
 		}
 		return rc;
 	}
 
 	rc = osc_enqueue_fini(req, upcall, cookie, &lockh, einfo->ei_mode,
 			      flags, speculative, rc);
-	if (intent)
-		ptlrpc_req_finished(req);
 
 	return rc;
 }
@@ -2904,16 +2887,8 @@ int osc_match_base(const struct lu_env *env, struct obd_export *exp,
 	policy->l_extent.end |= ~PAGE_MASK;
 
 	/* Next, search for already existing extent locks that will cover us */
-	/* If we're trying to read, we also search for an existing PW lock.  The
-	 * VFS and page cache already protect us locally, so lots of readers/
-	 * writers can share a single PW lock.
-	 */
-	rc = mode;
-	if (mode == LCK_PR)
-		rc |= LCK_PW;
-
 	rc = ldlm_lock_match_with_skip(obd->obd_namespace, lflags, 0,
-				       res_id, type, policy, rc, lockh,
+				       res_id, type, policy, mode, lockh,
 				       match_flags);
 	if (!rc || lflags & LDLM_FL_TEST_LOCK)
 		return rc;
diff --git a/fs/lustre/ptlrpc/wiretest.c b/fs/lustre/ptlrpc/wiretest.c
index c8b97fa..fedb914 100644
--- a/fs/lustre/ptlrpc/wiretest.c
+++ b/fs/lustre/ptlrpc/wiretest.c
@@ -1249,6 +1249,8 @@ void lustre_assert_wire_constants(void)
 		 OBD_CONNECT2_GETATTR_PFID);
 	LASSERTF(OBD_CONNECT2_LSEEK == 0x40000ULL, "found 0x%.16llxULL\n",
 		 OBD_CONNECT2_LSEEK);
+	LASSERTF(OBD_CONNECT2_DOM_LVB == 0x80000ULL, "found 0x%.16llxULL\n",
+		 OBD_CONNECT2_DOM_LVB);
 	LASSERTF(OBD_CKSUM_CRC32 == 0x00000001UL, "found 0x%.8xUL\n",
 		 (unsigned int)OBD_CKSUM_CRC32);
 	LASSERTF(OBD_CKSUM_ADLER == 0x00000002UL, "found 0x%.8xUL\n",
diff --git a/include/uapi/linux/lustre/lustre_idl.h b/include/uapi/linux/lustre/lustre_idl.h
index f953815..449ac47 100644
--- a/include/uapi/linux/lustre/lustre_idl.h
+++ b/include/uapi/linux/lustre/lustre_idl.h
@@ -839,6 +839,7 @@ struct ptlrpc_body_v2 {
 #define OBD_CONNECT2_FIDMAP	      0x10000ULL /* FID map */
 #define OBD_CONNECT2_GETATTR_PFID     0x20000ULL /* pack parent FID in getattr */
 #define OBD_CONNECT2_LSEEK	      0x40000ULL /* SEEK_HOLE/DATA RPC */
+#define OBD_CONNECT2_DOM_LVB	      0x80000ULL /* pack DOM glimpse data in LVB */
 /* XXX README XXX:
  * Please DO NOT add flag values here before first ensuring that this same
  * flag value is not in use on some other branch.  Please clear any such
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
