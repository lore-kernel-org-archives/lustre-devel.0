From: James Simmons <jsimmons@infradead.org>
Date: Thu, 2 Aug 2018 03:56:48 +0100 (BST)
Subject: [lustre-devel] [PATCH 05/22] Revert "staging: lustre: lnet:
 socklnd_proto: Use list_for_each_entry_safe"
In-Reply-To: <153292186081.13840.4047441745421559567.stgit@noble>
References: <153292153459.13840.17465048403476297915.stgit@noble>
 <153292186081.13840.4047441745421559567.stgit@noble>
Message-ID: <alpine.LFD.2.21.1808020356370.5677@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> This reverts commit 1edae04ff85fe65a333949de6101578c015a21fa.
> 
> These loops really want to remove everything, and using a
>   while(!list_empty())
> loop makes this more obvious.

Reviewed-by: James Simmons <jsimmons@infradead.org>
 
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
>  .../lustre/lnet/klnds/socklnd/socklnd_proto.c      |    4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_proto.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_proto.c
> index aaa04a5f0527..abfaf5701758 100644
> --- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_proto.c
> +++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_proto.c
> @@ -413,7 +413,6 @@ ksocknal_handle_zcack(struct ksock_conn *conn, __u64 cookie1, __u64 cookie2)
>  {
>  	struct ksock_peer *peer = conn->ksnc_peer;
>  	struct ksock_tx *tx;
> -	struct ksock_tx *temp;
>  	struct ksock_tx *tmp;
>  	LIST_HEAD(zlist);
>  	int count;
> @@ -448,7 +447,8 @@ ksocknal_handle_zcack(struct ksock_conn *conn, __u64 cookie1, __u64 cookie2)
>  
>  	spin_unlock(&peer->ksnp_lock);
>  
> -	list_for_each_entry_safe(tx, temp, &zlist, tx_zc_list) {
> +	while (!list_empty(&zlist)) {
> +		tx = list_entry(zlist.next, struct ksock_tx, tx_zc_list);
>  		list_del(&tx->tx_zc_list);
>  		ksocknal_tx_decref(tx);
>  	}
> 
> 
> 
