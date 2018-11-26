From: James Simmons <jsimmons@infradead.org>
Date: Mon, 26 Nov 2018 02:10:26 +0000 (GMT)
Subject: [lustre-devel] [PATCH 9/9] lustre: statahead: add smp_mb() to
 serialize ops
In-Reply-To: <154295732811.2850.6059970126126914084.stgit@noble>
References: <154295730810.2850.961218355189474016.stgit@noble>
 <154295732811.2850.6059970126126914084.stgit@noble>
Message-ID: <alpine.LFD.2.21.1811260210170.32255@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> From: Lai Siyao <lai.siyao@intel.com>
> 
> In ll_deauthorize_statahead(), it set thread stop flag, and then
> wake up thread, however wakeup is called inside spinlock in case
> ll_statahead_info is released, then we need to call smp_mb() to
> serialize setting and wakeup.

Reviewed-by: James Simmons <jsimmons@infradead.org>
 
> Signed-off-by: Lai Siyao <lai.siyao@intel.com>
> WC-bug-id: https://jira.whamcloud.com/browse/LU-7994
> Reviewed-on: https://review.whamcloud.com/23040
> Reviewed-by: Fan Yong <fan.yong@intel.com>
> Reviewed-by: Bobi Jam <bobijam@hotmail.com>
> Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
>  drivers/staging/lustre/lustre/llite/statahead.c |   15 ++++++++++++---
>  1 file changed, 12 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lustre/llite/statahead.c b/drivers/staging/lustre/lustre/llite/statahead.c
> index 3d71322aa1c7..24c2335c70a7 100644
> --- a/drivers/staging/lustre/lustre/llite/statahead.c
> +++ b/drivers/staging/lustre/lustre/llite/statahead.c
> @@ -1110,8 +1110,9 @@ static int ll_statahead_thread(void *arg)
>  		sa_handle_callback(sai);
>  
>  		set_current_state(TASK_IDLE);
> +		/* ensure we see the NULL stored by ll_deauthorize_statahead() */
>  		if (!sa_has_callback(sai) &&
> -		    sai->sai_task)
> +		    smp_load_acquire(&sai->sai_task))
>  			schedule();
>  		__set_current_state(TASK_RUNNING);
>  	}
> @@ -1191,9 +1192,17 @@ void ll_deauthorize_statahead(struct inode *dir, void *key)
>  		/*
>  		 * statahead thread may not quit yet because it needs to cache
>  		 * entries, now it's time to tell it to quit.
> +		 *
> +		 * In case sai is released, wake_up() is called inside spinlock,
> +		 * so we use smp_store_release() to serialize ops.
>  		 */
> -		wake_up_process(sai->sai_task);
> -		sai->sai_task = NULL;
> +		struct task_struct *task = sai->sai_task;
> +
> +		/* ensure ll_statahead_thread sees the NULL before
> +		 * calling schedule() again.
> +		 */
> +		smp_store_release(&sai->sai_task, NULL);
> +		wake_up_process(task);
>  	}
>  	spin_unlock(&lli->lli_sa_lock);
>  }
> 
> 
> 
