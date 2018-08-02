From: James Simmons <jsimmons@infradead.org>
Date: Thu, 2 Aug 2018 03:56:24 +0100 (BST)
Subject: [lustre-devel] [PATCH 04/22] Revert "staging: lustre: lnet:
 socklnd: Use list_for_each_entry_safe"
In-Reply-To: <153292186077.13840.2365613926140981649.stgit@noble>
References: <153292153459.13840.17465048403476297915.stgit@noble>
 <153292186077.13840.2365613926140981649.stgit@noble>
Message-ID: <alpine.LFD.2.21.1808020354340.5677@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> This reverts commit 2aff15d43a832cd0af0263e4456e5b01e15f86c6.
> 
> These loops really want to remove everything, and using a
>   while(!list_empty())
> loop makes this more obvious.

Reviewed-by: James Simmons <jsimmons@infradead.org>
 
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
>  .../staging/lustre/lnet/klnds/socklnd/socklnd.c    |    9 +++++----
>  1 file changed, 5 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
> index 6b1df0c98cbd..a48b1b9a850b 100644
> --- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
> +++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
> @@ -1546,7 +1546,6 @@ ksocknal_finalize_zcreq(struct ksock_conn *conn)
>  {
>  	struct ksock_peer *peer = conn->ksnc_peer;
>  	struct ksock_tx *tx;
> -	struct ksock_tx *temp;
>  	struct ksock_tx *tmp;
>  	LIST_HEAD(zlist);
>  
> @@ -1572,7 +1571,9 @@ ksocknal_finalize_zcreq(struct ksock_conn *conn)
>  
>  	spin_unlock(&peer->ksnp_lock);
>  
> -	list_for_each_entry_safe(tx, temp, &zlist, tx_zc_list) {
> +	while (!list_empty(&zlist)) {
> +		tx = list_entry(zlist.next, struct ksock_tx, tx_zc_list);
> +
>  		list_del(&tx->tx_zc_list);
>  		ksocknal_tx_decref(tx);
>  	}
> @@ -2270,13 +2271,13 @@ ksocknal_free_buffers(void)
>  	if (!list_empty(&ksocknal_data.ksnd_idle_noop_txs)) {
>  		struct list_head zlist;
>  		struct ksock_tx *tx;
> -		struct ksock_tx *temp;
>  
>  		list_add(&zlist, &ksocknal_data.ksnd_idle_noop_txs);
>  		list_del_init(&ksocknal_data.ksnd_idle_noop_txs);
>  		spin_unlock(&ksocknal_data.ksnd_tx_lock);
>  
> -		list_for_each_entry_safe(tx, temp, &zlist, tx_list) {
> +		while (!list_empty(&zlist)) {
> +			tx = list_entry(zlist.next, struct ksock_tx, tx_list);
>  			list_del(&tx->tx_list);
>  			kfree(tx);
>  		}
> 
> 
> 
