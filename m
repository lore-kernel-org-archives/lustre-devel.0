From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Wed, 2 Dec 2015 12:48:43 +0300
Subject: [lustre-devel] [PATCH 12/40] staging: lustre: Dynamic LNet
 Configuration (DLC) IOCTL changes
In-Reply-To: <1448062576-23757-13-git-send-email-jsimmons@infradead.org>
References: <1448062576-23757-1-git-send-email-jsimmons@infradead.org>
	<1448062576-23757-13-git-send-email-jsimmons@infradead.org>
Message-ID: <20151202094843.GL18797@mwanda>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Fri, Nov 20, 2015 at 06:35:48PM -0500, James Simmons wrote:
> +int libcfs_ioctl_getdata_len(const struct libcfs_ioctl_hdr __user *arg,
> +			     __u32 *len)
> +{
> +	struct libcfs_ioctl_hdr hdr;
>  
> -	orig_len = hdr->ioc_len;
> -	if (copy_from_user(buf, arg, hdr->ioc_len))
> +	if (copy_from_user(&hdr, arg, sizeof(hdr)))
>  		return -EFAULT;
> -	if (orig_len != data->ioc_len)
> -		return -EINVAL;


This check was actually important.  I don't see where it was moved to so
it looks like this patch introduces a serious information leak.


>  
> -	if (libcfs_ioctl_is_invalid(data)) {
> -		CERROR("PORTALS: ioctl not correctly formatted\n");
> +	if (hdr.ioc_version != LIBCFS_IOCTL_VERSION) {
> +		CERROR("LNET: version mismatch expected %#x, got %#x\n",
> +		       LIBCFS_IOCTL_VERSION, hdr.ioc_version);
>  		return -EINVAL;
>  	}
>  
> -	if (data->ioc_inllen1)
> -		data->ioc_inlbuf1 = &data->ioc_bulk[0];
> +	*len = hdr.ioc_len;
>  
> -	if (data->ioc_inllen2)
> -		data->ioc_inlbuf2 = &data->ioc_bulk[0] +
> -			cfs_size_round(data->ioc_inllen1);
> +	return 0;
> +}
>  
> +int libcfs_ioctl_getdata(struct libcfs_ioctl_hdr *buf, __u32 buf_len,
> +			  const void __user *arg)
> +{
> +	if (copy_from_user(buf, arg, buf_len))
> +		return -EFAULT;
>  	return 0;
>  }

Don't introduce this wrapper.  Abstraction layers just make the code
harder to read and obscures bugs.  Also the caller changes -EFAULT to
-EINVAL so right away it starts to be buggy.

>  
> diff --git a/drivers/staging/lustre/lustre/libcfs/module.c b/drivers/staging/lustre/lustre/libcfs/module.c
> index 75247e9..5348699 100644
> --- a/drivers/staging/lustre/lustre/libcfs/module.c
> +++ b/drivers/staging/lustre/lustre/libcfs/module.c
> @@ -54,6 +54,8 @@
>  
>  # define DEBUG_SUBSYSTEM S_LNET
>  
> +#define LIBCFS_MAX_IOCTL_BUF_LEN 2048
> +
>  #include "../../include/linux/libcfs/libcfs.h"
>  #include <asm/div64.h>
>  
> @@ -241,11 +243,21 @@ int libcfs_deregister_ioctl(struct libcfs_ioctl_handler *hand)
>  }
>  EXPORT_SYMBOL(libcfs_deregister_ioctl);
>  
> -static int libcfs_ioctl_int(struct cfs_psdev_file *pfile, unsigned long cmd,
> -			    void *arg, struct libcfs_ioctl_data *data)
> +static int libcfs_ioctl_handle(struct cfs_psdev_file *pfile, unsigned long cmd,
> +			       void *arg, struct libcfs_ioctl_hdr *hdr)
>  {
> +	struct libcfs_ioctl_data *data = NULL;
>  	int err = -EINVAL;
>  
> +	if ((cmd <= IOC_LIBCFS_LNETST) ||
> +	    (cmd >= IOC_LIBCFS_REGISTER_MYNID)) {
> +		data = container_of(hdr, struct libcfs_ioctl_data, ioc_hdr);
> +		err = libcfs_ioctl_data_adjust(data);
> +		if (err != 0) {

Generally, remove pointless double negatives like this.  It should be
just "if (err) " instead of "if (err != 0 != 0 != 0 != 0) " or whatever.

> +			return err;
> +		}
> +	}
> +
>  	switch (cmd) {
>  	case IOC_LIBCFS_CLEAR_DEBUG:
>  		libcfs_debug_clear_buffer();
> @@ -280,11 +292,11 @@ static int libcfs_ioctl_int(struct cfs_psdev_file *pfile, unsigned long cmd,
>  		err = -EINVAL;
>  		down_read(&ioctl_list_sem);
>  		list_for_each_entry(hand, &ioctl_list, item) {
> -			err = hand->handle_ioctl(cmd, data);
> +			err = hand->handle_ioctl(cmd, hdr);
>  			if (err != -EINVAL) {
>  				if (err == 0)
>  					err = libcfs_ioctl_popdata(arg,
> -							data, sizeof(*data));
> +							hdr, hdr->ioc_len);

This variable has not been verified since the user wrote to it last so
here is the information leak.

regards,
dan carpenter
