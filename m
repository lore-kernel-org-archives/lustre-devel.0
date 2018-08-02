From: James Simmons <jsimmons@infradead.org>
Date: Thu, 2 Aug 2018 04:04:18 +0100 (BST)
Subject: [lustre-devel] [PATCH 08/22] Revert "staging: lustre: lnet:
 config: Use list_for_each_entry_safe"
In-Reply-To: <153292186091.13840.114221205536468808.stgit@noble>
References: <153292153459.13840.17465048403476297915.stgit@noble>
 <153292186091.13840.114221205536468808.stgit@noble>
Message-ID: <alpine.LFD.2.21.1808020404070.5677@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> This reverts commit cb734cf73eaed9b9bb7f190cceaafc15af0d8815.
> 
> These loops really want to remove everything, and using a
>   while(!list_empty())
> loop makes this more obvious.

Reviewed-by: James Simmons <jsimmons@infradead.org>
 
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
>  drivers/staging/lustre/lnet/lnet/config.c |    5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lnet/lnet/config.c b/drivers/staging/lustre/lnet/lnet/config.c
> index 136905db2746..26b799e66e53 100644
> --- a/drivers/staging/lustre/lnet/lnet/config.c
> +++ b/drivers/staging/lustre/lnet/lnet/config.c
> @@ -1026,7 +1026,6 @@ lnet_match_networks(char **networksp, char *ip2nets, __u32 *ipaddrs, int nip)
>  	struct list_head *t;
>  	struct list_head *t2;
>  	struct lnet_text_buf *tb;
> -	struct lnet_text_buf *temp;
>  	struct lnet_text_buf *tb2;
>  	__u32 net1;
>  	__u32 net2;
> @@ -1049,7 +1048,9 @@ lnet_match_networks(char **networksp, char *ip2nets, __u32 *ipaddrs, int nip)
>  	len = 0;
>  	rc = 0;
>  
> -	list_for_each_entry_safe(tb, temp, &raw_entries, ltb_list) {
> +	while (!list_empty(&raw_entries)) {
> +		tb = list_entry(raw_entries.next, struct lnet_text_buf,
> +				ltb_list);
>  		strncpy(source, tb->ltb_text, sizeof(source));
>  		source[sizeof(source) - 1] = '\0';
>  
> 
> 
> 
