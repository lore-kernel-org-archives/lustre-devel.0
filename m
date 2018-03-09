From: Dilger, Andreas <andreas.dilger@intel.com>
Date: Fri, 9 Mar 2018 00:12:12 +0000
Subject: [lustre-devel] [PATCH 13/17] staging: lustre: remove
 'ptlrpc_thread usage' for sai_agl_thread
In-Reply-To: <151994708549.7628.13268008928655143336.stgit@noble>
References: <151994679573.7628.1024109499321778846.stgit@noble>
 <151994708549.7628.13268008928655143336.stgit@noble>
Message-ID: <A1BB636C-AB1F-4000-82F5-FFC700BCA3C3@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: NeilBrown <neilb@suse.com>
Cc: "Drokin, Oleg" <oleg.drokin@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, James Simmons <jsimmons@infradead.org>, Linux
 Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, "Yong, Fan" <fan.yong@intel.com>

On Mar 1, 2018, at 16:31, NeilBrown <neilb@suse.com> wrote:
> 
> Lustre has a 'struct ptlrpc_thread' which provides
> control functionality wrapped around kthreads.
> None of the functionality used in statahead.c requires
> ptlrcp_thread - it can all be done directly with kthreads.
> 
> So discard the ptlrpc_thread and just use a task_struct directly.
> 
> One particular change worth noting is that in the current
> code, the thread performs some start-up actions and then
> signals that it is ready to go.  In the new code, the thread
> is first created, then the startup actions are perform, then
> the thread is woken up.  This means there is no need to wait
> any more than kthread_create() already waits.
> 
> Signed-off-by: NeilBrown <neilb@suse.com>

Looks reasonable, but one minor comment inline below.  Not enough to
make me think the patch is bad, just a minor inefficiency...

Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>

I've also CC'd Fan Yong, who is the author of this code in case
he has any comments.

> diff --git a/drivers/staging/lustre/lustre/llite/statahead.c b/drivers/staging/lustre/lustre/llite/statahead.c
> index ba00881a5745..39241b952bf4 100644
> --- a/drivers/staging/lustre/lustre/llite/statahead.c
> +++ b/drivers/staging/lustre/lustre/llite/statahead.c
> @@ -861,35 +860,13 @@ static int ll_agl_thread(void *arg)
> 	struct inode	     *dir    = d_inode(parent);
> 	struct ll_inode_info     *plli   = ll_i2info(dir);
> 	struct ll_inode_info     *clli;
> -	struct ll_sb_info	*sbi    = ll_i2sbi(dir);
> -	struct ll_statahead_info *sai;
> -	struct ptlrpc_thread *thread;
> +	/* We already own this reference, so it is safe to take it without a lock. */
> +	struct ll_statahead_info *sai = plli->lli_sai;
> 
> -	sai = ll_sai_get(dir);

Here we used to grab a reference to "sai" from the directory, but you
get it in the calling thread now...

> @@ -937,16 +917,22 @@ static void ll_start_agl(struct dentry *parent, struct ll_statahead_info *sai)
> 	       sai, parent);
> 
> 	plli = ll_i2info(d_inode(parent));
> +	task = kthread_create(ll_agl_thread, parent, "ll_agl_%u",
> +			      plli->lli_opendir_pid);
> 	if (IS_ERR(task)) {
> 		CERROR("can't start ll_agl thread, rc: %ld\n", PTR_ERR(task));
> 		return;
> 	}
> 
> +	sai->sai_agl_task = task;
> +	atomic_inc(&ll_i2sbi(d_inode(parent))->ll_agl_total);
> +	spin_lock(&plli->lli_agl_lock);
> +	sai->sai_agl_valid = 1;
> +	spin_unlock(&plli->lli_agl_lock);
> +	/* Get an extra reference that the thread holds */
> +	ll_sai_get(d_inode(parent));

Here you get the extra reference, but we already have the pointer to
"sai", do going through "parent->d_inode->lli->lli_sai" to get "sai"
again seems convoluted.  One option is atomic_inc(&sai->sai_refcount),
but given that this is done only once per "ls" call I don't think it
is a huge deal, and not more work than was done before.

Cheers, Andreas

> +
> +	wake_up_process(task);
> }
> 
> /* statahead thread main function */
> @@ -958,7 +944,6 @@ static int ll_statahead_thread(void *arg)
> 	struct ll_sb_info	*sbi    = ll_i2sbi(dir);
> 	struct ll_statahead_info *sai;
> 	struct ptlrpc_thread *sa_thread;
> -	struct ptlrpc_thread *agl_thread;
> 	struct page	      *page = NULL;
> 	__u64		     pos    = 0;
> 	int		       first  = 0;
> @@ -967,7 +952,6 @@ static int ll_statahead_thread(void *arg)
> 
> 	sai = ll_sai_get(dir);
> 	sa_thread = &sai->sai_thread;
> -	agl_thread = &sai->sai_agl_thread;
> 	sa_thread->t_pid = current_pid();
> 	CDEBUG(D_READA, "statahead thread starting: sai %p, parent %pd\n",
> 	       sai, parent);
> @@ -1129,21 +1113,13 @@ static int ll_statahead_thread(void *arg)
> 		sa_handle_callback(sai);
> 	}
> out:
> -	if (sai->sai_agl_valid) {
> -		spin_lock(&lli->lli_agl_lock);
> -		thread_set_flags(agl_thread, SVC_STOPPING);
> -		spin_unlock(&lli->lli_agl_lock);
> -		wake_up(&agl_thread->t_ctl_waitq);
> +	if (sai->sai_agl_task) {
> +		kthread_stop(sai->sai_agl_task);
> 
> 		CDEBUG(D_READA, "stop agl thread: sai %p pid %u\n",
> -		       sai, (unsigned int)agl_thread->t_pid);
> -		wait_event_idle(agl_thread->t_ctl_waitq,
> -				thread_is_stopped(agl_thread));
> -	} else {
> -		/* Set agl_thread flags anyway. */
> -		thread_set_flags(agl_thread, SVC_STOPPED);
> +		       sai, (unsigned int)sai->sai_agl_task->pid);
> +		sai->sai_agl_task = NULL;
> 	}
> -
> 	/*
> 	 * wait for inflight statahead RPCs to finish, and then we can free sai
> 	 * safely because statahead RPC will access sai data
> 
> 

Cheers, Andreas
--
Andreas Dilger
Lustre Principal Architect
Intel Corporation
