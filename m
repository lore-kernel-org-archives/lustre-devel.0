From: Dilger, Andreas <andreas.dilger@intel.com>
Date: Wed, 9 Nov 2016 03:50:29 +0000
Subject: [lustre-devel] [PATCH] staging: lustre: ldlm: pl_recalc
	time	handling is wrong
In-Reply-To: <1478573240-12850-1-git-send-email-jsimmons@infradead.org>
References: <1478573240-12850-1-git-send-email-jsimmons@infradead.org>
Message-ID: <4C1355CC-5CF8-4AB3-95F1-B356EC357D00@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Simmons <jsimmons@infradead.org>, Arnd Bergmann <arnd@arndb.de>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>, "Drokin, Oleg" <oleg.drokin@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

On Nov 7, 2016, at 19:47, James Simmons <jsimmons@infradead.org> wrote:
> 
> The ldlm_pool field pl_recalc_time is set to the current
> monotonic clock value but the interval period is calculated
> with the wall clock. This means the interval period will
> always be far larger than the pl_recalc_period, which is
> just a small interval time period. The correct thing to
> do is to use monotomic clock current value instead of the
> wall clocks value when calculating recalc_interval_sec.

It looks like this was introduced by commit 8f83409cf
"staging/lustre: use 64-bit time for pl_recalc" but that patch changed
get_seconds() to a mix of ktime_get_seconds() and ktime_get_real_seconds()
for an unknown reason.  It doesn't appear that there is any difference
in overhead between the two (on 64-bit at least).

Since the ldlm pool recalculation interval is actually driven in response to
load on the server, it makes sense to use the "real" time instead of the
monotonic time (if I understand correctly) if the client is in a VM that
may periodically be blocked and "miss time" compared to the outside world.
Using the "real" clock, the recalc_interval_sec will correctly reflect the
actual elapsed time rather than just the number of ticks inside the VM.

Is my understanding of these different clocks correct?

Cheers, Andreas

> 
> Signed-off-by: James Simmons <jsimmons@infradead.org>
> ---
> drivers/staging/lustre/lustre/ldlm/ldlm_pool.c |    6 +++---
> 1 files changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c b/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c
> index 19831c5..30d4f80 100644
> --- a/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c
> +++ b/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c
> @@ -256,7 +256,7 @@ static int ldlm_cli_pool_recalc(struct ldlm_pool *pl)
> 	time64_t recalc_interval_sec;
> 	int ret;
> 
> -	recalc_interval_sec = ktime_get_real_seconds() - pl->pl_recalc_time;
> +	recalc_interval_sec = ktime_get_seconds() - pl->pl_recalc_time;
> 	if (recalc_interval_sec < pl->pl_recalc_period)
> 		return 0;
> 
> @@ -264,7 +264,7 @@ static int ldlm_cli_pool_recalc(struct ldlm_pool *pl)
> 	/*
> 	 * Check if we need to recalc lists now.
> 	 */
> -	recalc_interval_sec = ktime_get_real_seconds() - pl->pl_recalc_time;
> +	recalc_interval_sec = ktime_get_seconds() - pl->pl_recalc_time;
> 	if (recalc_interval_sec < pl->pl_recalc_period) {
> 		spin_unlock(&pl->pl_lock);
> 		return 0;
> @@ -301,7 +301,7 @@ static int ldlm_cli_pool_recalc(struct ldlm_pool *pl)
> 	 * Time of LRU resizing might be longer than period,
> 	 * so update after LRU resizing rather than before it.
> 	 */
> -	pl->pl_recalc_time = ktime_get_real_seconds();
> +	pl->pl_recalc_time = ktime_get_seconds();
> 	lprocfs_counter_add(pl->pl_stats, LDLM_POOL_TIMING_STAT,
> 			    recalc_interval_sec);
> 	spin_unlock(&pl->pl_lock);
> -- 
> 1.7.1
> 
> _______________________________________________
> lustre-devel mailing list
> lustre-devel at lists.lustre.org
> http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
