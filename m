From: Andreas Dilger <adilger@whamcloud.com>
Date: Mon, 30 Jul 2018 21:43:51 +0000
Subject: [lustre-devel] [PATCH 7/7] lustre: change TASK_NOLOAD to
 TASK_IDLE.
In-Reply-To: <153292257303.26496.13996008210683917463.stgit@noble>
References: <153292249340.26496.13985174182824912332.stgit@noble>
 <153292257303.26496.13996008210683917463.stgit@noble>
Message-ID: <2657E3CC-BC53-45C9-A6F4-65FEFE55409A@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Jul 29, 2018, at 21:49, NeilBrown <neilb@suse.com> wrote:
> 
> TASK_NOLOAD is not a task state to be use by
> itself, it should only be used together with
> TASK_UNINTERRUPTIBLE, which easily done
> by using TASK_IDLE.
> 
> So convert to TASK_IDLE.
> 
> Signed-off-by: NeilBrown <neilb@suse.com>

Nice to see this infrastructure is available.  I'm no fan of l_wait_event()
complexity, but without TASK_IDLE (only added in 4.13) we had to find a way
for servers to have lots of service threads without a load average of 100
or whatever...

Reviewed-by: Andreas Dilger <adilger@dilger.ca>

> ---
> drivers/staging/lustre/lnet/lnet/lib-eq.c |    4 ++--
> 1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lnet/lnet/lib-eq.c b/drivers/staging/lustre/lnet/lnet/lib-eq.c
> index 8347cc44e47d..f085388895ea 100644
> --- a/drivers/staging/lustre/lnet/lnet/lib-eq.c
> +++ b/drivers/staging/lustre/lnet/lnet/lib-eq.c
> @@ -349,7 +349,7 @@ __must_hold(&the_lnet.ln_eq_wait_lock)
>  * \param timeout Time in jiffies to wait for an event to occur on
>  * one of the EQs. The constant MAX_SCHEDULE_TIMEOUT can be used to indicate an
>  * infinite timeout.
> - * \param interruptible, if true, use TASK_INTERRUPTIBLE, else TASK_NOLOAD
> + * \param interruptible, if true, use TASK_INTERRUPTIBLE, else TASK_IDLE
>  * \param event,which On successful return (1 or -EOVERFLOW), \a event will
>  * hold the next event in the EQs, and \a which will contain the index of the
>  * EQ from which the event was taken.
> @@ -406,7 +406,7 @@ LNetEQPoll(struct lnet_handle_eq *eventqs, int neq, signed long timeout,
> 		 */
> 		wait = lnet_eq_wait_locked(&timeout,
> 					   interruptible ? TASK_INTERRUPTIBLE
> -					   : TASK_NOLOAD);
> +					   : TASK_IDLE);
> 		if (wait < 0) /* no new event */
> 			break;
> 	}
> 
> 

Cheers, Andreas
---
Andreas Dilger
Principal Lustre Architect
Whamcloud







-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 235 bytes
Desc: Message signed with OpenPGP
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180730/b79ac136/attachment.sig>
