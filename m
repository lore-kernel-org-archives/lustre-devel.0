From: Lidza Louina <lidza.louina@oracle.com>
Date: Thu, 23 Jun 2016 12:27:45 -0700 (PDT)
Subject: [lustre-devel] [PATCH v2] staging/lustre/lnet: changes value to
 correct type for assignment
Message-ID: <21218c92-e429-45df-aa98-1d91c6333957@default>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


----- Original Message -----
From: oleg.drokin@intel.com
To: lidza.louina at oracle.com
Cc: gregkh at linuxfoundation.org, lustre-devel at lists.lustre.org, devel at driverdev.osuosl.org, andreas.dilger at intel.com
Sent: Thursday, June 23, 2016 12:14:28 PM GMT -08:00 US/Canada Pacific
Subject: Re: [lustre-devel] [PATCH v2] staging/lustre/lnet: changes value to correct type for assignment


On Jun 23, 2016, at 2:56 PM, Lidza Louina wrote:

> The code attempted to add an unsigned int to a an unsigned 64-bit
> integer. This patch makes the code use the correct type of int to
> suppress a smatch warning.

I think you might want to update the commit message too, because
it does not really make much sense now.

How about

"The patch changes a value's type so it can be assigned correctly. 
This problem was caught by smatch."

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
