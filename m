From: James Simmons <jsimmons@infradead.org>
Date: Tue, 12 Apr 2016 01:05:32 +0100 (BST)
Subject: [lustre-devel] [PATCH] Mark a pointer as an userspace pointer
 using __user macro.
In-Reply-To: <1460292400-2732-1-git-send-email-antoine.blin@lip6.fr>
References: <1460292400-2732-1-git-send-email-antoine.blin@lip6.fr>
Message-ID: <alpine.LFD.2.20.1604120102560.32767@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> This change fixes below sparse error: "error: incompatible types
> in comparison expression (different address spaces)"
> 
> Signed-off-by: Antoine BLIN <antoine.blin@lip6.fr>

Sigh, I thought the worst was behind us for the LNet/libcfs cleanup.
I agree with Greg this is just papering over the problem. Properly
fixing this will require the tools to be fixed as well. I wonder
if ioctls are best way to handle this, perhaps debugfs?

> ---
>  drivers/staging/lustre/lnet/selftest/conrpc.c | 6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
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
>  
> -		next = tmp.next;
> +		if (next == head_up)
> +			return 0;
>  
>  		ent = list_entry(next, lstcon_rpc_ent_t, rpe_link);
>  
> -- 
> 2.7.4
> 
> _______________________________________________
> lustre-devel mailing list
> lustre-devel at lists.lustre.org
> http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
> 
