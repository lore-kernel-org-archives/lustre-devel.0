From: Dilger, Andreas <andreas.dilger@intel.com>
Date: Tue, 17 Oct 2017 23:05:39 +0000
Subject: [lustre-devel] [PATCH 12/20] staging: lustre: lnet: selftest:
 mark expected switch fall-through
In-Reply-To: <4633f85babbbeb119e318a9c319c8a49d68f6f13.1507781178.git.garsilva@embeddedor.com>
References: <cover.1507781178.git.garsilva@embeddedor.com>
 <4633f85babbbeb119e318a9c319c8a49d68f6f13.1507781178.git.garsilva@embeddedor.com>
Message-ID: <E52CD66A-26AC-42A3-BBF3-E87AD207F544@intel.com>
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
> drivers/staging/lustre/lnet/selftest/conctl.c | 1 +
> 1 file changed, 1 insertion(+)
> 
> diff --git a/drivers/staging/lustre/lnet/selftest/conctl.c b/drivers/staging/lustre/lnet/selftest/conctl.c
> index 9619ecb..551e921 100644
> --- a/drivers/staging/lustre/lnet/selftest/conctl.c
> +++ b/drivers/staging/lustre/lnet/selftest/conctl.c
> @@ -151,6 +151,7 @@ lst_debug_ioctl(struct lstio_debug_args *args)
> 
> 	case LST_OPC_BATCHSRV:
> 		client = 0;
> +		/* fall through */
> 	case LST_OPC_BATCHCLI:
> 		if (!name)
> 			goto out;
> -- 
> 2.7.4
> 

Cheers, Andreas
--
Andreas Dilger
Lustre Principal Architect
Intel Corporation
