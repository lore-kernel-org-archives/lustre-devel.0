From: Dilger, Andreas <andreas.dilger@intel.com>
Date: Tue, 17 Oct 2017 23:04:00 +0000
Subject: [lustre-devel] [PATCH 19/20] staging: lustre: ptlrpc: mark
 expected switch fall-throughs
In-Reply-To: <afa1f786515ab143ba5710a6df3797286269bbe2.1507781178.git.garsilva@embeddedor.com>
References: <cover.1507781178.git.garsilva@embeddedor.com>
 <afa1f786515ab143ba5710a6df3797286269bbe2.1507781178.git.garsilva@embeddedor.com>
Message-ID: <D8E42C0A-24EF-4312-9C0E-0D90BF296193@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Cc: "Drokin, Oleg" <oleg.drokin@intel.com>, James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>, "devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Oct 12, 2017, at 10:17, Gustavo A. R. Silva <garsilva@embeddedor.com> wrote:
> 
> In preparation to enabling -Wimplicit-fallthrough, mark switch cases
> where we are expecting to fall through.
> 
> Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>

Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>

> ---
> drivers/staging/lustre/lustre/ptlrpc/pack_generic.c | 6 +++---
> 1 file changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c b/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
> index aad4ff1..a3664c1 100644
> --- a/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
> +++ b/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
> @@ -786,7 +786,7 @@ __u32 lustre_msg_get_flags(struct lustre_msg *msg)
> 
> 		CERROR("invalid msg %p: no ptlrpc body!\n", msg);
> 	}
> -	/* no break */
> +	/* fall through */
> 	default:
> 		/* flags might be printed in debug code while message
> 		 * uninitialized
> @@ -854,7 +854,7 @@ __u32 lustre_msg_get_op_flags(struct lustre_msg *msg)
> 
> 		CERROR("invalid msg %p: no ptlrpc body!\n", msg);
> 	}
> -	/* no break */
> +	/* fall through */
> 	default:
> 		return 0;
> 	}
> @@ -1035,7 +1035,7 @@ int lustre_msg_get_status(struct lustre_msg *msg)
> 
> 		CERROR("invalid msg %p: no ptlrpc body!\n", msg);
> 	}
> -	/* no break */
> +	/* fall through */
> 	default:
> 		/* status might be printed in debug code while message
> 		 * uninitialized
> -- 
> 2.7.4
> 

Cheers, Andreas
--
Andreas Dilger
Lustre Principal Architect
Intel Corporation
