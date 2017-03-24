From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Fri, 24 Mar 2017 14:44:59 +0100
Subject: [lustre-devel] [PATCH] staging: lustre: Remove redundant code
In-Reply-To: <20170324113952.GA31427@arushi-HP-Pavilion-Notebook>
References: <20170324113952.GA31427@arushi-HP-Pavilion-Notebook>
Message-ID: <20170324134459.GA26275@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arushi Singhal <arushisinghal19971997@gmail.com>
Cc: oleg.drokin@intel.com, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, outreachy-kernel@googlegroups.com

On Fri, Mar 24, 2017 at 05:09:53PM +0530, Arushi Singhal wrote:
> Remove the code which do not have any value.
> 
> Signed-off-by: Arushi Singhal <arushisinghal19971997@gmail.com>
> ---
>  drivers/staging/lustre/lnet/lnet/net_fault.c | 5 -----
>  1 file changed, 5 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lnet/lnet/net_fault.c b/drivers/staging/lustre/lnet/lnet/net_fault.c
> index 18183cbb9859..b60261db9e67 100644
> --- a/drivers/staging/lustre/lnet/lnet/net_fault.c
> +++ b/drivers/staging/lustre/lnet/lnet/net_fault.c
> @@ -997,11 +997,6 @@ lnet_fault_ctl(int opc, struct libcfs_ioctl_data *data)
>  int
>  lnet_fault_init(void)
>  {
> -	BUILD_BUG_ON(LNET_PUT_BIT != 1 << LNET_MSG_PUT);
> -	BUILD_BUG_ON(LNET_ACK_BIT != 1 << LNET_MSG_ACK);
> -	BUILD_BUG_ON(LNET_GET_BIT != 1 << LNET_MSG_GET);
> -	BUILD_BUG_ON(LNET_REPLY_BIT != 1 << LNET_MSG_REPLY);

Why does this not have any value?  How are you ensuring that these
requirements are now being met?

thanks,

greg k-h
