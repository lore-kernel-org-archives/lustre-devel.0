From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Tue, 23 May 2017 21:38:55 +0200
Subject: [lustre-devel] [PATCH] drivers: staging: lustre: replace
 variable length array by dynamic allocation
In-Reply-To: <8c04ebb67ffbc9482cc6170e9bd29ec513766218.1495567933.git.raphael.beamonte@gmail.com>
References: <8c04ebb67ffbc9482cc6170e9bd29ec513766218.1495567933.git.raphael.beamonte@gmail.com>
Message-ID: <20170523193855.GA11862@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: =?iso-8859-1?Q?Rapha=EBl?= Beamonte <raphael.beamonte@gmail.com>
Cc: Oleg Drokin <oleg.drokin@intel.com>, devel@driverdev.osuosl.org, Sebastien Buisson <sebastien.buisson@bull.net>, Hongchao Zhang <hongchao.zhang@intel.com>, Fan Yong <fan.yong@intel.com>, linux-kernel@vger.kernel.org, Aditya Pandit <panditadityashreesh@yahoo.com>, Andreas Dilger <andreas.dilger@intel.com>, "John L. Hammond" <john.hammond@intel.com>, lustre-devel@lists.lustre.org

On Tue, May 23, 2017 at 09:32:13PM +0200, Rapha?l Beamonte wrote:
> Fixes the following sparse warnings:
> 
> drivers/staging/lustre/lustre/llite/xattr.c:89:62: warning: Variable
> length array is used.
> drivers/staging/lustre/lustre/llite/xattr.c:366:62: warning: Variable
> length array is used.
> 
> Signed-off-by: Rapha?l Beamonte <raphael.beamonte@gmail.com>
> ---
>  drivers/staging/lustre/lustre/llite/xattr.c | 24 ++++++++++++++++++++----
>  1 file changed, 20 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lustre/llite/xattr.c b/drivers/staging/lustre/lustre/llite/xattr.c
> index 6187bffec8c4..ccfc728d8ec0 100644
> --- a/drivers/staging/lustre/lustre/llite/xattr.c
> +++ b/drivers/staging/lustre/lustre/llite/xattr.c
> @@ -86,7 +86,7 @@ ll_xattr_set_common(const struct xattr_handler *handler,
>  		    const char *name, const void *value, size_t size,
>  		    int flags)
>  {
> -	char fullname[strlen(handler->prefix) + strlen(name) + 1];
> +	char *fullname;
>  	struct ll_sb_info *sbi = ll_i2sbi(inode);
>  	struct ptlrpc_request *req = NULL;
>  	const char *pv = value;
> @@ -140,10 +140,18 @@ ll_xattr_set_common(const struct xattr_handler *handler,
>  			return -EPERM;
>  	}
>  
> +	fullname = kmalloc(strlen(handler->prefix) + strlen(name) + 1,
> +			   GFP_KERNEL);
> +	if (!fullname)
> +		return -ENOMEM;
> +
>  	sprintf(fullname, "%s%s\n", handler->prefix, name);
>  	rc = md_setxattr(sbi->ll_md_exp, ll_inode2fid(inode),
>  			 valid, fullname, pv, size, 0, flags,
>  			 ll_i2suppgid(inode), &req);
> +
> +	kfree(fullname);

Didn't we reject much this same patch last week?

thanks,

greg k-h
