From: James Simmons <jsimmons@infradead.org>
Date: Thu, 2 Aug 2018 03:53:31 +0100 (BST)
Subject: [lustre-devel] [PATCH 02/22] Revert "staging: lustre: o2iblnd:
 Use list_for_each_entry_safe in kiblnd_destroy_fmr_pool_list"
In-Reply-To: <153292186069.13840.6426045683936468910.stgit@noble>
References: <153292153459.13840.17465048403476297915.stgit@noble>
 <153292186069.13840.6426045683936468910.stgit@noble>
Message-ID: <alpine.LFD.2.21.1808020353140.5677@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

> This reverts commit 0d33ec5f95fe068d7e96b6e7ed9216de93f6b5b0.
> 
> These loops really want to remove everything, and using a
>   while(!list_empty())
> loop makes this more obvious.
>

Reviewed-by: James Simmons <jsimmons@infradead.org>
 
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
>  .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c    |    5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
> index 05835cc0f0a5..124870ada28b 100644
> --- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
> +++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
> @@ -1306,9 +1306,10 @@ static void kiblnd_destroy_fmr_pool(struct kib_fmr_pool *fpo)
>  
>  static void kiblnd_destroy_fmr_pool_list(struct list_head *head)
>  {
> -	struct kib_fmr_pool *fpo, *tmp;
> +	struct kib_fmr_pool *fpo;
>  
> -	list_for_each_entry_safe(fpo, tmp, head, fpo_list) {
> +	while (!list_empty(head)) {
> +		fpo = list_entry(head->next, struct kib_fmr_pool, fpo_list);
>  		list_del(&fpo->fpo_list);
>  		kiblnd_destroy_fmr_pool(fpo);
>  	}
> 
> 
> 
