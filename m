From: Dilger, Andreas <andreas.dilger@intel.com>
Date: Thu, 23 Mar 2017 20:41:47 +0000
Subject: [lustre-devel] [PATCH v2] staging: lustre: Replace a bit shift
	by a use of BIT.
In-Reply-To: <20170322155333.GA17411@arushi-HP-Pavilion-Notebook>
References: <20170322155333.GA17411@arushi-HP-Pavilion-Notebook>
Message-ID: <1BE44C84-0DDB-4D9E-B4CB-C8A979F48EC6@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arushi Singhal <arushisinghal19971997@gmail.com>
Cc: "Drokin, Oleg" <oleg.drokin@intel.com>, James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, lustre-devel <lustre-devel@lists.lustre.org>, "devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "outreachy-kernel@googlegroups.com" <outreachy-kernel@googlegroups.com>

On Mar 22, 2017, at 09:53, Arushi Singhal <arushisinghal19971997@gmail.com> wrote:
> 
> This patch replaces bit shifting on 1 with the BIT(x) macro.
> This was done with coccinelle:
> @@
> constant c;
> @@
> 
> -1 << c
> +BIT(c)
> 
> Signed-off-by: Arushi Singhal <arushisinghal19971997@gmail.com>

Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>

> ---
> changes in v2
> - remove the unnecessary parenthesis.
> - removethe wrong changes.
> 
> drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c | 8 ++++----
> drivers/staging/lustre/lnet/lnet/lib-ptl.c             | 2 +-
> drivers/staging/lustre/lustre/llite/lproc_llite.c      | 2 +-
> 3 files changed, 6 insertions(+), 6 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
> index eaa4399e6a2e..2b93ceaa2844 100644
> --- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
> +++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
> @@ -1906,14 +1906,14 @@ ksocknal_connect(struct ksock_route *route)
> 		if (retry_later) /* needs reschedule */
> 			break;
> 
> -		if (wanted & (1 << SOCKLND_CONN_ANY)) {
> +		if (wanted & BIT(SOCKLND_CONN_ANY)) {
> 			type = SOCKLND_CONN_ANY;
> -		} else if (wanted & (1 << SOCKLND_CONN_CONTROL)) {
> +		} else if (wanted & BIT(SOCKLND_CONN_CONTROL)) {
> 			type = SOCKLND_CONN_CONTROL;
> -		} else if (wanted & (1 << SOCKLND_CONN_BULK_IN)) {
> +		} else if (wanted & BIT(SOCKLND_CONN_BULK_IN)) {
> 			type = SOCKLND_CONN_BULK_IN;
> 		} else {
> -			LASSERT(wanted & (1 << SOCKLND_CONN_BULK_OUT));
> +			LASSERT(wanted & BIT(SOCKLND_CONN_BULK_OUT));
> 			type = SOCKLND_CONN_BULK_OUT;
> 		}
> 
> diff --git a/drivers/staging/lustre/lnet/lnet/lib-ptl.c b/drivers/staging/lustre/lnet/lnet/lib-ptl.c
> index 63cce0c4a065..33332724ab94 100644
> --- a/drivers/staging/lustre/lnet/lnet/lib-ptl.c
> +++ b/drivers/staging/lustre/lnet/lnet/lib-ptl.c
> @@ -334,7 +334,7 @@ lnet_mt_test_exhausted(struct lnet_match_table *mtable, int pos)
> 	bmap = &mtable->mt_exhausted[pos >> LNET_MT_BITS_U64];
> 	pos &= (1 << LNET_MT_BITS_U64) - 1;
> 
> -	return (*bmap & (1ULL << pos));
> +	return (*bmap & BIT(pos));
> }
> 
> static void
> diff --git a/drivers/staging/lustre/lustre/llite/lproc_llite.c b/drivers/staging/lustre/lustre/llite/lproc_llite.c
> index 40f1fcf8b5c0..c742cba60199 100644
> --- a/drivers/staging/lustre/lustre/llite/lproc_llite.c
> +++ b/drivers/staging/lustre/lustre/llite/lproc_llite.c
> @@ -1308,7 +1308,7 @@ static void ll_display_extents_info(struct ll_rw_extents_info *io_extents,
> 			   r, pct(r, read_tot), pct(read_cum, read_tot),
> 			   w, pct(w, write_tot), pct(write_cum, write_tot));
> 		start = end;
> -		if (start == 1 << 10) {
> +		if (start == 1024) {
> 			start = 1;
> 			units += 10;
> 			unitp++;
> -- 
> 2.11.0
> 

Cheers, Andreas
--
Andreas Dilger
Lustre Principal Architect
Intel Corporation
