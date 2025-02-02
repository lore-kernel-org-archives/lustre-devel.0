Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 8D770C0218F
	for <lustre-devel@archiver.kernel.org>; Sun,  2 Feb 2025 21:05:30 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4YmMGH0Ht3z215C;
	Sun, 02 Feb 2025 12:50:31 -0800 (PST)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4YmMFn0jslz213G
 for <lustre-devel@lists.lustre.org>; Sun, 02 Feb 2025 12:50:04 -0800 (PST)
Received: from star2.ccs.ornl.gov (ltm-e204-208.ccs.ornl.gov [160.91.203.12])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 16C6E881AA0;
 Sun,  2 Feb 2025 15:46:42 -0500 (EST)
Received: by star2.ccs.ornl.gov (Postfix, from userid 2004)
 id 1438E106BE15; Sun,  2 Feb 2025 15:46:42 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun,  2 Feb 2025 15:46:29 -0500
Message-ID: <20250202204633.1148872-30-jsimmons@infradead.org>
X-Mailer: git-send-email 2.43.5
In-Reply-To: <20250202204633.1148872-1-jsimmons@infradead.org>
References: <20250202204633.1148872-1-jsimmons@infradead.org>
MIME-Version: 1.0
Subject: [lustre-devel] [PATCH 29/33] lustre: mdc: remove OBD_ -> CFS_ macros
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

Remove OBD macros that are simply redefinitions
of CFS macros.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12610
Lustre-commit: 32aff098ce016fb56 ("LU-12610 mdt: remove OBD_ -> CFS_ macros")
Signed-off-by: Timothy Day <timday@amazon.com>
Signed-off-by: Ben Evans <beevans@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/50806
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Neil Brown <neilb@suse.de>
Reviewed-by: Arshad Hussain <arshad.hussain@aeoncomputing.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/mdc/mdc_dev.c     | 8 ++++----
 fs/lustre/mdc/mdc_locks.c   | 4 ++--
 fs/lustre/mdc/mdc_request.c | 2 +-
 fs/lustre/mgc/mgc_request.c | 2 +-
 4 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/fs/lustre/mdc/mdc_dev.c b/fs/lustre/mdc/mdc_dev.c
index a205a8de3249..eccd9819ca56 100644
--- a/fs/lustre/mdc/mdc_dev.c
+++ b/fs/lustre/mdc/mdc_dev.c
@@ -657,10 +657,10 @@ int mdc_enqueue_interpret(const struct lu_env *env, struct ptlrpc_request *req,
 	ldlm_lock_addref(lockh, mode);
 
 	/* Let cl_lock_state_wait fail with -ERESTARTSYS to unuse sublocks. */
-	OBD_FAIL_TIMEOUT(OBD_FAIL_LDLM_ENQUEUE_HANG, 2);
+	CFS_FAIL_TIMEOUT(OBD_FAIL_LDLM_ENQUEUE_HANG, 2);
 
 	/* Let CP AST to grant the lock first. */
-	OBD_FAIL_TIMEOUT(OBD_FAIL_OSC_CP_ENQ_RACE, 1);
+	CFS_FAIL_TIMEOUT(OBD_FAIL_OSC_CP_ENQ_RACE, 1);
 
 	/* Complete obtaining the lock procedure. */
 	rc = ldlm_cli_enqueue_fini(aa->oa_exp, &req->rq_pill, &einfo, 1,
@@ -670,7 +670,7 @@ int mdc_enqueue_interpret(const struct lu_env *env, struct ptlrpc_request *req,
 	rc = mdc_enqueue_fini(aa->oa_exp, req, aa->oa_upcall, aa->oa_cookie,
 			      lockh, mode, aa->oa_flags, rc);
 
-	OBD_FAIL_TIMEOUT(OBD_FAIL_OSC_CP_CANCEL_RACE, 10);
+	CFS_FAIL_TIMEOUT(OBD_FAIL_OSC_CP_CANCEL_RACE, 10);
 
 	ldlm_lock_decref(lockh, mode);
 	LDLM_LOCK_PUT(lock);
@@ -724,7 +724,7 @@ int mdc_enqueue_send(const struct lu_env *env, struct obd_export *exp,
 
 		matched = ldlm_handle2lock(&lockh);
 
-		if (OBD_FAIL_CHECK(OBD_FAIL_MDC_GLIMPSE_DDOS))
+		if (CFS_FAIL_CHECK(OBD_FAIL_MDC_GLIMPSE_DDOS))
 			ldlm_set_kms_ignore(matched);
 
 		if (mdc_set_dom_lock_data(matched, einfo->ei_cbdata)) {
diff --git a/fs/lustre/mdc/mdc_locks.c b/fs/lustre/mdc/mdc_locks.c
index 7695c78dc1bd..3b4c21354070 100644
--- a/fs/lustre/mdc/mdc_locks.c
+++ b/fs/lustre/mdc/mdc_locks.c
@@ -1150,7 +1150,7 @@ static int mdc_finish_intent_lock(struct obd_export *exp,
 		/* balanced in ll_file_open */
 		ptlrpc_request_addref(request);
 		/* eviction in middle of open RPC processing b=11546 */
-		OBD_FAIL_TIMEOUT(OBD_FAIL_MDC_ENQUEUE_PAUSE,
+		CFS_FAIL_TIMEOUT(OBD_FAIL_MDC_ENQUEUE_PAUSE,
 				 obd_timeout);
 	}
 
@@ -1373,7 +1373,7 @@ static int mdc_intent_getattr_async_interpret(const struct lu_env *env,
 	struct ldlm_reply *lockrep;
 	u64 flags = LDLM_FL_HAS_INTENT;
 
-	if (OBD_FAIL_CHECK(OBD_FAIL_MDC_GETATTR_ENQUEUE))
+	if (CFS_FAIL_CHECK(OBD_FAIL_MDC_GETATTR_ENQUEUE))
 		rc = -ETIMEDOUT;
 
 	rc = ldlm_cli_enqueue_fini(exp, pill, einfo, 1, &flags, NULL, 0,
diff --git a/fs/lustre/mdc/mdc_request.c b/fs/lustre/mdc/mdc_request.c
index 3b838bceba39..b9b962c6f723 100644
--- a/fs/lustre/mdc/mdc_request.c
+++ b/fs/lustre/mdc/mdc_request.c
@@ -929,7 +929,7 @@ static int mdc_close(struct obd_export *exp, struct md_op_data *op_data,
 	}
 
 	*request = NULL;
-	if (OBD_FAIL_CHECK(OBD_FAIL_MDC_CLOSE))
+	if (CFS_FAIL_CHECK(OBD_FAIL_MDC_CLOSE))
 		req = NULL;
 	else
 		req = ptlrpc_request_alloc(class_exp2cliimp(exp), req_fmt);
diff --git a/fs/lustre/mgc/mgc_request.c b/fs/lustre/mgc/mgc_request.c
index 94e15f9e7c52..56fb50aedbd9 100644
--- a/fs/lustre/mgc/mgc_request.c
+++ b/fs/lustre/mgc/mgc_request.c
@@ -1605,7 +1605,7 @@ int mgc_process_log(struct obd_device *mgc, struct config_llog_data *cld)
 		return 0;
 	}
 
-	OBD_FAIL_TIMEOUT(OBD_FAIL_MGC_PAUSE_PROCESS_LOG, 20);
+	CFS_FAIL_TIMEOUT(OBD_FAIL_MGC_PAUSE_PROCESS_LOG, 20);
 
 	CDEBUG(D_MGC, "Process log %s:%p from %d\n", cld->cld_logname,
 	       cld->cld_cfg.cfg_instance, cld->cld_cfg.cfg_last_idx + 1);
-- 
2.39.3

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
