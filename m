Return-Path: <SRS0=HxeM=ML=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E98E4C07E9B
	for <lustre-devel@archiver.kernel.org>; Mon, 19 Jul 2021 12:32:25 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id A60A96112D
	for <lustre-devel@archiver.kernel.org>; Mon, 19 Jul 2021 12:32:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A60A96112D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 4519334F996;
	Mon, 19 Jul 2021 05:32:22 -0700 (PDT)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 412E934F962
 for <lustre-devel@lists.lustre.org>; Mon, 19 Jul 2021 05:32:17 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 8B9C16B0;
 Mon, 19 Jul 2021 08:32:15 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 82859BD1C6; Mon, 19 Jul 2021 08:32:15 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon, 19 Jul 2021 08:31:56 -0400
Message-Id: <1626697933-6971-2-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1626697933-6971-1-git-send-email-jsimmons@infradead.org>
References: <1626697933-6971-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 01/18] lustre: statahead: update task
 management code
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

From: "Mr. NeilBrown" <neilb@suse.de>

When the rewrite to remove ptlrpc_thread from statahead
was ported to OpenSFS, a number of improvements were made.
This patch back-ports those to Linux

And import bug-fix is in ll_agl_add() where we now call
wake_up_process() inside a spinlock, so we can be sure the task pointer
is not NULL.

A few while-loops waiting for events have been simplified to only check
each 'continue' condition once instead of checking before doing an
action, then checking it before sleeping.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12780
Lustre-commit: 5b630935452d5d8d7 ("LU-12780 llite: don't use ptlrpc_thread for sai_agl_thread")
Lustre-commit: 6bf49037b3a134587 ("LU-12780 llite: avoid ptlrpc_thread for ll_statahead_thread")
Signed-off-by: Mr. NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/36258
Reviewed-on: https://review.whamcloud.com/36259
Reviewed-by: Lai Siyao <lai.siyao@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Shaun Tancheff <shaun.tancheff@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/statahead.c | 95 +++++++++++++++++++++++----------------------
 1 file changed, 49 insertions(+), 46 deletions(-)

diff --git a/fs/lustre/llite/statahead.c b/fs/lustre/llite/statahead.c
index 282cb5a..40ea206 100644
--- a/fs/lustre/llite/statahead.c
+++ b/fs/lustre/llite/statahead.c
@@ -35,6 +35,7 @@
 #include <linux/mm.h>
 #include <linux/highmem.h>
 #include <linux/pagemap.h>
+#include <linux/delay.h>
 
 #define DEBUG_SUBSYSTEM S_LLITE
 
@@ -299,7 +300,6 @@ static void sa_put(struct ll_statahead_info *sai, struct sa_entry *entry,
 	if (sai->sai_task)
 		wake_up_process(sai->sai_task);
 	spin_unlock(&lli->lli_sa_lock);
-
 }
 
 /*
@@ -898,37 +898,40 @@ static int ll_agl_thread(void *arg)
 	CDEBUG(D_READA, "agl thread started: sai %p, parent %pd\n",
 	       sai, parent);
 
-	while (!kthread_should_stop()) {
-
+	while (({set_current_state(TASK_IDLE);
+		 !kthread_should_stop(); })) {
 		spin_lock(&plli->lli_agl_lock);
-		/* The statahead thread maybe help to process AGL entries,
-		 * so check whether list empty again.
-		 */
 		clli = list_first_entry_or_null(&sai->sai_agls,
 						struct ll_inode_info,
 						lli_agl_list);
 		if (clli) {
+			__set_current_state(TASK_RUNNING);
 			list_del_init(&clli->lli_agl_list);
 			spin_unlock(&plli->lli_agl_lock);
 			ll_agl_trigger(&clli->lli_vfs_inode, sai);
 			cond_resched();
 		} else {
 			spin_unlock(&plli->lli_agl_lock);
-		}
-
-		set_current_state(TASK_IDLE);
-		if (list_empty(&sai->sai_agls) &&
-		    !kthread_should_stop())
 			schedule();
-		__set_current_state(TASK_RUNNING);
+		}
 	}
+	__set_current_state(TASK_RUNNING);
 	return 0;
 }
 
 static void ll_stop_agl(struct ll_statahead_info *sai)
 {
-	struct ll_inode_info *plli = ll_i2info(sai->sai_dentry->d_inode);
+	struct dentry *parent = sai->sai_dentry;
+	struct ll_inode_info *plli = ll_i2info(parent->d_inode);
 	struct ll_inode_info *clli;
+	struct task_struct *agl_task;
+
+	spin_lock(&plli->lli_agl_lock);
+	agl_task = sai->sai_agl_task;
+	sai->sai_agl_task = NULL;
+	spin_unlock(&plli->lli_agl_lock);
+	if (!agl_task)
+		return;
 
 	CDEBUG(D_READA, "stop agl thread: sai %p pid %u\n",
 	       sai, (unsigned int)sai->sai_agl_task->pid);
@@ -1076,14 +1079,19 @@ static int ll_statahead_thread(void *arg)
 
 			fid_le_to_cpu(&fid, &ent->lde_fid);
 
-			do {
-				sa_handle_callback(sai);
+			while (({set_current_state(TASK_IDLE);
+				 sai->sai_task; })) {
+				if (sa_has_callback(sai)) {
+					__set_current_state(TASK_RUNNING);
+					sa_handle_callback(sai);
+				}
 
 				spin_lock(&lli->lli_agl_lock);
 				while (sa_sent_full(sai) &&
 				       !agl_list_empty(sai)) {
 					struct ll_inode_info *clli;
 
+					__set_current_state(TASK_RUNNING);
 					clli = list_first_entry(&sai->sai_agls,
 								struct ll_inode_info,
 								lli_agl_list);
@@ -1097,15 +1105,11 @@ static int ll_statahead_thread(void *arg)
 				}
 				spin_unlock(&lli->lli_agl_lock);
 
-				set_current_state(TASK_IDLE);
-				if (sa_sent_full(sai) &&
-				    !sa_has_callback(sai) &&
-				    agl_list_empty(sai) &&
-				    sai->sai_task)
-					/* wait for spare statahead window */
-					schedule();
-				__set_current_state(TASK_RUNNING);
-			} while (sa_sent_full(sai) && sai->sai_task);
+				if (!sa_sent_full(sai))
+					break;
+				schedule();
+			}
+			__set_current_state(TASK_RUNNING);
 
 			sa_statahead(parent, name, namelen, &fid);
 		}
@@ -1138,21 +1142,18 @@ static int ll_statahead_thread(void *arg)
 	 * statahead is finished, but statahead entries need to be cached, wait
 	 * for file release to stop me.
 	 */
-	while (sai->sai_task) {
-		sa_handle_callback(sai);
-
-		set_current_state(TASK_IDLE);
-		/* ensure we see the NULL stored by
-		 * ll_deauthorize_statahead()
-		 */
-		if (!sa_has_callback(sai) &&
-		    smp_load_acquire(&sai->sai_task))
+	while (({set_current_state(TASK_IDLE);
+		 sai->sai_task; })) {
+		if (sa_has_callback(sai)) {
+			__set_current_state(TASK_RUNNING);
+			sa_handle_callback(sai);
+		} else {
 			schedule();
-		__set_current_state(TASK_RUNNING);
+		}
 	}
+	__set_current_state(TASK_RUNNING);
 out:
-	if (sai->sai_agl_task)
-		ll_stop_agl(sai);
+	ll_stop_agl(sai);
 
 	/*
 	 * wait for inflight statahead RPCs to finish, and then we can free sai
@@ -1160,7 +1161,7 @@ static int ll_statahead_thread(void *arg)
 	 */
 	while (sai->sai_sent != sai->sai_replied) {
 		/* in case we're not woken up, timeout wait */
-		schedule_timeout_idle(HZ>>3);
+		msleep(125);
 	}
 
 	/* release resources held by statahead RPCs */
@@ -1176,7 +1177,7 @@ static int ll_statahead_thread(void *arg)
 	wake_up(&sai->sai_waitq);
 	ll_sai_put(sai);
 
-	do_exit(rc);
+	return rc;
 }
 
 /* authorize opened dir handle @key to statahead */
@@ -1220,18 +1221,15 @@ void ll_deauthorize_statahead(struct inode *dir, void *key)
 	sai = lli->lli_sai;
 	if (sai && sai->sai_task) {
 		/*
-		 * statahead thread may not quit yet because it needs to cache
-		 * entries, now it's time to tell it to quit.
+		 * statahead thread may not have quit yet because it needs to
+		 * cache entries, now it's time to tell it to quit.
 		 *
-		 * In case sai is released, wake_up() is called inside spinlock,
-		 * so we use smp_store_release() to serialize ops.
+		 * wake_up_process() provides the necessary barriers
+		 * to pair with set_current_state().
 		 */
 		struct task_struct *task = sai->sai_task;
 
-		/* ensure ll_statahead_thread sees the NULL before
-		 * calling schedule() again.
-		 */
-		smp_store_release(&sai->sai_task, NULL);
+		sai->sai_task = NULL;
 		wake_up_process(task);
 	}
 	spin_unlock(&lli->lli_sa_lock);
@@ -1510,6 +1508,11 @@ static int revalidate_statahead_dentry(struct inode *dir,
 	ldd = ll_d2d(*dentryp);
 	ldd->lld_sa_generation = lli->lli_sa_generation;
 	sa_put(sai, entry, lli);
+	spin_lock(&lli->lli_sa_lock);
+	if (sai->sai_task)
+		wake_up_process(sai->sai_task);
+	spin_unlock(&lli->lli_sa_lock);
+
 	return rc;
 }
 
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
