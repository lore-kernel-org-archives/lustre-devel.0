From: James Simmons <jsimmons@infradead.org>
Date: Thu, 2 Aug 2018 04:10:34 +0100 (BST)
Subject: [lustre-devel] [PATCH 22/22] lustre: sec_config: convert
 list_for_each_entry_safe() to while(!list_empty())
In-Reply-To: <153292186151.13840.8095964948258952076.stgit@noble>
References: <153292153459.13840.17465048403476297915.stgit@noble>
 <153292186151.13840.8095964948258952076.stgit@noble>
Message-ID: <alpine.LFD.2.21.1808020410250.5677@casper.infradead.org>
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
>  drivers/staging/lustre/lustre/ptlrpc/sec_config.c |    7 ++++---
>  1 file changed, 4 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec_config.c b/drivers/staging/lustre/lustre/ptlrpc/sec_config.c
> index 2389f9a8f534..1844ada6780f 100644
> --- a/drivers/staging/lustre/lustre/ptlrpc/sec_config.c
> +++ b/drivers/staging/lustre/lustre/ptlrpc/sec_config.c
> @@ -839,12 +839,13 @@ int sptlrpc_conf_init(void)
>  
>  void sptlrpc_conf_fini(void)
>  {
> -	struct sptlrpc_conf *conf, *conf_next;
> +	struct sptlrpc_conf *conf;
>  
>  	mutex_lock(&sptlrpc_conf_lock);
> -	list_for_each_entry_safe(conf, conf_next, &sptlrpc_confs, sc_list) {
> +	while (!list_empty(&sptlrpc_confs)) {
> +		conf = list_first_entry(&sptlrpc_confs,
> +					struct sptlrpc_conf, sc_list);
>  		sptlrpc_conf_free(conf);
>  	}
> -	LASSERT(list_empty(&sptlrpc_confs));
>  	mutex_unlock(&sptlrpc_conf_lock);
>  }
> 
> 
> 
