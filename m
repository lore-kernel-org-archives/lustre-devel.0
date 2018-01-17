From: James Simmons <jsimmons@infradead.org>
Date: Wed, 17 Jan 2018 15:33:07 +0000 (GMT)
Subject: [lustre-devel] [PATCH 11/19] staging: lustre: remove
 back_to_sleep()
In-Reply-To: <151538209372.23920.9644158038491397506.stgit@noble>
References: <151538168618.23920.8261096424342988792.stgit@noble>
 <151538209372.23920.9644158038491397506.stgit@noble>
Message-ID: <alpine.LFD.2.21.1801171532510.11282@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: NeilBrown <neilb@suse.com>
Cc: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, lkml <linux-kernel@vger.kernel.org>, lustre <lustre-devel@lists.lustre.org>


> When 'back_to_sleep()' is passed as the 'timeout' function,
> the effect is to wait indefinitely for the event, polling
> once after the timeout.
> If LWI_ON_SIGNAL_NOOP is given, then after the timeout
> we allow fatal signals to interrupt the wait.
> 
> Make this more obvious in both places "back_to_sleep()" is
> used but using two explicit sleeps.
> 
> The code in ptlrpcd_add_req() looks odd - why not just have one
> wait_event_idle()?  However I believe this is a faithful
> transformation of the existing code.

Reviewed-by: James Simmons <jsimmons@infradead.org>
 
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
>  drivers/staging/lustre/lustre/include/lustre_lib.h |    4 ----
>  drivers/staging/lustre/lustre/ptlrpc/import.c      |   11 ++++++-----
>  drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c     |    9 +++++----
>  3 files changed, 11 insertions(+), 13 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lustre/include/lustre_lib.h b/drivers/staging/lustre/lustre/include/lustre_lib.h
> index b2a64d0e682c..1939e959b92a 100644
> --- a/drivers/staging/lustre/lustre/include/lustre_lib.h
> +++ b/drivers/staging/lustre/lustre/include/lustre_lib.h
> @@ -140,10 +140,6 @@ void target_send_reply(struct ptlrpc_request *req, int rc, int fail_id);
>   * XXX nikita: some ptlrpc daemon threads have races of that sort.
>   *
>   */
> -static inline int back_to_sleep(void *arg)
> -{
> -	return 0;
> -}
>  
>  #define LWI_ON_SIGNAL_NOOP ((void (*)(void *))(-1))
>  
> diff --git a/drivers/staging/lustre/lustre/ptlrpc/import.c b/drivers/staging/lustre/lustre/ptlrpc/import.c
> index 5d62c9de27eb..faf0f606f013 100644
> --- a/drivers/staging/lustre/lustre/ptlrpc/import.c
> +++ b/drivers/staging/lustre/lustre/ptlrpc/import.c
> @@ -1496,7 +1496,6 @@ int ptlrpc_disconnect_import(struct obd_import *imp, int noclose)
>  	}
>  
>  	if (ptlrpc_import_in_recovery(imp)) {
> -		struct l_wait_info lwi;
>  		long timeout;
>  
>  		if (AT_OFF) {
> @@ -1510,10 +1509,12 @@ int ptlrpc_disconnect_import(struct obd_import *imp, int noclose)
>  			timeout = at_get(&imp->imp_at.iat_service_estimate[idx]) * HZ;
>  		}
>  
> -		lwi = LWI_TIMEOUT_INTR(cfs_timeout_cap(timeout),
> -				       back_to_sleep, LWI_ON_SIGNAL_NOOP, NULL);
> -		rc = l_wait_event(imp->imp_recovery_waitq,
> -				  !ptlrpc_import_in_recovery(imp), &lwi);
> +		if (wait_event_idle_timeout(imp->imp_recovery_waitq,
> +					    !ptlrpc_import_in_recovery(imp),
> +					    cfs_timeout_cap(timeout)) == 0)
> +			l_wait_event_abortable(
> +				imp->imp_recovery_waitq,
> +				!ptlrpc_import_in_recovery(imp));
>  	}
>  
>  	spin_lock(&imp->imp_lock);
> diff --git a/drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c b/drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c
> index dad2f9290f70..437b4b2a9072 100644
> --- a/drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c
> +++ b/drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c
> @@ -230,12 +230,13 @@ void ptlrpcd_add_req(struct ptlrpc_request *req)
>  
>  	spin_lock(&req->rq_lock);
>  	if (req->rq_invalid_rqset) {
> -		struct l_wait_info lwi = LWI_TIMEOUT(5 * HZ,
> -						     back_to_sleep, NULL);
> -
>  		req->rq_invalid_rqset = 0;
>  		spin_unlock(&req->rq_lock);
> -		l_wait_event(req->rq_set_waitq, !req->rq_set, &lwi);
> +		if (wait_event_idle_timeout(req->rq_set_waitq,
> +					    !req->rq_set,
> +					    5 * HZ) == 0)
> +			wait_event_idle(req->rq_set_waitq,
> +					!req->rq_set);
>  	} else if (req->rq_set) {
>  		/* If we have a valid "rq_set", just reuse it to avoid double
>  		 * linked.
> 
> 
> 
