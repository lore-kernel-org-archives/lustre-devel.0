From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Mon, 15 Jan 2018 16:00:28 +0100
Subject: [lustre-devel] [PATCH 1/8] staging: lustre: Enclose complex
 macros in parentheses
In-Reply-To: <1515691022-22729-2-git-send-email-fabian_huegel@web.de>
References: <1515691022-22729-1-git-send-email-fabian_huegel@web.de>
 <1515691022-22729-2-git-send-email-fabian_huegel@web.de>
Message-ID: <20180115150028.GA10946@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Fabian Huegel <fabian_huegel@web.de>
Cc: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Lai Siyao <lai.siyao@intel.com>, "John L . Hammond" <john.hammond@intel.com>, devel@driverdev.osuosl.org, Ben Evans <bevans@cray.com>, NeilBrown <neilb@suse.com>, Christoph Volkert <linux@christoph-volkert.de>, linux-kernel@i4.cs.fau.de, linux-kernel@vger.kernel.org, lustre-devel@lists.lustre.org

On Thu, Jan 11, 2018 at 06:16:55PM +0100, Fabian Huegel wrote:
> Checkpatch wants complex macros to be enclosed in parentheses, so we
> put parentheses around these four macros.
> 
> Signed-off-by: Fabian Huegel <fabian_huegel@web.de>
> Signed-off-by: Christoph Volkert <linux@christoph-volkert.de>
> ---
>  drivers/staging/lustre/lustre/include/obd_class.h | 8 ++++----
>  1 file changed, 4 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lustre/include/obd_class.h b/drivers/staging/lustre/lustre/include/obd_class.h
> index 67c535c..5c8cf30 100644
> --- a/drivers/staging/lustre/lustre/include/obd_class.h
> +++ b/drivers/staging/lustre/lustre/include/obd_class.h
> @@ -294,10 +294,10 @@ struct obdo;
>  
>  void obdo_to_ioobj(const struct obdo *oa, struct obd_ioobj *ioobj);
>  
> -#define OBT(dev)	(dev)->obd_type
> -#define OBP(dev, op)    (dev)->obd_type->typ_dt_ops->op
> -#define MDP(dev, op)    (dev)->obd_type->typ_md_ops->op
> -#define CTXTP(ctxt, op) (ctxt)->loc_logops->lop_##op
> +#define OBT(dev)	((dev)->obd_type)
> +#define OBP(dev, op)    ((dev)->obd_type->typ_dt_ops->op)
> +#define MDP(dev, op)    ((dev)->obd_type->typ_md_ops->op)
> +#define CTXTP(ctxt, op) ((ctxt)->loc_logops->lop_##op)

That really doesn't make any sense, as this can only be a variable in
here, not any "complex expression".  Sometimes checkpatch.pl isn't very
smart.

Also, these macros are horridly named, odds are they are not even
needed...

thanks,

greg k-h
