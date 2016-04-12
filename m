From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Mon, 11 Apr 2016 20:54:45 -0700
Subject: [lustre-devel] [PATCH 18/18] staging: lustre: osc: Lustre
 returns EINTR from writes when SA_RESTART is set
In-Reply-To: <1459820223-24754-19-git-send-email-jsimmons@infradead.org>
References: <1459820223-24754-1-git-send-email-jsimmons@infradead.org>
	<1459820223-24754-19-git-send-email-jsimmons@infradead.org>
Message-ID: <20160412035445.GA27982@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Simmons <jsimmons@infradead.org>
Cc: devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Patrick Farrell <paf@cray.com>, James Simmons <uja.ornl@gmail.com>

Some of this series didn't apply, due to merge issues with 4.6-rc3.  Can
you rebase and resend the remaining patches?

thanks,

greg k-h

On Mon, Apr 04, 2016 at 09:37:03PM -0400, James Simmons wrote:
> When Lustre is in a read or write system call and receives a
> SIGALRM, it will return EINTR if interrupted in osc_enter_cache.
> This prevents the system call from being restarted if
> SA_RESTART is set in the handler.
> 
> This patch changes behavior in this location to return ERESTARTSYS
> when a signal arrives during the call to l_wait_event.
> 
> Signed-off-by: Patrick Farrell <paf@cray.com>
> Signed-off-by: James Simmons <uja.ornl@gmail.com>
> ntel-bug-id: https://jira.hpdd.intel.com/browse/LU-3581
> Reviewed-on: http://review.whamcloud.com/7002
> Reviewed-by: Rahul Deshmukh <rahul_deshmukh@xyratex.com>
> Reviewed-by: Cory Spitz <spitzcor@cray.com>
> Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
> Signed-off-by: James Simmons <jsimmons@infradead.org>
> ---
>  drivers/staging/lustre/lustre/osc/osc_cache.c |   13 ++++++++++++-
>  1 files changed, 12 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lustre/osc/osc_cache.c b/drivers/staging/lustre/lustre/osc/osc_cache.c
> index f09b89d..956d57b 100644
> --- a/drivers/staging/lustre/lustre/osc/osc_cache.c
> +++ b/drivers/staging/lustre/lustre/osc/osc_cache.c
> @@ -1626,11 +1626,22 @@ static int osc_enter_cache(const struct lu_env *env, struct client_obd *cli,
>  
>  		/* l_wait_event is interrupted by signal, or timed out */
>  		if (rc < 0) {
> -			if (rc == -ETIMEDOUT) {
> +			switch (rc) {
> +			case -ETIMEDOUT:
>  				OSC_DUMP_GRANT(D_ERROR, cli,
>  					       "try to reserve %d.\n", bytes);
>  				osc_extent_tree_dump(D_ERROR, osc);
>  				rc = -EDQUOT;
> +				break;
> +			case -EINTR:
> +				/* Ensures restartability - LU-3581 */
> +				rc = -ERESTARTSYS;
> +				break;
> +			default:
> +				CDEBUG(D_CACHE, "%s: event for cache space @ %p never arrived due to %d\n",
> +				       cli->cl_import->imp_obd->obd_name,
> +				       &ocw, rc);
> +				break;
>  			}
>  			list_del_init(&ocw.ocw_entry);
>  			goto out;
> -- 
> 1.7.1
