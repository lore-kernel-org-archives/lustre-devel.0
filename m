From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Mon, 4 Dec 2017 11:33:04 +0300
Subject: [lustre-devel] [PATCH] staging: lustre: check result of
 register_shrinker
In-Reply-To: <20171202184046.4338-1-akaraliou.dev@gmail.com>
References: <20171202184046.4338-1-akaraliou.dev@gmail.com>
Message-ID: <20171204083304.se5gcmgw5iywsskj@mwanda>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Sat, Dec 02, 2017 at 09:40:46PM +0300, Aliaksei Karaliou wrote:
> Lustre code lacks checking the result of register_shrinker()
> in several places. register_shrinker() was tagged __must_check
> recently so that sparse has started reporting it.
> 
> Signed-off-by: Aliaksei Karaliou <akaraliou.dev@gmail.com>
> ---
>  drivers/staging/lustre/lustre/ldlm/ldlm_pool.c     |  7 +++++--
>  drivers/staging/lustre/lustre/obdclass/lu_object.c |  5 +++--
>  drivers/staging/lustre/lustre/osc/osc_request.c    |  4 +++-
>  drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c    | 13 ++++++++-----
>  4 files changed, 19 insertions(+), 10 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c b/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c
> index da65d00a7811..7795ececa6d3 100644
> --- a/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c
> +++ b/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c
> @@ -1086,8 +1086,11 @@ int ldlm_pools_init(void)
>  	int rc;
>  
>  	rc = ldlm_pools_thread_start();
> -	if (rc == 0)
> -		register_shrinker(&ldlm_pools_cli_shrinker);
> +	if (rc == 0) {
> +		rc = register_shrinker(&ldlm_pools_cli_shrinker);
> +		if (rc)
> +			ldlm_pools_thread_stop();
> +	}
>  
>  	return rc;


Originally, the code had two anti-patterns 1) Making the last check in
the function different from the others, 2)  Success handling instead
of failure handling.  Success handling leads to spaghetti code.  Write
it like this instead.

	rc = ldlm_pools_thread_start();
	if (rc)
		return rc;

	rc = register_shrinker(&ldlm_pools_cli_shrinker);
	if (rc) {
		ldlm_pools_thread_stop();
		return rc;
	}

	return 0;


>  }
> diff --git a/drivers/staging/lustre/lustre/obdclass/lu_object.c b/drivers/staging/lustre/lustre/obdclass/lu_object.c
> index b938a3f9d50a..9e0256ca2079 100644
> --- a/drivers/staging/lustre/lustre/obdclass/lu_object.c
> +++ b/drivers/staging/lustre/lustre/obdclass/lu_object.c
> @@ -1951,7 +1951,7 @@ int lu_global_init(void)
>  	 * inode, one for ea. Unfortunately setting this high value results in
>  	 * lu_object/inode cache consuming all the memory.
>  	 */
> -	register_shrinker(&lu_site_shrinker);
> +	result = register_shrinker(&lu_site_shrinker);

There should be some error handling if the register fails.

>  
>  	return result;
>  }
> @@ -1961,7 +1961,8 @@ int lu_global_init(void)
>   */
>  void lu_global_fini(void)
>  {
> -	unregister_shrinker(&lu_site_shrinker);
> +	if (lu_site_shrinker.nr_deferred)
> +		unregister_shrinker(&lu_site_shrinker);
>  	lu_context_key_degister(&lu_global_key);
>  
>  	/*
> diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
> index 53eda4c99142..45b1ebf33363 100644
> --- a/drivers/staging/lustre/lustre/osc/osc_request.c
> +++ b/drivers/staging/lustre/lustre/osc/osc_request.c
> @@ -2844,7 +2844,9 @@ static int __init osc_init(void)
>  	if (rc)
>  		goto out_kmem;
>  
> -	register_shrinker(&osc_cache_shrinker);
> +	rc = register_shrinker(&osc_cache_shrinker);
> +	if (rc)
> +		goto out_type;
>  
>  	/* This is obviously too much memory, only prevent overflow here */
>  	if (osc_reqpool_mem_max >= 1 << 12 || osc_reqpool_mem_max == 0) {
> diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c b/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c
> index 77a3721beaee..4eeff832fd4a 100644
> --- a/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c
> +++ b/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c
> @@ -396,6 +396,8 @@ static struct shrinker pools_shrinker = {
>  
>  int sptlrpc_enc_pool_init(void)
>  {
> +	int rc = -ENOMEM;
> +
>  	/*
>  	 * maximum capacity is 1/8 of total physical memory.
>  	 * is the 1/8 a good number?
> @@ -429,12 +431,13 @@ int sptlrpc_enc_pool_init(void)
>  	page_pools.epp_st_outofmem = 0;
>  
>  	enc_pools_alloc();
> -	if (!page_pools.epp_pools)
> -		return -ENOMEM;
> -
> -	register_shrinker(&pools_shrinker);
> +	if (page_pools.epp_pools) {
> +		rc = register_shrinker(&pools_shrinker);
> +		if (rc)
> +			enc_pools_free();
> +	}
>  
> -	return 0;
> +	return rc;

This new code is *really* hard to read.  The original was more readable.
Do it like this:

	if (!page_pools.epp_pools)
		return -ENOMEM;

	rc = register_shrinker(&pools_shrinker);
	if (rc) {
		enc_pools_free();
		return rc;
	}

	return 0;


regards,
dan carpenter
