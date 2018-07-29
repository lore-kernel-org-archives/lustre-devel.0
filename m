From: James Simmons <jsimmons@infradead.org>
Date: Sun, 29 Jul 2018 17:58:25 +0100 (BST)
Subject: [lustre-devel] [PATCH 2/9] lustre: llog: use GFP_KERNEL for all
 allocations.
In-Reply-To: <153232698483.26222.2842073304458010313.stgit@noble>
References: <153232696720.26222.9658151633697867322.stgit@noble>
 <153232698483.26222.2842073304458010313.stgit@noble>
Message-ID: <alpine.LFD.2.21.1807291757210.2402@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> Processing the log happens at mount time so
> memory allocations will not trigger write-out to
> this filesystem which might deadlock.
> So use of GFP_NOFS is not needed.
> GFP_KERNEL is preferred, especially for kvmalloc()
> which doesn't try the 'vmalloc' option when
> GFP_KERNEL is not specified.

Reviewed-by: James Simmons <jsimmons@infradead.org>
 
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
>  drivers/staging/lustre/lustre/obdclass/llog.c |    6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lustre/obdclass/llog.c b/drivers/staging/lustre/lustre/obdclass/llog.c
> index f59f89a76c91..8644d349535e 100644
> --- a/drivers/staging/lustre/lustre/obdclass/llog.c
> +++ b/drivers/staging/lustre/lustre/obdclass/llog.c
> @@ -59,7 +59,7 @@ static struct llog_handle *llog_alloc_handle(void)
>  {
>  	struct llog_handle *loghandle;
>  
> -	loghandle = kzalloc(sizeof(*loghandle), GFP_NOFS);
> +	loghandle = kzalloc(sizeof(*loghandle), GFP_KERNEL);
>  	if (!loghandle)
>  		return NULL;
>  
> @@ -242,7 +242,7 @@ static int llog_process_thread(void *arg)
>  	/* expect chunk_size to be power of two */
>  	LASSERT(is_power_of_2(chunk_size));
>  
> -	buf = kvzalloc(chunk_size, GFP_NOFS);
> +	buf = kvzalloc(chunk_size, GFP_KERNEL);
>  	if (!buf) {
>  		lpi->lpi_rc = -ENOMEM;
>  		return 0;
> @@ -421,7 +421,7 @@ int llog_process_or_fork(const struct lu_env *env,
>  	struct llog_process_info *lpi;
>  	int		      rc;
>  
> -	lpi = kzalloc(sizeof(*lpi), GFP_NOFS);
> +	lpi = kzalloc(sizeof(*lpi), GFP_KERNEL);
>  	if (!lpi)
>  		return -ENOMEM;
>  	lpi->lpi_loghandle = loghandle;
> 
> 
> 
