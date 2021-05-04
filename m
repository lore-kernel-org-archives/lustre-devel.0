Return-Path: <SRS0=WSMT=J7=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6D4BCC433ED
	for <lustre-devel@archiver.kernel.org>; Tue,  4 May 2021 00:11:11 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 2537D610E6
	for <lustre-devel@archiver.kernel.org>; Tue,  4 May 2021 00:11:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2537D610E6
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 68F2B21F83B;
	Mon,  3 May 2021 17:10:52 -0700 (PDT)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id F00D221F597
 for <lustre-devel@lists.lustre.org>; Mon,  3 May 2021 17:10:24 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 3E5E7EE5;
 Mon,  3 May 2021 20:10:20 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 3A7778AD38; Mon,  3 May 2021 20:10:20 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon,  3 May 2021 20:10:13 -0400
Message-Id: <1620087016-17857-12-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1620087016-17857-1-git-send-email-jsimmons@infradead.org>
References: <1620087016-17857-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 11/14] lustre: ptlrpc: idle import vs lock
 enqueue race
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
Cc: Alexander Boyko <c17825@cray.com>, Andriy Skulysh <c17819@cray.com>,
 Alexander Boyko <alexander.boyko@hpe.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Alexander Boyko <c17825@cray.com>

There is a window after ptlrpc_check_import_is_idle()
and setting LUSTRE_IMP_CONNECTING for lock enqueue.
The lock get granted on OST and is returned to the client.
Server's lock is destroyed on OST_DISCONNECT.

Perform import counters check with setting LUSTRE_IMP_CONNECTING.
A regression test_812c was added to sanity.

HPE-bug-id: LUS-8705
WC-bug-id: https://jira.whamcloud.com/browse/LU-14397
Lustre-commit: e6af3c529021976e ("LU-14397 ptlrpc: idle import vs lock enqueue race")
Signed-off-by: Andriy Skulysh <c17819@cray.com>
Signed-off-by: Alexander Boyko <alexander.boyko@hpe.com>
Reviewed-on: https://review.whamcloud.com/41403
Reviewed-by: Alex Zhuravlev <bzzz@whamcloud.com>
Reviewed-by: Andriy Skulysh <askulysh@gmail.com>
Reviewed-by: Alexey Lyashkov <alexey.lyashkov@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_net.h  |  1 +
 fs/lustre/include/obd_class.h   |  2 ++
 fs/lustre/include/obd_support.h |  1 +
 fs/lustre/obdclass/obd_mount.c  |  4 +--
 fs/lustre/osc/osc_lock.c        |  5 ++++
 fs/lustre/ptlrpc/client.c       | 11 +++++++
 fs/lustre/ptlrpc/import.c       | 63 ++++++++++++++++++++++++++++-------------
 fs/lustre/ptlrpc/pinger.c       |  5 ++--
 8 files changed, 69 insertions(+), 23 deletions(-)

diff --git a/fs/lustre/include/lustre_net.h b/fs/lustre/include/lustre_net.h
index e1eb888..f84ee46 100644
--- a/fs/lustre/include/lustre_net.h
+++ b/fs/lustre/include/lustre_net.h
@@ -1904,6 +1904,7 @@ int ptlrpc_request_bufs_pack(struct ptlrpc_request *request,
 			     u32 version, int opcode, char **bufs,
 			     struct ptlrpc_cli_ctx *ctx);
 void ptlrpc_req_finished(struct ptlrpc_request *request);
+void ptlrpc_req_finished_with_imp_lock(struct ptlrpc_request *request);
 struct ptlrpc_request *ptlrpc_request_addref(struct ptlrpc_request *req);
 struct ptlrpc_bulk_desc *ptlrpc_prep_bulk_imp(struct ptlrpc_request *req,
 					      unsigned int nfrags,
diff --git a/fs/lustre/include/obd_class.h b/fs/lustre/include/obd_class.h
index 1d1777a..eb52733 100644
--- a/fs/lustre/include/obd_class.h
+++ b/fs/lustre/include/obd_class.h
@@ -1713,6 +1713,8 @@ struct root_squash_info {
 	spinlock_t		rsi_lock;	/* protects rsi_nosquash_nids */
 };
 
+int server_name2index(const char *svname, u32 *idx, const char **endptr);
+
 /* linux-module.c */
 struct obd_ioctl_data;
 int obd_ioctl_getdata(struct obd_ioctl_data **data, int *len, void __user *arg);
diff --git a/fs/lustre/include/obd_support.h b/fs/lustre/include/obd_support.h
index 878a5cd..4628fab 100644
--- a/fs/lustre/include/obd_support.h
+++ b/fs/lustre/include/obd_support.h
@@ -365,6 +365,7 @@
 #define OBD_FAIL_PTLRPC_BULK_REPLY_ATTACH		0x522
 #define OBD_FAIL_PTLRPC_ROUND_XID			0x530
 #define OBD_FAIL_PTLRPC_CONNECT_RACE			0x531
+#define OBD_FAIL_PTLRPC_IDLE_RACE			0x533
 
 #define OBD_FAIL_OBD_PING_NET				0x600
 /*	OBD_FAIL_OBD_LOG_CANCEL_NET	0x601 obsolete since 1.5 */
diff --git a/fs/lustre/obdclass/obd_mount.c b/fs/lustre/obdclass/obd_mount.c
index fbad459..0a5e338 100644
--- a/fs/lustre/obdclass/obd_mount.c
+++ b/fs/lustre/obdclass/obd_mount.c
@@ -618,8 +618,7 @@ int server_name2fsname(const char *svname, char *fsname,
  * rc < 0  on error
  * if endptr isn't NULL it is set to end of name
  */
-static int server_name2index(const char *svname, u32 *idx,
-			     const char **endptr)
+int server_name2index(const char *svname, u32 *idx, const char **endptr)
 {
 	unsigned long index;
 	int rc;
@@ -658,6 +657,7 @@ static int server_name2index(const char *svname, u32 *idx,
 
 	return rc;
 }
+EXPORT_SYMBOL(server_name2index);
 
 /*************** mount common between server and client ***************/
 
diff --git a/fs/lustre/osc/osc_lock.c b/fs/lustre/osc/osc_lock.c
index de96fc0..e0de371 100644
--- a/fs/lustre/osc/osc_lock.c
+++ b/fs/lustre/osc/osc_lock.c
@@ -1037,6 +1037,11 @@ static int osc_lock_enqueue(const struct lu_env *env,
 		if (osc_lock_is_lockless(oscl)) {
 			oio->oi_lockless = 1;
 		} else if (!async) {
+			if (OBD_FAIL_PRECHECK(OBD_FAIL_PTLRPC_IDLE_RACE)) {
+				OBD_RACE(OBD_FAIL_PTLRPC_IDLE_RACE);
+				set_current_state(TASK_UNINTERRUPTIBLE);
+				schedule_timeout(HZ / 2);
+			}
 			LASSERT(oscl->ols_state == OLS_GRANTED);
 			LASSERT(oscl->ols_hold);
 			LASSERT(oscl->ols_dlmlock);
diff --git a/fs/lustre/ptlrpc/client.c b/fs/lustre/ptlrpc/client.c
index 97f1251..a812b29 100644
--- a/fs/lustre/ptlrpc/client.c
+++ b/fs/lustre/ptlrpc/client.c
@@ -2543,6 +2543,17 @@ static void __ptlrpc_free_req(struct ptlrpc_request *request, int locked)
 		ptlrpc_request_cache_free(request);
 }
 
+static int __ptlrpc_req_finished(struct ptlrpc_request *request, int locked);
+/**
+ * Drop one request reference. Must be called with import imp_lock held.
+ * When reference count drops to zero, request is freed.
+ */
+void ptlrpc_req_finished_with_imp_lock(struct ptlrpc_request *request)
+{
+	assert_spin_locked(&request->rq_import->imp_lock);
+	(void)__ptlrpc_req_finished(request, 1);
+}
+
 /**
  * Helper function
  * Drops one reference count for request @request.
diff --git a/fs/lustre/ptlrpc/import.c b/fs/lustre/ptlrpc/import.c
index 317f28c..1f31edb 100644
--- a/fs/lustre/ptlrpc/import.c
+++ b/fs/lustre/ptlrpc/import.c
@@ -1653,7 +1653,6 @@ static struct ptlrpc_request *ptlrpc_disconnect_prep_req(struct obd_import *imp)
 	req->rq_timeout = min_t(timeout_t, req->rq_timeout,
 				INITIAL_CONNECT_TIMEOUT);
 
-	import_set_state(imp, LUSTRE_IMP_CONNECTING);
 	req->rq_send_state =  LUSTRE_IMP_CONNECTING;
 	ptlrpc_request_set_replen(req);
 
@@ -1701,16 +1700,20 @@ int ptlrpc_disconnect_import(struct obd_import *imp, int noclose)
 				!ptlrpc_import_in_recovery(imp));
 	}
 
-	spin_lock(&imp->imp_lock);
-	if (imp->imp_state != LUSTRE_IMP_FULL)
-		goto out;
-	spin_unlock(&imp->imp_lock);
-
 	req = ptlrpc_disconnect_prep_req(imp);
 	if (IS_ERR(req)) {
 		rc = PTR_ERR(req);
 		goto set_state;
 	}
+
+	spin_lock(&imp->imp_lock);
+	if (imp->imp_state != LUSTRE_IMP_FULL) {
+		ptlrpc_req_finished_with_imp_lock(req);
+		goto out;
+	}
+	import_set_state_nolock(imp, LUSTRE_IMP_CONNECTING);
+	spin_unlock(&imp->imp_lock);
+
 	rc = ptlrpc_queue_wait(req);
 	ptlrpc_req_finished(req);
 
@@ -1794,6 +1797,21 @@ static int ptlrpc_disconnect_idle_interpret(const struct lu_env *env,
 	return 0;
 }
 
+static bool ptlrpc_can_idle(struct obd_import *imp)
+{
+	struct ldlm_namespace *ns = imp->imp_obd->obd_namespace;
+
+	/* one request for disconnect rpc */
+	if (atomic_read(&imp->imp_reqs) > 1)
+		return false;
+
+	/* any lock increases ns_bref being a resource holder */
+	if (ns && atomic_read(&ns->ns_bref) > 0)
+		return false;
+
+	return true;
+}
+
 int ptlrpc_disconnect_and_idle_import(struct obd_import *imp)
 {
 	struct ptlrpc_request *req;
@@ -1804,31 +1822,38 @@ int ptlrpc_disconnect_and_idle_import(struct obd_import *imp)
 	if (ptlrpc_import_in_recovery(imp))
 		return 0;
 
-	spin_lock(&imp->imp_lock);
+	req = ptlrpc_disconnect_prep_req(imp);
+	if (IS_ERR(req))
+		return PTR_ERR(req);
 
-	if (imp->imp_state != LUSTRE_IMP_FULL) {
+	req->rq_interpret_reply = ptlrpc_disconnect_idle_interpret;
+
+	if (OBD_FAIL_PRECHECK(OBD_FAIL_PTLRPC_IDLE_RACE)) {
+		u32 idx;
+
+		server_name2index(imp->imp_obd->obd_name, &idx, NULL);
+		if (idx == 0)
+			OBD_RACE(OBD_FAIL_PTLRPC_IDLE_RACE);
+	}
+
+	spin_lock(&imp->imp_lock);
+	if (imp->imp_state != LUSTRE_IMP_FULL || !ptlrpc_can_idle(imp)) {
+		ptlrpc_req_finished_with_imp_lock(req);
 		spin_unlock(&imp->imp_lock);
 		return 0;
 	}
+	import_set_state_nolock(imp, LUSTRE_IMP_CONNECTING);
+	/* don't make noise at reconnection */
+	imp->imp_was_idle = 1;
 	spin_unlock(&imp->imp_lock);
 
-	req = ptlrpc_disconnect_prep_req(imp);
-	if (IS_ERR(req))
-		return PTR_ERR(req);
-
 	CDEBUG_LIMIT(imp->imp_idle_debug, "%s: disconnect after %llus idle\n",
 		     imp->imp_obd->obd_name,
 		     ktime_get_real_seconds() - imp->imp_last_reply_time);
 
-	/* don't make noise at reconnection */
-	spin_lock(&imp->imp_lock);
-	imp->imp_was_idle = 1;
-	spin_unlock(&imp->imp_lock);
-
-	req->rq_interpret_reply = ptlrpc_disconnect_idle_interpret;
 	ptlrpcd_add_req(req);
 
-	return 0;
+	return 1;
 }
 EXPORT_SYMBOL(ptlrpc_disconnect_and_idle_import);
 
diff --git a/fs/lustre/ptlrpc/pinger.c b/fs/lustre/ptlrpc/pinger.c
index f565982..76a0844 100644
--- a/fs/lustre/ptlrpc/pinger.c
+++ b/fs/lustre/ptlrpc/pinger.c
@@ -127,8 +127,9 @@ static int ptlrpc_ping(struct obd_import *imp)
 {
 	struct ptlrpc_request *req;
 
-	if (ptlrpc_check_import_is_idle(imp))
-		return ptlrpc_disconnect_and_idle_import(imp);
+	if (ptlrpc_check_import_is_idle(imp) &&
+	    ptlrpc_disconnect_and_idle_import(imp) == 1)
+		return 0;
 
 	req = ptlrpc_prep_ping(imp);
 	if (!req) {
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
