From: James Simmons <jsimmons@infradead.org>
Date: Thu, 2 Aug 2018 04:13:09 +0100 (BST)
Subject: [lustre-devel] [PATCH 2/6] lustre: lnet/config: convert
 list_for_each to list_for_each_entry
In-Reply-To: <153292233958.26104.10972399803477314475.stgit@noble>
References: <153292233170.26104.16164388413209501300.stgit@noble>
 <153292233958.26104.10972399803477314475.stgit@noble>
Message-ID: <alpine.LFD.2.21.1808020412580.5677@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> This conversion to list_for_each_entry isn't quite trivial
> as the 'tmp' loop variables are used elsewhere in the function.
> This means we cannot just delete them, and so must inspect the
> code to ensure the values aren't used elsewhere - they aren't.
> 
> Also we need to introduce new loop variables: ltb1 and ltb2 as
> the lnet_text_buf was the some for both the original (nested) loops.

Reviewed-by: James Simmons <jsimmons@infradead.org>
 
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
>  drivers/staging/lustre/lnet/lnet/config.c |   11 +++++------
>  1 file changed, 5 insertions(+), 6 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lnet/lnet/config.c b/drivers/staging/lustre/lnet/lnet/config.c
> index 96336ecdacaf..091c4f714e84 100644
> --- a/drivers/staging/lustre/lnet/lnet/config.c
> +++ b/drivers/staging/lustre/lnet/lnet/config.c
> @@ -662,6 +662,7 @@ lnet_parse_route(char *str, int *im_a_router)
>  	__u32 net;
>  	lnet_nid_t nid;
>  	struct lnet_text_buf *ltb;
> +	struct lnet_text_buf *ltb1, *ltb2;
>  	int rc;
>  	char *sep;
>  	char *token = str;
> @@ -760,14 +761,12 @@ lnet_parse_route(char *str, int *im_a_router)
>  	LASSERT(!list_empty(&nets));
>  	LASSERT(!list_empty(&gateways));
>  
> -	list_for_each(tmp1, &nets) {
> -		ltb = list_entry(tmp1, struct lnet_text_buf, ltb_list);
> -		net = libcfs_str2net(ltb->ltb_text);
> +	list_for_each_entry(ltb1, &nets, ltb_list) {
> +		net = libcfs_str2net(ltb1->ltb_text);
>  		LASSERT(net != LNET_NIDNET(LNET_NID_ANY));
>  
> -		list_for_each(tmp2, &gateways) {
> -			ltb = list_entry(tmp2, struct lnet_text_buf, ltb_list);
> -			nid = libcfs_str2nid(ltb->ltb_text);
> +		list_for_each_entry(ltb2, &gateways, ltb_list) {
> +			nid = libcfs_str2nid(ltb2->ltb_text);
>  			LASSERT(nid != LNET_NID_ANY);
>  
>  			if (lnet_islocalnid(nid)) {
> 
> 
> 
