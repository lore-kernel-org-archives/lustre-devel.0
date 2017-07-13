From: Oleg Drokin <oleg.drokin@intel.com>
Date: Thu, 13 Jul 2017 00:29:44 -0400
Subject: [lustre-devel] [PATCH] stating: lustre: fix sparse error:
	incompatible types in comparison expression
In-Reply-To: <20170713021017.5368-1-rui.teng@linux.vnet.ibm.com>
References: <20170713021017.5368-1-rui.teng@linux.vnet.ibm.com>
Message-ID: <C93C23FD-C96C-4EF0-A622-AE060EB87203@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Rui Teng <rui.teng@linux.vnet.ibm.com>
Cc: Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org


On Jul 12, 2017, at 10:10 PM, Rui Teng wrote:

> Comparing two user space addresses to avoid sparse error:
> 
> drivers/staging//lustre/lnet/selftest/conrpc.c:490:30: error:
> incompatible types in comparison expression (different address spaces)
> 
> Signed-off-by: Rui Teng <rui.teng@linux.vnet.ibm.com>
> ---
> drivers/staging/lustre/lnet/selftest/conrpc.c | 5 ++---
> 1 file changed, 2 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lnet/selftest/conrpc.c b/drivers/staging/lustre/lnet/selftest/conrpc.c
> index da36c55b86d3..ae7c2772825e 100644
> --- a/drivers/staging/lustre/lnet/selftest/conrpc.c
> +++ b/drivers/staging/lustre/lnet/selftest/conrpc.c
> @@ -487,10 +487,9 @@ lstcon_rpc_trans_interpreter(struct lstcon_rpc_trans *trans,
> 				   sizeof(struct list_head)))
> 			return -EFAULT;
> 
> -		if (tmp.next == head_up)
> -			return 0;
> -
> 		next = tmp.next;

So the assignment is fine, but comparison is not? Strange.

I guess this is fine by me if that makes the warning go away.

Acked-by: Oleg Drokin <oleg.drokin@intel.com>

> +		if (next == head_up)
> +			return 0;
> 
> 		ent = list_entry(next, struct lstcon_rpc_ent, rpe_link);
> 
> -- 
> 2.11.0
