From: Dilger, Andreas <andreas.dilger@intel.com>
Date: Tue, 17 Oct 2017 22:56:21 +0000
Subject: [lustre-devel] [PATCH 02/20] staging: lustre: lnet: socklnd:
 mark expected switch fall-through
In-Reply-To: <ee379f071a9cc01fb06eff3205a9da1087279bf4.1507781178.git.garsilva@embeddedor.com>
References: <cover.1507781178.git.garsilva@embeddedor.com>
 <ee379f071a9cc01fb06eff3205a9da1087279bf4.1507781178.git.garsilva@embeddedor.com>
Message-ID: <236BFBC5-3722-413F-A8F9-1273E2221A24@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Cc: "Drokin, Oleg" <oleg.drokin@intel.com>, James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>, "devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Oct 12, 2017, at 10:16, Gustavo A. R. Silva <garsilva@embeddedor.com> wrote:
> 
> In preparation to enabling -Wimplicit-fallthrough, mark switch cases
> where we are expecting to fall through.
> 
> Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>

This isn't strictly necessary, since LASSERT() never returns, but
not harmful either.

Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>

> ---
> drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c | 2 +-
> 1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
> index d0ee58d..7b014ca 100644
> --- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
> +++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
> @@ -2308,7 +2308,7 @@ ksocknal_base_shutdown(void)
> 	switch (ksocknal_data.ksnd_init) {
> 	default:
> 		LASSERT(0);
> -
> +		/* fall through */
> 	case SOCKNAL_INIT_ALL:
> 	case SOCKNAL_INIT_DATA:
> 		LASSERT(ksocknal_data.ksnd_peers);
> -- 
> 2.7.4
> 

Cheers, Andreas
--
Andreas Dilger
Lustre Principal Architect
Intel Corporation
