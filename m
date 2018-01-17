From: James Simmons <jsimmons@infradead.org>
Date: Wed, 17 Jan 2018 15:35:14 +0000 (GMT)
Subject: [lustre-devel] [PATCH 15/19] staging: lustre: use explicit poll
 loop in ptlrpc_service_unlink_rqbd
In-Reply-To: <151538209387.23920.11031149890821644565.stgit@noble>
References: <151538168618.23920.8261096424342988792.stgit@noble>
 <151538209387.23920.11031149890821644565.stgit@noble>
Message-ID: <alpine.LFD.2.21.1801171535030.11282@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: NeilBrown <neilb@suse.com>
Cc: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, lkml <linux-kernel@vger.kernel.org>, lustre <lustre-devel@lists.lustre.org>


> Rather an using l_wait_event(), use wait_event_idle_timeout()
> with an explicit loop so it is easier to see what is happening.

Reviewed-by: James Simmons <jsimmons@infradead.org>
 
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
>  drivers/staging/lustre/lustre/ptlrpc/service.c |   15 ++++++++-------
>  1 file changed, 8 insertions(+), 7 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lustre/ptlrpc/service.c b/drivers/staging/lustre/lustre/ptlrpc/service.c
> index 5c41297d23d2..6e3403417434 100644
> --- a/drivers/staging/lustre/lustre/ptlrpc/service.c
> +++ b/drivers/staging/lustre/lustre/ptlrpc/service.c
> @@ -2618,7 +2618,7 @@ ptlrpc_service_unlink_rqbd(struct ptlrpc_service *svc)
>  {
>  	struct ptlrpc_service_part *svcpt;
>  	struct ptlrpc_request_buffer_desc *rqbd;
> -	struct l_wait_info lwi;
> +	int cnt;
>  	int rc;
>  	int i;
>  
> @@ -2658,12 +2658,13 @@ ptlrpc_service_unlink_rqbd(struct ptlrpc_service *svc)
>  			 * the HUGE timeout lets us CWARN for visibility
>  			 * of sluggish LNDs
>  			 */
> -			lwi = LWI_TIMEOUT_INTERVAL(
> -					LONG_UNLINK * HZ,
> -					HZ, NULL, NULL);
> -			rc = l_wait_event(svcpt->scp_waitq,
> -					  svcpt->scp_nrqbds_posted == 0, &lwi);
> -			if (rc == -ETIMEDOUT) {
> +			cnt = 0;
> +			while (cnt < LONG_UNLINK &&
> +			       (rc = wait_event_idle_timeout(svcpt->scp_waitq,
> +							     svcpt->scp_nrqbds_posted == 0,
> +							     HZ)) == 0)
> +				cnt ++;
> +			if (rc == 0) {
>  				CWARN("Service %s waiting for request buffers\n",
>  				      svcpt->scp_service->srv_name);
>  			}
> 
> 
> 
