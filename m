From: Greg KH <gregkh@linuxfoundation.org>
Date: Sun, 10 Apr 2016 08:39:59 -0700
Subject: [lustre-devel] [PATCH] Mark a pointer as an userspace pointer
 using __user macro.
In-Reply-To: <1460292400-2732-1-git-send-email-antoine.blin@lip6.fr>
References: <1460292400-2732-1-git-send-email-antoine.blin@lip6.fr>
Message-ID: <20160410153959.GA1564@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Sun, Apr 10, 2016 at 02:46:40PM +0200, Antoine BLIN wrote:
> This change fixes below sparse error: "error: incompatible types
> in comparison expression (different address spaces)"
> 
> Signed-off-by: Antoine BLIN <antoine.blin@lip6.fr>
> ---
>  drivers/staging/lustre/lnet/selftest/conrpc.c | 6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)

Please always cc: the driverdev mailing list for staging patches.

Also use the name of the driver, and the subsystem in the patch, like
the others written for this driver, look at 'git log' for details.

> 
> diff --git a/drivers/staging/lustre/lnet/selftest/conrpc.c b/drivers/staging/lustre/lnet/selftest/conrpc.c
> index 2be9451..1fdabb3 100644
> --- a/drivers/staging/lustre/lnet/selftest/conrpc.c
> +++ b/drivers/staging/lustre/lnet/selftest/conrpc.c
> @@ -490,10 +490,10 @@ lstcon_rpc_trans_interpreter(lstcon_rpc_trans_t *trans,
>  				   sizeof(struct list_head)))
>  			return -EFAULT;
>  
> -		if (tmp.next == head_up)
> -			return 0;
> +		next = (struct list_head __user *)tmp.next;

Kernel structures in userspace?  While that might be the case, this
really should be fixed "properly" and not papered over like this, sorry.

Do you have access to a lustre system to test changes like this?

thanks,

greg k-h
