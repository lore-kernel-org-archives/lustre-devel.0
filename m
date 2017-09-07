From: Greg KH <gregkh@linuxfoundation.org>
Date: Thu, 7 Sep 2017 14:33:49 +0200
Subject: [lustre-devel] [PATCH] staging: lustre: avoid going through
	unlock/lock overhead
In-Reply-To: <1504781862-15577-1-git-send-email-cakturk@gmail.com>
References: <1504781862-15577-1-git-send-email-cakturk@gmail.com>
Message-ID: <20170907123349.GB20922@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Cihangir Akturk <cakturk@gmail.com>
Cc: lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, oleg.drokin@intel.com, andreas.dilger@intel.com

On Thu, Sep 07, 2017 at 01:57:42PM +0300, Cihangir Akturk wrote:
> Unlocking a spin lock and then immediately locking without doing
> anything useful in between buys us nothing, except wasting CPU cycles.

Not always, it can be a "gate" for other users of the lock.

Are you sure that is not what is going on here?  Did you test this out
on a lustre system?  The locks here are anything but trivial...

> 
> Also code size gets smaller.
> 
> Before:
> 
>  text  data   bss    dec    hex filename
> 70415  2356  4108  76879  12c4f drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.o
> 
> After:
> 
>  text  data   bss    dec    hex filename
> 70095  2356  4108  76559  12b0f drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.o
> 
> Signed-off-by: Cihangir Akturk <cakturk@gmail.com>
> ---
>  drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c | 18 ++++++++----------
>  1 file changed, 8 insertions(+), 10 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
> index 64763aa..5d9cd33 100644
> --- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
> +++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
> @@ -1624,8 +1624,9 @@ int kiblnd_fmr_pool_map(struct kib_fmr_poolset *fps, struct kib_tx *tx,
>  	__u64 version;
>  	int rc;
>  
> - again:
> +again:
>  	spin_lock(&fps->fps_lock);
> +again_locked:
>  	version = fps->fps_version;
>  	list_for_each_entry(fpo, &fps->fps_pool_list, fpo_list) {
>  		fpo->fpo_deadline = cfs_time_shift(IBLND_POOL_DEADLINE);
> @@ -1722,10 +1723,8 @@ int kiblnd_fmr_pool_map(struct kib_fmr_poolset *fps, struct kib_tx *tx,
>  		}
>  
>  		/* EAGAIN and ... */
> -		if (version != fps->fps_version) {
> -			spin_unlock(&fps->fps_lock);
> -			goto again;
> -		}
> +		if (version != fps->fps_version)
> +			goto again_locked;
>  	}
>  
>  	if (fps->fps_increasing) {
> @@ -1754,9 +1753,8 @@ int kiblnd_fmr_pool_map(struct kib_fmr_poolset *fps, struct kib_tx *tx,
>  	} else {
>  		fps->fps_next_retry = cfs_time_shift(IBLND_POOL_RETRY);
>  	}
> -	spin_unlock(&fps->fps_lock);
>  
> -	goto again;
> +	goto again_locked;

Really, gotos backwards?  Ick, that's horrid as well, so maybe this is
better?  I hate this whole codebase...

I'll let the Lustre maintainers decide about this one...

greg k-h
