From: James Simmons <jsimmons@infradead.org>
Date: Thu, 2 Aug 2018 04:07:41 +0100 (BST)
Subject: [lustre-devel] [PATCH 15/22] lustre: o2iblnd: convert
 list_for_each_entry_safe() to while(!list_empty())
In-Reply-To: <153292186122.13840.1195251525324756487.stgit@noble>
References: <153292153459.13840.17465048403476297915.stgit@noble>
 <153292186122.13840.1195251525324756487.stgit@noble>
Message-ID: <alpine.LFD.2.21.1808020407310.5677@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> These loops are removing all element from a list.
> So using while(!list_empty()) makes the intent clearer.

Reviewed-by: James Simmons <jsimmons@infradead.org>
 
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
>  .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c    |   16 ++++++++++------
>  1 file changed, 10 insertions(+), 6 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
> index 124870ada28b..830a5bf34c16 100644
> --- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
> +++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
> @@ -1283,11 +1283,13 @@ static void kiblnd_destroy_fmr_pool(struct kib_fmr_pool *fpo)
>  		if (fpo->fmr.fpo_fmr_pool)
>  			ib_destroy_fmr_pool(fpo->fmr.fpo_fmr_pool);
>  	} else {
> -		struct kib_fast_reg_descriptor *frd, *tmp;
> +		struct kib_fast_reg_descriptor *frd;
>  		int i = 0;
>  
> -		list_for_each_entry_safe(frd, tmp, &fpo->fast_reg.fpo_pool_list,
> -					 frd_list) {
> +		while (!list_empty(&fpo->fast_reg.fpo_pool_list)) {
> +			frd = list_first_entry(&fpo->fast_reg.fpo_pool_list,
> +					       struct kib_fast_reg_descriptor,
> +					       frd_list);
>  			list_del(&frd->frd_list);
>  			ib_dereg_mr(frd->frd_mr);
>  			kfree(frd);
> @@ -1362,7 +1364,7 @@ static int kiblnd_alloc_fmr_pool(struct kib_fmr_poolset *fps, struct kib_fmr_poo
>  
>  static int kiblnd_alloc_freg_pool(struct kib_fmr_poolset *fps, struct kib_fmr_pool *fpo)
>  {
> -	struct kib_fast_reg_descriptor *frd, *tmp;
> +	struct kib_fast_reg_descriptor *frd;
>  	int i, rc;
>  
>  	INIT_LIST_HEAD(&fpo->fast_reg.fpo_pool_list);
> @@ -1399,8 +1401,10 @@ static int kiblnd_alloc_freg_pool(struct kib_fmr_poolset *fps, struct kib_fmr_po
>  	kfree(frd);
>  
>  out:
> -	list_for_each_entry_safe(frd, tmp, &fpo->fast_reg.fpo_pool_list,
> -				 frd_list) {
> +	while (!list_empty(&fpo->fast_reg.fpo_pool_list)) {
> +		frd = list_first_entry(&fpo->fast_reg.fpo_pool_list,
> +				       struct kib_fast_reg_descriptor,
> +				       frd_list);
>  		list_del(&frd->frd_list);
>  		ib_dereg_mr(frd->frd_mr);
>  		kfree(frd);
> 
> 
> 
