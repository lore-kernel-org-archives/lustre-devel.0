From: James Simmons <jsimmons@infradead.org>
Date: Wed, 17 Jan 2018 15:36:28 +0000 (GMT)
Subject: [lustre-devel] [PATCH 18/19] staging: lustre: replace
 l_wait_event_exclusive_head() with wait_event_idle_exclusive
In-Reply-To: <151538209398.23920.3167444012358212836.stgit@noble>
References: <151538168618.23920.8261096424342988792.stgit@noble>
 <151538209398.23920.3167444012358212836.stgit@noble>
Message-ID: <alpine.LFD.2.21.1801171536160.11282@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: NeilBrown <neilb@suse.com>
Cc: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, lkml <linux-kernel@vger.kernel.org>, lustre <lustre-devel@lists.lustre.org>


> This l_wait_event_exclusive_head() will wait indefinitely
> if the timeout is zero.  If it does wait with a timeout
> and times out, the timeout for next time is set to zero.
> 
> The can be mapped to a call to either
>  wait_event_idle_exclusive()
> or
>  wait_event_idle_exclusive_timeout()
> depending in the timeout setting.
> 
> The current code arrange for LIFO queuing of waiters,
> but include/event.h doesn't support that yet.
> Until it does, fall back on FIFO with
> wait_event_idle_exclusive{,_timeout}().

Reviewed-by: James Simmons <jsimmons@infradead.org>
 
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
>  drivers/staging/lustre/lustre/ptlrpc/service.c |   43 ++++++++++++++----------
>  1 file changed, 25 insertions(+), 18 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lustre/ptlrpc/service.c b/drivers/staging/lustre/lustre/ptlrpc/service.c
> index 6e3403417434..29fdb54f16ca 100644
> --- a/drivers/staging/lustre/lustre/ptlrpc/service.c
> +++ b/drivers/staging/lustre/lustre/ptlrpc/service.c
> @@ -1897,15 +1897,6 @@ ptlrpc_check_rqbd_pool(struct ptlrpc_service_part *svcpt)
>  	}
>  }
>  
> -static int
> -ptlrpc_retry_rqbds(void *arg)
> -{
> -	struct ptlrpc_service_part *svcpt = arg;
> -
> -	svcpt->scp_rqbd_timeout = 0;
> -	return -ETIMEDOUT;
> -}
> -
>  static inline int
>  ptlrpc_threads_enough(struct ptlrpc_service_part *svcpt)
>  {
> @@ -1968,13 +1959,17 @@ ptlrpc_server_request_incoming(struct ptlrpc_service_part *svcpt)
>  	return !list_empty(&svcpt->scp_req_incoming);
>  }
>  
> +/* We perfer lifo queuing, but kernel doesn't provide that yet. */
> +#ifndef wait_event_idle_exclusive_lifo
> +#define wait_event_idle_exclusive_lifo wait_event_idle_exclusive
> +#define wait_event_idle_exclusive_lifo_timeout wait_event_idle_exclusive_timeout
> +#endif
> +
>  static __attribute__((__noinline__)) int
>  ptlrpc_wait_event(struct ptlrpc_service_part *svcpt,
>  		  struct ptlrpc_thread *thread)
>  {
>  	/* Don't exit while there are replies to be handled */
> -	struct l_wait_info lwi = LWI_TIMEOUT(svcpt->scp_rqbd_timeout,
> -					     ptlrpc_retry_rqbds, svcpt);
>  
>  	/* XXX: Add this back when libcfs watchdog is merged upstream
>  	lc_watchdog_disable(thread->t_watchdog);
> @@ -1982,13 +1977,25 @@ ptlrpc_wait_event(struct ptlrpc_service_part *svcpt,
>  
>  	cond_resched();
>  
> -	l_wait_event_exclusive_head(svcpt->scp_waitq,
> -				    ptlrpc_thread_stopping(thread) ||
> -				    ptlrpc_server_request_incoming(svcpt) ||
> -				    ptlrpc_server_request_pending(svcpt,
> -								  false) ||
> -				    ptlrpc_rqbd_pending(svcpt) ||
> -				    ptlrpc_at_check(svcpt), &lwi);
> +	if (svcpt->scp_rqbd_timeout == 0)
> +		wait_event_idle_exclusive_lifo(
> +			svcpt->scp_waitq,
> +			ptlrpc_thread_stopping(thread) ||
> +			ptlrpc_server_request_incoming(svcpt) ||
> +			ptlrpc_server_request_pending(svcpt,
> +						      false) ||
> +			ptlrpc_rqbd_pending(svcpt) ||
> +			ptlrpc_at_check(svcpt));
> +	else if (0 == wait_event_idle_exclusive_lifo_timeout(
> +			 svcpt->scp_waitq,
> +			 ptlrpc_thread_stopping(thread) ||
> +			 ptlrpc_server_request_incoming(svcpt) ||
> +			 ptlrpc_server_request_pending(svcpt,
> +						       false) ||
> +			 ptlrpc_rqbd_pending(svcpt) ||
> +			 ptlrpc_at_check(svcpt),
> +			 svcpt->scp_rqbd_timeout))
> +		svcpt->scp_rqbd_timeout = 0;
>  
>  	if (ptlrpc_thread_stopping(thread))
>  		return -EINTR;
> 
> 
> 
