From: NeilBrown <neilb@suse.com>
Date: Fri, 02 Mar 2018 10:31:25 +1100
Subject: [lustre-devel] [PATCH 13/17] staging: lustre: remove 'ptlrpc_thread
 usage' for sai_agl_thread
In-Reply-To: <151994679573.7628.1024109499321778846.stgit@noble>
References: <151994679573.7628.1024109499321778846.stgit@noble>
Message-ID: <151994708549.7628.13268008928655143336.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, James Simmons <jsimmons@infradead.org>, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

Lustre has a 'struct ptlrpc_thread' which provides
control functionality wrapped around kthreads.
None of the functionality used in statahead.c requires
ptlrcp_thread - it can all be done directly with kthreads.

So discard the ptlrpc_thread and just use a task_struct directly.

One particular change worth noting is that in the current
code, the thread performs some start-up actions and then
signals that it is ready to go.  In the new code, the thread
is first created, then the startup actions are perform, then
the thread is woken up.  This means there is no need to wait
any more than kthread_create() already waits.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../staging/lustre/lustre/llite/llite_internal.h   |    2 -
 drivers/staging/lustre/lustre/llite/statahead.c    |   78 +++++++-------------
 2 files changed, 28 insertions(+), 52 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
index f68c2e88f12b..0c2d717fd526 100644
--- a/drivers/staging/lustre/lustre/llite/llite_internal.h
+++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
@@ -1071,7 +1071,7 @@ struct ll_statahead_info {
 				sai_in_readpage:1;/* statahead in readdir() */
 	wait_queue_head_t	sai_waitq;      /* stat-ahead wait queue */
 	struct ptlrpc_thread    sai_thread;     /* stat-ahead thread */
-	struct ptlrpc_thread    sai_agl_thread; /* AGL thread */
+	struct task_struct     *sai_agl_task;   /* AGL thread */
 	struct list_head	sai_interim_entries; /* entries which got async
 						      * stat reply, but not
 						      * instantiated
diff --git a/drivers/staging/lustre/lustre/llite/statahead.c b/drivers/staging/lustre/lustre/llite/statahead.c
index ba00881a5745..39241b952bf4 100644
--- a/drivers/staging/lustre/lustre/llite/statahead.c
+++ b/drivers/staging/lustre/lustre/llite/statahead.c
@@ -383,7 +383,7 @@ static void ll_agl_add(struct ll_statahead_info *sai,
 	}
 
 	if (added > 0)
-		wake_up(&sai->sai_agl_thread.t_ctl_waitq);
+		wake_up_process(sai->sai_agl_task);
 }
 
 /* allocate sai */
@@ -404,7 +404,6 @@ static struct ll_statahead_info *ll_sai_alloc(struct dentry *dentry)
 	sai->sai_index = 1;
 	init_waitqueue_head(&sai->sai_waitq);
 	init_waitqueue_head(&sai->sai_thread.t_ctl_waitq);
-	init_waitqueue_head(&sai->sai_agl_thread.t_ctl_waitq);
 
 	INIT_LIST_HEAD(&sai->sai_interim_entries);
 	INIT_LIST_HEAD(&sai->sai_entries);
@@ -467,7 +466,7 @@ static void ll_sai_put(struct ll_statahead_info *sai)
 		spin_unlock(&lli->lli_sa_lock);
 
 		LASSERT(thread_is_stopped(&sai->sai_thread));
-		LASSERT(thread_is_stopped(&sai->sai_agl_thread));
+		LASSERT(sai->sai_agl_task == NULL);
 		LASSERT(sai->sai_sent == sai->sai_replied);
 		LASSERT(!sa_has_callback(sai));
 
@@ -861,35 +860,13 @@ static int ll_agl_thread(void *arg)
 	struct inode	     *dir    = d_inode(parent);
 	struct ll_inode_info     *plli   = ll_i2info(dir);
 	struct ll_inode_info     *clli;
-	struct ll_sb_info	*sbi    = ll_i2sbi(dir);
-	struct ll_statahead_info *sai;
-	struct ptlrpc_thread *thread;
+	/* We already own this reference, so it is safe to take it without a lock. */
+	struct ll_statahead_info *sai = plli->lli_sai;
 
-	sai = ll_sai_get(dir);
-	thread = &sai->sai_agl_thread;
-	thread->t_pid = current_pid();
 	CDEBUG(D_READA, "agl thread started: sai %p, parent %pd\n",
 	       sai, parent);
 
-	atomic_inc(&sbi->ll_agl_total);
-	spin_lock(&plli->lli_agl_lock);
-	sai->sai_agl_valid = 1;
-	if (thread_is_init(thread))
-		/* If someone else has changed the thread state
-		 * (e.g. already changed to SVC_STOPPING), we can't just
-		 * blindly overwrite that setting.
-		 */
-		thread_set_flags(thread, SVC_RUNNING);
-	spin_unlock(&plli->lli_agl_lock);
-	wake_up(&thread->t_ctl_waitq);
-
-	while (1) {
-		wait_event_idle(thread->t_ctl_waitq,
-				!list_empty(&sai->sai_agls) ||
-				!thread_is_running(thread));
-
-		if (!thread_is_running(thread))
-			break;
+	while (!kthread_should_stop()) {
 
 		spin_lock(&plli->lli_agl_lock);
 		/* The statahead thread maybe help to process AGL entries,
@@ -904,6 +881,12 @@ static int ll_agl_thread(void *arg)
 		} else {
 			spin_unlock(&plli->lli_agl_lock);
 		}
+
+		set_current_state(TASK_IDLE);
+		if (list_empty(&sai->sai_agls) &&
+		    !kthread_should_stop())
+			schedule();
+		__set_current_state(TASK_RUNNING);
 	}
 
 	spin_lock(&plli->lli_agl_lock);
@@ -917,19 +900,16 @@ static int ll_agl_thread(void *arg)
 		iput(&clli->lli_vfs_inode);
 		spin_lock(&plli->lli_agl_lock);
 	}
-	thread_set_flags(thread, SVC_STOPPED);
 	spin_unlock(&plli->lli_agl_lock);
-	wake_up(&thread->t_ctl_waitq);
-	ll_sai_put(sai);
 	CDEBUG(D_READA, "agl thread stopped: sai %p, parent %pd\n",
 	       sai, parent);
+	ll_sai_put(sai);
 	return 0;
 }
 
 /* start agl thread */
 static void ll_start_agl(struct dentry *parent, struct ll_statahead_info *sai)
 {
-	struct ptlrpc_thread *thread = &sai->sai_agl_thread;
 	struct ll_inode_info  *plli;
 	struct task_struct *task;
 
@@ -937,16 +917,22 @@ static void ll_start_agl(struct dentry *parent, struct ll_statahead_info *sai)
 	       sai, parent);
 
 	plli = ll_i2info(d_inode(parent));
-	task = kthread_run(ll_agl_thread, parent, "ll_agl_%u",
-			   plli->lli_opendir_pid);
+	task = kthread_create(ll_agl_thread, parent, "ll_agl_%u",
+			      plli->lli_opendir_pid);
 	if (IS_ERR(task)) {
 		CERROR("can't start ll_agl thread, rc: %ld\n", PTR_ERR(task));
-		thread_set_flags(thread, SVC_STOPPED);
 		return;
 	}
 
-	wait_event_idle(thread->t_ctl_waitq,
-			thread_is_running(thread) || thread_is_stopped(thread));
+	sai->sai_agl_task = task;
+	atomic_inc(&ll_i2sbi(d_inode(parent))->ll_agl_total);
+	spin_lock(&plli->lli_agl_lock);
+	sai->sai_agl_valid = 1;
+	spin_unlock(&plli->lli_agl_lock);
+	/* Get an extra reference that the thread holds */
+	ll_sai_get(d_inode(parent));
+
+	wake_up_process(task);
 }
 
 /* statahead thread main function */
@@ -958,7 +944,6 @@ static int ll_statahead_thread(void *arg)
 	struct ll_sb_info	*sbi    = ll_i2sbi(dir);
 	struct ll_statahead_info *sai;
 	struct ptlrpc_thread *sa_thread;
-	struct ptlrpc_thread *agl_thread;
 	struct page	      *page = NULL;
 	__u64		     pos    = 0;
 	int		       first  = 0;
@@ -967,7 +952,6 @@ static int ll_statahead_thread(void *arg)
 
 	sai = ll_sai_get(dir);
 	sa_thread = &sai->sai_thread;
-	agl_thread = &sai->sai_agl_thread;
 	sa_thread->t_pid = current_pid();
 	CDEBUG(D_READA, "statahead thread starting: sai %p, parent %pd\n",
 	       sai, parent);
@@ -1129,21 +1113,13 @@ static int ll_statahead_thread(void *arg)
 		sa_handle_callback(sai);
 	}
 out:
-	if (sai->sai_agl_valid) {
-		spin_lock(&lli->lli_agl_lock);
-		thread_set_flags(agl_thread, SVC_STOPPING);
-		spin_unlock(&lli->lli_agl_lock);
-		wake_up(&agl_thread->t_ctl_waitq);
+	if (sai->sai_agl_task) {
+		kthread_stop(sai->sai_agl_task);
 
 		CDEBUG(D_READA, "stop agl thread: sai %p pid %u\n",
-		       sai, (unsigned int)agl_thread->t_pid);
-		wait_event_idle(agl_thread->t_ctl_waitq,
-				thread_is_stopped(agl_thread));
-	} else {
-		/* Set agl_thread flags anyway. */
-		thread_set_flags(agl_thread, SVC_STOPPED);
+		       sai, (unsigned int)sai->sai_agl_task->pid);
+		sai->sai_agl_task = NULL;
 	}
-
 	/*
 	 * wait for inflight statahead RPCs to finish, and then we can free sai
 	 * safely because statahead RPC will access sai data
