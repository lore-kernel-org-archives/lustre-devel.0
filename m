Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id DEC30C433EF
	for <lustre-devel@archiver.kernel.org>; Sun, 28 Nov 2021 23:28:49 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 7BE252010C1;
	Sun, 28 Nov 2021 15:28:31 -0800 (PST)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id AA9CF200F3F
 for <lustre-devel@lists.lustre.org>; Sun, 28 Nov 2021 15:28:02 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id B56DF265;
 Sun, 28 Nov 2021 18:27:56 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id B0E25C1AC4; Sun, 28 Nov 2021 18:27:56 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 28 Nov 2021 18:27:49 -0500
Message-Id: <1638142074-5945-15-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1638142074-5945-1-git-send-email-jsimmons@infradead.org>
References: <1638142074-5945-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 14/19] lustre: llite: skip request slot for
 lmv_revalidate_slaves()
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
Cc: Andriy Skulysh <c17819@cray.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Andriy Skulysh <c17819@cray.com>

Some syscalls need lmv_revalidate_slaves(). It requires
second lock enqueue and the it can be blocked by
lack of RPC slots.

Don't acquire rpc slot for second lock enqueue.

HPE-bug-id: LUS-8416
WC-bug-id: https://jira.whamcloud.com/browse/LU-15121
Lustre-commit: 7e781c605c4189ea1 ("LU-15121 llite: skip request slot for lmv_revalidate_slaves()")
Signed-off-by: Andriy Skulysh <c17819@cray.com>
Reviewed-on: https://review.whamcloud.com/45275
Reviewed-by: Vitaly Fertman <c17818@cray.com>
Reviewed-by: Alexander Zarochentsev <c17826@cray.com>
Reviewed-by: Vitaly Fertman <vitaly.fertman@hpe.com>
Reviewed-by: Alexander Zarochentsev <alexander.zarochentsev@hpe.com>
Reviewed-by: Lai Siyao <lai.siyao@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_dlm.h |  7 +++++--
 fs/lustre/include/obd.h        |  1 +
 fs/lustre/ldlm/ldlm_request.c  | 18 +++++++++++-------
 fs/lustre/llite/statahead.c    |  1 +
 fs/lustre/lmv/lmv_intent.c     |  2 ++
 fs/lustre/mdc/mdc_dev.c        |  3 ++-
 fs/lustre/mdc/mdc_locks.c      |  5 +++--
 fs/lustre/osc/osc_request.c    |  2 +-
 8 files changed, 26 insertions(+), 13 deletions(-)

diff --git a/fs/lustre/include/lustre_dlm.h b/fs/lustre/include/lustre_dlm.h
index 1fc199b..a2fe9676 100644
--- a/fs/lustre/include/lustre_dlm.h
+++ b/fs/lustre/include/lustre_dlm.h
@@ -1018,7 +1018,9 @@ struct ldlm_enqueue_info {
 	/* whether enqueue slave stripes */
 	unsigned int		ei_enq_slave:1;
 	/* whether acquire rpc slot */
-	unsigned int		ei_enq_slot:1;
+	unsigned int		ei_req_slot:1;
+	/** whether acquire mod rpc slot */
+	unsigned int		ei_mod_slot:1;
 };
 
 extern struct obd_ops ldlm_obd_ops;
@@ -1343,7 +1345,8 @@ int ldlm_prep_elc_req(struct obd_export *exp,
 int ldlm_cli_enqueue_fini(struct obd_export *exp, struct ptlrpc_request *req,
 			  struct ldlm_enqueue_info *einfo, u8 with_policy,
 			  u64 *flags, void *lvb, u32 lvb_len,
-			  const struct lustre_handle *lockh, int rc);
+			  const struct lustre_handle *lockh, int rc,
+			  bool request_slot);
 int ldlm_cli_convert_req(struct ldlm_lock *lock, u32 *flags, u64 new_bits);
 int ldlm_cli_convert(struct ldlm_lock *lock,
 		     enum ldlm_cancel_flags cancel_flags);
diff --git a/fs/lustre/include/obd.h b/fs/lustre/include/obd.h
index 27acd33..58a5803 100644
--- a/fs/lustre/include/obd.h
+++ b/fs/lustre/include/obd.h
@@ -722,6 +722,7 @@ enum md_cli_flags {
 	CLI_API32		= BIT(3),
 	CLI_MIGRATE		= BIT(4),
 	CLI_DIRTY_DATA		= BIT(5),
+	CLI_NO_SLOT		= BIT(6),
 };
 
 enum md_op_code {
diff --git a/fs/lustre/ldlm/ldlm_request.c b/fs/lustre/ldlm/ldlm_request.c
index 746c45b..44e1ec2 100644
--- a/fs/lustre/ldlm/ldlm_request.c
+++ b/fs/lustre/ldlm/ldlm_request.c
@@ -359,7 +359,9 @@ static bool ldlm_request_slot_needed(struct ldlm_enqueue_info *einfo)
 	/* exclude EXTENT locks and DOM-only IBITS locks because they
 	 * are asynchronous and don't wait on server being blocked.
 	 */
-	return einfo->ei_type == LDLM_FLOCK || einfo->ei_type == LDLM_IBITS;
+	return einfo->ei_req_slot &&
+	       (einfo->ei_type == LDLM_FLOCK ||
+		einfo->ei_type == LDLM_IBITS);
 }
 
 /**
@@ -371,7 +373,7 @@ int ldlm_cli_enqueue_fini(struct obd_export *exp, struct ptlrpc_request *req,
 			  struct ldlm_enqueue_info *einfo,
 			  u8 with_policy, u64 *ldlm_flags, void *lvb,
 			  u32 lvb_len, const struct lustre_handle *lockh,
-			  int rc)
+			  int rc, bool request_slot)
 {
 	struct ldlm_namespace *ns = exp->exp_obd->obd_namespace;
 	const struct lu_env *env = NULL;
@@ -380,7 +382,7 @@ int ldlm_cli_enqueue_fini(struct obd_export *exp, struct ptlrpc_request *req,
 	struct ldlm_reply *reply;
 	int cleanup_phase = 1;
 
-	if (ldlm_request_slot_needed(einfo))
+	if (request_slot)
 		obd_put_request_slot(&req->rq_import->imp_obd->u.cli);
 
 	ptlrpc_put_mod_rpc_slot(req);
@@ -726,6 +728,7 @@ int ldlm_cli_enqueue(struct obd_export *exp, struct ptlrpc_request **reqp,
 	int is_replay = *flags & LDLM_FL_REPLAY;
 	int req_passed_in = 1;
 	int rc, err;
+	bool need_req_slot;
 	struct ptlrpc_request *req;
 
 	ns = exp->exp_obd->obd_namespace;
@@ -829,13 +832,14 @@ int ldlm_cli_enqueue(struct obd_export *exp, struct ptlrpc_request **reqp,
 	 * that threads that are waiting for a modify RPC slot are not polluting
 	 * our rpcs in flight counter.
 	 */
-	if (einfo->ei_enq_slot)
+	if (einfo->ei_mod_slot)
 		ptlrpc_get_mod_rpc_slot(req);
 
-	if (ldlm_request_slot_needed(einfo)) {
+	need_req_slot = ldlm_request_slot_needed(einfo);
+	if (need_req_slot) {
 		rc = obd_get_request_slot(&req->rq_import->imp_obd->u.cli);
 		if (rc) {
-			if (einfo->ei_enq_slot)
+			if (einfo->ei_mod_slot)
 				ptlrpc_put_mod_rpc_slot(req);
 			failed_lock_cleanup(ns, lock, einfo->ei_mode);
 			LDLM_LOCK_RELEASE(lock);
@@ -855,7 +859,7 @@ int ldlm_cli_enqueue(struct obd_export *exp, struct ptlrpc_request **reqp,
 	rc = ptlrpc_queue_wait(req);
 
 	err = ldlm_cli_enqueue_fini(exp, req, einfo, policy ? 1 : 0, flags,
-				    lvb, lvb_len, lockh, rc);
+				    lvb, lvb_len, lockh, rc, need_req_slot);
 
 	/*
 	 * If ldlm_cli_enqueue_fini did not find the lock, we need to free
diff --git a/fs/lustre/llite/statahead.c b/fs/lustre/llite/statahead.c
index 4806e99..39ffb9d 100644
--- a/fs/lustre/llite/statahead.c
+++ b/fs/lustre/llite/statahead.c
@@ -380,6 +380,7 @@ static int ll_statahead_interpret(struct ptlrpc_request *req,
 	einfo->ei_cb_cp  = ldlm_completion_ast;
 	einfo->ei_cb_gl  = NULL;
 	einfo->ei_cbdata = NULL;
+	einfo->ei_req_slot = 1;
 
 	return minfo;
 }
diff --git a/fs/lustre/lmv/lmv_intent.c b/fs/lustre/lmv/lmv_intent.c
index 93da2b3..906ca16 100644
--- a/fs/lustre/lmv/lmv_intent.c
+++ b/fs/lustre/lmv/lmv_intent.c
@@ -106,6 +106,7 @@ static int lmv_intent_remote(struct obd_export *exp, struct lookup_intent *it,
 	}
 
 	op_data->op_bias = MDS_CROSS_REF;
+	op_data->op_cli_flags = CLI_NO_SLOT;
 	CDEBUG(D_INODE, "REMOTE_INTENT with fid=" DFID " -> mds #%u\n",
 	       PFID(&body->mbo_fid1), tgt->ltd_index);
 
@@ -203,6 +204,7 @@ int lmv_revalidate_slaves(struct obd_export *exp,
 		 * it's remote object.
 		 */
 		op_data->op_bias = MDS_CROSS_REF;
+		op_data->op_cli_flags = CLI_NO_SLOT;
 
 		tgt = lmv_tgt(lmv, lsm->lsm_md_oinfo[i].lmo_mds);
 		if (!tgt) {
diff --git a/fs/lustre/mdc/mdc_dev.c b/fs/lustre/mdc/mdc_dev.c
index b2f60ea..0b1d257 100644
--- a/fs/lustre/mdc/mdc_dev.c
+++ b/fs/lustre/mdc/mdc_dev.c
@@ -66,6 +66,7 @@ static void mdc_lock_build_einfo(const struct lu_env *env,
 	einfo->ei_cb_cp = ldlm_completion_ast;
 	einfo->ei_cb_gl = mdc_ldlm_glimpse_ast;
 	einfo->ei_cbdata = osc; /* value to be put into ->l_ast_data */
+	einfo->ei_req_slot = 1;
 }
 
 static void mdc_lock_lvb_update(const struct lu_env *env,
@@ -664,7 +665,7 @@ int mdc_enqueue_interpret(const struct lu_env *env, struct ptlrpc_request *req,
 	/* Complete obtaining the lock procedure. */
 	rc = ldlm_cli_enqueue_fini(aa->oa_exp, req, &einfo, 1, aa->oa_flags,
 				   aa->oa_lvb, aa->oa_lvb ?
-				   sizeof(*aa->oa_lvb) : 0, lockh, rc);
+				   sizeof(*aa->oa_lvb) : 0, lockh, rc, true);
 	/* Complete mdc stuff. */
 	rc = mdc_enqueue_fini(aa->oa_exp, req, aa->oa_upcall, aa->oa_cookie,
 			      lockh, mode, aa->oa_flags, rc);
diff --git a/fs/lustre/mdc/mdc_locks.c b/fs/lustre/mdc/mdc_locks.c
index 4135c3a..66f0039 100644
--- a/fs/lustre/mdc/mdc_locks.c
+++ b/fs/lustre/mdc/mdc_locks.c
@@ -984,7 +984,8 @@ int mdc_enqueue_base(struct obd_export *exp, struct ldlm_enqueue_info *einfo,
 		req->rq_sent = ktime_get_real_seconds() + resends;
 	}
 
-	einfo->ei_enq_slot = !mdc_skip_mod_rpc_slot(it);
+	einfo->ei_req_slot = !(op_data->op_cli_flags & CLI_NO_SLOT);
+	einfo->ei_mod_slot = !mdc_skip_mod_rpc_slot(it);
 
 	/* With Data-on-MDT the glimpse callback is needed too.
 	 * It is set here in advance but not in mdc_finish_enqueue()
@@ -1371,7 +1372,7 @@ static int mdc_intent_getattr_async_interpret(const struct lu_env *env,
 		rc = -ETIMEDOUT;
 
 	rc = ldlm_cli_enqueue_fini(exp, req, einfo, 1, &flags, NULL, 0,
-				   lockh, rc);
+				   lockh, rc, true);
 	if (rc < 0) {
 		CERROR("%s: ldlm_cli_enqueue_fini() failed: rc = %d\n",
 		       exp->exp_obd->obd_name, rc);
diff --git a/fs/lustre/osc/osc_request.c b/fs/lustre/osc/osc_request.c
index cf79808..e065eab 100644
--- a/fs/lustre/osc/osc_request.c
+++ b/fs/lustre/osc/osc_request.c
@@ -2824,7 +2824,7 @@ int osc_enqueue_interpret(const struct lu_env *env, struct ptlrpc_request *req,
 
 	/* Complete obtaining the lock procedure. */
 	rc = ldlm_cli_enqueue_fini(aa->oa_exp, req, &einfo, 1, aa->oa_flags,
-				   lvb, lvb_len, lockh, rc);
+				   lvb, lvb_len, lockh, rc, false);
 	/* Complete osc stuff. */
 	rc = osc_enqueue_fini(req, aa->oa_upcall, aa->oa_cookie, lockh, mode,
 			      aa->oa_flags, aa->oa_speculative, rc);
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
