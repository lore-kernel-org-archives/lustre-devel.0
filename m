From: Dilger, Andreas <andreas.dilger@intel.com>
Date: Tue, 17 Oct 2017 22:58:41 +0000
Subject: [lustre-devel] [PATCH 14/20] staging: lustre: lnet: selftest:
 mark expected switch fall-throughs
In-Reply-To: <498af25d3ec36c899f8b3071ce32c7937a4a038f.1507781178.git.garsilva@embeddedor.com>
References: <cover.1507781178.git.garsilva@embeddedor.com>
 <498af25d3ec36c899f8b3071ce32c7937a4a038f.1507781178.git.garsilva@embeddedor.com>
Message-ID: <E7783A92-0174-47F6-86EC-8FECB8F79AEE@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Cc: "Drokin, Oleg" <oleg.drokin@intel.com>, James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Lustre Development List <lustre-devel@lists.lustre.org>, "devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>, "Shehata, Amir" <amir.shehata@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Oct 12, 2017, at 10:17, Gustavo A. R. Silva <garsilva@embeddedor.com> wrote:
> 
> 
> In preparation to enabling -Wimplicit-fallthrough, mark switch cases
> where we are expecting to fall through.
> 
> Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>

Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>

> ---
> drivers/staging/lustre/lnet/selftest/module.c | 5 ++++-
> 1 file changed, 4 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/staging/lustre/lnet/selftest/module.c b/drivers/staging/lustre/lnet/selftest/module.c
> index b5d556f..fa1bccc 100644
> --- a/drivers/staging/lustre/lnet/selftest/module.c
> +++ b/drivers/staging/lustre/lnet/selftest/module.c
> @@ -57,10 +57,13 @@ lnet_selftest_exit(void)
> 	switch (lst_init_step) {
> 	case LST_INIT_CONSOLE:
> 		lstcon_console_fini();
> +		/* fall through */
> 	case LST_INIT_FW:
> 		sfw_shutdown();
> +		/* fall through */
> 	case LST_INIT_RPC:
> 		srpc_shutdown();
> +		/* fall through */
> 	case LST_INIT_WI_TEST:
> 		for (i = 0;
> 		     i < cfs_cpt_number(lnet_cpt_table()); i++) {
> @@ -72,7 +75,7 @@ lnet_selftest_exit(void)
> 			    sizeof(lst_sched_test[0]) *
> 			    cfs_cpt_number(lnet_cpt_table()));
> 		lst_sched_test = NULL;
> -
> +		/* fall through */
> 	case LST_INIT_WI_SERIAL:
> 		cfs_wi_sched_destroy(lst_sched_serial);
> 		lst_sched_serial = NULL;
> -- 
> 2.7.4
> 

Cheers, Andreas
--
Andreas Dilger
Lustre Principal Architect
Intel Corporation
