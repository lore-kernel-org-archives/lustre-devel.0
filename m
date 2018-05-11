From: NeilBrown <neilb@suse.com>
Date: Fri, 11 May 2018 10:43:23 +1000
Subject: [lustre-devel] [PATCH] staging: lustre: lnet: add static to
 libcfs_dev declaration
In-Reply-To: <20180510194128.GA19653@tanglefoot>
References: <20180510194128.GA19653@tanglefoot>
Message-ID: <87d0y39g44.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Justin Skists <justin.skists@juzza.co.uk>, devel@driverdev.osuosl.org, lustre-devel@lists.lustre.org, James Simmons <jsimmons@infradead.org>, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: linux-kernel@vger.kernel.org

On Thu, May 10 2018, Justin Skists wrote:

> Add a static prefix to the declaration for libcfs_dev. This would fix
> the following sparse warning:
>
> drivers/staging/lustre/lnet/libcfs/module.c:317:19: warning: symbol
> 'libcfs_dev' was not declared. Should it be static?

Thanks - that was my fault. (b4ded66db93b)
Reviewed-by: NeilBrown <neilb@suse.com>

Thanks,
NeilBrown

>
> Signed-off-by: Justin Skists <justin.skists@juzza.co.uk>
> ---
>  drivers/staging/lustre/lnet/libcfs/module.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/drivers/staging/lustre/lnet/libcfs/module.c b/drivers/staging/lustre/lnet/libcfs/module.c
> index ca942f474a55..e021e439f140 100644
> --- a/drivers/staging/lustre/lnet/libcfs/module.c
> +++ b/drivers/staging/lustre/lnet/libcfs/module.c
> @@ -314,7 +314,7 @@ static const struct file_operations libcfs_fops = {
>  	.unlocked_ioctl	= libcfs_psdev_ioctl,
>  };
>  
> -struct miscdevice libcfs_dev = {
> +static struct miscdevice libcfs_dev = {
>  	.minor = MISC_DYNAMIC_MINOR,
>  	.name = "lnet",
>  	.fops = &libcfs_fops,
> -- 
> 2.17.0
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180511/90899e3d/attachment.sig>
