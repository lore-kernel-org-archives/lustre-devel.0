From: Dilger, Andreas <andreas.dilger@intel.com>
Date: Wed, 7 Mar 2018 21:24:45 +0000
Subject: [lustre-devel] [PATCH 05/17] staging: lustre: lnet: keep
 ln_nportals consistent
In-Reply-To: <151994708521.7628.13905456558048566520.stgit@noble>
References: <151994679573.7628.1024109499321778846.stgit@noble>
 <151994708521.7628.13905456558048566520.stgit@noble>
Message-ID: <7BA17B93-50EA-41F3-890D-69EA4FE468F5@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: NeilBrown <neilb@suse.com>
Cc: "Drokin, Oleg" <oleg.drokin@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, James Simmons <jsimmons@infradead.org>, Linux
 Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

On Mar 1, 2018, at 16:31, NeilBrown <neilb@suse.com> wrote:
> 
> ln_nportals should be zero when no portals have
> been allocated.  This ensures that memory allocation failure
> is handled correctly elsewhere.
> 
> Signed-off-by: NeilBrown <neilb@suse.com>

Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>

> ---
> drivers/staging/lustre/lnet/lnet/lib-ptl.c |    5 +++--
> 1 file changed, 3 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lnet/lnet/lib-ptl.c b/drivers/staging/lustre/lnet/lnet/lib-ptl.c
> index 471f2f6c86f4..fc47379c5938 100644
> --- a/drivers/staging/lustre/lnet/lnet/lib-ptl.c
> +++ b/drivers/staging/lustre/lnet/lnet/lib-ptl.c
> @@ -841,6 +841,7 @@ lnet_portals_destroy(void)
> 
> 	cfs_array_free(the_lnet.ln_portals);
> 	the_lnet.ln_portals = NULL;
> +	the_lnet.ln_nportals = 0;
> }
> 
> int
> @@ -851,12 +852,12 @@ lnet_portals_create(void)
> 
> 	size = offsetof(struct lnet_portal, ptl_mt_maps[LNET_CPT_NUMBER]);
> 
> -	the_lnet.ln_nportals = MAX_PORTALS;
> -	the_lnet.ln_portals = cfs_array_alloc(the_lnet.ln_nportals, size);
> +	the_lnet.ln_portals = cfs_array_alloc(MAX_PORTALS, size);
> 	if (!the_lnet.ln_portals) {
> 		CERROR("Failed to allocate portals table\n");
> 		return -ENOMEM;
> 	}
> +	the_lnet.ln_nportals = MAX_PORTALS;
> 
> 	for (i = 0; i < the_lnet.ln_nportals; i++) {
> 		if (lnet_ptl_setup(the_lnet.ln_portals[i], i)) {
> 
> 

Cheers, Andreas
--
Andreas Dilger
Lustre Principal Architect
Intel Corporation
