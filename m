From: James Simmons <jsimmons@infradead.org>
Date: Thu, 2 Aug 2018 04:48:52 +0100 (BST)
Subject: [lustre-devel] [PATCH 7/7] lustre: change TASK_NOLOAD to
 TASK_IDLE.
In-Reply-To: <153292257303.26496.13996008210683917463.stgit@noble>
References: <153292249340.26496.13985174182824912332.stgit@noble>
 <153292257303.26496.13996008210683917463.stgit@noble>
Message-ID: <alpine.LFD.2.21.1808020448170.5677@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> TASK_NOLOAD is not a task state to be use by
> itself, it should only be used together with
> TASK_UNINTERRUPTIBLE, which easily done
> by using TASK_IDLE.
> 
> So convert to TASK_IDLE.

Sad only the latest kernel support this :-(

Reviewed-by: James Simmons <jsimmons@infradead.org>
 
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
>  drivers/staging/lustre/lnet/lnet/lib-eq.c |    4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lnet/lnet/lib-eq.c b/drivers/staging/lustre/lnet/lnet/lib-eq.c
> index 8347cc44e47d..f085388895ea 100644
> --- a/drivers/staging/lustre/lnet/lnet/lib-eq.c
> +++ b/drivers/staging/lustre/lnet/lnet/lib-eq.c
> @@ -349,7 +349,7 @@ __must_hold(&the_lnet.ln_eq_wait_lock)
>   * \param timeout Time in jiffies to wait for an event to occur on
>   * one of the EQs. The constant MAX_SCHEDULE_TIMEOUT can be used to indicate an
>   * infinite timeout.
> - * \param interruptible, if true, use TASK_INTERRUPTIBLE, else TASK_NOLOAD
> + * \param interruptible, if true, use TASK_INTERRUPTIBLE, else TASK_IDLE
>   * \param event,which On successful return (1 or -EOVERFLOW), \a event will
>   * hold the next event in the EQs, and \a which will contain the index of the
>   * EQ from which the event was taken.
> @@ -406,7 +406,7 @@ LNetEQPoll(struct lnet_handle_eq *eventqs, int neq, signed long timeout,
>  		 */
>  		wait = lnet_eq_wait_locked(&timeout,
>  					   interruptible ? TASK_INTERRUPTIBLE
> -					   : TASK_NOLOAD);
> +					   : TASK_IDLE);
>  		if (wait < 0) /* no new event */
>  			break;
>  	}
> 
> 
> 
