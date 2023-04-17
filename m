Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 3B336C77B76
	for <lustre-devel@archiver.kernel.org>; Mon, 17 Apr 2023 13:57:36 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4Q0T2f4Gndz21Hy;
	Mon, 17 Apr 2023 06:50:18 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4Q0T0S0N4Kz1yGh
 for <lustre-devel@lists.lustre.org>; Mon, 17 Apr 2023 06:48:23 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 84036100848E;
 Mon, 17 Apr 2023 09:47:24 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 82B45379; Mon, 17 Apr 2023 09:47:24 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon, 17 Apr 2023 09:47:08 -0400
Message-Id: <1681739243-29375-13-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1681739243-29375-1-git-send-email-jsimmons@infradead.org>
References: <1681739243-29375-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 12/27] lustre: obdclass: fix rpc slot leakage
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
Cc: Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Alex Zhuravlev <bzzz@whamcloud.com>

obd_get_mod_rpc_slot() can race with obd_put_mod_rpc_slot():
finishing wait_woken() resets WQ_FLAG_WOKEN (which is set
when the corresponding thread gets a slot incrementing
cl_mod_rpcs_in_flight. then another thread execting
__wake_up_locked_key() may find that wq_entry again and call
claim_mod_rpc_function() one more time again incrementing
cl_mod_rpc_in_flight. thus it's incremented twice for a
single obd_get_mod_rpc_slot().

flags &= ~WQ_FLAG_WOKEN
list_add()
wait_woken()
  schedule              claim_mod_rpc_function()
                                cl_mod_rpcs_in_flight++
                                wake_up()

  flags &= ~WQ_FLAG_WOKEN

                        #3: obd_put_mod_rpc_slot()
                        claim_mod_rpc_function()
                                cl_mod_rpcs_in_flight++
                                wake_up()
list_del()

the patch introduces a replacement for WQ_FLAG_WOKEN which is never
reset once set.

Fixes: 6d398c0843 ("lustre: obdclass: improve precision of wakeups for mod_rpcs")
WC-bug-id: https://jira.whamcloud.com/browse/LU-16633
Lustre-commit: 91a3726f313df33e09 ("LU-16633 obdclass: fix rpc slot leakage")
Signed-off-by: Alex Zhuravlev <bzzz@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/50261
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Lai Siyao <lai.siyao@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/mdc/mdc_request.c |  3 +++
 fs/lustre/obdclass/genops.c | 11 +++++++----
 2 files changed, 10 insertions(+), 4 deletions(-)

diff --git a/fs/lustre/mdc/mdc_request.c b/fs/lustre/mdc/mdc_request.c
index 58ea982..15e58e8 100644
--- a/fs/lustre/mdc/mdc_request.c
+++ b/fs/lustre/mdc/mdc_request.c
@@ -2964,6 +2964,9 @@ static int mdc_precleanup(struct obd_device *obd)
 
 static int mdc_cleanup(struct obd_device *obd)
 {
+	struct client_obd *cli = &obd->u.cli;
+
+	LASSERT(cli->cl_mod_rpcs_in_flight == 0);
 	return osc_cleanup_common(obd);
 }
 
diff --git a/fs/lustre/obdclass/genops.c b/fs/lustre/obdclass/genops.c
index b6bde00..43772aa 100644
--- a/fs/lustre/obdclass/genops.c
+++ b/fs/lustre/obdclass/genops.c
@@ -1487,6 +1487,7 @@ int obd_mod_rpc_stats_seq_show(struct client_obd *cli, struct seq_file *seq)
 struct mod_waiter {
 	struct client_obd *cli;
 	bool close_req;
+	bool woken;
 	wait_queue_entry_t wqe;
 };
 static int claim_mod_rpc_function(wait_queue_entry_t *wq_entry,
@@ -1499,10 +1500,9 @@ static int claim_mod_rpc_function(wait_queue_entry_t *wq_entry,
 	int ret;
 
 	/* As woken_wake_function() doesn't remove us from the wait_queue,
-	 * we could get called twice for the same thread - take care.
+	 * we use own flag to ensure we're called just once.
 	 */
-	if (wq_entry->flags & WQ_FLAG_WOKEN)
-		/* Already woke this thread, don't try again */
+	if (w->woken)
 		return 0;
 
 	/* A slot is available if
@@ -1516,6 +1516,7 @@ static int claim_mod_rpc_function(wait_queue_entry_t *wq_entry,
 		if (w->close_req)
 			cli->cl_close_rpcs_in_flight++;
 		ret = woken_wake_function(wq_entry, mode, flags, key);
+		w->woken = true;
 	} else if (cli->cl_close_rpcs_in_flight)
 		/* No other waiter could be woken */
 		ret = -1;
@@ -1543,6 +1544,7 @@ u16 obd_get_mod_rpc_slot(struct client_obd *cli, u32 opc)
 	struct mod_waiter wait = {
 		.cli = cli,
 		.close_req = (opc == MDS_CLOSE),
+		.woken = false,
 	};
 	u16 i, max;
 
@@ -1556,7 +1558,8 @@ u16 obd_get_mod_rpc_slot(struct client_obd *cli, u32 opc)
 	 * and there will be no need to wait.
 	 */
 	wake_up_locked(&cli->cl_mod_rpcs_waitq);
-	if (!(wait.wqe.flags & WQ_FLAG_WOKEN)) {
+	/* XXX: handle spurious wakeups (from unknown yet source */
+	while (wait.woken == false) {
 		spin_unlock_irq(&cli->cl_mod_rpcs_waitq.lock);
 		wait_woken(&wait.wqe, TASK_UNINTERRUPTIBLE,
 			   MAX_SCHEDULE_TIMEOUT);
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
