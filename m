From: James Simmons <jsimmons@infradead.org>
Date: Thu, 2 Aug 2018 04:09:09 +0100 (BST)
Subject: [lustre-devel] [PATCH 18/22] lustre: net_fault: convert
 list_for_each_entry_safe() to while(!list_empty())
In-Reply-To: <153292186135.13840.3626019723821443531.stgit@noble>
References: <153292153459.13840.17465048403476297915.stgit@noble>
 <153292186135.13840.3626019723821443531.stgit@noble>
Message-ID: <alpine.LFD.2.21.1808020408590.5677@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> These loops are removing all elements from a list.
> So using while(!list_empty()) makes the intent clearer.

Reviewed-by: James Simmons <jsimmons@infradead.org>
 
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
>  drivers/staging/lustre/lnet/lnet/net_fault.c |    7 +++++--
>  1 file changed, 5 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lnet/lnet/net_fault.c b/drivers/staging/lustre/lnet/lnet/net_fault.c
> index cb1f9053ef48..41d6131ee15a 100644
> --- a/drivers/staging/lustre/lnet/lnet/net_fault.c
> +++ b/drivers/staging/lustre/lnet/lnet/net_fault.c
> @@ -216,7 +216,8 @@ lnet_drop_rule_del(lnet_nid_t src, lnet_nid_t dst)
>  	}
>  	lnet_net_unlock(LNET_LOCK_EX);
>  
> -	list_for_each_entry_safe(rule, tmp, &zombies, dr_link) {
> +	while (!list_empty(&zombies)) {
> +		rule = list_first_entry(&zombies, struct lnet_drop_rule, dr_link);
>  		CDEBUG(D_NET, "Remove drop rule: src %s->dst: %s (1/%d, %d)\n",
>  		       libcfs_nid2str(rule->dr_attr.fa_src),
>  		       libcfs_nid2str(rule->dr_attr.fa_dst),
> @@ -841,7 +842,9 @@ lnet_delay_rule_del(lnet_nid_t src, lnet_nid_t dst, bool shutdown)
>  		  !list_empty(&rule_list);
>  	lnet_net_unlock(LNET_LOCK_EX);
>  
> -	list_for_each_entry_safe(rule, tmp, &rule_list, dl_link) {
> +	while (!list_empty(&rule_list)) {
> +		rule = list_first_entry(&rule_list,
> +					struct lnet_delay_rule, dl_link);
>  		list_del_init(&rule->dl_link);
>  
>  		del_timer_sync(&rule->dl_timer);
> 
> 
> 
