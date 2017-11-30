From: Dilger, Andreas <andreas.dilger@intel.com>
Date: Thu, 30 Nov 2017 00:45:03 +0000
Subject: [lustre-devel] [PATCH] staging: lustre: Check for
 register_shrinker() failure.
In-Reply-To: <1511962602-3840-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
References: <1511962602-3840-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Message-ID: <440FDAB5-EEAD-4C44-9646-3DA33D811215@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Nov 29, 2017, at 06:36, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp> wrote:
> 
> register_shrinker() might return -ENOMEM error since Linux 3.12.
> Note that since callers are not always calling undo functions
> appropriately, error handling added by this patch might not be helpful.
> 
> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Cc: Oleg Drokin <oleg.drokin@intel.com>
> Cc: James Simmons <jsimmons@infradead.org>
> Cc: Michal Hocko <mhocko@suse.com>

Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>


> ---
> drivers/staging/lustre/lustre/ldlm/ldlm_pool.c     | 7 +++++--
> drivers/staging/lustre/lustre/obdclass/lu_object.c | 4 +++-
> drivers/staging/lustre/lustre/osc/osc_request.c    | 4 +++-
> drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c    | 5 ++++-
> 4 files changed, 15 insertions(+), 5 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c b/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c
> index da65d00..7795ece 100644
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
> 
> 	return rc;
> }
> diff --git a/drivers/staging/lustre/lustre/obdclass/lu_object.c b/drivers/staging/lustre/lustre/obdclass/lu_object.c
> index b938a3f..e19f0b9 100644
> --- a/drivers/staging/lustre/lustre/obdclass/lu_object.c
> +++ b/drivers/staging/lustre/lustre/obdclass/lu_object.c
> @@ -1951,7 +1951,9 @@ int lu_global_init(void)
> 	 * inode, one for ea. Unfortunately setting this high value results in
> 	 * lu_object/inode cache consuming all the memory.
> 	 */
> -	register_shrinker(&lu_site_shrinker);
> +	result = register_shrinker(&lu_site_shrinker);
> +	if (result)
> +		lu_global_fini();
> 
> 	return result;
> }
> diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
> index 53eda4c..45b1ebf 100644
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
> index 77a3721..b85ae55 100644
> --- a/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c
> +++ b/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c
> @@ -432,7 +432,10 @@ int sptlrpc_enc_pool_init(void)
> 	if (!page_pools.epp_pools)
> 		return -ENOMEM;
> 
> -	register_shrinker(&pools_shrinker);
> +	if (register_shrinker(&pools_shrinker)) {
> +		enc_pools_free();
> +		return -ENOMEM;
> +	}
> 
> 	return 0;
> }
> -- 
> 1.8.3.1
> 

Cheers, Andreas
--
Andreas Dilger
Lustre Principal Architect
Intel Corporation
