From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Wed, 17 May 2017 12:34:18 +0300
Subject: [lustre-devel] [PATCH] staging: lustre: lnet: specify address
	space
In-Reply-To: <20170516205610.21324-1-melko@frugalware.org>
References: <20170516205610.21324-1-melko@frugalware.org>
Message-ID: <20170517093418.pv4brp4imlebqt5i@mwanda>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Tue, May 16, 2017 at 10:56:10PM +0200, Paolo Cretaro wrote:
> Fix warning issued by sparse:
> incorrect type in assignment (different address spaces).
> 
> Signed-off-by: Paolo Cretaro <melko@frugalware.org>
> ---
>  drivers/staging/lustre/lnet/lnet/lib-socket.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/staging/lustre/lnet/lnet/lib-socket.c b/drivers/staging/lustre/lnet/lnet/lib-socket.c
> index 9fca8d225ee0..e5e5213b4da0 100644
> --- a/drivers/staging/lustre/lnet/lnet/lib-socket.c
> +++ b/drivers/staging/lustre/lnet/lnet/lib-socket.c
> @@ -181,7 +181,7 @@ lnet_ipif_enumerate(char ***namesp)
>  			goto out0;
>  		}
>  
> -		ifc.ifc_buf = (char *)ifr;
> +		ifc.ifc_buf = (char __user *)ifr;

But it's not a __user pointer so this is wrong.  You have deleted a
valuable warning message which is there to inform us about important
bugs.

regards,
dan carpenter
