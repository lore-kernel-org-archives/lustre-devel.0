Return-Path: <SRS0=FD7t=JM=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9711EC433B4
	for <lustre-devel@archiver.kernel.org>; Thu, 15 Apr 2021 04:04:47 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 4E456610CB
	for <lustre-devel@archiver.kernel.org>; Thu, 15 Apr 2021 04:04:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4E456610CB
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 3206632B1EE;
	Wed, 14 Apr 2021 21:03:51 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id C870F32F6A5
 for <lustre-devel@lists.lustre.org>; Wed, 14 Apr 2021 21:02:58 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id C390F100F372;
 Thu, 15 Apr 2021 00:02:45 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id C21AD91884; Thu, 15 Apr 2021 00:02:45 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Thu, 15 Apr 2021 00:02:34 -0400
Message-Id: <1618459361-17909-43-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1618459361-17909-1-git-send-email-jsimmons@infradead.org>
References: <1618459361-17909-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 42/49] lustre: ptlrpc: don't use
 list_for_each_entry_safe unnecessarily.
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
Cc: Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: NeilBrown <neilb@suse.de>

list_for_each_entry_safe() is only needed if the body of the
loop might change the list, or if it might drop a lock that would
otherwise prevent the list from being changed.

When the body does neither of these, list_for_each_entry() should be
preferred as it makes the behaviour of the loop more clear to readers.

In each of the cases changed there, the list cannot change while the
loop proceeds.

WC-bug-id: https://jira.whamcloud.com/browse/LU-6142
Lustre-commit: 5c89fa57cb2dfff6 ("LU-6142 lustre: ptlrpc: don't use list_for_each_entry_safe unnecessarily.")
Signed-off-by: NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/41939
Reviewed-by: Arshad Hussain <arshad.hussain@aeoncomputing.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ptlrpc/client.c  | 10 +++++-----
 fs/lustre/ptlrpc/import.c  | 14 +++++++-------
 fs/lustre/ptlrpc/ptlrpcd.c |  4 ++--
 fs/lustre/ptlrpc/recover.c | 14 +++++++-------
 4 files changed, 21 insertions(+), 21 deletions(-)

diff --git a/fs/lustre/ptlrpc/client.c b/fs/lustre/ptlrpc/client.c
index 20c00ad..04e8fec 100644
--- a/fs/lustre/ptlrpc/client.c
+++ b/fs/lustre/ptlrpc/client.c
@@ -3060,7 +3060,7 @@ int ptlrpc_replay_req(struct ptlrpc_request *req)
  */
 void ptlrpc_abort_inflight(struct obd_import *imp)
 {
-	struct ptlrpc_request *req, *n;
+	struct ptlrpc_request *req;
 
 	/*
 	 * Make sure that no new requests get processed for this import.
@@ -3074,7 +3074,7 @@ void ptlrpc_abort_inflight(struct obd_import *imp)
 	 * locked?  Also, how do we know if the requests on the list are
 	 * being freed at this time?
 	 */
-	list_for_each_entry_safe(req, n, &imp->imp_sending_list, rq_list) {
+	list_for_each_entry(req, &imp->imp_sending_list, rq_list) {
 		DEBUG_REQ(D_RPCTRACE, req, "inflight");
 
 		spin_lock(&req->rq_lock);
@@ -3086,7 +3086,7 @@ void ptlrpc_abort_inflight(struct obd_import *imp)
 		spin_unlock(&req->rq_lock);
 	}
 
-	list_for_each_entry_safe(req, n, &imp->imp_delayed_list, rq_list) {
+	list_for_each_entry(req, &imp->imp_delayed_list, rq_list) {
 		DEBUG_REQ(D_RPCTRACE, req, "aborting waiting req");
 
 		spin_lock(&req->rq_lock);
@@ -3112,9 +3112,9 @@ void ptlrpc_abort_inflight(struct obd_import *imp)
  */
 void ptlrpc_abort_set(struct ptlrpc_request_set *set)
 {
-	struct ptlrpc_request *req, *tmp;
+	struct ptlrpc_request *req;
 
-	list_for_each_entry_safe(req, tmp, &set->set_requests, rq_set_chain) {
+	list_for_each_entry(req, &set->set_requests, rq_set_chain) {
 		spin_lock(&req->rq_lock);
 		if (req->rq_phase != RQ_PHASE_RPC) {
 			spin_unlock(&req->rq_lock);
diff --git a/fs/lustre/ptlrpc/import.c b/fs/lustre/ptlrpc/import.c
index 35c4f83..5e33ebc 100644
--- a/fs/lustre/ptlrpc/import.c
+++ b/fs/lustre/ptlrpc/import.c
@@ -271,11 +271,11 @@ void ptlrpc_deactivate_import(struct obd_import *imp)
 static time64_t ptlrpc_inflight_timeout(struct obd_import *imp)
 {
 	time64_t now = ktime_get_real_seconds();
-	struct ptlrpc_request *req, *n;
+	struct ptlrpc_request *req;
 	time64_t timeout = 0;
 
 	spin_lock(&imp->imp_lock);
-	list_for_each_entry_safe(req, n, &imp->imp_sending_list, rq_list)
+	list_for_each_entry(req, &imp->imp_sending_list, rq_list)
 		timeout = max(ptlrpc_inflight_deadline(req, now), timeout);
 
 	spin_unlock(&imp->imp_lock);
@@ -290,7 +290,7 @@ static time64_t ptlrpc_inflight_timeout(struct obd_import *imp)
  */
 void ptlrpc_invalidate_import(struct obd_import *imp)
 {
-	struct ptlrpc_request *req, *n;
+	struct ptlrpc_request *req;
 	time64_t timeout;
 	int rc;
 
@@ -370,13 +370,13 @@ void ptlrpc_invalidate_import(struct obd_import *imp)
 				 */
 				rc = 0;
 			} else {
-				list_for_each_entry_safe(req, n,
-							 &imp->imp_sending_list, rq_list) {
+				list_for_each_entry(req, &imp->imp_sending_list,
+						    rq_list) {
 					DEBUG_REQ(D_ERROR, req,
 						  "still on sending list");
 				}
-				list_for_each_entry_safe(req, n,
-							 &imp->imp_delayed_list, rq_list) {
+				list_for_each_entry(req, &imp->imp_delayed_list,
+						    rq_list) {
 					DEBUG_REQ(D_ERROR, req,
 						  "still on delayed list");
 				}
diff --git a/fs/lustre/ptlrpc/ptlrpcd.c b/fs/lustre/ptlrpc/ptlrpcd.c
index b0b81cc..ef24b0e 100644
--- a/fs/lustre/ptlrpc/ptlrpcd.c
+++ b/fs/lustre/ptlrpc/ptlrpcd.c
@@ -200,12 +200,12 @@ void ptlrpcd_wake(struct ptlrpc_request *req)
 static int ptlrpcd_steal_rqset(struct ptlrpc_request_set *des,
 			       struct ptlrpc_request_set *src)
 {
-	struct ptlrpc_request *req, *tmp;
+	struct ptlrpc_request *req;
 	int rc = 0;
 
 	spin_lock(&src->set_new_req_lock);
 	if (likely(!list_empty(&src->set_new_requests))) {
-		list_for_each_entry_safe(req, tmp, &src->set_new_requests, rq_set_chain)
+		list_for_each_entry(req, &src->set_new_requests, rq_set_chain)
 			req->rq_set = des;
 
 		list_splice_init(&src->set_new_requests, &des->set_requests);
diff --git a/fs/lustre/ptlrpc/recover.c b/fs/lustre/ptlrpc/recover.c
index 09ea3b3..104af56 100644
--- a/fs/lustre/ptlrpc/recover.c
+++ b/fs/lustre/ptlrpc/recover.c
@@ -66,7 +66,7 @@ void ptlrpc_initiate_recovery(struct obd_import *imp)
 int ptlrpc_replay_next(struct obd_import *imp, int *inflight)
 {
 	int rc = 0;
-	struct ptlrpc_request *req = NULL, *pos;
+	struct ptlrpc_request *req = NULL;
 	u64 last_transno;
 
 	*inflight = 0;
@@ -120,8 +120,8 @@ int ptlrpc_replay_next(struct obd_import *imp, int *inflight)
 	if (!req) {
 		struct ptlrpc_request *tmp;
 
-		list_for_each_entry_safe(tmp, pos, &imp->imp_replay_list,
-					 rq_replay_list) {
+		list_for_each_entry(tmp, &imp->imp_replay_list,
+				    rq_replay_list) {
 			if (tmp->rq_transno > last_transno) {
 				req = tmp;
 				break;
@@ -172,7 +172,7 @@ int ptlrpc_replay_next(struct obd_import *imp, int *inflight)
  */
 int ptlrpc_resend(struct obd_import *imp)
 {
-	struct ptlrpc_request *req, *next;
+	struct ptlrpc_request *req;
 
 	/* As long as we're in recovery, nothing should be added to the sending
 	 * list, so we don't need to hold the lock during this iteration and
@@ -186,7 +186,7 @@ int ptlrpc_resend(struct obd_import *imp)
 		return -1;
 	}
 
-	list_for_each_entry_safe(req, next, &imp->imp_sending_list, rq_list) {
+	list_for_each_entry(req, &imp->imp_sending_list, rq_list) {
 		LASSERTF((long)req > PAGE_SIZE && req != LP_POISON,
 			 "req %p bad\n", req);
 		LASSERTF(req->rq_type != LI_POISON, "req %p freed\n", req);
@@ -211,10 +211,10 @@ int ptlrpc_resend(struct obd_import *imp)
  */
 void ptlrpc_wake_delayed(struct obd_import *imp)
 {
-	struct ptlrpc_request *req, *pos;
+	struct ptlrpc_request *req;
 
 	spin_lock(&imp->imp_lock);
-	list_for_each_entry_safe(req, pos, &imp->imp_delayed_list, rq_list) {
+	list_for_each_entry(req, &imp->imp_delayed_list, rq_list) {
 		DEBUG_REQ(D_HA, req, "waking (set %p):", req->rq_set);
 		ptlrpc_client_wake_req(req);
 	}
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
