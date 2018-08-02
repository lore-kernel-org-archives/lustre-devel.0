From: James Simmons <jsimmons@infradead.org>
Date: Thu, 2 Aug 2018 04:08:43 +0100 (BST)
Subject: [lustre-devel] [PATCH 17/22] lustre: lib-move: convert
 list_for_each_entry_safe() to while(!list_empty())
In-Reply-To: <153292186130.13840.15403228991288155064.stgit@noble>
References: <153292153459.13840.17465048403476297915.stgit@noble>
 <153292186130.13840.15403228991288155064.stgit@noble>
Message-ID: <alpine.LFD.2.21.1808020408280.5677@casper.infradead.org>
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
>  drivers/staging/lustre/lnet/lnet/lib-move.c |    4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lnet/lnet/lib-move.c b/drivers/staging/lustre/lnet/lnet/lib-move.c
> index 2756e91b34bb..19cab374b6bc 100644
> --- a/drivers/staging/lustre/lnet/lnet/lib-move.c
> +++ b/drivers/staging/lustre/lnet/lnet/lib-move.c
> @@ -853,7 +853,6 @@ lnet_drop_routed_msgs_locked(struct list_head *list, int cpt)
>  {
>  	struct list_head drop;
>  	struct lnet_msg *msg;
> -	struct lnet_msg *tmp;
>  
>  	INIT_LIST_HEAD(&drop);
>  
> @@ -861,7 +860,8 @@ lnet_drop_routed_msgs_locked(struct list_head *list, int cpt)
>  
>  	lnet_net_unlock(cpt);
>  
> -	list_for_each_entry_safe(msg, tmp, &drop, msg_list) {
> +	while(!list_empty(&drop)) {
> +		msg = list_first_entry(&drop, struct lnet_msg, msg_list);
>  		lnet_ni_recv(msg->msg_rxpeer->lp_ni, msg->msg_private, NULL,
>  			     0, 0, 0, msg->msg_hdr.payload_length);
>  		list_del_init(&msg->msg_list);
> 
> 
> 
