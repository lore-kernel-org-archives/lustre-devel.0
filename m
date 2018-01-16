From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Tue, 16 Jan 2018 17:53:47 +0100
Subject: [lustre-devel] staging: lustre: lnet: convert selftest to use
 workqueues
In-Reply-To: <8724a144-6e84-7237-3a0a-21812901d88a@canonical.com>
References: <8724a144-6e84-7237-3a0a-21812901d88a@canonical.com>
Message-ID: <20180116165347.GC3682@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Colin Ian King <colin.king@canonical.com>
Cc: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, NeilBrown <neilb@suse.com>, lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org

On Tue, Jan 16, 2018 at 03:59:58PM +0000, Colin Ian King wrote:
> Hi,
> 
> CoverityScan detected a couple of issues, one of which was introduced
> with the following commit:
> 
> commit 6106c0f82481e686b337ee0c403821fb5c3c17ef
> Author: NeilBrown <neilb@suse.com>
> Date:   Thu Jan 11 15:06:40 2018 +1100
> 
> CoverityScan CID#1464078 ("Uninitialized scalar variable")
> 
> I'm not sure what the expected error return for these conditions are, so
> I've not fixed these as I didn't want to hazard a guess.
> 
> static int
> lnet_selftest_init(void)
> {
>         int nscheds;
>         int rc;
> 
> // note here rc is not initialized
> 
>         int i;
> 
>         lst_serial_wq = alloc_ordered_workqueue("lst_s", 0);
>         if (!lst_serial_wq) {
>                 CERROR("Failed to create serial WI scheduler for LST\n");
>                 return rc;
> 
> // garbage value in rc is returned
> 
>         }
>         lst_init_step = LST_INIT_WI_SERIAL;
> 
>         nscheds = cfs_cpt_number(lnet_cpt_table());
>         lst_test_wq = kvmalloc_array(nscheds, sizeof(lst_test_wq[0]),
>                                         GFP_KERNEL | __GFP_ZERO);
>         if (!lst_test_wq)
>                 goto error;
> 
> // this also returns garbage in rc

Already fixed in my tree by a patch from Arnd and me :)

thanks,

greg k-h
