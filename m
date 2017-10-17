From: Dilger, Andreas <andreas.dilger@intel.com>
Date: Tue, 17 Oct 2017 22:57:37 +0000
Subject: [lustre-devel] [PATCH 05/20] staging: lustre: lnet: net_fault:
 mark expected switch fall-through
In-Reply-To: <f6688e6db89b8d9004deeeffcb78d0d4f628f73c.1507781178.git.garsilva@embeddedor.com>
References: <cover.1507781178.git.garsilva@embeddedor.com>
 <f6688e6db89b8d9004deeeffcb78d0d4f628f73c.1507781178.git.garsilva@embeddedor.com>
Message-ID: <0EFF5864-9A26-49AA-B527-47BA1EC3C079@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Cc: "Drokin, Oleg" <oleg.drokin@intel.com>, James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Lustre Development List <lustre-devel@lists.lustre.org>, "Shehata, Amir" <amir.shehata@intel.com>, "devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Oct 12, 2017, at 10:16, Gustavo A. R. Silva <garsilva@embeddedor.com> wrote:
> 
> In preparation to enabling -Wimplicit-fallthrough, mark switch cases
> where we are expecting to fall through.
> 
> Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>

This could also just be "continue;", but doesn't appear harmful.

Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>

> ---
> drivers/staging/lustre/lnet/lnet/net_fault.c | 1 +
> 1 file changed, 1 insertion(+)
> 
> diff --git a/drivers/staging/lustre/lnet/lnet/net_fault.c b/drivers/staging/lustre/lnet/lnet/net_fault.c
> index 03f3d18..7391e16 100644
> --- a/drivers/staging/lustre/lnet/lnet/net_fault.c
> +++ b/drivers/staging/lustre/lnet/lnet/net_fault.c
> @@ -629,6 +629,7 @@ delayed_msg_process(struct list_head *msg_list, bool drop)
> 			case LNET_CREDIT_OK:
> 				lnet_ni_recv(ni, msg->msg_private, msg, 0,
> 					     0, msg->msg_len, msg->msg_len);
> +				/* fall through */
> 			case LNET_CREDIT_WAIT:
> 				continue;
> 			default: /* failures */
> -- 
> 2.7.4
> 

Cheers, Andreas
--
Andreas Dilger
Lustre Principal Architect
Intel Corporation
