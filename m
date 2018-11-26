From: James Simmons <jsimmons@infradead.org>
Date: Mon, 26 Nov 2018 01:49:01 +0000 (GMT)
Subject: [lustre-devel] [PATCH 7/9] lustre: lnet: Stop MLX5 triggering a
 dump_cqe
In-Reply-To: <154295732806.2850.603181458106225374.stgit@noble>
References: <154295730810.2850.961218355189474016.stgit@noble>
 <154295732806.2850.603181458106225374.stgit@noble>
Message-ID: <alpine.LFD.2.21.1811260146540.32255@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> From: Doug Oucharek <doug.s.oucharek@intel.com>
> 
> We have found that MLX5 will trigger a dump_cqe if we don't
> invalidate the rkey on a newly allocated MR for FastReg usage.
> 
> This fix just tags the MR as invalid on its creation if we are
> using FastReg and that will force it to do an invalidate of the
> rkey on first usage.

I pushed this one already, see https://lkml.org/lkml/2018/3/16/1410.
Dan felt this was more a infiniband layer bug that needed to be fixed.
It could be fixed already upstream or if it is not once this problem
is reported we will need to work the rdma group to fix it.
 
> Signed-off-by: Doug Oucharek <doug.s.oucharek@intel.com>
> WC-bug-id: https://jira.whamcloud.com/browse/LU-8752
> Reviewed-on: https://review.whamcloud.com/24306
> Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
> Reviewed-by: Amir Shehata <amir.shehata@intel.com>
> Reviewed-by: James Simmons <uja.ornl@yahoo.com>
> Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
>  .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c    |    7 ++++++-
>  1 file changed, 6 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
> index ecdf4dee533d..a5eada8ee354 100644
> --- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
> +++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
> @@ -1483,7 +1483,12 @@ static int kiblnd_alloc_freg_pool(struct kib_fmr_poolset *fps,
>  			goto out_middle;
>  		}
>  
> -		frd->frd_valid = true;
> +		/*
> +		 * There appears to be a bug in MLX5 code where you must
> +		 * invalidate the rkey of a new FastReg pool before first
> +		 * using it. Thus, I am marking the FRD invalid here.
> +		 */
> +		frd->frd_valid = false;
>  
>  		list_add_tail(&frd->frd_list, &fpo->fast_reg.fpo_pool_list);
>  		fpo->fast_reg.fpo_pool_size++;
> 
> 
> 
