From: James Simmons <jsimmons@infradead.org>
Date: Mon, 26 Feb 2018 14:48:48 +0000 (GMT)
Subject: [lustre-devel] [PATCH 3/3] staging: lustre: lnet/selftest:
 don't ignore status from lstcon_test_add
In-Reply-To: <151933737388.16436.11922095105762928334.stgit@noble>
References: <151933726925.16436.9827896439357574011.stgit@noble>
 <151933737388.16436.11922095105762928334.stgit@noble>
Message-ID: <alpine.LFD.2.21.1802261448360.13228@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: NeilBrown <neilb@suse.com>
Cc: devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Oleg Drokin <oleg.drokin@intel.com>, Lustre Development List <lustre-devel@lists.lustre.org>


> If lstcon_test_add sets 'ret' (passed by reference) to 1,
> then lst_test_add_ioctl() ignores the return value.
> This isn't justified - the return value must be zero for 'ret'
> to be meaningful.
> 
> Signed-off-by: NeilBrown <neilb@suse.com>

Reviewed-by: James Simmons <jsimmons@infradead.org>

> ---
>  drivers/staging/lustre/lnet/selftest/conctl.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/staging/lustre/lnet/selftest/conctl.c b/drivers/staging/lustre/lnet/selftest/conctl.c
> index 51497cf9a832..a2d8092bdeb7 100644
> --- a/drivers/staging/lustre/lnet/selftest/conctl.c
> +++ b/drivers/staging/lustre/lnet/selftest/conctl.c
> @@ -670,7 +670,7 @@ static int lst_test_add_ioctl(struct lstio_test_args *args)
>  			     args->lstio_tes_param_len,
>  			     &ret, args->lstio_tes_resultp);
>  
> -	if (ret)
> +	if (!rc && ret)
>  		rc = (copy_to_user(args->lstio_tes_retp, &ret,
>  				   sizeof(ret))) ? -EFAULT : 0;
>  out:
> 
> 
> 
