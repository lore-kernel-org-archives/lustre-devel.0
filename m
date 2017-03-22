From: Dilger, Andreas <andreas.dilger@intel.com>
Date: Wed, 22 Mar 2017 12:12:11 +0000
Subject: [lustre-devel] [PATCH] staging: lustre: Replace a bit shift by
	a use of BIT.
In-Reply-To: <20170322023933.GA11339@arushi-HP-Pavilion-Notebook>
References: <20170322023933.GA11339@arushi-HP-Pavilion-Notebook>
Message-ID: <FE801B69-BCDE-4A58-B61D-B33E46826D5F@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arushi Singhal <arushisinghal19971997@gmail.com>
Cc: "Drokin, Oleg" <oleg.drokin@intel.com>, James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>, "devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "outreachy-kernel@googlegroups.com" <outreachy-kernel@googlegroups.com>

On Mar 21, 2017, at 22:39, Arushi Singhal <arushisinghal19971997@gmail.com> wrote:
> 
> This patch replaces bit shifting on 1 with the BIT(x) macro.
> This was done with coccinelle:
> @@
> constant c;
> @@
> 
> -1 << c
> +BIT(c)

Did you take the time to look at what this Coccinelle script actually did, to see
if it actually makes sense?  Some of the cases where this replacement was done
makes sense because a specific bit is being accessed (i.e. a bitmask).  Elsewhere,
it doesn't make sense to use BIT() to specify numeric values (e.g. PAGE_SHIFT,
1 << 12 = 1024, etc) since they are not bitmasks.

> Signed-off-by: Arushi Singhal <arushisinghal19971997@gmail.com>
> ---
> drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c           | 2 +-
> drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c        | 8 ++++----
> drivers/staging/lustre/lnet/klnds/socklnd/socklnd_modparams.c | 2 +-
> drivers/staging/lustre/lnet/lnet/lib-ptl.c                    | 4 ++--
> drivers/staging/lustre/lnet/lnet/net_fault.c                  | 8 ++++----
> drivers/staging/lustre/lustre/llite/lproc_llite.c             | 4 ++--
> drivers/staging/lustre/lustre/obdclass/lustre_handles.c       | 2 +-
> drivers/staging/lustre/lustre/osc/osc_request.c               | 2 +-
> 8 files changed, 16 insertions(+), 16 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
> index 79321e4aaf30..449f04f125b7 100644
> --- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
> +++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
> @@ -2241,7 +2241,7 @@ static int kiblnd_hdev_get_attr(struct kib_hca_dev *hdev)
> 	 * matching that of the native system
> 	 */
> 	hdev->ibh_page_shift = PAGE_SHIFT;
> -	hdev->ibh_page_size  = 1 << PAGE_SHIFT;
> +	hdev->ibh_page_size  = BIT(PAGE_SHIFT);

This should just be replaced with "PAGE_SIZE".

> 	hdev->ibh_page_mask  = ~((__u64)hdev->ibh_page_size - 1);
> 
> 	hdev->ibh_mr_size = hdev->ibh_ibdev->attrs.max_mr_size;
> diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
> index eaa4399e6a2e..5bef8a7e053b 100644
> --- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
> +++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
> @@ -1906,14 +1906,14 @@ ksocknal_connect(struct ksock_route *route)
> 		if (retry_later) /* needs reschedule */
> 			break;
> 
> -		if (wanted & (1 << SOCKLND_CONN_ANY)) {
> +		if (wanted & (BIT(SOCKLND_CONN_ANY))) {

There shouldn't be any need to put parenthesis around (BIT(x)) here, or
any of the cases below, or the BIT macro is broken.  But besides that, the
use of BIT() here looks OK.

> 			type = SOCKLND_CONN_ANY;
> -		} else if (wanted & (1 << SOCKLND_CONN_CONTROL)) {
> +		} else if (wanted & (BIT(SOCKLND_CONN_CONTROL))) {
> 			type = SOCKLND_CONN_CONTROL;
> -		} else if (wanted & (1 << SOCKLND_CONN_BULK_IN)) {
> +		} else if (wanted & (BIT(SOCKLND_CONN_BULK_IN))) {
> 			type = SOCKLND_CONN_BULK_IN;
> 		} else {
> -			LASSERT(wanted & (1 << SOCKLND_CONN_BULK_OUT));
> +			LASSERT(wanted & (BIT(SOCKLND_CONN_BULK_OUT)));
> 			type = SOCKLND_CONN_BULK_OUT;
> 		}
> 
> diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_modparams.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_modparams.c
> index fc7eec83ac07..2d1e3479cf7e 100644
> --- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_modparams.c
> +++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_modparams.c
> @@ -71,7 +71,7 @@ static int typed_conns = 1;
> module_param(typed_conns, int, 0444);
> MODULE_PARM_DESC(typed_conns, "use different sockets for bulk");
> 
> -static int min_bulk = 1 << 10;
> +static int min_bulk = BIT(10);

This is a scalar value and not a bitmask.  It could just be "1024", but using
BIT() is not correct.

> module_param(min_bulk, int, 0644);
> MODULE_PARM_DESC(min_bulk, "smallest 'large' message");
> 
> diff --git a/drivers/staging/lustre/lnet/lnet/lib-ptl.c b/drivers/staging/lustre/lnet/lnet/lib-ptl.c
> index 63cce0c4a065..b980c669705e 100644
> --- a/drivers/staging/lustre/lnet/lnet/lib-ptl.c
> +++ b/drivers/staging/lustre/lnet/lnet/lib-ptl.c
> @@ -332,7 +332,7 @@ lnet_mt_test_exhausted(struct lnet_match_table *mtable, int pos)
> 	LASSERT(pos <= LNET_MT_HASH_IGNORE);
> 	/* mtable::mt_mhash[pos] is marked as exhausted or not */
> 	bmap = &mtable->mt_exhausted[pos >> LNET_MT_BITS_U64];
> -	pos &= (1 << LNET_MT_BITS_U64) - 1;
> +	pos &= (BIT(LNET_MT_BITS_U64)) - 1;

The use of BIT() above is probably not correct.  This is creating a mask to align
pos to a multiple of (1 << LNET_MT_BITS_U64), and IMHO BIT() shouldn't be used
just any time a value is being shifted but rather only when a one-bit mask is needed.

Conversely, the below usage could be converted to use the macro since this is
actually a bitmask:

       return *bmap & BIT(pos);

> 	return (*bmap & (1ULL << pos));
> }
> @@ -347,7 +347,7 @@ lnet_mt_set_exhausted(struct lnet_match_table *mtable, int pos, int exhausted)
> 
> 	/* set mtable::mt_mhash[pos] as exhausted/non-exhausted */
> 	bmap = &mtable->mt_exhausted[pos >> LNET_MT_BITS_U64];
> -	pos &= (1 << LNET_MT_BITS_U64) - 1;
> +	pos &= (BIT(LNET_MT_BITS_U64)) - 1;
> 
> 	if (!exhausted)
> 		*bmap &= ~(1ULL << pos);

Ditto.

> diff --git a/drivers/staging/lustre/lnet/lnet/net_fault.c b/drivers/staging/lustre/lnet/lnet/net_fault.c
> index 18183cbb9859..e83761a77d22 100644
> --- a/drivers/staging/lustre/lnet/lnet/net_fault.c
> +++ b/drivers/staging/lustre/lnet/lnet/net_fault.c
> @@ -997,10 +997,10 @@ lnet_fault_ctl(int opc, struct libcfs_ioctl_data *data)
> int
> lnet_fault_init(void)
> {
> -	BUILD_BUG_ON(LNET_PUT_BIT != 1 << LNET_MSG_PUT);
> -	BUILD_BUG_ON(LNET_ACK_BIT != 1 << LNET_MSG_ACK);
> -	BUILD_BUG_ON(LNET_GET_BIT != 1 << LNET_MSG_GET);
> -	BUILD_BUG_ON(LNET_REPLY_BIT != 1 << LNET_MSG_REPLY);
> +	BUILD_BUG_ON(LNET_PUT_BIT != BIT(LNET_MSG_PUT));
> +	BUILD_BUG_ON(LNET_ACK_BIT != BIT(LNET_MSG_ACK));
> +	BUILD_BUG_ON(LNET_GET_BIT != BIT(LNET_MSG_GET));
> +	BUILD_BUG_ON(LNET_REPLY_BIT != BIT(LNET_MSG_REPLY));

This looks reasonable at first glance, though on further thought it seems kind of
pointless since this is really:

#defined LET_PUT_BIT BIT(LNET_MSG_PUT)

       BUILD_BUG_ON(BIT(LNET_MSG_PUT) != BIT(LNET_MSG_PUT))

so it is just checking that the macro's value is the same when called two times.
I'd suggest just getting rid of these BUILD_BUG_ON() checks completely 

> diff --git a/drivers/staging/lustre/lustre/llite/lproc_llite.c b/drivers/staging/lustre/lustre/llite/lproc_llite.c
> index 40f1fcf8b5c0..366833dd8aa3 100644
> --- a/drivers/staging/lustre/lustre/llite/lproc_llite.c
> +++ b/drivers/staging/lustre/lustre/llite/lproc_llite.c
> @@ -1308,7 +1308,7 @@ static void ll_display_extents_info(struct ll_rw_extents_info *io_extents,
> 			   r, pct(r, read_tot), pct(read_cum, read_tot),
> 			   w, pct(w, write_tot), pct(write_cum, write_tot));
> 		start = end;
> -		if (start == 1 << 10) {
> +		if (start == BIT(10)) {

This should just be 1024, or could be left as-is left as-is.

> 			start = 1;
> 			units += 10;
> 			unitp++;
> @@ -1506,7 +1506,7 @@ void ll_rw_stats_tally(struct ll_sb_info *sbi, pid_t pid,
> 		lprocfs_oh_clear(&io_extents->pp_extents[cur].pp_w_hist);
> 	}
> 
> -	for (i = 0; (count >= (1 << LL_HIST_START << i)) &&
> +	for (i = 0; (count >= (BIT(LL_HIST_START) << i)) &&

This is also not a bitmask, but rather a scalar value.

> 	     (i < (LL_HIST_MAX - 1)); i++)
> 		;
> 	if (rw == 0) {
> diff --git a/drivers/staging/lustre/lustre/obdclass/lustre_handles.c b/drivers/staging/lustre/lustre/obdclass/lustre_handles.c
> index c9445e5ec271..11e32b5174f2 100644
> --- a/drivers/staging/lustre/lustre/obdclass/lustre_handles.c
> +++ b/drivers/staging/lustre/lustre/obdclass/lustre_handles.c
> @@ -49,7 +49,7 @@ static struct handle_bucket {
> 	struct list_head	head;
> } *handle_hash;
> 
> -#define HANDLE_HASH_SIZE (1 << 16)
> +#define HANDLE_HASH_SIZE (BIT(16))

Also not a bitmask, but a scalar value.

> #define HANDLE_HASH_MASK (HANDLE_HASH_SIZE - 1)
> 
> /*
> diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
> index d8aa3fb468c7..8739abf639a7 100644
> --- a/drivers/staging/lustre/lustre/osc/osc_request.c
> +++ b/drivers/staging/lustre/lustre/osc/osc_request.c
> @@ -2847,7 +2847,7 @@ static int __init osc_init(void)
> 	register_shrinker(&osc_cache_shrinker);
> 
> 	/* This is obviously too much memory, only prevent overflow here */
> -	if (osc_reqpool_mem_max >= 1 << 12 || osc_reqpool_mem_max == 0) {
> +	if (osc_reqpool_mem_max >= BIT(12) || osc_reqpool_mem_max == 0) {

Also a scalar value.  Could be 4096.


Cheers, Andreas
