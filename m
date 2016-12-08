From: James Simmons <jsimmons@infradead.org>
Date: Thu, 8 Dec 2016 00:23:57 +0000 (GMT)
Subject: [lustre-devel] [PATCH 4/8] staging/lustre/lov: make
	lov_lsm_alloc() static
In-Reply-To: <1481150494-1853127-5-git-send-email-green@linuxhacker.ru>
References: <1481150494-1853127-1-git-send-email-green@linuxhacker.ru>
	<1481150494-1853127-5-git-send-email-green@linuxhacker.ru>
Message-ID: <alpine.LFD.2.20.1612080023470.14850@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <green@linuxhacker.ru>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>


> It's not used anywhere outside of this file.
> Highlighted by sparse.

Reviewed-by: James Simmons <jsimmons@infradead.org>
 
> Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
> ---
>  drivers/staging/lustre/lustre/lov/lov_pack.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/staging/lustre/lustre/lov/lov_pack.c b/drivers/staging/lustre/lustre/lov/lov_pack.c
> index 6c93d18..68fa2de 100644
> --- a/drivers/staging/lustre/lustre/lov/lov_pack.c
> +++ b/drivers/staging/lustre/lustre/lov/lov_pack.c
> @@ -198,7 +198,8 @@ static int lov_verify_lmm(void *lmm, int lmm_bytes, __u16 *stripe_count)
>  	return rc;
>  }
>  
> -struct lov_stripe_md *lov_lsm_alloc(u16 stripe_count, u32 pattern, u32 magic)
> +static struct lov_stripe_md *lov_lsm_alloc(u16 stripe_count, u32 pattern,
> +					   u32 magic)
>  {
>  	struct lov_stripe_md *lsm;
>  	unsigned int i;
> -- 
> 2.7.4
> 
> 
