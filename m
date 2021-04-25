Return-Path: <SRS0=Gt0B=JW=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.7 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7E244C433ED
	for <lustre-devel@archiver.kernel.org>; Sun, 25 Apr 2021 20:09:18 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 3AC89611CC
	for <lustre-devel@archiver.kernel.org>; Sun, 25 Apr 2021 20:09:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3AC89611CC
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 4699021F90A;
	Sun, 25 Apr 2021 13:09:03 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 5702321F513
 for <lustre-devel@lists.lustre.org>; Sun, 25 Apr 2021 13:08:44 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 1A8C110087C4;
 Sun, 25 Apr 2021 16:08:40 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 1539869A64; Sun, 25 Apr 2021 16:08:40 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 25 Apr 2021 16:08:17 -0400
Message-Id: <1619381316-7719-11-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1619381316-7719-1-git-send-email-jsimmons@infradead.org>
References: <1619381316-7719-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 10/29] lustre: mdc: set fid2path RPC
 interruptible
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
Cc: Lai Siyao <lai.siyao@whamcloud.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Lai Siyao <lai.siyao@whamcloud.com>

Sometimes OI scrub can't fix the inconsistency in FID and name, and
server will return -EINPROGRESS for fid2path request. Upon such
failure, client will keep resending the request. Set such request
to be interruptible to avoid deadlock.

WC-bug-id: https://jira.whamcloud.com/browse/LU-14119
Lustre-commit: bf47526261067153 ("LU-14119 mdc: set fid2path RPC interruptible")
Signed-off-by: Lai Siyao <lai.siyao@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/41219
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Alex Zhuravlev <bzzz@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_net.h |  4 +++-
 fs/lustre/mdc/mdc_request.c    |  7 +++++++
 fs/lustre/ptlrpc/client.c      | 35 +++++++++++++++++++++++++++++++----
 3 files changed, 41 insertions(+), 5 deletions(-)

diff --git a/fs/lustre/include/lustre_net.h b/fs/lustre/include/lustre_net.h
index 2b98468..abd16ea 100644
--- a/fs/lustre/include/lustre_net.h
+++ b/fs/lustre/include/lustre_net.h
@@ -445,6 +445,7 @@ struct ptlrpc_request_set {
 	set_producer_func	set_producer;
 	/** opaq argument passed to the producer callback */
 	void			*set_producer_arg;
+	unsigned int		set_allow_intr:1;
 };
 
 struct ptlrpc_bulk_desc;
@@ -825,7 +826,8 @@ struct ptlrpc_request {
 		rq_allow_replay:1,
 		/* bulk request, sent to server, but uncommitted */
 		rq_unstable:1,
-		rq_early_free_repbuf:1; /* free reply buffer in advance */
+		rq_early_free_repbuf:1, /* free reply buffer in advance */
+		rq_allow_intr:1;
 	/** @} */
 
 	/** server-side flags @{ */
diff --git a/fs/lustre/mdc/mdc_request.c b/fs/lustre/mdc/mdc_request.c
index ef27af6..6ac3a39 100644
--- a/fs/lustre/mdc/mdc_request.c
+++ b/fs/lustre/mdc/mdc_request.c
@@ -2293,6 +2293,13 @@ static int mdc_get_info_rpc(struct obd_export *exp,
 			     RCL_SERVER, vallen);
 	ptlrpc_request_set_replen(req);
 
+	/* if server failed to resolve FID, and OI scrub not able to fix it, it
+	 * will return -EINPROGRESS, ptlrpc_queue_wait() will keep retrying,
+	 * set request interruptible to avoid deadlock.
+	 */
+	if (KEY_IS(KEY_FID2PATH))
+		req->rq_allow_intr = 1;
+
 	rc = ptlrpc_queue_wait(req);
 	/* -EREMOTE means the get_info result is partial, and it needs to
 	 * continue on another MDT, see fid2path part in lmv_iocontrol
diff --git a/fs/lustre/ptlrpc/client.c b/fs/lustre/ptlrpc/client.c
index 04e8fec..3c57b69 100644
--- a/fs/lustre/ptlrpc/client.c
+++ b/fs/lustre/ptlrpc/client.c
@@ -1127,6 +1127,9 @@ void ptlrpc_set_add_req(struct ptlrpc_request_set *set,
 	LASSERT(req->rq_import->imp_state != LUSTRE_IMP_IDLE);
 	LASSERT(list_empty(&req->rq_set_chain));
 
+	if (req->rq_allow_intr)
+		set->set_allow_intr = 1;
+
 	/* The set takes over the caller's request reference */
 	list_add_tail(&req->rq_set_chain, &set->set_requests);
 	req->rq_set = set;
@@ -1725,6 +1728,7 @@ int ptlrpc_check_set(const struct lu_env *env, struct ptlrpc_request_set *set)
 	list_for_each_entry_safe(req, next, &set->set_requests, rq_set_chain) {
 		struct obd_import *imp = req->rq_import;
 		int unregistered = 0;
+		int async = 1;
 		int rc = 0;
 
 		/*
@@ -1736,6 +1740,24 @@ int ptlrpc_check_set(const struct lu_env *env, struct ptlrpc_request_set *set)
 		 */
 		cond_resched();
 
+		/*
+		 * If the caller requires to allow to be interpreted by force
+		 * and it has really been interpreted, then move the request
+		 * to RQ_PHASE_INTERPRET phase in spite of what the current
+		 * phase is.
+		 */
+		if (unlikely(req->rq_allow_intr && req->rq_intr)) {
+			req->rq_status = -EINTR;
+			ptlrpc_rqphase_move(req, RQ_PHASE_INTERPRET);
+
+			/*
+			 * Since it is interpreted and we have to wait for
+			 * the reply to be unlinked, then use sync mode.
+			 */
+			async = 0;
+			goto interpret;
+		}
+
 		if (req->rq_phase == RQ_PHASE_NEW &&
 		    ptlrpc_send_new_req(req)) {
 			force_timer_recalc = 1;
@@ -2067,13 +2089,13 @@ int ptlrpc_check_set(const struct lu_env *env, struct ptlrpc_request_set *set)
 		 * This moves to "unregistering" phase we need to wait for
 		 * reply unlink.
 		 */
-		if (!unregistered && !ptlrpc_unregister_reply(req, 1)) {
+		if (!unregistered && !ptlrpc_unregister_reply(req, async)) {
 			/* start async bulk unlink too */
 			ptlrpc_unregister_bulk(req, 1);
 			continue;
 		}
 
-		if (!ptlrpc_unregister_bulk(req, 1))
+		if (!ptlrpc_unregister_bulk(req, async))
 			continue;
 
 		/* When calling interpret receive should already be finished. */
@@ -2271,8 +2293,12 @@ static void ptlrpc_interrupted_set(struct ptlrpc_request_set *set)
 
 	CDEBUG(D_RPCTRACE, "INTERRUPTED SET %p\n", set);
 	list_for_each_entry(req, &set->set_requests, rq_set_chain) {
+		if (req->rq_intr)
+			continue;
+
 		if (req->rq_phase != RQ_PHASE_RPC &&
-		    req->rq_phase != RQ_PHASE_UNREG_RPC)
+		    req->rq_phase != RQ_PHASE_UNREG_RPC &&
+		    !req->rq_allow_intr)
 			continue;
 
 		spin_lock(&req->rq_lock);
@@ -2368,7 +2394,8 @@ int ptlrpc_set_wait(const struct lu_env *env, struct ptlrpc_request_set *set)
 		CDEBUG(D_RPCTRACE, "set %p going to sleep for %lld seconds\n",
 		       set, timeout);
 
-		if (timeout == 0 && !signal_pending(current)) {
+		if ((timeout == 0 && !signal_pending(current)) ||
+		    set->set_allow_intr) {
 			/*
 			 * No requests are in-flight (ether timed out
 			 * or delayed), so we can allow interrupts.
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
