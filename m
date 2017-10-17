From: Dilger, Andreas <andreas.dilger@intel.com>
Date: Tue, 17 Oct 2017 23:03:36 +0000
Subject: [lustre-devel] [PATCH 18/20] staging: lustre: osc: mark
 expected switch fall-through
In-Reply-To: <ed0b43170d08cda14de2b6a8069e77054b03fae0.1507781178.git.garsilva@embeddedor.com>
References: <cover.1507781178.git.garsilva@embeddedor.com>
 <ed0b43170d08cda14de2b6a8069e77054b03fae0.1507781178.git.garsilva@embeddedor.com>
Message-ID: <274B25B3-8F82-4DDA-87F9-419C7F3BC510@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Cc: "Drokin, Oleg" <oleg.drokin@intel.com>, James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Lustre Development List <lustre-devel@lists.lustre.org>, "devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Oct 12, 2017, at 10:17, Gustavo A. R. Silva <garsilva@embeddedor.com> wrote:
> 
> In preparation to enabling -Wimplicit-fallthrough, mark switch cases
> where we are expecting to fall through.
> 
> Addresses-Coverity-ID: 1077598
> Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>

Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>

> ---
> drivers/staging/lustre/lustre/osc/osc_cache.c | 1 +
> 1 file changed, 1 insertion(+)
> 
> diff --git a/drivers/staging/lustre/lustre/osc/osc_cache.c b/drivers/staging/lustre/lustre/osc/osc_cache.c
> index e1207c2..eab7759 100644
> --- a/drivers/staging/lustre/lustre/osc/osc_cache.c
> +++ b/drivers/staging/lustre/lustre/osc/osc_cache.c
> @@ -227,6 +227,7 @@ static int osc_extent_sanity_check0(struct osc_extent *ext,
> 			rc = 65;
> 			goto out;
> 		}
> +		/* fall through */
> 	default:
> 		if (atomic_read(&ext->oe_users) > 0) {
> 			rc = 70;
> -- 
> 2.7.4
> 

Cheers, Andreas
--
Andreas Dilger
Lustre Principal Architect
Intel Corporation
