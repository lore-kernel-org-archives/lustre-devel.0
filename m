Return-Path: <SRS0=2ypu=OM=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 20CD4C433F5
	for <lustre-devel@archiver.kernel.org>; Wed, 22 Sep 2021 02:21:58 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id E00056112F
	for <lustre-devel@archiver.kernel.org>; Wed, 22 Sep 2021 02:21:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.1 mail.kernel.org E00056112F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 0BD0C21F349;
	Tue, 21 Sep 2021 19:21:57 -0700 (PDT)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id BC6CF21F232
 for <lustre-devel@lists.lustre.org>; Tue, 21 Sep 2021 19:20:09 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 23444468;
 Tue, 21 Sep 2021 22:20:04 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 20123FF4C1; Tue, 21 Sep 2021 22:20:04 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Tue, 21 Sep 2021 22:19:50 -0400
Message-Id: <1632277201-6920-14-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1632277201-6920-1-git-send-email-jsimmons@infradead.org>
References: <1632277201-6920-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 13/24] lustre: ptlrpc: two replay lock threads
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
Cc: Vitaly Fertman <vitaly.fertman@hpe.com>, Vitaly Fertman <c17818@cray.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Vitaly Fertman <c17818@cray.com>

conflict to each other what leads to:
        ASSERTION( atomic_read(&imp->imp_replay_inflight) == 1 )

replay_lock_interpret() does ptlrpc_connect_import() on error, and one
thread will appear starting with connect reply interpret.

replay_lock_interpret() also wakes up ldlm_lock_replay_thread() which
does ptlrpc_import_recovery_state_machine().

It may happen that both threads will get to ldlm_replay_locks() on the
next round at the same time, both increment imp_replay_inflight and
the second one will assert.

The problem appeared in LU-13600 which added ldlm_lock_replay_thread()
with the ptlrpc_import_recovery_state_machine() call.

HPE-bug-id: LUS-10147
WC-bug-id: https://jira.whamcloud.com/browse/LU-14847
Lustre-commit: d7d7eb50c8f5fd3fc ("LU-14847 ptlrpc: two replay lock threads")
Fixes: 8cc7f22847 ("lustre: ptlrpc: limit rate of lock replays")
Signed-off-by: Vitaly Fertman <vitaly.fertman@hpe.com>
Reviewed-by: Andriy Skulysh <andriy.skulysh@hpe.com>
Reviewed-by: Alexander Zarochentsev <alexander.zarochentsev@hpe.com>
Reviewed-on: https://es-gerrit.dev.cray.com/158931
Reviewed-on: https://review.whamcloud.com/44294
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Mike Pershin <mpershin@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ldlm/ldlm_request.c   | 10 +++++++---
 fs/lustre/obdclass/obd_config.c |  4 ++--
 2 files changed, 9 insertions(+), 5 deletions(-)

diff --git a/fs/lustre/ldlm/ldlm_request.c b/fs/lustre/ldlm/ldlm_request.c
index 7718e07..746c45b 100644
--- a/fs/lustre/ldlm/ldlm_request.c
+++ b/fs/lustre/ldlm/ldlm_request.c
@@ -2253,7 +2253,8 @@ int __ldlm_replay_locks(struct obd_import *imp, bool rate_limit)
 	struct ldlm_lock *lock;
 	int rc = 0;
 
-	LASSERT(atomic_read(&imp->imp_replay_inflight) == 1);
+	while (atomic_read(&imp->imp_replay_inflight) != 1)
+		cond_resched();
 
 	/* don't replay locks if import failed recovery */
 	if (imp->imp_vbr_failed)
@@ -2311,9 +2312,12 @@ int ldlm_replay_locks(struct obd_import *imp)
 	struct task_struct *task;
 	int rc = 0;
 
-	class_import_get(imp);
 	/* ensure this doesn't fall to 0 before all have been queued */
-	atomic_inc(&imp->imp_replay_inflight);
+	if (atomic_inc_return(&imp->imp_replay_inflight) > 1) {
+		atomic_dec(&imp->imp_replay_inflight);
+		return 0;
+	}
+	class_import_get(imp);
 
 	task = kthread_run(ldlm_lock_replay_thread, imp, "ldlm_lock_replay");
 	if (IS_ERR(task)) {
diff --git a/fs/lustre/obdclass/obd_config.c b/fs/lustre/obdclass/obd_config.c
index 3a0dbd5..cb70ed5 100644
--- a/fs/lustre/obdclass/obd_config.c
+++ b/fs/lustre/obdclass/obd_config.c
@@ -519,8 +519,8 @@ struct obd_device *class_incref(struct obd_device *obd,
 {
 	lu_ref_add_atomic(&obd->obd_reference, scope, source);
 	atomic_inc(&obd->obd_refcount);
-	CDEBUG(D_INFO, "incref %s (%p) now %d\n", obd->obd_name, obd,
-	       atomic_read(&obd->obd_refcount));
+	CDEBUG(D_INFO, "incref %s (%p) now %d - %s\n", obd->obd_name, obd,
+	       atomic_read(&obd->obd_refcount), scope);
 
 	return obd;
 }
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
