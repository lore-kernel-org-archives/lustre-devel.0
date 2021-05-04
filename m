Return-Path: <SRS0=WSMT=J7=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.7 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 67765C433ED
	for <lustre-devel@archiver.kernel.org>; Tue,  4 May 2021 00:10:46 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 1008F61185
	for <lustre-devel@archiver.kernel.org>; Tue,  4 May 2021 00:10:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1008F61185
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id C4C9A21F883;
	Mon,  3 May 2021 17:10:34 -0700 (PDT)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id CDCF421F42F
 for <lustre-devel@lists.lustre.org>; Mon,  3 May 2021 17:10:23 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 2C446EE1;
 Mon,  3 May 2021 20:10:20 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 28E298AD38; Mon,  3 May 2021 20:10:20 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon,  3 May 2021 20:10:09 -0400
Message-Id: <1620087016-17857-8-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1620087016-17857-1-git-send-email-jsimmons@infradead.org>
References: <1620087016-17857-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 07/14] lnet: libcfs: simplify task management
 in tracefile.c
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

The waitqueue, mutex, and two completions are not needed.
We can use kthread_stop/kthread_should_stop to synchronize
shutdown, cmpxchg() to ensure only one task is started, and a simple
wake_up_process() to wake the process.

WC-bug-id: https://jira.whamcloud.com/browse/LU-14428
Lustre-commit: 6c5e6dd777a49ab0 ("LU-14428 libcfs: simplify task management in tracefile.c")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/41492
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Arshad Hussain <arshad.hussain@aeoncomputing.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/libcfs/tracefile.c | 82 ++++++++++++++-------------------------------
 1 file changed, 26 insertions(+), 56 deletions(-)

diff --git a/net/lnet/libcfs/tracefile.c b/net/lnet/libcfs/tracefile.c
index 731623b..b1a2f3e 100644
--- a/net/lnet/libcfs/tracefile.c
+++ b/net/lnet/libcfs/tracefile.c
@@ -61,9 +61,8 @@ enum cfs_trace_buf_type {
 
 char cfs_tracefile[TRACEFILE_NAME_SIZE];
 long long cfs_tracefile_size = CFS_TRACEFILE_SIZE;
-static struct tracefiled_ctl trace_tctl;
-static DEFINE_MUTEX(cfs_trace_thread_mutex);
-static int thread_running;
+
+struct task_struct *tctl_task;
 
 static atomic_t cfs_tage_allocated = ATOMIC_INIT(0);
 static DECLARE_RWSEM(cfs_tracefile_sem);
@@ -78,14 +77,6 @@ struct page_collection {
 	int			pc_want_daemon_pages;
 };
 
-struct tracefiled_ctl {
-	struct completion	tctl_start;
-	struct completion	tctl_stop;
-	wait_queue_head_t	tctl_waitq;
-	pid_t			tctl_pid;
-	atomic_t		tctl_shutdown;
-};
-
 /*
  * small data-structure for each page owned by tracefiled.
  */
@@ -244,6 +235,7 @@ static void cfs_tage_to_tail(struct cfs_trace_page *tage,
 cfs_trace_get_tage_try(struct cfs_trace_cpu_data *tcd, unsigned long len)
 {
 	struct cfs_trace_page *tage;
+	struct task_struct *tsk;
 
 	if (tcd->tcd_cur_pages > 0) {
 		__LASSERT(!list_empty(&tcd->tcd_pages));
@@ -274,12 +266,10 @@ static void cfs_tage_to_tail(struct cfs_trace_page *tage,
 		list_add_tail(&tage->linkage, &tcd->tcd_pages);
 		tcd->tcd_cur_pages++;
 
-		if (tcd->tcd_cur_pages > 8 && thread_running) {
-			struct tracefiled_ctl *tctl = &trace_tctl;
-			/*
-			 * wake up tracefiled to process some pages.
+		if (tcd->tcd_cur_pages > 8 && tsk) {
+			/* wake up tracefiled to process some pages.
 			 */
-			wake_up(&tctl->tctl_waitq);
+			wake_up_process(tsk);
 		}
 		return tage;
 	}
@@ -332,7 +322,7 @@ static struct cfs_trace_page *cfs_trace_get_tage(struct cfs_trace_cpu_data *tcd,
 	tage = cfs_trace_get_tage_try(tcd, len);
 	if (tage)
 		return tage;
-	if (thread_running)
+	if (tctl_task)
 		cfs_tcd_shrink(tcd);
 	if (tcd->tcd_cur_pages > 0) {
 		tage = cfs_tage_from_list(tcd->tcd_pages.next);
@@ -1075,7 +1065,6 @@ int cfs_trace_get_debug_mb(void)
 static int tracefiled(void *arg)
 {
 	struct page_collection pc;
-	struct tracefiled_ctl *tctl = arg;
 	struct cfs_trace_page *tage;
 	struct cfs_trace_page *tmp;
 	struct file *filp;
@@ -1083,21 +1072,13 @@ static int tracefiled(void *arg)
 	int last_loop = 0;
 	int rc;
 
-	/* we're started late enough that we pick up init's fs context */
-	/* this is so broken in uml?  what on earth is going on? */
-
-	complete(&tctl->tctl_start);
-
 	pc.pc_want_daemon_pages = 0;
 
 	while (!last_loop) {
-		wait_event_timeout(tctl->tctl_waitq,
-				   ({ collect_pages(&pc);
-				     !list_empty(&pc.pc_pages); }) ||
-				   atomic_read(&tctl->tctl_shutdown),
-				   HZ);
-		if (atomic_read(&tctl->tctl_shutdown))
+		schedule_timeout_interruptible(HZ);
+		if (kthread_should_stop())
 			last_loop = 1;
+		collect_pages(&pc);
 		if (list_empty(&pc.pc_pages))
 			continue;
 
@@ -1168,50 +1149,39 @@ static int tracefiled(void *arg)
 		}
 		__LASSERT(list_empty(&pc.pc_pages));
 	}
-	complete(&tctl->tctl_stop);
+
 	return 0;
 }
 
 int cfs_trace_start_thread(void)
 {
-	struct tracefiled_ctl *tctl = &trace_tctl;
-	struct task_struct *task;
+	struct task_struct *tsk;
 	int rc = 0;
 
-	mutex_lock(&cfs_trace_thread_mutex);
-	if (thread_running)
-		goto out;
-
-	init_completion(&tctl->tctl_start);
-	init_completion(&tctl->tctl_stop);
-	init_waitqueue_head(&tctl->tctl_waitq);
-	atomic_set(&tctl->tctl_shutdown, 0);
+	if (tctl_task)
+		return 0;
 
-	task = kthread_run(tracefiled, tctl, "ktracefiled");
-	if (IS_ERR(task)) {
-		rc = PTR_ERR(task);
-		goto out;
-	}
+	tsk = kthread_create(tracefiled, NULL, "ktracefiled");
+	if (IS_ERR(tsk))
+		rc = PTR_ERR(tsk);
+	else if (cmpxchg(&tctl_task, NULL, tsk))
+		/* already running */
+		kthread_stop(tsk);
+	else
+		wake_up_process(tsk);
 
-	wait_for_completion(&tctl->tctl_start);
-	thread_running = 1;
-out:
-	mutex_unlock(&cfs_trace_thread_mutex);
 	return rc;
 }
 
 void cfs_trace_stop_thread(void)
 {
-	struct tracefiled_ctl *tctl = &trace_tctl;
+	struct task_struct *tsk;
 
-	mutex_lock(&cfs_trace_thread_mutex);
-	if (thread_running) {
+	tsk = xchg(&tctl_task, NULL);
+	if (tsk) {
 		pr_info("shutting down debug daemon thread...\n");
-		atomic_set(&tctl->tctl_shutdown, 1);
-		wait_for_completion(&tctl->tctl_stop);
-		thread_running = 0;
+		kthread_stop(tsk);
 	}
-	mutex_unlock(&cfs_trace_thread_mutex);
 }
 
 /* percents to share the total debug memory for each type */
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
