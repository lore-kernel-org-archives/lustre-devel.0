From: James Simmons <jsimmons@infradead.org>
Date: Thu, 10 Nov 2016 18:59:03 +0000 (GMT)
Subject: [lustre-devel] [PATCH v2] staging: lustre: ldlm: pl_recalc time
 handling is wrong
In-Reply-To: <4839295.T6k2aHkh3K@wuerfel>
References: <1478573240-12850-1-git-send-email-jsimmons@infradead.org>
	<1594836.LAbS3nYoXQ@wuerfel> <20161110122108.GA7580@kroah.com>
	<4839295.T6k2aHkh3K@wuerfel>
Message-ID: <alpine.LFD.2.20.1611101858360.31600@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arnd Bergmann <arnd@arndb.de>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Dilger, Andreas" <andreas.dilger@intel.com>, "devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>, "Drokin, Oleg" <oleg.drokin@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>


> James Simmons reports:
> > The ldlm_pool field pl_recalc_time is set to the current
> > monotonic clock value but the interval period is calculated
> > with the wall clock. This means the interval period will
> > always be far larger than the pl_recalc_period, which is
> > just a small interval time period. The correct thing to
> > do is to use monotomic clock current value instead of the
> > wall clocks value when calculating recalc_interval_sec.
> 
> This broke when I converted the 32-bit get_seconds() into
> ktime_get_{real_,}seconds() inconsistently. Either
> one of those two would have worked, but mixing them
> does not.
> 
> Staying with the original intention of the patch, this
> changes the ktime_get_seconds() calls into ktime_get_real_seconds(),
> using real time instead of mononic time.

Reviewed-by: James Simmons <jsimmons@infradead.org>
 
> Cc: stable at vger.kernel.org # v4.4+
> Fixes: 8f83409cf238 ("staging/lustre: use 64-bit time for pl_recalc")
> Reported-by: James Simmons <jsimmons@infradead.org>
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> ---
> v2: James' patch was similarly incomplete to mine, as it only
> addressed some of the calls. With this new version, all ktime
> accessors use the same time domain.
> 
> diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c b/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c
> index 19831c555c49..b820309d70e3 100644
> --- a/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c
> +++ b/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c
> @@ -356,10 +356,10 @@ static int ldlm_pool_recalc(struct ldlm_pool *pl)
>  	u32 recalc_interval_sec;
>  	int count;
>  
> -	recalc_interval_sec = ktime_get_seconds() - pl->pl_recalc_time;
> +	recalc_interval_sec = ktime_get_real_seconds() - pl->pl_recalc_time;
>  	if (recalc_interval_sec > 0) {
>  		spin_lock(&pl->pl_lock);
> -		recalc_interval_sec = ktime_get_seconds() - pl->pl_recalc_time;
> +		recalc_interval_sec = ktime_get_real_seconds() - pl->pl_recalc_time;
>  
>  		if (recalc_interval_sec > 0) {
>  			/*
> @@ -382,7 +382,7 @@ static int ldlm_pool_recalc(struct ldlm_pool *pl)
>  				    count);
>  	}
>  
> -	recalc_interval_sec = pl->pl_recalc_time - ktime_get_seconds() +
> +	recalc_interval_sec = pl->pl_recalc_time - ktime_get_real_seconds() +
>  			      pl->pl_recalc_period;
>  	if (recalc_interval_sec <= 0) {
>  		/* DEBUG: should be re-removed after LU-4536 is fixed */
> @@ -657,7 +657,7 @@ int ldlm_pool_init(struct ldlm_pool *pl, struct ldlm_namespace *ns,
>  
>  	spin_lock_init(&pl->pl_lock);
>  	atomic_set(&pl->pl_granted, 0);
> -	pl->pl_recalc_time = ktime_get_seconds();
> +	pl->pl_recalc_time = ktime_get_real_seconds();
>  	atomic_set(&pl->pl_lock_volume_factor, 1);
>  
>  	atomic_set(&pl->pl_grant_rate, 0);
> 
> 
