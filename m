From: Dilger, Andreas <andreas.dilger@intel.com>
Date: Sun, 3 Dec 2017 00:47:03 +0000
Subject: [lustre-devel] [PATCH] staging: lustre: check result of
 register_shrinker
In-Reply-To: <20171202184046.4338-1-akaraliou.dev@gmail.com>
References: <20171202184046.4338-1-akaraliou.dev@gmail.com>
Message-ID: <985AF256-3022-45FB-BFCF-1E2B0F622AA8@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Dec 2, 2017, at 11:40, Aliaksei Karaliou <akaraliou.dev@gmail.com> wrote:
> 
> Lustre code lacks checking the result of register_shrinker()
> in several places. register_shrinker() was tagged __must_check
> recently so that sparse has started reporting it.

Thank you for your patch.  Some comments below.

> Signed-off-by: Aliaksei Karaliou <akaraliou.dev@gmail.com>
> ---
> drivers/staging/lustre/lustre/ldlm/ldlm_pool.c     |  7 +++++--
> drivers/staging/lustre/lustre/obdclass/lu_object.c |  5 +++--
> drivers/staging/lustre/lustre/osc/osc_request.c    |  4 +++-
> drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c    | 13 ++++++++-----
> 4 files changed, 19 insertions(+), 10 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c b/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c
> index da65d00a7811..7795ececa6d3 100644
> --- a/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c
> +++ b/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c
> @@ -1086,8 +1086,11 @@ int ldlm_pools_init(void)
> 	int rc;
> 
> 	rc = ldlm_pools_thread_start();
> -	if (rc == 0)
> -		register_shrinker(&ldlm_pools_cli_shrinker);
> +	if (rc == 0) {
> +		rc = register_shrinker(&ldlm_pools_cli_shrinker);
> +		if (rc)
> +			ldlm_pools_thread_stop();
> +	}

Rather than nesting conditionals like this, kernel style prefers to use
"goto label" to do the cleanup in one place at the end of the function.
That keeps the indentation level reasonable, and avoids making the error
handling increasingly complex if more conditions are added in the future.
The preferred way to handle this would be:

	rc = ldlm_pools_thread_start();
	if (rc)
		goto out;

	rc = register_shrinker(&ldlm_pools_cli_shrinker);
	if (rc)
		goto out_pools;

	return 0;

out_pools:
	ldlm_pools_thread_stop();
out:
	goto out;
}

Then, if a new error condition is added, it just means an "out_shrinker:"
label is added and calling unregister_shrinker() at that point.

> diff --git a/drivers/staging/lustre/lustre/obdclass/lu_object.c b/drivers/staging/lustre/lustre/obdclass/lu_object.c
> index b938a3f9d50a..9e0256ca2079 100644
> --- a/drivers/staging/lustre/lustre/obdclass/lu_object.c
> +++ b/drivers/staging/lustre/lustre/obdclass/lu_object.c
> @@ -1951,7 +1951,7 @@ int lu_global_init(void)
> 	 * inode, one for ea. Unfortunately setting this high value results in
> 	 * lu_object/inode cache consuming all the memory.
> 	 */
> -	register_shrinker(&lu_site_shrinker);
> +	result = register_shrinker(&lu_site_shrinker);
> 
> 	return result;

> }
> @@ -1961,7 +1961,8 @@ int lu_global_init(void)
>  */
> void lu_global_fini(void)
> {
> -	unregister_shrinker(&lu_site_shrinker);
> +	if (lu_site_shrinker.nr_deferred)
> +		unregister_shrinker(&lu_site_shrinker);
> 	lu_context_key_degister(&lu_global_key);

Initially, I didn't think this was needed, but it seems that
unregister_shrinker() is not safe to be called on a shrinker that was
not initialized properly.

While the above check makes this callsite safe, and I'm OK with landing
this part of the patch, it might be safer for the kernel as a whole if
unregister_shrinker() was made safe against this internally?  Something like:

 void unregister_shrinker(struct shrinker *shrinker)
 {
+	if (!shrinker->nr_deferred)
+		return;
+
        down_write(&shrinker_rwsem);
        list_del(&shrinker->list);
        up_write(&shrinker_rwsem);
        kfree(shrinker->nr_deferred);
+	shrinker->nr_deferred = NULL;
 }

That avoids the need for the caller to "know" about nr_deferred.

> 
> 	/*
> diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
> index 53eda4c99142..45b1ebf33363 100644
> --- a/drivers/staging/lustre/lustre/osc/osc_request.c
> +++ b/drivers/staging/lustre/lustre/osc/osc_request.c
> @@ -2844,7 +2844,9 @@ static int __init osc_init(void)
> 	if (rc)
> 		goto out_kmem;
> 
> -	register_shrinker(&osc_cache_shrinker);
> +	rc = register_shrinker(&osc_cache_shrinker);
> +	if (rc)
> +		goto out_type;
> 
> 	/* This is obviously too much memory, only prevent overflow here */
> 	if (osc_reqpool_mem_max >= 1 << 12 || osc_reqpool_mem_max == 0) {
> diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c b/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c
> index 77a3721beaee..4eeff832fd4a 100644
> --- a/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c
> +++ b/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c
> @@ -396,6 +396,8 @@ static struct shrinker pools_shrinker = {
> 
> int sptlrpc_enc_pool_init(void)
> {
> +	int rc = -ENOMEM;
> +
> 	/*
> 	 * maximum capacity is 1/8 of total physical memory.
> 	 * is the 1/8 a good number?
> @@ -429,12 +431,13 @@ int sptlrpc_enc_pool_init(void)
> 	page_pools.epp_st_outofmem = 0;
> 
> 	enc_pools_alloc();
> -	if (!page_pools.epp_pools)
> -		return -ENOMEM;
> -
> -	register_shrinker(&pools_shrinker);
> +	if (page_pools.epp_pools) {
> +		rc = register_shrinker(&pools_shrinker);
> +		if (rc)
> +			enc_pools_free();
> +	}

Same comment here as above - please use labels to handle error cleanup.

> -	return 0;
> +	return rc;
> }
> 
> void sptlrpc_enc_pool_fini(void)
> -- 
> 2.11.0
> 

Cheers, Andreas
--
Andreas Dilger
Lustre Principal Architect
Intel Corporation
