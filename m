From: Dilger, Andreas <andreas.dilger@intel.com>
Date: Sat, 27 Jan 2018 00:41:35 +0000
Subject: [lustre-devel] [PATCH] staging: lustre: lnet/selftest: fix
 compile error on UP build
In-Reply-To: <87tvvd84yk.fsf@notabene.neil.brown.name>
References: <151564345630.21794.1667069238139184132.stgit@noble>
 <151564360053.21794.4058863911958997341.stgit@noble>
 <87tvvd84yk.fsf@notabene.neil.brown.name>
Message-ID: <37717983-8436-431F-ABCC-365E3425E35C@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: NeilBrown <neilb@suse.com>
Cc: "Drokin, Oleg" <oleg.drokin@intel.com>, James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, lkml <linux-kernel@vger.kernel.org>, lustre <lustre-devel@lists.lustre.org>, "Wu, Fengguang" <fengguang.wu@intel.com>

On Jan 22, 2018, at 23:27, NeilBrown <neilb@suse.com> wrote:
> 
> When compiled without CONFIG_SMP, we get a compile error
> as ->ctb_parts is not defined.
> 
> There is already a function, cfs_cpt_cpumask(), which will get the
> cpumask we need, and which handles the UP case by returning a NULL pointer.
> So use that and handle NULL.
> Also avoid the #ifdef by allocating a cpumask_var and copying
> into it, rather than sharing the mask.
> 
> Reported-by: kbuild test robot <fengguang.wu@intel.com>
> Fixes: 6106c0f82481 ("staging: lustre: lnet: convert selftest to use workqueues")
> Signed-off-by: NeilBrown <neilb@suse.com>

Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>

> ---
> drivers/staging/lustre/lnet/selftest/module.c | 17 ++++++++---------
> 1 file changed, 8 insertions(+), 9 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lnet/selftest/module.c b/drivers/staging/lustre/lnet/selftest/module.c
> index 31a74b48c995..7359aa56d9b3 100644
> --- a/drivers/staging/lustre/lnet/selftest/module.c
> +++ b/drivers/staging/lustre/lnet/selftest/module.c
> @@ -110,7 +110,8 @@ lnet_selftest_init(void)
> 	lst_init_step = LST_INIT_WI_TEST;
> 	for (i = 0; i < nscheds; i++) {
> 		int nthrs = cfs_cpt_weight(lnet_cpt_table(), i);
> -		struct workqueue_attrs attrs;
> +		struct workqueue_attrs attrs = {0};
> +		cpumask_var_t *mask = cfs_cpt_cpumask(lnet_cpt_table(), i);
> 
> 		/* reserve at least one CPU for LND */
> 		nthrs = max(nthrs - 1, 1);
> @@ -121,14 +122,12 @@ lnet_selftest_init(void)
> 			rc = -ENOMEM;
> 			goto error;
> 		}
> -		attrs.nice = 0;
> -		#ifdef CONFIG_CPUMASK_OFFSTACK
> -		attrs.cpumask = lnet_cpt_table()->ctb_parts[i].cpt_cpumask;
> -		#else
> -		cpumask_copy(attrs.cpumask, lnet_cpt_table()->ctb_parts[i].cpt_cpumask);
> -		#endif
> -		attrs.no_numa = false;
> -		apply_workqueue_attrs(lst_test_wq[i], &attrs);
> +
> +		if (mask && alloc_cpumask_var(&attrs.cpumask, GFP_KERNEL)) {
> +			cpumask_copy(attrs.cpumask, *mask);
> +			apply_workqueue_attrs(lst_test_wq[i], &attrs);
> +			free_cpumask_var(attrs.cpumask);
> +		}
> 	}
> 
> 	rc = srpc_startup();
> -- 
> 2.14.0.rc0.dirty
> 

Cheers, Andreas
--
Andreas Dilger
Lustre Principal Architect
Intel Corporation
