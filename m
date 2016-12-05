From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Mon, 5 Dec 2016 23:52:00 +0300
Subject: [lustre-devel] [PATCH] staging: lustre: Fix a spatch warning
 due to an assignment from kernel to user space
In-Reply-To: <20161202173332.5100-1-lambert.quentin@gmail.com>
References: <20161202173332.5100-1-lambert.quentin@gmail.com>
Message-ID: <20161205205200.GB31243@mwanda>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Quentin Lambert <lambert.quentin@gmail.com>
Cc: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org

On Fri, Dec 02, 2016 at 06:33:32PM +0100, Quentin Lambert wrote:
> lnet_ipif_enumerate was assigning a pointer from kernel space to user
> space. This patch uses copy_to_user to properly do that assignment.

Put the exact warning message here.

> 
> Signed-off-by: Quentin Lambert <lambert.quentin@gmail.com>
> ---
>  shouldn't we be using ifc_req instead of ifc_buf?
> 
>  drivers/staging/lustre/lnet/lnet/lib-socket.c |    8 +++++++-
>  1 file changed, 7 insertions(+), 1 deletion(-)
> 
> --- a/drivers/staging/lustre/lnet/lnet/lib-socket.c
> +++ b/drivers/staging/lustre/lnet/lnet/lib-socket.c
> @@ -181,7 +181,13 @@ lnet_ipif_enumerate(char ***namesp)
>  			goto out0;
>  		}
>  
> -		ifc.ifc_buf = (char *)ifr;
> +		rc = copy_to_user(ifc.ifc_buf, (char *)ifr,
> +				  nalloc * sizeof(*ifr));
> +		if (rc) {
> +			rc = -ENOMEM;
> +			goto out1;
> +		}


No idea what's going on here.  The original code is correct.

regards,
dan carpenter
