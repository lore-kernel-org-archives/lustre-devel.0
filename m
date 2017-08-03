From: James Simmons <jsimmons@infradead.org>
Date: Thu, 3 Aug 2017 18:27:29 +0100 (BST)
Subject: [lustre-devel] [PATCH] staging: lustre: declare
	fiemap_for_stripe static
In-Reply-To: <1501647591-22277-1-git-send-email-dwittman@gmail.com>
References: <1501647591-22277-1-git-send-email-dwittman@gmail.com>
Message-ID: <alpine.LFD.2.20.1708031827000.21881@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Wittman <dwittman@gmail.com>
Cc: oleg.drokin@intel.com, andreas.dilger@intel.com, jinshan.xiong@intel.com, bobijam.xu@intel.com, gregkh@linuxfoundation.org, john.hammond@intel.com, di.wang@intel.com, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, lustre-devel@lists.lustre.org


> Declare fiemap_for_stripe as static to fix sparse warnings:
> 
> > warning: symbol 'fiemap_for_stripe' was not declared. Should it be
> > static?

Acked-by: James Simmons <jsimmons@infradead.org>
 
> Signed-off-by: David Wittman <dwittman@gmail.com>
> ---
>  drivers/staging/lustre/lustre/lov/lov_object.c | 10 +++++-----
>  1 file changed, 5 insertions(+), 5 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lustre/lov/lov_object.c b/drivers/staging/lustre/lustre/lov/lov_object.c
> index 8fc0bcc..334ecb1 100644
> --- a/drivers/staging/lustre/lustre/lov/lov_object.c
> +++ b/drivers/staging/lustre/lustre/lov/lov_object.c
> @@ -1141,11 +1141,11 @@ struct fiemap_state {
>  	bool		fs_enough;
>  };
>  
> -int fiemap_for_stripe(const struct lu_env *env, struct cl_object *obj,
> -		      struct lov_stripe_md *lsm,
> -		      struct fiemap *fiemap, size_t *buflen,
> -		      struct ll_fiemap_info_key *fmkey, int stripeno,
> -		      struct fiemap_state *fs)
> +static int fiemap_for_stripe(const struct lu_env *env, struct cl_object *obj,
> +			     struct lov_stripe_md *lsm,
> +			     struct fiemap *fiemap, size_t *buflen,
> +			     struct ll_fiemap_info_key *fmkey, int stripeno,
> +			     struct fiemap_state *fs)
>  {
>  	struct cl_object *subobj;
>  	struct lov_obd *lov = lu2lov_dev(obj->co_lu.lo_dev)->ld_lov;
> -- 
> 2.7.4
> 
> _______________________________________________
> devel mailing list
> devel at linuxdriverproject.org
> http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel
> 
