From: Oleg Drokin <oleg.drokin@intel.com>
Date: Mon, 5 Dec 2016 17:58:06 -0500
Subject: [lustre-devel] [PATCH] staging: lustre: Fix a spatch warning
	due to an assignment from kernel to user space
In-Reply-To: <20161202173332.5100-1-lambert.quentin@gmail.com>
References: <20161202173332.5100-1-lambert.quentin@gmail.com>
Message-ID: <306D1D4D-A949-44F6-BAFE-44F08F609D9B@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Quentin Lambert <lambert.quentin@gmail.com>
Cc: Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org


On Dec 2, 2016, at 12:33 PM, Quentin Lambert wrote:

> lnet_ipif_enumerate was assigning a pointer from kernel space to user
> space. This patch uses copy_to_user to properly do that assignment.

I guess it's a false positive?

While lnet_sock_ioctl()->kernel_sock_unlocked_ioctl() does call into the
f_op->unlocked_ioctl() with a userspace argument, note that we have
set_fs(KERNEL_DS); in there, therefore allowig copy_from_user
and friends to work on kernel data too as if it was userspace.
(I know it's ugly and we need to find a better way of getting this data,
but at least it's not incorrect).

> 
> Signed-off-by: Quentin Lambert <lambert.quentin@gmail.com>
> ---
> shouldn't we be using ifc_req instead of ifc_buf?
> 
> drivers/staging/lustre/lnet/lnet/lib-socket.c |    8 +++++++-
> 1 file changed, 7 insertions(+), 1 deletion(-)
> 
> --- a/drivers/staging/lustre/lnet/lnet/lib-socket.c
> +++ b/drivers/staging/lustre/lnet/lnet/lib-socket.c
> @@ -181,7 +181,13 @@ lnet_ipif_enumerate(char ***namesp)
> 			goto out0;
> 		}
> 
> -		ifc.ifc_buf = (char *)ifr;
> +		rc = copy_to_user(ifc.ifc_buf, (char *)ifr,
> +				  nalloc * sizeof(*ifr));
> +		if (rc) {
> +			rc = -ENOMEM;
> +			goto out1;
> +		}
> +
> 		ifc.ifc_len = nalloc * sizeof(*ifr);
> 
> 		rc = lnet_sock_ioctl(SIOCGIFCONF, (unsigned long)&ifc);
> _______________________________________________
> lustre-devel mailing list
> lustre-devel at lists.lustre.org
> http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
