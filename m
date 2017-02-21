From: Joe Perches <joe@perches.com>
Date: Tue, 21 Feb 2017 12:40:10 -0800
Subject: [lustre-devel] [PATCH 5/6] staging: lustre: Using macro
	DIV_ROUND_UP
In-Reply-To: <20170221174631.GA22466@singhal-Inspiron-5558>
References: <20170221174631.GA22466@singhal-Inspiron-5558>
Message-ID: <1487709610.2853.39.camel@perches.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: simran singhal <singhalsimran0@gmail.com>, oleg.drokin@intel.com
Cc: andreas.dilger@intel.com, jsimmons@infradead.org, gregkh@linuxfoundation.org, lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, outreachy-kernel@googlegroups.com

On Tue, 2017-02-21 at 23:16 +0530, simran singhal wrote:
> The macro DIV_ROUND_UP performs the computation (((n) + (d) - 1) /(d)).
> It clarifies the divisor calculations. This occurence was detected using
> the coccinelle script:
> 
> @@
> expression e1;
> expression e2;
> @@
> (
> - ((e1) + e2 - 1) / (e2)
> + DIV_ROUND_UP(e1,e2)
> > 
> 
> - ((e1) + (e2 - 1)) / (e2)
> + DIV_ROUND_UP(e1,e2)
> )

Coccinelle scripts are great but please
inspect the results for appropriate style
and simplify the patch where possible.

> diff --git a/drivers/staging/lustre/lustre/ptlrpc/client.c b/drivers/staging/lustre/lustre/ptlrpc/client.c
[]
> @@ -3136,8 +3136,7 @@ void ptlrpc_set_bulk_mbits(struct ptlrpc_request *req)
>  	 * that server can infer the number of bulks that were prepared,
>  	 * see LU-1431
>  	 */
> -	req->rq_mbits += ((bd->bd_iov_count + LNET_MAX_IOV - 1) /
> -			  LNET_MAX_IOV) - 1;
> +	req->rq_mbits += (DIV_ROUND_UP(bd->bd_iov_count, LNET_MAX_IOV)) - 1;

Unnecessary parentheses.

> diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c b/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c
[]
> @@ -272,7 +272,7 @@ static unsigned long enc_pools_shrink_scan(struct shrinker *s,
>  static inline
>  int npages_to_npools(unsigned long npages)
>  {
> -	return (int)((npages + PAGES_PER_POOL - 1) / PAGES_PER_POOL);
> +	return (int)(DIV_ROUND_UP(npages, PAGES_PER_POOL));
>  }

Here too.
