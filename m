From: NeilBrown <neilb@suse.com>
Date: Fri, 02 Mar 2018 10:31:25 +1100
Subject: [lustre-devel] [PATCH 14/17] staging: lustre: change sai_thread to
 sai_task.
In-Reply-To: <151994679573.7628.1024109499321778846.stgit@noble>
References: <151994679573.7628.1024109499321778846.stgit@noble>
Message-ID: <151994708553.7628.2646121829758742627.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, James Simmons <jsimmons@infradead.org>, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

Rather than allocating a ptlrpc_thread for the
stat-ahead thread, just use the task_struct provided
by kthreads directly.

As nothing ever waits for the sai_task, it must call do_exit()
directly rather than simply return from the function.
Also it cannot use kthread_should_stop() to know when to stop.

There is one caller which can ask it to stop so we need a simple
signaling mechanism.  I've chosen to set ->sai_task to NULL
when the thread should finish up.  The thread notices this and
cleans up and exits.
lli_sa_lock is used to avoid races between waking up the process
and the process exiting.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../staging/lustre/lustre/llite/llite_internal.h   |    2 
 drivers/staging/lustre/lustre/llite/statahead.c    |  118 +++++++++-----------
 2 files changed, 54 insertions(+), 66 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
index 0c2d717fd526..d46bcf71b273 100644
--- a/drivers/staging/lustre/lustre/llite/llite_internal.h
+++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
@@ -1070,7 +1070,7 @@ struct ll_statahead_info {
 				sai_agl_valid:1,/* AGL is valid for the dir */
 				sai_in_readpage:1;/* statahead in readdir() */
 	wait_queue_head_t	sai_waitq;      /* stat-ahead wait queue */
-	struct ptlrpc_thread    sai_thread;     /* stat-ahead thread */
+	struct task_struct     *sai_task;       /* stat-ahead thread */
 	struct task_struct     *sai_agl_task;   /* AGL thread */
 	struct list_head	sai_interim_entries; /* entries which got async
 						      * stat reply, but not
diff --git a/drivers/staging/lustre/lustre/llite/statahead.c b/drivers/staging/lustre/lustre/llite/statahead.c
index 39241b952bf4..155ce3cf6f60 100644
--- a/drivers/staging/lustre/lustre/llite/statahead.c
+++ b/drivers/staging/lustre/lustre/llite/statahead.c
@@ -267,7 +267,7 @@ sa_kill(struct ll_statahead_info *sai, struct sa_entry *entry)
 
 /* called by scanner after use, sa_entry will be killed */
 static void
-sa_put(struct ll_statahead_info *sai, struct sa_entry *entry)
+sa_put(struct ll_statahead_info *sai, struct sa_entry *entry, struct ll_inode_info *lli)
 {
 	struct sa_entry *tmp, *next;
 
@@ -295,7 +295,11 @@ sa_put(struct ll_statahead_info *sai, struct sa_entry *entry)
 		sa_kill(sai, tmp);
 	}
 
-	wake_up(&sai->sai_thread.t_ctl_waitq);
+	spin_lock(&lli->lli_sa_lock);
+	if (sai->sai_task)
+		wake_up_process(sai->sai_task);
+	spin_unlock(&lli->lli_sa_lock);
+
 }
 
 /*
@@ -403,7 +407,6 @@ static struct ll_statahead_info *ll_sai_alloc(struct dentry *dentry)
 	sai->sai_max = LL_SA_RPC_MIN;
 	sai->sai_index = 1;
 	init_waitqueue_head(&sai->sai_waitq);
-	init_waitqueue_head(&sai->sai_thread.t_ctl_waitq);
 
 	INIT_LIST_HEAD(&sai->sai_interim_entries);
 	INIT_LIST_HEAD(&sai->sai_entries);
@@ -465,7 +468,7 @@ static void ll_sai_put(struct ll_statahead_info *sai)
 		lli->lli_sai = NULL;
 		spin_unlock(&lli->lli_sa_lock);
 
-		LASSERT(thread_is_stopped(&sai->sai_thread));
+		LASSERT(sai->sai_task == NULL);
 		LASSERT(sai->sai_agl_task == NULL);
 		LASSERT(sai->sai_sent == sai->sai_replied);
 		LASSERT(!sa_has_callback(sai));
@@ -646,7 +649,6 @@ static int ll_statahead_interpret(struct ptlrpc_request *req,
 	struct ll_inode_info     *lli = ll_i2info(dir);
 	struct ll_statahead_info *sai = lli->lli_sai;
 	struct sa_entry *entry = (struct sa_entry *)minfo->mi_cbdata;
-	wait_queue_head_t *waitq = NULL;
 	__u64 handle = 0;
 
 	if (it_disposition(it, DISP_LOOKUP_NEG))
@@ -657,7 +659,6 @@ static int ll_statahead_interpret(struct ptlrpc_request *req,
 	 * sai should be always valid, no need to refcount
 	 */
 	LASSERT(sai);
-	LASSERT(!thread_is_stopped(&sai->sai_thread));
 	LASSERT(entry);
 
 	CDEBUG(D_READA, "sa_entry %.*s rc %d\n",
@@ -681,8 +682,9 @@ static int ll_statahead_interpret(struct ptlrpc_request *req,
 	spin_lock(&lli->lli_sa_lock);
 	if (rc) {
 		if (__sa_make_ready(sai, entry, rc))
-			waitq = &sai->sai_waitq;
+			wake_up(&sai->sai_waitq);
 	} else {
+		int first = 0;
 		entry->se_minfo = minfo;
 		entry->se_req = ptlrpc_request_addref(req);
 		/*
@@ -693,14 +695,15 @@ static int ll_statahead_interpret(struct ptlrpc_request *req,
 		 */
 		entry->se_handle = handle;
 		if (!sa_has_callback(sai))
-			waitq = &sai->sai_thread.t_ctl_waitq;
+			first = 1;
 
 		list_add_tail(&entry->se_list, &sai->sai_interim_entries);
+
+		if (first && sai->sai_task)
+			wake_up_process(sai->sai_task);
 	}
 	sai->sai_replied++;
 
-	if (waitq)
-		wake_up(waitq);
 	spin_unlock(&lli->lli_sa_lock);
 
 	return rc;
@@ -942,17 +945,13 @@ static int ll_statahead_thread(void *arg)
 	struct inode	     *dir    = d_inode(parent);
 	struct ll_inode_info     *lli   = ll_i2info(dir);
 	struct ll_sb_info	*sbi    = ll_i2sbi(dir);
-	struct ll_statahead_info *sai;
-	struct ptlrpc_thread *sa_thread;
+	struct ll_statahead_info *sai = lli->lli_sai;
 	struct page	      *page = NULL;
 	__u64		     pos    = 0;
 	int		       first  = 0;
 	int		       rc     = 0;
 	struct md_op_data *op_data;
 
-	sai = ll_sai_get(dir);
-	sa_thread = &sai->sai_thread;
-	sa_thread->t_pid = current_pid();
 	CDEBUG(D_READA, "statahead thread starting: sai %p, parent %pd\n",
 	       sai, parent);
 
@@ -965,21 +964,7 @@ static int ll_statahead_thread(void *arg)
 
 	op_data->op_max_pages = ll_i2sbi(dir)->ll_md_brw_pages;
 
-	if (sbi->ll_flags & LL_SBI_AGL_ENABLED)
-		ll_start_agl(parent, sai);
-
-	atomic_inc(&sbi->ll_sa_total);
-	spin_lock(&lli->lli_sa_lock);
-	if (thread_is_init(sa_thread))
-		/* If someone else has changed the thread state
-		 * (e.g. already changed to SVC_STOPPING), we can't just
-		 * blindly overwrite that setting.
-		 */
-		thread_set_flags(sa_thread, SVC_RUNNING);
-	spin_unlock(&lli->lli_sa_lock);
-	wake_up(&sa_thread->t_ctl_waitq);
-
-	while (pos != MDS_DIR_END_OFF && thread_is_running(sa_thread)) {
+	while (pos != MDS_DIR_END_OFF && sai->sai_task) {
 		struct lu_dirpage *dp;
 		struct lu_dirent  *ent;
 
@@ -996,7 +981,7 @@ static int ll_statahead_thread(void *arg)
 
 		dp = page_address(page);
 		for (ent = lu_dirent_start(dp);
-		     ent && thread_is_running(sa_thread) && !sa_low_hit(sai);
+		     ent && sai->sai_task && !sa_low_hit(sai);
 		     ent = lu_dirent_next(ent)) {
 			struct lu_fid fid;
 			__u64 hash;
@@ -1046,13 +1031,7 @@ static int ll_statahead_thread(void *arg)
 
 			fid_le_to_cpu(&fid, &ent->lde_fid);
 
-			/* wait for spare statahead window */
 			do {
-				wait_event_idle(sa_thread->t_ctl_waitq,
-						!sa_sent_full(sai) ||
-						sa_has_callback(sai) ||
-						!list_empty(&sai->sai_agls) ||
-						!thread_is_running(sa_thread));
 				sa_handle_callback(sai);
 
 				spin_lock(&lli->lli_agl_lock);
@@ -1072,8 +1051,16 @@ static int ll_statahead_thread(void *arg)
 					spin_lock(&lli->lli_agl_lock);
 				}
 				spin_unlock(&lli->lli_agl_lock);
-			} while (sa_sent_full(sai) &&
-				 thread_is_running(sa_thread));
+
+				set_current_state(TASK_IDLE);
+				if (sa_sent_full(sai) &&
+				    !sa_has_callback(sai) &&
+				    agl_list_empty(sai) &&
+				    sai->sai_task)
+					/* wait for spare statahead window */
+					schedule();
+				__set_current_state(TASK_RUNNING);
+			} while (sa_sent_full(sai) && sai->sai_task);
 
 			sa_statahead(parent, name, namelen, &fid);
 		}
@@ -1096,7 +1083,7 @@ static int ll_statahead_thread(void *arg)
 
 	if (rc < 0) {
 		spin_lock(&lli->lli_sa_lock);
-		thread_set_flags(sa_thread, SVC_STOPPING);
+		sai->sai_task = NULL;
 		lli->lli_sa_enabled = 0;
 		spin_unlock(&lli->lli_sa_lock);
 	}
@@ -1105,12 +1092,14 @@ static int ll_statahead_thread(void *arg)
 	 * statahead is finished, but statahead entries need to be cached, wait
 	 * for file release to stop me.
 	 */
-	while (thread_is_running(sa_thread)) {
-		wait_event_idle(sa_thread->t_ctl_waitq,
-				sa_has_callback(sai) ||
-				!thread_is_running(sa_thread));
-
+	while (sai->sai_task) {
 		sa_handle_callback(sai);
+
+		set_current_state(TASK_IDLE);
+		if (!sa_has_callback(sai) &&
+		    sai->sai_task)
+			schedule();
+		__set_current_state(TASK_RUNNING);
 	}
 out:
 	if (sai->sai_agl_task) {
@@ -1126,26 +1115,23 @@ static int ll_statahead_thread(void *arg)
 	 */
 	while (sai->sai_sent != sai->sai_replied) {
 		/* in case we're not woken up, timeout wait */
-		wait_event_idle_timeout(sa_thread->t_ctl_waitq,
-					sai->sai_sent == sai->sai_replied,
-					HZ>>3);
+		schedule_timeout_idle(HZ>>3);
 	}
 
 	/* release resources held by statahead RPCs */
 	sa_handle_callback(sai);
 
-	spin_lock(&lli->lli_sa_lock);
-	thread_set_flags(sa_thread, SVC_STOPPED);
-	spin_unlock(&lli->lli_sa_lock);
-
 	CDEBUG(D_READA, "statahead thread stopped: sai %p, parent %pd\n",
 	       sai, parent);
 
+	spin_lock(&lli->lli_sa_lock);
+	sai->sai_task = NULL;
+	spin_unlock(&lli->lli_sa_lock);
+
 	wake_up(&sai->sai_waitq);
-	wake_up(&sa_thread->t_ctl_waitq);
 	ll_sai_put(sai);
 
-	return rc;
+	do_exit(rc);
 }
 
 /* authorize opened dir handle @key to statahead */
@@ -1187,13 +1173,13 @@ void ll_deauthorize_statahead(struct inode *dir, void *key)
 	lli->lli_opendir_pid = 0;
 	lli->lli_sa_enabled = 0;
 	sai = lli->lli_sai;
-	if (sai && thread_is_running(&sai->sai_thread)) {
+	if (sai && sai->sai_task) {
 		/*
 		 * statahead thread may not quit yet because it needs to cache
 		 * entries, now it's time to tell it to quit.
 		 */
-		thread_set_flags(&sai->sai_thread, SVC_STOPPING);
-		wake_up(&sai->sai_thread.t_ctl_waitq);
+		wake_up_process(sai->sai_task);
+		sai->sai_task = NULL;
 	}
 	spin_unlock(&lli->lli_sa_lock);
 }
@@ -1463,7 +1449,7 @@ static int revalidate_statahead_dentry(struct inode *dir,
 	 */
 	ldd = ll_d2d(*dentryp);
 	ldd->lld_sa_generation = lli->lli_sa_generation;
-	sa_put(sai, entry);
+	sa_put(sai, entry, lli);
 	return rc;
 }
 
@@ -1483,7 +1469,6 @@ static int start_statahead_thread(struct inode *dir, struct dentry *dentry)
 {
 	struct ll_inode_info *lli = ll_i2info(dir);
 	struct ll_statahead_info *sai = NULL;
-	struct ptlrpc_thread *thread;
 	struct task_struct *task;
 	struct dentry *parent = dentry->d_parent;
 	int rc;
@@ -1523,18 +1508,21 @@ static int start_statahead_thread(struct inode *dir, struct dentry *dentry)
 	CDEBUG(D_READA, "start statahead thread: [pid %d] [parent %pd]\n",
 	       current_pid(), parent);
 
-	task = kthread_run(ll_statahead_thread, parent, "ll_sa_%u",
-			   lli->lli_opendir_pid);
-	thread = &sai->sai_thread;
+	task = kthread_create(ll_statahead_thread, parent, "ll_sa_%u",
+			      lli->lli_opendir_pid);
 	if (IS_ERR(task)) {
 		rc = PTR_ERR(task);
 		CERROR("can't start ll_sa thread, rc : %d\n", rc);
 		goto out;
 	}
 
-	wait_event_idle(thread->t_ctl_waitq,
-			thread_is_running(thread) || thread_is_stopped(thread));
-	ll_sai_put(sai);
+	if (ll_i2sbi(parent->d_inode)->ll_flags & LL_SBI_AGL_ENABLED)
+		ll_start_agl(parent, sai);
+
+	atomic_inc(&ll_i2sbi(parent->d_inode)->ll_sa_total);
+	sai->sai_task = task;
+
+	wake_up_process(task);
 
 	/*
 	 * We don't stat-ahead for the first dirent since we are already in
