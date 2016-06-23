From: Lidza Louina <lidza.louina@oracle.com>
Date: Thu, 23 Jun 2016 11:07:28 -0700 (PDT)
Subject: [lustre-devel] [PATCH] staging/lustre/lnet: correctly casts
 value for arithmetic
Message-ID: <db0de3d1-1ae3-4121-9a59-36fe5619caea@default>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


----- Original Message -----
From: oleg.drokin@intel.com
To: lidza.louina at oracle.com
Cc: gregkh at linuxfoundation.org, lustre-devel at lists.lustre.org, devel at driverdev.osuosl.org, andreas.dilger at intel.com
Sent: Thursday, June 23, 2016 10:52:24 AM GMT -08:00 US/Canada Pacific
Subject: Re: [lustre-devel] [PATCH] staging/lustre/lnet: correctly casts value for arithmetic

NAK.

On Jun 23, 2016, at 1:24 PM, Lidza Louina wrote:

> The code attempted to add an unsigned int to a an unsigned 64-bit
> integer. This patch casts the unsigned regular int to suppress
> smatch warnings.
> 
> Signed-off-by: Lidza Louina <Lidza.Louina@oracle.com>
> ---
> drivers/staging/lustre/lnet/lnet/api-ni.c | 2 +-
> 1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
> index 346db89..5ecb2c7 100644
> --- a/drivers/staging/lustre/lnet/lnet/api-ni.c
> +++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
> @@ -513,7 +513,7 @@ lnet_res_lh_initialize(struct lnet_res_container *rec, lnet_libhandle_t *lh)
> 	unsigned int hash;
> 
> 	lh->lh_cookie = rec->rec_lh_cookie;
> -	rec->rec_lh_cookie += 1 << ibits;
> +	rec->rec_lh_cookie += (__u64)(1 << ibits);

This does not do what you think it does?

You want to convert 1 into 1ULL so that the value you are shifting
if already wide enough bit-wise?

But in fact ibits is: LNET_COOKIE_TYPE_BITS + LNET_CPT_BITS
LNET_COOKIE_TYPE_BITS is 2 and LNET_CPT_BITS is@max 8,
so 10 in total, this should fit into a regular 32 bit integer with zero
problems.
So we should be fine I imagine either way.

And adding 32bit int to 64bit int should always be ok anyway, right?
Is it that the addition of signed to unsigned is problematic?

Or what was the smatch warning?

The smatch warning had to do with the type of value rec->rec_1h_cookie 
was expecting. It's expecting it to be an unsigned 64 bit integer (I 
realize I didn't make that clear in my log). The math is correct, it's 
just the assignment that should be cast. 

The smatch warning was "drivers/staging/lustre/lnet/lnet/api-ni.c:516 
lnet_res_lh_initialize() warn: should '1 << ibits' be a 64 bit type?"

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
