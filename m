From: Dilger, Andreas <andreas.dilger@intel.com>
Date: Fri, 25 Nov 2016 23:16:48 +0000
Subject: [lustre-devel] [patch] staging: lustre/ptlrpc: small leak
	on	allocation failure
In-Reply-To: <20161124111204.GH17225@mwanda>
References: <20161124111204.GH17225@mwanda>
Message-ID: <F7C31145-1846-4DD3-8140-79E3D8249545@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Dan Carpenter <dan.carpenter@oracle.com>
Cc: "Drokin, Oleg" <oleg.drokin@intel.com>, "devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>, Sebastien Buisson <sebastien.buisson@bull.net>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Vitaly Fertman <vitaly_fertman@xyratex.com>, frank zago <fzago@cray.com>, "Shehata, Amir" <amir.shehata@intel.com>, "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>

On Nov 24, 2016, at 04:12, Dan Carpenter <dan.carpenter@oracle.com> wrote:
> 
> We should free "desc" before returning NULL.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>

> diff --git a/drivers/staging/lustre/lustre/ptlrpc/client.c b/drivers/staging/lustre/lustre/ptlrpc/client.c
> index ac959ef..8047413 100644
> --- a/drivers/staging/lustre/lustre/ptlrpc/client.c
> +++ b/drivers/staging/lustre/lustre/ptlrpc/client.c
> @@ -128,12 +128,12 @@ struct ptlrpc_bulk_desc *ptlrpc_new_bulk(unsigned int nfrags,
> 		GET_KIOV(desc) = kcalloc(nfrags, sizeof(*GET_KIOV(desc)),
> 					 GFP_NOFS);
> 		if (!GET_KIOV(desc))
> -			goto out;
> +			goto free_desc;
> 	} else {
> 		GET_KVEC(desc) = kcalloc(nfrags, sizeof(*GET_KVEC(desc)),
> 					 GFP_NOFS);
> 		if (!GET_KVEC(desc))
> -			goto out;
> +			goto free_desc;
> 	}
> 
> 	spin_lock_init(&desc->bd_lock);
> @@ -154,7 +154,8 @@ struct ptlrpc_bulk_desc *ptlrpc_new_bulk(unsigned int nfrags,
> 		LNetInvalidateHandle(&desc->bd_mds[i]);
> 
> 	return desc;
> -out:
> +free_desc:
> +	kfree(desc);
> 	return NULL;
> }
> 
> _______________________________________________
> lustre-devel mailing list
> lustre-devel at lists.lustre.org
> http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
