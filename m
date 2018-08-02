From: James Simmons <jsimmons@infradead.org>
Date: Thu, 2 Aug 2018 04:06:56 +0100 (BST)
Subject: [lustre-devel] [PATCH 13/22] Revert "staging: lustre: lnet: Use
 list_for_each_entry_safe"
In-Reply-To: <153292186113.13840.10926881392361029642.stgit@noble>
References: <153292153459.13840.17465048403476297915.stgit@noble>
 <153292186113.13840.10926881392361029642.stgit@noble>
Message-ID: <alpine.LFD.2.21.1808020406430.5677@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> This reverts commit 0daec763260e4f0d8038512b72971ddbcf1c63a1.
> 
> These loops really want to remove everything, and using a
>   while(!list_empty())
> loop makes this more obvious.

Reviewed-by: James Simmons <jsimmons@infradead.org>
 
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
>  .../staging/lustre/lnet/klnds/socklnd/socklnd_cb.c |    5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
> index 3f69618ad85b..d531847305e4 100644
> --- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
> +++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
> @@ -2260,12 +2260,13 @@ static inline void
>  ksocknal_flush_stale_txs(struct ksock_peer *peer)
>  {
>  	struct ksock_tx *tx;
> -	struct ksock_tx *tmp;
>  	LIST_HEAD(stale_txs);
>  
>  	write_lock_bh(&ksocknal_data.ksnd_global_lock);
>  
> -	list_for_each_entry_safe(tx, tmp, &peer->ksnp_tx_queue, tx_list) {
> +	while (!list_empty(&peer->ksnp_tx_queue)) {
> +		tx = list_entry(peer->ksnp_tx_queue.next, struct ksock_tx, tx_list);
> +
>  		if (ktime_get_seconds() < tx->tx_deadline)
>  			break;
>  
> 
> 
> 
