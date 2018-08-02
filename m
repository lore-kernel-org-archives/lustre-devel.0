From: James Simmons <jsimmons@infradead.org>
Date: Thu, 2 Aug 2018 04:46:53 +0100 (BST)
Subject: [lustre-devel] [PATCH 4/7] lustre: give different tcd_lock
 types different classes.
In-Reply-To: <153292257292.26496.6025900918938045378.stgit@noble>
References: <153292249340.26496.13985174182824912332.stgit@noble>
 <153292257292.26496.6025900918938045378.stgit@noble>
Message-ID: <alpine.LFD.2.21.1808020446430.5677@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> There are three different trace contexts:
>  process, softirq, irq.
> Each has its own lock (tcd_lock) which is locked
> as appropriate for that context.
> lockdep currently doesn't see that they are different
> and so deduces that the different uses might lead to
> deadlocks.
> So use separate calls to spin_lock_init() so that they
> each get a separate lock class, and lockdep sees no
> problem.

Reviewed-by: James Simmons <jsimmons@infradead.org>
 
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
>  drivers/staging/lustre/lnet/libcfs/tracefile.c |   18 +++++++++++++++++-
>  1 file changed, 17 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/staging/lustre/lnet/libcfs/tracefile.c b/drivers/staging/lustre/lnet/libcfs/tracefile.c
> index d4c80cf254e4..40048165fc16 100644
> --- a/drivers/staging/lustre/lnet/libcfs/tracefile.c
> +++ b/drivers/staging/lustre/lnet/libcfs/tracefile.c
> @@ -1285,7 +1285,23 @@ int cfs_tracefile_init(int max_pages)
>  	cfs_tcd_for_each(tcd, i, j) {
>  		int factor = pages_factor[i];
>  
> -		spin_lock_init(&tcd->tcd_lock);
> +		/* Note that we have three separate calls so
> +		 * they the locks get three separate classes
> +		 * and lockdep never thinks they are related.
> +		 * As they are used in different interrupt
> +		 * contexts, lockdep think the usage would conflict.
> +		 */
> +		switch(i) {
> +		case CFS_TCD_TYPE_PROC:
> +			spin_lock_init(&tcd->tcd_lock);
> +			break;
> +		case CFS_TCD_TYPE_SOFTIRQ:
> +			spin_lock_init(&tcd->tcd_lock);
> +			break;
> +		case CFS_TCD_TYPE_IRQ:
> +			spin_lock_init(&tcd->tcd_lock);
> +			break;
> +		}
>  		tcd->tcd_pages_factor = factor;
>  		tcd->tcd_type = i;
>  		tcd->tcd_cpu = j;
> 
> 
> 
