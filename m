From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Wed, 3 Feb 2016 14:40:35 -0800
Subject: [lustre-devel] [PATCH 5/7] staging:lustre: simplify
	libcfs_psdev_[open|release]
In-Reply-To: <1452022519-6716-6-git-send-email-jsimmons@infradead.org>
References: <1452022519-6716-1-git-send-email-jsimmons@infradead.org>
	<1452022519-6716-6-git-send-email-jsimmons@infradead.org>
Message-ID: <20160203224035.GA10529@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Simmons <jsimmons@infradead.org>
Cc: devel@driverdev.osuosl.org, Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, Parinay Kondekar <parinay.kondekar@seagate.com>, James Simmons <uja.ornl@yahoo.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, lustre-devel@lists.lustre.org

On Tue, Jan 05, 2016 at 02:35:17PM -0500, James Simmons wrote:
> From: Parinay Kondekar <parinay.kondekar@seagate.com>
> 
> With struct libcfs_device_userstate gone we can move
> the remaining code of libcfs_psdev_ops.p_[open|close]
> into the libcfs_psdev_[open|release] functions directly.
> 
> Signed-off-by: Parinay Kondekar <parinay.kondekar@seagate.com>
> Signed-off-by: James Simmons <uja.ornl@yahoo.com>
> Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5844
> Reviewed-on: http://review.whamcloud.com/17492
> Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
> Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
> Reviewed-by: John L. Hammond <john.hammond@intel.com>
> Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
> ---
>  .../staging/lustre/include/linux/libcfs/libcfs.h   |    2 --
>  .../lustre/lustre/libcfs/linux/linux-module.c      |   20 ++++++--------------
>  drivers/staging/lustre/lustre/libcfs/module.c      |   16 ----------------
>  3 files changed, 6 insertions(+), 32 deletions(-)
> 
> diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs.h b/drivers/staging/lustre/include/linux/libcfs/libcfs.h
> index 0d8a91e..06bb676 100644
> --- a/drivers/staging/lustre/include/linux/libcfs/libcfs.h
> +++ b/drivers/staging/lustre/include/linux/libcfs/libcfs.h
> @@ -73,8 +73,6 @@ struct cfs_psdev_file {
>  };
>  
>  struct cfs_psdev_ops {
> -	int (*p_open)(unsigned long, void *);
> -	int (*p_close)(unsigned long, void *);
>  	int (*p_read)(struct cfs_psdev_file *, char *, unsigned long);
>  	int (*p_write)(struct cfs_psdev_file *, char *, unsigned long);
>  	int (*p_ioctl)(struct cfs_psdev_file *, unsigned long, void *);
> diff --git a/drivers/staging/lustre/lustre/libcfs/linux/linux-module.c b/drivers/staging/lustre/lustre/libcfs/linux/linux-module.c
> index 33f6036..64f0fbf 100644
> --- a/drivers/staging/lustre/lustre/libcfs/linux/linux-module.c
> +++ b/drivers/staging/lustre/lustre/libcfs/linux/linux-module.c
> @@ -98,30 +98,22 @@ int libcfs_ioctl_popdata(void *arg, void *data, int size)
>  static int
>  libcfs_psdev_open(struct inode *inode, struct file *file)
>  {
> -	int    rc = 0;
> -
>  	if (!inode)
>  		return -EINVAL;
> -	if (libcfs_psdev_ops.p_open != NULL)
> -		rc = libcfs_psdev_ops.p_open(0, NULL);
> -	else
> -		return -EPERM;
> -	return rc;
> +
> +	try_module_get(THIS_MODULE);

Note, code like this is racy and incorrect and never needed, please fix
this up properly (hint, set the module in the file operations.)

Again, if you ever see code with that line, it is incorrect.

thanks,

greg k-h
