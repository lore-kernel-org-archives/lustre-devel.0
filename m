Return-Path: <SRS0=0agL=O7=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 19B96C433F5
	for <lustre-devel@archiver.kernel.org>; Mon, 11 Oct 2021 17:41:20 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id CA92960EB6
	for <lustre-devel@archiver.kernel.org>; Mon, 11 Oct 2021 17:41:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.1 mail.kernel.org CA92960EB6
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 638E9380EB7;
	Mon, 11 Oct 2021 10:41:07 -0700 (PDT)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id CC65721FDCE
 for <lustre-devel@lists.lustre.org>; Mon, 11 Oct 2021 10:40:56 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id BFE65465;
 Mon, 11 Oct 2021 13:40:51 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id BE8D6D5A46; Mon, 11 Oct 2021 13:40:51 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon, 11 Oct 2021 13:40:41 -0400
Message-Id: <1633974049-26490-13-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1633974049-26490-1-git-send-email-jsimmons@infradead.org>
References: <1633974049-26490-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 12/20] lustre: ptlrpc: use wait_woken() in
 ptlrpcd()
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

From: Mr NeilBrown <neilb@suse.de>

Using wait_event() to wait for ptlrpcd_check() to succeed is
problematic.  ptlrpcd_check() is complex and can wait for other
events.  This nested waiting can behave differently to expectation and
generates a warning

do not call blocking ops when !TASK_RUNNING

This happens because the task state is set to TASK_IDLE before
ptlrpcd_check() is calls.

A better approach (introduce for precisely this use-case) is to use
wait_woken() and woken_wake_function().

When a wake_up is requested on the waitq, woken_wake_function() sets a
flag to record the wakeup.  wait_woken() will wait until this flag is
set.  This way, the task state doesn't need to be set until after
ptlrpcd_check() has completed.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12362
Lustre-commit: 885b494632ca16d95 ("LU-12362 ptlrpc: use wait_woken() in ptlrpcd()")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/45069
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-by: xinliang <xinliang.liu@linaro.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ptlrpc/ptlrpcd.c | 23 ++++++++++++++++++-----
 1 file changed, 18 insertions(+), 5 deletions(-)

diff --git a/fs/lustre/ptlrpc/ptlrpcd.c b/fs/lustre/ptlrpc/ptlrpcd.c
index ed3f0e1..9cd9d39 100644
--- a/fs/lustre/ptlrpc/ptlrpcd.c
+++ b/fs/lustre/ptlrpc/ptlrpcd.c
@@ -435,18 +435,31 @@ static int ptlrpcd(void *arg)
 	 * new_req_list and ptlrpcd_check() moves them into the set.
 	 */
 	do {
+		DEFINE_WAIT_FUNC(wait, woken_wake_function);
 		time64_t timeout;
 
 		timeout = ptlrpc_set_next_timeout(set);
 
 		lu_context_enter(&env.le_ctx);
 		lu_context_enter(env.le_ses);
-		/* If timeout==0, wait indefinitely */
-		if (wait_event_idle_timeout(
-			    set->set_waitq,
-			    ptlrpcd_check(&env, pc),
-			    timeout ? (timeout * HZ) : MAX_SCHEDULE_TIMEOUT) == 0)
+
+		add_wait_queue(&set->set_waitq, &wait);
+		while (!ptlrpcd_check(&env, pc)) {
+			int ret;
+
+			if (timeout == 0)
+				ret = wait_woken(&wait, TASK_IDLE,
+						 MAX_SCHEDULE_TIMEOUT);
+			else
+				ret = wait_woken(&wait, TASK_IDLE,
+						 HZ * timeout);
+			if (ret != 0)
+				continue;
+			/* Timed out */
 			ptlrpc_expired_set(set);
+			break;
+		}
+		remove_wait_queue(&set->set_waitq, &wait);
 
 		lu_context_exit(&env.le_ctx);
 		lu_context_exit(env.le_ses);
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
