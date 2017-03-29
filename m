From: Greg KH <greg@kroah.com>
Date: Wed, 29 Mar 2017 09:33:20 +0200
Subject: [lustre-devel] [PATCH] Clear sparse warning: different address
	space
In-Reply-To: <20170325030503.31675-1-kedrot@gmail.com>
References: <20170325030503.31675-1-kedrot@gmail.com>
Message-ID: <20170329073320.GD8459@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Sat, Mar 25, 2017 at 12:05:03AM -0300, Guillermo O. Freschi wrote:
> Made tagged `index` as `__user` to remove warning from
> `obd_iocontrol` call.

Your subject line is odd, please make it match other changes for this
driver.

> Signed-off-by: Guillermo O. Freschi <kedrot@gmail.com>
> ---
>  drivers/staging/lustre/lustre/llite/dir.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/staging/lustre/lustre/llite/dir.c b/drivers/staging/lustre/lustre/llite/dir.c
> index 13b35922a4ca..acdde21d41d9 100644
> --- a/drivers/staging/lustre/lustre/llite/dir.c
> +++ b/drivers/staging/lustre/lustre/llite/dir.c
> @@ -1464,7 +1464,7 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
>  	case LL_IOC_FID2MDTIDX: {
>  		struct obd_export *exp = ll_i2mdexp(inode);
>  		struct lu_fid fid;
> -		__u32 index;
> +		__u32 __user index;

Are you sure?  How did you test this?

thanks,

greg k-h
