From: Oleg Drokin <oleg.drokin@intel.com>
Date: Thu, 23 Jun 2016 15:14:20 -0400
Subject: [lustre-devel] [PATCH v2] staging/lustre/lnet: changes value to
	correct type for assignment
In-Reply-To: <1466708196.10566.1.camel@lidza-VirtualBox>
References: <1466708196.10566.1.camel@lidza-VirtualBox>
Message-ID: <700D06CB-A2AD-43BE-BA82-555E78AC252C@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


On Jun 23, 2016, at 2:56 PM, Lidza Louina wrote:

> The code attempted to add an unsigned int to a an unsigned 64-bit
> integer. This patch makes the code use the correct type of int to
> suppress a smatch warning.

I think you might want to update the commit message too, because
it does not really make much sense now.

> 
> Signed-off-by: Lidza Louina <lidza.louina@oracle.com>
> ---
> drivers/staging/lustre/lnet/lnet/api-ni.c | 2 +-
> 1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
> index 346db89..fc5b763 100644
> --- a/drivers/staging/lustre/lnet/lnet/api-ni.c
> +++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
> @@ -513,7 +513,7 @@ lnet_res_lh_initialize(struct lnet_res_container *rec, lnet_libhandle_t *lh)
> 	unsigned int hash;
> 
> 	lh->lh_cookie = rec->rec_lh_cookie;
> -	rec->rec_lh_cookie += 1 << ibits;
> +	rec->rec_lh_cookie += (1ULL << ibits);
> 
> 	hash = (lh->lh_cookie >> ibits) & LNET_LH_HASH_MASK;
> 
> -- 
> 1.9.1
> 
> 
> 
> _______________________________________________
> lustre-devel mailing list
> lustre-devel at lists.lustre.org
> http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
