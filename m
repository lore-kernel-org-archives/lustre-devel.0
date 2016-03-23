From: Simmons, James A. <simmonsja@ornl.gov>
Date: Wed, 23 Mar 2016 18:31:49 +0000
Subject: [lustre-devel] [PATCH] Revert "Staging: lustre: o2iblnd: Use
 sizeof type *pointer instead of sizeof type."
In-Reply-To: <20160323134107.GA4356@kroah.com>
References: <1458685264-22755-1-git-send-email-jsimmons@infradead.org>
	<20160323014916.GF3190@kroah.com>	<D317846B.138487%andreas.dilger@intel.com>
	<20160323134107.GA4356@kroah.com>
Message-ID: <bb9ab572a3944b38814b0533323e0299@EXCHCS32.ornl.gov>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: 'Greg Kroah-Hartman' <gregkh@linuxfoundation.org>, "Dilger, Andreas" <andreas.dilger@intel.com>
Cc: "devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>, "Drokin, Oleg" <oleg.drokin@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

>On Wed, Mar 23, 2016 at 05:39:36AM +0000, Dilger, Andreas wrote:
>> On 2016/03/22, 19:49, "lustre-devel on behalf of Greg Kroah-Hartman"
>> <lustre-devel-bounces@lists.lustre.org on behalf of
>> gregkh at linuxfoundation.org> wrote:
>> 
>> >On Tue, Mar 22, 2016 at 06:21:04PM -0400, James Simmons wrote:
>> >> Latest testing fails when using ko2iblnd. It was tracked down
>> >> to commit 4671a026616df26000f7d8ad2f2ea4b6de79263c.
>> >> 
>> >> This reverts commit 4671a026616df26000f7d8ad2f2ea4b6de79263c.
>> >> ---
>> >>  .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c    |    4 ++--
>> >>  1 files changed, 2 insertions(+), 2 deletions(-)
>> >> 
>> >> diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
>> >>b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
>> >> index 89f9390..0d32e65 100644
>> >> --- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
>> >> +++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
>> >> @@ -1968,7 +1968,7 @@ static int kiblnd_net_init_pools(kib_net_t *net,
>> >>__u32 *cpts, int ncpts)
>> >>  	 */
>> >>  
>> >>  	net->ibn_fmr_ps = cfs_percpt_alloc(lnet_cpt_table(),
>> >> -					   sizeof(*net->ibn_fmr_ps));
>> >> +					   sizeof(kib_fmr_poolset_t));
>> >
>> >Ok, why is this revert needed?  Please give me a big huge comment about
>> >why this is not the same size of the variable being assigned to it,
>> >otherwise someone else is going to come along and make the exact same
>> >change again.
>> >
>> >>  	if (!net->ibn_fmr_ps) {
>> >>  		CERROR("Failed to allocate FMR pool array\n");
>> >>  		rc = -ENOMEM;
>> >> @@ -1992,7 +1992,7 @@ static int kiblnd_net_init_pools(kib_net_t *net,
>> >>__u32 *cpts, int ncpts)
>> >>  
>> >>   create_tx_pool:
>> >>  	net->ibn_tx_ps = cfs_percpt_alloc(lnet_cpt_table(),
>> >> -					  sizeof(*net->ibn_tx_ps));
>> >> +					  sizeof(kib_tx_poolset_t));
>> >
>> >Same here, why is this code wrong?
>> 
>> Looks like the declarations are:
>> 
>>         kib_tx_poolset_t	**ibn_tx_ps;	/* tx pool-set */
>> 	kib_fmr_poolset_t	**ibn_fmr_ps;	/* fmr pool-set */
>> 
>> 
>> 
>> so the right code should be:
>> 
>>         sizeof(**net->ibn_tx_ps);
>> 
>> 
>> and the same for sizeof(**net->ibn_fmr_ps)
>
>That's a mess, isn't there some other way to fix this up to be more
>"obvious"?

This must have been encountered in the past. How was it handle in those
other cases?
